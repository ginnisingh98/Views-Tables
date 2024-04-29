--------------------------------------------------------
--  DDL for Package Body PV_OFFER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_OFFER_PUB_W" as
  /* $Header: pvxwoffb.pls 120.1 2005/06/16 17:26 appldev  $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_offer_pub.discount_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).discount := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).discount_type := a3(indx);
          t(ddindx).tier_type := a4(indx);
          t(ddindx).tier_level := a5(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).product_level := a7(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).operation := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_offer_pub.discount_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a3(indx) := t(ddindx).discount_type;
          a4(indx) := t(ddindx).tier_type;
          a5(indx) := t(ddindx).tier_level;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).product_level;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a9(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy pv_offer_pub.na_qualifier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).qualifier_context := a1(indx);
          t(ddindx).qualifier_attribute := a2(indx);
          t(ddindx).qualifier_attr_value := a3(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).operation := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pv_offer_pub.na_qualifier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a1(indx) := t(ddindx).qualifier_context;
          a2(indx) := t(ddindx).qualifier_attribute;
          a3(indx) := t(ddindx).qualifier_attr_value;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy pv_offer_pub.budget_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).act_budget_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).budget_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).budget_amount := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).operation := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t pv_offer_pub.budget_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).act_budget_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).budget_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount);
          a3(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_offer(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_benefit_id  NUMBER
    , p_operation  VARCHAR2
    , p_offer_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_VARCHAR2_TABLE_300
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , x_offer_id out nocopy  NUMBER
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_modifier_list_rec pv_offer_pub.modifier_list_rec_type;
    ddp_budget_tbl pv_offer_pub.budget_tbl_type;
    ddp_discount_tbl pv_offer_pub.discount_line_tbl_type;
    ddp_na_qualifier_tbl pv_offer_pub.na_qualifier_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_modifier_list_rec.offer_id := rosetta_g_miss_num_map(p6_a0);
    ddp_modifier_list_rec.qp_list_header_id := rosetta_g_miss_num_map(p6_a1);
    ddp_modifier_list_rec.offer_type := p6_a2;
    ddp_modifier_list_rec.offer_code := p6_a3;
    ddp_modifier_list_rec.user_status_id := rosetta_g_miss_num_map(p6_a4);
    ddp_modifier_list_rec.object_version_number := rosetta_g_miss_num_map(p6_a5);
    ddp_modifier_list_rec.status_code := p6_a6;
    ddp_modifier_list_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a7);
    ddp_modifier_list_rec.budget_amount_tc := rosetta_g_miss_num_map(p6_a8);
    ddp_modifier_list_rec.transaction_currency_code := p6_a9;
    ddp_modifier_list_rec.functional_currency_code := p6_a10;
    ddp_modifier_list_rec.currency_code := p6_a11;
    ddp_modifier_list_rec.name := p6_a12;
    ddp_modifier_list_rec.description := p6_a13;
    ddp_modifier_list_rec.comments := p6_a14;
    ddp_modifier_list_rec.offer_operation := p6_a15;
    ddp_modifier_list_rec.modifier_operation := p6_a16;
    ddp_modifier_list_rec.budget_offer_yn := p6_a17;
    ddp_modifier_list_rec.tier_level := p6_a18;

    pv_offer_pub_w.rosetta_table_copy_in_p6(ddp_budget_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );

    pv_offer_pub_w.rosetta_table_copy_in_p2(ddp_discount_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );

    pv_offer_pub_w.rosetta_table_copy_in_p4(ddp_na_qualifier_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      );







    -- here's the delegated call to the old PL/SQL routine
    pv_offer_pub.create_offer(p_init_msg_list,
      p_api_version,
      p_commit,
      p_benefit_id,
      p_operation,
      p_offer_id,
      ddp_modifier_list_rec,
      ddp_budget_tbl,
      ddp_discount_tbl,
      ddp_na_qualifier_tbl,
      x_offer_id,
      x_qp_list_header_id,
      x_error_location,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

end pv_offer_pub_w;

/
