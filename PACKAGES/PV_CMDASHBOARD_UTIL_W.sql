--------------------------------------------------------
--  DDL for Package PV_CMDASHBOARD_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_CMDASHBOARD_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: pvxwcdus.pls 120.0 2005/07/05 23:49:43 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy pv_cmdashboard_util.kpi_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t pv_cmdashboard_util.kpi_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_kpis_detail(p_resource_id  NUMBER
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 in out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end pv_cmdashboard_util_w;

 

/
