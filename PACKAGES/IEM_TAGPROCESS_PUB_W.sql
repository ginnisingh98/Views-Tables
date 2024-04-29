--------------------------------------------------------
--  DDL for Package IEM_TAGPROCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TAGPROCESS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: IEMPTGWS.pls 115.2 2002/12/12 22:54:58 txliu noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy iem_tagprocess_pub.keyvals_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t iem_tagprocess_pub.keyvals_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure getencryptid(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_agent_id  NUMBER
    , p_interaction_id  NUMBER
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_300
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure gettagvalues(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_encrypted_id  VARCHAR2
    , p_message_id  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure gettagvalues_on_msgid(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_message_id  NUMBER
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure isvalidagent(p_agent_id  NUMBER
    , p_email_acct_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end iem_tagprocess_pub_w;

 

/
