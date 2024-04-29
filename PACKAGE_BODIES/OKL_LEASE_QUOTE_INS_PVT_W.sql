--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_INS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_INS_PVT_W" as
  /* $Header: OKLEQUIB.pls 120.0.12010000.2 2008/11/18 10:20:32 kkorrapo ship $ */
  procedure create_insurance_estimate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  BINARY_INTEGER
    , p3_a5  NUMBER
    , p3_a6  VARCHAR2
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , x_insurance_estimate_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_insurance_estimate_rec okl_lease_quote_ins_pvt.ins_est_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_insurance_estimate_rec.id := p3_a0;
    ddp_insurance_estimate_rec.ovn := p3_a1;
    ddp_insurance_estimate_rec.quote_type_code := p3_a2;
    ddp_insurance_estimate_rec.lease_quote_id := p3_a3;
    ddp_insurance_estimate_rec.policy_term := p3_a4;
    ddp_insurance_estimate_rec.stream_type_id := p3_a5;
    ddp_insurance_estimate_rec.payment_frequency := p3_a6;
    ddp_insurance_estimate_rec.periodic_amount := p3_a7;
    ddp_insurance_estimate_rec.cashflow_object_id := p3_a8;
    ddp_insurance_estimate_rec.cashflow_header_id := p3_a9;
    ddp_insurance_estimate_rec.cashflow_header_ovn := p3_a10;
    ddp_insurance_estimate_rec.cashflow_level_id := p3_a11;
    ddp_insurance_estimate_rec.cashflow_level_ovn := p3_a12;
    ddp_insurance_estimate_rec.description := p3_a13;
    ddp_insurance_estimate_rec.attribute_category := p3_a14;
    ddp_insurance_estimate_rec.attribute1 := p3_a15;
    ddp_insurance_estimate_rec.attribute2 := p3_a16;
    ddp_insurance_estimate_rec.attribute3 := p3_a17;
    ddp_insurance_estimate_rec.attribute4 := p3_a18;
    ddp_insurance_estimate_rec.attribute5 := p3_a19;
    ddp_insurance_estimate_rec.attribute6 := p3_a20;
    ddp_insurance_estimate_rec.attribute7 := p3_a21;
    ddp_insurance_estimate_rec.attribute8 := p3_a22;
    ddp_insurance_estimate_rec.attribute9 := p3_a23;
    ddp_insurance_estimate_rec.attribute10 := p3_a24;
    ddp_insurance_estimate_rec.attribute11 := p3_a25;
    ddp_insurance_estimate_rec.attribute12 := p3_a26;
    ddp_insurance_estimate_rec.attribute13 := p3_a27;
    ddp_insurance_estimate_rec.attribute14 := p3_a28;
    ddp_insurance_estimate_rec.attribute15 := p3_a29;





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_ins_pvt.create_insurance_estimate(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_insurance_estimate_rec,
      x_insurance_estimate_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_insurance_estimate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  BINARY_INTEGER
    , p3_a5  NUMBER
    , p3_a6  VARCHAR2
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_insurance_estimate_rec okl_lease_quote_ins_pvt.ins_est_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_insurance_estimate_rec.id := p3_a0;
    ddp_insurance_estimate_rec.ovn := p3_a1;
    ddp_insurance_estimate_rec.quote_type_code := p3_a2;
    ddp_insurance_estimate_rec.lease_quote_id := p3_a3;
    ddp_insurance_estimate_rec.policy_term := p3_a4;
    ddp_insurance_estimate_rec.stream_type_id := p3_a5;
    ddp_insurance_estimate_rec.payment_frequency := p3_a6;
    ddp_insurance_estimate_rec.periodic_amount := p3_a7;
    ddp_insurance_estimate_rec.cashflow_object_id := p3_a8;
    ddp_insurance_estimate_rec.cashflow_header_id := p3_a9;
    ddp_insurance_estimate_rec.cashflow_header_ovn := p3_a10;
    ddp_insurance_estimate_rec.cashflow_level_id := p3_a11;
    ddp_insurance_estimate_rec.cashflow_level_ovn := p3_a12;
    ddp_insurance_estimate_rec.description := p3_a13;
    ddp_insurance_estimate_rec.attribute_category := p3_a14;
    ddp_insurance_estimate_rec.attribute1 := p3_a15;
    ddp_insurance_estimate_rec.attribute2 := p3_a16;
    ddp_insurance_estimate_rec.attribute3 := p3_a17;
    ddp_insurance_estimate_rec.attribute4 := p3_a18;
    ddp_insurance_estimate_rec.attribute5 := p3_a19;
    ddp_insurance_estimate_rec.attribute6 := p3_a20;
    ddp_insurance_estimate_rec.attribute7 := p3_a21;
    ddp_insurance_estimate_rec.attribute8 := p3_a22;
    ddp_insurance_estimate_rec.attribute9 := p3_a23;
    ddp_insurance_estimate_rec.attribute10 := p3_a24;
    ddp_insurance_estimate_rec.attribute11 := p3_a25;
    ddp_insurance_estimate_rec.attribute12 := p3_a26;
    ddp_insurance_estimate_rec.attribute13 := p3_a27;
    ddp_insurance_estimate_rec.attribute14 := p3_a28;
    ddp_insurance_estimate_rec.attribute15 := p3_a29;




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_ins_pvt.update_insurance_estimate(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_insurance_estimate_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_lease_quote_ins_pvt_w;

/
