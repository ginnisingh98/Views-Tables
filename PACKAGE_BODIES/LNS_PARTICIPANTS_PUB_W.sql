--------------------------------------------------------
--  DDL for Package Body LNS_PARTICIPANTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_PARTICIPANTS_PUB_W" as
  /* $Header: LNS_PART_PUBJ_B.pls 120.4 2006/01/18 20:30 karamach noship $ */
  procedure validateparticipant(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_participant_rec lns_participants_pub.loan_participant_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loan_participant_rec.participant_id := p0_a0;
    ddp_loan_participant_rec.loan_id := p0_a1;
    ddp_loan_participant_rec.hz_party_id := p0_a2;
    ddp_loan_participant_rec.loan_participant_type := p0_a3;
    ddp_loan_participant_rec.start_date_active := p0_a4;
    ddp_loan_participant_rec.end_date_active := p0_a5;
    ddp_loan_participant_rec.cust_account_id := p0_a6;
    ddp_loan_participant_rec.bill_to_acct_site_id := p0_a7;
    ddp_loan_participant_rec.object_version_number := p0_a8;
    ddp_loan_participant_rec.attribute_category := p0_a9;
    ddp_loan_participant_rec.attribute1 := p0_a10;
    ddp_loan_participant_rec.attribute2 := p0_a11;
    ddp_loan_participant_rec.attribute3 := p0_a12;
    ddp_loan_participant_rec.attribute4 := p0_a13;
    ddp_loan_participant_rec.attribute5 := p0_a14;
    ddp_loan_participant_rec.attribute6 := p0_a15;
    ddp_loan_participant_rec.attribute7 := p0_a16;
    ddp_loan_participant_rec.attribute8 := p0_a17;
    ddp_loan_participant_rec.attribute9 := p0_a18;
    ddp_loan_participant_rec.attribute10 := p0_a19;
    ddp_loan_participant_rec.attribute11 := p0_a20;
    ddp_loan_participant_rec.attribute12 := p0_a21;
    ddp_loan_participant_rec.attribute13 := p0_a22;
    ddp_loan_participant_rec.attribute14 := p0_a23;
    ddp_loan_participant_rec.attribute15 := p0_a24;
    ddp_loan_participant_rec.attribute16 := p0_a25;
    ddp_loan_participant_rec.attribute17 := p0_a26;
    ddp_loan_participant_rec.attribute18 := p0_a27;
    ddp_loan_participant_rec.attribute19 := p0_a28;
    ddp_loan_participant_rec.attribute20 := p0_a29;
    ddp_loan_participant_rec.contact_rel_party_id := p0_a30;
    ddp_loan_participant_rec.contact_pers_party_id := p0_a31;
    ddp_loan_participant_rec.credit_request_id := p0_a32;
    ddp_loan_participant_rec.case_folder_id := p0_a33;
    ddp_loan_participant_rec.review_type := p0_a34;
    ddp_loan_participant_rec.credit_classification := p0_a35;





    -- here's the delegated call to the old PL/SQL routine
    lns_participants_pub.validateparticipant(ddp_loan_participant_rec,
      p_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure createparticipant(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , x_participant_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_participant_rec lns_participants_pub.loan_participant_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_loan_participant_rec.participant_id := p2_a0;
    ddp_loan_participant_rec.loan_id := p2_a1;
    ddp_loan_participant_rec.hz_party_id := p2_a2;
    ddp_loan_participant_rec.loan_participant_type := p2_a3;
    ddp_loan_participant_rec.start_date_active := p2_a4;
    ddp_loan_participant_rec.end_date_active := p2_a5;
    ddp_loan_participant_rec.cust_account_id := p2_a6;
    ddp_loan_participant_rec.bill_to_acct_site_id := p2_a7;
    ddp_loan_participant_rec.object_version_number := p2_a8;
    ddp_loan_participant_rec.attribute_category := p2_a9;
    ddp_loan_participant_rec.attribute1 := p2_a10;
    ddp_loan_participant_rec.attribute2 := p2_a11;
    ddp_loan_participant_rec.attribute3 := p2_a12;
    ddp_loan_participant_rec.attribute4 := p2_a13;
    ddp_loan_participant_rec.attribute5 := p2_a14;
    ddp_loan_participant_rec.attribute6 := p2_a15;
    ddp_loan_participant_rec.attribute7 := p2_a16;
    ddp_loan_participant_rec.attribute8 := p2_a17;
    ddp_loan_participant_rec.attribute9 := p2_a18;
    ddp_loan_participant_rec.attribute10 := p2_a19;
    ddp_loan_participant_rec.attribute11 := p2_a20;
    ddp_loan_participant_rec.attribute12 := p2_a21;
    ddp_loan_participant_rec.attribute13 := p2_a22;
    ddp_loan_participant_rec.attribute14 := p2_a23;
    ddp_loan_participant_rec.attribute15 := p2_a24;
    ddp_loan_participant_rec.attribute16 := p2_a25;
    ddp_loan_participant_rec.attribute17 := p2_a26;
    ddp_loan_participant_rec.attribute18 := p2_a27;
    ddp_loan_participant_rec.attribute19 := p2_a28;
    ddp_loan_participant_rec.attribute20 := p2_a29;
    ddp_loan_participant_rec.contact_rel_party_id := p2_a30;
    ddp_loan_participant_rec.contact_pers_party_id := p2_a31;
    ddp_loan_participant_rec.credit_request_id := p2_a32;
    ddp_loan_participant_rec.case_folder_id := p2_a33;
    ddp_loan_participant_rec.review_type := p2_a34;
    ddp_loan_participant_rec.credit_classification := p2_a35;





    -- here's the delegated call to the old PL/SQL routine
    lns_participants_pub.createparticipant(p_init_msg_list,
      p_validation_level,
      ddp_loan_participant_rec,
      x_participant_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure updateparticipant(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  DATE
    , p2_a5  DATE
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_participant_rec lns_participants_pub.loan_participant_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_loan_participant_rec.participant_id := p2_a0;
    ddp_loan_participant_rec.loan_id := p2_a1;
    ddp_loan_participant_rec.hz_party_id := p2_a2;
    ddp_loan_participant_rec.loan_participant_type := p2_a3;
    ddp_loan_participant_rec.start_date_active := p2_a4;
    ddp_loan_participant_rec.end_date_active := p2_a5;
    ddp_loan_participant_rec.cust_account_id := p2_a6;
    ddp_loan_participant_rec.bill_to_acct_site_id := p2_a7;
    ddp_loan_participant_rec.object_version_number := p2_a8;
    ddp_loan_participant_rec.attribute_category := p2_a9;
    ddp_loan_participant_rec.attribute1 := p2_a10;
    ddp_loan_participant_rec.attribute2 := p2_a11;
    ddp_loan_participant_rec.attribute3 := p2_a12;
    ddp_loan_participant_rec.attribute4 := p2_a13;
    ddp_loan_participant_rec.attribute5 := p2_a14;
    ddp_loan_participant_rec.attribute6 := p2_a15;
    ddp_loan_participant_rec.attribute7 := p2_a16;
    ddp_loan_participant_rec.attribute8 := p2_a17;
    ddp_loan_participant_rec.attribute9 := p2_a18;
    ddp_loan_participant_rec.attribute10 := p2_a19;
    ddp_loan_participant_rec.attribute11 := p2_a20;
    ddp_loan_participant_rec.attribute12 := p2_a21;
    ddp_loan_participant_rec.attribute13 := p2_a22;
    ddp_loan_participant_rec.attribute14 := p2_a23;
    ddp_loan_participant_rec.attribute15 := p2_a24;
    ddp_loan_participant_rec.attribute16 := p2_a25;
    ddp_loan_participant_rec.attribute17 := p2_a26;
    ddp_loan_participant_rec.attribute18 := p2_a27;
    ddp_loan_participant_rec.attribute19 := p2_a28;
    ddp_loan_participant_rec.attribute20 := p2_a29;
    ddp_loan_participant_rec.contact_rel_party_id := p2_a30;
    ddp_loan_participant_rec.contact_pers_party_id := p2_a31;
    ddp_loan_participant_rec.credit_request_id := p2_a32;
    ddp_loan_participant_rec.case_folder_id := p2_a33;
    ddp_loan_participant_rec.review_type := p2_a34;
    ddp_loan_participant_rec.credit_classification := p2_a35;





    -- here's the delegated call to the old PL/SQL routine
    lns_participants_pub.updateparticipant(p_init_msg_list,
      p_validation_level,
      ddp_loan_participant_rec,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end lns_participants_pub_w;

/
