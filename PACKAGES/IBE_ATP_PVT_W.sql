--------------------------------------------------------
--  DDL for Package IBE_ATP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ATP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: IBEVATWS.pls 115.8 2003/08/29 09:09:06 nsultan ship $ */
  procedure rosetta_table_copy_in_p1(t out NOCOPY ibe_atp_pvt.atp_line_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t ibe_atp_pvt.atp_line_tbl_typ, a0 out NOCOPY JTF_NUMBER_TABLE
    , a1 out NOCOPY JTF_NUMBER_TABLE
    , a2 out NOCOPY JTF_NUMBER_TABLE
    , a3 out NOCOPY JTF_NUMBER_TABLE
    , a4 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY JTF_NUMBER_TABLE
    , a6 out NOCOPY JTF_NUMBER_TABLE
    , a7 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY JTF_NUMBER_TABLE
    , a10 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 out NOCOPY JTF_NUMBER_TABLE
    , a12 out NOCOPY JTF_VARCHAR2_TABLE_2000
    );

  procedure check_availability(p_quote_header_id  NUMBER
    , p_date_format  VARCHAR2
    , p_lang_code  VARCHAR2
    , x_error_flag out NOCOPY VARCHAR2
    , x_error_message out NOCOPY VARCHAR2
    , p5_a0 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a1 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a2 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a3 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a4 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a5 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a6 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a7 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a8 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a9 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a10 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a11 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a12 in out NOCOPY JTF_VARCHAR2_TABLE_2000
  );
end ibe_atp_pvt_w;

 

/
