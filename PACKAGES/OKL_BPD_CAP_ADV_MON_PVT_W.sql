--------------------------------------------------------
--  DDL for Package OKL_BPD_CAP_ADV_MON_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CAP_ADV_MON_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEAMSS.pls 120.2 2007/08/02 08:39:54 dcshanmu ship $ */
  procedure handle_advanced_manual_pay(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_bpd_cap_adv_mon_pvt_w;

/
