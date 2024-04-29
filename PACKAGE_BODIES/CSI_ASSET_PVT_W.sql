--------------------------------------------------------
--  DDL for Package Body CSI_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ASSET_PVT_W" as
  /* $Header: csivaswb.pls 120.10 2008/01/15 03:36:11 devijay ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy csi_asset_pvt.lookup_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lookup_code := a0(indx);
          t(ddindx).valid_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t csi_asset_pvt.lookup_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).lookup_code;
          a1(indx) := t(ddindx).valid_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy csi_asset_pvt.asset_id_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).asset_book_type := a1(indx);
          t(ddindx).valid_flag := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t csi_asset_pvt.asset_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          a1(indx) := t(ddindx).asset_book_type;
          a2(indx) := t(ddindx).valid_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy csi_asset_pvt.asset_loc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_loc_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).valid_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t csi_asset_pvt.asset_loc_tbl, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).asset_loc_id);
          a1(indx) := t(ddindx).valid_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy csi_asset_pvt.instance_asset_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inst_interface_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).fa_asset_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).inst_asset_quantity := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t csi_asset_pvt.instance_asset_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).inst_interface_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).fa_asset_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).inst_asset_quantity);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy csi_asset_pvt.fa_asset_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fa_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).fa_asset_quantity := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).sync_up_quantity := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t csi_asset_pvt.fa_asset_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).fa_asset_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).fa_asset_quantity);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).sync_up_quantity);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy csi_asset_pvt.instance_sync_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
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
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inst_interface_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).instance_quantity := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).sync_up_quantity := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).vld_status := a4(indx);
          t(ddindx).hop := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).location_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).location_type_code := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t csi_asset_pvt.instance_sync_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).inst_interface_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).instance_quantity);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).sync_up_quantity);
          a4(indx) := t(ddindx).vld_status;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).hop);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a7(indx) := t(ddindx).location_type_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure initialize_asset_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  VARCHAR2
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  DATE
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  VARCHAR2
    , p_inst_asset_hist_id  NUMBER
    , x_nearest_full_dump in out nocopy  date
  )

  as
    ddx_instance_asset_rec csi_datastructures_pub.instance_asset_header_rec;
    ddx_nearest_full_dump date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddx_instance_asset_rec.instance_asset_id := rosetta_g_miss_num_map(p0_a0);
    ddx_instance_asset_rec.instance_id := rosetta_g_miss_num_map(p0_a1);
    ddx_instance_asset_rec.fa_asset_id := rosetta_g_miss_num_map(p0_a2);
    ddx_instance_asset_rec.fa_book_type_code := p0_a3;
    ddx_instance_asset_rec.fa_location_id := rosetta_g_miss_num_map(p0_a4);
    ddx_instance_asset_rec.asset_quantity := rosetta_g_miss_num_map(p0_a5);
    ddx_instance_asset_rec.update_status := p0_a6;
    ddx_instance_asset_rec.active_start_date := rosetta_g_miss_date_in_map(p0_a7);
    ddx_instance_asset_rec.active_end_date := rosetta_g_miss_date_in_map(p0_a8);
    ddx_instance_asset_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddx_instance_asset_rec.asset_number := p0_a10;
    ddx_instance_asset_rec.serial_number := p0_a11;
    ddx_instance_asset_rec.tag_number := p0_a12;
    ddx_instance_asset_rec.category := p0_a13;
    ddx_instance_asset_rec.fa_location_segment1 := p0_a14;
    ddx_instance_asset_rec.fa_location_segment2 := p0_a15;
    ddx_instance_asset_rec.fa_location_segment3 := p0_a16;
    ddx_instance_asset_rec.fa_location_segment4 := p0_a17;
    ddx_instance_asset_rec.fa_location_segment5 := p0_a18;
    ddx_instance_asset_rec.fa_location_segment6 := p0_a19;
    ddx_instance_asset_rec.fa_location_segment7 := p0_a20;
    ddx_instance_asset_rec.date_placed_in_service := rosetta_g_miss_date_in_map(p0_a21);
    ddx_instance_asset_rec.description := p0_a22;
    ddx_instance_asset_rec.employee_name := p0_a23;
    ddx_instance_asset_rec.expense_account_number := p0_a24;
    ddx_instance_asset_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p0_a25);
    ddx_instance_asset_rec.creation_complete_flag := p0_a26;


    ddx_nearest_full_dump := rosetta_g_miss_date_in_map(x_nearest_full_dump);

    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.initialize_asset_rec(ddx_instance_asset_rec,
      p_inst_asset_hist_id,
      ddx_nearest_full_dump);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_instance_asset_rec.instance_asset_id);
    p0_a1 := rosetta_g_miss_num_map(ddx_instance_asset_rec.instance_id);
    p0_a2 := rosetta_g_miss_num_map(ddx_instance_asset_rec.fa_asset_id);
    p0_a3 := ddx_instance_asset_rec.fa_book_type_code;
    p0_a4 := rosetta_g_miss_num_map(ddx_instance_asset_rec.fa_location_id);
    p0_a5 := rosetta_g_miss_num_map(ddx_instance_asset_rec.asset_quantity);
    p0_a6 := ddx_instance_asset_rec.update_status;
    p0_a7 := ddx_instance_asset_rec.active_start_date;
    p0_a8 := ddx_instance_asset_rec.active_end_date;
    p0_a9 := rosetta_g_miss_num_map(ddx_instance_asset_rec.object_version_number);
    p0_a10 := ddx_instance_asset_rec.asset_number;
    p0_a11 := ddx_instance_asset_rec.serial_number;
    p0_a12 := ddx_instance_asset_rec.tag_number;
    p0_a13 := ddx_instance_asset_rec.category;
    p0_a14 := ddx_instance_asset_rec.fa_location_segment1;
    p0_a15 := ddx_instance_asset_rec.fa_location_segment2;
    p0_a16 := ddx_instance_asset_rec.fa_location_segment3;
    p0_a17 := ddx_instance_asset_rec.fa_location_segment4;
    p0_a18 := ddx_instance_asset_rec.fa_location_segment5;
    p0_a19 := ddx_instance_asset_rec.fa_location_segment6;
    p0_a20 := ddx_instance_asset_rec.fa_location_segment7;
    p0_a21 := ddx_instance_asset_rec.date_placed_in_service;
    p0_a22 := ddx_instance_asset_rec.description;
    p0_a23 := ddx_instance_asset_rec.employee_name;
    p0_a24 := ddx_instance_asset_rec.expense_account_number;
    p0_a25 := rosetta_g_miss_num_map(ddx_instance_asset_rec.fa_mass_addition_id);
    p0_a26 := ddx_instance_asset_rec.creation_complete_flag;


    x_nearest_full_dump := ddx_nearest_full_dump;
  end;

  procedure construct_asset_from_hist(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_DATE_TABLE
    , p0_a8 in out nocopy JTF_DATE_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_DATE_TABLE
    , p0_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_time_stamp  date
  )

  as
    ddx_instance_asset_tbl csi_datastructures_pub.instance_asset_header_tbl;
    ddp_time_stamp date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_in_p59(ddx_instance_asset_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      );

    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);

    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.construct_asset_from_hist(ddx_instance_asset_tbl,
      ddp_time_stamp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_out_p59(ddx_instance_asset_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      );

  end;

  procedure get_asset_column_values(p_get_asset_cursor_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  DATE
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
  )

  as
    ddx_inst_asset_rec csi_datastructures_pub.instance_asset_header_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_asset_column_values(p_get_asset_cursor_id,
      ddx_inst_asset_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_inst_asset_rec.instance_asset_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_inst_asset_rec.instance_id);
    p1_a2 := rosetta_g_miss_num_map(ddx_inst_asset_rec.fa_asset_id);
    p1_a3 := ddx_inst_asset_rec.fa_book_type_code;
    p1_a4 := rosetta_g_miss_num_map(ddx_inst_asset_rec.fa_location_id);
    p1_a5 := rosetta_g_miss_num_map(ddx_inst_asset_rec.asset_quantity);
    p1_a6 := ddx_inst_asset_rec.update_status;
    p1_a7 := ddx_inst_asset_rec.active_start_date;
    p1_a8 := ddx_inst_asset_rec.active_end_date;
    p1_a9 := rosetta_g_miss_num_map(ddx_inst_asset_rec.object_version_number);
    p1_a10 := ddx_inst_asset_rec.asset_number;
    p1_a11 := ddx_inst_asset_rec.serial_number;
    p1_a12 := ddx_inst_asset_rec.tag_number;
    p1_a13 := ddx_inst_asset_rec.category;
    p1_a14 := ddx_inst_asset_rec.fa_location_segment1;
    p1_a15 := ddx_inst_asset_rec.fa_location_segment2;
    p1_a16 := ddx_inst_asset_rec.fa_location_segment3;
    p1_a17 := ddx_inst_asset_rec.fa_location_segment4;
    p1_a18 := ddx_inst_asset_rec.fa_location_segment5;
    p1_a19 := ddx_inst_asset_rec.fa_location_segment6;
    p1_a20 := ddx_inst_asset_rec.fa_location_segment7;
    p1_a21 := ddx_inst_asset_rec.date_placed_in_service;
    p1_a22 := ddx_inst_asset_rec.description;
    p1_a23 := ddx_inst_asset_rec.employee_name;
    p1_a24 := ddx_inst_asset_rec.expense_account_number;
    p1_a25 := rosetta_g_miss_num_map(ddx_inst_asset_rec.fa_mass_addition_id);
    p1_a26 := ddx_inst_asset_rec.creation_complete_flag;
  end;

  procedure bind_asset_variable(p_get_asset_cursor_id  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  NUMBER := 0-1962.0724
  )

  as
    ddp_inst_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_inst_asset_query_rec.instance_asset_id := rosetta_g_miss_num_map(p0_a0);
    ddp_inst_asset_query_rec.instance_id := rosetta_g_miss_num_map(p0_a1);
    ddp_inst_asset_query_rec.fa_asset_id := rosetta_g_miss_num_map(p0_a2);
    ddp_inst_asset_query_rec.fa_book_type_code := p0_a3;
    ddp_inst_asset_query_rec.fa_location_id := rosetta_g_miss_num_map(p0_a4);
    ddp_inst_asset_query_rec.update_status := p0_a5;
    ddp_inst_asset_query_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p0_a6);


    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.bind_asset_variable(ddp_inst_asset_query_rec,
      p_get_asset_cursor_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure resolve_id_columns(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_DATE_TABLE
    , p0_a8 in out nocopy JTF_DATE_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_DATE_TABLE
    , p0_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_asset_header_tbl csi_datastructures_pub.instance_asset_header_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_in_p59(ddp_asset_header_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.resolve_id_columns(ddp_asset_header_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_out_p59(ddp_asset_header_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      );
  end;

  procedure gen_asset_where_clause(x_where_clause out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  NUMBER := 0-1962.0724
  )

  as
    ddp_inst_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_inst_asset_query_rec.instance_asset_id := rosetta_g_miss_num_map(p0_a0);
    ddp_inst_asset_query_rec.instance_id := rosetta_g_miss_num_map(p0_a1);
    ddp_inst_asset_query_rec.fa_asset_id := rosetta_g_miss_num_map(p0_a2);
    ddp_inst_asset_query_rec.fa_book_type_code := p0_a3;
    ddp_inst_asset_query_rec.fa_location_id := rosetta_g_miss_num_map(p0_a4);
    ddp_inst_asset_query_rec.update_status := p0_a5;
    ddp_inst_asset_query_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p0_a6);


    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.gen_asset_where_clause(ddp_inst_asset_query_rec,
      x_where_clause);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure get_instance_assets(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_resolve_id_columns  VARCHAR2
    , p_time_stamp  date
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
  )

  as
    ddp_instance_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
    ddp_time_stamp date;
    ddx_instance_asset_tbl csi_datastructures_pub.instance_asset_header_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_asset_query_rec.instance_asset_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_asset_query_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_instance_asset_query_rec.fa_asset_id := rosetta_g_miss_num_map(p4_a2);
    ddp_instance_asset_query_rec.fa_book_type_code := p4_a3;
    ddp_instance_asset_query_rec.fa_location_id := rosetta_g_miss_num_map(p4_a4);
    ddp_instance_asset_query_rec.update_status := p4_a5;
    ddp_instance_asset_query_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p4_a6);


    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);





    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_instance_assets(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_asset_query_rec,
      p_resolve_id_columns,
      ddp_time_stamp,
      ddx_instance_asset_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    csi_datastructures_pub_w.rosetta_table_copy_out_p59(ddx_instance_asset_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      );



  end;

  procedure create_instance_asset(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0 in out nocopy JTF_NUMBER_TABLE
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_called_from_grp  VARCHAR2
  )

  as
    ddp_instance_asset_rec csi_datastructures_pub.instance_asset_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddp_lookup_tbl csi_asset_pvt.lookup_tbl;
    ddp_asset_count_rec csi_asset_pvt.asset_count_rec;
    ddp_asset_id_tbl csi_asset_pvt.asset_id_tbl;
    ddp_asset_loc_tbl csi_asset_pvt.asset_loc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_asset_rec.instance_asset_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_asset_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_instance_asset_rec.fa_asset_id := rosetta_g_miss_num_map(p4_a2);
    ddp_instance_asset_rec.fa_book_type_code := p4_a3;
    ddp_instance_asset_rec.fa_location_id := rosetta_g_miss_num_map(p4_a4);
    ddp_instance_asset_rec.asset_quantity := rosetta_g_miss_num_map(p4_a5);
    ddp_instance_asset_rec.update_status := p4_a6;
    ddp_instance_asset_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_instance_asset_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_instance_asset_rec.object_version_number := rosetta_g_miss_num_map(p4_a9);
    ddp_instance_asset_rec.check_for_instance_expiry := p4_a10;
    ddp_instance_asset_rec.parent_tbl_index := rosetta_g_miss_num_map(p4_a11);
    ddp_instance_asset_rec.fa_sync_flag := p4_a12;
    ddp_instance_asset_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_instance_asset_rec.creation_complete_flag := p4_a14;
    ddp_instance_asset_rec.fa_sync_validation_reqd := p4_a15;

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    csi_asset_pvt_w.rosetta_table_copy_in_p1(ddp_lookup_tbl, p9_a0
      , p9_a1
      );

    ddp_asset_count_rec.asset_count := rosetta_g_miss_num_map(p10_a0);
    ddp_asset_count_rec.lookup_count := rosetta_g_miss_num_map(p10_a1);
    ddp_asset_count_rec.loc_count := rosetta_g_miss_num_map(p10_a2);

    csi_asset_pvt_w.rosetta_table_copy_in_p4(ddp_asset_id_tbl, p11_a0
      , p11_a1
      , p11_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p6(ddp_asset_loc_tbl, p12_a0
      , p12_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.create_instance_asset(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_asset_rec,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lookup_tbl,
      ddp_asset_count_rec,
      ddp_asset_id_tbl,
      ddp_asset_loc_tbl,
      p_called_from_grp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_instance_asset_rec.instance_asset_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_instance_asset_rec.instance_id);
    p4_a2 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_asset_id);
    p4_a3 := ddp_instance_asset_rec.fa_book_type_code;
    p4_a4 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_location_id);
    p4_a5 := rosetta_g_miss_num_map(ddp_instance_asset_rec.asset_quantity);
    p4_a6 := ddp_instance_asset_rec.update_status;
    p4_a7 := ddp_instance_asset_rec.active_start_date;
    p4_a8 := ddp_instance_asset_rec.active_end_date;
    p4_a9 := rosetta_g_miss_num_map(ddp_instance_asset_rec.object_version_number);
    p4_a10 := ddp_instance_asset_rec.check_for_instance_expiry;
    p4_a11 := rosetta_g_miss_num_map(ddp_instance_asset_rec.parent_tbl_index);
    p4_a12 := ddp_instance_asset_rec.fa_sync_flag;
    p4_a13 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_mass_addition_id);
    p4_a14 := ddp_instance_asset_rec.creation_complete_flag;
    p4_a15 := ddp_instance_asset_rec.fa_sync_validation_reqd;

    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);




    csi_asset_pvt_w.rosetta_table_copy_out_p1(ddp_lookup_tbl, p9_a0
      , p9_a1
      );

    p10_a0 := rosetta_g_miss_num_map(ddp_asset_count_rec.asset_count);
    p10_a1 := rosetta_g_miss_num_map(ddp_asset_count_rec.lookup_count);
    p10_a2 := rosetta_g_miss_num_map(ddp_asset_count_rec.loc_count);

    csi_asset_pvt_w.rosetta_table_copy_out_p4(ddp_asset_id_tbl, p11_a0
      , p11_a1
      , p11_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p6(ddp_asset_loc_tbl, p12_a0
      , p12_a1
      );

  end;

  procedure update_instance_asset(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0 in out nocopy JTF_NUMBER_TABLE
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_instance_asset_rec csi_datastructures_pub.instance_asset_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddp_lookup_tbl csi_asset_pvt.lookup_tbl;
    ddp_asset_count_rec csi_asset_pvt.asset_count_rec;
    ddp_asset_id_tbl csi_asset_pvt.asset_id_tbl;
    ddp_asset_loc_tbl csi_asset_pvt.asset_loc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_asset_rec.instance_asset_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_asset_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_instance_asset_rec.fa_asset_id := rosetta_g_miss_num_map(p4_a2);
    ddp_instance_asset_rec.fa_book_type_code := p4_a3;
    ddp_instance_asset_rec.fa_location_id := rosetta_g_miss_num_map(p4_a4);
    ddp_instance_asset_rec.asset_quantity := rosetta_g_miss_num_map(p4_a5);
    ddp_instance_asset_rec.update_status := p4_a6;
    ddp_instance_asset_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_instance_asset_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_instance_asset_rec.object_version_number := rosetta_g_miss_num_map(p4_a9);
    ddp_instance_asset_rec.check_for_instance_expiry := p4_a10;
    ddp_instance_asset_rec.parent_tbl_index := rosetta_g_miss_num_map(p4_a11);
    ddp_instance_asset_rec.fa_sync_flag := p4_a12;
    ddp_instance_asset_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_instance_asset_rec.creation_complete_flag := p4_a14;
    ddp_instance_asset_rec.fa_sync_validation_reqd := p4_a15;

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    csi_asset_pvt_w.rosetta_table_copy_in_p1(ddp_lookup_tbl, p9_a0
      , p9_a1
      );

    ddp_asset_count_rec.asset_count := rosetta_g_miss_num_map(p10_a0);
    ddp_asset_count_rec.lookup_count := rosetta_g_miss_num_map(p10_a1);
    ddp_asset_count_rec.loc_count := rosetta_g_miss_num_map(p10_a2);

    csi_asset_pvt_w.rosetta_table_copy_in_p4(ddp_asset_id_tbl, p11_a0
      , p11_a1
      , p11_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p6(ddp_asset_loc_tbl, p12_a0
      , p12_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.update_instance_asset(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_asset_rec,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lookup_tbl,
      ddp_asset_count_rec,
      ddp_asset_id_tbl,
      ddp_asset_loc_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_instance_asset_rec.instance_asset_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_instance_asset_rec.instance_id);
    p4_a2 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_asset_id);
    p4_a3 := ddp_instance_asset_rec.fa_book_type_code;
    p4_a4 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_location_id);
    p4_a5 := rosetta_g_miss_num_map(ddp_instance_asset_rec.asset_quantity);
    p4_a6 := ddp_instance_asset_rec.update_status;
    p4_a7 := ddp_instance_asset_rec.active_start_date;
    p4_a8 := ddp_instance_asset_rec.active_end_date;
    p4_a9 := rosetta_g_miss_num_map(ddp_instance_asset_rec.object_version_number);
    p4_a10 := ddp_instance_asset_rec.check_for_instance_expiry;
    p4_a11 := rosetta_g_miss_num_map(ddp_instance_asset_rec.parent_tbl_index);
    p4_a12 := ddp_instance_asset_rec.fa_sync_flag;
    p4_a13 := rosetta_g_miss_num_map(ddp_instance_asset_rec.fa_mass_addition_id);
    p4_a14 := ddp_instance_asset_rec.creation_complete_flag;
    p4_a15 := ddp_instance_asset_rec.fa_sync_validation_reqd;

    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);




    csi_asset_pvt_w.rosetta_table_copy_out_p1(ddp_lookup_tbl, p9_a0
      , p9_a1
      );

    p10_a0 := rosetta_g_miss_num_map(ddp_asset_count_rec.asset_count);
    p10_a1 := rosetta_g_miss_num_map(ddp_asset_count_rec.lookup_count);
    p10_a2 := rosetta_g_miss_num_map(ddp_asset_count_rec.loc_count);

    csi_asset_pvt_w.rosetta_table_copy_out_p4(ddp_asset_id_tbl, p11_a0
      , p11_a1
      , p11_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p6(ddp_asset_loc_tbl, p12_a0
      , p12_a1
      );
  end;

  procedure get_instance_asset_hist(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_DATE_TABLE
    , p5_a14 out nocopy JTF_DATE_TABLE
    , p5_a15 out nocopy JTF_DATE_TABLE
    , p5_a16 out nocopy JTF_DATE_TABLE
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 out nocopy JTF_DATE_TABLE
    , p5_a40 out nocopy JTF_DATE_TABLE
    , p5_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a47 out nocopy JTF_NUMBER_TABLE
    , p5_a48 out nocopy JTF_NUMBER_TABLE
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a52 out nocopy JTF_NUMBER_TABLE
    , p5_a53 out nocopy JTF_NUMBER_TABLE
    , p5_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_ins_asset_hist_tbl csi_datastructures_pub.ins_asset_history_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_instance_asset_hist(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_transaction_id,
      ddx_ins_asset_hist_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    csi_datastructures_pub_w.rosetta_table_copy_out_p63(ddx_ins_asset_hist_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      );



  end;

  procedure asset_syncup_validation(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , x_error_msg out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddpx_instance_sync_tbl csi_asset_pvt.instance_sync_tbl;
    ddpx_instance_asset_sync_tbl csi_asset_pvt.instance_asset_sync_tbl;
    ddpx_fa_asset_sync_tbl csi_asset_pvt.fa_asset_sync_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_asset_pvt_w.rosetta_table_copy_in_p12(ddpx_instance_sync_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p8(ddpx_instance_asset_sync_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p10(ddpx_fa_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );



    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.asset_syncup_validation(ddpx_instance_sync_tbl,
      ddpx_instance_asset_sync_tbl,
      ddpx_fa_asset_sync_tbl,
      x_error_msg,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_asset_pvt_w.rosetta_table_copy_out_p12(ddpx_instance_sync_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p8(ddpx_instance_asset_sync_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p10(ddpx_fa_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );


  end;

  procedure get_attached_item_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  )

  as
    ddp_instance_asset_sync_tbl csi_asset_pvt.instance_asset_sync_tbl;
    ddx_instance_sync_tbl csi_asset_pvt.instance_sync_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csi_asset_pvt_w.rosetta_table_copy_in_p8(ddp_instance_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );







    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_attached_item_instances(p_api_version,
      p_init_msg_list,
      ddp_instance_asset_sync_tbl,
      ddx_instance_sync_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_system_name,
      p_called_from_grp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csi_asset_pvt_w.rosetta_table_copy_out_p12(ddx_instance_sync_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );





  end;

  procedure get_attached_asset_links(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  )

  as
    ddp_instance_sync_tbl csi_asset_pvt.instance_sync_tbl;
    ddx_instance_asset_sync_tbl csi_asset_pvt.instance_asset_sync_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csi_asset_pvt_w.rosetta_table_copy_in_p12(ddp_instance_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );







    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_attached_asset_links(p_api_version,
      p_init_msg_list,
      ddp_instance_sync_tbl,
      ddx_instance_asset_sync_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_system_name,
      p_called_from_grp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csi_asset_pvt_w.rosetta_table_copy_out_p8(ddx_instance_asset_sync_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      );





  end;

  procedure get_fa_asset_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  )

  as
    ddp_instance_asset_sync_tbl csi_asset_pvt.instance_asset_sync_tbl;
    ddx_fa_asset_sync_tab csi_asset_pvt.fa_asset_sync_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csi_asset_pvt_w.rosetta_table_copy_in_p8(ddp_instance_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );







    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_fa_asset_details(p_api_version,
      p_init_msg_list,
      ddp_instance_asset_sync_tbl,
      ddx_fa_asset_sync_tab,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_system_name,
      p_called_from_grp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csi_asset_pvt_w.rosetta_table_copy_out_p10(ddx_fa_asset_sync_tab, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      );





  end;

  procedure get_syncup_tree(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
    , p_source_system_name  VARCHAR2
    , p_called_from_grp  VARCHAR2
  )

  as
    ddpx_instance_sync_tbl csi_asset_pvt.instance_sync_tbl;
    ddpx_instance_asset_sync_tbl csi_asset_pvt.instance_asset_sync_tbl;
    ddx_fa_asset_sync_tbl csi_asset_pvt.fa_asset_sync_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_asset_pvt_w.rosetta_table_copy_in_p12(ddpx_instance_sync_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p8(ddpx_instance_asset_sync_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p10(ddx_fa_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );





    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.get_syncup_tree(ddpx_instance_sync_tbl,
      ddpx_instance_asset_sync_tbl,
      ddx_fa_asset_sync_tbl,
      x_return_status,
      x_error_msg,
      p_source_system_name,
      p_called_from_grp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_asset_pvt_w.rosetta_table_copy_out_p12(ddpx_instance_sync_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p8(ddpx_instance_asset_sync_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p10(ddx_fa_asset_sync_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );




  end;

  procedure create_instance_assets(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_DATE_TABLE
    , p4_a8 in out nocopy JTF_DATE_TABLE
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddp_lookup_tbl csi_asset_pvt.lookup_tbl;
    ddp_asset_count_rec csi_asset_pvt.asset_count_rec;
    ddp_asset_id_tbl csi_asset_pvt.asset_id_tbl;
    ddp_asset_loc_tbl csi_asset_pvt.asset_loc_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p52(ddp_instance_asset_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);

    csi_asset_pvt_w.rosetta_table_copy_in_p1(ddp_lookup_tbl, p6_a0
      , p6_a1
      );

    ddp_asset_count_rec.asset_count := rosetta_g_miss_num_map(p7_a0);
    ddp_asset_count_rec.lookup_count := rosetta_g_miss_num_map(p7_a1);
    ddp_asset_count_rec.loc_count := rosetta_g_miss_num_map(p7_a2);

    csi_asset_pvt_w.rosetta_table_copy_in_p4(ddp_asset_id_tbl, p8_a0
      , p8_a1
      , p8_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_in_p6(ddp_asset_loc_tbl, p9_a0
      , p9_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.create_instance_assets(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_asset_tbl,
      ddp_txn_rec,
      ddp_lookup_tbl,
      ddp_asset_count_rec,
      ddp_asset_id_tbl,
      ddp_asset_loc_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddp_instance_asset_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      );

    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);

    csi_asset_pvt_w.rosetta_table_copy_out_p1(ddp_lookup_tbl, p6_a0
      , p6_a1
      );

    p7_a0 := rosetta_g_miss_num_map(ddp_asset_count_rec.asset_count);
    p7_a1 := rosetta_g_miss_num_map(ddp_asset_count_rec.lookup_count);
    p7_a2 := rosetta_g_miss_num_map(ddp_asset_count_rec.loc_count);

    csi_asset_pvt_w.rosetta_table_copy_out_p4(ddp_asset_id_tbl, p8_a0
      , p8_a1
      , p8_a2
      );

    csi_asset_pvt_w.rosetta_table_copy_out_p6(ddp_asset_loc_tbl, p9_a0
      , p9_a1
      );



  end;

  procedure set_fa_sync_flag(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p_location_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddpx_instance_asset_rec csi_datastructures_pub.instance_asset_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddpx_instance_asset_rec.instance_asset_id := rosetta_g_miss_num_map(p0_a0);
    ddpx_instance_asset_rec.instance_id := rosetta_g_miss_num_map(p0_a1);
    ddpx_instance_asset_rec.fa_asset_id := rosetta_g_miss_num_map(p0_a2);
    ddpx_instance_asset_rec.fa_book_type_code := p0_a3;
    ddpx_instance_asset_rec.fa_location_id := rosetta_g_miss_num_map(p0_a4);
    ddpx_instance_asset_rec.asset_quantity := rosetta_g_miss_num_map(p0_a5);
    ddpx_instance_asset_rec.update_status := p0_a6;
    ddpx_instance_asset_rec.active_start_date := rosetta_g_miss_date_in_map(p0_a7);
    ddpx_instance_asset_rec.active_end_date := rosetta_g_miss_date_in_map(p0_a8);
    ddpx_instance_asset_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddpx_instance_asset_rec.check_for_instance_expiry := p0_a10;
    ddpx_instance_asset_rec.parent_tbl_index := rosetta_g_miss_num_map(p0_a11);
    ddpx_instance_asset_rec.fa_sync_flag := p0_a12;
    ddpx_instance_asset_rec.fa_mass_addition_id := rosetta_g_miss_num_map(p0_a13);
    ddpx_instance_asset_rec.creation_complete_flag := p0_a14;
    ddpx_instance_asset_rec.fa_sync_validation_reqd := p0_a15;




    -- here's the delegated call to the old PL/SQL routine
    csi_asset_pvt.set_fa_sync_flag(ddpx_instance_asset_rec,
      p_location_id,
      x_return_status,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.instance_asset_id);
    p0_a1 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.instance_id);
    p0_a2 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.fa_asset_id);
    p0_a3 := ddpx_instance_asset_rec.fa_book_type_code;
    p0_a4 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.fa_location_id);
    p0_a5 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.asset_quantity);
    p0_a6 := ddpx_instance_asset_rec.update_status;
    p0_a7 := ddpx_instance_asset_rec.active_start_date;
    p0_a8 := ddpx_instance_asset_rec.active_end_date;
    p0_a9 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.object_version_number);
    p0_a10 := ddpx_instance_asset_rec.check_for_instance_expiry;
    p0_a11 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.parent_tbl_index);
    p0_a12 := ddpx_instance_asset_rec.fa_sync_flag;
    p0_a13 := rosetta_g_miss_num_map(ddpx_instance_asset_rec.fa_mass_addition_id);
    p0_a14 := ddpx_instance_asset_rec.creation_complete_flag;
    p0_a15 := ddpx_instance_asset_rec.fa_sync_validation_reqd;



  end;

end csi_asset_pvt_w;

/
