--------------------------------------------------------
--  DDL for Package OZF_ACTBUDGETS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTBUDGETS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwbdgs.pls 120.6.12010000.3 2010/02/18 08:53:48 nepanda ship $ */
  procedure create_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , x_act_budget_id out nocopy  NUMBER
  );
  procedure create_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  DATE
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  DATE
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  NUMBER
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , x_act_budget_id out nocopy  NUMBER
    , p_approval_flag  VARCHAR2
  );
  procedure create_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  DATE
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  DATE
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  NUMBER
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , x_act_budget_id out nocopy  NUMBER
    , p_approval_flag  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  );
  procedure create_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  DATE
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  DATE
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  NUMBER
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , x_act_budget_id out nocopy  NUMBER
    , p_approval_flag  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
    , x_utilization_id out nocopy  NUMBER
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p_parent_process_flag  VARCHAR2
    , p_parent_process_key  VARCHAR2
    , p_parent_context  VARCHAR2
    , p_parent_approval_flag  VARCHAR2
    , p_continue_flow  VARCHAR2
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p15_a0  VARCHAR2
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  NUMBER
    , p15_a5  VARCHAR2
    , p15_a6  NUMBER
    , p15_a7  NUMBER
    , p15_a8  NUMBER
    , p15_a9  VARCHAR2
    , p15_a10  DATE
    , p15_a11  DATE
    , p15_a12  NUMBER
    , p15_a13  NUMBER
    , p15_a14  NUMBER
    , p15_a15  NUMBER
    , p15_a16  NUMBER
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  NUMBER
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  NUMBER
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  DATE
    , p15_a30  VARCHAR2
    , p15_a31  VARCHAR2
    , p15_a32  NUMBER
    , p15_a33  NUMBER
    , p15_a34  VARCHAR2
    , p15_a35  NUMBER
    , p15_a36  NUMBER
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p_parent_process_flag  VARCHAR2
    , p_parent_process_key  VARCHAR2
    , p_parent_context  VARCHAR2
    , p_parent_approval_flag  VARCHAR2
    , p_continue_flow  VARCHAR2
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p15_a0  VARCHAR2
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  NUMBER
    , p15_a5  VARCHAR2
    , p15_a6  NUMBER
    , p15_a7  NUMBER
    , p15_a8  NUMBER
    , p15_a9  VARCHAR2
    , p15_a10  DATE
    , p15_a11  DATE
    , p15_a12  NUMBER
    , p15_a13  NUMBER
    , p15_a14  NUMBER
    , p15_a15  NUMBER
    , p15_a16  NUMBER
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  NUMBER
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  NUMBER
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  DATE
    , p15_a30  VARCHAR2
    , p15_a31  VARCHAR2
    , p15_a32  NUMBER
    , p15_a33  NUMBER
    , p15_a34  VARCHAR2
    , p15_a35  NUMBER
    , p15_a36  NUMBER
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  NUMBER
    , p10_a5  VARCHAR2
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  NUMBER
    , p10_a9  VARCHAR2
    , p10_a10  DATE
    , p10_a11  DATE
    , p10_a12  NUMBER
    , p10_a13  NUMBER
    , p10_a14  NUMBER
    , p10_a15  NUMBER
    , p10_a16  NUMBER
    , p10_a17  NUMBER
    , p10_a18  VARCHAR2
    , p10_a19  NUMBER
    , p10_a20  NUMBER
    , p10_a21  NUMBER
    , p10_a22  NUMBER
    , p10_a23  VARCHAR2
    , p10_a24  NUMBER
    , p10_a25  NUMBER
    , p10_a26  NUMBER
    , p10_a27  NUMBER
    , p10_a28  NUMBER
    , p10_a29  DATE
    , p10_a30  VARCHAR2
    , p10_a31  VARCHAR2
    , p10_a32  NUMBER
    , p10_a33  NUMBER
    , p10_a34  VARCHAR2
    , p10_a35  NUMBER
    , p10_a36  NUMBER
    , p10_a37  VARCHAR2
    , p10_a38  VARCHAR2
    , p10_a39  VARCHAR2
    , p10_a40  VARCHAR2
    , p10_a41  VARCHAR2
    , p10_a42  VARCHAR2
    , p10_a43  VARCHAR2
    , p10_a44  VARCHAR2
    , p10_a45  VARCHAR2
    , p10_a46  VARCHAR2
    , p10_a47  VARCHAR2
    , p10_a48  VARCHAR2
    , p10_a49  VARCHAR2
    , p10_a50  VARCHAR2
    , p10_a51  VARCHAR2
    , p10_a52  VARCHAR2
    , p10_a53  VARCHAR2
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  NUMBER
    , p10_a5  VARCHAR2
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  NUMBER
    , p10_a9  VARCHAR2
    , p10_a10  DATE
    , p10_a11  DATE
    , p10_a12  NUMBER
    , p10_a13  NUMBER
    , p10_a14  NUMBER
    , p10_a15  NUMBER
    , p10_a16  NUMBER
    , p10_a17  NUMBER
    , p10_a18  VARCHAR2
    , p10_a19  NUMBER
    , p10_a20  NUMBER
    , p10_a21  NUMBER
    , p10_a22  NUMBER
    , p10_a23  VARCHAR2
    , p10_a24  NUMBER
    , p10_a25  NUMBER
    , p10_a26  NUMBER
    , p10_a27  NUMBER
    , p10_a28  NUMBER
    , p10_a29  DATE
    , p10_a30  VARCHAR2
    , p10_a31  VARCHAR2
    , p10_a32  NUMBER
    , p10_a33  NUMBER
    , p10_a34  VARCHAR2
    , p10_a35  NUMBER
    , p10_a36  NUMBER
    , p10_a37  VARCHAR2
    , p10_a38  VARCHAR2
    , p10_a39  VARCHAR2
    , p10_a40  VARCHAR2
    , p10_a41  VARCHAR2
    , p10_a42  VARCHAR2
    , p10_a43  VARCHAR2
    , p10_a44  VARCHAR2
    , p10_a45  VARCHAR2
    , p10_a46  VARCHAR2
    , p10_a47  VARCHAR2
    , p10_a48  VARCHAR2
    , p10_a49  VARCHAR2
    , p10_a50  VARCHAR2
    , p10_a51  VARCHAR2
    , p10_a52  VARCHAR2
    , p10_a53  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  );
  procedure update_act_budgets(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p_parent_process_flag  VARCHAR2
    , p_parent_process_key  VARCHAR2
    , p_parent_context  VARCHAR2
    , p_parent_approval_flag  VARCHAR2
    , p_continue_flow  VARCHAR2
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p15_a0  VARCHAR2
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  NUMBER
    , p15_a5  VARCHAR2
    , p15_a6  NUMBER
    , p15_a7  NUMBER
    , p15_a8  NUMBER
    , p15_a9  VARCHAR2
    , p15_a10  DATE
    , p15_a11  DATE
    , p15_a12  NUMBER
    , p15_a13  NUMBER
    , p15_a14  NUMBER
    , p15_a15  NUMBER
    , p15_a16  NUMBER
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  NUMBER
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  NUMBER
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  DATE
    , p15_a30  VARCHAR2
    , p15_a31  VARCHAR2
    , p15_a32  NUMBER
    , p15_a33  NUMBER
    , p15_a34  VARCHAR2
    , p15_a35  NUMBER
    , p15_a36  NUMBER
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
    , x_utilization_id out nocopy  NUMBER
  );
  procedure validate_act_budgets(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  DATE
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR
    , p6_a29  VARCHAR
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  NUMBER
    , p6_a35  DATE
    , p6_a36  NUMBER
    , p6_a37  VARCHAR2
    , p6_a38  NUMBER
    , p6_a39  VARCHAR2
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  NUMBER
    , p6_a43  VARCHAR2
    , p6_a44  DATE
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  NUMBER
  );
  procedure validate_act_budgets_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_act_budgets_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_act_budgets_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  DATE
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR
    , p1_a29 out nocopy  VARCHAR
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  DATE
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  DATE
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  NUMBER
  );
  procedure init_act_budgets_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  DATE
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR
    , p0_a29 out nocopy  VARCHAR
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  DATE
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  DATE
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  VARCHAR2
    , p0_a61 out nocopy  NUMBER
  );
  procedure create_child_act_budget(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  DATE
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  NUMBER
    , p3_a11  VARCHAR2
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  DATE
    , p3_a15  NUMBER
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , p3_a18  NUMBER
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  NUMBER
    , p3_a22  NUMBER
    , p3_a23  VARCHAR2
    , p3_a24  DATE
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR
    , p3_a29  VARCHAR
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  NUMBER
    , p3_a35  DATE
    , p3_a36  NUMBER
    , p3_a37  VARCHAR2
    , p3_a38  NUMBER
    , p3_a39  VARCHAR2
    , p3_a40  NUMBER
    , p3_a41  NUMBER
    , p3_a42  NUMBER
    , p3_a43  VARCHAR2
    , p3_a44  DATE
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  NUMBER
    , p_exchange_rate_type  VARCHAR2
  );
end ozf_actbudgets_pvt_w;

/
