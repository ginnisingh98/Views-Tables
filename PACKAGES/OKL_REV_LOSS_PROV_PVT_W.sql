--------------------------------------------------------
--  DDL for Package OKL_REV_LOSS_PROV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REV_LOSS_PROV_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLERPVS.pls 115.4 2003/01/06 19:32:07 sgiyer noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_rev_loss_prov_pvt.lprv_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t okl_rev_loss_prov_pvt.lprv_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    );

  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
  );
  procedure reverse_loss_provisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
  );
end okl_rev_loss_prov_pvt_w;

 

/
