--------------------------------------------------------
--  DDL for Package OZF_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_UTILITY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwutls.pls 120.1 2006/04/04 08:30:25 sshivali noship $ */
  procedure rosetta_table_copy_in_p12(t out nocopy ozf_utility_pvt.operating_units_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p12(t ozf_utility_pvt.operating_units_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p59(t out nocopy ozf_utility_pvt.dependent_objects_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p59(t ozf_utility_pvt.dependent_objects_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure log_message(p_log_level  NUMBER
    , p_module_name  VARCHAR2
    , p_rcs_id  VARCHAR2
    , p_pop_message  number
  );
  procedure logging_enabled(p_log_level  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure create_log(x_return_status out nocopy  VARCHAR2
    , p_arc_log_used_by  VARCHAR2
    , p_log_used_by_id  VARCHAR2
    , p_msg_data  VARCHAR2
    , p_msg_level  NUMBER
    , p_msg_type  VARCHAR2
    , p_desc  VARCHAR2
    , p_budget_id  NUMBER
    , p_threshold_id  NUMBER
    , p_transaction_id  NUMBER
    , p_notification_creat_date  date
    , p_activity_log_id  NUMBER
  );
  procedure convert_currency(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
  );
  procedure convert_timezone(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_tz_id  NUMBER
    , p_in_time  date
    , p_convert_type  VARCHAR2
    , x_out_time out nocopy  DATE
  );
  procedure convert_currency(p_set_of_books_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_conversion_date  date
    , p_conversion_type  VARCHAR2
    , p_conversion_rate  NUMBER
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_acc_amount out nocopy  NUMBER
    , x_rate out nocopy  NUMBER
  );
  procedure calculate_functional_curr(p_from_amount  NUMBER
    , p_conv_date  date
    , p_tc_currency_code  VARCHAR2
    , p_org_id  NUMBER
    , x_to_amount out nocopy  NUMBER
    , x_set_of_books_id out nocopy  NUMBER
    , x_mrc_sob_type_code out nocopy  VARCHAR2
    , x_fc_currency_code out nocopy  VARCHAR2
    , x_exchange_rate_type in out nocopy  VARCHAR2
    , x_exchange_rate in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure calculate_functional_currency(p_from_amount  NUMBER
    , p_conv_date  date
    , p_tc_currency_code  VARCHAR2
    , p_ledger_id  NUMBER
    , x_to_amount out nocopy  NUMBER
    , x_mrc_sob_type_code out nocopy  VARCHAR2
    , x_fc_currency_code out nocopy  VARCHAR2
    , x_exchange_rate_type in out nocopy  VARCHAR2
    , x_exchange_rate in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure convert_currency(p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_type  VARCHAR2
    , p_conv_rate  NUMBER
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_to_amount out nocopy  NUMBER
    , x_rate out nocopy  NUMBER
  );
end ozf_utility_pvt_w;

 

/
