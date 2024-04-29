--------------------------------------------------------
--  DDL for Package Body OZF_MASS_SETTLEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_MASS_SETTLEMENT_PVT_W" as
  /* $Header: ozfwmstb.pls 120.4.12010000.2 2008/08/01 06:22:06 bkunjan ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_mass_settlement_pvt.open_claim_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).claim_id := a0(indx);
          t(ddindx).claim_class := a1(indx);
          t(ddindx).claim_number := a2(indx);
          t(ddindx).amount_settled := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_mass_settlement_pvt.open_claim_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).claim_id;
          a1(indx) := t(ddindx).claim_class;
          a2(indx) := t(ddindx).claim_number;
          a3(indx) := t(ddindx).amount_settled;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_mass_settlement_pvt.open_transaction_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_trx_id := a0(indx);
          t(ddindx).cust_trx_type_id := a1(indx);
          t(ddindx).trx_class := a2(indx);
          t(ddindx).trx_number := a3(indx);
          t(ddindx).amount_settled := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ozf_mass_settlement_pvt.open_transaction_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).customer_trx_id;
          a1(indx) := t(ddindx).cust_trx_type_id;
          a2(indx) := t(ddindx).trx_class;
          a3(indx) := t(ddindx).trx_number;
          a4(indx) := t(ddindx).amount_settled;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_mass_settlement_pvt.claim_payment_method_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).payment_method := a0(indx);
          t(ddindx).gl_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).wo_rec_trx_id := a2(indx);
          t(ddindx).amount_settled := a3(indx);
          t(ddindx).wo_adj_trx_id := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ozf_mass_settlement_pvt.claim_payment_method_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).payment_method;
          a1(indx) := t(ddindx).gl_date;
          a2(indx) := t(ddindx).wo_rec_trx_id;
          a3(indx) := t(ddindx).amount_settled;
          a4(indx) := t(ddindx).wo_adj_trx_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure settle_mass_settlement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_DATE_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , x_claim_group_id out nocopy  NUMBER
    , x_claim_group_number out nocopy  VARCHAR2
  )

  as
    ddp_group_claim_rec ozf_mass_settlement_pvt.group_claim_rec;
    ddp_open_claim_tbl ozf_mass_settlement_pvt.open_claim_tbl;
    ddp_open_transaction_tbl ozf_mass_settlement_pvt.open_transaction_tbl;
    ddp_payment_method_tbl ozf_mass_settlement_pvt.claim_payment_method_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_group_claim_rec.claim_id := p7_a0;
    ddp_group_claim_rec.claim_class := p7_a1;
    ddp_group_claim_rec.claim_number := p7_a2;
    ddp_group_claim_rec.claim_type_id := p7_a3;
    ddp_group_claim_rec.reason_code_id := p7_a4;
    ddp_group_claim_rec.cust_account_id := p7_a5;
    ddp_group_claim_rec.amount_settled := p7_a6;
    ddp_group_claim_rec.currency_code := p7_a7;
    ddp_group_claim_rec.bill_to_site_id := p7_a8;
    ddp_group_claim_rec.org_id := p7_a9;

    ozf_mass_settlement_pvt_w.rosetta_table_copy_in_p2(ddp_open_claim_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      );

    ozf_mass_settlement_pvt_w.rosetta_table_copy_in_p4(ddp_open_transaction_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      );

    ozf_mass_settlement_pvt_w.rosetta_table_copy_in_p6(ddp_payment_method_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_mass_settlement_pvt.settle_mass_settlement(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_group_claim_rec,
      ddp_open_claim_tbl,
      ddp_open_transaction_tbl,
      ddp_payment_method_tbl,
      x_claim_group_id,
      x_claim_group_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end ozf_mass_settlement_pvt_w;

/
