--------------------------------------------------------
--  DDL for Package AMS_TRIGGER_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TRIGGER_PVT_OA" AUTHID CURRENT_USER as
/* $Header: amsatgrs.pls 120.0 2005/08/30 08:39:20 kbasavar noship $ */
  procedure create_trigger(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  DATE
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  DATE
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  DATE
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  DATE
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  NUMBER
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  DATE
    , p9_a4  NUMBER
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  NUMBER
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  NUMBER
    , p9_a14  VARCHAR2
    , p9_a15  NUMBER
    , p9_a16  NUMBER
    , p9_a17  VARCHAR2
    , p9_a18  NUMBER
    , p9_a19  NUMBER
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  NUMBER
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  NUMBER
    , x_trigger_check_id out nocopy  NUMBER
    , x_trigger_action_id out nocopy  NUMBER
    , x_trigger_id out nocopy  NUMBER
  );
  procedure update_trigger(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  DATE
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  DATE
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  DATE
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  DATE
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  NUMBER
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  DATE
    , p9_a4  NUMBER
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  NUMBER
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  NUMBER
    , p9_a14  VARCHAR2
    , p9_a15  NUMBER
    , p9_a16  NUMBER
    , p9_a17  VARCHAR2
    , p9_a18  NUMBER
    , p9_a19  NUMBER
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  NUMBER
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  NUMBER
  );

   FUNCTION get_ams_monitor_disable_delete(p_triggerId in NUMBER,p_start_date IN DATE) RETURN VARCHAR2;
end ams_trigger_pvt_oa;

 

/
