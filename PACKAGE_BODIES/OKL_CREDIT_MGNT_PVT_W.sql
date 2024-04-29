--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MGNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MGNT_PVT_W" as
  /* $Header: OKLECMTB.pls 115.3 2003/01/20 17:38:22 rgalipo noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := okl_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return okl_api.g_miss_date; end if;
    return d;
  end;

  procedure submit_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_contract_id  NUMBER
    , p_review_type  VARCHAR2
    , p_credit_classification  VARCHAR2
    , p_requested_amount  NUMBER
    , p_contact_party_id  NUMBER
    , p_notes  VARCHAR2
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  VARCHAR2 := null
    , p11_a6  NUMBER := 0-1962.0724
    , p11_a7  VARCHAR2 := null
    , p11_a8  NUMBER := 0-1962.0724
    , p11_a9  NUMBER := 0-1962.0724
    , p11_a10  NUMBER := 0-1962.0724
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_chr_rec okl_credit_mgnt_pvt.l_chr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_chr_rec.party_id := rosetta_g_miss_num_map(p11_a0);
    ddp_chr_rec.cust_acct_id := rosetta_g_miss_num_map(p11_a1);
    ddp_chr_rec.cust_acct_site_id := rosetta_g_miss_num_map(p11_a2);
    ddp_chr_rec.site_use_id := rosetta_g_miss_num_map(p11_a3);
    ddp_chr_rec.contract_id := rosetta_g_miss_num_map(p11_a4);
    ddp_chr_rec.contract_number := p11_a5;
    ddp_chr_rec.credit_khr_id := rosetta_g_miss_num_map(p11_a6);
    ddp_chr_rec.currency := p11_a7;
    ddp_chr_rec.txn_amount := rosetta_g_miss_num_map(p11_a8);
    ddp_chr_rec.requested_amount := rosetta_g_miss_num_map(p11_a9);
    ddp_chr_rec.term := rosetta_g_miss_num_map(p11_a10);
    ddp_chr_rec.party_contact_id := rosetta_g_miss_num_map(p11_a11);
    ddp_chr_rec.org_id := rosetta_g_miss_num_map(p11_a12);

    -- here's the delegated call to the old PL/SQL routine
    okl_credit_mgnt_pvt.submit_credit_request(p_api_version,
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
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_contract_id  NUMBER
    , p6_a0 out NOCOPY  NUMBER
    , p6_a1 out NOCOPY  NUMBER
    , p6_a2 out  NOCOPY NUMBER
    , p6_a3 out  NOCOPY NUMBER
    , p6_a4 out  NOCOPY NUMBER
    , p6_a5 out  NOCOPY VARCHAR2
    , p6_a6 out  NOCOPY NUMBER
    , p6_a7 out  NOCOPY VARCHAR2
    , p6_a8 out  NOCOPY NUMBER
    , p6_a9 out  NOCOPY NUMBER
    , p6_a10 out NOCOPY  NUMBER
    , p6_a11 out NOCOPY  NUMBER
    , p6_a12 out NOCOPY  NUMBER
  )

  as
    ddx_chr_rec okl_credit_mgnt_pvt.l_chr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_credit_mgnt_pvt.compile_credit_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_id,
      ddx_chr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_chr_rec.party_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_chr_rec.cust_acct_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_chr_rec.cust_acct_site_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_chr_rec.site_use_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_chr_rec.contract_id);
    p6_a5 := ddx_chr_rec.contract_number;
    p6_a6 := rosetta_g_miss_num_map(ddx_chr_rec.credit_khr_id);
    p6_a7 := ddx_chr_rec.currency;
    p6_a8 := rosetta_g_miss_num_map(ddx_chr_rec.txn_amount);
    p6_a9 := rosetta_g_miss_num_map(ddx_chr_rec.requested_amount);
    p6_a10 := rosetta_g_miss_num_map(ddx_chr_rec.term);
    p6_a11 := rosetta_g_miss_num_map(ddx_chr_rec.party_contact_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_chr_rec.org_id);
  end;

end okl_credit_mgnt_pvt_w;

/
