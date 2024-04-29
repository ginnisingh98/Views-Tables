--------------------------------------------------------
--  DDL for Package Body OZF_ALLOCATION_ENGINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ALLOCATION_ENGINE_PVT_W" as
  /* $Header: ozfwaegb.pls 115.1 2003/11/19 01:18:48 mkothari noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure allocate_target(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_number out nocopy  NUMBER
    , x_error_message out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_fund_id  NUMBER
    , p_old_start_date  date
    , p_new_end_date  date
    , p_addon_fact_id  NUMBER
    , p_addon_amount  NUMBER
  )

  as
    ddp_old_start_date date;
    ddp_new_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_old_start_date := rosetta_g_miss_date_in_map(p_old_start_date);

    ddp_new_end_date := rosetta_g_miss_date_in_map(p_new_end_date);



    -- here's the delegated call to the old PL/SQL routine
    ozf_allocation_engine_pvt.allocate_target(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_error_number,
      x_error_message,
      p_mode,
      p_fund_id,
      ddp_old_start_date,
      ddp_new_end_date,
      p_addon_fact_id,
      p_addon_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end ozf_allocation_engine_pvt_w;

/
