--------------------------------------------------------
--  DDL for Package Body OZF_ADJ_NEW_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ADJ_NEW_LINE_PVT_W" as
  /* $Header: ozfwanlb.pls 120.1 2006/04/04 18:01:24 rssharma noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_adj_new_line_pvt.adj_new_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_adj_new_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_type := a4(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).discount_type := a6(indx);
          t(ddindx).tier_type := a7(indx);
          t(ddindx).td_discount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).td_discount_type := a9(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).benefit_price_list_line_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).parent_adj_line_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a20(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_adj_new_line_pvt.adj_new_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adj_new_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_type;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a6(indx) := t(ddindx).discount_type;
          a7(indx) := t(ddindx).tier_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).td_discount);
          a9(indx) := t(ddindx).td_discount_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_price_list_line_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).parent_adj_line_id);
          a13(indx) := t(ddindx).start_date_active;
          a14(indx) := t(ddindx).end_date_active;
          a15(indx) := t(ddindx).creation_date;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).last_update_date;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy ozf_adj_new_line_pvt.adj_new_disc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_adj_new_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_type := a4(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).discount_type := a6(indx);
          t(ddindx).tier_type := a7(indx);
          t(ddindx).td_discount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).td_discount_type := a9(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).benefit_price_list_line_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).parent_adj_line_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).offer_adj_new_product_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).product_context := a14(indx);
          t(ddindx).product_attribute := a15(indx);
          t(ddindx).product_attr_value := a16(indx);
          t(ddindx).excluder_flag := a17(indx);
          t(ddindx).uom_code := a18(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).prod_obj_version_number := rosetta_g_miss_num_map(a27(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ozf_adj_new_line_pvt.adj_new_disc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adj_new_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_type;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a6(indx) := t(ddindx).discount_type;
          a7(indx) := t(ddindx).tier_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).td_discount);
          a9(indx) := t(ddindx).td_discount_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_price_list_line_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).parent_adj_line_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adj_new_product_id);
          a14(indx) := t(ddindx).product_context;
          a15(indx) := t(ddindx).product_attribute;
          a16(indx) := t(ddindx).product_attr_value;
          a17(indx) := t(ddindx).excluder_flag;
          a18(indx) := t(ddindx).uom_code;
          a19(indx) := t(ddindx).start_date_active;
          a20(indx) := t(ddindx).end_date_active;
          a21(indx) := t(ddindx).creation_date;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a23(indx) := t(ddindx).last_update_date;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).prod_obj_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure create_adj_new_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , x_offer_adj_new_line_id out nocopy  NUMBER
  )

  as
    ddp_adj_new_line_rec ozf_adj_new_line_pvt.adj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_new_line_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_new_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_new_line_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_new_line_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_new_line_rec.volume_type := p7_a4;
    ddp_adj_new_line_rec.discount := rosetta_g_miss_num_map(p7_a5);
    ddp_adj_new_line_rec.discount_type := p7_a6;
    ddp_adj_new_line_rec.tier_type := p7_a7;
    ddp_adj_new_line_rec.td_discount := rosetta_g_miss_num_map(p7_a8);
    ddp_adj_new_line_rec.td_discount_type := p7_a9;
    ddp_adj_new_line_rec.quantity := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_new_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a11);
    ddp_adj_new_line_rec.parent_adj_line_id := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_new_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_adj_new_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a14);
    ddp_adj_new_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_adj_new_line_rec.created_by := rosetta_g_miss_num_map(p7_a16);
    ddp_adj_new_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_adj_new_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a18);
    ddp_adj_new_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_adj_new_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a20);


    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.create_adj_new_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_new_line_rec,
      x_offer_adj_new_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_adj_new_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_adj_new_line_rec ozf_adj_new_line_pvt.adj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_new_line_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_new_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_new_line_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_new_line_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_new_line_rec.volume_type := p7_a4;
    ddp_adj_new_line_rec.discount := rosetta_g_miss_num_map(p7_a5);
    ddp_adj_new_line_rec.discount_type := p7_a6;
    ddp_adj_new_line_rec.tier_type := p7_a7;
    ddp_adj_new_line_rec.td_discount := rosetta_g_miss_num_map(p7_a8);
    ddp_adj_new_line_rec.td_discount_type := p7_a9;
    ddp_adj_new_line_rec.quantity := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_new_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a11);
    ddp_adj_new_line_rec.parent_adj_line_id := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_new_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_adj_new_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a14);
    ddp_adj_new_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_adj_new_line_rec.created_by := rosetta_g_miss_num_map(p7_a16);
    ddp_adj_new_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_adj_new_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a18);
    ddp_adj_new_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);
    ddp_adj_new_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a20);


    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.update_adj_new_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_new_line_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_adj_new_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  DATE := fnd_api.g_miss_date
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  DATE := fnd_api.g_miss_date
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_adj_new_line_rec ozf_adj_new_line_pvt.adj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_adj_new_line_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p4_a0);
    ddp_adj_new_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p4_a1);
    ddp_adj_new_line_rec.volume_from := rosetta_g_miss_num_map(p4_a2);
    ddp_adj_new_line_rec.volume_to := rosetta_g_miss_num_map(p4_a3);
    ddp_adj_new_line_rec.volume_type := p4_a4;
    ddp_adj_new_line_rec.discount := rosetta_g_miss_num_map(p4_a5);
    ddp_adj_new_line_rec.discount_type := p4_a6;
    ddp_adj_new_line_rec.tier_type := p4_a7;
    ddp_adj_new_line_rec.td_discount := rosetta_g_miss_num_map(p4_a8);
    ddp_adj_new_line_rec.td_discount_type := p4_a9;
    ddp_adj_new_line_rec.quantity := rosetta_g_miss_num_map(p4_a10);
    ddp_adj_new_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p4_a11);
    ddp_adj_new_line_rec.parent_adj_line_id := rosetta_g_miss_num_map(p4_a12);
    ddp_adj_new_line_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a13);
    ddp_adj_new_line_rec.end_date_active := rosetta_g_miss_date_in_map(p4_a14);
    ddp_adj_new_line_rec.creation_date := rosetta_g_miss_date_in_map(p4_a15);
    ddp_adj_new_line_rec.created_by := rosetta_g_miss_num_map(p4_a16);
    ddp_adj_new_line_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a17);
    ddp_adj_new_line_rec.last_updated_by := rosetta_g_miss_num_map(p4_a18);
    ddp_adj_new_line_rec.last_update_login := rosetta_g_miss_num_map(p4_a19);
    ddp_adj_new_line_rec.object_version_number := rosetta_g_miss_num_map(p4_a20);




    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.validate_adj_new_line(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_adj_new_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_adj_new_line_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_adj_new_line_rec ozf_adj_new_line_pvt.adj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_adj_new_line_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p0_a0);
    ddp_adj_new_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p0_a1);
    ddp_adj_new_line_rec.volume_from := rosetta_g_miss_num_map(p0_a2);
    ddp_adj_new_line_rec.volume_to := rosetta_g_miss_num_map(p0_a3);
    ddp_adj_new_line_rec.volume_type := p0_a4;
    ddp_adj_new_line_rec.discount := rosetta_g_miss_num_map(p0_a5);
    ddp_adj_new_line_rec.discount_type := p0_a6;
    ddp_adj_new_line_rec.tier_type := p0_a7;
    ddp_adj_new_line_rec.td_discount := rosetta_g_miss_num_map(p0_a8);
    ddp_adj_new_line_rec.td_discount_type := p0_a9;
    ddp_adj_new_line_rec.quantity := rosetta_g_miss_num_map(p0_a10);
    ddp_adj_new_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p0_a11);
    ddp_adj_new_line_rec.parent_adj_line_id := rosetta_g_miss_num_map(p0_a12);
    ddp_adj_new_line_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_adj_new_line_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a14);
    ddp_adj_new_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a15);
    ddp_adj_new_line_rec.created_by := rosetta_g_miss_num_map(p0_a16);
    ddp_adj_new_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_adj_new_line_rec.last_updated_by := rosetta_g_miss_num_map(p0_a18);
    ddp_adj_new_line_rec.last_update_login := rosetta_g_miss_num_map(p0_a19);
    ddp_adj_new_line_rec.object_version_number := rosetta_g_miss_num_map(p0_a20);



    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.check_adj_new_line_items(ddp_adj_new_line_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_adj_new_line_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
  )

  as
    ddp_adj_new_line_rec ozf_adj_new_line_pvt.adj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_adj_new_line_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_adj_new_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p5_a1);
    ddp_adj_new_line_rec.volume_from := rosetta_g_miss_num_map(p5_a2);
    ddp_adj_new_line_rec.volume_to := rosetta_g_miss_num_map(p5_a3);
    ddp_adj_new_line_rec.volume_type := p5_a4;
    ddp_adj_new_line_rec.discount := rosetta_g_miss_num_map(p5_a5);
    ddp_adj_new_line_rec.discount_type := p5_a6;
    ddp_adj_new_line_rec.tier_type := p5_a7;
    ddp_adj_new_line_rec.td_discount := rosetta_g_miss_num_map(p5_a8);
    ddp_adj_new_line_rec.td_discount_type := p5_a9;
    ddp_adj_new_line_rec.quantity := rosetta_g_miss_num_map(p5_a10);
    ddp_adj_new_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p5_a11);
    ddp_adj_new_line_rec.parent_adj_line_id := rosetta_g_miss_num_map(p5_a12);
    ddp_adj_new_line_rec.start_date_active := rosetta_g_miss_date_in_map(p5_a13);
    ddp_adj_new_line_rec.end_date_active := rosetta_g_miss_date_in_map(p5_a14);
    ddp_adj_new_line_rec.creation_date := rosetta_g_miss_date_in_map(p5_a15);
    ddp_adj_new_line_rec.created_by := rosetta_g_miss_num_map(p5_a16);
    ddp_adj_new_line_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_adj_new_line_rec.last_updated_by := rosetta_g_miss_num_map(p5_a18);
    ddp_adj_new_line_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);
    ddp_adj_new_line_rec.object_version_number := rosetta_g_miss_num_map(p5_a20);

    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.validate_adj_new_line_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_new_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_adj_new_disc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , x_offer_adj_new_line_id out nocopy  NUMBER
  )

  as
    ddp_adj_new_disc_rec ozf_adj_new_line_pvt.adj_new_disc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_new_disc_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_new_disc_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_new_disc_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_new_disc_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_new_disc_rec.volume_type := p7_a4;
    ddp_adj_new_disc_rec.discount := rosetta_g_miss_num_map(p7_a5);
    ddp_adj_new_disc_rec.discount_type := p7_a6;
    ddp_adj_new_disc_rec.tier_type := p7_a7;
    ddp_adj_new_disc_rec.td_discount := rosetta_g_miss_num_map(p7_a8);
    ddp_adj_new_disc_rec.td_discount_type := p7_a9;
    ddp_adj_new_disc_rec.quantity := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_new_disc_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a11);
    ddp_adj_new_disc_rec.parent_adj_line_id := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_new_disc_rec.offer_adj_new_product_id := rosetta_g_miss_num_map(p7_a13);
    ddp_adj_new_disc_rec.product_context := p7_a14;
    ddp_adj_new_disc_rec.product_attribute := p7_a15;
    ddp_adj_new_disc_rec.product_attr_value := p7_a16;
    ddp_adj_new_disc_rec.excluder_flag := p7_a17;
    ddp_adj_new_disc_rec.uom_code := p7_a18;
    ddp_adj_new_disc_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a19);
    ddp_adj_new_disc_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_adj_new_disc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_adj_new_disc_rec.created_by := rosetta_g_miss_num_map(p7_a22);
    ddp_adj_new_disc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_adj_new_disc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a24);
    ddp_adj_new_disc_rec.last_update_login := rosetta_g_miss_num_map(p7_a25);
    ddp_adj_new_disc_rec.object_version_number := rosetta_g_miss_num_map(p7_a26);
    ddp_adj_new_disc_rec.prod_obj_version_number := rosetta_g_miss_num_map(p7_a27);


    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.create_adj_new_disc(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_new_disc_rec,
      x_offer_adj_new_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_adj_new_disc(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_adj_new_disc_rec ozf_adj_new_line_pvt.adj_new_disc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_new_disc_rec.offer_adj_new_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_new_disc_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_new_disc_rec.volume_from := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_new_disc_rec.volume_to := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_new_disc_rec.volume_type := p7_a4;
    ddp_adj_new_disc_rec.discount := rosetta_g_miss_num_map(p7_a5);
    ddp_adj_new_disc_rec.discount_type := p7_a6;
    ddp_adj_new_disc_rec.tier_type := p7_a7;
    ddp_adj_new_disc_rec.td_discount := rosetta_g_miss_num_map(p7_a8);
    ddp_adj_new_disc_rec.td_discount_type := p7_a9;
    ddp_adj_new_disc_rec.quantity := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_new_disc_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a11);
    ddp_adj_new_disc_rec.parent_adj_line_id := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_new_disc_rec.offer_adj_new_product_id := rosetta_g_miss_num_map(p7_a13);
    ddp_adj_new_disc_rec.product_context := p7_a14;
    ddp_adj_new_disc_rec.product_attribute := p7_a15;
    ddp_adj_new_disc_rec.product_attr_value := p7_a16;
    ddp_adj_new_disc_rec.excluder_flag := p7_a17;
    ddp_adj_new_disc_rec.uom_code := p7_a18;
    ddp_adj_new_disc_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a19);
    ddp_adj_new_disc_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_adj_new_disc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_adj_new_disc_rec.created_by := rosetta_g_miss_num_map(p7_a22);
    ddp_adj_new_disc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_adj_new_disc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a24);
    ddp_adj_new_disc_rec.last_update_login := rosetta_g_miss_num_map(p7_a25);
    ddp_adj_new_disc_rec.object_version_number := rosetta_g_miss_num_map(p7_a26);
    ddp_adj_new_disc_rec.prod_obj_version_number := rosetta_g_miss_num_map(p7_a27);


    -- here's the delegated call to the old PL/SQL routine
    ozf_adj_new_line_pvt.update_adj_new_disc(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_new_disc_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ozf_adj_new_line_pvt_w;

/
