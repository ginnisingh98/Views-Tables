--------------------------------------------------------
--  DDL for Package OZF_ACTFORECAST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTFORECAST_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwfcts.pls 120.2 2005/07/29 03:20:46 appldev ship $ */
  procedure create_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  DATE
    , p7_a59  DATE
    , p7_a60  VARCHAR2
    , x_forecast_id out nocopy  NUMBER
  );
  procedure update_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  DATE
    , p7_a59  DATE
    , p7_a60  VARCHAR2
  );
  procedure validate_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  NUMBER
    , p6_a21  DATE
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  NUMBER
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  DATE
    , p6_a59  DATE
    , p6_a60  VARCHAR2
  );
  procedure validate_actfcst_items(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_actfcst_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  VARCHAR2
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  DATE
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
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
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  NUMBER
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  DATE
    , p1_a59  DATE
    , p1_a60  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_actfcst_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  VARCHAR2
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  DATE
    , p1_a59 out nocopy  DATE
    , p1_a60 out nocopy  VARCHAR2
  );
  procedure init_actforecast_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  VARCHAR2
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  DATE
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  NUMBER
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  DATE
    , p0_a59 out nocopy  DATE
    , p0_a60 out nocopy  VARCHAR2
  );
end ozf_actforecast_pvt_w;

 

/
