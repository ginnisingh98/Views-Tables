--------------------------------------------------------
--  DDL for Package CSE_DEPLOYMENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_DEPLOYMENT_GRP_W" AUTHID CURRENT_USER as
/* $Header: CSEDPLWS.pls 120.5 2006/07/24 17:07:53 sguthiva noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cse_deployment_grp.txn_instances_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cse_deployment_grp.txn_instances_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cse_deployment_grp.dest_location_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t cse_deployment_grp.dest_location_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy cse_deployment_grp.txn_ext_attrib_values_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cse_deployment_grp.txn_ext_attrib_values_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cse_deployment_grp.transaction_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t cse_deployment_grp.transaction_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_transaction(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_100
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_VARCHAR2_TABLE_100
    , p0_a12 JTF_NUMBER_TABLE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_VARCHAR2_TABLE_100
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_NUMBER_TABLE
    , p2_a2 in out nocopy JTF_NUMBER_TABLE
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , p2_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a6 in out nocopy JTF_DATE_TABLE
    , p2_a7 in out nocopy JTF_DATE_TABLE
    , p2_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_DATE_TABLE
    , p3_a2 in out nocopy JTF_DATE_TABLE
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_NUMBER_TABLE
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_NUMBER_TABLE
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_msg out nocopy  VARCHAR2
  );
end cse_deployment_grp_w;

 

/
