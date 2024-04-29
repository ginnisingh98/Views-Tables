--------------------------------------------------------
--  DDL for Package Body PV_PRGM_APPROVAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_APPROVAL_PVT_W" as
  /* $Header: pvxwpapb.pls 115.1 2003/11/01 00:49:08 pukken ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

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
  )

  as
    ddstart_date date;
    ddend_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddstart_date := rosetta_g_miss_date_in_map(start_date);

    ddend_date := rosetta_g_miss_date_in_map(end_date);




    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_approval_pvt.update_enrl_req_status(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      enrl_request_id,
      entity_code,
      approvalstatus,
      ddstart_date,
      ddend_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end pv_prgm_approval_pvt_w;

/
