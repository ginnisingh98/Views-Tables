--------------------------------------------------------
--  DDL for Package IBY_DBCCARD_GRAPH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DBCCARD_GRAPH_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ibyrdghs.pls 115.1 2002/11/16 01:42:08 jleybovi noship $ */
  procedure rosetta_table_copy_in_p12(t out nocopy iby_dbccard_graph_pvt.hourlyvol_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t iby_dbccard_graph_pvt.hourlyvol_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p13(t out nocopy iby_dbccard_graph_pvt.trxntrends_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p13(t iby_dbccard_graph_pvt.trxntrends_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p14(t out nocopy iby_dbccard_graph_pvt.trends_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p14(t iby_dbccard_graph_pvt.trends_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    );

  procedure get_hourly_volume(payee_id  VARCHAR2
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_trxn_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  );
  procedure get_processor_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  );
  procedure get_subtype_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  );
  procedure get_failure_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  );
end iby_dbccard_graph_pvt_w;

 

/
