--------------------------------------------------------
--  DDL for Package QA_AUDIT_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_AUDIT_PKG_W" AUTHID CURRENT_USER as
  /* $Header: qaaudwrs.pls 120.0 2005/06/09 09:41 srhariha noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy qa_audit_pkg.summaryparamarray, a0 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p2(t qa_audit_pkg.summaryparamarray, a0 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p3(t out nocopy qa_audit_pkg.catsummaryparamarray, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p3(t qa_audit_pkg.catsummaryparamarray, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure copy_questions(p_audit_bank_plan_id  NUMBER
    , p_audit_bank_org_id  NUMBER
    , p2_a0 JTF_VARCHAR2_TABLE_200
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p3_a1 JTF_VARCHAR2_TABLE_200
    , p3_a2 JTF_VARCHAR2_TABLE_200
    , p3_a3 JTF_VARCHAR2_TABLE_200
    , p_audit_question_plan_id  NUMBER
    , p_audit_question_org_id  NUMBER
    , p_audit_num  VARCHAR2
    , x_count out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
end qa_audit_pkg_w;

 

/
