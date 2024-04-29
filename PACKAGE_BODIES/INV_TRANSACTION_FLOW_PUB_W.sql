--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTION_FLOW_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTION_FLOW_PUB_W" as
  /* $Header: INVWICTB.pls 115.1 2003/12/18 16:13:46 sthamman noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy inv_transaction_flow_pub.g_transaction_flow_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
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
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).start_org_id := a1(indx);
          t(ddindx).end_org_id := a2(indx);
          t(ddindx).organization_id := a3(indx);
          t(ddindx).line_number := a4(indx);
          t(ddindx).from_org_id := a5(indx);
          t(ddindx).from_organization_id := a6(indx);
          t(ddindx).to_org_id := a7(indx);
          t(ddindx).to_organization_id := a8(indx);
          t(ddindx).asset_item_pricing_option := a9(indx);
          t(ddindx).expense_item_pricing_option := a10(indx);
          t(ddindx).start_date := a11(indx);
          t(ddindx).end_date := a12(indx);
          t(ddindx).customer_id := a13(indx);
          t(ddindx).address_id := a14(indx);
          t(ddindx).customer_site_id := a15(indx);
          t(ddindx).cust_trx_type_id := a16(indx);
          t(ddindx).vendor_id := a17(indx);
          t(ddindx).vendor_site_id := a18(indx);
          t(ddindx).freight_code_combination_id := a19(indx);
          t(ddindx).inventory_accrual_account_id := a20(indx);
          t(ddindx).expense_accrual_account_id := a21(indx);
          t(ddindx).intercompany_cogs_account_id := a22(indx);
          t(ddindx).new_accounting_flag := a23(indx);
          t(ddindx).from_org_cost_group_id := a24(indx);
          t(ddindx).to_org_cost_group_id := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t inv_transaction_flow_pub.g_transaction_flow_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
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
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
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
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
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
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
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
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
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
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).start_org_id;
          a2(indx) := t(ddindx).end_org_id;
          a3(indx) := t(ddindx).organization_id;
          a4(indx) := t(ddindx).line_number;
          a5(indx) := t(ddindx).from_org_id;
          a6(indx) := t(ddindx).from_organization_id;
          a7(indx) := t(ddindx).to_org_id;
          a8(indx) := t(ddindx).to_organization_id;
          a9(indx) := t(ddindx).asset_item_pricing_option;
          a10(indx) := t(ddindx).expense_item_pricing_option;
          a11(indx) := t(ddindx).start_date;
          a12(indx) := t(ddindx).end_date;
          a13(indx) := t(ddindx).customer_id;
          a14(indx) := t(ddindx).address_id;
          a15(indx) := t(ddindx).customer_site_id;
          a16(indx) := t(ddindx).cust_trx_type_id;
          a17(indx) := t(ddindx).vendor_id;
          a18(indx) := t(ddindx).vendor_site_id;
          a19(indx) := t(ddindx).freight_code_combination_id;
          a20(indx) := t(ddindx).inventory_accrual_account_id;
          a21(indx) := t(ddindx).expense_accrual_account_id;
          a22(indx) := t(ddindx).intercompany_cogs_account_id;
          a23(indx) := t(ddindx).new_accounting_flag;
          a24(indx) := t(ddindx).from_org_cost_group_id;
          a25(indx) := t(ddindx).to_org_cost_group_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy inv_transaction_flow_pub.number_tbl, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p10(t inv_transaction_flow_pub.number_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure rosetta_table_copy_in_p11(t out nocopy inv_transaction_flow_pub.varchar2_tbl, a0 JTF_VARCHAR2_TABLE_200) as
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
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t inv_transaction_flow_pub.varchar2_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
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
  end rosetta_table_copy_out_p11;

  procedure get_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_DATE_TABLE
    , p3_a12 out nocopy JTF_DATE_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_NUMBER_TABLE
    , p3_a22 out nocopy JTF_NUMBER_TABLE
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_operating_unit  NUMBER
    , p_end_operating_unit  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code_tbl JTF_NUMBER_TABLE
    , p_qualifier_value_tbl JTF_NUMBER_TABLE
    , p_transaction_date  DATE
    , p_get_default_cost_group  VARCHAR2
  )

  as
    ddx_transaction_flows_tbl inv_transaction_flow_pub.g_transaction_flow_tbl_type;
    ddp_qualifier_code_tbl inv_transaction_flow_pub.number_tbl;
    ddp_qualifier_value_tbl inv_transaction_flow_pub.number_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_qualifier_code_tbl, p_qualifier_code_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_qualifier_value_tbl, p_qualifier_value_tbl);

    -- here's the delegated call to the old PL/SQL routine
    inv_transaction_flow_pub.get_transaction_flow(x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_transaction_flows_tbl,
      p_api_version,
      p_init_msg_list,
      p_start_operating_unit,
      p_end_operating_unit,
      p_flow_type,
      p_organization_id,
      ddp_qualifier_code_tbl,
      ddp_qualifier_value_tbl,
      p_transaction_date,
      p_get_default_cost_group);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_out_p9(ddx_transaction_flows_tbl, p3_a0
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
      );

  end;

  procedure get_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_DATE_TABLE
    , p3_a12 out nocopy JTF_DATE_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_NUMBER_TABLE
    , p3_a22 out nocopy JTF_NUMBER_TABLE
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_header_id  NUMBER
    , p_get_default_cost_group  VARCHAR2
  )

  as
    ddx_transaction_flows_tbl inv_transaction_flow_pub.g_transaction_flow_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    inv_transaction_flow_pub.get_transaction_flow(x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_transaction_flows_tbl,
      p_api_version,
      p_init_msg_list,
      p_header_id,
      p_get_default_cost_group);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_out_p9(ddx_transaction_flows_tbl, p3_a0
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
      );

  end;

  procedure check_transaction_flow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_operating_unit  NUMBER
    , p_end_operating_unit  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code_tbl JTF_NUMBER_TABLE
    , p_qualifier_value_tbl JTF_NUMBER_TABLE
    , p_transaction_date  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_header_id out nocopy  NUMBER
    , x_new_accounting_flag out nocopy  VARCHAR2
    , x_transaction_flow_exists out nocopy  VARCHAR2
  )

  as
    ddp_qualifier_code_tbl inv_transaction_flow_pub.number_tbl;
    ddp_qualifier_value_tbl inv_transaction_flow_pub.number_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_qualifier_code_tbl, p_qualifier_code_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_qualifier_value_tbl, p_qualifier_value_tbl);

    -- here's the delegated call to the old PL/SQL routine
    inv_transaction_flow_pub.check_transaction_flow(p_api_version,
      p_init_msg_list,
      p_start_operating_unit,
      p_end_operating_unit,
      p_flow_type,
      p_organization_id,
      ddp_qualifier_code_tbl,
      ddp_qualifier_value_tbl,
      p_transaction_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_header_id,
      x_new_accounting_flag,
      x_transaction_flow_exists);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure create_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_header_id out nocopy  NUMBER
    , x_line_number_tbl out nocopy JTF_NUMBER_TABLE
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_org_id  NUMBER
    , p_end_org_id  NUMBER
    , p_flow_type  NUMBER
    , p_organization_id  NUMBER
    , p_qualifier_code  NUMBER
    , p_qualifier_value_id  NUMBER
    , p_asset_item_pricing_option  NUMBER
    , p_expense_item_pricing_option  NUMBER
    , p_new_accounting_flag  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_line_number_tbl JTF_NUMBER_TABLE
    , p_from_org_id_tbl JTF_NUMBER_TABLE
    , p_from_organization_id_tbl JTF_NUMBER_TABLE
    , p_to_org_id_tbl JTF_NUMBER_TABLE
    , p_to_organization_id_tbl JTF_NUMBER_TABLE
    , p_line_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_ship_organization_id_tbl JTF_NUMBER_TABLE
    , p_sell_organization_id_tbl JTF_NUMBER_TABLE
    , p_vendor_id_tbl JTF_NUMBER_TABLE
    , p_vendor_site_id_tbl JTF_NUMBER_TABLE
    , p_customer_id_tbl JTF_NUMBER_TABLE
    , p_address_id_tbl JTF_NUMBER_TABLE
    , p_customer_site_id_tbl JTF_NUMBER_TABLE
    , p_cust_trx_type_id_tbl JTF_NUMBER_TABLE
    , p_ic_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_revalue_average_flag_tbl JTF_VARCHAR2_TABLE_200
    , p_freight_code_comb_id_tbl JTF_NUMBER_TABLE
    , p_inv_currency_code_tbl JTF_NUMBER_TABLE
    , p_ic_cogs_acct_id_tbl JTF_NUMBER_TABLE
    , p_inv_accrual_acct_id_tbl JTF_NUMBER_TABLE
    , p_exp_accrual_acct_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddx_line_number_tbl inv_transaction_flow_pub.number_tbl;
    ddp_line_number_tbl inv_transaction_flow_pub.number_tbl;
    ddp_from_org_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_from_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_to_org_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_to_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_line_attr_category_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute1_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute2_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute3_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute4_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute5_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute6_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute7_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute8_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute9_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute10_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute11_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute12_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute13_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute14_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute15_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ship_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_sell_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_vendor_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_vendor_site_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_customer_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_address_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_customer_site_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_cust_trx_type_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_ic_attribute_category_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute1_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute2_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute3_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute4_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute5_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute6_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute7_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute8_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute9_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute10_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute11_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute12_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute13_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute14_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute15_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_revalue_average_flag_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_freight_code_comb_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_inv_currency_code_tbl inv_transaction_flow_pub.number_tbl;
    ddp_ic_cogs_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_inv_accrual_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_exp_accrual_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_line_number_tbl, p_line_number_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_from_org_id_tbl, p_from_org_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_from_organization_id_tbl, p_from_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_to_org_id_tbl, p_to_org_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_to_organization_id_tbl, p_to_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attr_category_tbl, p_line_attribute_category_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute1_tbl, p_line_attribute1_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute2_tbl, p_line_attribute2_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute3_tbl, p_line_attribute3_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute4_tbl, p_line_attribute4_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute5_tbl, p_line_attribute5_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute6_tbl, p_line_attribute6_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute7_tbl, p_line_attribute7_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute8_tbl, p_line_attribute8_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute9_tbl, p_line_attribute9_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute10_tbl, p_line_attribute10_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute11_tbl, p_line_attribute11_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute12_tbl, p_line_attribute12_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute13_tbl, p_line_attribute13_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute14_tbl, p_line_attribute14_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute15_tbl, p_line_attribute15_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_ship_organization_id_tbl, p_ship_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_sell_organization_id_tbl, p_sell_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_vendor_id_tbl, p_vendor_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_vendor_site_id_tbl, p_vendor_site_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_customer_id_tbl, p_customer_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_address_id_tbl, p_address_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_customer_site_id_tbl, p_customer_site_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_cust_trx_type_id_tbl, p_cust_trx_type_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute_category_tbl, p_ic_attribute_category_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute1_tbl, p_ic_attribute1_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute2_tbl, p_ic_attribute2_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute3_tbl, p_ic_attribute3_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute4_tbl, p_ic_attribute4_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute5_tbl, p_ic_attribute5_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute6_tbl, p_ic_attribute6_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute7_tbl, p_ic_attribute7_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute8_tbl, p_ic_attribute8_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute9_tbl, p_ic_attribute9_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute10_tbl, p_ic_attribute10_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute11_tbl, p_ic_attribute11_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute12_tbl, p_ic_attribute12_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute13_tbl, p_ic_attribute13_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute14_tbl, p_ic_attribute14_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute15_tbl, p_ic_attribute15_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_revalue_average_flag_tbl, p_revalue_average_flag_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_freight_code_comb_id_tbl, p_freight_code_comb_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_inv_currency_code_tbl, p_inv_currency_code_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_ic_cogs_acct_id_tbl, p_ic_cogs_acct_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_inv_accrual_acct_id_tbl, p_inv_accrual_acct_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_exp_accrual_acct_id_tbl, p_exp_accrual_acct_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    inv_transaction_flow_pub.create_transaction_flow(x_return_status,
      x_msg_data,
      x_msg_count,
      x_header_id,
      ddx_line_number_tbl,
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_start_org_id,
      p_end_org_id,
      p_flow_type,
      p_organization_id,
      p_qualifier_code,
      p_qualifier_value_id,
      p_asset_item_pricing_option,
      p_expense_item_pricing_option,
      p_new_accounting_flag,
      p_start_date,
      p_end_date,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      ddp_line_number_tbl,
      ddp_from_org_id_tbl,
      ddp_from_organization_id_tbl,
      ddp_to_org_id_tbl,
      ddp_to_organization_id_tbl,
      ddp_line_attr_category_tbl,
      ddp_line_attribute1_tbl,
      ddp_line_attribute2_tbl,
      ddp_line_attribute3_tbl,
      ddp_line_attribute4_tbl,
      ddp_line_attribute5_tbl,
      ddp_line_attribute6_tbl,
      ddp_line_attribute7_tbl,
      ddp_line_attribute8_tbl,
      ddp_line_attribute9_tbl,
      ddp_line_attribute10_tbl,
      ddp_line_attribute11_tbl,
      ddp_line_attribute12_tbl,
      ddp_line_attribute13_tbl,
      ddp_line_attribute14_tbl,
      ddp_line_attribute15_tbl,
      ddp_ship_organization_id_tbl,
      ddp_sell_organization_id_tbl,
      ddp_vendor_id_tbl,
      ddp_vendor_site_id_tbl,
      ddp_customer_id_tbl,
      ddp_address_id_tbl,
      ddp_customer_site_id_tbl,
      ddp_cust_trx_type_id_tbl,
      ddp_ic_attribute_category_tbl,
      ddp_ic_attribute1_tbl,
      ddp_ic_attribute2_tbl,
      ddp_ic_attribute3_tbl,
      ddp_ic_attribute4_tbl,
      ddp_ic_attribute5_tbl,
      ddp_ic_attribute6_tbl,
      ddp_ic_attribute7_tbl,
      ddp_ic_attribute8_tbl,
      ddp_ic_attribute9_tbl,
      ddp_ic_attribute10_tbl,
      ddp_ic_attribute11_tbl,
      ddp_ic_attribute12_tbl,
      ddp_ic_attribute13_tbl,
      ddp_ic_attribute14_tbl,
      ddp_ic_attribute15_tbl,
      ddp_revalue_average_flag_tbl,
      ddp_freight_code_comb_id_tbl,
      ddp_inv_currency_code_tbl,
      ddp_ic_cogs_acct_id_tbl,
      ddp_inv_accrual_acct_id_tbl,
      ddp_exp_accrual_acct_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_out_p10(ddx_line_number_tbl, x_line_number_tbl);

  end;

  procedure update_transaction_flow(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_header_id  NUMBER
    , p_flow_type  NUMBER
    , p_start_date  DATE
    , p_end_date  DATE
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_line_number_tbl JTF_NUMBER_TABLE
    , p_line_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_line_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_ship_organization_id_tbl JTF_NUMBER_TABLE
    , p_sell_organization_id_tbl JTF_NUMBER_TABLE
    , p_vendor_id_tbl JTF_NUMBER_TABLE
    , p_vendor_site_id_tbl JTF_NUMBER_TABLE
    , p_customer_id_tbl JTF_NUMBER_TABLE
    , p_address_id_tbl JTF_NUMBER_TABLE
    , p_customer_site_id_tbl JTF_NUMBER_TABLE
    , p_cust_trx_type_id_tbl JTF_NUMBER_TABLE
    , p_ic_attribute_category_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute1_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute2_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute3_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute4_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute5_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute6_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute7_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute8_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute9_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute10_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute11_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute12_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute13_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute14_tbl JTF_VARCHAR2_TABLE_200
    , p_ic_attribute15_tbl JTF_VARCHAR2_TABLE_200
    , p_revalue_average_flag_tbl JTF_VARCHAR2_TABLE_200
    , p_freight_code_comb_id_tbl JTF_NUMBER_TABLE
    , p_inv_currency_code_tbl JTF_NUMBER_TABLE
    , p_ic_cogs_acct_id_tbl JTF_NUMBER_TABLE
    , p_inv_accrual_acct_id_tbl JTF_NUMBER_TABLE
    , p_exp_accrual_acct_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_line_number_tbl inv_transaction_flow_pub.number_tbl;
    ddp_line_attr_category_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute1_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute2_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute3_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute4_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute5_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute6_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute7_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute8_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute9_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute10_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute11_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute12_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute13_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute14_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_line_attribute15_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ship_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_sell_organization_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_vendor_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_vendor_site_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_customer_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_address_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_customer_site_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_cust_trx_type_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_ic_attribute_category_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute1_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute2_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute3_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute4_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute5_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute6_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute7_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute8_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute9_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute10_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute11_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute12_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute13_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute14_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_ic_attribute15_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_revalue_average_flag_tbl inv_transaction_flow_pub.varchar2_tbl;
    ddp_freight_code_comb_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_inv_currency_code_tbl inv_transaction_flow_pub.number_tbl;
    ddp_ic_cogs_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_inv_accrual_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddp_exp_accrual_acct_id_tbl inv_transaction_flow_pub.number_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_line_number_tbl, p_line_number_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attr_category_tbl, p_line_attribute_category_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute1_tbl, p_line_attribute1_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute2_tbl, p_line_attribute2_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute3_tbl, p_line_attribute3_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute4_tbl, p_line_attribute4_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute5_tbl, p_line_attribute5_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute6_tbl, p_line_attribute6_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute7_tbl, p_line_attribute7_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute8_tbl, p_line_attribute8_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute9_tbl, p_line_attribute9_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute10_tbl, p_line_attribute10_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute11_tbl, p_line_attribute11_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute12_tbl, p_line_attribute12_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute13_tbl, p_line_attribute13_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute14_tbl, p_line_attribute14_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_line_attribute15_tbl, p_line_attribute15_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_ship_organization_id_tbl, p_ship_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_sell_organization_id_tbl, p_sell_organization_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_vendor_id_tbl, p_vendor_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_vendor_site_id_tbl, p_vendor_site_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_customer_id_tbl, p_customer_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_address_id_tbl, p_address_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_customer_site_id_tbl, p_customer_site_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_cust_trx_type_id_tbl, p_cust_trx_type_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute_category_tbl, p_ic_attribute_category_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute1_tbl, p_ic_attribute1_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute2_tbl, p_ic_attribute2_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute3_tbl, p_ic_attribute3_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute4_tbl, p_ic_attribute4_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute5_tbl, p_ic_attribute5_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute6_tbl, p_ic_attribute6_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute7_tbl, p_ic_attribute7_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute8_tbl, p_ic_attribute8_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute9_tbl, p_ic_attribute9_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute10_tbl, p_ic_attribute10_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute11_tbl, p_ic_attribute11_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute12_tbl, p_ic_attribute12_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute13_tbl, p_ic_attribute13_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute14_tbl, p_ic_attribute14_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_ic_attribute15_tbl, p_ic_attribute15_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p11(ddp_revalue_average_flag_tbl, p_revalue_average_flag_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_freight_code_comb_id_tbl, p_freight_code_comb_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_inv_currency_code_tbl, p_inv_currency_code_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_ic_cogs_acct_id_tbl, p_ic_cogs_acct_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_inv_accrual_acct_id_tbl, p_inv_accrual_acct_id_tbl);

    inv_transaction_flow_pub_w.rosetta_table_copy_in_p10(ddp_exp_accrual_acct_id_tbl, p_exp_accrual_acct_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    inv_transaction_flow_pub.update_transaction_flow(x_return_status,
      x_msg_data,
      x_msg_count,
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_header_id,
      p_flow_type,
      p_start_date,
      p_end_date,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      ddp_line_number_tbl,
      ddp_line_attr_category_tbl,
      ddp_line_attribute1_tbl,
      ddp_line_attribute2_tbl,
      ddp_line_attribute3_tbl,
      ddp_line_attribute4_tbl,
      ddp_line_attribute5_tbl,
      ddp_line_attribute6_tbl,
      ddp_line_attribute7_tbl,
      ddp_line_attribute8_tbl,
      ddp_line_attribute9_tbl,
      ddp_line_attribute10_tbl,
      ddp_line_attribute11_tbl,
      ddp_line_attribute12_tbl,
      ddp_line_attribute13_tbl,
      ddp_line_attribute14_tbl,
      ddp_line_attribute15_tbl,
      ddp_ship_organization_id_tbl,
      ddp_sell_organization_id_tbl,
      ddp_vendor_id_tbl,
      ddp_vendor_site_id_tbl,
      ddp_customer_id_tbl,
      ddp_address_id_tbl,
      ddp_customer_site_id_tbl,
      ddp_cust_trx_type_id_tbl,
      ddp_ic_attribute_category_tbl,
      ddp_ic_attribute1_tbl,
      ddp_ic_attribute2_tbl,
      ddp_ic_attribute3_tbl,
      ddp_ic_attribute4_tbl,
      ddp_ic_attribute5_tbl,
      ddp_ic_attribute6_tbl,
      ddp_ic_attribute7_tbl,
      ddp_ic_attribute8_tbl,
      ddp_ic_attribute9_tbl,
      ddp_ic_attribute10_tbl,
      ddp_ic_attribute11_tbl,
      ddp_ic_attribute12_tbl,
      ddp_ic_attribute13_tbl,
      ddp_ic_attribute14_tbl,
      ddp_ic_attribute15_tbl,
      ddp_revalue_average_flag_tbl,
      ddp_freight_code_comb_id_tbl,
      ddp_inv_currency_code_tbl,
      ddp_ic_cogs_acct_id_tbl,
      ddp_inv_accrual_acct_id_tbl,
      ddp_exp_accrual_acct_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
  end;

end inv_transaction_flow_pub_w;

/
