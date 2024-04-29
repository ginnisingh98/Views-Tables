--------------------------------------------------------
--  DDL for Package Body PV_ORDER_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ORDER_MGMT_PVT_W" as
  /* $Header: pvxwpomb.pls 120.5 2005/12/14 12:24 dgottlie ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_order_mgmt_pvt.payment_info_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).enrl_req_id := a0(indx);
          t(ddindx).order_header_id := a1(indx);
          t(ddindx).trxn_extension_id := a2(indx);
          t(ddindx).invite_header_id := a3(indx);
          t(ddindx).object_version_number := a4(indx);
          t(ddindx).payment_amount := a5(indx);
          t(ddindx).currency := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_order_mgmt_pvt.payment_info_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).enrl_req_id;
          a1(indx) := t(ddindx).order_header_id;
          a2(indx) := t(ddindx).trxn_extension_id;
          a3(indx) := t(ddindx).invite_header_id;
          a4(indx) := t(ddindx).object_version_number;
          a5(indx) := t(ddindx).payment_amount;
          a6(indx) := t(ddindx).currency;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy pv_order_mgmt_pvt.order_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).order_header_id := a1(indx);
          t(ddindx).enrl_request_id := a2(indx);
          t(ddindx).invite_header_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pv_order_mgmt_pvt.order_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).order_header_id;
          a2(indx) := t(ddindx).enrl_request_id;
          a3(indx) := t(ddindx).invite_header_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure set_enrq_payment_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contact_party_id  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_is_authorized out nocopy  VARCHAR2
  )

  as
    ddp_payment_method_rec pv_order_mgmt_pvt.payment_method_rec_type;
    ddp_enrl_req_id pv_order_mgmt_pvt.payment_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_payment_method_rec.payment_type_code := p4_a0;
    ddp_payment_method_rec.check_number := p4_a1;
    ddp_payment_method_rec.credit_card_code := p4_a2;
    ddp_payment_method_rec.credit_card_holder_name := p4_a3;
    ddp_payment_method_rec.credit_card_number := p4_a4;
    ddp_payment_method_rec.credit_card_exp_month := p4_a5;
    ddp_payment_method_rec.credit_card_exp_year := p4_a6;
    ddp_payment_method_rec.cust_po_number := p4_a7;
    ddp_payment_method_rec.instr_assignment_id := p4_a8;
    ddp_payment_method_rec.instrument_security_code := p4_a9;
    ddp_payment_method_rec.cc_stmt_party_site_id := p4_a10;

    pv_order_mgmt_pvt_w.rosetta_table_copy_in_p2(ddp_enrl_req_id, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      );





    -- here's the delegated call to the old PL/SQL routine
    pv_order_mgmt_pvt.set_enrq_payment_info(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_contact_party_id,
      ddp_payment_method_rec,
      ddp_enrl_req_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_is_authorized);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure set_vad_payment_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contact_party_id  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_payment_method_rec pv_order_mgmt_pvt.payment_method_rec_type;
    ddp_order_header_id pv_order_mgmt_pvt.payment_info_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_payment_method_rec.payment_type_code := p4_a0;
    ddp_payment_method_rec.check_number := p4_a1;
    ddp_payment_method_rec.credit_card_code := p4_a2;
    ddp_payment_method_rec.credit_card_holder_name := p4_a3;
    ddp_payment_method_rec.credit_card_number := p4_a4;
    ddp_payment_method_rec.credit_card_exp_month := p4_a5;
    ddp_payment_method_rec.credit_card_exp_year := p4_a6;
    ddp_payment_method_rec.cust_po_number := p4_a7;
    ddp_payment_method_rec.instr_assignment_id := p4_a8;
    ddp_payment_method_rec.instrument_security_code := p4_a9;
    ddp_payment_method_rec.cc_stmt_party_site_id := p4_a10;

    pv_order_mgmt_pvt_w.rosetta_table_copy_in_p2(ddp_order_header_id, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      );




    -- here's the delegated call to the old PL/SQL routine
    pv_order_mgmt_pvt.set_vad_payment_info(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_contact_party_id,
      ddp_payment_method_rec,
      ddp_order_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end pv_order_mgmt_pvt_w;

/
