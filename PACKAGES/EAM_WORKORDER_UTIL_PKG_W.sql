--------------------------------------------------------
--  DDL for Package EAM_WORKORDER_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDER_UTIL_PKG_W" AUTHID CURRENT_USER as
  /* $Header: EAMVWUPS.pls 120.0 2005/06/08 02:49:08 appldev noship $ eam_workorder_util_pkg_w.pkb 115.0 2005/05/23 07:08:38 grajan noship $*/

  procedure rosetta_table_copy_in_p7(t out nocopy eam_workorder_util_pkg.t_workflow_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t eam_workorder_util_pkg.t_workflow_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );


  procedure get_workflow_details(p_item_type  String
    , p_item_key  String
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
  );
end eam_workorder_util_pkg_w;

 

/
