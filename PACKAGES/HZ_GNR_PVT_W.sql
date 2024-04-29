--------------------------------------------------------
--  DDL for Package HZ_GNR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ARHGNRWS.pls 120.4 2006/02/09 21:25:29 nsinghai noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy hz_gnr_pvt.geo_struct_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t hz_gnr_pvt.geo_struct_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy hz_gnr_pvt.geo_suggest_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p6(t hz_gnr_pvt.geo_suggest_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure search_geographies(p_table_name  VARCHAR2
    , p_address_style  VARCHAR2
    , p_address_usage  VARCHAR2
    , p_country_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_county  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_postal_plus4_code  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , x_mapped_struct_count out nocopy  NUMBER
    , x_records_count out nocopy  NUMBER
    , x_return_code out nocopy  NUMBER
    , x_validation_level out nocopy  VARCHAR2
    , p24_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a2 out nocopy JTF_NUMBER_TABLE
    , p24_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a6 out nocopy JTF_NUMBER_TABLE
    , p24_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a10 out nocopy JTF_NUMBER_TABLE
    , p24_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a13 out nocopy JTF_NUMBER_TABLE
    , p24_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a16 out nocopy JTF_NUMBER_TABLE
    , p24_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a19 out nocopy JTF_NUMBER_TABLE
    , p24_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a22 out nocopy JTF_NUMBER_TABLE
    , p24_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a25 out nocopy JTF_NUMBER_TABLE
    , p24_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a28 out nocopy JTF_NUMBER_TABLE
    , p24_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a31 out nocopy JTF_NUMBER_TABLE
    , p24_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a34 out nocopy JTF_NUMBER_TABLE
    , p24_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a37 out nocopy JTF_NUMBER_TABLE
    , p24_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a40 out nocopy JTF_NUMBER_TABLE
    , p24_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a43 out nocopy JTF_NUMBER_TABLE
    , p24_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a46 out nocopy JTF_NUMBER_TABLE
    , p24_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a49 out nocopy JTF_NUMBER_TABLE
    , p24_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a52 out nocopy JTF_NUMBER_TABLE
    , p24_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a54 out nocopy JTF_VARCHAR2_TABLE_4000
    , p25_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a3 out nocopy JTF_NUMBER_TABLE
    , p25_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p25_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p26_a0 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_gnr_pvt_w;

 

/
