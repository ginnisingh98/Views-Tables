--------------------------------------------------------
--  DDL for Package Body LNS_EXT_LOAN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_EXT_LOAN_PUB_W" as
  /* $Header: LNS_EXT_LOAN_PUBJ_B.pls 120.0.12010000.1 2009/03/16 12:10:18 gparuchu noship $ */
  procedure save_loan_extension(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_ext_rec lns_ext_loan_pub.loan_ext_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_loan_ext_rec.loan_ext_id := p4_a0;
    ddp_loan_ext_rec.loan_id := p4_a1;
    ddp_loan_ext_rec.description := p4_a2;
    ddp_loan_ext_rec.ext_term := p4_a3;
    ddp_loan_ext_rec.ext_term_period := p4_a4;
    ddp_loan_ext_rec.ext_balloon_type := p4_a5;
    ddp_loan_ext_rec.ext_balloon_amount := p4_a6;
    ddp_loan_ext_rec.ext_amort_term := p4_a7;
    ddp_loan_ext_rec.ext_rate := p4_a8;
    ddp_loan_ext_rec.ext_spread := p4_a9;
    ddp_loan_ext_rec.ext_io_flag := p4_a10;
    ddp_loan_ext_rec.ext_floating_flag := p4_a11;
    ddp_loan_ext_rec.ext_index_date := p4_a12;




    -- here's the delegated call to the old PL/SQL routine
    lns_ext_loan_pub.save_loan_extension(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_loan_ext_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_loan_ext_rec.loan_ext_id;
    p4_a1 := ddp_loan_ext_rec.loan_id;
    p4_a2 := ddp_loan_ext_rec.description;
    p4_a3 := ddp_loan_ext_rec.ext_term;
    p4_a4 := ddp_loan_ext_rec.ext_term_period;
    p4_a5 := ddp_loan_ext_rec.ext_balloon_type;
    p4_a6 := ddp_loan_ext_rec.ext_balloon_amount;
    p4_a7 := ddp_loan_ext_rec.ext_amort_term;
    p4_a8 := ddp_loan_ext_rec.ext_rate;
    p4_a9 := ddp_loan_ext_rec.ext_spread;
    p4_a10 := ddp_loan_ext_rec.ext_io_flag;
    p4_a11 := ddp_loan_ext_rec.ext_floating_flag;
    p4_a12 := ddp_loan_ext_rec.ext_index_date;



  end;

  procedure calc_new_terms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  DATE
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  NUMBER
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  DATE
    , p4_a19 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_new_term_rec lns_ext_loan_pub.new_term_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_new_term_rec.loan_id := p4_a0;
    ddp_new_term_rec.ext_term := p4_a1;
    ddp_new_term_rec.ext_term_period := p4_a2;
    ddp_new_term_rec.ext_balloon_type := p4_a3;
    ddp_new_term_rec.ext_balloon_amount := p4_a4;
    ddp_new_term_rec.ext_amort_term := p4_a5;
    ddp_new_term_rec.old_term := p4_a6;
    ddp_new_term_rec.old_term_period := p4_a7;
    ddp_new_term_rec.old_balloon_type := p4_a8;
    ddp_new_term_rec.old_balloon_amount := p4_a9;
    ddp_new_term_rec.old_amort_term := p4_a10;
    ddp_new_term_rec.old_maturity_date := p4_a11;
    ddp_new_term_rec.old_installments := p4_a12;
    ddp_new_term_rec.new_term := p4_a13;
    ddp_new_term_rec.new_term_period := p4_a14;
    ddp_new_term_rec.new_balloon_type := p4_a15;
    ddp_new_term_rec.new_balloon_amount := p4_a16;
    ddp_new_term_rec.new_amort_term := p4_a17;
    ddp_new_term_rec.new_maturity_date := p4_a18;
    ddp_new_term_rec.new_installments := p4_a19;




    -- here's the delegated call to the old PL/SQL routine
    lns_ext_loan_pub.calc_new_terms(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_new_term_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_new_term_rec.loan_id;
    p4_a1 := ddp_new_term_rec.ext_term;
    p4_a2 := ddp_new_term_rec.ext_term_period;
    p4_a3 := ddp_new_term_rec.ext_balloon_type;
    p4_a4 := ddp_new_term_rec.ext_balloon_amount;
    p4_a5 := ddp_new_term_rec.ext_amort_term;
    p4_a6 := ddp_new_term_rec.old_term;
    p4_a7 := ddp_new_term_rec.old_term_period;
    p4_a8 := ddp_new_term_rec.old_balloon_type;
    p4_a9 := ddp_new_term_rec.old_balloon_amount;
    p4_a10 := ddp_new_term_rec.old_amort_term;
    p4_a11 := ddp_new_term_rec.old_maturity_date;
    p4_a12 := ddp_new_term_rec.old_installments;
    p4_a13 := ddp_new_term_rec.new_term;
    p4_a14 := ddp_new_term_rec.new_term_period;
    p4_a15 := ddp_new_term_rec.new_balloon_type;
    p4_a16 := ddp_new_term_rec.new_balloon_amount;
    p4_a17 := ddp_new_term_rec.new_amort_term;
    p4_a18 := ddp_new_term_rec.new_maturity_date;
    p4_a19 := ddp_new_term_rec.new_installments;



  end;

end lns_ext_loan_pub_w;

/
