--------------------------------------------------------
--  DDL for Package IEM_SERVER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SERVER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: IEMVSVRS.pls 120.0 2005/06/02 13:50:15 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_server_pub.emailsvr_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t iem_server_pub.emailsvr_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_emailserver_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_server_id  NUMBER
    , p_server_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
  );
end iem_server_pub_w;

 

/
