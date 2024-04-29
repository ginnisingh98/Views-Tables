--------------------------------------------------------
--  DDL for Package JTF_CAL_ADDR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_ADDR_PVT_W" AUTHID CURRENT_USER AS
/* $Header: jtfwcas.pls 115.2 2002/04/09 10:57:49 pkm ship      $ */
  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  DATE
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , x_address_id out  NUMBER
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  DATE
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , x_object_version_number out  NUMBER
  );
end jtf_cal_addr_pvt_w;

 

/
