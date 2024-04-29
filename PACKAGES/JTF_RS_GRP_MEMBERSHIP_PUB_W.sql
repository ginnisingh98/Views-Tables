--------------------------------------------------------
--  DDL for Package JTF_RS_GRP_MEMBERSHIP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GRP_MEMBERSHIP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrswms.pls 120.0 2005/05/11 08:23:27 appldev ship $ */
  procedure create_group_membership(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_id  NUMBER
    , p_role_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
  procedure update_group_membership(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id  NUMBER
    , p_role_relate_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , p_object_version_num  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
end jtf_rs_grp_membership_pub_w;

 

/
