--------------------------------------------------------
--  DDL for Package Body OKL_LA_VALIDATION_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_VALIDATION_UTIL_PVT_W" as
  /* $Header: OKLEDVUB.pls 115.4 2003/09/23 14:17:45 kthiruva noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure validate_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_scs_code  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_customer_id1 in out nocopy  VARCHAR2
    , p_customer_id2 in out nocopy  VARCHAR2
    , p_customer_code in out nocopy  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_chr_cust_acct_id out nocopy  NUMBER
    , p_customer_acc_name  VARCHAR2
    , p_product_name  VARCHAR2
    , p_product_id in out nocopy  VARCHAR2
    , p_product_desc in out nocopy  VARCHAR2
    , p_contact_id1 in out nocopy  VARCHAR2
    , p_contact_id2 in out nocopy  VARCHAR2
    , p_contact_code in out nocopy  VARCHAR2
    , p_contact_name  VARCHAR2
    , p_mla_no  VARCHAR2
    , p_mla_id in out nocopy  VARCHAR2
    , p_program_no  VARCHAR2
    , p_program_id in out nocopy  VARCHAR2
    , p_credit_line_no  VARCHAR2
    , p_credit_line_id in out nocopy  VARCHAR2
    , p_currency_name  VARCHAR2
    , p_currency_code in out nocopy  VARCHAR2
    , p_start_date  date
    , p_deal_type  VARCHAR2
  )

  as
    ddp_start_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





























    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_la_validation_util_pvt.validate_deal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_scs_code,
      p_contract_number,
      p_customer_id1,
      p_customer_id2,
      p_customer_code,
      p_customer_name,
      p_chr_cust_acct_id,
      p_customer_acc_name,
      p_product_name,
      p_product_id,
      p_product_desc,
      p_contact_id1,
      p_contact_id2,
      p_contact_code,
      p_contact_name,
      p_mla_no,
      p_mla_id,
      p_program_no,
      p_program_id,
      p_credit_line_no,
      p_credit_line_id,
      p_currency_name,
      p_currency_code,
      ddp_start_date,
      p_deal_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






























  end;

end okl_la_validation_util_pvt_w;

/
