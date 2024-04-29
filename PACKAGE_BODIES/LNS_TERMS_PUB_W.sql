--------------------------------------------------------
--  DDL for Package Body LNS_TERMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_TERMS_PUB_W" as
  /* $Header: LNS_TERMS_PUBJ_B.pls 120.4.12010000.8 2010/03/19 08:34:45 gparuchu ship $ */
  procedure create_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , x_term_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_term_rec lns_terms_pub.loan_term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_term_rec.term_id := p1_a0;
    ddp_loan_term_rec.loan_id := p1_a1;
    ddp_loan_term_rec.day_count_method := p1_a2;
    ddp_loan_term_rec.based_on_balance := p1_a3;
    ddp_loan_term_rec.first_rate_change_date := p1_a4;
    ddp_loan_term_rec.next_rate_change_date := p1_a5;
    ddp_loan_term_rec.percent_increase := p1_a6;
    ddp_loan_term_rec.percent_increase_term := p1_a7;
    ddp_loan_term_rec.payment_application_order := p1_a8;
    ddp_loan_term_rec.prepay_penalty_flag := p1_a9;
    ddp_loan_term_rec.prepay_penalty_date := p1_a10;
    ddp_loan_term_rec.ceiling_rate := p1_a11;
    ddp_loan_term_rec.floor_rate := p1_a12;
    ddp_loan_term_rec.delinquency_threshold_number := p1_a13;
    ddp_loan_term_rec.delinquency_threshold_amount := p1_a14;
    ddp_loan_term_rec.calculation_method := p1_a15;
    ddp_loan_term_rec.reamortize_under_payment := p1_a16;
    ddp_loan_term_rec.reamortize_over_payment := p1_a17;
    ddp_loan_term_rec.reamortize_with_interest := p1_a18;
    ddp_loan_term_rec.loan_payment_frequency := p1_a19;
    ddp_loan_term_rec.interest_compounding_freq := p1_a20;
    ddp_loan_term_rec.amortization_frequency := p1_a21;
    ddp_loan_term_rec.number_grace_days := p1_a22;
    ddp_loan_term_rec.rate_type := p1_a23;
    ddp_loan_term_rec.index_name := p1_a24;
    ddp_loan_term_rec.adjustment_frequency := p1_a25;
    ddp_loan_term_rec.adjustment_frequency_type := p1_a26;
    ddp_loan_term_rec.fixed_rate_period := p1_a27;
    ddp_loan_term_rec.fixed_rate_period_type := p1_a28;
    ddp_loan_term_rec.first_payment_date := p1_a29;
    ddp_loan_term_rec.next_payment_due_date := p1_a30;
    ddp_loan_term_rec.open_first_payment_date := p1_a31;
    ddp_loan_term_rec.open_payment_frequency := p1_a32;
    ddp_loan_term_rec.open_next_payment_date := p1_a33;
    ddp_loan_term_rec.lock_in_date := p1_a34;
    ddp_loan_term_rec.lock_to_date := p1_a35;
    ddp_loan_term_rec.rate_change_frequency := p1_a36;
    ddp_loan_term_rec.index_rate_id := p1_a37;
    ddp_loan_term_rec.percent_increase_life := p1_a38;
    ddp_loan_term_rec.first_percent_increase := p1_a39;
    ddp_loan_term_rec.open_percent_increase := p1_a40;
    ddp_loan_term_rec.open_percent_increase_life := p1_a41;
    ddp_loan_term_rec.open_first_percent_increase := p1_a42;
    ddp_loan_term_rec.pmt_appl_order_scope := p1_a43;
    ddp_loan_term_rec.open_ceiling_rate := p1_a44;
    ddp_loan_term_rec.open_floor_rate := p1_a45;
    ddp_loan_term_rec.open_index_date := p1_a46;
    ddp_loan_term_rec.term_index_date := p1_a47;
    ddp_loan_term_rec.open_projected_rate := p1_a48;
    ddp_loan_term_rec.term_projected_rate := p1_a49;
    ddp_loan_term_rec.payment_calc_method := p1_a50;
    ddp_loan_term_rec.custom_calc_method := p1_a51;
    ddp_loan_term_rec.orig_pay_calc_method := p1_a52;
    ddp_loan_term_rec.prin_first_pay_date := p1_a53;
    ddp_loan_term_rec.prin_payment_frequency := p1_a54;
    ddp_loan_term_rec.penal_int_rate := p1_a55;
    ddp_loan_term_rec.penal_int_grace_days := p1_a56;
    ddp_loan_term_rec.calc_add_int_unpaid_prin := p1_a57;
    ddp_loan_term_rec.calc_add_int_unpaid_int := p1_a58;
    ddp_loan_term_rec.reamortize_on_funding := p1_a59;





    -- here's the delegated call to the old PL/SQL routine
    lns_terms_pub.create_term(p_init_msg_list,
      ddp_loan_term_rec,
      x_term_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_term_rec lns_terms_pub.loan_term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_term_rec.term_id := p1_a0;
    ddp_loan_term_rec.loan_id := p1_a1;
    ddp_loan_term_rec.day_count_method := p1_a2;
    ddp_loan_term_rec.based_on_balance := p1_a3;
    ddp_loan_term_rec.first_rate_change_date := p1_a4;
    ddp_loan_term_rec.next_rate_change_date := p1_a5;
    ddp_loan_term_rec.percent_increase := p1_a6;
    ddp_loan_term_rec.percent_increase_term := p1_a7;
    ddp_loan_term_rec.payment_application_order := p1_a8;
    ddp_loan_term_rec.prepay_penalty_flag := p1_a9;
    ddp_loan_term_rec.prepay_penalty_date := p1_a10;
    ddp_loan_term_rec.ceiling_rate := p1_a11;
    ddp_loan_term_rec.floor_rate := p1_a12;
    ddp_loan_term_rec.delinquency_threshold_number := p1_a13;
    ddp_loan_term_rec.delinquency_threshold_amount := p1_a14;
    ddp_loan_term_rec.calculation_method := p1_a15;
    ddp_loan_term_rec.reamortize_under_payment := p1_a16;
    ddp_loan_term_rec.reamortize_over_payment := p1_a17;
    ddp_loan_term_rec.reamortize_with_interest := p1_a18;
    ddp_loan_term_rec.loan_payment_frequency := p1_a19;
    ddp_loan_term_rec.interest_compounding_freq := p1_a20;
    ddp_loan_term_rec.amortization_frequency := p1_a21;
    ddp_loan_term_rec.number_grace_days := p1_a22;
    ddp_loan_term_rec.rate_type := p1_a23;
    ddp_loan_term_rec.index_name := p1_a24;
    ddp_loan_term_rec.adjustment_frequency := p1_a25;
    ddp_loan_term_rec.adjustment_frequency_type := p1_a26;
    ddp_loan_term_rec.fixed_rate_period := p1_a27;
    ddp_loan_term_rec.fixed_rate_period_type := p1_a28;
    ddp_loan_term_rec.first_payment_date := p1_a29;
    ddp_loan_term_rec.next_payment_due_date := p1_a30;
    ddp_loan_term_rec.open_first_payment_date := p1_a31;
    ddp_loan_term_rec.open_payment_frequency := p1_a32;
    ddp_loan_term_rec.open_next_payment_date := p1_a33;
    ddp_loan_term_rec.lock_in_date := p1_a34;
    ddp_loan_term_rec.lock_to_date := p1_a35;
    ddp_loan_term_rec.rate_change_frequency := p1_a36;
    ddp_loan_term_rec.index_rate_id := p1_a37;
    ddp_loan_term_rec.percent_increase_life := p1_a38;
    ddp_loan_term_rec.first_percent_increase := p1_a39;
    ddp_loan_term_rec.open_percent_increase := p1_a40;
    ddp_loan_term_rec.open_percent_increase_life := p1_a41;
    ddp_loan_term_rec.open_first_percent_increase := p1_a42;
    ddp_loan_term_rec.pmt_appl_order_scope := p1_a43;
    ddp_loan_term_rec.open_ceiling_rate := p1_a44;
    ddp_loan_term_rec.open_floor_rate := p1_a45;
    ddp_loan_term_rec.open_index_date := p1_a46;
    ddp_loan_term_rec.term_index_date := p1_a47;
    ddp_loan_term_rec.open_projected_rate := p1_a48;
    ddp_loan_term_rec.term_projected_rate := p1_a49;
    ddp_loan_term_rec.payment_calc_method := p1_a50;
    ddp_loan_term_rec.custom_calc_method := p1_a51;
    ddp_loan_term_rec.orig_pay_calc_method := p1_a52;
    ddp_loan_term_rec.prin_first_pay_date := p1_a53;
    ddp_loan_term_rec.prin_payment_frequency := p1_a54;
    ddp_loan_term_rec.penal_int_rate := p1_a55;
    ddp_loan_term_rec.penal_int_grace_days := p1_a56;
    ddp_loan_term_rec.calc_add_int_unpaid_prin := p1_a57;
    ddp_loan_term_rec.calc_add_int_unpaid_int := p1_a58;
    ddp_loan_term_rec.reamortize_on_funding := p1_a59;





    -- here's the delegated call to the old PL/SQL routine
    lns_terms_pub.update_term(p_init_msg_list,
      ddp_loan_term_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_term_rec lns_terms_pub.loan_term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_term_rec.term_id := p1_a0;
    ddp_loan_term_rec.loan_id := p1_a1;
    ddp_loan_term_rec.day_count_method := p1_a2;
    ddp_loan_term_rec.based_on_balance := p1_a3;
    ddp_loan_term_rec.first_rate_change_date := p1_a4;
    ddp_loan_term_rec.next_rate_change_date := p1_a5;
    ddp_loan_term_rec.percent_increase := p1_a6;
    ddp_loan_term_rec.percent_increase_term := p1_a7;
    ddp_loan_term_rec.payment_application_order := p1_a8;
    ddp_loan_term_rec.prepay_penalty_flag := p1_a9;
    ddp_loan_term_rec.prepay_penalty_date := p1_a10;
    ddp_loan_term_rec.ceiling_rate := p1_a11;
    ddp_loan_term_rec.floor_rate := p1_a12;
    ddp_loan_term_rec.delinquency_threshold_number := p1_a13;
    ddp_loan_term_rec.delinquency_threshold_amount := p1_a14;
    ddp_loan_term_rec.calculation_method := p1_a15;
    ddp_loan_term_rec.reamortize_under_payment := p1_a16;
    ddp_loan_term_rec.reamortize_over_payment := p1_a17;
    ddp_loan_term_rec.reamortize_with_interest := p1_a18;
    ddp_loan_term_rec.loan_payment_frequency := p1_a19;
    ddp_loan_term_rec.interest_compounding_freq := p1_a20;
    ddp_loan_term_rec.amortization_frequency := p1_a21;
    ddp_loan_term_rec.number_grace_days := p1_a22;
    ddp_loan_term_rec.rate_type := p1_a23;
    ddp_loan_term_rec.index_name := p1_a24;
    ddp_loan_term_rec.adjustment_frequency := p1_a25;
    ddp_loan_term_rec.adjustment_frequency_type := p1_a26;
    ddp_loan_term_rec.fixed_rate_period := p1_a27;
    ddp_loan_term_rec.fixed_rate_period_type := p1_a28;
    ddp_loan_term_rec.first_payment_date := p1_a29;
    ddp_loan_term_rec.next_payment_due_date := p1_a30;
    ddp_loan_term_rec.open_first_payment_date := p1_a31;
    ddp_loan_term_rec.open_payment_frequency := p1_a32;
    ddp_loan_term_rec.open_next_payment_date := p1_a33;
    ddp_loan_term_rec.lock_in_date := p1_a34;
    ddp_loan_term_rec.lock_to_date := p1_a35;
    ddp_loan_term_rec.rate_change_frequency := p1_a36;
    ddp_loan_term_rec.index_rate_id := p1_a37;
    ddp_loan_term_rec.percent_increase_life := p1_a38;
    ddp_loan_term_rec.first_percent_increase := p1_a39;
    ddp_loan_term_rec.open_percent_increase := p1_a40;
    ddp_loan_term_rec.open_percent_increase_life := p1_a41;
    ddp_loan_term_rec.open_first_percent_increase := p1_a42;
    ddp_loan_term_rec.pmt_appl_order_scope := p1_a43;
    ddp_loan_term_rec.open_ceiling_rate := p1_a44;
    ddp_loan_term_rec.open_floor_rate := p1_a45;
    ddp_loan_term_rec.open_index_date := p1_a46;
    ddp_loan_term_rec.term_index_date := p1_a47;
    ddp_loan_term_rec.open_projected_rate := p1_a48;
    ddp_loan_term_rec.term_projected_rate := p1_a49;
    ddp_loan_term_rec.payment_calc_method := p1_a50;
    ddp_loan_term_rec.custom_calc_method := p1_a51;
    ddp_loan_term_rec.orig_pay_calc_method := p1_a52;
    ddp_loan_term_rec.prin_first_pay_date := p1_a53;
    ddp_loan_term_rec.prin_payment_frequency := p1_a54;
    ddp_loan_term_rec.penal_int_rate := p1_a55;
    ddp_loan_term_rec.penal_int_grace_days := p1_a56;
    ddp_loan_term_rec.calc_add_int_unpaid_prin := p1_a57;
    ddp_loan_term_rec.calc_add_int_unpaid_int := p1_a58;
    ddp_loan_term_rec.reamortize_on_funding := p1_a59;




    -- here's the delegated call to the old PL/SQL routine
    lns_terms_pub.validate_term(p_init_msg_list,
      ddp_loan_term_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure get_loan_term_rec(p_init_msg_list  VARCHAR2
    , p_term_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  NUMBER
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  NUMBER
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  NUMBER
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  DATE
    , p2_a30 out nocopy  DATE
    , p2_a31 out nocopy  DATE
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  DATE
    , p2_a34 out nocopy  DATE
    , p2_a35 out nocopy  DATE
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  NUMBER
    , p2_a38 out nocopy  NUMBER
    , p2_a39 out nocopy  NUMBER
    , p2_a40 out nocopy  NUMBER
    , p2_a41 out nocopy  NUMBER
    , p2_a42 out nocopy  NUMBER
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  NUMBER
    , p2_a45 out nocopy  NUMBER
    , p2_a46 out nocopy  DATE
    , p2_a47 out nocopy  DATE
    , p2_a48 out nocopy  NUMBER
    , p2_a49 out nocopy  NUMBER
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  DATE
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  NUMBER
    , p2_a56 out nocopy  NUMBER
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_loan_term_rec lns_terms_pub.loan_term_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    lns_terms_pub.get_loan_term_rec(p_init_msg_list,
      p_term_id,
      ddx_loan_term_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_loan_term_rec.term_id;
    p2_a1 := ddx_loan_term_rec.loan_id;
    p2_a2 := ddx_loan_term_rec.day_count_method;
    p2_a3 := ddx_loan_term_rec.based_on_balance;
    p2_a4 := ddx_loan_term_rec.first_rate_change_date;
    p2_a5 := ddx_loan_term_rec.next_rate_change_date;
    p2_a6 := ddx_loan_term_rec.percent_increase;
    p2_a7 := ddx_loan_term_rec.percent_increase_term;
    p2_a8 := ddx_loan_term_rec.payment_application_order;
    p2_a9 := ddx_loan_term_rec.prepay_penalty_flag;
    p2_a10 := ddx_loan_term_rec.prepay_penalty_date;
    p2_a11 := ddx_loan_term_rec.ceiling_rate;
    p2_a12 := ddx_loan_term_rec.floor_rate;
    p2_a13 := ddx_loan_term_rec.delinquency_threshold_number;
    p2_a14 := ddx_loan_term_rec.delinquency_threshold_amount;
    p2_a15 := ddx_loan_term_rec.calculation_method;
    p2_a16 := ddx_loan_term_rec.reamortize_under_payment;
    p2_a17 := ddx_loan_term_rec.reamortize_over_payment;
    p2_a18 := ddx_loan_term_rec.reamortize_with_interest;
    p2_a19 := ddx_loan_term_rec.loan_payment_frequency;
    p2_a20 := ddx_loan_term_rec.interest_compounding_freq;
    p2_a21 := ddx_loan_term_rec.amortization_frequency;
    p2_a22 := ddx_loan_term_rec.number_grace_days;
    p2_a23 := ddx_loan_term_rec.rate_type;
    p2_a24 := ddx_loan_term_rec.index_name;
    p2_a25 := ddx_loan_term_rec.adjustment_frequency;
    p2_a26 := ddx_loan_term_rec.adjustment_frequency_type;
    p2_a27 := ddx_loan_term_rec.fixed_rate_period;
    p2_a28 := ddx_loan_term_rec.fixed_rate_period_type;
    p2_a29 := ddx_loan_term_rec.first_payment_date;
    p2_a30 := ddx_loan_term_rec.next_payment_due_date;
    p2_a31 := ddx_loan_term_rec.open_first_payment_date;
    p2_a32 := ddx_loan_term_rec.open_payment_frequency;
    p2_a33 := ddx_loan_term_rec.open_next_payment_date;
    p2_a34 := ddx_loan_term_rec.lock_in_date;
    p2_a35 := ddx_loan_term_rec.lock_to_date;
    p2_a36 := ddx_loan_term_rec.rate_change_frequency;
    p2_a37 := ddx_loan_term_rec.index_rate_id;
    p2_a38 := ddx_loan_term_rec.percent_increase_life;
    p2_a39 := ddx_loan_term_rec.first_percent_increase;
    p2_a40 := ddx_loan_term_rec.open_percent_increase;
    p2_a41 := ddx_loan_term_rec.open_percent_increase_life;
    p2_a42 := ddx_loan_term_rec.open_first_percent_increase;
    p2_a43 := ddx_loan_term_rec.pmt_appl_order_scope;
    p2_a44 := ddx_loan_term_rec.open_ceiling_rate;
    p2_a45 := ddx_loan_term_rec.open_floor_rate;
    p2_a46 := ddx_loan_term_rec.open_index_date;
    p2_a47 := ddx_loan_term_rec.term_index_date;
    p2_a48 := ddx_loan_term_rec.open_projected_rate;
    p2_a49 := ddx_loan_term_rec.term_projected_rate;
    p2_a50 := ddx_loan_term_rec.payment_calc_method;
    p2_a51 := ddx_loan_term_rec.custom_calc_method;
    p2_a52 := ddx_loan_term_rec.orig_pay_calc_method;
    p2_a53 := ddx_loan_term_rec.prin_first_pay_date;
    p2_a54 := ddx_loan_term_rec.prin_payment_frequency;
    p2_a55 := ddx_loan_term_rec.penal_int_rate;
    p2_a56 := ddx_loan_term_rec.penal_int_grace_days;
    p2_a57 := ddx_loan_term_rec.calc_add_int_unpaid_prin;
    p2_a58 := ddx_loan_term_rec.calc_add_int_unpaid_int;
    p2_a59 := ddx_loan_term_rec.reamortize_on_funding;



  end;

end lns_terms_pub_w;

/
