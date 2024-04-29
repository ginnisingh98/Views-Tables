--------------------------------------------------------
--  DDL for Package AMS_DIALOG_REGS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DIALOG_REGS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: amswders.pls 120.5 2006/08/16 05:23:34 rrajesh noship $ */
  procedure register(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  DATE
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  DATE
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  NUMBER
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  NUMBER
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  DATE
    , p7_a104  DATE
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  NUMBER
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  VARCHAR2
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  DATE
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  NUMBER
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  VARCHAR2
    , p7_a152  VARCHAR2
    , p7_a153  NUMBER
    , p7_a154  NUMBER
    , p7_a155  NUMBER
    , p7_a156  NUMBER
    , p7_a157  VARCHAR2
    , p7_a158  VARCHAR2
    , p7_a159  VARCHAR2
    , p7_a160  VARCHAR2
    , p_block_fulfillment  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_application_id  NUMBER
    , x_confirm_code out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_system_status_code out nocopy  VARCHAR2
    , p7_a161  VARCHAR2
  );
end ams_dialog_regs_pub_w;

 

/
