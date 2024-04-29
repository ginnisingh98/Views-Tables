--------------------------------------------------------
--  DDL for Package AHL_DI_DOC_REVISION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_DOC_REVISION_PUB_W" AUTHID CURRENT_USER as
  /* $Header: AHLREVWS.pls 120.0 2005/05/26 02:01:00 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_di_doc_revision_pub.revision_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_400
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_2000
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
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
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_di_doc_revision_pub.revision_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_400
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_revision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_only  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_DATE_TABLE
    , p5_a13 in out nocopy JTF_DATE_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_DATE_TABLE
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 in out nocopy JTF_NUMBER_TABLE
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure modify_revision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_only  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_DATE_TABLE
    , p5_a13 in out nocopy JTF_DATE_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_DATE_TABLE
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a21 in out nocopy JTF_NUMBER_TABLE
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_di_doc_revision_pub_w;

 

/
