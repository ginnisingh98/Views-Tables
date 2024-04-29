--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MEMO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MEMO_PVT_W" as
  /* $Header: OKLECRMB.pls 120.4 2007/11/06 07:31:37 veramach noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_credit_memo_pvt.credit_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lsm_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_source := a1(indx);
          t(ddindx).source_trx_number := a2(indx);
          t(ddindx).credit_amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).credit_sty_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).credit_try_name := a5(indx);
          t(ddindx).credit_desc := a6(indx);
          t(ddindx).credit_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).currency_code := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_credit_memo_pvt.credit_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lsm_id);
          a1(indx) := t(ddindx).transaction_source;
          a2(indx) := t(ddindx).source_trx_number;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).credit_amount);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).credit_sty_id);
          a5(indx) := t(ddindx).credit_try_name;
          a6(indx) := t(ddindx).credit_desc;
          a7(indx) := t(ddindx).credit_date;
          a8(indx) := t(ddindx).currency_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure insert_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_tld_id  NUMBER
    , p_credit_amount  NUMBER
    , p_credit_sty_id  NUMBER
    , p_credit_desc  VARCHAR2
    , p_credit_date  date
    , p_try_id  NUMBER
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , x_tai_id out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  NUMBER
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  VARCHAR2
    , p11_a44 out nocopy  VARCHAR2
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  DATE
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  NUMBER
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  NUMBER
    , p11_a53 out nocopy  DATE
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  DATE
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  NUMBER
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  NUMBER
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  DATE
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  NUMBER
    , p11_a66 out nocopy  NUMBER
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  NUMBER
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  NUMBER
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_credit_date date;
    ddx_taiv_rec okl_credit_memo_pvt.taiv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_credit_date := rosetta_g_miss_date_in_map(p_credit_date);









    -- here's the delegated call to the old PL/SQL routine
    okl_credit_memo_pvt.insert_request(p_api_version,
      p_init_msg_list,
      p_tld_id,
      p_credit_amount,
      p_credit_sty_id,
      p_credit_desc,
      ddp_credit_date,
      p_try_id,
      p_transaction_source,
      p_source_trx_number,
      x_tai_id,
      ddx_taiv_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p11_a2 := ddx_taiv_rec.sfwt_flag;
    p11_a3 := ddx_taiv_rec.currency_code;
    p11_a4 := ddx_taiv_rec.currency_conversion_type;
    p11_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p11_a6 := ddx_taiv_rec.currency_conversion_date;
    p11_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p11_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p11_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p11_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p11_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p11_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p11_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p11_a14 := ddx_taiv_rec.trx_status_code;
    p11_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p11_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p11_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p11_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p11_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p11_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p11_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p11_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p11_a23 := ddx_taiv_rec.date_invoiced;
    p11_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p11_a25 := ddx_taiv_rec.description;
    p11_a26 := ddx_taiv_rec.trx_number;
    p11_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p11_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p11_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p11_a30 := ddx_taiv_rec.attribute_category;
    p11_a31 := ddx_taiv_rec.attribute1;
    p11_a32 := ddx_taiv_rec.attribute2;
    p11_a33 := ddx_taiv_rec.attribute3;
    p11_a34 := ddx_taiv_rec.attribute4;
    p11_a35 := ddx_taiv_rec.attribute5;
    p11_a36 := ddx_taiv_rec.attribute6;
    p11_a37 := ddx_taiv_rec.attribute7;
    p11_a38 := ddx_taiv_rec.attribute8;
    p11_a39 := ddx_taiv_rec.attribute9;
    p11_a40 := ddx_taiv_rec.attribute10;
    p11_a41 := ddx_taiv_rec.attribute11;
    p11_a42 := ddx_taiv_rec.attribute12;
    p11_a43 := ddx_taiv_rec.attribute13;
    p11_a44 := ddx_taiv_rec.attribute14;
    p11_a45 := ddx_taiv_rec.attribute15;
    p11_a46 := ddx_taiv_rec.date_entered;
    p11_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p11_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p11_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p11_a50 := ddx_taiv_rec.program_update_date;
    p11_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p11_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p11_a53 := ddx_taiv_rec.creation_date;
    p11_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p11_a55 := ddx_taiv_rec.last_update_date;
    p11_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p11_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p11_a58 := ddx_taiv_rec.investor_agreement_number;
    p11_a59 := ddx_taiv_rec.investor_name;
    p11_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p11_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p11_a62 := ddx_taiv_rec.invoice_pull_yn;
    p11_a63 := ddx_taiv_rec.due_date;
    p11_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p11_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p11_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p11_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p11_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p11_a69 := ddx_taiv_rec.tax_exempt_flag;
    p11_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p11_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p11_a72 := ddx_taiv_rec.private_label;
    p11_a73 := ddx_taiv_rec.transaction_date;



  end;

  procedure insert_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_VARCHAR2_TABLE_200
    , p2_a6 JTF_VARCHAR2_TABLE_2000
    , p2_a7 JTF_DATE_TABLE
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_NUMBER_TABLE
    , p5_a19 out nocopy JTF_NUMBER_TABLE
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_NUMBER_TABLE
    , p5_a22 out nocopy JTF_NUMBER_TABLE
    , p5_a23 out nocopy JTF_DATE_TABLE
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_NUMBER_TABLE
    , p5_a29 out nocopy JTF_NUMBER_TABLE
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a46 out nocopy JTF_DATE_TABLE
    , p5_a47 out nocopy JTF_NUMBER_TABLE
    , p5_a48 out nocopy JTF_NUMBER_TABLE
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_DATE_TABLE
    , p5_a51 out nocopy JTF_NUMBER_TABLE
    , p5_a52 out nocopy JTF_NUMBER_TABLE
    , p5_a53 out nocopy JTF_DATE_TABLE
    , p5_a54 out nocopy JTF_NUMBER_TABLE
    , p5_a55 out nocopy JTF_DATE_TABLE
    , p5_a56 out nocopy JTF_NUMBER_TABLE
    , p5_a57 out nocopy JTF_NUMBER_TABLE
    , p5_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a61 out nocopy JTF_NUMBER_TABLE
    , p5_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a63 out nocopy JTF_DATE_TABLE
    , p5_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a66 out nocopy JTF_NUMBER_TABLE
    , p5_a67 out nocopy JTF_NUMBER_TABLE
    , p5_a68 out nocopy JTF_NUMBER_TABLE
    , p5_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a71 out nocopy JTF_NUMBER_TABLE
    , p5_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a73 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_credit_list okl_credit_memo_pvt.credit_tbl;
    ddx_taiv_tbl okl_credit_memo_pvt.taiv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_credit_memo_pvt_w.rosetta_table_copy_in_p1(ddp_credit_list, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      );







    -- here's the delegated call to the old PL/SQL routine
    okl_credit_memo_pvt.insert_request(p_api_version,
      p_init_msg_list,
      ddp_credit_list,
      p_transaction_source,
      p_source_trx_number,
      ddx_taiv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    okl_tai_pvt_w.rosetta_table_copy_out_p8(ddx_taiv_tbl, p5_a0
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
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );



  end;

  procedure insert_on_acc_cm_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_tld_id  NUMBER
    , p_credit_amount  NUMBER
    , p_credit_sty_id  NUMBER
    , p_credit_desc  VARCHAR2
    , p_credit_date  date
    , p_try_id  NUMBER
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , x_tai_id out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  NUMBER
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  VARCHAR2
    , p11_a44 out nocopy  VARCHAR2
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  DATE
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  NUMBER
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  NUMBER
    , p11_a53 out nocopy  DATE
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  DATE
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  NUMBER
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  NUMBER
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  DATE
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  NUMBER
    , p11_a66 out nocopy  NUMBER
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  NUMBER
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  NUMBER
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_credit_date date;
    ddx_taiv_rec okl_credit_memo_pvt.taiv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_credit_date := rosetta_g_miss_date_in_map(p_credit_date);









    -- here's the delegated call to the old PL/SQL routine
    okl_credit_memo_pvt.insert_on_acc_cm_request(p_api_version,
      p_init_msg_list,
      p_tld_id,
      p_credit_amount,
      p_credit_sty_id,
      p_credit_desc,
      ddp_credit_date,
      p_try_id,
      p_transaction_source,
      p_source_trx_number,
      x_tai_id,
      ddx_taiv_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_taiv_rec.id);
    p11_a1 := rosetta_g_miss_num_map(ddx_taiv_rec.object_version_number);
    p11_a2 := ddx_taiv_rec.sfwt_flag;
    p11_a3 := ddx_taiv_rec.currency_code;
    p11_a4 := ddx_taiv_rec.currency_conversion_type;
    p11_a5 := rosetta_g_miss_num_map(ddx_taiv_rec.currency_conversion_rate);
    p11_a6 := ddx_taiv_rec.currency_conversion_date;
    p11_a7 := rosetta_g_miss_num_map(ddx_taiv_rec.khr_id);
    p11_a8 := rosetta_g_miss_num_map(ddx_taiv_rec.cra_id);
    p11_a9 := rosetta_g_miss_num_map(ddx_taiv_rec.tap_id);
    p11_a10 := rosetta_g_miss_num_map(ddx_taiv_rec.qte_id);
    p11_a11 := rosetta_g_miss_num_map(ddx_taiv_rec.tcn_id);
    p11_a12 := rosetta_g_miss_num_map(ddx_taiv_rec.tai_id_reverses);
    p11_a13 := rosetta_g_miss_num_map(ddx_taiv_rec.ipy_id);
    p11_a14 := ddx_taiv_rec.trx_status_code;
    p11_a15 := rosetta_g_miss_num_map(ddx_taiv_rec.set_of_books_id);
    p11_a16 := rosetta_g_miss_num_map(ddx_taiv_rec.try_id);
    p11_a17 := rosetta_g_miss_num_map(ddx_taiv_rec.ibt_id);
    p11_a18 := rosetta_g_miss_num_map(ddx_taiv_rec.ixx_id);
    p11_a19 := rosetta_g_miss_num_map(ddx_taiv_rec.irm_id);
    p11_a20 := rosetta_g_miss_num_map(ddx_taiv_rec.irt_id);
    p11_a21 := rosetta_g_miss_num_map(ddx_taiv_rec.svf_id);
    p11_a22 := rosetta_g_miss_num_map(ddx_taiv_rec.amount);
    p11_a23 := ddx_taiv_rec.date_invoiced;
    p11_a24 := rosetta_g_miss_num_map(ddx_taiv_rec.amount_applied);
    p11_a25 := ddx_taiv_rec.description;
    p11_a26 := ddx_taiv_rec.trx_number;
    p11_a27 := rosetta_g_miss_num_map(ddx_taiv_rec.clg_id);
    p11_a28 := rosetta_g_miss_num_map(ddx_taiv_rec.pox_id);
    p11_a29 := rosetta_g_miss_num_map(ddx_taiv_rec.cpy_id);
    p11_a30 := ddx_taiv_rec.attribute_category;
    p11_a31 := ddx_taiv_rec.attribute1;
    p11_a32 := ddx_taiv_rec.attribute2;
    p11_a33 := ddx_taiv_rec.attribute3;
    p11_a34 := ddx_taiv_rec.attribute4;
    p11_a35 := ddx_taiv_rec.attribute5;
    p11_a36 := ddx_taiv_rec.attribute6;
    p11_a37 := ddx_taiv_rec.attribute7;
    p11_a38 := ddx_taiv_rec.attribute8;
    p11_a39 := ddx_taiv_rec.attribute9;
    p11_a40 := ddx_taiv_rec.attribute10;
    p11_a41 := ddx_taiv_rec.attribute11;
    p11_a42 := ddx_taiv_rec.attribute12;
    p11_a43 := ddx_taiv_rec.attribute13;
    p11_a44 := ddx_taiv_rec.attribute14;
    p11_a45 := ddx_taiv_rec.attribute15;
    p11_a46 := ddx_taiv_rec.date_entered;
    p11_a47 := rosetta_g_miss_num_map(ddx_taiv_rec.request_id);
    p11_a48 := rosetta_g_miss_num_map(ddx_taiv_rec.program_application_id);
    p11_a49 := rosetta_g_miss_num_map(ddx_taiv_rec.program_id);
    p11_a50 := ddx_taiv_rec.program_update_date;
    p11_a51 := rosetta_g_miss_num_map(ddx_taiv_rec.org_id);
    p11_a52 := rosetta_g_miss_num_map(ddx_taiv_rec.created_by);
    p11_a53 := ddx_taiv_rec.creation_date;
    p11_a54 := rosetta_g_miss_num_map(ddx_taiv_rec.last_updated_by);
    p11_a55 := ddx_taiv_rec.last_update_date;
    p11_a56 := rosetta_g_miss_num_map(ddx_taiv_rec.last_update_login);
    p11_a57 := rosetta_g_miss_num_map(ddx_taiv_rec.legal_entity_id);
    p11_a58 := ddx_taiv_rec.investor_agreement_number;
    p11_a59 := ddx_taiv_rec.investor_name;
    p11_a60 := ddx_taiv_rec.okl_source_billing_trx;
    p11_a61 := rosetta_g_miss_num_map(ddx_taiv_rec.inf_id);
    p11_a62 := ddx_taiv_rec.invoice_pull_yn;
    p11_a63 := ddx_taiv_rec.due_date;
    p11_a64 := ddx_taiv_rec.consolidated_invoice_number;
    p11_a65 := rosetta_g_miss_num_map(ddx_taiv_rec.isi_id);
    p11_a66 := rosetta_g_miss_num_map(ddx_taiv_rec.receivables_invoice_id);
    p11_a67 := rosetta_g_miss_num_map(ddx_taiv_rec.cust_trx_type_id);
    p11_a68 := rosetta_g_miss_num_map(ddx_taiv_rec.customer_bank_account_id);
    p11_a69 := ddx_taiv_rec.tax_exempt_flag;
    p11_a70 := ddx_taiv_rec.tax_exempt_reason_code;
    p11_a71 := rosetta_g_miss_num_map(ddx_taiv_rec.reference_line_id);
    p11_a72 := ddx_taiv_rec.private_label;
    p11_a73 := ddx_taiv_rec.transaction_date;



  end;

end okl_credit_memo_pvt_w;

/
