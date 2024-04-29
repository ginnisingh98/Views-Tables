--------------------------------------------------------
--  DDL for Package LNS_PARTICIPANTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_PARTICIPANTS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_PART_PUBJ_S.pls 120.4 2006/01/18 20:30 karamach noship $ */
  procedure validateparticipant(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure createparticipant(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , x_participant_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure updateparticipant(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_participants_pub_w;

 

/
