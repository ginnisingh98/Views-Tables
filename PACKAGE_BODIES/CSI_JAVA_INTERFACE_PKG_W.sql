--------------------------------------------------------
--  DDL for Package Body CSI_JAVA_INTERFACE_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_JAVA_INTERFACE_PKG_W" as
  /* $Header: csivjiwb.pls 120.19.12010000.2 2009/05/25 05:24:52 dsingire ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy csi_java_interface_pkg.csi_output_tbl_ib, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).sts_code := a3(indx);
          t(ddindx).service_line_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).service_name := a5(indx);
          t(ddindx).service_description := a6(indx);
          t(ddindx).coverage_term_line_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).coverage_term_name := a8(indx);
          t(ddindx).coverage_term_description := a9(indx);
          t(ddindx).service_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).service_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).warranty_flag := a12(indx);
          t(ddindx).eligible_for_entitlement := a13(indx);
          t(ddindx).exp_reaction_time := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).exp_resolution_time := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).status_code := a16(indx);
          t(ddindx).status_text := a17(indx);
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a18(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t csi_java_interface_pkg.csi_output_tbl_ib, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_DATE_TABLE();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).contract_id);
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).sts_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).service_line_id);
          a5(indx) := t(ddindx).service_name;
          a6(indx) := t(ddindx).service_description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).coverage_term_line_id);
          a8(indx) := t(ddindx).coverage_term_name;
          a9(indx) := t(ddindx).coverage_term_description;
          a10(indx) := t(ddindx).service_start_date;
          a11(indx) := t(ddindx).service_end_date;
          a12(indx) := t(ddindx).warranty_flag;
          a13(indx) := t(ddindx).eligible_for_entitlement;
          a14(indx) := t(ddindx).exp_reaction_time;
          a15(indx) := t(ddindx).exp_resolution_time;
          a16(indx) := t(ddindx).status_code;
          a17(indx) := t(ddindx).status_text;
          a18(indx) := t(ddindx).date_terminated;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy csi_java_interface_pkg.csi_coverage_tbl_ib, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).covered_level_code := a0(indx);
          t(ddindx).covered_level_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t csi_java_interface_pkg.csi_coverage_tbl_ib, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).covered_level_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).covered_level_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy csi_java_interface_pkg.dpl_instance_tbl, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csi_java_interface_pkg.dpl_instance_tbl, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).instance_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
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
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_party_tbl csi_datastructures_pub.party_tbl;
    ddp_account_tbl csi_datastructures_pub.party_account_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_rec.instance_number := p4_a1;
    ddp_instance_rec.external_reference := p4_a2;
    ddp_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a3);
    ddp_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p4_a4);
    ddp_instance_rec.inventory_revision := p4_a5;
    ddp_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a6);
    ddp_instance_rec.serial_number := p4_a7;
    ddp_instance_rec.mfg_serial_number_flag := p4_a8;
    ddp_instance_rec.lot_number := p4_a9;
    ddp_instance_rec.quantity := rosetta_g_miss_num_map(p4_a10);
    ddp_instance_rec.unit_of_measure := p4_a11;
    ddp_instance_rec.accounting_class_code := p4_a12;
    ddp_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_instance_rec.instance_status_id := rosetta_g_miss_num_map(p4_a14);
    ddp_instance_rec.customer_view_flag := p4_a15;
    ddp_instance_rec.merchant_view_flag := p4_a16;
    ddp_instance_rec.sellable_flag := p4_a17;
    ddp_instance_rec.system_id := rosetta_g_miss_num_map(p4_a18);
    ddp_instance_rec.instance_type_code := p4_a19;
    ddp_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_instance_rec.location_type_code := p4_a22;
    ddp_instance_rec.location_id := rosetta_g_miss_num_map(p4_a23);
    ddp_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a24);
    ddp_instance_rec.inv_subinventory_name := p4_a25;
    ddp_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a26);
    ddp_instance_rec.pa_project_id := rosetta_g_miss_num_map(p4_a27);
    ddp_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a28);
    ddp_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a29);
    ddp_instance_rec.wip_job_id := rosetta_g_miss_num_map(p4_a30);
    ddp_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a31);
    ddp_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a32);
    ddp_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a33);
    ddp_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a34);
    ddp_instance_rec.last_oe_po_number := p4_a35;
    ddp_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a36);
    ddp_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a37);
    ddp_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a38);
    ddp_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a39);
    ddp_instance_rec.install_date := rosetta_g_miss_date_in_map(p4_a40);
    ddp_instance_rec.manually_created_flag := p4_a41;
    ddp_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a42);
    ddp_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a43);
    ddp_instance_rec.creation_complete_flag := p4_a44;
    ddp_instance_rec.completeness_flag := p4_a45;
    ddp_instance_rec.version_label := p4_a46;
    ddp_instance_rec.version_label_description := p4_a47;
    ddp_instance_rec.context := p4_a48;
    ddp_instance_rec.attribute1 := p4_a49;
    ddp_instance_rec.attribute2 := p4_a50;
    ddp_instance_rec.attribute3 := p4_a51;
    ddp_instance_rec.attribute4 := p4_a52;
    ddp_instance_rec.attribute5 := p4_a53;
    ddp_instance_rec.attribute6 := p4_a54;
    ddp_instance_rec.attribute7 := p4_a55;
    ddp_instance_rec.attribute8 := p4_a56;
    ddp_instance_rec.attribute9 := p4_a57;
    ddp_instance_rec.attribute10 := p4_a58;
    ddp_instance_rec.attribute11 := p4_a59;
    ddp_instance_rec.attribute12 := p4_a60;
    ddp_instance_rec.attribute13 := p4_a61;
    ddp_instance_rec.attribute14 := p4_a62;
    ddp_instance_rec.attribute15 := p4_a63;
    ddp_instance_rec.object_version_number := rosetta_g_miss_num_map(p4_a64);
    ddp_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p4_a65);
    ddp_instance_rec.install_location_type_code := p4_a66;
    ddp_instance_rec.install_location_id := rosetta_g_miss_num_map(p4_a67);
    ddp_instance_rec.instance_usage_code := p4_a68;
    ddp_instance_rec.check_for_instance_expiry := p4_a69;
    ddp_instance_rec.processed_flag := p4_a70;
    ddp_instance_rec.call_contracts := p4_a71;
    ddp_instance_rec.interface_id := rosetta_g_miss_num_map(p4_a72);
    ddp_instance_rec.grp_call_contracts := p4_a73;
    ddp_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a74);
    ddp_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a75);
    ddp_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a76);
    ddp_instance_rec.config_valid_status := p4_a77;
    ddp_instance_rec.instance_description := p4_a78;
    ddp_instance_rec.call_batch_validation := p4_a79;
    ddp_instance_rec.request_id := rosetta_g_miss_num_map(p4_a80);
    ddp_instance_rec.program_application_id := rosetta_g_miss_num_map(p4_a81);
    ddp_instance_rec.program_id := rosetta_g_miss_num_map(p4_a82);
    ddp_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a83);
    ddp_instance_rec.cascade_ownership_flag := p4_a84;
    ddp_instance_rec.network_asset_flag := p4_a85;
    ddp_instance_rec.maintainable_flag := p4_a86;
    ddp_instance_rec.pn_location_id := rosetta_g_miss_num_map(p4_a87);
    ddp_instance_rec.asset_criticality_code := p4_a88;
    ddp_instance_rec.category_id := rosetta_g_miss_num_map(p4_a89);
    ddp_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p4_a90);
    ddp_instance_rec.instantiation_flag := p4_a91;
    ddp_instance_rec.linear_location_id := rosetta_g_miss_num_map(p4_a92);
    ddp_instance_rec.operational_log_flag := p4_a93;
    ddp_instance_rec.checkin_status := rosetta_g_miss_num_map(p4_a94);
    ddp_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p4_a95);
    ddp_instance_rec.attribute16 := p4_a96;
    ddp_instance_rec.attribute17 := p4_a97;
    ddp_instance_rec.attribute18 := p4_a98;
    ddp_instance_rec.attribute19 := p4_a99;
    ddp_instance_rec.attribute20 := p4_a100;
    ddp_instance_rec.attribute21 := p4_a101;
    ddp_instance_rec.attribute22 := p4_a102;
    ddp_instance_rec.attribute23 := p4_a103;
    ddp_instance_rec.attribute24 := p4_a104;
    ddp_instance_rec.attribute25 := p4_a105;
    ddp_instance_rec.attribute26 := p4_a106;
    ddp_instance_rec.attribute27 := p4_a107;
    ddp_instance_rec.attribute28 := p4_a108;
    ddp_instance_rec.attribute29 := p4_a109;
    ddp_instance_rec.attribute30 := p4_a110;
    ddp_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p4_a111);
    ddp_instance_rec.purchase_currency_code := p4_a112;
    ddp_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p4_a113);
    ddp_instance_rec.payables_currency_code := p4_a114;
    ddp_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p4_a115);
    ddp_instance_rec.sales_currency_code := p4_a116;
    ddp_instance_rec.operational_status_code := p4_a117;
    ddp_instance_rec.department_id := rosetta_g_miss_num_map(p4_a118);
    ddp_instance_rec.wip_accounting_class := p4_a119;
    ddp_instance_rec.area_id := rosetta_g_miss_num_map(p4_a120);
    ddp_instance_rec.owner_party_id := rosetta_g_miss_num_map(p4_a121);
    ddp_instance_rec.source_code := p4_a122;

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
    csi_java_interface_pkg.create_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_rec,
      ddp_party_tbl,
      ddp_account_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_instance_rec.instance_id);
    p4_a1 := ddp_instance_rec.instance_number;
    p4_a2 := ddp_instance_rec.external_reference;
    p4_a3 := rosetta_g_miss_num_map(ddp_instance_rec.inventory_item_id);
    p4_a4 := rosetta_g_miss_num_map(ddp_instance_rec.vld_organization_id);
    p4_a5 := ddp_instance_rec.inventory_revision;
    p4_a6 := rosetta_g_miss_num_map(ddp_instance_rec.inv_master_organization_id);
    p4_a7 := ddp_instance_rec.serial_number;
    p4_a8 := ddp_instance_rec.mfg_serial_number_flag;
    p4_a9 := ddp_instance_rec.lot_number;
    p4_a10 := rosetta_g_miss_num_map(ddp_instance_rec.quantity);
    p4_a11 := ddp_instance_rec.unit_of_measure;
    p4_a12 := ddp_instance_rec.accounting_class_code;
    p4_a13 := rosetta_g_miss_num_map(ddp_instance_rec.instance_condition_id);
    p4_a14 := rosetta_g_miss_num_map(ddp_instance_rec.instance_status_id);
    p4_a15 := ddp_instance_rec.customer_view_flag;
    p4_a16 := ddp_instance_rec.merchant_view_flag;
    p4_a17 := ddp_instance_rec.sellable_flag;
    p4_a18 := rosetta_g_miss_num_map(ddp_instance_rec.system_id);
    p4_a19 := ddp_instance_rec.instance_type_code;
    p4_a20 := ddp_instance_rec.active_start_date;
    p4_a21 := ddp_instance_rec.active_end_date;
    p4_a22 := ddp_instance_rec.location_type_code;
    p4_a23 := rosetta_g_miss_num_map(ddp_instance_rec.location_id);
    p4_a24 := rosetta_g_miss_num_map(ddp_instance_rec.inv_organization_id);
    p4_a25 := ddp_instance_rec.inv_subinventory_name;
    p4_a26 := rosetta_g_miss_num_map(ddp_instance_rec.inv_locator_id);
    p4_a27 := rosetta_g_miss_num_map(ddp_instance_rec.pa_project_id);
    p4_a28 := rosetta_g_miss_num_map(ddp_instance_rec.pa_project_task_id);
    p4_a29 := rosetta_g_miss_num_map(ddp_instance_rec.in_transit_order_line_id);
    p4_a30 := rosetta_g_miss_num_map(ddp_instance_rec.wip_job_id);
    p4_a31 := rosetta_g_miss_num_map(ddp_instance_rec.po_order_line_id);
    p4_a32 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_order_line_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_rma_line_id);
    p4_a34 := rosetta_g_miss_num_map(ddp_instance_rec.last_po_po_line_id);
    p4_a35 := ddp_instance_rec.last_oe_po_number;
    p4_a36 := rosetta_g_miss_num_map(ddp_instance_rec.last_wip_job_id);
    p4_a37 := rosetta_g_miss_num_map(ddp_instance_rec.last_pa_project_id);
    p4_a38 := rosetta_g_miss_num_map(ddp_instance_rec.last_pa_task_id);
    p4_a39 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_agreement_id);
    p4_a40 := ddp_instance_rec.install_date;
    p4_a41 := ddp_instance_rec.manually_created_flag;
    p4_a42 := ddp_instance_rec.return_by_date;
    p4_a43 := ddp_instance_rec.actual_return_date;
    p4_a44 := ddp_instance_rec.creation_complete_flag;
    p4_a45 := ddp_instance_rec.completeness_flag;
    p4_a46 := ddp_instance_rec.version_label;
    p4_a47 := ddp_instance_rec.version_label_description;
    p4_a48 := ddp_instance_rec.context;
    p4_a49 := ddp_instance_rec.attribute1;
    p4_a50 := ddp_instance_rec.attribute2;
    p4_a51 := ddp_instance_rec.attribute3;
    p4_a52 := ddp_instance_rec.attribute4;
    p4_a53 := ddp_instance_rec.attribute5;
    p4_a54 := ddp_instance_rec.attribute6;
    p4_a55 := ddp_instance_rec.attribute7;
    p4_a56 := ddp_instance_rec.attribute8;
    p4_a57 := ddp_instance_rec.attribute9;
    p4_a58 := ddp_instance_rec.attribute10;
    p4_a59 := ddp_instance_rec.attribute11;
    p4_a60 := ddp_instance_rec.attribute12;
    p4_a61 := ddp_instance_rec.attribute13;
    p4_a62 := ddp_instance_rec.attribute14;
    p4_a63 := ddp_instance_rec.attribute15;
    p4_a64 := rosetta_g_miss_num_map(ddp_instance_rec.object_version_number);
    p4_a65 := rosetta_g_miss_num_map(ddp_instance_rec.last_txn_line_detail_id);
    p4_a66 := ddp_instance_rec.install_location_type_code;
    p4_a67 := rosetta_g_miss_num_map(ddp_instance_rec.install_location_id);
    p4_a68 := ddp_instance_rec.instance_usage_code;
    p4_a69 := ddp_instance_rec.check_for_instance_expiry;
    p4_a70 := ddp_instance_rec.processed_flag;
    p4_a71 := ddp_instance_rec.call_contracts;
    p4_a72 := rosetta_g_miss_num_map(ddp_instance_rec.interface_id);
    p4_a73 := ddp_instance_rec.grp_call_contracts;
    p4_a74 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_hdr_id);
    p4_a75 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_rev_num);
    p4_a76 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_item_id);
    p4_a77 := ddp_instance_rec.config_valid_status;
    p4_a78 := ddp_instance_rec.instance_description;
    p4_a79 := ddp_instance_rec.call_batch_validation;
    p4_a80 := rosetta_g_miss_num_map(ddp_instance_rec.request_id);
    p4_a81 := rosetta_g_miss_num_map(ddp_instance_rec.program_application_id);
    p4_a82 := rosetta_g_miss_num_map(ddp_instance_rec.program_id);
    p4_a83 := ddp_instance_rec.program_update_date;
    p4_a84 := ddp_instance_rec.cascade_ownership_flag;
    p4_a85 := ddp_instance_rec.network_asset_flag;
    p4_a86 := ddp_instance_rec.maintainable_flag;
    p4_a87 := rosetta_g_miss_num_map(ddp_instance_rec.pn_location_id);
    p4_a88 := ddp_instance_rec.asset_criticality_code;
    p4_a89 := rosetta_g_miss_num_map(ddp_instance_rec.category_id);
    p4_a90 := rosetta_g_miss_num_map(ddp_instance_rec.equipment_gen_object_id);
    p4_a91 := ddp_instance_rec.instantiation_flag;
    p4_a92 := rosetta_g_miss_num_map(ddp_instance_rec.linear_location_id);
    p4_a93 := ddp_instance_rec.operational_log_flag;
    p4_a94 := rosetta_g_miss_num_map(ddp_instance_rec.checkin_status);
    p4_a95 := ddp_instance_rec.supplier_warranty_exp_date;
    p4_a96 := ddp_instance_rec.attribute16;
    p4_a97 := ddp_instance_rec.attribute17;
    p4_a98 := ddp_instance_rec.attribute18;
    p4_a99 := ddp_instance_rec.attribute19;
    p4_a100 := ddp_instance_rec.attribute20;
    p4_a101 := ddp_instance_rec.attribute21;
    p4_a102 := ddp_instance_rec.attribute22;
    p4_a103 := ddp_instance_rec.attribute23;
    p4_a104 := ddp_instance_rec.attribute24;
    p4_a105 := ddp_instance_rec.attribute25;
    p4_a106 := ddp_instance_rec.attribute26;
    p4_a107 := ddp_instance_rec.attribute27;
    p4_a108 := ddp_instance_rec.attribute28;
    p4_a109 := ddp_instance_rec.attribute29;
    p4_a110 := ddp_instance_rec.attribute30;
    p4_a111 := rosetta_g_miss_num_map(ddp_instance_rec.purchase_unit_price);
    p4_a112 := ddp_instance_rec.purchase_currency_code;
    p4_a113 := rosetta_g_miss_num_map(ddp_instance_rec.payables_unit_price);
    p4_a114 := ddp_instance_rec.payables_currency_code;
    p4_a115 := rosetta_g_miss_num_map(ddp_instance_rec.sales_unit_price);
    p4_a116 := ddp_instance_rec.sales_currency_code;
    p4_a117 := ddp_instance_rec.operational_status_code;
    p4_a118 := rosetta_g_miss_num_map(ddp_instance_rec.department_id);
    p4_a119 := ddp_instance_rec.wip_accounting_class;
    p4_a120 := rosetta_g_miss_num_map(ddp_instance_rec.area_id);
    p4_a121 := rosetta_g_miss_num_map(ddp_instance_rec.owner_party_id);
    p4_a122 := ddp_instance_rec.source_code;

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

  procedure split_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
    , p_quantity1  NUMBER
    , p_quantity2  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p13_a0 in out nocopy  NUMBER
    , p13_a1 in out nocopy  DATE
    , p13_a2 in out nocopy  DATE
    , p13_a3 in out nocopy  NUMBER
    , p13_a4 in out nocopy  NUMBER
    , p13_a5 in out nocopy  NUMBER
    , p13_a6 in out nocopy  VARCHAR2
    , p13_a7 in out nocopy  NUMBER
    , p13_a8 in out nocopy  VARCHAR2
    , p13_a9 in out nocopy  NUMBER
    , p13_a10 in out nocopy  VARCHAR2
    , p13_a11 in out nocopy  NUMBER
    , p13_a12 in out nocopy  NUMBER
    , p13_a13 in out nocopy  NUMBER
    , p13_a14 in out nocopy  NUMBER
    , p13_a15 in out nocopy  VARCHAR2
    , p13_a16 in out nocopy  NUMBER
    , p13_a17 in out nocopy  VARCHAR2
    , p13_a18 in out nocopy  VARCHAR2
    , p13_a19 in out nocopy  NUMBER
    , p13_a20 in out nocopy  VARCHAR2
    , p13_a21 in out nocopy  VARCHAR2
    , p13_a22 in out nocopy  VARCHAR2
    , p13_a23 in out nocopy  VARCHAR2
    , p13_a24 in out nocopy  VARCHAR2
    , p13_a25 in out nocopy  VARCHAR2
    , p13_a26 in out nocopy  VARCHAR2
    , p13_a27 in out nocopy  VARCHAR2
    , p13_a28 in out nocopy  VARCHAR2
    , p13_a29 in out nocopy  VARCHAR2
    , p13_a30 in out nocopy  VARCHAR2
    , p13_a31 in out nocopy  VARCHAR2
    , p13_a32 in out nocopy  VARCHAR2
    , p13_a33 in out nocopy  VARCHAR2
    , p13_a34 in out nocopy  VARCHAR2
    , p13_a35 in out nocopy  VARCHAR2
    , p13_a36 in out nocopy  NUMBER
    , p13_a37 in out nocopy  VARCHAR2
    , p13_a38 in out nocopy  DATE
    , p13_a39 in out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  VARCHAR2
    , p14_a2 out nocopy  VARCHAR2
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  VARCHAR2
    , p14_a6 out nocopy  NUMBER
    , p14_a7 out nocopy  VARCHAR2
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  VARCHAR2
    , p14_a12 out nocopy  VARCHAR2
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  NUMBER
    , p14_a15 out nocopy  VARCHAR2
    , p14_a16 out nocopy  VARCHAR2
    , p14_a17 out nocopy  VARCHAR2
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  VARCHAR2
    , p14_a20 out nocopy  DATE
    , p14_a21 out nocopy  DATE
    , p14_a22 out nocopy  VARCHAR2
    , p14_a23 out nocopy  NUMBER
    , p14_a24 out nocopy  NUMBER
    , p14_a25 out nocopy  VARCHAR2
    , p14_a26 out nocopy  NUMBER
    , p14_a27 out nocopy  NUMBER
    , p14_a28 out nocopy  NUMBER
    , p14_a29 out nocopy  NUMBER
    , p14_a30 out nocopy  NUMBER
    , p14_a31 out nocopy  NUMBER
    , p14_a32 out nocopy  NUMBER
    , p14_a33 out nocopy  NUMBER
    , p14_a34 out nocopy  NUMBER
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  NUMBER
    , p14_a37 out nocopy  NUMBER
    , p14_a38 out nocopy  NUMBER
    , p14_a39 out nocopy  NUMBER
    , p14_a40 out nocopy  DATE
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  DATE
    , p14_a43 out nocopy  DATE
    , p14_a44 out nocopy  VARCHAR2
    , p14_a45 out nocopy  VARCHAR2
    , p14_a46 out nocopy  VARCHAR2
    , p14_a47 out nocopy  VARCHAR2
    , p14_a48 out nocopy  VARCHAR2
    , p14_a49 out nocopy  VARCHAR2
    , p14_a50 out nocopy  VARCHAR2
    , p14_a51 out nocopy  VARCHAR2
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  VARCHAR2
    , p14_a54 out nocopy  VARCHAR2
    , p14_a55 out nocopy  VARCHAR2
    , p14_a56 out nocopy  VARCHAR2
    , p14_a57 out nocopy  VARCHAR2
    , p14_a58 out nocopy  VARCHAR2
    , p14_a59 out nocopy  VARCHAR2
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  VARCHAR2
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  NUMBER
    , p14_a65 out nocopy  NUMBER
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  NUMBER
    , p14_a68 out nocopy  VARCHAR2
    , p14_a69 out nocopy  VARCHAR2
    , p14_a70 out nocopy  VARCHAR2
    , p14_a71 out nocopy  VARCHAR2
    , p14_a72 out nocopy  NUMBER
    , p14_a73 out nocopy  VARCHAR2
    , p14_a74 out nocopy  NUMBER
    , p14_a75 out nocopy  NUMBER
    , p14_a76 out nocopy  NUMBER
    , p14_a77 out nocopy  VARCHAR2
    , p14_a78 out nocopy  VARCHAR2
    , p14_a79 out nocopy  VARCHAR2
    , p14_a80 out nocopy  NUMBER
    , p14_a81 out nocopy  NUMBER
    , p14_a82 out nocopy  NUMBER
    , p14_a83 out nocopy  DATE
    , p14_a84 out nocopy  VARCHAR2
    , p14_a85 out nocopy  VARCHAR2
    , p14_a86 out nocopy  VARCHAR2
    , p14_a87 out nocopy  NUMBER
    , p14_a88 out nocopy  VARCHAR2
    , p14_a89 out nocopy  NUMBER
    , p14_a90 out nocopy  NUMBER
    , p14_a91 out nocopy  VARCHAR2
    , p14_a92 out nocopy  NUMBER
    , p14_a93 out nocopy  VARCHAR2
    , p14_a94 out nocopy  NUMBER
    , p14_a95 out nocopy  DATE
    , p14_a96 out nocopy  VARCHAR2
    , p14_a97 out nocopy  VARCHAR2
    , p14_a98 out nocopy  VARCHAR2
    , p14_a99 out nocopy  VARCHAR2
    , p14_a100 out nocopy  VARCHAR2
    , p14_a101 out nocopy  VARCHAR2
    , p14_a102 out nocopy  VARCHAR2
    , p14_a103 out nocopy  VARCHAR2
    , p14_a104 out nocopy  VARCHAR2
    , p14_a105 out nocopy  VARCHAR2
    , p14_a106 out nocopy  VARCHAR2
    , p14_a107 out nocopy  VARCHAR2
    , p14_a108 out nocopy  VARCHAR2
    , p14_a109 out nocopy  VARCHAR2
    , p14_a110 out nocopy  VARCHAR2
    , p14_a111 out nocopy  NUMBER
    , p14_a112 out nocopy  VARCHAR2
    , p14_a113 out nocopy  NUMBER
    , p14_a114 out nocopy  VARCHAR2
    , p14_a115 out nocopy  NUMBER
    , p14_a116 out nocopy  VARCHAR2
    , p14_a117 out nocopy  VARCHAR2
    , p14_a118 out nocopy  NUMBER
    , p14_a119 out nocopy  VARCHAR2
    , p14_a120 out nocopy  NUMBER
    , p14_a121 out nocopy  NUMBER
    , p14_a122 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_source_instance_rec csi_datastructures_pub.instance_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_new_instance_rec csi_datastructures_pub.instance_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_source_instance_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_source_instance_rec.instance_number := p4_a1;
    ddp_source_instance_rec.external_reference := p4_a2;
    ddp_source_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a3);
    ddp_source_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p4_a4);
    ddp_source_instance_rec.inventory_revision := p4_a5;
    ddp_source_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a6);
    ddp_source_instance_rec.serial_number := p4_a7;
    ddp_source_instance_rec.mfg_serial_number_flag := p4_a8;
    ddp_source_instance_rec.lot_number := p4_a9;
    ddp_source_instance_rec.quantity := rosetta_g_miss_num_map(p4_a10);
    ddp_source_instance_rec.unit_of_measure := p4_a11;
    ddp_source_instance_rec.accounting_class_code := p4_a12;
    ddp_source_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_source_instance_rec.instance_status_id := rosetta_g_miss_num_map(p4_a14);
    ddp_source_instance_rec.customer_view_flag := p4_a15;
    ddp_source_instance_rec.merchant_view_flag := p4_a16;
    ddp_source_instance_rec.sellable_flag := p4_a17;
    ddp_source_instance_rec.system_id := rosetta_g_miss_num_map(p4_a18);
    ddp_source_instance_rec.instance_type_code := p4_a19;
    ddp_source_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_source_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_source_instance_rec.location_type_code := p4_a22;
    ddp_source_instance_rec.location_id := rosetta_g_miss_num_map(p4_a23);
    ddp_source_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a24);
    ddp_source_instance_rec.inv_subinventory_name := p4_a25;
    ddp_source_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a26);
    ddp_source_instance_rec.pa_project_id := rosetta_g_miss_num_map(p4_a27);
    ddp_source_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a28);
    ddp_source_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a29);
    ddp_source_instance_rec.wip_job_id := rosetta_g_miss_num_map(p4_a30);
    ddp_source_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a31);
    ddp_source_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a32);
    ddp_source_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a33);
    ddp_source_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a34);
    ddp_source_instance_rec.last_oe_po_number := p4_a35;
    ddp_source_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a36);
    ddp_source_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a37);
    ddp_source_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a38);
    ddp_source_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a39);
    ddp_source_instance_rec.install_date := rosetta_g_miss_date_in_map(p4_a40);
    ddp_source_instance_rec.manually_created_flag := p4_a41;
    ddp_source_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a42);
    ddp_source_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a43);
    ddp_source_instance_rec.creation_complete_flag := p4_a44;
    ddp_source_instance_rec.completeness_flag := p4_a45;
    ddp_source_instance_rec.version_label := p4_a46;
    ddp_source_instance_rec.version_label_description := p4_a47;
    ddp_source_instance_rec.context := p4_a48;
    ddp_source_instance_rec.attribute1 := p4_a49;
    ddp_source_instance_rec.attribute2 := p4_a50;
    ddp_source_instance_rec.attribute3 := p4_a51;
    ddp_source_instance_rec.attribute4 := p4_a52;
    ddp_source_instance_rec.attribute5 := p4_a53;
    ddp_source_instance_rec.attribute6 := p4_a54;
    ddp_source_instance_rec.attribute7 := p4_a55;
    ddp_source_instance_rec.attribute8 := p4_a56;
    ddp_source_instance_rec.attribute9 := p4_a57;
    ddp_source_instance_rec.attribute10 := p4_a58;
    ddp_source_instance_rec.attribute11 := p4_a59;
    ddp_source_instance_rec.attribute12 := p4_a60;
    ddp_source_instance_rec.attribute13 := p4_a61;
    ddp_source_instance_rec.attribute14 := p4_a62;
    ddp_source_instance_rec.attribute15 := p4_a63;
    ddp_source_instance_rec.object_version_number := rosetta_g_miss_num_map(p4_a64);
    ddp_source_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p4_a65);
    ddp_source_instance_rec.install_location_type_code := p4_a66;
    ddp_source_instance_rec.install_location_id := rosetta_g_miss_num_map(p4_a67);
    ddp_source_instance_rec.instance_usage_code := p4_a68;
    ddp_source_instance_rec.check_for_instance_expiry := p4_a69;
    ddp_source_instance_rec.processed_flag := p4_a70;
    ddp_source_instance_rec.call_contracts := p4_a71;
    ddp_source_instance_rec.interface_id := rosetta_g_miss_num_map(p4_a72);
    ddp_source_instance_rec.grp_call_contracts := p4_a73;
    ddp_source_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a74);
    ddp_source_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a75);
    ddp_source_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a76);
    ddp_source_instance_rec.config_valid_status := p4_a77;
    ddp_source_instance_rec.instance_description := p4_a78;
    ddp_source_instance_rec.call_batch_validation := p4_a79;
    ddp_source_instance_rec.request_id := rosetta_g_miss_num_map(p4_a80);
    ddp_source_instance_rec.program_application_id := rosetta_g_miss_num_map(p4_a81);
    ddp_source_instance_rec.program_id := rosetta_g_miss_num_map(p4_a82);
    ddp_source_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a83);
    ddp_source_instance_rec.cascade_ownership_flag := p4_a84;
    ddp_source_instance_rec.network_asset_flag := p4_a85;
    ddp_source_instance_rec.maintainable_flag := p4_a86;
    ddp_source_instance_rec.pn_location_id := rosetta_g_miss_num_map(p4_a87);
    ddp_source_instance_rec.asset_criticality_code := p4_a88;
    ddp_source_instance_rec.category_id := rosetta_g_miss_num_map(p4_a89);
    ddp_source_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p4_a90);
    ddp_source_instance_rec.instantiation_flag := p4_a91;
    ddp_source_instance_rec.linear_location_id := rosetta_g_miss_num_map(p4_a92);
    ddp_source_instance_rec.operational_log_flag := p4_a93;
    ddp_source_instance_rec.checkin_status := rosetta_g_miss_num_map(p4_a94);
    ddp_source_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p4_a95);
    ddp_source_instance_rec.attribute16 := p4_a96;
    ddp_source_instance_rec.attribute17 := p4_a97;
    ddp_source_instance_rec.attribute18 := p4_a98;
    ddp_source_instance_rec.attribute19 := p4_a99;
    ddp_source_instance_rec.attribute20 := p4_a100;
    ddp_source_instance_rec.attribute21 := p4_a101;
    ddp_source_instance_rec.attribute22 := p4_a102;
    ddp_source_instance_rec.attribute23 := p4_a103;
    ddp_source_instance_rec.attribute24 := p4_a104;
    ddp_source_instance_rec.attribute25 := p4_a105;
    ddp_source_instance_rec.attribute26 := p4_a106;
    ddp_source_instance_rec.attribute27 := p4_a107;
    ddp_source_instance_rec.attribute28 := p4_a108;
    ddp_source_instance_rec.attribute29 := p4_a109;
    ddp_source_instance_rec.attribute30 := p4_a110;
    ddp_source_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p4_a111);
    ddp_source_instance_rec.purchase_currency_code := p4_a112;
    ddp_source_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p4_a113);
    ddp_source_instance_rec.payables_currency_code := p4_a114;
    ddp_source_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p4_a115);
    ddp_source_instance_rec.sales_currency_code := p4_a116;
    ddp_source_instance_rec.operational_status_code := p4_a117;
    ddp_source_instance_rec.department_id := rosetta_g_miss_num_map(p4_a118);
    ddp_source_instance_rec.wip_accounting_class := p4_a119;
    ddp_source_instance_rec.area_id := rosetta_g_miss_num_map(p4_a120);
    ddp_source_instance_rec.owner_party_id := rosetta_g_miss_num_map(p4_a121);
    ddp_source_instance_rec.source_code := p4_a122;









    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p13_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p13_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p13_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p13_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p13_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p13_a5);
    ddp_txn_rec.source_group_ref := p13_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p13_a7);
    ddp_txn_rec.source_header_ref := p13_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p13_a9);
    ddp_txn_rec.source_line_ref := p13_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p13_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p13_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p13_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p13_a14);
    ddp_txn_rec.transaction_uom_code := p13_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p13_a16);
    ddp_txn_rec.transaction_status_code := p13_a17;
    ddp_txn_rec.transaction_action_code := p13_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p13_a19);
    ddp_txn_rec.context := p13_a20;
    ddp_txn_rec.attribute1 := p13_a21;
    ddp_txn_rec.attribute2 := p13_a22;
    ddp_txn_rec.attribute3 := p13_a23;
    ddp_txn_rec.attribute4 := p13_a24;
    ddp_txn_rec.attribute5 := p13_a25;
    ddp_txn_rec.attribute6 := p13_a26;
    ddp_txn_rec.attribute7 := p13_a27;
    ddp_txn_rec.attribute8 := p13_a28;
    ddp_txn_rec.attribute9 := p13_a29;
    ddp_txn_rec.attribute10 := p13_a30;
    ddp_txn_rec.attribute11 := p13_a31;
    ddp_txn_rec.attribute12 := p13_a32;
    ddp_txn_rec.attribute13 := p13_a33;
    ddp_txn_rec.attribute14 := p13_a34;
    ddp_txn_rec.attribute15 := p13_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p13_a36);
    ddp_txn_rec.split_reason_code := p13_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p13_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p13_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.split_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_source_instance_rec,
      p_quantity1,
      p_quantity2,
      p_copy_ext_attribs,
      p_copy_org_assignments,
      p_copy_parties,
      p_copy_accounts,
      p_copy_asset_assignments,
      p_copy_pricing_attribs,
      ddp_txn_rec,
      ddx_new_instance_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_id);
    p4_a1 := ddp_source_instance_rec.instance_number;
    p4_a2 := ddp_source_instance_rec.external_reference;
    p4_a3 := rosetta_g_miss_num_map(ddp_source_instance_rec.inventory_item_id);
    p4_a4 := rosetta_g_miss_num_map(ddp_source_instance_rec.vld_organization_id);
    p4_a5 := ddp_source_instance_rec.inventory_revision;
    p4_a6 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_master_organization_id);
    p4_a7 := ddp_source_instance_rec.serial_number;
    p4_a8 := ddp_source_instance_rec.mfg_serial_number_flag;
    p4_a9 := ddp_source_instance_rec.lot_number;
    p4_a10 := rosetta_g_miss_num_map(ddp_source_instance_rec.quantity);
    p4_a11 := ddp_source_instance_rec.unit_of_measure;
    p4_a12 := ddp_source_instance_rec.accounting_class_code;
    p4_a13 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_condition_id);
    p4_a14 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_status_id);
    p4_a15 := ddp_source_instance_rec.customer_view_flag;
    p4_a16 := ddp_source_instance_rec.merchant_view_flag;
    p4_a17 := ddp_source_instance_rec.sellable_flag;
    p4_a18 := rosetta_g_miss_num_map(ddp_source_instance_rec.system_id);
    p4_a19 := ddp_source_instance_rec.instance_type_code;
    p4_a20 := ddp_source_instance_rec.active_start_date;
    p4_a21 := ddp_source_instance_rec.active_end_date;
    p4_a22 := ddp_source_instance_rec.location_type_code;
    p4_a23 := rosetta_g_miss_num_map(ddp_source_instance_rec.location_id);
    p4_a24 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_organization_id);
    p4_a25 := ddp_source_instance_rec.inv_subinventory_name;
    p4_a26 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_locator_id);
    p4_a27 := rosetta_g_miss_num_map(ddp_source_instance_rec.pa_project_id);
    p4_a28 := rosetta_g_miss_num_map(ddp_source_instance_rec.pa_project_task_id);
    p4_a29 := rosetta_g_miss_num_map(ddp_source_instance_rec.in_transit_order_line_id);
    p4_a30 := rosetta_g_miss_num_map(ddp_source_instance_rec.wip_job_id);
    p4_a31 := rosetta_g_miss_num_map(ddp_source_instance_rec.po_order_line_id);
    p4_a32 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_order_line_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_rma_line_id);
    p4_a34 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_po_po_line_id);
    p4_a35 := ddp_source_instance_rec.last_oe_po_number;
    p4_a36 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_wip_job_id);
    p4_a37 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_pa_project_id);
    p4_a38 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_pa_task_id);
    p4_a39 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_agreement_id);
    p4_a40 := ddp_source_instance_rec.install_date;
    p4_a41 := ddp_source_instance_rec.manually_created_flag;
    p4_a42 := ddp_source_instance_rec.return_by_date;
    p4_a43 := ddp_source_instance_rec.actual_return_date;
    p4_a44 := ddp_source_instance_rec.creation_complete_flag;
    p4_a45 := ddp_source_instance_rec.completeness_flag;
    p4_a46 := ddp_source_instance_rec.version_label;
    p4_a47 := ddp_source_instance_rec.version_label_description;
    p4_a48 := ddp_source_instance_rec.context;
    p4_a49 := ddp_source_instance_rec.attribute1;
    p4_a50 := ddp_source_instance_rec.attribute2;
    p4_a51 := ddp_source_instance_rec.attribute3;
    p4_a52 := ddp_source_instance_rec.attribute4;
    p4_a53 := ddp_source_instance_rec.attribute5;
    p4_a54 := ddp_source_instance_rec.attribute6;
    p4_a55 := ddp_source_instance_rec.attribute7;
    p4_a56 := ddp_source_instance_rec.attribute8;
    p4_a57 := ddp_source_instance_rec.attribute9;
    p4_a58 := ddp_source_instance_rec.attribute10;
    p4_a59 := ddp_source_instance_rec.attribute11;
    p4_a60 := ddp_source_instance_rec.attribute12;
    p4_a61 := ddp_source_instance_rec.attribute13;
    p4_a62 := ddp_source_instance_rec.attribute14;
    p4_a63 := ddp_source_instance_rec.attribute15;
    p4_a64 := rosetta_g_miss_num_map(ddp_source_instance_rec.object_version_number);
    p4_a65 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_txn_line_detail_id);
    p4_a66 := ddp_source_instance_rec.install_location_type_code;
    p4_a67 := rosetta_g_miss_num_map(ddp_source_instance_rec.install_location_id);
    p4_a68 := ddp_source_instance_rec.instance_usage_code;
    p4_a69 := ddp_source_instance_rec.check_for_instance_expiry;
    p4_a70 := ddp_source_instance_rec.processed_flag;
    p4_a71 := ddp_source_instance_rec.call_contracts;
    p4_a72 := rosetta_g_miss_num_map(ddp_source_instance_rec.interface_id);
    p4_a73 := ddp_source_instance_rec.grp_call_contracts;
    p4_a74 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_hdr_id);
    p4_a75 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_rev_num);
    p4_a76 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_item_id);
    p4_a77 := ddp_source_instance_rec.config_valid_status;
    p4_a78 := ddp_source_instance_rec.instance_description;
    p4_a79 := ddp_source_instance_rec.call_batch_validation;
    p4_a80 := rosetta_g_miss_num_map(ddp_source_instance_rec.request_id);
    p4_a81 := rosetta_g_miss_num_map(ddp_source_instance_rec.program_application_id);
    p4_a82 := rosetta_g_miss_num_map(ddp_source_instance_rec.program_id);
    p4_a83 := ddp_source_instance_rec.program_update_date;
    p4_a84 := ddp_source_instance_rec.cascade_ownership_flag;
    p4_a85 := ddp_source_instance_rec.network_asset_flag;
    p4_a86 := ddp_source_instance_rec.maintainable_flag;
    p4_a87 := rosetta_g_miss_num_map(ddp_source_instance_rec.pn_location_id);
    p4_a88 := ddp_source_instance_rec.asset_criticality_code;
    p4_a89 := rosetta_g_miss_num_map(ddp_source_instance_rec.category_id);
    p4_a90 := rosetta_g_miss_num_map(ddp_source_instance_rec.equipment_gen_object_id);
    p4_a91 := ddp_source_instance_rec.instantiation_flag;
    p4_a92 := rosetta_g_miss_num_map(ddp_source_instance_rec.linear_location_id);
    p4_a93 := ddp_source_instance_rec.operational_log_flag;
    p4_a94 := rosetta_g_miss_num_map(ddp_source_instance_rec.checkin_status);
    p4_a95 := ddp_source_instance_rec.supplier_warranty_exp_date;
    p4_a96 := ddp_source_instance_rec.attribute16;
    p4_a97 := ddp_source_instance_rec.attribute17;
    p4_a98 := ddp_source_instance_rec.attribute18;
    p4_a99 := ddp_source_instance_rec.attribute19;
    p4_a100 := ddp_source_instance_rec.attribute20;
    p4_a101 := ddp_source_instance_rec.attribute21;
    p4_a102 := ddp_source_instance_rec.attribute22;
    p4_a103 := ddp_source_instance_rec.attribute23;
    p4_a104 := ddp_source_instance_rec.attribute24;
    p4_a105 := ddp_source_instance_rec.attribute25;
    p4_a106 := ddp_source_instance_rec.attribute26;
    p4_a107 := ddp_source_instance_rec.attribute27;
    p4_a108 := ddp_source_instance_rec.attribute28;
    p4_a109 := ddp_source_instance_rec.attribute29;
    p4_a110 := ddp_source_instance_rec.attribute30;
    p4_a111 := rosetta_g_miss_num_map(ddp_source_instance_rec.purchase_unit_price);
    p4_a112 := ddp_source_instance_rec.purchase_currency_code;
    p4_a113 := rosetta_g_miss_num_map(ddp_source_instance_rec.payables_unit_price);
    p4_a114 := ddp_source_instance_rec.payables_currency_code;
    p4_a115 := rosetta_g_miss_num_map(ddp_source_instance_rec.sales_unit_price);
    p4_a116 := ddp_source_instance_rec.sales_currency_code;
    p4_a117 := ddp_source_instance_rec.operational_status_code;
    p4_a118 := rosetta_g_miss_num_map(ddp_source_instance_rec.department_id);
    p4_a119 := ddp_source_instance_rec.wip_accounting_class;
    p4_a120 := rosetta_g_miss_num_map(ddp_source_instance_rec.area_id);
    p4_a121 := rosetta_g_miss_num_map(ddp_source_instance_rec.owner_party_id);
    p4_a122 := ddp_source_instance_rec.source_code;









    p13_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p13_a1 := ddp_txn_rec.transaction_date;
    p13_a2 := ddp_txn_rec.source_transaction_date;
    p13_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p13_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p13_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p13_a6 := ddp_txn_rec.source_group_ref;
    p13_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p13_a8 := ddp_txn_rec.source_header_ref;
    p13_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p13_a10 := ddp_txn_rec.source_line_ref;
    p13_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p13_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p13_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p13_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p13_a15 := ddp_txn_rec.transaction_uom_code;
    p13_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p13_a17 := ddp_txn_rec.transaction_status_code;
    p13_a18 := ddp_txn_rec.transaction_action_code;
    p13_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p13_a20 := ddp_txn_rec.context;
    p13_a21 := ddp_txn_rec.attribute1;
    p13_a22 := ddp_txn_rec.attribute2;
    p13_a23 := ddp_txn_rec.attribute3;
    p13_a24 := ddp_txn_rec.attribute4;
    p13_a25 := ddp_txn_rec.attribute5;
    p13_a26 := ddp_txn_rec.attribute6;
    p13_a27 := ddp_txn_rec.attribute7;
    p13_a28 := ddp_txn_rec.attribute8;
    p13_a29 := ddp_txn_rec.attribute9;
    p13_a30 := ddp_txn_rec.attribute10;
    p13_a31 := ddp_txn_rec.attribute11;
    p13_a32 := ddp_txn_rec.attribute12;
    p13_a33 := ddp_txn_rec.attribute13;
    p13_a34 := ddp_txn_rec.attribute14;
    p13_a35 := ddp_txn_rec.attribute15;
    p13_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p13_a37 := ddp_txn_rec.split_reason_code;
    p13_a38 := ddp_txn_rec.src_txn_creation_date;
    p13_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);

    p14_a0 := rosetta_g_miss_num_map(ddx_new_instance_rec.instance_id);
    p14_a1 := ddx_new_instance_rec.instance_number;
    p14_a2 := ddx_new_instance_rec.external_reference;
    p14_a3 := rosetta_g_miss_num_map(ddx_new_instance_rec.inventory_item_id);
    p14_a4 := rosetta_g_miss_num_map(ddx_new_instance_rec.vld_organization_id);
    p14_a5 := ddx_new_instance_rec.inventory_revision;
    p14_a6 := rosetta_g_miss_num_map(ddx_new_instance_rec.inv_master_organization_id);
    p14_a7 := ddx_new_instance_rec.serial_number;
    p14_a8 := ddx_new_instance_rec.mfg_serial_number_flag;
    p14_a9 := ddx_new_instance_rec.lot_number;
    p14_a10 := rosetta_g_miss_num_map(ddx_new_instance_rec.quantity);
    p14_a11 := ddx_new_instance_rec.unit_of_measure;
    p14_a12 := ddx_new_instance_rec.accounting_class_code;
    p14_a13 := rosetta_g_miss_num_map(ddx_new_instance_rec.instance_condition_id);
    p14_a14 := rosetta_g_miss_num_map(ddx_new_instance_rec.instance_status_id);
    p14_a15 := ddx_new_instance_rec.customer_view_flag;
    p14_a16 := ddx_new_instance_rec.merchant_view_flag;
    p14_a17 := ddx_new_instance_rec.sellable_flag;
    p14_a18 := rosetta_g_miss_num_map(ddx_new_instance_rec.system_id);
    p14_a19 := ddx_new_instance_rec.instance_type_code;
    p14_a20 := ddx_new_instance_rec.active_start_date;
    p14_a21 := ddx_new_instance_rec.active_end_date;
    p14_a22 := ddx_new_instance_rec.location_type_code;
    p14_a23 := rosetta_g_miss_num_map(ddx_new_instance_rec.location_id);
    p14_a24 := rosetta_g_miss_num_map(ddx_new_instance_rec.inv_organization_id);
    p14_a25 := ddx_new_instance_rec.inv_subinventory_name;
    p14_a26 := rosetta_g_miss_num_map(ddx_new_instance_rec.inv_locator_id);
    p14_a27 := rosetta_g_miss_num_map(ddx_new_instance_rec.pa_project_id);
    p14_a28 := rosetta_g_miss_num_map(ddx_new_instance_rec.pa_project_task_id);
    p14_a29 := rosetta_g_miss_num_map(ddx_new_instance_rec.in_transit_order_line_id);
    p14_a30 := rosetta_g_miss_num_map(ddx_new_instance_rec.wip_job_id);
    p14_a31 := rosetta_g_miss_num_map(ddx_new_instance_rec.po_order_line_id);
    p14_a32 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_oe_order_line_id);
    p14_a33 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_oe_rma_line_id);
    p14_a34 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_po_po_line_id);
    p14_a35 := ddx_new_instance_rec.last_oe_po_number;
    p14_a36 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_wip_job_id);
    p14_a37 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_pa_project_id);
    p14_a38 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_pa_task_id);
    p14_a39 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_oe_agreement_id);
    p14_a40 := ddx_new_instance_rec.install_date;
    p14_a41 := ddx_new_instance_rec.manually_created_flag;
    p14_a42 := ddx_new_instance_rec.return_by_date;
    p14_a43 := ddx_new_instance_rec.actual_return_date;
    p14_a44 := ddx_new_instance_rec.creation_complete_flag;
    p14_a45 := ddx_new_instance_rec.completeness_flag;
    p14_a46 := ddx_new_instance_rec.version_label;
    p14_a47 := ddx_new_instance_rec.version_label_description;
    p14_a48 := ddx_new_instance_rec.context;
    p14_a49 := ddx_new_instance_rec.attribute1;
    p14_a50 := ddx_new_instance_rec.attribute2;
    p14_a51 := ddx_new_instance_rec.attribute3;
    p14_a52 := ddx_new_instance_rec.attribute4;
    p14_a53 := ddx_new_instance_rec.attribute5;
    p14_a54 := ddx_new_instance_rec.attribute6;
    p14_a55 := ddx_new_instance_rec.attribute7;
    p14_a56 := ddx_new_instance_rec.attribute8;
    p14_a57 := ddx_new_instance_rec.attribute9;
    p14_a58 := ddx_new_instance_rec.attribute10;
    p14_a59 := ddx_new_instance_rec.attribute11;
    p14_a60 := ddx_new_instance_rec.attribute12;
    p14_a61 := ddx_new_instance_rec.attribute13;
    p14_a62 := ddx_new_instance_rec.attribute14;
    p14_a63 := ddx_new_instance_rec.attribute15;
    p14_a64 := rosetta_g_miss_num_map(ddx_new_instance_rec.object_version_number);
    p14_a65 := rosetta_g_miss_num_map(ddx_new_instance_rec.last_txn_line_detail_id);
    p14_a66 := ddx_new_instance_rec.install_location_type_code;
    p14_a67 := rosetta_g_miss_num_map(ddx_new_instance_rec.install_location_id);
    p14_a68 := ddx_new_instance_rec.instance_usage_code;
    p14_a69 := ddx_new_instance_rec.check_for_instance_expiry;
    p14_a70 := ddx_new_instance_rec.processed_flag;
    p14_a71 := ddx_new_instance_rec.call_contracts;
    p14_a72 := rosetta_g_miss_num_map(ddx_new_instance_rec.interface_id);
    p14_a73 := ddx_new_instance_rec.grp_call_contracts;
    p14_a74 := rosetta_g_miss_num_map(ddx_new_instance_rec.config_inst_hdr_id);
    p14_a75 := rosetta_g_miss_num_map(ddx_new_instance_rec.config_inst_rev_num);
    p14_a76 := rosetta_g_miss_num_map(ddx_new_instance_rec.config_inst_item_id);
    p14_a77 := ddx_new_instance_rec.config_valid_status;
    p14_a78 := ddx_new_instance_rec.instance_description;
    p14_a79 := ddx_new_instance_rec.call_batch_validation;
    p14_a80 := rosetta_g_miss_num_map(ddx_new_instance_rec.request_id);
    p14_a81 := rosetta_g_miss_num_map(ddx_new_instance_rec.program_application_id);
    p14_a82 := rosetta_g_miss_num_map(ddx_new_instance_rec.program_id);
    p14_a83 := ddx_new_instance_rec.program_update_date;
    p14_a84 := ddx_new_instance_rec.cascade_ownership_flag;
    p14_a85 := ddx_new_instance_rec.network_asset_flag;
    p14_a86 := ddx_new_instance_rec.maintainable_flag;
    p14_a87 := rosetta_g_miss_num_map(ddx_new_instance_rec.pn_location_id);
    p14_a88 := ddx_new_instance_rec.asset_criticality_code;
    p14_a89 := rosetta_g_miss_num_map(ddx_new_instance_rec.category_id);
    p14_a90 := rosetta_g_miss_num_map(ddx_new_instance_rec.equipment_gen_object_id);
    p14_a91 := ddx_new_instance_rec.instantiation_flag;
    p14_a92 := rosetta_g_miss_num_map(ddx_new_instance_rec.linear_location_id);
    p14_a93 := ddx_new_instance_rec.operational_log_flag;
    p14_a94 := rosetta_g_miss_num_map(ddx_new_instance_rec.checkin_status);
    p14_a95 := ddx_new_instance_rec.supplier_warranty_exp_date;
    p14_a96 := ddx_new_instance_rec.attribute16;
    p14_a97 := ddx_new_instance_rec.attribute17;
    p14_a98 := ddx_new_instance_rec.attribute18;
    p14_a99 := ddx_new_instance_rec.attribute19;
    p14_a100 := ddx_new_instance_rec.attribute20;
    p14_a101 := ddx_new_instance_rec.attribute21;
    p14_a102 := ddx_new_instance_rec.attribute22;
    p14_a103 := ddx_new_instance_rec.attribute23;
    p14_a104 := ddx_new_instance_rec.attribute24;
    p14_a105 := ddx_new_instance_rec.attribute25;
    p14_a106 := ddx_new_instance_rec.attribute26;
    p14_a107 := ddx_new_instance_rec.attribute27;
    p14_a108 := ddx_new_instance_rec.attribute28;
    p14_a109 := ddx_new_instance_rec.attribute29;
    p14_a110 := ddx_new_instance_rec.attribute30;
    p14_a111 := rosetta_g_miss_num_map(ddx_new_instance_rec.purchase_unit_price);
    p14_a112 := ddx_new_instance_rec.purchase_currency_code;
    p14_a113 := rosetta_g_miss_num_map(ddx_new_instance_rec.payables_unit_price);
    p14_a114 := ddx_new_instance_rec.payables_currency_code;
    p14_a115 := rosetta_g_miss_num_map(ddx_new_instance_rec.sales_unit_price);
    p14_a116 := ddx_new_instance_rec.sales_currency_code;
    p14_a117 := ddx_new_instance_rec.operational_status_code;
    p14_a118 := rosetta_g_miss_num_map(ddx_new_instance_rec.department_id);
    p14_a119 := ddx_new_instance_rec.wip_accounting_class;
    p14_a120 := rosetta_g_miss_num_map(ddx_new_instance_rec.area_id);
    p14_a121 := rosetta_g_miss_num_map(ddx_new_instance_rec.owner_party_id);
    p14_a122 := ddx_new_instance_rec.source_code;



  end;

  procedure split_item_instance_lines(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  DATE
    , p11_a2 in out nocopy  DATE
    , p11_a3 in out nocopy  NUMBER
    , p11_a4 in out nocopy  NUMBER
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  NUMBER
    , p11_a8 in out nocopy  VARCHAR2
    , p11_a9 in out nocopy  NUMBER
    , p11_a10 in out nocopy  VARCHAR2
    , p11_a11 in out nocopy  NUMBER
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  NUMBER
    , p11_a14 in out nocopy  NUMBER
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  NUMBER
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  NUMBER
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , p11_a29 in out nocopy  VARCHAR2
    , p11_a30 in out nocopy  VARCHAR2
    , p11_a31 in out nocopy  VARCHAR2
    , p11_a32 in out nocopy  VARCHAR2
    , p11_a33 in out nocopy  VARCHAR2
    , p11_a34 in out nocopy  VARCHAR2
    , p11_a35 in out nocopy  VARCHAR2
    , p11_a36 in out nocopy  NUMBER
    , p11_a37 in out nocopy  VARCHAR2
    , p11_a38 in out nocopy  DATE
    , p11_a39 in out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_NUMBER_TABLE
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_NUMBER_TABLE
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a20 out nocopy JTF_DATE_TABLE
    , p12_a21 out nocopy JTF_DATE_TABLE
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a23 out nocopy JTF_NUMBER_TABLE
    , p12_a24 out nocopy JTF_NUMBER_TABLE
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a26 out nocopy JTF_NUMBER_TABLE
    , p12_a27 out nocopy JTF_NUMBER_TABLE
    , p12_a28 out nocopy JTF_NUMBER_TABLE
    , p12_a29 out nocopy JTF_NUMBER_TABLE
    , p12_a30 out nocopy JTF_NUMBER_TABLE
    , p12_a31 out nocopy JTF_NUMBER_TABLE
    , p12_a32 out nocopy JTF_NUMBER_TABLE
    , p12_a33 out nocopy JTF_NUMBER_TABLE
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_NUMBER_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_NUMBER_TABLE
    , p12_a40 out nocopy JTF_DATE_TABLE
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a42 out nocopy JTF_DATE_TABLE
    , p12_a43 out nocopy JTF_DATE_TABLE
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a64 out nocopy JTF_NUMBER_TABLE
    , p12_a65 out nocopy JTF_NUMBER_TABLE
    , p12_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a67 out nocopy JTF_NUMBER_TABLE
    , p12_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a72 out nocopy JTF_NUMBER_TABLE
    , p12_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a74 out nocopy JTF_NUMBER_TABLE
    , p12_a75 out nocopy JTF_NUMBER_TABLE
    , p12_a76 out nocopy JTF_NUMBER_TABLE
    , p12_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a80 out nocopy JTF_NUMBER_TABLE
    , p12_a81 out nocopy JTF_NUMBER_TABLE
    , p12_a82 out nocopy JTF_NUMBER_TABLE
    , p12_a83 out nocopy JTF_DATE_TABLE
    , p12_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a87 out nocopy JTF_NUMBER_TABLE
    , p12_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a89 out nocopy JTF_NUMBER_TABLE
    , p12_a90 out nocopy JTF_NUMBER_TABLE
    , p12_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a92 out nocopy JTF_NUMBER_TABLE
    , p12_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a94 out nocopy JTF_NUMBER_TABLE
    , p12_a95 out nocopy JTF_DATE_TABLE
    , p12_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a111 out nocopy JTF_NUMBER_TABLE
    , p12_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a113 out nocopy JTF_NUMBER_TABLE
    , p12_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a115 out nocopy JTF_NUMBER_TABLE
    , p12_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a118 out nocopy JTF_NUMBER_TABLE
    , p12_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a120 out nocopy JTF_NUMBER_TABLE
    , p12_a121 out nocopy JTF_NUMBER_TABLE
    , p12_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_source_instance_rec csi_datastructures_pub.instance_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_new_instance_tbl csi_datastructures_pub.instance_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_source_instance_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_source_instance_rec.instance_number := p4_a1;
    ddp_source_instance_rec.external_reference := p4_a2;
    ddp_source_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a3);
    ddp_source_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p4_a4);
    ddp_source_instance_rec.inventory_revision := p4_a5;
    ddp_source_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a6);
    ddp_source_instance_rec.serial_number := p4_a7;
    ddp_source_instance_rec.mfg_serial_number_flag := p4_a8;
    ddp_source_instance_rec.lot_number := p4_a9;
    ddp_source_instance_rec.quantity := rosetta_g_miss_num_map(p4_a10);
    ddp_source_instance_rec.unit_of_measure := p4_a11;
    ddp_source_instance_rec.accounting_class_code := p4_a12;
    ddp_source_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_source_instance_rec.instance_status_id := rosetta_g_miss_num_map(p4_a14);
    ddp_source_instance_rec.customer_view_flag := p4_a15;
    ddp_source_instance_rec.merchant_view_flag := p4_a16;
    ddp_source_instance_rec.sellable_flag := p4_a17;
    ddp_source_instance_rec.system_id := rosetta_g_miss_num_map(p4_a18);
    ddp_source_instance_rec.instance_type_code := p4_a19;
    ddp_source_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_source_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_source_instance_rec.location_type_code := p4_a22;
    ddp_source_instance_rec.location_id := rosetta_g_miss_num_map(p4_a23);
    ddp_source_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a24);
    ddp_source_instance_rec.inv_subinventory_name := p4_a25;
    ddp_source_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a26);
    ddp_source_instance_rec.pa_project_id := rosetta_g_miss_num_map(p4_a27);
    ddp_source_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a28);
    ddp_source_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a29);
    ddp_source_instance_rec.wip_job_id := rosetta_g_miss_num_map(p4_a30);
    ddp_source_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a31);
    ddp_source_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a32);
    ddp_source_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a33);
    ddp_source_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a34);
    ddp_source_instance_rec.last_oe_po_number := p4_a35;
    ddp_source_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a36);
    ddp_source_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a37);
    ddp_source_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a38);
    ddp_source_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a39);
    ddp_source_instance_rec.install_date := rosetta_g_miss_date_in_map(p4_a40);
    ddp_source_instance_rec.manually_created_flag := p4_a41;
    ddp_source_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a42);
    ddp_source_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a43);
    ddp_source_instance_rec.creation_complete_flag := p4_a44;
    ddp_source_instance_rec.completeness_flag := p4_a45;
    ddp_source_instance_rec.version_label := p4_a46;
    ddp_source_instance_rec.version_label_description := p4_a47;
    ddp_source_instance_rec.context := p4_a48;
    ddp_source_instance_rec.attribute1 := p4_a49;
    ddp_source_instance_rec.attribute2 := p4_a50;
    ddp_source_instance_rec.attribute3 := p4_a51;
    ddp_source_instance_rec.attribute4 := p4_a52;
    ddp_source_instance_rec.attribute5 := p4_a53;
    ddp_source_instance_rec.attribute6 := p4_a54;
    ddp_source_instance_rec.attribute7 := p4_a55;
    ddp_source_instance_rec.attribute8 := p4_a56;
    ddp_source_instance_rec.attribute9 := p4_a57;
    ddp_source_instance_rec.attribute10 := p4_a58;
    ddp_source_instance_rec.attribute11 := p4_a59;
    ddp_source_instance_rec.attribute12 := p4_a60;
    ddp_source_instance_rec.attribute13 := p4_a61;
    ddp_source_instance_rec.attribute14 := p4_a62;
    ddp_source_instance_rec.attribute15 := p4_a63;
    ddp_source_instance_rec.object_version_number := rosetta_g_miss_num_map(p4_a64);
    ddp_source_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p4_a65);
    ddp_source_instance_rec.install_location_type_code := p4_a66;
    ddp_source_instance_rec.install_location_id := rosetta_g_miss_num_map(p4_a67);
    ddp_source_instance_rec.instance_usage_code := p4_a68;
    ddp_source_instance_rec.check_for_instance_expiry := p4_a69;
    ddp_source_instance_rec.processed_flag := p4_a70;
    ddp_source_instance_rec.call_contracts := p4_a71;
    ddp_source_instance_rec.interface_id := rosetta_g_miss_num_map(p4_a72);
    ddp_source_instance_rec.grp_call_contracts := p4_a73;
    ddp_source_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a74);
    ddp_source_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a75);
    ddp_source_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a76);
    ddp_source_instance_rec.config_valid_status := p4_a77;
    ddp_source_instance_rec.instance_description := p4_a78;
    ddp_source_instance_rec.call_batch_validation := p4_a79;
    ddp_source_instance_rec.request_id := rosetta_g_miss_num_map(p4_a80);
    ddp_source_instance_rec.program_application_id := rosetta_g_miss_num_map(p4_a81);
    ddp_source_instance_rec.program_id := rosetta_g_miss_num_map(p4_a82);
    ddp_source_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a83);
    ddp_source_instance_rec.cascade_ownership_flag := p4_a84;
    ddp_source_instance_rec.network_asset_flag := p4_a85;
    ddp_source_instance_rec.maintainable_flag := p4_a86;
    ddp_source_instance_rec.pn_location_id := rosetta_g_miss_num_map(p4_a87);
    ddp_source_instance_rec.asset_criticality_code := p4_a88;
    ddp_source_instance_rec.category_id := rosetta_g_miss_num_map(p4_a89);
    ddp_source_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p4_a90);
    ddp_source_instance_rec.instantiation_flag := p4_a91;
    ddp_source_instance_rec.linear_location_id := rosetta_g_miss_num_map(p4_a92);
    ddp_source_instance_rec.operational_log_flag := p4_a93;
    ddp_source_instance_rec.checkin_status := rosetta_g_miss_num_map(p4_a94);
    ddp_source_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p4_a95);
    ddp_source_instance_rec.attribute16 := p4_a96;
    ddp_source_instance_rec.attribute17 := p4_a97;
    ddp_source_instance_rec.attribute18 := p4_a98;
    ddp_source_instance_rec.attribute19 := p4_a99;
    ddp_source_instance_rec.attribute20 := p4_a100;
    ddp_source_instance_rec.attribute21 := p4_a101;
    ddp_source_instance_rec.attribute22 := p4_a102;
    ddp_source_instance_rec.attribute23 := p4_a103;
    ddp_source_instance_rec.attribute24 := p4_a104;
    ddp_source_instance_rec.attribute25 := p4_a105;
    ddp_source_instance_rec.attribute26 := p4_a106;
    ddp_source_instance_rec.attribute27 := p4_a107;
    ddp_source_instance_rec.attribute28 := p4_a108;
    ddp_source_instance_rec.attribute29 := p4_a109;
    ddp_source_instance_rec.attribute30 := p4_a110;
    ddp_source_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p4_a111);
    ddp_source_instance_rec.purchase_currency_code := p4_a112;
    ddp_source_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p4_a113);
    ddp_source_instance_rec.payables_currency_code := p4_a114;
    ddp_source_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p4_a115);
    ddp_source_instance_rec.sales_currency_code := p4_a116;
    ddp_source_instance_rec.operational_status_code := p4_a117;
    ddp_source_instance_rec.department_id := rosetta_g_miss_num_map(p4_a118);
    ddp_source_instance_rec.wip_accounting_class := p4_a119;
    ddp_source_instance_rec.area_id := rosetta_g_miss_num_map(p4_a120);
    ddp_source_instance_rec.owner_party_id := rosetta_g_miss_num_map(p4_a121);
    ddp_source_instance_rec.source_code := p4_a122;







    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p11_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p11_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p11_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p11_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p11_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p11_a5);
    ddp_txn_rec.source_group_ref := p11_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p11_a7);
    ddp_txn_rec.source_header_ref := p11_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p11_a9);
    ddp_txn_rec.source_line_ref := p11_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p11_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p11_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p11_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p11_a14);
    ddp_txn_rec.transaction_uom_code := p11_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p11_a16);
    ddp_txn_rec.transaction_status_code := p11_a17;
    ddp_txn_rec.transaction_action_code := p11_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p11_a19);
    ddp_txn_rec.context := p11_a20;
    ddp_txn_rec.attribute1 := p11_a21;
    ddp_txn_rec.attribute2 := p11_a22;
    ddp_txn_rec.attribute3 := p11_a23;
    ddp_txn_rec.attribute4 := p11_a24;
    ddp_txn_rec.attribute5 := p11_a25;
    ddp_txn_rec.attribute6 := p11_a26;
    ddp_txn_rec.attribute7 := p11_a27;
    ddp_txn_rec.attribute8 := p11_a28;
    ddp_txn_rec.attribute9 := p11_a29;
    ddp_txn_rec.attribute10 := p11_a30;
    ddp_txn_rec.attribute11 := p11_a31;
    ddp_txn_rec.attribute12 := p11_a32;
    ddp_txn_rec.attribute13 := p11_a33;
    ddp_txn_rec.attribute14 := p11_a34;
    ddp_txn_rec.attribute15 := p11_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p11_a36);
    ddp_txn_rec.split_reason_code := p11_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p11_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p11_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.split_item_instance_lines(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_source_instance_rec,
      p_copy_ext_attribs,
      p_copy_org_assignments,
      p_copy_parties,
      p_copy_accounts,
      p_copy_asset_assignments,
      p_copy_pricing_attribs,
      ddp_txn_rec,
      ddx_new_instance_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_id);
    p4_a1 := ddp_source_instance_rec.instance_number;
    p4_a2 := ddp_source_instance_rec.external_reference;
    p4_a3 := rosetta_g_miss_num_map(ddp_source_instance_rec.inventory_item_id);
    p4_a4 := rosetta_g_miss_num_map(ddp_source_instance_rec.vld_organization_id);
    p4_a5 := ddp_source_instance_rec.inventory_revision;
    p4_a6 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_master_organization_id);
    p4_a7 := ddp_source_instance_rec.serial_number;
    p4_a8 := ddp_source_instance_rec.mfg_serial_number_flag;
    p4_a9 := ddp_source_instance_rec.lot_number;
    p4_a10 := rosetta_g_miss_num_map(ddp_source_instance_rec.quantity);
    p4_a11 := ddp_source_instance_rec.unit_of_measure;
    p4_a12 := ddp_source_instance_rec.accounting_class_code;
    p4_a13 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_condition_id);
    p4_a14 := rosetta_g_miss_num_map(ddp_source_instance_rec.instance_status_id);
    p4_a15 := ddp_source_instance_rec.customer_view_flag;
    p4_a16 := ddp_source_instance_rec.merchant_view_flag;
    p4_a17 := ddp_source_instance_rec.sellable_flag;
    p4_a18 := rosetta_g_miss_num_map(ddp_source_instance_rec.system_id);
    p4_a19 := ddp_source_instance_rec.instance_type_code;
    p4_a20 := ddp_source_instance_rec.active_start_date;
    p4_a21 := ddp_source_instance_rec.active_end_date;
    p4_a22 := ddp_source_instance_rec.location_type_code;
    p4_a23 := rosetta_g_miss_num_map(ddp_source_instance_rec.location_id);
    p4_a24 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_organization_id);
    p4_a25 := ddp_source_instance_rec.inv_subinventory_name;
    p4_a26 := rosetta_g_miss_num_map(ddp_source_instance_rec.inv_locator_id);
    p4_a27 := rosetta_g_miss_num_map(ddp_source_instance_rec.pa_project_id);
    p4_a28 := rosetta_g_miss_num_map(ddp_source_instance_rec.pa_project_task_id);
    p4_a29 := rosetta_g_miss_num_map(ddp_source_instance_rec.in_transit_order_line_id);
    p4_a30 := rosetta_g_miss_num_map(ddp_source_instance_rec.wip_job_id);
    p4_a31 := rosetta_g_miss_num_map(ddp_source_instance_rec.po_order_line_id);
    p4_a32 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_order_line_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_rma_line_id);
    p4_a34 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_po_po_line_id);
    p4_a35 := ddp_source_instance_rec.last_oe_po_number;
    p4_a36 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_wip_job_id);
    p4_a37 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_pa_project_id);
    p4_a38 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_pa_task_id);
    p4_a39 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_oe_agreement_id);
    p4_a40 := ddp_source_instance_rec.install_date;
    p4_a41 := ddp_source_instance_rec.manually_created_flag;
    p4_a42 := ddp_source_instance_rec.return_by_date;
    p4_a43 := ddp_source_instance_rec.actual_return_date;
    p4_a44 := ddp_source_instance_rec.creation_complete_flag;
    p4_a45 := ddp_source_instance_rec.completeness_flag;
    p4_a46 := ddp_source_instance_rec.version_label;
    p4_a47 := ddp_source_instance_rec.version_label_description;
    p4_a48 := ddp_source_instance_rec.context;
    p4_a49 := ddp_source_instance_rec.attribute1;
    p4_a50 := ddp_source_instance_rec.attribute2;
    p4_a51 := ddp_source_instance_rec.attribute3;
    p4_a52 := ddp_source_instance_rec.attribute4;
    p4_a53 := ddp_source_instance_rec.attribute5;
    p4_a54 := ddp_source_instance_rec.attribute6;
    p4_a55 := ddp_source_instance_rec.attribute7;
    p4_a56 := ddp_source_instance_rec.attribute8;
    p4_a57 := ddp_source_instance_rec.attribute9;
    p4_a58 := ddp_source_instance_rec.attribute10;
    p4_a59 := ddp_source_instance_rec.attribute11;
    p4_a60 := ddp_source_instance_rec.attribute12;
    p4_a61 := ddp_source_instance_rec.attribute13;
    p4_a62 := ddp_source_instance_rec.attribute14;
    p4_a63 := ddp_source_instance_rec.attribute15;
    p4_a64 := rosetta_g_miss_num_map(ddp_source_instance_rec.object_version_number);
    p4_a65 := rosetta_g_miss_num_map(ddp_source_instance_rec.last_txn_line_detail_id);
    p4_a66 := ddp_source_instance_rec.install_location_type_code;
    p4_a67 := rosetta_g_miss_num_map(ddp_source_instance_rec.install_location_id);
    p4_a68 := ddp_source_instance_rec.instance_usage_code;
    p4_a69 := ddp_source_instance_rec.check_for_instance_expiry;
    p4_a70 := ddp_source_instance_rec.processed_flag;
    p4_a71 := ddp_source_instance_rec.call_contracts;
    p4_a72 := rosetta_g_miss_num_map(ddp_source_instance_rec.interface_id);
    p4_a73 := ddp_source_instance_rec.grp_call_contracts;
    p4_a74 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_hdr_id);
    p4_a75 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_rev_num);
    p4_a76 := rosetta_g_miss_num_map(ddp_source_instance_rec.config_inst_item_id);
    p4_a77 := ddp_source_instance_rec.config_valid_status;
    p4_a78 := ddp_source_instance_rec.instance_description;
    p4_a79 := ddp_source_instance_rec.call_batch_validation;
    p4_a80 := rosetta_g_miss_num_map(ddp_source_instance_rec.request_id);
    p4_a81 := rosetta_g_miss_num_map(ddp_source_instance_rec.program_application_id);
    p4_a82 := rosetta_g_miss_num_map(ddp_source_instance_rec.program_id);
    p4_a83 := ddp_source_instance_rec.program_update_date;
    p4_a84 := ddp_source_instance_rec.cascade_ownership_flag;
    p4_a85 := ddp_source_instance_rec.network_asset_flag;
    p4_a86 := ddp_source_instance_rec.maintainable_flag;
    p4_a87 := rosetta_g_miss_num_map(ddp_source_instance_rec.pn_location_id);
    p4_a88 := ddp_source_instance_rec.asset_criticality_code;
    p4_a89 := rosetta_g_miss_num_map(ddp_source_instance_rec.category_id);
    p4_a90 := rosetta_g_miss_num_map(ddp_source_instance_rec.equipment_gen_object_id);
    p4_a91 := ddp_source_instance_rec.instantiation_flag;
    p4_a92 := rosetta_g_miss_num_map(ddp_source_instance_rec.linear_location_id);
    p4_a93 := ddp_source_instance_rec.operational_log_flag;
    p4_a94 := rosetta_g_miss_num_map(ddp_source_instance_rec.checkin_status);
    p4_a95 := ddp_source_instance_rec.supplier_warranty_exp_date;
    p4_a96 := ddp_source_instance_rec.attribute16;
    p4_a97 := ddp_source_instance_rec.attribute17;
    p4_a98 := ddp_source_instance_rec.attribute18;
    p4_a99 := ddp_source_instance_rec.attribute19;
    p4_a100 := ddp_source_instance_rec.attribute20;
    p4_a101 := ddp_source_instance_rec.attribute21;
    p4_a102 := ddp_source_instance_rec.attribute22;
    p4_a103 := ddp_source_instance_rec.attribute23;
    p4_a104 := ddp_source_instance_rec.attribute24;
    p4_a105 := ddp_source_instance_rec.attribute25;
    p4_a106 := ddp_source_instance_rec.attribute26;
    p4_a107 := ddp_source_instance_rec.attribute27;
    p4_a108 := ddp_source_instance_rec.attribute28;
    p4_a109 := ddp_source_instance_rec.attribute29;
    p4_a110 := ddp_source_instance_rec.attribute30;
    p4_a111 := rosetta_g_miss_num_map(ddp_source_instance_rec.purchase_unit_price);
    p4_a112 := ddp_source_instance_rec.purchase_currency_code;
    p4_a113 := rosetta_g_miss_num_map(ddp_source_instance_rec.payables_unit_price);
    p4_a114 := ddp_source_instance_rec.payables_currency_code;
    p4_a115 := rosetta_g_miss_num_map(ddp_source_instance_rec.sales_unit_price);
    p4_a116 := ddp_source_instance_rec.sales_currency_code;
    p4_a117 := ddp_source_instance_rec.operational_status_code;
    p4_a118 := rosetta_g_miss_num_map(ddp_source_instance_rec.department_id);
    p4_a119 := ddp_source_instance_rec.wip_accounting_class;
    p4_a120 := rosetta_g_miss_num_map(ddp_source_instance_rec.area_id);
    p4_a121 := rosetta_g_miss_num_map(ddp_source_instance_rec.owner_party_id);
    p4_a122 := ddp_source_instance_rec.source_code;







    p11_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p11_a1 := ddp_txn_rec.transaction_date;
    p11_a2 := ddp_txn_rec.source_transaction_date;
    p11_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p11_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p11_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p11_a6 := ddp_txn_rec.source_group_ref;
    p11_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p11_a8 := ddp_txn_rec.source_header_ref;
    p11_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p11_a10 := ddp_txn_rec.source_line_ref;
    p11_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p11_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p11_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p11_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p11_a15 := ddp_txn_rec.transaction_uom_code;
    p11_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p11_a17 := ddp_txn_rec.transaction_status_code;
    p11_a18 := ddp_txn_rec.transaction_action_code;
    p11_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p11_a20 := ddp_txn_rec.context;
    p11_a21 := ddp_txn_rec.attribute1;
    p11_a22 := ddp_txn_rec.attribute2;
    p11_a23 := ddp_txn_rec.attribute3;
    p11_a24 := ddp_txn_rec.attribute4;
    p11_a25 := ddp_txn_rec.attribute5;
    p11_a26 := ddp_txn_rec.attribute6;
    p11_a27 := ddp_txn_rec.attribute7;
    p11_a28 := ddp_txn_rec.attribute8;
    p11_a29 := ddp_txn_rec.attribute9;
    p11_a30 := ddp_txn_rec.attribute10;
    p11_a31 := ddp_txn_rec.attribute11;
    p11_a32 := ddp_txn_rec.attribute12;
    p11_a33 := ddp_txn_rec.attribute13;
    p11_a34 := ddp_txn_rec.attribute14;
    p11_a35 := ddp_txn_rec.attribute15;
    p11_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p11_a37 := ddp_txn_rec.split_reason_code;
    p11_a38 := ddp_txn_rec.src_txn_creation_date;
    p11_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p19(ddx_new_instance_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      , p12_a35
      , p12_a36
      , p12_a37
      , p12_a38
      , p12_a39
      , p12_a40
      , p12_a41
      , p12_a42
      , p12_a43
      , p12_a44
      , p12_a45
      , p12_a46
      , p12_a47
      , p12_a48
      , p12_a49
      , p12_a50
      , p12_a51
      , p12_a52
      , p12_a53
      , p12_a54
      , p12_a55
      , p12_a56
      , p12_a57
      , p12_a58
      , p12_a59
      , p12_a60
      , p12_a61
      , p12_a62
      , p12_a63
      , p12_a64
      , p12_a65
      , p12_a66
      , p12_a67
      , p12_a68
      , p12_a69
      , p12_a70
      , p12_a71
      , p12_a72
      , p12_a73
      , p12_a74
      , p12_a75
      , p12_a76
      , p12_a77
      , p12_a78
      , p12_a79
      , p12_a80
      , p12_a81
      , p12_a82
      , p12_a83
      , p12_a84
      , p12_a85
      , p12_a86
      , p12_a87
      , p12_a88
      , p12_a89
      , p12_a90
      , p12_a91
      , p12_a92
      , p12_a93
      , p12_a94
      , p12_a95
      , p12_a96
      , p12_a97
      , p12_a98
      , p12_a99
      , p12_a100
      , p12_a101
      , p12_a102
      , p12_a103
      , p12_a104
      , p12_a105
      , p12_a106
      , p12_a107
      , p12_a108
      , p12_a109
      , p12_a110
      , p12_a111
      , p12_a112
      , p12_a113
      , p12_a114
      , p12_a115
      , p12_a116
      , p12_a117
      , p12_a118
      , p12_a119
      , p12_a120
      , p12_a121
      , p12_a122
      );



  end;

  procedure copy_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_contacts  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p_copy_inst_children  VARCHAR2
    , p13_a0 in out nocopy  NUMBER
    , p13_a1 in out nocopy  DATE
    , p13_a2 in out nocopy  DATE
    , p13_a3 in out nocopy  NUMBER
    , p13_a4 in out nocopy  NUMBER
    , p13_a5 in out nocopy  NUMBER
    , p13_a6 in out nocopy  VARCHAR2
    , p13_a7 in out nocopy  NUMBER
    , p13_a8 in out nocopy  VARCHAR2
    , p13_a9 in out nocopy  NUMBER
    , p13_a10 in out nocopy  VARCHAR2
    , p13_a11 in out nocopy  NUMBER
    , p13_a12 in out nocopy  NUMBER
    , p13_a13 in out nocopy  NUMBER
    , p13_a14 in out nocopy  NUMBER
    , p13_a15 in out nocopy  VARCHAR2
    , p13_a16 in out nocopy  NUMBER
    , p13_a17 in out nocopy  VARCHAR2
    , p13_a18 in out nocopy  VARCHAR2
    , p13_a19 in out nocopy  NUMBER
    , p13_a20 in out nocopy  VARCHAR2
    , p13_a21 in out nocopy  VARCHAR2
    , p13_a22 in out nocopy  VARCHAR2
    , p13_a23 in out nocopy  VARCHAR2
    , p13_a24 in out nocopy  VARCHAR2
    , p13_a25 in out nocopy  VARCHAR2
    , p13_a26 in out nocopy  VARCHAR2
    , p13_a27 in out nocopy  VARCHAR2
    , p13_a28 in out nocopy  VARCHAR2
    , p13_a29 in out nocopy  VARCHAR2
    , p13_a30 in out nocopy  VARCHAR2
    , p13_a31 in out nocopy  VARCHAR2
    , p13_a32 in out nocopy  VARCHAR2
    , p13_a33 in out nocopy  VARCHAR2
    , p13_a34 in out nocopy  VARCHAR2
    , p13_a35 in out nocopy  VARCHAR2
    , p13_a36 in out nocopy  NUMBER
    , p13_a37 in out nocopy  VARCHAR2
    , p13_a38 in out nocopy  DATE
    , p13_a39 in out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_NUMBER_TABLE
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_NUMBER_TABLE
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_NUMBER_TABLE
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_NUMBER_TABLE
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_DATE_TABLE
    , p14_a21 out nocopy JTF_DATE_TABLE
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_NUMBER_TABLE
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 out nocopy JTF_NUMBER_TABLE
    , p14_a27 out nocopy JTF_NUMBER_TABLE
    , p14_a28 out nocopy JTF_NUMBER_TABLE
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , p14_a30 out nocopy JTF_NUMBER_TABLE
    , p14_a31 out nocopy JTF_NUMBER_TABLE
    , p14_a32 out nocopy JTF_NUMBER_TABLE
    , p14_a33 out nocopy JTF_NUMBER_TABLE
    , p14_a34 out nocopy JTF_NUMBER_TABLE
    , p14_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a36 out nocopy JTF_NUMBER_TABLE
    , p14_a37 out nocopy JTF_NUMBER_TABLE
    , p14_a38 out nocopy JTF_NUMBER_TABLE
    , p14_a39 out nocopy JTF_NUMBER_TABLE
    , p14_a40 out nocopy JTF_DATE_TABLE
    , p14_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a42 out nocopy JTF_DATE_TABLE
    , p14_a43 out nocopy JTF_DATE_TABLE
    , p14_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a64 out nocopy JTF_NUMBER_TABLE
    , p14_a65 out nocopy JTF_NUMBER_TABLE
    , p14_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a67 out nocopy JTF_NUMBER_TABLE
    , p14_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a72 out nocopy JTF_NUMBER_TABLE
    , p14_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a74 out nocopy JTF_NUMBER_TABLE
    , p14_a75 out nocopy JTF_NUMBER_TABLE
    , p14_a76 out nocopy JTF_NUMBER_TABLE
    , p14_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a80 out nocopy JTF_NUMBER_TABLE
    , p14_a81 out nocopy JTF_NUMBER_TABLE
    , p14_a82 out nocopy JTF_NUMBER_TABLE
    , p14_a83 out nocopy JTF_DATE_TABLE
    , p14_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a87 out nocopy JTF_NUMBER_TABLE
    , p14_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a89 out nocopy JTF_NUMBER_TABLE
    , p14_a90 out nocopy JTF_NUMBER_TABLE
    , p14_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a92 out nocopy JTF_NUMBER_TABLE
    , p14_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a94 out nocopy JTF_NUMBER_TABLE
    , p14_a95 out nocopy JTF_DATE_TABLE
    , p14_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a111 out nocopy JTF_NUMBER_TABLE
    , p14_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a113 out nocopy JTF_NUMBER_TABLE
    , p14_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a115 out nocopy JTF_NUMBER_TABLE
    , p14_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a118 out nocopy JTF_NUMBER_TABLE
    , p14_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a120 out nocopy JTF_NUMBER_TABLE
    , p14_a121 out nocopy JTF_NUMBER_TABLE
    , p14_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  NUMBER := 0-1962.0724
    , p4_a40  DATE := fnd_api.g_miss_date
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  DATE := fnd_api.g_miss_date
    , p4_a43  DATE := fnd_api.g_miss_date
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  NUMBER := 0-1962.0724
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  NUMBER := 0-1962.0724
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  NUMBER := 0-1962.0724
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  NUMBER := 0-1962.0724
    , p4_a75  NUMBER := 0-1962.0724
    , p4_a76  NUMBER := 0-1962.0724
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  NUMBER := 0-1962.0724
    , p4_a82  NUMBER := 0-1962.0724
    , p4_a83  DATE := fnd_api.g_miss_date
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  NUMBER := 0-1962.0724
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  NUMBER := 0-1962.0724
    , p4_a90  NUMBER := 0-1962.0724
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  NUMBER := 0-1962.0724
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  NUMBER := 0-1962.0724
    , p4_a95  DATE := fnd_api.g_miss_date
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  NUMBER := 0-1962.0724
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  NUMBER := 0-1962.0724
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  NUMBER := 0-1962.0724
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  NUMBER := 0-1962.0724
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  NUMBER := 0-1962.0724
    , p4_a121  NUMBER := 0-1962.0724
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_source_instance_rec csi_datastructures_pub.instance_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_new_instance_tbl csi_datastructures_pub.instance_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_source_instance_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_source_instance_rec.instance_number := p4_a1;
    ddp_source_instance_rec.external_reference := p4_a2;
    ddp_source_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a3);
    ddp_source_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p4_a4);
    ddp_source_instance_rec.inventory_revision := p4_a5;
    ddp_source_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a6);
    ddp_source_instance_rec.serial_number := p4_a7;
    ddp_source_instance_rec.mfg_serial_number_flag := p4_a8;
    ddp_source_instance_rec.lot_number := p4_a9;
    ddp_source_instance_rec.quantity := rosetta_g_miss_num_map(p4_a10);
    ddp_source_instance_rec.unit_of_measure := p4_a11;
    ddp_source_instance_rec.accounting_class_code := p4_a12;
    ddp_source_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a13);
    ddp_source_instance_rec.instance_status_id := rosetta_g_miss_num_map(p4_a14);
    ddp_source_instance_rec.customer_view_flag := p4_a15;
    ddp_source_instance_rec.merchant_view_flag := p4_a16;
    ddp_source_instance_rec.sellable_flag := p4_a17;
    ddp_source_instance_rec.system_id := rosetta_g_miss_num_map(p4_a18);
    ddp_source_instance_rec.instance_type_code := p4_a19;
    ddp_source_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_source_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_source_instance_rec.location_type_code := p4_a22;
    ddp_source_instance_rec.location_id := rosetta_g_miss_num_map(p4_a23);
    ddp_source_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a24);
    ddp_source_instance_rec.inv_subinventory_name := p4_a25;
    ddp_source_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a26);
    ddp_source_instance_rec.pa_project_id := rosetta_g_miss_num_map(p4_a27);
    ddp_source_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a28);
    ddp_source_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a29);
    ddp_source_instance_rec.wip_job_id := rosetta_g_miss_num_map(p4_a30);
    ddp_source_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a31);
    ddp_source_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a32);
    ddp_source_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a33);
    ddp_source_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a34);
    ddp_source_instance_rec.last_oe_po_number := p4_a35;
    ddp_source_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a36);
    ddp_source_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a37);
    ddp_source_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a38);
    ddp_source_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a39);
    ddp_source_instance_rec.install_date := rosetta_g_miss_date_in_map(p4_a40);
    ddp_source_instance_rec.manually_created_flag := p4_a41;
    ddp_source_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a42);
    ddp_source_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a43);
    ddp_source_instance_rec.creation_complete_flag := p4_a44;
    ddp_source_instance_rec.completeness_flag := p4_a45;
    ddp_source_instance_rec.version_label := p4_a46;
    ddp_source_instance_rec.version_label_description := p4_a47;
    ddp_source_instance_rec.context := p4_a48;
    ddp_source_instance_rec.attribute1 := p4_a49;
    ddp_source_instance_rec.attribute2 := p4_a50;
    ddp_source_instance_rec.attribute3 := p4_a51;
    ddp_source_instance_rec.attribute4 := p4_a52;
    ddp_source_instance_rec.attribute5 := p4_a53;
    ddp_source_instance_rec.attribute6 := p4_a54;
    ddp_source_instance_rec.attribute7 := p4_a55;
    ddp_source_instance_rec.attribute8 := p4_a56;
    ddp_source_instance_rec.attribute9 := p4_a57;
    ddp_source_instance_rec.attribute10 := p4_a58;
    ddp_source_instance_rec.attribute11 := p4_a59;
    ddp_source_instance_rec.attribute12 := p4_a60;
    ddp_source_instance_rec.attribute13 := p4_a61;
    ddp_source_instance_rec.attribute14 := p4_a62;
    ddp_source_instance_rec.attribute15 := p4_a63;
    ddp_source_instance_rec.object_version_number := rosetta_g_miss_num_map(p4_a64);
    ddp_source_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p4_a65);
    ddp_source_instance_rec.install_location_type_code := p4_a66;
    ddp_source_instance_rec.install_location_id := rosetta_g_miss_num_map(p4_a67);
    ddp_source_instance_rec.instance_usage_code := p4_a68;
    ddp_source_instance_rec.check_for_instance_expiry := p4_a69;
    ddp_source_instance_rec.processed_flag := p4_a70;
    ddp_source_instance_rec.call_contracts := p4_a71;
    ddp_source_instance_rec.interface_id := rosetta_g_miss_num_map(p4_a72);
    ddp_source_instance_rec.grp_call_contracts := p4_a73;
    ddp_source_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a74);
    ddp_source_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a75);
    ddp_source_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a76);
    ddp_source_instance_rec.config_valid_status := p4_a77;
    ddp_source_instance_rec.instance_description := p4_a78;
    ddp_source_instance_rec.call_batch_validation := p4_a79;
    ddp_source_instance_rec.request_id := rosetta_g_miss_num_map(p4_a80);
    ddp_source_instance_rec.program_application_id := rosetta_g_miss_num_map(p4_a81);
    ddp_source_instance_rec.program_id := rosetta_g_miss_num_map(p4_a82);
    ddp_source_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a83);
    ddp_source_instance_rec.cascade_ownership_flag := p4_a84;
    ddp_source_instance_rec.network_asset_flag := p4_a85;
    ddp_source_instance_rec.maintainable_flag := p4_a86;
    ddp_source_instance_rec.pn_location_id := rosetta_g_miss_num_map(p4_a87);
    ddp_source_instance_rec.asset_criticality_code := p4_a88;
    ddp_source_instance_rec.category_id := rosetta_g_miss_num_map(p4_a89);
    ddp_source_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p4_a90);
    ddp_source_instance_rec.instantiation_flag := p4_a91;
    ddp_source_instance_rec.linear_location_id := rosetta_g_miss_num_map(p4_a92);
    ddp_source_instance_rec.operational_log_flag := p4_a93;
    ddp_source_instance_rec.checkin_status := rosetta_g_miss_num_map(p4_a94);
    ddp_source_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p4_a95);
    ddp_source_instance_rec.attribute16 := p4_a96;
    ddp_source_instance_rec.attribute17 := p4_a97;
    ddp_source_instance_rec.attribute18 := p4_a98;
    ddp_source_instance_rec.attribute19 := p4_a99;
    ddp_source_instance_rec.attribute20 := p4_a100;
    ddp_source_instance_rec.attribute21 := p4_a101;
    ddp_source_instance_rec.attribute22 := p4_a102;
    ddp_source_instance_rec.attribute23 := p4_a103;
    ddp_source_instance_rec.attribute24 := p4_a104;
    ddp_source_instance_rec.attribute25 := p4_a105;
    ddp_source_instance_rec.attribute26 := p4_a106;
    ddp_source_instance_rec.attribute27 := p4_a107;
    ddp_source_instance_rec.attribute28 := p4_a108;
    ddp_source_instance_rec.attribute29 := p4_a109;
    ddp_source_instance_rec.attribute30 := p4_a110;
    ddp_source_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p4_a111);
    ddp_source_instance_rec.purchase_currency_code := p4_a112;
    ddp_source_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p4_a113);
    ddp_source_instance_rec.payables_currency_code := p4_a114;
    ddp_source_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p4_a115);
    ddp_source_instance_rec.sales_currency_code := p4_a116;
    ddp_source_instance_rec.operational_status_code := p4_a117;
    ddp_source_instance_rec.department_id := rosetta_g_miss_num_map(p4_a118);
    ddp_source_instance_rec.wip_accounting_class := p4_a119;
    ddp_source_instance_rec.area_id := rosetta_g_miss_num_map(p4_a120);
    ddp_source_instance_rec.owner_party_id := rosetta_g_miss_num_map(p4_a121);
    ddp_source_instance_rec.source_code := p4_a122;









    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p13_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p13_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p13_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p13_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p13_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p13_a5);
    ddp_txn_rec.source_group_ref := p13_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p13_a7);
    ddp_txn_rec.source_header_ref := p13_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p13_a9);
    ddp_txn_rec.source_line_ref := p13_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p13_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p13_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p13_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p13_a14);
    ddp_txn_rec.transaction_uom_code := p13_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p13_a16);
    ddp_txn_rec.transaction_status_code := p13_a17;
    ddp_txn_rec.transaction_action_code := p13_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p13_a19);
    ddp_txn_rec.context := p13_a20;
    ddp_txn_rec.attribute1 := p13_a21;
    ddp_txn_rec.attribute2 := p13_a22;
    ddp_txn_rec.attribute3 := p13_a23;
    ddp_txn_rec.attribute4 := p13_a24;
    ddp_txn_rec.attribute5 := p13_a25;
    ddp_txn_rec.attribute6 := p13_a26;
    ddp_txn_rec.attribute7 := p13_a27;
    ddp_txn_rec.attribute8 := p13_a28;
    ddp_txn_rec.attribute9 := p13_a29;
    ddp_txn_rec.attribute10 := p13_a30;
    ddp_txn_rec.attribute11 := p13_a31;
    ddp_txn_rec.attribute12 := p13_a32;
    ddp_txn_rec.attribute13 := p13_a33;
    ddp_txn_rec.attribute14 := p13_a34;
    ddp_txn_rec.attribute15 := p13_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p13_a36);
    ddp_txn_rec.split_reason_code := p13_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p13_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p13_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.copy_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_source_instance_rec,
      p_copy_ext_attribs,
      p_copy_org_assignments,
      p_copy_parties,
      p_copy_contacts,
      p_copy_accounts,
      p_copy_asset_assignments,
      p_copy_pricing_attribs,
      p_copy_inst_children,
      ddp_txn_rec,
      ddx_new_instance_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p13_a1 := ddp_txn_rec.transaction_date;
    p13_a2 := ddp_txn_rec.source_transaction_date;
    p13_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p13_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p13_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p13_a6 := ddp_txn_rec.source_group_ref;
    p13_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p13_a8 := ddp_txn_rec.source_header_ref;
    p13_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p13_a10 := ddp_txn_rec.source_line_ref;
    p13_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p13_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p13_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p13_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p13_a15 := ddp_txn_rec.transaction_uom_code;
    p13_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p13_a17 := ddp_txn_rec.transaction_status_code;
    p13_a18 := ddp_txn_rec.transaction_action_code;
    p13_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p13_a20 := ddp_txn_rec.context;
    p13_a21 := ddp_txn_rec.attribute1;
    p13_a22 := ddp_txn_rec.attribute2;
    p13_a23 := ddp_txn_rec.attribute3;
    p13_a24 := ddp_txn_rec.attribute4;
    p13_a25 := ddp_txn_rec.attribute5;
    p13_a26 := ddp_txn_rec.attribute6;
    p13_a27 := ddp_txn_rec.attribute7;
    p13_a28 := ddp_txn_rec.attribute8;
    p13_a29 := ddp_txn_rec.attribute9;
    p13_a30 := ddp_txn_rec.attribute10;
    p13_a31 := ddp_txn_rec.attribute11;
    p13_a32 := ddp_txn_rec.attribute12;
    p13_a33 := ddp_txn_rec.attribute13;
    p13_a34 := ddp_txn_rec.attribute14;
    p13_a35 := ddp_txn_rec.attribute15;
    p13_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p13_a37 := ddp_txn_rec.split_reason_code;
    p13_a38 := ddp_txn_rec.src_txn_creation_date;
    p13_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p19(ddx_new_instance_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      , p14_a27
      , p14_a28
      , p14_a29
      , p14_a30
      , p14_a31
      , p14_a32
      , p14_a33
      , p14_a34
      , p14_a35
      , p14_a36
      , p14_a37
      , p14_a38
      , p14_a39
      , p14_a40
      , p14_a41
      , p14_a42
      , p14_a43
      , p14_a44
      , p14_a45
      , p14_a46
      , p14_a47
      , p14_a48
      , p14_a49
      , p14_a50
      , p14_a51
      , p14_a52
      , p14_a53
      , p14_a54
      , p14_a55
      , p14_a56
      , p14_a57
      , p14_a58
      , p14_a59
      , p14_a60
      , p14_a61
      , p14_a62
      , p14_a63
      , p14_a64
      , p14_a65
      , p14_a66
      , p14_a67
      , p14_a68
      , p14_a69
      , p14_a70
      , p14_a71
      , p14_a72
      , p14_a73
      , p14_a74
      , p14_a75
      , p14_a76
      , p14_a77
      , p14_a78
      , p14_a79
      , p14_a80
      , p14_a81
      , p14_a82
      , p14_a83
      , p14_a84
      , p14_a85
      , p14_a86
      , p14_a87
      , p14_a88
      , p14_a89
      , p14_a90
      , p14_a91
      , p14_a92
      , p14_a93
      , p14_a94
      , p14_a95
      , p14_a96
      , p14_a97
      , p14_a98
      , p14_a99
      , p14_a100
      , p14_a101
      , p14_a102
      , p14_a103
      , p14_a104
      , p14_a105
      , p14_a106
      , p14_a107
      , p14_a108
      , p14_a109
      , p14_a110
      , p14_a111
      , p14_a112
      , p14_a113
      , p14_a114
      , p14_a115
      , p14_a116
      , p14_a117
      , p14_a118
      , p14_a119
      , p14_a120
      , p14_a121
      , p14_a122
      );



  end;

  procedure getcontracts(product_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a10 out nocopy JTF_DATE_TABLE
    , p4_a11 out nocopy JTF_DATE_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a14 out nocopy JTF_DATE_TABLE
    , p4_a15 out nocopy JTF_DATE_TABLE
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a18 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_output_contracts csi_java_interface_pkg.csi_output_tbl_ib;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.getcontracts(product_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_output_contracts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_java_interface_pkg_w.rosetta_table_copy_out_p1(ddx_output_contracts, p4_a0
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
      );
  end;

  procedure get_coverage_for_prod_sch(contract_number  VARCHAR2
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , x_sequence_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_coverage_tbl csi_java_interface_pkg.csi_coverage_tbl_ib;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.get_coverage_for_prod_sch(contract_number,
      ddx_coverage_tbl,
      x_sequence_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    csi_java_interface_pkg_w.rosetta_table_copy_out_p3(ddx_coverage_tbl, p1_a0
      , p1_a1
      );




  end;

  procedure get_history_transactions(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p_instance_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_NUMBER_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_NUMBER_TABLE
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_NUMBER_TABLE
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_NUMBER_TABLE
    , p6_a98 out nocopy JTF_NUMBER_TABLE
    , p6_a99 out nocopy JTF_NUMBER_TABLE
    , p6_a100 out nocopy JTF_NUMBER_TABLE
    , p6_a101 out nocopy JTF_NUMBER_TABLE
    , p6_a102 out nocopy JTF_NUMBER_TABLE
    , p6_a103 out nocopy JTF_NUMBER_TABLE
    , p6_a104 out nocopy JTF_NUMBER_TABLE
    , p6_a105 out nocopy JTF_DATE_TABLE
    , p6_a106 out nocopy JTF_DATE_TABLE
    , p6_a107 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a108 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a109 out nocopy JTF_DATE_TABLE
    , p6_a110 out nocopy JTF_DATE_TABLE
    , p6_a111 out nocopy JTF_DATE_TABLE
    , p6_a112 out nocopy JTF_DATE_TABLE
    , p6_a113 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a115 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a118 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a129 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a130 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a131 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a132 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a133 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a134 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a135 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a136 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a137 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a138 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a139 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a140 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a141 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a142 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a143 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a144 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a145 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a146 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a147 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a148 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a149 out nocopy JTF_NUMBER_TABLE
    , p6_a150 out nocopy JTF_NUMBER_TABLE
    , p6_a151 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a152 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a153 out nocopy JTF_NUMBER_TABLE
    , p6_a154 out nocopy JTF_NUMBER_TABLE
    , p6_a155 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a156 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a157 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a158 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a159 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a160 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a161 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a162 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a163 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a164 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a167 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a170 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a171 out nocopy JTF_NUMBER_TABLE
    , p6_a172 out nocopy JTF_NUMBER_TABLE
    , p6_a173 out nocopy JTF_NUMBER_TABLE
    , p6_a174 out nocopy JTF_NUMBER_TABLE
    , p6_a175 out nocopy JTF_DATE_TABLE
    , p6_a176 out nocopy JTF_DATE_TABLE
    , p6_a177 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a183 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a184 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a185 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a186 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a187 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a188 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a189 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a190 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a191 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a192 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a193 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a194 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a195 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a196 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a197 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a198 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a199 out nocopy JTF_NUMBER_TABLE
    , p6_a200 out nocopy JTF_NUMBER_TABLE
    , p6_a201 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a202 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a203 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a204 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a205 out nocopy JTF_NUMBER_TABLE
    , p6_a206 out nocopy JTF_NUMBER_TABLE
    , p6_a207 out nocopy JTF_NUMBER_TABLE
    , p6_a208 out nocopy JTF_NUMBER_TABLE
    , p6_a209 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a210 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a211 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a212 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a213 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a214 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a215 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a216 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a217 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a218 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a219 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a220 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a221 out nocopy JTF_NUMBER_TABLE
    , p6_a222 out nocopy JTF_NUMBER_TABLE
    , p6_a223 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a224 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a225 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a226 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a227 out nocopy JTF_NUMBER_TABLE
    , p6_a228 out nocopy JTF_NUMBER_TABLE
    , p6_a229 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a230 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a231 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a232 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a233 out nocopy JTF_NUMBER_TABLE
    , p6_a234 out nocopy JTF_NUMBER_TABLE
    , p6_a235 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a236 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a237 out nocopy JTF_NUMBER_TABLE
    , p6_a238 out nocopy JTF_NUMBER_TABLE
    , p6_a239 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a240 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a241 out nocopy JTF_NUMBER_TABLE
    , p6_a242 out nocopy JTF_NUMBER_TABLE
    , p6_a243 out nocopy JTF_DATE_TABLE
    , p6_a244 out nocopy JTF_DATE_TABLE
    , p6_a245 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a246 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a247 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a248 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a249 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a250 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a251 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a252 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a253 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a254 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a255 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a256 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a257 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a258 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a259 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a260 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a261 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a262 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a263 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a264 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a265 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a266 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a267 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a268 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a269 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a270 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a271 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a272 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a273 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a274 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a275 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a276 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a277 out nocopy JTF_NUMBER_TABLE
    , p6_a278 out nocopy JTF_NUMBER_TABLE
    , p6_a279 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a280 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a281 out nocopy JTF_NUMBER_TABLE
    , p6_a282 out nocopy JTF_NUMBER_TABLE
    , p6_a283 out nocopy JTF_NUMBER_TABLE
    , p6_a284 out nocopy JTF_NUMBER_TABLE
    , p6_a285 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a286 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a287 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a288 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a289 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a290 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a291 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a292 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a293 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_DATE_TABLE
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a50 out nocopy JTF_NUMBER_TABLE
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a72 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a75 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a86 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
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
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a90 out nocopy JTF_NUMBER_TABLE
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_DATE_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_DATE_TABLE
    , p10_a14 out nocopy JTF_DATE_TABLE
    , p10_a15 out nocopy JTF_DATE_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_DATE_TABLE
    , p10_a40 out nocopy JTF_DATE_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_NUMBER_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a4 out nocopy JTF_DATE_TABLE
    , p11_a5 out nocopy JTF_DATE_TABLE
    , p11_a6 out nocopy JTF_DATE_TABLE
    , p11_a7 out nocopy JTF_DATE_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a7 out nocopy JTF_DATE_TABLE
    , p12_a8 out nocopy JTF_DATE_TABLE
    , p12_a9 out nocopy JTF_DATE_TABLE
    , p12_a10 out nocopy JTF_DATE_TABLE
    , p12_a11 out nocopy JTF_DATE_TABLE
    , p12_a12 out nocopy JTF_DATE_TABLE
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a46 out nocopy JTF_NUMBER_TABLE
    , p12_a47 out nocopy JTF_NUMBER_TABLE
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_DATE_TABLE
    , p13_a8 out nocopy JTF_DATE_TABLE
    , p13_a9 out nocopy JTF_DATE_TABLE
    , p13_a10 out nocopy JTF_DATE_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a46 out nocopy JTF_NUMBER_TABLE
    , p13_a47 out nocopy JTF_DATE_TABLE
    , p13_a48 out nocopy JTF_NUMBER_TABLE
    , p13_a49 out nocopy JTF_NUMBER_TABLE
    , p13_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_instance_history_tbl csi_datastructures_pub.instance_history_tbl;
    ddx_party_history_tbl csi_datastructures_pub.party_history_tbl;
    ddx_account_history_tbl csi_datastructures_pub.account_history_tbl;
    ddx_org_unit_history_tbl csi_datastructures_pub.org_units_history_tbl;
    ddx_ins_asset_hist_tbl csi_datastructures_pub.ins_asset_history_tbl;
    ddx_ext_attrib_val_hist_tbl csi_datastructures_pub.ext_attrib_val_history_tbl;
    ddx_version_label_hist_tbl csi_datastructures_pub.version_label_history_tbl;
    ddx_rel_history_tbl csi_datastructures_pub.relationship_history_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.get_history_transactions(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_transaction_id,
      p_instance_id,
      ddx_instance_history_tbl,
      ddx_party_history_tbl,
      ddx_account_history_tbl,
      ddx_org_unit_history_tbl,
      ddx_ins_asset_hist_tbl,
      ddx_ext_attrib_val_hist_tbl,
      ddx_version_label_hist_tbl,
      ddx_rel_history_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csi_datastructures_pub_w.rosetta_table_copy_out_p61(ddx_instance_history_tbl, p6_a0
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
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      , p6_a99
      , p6_a100
      , p6_a101
      , p6_a102
      , p6_a103
      , p6_a104
      , p6_a105
      , p6_a106
      , p6_a107
      , p6_a108
      , p6_a109
      , p6_a110
      , p6_a111
      , p6_a112
      , p6_a113
      , p6_a114
      , p6_a115
      , p6_a116
      , p6_a117
      , p6_a118
      , p6_a119
      , p6_a120
      , p6_a121
      , p6_a122
      , p6_a123
      , p6_a124
      , p6_a125
      , p6_a126
      , p6_a127
      , p6_a128
      , p6_a129
      , p6_a130
      , p6_a131
      , p6_a132
      , p6_a133
      , p6_a134
      , p6_a135
      , p6_a136
      , p6_a137
      , p6_a138
      , p6_a139
      , p6_a140
      , p6_a141
      , p6_a142
      , p6_a143
      , p6_a144
      , p6_a145
      , p6_a146
      , p6_a147
      , p6_a148
      , p6_a149
      , p6_a150
      , p6_a151
      , p6_a152
      , p6_a153
      , p6_a154
      , p6_a155
      , p6_a156
      , p6_a157
      , p6_a158
      , p6_a159
      , p6_a160
      , p6_a161
      , p6_a162
      , p6_a163
      , p6_a164
      , p6_a165
      , p6_a166
      , p6_a167
      , p6_a168
      , p6_a169
      , p6_a170
      , p6_a171
      , p6_a172
      , p6_a173
      , p6_a174
      , p6_a175
      , p6_a176
      , p6_a177
      , p6_a178
      , p6_a179
      , p6_a180
      , p6_a181
      , p6_a182
      , p6_a183
      , p6_a184
      , p6_a185
      , p6_a186
      , p6_a187
      , p6_a188
      , p6_a189
      , p6_a190
      , p6_a191
      , p6_a192
      , p6_a193
      , p6_a194
      , p6_a195
      , p6_a196
      , p6_a197
      , p6_a198
      , p6_a199
      , p6_a200
      , p6_a201
      , p6_a202
      , p6_a203
      , p6_a204
      , p6_a205
      , p6_a206
      , p6_a207
      , p6_a208
      , p6_a209
      , p6_a210
      , p6_a211
      , p6_a212
      , p6_a213
      , p6_a214
      , p6_a215
      , p6_a216
      , p6_a217
      , p6_a218
      , p6_a219
      , p6_a220
      , p6_a221
      , p6_a222
      , p6_a223
      , p6_a224
      , p6_a225
      , p6_a226
      , p6_a227
      , p6_a228
      , p6_a229
      , p6_a230
      , p6_a231
      , p6_a232
      , p6_a233
      , p6_a234
      , p6_a235
      , p6_a236
      , p6_a237
      , p6_a238
      , p6_a239
      , p6_a240
      , p6_a241
      , p6_a242
      , p6_a243
      , p6_a244
      , p6_a245
      , p6_a246
      , p6_a247
      , p6_a248
      , p6_a249
      , p6_a250
      , p6_a251
      , p6_a252
      , p6_a253
      , p6_a254
      , p6_a255
      , p6_a256
      , p6_a257
      , p6_a258
      , p6_a259
      , p6_a260
      , p6_a261
      , p6_a262
      , p6_a263
      , p6_a264
      , p6_a265
      , p6_a266
      , p6_a267
      , p6_a268
      , p6_a269
      , p6_a270
      , p6_a271
      , p6_a272
      , p6_a273
      , p6_a274
      , p6_a275
      , p6_a276
      , p6_a277
      , p6_a278
      , p6_a279
      , p6_a280
      , p6_a281
      , p6_a282
      , p6_a283
      , p6_a284
      , p6_a285
      , p6_a286
      , p6_a287
      , p6_a288
      , p6_a289
      , p6_a290
      , p6_a291
      , p6_a292
      , p6_a293
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p67(ddx_party_history_tbl, p7_a0
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
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p69(ddx_account_history_tbl, p8_a0
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
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p71(ddx_org_unit_history_tbl, p9_a0
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
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p63(ddx_ins_asset_hist_tbl, p10_a0
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
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p65(ddx_ext_attrib_val_hist_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p73(ddx_version_label_hist_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      , p12_a35
      , p12_a36
      , p12_a37
      , p12_a38
      , p12_a39
      , p12_a40
      , p12_a41
      , p12_a42
      , p12_a43
      , p12_a44
      , p12_a45
      , p12_a46
      , p12_a47
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p34(ddx_rel_history_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      , p13_a27
      , p13_a28
      , p13_a29
      , p13_a30
      , p13_a31
      , p13_a32
      , p13_a33
      , p13_a34
      , p13_a35
      , p13_a36
      , p13_a37
      , p13_a38
      , p13_a39
      , p13_a40
      , p13_a41
      , p13_a42
      , p13_a43
      , p13_a44
      , p13_a45
      , p13_a46
      , p13_a47
      , p13_a48
      , p13_a49
      , p13_a50
      , p13_a51
      , p13_a52
      , p13_a53
      );



  end;

  procedure get_instance_link_locations(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_instance_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_instance_link_rec csi_datastructures_pub.instance_link_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.get_instance_link_locations(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_instance_id,
      ddx_instance_link_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddx_instance_link_rec.instance_id);
    p5_a1 := ddx_instance_link_rec.start_loc_address1;
    p5_a2 := ddx_instance_link_rec.start_loc_address2;
    p5_a3 := ddx_instance_link_rec.start_loc_address3;
    p5_a4 := ddx_instance_link_rec.start_loc_address4;
    p5_a5 := ddx_instance_link_rec.start_loc_city;
    p5_a6 := ddx_instance_link_rec.start_loc_state;
    p5_a7 := ddx_instance_link_rec.start_loc_postal_code;
    p5_a8 := ddx_instance_link_rec.start_loc_country;
    p5_a9 := ddx_instance_link_rec.end_loc_address1;
    p5_a10 := ddx_instance_link_rec.end_loc_address2;
    p5_a11 := ddx_instance_link_rec.end_loc_address3;
    p5_a12 := ddx_instance_link_rec.end_loc_address4;
    p5_a13 := ddx_instance_link_rec.end_loc_city;
    p5_a14 := ddx_instance_link_rec.end_loc_state;
    p5_a15 := ddx_instance_link_rec.end_loc_postal_code;
    p5_a16 := ddx_instance_link_rec.end_loc_country;



  end;

  procedure get_contact_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_contact_party_id  NUMBER
    , p_contact_flag  VARCHAR2
    , p_party_tbl  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_contact_details csi_datastructures_pub.contact_details_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.get_contact_details(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_contact_party_id,
      p_contact_flag,
      p_party_tbl,
      ddx_contact_details,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_contact_details.contact_party_id);
    p7_a1 := ddx_contact_details.party_name;
    p7_a2 := ddx_contact_details.address1;
    p7_a3 := ddx_contact_details.address2;
    p7_a4 := ddx_contact_details.address3;
    p7_a5 := ddx_contact_details.address4;
    p7_a6 := ddx_contact_details.city;
    p7_a7 := ddx_contact_details.state;
    p7_a8 := ddx_contact_details.postal_code;
    p7_a9 := ddx_contact_details.country;
    p7_a10 := ddx_contact_details.email;
    p7_a11 := ddx_contact_details.fax;
    p7_a12 := ddx_contact_details.mobile;
    p7_a13 := ddx_contact_details.page;
    p7_a14 := ddx_contact_details.officephone;
    p7_a15 := ddx_contact_details.homephone;



  end;

  procedure bld_instance_all_parents_tbl(p_subject_id  NUMBER
    , p_relationship_type_code  VARCHAR2
    , p_time_stamp  date
  )

  as
    ddp_time_stamp date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);

    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.bld_instance_all_parents_tbl(p_subject_id,
      p_relationship_type_code,
      ddp_time_stamp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  function get_instance_all_parents(p_subject_id  NUMBER
    , p_time_stamp  date
  ) return varchar2

  as
    ddp_time_stamp date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csi_java_interface_pkg.get_instance_all_parents(p_subject_id,
      ddp_time_stamp);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  procedure expire_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_subject_id  NUMBER
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
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_id_lst csi_datastructures_pub.id_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





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





    -- here's the delegated call to the old PL/SQL routine
    csi_java_interface_pkg.expire_relationship(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_subject_id,
      ddp_txn_rec,
      ddx_instance_id_lst,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





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

    csi_datastructures_pub_w.rosetta_table_copy_out_p15(ddx_instance_id_lst, x_instance_id_lst);



  end;

  function get_instance_ids(p0_a0 in out nocopy JTF_NUMBER_TABLE
  ) return varchar2

  as
    ddp_instance_tbl csi_java_interface_pkg.dpl_instance_tbl;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_java_interface_pkg_w.rosetta_table_copy_in_p5(ddp_instance_tbl, p0_a0
      );

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csi_java_interface_pkg.get_instance_ids(ddp_instance_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_java_interface_pkg_w.rosetta_table_copy_out_p5(ddp_instance_tbl, p0_a0
      );

    return ddrosetta_retval;
  end;

end csi_java_interface_pkg_w;

/
