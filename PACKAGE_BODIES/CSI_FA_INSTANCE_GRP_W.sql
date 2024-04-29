--------------------------------------------------------
--  DDL for Package Body CSI_FA_INSTANCE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_FA_INSTANCE_GRP_W" as
  /* $Header: csigfawb.pls 120.11 2008/01/15 03:38:47 devijay ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy csi_fa_instance_grp.instance_serial_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_number := a0(indx);
          t(ddindx).serial_number := a1(indx);
          t(ddindx).lot_number := a2(indx);
          t(ddindx).external_reference := a3(indx);
          t(ddindx).instance_usage_code := a4(indx);
          t(ddindx).instance_description := a5(indx);
          t(ddindx).operational_status_code := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t csi_fa_instance_grp.instance_serial_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).instance_number;
          a1(indx) := t(ddindx).serial_number;
          a2(indx) := t(ddindx).lot_number;
          a3(indx) := t(ddindx).external_reference;
          a4(indx) := t(ddindx).instance_usage_code;
          a5(indx) := t(ddindx).instance_description;
          a6(indx) := t(ddindx).operational_status_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure create_item_instance(p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_VARCHAR2_TABLE_300
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
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
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_NUMBER_TABLE
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_200
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
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
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_NUMBER_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_NUMBER_TABLE
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_NUMBER_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_NUMBER_TABLE
    , p7_a40 out nocopy JTF_DATE_TABLE
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 out nocopy JTF_DATE_TABLE
    , p7_a43 out nocopy JTF_DATE_TABLE
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a64 out nocopy JTF_NUMBER_TABLE
    , p7_a65 out nocopy JTF_NUMBER_TABLE
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_NUMBER_TABLE
    , p7_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a72 out nocopy JTF_NUMBER_TABLE
    , p7_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a74 out nocopy JTF_NUMBER_TABLE
    , p7_a75 out nocopy JTF_NUMBER_TABLE
    , p7_a76 out nocopy JTF_NUMBER_TABLE
    , p7_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a80 out nocopy JTF_NUMBER_TABLE
    , p7_a81 out nocopy JTF_NUMBER_TABLE
    , p7_a82 out nocopy JTF_NUMBER_TABLE
    , p7_a83 out nocopy JTF_DATE_TABLE
    , p7_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a87 out nocopy JTF_NUMBER_TABLE
    , p7_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a89 out nocopy JTF_NUMBER_TABLE
    , p7_a90 out nocopy JTF_NUMBER_TABLE
    , p7_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a92 out nocopy JTF_NUMBER_TABLE
    , p7_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a94 out nocopy JTF_NUMBER_TABLE
    , p7_a95 out nocopy JTF_DATE_TABLE
    , p7_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a111 out nocopy JTF_NUMBER_TABLE
    , p7_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a113 out nocopy JTF_NUMBER_TABLE
    , p7_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a115 out nocopy JTF_NUMBER_TABLE
    , p7_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a118 out nocopy JTF_NUMBER_TABLE
    , p7_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a120 out nocopy JTF_NUMBER_TABLE
    , p7_a121 out nocopy JTF_NUMBER_TABLE
    , p7_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  VARCHAR2 := fnd_api.g_miss_char
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  NUMBER := 0-1962.0724
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  NUMBER := 0-1962.0724
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  DATE := fnd_api.g_miss_date
    , p2_a21  DATE := fnd_api.g_miss_date
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  NUMBER := 0-1962.0724
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  NUMBER := 0-1962.0724
    , p2_a27  NUMBER := 0-1962.0724
    , p2_a28  NUMBER := 0-1962.0724
    , p2_a29  NUMBER := 0-1962.0724
    , p2_a30  NUMBER := 0-1962.0724
    , p2_a31  NUMBER := 0-1962.0724
    , p2_a32  NUMBER := 0-1962.0724
    , p2_a33  NUMBER := 0-1962.0724
    , p2_a34  NUMBER := 0-1962.0724
    , p2_a35  VARCHAR2 := fnd_api.g_miss_char
    , p2_a36  NUMBER := 0-1962.0724
    , p2_a37  NUMBER := 0-1962.0724
    , p2_a38  NUMBER := 0-1962.0724
    , p2_a39  NUMBER := 0-1962.0724
    , p2_a40  DATE := fnd_api.g_miss_date
    , p2_a41  VARCHAR2 := fnd_api.g_miss_char
    , p2_a42  DATE := fnd_api.g_miss_date
    , p2_a43  DATE := fnd_api.g_miss_date
    , p2_a44  VARCHAR2 := fnd_api.g_miss_char
    , p2_a45  VARCHAR2 := fnd_api.g_miss_char
    , p2_a46  VARCHAR2 := fnd_api.g_miss_char
    , p2_a47  VARCHAR2 := fnd_api.g_miss_char
    , p2_a48  VARCHAR2 := fnd_api.g_miss_char
    , p2_a49  VARCHAR2 := fnd_api.g_miss_char
    , p2_a50  VARCHAR2 := fnd_api.g_miss_char
    , p2_a51  VARCHAR2 := fnd_api.g_miss_char
    , p2_a52  VARCHAR2 := fnd_api.g_miss_char
    , p2_a53  VARCHAR2 := fnd_api.g_miss_char
    , p2_a54  VARCHAR2 := fnd_api.g_miss_char
    , p2_a55  VARCHAR2 := fnd_api.g_miss_char
    , p2_a56  VARCHAR2 := fnd_api.g_miss_char
    , p2_a57  VARCHAR2 := fnd_api.g_miss_char
    , p2_a58  VARCHAR2 := fnd_api.g_miss_char
    , p2_a59  VARCHAR2 := fnd_api.g_miss_char
    , p2_a60  VARCHAR2 := fnd_api.g_miss_char
    , p2_a61  VARCHAR2 := fnd_api.g_miss_char
    , p2_a62  VARCHAR2 := fnd_api.g_miss_char
    , p2_a63  VARCHAR2 := fnd_api.g_miss_char
    , p2_a64  NUMBER := 0-1962.0724
    , p2_a65  NUMBER := 0-1962.0724
    , p2_a66  VARCHAR2 := fnd_api.g_miss_char
    , p2_a67  NUMBER := 0-1962.0724
    , p2_a68  VARCHAR2 := fnd_api.g_miss_char
    , p2_a69  VARCHAR2 := fnd_api.g_miss_char
    , p2_a70  VARCHAR2 := fnd_api.g_miss_char
    , p2_a71  VARCHAR2 := fnd_api.g_miss_char
    , p2_a72  NUMBER := 0-1962.0724
    , p2_a73  VARCHAR2 := fnd_api.g_miss_char
    , p2_a74  NUMBER := 0-1962.0724
    , p2_a75  NUMBER := 0-1962.0724
    , p2_a76  NUMBER := 0-1962.0724
    , p2_a77  VARCHAR2 := fnd_api.g_miss_char
    , p2_a78  VARCHAR2 := fnd_api.g_miss_char
    , p2_a79  VARCHAR2 := fnd_api.g_miss_char
    , p2_a80  NUMBER := 0-1962.0724
    , p2_a81  NUMBER := 0-1962.0724
    , p2_a82  NUMBER := 0-1962.0724
    , p2_a83  DATE := fnd_api.g_miss_date
    , p2_a84  VARCHAR2 := fnd_api.g_miss_char
    , p2_a85  VARCHAR2 := fnd_api.g_miss_char
    , p2_a86  VARCHAR2 := fnd_api.g_miss_char
    , p2_a87  NUMBER := 0-1962.0724
    , p2_a88  VARCHAR2 := fnd_api.g_miss_char
    , p2_a89  NUMBER := 0-1962.0724
    , p2_a90  NUMBER := 0-1962.0724
    , p2_a91  VARCHAR2 := fnd_api.g_miss_char
    , p2_a92  NUMBER := 0-1962.0724
    , p2_a93  VARCHAR2 := fnd_api.g_miss_char
    , p2_a94  NUMBER := 0-1962.0724
    , p2_a95  DATE := fnd_api.g_miss_date
    , p2_a96  VARCHAR2 := fnd_api.g_miss_char
    , p2_a97  VARCHAR2 := fnd_api.g_miss_char
    , p2_a98  VARCHAR2 := fnd_api.g_miss_char
    , p2_a99  VARCHAR2 := fnd_api.g_miss_char
    , p2_a100  VARCHAR2 := fnd_api.g_miss_char
    , p2_a101  VARCHAR2 := fnd_api.g_miss_char
    , p2_a102  VARCHAR2 := fnd_api.g_miss_char
    , p2_a103  VARCHAR2 := fnd_api.g_miss_char
    , p2_a104  VARCHAR2 := fnd_api.g_miss_char
    , p2_a105  VARCHAR2 := fnd_api.g_miss_char
    , p2_a106  VARCHAR2 := fnd_api.g_miss_char
    , p2_a107  VARCHAR2 := fnd_api.g_miss_char
    , p2_a108  VARCHAR2 := fnd_api.g_miss_char
    , p2_a109  VARCHAR2 := fnd_api.g_miss_char
    , p2_a110  VARCHAR2 := fnd_api.g_miss_char
    , p2_a111  NUMBER := 0-1962.0724
    , p2_a112  VARCHAR2 := fnd_api.g_miss_char
    , p2_a113  NUMBER := 0-1962.0724
    , p2_a114  VARCHAR2 := fnd_api.g_miss_char
    , p2_a115  NUMBER := 0-1962.0724
    , p2_a116  VARCHAR2 := fnd_api.g_miss_char
    , p2_a117  VARCHAR2 := fnd_api.g_miss_char
    , p2_a118  NUMBER := 0-1962.0724
    , p2_a119  VARCHAR2 := fnd_api.g_miss_char
    , p2_a120  NUMBER := 0-1962.0724
    , p2_a121  NUMBER := 0-1962.0724
    , p2_a122  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fixed_asset_rec csi_fa_instance_grp.fixed_asset_rec;
    ddp_eam_rec csi_fa_instance_grp.eam_rec;
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_instance_serial_tbl csi_fa_instance_grp.instance_serial_tbl;
    ddp_party_tbl csi_datastructures_pub.party_tbl;
    ddp_party_account_tbl csi_datastructures_pub.party_account_tbl;
    ddpx_csi_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_tbl csi_datastructures_pub.instance_tbl;
    ddx_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fixed_asset_rec.asset_id := rosetta_g_miss_num_map(p0_a0);
    ddp_fixed_asset_rec.book_type_code := p0_a1;
    ddp_fixed_asset_rec.asset_location_id := rosetta_g_miss_num_map(p0_a2);
    ddp_fixed_asset_rec.asset_quantity := rosetta_g_miss_num_map(p0_a3);
    ddp_fixed_asset_rec.fa_sync_flag := p0_a4;
    ddp_fixed_asset_rec.fa_sync_validation_reqd := p0_a5;

    ddp_eam_rec.category_id := rosetta_g_miss_num_map(p1_a0);
    ddp_eam_rec.asset_criticality_code := p1_a1;
    ddp_eam_rec.owning_department_id := rosetta_g_miss_num_map(p1_a2);
    ddp_eam_rec.wip_accounting_class_code := p1_a3;
    ddp_eam_rec.area_id := rosetta_g_miss_num_map(p1_a4);
    ddp_eam_rec.parent_instance_id := rosetta_g_miss_num_map(p1_a5);

    ddp_instance_rec.instance_id := rosetta_g_miss_num_map(p2_a0);
    ddp_instance_rec.instance_number := p2_a1;
    ddp_instance_rec.external_reference := p2_a2;
    ddp_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p2_a3);
    ddp_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p2_a4);
    ddp_instance_rec.inventory_revision := p2_a5;
    ddp_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p2_a6);
    ddp_instance_rec.serial_number := p2_a7;
    ddp_instance_rec.mfg_serial_number_flag := p2_a8;
    ddp_instance_rec.lot_number := p2_a9;
    ddp_instance_rec.quantity := rosetta_g_miss_num_map(p2_a10);
    ddp_instance_rec.unit_of_measure := p2_a11;
    ddp_instance_rec.accounting_class_code := p2_a12;
    ddp_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p2_a13);
    ddp_instance_rec.instance_status_id := rosetta_g_miss_num_map(p2_a14);
    ddp_instance_rec.customer_view_flag := p2_a15;
    ddp_instance_rec.merchant_view_flag := p2_a16;
    ddp_instance_rec.sellable_flag := p2_a17;
    ddp_instance_rec.system_id := rosetta_g_miss_num_map(p2_a18);
    ddp_instance_rec.instance_type_code := p2_a19;
    ddp_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p2_a20);
    ddp_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p2_a21);
    ddp_instance_rec.location_type_code := p2_a22;
    ddp_instance_rec.location_id := rosetta_g_miss_num_map(p2_a23);
    ddp_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p2_a24);
    ddp_instance_rec.inv_subinventory_name := p2_a25;
    ddp_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p2_a26);
    ddp_instance_rec.pa_project_id := rosetta_g_miss_num_map(p2_a27);
    ddp_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p2_a28);
    ddp_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p2_a29);
    ddp_instance_rec.wip_job_id := rosetta_g_miss_num_map(p2_a30);
    ddp_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p2_a31);
    ddp_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p2_a32);
    ddp_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p2_a33);
    ddp_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p2_a34);
    ddp_instance_rec.last_oe_po_number := p2_a35;
    ddp_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p2_a36);
    ddp_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p2_a37);
    ddp_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p2_a38);
    ddp_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p2_a39);
    ddp_instance_rec.install_date := rosetta_g_miss_date_in_map(p2_a40);
    ddp_instance_rec.manually_created_flag := p2_a41;
    ddp_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p2_a42);
    ddp_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p2_a43);
    ddp_instance_rec.creation_complete_flag := p2_a44;
    ddp_instance_rec.completeness_flag := p2_a45;
    ddp_instance_rec.version_label := p2_a46;
    ddp_instance_rec.version_label_description := p2_a47;
    ddp_instance_rec.context := p2_a48;
    ddp_instance_rec.attribute1 := p2_a49;
    ddp_instance_rec.attribute2 := p2_a50;
    ddp_instance_rec.attribute3 := p2_a51;
    ddp_instance_rec.attribute4 := p2_a52;
    ddp_instance_rec.attribute5 := p2_a53;
    ddp_instance_rec.attribute6 := p2_a54;
    ddp_instance_rec.attribute7 := p2_a55;
    ddp_instance_rec.attribute8 := p2_a56;
    ddp_instance_rec.attribute9 := p2_a57;
    ddp_instance_rec.attribute10 := p2_a58;
    ddp_instance_rec.attribute11 := p2_a59;
    ddp_instance_rec.attribute12 := p2_a60;
    ddp_instance_rec.attribute13 := p2_a61;
    ddp_instance_rec.attribute14 := p2_a62;
    ddp_instance_rec.attribute15 := p2_a63;
    ddp_instance_rec.object_version_number := rosetta_g_miss_num_map(p2_a64);
    ddp_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p2_a65);
    ddp_instance_rec.install_location_type_code := p2_a66;
    ddp_instance_rec.install_location_id := rosetta_g_miss_num_map(p2_a67);
    ddp_instance_rec.instance_usage_code := p2_a68;
    ddp_instance_rec.check_for_instance_expiry := p2_a69;
    ddp_instance_rec.processed_flag := p2_a70;
    ddp_instance_rec.call_contracts := p2_a71;
    ddp_instance_rec.interface_id := rosetta_g_miss_num_map(p2_a72);
    ddp_instance_rec.grp_call_contracts := p2_a73;
    ddp_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p2_a74);
    ddp_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p2_a75);
    ddp_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p2_a76);
    ddp_instance_rec.config_valid_status := p2_a77;
    ddp_instance_rec.instance_description := p2_a78;
    ddp_instance_rec.call_batch_validation := p2_a79;
    ddp_instance_rec.request_id := rosetta_g_miss_num_map(p2_a80);
    ddp_instance_rec.program_application_id := rosetta_g_miss_num_map(p2_a81);
    ddp_instance_rec.program_id := rosetta_g_miss_num_map(p2_a82);
    ddp_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a83);
    ddp_instance_rec.cascade_ownership_flag := p2_a84;
    ddp_instance_rec.network_asset_flag := p2_a85;
    ddp_instance_rec.maintainable_flag := p2_a86;
    ddp_instance_rec.pn_location_id := rosetta_g_miss_num_map(p2_a87);
    ddp_instance_rec.asset_criticality_code := p2_a88;
    ddp_instance_rec.category_id := rosetta_g_miss_num_map(p2_a89);
    ddp_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p2_a90);
    ddp_instance_rec.instantiation_flag := p2_a91;
    ddp_instance_rec.linear_location_id := rosetta_g_miss_num_map(p2_a92);
    ddp_instance_rec.operational_log_flag := p2_a93;
    ddp_instance_rec.checkin_status := rosetta_g_miss_num_map(p2_a94);
    ddp_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p2_a95);
    ddp_instance_rec.attribute16 := p2_a96;
    ddp_instance_rec.attribute17 := p2_a97;
    ddp_instance_rec.attribute18 := p2_a98;
    ddp_instance_rec.attribute19 := p2_a99;
    ddp_instance_rec.attribute20 := p2_a100;
    ddp_instance_rec.attribute21 := p2_a101;
    ddp_instance_rec.attribute22 := p2_a102;
    ddp_instance_rec.attribute23 := p2_a103;
    ddp_instance_rec.attribute24 := p2_a104;
    ddp_instance_rec.attribute25 := p2_a105;
    ddp_instance_rec.attribute26 := p2_a106;
    ddp_instance_rec.attribute27 := p2_a107;
    ddp_instance_rec.attribute28 := p2_a108;
    ddp_instance_rec.attribute29 := p2_a109;
    ddp_instance_rec.attribute30 := p2_a110;
    ddp_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p2_a111);
    ddp_instance_rec.purchase_currency_code := p2_a112;
    ddp_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p2_a113);
    ddp_instance_rec.payables_currency_code := p2_a114;
    ddp_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p2_a115);
    ddp_instance_rec.sales_currency_code := p2_a116;
    ddp_instance_rec.operational_status_code := p2_a117;
    ddp_instance_rec.department_id := rosetta_g_miss_num_map(p2_a118);
    ddp_instance_rec.wip_accounting_class := p2_a119;
    ddp_instance_rec.area_id := rosetta_g_miss_num_map(p2_a120);
    ddp_instance_rec.owner_party_id := rosetta_g_miss_num_map(p2_a121);
    ddp_instance_rec.source_code := p2_a122;

    csi_fa_instance_grp_w.rosetta_table_copy_in_p4(ddp_instance_serial_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p9(ddp_party_tbl, p4_a0
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
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      );

    csi_datastructures_pub_w.rosetta_table_copy_in_p6(ddp_party_account_tbl, p5_a0
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
      );

    ddpx_csi_txn_rec.transaction_id := rosetta_g_miss_num_map(p6_a0);
    ddpx_csi_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p6_a1);
    ddpx_csi_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p6_a2);
    ddpx_csi_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p6_a3);
    ddpx_csi_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p6_a4);
    ddpx_csi_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p6_a5);
    ddpx_csi_txn_rec.source_group_ref := p6_a6;
    ddpx_csi_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p6_a7);
    ddpx_csi_txn_rec.source_header_ref := p6_a8;
    ddpx_csi_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p6_a9);
    ddpx_csi_txn_rec.source_line_ref := p6_a10;
    ddpx_csi_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p6_a11);
    ddpx_csi_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p6_a12);
    ddpx_csi_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p6_a13);
    ddpx_csi_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p6_a14);
    ddpx_csi_txn_rec.transaction_uom_code := p6_a15;
    ddpx_csi_txn_rec.transacted_by := rosetta_g_miss_num_map(p6_a16);
    ddpx_csi_txn_rec.transaction_status_code := p6_a17;
    ddpx_csi_txn_rec.transaction_action_code := p6_a18;
    ddpx_csi_txn_rec.message_id := rosetta_g_miss_num_map(p6_a19);
    ddpx_csi_txn_rec.context := p6_a20;
    ddpx_csi_txn_rec.attribute1 := p6_a21;
    ddpx_csi_txn_rec.attribute2 := p6_a22;
    ddpx_csi_txn_rec.attribute3 := p6_a23;
    ddpx_csi_txn_rec.attribute4 := p6_a24;
    ddpx_csi_txn_rec.attribute5 := p6_a25;
    ddpx_csi_txn_rec.attribute6 := p6_a26;
    ddpx_csi_txn_rec.attribute7 := p6_a27;
    ddpx_csi_txn_rec.attribute8 := p6_a28;
    ddpx_csi_txn_rec.attribute9 := p6_a29;
    ddpx_csi_txn_rec.attribute10 := p6_a30;
    ddpx_csi_txn_rec.attribute11 := p6_a31;
    ddpx_csi_txn_rec.attribute12 := p6_a32;
    ddpx_csi_txn_rec.attribute13 := p6_a33;
    ddpx_csi_txn_rec.attribute14 := p6_a34;
    ddpx_csi_txn_rec.attribute15 := p6_a35;
    ddpx_csi_txn_rec.object_version_number := rosetta_g_miss_num_map(p6_a36);
    ddpx_csi_txn_rec.split_reason_code := p6_a37;
    ddpx_csi_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p6_a38);
    ddpx_csi_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p6_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_fa_instance_grp.create_item_instance(ddp_fixed_asset_rec,
      ddp_eam_rec,
      ddp_instance_rec,
      ddp_instance_serial_tbl,
      ddp_party_tbl,
      ddp_party_account_tbl,
      ddpx_csi_txn_rec,
      ddx_instance_tbl,
      ddx_instance_asset_tbl,
      x_return_status,
      x_error_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_id);
    p6_a1 := ddpx_csi_txn_rec.transaction_date;
    p6_a2 := ddpx_csi_txn_rec.source_transaction_date;
    p6_a3 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_type_id);
    p6_a4 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.txn_sub_type_id);
    p6_a5 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_group_ref_id);
    p6_a6 := ddpx_csi_txn_rec.source_group_ref;
    p6_a7 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_header_ref_id);
    p6_a8 := ddpx_csi_txn_rec.source_header_ref;
    p6_a9 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_line_ref_id);
    p6_a10 := ddpx_csi_txn_rec.source_line_ref;
    p6_a11 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id1);
    p6_a12 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id2);
    p6_a13 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.inv_material_transaction_id);
    p6_a14 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_quantity);
    p6_a15 := ddpx_csi_txn_rec.transaction_uom_code;
    p6_a16 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transacted_by);
    p6_a17 := ddpx_csi_txn_rec.transaction_status_code;
    p6_a18 := ddpx_csi_txn_rec.transaction_action_code;
    p6_a19 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.message_id);
    p6_a20 := ddpx_csi_txn_rec.context;
    p6_a21 := ddpx_csi_txn_rec.attribute1;
    p6_a22 := ddpx_csi_txn_rec.attribute2;
    p6_a23 := ddpx_csi_txn_rec.attribute3;
    p6_a24 := ddpx_csi_txn_rec.attribute4;
    p6_a25 := ddpx_csi_txn_rec.attribute5;
    p6_a26 := ddpx_csi_txn_rec.attribute6;
    p6_a27 := ddpx_csi_txn_rec.attribute7;
    p6_a28 := ddpx_csi_txn_rec.attribute8;
    p6_a29 := ddpx_csi_txn_rec.attribute9;
    p6_a30 := ddpx_csi_txn_rec.attribute10;
    p6_a31 := ddpx_csi_txn_rec.attribute11;
    p6_a32 := ddpx_csi_txn_rec.attribute12;
    p6_a33 := ddpx_csi_txn_rec.attribute13;
    p6_a34 := ddpx_csi_txn_rec.attribute14;
    p6_a35 := ddpx_csi_txn_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.object_version_number);
    p6_a37 := ddpx_csi_txn_rec.split_reason_code;
    p6_a38 := ddpx_csi_txn_rec.src_txn_creation_date;
    p6_a39 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p19(ddx_instance_tbl, p7_a0
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
      , p7_a88
      , p7_a89
      , p7_a90
      , p7_a91
      , p7_a92
      , p7_a93
      , p7_a94
      , p7_a95
      , p7_a96
      , p7_a97
      , p7_a98
      , p7_a99
      , p7_a100
      , p7_a101
      , p7_a102
      , p7_a103
      , p7_a104
      , p7_a105
      , p7_a106
      , p7_a107
      , p7_a108
      , p7_a109
      , p7_a110
      , p7_a111
      , p7_a112
      , p7_a113
      , p7_a114
      , p7_a115
      , p7_a116
      , p7_a117
      , p7_a118
      , p7_a119
      , p7_a120
      , p7_a121
      , p7_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddx_instance_asset_tbl, p8_a0
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
      );


  end;

  procedure copy_item_instance(p2_a0 JTF_VARCHAR2_TABLE_100
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_300
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_contacts  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_inst_children  VARCHAR2
    , p12_a0 in out nocopy  NUMBER
    , p12_a1 in out nocopy  DATE
    , p12_a2 in out nocopy  DATE
    , p12_a3 in out nocopy  NUMBER
    , p12_a4 in out nocopy  NUMBER
    , p12_a5 in out nocopy  NUMBER
    , p12_a6 in out nocopy  VARCHAR2
    , p12_a7 in out nocopy  NUMBER
    , p12_a8 in out nocopy  VARCHAR2
    , p12_a9 in out nocopy  NUMBER
    , p12_a10 in out nocopy  VARCHAR2
    , p12_a11 in out nocopy  NUMBER
    , p12_a12 in out nocopy  NUMBER
    , p12_a13 in out nocopy  NUMBER
    , p12_a14 in out nocopy  NUMBER
    , p12_a15 in out nocopy  VARCHAR2
    , p12_a16 in out nocopy  NUMBER
    , p12_a17 in out nocopy  VARCHAR2
    , p12_a18 in out nocopy  VARCHAR2
    , p12_a19 in out nocopy  NUMBER
    , p12_a20 in out nocopy  VARCHAR2
    , p12_a21 in out nocopy  VARCHAR2
    , p12_a22 in out nocopy  VARCHAR2
    , p12_a23 in out nocopy  VARCHAR2
    , p12_a24 in out nocopy  VARCHAR2
    , p12_a25 in out nocopy  VARCHAR2
    , p12_a26 in out nocopy  VARCHAR2
    , p12_a27 in out nocopy  VARCHAR2
    , p12_a28 in out nocopy  VARCHAR2
    , p12_a29 in out nocopy  VARCHAR2
    , p12_a30 in out nocopy  VARCHAR2
    , p12_a31 in out nocopy  VARCHAR2
    , p12_a32 in out nocopy  VARCHAR2
    , p12_a33 in out nocopy  VARCHAR2
    , p12_a34 in out nocopy  VARCHAR2
    , p12_a35 in out nocopy  VARCHAR2
    , p12_a36 in out nocopy  NUMBER
    , p12_a37 in out nocopy  VARCHAR2
    , p12_a38 in out nocopy  DATE
    , p12_a39 in out nocopy  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_NUMBER_TABLE
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_NUMBER_TABLE
    , p13_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a20 out nocopy JTF_DATE_TABLE
    , p13_a21 out nocopy JTF_DATE_TABLE
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_NUMBER_TABLE
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a26 out nocopy JTF_NUMBER_TABLE
    , p13_a27 out nocopy JTF_NUMBER_TABLE
    , p13_a28 out nocopy JTF_NUMBER_TABLE
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_NUMBER_TABLE
    , p13_a31 out nocopy JTF_NUMBER_TABLE
    , p13_a32 out nocopy JTF_NUMBER_TABLE
    , p13_a33 out nocopy JTF_NUMBER_TABLE
    , p13_a34 out nocopy JTF_NUMBER_TABLE
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a36 out nocopy JTF_NUMBER_TABLE
    , p13_a37 out nocopy JTF_NUMBER_TABLE
    , p13_a38 out nocopy JTF_NUMBER_TABLE
    , p13_a39 out nocopy JTF_NUMBER_TABLE
    , p13_a40 out nocopy JTF_DATE_TABLE
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a42 out nocopy JTF_DATE_TABLE
    , p13_a43 out nocopy JTF_DATE_TABLE
    , p13_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a64 out nocopy JTF_NUMBER_TABLE
    , p13_a65 out nocopy JTF_NUMBER_TABLE
    , p13_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a67 out nocopy JTF_NUMBER_TABLE
    , p13_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a72 out nocopy JTF_NUMBER_TABLE
    , p13_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a74 out nocopy JTF_NUMBER_TABLE
    , p13_a75 out nocopy JTF_NUMBER_TABLE
    , p13_a76 out nocopy JTF_NUMBER_TABLE
    , p13_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a80 out nocopy JTF_NUMBER_TABLE
    , p13_a81 out nocopy JTF_NUMBER_TABLE
    , p13_a82 out nocopy JTF_NUMBER_TABLE
    , p13_a83 out nocopy JTF_DATE_TABLE
    , p13_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a87 out nocopy JTF_NUMBER_TABLE
    , p13_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a89 out nocopy JTF_NUMBER_TABLE
    , p13_a90 out nocopy JTF_NUMBER_TABLE
    , p13_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a92 out nocopy JTF_NUMBER_TABLE
    , p13_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a94 out nocopy JTF_NUMBER_TABLE
    , p13_a95 out nocopy JTF_DATE_TABLE
    , p13_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a111 out nocopy JTF_NUMBER_TABLE
    , p13_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a113 out nocopy JTF_NUMBER_TABLE
    , p13_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a115 out nocopy JTF_NUMBER_TABLE
    , p13_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a118 out nocopy JTF_NUMBER_TABLE
    , p13_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a120 out nocopy JTF_NUMBER_TABLE
    , p13_a121 out nocopy JTF_NUMBER_TABLE
    , p13_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p14_a8 out nocopy JTF_DATE_TABLE
    , p14_a9 out nocopy JTF_NUMBER_TABLE
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_NUMBER_TABLE
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  NUMBER := 0-1962.0724
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  DATE := fnd_api.g_miss_date
    , p1_a21  DATE := fnd_api.g_miss_date
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  NUMBER := 0-1962.0724
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  NUMBER := 0-1962.0724
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  NUMBER := 0-1962.0724
    , p1_a31  NUMBER := 0-1962.0724
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  DATE := fnd_api.g_miss_date
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  DATE := fnd_api.g_miss_date
    , p1_a43  DATE := fnd_api.g_miss_date
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  VARCHAR2 := fnd_api.g_miss_char
    , p1_a46  VARCHAR2 := fnd_api.g_miss_char
    , p1_a47  VARCHAR2 := fnd_api.g_miss_char
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  NUMBER := 0-1962.0724
    , p1_a65  NUMBER := 0-1962.0724
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  NUMBER := 0-1962.0724
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  NUMBER := 0-1962.0724
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  NUMBER := 0-1962.0724
    , p1_a75  NUMBER := 0-1962.0724
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  VARCHAR2 := fnd_api.g_miss_char
    , p1_a79  VARCHAR2 := fnd_api.g_miss_char
    , p1_a80  NUMBER := 0-1962.0724
    , p1_a81  NUMBER := 0-1962.0724
    , p1_a82  NUMBER := 0-1962.0724
    , p1_a83  DATE := fnd_api.g_miss_date
    , p1_a84  VARCHAR2 := fnd_api.g_miss_char
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  NUMBER := 0-1962.0724
    , p1_a88  VARCHAR2 := fnd_api.g_miss_char
    , p1_a89  NUMBER := 0-1962.0724
    , p1_a90  NUMBER := 0-1962.0724
    , p1_a91  VARCHAR2 := fnd_api.g_miss_char
    , p1_a92  NUMBER := 0-1962.0724
    , p1_a93  VARCHAR2 := fnd_api.g_miss_char
    , p1_a94  NUMBER := 0-1962.0724
    , p1_a95  DATE := fnd_api.g_miss_date
    , p1_a96  VARCHAR2 := fnd_api.g_miss_char
    , p1_a97  VARCHAR2 := fnd_api.g_miss_char
    , p1_a98  VARCHAR2 := fnd_api.g_miss_char
    , p1_a99  VARCHAR2 := fnd_api.g_miss_char
    , p1_a100  VARCHAR2 := fnd_api.g_miss_char
    , p1_a101  VARCHAR2 := fnd_api.g_miss_char
    , p1_a102  VARCHAR2 := fnd_api.g_miss_char
    , p1_a103  VARCHAR2 := fnd_api.g_miss_char
    , p1_a104  VARCHAR2 := fnd_api.g_miss_char
    , p1_a105  VARCHAR2 := fnd_api.g_miss_char
    , p1_a106  VARCHAR2 := fnd_api.g_miss_char
    , p1_a107  VARCHAR2 := fnd_api.g_miss_char
    , p1_a108  VARCHAR2 := fnd_api.g_miss_char
    , p1_a109  VARCHAR2 := fnd_api.g_miss_char
    , p1_a110  VARCHAR2 := fnd_api.g_miss_char
    , p1_a111  NUMBER := 0-1962.0724
    , p1_a112  VARCHAR2 := fnd_api.g_miss_char
    , p1_a113  NUMBER := 0-1962.0724
    , p1_a114  VARCHAR2 := fnd_api.g_miss_char
    , p1_a115  NUMBER := 0-1962.0724
    , p1_a116  VARCHAR2 := fnd_api.g_miss_char
    , p1_a117  VARCHAR2 := fnd_api.g_miss_char
    , p1_a118  NUMBER := 0-1962.0724
    , p1_a119  VARCHAR2 := fnd_api.g_miss_char
    , p1_a120  NUMBER := 0-1962.0724
    , p1_a121  NUMBER := 0-1962.0724
    , p1_a122  VARCHAR2 := fnd_api.g_miss_char
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
  )

  as
    ddp_fixed_asset_rec csi_fa_instance_grp.fixed_asset_rec;
    ddp_instance_rec csi_datastructures_pub.instance_rec;
    ddp_instance_serial_tbl csi_fa_instance_grp.instance_serial_tbl;
    ddp_eam_rec csi_fa_instance_grp.eam_rec;
    ddpx_csi_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_tbl csi_datastructures_pub.instance_tbl;
    ddx_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fixed_asset_rec.asset_id := rosetta_g_miss_num_map(p0_a0);
    ddp_fixed_asset_rec.book_type_code := p0_a1;
    ddp_fixed_asset_rec.asset_location_id := rosetta_g_miss_num_map(p0_a2);
    ddp_fixed_asset_rec.asset_quantity := rosetta_g_miss_num_map(p0_a3);
    ddp_fixed_asset_rec.fa_sync_flag := p0_a4;
    ddp_fixed_asset_rec.fa_sync_validation_reqd := p0_a5;

    ddp_instance_rec.instance_id := rosetta_g_miss_num_map(p1_a0);
    ddp_instance_rec.instance_number := p1_a1;
    ddp_instance_rec.external_reference := p1_a2;
    ddp_instance_rec.inventory_item_id := rosetta_g_miss_num_map(p1_a3);
    ddp_instance_rec.vld_organization_id := rosetta_g_miss_num_map(p1_a4);
    ddp_instance_rec.inventory_revision := p1_a5;
    ddp_instance_rec.inv_master_organization_id := rosetta_g_miss_num_map(p1_a6);
    ddp_instance_rec.serial_number := p1_a7;
    ddp_instance_rec.mfg_serial_number_flag := p1_a8;
    ddp_instance_rec.lot_number := p1_a9;
    ddp_instance_rec.quantity := rosetta_g_miss_num_map(p1_a10);
    ddp_instance_rec.unit_of_measure := p1_a11;
    ddp_instance_rec.accounting_class_code := p1_a12;
    ddp_instance_rec.instance_condition_id := rosetta_g_miss_num_map(p1_a13);
    ddp_instance_rec.instance_status_id := rosetta_g_miss_num_map(p1_a14);
    ddp_instance_rec.customer_view_flag := p1_a15;
    ddp_instance_rec.merchant_view_flag := p1_a16;
    ddp_instance_rec.sellable_flag := p1_a17;
    ddp_instance_rec.system_id := rosetta_g_miss_num_map(p1_a18);
    ddp_instance_rec.instance_type_code := p1_a19;
    ddp_instance_rec.active_start_date := rosetta_g_miss_date_in_map(p1_a20);
    ddp_instance_rec.active_end_date := rosetta_g_miss_date_in_map(p1_a21);
    ddp_instance_rec.location_type_code := p1_a22;
    ddp_instance_rec.location_id := rosetta_g_miss_num_map(p1_a23);
    ddp_instance_rec.inv_organization_id := rosetta_g_miss_num_map(p1_a24);
    ddp_instance_rec.inv_subinventory_name := p1_a25;
    ddp_instance_rec.inv_locator_id := rosetta_g_miss_num_map(p1_a26);
    ddp_instance_rec.pa_project_id := rosetta_g_miss_num_map(p1_a27);
    ddp_instance_rec.pa_project_task_id := rosetta_g_miss_num_map(p1_a28);
    ddp_instance_rec.in_transit_order_line_id := rosetta_g_miss_num_map(p1_a29);
    ddp_instance_rec.wip_job_id := rosetta_g_miss_num_map(p1_a30);
    ddp_instance_rec.po_order_line_id := rosetta_g_miss_num_map(p1_a31);
    ddp_instance_rec.last_oe_order_line_id := rosetta_g_miss_num_map(p1_a32);
    ddp_instance_rec.last_oe_rma_line_id := rosetta_g_miss_num_map(p1_a33);
    ddp_instance_rec.last_po_po_line_id := rosetta_g_miss_num_map(p1_a34);
    ddp_instance_rec.last_oe_po_number := p1_a35;
    ddp_instance_rec.last_wip_job_id := rosetta_g_miss_num_map(p1_a36);
    ddp_instance_rec.last_pa_project_id := rosetta_g_miss_num_map(p1_a37);
    ddp_instance_rec.last_pa_task_id := rosetta_g_miss_num_map(p1_a38);
    ddp_instance_rec.last_oe_agreement_id := rosetta_g_miss_num_map(p1_a39);
    ddp_instance_rec.install_date := rosetta_g_miss_date_in_map(p1_a40);
    ddp_instance_rec.manually_created_flag := p1_a41;
    ddp_instance_rec.return_by_date := rosetta_g_miss_date_in_map(p1_a42);
    ddp_instance_rec.actual_return_date := rosetta_g_miss_date_in_map(p1_a43);
    ddp_instance_rec.creation_complete_flag := p1_a44;
    ddp_instance_rec.completeness_flag := p1_a45;
    ddp_instance_rec.version_label := p1_a46;
    ddp_instance_rec.version_label_description := p1_a47;
    ddp_instance_rec.context := p1_a48;
    ddp_instance_rec.attribute1 := p1_a49;
    ddp_instance_rec.attribute2 := p1_a50;
    ddp_instance_rec.attribute3 := p1_a51;
    ddp_instance_rec.attribute4 := p1_a52;
    ddp_instance_rec.attribute5 := p1_a53;
    ddp_instance_rec.attribute6 := p1_a54;
    ddp_instance_rec.attribute7 := p1_a55;
    ddp_instance_rec.attribute8 := p1_a56;
    ddp_instance_rec.attribute9 := p1_a57;
    ddp_instance_rec.attribute10 := p1_a58;
    ddp_instance_rec.attribute11 := p1_a59;
    ddp_instance_rec.attribute12 := p1_a60;
    ddp_instance_rec.attribute13 := p1_a61;
    ddp_instance_rec.attribute14 := p1_a62;
    ddp_instance_rec.attribute15 := p1_a63;
    ddp_instance_rec.object_version_number := rosetta_g_miss_num_map(p1_a64);
    ddp_instance_rec.last_txn_line_detail_id := rosetta_g_miss_num_map(p1_a65);
    ddp_instance_rec.install_location_type_code := p1_a66;
    ddp_instance_rec.install_location_id := rosetta_g_miss_num_map(p1_a67);
    ddp_instance_rec.instance_usage_code := p1_a68;
    ddp_instance_rec.check_for_instance_expiry := p1_a69;
    ddp_instance_rec.processed_flag := p1_a70;
    ddp_instance_rec.call_contracts := p1_a71;
    ddp_instance_rec.interface_id := rosetta_g_miss_num_map(p1_a72);
    ddp_instance_rec.grp_call_contracts := p1_a73;
    ddp_instance_rec.config_inst_hdr_id := rosetta_g_miss_num_map(p1_a74);
    ddp_instance_rec.config_inst_rev_num := rosetta_g_miss_num_map(p1_a75);
    ddp_instance_rec.config_inst_item_id := rosetta_g_miss_num_map(p1_a76);
    ddp_instance_rec.config_valid_status := p1_a77;
    ddp_instance_rec.instance_description := p1_a78;
    ddp_instance_rec.call_batch_validation := p1_a79;
    ddp_instance_rec.request_id := rosetta_g_miss_num_map(p1_a80);
    ddp_instance_rec.program_application_id := rosetta_g_miss_num_map(p1_a81);
    ddp_instance_rec.program_id := rosetta_g_miss_num_map(p1_a82);
    ddp_instance_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a83);
    ddp_instance_rec.cascade_ownership_flag := p1_a84;
    ddp_instance_rec.network_asset_flag := p1_a85;
    ddp_instance_rec.maintainable_flag := p1_a86;
    ddp_instance_rec.pn_location_id := rosetta_g_miss_num_map(p1_a87);
    ddp_instance_rec.asset_criticality_code := p1_a88;
    ddp_instance_rec.category_id := rosetta_g_miss_num_map(p1_a89);
    ddp_instance_rec.equipment_gen_object_id := rosetta_g_miss_num_map(p1_a90);
    ddp_instance_rec.instantiation_flag := p1_a91;
    ddp_instance_rec.linear_location_id := rosetta_g_miss_num_map(p1_a92);
    ddp_instance_rec.operational_log_flag := p1_a93;
    ddp_instance_rec.checkin_status := rosetta_g_miss_num_map(p1_a94);
    ddp_instance_rec.supplier_warranty_exp_date := rosetta_g_miss_date_in_map(p1_a95);
    ddp_instance_rec.attribute16 := p1_a96;
    ddp_instance_rec.attribute17 := p1_a97;
    ddp_instance_rec.attribute18 := p1_a98;
    ddp_instance_rec.attribute19 := p1_a99;
    ddp_instance_rec.attribute20 := p1_a100;
    ddp_instance_rec.attribute21 := p1_a101;
    ddp_instance_rec.attribute22 := p1_a102;
    ddp_instance_rec.attribute23 := p1_a103;
    ddp_instance_rec.attribute24 := p1_a104;
    ddp_instance_rec.attribute25 := p1_a105;
    ddp_instance_rec.attribute26 := p1_a106;
    ddp_instance_rec.attribute27 := p1_a107;
    ddp_instance_rec.attribute28 := p1_a108;
    ddp_instance_rec.attribute29 := p1_a109;
    ddp_instance_rec.attribute30 := p1_a110;
    ddp_instance_rec.purchase_unit_price := rosetta_g_miss_num_map(p1_a111);
    ddp_instance_rec.purchase_currency_code := p1_a112;
    ddp_instance_rec.payables_unit_price := rosetta_g_miss_num_map(p1_a113);
    ddp_instance_rec.payables_currency_code := p1_a114;
    ddp_instance_rec.sales_unit_price := rosetta_g_miss_num_map(p1_a115);
    ddp_instance_rec.sales_currency_code := p1_a116;
    ddp_instance_rec.operational_status_code := p1_a117;
    ddp_instance_rec.department_id := rosetta_g_miss_num_map(p1_a118);
    ddp_instance_rec.wip_accounting_class := p1_a119;
    ddp_instance_rec.area_id := rosetta_g_miss_num_map(p1_a120);
    ddp_instance_rec.owner_party_id := rosetta_g_miss_num_map(p1_a121);
    ddp_instance_rec.source_code := p1_a122;

    csi_fa_instance_grp_w.rosetta_table_copy_in_p4(ddp_instance_serial_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      );

    ddp_eam_rec.category_id := rosetta_g_miss_num_map(p3_a0);
    ddp_eam_rec.asset_criticality_code := p3_a1;
    ddp_eam_rec.owning_department_id := rosetta_g_miss_num_map(p3_a2);
    ddp_eam_rec.wip_accounting_class_code := p3_a3;
    ddp_eam_rec.area_id := rosetta_g_miss_num_map(p3_a4);
    ddp_eam_rec.parent_instance_id := rosetta_g_miss_num_map(p3_a5);









    ddpx_csi_txn_rec.transaction_id := rosetta_g_miss_num_map(p12_a0);
    ddpx_csi_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p12_a1);
    ddpx_csi_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p12_a2);
    ddpx_csi_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p12_a3);
    ddpx_csi_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p12_a4);
    ddpx_csi_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p12_a5);
    ddpx_csi_txn_rec.source_group_ref := p12_a6;
    ddpx_csi_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p12_a7);
    ddpx_csi_txn_rec.source_header_ref := p12_a8;
    ddpx_csi_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p12_a9);
    ddpx_csi_txn_rec.source_line_ref := p12_a10;
    ddpx_csi_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p12_a11);
    ddpx_csi_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p12_a12);
    ddpx_csi_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p12_a13);
    ddpx_csi_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p12_a14);
    ddpx_csi_txn_rec.transaction_uom_code := p12_a15;
    ddpx_csi_txn_rec.transacted_by := rosetta_g_miss_num_map(p12_a16);
    ddpx_csi_txn_rec.transaction_status_code := p12_a17;
    ddpx_csi_txn_rec.transaction_action_code := p12_a18;
    ddpx_csi_txn_rec.message_id := rosetta_g_miss_num_map(p12_a19);
    ddpx_csi_txn_rec.context := p12_a20;
    ddpx_csi_txn_rec.attribute1 := p12_a21;
    ddpx_csi_txn_rec.attribute2 := p12_a22;
    ddpx_csi_txn_rec.attribute3 := p12_a23;
    ddpx_csi_txn_rec.attribute4 := p12_a24;
    ddpx_csi_txn_rec.attribute5 := p12_a25;
    ddpx_csi_txn_rec.attribute6 := p12_a26;
    ddpx_csi_txn_rec.attribute7 := p12_a27;
    ddpx_csi_txn_rec.attribute8 := p12_a28;
    ddpx_csi_txn_rec.attribute9 := p12_a29;
    ddpx_csi_txn_rec.attribute10 := p12_a30;
    ddpx_csi_txn_rec.attribute11 := p12_a31;
    ddpx_csi_txn_rec.attribute12 := p12_a32;
    ddpx_csi_txn_rec.attribute13 := p12_a33;
    ddpx_csi_txn_rec.attribute14 := p12_a34;
    ddpx_csi_txn_rec.attribute15 := p12_a35;
    ddpx_csi_txn_rec.object_version_number := rosetta_g_miss_num_map(p12_a36);
    ddpx_csi_txn_rec.split_reason_code := p12_a37;
    ddpx_csi_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p12_a38);
    ddpx_csi_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p12_a39);





    -- here's the delegated call to the old PL/SQL routine
    csi_fa_instance_grp.copy_item_instance(ddp_fixed_asset_rec,
      ddp_instance_rec,
      ddp_instance_serial_tbl,
      ddp_eam_rec,
      p_copy_parties,
      p_copy_accounts,
      p_copy_contacts,
      p_copy_org_assignments,
      p_copy_asset_assignments,
      p_copy_pricing_attribs,
      p_copy_ext_attribs,
      p_copy_inst_children,
      ddpx_csi_txn_rec,
      ddx_instance_tbl,
      ddx_instance_asset_tbl,
      x_return_status,
      x_error_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_id);
    p12_a1 := ddpx_csi_txn_rec.transaction_date;
    p12_a2 := ddpx_csi_txn_rec.source_transaction_date;
    p12_a3 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_type_id);
    p12_a4 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.txn_sub_type_id);
    p12_a5 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_group_ref_id);
    p12_a6 := ddpx_csi_txn_rec.source_group_ref;
    p12_a7 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_header_ref_id);
    p12_a8 := ddpx_csi_txn_rec.source_header_ref;
    p12_a9 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_line_ref_id);
    p12_a10 := ddpx_csi_txn_rec.source_line_ref;
    p12_a11 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id1);
    p12_a12 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id2);
    p12_a13 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.inv_material_transaction_id);
    p12_a14 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_quantity);
    p12_a15 := ddpx_csi_txn_rec.transaction_uom_code;
    p12_a16 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transacted_by);
    p12_a17 := ddpx_csi_txn_rec.transaction_status_code;
    p12_a18 := ddpx_csi_txn_rec.transaction_action_code;
    p12_a19 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.message_id);
    p12_a20 := ddpx_csi_txn_rec.context;
    p12_a21 := ddpx_csi_txn_rec.attribute1;
    p12_a22 := ddpx_csi_txn_rec.attribute2;
    p12_a23 := ddpx_csi_txn_rec.attribute3;
    p12_a24 := ddpx_csi_txn_rec.attribute4;
    p12_a25 := ddpx_csi_txn_rec.attribute5;
    p12_a26 := ddpx_csi_txn_rec.attribute6;
    p12_a27 := ddpx_csi_txn_rec.attribute7;
    p12_a28 := ddpx_csi_txn_rec.attribute8;
    p12_a29 := ddpx_csi_txn_rec.attribute9;
    p12_a30 := ddpx_csi_txn_rec.attribute10;
    p12_a31 := ddpx_csi_txn_rec.attribute11;
    p12_a32 := ddpx_csi_txn_rec.attribute12;
    p12_a33 := ddpx_csi_txn_rec.attribute13;
    p12_a34 := ddpx_csi_txn_rec.attribute14;
    p12_a35 := ddpx_csi_txn_rec.attribute15;
    p12_a36 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.object_version_number);
    p12_a37 := ddpx_csi_txn_rec.split_reason_code;
    p12_a38 := ddpx_csi_txn_rec.src_txn_creation_date;
    p12_a39 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p19(ddx_instance_tbl, p13_a0
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
      , p13_a54
      , p13_a55
      , p13_a56
      , p13_a57
      , p13_a58
      , p13_a59
      , p13_a60
      , p13_a61
      , p13_a62
      , p13_a63
      , p13_a64
      , p13_a65
      , p13_a66
      , p13_a67
      , p13_a68
      , p13_a69
      , p13_a70
      , p13_a71
      , p13_a72
      , p13_a73
      , p13_a74
      , p13_a75
      , p13_a76
      , p13_a77
      , p13_a78
      , p13_a79
      , p13_a80
      , p13_a81
      , p13_a82
      , p13_a83
      , p13_a84
      , p13_a85
      , p13_a86
      , p13_a87
      , p13_a88
      , p13_a89
      , p13_a90
      , p13_a91
      , p13_a92
      , p13_a93
      , p13_a94
      , p13_a95
      , p13_a96
      , p13_a97
      , p13_a98
      , p13_a99
      , p13_a100
      , p13_a101
      , p13_a102
      , p13_a103
      , p13_a104
      , p13_a105
      , p13_a106
      , p13_a107
      , p13_a108
      , p13_a109
      , p13_a110
      , p13_a111
      , p13_a112
      , p13_a113
      , p13_a114
      , p13_a115
      , p13_a116
      , p13_a117
      , p13_a118
      , p13_a119
      , p13_a120
      , p13_a121
      , p13_a122
      );

    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddx_instance_asset_tbl, p14_a0
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
      );


  end;

  procedure associate_item_instance(p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p1_a10 JTF_NUMBER_TABLE
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_VARCHAR2_TABLE_100
    , p1_a16 JTF_VARCHAR2_TABLE_100
    , p1_a17 JTF_VARCHAR2_TABLE_100
    , p1_a18 JTF_NUMBER_TABLE
    , p1_a19 JTF_VARCHAR2_TABLE_100
    , p1_a20 JTF_DATE_TABLE
    , p1_a21 JTF_DATE_TABLE
    , p1_a22 JTF_VARCHAR2_TABLE_100
    , p1_a23 JTF_NUMBER_TABLE
    , p1_a24 JTF_NUMBER_TABLE
    , p1_a25 JTF_VARCHAR2_TABLE_100
    , p1_a26 JTF_NUMBER_TABLE
    , p1_a27 JTF_NUMBER_TABLE
    , p1_a28 JTF_NUMBER_TABLE
    , p1_a29 JTF_NUMBER_TABLE
    , p1_a30 JTF_NUMBER_TABLE
    , p1_a31 JTF_NUMBER_TABLE
    , p1_a32 JTF_NUMBER_TABLE
    , p1_a33 JTF_NUMBER_TABLE
    , p1_a34 JTF_NUMBER_TABLE
    , p1_a35 JTF_VARCHAR2_TABLE_100
    , p1_a36 JTF_NUMBER_TABLE
    , p1_a37 JTF_NUMBER_TABLE
    , p1_a38 JTF_NUMBER_TABLE
    , p1_a39 JTF_NUMBER_TABLE
    , p1_a40 JTF_DATE_TABLE
    , p1_a41 JTF_VARCHAR2_TABLE_100
    , p1_a42 JTF_DATE_TABLE
    , p1_a43 JTF_DATE_TABLE
    , p1_a44 JTF_VARCHAR2_TABLE_100
    , p1_a45 JTF_VARCHAR2_TABLE_100
    , p1_a46 JTF_VARCHAR2_TABLE_300
    , p1_a47 JTF_VARCHAR2_TABLE_300
    , p1_a48 JTF_VARCHAR2_TABLE_100
    , p1_a49 JTF_VARCHAR2_TABLE_300
    , p1_a50 JTF_VARCHAR2_TABLE_300
    , p1_a51 JTF_VARCHAR2_TABLE_300
    , p1_a52 JTF_VARCHAR2_TABLE_300
    , p1_a53 JTF_VARCHAR2_TABLE_300
    , p1_a54 JTF_VARCHAR2_TABLE_300
    , p1_a55 JTF_VARCHAR2_TABLE_300
    , p1_a56 JTF_VARCHAR2_TABLE_300
    , p1_a57 JTF_VARCHAR2_TABLE_300
    , p1_a58 JTF_VARCHAR2_TABLE_300
    , p1_a59 JTF_VARCHAR2_TABLE_300
    , p1_a60 JTF_VARCHAR2_TABLE_300
    , p1_a61 JTF_VARCHAR2_TABLE_300
    , p1_a62 JTF_VARCHAR2_TABLE_300
    , p1_a63 JTF_VARCHAR2_TABLE_300
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_VARCHAR2_TABLE_100
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_VARCHAR2_TABLE_100
    , p1_a69 JTF_VARCHAR2_TABLE_100
    , p1_a70 JTF_VARCHAR2_TABLE_100
    , p1_a71 JTF_VARCHAR2_TABLE_100
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_VARCHAR2_TABLE_100
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_NUMBER_TABLE
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_VARCHAR2_TABLE_100
    , p1_a78 JTF_VARCHAR2_TABLE_300
    , p1_a79 JTF_VARCHAR2_TABLE_100
    , p1_a80 JTF_NUMBER_TABLE
    , p1_a81 JTF_NUMBER_TABLE
    , p1_a82 JTF_NUMBER_TABLE
    , p1_a83 JTF_DATE_TABLE
    , p1_a84 JTF_VARCHAR2_TABLE_100
    , p1_a85 JTF_VARCHAR2_TABLE_100
    , p1_a86 JTF_VARCHAR2_TABLE_100
    , p1_a87 JTF_NUMBER_TABLE
    , p1_a88 JTF_VARCHAR2_TABLE_100
    , p1_a89 JTF_NUMBER_TABLE
    , p1_a90 JTF_NUMBER_TABLE
    , p1_a91 JTF_VARCHAR2_TABLE_100
    , p1_a92 JTF_NUMBER_TABLE
    , p1_a93 JTF_VARCHAR2_TABLE_100
    , p1_a94 JTF_NUMBER_TABLE
    , p1_a95 JTF_DATE_TABLE
    , p1_a96 JTF_VARCHAR2_TABLE_300
    , p1_a97 JTF_VARCHAR2_TABLE_300
    , p1_a98 JTF_VARCHAR2_TABLE_300
    , p1_a99 JTF_VARCHAR2_TABLE_300
    , p1_a100 JTF_VARCHAR2_TABLE_300
    , p1_a101 JTF_VARCHAR2_TABLE_300
    , p1_a102 JTF_VARCHAR2_TABLE_300
    , p1_a103 JTF_VARCHAR2_TABLE_300
    , p1_a104 JTF_VARCHAR2_TABLE_300
    , p1_a105 JTF_VARCHAR2_TABLE_300
    , p1_a106 JTF_VARCHAR2_TABLE_300
    , p1_a107 JTF_VARCHAR2_TABLE_300
    , p1_a108 JTF_VARCHAR2_TABLE_300
    , p1_a109 JTF_VARCHAR2_TABLE_300
    , p1_a110 JTF_VARCHAR2_TABLE_300
    , p1_a111 JTF_NUMBER_TABLE
    , p1_a112 JTF_VARCHAR2_TABLE_100
    , p1_a113 JTF_NUMBER_TABLE
    , p1_a114 JTF_VARCHAR2_TABLE_100
    , p1_a115 JTF_NUMBER_TABLE
    , p1_a116 JTF_VARCHAR2_TABLE_100
    , p1_a117 JTF_VARCHAR2_TABLE_100
    , p1_a118 JTF_NUMBER_TABLE
    , p1_a119 JTF_VARCHAR2_TABLE_100
    , p1_a120 JTF_NUMBER_TABLE
    , p1_a121 JTF_NUMBER_TABLE
    , p1_a122 JTF_VARCHAR2_TABLE_100
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  DATE
    , p2_a2 in out nocopy  DATE
    , p2_a3 in out nocopy  NUMBER
    , p2_a4 in out nocopy  NUMBER
    , p2_a5 in out nocopy  NUMBER
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  NUMBER
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  NUMBER
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  NUMBER
    , p2_a12 in out nocopy  NUMBER
    , p2_a13 in out nocopy  NUMBER
    , p2_a14 in out nocopy  NUMBER
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  NUMBER
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  NUMBER
    , p2_a20 in out nocopy  VARCHAR2
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  VARCHAR2
    , p2_a24 in out nocopy  VARCHAR2
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  VARCHAR2
    , p2_a36 in out nocopy  NUMBER
    , p2_a37 in out nocopy  VARCHAR2
    , p2_a38 in out nocopy  DATE
    , p2_a39 in out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 out nocopy JTF_DATE_TABLE
    , p3_a8 out nocopy JTF_DATE_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_fixed_asset_rec csi_fa_instance_grp.fixed_asset_rec;
    ddp_instance_tbl csi_datastructures_pub.instance_tbl;
    ddpx_csi_txn_rec csi_datastructures_pub.transaction_rec;
    ddx_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fixed_asset_rec.asset_id := rosetta_g_miss_num_map(p0_a0);
    ddp_fixed_asset_rec.book_type_code := p0_a1;
    ddp_fixed_asset_rec.asset_location_id := rosetta_g_miss_num_map(p0_a2);
    ddp_fixed_asset_rec.asset_quantity := rosetta_g_miss_num_map(p0_a3);
    ddp_fixed_asset_rec.fa_sync_flag := p0_a4;
    ddp_fixed_asset_rec.fa_sync_validation_reqd := p0_a5;

    csi_datastructures_pub_w.rosetta_table_copy_in_p19(ddp_instance_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      , p1_a110
      , p1_a111
      , p1_a112
      , p1_a113
      , p1_a114
      , p1_a115
      , p1_a116
      , p1_a117
      , p1_a118
      , p1_a119
      , p1_a120
      , p1_a121
      , p1_a122
      );

    ddpx_csi_txn_rec.transaction_id := rosetta_g_miss_num_map(p2_a0);
    ddpx_csi_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p2_a1);
    ddpx_csi_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p2_a2);
    ddpx_csi_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p2_a3);
    ddpx_csi_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p2_a4);
    ddpx_csi_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p2_a5);
    ddpx_csi_txn_rec.source_group_ref := p2_a6;
    ddpx_csi_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p2_a7);
    ddpx_csi_txn_rec.source_header_ref := p2_a8;
    ddpx_csi_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p2_a9);
    ddpx_csi_txn_rec.source_line_ref := p2_a10;
    ddpx_csi_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p2_a11);
    ddpx_csi_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p2_a12);
    ddpx_csi_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p2_a13);
    ddpx_csi_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p2_a14);
    ddpx_csi_txn_rec.transaction_uom_code := p2_a15;
    ddpx_csi_txn_rec.transacted_by := rosetta_g_miss_num_map(p2_a16);
    ddpx_csi_txn_rec.transaction_status_code := p2_a17;
    ddpx_csi_txn_rec.transaction_action_code := p2_a18;
    ddpx_csi_txn_rec.message_id := rosetta_g_miss_num_map(p2_a19);
    ddpx_csi_txn_rec.context := p2_a20;
    ddpx_csi_txn_rec.attribute1 := p2_a21;
    ddpx_csi_txn_rec.attribute2 := p2_a22;
    ddpx_csi_txn_rec.attribute3 := p2_a23;
    ddpx_csi_txn_rec.attribute4 := p2_a24;
    ddpx_csi_txn_rec.attribute5 := p2_a25;
    ddpx_csi_txn_rec.attribute6 := p2_a26;
    ddpx_csi_txn_rec.attribute7 := p2_a27;
    ddpx_csi_txn_rec.attribute8 := p2_a28;
    ddpx_csi_txn_rec.attribute9 := p2_a29;
    ddpx_csi_txn_rec.attribute10 := p2_a30;
    ddpx_csi_txn_rec.attribute11 := p2_a31;
    ddpx_csi_txn_rec.attribute12 := p2_a32;
    ddpx_csi_txn_rec.attribute13 := p2_a33;
    ddpx_csi_txn_rec.attribute14 := p2_a34;
    ddpx_csi_txn_rec.attribute15 := p2_a35;
    ddpx_csi_txn_rec.object_version_number := rosetta_g_miss_num_map(p2_a36);
    ddpx_csi_txn_rec.split_reason_code := p2_a37;
    ddpx_csi_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p2_a38);
    ddpx_csi_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p2_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_fa_instance_grp.associate_item_instance(ddp_fixed_asset_rec,
      ddp_instance_tbl,
      ddpx_csi_txn_rec,
      ddx_instance_asset_tbl,
      x_return_status,
      x_error_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_id);
    p2_a1 := ddpx_csi_txn_rec.transaction_date;
    p2_a2 := ddpx_csi_txn_rec.source_transaction_date;
    p2_a3 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_type_id);
    p2_a4 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.txn_sub_type_id);
    p2_a5 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_group_ref_id);
    p2_a6 := ddpx_csi_txn_rec.source_group_ref;
    p2_a7 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_header_ref_id);
    p2_a8 := ddpx_csi_txn_rec.source_header_ref;
    p2_a9 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_line_ref_id);
    p2_a10 := ddpx_csi_txn_rec.source_line_ref;
    p2_a11 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id1);
    p2_a12 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id2);
    p2_a13 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.inv_material_transaction_id);
    p2_a14 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_quantity);
    p2_a15 := ddpx_csi_txn_rec.transaction_uom_code;
    p2_a16 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transacted_by);
    p2_a17 := ddpx_csi_txn_rec.transaction_status_code;
    p2_a18 := ddpx_csi_txn_rec.transaction_action_code;
    p2_a19 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.message_id);
    p2_a20 := ddpx_csi_txn_rec.context;
    p2_a21 := ddpx_csi_txn_rec.attribute1;
    p2_a22 := ddpx_csi_txn_rec.attribute2;
    p2_a23 := ddpx_csi_txn_rec.attribute3;
    p2_a24 := ddpx_csi_txn_rec.attribute4;
    p2_a25 := ddpx_csi_txn_rec.attribute5;
    p2_a26 := ddpx_csi_txn_rec.attribute6;
    p2_a27 := ddpx_csi_txn_rec.attribute7;
    p2_a28 := ddpx_csi_txn_rec.attribute8;
    p2_a29 := ddpx_csi_txn_rec.attribute9;
    p2_a30 := ddpx_csi_txn_rec.attribute10;
    p2_a31 := ddpx_csi_txn_rec.attribute11;
    p2_a32 := ddpx_csi_txn_rec.attribute12;
    p2_a33 := ddpx_csi_txn_rec.attribute13;
    p2_a34 := ddpx_csi_txn_rec.attribute14;
    p2_a35 := ddpx_csi_txn_rec.attribute15;
    p2_a36 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.object_version_number);
    p2_a37 := ddpx_csi_txn_rec.split_reason_code;
    p2_a38 := ddpx_csi_txn_rec.src_txn_creation_date;
    p2_a39 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.gl_interface_status_code);

    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddx_instance_asset_tbl, p3_a0
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
      );


  end;

  procedure update_asset_association(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_VARCHAR2_TABLE_100
    , p0_a7 JTF_DATE_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_VARCHAR2_TABLE_100
    , p0_a15 JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  DATE
    , p1_a3 in out nocopy  NUMBER
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  VARCHAR2
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  VARCHAR2
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  NUMBER
    , p1_a15 in out nocopy  VARCHAR2
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  VARCHAR2
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  VARCHAR2
    , p1_a22 in out nocopy  VARCHAR2
    , p1_a23 in out nocopy  VARCHAR2
    , p1_a24 in out nocopy  VARCHAR2
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  VARCHAR2
    , p1_a29 in out nocopy  VARCHAR2
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  DATE
    , p1_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
  )

  as
    ddp_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddpx_csi_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_in_p52(ddp_instance_asset_tbl, p0_a0
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
      );

    ddpx_csi_txn_rec.transaction_id := rosetta_g_miss_num_map(p1_a0);
    ddpx_csi_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p1_a1);
    ddpx_csi_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p1_a2);
    ddpx_csi_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p1_a3);
    ddpx_csi_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p1_a4);
    ddpx_csi_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p1_a5);
    ddpx_csi_txn_rec.source_group_ref := p1_a6;
    ddpx_csi_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p1_a7);
    ddpx_csi_txn_rec.source_header_ref := p1_a8;
    ddpx_csi_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p1_a9);
    ddpx_csi_txn_rec.source_line_ref := p1_a10;
    ddpx_csi_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p1_a11);
    ddpx_csi_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p1_a12);
    ddpx_csi_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p1_a13);
    ddpx_csi_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p1_a14);
    ddpx_csi_txn_rec.transaction_uom_code := p1_a15;
    ddpx_csi_txn_rec.transacted_by := rosetta_g_miss_num_map(p1_a16);
    ddpx_csi_txn_rec.transaction_status_code := p1_a17;
    ddpx_csi_txn_rec.transaction_action_code := p1_a18;
    ddpx_csi_txn_rec.message_id := rosetta_g_miss_num_map(p1_a19);
    ddpx_csi_txn_rec.context := p1_a20;
    ddpx_csi_txn_rec.attribute1 := p1_a21;
    ddpx_csi_txn_rec.attribute2 := p1_a22;
    ddpx_csi_txn_rec.attribute3 := p1_a23;
    ddpx_csi_txn_rec.attribute4 := p1_a24;
    ddpx_csi_txn_rec.attribute5 := p1_a25;
    ddpx_csi_txn_rec.attribute6 := p1_a26;
    ddpx_csi_txn_rec.attribute7 := p1_a27;
    ddpx_csi_txn_rec.attribute8 := p1_a28;
    ddpx_csi_txn_rec.attribute9 := p1_a29;
    ddpx_csi_txn_rec.attribute10 := p1_a30;
    ddpx_csi_txn_rec.attribute11 := p1_a31;
    ddpx_csi_txn_rec.attribute12 := p1_a32;
    ddpx_csi_txn_rec.attribute13 := p1_a33;
    ddpx_csi_txn_rec.attribute14 := p1_a34;
    ddpx_csi_txn_rec.attribute15 := p1_a35;
    ddpx_csi_txn_rec.object_version_number := rosetta_g_miss_num_map(p1_a36);
    ddpx_csi_txn_rec.split_reason_code := p1_a37;
    ddpx_csi_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p1_a38);
    ddpx_csi_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p1_a39);



    -- here's the delegated call to the old PL/SQL routine
    csi_fa_instance_grp.update_asset_association(ddp_instance_asset_tbl,
      ddpx_csi_txn_rec,
      x_return_status,
      x_error_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_id);
    p1_a1 := ddpx_csi_txn_rec.transaction_date;
    p1_a2 := ddpx_csi_txn_rec.source_transaction_date;
    p1_a3 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_type_id);
    p1_a4 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.txn_sub_type_id);
    p1_a5 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_group_ref_id);
    p1_a6 := ddpx_csi_txn_rec.source_group_ref;
    p1_a7 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_header_ref_id);
    p1_a8 := ddpx_csi_txn_rec.source_header_ref;
    p1_a9 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_line_ref_id);
    p1_a10 := ddpx_csi_txn_rec.source_line_ref;
    p1_a11 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id1);
    p1_a12 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id2);
    p1_a13 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.inv_material_transaction_id);
    p1_a14 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_quantity);
    p1_a15 := ddpx_csi_txn_rec.transaction_uom_code;
    p1_a16 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transacted_by);
    p1_a17 := ddpx_csi_txn_rec.transaction_status_code;
    p1_a18 := ddpx_csi_txn_rec.transaction_action_code;
    p1_a19 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.message_id);
    p1_a20 := ddpx_csi_txn_rec.context;
    p1_a21 := ddpx_csi_txn_rec.attribute1;
    p1_a22 := ddpx_csi_txn_rec.attribute2;
    p1_a23 := ddpx_csi_txn_rec.attribute3;
    p1_a24 := ddpx_csi_txn_rec.attribute4;
    p1_a25 := ddpx_csi_txn_rec.attribute5;
    p1_a26 := ddpx_csi_txn_rec.attribute6;
    p1_a27 := ddpx_csi_txn_rec.attribute7;
    p1_a28 := ddpx_csi_txn_rec.attribute8;
    p1_a29 := ddpx_csi_txn_rec.attribute9;
    p1_a30 := ddpx_csi_txn_rec.attribute10;
    p1_a31 := ddpx_csi_txn_rec.attribute11;
    p1_a32 := ddpx_csi_txn_rec.attribute12;
    p1_a33 := ddpx_csi_txn_rec.attribute13;
    p1_a34 := ddpx_csi_txn_rec.attribute14;
    p1_a35 := ddpx_csi_txn_rec.attribute15;
    p1_a36 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.object_version_number);
    p1_a37 := ddpx_csi_txn_rec.split_reason_code;
    p1_a38 := ddpx_csi_txn_rec.src_txn_creation_date;
    p1_a39 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.gl_interface_status_code);


  end;

  procedure create_instance_assets(p0_a0 in out nocopy JTF_NUMBER_TABLE
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
    , p0_a11 in out nocopy JTF_NUMBER_TABLE
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  DATE
    , p1_a3 in out nocopy  NUMBER
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  VARCHAR2
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  VARCHAR2
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  NUMBER
    , p1_a15 in out nocopy  VARCHAR2
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  VARCHAR2
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  VARCHAR2
    , p1_a22 in out nocopy  VARCHAR2
    , p1_a23 in out nocopy  VARCHAR2
    , p1_a24 in out nocopy  VARCHAR2
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  VARCHAR2
    , p1_a29 in out nocopy  VARCHAR2
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  DATE
    , p1_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
  )

  as
    ddpx_instance_asset_tbl csi_datastructures_pub.instance_asset_tbl;
    ddpx_csi_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_in_p52(ddpx_instance_asset_tbl, p0_a0
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
      );

    ddpx_csi_txn_rec.transaction_id := rosetta_g_miss_num_map(p1_a0);
    ddpx_csi_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p1_a1);
    ddpx_csi_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p1_a2);
    ddpx_csi_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p1_a3);
    ddpx_csi_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p1_a4);
    ddpx_csi_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p1_a5);
    ddpx_csi_txn_rec.source_group_ref := p1_a6;
    ddpx_csi_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p1_a7);
    ddpx_csi_txn_rec.source_header_ref := p1_a8;
    ddpx_csi_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p1_a9);
    ddpx_csi_txn_rec.source_line_ref := p1_a10;
    ddpx_csi_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p1_a11);
    ddpx_csi_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p1_a12);
    ddpx_csi_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p1_a13);
    ddpx_csi_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p1_a14);
    ddpx_csi_txn_rec.transaction_uom_code := p1_a15;
    ddpx_csi_txn_rec.transacted_by := rosetta_g_miss_num_map(p1_a16);
    ddpx_csi_txn_rec.transaction_status_code := p1_a17;
    ddpx_csi_txn_rec.transaction_action_code := p1_a18;
    ddpx_csi_txn_rec.message_id := rosetta_g_miss_num_map(p1_a19);
    ddpx_csi_txn_rec.context := p1_a20;
    ddpx_csi_txn_rec.attribute1 := p1_a21;
    ddpx_csi_txn_rec.attribute2 := p1_a22;
    ddpx_csi_txn_rec.attribute3 := p1_a23;
    ddpx_csi_txn_rec.attribute4 := p1_a24;
    ddpx_csi_txn_rec.attribute5 := p1_a25;
    ddpx_csi_txn_rec.attribute6 := p1_a26;
    ddpx_csi_txn_rec.attribute7 := p1_a27;
    ddpx_csi_txn_rec.attribute8 := p1_a28;
    ddpx_csi_txn_rec.attribute9 := p1_a29;
    ddpx_csi_txn_rec.attribute10 := p1_a30;
    ddpx_csi_txn_rec.attribute11 := p1_a31;
    ddpx_csi_txn_rec.attribute12 := p1_a32;
    ddpx_csi_txn_rec.attribute13 := p1_a33;
    ddpx_csi_txn_rec.attribute14 := p1_a34;
    ddpx_csi_txn_rec.attribute15 := p1_a35;
    ddpx_csi_txn_rec.object_version_number := rosetta_g_miss_num_map(p1_a36);
    ddpx_csi_txn_rec.split_reason_code := p1_a37;
    ddpx_csi_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p1_a38);
    ddpx_csi_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p1_a39);



    -- here's the delegated call to the old PL/SQL routine
    csi_fa_instance_grp.create_instance_assets(ddpx_instance_asset_tbl,
      ddpx_csi_txn_rec,
      x_return_status,
      x_error_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    csi_datastructures_pub_w.rosetta_table_copy_out_p52(ddpx_instance_asset_tbl, p0_a0
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
      );

    p1_a0 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_id);
    p1_a1 := ddpx_csi_txn_rec.transaction_date;
    p1_a2 := ddpx_csi_txn_rec.source_transaction_date;
    p1_a3 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_type_id);
    p1_a4 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.txn_sub_type_id);
    p1_a5 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_group_ref_id);
    p1_a6 := ddpx_csi_txn_rec.source_group_ref;
    p1_a7 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_header_ref_id);
    p1_a8 := ddpx_csi_txn_rec.source_header_ref;
    p1_a9 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_line_ref_id);
    p1_a10 := ddpx_csi_txn_rec.source_line_ref;
    p1_a11 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id1);
    p1_a12 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.source_dist_ref_id2);
    p1_a13 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.inv_material_transaction_id);
    p1_a14 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transaction_quantity);
    p1_a15 := ddpx_csi_txn_rec.transaction_uom_code;
    p1_a16 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.transacted_by);
    p1_a17 := ddpx_csi_txn_rec.transaction_status_code;
    p1_a18 := ddpx_csi_txn_rec.transaction_action_code;
    p1_a19 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.message_id);
    p1_a20 := ddpx_csi_txn_rec.context;
    p1_a21 := ddpx_csi_txn_rec.attribute1;
    p1_a22 := ddpx_csi_txn_rec.attribute2;
    p1_a23 := ddpx_csi_txn_rec.attribute3;
    p1_a24 := ddpx_csi_txn_rec.attribute4;
    p1_a25 := ddpx_csi_txn_rec.attribute5;
    p1_a26 := ddpx_csi_txn_rec.attribute6;
    p1_a27 := ddpx_csi_txn_rec.attribute7;
    p1_a28 := ddpx_csi_txn_rec.attribute8;
    p1_a29 := ddpx_csi_txn_rec.attribute9;
    p1_a30 := ddpx_csi_txn_rec.attribute10;
    p1_a31 := ddpx_csi_txn_rec.attribute11;
    p1_a32 := ddpx_csi_txn_rec.attribute12;
    p1_a33 := ddpx_csi_txn_rec.attribute13;
    p1_a34 := ddpx_csi_txn_rec.attribute14;
    p1_a35 := ddpx_csi_txn_rec.attribute15;
    p1_a36 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.object_version_number);
    p1_a37 := ddpx_csi_txn_rec.split_reason_code;
    p1_a38 := ddpx_csi_txn_rec.src_txn_creation_date;
    p1_a39 := rosetta_g_miss_num_map(ddpx_csi_txn_rec.gl_interface_status_code);


  end;

end csi_fa_instance_grp_w;

/
