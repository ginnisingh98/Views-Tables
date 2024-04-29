--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_UTL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_UTL_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsrls.pls 120.0 2005/05/11 08:21:39 appldev ship $ */
  procedure end_date_employee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_end_date_active  date
    , x_object_ver_number in out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
end jtf_rs_resource_utl_pub_w;

 

/
