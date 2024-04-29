--------------------------------------------------------
--  DDL for Package Body OZF_FUND_ALLOCATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_ALLOCATIONS_PVT_W" as
  /* $Header: ozfwalcb.pls 115.3 2003/10/01 09:57:05 kdass noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy ozf_fund_allocations_pvt.fact_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
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
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
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
    , a81 JTF_DATE_TABLE
    , a82 JTF_DATE_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_DATE_TABLE
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).activity_metric_fact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).act_metric_used_by_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).arc_act_metric_used_by := a8(indx);
          t(ddindx).value_type := a9(indx);
          t(ddindx).activity_metric_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).activity_geo_area_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).activity_product_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).transaction_currency_code := a13(indx);
          t(ddindx).trans_forecasted_value := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).base_quantity := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).functional_currency_code := a16(indx);
          t(ddindx).func_forecasted_value := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).de_metric_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).de_geographic_area_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).de_geographic_area_type := a21(indx);
          t(ddindx).de_inventory_item_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).de_inventory_item_org_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).time_id1 := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).time_id2 := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).time_id3 := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).time_id4 := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).time_id5 := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).time_id6 := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).time_id7 := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).time_id8 := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).time_id9 := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).time_id10 := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).time_id11 := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).time_id12 := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).time_id13 := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).time_id14 := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).time_id15 := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).time_id16 := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).time_id17 := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).time_id18 := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).time_id19 := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).time_id20 := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).time_id21 := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).time_id22 := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).time_id23 := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).time_id24 := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).time_id25 := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).time_id26 := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).time_id27 := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).time_id28 := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).time_id29 := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).time_id30 := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).time_id31 := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).time_id32 := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).time_id33 := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).time_id34 := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).time_id35 := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).time_id36 := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).time_id37 := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).time_id38 := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).time_id39 := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).time_id40 := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).time_id41 := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).time_id42 := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).time_id43 := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).time_id44 := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).time_id45 := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).time_id46 := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).time_id47 := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).time_id48 := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).time_id49 := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).time_id50 := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).time_id51 := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).time_id52 := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).time_id53 := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).hierarchy_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).node_id := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).level_depth := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).formula_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a81(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a82(indx));
          t(ddindx).fact_value := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).fact_percent := rosetta_g_miss_num_map(a84(indx));
          t(ddindx).root_fact_id := rosetta_g_miss_num_map(a85(indx));
          t(ddindx).previous_fact_id := rosetta_g_miss_num_map(a86(indx));
          t(ddindx).fact_type := a87(indx);
          t(ddindx).fact_reference := a88(indx);
          t(ddindx).forward_buy_quantity := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).status_code := a90(indx);
          t(ddindx).hierarchy_type := a91(indx);
          t(ddindx).approval_date := rosetta_g_miss_date_in_map(a92(indx));
          t(ddindx).recommend_total_amount := rosetta_g_miss_num_map(a93(indx));
          t(ddindx).recommend_hb_amount := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).request_total_amount := rosetta_g_miss_num_map(a95(indx));
          t(ddindx).request_hb_amount := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).actual_total_amount := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).actual_hb_amount := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).base_total_pct := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).base_hb_pct := rosetta_g_miss_num_map(a100(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t ozf_fund_allocations_pvt.fact_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
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
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_DATE_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_NUMBER_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_DATE_TABLE
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_NUMBER_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_NUMBER_TABLE
    , a98 out nocopy JTF_NUMBER_TABLE
    , a99 out nocopy JTF_NUMBER_TABLE
    , a100 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
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
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
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
    a81 := JTF_DATE_TABLE();
    a82 := JTF_DATE_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_NUMBER_TABLE();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_DATE_TABLE();
    a93 := JTF_NUMBER_TABLE();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_NUMBER_TABLE();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
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
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
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
      a81 := JTF_DATE_TABLE();
      a82 := JTF_DATE_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_NUMBER_TABLE();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_DATE_TABLE();
      a93 := JTF_NUMBER_TABLE();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_NUMBER_TABLE();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).activity_metric_fact_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).act_metric_used_by_id);
          a8(indx) := t(ddindx).arc_act_metric_used_by;
          a9(indx) := t(ddindx).value_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).activity_metric_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).activity_geo_area_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).activity_product_id);
          a13(indx) := t(ddindx).transaction_currency_code;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).trans_forecasted_value);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).base_quantity);
          a16(indx) := t(ddindx).functional_currency_code;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).func_forecasted_value);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).de_metric_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).de_geographic_area_id);
          a21(indx) := t(ddindx).de_geographic_area_type;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).de_inventory_item_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).de_inventory_item_org_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).time_id1);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).time_id2);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).time_id3);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).time_id4);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).time_id5);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).time_id6);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).time_id7);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).time_id8);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).time_id9);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).time_id10);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).time_id11);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).time_id12);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).time_id13);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).time_id14);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).time_id15);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).time_id16);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).time_id17);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).time_id18);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).time_id19);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).time_id20);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).time_id21);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).time_id22);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).time_id23);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).time_id24);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).time_id25);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).time_id26);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).time_id27);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).time_id28);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).time_id29);
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).time_id30);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).time_id31);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).time_id32);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).time_id33);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).time_id34);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).time_id35);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).time_id36);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).time_id37);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).time_id38);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).time_id39);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).time_id40);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).time_id41);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).time_id42);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).time_id43);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).time_id44);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).time_id45);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).time_id46);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).time_id47);
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).time_id48);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).time_id49);
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).time_id50);
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).time_id51);
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).time_id52);
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).time_id53);
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).hierarchy_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).node_id);
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).level_depth);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a81(indx) := t(ddindx).from_date;
          a82(indx) := t(ddindx).to_date;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).fact_value);
          a84(indx) := rosetta_g_miss_num_map(t(ddindx).fact_percent);
          a85(indx) := rosetta_g_miss_num_map(t(ddindx).root_fact_id);
          a86(indx) := rosetta_g_miss_num_map(t(ddindx).previous_fact_id);
          a87(indx) := t(ddindx).fact_type;
          a88(indx) := t(ddindx).fact_reference;
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).forward_buy_quantity);
          a90(indx) := t(ddindx).status_code;
          a91(indx) := t(ddindx).hierarchy_type;
          a92(indx) := t(ddindx).approval_date;
          a93(indx) := rosetta_g_miss_num_map(t(ddindx).recommend_total_amount);
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).recommend_hb_amount);
          a95(indx) := rosetta_g_miss_num_map(t(ddindx).request_total_amount);
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).request_hb_amount);
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).actual_total_amount);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).actual_hb_amount);
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).base_total_pct);
          a100(indx) := rosetta_g_miss_num_map(t(ddindx).base_hb_pct);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_fund_allocations_pvt.factid_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fact_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).fact_obj_ver := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).approve_recommend := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_fund_allocations_pvt.factid_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).fact_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).fact_obj_ver);
          a2(indx) := t(ddindx).approve_recommend;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure update_worksheet_amount(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_alloc_id  NUMBER
    , p_alloc_obj_ver  NUMBER
    , p_cascade_flag  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_DATE_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_DATE_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_100
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_NUMBER_TABLE
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_NUMBER_TABLE
    , p7_a58 JTF_NUMBER_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_NUMBER_TABLE
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_NUMBER_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p7_a66 JTF_NUMBER_TABLE
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_NUMBER_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_NUMBER_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_NUMBER_TABLE
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_NUMBER_TABLE
    , p7_a80 JTF_NUMBER_TABLE
    , p7_a81 JTF_DATE_TABLE
    , p7_a82 JTF_DATE_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_VARCHAR2_TABLE_300
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_VARCHAR2_TABLE_100
    , p7_a91 JTF_VARCHAR2_TABLE_100
    , p7_a92 JTF_DATE_TABLE
    , p7_a93 JTF_NUMBER_TABLE
    , p7_a94 JTF_NUMBER_TABLE
    , p7_a95 JTF_NUMBER_TABLE
    , p7_a96 JTF_NUMBER_TABLE
    , p7_a97 JTF_NUMBER_TABLE
    , p7_a98 JTF_NUMBER_TABLE
    , p7_a99 JTF_NUMBER_TABLE
    , p7_a100 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fact_table ozf_fund_allocations_pvt.fact_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_fund_allocations_pvt_w.rosetta_table_copy_in_p0(ddp_fact_table, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_allocations_pvt.update_worksheet_amount(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_alloc_id,
      p_alloc_obj_ver,
      p_cascade_flag,
      ddp_fact_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure approve_levels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_approver_factid  NUMBER
    , p_approve_all_flag  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_factid_table ozf_fund_allocations_pvt.factid_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ozf_fund_allocations_pvt_w.rosetta_table_copy_in_p2(ddp_factid_table, p6_a0
      , p6_a1
      , p6_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_allocations_pvt.approve_levels(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_approver_factid,
      p_approve_all_flag,
      ddp_factid_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure reject_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_rejector_factid  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_factid_table ozf_fund_allocations_pvt.factid_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ozf_fund_allocations_pvt_w.rosetta_table_copy_in_p2(ddp_factid_table, p5_a0
      , p5_a1
      , p5_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_allocations_pvt.reject_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_rejector_factid,
      ddp_factid_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ozf_fund_allocations_pvt_w;

/
