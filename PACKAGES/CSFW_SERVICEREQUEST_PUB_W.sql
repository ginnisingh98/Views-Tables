--------------------------------------------------------
--  DDL for Package CSFW_SERVICEREQUEST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_SERVICEREQUEST_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csfwvsrs.pls 120.1.12010000.2 2009/07/29 12:06:37 syenduri ship $ */
  procedure update_request_resolution(p_incident_id  NUMBER
    , p_resolution_code  VARCHAR2
    , p_resolution_summary  VARCHAR2
    , p_problem_code  VARCHAR2
    , p_cust_po_number  VARCHAR2
    , p_commit  number
    , p_init_msg_list  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  INTEGER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_version_number  NUMBER
    , p_incident_severity_id   NUMBER default null -- For enhancement in FSTP 12.1.3 Project
  );
end csfw_servicerequest_pub_w;

/
