--------------------------------------------------------
--  DDL for Package JTA_SYNC_TASK_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_TASK_W" AUTHID CURRENT_USER as
  /* $Header: jtavstws.pls 120.2 2006/04/27 01:09 deeprao ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy jta_sync_task.task_tbl, a0 JTF_NUMBER_TABLE
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
    );
  procedure rosetta_table_copy_out_p3(t jta_sync_task.task_tbl, a0 out nocopy JTF_NUMBER_TABLE
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
    );

  procedure rosetta_table_copy_in_p4(t out nocopy jta_sync_task.exclusion_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p4(t jta_sync_task.exclusion_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    );

  procedure get_count(p_request_type  VARCHAR2
    , p_syncanchor  date
    , x_total out nocopy  NUMBER
    , x_totalnew out nocopy  NUMBER
    , x_totalmodified out nocopy  NUMBER
    , x_totaldeleted out nocopy  NUMBER
  );
  procedure get_list(p_request_type  VARCHAR2
    , p_syncanchor  date
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_DATE_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p2_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a10 out nocopy JTF_DATE_TABLE
    , p2_a11 out nocopy JTF_DATE_TABLE
    , p2_a12 out nocopy JTF_DATE_TABLE
    , p2_a13 out nocopy JTF_DATE_TABLE
    , p2_a14 out nocopy JTF_DATE_TABLE
    , p2_a15 out nocopy JTF_DATE_TABLE
    , p2_a16 out nocopy JTF_NUMBER_TABLE
    , p2_a17 out nocopy JTF_NUMBER_TABLE
    , p2_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a19 out nocopy JTF_DATE_TABLE
    , p2_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a22 out nocopy JTF_NUMBER_TABLE
    , p2_a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a24 out nocopy JTF_NUMBER_TABLE
    , p2_a25 out nocopy JTF_NUMBER_TABLE
    , p2_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a29 out nocopy JTF_NUMBER_TABLE
    , p2_a30 out nocopy JTF_DATE_TABLE
    , p2_a31 out nocopy JTF_DATE_TABLE
    , p2_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a39 out nocopy JTF_NUMBER_TABLE
    , p2_a40 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
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
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
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
  );
end jta_sync_task_w;

 

/
