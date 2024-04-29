--------------------------------------------------------
--  DDL for Package Body CN_ADD_TBH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ADD_TBH_PVT_W" as
  /* $Header: cnwatbhb.pls 115.4 2002/11/25 22:22:09 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_tbh(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_mgr_srp_id  NUMBER
    , p_name  VARCHAR2
    , p_emp_num  VARCHAR2
    , p_comp_group_id  NUMBER
    , p_start_date_active  date
    , p_end_date_active  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_srp_id out nocopy  NUMBER
  )

  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);





    -- here's the delegated call to the old PL/SQL routine
    cn_add_tbh_pvt.create_tbh(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_mgr_srp_id,
      p_name,
      p_emp_num,
      p_comp_group_id,
      ddp_start_date_active,
      ddp_end_date_active,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_srp_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

end cn_add_tbh_pvt_w;

/
