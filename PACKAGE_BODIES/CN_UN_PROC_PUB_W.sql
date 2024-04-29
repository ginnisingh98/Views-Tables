--------------------------------------------------------
--  DDL for Package Body CN_UN_PROC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UN_PROC_PUB_W" as
  /* $Header: cnwnprob.pls 115.6 2002/11/26 01:35:49 mblum ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_un_proc_pub.adj_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
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
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).invoice_number := a0(indx);
          t(ddindx).invoice_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).order_number := a2(indx);
          t(ddindx).order_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).processed_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).trx_type_disp := a6(indx);
          t(ddindx).adjust_status_disp := a7(indx);
          t(ddindx).adjusted_by := a8(indx);
          t(ddindx).load_status := a9(indx);
          t(ddindx).calc_status_disp := a10(indx);
          t(ddindx).sales_credit := a11(indx);
          t(ddindx).commission := a12(indx);
          t(ddindx).adjust_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute2 := a15(indx);
          t(ddindx).attribute3 := a16(indx);
          t(ddindx).attribute4 := a17(indx);
          t(ddindx).attribute5 := a18(indx);
          t(ddindx).attribute6 := a19(indx);
          t(ddindx).attribute7 := a20(indx);
          t(ddindx).attribute8 := a21(indx);
          t(ddindx).attribute9 := a22(indx);
          t(ddindx).attribute10 := a23(indx);
          t(ddindx).attribute11 := a24(indx);
          t(ddindx).attribute12 := a25(indx);
          t(ddindx).attribute13 := a26(indx);
          t(ddindx).attribute14 := a27(indx);
          t(ddindx).attribute15 := a28(indx);
          t(ddindx).attribute16 := a29(indx);
          t(ddindx).attribute17 := a30(indx);
          t(ddindx).attribute18 := a31(indx);
          t(ddindx).attribute19 := a32(indx);
          t(ddindx).attribute20 := a33(indx);
          t(ddindx).attribute21 := a34(indx);
          t(ddindx).attribute22 := a35(indx);
          t(ddindx).attribute23 := a36(indx);
          t(ddindx).attribute24 := a37(indx);
          t(ddindx).attribute25 := a38(indx);
          t(ddindx).attribute26 := a39(indx);
          t(ddindx).attribute27 := a40(indx);
          t(ddindx).attribute28 := a41(indx);
          t(ddindx).attribute29 := a42(indx);
          t(ddindx).attribute30 := a43(indx);
          t(ddindx).attribute31 := a44(indx);
          t(ddindx).attribute32 := a45(indx);
          t(ddindx).attribute33 := a46(indx);
          t(ddindx).attribute34 := a47(indx);
          t(ddindx).attribute35 := a48(indx);
          t(ddindx).attribute36 := a49(indx);
          t(ddindx).attribute37 := a50(indx);
          t(ddindx).attribute38 := a51(indx);
          t(ddindx).attribute39 := a52(indx);
          t(ddindx).attribute40 := a53(indx);
          t(ddindx).attribute41 := a54(indx);
          t(ddindx).attribute42 := a55(indx);
          t(ddindx).attribute43 := a56(indx);
          t(ddindx).attribute44 := a57(indx);
          t(ddindx).attribute45 := a58(indx);
          t(ddindx).attribute46 := a59(indx);
          t(ddindx).attribute47 := a60(indx);
          t(ddindx).attribute48 := a61(indx);
          t(ddindx).attribute49 := a62(indx);
          t(ddindx).attribute50 := a63(indx);
          t(ddindx).attribute51 := a64(indx);
          t(ddindx).attribute52 := a65(indx);
          t(ddindx).attribute53 := a66(indx);
          t(ddindx).attribute54 := a67(indx);
          t(ddindx).attribute55 := a68(indx);
          t(ddindx).attribute56 := a69(indx);
          t(ddindx).attribute57 := a70(indx);
          t(ddindx).attribute58 := a71(indx);
          t(ddindx).attribute59 := a72(indx);
          t(ddindx).attribute60 := a73(indx);
          t(ddindx).attribute61 := a74(indx);
          t(ddindx).attribute62 := a75(indx);
          t(ddindx).attribute63 := a76(indx);
          t(ddindx).attribute64 := a77(indx);
          t(ddindx).attribute65 := a78(indx);
          t(ddindx).attribute66 := a79(indx);
          t(ddindx).attribute67 := a80(indx);
          t(ddindx).attribute68 := a81(indx);
          t(ddindx).attribute69 := a82(indx);
          t(ddindx).attribute70 := a83(indx);
          t(ddindx).attribute71 := a84(indx);
          t(ddindx).attribute72 := a85(indx);
          t(ddindx).attribute73 := a86(indx);
          t(ddindx).attribute74 := a87(indx);
          t(ddindx).attribute75 := a88(indx);
          t(ddindx).attribute76 := a89(indx);
          t(ddindx).attribute77 := a90(indx);
          t(ddindx).attribute78 := a91(indx);
          t(ddindx).attribute79 := a92(indx);
          t(ddindx).attribute80 := a93(indx);
          t(ddindx).attribute81 := a94(indx);
          t(ddindx).attribute82 := a95(indx);
          t(ddindx).attribute83 := a96(indx);
          t(ddindx).attribute84 := a97(indx);
          t(ddindx).attribute85 := a98(indx);
          t(ddindx).attribute86 := a99(indx);
          t(ddindx).attribute87 := a100(indx);
          t(ddindx).attribute88 := a101(indx);
          t(ddindx).attribute89 := a102(indx);
          t(ddindx).attribute90 := a103(indx);
          t(ddindx).attribute91 := a104(indx);
          t(ddindx).attribute92 := a105(indx);
          t(ddindx).attribute93 := a106(indx);
          t(ddindx).attribute94 := a107(indx);
          t(ddindx).attribute95 := a108(indx);
          t(ddindx).attribute96 := a109(indx);
          t(ddindx).attribute97 := a110(indx);
          t(ddindx).attribute98 := a111(indx);
          t(ddindx).attribute99 := a112(indx);
          t(ddindx).attribute100 := a113(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_un_proc_pub.adj_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_VARCHAR2_TABLE_300
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_300
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_300
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_VARCHAR2_TABLE_300
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_300
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_300
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_300
    , a104 out nocopy JTF_VARCHAR2_TABLE_300
    , a105 out nocopy JTF_VARCHAR2_TABLE_300
    , a106 out nocopy JTF_VARCHAR2_TABLE_300
    , a107 out nocopy JTF_VARCHAR2_TABLE_300
    , a108 out nocopy JTF_VARCHAR2_TABLE_300
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_VARCHAR2_TABLE_300
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
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
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_300();
    a106 := JTF_VARCHAR2_TABLE_300();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_300();
    a109 := JTF_VARCHAR2_TABLE_300();
    a110 := JTF_VARCHAR2_TABLE_300();
    a111 := JTF_VARCHAR2_TABLE_300();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
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
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_300();
      a106 := JTF_VARCHAR2_TABLE_300();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_300();
      a109 := JTF_VARCHAR2_TABLE_300();
      a110 := JTF_VARCHAR2_TABLE_300();
      a111 := JTF_VARCHAR2_TABLE_300();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).invoice_number;
          a1(indx) := t(ddindx).invoice_date;
          a2(indx) := t(ddindx).order_number;
          a3(indx) := t(ddindx).order_date;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).processed_date;
          a6(indx) := t(ddindx).trx_type_disp;
          a7(indx) := t(ddindx).adjust_status_disp;
          a8(indx) := t(ddindx).adjusted_by;
          a9(indx) := t(ddindx).load_status;
          a10(indx) := t(ddindx).calc_status_disp;
          a11(indx) := t(ddindx).sales_credit;
          a12(indx) := t(ddindx).commission;
          a13(indx) := t(ddindx).adjust_date;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute2;
          a16(indx) := t(ddindx).attribute3;
          a17(indx) := t(ddindx).attribute4;
          a18(indx) := t(ddindx).attribute5;
          a19(indx) := t(ddindx).attribute6;
          a20(indx) := t(ddindx).attribute7;
          a21(indx) := t(ddindx).attribute8;
          a22(indx) := t(ddindx).attribute9;
          a23(indx) := t(ddindx).attribute10;
          a24(indx) := t(ddindx).attribute11;
          a25(indx) := t(ddindx).attribute12;
          a26(indx) := t(ddindx).attribute13;
          a27(indx) := t(ddindx).attribute14;
          a28(indx) := t(ddindx).attribute15;
          a29(indx) := t(ddindx).attribute16;
          a30(indx) := t(ddindx).attribute17;
          a31(indx) := t(ddindx).attribute18;
          a32(indx) := t(ddindx).attribute19;
          a33(indx) := t(ddindx).attribute20;
          a34(indx) := t(ddindx).attribute21;
          a35(indx) := t(ddindx).attribute22;
          a36(indx) := t(ddindx).attribute23;
          a37(indx) := t(ddindx).attribute24;
          a38(indx) := t(ddindx).attribute25;
          a39(indx) := t(ddindx).attribute26;
          a40(indx) := t(ddindx).attribute27;
          a41(indx) := t(ddindx).attribute28;
          a42(indx) := t(ddindx).attribute29;
          a43(indx) := t(ddindx).attribute30;
          a44(indx) := t(ddindx).attribute31;
          a45(indx) := t(ddindx).attribute32;
          a46(indx) := t(ddindx).attribute33;
          a47(indx) := t(ddindx).attribute34;
          a48(indx) := t(ddindx).attribute35;
          a49(indx) := t(ddindx).attribute36;
          a50(indx) := t(ddindx).attribute37;
          a51(indx) := t(ddindx).attribute38;
          a52(indx) := t(ddindx).attribute39;
          a53(indx) := t(ddindx).attribute40;
          a54(indx) := t(ddindx).attribute41;
          a55(indx) := t(ddindx).attribute42;
          a56(indx) := t(ddindx).attribute43;
          a57(indx) := t(ddindx).attribute44;
          a58(indx) := t(ddindx).attribute45;
          a59(indx) := t(ddindx).attribute46;
          a60(indx) := t(ddindx).attribute47;
          a61(indx) := t(ddindx).attribute48;
          a62(indx) := t(ddindx).attribute49;
          a63(indx) := t(ddindx).attribute50;
          a64(indx) := t(ddindx).attribute51;
          a65(indx) := t(ddindx).attribute52;
          a66(indx) := t(ddindx).attribute53;
          a67(indx) := t(ddindx).attribute54;
          a68(indx) := t(ddindx).attribute55;
          a69(indx) := t(ddindx).attribute56;
          a70(indx) := t(ddindx).attribute57;
          a71(indx) := t(ddindx).attribute58;
          a72(indx) := t(ddindx).attribute59;
          a73(indx) := t(ddindx).attribute60;
          a74(indx) := t(ddindx).attribute61;
          a75(indx) := t(ddindx).attribute62;
          a76(indx) := t(ddindx).attribute63;
          a77(indx) := t(ddindx).attribute64;
          a78(indx) := t(ddindx).attribute65;
          a79(indx) := t(ddindx).attribute66;
          a80(indx) := t(ddindx).attribute67;
          a81(indx) := t(ddindx).attribute68;
          a82(indx) := t(ddindx).attribute69;
          a83(indx) := t(ddindx).attribute70;
          a84(indx) := t(ddindx).attribute71;
          a85(indx) := t(ddindx).attribute72;
          a86(indx) := t(ddindx).attribute73;
          a87(indx) := t(ddindx).attribute74;
          a88(indx) := t(ddindx).attribute75;
          a89(indx) := t(ddindx).attribute76;
          a90(indx) := t(ddindx).attribute77;
          a91(indx) := t(ddindx).attribute78;
          a92(indx) := t(ddindx).attribute79;
          a93(indx) := t(ddindx).attribute80;
          a94(indx) := t(ddindx).attribute81;
          a95(indx) := t(ddindx).attribute82;
          a96(indx) := t(ddindx).attribute83;
          a97(indx) := t(ddindx).attribute84;
          a98(indx) := t(ddindx).attribute85;
          a99(indx) := t(ddindx).attribute86;
          a100(indx) := t(ddindx).attribute87;
          a101(indx) := t(ddindx).attribute88;
          a102(indx) := t(ddindx).attribute89;
          a103(indx) := t(ddindx).attribute90;
          a104(indx) := t(ddindx).attribute91;
          a105(indx) := t(ddindx).attribute92;
          a106(indx) := t(ddindx).attribute93;
          a107(indx) := t(ddindx).attribute94;
          a108(indx) := t(ddindx).attribute95;
          a109(indx) := t(ddindx).attribute96;
          a110(indx) := t(ddindx).attribute97;
          a111(indx) := t(ddindx).attribute98;
          a112(indx) := t(ddindx).attribute99;
          a113(indx) := t(ddindx).attribute100;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_adj(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_pr_date_from  date
    , p_pr_date_to  date
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p_adjust_status  VARCHAR2
    , p_adjust_date  date
    , p_trx_type  VARCHAR2
    , p_calc_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_date_pattern  date
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p20_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a1 out nocopy JTF_DATE_TABLE
    , p20_a2 out nocopy JTF_NUMBER_TABLE
    , p20_a3 out nocopy JTF_DATE_TABLE
    , p20_a4 out nocopy JTF_DATE_TABLE
    , p20_a5 out nocopy JTF_DATE_TABLE
    , p20_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a11 out nocopy JTF_NUMBER_TABLE
    , p20_a12 out nocopy JTF_NUMBER_TABLE
    , p20_a13 out nocopy JTF_DATE_TABLE
    , p20_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , x_adj_count out nocopy  NUMBER
    , x_total_sales_credit out nocopy  NUMBER
    , x_total_commission out nocopy  NUMBER
  )

  as
    ddp_pr_date_from date;
    ddp_pr_date_to date;
    ddp_adjust_date date;
    ddp_date_pattern date;
    ddx_adj_tbl cn_un_proc_pub.adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_pr_date_from := rosetta_g_miss_date_in_map(p_pr_date_from);

    ddp_pr_date_to := rosetta_g_miss_date_in_map(p_pr_date_to);




    ddp_adjust_date := rosetta_g_miss_date_in_map(p_adjust_date);




    ddp_date_pattern := rosetta_g_miss_date_in_map(p_date_pattern);







    -- here's the delegated call to the old PL/SQL routine
    cn_un_proc_pub.get_adj(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      p_salesrep_id,
      ddp_pr_date_from,
      ddp_pr_date_to,
      p_invoice_num,
      p_order_num,
      p_adjust_status,
      ddp_adjust_date,
      p_trx_type,
      p_calc_status,
      p_load_status,
      ddp_date_pattern,
      p_start_record,
      p_increment_count,
      ddx_adj_tbl,
      x_adj_count,
      x_total_sales_credit,
      x_total_commission);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




















    cn_un_proc_pub_w.rosetta_table_copy_out_p1(ddx_adj_tbl, p20_a0
      , p20_a1
      , p20_a2
      , p20_a3
      , p20_a4
      , p20_a5
      , p20_a6
      , p20_a7
      , p20_a8
      , p20_a9
      , p20_a10
      , p20_a11
      , p20_a12
      , p20_a13
      , p20_a14
      , p20_a15
      , p20_a16
      , p20_a17
      , p20_a18
      , p20_a19
      , p20_a20
      , p20_a21
      , p20_a22
      , p20_a23
      , p20_a24
      , p20_a25
      , p20_a26
      , p20_a27
      , p20_a28
      , p20_a29
      , p20_a30
      , p20_a31
      , p20_a32
      , p20_a33
      , p20_a34
      , p20_a35
      , p20_a36
      , p20_a37
      , p20_a38
      , p20_a39
      , p20_a40
      , p20_a41
      , p20_a42
      , p20_a43
      , p20_a44
      , p20_a45
      , p20_a46
      , p20_a47
      , p20_a48
      , p20_a49
      , p20_a50
      , p20_a51
      , p20_a52
      , p20_a53
      , p20_a54
      , p20_a55
      , p20_a56
      , p20_a57
      , p20_a58
      , p20_a59
      , p20_a60
      , p20_a61
      , p20_a62
      , p20_a63
      , p20_a64
      , p20_a65
      , p20_a66
      , p20_a67
      , p20_a68
      , p20_a69
      , p20_a70
      , p20_a71
      , p20_a72
      , p20_a73
      , p20_a74
      , p20_a75
      , p20_a76
      , p20_a77
      , p20_a78
      , p20_a79
      , p20_a80
      , p20_a81
      , p20_a82
      , p20_a83
      , p20_a84
      , p20_a85
      , p20_a86
      , p20_a87
      , p20_a88
      , p20_a89
      , p20_a90
      , p20_a91
      , p20_a92
      , p20_a93
      , p20_a94
      , p20_a95
      , p20_a96
      , p20_a97
      , p20_a98
      , p20_a99
      , p20_a100
      , p20_a101
      , p20_a102
      , p20_a103
      , p20_a104
      , p20_a105
      , p20_a106
      , p20_a107
      , p20_a108
      , p20_a109
      , p20_a110
      , p20_a111
      , p20_a112
      , p20_a113
      );



  end;

end cn_un_proc_pub_w;

/
