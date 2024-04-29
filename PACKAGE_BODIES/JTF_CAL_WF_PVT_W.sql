--------------------------------------------------------
--  DDL for Package Body JTF_CAL_WF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_WF_PVT_W" as
  /* $Header: jtfwcwb.pls 120.2 2006/04/28 01:47 deeprao ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure startreminders(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_invitor  NUMBER
    , p_taskid  NUMBER
    , p_reminddate  date
  )

  as
    ddp_reminddate date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_reminddate := rosetta_g_miss_date_in_map(p_reminddate);

    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_wf_pvt.startreminders(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_invitor,
      p_taskid,
      ddp_reminddate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure updatereminders(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_taskid  NUMBER
    , p_reminddate  date
  )

  as
    ddp_reminddate date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_reminddate := rosetta_g_miss_date_in_map(p_reminddate);

    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_wf_pvt.updatereminders(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_taskid,
      ddp_reminddate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end jtf_cal_wf_pvt_w;

/
