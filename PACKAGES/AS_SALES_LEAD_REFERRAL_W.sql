--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_REFERRAL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_REFERRAL_W" AUTHID CURRENT_USER as
  /* $Header: asxwlrps.pls 120.1 2005/06/23 15:49:41 appldev ship $ */
  procedure rosetta_table_copy_in_p53(t OUT NOCOPY  as_sales_lead_referral.t_overriding_usernames, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p53(t as_sales_lead_referral.t_overriding_usernames, a0 OUT NOCOPY  JTF_VARCHAR2_TABLE_100);

  procedure notify_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_lead_id  NUMBER
    , p_lead_status  VARCHAR2
    , p_salesforce_id  NUMBER
    , p_overriding_usernames JTF_VARCHAR2_TABLE_100
    , x_msg_count OUT NOCOPY   NUMBER
    , x_msg_data OUT NOCOPY   VARCHAR2
    , x_return_status OUT NOCOPY   VARCHAR2
  );
  procedure update_sales_referral_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p_overriding_usernames JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY   VARCHAR2
    , x_msg_count OUT NOCOPY   NUMBER
    , x_msg_data OUT NOCOPY   VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  DATE := fnd_api.g_miss_date
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  NUMBER := 0-1962.0724
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  NUMBER := 0-1962.0724
    , p9_a58  NUMBER := 0-1962.0724
    , p9_a59  NUMBER := 0-1962.0724
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  VARCHAR2 := fnd_api.g_miss_char
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  NUMBER := 0-1962.0724
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  VARCHAR2 := fnd_api.g_miss_char
    , p9_a73  VARCHAR2 := fnd_api.g_miss_char
    , p9_a74  VARCHAR2 := fnd_api.g_miss_char
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  NUMBER := 0-1962.0724
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  DATE := fnd_api.g_miss_date
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  VARCHAR2 := fnd_api.g_miss_char
  );
end as_sales_lead_referral_w;

 

/
