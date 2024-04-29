--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SEARCH_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SEARCH_W" as
  /* $Header: ARHDQJSB.pls 120.5 2005/10/30 04:18:53 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p5(t out nocopy hz_party_search.scorelist, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score1 := a0(indx);
          t(ddindx).score2 := a1(indx);
          t(ddindx).score3 := a2(indx);
          t(ddindx).score4 := a3(indx);
          t(ddindx).score5 := a4(indx);
          t(ddindx).score6 := a5(indx);
          t(ddindx).score7 := a6(indx);
          t(ddindx).score8 := a7(indx);
          t(ddindx).score9 := a8(indx);
          t(ddindx).score10 := a9(indx);
          t(ddindx).score11 := a10(indx);
          t(ddindx).score12 := a11(indx);
          t(ddindx).score13 := a12(indx);
          t(ddindx).score14 := a13(indx);
          t(ddindx).score15 := a14(indx);
          t(ddindx).score16 := a15(indx);
          t(ddindx).score17 := a16(indx);
          t(ddindx).score18 := a17(indx);
          t(ddindx).score19 := a18(indx);
          t(ddindx).score20 := a19(indx);
          t(ddindx).score21 := a20(indx);
          t(ddindx).score22 := a21(indx);
          t(ddindx).score23 := a22(indx);
          t(ddindx).score24 := a23(indx);
          t(ddindx).score25 := a24(indx);
          t(ddindx).score26 := a25(indx);
          t(ddindx).score27 := a26(indx);
          t(ddindx).score28 := a27(indx);
          t(ddindx).score29 := a28(indx);
          t(ddindx).score30 := a29(indx);
          t(ddindx).score31 := a30(indx);
          t(ddindx).score32 := a31(indx);
          t(ddindx).score33 := a32(indx);
          t(ddindx).score34 := a33(indx);
          t(ddindx).score35 := a34(indx);
          t(ddindx).score36 := a35(indx);
          t(ddindx).score37 := a36(indx);
          t(ddindx).score38 := a37(indx);
          t(ddindx).score39 := a38(indx);
          t(ddindx).score40 := a39(indx);
          t(ddindx).score41 := a40(indx);
          t(ddindx).score42 := a41(indx);
          t(ddindx).score43 := a42(indx);
          t(ddindx).score44 := a43(indx);
          t(ddindx).score45 := a44(indx);
          t(ddindx).score46 := a45(indx);
          t(ddindx).score47 := a46(indx);
          t(ddindx).score48 := a47(indx);
          t(ddindx).score49 := a48(indx);
          t(ddindx).score50 := a49(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t hz_party_search.scorelist, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score1;
          a1(indx) := t(ddindx).score2;
          a2(indx) := t(ddindx).score3;
          a3(indx) := t(ddindx).score4;
          a4(indx) := t(ddindx).score5;
          a5(indx) := t(ddindx).score6;
          a6(indx) := t(ddindx).score7;
          a7(indx) := t(ddindx).score8;
          a8(indx) := t(ddindx).score9;
          a9(indx) := t(ddindx).score10;
          a10(indx) := t(ddindx).score11;
          a11(indx) := t(ddindx).score12;
          a12(indx) := t(ddindx).score13;
          a13(indx) := t(ddindx).score14;
          a14(indx) := t(ddindx).score15;
          a15(indx) := t(ddindx).score16;
          a16(indx) := t(ddindx).score17;
          a17(indx) := t(ddindx).score18;
          a18(indx) := t(ddindx).score19;
          a19(indx) := t(ddindx).score20;
          a20(indx) := t(ddindx).score21;
          a21(indx) := t(ddindx).score22;
          a22(indx) := t(ddindx).score23;
          a23(indx) := t(ddindx).score24;
          a24(indx) := t(ddindx).score25;
          a25(indx) := t(ddindx).score26;
          a26(indx) := t(ddindx).score27;
          a27(indx) := t(ddindx).score28;
          a28(indx) := t(ddindx).score29;
          a29(indx) := t(ddindx).score30;
          a30(indx) := t(ddindx).score31;
          a31(indx) := t(ddindx).score32;
          a32(indx) := t(ddindx).score33;
          a33(indx) := t(ddindx).score34;
          a34(indx) := t(ddindx).score35;
          a35(indx) := t(ddindx).score36;
          a36(indx) := t(ddindx).score37;
          a37(indx) := t(ddindx).score38;
          a38(indx) := t(ddindx).score39;
          a39(indx) := t(ddindx).score40;
          a40(indx) := t(ddindx).score41;
          a41(indx) := t(ddindx).score42;
          a42(indx) := t(ddindx).score43;
          a43(indx) := t(ddindx).score44;
          a44(indx) := t(ddindx).score45;
          a45(indx) := t(ddindx).score46;
          a46(indx) := t(ddindx).score47;
          a47(indx) := t(ddindx).score48;
          a48(indx) := t(ddindx).score49;
          a49(indx) := t(ddindx).score50;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy hz_party_search.idlist, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t hz_party_search.idlist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy hz_party_search.txlist, a0 JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t hz_party_search.txlist, a0 out nocopy JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy hz_party_search.party_site_list, a0 JTF_VARCHAR2_TABLE_4000
    , a1 JTF_VARCHAR2_TABLE_4000
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_VARCHAR2_TABLE_4000
    , a6 JTF_VARCHAR2_TABLE_4000
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_4000
    , a9 JTF_VARCHAR2_TABLE_4000
    , a10 JTF_VARCHAR2_TABLE_4000
    , a11 JTF_VARCHAR2_TABLE_4000
    , a12 JTF_VARCHAR2_TABLE_4000
    , a13 JTF_VARCHAR2_TABLE_4000
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_VARCHAR2_TABLE_4000
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_4000
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_4000
    , a20 JTF_VARCHAR2_TABLE_4000
    , a21 JTF_VARCHAR2_TABLE_4000
    , a22 JTF_VARCHAR2_TABLE_4000
    , a23 JTF_VARCHAR2_TABLE_4000
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_VARCHAR2_TABLE_4000
    , a26 JTF_VARCHAR2_TABLE_4000
    , a27 JTF_VARCHAR2_TABLE_4000
    , a28 JTF_VARCHAR2_TABLE_4000
    , a29 JTF_VARCHAR2_TABLE_4000
    , a30 JTF_VARCHAR2_TABLE_4000
    , a31 JTF_VARCHAR2_TABLE_4000
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_600
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).address := a0(indx);
          t(ddindx).addr_source_system_ref := a1(indx);
          t(ddindx).custom_attribute1 := a2(indx);
          t(ddindx).custom_attribute10 := a3(indx);
          t(ddindx).custom_attribute11 := a4(indx);
          t(ddindx).custom_attribute12 := a5(indx);
          t(ddindx).custom_attribute13 := a6(indx);
          t(ddindx).custom_attribute14 := a7(indx);
          t(ddindx).custom_attribute15 := a8(indx);
          t(ddindx).custom_attribute16 := a9(indx);
          t(ddindx).custom_attribute17 := a10(indx);
          t(ddindx).custom_attribute18 := a11(indx);
          t(ddindx).custom_attribute19 := a12(indx);
          t(ddindx).custom_attribute2 := a13(indx);
          t(ddindx).custom_attribute20 := a14(indx);
          t(ddindx).custom_attribute21 := a15(indx);
          t(ddindx).custom_attribute22 := a16(indx);
          t(ddindx).custom_attribute23 := a17(indx);
          t(ddindx).custom_attribute24 := a18(indx);
          t(ddindx).custom_attribute25 := a19(indx);
          t(ddindx).custom_attribute26 := a20(indx);
          t(ddindx).custom_attribute27 := a21(indx);
          t(ddindx).custom_attribute28 := a22(indx);
          t(ddindx).custom_attribute29 := a23(indx);
          t(ddindx).custom_attribute3 := a24(indx);
          t(ddindx).custom_attribute30 := a25(indx);
          t(ddindx).custom_attribute4 := a26(indx);
          t(ddindx).custom_attribute5 := a27(indx);
          t(ddindx).custom_attribute6 := a28(indx);
          t(ddindx).custom_attribute7 := a29(indx);
          t(ddindx).custom_attribute8 := a30(indx);
          t(ddindx).custom_attribute9 := a31(indx);
          t(ddindx).address1 := a32(indx);
          t(ddindx).address2 := a33(indx);
          t(ddindx).address3 := a34(indx);
          t(ddindx).address4 := a35(indx);
          t(ddindx).address_effective_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).address_expiration_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).address_lines_phonetic := a38(indx);
          t(ddindx).city := a39(indx);
          t(ddindx).clli_code := a40(indx);
          t(ddindx).content_source_type := a41(indx);
          t(ddindx).country := a42(indx);
          t(ddindx).county := a43(indx);
          t(ddindx).floor := a44(indx);
          t(ddindx).house_number := a45(indx);
          t(ddindx).language := a46(indx);
          t(ddindx).position := a47(indx);
          t(ddindx).postal_code := a48(indx);
          t(ddindx).postal_plus4_code := a49(indx);
          t(ddindx).po_box_number := a50(indx);
          t(ddindx).province := a51(indx);
          t(ddindx).sales_tax_geocode := a52(indx);
          t(ddindx).sales_tax_inside_city_limits := a53(indx);
          t(ddindx).state := a54(indx);
          t(ddindx).street := a55(indx);
          t(ddindx).street_number := a56(indx);
          t(ddindx).street_suffix := a57(indx);
          t(ddindx).suite := a58(indx);
          t(ddindx).trailing_directory_code := a59(indx);
          t(ddindx).validated_flag := a60(indx);
          t(ddindx).identifying_address_flag := a61(indx);
          t(ddindx).mailstop := a62(indx);
          t(ddindx).party_site_name := a63(indx);
          t(ddindx).party_site_number := a64(indx);
          t(ddindx).status := a65(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t hz_party_search.party_site_list, a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_600
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
    a1 := JTF_VARCHAR2_TABLE_4000();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_4000();
    a4 := JTF_VARCHAR2_TABLE_4000();
    a5 := JTF_VARCHAR2_TABLE_4000();
    a6 := JTF_VARCHAR2_TABLE_4000();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_4000();
    a9 := JTF_VARCHAR2_TABLE_4000();
    a10 := JTF_VARCHAR2_TABLE_4000();
    a11 := JTF_VARCHAR2_TABLE_4000();
    a12 := JTF_VARCHAR2_TABLE_4000();
    a13 := JTF_VARCHAR2_TABLE_4000();
    a14 := JTF_VARCHAR2_TABLE_4000();
    a15 := JTF_VARCHAR2_TABLE_4000();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_VARCHAR2_TABLE_4000();
    a18 := JTF_VARCHAR2_TABLE_4000();
    a19 := JTF_VARCHAR2_TABLE_4000();
    a20 := JTF_VARCHAR2_TABLE_4000();
    a21 := JTF_VARCHAR2_TABLE_4000();
    a22 := JTF_VARCHAR2_TABLE_4000();
    a23 := JTF_VARCHAR2_TABLE_4000();
    a24 := JTF_VARCHAR2_TABLE_4000();
    a25 := JTF_VARCHAR2_TABLE_4000();
    a26 := JTF_VARCHAR2_TABLE_4000();
    a27 := JTF_VARCHAR2_TABLE_4000();
    a28 := JTF_VARCHAR2_TABLE_4000();
    a29 := JTF_VARCHAR2_TABLE_4000();
    a30 := JTF_VARCHAR2_TABLE_4000();
    a31 := JTF_VARCHAR2_TABLE_4000();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_VARCHAR2_TABLE_600();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
      a1 := JTF_VARCHAR2_TABLE_4000();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_4000();
      a4 := JTF_VARCHAR2_TABLE_4000();
      a5 := JTF_VARCHAR2_TABLE_4000();
      a6 := JTF_VARCHAR2_TABLE_4000();
      a7 := JTF_VARCHAR2_TABLE_4000();
      a8 := JTF_VARCHAR2_TABLE_4000();
      a9 := JTF_VARCHAR2_TABLE_4000();
      a10 := JTF_VARCHAR2_TABLE_4000();
      a11 := JTF_VARCHAR2_TABLE_4000();
      a12 := JTF_VARCHAR2_TABLE_4000();
      a13 := JTF_VARCHAR2_TABLE_4000();
      a14 := JTF_VARCHAR2_TABLE_4000();
      a15 := JTF_VARCHAR2_TABLE_4000();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_VARCHAR2_TABLE_4000();
      a18 := JTF_VARCHAR2_TABLE_4000();
      a19 := JTF_VARCHAR2_TABLE_4000();
      a20 := JTF_VARCHAR2_TABLE_4000();
      a21 := JTF_VARCHAR2_TABLE_4000();
      a22 := JTF_VARCHAR2_TABLE_4000();
      a23 := JTF_VARCHAR2_TABLE_4000();
      a24 := JTF_VARCHAR2_TABLE_4000();
      a25 := JTF_VARCHAR2_TABLE_4000();
      a26 := JTF_VARCHAR2_TABLE_4000();
      a27 := JTF_VARCHAR2_TABLE_4000();
      a28 := JTF_VARCHAR2_TABLE_4000();
      a29 := JTF_VARCHAR2_TABLE_4000();
      a30 := JTF_VARCHAR2_TABLE_4000();
      a31 := JTF_VARCHAR2_TABLE_4000();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_VARCHAR2_TABLE_600();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).address;
          a1(indx) := t(ddindx).addr_source_system_ref;
          a2(indx) := t(ddindx).custom_attribute1;
          a3(indx) := t(ddindx).custom_attribute10;
          a4(indx) := t(ddindx).custom_attribute11;
          a5(indx) := t(ddindx).custom_attribute12;
          a6(indx) := t(ddindx).custom_attribute13;
          a7(indx) := t(ddindx).custom_attribute14;
          a8(indx) := t(ddindx).custom_attribute15;
          a9(indx) := t(ddindx).custom_attribute16;
          a10(indx) := t(ddindx).custom_attribute17;
          a11(indx) := t(ddindx).custom_attribute18;
          a12(indx) := t(ddindx).custom_attribute19;
          a13(indx) := t(ddindx).custom_attribute2;
          a14(indx) := t(ddindx).custom_attribute20;
          a15(indx) := t(ddindx).custom_attribute21;
          a16(indx) := t(ddindx).custom_attribute22;
          a17(indx) := t(ddindx).custom_attribute23;
          a18(indx) := t(ddindx).custom_attribute24;
          a19(indx) := t(ddindx).custom_attribute25;
          a20(indx) := t(ddindx).custom_attribute26;
          a21(indx) := t(ddindx).custom_attribute27;
          a22(indx) := t(ddindx).custom_attribute28;
          a23(indx) := t(ddindx).custom_attribute29;
          a24(indx) := t(ddindx).custom_attribute3;
          a25(indx) := t(ddindx).custom_attribute30;
          a26(indx) := t(ddindx).custom_attribute4;
          a27(indx) := t(ddindx).custom_attribute5;
          a28(indx) := t(ddindx).custom_attribute6;
          a29(indx) := t(ddindx).custom_attribute7;
          a30(indx) := t(ddindx).custom_attribute8;
          a31(indx) := t(ddindx).custom_attribute9;
          a32(indx) := t(ddindx).address1;
          a33(indx) := t(ddindx).address2;
          a34(indx) := t(ddindx).address3;
          a35(indx) := t(ddindx).address4;
          a36(indx) := t(ddindx).address_effective_date;
          a37(indx) := t(ddindx).address_expiration_date;
          a38(indx) := t(ddindx).address_lines_phonetic;
          a39(indx) := t(ddindx).city;
          a40(indx) := t(ddindx).clli_code;
          a41(indx) := t(ddindx).content_source_type;
          a42(indx) := t(ddindx).country;
          a43(indx) := t(ddindx).county;
          a44(indx) := t(ddindx).floor;
          a45(indx) := t(ddindx).house_number;
          a46(indx) := t(ddindx).language;
          a47(indx) := t(ddindx).position;
          a48(indx) := t(ddindx).postal_code;
          a49(indx) := t(ddindx).postal_plus4_code;
          a50(indx) := t(ddindx).po_box_number;
          a51(indx) := t(ddindx).province;
          a52(indx) := t(ddindx).sales_tax_geocode;
          a53(indx) := t(ddindx).sales_tax_inside_city_limits;
          a54(indx) := t(ddindx).state;
          a55(indx) := t(ddindx).street;
          a56(indx) := t(ddindx).street_number;
          a57(indx) := t(ddindx).street_suffix;
          a58(indx) := t(ddindx).suite;
          a59(indx) := t(ddindx).trailing_directory_code;
          a60(indx) := t(ddindx).validated_flag;
          a61(indx) := t(ddindx).identifying_address_flag;
          a62(indx) := t(ddindx).mailstop;
          a63(indx) := t(ddindx).party_site_name;
          a64(indx) := t(ddindx).party_site_number;
          a65(indx) := t(ddindx).status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy hz_party_search.contact_list, a0 JTF_VARCHAR2_TABLE_4000
    , a1 JTF_VARCHAR2_TABLE_4000
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_VARCHAR2_TABLE_4000
    , a6 JTF_VARCHAR2_TABLE_4000
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_4000
    , a9 JTF_VARCHAR2_TABLE_4000
    , a10 JTF_VARCHAR2_TABLE_4000
    , a11 JTF_VARCHAR2_TABLE_4000
    , a12 JTF_VARCHAR2_TABLE_4000
    , a13 JTF_VARCHAR2_TABLE_4000
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_VARCHAR2_TABLE_4000
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_4000
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_4000
    , a20 JTF_VARCHAR2_TABLE_4000
    , a21 JTF_VARCHAR2_TABLE_4000
    , a22 JTF_VARCHAR2_TABLE_4000
    , a23 JTF_VARCHAR2_TABLE_4000
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_VARCHAR2_TABLE_4000
    , a26 JTF_VARCHAR2_TABLE_4000
    , a27 JTF_VARCHAR2_TABLE_4000
    , a28 JTF_VARCHAR2_TABLE_4000
    , a29 JTF_VARCHAR2_TABLE_4000
    , a30 JTF_VARCHAR2_TABLE_4000
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_4000
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_DATE_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_400
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contact_source_system_ref := a0(indx);
          t(ddindx).custom_attribute1 := a1(indx);
          t(ddindx).custom_attribute10 := a2(indx);
          t(ddindx).custom_attribute11 := a3(indx);
          t(ddindx).custom_attribute12 := a4(indx);
          t(ddindx).custom_attribute13 := a5(indx);
          t(ddindx).custom_attribute14 := a6(indx);
          t(ddindx).custom_attribute15 := a7(indx);
          t(ddindx).custom_attribute16 := a8(indx);
          t(ddindx).custom_attribute17 := a9(indx);
          t(ddindx).custom_attribute18 := a10(indx);
          t(ddindx).custom_attribute19 := a11(indx);
          t(ddindx).custom_attribute2 := a12(indx);
          t(ddindx).custom_attribute20 := a13(indx);
          t(ddindx).custom_attribute21 := a14(indx);
          t(ddindx).custom_attribute22 := a15(indx);
          t(ddindx).custom_attribute23 := a16(indx);
          t(ddindx).custom_attribute24 := a17(indx);
          t(ddindx).custom_attribute25 := a18(indx);
          t(ddindx).custom_attribute26 := a19(indx);
          t(ddindx).custom_attribute27 := a20(indx);
          t(ddindx).custom_attribute28 := a21(indx);
          t(ddindx).custom_attribute29 := a22(indx);
          t(ddindx).custom_attribute3 := a23(indx);
          t(ddindx).custom_attribute30 := a24(indx);
          t(ddindx).custom_attribute4 := a25(indx);
          t(ddindx).custom_attribute5 := a26(indx);
          t(ddindx).custom_attribute6 := a27(indx);
          t(ddindx).custom_attribute7 := a28(indx);
          t(ddindx).custom_attribute8 := a29(indx);
          t(ddindx).custom_attribute9 := a30(indx);
          t(ddindx).contact_number := a31(indx);
          t(ddindx).contact_name := a32(indx);
          t(ddindx).decision_maker_flag := a33(indx);
          t(ddindx).job_title := a34(indx);
          t(ddindx).job_title_code := a35(indx);
          t(ddindx).mail_stop := a36(indx);
          t(ddindx).native_language := a37(indx);
          t(ddindx).other_language_1 := a38(indx);
          t(ddindx).other_language_2 := a39(indx);
          t(ddindx).rank := a40(indx);
          t(ddindx).reference_use_flag := a41(indx);
          t(ddindx).title := a42(indx);
          t(ddindx).relationship_type := a43(indx);
          t(ddindx).best_time_contact_begin := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).best_time_contact_end := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).date_of_birth := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).date_of_death := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).jgzz_fiscal_code := a48(indx);
          t(ddindx).known_as := a49(indx);
          t(ddindx).person_academic_title := a50(indx);
          t(ddindx).person_first_name := a51(indx);
          t(ddindx).person_first_name_phonetic := a52(indx);
          t(ddindx).person_identifier := a53(indx);
          t(ddindx).person_iden_type := a54(indx);
          t(ddindx).person_initials := a55(indx);
          t(ddindx).person_last_name := a56(indx);
          t(ddindx).person_last_name_phonetic := a57(indx);
          t(ddindx).person_middle_name := a58(indx);
          t(ddindx).person_name := a59(indx);
          t(ddindx).person_name_phonetic := a60(indx);
          t(ddindx).person_name_suffix := a61(indx);
          t(ddindx).person_previous_last_name := a62(indx);
          t(ddindx).person_title := a63(indx);
          t(ddindx).place_of_birth := a64(indx);
          t(ddindx).tax_name := a65(indx);
          t(ddindx).tax_reference := a66(indx);
          t(ddindx).content_source_type := a67(indx);
          t(ddindx).directional_flag := a68(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t hz_party_search.contact_list, a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_4000
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_400
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
    a1 := JTF_VARCHAR2_TABLE_4000();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_4000();
    a4 := JTF_VARCHAR2_TABLE_4000();
    a5 := JTF_VARCHAR2_TABLE_4000();
    a6 := JTF_VARCHAR2_TABLE_4000();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_4000();
    a9 := JTF_VARCHAR2_TABLE_4000();
    a10 := JTF_VARCHAR2_TABLE_4000();
    a11 := JTF_VARCHAR2_TABLE_4000();
    a12 := JTF_VARCHAR2_TABLE_4000();
    a13 := JTF_VARCHAR2_TABLE_4000();
    a14 := JTF_VARCHAR2_TABLE_4000();
    a15 := JTF_VARCHAR2_TABLE_4000();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_VARCHAR2_TABLE_4000();
    a18 := JTF_VARCHAR2_TABLE_4000();
    a19 := JTF_VARCHAR2_TABLE_4000();
    a20 := JTF_VARCHAR2_TABLE_4000();
    a21 := JTF_VARCHAR2_TABLE_4000();
    a22 := JTF_VARCHAR2_TABLE_4000();
    a23 := JTF_VARCHAR2_TABLE_4000();
    a24 := JTF_VARCHAR2_TABLE_4000();
    a25 := JTF_VARCHAR2_TABLE_4000();
    a26 := JTF_VARCHAR2_TABLE_4000();
    a27 := JTF_VARCHAR2_TABLE_4000();
    a28 := JTF_VARCHAR2_TABLE_4000();
    a29 := JTF_VARCHAR2_TABLE_4000();
    a30 := JTF_VARCHAR2_TABLE_4000();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_4000();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_VARCHAR2_TABLE_400();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
      a1 := JTF_VARCHAR2_TABLE_4000();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_4000();
      a4 := JTF_VARCHAR2_TABLE_4000();
      a5 := JTF_VARCHAR2_TABLE_4000();
      a6 := JTF_VARCHAR2_TABLE_4000();
      a7 := JTF_VARCHAR2_TABLE_4000();
      a8 := JTF_VARCHAR2_TABLE_4000();
      a9 := JTF_VARCHAR2_TABLE_4000();
      a10 := JTF_VARCHAR2_TABLE_4000();
      a11 := JTF_VARCHAR2_TABLE_4000();
      a12 := JTF_VARCHAR2_TABLE_4000();
      a13 := JTF_VARCHAR2_TABLE_4000();
      a14 := JTF_VARCHAR2_TABLE_4000();
      a15 := JTF_VARCHAR2_TABLE_4000();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_VARCHAR2_TABLE_4000();
      a18 := JTF_VARCHAR2_TABLE_4000();
      a19 := JTF_VARCHAR2_TABLE_4000();
      a20 := JTF_VARCHAR2_TABLE_4000();
      a21 := JTF_VARCHAR2_TABLE_4000();
      a22 := JTF_VARCHAR2_TABLE_4000();
      a23 := JTF_VARCHAR2_TABLE_4000();
      a24 := JTF_VARCHAR2_TABLE_4000();
      a25 := JTF_VARCHAR2_TABLE_4000();
      a26 := JTF_VARCHAR2_TABLE_4000();
      a27 := JTF_VARCHAR2_TABLE_4000();
      a28 := JTF_VARCHAR2_TABLE_4000();
      a29 := JTF_VARCHAR2_TABLE_4000();
      a30 := JTF_VARCHAR2_TABLE_4000();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_4000();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_VARCHAR2_TABLE_400();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contact_source_system_ref;
          a1(indx) := t(ddindx).custom_attribute1;
          a2(indx) := t(ddindx).custom_attribute10;
          a3(indx) := t(ddindx).custom_attribute11;
          a4(indx) := t(ddindx).custom_attribute12;
          a5(indx) := t(ddindx).custom_attribute13;
          a6(indx) := t(ddindx).custom_attribute14;
          a7(indx) := t(ddindx).custom_attribute15;
          a8(indx) := t(ddindx).custom_attribute16;
          a9(indx) := t(ddindx).custom_attribute17;
          a10(indx) := t(ddindx).custom_attribute18;
          a11(indx) := t(ddindx).custom_attribute19;
          a12(indx) := t(ddindx).custom_attribute2;
          a13(indx) := t(ddindx).custom_attribute20;
          a14(indx) := t(ddindx).custom_attribute21;
          a15(indx) := t(ddindx).custom_attribute22;
          a16(indx) := t(ddindx).custom_attribute23;
          a17(indx) := t(ddindx).custom_attribute24;
          a18(indx) := t(ddindx).custom_attribute25;
          a19(indx) := t(ddindx).custom_attribute26;
          a20(indx) := t(ddindx).custom_attribute27;
          a21(indx) := t(ddindx).custom_attribute28;
          a22(indx) := t(ddindx).custom_attribute29;
          a23(indx) := t(ddindx).custom_attribute3;
          a24(indx) := t(ddindx).custom_attribute30;
          a25(indx) := t(ddindx).custom_attribute4;
          a26(indx) := t(ddindx).custom_attribute5;
          a27(indx) := t(ddindx).custom_attribute6;
          a28(indx) := t(ddindx).custom_attribute7;
          a29(indx) := t(ddindx).custom_attribute8;
          a30(indx) := t(ddindx).custom_attribute9;
          a31(indx) := t(ddindx).contact_number;
          a32(indx) := t(ddindx).contact_name;
          a33(indx) := t(ddindx).decision_maker_flag;
          a34(indx) := t(ddindx).job_title;
          a35(indx) := t(ddindx).job_title_code;
          a36(indx) := t(ddindx).mail_stop;
          a37(indx) := t(ddindx).native_language;
          a38(indx) := t(ddindx).other_language_1;
          a39(indx) := t(ddindx).other_language_2;
          a40(indx) := t(ddindx).rank;
          a41(indx) := t(ddindx).reference_use_flag;
          a42(indx) := t(ddindx).title;
          a43(indx) := t(ddindx).relationship_type;
          a44(indx) := t(ddindx).best_time_contact_begin;
          a45(indx) := t(ddindx).best_time_contact_end;
          a46(indx) := t(ddindx).date_of_birth;
          a47(indx) := t(ddindx).date_of_death;
          a48(indx) := t(ddindx).jgzz_fiscal_code;
          a49(indx) := t(ddindx).known_as;
          a50(indx) := t(ddindx).person_academic_title;
          a51(indx) := t(ddindx).person_first_name;
          a52(indx) := t(ddindx).person_first_name_phonetic;
          a53(indx) := t(ddindx).person_identifier;
          a54(indx) := t(ddindx).person_iden_type;
          a55(indx) := t(ddindx).person_initials;
          a56(indx) := t(ddindx).person_last_name;
          a57(indx) := t(ddindx).person_last_name_phonetic;
          a58(indx) := t(ddindx).person_middle_name;
          a59(indx) := t(ddindx).person_name;
          a60(indx) := t(ddindx).person_name_phonetic;
          a61(indx) := t(ddindx).person_name_suffix;
          a62(indx) := t(ddindx).person_previous_last_name;
          a63(indx) := t(ddindx).person_title;
          a64(indx) := t(ddindx).place_of_birth;
          a65(indx) := t(ddindx).tax_name;
          a66(indx) := t(ddindx).tax_reference;
          a67(indx) := t(ddindx).content_source_type;
          a68(indx) := t(ddindx).directional_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy hz_party_search.contact_point_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_VARCHAR2_TABLE_4000
    , a6 JTF_VARCHAR2_TABLE_4000
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_4000
    , a9 JTF_VARCHAR2_TABLE_4000
    , a10 JTF_VARCHAR2_TABLE_4000
    , a11 JTF_VARCHAR2_TABLE_4000
    , a12 JTF_VARCHAR2_TABLE_4000
    , a13 JTF_VARCHAR2_TABLE_4000
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_VARCHAR2_TABLE_4000
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_4000
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_4000
    , a20 JTF_VARCHAR2_TABLE_4000
    , a21 JTF_VARCHAR2_TABLE_4000
    , a22 JTF_VARCHAR2_TABLE_4000
    , a23 JTF_VARCHAR2_TABLE_4000
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_VARCHAR2_TABLE_4000
    , a26 JTF_VARCHAR2_TABLE_4000
    , a27 JTF_VARCHAR2_TABLE_4000
    , a28 JTF_VARCHAR2_TABLE_4000
    , a29 JTF_VARCHAR2_TABLE_4000
    , a30 JTF_VARCHAR2_TABLE_4000
    , a31 JTF_VARCHAR2_TABLE_4000
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_4000
    , a44 JTF_DATE_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_2000
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contact_point_type := a0(indx);
          t(ddindx).cpt_source_system_ref := a1(indx);
          t(ddindx).custom_attribute1 := a2(indx);
          t(ddindx).custom_attribute10 := a3(indx);
          t(ddindx).custom_attribute11 := a4(indx);
          t(ddindx).custom_attribute12 := a5(indx);
          t(ddindx).custom_attribute13 := a6(indx);
          t(ddindx).custom_attribute14 := a7(indx);
          t(ddindx).custom_attribute15 := a8(indx);
          t(ddindx).custom_attribute16 := a9(indx);
          t(ddindx).custom_attribute17 := a10(indx);
          t(ddindx).custom_attribute18 := a11(indx);
          t(ddindx).custom_attribute19 := a12(indx);
          t(ddindx).custom_attribute2 := a13(indx);
          t(ddindx).custom_attribute20 := a14(indx);
          t(ddindx).custom_attribute21 := a15(indx);
          t(ddindx).custom_attribute22 := a16(indx);
          t(ddindx).custom_attribute23 := a17(indx);
          t(ddindx).custom_attribute24 := a18(indx);
          t(ddindx).custom_attribute25 := a19(indx);
          t(ddindx).custom_attribute26 := a20(indx);
          t(ddindx).custom_attribute27 := a21(indx);
          t(ddindx).custom_attribute28 := a22(indx);
          t(ddindx).custom_attribute29 := a23(indx);
          t(ddindx).custom_attribute3 := a24(indx);
          t(ddindx).custom_attribute30 := a25(indx);
          t(ddindx).custom_attribute4 := a26(indx);
          t(ddindx).custom_attribute5 := a27(indx);
          t(ddindx).custom_attribute6 := a28(indx);
          t(ddindx).custom_attribute7 := a29(indx);
          t(ddindx).custom_attribute8 := a30(indx);
          t(ddindx).custom_attribute9 := a31(indx);
          t(ddindx).content_source_type := a32(indx);
          t(ddindx).edi_ece_tp_location_code := a33(indx);
          t(ddindx).edi_id_number := a34(indx);
          t(ddindx).edi_payment_format := a35(indx);
          t(ddindx).edi_payment_method := a36(indx);
          t(ddindx).edi_remittance_instruction := a37(indx);
          t(ddindx).edi_remittance_method := a38(indx);
          t(ddindx).edi_tp_header_id := a39(indx);
          t(ddindx).edi_transaction_handling := a40(indx);
          t(ddindx).email_address := a41(indx);
          t(ddindx).email_format := a42(indx);
          t(ddindx).flex_format_phone_number := a43(indx);
          t(ddindx).last_contact_dt_time := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).phone_area_code := a45(indx);
          t(ddindx).phone_calling_calendar := a46(indx);
          t(ddindx).phone_country_code := a47(indx);
          t(ddindx).phone_extension := a48(indx);
          t(ddindx).phone_line_type := a49(indx);
          t(ddindx).phone_number := a50(indx);
          t(ddindx).primary_flag := a51(indx);
          t(ddindx).raw_phone_number := a52(indx);
          t(ddindx).telephone_type := a53(indx);
          t(ddindx).telex_number := a54(indx);
          t(ddindx).time_zone := a55(indx);
          t(ddindx).url := a56(indx);
          t(ddindx).web_type := a57(indx);
          t(ddindx).status := a58(indx);
          t(ddindx).contact_point_purpose := a59(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t hz_party_search.contact_point_list, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_4000
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_2000
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_4000();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_4000();
    a4 := JTF_VARCHAR2_TABLE_4000();
    a5 := JTF_VARCHAR2_TABLE_4000();
    a6 := JTF_VARCHAR2_TABLE_4000();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_4000();
    a9 := JTF_VARCHAR2_TABLE_4000();
    a10 := JTF_VARCHAR2_TABLE_4000();
    a11 := JTF_VARCHAR2_TABLE_4000();
    a12 := JTF_VARCHAR2_TABLE_4000();
    a13 := JTF_VARCHAR2_TABLE_4000();
    a14 := JTF_VARCHAR2_TABLE_4000();
    a15 := JTF_VARCHAR2_TABLE_4000();
    a16 := JTF_VARCHAR2_TABLE_4000();
    a17 := JTF_VARCHAR2_TABLE_4000();
    a18 := JTF_VARCHAR2_TABLE_4000();
    a19 := JTF_VARCHAR2_TABLE_4000();
    a20 := JTF_VARCHAR2_TABLE_4000();
    a21 := JTF_VARCHAR2_TABLE_4000();
    a22 := JTF_VARCHAR2_TABLE_4000();
    a23 := JTF_VARCHAR2_TABLE_4000();
    a24 := JTF_VARCHAR2_TABLE_4000();
    a25 := JTF_VARCHAR2_TABLE_4000();
    a26 := JTF_VARCHAR2_TABLE_4000();
    a27 := JTF_VARCHAR2_TABLE_4000();
    a28 := JTF_VARCHAR2_TABLE_4000();
    a29 := JTF_VARCHAR2_TABLE_4000();
    a30 := JTF_VARCHAR2_TABLE_4000();
    a31 := JTF_VARCHAR2_TABLE_4000();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_2000();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_4000();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_2000();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_2000();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_4000();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_4000();
      a4 := JTF_VARCHAR2_TABLE_4000();
      a5 := JTF_VARCHAR2_TABLE_4000();
      a6 := JTF_VARCHAR2_TABLE_4000();
      a7 := JTF_VARCHAR2_TABLE_4000();
      a8 := JTF_VARCHAR2_TABLE_4000();
      a9 := JTF_VARCHAR2_TABLE_4000();
      a10 := JTF_VARCHAR2_TABLE_4000();
      a11 := JTF_VARCHAR2_TABLE_4000();
      a12 := JTF_VARCHAR2_TABLE_4000();
      a13 := JTF_VARCHAR2_TABLE_4000();
      a14 := JTF_VARCHAR2_TABLE_4000();
      a15 := JTF_VARCHAR2_TABLE_4000();
      a16 := JTF_VARCHAR2_TABLE_4000();
      a17 := JTF_VARCHAR2_TABLE_4000();
      a18 := JTF_VARCHAR2_TABLE_4000();
      a19 := JTF_VARCHAR2_TABLE_4000();
      a20 := JTF_VARCHAR2_TABLE_4000();
      a21 := JTF_VARCHAR2_TABLE_4000();
      a22 := JTF_VARCHAR2_TABLE_4000();
      a23 := JTF_VARCHAR2_TABLE_4000();
      a24 := JTF_VARCHAR2_TABLE_4000();
      a25 := JTF_VARCHAR2_TABLE_4000();
      a26 := JTF_VARCHAR2_TABLE_4000();
      a27 := JTF_VARCHAR2_TABLE_4000();
      a28 := JTF_VARCHAR2_TABLE_4000();
      a29 := JTF_VARCHAR2_TABLE_4000();
      a30 := JTF_VARCHAR2_TABLE_4000();
      a31 := JTF_VARCHAR2_TABLE_4000();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_2000();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_4000();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_2000();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_2000();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).contact_point_type;
          a1(indx) := t(ddindx).cpt_source_system_ref;
          a2(indx) := t(ddindx).custom_attribute1;
          a3(indx) := t(ddindx).custom_attribute10;
          a4(indx) := t(ddindx).custom_attribute11;
          a5(indx) := t(ddindx).custom_attribute12;
          a6(indx) := t(ddindx).custom_attribute13;
          a7(indx) := t(ddindx).custom_attribute14;
          a8(indx) := t(ddindx).custom_attribute15;
          a9(indx) := t(ddindx).custom_attribute16;
          a10(indx) := t(ddindx).custom_attribute17;
          a11(indx) := t(ddindx).custom_attribute18;
          a12(indx) := t(ddindx).custom_attribute19;
          a13(indx) := t(ddindx).custom_attribute2;
          a14(indx) := t(ddindx).custom_attribute20;
          a15(indx) := t(ddindx).custom_attribute21;
          a16(indx) := t(ddindx).custom_attribute22;
          a17(indx) := t(ddindx).custom_attribute23;
          a18(indx) := t(ddindx).custom_attribute24;
          a19(indx) := t(ddindx).custom_attribute25;
          a20(indx) := t(ddindx).custom_attribute26;
          a21(indx) := t(ddindx).custom_attribute27;
          a22(indx) := t(ddindx).custom_attribute28;
          a23(indx) := t(ddindx).custom_attribute29;
          a24(indx) := t(ddindx).custom_attribute3;
          a25(indx) := t(ddindx).custom_attribute30;
          a26(indx) := t(ddindx).custom_attribute4;
          a27(indx) := t(ddindx).custom_attribute5;
          a28(indx) := t(ddindx).custom_attribute6;
          a29(indx) := t(ddindx).custom_attribute7;
          a30(indx) := t(ddindx).custom_attribute8;
          a31(indx) := t(ddindx).custom_attribute9;
          a32(indx) := t(ddindx).content_source_type;
          a33(indx) := t(ddindx).edi_ece_tp_location_code;
          a34(indx) := t(ddindx).edi_id_number;
          a35(indx) := t(ddindx).edi_payment_format;
          a36(indx) := t(ddindx).edi_payment_method;
          a37(indx) := t(ddindx).edi_remittance_instruction;
          a38(indx) := t(ddindx).edi_remittance_method;
          a39(indx) := t(ddindx).edi_tp_header_id;
          a40(indx) := t(ddindx).edi_transaction_handling;
          a41(indx) := t(ddindx).email_address;
          a42(indx) := t(ddindx).email_format;
          a43(indx) := t(ddindx).flex_format_phone_number;
          a44(indx) := t(ddindx).last_contact_dt_time;
          a45(indx) := t(ddindx).phone_area_code;
          a46(indx) := t(ddindx).phone_calling_calendar;
          a47(indx) := t(ddindx).phone_country_code;
          a48(indx) := t(ddindx).phone_extension;
          a49(indx) := t(ddindx).phone_line_type;
          a50(indx) := t(ddindx).phone_number;
          a51(indx) := t(ddindx).primary_flag;
          a52(indx) := t(ddindx).raw_phone_number;
          a53(indx) := t(ddindx).telephone_type;
          a54(indx) := t(ddindx).telex_number;
          a55(indx) := t(ddindx).time_zone;
          a56(indx) := t(ddindx).url;
          a57(indx) := t(ddindx).web_type;
          a58(indx) := t(ddindx).status;
          a59(indx) := t(ddindx).contact_point_purpose;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy hz_party_search.score_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).total_score := a0(indx);
          t(ddindx).party_score := a1(indx);
          t(ddindx).party_site_score := a2(indx);
          t(ddindx).contact_score := a3(indx);
          t(ddindx).contact_point_score := a4(indx);
          t(ddindx).party_id := a5(indx);
          t(ddindx).party_site_id := a6(indx);
          t(ddindx).org_contact_id := a7(indx);
          t(ddindx).contact_point_id := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t hz_party_search.score_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).total_score;
          a1(indx) := t(ddindx).party_score;
          a2(indx) := t(ddindx).party_site_score;
          a3(indx) := t(ddindx).contact_score;
          a4(indx) := t(ddindx).contact_point_score;
          a5(indx) := t(ddindx).party_id;
          a6(indx) := t(ddindx).party_site_id;
          a7(indx) := t(ddindx).org_contact_id;
          a8(indx) := t(ddindx).contact_point_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure find_parties_1(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  DATE
    , p2_a37  DATE
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  NUMBER
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  DATE
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  VARCHAR2
    , p2_a65  NUMBER
    , p2_a66  DATE
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  NUMBER
    , p2_a79  NUMBER
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  DATE
    , p2_a91  NUMBER
    , p2_a92  VARCHAR2
    , p2_a93  VARCHAR2
    , p2_a94  VARCHAR2
    , p2_a95  VARCHAR2
    , p2_a96  NUMBER
    , p2_a97  VARCHAR2
    , p2_a98  VARCHAR2
    , p2_a99  NUMBER
    , p2_a100  VARCHAR2
    , p2_a101  VARCHAR2
    , p2_a102  VARCHAR2
    , p2_a103  VARCHAR2
    , p2_a104  VARCHAR2
    , p2_a105  VARCHAR2
    , p2_a106  VARCHAR2
    , p2_a107  VARCHAR2
    , p2_a108  VARCHAR2
    , p2_a109  VARCHAR2
    , p2_a110  VARCHAR2
    , p2_a111  VARCHAR2
    , p2_a112  VARCHAR2
    , p2_a113  VARCHAR2
    , p2_a114  VARCHAR2
    , p2_a115  VARCHAR2
    , p2_a116  NUMBER
    , p2_a117  VARCHAR2
    , p2_a118  VARCHAR2
    , p2_a119  NUMBER
    , p2_a120  VARCHAR2
    , p2_a121  VARCHAR2
    , p2_a122  VARCHAR2
    , p2_a123  VARCHAR2
    , p2_a124  VARCHAR2
    , p2_a125  VARCHAR2
    , p2_a126  VARCHAR2
    , p2_a127  VARCHAR2
    , p2_a128  VARCHAR2
    , p2_a129  VARCHAR2
    , p2_a130  VARCHAR2
    , p2_a131  VARCHAR2
    , p2_a132  VARCHAR2
    , p2_a133  VARCHAR2
    , p2_a134  VARCHAR2
    , p2_a135  VARCHAR2
    , p2_a136  VARCHAR2
    , p2_a137  VARCHAR2
    , p2_a138  VARCHAR2
    , p2_a139  VARCHAR2
    , p2_a140  VARCHAR2
    , p2_a141  VARCHAR2
    , p2_a142  VARCHAR2
    , p2_a143  NUMBER
    , p2_a144  VARCHAR2
    , p2_a145  NUMBER
    , p2_a146  VARCHAR2
    , p2_a147  VARCHAR2
    , p2_a148  VARCHAR2
    , p2_a149  VARCHAR2
    , p2_a150  VARCHAR2
    , p2_a151  VARCHAR2
    , p2_a152  VARCHAR2
    , p2_a153  VARCHAR2
    , p2_a154  VARCHAR2
    , p2_a155  VARCHAR2
    , p2_a156  VARCHAR2
    , p2_a157  VARCHAR2
    , p2_a158  VARCHAR2
    , p2_a159  DATE
    , p2_a160  DATE
    , p2_a161  DATE
    , p2_a162  DATE
    , p2_a163  VARCHAR2
    , p2_a164  VARCHAR2
    , p2_a165  VARCHAR2
    , p2_a166  NUMBER
    , p2_a167  NUMBER
    , p2_a168  VARCHAR2
    , p2_a169  VARCHAR2
    , p2_a170  DATE
    , p2_a171  VARCHAR2
    , p2_a172  NUMBER
    , p2_a173  VARCHAR2
    , p2_a174  VARCHAR2
    , p2_a175  VARCHAR2
    , p2_a176  VARCHAR2
    , p2_a177  VARCHAR2
    , p2_a178  VARCHAR2
    , p2_a179  VARCHAR2
    , p2_a180  VARCHAR2
    , p2_a181  VARCHAR2
    , p2_a182  VARCHAR2
    , p2_a183  VARCHAR2
    , p2_a184  VARCHAR2
    , p2_a185  VARCHAR2
    , p2_a186  VARCHAR2
    , p2_a187  VARCHAR2
    , p2_a188  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_4000
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_4000
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_DATE_TABLE
    , p4_a47 JTF_DATE_TABLE
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_500
    , p4_a60 JTF_VARCHAR2_TABLE_400
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_100
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_VARCHAR2_TABLE_100
    , p4_a68 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_4000
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_2000
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_4000
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_VARCHAR2_TABLE_2000
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , p_search_merged  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_party_search_rec.all_account_names := p2_a0;
    ddp_party_search_rec.all_account_numbers := p2_a1;
    ddp_party_search_rec.domain_name := p2_a2;
    ddp_party_search_rec.party_source_system_ref := p2_a3;
    ddp_party_search_rec.custom_attribute1 := p2_a4;
    ddp_party_search_rec.custom_attribute10 := p2_a5;
    ddp_party_search_rec.custom_attribute11 := p2_a6;
    ddp_party_search_rec.custom_attribute12 := p2_a7;
    ddp_party_search_rec.custom_attribute13 := p2_a8;
    ddp_party_search_rec.custom_attribute14 := p2_a9;
    ddp_party_search_rec.custom_attribute15 := p2_a10;
    ddp_party_search_rec.custom_attribute16 := p2_a11;
    ddp_party_search_rec.custom_attribute17 := p2_a12;
    ddp_party_search_rec.custom_attribute18 := p2_a13;
    ddp_party_search_rec.custom_attribute19 := p2_a14;
    ddp_party_search_rec.custom_attribute2 := p2_a15;
    ddp_party_search_rec.custom_attribute20 := p2_a16;
    ddp_party_search_rec.custom_attribute21 := p2_a17;
    ddp_party_search_rec.custom_attribute22 := p2_a18;
    ddp_party_search_rec.custom_attribute23 := p2_a19;
    ddp_party_search_rec.custom_attribute24 := p2_a20;
    ddp_party_search_rec.custom_attribute25 := p2_a21;
    ddp_party_search_rec.custom_attribute26 := p2_a22;
    ddp_party_search_rec.custom_attribute27 := p2_a23;
    ddp_party_search_rec.custom_attribute28 := p2_a24;
    ddp_party_search_rec.custom_attribute29 := p2_a25;
    ddp_party_search_rec.custom_attribute3 := p2_a26;
    ddp_party_search_rec.custom_attribute30 := p2_a27;
    ddp_party_search_rec.custom_attribute4 := p2_a28;
    ddp_party_search_rec.custom_attribute5 := p2_a29;
    ddp_party_search_rec.custom_attribute6 := p2_a30;
    ddp_party_search_rec.custom_attribute7 := p2_a31;
    ddp_party_search_rec.custom_attribute8 := p2_a32;
    ddp_party_search_rec.custom_attribute9 := p2_a33;
    ddp_party_search_rec.analysis_fy := p2_a34;
    ddp_party_search_rec.avg_high_credit := p2_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a37);
    ddp_party_search_rec.branch_flag := p2_a38;
    ddp_party_search_rec.business_scope := p2_a39;
    ddp_party_search_rec.ceo_name := p2_a40;
    ddp_party_search_rec.ceo_title := p2_a41;
    ddp_party_search_rec.cong_dist_code := p2_a42;
    ddp_party_search_rec.content_source_number := p2_a43;
    ddp_party_search_rec.content_source_type := p2_a44;
    ddp_party_search_rec.control_yr := p2_a45;
    ddp_party_search_rec.corporation_class := p2_a46;
    ddp_party_search_rec.credit_score := p2_a47;
    ddp_party_search_rec.credit_score_age := p2_a48;
    ddp_party_search_rec.credit_score_class := p2_a49;
    ddp_party_search_rec.credit_score_commentary := p2_a50;
    ddp_party_search_rec.credit_score_commentary10 := p2_a51;
    ddp_party_search_rec.credit_score_commentary2 := p2_a52;
    ddp_party_search_rec.credit_score_commentary3 := p2_a53;
    ddp_party_search_rec.credit_score_commentary4 := p2_a54;
    ddp_party_search_rec.credit_score_commentary5 := p2_a55;
    ddp_party_search_rec.credit_score_commentary6 := p2_a56;
    ddp_party_search_rec.credit_score_commentary7 := p2_a57;
    ddp_party_search_rec.credit_score_commentary8 := p2_a58;
    ddp_party_search_rec.credit_score_commentary9 := p2_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a60);
    ddp_party_search_rec.credit_score_incd_default := p2_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p2_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p2_a63;
    ddp_party_search_rec.db_rating := p2_a64;
    ddp_party_search_rec.debarments_count := p2_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a66);
    ddp_party_search_rec.debarment_ind := p2_a67;
    ddp_party_search_rec.disadv_8a_ind := p2_a68;
    ddp_party_search_rec.duns_number_c := p2_a69;
    ddp_party_search_rec.employees_total := p2_a70;
    ddp_party_search_rec.emp_at_primary_adr := p2_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p2_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p2_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p2_a74;
    ddp_party_search_rec.enquiry_duns := p2_a75;
    ddp_party_search_rec.export_ind := p2_a76;
    ddp_party_search_rec.failure_score := p2_a77;
    ddp_party_search_rec.failure_score_age := p2_a78;
    ddp_party_search_rec.failure_score_class := p2_a79;
    ddp_party_search_rec.failure_score_commentary := p2_a80;
    ddp_party_search_rec.failure_score_commentary10 := p2_a81;
    ddp_party_search_rec.failure_score_commentary2 := p2_a82;
    ddp_party_search_rec.failure_score_commentary3 := p2_a83;
    ddp_party_search_rec.failure_score_commentary4 := p2_a84;
    ddp_party_search_rec.failure_score_commentary5 := p2_a85;
    ddp_party_search_rec.failure_score_commentary6 := p2_a86;
    ddp_party_search_rec.failure_score_commentary7 := p2_a87;
    ddp_party_search_rec.failure_score_commentary8 := p2_a88;
    ddp_party_search_rec.failure_score_commentary9 := p2_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a90);
    ddp_party_search_rec.failure_score_incd_default := p2_a91;
    ddp_party_search_rec.failure_score_override_code := p2_a92;
    ddp_party_search_rec.fiscal_yearend_month := p2_a93;
    ddp_party_search_rec.global_failure_score := p2_a94;
    ddp_party_search_rec.gsa_indicator_flag := p2_a95;
    ddp_party_search_rec.high_credit := p2_a96;
    ddp_party_search_rec.hq_branch_ind := p2_a97;
    ddp_party_search_rec.import_ind := p2_a98;
    ddp_party_search_rec.incorp_year := p2_a99;
    ddp_party_search_rec.internal_flag := p2_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p2_a101;
    ddp_party_search_rec.party_all_names := p2_a102;
    ddp_party_search_rec.known_as := p2_a103;
    ddp_party_search_rec.known_as2 := p2_a104;
    ddp_party_search_rec.known_as3 := p2_a105;
    ddp_party_search_rec.known_as4 := p2_a106;
    ddp_party_search_rec.known_as5 := p2_a107;
    ddp_party_search_rec.labor_surplus_ind := p2_a108;
    ddp_party_search_rec.legal_status := p2_a109;
    ddp_party_search_rec.line_of_business := p2_a110;
    ddp_party_search_rec.local_activity_code := p2_a111;
    ddp_party_search_rec.local_activity_code_type := p2_a112;
    ddp_party_search_rec.local_bus_identifier := p2_a113;
    ddp_party_search_rec.local_bus_iden_type := p2_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p2_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p2_a116;
    ddp_party_search_rec.minority_owned_ind := p2_a117;
    ddp_party_search_rec.minority_owned_type := p2_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p2_a119;
    ddp_party_search_rec.oob_ind := p2_a120;
    ddp_party_search_rec.organization_name := p2_a121;
    ddp_party_search_rec.organization_name_phonetic := p2_a122;
    ddp_party_search_rec.organization_type := p2_a123;
    ddp_party_search_rec.parent_sub_ind := p2_a124;
    ddp_party_search_rec.paydex_norm := p2_a125;
    ddp_party_search_rec.paydex_score := p2_a126;
    ddp_party_search_rec.paydex_three_months_ago := p2_a127;
    ddp_party_search_rec.pref_functional_currency := p2_a128;
    ddp_party_search_rec.principal_name := p2_a129;
    ddp_party_search_rec.principal_title := p2_a130;
    ddp_party_search_rec.public_private_ownership_flag := p2_a131;
    ddp_party_search_rec.registration_type := p2_a132;
    ddp_party_search_rec.rent_own_ind := p2_a133;
    ddp_party_search_rec.sic_code := p2_a134;
    ddp_party_search_rec.sic_code_type := p2_a135;
    ddp_party_search_rec.small_bus_ind := p2_a136;
    ddp_party_search_rec.tax_name := p2_a137;
    ddp_party_search_rec.tax_reference := p2_a138;
    ddp_party_search_rec.total_employees_text := p2_a139;
    ddp_party_search_rec.total_emp_est_ind := p2_a140;
    ddp_party_search_rec.total_emp_min_ind := p2_a141;
    ddp_party_search_rec.total_employees_ind := p2_a142;
    ddp_party_search_rec.total_payments := p2_a143;
    ddp_party_search_rec.woman_owned_ind := p2_a144;
    ddp_party_search_rec.year_established := p2_a145;
    ddp_party_search_rec.category_code := p2_a146;
    ddp_party_search_rec.competitor_flag := p2_a147;
    ddp_party_search_rec.do_not_mail_flag := p2_a148;
    ddp_party_search_rec.group_type := p2_a149;
    ddp_party_search_rec.language_name := p2_a150;
    ddp_party_search_rec.party_name := p2_a151;
    ddp_party_search_rec.party_number := p2_a152;
    ddp_party_search_rec.party_type := p2_a153;
    ddp_party_search_rec.reference_use_flag := p2_a154;
    ddp_party_search_rec.salutation := p2_a155;
    ddp_party_search_rec.status := p2_a156;
    ddp_party_search_rec.third_party_flag := p2_a157;
    ddp_party_search_rec.validated_flag := p2_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p2_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p2_a162);
    ddp_party_search_rec.declared_ethnicity := p2_a163;
    ddp_party_search_rec.gender := p2_a164;
    ddp_party_search_rec.head_of_household_flag := p2_a165;
    ddp_party_search_rec.household_income := p2_a166;
    ddp_party_search_rec.household_size := p2_a167;
    ddp_party_search_rec.last_known_gps := p2_a168;
    ddp_party_search_rec.marital_status := p2_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a170);
    ddp_party_search_rec.middle_name_phonetic := p2_a171;
    ddp_party_search_rec.personal_income := p2_a172;
    ddp_party_search_rec.person_academic_title := p2_a173;
    ddp_party_search_rec.person_first_name := p2_a174;
    ddp_party_search_rec.person_first_name_phonetic := p2_a175;
    ddp_party_search_rec.person_identifier := p2_a176;
    ddp_party_search_rec.person_iden_type := p2_a177;
    ddp_party_search_rec.person_initials := p2_a178;
    ddp_party_search_rec.person_last_name := p2_a179;
    ddp_party_search_rec.person_last_name_phonetic := p2_a180;
    ddp_party_search_rec.person_middle_name := p2_a181;
    ddp_party_search_rec.person_name := p2_a182;
    ddp_party_search_rec.person_name_phonetic := p2_a183;
    ddp_party_search_rec.person_name_suffix := p2_a184;
    ddp_party_search_rec.person_previous_last_name := p2_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p2_a186;
    ddp_party_search_rec.person_title := p2_a187;
    ddp_party_search_rec.place_of_birth := p2_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p5_a0
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
      );









    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.find_parties(p_init_msg_list,
      p_rule_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      p_search_merged,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure find_parties_2(p_init_msg_list  VARCHAR2
    , x_rule_id in out nocopy  NUMBER
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  DATE
    , p2_a37  DATE
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  NUMBER
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  DATE
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  VARCHAR2
    , p2_a65  NUMBER
    , p2_a66  DATE
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  NUMBER
    , p2_a79  NUMBER
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  DATE
    , p2_a91  NUMBER
    , p2_a92  VARCHAR2
    , p2_a93  VARCHAR2
    , p2_a94  VARCHAR2
    , p2_a95  VARCHAR2
    , p2_a96  NUMBER
    , p2_a97  VARCHAR2
    , p2_a98  VARCHAR2
    , p2_a99  NUMBER
    , p2_a100  VARCHAR2
    , p2_a101  VARCHAR2
    , p2_a102  VARCHAR2
    , p2_a103  VARCHAR2
    , p2_a104  VARCHAR2
    , p2_a105  VARCHAR2
    , p2_a106  VARCHAR2
    , p2_a107  VARCHAR2
    , p2_a108  VARCHAR2
    , p2_a109  VARCHAR2
    , p2_a110  VARCHAR2
    , p2_a111  VARCHAR2
    , p2_a112  VARCHAR2
    , p2_a113  VARCHAR2
    , p2_a114  VARCHAR2
    , p2_a115  VARCHAR2
    , p2_a116  NUMBER
    , p2_a117  VARCHAR2
    , p2_a118  VARCHAR2
    , p2_a119  NUMBER
    , p2_a120  VARCHAR2
    , p2_a121  VARCHAR2
    , p2_a122  VARCHAR2
    , p2_a123  VARCHAR2
    , p2_a124  VARCHAR2
    , p2_a125  VARCHAR2
    , p2_a126  VARCHAR2
    , p2_a127  VARCHAR2
    , p2_a128  VARCHAR2
    , p2_a129  VARCHAR2
    , p2_a130  VARCHAR2
    , p2_a131  VARCHAR2
    , p2_a132  VARCHAR2
    , p2_a133  VARCHAR2
    , p2_a134  VARCHAR2
    , p2_a135  VARCHAR2
    , p2_a136  VARCHAR2
    , p2_a137  VARCHAR2
    , p2_a138  VARCHAR2
    , p2_a139  VARCHAR2
    , p2_a140  VARCHAR2
    , p2_a141  VARCHAR2
    , p2_a142  VARCHAR2
    , p2_a143  NUMBER
    , p2_a144  VARCHAR2
    , p2_a145  NUMBER
    , p2_a146  VARCHAR2
    , p2_a147  VARCHAR2
    , p2_a148  VARCHAR2
    , p2_a149  VARCHAR2
    , p2_a150  VARCHAR2
    , p2_a151  VARCHAR2
    , p2_a152  VARCHAR2
    , p2_a153  VARCHAR2
    , p2_a154  VARCHAR2
    , p2_a155  VARCHAR2
    , p2_a156  VARCHAR2
    , p2_a157  VARCHAR2
    , p2_a158  VARCHAR2
    , p2_a159  DATE
    , p2_a160  DATE
    , p2_a161  DATE
    , p2_a162  DATE
    , p2_a163  VARCHAR2
    , p2_a164  VARCHAR2
    , p2_a165  VARCHAR2
    , p2_a166  NUMBER
    , p2_a167  NUMBER
    , p2_a168  VARCHAR2
    , p2_a169  VARCHAR2
    , p2_a170  DATE
    , p2_a171  VARCHAR2
    , p2_a172  NUMBER
    , p2_a173  VARCHAR2
    , p2_a174  VARCHAR2
    , p2_a175  VARCHAR2
    , p2_a176  VARCHAR2
    , p2_a177  VARCHAR2
    , p2_a178  VARCHAR2
    , p2_a179  VARCHAR2
    , p2_a180  VARCHAR2
    , p2_a181  VARCHAR2
    , p2_a182  VARCHAR2
    , p2_a183  VARCHAR2
    , p2_a184  VARCHAR2
    , p2_a185  VARCHAR2
    , p2_a186  VARCHAR2
    , p2_a187  VARCHAR2
    , p2_a188  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_4000
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_4000
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_DATE_TABLE
    , p4_a47 JTF_DATE_TABLE
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_500
    , p4_a60 JTF_VARCHAR2_TABLE_400
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_100
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_VARCHAR2_TABLE_100
    , p4_a68 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_4000
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_2000
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_4000
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_VARCHAR2_TABLE_2000
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_search_merged  VARCHAR2
    , x_search_ctx_id in out nocopy  NUMBER
    , x_num_matches in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_party_search_rec.all_account_names := p2_a0;
    ddp_party_search_rec.all_account_numbers := p2_a1;
    ddp_party_search_rec.domain_name := p2_a2;
    ddp_party_search_rec.party_source_system_ref := p2_a3;
    ddp_party_search_rec.custom_attribute1 := p2_a4;
    ddp_party_search_rec.custom_attribute10 := p2_a5;
    ddp_party_search_rec.custom_attribute11 := p2_a6;
    ddp_party_search_rec.custom_attribute12 := p2_a7;
    ddp_party_search_rec.custom_attribute13 := p2_a8;
    ddp_party_search_rec.custom_attribute14 := p2_a9;
    ddp_party_search_rec.custom_attribute15 := p2_a10;
    ddp_party_search_rec.custom_attribute16 := p2_a11;
    ddp_party_search_rec.custom_attribute17 := p2_a12;
    ddp_party_search_rec.custom_attribute18 := p2_a13;
    ddp_party_search_rec.custom_attribute19 := p2_a14;
    ddp_party_search_rec.custom_attribute2 := p2_a15;
    ddp_party_search_rec.custom_attribute20 := p2_a16;
    ddp_party_search_rec.custom_attribute21 := p2_a17;
    ddp_party_search_rec.custom_attribute22 := p2_a18;
    ddp_party_search_rec.custom_attribute23 := p2_a19;
    ddp_party_search_rec.custom_attribute24 := p2_a20;
    ddp_party_search_rec.custom_attribute25 := p2_a21;
    ddp_party_search_rec.custom_attribute26 := p2_a22;
    ddp_party_search_rec.custom_attribute27 := p2_a23;
    ddp_party_search_rec.custom_attribute28 := p2_a24;
    ddp_party_search_rec.custom_attribute29 := p2_a25;
    ddp_party_search_rec.custom_attribute3 := p2_a26;
    ddp_party_search_rec.custom_attribute30 := p2_a27;
    ddp_party_search_rec.custom_attribute4 := p2_a28;
    ddp_party_search_rec.custom_attribute5 := p2_a29;
    ddp_party_search_rec.custom_attribute6 := p2_a30;
    ddp_party_search_rec.custom_attribute7 := p2_a31;
    ddp_party_search_rec.custom_attribute8 := p2_a32;
    ddp_party_search_rec.custom_attribute9 := p2_a33;
    ddp_party_search_rec.analysis_fy := p2_a34;
    ddp_party_search_rec.avg_high_credit := p2_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a37);
    ddp_party_search_rec.branch_flag := p2_a38;
    ddp_party_search_rec.business_scope := p2_a39;
    ddp_party_search_rec.ceo_name := p2_a40;
    ddp_party_search_rec.ceo_title := p2_a41;
    ddp_party_search_rec.cong_dist_code := p2_a42;
    ddp_party_search_rec.content_source_number := p2_a43;
    ddp_party_search_rec.content_source_type := p2_a44;
    ddp_party_search_rec.control_yr := p2_a45;
    ddp_party_search_rec.corporation_class := p2_a46;
    ddp_party_search_rec.credit_score := p2_a47;
    ddp_party_search_rec.credit_score_age := p2_a48;
    ddp_party_search_rec.credit_score_class := p2_a49;
    ddp_party_search_rec.credit_score_commentary := p2_a50;
    ddp_party_search_rec.credit_score_commentary10 := p2_a51;
    ddp_party_search_rec.credit_score_commentary2 := p2_a52;
    ddp_party_search_rec.credit_score_commentary3 := p2_a53;
    ddp_party_search_rec.credit_score_commentary4 := p2_a54;
    ddp_party_search_rec.credit_score_commentary5 := p2_a55;
    ddp_party_search_rec.credit_score_commentary6 := p2_a56;
    ddp_party_search_rec.credit_score_commentary7 := p2_a57;
    ddp_party_search_rec.credit_score_commentary8 := p2_a58;
    ddp_party_search_rec.credit_score_commentary9 := p2_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a60);
    ddp_party_search_rec.credit_score_incd_default := p2_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p2_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p2_a63;
    ddp_party_search_rec.db_rating := p2_a64;
    ddp_party_search_rec.debarments_count := p2_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a66);
    ddp_party_search_rec.debarment_ind := p2_a67;
    ddp_party_search_rec.disadv_8a_ind := p2_a68;
    ddp_party_search_rec.duns_number_c := p2_a69;
    ddp_party_search_rec.employees_total := p2_a70;
    ddp_party_search_rec.emp_at_primary_adr := p2_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p2_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p2_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p2_a74;
    ddp_party_search_rec.enquiry_duns := p2_a75;
    ddp_party_search_rec.export_ind := p2_a76;
    ddp_party_search_rec.failure_score := p2_a77;
    ddp_party_search_rec.failure_score_age := p2_a78;
    ddp_party_search_rec.failure_score_class := p2_a79;
    ddp_party_search_rec.failure_score_commentary := p2_a80;
    ddp_party_search_rec.failure_score_commentary10 := p2_a81;
    ddp_party_search_rec.failure_score_commentary2 := p2_a82;
    ddp_party_search_rec.failure_score_commentary3 := p2_a83;
    ddp_party_search_rec.failure_score_commentary4 := p2_a84;
    ddp_party_search_rec.failure_score_commentary5 := p2_a85;
    ddp_party_search_rec.failure_score_commentary6 := p2_a86;
    ddp_party_search_rec.failure_score_commentary7 := p2_a87;
    ddp_party_search_rec.failure_score_commentary8 := p2_a88;
    ddp_party_search_rec.failure_score_commentary9 := p2_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a90);
    ddp_party_search_rec.failure_score_incd_default := p2_a91;
    ddp_party_search_rec.failure_score_override_code := p2_a92;
    ddp_party_search_rec.fiscal_yearend_month := p2_a93;
    ddp_party_search_rec.global_failure_score := p2_a94;
    ddp_party_search_rec.gsa_indicator_flag := p2_a95;
    ddp_party_search_rec.high_credit := p2_a96;
    ddp_party_search_rec.hq_branch_ind := p2_a97;
    ddp_party_search_rec.import_ind := p2_a98;
    ddp_party_search_rec.incorp_year := p2_a99;
    ddp_party_search_rec.internal_flag := p2_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p2_a101;
    ddp_party_search_rec.party_all_names := p2_a102;
    ddp_party_search_rec.known_as := p2_a103;
    ddp_party_search_rec.known_as2 := p2_a104;
    ddp_party_search_rec.known_as3 := p2_a105;
    ddp_party_search_rec.known_as4 := p2_a106;
    ddp_party_search_rec.known_as5 := p2_a107;
    ddp_party_search_rec.labor_surplus_ind := p2_a108;
    ddp_party_search_rec.legal_status := p2_a109;
    ddp_party_search_rec.line_of_business := p2_a110;
    ddp_party_search_rec.local_activity_code := p2_a111;
    ddp_party_search_rec.local_activity_code_type := p2_a112;
    ddp_party_search_rec.local_bus_identifier := p2_a113;
    ddp_party_search_rec.local_bus_iden_type := p2_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p2_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p2_a116;
    ddp_party_search_rec.minority_owned_ind := p2_a117;
    ddp_party_search_rec.minority_owned_type := p2_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p2_a119;
    ddp_party_search_rec.oob_ind := p2_a120;
    ddp_party_search_rec.organization_name := p2_a121;
    ddp_party_search_rec.organization_name_phonetic := p2_a122;
    ddp_party_search_rec.organization_type := p2_a123;
    ddp_party_search_rec.parent_sub_ind := p2_a124;
    ddp_party_search_rec.paydex_norm := p2_a125;
    ddp_party_search_rec.paydex_score := p2_a126;
    ddp_party_search_rec.paydex_three_months_ago := p2_a127;
    ddp_party_search_rec.pref_functional_currency := p2_a128;
    ddp_party_search_rec.principal_name := p2_a129;
    ddp_party_search_rec.principal_title := p2_a130;
    ddp_party_search_rec.public_private_ownership_flag := p2_a131;
    ddp_party_search_rec.registration_type := p2_a132;
    ddp_party_search_rec.rent_own_ind := p2_a133;
    ddp_party_search_rec.sic_code := p2_a134;
    ddp_party_search_rec.sic_code_type := p2_a135;
    ddp_party_search_rec.small_bus_ind := p2_a136;
    ddp_party_search_rec.tax_name := p2_a137;
    ddp_party_search_rec.tax_reference := p2_a138;
    ddp_party_search_rec.total_employees_text := p2_a139;
    ddp_party_search_rec.total_emp_est_ind := p2_a140;
    ddp_party_search_rec.total_emp_min_ind := p2_a141;
    ddp_party_search_rec.total_employees_ind := p2_a142;
    ddp_party_search_rec.total_payments := p2_a143;
    ddp_party_search_rec.woman_owned_ind := p2_a144;
    ddp_party_search_rec.year_established := p2_a145;
    ddp_party_search_rec.category_code := p2_a146;
    ddp_party_search_rec.competitor_flag := p2_a147;
    ddp_party_search_rec.do_not_mail_flag := p2_a148;
    ddp_party_search_rec.group_type := p2_a149;
    ddp_party_search_rec.language_name := p2_a150;
    ddp_party_search_rec.party_name := p2_a151;
    ddp_party_search_rec.party_number := p2_a152;
    ddp_party_search_rec.party_type := p2_a153;
    ddp_party_search_rec.reference_use_flag := p2_a154;
    ddp_party_search_rec.salutation := p2_a155;
    ddp_party_search_rec.status := p2_a156;
    ddp_party_search_rec.third_party_flag := p2_a157;
    ddp_party_search_rec.validated_flag := p2_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p2_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p2_a162);
    ddp_party_search_rec.declared_ethnicity := p2_a163;
    ddp_party_search_rec.gender := p2_a164;
    ddp_party_search_rec.head_of_household_flag := p2_a165;
    ddp_party_search_rec.household_income := p2_a166;
    ddp_party_search_rec.household_size := p2_a167;
    ddp_party_search_rec.last_known_gps := p2_a168;
    ddp_party_search_rec.marital_status := p2_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a170);
    ddp_party_search_rec.middle_name_phonetic := p2_a171;
    ddp_party_search_rec.personal_income := p2_a172;
    ddp_party_search_rec.person_academic_title := p2_a173;
    ddp_party_search_rec.person_first_name := p2_a174;
    ddp_party_search_rec.person_first_name_phonetic := p2_a175;
    ddp_party_search_rec.person_identifier := p2_a176;
    ddp_party_search_rec.person_iden_type := p2_a177;
    ddp_party_search_rec.person_initials := p2_a178;
    ddp_party_search_rec.person_last_name := p2_a179;
    ddp_party_search_rec.person_last_name_phonetic := p2_a180;
    ddp_party_search_rec.person_middle_name := p2_a181;
    ddp_party_search_rec.person_name := p2_a182;
    ddp_party_search_rec.person_name_phonetic := p2_a183;
    ddp_party_search_rec.person_name_suffix := p2_a184;
    ddp_party_search_rec.person_previous_last_name := p2_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p2_a186;
    ddp_party_search_rec.person_title := p2_a187;
    ddp_party_search_rec.place_of_birth := p2_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p5_a0
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
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.find_parties(p_init_msg_list,
      x_rule_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_search_merged,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure find_persons_3(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  DATE
    , p2_a37  DATE
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  NUMBER
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  DATE
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  VARCHAR2
    , p2_a65  NUMBER
    , p2_a66  DATE
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  NUMBER
    , p2_a79  NUMBER
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  DATE
    , p2_a91  NUMBER
    , p2_a92  VARCHAR2
    , p2_a93  VARCHAR2
    , p2_a94  VARCHAR2
    , p2_a95  VARCHAR2
    , p2_a96  NUMBER
    , p2_a97  VARCHAR2
    , p2_a98  VARCHAR2
    , p2_a99  NUMBER
    , p2_a100  VARCHAR2
    , p2_a101  VARCHAR2
    , p2_a102  VARCHAR2
    , p2_a103  VARCHAR2
    , p2_a104  VARCHAR2
    , p2_a105  VARCHAR2
    , p2_a106  VARCHAR2
    , p2_a107  VARCHAR2
    , p2_a108  VARCHAR2
    , p2_a109  VARCHAR2
    , p2_a110  VARCHAR2
    , p2_a111  VARCHAR2
    , p2_a112  VARCHAR2
    , p2_a113  VARCHAR2
    , p2_a114  VARCHAR2
    , p2_a115  VARCHAR2
    , p2_a116  NUMBER
    , p2_a117  VARCHAR2
    , p2_a118  VARCHAR2
    , p2_a119  NUMBER
    , p2_a120  VARCHAR2
    , p2_a121  VARCHAR2
    , p2_a122  VARCHAR2
    , p2_a123  VARCHAR2
    , p2_a124  VARCHAR2
    , p2_a125  VARCHAR2
    , p2_a126  VARCHAR2
    , p2_a127  VARCHAR2
    , p2_a128  VARCHAR2
    , p2_a129  VARCHAR2
    , p2_a130  VARCHAR2
    , p2_a131  VARCHAR2
    , p2_a132  VARCHAR2
    , p2_a133  VARCHAR2
    , p2_a134  VARCHAR2
    , p2_a135  VARCHAR2
    , p2_a136  VARCHAR2
    , p2_a137  VARCHAR2
    , p2_a138  VARCHAR2
    , p2_a139  VARCHAR2
    , p2_a140  VARCHAR2
    , p2_a141  VARCHAR2
    , p2_a142  VARCHAR2
    , p2_a143  NUMBER
    , p2_a144  VARCHAR2
    , p2_a145  NUMBER
    , p2_a146  VARCHAR2
    , p2_a147  VARCHAR2
    , p2_a148  VARCHAR2
    , p2_a149  VARCHAR2
    , p2_a150  VARCHAR2
    , p2_a151  VARCHAR2
    , p2_a152  VARCHAR2
    , p2_a153  VARCHAR2
    , p2_a154  VARCHAR2
    , p2_a155  VARCHAR2
    , p2_a156  VARCHAR2
    , p2_a157  VARCHAR2
    , p2_a158  VARCHAR2
    , p2_a159  DATE
    , p2_a160  DATE
    , p2_a161  DATE
    , p2_a162  DATE
    , p2_a163  VARCHAR2
    , p2_a164  VARCHAR2
    , p2_a165  VARCHAR2
    , p2_a166  NUMBER
    , p2_a167  NUMBER
    , p2_a168  VARCHAR2
    , p2_a169  VARCHAR2
    , p2_a170  DATE
    , p2_a171  VARCHAR2
    , p2_a172  NUMBER
    , p2_a173  VARCHAR2
    , p2_a174  VARCHAR2
    , p2_a175  VARCHAR2
    , p2_a176  VARCHAR2
    , p2_a177  VARCHAR2
    , p2_a178  VARCHAR2
    , p2_a179  VARCHAR2
    , p2_a180  VARCHAR2
    , p2_a181  VARCHAR2
    , p2_a182  VARCHAR2
    , p2_a183  VARCHAR2
    , p2_a184  VARCHAR2
    , p2_a185  VARCHAR2
    , p2_a186  VARCHAR2
    , p2_a187  VARCHAR2
    , p2_a188  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_4000
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_4000
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_DATE_TABLE
    , p4_a47 JTF_DATE_TABLE
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_500
    , p4_a60 JTF_VARCHAR2_TABLE_400
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_100
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_VARCHAR2_TABLE_100
    , p4_a68 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_4000
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_2000
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_4000
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_VARCHAR2_TABLE_2000
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_party_search_rec.all_account_names := p2_a0;
    ddp_party_search_rec.all_account_numbers := p2_a1;
    ddp_party_search_rec.domain_name := p2_a2;
    ddp_party_search_rec.party_source_system_ref := p2_a3;
    ddp_party_search_rec.custom_attribute1 := p2_a4;
    ddp_party_search_rec.custom_attribute10 := p2_a5;
    ddp_party_search_rec.custom_attribute11 := p2_a6;
    ddp_party_search_rec.custom_attribute12 := p2_a7;
    ddp_party_search_rec.custom_attribute13 := p2_a8;
    ddp_party_search_rec.custom_attribute14 := p2_a9;
    ddp_party_search_rec.custom_attribute15 := p2_a10;
    ddp_party_search_rec.custom_attribute16 := p2_a11;
    ddp_party_search_rec.custom_attribute17 := p2_a12;
    ddp_party_search_rec.custom_attribute18 := p2_a13;
    ddp_party_search_rec.custom_attribute19 := p2_a14;
    ddp_party_search_rec.custom_attribute2 := p2_a15;
    ddp_party_search_rec.custom_attribute20 := p2_a16;
    ddp_party_search_rec.custom_attribute21 := p2_a17;
    ddp_party_search_rec.custom_attribute22 := p2_a18;
    ddp_party_search_rec.custom_attribute23 := p2_a19;
    ddp_party_search_rec.custom_attribute24 := p2_a20;
    ddp_party_search_rec.custom_attribute25 := p2_a21;
    ddp_party_search_rec.custom_attribute26 := p2_a22;
    ddp_party_search_rec.custom_attribute27 := p2_a23;
    ddp_party_search_rec.custom_attribute28 := p2_a24;
    ddp_party_search_rec.custom_attribute29 := p2_a25;
    ddp_party_search_rec.custom_attribute3 := p2_a26;
    ddp_party_search_rec.custom_attribute30 := p2_a27;
    ddp_party_search_rec.custom_attribute4 := p2_a28;
    ddp_party_search_rec.custom_attribute5 := p2_a29;
    ddp_party_search_rec.custom_attribute6 := p2_a30;
    ddp_party_search_rec.custom_attribute7 := p2_a31;
    ddp_party_search_rec.custom_attribute8 := p2_a32;
    ddp_party_search_rec.custom_attribute9 := p2_a33;
    ddp_party_search_rec.analysis_fy := p2_a34;
    ddp_party_search_rec.avg_high_credit := p2_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a37);
    ddp_party_search_rec.branch_flag := p2_a38;
    ddp_party_search_rec.business_scope := p2_a39;
    ddp_party_search_rec.ceo_name := p2_a40;
    ddp_party_search_rec.ceo_title := p2_a41;
    ddp_party_search_rec.cong_dist_code := p2_a42;
    ddp_party_search_rec.content_source_number := p2_a43;
    ddp_party_search_rec.content_source_type := p2_a44;
    ddp_party_search_rec.control_yr := p2_a45;
    ddp_party_search_rec.corporation_class := p2_a46;
    ddp_party_search_rec.credit_score := p2_a47;
    ddp_party_search_rec.credit_score_age := p2_a48;
    ddp_party_search_rec.credit_score_class := p2_a49;
    ddp_party_search_rec.credit_score_commentary := p2_a50;
    ddp_party_search_rec.credit_score_commentary10 := p2_a51;
    ddp_party_search_rec.credit_score_commentary2 := p2_a52;
    ddp_party_search_rec.credit_score_commentary3 := p2_a53;
    ddp_party_search_rec.credit_score_commentary4 := p2_a54;
    ddp_party_search_rec.credit_score_commentary5 := p2_a55;
    ddp_party_search_rec.credit_score_commentary6 := p2_a56;
    ddp_party_search_rec.credit_score_commentary7 := p2_a57;
    ddp_party_search_rec.credit_score_commentary8 := p2_a58;
    ddp_party_search_rec.credit_score_commentary9 := p2_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a60);
    ddp_party_search_rec.credit_score_incd_default := p2_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p2_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p2_a63;
    ddp_party_search_rec.db_rating := p2_a64;
    ddp_party_search_rec.debarments_count := p2_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a66);
    ddp_party_search_rec.debarment_ind := p2_a67;
    ddp_party_search_rec.disadv_8a_ind := p2_a68;
    ddp_party_search_rec.duns_number_c := p2_a69;
    ddp_party_search_rec.employees_total := p2_a70;
    ddp_party_search_rec.emp_at_primary_adr := p2_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p2_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p2_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p2_a74;
    ddp_party_search_rec.enquiry_duns := p2_a75;
    ddp_party_search_rec.export_ind := p2_a76;
    ddp_party_search_rec.failure_score := p2_a77;
    ddp_party_search_rec.failure_score_age := p2_a78;
    ddp_party_search_rec.failure_score_class := p2_a79;
    ddp_party_search_rec.failure_score_commentary := p2_a80;
    ddp_party_search_rec.failure_score_commentary10 := p2_a81;
    ddp_party_search_rec.failure_score_commentary2 := p2_a82;
    ddp_party_search_rec.failure_score_commentary3 := p2_a83;
    ddp_party_search_rec.failure_score_commentary4 := p2_a84;
    ddp_party_search_rec.failure_score_commentary5 := p2_a85;
    ddp_party_search_rec.failure_score_commentary6 := p2_a86;
    ddp_party_search_rec.failure_score_commentary7 := p2_a87;
    ddp_party_search_rec.failure_score_commentary8 := p2_a88;
    ddp_party_search_rec.failure_score_commentary9 := p2_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a90);
    ddp_party_search_rec.failure_score_incd_default := p2_a91;
    ddp_party_search_rec.failure_score_override_code := p2_a92;
    ddp_party_search_rec.fiscal_yearend_month := p2_a93;
    ddp_party_search_rec.global_failure_score := p2_a94;
    ddp_party_search_rec.gsa_indicator_flag := p2_a95;
    ddp_party_search_rec.high_credit := p2_a96;
    ddp_party_search_rec.hq_branch_ind := p2_a97;
    ddp_party_search_rec.import_ind := p2_a98;
    ddp_party_search_rec.incorp_year := p2_a99;
    ddp_party_search_rec.internal_flag := p2_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p2_a101;
    ddp_party_search_rec.party_all_names := p2_a102;
    ddp_party_search_rec.known_as := p2_a103;
    ddp_party_search_rec.known_as2 := p2_a104;
    ddp_party_search_rec.known_as3 := p2_a105;
    ddp_party_search_rec.known_as4 := p2_a106;
    ddp_party_search_rec.known_as5 := p2_a107;
    ddp_party_search_rec.labor_surplus_ind := p2_a108;
    ddp_party_search_rec.legal_status := p2_a109;
    ddp_party_search_rec.line_of_business := p2_a110;
    ddp_party_search_rec.local_activity_code := p2_a111;
    ddp_party_search_rec.local_activity_code_type := p2_a112;
    ddp_party_search_rec.local_bus_identifier := p2_a113;
    ddp_party_search_rec.local_bus_iden_type := p2_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p2_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p2_a116;
    ddp_party_search_rec.minority_owned_ind := p2_a117;
    ddp_party_search_rec.minority_owned_type := p2_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p2_a119;
    ddp_party_search_rec.oob_ind := p2_a120;
    ddp_party_search_rec.organization_name := p2_a121;
    ddp_party_search_rec.organization_name_phonetic := p2_a122;
    ddp_party_search_rec.organization_type := p2_a123;
    ddp_party_search_rec.parent_sub_ind := p2_a124;
    ddp_party_search_rec.paydex_norm := p2_a125;
    ddp_party_search_rec.paydex_score := p2_a126;
    ddp_party_search_rec.paydex_three_months_ago := p2_a127;
    ddp_party_search_rec.pref_functional_currency := p2_a128;
    ddp_party_search_rec.principal_name := p2_a129;
    ddp_party_search_rec.principal_title := p2_a130;
    ddp_party_search_rec.public_private_ownership_flag := p2_a131;
    ddp_party_search_rec.registration_type := p2_a132;
    ddp_party_search_rec.rent_own_ind := p2_a133;
    ddp_party_search_rec.sic_code := p2_a134;
    ddp_party_search_rec.sic_code_type := p2_a135;
    ddp_party_search_rec.small_bus_ind := p2_a136;
    ddp_party_search_rec.tax_name := p2_a137;
    ddp_party_search_rec.tax_reference := p2_a138;
    ddp_party_search_rec.total_employees_text := p2_a139;
    ddp_party_search_rec.total_emp_est_ind := p2_a140;
    ddp_party_search_rec.total_emp_min_ind := p2_a141;
    ddp_party_search_rec.total_employees_ind := p2_a142;
    ddp_party_search_rec.total_payments := p2_a143;
    ddp_party_search_rec.woman_owned_ind := p2_a144;
    ddp_party_search_rec.year_established := p2_a145;
    ddp_party_search_rec.category_code := p2_a146;
    ddp_party_search_rec.competitor_flag := p2_a147;
    ddp_party_search_rec.do_not_mail_flag := p2_a148;
    ddp_party_search_rec.group_type := p2_a149;
    ddp_party_search_rec.language_name := p2_a150;
    ddp_party_search_rec.party_name := p2_a151;
    ddp_party_search_rec.party_number := p2_a152;
    ddp_party_search_rec.party_type := p2_a153;
    ddp_party_search_rec.reference_use_flag := p2_a154;
    ddp_party_search_rec.salutation := p2_a155;
    ddp_party_search_rec.status := p2_a156;
    ddp_party_search_rec.third_party_flag := p2_a157;
    ddp_party_search_rec.validated_flag := p2_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p2_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p2_a162);
    ddp_party_search_rec.declared_ethnicity := p2_a163;
    ddp_party_search_rec.gender := p2_a164;
    ddp_party_search_rec.head_of_household_flag := p2_a165;
    ddp_party_search_rec.household_income := p2_a166;
    ddp_party_search_rec.household_size := p2_a167;
    ddp_party_search_rec.last_known_gps := p2_a168;
    ddp_party_search_rec.marital_status := p2_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a170);
    ddp_party_search_rec.middle_name_phonetic := p2_a171;
    ddp_party_search_rec.personal_income := p2_a172;
    ddp_party_search_rec.person_academic_title := p2_a173;
    ddp_party_search_rec.person_first_name := p2_a174;
    ddp_party_search_rec.person_first_name_phonetic := p2_a175;
    ddp_party_search_rec.person_identifier := p2_a176;
    ddp_party_search_rec.person_iden_type := p2_a177;
    ddp_party_search_rec.person_initials := p2_a178;
    ddp_party_search_rec.person_last_name := p2_a179;
    ddp_party_search_rec.person_last_name_phonetic := p2_a180;
    ddp_party_search_rec.person_middle_name := p2_a181;
    ddp_party_search_rec.person_name := p2_a182;
    ddp_party_search_rec.person_name_phonetic := p2_a183;
    ddp_party_search_rec.person_name_suffix := p2_a184;
    ddp_party_search_rec.person_previous_last_name := p2_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p2_a186;
    ddp_party_search_rec.person_title := p2_a187;
    ddp_party_search_rec.place_of_birth := p2_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p5_a0
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
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.find_persons(p_init_msg_list,
      p_rule_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure get_matching_party_sites_4(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_4000
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_2000
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_4000
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_2000
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_VARCHAR2_TABLE_2000
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p4_a0
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
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_party_sites(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_party_site_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_matching_party_sites_5(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_4000
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_2000
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_4000
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_2000
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_VARCHAR2_TABLE_2000
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , x_search_ctx_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p4_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_party_sites(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_party_site_list,
      ddp_contact_point_list,
      x_search_ctx_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_matching_contacts_6(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_100
    , p3_a32 JTF_VARCHAR2_TABLE_4000
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_VARCHAR2_TABLE_100
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_VARCHAR2_TABLE_100
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_DATE_TABLE
    , p3_a45 JTF_DATE_TABLE
    , p3_a46 JTF_DATE_TABLE
    , p3_a47 JTF_DATE_TABLE
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_300
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_200
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_200
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_500
    , p3_a60 JTF_VARCHAR2_TABLE_400
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_200
    , p3_a63 JTF_VARCHAR2_TABLE_100
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p3_a66 JTF_VARCHAR2_TABLE_100
    , p3_a67 JTF_VARCHAR2_TABLE_100
    , p3_a68 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_4000
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_2000
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_4000
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_2000
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_VARCHAR2_TABLE_2000
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p4_a0
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
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_contacts(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_contact_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_matching_contacts_7(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_100
    , p3_a32 JTF_VARCHAR2_TABLE_4000
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_VARCHAR2_TABLE_100
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_VARCHAR2_TABLE_100
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_DATE_TABLE
    , p3_a45 JTF_DATE_TABLE
    , p3_a46 JTF_DATE_TABLE
    , p3_a47 JTF_DATE_TABLE
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_300
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_200
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_200
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_500
    , p3_a60 JTF_VARCHAR2_TABLE_400
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_200
    , p3_a63 JTF_VARCHAR2_TABLE_100
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p3_a66 JTF_VARCHAR2_TABLE_100
    , p3_a67 JTF_VARCHAR2_TABLE_100
    , p3_a68 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_4000
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_2000
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_4000
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_2000
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_VARCHAR2_TABLE_2000
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , x_search_ctx_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p4_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_contacts(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_contact_list,
      ddp_contact_point_list,
      x_search_ctx_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_matching_contact_points_8(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_100
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_VARCHAR2_TABLE_100
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_VARCHAR2_TABLE_100
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_NUMBER_TABLE
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_2000
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_4000
    , p3_a44 JTF_DATE_TABLE
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_2000
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_NUMBER_TABLE
    , p3_a56 JTF_VARCHAR2_TABLE_2000
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p3_a0
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
      );








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_contact_points(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure get_matching_contact_points_9(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_100
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_VARCHAR2_TABLE_100
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_VARCHAR2_TABLE_100
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_NUMBER_TABLE
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_2000
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_4000
    , p3_a44 JTF_DATE_TABLE
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_2000
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_NUMBER_TABLE
    , p3_a56 JTF_VARCHAR2_TABLE_2000
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , x_search_ctx_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p3_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_matching_contact_points(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_contact_point_list,
      x_search_ctx_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_party_score_details_10(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p_search_ctx_id  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  DATE
    , p4_a37  DATE
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  NUMBER
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  VARCHAR2
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  DATE
    , p4_a61  NUMBER
    , p4_a62  NUMBER
    , p4_a63  NUMBER
    , p4_a64  VARCHAR2
    , p4_a65  NUMBER
    , p4_a66  DATE
    , p4_a67  VARCHAR2
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  NUMBER
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  VARCHAR2
    , p4_a77  VARCHAR2
    , p4_a78  NUMBER
    , p4_a79  NUMBER
    , p4_a80  VARCHAR2
    , p4_a81  VARCHAR2
    , p4_a82  VARCHAR2
    , p4_a83  VARCHAR2
    , p4_a84  VARCHAR2
    , p4_a85  VARCHAR2
    , p4_a86  VARCHAR2
    , p4_a87  VARCHAR2
    , p4_a88  VARCHAR2
    , p4_a89  VARCHAR2
    , p4_a90  DATE
    , p4_a91  NUMBER
    , p4_a92  VARCHAR2
    , p4_a93  VARCHAR2
    , p4_a94  VARCHAR2
    , p4_a95  VARCHAR2
    , p4_a96  NUMBER
    , p4_a97  VARCHAR2
    , p4_a98  VARCHAR2
    , p4_a99  NUMBER
    , p4_a100  VARCHAR2
    , p4_a101  VARCHAR2
    , p4_a102  VARCHAR2
    , p4_a103  VARCHAR2
    , p4_a104  VARCHAR2
    , p4_a105  VARCHAR2
    , p4_a106  VARCHAR2
    , p4_a107  VARCHAR2
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  VARCHAR2
    , p4_a113  VARCHAR2
    , p4_a114  VARCHAR2
    , p4_a115  VARCHAR2
    , p4_a116  NUMBER
    , p4_a117  VARCHAR2
    , p4_a118  VARCHAR2
    , p4_a119  NUMBER
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  VARCHAR2
    , p4_a126  VARCHAR2
    , p4_a127  VARCHAR2
    , p4_a128  VARCHAR2
    , p4_a129  VARCHAR2
    , p4_a130  VARCHAR2
    , p4_a131  VARCHAR2
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  VARCHAR2
    , p4_a136  VARCHAR2
    , p4_a137  VARCHAR2
    , p4_a138  VARCHAR2
    , p4_a139  VARCHAR2
    , p4_a140  VARCHAR2
    , p4_a141  VARCHAR2
    , p4_a142  VARCHAR2
    , p4_a143  NUMBER
    , p4_a144  VARCHAR2
    , p4_a145  NUMBER
    , p4_a146  VARCHAR2
    , p4_a147  VARCHAR2
    , p4_a148  VARCHAR2
    , p4_a149  VARCHAR2
    , p4_a150  VARCHAR2
    , p4_a151  VARCHAR2
    , p4_a152  VARCHAR2
    , p4_a153  VARCHAR2
    , p4_a154  VARCHAR2
    , p4_a155  VARCHAR2
    , p4_a156  VARCHAR2
    , p4_a157  VARCHAR2
    , p4_a158  VARCHAR2
    , p4_a159  DATE
    , p4_a160  DATE
    , p4_a161  DATE
    , p4_a162  DATE
    , p4_a163  VARCHAR2
    , p4_a164  VARCHAR2
    , p4_a165  VARCHAR2
    , p4_a166  NUMBER
    , p4_a167  NUMBER
    , p4_a168  VARCHAR2
    , p4_a169  VARCHAR2
    , p4_a170  DATE
    , p4_a171  VARCHAR2
    , p4_a172  NUMBER
    , p4_a173  VARCHAR2
    , p4_a174  VARCHAR2
    , p4_a175  VARCHAR2
    , p4_a176  VARCHAR2
    , p4_a177  VARCHAR2
    , p4_a178  VARCHAR2
    , p4_a179  VARCHAR2
    , p4_a180  VARCHAR2
    , p4_a181  VARCHAR2
    , p4_a182  VARCHAR2
    , p4_a183  VARCHAR2
    , p4_a184  VARCHAR2
    , p4_a185  VARCHAR2
    , p4_a186  VARCHAR2
    , p4_a187  VARCHAR2
    , p4_a188  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_4000
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_4000
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_VARCHAR2_TABLE_300
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_600
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_300
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_VARCHAR2_TABLE_4000
    , p6_a1 JTF_VARCHAR2_TABLE_4000
    , p6_a2 JTF_VARCHAR2_TABLE_4000
    , p6_a3 JTF_VARCHAR2_TABLE_4000
    , p6_a4 JTF_VARCHAR2_TABLE_4000
    , p6_a5 JTF_VARCHAR2_TABLE_4000
    , p6_a6 JTF_VARCHAR2_TABLE_4000
    , p6_a7 JTF_VARCHAR2_TABLE_4000
    , p6_a8 JTF_VARCHAR2_TABLE_4000
    , p6_a9 JTF_VARCHAR2_TABLE_4000
    , p6_a10 JTF_VARCHAR2_TABLE_4000
    , p6_a11 JTF_VARCHAR2_TABLE_4000
    , p6_a12 JTF_VARCHAR2_TABLE_4000
    , p6_a13 JTF_VARCHAR2_TABLE_4000
    , p6_a14 JTF_VARCHAR2_TABLE_4000
    , p6_a15 JTF_VARCHAR2_TABLE_4000
    , p6_a16 JTF_VARCHAR2_TABLE_4000
    , p6_a17 JTF_VARCHAR2_TABLE_4000
    , p6_a18 JTF_VARCHAR2_TABLE_4000
    , p6_a19 JTF_VARCHAR2_TABLE_4000
    , p6_a20 JTF_VARCHAR2_TABLE_4000
    , p6_a21 JTF_VARCHAR2_TABLE_4000
    , p6_a22 JTF_VARCHAR2_TABLE_4000
    , p6_a23 JTF_VARCHAR2_TABLE_4000
    , p6_a24 JTF_VARCHAR2_TABLE_4000
    , p6_a25 JTF_VARCHAR2_TABLE_4000
    , p6_a26 JTF_VARCHAR2_TABLE_4000
    , p6_a27 JTF_VARCHAR2_TABLE_4000
    , p6_a28 JTF_VARCHAR2_TABLE_4000
    , p6_a29 JTF_VARCHAR2_TABLE_4000
    , p6_a30 JTF_VARCHAR2_TABLE_4000
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_VARCHAR2_TABLE_4000
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_VARCHAR2_TABLE_100
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_100
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_100
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p6_a43 JTF_VARCHAR2_TABLE_100
    , p6_a44 JTF_DATE_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_VARCHAR2_TABLE_100
    , p6_a49 JTF_VARCHAR2_TABLE_300
    , p6_a50 JTF_VARCHAR2_TABLE_100
    , p6_a51 JTF_VARCHAR2_TABLE_200
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_VARCHAR2_TABLE_100
    , p6_a54 JTF_VARCHAR2_TABLE_100
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_200
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_500
    , p6_a60 JTF_VARCHAR2_TABLE_400
    , p6_a61 JTF_VARCHAR2_TABLE_100
    , p6_a62 JTF_VARCHAR2_TABLE_200
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_VARCHAR2_TABLE_100
    , p6_a68 JTF_VARCHAR2_TABLE_100
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_4000
    , p7_a2 JTF_VARCHAR2_TABLE_4000
    , p7_a3 JTF_VARCHAR2_TABLE_4000
    , p7_a4 JTF_VARCHAR2_TABLE_4000
    , p7_a5 JTF_VARCHAR2_TABLE_4000
    , p7_a6 JTF_VARCHAR2_TABLE_4000
    , p7_a7 JTF_VARCHAR2_TABLE_4000
    , p7_a8 JTF_VARCHAR2_TABLE_4000
    , p7_a9 JTF_VARCHAR2_TABLE_4000
    , p7_a10 JTF_VARCHAR2_TABLE_4000
    , p7_a11 JTF_VARCHAR2_TABLE_4000
    , p7_a12 JTF_VARCHAR2_TABLE_4000
    , p7_a13 JTF_VARCHAR2_TABLE_4000
    , p7_a14 JTF_VARCHAR2_TABLE_4000
    , p7_a15 JTF_VARCHAR2_TABLE_4000
    , p7_a16 JTF_VARCHAR2_TABLE_4000
    , p7_a17 JTF_VARCHAR2_TABLE_4000
    , p7_a18 JTF_VARCHAR2_TABLE_4000
    , p7_a19 JTF_VARCHAR2_TABLE_4000
    , p7_a20 JTF_VARCHAR2_TABLE_4000
    , p7_a21 JTF_VARCHAR2_TABLE_4000
    , p7_a22 JTF_VARCHAR2_TABLE_4000
    , p7_a23 JTF_VARCHAR2_TABLE_4000
    , p7_a24 JTF_VARCHAR2_TABLE_4000
    , p7_a25 JTF_VARCHAR2_TABLE_4000
    , p7_a26 JTF_VARCHAR2_TABLE_4000
    , p7_a27 JTF_VARCHAR2_TABLE_4000
    , p7_a28 JTF_VARCHAR2_TABLE_4000
    , p7_a29 JTF_VARCHAR2_TABLE_4000
    , p7_a30 JTF_VARCHAR2_TABLE_4000
    , p7_a31 JTF_VARCHAR2_TABLE_4000
    , p7_a32 JTF_VARCHAR2_TABLE_100
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_VARCHAR2_TABLE_100
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_VARCHAR2_TABLE_100
    , p7_a41 JTF_VARCHAR2_TABLE_2000
    , p7_a42 JTF_VARCHAR2_TABLE_100
    , p7_a43 JTF_VARCHAR2_TABLE_4000
    , p7_a44 JTF_DATE_TABLE
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_VARCHAR2_TABLE_100
    , p7_a48 JTF_VARCHAR2_TABLE_100
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_VARCHAR2_TABLE_100
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_VARCHAR2_TABLE_2000
    , p7_a53 JTF_VARCHAR2_TABLE_100
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_VARCHAR2_TABLE_2000
    , p7_a57 JTF_VARCHAR2_TABLE_100
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_party_search_rec.all_account_names := p4_a0;
    ddp_party_search_rec.all_account_numbers := p4_a1;
    ddp_party_search_rec.domain_name := p4_a2;
    ddp_party_search_rec.party_source_system_ref := p4_a3;
    ddp_party_search_rec.custom_attribute1 := p4_a4;
    ddp_party_search_rec.custom_attribute10 := p4_a5;
    ddp_party_search_rec.custom_attribute11 := p4_a6;
    ddp_party_search_rec.custom_attribute12 := p4_a7;
    ddp_party_search_rec.custom_attribute13 := p4_a8;
    ddp_party_search_rec.custom_attribute14 := p4_a9;
    ddp_party_search_rec.custom_attribute15 := p4_a10;
    ddp_party_search_rec.custom_attribute16 := p4_a11;
    ddp_party_search_rec.custom_attribute17 := p4_a12;
    ddp_party_search_rec.custom_attribute18 := p4_a13;
    ddp_party_search_rec.custom_attribute19 := p4_a14;
    ddp_party_search_rec.custom_attribute2 := p4_a15;
    ddp_party_search_rec.custom_attribute20 := p4_a16;
    ddp_party_search_rec.custom_attribute21 := p4_a17;
    ddp_party_search_rec.custom_attribute22 := p4_a18;
    ddp_party_search_rec.custom_attribute23 := p4_a19;
    ddp_party_search_rec.custom_attribute24 := p4_a20;
    ddp_party_search_rec.custom_attribute25 := p4_a21;
    ddp_party_search_rec.custom_attribute26 := p4_a22;
    ddp_party_search_rec.custom_attribute27 := p4_a23;
    ddp_party_search_rec.custom_attribute28 := p4_a24;
    ddp_party_search_rec.custom_attribute29 := p4_a25;
    ddp_party_search_rec.custom_attribute3 := p4_a26;
    ddp_party_search_rec.custom_attribute30 := p4_a27;
    ddp_party_search_rec.custom_attribute4 := p4_a28;
    ddp_party_search_rec.custom_attribute5 := p4_a29;
    ddp_party_search_rec.custom_attribute6 := p4_a30;
    ddp_party_search_rec.custom_attribute7 := p4_a31;
    ddp_party_search_rec.custom_attribute8 := p4_a32;
    ddp_party_search_rec.custom_attribute9 := p4_a33;
    ddp_party_search_rec.analysis_fy := p4_a34;
    ddp_party_search_rec.avg_high_credit := p4_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p4_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p4_a37);
    ddp_party_search_rec.branch_flag := p4_a38;
    ddp_party_search_rec.business_scope := p4_a39;
    ddp_party_search_rec.ceo_name := p4_a40;
    ddp_party_search_rec.ceo_title := p4_a41;
    ddp_party_search_rec.cong_dist_code := p4_a42;
    ddp_party_search_rec.content_source_number := p4_a43;
    ddp_party_search_rec.content_source_type := p4_a44;
    ddp_party_search_rec.control_yr := p4_a45;
    ddp_party_search_rec.corporation_class := p4_a46;
    ddp_party_search_rec.credit_score := p4_a47;
    ddp_party_search_rec.credit_score_age := p4_a48;
    ddp_party_search_rec.credit_score_class := p4_a49;
    ddp_party_search_rec.credit_score_commentary := p4_a50;
    ddp_party_search_rec.credit_score_commentary10 := p4_a51;
    ddp_party_search_rec.credit_score_commentary2 := p4_a52;
    ddp_party_search_rec.credit_score_commentary3 := p4_a53;
    ddp_party_search_rec.credit_score_commentary4 := p4_a54;
    ddp_party_search_rec.credit_score_commentary5 := p4_a55;
    ddp_party_search_rec.credit_score_commentary6 := p4_a56;
    ddp_party_search_rec.credit_score_commentary7 := p4_a57;
    ddp_party_search_rec.credit_score_commentary8 := p4_a58;
    ddp_party_search_rec.credit_score_commentary9 := p4_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p4_a60);
    ddp_party_search_rec.credit_score_incd_default := p4_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p4_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p4_a63;
    ddp_party_search_rec.db_rating := p4_a64;
    ddp_party_search_rec.debarments_count := p4_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p4_a66);
    ddp_party_search_rec.debarment_ind := p4_a67;
    ddp_party_search_rec.disadv_8a_ind := p4_a68;
    ddp_party_search_rec.duns_number_c := p4_a69;
    ddp_party_search_rec.employees_total := p4_a70;
    ddp_party_search_rec.emp_at_primary_adr := p4_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p4_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p4_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p4_a74;
    ddp_party_search_rec.enquiry_duns := p4_a75;
    ddp_party_search_rec.export_ind := p4_a76;
    ddp_party_search_rec.failure_score := p4_a77;
    ddp_party_search_rec.failure_score_age := p4_a78;
    ddp_party_search_rec.failure_score_class := p4_a79;
    ddp_party_search_rec.failure_score_commentary := p4_a80;
    ddp_party_search_rec.failure_score_commentary10 := p4_a81;
    ddp_party_search_rec.failure_score_commentary2 := p4_a82;
    ddp_party_search_rec.failure_score_commentary3 := p4_a83;
    ddp_party_search_rec.failure_score_commentary4 := p4_a84;
    ddp_party_search_rec.failure_score_commentary5 := p4_a85;
    ddp_party_search_rec.failure_score_commentary6 := p4_a86;
    ddp_party_search_rec.failure_score_commentary7 := p4_a87;
    ddp_party_search_rec.failure_score_commentary8 := p4_a88;
    ddp_party_search_rec.failure_score_commentary9 := p4_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p4_a90);
    ddp_party_search_rec.failure_score_incd_default := p4_a91;
    ddp_party_search_rec.failure_score_override_code := p4_a92;
    ddp_party_search_rec.fiscal_yearend_month := p4_a93;
    ddp_party_search_rec.global_failure_score := p4_a94;
    ddp_party_search_rec.gsa_indicator_flag := p4_a95;
    ddp_party_search_rec.high_credit := p4_a96;
    ddp_party_search_rec.hq_branch_ind := p4_a97;
    ddp_party_search_rec.import_ind := p4_a98;
    ddp_party_search_rec.incorp_year := p4_a99;
    ddp_party_search_rec.internal_flag := p4_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p4_a101;
    ddp_party_search_rec.party_all_names := p4_a102;
    ddp_party_search_rec.known_as := p4_a103;
    ddp_party_search_rec.known_as2 := p4_a104;
    ddp_party_search_rec.known_as3 := p4_a105;
    ddp_party_search_rec.known_as4 := p4_a106;
    ddp_party_search_rec.known_as5 := p4_a107;
    ddp_party_search_rec.labor_surplus_ind := p4_a108;
    ddp_party_search_rec.legal_status := p4_a109;
    ddp_party_search_rec.line_of_business := p4_a110;
    ddp_party_search_rec.local_activity_code := p4_a111;
    ddp_party_search_rec.local_activity_code_type := p4_a112;
    ddp_party_search_rec.local_bus_identifier := p4_a113;
    ddp_party_search_rec.local_bus_iden_type := p4_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p4_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p4_a116;
    ddp_party_search_rec.minority_owned_ind := p4_a117;
    ddp_party_search_rec.minority_owned_type := p4_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p4_a119;
    ddp_party_search_rec.oob_ind := p4_a120;
    ddp_party_search_rec.organization_name := p4_a121;
    ddp_party_search_rec.organization_name_phonetic := p4_a122;
    ddp_party_search_rec.organization_type := p4_a123;
    ddp_party_search_rec.parent_sub_ind := p4_a124;
    ddp_party_search_rec.paydex_norm := p4_a125;
    ddp_party_search_rec.paydex_score := p4_a126;
    ddp_party_search_rec.paydex_three_months_ago := p4_a127;
    ddp_party_search_rec.pref_functional_currency := p4_a128;
    ddp_party_search_rec.principal_name := p4_a129;
    ddp_party_search_rec.principal_title := p4_a130;
    ddp_party_search_rec.public_private_ownership_flag := p4_a131;
    ddp_party_search_rec.registration_type := p4_a132;
    ddp_party_search_rec.rent_own_ind := p4_a133;
    ddp_party_search_rec.sic_code := p4_a134;
    ddp_party_search_rec.sic_code_type := p4_a135;
    ddp_party_search_rec.small_bus_ind := p4_a136;
    ddp_party_search_rec.tax_name := p4_a137;
    ddp_party_search_rec.tax_reference := p4_a138;
    ddp_party_search_rec.total_employees_text := p4_a139;
    ddp_party_search_rec.total_emp_est_ind := p4_a140;
    ddp_party_search_rec.total_emp_min_ind := p4_a141;
    ddp_party_search_rec.total_employees_ind := p4_a142;
    ddp_party_search_rec.total_payments := p4_a143;
    ddp_party_search_rec.woman_owned_ind := p4_a144;
    ddp_party_search_rec.year_established := p4_a145;
    ddp_party_search_rec.category_code := p4_a146;
    ddp_party_search_rec.competitor_flag := p4_a147;
    ddp_party_search_rec.do_not_mail_flag := p4_a148;
    ddp_party_search_rec.group_type := p4_a149;
    ddp_party_search_rec.language_name := p4_a150;
    ddp_party_search_rec.party_name := p4_a151;
    ddp_party_search_rec.party_number := p4_a152;
    ddp_party_search_rec.party_type := p4_a153;
    ddp_party_search_rec.reference_use_flag := p4_a154;
    ddp_party_search_rec.salutation := p4_a155;
    ddp_party_search_rec.status := p4_a156;
    ddp_party_search_rec.third_party_flag := p4_a157;
    ddp_party_search_rec.validated_flag := p4_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p4_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p4_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p4_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p4_a162);
    ddp_party_search_rec.declared_ethnicity := p4_a163;
    ddp_party_search_rec.gender := p4_a164;
    ddp_party_search_rec.head_of_household_flag := p4_a165;
    ddp_party_search_rec.household_income := p4_a166;
    ddp_party_search_rec.household_size := p4_a167;
    ddp_party_search_rec.last_known_gps := p4_a168;
    ddp_party_search_rec.marital_status := p4_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p4_a170);
    ddp_party_search_rec.middle_name_phonetic := p4_a171;
    ddp_party_search_rec.personal_income := p4_a172;
    ddp_party_search_rec.person_academic_title := p4_a173;
    ddp_party_search_rec.person_first_name := p4_a174;
    ddp_party_search_rec.person_first_name_phonetic := p4_a175;
    ddp_party_search_rec.person_identifier := p4_a176;
    ddp_party_search_rec.person_iden_type := p4_a177;
    ddp_party_search_rec.person_initials := p4_a178;
    ddp_party_search_rec.person_last_name := p4_a179;
    ddp_party_search_rec.person_last_name_phonetic := p4_a180;
    ddp_party_search_rec.person_middle_name := p4_a181;
    ddp_party_search_rec.person_name := p4_a182;
    ddp_party_search_rec.person_name_phonetic := p4_a183;
    ddp_party_search_rec.person_name_suffix := p4_a184;
    ddp_party_search_rec.person_previous_last_name := p4_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p4_a186;
    ddp_party_search_rec.person_title := p4_a187;
    ddp_party_search_rec.place_of_birth := p4_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p5_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p6_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_party_score_details(p_init_msg_list,
      p_rule_id,
      p_party_id,
      p_search_ctx_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure get_score_details_11(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  DATE
    , p3_a61  NUMBER
    , p3_a62  NUMBER
    , p3_a63  NUMBER
    , p3_a64  VARCHAR2
    , p3_a65  NUMBER
    , p3_a66  DATE
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  NUMBER
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  NUMBER
    , p3_a79  NUMBER
    , p3_a80  VARCHAR2
    , p3_a81  VARCHAR2
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  DATE
    , p3_a91  NUMBER
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  NUMBER
    , p3_a97  VARCHAR2
    , p3_a98  VARCHAR2
    , p3_a99  NUMBER
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  VARCHAR2
    , p3_a106  VARCHAR2
    , p3_a107  VARCHAR2
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  VARCHAR2
    , p3_a113  VARCHAR2
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  NUMBER
    , p3_a117  VARCHAR2
    , p3_a118  VARCHAR2
    , p3_a119  NUMBER
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  VARCHAR2
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  VARCHAR2
    , p3_a129  VARCHAR2
    , p3_a130  VARCHAR2
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  VARCHAR2
    , p3_a136  VARCHAR2
    , p3_a137  VARCHAR2
    , p3_a138  VARCHAR2
    , p3_a139  VARCHAR2
    , p3_a140  VARCHAR2
    , p3_a141  VARCHAR2
    , p3_a142  VARCHAR2
    , p3_a143  NUMBER
    , p3_a144  VARCHAR2
    , p3_a145  NUMBER
    , p3_a146  VARCHAR2
    , p3_a147  VARCHAR2
    , p3_a148  VARCHAR2
    , p3_a149  VARCHAR2
    , p3_a150  VARCHAR2
    , p3_a151  VARCHAR2
    , p3_a152  VARCHAR2
    , p3_a153  VARCHAR2
    , p3_a154  VARCHAR2
    , p3_a155  VARCHAR2
    , p3_a156  VARCHAR2
    , p3_a157  VARCHAR2
    , p3_a158  VARCHAR2
    , p3_a159  DATE
    , p3_a160  DATE
    , p3_a161  DATE
    , p3_a162  DATE
    , p3_a163  VARCHAR2
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  NUMBER
    , p3_a167  NUMBER
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p3_a170  DATE
    , p3_a171  VARCHAR2
    , p3_a172  NUMBER
    , p3_a173  VARCHAR2
    , p3_a174  VARCHAR2
    , p3_a175  VARCHAR2
    , p3_a176  VARCHAR2
    , p3_a177  VARCHAR2
    , p3_a178  VARCHAR2
    , p3_a179  VARCHAR2
    , p3_a180  VARCHAR2
    , p3_a181  VARCHAR2
    , p3_a182  VARCHAR2
    , p3_a183  VARCHAR2
    , p3_a184  VARCHAR2
    , p3_a185  VARCHAR2
    , p3_a186  VARCHAR2
    , p3_a187  VARCHAR2
    , p3_a188  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_4000
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_4000
    , p4_a32 JTF_VARCHAR2_TABLE_300
    , p4_a33 JTF_VARCHAR2_TABLE_300
    , p4_a34 JTF_VARCHAR2_TABLE_300
    , p4_a35 JTF_VARCHAR2_TABLE_300
    , p4_a36 JTF_DATE_TABLE
    , p4_a37 JTF_DATE_TABLE
    , p4_a38 JTF_VARCHAR2_TABLE_600
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_VARCHAR2_TABLE_100
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_100
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_VARCHAR2_TABLE_100
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_100
    , p4_a60 JTF_VARCHAR2_TABLE_100
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_100
    , p4_a63 JTF_VARCHAR2_TABLE_300
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_VARCHAR2_TABLE_4000
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_4000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_300
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_400
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_4000
    , p6_a2 JTF_VARCHAR2_TABLE_4000
    , p6_a3 JTF_VARCHAR2_TABLE_4000
    , p6_a4 JTF_VARCHAR2_TABLE_4000
    , p6_a5 JTF_VARCHAR2_TABLE_4000
    , p6_a6 JTF_VARCHAR2_TABLE_4000
    , p6_a7 JTF_VARCHAR2_TABLE_4000
    , p6_a8 JTF_VARCHAR2_TABLE_4000
    , p6_a9 JTF_VARCHAR2_TABLE_4000
    , p6_a10 JTF_VARCHAR2_TABLE_4000
    , p6_a11 JTF_VARCHAR2_TABLE_4000
    , p6_a12 JTF_VARCHAR2_TABLE_4000
    , p6_a13 JTF_VARCHAR2_TABLE_4000
    , p6_a14 JTF_VARCHAR2_TABLE_4000
    , p6_a15 JTF_VARCHAR2_TABLE_4000
    , p6_a16 JTF_VARCHAR2_TABLE_4000
    , p6_a17 JTF_VARCHAR2_TABLE_4000
    , p6_a18 JTF_VARCHAR2_TABLE_4000
    , p6_a19 JTF_VARCHAR2_TABLE_4000
    , p6_a20 JTF_VARCHAR2_TABLE_4000
    , p6_a21 JTF_VARCHAR2_TABLE_4000
    , p6_a22 JTF_VARCHAR2_TABLE_4000
    , p6_a23 JTF_VARCHAR2_TABLE_4000
    , p6_a24 JTF_VARCHAR2_TABLE_4000
    , p6_a25 JTF_VARCHAR2_TABLE_4000
    , p6_a26 JTF_VARCHAR2_TABLE_4000
    , p6_a27 JTF_VARCHAR2_TABLE_4000
    , p6_a28 JTF_VARCHAR2_TABLE_4000
    , p6_a29 JTF_VARCHAR2_TABLE_4000
    , p6_a30 JTF_VARCHAR2_TABLE_4000
    , p6_a31 JTF_VARCHAR2_TABLE_4000
    , p6_a32 JTF_VARCHAR2_TABLE_100
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_VARCHAR2_TABLE_100
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_100
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_2000
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p6_a43 JTF_VARCHAR2_TABLE_4000
    , p6_a44 JTF_DATE_TABLE
    , p6_a45 JTF_VARCHAR2_TABLE_100
    , p6_a46 JTF_VARCHAR2_TABLE_100
    , p6_a47 JTF_VARCHAR2_TABLE_100
    , p6_a48 JTF_VARCHAR2_TABLE_100
    , p6_a49 JTF_VARCHAR2_TABLE_100
    , p6_a50 JTF_VARCHAR2_TABLE_100
    , p6_a51 JTF_VARCHAR2_TABLE_100
    , p6_a52 JTF_VARCHAR2_TABLE_2000
    , p6_a53 JTF_VARCHAR2_TABLE_100
    , p6_a54 JTF_VARCHAR2_TABLE_100
    , p6_a55 JTF_NUMBER_TABLE
    , p6_a56 JTF_VARCHAR2_TABLE_2000
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , x_search_ctx_id in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_party_search_rec.all_account_names := p3_a0;
    ddp_party_search_rec.all_account_numbers := p3_a1;
    ddp_party_search_rec.domain_name := p3_a2;
    ddp_party_search_rec.party_source_system_ref := p3_a3;
    ddp_party_search_rec.custom_attribute1 := p3_a4;
    ddp_party_search_rec.custom_attribute10 := p3_a5;
    ddp_party_search_rec.custom_attribute11 := p3_a6;
    ddp_party_search_rec.custom_attribute12 := p3_a7;
    ddp_party_search_rec.custom_attribute13 := p3_a8;
    ddp_party_search_rec.custom_attribute14 := p3_a9;
    ddp_party_search_rec.custom_attribute15 := p3_a10;
    ddp_party_search_rec.custom_attribute16 := p3_a11;
    ddp_party_search_rec.custom_attribute17 := p3_a12;
    ddp_party_search_rec.custom_attribute18 := p3_a13;
    ddp_party_search_rec.custom_attribute19 := p3_a14;
    ddp_party_search_rec.custom_attribute2 := p3_a15;
    ddp_party_search_rec.custom_attribute20 := p3_a16;
    ddp_party_search_rec.custom_attribute21 := p3_a17;
    ddp_party_search_rec.custom_attribute22 := p3_a18;
    ddp_party_search_rec.custom_attribute23 := p3_a19;
    ddp_party_search_rec.custom_attribute24 := p3_a20;
    ddp_party_search_rec.custom_attribute25 := p3_a21;
    ddp_party_search_rec.custom_attribute26 := p3_a22;
    ddp_party_search_rec.custom_attribute27 := p3_a23;
    ddp_party_search_rec.custom_attribute28 := p3_a24;
    ddp_party_search_rec.custom_attribute29 := p3_a25;
    ddp_party_search_rec.custom_attribute3 := p3_a26;
    ddp_party_search_rec.custom_attribute30 := p3_a27;
    ddp_party_search_rec.custom_attribute4 := p3_a28;
    ddp_party_search_rec.custom_attribute5 := p3_a29;
    ddp_party_search_rec.custom_attribute6 := p3_a30;
    ddp_party_search_rec.custom_attribute7 := p3_a31;
    ddp_party_search_rec.custom_attribute8 := p3_a32;
    ddp_party_search_rec.custom_attribute9 := p3_a33;
    ddp_party_search_rec.analysis_fy := p3_a34;
    ddp_party_search_rec.avg_high_credit := p3_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p3_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p3_a37);
    ddp_party_search_rec.branch_flag := p3_a38;
    ddp_party_search_rec.business_scope := p3_a39;
    ddp_party_search_rec.ceo_name := p3_a40;
    ddp_party_search_rec.ceo_title := p3_a41;
    ddp_party_search_rec.cong_dist_code := p3_a42;
    ddp_party_search_rec.content_source_number := p3_a43;
    ddp_party_search_rec.content_source_type := p3_a44;
    ddp_party_search_rec.control_yr := p3_a45;
    ddp_party_search_rec.corporation_class := p3_a46;
    ddp_party_search_rec.credit_score := p3_a47;
    ddp_party_search_rec.credit_score_age := p3_a48;
    ddp_party_search_rec.credit_score_class := p3_a49;
    ddp_party_search_rec.credit_score_commentary := p3_a50;
    ddp_party_search_rec.credit_score_commentary10 := p3_a51;
    ddp_party_search_rec.credit_score_commentary2 := p3_a52;
    ddp_party_search_rec.credit_score_commentary3 := p3_a53;
    ddp_party_search_rec.credit_score_commentary4 := p3_a54;
    ddp_party_search_rec.credit_score_commentary5 := p3_a55;
    ddp_party_search_rec.credit_score_commentary6 := p3_a56;
    ddp_party_search_rec.credit_score_commentary7 := p3_a57;
    ddp_party_search_rec.credit_score_commentary8 := p3_a58;
    ddp_party_search_rec.credit_score_commentary9 := p3_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p3_a60);
    ddp_party_search_rec.credit_score_incd_default := p3_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p3_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p3_a63;
    ddp_party_search_rec.db_rating := p3_a64;
    ddp_party_search_rec.debarments_count := p3_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p3_a66);
    ddp_party_search_rec.debarment_ind := p3_a67;
    ddp_party_search_rec.disadv_8a_ind := p3_a68;
    ddp_party_search_rec.duns_number_c := p3_a69;
    ddp_party_search_rec.employees_total := p3_a70;
    ddp_party_search_rec.emp_at_primary_adr := p3_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p3_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p3_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p3_a74;
    ddp_party_search_rec.enquiry_duns := p3_a75;
    ddp_party_search_rec.export_ind := p3_a76;
    ddp_party_search_rec.failure_score := p3_a77;
    ddp_party_search_rec.failure_score_age := p3_a78;
    ddp_party_search_rec.failure_score_class := p3_a79;
    ddp_party_search_rec.failure_score_commentary := p3_a80;
    ddp_party_search_rec.failure_score_commentary10 := p3_a81;
    ddp_party_search_rec.failure_score_commentary2 := p3_a82;
    ddp_party_search_rec.failure_score_commentary3 := p3_a83;
    ddp_party_search_rec.failure_score_commentary4 := p3_a84;
    ddp_party_search_rec.failure_score_commentary5 := p3_a85;
    ddp_party_search_rec.failure_score_commentary6 := p3_a86;
    ddp_party_search_rec.failure_score_commentary7 := p3_a87;
    ddp_party_search_rec.failure_score_commentary8 := p3_a88;
    ddp_party_search_rec.failure_score_commentary9 := p3_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p3_a90);
    ddp_party_search_rec.failure_score_incd_default := p3_a91;
    ddp_party_search_rec.failure_score_override_code := p3_a92;
    ddp_party_search_rec.fiscal_yearend_month := p3_a93;
    ddp_party_search_rec.global_failure_score := p3_a94;
    ddp_party_search_rec.gsa_indicator_flag := p3_a95;
    ddp_party_search_rec.high_credit := p3_a96;
    ddp_party_search_rec.hq_branch_ind := p3_a97;
    ddp_party_search_rec.import_ind := p3_a98;
    ddp_party_search_rec.incorp_year := p3_a99;
    ddp_party_search_rec.internal_flag := p3_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p3_a101;
    ddp_party_search_rec.party_all_names := p3_a102;
    ddp_party_search_rec.known_as := p3_a103;
    ddp_party_search_rec.known_as2 := p3_a104;
    ddp_party_search_rec.known_as3 := p3_a105;
    ddp_party_search_rec.known_as4 := p3_a106;
    ddp_party_search_rec.known_as5 := p3_a107;
    ddp_party_search_rec.labor_surplus_ind := p3_a108;
    ddp_party_search_rec.legal_status := p3_a109;
    ddp_party_search_rec.line_of_business := p3_a110;
    ddp_party_search_rec.local_activity_code := p3_a111;
    ddp_party_search_rec.local_activity_code_type := p3_a112;
    ddp_party_search_rec.local_bus_identifier := p3_a113;
    ddp_party_search_rec.local_bus_iden_type := p3_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p3_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p3_a116;
    ddp_party_search_rec.minority_owned_ind := p3_a117;
    ddp_party_search_rec.minority_owned_type := p3_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p3_a119;
    ddp_party_search_rec.oob_ind := p3_a120;
    ddp_party_search_rec.organization_name := p3_a121;
    ddp_party_search_rec.organization_name_phonetic := p3_a122;
    ddp_party_search_rec.organization_type := p3_a123;
    ddp_party_search_rec.parent_sub_ind := p3_a124;
    ddp_party_search_rec.paydex_norm := p3_a125;
    ddp_party_search_rec.paydex_score := p3_a126;
    ddp_party_search_rec.paydex_three_months_ago := p3_a127;
    ddp_party_search_rec.pref_functional_currency := p3_a128;
    ddp_party_search_rec.principal_name := p3_a129;
    ddp_party_search_rec.principal_title := p3_a130;
    ddp_party_search_rec.public_private_ownership_flag := p3_a131;
    ddp_party_search_rec.registration_type := p3_a132;
    ddp_party_search_rec.rent_own_ind := p3_a133;
    ddp_party_search_rec.sic_code := p3_a134;
    ddp_party_search_rec.sic_code_type := p3_a135;
    ddp_party_search_rec.small_bus_ind := p3_a136;
    ddp_party_search_rec.tax_name := p3_a137;
    ddp_party_search_rec.tax_reference := p3_a138;
    ddp_party_search_rec.total_employees_text := p3_a139;
    ddp_party_search_rec.total_emp_est_ind := p3_a140;
    ddp_party_search_rec.total_emp_min_ind := p3_a141;
    ddp_party_search_rec.total_employees_ind := p3_a142;
    ddp_party_search_rec.total_payments := p3_a143;
    ddp_party_search_rec.woman_owned_ind := p3_a144;
    ddp_party_search_rec.year_established := p3_a145;
    ddp_party_search_rec.category_code := p3_a146;
    ddp_party_search_rec.competitor_flag := p3_a147;
    ddp_party_search_rec.do_not_mail_flag := p3_a148;
    ddp_party_search_rec.group_type := p3_a149;
    ddp_party_search_rec.language_name := p3_a150;
    ddp_party_search_rec.party_name := p3_a151;
    ddp_party_search_rec.party_number := p3_a152;
    ddp_party_search_rec.party_type := p3_a153;
    ddp_party_search_rec.reference_use_flag := p3_a154;
    ddp_party_search_rec.salutation := p3_a155;
    ddp_party_search_rec.status := p3_a156;
    ddp_party_search_rec.third_party_flag := p3_a157;
    ddp_party_search_rec.validated_flag := p3_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p3_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p3_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p3_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p3_a162);
    ddp_party_search_rec.declared_ethnicity := p3_a163;
    ddp_party_search_rec.gender := p3_a164;
    ddp_party_search_rec.head_of_household_flag := p3_a165;
    ddp_party_search_rec.household_income := p3_a166;
    ddp_party_search_rec.household_size := p3_a167;
    ddp_party_search_rec.last_known_gps := p3_a168;
    ddp_party_search_rec.marital_status := p3_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p3_a170);
    ddp_party_search_rec.middle_name_phonetic := p3_a171;
    ddp_party_search_rec.personal_income := p3_a172;
    ddp_party_search_rec.person_academic_title := p3_a173;
    ddp_party_search_rec.person_first_name := p3_a174;
    ddp_party_search_rec.person_first_name_phonetic := p3_a175;
    ddp_party_search_rec.person_identifier := p3_a176;
    ddp_party_search_rec.person_iden_type := p3_a177;
    ddp_party_search_rec.person_initials := p3_a178;
    ddp_party_search_rec.person_last_name := p3_a179;
    ddp_party_search_rec.person_last_name_phonetic := p3_a180;
    ddp_party_search_rec.person_middle_name := p3_a181;
    ddp_party_search_rec.person_name := p3_a182;
    ddp_party_search_rec.person_name_phonetic := p3_a183;
    ddp_party_search_rec.person_name_suffix := p3_a184;
    ddp_party_search_rec.person_previous_last_name := p3_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p3_a186;
    ddp_party_search_rec.person_title := p3_a187;
    ddp_party_search_rec.place_of_birth := p3_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p5_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p6_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_score_details(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      x_search_ctx_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure find_party_details_12(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  DATE
    , p2_a37  DATE
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  NUMBER
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  NUMBER
    , p2_a49  NUMBER
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  VARCHAR2
    , p2_a60  DATE
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  VARCHAR2
    , p2_a65  NUMBER
    , p2_a66  DATE
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  NUMBER
    , p2_a79  NUMBER
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  DATE
    , p2_a91  NUMBER
    , p2_a92  VARCHAR2
    , p2_a93  VARCHAR2
    , p2_a94  VARCHAR2
    , p2_a95  VARCHAR2
    , p2_a96  NUMBER
    , p2_a97  VARCHAR2
    , p2_a98  VARCHAR2
    , p2_a99  NUMBER
    , p2_a100  VARCHAR2
    , p2_a101  VARCHAR2
    , p2_a102  VARCHAR2
    , p2_a103  VARCHAR2
    , p2_a104  VARCHAR2
    , p2_a105  VARCHAR2
    , p2_a106  VARCHAR2
    , p2_a107  VARCHAR2
    , p2_a108  VARCHAR2
    , p2_a109  VARCHAR2
    , p2_a110  VARCHAR2
    , p2_a111  VARCHAR2
    , p2_a112  VARCHAR2
    , p2_a113  VARCHAR2
    , p2_a114  VARCHAR2
    , p2_a115  VARCHAR2
    , p2_a116  NUMBER
    , p2_a117  VARCHAR2
    , p2_a118  VARCHAR2
    , p2_a119  NUMBER
    , p2_a120  VARCHAR2
    , p2_a121  VARCHAR2
    , p2_a122  VARCHAR2
    , p2_a123  VARCHAR2
    , p2_a124  VARCHAR2
    , p2_a125  VARCHAR2
    , p2_a126  VARCHAR2
    , p2_a127  VARCHAR2
    , p2_a128  VARCHAR2
    , p2_a129  VARCHAR2
    , p2_a130  VARCHAR2
    , p2_a131  VARCHAR2
    , p2_a132  VARCHAR2
    , p2_a133  VARCHAR2
    , p2_a134  VARCHAR2
    , p2_a135  VARCHAR2
    , p2_a136  VARCHAR2
    , p2_a137  VARCHAR2
    , p2_a138  VARCHAR2
    , p2_a139  VARCHAR2
    , p2_a140  VARCHAR2
    , p2_a141  VARCHAR2
    , p2_a142  VARCHAR2
    , p2_a143  NUMBER
    , p2_a144  VARCHAR2
    , p2_a145  NUMBER
    , p2_a146  VARCHAR2
    , p2_a147  VARCHAR2
    , p2_a148  VARCHAR2
    , p2_a149  VARCHAR2
    , p2_a150  VARCHAR2
    , p2_a151  VARCHAR2
    , p2_a152  VARCHAR2
    , p2_a153  VARCHAR2
    , p2_a154  VARCHAR2
    , p2_a155  VARCHAR2
    , p2_a156  VARCHAR2
    , p2_a157  VARCHAR2
    , p2_a158  VARCHAR2
    , p2_a159  DATE
    , p2_a160  DATE
    , p2_a161  DATE
    , p2_a162  DATE
    , p2_a163  VARCHAR2
    , p2_a164  VARCHAR2
    , p2_a165  VARCHAR2
    , p2_a166  NUMBER
    , p2_a167  NUMBER
    , p2_a168  VARCHAR2
    , p2_a169  VARCHAR2
    , p2_a170  DATE
    , p2_a171  VARCHAR2
    , p2_a172  NUMBER
    , p2_a173  VARCHAR2
    , p2_a174  VARCHAR2
    , p2_a175  VARCHAR2
    , p2_a176  VARCHAR2
    , p2_a177  VARCHAR2
    , p2_a178  VARCHAR2
    , p2_a179  VARCHAR2
    , p2_a180  VARCHAR2
    , p2_a181  VARCHAR2
    , p2_a182  VARCHAR2
    , p2_a183  VARCHAR2
    , p2_a184  VARCHAR2
    , p2_a185  VARCHAR2
    , p2_a186  VARCHAR2
    , p2_a187  VARCHAR2
    , p2_a188  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_4000
    , p3_a1 JTF_VARCHAR2_TABLE_4000
    , p3_a2 JTF_VARCHAR2_TABLE_4000
    , p3_a3 JTF_VARCHAR2_TABLE_4000
    , p3_a4 JTF_VARCHAR2_TABLE_4000
    , p3_a5 JTF_VARCHAR2_TABLE_4000
    , p3_a6 JTF_VARCHAR2_TABLE_4000
    , p3_a7 JTF_VARCHAR2_TABLE_4000
    , p3_a8 JTF_VARCHAR2_TABLE_4000
    , p3_a9 JTF_VARCHAR2_TABLE_4000
    , p3_a10 JTF_VARCHAR2_TABLE_4000
    , p3_a11 JTF_VARCHAR2_TABLE_4000
    , p3_a12 JTF_VARCHAR2_TABLE_4000
    , p3_a13 JTF_VARCHAR2_TABLE_4000
    , p3_a14 JTF_VARCHAR2_TABLE_4000
    , p3_a15 JTF_VARCHAR2_TABLE_4000
    , p3_a16 JTF_VARCHAR2_TABLE_4000
    , p3_a17 JTF_VARCHAR2_TABLE_4000
    , p3_a18 JTF_VARCHAR2_TABLE_4000
    , p3_a19 JTF_VARCHAR2_TABLE_4000
    , p3_a20 JTF_VARCHAR2_TABLE_4000
    , p3_a21 JTF_VARCHAR2_TABLE_4000
    , p3_a22 JTF_VARCHAR2_TABLE_4000
    , p3_a23 JTF_VARCHAR2_TABLE_4000
    , p3_a24 JTF_VARCHAR2_TABLE_4000
    , p3_a25 JTF_VARCHAR2_TABLE_4000
    , p3_a26 JTF_VARCHAR2_TABLE_4000
    , p3_a27 JTF_VARCHAR2_TABLE_4000
    , p3_a28 JTF_VARCHAR2_TABLE_4000
    , p3_a29 JTF_VARCHAR2_TABLE_4000
    , p3_a30 JTF_VARCHAR2_TABLE_4000
    , p3_a31 JTF_VARCHAR2_TABLE_4000
    , p3_a32 JTF_VARCHAR2_TABLE_300
    , p3_a33 JTF_VARCHAR2_TABLE_300
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_300
    , p3_a36 JTF_DATE_TABLE
    , p3_a37 JTF_DATE_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_600
    , p3_a39 JTF_VARCHAR2_TABLE_100
    , p3_a40 JTF_VARCHAR2_TABLE_100
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_VARCHAR2_TABLE_100
    , p3_a44 JTF_VARCHAR2_TABLE_100
    , p3_a45 JTF_VARCHAR2_TABLE_100
    , p3_a46 JTF_VARCHAR2_TABLE_100
    , p3_a47 JTF_VARCHAR2_TABLE_100
    , p3_a48 JTF_VARCHAR2_TABLE_100
    , p3_a49 JTF_VARCHAR2_TABLE_100
    , p3_a50 JTF_VARCHAR2_TABLE_100
    , p3_a51 JTF_VARCHAR2_TABLE_100
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_VARCHAR2_TABLE_100
    , p3_a56 JTF_VARCHAR2_TABLE_100
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_VARCHAR2_TABLE_100
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_VARCHAR2_TABLE_100
    , p3_a63 JTF_VARCHAR2_TABLE_300
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_VARCHAR2_TABLE_4000
    , p4_a1 JTF_VARCHAR2_TABLE_4000
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_4000
    , p4_a6 JTF_VARCHAR2_TABLE_4000
    , p4_a7 JTF_VARCHAR2_TABLE_4000
    , p4_a8 JTF_VARCHAR2_TABLE_4000
    , p4_a9 JTF_VARCHAR2_TABLE_4000
    , p4_a10 JTF_VARCHAR2_TABLE_4000
    , p4_a11 JTF_VARCHAR2_TABLE_4000
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_VARCHAR2_TABLE_4000
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_VARCHAR2_TABLE_4000
    , p4_a16 JTF_VARCHAR2_TABLE_4000
    , p4_a17 JTF_VARCHAR2_TABLE_4000
    , p4_a18 JTF_VARCHAR2_TABLE_4000
    , p4_a19 JTF_VARCHAR2_TABLE_4000
    , p4_a20 JTF_VARCHAR2_TABLE_4000
    , p4_a21 JTF_VARCHAR2_TABLE_4000
    , p4_a22 JTF_VARCHAR2_TABLE_4000
    , p4_a23 JTF_VARCHAR2_TABLE_4000
    , p4_a24 JTF_VARCHAR2_TABLE_4000
    , p4_a25 JTF_VARCHAR2_TABLE_4000
    , p4_a26 JTF_VARCHAR2_TABLE_4000
    , p4_a27 JTF_VARCHAR2_TABLE_4000
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_VARCHAR2_TABLE_4000
    , p4_a30 JTF_VARCHAR2_TABLE_4000
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_4000
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_DATE_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_DATE_TABLE
    , p4_a47 JTF_DATE_TABLE
    , p4_a48 JTF_VARCHAR2_TABLE_100
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_100
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_100
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_100
    , p4_a58 JTF_VARCHAR2_TABLE_100
    , p4_a59 JTF_VARCHAR2_TABLE_500
    , p4_a60 JTF_VARCHAR2_TABLE_400
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_100
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_VARCHAR2_TABLE_100
    , p4_a68 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_4000
    , p5_a2 JTF_VARCHAR2_TABLE_4000
    , p5_a3 JTF_VARCHAR2_TABLE_4000
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_VARCHAR2_TABLE_4000
    , p5_a6 JTF_VARCHAR2_TABLE_4000
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_4000
    , p5_a9 JTF_VARCHAR2_TABLE_4000
    , p5_a10 JTF_VARCHAR2_TABLE_4000
    , p5_a11 JTF_VARCHAR2_TABLE_4000
    , p5_a12 JTF_VARCHAR2_TABLE_4000
    , p5_a13 JTF_VARCHAR2_TABLE_4000
    , p5_a14 JTF_VARCHAR2_TABLE_4000
    , p5_a15 JTF_VARCHAR2_TABLE_4000
    , p5_a16 JTF_VARCHAR2_TABLE_4000
    , p5_a17 JTF_VARCHAR2_TABLE_4000
    , p5_a18 JTF_VARCHAR2_TABLE_4000
    , p5_a19 JTF_VARCHAR2_TABLE_4000
    , p5_a20 JTF_VARCHAR2_TABLE_4000
    , p5_a21 JTF_VARCHAR2_TABLE_4000
    , p5_a22 JTF_VARCHAR2_TABLE_4000
    , p5_a23 JTF_VARCHAR2_TABLE_4000
    , p5_a24 JTF_VARCHAR2_TABLE_4000
    , p5_a25 JTF_VARCHAR2_TABLE_4000
    , p5_a26 JTF_VARCHAR2_TABLE_4000
    , p5_a27 JTF_VARCHAR2_TABLE_4000
    , p5_a28 JTF_VARCHAR2_TABLE_4000
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_VARCHAR2_TABLE_4000
    , p5_a31 JTF_VARCHAR2_TABLE_4000
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_2000
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_4000
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_VARCHAR2_TABLE_2000
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p_restrict_sql  VARCHAR2
    , p_match_type  VARCHAR2
    , p_search_merged  VARCHAR2
    , x_search_ctx_id out nocopy  NUMBER
    , x_num_matches out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_search_rec hz_party_search.party_search_rec_type;
    ddp_party_site_list hz_party_search.party_site_list;
    ddp_contact_list hz_party_search.contact_list;
    ddp_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_party_search_rec.all_account_names := p2_a0;
    ddp_party_search_rec.all_account_numbers := p2_a1;
    ddp_party_search_rec.domain_name := p2_a2;
    ddp_party_search_rec.party_source_system_ref := p2_a3;
    ddp_party_search_rec.custom_attribute1 := p2_a4;
    ddp_party_search_rec.custom_attribute10 := p2_a5;
    ddp_party_search_rec.custom_attribute11 := p2_a6;
    ddp_party_search_rec.custom_attribute12 := p2_a7;
    ddp_party_search_rec.custom_attribute13 := p2_a8;
    ddp_party_search_rec.custom_attribute14 := p2_a9;
    ddp_party_search_rec.custom_attribute15 := p2_a10;
    ddp_party_search_rec.custom_attribute16 := p2_a11;
    ddp_party_search_rec.custom_attribute17 := p2_a12;
    ddp_party_search_rec.custom_attribute18 := p2_a13;
    ddp_party_search_rec.custom_attribute19 := p2_a14;
    ddp_party_search_rec.custom_attribute2 := p2_a15;
    ddp_party_search_rec.custom_attribute20 := p2_a16;
    ddp_party_search_rec.custom_attribute21 := p2_a17;
    ddp_party_search_rec.custom_attribute22 := p2_a18;
    ddp_party_search_rec.custom_attribute23 := p2_a19;
    ddp_party_search_rec.custom_attribute24 := p2_a20;
    ddp_party_search_rec.custom_attribute25 := p2_a21;
    ddp_party_search_rec.custom_attribute26 := p2_a22;
    ddp_party_search_rec.custom_attribute27 := p2_a23;
    ddp_party_search_rec.custom_attribute28 := p2_a24;
    ddp_party_search_rec.custom_attribute29 := p2_a25;
    ddp_party_search_rec.custom_attribute3 := p2_a26;
    ddp_party_search_rec.custom_attribute30 := p2_a27;
    ddp_party_search_rec.custom_attribute4 := p2_a28;
    ddp_party_search_rec.custom_attribute5 := p2_a29;
    ddp_party_search_rec.custom_attribute6 := p2_a30;
    ddp_party_search_rec.custom_attribute7 := p2_a31;
    ddp_party_search_rec.custom_attribute8 := p2_a32;
    ddp_party_search_rec.custom_attribute9 := p2_a33;
    ddp_party_search_rec.analysis_fy := p2_a34;
    ddp_party_search_rec.avg_high_credit := p2_a35;
    ddp_party_search_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a36);
    ddp_party_search_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a37);
    ddp_party_search_rec.branch_flag := p2_a38;
    ddp_party_search_rec.business_scope := p2_a39;
    ddp_party_search_rec.ceo_name := p2_a40;
    ddp_party_search_rec.ceo_title := p2_a41;
    ddp_party_search_rec.cong_dist_code := p2_a42;
    ddp_party_search_rec.content_source_number := p2_a43;
    ddp_party_search_rec.content_source_type := p2_a44;
    ddp_party_search_rec.control_yr := p2_a45;
    ddp_party_search_rec.corporation_class := p2_a46;
    ddp_party_search_rec.credit_score := p2_a47;
    ddp_party_search_rec.credit_score_age := p2_a48;
    ddp_party_search_rec.credit_score_class := p2_a49;
    ddp_party_search_rec.credit_score_commentary := p2_a50;
    ddp_party_search_rec.credit_score_commentary10 := p2_a51;
    ddp_party_search_rec.credit_score_commentary2 := p2_a52;
    ddp_party_search_rec.credit_score_commentary3 := p2_a53;
    ddp_party_search_rec.credit_score_commentary4 := p2_a54;
    ddp_party_search_rec.credit_score_commentary5 := p2_a55;
    ddp_party_search_rec.credit_score_commentary6 := p2_a56;
    ddp_party_search_rec.credit_score_commentary7 := p2_a57;
    ddp_party_search_rec.credit_score_commentary8 := p2_a58;
    ddp_party_search_rec.credit_score_commentary9 := p2_a59;
    ddp_party_search_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a60);
    ddp_party_search_rec.credit_score_incd_default := p2_a61;
    ddp_party_search_rec.credit_score_natl_percentile := p2_a62;
    ddp_party_search_rec.curr_fy_potential_revenue := p2_a63;
    ddp_party_search_rec.db_rating := p2_a64;
    ddp_party_search_rec.debarments_count := p2_a65;
    ddp_party_search_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a66);
    ddp_party_search_rec.debarment_ind := p2_a67;
    ddp_party_search_rec.disadv_8a_ind := p2_a68;
    ddp_party_search_rec.duns_number_c := p2_a69;
    ddp_party_search_rec.employees_total := p2_a70;
    ddp_party_search_rec.emp_at_primary_adr := p2_a71;
    ddp_party_search_rec.emp_at_primary_adr_est_ind := p2_a72;
    ddp_party_search_rec.emp_at_primary_adr_min_ind := p2_a73;
    ddp_party_search_rec.emp_at_primary_adr_text := p2_a74;
    ddp_party_search_rec.enquiry_duns := p2_a75;
    ddp_party_search_rec.export_ind := p2_a76;
    ddp_party_search_rec.failure_score := p2_a77;
    ddp_party_search_rec.failure_score_age := p2_a78;
    ddp_party_search_rec.failure_score_class := p2_a79;
    ddp_party_search_rec.failure_score_commentary := p2_a80;
    ddp_party_search_rec.failure_score_commentary10 := p2_a81;
    ddp_party_search_rec.failure_score_commentary2 := p2_a82;
    ddp_party_search_rec.failure_score_commentary3 := p2_a83;
    ddp_party_search_rec.failure_score_commentary4 := p2_a84;
    ddp_party_search_rec.failure_score_commentary5 := p2_a85;
    ddp_party_search_rec.failure_score_commentary6 := p2_a86;
    ddp_party_search_rec.failure_score_commentary7 := p2_a87;
    ddp_party_search_rec.failure_score_commentary8 := p2_a88;
    ddp_party_search_rec.failure_score_commentary9 := p2_a89;
    ddp_party_search_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a90);
    ddp_party_search_rec.failure_score_incd_default := p2_a91;
    ddp_party_search_rec.failure_score_override_code := p2_a92;
    ddp_party_search_rec.fiscal_yearend_month := p2_a93;
    ddp_party_search_rec.global_failure_score := p2_a94;
    ddp_party_search_rec.gsa_indicator_flag := p2_a95;
    ddp_party_search_rec.high_credit := p2_a96;
    ddp_party_search_rec.hq_branch_ind := p2_a97;
    ddp_party_search_rec.import_ind := p2_a98;
    ddp_party_search_rec.incorp_year := p2_a99;
    ddp_party_search_rec.internal_flag := p2_a100;
    ddp_party_search_rec.jgzz_fiscal_code := p2_a101;
    ddp_party_search_rec.party_all_names := p2_a102;
    ddp_party_search_rec.known_as := p2_a103;
    ddp_party_search_rec.known_as2 := p2_a104;
    ddp_party_search_rec.known_as3 := p2_a105;
    ddp_party_search_rec.known_as4 := p2_a106;
    ddp_party_search_rec.known_as5 := p2_a107;
    ddp_party_search_rec.labor_surplus_ind := p2_a108;
    ddp_party_search_rec.legal_status := p2_a109;
    ddp_party_search_rec.line_of_business := p2_a110;
    ddp_party_search_rec.local_activity_code := p2_a111;
    ddp_party_search_rec.local_activity_code_type := p2_a112;
    ddp_party_search_rec.local_bus_identifier := p2_a113;
    ddp_party_search_rec.local_bus_iden_type := p2_a114;
    ddp_party_search_rec.maximum_credit_currency_code := p2_a115;
    ddp_party_search_rec.maximum_credit_recommendation := p2_a116;
    ddp_party_search_rec.minority_owned_ind := p2_a117;
    ddp_party_search_rec.minority_owned_type := p2_a118;
    ddp_party_search_rec.next_fy_potential_revenue := p2_a119;
    ddp_party_search_rec.oob_ind := p2_a120;
    ddp_party_search_rec.organization_name := p2_a121;
    ddp_party_search_rec.organization_name_phonetic := p2_a122;
    ddp_party_search_rec.organization_type := p2_a123;
    ddp_party_search_rec.parent_sub_ind := p2_a124;
    ddp_party_search_rec.paydex_norm := p2_a125;
    ddp_party_search_rec.paydex_score := p2_a126;
    ddp_party_search_rec.paydex_three_months_ago := p2_a127;
    ddp_party_search_rec.pref_functional_currency := p2_a128;
    ddp_party_search_rec.principal_name := p2_a129;
    ddp_party_search_rec.principal_title := p2_a130;
    ddp_party_search_rec.public_private_ownership_flag := p2_a131;
    ddp_party_search_rec.registration_type := p2_a132;
    ddp_party_search_rec.rent_own_ind := p2_a133;
    ddp_party_search_rec.sic_code := p2_a134;
    ddp_party_search_rec.sic_code_type := p2_a135;
    ddp_party_search_rec.small_bus_ind := p2_a136;
    ddp_party_search_rec.tax_name := p2_a137;
    ddp_party_search_rec.tax_reference := p2_a138;
    ddp_party_search_rec.total_employees_text := p2_a139;
    ddp_party_search_rec.total_emp_est_ind := p2_a140;
    ddp_party_search_rec.total_emp_min_ind := p2_a141;
    ddp_party_search_rec.total_employees_ind := p2_a142;
    ddp_party_search_rec.total_payments := p2_a143;
    ddp_party_search_rec.woman_owned_ind := p2_a144;
    ddp_party_search_rec.year_established := p2_a145;
    ddp_party_search_rec.category_code := p2_a146;
    ddp_party_search_rec.competitor_flag := p2_a147;
    ddp_party_search_rec.do_not_mail_flag := p2_a148;
    ddp_party_search_rec.group_type := p2_a149;
    ddp_party_search_rec.language_name := p2_a150;
    ddp_party_search_rec.party_name := p2_a151;
    ddp_party_search_rec.party_number := p2_a152;
    ddp_party_search_rec.party_type := p2_a153;
    ddp_party_search_rec.reference_use_flag := p2_a154;
    ddp_party_search_rec.salutation := p2_a155;
    ddp_party_search_rec.status := p2_a156;
    ddp_party_search_rec.third_party_flag := p2_a157;
    ddp_party_search_rec.validated_flag := p2_a158;
    ddp_party_search_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a159);
    ddp_party_search_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a160);
    ddp_party_search_rec.effective_start_date := rosetta_g_miss_date_in_map(p2_a161);
    ddp_party_search_rec.effective_end_date := rosetta_g_miss_date_in_map(p2_a162);
    ddp_party_search_rec.declared_ethnicity := p2_a163;
    ddp_party_search_rec.gender := p2_a164;
    ddp_party_search_rec.head_of_household_flag := p2_a165;
    ddp_party_search_rec.household_income := p2_a166;
    ddp_party_search_rec.household_size := p2_a167;
    ddp_party_search_rec.last_known_gps := p2_a168;
    ddp_party_search_rec.marital_status := p2_a169;
    ddp_party_search_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a170);
    ddp_party_search_rec.middle_name_phonetic := p2_a171;
    ddp_party_search_rec.personal_income := p2_a172;
    ddp_party_search_rec.person_academic_title := p2_a173;
    ddp_party_search_rec.person_first_name := p2_a174;
    ddp_party_search_rec.person_first_name_phonetic := p2_a175;
    ddp_party_search_rec.person_identifier := p2_a176;
    ddp_party_search_rec.person_iden_type := p2_a177;
    ddp_party_search_rec.person_initials := p2_a178;
    ddp_party_search_rec.person_last_name := p2_a179;
    ddp_party_search_rec.person_last_name_phonetic := p2_a180;
    ddp_party_search_rec.person_middle_name := p2_a181;
    ddp_party_search_rec.person_name := p2_a182;
    ddp_party_search_rec.person_name_phonetic := p2_a183;
    ddp_party_search_rec.person_name_suffix := p2_a184;
    ddp_party_search_rec.person_previous_last_name := p2_a185;
    ddp_party_search_rec.person_pre_name_adjunct := p2_a186;
    ddp_party_search_rec.person_title := p2_a187;
    ddp_party_search_rec.place_of_birth := p2_a188;

    hz_party_search_w.rosetta_table_copy_in_p8(ddp_party_site_list, p3_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p9(ddp_contact_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_in_p10(ddp_contact_point_list, p5_a0
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
      );









    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.find_party_details(p_init_msg_list,
      p_rule_id,
      ddp_party_search_rec,
      ddp_party_site_list,
      ddp_contact_list,
      ddp_contact_point_list,
      p_restrict_sql,
      p_match_type,
      p_search_merged,
      x_search_ctx_id,
      x_num_matches,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure get_party_for_search_13(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  NUMBER
    , p3_a36 out nocopy  DATE
    , p3_a37 out nocopy  DATE
    , p3_a38 out nocopy  VARCHAR2
    , p3_a39 out nocopy  VARCHAR2
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  VARCHAR2
    , p3_a44 out nocopy  VARCHAR2
    , p3_a45 out nocopy  NUMBER
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  VARCHAR2
    , p3_a48 out nocopy  NUMBER
    , p3_a49 out nocopy  NUMBER
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  VARCHAR2
    , p3_a52 out nocopy  VARCHAR2
    , p3_a53 out nocopy  VARCHAR2
    , p3_a54 out nocopy  VARCHAR2
    , p3_a55 out nocopy  VARCHAR2
    , p3_a56 out nocopy  VARCHAR2
    , p3_a57 out nocopy  VARCHAR2
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  VARCHAR2
    , p3_a60 out nocopy  DATE
    , p3_a61 out nocopy  NUMBER
    , p3_a62 out nocopy  NUMBER
    , p3_a63 out nocopy  NUMBER
    , p3_a64 out nocopy  VARCHAR2
    , p3_a65 out nocopy  NUMBER
    , p3_a66 out nocopy  DATE
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  VARCHAR2
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  NUMBER
    , p3_a71 out nocopy  VARCHAR2
    , p3_a72 out nocopy  VARCHAR2
    , p3_a73 out nocopy  VARCHAR2
    , p3_a74 out nocopy  VARCHAR2
    , p3_a75 out nocopy  VARCHAR2
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  NUMBER
    , p3_a79 out nocopy  NUMBER
    , p3_a80 out nocopy  VARCHAR2
    , p3_a81 out nocopy  VARCHAR2
    , p3_a82 out nocopy  VARCHAR2
    , p3_a83 out nocopy  VARCHAR2
    , p3_a84 out nocopy  VARCHAR2
    , p3_a85 out nocopy  VARCHAR2
    , p3_a86 out nocopy  VARCHAR2
    , p3_a87 out nocopy  VARCHAR2
    , p3_a88 out nocopy  VARCHAR2
    , p3_a89 out nocopy  VARCHAR2
    , p3_a90 out nocopy  DATE
    , p3_a91 out nocopy  NUMBER
    , p3_a92 out nocopy  VARCHAR2
    , p3_a93 out nocopy  VARCHAR2
    , p3_a94 out nocopy  VARCHAR2
    , p3_a95 out nocopy  VARCHAR2
    , p3_a96 out nocopy  NUMBER
    , p3_a97 out nocopy  VARCHAR2
    , p3_a98 out nocopy  VARCHAR2
    , p3_a99 out nocopy  NUMBER
    , p3_a100 out nocopy  VARCHAR2
    , p3_a101 out nocopy  VARCHAR2
    , p3_a102 out nocopy  VARCHAR2
    , p3_a103 out nocopy  VARCHAR2
    , p3_a104 out nocopy  VARCHAR2
    , p3_a105 out nocopy  VARCHAR2
    , p3_a106 out nocopy  VARCHAR2
    , p3_a107 out nocopy  VARCHAR2
    , p3_a108 out nocopy  VARCHAR2
    , p3_a109 out nocopy  VARCHAR2
    , p3_a110 out nocopy  VARCHAR2
    , p3_a111 out nocopy  VARCHAR2
    , p3_a112 out nocopy  VARCHAR2
    , p3_a113 out nocopy  VARCHAR2
    , p3_a114 out nocopy  VARCHAR2
    , p3_a115 out nocopy  VARCHAR2
    , p3_a116 out nocopy  NUMBER
    , p3_a117 out nocopy  VARCHAR2
    , p3_a118 out nocopy  VARCHAR2
    , p3_a119 out nocopy  NUMBER
    , p3_a120 out nocopy  VARCHAR2
    , p3_a121 out nocopy  VARCHAR2
    , p3_a122 out nocopy  VARCHAR2
    , p3_a123 out nocopy  VARCHAR2
    , p3_a124 out nocopy  VARCHAR2
    , p3_a125 out nocopy  VARCHAR2
    , p3_a126 out nocopy  VARCHAR2
    , p3_a127 out nocopy  VARCHAR2
    , p3_a128 out nocopy  VARCHAR2
    , p3_a129 out nocopy  VARCHAR2
    , p3_a130 out nocopy  VARCHAR2
    , p3_a131 out nocopy  VARCHAR2
    , p3_a132 out nocopy  VARCHAR2
    , p3_a133 out nocopy  VARCHAR2
    , p3_a134 out nocopy  VARCHAR2
    , p3_a135 out nocopy  VARCHAR2
    , p3_a136 out nocopy  VARCHAR2
    , p3_a137 out nocopy  VARCHAR2
    , p3_a138 out nocopy  VARCHAR2
    , p3_a139 out nocopy  VARCHAR2
    , p3_a140 out nocopy  VARCHAR2
    , p3_a141 out nocopy  VARCHAR2
    , p3_a142 out nocopy  VARCHAR2
    , p3_a143 out nocopy  NUMBER
    , p3_a144 out nocopy  VARCHAR2
    , p3_a145 out nocopy  NUMBER
    , p3_a146 out nocopy  VARCHAR2
    , p3_a147 out nocopy  VARCHAR2
    , p3_a148 out nocopy  VARCHAR2
    , p3_a149 out nocopy  VARCHAR2
    , p3_a150 out nocopy  VARCHAR2
    , p3_a151 out nocopy  VARCHAR2
    , p3_a152 out nocopy  VARCHAR2
    , p3_a153 out nocopy  VARCHAR2
    , p3_a154 out nocopy  VARCHAR2
    , p3_a155 out nocopy  VARCHAR2
    , p3_a156 out nocopy  VARCHAR2
    , p3_a157 out nocopy  VARCHAR2
    , p3_a158 out nocopy  VARCHAR2
    , p3_a159 out nocopy  DATE
    , p3_a160 out nocopy  DATE
    , p3_a161 out nocopy  DATE
    , p3_a162 out nocopy  DATE
    , p3_a163 out nocopy  VARCHAR2
    , p3_a164 out nocopy  VARCHAR2
    , p3_a165 out nocopy  VARCHAR2
    , p3_a166 out nocopy  NUMBER
    , p3_a167 out nocopy  NUMBER
    , p3_a168 out nocopy  VARCHAR2
    , p3_a169 out nocopy  VARCHAR2
    , p3_a170 out nocopy  DATE
    , p3_a171 out nocopy  VARCHAR2
    , p3_a172 out nocopy  NUMBER
    , p3_a173 out nocopy  VARCHAR2
    , p3_a174 out nocopy  VARCHAR2
    , p3_a175 out nocopy  VARCHAR2
    , p3_a176 out nocopy  VARCHAR2
    , p3_a177 out nocopy  VARCHAR2
    , p3_a178 out nocopy  VARCHAR2
    , p3_a179 out nocopy  VARCHAR2
    , p3_a180 out nocopy  VARCHAR2
    , p3_a181 out nocopy  VARCHAR2
    , p3_a182 out nocopy  VARCHAR2
    , p3_a183 out nocopy  VARCHAR2
    , p3_a184 out nocopy  VARCHAR2
    , p3_a185 out nocopy  VARCHAR2
    , p3_a186 out nocopy  VARCHAR2
    , p3_a187 out nocopy  VARCHAR2
    , p3_a188 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a36 out nocopy JTF_DATE_TABLE
    , p4_a37 out nocopy JTF_DATE_TABLE
    , p4_a38 out nocopy JTF_VARCHAR2_TABLE_600
    , p4_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a44 out nocopy JTF_DATE_TABLE
    , p5_a45 out nocopy JTF_DATE_TABLE
    , p5_a46 out nocopy JTF_DATE_TABLE
    , p5_a47 out nocopy JTF_DATE_TABLE
    , p5_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a60 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_party_search_rec hz_party_search.party_search_rec_type;
    ddx_party_site_list hz_party_search.party_site_list;
    ddx_contact_list hz_party_search.contact_list;
    ddx_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_party_for_search(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddx_party_search_rec,
      ddx_party_site_list,
      ddx_contact_list,
      ddx_contact_point_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddx_party_search_rec.all_account_names;
    p3_a1 := ddx_party_search_rec.all_account_numbers;
    p3_a2 := ddx_party_search_rec.domain_name;
    p3_a3 := ddx_party_search_rec.party_source_system_ref;
    p3_a4 := ddx_party_search_rec.custom_attribute1;
    p3_a5 := ddx_party_search_rec.custom_attribute10;
    p3_a6 := ddx_party_search_rec.custom_attribute11;
    p3_a7 := ddx_party_search_rec.custom_attribute12;
    p3_a8 := ddx_party_search_rec.custom_attribute13;
    p3_a9 := ddx_party_search_rec.custom_attribute14;
    p3_a10 := ddx_party_search_rec.custom_attribute15;
    p3_a11 := ddx_party_search_rec.custom_attribute16;
    p3_a12 := ddx_party_search_rec.custom_attribute17;
    p3_a13 := ddx_party_search_rec.custom_attribute18;
    p3_a14 := ddx_party_search_rec.custom_attribute19;
    p3_a15 := ddx_party_search_rec.custom_attribute2;
    p3_a16 := ddx_party_search_rec.custom_attribute20;
    p3_a17 := ddx_party_search_rec.custom_attribute21;
    p3_a18 := ddx_party_search_rec.custom_attribute22;
    p3_a19 := ddx_party_search_rec.custom_attribute23;
    p3_a20 := ddx_party_search_rec.custom_attribute24;
    p3_a21 := ddx_party_search_rec.custom_attribute25;
    p3_a22 := ddx_party_search_rec.custom_attribute26;
    p3_a23 := ddx_party_search_rec.custom_attribute27;
    p3_a24 := ddx_party_search_rec.custom_attribute28;
    p3_a25 := ddx_party_search_rec.custom_attribute29;
    p3_a26 := ddx_party_search_rec.custom_attribute3;
    p3_a27 := ddx_party_search_rec.custom_attribute30;
    p3_a28 := ddx_party_search_rec.custom_attribute4;
    p3_a29 := ddx_party_search_rec.custom_attribute5;
    p3_a30 := ddx_party_search_rec.custom_attribute6;
    p3_a31 := ddx_party_search_rec.custom_attribute7;
    p3_a32 := ddx_party_search_rec.custom_attribute8;
    p3_a33 := ddx_party_search_rec.custom_attribute9;
    p3_a34 := ddx_party_search_rec.analysis_fy;
    p3_a35 := ddx_party_search_rec.avg_high_credit;
    p3_a36 := ddx_party_search_rec.best_time_contact_begin;
    p3_a37 := ddx_party_search_rec.best_time_contact_end;
    p3_a38 := ddx_party_search_rec.branch_flag;
    p3_a39 := ddx_party_search_rec.business_scope;
    p3_a40 := ddx_party_search_rec.ceo_name;
    p3_a41 := ddx_party_search_rec.ceo_title;
    p3_a42 := ddx_party_search_rec.cong_dist_code;
    p3_a43 := ddx_party_search_rec.content_source_number;
    p3_a44 := ddx_party_search_rec.content_source_type;
    p3_a45 := ddx_party_search_rec.control_yr;
    p3_a46 := ddx_party_search_rec.corporation_class;
    p3_a47 := ddx_party_search_rec.credit_score;
    p3_a48 := ddx_party_search_rec.credit_score_age;
    p3_a49 := ddx_party_search_rec.credit_score_class;
    p3_a50 := ddx_party_search_rec.credit_score_commentary;
    p3_a51 := ddx_party_search_rec.credit_score_commentary10;
    p3_a52 := ddx_party_search_rec.credit_score_commentary2;
    p3_a53 := ddx_party_search_rec.credit_score_commentary3;
    p3_a54 := ddx_party_search_rec.credit_score_commentary4;
    p3_a55 := ddx_party_search_rec.credit_score_commentary5;
    p3_a56 := ddx_party_search_rec.credit_score_commentary6;
    p3_a57 := ddx_party_search_rec.credit_score_commentary7;
    p3_a58 := ddx_party_search_rec.credit_score_commentary8;
    p3_a59 := ddx_party_search_rec.credit_score_commentary9;
    p3_a60 := ddx_party_search_rec.credit_score_date;
    p3_a61 := ddx_party_search_rec.credit_score_incd_default;
    p3_a62 := ddx_party_search_rec.credit_score_natl_percentile;
    p3_a63 := ddx_party_search_rec.curr_fy_potential_revenue;
    p3_a64 := ddx_party_search_rec.db_rating;
    p3_a65 := ddx_party_search_rec.debarments_count;
    p3_a66 := ddx_party_search_rec.debarments_date;
    p3_a67 := ddx_party_search_rec.debarment_ind;
    p3_a68 := ddx_party_search_rec.disadv_8a_ind;
    p3_a69 := ddx_party_search_rec.duns_number_c;
    p3_a70 := ddx_party_search_rec.employees_total;
    p3_a71 := ddx_party_search_rec.emp_at_primary_adr;
    p3_a72 := ddx_party_search_rec.emp_at_primary_adr_est_ind;
    p3_a73 := ddx_party_search_rec.emp_at_primary_adr_min_ind;
    p3_a74 := ddx_party_search_rec.emp_at_primary_adr_text;
    p3_a75 := ddx_party_search_rec.enquiry_duns;
    p3_a76 := ddx_party_search_rec.export_ind;
    p3_a77 := ddx_party_search_rec.failure_score;
    p3_a78 := ddx_party_search_rec.failure_score_age;
    p3_a79 := ddx_party_search_rec.failure_score_class;
    p3_a80 := ddx_party_search_rec.failure_score_commentary;
    p3_a81 := ddx_party_search_rec.failure_score_commentary10;
    p3_a82 := ddx_party_search_rec.failure_score_commentary2;
    p3_a83 := ddx_party_search_rec.failure_score_commentary3;
    p3_a84 := ddx_party_search_rec.failure_score_commentary4;
    p3_a85 := ddx_party_search_rec.failure_score_commentary5;
    p3_a86 := ddx_party_search_rec.failure_score_commentary6;
    p3_a87 := ddx_party_search_rec.failure_score_commentary7;
    p3_a88 := ddx_party_search_rec.failure_score_commentary8;
    p3_a89 := ddx_party_search_rec.failure_score_commentary9;
    p3_a90 := ddx_party_search_rec.failure_score_date;
    p3_a91 := ddx_party_search_rec.failure_score_incd_default;
    p3_a92 := ddx_party_search_rec.failure_score_override_code;
    p3_a93 := ddx_party_search_rec.fiscal_yearend_month;
    p3_a94 := ddx_party_search_rec.global_failure_score;
    p3_a95 := ddx_party_search_rec.gsa_indicator_flag;
    p3_a96 := ddx_party_search_rec.high_credit;
    p3_a97 := ddx_party_search_rec.hq_branch_ind;
    p3_a98 := ddx_party_search_rec.import_ind;
    p3_a99 := ddx_party_search_rec.incorp_year;
    p3_a100 := ddx_party_search_rec.internal_flag;
    p3_a101 := ddx_party_search_rec.jgzz_fiscal_code;
    p3_a102 := ddx_party_search_rec.party_all_names;
    p3_a103 := ddx_party_search_rec.known_as;
    p3_a104 := ddx_party_search_rec.known_as2;
    p3_a105 := ddx_party_search_rec.known_as3;
    p3_a106 := ddx_party_search_rec.known_as4;
    p3_a107 := ddx_party_search_rec.known_as5;
    p3_a108 := ddx_party_search_rec.labor_surplus_ind;
    p3_a109 := ddx_party_search_rec.legal_status;
    p3_a110 := ddx_party_search_rec.line_of_business;
    p3_a111 := ddx_party_search_rec.local_activity_code;
    p3_a112 := ddx_party_search_rec.local_activity_code_type;
    p3_a113 := ddx_party_search_rec.local_bus_identifier;
    p3_a114 := ddx_party_search_rec.local_bus_iden_type;
    p3_a115 := ddx_party_search_rec.maximum_credit_currency_code;
    p3_a116 := ddx_party_search_rec.maximum_credit_recommendation;
    p3_a117 := ddx_party_search_rec.minority_owned_ind;
    p3_a118 := ddx_party_search_rec.minority_owned_type;
    p3_a119 := ddx_party_search_rec.next_fy_potential_revenue;
    p3_a120 := ddx_party_search_rec.oob_ind;
    p3_a121 := ddx_party_search_rec.organization_name;
    p3_a122 := ddx_party_search_rec.organization_name_phonetic;
    p3_a123 := ddx_party_search_rec.organization_type;
    p3_a124 := ddx_party_search_rec.parent_sub_ind;
    p3_a125 := ddx_party_search_rec.paydex_norm;
    p3_a126 := ddx_party_search_rec.paydex_score;
    p3_a127 := ddx_party_search_rec.paydex_three_months_ago;
    p3_a128 := ddx_party_search_rec.pref_functional_currency;
    p3_a129 := ddx_party_search_rec.principal_name;
    p3_a130 := ddx_party_search_rec.principal_title;
    p3_a131 := ddx_party_search_rec.public_private_ownership_flag;
    p3_a132 := ddx_party_search_rec.registration_type;
    p3_a133 := ddx_party_search_rec.rent_own_ind;
    p3_a134 := ddx_party_search_rec.sic_code;
    p3_a135 := ddx_party_search_rec.sic_code_type;
    p3_a136 := ddx_party_search_rec.small_bus_ind;
    p3_a137 := ddx_party_search_rec.tax_name;
    p3_a138 := ddx_party_search_rec.tax_reference;
    p3_a139 := ddx_party_search_rec.total_employees_text;
    p3_a140 := ddx_party_search_rec.total_emp_est_ind;
    p3_a141 := ddx_party_search_rec.total_emp_min_ind;
    p3_a142 := ddx_party_search_rec.total_employees_ind;
    p3_a143 := ddx_party_search_rec.total_payments;
    p3_a144 := ddx_party_search_rec.woman_owned_ind;
    p3_a145 := ddx_party_search_rec.year_established;
    p3_a146 := ddx_party_search_rec.category_code;
    p3_a147 := ddx_party_search_rec.competitor_flag;
    p3_a148 := ddx_party_search_rec.do_not_mail_flag;
    p3_a149 := ddx_party_search_rec.group_type;
    p3_a150 := ddx_party_search_rec.language_name;
    p3_a151 := ddx_party_search_rec.party_name;
    p3_a152 := ddx_party_search_rec.party_number;
    p3_a153 := ddx_party_search_rec.party_type;
    p3_a154 := ddx_party_search_rec.reference_use_flag;
    p3_a155 := ddx_party_search_rec.salutation;
    p3_a156 := ddx_party_search_rec.status;
    p3_a157 := ddx_party_search_rec.third_party_flag;
    p3_a158 := ddx_party_search_rec.validated_flag;
    p3_a159 := ddx_party_search_rec.date_of_birth;
    p3_a160 := ddx_party_search_rec.date_of_death;
    p3_a161 := ddx_party_search_rec.effective_start_date;
    p3_a162 := ddx_party_search_rec.effective_end_date;
    p3_a163 := ddx_party_search_rec.declared_ethnicity;
    p3_a164 := ddx_party_search_rec.gender;
    p3_a165 := ddx_party_search_rec.head_of_household_flag;
    p3_a166 := ddx_party_search_rec.household_income;
    p3_a167 := ddx_party_search_rec.household_size;
    p3_a168 := ddx_party_search_rec.last_known_gps;
    p3_a169 := ddx_party_search_rec.marital_status;
    p3_a170 := ddx_party_search_rec.marital_status_effective_date;
    p3_a171 := ddx_party_search_rec.middle_name_phonetic;
    p3_a172 := ddx_party_search_rec.personal_income;
    p3_a173 := ddx_party_search_rec.person_academic_title;
    p3_a174 := ddx_party_search_rec.person_first_name;
    p3_a175 := ddx_party_search_rec.person_first_name_phonetic;
    p3_a176 := ddx_party_search_rec.person_identifier;
    p3_a177 := ddx_party_search_rec.person_iden_type;
    p3_a178 := ddx_party_search_rec.person_initials;
    p3_a179 := ddx_party_search_rec.person_last_name;
    p3_a180 := ddx_party_search_rec.person_last_name_phonetic;
    p3_a181 := ddx_party_search_rec.person_middle_name;
    p3_a182 := ddx_party_search_rec.person_name;
    p3_a183 := ddx_party_search_rec.person_name_phonetic;
    p3_a184 := ddx_party_search_rec.person_name_suffix;
    p3_a185 := ddx_party_search_rec.person_previous_last_name;
    p3_a186 := ddx_party_search_rec.person_pre_name_adjunct;
    p3_a187 := ddx_party_search_rec.person_title;
    p3_a188 := ddx_party_search_rec.place_of_birth;

    hz_party_search_w.rosetta_table_copy_out_p8(ddx_party_site_list, p4_a0
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
      );

    hz_party_search_w.rosetta_table_copy_out_p9(ddx_contact_list, p5_a0
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
      );

    hz_party_search_w.rosetta_table_copy_out_p10(ddx_contact_point_list, p6_a0
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
      );



  end;

  procedure get_search_criteria_14(p_init_msg_list  VARCHAR2
    , p_rule_id  NUMBER
    , p_party_id  NUMBER
    , p_party_site_ids JTF_NUMBER_TABLE
    , p_contact_ids JTF_NUMBER_TABLE
    , p_contact_pt_ids JTF_NUMBER_TABLE
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  DATE
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  VARCHAR2
    , p6_a83 out nocopy  VARCHAR2
    , p6_a84 out nocopy  VARCHAR2
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  DATE
    , p6_a91 out nocopy  NUMBER
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  VARCHAR2
    , p6_a94 out nocopy  VARCHAR2
    , p6_a95 out nocopy  VARCHAR2
    , p6_a96 out nocopy  NUMBER
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  VARCHAR2
    , p6_a99 out nocopy  NUMBER
    , p6_a100 out nocopy  VARCHAR2
    , p6_a101 out nocopy  VARCHAR2
    , p6_a102 out nocopy  VARCHAR2
    , p6_a103 out nocopy  VARCHAR2
    , p6_a104 out nocopy  VARCHAR2
    , p6_a105 out nocopy  VARCHAR2
    , p6_a106 out nocopy  VARCHAR2
    , p6_a107 out nocopy  VARCHAR2
    , p6_a108 out nocopy  VARCHAR2
    , p6_a109 out nocopy  VARCHAR2
    , p6_a110 out nocopy  VARCHAR2
    , p6_a111 out nocopy  VARCHAR2
    , p6_a112 out nocopy  VARCHAR2
    , p6_a113 out nocopy  VARCHAR2
    , p6_a114 out nocopy  VARCHAR2
    , p6_a115 out nocopy  VARCHAR2
    , p6_a116 out nocopy  NUMBER
    , p6_a117 out nocopy  VARCHAR2
    , p6_a118 out nocopy  VARCHAR2
    , p6_a119 out nocopy  NUMBER
    , p6_a120 out nocopy  VARCHAR2
    , p6_a121 out nocopy  VARCHAR2
    , p6_a122 out nocopy  VARCHAR2
    , p6_a123 out nocopy  VARCHAR2
    , p6_a124 out nocopy  VARCHAR2
    , p6_a125 out nocopy  VARCHAR2
    , p6_a126 out nocopy  VARCHAR2
    , p6_a127 out nocopy  VARCHAR2
    , p6_a128 out nocopy  VARCHAR2
    , p6_a129 out nocopy  VARCHAR2
    , p6_a130 out nocopy  VARCHAR2
    , p6_a131 out nocopy  VARCHAR2
    , p6_a132 out nocopy  VARCHAR2
    , p6_a133 out nocopy  VARCHAR2
    , p6_a134 out nocopy  VARCHAR2
    , p6_a135 out nocopy  VARCHAR2
    , p6_a136 out nocopy  VARCHAR2
    , p6_a137 out nocopy  VARCHAR2
    , p6_a138 out nocopy  VARCHAR2
    , p6_a139 out nocopy  VARCHAR2
    , p6_a140 out nocopy  VARCHAR2
    , p6_a141 out nocopy  VARCHAR2
    , p6_a142 out nocopy  VARCHAR2
    , p6_a143 out nocopy  NUMBER
    , p6_a144 out nocopy  VARCHAR2
    , p6_a145 out nocopy  NUMBER
    , p6_a146 out nocopy  VARCHAR2
    , p6_a147 out nocopy  VARCHAR2
    , p6_a148 out nocopy  VARCHAR2
    , p6_a149 out nocopy  VARCHAR2
    , p6_a150 out nocopy  VARCHAR2
    , p6_a151 out nocopy  VARCHAR2
    , p6_a152 out nocopy  VARCHAR2
    , p6_a153 out nocopy  VARCHAR2
    , p6_a154 out nocopy  VARCHAR2
    , p6_a155 out nocopy  VARCHAR2
    , p6_a156 out nocopy  VARCHAR2
    , p6_a157 out nocopy  VARCHAR2
    , p6_a158 out nocopy  VARCHAR2
    , p6_a159 out nocopy  DATE
    , p6_a160 out nocopy  DATE
    , p6_a161 out nocopy  DATE
    , p6_a162 out nocopy  DATE
    , p6_a163 out nocopy  VARCHAR2
    , p6_a164 out nocopy  VARCHAR2
    , p6_a165 out nocopy  VARCHAR2
    , p6_a166 out nocopy  NUMBER
    , p6_a167 out nocopy  NUMBER
    , p6_a168 out nocopy  VARCHAR2
    , p6_a169 out nocopy  VARCHAR2
    , p6_a170 out nocopy  DATE
    , p6_a171 out nocopy  VARCHAR2
    , p6_a172 out nocopy  NUMBER
    , p6_a173 out nocopy  VARCHAR2
    , p6_a174 out nocopy  VARCHAR2
    , p6_a175 out nocopy  VARCHAR2
    , p6_a176 out nocopy  VARCHAR2
    , p6_a177 out nocopy  VARCHAR2
    , p6_a178 out nocopy  VARCHAR2
    , p6_a179 out nocopy  VARCHAR2
    , p6_a180 out nocopy  VARCHAR2
    , p6_a181 out nocopy  VARCHAR2
    , p6_a182 out nocopy  VARCHAR2
    , p6_a183 out nocopy  VARCHAR2
    , p6_a184 out nocopy  VARCHAR2
    , p6_a185 out nocopy  VARCHAR2
    , p6_a186 out nocopy  VARCHAR2
    , p6_a187 out nocopy  VARCHAR2
    , p6_a188 out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a36 out nocopy JTF_DATE_TABLE
    , p7_a37 out nocopy JTF_DATE_TABLE
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_DATE_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_DATE_TABLE
    , p8_a47 out nocopy JTF_DATE_TABLE
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a44 out nocopy JTF_DATE_TABLE
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a55 out nocopy JTF_NUMBER_TABLE
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_site_ids hz_party_search.idlist;
    ddp_contact_ids hz_party_search.idlist;
    ddp_contact_pt_ids hz_party_search.idlist;
    ddx_party_search_rec hz_party_search.party_search_rec_type;
    ddx_party_site_list hz_party_search.party_site_list;
    ddx_contact_list hz_party_search.contact_list;
    ddx_contact_point_list hz_party_search.contact_point_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    hz_party_search_w.rosetta_table_copy_in_p6(ddp_party_site_ids, p_party_site_ids);

    hz_party_search_w.rosetta_table_copy_in_p6(ddp_contact_ids, p_contact_ids);

    hz_party_search_w.rosetta_table_copy_in_p6(ddp_contact_pt_ids, p_contact_pt_ids);








    -- here's the delegated call to the old PL/SQL routine
    hz_party_search.get_search_criteria(p_init_msg_list,
      p_rule_id,
      p_party_id,
      ddp_party_site_ids,
      ddp_contact_ids,
      ddp_contact_pt_ids,
      ddx_party_search_rec,
      ddx_party_site_list,
      ddx_contact_list,
      ddx_contact_point_list,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_party_search_rec.all_account_names;
    p6_a1 := ddx_party_search_rec.all_account_numbers;
    p6_a2 := ddx_party_search_rec.domain_name;
    p6_a3 := ddx_party_search_rec.party_source_system_ref;
    p6_a4 := ddx_party_search_rec.custom_attribute1;
    p6_a5 := ddx_party_search_rec.custom_attribute10;
    p6_a6 := ddx_party_search_rec.custom_attribute11;
    p6_a7 := ddx_party_search_rec.custom_attribute12;
    p6_a8 := ddx_party_search_rec.custom_attribute13;
    p6_a9 := ddx_party_search_rec.custom_attribute14;
    p6_a10 := ddx_party_search_rec.custom_attribute15;
    p6_a11 := ddx_party_search_rec.custom_attribute16;
    p6_a12 := ddx_party_search_rec.custom_attribute17;
    p6_a13 := ddx_party_search_rec.custom_attribute18;
    p6_a14 := ddx_party_search_rec.custom_attribute19;
    p6_a15 := ddx_party_search_rec.custom_attribute2;
    p6_a16 := ddx_party_search_rec.custom_attribute20;
    p6_a17 := ddx_party_search_rec.custom_attribute21;
    p6_a18 := ddx_party_search_rec.custom_attribute22;
    p6_a19 := ddx_party_search_rec.custom_attribute23;
    p6_a20 := ddx_party_search_rec.custom_attribute24;
    p6_a21 := ddx_party_search_rec.custom_attribute25;
    p6_a22 := ddx_party_search_rec.custom_attribute26;
    p6_a23 := ddx_party_search_rec.custom_attribute27;
    p6_a24 := ddx_party_search_rec.custom_attribute28;
    p6_a25 := ddx_party_search_rec.custom_attribute29;
    p6_a26 := ddx_party_search_rec.custom_attribute3;
    p6_a27 := ddx_party_search_rec.custom_attribute30;
    p6_a28 := ddx_party_search_rec.custom_attribute4;
    p6_a29 := ddx_party_search_rec.custom_attribute5;
    p6_a30 := ddx_party_search_rec.custom_attribute6;
    p6_a31 := ddx_party_search_rec.custom_attribute7;
    p6_a32 := ddx_party_search_rec.custom_attribute8;
    p6_a33 := ddx_party_search_rec.custom_attribute9;
    p6_a34 := ddx_party_search_rec.analysis_fy;
    p6_a35 := ddx_party_search_rec.avg_high_credit;
    p6_a36 := ddx_party_search_rec.best_time_contact_begin;
    p6_a37 := ddx_party_search_rec.best_time_contact_end;
    p6_a38 := ddx_party_search_rec.branch_flag;
    p6_a39 := ddx_party_search_rec.business_scope;
    p6_a40 := ddx_party_search_rec.ceo_name;
    p6_a41 := ddx_party_search_rec.ceo_title;
    p6_a42 := ddx_party_search_rec.cong_dist_code;
    p6_a43 := ddx_party_search_rec.content_source_number;
    p6_a44 := ddx_party_search_rec.content_source_type;
    p6_a45 := ddx_party_search_rec.control_yr;
    p6_a46 := ddx_party_search_rec.corporation_class;
    p6_a47 := ddx_party_search_rec.credit_score;
    p6_a48 := ddx_party_search_rec.credit_score_age;
    p6_a49 := ddx_party_search_rec.credit_score_class;
    p6_a50 := ddx_party_search_rec.credit_score_commentary;
    p6_a51 := ddx_party_search_rec.credit_score_commentary10;
    p6_a52 := ddx_party_search_rec.credit_score_commentary2;
    p6_a53 := ddx_party_search_rec.credit_score_commentary3;
    p6_a54 := ddx_party_search_rec.credit_score_commentary4;
    p6_a55 := ddx_party_search_rec.credit_score_commentary5;
    p6_a56 := ddx_party_search_rec.credit_score_commentary6;
    p6_a57 := ddx_party_search_rec.credit_score_commentary7;
    p6_a58 := ddx_party_search_rec.credit_score_commentary8;
    p6_a59 := ddx_party_search_rec.credit_score_commentary9;
    p6_a60 := ddx_party_search_rec.credit_score_date;
    p6_a61 := ddx_party_search_rec.credit_score_incd_default;
    p6_a62 := ddx_party_search_rec.credit_score_natl_percentile;
    p6_a63 := ddx_party_search_rec.curr_fy_potential_revenue;
    p6_a64 := ddx_party_search_rec.db_rating;
    p6_a65 := ddx_party_search_rec.debarments_count;
    p6_a66 := ddx_party_search_rec.debarments_date;
    p6_a67 := ddx_party_search_rec.debarment_ind;
    p6_a68 := ddx_party_search_rec.disadv_8a_ind;
    p6_a69 := ddx_party_search_rec.duns_number_c;
    p6_a70 := ddx_party_search_rec.employees_total;
    p6_a71 := ddx_party_search_rec.emp_at_primary_adr;
    p6_a72 := ddx_party_search_rec.emp_at_primary_adr_est_ind;
    p6_a73 := ddx_party_search_rec.emp_at_primary_adr_min_ind;
    p6_a74 := ddx_party_search_rec.emp_at_primary_adr_text;
    p6_a75 := ddx_party_search_rec.enquiry_duns;
    p6_a76 := ddx_party_search_rec.export_ind;
    p6_a77 := ddx_party_search_rec.failure_score;
    p6_a78 := ddx_party_search_rec.failure_score_age;
    p6_a79 := ddx_party_search_rec.failure_score_class;
    p6_a80 := ddx_party_search_rec.failure_score_commentary;
    p6_a81 := ddx_party_search_rec.failure_score_commentary10;
    p6_a82 := ddx_party_search_rec.failure_score_commentary2;
    p6_a83 := ddx_party_search_rec.failure_score_commentary3;
    p6_a84 := ddx_party_search_rec.failure_score_commentary4;
    p6_a85 := ddx_party_search_rec.failure_score_commentary5;
    p6_a86 := ddx_party_search_rec.failure_score_commentary6;
    p6_a87 := ddx_party_search_rec.failure_score_commentary7;
    p6_a88 := ddx_party_search_rec.failure_score_commentary8;
    p6_a89 := ddx_party_search_rec.failure_score_commentary9;
    p6_a90 := ddx_party_search_rec.failure_score_date;
    p6_a91 := ddx_party_search_rec.failure_score_incd_default;
    p6_a92 := ddx_party_search_rec.failure_score_override_code;
    p6_a93 := ddx_party_search_rec.fiscal_yearend_month;
    p6_a94 := ddx_party_search_rec.global_failure_score;
    p6_a95 := ddx_party_search_rec.gsa_indicator_flag;
    p6_a96 := ddx_party_search_rec.high_credit;
    p6_a97 := ddx_party_search_rec.hq_branch_ind;
    p6_a98 := ddx_party_search_rec.import_ind;
    p6_a99 := ddx_party_search_rec.incorp_year;
    p6_a100 := ddx_party_search_rec.internal_flag;
    p6_a101 := ddx_party_search_rec.jgzz_fiscal_code;
    p6_a102 := ddx_party_search_rec.party_all_names;
    p6_a103 := ddx_party_search_rec.known_as;
    p6_a104 := ddx_party_search_rec.known_as2;
    p6_a105 := ddx_party_search_rec.known_as3;
    p6_a106 := ddx_party_search_rec.known_as4;
    p6_a107 := ddx_party_search_rec.known_as5;
    p6_a108 := ddx_party_search_rec.labor_surplus_ind;
    p6_a109 := ddx_party_search_rec.legal_status;
    p6_a110 := ddx_party_search_rec.line_of_business;
    p6_a111 := ddx_party_search_rec.local_activity_code;
    p6_a112 := ddx_party_search_rec.local_activity_code_type;
    p6_a113 := ddx_party_search_rec.local_bus_identifier;
    p6_a114 := ddx_party_search_rec.local_bus_iden_type;
    p6_a115 := ddx_party_search_rec.maximum_credit_currency_code;
    p6_a116 := ddx_party_search_rec.maximum_credit_recommendation;
    p6_a117 := ddx_party_search_rec.minority_owned_ind;
    p6_a118 := ddx_party_search_rec.minority_owned_type;
    p6_a119 := ddx_party_search_rec.next_fy_potential_revenue;
    p6_a120 := ddx_party_search_rec.oob_ind;
    p6_a121 := ddx_party_search_rec.organization_name;
    p6_a122 := ddx_party_search_rec.organization_name_phonetic;
    p6_a123 := ddx_party_search_rec.organization_type;
    p6_a124 := ddx_party_search_rec.parent_sub_ind;
    p6_a125 := ddx_party_search_rec.paydex_norm;
    p6_a126 := ddx_party_search_rec.paydex_score;
    p6_a127 := ddx_party_search_rec.paydex_three_months_ago;
    p6_a128 := ddx_party_search_rec.pref_functional_currency;
    p6_a129 := ddx_party_search_rec.principal_name;
    p6_a130 := ddx_party_search_rec.principal_title;
    p6_a131 := ddx_party_search_rec.public_private_ownership_flag;
    p6_a132 := ddx_party_search_rec.registration_type;
    p6_a133 := ddx_party_search_rec.rent_own_ind;
    p6_a134 := ddx_party_search_rec.sic_code;
    p6_a135 := ddx_party_search_rec.sic_code_type;
    p6_a136 := ddx_party_search_rec.small_bus_ind;
    p6_a137 := ddx_party_search_rec.tax_name;
    p6_a138 := ddx_party_search_rec.tax_reference;
    p6_a139 := ddx_party_search_rec.total_employees_text;
    p6_a140 := ddx_party_search_rec.total_emp_est_ind;
    p6_a141 := ddx_party_search_rec.total_emp_min_ind;
    p6_a142 := ddx_party_search_rec.total_employees_ind;
    p6_a143 := ddx_party_search_rec.total_payments;
    p6_a144 := ddx_party_search_rec.woman_owned_ind;
    p6_a145 := ddx_party_search_rec.year_established;
    p6_a146 := ddx_party_search_rec.category_code;
    p6_a147 := ddx_party_search_rec.competitor_flag;
    p6_a148 := ddx_party_search_rec.do_not_mail_flag;
    p6_a149 := ddx_party_search_rec.group_type;
    p6_a150 := ddx_party_search_rec.language_name;
    p6_a151 := ddx_party_search_rec.party_name;
    p6_a152 := ddx_party_search_rec.party_number;
    p6_a153 := ddx_party_search_rec.party_type;
    p6_a154 := ddx_party_search_rec.reference_use_flag;
    p6_a155 := ddx_party_search_rec.salutation;
    p6_a156 := ddx_party_search_rec.status;
    p6_a157 := ddx_party_search_rec.third_party_flag;
    p6_a158 := ddx_party_search_rec.validated_flag;
    p6_a159 := ddx_party_search_rec.date_of_birth;
    p6_a160 := ddx_party_search_rec.date_of_death;
    p6_a161 := ddx_party_search_rec.effective_start_date;
    p6_a162 := ddx_party_search_rec.effective_end_date;
    p6_a163 := ddx_party_search_rec.declared_ethnicity;
    p6_a164 := ddx_party_search_rec.gender;
    p6_a165 := ddx_party_search_rec.head_of_household_flag;
    p6_a166 := ddx_party_search_rec.household_income;
    p6_a167 := ddx_party_search_rec.household_size;
    p6_a168 := ddx_party_search_rec.last_known_gps;
    p6_a169 := ddx_party_search_rec.marital_status;
    p6_a170 := ddx_party_search_rec.marital_status_effective_date;
    p6_a171 := ddx_party_search_rec.middle_name_phonetic;
    p6_a172 := ddx_party_search_rec.personal_income;
    p6_a173 := ddx_party_search_rec.person_academic_title;
    p6_a174 := ddx_party_search_rec.person_first_name;
    p6_a175 := ddx_party_search_rec.person_first_name_phonetic;
    p6_a176 := ddx_party_search_rec.person_identifier;
    p6_a177 := ddx_party_search_rec.person_iden_type;
    p6_a178 := ddx_party_search_rec.person_initials;
    p6_a179 := ddx_party_search_rec.person_last_name;
    p6_a180 := ddx_party_search_rec.person_last_name_phonetic;
    p6_a181 := ddx_party_search_rec.person_middle_name;
    p6_a182 := ddx_party_search_rec.person_name;
    p6_a183 := ddx_party_search_rec.person_name_phonetic;
    p6_a184 := ddx_party_search_rec.person_name_suffix;
    p6_a185 := ddx_party_search_rec.person_previous_last_name;
    p6_a186 := ddx_party_search_rec.person_pre_name_adjunct;
    p6_a187 := ddx_party_search_rec.person_title;
    p6_a188 := ddx_party_search_rec.place_of_birth;

    hz_party_search_w.rosetta_table_copy_out_p8(ddx_party_site_list, p7_a0
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
      );

    hz_party_search_w.rosetta_table_copy_out_p9(ddx_contact_list, p8_a0
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
      );

    hz_party_search_w.rosetta_table_copy_out_p10(ddx_contact_point_list, p9_a0
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
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      );



  end;

end hz_party_search_w;

/
