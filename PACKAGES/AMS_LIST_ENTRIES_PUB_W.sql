--------------------------------------------------------
--  DDL for Package AMS_LIST_ENTRIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_ENTRIES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: amszlies.pls 115.6 2002/11/22 08:58:17 jieli ship $ */
  procedure create_list_entries(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_entry_id OUT NOCOPY  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  NUMBER := 0-1962.0724
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  VARCHAR2 := fnd_api.g_miss_char
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  VARCHAR2 := fnd_api.g_miss_char
    , p6_a100  VARCHAR2 := fnd_api.g_miss_char
    , p6_a101  VARCHAR2 := fnd_api.g_miss_char
    , p6_a102  VARCHAR2 := fnd_api.g_miss_char
    , p6_a103  VARCHAR2 := fnd_api.g_miss_char
    , p6_a104  VARCHAR2 := fnd_api.g_miss_char
    , p6_a105  VARCHAR2 := fnd_api.g_miss_char
    , p6_a106  VARCHAR2 := fnd_api.g_miss_char
    , p6_a107  VARCHAR2 := fnd_api.g_miss_char
    , p6_a108  VARCHAR2 := fnd_api.g_miss_char
    , p6_a109  VARCHAR2 := fnd_api.g_miss_char
    , p6_a110  VARCHAR2 := fnd_api.g_miss_char
    , p6_a111  VARCHAR2 := fnd_api.g_miss_char
    , p6_a112  VARCHAR2 := fnd_api.g_miss_char
    , p6_a113  VARCHAR2 := fnd_api.g_miss_char
    , p6_a114  VARCHAR2 := fnd_api.g_miss_char
    , p6_a115  VARCHAR2 := fnd_api.g_miss_char
    , p6_a116  VARCHAR2 := fnd_api.g_miss_char
    , p6_a117  VARCHAR2 := fnd_api.g_miss_char
    , p6_a118  VARCHAR2 := fnd_api.g_miss_char
    , p6_a119  VARCHAR2 := fnd_api.g_miss_char
    , p6_a120  VARCHAR2 := fnd_api.g_miss_char
    , p6_a121  VARCHAR2 := fnd_api.g_miss_char
    , p6_a122  VARCHAR2 := fnd_api.g_miss_char
    , p6_a123  VARCHAR2 := fnd_api.g_miss_char
    , p6_a124  VARCHAR2 := fnd_api.g_miss_char
    , p6_a125  VARCHAR2 := fnd_api.g_miss_char
    , p6_a126  VARCHAR2 := fnd_api.g_miss_char
    , p6_a127  VARCHAR2 := fnd_api.g_miss_char
    , p6_a128  VARCHAR2 := fnd_api.g_miss_char
    , p6_a129  VARCHAR2 := fnd_api.g_miss_char
    , p6_a130  VARCHAR2 := fnd_api.g_miss_char
    , p6_a131  VARCHAR2 := fnd_api.g_miss_char
    , p6_a132  VARCHAR2 := fnd_api.g_miss_char
    , p6_a133  VARCHAR2 := fnd_api.g_miss_char
    , p6_a134  VARCHAR2 := fnd_api.g_miss_char
    , p6_a135  VARCHAR2 := fnd_api.g_miss_char
    , p6_a136  VARCHAR2 := fnd_api.g_miss_char
    , p6_a137  VARCHAR2 := fnd_api.g_miss_char
    , p6_a138  VARCHAR2 := fnd_api.g_miss_char
    , p6_a139  VARCHAR2 := fnd_api.g_miss_char
    , p6_a140  VARCHAR2 := fnd_api.g_miss_char
    , p6_a141  VARCHAR2 := fnd_api.g_miss_char
    , p6_a142  VARCHAR2 := fnd_api.g_miss_char
    , p6_a143  VARCHAR2 := fnd_api.g_miss_char
    , p6_a144  VARCHAR2 := fnd_api.g_miss_char
    , p6_a145  VARCHAR2 := fnd_api.g_miss_char
    , p6_a146  VARCHAR2 := fnd_api.g_miss_char
    , p6_a147  VARCHAR2 := fnd_api.g_miss_char
    , p6_a148  VARCHAR2 := fnd_api.g_miss_char
    , p6_a149  VARCHAR2 := fnd_api.g_miss_char
    , p6_a150  VARCHAR2 := fnd_api.g_miss_char
    , p6_a151  VARCHAR2 := fnd_api.g_miss_char
    , p6_a152  VARCHAR2 := fnd_api.g_miss_char
    , p6_a153  VARCHAR2 := fnd_api.g_miss_char
    , p6_a154  VARCHAR2 := fnd_api.g_miss_char
    , p6_a155  VARCHAR2 := fnd_api.g_miss_char
    , p6_a156  VARCHAR2 := fnd_api.g_miss_char
    , p6_a157  VARCHAR2 := fnd_api.g_miss_char
    , p6_a158  VARCHAR2 := fnd_api.g_miss_char
    , p6_a159  VARCHAR2 := fnd_api.g_miss_char
    , p6_a160  VARCHAR2 := fnd_api.g_miss_char
    , p6_a161  VARCHAR2 := fnd_api.g_miss_char
    , p6_a162  VARCHAR2 := fnd_api.g_miss_char
    , p6_a163  VARCHAR2 := fnd_api.g_miss_char
    , p6_a164  VARCHAR2 := fnd_api.g_miss_char
    , p6_a165  VARCHAR2 := fnd_api.g_miss_char
    , p6_a166  VARCHAR2 := fnd_api.g_miss_char
    , p6_a167  VARCHAR2 := fnd_api.g_miss_char
    , p6_a168  VARCHAR2 := fnd_api.g_miss_char
    , p6_a169  VARCHAR2 := fnd_api.g_miss_char
    , p6_a170  VARCHAR2 := fnd_api.g_miss_char
    , p6_a171  VARCHAR2 := fnd_api.g_miss_char
    , p6_a172  VARCHAR2 := fnd_api.g_miss_char
    , p6_a173  VARCHAR2 := fnd_api.g_miss_char
    , p6_a174  VARCHAR2 := fnd_api.g_miss_char
    , p6_a175  VARCHAR2 := fnd_api.g_miss_char
    , p6_a176  VARCHAR2 := fnd_api.g_miss_char
    , p6_a177  VARCHAR2 := fnd_api.g_miss_char
    , p6_a178  VARCHAR2 := fnd_api.g_miss_char
    , p6_a179  VARCHAR2 := fnd_api.g_miss_char
    , p6_a180  VARCHAR2 := fnd_api.g_miss_char
    , p6_a181  VARCHAR2 := fnd_api.g_miss_char
    , p6_a182  VARCHAR2 := fnd_api.g_miss_char
    , p6_a183  VARCHAR2 := fnd_api.g_miss_char
    , p6_a184  VARCHAR2 := fnd_api.g_miss_char
    , p6_a185  VARCHAR2 := fnd_api.g_miss_char
    , p6_a186  VARCHAR2 := fnd_api.g_miss_char
    , p6_a187  VARCHAR2 := fnd_api.g_miss_char
    , p6_a188  VARCHAR2 := fnd_api.g_miss_char
    , p6_a189  VARCHAR2 := fnd_api.g_miss_char
    , p6_a190  VARCHAR2 := fnd_api.g_miss_char
    , p6_a191  VARCHAR2 := fnd_api.g_miss_char
    , p6_a192  VARCHAR2 := fnd_api.g_miss_char
    , p6_a193  VARCHAR2 := fnd_api.g_miss_char
    , p6_a194  VARCHAR2 := fnd_api.g_miss_char
    , p6_a195  VARCHAR2 := fnd_api.g_miss_char
    , p6_a196  VARCHAR2 := fnd_api.g_miss_char
    , p6_a197  VARCHAR2 := fnd_api.g_miss_char
    , p6_a198  VARCHAR2 := fnd_api.g_miss_char
    , p6_a199  VARCHAR2 := fnd_api.g_miss_char
    , p6_a200  VARCHAR2 := fnd_api.g_miss_char
    , p6_a201  VARCHAR2 := fnd_api.g_miss_char
    , p6_a202  VARCHAR2 := fnd_api.g_miss_char
    , p6_a203  VARCHAR2 := fnd_api.g_miss_char
    , p6_a204  VARCHAR2 := fnd_api.g_miss_char
    , p6_a205  VARCHAR2 := fnd_api.g_miss_char
    , p6_a206  VARCHAR2 := fnd_api.g_miss_char
    , p6_a207  VARCHAR2 := fnd_api.g_miss_char
    , p6_a208  VARCHAR2 := fnd_api.g_miss_char
    , p6_a209  VARCHAR2 := fnd_api.g_miss_char
    , p6_a210  VARCHAR2 := fnd_api.g_miss_char
    , p6_a211  VARCHAR2 := fnd_api.g_miss_char
    , p6_a212  VARCHAR2 := fnd_api.g_miss_char
    , p6_a213  VARCHAR2 := fnd_api.g_miss_char
    , p6_a214  VARCHAR2 := fnd_api.g_miss_char
    , p6_a215  VARCHAR2 := fnd_api.g_miss_char
    , p6_a216  VARCHAR2 := fnd_api.g_miss_char
    , p6_a217  VARCHAR2 := fnd_api.g_miss_char
    , p6_a218  VARCHAR2 := fnd_api.g_miss_char
    , p6_a219  VARCHAR2 := fnd_api.g_miss_char
    , p6_a220  VARCHAR2 := fnd_api.g_miss_char
    , p6_a221  VARCHAR2 := fnd_api.g_miss_char
    , p6_a222  VARCHAR2 := fnd_api.g_miss_char
    , p6_a223  VARCHAR2 := fnd_api.g_miss_char
    , p6_a224  VARCHAR2 := fnd_api.g_miss_char
    , p6_a225  VARCHAR2 := fnd_api.g_miss_char
    , p6_a226  VARCHAR2 := fnd_api.g_miss_char
    , p6_a227  VARCHAR2 := fnd_api.g_miss_char
    , p6_a228  VARCHAR2 := fnd_api.g_miss_char
    , p6_a229  VARCHAR2 := fnd_api.g_miss_char
    , p6_a230  VARCHAR2 := fnd_api.g_miss_char
    , p6_a231  VARCHAR2 := fnd_api.g_miss_char
    , p6_a232  VARCHAR2 := fnd_api.g_miss_char
    , p6_a233  VARCHAR2 := fnd_api.g_miss_char
    , p6_a234  VARCHAR2 := fnd_api.g_miss_char
    , p6_a235  VARCHAR2 := fnd_api.g_miss_char
    , p6_a236  VARCHAR2 := fnd_api.g_miss_char
    , p6_a237  VARCHAR2 := fnd_api.g_miss_char
    , p6_a238  VARCHAR2 := fnd_api.g_miss_char
    , p6_a239  VARCHAR2 := fnd_api.g_miss_char
    , p6_a240  VARCHAR2 := fnd_api.g_miss_char
    , p6_a241  VARCHAR2 := fnd_api.g_miss_char
    , p6_a242  VARCHAR2 := fnd_api.g_miss_char
    , p6_a243  VARCHAR2 := fnd_api.g_miss_char
    , p6_a244  VARCHAR2 := fnd_api.g_miss_char
    , p6_a245  VARCHAR2 := fnd_api.g_miss_char
    , p6_a246  VARCHAR2 := fnd_api.g_miss_char
    , p6_a247  VARCHAR2 := fnd_api.g_miss_char
    , p6_a248  VARCHAR2 := fnd_api.g_miss_char
    , p6_a249  VARCHAR2 := fnd_api.g_miss_char
    , p6_a250  VARCHAR2 := fnd_api.g_miss_char
    , p6_a251  VARCHAR2 := fnd_api.g_miss_char
    , p6_a252  VARCHAR2 := fnd_api.g_miss_char
    , p6_a253  VARCHAR2 := fnd_api.g_miss_char
    , p6_a254  VARCHAR2 := fnd_api.g_miss_char
    , p6_a255  VARCHAR2 := fnd_api.g_miss_char
    , p6_a256  VARCHAR2 := fnd_api.g_miss_char
    , p6_a257  VARCHAR2 := fnd_api.g_miss_char
    , p6_a258  NUMBER := 0-1962.0724
    , p6_a259  NUMBER := 0-1962.0724
    , p6_a260  NUMBER := 0-1962.0724
    , p6_a261  VARCHAR2 := fnd_api.g_miss_char
    , p6_a262  DATE := fnd_api.g_miss_date
    , p6_a263  VARCHAR2 := fnd_api.g_miss_char
    , p6_a264  VARCHAR2 := fnd_api.g_miss_char
    , p6_a265  VARCHAR2 := fnd_api.g_miss_char
    , p6_a266  VARCHAR2 := fnd_api.g_miss_char
    , p6_a267  DATE := fnd_api.g_miss_date
  );
  procedure update_list_entries(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  NUMBER := 0-1962.0724
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  VARCHAR2 := fnd_api.g_miss_char
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  VARCHAR2 := fnd_api.g_miss_char
    , p6_a100  VARCHAR2 := fnd_api.g_miss_char
    , p6_a101  VARCHAR2 := fnd_api.g_miss_char
    , p6_a102  VARCHAR2 := fnd_api.g_miss_char
    , p6_a103  VARCHAR2 := fnd_api.g_miss_char
    , p6_a104  VARCHAR2 := fnd_api.g_miss_char
    , p6_a105  VARCHAR2 := fnd_api.g_miss_char
    , p6_a106  VARCHAR2 := fnd_api.g_miss_char
    , p6_a107  VARCHAR2 := fnd_api.g_miss_char
    , p6_a108  VARCHAR2 := fnd_api.g_miss_char
    , p6_a109  VARCHAR2 := fnd_api.g_miss_char
    , p6_a110  VARCHAR2 := fnd_api.g_miss_char
    , p6_a111  VARCHAR2 := fnd_api.g_miss_char
    , p6_a112  VARCHAR2 := fnd_api.g_miss_char
    , p6_a113  VARCHAR2 := fnd_api.g_miss_char
    , p6_a114  VARCHAR2 := fnd_api.g_miss_char
    , p6_a115  VARCHAR2 := fnd_api.g_miss_char
    , p6_a116  VARCHAR2 := fnd_api.g_miss_char
    , p6_a117  VARCHAR2 := fnd_api.g_miss_char
    , p6_a118  VARCHAR2 := fnd_api.g_miss_char
    , p6_a119  VARCHAR2 := fnd_api.g_miss_char
    , p6_a120  VARCHAR2 := fnd_api.g_miss_char
    , p6_a121  VARCHAR2 := fnd_api.g_miss_char
    , p6_a122  VARCHAR2 := fnd_api.g_miss_char
    , p6_a123  VARCHAR2 := fnd_api.g_miss_char
    , p6_a124  VARCHAR2 := fnd_api.g_miss_char
    , p6_a125  VARCHAR2 := fnd_api.g_miss_char
    , p6_a126  VARCHAR2 := fnd_api.g_miss_char
    , p6_a127  VARCHAR2 := fnd_api.g_miss_char
    , p6_a128  VARCHAR2 := fnd_api.g_miss_char
    , p6_a129  VARCHAR2 := fnd_api.g_miss_char
    , p6_a130  VARCHAR2 := fnd_api.g_miss_char
    , p6_a131  VARCHAR2 := fnd_api.g_miss_char
    , p6_a132  VARCHAR2 := fnd_api.g_miss_char
    , p6_a133  VARCHAR2 := fnd_api.g_miss_char
    , p6_a134  VARCHAR2 := fnd_api.g_miss_char
    , p6_a135  VARCHAR2 := fnd_api.g_miss_char
    , p6_a136  VARCHAR2 := fnd_api.g_miss_char
    , p6_a137  VARCHAR2 := fnd_api.g_miss_char
    , p6_a138  VARCHAR2 := fnd_api.g_miss_char
    , p6_a139  VARCHAR2 := fnd_api.g_miss_char
    , p6_a140  VARCHAR2 := fnd_api.g_miss_char
    , p6_a141  VARCHAR2 := fnd_api.g_miss_char
    , p6_a142  VARCHAR2 := fnd_api.g_miss_char
    , p6_a143  VARCHAR2 := fnd_api.g_miss_char
    , p6_a144  VARCHAR2 := fnd_api.g_miss_char
    , p6_a145  VARCHAR2 := fnd_api.g_miss_char
    , p6_a146  VARCHAR2 := fnd_api.g_miss_char
    , p6_a147  VARCHAR2 := fnd_api.g_miss_char
    , p6_a148  VARCHAR2 := fnd_api.g_miss_char
    , p6_a149  VARCHAR2 := fnd_api.g_miss_char
    , p6_a150  VARCHAR2 := fnd_api.g_miss_char
    , p6_a151  VARCHAR2 := fnd_api.g_miss_char
    , p6_a152  VARCHAR2 := fnd_api.g_miss_char
    , p6_a153  VARCHAR2 := fnd_api.g_miss_char
    , p6_a154  VARCHAR2 := fnd_api.g_miss_char
    , p6_a155  VARCHAR2 := fnd_api.g_miss_char
    , p6_a156  VARCHAR2 := fnd_api.g_miss_char
    , p6_a157  VARCHAR2 := fnd_api.g_miss_char
    , p6_a158  VARCHAR2 := fnd_api.g_miss_char
    , p6_a159  VARCHAR2 := fnd_api.g_miss_char
    , p6_a160  VARCHAR2 := fnd_api.g_miss_char
    , p6_a161  VARCHAR2 := fnd_api.g_miss_char
    , p6_a162  VARCHAR2 := fnd_api.g_miss_char
    , p6_a163  VARCHAR2 := fnd_api.g_miss_char
    , p6_a164  VARCHAR2 := fnd_api.g_miss_char
    , p6_a165  VARCHAR2 := fnd_api.g_miss_char
    , p6_a166  VARCHAR2 := fnd_api.g_miss_char
    , p6_a167  VARCHAR2 := fnd_api.g_miss_char
    , p6_a168  VARCHAR2 := fnd_api.g_miss_char
    , p6_a169  VARCHAR2 := fnd_api.g_miss_char
    , p6_a170  VARCHAR2 := fnd_api.g_miss_char
    , p6_a171  VARCHAR2 := fnd_api.g_miss_char
    , p6_a172  VARCHAR2 := fnd_api.g_miss_char
    , p6_a173  VARCHAR2 := fnd_api.g_miss_char
    , p6_a174  VARCHAR2 := fnd_api.g_miss_char
    , p6_a175  VARCHAR2 := fnd_api.g_miss_char
    , p6_a176  VARCHAR2 := fnd_api.g_miss_char
    , p6_a177  VARCHAR2 := fnd_api.g_miss_char
    , p6_a178  VARCHAR2 := fnd_api.g_miss_char
    , p6_a179  VARCHAR2 := fnd_api.g_miss_char
    , p6_a180  VARCHAR2 := fnd_api.g_miss_char
    , p6_a181  VARCHAR2 := fnd_api.g_miss_char
    , p6_a182  VARCHAR2 := fnd_api.g_miss_char
    , p6_a183  VARCHAR2 := fnd_api.g_miss_char
    , p6_a184  VARCHAR2 := fnd_api.g_miss_char
    , p6_a185  VARCHAR2 := fnd_api.g_miss_char
    , p6_a186  VARCHAR2 := fnd_api.g_miss_char
    , p6_a187  VARCHAR2 := fnd_api.g_miss_char
    , p6_a188  VARCHAR2 := fnd_api.g_miss_char
    , p6_a189  VARCHAR2 := fnd_api.g_miss_char
    , p6_a190  VARCHAR2 := fnd_api.g_miss_char
    , p6_a191  VARCHAR2 := fnd_api.g_miss_char
    , p6_a192  VARCHAR2 := fnd_api.g_miss_char
    , p6_a193  VARCHAR2 := fnd_api.g_miss_char
    , p6_a194  VARCHAR2 := fnd_api.g_miss_char
    , p6_a195  VARCHAR2 := fnd_api.g_miss_char
    , p6_a196  VARCHAR2 := fnd_api.g_miss_char
    , p6_a197  VARCHAR2 := fnd_api.g_miss_char
    , p6_a198  VARCHAR2 := fnd_api.g_miss_char
    , p6_a199  VARCHAR2 := fnd_api.g_miss_char
    , p6_a200  VARCHAR2 := fnd_api.g_miss_char
    , p6_a201  VARCHAR2 := fnd_api.g_miss_char
    , p6_a202  VARCHAR2 := fnd_api.g_miss_char
    , p6_a203  VARCHAR2 := fnd_api.g_miss_char
    , p6_a204  VARCHAR2 := fnd_api.g_miss_char
    , p6_a205  VARCHAR2 := fnd_api.g_miss_char
    , p6_a206  VARCHAR2 := fnd_api.g_miss_char
    , p6_a207  VARCHAR2 := fnd_api.g_miss_char
    , p6_a208  VARCHAR2 := fnd_api.g_miss_char
    , p6_a209  VARCHAR2 := fnd_api.g_miss_char
    , p6_a210  VARCHAR2 := fnd_api.g_miss_char
    , p6_a211  VARCHAR2 := fnd_api.g_miss_char
    , p6_a212  VARCHAR2 := fnd_api.g_miss_char
    , p6_a213  VARCHAR2 := fnd_api.g_miss_char
    , p6_a214  VARCHAR2 := fnd_api.g_miss_char
    , p6_a215  VARCHAR2 := fnd_api.g_miss_char
    , p6_a216  VARCHAR2 := fnd_api.g_miss_char
    , p6_a217  VARCHAR2 := fnd_api.g_miss_char
    , p6_a218  VARCHAR2 := fnd_api.g_miss_char
    , p6_a219  VARCHAR2 := fnd_api.g_miss_char
    , p6_a220  VARCHAR2 := fnd_api.g_miss_char
    , p6_a221  VARCHAR2 := fnd_api.g_miss_char
    , p6_a222  VARCHAR2 := fnd_api.g_miss_char
    , p6_a223  VARCHAR2 := fnd_api.g_miss_char
    , p6_a224  VARCHAR2 := fnd_api.g_miss_char
    , p6_a225  VARCHAR2 := fnd_api.g_miss_char
    , p6_a226  VARCHAR2 := fnd_api.g_miss_char
    , p6_a227  VARCHAR2 := fnd_api.g_miss_char
    , p6_a228  VARCHAR2 := fnd_api.g_miss_char
    , p6_a229  VARCHAR2 := fnd_api.g_miss_char
    , p6_a230  VARCHAR2 := fnd_api.g_miss_char
    , p6_a231  VARCHAR2 := fnd_api.g_miss_char
    , p6_a232  VARCHAR2 := fnd_api.g_miss_char
    , p6_a233  VARCHAR2 := fnd_api.g_miss_char
    , p6_a234  VARCHAR2 := fnd_api.g_miss_char
    , p6_a235  VARCHAR2 := fnd_api.g_miss_char
    , p6_a236  VARCHAR2 := fnd_api.g_miss_char
    , p6_a237  VARCHAR2 := fnd_api.g_miss_char
    , p6_a238  VARCHAR2 := fnd_api.g_miss_char
    , p6_a239  VARCHAR2 := fnd_api.g_miss_char
    , p6_a240  VARCHAR2 := fnd_api.g_miss_char
    , p6_a241  VARCHAR2 := fnd_api.g_miss_char
    , p6_a242  VARCHAR2 := fnd_api.g_miss_char
    , p6_a243  VARCHAR2 := fnd_api.g_miss_char
    , p6_a244  VARCHAR2 := fnd_api.g_miss_char
    , p6_a245  VARCHAR2 := fnd_api.g_miss_char
    , p6_a246  VARCHAR2 := fnd_api.g_miss_char
    , p6_a247  VARCHAR2 := fnd_api.g_miss_char
    , p6_a248  VARCHAR2 := fnd_api.g_miss_char
    , p6_a249  VARCHAR2 := fnd_api.g_miss_char
    , p6_a250  VARCHAR2 := fnd_api.g_miss_char
    , p6_a251  VARCHAR2 := fnd_api.g_miss_char
    , p6_a252  VARCHAR2 := fnd_api.g_miss_char
    , p6_a253  VARCHAR2 := fnd_api.g_miss_char
    , p6_a254  VARCHAR2 := fnd_api.g_miss_char
    , p6_a255  VARCHAR2 := fnd_api.g_miss_char
    , p6_a256  VARCHAR2 := fnd_api.g_miss_char
    , p6_a257  VARCHAR2 := fnd_api.g_miss_char
    , p6_a258  NUMBER := 0-1962.0724
    , p6_a259  NUMBER := 0-1962.0724
    , p6_a260  NUMBER := 0-1962.0724
    , p6_a261  VARCHAR2 := fnd_api.g_miss_char
    , p6_a262  DATE := fnd_api.g_miss_date
    , p6_a263  VARCHAR2 := fnd_api.g_miss_char
    , p6_a264  VARCHAR2 := fnd_api.g_miss_char
    , p6_a265  VARCHAR2 := fnd_api.g_miss_char
    , p6_a266  VARCHAR2 := fnd_api.g_miss_char
    , p6_a267  DATE := fnd_api.g_miss_date
  );
end ams_list_entries_pub_w;

 

/
