--------------------------------------------------------
--  DDL for Package AST_CAMP_OUTCOME_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_CAMP_OUTCOME_PVT_W" AUTHID CURRENT_USER as
  /* $Header: astwcops.pls 115.2 2002/02/05 18:04:49 pkm ship      $ */
  procedure rosetta_table_copy_in_p3(t out ast_camp_outcome_pvt.camp_outcome_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ast_camp_outcome_pvt.camp_outcome_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_DATE_TABLE
    , a5 out JTF_NUMBER_TABLE
    , a6 out JTF_DATE_TABLE
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_VARCHAR2_TABLE_100
    );

  procedure create_camp_outcome(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure delete_camp_outcome(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
  );
end ast_camp_outcome_pvt_w;

 

/
