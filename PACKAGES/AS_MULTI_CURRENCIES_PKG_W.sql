--------------------------------------------------------
--  DDL for Package AS_MULTI_CURRENCIES_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_MULTI_CURRENCIES_PKG_W" AUTHID CURRENT_USER as
  /* $Header: asxwmcps.pls 120.1 2005/06/24 22:26 appldev ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy as_multi_currencies_pkg.type_mappings_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t as_multi_currencies_pkg.type_mappings_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy as_multi_currencies_pkg.period_rates_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t as_multi_currencies_pkg.period_rates_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure insert_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure insert_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end as_multi_currencies_pkg_w;

 

/
