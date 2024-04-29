--------------------------------------------------------
--  DDL for Package JTS_CONFIG_VERSION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_VERSION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtswcvrs.pls 115.5 2002/03/27 18:03:15 pkm ship    $ */
  procedure rosetta_table_copy_in_p4(t out jts_config_version_pvt.config_version_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t jts_config_version_pvt.config_version_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_300
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_200
    , a7 out JTF_VARCHAR2_TABLE_200
    , a8 out JTF_VARCHAR2_TABLE_200
    , a9 out JTF_VARCHAR2_TABLE_200
    , a10 out JTF_VARCHAR2_TABLE_200
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_DATE_TABLE
    , a23 out JTF_NUMBER_TABLE
    , a24 out JTF_DATE_TABLE
    , a25 out JTF_NUMBER_TABLE
    , a26 out JTF_NUMBER_TABLE
    , a27 out JTF_VARCHAR2_TABLE_100
    , a28 out JTF_VARCHAR2_TABLE_100
    , a29 out JTF_VARCHAR2_TABLE_100
    , a30 out JTF_VARCHAR2_TABLE_300
    , a31 out JTF_NUMBER_TABLE
    , a32 out JTF_VARCHAR2_TABLE_100
    , a33 out JTF_VARCHAR2_TABLE_100
    , a34 out JTF_VARCHAR2_TABLE_100
    , a35 out JTF_VARCHAR2_TABLE_100
    , a36 out JTF_DATE_TABLE
    , a37 out JTF_VARCHAR2_TABLE_100
    , a38 out JTF_VARCHAR2_TABLE_100
    , a39 out JTF_VARCHAR2_TABLE_100
    , a40 out JTF_VARCHAR2_TABLE_100
    , a41 out JTF_VARCHAR2_TABLE_100
    , a42 out JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out jts_config_version_pvt.version_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t jts_config_version_pvt.version_id_tbl_type, a0 out JTF_NUMBER_TABLE);

  procedure delete_some_versions(p_api_version  NUMBER
    , p_version_tbl JTF_NUMBER_TABLE
  );
  procedure get_version(p_api_version  NUMBER
    , p_version_id  NUMBER
    , p2_a0 out  NUMBER
    , p2_a1 out  NUMBER
    , p2_a2 out  VARCHAR2
    , p2_a3 out  NUMBER
    , p2_a4 out  VARCHAR2
    , p2_a5 out  VARCHAR2
    , p2_a6 out  VARCHAR2
    , p2_a7 out  VARCHAR2
    , p2_a8 out  VARCHAR2
    , p2_a9 out  VARCHAR2
    , p2_a10 out  VARCHAR2
    , p2_a11 out  VARCHAR2
    , p2_a12 out  VARCHAR2
    , p2_a13 out  VARCHAR2
    , p2_a14 out  VARCHAR2
    , p2_a15 out  VARCHAR2
    , p2_a16 out  VARCHAR2
    , p2_a17 out  VARCHAR2
    , p2_a18 out  VARCHAR2
    , p2_a19 out  VARCHAR2
    , p2_a20 out  VARCHAR2
    , p2_a21 out  VARCHAR2
    , p2_a22 out  DATE
    , p2_a23 out  NUMBER
    , p2_a24 out  DATE
    , p2_a25 out  NUMBER
    , p2_a26 out  NUMBER
    , p2_a27 out  VARCHAR2
    , p2_a28 out  VARCHAR2
    , p2_a29 out  VARCHAR2
    , p2_a30 out  VARCHAR2
    , p2_a31 out  NUMBER
    , p2_a32 out  VARCHAR2
    , p2_a33 out  VARCHAR2
    , p2_a34 out  VARCHAR2
    , p2_a35 out  VARCHAR2
    , p2_a36 out  DATE
    , p2_a37 out  VARCHAR2
    , p2_a38 out  VARCHAR2
    , p2_a39 out  VARCHAR2
    , p2_a40 out  VARCHAR2
    , p2_a41 out  VARCHAR2
    , p2_a42 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure get_versions(p_api_version  NUMBER
    , p_config_id  NUMBER
    , p_order_by  VARCHAR2
    , p_how_to_order  VARCHAR2
    , p4_a0 out JTF_NUMBER_TABLE
    , p4_a1 out JTF_NUMBER_TABLE
    , p4_a2 out JTF_VARCHAR2_TABLE_100
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_VARCHAR2_TABLE_300
    , p4_a5 out JTF_VARCHAR2_TABLE_100
    , p4_a6 out JTF_VARCHAR2_TABLE_200
    , p4_a7 out JTF_VARCHAR2_TABLE_200
    , p4_a8 out JTF_VARCHAR2_TABLE_200
    , p4_a9 out JTF_VARCHAR2_TABLE_200
    , p4_a10 out JTF_VARCHAR2_TABLE_200
    , p4_a11 out JTF_VARCHAR2_TABLE_200
    , p4_a12 out JTF_VARCHAR2_TABLE_200
    , p4_a13 out JTF_VARCHAR2_TABLE_200
    , p4_a14 out JTF_VARCHAR2_TABLE_200
    , p4_a15 out JTF_VARCHAR2_TABLE_200
    , p4_a16 out JTF_VARCHAR2_TABLE_200
    , p4_a17 out JTF_VARCHAR2_TABLE_200
    , p4_a18 out JTF_VARCHAR2_TABLE_200
    , p4_a19 out JTF_VARCHAR2_TABLE_200
    , p4_a20 out JTF_VARCHAR2_TABLE_200
    , p4_a21 out JTF_VARCHAR2_TABLE_200
    , p4_a22 out JTF_DATE_TABLE
    , p4_a23 out JTF_NUMBER_TABLE
    , p4_a24 out JTF_DATE_TABLE
    , p4_a25 out JTF_NUMBER_TABLE
    , p4_a26 out JTF_NUMBER_TABLE
    , p4_a27 out JTF_VARCHAR2_TABLE_100
    , p4_a28 out JTF_VARCHAR2_TABLE_100
    , p4_a29 out JTF_VARCHAR2_TABLE_100
    , p4_a30 out JTF_VARCHAR2_TABLE_300
    , p4_a31 out JTF_NUMBER_TABLE
    , p4_a32 out JTF_VARCHAR2_TABLE_100
    , p4_a33 out JTF_VARCHAR2_TABLE_100
    , p4_a34 out JTF_VARCHAR2_TABLE_100
    , p4_a35 out JTF_VARCHAR2_TABLE_100
    , p4_a36 out JTF_DATE_TABLE
    , p4_a37 out JTF_VARCHAR2_TABLE_100
    , p4_a38 out JTF_VARCHAR2_TABLE_100
    , p4_a39 out JTF_VARCHAR2_TABLE_100
    , p4_a40 out JTF_VARCHAR2_TABLE_100
    , p4_a41 out JTF_VARCHAR2_TABLE_100
    , p4_a42 out JTF_NUMBER_TABLE
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
end jts_config_version_pvt_w;

 

/
