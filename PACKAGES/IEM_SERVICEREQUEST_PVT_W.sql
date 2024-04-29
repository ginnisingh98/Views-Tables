--------------------------------------------------------
--  DDL for Package IEM_SERVICEREQUEST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SERVICEREQUEST_PVT_W" AUTHID CURRENT_USER as
  /* $Header: iemcspks.pls 115.3 2002/12/23 19:34:52 mrabatin noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy iem_servicerequest_pvt.notes_table, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_32767
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t iem_servicerequest_pvt.notes_table, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_32767
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy iem_servicerequest_pvt.contacts_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t iem_servicerequest_pvt.contacts_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_servicerequest_wrap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  NUMBER
    , p13_a79  NUMBER
    , p13_a80  NUMBER
    , p13_a81  NUMBER
    , p13_a82  VARCHAR2
    , p13_a83  DATE
    , p13_a84  VARCHAR2
    , p13_a85  NUMBER
    , p13_a86  NUMBER
    , p13_a87  VARCHAR2
    , p13_a88  NUMBER
    , p13_a89  VARCHAR2
    , p13_a90  NUMBER
    , p13_a91  NUMBER
    , p13_a92  VARCHAR2
    , p13_a93  NUMBER
    , p13_a94  VARCHAR2
    , p13_a95  VARCHAR2
    , p13_a96  VARCHAR2
    , p13_a97  DATE
    , p13_a98  NUMBER
    , p13_a99  NUMBER
    , p13_a100  NUMBER
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  VARCHAR2
    , p13_a108  NUMBER
    , p13_a109  VARCHAR2
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  VARCHAR2
    , p13_a114  VARCHAR2
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  VARCHAR2
    , p13_a118  NUMBER
    , p13_a119  NUMBER
    , p13_a120  VARCHAR2
    , p13_a121  VARCHAR2
    , p13_a122  VARCHAR2
    , p13_a123  VARCHAR2
    , p13_a124  VARCHAR2
    , p13_a125  VARCHAR2
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
  );
  procedure update_servicerequest_wrap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
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
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  NUMBER
    , p15_a79  NUMBER
    , p15_a80  NUMBER
    , p15_a81  NUMBER
    , p15_a82  VARCHAR2
    , p15_a83  DATE
    , p15_a84  VARCHAR2
    , p15_a85  NUMBER
    , p15_a86  NUMBER
    , p15_a87  VARCHAR2
    , p15_a88  NUMBER
    , p15_a89  VARCHAR2
    , p15_a90  NUMBER
    , p15_a91  NUMBER
    , p15_a92  VARCHAR2
    , p15_a93  NUMBER
    , p15_a94  VARCHAR2
    , p15_a95  VARCHAR2
    , p15_a96  VARCHAR2
    , p15_a97  DATE
    , p15_a98  NUMBER
    , p15_a99  NUMBER
    , p15_a100  NUMBER
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  VARCHAR2
    , p15_a108  NUMBER
    , p15_a109  VARCHAR2
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  VARCHAR2
    , p15_a114  VARCHAR2
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  VARCHAR2
    , p15_a118  NUMBER
    , p15_a119  NUMBER
    , p15_a120  VARCHAR2
    , p15_a121  VARCHAR2
    , p15_a122  VARCHAR2
    , p15_a123  VARCHAR2
    , p15_a124  VARCHAR2
    , p15_a125  VARCHAR2
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
    , x_interaction_id out nocopy  NUMBER
  );
  procedure initialize_rec(p0_a0 in out nocopy  DATE
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  DATE
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  NUMBER
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  VARCHAR2
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  VARCHAR2
    , p0_a36 in out nocopy  VARCHAR2
    , p0_a37 in out nocopy  VARCHAR2
    , p0_a38 in out nocopy  VARCHAR2
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  VARCHAR2
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  NUMBER
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  NUMBER
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  DATE
    , p0_a61 in out nocopy  NUMBER
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  VARCHAR2
    , p0_a69 in out nocopy  VARCHAR2
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  VARCHAR2
    , p0_a78 in out nocopy  NUMBER
    , p0_a79 in out nocopy  NUMBER
    , p0_a80 in out nocopy  NUMBER
    , p0_a81 in out nocopy  NUMBER
    , p0_a82 in out nocopy  VARCHAR2
    , p0_a83 in out nocopy  DATE
    , p0_a84 in out nocopy  VARCHAR2
    , p0_a85 in out nocopy  NUMBER
    , p0_a86 in out nocopy  NUMBER
    , p0_a87 in out nocopy  VARCHAR2
    , p0_a88 in out nocopy  NUMBER
    , p0_a89 in out nocopy  VARCHAR2
    , p0_a90 in out nocopy  NUMBER
    , p0_a91 in out nocopy  NUMBER
    , p0_a92 in out nocopy  VARCHAR2
    , p0_a93 in out nocopy  NUMBER
    , p0_a94 in out nocopy  VARCHAR2
    , p0_a95 in out nocopy  VARCHAR2
    , p0_a96 in out nocopy  VARCHAR2
    , p0_a97 in out nocopy  DATE
    , p0_a98 in out nocopy  NUMBER
    , p0_a99 in out nocopy  NUMBER
    , p0_a100 in out nocopy  NUMBER
    , p0_a101 in out nocopy  NUMBER
    , p0_a102 in out nocopy  NUMBER
    , p0_a103 in out nocopy  VARCHAR2
    , p0_a104 in out nocopy  NUMBER
    , p0_a105 in out nocopy  VARCHAR2
    , p0_a106 in out nocopy  NUMBER
    , p0_a107 in out nocopy  VARCHAR2
    , p0_a108 in out nocopy  NUMBER
    , p0_a109 in out nocopy  VARCHAR2
    , p0_a110 in out nocopy  VARCHAR2
    , p0_a111 in out nocopy  VARCHAR2
    , p0_a112 in out nocopy  VARCHAR2
    , p0_a113 in out nocopy  VARCHAR2
    , p0_a114 in out nocopy  VARCHAR2
    , p0_a115 in out nocopy  NUMBER
    , p0_a116 in out nocopy  NUMBER
    , p0_a117 in out nocopy  VARCHAR2
    , p0_a118 in out nocopy  NUMBER
    , p0_a119 in out nocopy  NUMBER
    , p0_a120 in out nocopy  VARCHAR2
    , p0_a121 in out nocopy  VARCHAR2
    , p0_a122 in out nocopy  VARCHAR2
    , p0_a123 in out nocopy  VARCHAR2
    , p0_a124 in out nocopy  VARCHAR2
    , p0_a125 in out nocopy  VARCHAR2
  );
end iem_servicerequest_pvt_w;

 

/
