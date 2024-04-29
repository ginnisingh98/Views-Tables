--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK_W" AUTHID CURRENT_USER as
  /* $Header: cacvstws.pls 120.3 2005/09/27 07:37:15 rhshriva noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy cac_sync_task.task_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_4000
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_2000
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_4000
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t cac_sync_task.task_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_4000
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy cac_sync_task.exclusion_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_4000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_2000
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_4000
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t cac_sync_task.exclusion_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_4000
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy cac_sync_task.attendee_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_2000
    , a13 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t cac_sync_task.attendee_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_count(p_request_type  VARCHAR2
    , p_syncanchor  date
    , p_principal_id  NUMBER
    , x_total out nocopy  NUMBER
    , x_totalnew out nocopy  NUMBER
    , x_totalmodified out nocopy  NUMBER
    , x_totaldeleted out nocopy  NUMBER
  );
  procedure get_list(p_request_type  VARCHAR2
    , p_syncanchor  date
    , p_principal_id  NUMBER
    , p_sync_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_DATE_TABLE
    , p4_a11 out nocopy JTF_DATE_TABLE
    , p4_a12 out nocopy JTF_DATE_TABLE
    , p4_a13 out nocopy JTF_DATE_TABLE
    , p4_a14 out nocopy JTF_DATE_TABLE
    , p4_a15 out nocopy JTF_DATE_TABLE
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a19 out nocopy JTF_DATE_TABLE
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a22 out nocopy JTF_NUMBER_TABLE
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a24 out nocopy JTF_NUMBER_TABLE
    , p4_a25 out nocopy JTF_NUMBER_TABLE
    , p4_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a29 out nocopy JTF_NUMBER_TABLE
    , p4_a30 out nocopy JTF_DATE_TABLE
    , p4_a31 out nocopy JTF_DATE_TABLE
    , p4_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a39 out nocopy JTF_NUMBER_TABLE
    , p4_a40 out nocopy JTF_NUMBER_TABLE
    , p4_a41 out nocopy JTF_VARCHAR2_TABLE_4000
    , p4_a42 out nocopy JTF_NUMBER_TABLE
    , p4_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_DATE_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_DATE_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 out nocopy JTF_DATE_TABLE
    , p5_a12 out nocopy JTF_DATE_TABLE
    , p5_a13 out nocopy JTF_DATE_TABLE
    , p5_a14 out nocopy JTF_DATE_TABLE
    , p5_a15 out nocopy JTF_DATE_TABLE
    , p5_a16 out nocopy JTF_DATE_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_NUMBER_TABLE
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_DATE_TABLE
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a23 out nocopy JTF_NUMBER_TABLE
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a25 out nocopy JTF_NUMBER_TABLE
    , p5_a26 out nocopy JTF_NUMBER_TABLE
    , p5_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 out nocopy JTF_NUMBER_TABLE
    , p5_a31 out nocopy JTF_DATE_TABLE
    , p5_a32 out nocopy JTF_DATE_TABLE
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 out nocopy JTF_NUMBER_TABLE
    , p5_a41 out nocopy JTF_NUMBER_TABLE
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a43 out nocopy JTF_NUMBER_TABLE
    , p5_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure create_ids(p_num_req  NUMBER
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_DATE_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p1_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p1_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a10 in out nocopy JTF_DATE_TABLE
    , p1_a11 in out nocopy JTF_DATE_TABLE
    , p1_a12 in out nocopy JTF_DATE_TABLE
    , p1_a13 in out nocopy JTF_DATE_TABLE
    , p1_a14 in out nocopy JTF_DATE_TABLE
    , p1_a15 in out nocopy JTF_DATE_TABLE
    , p1_a16 in out nocopy JTF_NUMBER_TABLE
    , p1_a17 in out nocopy JTF_NUMBER_TABLE
    , p1_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a19 in out nocopy JTF_DATE_TABLE
    , p1_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a22 in out nocopy JTF_NUMBER_TABLE
    , p1_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a24 in out nocopy JTF_NUMBER_TABLE
    , p1_a25 in out nocopy JTF_NUMBER_TABLE
    , p1_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a29 in out nocopy JTF_NUMBER_TABLE
    , p1_a30 in out nocopy JTF_DATE_TABLE
    , p1_a31 in out nocopy JTF_DATE_TABLE
    , p1_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a39 in out nocopy JTF_NUMBER_TABLE
    , p1_a40 in out nocopy JTF_NUMBER_TABLE
    , p1_a41 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p1_a42 in out nocopy JTF_NUMBER_TABLE
    , p1_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a44 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure update_data(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_DATE_TABLE
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_DATE_TABLE
    , p0_a11 in out nocopy JTF_DATE_TABLE
    , p0_a12 in out nocopy JTF_DATE_TABLE
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_DATE_TABLE
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_DATE_TABLE
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a22 in out nocopy JTF_NUMBER_TABLE
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a24 in out nocopy JTF_NUMBER_TABLE
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a29 in out nocopy JTF_NUMBER_TABLE
    , p0_a30 in out nocopy JTF_DATE_TABLE
    , p0_a31 in out nocopy JTF_DATE_TABLE
    , p0_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a39 in out nocopy JTF_NUMBER_TABLE
    , p0_a40 in out nocopy JTF_NUMBER_TABLE
    , p0_a41 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a42 in out nocopy JTF_NUMBER_TABLE
    , p0_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_DATE_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_NUMBER_TABLE
    , p1_a4 in out nocopy JTF_DATE_TABLE
    , p1_a5 in out nocopy JTF_NUMBER_TABLE
    , p1_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a8 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a9 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p1_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a11 in out nocopy JTF_DATE_TABLE
    , p1_a12 in out nocopy JTF_DATE_TABLE
    , p1_a13 in out nocopy JTF_DATE_TABLE
    , p1_a14 in out nocopy JTF_DATE_TABLE
    , p1_a15 in out nocopy JTF_DATE_TABLE
    , p1_a16 in out nocopy JTF_DATE_TABLE
    , p1_a17 in out nocopy JTF_NUMBER_TABLE
    , p1_a18 in out nocopy JTF_NUMBER_TABLE
    , p1_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a20 in out nocopy JTF_DATE_TABLE
    , p1_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a22 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a23 in out nocopy JTF_NUMBER_TABLE
    , p1_a24 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a25 in out nocopy JTF_NUMBER_TABLE
    , p1_a26 in out nocopy JTF_NUMBER_TABLE
    , p1_a27 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a28 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a30 in out nocopy JTF_NUMBER_TABLE
    , p1_a31 in out nocopy JTF_DATE_TABLE
    , p1_a32 in out nocopy JTF_DATE_TABLE
    , p1_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a40 in out nocopy JTF_NUMBER_TABLE
    , p1_a41 in out nocopy JTF_NUMBER_TABLE
    , p1_a42 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p1_a43 in out nocopy JTF_NUMBER_TABLE
    , p1_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a45 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure delete_data(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_DATE_TABLE
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_DATE_TABLE
    , p0_a11 in out nocopy JTF_DATE_TABLE
    , p0_a12 in out nocopy JTF_DATE_TABLE
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_DATE_TABLE
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_DATE_TABLE
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a22 in out nocopy JTF_NUMBER_TABLE
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a24 in out nocopy JTF_NUMBER_TABLE
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a29 in out nocopy JTF_NUMBER_TABLE
    , p0_a30 in out nocopy JTF_DATE_TABLE
    , p0_a31 in out nocopy JTF_DATE_TABLE
    , p0_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a39 in out nocopy JTF_NUMBER_TABLE
    , p0_a40 in out nocopy JTF_NUMBER_TABLE
    , p0_a41 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a42 in out nocopy JTF_NUMBER_TABLE
    , p0_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a44 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end cac_sync_task_w;

 

/
