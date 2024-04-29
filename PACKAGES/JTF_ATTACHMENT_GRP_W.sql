--------------------------------------------------------
--  DDL for Package JTF_ATTACHMENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ATTACHMENT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRATS.pls 115.8 2004/07/09 18:50:24 applrt ship $ */
  procedure rosetta_table_copy_in_p1(t out jtf_attachment_grp.attachment_tbl_type, a0 JTF_NUMBER_TABLE
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
    );
  procedure rosetta_table_copy_out_p1(t jtf_attachment_grp.attachment_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_VARCHAR2_TABLE_300
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    , a13 out JTF_VARCHAR2_TABLE_2000
    , a14 out JTF_VARCHAR2_TABLE_2000
    , a15 out JTF_VARCHAR2_TABLE_2000
    , a16 out JTF_VARCHAR2_TABLE_100
    , a17 out JTF_VARCHAR2_TABLE_100
    , a18 out JTF_VARCHAR2_TABLE_100
    , a19 out JTF_NUMBER_TABLE
    , a20 out JTF_VARCHAR2_TABLE_2000
    , a21 out JTF_VARCHAR2_TABLE_300
    , a22 out JTF_VARCHAR2_TABLE_1100
    , a23 out JTF_NUMBER_TABLE
    , a24 out JTF_VARCHAR2_TABLE_300
    , a25 out JTF_VARCHAR2_TABLE_100
    , a26 out JTF_VARCHAR2_TABLE_200
    , a27 out JTF_VARCHAR2_TABLE_200
    , a28 out JTF_VARCHAR2_TABLE_200
    , a29 out JTF_VARCHAR2_TABLE_200
    , a30 out JTF_VARCHAR2_TABLE_200
    , a31 out JTF_VARCHAR2_TABLE_200
    , a32 out JTF_VARCHAR2_TABLE_200
    , a33 out JTF_VARCHAR2_TABLE_200
    , a34 out JTF_VARCHAR2_TABLE_200
    , a35 out JTF_VARCHAR2_TABLE_200
    , a36 out JTF_VARCHAR2_TABLE_200
    , a37 out JTF_VARCHAR2_TABLE_200
    , a38 out JTF_VARCHAR2_TABLE_200
    , a39 out JTF_VARCHAR2_TABLE_200
    , a40 out JTF_VARCHAR2_TABLE_200
    , a41 out JTF_VARCHAR2_TABLE_2000
    , a42 out JTF_VARCHAR2_TABLE_1000
    , a43 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out jtf_attachment_grp.ath_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t jtf_attachment_grp.ath_id_ver_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out jtf_attachment_grp.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t jtf_attachment_grp.number_table, a0 out JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p5(t out jtf_attachment_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p5(t jtf_attachment_grp.varchar2_table_300, a0 out JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p6(t out jtf_attachment_grp.varchar2_table_20, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p6(t jtf_attachment_grp.varchar2_table_20, a0 out JTF_VARCHAR2_TABLE_100);

  procedure list_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_appl_id  NUMBER
    , p_deliverable_id  NUMBER
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_ath_id_tbl out JTF_NUMBER_TABLE
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
    , x_file_ext_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_width_tbl out JTF_NUMBER_TABLE
    , x_dsp_height_tbl out JTF_NUMBER_TABLE
    , x_version_tbl out JTF_NUMBER_TABLE
  );
  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  NUMBER
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  NUMBER
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  VARCHAR2
    , p6_a8 in out  NUMBER
    , p6_a9 in out  VARCHAR2
    , p6_a10 in out  VARCHAR2
    , p6_a11 in out  NUMBER
    , p6_a12 in out  NUMBER
    , p6_a13 in out  VARCHAR2
    , p6_a14 in out  VARCHAR2
    , p6_a15 in out  VARCHAR2
    , p6_a16 in out  VARCHAR2
    , p6_a17 in out  VARCHAR2
    , p6_a18 in out  VARCHAR2
    , p6_a19 in out  NUMBER
    , p6_a20 in out  VARCHAR2
    , p6_a21 in out  VARCHAR2
    , p6_a22 in out  VARCHAR2
    , p6_a23 in out  NUMBER
    , p6_a24 in out  VARCHAR2
    , p6_a25 in out  VARCHAR2
    , p6_a26 in out  VARCHAR2
    , p6_a27 in out  VARCHAR2
    , p6_a28 in out  VARCHAR2
    , p6_a29 in out  VARCHAR2
    , p6_a30 in out  VARCHAR2
    , p6_a31 in out  VARCHAR2
    , p6_a32 in out  VARCHAR2
    , p6_a33 in out  VARCHAR2
    , p6_a34 in out  VARCHAR2
    , p6_a35 in out  VARCHAR2
    , p6_a36 in out  VARCHAR2
    , p6_a37 in out  VARCHAR2
    , p6_a38 in out  VARCHAR2
    , p6_a39 in out  VARCHAR2
    , p6_a40 in out  VARCHAR2
    , p6_a41 in out  VARCHAR2
    , p6_a42 in out  VARCHAR2
    , p6_a43 in out  VARCHAR2
  );
  procedure save_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_NUMBER_TABLE
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_NUMBER_TABLE
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_100
    , p6_a6 in out JTF_VARCHAR2_TABLE_100
    , p6_a7 in out JTF_VARCHAR2_TABLE_100
    , p6_a8 in out JTF_NUMBER_TABLE
    , p6_a9 in out JTF_VARCHAR2_TABLE_100
    , p6_a10 in out JTF_VARCHAR2_TABLE_300
    , p6_a11 in out JTF_NUMBER_TABLE
    , p6_a12 in out JTF_NUMBER_TABLE
    , p6_a13 in out JTF_VARCHAR2_TABLE_2000
    , p6_a14 in out JTF_VARCHAR2_TABLE_2000
    , p6_a15 in out JTF_VARCHAR2_TABLE_2000
    , p6_a16 in out JTF_VARCHAR2_TABLE_100
    , p6_a17 in out JTF_VARCHAR2_TABLE_100
    , p6_a18 in out JTF_VARCHAR2_TABLE_100
    , p6_a19 in out JTF_NUMBER_TABLE
    , p6_a20 in out JTF_VARCHAR2_TABLE_2000
    , p6_a21 in out JTF_VARCHAR2_TABLE_300
    , p6_a22 in out JTF_VARCHAR2_TABLE_1100
    , p6_a23 in out JTF_NUMBER_TABLE
    , p6_a24 in out JTF_VARCHAR2_TABLE_300
    , p6_a25 in out JTF_VARCHAR2_TABLE_100
    , p6_a26 in out JTF_VARCHAR2_TABLE_200
    , p6_a27 in out JTF_VARCHAR2_TABLE_200
    , p6_a28 in out JTF_VARCHAR2_TABLE_200
    , p6_a29 in out JTF_VARCHAR2_TABLE_200
    , p6_a30 in out JTF_VARCHAR2_TABLE_200
    , p6_a31 in out JTF_VARCHAR2_TABLE_200
    , p6_a32 in out JTF_VARCHAR2_TABLE_200
    , p6_a33 in out JTF_VARCHAR2_TABLE_200
    , p6_a34 in out JTF_VARCHAR2_TABLE_200
    , p6_a35 in out JTF_VARCHAR2_TABLE_200
    , p6_a36 in out JTF_VARCHAR2_TABLE_200
    , p6_a37 in out JTF_VARCHAR2_TABLE_200
    , p6_a38 in out JTF_VARCHAR2_TABLE_200
    , p6_a39 in out JTF_VARCHAR2_TABLE_200
    , p6_a40 in out JTF_VARCHAR2_TABLE_200
    , p6_a41 in out JTF_VARCHAR2_TABLE_2000
    , p6_a42 in out JTF_VARCHAR2_TABLE_1000
    , p6_a43 in out JTF_VARCHAR2_TABLE_100
  );
  procedure delete_attachment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_300
    , p6_a2 in out JTF_NUMBER_TABLE
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
  );
end jtf_attachment_grp_w;

 

/
