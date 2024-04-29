--------------------------------------------------------
--  DDL for Package CN_PAY_ELEMENT_INPUTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_ELEMENT_INPUTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwqpis.pls 115.4 2002/07/30 02:43:29 achung noship $ */
  procedure rosetta_table_copy_in_p2(t out cn_pay_element_inputs_pvt.pay_element_input_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p2(t cn_pay_element_inputs_pvt.pay_element_input_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_DATE_TABLE
    , a2 out JTF_DATE_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_NUMBER_TABLE
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    , a13 out JTF_VARCHAR2_TABLE_100
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_VARCHAR2_TABLE_200
    , a23 out JTF_VARCHAR2_TABLE_200
    , a24 out JTF_VARCHAR2_TABLE_200
    , a25 out JTF_VARCHAR2_TABLE_200
    , a26 out JTF_VARCHAR2_TABLE_200
    , a27 out JTF_VARCHAR2_TABLE_200
    , a28 out JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p5(t out cn_pay_element_inputs_pvt.pay_element_input_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cn_pay_element_inputs_pvt.pay_element_input_out_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_DATE_TABLE
    , a7 out JTF_DATE_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    );

  procedure create_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  DATE
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_pay_element_input_id out  NUMBER
    , x_loading_status out  VARCHAR2
  );
  procedure update_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  DATE
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  DATE
    , p8_a2  DATE
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , x_loading_status out  VARCHAR2
  );
  procedure get_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_element_type_id  NUMBER
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_order_by  VARCHAR2
    , p11_a0 out JTF_NUMBER_TABLE
    , p11_a1 out JTF_NUMBER_TABLE
    , p11_a2 out JTF_NUMBER_TABLE
    , p11_a3 out JTF_NUMBER_TABLE
    , p11_a4 out JTF_VARCHAR2_TABLE_100
    , p11_a5 out JTF_VARCHAR2_TABLE_100
    , p11_a6 out JTF_DATE_TABLE
    , p11_a7 out JTF_DATE_TABLE
    , p11_a8 out JTF_VARCHAR2_TABLE_100
    , p11_a9 out JTF_VARCHAR2_TABLE_100
    , p11_a10 out JTF_NUMBER_TABLE
    , p11_a11 out JTF_NUMBER_TABLE
    , p11_a12 out JTF_NUMBER_TABLE
    , x_total_records out  NUMBER
    , x_status out  VARCHAR2
    , x_loading_status out  VARCHAR2
  );
end cn_pay_element_inputs_pvt_w;

 

/
