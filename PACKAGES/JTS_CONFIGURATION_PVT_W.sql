--------------------------------------------------------
--  DDL for Package JTS_CONFIGURATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIGURATION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtswcfgs.pls 115.4 2002/03/22 19:07:54 pkm ship    $ */
  procedure rosetta_table_copy_in_p5(t out jts_configuration_pvt.config_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
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
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t jts_configuration_pvt.config_rec_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_VARCHAR2_TABLE_100
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
    , a22 out JTF_VARCHAR2_TABLE_200
    , a23 out JTF_VARCHAR2_TABLE_200
    , a24 out JTF_VARCHAR2_TABLE_200
    , a25 out JTF_DATE_TABLE
    , a26 out JTF_NUMBER_TABLE
    , a27 out JTF_DATE_TABLE
    , a28 out JTF_NUMBER_TABLE
    , a29 out JTF_NUMBER_TABLE
    , a30 out JTF_VARCHAR2_TABLE_100
    , a31 out JTF_VARCHAR2_TABLE_100
    );

  procedure create_configuration(p_api_version  NUMBER
    , x_config_id out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  DATE := fnd_api.g_miss_date
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  DATE := fnd_api.g_miss_date
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_configuration(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_config_id  NUMBER
    , p3_a0 out  NUMBER
    , p3_a1 out  VARCHAR2
    , p3_a2 out  VARCHAR2
    , p3_a3 out  NUMBER
    , p3_a4 out  VARCHAR2
    , p3_a5 out  VARCHAR2
    , p3_a6 out  VARCHAR2
    , p3_a7 out  VARCHAR2
    , p3_a8 out  VARCHAR2
    , p3_a9 out  VARCHAR2
    , p3_a10 out  VARCHAR2
    , p3_a11 out  VARCHAR2
    , p3_a12 out  VARCHAR2
    , p3_a13 out  VARCHAR2
    , p3_a14 out  VARCHAR2
    , p3_a15 out  VARCHAR2
    , p3_a16 out  VARCHAR2
    , p3_a17 out  VARCHAR2
    , p3_a18 out  VARCHAR2
    , p3_a19 out  VARCHAR2
    , p3_a20 out  VARCHAR2
    , p3_a21 out  VARCHAR2
    , p3_a22 out  VARCHAR2
    , p3_a23 out  VARCHAR2
    , p3_a24 out  VARCHAR2
    , p3_a25 out  DATE
    , p3_a26 out  NUMBER
    , p3_a27 out  DATE
    , p3_a28 out  NUMBER
    , p3_a29 out  NUMBER
    , p3_a30 out  VARCHAR2
    , p3_a31 out  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure get_configurations(p_api_version  NUMBER
    , p_where_clause  VARCHAR2
    , p_order_by  VARCHAR2
    , p_how_to_order  VARCHAR2
    , p4_a0 out JTF_NUMBER_TABLE
    , p4_a1 out JTF_VARCHAR2_TABLE_100
    , p4_a2 out JTF_VARCHAR2_TABLE_300
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_VARCHAR2_TABLE_100
    , p4_a5 out JTF_VARCHAR2_TABLE_100
    , p4_a6 out JTF_VARCHAR2_TABLE_100
    , p4_a7 out JTF_VARCHAR2_TABLE_100
    , p4_a8 out JTF_VARCHAR2_TABLE_100
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
    , p4_a22 out JTF_VARCHAR2_TABLE_200
    , p4_a23 out JTF_VARCHAR2_TABLE_200
    , p4_a24 out JTF_VARCHAR2_TABLE_200
    , p4_a25 out JTF_DATE_TABLE
    , p4_a26 out JTF_NUMBER_TABLE
    , p4_a27 out JTF_DATE_TABLE
    , p4_a28 out JTF_NUMBER_TABLE
    , p4_a29 out JTF_NUMBER_TABLE
    , p4_a30 out JTF_VARCHAR2_TABLE_100
    , p4_a31 out JTF_VARCHAR2_TABLE_100
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
end jts_configuration_pvt_w;

 

/
