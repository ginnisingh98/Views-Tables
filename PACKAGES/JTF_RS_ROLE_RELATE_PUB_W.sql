--------------------------------------------------------
--  DDL for Package JTF_RS_ROLE_RELATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_ROLE_RELATE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsres.pls 120.0 2005/05/11 08:21:35 appldev noship $ */
  procedure create_resource_role_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_role_resource_type  VARCHAR2
    , p_role_resource_id  NUMBER
    , p_role_id  NUMBER
    , p_role_code  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_role_relate_id out NOCOPY  NUMBER
  );
  procedure update_resource_role_relate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_role_relate_id  NUMBER
    , p_start_date_active  date
    , p_end_date_active  date
    , p_object_version_num in out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
end jtf_rs_role_relate_pub_w;

 

/
