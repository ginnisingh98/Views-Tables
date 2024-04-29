--------------------------------------------------------
--  DDL for Package CSK_SETUP_UTILITY_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSK_SETUP_UTILITY_PKG_W" AUTHID CURRENT_USER as
  /* $Header: csktsuws.pls 120.0 2005/06/01 12:02:26 appldev noship $ */
  procedure rosetta_table_copy_in_p12(t out nocopy csk_setup_utility_pkg.stmt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t csk_setup_utility_pkg.stmt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p13(t out nocopy csk_setup_utility_pkg.cat_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p13(t csk_setup_utility_pkg.cat_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure create_solution(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_2000
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p_cat_tbl JTF_NUMBER_TABLE
    , p_publish  number
  );
end csk_setup_utility_pkg_w;

 

/
