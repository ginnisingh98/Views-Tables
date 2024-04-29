--------------------------------------------------------
--  DDL for Package Body CSI_MASS_EDIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MASS_EDIT_PUB_W" as
  /* $Header: csipmewb.pls 120.5.12010000.3 2008/12/03 08:33:43 ngoutam ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy csi_mass_edit_pub.mass_edit_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entry_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).txn_line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).txn_line_detail_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).status_code := a4(indx);
          t(ddindx).batch_type := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).schedule_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).system_cascade := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t csi_mass_edit_pub.mass_edit_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).entry_id);
          a1(indx) := t(ddindx).name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_detail_id);
          a4(indx) := t(ddindx).status_code;
          a5(indx) := t(ddindx).batch_type;
          a6(indx) := t(ddindx).description;
          a7(indx) := t(ddindx).schedule_date;
          a8(indx) := t(ddindx).start_date;
          a9(indx) := t(ddindx).end_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a11(indx) := t(ddindx).system_cascade;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy csi_mass_edit_pub.mass_edit_inst_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).txn_line_detail_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t csi_mass_edit_pub.mass_edit_inst_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_detail_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a2(indx) := t(ddindx).active_end_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy csi_mass_edit_pub.mass_edit_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entry_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).txn_line_detail_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).instance_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).error_text := a3(indx);
          t(ddindx).error_code := a4(indx);
          t(ddindx).name := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t csi_mass_edit_pub.mass_edit_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).entry_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_detail_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a3(indx) := t(ddindx).error_text;
          a4(indx) := t(ddindx).error_code;
          a5(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy csi_mass_edit_pub.mass_edit_sys_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entry_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).batch_name := a1(indx);
          t(ddindx).txn_line_detail_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).system_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).error_text := a4(indx);
          t(ddindx).error_code := a5(indx);
          t(ddindx).name := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t csi_mass_edit_pub.mass_edit_sys_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).entry_id);
          a1(indx) := t(ddindx).batch_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_detail_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).system_id);
          a4(indx) := t(ddindx).error_text;
          a5(indx) := t(ddindx).error_code;
          a6(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy csi_mass_edit_pub.mass_upd_rep_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).entity_name := a1(indx);
          t(ddindx).error_message := a2(indx);
          t(ddindx).entry_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).txn_line_detail_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).error_code := a5(indx);
          t(ddindx).name := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t csi_mass_edit_pub.mass_upd_rep_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          a1(indx) := t(ddindx).entity_name;
          a2(indx) := t(ddindx).error_message;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).entry_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).txn_line_detail_id);
          a5(indx) := t(ddindx).error_code;
          a6(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure create_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
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
    , p5_a31 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  NUMBER
    , p7_a21 in out nocopy  DATE
    , p7_a22 in out nocopy  DATE
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  DATE
    , p7_a28 in out nocopy  DATE
    , p7_a29 in out nocopy  DATE
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  NUMBER
    , p7_a32 in out nocopy  NUMBER
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  NUMBER
    , p7_a35 in out nocopy  NUMBER
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  NUMBER
    , p7_a41 in out nocopy  NUMBER
    , p7_a42 in out nocopy  NUMBER
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  DATE
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  NUMBER
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  NUMBER
    , p7_a68 in out nocopy  NUMBER
    , p7_a69 in out nocopy  NUMBER
    , p7_a70 in out nocopy  NUMBER
    , p7_a71 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_DATE_TABLE
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_DATE_TABLE
    , p9_a8 in out nocopy JTF_DATE_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_DATE_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_mass_edit_rec csi_mass_edit_pub.mass_edit_rec;
    ddpx_txn_line_rec csi_t_datastructures_grp.txn_line_rec;
    ddpx_mass_edit_inst_tbl csi_mass_edit_pub.mass_edit_inst_tbl;
    ddpx_txn_line_detail_rec csi_t_datastructures_grp.txn_line_detail_rec;
    ddpx_txn_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl;
    ddpx_txn_pty_acct_detail_tbl csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    ddpx_txn_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    ddx_mass_edit_error_tbl csi_mass_edit_pub.mass_edit_error_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddpx_mass_edit_rec.entry_id := rosetta_g_miss_num_map(p4_a0);
    ddpx_mass_edit_rec.name := p4_a1;
    ddpx_mass_edit_rec.txn_line_id := rosetta_g_miss_num_map(p4_a2);
    ddpx_mass_edit_rec.txn_line_detail_id := rosetta_g_miss_num_map(p4_a3);
    ddpx_mass_edit_rec.status_code := p4_a4;
    ddpx_mass_edit_rec.batch_type := p4_a5;
    ddpx_mass_edit_rec.description := p4_a6;
    ddpx_mass_edit_rec.schedule_date := rosetta_g_miss_date_in_map(p4_a7);
    ddpx_mass_edit_rec.start_date := rosetta_g_miss_date_in_map(p4_a8);
    ddpx_mass_edit_rec.end_date := rosetta_g_miss_date_in_map(p4_a9);
    ddpx_mass_edit_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddpx_mass_edit_rec.system_cascade := p4_a11;

    ddpx_txn_line_rec.transaction_line_id := rosetta_g_miss_num_map(p5_a0);
    ddpx_txn_line_rec.source_transaction_type_id := rosetta_g_miss_num_map(p5_a1);
    ddpx_txn_line_rec.source_transaction_id := rosetta_g_miss_num_map(p5_a2);
    ddpx_txn_line_rec.source_txn_header_id := rosetta_g_miss_num_map(p5_a3);
    ddpx_txn_line_rec.source_transaction_table := p5_a4;
    ddpx_txn_line_rec.config_session_hdr_id := rosetta_g_miss_num_map(p5_a5);
    ddpx_txn_line_rec.config_session_rev_num := rosetta_g_miss_num_map(p5_a6);
    ddpx_txn_line_rec.config_session_item_id := rosetta_g_miss_num_map(p5_a7);
    ddpx_txn_line_rec.config_valid_status := p5_a8;
    ddpx_txn_line_rec.source_transaction_status := p5_a9;
    ddpx_txn_line_rec.api_caller_identity := p5_a10;
    ddpx_txn_line_rec.inv_material_txn_flag := p5_a11;
    ddpx_txn_line_rec.error_code := p5_a12;
    ddpx_txn_line_rec.error_explanation := p5_a13;
    ddpx_txn_line_rec.processing_status := p5_a14;
    ddpx_txn_line_rec.context := p5_a15;
    ddpx_txn_line_rec.attribute1 := p5_a16;
    ddpx_txn_line_rec.attribute2 := p5_a17;
    ddpx_txn_line_rec.attribute3 := p5_a18;
    ddpx_txn_line_rec.attribute4 := p5_a19;
    ddpx_txn_line_rec.attribute5 := p5_a20;
    ddpx_txn_line_rec.attribute6 := p5_a21;
    ddpx_txn_line_rec.attribute7 := p5_a22;
    ddpx_txn_line_rec.attribute8 := p5_a23;
    ddpx_txn_line_rec.attribute9 := p5_a24;
    ddpx_txn_line_rec.attribute10 := p5_a25;
    ddpx_txn_line_rec.attribute11 := p5_a26;
    ddpx_txn_line_rec.attribute12 := p5_a27;
    ddpx_txn_line_rec.attribute13 := p5_a28;
    ddpx_txn_line_rec.attribute14 := p5_a29;
    ddpx_txn_line_rec.attribute15 := p5_a30;
    ddpx_txn_line_rec.object_version_number := rosetta_g_miss_num_map(p5_a31);

    csi_mass_edit_pub_w.rosetta_table_copy_in_p6(ddpx_mass_edit_inst_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    ddpx_txn_line_detail_rec.txn_line_detail_id := rosetta_g_miss_num_map(p7_a0);
    ddpx_txn_line_detail_rec.transaction_line_id := rosetta_g_miss_num_map(p7_a1);
    ddpx_txn_line_detail_rec.sub_type_id := rosetta_g_miss_num_map(p7_a2);
    ddpx_txn_line_detail_rec.instance_exists_flag := p7_a3;
    ddpx_txn_line_detail_rec.source_transaction_flag := p7_a4;
    ddpx_txn_line_detail_rec.instance_id := rosetta_g_miss_num_map(p7_a5);
    ddpx_txn_line_detail_rec.changed_instance_id := rosetta_g_miss_num_map(p7_a6);
    ddpx_txn_line_detail_rec.csi_system_id := rosetta_g_miss_num_map(p7_a7);
    ddpx_txn_line_detail_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a8);
    ddpx_txn_line_detail_rec.inventory_revision := p7_a9;
    ddpx_txn_line_detail_rec.inv_organization_id := rosetta_g_miss_num_map(p7_a10);
    ddpx_txn_line_detail_rec.item_condition_id := rosetta_g_miss_num_map(p7_a11);
    ddpx_txn_line_detail_rec.instance_type_code := p7_a12;
    ddpx_txn_line_detail_rec.quantity := rosetta_g_miss_num_map(p7_a13);
    ddpx_txn_line_detail_rec.unit_of_measure := p7_a14;
    ddpx_txn_line_detail_rec.qty_remaining := rosetta_g_miss_num_map(p7_a15);
    ddpx_txn_line_detail_rec.serial_number := p7_a16;
    ddpx_txn_line_detail_rec.mfg_serial_number_flag := p7_a17;
    ddpx_txn_line_detail_rec.lot_number := p7_a18;
    ddpx_txn_line_detail_rec.location_type_code := p7_a19;
    ddpx_txn_line_detail_rec.location_id := rosetta_g_miss_num_map(p7_a20);
    ddpx_txn_line_detail_rec.installation_date := rosetta_g_miss_date_in_map(p7_a21);
    ddpx_txn_line_detail_rec.in_service_date := rosetta_g_miss_date_in_map(p7_a22);
    ddpx_txn_line_detail_rec.external_reference := p7_a23;
    ddpx_txn_line_detail_rec.transaction_system_id := rosetta_g_miss_num_map(p7_a24);
    ddpx_txn_line_detail_rec.sellable_flag := p7_a25;
    ddpx_txn_line_detail_rec.version_label := p7_a26;
    ddpx_txn_line_detail_rec.return_by_date := rosetta_g_miss_date_in_map(p7_a27);
    ddpx_txn_line_detail_rec.active_start_date := rosetta_g_miss_date_in_map(p7_a28);
    ddpx_txn_line_detail_rec.active_end_date := rosetta_g_miss_date_in_map(p7_a29);
    ddpx_txn_line_detail_rec.preserve_detail_flag := p7_a30;
    ddpx_txn_line_detail_rec.reference_source_id := rosetta_g_miss_num_map(p7_a31);
    ddpx_txn_line_detail_rec.reference_source_line_id := rosetta_g_miss_num_map(p7_a32);
    ddpx_txn_line_detail_rec.reference_source_date := rosetta_g_miss_date_in_map(p7_a33);
    ddpx_txn_line_detail_rec.csi_transaction_id := rosetta_g_miss_num_map(p7_a34);
    ddpx_txn_line_detail_rec.source_txn_line_detail_id := rosetta_g_miss_num_map(p7_a35);
    ddpx_txn_line_detail_rec.inv_mtl_transaction_id := rosetta_g_miss_num_map(p7_a36);
    ddpx_txn_line_detail_rec.processing_status := p7_a37;
    ddpx_txn_line_detail_rec.error_code := p7_a38;
    ddpx_txn_line_detail_rec.error_explanation := p7_a39;
    ddpx_txn_line_detail_rec.txn_systems_index := rosetta_g_miss_num_map(p7_a40);
    ddpx_txn_line_detail_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p7_a41);
    ddpx_txn_line_detail_rec.config_inst_rev_num := rosetta_g_miss_num_map(p7_a42);
    ddpx_txn_line_detail_rec.config_inst_item_id := rosetta_g_miss_num_map(p7_a43);
    ddpx_txn_line_detail_rec.config_inst_baseline_rev_num := rosetta_g_miss_num_map(p7_a44);
    ddpx_txn_line_detail_rec.target_commitment_date := rosetta_g_miss_date_in_map(p7_a45);
    ddpx_txn_line_detail_rec.instance_description := p7_a46;
    ddpx_txn_line_detail_rec.api_caller_identity := p7_a47;
    ddpx_txn_line_detail_rec.install_location_type_code := p7_a48;
    ddpx_txn_line_detail_rec.install_location_id := rosetta_g_miss_num_map(p7_a49);
    ddpx_txn_line_detail_rec.cascade_owner_flag := p7_a50;
    ddpx_txn_line_detail_rec.context := p7_a51;
    ddpx_txn_line_detail_rec.attribute1 := p7_a52;
    ddpx_txn_line_detail_rec.attribute2 := p7_a53;
    ddpx_txn_line_detail_rec.attribute3 := p7_a54;
    ddpx_txn_line_detail_rec.attribute4 := p7_a55;
    ddpx_txn_line_detail_rec.attribute5 := p7_a56;
    ddpx_txn_line_detail_rec.attribute6 := p7_a57;
    ddpx_txn_line_detail_rec.attribute7 := p7_a58;
    ddpx_txn_line_detail_rec.attribute8 := p7_a59;
    ddpx_txn_line_detail_rec.attribute9 := p7_a60;
    ddpx_txn_line_detail_rec.attribute10 := p7_a61;
    ddpx_txn_line_detail_rec.attribute11 := p7_a62;
    ddpx_txn_line_detail_rec.attribute12 := p7_a63;
    ddpx_txn_line_detail_rec.attribute13 := p7_a64;
    ddpx_txn_line_detail_rec.attribute14 := p7_a65;
    ddpx_txn_line_detail_rec.attribute15 := p7_a66;
    ddpx_txn_line_detail_rec.object_version_number := rosetta_g_miss_num_map(p7_a67);
    ddpx_txn_line_detail_rec.parent_instance_id := rosetta_g_miss_num_map(p7_a68);
    ddpx_txn_line_detail_rec.assc_txn_line_detail_id := rosetta_g_miss_num_map(p7_a69);
    ddpx_txn_line_detail_rec.overriding_csi_txn_id := rosetta_g_miss_num_map(p7_a70);
    ddpx_txn_line_detail_rec.instance_status_id := rosetta_g_miss_num_map(p7_a71);

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p6(ddpx_txn_party_detail_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p8(ddpx_txn_pty_acct_detail_tbl, p9_a0
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
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p14(ddpx_txn_ext_attrib_vals_tbl, p10_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.create_mass_edit_batch(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddpx_mass_edit_rec,
      ddpx_txn_line_rec,
      ddpx_mass_edit_inst_tbl,
      ddpx_txn_line_detail_rec,
      ddpx_txn_party_detail_tbl,
      ddpx_txn_pty_acct_detail_tbl,
      ddpx_txn_ext_attrib_vals_tbl,
      ddx_mass_edit_error_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.entry_id);
    p4_a1 := ddpx_mass_edit_rec.name;
    p4_a2 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_id);
    p4_a3 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_detail_id);
    p4_a4 := ddpx_mass_edit_rec.status_code;
    p4_a5 := ddpx_mass_edit_rec.batch_type;
    p4_a6 := ddpx_mass_edit_rec.description;
    p4_a7 := ddpx_mass_edit_rec.schedule_date;
    p4_a8 := ddpx_mass_edit_rec.start_date;
    p4_a9 := ddpx_mass_edit_rec.end_date;
    p4_a10 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.object_version_number);
    p4_a11 := ddpx_mass_edit_rec.system_cascade;

    p5_a0 := rosetta_g_miss_num_map(ddpx_txn_line_rec.transaction_line_id);
    p5_a1 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_transaction_type_id);
    p5_a2 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_transaction_id);
    p5_a3 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_txn_header_id);
    p5_a4 := ddpx_txn_line_rec.source_transaction_table;
    p5_a5 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_hdr_id);
    p5_a6 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_rev_num);
    p5_a7 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_item_id);
    p5_a8 := ddpx_txn_line_rec.config_valid_status;
    p5_a9 := ddpx_txn_line_rec.source_transaction_status;
    p5_a10 := ddpx_txn_line_rec.api_caller_identity;
    p5_a11 := ddpx_txn_line_rec.inv_material_txn_flag;
    p5_a12 := ddpx_txn_line_rec.error_code;
    p5_a13 := ddpx_txn_line_rec.error_explanation;
    p5_a14 := ddpx_txn_line_rec.processing_status;
    p5_a15 := ddpx_txn_line_rec.context;
    p5_a16 := ddpx_txn_line_rec.attribute1;
    p5_a17 := ddpx_txn_line_rec.attribute2;
    p5_a18 := ddpx_txn_line_rec.attribute3;
    p5_a19 := ddpx_txn_line_rec.attribute4;
    p5_a20 := ddpx_txn_line_rec.attribute5;
    p5_a21 := ddpx_txn_line_rec.attribute6;
    p5_a22 := ddpx_txn_line_rec.attribute7;
    p5_a23 := ddpx_txn_line_rec.attribute8;
    p5_a24 := ddpx_txn_line_rec.attribute9;
    p5_a25 := ddpx_txn_line_rec.attribute10;
    p5_a26 := ddpx_txn_line_rec.attribute11;
    p5_a27 := ddpx_txn_line_rec.attribute12;
    p5_a28 := ddpx_txn_line_rec.attribute13;
    p5_a29 := ddpx_txn_line_rec.attribute14;
    p5_a30 := ddpx_txn_line_rec.attribute15;
    p5_a31 := rosetta_g_miss_num_map(ddpx_txn_line_rec.object_version_number);

    csi_mass_edit_pub_w.rosetta_table_copy_out_p6(ddpx_mass_edit_inst_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    p7_a0 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.txn_line_detail_id);
    p7_a1 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.transaction_line_id);
    p7_a2 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.sub_type_id);
    p7_a3 := ddpx_txn_line_detail_rec.instance_exists_flag;
    p7_a4 := ddpx_txn_line_detail_rec.source_transaction_flag;
    p7_a5 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.instance_id);
    p7_a6 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.changed_instance_id);
    p7_a7 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.csi_system_id);
    p7_a8 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inventory_item_id);
    p7_a9 := ddpx_txn_line_detail_rec.inventory_revision;
    p7_a10 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inv_organization_id);
    p7_a11 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.item_condition_id);
    p7_a12 := ddpx_txn_line_detail_rec.instance_type_code;
    p7_a13 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.quantity);
    p7_a14 := ddpx_txn_line_detail_rec.unit_of_measure;
    p7_a15 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.qty_remaining);
    p7_a16 := ddpx_txn_line_detail_rec.serial_number;
    p7_a17 := ddpx_txn_line_detail_rec.mfg_serial_number_flag;
    p7_a18 := ddpx_txn_line_detail_rec.lot_number;
    p7_a19 := ddpx_txn_line_detail_rec.location_type_code;
    p7_a20 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.location_id);
    p7_a21 := ddpx_txn_line_detail_rec.installation_date;
    p7_a22 := ddpx_txn_line_detail_rec.in_service_date;
    p7_a23 := ddpx_txn_line_detail_rec.external_reference;
    p7_a24 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.transaction_system_id);
    p7_a25 := ddpx_txn_line_detail_rec.sellable_flag;
    p7_a26 := ddpx_txn_line_detail_rec.version_label;
    p7_a27 := ddpx_txn_line_detail_rec.return_by_date;
    p7_a28 := ddpx_txn_line_detail_rec.active_start_date;
    p7_a29 := ddpx_txn_line_detail_rec.active_end_date;
    p7_a30 := ddpx_txn_line_detail_rec.preserve_detail_flag;
    p7_a31 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.reference_source_id);
    p7_a32 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.reference_source_line_id);
    p7_a33 := ddpx_txn_line_detail_rec.reference_source_date;
    p7_a34 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.csi_transaction_id);
    p7_a35 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.source_txn_line_detail_id);
    p7_a36 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inv_mtl_transaction_id);
    p7_a37 := ddpx_txn_line_detail_rec.processing_status;
    p7_a38 := ddpx_txn_line_detail_rec.error_code;
    p7_a39 := ddpx_txn_line_detail_rec.error_explanation;
    p7_a40 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.txn_systems_index);
    p7_a41 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_hdr_id);
    p7_a42 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_rev_num);
    p7_a43 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_item_id);
    p7_a44 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_baseline_rev_num);
    p7_a45 := ddpx_txn_line_detail_rec.target_commitment_date;
    p7_a46 := ddpx_txn_line_detail_rec.instance_description;
    p7_a47 := ddpx_txn_line_detail_rec.api_caller_identity;
    p7_a48 := ddpx_txn_line_detail_rec.install_location_type_code;
    p7_a49 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.install_location_id);
    p7_a50 := ddpx_txn_line_detail_rec.cascade_owner_flag;
    p7_a51 := ddpx_txn_line_detail_rec.context;
    p7_a52 := ddpx_txn_line_detail_rec.attribute1;
    p7_a53 := ddpx_txn_line_detail_rec.attribute2;
    p7_a54 := ddpx_txn_line_detail_rec.attribute3;
    p7_a55 := ddpx_txn_line_detail_rec.attribute4;
    p7_a56 := ddpx_txn_line_detail_rec.attribute5;
    p7_a57 := ddpx_txn_line_detail_rec.attribute6;
    p7_a58 := ddpx_txn_line_detail_rec.attribute7;
    p7_a59 := ddpx_txn_line_detail_rec.attribute8;
    p7_a60 := ddpx_txn_line_detail_rec.attribute9;
    p7_a61 := ddpx_txn_line_detail_rec.attribute10;
    p7_a62 := ddpx_txn_line_detail_rec.attribute11;
    p7_a63 := ddpx_txn_line_detail_rec.attribute12;
    p7_a64 := ddpx_txn_line_detail_rec.attribute13;
    p7_a65 := ddpx_txn_line_detail_rec.attribute14;
    p7_a66 := ddpx_txn_line_detail_rec.attribute15;
    p7_a67 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.object_version_number);
    p7_a68 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.parent_instance_id);
    p7_a69 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.assc_txn_line_detail_id);
    p7_a70 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.overriding_csi_txn_id);
    p7_a71 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.instance_status_id);

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p6(ddpx_txn_party_detail_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p8(ddpx_txn_pty_acct_detail_tbl, p9_a0
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
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p14(ddpx_txn_ext_attrib_vals_tbl, p10_a0
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
      );

    csi_mass_edit_pub_w.rosetta_table_copy_out_p8(ddx_mass_edit_error_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      );



  end;

  procedure update_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
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
    , p5_a31 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  NUMBER
    , p7_a21 in out nocopy  DATE
    , p7_a22 in out nocopy  DATE
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  DATE
    , p7_a28 in out nocopy  DATE
    , p7_a29 in out nocopy  DATE
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  NUMBER
    , p7_a32 in out nocopy  NUMBER
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  NUMBER
    , p7_a35 in out nocopy  NUMBER
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  NUMBER
    , p7_a41 in out nocopy  NUMBER
    , p7_a42 in out nocopy  NUMBER
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  DATE
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  NUMBER
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  NUMBER
    , p7_a68 in out nocopy  NUMBER
    , p7_a69 in out nocopy  NUMBER
    , p7_a70 in out nocopy  NUMBER
    , p7_a71 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_DATE_TABLE
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_DATE_TABLE
    , p9_a8 in out nocopy JTF_DATE_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_DATE_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_mass_edit_rec csi_mass_edit_pub.mass_edit_rec;
    ddpx_txn_line_rec csi_t_datastructures_grp.txn_line_rec;
    ddpx_mass_edit_inst_tbl csi_mass_edit_pub.mass_edit_inst_tbl;
    ddpx_txn_line_detail_rec csi_t_datastructures_grp.txn_line_detail_rec;
    ddpx_txn_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl;
    ddpx_txn_pty_acct_detail_tbl csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    ddpx_txn_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    ddx_mass_edit_error_tbl csi_mass_edit_pub.mass_edit_error_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddpx_mass_edit_rec.entry_id := rosetta_g_miss_num_map(p4_a0);
    ddpx_mass_edit_rec.name := p4_a1;
    ddpx_mass_edit_rec.txn_line_id := rosetta_g_miss_num_map(p4_a2);
    ddpx_mass_edit_rec.txn_line_detail_id := rosetta_g_miss_num_map(p4_a3);
    ddpx_mass_edit_rec.status_code := p4_a4;
    ddpx_mass_edit_rec.batch_type := p4_a5;
    ddpx_mass_edit_rec.description := p4_a6;
    ddpx_mass_edit_rec.schedule_date := rosetta_g_miss_date_in_map(p4_a7);
    ddpx_mass_edit_rec.start_date := rosetta_g_miss_date_in_map(p4_a8);
    ddpx_mass_edit_rec.end_date := rosetta_g_miss_date_in_map(p4_a9);
    ddpx_mass_edit_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddpx_mass_edit_rec.system_cascade := p4_a11;

    ddpx_txn_line_rec.transaction_line_id := rosetta_g_miss_num_map(p5_a0);
    ddpx_txn_line_rec.source_transaction_type_id := rosetta_g_miss_num_map(p5_a1);
    ddpx_txn_line_rec.source_transaction_id := rosetta_g_miss_num_map(p5_a2);
    ddpx_txn_line_rec.source_txn_header_id := rosetta_g_miss_num_map(p5_a3);
    ddpx_txn_line_rec.source_transaction_table := p5_a4;
    ddpx_txn_line_rec.config_session_hdr_id := rosetta_g_miss_num_map(p5_a5);
    ddpx_txn_line_rec.config_session_rev_num := rosetta_g_miss_num_map(p5_a6);
    ddpx_txn_line_rec.config_session_item_id := rosetta_g_miss_num_map(p5_a7);
    ddpx_txn_line_rec.config_valid_status := p5_a8;
    ddpx_txn_line_rec.source_transaction_status := p5_a9;
    ddpx_txn_line_rec.api_caller_identity := p5_a10;
    ddpx_txn_line_rec.inv_material_txn_flag := p5_a11;
    ddpx_txn_line_rec.error_code := p5_a12;
    ddpx_txn_line_rec.error_explanation := p5_a13;
    ddpx_txn_line_rec.processing_status := p5_a14;
    ddpx_txn_line_rec.context := p5_a15;
    ddpx_txn_line_rec.attribute1 := p5_a16;
    ddpx_txn_line_rec.attribute2 := p5_a17;
    ddpx_txn_line_rec.attribute3 := p5_a18;
    ddpx_txn_line_rec.attribute4 := p5_a19;
    ddpx_txn_line_rec.attribute5 := p5_a20;
    ddpx_txn_line_rec.attribute6 := p5_a21;
    ddpx_txn_line_rec.attribute7 := p5_a22;
    ddpx_txn_line_rec.attribute8 := p5_a23;
    ddpx_txn_line_rec.attribute9 := p5_a24;
    ddpx_txn_line_rec.attribute10 := p5_a25;
    ddpx_txn_line_rec.attribute11 := p5_a26;
    ddpx_txn_line_rec.attribute12 := p5_a27;
    ddpx_txn_line_rec.attribute13 := p5_a28;
    ddpx_txn_line_rec.attribute14 := p5_a29;
    ddpx_txn_line_rec.attribute15 := p5_a30;
    ddpx_txn_line_rec.object_version_number := rosetta_g_miss_num_map(p5_a31);

    csi_mass_edit_pub_w.rosetta_table_copy_in_p6(ddpx_mass_edit_inst_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    ddpx_txn_line_detail_rec.txn_line_detail_id := rosetta_g_miss_num_map(p7_a0);
    ddpx_txn_line_detail_rec.transaction_line_id := rosetta_g_miss_num_map(p7_a1);
    ddpx_txn_line_detail_rec.sub_type_id := rosetta_g_miss_num_map(p7_a2);
    ddpx_txn_line_detail_rec.instance_exists_flag := p7_a3;
    ddpx_txn_line_detail_rec.source_transaction_flag := p7_a4;
    ddpx_txn_line_detail_rec.instance_id := rosetta_g_miss_num_map(p7_a5);
    ddpx_txn_line_detail_rec.changed_instance_id := rosetta_g_miss_num_map(p7_a6);
    ddpx_txn_line_detail_rec.csi_system_id := rosetta_g_miss_num_map(p7_a7);
    ddpx_txn_line_detail_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a8);
    ddpx_txn_line_detail_rec.inventory_revision := p7_a9;
    ddpx_txn_line_detail_rec.inv_organization_id := rosetta_g_miss_num_map(p7_a10);
    ddpx_txn_line_detail_rec.item_condition_id := rosetta_g_miss_num_map(p7_a11);
    ddpx_txn_line_detail_rec.instance_type_code := p7_a12;
    ddpx_txn_line_detail_rec.quantity := rosetta_g_miss_num_map(p7_a13);
    ddpx_txn_line_detail_rec.unit_of_measure := p7_a14;
    ddpx_txn_line_detail_rec.qty_remaining := rosetta_g_miss_num_map(p7_a15);
    ddpx_txn_line_detail_rec.serial_number := p7_a16;
    ddpx_txn_line_detail_rec.mfg_serial_number_flag := p7_a17;
    ddpx_txn_line_detail_rec.lot_number := p7_a18;
    ddpx_txn_line_detail_rec.location_type_code := p7_a19;
    ddpx_txn_line_detail_rec.location_id := rosetta_g_miss_num_map(p7_a20);
    ddpx_txn_line_detail_rec.installation_date := rosetta_g_miss_date_in_map(p7_a21);
    ddpx_txn_line_detail_rec.in_service_date := rosetta_g_miss_date_in_map(p7_a22);
    ddpx_txn_line_detail_rec.external_reference := p7_a23;
    ddpx_txn_line_detail_rec.transaction_system_id := rosetta_g_miss_num_map(p7_a24);
    ddpx_txn_line_detail_rec.sellable_flag := p7_a25;
    ddpx_txn_line_detail_rec.version_label := p7_a26;
    ddpx_txn_line_detail_rec.return_by_date := rosetta_g_miss_date_in_map(p7_a27);
    ddpx_txn_line_detail_rec.active_start_date := rosetta_g_miss_date_in_map(p7_a28);
    ddpx_txn_line_detail_rec.active_end_date := rosetta_g_miss_date_in_map(p7_a29);
    ddpx_txn_line_detail_rec.preserve_detail_flag := p7_a30;
    ddpx_txn_line_detail_rec.reference_source_id := rosetta_g_miss_num_map(p7_a31);
    ddpx_txn_line_detail_rec.reference_source_line_id := rosetta_g_miss_num_map(p7_a32);
    ddpx_txn_line_detail_rec.reference_source_date := rosetta_g_miss_date_in_map(p7_a33);
    ddpx_txn_line_detail_rec.csi_transaction_id := rosetta_g_miss_num_map(p7_a34);
    ddpx_txn_line_detail_rec.source_txn_line_detail_id := rosetta_g_miss_num_map(p7_a35);
    ddpx_txn_line_detail_rec.inv_mtl_transaction_id := rosetta_g_miss_num_map(p7_a36);
    ddpx_txn_line_detail_rec.processing_status := p7_a37;
    ddpx_txn_line_detail_rec.error_code := p7_a38;
    ddpx_txn_line_detail_rec.error_explanation := p7_a39;
    ddpx_txn_line_detail_rec.txn_systems_index := rosetta_g_miss_num_map(p7_a40);
    ddpx_txn_line_detail_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p7_a41);
    ddpx_txn_line_detail_rec.config_inst_rev_num := rosetta_g_miss_num_map(p7_a42);
    ddpx_txn_line_detail_rec.config_inst_item_id := rosetta_g_miss_num_map(p7_a43);
    ddpx_txn_line_detail_rec.config_inst_baseline_rev_num := rosetta_g_miss_num_map(p7_a44);
    ddpx_txn_line_detail_rec.target_commitment_date := rosetta_g_miss_date_in_map(p7_a45);
    ddpx_txn_line_detail_rec.instance_description := p7_a46;
    ddpx_txn_line_detail_rec.api_caller_identity := p7_a47;
    ddpx_txn_line_detail_rec.install_location_type_code := p7_a48;
    ddpx_txn_line_detail_rec.install_location_id := rosetta_g_miss_num_map(p7_a49);
    ddpx_txn_line_detail_rec.cascade_owner_flag := p7_a50;
    ddpx_txn_line_detail_rec.context := p7_a51;
    ddpx_txn_line_detail_rec.attribute1 := p7_a52;
    ddpx_txn_line_detail_rec.attribute2 := p7_a53;
    ddpx_txn_line_detail_rec.attribute3 := p7_a54;
    ddpx_txn_line_detail_rec.attribute4 := p7_a55;
    ddpx_txn_line_detail_rec.attribute5 := p7_a56;
    ddpx_txn_line_detail_rec.attribute6 := p7_a57;
    ddpx_txn_line_detail_rec.attribute7 := p7_a58;
    ddpx_txn_line_detail_rec.attribute8 := p7_a59;
    ddpx_txn_line_detail_rec.attribute9 := p7_a60;
    ddpx_txn_line_detail_rec.attribute10 := p7_a61;
    ddpx_txn_line_detail_rec.attribute11 := p7_a62;
    ddpx_txn_line_detail_rec.attribute12 := p7_a63;
    ddpx_txn_line_detail_rec.attribute13 := p7_a64;
    ddpx_txn_line_detail_rec.attribute14 := p7_a65;
    ddpx_txn_line_detail_rec.attribute15 := p7_a66;
    ddpx_txn_line_detail_rec.object_version_number := rosetta_g_miss_num_map(p7_a67);
    ddpx_txn_line_detail_rec.parent_instance_id := rosetta_g_miss_num_map(p7_a68);
    ddpx_txn_line_detail_rec.assc_txn_line_detail_id := rosetta_g_miss_num_map(p7_a69);
    ddpx_txn_line_detail_rec.overriding_csi_txn_id := rosetta_g_miss_num_map(p7_a70);
    ddpx_txn_line_detail_rec.instance_status_id := rosetta_g_miss_num_map(p7_a71);

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p6(ddpx_txn_party_detail_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p8(ddpx_txn_pty_acct_detail_tbl, p9_a0
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
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_in_p14(ddpx_txn_ext_attrib_vals_tbl, p10_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.update_mass_edit_batch(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddpx_mass_edit_rec,
      ddpx_txn_line_rec,
      ddpx_mass_edit_inst_tbl,
      ddpx_txn_line_detail_rec,
      ddpx_txn_party_detail_tbl,
      ddpx_txn_pty_acct_detail_tbl,
      ddpx_txn_ext_attrib_vals_tbl,
      ddx_mass_edit_error_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.entry_id);
    p4_a1 := ddpx_mass_edit_rec.name;
    p4_a2 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_id);
    p4_a3 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_detail_id);
    p4_a4 := ddpx_mass_edit_rec.status_code;
    p4_a5 := ddpx_mass_edit_rec.batch_type;
    p4_a6 := ddpx_mass_edit_rec.description;
    p4_a7 := ddpx_mass_edit_rec.schedule_date;
    p4_a8 := ddpx_mass_edit_rec.start_date;
    p4_a9 := ddpx_mass_edit_rec.end_date;
    p4_a10 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.object_version_number);
    p4_a11 := ddpx_mass_edit_rec.system_cascade;

    p5_a0 := rosetta_g_miss_num_map(ddpx_txn_line_rec.transaction_line_id);
    p5_a1 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_transaction_type_id);
    p5_a2 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_transaction_id);
    p5_a3 := rosetta_g_miss_num_map(ddpx_txn_line_rec.source_txn_header_id);
    p5_a4 := ddpx_txn_line_rec.source_transaction_table;
    p5_a5 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_hdr_id);
    p5_a6 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_rev_num);
    p5_a7 := rosetta_g_miss_num_map(ddpx_txn_line_rec.config_session_item_id);
    p5_a8 := ddpx_txn_line_rec.config_valid_status;
    p5_a9 := ddpx_txn_line_rec.source_transaction_status;
    p5_a10 := ddpx_txn_line_rec.api_caller_identity;
    p5_a11 := ddpx_txn_line_rec.inv_material_txn_flag;
    p5_a12 := ddpx_txn_line_rec.error_code;
    p5_a13 := ddpx_txn_line_rec.error_explanation;
    p5_a14 := ddpx_txn_line_rec.processing_status;
    p5_a15 := ddpx_txn_line_rec.context;
    p5_a16 := ddpx_txn_line_rec.attribute1;
    p5_a17 := ddpx_txn_line_rec.attribute2;
    p5_a18 := ddpx_txn_line_rec.attribute3;
    p5_a19 := ddpx_txn_line_rec.attribute4;
    p5_a20 := ddpx_txn_line_rec.attribute5;
    p5_a21 := ddpx_txn_line_rec.attribute6;
    p5_a22 := ddpx_txn_line_rec.attribute7;
    p5_a23 := ddpx_txn_line_rec.attribute8;
    p5_a24 := ddpx_txn_line_rec.attribute9;
    p5_a25 := ddpx_txn_line_rec.attribute10;
    p5_a26 := ddpx_txn_line_rec.attribute11;
    p5_a27 := ddpx_txn_line_rec.attribute12;
    p5_a28 := ddpx_txn_line_rec.attribute13;
    p5_a29 := ddpx_txn_line_rec.attribute14;
    p5_a30 := ddpx_txn_line_rec.attribute15;
    p5_a31 := rosetta_g_miss_num_map(ddpx_txn_line_rec.object_version_number);

    csi_mass_edit_pub_w.rosetta_table_copy_out_p6(ddpx_mass_edit_inst_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    p7_a0 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.txn_line_detail_id);
    p7_a1 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.transaction_line_id);
    p7_a2 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.sub_type_id);
    p7_a3 := ddpx_txn_line_detail_rec.instance_exists_flag;
    p7_a4 := ddpx_txn_line_detail_rec.source_transaction_flag;
    p7_a5 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.instance_id);
    p7_a6 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.changed_instance_id);
    p7_a7 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.csi_system_id);
    p7_a8 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inventory_item_id);
    p7_a9 := ddpx_txn_line_detail_rec.inventory_revision;
    p7_a10 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inv_organization_id);
    p7_a11 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.item_condition_id);
    p7_a12 := ddpx_txn_line_detail_rec.instance_type_code;
    p7_a13 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.quantity);
    p7_a14 := ddpx_txn_line_detail_rec.unit_of_measure;
    p7_a15 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.qty_remaining);
    p7_a16 := ddpx_txn_line_detail_rec.serial_number;
    p7_a17 := ddpx_txn_line_detail_rec.mfg_serial_number_flag;
    p7_a18 := ddpx_txn_line_detail_rec.lot_number;
    p7_a19 := ddpx_txn_line_detail_rec.location_type_code;
    p7_a20 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.location_id);
    p7_a21 := ddpx_txn_line_detail_rec.installation_date;
    p7_a22 := ddpx_txn_line_detail_rec.in_service_date;
    p7_a23 := ddpx_txn_line_detail_rec.external_reference;
    p7_a24 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.transaction_system_id);
    p7_a25 := ddpx_txn_line_detail_rec.sellable_flag;
    p7_a26 := ddpx_txn_line_detail_rec.version_label;
    p7_a27 := ddpx_txn_line_detail_rec.return_by_date;
    p7_a28 := ddpx_txn_line_detail_rec.active_start_date;
    p7_a29 := ddpx_txn_line_detail_rec.active_end_date;
    p7_a30 := ddpx_txn_line_detail_rec.preserve_detail_flag;
    p7_a31 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.reference_source_id);
    p7_a32 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.reference_source_line_id);
    p7_a33 := ddpx_txn_line_detail_rec.reference_source_date;
    p7_a34 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.csi_transaction_id);
    p7_a35 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.source_txn_line_detail_id);
    p7_a36 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.inv_mtl_transaction_id);
    p7_a37 := ddpx_txn_line_detail_rec.processing_status;
    p7_a38 := ddpx_txn_line_detail_rec.error_code;
    p7_a39 := ddpx_txn_line_detail_rec.error_explanation;
    p7_a40 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.txn_systems_index);
    p7_a41 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_hdr_id);
    p7_a42 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_rev_num);
    p7_a43 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_item_id);
    p7_a44 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.config_inst_baseline_rev_num);
    p7_a45 := ddpx_txn_line_detail_rec.target_commitment_date;
    p7_a46 := ddpx_txn_line_detail_rec.instance_description;
    p7_a47 := ddpx_txn_line_detail_rec.api_caller_identity;
    p7_a48 := ddpx_txn_line_detail_rec.install_location_type_code;
    p7_a49 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.install_location_id);
    p7_a50 := ddpx_txn_line_detail_rec.cascade_owner_flag;
    p7_a51 := ddpx_txn_line_detail_rec.context;
    p7_a52 := ddpx_txn_line_detail_rec.attribute1;
    p7_a53 := ddpx_txn_line_detail_rec.attribute2;
    p7_a54 := ddpx_txn_line_detail_rec.attribute3;
    p7_a55 := ddpx_txn_line_detail_rec.attribute4;
    p7_a56 := ddpx_txn_line_detail_rec.attribute5;
    p7_a57 := ddpx_txn_line_detail_rec.attribute6;
    p7_a58 := ddpx_txn_line_detail_rec.attribute7;
    p7_a59 := ddpx_txn_line_detail_rec.attribute8;
    p7_a60 := ddpx_txn_line_detail_rec.attribute9;
    p7_a61 := ddpx_txn_line_detail_rec.attribute10;
    p7_a62 := ddpx_txn_line_detail_rec.attribute11;
    p7_a63 := ddpx_txn_line_detail_rec.attribute12;
    p7_a64 := ddpx_txn_line_detail_rec.attribute13;
    p7_a65 := ddpx_txn_line_detail_rec.attribute14;
    p7_a66 := ddpx_txn_line_detail_rec.attribute15;
    p7_a67 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.object_version_number);
    p7_a68 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.parent_instance_id);
    p7_a69 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.assc_txn_line_detail_id);
    p7_a70 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.overriding_csi_txn_id);
    p7_a71 := rosetta_g_miss_num_map(ddpx_txn_line_detail_rec.instance_status_id);

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p6(ddpx_txn_party_detail_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p8(ddpx_txn_pty_acct_detail_tbl, p9_a0
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
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p14(ddpx_txn_ext_attrib_vals_tbl, p10_a0
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
      );

    csi_mass_edit_pub_w.rosetta_table_copy_out_p8(ddx_mass_edit_error_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      );



  end;

  procedure delete_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  DATE := fnd_api.g_miss_date
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_mass_edit_rec csi_mass_edit_pub.mass_edit_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_mass_edit_rec.entry_id := rosetta_g_miss_num_map(p4_a0);
    ddp_mass_edit_rec.name := p4_a1;
    ddp_mass_edit_rec.txn_line_id := rosetta_g_miss_num_map(p4_a2);
    ddp_mass_edit_rec.txn_line_detail_id := rosetta_g_miss_num_map(p4_a3);
    ddp_mass_edit_rec.status_code := p4_a4;
    ddp_mass_edit_rec.batch_type := p4_a5;
    ddp_mass_edit_rec.description := p4_a6;
    ddp_mass_edit_rec.schedule_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_mass_edit_rec.start_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_mass_edit_rec.end_date := rosetta_g_miss_date_in_map(p4_a9);
    ddp_mass_edit_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_mass_edit_rec.system_cascade := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.delete_mass_edit_batch(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_mass_edit_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_mass_edit_batches(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_2000
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_DATE_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_mass_edit_tbl csi_mass_edit_pub.mass_edit_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_mass_edit_pub_w.rosetta_table_copy_in_p4(ddp_mass_edit_tbl, p4_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.delete_mass_edit_batches(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_mass_edit_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_mass_edit_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_DATE_TABLE
    , p5_a22 out nocopy JTF_DATE_TABLE
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a27 out nocopy JTF_DATE_TABLE
    , p5_a28 out nocopy JTF_DATE_TABLE
    , p5_a29 out nocopy JTF_DATE_TABLE
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_NUMBER_TABLE
    , p5_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a33 out nocopy JTF_DATE_TABLE
    , p5_a34 out nocopy JTF_NUMBER_TABLE
    , p5_a35 out nocopy JTF_NUMBER_TABLE
    , p5_a36 out nocopy JTF_NUMBER_TABLE
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a40 out nocopy JTF_NUMBER_TABLE
    , p5_a41 out nocopy JTF_NUMBER_TABLE
    , p5_a42 out nocopy JTF_NUMBER_TABLE
    , p5_a43 out nocopy JTF_NUMBER_TABLE
    , p5_a44 out nocopy JTF_NUMBER_TABLE
    , p5_a45 out nocopy JTF_DATE_TABLE
    , p5_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a67 out nocopy JTF_NUMBER_TABLE
    , p5_a68 out nocopy JTF_NUMBER_TABLE
    , p5_a69 out nocopy JTF_NUMBER_TABLE
    , p5_a70 out nocopy JTF_NUMBER_TABLE
    , p5_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_mass_edit_rec csi_mass_edit_pub.mass_edit_rec;
    ddx_txn_line_detail_tbl csi_t_datastructures_grp.txn_line_detail_tbl;
    ddx_txn_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl;
    ddx_txn_pty_acct_detail_tbl csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    ddx_txn_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddpx_mass_edit_rec.entry_id := rosetta_g_miss_num_map(p4_a0);
    ddpx_mass_edit_rec.name := p4_a1;
    ddpx_mass_edit_rec.txn_line_id := rosetta_g_miss_num_map(p4_a2);
    ddpx_mass_edit_rec.txn_line_detail_id := rosetta_g_miss_num_map(p4_a3);
    ddpx_mass_edit_rec.status_code := p4_a4;
    ddpx_mass_edit_rec.batch_type := p4_a5;
    ddpx_mass_edit_rec.description := p4_a6;
    ddpx_mass_edit_rec.schedule_date := rosetta_g_miss_date_in_map(p4_a7);
    ddpx_mass_edit_rec.start_date := rosetta_g_miss_date_in_map(p4_a8);
    ddpx_mass_edit_rec.end_date := rosetta_g_miss_date_in_map(p4_a9);
    ddpx_mass_edit_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddpx_mass_edit_rec.system_cascade := p4_a11;








    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.get_mass_edit_details(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddpx_mass_edit_rec,
      ddx_txn_line_detail_tbl,
      ddx_txn_party_detail_tbl,
      ddx_txn_pty_acct_detail_tbl,
      ddx_txn_ext_attrib_vals_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.entry_id);
    p4_a1 := ddpx_mass_edit_rec.name;
    p4_a2 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_id);
    p4_a3 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.txn_line_detail_id);
    p4_a4 := ddpx_mass_edit_rec.status_code;
    p4_a5 := ddpx_mass_edit_rec.batch_type;
    p4_a6 := ddpx_mass_edit_rec.description;
    p4_a7 := ddpx_mass_edit_rec.schedule_date;
    p4_a8 := ddpx_mass_edit_rec.start_date;
    p4_a9 := ddpx_mass_edit_rec.end_date;
    p4_a10 := rosetta_g_miss_num_map(ddpx_mass_edit_rec.object_version_number);
    p4_a11 := ddpx_mass_edit_rec.system_cascade;

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p4(ddx_txn_line_detail_tbl, p5_a0
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
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p6(ddx_txn_party_detail_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p8(ddx_txn_pty_acct_detail_tbl, p7_a0
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
      , p7_a27
      );

    csi_t_datastructures_grp_w.rosetta_table_copy_out_p14(ddx_txn_ext_attrib_vals_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      );



  end;

  procedure process_system_mass_update(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_entry_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 in out nocopy JTF_NUMBER_TABLE
    , p3_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_NUMBER_TABLE
    , p3_a14 in out nocopy JTF_NUMBER_TABLE
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a18 in out nocopy JTF_NUMBER_TABLE
    , p3_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a20 in out nocopy JTF_DATE_TABLE
    , p3_a21 in out nocopy JTF_DATE_TABLE
    , p3_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 in out nocopy JTF_NUMBER_TABLE
    , p3_a24 in out nocopy JTF_NUMBER_TABLE
    , p3_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a26 in out nocopy JTF_NUMBER_TABLE
    , p3_a27 in out nocopy JTF_NUMBER_TABLE
    , p3_a28 in out nocopy JTF_NUMBER_TABLE
    , p3_a29 in out nocopy JTF_NUMBER_TABLE
    , p3_a30 in out nocopy JTF_NUMBER_TABLE
    , p3_a31 in out nocopy JTF_NUMBER_TABLE
    , p3_a32 in out nocopy JTF_NUMBER_TABLE
    , p3_a33 in out nocopy JTF_NUMBER_TABLE
    , p3_a34 in out nocopy JTF_NUMBER_TABLE
    , p3_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a36 in out nocopy JTF_NUMBER_TABLE
    , p3_a37 in out nocopy JTF_NUMBER_TABLE
    , p3_a38 in out nocopy JTF_NUMBER_TABLE
    , p3_a39 in out nocopy JTF_NUMBER_TABLE
    , p3_a40 in out nocopy JTF_DATE_TABLE
    , p3_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a42 in out nocopy JTF_DATE_TABLE
    , p3_a43 in out nocopy JTF_DATE_TABLE
    , p3_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a46 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a47 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a49 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a50 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a51 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a52 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a53 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a54 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a55 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a56 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a57 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a58 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a59 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a60 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a61 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a62 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a63 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a64 in out nocopy JTF_NUMBER_TABLE
    , p3_a65 in out nocopy JTF_NUMBER_TABLE
    , p3_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a67 in out nocopy JTF_NUMBER_TABLE
    , p3_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a70 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a71 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a72 in out nocopy JTF_NUMBER_TABLE
    , p3_a73 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a74 in out nocopy JTF_NUMBER_TABLE
    , p3_a75 in out nocopy JTF_NUMBER_TABLE
    , p3_a76 in out nocopy JTF_NUMBER_TABLE
    , p3_a77 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a78 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a79 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a80 in out nocopy JTF_NUMBER_TABLE
    , p3_a81 in out nocopy JTF_NUMBER_TABLE
    , p3_a82 in out nocopy JTF_NUMBER_TABLE
    , p3_a83 in out nocopy JTF_DATE_TABLE
    , p3_a84 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a85 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a86 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a87 in out nocopy JTF_NUMBER_TABLE
    , p3_a88 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a89 in out nocopy JTF_NUMBER_TABLE
    , p3_a90 in out nocopy JTF_NUMBER_TABLE
    , p3_a91 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a92 in out nocopy JTF_NUMBER_TABLE
    , p3_a93 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a94 in out nocopy JTF_NUMBER_TABLE
    , p3_a95 in out nocopy JTF_DATE_TABLE
    , p3_a96 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a97 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a98 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a99 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a100 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a101 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a102 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a103 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a104 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a105 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a106 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a107 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a108 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a109 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a110 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a111 in out nocopy JTF_NUMBER_TABLE
    , p3_a112 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a113 in out nocopy JTF_NUMBER_TABLE
    , p3_a114 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a115 in out nocopy JTF_NUMBER_TABLE
    , p3_a116 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a117 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a118 in out nocopy JTF_NUMBER_TABLE
    , p3_a119 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a120 in out nocopy JTF_NUMBER_TABLE
    , p3_a121 in out nocopy JTF_NUMBER_TABLE
    , p3_a122 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_DATE_TABLE
    , p4_a6 in out nocopy JTF_DATE_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_NUMBER_TABLE
    , p4_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_NUMBER_TABLE
    , p6_a33 in out nocopy JTF_DATE_TABLE
    , p6_a34 in out nocopy JTF_NUMBER_TABLE
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  DATE
    , p7_a2 in out nocopy  DATE
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  NUMBER
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  DATE
    , p7_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_instance_tbl csi_datastructures_pub.instance_tbl;
    ddp_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_party_tbl csi_datastructures_pub.party_tbl;
    ddp_account_tbl csi_datastructures_pub.party_account_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    csi_datastructures_pub_w.rosetta_table_copy_in_p19(ddp_instance_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      , p3_a40
      , p3_a41
      , p3_a42
      , p3_a43
      , p3_a44
      , p3_a45
      , p3_a46
      , p3_a47
      , p3_a48
      , p3_a49
      , p3_a50
      , p3_a51
      , p3_a52
      , p3_a53
      , p3_a54
      , p3_a55
      , p3_a56
      , p3_a57
      , p3_a58
      , p3_a59
      , p3_a60
      , p3_a61
      , p3_a62
      , p3_a63
      , p3_a64
      , p3_a65
      , p3_a66
      , p3_a67
      , p3_a68
      , p3_a69
      , p3_a70
      , p3_a71
      , p3_a72
      , p3_a73
      , p3_a74
      , p3_a75
      , p3_a76
      , p3_a77
      , p3_a78
      , p3_a79
      , p3_a80
      , p3_a81
      , p3_a82
      , p3_a83
      , p3_a84
      , p3_a85
      , p3_a86
      , p3_a87
      , p3_a88
      , p3_a89
      , p3_a90
      , p3_a91
      , p3_a92
      , p3_a93
      , p3_a94
      , p3_a95
      , p3_a96
      , p3_a97
      , p3_a98
      , p3_a99
      , p3_a100
      , p3_a101
      , p3_a102
      , p3_a103
      , p3_a104
      , p3_a105
      , p3_a106
      , p3_a107
      , p3_a108
      , p3_a109
      , p3_a110
      , p3_a111
      , p3_a112
      , p3_a113
      , p3_a114
      , p3_a115
      , p3_a116
      , p3_a117
      , p3_a118
      , p3_a119
      , p3_a120
      , p3_a121
      , p3_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_values_tbl, p4_a0
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
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p9(ddp_party_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p6(ddp_account_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p7_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p7_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p7_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p7_a5);
    ddp_txn_rec.source_group_ref := p7_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p7_a7);
    ddp_txn_rec.source_header_ref := p7_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p7_a9);
    ddp_txn_rec.source_line_ref := p7_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p7_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p7_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p7_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p7_a14);
    ddp_txn_rec.transaction_uom_code := p7_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p7_a16);
    ddp_txn_rec.transaction_status_code := p7_a17;
    ddp_txn_rec.transaction_action_code := p7_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p7_a19);
    ddp_txn_rec.context := p7_a20;
    ddp_txn_rec.attribute1 := p7_a21;
    ddp_txn_rec.attribute2 := p7_a22;
    ddp_txn_rec.attribute3 := p7_a23;
    ddp_txn_rec.attribute4 := p7_a24;
    ddp_txn_rec.attribute5 := p7_a25;
    ddp_txn_rec.attribute6 := p7_a26;
    ddp_txn_rec.attribute7 := p7_a27;
    ddp_txn_rec.attribute8 := p7_a28;
    ddp_txn_rec.attribute9 := p7_a29;
    ddp_txn_rec.attribute10 := p7_a30;
    ddp_txn_rec.attribute11 := p7_a31;
    ddp_txn_rec.attribute12 := p7_a32;
    ddp_txn_rec.attribute13 := p7_a33;
    ddp_txn_rec.attribute14 := p7_a34;
    ddp_txn_rec.attribute15 := p7_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p7_a36);
    ddp_txn_rec.split_reason_code := p7_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p7_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p7_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.process_system_mass_update(p_api_version,
      p_commit,
      p_entry_id,
      ddp_instance_tbl,
      ddp_ext_attrib_values_tbl,
      ddp_party_tbl,
      ddp_account_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csi_datastructures_pub_w.rosetta_table_copy_out_p19(ddp_instance_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      , p3_a40
      , p3_a41
      , p3_a42
      , p3_a43
      , p3_a44
      , p3_a45
      , p3_a46
      , p3_a47
      , p3_a48
      , p3_a49
      , p3_a50
      , p3_a51
      , p3_a52
      , p3_a53
      , p3_a54
      , p3_a55
      , p3_a56
      , p3_a57
      , p3_a58
      , p3_a59
      , p3_a60
      , p3_a61
      , p3_a62
      , p3_a63
      , p3_a64
      , p3_a65
      , p3_a66
      , p3_a67
      , p3_a68
      , p3_a69
      , p3_a70
      , p3_a71
      , p3_a72
      , p3_a73
      , p3_a74
      , p3_a75
      , p3_a76
      , p3_a77
      , p3_a78
      , p3_a79
      , p3_a80
      , p3_a81
      , p3_a82
      , p3_a83
      , p3_a84
      , p3_a85
      , p3_a86
      , p3_a87
      , p3_a88
      , p3_a89
      , p3_a90
      , p3_a91
      , p3_a92
      , p3_a93
      , p3_a94
      , p3_a95
      , p3_a96
      , p3_a97
      , p3_a98
      , p3_a99
      , p3_a100
      , p3_a101
      , p3_a102
      , p3_a103
      , p3_a104
      , p3_a105
      , p3_a106
      , p3_a107
      , p3_a108
      , p3_a109
      , p3_a110
      , p3_a111
      , p3_a112
      , p3_a113
      , p3_a114
      , p3_a115
      , p3_a116
      , p3_a117
      , p3_a118
      , p3_a119
      , p3_a120
      , p3_a121
      , p3_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddp_ext_attrib_values_tbl, p4_a0
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
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p9(ddp_party_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p6(ddp_account_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      );

    p7_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p7_a1 := ddp_txn_rec.transaction_date;
    p7_a2 := ddp_txn_rec.source_transaction_date;
    p7_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p7_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p7_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p7_a6 := ddp_txn_rec.source_group_ref;
    p7_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p7_a8 := ddp_txn_rec.source_header_ref;
    p7_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p7_a10 := ddp_txn_rec.source_line_ref;
    p7_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p7_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p7_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p7_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p7_a15 := ddp_txn_rec.transaction_uom_code;
    p7_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p7_a17 := ddp_txn_rec.transaction_status_code;
    p7_a18 := ddp_txn_rec.transaction_action_code;
    p7_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p7_a20 := ddp_txn_rec.context;
    p7_a21 := ddp_txn_rec.attribute1;
    p7_a22 := ddp_txn_rec.attribute2;
    p7_a23 := ddp_txn_rec.attribute3;
    p7_a24 := ddp_txn_rec.attribute4;
    p7_a25 := ddp_txn_rec.attribute5;
    p7_a26 := ddp_txn_rec.attribute6;
    p7_a27 := ddp_txn_rec.attribute7;
    p7_a28 := ddp_txn_rec.attribute8;
    p7_a29 := ddp_txn_rec.attribute9;
    p7_a30 := ddp_txn_rec.attribute10;
    p7_a31 := ddp_txn_rec.attribute11;
    p7_a32 := ddp_txn_rec.attribute12;
    p7_a33 := ddp_txn_rec.attribute13;
    p7_a34 := ddp_txn_rec.attribute14;
    p7_a35 := ddp_txn_rec.attribute15;
    p7_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p7_a37 := ddp_txn_rec.split_reason_code;
    p7_a38 := ddp_txn_rec.src_txn_creation_date;
    p7_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

  procedure identify_system_for_update(p_txn_line_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_upd_system_tbl csi_datastructures_pub.mu_systems_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.identify_system_for_update(p_txn_line_id,
      ddp_upd_system_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    csi_datastructures_pub_w.rosetta_table_copy_out_p94(ddp_upd_system_tbl, p1_a0
      );

  end;

  procedure validate_system_batch(p_entry_id  NUMBER
    , p_txn_line_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_upd_system_tbl csi_datastructures_pub.mu_systems_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csi_datastructures_pub_w.rosetta_table_copy_in_p94(ddp_upd_system_tbl, p2_a0
      );


    -- here's the delegated call to the old PL/SQL routine
    csi_mass_edit_pub.validate_system_batch(p_entry_id,
      p_txn_line_id,
      ddp_upd_system_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end csi_mass_edit_pub_w;

/
