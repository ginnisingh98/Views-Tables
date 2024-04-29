--------------------------------------------------------
--  DDL for Package PV_PRGM_APPROVAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_APPROVAL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwpaps.pls 115.1 2003/11/01 00:48:58 pukken ship $ */
  procedure update_enrl_req_status(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , enrl_request_id  NUMBER
    , entity_code  VARCHAR2
    , approvalstatus  VARCHAR2
    , start_date  date
    , end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end pv_prgm_approval_pvt_w;

 

/
