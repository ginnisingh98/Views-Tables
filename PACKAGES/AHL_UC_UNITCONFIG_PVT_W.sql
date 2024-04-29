--------------------------------------------------------
--  DDL for Package AHL_UC_UNITCONFIG_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_UNITCONFIG_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLVUCWS.pls 120.0.12010000.2 2008/11/14 13:02:34 sathapli ship $ */
  procedure create_uc_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  DATE
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
  );
  procedure update_uc_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  DATE
    , p8_a11 in out nocopy  DATE
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  NUMBER
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  NUMBER
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  DATE
    , p9_a14  DATE
    , p9_a15  NUMBER
    , p9_a16  NUMBER
    , p9_a17  VARCHAR2
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  VARCHAR2
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  VARCHAR2
    , p9_a27  VARCHAR2
    , p9_a28  VARCHAR2
    , p9_a29  VARCHAR2
    , p9_a30  VARCHAR2
    , p9_a31  VARCHAR2
    , p9_a32  VARCHAR2
    , p9_a33  VARCHAR2
    , p9_a34  VARCHAR2
    , p9_a35  VARCHAR2
    , p9_a36  VARCHAR2
    , p9_a37  VARCHAR2
    , p9_a38  VARCHAR2
    , p9_a39  VARCHAR2
    , p9_a40  VARCHAR2
    , p9_a41  VARCHAR2
    , p9_a42  VARCHAR2
    , p9_a43  VARCHAR2
    , p9_a44  VARCHAR2
    , p9_a45  VARCHAR2
    , p9_a46  VARCHAR2
    , p9_a47  VARCHAR2
  );
end ahl_uc_unitconfig_pvt_w;

/
