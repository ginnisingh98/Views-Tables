--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: OKLEAUTS.pls 120.3 2007/01/25 11:20:28 nikshah ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okl_accounting_util.seg_num_array_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t okl_accounting_util.seg_num_array_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy okl_accounting_util.seg_array_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t okl_accounting_util.seg_array_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy okl_accounting_util.seg_desc_array_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p2(t okl_accounting_util.seg_desc_array_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p3(t out nocopy okl_accounting_util.error_message_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p3(t okl_accounting_util.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure rosetta_table_copy_in_p26(t out nocopy okl_accounting_util.overlap_attrib_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p26(t okl_accounting_util.overlap_attrib_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure get_segment_array(p_concate_segments  VARCHAR2
    , p_delimiter  VARCHAR2
    , p_seg_array_type out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_error_message(p_all_message out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure get_error_msg(p_all_message out nocopy JTF_VARCHAR2_TABLE_2000
  );
  function get_curr_con_rate(p_from_curr_code  VARCHAR2
    , p_to_curr_code  VARCHAR2
    , p_con_date  date
    , p_con_type  VARCHAR2
  ) return number;
  procedure get_curr_con_rate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_curr_code  VARCHAR2
    , p_to_curr_code  VARCHAR2
    , p_con_date  date
    , p_con_type  VARCHAR2
    , x_conv_rate out nocopy  NUMBER
  );
  procedure get_accounting_segment(p0_a0 out nocopy  JTF_NUMBER_TABLE
    , p0_a1 out nocopy  JTF_VARCHAR2_TABLE_100
    , p0_a2 out nocopy  JTF_VARCHAR2_TABLE_100
  );
  procedure get_period_info(p_date  date
    , p_period_name out nocopy  VARCHAR2
    , p_start_date out nocopy  DATE
    , p_end_date out nocopy  DATE
    , p_ledger_id  NUMBER
  );
  procedure check_overlaps(p_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p_start_date_attribute_name  VARCHAR2
    , p_start_date  date
    , p_end_date_attribute_name  VARCHAR2
    , p_end_date  date
    , p_view  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_valid out nocopy  number
  );
  procedure get_version(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p_cur_version  VARCHAR2
    , p_end_date_attribute_name  VARCHAR2
    , p_end_date  date
    , p_view  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_new_version out nocopy  VARCHAR2
  );
  procedure convert_to_functional_currency(p_khr_id  NUMBER
    , p_to_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  );
  procedure convert_to_functional_currency(p_khr_id  NUMBER
    , p_to_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  );
  procedure convert_to_contract_currency(p_khr_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  );
  procedure convert_to_contract_currency(p_khr_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  );
  function get_valid_gl_date(p_gl_date  date
    , p_ledger_id  NUMBER
  ) return date;
end okl_accounting_util_w;

/
