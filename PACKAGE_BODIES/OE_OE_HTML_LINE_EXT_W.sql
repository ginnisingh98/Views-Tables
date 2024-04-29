--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_LINE_EXT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_LINE_EXT_W" as
  /* $Header: ONTRLIEB.pls 120.0 2005/06/01 01:27:07 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_oe_html_line_ext.line_dff_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute16 := a7(indx);
          t(ddindx).attribute17 := a8(indx);
          t(ddindx).attribute18 := a9(indx);
          t(ddindx).attribute19 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute20 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).global_attribute1 := a20(indx);
          t(ddindx).global_attribute10 := a21(indx);
          t(ddindx).global_attribute11 := a22(indx);
          t(ddindx).global_attribute12 := a23(indx);
          t(ddindx).global_attribute13 := a24(indx);
          t(ddindx).global_attribute14 := a25(indx);
          t(ddindx).global_attribute15 := a26(indx);
          t(ddindx).global_attribute16 := a27(indx);
          t(ddindx).global_attribute17 := a28(indx);
          t(ddindx).global_attribute18 := a29(indx);
          t(ddindx).global_attribute19 := a30(indx);
          t(ddindx).global_attribute2 := a31(indx);
          t(ddindx).global_attribute20 := a32(indx);
          t(ddindx).global_attribute3 := a33(indx);
          t(ddindx).global_attribute4 := a34(indx);
          t(ddindx).global_attribute5 := a35(indx);
          t(ddindx).global_attribute6 := a36(indx);
          t(ddindx).global_attribute7 := a37(indx);
          t(ddindx).global_attribute8 := a38(indx);
          t(ddindx).global_attribute9 := a39(indx);
          t(ddindx).global_attribute_category := a40(indx);
          t(ddindx).line_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).industry_attribute1 := a42(indx);
          t(ddindx).industry_attribute10 := a43(indx);
          t(ddindx).industry_attribute11 := a44(indx);
          t(ddindx).industry_attribute12 := a45(indx);
          t(ddindx).industry_attribute13 := a46(indx);
          t(ddindx).industry_attribute14 := a47(indx);
          t(ddindx).industry_attribute15 := a48(indx);
          t(ddindx).industry_attribute16 := a49(indx);
          t(ddindx).industry_attribute17 := a50(indx);
          t(ddindx).industry_attribute18 := a51(indx);
          t(ddindx).industry_attribute19 := a52(indx);
          t(ddindx).industry_attribute20 := a53(indx);
          t(ddindx).industry_attribute21 := a54(indx);
          t(ddindx).industry_attribute22 := a55(indx);
          t(ddindx).industry_attribute23 := a56(indx);
          t(ddindx).industry_attribute24 := a57(indx);
          t(ddindx).industry_attribute25 := a58(indx);
          t(ddindx).industry_attribute26 := a59(indx);
          t(ddindx).industry_attribute27 := a60(indx);
          t(ddindx).industry_attribute28 := a61(indx);
          t(ddindx).industry_attribute29 := a62(indx);
          t(ddindx).industry_attribute30 := a63(indx);
          t(ddindx).industry_attribute2 := a64(indx);
          t(ddindx).industry_attribute3 := a65(indx);
          t(ddindx).industry_attribute4 := a66(indx);
          t(ddindx).industry_attribute5 := a67(indx);
          t(ddindx).industry_attribute6 := a68(indx);
          t(ddindx).industry_attribute7 := a69(indx);
          t(ddindx).industry_attribute8 := a70(indx);
          t(ddindx).industry_attribute9 := a71(indx);
          t(ddindx).industry_context := a72(indx);
          t(ddindx).tp_context := a73(indx);
          t(ddindx).tp_attribute1 := a74(indx);
          t(ddindx).tp_attribute2 := a75(indx);
          t(ddindx).tp_attribute3 := a76(indx);
          t(ddindx).tp_attribute4 := a77(indx);
          t(ddindx).tp_attribute5 := a78(indx);
          t(ddindx).tp_attribute6 := a79(indx);
          t(ddindx).tp_attribute7 := a80(indx);
          t(ddindx).tp_attribute8 := a81(indx);
          t(ddindx).tp_attribute9 := a82(indx);
          t(ddindx).tp_attribute10 := a83(indx);
          t(ddindx).tp_attribute11 := a84(indx);
          t(ddindx).tp_attribute12 := a85(indx);
          t(ddindx).tp_attribute13 := a86(indx);
          t(ddindx).tp_attribute14 := a87(indx);
          t(ddindx).tp_attribute15 := a88(indx);
          t(ddindx).return_attribute1 := a89(indx);
          t(ddindx).return_attribute10 := a90(indx);
          t(ddindx).return_attribute11 := a91(indx);
          t(ddindx).return_attribute12 := a92(indx);
          t(ddindx).return_attribute13 := a93(indx);
          t(ddindx).return_attribute14 := a94(indx);
          t(ddindx).return_attribute15 := a95(indx);
          t(ddindx).return_attribute2 := a96(indx);
          t(ddindx).return_attribute3 := a97(indx);
          t(ddindx).return_attribute4 := a98(indx);
          t(ddindx).return_attribute5 := a99(indx);
          t(ddindx).return_attribute6 := a100(indx);
          t(ddindx).return_attribute7 := a101(indx);
          t(ddindx).return_attribute8 := a102(indx);
          t(ddindx).return_attribute9 := a103(indx);
          t(ddindx).return_context := a104(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t oe_oe_html_line_ext.line_dff_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a41 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_300();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_300();
    a104 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_300();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_300();
      a104 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute16;
          a8(indx) := t(ddindx).attribute17;
          a9(indx) := t(ddindx).attribute18;
          a10(indx) := t(ddindx).attribute19;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute20;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).global_attribute1;
          a21(indx) := t(ddindx).global_attribute10;
          a22(indx) := t(ddindx).global_attribute11;
          a23(indx) := t(ddindx).global_attribute12;
          a24(indx) := t(ddindx).global_attribute13;
          a25(indx) := t(ddindx).global_attribute14;
          a26(indx) := t(ddindx).global_attribute15;
          a27(indx) := t(ddindx).global_attribute16;
          a28(indx) := t(ddindx).global_attribute17;
          a29(indx) := t(ddindx).global_attribute18;
          a30(indx) := t(ddindx).global_attribute19;
          a31(indx) := t(ddindx).global_attribute2;
          a32(indx) := t(ddindx).global_attribute20;
          a33(indx) := t(ddindx).global_attribute3;
          a34(indx) := t(ddindx).global_attribute4;
          a35(indx) := t(ddindx).global_attribute5;
          a36(indx) := t(ddindx).global_attribute6;
          a37(indx) := t(ddindx).global_attribute7;
          a38(indx) := t(ddindx).global_attribute8;
          a39(indx) := t(ddindx).global_attribute9;
          a40(indx) := t(ddindx).global_attribute_category;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a42(indx) := t(ddindx).industry_attribute1;
          a43(indx) := t(ddindx).industry_attribute10;
          a44(indx) := t(ddindx).industry_attribute11;
          a45(indx) := t(ddindx).industry_attribute12;
          a46(indx) := t(ddindx).industry_attribute13;
          a47(indx) := t(ddindx).industry_attribute14;
          a48(indx) := t(ddindx).industry_attribute15;
          a49(indx) := t(ddindx).industry_attribute16;
          a50(indx) := t(ddindx).industry_attribute17;
          a51(indx) := t(ddindx).industry_attribute18;
          a52(indx) := t(ddindx).industry_attribute19;
          a53(indx) := t(ddindx).industry_attribute20;
          a54(indx) := t(ddindx).industry_attribute21;
          a55(indx) := t(ddindx).industry_attribute22;
          a56(indx) := t(ddindx).industry_attribute23;
          a57(indx) := t(ddindx).industry_attribute24;
          a58(indx) := t(ddindx).industry_attribute25;
          a59(indx) := t(ddindx).industry_attribute26;
          a60(indx) := t(ddindx).industry_attribute27;
          a61(indx) := t(ddindx).industry_attribute28;
          a62(indx) := t(ddindx).industry_attribute29;
          a63(indx) := t(ddindx).industry_attribute30;
          a64(indx) := t(ddindx).industry_attribute2;
          a65(indx) := t(ddindx).industry_attribute3;
          a66(indx) := t(ddindx).industry_attribute4;
          a67(indx) := t(ddindx).industry_attribute5;
          a68(indx) := t(ddindx).industry_attribute6;
          a69(indx) := t(ddindx).industry_attribute7;
          a70(indx) := t(ddindx).industry_attribute8;
          a71(indx) := t(ddindx).industry_attribute9;
          a72(indx) := t(ddindx).industry_context;
          a73(indx) := t(ddindx).tp_context;
          a74(indx) := t(ddindx).tp_attribute1;
          a75(indx) := t(ddindx).tp_attribute2;
          a76(indx) := t(ddindx).tp_attribute3;
          a77(indx) := t(ddindx).tp_attribute4;
          a78(indx) := t(ddindx).tp_attribute5;
          a79(indx) := t(ddindx).tp_attribute6;
          a80(indx) := t(ddindx).tp_attribute7;
          a81(indx) := t(ddindx).tp_attribute8;
          a82(indx) := t(ddindx).tp_attribute9;
          a83(indx) := t(ddindx).tp_attribute10;
          a84(indx) := t(ddindx).tp_attribute11;
          a85(indx) := t(ddindx).tp_attribute12;
          a86(indx) := t(ddindx).tp_attribute13;
          a87(indx) := t(ddindx).tp_attribute14;
          a88(indx) := t(ddindx).tp_attribute15;
          a89(indx) := t(ddindx).return_attribute1;
          a90(indx) := t(ddindx).return_attribute10;
          a91(indx) := t(ddindx).return_attribute11;
          a92(indx) := t(ddindx).return_attribute12;
          a93(indx) := t(ddindx).return_attribute13;
          a94(indx) := t(ddindx).return_attribute14;
          a95(indx) := t(ddindx).return_attribute15;
          a96(indx) := t(ddindx).return_attribute2;
          a97(indx) := t(ddindx).return_attribute3;
          a98(indx) := t(ddindx).return_attribute4;
          a99(indx) := t(ddindx).return_attribute5;
          a100(indx) := t(ddindx).return_attribute6;
          a101(indx) := t(ddindx).return_attribute7;
          a102(indx) := t(ddindx).return_attribute8;
          a103(indx) := t(ddindx).return_attribute9;
          a104(indx) := t(ddindx).return_context;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out NOCOPY /* file.sql.39 change */ oe_oe_html_line_ext.line_ext_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_400
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_400
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_400
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_400
    , a110 JTF_VARCHAR2_TABLE_100
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_400
    , a117 JTF_VARCHAR2_TABLE_2000
    , a118 JTF_VARCHAR2_TABLE_2000
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_400
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_400
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_VARCHAR2_TABLE_400
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_400
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_400
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_300
    , a144 JTF_VARCHAR2_TABLE_300
    , a145 JTF_VARCHAR2_TABLE_400
    , a146 JTF_NUMBER_TABLE
    , a147 JTF_NUMBER_TABLE
    , a148 JTF_NUMBER_TABLE
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).accounting_rule := a0(indx);
          t(ddindx).agreement := a1(indx);
          t(ddindx).commitment := a2(indx);
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).deliver_to_address1 := a4(indx);
          t(ddindx).deliver_to_address2 := a5(indx);
          t(ddindx).deliver_to_address3 := a6(indx);
          t(ddindx).deliver_to_address4 := a7(indx);
          t(ddindx).deliver_to_contact := a8(indx);
          t(ddindx).deliver_to_location := a9(indx);
          t(ddindx).deliver_to_org := a10(indx);
          t(ddindx).deliver_to_state := a11(indx);
          t(ddindx).deliver_to_city := a12(indx);
          t(ddindx).deliver_to_zip := a13(indx);
          t(ddindx).deliver_to_country := a14(indx);
          t(ddindx).deliver_to_county := a15(indx);
          t(ddindx).deliver_to_province := a16(indx);
          t(ddindx).demand_class := a17(indx);
          t(ddindx).demand_bucket_type := a18(indx);
          t(ddindx).fob_point := a19(indx);
          t(ddindx).freight_terms := a20(indx);
          t(ddindx).inventory_item := a21(indx);
          t(ddindx).invoice_to_address1 := a22(indx);
          t(ddindx).invoice_to_address2 := a23(indx);
          t(ddindx).invoice_to_address3 := a24(indx);
          t(ddindx).invoice_to_address4 := a25(indx);
          t(ddindx).invoice_to_contact := a26(indx);
          t(ddindx).invoice_to_location := a27(indx);
          t(ddindx).invoice_to_org := a28(indx);
          t(ddindx).invoice_to_state := a29(indx);
          t(ddindx).invoice_to_city := a30(indx);
          t(ddindx).invoice_to_zip := a31(indx);
          t(ddindx).invoice_to_country := a32(indx);
          t(ddindx).invoice_to_county := a33(indx);
          t(ddindx).invoice_to_province := a34(indx);
          t(ddindx).invoicing_rule := a35(indx);
          t(ddindx).item_type := a36(indx);
          t(ddindx).line_type := a37(indx);
          t(ddindx).over_ship_reason := a38(indx);
          t(ddindx).payment_term := a39(indx);
          t(ddindx).price_list := a40(indx);
          t(ddindx).project := a41(indx);
          t(ddindx).return_reason := a42(indx);
          t(ddindx).rla_schedule_type := a43(indx);
          t(ddindx).salesrep := a44(indx);
          t(ddindx).shipment_priority := a45(indx);
          t(ddindx).ship_from_address1 := a46(indx);
          t(ddindx).ship_from_address2 := a47(indx);
          t(ddindx).ship_from_address3 := a48(indx);
          t(ddindx).ship_from_address4 := a49(indx);
          t(ddindx).ship_from_location := a50(indx);
          t(ddindx).ship_from_city := a51(indx);
          t(ddindx).ship_from_postal_code := a52(indx);
          t(ddindx).ship_from_country := a53(indx);
          t(ddindx).ship_from_region1 := a54(indx);
          t(ddindx).ship_from_region2 := a55(indx);
          t(ddindx).ship_from_region3 := a56(indx);
          t(ddindx).ship_from_org := a57(indx);
          t(ddindx).ship_to_address1 := a58(indx);
          t(ddindx).ship_to_address2 := a59(indx);
          t(ddindx).ship_to_address3 := a60(indx);
          t(ddindx).ship_to_address4 := a61(indx);
          t(ddindx).ship_to_state := a62(indx);
          t(ddindx).ship_to_country := a63(indx);
          t(ddindx).ship_to_zip := a64(indx);
          t(ddindx).ship_to_county := a65(indx);
          t(ddindx).ship_to_province := a66(indx);
          t(ddindx).ship_to_city := a67(indx);
          t(ddindx).ship_to_contact := a68(indx);
          t(ddindx).ship_to_contact_last_name := a69(indx);
          t(ddindx).ship_to_contact_first_name := a70(indx);
          t(ddindx).ship_to_location := a71(indx);
          t(ddindx).ship_to_org := a72(indx);
          t(ddindx).source_type := a73(indx);
          t(ddindx).intermed_ship_to_address1 := a74(indx);
          t(ddindx).intermed_ship_to_address2 := a75(indx);
          t(ddindx).intermed_ship_to_address3 := a76(indx);
          t(ddindx).intermed_ship_to_address4 := a77(indx);
          t(ddindx).intermed_ship_to_contact := a78(indx);
          t(ddindx).intermed_ship_to_location := a79(indx);
          t(ddindx).intermed_ship_to_org := a80(indx);
          t(ddindx).intermed_ship_to_state := a81(indx);
          t(ddindx).intermed_ship_to_city := a82(indx);
          t(ddindx).intermed_ship_to_zip := a83(indx);
          t(ddindx).intermed_ship_to_country := a84(indx);
          t(ddindx).intermed_ship_to_county := a85(indx);
          t(ddindx).intermed_ship_to_province := a86(indx);
          t(ddindx).sold_to_org := a87(indx);
          t(ddindx).sold_from_org := a88(indx);
          t(ddindx).task := a89(indx);
          t(ddindx).tax_exempt := a90(indx);
          t(ddindx).tax_exempt_reason := a91(indx);
          t(ddindx).tax_point := a92(indx);
          t(ddindx).veh_cus_item_cum_key := a93(indx);
          t(ddindx).visible_demand := a94(indx);
          t(ddindx).customer_payment_term := a95(indx);
          t(ddindx).ref_order_number := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).ref_line_number := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).ref_shipment_number := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).ref_option_number := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).ref_invoice_number := a100(indx);
          t(ddindx).ref_invoice_line_number := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).credit_invoice_number := a102(indx);
          t(ddindx).tax_group := a103(indx);
          t(ddindx).status := a104(indx);
          t(ddindx).freight_carrier := a105(indx);
          t(ddindx).shipping_method := a106(indx);
          t(ddindx).calculate_price_descr := a107(indx);
          t(ddindx).ship_to_customer_name := a108(indx);
          t(ddindx).invoice_to_customer_name := a109(indx);
          t(ddindx).ship_to_customer_number := a110(indx);
          t(ddindx).invoice_to_customer_number := a111(indx);
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a112(indx));
          t(ddindx).invoice_to_customer_id := rosetta_g_miss_num_map(a113(indx));
          t(ddindx).deliver_to_customer_id := rosetta_g_miss_num_map(a114(indx));
          t(ddindx).deliver_to_customer_number := a115(indx);
          t(ddindx).deliver_to_customer_name := a116(indx);
          t(ddindx).original_ordered_item := a117(indx);
          t(ddindx).original_inventory_item := a118(indx);
          t(ddindx).original_item_identifier_type := a119(indx);
          t(ddindx).deliver_to_customer_number_oi := a120(indx);
          t(ddindx).deliver_to_customer_name_oi := a121(indx);
          t(ddindx).ship_to_customer_number_oi := a122(indx);
          t(ddindx).ship_to_customer_name_oi := a123(indx);
          t(ddindx).invoice_to_customer_number_oi := a124(indx);
          t(ddindx).invoice_to_customer_name_oi := a125(indx);
          t(ddindx).item_relationship_type_dsp := a126(indx);
          t(ddindx).transaction_phase := a127(indx);
          t(ddindx).end_customer_name := a128(indx);
          t(ddindx).end_customer_number := a129(indx);
          t(ddindx).end_customer_contact := a130(indx);
          t(ddindx).end_cust_contact_last_name := a131(indx);
          t(ddindx).end_cust_contact_first_name := a132(indx);
          t(ddindx).end_customer_site_address1 := a133(indx);
          t(ddindx).end_customer_site_address2 := a134(indx);
          t(ddindx).end_customer_site_address3 := a135(indx);
          t(ddindx).end_customer_site_address4 := a136(indx);
          t(ddindx).end_customer_site_location := a137(indx);
          t(ddindx).end_customer_site_state := a138(indx);
          t(ddindx).end_customer_site_country := a139(indx);
          t(ddindx).end_customer_site_zip := a140(indx);
          t(ddindx).end_customer_site_county := a141(indx);
          t(ddindx).end_customer_site_province := a142(indx);
          t(ddindx).end_customer_site_city := a143(indx);
          t(ddindx).end_customer_site_postal_code := a144(indx);
          t(ddindx).blanket_agreement_name := a145(indx);
          t(ddindx).extended_price := rosetta_g_miss_num_map(a146(indx));
          t(ddindx).unit_selling_price := rosetta_g_miss_num_map(a147(indx));
          t(ddindx).unit_list_price := rosetta_g_miss_num_map(a148(indx));
          t(ddindx).line_number := a149(indx);
          t(ddindx).item_description := a150(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t oe_oe_html_line_ext.line_ext_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a98 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a143 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a144 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a146 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a147 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a148 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a149 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a150 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_400();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_400();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_400();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_VARCHAR2_TABLE_100();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_400();
    a109 := JTF_VARCHAR2_TABLE_400();
    a110 := JTF_VARCHAR2_TABLE_100();
    a111 := JTF_VARCHAR2_TABLE_100();
    a112 := JTF_NUMBER_TABLE();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_NUMBER_TABLE();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_400();
    a117 := JTF_VARCHAR2_TABLE_2000();
    a118 := JTF_VARCHAR2_TABLE_2000();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_100();
    a121 := JTF_VARCHAR2_TABLE_400();
    a122 := JTF_VARCHAR2_TABLE_100();
    a123 := JTF_VARCHAR2_TABLE_400();
    a124 := JTF_VARCHAR2_TABLE_100();
    a125 := JTF_VARCHAR2_TABLE_400();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_400();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_VARCHAR2_TABLE_400();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_300();
    a133 := JTF_VARCHAR2_TABLE_300();
    a134 := JTF_VARCHAR2_TABLE_300();
    a135 := JTF_VARCHAR2_TABLE_300();
    a136 := JTF_VARCHAR2_TABLE_300();
    a137 := JTF_VARCHAR2_TABLE_300();
    a138 := JTF_VARCHAR2_TABLE_300();
    a139 := JTF_VARCHAR2_TABLE_300();
    a140 := JTF_VARCHAR2_TABLE_300();
    a141 := JTF_VARCHAR2_TABLE_300();
    a142 := JTF_VARCHAR2_TABLE_300();
    a143 := JTF_VARCHAR2_TABLE_300();
    a144 := JTF_VARCHAR2_TABLE_300();
    a145 := JTF_VARCHAR2_TABLE_400();
    a146 := JTF_NUMBER_TABLE();
    a147 := JTF_NUMBER_TABLE();
    a148 := JTF_NUMBER_TABLE();
    a149 := JTF_VARCHAR2_TABLE_100();
    a150 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_400();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_400();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_400();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_VARCHAR2_TABLE_100();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_400();
      a109 := JTF_VARCHAR2_TABLE_400();
      a110 := JTF_VARCHAR2_TABLE_100();
      a111 := JTF_VARCHAR2_TABLE_100();
      a112 := JTF_NUMBER_TABLE();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_NUMBER_TABLE();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_400();
      a117 := JTF_VARCHAR2_TABLE_2000();
      a118 := JTF_VARCHAR2_TABLE_2000();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_100();
      a121 := JTF_VARCHAR2_TABLE_400();
      a122 := JTF_VARCHAR2_TABLE_100();
      a123 := JTF_VARCHAR2_TABLE_400();
      a124 := JTF_VARCHAR2_TABLE_100();
      a125 := JTF_VARCHAR2_TABLE_400();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_400();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_VARCHAR2_TABLE_400();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_300();
      a133 := JTF_VARCHAR2_TABLE_300();
      a134 := JTF_VARCHAR2_TABLE_300();
      a135 := JTF_VARCHAR2_TABLE_300();
      a136 := JTF_VARCHAR2_TABLE_300();
      a137 := JTF_VARCHAR2_TABLE_300();
      a138 := JTF_VARCHAR2_TABLE_300();
      a139 := JTF_VARCHAR2_TABLE_300();
      a140 := JTF_VARCHAR2_TABLE_300();
      a141 := JTF_VARCHAR2_TABLE_300();
      a142 := JTF_VARCHAR2_TABLE_300();
      a143 := JTF_VARCHAR2_TABLE_300();
      a144 := JTF_VARCHAR2_TABLE_300();
      a145 := JTF_VARCHAR2_TABLE_400();
      a146 := JTF_NUMBER_TABLE();
      a147 := JTF_NUMBER_TABLE();
      a148 := JTF_NUMBER_TABLE();
      a149 := JTF_VARCHAR2_TABLE_100();
      a150 := JTF_VARCHAR2_TABLE_1000();
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
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).accounting_rule;
          a1(indx) := t(ddindx).agreement;
          a2(indx) := t(ddindx).commitment;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          a4(indx) := t(ddindx).deliver_to_address1;
          a5(indx) := t(ddindx).deliver_to_address2;
          a6(indx) := t(ddindx).deliver_to_address3;
          a7(indx) := t(ddindx).deliver_to_address4;
          a8(indx) := t(ddindx).deliver_to_contact;
          a9(indx) := t(ddindx).deliver_to_location;
          a10(indx) := t(ddindx).deliver_to_org;
          a11(indx) := t(ddindx).deliver_to_state;
          a12(indx) := t(ddindx).deliver_to_city;
          a13(indx) := t(ddindx).deliver_to_zip;
          a14(indx) := t(ddindx).deliver_to_country;
          a15(indx) := t(ddindx).deliver_to_county;
          a16(indx) := t(ddindx).deliver_to_province;
          a17(indx) := t(ddindx).demand_class;
          a18(indx) := t(ddindx).demand_bucket_type;
          a19(indx) := t(ddindx).fob_point;
          a20(indx) := t(ddindx).freight_terms;
          a21(indx) := t(ddindx).inventory_item;
          a22(indx) := t(ddindx).invoice_to_address1;
          a23(indx) := t(ddindx).invoice_to_address2;
          a24(indx) := t(ddindx).invoice_to_address3;
          a25(indx) := t(ddindx).invoice_to_address4;
          a26(indx) := t(ddindx).invoice_to_contact;
          a27(indx) := t(ddindx).invoice_to_location;
          a28(indx) := t(ddindx).invoice_to_org;
          a29(indx) := t(ddindx).invoice_to_state;
          a30(indx) := t(ddindx).invoice_to_city;
          a31(indx) := t(ddindx).invoice_to_zip;
          a32(indx) := t(ddindx).invoice_to_country;
          a33(indx) := t(ddindx).invoice_to_county;
          a34(indx) := t(ddindx).invoice_to_province;
          a35(indx) := t(ddindx).invoicing_rule;
          a36(indx) := t(ddindx).item_type;
          a37(indx) := t(ddindx).line_type;
          a38(indx) := t(ddindx).over_ship_reason;
          a39(indx) := t(ddindx).payment_term;
          a40(indx) := t(ddindx).price_list;
          a41(indx) := t(ddindx).project;
          a42(indx) := t(ddindx).return_reason;
          a43(indx) := t(ddindx).rla_schedule_type;
          a44(indx) := t(ddindx).salesrep;
          a45(indx) := t(ddindx).shipment_priority;
          a46(indx) := t(ddindx).ship_from_address1;
          a47(indx) := t(ddindx).ship_from_address2;
          a48(indx) := t(ddindx).ship_from_address3;
          a49(indx) := t(ddindx).ship_from_address4;
          a50(indx) := t(ddindx).ship_from_location;
          a51(indx) := t(ddindx).ship_from_city;
          a52(indx) := t(ddindx).ship_from_postal_code;
          a53(indx) := t(ddindx).ship_from_country;
          a54(indx) := t(ddindx).ship_from_region1;
          a55(indx) := t(ddindx).ship_from_region2;
          a56(indx) := t(ddindx).ship_from_region3;
          a57(indx) := t(ddindx).ship_from_org;
          a58(indx) := t(ddindx).ship_to_address1;
          a59(indx) := t(ddindx).ship_to_address2;
          a60(indx) := t(ddindx).ship_to_address3;
          a61(indx) := t(ddindx).ship_to_address4;
          a62(indx) := t(ddindx).ship_to_state;
          a63(indx) := t(ddindx).ship_to_country;
          a64(indx) := t(ddindx).ship_to_zip;
          a65(indx) := t(ddindx).ship_to_county;
          a66(indx) := t(ddindx).ship_to_province;
          a67(indx) := t(ddindx).ship_to_city;
          a68(indx) := t(ddindx).ship_to_contact;
          a69(indx) := t(ddindx).ship_to_contact_last_name;
          a70(indx) := t(ddindx).ship_to_contact_first_name;
          a71(indx) := t(ddindx).ship_to_location;
          a72(indx) := t(ddindx).ship_to_org;
          a73(indx) := t(ddindx).source_type;
          a74(indx) := t(ddindx).intermed_ship_to_address1;
          a75(indx) := t(ddindx).intermed_ship_to_address2;
          a76(indx) := t(ddindx).intermed_ship_to_address3;
          a77(indx) := t(ddindx).intermed_ship_to_address4;
          a78(indx) := t(ddindx).intermed_ship_to_contact;
          a79(indx) := t(ddindx).intermed_ship_to_location;
          a80(indx) := t(ddindx).intermed_ship_to_org;
          a81(indx) := t(ddindx).intermed_ship_to_state;
          a82(indx) := t(ddindx).intermed_ship_to_city;
          a83(indx) := t(ddindx).intermed_ship_to_zip;
          a84(indx) := t(ddindx).intermed_ship_to_country;
          a85(indx) := t(ddindx).intermed_ship_to_county;
          a86(indx) := t(ddindx).intermed_ship_to_province;
          a87(indx) := t(ddindx).sold_to_org;
          a88(indx) := t(ddindx).sold_from_org;
          a89(indx) := t(ddindx).task;
          a90(indx) := t(ddindx).tax_exempt;
          a91(indx) := t(ddindx).tax_exempt_reason;
          a92(indx) := t(ddindx).tax_point;
          a93(indx) := t(ddindx).veh_cus_item_cum_key;
          a94(indx) := t(ddindx).visible_demand;
          a95(indx) := t(ddindx).customer_payment_term;
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).ref_order_number);
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).ref_line_number);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).ref_shipment_number);
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).ref_option_number);
          a100(indx) := t(ddindx).ref_invoice_number;
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).ref_invoice_line_number);
          a102(indx) := t(ddindx).credit_invoice_number;
          a103(indx) := t(ddindx).tax_group;
          a104(indx) := t(ddindx).status;
          a105(indx) := t(ddindx).freight_carrier;
          a106(indx) := t(ddindx).shipping_method;
          a107(indx) := t(ddindx).calculate_price_descr;
          a108(indx) := t(ddindx).ship_to_customer_name;
          a109(indx) := t(ddindx).invoice_to_customer_name;
          a110(indx) := t(ddindx).ship_to_customer_number;
          a111(indx) := t(ddindx).invoice_to_customer_number;
          a112(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a113(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_id);
          a114(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_id);
          a115(indx) := t(ddindx).deliver_to_customer_number;
          a116(indx) := t(ddindx).deliver_to_customer_name;
          a117(indx) := t(ddindx).original_ordered_item;
          a118(indx) := t(ddindx).original_inventory_item;
          a119(indx) := t(ddindx).original_item_identifier_type;
          a120(indx) := t(ddindx).deliver_to_customer_number_oi;
          a121(indx) := t(ddindx).deliver_to_customer_name_oi;
          a122(indx) := t(ddindx).ship_to_customer_number_oi;
          a123(indx) := t(ddindx).ship_to_customer_name_oi;
          a124(indx) := t(ddindx).invoice_to_customer_number_oi;
          a125(indx) := t(ddindx).invoice_to_customer_name_oi;
          a126(indx) := t(ddindx).item_relationship_type_dsp;
          a127(indx) := t(ddindx).transaction_phase;
          a128(indx) := t(ddindx).end_customer_name;
          a129(indx) := t(ddindx).end_customer_number;
          a130(indx) := t(ddindx).end_customer_contact;
          a131(indx) := t(ddindx).end_cust_contact_last_name;
          a132(indx) := t(ddindx).end_cust_contact_first_name;
          a133(indx) := t(ddindx).end_customer_site_address1;
          a134(indx) := t(ddindx).end_customer_site_address2;
          a135(indx) := t(ddindx).end_customer_site_address3;
          a136(indx) := t(ddindx).end_customer_site_address4;
          a137(indx) := t(ddindx).end_customer_site_location;
          a138(indx) := t(ddindx).end_customer_site_state;
          a139(indx) := t(ddindx).end_customer_site_country;
          a140(indx) := t(ddindx).end_customer_site_zip;
          a141(indx) := t(ddindx).end_customer_site_county;
          a142(indx) := t(ddindx).end_customer_site_province;
          a143(indx) := t(ddindx).end_customer_site_city;
          a144(indx) := t(ddindx).end_customer_site_postal_code;
          a145(indx) := t(ddindx).blanket_agreement_name;
          a146(indx) := rosetta_g_miss_num_map(t(ddindx).extended_price);
          a147(indx) := rosetta_g_miss_num_map(t(ddindx).unit_selling_price);
          a148(indx) := rosetta_g_miss_num_map(t(ddindx).unit_list_price);
          a149(indx) := t(ddindx).line_number;
          a150(indx) := t(ddindx).item_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure save_lines(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_cascade_flag out NOCOPY /* file.sql.39 change */  number
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_DATE_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_VARCHAR2_TABLE_1000
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_DATE_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_VARCHAR2_TABLE_100
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_NUMBER_TABLE
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_DATE_TABLE
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_DATE_TABLE
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_NUMBER_TABLE
    , p4_a46 JTF_NUMBER_TABLE
    , p4_a47 JTF_NUMBER_TABLE
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_NUMBER_TABLE
    , p4_a51 JTF_NUMBER_TABLE
    , p4_a52 JTF_NUMBER_TABLE
    , p4_a53 JTF_VARCHAR2_TABLE_2000
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_NUMBER_TABLE
    , p4_a57 JTF_DATE_TABLE
    , p4_a58 JTF_NUMBER_TABLE
    , p4_a59 JTF_DATE_TABLE
    , p4_a60 JTF_VARCHAR2_TABLE_100
    , p4_a61 JTF_NUMBER_TABLE
    , p4_a62 JTF_NUMBER_TABLE
    , p4_a63 JTF_NUMBER_TABLE
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_NUMBER_TABLE
    , p4_a66 JTF_NUMBER_TABLE
    , p4_a67 JTF_NUMBER_TABLE
    , p4_a68 JTF_NUMBER_TABLE
    , p4_a69 JTF_NUMBER_TABLE
    , p4_a70 JTF_VARCHAR2_TABLE_100
    , p4_a71 JTF_VARCHAR2_TABLE_100
    , p4_a72 JTF_NUMBER_TABLE
    , p4_a73 JTF_NUMBER_TABLE
    , p4_a74 JTF_NUMBER_TABLE
    , p4_a75 JTF_VARCHAR2_TABLE_100
    , p4_a76 JTF_VARCHAR2_TABLE_100
    , p4_a77 JTF_NUMBER_TABLE
    , p4_a78 JTF_VARCHAR2_TABLE_100
    , p4_a79 JTF_VARCHAR2_TABLE_100
    , p4_a80 JTF_VARCHAR2_TABLE_100
    , p4_a81 JTF_VARCHAR2_TABLE_100
    , p4_a82 JTF_NUMBER_TABLE
    , p4_a83 JTF_NUMBER_TABLE
    , p4_a84 JTF_VARCHAR2_TABLE_100
    , p4_a85 JTF_NUMBER_TABLE
    , p4_a86 JTF_VARCHAR2_TABLE_300
    , p4_a87 JTF_DATE_TABLE
    , p4_a88 JTF_NUMBER_TABLE
    , p4_a89 JTF_VARCHAR2_TABLE_100
    , p4_a90 JTF_NUMBER_TABLE
    , p4_a91 JTF_NUMBER_TABLE
    , p4_a92 JTF_DATE_TABLE
    , p4_a93 JTF_NUMBER_TABLE
    , p4_a94 JTF_DATE_TABLE
    , p4_a95 JTF_VARCHAR2_TABLE_100
    , p4_a96 JTF_NUMBER_TABLE
    , p4_a97 JTF_NUMBER_TABLE
    , p4_a98 JTF_NUMBER_TABLE
    , p4_a99 JTF_VARCHAR2_TABLE_100
    , p4_a100 JTF_DATE_TABLE
    , p4_a101 JTF_NUMBER_TABLE
    , p4_a102 JTF_NUMBER_TABLE
    , p4_a103 JTF_VARCHAR2_TABLE_100
    , p4_a104 JTF_VARCHAR2_TABLE_100
    , p4_a105 JTF_NUMBER_TABLE
    , p4_a106 JTF_DATE_TABLE
    , p4_a107 JTF_DATE_TABLE
    , p4_a108 JTF_VARCHAR2_TABLE_100
    , p4_a109 JTF_VARCHAR2_TABLE_100
    , p4_a110 JTF_NUMBER_TABLE
    , p4_a111 JTF_VARCHAR2_TABLE_100
    , p4_a112 JTF_NUMBER_TABLE
    , p4_a113 JTF_NUMBER_TABLE
    , p4_a114 JTF_VARCHAR2_TABLE_100
    , p4_a115 JTF_VARCHAR2_TABLE_100
    , p4_a116 JTF_NUMBER_TABLE
    , p4_a117 JTF_NUMBER_TABLE
    , p4_a118 JTF_VARCHAR2_TABLE_100
    , p4_a119 JTF_VARCHAR2_TABLE_100
    , p4_a120 JTF_NUMBER_TABLE
    , p4_a121 JTF_VARCHAR2_TABLE_100
    , p4_a122 JTF_NUMBER_TABLE
    , p4_a123 JTF_NUMBER_TABLE
    , p4_a124 JTF_NUMBER_TABLE
    , p4_a125 JTF_NUMBER_TABLE
    , p4_a126 JTF_NUMBER_TABLE
    , p4_a127 JTF_NUMBER_TABLE
    , p4_a128 JTF_NUMBER_TABLE
    , p4_a129 JTF_NUMBER_TABLE
    , p4_a130 JTF_VARCHAR2_TABLE_2000
    , p4_a131 JTF_NUMBER_TABLE
    , p4_a132 JTF_NUMBER_TABLE
    , p4_a133 JTF_NUMBER_TABLE
    , p4_a134 JTF_VARCHAR2_TABLE_100
    , p4_a135 JTF_NUMBER_TABLE
    , p4_a136 JTF_NUMBER_TABLE
    , p4_a137 JTF_VARCHAR2_TABLE_100
    , p4_a138 JTF_DATE_TABLE
    , p4_a139 JTF_VARCHAR2_TABLE_100
    , p4_a140 JTF_VARCHAR2_TABLE_100
    , p4_a141 JTF_VARCHAR2_TABLE_100
    , p4_a142 JTF_VARCHAR2_TABLE_100
    , p4_a143 JTF_NUMBER_TABLE
    , p4_a144 JTF_NUMBER_TABLE
    , p4_a145 JTF_VARCHAR2_TABLE_100
    , p4_a146 JTF_NUMBER_TABLE
    , p4_a147 JTF_NUMBER_TABLE
    , p4_a148 JTF_NUMBER_TABLE
    , p4_a149 JTF_NUMBER_TABLE
    , p4_a150 JTF_NUMBER_TABLE
    , p4_a151 JTF_NUMBER_TABLE
    , p4_a152 JTF_NUMBER_TABLE
    , p4_a153 JTF_VARCHAR2_TABLE_100
    , p4_a154 JTF_VARCHAR2_TABLE_100
    , p4_a155 JTF_VARCHAR2_TABLE_100
    , p4_a156 JTF_VARCHAR2_TABLE_100
    , p4_a157 JTF_VARCHAR2_TABLE_100
    , p4_a158 JTF_DATE_TABLE
    , p4_a159 JTF_VARCHAR2_TABLE_100
    , p4_a160 JTF_DATE_TABLE
    , p4_a161 JTF_VARCHAR2_TABLE_100
    , p4_a162 JTF_VARCHAR2_TABLE_2000
    , p4_a163 JTF_VARCHAR2_TABLE_100
    , p4_a164 JTF_VARCHAR2_TABLE_100
    , p4_a165 JTF_VARCHAR2_TABLE_100
    , p4_a166 JTF_NUMBER_TABLE
    , p4_a167 JTF_VARCHAR2_TABLE_100
    , p4_a168 JTF_VARCHAR2_TABLE_100
    , p4_a169 JTF_VARCHAR2_TABLE_100
    , p4_a170 JTF_VARCHAR2_TABLE_100
    , p4_a171 JTF_VARCHAR2_TABLE_100
    , p4_a172 JTF_VARCHAR2_TABLE_100
    , p4_a173 JTF_VARCHAR2_TABLE_100
    , p4_a174 JTF_NUMBER_TABLE
    , p4_a175 JTF_NUMBER_TABLE
    , p4_a176 JTF_NUMBER_TABLE
    , p4_a177 JTF_VARCHAR2_TABLE_100
    , p4_a178 JTF_VARCHAR2_TABLE_2000
    , p4_a179 JTF_VARCHAR2_TABLE_2000
    , p4_a180 JTF_VARCHAR2_TABLE_100
    , p4_a181 JTF_NUMBER_TABLE
    , p4_a182 JTF_VARCHAR2_TABLE_100
    , p4_a183 JTF_VARCHAR2_TABLE_2000
    , p4_a184 JTF_NUMBER_TABLE
    , p4_a185 JTF_VARCHAR2_TABLE_100
    , p4_a186 JTF_DATE_TABLE
    , p4_a187 JTF_DATE_TABLE
    , p4_a188 JTF_VARCHAR2_TABLE_100
    , p4_a189 JTF_NUMBER_TABLE
    , p4_a190 JTF_NUMBER_TABLE
    , p4_a191 JTF_NUMBER_TABLE
    , p4_a192 JTF_NUMBER_TABLE
    , p4_a193 JTF_VARCHAR2_TABLE_100
    , p4_a194 JTF_NUMBER_TABLE
    , p4_a195 JTF_NUMBER_TABLE
    , p4_a196 JTF_NUMBER_TABLE
    , p4_a197 JTF_NUMBER_TABLE
    , p4_a198 JTF_VARCHAR2_TABLE_100
    , p4_a199 JTF_VARCHAR2_TABLE_100
    , p4_a200 JTF_VARCHAR2_TABLE_100
    , p4_a201 JTF_NUMBER_TABLE
    , p4_a202 JTF_NUMBER_TABLE
    , p4_a203 JTF_NUMBER_TABLE
    , p4_a204 JTF_NUMBER_TABLE
    , p4_a205 JTF_VARCHAR2_TABLE_300
    , p4_a206 JTF_VARCHAR2_TABLE_100
    , p4_a207 JTF_VARCHAR2_TABLE_100
    , p4_a208 JTF_VARCHAR2_TABLE_100
    , p4_a209 JTF_VARCHAR2_TABLE_100
    , p4_a210 JTF_VARCHAR2_TABLE_100
    , p4_a211 JTF_VARCHAR2_TABLE_100
    , p4_a212 JTF_NUMBER_TABLE
    , p4_a213 JTF_NUMBER_TABLE
    , p4_a214 JTF_DATE_TABLE
    , p4_a215 JTF_NUMBER_TABLE
    , p4_a216 JTF_VARCHAR2_TABLE_100
    , p4_a217 JTF_NUMBER_TABLE
    , p4_a218 JTF_VARCHAR2_TABLE_100
    , p4_a219 JTF_VARCHAR2_TABLE_100
    , p4_a220 JTF_VARCHAR2_TABLE_100
    , p4_a221 JTF_VARCHAR2_TABLE_100
    , p4_a222 JTF_VARCHAR2_TABLE_100
    , p4_a223 JTF_VARCHAR2_TABLE_100
    , p4_a224 JTF_NUMBER_TABLE
    , p4_a225 JTF_NUMBER_TABLE
    , p4_a226 JTF_NUMBER_TABLE
    , p4_a227 JTF_NUMBER_TABLE
    , p4_a228 JTF_VARCHAR2_TABLE_100
    , p4_a229 JTF_NUMBER_TABLE
    , p4_a230 JTF_VARCHAR2_TABLE_100
    , p4_a231 JTF_NUMBER_TABLE
    , p4_a232 JTF_VARCHAR2_TABLE_2000
    , p4_a233 JTF_VARCHAR2_TABLE_100
    , p4_a234 JTF_NUMBER_TABLE
    , p4_a235 JTF_VARCHAR2_TABLE_100
    , p4_a236 JTF_NUMBER_TABLE
    , p4_a237 JTF_NUMBER_TABLE
    , p4_a238 JTF_NUMBER_TABLE
    , p4_a239 JTF_NUMBER_TABLE
    , p4_a240 JTF_NUMBER_TABLE
    , p4_a241 JTF_VARCHAR2_TABLE_1000
    , p4_a242 JTF_VARCHAR2_TABLE_100
    , p4_a243 JTF_NUMBER_TABLE
    , p4_a244 JTF_NUMBER_TABLE
    , p4_a245 JTF_NUMBER_TABLE
    , p4_a246 JTF_NUMBER_TABLE
    , p4_a247 JTF_VARCHAR2_TABLE_100
    , p4_a248 JTF_VARCHAR2_TABLE_100
    , p4_a249 JTF_DATE_TABLE
    , p4_a250 JTF_VARCHAR2_TABLE_100
    , p4_a251 JTF_NUMBER_TABLE
    , p4_a252 JTF_NUMBER_TABLE
    , p4_a253 JTF_VARCHAR2_TABLE_100
    , p4_a254 JTF_VARCHAR2_TABLE_100
    , p4_a255 JTF_VARCHAR2_TABLE_100
    , p4_a256 JTF_NUMBER_TABLE
    , p4_a257 JTF_NUMBER_TABLE
    , p4_a258 JTF_NUMBER_TABLE
    , p4_a259 JTF_VARCHAR2_TABLE_300
    , p4_a260 JTF_DATE_TABLE
    , p4_a261 JTF_VARCHAR2_TABLE_300
    , p4_a262 JTF_DATE_TABLE
    , p4_a263 JTF_NUMBER_TABLE
    , p4_a264 JTF_NUMBER_TABLE
    , p4_a265 JTF_NUMBER_TABLE
    , p4_a266 JTF_NUMBER_TABLE
    , p4_a267 JTF_NUMBER_TABLE
    , p4_a268 JTF_NUMBER_TABLE
    , p4_a269 JTF_NUMBER_TABLE
    , p4_a270 JTF_NUMBER_TABLE
    , p4_a271 JTF_NUMBER_TABLE
    , p4_a272 JTF_NUMBER_TABLE
    , p4_a273 JTF_NUMBER_TABLE
    , p4_a274 JTF_NUMBER_TABLE
    , p4_a275 JTF_NUMBER_TABLE
    , p4_a276 JTF_NUMBER_TABLE
    , p4_a277 JTF_NUMBER_TABLE
    , p4_a278 JTF_NUMBER_TABLE
    , p4_a279 JTF_NUMBER_TABLE
    , p4_a280 JTF_NUMBER_TABLE
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_1000
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_2000
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_VARCHAR2_TABLE_100
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_VARCHAR2_TABLE_300
    , p5_a87 JTF_DATE_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_NUMBER_TABLE
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_DATE_TABLE
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_DATE_TABLE
    , p5_a95 JTF_VARCHAR2_TABLE_100
    , p5_a96 JTF_NUMBER_TABLE
    , p5_a97 JTF_NUMBER_TABLE
    , p5_a98 JTF_NUMBER_TABLE
    , p5_a99 JTF_VARCHAR2_TABLE_100
    , p5_a100 JTF_DATE_TABLE
    , p5_a101 JTF_NUMBER_TABLE
    , p5_a102 JTF_NUMBER_TABLE
    , p5_a103 JTF_VARCHAR2_TABLE_100
    , p5_a104 JTF_VARCHAR2_TABLE_100
    , p5_a105 JTF_NUMBER_TABLE
    , p5_a106 JTF_DATE_TABLE
    , p5_a107 JTF_DATE_TABLE
    , p5_a108 JTF_VARCHAR2_TABLE_100
    , p5_a109 JTF_VARCHAR2_TABLE_100
    , p5_a110 JTF_NUMBER_TABLE
    , p5_a111 JTF_VARCHAR2_TABLE_100
    , p5_a112 JTF_NUMBER_TABLE
    , p5_a113 JTF_NUMBER_TABLE
    , p5_a114 JTF_VARCHAR2_TABLE_100
    , p5_a115 JTF_VARCHAR2_TABLE_100
    , p5_a116 JTF_NUMBER_TABLE
    , p5_a117 JTF_NUMBER_TABLE
    , p5_a118 JTF_VARCHAR2_TABLE_100
    , p5_a119 JTF_VARCHAR2_TABLE_100
    , p5_a120 JTF_NUMBER_TABLE
    , p5_a121 JTF_VARCHAR2_TABLE_100
    , p5_a122 JTF_NUMBER_TABLE
    , p5_a123 JTF_NUMBER_TABLE
    , p5_a124 JTF_NUMBER_TABLE
    , p5_a125 JTF_NUMBER_TABLE
    , p5_a126 JTF_NUMBER_TABLE
    , p5_a127 JTF_NUMBER_TABLE
    , p5_a128 JTF_NUMBER_TABLE
    , p5_a129 JTF_NUMBER_TABLE
    , p5_a130 JTF_VARCHAR2_TABLE_2000
    , p5_a131 JTF_NUMBER_TABLE
    , p5_a132 JTF_NUMBER_TABLE
    , p5_a133 JTF_NUMBER_TABLE
    , p5_a134 JTF_VARCHAR2_TABLE_100
    , p5_a135 JTF_NUMBER_TABLE
    , p5_a136 JTF_NUMBER_TABLE
    , p5_a137 JTF_VARCHAR2_TABLE_100
    , p5_a138 JTF_DATE_TABLE
    , p5_a139 JTF_VARCHAR2_TABLE_100
    , p5_a140 JTF_VARCHAR2_TABLE_100
    , p5_a141 JTF_VARCHAR2_TABLE_100
    , p5_a142 JTF_VARCHAR2_TABLE_100
    , p5_a143 JTF_NUMBER_TABLE
    , p5_a144 JTF_NUMBER_TABLE
    , p5_a145 JTF_VARCHAR2_TABLE_100
    , p5_a146 JTF_NUMBER_TABLE
    , p5_a147 JTF_NUMBER_TABLE
    , p5_a148 JTF_NUMBER_TABLE
    , p5_a149 JTF_NUMBER_TABLE
    , p5_a150 JTF_NUMBER_TABLE
    , p5_a151 JTF_NUMBER_TABLE
    , p5_a152 JTF_NUMBER_TABLE
    , p5_a153 JTF_VARCHAR2_TABLE_100
    , p5_a154 JTF_VARCHAR2_TABLE_100
    , p5_a155 JTF_VARCHAR2_TABLE_100
    , p5_a156 JTF_VARCHAR2_TABLE_100
    , p5_a157 JTF_VARCHAR2_TABLE_100
    , p5_a158 JTF_DATE_TABLE
    , p5_a159 JTF_VARCHAR2_TABLE_100
    , p5_a160 JTF_DATE_TABLE
    , p5_a161 JTF_VARCHAR2_TABLE_100
    , p5_a162 JTF_VARCHAR2_TABLE_2000
    , p5_a163 JTF_VARCHAR2_TABLE_100
    , p5_a164 JTF_VARCHAR2_TABLE_100
    , p5_a165 JTF_VARCHAR2_TABLE_100
    , p5_a166 JTF_NUMBER_TABLE
    , p5_a167 JTF_VARCHAR2_TABLE_100
    , p5_a168 JTF_VARCHAR2_TABLE_100
    , p5_a169 JTF_VARCHAR2_TABLE_100
    , p5_a170 JTF_VARCHAR2_TABLE_100
    , p5_a171 JTF_VARCHAR2_TABLE_100
    , p5_a172 JTF_VARCHAR2_TABLE_100
    , p5_a173 JTF_VARCHAR2_TABLE_100
    , p5_a174 JTF_NUMBER_TABLE
    , p5_a175 JTF_NUMBER_TABLE
    , p5_a176 JTF_NUMBER_TABLE
    , p5_a177 JTF_VARCHAR2_TABLE_100
    , p5_a178 JTF_VARCHAR2_TABLE_2000
    , p5_a179 JTF_VARCHAR2_TABLE_2000
    , p5_a180 JTF_VARCHAR2_TABLE_100
    , p5_a181 JTF_NUMBER_TABLE
    , p5_a182 JTF_VARCHAR2_TABLE_100
    , p5_a183 JTF_VARCHAR2_TABLE_2000
    , p5_a184 JTF_NUMBER_TABLE
    , p5_a185 JTF_VARCHAR2_TABLE_100
    , p5_a186 JTF_DATE_TABLE
    , p5_a187 JTF_DATE_TABLE
    , p5_a188 JTF_VARCHAR2_TABLE_100
    , p5_a189 JTF_NUMBER_TABLE
    , p5_a190 JTF_NUMBER_TABLE
    , p5_a191 JTF_NUMBER_TABLE
    , p5_a192 JTF_NUMBER_TABLE
    , p5_a193 JTF_VARCHAR2_TABLE_100
    , p5_a194 JTF_NUMBER_TABLE
    , p5_a195 JTF_NUMBER_TABLE
    , p5_a196 JTF_NUMBER_TABLE
    , p5_a197 JTF_NUMBER_TABLE
    , p5_a198 JTF_VARCHAR2_TABLE_100
    , p5_a199 JTF_VARCHAR2_TABLE_100
    , p5_a200 JTF_VARCHAR2_TABLE_100
    , p5_a201 JTF_NUMBER_TABLE
    , p5_a202 JTF_NUMBER_TABLE
    , p5_a203 JTF_NUMBER_TABLE
    , p5_a204 JTF_NUMBER_TABLE
    , p5_a205 JTF_VARCHAR2_TABLE_300
    , p5_a206 JTF_VARCHAR2_TABLE_100
    , p5_a207 JTF_VARCHAR2_TABLE_100
    , p5_a208 JTF_VARCHAR2_TABLE_100
    , p5_a209 JTF_VARCHAR2_TABLE_100
    , p5_a210 JTF_VARCHAR2_TABLE_100
    , p5_a211 JTF_VARCHAR2_TABLE_100
    , p5_a212 JTF_NUMBER_TABLE
    , p5_a213 JTF_NUMBER_TABLE
    , p5_a214 JTF_DATE_TABLE
    , p5_a215 JTF_NUMBER_TABLE
    , p5_a216 JTF_VARCHAR2_TABLE_100
    , p5_a217 JTF_NUMBER_TABLE
    , p5_a218 JTF_VARCHAR2_TABLE_100
    , p5_a219 JTF_VARCHAR2_TABLE_100
    , p5_a220 JTF_VARCHAR2_TABLE_100
    , p5_a221 JTF_VARCHAR2_TABLE_100
    , p5_a222 JTF_VARCHAR2_TABLE_100
    , p5_a223 JTF_VARCHAR2_TABLE_100
    , p5_a224 JTF_NUMBER_TABLE
    , p5_a225 JTF_NUMBER_TABLE
    , p5_a226 JTF_NUMBER_TABLE
    , p5_a227 JTF_NUMBER_TABLE
    , p5_a228 JTF_VARCHAR2_TABLE_100
    , p5_a229 JTF_NUMBER_TABLE
    , p5_a230 JTF_VARCHAR2_TABLE_100
    , p5_a231 JTF_NUMBER_TABLE
    , p5_a232 JTF_VARCHAR2_TABLE_2000
    , p5_a233 JTF_VARCHAR2_TABLE_100
    , p5_a234 JTF_NUMBER_TABLE
    , p5_a235 JTF_VARCHAR2_TABLE_100
    , p5_a236 JTF_NUMBER_TABLE
    , p5_a237 JTF_NUMBER_TABLE
    , p5_a238 JTF_NUMBER_TABLE
    , p5_a239 JTF_NUMBER_TABLE
    , p5_a240 JTF_NUMBER_TABLE
    , p5_a241 JTF_VARCHAR2_TABLE_1000
    , p5_a242 JTF_VARCHAR2_TABLE_100
    , p5_a243 JTF_NUMBER_TABLE
    , p5_a244 JTF_NUMBER_TABLE
    , p5_a245 JTF_NUMBER_TABLE
    , p5_a246 JTF_NUMBER_TABLE
    , p5_a247 JTF_VARCHAR2_TABLE_100
    , p5_a248 JTF_VARCHAR2_TABLE_100
    , p5_a249 JTF_DATE_TABLE
    , p5_a250 JTF_VARCHAR2_TABLE_100
    , p5_a251 JTF_NUMBER_TABLE
    , p5_a252 JTF_NUMBER_TABLE
    , p5_a253 JTF_VARCHAR2_TABLE_100
    , p5_a254 JTF_VARCHAR2_TABLE_100
    , p5_a255 JTF_VARCHAR2_TABLE_100
    , p5_a256 JTF_NUMBER_TABLE
    , p5_a257 JTF_NUMBER_TABLE
    , p5_a258 JTF_NUMBER_TABLE
    , p5_a259 JTF_VARCHAR2_TABLE_300
    , p5_a260 JTF_DATE_TABLE
    , p5_a261 JTF_VARCHAR2_TABLE_300
    , p5_a262 JTF_DATE_TABLE
    , p5_a263 JTF_NUMBER_TABLE
    , p5_a264 JTF_NUMBER_TABLE
    , p5_a265 JTF_NUMBER_TABLE
    , p5_a266 JTF_NUMBER_TABLE
    , p5_a267 JTF_NUMBER_TABLE
    , p5_a268 JTF_NUMBER_TABLE
    , p5_a269 JTF_NUMBER_TABLE
    , p5_a270 JTF_NUMBER_TABLE
    , p5_a271 JTF_NUMBER_TABLE
    , p5_a272 JTF_NUMBER_TABLE
    , p5_a273 JTF_NUMBER_TABLE
    , p5_a274 JTF_NUMBER_TABLE
    , p5_a275 JTF_NUMBER_TABLE
    , p5_a276 JTF_NUMBER_TABLE
    , p5_a277 JTF_NUMBER_TABLE
    , p5_a278 JTF_NUMBER_TABLE
    , p5_a279 JTF_NUMBER_TABLE
    , p5_a280 JTF_NUMBER_TABLE
  )

  as
    ddx_cascade_flag boolean;
    ddp_line_tbl oe_order_pub.line_tbl_type;
    ddp_old_line_tbl oe_order_pub.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    oe_order_pub_w.rosetta_table_copy_in_p19(ddp_line_tbl, p4_a0
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
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      , p4_a71
      , p4_a72
      , p4_a73
      , p4_a74
      , p4_a75
      , p4_a76
      , p4_a77
      , p4_a78
      , p4_a79
      , p4_a80
      , p4_a81
      , p4_a82
      , p4_a83
      , p4_a84
      , p4_a85
      , p4_a86
      , p4_a87
      , p4_a88
      , p4_a89
      , p4_a90
      , p4_a91
      , p4_a92
      , p4_a93
      , p4_a94
      , p4_a95
      , p4_a96
      , p4_a97
      , p4_a98
      , p4_a99
      , p4_a100
      , p4_a101
      , p4_a102
      , p4_a103
      , p4_a104
      , p4_a105
      , p4_a106
      , p4_a107
      , p4_a108
      , p4_a109
      , p4_a110
      , p4_a111
      , p4_a112
      , p4_a113
      , p4_a114
      , p4_a115
      , p4_a116
      , p4_a117
      , p4_a118
      , p4_a119
      , p4_a120
      , p4_a121
      , p4_a122
      , p4_a123
      , p4_a124
      , p4_a125
      , p4_a126
      , p4_a127
      , p4_a128
      , p4_a129
      , p4_a130
      , p4_a131
      , p4_a132
      , p4_a133
      , p4_a134
      , p4_a135
      , p4_a136
      , p4_a137
      , p4_a138
      , p4_a139
      , p4_a140
      , p4_a141
      , p4_a142
      , p4_a143
      , p4_a144
      , p4_a145
      , p4_a146
      , p4_a147
      , p4_a148
      , p4_a149
      , p4_a150
      , p4_a151
      , p4_a152
      , p4_a153
      , p4_a154
      , p4_a155
      , p4_a156
      , p4_a157
      , p4_a158
      , p4_a159
      , p4_a160
      , p4_a161
      , p4_a162
      , p4_a163
      , p4_a164
      , p4_a165
      , p4_a166
      , p4_a167
      , p4_a168
      , p4_a169
      , p4_a170
      , p4_a171
      , p4_a172
      , p4_a173
      , p4_a174
      , p4_a175
      , p4_a176
      , p4_a177
      , p4_a178
      , p4_a179
      , p4_a180
      , p4_a181
      , p4_a182
      , p4_a183
      , p4_a184
      , p4_a185
      , p4_a186
      , p4_a187
      , p4_a188
      , p4_a189
      , p4_a190
      , p4_a191
      , p4_a192
      , p4_a193
      , p4_a194
      , p4_a195
      , p4_a196
      , p4_a197
      , p4_a198
      , p4_a199
      , p4_a200
      , p4_a201
      , p4_a202
      , p4_a203
      , p4_a204
      , p4_a205
      , p4_a206
      , p4_a207
      , p4_a208
      , p4_a209
      , p4_a210
      , p4_a211
      , p4_a212
      , p4_a213
      , p4_a214
      , p4_a215
      , p4_a216
      , p4_a217
      , p4_a218
      , p4_a219
      , p4_a220
      , p4_a221
      , p4_a222
      , p4_a223
      , p4_a224
      , p4_a225
      , p4_a226
      , p4_a227
      , p4_a228
      , p4_a229
      , p4_a230
      , p4_a231
      , p4_a232
      , p4_a233
      , p4_a234
      , p4_a235
      , p4_a236
      , p4_a237
      , p4_a238
      , p4_a239
      , p4_a240
      , p4_a241
      , p4_a242
      , p4_a243
      , p4_a244
      , p4_a245
      , p4_a246
      , p4_a247
      , p4_a248
      , p4_a249
      , p4_a250
      , p4_a251
      , p4_a252
      , p4_a253
      , p4_a254
      , p4_a255
      , p4_a256
      , p4_a257
      , p4_a258
      , p4_a259
      , p4_a260
      , p4_a261
      , p4_a262
      , p4_a263
      , p4_a264
      , p4_a265
      , p4_a266
      , p4_a267
      , p4_a268
      , p4_a269
      , p4_a270
      , p4_a271
      , p4_a272
      , p4_a273
      , p4_a274
      , p4_a275
      , p4_a276
      , p4_a277
      , p4_a278
      , p4_a279
      , p4_a280
      );

    oe_order_pub_w.rosetta_table_copy_in_p19(ddp_old_line_tbl, p5_a0
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
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      , p5_a99
      , p5_a100
      , p5_a101
      , p5_a102
      , p5_a103
      , p5_a104
      , p5_a105
      , p5_a106
      , p5_a107
      , p5_a108
      , p5_a109
      , p5_a110
      , p5_a111
      , p5_a112
      , p5_a113
      , p5_a114
      , p5_a115
      , p5_a116
      , p5_a117
      , p5_a118
      , p5_a119
      , p5_a120
      , p5_a121
      , p5_a122
      , p5_a123
      , p5_a124
      , p5_a125
      , p5_a126
      , p5_a127
      , p5_a128
      , p5_a129
      , p5_a130
      , p5_a131
      , p5_a132
      , p5_a133
      , p5_a134
      , p5_a135
      , p5_a136
      , p5_a137
      , p5_a138
      , p5_a139
      , p5_a140
      , p5_a141
      , p5_a142
      , p5_a143
      , p5_a144
      , p5_a145
      , p5_a146
      , p5_a147
      , p5_a148
      , p5_a149
      , p5_a150
      , p5_a151
      , p5_a152
      , p5_a153
      , p5_a154
      , p5_a155
      , p5_a156
      , p5_a157
      , p5_a158
      , p5_a159
      , p5_a160
      , p5_a161
      , p5_a162
      , p5_a163
      , p5_a164
      , p5_a165
      , p5_a166
      , p5_a167
      , p5_a168
      , p5_a169
      , p5_a170
      , p5_a171
      , p5_a172
      , p5_a173
      , p5_a174
      , p5_a175
      , p5_a176
      , p5_a177
      , p5_a178
      , p5_a179
      , p5_a180
      , p5_a181
      , p5_a182
      , p5_a183
      , p5_a184
      , p5_a185
      , p5_a186
      , p5_a187
      , p5_a188
      , p5_a189
      , p5_a190
      , p5_a191
      , p5_a192
      , p5_a193
      , p5_a194
      , p5_a195
      , p5_a196
      , p5_a197
      , p5_a198
      , p5_a199
      , p5_a200
      , p5_a201
      , p5_a202
      , p5_a203
      , p5_a204
      , p5_a205
      , p5_a206
      , p5_a207
      , p5_a208
      , p5_a209
      , p5_a210
      , p5_a211
      , p5_a212
      , p5_a213
      , p5_a214
      , p5_a215
      , p5_a216
      , p5_a217
      , p5_a218
      , p5_a219
      , p5_a220
      , p5_a221
      , p5_a222
      , p5_a223
      , p5_a224
      , p5_a225
      , p5_a226
      , p5_a227
      , p5_a228
      , p5_a229
      , p5_a230
      , p5_a231
      , p5_a232
      , p5_a233
      , p5_a234
      , p5_a235
      , p5_a236
      , p5_a237
      , p5_a238
      , p5_a239
      , p5_a240
      , p5_a241
      , p5_a242
      , p5_a243
      , p5_a244
      , p5_a245
      , p5_a246
      , p5_a247
      , p5_a248
      , p5_a249
      , p5_a250
      , p5_a251
      , p5_a252
      , p5_a253
      , p5_a254
      , p5_a255
      , p5_a256
      , p5_a257
      , p5_a258
      , p5_a259
      , p5_a260
      , p5_a261
      , p5_a262
      , p5_a263
      , p5_a264
      , p5_a265
      , p5_a266
      , p5_a267
      , p5_a268
      , p5_a269
      , p5_a270
      , p5_a271
      , p5_a272
      , p5_a273
      , p5_a274
      , p5_a275
      , p5_a276
      , p5_a277
      , p5_a278
      , p5_a279
      , p5_a280
      );

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_line_ext.save_lines(x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_cascade_flag,
      ddp_line_tbl,
      ddp_old_line_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  if ddx_cascade_flag is null
    then x_cascade_flag := null;
  elsif ddx_cascade_flag
    then x_cascade_flag := 1;
  else x_cascade_flag := 0;
  end if;


  end;

  procedure prepare_lines_dff_for_save(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_300
    , p3_a1 JTF_VARCHAR2_TABLE_300
    , p3_a2 JTF_VARCHAR2_TABLE_300
    , p3_a3 JTF_VARCHAR2_TABLE_300
    , p3_a4 JTF_VARCHAR2_TABLE_300
    , p3_a5 JTF_VARCHAR2_TABLE_300
    , p3_a6 JTF_VARCHAR2_TABLE_300
    , p3_a7 JTF_VARCHAR2_TABLE_300
    , p3_a8 JTF_VARCHAR2_TABLE_300
    , p3_a9 JTF_VARCHAR2_TABLE_300
    , p3_a10 JTF_VARCHAR2_TABLE_300
    , p3_a11 JTF_VARCHAR2_TABLE_300
    , p3_a12 JTF_VARCHAR2_TABLE_300
    , p3_a13 JTF_VARCHAR2_TABLE_300
    , p3_a14 JTF_VARCHAR2_TABLE_300
    , p3_a15 JTF_VARCHAR2_TABLE_300
    , p3_a16 JTF_VARCHAR2_TABLE_300
    , p3_a17 JTF_VARCHAR2_TABLE_300
    , p3_a18 JTF_VARCHAR2_TABLE_300
    , p3_a19 JTF_VARCHAR2_TABLE_300
    , p3_a20 JTF_VARCHAR2_TABLE_300
    , p3_a21 JTF_VARCHAR2_TABLE_300
    , p3_a22 JTF_VARCHAR2_TABLE_300
    , p3_a23 JTF_VARCHAR2_TABLE_300
    , p3_a24 JTF_VARCHAR2_TABLE_300
    , p3_a25 JTF_VARCHAR2_TABLE_300
    , p3_a26 JTF_VARCHAR2_TABLE_300
    , p3_a27 JTF_VARCHAR2_TABLE_300
    , p3_a28 JTF_VARCHAR2_TABLE_300
    , p3_a29 JTF_VARCHAR2_TABLE_300
    , p3_a30 JTF_VARCHAR2_TABLE_300
    , p3_a31 JTF_VARCHAR2_TABLE_300
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_VARCHAR2_TABLE_300
    , p3_a37 JTF_VARCHAR2_TABLE_300
    , p3_a38 JTF_VARCHAR2_TABLE_300
    , p3_a39 JTF_VARCHAR2_TABLE_300
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_NUMBER_TABLE
    , p3_a42 JTF_VARCHAR2_TABLE_300
    , p3_a43 JTF_VARCHAR2_TABLE_300
    , p3_a44 JTF_VARCHAR2_TABLE_300
    , p3_a45 JTF_VARCHAR2_TABLE_300
    , p3_a46 JTF_VARCHAR2_TABLE_300
    , p3_a47 JTF_VARCHAR2_TABLE_300
    , p3_a48 JTF_VARCHAR2_TABLE_300
    , p3_a49 JTF_VARCHAR2_TABLE_300
    , p3_a50 JTF_VARCHAR2_TABLE_300
    , p3_a51 JTF_VARCHAR2_TABLE_300
    , p3_a52 JTF_VARCHAR2_TABLE_300
    , p3_a53 JTF_VARCHAR2_TABLE_300
    , p3_a54 JTF_VARCHAR2_TABLE_300
    , p3_a55 JTF_VARCHAR2_TABLE_300
    , p3_a56 JTF_VARCHAR2_TABLE_300
    , p3_a57 JTF_VARCHAR2_TABLE_300
    , p3_a58 JTF_VARCHAR2_TABLE_300
    , p3_a59 JTF_VARCHAR2_TABLE_300
    , p3_a60 JTF_VARCHAR2_TABLE_300
    , p3_a61 JTF_VARCHAR2_TABLE_300
    , p3_a62 JTF_VARCHAR2_TABLE_300
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_300
    , p3_a65 JTF_VARCHAR2_TABLE_300
    , p3_a66 JTF_VARCHAR2_TABLE_300
    , p3_a67 JTF_VARCHAR2_TABLE_300
    , p3_a68 JTF_VARCHAR2_TABLE_300
    , p3_a69 JTF_VARCHAR2_TABLE_300
    , p3_a70 JTF_VARCHAR2_TABLE_300
    , p3_a71 JTF_VARCHAR2_TABLE_300
    , p3_a72 JTF_VARCHAR2_TABLE_100
    , p3_a73 JTF_VARCHAR2_TABLE_100
    , p3_a74 JTF_VARCHAR2_TABLE_300
    , p3_a75 JTF_VARCHAR2_TABLE_300
    , p3_a76 JTF_VARCHAR2_TABLE_300
    , p3_a77 JTF_VARCHAR2_TABLE_300
    , p3_a78 JTF_VARCHAR2_TABLE_300
    , p3_a79 JTF_VARCHAR2_TABLE_300
    , p3_a80 JTF_VARCHAR2_TABLE_300
    , p3_a81 JTF_VARCHAR2_TABLE_300
    , p3_a82 JTF_VARCHAR2_TABLE_300
    , p3_a83 JTF_VARCHAR2_TABLE_300
    , p3_a84 JTF_VARCHAR2_TABLE_300
    , p3_a85 JTF_VARCHAR2_TABLE_300
    , p3_a86 JTF_VARCHAR2_TABLE_300
    , p3_a87 JTF_VARCHAR2_TABLE_300
    , p3_a88 JTF_VARCHAR2_TABLE_300
    , p3_a89 JTF_VARCHAR2_TABLE_300
    , p3_a90 JTF_VARCHAR2_TABLE_300
    , p3_a91 JTF_VARCHAR2_TABLE_300
    , p3_a92 JTF_VARCHAR2_TABLE_300
    , p3_a93 JTF_VARCHAR2_TABLE_300
    , p3_a94 JTF_VARCHAR2_TABLE_300
    , p3_a95 JTF_VARCHAR2_TABLE_300
    , p3_a96 JTF_VARCHAR2_TABLE_300
    , p3_a97 JTF_VARCHAR2_TABLE_300
    , p3_a98 JTF_VARCHAR2_TABLE_300
    , p3_a99 JTF_VARCHAR2_TABLE_300
    , p3_a100 JTF_VARCHAR2_TABLE_300
    , p3_a101 JTF_VARCHAR2_TABLE_300
    , p3_a102 JTF_VARCHAR2_TABLE_300
    , p3_a103 JTF_VARCHAR2_TABLE_300
    , p3_a104 JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_line_dff_tbl oe_oe_html_line_ext.line_dff_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    oe_oe_html_line_ext_w.rosetta_table_copy_in_p1(ddx_line_dff_tbl, p3_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_line_ext.prepare_lines_dff_for_save(x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_line_dff_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure populate_transient_attributes(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  DATE
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  DATE
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  DATE
    , p0_a58  NUMBER
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  VARCHAR2
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  VARCHAR2
    , p0_a87  DATE
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  DATE
    , p0_a95  VARCHAR2
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  VARCHAR2
    , p0_a100  DATE
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  NUMBER
    , p0_a106  DATE
    , p0_a107  DATE
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  NUMBER
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  NUMBER
    , p0_a114  VARCHAR2
    , p0_a115  VARCHAR2
    , p0_a116  NUMBER
    , p0_a117  NUMBER
    , p0_a118  VARCHAR2
    , p0_a119  VARCHAR2
    , p0_a120  NUMBER
    , p0_a121  VARCHAR2
    , p0_a122  NUMBER
    , p0_a123  NUMBER
    , p0_a124  NUMBER
    , p0_a125  NUMBER
    , p0_a126  NUMBER
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  NUMBER
    , p0_a130  VARCHAR2
    , p0_a131  NUMBER
    , p0_a132  NUMBER
    , p0_a133  NUMBER
    , p0_a134  VARCHAR2
    , p0_a135  NUMBER
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p0_a138  DATE
    , p0_a139  VARCHAR2
    , p0_a140  VARCHAR2
    , p0_a141  VARCHAR2
    , p0_a142  VARCHAR2
    , p0_a143  NUMBER
    , p0_a144  NUMBER
    , p0_a145  VARCHAR2
    , p0_a146  NUMBER
    , p0_a147  NUMBER
    , p0_a148  NUMBER
    , p0_a149  NUMBER
    , p0_a150  NUMBER
    , p0_a151  NUMBER
    , p0_a152  NUMBER
    , p0_a153  VARCHAR2
    , p0_a154  VARCHAR2
    , p0_a155  VARCHAR2
    , p0_a156  VARCHAR2
    , p0_a157  VARCHAR2
    , p0_a158  DATE
    , p0_a159  VARCHAR2
    , p0_a160  DATE
    , p0_a161  VARCHAR2
    , p0_a162  VARCHAR2
    , p0_a163  VARCHAR2
    , p0_a164  VARCHAR2
    , p0_a165  VARCHAR2
    , p0_a166  NUMBER
    , p0_a167  VARCHAR2
    , p0_a168  VARCHAR2
    , p0_a169  VARCHAR2
    , p0_a170  VARCHAR2
    , p0_a171  VARCHAR2
    , p0_a172  VARCHAR2
    , p0_a173  VARCHAR2
    , p0_a174  NUMBER
    , p0_a175  NUMBER
    , p0_a176  NUMBER
    , p0_a177  VARCHAR2
    , p0_a178  VARCHAR2
    , p0_a179  VARCHAR2
    , p0_a180  VARCHAR2
    , p0_a181  NUMBER
    , p0_a182  VARCHAR2
    , p0_a183  VARCHAR2
    , p0_a184  NUMBER
    , p0_a185  VARCHAR2
    , p0_a186  DATE
    , p0_a187  DATE
    , p0_a188  VARCHAR2
    , p0_a189  NUMBER
    , p0_a190  NUMBER
    , p0_a191  NUMBER
    , p0_a192  NUMBER
    , p0_a193  VARCHAR2
    , p0_a194  NUMBER
    , p0_a195  NUMBER
    , p0_a196  NUMBER
    , p0_a197  NUMBER
    , p0_a198  VARCHAR2
    , p0_a199  VARCHAR2
    , p0_a200  VARCHAR2
    , p0_a201  NUMBER
    , p0_a202  NUMBER
    , p0_a203  NUMBER
    , p0_a204  NUMBER
    , p0_a205  VARCHAR2
    , p0_a206  VARCHAR2
    , p0_a207  VARCHAR2
    , p0_a208  VARCHAR2
    , p0_a209  VARCHAR2
    , p0_a210  VARCHAR2
    , p0_a211  VARCHAR2
    , p0_a212  NUMBER
    , p0_a213  NUMBER
    , p0_a214  DATE
    , p0_a215  NUMBER
    , p0_a216  VARCHAR2
    , p0_a217  NUMBER
    , p0_a218  VARCHAR2
    , p0_a219  VARCHAR2
    , p0_a220  VARCHAR2
    , p0_a221  VARCHAR2
    , p0_a222  VARCHAR2
    , p0_a223  VARCHAR2
    , p0_a224  NUMBER
    , p0_a225  NUMBER
    , p0_a226  NUMBER
    , p0_a227  NUMBER
    , p0_a228  VARCHAR2
    , p0_a229  NUMBER
    , p0_a230  VARCHAR2
    , p0_a231  NUMBER
    , p0_a232  VARCHAR2
    , p0_a233  VARCHAR2
    , p0_a234  NUMBER
    , p0_a235  VARCHAR2
    , p0_a236  NUMBER
    , p0_a237  NUMBER
    , p0_a238  NUMBER
    , p0_a239  NUMBER
    , p0_a240  NUMBER
    , p0_a241  VARCHAR2
    , p0_a242  VARCHAR2
    , p0_a243  NUMBER
    , p0_a244  NUMBER
    , p0_a245  NUMBER
    , p0_a246  NUMBER
    , p0_a247  VARCHAR2
    , p0_a248  VARCHAR2
    , p0_a249  DATE
    , p0_a250  VARCHAR2
    , p0_a251  NUMBER
    , p0_a252  NUMBER
    , p0_a253  VARCHAR2
    , p0_a254  VARCHAR2
    , p0_a255  VARCHAR2
    , p0_a256  NUMBER
    , p0_a257  NUMBER
    , p0_a258  NUMBER
    , p0_a259  VARCHAR2
    , p0_a260  DATE
    , p0_a261  VARCHAR2
    , p0_a262  DATE
    , p0_a263  NUMBER
    , p0_a264  NUMBER
    , p0_a265  NUMBER
    , p0_a266  NUMBER
    , p0_a267  NUMBER
    , p0_a268  NUMBER
    , p0_a269  NUMBER
    , p0_a270  NUMBER
    , p0_a271  NUMBER
    , p0_a272  NUMBER
    , p0_a273  NUMBER
    , p0_a274  NUMBER
    , p0_a275  NUMBER
    , p0_a276  NUMBER
    , p0_a277  NUMBER
    , p0_a278  NUMBER
    , p0_a279  NUMBER
    , p0_a280  NUMBER
    , p1_a0 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a1 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a2 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a3 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a4 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a5 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a6 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a7 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a8 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a9 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a10 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a11 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a12 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a13 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a14 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a15 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a16 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a17 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a18 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a19 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a20 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a21 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a22 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a23 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a24 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a25 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a26 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a27 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a29 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a30 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a31 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a32 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a33 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a35 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a36 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a37 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a38 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a39 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a40 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a41 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a42 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a43 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a44 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a45 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a46 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a47 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a48 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a49 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a50 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a51 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a52 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a53 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a54 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a55 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a56 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a57 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a58 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a59 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a60 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a61 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a62 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a63 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a64 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a65 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a66 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a67 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a68 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a69 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a70 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a71 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a72 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a73 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a74 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a75 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a76 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a77 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a78 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a79 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a80 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a81 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a82 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a83 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a84 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a85 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a87 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a88 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a89 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a90 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a91 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a92 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a93 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a94 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a95 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a96 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a97 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a98 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a99 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a100 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a101 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a102 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a103 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a105 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a106 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a107 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a109 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a110 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a111 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a112 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a113 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a114 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a115 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a116 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a117 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a118 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a119 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a120 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a122 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a123 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a124 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a125 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a126 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a127 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a128 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a129 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a130 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a131 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a132 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a133 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a135 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a136 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a138 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a141 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a142 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a143 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a144 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a145 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a146 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a147 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a148 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a149 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a150 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_line_rec oe_order_pub.line_rec_type;
    ddx_line_val_rec oe_oe_html_line_ext.line_ext_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_line_rec.accounting_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_line_rec.actual_arrival_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_line_rec.actual_shipment_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_line_rec.agreement_id := rosetta_g_miss_num_map(p0_a3);
    ddp_line_rec.arrival_set_id := rosetta_g_miss_num_map(p0_a4);
    ddp_line_rec.ato_line_id := rosetta_g_miss_num_map(p0_a5);
    ddp_line_rec.authorized_to_ship_flag := p0_a6;
    ddp_line_rec.auto_selected_quantity := rosetta_g_miss_num_map(p0_a7);
    ddp_line_rec.booked_flag := p0_a8;
    ddp_line_rec.cancelled_flag := p0_a9;
    ddp_line_rec.cancelled_quantity := rosetta_g_miss_num_map(p0_a10);
    ddp_line_rec.cancelled_quantity2 := rosetta_g_miss_num_map(p0_a11);
    ddp_line_rec.commitment_id := rosetta_g_miss_num_map(p0_a12);
    ddp_line_rec.component_code := p0_a13;
    ddp_line_rec.component_number := rosetta_g_miss_num_map(p0_a14);
    ddp_line_rec.component_sequence_id := rosetta_g_miss_num_map(p0_a15);
    ddp_line_rec.config_header_id := rosetta_g_miss_num_map(p0_a16);
    ddp_line_rec.config_rev_nbr := rosetta_g_miss_num_map(p0_a17);
    ddp_line_rec.config_display_sequence := rosetta_g_miss_num_map(p0_a18);
    ddp_line_rec.configuration_id := rosetta_g_miss_num_map(p0_a19);
    ddp_line_rec.context := p0_a20;
    ddp_line_rec.created_by := rosetta_g_miss_num_map(p0_a21);
    ddp_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a22);
    ddp_line_rec.credit_invoice_line_id := rosetta_g_miss_num_map(p0_a23);
    ddp_line_rec.customer_dock_code := p0_a24;
    ddp_line_rec.customer_job := p0_a25;
    ddp_line_rec.customer_production_line := p0_a26;
    ddp_line_rec.customer_trx_line_id := rosetta_g_miss_num_map(p0_a27);
    ddp_line_rec.cust_model_serial_number := p0_a28;
    ddp_line_rec.cust_po_number := p0_a29;
    ddp_line_rec.cust_production_seq_num := p0_a30;
    ddp_line_rec.delivery_lead_time := rosetta_g_miss_num_map(p0_a31);
    ddp_line_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p0_a32);
    ddp_line_rec.deliver_to_org_id := rosetta_g_miss_num_map(p0_a33);
    ddp_line_rec.demand_bucket_type_code := p0_a34;
    ddp_line_rec.demand_class_code := p0_a35;
    ddp_line_rec.dep_plan_required_flag := p0_a36;
    ddp_line_rec.earliest_acceptable_date := rosetta_g_miss_date_in_map(p0_a37);
    ddp_line_rec.end_item_unit_number := p0_a38;
    ddp_line_rec.explosion_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_line_rec.fob_point_code := p0_a40;
    ddp_line_rec.freight_carrier_code := p0_a41;
    ddp_line_rec.freight_terms_code := p0_a42;
    ddp_line_rec.fulfilled_quantity := rosetta_g_miss_num_map(p0_a43);
    ddp_line_rec.fulfilled_quantity2 := rosetta_g_miss_num_map(p0_a44);
    ddp_line_rec.header_id := rosetta_g_miss_num_map(p0_a45);
    ddp_line_rec.intermed_ship_to_org_id := rosetta_g_miss_num_map(p0_a46);
    ddp_line_rec.intermed_ship_to_contact_id := rosetta_g_miss_num_map(p0_a47);
    ddp_line_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a48);
    ddp_line_rec.invoice_interface_status_code := p0_a49;
    ddp_line_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p0_a50);
    ddp_line_rec.invoice_to_org_id := rosetta_g_miss_num_map(p0_a51);
    ddp_line_rec.invoicing_rule_id := rosetta_g_miss_num_map(p0_a52);
    ddp_line_rec.ordered_item := p0_a53;
    ddp_line_rec.item_revision := p0_a54;
    ddp_line_rec.item_type_code := p0_a55;
    ddp_line_rec.last_updated_by := rosetta_g_miss_num_map(p0_a56);
    ddp_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a57);
    ddp_line_rec.last_update_login := rosetta_g_miss_num_map(p0_a58);
    ddp_line_rec.latest_acceptable_date := rosetta_g_miss_date_in_map(p0_a59);
    ddp_line_rec.line_category_code := p0_a60;
    ddp_line_rec.line_id := rosetta_g_miss_num_map(p0_a61);
    ddp_line_rec.line_number := rosetta_g_miss_num_map(p0_a62);
    ddp_line_rec.line_type_id := rosetta_g_miss_num_map(p0_a63);
    ddp_line_rec.link_to_line_ref := p0_a64;
    ddp_line_rec.link_to_line_id := rosetta_g_miss_num_map(p0_a65);
    ddp_line_rec.link_to_line_index := rosetta_g_miss_num_map(p0_a66);
    ddp_line_rec.model_group_number := rosetta_g_miss_num_map(p0_a67);
    ddp_line_rec.mfg_component_sequence_id := rosetta_g_miss_num_map(p0_a68);
    ddp_line_rec.mfg_lead_time := rosetta_g_miss_num_map(p0_a69);
    ddp_line_rec.open_flag := p0_a70;
    ddp_line_rec.option_flag := p0_a71;
    ddp_line_rec.option_number := rosetta_g_miss_num_map(p0_a72);
    ddp_line_rec.ordered_quantity := rosetta_g_miss_num_map(p0_a73);
    ddp_line_rec.ordered_quantity2 := rosetta_g_miss_num_map(p0_a74);
    ddp_line_rec.order_quantity_uom := p0_a75;
    ddp_line_rec.ordered_quantity_uom2 := p0_a76;
    ddp_line_rec.org_id := rosetta_g_miss_num_map(p0_a77);
    ddp_line_rec.orig_sys_document_ref := p0_a78;
    ddp_line_rec.orig_sys_line_ref := p0_a79;
    ddp_line_rec.over_ship_reason_code := p0_a80;
    ddp_line_rec.over_ship_resolved_flag := p0_a81;
    ddp_line_rec.payment_term_id := rosetta_g_miss_num_map(p0_a82);
    ddp_line_rec.planning_priority := rosetta_g_miss_num_map(p0_a83);
    ddp_line_rec.preferred_grade := p0_a84;
    ddp_line_rec.price_list_id := rosetta_g_miss_num_map(p0_a85);
    ddp_line_rec.price_request_code := p0_a86;
    ddp_line_rec.pricing_date := rosetta_g_miss_date_in_map(p0_a87);
    ddp_line_rec.pricing_quantity := rosetta_g_miss_num_map(p0_a88);
    ddp_line_rec.pricing_quantity_uom := p0_a89;
    ddp_line_rec.program_application_id := rosetta_g_miss_num_map(p0_a90);
    ddp_line_rec.program_id := rosetta_g_miss_num_map(p0_a91);
    ddp_line_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a92);
    ddp_line_rec.project_id := rosetta_g_miss_num_map(p0_a93);
    ddp_line_rec.promise_date := rosetta_g_miss_date_in_map(p0_a94);
    ddp_line_rec.re_source_flag := p0_a95;
    ddp_line_rec.reference_customer_trx_line_id := rosetta_g_miss_num_map(p0_a96);
    ddp_line_rec.reference_header_id := rosetta_g_miss_num_map(p0_a97);
    ddp_line_rec.reference_line_id := rosetta_g_miss_num_map(p0_a98);
    ddp_line_rec.reference_type := p0_a99;
    ddp_line_rec.request_date := rosetta_g_miss_date_in_map(p0_a100);
    ddp_line_rec.request_id := rosetta_g_miss_num_map(p0_a101);
    ddp_line_rec.reserved_quantity := rosetta_g_miss_num_map(p0_a102);
    ddp_line_rec.return_reason_code := p0_a103;
    ddp_line_rec.rla_schedule_type_code := p0_a104;
    ddp_line_rec.salesrep_id := rosetta_g_miss_num_map(p0_a105);
    ddp_line_rec.schedule_arrival_date := rosetta_g_miss_date_in_map(p0_a106);
    ddp_line_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p0_a107);
    ddp_line_rec.schedule_action_code := p0_a108;
    ddp_line_rec.schedule_status_code := p0_a109;
    ddp_line_rec.shipment_number := rosetta_g_miss_num_map(p0_a110);
    ddp_line_rec.shipment_priority_code := p0_a111;
    ddp_line_rec.shipped_quantity := rosetta_g_miss_num_map(p0_a112);
    ddp_line_rec.shipped_quantity2 := rosetta_g_miss_num_map(p0_a113);
    ddp_line_rec.shipping_interfaced_flag := p0_a114;
    ddp_line_rec.shipping_method_code := p0_a115;
    ddp_line_rec.shipping_quantity := rosetta_g_miss_num_map(p0_a116);
    ddp_line_rec.shipping_quantity2 := rosetta_g_miss_num_map(p0_a117);
    ddp_line_rec.shipping_quantity_uom := p0_a118;
    ddp_line_rec.shipping_quantity_uom2 := p0_a119;
    ddp_line_rec.ship_from_org_id := rosetta_g_miss_num_map(p0_a120);
    ddp_line_rec.ship_model_complete_flag := p0_a121;
    ddp_line_rec.ship_set_id := rosetta_g_miss_num_map(p0_a122);
    ddp_line_rec.fulfillment_set_id := rosetta_g_miss_num_map(p0_a123);
    ddp_line_rec.ship_tolerance_above := rosetta_g_miss_num_map(p0_a124);
    ddp_line_rec.ship_tolerance_below := rosetta_g_miss_num_map(p0_a125);
    ddp_line_rec.ship_to_contact_id := rosetta_g_miss_num_map(p0_a126);
    ddp_line_rec.ship_to_org_id := rosetta_g_miss_num_map(p0_a127);
    ddp_line_rec.sold_to_org_id := rosetta_g_miss_num_map(p0_a128);
    ddp_line_rec.sold_from_org_id := rosetta_g_miss_num_map(p0_a129);
    ddp_line_rec.sort_order := p0_a130;
    ddp_line_rec.source_document_id := rosetta_g_miss_num_map(p0_a131);
    ddp_line_rec.source_document_line_id := rosetta_g_miss_num_map(p0_a132);
    ddp_line_rec.source_document_type_id := rosetta_g_miss_num_map(p0_a133);
    ddp_line_rec.source_type_code := p0_a134;
    ddp_line_rec.split_from_line_id := rosetta_g_miss_num_map(p0_a135);
    ddp_line_rec.task_id := rosetta_g_miss_num_map(p0_a136);
    ddp_line_rec.tax_code := p0_a137;
    ddp_line_rec.tax_date := rosetta_g_miss_date_in_map(p0_a138);
    ddp_line_rec.tax_exempt_flag := p0_a139;
    ddp_line_rec.tax_exempt_number := p0_a140;
    ddp_line_rec.tax_exempt_reason_code := p0_a141;
    ddp_line_rec.tax_point_code := p0_a142;
    ddp_line_rec.tax_rate := rosetta_g_miss_num_map(p0_a143);
    ddp_line_rec.tax_value := rosetta_g_miss_num_map(p0_a144);
    ddp_line_rec.top_model_line_ref := p0_a145;
    ddp_line_rec.top_model_line_id := rosetta_g_miss_num_map(p0_a146);
    ddp_line_rec.top_model_line_index := rosetta_g_miss_num_map(p0_a147);
    ddp_line_rec.unit_list_price := rosetta_g_miss_num_map(p0_a148);
    ddp_line_rec.unit_list_price_per_pqty := rosetta_g_miss_num_map(p0_a149);
    ddp_line_rec.unit_selling_price := rosetta_g_miss_num_map(p0_a150);
    ddp_line_rec.unit_selling_price_per_pqty := rosetta_g_miss_num_map(p0_a151);
    ddp_line_rec.veh_cus_item_cum_key_id := rosetta_g_miss_num_map(p0_a152);
    ddp_line_rec.visible_demand_flag := p0_a153;
    ddp_line_rec.return_status := p0_a154;
    ddp_line_rec.db_flag := p0_a155;
    ddp_line_rec.operation := p0_a156;
    ddp_line_rec.first_ack_code := p0_a157;
    ddp_line_rec.first_ack_date := rosetta_g_miss_date_in_map(p0_a158);
    ddp_line_rec.last_ack_code := p0_a159;
    ddp_line_rec.last_ack_date := rosetta_g_miss_date_in_map(p0_a160);
    ddp_line_rec.change_reason := p0_a161;
    ddp_line_rec.change_comments := p0_a162;
    ddp_line_rec.arrival_set := p0_a163;
    ddp_line_rec.ship_set := p0_a164;
    ddp_line_rec.fulfillment_set := p0_a165;
    ddp_line_rec.order_source_id := rosetta_g_miss_num_map(p0_a166);
    ddp_line_rec.orig_sys_shipment_ref := p0_a167;
    ddp_line_rec.change_sequence := p0_a168;
    ddp_line_rec.change_request_code := p0_a169;
    ddp_line_rec.status_flag := p0_a170;
    ddp_line_rec.drop_ship_flag := p0_a171;
    ddp_line_rec.customer_line_number := p0_a172;
    ddp_line_rec.customer_shipment_number := p0_a173;
    ddp_line_rec.customer_item_net_price := rosetta_g_miss_num_map(p0_a174);
    ddp_line_rec.customer_payment_term_id := rosetta_g_miss_num_map(p0_a175);
    ddp_line_rec.ordered_item_id := rosetta_g_miss_num_map(p0_a176);
    ddp_line_rec.item_identifier_type := p0_a177;
    ddp_line_rec.shipping_instructions := p0_a178;
    ddp_line_rec.packing_instructions := p0_a179;
    ddp_line_rec.calculate_price_flag := p0_a180;
    ddp_line_rec.invoiced_quantity := rosetta_g_miss_num_map(p0_a181);
    ddp_line_rec.service_txn_reason_code := p0_a182;
    ddp_line_rec.service_txn_comments := p0_a183;
    ddp_line_rec.service_duration := rosetta_g_miss_num_map(p0_a184);
    ddp_line_rec.service_period := p0_a185;
    ddp_line_rec.service_start_date := rosetta_g_miss_date_in_map(p0_a186);
    ddp_line_rec.service_end_date := rosetta_g_miss_date_in_map(p0_a187);
    ddp_line_rec.service_coterminate_flag := p0_a188;
    ddp_line_rec.unit_list_percent := rosetta_g_miss_num_map(p0_a189);
    ddp_line_rec.unit_selling_percent := rosetta_g_miss_num_map(p0_a190);
    ddp_line_rec.unit_percent_base_price := rosetta_g_miss_num_map(p0_a191);
    ddp_line_rec.service_number := rosetta_g_miss_num_map(p0_a192);
    ddp_line_rec.service_reference_type_code := p0_a193;
    ddp_line_rec.service_reference_line_id := rosetta_g_miss_num_map(p0_a194);
    ddp_line_rec.service_reference_system_id := rosetta_g_miss_num_map(p0_a195);
    ddp_line_rec.service_ref_order_number := rosetta_g_miss_num_map(p0_a196);
    ddp_line_rec.service_ref_line_number := rosetta_g_miss_num_map(p0_a197);
    ddp_line_rec.service_reference_order := p0_a198;
    ddp_line_rec.service_reference_line := p0_a199;
    ddp_line_rec.service_reference_system := p0_a200;
    ddp_line_rec.service_ref_shipment_number := rosetta_g_miss_num_map(p0_a201);
    ddp_line_rec.service_ref_option_number := rosetta_g_miss_num_map(p0_a202);
    ddp_line_rec.service_line_index := rosetta_g_miss_num_map(p0_a203);
    ddp_line_rec.line_set_id := rosetta_g_miss_num_map(p0_a204);
    ddp_line_rec.split_by := p0_a205;
    ddp_line_rec.split_action_code := p0_a206;
    ddp_line_rec.shippable_flag := p0_a207;
    ddp_line_rec.model_remnant_flag := p0_a208;
    ddp_line_rec.flow_status_code := p0_a209;
    ddp_line_rec.fulfilled_flag := p0_a210;
    ddp_line_rec.fulfillment_method_code := p0_a211;
    ddp_line_rec.revenue_amount := rosetta_g_miss_num_map(p0_a212);
    ddp_line_rec.marketing_source_code_id := rosetta_g_miss_num_map(p0_a213);
    ddp_line_rec.fulfillment_date := rosetta_g_miss_date_in_map(p0_a214);
    if p0_a215 is null
      then ddp_line_rec.semi_processed_flag := null;
    elsif p0_a215 = 0
      then ddp_line_rec.semi_processed_flag := false;
    else ddp_line_rec.semi_processed_flag := true;
    end if;
    ddp_line_rec.upgraded_flag := p0_a216;
    ddp_line_rec.lock_control := rosetta_g_miss_num_map(p0_a217);
    ddp_line_rec.subinventory := p0_a218;
    ddp_line_rec.split_from_line_ref := p0_a219;
    ddp_line_rec.split_from_shipment_ref := p0_a220;
    ddp_line_rec.ship_to_edi_location_code := p0_a221;
    ddp_line_rec.bill_to_edi_location_code := p0_a222;
    ddp_line_rec.ship_from_edi_location_code := p0_a223;
    ddp_line_rec.ship_from_address_id := rosetta_g_miss_num_map(p0_a224);
    ddp_line_rec.sold_to_address_id := rosetta_g_miss_num_map(p0_a225);
    ddp_line_rec.ship_to_address_id := rosetta_g_miss_num_map(p0_a226);
    ddp_line_rec.invoice_address_id := rosetta_g_miss_num_map(p0_a227);
    ddp_line_rec.ship_to_address_code := p0_a228;
    ddp_line_rec.original_inventory_item_id := rosetta_g_miss_num_map(p0_a229);
    ddp_line_rec.original_item_identifier_type := p0_a230;
    ddp_line_rec.original_ordered_item_id := rosetta_g_miss_num_map(p0_a231);
    ddp_line_rec.original_ordered_item := p0_a232;
    ddp_line_rec.item_substitution_type_code := p0_a233;
    ddp_line_rec.late_demand_penalty_factor := rosetta_g_miss_num_map(p0_a234);
    ddp_line_rec.override_atp_date_code := p0_a235;
    ddp_line_rec.ship_to_customer_id := rosetta_g_miss_num_map(p0_a236);
    ddp_line_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p0_a237);
    ddp_line_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p0_a238);
    ddp_line_rec.accounting_rule_duration := rosetta_g_miss_num_map(p0_a239);
    ddp_line_rec.unit_cost := rosetta_g_miss_num_map(p0_a240);
    ddp_line_rec.user_item_description := p0_a241;
    ddp_line_rec.xml_transaction_type_code := p0_a242;
    ddp_line_rec.item_relationship_type := rosetta_g_miss_num_map(p0_a243);
    ddp_line_rec.blanket_number := rosetta_g_miss_num_map(p0_a244);
    ddp_line_rec.blanket_line_number := rosetta_g_miss_num_map(p0_a245);
    ddp_line_rec.blanket_version_number := rosetta_g_miss_num_map(p0_a246);
    ddp_line_rec.cso_response_flag := p0_a247;
    ddp_line_rec.firm_demand_flag := p0_a248;
    ddp_line_rec.earliest_ship_date := rosetta_g_miss_date_in_map(p0_a249);
    ddp_line_rec.transaction_phase_code := p0_a250;
    ddp_line_rec.source_document_version_number := rosetta_g_miss_num_map(p0_a251);
    ddp_line_rec.minisite_id := rosetta_g_miss_num_map(p0_a252);
    ddp_line_rec.ib_owner := p0_a253;
    ddp_line_rec.ib_installed_at_location := p0_a254;
    ddp_line_rec.ib_current_location := p0_a255;
    ddp_line_rec.end_customer_id := rosetta_g_miss_num_map(p0_a256);
    ddp_line_rec.end_customer_contact_id := rosetta_g_miss_num_map(p0_a257);
    ddp_line_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p0_a258);
    ddp_line_rec.supplier_signature := p0_a259;
    ddp_line_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p0_a260);
    ddp_line_rec.customer_signature := p0_a261;
    ddp_line_rec.customer_signature_date := rosetta_g_miss_date_in_map(p0_a262);
    ddp_line_rec.ship_to_party_id := rosetta_g_miss_num_map(p0_a263);
    ddp_line_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p0_a264);
    ddp_line_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p0_a265);
    ddp_line_rec.deliver_to_party_id := rosetta_g_miss_num_map(p0_a266);
    ddp_line_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p0_a267);
    ddp_line_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p0_a268);
    ddp_line_rec.invoice_to_party_id := rosetta_g_miss_num_map(p0_a269);
    ddp_line_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p0_a270);
    ddp_line_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p0_a271);
    ddp_line_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p0_a272);
    ddp_line_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p0_a273);
    ddp_line_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p0_a274);
    ddp_line_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p0_a275);
    ddp_line_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p0_a276);
    ddp_line_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p0_a277);
    ddp_line_rec.retrobill_request_id := rosetta_g_miss_num_map(p0_a278);
    ddp_line_rec.original_list_price := rosetta_g_miss_num_map(p0_a279);
    ddp_line_rec.commitment_applied_amount := rosetta_g_miss_num_map(p0_a280);





    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_line_ext.populate_transient_attributes(ddp_line_rec,
      ddx_line_val_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_line_val_rec.accounting_rule;
    p1_a1 := ddx_line_val_rec.agreement;
    p1_a2 := ddx_line_val_rec.commitment;
    p1_a3 := rosetta_g_miss_num_map(ddx_line_val_rec.commitment_applied_amount);
    p1_a4 := ddx_line_val_rec.deliver_to_address1;
    p1_a5 := ddx_line_val_rec.deliver_to_address2;
    p1_a6 := ddx_line_val_rec.deliver_to_address3;
    p1_a7 := ddx_line_val_rec.deliver_to_address4;
    p1_a8 := ddx_line_val_rec.deliver_to_contact;
    p1_a9 := ddx_line_val_rec.deliver_to_location;
    p1_a10 := ddx_line_val_rec.deliver_to_org;
    p1_a11 := ddx_line_val_rec.deliver_to_state;
    p1_a12 := ddx_line_val_rec.deliver_to_city;
    p1_a13 := ddx_line_val_rec.deliver_to_zip;
    p1_a14 := ddx_line_val_rec.deliver_to_country;
    p1_a15 := ddx_line_val_rec.deliver_to_county;
    p1_a16 := ddx_line_val_rec.deliver_to_province;
    p1_a17 := ddx_line_val_rec.demand_class;
    p1_a18 := ddx_line_val_rec.demand_bucket_type;
    p1_a19 := ddx_line_val_rec.fob_point;
    p1_a20 := ddx_line_val_rec.freight_terms;
    p1_a21 := ddx_line_val_rec.inventory_item;
    p1_a22 := ddx_line_val_rec.invoice_to_address1;
    p1_a23 := ddx_line_val_rec.invoice_to_address2;
    p1_a24 := ddx_line_val_rec.invoice_to_address3;
    p1_a25 := ddx_line_val_rec.invoice_to_address4;
    p1_a26 := ddx_line_val_rec.invoice_to_contact;
    p1_a27 := ddx_line_val_rec.invoice_to_location;
    p1_a28 := ddx_line_val_rec.invoice_to_org;
    p1_a29 := ddx_line_val_rec.invoice_to_state;
    p1_a30 := ddx_line_val_rec.invoice_to_city;
    p1_a31 := ddx_line_val_rec.invoice_to_zip;
    p1_a32 := ddx_line_val_rec.invoice_to_country;
    p1_a33 := ddx_line_val_rec.invoice_to_county;
    p1_a34 := ddx_line_val_rec.invoice_to_province;
    p1_a35 := ddx_line_val_rec.invoicing_rule;
    p1_a36 := ddx_line_val_rec.item_type;
    p1_a37 := ddx_line_val_rec.line_type;
    p1_a38 := ddx_line_val_rec.over_ship_reason;
    p1_a39 := ddx_line_val_rec.payment_term;
    p1_a40 := ddx_line_val_rec.price_list;
    p1_a41 := ddx_line_val_rec.project;
    p1_a42 := ddx_line_val_rec.return_reason;
    p1_a43 := ddx_line_val_rec.rla_schedule_type;
    p1_a44 := ddx_line_val_rec.salesrep;
    p1_a45 := ddx_line_val_rec.shipment_priority;
    p1_a46 := ddx_line_val_rec.ship_from_address1;
    p1_a47 := ddx_line_val_rec.ship_from_address2;
    p1_a48 := ddx_line_val_rec.ship_from_address3;
    p1_a49 := ddx_line_val_rec.ship_from_address4;
    p1_a50 := ddx_line_val_rec.ship_from_location;
    p1_a51 := ddx_line_val_rec.ship_from_city;
    p1_a52 := ddx_line_val_rec.ship_from_postal_code;
    p1_a53 := ddx_line_val_rec.ship_from_country;
    p1_a54 := ddx_line_val_rec.ship_from_region1;
    p1_a55 := ddx_line_val_rec.ship_from_region2;
    p1_a56 := ddx_line_val_rec.ship_from_region3;
    p1_a57 := ddx_line_val_rec.ship_from_org;
    p1_a58 := ddx_line_val_rec.ship_to_address1;
    p1_a59 := ddx_line_val_rec.ship_to_address2;
    p1_a60 := ddx_line_val_rec.ship_to_address3;
    p1_a61 := ddx_line_val_rec.ship_to_address4;
    p1_a62 := ddx_line_val_rec.ship_to_state;
    p1_a63 := ddx_line_val_rec.ship_to_country;
    p1_a64 := ddx_line_val_rec.ship_to_zip;
    p1_a65 := ddx_line_val_rec.ship_to_county;
    p1_a66 := ddx_line_val_rec.ship_to_province;
    p1_a67 := ddx_line_val_rec.ship_to_city;
    p1_a68 := ddx_line_val_rec.ship_to_contact;
    p1_a69 := ddx_line_val_rec.ship_to_contact_last_name;
    p1_a70 := ddx_line_val_rec.ship_to_contact_first_name;
    p1_a71 := ddx_line_val_rec.ship_to_location;
    p1_a72 := ddx_line_val_rec.ship_to_org;
    p1_a73 := ddx_line_val_rec.source_type;
    p1_a74 := ddx_line_val_rec.intermed_ship_to_address1;
    p1_a75 := ddx_line_val_rec.intermed_ship_to_address2;
    p1_a76 := ddx_line_val_rec.intermed_ship_to_address3;
    p1_a77 := ddx_line_val_rec.intermed_ship_to_address4;
    p1_a78 := ddx_line_val_rec.intermed_ship_to_contact;
    p1_a79 := ddx_line_val_rec.intermed_ship_to_location;
    p1_a80 := ddx_line_val_rec.intermed_ship_to_org;
    p1_a81 := ddx_line_val_rec.intermed_ship_to_state;
    p1_a82 := ddx_line_val_rec.intermed_ship_to_city;
    p1_a83 := ddx_line_val_rec.intermed_ship_to_zip;
    p1_a84 := ddx_line_val_rec.intermed_ship_to_country;
    p1_a85 := ddx_line_val_rec.intermed_ship_to_county;
    p1_a86 := ddx_line_val_rec.intermed_ship_to_province;
    p1_a87 := ddx_line_val_rec.sold_to_org;
    p1_a88 := ddx_line_val_rec.sold_from_org;
    p1_a89 := ddx_line_val_rec.task;
    p1_a90 := ddx_line_val_rec.tax_exempt;
    p1_a91 := ddx_line_val_rec.tax_exempt_reason;
    p1_a92 := ddx_line_val_rec.tax_point;
    p1_a93 := ddx_line_val_rec.veh_cus_item_cum_key;
    p1_a94 := ddx_line_val_rec.visible_demand;
    p1_a95 := ddx_line_val_rec.customer_payment_term;
    p1_a96 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_order_number);
    p1_a97 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_line_number);
    p1_a98 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_shipment_number);
    p1_a99 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_option_number);
    p1_a100 := ddx_line_val_rec.ref_invoice_number;
    p1_a101 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_invoice_line_number);
    p1_a102 := ddx_line_val_rec.credit_invoice_number;
    p1_a103 := ddx_line_val_rec.tax_group;
    p1_a104 := ddx_line_val_rec.status;
    p1_a105 := ddx_line_val_rec.freight_carrier;
    p1_a106 := ddx_line_val_rec.shipping_method;
    p1_a107 := ddx_line_val_rec.calculate_price_descr;
    p1_a108 := ddx_line_val_rec.ship_to_customer_name;
    p1_a109 := ddx_line_val_rec.invoice_to_customer_name;
    p1_a110 := ddx_line_val_rec.ship_to_customer_number;
    p1_a111 := ddx_line_val_rec.invoice_to_customer_number;
    p1_a112 := rosetta_g_miss_num_map(ddx_line_val_rec.ship_to_customer_id);
    p1_a113 := rosetta_g_miss_num_map(ddx_line_val_rec.invoice_to_customer_id);
    p1_a114 := rosetta_g_miss_num_map(ddx_line_val_rec.deliver_to_customer_id);
    p1_a115 := ddx_line_val_rec.deliver_to_customer_number;
    p1_a116 := ddx_line_val_rec.deliver_to_customer_name;
    p1_a117 := ddx_line_val_rec.original_ordered_item;
    p1_a118 := ddx_line_val_rec.original_inventory_item;
    p1_a119 := ddx_line_val_rec.original_item_identifier_type;
    p1_a120 := ddx_line_val_rec.deliver_to_customer_number_oi;
    p1_a121 := ddx_line_val_rec.deliver_to_customer_name_oi;
    p1_a122 := ddx_line_val_rec.ship_to_customer_number_oi;
    p1_a123 := ddx_line_val_rec.ship_to_customer_name_oi;
    p1_a124 := ddx_line_val_rec.invoice_to_customer_number_oi;
    p1_a125 := ddx_line_val_rec.invoice_to_customer_name_oi;
    p1_a126 := ddx_line_val_rec.item_relationship_type_dsp;
    p1_a127 := ddx_line_val_rec.transaction_phase;
    p1_a128 := ddx_line_val_rec.end_customer_name;
    p1_a129 := ddx_line_val_rec.end_customer_number;
    p1_a130 := ddx_line_val_rec.end_customer_contact;
    p1_a131 := ddx_line_val_rec.end_cust_contact_last_name;
    p1_a132 := ddx_line_val_rec.end_cust_contact_first_name;
    p1_a133 := ddx_line_val_rec.end_customer_site_address1;
    p1_a134 := ddx_line_val_rec.end_customer_site_address2;
    p1_a135 := ddx_line_val_rec.end_customer_site_address3;
    p1_a136 := ddx_line_val_rec.end_customer_site_address4;
    p1_a137 := ddx_line_val_rec.end_customer_site_location;
    p1_a138 := ddx_line_val_rec.end_customer_site_state;
    p1_a139 := ddx_line_val_rec.end_customer_site_country;
    p1_a140 := ddx_line_val_rec.end_customer_site_zip;
    p1_a141 := ddx_line_val_rec.end_customer_site_county;
    p1_a142 := ddx_line_val_rec.end_customer_site_province;
    p1_a143 := ddx_line_val_rec.end_customer_site_city;
    p1_a144 := ddx_line_val_rec.end_customer_site_postal_code;
    p1_a145 := ddx_line_val_rec.blanket_agreement_name;
    p1_a146 := rosetta_g_miss_num_map(ddx_line_val_rec.extended_price);
    p1_a147 := rosetta_g_miss_num_map(ddx_line_val_rec.unit_selling_price);
    p1_a148 := rosetta_g_miss_num_map(ddx_line_val_rec.unit_list_price);
    p1_a149 := ddx_line_val_rec.line_number;
    p1_a150 := ddx_line_val_rec.item_description;



  end;

end oe_oe_html_line_ext_w;

/
