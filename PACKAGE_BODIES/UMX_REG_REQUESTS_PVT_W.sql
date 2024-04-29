--------------------------------------------------------
--  DDL for Package Body UMX_REG_REQUESTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REG_REQUESTS_PVT_W" as
  /* $Header: UMXRGRWB.pls 115.5 2004/07/09 20:31:03 kching noship $ */
  procedure is_username_available(p_username  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := umx_reg_requests_pvt.is_username_available(p_username);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure update_reg_request(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  VARCHAR2
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
  )

  as
    ddp_reg_request umx_reg_requests_pvt.reg_request_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_reg_request.reg_request_id := p0_a0;
    ddp_reg_request.reg_service_type := p0_a1;
    ddp_reg_request.status_code := p0_a2;
    ddp_reg_request.requested_by_userid := p0_a3;
    ddp_reg_request.requested_for_user_id := p0_a4;
    ddp_reg_request.requested_for_party_id := p0_a5;
    ddp_reg_request.requested_username := p0_a6;
    ddp_reg_request.requested_start_date := p0_a7;
    ddp_reg_request.requested_end_date := p0_a8;
    ddp_reg_request.wf_role_name := p0_a9;
    ddp_reg_request.reg_service_code := p0_a10;
    ddp_reg_request.ame_application_id := p0_a11;
    ddp_reg_request.ame_transaction_type_id := p0_a12;
    ddp_reg_request.justification := p0_a13;
    ddp_reg_request.wf_event_name := p0_a14;
    ddp_reg_request.email_verification_flag := p0_a15;

    -- here's the delegated call to the old PL/SQL routine
    umx_reg_requests_pvt.update_reg_request(ddp_reg_request);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_reg_request.reg_request_id;
    p0_a1 := ddp_reg_request.reg_service_type;
    p0_a2 := ddp_reg_request.status_code;
    p0_a3 := ddp_reg_request.requested_by_userid;
    p0_a4 := ddp_reg_request.requested_for_user_id;
    p0_a5 := ddp_reg_request.requested_for_party_id;
    p0_a6 := ddp_reg_request.requested_username;
    p0_a7 := ddp_reg_request.requested_start_date;
    p0_a8 := ddp_reg_request.requested_end_date;
    p0_a9 := ddp_reg_request.wf_role_name;
    p0_a10 := ddp_reg_request.reg_service_code;
    p0_a11 := ddp_reg_request.ame_application_id;
    p0_a12 := ddp_reg_request.ame_transaction_type_id;
    p0_a13 := ddp_reg_request.justification;
    p0_a14 := ddp_reg_request.wf_event_name;
    p0_a15 := ddp_reg_request.email_verification_flag;
  end;

end umx_reg_requests_pvt_w;

/
