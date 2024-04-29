--------------------------------------------------------
--  DDL for Package Body LNS_FEE_ASSIGNMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FEE_ASSIGNMENT_PUB_W" as
  /* $Header: LNS_FASGM_PUBJ_B.pls 120.2.12010000.3 2010/02/24 01:54:33 mbolli ship $ */
  procedure create_fee_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  NUMBER
    , p1_a16  DATE
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  DATE
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , x_fee_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_assignment_rec lns_fee_assignment_pub.fee_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_fee_assignment_rec.fee_assignment_id := p1_a0;
    ddp_fee_assignment_rec.loan_id := p1_a1;
    ddp_fee_assignment_rec.fee_id := p1_a2;
    ddp_fee_assignment_rec.fee := p1_a3;
    ddp_fee_assignment_rec.fee_type := p1_a4;
    ddp_fee_assignment_rec.fee_basis := p1_a5;
    ddp_fee_assignment_rec.number_grace_days := p1_a6;
    ddp_fee_assignment_rec.collected_third_party_flag := p1_a7;
    ddp_fee_assignment_rec.rate_type := p1_a8;
    ddp_fee_assignment_rec.begin_installment_number := p1_a9;
    ddp_fee_assignment_rec.end_installment_number := p1_a10;
    ddp_fee_assignment_rec.number_of_payments := p1_a11;
    ddp_fee_assignment_rec.billing_option := p1_a12;
    ddp_fee_assignment_rec.created_by := p1_a13;
    ddp_fee_assignment_rec.creation_date := p1_a14;
    ddp_fee_assignment_rec.last_updated_by := p1_a15;
    ddp_fee_assignment_rec.last_update_date := p1_a16;
    ddp_fee_assignment_rec.last_update_login := p1_a17;
    ddp_fee_assignment_rec.object_version_number := p1_a18;
    ddp_fee_assignment_rec.start_date_active := p1_a19;
    ddp_fee_assignment_rec.end_date_active := p1_a20;
    ddp_fee_assignment_rec.disb_header_id := p1_a21;
    ddp_fee_assignment_rec.delete_disabled_flag := p1_a22;
    ddp_fee_assignment_rec.open_phase_flag := p1_a23;
    ddp_fee_assignment_rec.phase := p1_a24;





    -- here's the delegated call to the old PL/SQL routine
    lns_fee_assignment_pub.create_fee_assignment(p_init_msg_list,
      ddp_fee_assignment_rec,
      x_fee_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_fee_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  NUMBER
    , p1_a16  DATE
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  DATE
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_fee_assignment_rec lns_fee_assignment_pub.fee_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_fee_assignment_rec.fee_assignment_id := p1_a0;
    ddp_fee_assignment_rec.loan_id := p1_a1;
    ddp_fee_assignment_rec.fee_id := p1_a2;
    ddp_fee_assignment_rec.fee := p1_a3;
    ddp_fee_assignment_rec.fee_type := p1_a4;
    ddp_fee_assignment_rec.fee_basis := p1_a5;
    ddp_fee_assignment_rec.number_grace_days := p1_a6;
    ddp_fee_assignment_rec.collected_third_party_flag := p1_a7;
    ddp_fee_assignment_rec.rate_type := p1_a8;
    ddp_fee_assignment_rec.begin_installment_number := p1_a9;
    ddp_fee_assignment_rec.end_installment_number := p1_a10;
    ddp_fee_assignment_rec.number_of_payments := p1_a11;
    ddp_fee_assignment_rec.billing_option := p1_a12;
    ddp_fee_assignment_rec.created_by := p1_a13;
    ddp_fee_assignment_rec.creation_date := p1_a14;
    ddp_fee_assignment_rec.last_updated_by := p1_a15;
    ddp_fee_assignment_rec.last_update_date := p1_a16;
    ddp_fee_assignment_rec.last_update_login := p1_a17;
    ddp_fee_assignment_rec.object_version_number := p1_a18;
    ddp_fee_assignment_rec.start_date_active := p1_a19;
    ddp_fee_assignment_rec.end_date_active := p1_a20;
    ddp_fee_assignment_rec.disb_header_id := p1_a21;
    ddp_fee_assignment_rec.delete_disabled_flag := p1_a22;
    ddp_fee_assignment_rec.open_phase_flag := p1_a23;
    ddp_fee_assignment_rec.phase := p1_a24;





    -- here's the delegated call to the old PL/SQL routine
    lns_fee_assignment_pub.update_fee_assignment(p_init_msg_list,
      ddp_fee_assignment_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end lns_fee_assignment_pub_w;

/
