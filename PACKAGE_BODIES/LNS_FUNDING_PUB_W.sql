--------------------------------------------------------
--  DDL for Package Body LNS_FUNDING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FUNDING_PUB_W" as
  /* $Header: LNS_FUND_PUBJ_B.pls 120.16.12010000.2 2010/03/19 08:36:44 gparuchu ship $ */
  procedure get_default_payment_attributes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p5_a0 out nocopy  VARCHAR2
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  NUMBER
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trxn_attributes_rec lns_funding_pub.trxn_attributes_rec_type;
    ddx_default_pmt_attrs_rec lns_funding_pub.default_pmt_attrs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_trxn_attributes_rec.application_id := p4_a0;
    ddp_trxn_attributes_rec.payer_legal_entity_id := p4_a1;
    ddp_trxn_attributes_rec.payer_org_id := p4_a2;
    ddp_trxn_attributes_rec.payer_org_type := p4_a3;
    ddp_trxn_attributes_rec.payee_party_id := p4_a4;
    ddp_trxn_attributes_rec.payee_party_site_id := p4_a5;
    ddp_trxn_attributes_rec.supplier_site_id := p4_a6;
    ddp_trxn_attributes_rec.pay_proc_trxn_type_code := p4_a7;
    ddp_trxn_attributes_rec.payment_currency := p4_a8;
    ddp_trxn_attributes_rec.payment_amount := p4_a9;
    ddp_trxn_attributes_rec.payment_function := p4_a10;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.get_default_payment_attributes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_trxn_attributes_rec,
      ddx_default_pmt_attrs_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddx_default_pmt_attrs_rec.payment_method_name;
    p5_a1 := ddx_default_pmt_attrs_rec.payment_method_code;
    p5_a2 := ddx_default_pmt_attrs_rec.payee_bankaccount_id;
    p5_a3 := ddx_default_pmt_attrs_rec.payee_bankaccount_number;
    p5_a4 := ddx_default_pmt_attrs_rec.payee_bankaccount_name;



  end;

  procedure insert_disb_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  VARCHAR2
    , p4_a7  DATE
    , p4_a8  DATE
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_disb_header_rec lns_funding_pub.lns_disb_headers_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_disb_header_rec.disb_header_id := p4_a0;
    ddp_disb_header_rec.loan_id := p4_a1;
    ddp_disb_header_rec.activity_code := p4_a2;
    ddp_disb_header_rec.disbursement_number := p4_a3;
    ddp_disb_header_rec.header_amount := p4_a4;
    ddp_disb_header_rec.header_percent := p4_a5;
    ddp_disb_header_rec.status := p4_a6;
    ddp_disb_header_rec.target_date := p4_a7;
    ddp_disb_header_rec.payment_request_date := p4_a8;
    ddp_disb_header_rec.object_version_number := p4_a9;
    ddp_disb_header_rec.autofunding_flag := p4_a10;
    ddp_disb_header_rec.phase := p4_a11;
    ddp_disb_header_rec.description := p4_a12;




    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.insert_disb_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_disb_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_disb_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  VARCHAR2
    , p4_a7  DATE
    , p4_a8  DATE
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_disb_header_rec lns_funding_pub.lns_disb_headers_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_disb_header_rec.disb_header_id := p4_a0;
    ddp_disb_header_rec.loan_id := p4_a1;
    ddp_disb_header_rec.activity_code := p4_a2;
    ddp_disb_header_rec.disbursement_number := p4_a3;
    ddp_disb_header_rec.header_amount := p4_a4;
    ddp_disb_header_rec.header_percent := p4_a5;
    ddp_disb_header_rec.status := p4_a6;
    ddp_disb_header_rec.target_date := p4_a7;
    ddp_disb_header_rec.payment_request_date := p4_a8;
    ddp_disb_header_rec.object_version_number := p4_a9;
    ddp_disb_header_rec.autofunding_flag := p4_a10;
    ddp_disb_header_rec.phase := p4_a11;
    ddp_disb_header_rec.description := p4_a12;




    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.update_disb_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_disb_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure insert_disb_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  DATE
    , p4_a10  DATE
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_disb_line_rec lns_funding_pub.lns_disb_lines_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_disb_line_rec.disb_line_id := p4_a0;
    ddp_disb_line_rec.disb_header_id := p4_a1;
    ddp_disb_line_rec.disb_line_number := p4_a2;
    ddp_disb_line_rec.line_amount := p4_a3;
    ddp_disb_line_rec.line_percent := p4_a4;
    ddp_disb_line_rec.payee_party_id := p4_a5;
    ddp_disb_line_rec.bank_account_id := p4_a6;
    ddp_disb_line_rec.payment_method_code := p4_a7;
    ddp_disb_line_rec.status := p4_a8;
    ddp_disb_line_rec.request_date := p4_a9;
    ddp_disb_line_rec.disbursement_date := p4_a10;
    ddp_disb_line_rec.object_version_number := p4_a11;
    ddp_disb_line_rec.invoice_interface_id := p4_a12;
    ddp_disb_line_rec.invoice_id := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.insert_disb_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_disb_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_disb_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  DATE
    , p4_a10  DATE
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_disb_line_rec lns_funding_pub.lns_disb_lines_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_disb_line_rec.disb_line_id := p4_a0;
    ddp_disb_line_rec.disb_header_id := p4_a1;
    ddp_disb_line_rec.disb_line_number := p4_a2;
    ddp_disb_line_rec.line_amount := p4_a3;
    ddp_disb_line_rec.line_percent := p4_a4;
    ddp_disb_line_rec.payee_party_id := p4_a5;
    ddp_disb_line_rec.bank_account_id := p4_a6;
    ddp_disb_line_rec.payment_method_code := p4_a7;
    ddp_disb_line_rec.status := p4_a8;
    ddp_disb_line_rec.request_date := p4_a9;
    ddp_disb_line_rec.disbursement_date := p4_a10;
    ddp_disb_line_rec.object_version_number := p4_a11;
    ddp_disb_line_rec.invoice_interface_id := p4_a12;
    ddp_disb_line_rec.invoice_id := p4_a13;




    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.update_disb_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_disb_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_payee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , x_payee_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_payee_rec lns_funding_pub.loan_payee_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_payee_rec.payee_name := p4_a0;
    ddp_payee_rec.taxpayer_id := p4_a1;
    ddp_payee_rec.tax_registration_id := p4_a2;
    ddp_payee_rec.supplier_type := p4_a3;
    ddp_payee_rec.payee_number := p4_a4;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.create_payee(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_payee_rec,
      x_payee_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_payee_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , x_payee_site_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_payee_site_rec lns_funding_pub.loan_payee_site_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_payee_site_rec.payee_site_code := p4_a0;
    ddp_payee_site_rec.payee_id := p4_a1;
    ddp_payee_site_rec.address_line1 := p4_a2;
    ddp_payee_site_rec.address_line2 := p4_a3;
    ddp_payee_site_rec.address_line3 := p4_a4;
    ddp_payee_site_rec.city := p4_a5;
    ddp_payee_site_rec.state := p4_a6;
    ddp_payee_site_rec.zip := p4_a7;
    ddp_payee_site_rec.province := p4_a8;
    ddp_payee_site_rec.county := p4_a9;
    ddp_payee_site_rec.country := p4_a10;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.create_payee_site(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_payee_site_rec,
      x_payee_site_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_site_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , x_site_contact_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_site_contact_rec lns_funding_pub.site_contact_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_site_contact_rec.payee_site_id := p4_a0;
    ddp_site_contact_rec.first_name := p4_a1;
    ddp_site_contact_rec.last_name := p4_a2;
    ddp_site_contact_rec.title := p4_a3;
    ddp_site_contact_rec.phone := p4_a4;
    ddp_site_contact_rec.fax := p4_a5;
    ddp_site_contact_rec.email := p4_a6;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.create_site_contact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_site_contact_rec,
      x_site_contact_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_bank_acc_use(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , x_bank_acc_use_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_bank_acc_use_rec lns_funding_pub.bank_account_use_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_bank_acc_use_rec.payee_id := p4_a0;
    ddp_bank_acc_use_rec.payee_site_id := p4_a1;
    ddp_bank_acc_use_rec.bank_account_id := p4_a2;
    ddp_bank_acc_use_rec.primary_flag := p4_a3;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.create_bank_acc_use(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_bank_acc_use_rec,
      x_bank_acc_use_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure init_funding_advice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , x_funding_advice_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_init_funding_rec lns_funding_pub.init_funding_advice_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_init_funding_rec.loan_id := p4_a0;
    ddp_init_funding_rec.payment_method := p4_a1;
    ddp_init_funding_rec.payee_id := p4_a2;
    ddp_init_funding_rec.payee_site_id := p4_a3;
    ddp_init_funding_rec.site_contact_id := p4_a4;
    ddp_init_funding_rec.bank_branch_id := p4_a5;
    ddp_init_funding_rec.bank_account_id := p4_a6;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.init_funding_advice(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_init_funding_rec,
      x_funding_advice_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_funding_advice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , p4_a14  NUMBER
    , p4_a15  NUMBER
    , p4_a16  NUMBER
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , x_funding_advice_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_funding_advice_rec lns_funding_pub.funding_advice_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_funding_advice_rec.funding_advice_id := p4_a0;
    ddp_funding_advice_rec.loan_id := p4_a1;
    ddp_funding_advice_rec.loan_start_date := p4_a2;
    ddp_funding_advice_rec.first_payment_date := p4_a3;
    ddp_funding_advice_rec.approved_date := p4_a4;
    ddp_funding_advice_rec.due_date := p4_a5;
    ddp_funding_advice_rec.amount := p4_a6;
    ddp_funding_advice_rec.currency := p4_a7;
    ddp_funding_advice_rec.description := p4_a8;
    ddp_funding_advice_rec.payment_method := p4_a9;
    ddp_funding_advice_rec.payee_id := p4_a10;
    ddp_funding_advice_rec.payee_site_id := p4_a11;
    ddp_funding_advice_rec.site_contact_id := p4_a12;
    ddp_funding_advice_rec.bank_branch_id := p4_a13;
    ddp_funding_advice_rec.bank_account_id := p4_a14;
    ddp_funding_advice_rec.invoice_id := p4_a15;
    ddp_funding_advice_rec.request_id := p4_a16;
    ddp_funding_advice_rec.advice_number := p4_a17;
    ddp_funding_advice_rec.invoice_number := p4_a18;
    ddp_funding_advice_rec.loan_status := p4_a19;





    -- here's the delegated call to the old PL/SQL routine
    lns_funding_pub.create_funding_advice(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_funding_advice_rec,
      x_funding_advice_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end lns_funding_pub_w;

/
