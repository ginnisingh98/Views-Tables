--------------------------------------------------------
--  DDL for Package AMS_LISTIMPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTIMPORT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswimls.pls 115.13 2002/11/12 23:44:38 jieli noship $ */
  procedure import_process(p_import_list_header_id  NUMBER
    , p_start_time  date
    , p_control_file  VARCHAR2
    , p_staged_only  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_generate_list  VARCHAR2
    , p_list_name  VARCHAR2
    , x_request_id OUT NOCOPY  NUMBER
  );
end ams_listimport_pvt_w;

 

/
