--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_RELATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_RELATE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsrrs.pls 120.0 2005/05/11 08:21:46 appldev ship $ */
  procedure create_resource_group_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_id  NUMBER
    , p_group_number  VARCHAR2
    , p_related_group_id  NUMBER
    , p_related_group_number  VARCHAR2
    , p_relation_type  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_group_relate_id out NOCOPY  NUMBER
  );
  procedure update_resource_group_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_relate_id  NUMBER
    , p_start_date_active  date
    , p_end_date_active  date
    , p_object_version_num in out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
end jtf_rs_group_relate_pub_w;

 

/
