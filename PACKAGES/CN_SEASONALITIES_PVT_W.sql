--------------------------------------------------------
--  DDL for Package CN_SEASONALITIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEASONALITIES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwseass.pls 115.5 2002/11/25 22:30:26 nkodkani ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy cn_seasonalities_pvt.seasonalities_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t cn_seasonalities_pvt.seasonalities_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure update_seasonalities(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_seasonalities(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_seasonalities_pvt_w;

 

/
