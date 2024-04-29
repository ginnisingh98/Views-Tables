--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MGNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MGNT_PUB_W" as
  /* $Header: OKLUCMTB.pls 115.4 2003/10/30 23:20:30 rgalipo noship $ */
  procedure submit_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_review_type  VARCHAR2
    , p_credit_classification  VARCHAR2
    , p_requested_amount  NUMBER
    , p_contact_party_id  NUMBER
    , p_notes  VARCHAR2
    , p11_a0  NUMBER
    , p11_a1  NUMBER
    , p11_a2  NUMBER
    , p11_a3  NUMBER
    , p11_a4  NUMBER
    , p11_a5  VARCHAR2
    , p11_a6  NUMBER
    , p11_a7  VARCHAR2
    , p11_a8  NUMBER
    , p11_a9  NUMBER
    , p11_a10  NUMBER
    , p11_a11  NUMBER
    , p11_a12  NUMBER
  )

  as
    ddp_chr_rec okl_credit_mgnt_pvt.l_chr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_chr_rec.party_id := p11_a0;
    ddp_chr_rec.cust_acct_id := p11_a1;
    ddp_chr_rec.cust_acct_site_id := p11_a2;
    ddp_chr_rec.site_use_id := p11_a3;
    ddp_chr_rec.contract_id := p11_a4;
    ddp_chr_rec.contract_number := p11_a5;
    ddp_chr_rec.credit_khr_id := p11_a6;
    ddp_chr_rec.currency := p11_a7;
    ddp_chr_rec.txn_amount := p11_a8;
    ddp_chr_rec.requested_amount := p11_a9;
    ddp_chr_rec.term := p11_a10;
    ddp_chr_rec.party_contact_id := p11_a11;
    ddp_chr_rec.org_id := p11_a12;

    -- here's the delegated call to the old PL/SQL routine
    okl_credit_mgnt_pub.submit_credit_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_id,
      p_review_type,
      p_credit_classification,
      p_requested_amount,
      p_contact_party_id,
      p_notes,
      ddp_chr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure compile_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
  )

  as
    ddx_chr_rec okl_credit_mgnt_pvt.l_chr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_credit_mgnt_pub.compile_credit_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_id,
      ddx_chr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_chr_rec.party_id;
    p6_a1 := ddx_chr_rec.cust_acct_id;
    p6_a2 := ddx_chr_rec.cust_acct_site_id;
    p6_a3 := ddx_chr_rec.site_use_id;
    p6_a4 := ddx_chr_rec.contract_id;
    p6_a5 := ddx_chr_rec.contract_number;
    p6_a6 := ddx_chr_rec.credit_khr_id;
    p6_a7 := ddx_chr_rec.currency;
    p6_a8 := ddx_chr_rec.txn_amount;
    p6_a9 := ddx_chr_rec.requested_amount;
    p6_a10 := ddx_chr_rec.term;
    p6_a11 := ddx_chr_rec.party_contact_id;
    p6_a12 := ddx_chr_rec.org_id;
  end;

end okl_credit_mgnt_pub_w;

/
