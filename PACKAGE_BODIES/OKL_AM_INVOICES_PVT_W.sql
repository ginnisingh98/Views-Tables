--------------------------------------------------------
--  DDL for Package Body OKL_AM_INVOICES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_INVOICES_PVT_W" as
  /* $Header: OKLEAMIB.pls 120.5 2008/06/16 18:34:13 asahoo ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okl_am_invoices_pvt.ariv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).p_acn_id := a0(indx);
          t(ddindx).p_acs_code := a1(indx);
          t(ddindx).p_part_name := a2(indx);
          t(ddindx).p_condition_type := a3(indx);
          t(ddindx).p_damage_type := a4(indx);
          t(ddindx).p_actual_repair_cost := a5(indx);
          t(ddindx).p_date_approved := a6(indx);
          t(ddindx).p_bill_to := a7(indx);
          t(ddindx).p_date_invoice := a8(indx);
          t(ddindx).p_approved_yn := a9(indx);
          t(ddindx).p_acd_id_cost := a10(indx);
          t(ddindx).p_object_version_number := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_am_invoices_pvt.ariv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).p_acn_id;
          a1(indx) := t(ddindx).p_acs_code;
          a2(indx) := t(ddindx).p_part_name;
          a3(indx) := t(ddindx).p_condition_type;
          a4(indx) := t(ddindx).p_damage_type;
          a5(indx) := t(ddindx).p_actual_repair_cost;
          a6(indx) := t(ddindx).p_date_approved;
          a7(indx) := t(ddindx).p_bill_to;
          a8(indx) := t(ddindx).p_date_invoice;
          a9(indx) := t(ddindx).p_approved_yn;
          a10(indx) := t(ddindx).p_acd_id_cost;
          a11(indx) := t(ddindx).p_object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy okl_am_invoices_pvt.tld_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inv_tld_id := a0(indx);
          t(ddindx).cm_tld_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okl_am_invoices_pvt.tld_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).inv_tld_id;
          a1(indx) := t(ddindx).cm_tld_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy okl_am_invoices_pvt.sdd_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lsm_id := a0(indx);
          t(ddindx).tld_id := a1(indx);
          t(ddindx).amount := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_am_invoices_pvt.sdd_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).lsm_id;
          a1(indx) := t(ddindx).tld_id;
          a2(indx) := t(ddindx).amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_vendor_billing_info(p_cpl_id  NUMBER
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  NUMBER
    , p1_a2 in out nocopy  VARCHAR2
    , p1_a3 in out nocopy  VARCHAR2
    , p1_a4 in out nocopy  VARCHAR2
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  DATE
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  NUMBER
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  NUMBER
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  VARCHAR2
    , p1_a15 in out nocopy  NUMBER
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  NUMBER
    , p1_a18 in out nocopy  NUMBER
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  NUMBER
    , p1_a21 in out nocopy  NUMBER
    , p1_a22 in out nocopy  NUMBER
    , p1_a23 in out nocopy  DATE
    , p1_a24 in out nocopy  NUMBER
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  NUMBER
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  VARCHAR2
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  VARCHAR2
    , p1_a39 in out nocopy  VARCHAR2
    , p1_a40 in out nocopy  VARCHAR2
    , p1_a41 in out nocopy  VARCHAR2
    , p1_a42 in out nocopy  VARCHAR2
    , p1_a43 in out nocopy  VARCHAR2
    , p1_a44 in out nocopy  VARCHAR2
    , p1_a45 in out nocopy  VARCHAR2
    , p1_a46 in out nocopy  DATE
    , p1_a47 in out nocopy  NUMBER
    , p1_a48 in out nocopy  NUMBER
    , p1_a49 in out nocopy  NUMBER
    , p1_a50 in out nocopy  DATE
    , p1_a51 in out nocopy  NUMBER
    , p1_a52 in out nocopy  NUMBER
    , p1_a53 in out nocopy  DATE
    , p1_a54 in out nocopy  NUMBER
    , p1_a55 in out nocopy  DATE
    , p1_a56 in out nocopy  NUMBER
    , p1_a57 in out nocopy  NUMBER
    , p1_a58 in out nocopy  VARCHAR2
    , p1_a59 in out nocopy  VARCHAR2
    , p1_a60 in out nocopy  VARCHAR2
    , p1_a61 in out nocopy  NUMBER
    , p1_a62 in out nocopy  VARCHAR2
    , p1_a63 in out nocopy  DATE
    , p1_a64 in out nocopy  VARCHAR2
    , p1_a65 in out nocopy  NUMBER
    , p1_a66 in out nocopy  NUMBER
    , p1_a67 in out nocopy  NUMBER
    , p1_a68 in out nocopy  NUMBER
    , p1_a69 in out nocopy  VARCHAR2
    , p1_a70 in out nocopy  VARCHAR2
    , p1_a71 in out nocopy  NUMBER
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddpx_taiv_rec okl_am_invoices_pvt.taiv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddpx_taiv_rec.id := p1_a0;
    ddpx_taiv_rec.object_version_number := p1_a1;
    ddpx_taiv_rec.sfwt_flag := p1_a2;
    ddpx_taiv_rec.currency_code := p1_a3;
    ddpx_taiv_rec.currency_conversion_type := p1_a4;
    ddpx_taiv_rec.currency_conversion_rate := p1_a5;
    ddpx_taiv_rec.currency_conversion_date := p1_a6;
    ddpx_taiv_rec.khr_id := p1_a7;
    ddpx_taiv_rec.cra_id := p1_a8;
    ddpx_taiv_rec.tap_id := p1_a9;
    ddpx_taiv_rec.qte_id := p1_a10;
    ddpx_taiv_rec.tcn_id := p1_a11;
    ddpx_taiv_rec.tai_id_reverses := p1_a12;
    ddpx_taiv_rec.ipy_id := p1_a13;
    ddpx_taiv_rec.trx_status_code := p1_a14;
    ddpx_taiv_rec.set_of_books_id := p1_a15;
    ddpx_taiv_rec.try_id := p1_a16;
    ddpx_taiv_rec.ibt_id := p1_a17;
    ddpx_taiv_rec.ixx_id := p1_a18;
    ddpx_taiv_rec.irm_id := p1_a19;
    ddpx_taiv_rec.irt_id := p1_a20;
    ddpx_taiv_rec.svf_id := p1_a21;
    ddpx_taiv_rec.amount := p1_a22;
    ddpx_taiv_rec.date_invoiced := p1_a23;
    ddpx_taiv_rec.amount_applied := p1_a24;
    ddpx_taiv_rec.description := p1_a25;
    ddpx_taiv_rec.trx_number := p1_a26;
    ddpx_taiv_rec.clg_id := p1_a27;
    ddpx_taiv_rec.pox_id := p1_a28;
    ddpx_taiv_rec.cpy_id := p1_a29;
    ddpx_taiv_rec.attribute_category := p1_a30;
    ddpx_taiv_rec.attribute1 := p1_a31;
    ddpx_taiv_rec.attribute2 := p1_a32;
    ddpx_taiv_rec.attribute3 := p1_a33;
    ddpx_taiv_rec.attribute4 := p1_a34;
    ddpx_taiv_rec.attribute5 := p1_a35;
    ddpx_taiv_rec.attribute6 := p1_a36;
    ddpx_taiv_rec.attribute7 := p1_a37;
    ddpx_taiv_rec.attribute8 := p1_a38;
    ddpx_taiv_rec.attribute9 := p1_a39;
    ddpx_taiv_rec.attribute10 := p1_a40;
    ddpx_taiv_rec.attribute11 := p1_a41;
    ddpx_taiv_rec.attribute12 := p1_a42;
    ddpx_taiv_rec.attribute13 := p1_a43;
    ddpx_taiv_rec.attribute14 := p1_a44;
    ddpx_taiv_rec.attribute15 := p1_a45;
    ddpx_taiv_rec.date_entered := p1_a46;
    ddpx_taiv_rec.request_id := p1_a47;
    ddpx_taiv_rec.program_application_id := p1_a48;
    ddpx_taiv_rec.program_id := p1_a49;
    ddpx_taiv_rec.program_update_date := p1_a50;
    ddpx_taiv_rec.org_id := p1_a51;
    ddpx_taiv_rec.created_by := p1_a52;
    ddpx_taiv_rec.creation_date := p1_a53;
    ddpx_taiv_rec.last_updated_by := p1_a54;
    ddpx_taiv_rec.last_update_date := p1_a55;
    ddpx_taiv_rec.last_update_login := p1_a56;
    ddpx_taiv_rec.legal_entity_id := p1_a57;
    ddpx_taiv_rec.investor_agreement_number := p1_a58;
    ddpx_taiv_rec.investor_name := p1_a59;
    ddpx_taiv_rec.okl_source_billing_trx := p1_a60;
    ddpx_taiv_rec.inf_id := p1_a61;
    ddpx_taiv_rec.invoice_pull_yn := p1_a62;
    ddpx_taiv_rec.due_date := p1_a63;
    ddpx_taiv_rec.consolidated_invoice_number := p1_a64;
    ddpx_taiv_rec.isi_id := p1_a65;
    ddpx_taiv_rec.receivables_invoice_id := p1_a66;
    ddpx_taiv_rec.cust_trx_type_id := p1_a67;
    ddpx_taiv_rec.customer_bank_account_id := p1_a68;
    ddpx_taiv_rec.tax_exempt_flag := p1_a69;
    ddpx_taiv_rec.tax_exempt_reason_code := p1_a70;
    ddpx_taiv_rec.reference_line_id := p1_a71;
    ddpx_taiv_rec.private_label := p1_a72;
    ddpx_taiv_rec.transaction_date := p1_a73;


    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.get_vendor_billing_info(p_cpl_id,
      ddpx_taiv_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddpx_taiv_rec.id;
    p1_a1 := ddpx_taiv_rec.object_version_number;
    p1_a2 := ddpx_taiv_rec.sfwt_flag;
    p1_a3 := ddpx_taiv_rec.currency_code;
    p1_a4 := ddpx_taiv_rec.currency_conversion_type;
    p1_a5 := ddpx_taiv_rec.currency_conversion_rate;
    p1_a6 := ddpx_taiv_rec.currency_conversion_date;
    p1_a7 := ddpx_taiv_rec.khr_id;
    p1_a8 := ddpx_taiv_rec.cra_id;
    p1_a9 := ddpx_taiv_rec.tap_id;
    p1_a10 := ddpx_taiv_rec.qte_id;
    p1_a11 := ddpx_taiv_rec.tcn_id;
    p1_a12 := ddpx_taiv_rec.tai_id_reverses;
    p1_a13 := ddpx_taiv_rec.ipy_id;
    p1_a14 := ddpx_taiv_rec.trx_status_code;
    p1_a15 := ddpx_taiv_rec.set_of_books_id;
    p1_a16 := ddpx_taiv_rec.try_id;
    p1_a17 := ddpx_taiv_rec.ibt_id;
    p1_a18 := ddpx_taiv_rec.ixx_id;
    p1_a19 := ddpx_taiv_rec.irm_id;
    p1_a20 := ddpx_taiv_rec.irt_id;
    p1_a21 := ddpx_taiv_rec.svf_id;
    p1_a22 := ddpx_taiv_rec.amount;
    p1_a23 := ddpx_taiv_rec.date_invoiced;
    p1_a24 := ddpx_taiv_rec.amount_applied;
    p1_a25 := ddpx_taiv_rec.description;
    p1_a26 := ddpx_taiv_rec.trx_number;
    p1_a27 := ddpx_taiv_rec.clg_id;
    p1_a28 := ddpx_taiv_rec.pox_id;
    p1_a29 := ddpx_taiv_rec.cpy_id;
    p1_a30 := ddpx_taiv_rec.attribute_category;
    p1_a31 := ddpx_taiv_rec.attribute1;
    p1_a32 := ddpx_taiv_rec.attribute2;
    p1_a33 := ddpx_taiv_rec.attribute3;
    p1_a34 := ddpx_taiv_rec.attribute4;
    p1_a35 := ddpx_taiv_rec.attribute5;
    p1_a36 := ddpx_taiv_rec.attribute6;
    p1_a37 := ddpx_taiv_rec.attribute7;
    p1_a38 := ddpx_taiv_rec.attribute8;
    p1_a39 := ddpx_taiv_rec.attribute9;
    p1_a40 := ddpx_taiv_rec.attribute10;
    p1_a41 := ddpx_taiv_rec.attribute11;
    p1_a42 := ddpx_taiv_rec.attribute12;
    p1_a43 := ddpx_taiv_rec.attribute13;
    p1_a44 := ddpx_taiv_rec.attribute14;
    p1_a45 := ddpx_taiv_rec.attribute15;
    p1_a46 := ddpx_taiv_rec.date_entered;
    p1_a47 := ddpx_taiv_rec.request_id;
    p1_a48 := ddpx_taiv_rec.program_application_id;
    p1_a49 := ddpx_taiv_rec.program_id;
    p1_a50 := ddpx_taiv_rec.program_update_date;
    p1_a51 := ddpx_taiv_rec.org_id;
    p1_a52 := ddpx_taiv_rec.created_by;
    p1_a53 := ddpx_taiv_rec.creation_date;
    p1_a54 := ddpx_taiv_rec.last_updated_by;
    p1_a55 := ddpx_taiv_rec.last_update_date;
    p1_a56 := ddpx_taiv_rec.last_update_login;
    p1_a57 := ddpx_taiv_rec.legal_entity_id;
    p1_a58 := ddpx_taiv_rec.investor_agreement_number;
    p1_a59 := ddpx_taiv_rec.investor_name;
    p1_a60 := ddpx_taiv_rec.okl_source_billing_trx;
    p1_a61 := ddpx_taiv_rec.inf_id;
    p1_a62 := ddpx_taiv_rec.invoice_pull_yn;
    p1_a63 := ddpx_taiv_rec.due_date;
    p1_a64 := ddpx_taiv_rec.consolidated_invoice_number;
    p1_a65 := ddpx_taiv_rec.isi_id;
    p1_a66 := ddpx_taiv_rec.receivables_invoice_id;
    p1_a67 := ddpx_taiv_rec.cust_trx_type_id;
    p1_a68 := ddpx_taiv_rec.customer_bank_account_id;
    p1_a69 := ddpx_taiv_rec.tax_exempt_flag;
    p1_a70 := ddpx_taiv_rec.tax_exempt_reason_code;
    p1_a71 := ddpx_taiv_rec.reference_line_id;
    p1_a72 := ddpx_taiv_rec.private_label;
    p1_a73 := ddpx_taiv_rec.transaction_date;

  end;

  procedure contract_remaining_sec_dep(p_contract_id  NUMBER
    , p_contract_line_id  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , x_total_amount out nocopy  NUMBER
  )

  as
    ddx_sdd_tbl okl_am_invoices_pvt.sdd_tbl_type;
    ddx_tld_tbl okl_am_invoices_pvt.tld_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.contract_remaining_sec_dep(p_contract_id,
      p_contract_line_id,
      ddx_sdd_tbl,
      ddx_tld_tbl,
      x_total_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    okl_am_invoices_pvt_w.rosetta_table_copy_out_p7(ddx_sdd_tbl, p2_a0
      , p2_a1
      , p2_a2
      );

    okl_am_invoices_pvt_w.rosetta_table_copy_out_p6(ddx_tld_tbl, p3_a0
      , p3_a1
      );

  end;

  procedure create_repair_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_ariv_tbl okl_am_invoices_pvt.ariv_tbl_type;
    ddx_taiv_tbl okl_am_invoices_pvt.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_invoices_pvt_w.rosetta_table_copy_in_p5(ddp_ariv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.create_repair_invoice(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_ariv_tbl,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p6_a0
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
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      );
  end;

  procedure create_remarket_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_order_line_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_taiv_tbl okl_am_invoices_pvt.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.create_remarket_invoice(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      p_order_line_id,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p6_a0
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
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      );
  end;

  procedure create_quote_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_quote_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_taiv_tbl okl_am_invoices_pvt.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.create_quote_invoice(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      p_quote_id,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p6_a0
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
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      );
  end;

  procedure create_scrt_dpst_dsps_inv(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_contract_line_id  NUMBER
    , p_dispose_amount  NUMBER
    , p_quote_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a46 out nocopy JTF_DATE_TABLE
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_DATE_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_NUMBER_TABLE
    , p9_a53 out nocopy JTF_DATE_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_DATE_TABLE
    , p9_a56 out nocopy JTF_NUMBER_TABLE
    , p9_a57 out nocopy JTF_NUMBER_TABLE
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_NUMBER_TABLE
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a63 out nocopy JTF_DATE_TABLE
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a65 out nocopy JTF_NUMBER_TABLE
    , p9_a66 out nocopy JTF_NUMBER_TABLE
    , p9_a67 out nocopy JTF_NUMBER_TABLE
    , p9_a68 out nocopy JTF_NUMBER_TABLE
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a71 out nocopy JTF_NUMBER_TABLE
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_taiv_tbl okl_am_invoices_pvt.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_am_invoices_pvt.create_scrt_dpst_dsps_inv(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      p_contract_id,
      p_contract_line_id,
      p_dispose_amount,
      p_quote_id,
      ddx_taiv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p9_a0
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
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      );
  end;

end okl_am_invoices_pvt_w;

/
