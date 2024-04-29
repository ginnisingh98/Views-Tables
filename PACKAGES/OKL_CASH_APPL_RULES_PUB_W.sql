--------------------------------------------------------
--  DDL for Package OKL_CASH_APPL_RULES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPL_RULES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCAPS.pls 120.3 2007/08/02 15:52:33 nikshah ship $ */
  procedure okl_cash_applic(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cons_bill_id  NUMBER
    , p_cons_bill_num  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_date  date
    , p_currency_conv_rate  NUMBER
    , p_irm_id  NUMBER
    , p_check_number  VARCHAR2
    , p_rcpt_amount  NUMBER
    , p_contract_id  NUMBER
    , p_contract_num  VARCHAR2
    , p_customer_id  NUMBER
    , p_customer_num  NUMBER
    , p_gl_date  date
    , p_receipt_date  date
    , p_bank_account_id  NUMBER
    , p_comments  VARCHAR2
    , p_create_receipt_flag  VARCHAR2
  );
  procedure create_manual_receipt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cons_bill_id  NUMBER
    , p_ar_inv_id  NUMBER
    , p_contract_id  NUMBER
    , x_cash_receipt_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  DATE := fnd_api.g_miss_date
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_cash_appl_rules_pub_w;

/
