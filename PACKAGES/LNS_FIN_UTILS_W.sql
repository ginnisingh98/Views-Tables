--------------------------------------------------------
--  DDL for Package LNS_FIN_UTILS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FIN_UTILS_W" AUTHID CURRENT_USER as
  /* $Header: LNS_FIN_UTILSJ_S.pls 120.0.12010000.3 2010/02/05 18:23:25 mbolli ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy lns_fin_utils.date_tbl, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p0(t lns_fin_utils.date_tbl, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy lns_fin_utils.payment_schedule_tbl, a0 JTF_DATE_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t lns_fin_utils.payment_schedule_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure isleapyear(p_year  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end lns_fin_utils_w;

/
