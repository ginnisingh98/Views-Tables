--------------------------------------------------------
--  DDL for Package Body JTF_REGION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_REGION_PUB_W" as
  /* $Header: jtfregwb.pls 120.2 2005/10/25 05:25:07 psanyal ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_result_table, a0 JTF_VARCHAR2_TABLE_300
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).value1 := a0(indx);
          t(ddindx).value2 := a1(indx);
          t(ddindx).value3 := a2(indx);
          t(ddindx).value4 := a3(indx);
          t(ddindx).value5 := a4(indx);
          t(ddindx).value6 := a5(indx);
          t(ddindx).value7 := a6(indx);
          t(ddindx).value8 := a7(indx);
          t(ddindx).value9 := a8(indx);
          t(ddindx).value10 := a9(indx);
          t(ddindx).value11 := a10(indx);
          t(ddindx).value12 := a11(indx);
          t(ddindx).value13 := a12(indx);
          t(ddindx).value14 := a13(indx);
          t(ddindx).value15 := a14(indx);
          t(ddindx).value16 := a15(indx);
          t(ddindx).value17 := a16(indx);
          t(ddindx).value18 := a17(indx);
          t(ddindx).value19 := a18(indx);
          t(ddindx).value20 := a19(indx);
          t(ddindx).value21 := a20(indx);
          t(ddindx).value22 := a21(indx);
          t(ddindx).value23 := a22(indx);
          t(ddindx).value24 := a23(indx);
          t(ddindx).value25 := a24(indx);
          t(ddindx).value26 := a25(indx);
          t(ddindx).value27 := a26(indx);
          t(ddindx).value28 := a27(indx);
          t(ddindx).value29 := a28(indx);
          t(ddindx).value30 := a29(indx);
          t(ddindx).value31 := a30(indx);
          t(ddindx).value32 := a31(indx);
          t(ddindx).value33 := a32(indx);
          t(ddindx).value34 := a33(indx);
          t(ddindx).value35 := a34(indx);
          t(ddindx).value36 := a35(indx);
          t(ddindx).value37 := a36(indx);
          t(ddindx).value38 := a37(indx);
          t(ddindx).value39 := a38(indx);
          t(ddindx).value40 := a39(indx);
          t(ddindx).value41 := a40(indx);
          t(ddindx).value42 := a41(indx);
          t(ddindx).value43 := a42(indx);
          t(ddindx).value44 := a43(indx);
          t(ddindx).value45 := a44(indx);
          t(ddindx).value46 := a45(indx);
          t(ddindx).value47 := a46(indx);
          t(ddindx).value48 := a47(indx);
          t(ddindx).value49 := a48(indx);
          t(ddindx).value50 := a49(indx);
          t(ddindx).value51 := a50(indx);
          t(ddindx).value52 := a51(indx);
          t(ddindx).value53 := a52(indx);
          t(ddindx).value54 := a53(indx);
          t(ddindx).value55 := a54(indx);
          t(ddindx).value56 := a55(indx);
          t(ddindx).value57 := a56(indx);
          t(ddindx).value58 := a57(indx);
          t(ddindx).value59 := a58(indx);
          t(ddindx).value60 := a59(indx);
          t(ddindx).value61 := a60(indx);
          t(ddindx).value62 := a61(indx);
          t(ddindx).value63 := a62(indx);
          t(ddindx).value64 := a63(indx);
          t(ddindx).value65 := a64(indx);
          t(ddindx).value66 := a65(indx);
          t(ddindx).value67 := a66(indx);
          t(ddindx).value68 := a67(indx);
          t(ddindx).value69 := a68(indx);
          t(ddindx).value70 := a69(indx);
          t(ddindx).value71 := a70(indx);
          t(ddindx).value72 := a71(indx);
          t(ddindx).value73 := a72(indx);
          t(ddindx).value74 := a73(indx);
          t(ddindx).value75 := a74(indx);
          t(ddindx).value76 := a75(indx);
          t(ddindx).value77 := a76(indx);
          t(ddindx).value78 := a77(indx);
          t(ddindx).value79 := a78(indx);
          t(ddindx).value80 := a79(indx);
          t(ddindx).value81 := a80(indx);
          t(ddindx).value82 := a81(indx);
          t(ddindx).value83 := a82(indx);
          t(ddindx).value84 := a83(indx);
          t(ddindx).value85 := a84(indx);
          t(ddindx).value86 := a85(indx);
          t(ddindx).value87 := a86(indx);
          t(ddindx).value88 := a87(indx);
          t(ddindx).value89 := a88(indx);
          t(ddindx).value90 := a89(indx);
          t(ddindx).value91 := a90(indx);
          t(ddindx).value92 := a91(indx);
          t(ddindx).value93 := a92(indx);
          t(ddindx).value94 := a93(indx);
          t(ddindx).value95 := a94(indx);
          t(ddindx).value96 := a95(indx);
          t(ddindx).value97 := a96(indx);
          t(ddindx).value98 := a97(indx);
          t(ddindx).value99 := a98(indx);
          t(ddindx).value100 := a99(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jtf_region_pub.ak_result_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).value1;
          a1(indx) := t(ddindx).value2;
          a2(indx) := t(ddindx).value3;
          a3(indx) := t(ddindx).value4;
          a4(indx) := t(ddindx).value5;
          a5(indx) := t(ddindx).value6;
          a6(indx) := t(ddindx).value7;
          a7(indx) := t(ddindx).value8;
          a8(indx) := t(ddindx).value9;
          a9(indx) := t(ddindx).value10;
          a10(indx) := t(ddindx).value11;
          a11(indx) := t(ddindx).value12;
          a12(indx) := t(ddindx).value13;
          a13(indx) := t(ddindx).value14;
          a14(indx) := t(ddindx).value15;
          a15(indx) := t(ddindx).value16;
          a16(indx) := t(ddindx).value17;
          a17(indx) := t(ddindx).value18;
          a18(indx) := t(ddindx).value19;
          a19(indx) := t(ddindx).value20;
          a20(indx) := t(ddindx).value21;
          a21(indx) := t(ddindx).value22;
          a22(indx) := t(ddindx).value23;
          a23(indx) := t(ddindx).value24;
          a24(indx) := t(ddindx).value25;
          a25(indx) := t(ddindx).value26;
          a26(indx) := t(ddindx).value27;
          a27(indx) := t(ddindx).value28;
          a28(indx) := t(ddindx).value29;
          a29(indx) := t(ddindx).value30;
          a30(indx) := t(ddindx).value31;
          a31(indx) := t(ddindx).value32;
          a32(indx) := t(ddindx).value33;
          a33(indx) := t(ddindx).value34;
          a34(indx) := t(ddindx).value35;
          a35(indx) := t(ddindx).value36;
          a36(indx) := t(ddindx).value37;
          a37(indx) := t(ddindx).value38;
          a38(indx) := t(ddindx).value39;
          a39(indx) := t(ddindx).value40;
          a40(indx) := t(ddindx).value41;
          a41(indx) := t(ddindx).value42;
          a42(indx) := t(ddindx).value43;
          a43(indx) := t(ddindx).value44;
          a44(indx) := t(ddindx).value45;
          a45(indx) := t(ddindx).value46;
          a46(indx) := t(ddindx).value47;
          a47(indx) := t(ddindx).value48;
          a48(indx) := t(ddindx).value49;
          a49(indx) := t(ddindx).value50;
          a50(indx) := t(ddindx).value51;
          a51(indx) := t(ddindx).value52;
          a52(indx) := t(ddindx).value53;
          a53(indx) := t(ddindx).value54;
          a54(indx) := t(ddindx).value55;
          a55(indx) := t(ddindx).value56;
          a56(indx) := t(ddindx).value57;
          a57(indx) := t(ddindx).value58;
          a58(indx) := t(ddindx).value59;
          a59(indx) := t(ddindx).value60;
          a60(indx) := t(ddindx).value61;
          a61(indx) := t(ddindx).value62;
          a62(indx) := t(ddindx).value63;
          a63(indx) := t(ddindx).value64;
          a64(indx) := t(ddindx).value65;
          a65(indx) := t(ddindx).value66;
          a66(indx) := t(ddindx).value67;
          a67(indx) := t(ddindx).value68;
          a68(indx) := t(ddindx).value69;
          a69(indx) := t(ddindx).value70;
          a70(indx) := t(ddindx).value71;
          a71(indx) := t(ddindx).value72;
          a72(indx) := t(ddindx).value73;
          a73(indx) := t(ddindx).value74;
          a74(indx) := t(ddindx).value75;
          a75(indx) := t(ddindx).value76;
          a76(indx) := t(ddindx).value77;
          a77(indx) := t(ddindx).value78;
          a78(indx) := t(ddindx).value79;
          a79(indx) := t(ddindx).value80;
          a80(indx) := t(ddindx).value81;
          a81(indx) := t(ddindx).value82;
          a82(indx) := t(ddindx).value83;
          a83(indx) := t(ddindx).value84;
          a84(indx) := t(ddindx).value85;
          a85(indx) := t(ddindx).value86;
          a86(indx) := t(ddindx).value87;
          a87(indx) := t(ddindx).value88;
          a88(indx) := t(ddindx).value89;
          a89(indx) := t(ddindx).value90;
          a90(indx) := t(ddindx).value91;
          a91(indx) := t(ddindx).value92;
          a92(indx) := t(ddindx).value93;
          a93(indx) := t(ddindx).value94;
          a94(indx) := t(ddindx).value95;
          a95(indx) := t(ddindx).value96;
          a96(indx) := t(ddindx).value97;
          a97(indx) := t(ddindx).value98;
          a98(indx) := t(ddindx).value99;
          a99(indx) := t(ddindx).value100;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_item_rec_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).column_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jtf_region_pub.ak_item_rec_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).value_id);
          a1(indx) := t(ddindx).column_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_bind_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t jtf_region_pub.ak_bind_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_region_items_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_label_long := a0(indx);
          t(ddindx).attribute_label_short := a1(indx);
          t(ddindx).column_name := a2(indx);
          t(ddindx).data_type := a3(indx);
          t(ddindx).attribute_name := a4(indx);
          t(ddindx).attribute_code := a5(indx);
          t(ddindx).attribute_description := a6(indx);
          t(ddindx).display_value_length := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).lov_region_code := a8(indx);
          t(ddindx).node_display_flag := a9(indx);
          t(ddindx).node_query_flag := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_region_pub.ak_region_items_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).attribute_label_long;
          a1(indx) := t(ddindx).attribute_label_short;
          a2(indx) := t(ddindx).column_name;
          a3(indx) := t(ddindx).data_type;
          a4(indx) := t(ddindx).attribute_name;
          a5(indx) := t(ddindx).attribute_code;
          a6(indx) := t(ddindx).attribute_description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).display_value_length);
          a8(indx) := t(ddindx).lov_region_code;
          a9(indx) := t(ddindx).node_display_flag;
          a10(indx) := t(ddindx).node_query_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.short_varchar2_table, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t jtf_region_pub.short_varchar2_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.long_varchar2_table, a0 JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jtf_region_pub.long_varchar2_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
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
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.number_table, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t jtf_region_pub.number_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure get_regions(p_get_region_codes JTF_VARCHAR2_TABLE_100
    , p_get_application_id  NUMBER
    , p_get_responsibility_ids JTF_NUMBER_TABLE
    , p_skip_column_name  number
    , p_lang OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_ret_region_codes OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_resp_ids OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p_ret_object_name OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_region_name OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_region_description OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p10_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_get_region_codes jtf_region_pub.short_varchar2_table;
    ddp_get_responsibility_ids jtf_region_pub.number_table;
    ddp_skip_column_name boolean;
    ddp_ret_region_codes jtf_region_pub.short_varchar2_table;
    ddp_ret_resp_ids jtf_region_pub.number_table;
    ddp_ret_object_name jtf_region_pub.short_varchar2_table;
    ddp_ret_region_name jtf_region_pub.short_varchar2_table;
    ddp_ret_region_description jtf_region_pub.long_varchar2_table;
    ddp_ret_region_items_table jtf_region_pub.ak_region_items_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    jtf_region_pub_w.rosetta_table_copy_in_p8(ddp_get_region_codes, p_get_region_codes);


    jtf_region_pub_w.rosetta_table_copy_in_p10(ddp_get_responsibility_ids, p_get_responsibility_ids);

    if p_skip_column_name is null
      then ddp_skip_column_name := null;
    elsif p_skip_column_name = 0
      then ddp_skip_column_name := false;
    else ddp_skip_column_name := true;
    end if;








    -- here's the delegated call to the old PL/SQL routine
    jtf_region_pub.get_regions(ddp_get_region_codes,
      p_get_application_id,
      ddp_get_responsibility_ids,
      ddp_skip_column_name,
      p_lang,
      ddp_ret_region_codes,
      ddp_ret_resp_ids,
      ddp_ret_object_name,
      ddp_ret_region_name,
      ddp_ret_region_description,
      ddp_ret_region_items_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    jtf_region_pub_w.rosetta_table_copy_out_p8(ddp_ret_region_codes, p_ret_region_codes);

    jtf_region_pub_w.rosetta_table_copy_out_p10(ddp_ret_resp_ids, p_ret_resp_ids);

    jtf_region_pub_w.rosetta_table_copy_out_p8(ddp_ret_object_name, p_ret_object_name);

    jtf_region_pub_w.rosetta_table_copy_out_p8(ddp_ret_region_name, p_ret_region_name);

    jtf_region_pub_w.rosetta_table_copy_out_p9(ddp_ret_region_description, p_ret_region_description);

    jtf_region_pub_w.rosetta_table_copy_out_p7(ddp_ret_region_items_table, p10_a0
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
      );
  end;

  procedure get_region(p_region_code  VARCHAR2
    , p_application_id  NUMBER
    , p_responsibility_id  NUMBER
    , p_object_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_region_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_region_description OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p6_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_region_items_table jtf_region_pub.ak_region_items_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jtf_region_pub.get_region(p_region_code,
      p_application_id,
      p_responsibility_id,
      p_object_name,
      p_region_name,
      p_region_description,
      ddp_region_items_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    jtf_region_pub_w.rosetta_table_copy_out_p7(ddp_region_items_table, p6_a0
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
      );
  end;

  procedure ak_query(p_application_id  NUMBER
    , p_region_code  VARCHAR2
    , p_where_clause  VARCHAR2
    , p_order_by_clause  VARCHAR2
    , p_responsibility_id  NUMBER
    , p_user_id  NUMBER
    , p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_max_rows IN OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a12 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a14 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a15 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a19 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a20 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a21 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a22 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a23 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a24 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a25 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a26 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a27 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a28 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a29 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a30 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a31 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a32 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a33 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a34 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a35 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a36 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a37 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a38 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a39 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a40 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a41 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a42 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a43 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a44 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a45 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a46 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a47 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a48 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a49 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a50 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a51 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a52 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a53 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a54 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a55 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a56 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a57 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a58 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a59 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a60 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a61 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a62 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a63 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a64 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a65 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a66 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a67 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a68 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a69 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a70 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a71 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a72 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a73 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a74 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a75 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a76 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a77 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a78 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a79 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a80 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a81 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a82 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a83 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a84 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a85 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a86 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a87 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a88 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a89 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a90 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a91 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a92 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a93 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a94 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a95 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a96 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a97 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a98 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a99 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_where_binds jtf_region_pub.ak_bind_table;
    ddp_ak_item_rec_table jtf_region_pub.ak_item_rec_table;
    ddp_ak_result_table jtf_region_pub.ak_result_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    jtf_region_pub_w.rosetta_table_copy_in_p6(ddp_where_binds, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    jtf_region_pub.ak_query(p_application_id,
      p_region_code,
      p_where_clause,
      p_order_by_clause,
      p_responsibility_id,
      p_user_id,
      p_range_low,
      p_range_high,
      p_max_rows,
      ddp_where_binds,
      ddp_ak_item_rec_table,
      ddp_ak_result_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    jtf_region_pub_w.rosetta_table_copy_out_p5(ddp_ak_item_rec_table, p10_a0
      , p10_a1
      );

    jtf_region_pub_w.rosetta_table_copy_out_p4(ddp_ak_result_table, p11_a0
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
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      , p11_a48
      , p11_a49
      , p11_a50
      , p11_a51
      , p11_a52
      , p11_a53
      , p11_a54
      , p11_a55
      , p11_a56
      , p11_a57
      , p11_a58
      , p11_a59
      , p11_a60
      , p11_a61
      , p11_a62
      , p11_a63
      , p11_a64
      , p11_a65
      , p11_a66
      , p11_a67
      , p11_a68
      , p11_a69
      , p11_a70
      , p11_a71
      , p11_a72
      , p11_a73
      , p11_a74
      , p11_a75
      , p11_a76
      , p11_a77
      , p11_a78
      , p11_a79
      , p11_a80
      , p11_a81
      , p11_a82
      , p11_a83
      , p11_a84
      , p11_a85
      , p11_a86
      , p11_a87
      , p11_a88
      , p11_a89
      , p11_a90
      , p11_a91
      , p11_a92
      , p11_a93
      , p11_a94
      , p11_a95
      , p11_a96
      , p11_a97
      , p11_a98
      , p11_a99
      );
  end;

end jtf_region_pub_w;

/
