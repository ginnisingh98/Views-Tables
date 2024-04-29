--------------------------------------------------------
--  DDL for Package Body CN_PMT_TRANS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMT_TRANS_PVT_W" as
  /* $Header: cnwpmtrb.pls 120.4 2005/12/23 09:26 fmburu noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_pmt_trans_pvt.pmt_tran_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).payment_transaction_id := a0(indx);
          t(ddindx).amount := a1(indx);
          t(ddindx).payment_amount := a2(indx);
          t(ddindx).payment_diff := a3(indx);
          t(ddindx).quota_id := a4(indx);
          t(ddindx).quota_name := a5(indx);
          t(ddindx).incentive_type_code := a6(indx);
          t(ddindx).incentive_type := a7(indx);
          t(ddindx).hold_flag := a8(indx);
          t(ddindx).hold_flag_desc := a9(indx);
          t(ddindx).waive_flag := a10(indx);
          t(ddindx).waive_flag_desc := a11(indx);
          t(ddindx).pay_element_type_id := a12(indx);
          t(ddindx).pay_element_name := a13(indx);
          t(ddindx).recoverable_flag := a14(indx);
          t(ddindx).recoverable_flag_desc := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_pmt_trans_pvt.pmt_tran_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).payment_transaction_id;
          a1(indx) := t(ddindx).amount;
          a2(indx) := t(ddindx).payment_amount;
          a3(indx) := t(ddindx).payment_diff;
          a4(indx) := t(ddindx).quota_id;
          a5(indx) := t(ddindx).quota_name;
          a6(indx) := t(ddindx).incentive_type_code;
          a7(indx) := t(ddindx).incentive_type;
          a8(indx) := t(ddindx).hold_flag;
          a9(indx) := t(ddindx).hold_flag_desc;
          a10(indx) := t(ddindx).waive_flag;
          a11(indx) := t(ddindx).waive_flag_desc;
          a12(indx) := t(ddindx).pay_element_type_id;
          a13(indx) := t(ddindx).pay_element_name;
          a14(indx) := t(ddindx).recoverable_flag;
          a15(indx) := t(ddindx).recoverable_flag_desc;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_pmt_trans_pvt.pmt_process_tbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_4000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_action := a0(indx);
          t(ddindx).payrun_id := a1(indx);
          t(ddindx).salesrep_id := a2(indx);
          t(ddindx).quota_id := a3(indx);
          t(ddindx).revenue_class_id := a4(indx);
          t(ddindx).invoice_number := a5(indx);
          t(ddindx).order_number := a6(indx);
          t(ddindx).customer := a7(indx);
          t(ddindx).hold_flag := a8(indx);
          t(ddindx).request_id := a9(indx);
          t(ddindx).org_id := a10(indx);
          t(ddindx).object_version_number := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_pmt_trans_pvt.pmt_process_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_4000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_4000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_4000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_4000();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).p_action;
          a1(indx) := t(ddindx).payrun_id;
          a2(indx) := t(ddindx).salesrep_id;
          a3(indx) := t(ddindx).quota_id;
          a4(indx) := t(ddindx).revenue_class_id;
          a5(indx) := t(ddindx).invoice_number;
          a6(indx) := t(ddindx).order_number;
          a7(indx) := t(ddindx).customer;
          a8(indx) := t(ddindx).hold_flag;
          a9(indx) := t(ddindx).request_id;
          a10(indx) := t(ddindx).org_id;
          a11(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure process_pmt_transactions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rec cn_pmt_trans_pvt.pmt_process_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rec.p_action := p4_a0;
    ddp_rec.payrun_id := p4_a1;
    ddp_rec.salesrep_id := p4_a2;
    ddp_rec.quota_id := p4_a3;
    ddp_rec.revenue_class_id := p4_a4;
    ddp_rec.invoice_number := p4_a5;
    ddp_rec.order_number := p4_a6;
    ddp_rec.customer := p4_a7;
    ddp_rec.hold_flag := p4_a8;
    ddp_rec.request_id := p4_a9;
    ddp_rec.org_id := p4_a10;
    ddp_rec.object_version_number := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    cn_pmt_trans_pvt.process_pmt_transactions(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_rec.p_action;
    p4_a1 := ddp_rec.payrun_id;
    p4_a2 := ddp_rec.salesrep_id;
    p4_a3 := ddp_rec.quota_id;
    p4_a4 := ddp_rec.revenue_class_id;
    p4_a5 := ddp_rec.invoice_number;
    p4_a6 := ddp_rec.order_number;
    p4_a7 := ddp_rec.customer;
    p4_a8 := ddp_rec.hold_flag;
    p4_a9 := ddp_rec.request_id;
    p4_a10 := ddp_rec.org_id;
    p4_a11 := ddp_rec.object_version_number;



  end;

end cn_pmt_trans_pvt_w;

/
