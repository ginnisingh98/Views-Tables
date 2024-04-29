--------------------------------------------------------
--  DDL for Package Body CSFW_SERVICEREQUEST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_SERVICEREQUEST_PUB_W" as
  /* $Header: csfwvsrb.pls 120.2.12010000.2 2009/07/29 12:04:19 syenduri ship $ */
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
  )

  as
    ddp_commit boolean;
    ddp_init_msg_list boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    if p_commit is null
      then ddp_commit := null;
    elsif p_commit = 0
      then ddp_commit := false;
    else ddp_commit := true;
    end if;

    if p_init_msg_list is null
      then ddp_init_msg_list := null;
    elsif p_init_msg_list = 0
      then ddp_init_msg_list := false;
    else ddp_init_msg_list := true;
    end if;





    -- here's the delegated call to the old PL/SQL routine
    csfw_servicerequest_pub.update_request_resolution(p_incident_id,
      p_resolution_code,
      p_resolution_summary,
      p_problem_code,
      p_cust_po_number,
      ddp_commit,
      ddp_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_object_version_number,
      p_incident_severity_id );

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end csfw_servicerequest_pub_w;

/
