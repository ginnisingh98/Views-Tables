--------------------------------------------------------
--  DDL for Package EAM_PMDEF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PMDEF_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMWPMDS.pls 120.1 2005/08/17 08:19:08 ksiddhar noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy eam_pmdef_pub.pm_activities_grp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p2(t eam_pmdef_pub.pm_activities_grp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy eam_pmdef_pub.pm_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t eam_pmdef_pub.pm_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy eam_pmdef_pub.pm_date_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t eam_pmdef_pub.pm_date_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy eam_pmdef_pub.pm_num_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t eam_pmdef_pub.pm_num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure instantiate_pm_defs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_activity_assoc_id_tbl JTF_NUMBER_TABLE
  );
  procedure create_pm_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_DATE_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_DATE_TABLE
    , p11_a10 JTF_DATE_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , x_new_pm_schedule_id out nocopy  NUMBER
  );
  procedure update_pm_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_DATE_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_DATE_TABLE
    , p11_a10 JTF_DATE_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
  );
  procedure validate_pm_header(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  DATE
    , p0_a33  DATE
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  DATE
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_day_interval_rule(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_runtime_rule(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_list_date(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_day_interval_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_runtime_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_list_date_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_header_and_rules(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  DATE
    , p0_a33  DATE
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  DATE
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_DATE_TABLE
    , p2_a10 JTF_DATE_TABLE
    , p2_a11 JTF_DATE_TABLE
    , p2_a12 JTF_VARCHAR2_TABLE_100
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_DATE_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_DATE_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_activity(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  DATE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  DATE
    , p2_a33  DATE
    , p2_a34  NUMBER
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  NUMBER
    , p2_a42  NUMBER
    , p2_a43  DATE
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_activity(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  DATE
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  DATE
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  DATE
    , p1_a33  DATE
    , p1_a34  NUMBER
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  DATE
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_pm_activities(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  DATE
    , p2_a33  DATE
    , p2_a34  NUMBER
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  NUMBER
    , p2_a42  NUMBER
    , p2_a43  DATE
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure sort_table_by_date(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_DATE_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p_num_rows  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_DATE_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
  );
  procedure sort_table_by_number(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p_num_rows  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
  );
  procedure merge_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p2_a5 out nocopy JTF_NUMBER_TABLE
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_NUMBER_TABLE
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p2_a9 out nocopy JTF_DATE_TABLE
    , p2_a10 out nocopy JTF_DATE_TABLE
    , p2_a11 out nocopy JTF_DATE_TABLE
    , p2_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
end eam_pmdef_pub_w;

 

/
