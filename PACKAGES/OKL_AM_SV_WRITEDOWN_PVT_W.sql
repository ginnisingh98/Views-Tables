--------------------------------------------------------
--  DDL for Package OKL_AM_SV_WRITEDOWN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SV_WRITEDOWN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESVWS.pls 120.1 2005/07/07 12:46:50 asawanka noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_am_sv_writedown_pvt.assets_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t okl_am_sv_writedown_pvt.assets_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_salvage_value_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , x_salvage_value_status out nocopy  VARCHAR2
  );
end okl_am_sv_writedown_pvt_w;

 

/
