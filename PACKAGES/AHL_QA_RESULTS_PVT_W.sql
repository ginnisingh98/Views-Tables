--------------------------------------------------------
--  DDL for Package AHL_QA_RESULTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_QA_RESULTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWQARS.pls 115.2 2002/11/14 23:06:50 shkalyan noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_qa_results_pvt.qa_results_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t ahl_qa_results_pvt.qa_results_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_qa_results_pvt.occurrence_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ahl_qa_results_pvt.occurrence_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_qa_results_pvt.qa_context_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p5(t ahl_qa_results_pvt.qa_context_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure submit_qa_results(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_plan_id  NUMBER
    , p_organization_id  NUMBER
    , p_transaction_no  NUMBER
    , p_specification_id  NUMBER
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_VARCHAR2_TABLE_2000
    , p13_a2 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_VARCHAR2_TABLE_2000
    , p14_a2 JTF_NUMBER_TABLE
    , p15_a0 JTF_VARCHAR2_TABLE_100
    , p15_a1 JTF_VARCHAR2_TABLE_2000
    , p_result_commit_flag  NUMBER
    , p_id_or_value  VARCHAR2
    , p_x_collection_id in out nocopy  NUMBER
    , p19_a0 in out nocopy JTF_NUMBER_TABLE
    , p19_a1 in out nocopy JTF_NUMBER_TABLE
  );
end ahl_qa_results_pvt_w;

 

/
