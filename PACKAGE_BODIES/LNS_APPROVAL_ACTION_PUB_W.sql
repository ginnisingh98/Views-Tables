--------------------------------------------------------
--  DDL for Package Body LNS_APPROVAL_ACTION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_APPROVAL_ACTION_PUB_W" as
  /* $Header: LNS_APACT_PUBJ_B.pls 120.0.12010000.3 2010/04/08 08:41:38 gparuchu ship $ */
  procedure create_approval_action(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , x_action_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_approval_action_rec lns_approval_action_pub.approval_action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_approval_action_rec.action_id := p1_a0;
    ddp_approval_action_rec.created_by := p1_a1;
    ddp_approval_action_rec.creation_date := p1_a2;
    ddp_approval_action_rec.last_updated_by := p1_a3;
    ddp_approval_action_rec.last_update_date := p1_a4;
    ddp_approval_action_rec.last_update_login := p1_a5;
    ddp_approval_action_rec.object_version_number := p1_a6;
    ddp_approval_action_rec.loan_id := p1_a7;
    ddp_approval_action_rec.action_type := p1_a8;
    ddp_approval_action_rec.amount := p1_a9;
    ddp_approval_action_rec.reason_code := p1_a10;
    ddp_approval_action_rec.attribute_category := p1_a11;
    ddp_approval_action_rec.attribute1 := p1_a12;
    ddp_approval_action_rec.attribute2 := p1_a13;
    ddp_approval_action_rec.attribute3 := p1_a14;
    ddp_approval_action_rec.attribute4 := p1_a15;
    ddp_approval_action_rec.attribute5 := p1_a16;
    ddp_approval_action_rec.attribute6 := p1_a17;
    ddp_approval_action_rec.attribute7 := p1_a18;
    ddp_approval_action_rec.attribute8 := p1_a19;
    ddp_approval_action_rec.attribute9 := p1_a20;
    ddp_approval_action_rec.attribute10 := p1_a21;
    ddp_approval_action_rec.attribute11 := p1_a22;
    ddp_approval_action_rec.attribute12 := p1_a23;
    ddp_approval_action_rec.attribute13 := p1_a24;
    ddp_approval_action_rec.attribute14 := p1_a25;
    ddp_approval_action_rec.attribute15 := p1_a26;
    ddp_approval_action_rec.attribute16 := p1_a27;
    ddp_approval_action_rec.attribute17 := p1_a28;
    ddp_approval_action_rec.attribute18 := p1_a29;
    ddp_approval_action_rec.attribute19 := p1_a30;
    ddp_approval_action_rec.attribute20 := p1_a31;





    -- here's the delegated call to the old PL/SQL routine
    lns_approval_action_pub.create_approval_action(p_init_msg_list,
      ddp_approval_action_rec,
      x_action_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_approval_action(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_approval_action_rec lns_approval_action_pub.approval_action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_approval_action_rec.action_id := p1_a0;
    ddp_approval_action_rec.created_by := p1_a1;
    ddp_approval_action_rec.creation_date := p1_a2;
    ddp_approval_action_rec.last_updated_by := p1_a3;
    ddp_approval_action_rec.last_update_date := p1_a4;
    ddp_approval_action_rec.last_update_login := p1_a5;
    ddp_approval_action_rec.object_version_number := p1_a6;
    ddp_approval_action_rec.loan_id := p1_a7;
    ddp_approval_action_rec.action_type := p1_a8;
    ddp_approval_action_rec.amount := p1_a9;
    ddp_approval_action_rec.reason_code := p1_a10;
    ddp_approval_action_rec.attribute_category := p1_a11;
    ddp_approval_action_rec.attribute1 := p1_a12;
    ddp_approval_action_rec.attribute2 := p1_a13;
    ddp_approval_action_rec.attribute3 := p1_a14;
    ddp_approval_action_rec.attribute4 := p1_a15;
    ddp_approval_action_rec.attribute5 := p1_a16;
    ddp_approval_action_rec.attribute6 := p1_a17;
    ddp_approval_action_rec.attribute7 := p1_a18;
    ddp_approval_action_rec.attribute8 := p1_a19;
    ddp_approval_action_rec.attribute9 := p1_a20;
    ddp_approval_action_rec.attribute10 := p1_a21;
    ddp_approval_action_rec.attribute11 := p1_a22;
    ddp_approval_action_rec.attribute12 := p1_a23;
    ddp_approval_action_rec.attribute13 := p1_a24;
    ddp_approval_action_rec.attribute14 := p1_a25;
    ddp_approval_action_rec.attribute15 := p1_a26;
    ddp_approval_action_rec.attribute16 := p1_a27;
    ddp_approval_action_rec.attribute17 := p1_a28;
    ddp_approval_action_rec.attribute18 := p1_a29;
    ddp_approval_action_rec.attribute19 := p1_a30;
    ddp_approval_action_rec.attribute20 := p1_a31;





    -- here's the delegated call to the old PL/SQL routine
    lns_approval_action_pub.update_approval_action(p_init_msg_list,
      ddp_approval_action_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end lns_approval_action_pub_w;

/
