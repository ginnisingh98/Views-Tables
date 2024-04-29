--------------------------------------------------------
--  DDL for Package Body CS_SR_EXTATTRIBUTES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_EXTATTRIBUTES_PVT_W" as
  /* $Header: csvextrb.pls 120.4.12010000.2 2009/06/23 10:46:57 lkullamb ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy cs_sr_extattributes_pvt.ext_attr_audit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_DATE_TABLE
    , a89 JTF_DATE_TABLE
    , a90 JTF_DATE_TABLE
    , a91 JTF_DATE_TABLE
    , a92 JTF_DATE_TABLE
    , a93 JTF_DATE_TABLE
    , a94 JTF_DATE_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_DATE_TABLE
    , a97 JTF_DATE_TABLE
    , a98 JTF_DATE_TABLE
    , a99 JTF_DATE_TABLE
    , a100 JTF_DATE_TABLE
    , a101 JTF_DATE_TABLE
    , a102 JTF_DATE_TABLE
    , a103 JTF_DATE_TABLE
    , a104 JTF_DATE_TABLE
    , a105 JTF_DATE_TABLE
    , a106 JTF_DATE_TABLE
    , a107 JTF_DATE_TABLE
    , a108 JTF_DATE_TABLE
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_VARCHAR2_TABLE_100
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_VARCHAR2_TABLE_100
    , a113 JTF_VARCHAR2_TABLE_100
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_100
    , a117 JTF_VARCHAR2_TABLE_100
    , a118 JTF_VARCHAR2_TABLE_100
    , a119 JTF_VARCHAR2_TABLE_100
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_100
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_100
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_VARCHAR2_TABLE_100
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).extension_id := a0(indx);
          t(ddindx).row_identifier := a1(indx);
          t(ddindx).pk_column_1 := a2(indx);
          t(ddindx).pk_column_2 := a3(indx);
          t(ddindx).pk_column_3 := a4(indx);
          t(ddindx).pk_column_4 := a5(indx);
          t(ddindx).pk_column_5 := a6(indx);
          t(ddindx).context := a7(indx);
          t(ddindx).attr_group_id := a8(indx);
          t(ddindx).c_ext_attr1 := a9(indx);
          t(ddindx).c_ext_attr2 := a10(indx);
          t(ddindx).c_ext_attr3 := a11(indx);
          t(ddindx).c_ext_attr4 := a12(indx);
          t(ddindx).c_ext_attr5 := a13(indx);
          t(ddindx).c_ext_attr6 := a14(indx);
          t(ddindx).c_ext_attr7 := a15(indx);
          t(ddindx).c_ext_attr8 := a16(indx);
          t(ddindx).c_ext_attr9 := a17(indx);
          t(ddindx).c_ext_attr10 := a18(indx);
          t(ddindx).c_ext_attr11 := a19(indx);
          t(ddindx).c_ext_attr12 := a20(indx);
          t(ddindx).c_ext_attr13 := a21(indx);
          t(ddindx).c_ext_attr14 := a22(indx);
          t(ddindx).c_ext_attr15 := a23(indx);
          t(ddindx).c_ext_attr16 := a24(indx);
          t(ddindx).c_ext_attr17 := a25(indx);
          t(ddindx).c_ext_attr18 := a26(indx);
          t(ddindx).c_ext_attr19 := a27(indx);
          t(ddindx).c_ext_attr20 := a28(indx);
          t(ddindx).c_ext_attr21 := a29(indx);
          t(ddindx).c_ext_attr22 := a30(indx);
          t(ddindx).c_ext_attr23 := a31(indx);
          t(ddindx).c_ext_attr24 := a32(indx);
          t(ddindx).c_ext_attr25 := a33(indx);
          t(ddindx).c_ext_attr26 := a34(indx);
          t(ddindx).c_ext_attr27 := a35(indx);
          t(ddindx).c_ext_attr28 := a36(indx);
          t(ddindx).c_ext_attr29 := a37(indx);
          t(ddindx).c_ext_attr30 := a38(indx);
          t(ddindx).c_ext_attr31 := a39(indx);
          t(ddindx).c_ext_attr32 := a40(indx);
          t(ddindx).c_ext_attr33 := a41(indx);
          t(ddindx).c_ext_attr34 := a42(indx);
          t(ddindx).c_ext_attr35 := a43(indx);
          t(ddindx).c_ext_attr36 := a44(indx);
          t(ddindx).c_ext_attr37 := a45(indx);
          t(ddindx).c_ext_attr38 := a46(indx);
          t(ddindx).c_ext_attr39 := a47(indx);
          t(ddindx).c_ext_attr40 := a48(indx);
          t(ddindx).c_ext_attr41 := a49(indx);
          t(ddindx).c_ext_attr42 := a50(indx);
          t(ddindx).c_ext_attr43 := a51(indx);
          t(ddindx).c_ext_attr44 := a52(indx);
          t(ddindx).c_ext_attr45 := a53(indx);
          t(ddindx).c_ext_attr46 := a54(indx);
          t(ddindx).c_ext_attr47 := a55(indx);
          t(ddindx).c_ext_attr48 := a56(indx);
          t(ddindx).c_ext_attr49 := a57(indx);
          t(ddindx).c_ext_attr50 := a58(indx);
          t(ddindx).n_ext_attr1 := a59(indx);
          t(ddindx).n_ext_attr2 := a60(indx);
          t(ddindx).n_ext_attr3 := a61(indx);
          t(ddindx).n_ext_attr4 := a62(indx);
          t(ddindx).n_ext_attr5 := a63(indx);
          t(ddindx).n_ext_attr6 := a64(indx);
          t(ddindx).n_ext_attr7 := a65(indx);
          t(ddindx).n_ext_attr8 := a66(indx);
          t(ddindx).n_ext_attr9 := a67(indx);
          t(ddindx).n_ext_attr10 := a68(indx);
          t(ddindx).n_ext_attr11 := a69(indx);
          t(ddindx).n_ext_attr12 := a70(indx);
          t(ddindx).n_ext_attr13 := a71(indx);
          t(ddindx).n_ext_attr14 := a72(indx);
          t(ddindx).n_ext_attr15 := a73(indx);
          t(ddindx).n_ext_attr16 := a74(indx);
          t(ddindx).n_ext_attr17 := a75(indx);
          t(ddindx).n_ext_attr18 := a76(indx);
          t(ddindx).n_ext_attr19 := a77(indx);
          t(ddindx).n_ext_attr20 := a78(indx);
          t(ddindx).n_ext_attr21 := a79(indx);
          t(ddindx).n_ext_attr22 := a80(indx);
          t(ddindx).n_ext_attr23 := a81(indx);
          t(ddindx).n_ext_attr24 := a82(indx);
          t(ddindx).n_ext_attr25 := a83(indx);
          t(ddindx).d_ext_attr1 := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).d_ext_attr2 := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).d_ext_attr3 := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).d_ext_attr4 := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).d_ext_attr5 := rosetta_g_miss_date_in_map(a88(indx));
          t(ddindx).d_ext_attr6 := rosetta_g_miss_date_in_map(a89(indx));
          t(ddindx).d_ext_attr7 := rosetta_g_miss_date_in_map(a90(indx));
          t(ddindx).d_ext_attr8 := rosetta_g_miss_date_in_map(a91(indx));
          t(ddindx).d_ext_attr9 := rosetta_g_miss_date_in_map(a92(indx));
          t(ddindx).d_ext_attr10 := rosetta_g_miss_date_in_map(a93(indx));
          t(ddindx).d_ext_attr11 := rosetta_g_miss_date_in_map(a94(indx));
          t(ddindx).d_ext_attr12 := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).d_ext_attr13 := rosetta_g_miss_date_in_map(a96(indx));
          t(ddindx).d_ext_attr14 := rosetta_g_miss_date_in_map(a97(indx));
          t(ddindx).d_ext_attr15 := rosetta_g_miss_date_in_map(a98(indx));
          t(ddindx).d_ext_attr16 := rosetta_g_miss_date_in_map(a99(indx));
          t(ddindx).d_ext_attr17 := rosetta_g_miss_date_in_map(a100(indx));
          t(ddindx).d_ext_attr18 := rosetta_g_miss_date_in_map(a101(indx));
          t(ddindx).d_ext_attr19 := rosetta_g_miss_date_in_map(a102(indx));
          t(ddindx).d_ext_attr20 := rosetta_g_miss_date_in_map(a103(indx));
          t(ddindx).d_ext_attr21 := rosetta_g_miss_date_in_map(a104(indx));
          t(ddindx).d_ext_attr22 := rosetta_g_miss_date_in_map(a105(indx));
          t(ddindx).d_ext_attr23 := rosetta_g_miss_date_in_map(a106(indx));
          t(ddindx).d_ext_attr24 := rosetta_g_miss_date_in_map(a107(indx));
          t(ddindx).d_ext_attr25 := rosetta_g_miss_date_in_map(a108(indx));
          t(ddindx).uom_ext_attr1 := a109(indx);
          t(ddindx).uom_ext_attr2 := a110(indx);
          t(ddindx).uom_ext_attr3 := a111(indx);
          t(ddindx).uom_ext_attr4 := a112(indx);
          t(ddindx).uom_ext_attr5 := a113(indx);
          t(ddindx).uom_ext_attr6 := a114(indx);
          t(ddindx).uom_ext_attr7 := a115(indx);
          t(ddindx).uom_ext_attr8 := a116(indx);
          t(ddindx).uom_ext_attr9 := a117(indx);
          t(ddindx).uom_ext_attr10 := a118(indx);
          t(ddindx).uom_ext_attr11 := a119(indx);
          t(ddindx).uom_ext_attr12 := a120(indx);
          t(ddindx).uom_ext_attr13 := a121(indx);
          t(ddindx).uom_ext_attr14 := a122(indx);
          t(ddindx).uom_ext_attr15 := a123(indx);
          t(ddindx).uom_ext_attr16 := a124(indx);
          t(ddindx).uom_ext_attr17 := a125(indx);
          t(ddindx).uom_ext_attr18 := a126(indx);
          t(ddindx).uom_ext_attr19 := a127(indx);
          t(ddindx).uom_ext_attr20 := a128(indx);
          t(ddindx).uom_ext_attr21 := a129(indx);
          t(ddindx).uom_ext_attr22 := a130(indx);
          t(ddindx).uom_ext_attr23 := a131(indx);
          t(ddindx).uom_ext_attr24 := a132(indx);
          t(ddindx).uom_ext_attr25 := a133(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cs_sr_extattributes_pvt.ext_attr_audit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_DATE_TABLE
    , a89 out nocopy JTF_DATE_TABLE
    , a90 out nocopy JTF_DATE_TABLE
    , a91 out nocopy JTF_DATE_TABLE
    , a92 out nocopy JTF_DATE_TABLE
    , a93 out nocopy JTF_DATE_TABLE
    , a94 out nocopy JTF_DATE_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_DATE_TABLE
    , a97 out nocopy JTF_DATE_TABLE
    , a98 out nocopy JTF_DATE_TABLE
    , a99 out nocopy JTF_DATE_TABLE
    , a100 out nocopy JTF_DATE_TABLE
    , a101 out nocopy JTF_DATE_TABLE
    , a102 out nocopy JTF_DATE_TABLE
    , a103 out nocopy JTF_DATE_TABLE
    , a104 out nocopy JTF_DATE_TABLE
    , a105 out nocopy JTF_DATE_TABLE
    , a106 out nocopy JTF_DATE_TABLE
    , a107 out nocopy JTF_DATE_TABLE
    , a108 out nocopy JTF_DATE_TABLE
    , a109 out nocopy JTF_VARCHAR2_TABLE_100
    , a110 out nocopy JTF_VARCHAR2_TABLE_100
    , a111 out nocopy JTF_VARCHAR2_TABLE_100
    , a112 out nocopy JTF_VARCHAR2_TABLE_100
    , a113 out nocopy JTF_VARCHAR2_TABLE_100
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
    , a115 out nocopy JTF_VARCHAR2_TABLE_100
    , a116 out nocopy JTF_VARCHAR2_TABLE_100
    , a117 out nocopy JTF_VARCHAR2_TABLE_100
    , a118 out nocopy JTF_VARCHAR2_TABLE_100
    , a119 out nocopy JTF_VARCHAR2_TABLE_100
    , a120 out nocopy JTF_VARCHAR2_TABLE_100
    , a121 out nocopy JTF_VARCHAR2_TABLE_100
    , a122 out nocopy JTF_VARCHAR2_TABLE_100
    , a123 out nocopy JTF_VARCHAR2_TABLE_100
    , a124 out nocopy JTF_VARCHAR2_TABLE_100
    , a125 out nocopy JTF_VARCHAR2_TABLE_100
    , a126 out nocopy JTF_VARCHAR2_TABLE_100
    , a127 out nocopy JTF_VARCHAR2_TABLE_100
    , a128 out nocopy JTF_VARCHAR2_TABLE_100
    , a129 out nocopy JTF_VARCHAR2_TABLE_100
    , a130 out nocopy JTF_VARCHAR2_TABLE_100
    , a131 out nocopy JTF_VARCHAR2_TABLE_100
    , a132 out nocopy JTF_VARCHAR2_TABLE_100
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_DATE_TABLE();
    a89 := JTF_DATE_TABLE();
    a90 := JTF_DATE_TABLE();
    a91 := JTF_DATE_TABLE();
    a92 := JTF_DATE_TABLE();
    a93 := JTF_DATE_TABLE();
    a94 := JTF_DATE_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_DATE_TABLE();
    a97 := JTF_DATE_TABLE();
    a98 := JTF_DATE_TABLE();
    a99 := JTF_DATE_TABLE();
    a100 := JTF_DATE_TABLE();
    a101 := JTF_DATE_TABLE();
    a102 := JTF_DATE_TABLE();
    a103 := JTF_DATE_TABLE();
    a104 := JTF_DATE_TABLE();
    a105 := JTF_DATE_TABLE();
    a106 := JTF_DATE_TABLE();
    a107 := JTF_DATE_TABLE();
    a108 := JTF_DATE_TABLE();
    a109 := JTF_VARCHAR2_TABLE_100();
    a110 := JTF_VARCHAR2_TABLE_100();
    a111 := JTF_VARCHAR2_TABLE_100();
    a112 := JTF_VARCHAR2_TABLE_100();
    a113 := JTF_VARCHAR2_TABLE_100();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_100();
    a117 := JTF_VARCHAR2_TABLE_100();
    a118 := JTF_VARCHAR2_TABLE_100();
    a119 := JTF_VARCHAR2_TABLE_100();
    a120 := JTF_VARCHAR2_TABLE_100();
    a121 := JTF_VARCHAR2_TABLE_100();
    a122 := JTF_VARCHAR2_TABLE_100();
    a123 := JTF_VARCHAR2_TABLE_100();
    a124 := JTF_VARCHAR2_TABLE_100();
    a125 := JTF_VARCHAR2_TABLE_100();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_100();
    a128 := JTF_VARCHAR2_TABLE_100();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_VARCHAR2_TABLE_100();
    a131 := JTF_VARCHAR2_TABLE_100();
    a132 := JTF_VARCHAR2_TABLE_100();
    a133 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_DATE_TABLE();
      a89 := JTF_DATE_TABLE();
      a90 := JTF_DATE_TABLE();
      a91 := JTF_DATE_TABLE();
      a92 := JTF_DATE_TABLE();
      a93 := JTF_DATE_TABLE();
      a94 := JTF_DATE_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_DATE_TABLE();
      a97 := JTF_DATE_TABLE();
      a98 := JTF_DATE_TABLE();
      a99 := JTF_DATE_TABLE();
      a100 := JTF_DATE_TABLE();
      a101 := JTF_DATE_TABLE();
      a102 := JTF_DATE_TABLE();
      a103 := JTF_DATE_TABLE();
      a104 := JTF_DATE_TABLE();
      a105 := JTF_DATE_TABLE();
      a106 := JTF_DATE_TABLE();
      a107 := JTF_DATE_TABLE();
      a108 := JTF_DATE_TABLE();
      a109 := JTF_VARCHAR2_TABLE_100();
      a110 := JTF_VARCHAR2_TABLE_100();
      a111 := JTF_VARCHAR2_TABLE_100();
      a112 := JTF_VARCHAR2_TABLE_100();
      a113 := JTF_VARCHAR2_TABLE_100();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_100();
      a117 := JTF_VARCHAR2_TABLE_100();
      a118 := JTF_VARCHAR2_TABLE_100();
      a119 := JTF_VARCHAR2_TABLE_100();
      a120 := JTF_VARCHAR2_TABLE_100();
      a121 := JTF_VARCHAR2_TABLE_100();
      a122 := JTF_VARCHAR2_TABLE_100();
      a123 := JTF_VARCHAR2_TABLE_100();
      a124 := JTF_VARCHAR2_TABLE_100();
      a125 := JTF_VARCHAR2_TABLE_100();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_100();
      a128 := JTF_VARCHAR2_TABLE_100();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_VARCHAR2_TABLE_100();
      a131 := JTF_VARCHAR2_TABLE_100();
      a132 := JTF_VARCHAR2_TABLE_100();
      a133 := JTF_VARCHAR2_TABLE_100();
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
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).extension_id;
          a1(indx) := t(ddindx).row_identifier;
          a2(indx) := t(ddindx).pk_column_1;
          a3(indx) := t(ddindx).pk_column_2;
          a4(indx) := t(ddindx).pk_column_3;
          a5(indx) := t(ddindx).pk_column_4;
          a6(indx) := t(ddindx).pk_column_5;
          a7(indx) := t(ddindx).context;
          a8(indx) := t(ddindx).attr_group_id;
          a9(indx) := t(ddindx).c_ext_attr1;
          a10(indx) := t(ddindx).c_ext_attr2;
          a11(indx) := t(ddindx).c_ext_attr3;
          a12(indx) := t(ddindx).c_ext_attr4;
          a13(indx) := t(ddindx).c_ext_attr5;
          a14(indx) := t(ddindx).c_ext_attr6;
          a15(indx) := t(ddindx).c_ext_attr7;
          a16(indx) := t(ddindx).c_ext_attr8;
          a17(indx) := t(ddindx).c_ext_attr9;
          a18(indx) := t(ddindx).c_ext_attr10;
          a19(indx) := t(ddindx).c_ext_attr11;
          a20(indx) := t(ddindx).c_ext_attr12;
          a21(indx) := t(ddindx).c_ext_attr13;
          a22(indx) := t(ddindx).c_ext_attr14;
          a23(indx) := t(ddindx).c_ext_attr15;
          a24(indx) := t(ddindx).c_ext_attr16;
          a25(indx) := t(ddindx).c_ext_attr17;
          a26(indx) := t(ddindx).c_ext_attr18;
          a27(indx) := t(ddindx).c_ext_attr19;
          a28(indx) := t(ddindx).c_ext_attr20;
          a29(indx) := t(ddindx).c_ext_attr21;
          a30(indx) := t(ddindx).c_ext_attr22;
          a31(indx) := t(ddindx).c_ext_attr23;
          a32(indx) := t(ddindx).c_ext_attr24;
          a33(indx) := t(ddindx).c_ext_attr25;
          a34(indx) := t(ddindx).c_ext_attr26;
          a35(indx) := t(ddindx).c_ext_attr27;
          a36(indx) := t(ddindx).c_ext_attr28;
          a37(indx) := t(ddindx).c_ext_attr29;
          a38(indx) := t(ddindx).c_ext_attr30;
          a39(indx) := t(ddindx).c_ext_attr31;
          a40(indx) := t(ddindx).c_ext_attr32;
          a41(indx) := t(ddindx).c_ext_attr33;
          a42(indx) := t(ddindx).c_ext_attr34;
          a43(indx) := t(ddindx).c_ext_attr35;
          a44(indx) := t(ddindx).c_ext_attr36;
          a45(indx) := t(ddindx).c_ext_attr37;
          a46(indx) := t(ddindx).c_ext_attr38;
          a47(indx) := t(ddindx).c_ext_attr39;
          a48(indx) := t(ddindx).c_ext_attr40;
          a49(indx) := t(ddindx).c_ext_attr41;
          a50(indx) := t(ddindx).c_ext_attr42;
          a51(indx) := t(ddindx).c_ext_attr43;
          a52(indx) := t(ddindx).c_ext_attr44;
          a53(indx) := t(ddindx).c_ext_attr45;
          a54(indx) := t(ddindx).c_ext_attr46;
          a55(indx) := t(ddindx).c_ext_attr47;
          a56(indx) := t(ddindx).c_ext_attr48;
          a57(indx) := t(ddindx).c_ext_attr49;
          a58(indx) := t(ddindx).c_ext_attr50;
          a59(indx) := t(ddindx).n_ext_attr1;
          a60(indx) := t(ddindx).n_ext_attr2;
          a61(indx) := t(ddindx).n_ext_attr3;
          a62(indx) := t(ddindx).n_ext_attr4;
          a63(indx) := t(ddindx).n_ext_attr5;
          a64(indx) := t(ddindx).n_ext_attr6;
          a65(indx) := t(ddindx).n_ext_attr7;
          a66(indx) := t(ddindx).n_ext_attr8;
          a67(indx) := t(ddindx).n_ext_attr9;
          a68(indx) := t(ddindx).n_ext_attr10;
          a69(indx) := t(ddindx).n_ext_attr11;
          a70(indx) := t(ddindx).n_ext_attr12;
          a71(indx) := t(ddindx).n_ext_attr13;
          a72(indx) := t(ddindx).n_ext_attr14;
          a73(indx) := t(ddindx).n_ext_attr15;
          a74(indx) := t(ddindx).n_ext_attr16;
          a75(indx) := t(ddindx).n_ext_attr17;
          a76(indx) := t(ddindx).n_ext_attr18;
          a77(indx) := t(ddindx).n_ext_attr19;
          a78(indx) := t(ddindx).n_ext_attr20;
          a79(indx) := t(ddindx).n_ext_attr21;
          a80(indx) := t(ddindx).n_ext_attr22;
          a81(indx) := t(ddindx).n_ext_attr23;
          a82(indx) := t(ddindx).n_ext_attr24;
          a83(indx) := t(ddindx).n_ext_attr25;
          a84(indx) := t(ddindx).d_ext_attr1;
          a85(indx) := t(ddindx).d_ext_attr2;
          a86(indx) := t(ddindx).d_ext_attr3;
          a87(indx) := t(ddindx).d_ext_attr4;
          a88(indx) := t(ddindx).d_ext_attr5;
          a89(indx) := t(ddindx).d_ext_attr6;
          a90(indx) := t(ddindx).d_ext_attr7;
          a91(indx) := t(ddindx).d_ext_attr8;
          a92(indx) := t(ddindx).d_ext_attr9;
          a93(indx) := t(ddindx).d_ext_attr10;
          a94(indx) := t(ddindx).d_ext_attr11;
          a95(indx) := t(ddindx).d_ext_attr12;
          a96(indx) := t(ddindx).d_ext_attr13;
          a97(indx) := t(ddindx).d_ext_attr14;
          a98(indx) := t(ddindx).d_ext_attr15;
          a99(indx) := t(ddindx).d_ext_attr16;
          a100(indx) := t(ddindx).d_ext_attr17;
          a101(indx) := t(ddindx).d_ext_attr18;
          a102(indx) := t(ddindx).d_ext_attr19;
          a103(indx) := t(ddindx).d_ext_attr20;
          a104(indx) := t(ddindx).d_ext_attr21;
          a105(indx) := t(ddindx).d_ext_attr22;
          a106(indx) := t(ddindx).d_ext_attr23;
          a107(indx) := t(ddindx).d_ext_attr24;
          a108(indx) := t(ddindx).d_ext_attr25;
          a109(indx) := t(ddindx).uom_ext_attr1;
          a110(indx) := t(ddindx).uom_ext_attr2;
          a111(indx) := t(ddindx).uom_ext_attr3;
          a112(indx) := t(ddindx).uom_ext_attr4;
          a113(indx) := t(ddindx).uom_ext_attr5;
          a114(indx) := t(ddindx).uom_ext_attr6;
          a115(indx) := t(ddindx).uom_ext_attr7;
          a116(indx) := t(ddindx).uom_ext_attr8;
          a117(indx) := t(ddindx).uom_ext_attr9;
          a118(indx) := t(ddindx).uom_ext_attr10;
          a119(indx) := t(ddindx).uom_ext_attr11;
          a120(indx) := t(ddindx).uom_ext_attr12;
          a121(indx) := t(ddindx).uom_ext_attr13;
          a122(indx) := t(ddindx).uom_ext_attr14;
          a123(indx) := t(ddindx).uom_ext_attr15;
          a124(indx) := t(ddindx).uom_ext_attr16;
          a125(indx) := t(ddindx).uom_ext_attr17;
          a126(indx) := t(ddindx).uom_ext_attr18;
          a127(indx) := t(ddindx).uom_ext_attr19;
          a128(indx) := t(ddindx).uom_ext_attr20;
          a129(indx) := t(ddindx).uom_ext_attr21;
          a130(indx) := t(ddindx).uom_ext_attr22;
          a131(indx) := t(ddindx).uom_ext_attr23;
          a132(indx) := t(ddindx).uom_ext_attr24;
          a133(indx) := t(ddindx).uom_ext_attr25;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy cs_sr_extattributes_pvt.ext_grp_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).row_identifier := a0(indx);
          t(ddindx).attr_group_id := a1(indx);
          t(ddindx).attr_group_type := a2(indx);
          t(ddindx).attr_group_name := a3(indx);
          t(ddindx).attr_group_disp_name := a4(indx);
          t(ddindx).column_name := a5(indx);
          t(ddindx).attr_name := a6(indx);
          t(ddindx).attr_value_str := a7(indx);
          t(ddindx).attr_value_num := a8(indx);
          t(ddindx).attr_value_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).attr_value_display := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t cs_sr_extattributes_pvt.ext_grp_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_1000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).row_identifier;
          a1(indx) := t(ddindx).attr_group_id;
          a2(indx) := t(ddindx).attr_group_type;
          a3(indx) := t(ddindx).attr_group_name;
          a4(indx) := t(ddindx).attr_group_disp_name;
          a5(indx) := t(ddindx).column_name;
          a6(indx) := t(ddindx).attr_name;
          a7(indx) := t(ddindx).attr_value_str;
          a8(indx) := t(ddindx).attr_value_num;
          a9(indx) := t(ddindx).attr_value_date;
          a10(indx) := t(ddindx).attr_value_display;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure get_sr_ext_attrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_incident_id  NUMBER
    , p_object_name  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_ext_attr_grp_tbl cs_servicerequest_pub.ext_attr_grp_tbl_type;
    ddx_ext_attr_tbl cs_servicerequest_pub.ext_attr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.get_sr_ext_attrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_incident_id,
      p_object_name,
      ddx_ext_attr_grp_tbl,
      ddx_ext_attr_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cs_servicerequest_pub_w.rosetta_table_copy_out_p8(ddx_ext_attr_grp_tbl, p5_a0
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
      );

    cs_servicerequest_pub_w.rosetta_table_copy_out_p10(ddx_ext_attr_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );



  end;

  procedure process_sr_ext_attrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_incident_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_200
    , p4_a2 JTF_VARCHAR2_TABLE_200
    , p4_a3 JTF_VARCHAR2_TABLE_200
    , p4_a4 JTF_VARCHAR2_TABLE_200
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_failed_row_id_list out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_errorcode out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ext_attr_grp_tbl cs_servicerequest_pub.ext_attr_grp_tbl_type;
    ddp_ext_attr_tbl cs_servicerequest_pub.ext_attr_tbl_type;
    ddp_modified_on date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cs_servicerequest_pub_w.rosetta_table_copy_in_p8(ddp_ext_attr_grp_tbl, p4_a0
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
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p10(ddp_ext_attr_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    ddp_modified_on := rosetta_g_miss_date_in_map(p_modified_on);






    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.process_sr_ext_attrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_incident_id,
      ddp_ext_attr_grp_tbl,
      ddp_ext_attr_tbl,
      p_modified_by,
      ddp_modified_on,
      x_failed_row_id_list,
      x_return_status,
      x_errorcode,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure create_ext_attr_audit(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p0_a3 JTF_VARCHAR2_TABLE_200
    , p0_a4 JTF_VARCHAR2_TABLE_200
    , p0_a5 JTF_VARCHAR2_TABLE_200
    , p0_a6 JTF_VARCHAR2_TABLE_200
    , p0_a7 JTF_VARCHAR2_TABLE_200
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_VARCHAR2_TABLE_200
    , p0_a10 JTF_VARCHAR2_TABLE_200
    , p0_a11 JTF_VARCHAR2_TABLE_200
    , p0_a12 JTF_VARCHAR2_TABLE_200
    , p0_a13 JTF_VARCHAR2_TABLE_200
    , p0_a14 JTF_VARCHAR2_TABLE_200
    , p0_a15 JTF_VARCHAR2_TABLE_200
    , p0_a16 JTF_VARCHAR2_TABLE_200
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_VARCHAR2_TABLE_200
    , p0_a38 JTF_VARCHAR2_TABLE_200
    , p0_a39 JTF_VARCHAR2_TABLE_200
    , p0_a40 JTF_VARCHAR2_TABLE_200
    , p0_a41 JTF_VARCHAR2_TABLE_200
    , p0_a42 JTF_VARCHAR2_TABLE_200
    , p0_a43 JTF_VARCHAR2_TABLE_200
    , p0_a44 JTF_VARCHAR2_TABLE_200
    , p0_a45 JTF_VARCHAR2_TABLE_200
    , p0_a46 JTF_VARCHAR2_TABLE_200
    , p0_a47 JTF_VARCHAR2_TABLE_200
    , p0_a48 JTF_VARCHAR2_TABLE_200
    , p0_a49 JTF_VARCHAR2_TABLE_200
    , p0_a50 JTF_VARCHAR2_TABLE_200
    , p0_a51 JTF_VARCHAR2_TABLE_200
    , p0_a52 JTF_VARCHAR2_TABLE_200
    , p0_a53 JTF_VARCHAR2_TABLE_200
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p0_a55 JTF_VARCHAR2_TABLE_200
    , p0_a56 JTF_VARCHAR2_TABLE_200
    , p0_a57 JTF_VARCHAR2_TABLE_200
    , p0_a58 JTF_VARCHAR2_TABLE_200
    , p0_a59 JTF_NUMBER_TABLE
    , p0_a60 JTF_NUMBER_TABLE
    , p0_a61 JTF_NUMBER_TABLE
    , p0_a62 JTF_NUMBER_TABLE
    , p0_a63 JTF_NUMBER_TABLE
    , p0_a64 JTF_NUMBER_TABLE
    , p0_a65 JTF_NUMBER_TABLE
    , p0_a66 JTF_NUMBER_TABLE
    , p0_a67 JTF_NUMBER_TABLE
    , p0_a68 JTF_NUMBER_TABLE
    , p0_a69 JTF_NUMBER_TABLE
    , p0_a70 JTF_NUMBER_TABLE
    , p0_a71 JTF_NUMBER_TABLE
    , p0_a72 JTF_NUMBER_TABLE
    , p0_a73 JTF_NUMBER_TABLE
    , p0_a74 JTF_NUMBER_TABLE
    , p0_a75 JTF_NUMBER_TABLE
    , p0_a76 JTF_NUMBER_TABLE
    , p0_a77 JTF_NUMBER_TABLE
    , p0_a78 JTF_NUMBER_TABLE
    , p0_a79 JTF_NUMBER_TABLE
    , p0_a80 JTF_NUMBER_TABLE
    , p0_a81 JTF_NUMBER_TABLE
    , p0_a82 JTF_NUMBER_TABLE
    , p0_a83 JTF_NUMBER_TABLE
    , p0_a84 JTF_DATE_TABLE
    , p0_a85 JTF_DATE_TABLE
    , p0_a86 JTF_DATE_TABLE
    , p0_a87 JTF_DATE_TABLE
    , p0_a88 JTF_DATE_TABLE
    , p0_a89 JTF_DATE_TABLE
    , p0_a90 JTF_DATE_TABLE
    , p0_a91 JTF_DATE_TABLE
    , p0_a92 JTF_DATE_TABLE
    , p0_a93 JTF_DATE_TABLE
    , p0_a94 JTF_DATE_TABLE
    , p0_a95 JTF_DATE_TABLE
    , p0_a96 JTF_DATE_TABLE
    , p0_a97 JTF_DATE_TABLE
    , p0_a98 JTF_DATE_TABLE
    , p0_a99 JTF_DATE_TABLE
    , p0_a100 JTF_DATE_TABLE
    , p0_a101 JTF_DATE_TABLE
    , p0_a102 JTF_DATE_TABLE
    , p0_a103 JTF_DATE_TABLE
    , p0_a104 JTF_DATE_TABLE
    , p0_a105 JTF_DATE_TABLE
    , p0_a106 JTF_DATE_TABLE
    , p0_a107 JTF_DATE_TABLE
    , p0_a108 JTF_DATE_TABLE
    , p0_a109 JTF_VARCHAR2_TABLE_100
    , p0_a110 JTF_VARCHAR2_TABLE_100
    , p0_a111 JTF_VARCHAR2_TABLE_100
    , p0_a112 JTF_VARCHAR2_TABLE_100
    , p0_a113 JTF_VARCHAR2_TABLE_100
    , p0_a114 JTF_VARCHAR2_TABLE_100
    , p0_a115 JTF_VARCHAR2_TABLE_100
    , p0_a116 JTF_VARCHAR2_TABLE_100
    , p0_a117 JTF_VARCHAR2_TABLE_100
    , p0_a118 JTF_VARCHAR2_TABLE_100
    , p0_a119 JTF_VARCHAR2_TABLE_100
    , p0_a120 JTF_VARCHAR2_TABLE_100
    , p0_a121 JTF_VARCHAR2_TABLE_100
    , p0_a122 JTF_VARCHAR2_TABLE_100
    , p0_a123 JTF_VARCHAR2_TABLE_100
    , p0_a124 JTF_VARCHAR2_TABLE_100
    , p0_a125 JTF_VARCHAR2_TABLE_100
    , p0_a126 JTF_VARCHAR2_TABLE_100
    , p0_a127 JTF_VARCHAR2_TABLE_100
    , p0_a128 JTF_VARCHAR2_TABLE_100
    , p0_a129 JTF_VARCHAR2_TABLE_100
    , p0_a130 JTF_VARCHAR2_TABLE_100
    , p0_a131 JTF_VARCHAR2_TABLE_100
    , p0_a132 JTF_VARCHAR2_TABLE_100
    , p0_a133 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p1_a3 JTF_VARCHAR2_TABLE_200
    , p1_a4 JTF_VARCHAR2_TABLE_200
    , p1_a5 JTF_VARCHAR2_TABLE_200
    , p1_a6 JTF_VARCHAR2_TABLE_200
    , p1_a7 JTF_VARCHAR2_TABLE_200
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_VARCHAR2_TABLE_200
    , p1_a10 JTF_VARCHAR2_TABLE_200
    , p1_a11 JTF_VARCHAR2_TABLE_200
    , p1_a12 JTF_VARCHAR2_TABLE_200
    , p1_a13 JTF_VARCHAR2_TABLE_200
    , p1_a14 JTF_VARCHAR2_TABLE_200
    , p1_a15 JTF_VARCHAR2_TABLE_200
    , p1_a16 JTF_VARCHAR2_TABLE_200
    , p1_a17 JTF_VARCHAR2_TABLE_200
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p1_a19 JTF_VARCHAR2_TABLE_200
    , p1_a20 JTF_VARCHAR2_TABLE_200
    , p1_a21 JTF_VARCHAR2_TABLE_200
    , p1_a22 JTF_VARCHAR2_TABLE_200
    , p1_a23 JTF_VARCHAR2_TABLE_200
    , p1_a24 JTF_VARCHAR2_TABLE_200
    , p1_a25 JTF_VARCHAR2_TABLE_200
    , p1_a26 JTF_VARCHAR2_TABLE_200
    , p1_a27 JTF_VARCHAR2_TABLE_200
    , p1_a28 JTF_VARCHAR2_TABLE_200
    , p1_a29 JTF_VARCHAR2_TABLE_200
    , p1_a30 JTF_VARCHAR2_TABLE_200
    , p1_a31 JTF_VARCHAR2_TABLE_200
    , p1_a32 JTF_VARCHAR2_TABLE_200
    , p1_a33 JTF_VARCHAR2_TABLE_200
    , p1_a34 JTF_VARCHAR2_TABLE_200
    , p1_a35 JTF_VARCHAR2_TABLE_200
    , p1_a36 JTF_VARCHAR2_TABLE_200
    , p1_a37 JTF_VARCHAR2_TABLE_200
    , p1_a38 JTF_VARCHAR2_TABLE_200
    , p1_a39 JTF_VARCHAR2_TABLE_200
    , p1_a40 JTF_VARCHAR2_TABLE_200
    , p1_a41 JTF_VARCHAR2_TABLE_200
    , p1_a42 JTF_VARCHAR2_TABLE_200
    , p1_a43 JTF_VARCHAR2_TABLE_200
    , p1_a44 JTF_VARCHAR2_TABLE_200
    , p1_a45 JTF_VARCHAR2_TABLE_200
    , p1_a46 JTF_VARCHAR2_TABLE_200
    , p1_a47 JTF_VARCHAR2_TABLE_200
    , p1_a48 JTF_VARCHAR2_TABLE_200
    , p1_a49 JTF_VARCHAR2_TABLE_200
    , p1_a50 JTF_VARCHAR2_TABLE_200
    , p1_a51 JTF_VARCHAR2_TABLE_200
    , p1_a52 JTF_VARCHAR2_TABLE_200
    , p1_a53 JTF_VARCHAR2_TABLE_200
    , p1_a54 JTF_VARCHAR2_TABLE_200
    , p1_a55 JTF_VARCHAR2_TABLE_200
    , p1_a56 JTF_VARCHAR2_TABLE_200
    , p1_a57 JTF_VARCHAR2_TABLE_200
    , p1_a58 JTF_VARCHAR2_TABLE_200
    , p1_a59 JTF_NUMBER_TABLE
    , p1_a60 JTF_NUMBER_TABLE
    , p1_a61 JTF_NUMBER_TABLE
    , p1_a62 JTF_NUMBER_TABLE
    , p1_a63 JTF_NUMBER_TABLE
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_NUMBER_TABLE
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_NUMBER_TABLE
    , p1_a69 JTF_NUMBER_TABLE
    , p1_a70 JTF_NUMBER_TABLE
    , p1_a71 JTF_NUMBER_TABLE
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_NUMBER_TABLE
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_NUMBER_TABLE
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_NUMBER_TABLE
    , p1_a78 JTF_NUMBER_TABLE
    , p1_a79 JTF_NUMBER_TABLE
    , p1_a80 JTF_NUMBER_TABLE
    , p1_a81 JTF_NUMBER_TABLE
    , p1_a82 JTF_NUMBER_TABLE
    , p1_a83 JTF_NUMBER_TABLE
    , p1_a84 JTF_DATE_TABLE
    , p1_a85 JTF_DATE_TABLE
    , p1_a86 JTF_DATE_TABLE
    , p1_a87 JTF_DATE_TABLE
    , p1_a88 JTF_DATE_TABLE
    , p1_a89 JTF_DATE_TABLE
    , p1_a90 JTF_DATE_TABLE
    , p1_a91 JTF_DATE_TABLE
    , p1_a92 JTF_DATE_TABLE
    , p1_a93 JTF_DATE_TABLE
    , p1_a94 JTF_DATE_TABLE
    , p1_a95 JTF_DATE_TABLE
    , p1_a96 JTF_DATE_TABLE
    , p1_a97 JTF_DATE_TABLE
    , p1_a98 JTF_DATE_TABLE
    , p1_a99 JTF_DATE_TABLE
    , p1_a100 JTF_DATE_TABLE
    , p1_a101 JTF_DATE_TABLE
    , p1_a102 JTF_DATE_TABLE
    , p1_a103 JTF_DATE_TABLE
    , p1_a104 JTF_DATE_TABLE
    , p1_a105 JTF_DATE_TABLE
    , p1_a106 JTF_DATE_TABLE
    , p1_a107 JTF_DATE_TABLE
    , p1_a108 JTF_DATE_TABLE
    , p1_a109 JTF_VARCHAR2_TABLE_100
    , p1_a110 JTF_VARCHAR2_TABLE_100
    , p1_a111 JTF_VARCHAR2_TABLE_100
    , p1_a112 JTF_VARCHAR2_TABLE_100
    , p1_a113 JTF_VARCHAR2_TABLE_100
    , p1_a114 JTF_VARCHAR2_TABLE_100
    , p1_a115 JTF_VARCHAR2_TABLE_100
    , p1_a116 JTF_VARCHAR2_TABLE_100
    , p1_a117 JTF_VARCHAR2_TABLE_100
    , p1_a118 JTF_VARCHAR2_TABLE_100
    , p1_a119 JTF_VARCHAR2_TABLE_100
    , p1_a120 JTF_VARCHAR2_TABLE_100
    , p1_a121 JTF_VARCHAR2_TABLE_100
    , p1_a122 JTF_VARCHAR2_TABLE_100
    , p1_a123 JTF_VARCHAR2_TABLE_100
    , p1_a124 JTF_VARCHAR2_TABLE_100
    , p1_a125 JTF_VARCHAR2_TABLE_100
    , p1_a126 JTF_VARCHAR2_TABLE_100
    , p1_a127 JTF_VARCHAR2_TABLE_100
    , p1_a128 JTF_VARCHAR2_TABLE_100
    , p1_a129 JTF_VARCHAR2_TABLE_100
    , p1_a130 JTF_VARCHAR2_TABLE_100
    , p1_a131 JTF_VARCHAR2_TABLE_100
    , p1_a132 JTF_VARCHAR2_TABLE_100
    , p1_a133 JTF_VARCHAR2_TABLE_100
    , p_object_name  VARCHAR2
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sr_ea_new_audit_rec_table cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_sr_ea_old_audit_rec_table cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_modified_on date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_sr_ea_new_audit_rec_table, p0_a0
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
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      , p0_a55
      , p0_a56
      , p0_a57
      , p0_a58
      , p0_a59
      , p0_a60
      , p0_a61
      , p0_a62
      , p0_a63
      , p0_a64
      , p0_a65
      , p0_a66
      , p0_a67
      , p0_a68
      , p0_a69
      , p0_a70
      , p0_a71
      , p0_a72
      , p0_a73
      , p0_a74
      , p0_a75
      , p0_a76
      , p0_a77
      , p0_a78
      , p0_a79
      , p0_a80
      , p0_a81
      , p0_a82
      , p0_a83
      , p0_a84
      , p0_a85
      , p0_a86
      , p0_a87
      , p0_a88
      , p0_a89
      , p0_a90
      , p0_a91
      , p0_a92
      , p0_a93
      , p0_a94
      , p0_a95
      , p0_a96
      , p0_a97
      , p0_a98
      , p0_a99
      , p0_a100
      , p0_a101
      , p0_a102
      , p0_a103
      , p0_a104
      , p0_a105
      , p0_a106
      , p0_a107
      , p0_a108
      , p0_a109
      , p0_a110
      , p0_a111
      , p0_a112
      , p0_a113
      , p0_a114
      , p0_a115
      , p0_a116
      , p0_a117
      , p0_a118
      , p0_a119
      , p0_a120
      , p0_a121
      , p0_a122
      , p0_a123
      , p0_a124
      , p0_a125
      , p0_a126
      , p0_a127
      , p0_a128
      , p0_a129
      , p0_a130
      , p0_a131
      , p0_a132
      , p0_a133
      );

    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_sr_ea_old_audit_rec_table, p1_a0
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
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      );



    ddp_modified_on := rosetta_g_miss_date_in_map(p_modified_on);




    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.create_ext_attr_audit(ddp_sr_ea_new_audit_rec_table,
      ddp_sr_ea_old_audit_rec_table,
      p_object_name,
      p_modified_by,
      ddp_modified_on,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure merge_ext_attrs_details(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_200
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p0_a3 JTF_VARCHAR2_TABLE_200
    , p0_a4 JTF_VARCHAR2_TABLE_200
    , p0_a5 JTF_VARCHAR2_TABLE_200
    , p0_a6 JTF_VARCHAR2_TABLE_200
    , p0_a7 JTF_VARCHAR2_TABLE_100
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_VARCHAR2_TABLE_100
    , p0_a12 JTF_VARCHAR2_TABLE_200
    , p0_a13 JTF_VARCHAR2_TABLE_100
    , p0_a14 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p1_a3 JTF_VARCHAR2_TABLE_200
    , p1_a4 JTF_VARCHAR2_TABLE_4000
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_DATE_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_4000
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p2_a9 out nocopy JTF_DATE_TABLE
    , p2_a10 out nocopy JTF_VARCHAR2_TABLE_1000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ext_attr_grp_tbl cs_servicerequest_pub.ext_attr_grp_tbl_type;
    ddp_ext_attr_tbl cs_servicerequest_pub.ext_attr_tbl_type;
    ddx_ext_grp_attr_tbl cs_sr_extattributes_pvt.ext_grp_attr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    cs_servicerequest_pub_w.rosetta_table_copy_in_p8(ddp_ext_attr_grp_tbl, p0_a0
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
      );

    cs_servicerequest_pub_w.rosetta_table_copy_in_p10(ddp_ext_attr_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      );





    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.merge_ext_attrs_details(ddp_ext_attr_grp_tbl,
      ddp_ext_attr_tbl,
      ddx_ext_grp_attr_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    cs_sr_extattributes_pvt_w.rosetta_table_copy_out_p6(ddx_ext_grp_attr_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      );



  end;

  procedure insert_sr_row(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p0_a3 JTF_VARCHAR2_TABLE_200
    , p0_a4 JTF_VARCHAR2_TABLE_200
    , p0_a5 JTF_VARCHAR2_TABLE_200
    , p0_a6 JTF_VARCHAR2_TABLE_200
    , p0_a7 JTF_VARCHAR2_TABLE_200
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_VARCHAR2_TABLE_200
    , p0_a10 JTF_VARCHAR2_TABLE_200
    , p0_a11 JTF_VARCHAR2_TABLE_200
    , p0_a12 JTF_VARCHAR2_TABLE_200
    , p0_a13 JTF_VARCHAR2_TABLE_200
    , p0_a14 JTF_VARCHAR2_TABLE_200
    , p0_a15 JTF_VARCHAR2_TABLE_200
    , p0_a16 JTF_VARCHAR2_TABLE_200
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_VARCHAR2_TABLE_200
    , p0_a38 JTF_VARCHAR2_TABLE_200
    , p0_a39 JTF_VARCHAR2_TABLE_200
    , p0_a40 JTF_VARCHAR2_TABLE_200
    , p0_a41 JTF_VARCHAR2_TABLE_200
    , p0_a42 JTF_VARCHAR2_TABLE_200
    , p0_a43 JTF_VARCHAR2_TABLE_200
    , p0_a44 JTF_VARCHAR2_TABLE_200
    , p0_a45 JTF_VARCHAR2_TABLE_200
    , p0_a46 JTF_VARCHAR2_TABLE_200
    , p0_a47 JTF_VARCHAR2_TABLE_200
    , p0_a48 JTF_VARCHAR2_TABLE_200
    , p0_a49 JTF_VARCHAR2_TABLE_200
    , p0_a50 JTF_VARCHAR2_TABLE_200
    , p0_a51 JTF_VARCHAR2_TABLE_200
    , p0_a52 JTF_VARCHAR2_TABLE_200
    , p0_a53 JTF_VARCHAR2_TABLE_200
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p0_a55 JTF_VARCHAR2_TABLE_200
    , p0_a56 JTF_VARCHAR2_TABLE_200
    , p0_a57 JTF_VARCHAR2_TABLE_200
    , p0_a58 JTF_VARCHAR2_TABLE_200
    , p0_a59 JTF_NUMBER_TABLE
    , p0_a60 JTF_NUMBER_TABLE
    , p0_a61 JTF_NUMBER_TABLE
    , p0_a62 JTF_NUMBER_TABLE
    , p0_a63 JTF_NUMBER_TABLE
    , p0_a64 JTF_NUMBER_TABLE
    , p0_a65 JTF_NUMBER_TABLE
    , p0_a66 JTF_NUMBER_TABLE
    , p0_a67 JTF_NUMBER_TABLE
    , p0_a68 JTF_NUMBER_TABLE
    , p0_a69 JTF_NUMBER_TABLE
    , p0_a70 JTF_NUMBER_TABLE
    , p0_a71 JTF_NUMBER_TABLE
    , p0_a72 JTF_NUMBER_TABLE
    , p0_a73 JTF_NUMBER_TABLE
    , p0_a74 JTF_NUMBER_TABLE
    , p0_a75 JTF_NUMBER_TABLE
    , p0_a76 JTF_NUMBER_TABLE
    , p0_a77 JTF_NUMBER_TABLE
    , p0_a78 JTF_NUMBER_TABLE
    , p0_a79 JTF_NUMBER_TABLE
    , p0_a80 JTF_NUMBER_TABLE
    , p0_a81 JTF_NUMBER_TABLE
    , p0_a82 JTF_NUMBER_TABLE
    , p0_a83 JTF_NUMBER_TABLE
    , p0_a84 JTF_DATE_TABLE
    , p0_a85 JTF_DATE_TABLE
    , p0_a86 JTF_DATE_TABLE
    , p0_a87 JTF_DATE_TABLE
    , p0_a88 JTF_DATE_TABLE
    , p0_a89 JTF_DATE_TABLE
    , p0_a90 JTF_DATE_TABLE
    , p0_a91 JTF_DATE_TABLE
    , p0_a92 JTF_DATE_TABLE
    , p0_a93 JTF_DATE_TABLE
    , p0_a94 JTF_DATE_TABLE
    , p0_a95 JTF_DATE_TABLE
    , p0_a96 JTF_DATE_TABLE
    , p0_a97 JTF_DATE_TABLE
    , p0_a98 JTF_DATE_TABLE
    , p0_a99 JTF_DATE_TABLE
    , p0_a100 JTF_DATE_TABLE
    , p0_a101 JTF_DATE_TABLE
    , p0_a102 JTF_DATE_TABLE
    , p0_a103 JTF_DATE_TABLE
    , p0_a104 JTF_DATE_TABLE
    , p0_a105 JTF_DATE_TABLE
    , p0_a106 JTF_DATE_TABLE
    , p0_a107 JTF_DATE_TABLE
    , p0_a108 JTF_DATE_TABLE
    , p0_a109 JTF_VARCHAR2_TABLE_100
    , p0_a110 JTF_VARCHAR2_TABLE_100
    , p0_a111 JTF_VARCHAR2_TABLE_100
    , p0_a112 JTF_VARCHAR2_TABLE_100
    , p0_a113 JTF_VARCHAR2_TABLE_100
    , p0_a114 JTF_VARCHAR2_TABLE_100
    , p0_a115 JTF_VARCHAR2_TABLE_100
    , p0_a116 JTF_VARCHAR2_TABLE_100
    , p0_a117 JTF_VARCHAR2_TABLE_100
    , p0_a118 JTF_VARCHAR2_TABLE_100
    , p0_a119 JTF_VARCHAR2_TABLE_100
    , p0_a120 JTF_VARCHAR2_TABLE_100
    , p0_a121 JTF_VARCHAR2_TABLE_100
    , p0_a122 JTF_VARCHAR2_TABLE_100
    , p0_a123 JTF_VARCHAR2_TABLE_100
    , p0_a124 JTF_VARCHAR2_TABLE_100
    , p0_a125 JTF_VARCHAR2_TABLE_100
    , p0_a126 JTF_VARCHAR2_TABLE_100
    , p0_a127 JTF_VARCHAR2_TABLE_100
    , p0_a128 JTF_VARCHAR2_TABLE_100
    , p0_a129 JTF_VARCHAR2_TABLE_100
    , p0_a130 JTF_VARCHAR2_TABLE_100
    , p0_a131 JTF_VARCHAR2_TABLE_100
    , p0_a132 JTF_VARCHAR2_TABLE_100
    , p0_a133 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p1_a3 JTF_VARCHAR2_TABLE_200
    , p1_a4 JTF_VARCHAR2_TABLE_200
    , p1_a5 JTF_VARCHAR2_TABLE_200
    , p1_a6 JTF_VARCHAR2_TABLE_200
    , p1_a7 JTF_VARCHAR2_TABLE_200
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_VARCHAR2_TABLE_200
    , p1_a10 JTF_VARCHAR2_TABLE_200
    , p1_a11 JTF_VARCHAR2_TABLE_200
    , p1_a12 JTF_VARCHAR2_TABLE_200
    , p1_a13 JTF_VARCHAR2_TABLE_200
    , p1_a14 JTF_VARCHAR2_TABLE_200
    , p1_a15 JTF_VARCHAR2_TABLE_200
    , p1_a16 JTF_VARCHAR2_TABLE_200
    , p1_a17 JTF_VARCHAR2_TABLE_200
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p1_a19 JTF_VARCHAR2_TABLE_200
    , p1_a20 JTF_VARCHAR2_TABLE_200
    , p1_a21 JTF_VARCHAR2_TABLE_200
    , p1_a22 JTF_VARCHAR2_TABLE_200
    , p1_a23 JTF_VARCHAR2_TABLE_200
    , p1_a24 JTF_VARCHAR2_TABLE_200
    , p1_a25 JTF_VARCHAR2_TABLE_200
    , p1_a26 JTF_VARCHAR2_TABLE_200
    , p1_a27 JTF_VARCHAR2_TABLE_200
    , p1_a28 JTF_VARCHAR2_TABLE_200
    , p1_a29 JTF_VARCHAR2_TABLE_200
    , p1_a30 JTF_VARCHAR2_TABLE_200
    , p1_a31 JTF_VARCHAR2_TABLE_200
    , p1_a32 JTF_VARCHAR2_TABLE_200
    , p1_a33 JTF_VARCHAR2_TABLE_200
    , p1_a34 JTF_VARCHAR2_TABLE_200
    , p1_a35 JTF_VARCHAR2_TABLE_200
    , p1_a36 JTF_VARCHAR2_TABLE_200
    , p1_a37 JTF_VARCHAR2_TABLE_200
    , p1_a38 JTF_VARCHAR2_TABLE_200
    , p1_a39 JTF_VARCHAR2_TABLE_200
    , p1_a40 JTF_VARCHAR2_TABLE_200
    , p1_a41 JTF_VARCHAR2_TABLE_200
    , p1_a42 JTF_VARCHAR2_TABLE_200
    , p1_a43 JTF_VARCHAR2_TABLE_200
    , p1_a44 JTF_VARCHAR2_TABLE_200
    , p1_a45 JTF_VARCHAR2_TABLE_200
    , p1_a46 JTF_VARCHAR2_TABLE_200
    , p1_a47 JTF_VARCHAR2_TABLE_200
    , p1_a48 JTF_VARCHAR2_TABLE_200
    , p1_a49 JTF_VARCHAR2_TABLE_200
    , p1_a50 JTF_VARCHAR2_TABLE_200
    , p1_a51 JTF_VARCHAR2_TABLE_200
    , p1_a52 JTF_VARCHAR2_TABLE_200
    , p1_a53 JTF_VARCHAR2_TABLE_200
    , p1_a54 JTF_VARCHAR2_TABLE_200
    , p1_a55 JTF_VARCHAR2_TABLE_200
    , p1_a56 JTF_VARCHAR2_TABLE_200
    , p1_a57 JTF_VARCHAR2_TABLE_200
    , p1_a58 JTF_VARCHAR2_TABLE_200
    , p1_a59 JTF_NUMBER_TABLE
    , p1_a60 JTF_NUMBER_TABLE
    , p1_a61 JTF_NUMBER_TABLE
    , p1_a62 JTF_NUMBER_TABLE
    , p1_a63 JTF_NUMBER_TABLE
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_NUMBER_TABLE
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_NUMBER_TABLE
    , p1_a69 JTF_NUMBER_TABLE
    , p1_a70 JTF_NUMBER_TABLE
    , p1_a71 JTF_NUMBER_TABLE
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_NUMBER_TABLE
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_NUMBER_TABLE
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_NUMBER_TABLE
    , p1_a78 JTF_NUMBER_TABLE
    , p1_a79 JTF_NUMBER_TABLE
    , p1_a80 JTF_NUMBER_TABLE
    , p1_a81 JTF_NUMBER_TABLE
    , p1_a82 JTF_NUMBER_TABLE
    , p1_a83 JTF_NUMBER_TABLE
    , p1_a84 JTF_DATE_TABLE
    , p1_a85 JTF_DATE_TABLE
    , p1_a86 JTF_DATE_TABLE
    , p1_a87 JTF_DATE_TABLE
    , p1_a88 JTF_DATE_TABLE
    , p1_a89 JTF_DATE_TABLE
    , p1_a90 JTF_DATE_TABLE
    , p1_a91 JTF_DATE_TABLE
    , p1_a92 JTF_DATE_TABLE
    , p1_a93 JTF_DATE_TABLE
    , p1_a94 JTF_DATE_TABLE
    , p1_a95 JTF_DATE_TABLE
    , p1_a96 JTF_DATE_TABLE
    , p1_a97 JTF_DATE_TABLE
    , p1_a98 JTF_DATE_TABLE
    , p1_a99 JTF_DATE_TABLE
    , p1_a100 JTF_DATE_TABLE
    , p1_a101 JTF_DATE_TABLE
    , p1_a102 JTF_DATE_TABLE
    , p1_a103 JTF_DATE_TABLE
    , p1_a104 JTF_DATE_TABLE
    , p1_a105 JTF_DATE_TABLE
    , p1_a106 JTF_DATE_TABLE
    , p1_a107 JTF_DATE_TABLE
    , p1_a108 JTF_DATE_TABLE
    , p1_a109 JTF_VARCHAR2_TABLE_100
    , p1_a110 JTF_VARCHAR2_TABLE_100
    , p1_a111 JTF_VARCHAR2_TABLE_100
    , p1_a112 JTF_VARCHAR2_TABLE_100
    , p1_a113 JTF_VARCHAR2_TABLE_100
    , p1_a114 JTF_VARCHAR2_TABLE_100
    , p1_a115 JTF_VARCHAR2_TABLE_100
    , p1_a116 JTF_VARCHAR2_TABLE_100
    , p1_a117 JTF_VARCHAR2_TABLE_100
    , p1_a118 JTF_VARCHAR2_TABLE_100
    , p1_a119 JTF_VARCHAR2_TABLE_100
    , p1_a120 JTF_VARCHAR2_TABLE_100
    , p1_a121 JTF_VARCHAR2_TABLE_100
    , p1_a122 JTF_VARCHAR2_TABLE_100
    , p1_a123 JTF_VARCHAR2_TABLE_100
    , p1_a124 JTF_VARCHAR2_TABLE_100
    , p1_a125 JTF_VARCHAR2_TABLE_100
    , p1_a126 JTF_VARCHAR2_TABLE_100
    , p1_a127 JTF_VARCHAR2_TABLE_100
    , p1_a128 JTF_VARCHAR2_TABLE_100
    , p1_a129 JTF_VARCHAR2_TABLE_100
    , p1_a130 JTF_VARCHAR2_TABLE_100
    , p1_a131 JTF_VARCHAR2_TABLE_100
    , p1_a132 JTF_VARCHAR2_TABLE_100
    , p1_a133 JTF_VARCHAR2_TABLE_100
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_new_ext_attrs cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_old_ext_attrs cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_modified_on date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_new_ext_attrs, p0_a0
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
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      , p0_a55
      , p0_a56
      , p0_a57
      , p0_a58
      , p0_a59
      , p0_a60
      , p0_a61
      , p0_a62
      , p0_a63
      , p0_a64
      , p0_a65
      , p0_a66
      , p0_a67
      , p0_a68
      , p0_a69
      , p0_a70
      , p0_a71
      , p0_a72
      , p0_a73
      , p0_a74
      , p0_a75
      , p0_a76
      , p0_a77
      , p0_a78
      , p0_a79
      , p0_a80
      , p0_a81
      , p0_a82
      , p0_a83
      , p0_a84
      , p0_a85
      , p0_a86
      , p0_a87
      , p0_a88
      , p0_a89
      , p0_a90
      , p0_a91
      , p0_a92
      , p0_a93
      , p0_a94
      , p0_a95
      , p0_a96
      , p0_a97
      , p0_a98
      , p0_a99
      , p0_a100
      , p0_a101
      , p0_a102
      , p0_a103
      , p0_a104
      , p0_a105
      , p0_a106
      , p0_a107
      , p0_a108
      , p0_a109
      , p0_a110
      , p0_a111
      , p0_a112
      , p0_a113
      , p0_a114
      , p0_a115
      , p0_a116
      , p0_a117
      , p0_a118
      , p0_a119
      , p0_a120
      , p0_a121
      , p0_a122
      , p0_a123
      , p0_a124
      , p0_a125
      , p0_a126
      , p0_a127
      , p0_a128
      , p0_a129
      , p0_a130
      , p0_a131
      , p0_a132
      , p0_a133
      );

    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_old_ext_attrs, p1_a0
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
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      );


    ddp_modified_on := rosetta_g_miss_date_in_map(p_modified_on);




    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.insert_sr_row(ddp_new_ext_attrs,
      ddp_old_ext_attrs,
      p_modified_by,
      ddp_modified_on,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure insert_pr_row(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p0_a3 JTF_VARCHAR2_TABLE_200
    , p0_a4 JTF_VARCHAR2_TABLE_200
    , p0_a5 JTF_VARCHAR2_TABLE_200
    , p0_a6 JTF_VARCHAR2_TABLE_200
    , p0_a7 JTF_VARCHAR2_TABLE_200
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_VARCHAR2_TABLE_200
    , p0_a10 JTF_VARCHAR2_TABLE_200
    , p0_a11 JTF_VARCHAR2_TABLE_200
    , p0_a12 JTF_VARCHAR2_TABLE_200
    , p0_a13 JTF_VARCHAR2_TABLE_200
    , p0_a14 JTF_VARCHAR2_TABLE_200
    , p0_a15 JTF_VARCHAR2_TABLE_200
    , p0_a16 JTF_VARCHAR2_TABLE_200
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_VARCHAR2_TABLE_200
    , p0_a38 JTF_VARCHAR2_TABLE_200
    , p0_a39 JTF_VARCHAR2_TABLE_200
    , p0_a40 JTF_VARCHAR2_TABLE_200
    , p0_a41 JTF_VARCHAR2_TABLE_200
    , p0_a42 JTF_VARCHAR2_TABLE_200
    , p0_a43 JTF_VARCHAR2_TABLE_200
    , p0_a44 JTF_VARCHAR2_TABLE_200
    , p0_a45 JTF_VARCHAR2_TABLE_200
    , p0_a46 JTF_VARCHAR2_TABLE_200
    , p0_a47 JTF_VARCHAR2_TABLE_200
    , p0_a48 JTF_VARCHAR2_TABLE_200
    , p0_a49 JTF_VARCHAR2_TABLE_200
    , p0_a50 JTF_VARCHAR2_TABLE_200
    , p0_a51 JTF_VARCHAR2_TABLE_200
    , p0_a52 JTF_VARCHAR2_TABLE_200
    , p0_a53 JTF_VARCHAR2_TABLE_200
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p0_a55 JTF_VARCHAR2_TABLE_200
    , p0_a56 JTF_VARCHAR2_TABLE_200
    , p0_a57 JTF_VARCHAR2_TABLE_200
    , p0_a58 JTF_VARCHAR2_TABLE_200
    , p0_a59 JTF_NUMBER_TABLE
    , p0_a60 JTF_NUMBER_TABLE
    , p0_a61 JTF_NUMBER_TABLE
    , p0_a62 JTF_NUMBER_TABLE
    , p0_a63 JTF_NUMBER_TABLE
    , p0_a64 JTF_NUMBER_TABLE
    , p0_a65 JTF_NUMBER_TABLE
    , p0_a66 JTF_NUMBER_TABLE
    , p0_a67 JTF_NUMBER_TABLE
    , p0_a68 JTF_NUMBER_TABLE
    , p0_a69 JTF_NUMBER_TABLE
    , p0_a70 JTF_NUMBER_TABLE
    , p0_a71 JTF_NUMBER_TABLE
    , p0_a72 JTF_NUMBER_TABLE
    , p0_a73 JTF_NUMBER_TABLE
    , p0_a74 JTF_NUMBER_TABLE
    , p0_a75 JTF_NUMBER_TABLE
    , p0_a76 JTF_NUMBER_TABLE
    , p0_a77 JTF_NUMBER_TABLE
    , p0_a78 JTF_NUMBER_TABLE
    , p0_a79 JTF_NUMBER_TABLE
    , p0_a80 JTF_NUMBER_TABLE
    , p0_a81 JTF_NUMBER_TABLE
    , p0_a82 JTF_NUMBER_TABLE
    , p0_a83 JTF_NUMBER_TABLE
    , p0_a84 JTF_DATE_TABLE
    , p0_a85 JTF_DATE_TABLE
    , p0_a86 JTF_DATE_TABLE
    , p0_a87 JTF_DATE_TABLE
    , p0_a88 JTF_DATE_TABLE
    , p0_a89 JTF_DATE_TABLE
    , p0_a90 JTF_DATE_TABLE
    , p0_a91 JTF_DATE_TABLE
    , p0_a92 JTF_DATE_TABLE
    , p0_a93 JTF_DATE_TABLE
    , p0_a94 JTF_DATE_TABLE
    , p0_a95 JTF_DATE_TABLE
    , p0_a96 JTF_DATE_TABLE
    , p0_a97 JTF_DATE_TABLE
    , p0_a98 JTF_DATE_TABLE
    , p0_a99 JTF_DATE_TABLE
    , p0_a100 JTF_DATE_TABLE
    , p0_a101 JTF_DATE_TABLE
    , p0_a102 JTF_DATE_TABLE
    , p0_a103 JTF_DATE_TABLE
    , p0_a104 JTF_DATE_TABLE
    , p0_a105 JTF_DATE_TABLE
    , p0_a106 JTF_DATE_TABLE
    , p0_a107 JTF_DATE_TABLE
    , p0_a108 JTF_DATE_TABLE
    , p0_a109 JTF_VARCHAR2_TABLE_100
    , p0_a110 JTF_VARCHAR2_TABLE_100
    , p0_a111 JTF_VARCHAR2_TABLE_100
    , p0_a112 JTF_VARCHAR2_TABLE_100
    , p0_a113 JTF_VARCHAR2_TABLE_100
    , p0_a114 JTF_VARCHAR2_TABLE_100
    , p0_a115 JTF_VARCHAR2_TABLE_100
    , p0_a116 JTF_VARCHAR2_TABLE_100
    , p0_a117 JTF_VARCHAR2_TABLE_100
    , p0_a118 JTF_VARCHAR2_TABLE_100
    , p0_a119 JTF_VARCHAR2_TABLE_100
    , p0_a120 JTF_VARCHAR2_TABLE_100
    , p0_a121 JTF_VARCHAR2_TABLE_100
    , p0_a122 JTF_VARCHAR2_TABLE_100
    , p0_a123 JTF_VARCHAR2_TABLE_100
    , p0_a124 JTF_VARCHAR2_TABLE_100
    , p0_a125 JTF_VARCHAR2_TABLE_100
    , p0_a126 JTF_VARCHAR2_TABLE_100
    , p0_a127 JTF_VARCHAR2_TABLE_100
    , p0_a128 JTF_VARCHAR2_TABLE_100
    , p0_a129 JTF_VARCHAR2_TABLE_100
    , p0_a130 JTF_VARCHAR2_TABLE_100
    , p0_a131 JTF_VARCHAR2_TABLE_100
    , p0_a132 JTF_VARCHAR2_TABLE_100
    , p0_a133 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p1_a3 JTF_VARCHAR2_TABLE_200
    , p1_a4 JTF_VARCHAR2_TABLE_200
    , p1_a5 JTF_VARCHAR2_TABLE_200
    , p1_a6 JTF_VARCHAR2_TABLE_200
    , p1_a7 JTF_VARCHAR2_TABLE_200
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_VARCHAR2_TABLE_200
    , p1_a10 JTF_VARCHAR2_TABLE_200
    , p1_a11 JTF_VARCHAR2_TABLE_200
    , p1_a12 JTF_VARCHAR2_TABLE_200
    , p1_a13 JTF_VARCHAR2_TABLE_200
    , p1_a14 JTF_VARCHAR2_TABLE_200
    , p1_a15 JTF_VARCHAR2_TABLE_200
    , p1_a16 JTF_VARCHAR2_TABLE_200
    , p1_a17 JTF_VARCHAR2_TABLE_200
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p1_a19 JTF_VARCHAR2_TABLE_200
    , p1_a20 JTF_VARCHAR2_TABLE_200
    , p1_a21 JTF_VARCHAR2_TABLE_200
    , p1_a22 JTF_VARCHAR2_TABLE_200
    , p1_a23 JTF_VARCHAR2_TABLE_200
    , p1_a24 JTF_VARCHAR2_TABLE_200
    , p1_a25 JTF_VARCHAR2_TABLE_200
    , p1_a26 JTF_VARCHAR2_TABLE_200
    , p1_a27 JTF_VARCHAR2_TABLE_200
    , p1_a28 JTF_VARCHAR2_TABLE_200
    , p1_a29 JTF_VARCHAR2_TABLE_200
    , p1_a30 JTF_VARCHAR2_TABLE_200
    , p1_a31 JTF_VARCHAR2_TABLE_200
    , p1_a32 JTF_VARCHAR2_TABLE_200
    , p1_a33 JTF_VARCHAR2_TABLE_200
    , p1_a34 JTF_VARCHAR2_TABLE_200
    , p1_a35 JTF_VARCHAR2_TABLE_200
    , p1_a36 JTF_VARCHAR2_TABLE_200
    , p1_a37 JTF_VARCHAR2_TABLE_200
    , p1_a38 JTF_VARCHAR2_TABLE_200
    , p1_a39 JTF_VARCHAR2_TABLE_200
    , p1_a40 JTF_VARCHAR2_TABLE_200
    , p1_a41 JTF_VARCHAR2_TABLE_200
    , p1_a42 JTF_VARCHAR2_TABLE_200
    , p1_a43 JTF_VARCHAR2_TABLE_200
    , p1_a44 JTF_VARCHAR2_TABLE_200
    , p1_a45 JTF_VARCHAR2_TABLE_200
    , p1_a46 JTF_VARCHAR2_TABLE_200
    , p1_a47 JTF_VARCHAR2_TABLE_200
    , p1_a48 JTF_VARCHAR2_TABLE_200
    , p1_a49 JTF_VARCHAR2_TABLE_200
    , p1_a50 JTF_VARCHAR2_TABLE_200
    , p1_a51 JTF_VARCHAR2_TABLE_200
    , p1_a52 JTF_VARCHAR2_TABLE_200
    , p1_a53 JTF_VARCHAR2_TABLE_200
    , p1_a54 JTF_VARCHAR2_TABLE_200
    , p1_a55 JTF_VARCHAR2_TABLE_200
    , p1_a56 JTF_VARCHAR2_TABLE_200
    , p1_a57 JTF_VARCHAR2_TABLE_200
    , p1_a58 JTF_VARCHAR2_TABLE_200
    , p1_a59 JTF_NUMBER_TABLE
    , p1_a60 JTF_NUMBER_TABLE
    , p1_a61 JTF_NUMBER_TABLE
    , p1_a62 JTF_NUMBER_TABLE
    , p1_a63 JTF_NUMBER_TABLE
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_NUMBER_TABLE
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_NUMBER_TABLE
    , p1_a69 JTF_NUMBER_TABLE
    , p1_a70 JTF_NUMBER_TABLE
    , p1_a71 JTF_NUMBER_TABLE
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_NUMBER_TABLE
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_NUMBER_TABLE
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_NUMBER_TABLE
    , p1_a78 JTF_NUMBER_TABLE
    , p1_a79 JTF_NUMBER_TABLE
    , p1_a80 JTF_NUMBER_TABLE
    , p1_a81 JTF_NUMBER_TABLE
    , p1_a82 JTF_NUMBER_TABLE
    , p1_a83 JTF_NUMBER_TABLE
    , p1_a84 JTF_DATE_TABLE
    , p1_a85 JTF_DATE_TABLE
    , p1_a86 JTF_DATE_TABLE
    , p1_a87 JTF_DATE_TABLE
    , p1_a88 JTF_DATE_TABLE
    , p1_a89 JTF_DATE_TABLE
    , p1_a90 JTF_DATE_TABLE
    , p1_a91 JTF_DATE_TABLE
    , p1_a92 JTF_DATE_TABLE
    , p1_a93 JTF_DATE_TABLE
    , p1_a94 JTF_DATE_TABLE
    , p1_a95 JTF_DATE_TABLE
    , p1_a96 JTF_DATE_TABLE
    , p1_a97 JTF_DATE_TABLE
    , p1_a98 JTF_DATE_TABLE
    , p1_a99 JTF_DATE_TABLE
    , p1_a100 JTF_DATE_TABLE
    , p1_a101 JTF_DATE_TABLE
    , p1_a102 JTF_DATE_TABLE
    , p1_a103 JTF_DATE_TABLE
    , p1_a104 JTF_DATE_TABLE
    , p1_a105 JTF_DATE_TABLE
    , p1_a106 JTF_DATE_TABLE
    , p1_a107 JTF_DATE_TABLE
    , p1_a108 JTF_DATE_TABLE
    , p1_a109 JTF_VARCHAR2_TABLE_100
    , p1_a110 JTF_VARCHAR2_TABLE_100
    , p1_a111 JTF_VARCHAR2_TABLE_100
    , p1_a112 JTF_VARCHAR2_TABLE_100
    , p1_a113 JTF_VARCHAR2_TABLE_100
    , p1_a114 JTF_VARCHAR2_TABLE_100
    , p1_a115 JTF_VARCHAR2_TABLE_100
    , p1_a116 JTF_VARCHAR2_TABLE_100
    , p1_a117 JTF_VARCHAR2_TABLE_100
    , p1_a118 JTF_VARCHAR2_TABLE_100
    , p1_a119 JTF_VARCHAR2_TABLE_100
    , p1_a120 JTF_VARCHAR2_TABLE_100
    , p1_a121 JTF_VARCHAR2_TABLE_100
    , p1_a122 JTF_VARCHAR2_TABLE_100
    , p1_a123 JTF_VARCHAR2_TABLE_100
    , p1_a124 JTF_VARCHAR2_TABLE_100
    , p1_a125 JTF_VARCHAR2_TABLE_100
    , p1_a126 JTF_VARCHAR2_TABLE_100
    , p1_a127 JTF_VARCHAR2_TABLE_100
    , p1_a128 JTF_VARCHAR2_TABLE_100
    , p1_a129 JTF_VARCHAR2_TABLE_100
    , p1_a130 JTF_VARCHAR2_TABLE_100
    , p1_a131 JTF_VARCHAR2_TABLE_100
    , p1_a132 JTF_VARCHAR2_TABLE_100
    , p1_a133 JTF_VARCHAR2_TABLE_100
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_new_ext_attrs cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_old_ext_attrs cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddp_modified_on date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_new_ext_attrs, p0_a0
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
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      , p0_a55
      , p0_a56
      , p0_a57
      , p0_a58
      , p0_a59
      , p0_a60
      , p0_a61
      , p0_a62
      , p0_a63
      , p0_a64
      , p0_a65
      , p0_a66
      , p0_a67
      , p0_a68
      , p0_a69
      , p0_a70
      , p0_a71
      , p0_a72
      , p0_a73
      , p0_a74
      , p0_a75
      , p0_a76
      , p0_a77
      , p0_a78
      , p0_a79
      , p0_a80
      , p0_a81
      , p0_a82
      , p0_a83
      , p0_a84
      , p0_a85
      , p0_a86
      , p0_a87
      , p0_a88
      , p0_a89
      , p0_a90
      , p0_a91
      , p0_a92
      , p0_a93
      , p0_a94
      , p0_a95
      , p0_a96
      , p0_a97
      , p0_a98
      , p0_a99
      , p0_a100
      , p0_a101
      , p0_a102
      , p0_a103
      , p0_a104
      , p0_a105
      , p0_a106
      , p0_a107
      , p0_a108
      , p0_a109
      , p0_a110
      , p0_a111
      , p0_a112
      , p0_a113
      , p0_a114
      , p0_a115
      , p0_a116
      , p0_a117
      , p0_a118
      , p0_a119
      , p0_a120
      , p0_a121
      , p0_a122
      , p0_a123
      , p0_a124
      , p0_a125
      , p0_a126
      , p0_a127
      , p0_a128
      , p0_a129
      , p0_a130
      , p0_a131
      , p0_a132
      , p0_a133
      );

    cs_sr_extattributes_pvt_w.rosetta_table_copy_in_p4(ddp_old_ext_attrs, p1_a0
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
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      );


    ddp_modified_on := rosetta_g_miss_date_in_map(p_modified_on);




    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.insert_pr_row(ddp_new_ext_attrs,
      ddp_old_ext_attrs,
      p_modified_by,
      ddp_modified_on,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure populate_ext_attr_audit_tbl(p_extension_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a8 out nocopy JTF_NUMBER_TABLE
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a59 out nocopy JTF_NUMBER_TABLE
    , p1_a60 out nocopy JTF_NUMBER_TABLE
    , p1_a61 out nocopy JTF_NUMBER_TABLE
    , p1_a62 out nocopy JTF_NUMBER_TABLE
    , p1_a63 out nocopy JTF_NUMBER_TABLE
    , p1_a64 out nocopy JTF_NUMBER_TABLE
    , p1_a65 out nocopy JTF_NUMBER_TABLE
    , p1_a66 out nocopy JTF_NUMBER_TABLE
    , p1_a67 out nocopy JTF_NUMBER_TABLE
    , p1_a68 out nocopy JTF_NUMBER_TABLE
    , p1_a69 out nocopy JTF_NUMBER_TABLE
    , p1_a70 out nocopy JTF_NUMBER_TABLE
    , p1_a71 out nocopy JTF_NUMBER_TABLE
    , p1_a72 out nocopy JTF_NUMBER_TABLE
    , p1_a73 out nocopy JTF_NUMBER_TABLE
    , p1_a74 out nocopy JTF_NUMBER_TABLE
    , p1_a75 out nocopy JTF_NUMBER_TABLE
    , p1_a76 out nocopy JTF_NUMBER_TABLE
    , p1_a77 out nocopy JTF_NUMBER_TABLE
    , p1_a78 out nocopy JTF_NUMBER_TABLE
    , p1_a79 out nocopy JTF_NUMBER_TABLE
    , p1_a80 out nocopy JTF_NUMBER_TABLE
    , p1_a81 out nocopy JTF_NUMBER_TABLE
    , p1_a82 out nocopy JTF_NUMBER_TABLE
    , p1_a83 out nocopy JTF_NUMBER_TABLE
    , p1_a84 out nocopy JTF_DATE_TABLE
    , p1_a85 out nocopy JTF_DATE_TABLE
    , p1_a86 out nocopy JTF_DATE_TABLE
    , p1_a87 out nocopy JTF_DATE_TABLE
    , p1_a88 out nocopy JTF_DATE_TABLE
    , p1_a89 out nocopy JTF_DATE_TABLE
    , p1_a90 out nocopy JTF_DATE_TABLE
    , p1_a91 out nocopy JTF_DATE_TABLE
    , p1_a92 out nocopy JTF_DATE_TABLE
    , p1_a93 out nocopy JTF_DATE_TABLE
    , p1_a94 out nocopy JTF_DATE_TABLE
    , p1_a95 out nocopy JTF_DATE_TABLE
    , p1_a96 out nocopy JTF_DATE_TABLE
    , p1_a97 out nocopy JTF_DATE_TABLE
    , p1_a98 out nocopy JTF_DATE_TABLE
    , p1_a99 out nocopy JTF_DATE_TABLE
    , p1_a100 out nocopy JTF_DATE_TABLE
    , p1_a101 out nocopy JTF_DATE_TABLE
    , p1_a102 out nocopy JTF_DATE_TABLE
    , p1_a103 out nocopy JTF_DATE_TABLE
    , p1_a104 out nocopy JTF_DATE_TABLE
    , p1_a105 out nocopy JTF_DATE_TABLE
    , p1_a106 out nocopy JTF_DATE_TABLE
    , p1_a107 out nocopy JTF_DATE_TABLE
    , p1_a108 out nocopy JTF_DATE_TABLE
    , p1_a109 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a110 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a111 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a113 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a115 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a118 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a120 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a121 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a123 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a124 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a125 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a126 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a127 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a128 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a129 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a131 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_ext_attrs_tbl cs_sr_extattributes_pvt.ext_attr_audit_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cs_sr_extattributes_pvt.populate_ext_attr_audit_tbl(p_extension_id,
      ddx_ext_attrs_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cs_sr_extattributes_pvt_w.rosetta_table_copy_out_p4(ddx_ext_attrs_tbl, p1_a0
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
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      );



  end;

end cs_sr_extattributes_pvt_w;

/
