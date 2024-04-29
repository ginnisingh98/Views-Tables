--------------------------------------------------------
--  DDL for Package Body AMS_LISTENTRY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTENTRY_PUB_W" as
  /* $Header: amszlseb.pls 115.5 2002/11/22 08:58:26 jieli ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_listentry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  VARCHAR2 := fnd_api.g_miss_char
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
    , p7_a295  VARCHAR2 := fnd_api.g_miss_char
    , p7_a296  VARCHAR2 := fnd_api.g_miss_char
    , p7_a297  VARCHAR2 := fnd_api.g_miss_char
    , p7_a298  VARCHAR2 := fnd_api.g_miss_char
    , p7_a299  VARCHAR2 := fnd_api.g_miss_char
    , p7_a300  VARCHAR2 := fnd_api.g_miss_char
    , p7_a301  VARCHAR2 := fnd_api.g_miss_char
    , p7_a302  VARCHAR2 := fnd_api.g_miss_char
    , p7_a303  VARCHAR2 := fnd_api.g_miss_char
    , p7_a304  VARCHAR2 := fnd_api.g_miss_char
    , p7_a305  VARCHAR2 := fnd_api.g_miss_char
    , p7_a306  VARCHAR2 := fnd_api.g_miss_char
    , p7_a307  VARCHAR2 := fnd_api.g_miss_char
    , p7_a308  VARCHAR2 := fnd_api.g_miss_char
    , p7_a309  VARCHAR2 := fnd_api.g_miss_char
    , p7_a310  VARCHAR2 := fnd_api.g_miss_char
    , p7_a311  VARCHAR2 := fnd_api.g_miss_char
    , p7_a312  VARCHAR2 := fnd_api.g_miss_char
    , p7_a313  VARCHAR2 := fnd_api.g_miss_char
    , p7_a314  VARCHAR2 := fnd_api.g_miss_char
    , p7_a315  VARCHAR2 := fnd_api.g_miss_char
    , p7_a316  VARCHAR2 := fnd_api.g_miss_char
    , p7_a317  VARCHAR2 := fnd_api.g_miss_char
    , p7_a318  VARCHAR2 := fnd_api.g_miss_char
    , p7_a319  VARCHAR2 := fnd_api.g_miss_char
    , p7_a320  VARCHAR2 := fnd_api.g_miss_char
    , p7_a321  VARCHAR2 := fnd_api.g_miss_char
    , p7_a322  VARCHAR2 := fnd_api.g_miss_char
    , p7_a323  VARCHAR2 := fnd_api.g_miss_char
    , p7_a324  VARCHAR2 := fnd_api.g_miss_char
    , p7_a325  VARCHAR2 := fnd_api.g_miss_char
    , p7_a326  VARCHAR2 := fnd_api.g_miss_char
    , p7_a327  VARCHAR2 := fnd_api.g_miss_char
    , p7_a328  VARCHAR2 := fnd_api.g_miss_char
    , p7_a329  VARCHAR2 := fnd_api.g_miss_char
    , p7_a330  VARCHAR2 := fnd_api.g_miss_char
    , p7_a331  VARCHAR2 := fnd_api.g_miss_char
    , p7_a332  VARCHAR2 := fnd_api.g_miss_char
    , p7_a333  VARCHAR2 := fnd_api.g_miss_char
    , p7_a334  VARCHAR2 := fnd_api.g_miss_char
    , p7_a335  VARCHAR2 := fnd_api.g_miss_char
    , p7_a336  VARCHAR2 := fnd_api.g_miss_char
    , p7_a337  VARCHAR2 := fnd_api.g_miss_char
    , p7_a338  VARCHAR2 := fnd_api.g_miss_char
    , p7_a339  VARCHAR2 := fnd_api.g_miss_char
    , p7_a340  VARCHAR2 := fnd_api.g_miss_char
    , p7_a341  VARCHAR2 := fnd_api.g_miss_char
    , p7_a342  VARCHAR2 := fnd_api.g_miss_char
    , p7_a343  VARCHAR2 := fnd_api.g_miss_char
    , p7_a344  VARCHAR2 := fnd_api.g_miss_char
    , p7_a345  VARCHAR2 := fnd_api.g_miss_char
    , p7_a346  VARCHAR2 := fnd_api.g_miss_char
    , p7_a347  VARCHAR2 := fnd_api.g_miss_char
    , p7_a348  VARCHAR2 := fnd_api.g_miss_char
    , p7_a349  VARCHAR2 := fnd_api.g_miss_char
    , p7_a350  VARCHAR2 := fnd_api.g_miss_char
    , p7_a351  VARCHAR2 := fnd_api.g_miss_char
    , p7_a352  VARCHAR2 := fnd_api.g_miss_char
    , p7_a353  VARCHAR2 := fnd_api.g_miss_char
    , p7_a354  VARCHAR2 := fnd_api.g_miss_char
    , p7_a355  VARCHAR2 := fnd_api.g_miss_char
    , p7_a356  VARCHAR2 := fnd_api.g_miss_char
    , p7_a357  VARCHAR2 := fnd_api.g_miss_char
    , p7_a358  VARCHAR2 := fnd_api.g_miss_char
    , p7_a359  VARCHAR2 := fnd_api.g_miss_char
    , p7_a360  VARCHAR2 := fnd_api.g_miss_char
    , p7_a361  VARCHAR2 := fnd_api.g_miss_char
    , p7_a362  VARCHAR2 := fnd_api.g_miss_char
    , p7_a363  VARCHAR2 := fnd_api.g_miss_char
    , p7_a364  VARCHAR2 := fnd_api.g_miss_char
    , p7_a365  VARCHAR2 := fnd_api.g_miss_char
    , p7_a366  NUMBER := 0-1962.0724
    , p7_a367  NUMBER := 0-1962.0724
    , p7_a368  NUMBER := 0-1962.0724
    , p7_a369  NUMBER := 0-1962.0724
    , p7_a370  NUMBER := 0-1962.0724
    , p7_a371  NUMBER := 0-1962.0724
    , p7_a372  DATE := fnd_api.g_miss_date
    , p7_a373  DATE := fnd_api.g_miss_date
    , p7_a374  NUMBER := 0-1962.0724
    , p7_a375  NUMBER := 0-1962.0724
    , x_entry_id OUT NOCOPY  NUMBER
  )
  as
    ddp_entry_rec ams_listentry_pvt.entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_entry_rec.list_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_entry_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_entry_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_entry_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_entry_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_entry_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_entry_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_entry_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a8);
    ddp_entry_rec.arc_list_select_action_from := p7_a9;
    ddp_entry_rec.list_select_action_from_name := p7_a10;
    ddp_entry_rec.source_code := p7_a11;
    ddp_entry_rec.arc_list_used_by_source := p7_a12;
    ddp_entry_rec.source_code_for_id := rosetta_g_miss_num_map(p7_a13);
    ddp_entry_rec.pin_code := p7_a14;
    ddp_entry_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_entry_rec.list_entry_source_system_type := p7_a16;
    ddp_entry_rec.view_application_id := rosetta_g_miss_num_map(p7_a17);
    ddp_entry_rec.manually_entered_flag := p7_a18;
    ddp_entry_rec.marked_as_duplicate_flag := p7_a19;
    ddp_entry_rec.marked_as_random_flag := p7_a20;
    ddp_entry_rec.part_of_control_group_flag := p7_a21;
    ddp_entry_rec.exclude_in_triggered_list_flag := p7_a22;
    ddp_entry_rec.enabled_flag := p7_a23;
    ddp_entry_rec.cell_code := p7_a24;
    ddp_entry_rec.dedupe_key := p7_a25;
    ddp_entry_rec.randomly_generated_number := rosetta_g_miss_num_map(p7_a26);
    ddp_entry_rec.campaign_id := rosetta_g_miss_num_map(p7_a27);
    ddp_entry_rec.media_id := rosetta_g_miss_num_map(p7_a28);
    ddp_entry_rec.channel_id := rosetta_g_miss_num_map(p7_a29);
    ddp_entry_rec.channel_schedule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_entry_rec.event_offer_id := rosetta_g_miss_num_map(p7_a31);
    ddp_entry_rec.customer_id := rosetta_g_miss_num_map(p7_a32);
    ddp_entry_rec.market_segment_id := rosetta_g_miss_num_map(p7_a33);
    ddp_entry_rec.vendor_id := rosetta_g_miss_num_map(p7_a34);
    ddp_entry_rec.transfer_flag := p7_a35;
    ddp_entry_rec.transfer_status := p7_a36;
    ddp_entry_rec.list_source := p7_a37;
    ddp_entry_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p7_a38);
    ddp_entry_rec.marked_flag := p7_a39;
    ddp_entry_rec.lead_id := rosetta_g_miss_num_map(p7_a40);
    ddp_entry_rec.letter_id := rosetta_g_miss_num_map(p7_a41);
    ddp_entry_rec.picking_header_id := rosetta_g_miss_num_map(p7_a42);
    ddp_entry_rec.batch_id := rosetta_g_miss_num_map(p7_a43);
    ddp_entry_rec.first_name := p7_a44;
    ddp_entry_rec.last_name := p7_a45;
    ddp_entry_rec.customer_name := p7_a46;
    ddp_entry_rec.col1 := p7_a47;
    ddp_entry_rec.col2 := p7_a48;
    ddp_entry_rec.col3 := p7_a49;
    ddp_entry_rec.col4 := p7_a50;
    ddp_entry_rec.col5 := p7_a51;
    ddp_entry_rec.col6 := p7_a52;
    ddp_entry_rec.col7 := p7_a53;
    ddp_entry_rec.col8 := p7_a54;
    ddp_entry_rec.col9 := p7_a55;
    ddp_entry_rec.col10 := p7_a56;
    ddp_entry_rec.col11 := p7_a57;
    ddp_entry_rec.col12 := p7_a58;
    ddp_entry_rec.col13 := p7_a59;
    ddp_entry_rec.col14 := p7_a60;
    ddp_entry_rec.col15 := p7_a61;
    ddp_entry_rec.col16 := p7_a62;
    ddp_entry_rec.col17 := p7_a63;
    ddp_entry_rec.col18 := p7_a64;
    ddp_entry_rec.col19 := p7_a65;
    ddp_entry_rec.col20 := p7_a66;
    ddp_entry_rec.col21 := p7_a67;
    ddp_entry_rec.col22 := p7_a68;
    ddp_entry_rec.col23 := p7_a69;
    ddp_entry_rec.col24 := p7_a70;
    ddp_entry_rec.col25 := p7_a71;
    ddp_entry_rec.col26 := p7_a72;
    ddp_entry_rec.col27 := p7_a73;
    ddp_entry_rec.col28 := p7_a74;
    ddp_entry_rec.col29 := p7_a75;
    ddp_entry_rec.col30 := p7_a76;
    ddp_entry_rec.col31 := p7_a77;
    ddp_entry_rec.col32 := p7_a78;
    ddp_entry_rec.col33 := p7_a79;
    ddp_entry_rec.col34 := p7_a80;
    ddp_entry_rec.col35 := p7_a81;
    ddp_entry_rec.col36 := p7_a82;
    ddp_entry_rec.col37 := p7_a83;
    ddp_entry_rec.col38 := p7_a84;
    ddp_entry_rec.col39 := p7_a85;
    ddp_entry_rec.col40 := p7_a86;
    ddp_entry_rec.col41 := p7_a87;
    ddp_entry_rec.col42 := p7_a88;
    ddp_entry_rec.col43 := p7_a89;
    ddp_entry_rec.col44 := p7_a90;
    ddp_entry_rec.col45 := p7_a91;
    ddp_entry_rec.col46 := p7_a92;
    ddp_entry_rec.col47 := p7_a93;
    ddp_entry_rec.col48 := p7_a94;
    ddp_entry_rec.col49 := p7_a95;
    ddp_entry_rec.col50 := p7_a96;
    ddp_entry_rec.col51 := p7_a97;
    ddp_entry_rec.col52 := p7_a98;
    ddp_entry_rec.col53 := p7_a99;
    ddp_entry_rec.col54 := p7_a100;
    ddp_entry_rec.col55 := p7_a101;
    ddp_entry_rec.col56 := p7_a102;
    ddp_entry_rec.col57 := p7_a103;
    ddp_entry_rec.col58 := p7_a104;
    ddp_entry_rec.col59 := p7_a105;
    ddp_entry_rec.col60 := p7_a106;
    ddp_entry_rec.col61 := p7_a107;
    ddp_entry_rec.col62 := p7_a108;
    ddp_entry_rec.col63 := p7_a109;
    ddp_entry_rec.col64 := p7_a110;
    ddp_entry_rec.col65 := p7_a111;
    ddp_entry_rec.col66 := p7_a112;
    ddp_entry_rec.col67 := p7_a113;
    ddp_entry_rec.col68 := p7_a114;
    ddp_entry_rec.col69 := p7_a115;
    ddp_entry_rec.col70 := p7_a116;
    ddp_entry_rec.col71 := p7_a117;
    ddp_entry_rec.col72 := p7_a118;
    ddp_entry_rec.col73 := p7_a119;
    ddp_entry_rec.col74 := p7_a120;
    ddp_entry_rec.col75 := p7_a121;
    ddp_entry_rec.col76 := p7_a122;
    ddp_entry_rec.col77 := p7_a123;
    ddp_entry_rec.col78 := p7_a124;
    ddp_entry_rec.col79 := p7_a125;
    ddp_entry_rec.col80 := p7_a126;
    ddp_entry_rec.col81 := p7_a127;
    ddp_entry_rec.col82 := p7_a128;
    ddp_entry_rec.col83 := p7_a129;
    ddp_entry_rec.col84 := p7_a130;
    ddp_entry_rec.col85 := p7_a131;
    ddp_entry_rec.col86 := p7_a132;
    ddp_entry_rec.col87 := p7_a133;
    ddp_entry_rec.col88 := p7_a134;
    ddp_entry_rec.col89 := p7_a135;
    ddp_entry_rec.col90 := p7_a136;
    ddp_entry_rec.col91 := p7_a137;
    ddp_entry_rec.col92 := p7_a138;
    ddp_entry_rec.col93 := p7_a139;
    ddp_entry_rec.col94 := p7_a140;
    ddp_entry_rec.col95 := p7_a141;
    ddp_entry_rec.col96 := p7_a142;
    ddp_entry_rec.col97 := p7_a143;
    ddp_entry_rec.col98 := p7_a144;
    ddp_entry_rec.col99 := p7_a145;
    ddp_entry_rec.col100 := p7_a146;
    ddp_entry_rec.col101 := p7_a147;
    ddp_entry_rec.col102 := p7_a148;
    ddp_entry_rec.col103 := p7_a149;
    ddp_entry_rec.col104 := p7_a150;
    ddp_entry_rec.col105 := p7_a151;
    ddp_entry_rec.col106 := p7_a152;
    ddp_entry_rec.col107 := p7_a153;
    ddp_entry_rec.col108 := p7_a154;
    ddp_entry_rec.col109 := p7_a155;
    ddp_entry_rec.col110 := p7_a156;
    ddp_entry_rec.col111 := p7_a157;
    ddp_entry_rec.col112 := p7_a158;
    ddp_entry_rec.col113 := p7_a159;
    ddp_entry_rec.col114 := p7_a160;
    ddp_entry_rec.col115 := p7_a161;
    ddp_entry_rec.col116 := p7_a162;
    ddp_entry_rec.col117 := p7_a163;
    ddp_entry_rec.col118 := p7_a164;
    ddp_entry_rec.col119 := p7_a165;
    ddp_entry_rec.col120 := p7_a166;
    ddp_entry_rec.col121 := p7_a167;
    ddp_entry_rec.col122 := p7_a168;
    ddp_entry_rec.col123 := p7_a169;
    ddp_entry_rec.col124 := p7_a170;
    ddp_entry_rec.col125 := p7_a171;
    ddp_entry_rec.col126 := p7_a172;
    ddp_entry_rec.col127 := p7_a173;
    ddp_entry_rec.col128 := p7_a174;
    ddp_entry_rec.col129 := p7_a175;
    ddp_entry_rec.col130 := p7_a176;
    ddp_entry_rec.col131 := p7_a177;
    ddp_entry_rec.col132 := p7_a178;
    ddp_entry_rec.col133 := p7_a179;
    ddp_entry_rec.col134 := p7_a180;
    ddp_entry_rec.col135 := p7_a181;
    ddp_entry_rec.col136 := p7_a182;
    ddp_entry_rec.col137 := p7_a183;
    ddp_entry_rec.col138 := p7_a184;
    ddp_entry_rec.col139 := p7_a185;
    ddp_entry_rec.col140 := p7_a186;
    ddp_entry_rec.col141 := p7_a187;
    ddp_entry_rec.col142 := p7_a188;
    ddp_entry_rec.col143 := p7_a189;
    ddp_entry_rec.col144 := p7_a190;
    ddp_entry_rec.col145 := p7_a191;
    ddp_entry_rec.col146 := p7_a192;
    ddp_entry_rec.col147 := p7_a193;
    ddp_entry_rec.col148 := p7_a194;
    ddp_entry_rec.col149 := p7_a195;
    ddp_entry_rec.col150 := p7_a196;
    ddp_entry_rec.col151 := p7_a197;
    ddp_entry_rec.col152 := p7_a198;
    ddp_entry_rec.col153 := p7_a199;
    ddp_entry_rec.col154 := p7_a200;
    ddp_entry_rec.col155 := p7_a201;
    ddp_entry_rec.col156 := p7_a202;
    ddp_entry_rec.col157 := p7_a203;
    ddp_entry_rec.col158 := p7_a204;
    ddp_entry_rec.col159 := p7_a205;
    ddp_entry_rec.col160 := p7_a206;
    ddp_entry_rec.col161 := p7_a207;
    ddp_entry_rec.col162 := p7_a208;
    ddp_entry_rec.col163 := p7_a209;
    ddp_entry_rec.col164 := p7_a210;
    ddp_entry_rec.col165 := p7_a211;
    ddp_entry_rec.col166 := p7_a212;
    ddp_entry_rec.col167 := p7_a213;
    ddp_entry_rec.col168 := p7_a214;
    ddp_entry_rec.col169 := p7_a215;
    ddp_entry_rec.col170 := p7_a216;
    ddp_entry_rec.col171 := p7_a217;
    ddp_entry_rec.col172 := p7_a218;
    ddp_entry_rec.col173 := p7_a219;
    ddp_entry_rec.col174 := p7_a220;
    ddp_entry_rec.col175 := p7_a221;
    ddp_entry_rec.col176 := p7_a222;
    ddp_entry_rec.col177 := p7_a223;
    ddp_entry_rec.col178 := p7_a224;
    ddp_entry_rec.col179 := p7_a225;
    ddp_entry_rec.col180 := p7_a226;
    ddp_entry_rec.col181 := p7_a227;
    ddp_entry_rec.col182 := p7_a228;
    ddp_entry_rec.col183 := p7_a229;
    ddp_entry_rec.col184 := p7_a230;
    ddp_entry_rec.col185 := p7_a231;
    ddp_entry_rec.col186 := p7_a232;
    ddp_entry_rec.col187 := p7_a233;
    ddp_entry_rec.col188 := p7_a234;
    ddp_entry_rec.col189 := p7_a235;
    ddp_entry_rec.col190 := p7_a236;
    ddp_entry_rec.col191 := p7_a237;
    ddp_entry_rec.col192 := p7_a238;
    ddp_entry_rec.col193 := p7_a239;
    ddp_entry_rec.col194 := p7_a240;
    ddp_entry_rec.col195 := p7_a241;
    ddp_entry_rec.col196 := p7_a242;
    ddp_entry_rec.col197 := p7_a243;
    ddp_entry_rec.col198 := p7_a244;
    ddp_entry_rec.col199 := p7_a245;
    ddp_entry_rec.col200 := p7_a246;
    ddp_entry_rec.col201 := p7_a247;
    ddp_entry_rec.col202 := p7_a248;
    ddp_entry_rec.col203 := p7_a249;
    ddp_entry_rec.col204 := p7_a250;
    ddp_entry_rec.col205 := p7_a251;
    ddp_entry_rec.col206 := p7_a252;
    ddp_entry_rec.col207 := p7_a253;
    ddp_entry_rec.col208 := p7_a254;
    ddp_entry_rec.col209 := p7_a255;
    ddp_entry_rec.col210 := p7_a256;
    ddp_entry_rec.col211 := p7_a257;
    ddp_entry_rec.col212 := p7_a258;
    ddp_entry_rec.col213 := p7_a259;
    ddp_entry_rec.col214 := p7_a260;
    ddp_entry_rec.col215 := p7_a261;
    ddp_entry_rec.col216 := p7_a262;
    ddp_entry_rec.col217 := p7_a263;
    ddp_entry_rec.col218 := p7_a264;
    ddp_entry_rec.col219 := p7_a265;
    ddp_entry_rec.col220 := p7_a266;
    ddp_entry_rec.col221 := p7_a267;
    ddp_entry_rec.col222 := p7_a268;
    ddp_entry_rec.col223 := p7_a269;
    ddp_entry_rec.col224 := p7_a270;
    ddp_entry_rec.col225 := p7_a271;
    ddp_entry_rec.col226 := p7_a272;
    ddp_entry_rec.col227 := p7_a273;
    ddp_entry_rec.col228 := p7_a274;
    ddp_entry_rec.col229 := p7_a275;
    ddp_entry_rec.col230 := p7_a276;
    ddp_entry_rec.col231 := p7_a277;
    ddp_entry_rec.col232 := p7_a278;
    ddp_entry_rec.col233 := p7_a279;
    ddp_entry_rec.col234 := p7_a280;
    ddp_entry_rec.col235 := p7_a281;
    ddp_entry_rec.col236 := p7_a282;
    ddp_entry_rec.col237 := p7_a283;
    ddp_entry_rec.col238 := p7_a284;
    ddp_entry_rec.col239 := p7_a285;
    ddp_entry_rec.col240 := p7_a286;
    ddp_entry_rec.col241 := p7_a287;
    ddp_entry_rec.col242 := p7_a288;
    ddp_entry_rec.col243 := p7_a289;
    ddp_entry_rec.col244 := p7_a290;
    ddp_entry_rec.col245 := p7_a291;
    ddp_entry_rec.col246 := p7_a292;
    ddp_entry_rec.col247 := p7_a293;
    ddp_entry_rec.col248 := p7_a294;
    ddp_entry_rec.col249 := p7_a295;
    ddp_entry_rec.col250 := p7_a296;
    ddp_entry_rec.col251 := p7_a297;
    ddp_entry_rec.col252 := p7_a298;
    ddp_entry_rec.col253 := p7_a299;
    ddp_entry_rec.col254 := p7_a300;
    ddp_entry_rec.col255 := p7_a301;
    ddp_entry_rec.col256 := p7_a302;
    ddp_entry_rec.col257 := p7_a303;
    ddp_entry_rec.col258 := p7_a304;
    ddp_entry_rec.col259 := p7_a305;
    ddp_entry_rec.col260 := p7_a306;
    ddp_entry_rec.col261 := p7_a307;
    ddp_entry_rec.col262 := p7_a308;
    ddp_entry_rec.col263 := p7_a309;
    ddp_entry_rec.col264 := p7_a310;
    ddp_entry_rec.col265 := p7_a311;
    ddp_entry_rec.col266 := p7_a312;
    ddp_entry_rec.col267 := p7_a313;
    ddp_entry_rec.col268 := p7_a314;
    ddp_entry_rec.col269 := p7_a315;
    ddp_entry_rec.col270 := p7_a316;
    ddp_entry_rec.col271 := p7_a317;
    ddp_entry_rec.col272 := p7_a318;
    ddp_entry_rec.col273 := p7_a319;
    ddp_entry_rec.col274 := p7_a320;
    ddp_entry_rec.col275 := p7_a321;
    ddp_entry_rec.col276 := p7_a322;
    ddp_entry_rec.col277 := p7_a323;
    ddp_entry_rec.col278 := p7_a324;
    ddp_entry_rec.col279 := p7_a325;
    ddp_entry_rec.col280 := p7_a326;
    ddp_entry_rec.col281 := p7_a327;
    ddp_entry_rec.col282 := p7_a328;
    ddp_entry_rec.col283 := p7_a329;
    ddp_entry_rec.col284 := p7_a330;
    ddp_entry_rec.col285 := p7_a331;
    ddp_entry_rec.col286 := p7_a332;
    ddp_entry_rec.col287 := p7_a333;
    ddp_entry_rec.col288 := p7_a334;
    ddp_entry_rec.col289 := p7_a335;
    ddp_entry_rec.col290 := p7_a336;
    ddp_entry_rec.col291 := p7_a337;
    ddp_entry_rec.col292 := p7_a338;
    ddp_entry_rec.col293 := p7_a339;
    ddp_entry_rec.col294 := p7_a340;
    ddp_entry_rec.col295 := p7_a341;
    ddp_entry_rec.col296 := p7_a342;
    ddp_entry_rec.col297 := p7_a343;
    ddp_entry_rec.col298 := p7_a344;
    ddp_entry_rec.col299 := p7_a345;
    ddp_entry_rec.col300 := p7_a346;
    ddp_entry_rec.address_line1 := p7_a347;
    ddp_entry_rec.address_line2 := p7_a348;
    ddp_entry_rec.callback_flag := p7_a349;
    ddp_entry_rec.city := p7_a350;
    ddp_entry_rec.country := p7_a351;
    ddp_entry_rec.do_not_use_flag := p7_a352;
    ddp_entry_rec.do_not_use_reason := p7_a353;
    ddp_entry_rec.email_address := p7_a354;
    ddp_entry_rec.fax := p7_a355;
    ddp_entry_rec.phone := p7_a356;
    ddp_entry_rec.record_out_flag := p7_a357;
    ddp_entry_rec.state := p7_a358;
    ddp_entry_rec.suffix := p7_a359;
    ddp_entry_rec.title := p7_a360;
    ddp_entry_rec.usage_restriction := p7_a361;
    ddp_entry_rec.zipcode := p7_a362;
    ddp_entry_rec.curr_cp_country_code := p7_a363;
    ddp_entry_rec.curr_cp_phone_number := p7_a364;
    ddp_entry_rec.curr_cp_raw_phone_number := p7_a365;
    ddp_entry_rec.curr_cp_area_code := rosetta_g_miss_num_map(p7_a366);
    ddp_entry_rec.curr_cp_id := rosetta_g_miss_num_map(p7_a367);
    ddp_entry_rec.curr_cp_index := rosetta_g_miss_num_map(p7_a368);
    ddp_entry_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p7_a369);
    ddp_entry_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p7_a370);
    ddp_entry_rec.imp_source_line_id := rosetta_g_miss_num_map(p7_a371);
    ddp_entry_rec.next_call_time := rosetta_g_miss_date_in_map(p7_a372);
    ddp_entry_rec.record_release_time := rosetta_g_miss_date_in_map(p7_a373);
    ddp_entry_rec.party_id := rosetta_g_miss_num_map(p7_a374);
    ddp_entry_rec.parent_party_id := rosetta_g_miss_num_map(p7_a375);


    -- here's the delegated call to the old PL/SQL routine
    ams_listentry_pub.create_listentry(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entry_rec,
      x_entry_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_listentry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  VARCHAR2 := fnd_api.g_miss_char
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
    , p7_a295  VARCHAR2 := fnd_api.g_miss_char
    , p7_a296  VARCHAR2 := fnd_api.g_miss_char
    , p7_a297  VARCHAR2 := fnd_api.g_miss_char
    , p7_a298  VARCHAR2 := fnd_api.g_miss_char
    , p7_a299  VARCHAR2 := fnd_api.g_miss_char
    , p7_a300  VARCHAR2 := fnd_api.g_miss_char
    , p7_a301  VARCHAR2 := fnd_api.g_miss_char
    , p7_a302  VARCHAR2 := fnd_api.g_miss_char
    , p7_a303  VARCHAR2 := fnd_api.g_miss_char
    , p7_a304  VARCHAR2 := fnd_api.g_miss_char
    , p7_a305  VARCHAR2 := fnd_api.g_miss_char
    , p7_a306  VARCHAR2 := fnd_api.g_miss_char
    , p7_a307  VARCHAR2 := fnd_api.g_miss_char
    , p7_a308  VARCHAR2 := fnd_api.g_miss_char
    , p7_a309  VARCHAR2 := fnd_api.g_miss_char
    , p7_a310  VARCHAR2 := fnd_api.g_miss_char
    , p7_a311  VARCHAR2 := fnd_api.g_miss_char
    , p7_a312  VARCHAR2 := fnd_api.g_miss_char
    , p7_a313  VARCHAR2 := fnd_api.g_miss_char
    , p7_a314  VARCHAR2 := fnd_api.g_miss_char
    , p7_a315  VARCHAR2 := fnd_api.g_miss_char
    , p7_a316  VARCHAR2 := fnd_api.g_miss_char
    , p7_a317  VARCHAR2 := fnd_api.g_miss_char
    , p7_a318  VARCHAR2 := fnd_api.g_miss_char
    , p7_a319  VARCHAR2 := fnd_api.g_miss_char
    , p7_a320  VARCHAR2 := fnd_api.g_miss_char
    , p7_a321  VARCHAR2 := fnd_api.g_miss_char
    , p7_a322  VARCHAR2 := fnd_api.g_miss_char
    , p7_a323  VARCHAR2 := fnd_api.g_miss_char
    , p7_a324  VARCHAR2 := fnd_api.g_miss_char
    , p7_a325  VARCHAR2 := fnd_api.g_miss_char
    , p7_a326  VARCHAR2 := fnd_api.g_miss_char
    , p7_a327  VARCHAR2 := fnd_api.g_miss_char
    , p7_a328  VARCHAR2 := fnd_api.g_miss_char
    , p7_a329  VARCHAR2 := fnd_api.g_miss_char
    , p7_a330  VARCHAR2 := fnd_api.g_miss_char
    , p7_a331  VARCHAR2 := fnd_api.g_miss_char
    , p7_a332  VARCHAR2 := fnd_api.g_miss_char
    , p7_a333  VARCHAR2 := fnd_api.g_miss_char
    , p7_a334  VARCHAR2 := fnd_api.g_miss_char
    , p7_a335  VARCHAR2 := fnd_api.g_miss_char
    , p7_a336  VARCHAR2 := fnd_api.g_miss_char
    , p7_a337  VARCHAR2 := fnd_api.g_miss_char
    , p7_a338  VARCHAR2 := fnd_api.g_miss_char
    , p7_a339  VARCHAR2 := fnd_api.g_miss_char
    , p7_a340  VARCHAR2 := fnd_api.g_miss_char
    , p7_a341  VARCHAR2 := fnd_api.g_miss_char
    , p7_a342  VARCHAR2 := fnd_api.g_miss_char
    , p7_a343  VARCHAR2 := fnd_api.g_miss_char
    , p7_a344  VARCHAR2 := fnd_api.g_miss_char
    , p7_a345  VARCHAR2 := fnd_api.g_miss_char
    , p7_a346  VARCHAR2 := fnd_api.g_miss_char
    , p7_a347  VARCHAR2 := fnd_api.g_miss_char
    , p7_a348  VARCHAR2 := fnd_api.g_miss_char
    , p7_a349  VARCHAR2 := fnd_api.g_miss_char
    , p7_a350  VARCHAR2 := fnd_api.g_miss_char
    , p7_a351  VARCHAR2 := fnd_api.g_miss_char
    , p7_a352  VARCHAR2 := fnd_api.g_miss_char
    , p7_a353  VARCHAR2 := fnd_api.g_miss_char
    , p7_a354  VARCHAR2 := fnd_api.g_miss_char
    , p7_a355  VARCHAR2 := fnd_api.g_miss_char
    , p7_a356  VARCHAR2 := fnd_api.g_miss_char
    , p7_a357  VARCHAR2 := fnd_api.g_miss_char
    , p7_a358  VARCHAR2 := fnd_api.g_miss_char
    , p7_a359  VARCHAR2 := fnd_api.g_miss_char
    , p7_a360  VARCHAR2 := fnd_api.g_miss_char
    , p7_a361  VARCHAR2 := fnd_api.g_miss_char
    , p7_a362  VARCHAR2 := fnd_api.g_miss_char
    , p7_a363  VARCHAR2 := fnd_api.g_miss_char
    , p7_a364  VARCHAR2 := fnd_api.g_miss_char
    , p7_a365  VARCHAR2 := fnd_api.g_miss_char
    , p7_a366  NUMBER := 0-1962.0724
    , p7_a367  NUMBER := 0-1962.0724
    , p7_a368  NUMBER := 0-1962.0724
    , p7_a369  NUMBER := 0-1962.0724
    , p7_a370  NUMBER := 0-1962.0724
    , p7_a371  NUMBER := 0-1962.0724
    , p7_a372  DATE := fnd_api.g_miss_date
    , p7_a373  DATE := fnd_api.g_miss_date
    , p7_a374  NUMBER := 0-1962.0724
    , p7_a375  NUMBER := 0-1962.0724
  )
  as
    ddp_entry_rec ams_listentry_pvt.entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_entry_rec.list_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_entry_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_entry_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_entry_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_entry_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_entry_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_entry_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_entry_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a8);
    ddp_entry_rec.arc_list_select_action_from := p7_a9;
    ddp_entry_rec.list_select_action_from_name := p7_a10;
    ddp_entry_rec.source_code := p7_a11;
    ddp_entry_rec.arc_list_used_by_source := p7_a12;
    ddp_entry_rec.source_code_for_id := rosetta_g_miss_num_map(p7_a13);
    ddp_entry_rec.pin_code := p7_a14;
    ddp_entry_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_entry_rec.list_entry_source_system_type := p7_a16;
    ddp_entry_rec.view_application_id := rosetta_g_miss_num_map(p7_a17);
    ddp_entry_rec.manually_entered_flag := p7_a18;
    ddp_entry_rec.marked_as_duplicate_flag := p7_a19;
    ddp_entry_rec.marked_as_random_flag := p7_a20;
    ddp_entry_rec.part_of_control_group_flag := p7_a21;
    ddp_entry_rec.exclude_in_triggered_list_flag := p7_a22;
    ddp_entry_rec.enabled_flag := p7_a23;
    ddp_entry_rec.cell_code := p7_a24;
    ddp_entry_rec.dedupe_key := p7_a25;
    ddp_entry_rec.randomly_generated_number := rosetta_g_miss_num_map(p7_a26);
    ddp_entry_rec.campaign_id := rosetta_g_miss_num_map(p7_a27);
    ddp_entry_rec.media_id := rosetta_g_miss_num_map(p7_a28);
    ddp_entry_rec.channel_id := rosetta_g_miss_num_map(p7_a29);
    ddp_entry_rec.channel_schedule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_entry_rec.event_offer_id := rosetta_g_miss_num_map(p7_a31);
    ddp_entry_rec.customer_id := rosetta_g_miss_num_map(p7_a32);
    ddp_entry_rec.market_segment_id := rosetta_g_miss_num_map(p7_a33);
    ddp_entry_rec.vendor_id := rosetta_g_miss_num_map(p7_a34);
    ddp_entry_rec.transfer_flag := p7_a35;
    ddp_entry_rec.transfer_status := p7_a36;
    ddp_entry_rec.list_source := p7_a37;
    ddp_entry_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p7_a38);
    ddp_entry_rec.marked_flag := p7_a39;
    ddp_entry_rec.lead_id := rosetta_g_miss_num_map(p7_a40);
    ddp_entry_rec.letter_id := rosetta_g_miss_num_map(p7_a41);
    ddp_entry_rec.picking_header_id := rosetta_g_miss_num_map(p7_a42);
    ddp_entry_rec.batch_id := rosetta_g_miss_num_map(p7_a43);
    ddp_entry_rec.first_name := p7_a44;
    ddp_entry_rec.last_name := p7_a45;
    ddp_entry_rec.customer_name := p7_a46;
    ddp_entry_rec.col1 := p7_a47;
    ddp_entry_rec.col2 := p7_a48;
    ddp_entry_rec.col3 := p7_a49;
    ddp_entry_rec.col4 := p7_a50;
    ddp_entry_rec.col5 := p7_a51;
    ddp_entry_rec.col6 := p7_a52;
    ddp_entry_rec.col7 := p7_a53;
    ddp_entry_rec.col8 := p7_a54;
    ddp_entry_rec.col9 := p7_a55;
    ddp_entry_rec.col10 := p7_a56;
    ddp_entry_rec.col11 := p7_a57;
    ddp_entry_rec.col12 := p7_a58;
    ddp_entry_rec.col13 := p7_a59;
    ddp_entry_rec.col14 := p7_a60;
    ddp_entry_rec.col15 := p7_a61;
    ddp_entry_rec.col16 := p7_a62;
    ddp_entry_rec.col17 := p7_a63;
    ddp_entry_rec.col18 := p7_a64;
    ddp_entry_rec.col19 := p7_a65;
    ddp_entry_rec.col20 := p7_a66;
    ddp_entry_rec.col21 := p7_a67;
    ddp_entry_rec.col22 := p7_a68;
    ddp_entry_rec.col23 := p7_a69;
    ddp_entry_rec.col24 := p7_a70;
    ddp_entry_rec.col25 := p7_a71;
    ddp_entry_rec.col26 := p7_a72;
    ddp_entry_rec.col27 := p7_a73;
    ddp_entry_rec.col28 := p7_a74;
    ddp_entry_rec.col29 := p7_a75;
    ddp_entry_rec.col30 := p7_a76;
    ddp_entry_rec.col31 := p7_a77;
    ddp_entry_rec.col32 := p7_a78;
    ddp_entry_rec.col33 := p7_a79;
    ddp_entry_rec.col34 := p7_a80;
    ddp_entry_rec.col35 := p7_a81;
    ddp_entry_rec.col36 := p7_a82;
    ddp_entry_rec.col37 := p7_a83;
    ddp_entry_rec.col38 := p7_a84;
    ddp_entry_rec.col39 := p7_a85;
    ddp_entry_rec.col40 := p7_a86;
    ddp_entry_rec.col41 := p7_a87;
    ddp_entry_rec.col42 := p7_a88;
    ddp_entry_rec.col43 := p7_a89;
    ddp_entry_rec.col44 := p7_a90;
    ddp_entry_rec.col45 := p7_a91;
    ddp_entry_rec.col46 := p7_a92;
    ddp_entry_rec.col47 := p7_a93;
    ddp_entry_rec.col48 := p7_a94;
    ddp_entry_rec.col49 := p7_a95;
    ddp_entry_rec.col50 := p7_a96;
    ddp_entry_rec.col51 := p7_a97;
    ddp_entry_rec.col52 := p7_a98;
    ddp_entry_rec.col53 := p7_a99;
    ddp_entry_rec.col54 := p7_a100;
    ddp_entry_rec.col55 := p7_a101;
    ddp_entry_rec.col56 := p7_a102;
    ddp_entry_rec.col57 := p7_a103;
    ddp_entry_rec.col58 := p7_a104;
    ddp_entry_rec.col59 := p7_a105;
    ddp_entry_rec.col60 := p7_a106;
    ddp_entry_rec.col61 := p7_a107;
    ddp_entry_rec.col62 := p7_a108;
    ddp_entry_rec.col63 := p7_a109;
    ddp_entry_rec.col64 := p7_a110;
    ddp_entry_rec.col65 := p7_a111;
    ddp_entry_rec.col66 := p7_a112;
    ddp_entry_rec.col67 := p7_a113;
    ddp_entry_rec.col68 := p7_a114;
    ddp_entry_rec.col69 := p7_a115;
    ddp_entry_rec.col70 := p7_a116;
    ddp_entry_rec.col71 := p7_a117;
    ddp_entry_rec.col72 := p7_a118;
    ddp_entry_rec.col73 := p7_a119;
    ddp_entry_rec.col74 := p7_a120;
    ddp_entry_rec.col75 := p7_a121;
    ddp_entry_rec.col76 := p7_a122;
    ddp_entry_rec.col77 := p7_a123;
    ddp_entry_rec.col78 := p7_a124;
    ddp_entry_rec.col79 := p7_a125;
    ddp_entry_rec.col80 := p7_a126;
    ddp_entry_rec.col81 := p7_a127;
    ddp_entry_rec.col82 := p7_a128;
    ddp_entry_rec.col83 := p7_a129;
    ddp_entry_rec.col84 := p7_a130;
    ddp_entry_rec.col85 := p7_a131;
    ddp_entry_rec.col86 := p7_a132;
    ddp_entry_rec.col87 := p7_a133;
    ddp_entry_rec.col88 := p7_a134;
    ddp_entry_rec.col89 := p7_a135;
    ddp_entry_rec.col90 := p7_a136;
    ddp_entry_rec.col91 := p7_a137;
    ddp_entry_rec.col92 := p7_a138;
    ddp_entry_rec.col93 := p7_a139;
    ddp_entry_rec.col94 := p7_a140;
    ddp_entry_rec.col95 := p7_a141;
    ddp_entry_rec.col96 := p7_a142;
    ddp_entry_rec.col97 := p7_a143;
    ddp_entry_rec.col98 := p7_a144;
    ddp_entry_rec.col99 := p7_a145;
    ddp_entry_rec.col100 := p7_a146;
    ddp_entry_rec.col101 := p7_a147;
    ddp_entry_rec.col102 := p7_a148;
    ddp_entry_rec.col103 := p7_a149;
    ddp_entry_rec.col104 := p7_a150;
    ddp_entry_rec.col105 := p7_a151;
    ddp_entry_rec.col106 := p7_a152;
    ddp_entry_rec.col107 := p7_a153;
    ddp_entry_rec.col108 := p7_a154;
    ddp_entry_rec.col109 := p7_a155;
    ddp_entry_rec.col110 := p7_a156;
    ddp_entry_rec.col111 := p7_a157;
    ddp_entry_rec.col112 := p7_a158;
    ddp_entry_rec.col113 := p7_a159;
    ddp_entry_rec.col114 := p7_a160;
    ddp_entry_rec.col115 := p7_a161;
    ddp_entry_rec.col116 := p7_a162;
    ddp_entry_rec.col117 := p7_a163;
    ddp_entry_rec.col118 := p7_a164;
    ddp_entry_rec.col119 := p7_a165;
    ddp_entry_rec.col120 := p7_a166;
    ddp_entry_rec.col121 := p7_a167;
    ddp_entry_rec.col122 := p7_a168;
    ddp_entry_rec.col123 := p7_a169;
    ddp_entry_rec.col124 := p7_a170;
    ddp_entry_rec.col125 := p7_a171;
    ddp_entry_rec.col126 := p7_a172;
    ddp_entry_rec.col127 := p7_a173;
    ddp_entry_rec.col128 := p7_a174;
    ddp_entry_rec.col129 := p7_a175;
    ddp_entry_rec.col130 := p7_a176;
    ddp_entry_rec.col131 := p7_a177;
    ddp_entry_rec.col132 := p7_a178;
    ddp_entry_rec.col133 := p7_a179;
    ddp_entry_rec.col134 := p7_a180;
    ddp_entry_rec.col135 := p7_a181;
    ddp_entry_rec.col136 := p7_a182;
    ddp_entry_rec.col137 := p7_a183;
    ddp_entry_rec.col138 := p7_a184;
    ddp_entry_rec.col139 := p7_a185;
    ddp_entry_rec.col140 := p7_a186;
    ddp_entry_rec.col141 := p7_a187;
    ddp_entry_rec.col142 := p7_a188;
    ddp_entry_rec.col143 := p7_a189;
    ddp_entry_rec.col144 := p7_a190;
    ddp_entry_rec.col145 := p7_a191;
    ddp_entry_rec.col146 := p7_a192;
    ddp_entry_rec.col147 := p7_a193;
    ddp_entry_rec.col148 := p7_a194;
    ddp_entry_rec.col149 := p7_a195;
    ddp_entry_rec.col150 := p7_a196;
    ddp_entry_rec.col151 := p7_a197;
    ddp_entry_rec.col152 := p7_a198;
    ddp_entry_rec.col153 := p7_a199;
    ddp_entry_rec.col154 := p7_a200;
    ddp_entry_rec.col155 := p7_a201;
    ddp_entry_rec.col156 := p7_a202;
    ddp_entry_rec.col157 := p7_a203;
    ddp_entry_rec.col158 := p7_a204;
    ddp_entry_rec.col159 := p7_a205;
    ddp_entry_rec.col160 := p7_a206;
    ddp_entry_rec.col161 := p7_a207;
    ddp_entry_rec.col162 := p7_a208;
    ddp_entry_rec.col163 := p7_a209;
    ddp_entry_rec.col164 := p7_a210;
    ddp_entry_rec.col165 := p7_a211;
    ddp_entry_rec.col166 := p7_a212;
    ddp_entry_rec.col167 := p7_a213;
    ddp_entry_rec.col168 := p7_a214;
    ddp_entry_rec.col169 := p7_a215;
    ddp_entry_rec.col170 := p7_a216;
    ddp_entry_rec.col171 := p7_a217;
    ddp_entry_rec.col172 := p7_a218;
    ddp_entry_rec.col173 := p7_a219;
    ddp_entry_rec.col174 := p7_a220;
    ddp_entry_rec.col175 := p7_a221;
    ddp_entry_rec.col176 := p7_a222;
    ddp_entry_rec.col177 := p7_a223;
    ddp_entry_rec.col178 := p7_a224;
    ddp_entry_rec.col179 := p7_a225;
    ddp_entry_rec.col180 := p7_a226;
    ddp_entry_rec.col181 := p7_a227;
    ddp_entry_rec.col182 := p7_a228;
    ddp_entry_rec.col183 := p7_a229;
    ddp_entry_rec.col184 := p7_a230;
    ddp_entry_rec.col185 := p7_a231;
    ddp_entry_rec.col186 := p7_a232;
    ddp_entry_rec.col187 := p7_a233;
    ddp_entry_rec.col188 := p7_a234;
    ddp_entry_rec.col189 := p7_a235;
    ddp_entry_rec.col190 := p7_a236;
    ddp_entry_rec.col191 := p7_a237;
    ddp_entry_rec.col192 := p7_a238;
    ddp_entry_rec.col193 := p7_a239;
    ddp_entry_rec.col194 := p7_a240;
    ddp_entry_rec.col195 := p7_a241;
    ddp_entry_rec.col196 := p7_a242;
    ddp_entry_rec.col197 := p7_a243;
    ddp_entry_rec.col198 := p7_a244;
    ddp_entry_rec.col199 := p7_a245;
    ddp_entry_rec.col200 := p7_a246;
    ddp_entry_rec.col201 := p7_a247;
    ddp_entry_rec.col202 := p7_a248;
    ddp_entry_rec.col203 := p7_a249;
    ddp_entry_rec.col204 := p7_a250;
    ddp_entry_rec.col205 := p7_a251;
    ddp_entry_rec.col206 := p7_a252;
    ddp_entry_rec.col207 := p7_a253;
    ddp_entry_rec.col208 := p7_a254;
    ddp_entry_rec.col209 := p7_a255;
    ddp_entry_rec.col210 := p7_a256;
    ddp_entry_rec.col211 := p7_a257;
    ddp_entry_rec.col212 := p7_a258;
    ddp_entry_rec.col213 := p7_a259;
    ddp_entry_rec.col214 := p7_a260;
    ddp_entry_rec.col215 := p7_a261;
    ddp_entry_rec.col216 := p7_a262;
    ddp_entry_rec.col217 := p7_a263;
    ddp_entry_rec.col218 := p7_a264;
    ddp_entry_rec.col219 := p7_a265;
    ddp_entry_rec.col220 := p7_a266;
    ddp_entry_rec.col221 := p7_a267;
    ddp_entry_rec.col222 := p7_a268;
    ddp_entry_rec.col223 := p7_a269;
    ddp_entry_rec.col224 := p7_a270;
    ddp_entry_rec.col225 := p7_a271;
    ddp_entry_rec.col226 := p7_a272;
    ddp_entry_rec.col227 := p7_a273;
    ddp_entry_rec.col228 := p7_a274;
    ddp_entry_rec.col229 := p7_a275;
    ddp_entry_rec.col230 := p7_a276;
    ddp_entry_rec.col231 := p7_a277;
    ddp_entry_rec.col232 := p7_a278;
    ddp_entry_rec.col233 := p7_a279;
    ddp_entry_rec.col234 := p7_a280;
    ddp_entry_rec.col235 := p7_a281;
    ddp_entry_rec.col236 := p7_a282;
    ddp_entry_rec.col237 := p7_a283;
    ddp_entry_rec.col238 := p7_a284;
    ddp_entry_rec.col239 := p7_a285;
    ddp_entry_rec.col240 := p7_a286;
    ddp_entry_rec.col241 := p7_a287;
    ddp_entry_rec.col242 := p7_a288;
    ddp_entry_rec.col243 := p7_a289;
    ddp_entry_rec.col244 := p7_a290;
    ddp_entry_rec.col245 := p7_a291;
    ddp_entry_rec.col246 := p7_a292;
    ddp_entry_rec.col247 := p7_a293;
    ddp_entry_rec.col248 := p7_a294;
    ddp_entry_rec.col249 := p7_a295;
    ddp_entry_rec.col250 := p7_a296;
    ddp_entry_rec.col251 := p7_a297;
    ddp_entry_rec.col252 := p7_a298;
    ddp_entry_rec.col253 := p7_a299;
    ddp_entry_rec.col254 := p7_a300;
    ddp_entry_rec.col255 := p7_a301;
    ddp_entry_rec.col256 := p7_a302;
    ddp_entry_rec.col257 := p7_a303;
    ddp_entry_rec.col258 := p7_a304;
    ddp_entry_rec.col259 := p7_a305;
    ddp_entry_rec.col260 := p7_a306;
    ddp_entry_rec.col261 := p7_a307;
    ddp_entry_rec.col262 := p7_a308;
    ddp_entry_rec.col263 := p7_a309;
    ddp_entry_rec.col264 := p7_a310;
    ddp_entry_rec.col265 := p7_a311;
    ddp_entry_rec.col266 := p7_a312;
    ddp_entry_rec.col267 := p7_a313;
    ddp_entry_rec.col268 := p7_a314;
    ddp_entry_rec.col269 := p7_a315;
    ddp_entry_rec.col270 := p7_a316;
    ddp_entry_rec.col271 := p7_a317;
    ddp_entry_rec.col272 := p7_a318;
    ddp_entry_rec.col273 := p7_a319;
    ddp_entry_rec.col274 := p7_a320;
    ddp_entry_rec.col275 := p7_a321;
    ddp_entry_rec.col276 := p7_a322;
    ddp_entry_rec.col277 := p7_a323;
    ddp_entry_rec.col278 := p7_a324;
    ddp_entry_rec.col279 := p7_a325;
    ddp_entry_rec.col280 := p7_a326;
    ddp_entry_rec.col281 := p7_a327;
    ddp_entry_rec.col282 := p7_a328;
    ddp_entry_rec.col283 := p7_a329;
    ddp_entry_rec.col284 := p7_a330;
    ddp_entry_rec.col285 := p7_a331;
    ddp_entry_rec.col286 := p7_a332;
    ddp_entry_rec.col287 := p7_a333;
    ddp_entry_rec.col288 := p7_a334;
    ddp_entry_rec.col289 := p7_a335;
    ddp_entry_rec.col290 := p7_a336;
    ddp_entry_rec.col291 := p7_a337;
    ddp_entry_rec.col292 := p7_a338;
    ddp_entry_rec.col293 := p7_a339;
    ddp_entry_rec.col294 := p7_a340;
    ddp_entry_rec.col295 := p7_a341;
    ddp_entry_rec.col296 := p7_a342;
    ddp_entry_rec.col297 := p7_a343;
    ddp_entry_rec.col298 := p7_a344;
    ddp_entry_rec.col299 := p7_a345;
    ddp_entry_rec.col300 := p7_a346;
    ddp_entry_rec.address_line1 := p7_a347;
    ddp_entry_rec.address_line2 := p7_a348;
    ddp_entry_rec.callback_flag := p7_a349;
    ddp_entry_rec.city := p7_a350;
    ddp_entry_rec.country := p7_a351;
    ddp_entry_rec.do_not_use_flag := p7_a352;
    ddp_entry_rec.do_not_use_reason := p7_a353;
    ddp_entry_rec.email_address := p7_a354;
    ddp_entry_rec.fax := p7_a355;
    ddp_entry_rec.phone := p7_a356;
    ddp_entry_rec.record_out_flag := p7_a357;
    ddp_entry_rec.state := p7_a358;
    ddp_entry_rec.suffix := p7_a359;
    ddp_entry_rec.title := p7_a360;
    ddp_entry_rec.usage_restriction := p7_a361;
    ddp_entry_rec.zipcode := p7_a362;
    ddp_entry_rec.curr_cp_country_code := p7_a363;
    ddp_entry_rec.curr_cp_phone_number := p7_a364;
    ddp_entry_rec.curr_cp_raw_phone_number := p7_a365;
    ddp_entry_rec.curr_cp_area_code := rosetta_g_miss_num_map(p7_a366);
    ddp_entry_rec.curr_cp_id := rosetta_g_miss_num_map(p7_a367);
    ddp_entry_rec.curr_cp_index := rosetta_g_miss_num_map(p7_a368);
    ddp_entry_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p7_a369);
    ddp_entry_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p7_a370);
    ddp_entry_rec.imp_source_line_id := rosetta_g_miss_num_map(p7_a371);
    ddp_entry_rec.next_call_time := rosetta_g_miss_date_in_map(p7_a372);
    ddp_entry_rec.record_release_time := rosetta_g_miss_date_in_map(p7_a373);
    ddp_entry_rec.party_id := rosetta_g_miss_num_map(p7_a374);
    ddp_entry_rec.parent_party_id := rosetta_g_miss_num_map(p7_a375);

    -- here's the delegated call to the old PL/SQL routine
    ams_listentry_pub.update_listentry(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entry_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_listentry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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
    , p6_a258  VARCHAR2 := fnd_api.g_miss_char
    , p6_a259  VARCHAR2 := fnd_api.g_miss_char
    , p6_a260  VARCHAR2 := fnd_api.g_miss_char
    , p6_a261  VARCHAR2 := fnd_api.g_miss_char
    , p6_a262  VARCHAR2 := fnd_api.g_miss_char
    , p6_a263  VARCHAR2 := fnd_api.g_miss_char
    , p6_a264  VARCHAR2 := fnd_api.g_miss_char
    , p6_a265  VARCHAR2 := fnd_api.g_miss_char
    , p6_a266  VARCHAR2 := fnd_api.g_miss_char
    , p6_a267  VARCHAR2 := fnd_api.g_miss_char
    , p6_a268  VARCHAR2 := fnd_api.g_miss_char
    , p6_a269  VARCHAR2 := fnd_api.g_miss_char
    , p6_a270  VARCHAR2 := fnd_api.g_miss_char
    , p6_a271  VARCHAR2 := fnd_api.g_miss_char
    , p6_a272  VARCHAR2 := fnd_api.g_miss_char
    , p6_a273  VARCHAR2 := fnd_api.g_miss_char
    , p6_a274  VARCHAR2 := fnd_api.g_miss_char
    , p6_a275  VARCHAR2 := fnd_api.g_miss_char
    , p6_a276  VARCHAR2 := fnd_api.g_miss_char
    , p6_a277  VARCHAR2 := fnd_api.g_miss_char
    , p6_a278  VARCHAR2 := fnd_api.g_miss_char
    , p6_a279  VARCHAR2 := fnd_api.g_miss_char
    , p6_a280  VARCHAR2 := fnd_api.g_miss_char
    , p6_a281  VARCHAR2 := fnd_api.g_miss_char
    , p6_a282  VARCHAR2 := fnd_api.g_miss_char
    , p6_a283  VARCHAR2 := fnd_api.g_miss_char
    , p6_a284  VARCHAR2 := fnd_api.g_miss_char
    , p6_a285  VARCHAR2 := fnd_api.g_miss_char
    , p6_a286  VARCHAR2 := fnd_api.g_miss_char
    , p6_a287  VARCHAR2 := fnd_api.g_miss_char
    , p6_a288  VARCHAR2 := fnd_api.g_miss_char
    , p6_a289  VARCHAR2 := fnd_api.g_miss_char
    , p6_a290  VARCHAR2 := fnd_api.g_miss_char
    , p6_a291  VARCHAR2 := fnd_api.g_miss_char
    , p6_a292  VARCHAR2 := fnd_api.g_miss_char
    , p6_a293  VARCHAR2 := fnd_api.g_miss_char
    , p6_a294  VARCHAR2 := fnd_api.g_miss_char
    , p6_a295  VARCHAR2 := fnd_api.g_miss_char
    , p6_a296  VARCHAR2 := fnd_api.g_miss_char
    , p6_a297  VARCHAR2 := fnd_api.g_miss_char
    , p6_a298  VARCHAR2 := fnd_api.g_miss_char
    , p6_a299  VARCHAR2 := fnd_api.g_miss_char
    , p6_a300  VARCHAR2 := fnd_api.g_miss_char
    , p6_a301  VARCHAR2 := fnd_api.g_miss_char
    , p6_a302  VARCHAR2 := fnd_api.g_miss_char
    , p6_a303  VARCHAR2 := fnd_api.g_miss_char
    , p6_a304  VARCHAR2 := fnd_api.g_miss_char
    , p6_a305  VARCHAR2 := fnd_api.g_miss_char
    , p6_a306  VARCHAR2 := fnd_api.g_miss_char
    , p6_a307  VARCHAR2 := fnd_api.g_miss_char
    , p6_a308  VARCHAR2 := fnd_api.g_miss_char
    , p6_a309  VARCHAR2 := fnd_api.g_miss_char
    , p6_a310  VARCHAR2 := fnd_api.g_miss_char
    , p6_a311  VARCHAR2 := fnd_api.g_miss_char
    , p6_a312  VARCHAR2 := fnd_api.g_miss_char
    , p6_a313  VARCHAR2 := fnd_api.g_miss_char
    , p6_a314  VARCHAR2 := fnd_api.g_miss_char
    , p6_a315  VARCHAR2 := fnd_api.g_miss_char
    , p6_a316  VARCHAR2 := fnd_api.g_miss_char
    , p6_a317  VARCHAR2 := fnd_api.g_miss_char
    , p6_a318  VARCHAR2 := fnd_api.g_miss_char
    , p6_a319  VARCHAR2 := fnd_api.g_miss_char
    , p6_a320  VARCHAR2 := fnd_api.g_miss_char
    , p6_a321  VARCHAR2 := fnd_api.g_miss_char
    , p6_a322  VARCHAR2 := fnd_api.g_miss_char
    , p6_a323  VARCHAR2 := fnd_api.g_miss_char
    , p6_a324  VARCHAR2 := fnd_api.g_miss_char
    , p6_a325  VARCHAR2 := fnd_api.g_miss_char
    , p6_a326  VARCHAR2 := fnd_api.g_miss_char
    , p6_a327  VARCHAR2 := fnd_api.g_miss_char
    , p6_a328  VARCHAR2 := fnd_api.g_miss_char
    , p6_a329  VARCHAR2 := fnd_api.g_miss_char
    , p6_a330  VARCHAR2 := fnd_api.g_miss_char
    , p6_a331  VARCHAR2 := fnd_api.g_miss_char
    , p6_a332  VARCHAR2 := fnd_api.g_miss_char
    , p6_a333  VARCHAR2 := fnd_api.g_miss_char
    , p6_a334  VARCHAR2 := fnd_api.g_miss_char
    , p6_a335  VARCHAR2 := fnd_api.g_miss_char
    , p6_a336  VARCHAR2 := fnd_api.g_miss_char
    , p6_a337  VARCHAR2 := fnd_api.g_miss_char
    , p6_a338  VARCHAR2 := fnd_api.g_miss_char
    , p6_a339  VARCHAR2 := fnd_api.g_miss_char
    , p6_a340  VARCHAR2 := fnd_api.g_miss_char
    , p6_a341  VARCHAR2 := fnd_api.g_miss_char
    , p6_a342  VARCHAR2 := fnd_api.g_miss_char
    , p6_a343  VARCHAR2 := fnd_api.g_miss_char
    , p6_a344  VARCHAR2 := fnd_api.g_miss_char
    , p6_a345  VARCHAR2 := fnd_api.g_miss_char
    , p6_a346  VARCHAR2 := fnd_api.g_miss_char
    , p6_a347  VARCHAR2 := fnd_api.g_miss_char
    , p6_a348  VARCHAR2 := fnd_api.g_miss_char
    , p6_a349  VARCHAR2 := fnd_api.g_miss_char
    , p6_a350  VARCHAR2 := fnd_api.g_miss_char
    , p6_a351  VARCHAR2 := fnd_api.g_miss_char
    , p6_a352  VARCHAR2 := fnd_api.g_miss_char
    , p6_a353  VARCHAR2 := fnd_api.g_miss_char
    , p6_a354  VARCHAR2 := fnd_api.g_miss_char
    , p6_a355  VARCHAR2 := fnd_api.g_miss_char
    , p6_a356  VARCHAR2 := fnd_api.g_miss_char
    , p6_a357  VARCHAR2 := fnd_api.g_miss_char
    , p6_a358  VARCHAR2 := fnd_api.g_miss_char
    , p6_a359  VARCHAR2 := fnd_api.g_miss_char
    , p6_a360  VARCHAR2 := fnd_api.g_miss_char
    , p6_a361  VARCHAR2 := fnd_api.g_miss_char
    , p6_a362  VARCHAR2 := fnd_api.g_miss_char
    , p6_a363  VARCHAR2 := fnd_api.g_miss_char
    , p6_a364  VARCHAR2 := fnd_api.g_miss_char
    , p6_a365  VARCHAR2 := fnd_api.g_miss_char
    , p6_a366  NUMBER := 0-1962.0724
    , p6_a367  NUMBER := 0-1962.0724
    , p6_a368  NUMBER := 0-1962.0724
    , p6_a369  NUMBER := 0-1962.0724
    , p6_a370  NUMBER := 0-1962.0724
    , p6_a371  NUMBER := 0-1962.0724
    , p6_a372  DATE := fnd_api.g_miss_date
    , p6_a373  DATE := fnd_api.g_miss_date
    , p6_a374  NUMBER := 0-1962.0724
    , p6_a375  NUMBER := 0-1962.0724
  )
  as
    ddp_entry_rec ams_listentry_pvt.entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_entry_rec.list_entry_id := rosetta_g_miss_num_map(p6_a0);
    ddp_entry_rec.list_header_id := rosetta_g_miss_num_map(p6_a1);
    ddp_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_entry_rec.last_updated_by := rosetta_g_miss_num_map(p6_a3);
    ddp_entry_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_entry_rec.created_by := rosetta_g_miss_num_map(p6_a5);
    ddp_entry_rec.last_update_login := rosetta_g_miss_num_map(p6_a6);
    ddp_entry_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_entry_rec.list_select_action_id := rosetta_g_miss_num_map(p6_a8);
    ddp_entry_rec.arc_list_select_action_from := p6_a9;
    ddp_entry_rec.list_select_action_from_name := p6_a10;
    ddp_entry_rec.source_code := p6_a11;
    ddp_entry_rec.arc_list_used_by_source := p6_a12;
    ddp_entry_rec.source_code_for_id := rosetta_g_miss_num_map(p6_a13);
    ddp_entry_rec.pin_code := p6_a14;
    ddp_entry_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p6_a15);
    ddp_entry_rec.list_entry_source_system_type := p6_a16;
    ddp_entry_rec.view_application_id := rosetta_g_miss_num_map(p6_a17);
    ddp_entry_rec.manually_entered_flag := p6_a18;
    ddp_entry_rec.marked_as_duplicate_flag := p6_a19;
    ddp_entry_rec.marked_as_random_flag := p6_a20;
    ddp_entry_rec.part_of_control_group_flag := p6_a21;
    ddp_entry_rec.exclude_in_triggered_list_flag := p6_a22;
    ddp_entry_rec.enabled_flag := p6_a23;
    ddp_entry_rec.cell_code := p6_a24;
    ddp_entry_rec.dedupe_key := p6_a25;
    ddp_entry_rec.randomly_generated_number := rosetta_g_miss_num_map(p6_a26);
    ddp_entry_rec.campaign_id := rosetta_g_miss_num_map(p6_a27);
    ddp_entry_rec.media_id := rosetta_g_miss_num_map(p6_a28);
    ddp_entry_rec.channel_id := rosetta_g_miss_num_map(p6_a29);
    ddp_entry_rec.channel_schedule_id := rosetta_g_miss_num_map(p6_a30);
    ddp_entry_rec.event_offer_id := rosetta_g_miss_num_map(p6_a31);
    ddp_entry_rec.customer_id := rosetta_g_miss_num_map(p6_a32);
    ddp_entry_rec.market_segment_id := rosetta_g_miss_num_map(p6_a33);
    ddp_entry_rec.vendor_id := rosetta_g_miss_num_map(p6_a34);
    ddp_entry_rec.transfer_flag := p6_a35;
    ddp_entry_rec.transfer_status := p6_a36;
    ddp_entry_rec.list_source := p6_a37;
    ddp_entry_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p6_a38);
    ddp_entry_rec.marked_flag := p6_a39;
    ddp_entry_rec.lead_id := rosetta_g_miss_num_map(p6_a40);
    ddp_entry_rec.letter_id := rosetta_g_miss_num_map(p6_a41);
    ddp_entry_rec.picking_header_id := rosetta_g_miss_num_map(p6_a42);
    ddp_entry_rec.batch_id := rosetta_g_miss_num_map(p6_a43);
    ddp_entry_rec.first_name := p6_a44;
    ddp_entry_rec.last_name := p6_a45;
    ddp_entry_rec.customer_name := p6_a46;
    ddp_entry_rec.col1 := p6_a47;
    ddp_entry_rec.col2 := p6_a48;
    ddp_entry_rec.col3 := p6_a49;
    ddp_entry_rec.col4 := p6_a50;
    ddp_entry_rec.col5 := p6_a51;
    ddp_entry_rec.col6 := p6_a52;
    ddp_entry_rec.col7 := p6_a53;
    ddp_entry_rec.col8 := p6_a54;
    ddp_entry_rec.col9 := p6_a55;
    ddp_entry_rec.col10 := p6_a56;
    ddp_entry_rec.col11 := p6_a57;
    ddp_entry_rec.col12 := p6_a58;
    ddp_entry_rec.col13 := p6_a59;
    ddp_entry_rec.col14 := p6_a60;
    ddp_entry_rec.col15 := p6_a61;
    ddp_entry_rec.col16 := p6_a62;
    ddp_entry_rec.col17 := p6_a63;
    ddp_entry_rec.col18 := p6_a64;
    ddp_entry_rec.col19 := p6_a65;
    ddp_entry_rec.col20 := p6_a66;
    ddp_entry_rec.col21 := p6_a67;
    ddp_entry_rec.col22 := p6_a68;
    ddp_entry_rec.col23 := p6_a69;
    ddp_entry_rec.col24 := p6_a70;
    ddp_entry_rec.col25 := p6_a71;
    ddp_entry_rec.col26 := p6_a72;
    ddp_entry_rec.col27 := p6_a73;
    ddp_entry_rec.col28 := p6_a74;
    ddp_entry_rec.col29 := p6_a75;
    ddp_entry_rec.col30 := p6_a76;
    ddp_entry_rec.col31 := p6_a77;
    ddp_entry_rec.col32 := p6_a78;
    ddp_entry_rec.col33 := p6_a79;
    ddp_entry_rec.col34 := p6_a80;
    ddp_entry_rec.col35 := p6_a81;
    ddp_entry_rec.col36 := p6_a82;
    ddp_entry_rec.col37 := p6_a83;
    ddp_entry_rec.col38 := p6_a84;
    ddp_entry_rec.col39 := p6_a85;
    ddp_entry_rec.col40 := p6_a86;
    ddp_entry_rec.col41 := p6_a87;
    ddp_entry_rec.col42 := p6_a88;
    ddp_entry_rec.col43 := p6_a89;
    ddp_entry_rec.col44 := p6_a90;
    ddp_entry_rec.col45 := p6_a91;
    ddp_entry_rec.col46 := p6_a92;
    ddp_entry_rec.col47 := p6_a93;
    ddp_entry_rec.col48 := p6_a94;
    ddp_entry_rec.col49 := p6_a95;
    ddp_entry_rec.col50 := p6_a96;
    ddp_entry_rec.col51 := p6_a97;
    ddp_entry_rec.col52 := p6_a98;
    ddp_entry_rec.col53 := p6_a99;
    ddp_entry_rec.col54 := p6_a100;
    ddp_entry_rec.col55 := p6_a101;
    ddp_entry_rec.col56 := p6_a102;
    ddp_entry_rec.col57 := p6_a103;
    ddp_entry_rec.col58 := p6_a104;
    ddp_entry_rec.col59 := p6_a105;
    ddp_entry_rec.col60 := p6_a106;
    ddp_entry_rec.col61 := p6_a107;
    ddp_entry_rec.col62 := p6_a108;
    ddp_entry_rec.col63 := p6_a109;
    ddp_entry_rec.col64 := p6_a110;
    ddp_entry_rec.col65 := p6_a111;
    ddp_entry_rec.col66 := p6_a112;
    ddp_entry_rec.col67 := p6_a113;
    ddp_entry_rec.col68 := p6_a114;
    ddp_entry_rec.col69 := p6_a115;
    ddp_entry_rec.col70 := p6_a116;
    ddp_entry_rec.col71 := p6_a117;
    ddp_entry_rec.col72 := p6_a118;
    ddp_entry_rec.col73 := p6_a119;
    ddp_entry_rec.col74 := p6_a120;
    ddp_entry_rec.col75 := p6_a121;
    ddp_entry_rec.col76 := p6_a122;
    ddp_entry_rec.col77 := p6_a123;
    ddp_entry_rec.col78 := p6_a124;
    ddp_entry_rec.col79 := p6_a125;
    ddp_entry_rec.col80 := p6_a126;
    ddp_entry_rec.col81 := p6_a127;
    ddp_entry_rec.col82 := p6_a128;
    ddp_entry_rec.col83 := p6_a129;
    ddp_entry_rec.col84 := p6_a130;
    ddp_entry_rec.col85 := p6_a131;
    ddp_entry_rec.col86 := p6_a132;
    ddp_entry_rec.col87 := p6_a133;
    ddp_entry_rec.col88 := p6_a134;
    ddp_entry_rec.col89 := p6_a135;
    ddp_entry_rec.col90 := p6_a136;
    ddp_entry_rec.col91 := p6_a137;
    ddp_entry_rec.col92 := p6_a138;
    ddp_entry_rec.col93 := p6_a139;
    ddp_entry_rec.col94 := p6_a140;
    ddp_entry_rec.col95 := p6_a141;
    ddp_entry_rec.col96 := p6_a142;
    ddp_entry_rec.col97 := p6_a143;
    ddp_entry_rec.col98 := p6_a144;
    ddp_entry_rec.col99 := p6_a145;
    ddp_entry_rec.col100 := p6_a146;
    ddp_entry_rec.col101 := p6_a147;
    ddp_entry_rec.col102 := p6_a148;
    ddp_entry_rec.col103 := p6_a149;
    ddp_entry_rec.col104 := p6_a150;
    ddp_entry_rec.col105 := p6_a151;
    ddp_entry_rec.col106 := p6_a152;
    ddp_entry_rec.col107 := p6_a153;
    ddp_entry_rec.col108 := p6_a154;
    ddp_entry_rec.col109 := p6_a155;
    ddp_entry_rec.col110 := p6_a156;
    ddp_entry_rec.col111 := p6_a157;
    ddp_entry_rec.col112 := p6_a158;
    ddp_entry_rec.col113 := p6_a159;
    ddp_entry_rec.col114 := p6_a160;
    ddp_entry_rec.col115 := p6_a161;
    ddp_entry_rec.col116 := p6_a162;
    ddp_entry_rec.col117 := p6_a163;
    ddp_entry_rec.col118 := p6_a164;
    ddp_entry_rec.col119 := p6_a165;
    ddp_entry_rec.col120 := p6_a166;
    ddp_entry_rec.col121 := p6_a167;
    ddp_entry_rec.col122 := p6_a168;
    ddp_entry_rec.col123 := p6_a169;
    ddp_entry_rec.col124 := p6_a170;
    ddp_entry_rec.col125 := p6_a171;
    ddp_entry_rec.col126 := p6_a172;
    ddp_entry_rec.col127 := p6_a173;
    ddp_entry_rec.col128 := p6_a174;
    ddp_entry_rec.col129 := p6_a175;
    ddp_entry_rec.col130 := p6_a176;
    ddp_entry_rec.col131 := p6_a177;
    ddp_entry_rec.col132 := p6_a178;
    ddp_entry_rec.col133 := p6_a179;
    ddp_entry_rec.col134 := p6_a180;
    ddp_entry_rec.col135 := p6_a181;
    ddp_entry_rec.col136 := p6_a182;
    ddp_entry_rec.col137 := p6_a183;
    ddp_entry_rec.col138 := p6_a184;
    ddp_entry_rec.col139 := p6_a185;
    ddp_entry_rec.col140 := p6_a186;
    ddp_entry_rec.col141 := p6_a187;
    ddp_entry_rec.col142 := p6_a188;
    ddp_entry_rec.col143 := p6_a189;
    ddp_entry_rec.col144 := p6_a190;
    ddp_entry_rec.col145 := p6_a191;
    ddp_entry_rec.col146 := p6_a192;
    ddp_entry_rec.col147 := p6_a193;
    ddp_entry_rec.col148 := p6_a194;
    ddp_entry_rec.col149 := p6_a195;
    ddp_entry_rec.col150 := p6_a196;
    ddp_entry_rec.col151 := p6_a197;
    ddp_entry_rec.col152 := p6_a198;
    ddp_entry_rec.col153 := p6_a199;
    ddp_entry_rec.col154 := p6_a200;
    ddp_entry_rec.col155 := p6_a201;
    ddp_entry_rec.col156 := p6_a202;
    ddp_entry_rec.col157 := p6_a203;
    ddp_entry_rec.col158 := p6_a204;
    ddp_entry_rec.col159 := p6_a205;
    ddp_entry_rec.col160 := p6_a206;
    ddp_entry_rec.col161 := p6_a207;
    ddp_entry_rec.col162 := p6_a208;
    ddp_entry_rec.col163 := p6_a209;
    ddp_entry_rec.col164 := p6_a210;
    ddp_entry_rec.col165 := p6_a211;
    ddp_entry_rec.col166 := p6_a212;
    ddp_entry_rec.col167 := p6_a213;
    ddp_entry_rec.col168 := p6_a214;
    ddp_entry_rec.col169 := p6_a215;
    ddp_entry_rec.col170 := p6_a216;
    ddp_entry_rec.col171 := p6_a217;
    ddp_entry_rec.col172 := p6_a218;
    ddp_entry_rec.col173 := p6_a219;
    ddp_entry_rec.col174 := p6_a220;
    ddp_entry_rec.col175 := p6_a221;
    ddp_entry_rec.col176 := p6_a222;
    ddp_entry_rec.col177 := p6_a223;
    ddp_entry_rec.col178 := p6_a224;
    ddp_entry_rec.col179 := p6_a225;
    ddp_entry_rec.col180 := p6_a226;
    ddp_entry_rec.col181 := p6_a227;
    ddp_entry_rec.col182 := p6_a228;
    ddp_entry_rec.col183 := p6_a229;
    ddp_entry_rec.col184 := p6_a230;
    ddp_entry_rec.col185 := p6_a231;
    ddp_entry_rec.col186 := p6_a232;
    ddp_entry_rec.col187 := p6_a233;
    ddp_entry_rec.col188 := p6_a234;
    ddp_entry_rec.col189 := p6_a235;
    ddp_entry_rec.col190 := p6_a236;
    ddp_entry_rec.col191 := p6_a237;
    ddp_entry_rec.col192 := p6_a238;
    ddp_entry_rec.col193 := p6_a239;
    ddp_entry_rec.col194 := p6_a240;
    ddp_entry_rec.col195 := p6_a241;
    ddp_entry_rec.col196 := p6_a242;
    ddp_entry_rec.col197 := p6_a243;
    ddp_entry_rec.col198 := p6_a244;
    ddp_entry_rec.col199 := p6_a245;
    ddp_entry_rec.col200 := p6_a246;
    ddp_entry_rec.col201 := p6_a247;
    ddp_entry_rec.col202 := p6_a248;
    ddp_entry_rec.col203 := p6_a249;
    ddp_entry_rec.col204 := p6_a250;
    ddp_entry_rec.col205 := p6_a251;
    ddp_entry_rec.col206 := p6_a252;
    ddp_entry_rec.col207 := p6_a253;
    ddp_entry_rec.col208 := p6_a254;
    ddp_entry_rec.col209 := p6_a255;
    ddp_entry_rec.col210 := p6_a256;
    ddp_entry_rec.col211 := p6_a257;
    ddp_entry_rec.col212 := p6_a258;
    ddp_entry_rec.col213 := p6_a259;
    ddp_entry_rec.col214 := p6_a260;
    ddp_entry_rec.col215 := p6_a261;
    ddp_entry_rec.col216 := p6_a262;
    ddp_entry_rec.col217 := p6_a263;
    ddp_entry_rec.col218 := p6_a264;
    ddp_entry_rec.col219 := p6_a265;
    ddp_entry_rec.col220 := p6_a266;
    ddp_entry_rec.col221 := p6_a267;
    ddp_entry_rec.col222 := p6_a268;
    ddp_entry_rec.col223 := p6_a269;
    ddp_entry_rec.col224 := p6_a270;
    ddp_entry_rec.col225 := p6_a271;
    ddp_entry_rec.col226 := p6_a272;
    ddp_entry_rec.col227 := p6_a273;
    ddp_entry_rec.col228 := p6_a274;
    ddp_entry_rec.col229 := p6_a275;
    ddp_entry_rec.col230 := p6_a276;
    ddp_entry_rec.col231 := p6_a277;
    ddp_entry_rec.col232 := p6_a278;
    ddp_entry_rec.col233 := p6_a279;
    ddp_entry_rec.col234 := p6_a280;
    ddp_entry_rec.col235 := p6_a281;
    ddp_entry_rec.col236 := p6_a282;
    ddp_entry_rec.col237 := p6_a283;
    ddp_entry_rec.col238 := p6_a284;
    ddp_entry_rec.col239 := p6_a285;
    ddp_entry_rec.col240 := p6_a286;
    ddp_entry_rec.col241 := p6_a287;
    ddp_entry_rec.col242 := p6_a288;
    ddp_entry_rec.col243 := p6_a289;
    ddp_entry_rec.col244 := p6_a290;
    ddp_entry_rec.col245 := p6_a291;
    ddp_entry_rec.col246 := p6_a292;
    ddp_entry_rec.col247 := p6_a293;
    ddp_entry_rec.col248 := p6_a294;
    ddp_entry_rec.col249 := p6_a295;
    ddp_entry_rec.col250 := p6_a296;
    ddp_entry_rec.col251 := p6_a297;
    ddp_entry_rec.col252 := p6_a298;
    ddp_entry_rec.col253 := p6_a299;
    ddp_entry_rec.col254 := p6_a300;
    ddp_entry_rec.col255 := p6_a301;
    ddp_entry_rec.col256 := p6_a302;
    ddp_entry_rec.col257 := p6_a303;
    ddp_entry_rec.col258 := p6_a304;
    ddp_entry_rec.col259 := p6_a305;
    ddp_entry_rec.col260 := p6_a306;
    ddp_entry_rec.col261 := p6_a307;
    ddp_entry_rec.col262 := p6_a308;
    ddp_entry_rec.col263 := p6_a309;
    ddp_entry_rec.col264 := p6_a310;
    ddp_entry_rec.col265 := p6_a311;
    ddp_entry_rec.col266 := p6_a312;
    ddp_entry_rec.col267 := p6_a313;
    ddp_entry_rec.col268 := p6_a314;
    ddp_entry_rec.col269 := p6_a315;
    ddp_entry_rec.col270 := p6_a316;
    ddp_entry_rec.col271 := p6_a317;
    ddp_entry_rec.col272 := p6_a318;
    ddp_entry_rec.col273 := p6_a319;
    ddp_entry_rec.col274 := p6_a320;
    ddp_entry_rec.col275 := p6_a321;
    ddp_entry_rec.col276 := p6_a322;
    ddp_entry_rec.col277 := p6_a323;
    ddp_entry_rec.col278 := p6_a324;
    ddp_entry_rec.col279 := p6_a325;
    ddp_entry_rec.col280 := p6_a326;
    ddp_entry_rec.col281 := p6_a327;
    ddp_entry_rec.col282 := p6_a328;
    ddp_entry_rec.col283 := p6_a329;
    ddp_entry_rec.col284 := p6_a330;
    ddp_entry_rec.col285 := p6_a331;
    ddp_entry_rec.col286 := p6_a332;
    ddp_entry_rec.col287 := p6_a333;
    ddp_entry_rec.col288 := p6_a334;
    ddp_entry_rec.col289 := p6_a335;
    ddp_entry_rec.col290 := p6_a336;
    ddp_entry_rec.col291 := p6_a337;
    ddp_entry_rec.col292 := p6_a338;
    ddp_entry_rec.col293 := p6_a339;
    ddp_entry_rec.col294 := p6_a340;
    ddp_entry_rec.col295 := p6_a341;
    ddp_entry_rec.col296 := p6_a342;
    ddp_entry_rec.col297 := p6_a343;
    ddp_entry_rec.col298 := p6_a344;
    ddp_entry_rec.col299 := p6_a345;
    ddp_entry_rec.col300 := p6_a346;
    ddp_entry_rec.address_line1 := p6_a347;
    ddp_entry_rec.address_line2 := p6_a348;
    ddp_entry_rec.callback_flag := p6_a349;
    ddp_entry_rec.city := p6_a350;
    ddp_entry_rec.country := p6_a351;
    ddp_entry_rec.do_not_use_flag := p6_a352;
    ddp_entry_rec.do_not_use_reason := p6_a353;
    ddp_entry_rec.email_address := p6_a354;
    ddp_entry_rec.fax := p6_a355;
    ddp_entry_rec.phone := p6_a356;
    ddp_entry_rec.record_out_flag := p6_a357;
    ddp_entry_rec.state := p6_a358;
    ddp_entry_rec.suffix := p6_a359;
    ddp_entry_rec.title := p6_a360;
    ddp_entry_rec.usage_restriction := p6_a361;
    ddp_entry_rec.zipcode := p6_a362;
    ddp_entry_rec.curr_cp_country_code := p6_a363;
    ddp_entry_rec.curr_cp_phone_number := p6_a364;
    ddp_entry_rec.curr_cp_raw_phone_number := p6_a365;
    ddp_entry_rec.curr_cp_area_code := rosetta_g_miss_num_map(p6_a366);
    ddp_entry_rec.curr_cp_id := rosetta_g_miss_num_map(p6_a367);
    ddp_entry_rec.curr_cp_index := rosetta_g_miss_num_map(p6_a368);
    ddp_entry_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p6_a369);
    ddp_entry_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p6_a370);
    ddp_entry_rec.imp_source_line_id := rosetta_g_miss_num_map(p6_a371);
    ddp_entry_rec.next_call_time := rosetta_g_miss_date_in_map(p6_a372);
    ddp_entry_rec.record_release_time := rosetta_g_miss_date_in_map(p6_a373);
    ddp_entry_rec.party_id := rosetta_g_miss_num_map(p6_a374);
    ddp_entry_rec.parent_party_id := rosetta_g_miss_num_map(p6_a375);

    -- here's the delegated call to the old PL/SQL routine
    ams_listentry_pub.validate_listentry(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_entry_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure init_entry_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  NUMBER
    , p0_a2 OUT NOCOPY  DATE
    , p0_a3 OUT NOCOPY  NUMBER
    , p0_a4 OUT NOCOPY  DATE
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  NUMBER
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  NUMBER
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
    , p0_a26 OUT NOCOPY  NUMBER
    , p0_a27 OUT NOCOPY  NUMBER
    , p0_a28 OUT NOCOPY  NUMBER
    , p0_a29 OUT NOCOPY  NUMBER
    , p0_a30 OUT NOCOPY  NUMBER
    , p0_a31 OUT NOCOPY  NUMBER
    , p0_a32 OUT NOCOPY  NUMBER
    , p0_a33 OUT NOCOPY  NUMBER
    , p0_a34 OUT NOCOPY  NUMBER
    , p0_a35 OUT NOCOPY  VARCHAR2
    , p0_a36 OUT NOCOPY  VARCHAR2
    , p0_a37 OUT NOCOPY  VARCHAR2
    , p0_a38 OUT NOCOPY  NUMBER
    , p0_a39 OUT NOCOPY  VARCHAR2
    , p0_a40 OUT NOCOPY  NUMBER
    , p0_a41 OUT NOCOPY  NUMBER
    , p0_a42 OUT NOCOPY  NUMBER
    , p0_a43 OUT NOCOPY  NUMBER
    , p0_a44 OUT NOCOPY  VARCHAR2
    , p0_a45 OUT NOCOPY  VARCHAR2
    , p0_a46 OUT NOCOPY  VARCHAR2
    , p0_a47 OUT NOCOPY  VARCHAR2
    , p0_a48 OUT NOCOPY  VARCHAR2
    , p0_a49 OUT NOCOPY  VARCHAR2
    , p0_a50 OUT NOCOPY  VARCHAR2
    , p0_a51 OUT NOCOPY  VARCHAR2
    , p0_a52 OUT NOCOPY  VARCHAR2
    , p0_a53 OUT NOCOPY  VARCHAR2
    , p0_a54 OUT NOCOPY  VARCHAR2
    , p0_a55 OUT NOCOPY  VARCHAR2
    , p0_a56 OUT NOCOPY  VARCHAR2
    , p0_a57 OUT NOCOPY  VARCHAR2
    , p0_a58 OUT NOCOPY  VARCHAR2
    , p0_a59 OUT NOCOPY  VARCHAR2
    , p0_a60 OUT NOCOPY  VARCHAR2
    , p0_a61 OUT NOCOPY  VARCHAR2
    , p0_a62 OUT NOCOPY  VARCHAR2
    , p0_a63 OUT NOCOPY  VARCHAR2
    , p0_a64 OUT NOCOPY  VARCHAR2
    , p0_a65 OUT NOCOPY  VARCHAR2
    , p0_a66 OUT NOCOPY  VARCHAR2
    , p0_a67 OUT NOCOPY  VARCHAR2
    , p0_a68 OUT NOCOPY  VARCHAR2
    , p0_a69 OUT NOCOPY  VARCHAR2
    , p0_a70 OUT NOCOPY  VARCHAR2
    , p0_a71 OUT NOCOPY  VARCHAR2
    , p0_a72 OUT NOCOPY  VARCHAR2
    , p0_a73 OUT NOCOPY  VARCHAR2
    , p0_a74 OUT NOCOPY  VARCHAR2
    , p0_a75 OUT NOCOPY  VARCHAR2
    , p0_a76 OUT NOCOPY  VARCHAR2
    , p0_a77 OUT NOCOPY  VARCHAR2
    , p0_a78 OUT NOCOPY  VARCHAR2
    , p0_a79 OUT NOCOPY  VARCHAR2
    , p0_a80 OUT NOCOPY  VARCHAR2
    , p0_a81 OUT NOCOPY  VARCHAR2
    , p0_a82 OUT NOCOPY  VARCHAR2
    , p0_a83 OUT NOCOPY  VARCHAR2
    , p0_a84 OUT NOCOPY  VARCHAR2
    , p0_a85 OUT NOCOPY  VARCHAR2
    , p0_a86 OUT NOCOPY  VARCHAR2
    , p0_a87 OUT NOCOPY  VARCHAR2
    , p0_a88 OUT NOCOPY  VARCHAR2
    , p0_a89 OUT NOCOPY  VARCHAR2
    , p0_a90 OUT NOCOPY  VARCHAR2
    , p0_a91 OUT NOCOPY  VARCHAR2
    , p0_a92 OUT NOCOPY  VARCHAR2
    , p0_a93 OUT NOCOPY  VARCHAR2
    , p0_a94 OUT NOCOPY  VARCHAR2
    , p0_a95 OUT NOCOPY  VARCHAR2
    , p0_a96 OUT NOCOPY  VARCHAR2
    , p0_a97 OUT NOCOPY  VARCHAR2
    , p0_a98 OUT NOCOPY  VARCHAR2
    , p0_a99 OUT NOCOPY  VARCHAR2
    , p0_a100 OUT NOCOPY  VARCHAR2
    , p0_a101 OUT NOCOPY  VARCHAR2
    , p0_a102 OUT NOCOPY  VARCHAR2
    , p0_a103 OUT NOCOPY  VARCHAR2
    , p0_a104 OUT NOCOPY  VARCHAR2
    , p0_a105 OUT NOCOPY  VARCHAR2
    , p0_a106 OUT NOCOPY  VARCHAR2
    , p0_a107 OUT NOCOPY  VARCHAR2
    , p0_a108 OUT NOCOPY  VARCHAR2
    , p0_a109 OUT NOCOPY  VARCHAR2
    , p0_a110 OUT NOCOPY  VARCHAR2
    , p0_a111 OUT NOCOPY  VARCHAR2
    , p0_a112 OUT NOCOPY  VARCHAR2
    , p0_a113 OUT NOCOPY  VARCHAR2
    , p0_a114 OUT NOCOPY  VARCHAR2
    , p0_a115 OUT NOCOPY  VARCHAR2
    , p0_a116 OUT NOCOPY  VARCHAR2
    , p0_a117 OUT NOCOPY  VARCHAR2
    , p0_a118 OUT NOCOPY  VARCHAR2
    , p0_a119 OUT NOCOPY  VARCHAR2
    , p0_a120 OUT NOCOPY  VARCHAR2
    , p0_a121 OUT NOCOPY  VARCHAR2
    , p0_a122 OUT NOCOPY  VARCHAR2
    , p0_a123 OUT NOCOPY  VARCHAR2
    , p0_a124 OUT NOCOPY  VARCHAR2
    , p0_a125 OUT NOCOPY  VARCHAR2
    , p0_a126 OUT NOCOPY  VARCHAR2
    , p0_a127 OUT NOCOPY  VARCHAR2
    , p0_a128 OUT NOCOPY  VARCHAR2
    , p0_a129 OUT NOCOPY  VARCHAR2
    , p0_a130 OUT NOCOPY  VARCHAR2
    , p0_a131 OUT NOCOPY  VARCHAR2
    , p0_a132 OUT NOCOPY  VARCHAR2
    , p0_a133 OUT NOCOPY  VARCHAR2
    , p0_a134 OUT NOCOPY  VARCHAR2
    , p0_a135 OUT NOCOPY  VARCHAR2
    , p0_a136 OUT NOCOPY  VARCHAR2
    , p0_a137 OUT NOCOPY  VARCHAR2
    , p0_a138 OUT NOCOPY  VARCHAR2
    , p0_a139 OUT NOCOPY  VARCHAR2
    , p0_a140 OUT NOCOPY  VARCHAR2
    , p0_a141 OUT NOCOPY  VARCHAR2
    , p0_a142 OUT NOCOPY  VARCHAR2
    , p0_a143 OUT NOCOPY  VARCHAR2
    , p0_a144 OUT NOCOPY  VARCHAR2
    , p0_a145 OUT NOCOPY  VARCHAR2
    , p0_a146 OUT NOCOPY  VARCHAR2
    , p0_a147 OUT NOCOPY  VARCHAR2
    , p0_a148 OUT NOCOPY  VARCHAR2
    , p0_a149 OUT NOCOPY  VARCHAR2
    , p0_a150 OUT NOCOPY  VARCHAR2
    , p0_a151 OUT NOCOPY  VARCHAR2
    , p0_a152 OUT NOCOPY  VARCHAR2
    , p0_a153 OUT NOCOPY  VARCHAR2
    , p0_a154 OUT NOCOPY  VARCHAR2
    , p0_a155 OUT NOCOPY  VARCHAR2
    , p0_a156 OUT NOCOPY  VARCHAR2
    , p0_a157 OUT NOCOPY  VARCHAR2
    , p0_a158 OUT NOCOPY  VARCHAR2
    , p0_a159 OUT NOCOPY  VARCHAR2
    , p0_a160 OUT NOCOPY  VARCHAR2
    , p0_a161 OUT NOCOPY  VARCHAR2
    , p0_a162 OUT NOCOPY  VARCHAR2
    , p0_a163 OUT NOCOPY  VARCHAR2
    , p0_a164 OUT NOCOPY  VARCHAR2
    , p0_a165 OUT NOCOPY  VARCHAR2
    , p0_a166 OUT NOCOPY  VARCHAR2
    , p0_a167 OUT NOCOPY  VARCHAR2
    , p0_a168 OUT NOCOPY  VARCHAR2
    , p0_a169 OUT NOCOPY  VARCHAR2
    , p0_a170 OUT NOCOPY  VARCHAR2
    , p0_a171 OUT NOCOPY  VARCHAR2
    , p0_a172 OUT NOCOPY  VARCHAR2
    , p0_a173 OUT NOCOPY  VARCHAR2
    , p0_a174 OUT NOCOPY  VARCHAR2
    , p0_a175 OUT NOCOPY  VARCHAR2
    , p0_a176 OUT NOCOPY  VARCHAR2
    , p0_a177 OUT NOCOPY  VARCHAR2
    , p0_a178 OUT NOCOPY  VARCHAR2
    , p0_a179 OUT NOCOPY  VARCHAR2
    , p0_a180 OUT NOCOPY  VARCHAR2
    , p0_a181 OUT NOCOPY  VARCHAR2
    , p0_a182 OUT NOCOPY  VARCHAR2
    , p0_a183 OUT NOCOPY  VARCHAR2
    , p0_a184 OUT NOCOPY  VARCHAR2
    , p0_a185 OUT NOCOPY  VARCHAR2
    , p0_a186 OUT NOCOPY  VARCHAR2
    , p0_a187 OUT NOCOPY  VARCHAR2
    , p0_a188 OUT NOCOPY  VARCHAR2
    , p0_a189 OUT NOCOPY  VARCHAR2
    , p0_a190 OUT NOCOPY  VARCHAR2
    , p0_a191 OUT NOCOPY  VARCHAR2
    , p0_a192 OUT NOCOPY  VARCHAR2
    , p0_a193 OUT NOCOPY  VARCHAR2
    , p0_a194 OUT NOCOPY  VARCHAR2
    , p0_a195 OUT NOCOPY  VARCHAR2
    , p0_a196 OUT NOCOPY  VARCHAR2
    , p0_a197 OUT NOCOPY  VARCHAR2
    , p0_a198 OUT NOCOPY  VARCHAR2
    , p0_a199 OUT NOCOPY  VARCHAR2
    , p0_a200 OUT NOCOPY  VARCHAR2
    , p0_a201 OUT NOCOPY  VARCHAR2
    , p0_a202 OUT NOCOPY  VARCHAR2
    , p0_a203 OUT NOCOPY  VARCHAR2
    , p0_a204 OUT NOCOPY  VARCHAR2
    , p0_a205 OUT NOCOPY  VARCHAR2
    , p0_a206 OUT NOCOPY  VARCHAR2
    , p0_a207 OUT NOCOPY  VARCHAR2
    , p0_a208 OUT NOCOPY  VARCHAR2
    , p0_a209 OUT NOCOPY  VARCHAR2
    , p0_a210 OUT NOCOPY  VARCHAR2
    , p0_a211 OUT NOCOPY  VARCHAR2
    , p0_a212 OUT NOCOPY  VARCHAR2
    , p0_a213 OUT NOCOPY  VARCHAR2
    , p0_a214 OUT NOCOPY  VARCHAR2
    , p0_a215 OUT NOCOPY  VARCHAR2
    , p0_a216 OUT NOCOPY  VARCHAR2
    , p0_a217 OUT NOCOPY  VARCHAR2
    , p0_a218 OUT NOCOPY  VARCHAR2
    , p0_a219 OUT NOCOPY  VARCHAR2
    , p0_a220 OUT NOCOPY  VARCHAR2
    , p0_a221 OUT NOCOPY  VARCHAR2
    , p0_a222 OUT NOCOPY  VARCHAR2
    , p0_a223 OUT NOCOPY  VARCHAR2
    , p0_a224 OUT NOCOPY  VARCHAR2
    , p0_a225 OUT NOCOPY  VARCHAR2
    , p0_a226 OUT NOCOPY  VARCHAR2
    , p0_a227 OUT NOCOPY  VARCHAR2
    , p0_a228 OUT NOCOPY  VARCHAR2
    , p0_a229 OUT NOCOPY  VARCHAR2
    , p0_a230 OUT NOCOPY  VARCHAR2
    , p0_a231 OUT NOCOPY  VARCHAR2
    , p0_a232 OUT NOCOPY  VARCHAR2
    , p0_a233 OUT NOCOPY  VARCHAR2
    , p0_a234 OUT NOCOPY  VARCHAR2
    , p0_a235 OUT NOCOPY  VARCHAR2
    , p0_a236 OUT NOCOPY  VARCHAR2
    , p0_a237 OUT NOCOPY  VARCHAR2
    , p0_a238 OUT NOCOPY  VARCHAR2
    , p0_a239 OUT NOCOPY  VARCHAR2
    , p0_a240 OUT NOCOPY  VARCHAR2
    , p0_a241 OUT NOCOPY  VARCHAR2
    , p0_a242 OUT NOCOPY  VARCHAR2
    , p0_a243 OUT NOCOPY  VARCHAR2
    , p0_a244 OUT NOCOPY  VARCHAR2
    , p0_a245 OUT NOCOPY  VARCHAR2
    , p0_a246 OUT NOCOPY  VARCHAR2
    , p0_a247 OUT NOCOPY  VARCHAR2
    , p0_a248 OUT NOCOPY  VARCHAR2
    , p0_a249 OUT NOCOPY  VARCHAR2
    , p0_a250 OUT NOCOPY  VARCHAR2
    , p0_a251 OUT NOCOPY  VARCHAR2
    , p0_a252 OUT NOCOPY  VARCHAR2
    , p0_a253 OUT NOCOPY  VARCHAR2
    , p0_a254 OUT NOCOPY  VARCHAR2
    , p0_a255 OUT NOCOPY  VARCHAR2
    , p0_a256 OUT NOCOPY  VARCHAR2
    , p0_a257 OUT NOCOPY  VARCHAR2
    , p0_a258 OUT NOCOPY  VARCHAR2
    , p0_a259 OUT NOCOPY  VARCHAR2
    , p0_a260 OUT NOCOPY  VARCHAR2
    , p0_a261 OUT NOCOPY  VARCHAR2
    , p0_a262 OUT NOCOPY  VARCHAR2
    , p0_a263 OUT NOCOPY  VARCHAR2
    , p0_a264 OUT NOCOPY  VARCHAR2
    , p0_a265 OUT NOCOPY  VARCHAR2
    , p0_a266 OUT NOCOPY  VARCHAR2
    , p0_a267 OUT NOCOPY  VARCHAR2
    , p0_a268 OUT NOCOPY  VARCHAR2
    , p0_a269 OUT NOCOPY  VARCHAR2
    , p0_a270 OUT NOCOPY  VARCHAR2
    , p0_a271 OUT NOCOPY  VARCHAR2
    , p0_a272 OUT NOCOPY  VARCHAR2
    , p0_a273 OUT NOCOPY  VARCHAR2
    , p0_a274 OUT NOCOPY  VARCHAR2
    , p0_a275 OUT NOCOPY  VARCHAR2
    , p0_a276 OUT NOCOPY  VARCHAR2
    , p0_a277 OUT NOCOPY  VARCHAR2
    , p0_a278 OUT NOCOPY  VARCHAR2
    , p0_a279 OUT NOCOPY  VARCHAR2
    , p0_a280 OUT NOCOPY  VARCHAR2
    , p0_a281 OUT NOCOPY  VARCHAR2
    , p0_a282 OUT NOCOPY  VARCHAR2
    , p0_a283 OUT NOCOPY  VARCHAR2
    , p0_a284 OUT NOCOPY  VARCHAR2
    , p0_a285 OUT NOCOPY  VARCHAR2
    , p0_a286 OUT NOCOPY  VARCHAR2
    , p0_a287 OUT NOCOPY  VARCHAR2
    , p0_a288 OUT NOCOPY  VARCHAR2
    , p0_a289 OUT NOCOPY  VARCHAR2
    , p0_a290 OUT NOCOPY  VARCHAR2
    , p0_a291 OUT NOCOPY  VARCHAR2
    , p0_a292 OUT NOCOPY  VARCHAR2
    , p0_a293 OUT NOCOPY  VARCHAR2
    , p0_a294 OUT NOCOPY  VARCHAR2
    , p0_a295 OUT NOCOPY  VARCHAR2
    , p0_a296 OUT NOCOPY  VARCHAR2
    , p0_a297 OUT NOCOPY  VARCHAR2
    , p0_a298 OUT NOCOPY  VARCHAR2
    , p0_a299 OUT NOCOPY  VARCHAR2
    , p0_a300 OUT NOCOPY  VARCHAR2
    , p0_a301 OUT NOCOPY  VARCHAR2
    , p0_a302 OUT NOCOPY  VARCHAR2
    , p0_a303 OUT NOCOPY  VARCHAR2
    , p0_a304 OUT NOCOPY  VARCHAR2
    , p0_a305 OUT NOCOPY  VARCHAR2
    , p0_a306 OUT NOCOPY  VARCHAR2
    , p0_a307 OUT NOCOPY  VARCHAR2
    , p0_a308 OUT NOCOPY  VARCHAR2
    , p0_a309 OUT NOCOPY  VARCHAR2
    , p0_a310 OUT NOCOPY  VARCHAR2
    , p0_a311 OUT NOCOPY  VARCHAR2
    , p0_a312 OUT NOCOPY  VARCHAR2
    , p0_a313 OUT NOCOPY  VARCHAR2
    , p0_a314 OUT NOCOPY  VARCHAR2
    , p0_a315 OUT NOCOPY  VARCHAR2
    , p0_a316 OUT NOCOPY  VARCHAR2
    , p0_a317 OUT NOCOPY  VARCHAR2
    , p0_a318 OUT NOCOPY  VARCHAR2
    , p0_a319 OUT NOCOPY  VARCHAR2
    , p0_a320 OUT NOCOPY  VARCHAR2
    , p0_a321 OUT NOCOPY  VARCHAR2
    , p0_a322 OUT NOCOPY  VARCHAR2
    , p0_a323 OUT NOCOPY  VARCHAR2
    , p0_a324 OUT NOCOPY  VARCHAR2
    , p0_a325 OUT NOCOPY  VARCHAR2
    , p0_a326 OUT NOCOPY  VARCHAR2
    , p0_a327 OUT NOCOPY  VARCHAR2
    , p0_a328 OUT NOCOPY  VARCHAR2
    , p0_a329 OUT NOCOPY  VARCHAR2
    , p0_a330 OUT NOCOPY  VARCHAR2
    , p0_a331 OUT NOCOPY  VARCHAR2
    , p0_a332 OUT NOCOPY  VARCHAR2
    , p0_a333 OUT NOCOPY  VARCHAR2
    , p0_a334 OUT NOCOPY  VARCHAR2
    , p0_a335 OUT NOCOPY  VARCHAR2
    , p0_a336 OUT NOCOPY  VARCHAR2
    , p0_a337 OUT NOCOPY  VARCHAR2
    , p0_a338 OUT NOCOPY  VARCHAR2
    , p0_a339 OUT NOCOPY  VARCHAR2
    , p0_a340 OUT NOCOPY  VARCHAR2
    , p0_a341 OUT NOCOPY  VARCHAR2
    , p0_a342 OUT NOCOPY  VARCHAR2
    , p0_a343 OUT NOCOPY  VARCHAR2
    , p0_a344 OUT NOCOPY  VARCHAR2
    , p0_a345 OUT NOCOPY  VARCHAR2
    , p0_a346 OUT NOCOPY  VARCHAR2
    , p0_a347 OUT NOCOPY  VARCHAR2
    , p0_a348 OUT NOCOPY  VARCHAR2
    , p0_a349 OUT NOCOPY  VARCHAR2
    , p0_a350 OUT NOCOPY  VARCHAR2
    , p0_a351 OUT NOCOPY  VARCHAR2
    , p0_a352 OUT NOCOPY  VARCHAR2
    , p0_a353 OUT NOCOPY  VARCHAR2
    , p0_a354 OUT NOCOPY  VARCHAR2
    , p0_a355 OUT NOCOPY  VARCHAR2
    , p0_a356 OUT NOCOPY  VARCHAR2
    , p0_a357 OUT NOCOPY  VARCHAR2
    , p0_a358 OUT NOCOPY  VARCHAR2
    , p0_a359 OUT NOCOPY  VARCHAR2
    , p0_a360 OUT NOCOPY  VARCHAR2
    , p0_a361 OUT NOCOPY  VARCHAR2
    , p0_a362 OUT NOCOPY  VARCHAR2
    , p0_a363 OUT NOCOPY  VARCHAR2
    , p0_a364 OUT NOCOPY  VARCHAR2
    , p0_a365 OUT NOCOPY  VARCHAR2
    , p0_a366 OUT NOCOPY  NUMBER
    , p0_a367 OUT NOCOPY  NUMBER
    , p0_a368 OUT NOCOPY  NUMBER
    , p0_a369 OUT NOCOPY  NUMBER
    , p0_a370 OUT NOCOPY  NUMBER
    , p0_a371 OUT NOCOPY  NUMBER
    , p0_a372 OUT NOCOPY  DATE
    , p0_a373 OUT NOCOPY  DATE
    , p0_a374 OUT NOCOPY  NUMBER
    , p0_a375 OUT NOCOPY  NUMBER
  )
  as
    ddx_entry_rec ams_listentry_pvt.entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_listentry_pub.init_entry_rec(ddx_entry_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_entry_rec.list_entry_id);
    p0_a1 := rosetta_g_miss_num_map(ddx_entry_rec.list_header_id);
    p0_a2 := ddx_entry_rec.last_update_date;
    p0_a3 := rosetta_g_miss_num_map(ddx_entry_rec.last_updated_by);
    p0_a4 := ddx_entry_rec.creation_date;
    p0_a5 := rosetta_g_miss_num_map(ddx_entry_rec.created_by);
    p0_a6 := rosetta_g_miss_num_map(ddx_entry_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_entry_rec.object_version_number);
    p0_a8 := rosetta_g_miss_num_map(ddx_entry_rec.list_select_action_id);
    p0_a9 := ddx_entry_rec.arc_list_select_action_from;
    p0_a10 := ddx_entry_rec.list_select_action_from_name;
    p0_a11 := ddx_entry_rec.source_code;
    p0_a12 := ddx_entry_rec.arc_list_used_by_source;
    p0_a13 := rosetta_g_miss_num_map(ddx_entry_rec.source_code_for_id);
    p0_a14 := ddx_entry_rec.pin_code;
    p0_a15 := rosetta_g_miss_num_map(ddx_entry_rec.list_entry_source_system_id);
    p0_a16 := ddx_entry_rec.list_entry_source_system_type;
    p0_a17 := rosetta_g_miss_num_map(ddx_entry_rec.view_application_id);
    p0_a18 := ddx_entry_rec.manually_entered_flag;
    p0_a19 := ddx_entry_rec.marked_as_duplicate_flag;
    p0_a20 := ddx_entry_rec.marked_as_random_flag;
    p0_a21 := ddx_entry_rec.part_of_control_group_flag;
    p0_a22 := ddx_entry_rec.exclude_in_triggered_list_flag;
    p0_a23 := ddx_entry_rec.enabled_flag;
    p0_a24 := ddx_entry_rec.cell_code;
    p0_a25 := ddx_entry_rec.dedupe_key;
    p0_a26 := rosetta_g_miss_num_map(ddx_entry_rec.randomly_generated_number);
    p0_a27 := rosetta_g_miss_num_map(ddx_entry_rec.campaign_id);
    p0_a28 := rosetta_g_miss_num_map(ddx_entry_rec.media_id);
    p0_a29 := rosetta_g_miss_num_map(ddx_entry_rec.channel_id);
    p0_a30 := rosetta_g_miss_num_map(ddx_entry_rec.channel_schedule_id);
    p0_a31 := rosetta_g_miss_num_map(ddx_entry_rec.event_offer_id);
    p0_a32 := rosetta_g_miss_num_map(ddx_entry_rec.customer_id);
    p0_a33 := rosetta_g_miss_num_map(ddx_entry_rec.market_segment_id);
    p0_a34 := rosetta_g_miss_num_map(ddx_entry_rec.vendor_id);
    p0_a35 := ddx_entry_rec.transfer_flag;
    p0_a36 := ddx_entry_rec.transfer_status;
    p0_a37 := ddx_entry_rec.list_source;
    p0_a38 := rosetta_g_miss_num_map(ddx_entry_rec.duplicate_master_entry_id);
    p0_a39 := ddx_entry_rec.marked_flag;
    p0_a40 := rosetta_g_miss_num_map(ddx_entry_rec.lead_id);
    p0_a41 := rosetta_g_miss_num_map(ddx_entry_rec.letter_id);
    p0_a42 := rosetta_g_miss_num_map(ddx_entry_rec.picking_header_id);
    p0_a43 := rosetta_g_miss_num_map(ddx_entry_rec.batch_id);
    p0_a44 := ddx_entry_rec.first_name;
    p0_a45 := ddx_entry_rec.last_name;
    p0_a46 := ddx_entry_rec.customer_name;
    p0_a47 := ddx_entry_rec.col1;
    p0_a48 := ddx_entry_rec.col2;
    p0_a49 := ddx_entry_rec.col3;
    p0_a50 := ddx_entry_rec.col4;
    p0_a51 := ddx_entry_rec.col5;
    p0_a52 := ddx_entry_rec.col6;
    p0_a53 := ddx_entry_rec.col7;
    p0_a54 := ddx_entry_rec.col8;
    p0_a55 := ddx_entry_rec.col9;
    p0_a56 := ddx_entry_rec.col10;
    p0_a57 := ddx_entry_rec.col11;
    p0_a58 := ddx_entry_rec.col12;
    p0_a59 := ddx_entry_rec.col13;
    p0_a60 := ddx_entry_rec.col14;
    p0_a61 := ddx_entry_rec.col15;
    p0_a62 := ddx_entry_rec.col16;
    p0_a63 := ddx_entry_rec.col17;
    p0_a64 := ddx_entry_rec.col18;
    p0_a65 := ddx_entry_rec.col19;
    p0_a66 := ddx_entry_rec.col20;
    p0_a67 := ddx_entry_rec.col21;
    p0_a68 := ddx_entry_rec.col22;
    p0_a69 := ddx_entry_rec.col23;
    p0_a70 := ddx_entry_rec.col24;
    p0_a71 := ddx_entry_rec.col25;
    p0_a72 := ddx_entry_rec.col26;
    p0_a73 := ddx_entry_rec.col27;
    p0_a74 := ddx_entry_rec.col28;
    p0_a75 := ddx_entry_rec.col29;
    p0_a76 := ddx_entry_rec.col30;
    p0_a77 := ddx_entry_rec.col31;
    p0_a78 := ddx_entry_rec.col32;
    p0_a79 := ddx_entry_rec.col33;
    p0_a80 := ddx_entry_rec.col34;
    p0_a81 := ddx_entry_rec.col35;
    p0_a82 := ddx_entry_rec.col36;
    p0_a83 := ddx_entry_rec.col37;
    p0_a84 := ddx_entry_rec.col38;
    p0_a85 := ddx_entry_rec.col39;
    p0_a86 := ddx_entry_rec.col40;
    p0_a87 := ddx_entry_rec.col41;
    p0_a88 := ddx_entry_rec.col42;
    p0_a89 := ddx_entry_rec.col43;
    p0_a90 := ddx_entry_rec.col44;
    p0_a91 := ddx_entry_rec.col45;
    p0_a92 := ddx_entry_rec.col46;
    p0_a93 := ddx_entry_rec.col47;
    p0_a94 := ddx_entry_rec.col48;
    p0_a95 := ddx_entry_rec.col49;
    p0_a96 := ddx_entry_rec.col50;
    p0_a97 := ddx_entry_rec.col51;
    p0_a98 := ddx_entry_rec.col52;
    p0_a99 := ddx_entry_rec.col53;
    p0_a100 := ddx_entry_rec.col54;
    p0_a101 := ddx_entry_rec.col55;
    p0_a102 := ddx_entry_rec.col56;
    p0_a103 := ddx_entry_rec.col57;
    p0_a104 := ddx_entry_rec.col58;
    p0_a105 := ddx_entry_rec.col59;
    p0_a106 := ddx_entry_rec.col60;
    p0_a107 := ddx_entry_rec.col61;
    p0_a108 := ddx_entry_rec.col62;
    p0_a109 := ddx_entry_rec.col63;
    p0_a110 := ddx_entry_rec.col64;
    p0_a111 := ddx_entry_rec.col65;
    p0_a112 := ddx_entry_rec.col66;
    p0_a113 := ddx_entry_rec.col67;
    p0_a114 := ddx_entry_rec.col68;
    p0_a115 := ddx_entry_rec.col69;
    p0_a116 := ddx_entry_rec.col70;
    p0_a117 := ddx_entry_rec.col71;
    p0_a118 := ddx_entry_rec.col72;
    p0_a119 := ddx_entry_rec.col73;
    p0_a120 := ddx_entry_rec.col74;
    p0_a121 := ddx_entry_rec.col75;
    p0_a122 := ddx_entry_rec.col76;
    p0_a123 := ddx_entry_rec.col77;
    p0_a124 := ddx_entry_rec.col78;
    p0_a125 := ddx_entry_rec.col79;
    p0_a126 := ddx_entry_rec.col80;
    p0_a127 := ddx_entry_rec.col81;
    p0_a128 := ddx_entry_rec.col82;
    p0_a129 := ddx_entry_rec.col83;
    p0_a130 := ddx_entry_rec.col84;
    p0_a131 := ddx_entry_rec.col85;
    p0_a132 := ddx_entry_rec.col86;
    p0_a133 := ddx_entry_rec.col87;
    p0_a134 := ddx_entry_rec.col88;
    p0_a135 := ddx_entry_rec.col89;
    p0_a136 := ddx_entry_rec.col90;
    p0_a137 := ddx_entry_rec.col91;
    p0_a138 := ddx_entry_rec.col92;
    p0_a139 := ddx_entry_rec.col93;
    p0_a140 := ddx_entry_rec.col94;
    p0_a141 := ddx_entry_rec.col95;
    p0_a142 := ddx_entry_rec.col96;
    p0_a143 := ddx_entry_rec.col97;
    p0_a144 := ddx_entry_rec.col98;
    p0_a145 := ddx_entry_rec.col99;
    p0_a146 := ddx_entry_rec.col100;
    p0_a147 := ddx_entry_rec.col101;
    p0_a148 := ddx_entry_rec.col102;
    p0_a149 := ddx_entry_rec.col103;
    p0_a150 := ddx_entry_rec.col104;
    p0_a151 := ddx_entry_rec.col105;
    p0_a152 := ddx_entry_rec.col106;
    p0_a153 := ddx_entry_rec.col107;
    p0_a154 := ddx_entry_rec.col108;
    p0_a155 := ddx_entry_rec.col109;
    p0_a156 := ddx_entry_rec.col110;
    p0_a157 := ddx_entry_rec.col111;
    p0_a158 := ddx_entry_rec.col112;
    p0_a159 := ddx_entry_rec.col113;
    p0_a160 := ddx_entry_rec.col114;
    p0_a161 := ddx_entry_rec.col115;
    p0_a162 := ddx_entry_rec.col116;
    p0_a163 := ddx_entry_rec.col117;
    p0_a164 := ddx_entry_rec.col118;
    p0_a165 := ddx_entry_rec.col119;
    p0_a166 := ddx_entry_rec.col120;
    p0_a167 := ddx_entry_rec.col121;
    p0_a168 := ddx_entry_rec.col122;
    p0_a169 := ddx_entry_rec.col123;
    p0_a170 := ddx_entry_rec.col124;
    p0_a171 := ddx_entry_rec.col125;
    p0_a172 := ddx_entry_rec.col126;
    p0_a173 := ddx_entry_rec.col127;
    p0_a174 := ddx_entry_rec.col128;
    p0_a175 := ddx_entry_rec.col129;
    p0_a176 := ddx_entry_rec.col130;
    p0_a177 := ddx_entry_rec.col131;
    p0_a178 := ddx_entry_rec.col132;
    p0_a179 := ddx_entry_rec.col133;
    p0_a180 := ddx_entry_rec.col134;
    p0_a181 := ddx_entry_rec.col135;
    p0_a182 := ddx_entry_rec.col136;
    p0_a183 := ddx_entry_rec.col137;
    p0_a184 := ddx_entry_rec.col138;
    p0_a185 := ddx_entry_rec.col139;
    p0_a186 := ddx_entry_rec.col140;
    p0_a187 := ddx_entry_rec.col141;
    p0_a188 := ddx_entry_rec.col142;
    p0_a189 := ddx_entry_rec.col143;
    p0_a190 := ddx_entry_rec.col144;
    p0_a191 := ddx_entry_rec.col145;
    p0_a192 := ddx_entry_rec.col146;
    p0_a193 := ddx_entry_rec.col147;
    p0_a194 := ddx_entry_rec.col148;
    p0_a195 := ddx_entry_rec.col149;
    p0_a196 := ddx_entry_rec.col150;
    p0_a197 := ddx_entry_rec.col151;
    p0_a198 := ddx_entry_rec.col152;
    p0_a199 := ddx_entry_rec.col153;
    p0_a200 := ddx_entry_rec.col154;
    p0_a201 := ddx_entry_rec.col155;
    p0_a202 := ddx_entry_rec.col156;
    p0_a203 := ddx_entry_rec.col157;
    p0_a204 := ddx_entry_rec.col158;
    p0_a205 := ddx_entry_rec.col159;
    p0_a206 := ddx_entry_rec.col160;
    p0_a207 := ddx_entry_rec.col161;
    p0_a208 := ddx_entry_rec.col162;
    p0_a209 := ddx_entry_rec.col163;
    p0_a210 := ddx_entry_rec.col164;
    p0_a211 := ddx_entry_rec.col165;
    p0_a212 := ddx_entry_rec.col166;
    p0_a213 := ddx_entry_rec.col167;
    p0_a214 := ddx_entry_rec.col168;
    p0_a215 := ddx_entry_rec.col169;
    p0_a216 := ddx_entry_rec.col170;
    p0_a217 := ddx_entry_rec.col171;
    p0_a218 := ddx_entry_rec.col172;
    p0_a219 := ddx_entry_rec.col173;
    p0_a220 := ddx_entry_rec.col174;
    p0_a221 := ddx_entry_rec.col175;
    p0_a222 := ddx_entry_rec.col176;
    p0_a223 := ddx_entry_rec.col177;
    p0_a224 := ddx_entry_rec.col178;
    p0_a225 := ddx_entry_rec.col179;
    p0_a226 := ddx_entry_rec.col180;
    p0_a227 := ddx_entry_rec.col181;
    p0_a228 := ddx_entry_rec.col182;
    p0_a229 := ddx_entry_rec.col183;
    p0_a230 := ddx_entry_rec.col184;
    p0_a231 := ddx_entry_rec.col185;
    p0_a232 := ddx_entry_rec.col186;
    p0_a233 := ddx_entry_rec.col187;
    p0_a234 := ddx_entry_rec.col188;
    p0_a235 := ddx_entry_rec.col189;
    p0_a236 := ddx_entry_rec.col190;
    p0_a237 := ddx_entry_rec.col191;
    p0_a238 := ddx_entry_rec.col192;
    p0_a239 := ddx_entry_rec.col193;
    p0_a240 := ddx_entry_rec.col194;
    p0_a241 := ddx_entry_rec.col195;
    p0_a242 := ddx_entry_rec.col196;
    p0_a243 := ddx_entry_rec.col197;
    p0_a244 := ddx_entry_rec.col198;
    p0_a245 := ddx_entry_rec.col199;
    p0_a246 := ddx_entry_rec.col200;
    p0_a247 := ddx_entry_rec.col201;
    p0_a248 := ddx_entry_rec.col202;
    p0_a249 := ddx_entry_rec.col203;
    p0_a250 := ddx_entry_rec.col204;
    p0_a251 := ddx_entry_rec.col205;
    p0_a252 := ddx_entry_rec.col206;
    p0_a253 := ddx_entry_rec.col207;
    p0_a254 := ddx_entry_rec.col208;
    p0_a255 := ddx_entry_rec.col209;
    p0_a256 := ddx_entry_rec.col210;
    p0_a257 := ddx_entry_rec.col211;
    p0_a258 := ddx_entry_rec.col212;
    p0_a259 := ddx_entry_rec.col213;
    p0_a260 := ddx_entry_rec.col214;
    p0_a261 := ddx_entry_rec.col215;
    p0_a262 := ddx_entry_rec.col216;
    p0_a263 := ddx_entry_rec.col217;
    p0_a264 := ddx_entry_rec.col218;
    p0_a265 := ddx_entry_rec.col219;
    p0_a266 := ddx_entry_rec.col220;
    p0_a267 := ddx_entry_rec.col221;
    p0_a268 := ddx_entry_rec.col222;
    p0_a269 := ddx_entry_rec.col223;
    p0_a270 := ddx_entry_rec.col224;
    p0_a271 := ddx_entry_rec.col225;
    p0_a272 := ddx_entry_rec.col226;
    p0_a273 := ddx_entry_rec.col227;
    p0_a274 := ddx_entry_rec.col228;
    p0_a275 := ddx_entry_rec.col229;
    p0_a276 := ddx_entry_rec.col230;
    p0_a277 := ddx_entry_rec.col231;
    p0_a278 := ddx_entry_rec.col232;
    p0_a279 := ddx_entry_rec.col233;
    p0_a280 := ddx_entry_rec.col234;
    p0_a281 := ddx_entry_rec.col235;
    p0_a282 := ddx_entry_rec.col236;
    p0_a283 := ddx_entry_rec.col237;
    p0_a284 := ddx_entry_rec.col238;
    p0_a285 := ddx_entry_rec.col239;
    p0_a286 := ddx_entry_rec.col240;
    p0_a287 := ddx_entry_rec.col241;
    p0_a288 := ddx_entry_rec.col242;
    p0_a289 := ddx_entry_rec.col243;
    p0_a290 := ddx_entry_rec.col244;
    p0_a291 := ddx_entry_rec.col245;
    p0_a292 := ddx_entry_rec.col246;
    p0_a293 := ddx_entry_rec.col247;
    p0_a294 := ddx_entry_rec.col248;
    p0_a295 := ddx_entry_rec.col249;
    p0_a296 := ddx_entry_rec.col250;
    p0_a297 := ddx_entry_rec.col251;
    p0_a298 := ddx_entry_rec.col252;
    p0_a299 := ddx_entry_rec.col253;
    p0_a300 := ddx_entry_rec.col254;
    p0_a301 := ddx_entry_rec.col255;
    p0_a302 := ddx_entry_rec.col256;
    p0_a303 := ddx_entry_rec.col257;
    p0_a304 := ddx_entry_rec.col258;
    p0_a305 := ddx_entry_rec.col259;
    p0_a306 := ddx_entry_rec.col260;
    p0_a307 := ddx_entry_rec.col261;
    p0_a308 := ddx_entry_rec.col262;
    p0_a309 := ddx_entry_rec.col263;
    p0_a310 := ddx_entry_rec.col264;
    p0_a311 := ddx_entry_rec.col265;
    p0_a312 := ddx_entry_rec.col266;
    p0_a313 := ddx_entry_rec.col267;
    p0_a314 := ddx_entry_rec.col268;
    p0_a315 := ddx_entry_rec.col269;
    p0_a316 := ddx_entry_rec.col270;
    p0_a317 := ddx_entry_rec.col271;
    p0_a318 := ddx_entry_rec.col272;
    p0_a319 := ddx_entry_rec.col273;
    p0_a320 := ddx_entry_rec.col274;
    p0_a321 := ddx_entry_rec.col275;
    p0_a322 := ddx_entry_rec.col276;
    p0_a323 := ddx_entry_rec.col277;
    p0_a324 := ddx_entry_rec.col278;
    p0_a325 := ddx_entry_rec.col279;
    p0_a326 := ddx_entry_rec.col280;
    p0_a327 := ddx_entry_rec.col281;
    p0_a328 := ddx_entry_rec.col282;
    p0_a329 := ddx_entry_rec.col283;
    p0_a330 := ddx_entry_rec.col284;
    p0_a331 := ddx_entry_rec.col285;
    p0_a332 := ddx_entry_rec.col286;
    p0_a333 := ddx_entry_rec.col287;
    p0_a334 := ddx_entry_rec.col288;
    p0_a335 := ddx_entry_rec.col289;
    p0_a336 := ddx_entry_rec.col290;
    p0_a337 := ddx_entry_rec.col291;
    p0_a338 := ddx_entry_rec.col292;
    p0_a339 := ddx_entry_rec.col293;
    p0_a340 := ddx_entry_rec.col294;
    p0_a341 := ddx_entry_rec.col295;
    p0_a342 := ddx_entry_rec.col296;
    p0_a343 := ddx_entry_rec.col297;
    p0_a344 := ddx_entry_rec.col298;
    p0_a345 := ddx_entry_rec.col299;
    p0_a346 := ddx_entry_rec.col300;
    p0_a347 := ddx_entry_rec.address_line1;
    p0_a348 := ddx_entry_rec.address_line2;
    p0_a349 := ddx_entry_rec.callback_flag;
    p0_a350 := ddx_entry_rec.city;
    p0_a351 := ddx_entry_rec.country;
    p0_a352 := ddx_entry_rec.do_not_use_flag;
    p0_a353 := ddx_entry_rec.do_not_use_reason;
    p0_a354 := ddx_entry_rec.email_address;
    p0_a355 := ddx_entry_rec.fax;
    p0_a356 := ddx_entry_rec.phone;
    p0_a357 := ddx_entry_rec.record_out_flag;
    p0_a358 := ddx_entry_rec.state;
    p0_a359 := ddx_entry_rec.suffix;
    p0_a360 := ddx_entry_rec.title;
    p0_a361 := ddx_entry_rec.usage_restriction;
    p0_a362 := ddx_entry_rec.zipcode;
    p0_a363 := ddx_entry_rec.curr_cp_country_code;
    p0_a364 := ddx_entry_rec.curr_cp_phone_number;
    p0_a365 := ddx_entry_rec.curr_cp_raw_phone_number;
    p0_a366 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_area_code);
    p0_a367 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_id);
    p0_a368 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_index);
    p0_a369 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_time_zone);
    p0_a370 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_time_zone_aux);
    p0_a371 := rosetta_g_miss_num_map(ddx_entry_rec.imp_source_line_id);
    p0_a372 := ddx_entry_rec.next_call_time;
    p0_a373 := ddx_entry_rec.record_release_time;
    p0_a374 := rosetta_g_miss_num_map(ddx_entry_rec.party_id);
    p0_a375 := rosetta_g_miss_num_map(ddx_entry_rec.parent_party_id);
  end;

end ams_listentry_pub_w;

/
