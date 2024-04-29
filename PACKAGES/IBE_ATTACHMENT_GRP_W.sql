--------------------------------------------------------
--  DDL for Package IBE_ATTACHMENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ATTACHMENT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRATS.pls 115.2 2002/12/18 07:07:13 schak ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ibe_attachment_grp.attachment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_1100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_VARCHAR2_TABLE_1000
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ibe_attachment_grp.attachment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_1100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_VARCHAR2_TABLE_1000
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ibe_attachment_grp.ath_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ibe_attachment_grp.ath_id_ver_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ibe_attachment_grp.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t ibe_attachment_grp.number_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p5(t out nocopy ibe_attachment_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p5(t ibe_attachment_grp.varchar2_table_300, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p6(t out nocopy ibe_attachment_grp.varchar2_table_20, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p6(t ibe_attachment_grp.varchar2_table_20, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure list_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_appl_id  NUMBER
    , p_deliverable_id  NUMBER
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out nocopy  NUMBER
    , x_ath_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_dlv_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_file_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_file_ext_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_dsp_width_tbl out nocopy JTF_NUMBER_TABLE
    , x_dsp_height_tbl out nocopy JTF_NUMBER_TABLE
    , x_version_tbl out nocopy JTF_NUMBER_TABLE
  );
  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  VARCHAR2
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  NUMBER
    , p6_a12 in out nocopy  NUMBER
    , p6_a13 in out nocopy  VARCHAR2
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  VARCHAR2
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  NUMBER
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  NUMBER
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p6_a26 in out nocopy  VARCHAR2
    , p6_a27 in out nocopy  VARCHAR2
    , p6_a28 in out nocopy  VARCHAR2
    , p6_a29 in out nocopy  VARCHAR2
    , p6_a30 in out nocopy  VARCHAR2
    , p6_a31 in out nocopy  VARCHAR2
    , p6_a32 in out nocopy  VARCHAR2
    , p6_a33 in out nocopy  VARCHAR2
    , p6_a34 in out nocopy  VARCHAR2
    , p6_a35 in out nocopy  VARCHAR2
    , p6_a36 in out nocopy  VARCHAR2
    , p6_a37 in out nocopy  VARCHAR2
    , p6_a38 in out nocopy  VARCHAR2
    , p6_a39 in out nocopy  VARCHAR2
    , p6_a40 in out nocopy  VARCHAR2
    , p6_a41 in out nocopy  VARCHAR2
    , p6_a42 in out nocopy  VARCHAR2
    , p6_a43 in out nocopy  VARCHAR2
    , p6_a44 in out nocopy  VARCHAR2
  );
  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 in out nocopy JTF_NUMBER_TABLE
    , p6_a12 in out nocopy JTF_NUMBER_TABLE
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 in out nocopy JTF_NUMBER_TABLE
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_1100
    , p6_a23 in out nocopy JTF_NUMBER_TABLE
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a41 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a42 in out nocopy JTF_VARCHAR2_TABLE_1000
    , p6_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure delete_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ibe_attachment_grp_w;

 

/
