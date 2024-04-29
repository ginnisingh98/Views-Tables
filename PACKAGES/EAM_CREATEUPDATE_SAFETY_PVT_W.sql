--------------------------------------------------------
--  DDL for Package EAM_CREATEUPDATE_SAFETY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CREATEUPDATE_SAFETY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: EAMVWPCS.pls 120.0.12010000.2 2010/03/23 00:36:09 mashah noship $ */

  procedure create_update_permit(p_commit  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  NUMBER
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  DATE
    , p1_a12  VARCHAR2
    , p1_a13  DATE
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  DATE
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_300
    , p2_a10 JTF_VARCHAR2_TABLE_300
    , p2_a11 JTF_VARCHAR2_TABLE_300
    , p2_a12 JTF_VARCHAR2_TABLE_300
    , p2_a13 JTF_VARCHAR2_TABLE_300
    , p2_a14 JTF_VARCHAR2_TABLE_300
    , p2_a15 JTF_VARCHAR2_TABLE_300
    , p2_a16 JTF_VARCHAR2_TABLE_300
    , p2_a17 JTF_VARCHAR2_TABLE_300
    , p2_a18 JTF_VARCHAR2_TABLE_300
    , p2_a19 JTF_VARCHAR2_TABLE_300
    , p2_a20 JTF_VARCHAR2_TABLE_300
    , p2_a21 JTF_VARCHAR2_TABLE_300
    , p2_a22 JTF_VARCHAR2_TABLE_300
    , p2_a23 JTF_VARCHAR2_TABLE_300
    , p2_a24 JTF_VARCHAR2_TABLE_300
    , p2_a25 JTF_VARCHAR2_TABLE_300
    , p2_a26 JTF_VARCHAR2_TABLE_300
    , p2_a27 JTF_VARCHAR2_TABLE_300
    , p2_a28 JTF_VARCHAR2_TABLE_300
    , p2_a29 JTF_VARCHAR2_TABLE_300
    , p2_a30 JTF_VARCHAR2_TABLE_300
    , p2_a31 JTF_VARCHAR2_TABLE_300
    , p2_a32 JTF_VARCHAR2_TABLE_300
    , p2_a33 JTF_VARCHAR2_TABLE_300
    , p2_a34 JTF_VARCHAR2_TABLE_300
    , p2_a35 JTF_VARCHAR2_TABLE_300
    , p2_a36 JTF_VARCHAR2_TABLE_300
    , p2_a37 JTF_VARCHAR2_TABLE_300
    , p2_a38 JTF_VARCHAR2_TABLE_300
    , p2_a39 JTF_NUMBER_TABLE
    , p2_a40 JTF_DATE_TABLE
    , x_permit_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  );
end eam_createupdate_safety_pvt_w;


/
