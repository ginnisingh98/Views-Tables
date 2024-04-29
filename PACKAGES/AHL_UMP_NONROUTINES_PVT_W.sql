--------------------------------------------------------
--  DDL for Package AHL_UMP_NONROUTINES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_NONROUTINES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWNRTS.pls 120.0.12010000.2 2010/03/24 10:31:02 ajprasan ship $ */
  procedure create_sr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  NUMBER
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  DATE
    , p9_a28 in out nocopy  DATE
    , p9_a29 in out nocopy  NUMBER
    , p9_a30 in out nocopy  NUMBER
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  NUMBER
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  NUMBER
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  NUMBER
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  NUMBER
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  NUMBER
    , p9_a45 in out nocopy  VARCHAR2
    , p9_a46 in out nocopy  NUMBER
    , p9_a47 in out nocopy  VARCHAR2
    , p9_a48 in out nocopy  VARCHAR2
    , p9_a49 in out nocopy  NUMBER
    , p9_a50 in out nocopy  VARCHAR2
    , p9_a51 in out nocopy  VARCHAR2
    , p9_a52 in out nocopy  VARCHAR2
    , p9_a53 in out nocopy  VARCHAR2
    , p9_a54 in out nocopy  VARCHAR2
    , p9_a55 in out nocopy  VARCHAR2
    , p9_a56 in out nocopy  VARCHAR2
    , p9_a57 in out nocopy  VARCHAR2
    , p9_a58 in out nocopy  VARCHAR2
    , p9_a59 in out nocopy  VARCHAR2
    , p9_a60 in out nocopy  VARCHAR2
    , p9_a61 in out nocopy  VARCHAR2
    , p9_a62 in out nocopy  VARCHAR2
    , p9_a63 in out nocopy  VARCHAR2
    , p9_a64 in out nocopy  VARCHAR2
    , p9_a65 in out nocopy  VARCHAR2
    , p9_a66 in out nocopy  VARCHAR2
  );
  procedure update_sr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  NUMBER
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  DATE
    , p9_a28 in out nocopy  DATE
    , p9_a29 in out nocopy  NUMBER
    , p9_a30 in out nocopy  NUMBER
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  NUMBER
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  NUMBER
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  NUMBER
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  NUMBER
    , p9_a43 in out nocopy  VARCHAR2
    , p9_a44 in out nocopy  NUMBER
    , p9_a45 in out nocopy  VARCHAR2
    , p9_a46 in out nocopy  NUMBER
    , p9_a47 in out nocopy  VARCHAR2
    , p9_a48 in out nocopy  VARCHAR2
    , p9_a49 in out nocopy  NUMBER
    , p9_a50 in out nocopy  VARCHAR2
    , p9_a51 in out nocopy  VARCHAR2
    , p9_a52 in out nocopy  VARCHAR2
    , p9_a53 in out nocopy  VARCHAR2
    , p9_a54 in out nocopy  VARCHAR2
    , p9_a55 in out nocopy  VARCHAR2
    , p9_a56 in out nocopy  VARCHAR2
    , p9_a57 in out nocopy  VARCHAR2
    , p9_a58 in out nocopy  VARCHAR2
    , p9_a59 in out nocopy  VARCHAR2
    , p9_a60 in out nocopy  VARCHAR2
    , p9_a61 in out nocopy  VARCHAR2
    , p9_a62 in out nocopy  VARCHAR2
    , p9_a63 in out nocopy  VARCHAR2
    , p9_a64 in out nocopy  VARCHAR2
    , p9_a65 in out nocopy  VARCHAR2
    , p9_a66 in out nocopy  VARCHAR2
  );
end ahl_ump_nonroutines_pvt_w;

/
