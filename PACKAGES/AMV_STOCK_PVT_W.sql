--------------------------------------------------------
--  DDL for Package AMV_STOCK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_STOCK_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amvwstks.pls 120.2 2005/06/30 08:26 appldev ship $ */
  procedure rosetta_table_copy_in_p6(t out nocopy amv_stock_pvt.amv_tkr_varray_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t amv_stock_pvt.amv_tkr_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy amv_stock_pvt.amv_sym_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t amv_stock_pvt.amv_sym_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out nocopy amv_stock_pvt.amv_stk_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t amv_stock_pvt.amv_stk_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy amv_stock_pvt.amv_news_varray_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p9(t amv_stock_pvt.amv_news_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy amv_stock_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_400);
  procedure rosetta_table_copy_out_p10(t amv_stock_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_400);

  procedure rosetta_table_copy_in_p11(t out nocopy amv_stock_pvt.amv_num_varray_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p11(t amv_stock_pvt.amv_num_varray_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure get_userticker(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_id  NUMBER
    , p_distinct_stocks  VARCHAR2
    , p_sort_order  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_stockdetails(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_symbols  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_vendormissedstocks(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
    , p_start_index  NUMBER
    , p_batch_size  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure insert_stockvendorkeys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  NUMBER := 0-1962.0724
  );
  procedure get_userselectedkeys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
    , p_all_keys  VARCHAR2
    , x_keys_array out nocopy JTF_VARCHAR2_TABLE_400
  );
  procedure insert_vendornews(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  DATE := fnd_api.g_miss_date
  );
  procedure get_companynews(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_stock_id  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_DATE_TABLE
  );
end amv_stock_pvt_w;

 

/
