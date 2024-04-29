--------------------------------------------------------
--  DDL for Package FND_UPDATE_USER_PREF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_UPDATE_USER_PREF_PUB_W" AUTHID CURRENT_USER as
  /* $Header: fndpirrs.pls 120.1 2005/07/02 03:35:21 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy fnd_update_user_pref_pub.preference_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t fnd_update_user_pref_pub.preference_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure set_purpose_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_user_id  NUMBER
    , p_party_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end fnd_update_user_pref_pub_w;

 

/
