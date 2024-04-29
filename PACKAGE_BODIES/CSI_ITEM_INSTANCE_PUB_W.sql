--------------------------------------------------------
--  DDL for Package Body CSI_ITEM_INSTANCE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ITEM_INSTANCE_PUB_W" as
  /* $Header: csipiiwb.pls 120.18.12010000.2 2009/05/22 20:04:40 hyonlee ship $ */
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

  procedure rosetta_table_copy_in_p14(t out nocopy csi_item_instance_pub.txn_oks_type_tbl, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t csi_item_instance_pub.txn_oks_type_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p14;

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
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_DATE_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 in out nocopy JTF_NUMBER_TABLE
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_NUMBER_TABLE
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_DATE_TABLE
    , p8_a3 in out nocopy JTF_DATE_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a121 in out nocopy JTF_NUMBER_TABLE
    , p8_a122 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_DATE_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_party_tbl csi_datastructures_pub.party_tbl;
    ddp_account_tbl csi_datastructures_pub.party_account_tbl;
    ddp_pricing_attrib_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_org_assignments_tbl csi_datastructures_pub.organization_units_tbl;
    ddp_asset_assignment_tbl csi_datastructures_pub.instance_asset_tbl;
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

    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_values_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p9(ddp_party_tbl, p6_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p6(ddp_account_tbl, p7_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p46(ddp_pricing_attrib_tbl, p8_a0
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
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      , p8_a99
      , p8_a100
      , p8_a101
      , p8_a102
      , p8_a103
      , p8_a104
      , p8_a105
      , p8_a106
      , p8_a107
      , p8_a108
      , p8_a109
      , p8_a110
      , p8_a111
      , p8_a112
      , p8_a113
      , p8_a114
      , p8_a115
      , p8_a116
      , p8_a117
      , p8_a118
      , p8_a119
      , p8_a120
      , p8_a121
      , p8_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p49(ddp_org_assignments_tbl, p9_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p52(ddp_asset_assignment_tbl, p10_a0
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
      );

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
    csi_item_instance_pub.create_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_rec,
      ddp_ext_attrib_values_tbl,
      ddp_party_tbl,
      ddp_account_tbl,
      ddp_pricing_attrib_tbl,
      ddp_org_assignments_tbl,
      ddp_asset_assignment_tbl,
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

    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddp_ext_attrib_values_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p9(ddp_party_tbl, p6_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p6(ddp_account_tbl, p7_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p46(ddp_pricing_attrib_tbl, p8_a0
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
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      , p8_a99
      , p8_a100
      , p8_a101
      , p8_a102
      , p8_a103
      , p8_a104
      , p8_a105
      , p8_a106
      , p8_a107
      , p8_a108
      , p8_a109
      , p8_a110
      , p8_a111
      , p8_a112
      , p8_a113
      , p8_a114
      , p8_a115
      , p8_a116
      , p8_a117
      , p8_a118
      , p8_a119
      , p8_a120
      , p8_a121
      , p8_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p49(ddp_org_assignments_tbl, p9_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddp_asset_assignment_tbl, p10_a0
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
      );

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



  end;

  procedure update_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_DATE_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 in out nocopy JTF_NUMBER_TABLE
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_NUMBER_TABLE
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_DATE_TABLE
    , p8_a3 in out nocopy JTF_DATE_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a121 in out nocopy JTF_NUMBER_TABLE
    , p8_a122 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_DATE_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
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
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_party_tbl csi_datastructures_pub.party_tbl;
    ddp_account_tbl csi_datastructures_pub.party_account_tbl;
    ddp_pricing_attrib_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_org_assignments_tbl csi_datastructures_pub.organization_units_tbl;
    ddp_asset_assignment_tbl csi_datastructures_pub.instance_asset_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_id_lst csi_datastructures_pub.id_tbl;
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

    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_values_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p9(ddp_party_tbl, p6_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p6(ddp_account_tbl, p7_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p46(ddp_pricing_attrib_tbl, p8_a0
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
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      , p8_a99
      , p8_a100
      , p8_a101
      , p8_a102
      , p8_a103
      , p8_a104
      , p8_a105
      , p8_a106
      , p8_a107
      , p8_a108
      , p8_a109
      , p8_a110
      , p8_a111
      , p8_a112
      , p8_a113
      , p8_a114
      , p8_a115
      , p8_a116
      , p8_a117
      , p8_a118
      , p8_a119
      , p8_a120
      , p8_a121
      , p8_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p49(ddp_org_assignments_tbl, p9_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p52(ddp_asset_assignment_tbl, p10_a0
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
      );

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
    csi_item_instance_pub.update_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_rec,
      ddp_ext_attrib_values_tbl,
      ddp_party_tbl,
      ddp_account_tbl,
      ddp_pricing_attrib_tbl,
      ddp_org_assignments_tbl,
      ddp_asset_assignment_tbl,
      ddp_txn_rec,
      ddx_instance_id_lst,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddp_ext_attrib_values_tbl, p5_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p9(ddp_party_tbl, p6_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p6(ddp_account_tbl, p7_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p46(ddp_pricing_attrib_tbl, p8_a0
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
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      , p8_a99
      , p8_a100
      , p8_a101
      , p8_a102
      , p8_a103
      , p8_a104
      , p8_a105
      , p8_a106
      , p8_a107
      , p8_a108
      , p8_a109
      , p8_a110
      , p8_a111
      , p8_a112
      , p8_a113
      , p8_a114
      , p8_a115
      , p8_a116
      , p8_a117
      , p8_a118
      , p8_a119
      , p8_a120
      , p8_a121
      , p8_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p49(ddp_org_assignments_tbl, p9_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddp_asset_assignment_tbl, p10_a0
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
      );

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

    csi_datastructures_pub_w.rosetta_table_copy_out_p15(ddx_instance_id_lst, x_instance_id_lst);



  end;

  procedure expire_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_expire_children  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  DATE
    , p6_a2 in out nocopy  DATE
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  NUMBER
    , p6_a12 in out nocopy  NUMBER
    , p6_a13 in out nocopy  NUMBER
    , p6_a14 in out nocopy  NUMBER
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  NUMBER
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  NUMBER
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  VARCHAR2
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p6_a26 in out nocopy  VARCHAR2
    , p6_a27 in out nocopy  VARCHAR2
    , p6_a28 in out nocopy  VARCHAR2
    , p6_a29 in out nocopy  VARCHAR2
    , p6_a30 in out nocopy  VARCHAR2
    , p6_a31 in out nocopy  VARCHAR2
    , p6_a32 in out nocopy  VARCHAR2
    , p6_a33 in out nocopy  VARCHAR2
    , p6_a34 in out nocopy  VARCHAR2
    , p6_a35 in out nocopy  VARCHAR2
    , p6_a36 in out nocopy  NUMBER
    , p6_a37 in out nocopy  VARCHAR2
    , p6_a38 in out nocopy  DATE
    , p6_a39 in out nocopy  NUMBER
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
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
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_id_lst csi_datastructures_pub.id_tbl;
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


    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p6_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p6_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p6_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p6_a5);
    ddp_txn_rec.source_group_ref := p6_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p6_a7);
    ddp_txn_rec.source_header_ref := p6_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p6_a9);
    ddp_txn_rec.source_line_ref := p6_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p6_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p6_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p6_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p6_a14);
    ddp_txn_rec.transaction_uom_code := p6_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p6_a16);
    ddp_txn_rec.transaction_status_code := p6_a17;
    ddp_txn_rec.transaction_action_code := p6_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p6_a19);
    ddp_txn_rec.context := p6_a20;
    ddp_txn_rec.attribute1 := p6_a21;
    ddp_txn_rec.attribute2 := p6_a22;
    ddp_txn_rec.attribute3 := p6_a23;
    ddp_txn_rec.attribute4 := p6_a24;
    ddp_txn_rec.attribute5 := p6_a25;
    ddp_txn_rec.attribute6 := p6_a26;
    ddp_txn_rec.attribute7 := p6_a27;
    ddp_txn_rec.attribute8 := p6_a28;
    ddp_txn_rec.attribute9 := p6_a29;
    ddp_txn_rec.attribute10 := p6_a30;
    ddp_txn_rec.attribute11 := p6_a31;
    ddp_txn_rec.attribute12 := p6_a32;
    ddp_txn_rec.attribute13 := p6_a33;
    ddp_txn_rec.attribute14 := p6_a34;
    ddp_txn_rec.attribute15 := p6_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p6_a36);
    ddp_txn_rec.split_reason_code := p6_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p6_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.expire_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_rec,
      p_expire_children,
      ddp_txn_rec,
      ddx_instance_id_lst,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p6_a1 := ddp_txn_rec.transaction_date;
    p6_a2 := ddp_txn_rec.source_transaction_date;
    p6_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p6_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p6_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p6_a6 := ddp_txn_rec.source_group_ref;
    p6_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p6_a8 := ddp_txn_rec.source_header_ref;
    p6_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p6_a10 := ddp_txn_rec.source_line_ref;
    p6_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p6_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p6_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p6_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p6_a15 := ddp_txn_rec.transaction_uom_code;
    p6_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p6_a17 := ddp_txn_rec.transaction_status_code;
    p6_a18 := ddp_txn_rec.transaction_action_code;
    p6_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p6_a20 := ddp_txn_rec.context;
    p6_a21 := ddp_txn_rec.attribute1;
    p6_a22 := ddp_txn_rec.attribute2;
    p6_a23 := ddp_txn_rec.attribute3;
    p6_a24 := ddp_txn_rec.attribute4;
    p6_a25 := ddp_txn_rec.attribute5;
    p6_a26 := ddp_txn_rec.attribute6;
    p6_a27 := ddp_txn_rec.attribute7;
    p6_a28 := ddp_txn_rec.attribute8;
    p6_a29 := ddp_txn_rec.attribute9;
    p6_a30 := ddp_txn_rec.attribute10;
    p6_a31 := ddp_txn_rec.attribute11;
    p6_a32 := ddp_txn_rec.attribute12;
    p6_a33 := ddp_txn_rec.attribute13;
    p6_a34 := ddp_txn_rec.attribute14;
    p6_a35 := ddp_txn_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p6_a37 := ddp_txn_rec.split_reason_code;
    p6_a38 := ddp_txn_rec.src_txn_creation_date;
    p6_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p15(ddx_instance_id_lst, x_instance_id_lst);



  end;

  procedure get_item_instances(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p_resolve_id_columns  VARCHAR2
    , p_active_instance_only  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a25 out nocopy JTF_DATE_TABLE
    , p10_a26 out nocopy JTF_DATE_TABLE
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p10_a33 out nocopy JTF_NUMBER_TABLE
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_NUMBER_TABLE
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_NUMBER_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_NUMBER_TABLE
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_DATE_TABLE
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a75 out nocopy JTF_NUMBER_TABLE
    , p10_a76 out nocopy JTF_NUMBER_TABLE
    , p10_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a90 out nocopy JTF_DATE_TABLE
    , p10_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a99 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a100 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a101 out nocopy JTF_NUMBER_TABLE
    , p10_a102 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a103 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a104 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a106 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a107 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a108 out nocopy JTF_NUMBER_TABLE
    , p10_a109 out nocopy JTF_NUMBER_TABLE
    , p10_a110 out nocopy JTF_NUMBER_TABLE
    , p10_a111 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a118 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a120 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a125 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a126 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a127 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a128 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a129 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a130 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a131 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a134 out nocopy JTF_NUMBER_TABLE
    , p10_a135 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a136 out nocopy JTF_NUMBER_TABLE
    , p10_a137 out nocopy JTF_NUMBER_TABLE
    , p10_a138 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a139 out nocopy JTF_NUMBER_TABLE
    , p10_a140 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a141 out nocopy JTF_NUMBER_TABLE
    , p10_a142 out nocopy JTF_DATE_TABLE
    , p10_a143 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a144 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a145 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a146 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a147 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a148 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a149 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a150 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a151 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a152 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a153 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a154 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a155 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a156 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a157 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a158 out nocopy JTF_NUMBER_TABLE
    , p10_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a160 out nocopy JTF_NUMBER_TABLE
    , p10_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a162 out nocopy JTF_NUMBER_TABLE
    , p10_a163 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a167 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a170 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a171 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a172 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a174 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a175 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a177 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  DATE := fnd_api.g_miss_date
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  DATE := fnd_api.g_miss_date
    , p4_a32  DATE := fnd_api.g_miss_date
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_instance_query_rec csi_datastructures_pub.instance_query_rec;
    ddp_party_query_rec csi_datastructures_pub.party_query_rec;
    ddp_account_query_rec csi_datastructures_pub.party_account_query_rec;
    ddx_instance_header_tbl csi_datastructures_pub.instance_header_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_query_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_query_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a1);
    ddp_instance_query_rec.inventory_revision := p4_a2;
    ddp_instance_query_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a3);
    ddp_instance_query_rec.serial_number := p4_a4;
    ddp_instance_query_rec.lot_number := p4_a5;
    ddp_instance_query_rec.unit_of_measure := p4_a6;
    ddp_instance_query_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a7);
    ddp_instance_query_rec.instance_status_id := rosetta_g_miss_num_map(p4_a8);
    ddp_instance_query_rec.system_id := rosetta_g_miss_num_map(p4_a9);
    ddp_instance_query_rec.instance_type_code := p4_a10;
    ddp_instance_query_rec.location_type_code := p4_a11;
    ddp_instance_query_rec.location_id := rosetta_g_miss_num_map(p4_a12);
    ddp_instance_query_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a13);
    ddp_instance_query_rec.inv_subinventory_name := p4_a14;
    ddp_instance_query_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a15);
    ddp_instance_query_rec.pa_project_id := rosetta_g_miss_num_map(p4_a16);
    ddp_instance_query_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a17);
    ddp_instance_query_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a18);
    ddp_instance_query_rec.wip_job_id := rosetta_g_miss_num_map(p4_a19);
    ddp_instance_query_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a20);
    ddp_instance_query_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a21);
    ddp_instance_query_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a22);
    ddp_instance_query_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a23);
    ddp_instance_query_rec.last_oe_po_number := p4_a24;
    ddp_instance_query_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a25);
    ddp_instance_query_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a26);
    ddp_instance_query_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a27);
    ddp_instance_query_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a28);
    ddp_instance_query_rec.install_date := rosetta_g_miss_date_in_map(p4_a29);
    ddp_instance_query_rec.manually_created_flag := p4_a30;
    ddp_instance_query_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a31);
    ddp_instance_query_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a32);
    ddp_instance_query_rec.instance_usage_code := p4_a33;
    ddp_instance_query_rec.query_units_only := p4_a34;
    ddp_instance_query_rec.contract_number := p4_a35;
    ddp_instance_query_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a36);
    ddp_instance_query_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a37);
    ddp_instance_query_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a38);
    ddp_instance_query_rec.instance_description := p4_a39;
    ddp_instance_query_rec.operational_status_code := p4_a40;

    ddp_party_query_rec.instance_party_id := rosetta_g_miss_num_map(p5_a0);
    ddp_party_query_rec.instance_id := rosetta_g_miss_num_map(p5_a1);
    ddp_party_query_rec.party_id := rosetta_g_miss_num_map(p5_a2);
    ddp_party_query_rec.relationship_type_code := p5_a3;

    ddp_account_query_rec.ip_account_id := rosetta_g_miss_num_map(p6_a0);
    ddp_account_query_rec.instance_party_id := rosetta_g_miss_num_map(p6_a1);
    ddp_account_query_rec.party_account_id := rosetta_g_miss_num_map(p6_a2);
    ddp_account_query_rec.relationship_type_code := p6_a3;








    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.get_item_instances(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_query_rec,
      ddp_party_query_rec,
      ddp_account_query_rec,
      p_transaction_id,
      p_resolve_id_columns,
      p_active_instance_only,
      ddx_instance_header_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    csi_datastructures_pub_w.rosetta_table_copy_out_p22(ddx_instance_header_tbl, p10_a0
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
      , p10_a56
      , p10_a57
      , p10_a58
      , p10_a59
      , p10_a60
      , p10_a61
      , p10_a62
      , p10_a63
      , p10_a64
      , p10_a65
      , p10_a66
      , p10_a67
      , p10_a68
      , p10_a69
      , p10_a70
      , p10_a71
      , p10_a72
      , p10_a73
      , p10_a74
      , p10_a75
      , p10_a76
      , p10_a77
      , p10_a78
      , p10_a79
      , p10_a80
      , p10_a81
      , p10_a82
      , p10_a83
      , p10_a84
      , p10_a85
      , p10_a86
      , p10_a87
      , p10_a88
      , p10_a89
      , p10_a90
      , p10_a91
      , p10_a92
      , p10_a93
      , p10_a94
      , p10_a95
      , p10_a96
      , p10_a97
      , p10_a98
      , p10_a99
      , p10_a100
      , p10_a101
      , p10_a102
      , p10_a103
      , p10_a104
      , p10_a105
      , p10_a106
      , p10_a107
      , p10_a108
      , p10_a109
      , p10_a110
      , p10_a111
      , p10_a112
      , p10_a113
      , p10_a114
      , p10_a115
      , p10_a116
      , p10_a117
      , p10_a118
      , p10_a119
      , p10_a120
      , p10_a121
      , p10_a122
      , p10_a123
      , p10_a124
      , p10_a125
      , p10_a126
      , p10_a127
      , p10_a128
      , p10_a129
      , p10_a130
      , p10_a131
      , p10_a132
      , p10_a133
      , p10_a134
      , p10_a135
      , p10_a136
      , p10_a137
      , p10_a138
      , p10_a139
      , p10_a140
      , p10_a141
      , p10_a142
      , p10_a143
      , p10_a144
      , p10_a145
      , p10_a146
      , p10_a147
      , p10_a148
      , p10_a149
      , p10_a150
      , p10_a151
      , p10_a152
      , p10_a153
      , p10_a154
      , p10_a155
      , p10_a156
      , p10_a157
      , p10_a158
      , p10_a159
      , p10_a160
      , p10_a161
      , p10_a162
      , p10_a163
      , p10_a164
      , p10_a165
      , p10_a166
      , p10_a167
      , p10_a168
      , p10_a169
      , p10_a170
      , p10_a171
      , p10_a172
      , p10_a173
      , p10_a174
      , p10_a175
      , p10_a176
      , p10_a177
      );



  end;

  procedure get_item_instance_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  NUMBER
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  DATE
    , p4_a26 in out nocopy  DATE
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  NUMBER
    , p4_a42 in out nocopy  NUMBER
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  NUMBER
    , p4_a45 in out nocopy  NUMBER
    , p4_a46 in out nocopy  NUMBER
    , p4_a47 in out nocopy  NUMBER
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  NUMBER
    , p4_a50 in out nocopy  NUMBER
    , p4_a51 in out nocopy  NUMBER
    , p4_a52 in out nocopy  NUMBER
    , p4_a53 in out nocopy  DATE
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  DATE
    , p4_a56 in out nocopy  DATE
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  VARCHAR2
    , p4_a65 in out nocopy  VARCHAR2
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  VARCHAR2
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  VARCHAR2
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  VARCHAR2
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  NUMBER
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  VARCHAR2
    , p4_a81 in out nocopy  VARCHAR2
    , p4_a82 in out nocopy  VARCHAR2
    , p4_a83 in out nocopy  VARCHAR2
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  VARCHAR2
    , p4_a88 in out nocopy  NUMBER
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  DATE
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  VARCHAR2
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  VARCHAR2
    , p4_a95 in out nocopy  VARCHAR2
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  NUMBER
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  NUMBER
    , p4_a109 in out nocopy  NUMBER
    , p4_a110 in out nocopy  NUMBER
    , p4_a111 in out nocopy  VARCHAR2
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  VARCHAR2
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  VARCHAR2
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  VARCHAR2
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  VARCHAR2
    , p4_a121 in out nocopy  VARCHAR2
    , p4_a122 in out nocopy  VARCHAR2
    , p4_a123 in out nocopy  VARCHAR2
    , p4_a124 in out nocopy  VARCHAR2
    , p4_a125 in out nocopy  VARCHAR2
    , p4_a126 in out nocopy  VARCHAR2
    , p4_a127 in out nocopy  VARCHAR2
    , p4_a128 in out nocopy  VARCHAR2
    , p4_a129 in out nocopy  VARCHAR2
    , p4_a130 in out nocopy  VARCHAR2
    , p4_a131 in out nocopy  VARCHAR2
    , p4_a132 in out nocopy  VARCHAR2
    , p4_a133 in out nocopy  VARCHAR2
    , p4_a134 in out nocopy  NUMBER
    , p4_a135 in out nocopy  VARCHAR2
    , p4_a136 in out nocopy  NUMBER
    , p4_a137 in out nocopy  NUMBER
    , p4_a138 in out nocopy  VARCHAR2
    , p4_a139 in out nocopy  NUMBER
    , p4_a140 in out nocopy  VARCHAR2
    , p4_a141 in out nocopy  NUMBER
    , p4_a142 in out nocopy  DATE
    , p4_a143 in out nocopy  VARCHAR2
    , p4_a144 in out nocopy  VARCHAR2
    , p4_a145 in out nocopy  VARCHAR2
    , p4_a146 in out nocopy  VARCHAR2
    , p4_a147 in out nocopy  VARCHAR2
    , p4_a148 in out nocopy  VARCHAR2
    , p4_a149 in out nocopy  VARCHAR2
    , p4_a150 in out nocopy  VARCHAR2
    , p4_a151 in out nocopy  VARCHAR2
    , p4_a152 in out nocopy  VARCHAR2
    , p4_a153 in out nocopy  VARCHAR2
    , p4_a154 in out nocopy  VARCHAR2
    , p4_a155 in out nocopy  VARCHAR2
    , p4_a156 in out nocopy  VARCHAR2
    , p4_a157 in out nocopy  VARCHAR2
    , p4_a158 in out nocopy  NUMBER
    , p4_a159 in out nocopy  VARCHAR2
    , p4_a160 in out nocopy  NUMBER
    , p4_a161 in out nocopy  VARCHAR2
    , p4_a162 in out nocopy  NUMBER
    , p4_a163 in out nocopy  VARCHAR2
    , p4_a164 in out nocopy  VARCHAR2
    , p4_a165 in out nocopy  VARCHAR2
    , p4_a166 in out nocopy  VARCHAR2
    , p4_a167 in out nocopy  VARCHAR2
    , p4_a168 in out nocopy  VARCHAR2
    , p4_a169 in out nocopy  VARCHAR2
    , p4_a170 in out nocopy  VARCHAR2
    , p4_a171 in out nocopy  VARCHAR2
    , p4_a172 in out nocopy  VARCHAR2
    , p4_a173 in out nocopy  VARCHAR2
    , p4_a174 in out nocopy  VARCHAR2
    , p4_a175 in out nocopy  VARCHAR2
    , p4_a176 in out nocopy  VARCHAR2
    , p4_a177 in out nocopy  VARCHAR2
    , p_get_parties  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_accounts  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
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
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_org_assignments  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_DATE_TABLE
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_pricing_attribs  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_DATE_TABLE
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_300
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
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a71 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a72 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a73 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a74 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a75 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a76 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a77 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a78 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a79 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a80 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a81 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a82 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a83 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a84 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a87 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a89 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a90 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a91 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a92 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a93 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a94 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a95 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a96 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a97 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a99 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a100 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a101 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a102 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a103 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a104 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a106 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a107 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a108 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a109 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a110 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a111 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a112 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a113 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a114 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a115 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a116 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a117 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a118 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a119 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a120 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a121 out nocopy JTF_NUMBER_TABLE
    , p12_a122 out nocopy JTF_NUMBER_TABLE
    , p_get_ext_attribs  VARCHAR2
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a5 out nocopy JTF_DATE_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_NUMBER_TABLE
    , p15_a4 out nocopy JTF_NUMBER_TABLE
    , p15_a5 out nocopy JTF_NUMBER_TABLE
    , p15_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a10 out nocopy JTF_DATE_TABLE
    , p15_a11 out nocopy JTF_DATE_TABLE
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a28 out nocopy JTF_NUMBER_TABLE
    , p_get_asset_assignments  VARCHAR2
    , p17_a0 out nocopy JTF_NUMBER_TABLE
    , p17_a1 out nocopy JTF_NUMBER_TABLE
    , p17_a2 out nocopy JTF_NUMBER_TABLE
    , p17_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a4 out nocopy JTF_NUMBER_TABLE
    , p17_a5 out nocopy JTF_NUMBER_TABLE
    , p17_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a7 out nocopy JTF_DATE_TABLE
    , p17_a8 out nocopy JTF_DATE_TABLE
    , p17_a9 out nocopy JTF_NUMBER_TABLE
    , p17_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a21 out nocopy JTF_DATE_TABLE
    , p17_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p17_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a25 out nocopy JTF_NUMBER_TABLE
    , p17_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p_resolve_id_columns  VARCHAR2
    , p_time_stamp  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_instance_rec csi_datastructures_pub.instance_header_rec;
    ddp_party_header_tbl csi_datastructures_pub.party_header_tbl;
    ddp_account_header_tbl csi_datastructures_pub.party_account_header_tbl;
    ddp_org_header_tbl csi_datastructures_pub.org_units_header_tbl;
    ddp_pricing_attrib_tbl csi_datastructures_pub.pricing_attribs_tbl;
    ddp_ext_attrib_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_ext_attrib_def_tbl csi_datastructures_pub.extend_attrib_tbl;
    ddp_asset_header_tbl csi_datastructures_pub.instance_asset_header_tbl;
    ddp_time_stamp date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_instance_rec.instance_id := rosetta_g_miss_num_map(p4_a0);
    ddp_instance_rec.instance_number := p4_a1;
    ddp_instance_rec.external_reference := p4_a2;
    ddp_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a3);
    ddp_instance_rec.inventory_revision := p4_a4;
    ddp_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p4_a5);
    ddp_instance_rec.serial_number := p4_a6;
    ddp_instance_rec.mfg_serial_number_flag := p4_a7;
    ddp_instance_rec.lot_number := p4_a8;
    ddp_instance_rec.quantity := rosetta_g_miss_num_map(p4_a9);
    ddp_instance_rec.unit_of_measure_name := p4_a10;
    ddp_instance_rec.unit_of_measure := p4_a11;
    ddp_instance_rec.accounting_class := p4_a12;
    ddp_instance_rec.accounting_class_code := p4_a13;
    ddp_instance_rec.instance_condition := p4_a14;
    ddp_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p4_a15);
    ddp_instance_rec.instance_status := p4_a16;
    ddp_instance_rec.instance_status_id := rosetta_g_miss_num_map(p4_a17);
    ddp_instance_rec.customer_view_flag := p4_a18;
    ddp_instance_rec.merchant_view_flag := p4_a19;
    ddp_instance_rec.sellable_flag := p4_a20;
    ddp_instance_rec.system_id := rosetta_g_miss_num_map(p4_a21);
    ddp_instance_rec.system_name := p4_a22;
    ddp_instance_rec.instance_type_code := p4_a23;
    ddp_instance_rec.instance_type_name := p4_a24;
    ddp_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p4_a25);
    ddp_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p4_a26);
    ddp_instance_rec.location_type_code := p4_a27;
    ddp_instance_rec.location_id := rosetta_g_miss_num_map(p4_a28);
    ddp_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p4_a29);
    ddp_instance_rec.inv_organization_name := p4_a30;
    ddp_instance_rec.inv_subinventory_name := p4_a31;
    ddp_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p4_a32);
    ddp_instance_rec.pa_project_id := rosetta_g_miss_num_map(p4_a33);
    ddp_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p4_a34);
    ddp_instance_rec.pa_project_name := p4_a35;
    ddp_instance_rec.pa_project_number := p4_a36;
    ddp_instance_rec.pa_task_name := p4_a37;
    ddp_instance_rec.pa_task_number := p4_a38;
    ddp_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p4_a39);
    ddp_instance_rec.in_transit_order_line_number := rosetta_g_miss_num_map(p4_a40);
    ddp_instance_rec.in_transit_order_number := rosetta_g_miss_num_map(p4_a41);
    ddp_instance_rec.wip_job_id := rosetta_g_miss_num_map(p4_a42);
    ddp_instance_rec.wip_entity_name := p4_a43;
    ddp_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p4_a44);
    ddp_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p4_a45);
    ddp_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p4_a46);
    ddp_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p4_a47);
    ddp_instance_rec.last_oe_po_number := p4_a48;
    ddp_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p4_a49);
    ddp_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p4_a50);
    ddp_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p4_a51);
    ddp_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p4_a52);
    ddp_instance_rec.install_date := rosetta_g_miss_date_in_map(p4_a53);
    ddp_instance_rec.manually_created_flag := p4_a54;
    ddp_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p4_a55);
    ddp_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p4_a56);
    ddp_instance_rec.creation_complete_flag := p4_a57;
    ddp_instance_rec.completeness_flag := p4_a58;
    ddp_instance_rec.context := p4_a59;
    ddp_instance_rec.attribute1 := p4_a60;
    ddp_instance_rec.attribute2 := p4_a61;
    ddp_instance_rec.attribute3 := p4_a62;
    ddp_instance_rec.attribute4 := p4_a63;
    ddp_instance_rec.attribute5 := p4_a64;
    ddp_instance_rec.attribute6 := p4_a65;
    ddp_instance_rec.attribute7 := p4_a66;
    ddp_instance_rec.attribute8 := p4_a67;
    ddp_instance_rec.attribute9 := p4_a68;
    ddp_instance_rec.attribute10 := p4_a69;
    ddp_instance_rec.attribute11 := p4_a70;
    ddp_instance_rec.attribute12 := p4_a71;
    ddp_instance_rec.attribute13 := p4_a72;
    ddp_instance_rec.attribute14 := p4_a73;
    ddp_instance_rec.attribute15 := p4_a74;
    ddp_instance_rec.object_version_number := rosetta_g_miss_num_map(p4_a75);
    ddp_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p4_a76);
    ddp_instance_rec.install_location_type_code := p4_a77;
    ddp_instance_rec.install_location_id := rosetta_g_miss_num_map(p4_a78);
    ddp_instance_rec.instance_usage_code := p4_a79;
    ddp_instance_rec.current_loc_address1 := p4_a80;
    ddp_instance_rec.current_loc_address2 := p4_a81;
    ddp_instance_rec.current_loc_address3 := p4_a82;
    ddp_instance_rec.current_loc_address4 := p4_a83;
    ddp_instance_rec.current_loc_city := p4_a84;
    ddp_instance_rec.current_loc_state := p4_a85;
    ddp_instance_rec.current_loc_postal_code := p4_a86;
    ddp_instance_rec.current_loc_country := p4_a87;
    ddp_instance_rec.sales_order_number := rosetta_g_miss_num_map(p4_a88);
    ddp_instance_rec.sales_order_line_number := rosetta_g_miss_num_map(p4_a89);
    ddp_instance_rec.sales_order_date := rosetta_g_miss_date_in_map(p4_a90);
    ddp_instance_rec.purchase_order_number := p4_a91;
    ddp_instance_rec.instance_usage_name := p4_a92;
    ddp_instance_rec.install_loc_address1 := p4_a93;
    ddp_instance_rec.install_loc_address2 := p4_a94;
    ddp_instance_rec.install_loc_address3 := p4_a95;
    ddp_instance_rec.install_loc_address4 := p4_a96;
    ddp_instance_rec.install_loc_city := p4_a97;
    ddp_instance_rec.install_loc_state := p4_a98;
    ddp_instance_rec.install_loc_postal_code := p4_a99;
    ddp_instance_rec.install_loc_country := p4_a100;
    ddp_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p4_a101);
    ddp_instance_rec.current_loc_number := p4_a102;
    ddp_instance_rec.install_loc_number := p4_a103;
    ddp_instance_rec.current_party_name := p4_a104;
    ddp_instance_rec.current_party_number := p4_a105;
    ddp_instance_rec.install_party_name := p4_a106;
    ddp_instance_rec.install_party_number := p4_a107;
    ddp_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p4_a108);
    ddp_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p4_a109);
    ddp_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p4_a110);
    ddp_instance_rec.config_valid_status := p4_a111;
    ddp_instance_rec.instance_description := p4_a112;
    ddp_instance_rec.start_loc_address1 := p4_a113;
    ddp_instance_rec.start_loc_address2 := p4_a114;
    ddp_instance_rec.start_loc_address3 := p4_a115;
    ddp_instance_rec.start_loc_address4 := p4_a116;
    ddp_instance_rec.start_loc_city := p4_a117;
    ddp_instance_rec.start_loc_state := p4_a118;
    ddp_instance_rec.start_loc_postal_code := p4_a119;
    ddp_instance_rec.start_loc_country := p4_a120;
    ddp_instance_rec.end_loc_address1 := p4_a121;
    ddp_instance_rec.end_loc_address2 := p4_a122;
    ddp_instance_rec.end_loc_address3 := p4_a123;
    ddp_instance_rec.end_loc_address4 := p4_a124;
    ddp_instance_rec.end_loc_city := p4_a125;
    ddp_instance_rec.end_loc_state := p4_a126;
    ddp_instance_rec.end_loc_postal_code := p4_a127;
    ddp_instance_rec.end_loc_country := p4_a128;
    ddp_instance_rec.vld_organization_name := p4_a129;
    ddp_instance_rec.last_oe_agreement_name := p4_a130;
    ddp_instance_rec.inv_locator_name := p4_a131;
    ddp_instance_rec.network_asset_flag := p4_a132;
    ddp_instance_rec.maintainable_flag := p4_a133;
    ddp_instance_rec.pn_location_id := rosetta_g_miss_num_map(p4_a134);
    ddp_instance_rec.asset_criticality_code := p4_a135;
    ddp_instance_rec.category_id := rosetta_g_miss_num_map(p4_a136);
    ddp_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p4_a137);
    ddp_instance_rec.instantiation_flag := p4_a138;
    ddp_instance_rec.linear_location_id := rosetta_g_miss_num_map(p4_a139);
    ddp_instance_rec.operational_log_flag := p4_a140;
    ddp_instance_rec.checkin_status := rosetta_g_miss_num_map(p4_a141);
    ddp_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p4_a142);
    ddp_instance_rec.attribute16 := p4_a143;
    ddp_instance_rec.attribute17 := p4_a144;
    ddp_instance_rec.attribute18 := p4_a145;
    ddp_instance_rec.attribute19 := p4_a146;
    ddp_instance_rec.attribute20 := p4_a147;
    ddp_instance_rec.attribute21 := p4_a148;
    ddp_instance_rec.attribute22 := p4_a149;
    ddp_instance_rec.attribute23 := p4_a150;
    ddp_instance_rec.attribute24 := p4_a151;
    ddp_instance_rec.attribute25 := p4_a152;
    ddp_instance_rec.attribute26 := p4_a153;
    ddp_instance_rec.attribute27 := p4_a154;
    ddp_instance_rec.attribute28 := p4_a155;
    ddp_instance_rec.attribute29 := p4_a156;
    ddp_instance_rec.attribute30 := p4_a157;
    ddp_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p4_a158);
    ddp_instance_rec.purchase_currency_code := p4_a159;
    ddp_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p4_a160);
    ddp_instance_rec.payables_currency_code := p4_a161;
    ddp_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p4_a162);
    ddp_instance_rec.sales_currency_code := p4_a163;
    ddp_instance_rec.operational_status_code := p4_a164;
    ddp_instance_rec.operational_status_name := p4_a165;
    ddp_instance_rec.maintenance_organization := p4_a166;
    ddp_instance_rec.department := p4_a167;
    ddp_instance_rec.area := p4_a168;
    ddp_instance_rec.wip_accounting_class := p4_a169;
    ddp_instance_rec.parent_asset_group := p4_a170;
    ddp_instance_rec.criticality := p4_a171;
    ddp_instance_rec.category_name := p4_a172;
    ddp_instance_rec.parent_asset_number := p4_a173;
    ddp_instance_rec.maintainable := p4_a174;
    ddp_instance_rec.version_label := p4_a175;
    ddp_instance_rec.version_label_meaning := p4_a176;
    ddp_instance_rec.inventory_item_name := p4_a177;















    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);




    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.get_item_instance_details(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_instance_rec,
      p_get_parties,
      ddp_party_header_tbl,
      p_get_accounts,
      ddp_account_header_tbl,
      p_get_org_assignments,
      ddp_org_header_tbl,
      p_get_pricing_attribs,
      ddp_pricing_attrib_tbl,
      p_get_ext_attribs,
      ddp_ext_attrib_tbl,
      ddp_ext_attrib_def_tbl,
      p_get_asset_assignments,
      ddp_asset_header_tbl,
      p_resolve_id_columns,
      ddp_time_stamp,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddp_instance_rec.instance_id);
    p4_a1 := ddp_instance_rec.instance_number;
    p4_a2 := ddp_instance_rec.external_reference;
    p4_a3 := rosetta_g_miss_num_map(ddp_instance_rec.inventory_item_id);
    p4_a4 := ddp_instance_rec.inventory_revision;
    p4_a5 := rosetta_g_miss_num_map(ddp_instance_rec.inv_master_organization_id);
    p4_a6 := ddp_instance_rec.serial_number;
    p4_a7 := ddp_instance_rec.mfg_serial_number_flag;
    p4_a8 := ddp_instance_rec.lot_number;
    p4_a9 := rosetta_g_miss_num_map(ddp_instance_rec.quantity);
    p4_a10 := ddp_instance_rec.unit_of_measure_name;
    p4_a11 := ddp_instance_rec.unit_of_measure;
    p4_a12 := ddp_instance_rec.accounting_class;
    p4_a13 := ddp_instance_rec.accounting_class_code;
    p4_a14 := ddp_instance_rec.instance_condition;
    p4_a15 := rosetta_g_miss_num_map(ddp_instance_rec.instance_condition_id);
    p4_a16 := ddp_instance_rec.instance_status;
    p4_a17 := rosetta_g_miss_num_map(ddp_instance_rec.instance_status_id);
    p4_a18 := ddp_instance_rec.customer_view_flag;
    p4_a19 := ddp_instance_rec.merchant_view_flag;
    p4_a20 := ddp_instance_rec.sellable_flag;
    p4_a21 := rosetta_g_miss_num_map(ddp_instance_rec.system_id);
    p4_a22 := ddp_instance_rec.system_name;
    p4_a23 := ddp_instance_rec.instance_type_code;
    p4_a24 := ddp_instance_rec.instance_type_name;
    p4_a25 := ddp_instance_rec.active_start_date;
    p4_a26 := ddp_instance_rec.active_end_date;
    p4_a27 := ddp_instance_rec.location_type_code;
    p4_a28 := rosetta_g_miss_num_map(ddp_instance_rec.location_id);
    p4_a29 := rosetta_g_miss_num_map(ddp_instance_rec.inv_organization_id);
    p4_a30 := ddp_instance_rec.inv_organization_name;
    p4_a31 := ddp_instance_rec.inv_subinventory_name;
    p4_a32 := rosetta_g_miss_num_map(ddp_instance_rec.inv_locator_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_instance_rec.pa_project_id);
    p4_a34 := rosetta_g_miss_num_map(ddp_instance_rec.pa_project_task_id);
    p4_a35 := ddp_instance_rec.pa_project_name;
    p4_a36 := ddp_instance_rec.pa_project_number;
    p4_a37 := ddp_instance_rec.pa_task_name;
    p4_a38 := ddp_instance_rec.pa_task_number;
    p4_a39 := rosetta_g_miss_num_map(ddp_instance_rec.in_transit_order_line_id);
    p4_a40 := rosetta_g_miss_num_map(ddp_instance_rec.in_transit_order_line_number);
    p4_a41 := rosetta_g_miss_num_map(ddp_instance_rec.in_transit_order_number);
    p4_a42 := rosetta_g_miss_num_map(ddp_instance_rec.wip_job_id);
    p4_a43 := ddp_instance_rec.wip_entity_name;
    p4_a44 := rosetta_g_miss_num_map(ddp_instance_rec.po_order_line_id);
    p4_a45 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_order_line_id);
    p4_a46 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_rma_line_id);
    p4_a47 := rosetta_g_miss_num_map(ddp_instance_rec.last_po_po_line_id);
    p4_a48 := ddp_instance_rec.last_oe_po_number;
    p4_a49 := rosetta_g_miss_num_map(ddp_instance_rec.last_wip_job_id);
    p4_a50 := rosetta_g_miss_num_map(ddp_instance_rec.last_pa_project_id);
    p4_a51 := rosetta_g_miss_num_map(ddp_instance_rec.last_pa_task_id);
    p4_a52 := rosetta_g_miss_num_map(ddp_instance_rec.last_oe_agreement_id);
    p4_a53 := ddp_instance_rec.install_date;
    p4_a54 := ddp_instance_rec.manually_created_flag;
    p4_a55 := ddp_instance_rec.return_by_date;
    p4_a56 := ddp_instance_rec.actual_return_date;
    p4_a57 := ddp_instance_rec.creation_complete_flag;
    p4_a58 := ddp_instance_rec.completeness_flag;
    p4_a59 := ddp_instance_rec.context;
    p4_a60 := ddp_instance_rec.attribute1;
    p4_a61 := ddp_instance_rec.attribute2;
    p4_a62 := ddp_instance_rec.attribute3;
    p4_a63 := ddp_instance_rec.attribute4;
    p4_a64 := ddp_instance_rec.attribute5;
    p4_a65 := ddp_instance_rec.attribute6;
    p4_a66 := ddp_instance_rec.attribute7;
    p4_a67 := ddp_instance_rec.attribute8;
    p4_a68 := ddp_instance_rec.attribute9;
    p4_a69 := ddp_instance_rec.attribute10;
    p4_a70 := ddp_instance_rec.attribute11;
    p4_a71 := ddp_instance_rec.attribute12;
    p4_a72 := ddp_instance_rec.attribute13;
    p4_a73 := ddp_instance_rec.attribute14;
    p4_a74 := ddp_instance_rec.attribute15;
    p4_a75 := rosetta_g_miss_num_map(ddp_instance_rec.object_version_number);
    p4_a76 := rosetta_g_miss_num_map(ddp_instance_rec.last_txn_line_detail_id);
    p4_a77 := ddp_instance_rec.install_location_type_code;
    p4_a78 := rosetta_g_miss_num_map(ddp_instance_rec.install_location_id);
    p4_a79 := ddp_instance_rec.instance_usage_code;
    p4_a80 := ddp_instance_rec.current_loc_address1;
    p4_a81 := ddp_instance_rec.current_loc_address2;
    p4_a82 := ddp_instance_rec.current_loc_address3;
    p4_a83 := ddp_instance_rec.current_loc_address4;
    p4_a84 := ddp_instance_rec.current_loc_city;
    p4_a85 := ddp_instance_rec.current_loc_state;
    p4_a86 := ddp_instance_rec.current_loc_postal_code;
    p4_a87 := ddp_instance_rec.current_loc_country;
    p4_a88 := rosetta_g_miss_num_map(ddp_instance_rec.sales_order_number);
    p4_a89 := rosetta_g_miss_num_map(ddp_instance_rec.sales_order_line_number);
    p4_a90 := ddp_instance_rec.sales_order_date;
    p4_a91 := ddp_instance_rec.purchase_order_number;
    p4_a92 := ddp_instance_rec.instance_usage_name;
    p4_a93 := ddp_instance_rec.install_loc_address1;
    p4_a94 := ddp_instance_rec.install_loc_address2;
    p4_a95 := ddp_instance_rec.install_loc_address3;
    p4_a96 := ddp_instance_rec.install_loc_address4;
    p4_a97 := ddp_instance_rec.install_loc_city;
    p4_a98 := ddp_instance_rec.install_loc_state;
    p4_a99 := ddp_instance_rec.install_loc_postal_code;
    p4_a100 := ddp_instance_rec.install_loc_country;
    p4_a101 := rosetta_g_miss_num_map(ddp_instance_rec.vld_organization_id);
    p4_a102 := ddp_instance_rec.current_loc_number;
    p4_a103 := ddp_instance_rec.install_loc_number;
    p4_a104 := ddp_instance_rec.current_party_name;
    p4_a105 := ddp_instance_rec.current_party_number;
    p4_a106 := ddp_instance_rec.install_party_name;
    p4_a107 := ddp_instance_rec.install_party_number;
    p4_a108 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_hdr_id);
    p4_a109 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_rev_num);
    p4_a110 := rosetta_g_miss_num_map(ddp_instance_rec.config_inst_item_id);
    p4_a111 := ddp_instance_rec.config_valid_status;
    p4_a112 := ddp_instance_rec.instance_description;
    p4_a113 := ddp_instance_rec.start_loc_address1;
    p4_a114 := ddp_instance_rec.start_loc_address2;
    p4_a115 := ddp_instance_rec.start_loc_address3;
    p4_a116 := ddp_instance_rec.start_loc_address4;
    p4_a117 := ddp_instance_rec.start_loc_city;
    p4_a118 := ddp_instance_rec.start_loc_state;
    p4_a119 := ddp_instance_rec.start_loc_postal_code;
    p4_a120 := ddp_instance_rec.start_loc_country;
    p4_a121 := ddp_instance_rec.end_loc_address1;
    p4_a122 := ddp_instance_rec.end_loc_address2;
    p4_a123 := ddp_instance_rec.end_loc_address3;
    p4_a124 := ddp_instance_rec.end_loc_address4;
    p4_a125 := ddp_instance_rec.end_loc_city;
    p4_a126 := ddp_instance_rec.end_loc_state;
    p4_a127 := ddp_instance_rec.end_loc_postal_code;
    p4_a128 := ddp_instance_rec.end_loc_country;
    p4_a129 := ddp_instance_rec.vld_organization_name;
    p4_a130 := ddp_instance_rec.last_oe_agreement_name;
    p4_a131 := ddp_instance_rec.inv_locator_name;
    p4_a132 := ddp_instance_rec.network_asset_flag;
    p4_a133 := ddp_instance_rec.maintainable_flag;
    p4_a134 := rosetta_g_miss_num_map(ddp_instance_rec.pn_location_id);
    p4_a135 := ddp_instance_rec.asset_criticality_code;
    p4_a136 := rosetta_g_miss_num_map(ddp_instance_rec.category_id);
    p4_a137 := rosetta_g_miss_num_map(ddp_instance_rec.equipment_gen_object_id);
    p4_a138 := ddp_instance_rec.instantiation_flag;
    p4_a139 := rosetta_g_miss_num_map(ddp_instance_rec.linear_location_id);
    p4_a140 := ddp_instance_rec.operational_log_flag;
    p4_a141 := rosetta_g_miss_num_map(ddp_instance_rec.checkin_status);
    p4_a142 := ddp_instance_rec.supplier_warranty_exp_date;
    p4_a143 := ddp_instance_rec.attribute16;
    p4_a144 := ddp_instance_rec.attribute17;
    p4_a145 := ddp_instance_rec.attribute18;
    p4_a146 := ddp_instance_rec.attribute19;
    p4_a147 := ddp_instance_rec.attribute20;
    p4_a148 := ddp_instance_rec.attribute21;
    p4_a149 := ddp_instance_rec.attribute22;
    p4_a150 := ddp_instance_rec.attribute23;
    p4_a151 := ddp_instance_rec.attribute24;
    p4_a152 := ddp_instance_rec.attribute25;
    p4_a153 := ddp_instance_rec.attribute26;
    p4_a154 := ddp_instance_rec.attribute27;
    p4_a155 := ddp_instance_rec.attribute28;
    p4_a156 := ddp_instance_rec.attribute29;
    p4_a157 := ddp_instance_rec.attribute30;
    p4_a158 := rosetta_g_miss_num_map(ddp_instance_rec.purchase_unit_price);
    p4_a159 := ddp_instance_rec.purchase_currency_code;
    p4_a160 := rosetta_g_miss_num_map(ddp_instance_rec.payables_unit_price);
    p4_a161 := ddp_instance_rec.payables_currency_code;
    p4_a162 := rosetta_g_miss_num_map(ddp_instance_rec.sales_unit_price);
    p4_a163 := ddp_instance_rec.sales_currency_code;
    p4_a164 := ddp_instance_rec.operational_status_code;
    p4_a165 := ddp_instance_rec.operational_status_name;
    p4_a166 := ddp_instance_rec.maintenance_organization;
    p4_a167 := ddp_instance_rec.department;
    p4_a168 := ddp_instance_rec.area;
    p4_a169 := ddp_instance_rec.wip_accounting_class;
    p4_a170 := ddp_instance_rec.parent_asset_group;
    p4_a171 := ddp_instance_rec.criticality;
    p4_a172 := ddp_instance_rec.category_name;
    p4_a173 := ddp_instance_rec.parent_asset_number;
    p4_a174 := ddp_instance_rec.maintainable;
    p4_a175 := ddp_instance_rec.version_label;
    p4_a176 := ddp_instance_rec.version_label_meaning;
    p4_a177 := ddp_instance_rec.inventory_item_name;


    csi_datastructures_pub_w.rosetta_table_copy_out_p11(ddp_party_header_tbl, p6_a0
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
      );


    csi_datastructures_pub_w.rosetta_table_copy_out_p55(ddp_account_header_tbl, p8_a0
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
      );


    csi_datastructures_pub_w.rosetta_table_copy_out_p57(ddp_org_header_tbl, p10_a0
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
      );


    csi_datastructures_pub_w.rosetta_table_copy_out_p46(ddp_pricing_attrib_tbl, p12_a0
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


    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddp_ext_attrib_tbl, p14_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p41(ddp_ext_attrib_def_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      , p15_a27
      , p15_a28
      );


    csi_datastructures_pub_w.rosetta_table_copy_out_p59(ddp_asset_header_tbl, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      , p17_a9
      , p17_a10
      , p17_a11
      , p17_a12
      , p17_a13
      , p17_a14
      , p17_a15
      , p17_a16
      , p17_a17
      , p17_a18
      , p17_a19
      , p17_a20
      , p17_a21
      , p17_a22
      , p17_a23
      , p17_a24
      , p17_a25
      , p17_a26
      );





  end;

  procedure get_version_labels(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
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
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  DATE := fnd_api.g_miss_date
  )

  as
    ddp_version_label_query_rec csi_datastructures_pub.version_label_query_rec;
    ddp_time_stamp date;
    ddx_version_label_tbl csi_datastructures_pub.version_label_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_version_label_query_rec.version_label_id := rosetta_g_miss_num_map(p4_a0);
    ddp_version_label_query_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_version_label_query_rec.version_label := p4_a2;
    ddp_version_label_query_rec.date_time_stamp := rosetta_g_miss_date_in_map(p4_a3);

    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);





    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.get_version_labels(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_version_label_query_rec,
      ddp_time_stamp,
      ddx_version_label_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csi_datastructures_pub_w.rosetta_table_copy_out_p14(ddx_version_label_tbl, p6_a0
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
      );



  end;

  procedure create_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a4 in out nocopy JTF_DATE_TABLE
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
  )

  as
    ddp_version_label_tbl csi_datastructures_pub.version_label_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p14(ddp_version_label_tbl, p4_a0
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




    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.create_version_label(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_version_label_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p14(ddp_version_label_tbl, p4_a0
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



  end;

  procedure update_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_300
    , p4_a3 JTF_VARCHAR2_TABLE_300
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_NUMBER_TABLE
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
  )

  as
    ddp_version_label_tbl csi_datastructures_pub.version_label_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p14(ddp_version_label_tbl, p4_a0
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




    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.update_version_label(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_version_label_tbl,
      ddp_txn_rec,
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



  end;

  procedure expire_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_300
    , p4_a3 JTF_VARCHAR2_TABLE_300
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_NUMBER_TABLE
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
  )

  as
    ddp_version_label_tbl csi_datastructures_pub.version_label_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p14(ddp_version_label_tbl, p4_a0
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




    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.expire_version_label(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_version_label_tbl,
      ddp_txn_rec,
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



  end;

  procedure get_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
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
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
  )

  as
    ddp_ext_attribs_query_rec csi_datastructures_pub.extend_attrib_query_rec;
    ddp_time_stamp date;
    ddx_ext_attrib_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddx_ext_attrib_def_tbl csi_datastructures_pub.extend_attrib_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ext_attribs_query_rec.attribute_value_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ext_attribs_query_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ext_attribs_query_rec.attribute_id := rosetta_g_miss_num_map(p4_a2);

    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);






    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.get_extended_attrib_values(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ext_attribs_query_rec,
      ddp_time_stamp,
      ddx_ext_attrib_tbl,
      ddx_ext_attrib_def_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddx_ext_attrib_tbl, p6_a0
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
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p41(ddx_ext_attrib_def_tbl, p7_a0
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
      );



  end;

  procedure create_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
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
  )

  as
    ddp_ext_attrib_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_tbl, p4_a0
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
    csi_item_instance_pub.create_extended_attrib_values(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ext_attrib_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p43(ddp_ext_attrib_tbl, p4_a0
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



  end;

  procedure update_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_300
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
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
  )

  as
    ddp_ext_attrib_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_tbl, p4_a0
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
    csi_item_instance_pub.update_extended_attrib_values(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ext_attrib_tbl,
      ddp_txn_rec,
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



  end;

  procedure expire_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_300
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
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
  )

  as
    ddp_ext_attrib_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p43(ddp_ext_attrib_tbl, p4_a0
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
    csi_item_instance_pub.expire_extended_attrib_values(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ext_attrib_tbl,
      ddp_txn_rec,
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



  end;

  procedure copy_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_party_contacts  VARCHAR2
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
    csi_item_instance_pub.copy_item_instance(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_source_instance_rec,
      p_copy_ext_attribs,
      p_copy_org_assignments,
      p_copy_parties,
      p_copy_party_contacts,
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

  procedure get_oks_txn_types(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_check_contracts_yn  VARCHAR2
    , p_txn_type  VARCHAR2
    , x_txn_type_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_configflag out nocopy  VARCHAR2
    , px_txn_date in out nocopy  date
    , x_imp_contracts_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  DATE := fnd_api.g_miss_date
    , p3_a21  DATE := fnd_api.g_miss_date
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  NUMBER := 0-1962.0724
    , p3_a24  NUMBER := 0-1962.0724
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  NUMBER := 0-1962.0724
    , p3_a27  NUMBER := 0-1962.0724
    , p3_a28  NUMBER := 0-1962.0724
    , p3_a29  NUMBER := 0-1962.0724
    , p3_a30  NUMBER := 0-1962.0724
    , p3_a31  NUMBER := 0-1962.0724
    , p3_a32  NUMBER := 0-1962.0724
    , p3_a33  NUMBER := 0-1962.0724
    , p3_a34  NUMBER := 0-1962.0724
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  NUMBER := 0-1962.0724
    , p3_a37  NUMBER := 0-1962.0724
    , p3_a38  NUMBER := 0-1962.0724
    , p3_a39  NUMBER := 0-1962.0724
    , p3_a40  DATE := fnd_api.g_miss_date
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
    , p3_a42  DATE := fnd_api.g_miss_date
    , p3_a43  DATE := fnd_api.g_miss_date
    , p3_a44  VARCHAR2 := fnd_api.g_miss_char
    , p3_a45  VARCHAR2 := fnd_api.g_miss_char
    , p3_a46  VARCHAR2 := fnd_api.g_miss_char
    , p3_a47  VARCHAR2 := fnd_api.g_miss_char
    , p3_a48  VARCHAR2 := fnd_api.g_miss_char
    , p3_a49  VARCHAR2 := fnd_api.g_miss_char
    , p3_a50  VARCHAR2 := fnd_api.g_miss_char
    , p3_a51  VARCHAR2 := fnd_api.g_miss_char
    , p3_a52  VARCHAR2 := fnd_api.g_miss_char
    , p3_a53  VARCHAR2 := fnd_api.g_miss_char
    , p3_a54  VARCHAR2 := fnd_api.g_miss_char
    , p3_a55  VARCHAR2 := fnd_api.g_miss_char
    , p3_a56  VARCHAR2 := fnd_api.g_miss_char
    , p3_a57  VARCHAR2 := fnd_api.g_miss_char
    , p3_a58  VARCHAR2 := fnd_api.g_miss_char
    , p3_a59  VARCHAR2 := fnd_api.g_miss_char
    , p3_a60  VARCHAR2 := fnd_api.g_miss_char
    , p3_a61  VARCHAR2 := fnd_api.g_miss_char
    , p3_a62  VARCHAR2 := fnd_api.g_miss_char
    , p3_a63  VARCHAR2 := fnd_api.g_miss_char
    , p3_a64  NUMBER := 0-1962.0724
    , p3_a65  NUMBER := 0-1962.0724
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  NUMBER := 0-1962.0724
    , p3_a68  VARCHAR2 := fnd_api.g_miss_char
    , p3_a69  VARCHAR2 := fnd_api.g_miss_char
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
    , p3_a71  VARCHAR2 := fnd_api.g_miss_char
    , p3_a72  NUMBER := 0-1962.0724
    , p3_a73  VARCHAR2 := fnd_api.g_miss_char
    , p3_a74  NUMBER := 0-1962.0724
    , p3_a75  NUMBER := 0-1962.0724
    , p3_a76  NUMBER := 0-1962.0724
    , p3_a77  VARCHAR2 := fnd_api.g_miss_char
    , p3_a78  VARCHAR2 := fnd_api.g_miss_char
    , p3_a79  VARCHAR2 := fnd_api.g_miss_char
    , p3_a80  NUMBER := 0-1962.0724
    , p3_a81  NUMBER := 0-1962.0724
    , p3_a82  NUMBER := 0-1962.0724
    , p3_a83  DATE := fnd_api.g_miss_date
    , p3_a84  VARCHAR2 := fnd_api.g_miss_char
    , p3_a85  VARCHAR2 := fnd_api.g_miss_char
    , p3_a86  VARCHAR2 := fnd_api.g_miss_char
    , p3_a87  NUMBER := 0-1962.0724
    , p3_a88  VARCHAR2 := fnd_api.g_miss_char
    , p3_a89  NUMBER := 0-1962.0724
    , p3_a90  NUMBER := 0-1962.0724
    , p3_a91  VARCHAR2 := fnd_api.g_miss_char
    , p3_a92  NUMBER := 0-1962.0724
    , p3_a93  VARCHAR2 := fnd_api.g_miss_char
    , p3_a94  NUMBER := 0-1962.0724
    , p3_a95  DATE := fnd_api.g_miss_date
    , p3_a96  VARCHAR2 := fnd_api.g_miss_char
    , p3_a97  VARCHAR2 := fnd_api.g_miss_char
    , p3_a98  VARCHAR2 := fnd_api.g_miss_char
    , p3_a99  VARCHAR2 := fnd_api.g_miss_char
    , p3_a100  VARCHAR2 := fnd_api.g_miss_char
    , p3_a101  VARCHAR2 := fnd_api.g_miss_char
    , p3_a102  VARCHAR2 := fnd_api.g_miss_char
    , p3_a103  VARCHAR2 := fnd_api.g_miss_char
    , p3_a104  VARCHAR2 := fnd_api.g_miss_char
    , p3_a105  VARCHAR2 := fnd_api.g_miss_char
    , p3_a106  VARCHAR2 := fnd_api.g_miss_char
    , p3_a107  VARCHAR2 := fnd_api.g_miss_char
    , p3_a108  VARCHAR2 := fnd_api.g_miss_char
    , p3_a109  VARCHAR2 := fnd_api.g_miss_char
    , p3_a110  VARCHAR2 := fnd_api.g_miss_char
    , p3_a111  NUMBER := 0-1962.0724
    , p3_a112  VARCHAR2 := fnd_api.g_miss_char
    , p3_a113  NUMBER := 0-1962.0724
    , p3_a114  VARCHAR2 := fnd_api.g_miss_char
    , p3_a115  NUMBER := 0-1962.0724
    , p3_a116  VARCHAR2 := fnd_api.g_miss_char
    , p3_a117  VARCHAR2 := fnd_api.g_miss_char
    , p3_a118  NUMBER := 0-1962.0724
    , p3_a119  VARCHAR2 := fnd_api.g_miss_char
    , p3_a120  NUMBER := 0-1962.0724
    , p3_a121  NUMBER := 0-1962.0724
    , p3_a122  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddx_txn_type_tbl csi_item_instance_pub.txn_oks_type_tbl;
    ddpx_txn_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_instance_rec.instance_id := rosetta_g_miss_num_map(p3_a0);
    ddp_instance_rec.instance_number := p3_a1;
    ddp_instance_rec.external_reference := p3_a2;
    ddp_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p3_a3);
    ddp_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p3_a4);
    ddp_instance_rec.inventory_revision := p3_a5;
    ddp_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p3_a6);
    ddp_instance_rec.serial_number := p3_a7;
    ddp_instance_rec.mfg_serial_number_flag := p3_a8;
    ddp_instance_rec.lot_number := p3_a9;
    ddp_instance_rec.quantity := rosetta_g_miss_num_map(p3_a10);
    ddp_instance_rec.unit_of_measure := p3_a11;
    ddp_instance_rec.accounting_class_code := p3_a12;
    ddp_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p3_a13);
    ddp_instance_rec.instance_status_id := rosetta_g_miss_num_map(p3_a14);
    ddp_instance_rec.customer_view_flag := p3_a15;
    ddp_instance_rec.merchant_view_flag := p3_a16;
    ddp_instance_rec.sellable_flag := p3_a17;
    ddp_instance_rec.system_id := rosetta_g_miss_num_map(p3_a18);
    ddp_instance_rec.instance_type_code := p3_a19;
    ddp_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p3_a20);
    ddp_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p3_a21);
    ddp_instance_rec.location_type_code := p3_a22;
    ddp_instance_rec.location_id := rosetta_g_miss_num_map(p3_a23);
    ddp_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p3_a24);
    ddp_instance_rec.inv_subinventory_name := p3_a25;
    ddp_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p3_a26);
    ddp_instance_rec.pa_project_id := rosetta_g_miss_num_map(p3_a27);
    ddp_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p3_a28);
    ddp_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p3_a29);
    ddp_instance_rec.wip_job_id := rosetta_g_miss_num_map(p3_a30);
    ddp_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p3_a31);
    ddp_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p3_a32);
    ddp_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p3_a33);
    ddp_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p3_a34);
    ddp_instance_rec.last_oe_po_number := p3_a35;
    ddp_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p3_a36);
    ddp_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p3_a37);
    ddp_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p3_a38);
    ddp_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p3_a39);
    ddp_instance_rec.install_date := rosetta_g_miss_date_in_map(p3_a40);
    ddp_instance_rec.manually_created_flag := p3_a41;
    ddp_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p3_a42);
    ddp_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p3_a43);
    ddp_instance_rec.creation_complete_flag := p3_a44;
    ddp_instance_rec.completeness_flag := p3_a45;
    ddp_instance_rec.version_label := p3_a46;
    ddp_instance_rec.version_label_description := p3_a47;
    ddp_instance_rec.context := p3_a48;
    ddp_instance_rec.attribute1 := p3_a49;
    ddp_instance_rec.attribute2 := p3_a50;
    ddp_instance_rec.attribute3 := p3_a51;
    ddp_instance_rec.attribute4 := p3_a52;
    ddp_instance_rec.attribute5 := p3_a53;
    ddp_instance_rec.attribute6 := p3_a54;
    ddp_instance_rec.attribute7 := p3_a55;
    ddp_instance_rec.attribute8 := p3_a56;
    ddp_instance_rec.attribute9 := p3_a57;
    ddp_instance_rec.attribute10 := p3_a58;
    ddp_instance_rec.attribute11 := p3_a59;
    ddp_instance_rec.attribute12 := p3_a60;
    ddp_instance_rec.attribute13 := p3_a61;
    ddp_instance_rec.attribute14 := p3_a62;
    ddp_instance_rec.attribute15 := p3_a63;
    ddp_instance_rec.object_version_number := rosetta_g_miss_num_map(p3_a64);
    ddp_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p3_a65);
    ddp_instance_rec.install_location_type_code := p3_a66;
    ddp_instance_rec.install_location_id := rosetta_g_miss_num_map(p3_a67);
    ddp_instance_rec.instance_usage_code := p3_a68;
    ddp_instance_rec.check_for_instance_expiry := p3_a69;
    ddp_instance_rec.processed_flag := p3_a70;
    ddp_instance_rec.call_contracts := p3_a71;
    ddp_instance_rec.interface_id := rosetta_g_miss_num_map(p3_a72);
    ddp_instance_rec.grp_call_contracts := p3_a73;
    ddp_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p3_a74);
    ddp_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p3_a75);
    ddp_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p3_a76);
    ddp_instance_rec.config_valid_status := p3_a77;
    ddp_instance_rec.instance_description := p3_a78;
    ddp_instance_rec.call_batch_validation := p3_a79;
    ddp_instance_rec.request_id := rosetta_g_miss_num_map(p3_a80);
    ddp_instance_rec.program_application_id := rosetta_g_miss_num_map(p3_a81);
    ddp_instance_rec.program_id := rosetta_g_miss_num_map(p3_a82);
    ddp_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a83);
    ddp_instance_rec.cascade_ownership_flag := p3_a84;
    ddp_instance_rec.network_asset_flag := p3_a85;
    ddp_instance_rec.maintainable_flag := p3_a86;
    ddp_instance_rec.pn_location_id := rosetta_g_miss_num_map(p3_a87);
    ddp_instance_rec.asset_criticality_code := p3_a88;
    ddp_instance_rec.category_id := rosetta_g_miss_num_map(p3_a89);
    ddp_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p3_a90);
    ddp_instance_rec.instantiation_flag := p3_a91;
    ddp_instance_rec.linear_location_id := rosetta_g_miss_num_map(p3_a92);
    ddp_instance_rec.operational_log_flag := p3_a93;
    ddp_instance_rec.checkin_status := rosetta_g_miss_num_map(p3_a94);
    ddp_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p3_a95);
    ddp_instance_rec.attribute16 := p3_a96;
    ddp_instance_rec.attribute17 := p3_a97;
    ddp_instance_rec.attribute18 := p3_a98;
    ddp_instance_rec.attribute19 := p3_a99;
    ddp_instance_rec.attribute20 := p3_a100;
    ddp_instance_rec.attribute21 := p3_a101;
    ddp_instance_rec.attribute22 := p3_a102;
    ddp_instance_rec.attribute23 := p3_a103;
    ddp_instance_rec.attribute24 := p3_a104;
    ddp_instance_rec.attribute25 := p3_a105;
    ddp_instance_rec.attribute26 := p3_a106;
    ddp_instance_rec.attribute27 := p3_a107;
    ddp_instance_rec.attribute28 := p3_a108;
    ddp_instance_rec.attribute29 := p3_a109;
    ddp_instance_rec.attribute30 := p3_a110;
    ddp_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p3_a111);
    ddp_instance_rec.purchase_currency_code := p3_a112;
    ddp_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p3_a113);
    ddp_instance_rec.payables_currency_code := p3_a114;
    ddp_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p3_a115);
    ddp_instance_rec.sales_currency_code := p3_a116;
    ddp_instance_rec.operational_status_code := p3_a117;
    ddp_instance_rec.department_id := rosetta_g_miss_num_map(p3_a118);
    ddp_instance_rec.wip_accounting_class := p3_a119;
    ddp_instance_rec.area_id := rosetta_g_miss_num_map(p3_a120);
    ddp_instance_rec.owner_party_id := rosetta_g_miss_num_map(p3_a121);
    ddp_instance_rec.source_code := p3_a122;





    ddpx_txn_date := rosetta_g_miss_date_in_map(px_txn_date);





    -- here's the delegated call to the old PL/SQL routine
    csi_item_instance_pub.get_oks_txn_types(p_api_version,
      p_commit,
      p_init_msg_list,
      ddp_instance_rec,
      p_check_contracts_yn,
      p_txn_type,
      ddx_txn_type_tbl,
      x_configflag,
      ddpx_txn_date,
      x_imp_contracts_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csi_item_instance_pub_w.rosetta_table_copy_out_p14(ddx_txn_type_tbl, x_txn_type_tbl);


    px_txn_date := ddpx_txn_date;




  end;

end csi_item_instance_pub_w;

/
