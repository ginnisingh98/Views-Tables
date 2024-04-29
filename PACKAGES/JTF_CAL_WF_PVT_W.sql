--------------------------------------------------------
--  DDL for Package JTF_CAL_WF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_WF_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtfwcws.pls 120.2 2006/04/28 01:46 deeprao ship $ */
  procedure startreminders(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_invitor  NUMBER
    , p_taskid  NUMBER
    , p_reminddate  date
  );
  procedure updatereminders(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_taskid  NUMBER
    , p_reminddate  date
  );
end jtf_cal_wf_pvt_w;

 

/
