--------------------------------------------------------
--  DDL for Package Body CN_PAYMENT_WORKSHEET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYMENT_WORKSHEET_PVT_W" as
  /* $Header: cnwwkshb.pls 120.1.12000000.3 2007/05/23 11:30:28 rrshetty ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy cn_payment_worksheet_pvt.salesrep_tab_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).salesrep_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cn_payment_worksheet_pvt.salesrep_tab_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).salesrep_id;
          a1(indx) := t(ddindx).batch_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p7(t out nocopy cn_payment_worksheet_pvt.calc_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_id := a0(indx);
          t(ddindx).pmt_amount_calc := a1(indx);
          t(ddindx).pmt_amount_rec := a2(indx);
          t(ddindx).pmt_amount_adj_rec := a3(indx);
          t(ddindx).pmt_amount_adj_nrec := a4(indx);
          t(ddindx).pmt_amount_ctr := a5(indx);
          t(ddindx).held_amount := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cn_payment_worksheet_pvt.calc_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).quota_id;
          a1(indx) := t(ddindx).pmt_amount_calc;
          a2(indx) := t(ddindx).pmt_amount_rec;
          a3(indx) := t(ddindx).pmt_amount_adj_rec;
          a4(indx) := t(ddindx).pmt_amount_adj_nrec;
          a5(indx) := t(ddindx).pmt_amount_ctr;
          a6(indx) := t(ddindx).held_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure generic_conc_processor(p_payrun_id  NUMBER
    , p1_a0  VARCHAR2
    , p_org_id  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , x_errbuf out nocopy  VARCHAR2
    , x_retcode out nocopy  NUMBER
  )

  as
    ddp_params cn_payment_worksheet_pvt.conc_params;
    ddp_salesrep_tbl cn_payment_worksheet_pvt.salesrep_tab_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_params.conc_program_name := p1_a0;


    cn_payment_worksheet_pvt_w.rosetta_table_copy_in_p4(ddp_salesrep_tbl, p3_a0
      , p3_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    cn_payment_worksheet_pvt.generic_conc_processor(p_payrun_id,
      ddp_params,
      p_org_id,
      ddp_salesrep_tbl,
      x_errbuf,
      x_retcode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_worksheet(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  )

  as
    ddp_worksheet_rec cn_payment_worksheet_pvt.worksheet_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_worksheet_rec.payrun_id := p7_a0;
    ddp_worksheet_rec.salesrep_id := p7_a1;
    ddp_worksheet_rec.call_from := p7_a2;
    ddp_worksheet_rec.worksheet_id := p7_a3;
    ddp_worksheet_rec.org_id := p7_a4;



    -- here's the delegated call to the old PL/SQL routine
    cn_payment_worksheet_pvt.create_worksheet(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_worksheet_rec,
      x_loading_status,
      x_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end cn_payment_worksheet_pvt_w;

/
