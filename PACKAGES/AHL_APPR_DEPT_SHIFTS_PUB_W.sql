--------------------------------------------------------
--  DDL for Package AHL_APPR_DEPT_SHIFTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_APPR_DEPT_SHIFTS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: AHLWDSHS.pls 120.1 2007/12/24 22:40:41 rbhavsar ship $ */
  procedure create_appr_dept_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  DATE
    , p9_a7 in out nocopy  NUMBER
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  NUMBER
    , p9_a15 in out nocopy  NUMBER
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  NUMBER
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
  );
  procedure delete_appr_dept_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  DATE
    , p9_a7 in out nocopy  NUMBER
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  NUMBER
    , p9_a14 in out nocopy  NUMBER
    , p9_a15 in out nocopy  NUMBER
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  NUMBER
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
  );
end ahl_appr_dept_shifts_pub_w;

/
