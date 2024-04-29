--------------------------------------------------------
--  DDL for Package IBY_DBCCARD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DBCCARD_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ibyrdmns.pls 115.1 2002/11/20 01:20:18 jleybovi noship $ */
  procedure rosetta_table_copy_in_p13(t out nocopy iby_dbccard_pvt.summary_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t iby_dbccard_pvt.summary_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p14(t out nocopy iby_dbccard_pvt.trxnsum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p14(t iby_dbccard_pvt.trxnsum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p15(t out nocopy iby_dbccard_pvt.trxnfail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p15(t iby_dbccard_pvt.trxnfail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_trxn_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_failure_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_cardtype_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_processor_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
  );
end iby_dbccard_pvt_w;

 

/
