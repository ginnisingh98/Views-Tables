--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_INFO_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_INFO_V2PUB_JW" as
  /* $Header: ARH2PRJB.pls 120.2 2005/06/18 04:28:54 jhuang noship $ */
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

  procedure create_credit_rating_1(p_init_msg_list  VARCHAR2
    , x_credit_rating_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  NUMBER := null
    , p1_a20  NUMBER := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  DATE := null
    , p1_a32  NUMBER := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  NUMBER := null
    , p1_a36  NUMBER := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  NUMBER := null
    , p1_a49  NUMBER := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  NUMBER := null
    , p1_a54  DATE := null
    , p1_a55  NUMBER := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  NUMBER := null
    , p1_a64  NUMBER := null
    , p1_a65  NUMBER := null
    , p1_a66  NUMBER := null
    , p1_a67  NUMBER := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  NUMBER := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  NUMBER := null
    , p1_a82  DATE := null
    , p1_a83  NUMBER := null
    , p1_a84  DATE := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  NUMBER := null
    , p1_a92  DATE := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
  )
  as
    ddp_credit_rating_rec hz_party_info_v2pub.credit_rating_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_credit_rating_rec.credit_rating_id := rosetta_g_miss_num_map(p1_a0);
    ddp_credit_rating_rec.description := p1_a1;
    ddp_credit_rating_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_credit_rating_rec.rating := p1_a3;
    ddp_credit_rating_rec.rated_as_of_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_credit_rating_rec.rating_organization := p1_a5;
    ddp_credit_rating_rec.comments := p1_a6;
    ddp_credit_rating_rec.det_history_ind := p1_a7;
    ddp_credit_rating_rec.fincl_embt_ind := p1_a8;
    ddp_credit_rating_rec.criminal_proceeding_ind := p1_a9;
    ddp_credit_rating_rec.claims_ind := p1_a10;
    ddp_credit_rating_rec.secured_flng_ind := p1_a11;
    ddp_credit_rating_rec.fincl_lgl_event_ind := p1_a12;
    ddp_credit_rating_rec.disaster_ind := p1_a13;
    ddp_credit_rating_rec.oprg_spec_evnt_ind := p1_a14;
    ddp_credit_rating_rec.other_spec_evnt_ind := p1_a15;
    ddp_credit_rating_rec.status := p1_a16;
    ddp_credit_rating_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a17);
    ddp_credit_rating_rec.credit_score := p1_a18;
    ddp_credit_rating_rec.credit_score_age := rosetta_g_miss_num_map(p1_a19);
    ddp_credit_rating_rec.credit_score_class := rosetta_g_miss_num_map(p1_a20);
    ddp_credit_rating_rec.credit_score_commentary := p1_a21;
    ddp_credit_rating_rec.credit_score_commentary2 := p1_a22;
    ddp_credit_rating_rec.credit_score_commentary3 := p1_a23;
    ddp_credit_rating_rec.credit_score_commentary4 := p1_a24;
    ddp_credit_rating_rec.credit_score_commentary5 := p1_a25;
    ddp_credit_rating_rec.credit_score_commentary6 := p1_a26;
    ddp_credit_rating_rec.credit_score_commentary7 := p1_a27;
    ddp_credit_rating_rec.credit_score_commentary8 := p1_a28;
    ddp_credit_rating_rec.credit_score_commentary9 := p1_a29;
    ddp_credit_rating_rec.credit_score_commentary10 := p1_a30;
    ddp_credit_rating_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a31);
    ddp_credit_rating_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a32);
    ddp_credit_rating_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a33);
    ddp_credit_rating_rec.failure_score := p1_a34;
    ddp_credit_rating_rec.failure_score_age := rosetta_g_miss_num_map(p1_a35);
    ddp_credit_rating_rec.failure_score_class := rosetta_g_miss_num_map(p1_a36);
    ddp_credit_rating_rec.failure_score_commentary := p1_a37;
    ddp_credit_rating_rec.failure_score_commentary2 := p1_a38;
    ddp_credit_rating_rec.failure_score_commentary3 := p1_a39;
    ddp_credit_rating_rec.failure_score_commentary4 := p1_a40;
    ddp_credit_rating_rec.failure_score_commentary5 := p1_a41;
    ddp_credit_rating_rec.failure_score_commentary6 := p1_a42;
    ddp_credit_rating_rec.failure_score_commentary7 := p1_a43;
    ddp_credit_rating_rec.failure_score_commentary8 := p1_a44;
    ddp_credit_rating_rec.failure_score_commentary9 := p1_a45;
    ddp_credit_rating_rec.failure_score_commentary10 := p1_a46;
    ddp_credit_rating_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a47);
    ddp_credit_rating_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a48);
    ddp_credit_rating_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a49);
    ddp_credit_rating_rec.failure_score_override_code := p1_a50;
    ddp_credit_rating_rec.global_failure_score := p1_a51;
    ddp_credit_rating_rec.debarment_ind := p1_a52;
    ddp_credit_rating_rec.debarments_count := rosetta_g_miss_num_map(p1_a53);
    ddp_credit_rating_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a54);
    ddp_credit_rating_rec.high_credit := rosetta_g_miss_num_map(p1_a55);
    ddp_credit_rating_rec.maximum_credit_currency_code := p1_a56;
    ddp_credit_rating_rec.maximum_credit_rcmd := rosetta_g_miss_num_map(p1_a57);
    ddp_credit_rating_rec.paydex_norm := p1_a58;
    ddp_credit_rating_rec.paydex_score := p1_a59;
    ddp_credit_rating_rec.paydex_three_months_ago := p1_a60;
    ddp_credit_rating_rec.credit_score_override_code := p1_a61;
    ddp_credit_rating_rec.cr_scr_clas_expl := p1_a62;
    ddp_credit_rating_rec.low_rng_delq_scr := rosetta_g_miss_num_map(p1_a63);
    ddp_credit_rating_rec.high_rng_delq_scr := rosetta_g_miss_num_map(p1_a64);
    ddp_credit_rating_rec.delq_pmt_rng_prcnt := rosetta_g_miss_num_map(p1_a65);
    ddp_credit_rating_rec.delq_pmt_pctg_for_all_firms := rosetta_g_miss_num_map(p1_a66);
    ddp_credit_rating_rec.num_trade_experiences := rosetta_g_miss_num_map(p1_a67);
    ddp_credit_rating_rec.paydex_firm_days := p1_a68;
    ddp_credit_rating_rec.paydex_firm_comment := p1_a69;
    ddp_credit_rating_rec.paydex_industry_days := p1_a70;
    ddp_credit_rating_rec.paydex_industry_comment := p1_a71;
    ddp_credit_rating_rec.paydex_comment := p1_a72;
    ddp_credit_rating_rec.suit_ind := p1_a73;
    ddp_credit_rating_rec.lien_ind := p1_a74;
    ddp_credit_rating_rec.judgement_ind := p1_a75;
    ddp_credit_rating_rec.bankruptcy_ind := p1_a76;
    ddp_credit_rating_rec.no_trade_ind := p1_a77;
    ddp_credit_rating_rec.prnt_hq_bkcy_ind := p1_a78;
    ddp_credit_rating_rec.num_prnt_bkcy_filing := rosetta_g_miss_num_map(p1_a79);
    ddp_credit_rating_rec.prnt_bkcy_filg_type := p1_a80;
    ddp_credit_rating_rec.prnt_bkcy_filg_chapter := rosetta_g_miss_num_map(p1_a81);
    ddp_credit_rating_rec.prnt_bkcy_filg_date := rosetta_g_miss_date_in_map(p1_a82);
    ddp_credit_rating_rec.num_prnt_bkcy_convs := rosetta_g_miss_num_map(p1_a83);
    ddp_credit_rating_rec.prnt_bkcy_conv_date := rosetta_g_miss_date_in_map(p1_a84);
    ddp_credit_rating_rec.prnt_bkcy_chapter_conv := p1_a85;
    ddp_credit_rating_rec.slow_trade_expl := p1_a86;
    ddp_credit_rating_rec.negv_pmt_expl := p1_a87;
    ddp_credit_rating_rec.pub_rec_expl := p1_a88;
    ddp_credit_rating_rec.business_discontinued := p1_a89;
    ddp_credit_rating_rec.spcl_event_comment := p1_a90;
    ddp_credit_rating_rec.num_spcl_event := rosetta_g_miss_num_map(p1_a91);
    ddp_credit_rating_rec.spcl_event_update_date := rosetta_g_miss_date_in_map(p1_a92);
    ddp_credit_rating_rec.spcl_evnt_txt := p1_a93;
    ddp_credit_rating_rec.actual_content_source := p1_a94;
    ddp_credit_rating_rec.created_by_module := p1_a95;





    -- here's the delegated call to the old PL/SQL routine
    hz_party_info_v2pub.create_credit_rating(p_init_msg_list,
      ddp_credit_rating_rec,
      x_credit_rating_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_credit_rating_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  NUMBER := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  NUMBER := null
    , p1_a20  NUMBER := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  DATE := null
    , p1_a32  NUMBER := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  NUMBER := null
    , p1_a36  NUMBER := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  DATE := null
    , p1_a48  NUMBER := null
    , p1_a49  NUMBER := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  NUMBER := null
    , p1_a54  DATE := null
    , p1_a55  NUMBER := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  NUMBER := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  NUMBER := null
    , p1_a64  NUMBER := null
    , p1_a65  NUMBER := null
    , p1_a66  NUMBER := null
    , p1_a67  NUMBER := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  NUMBER := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  NUMBER := null
    , p1_a82  DATE := null
    , p1_a83  NUMBER := null
    , p1_a84  DATE := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  NUMBER := null
    , p1_a92  DATE := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  VARCHAR2 := null
    , p1_a95  VARCHAR2 := null
  )
  as
    ddp_credit_rating_rec hz_party_info_v2pub.credit_rating_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_credit_rating_rec.credit_rating_id := rosetta_g_miss_num_map(p1_a0);
    ddp_credit_rating_rec.description := p1_a1;
    ddp_credit_rating_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_credit_rating_rec.rating := p1_a3;
    ddp_credit_rating_rec.rated_as_of_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_credit_rating_rec.rating_organization := p1_a5;
    ddp_credit_rating_rec.comments := p1_a6;
    ddp_credit_rating_rec.det_history_ind := p1_a7;
    ddp_credit_rating_rec.fincl_embt_ind := p1_a8;
    ddp_credit_rating_rec.criminal_proceeding_ind := p1_a9;
    ddp_credit_rating_rec.claims_ind := p1_a10;
    ddp_credit_rating_rec.secured_flng_ind := p1_a11;
    ddp_credit_rating_rec.fincl_lgl_event_ind := p1_a12;
    ddp_credit_rating_rec.disaster_ind := p1_a13;
    ddp_credit_rating_rec.oprg_spec_evnt_ind := p1_a14;
    ddp_credit_rating_rec.other_spec_evnt_ind := p1_a15;
    ddp_credit_rating_rec.status := p1_a16;
    ddp_credit_rating_rec.avg_high_credit := rosetta_g_miss_num_map(p1_a17);
    ddp_credit_rating_rec.credit_score := p1_a18;
    ddp_credit_rating_rec.credit_score_age := rosetta_g_miss_num_map(p1_a19);
    ddp_credit_rating_rec.credit_score_class := rosetta_g_miss_num_map(p1_a20);
    ddp_credit_rating_rec.credit_score_commentary := p1_a21;
    ddp_credit_rating_rec.credit_score_commentary2 := p1_a22;
    ddp_credit_rating_rec.credit_score_commentary3 := p1_a23;
    ddp_credit_rating_rec.credit_score_commentary4 := p1_a24;
    ddp_credit_rating_rec.credit_score_commentary5 := p1_a25;
    ddp_credit_rating_rec.credit_score_commentary6 := p1_a26;
    ddp_credit_rating_rec.credit_score_commentary7 := p1_a27;
    ddp_credit_rating_rec.credit_score_commentary8 := p1_a28;
    ddp_credit_rating_rec.credit_score_commentary9 := p1_a29;
    ddp_credit_rating_rec.credit_score_commentary10 := p1_a30;
    ddp_credit_rating_rec.credit_score_date := rosetta_g_miss_date_in_map(p1_a31);
    ddp_credit_rating_rec.credit_score_incd_default := rosetta_g_miss_num_map(p1_a32);
    ddp_credit_rating_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p1_a33);
    ddp_credit_rating_rec.failure_score := p1_a34;
    ddp_credit_rating_rec.failure_score_age := rosetta_g_miss_num_map(p1_a35);
    ddp_credit_rating_rec.failure_score_class := rosetta_g_miss_num_map(p1_a36);
    ddp_credit_rating_rec.failure_score_commentary := p1_a37;
    ddp_credit_rating_rec.failure_score_commentary2 := p1_a38;
    ddp_credit_rating_rec.failure_score_commentary3 := p1_a39;
    ddp_credit_rating_rec.failure_score_commentary4 := p1_a40;
    ddp_credit_rating_rec.failure_score_commentary5 := p1_a41;
    ddp_credit_rating_rec.failure_score_commentary6 := p1_a42;
    ddp_credit_rating_rec.failure_score_commentary7 := p1_a43;
    ddp_credit_rating_rec.failure_score_commentary8 := p1_a44;
    ddp_credit_rating_rec.failure_score_commentary9 := p1_a45;
    ddp_credit_rating_rec.failure_score_commentary10 := p1_a46;
    ddp_credit_rating_rec.failure_score_date := rosetta_g_miss_date_in_map(p1_a47);
    ddp_credit_rating_rec.failure_score_incd_default := rosetta_g_miss_num_map(p1_a48);
    ddp_credit_rating_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p1_a49);
    ddp_credit_rating_rec.failure_score_override_code := p1_a50;
    ddp_credit_rating_rec.global_failure_score := p1_a51;
    ddp_credit_rating_rec.debarment_ind := p1_a52;
    ddp_credit_rating_rec.debarments_count := rosetta_g_miss_num_map(p1_a53);
    ddp_credit_rating_rec.debarments_date := rosetta_g_miss_date_in_map(p1_a54);
    ddp_credit_rating_rec.high_credit := rosetta_g_miss_num_map(p1_a55);
    ddp_credit_rating_rec.maximum_credit_currency_code := p1_a56;
    ddp_credit_rating_rec.maximum_credit_rcmd := rosetta_g_miss_num_map(p1_a57);
    ddp_credit_rating_rec.paydex_norm := p1_a58;
    ddp_credit_rating_rec.paydex_score := p1_a59;
    ddp_credit_rating_rec.paydex_three_months_ago := p1_a60;
    ddp_credit_rating_rec.credit_score_override_code := p1_a61;
    ddp_credit_rating_rec.cr_scr_clas_expl := p1_a62;
    ddp_credit_rating_rec.low_rng_delq_scr := rosetta_g_miss_num_map(p1_a63);
    ddp_credit_rating_rec.high_rng_delq_scr := rosetta_g_miss_num_map(p1_a64);
    ddp_credit_rating_rec.delq_pmt_rng_prcnt := rosetta_g_miss_num_map(p1_a65);
    ddp_credit_rating_rec.delq_pmt_pctg_for_all_firms := rosetta_g_miss_num_map(p1_a66);
    ddp_credit_rating_rec.num_trade_experiences := rosetta_g_miss_num_map(p1_a67);
    ddp_credit_rating_rec.paydex_firm_days := p1_a68;
    ddp_credit_rating_rec.paydex_firm_comment := p1_a69;
    ddp_credit_rating_rec.paydex_industry_days := p1_a70;
    ddp_credit_rating_rec.paydex_industry_comment := p1_a71;
    ddp_credit_rating_rec.paydex_comment := p1_a72;
    ddp_credit_rating_rec.suit_ind := p1_a73;
    ddp_credit_rating_rec.lien_ind := p1_a74;
    ddp_credit_rating_rec.judgement_ind := p1_a75;
    ddp_credit_rating_rec.bankruptcy_ind := p1_a76;
    ddp_credit_rating_rec.no_trade_ind := p1_a77;
    ddp_credit_rating_rec.prnt_hq_bkcy_ind := p1_a78;
    ddp_credit_rating_rec.num_prnt_bkcy_filing := rosetta_g_miss_num_map(p1_a79);
    ddp_credit_rating_rec.prnt_bkcy_filg_type := p1_a80;
    ddp_credit_rating_rec.prnt_bkcy_filg_chapter := rosetta_g_miss_num_map(p1_a81);
    ddp_credit_rating_rec.prnt_bkcy_filg_date := rosetta_g_miss_date_in_map(p1_a82);
    ddp_credit_rating_rec.num_prnt_bkcy_convs := rosetta_g_miss_num_map(p1_a83);
    ddp_credit_rating_rec.prnt_bkcy_conv_date := rosetta_g_miss_date_in_map(p1_a84);
    ddp_credit_rating_rec.prnt_bkcy_chapter_conv := p1_a85;
    ddp_credit_rating_rec.slow_trade_expl := p1_a86;
    ddp_credit_rating_rec.negv_pmt_expl := p1_a87;
    ddp_credit_rating_rec.pub_rec_expl := p1_a88;
    ddp_credit_rating_rec.business_discontinued := p1_a89;
    ddp_credit_rating_rec.spcl_event_comment := p1_a90;
    ddp_credit_rating_rec.num_spcl_event := rosetta_g_miss_num_map(p1_a91);
    ddp_credit_rating_rec.spcl_event_update_date := rosetta_g_miss_date_in_map(p1_a92);
    ddp_credit_rating_rec.spcl_evnt_txt := p1_a93;
    ddp_credit_rating_rec.actual_content_source := p1_a94;
    ddp_credit_rating_rec.created_by_module := p1_a95;





    -- here's the delegated call to the old PL/SQL routine
    hz_party_info_v2pub.update_credit_rating(p_init_msg_list,
      ddp_credit_rating_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_credit_rating_rec_3(p_init_msg_list  VARCHAR2
    , p_credit_rating_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  NUMBER
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  NUMBER
    , p2_a20 out nocopy  NUMBER
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  DATE
    , p2_a32 out nocopy  NUMBER
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  NUMBER
    , p2_a36 out nocopy  NUMBER
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  VARCHAR2
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  DATE
    , p2_a48 out nocopy  NUMBER
    , p2_a49 out nocopy  NUMBER
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  NUMBER
    , p2_a54 out nocopy  DATE
    , p2_a55 out nocopy  NUMBER
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  NUMBER
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  VARCHAR2
    , p2_a63 out nocopy  NUMBER
    , p2_a64 out nocopy  NUMBER
    , p2_a65 out nocopy  NUMBER
    , p2_a66 out nocopy  NUMBER
    , p2_a67 out nocopy  NUMBER
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  VARCHAR2
    , p2_a71 out nocopy  VARCHAR2
    , p2_a72 out nocopy  VARCHAR2
    , p2_a73 out nocopy  VARCHAR2
    , p2_a74 out nocopy  VARCHAR2
    , p2_a75 out nocopy  VARCHAR2
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  VARCHAR2
    , p2_a78 out nocopy  VARCHAR2
    , p2_a79 out nocopy  NUMBER
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  NUMBER
    , p2_a82 out nocopy  DATE
    , p2_a83 out nocopy  NUMBER
    , p2_a84 out nocopy  DATE
    , p2_a85 out nocopy  VARCHAR2
    , p2_a86 out nocopy  VARCHAR2
    , p2_a87 out nocopy  VARCHAR2
    , p2_a88 out nocopy  VARCHAR2
    , p2_a89 out nocopy  VARCHAR2
    , p2_a90 out nocopy  VARCHAR2
    , p2_a91 out nocopy  NUMBER
    , p2_a92 out nocopy  DATE
    , p2_a93 out nocopy  VARCHAR2
    , p2_a94 out nocopy  VARCHAR2
    , p2_a95 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_credit_rating_rec hz_party_info_v2pub.credit_rating_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_party_info_v2pub.get_credit_rating_rec(p_init_msg_list,
      p_credit_rating_id,
      ddx_credit_rating_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_credit_rating_rec.credit_rating_id);
    p2_a1 := ddx_credit_rating_rec.description;
    p2_a2 := rosetta_g_miss_num_map(ddx_credit_rating_rec.party_id);
    p2_a3 := ddx_credit_rating_rec.rating;
    p2_a4 := ddx_credit_rating_rec.rated_as_of_date;
    p2_a5 := ddx_credit_rating_rec.rating_organization;
    p2_a6 := ddx_credit_rating_rec.comments;
    p2_a7 := ddx_credit_rating_rec.det_history_ind;
    p2_a8 := ddx_credit_rating_rec.fincl_embt_ind;
    p2_a9 := ddx_credit_rating_rec.criminal_proceeding_ind;
    p2_a10 := ddx_credit_rating_rec.claims_ind;
    p2_a11 := ddx_credit_rating_rec.secured_flng_ind;
    p2_a12 := ddx_credit_rating_rec.fincl_lgl_event_ind;
    p2_a13 := ddx_credit_rating_rec.disaster_ind;
    p2_a14 := ddx_credit_rating_rec.oprg_spec_evnt_ind;
    p2_a15 := ddx_credit_rating_rec.other_spec_evnt_ind;
    p2_a16 := ddx_credit_rating_rec.status;
    p2_a17 := rosetta_g_miss_num_map(ddx_credit_rating_rec.avg_high_credit);
    p2_a18 := ddx_credit_rating_rec.credit_score;
    p2_a19 := rosetta_g_miss_num_map(ddx_credit_rating_rec.credit_score_age);
    p2_a20 := rosetta_g_miss_num_map(ddx_credit_rating_rec.credit_score_class);
    p2_a21 := ddx_credit_rating_rec.credit_score_commentary;
    p2_a22 := ddx_credit_rating_rec.credit_score_commentary2;
    p2_a23 := ddx_credit_rating_rec.credit_score_commentary3;
    p2_a24 := ddx_credit_rating_rec.credit_score_commentary4;
    p2_a25 := ddx_credit_rating_rec.credit_score_commentary5;
    p2_a26 := ddx_credit_rating_rec.credit_score_commentary6;
    p2_a27 := ddx_credit_rating_rec.credit_score_commentary7;
    p2_a28 := ddx_credit_rating_rec.credit_score_commentary8;
    p2_a29 := ddx_credit_rating_rec.credit_score_commentary9;
    p2_a30 := ddx_credit_rating_rec.credit_score_commentary10;
    p2_a31 := ddx_credit_rating_rec.credit_score_date;
    p2_a32 := rosetta_g_miss_num_map(ddx_credit_rating_rec.credit_score_incd_default);
    p2_a33 := rosetta_g_miss_num_map(ddx_credit_rating_rec.credit_score_natl_percentile);
    p2_a34 := ddx_credit_rating_rec.failure_score;
    p2_a35 := rosetta_g_miss_num_map(ddx_credit_rating_rec.failure_score_age);
    p2_a36 := rosetta_g_miss_num_map(ddx_credit_rating_rec.failure_score_class);
    p2_a37 := ddx_credit_rating_rec.failure_score_commentary;
    p2_a38 := ddx_credit_rating_rec.failure_score_commentary2;
    p2_a39 := ddx_credit_rating_rec.failure_score_commentary3;
    p2_a40 := ddx_credit_rating_rec.failure_score_commentary4;
    p2_a41 := ddx_credit_rating_rec.failure_score_commentary5;
    p2_a42 := ddx_credit_rating_rec.failure_score_commentary6;
    p2_a43 := ddx_credit_rating_rec.failure_score_commentary7;
    p2_a44 := ddx_credit_rating_rec.failure_score_commentary8;
    p2_a45 := ddx_credit_rating_rec.failure_score_commentary9;
    p2_a46 := ddx_credit_rating_rec.failure_score_commentary10;
    p2_a47 := ddx_credit_rating_rec.failure_score_date;
    p2_a48 := rosetta_g_miss_num_map(ddx_credit_rating_rec.failure_score_incd_default);
    p2_a49 := rosetta_g_miss_num_map(ddx_credit_rating_rec.failure_score_natnl_percentile);
    p2_a50 := ddx_credit_rating_rec.failure_score_override_code;
    p2_a51 := ddx_credit_rating_rec.global_failure_score;
    p2_a52 := ddx_credit_rating_rec.debarment_ind;
    p2_a53 := rosetta_g_miss_num_map(ddx_credit_rating_rec.debarments_count);
    p2_a54 := ddx_credit_rating_rec.debarments_date;
    p2_a55 := rosetta_g_miss_num_map(ddx_credit_rating_rec.high_credit);
    p2_a56 := ddx_credit_rating_rec.maximum_credit_currency_code;
    p2_a57 := rosetta_g_miss_num_map(ddx_credit_rating_rec.maximum_credit_rcmd);
    p2_a58 := ddx_credit_rating_rec.paydex_norm;
    p2_a59 := ddx_credit_rating_rec.paydex_score;
    p2_a60 := ddx_credit_rating_rec.paydex_three_months_ago;
    p2_a61 := ddx_credit_rating_rec.credit_score_override_code;
    p2_a62 := ddx_credit_rating_rec.cr_scr_clas_expl;
    p2_a63 := rosetta_g_miss_num_map(ddx_credit_rating_rec.low_rng_delq_scr);
    p2_a64 := rosetta_g_miss_num_map(ddx_credit_rating_rec.high_rng_delq_scr);
    p2_a65 := rosetta_g_miss_num_map(ddx_credit_rating_rec.delq_pmt_rng_prcnt);
    p2_a66 := rosetta_g_miss_num_map(ddx_credit_rating_rec.delq_pmt_pctg_for_all_firms);
    p2_a67 := rosetta_g_miss_num_map(ddx_credit_rating_rec.num_trade_experiences);
    p2_a68 := ddx_credit_rating_rec.paydex_firm_days;
    p2_a69 := ddx_credit_rating_rec.paydex_firm_comment;
    p2_a70 := ddx_credit_rating_rec.paydex_industry_days;
    p2_a71 := ddx_credit_rating_rec.paydex_industry_comment;
    p2_a72 := ddx_credit_rating_rec.paydex_comment;
    p2_a73 := ddx_credit_rating_rec.suit_ind;
    p2_a74 := ddx_credit_rating_rec.lien_ind;
    p2_a75 := ddx_credit_rating_rec.judgement_ind;
    p2_a76 := ddx_credit_rating_rec.bankruptcy_ind;
    p2_a77 := ddx_credit_rating_rec.no_trade_ind;
    p2_a78 := ddx_credit_rating_rec.prnt_hq_bkcy_ind;
    p2_a79 := rosetta_g_miss_num_map(ddx_credit_rating_rec.num_prnt_bkcy_filing);
    p2_a80 := ddx_credit_rating_rec.prnt_bkcy_filg_type;
    p2_a81 := rosetta_g_miss_num_map(ddx_credit_rating_rec.prnt_bkcy_filg_chapter);
    p2_a82 := ddx_credit_rating_rec.prnt_bkcy_filg_date;
    p2_a83 := rosetta_g_miss_num_map(ddx_credit_rating_rec.num_prnt_bkcy_convs);
    p2_a84 := ddx_credit_rating_rec.prnt_bkcy_conv_date;
    p2_a85 := ddx_credit_rating_rec.prnt_bkcy_chapter_conv;
    p2_a86 := ddx_credit_rating_rec.slow_trade_expl;
    p2_a87 := ddx_credit_rating_rec.negv_pmt_expl;
    p2_a88 := ddx_credit_rating_rec.pub_rec_expl;
    p2_a89 := ddx_credit_rating_rec.business_discontinued;
    p2_a90 := ddx_credit_rating_rec.spcl_event_comment;
    p2_a91 := rosetta_g_miss_num_map(ddx_credit_rating_rec.num_spcl_event);
    p2_a92 := ddx_credit_rating_rec.spcl_event_update_date;
    p2_a93 := ddx_credit_rating_rec.spcl_evnt_txt;
    p2_a94 := ddx_credit_rating_rec.actual_content_source;
    p2_a95 := ddx_credit_rating_rec.created_by_module;



  end;

end hz_party_info_v2pub_jw;

/
