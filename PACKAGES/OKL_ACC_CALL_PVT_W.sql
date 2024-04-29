--------------------------------------------------------
--  DDL for Package OKL_ACC_CALL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_CALL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEACCS.pls 120.1 2005/07/07 13:30:37 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_acc_call_pvt.bpd_acc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t okl_acc_call_pvt.bpd_acc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_acc_trans(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_acc_trans(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  );
end okl_acc_call_pvt_w;

 

/
