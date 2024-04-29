--------------------------------------------------------
--  DDL for Package Body JTF_FULFILLMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FULFILLMENT_PUB_W" as
  /* $Header: jtfgfmpwb.pls 120.0 2005/05/11 08:14:42 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy jtf_fulfillment_pub.order_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ship_party_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).ship_party_site_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).ship_method_code := a2(indx);
          t(ddindx).quantity := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t jtf_fulfillment_pub.order_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ship_party_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).ship_party_site_id);
          a2(indx) := t(ddindx).ship_method_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_fulfill_physical(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , x_request_history_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_order_header_rec jtf_fulfillment_pub.order_header_rec_type;
    ddp_order_line_tbl jtf_fulfillment_pub.order_line_tbl_type;
    ddx_order_header_rec aso_order_int.order_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_order_header_rec.cust_party_id := rosetta_g_miss_num_map(p6_a0);
    ddp_order_header_rec.cust_account_id := rosetta_g_miss_num_map(p6_a1);
    ddp_order_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p6_a2);
    ddp_order_header_rec.inv_party_id := rosetta_g_miss_num_map(p6_a3);
    ddp_order_header_rec.inv_party_site_id := rosetta_g_miss_num_map(p6_a4);
    ddp_order_header_rec.ship_party_site_id := rosetta_g_miss_num_map(p6_a5);
    ddp_order_header_rec.quote_source_code := p6_a6;
    ddp_order_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p6_a7);
    ddp_order_header_rec.order_type_id := rosetta_g_miss_num_map(p6_a8);
    ddp_order_header_rec.employee_id := rosetta_g_miss_num_map(p6_a9);
    ddp_order_header_rec.collateral_id := rosetta_g_miss_num_map(p6_a10);
    ddp_order_header_rec.cover_letter_id := rosetta_g_miss_num_map(p6_a11);
    ddp_order_header_rec.uom_code := p6_a12;
    ddp_order_header_rec.line_category_code := p6_a13;
    ddp_order_header_rec.inv_organization_id := rosetta_g_miss_num_map(p6_a14);

    jtf_fulfillment_pub_w.rosetta_table_copy_in_p2(ddp_order_line_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );



    -- here's the delegated call to the old PL/SQL routine
    jtf_fulfillment_pub.create_fulfill_physical(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_order_header_rec,
      ddp_order_line_tbl,
      ddx_order_header_rec,
      x_request_history_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_order_header_rec.order_number);
    p8_a1 := rosetta_g_miss_num_map(ddx_order_header_rec.order_header_id);
    p8_a2 := rosetta_g_miss_num_map(ddx_order_header_rec.quote_header_id);
    p8_a3 := ddx_order_header_rec.status;

  end;

end jtf_fulfillment_pub_w;

/
