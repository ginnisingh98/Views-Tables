--------------------------------------------------------
--  DDL for Package Body AMS_LISTHEADER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTHEADER_PVT_W" as
  /* $Header: amswlshb.pls 115.20 2004/02/04 01:34:45 vbhandar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure create_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_listheader_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  DATE := fnd_api.g_miss_date
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  DATE := fnd_api.g_miss_date
    , p7_a50  DATE := fnd_api.g_miss_date
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  NUMBER := 0-1962.0724
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
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
    , p7_a87  NUMBER := 0-1962.0724
    , p7_a88  DATE := fnd_api.g_miss_date
    , p7_a89  NUMBER := 0-1962.0724
    , p7_a90  NUMBER := 0-1962.0724
    , p7_a91  NUMBER := 0-1962.0724
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  NUMBER := 0-1962.0724
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  NUMBER := 0-1962.0724
    , p7_a96  NUMBER := 0-1962.0724
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  NUMBER := 0-1962.0724
    , p7_a104  NUMBER := 0-1962.0724
    , p7_a105  NUMBER := 0-1962.0724
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  NUMBER := 0-1962.0724
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p7_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_listheader_rec.list_name := p7_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a13);
    ddp_listheader_rec.arc_list_used_by := p7_a14;
    ddp_listheader_rec.list_type := p7_a15;
    ddp_listheader_rec.status_code := p7_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_listheader_rec.generation_type := p7_a18;
    ddp_listheader_rec.repeat_exclude_type := p7_a19;
    ddp_listheader_rec.row_selection_type := p7_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p7_a21);
    ddp_listheader_rec.access_level := p7_a22;
    ddp_listheader_rec.enable_log_flag := p7_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p7_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p7_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p7_a26;
    ddp_listheader_rec.generate_control_group_flag := p7_a27;
    ddp_listheader_rec.last_generation_success_flag := p7_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p7_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p7_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p7_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p7_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p7_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p7_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p7_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p7_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p7_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p7_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p7_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p7_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p7_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p7_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p7_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p7_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p7_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p7_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p7_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p7_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p7_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p7_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p7_a55;
    ddp_listheader_rec.result_text := p7_a56;
    ddp_listheader_rec.keywords := p7_a57;
    ddp_listheader_rec.description := p7_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p7_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p7_a60);
    ddp_listheader_rec.list_source := p7_a61;
    ddp_listheader_rec.list_source_type := p7_a62;
    ddp_listheader_rec.list_online_flag := p7_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p7_a64);
    ddp_listheader_rec.enabled_flag := p7_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p7_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p7_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p7_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p7_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p7_a70);
    ddp_listheader_rec.attribute_category := p7_a71;
    ddp_listheader_rec.attribute1 := p7_a72;
    ddp_listheader_rec.attribute2 := p7_a73;
    ddp_listheader_rec.attribute3 := p7_a74;
    ddp_listheader_rec.attribute4 := p7_a75;
    ddp_listheader_rec.attribute5 := p7_a76;
    ddp_listheader_rec.attribute6 := p7_a77;
    ddp_listheader_rec.attribute7 := p7_a78;
    ddp_listheader_rec.attribute8 := p7_a79;
    ddp_listheader_rec.attribute9 := p7_a80;
    ddp_listheader_rec.attribute10 := p7_a81;
    ddp_listheader_rec.attribute11 := p7_a82;
    ddp_listheader_rec.attribute12 := p7_a83;
    ddp_listheader_rec.attribute13 := p7_a84;
    ddp_listheader_rec.attribute14 := p7_a85;
    ddp_listheader_rec.attribute15 := p7_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p7_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p7_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p7_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p7_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p7_a91);
    ddp_listheader_rec.dialing_method := p7_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p7_a93);
    ddp_listheader_rec.release_strategy := p7_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p7_a96);
    ddp_listheader_rec.callback_priority_flag := p7_a97;
    ddp_listheader_rec.call_center_ready_flag := p7_a98;
    ddp_listheader_rec.language := p7_a99;
    ddp_listheader_rec.purge_flag := p7_a100;
    ddp_listheader_rec.public_flag := p7_a101;
    ddp_listheader_rec.list_category := p7_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p7_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p7_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p7_a105);
    ddp_listheader_rec.source_lang := p7_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p7_a107);
    ddp_listheader_rec.apply_traffic_cop := p7_a108;


    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.create_listheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec,
      x_listheader_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  DATE := fnd_api.g_miss_date
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  DATE := fnd_api.g_miss_date
    , p7_a50  DATE := fnd_api.g_miss_date
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  NUMBER := 0-1962.0724
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
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
    , p7_a87  NUMBER := 0-1962.0724
    , p7_a88  DATE := fnd_api.g_miss_date
    , p7_a89  NUMBER := 0-1962.0724
    , p7_a90  NUMBER := 0-1962.0724
    , p7_a91  NUMBER := 0-1962.0724
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  NUMBER := 0-1962.0724
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  NUMBER := 0-1962.0724
    , p7_a96  NUMBER := 0-1962.0724
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  NUMBER := 0-1962.0724
    , p7_a104  NUMBER := 0-1962.0724
    , p7_a105  NUMBER := 0-1962.0724
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  NUMBER := 0-1962.0724
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p7_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_listheader_rec.list_name := p7_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p7_a13);
    ddp_listheader_rec.arc_list_used_by := p7_a14;
    ddp_listheader_rec.list_type := p7_a15;
    ddp_listheader_rec.status_code := p7_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_listheader_rec.generation_type := p7_a18;
    ddp_listheader_rec.repeat_exclude_type := p7_a19;
    ddp_listheader_rec.row_selection_type := p7_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p7_a21);
    ddp_listheader_rec.access_level := p7_a22;
    ddp_listheader_rec.enable_log_flag := p7_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p7_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p7_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p7_a26;
    ddp_listheader_rec.generate_control_group_flag := p7_a27;
    ddp_listheader_rec.last_generation_success_flag := p7_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p7_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p7_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p7_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p7_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p7_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p7_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p7_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p7_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p7_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p7_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p7_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p7_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p7_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p7_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p7_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p7_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p7_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p7_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p7_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p7_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p7_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p7_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p7_a55;
    ddp_listheader_rec.result_text := p7_a56;
    ddp_listheader_rec.keywords := p7_a57;
    ddp_listheader_rec.description := p7_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p7_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p7_a60);
    ddp_listheader_rec.list_source := p7_a61;
    ddp_listheader_rec.list_source_type := p7_a62;
    ddp_listheader_rec.list_online_flag := p7_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p7_a64);
    ddp_listheader_rec.enabled_flag := p7_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p7_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p7_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p7_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p7_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p7_a70);
    ddp_listheader_rec.attribute_category := p7_a71;
    ddp_listheader_rec.attribute1 := p7_a72;
    ddp_listheader_rec.attribute2 := p7_a73;
    ddp_listheader_rec.attribute3 := p7_a74;
    ddp_listheader_rec.attribute4 := p7_a75;
    ddp_listheader_rec.attribute5 := p7_a76;
    ddp_listheader_rec.attribute6 := p7_a77;
    ddp_listheader_rec.attribute7 := p7_a78;
    ddp_listheader_rec.attribute8 := p7_a79;
    ddp_listheader_rec.attribute9 := p7_a80;
    ddp_listheader_rec.attribute10 := p7_a81;
    ddp_listheader_rec.attribute11 := p7_a82;
    ddp_listheader_rec.attribute12 := p7_a83;
    ddp_listheader_rec.attribute13 := p7_a84;
    ddp_listheader_rec.attribute14 := p7_a85;
    ddp_listheader_rec.attribute15 := p7_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p7_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p7_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p7_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p7_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p7_a91);
    ddp_listheader_rec.dialing_method := p7_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p7_a93);
    ddp_listheader_rec.release_strategy := p7_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p7_a96);
    ddp_listheader_rec.callback_priority_flag := p7_a97;
    ddp_listheader_rec.call_center_ready_flag := p7_a98;
    ddp_listheader_rec.language := p7_a99;
    ddp_listheader_rec.purge_flag := p7_a100;
    ddp_listheader_rec.public_flag := p7_a101;
    ddp_listheader_rec.list_category := p7_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p7_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p7_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p7_a105);
    ddp_listheader_rec.source_lang := p7_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p7_a107);
    ddp_listheader_rec.apply_traffic_cop := p7_a108;

    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.update_listheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  DATE := fnd_api.g_miss_date
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  DATE := fnd_api.g_miss_date
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  DATE := fnd_api.g_miss_date
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  NUMBER := 0-1962.0724
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  NUMBER := 0-1962.0724
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  NUMBER := 0-1962.0724
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  DATE := fnd_api.g_miss_date
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
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  DATE := fnd_api.g_miss_date
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  NUMBER := 0-1962.0724
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  NUMBER := 0-1962.0724
    , p6_a96  NUMBER := 0-1962.0724
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  VARCHAR2 := fnd_api.g_miss_char
    , p6_a100  VARCHAR2 := fnd_api.g_miss_char
    , p6_a101  VARCHAR2 := fnd_api.g_miss_char
    , p6_a102  VARCHAR2 := fnd_api.g_miss_char
    , p6_a103  NUMBER := 0-1962.0724
    , p6_a104  NUMBER := 0-1962.0724
    , p6_a105  NUMBER := 0-1962.0724
    , p6_a106  VARCHAR2 := fnd_api.g_miss_char
    , p6_a107  NUMBER := 0-1962.0724
    , p6_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p6_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p6_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p6_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p6_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p6_a11);
    ddp_listheader_rec.list_name := p6_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p6_a13);
    ddp_listheader_rec.arc_list_used_by := p6_a14;
    ddp_listheader_rec.list_type := p6_a15;
    ddp_listheader_rec.status_code := p6_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_listheader_rec.generation_type := p6_a18;
    ddp_listheader_rec.repeat_exclude_type := p6_a19;
    ddp_listheader_rec.row_selection_type := p6_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p6_a21);
    ddp_listheader_rec.access_level := p6_a22;
    ddp_listheader_rec.enable_log_flag := p6_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p6_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p6_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p6_a26;
    ddp_listheader_rec.generate_control_group_flag := p6_a27;
    ddp_listheader_rec.last_generation_success_flag := p6_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p6_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p6_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p6_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p6_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p6_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p6_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p6_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p6_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p6_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p6_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p6_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p6_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p6_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p6_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p6_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p6_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p6_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p6_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p6_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p6_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p6_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p6_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p6_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p6_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p6_a55;
    ddp_listheader_rec.result_text := p6_a56;
    ddp_listheader_rec.keywords := p6_a57;
    ddp_listheader_rec.description := p6_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p6_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p6_a60);
    ddp_listheader_rec.list_source := p6_a61;
    ddp_listheader_rec.list_source_type := p6_a62;
    ddp_listheader_rec.list_online_flag := p6_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p6_a64);
    ddp_listheader_rec.enabled_flag := p6_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p6_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p6_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p6_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p6_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p6_a70);
    ddp_listheader_rec.attribute_category := p6_a71;
    ddp_listheader_rec.attribute1 := p6_a72;
    ddp_listheader_rec.attribute2 := p6_a73;
    ddp_listheader_rec.attribute3 := p6_a74;
    ddp_listheader_rec.attribute4 := p6_a75;
    ddp_listheader_rec.attribute5 := p6_a76;
    ddp_listheader_rec.attribute6 := p6_a77;
    ddp_listheader_rec.attribute7 := p6_a78;
    ddp_listheader_rec.attribute8 := p6_a79;
    ddp_listheader_rec.attribute9 := p6_a80;
    ddp_listheader_rec.attribute10 := p6_a81;
    ddp_listheader_rec.attribute11 := p6_a82;
    ddp_listheader_rec.attribute12 := p6_a83;
    ddp_listheader_rec.attribute13 := p6_a84;
    ddp_listheader_rec.attribute14 := p6_a85;
    ddp_listheader_rec.attribute15 := p6_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p6_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p6_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p6_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p6_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p6_a91);
    ddp_listheader_rec.dialing_method := p6_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p6_a93);
    ddp_listheader_rec.release_strategy := p6_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p6_a96);
    ddp_listheader_rec.callback_priority_flag := p6_a97;
    ddp_listheader_rec.call_center_ready_flag := p6_a98;
    ddp_listheader_rec.language := p6_a99;
    ddp_listheader_rec.purge_flag := p6_a100;
    ddp_listheader_rec.public_flag := p6_a101;
    ddp_listheader_rec.list_category := p6_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p6_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p6_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p6_a105);
    ddp_listheader_rec.source_lang := p6_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p6_a107);
    ddp_listheader_rec.apply_traffic_cop := p6_a108;

    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.validate_listheader(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_list_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  DATE := fnd_api.g_miss_date
    , p0_a33  DATE := fnd_api.g_miss_date
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  DATE := fnd_api.g_miss_date
    , p0_a50  DATE := fnd_api.g_miss_date
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  NUMBER := 0-1962.0724
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  NUMBER := 0-1962.0724
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  NUMBER := 0-1962.0724
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  DATE := fnd_api.g_miss_date
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  VARCHAR2 := fnd_api.g_miss_char
    , p0_a84  VARCHAR2 := fnd_api.g_miss_char
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  NUMBER := 0-1962.0724
    , p0_a88  DATE := fnd_api.g_miss_date
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  VARCHAR2 := fnd_api.g_miss_char
    , p0_a93  NUMBER := 0-1962.0724
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  VARCHAR2 := fnd_api.g_miss_char
    , p0_a99  VARCHAR2 := fnd_api.g_miss_char
    , p0_a100  VARCHAR2 := fnd_api.g_miss_char
    , p0_a101  VARCHAR2 := fnd_api.g_miss_char
    , p0_a102  VARCHAR2 := fnd_api.g_miss_char
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  NUMBER := 0-1962.0724
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  NUMBER := 0-1962.0724
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p0_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_listheader_rec.list_name := p0_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a13);
    ddp_listheader_rec.arc_list_used_by := p0_a14;
    ddp_listheader_rec.list_type := p0_a15;
    ddp_listheader_rec.status_code := p0_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_listheader_rec.generation_type := p0_a18;
    ddp_listheader_rec.repeat_exclude_type := p0_a19;
    ddp_listheader_rec.row_selection_type := p0_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p0_a21);
    ddp_listheader_rec.access_level := p0_a22;
    ddp_listheader_rec.enable_log_flag := p0_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p0_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p0_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p0_a26;
    ddp_listheader_rec.generate_control_group_flag := p0_a27;
    ddp_listheader_rec.last_generation_success_flag := p0_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p0_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p0_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p0_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p0_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p0_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p0_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p0_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p0_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p0_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p0_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p0_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p0_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p0_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p0_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p0_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p0_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p0_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p0_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p0_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p0_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p0_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p0_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p0_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p0_a55;
    ddp_listheader_rec.result_text := p0_a56;
    ddp_listheader_rec.keywords := p0_a57;
    ddp_listheader_rec.description := p0_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p0_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p0_a60);
    ddp_listheader_rec.list_source := p0_a61;
    ddp_listheader_rec.list_source_type := p0_a62;
    ddp_listheader_rec.list_online_flag := p0_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p0_a64);
    ddp_listheader_rec.enabled_flag := p0_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p0_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p0_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p0_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p0_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p0_a70);
    ddp_listheader_rec.attribute_category := p0_a71;
    ddp_listheader_rec.attribute1 := p0_a72;
    ddp_listheader_rec.attribute2 := p0_a73;
    ddp_listheader_rec.attribute3 := p0_a74;
    ddp_listheader_rec.attribute4 := p0_a75;
    ddp_listheader_rec.attribute5 := p0_a76;
    ddp_listheader_rec.attribute6 := p0_a77;
    ddp_listheader_rec.attribute7 := p0_a78;
    ddp_listheader_rec.attribute8 := p0_a79;
    ddp_listheader_rec.attribute9 := p0_a80;
    ddp_listheader_rec.attribute10 := p0_a81;
    ddp_listheader_rec.attribute11 := p0_a82;
    ddp_listheader_rec.attribute12 := p0_a83;
    ddp_listheader_rec.attribute13 := p0_a84;
    ddp_listheader_rec.attribute14 := p0_a85;
    ddp_listheader_rec.attribute15 := p0_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p0_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p0_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p0_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p0_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p0_a91);
    ddp_listheader_rec.dialing_method := p0_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p0_a93);
    ddp_listheader_rec.release_strategy := p0_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p0_a96);
    ddp_listheader_rec.callback_priority_flag := p0_a97;
    ddp_listheader_rec.call_center_ready_flag := p0_a98;
    ddp_listheader_rec.language := p0_a99;
    ddp_listheader_rec.purge_flag := p0_a100;
    ddp_listheader_rec.public_flag := p0_a101;
    ddp_listheader_rec.list_category := p0_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p0_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p0_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p0_a105);
    ddp_listheader_rec.source_lang := p0_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p0_a107);
    ddp_listheader_rec.apply_traffic_cop := p0_a108;



    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.validate_list_items(ddp_listheader_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_list_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  DATE := fnd_api.g_miss_date
    , p0_a33  DATE := fnd_api.g_miss_date
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  DATE := fnd_api.g_miss_date
    , p0_a50  DATE := fnd_api.g_miss_date
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  NUMBER := 0-1962.0724
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  NUMBER := 0-1962.0724
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  NUMBER := 0-1962.0724
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  DATE := fnd_api.g_miss_date
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  VARCHAR2 := fnd_api.g_miss_char
    , p0_a84  VARCHAR2 := fnd_api.g_miss_char
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  NUMBER := 0-1962.0724
    , p0_a88  DATE := fnd_api.g_miss_date
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  VARCHAR2 := fnd_api.g_miss_char
    , p0_a93  NUMBER := 0-1962.0724
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  VARCHAR2 := fnd_api.g_miss_char
    , p0_a99  VARCHAR2 := fnd_api.g_miss_char
    , p0_a100  VARCHAR2 := fnd_api.g_miss_char
    , p0_a101  VARCHAR2 := fnd_api.g_miss_char
    , p0_a102  VARCHAR2 := fnd_api.g_miss_char
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  NUMBER := 0-1962.0724
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  NUMBER := 0-1962.0724
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  DATE := fnd_api.g_miss_date
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  NUMBER := 0-1962.0724
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  DATE := fnd_api.g_miss_date
    , p1_a30  DATE := fnd_api.g_miss_date
    , p1_a31  DATE := fnd_api.g_miss_date
    , p1_a32  DATE := fnd_api.g_miss_date
    , p1_a33  DATE := fnd_api.g_miss_date
    , p1_a34  DATE := fnd_api.g_miss_date
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  NUMBER := 0-1962.0724
    , p1_a41  NUMBER := 0-1962.0724
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  NUMBER := 0-1962.0724
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  NUMBER := 0-1962.0724
    , p1_a49  DATE := fnd_api.g_miss_date
    , p1_a50  DATE := fnd_api.g_miss_date
    , p1_a51  NUMBER := 0-1962.0724
    , p1_a52  NUMBER := 0-1962.0724
    , p1_a53  NUMBER := 0-1962.0724
    , p1_a54  NUMBER := 0-1962.0724
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  NUMBER := 0-1962.0724
    , p1_a60  NUMBER := 0-1962.0724
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  NUMBER := 0-1962.0724
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  NUMBER := 0-1962.0724
    , p1_a67  NUMBER := 0-1962.0724
    , p1_a68  NUMBER := 0-1962.0724
    , p1_a69  NUMBER := 0-1962.0724
    , p1_a70  DATE := fnd_api.g_miss_date
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  VARCHAR2 := fnd_api.g_miss_char
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  VARCHAR2 := fnd_api.g_miss_char
    , p1_a79  VARCHAR2 := fnd_api.g_miss_char
    , p1_a80  VARCHAR2 := fnd_api.g_miss_char
    , p1_a81  VARCHAR2 := fnd_api.g_miss_char
    , p1_a82  VARCHAR2 := fnd_api.g_miss_char
    , p1_a83  VARCHAR2 := fnd_api.g_miss_char
    , p1_a84  VARCHAR2 := fnd_api.g_miss_char
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  NUMBER := 0-1962.0724
    , p1_a88  DATE := fnd_api.g_miss_date
    , p1_a89  NUMBER := 0-1962.0724
    , p1_a90  NUMBER := 0-1962.0724
    , p1_a91  NUMBER := 0-1962.0724
    , p1_a92  VARCHAR2 := fnd_api.g_miss_char
    , p1_a93  NUMBER := 0-1962.0724
    , p1_a94  VARCHAR2 := fnd_api.g_miss_char
    , p1_a95  NUMBER := 0-1962.0724
    , p1_a96  NUMBER := 0-1962.0724
    , p1_a97  VARCHAR2 := fnd_api.g_miss_char
    , p1_a98  VARCHAR2 := fnd_api.g_miss_char
    , p1_a99  VARCHAR2 := fnd_api.g_miss_char
    , p1_a100  VARCHAR2 := fnd_api.g_miss_char
    , p1_a101  VARCHAR2 := fnd_api.g_miss_char
    , p1_a102  VARCHAR2 := fnd_api.g_miss_char
    , p1_a103  NUMBER := 0-1962.0724
    , p1_a104  NUMBER := 0-1962.0724
    , p1_a105  NUMBER := 0-1962.0724
    , p1_a106  VARCHAR2 := fnd_api.g_miss_char
    , p1_a107  NUMBER := 0-1962.0724
    , p1_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddp_complete_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p0_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_listheader_rec.list_name := p0_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a13);
    ddp_listheader_rec.arc_list_used_by := p0_a14;
    ddp_listheader_rec.list_type := p0_a15;
    ddp_listheader_rec.status_code := p0_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_listheader_rec.generation_type := p0_a18;
    ddp_listheader_rec.repeat_exclude_type := p0_a19;
    ddp_listheader_rec.row_selection_type := p0_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p0_a21);
    ddp_listheader_rec.access_level := p0_a22;
    ddp_listheader_rec.enable_log_flag := p0_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p0_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p0_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p0_a26;
    ddp_listheader_rec.generate_control_group_flag := p0_a27;
    ddp_listheader_rec.last_generation_success_flag := p0_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p0_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p0_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p0_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p0_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p0_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p0_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p0_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p0_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p0_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p0_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p0_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p0_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p0_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p0_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p0_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p0_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p0_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p0_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p0_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p0_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p0_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p0_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p0_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p0_a55;
    ddp_listheader_rec.result_text := p0_a56;
    ddp_listheader_rec.keywords := p0_a57;
    ddp_listheader_rec.description := p0_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p0_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p0_a60);
    ddp_listheader_rec.list_source := p0_a61;
    ddp_listheader_rec.list_source_type := p0_a62;
    ddp_listheader_rec.list_online_flag := p0_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p0_a64);
    ddp_listheader_rec.enabled_flag := p0_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p0_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p0_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p0_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p0_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p0_a70);
    ddp_listheader_rec.attribute_category := p0_a71;
    ddp_listheader_rec.attribute1 := p0_a72;
    ddp_listheader_rec.attribute2 := p0_a73;
    ddp_listheader_rec.attribute3 := p0_a74;
    ddp_listheader_rec.attribute4 := p0_a75;
    ddp_listheader_rec.attribute5 := p0_a76;
    ddp_listheader_rec.attribute6 := p0_a77;
    ddp_listheader_rec.attribute7 := p0_a78;
    ddp_listheader_rec.attribute8 := p0_a79;
    ddp_listheader_rec.attribute9 := p0_a80;
    ddp_listheader_rec.attribute10 := p0_a81;
    ddp_listheader_rec.attribute11 := p0_a82;
    ddp_listheader_rec.attribute12 := p0_a83;
    ddp_listheader_rec.attribute13 := p0_a84;
    ddp_listheader_rec.attribute14 := p0_a85;
    ddp_listheader_rec.attribute15 := p0_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p0_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p0_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p0_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p0_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p0_a91);
    ddp_listheader_rec.dialing_method := p0_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p0_a93);
    ddp_listheader_rec.release_strategy := p0_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p0_a96);
    ddp_listheader_rec.callback_priority_flag := p0_a97;
    ddp_listheader_rec.call_center_ready_flag := p0_a98;
    ddp_listheader_rec.language := p0_a99;
    ddp_listheader_rec.purge_flag := p0_a100;
    ddp_listheader_rec.public_flag := p0_a101;
    ddp_listheader_rec.list_category := p0_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p0_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p0_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p0_a105);
    ddp_listheader_rec.source_lang := p0_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p0_a107);
    ddp_listheader_rec.apply_traffic_cop := p0_a108;

    ddp_complete_rec.list_header_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.request_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.program_application_id := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.view_application_id := rosetta_g_miss_num_map(p1_a11);
    ddp_complete_rec.list_name := p1_a12;
    ddp_complete_rec.list_used_by_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.arc_list_used_by := p1_a14;
    ddp_complete_rec.list_type := p1_a15;
    ddp_complete_rec.status_code := p1_a16;
    ddp_complete_rec.status_date := rosetta_g_miss_date_in_map(p1_a17);
    ddp_complete_rec.generation_type := p1_a18;
    ddp_complete_rec.repeat_exclude_type := p1_a19;
    ddp_complete_rec.row_selection_type := p1_a20;
    ddp_complete_rec.owner_user_id := rosetta_g_miss_num_map(p1_a21);
    ddp_complete_rec.access_level := p1_a22;
    ddp_complete_rec.enable_log_flag := p1_a23;
    ddp_complete_rec.enable_word_replacement_flag := p1_a24;
    ddp_complete_rec.enable_parallel_dml_flag := p1_a25;
    ddp_complete_rec.dedupe_during_generation_flag := p1_a26;
    ddp_complete_rec.generate_control_group_flag := p1_a27;
    ddp_complete_rec.last_generation_success_flag := p1_a28;
    ddp_complete_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_complete_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p1_a30);
    ddp_complete_rec.actual_end_date := rosetta_g_miss_date_in_map(p1_a31);
    ddp_complete_rec.sent_out_date := rosetta_g_miss_date_in_map(p1_a32);
    ddp_complete_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p1_a33);
    ddp_complete_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p1_a34);
    ddp_complete_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p1_a35);
    ddp_complete_rec.workflow_item_key := rosetta_g_miss_num_map(p1_a36);
    ddp_complete_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p1_a37);
    ddp_complete_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p1_a38);
    ddp_complete_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p1_a39);
    ddp_complete_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p1_a40);
    ddp_complete_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p1_a41);
    ddp_complete_rec.no_of_rows_active := rosetta_g_miss_num_map(p1_a42);
    ddp_complete_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p1_a43);
    ddp_complete_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p1_a44);
    ddp_complete_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p1_a45);
    ddp_complete_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p1_a46);
    ddp_complete_rec.no_of_rows_random := rosetta_g_miss_num_map(p1_a47);
    ddp_complete_rec.org_id := rosetta_g_miss_num_map(p1_a48);
    ddp_complete_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p1_a49);
    ddp_complete_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p1_a50);
    ddp_complete_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p1_a51);
    ddp_complete_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p1_a52);
    ddp_complete_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p1_a53);
    ddp_complete_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p1_a54);
    ddp_complete_rec.repeat_source_list_header_id := p1_a55;
    ddp_complete_rec.result_text := p1_a56;
    ddp_complete_rec.keywords := p1_a57;
    ddp_complete_rec.description := p1_a58;
    ddp_complete_rec.list_priority := rosetta_g_miss_num_map(p1_a59);
    ddp_complete_rec.assign_person_id := rosetta_g_miss_num_map(p1_a60);
    ddp_complete_rec.list_source := p1_a61;
    ddp_complete_rec.list_source_type := p1_a62;
    ddp_complete_rec.list_online_flag := p1_a63;
    ddp_complete_rec.random_list_id := rosetta_g_miss_num_map(p1_a64);
    ddp_complete_rec.enabled_flag := p1_a65;
    ddp_complete_rec.assigned_to := rosetta_g_miss_num_map(p1_a66);
    ddp_complete_rec.query_id := rosetta_g_miss_num_map(p1_a67);
    ddp_complete_rec.owner_person_id := rosetta_g_miss_num_map(p1_a68);
    ddp_complete_rec.archived_by := rosetta_g_miss_num_map(p1_a69);
    ddp_complete_rec.archived_date := rosetta_g_miss_date_in_map(p1_a70);
    ddp_complete_rec.attribute_category := p1_a71;
    ddp_complete_rec.attribute1 := p1_a72;
    ddp_complete_rec.attribute2 := p1_a73;
    ddp_complete_rec.attribute3 := p1_a74;
    ddp_complete_rec.attribute4 := p1_a75;
    ddp_complete_rec.attribute5 := p1_a76;
    ddp_complete_rec.attribute6 := p1_a77;
    ddp_complete_rec.attribute7 := p1_a78;
    ddp_complete_rec.attribute8 := p1_a79;
    ddp_complete_rec.attribute9 := p1_a80;
    ddp_complete_rec.attribute10 := p1_a81;
    ddp_complete_rec.attribute11 := p1_a82;
    ddp_complete_rec.attribute12 := p1_a83;
    ddp_complete_rec.attribute13 := p1_a84;
    ddp_complete_rec.attribute14 := p1_a85;
    ddp_complete_rec.attribute15 := p1_a86;
    ddp_complete_rec.timezone_id := rosetta_g_miss_num_map(p1_a87);
    ddp_complete_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p1_a88);
    ddp_complete_rec.user_status_id := rosetta_g_miss_num_map(p1_a89);
    ddp_complete_rec.quantum := rosetta_g_miss_num_map(p1_a90);
    ddp_complete_rec.release_control_alg_id := rosetta_g_miss_num_map(p1_a91);
    ddp_complete_rec.dialing_method := p1_a92;
    ddp_complete_rec.calling_calendar_id := rosetta_g_miss_num_map(p1_a93);
    ddp_complete_rec.release_strategy := p1_a94;
    ddp_complete_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a95);
    ddp_complete_rec.country := rosetta_g_miss_num_map(p1_a96);
    ddp_complete_rec.callback_priority_flag := p1_a97;
    ddp_complete_rec.call_center_ready_flag := p1_a98;
    ddp_complete_rec.language := p1_a99;
    ddp_complete_rec.purge_flag := p1_a100;
    ddp_complete_rec.public_flag := p1_a101;
    ddp_complete_rec.list_category := p1_a102;
    ddp_complete_rec.quota := rosetta_g_miss_num_map(p1_a103);
    ddp_complete_rec.quota_reset := rosetta_g_miss_num_map(p1_a104);
    ddp_complete_rec.recycling_alg_id := rosetta_g_miss_num_map(p1_a105);
    ddp_complete_rec.source_lang := p1_a106;
    ddp_complete_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p1_a107);
    ddp_complete_rec.apply_traffic_cop := p1_a108;


    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.validate_list_record(ddp_listheader_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_listheader_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  DATE
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  DATE
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  DATE
    , p0_a30 out nocopy  DATE
    , p0_a31 out nocopy  DATE
    , p0_a32 out nocopy  DATE
    , p0_a33 out nocopy  DATE
    , p0_a34 out nocopy  DATE
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  NUMBER
    , p0_a44 out nocopy  NUMBER
    , p0_a45 out nocopy  NUMBER
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  DATE
    , p0_a50 out nocopy  DATE
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  VARCHAR2
    , p0_a63 out nocopy  VARCHAR2
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  NUMBER
    , p0_a69 out nocopy  NUMBER
    , p0_a70 out nocopy  DATE
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  VARCHAR2
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
    , p0_a82 out nocopy  VARCHAR2
    , p0_a83 out nocopy  VARCHAR2
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  NUMBER
    , p0_a88 out nocopy  DATE
    , p0_a89 out nocopy  NUMBER
    , p0_a90 out nocopy  NUMBER
    , p0_a91 out nocopy  NUMBER
    , p0_a92 out nocopy  VARCHAR2
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  VARCHAR2
    , p0_a95 out nocopy  NUMBER
    , p0_a96 out nocopy  NUMBER
    , p0_a97 out nocopy  VARCHAR2
    , p0_a98 out nocopy  VARCHAR2
    , p0_a99 out nocopy  VARCHAR2
    , p0_a100 out nocopy  VARCHAR2
    , p0_a101 out nocopy  VARCHAR2
    , p0_a102 out nocopy  VARCHAR2
    , p0_a103 out nocopy  NUMBER
    , p0_a104 out nocopy  NUMBER
    , p0_a105 out nocopy  NUMBER
    , p0_a106 out nocopy  VARCHAR2
    , p0_a107 out nocopy  NUMBER
    , p0_a108 out nocopy  VARCHAR2
  )

  as
    ddx_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.init_listheader_rec(ddx_listheader_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_listheader_rec.list_header_id);
    p0_a1 := ddx_listheader_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_listheader_rec.last_updated_by);
    p0_a3 := ddx_listheader_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_listheader_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_listheader_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_listheader_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_listheader_rec.request_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_listheader_rec.program_id);
    p0_a9 := rosetta_g_miss_num_map(ddx_listheader_rec.program_application_id);
    p0_a10 := ddx_listheader_rec.program_update_date;
    p0_a11 := rosetta_g_miss_num_map(ddx_listheader_rec.view_application_id);
    p0_a12 := ddx_listheader_rec.list_name;
    p0_a13 := rosetta_g_miss_num_map(ddx_listheader_rec.list_used_by_id);
    p0_a14 := ddx_listheader_rec.arc_list_used_by;
    p0_a15 := ddx_listheader_rec.list_type;
    p0_a16 := ddx_listheader_rec.status_code;
    p0_a17 := ddx_listheader_rec.status_date;
    p0_a18 := ddx_listheader_rec.generation_type;
    p0_a19 := ddx_listheader_rec.repeat_exclude_type;
    p0_a20 := ddx_listheader_rec.row_selection_type;
    p0_a21 := rosetta_g_miss_num_map(ddx_listheader_rec.owner_user_id);
    p0_a22 := ddx_listheader_rec.access_level;
    p0_a23 := ddx_listheader_rec.enable_log_flag;
    p0_a24 := ddx_listheader_rec.enable_word_replacement_flag;
    p0_a25 := ddx_listheader_rec.enable_parallel_dml_flag;
    p0_a26 := ddx_listheader_rec.dedupe_during_generation_flag;
    p0_a27 := ddx_listheader_rec.generate_control_group_flag;
    p0_a28 := ddx_listheader_rec.last_generation_success_flag;
    p0_a29 := ddx_listheader_rec.forecasted_start_date;
    p0_a30 := ddx_listheader_rec.forecasted_end_date;
    p0_a31 := ddx_listheader_rec.actual_end_date;
    p0_a32 := ddx_listheader_rec.sent_out_date;
    p0_a33 := ddx_listheader_rec.dedupe_start_date;
    p0_a34 := ddx_listheader_rec.last_dedupe_date;
    p0_a35 := rosetta_g_miss_num_map(ddx_listheader_rec.last_deduped_by_user_id);
    p0_a36 := rosetta_g_miss_num_map(ddx_listheader_rec.workflow_item_key);
    p0_a37 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_duplicates);
    p0_a38 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_min_requested);
    p0_a39 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_max_requested);
    p0_a40 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_in_list);
    p0_a41 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_in_ctrl_group);
    p0_a42 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_active);
    p0_a43 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_inactive);
    p0_a44 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_manually_entered);
    p0_a45 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_do_not_call);
    p0_a46 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_do_not_mail);
    p0_a47 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_random);
    p0_a48 := rosetta_g_miss_num_map(ddx_listheader_rec.org_id);
    p0_a49 := ddx_listheader_rec.main_gen_start_time;
    p0_a50 := ddx_listheader_rec.main_gen_end_time;
    p0_a51 := rosetta_g_miss_num_map(ddx_listheader_rec.main_random_nth_row_selection);
    p0_a52 := rosetta_g_miss_num_map(ddx_listheader_rec.main_random_pct_row_selection);
    p0_a53 := rosetta_g_miss_num_map(ddx_listheader_rec.ctrl_random_nth_row_selection);
    p0_a54 := rosetta_g_miss_num_map(ddx_listheader_rec.ctrl_random_pct_row_selection);
    p0_a55 := ddx_listheader_rec.repeat_source_list_header_id;
    p0_a56 := ddx_listheader_rec.result_text;
    p0_a57 := ddx_listheader_rec.keywords;
    p0_a58 := ddx_listheader_rec.description;
    p0_a59 := rosetta_g_miss_num_map(ddx_listheader_rec.list_priority);
    p0_a60 := rosetta_g_miss_num_map(ddx_listheader_rec.assign_person_id);
    p0_a61 := ddx_listheader_rec.list_source;
    p0_a62 := ddx_listheader_rec.list_source_type;
    p0_a63 := ddx_listheader_rec.list_online_flag;
    p0_a64 := rosetta_g_miss_num_map(ddx_listheader_rec.random_list_id);
    p0_a65 := ddx_listheader_rec.enabled_flag;
    p0_a66 := rosetta_g_miss_num_map(ddx_listheader_rec.assigned_to);
    p0_a67 := rosetta_g_miss_num_map(ddx_listheader_rec.query_id);
    p0_a68 := rosetta_g_miss_num_map(ddx_listheader_rec.owner_person_id);
    p0_a69 := rosetta_g_miss_num_map(ddx_listheader_rec.archived_by);
    p0_a70 := ddx_listheader_rec.archived_date;
    p0_a71 := ddx_listheader_rec.attribute_category;
    p0_a72 := ddx_listheader_rec.attribute1;
    p0_a73 := ddx_listheader_rec.attribute2;
    p0_a74 := ddx_listheader_rec.attribute3;
    p0_a75 := ddx_listheader_rec.attribute4;
    p0_a76 := ddx_listheader_rec.attribute5;
    p0_a77 := ddx_listheader_rec.attribute6;
    p0_a78 := ddx_listheader_rec.attribute7;
    p0_a79 := ddx_listheader_rec.attribute8;
    p0_a80 := ddx_listheader_rec.attribute9;
    p0_a81 := ddx_listheader_rec.attribute10;
    p0_a82 := ddx_listheader_rec.attribute11;
    p0_a83 := ddx_listheader_rec.attribute12;
    p0_a84 := ddx_listheader_rec.attribute13;
    p0_a85 := ddx_listheader_rec.attribute14;
    p0_a86 := ddx_listheader_rec.attribute15;
    p0_a87 := rosetta_g_miss_num_map(ddx_listheader_rec.timezone_id);
    p0_a88 := ddx_listheader_rec.user_entered_start_time;
    p0_a89 := rosetta_g_miss_num_map(ddx_listheader_rec.user_status_id);
    p0_a90 := rosetta_g_miss_num_map(ddx_listheader_rec.quantum);
    p0_a91 := rosetta_g_miss_num_map(ddx_listheader_rec.release_control_alg_id);
    p0_a92 := ddx_listheader_rec.dialing_method;
    p0_a93 := rosetta_g_miss_num_map(ddx_listheader_rec.calling_calendar_id);
    p0_a94 := ddx_listheader_rec.release_strategy;
    p0_a95 := rosetta_g_miss_num_map(ddx_listheader_rec.custom_setup_id);
    p0_a96 := rosetta_g_miss_num_map(ddx_listheader_rec.country);
    p0_a97 := ddx_listheader_rec.callback_priority_flag;
    p0_a98 := ddx_listheader_rec.call_center_ready_flag;
    p0_a99 := ddx_listheader_rec.language;
    p0_a100 := ddx_listheader_rec.purge_flag;
    p0_a101 := ddx_listheader_rec.public_flag;
    p0_a102 := ddx_listheader_rec.list_category;
    p0_a103 := rosetta_g_miss_num_map(ddx_listheader_rec.quota);
    p0_a104 := rosetta_g_miss_num_map(ddx_listheader_rec.quota_reset);
    p0_a105 := rosetta_g_miss_num_map(ddx_listheader_rec.recycling_alg_id);
    p0_a106 := ddx_listheader_rec.source_lang;
    p0_a107 := rosetta_g_miss_num_map(ddx_listheader_rec.no_of_rows_prev_contacted);
    p0_a108 := ddx_listheader_rec.apply_traffic_cop;
  end;

  procedure complete_listheader_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  DATE
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  DATE
    , p1_a30 out nocopy  DATE
    , p1_a31 out nocopy  DATE
    , p1_a32 out nocopy  DATE
    , p1_a33 out nocopy  DATE
    , p1_a34 out nocopy  DATE
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  NUMBER
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  DATE
    , p1_a50 out nocopy  DATE
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  VARCHAR2
    , p1_a63 out nocopy  VARCHAR2
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  NUMBER
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  DATE
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  VARCHAR2
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  VARCHAR2
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  NUMBER
    , p1_a88 out nocopy  DATE
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  NUMBER
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  VARCHAR2
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  VARCHAR2
    , p1_a95 out nocopy  NUMBER
    , p1_a96 out nocopy  NUMBER
    , p1_a97 out nocopy  VARCHAR2
    , p1_a98 out nocopy  VARCHAR2
    , p1_a99 out nocopy  VARCHAR2
    , p1_a100 out nocopy  VARCHAR2
    , p1_a101 out nocopy  VARCHAR2
    , p1_a102 out nocopy  VARCHAR2
    , p1_a103 out nocopy  NUMBER
    , p1_a104 out nocopy  NUMBER
    , p1_a105 out nocopy  NUMBER
    , p1_a106 out nocopy  VARCHAR2
    , p1_a107 out nocopy  NUMBER
    , p1_a108 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  DATE := fnd_api.g_miss_date
    , p0_a33  DATE := fnd_api.g_miss_date
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  DATE := fnd_api.g_miss_date
    , p0_a50  DATE := fnd_api.g_miss_date
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  NUMBER := 0-1962.0724
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  NUMBER := 0-1962.0724
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  NUMBER := 0-1962.0724
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  DATE := fnd_api.g_miss_date
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  VARCHAR2 := fnd_api.g_miss_char
    , p0_a84  VARCHAR2 := fnd_api.g_miss_char
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  NUMBER := 0-1962.0724
    , p0_a88  DATE := fnd_api.g_miss_date
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  VARCHAR2 := fnd_api.g_miss_char
    , p0_a93  NUMBER := 0-1962.0724
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  VARCHAR2 := fnd_api.g_miss_char
    , p0_a99  VARCHAR2 := fnd_api.g_miss_char
    , p0_a100  VARCHAR2 := fnd_api.g_miss_char
    , p0_a101  VARCHAR2 := fnd_api.g_miss_char
    , p0_a102  VARCHAR2 := fnd_api.g_miss_char
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  NUMBER := 0-1962.0724
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  NUMBER := 0-1962.0724
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddx_complete_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p0_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_listheader_rec.list_name := p0_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p0_a13);
    ddp_listheader_rec.arc_list_used_by := p0_a14;
    ddp_listheader_rec.list_type := p0_a15;
    ddp_listheader_rec.status_code := p0_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_listheader_rec.generation_type := p0_a18;
    ddp_listheader_rec.repeat_exclude_type := p0_a19;
    ddp_listheader_rec.row_selection_type := p0_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p0_a21);
    ddp_listheader_rec.access_level := p0_a22;
    ddp_listheader_rec.enable_log_flag := p0_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p0_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p0_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p0_a26;
    ddp_listheader_rec.generate_control_group_flag := p0_a27;
    ddp_listheader_rec.last_generation_success_flag := p0_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p0_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p0_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p0_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p0_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p0_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p0_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p0_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p0_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p0_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p0_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p0_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p0_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p0_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p0_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p0_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p0_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p0_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p0_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p0_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p0_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p0_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p0_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p0_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p0_a55;
    ddp_listheader_rec.result_text := p0_a56;
    ddp_listheader_rec.keywords := p0_a57;
    ddp_listheader_rec.description := p0_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p0_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p0_a60);
    ddp_listheader_rec.list_source := p0_a61;
    ddp_listheader_rec.list_source_type := p0_a62;
    ddp_listheader_rec.list_online_flag := p0_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p0_a64);
    ddp_listheader_rec.enabled_flag := p0_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p0_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p0_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p0_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p0_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p0_a70);
    ddp_listheader_rec.attribute_category := p0_a71;
    ddp_listheader_rec.attribute1 := p0_a72;
    ddp_listheader_rec.attribute2 := p0_a73;
    ddp_listheader_rec.attribute3 := p0_a74;
    ddp_listheader_rec.attribute4 := p0_a75;
    ddp_listheader_rec.attribute5 := p0_a76;
    ddp_listheader_rec.attribute6 := p0_a77;
    ddp_listheader_rec.attribute7 := p0_a78;
    ddp_listheader_rec.attribute8 := p0_a79;
    ddp_listheader_rec.attribute9 := p0_a80;
    ddp_listheader_rec.attribute10 := p0_a81;
    ddp_listheader_rec.attribute11 := p0_a82;
    ddp_listheader_rec.attribute12 := p0_a83;
    ddp_listheader_rec.attribute13 := p0_a84;
    ddp_listheader_rec.attribute14 := p0_a85;
    ddp_listheader_rec.attribute15 := p0_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p0_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p0_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p0_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p0_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p0_a91);
    ddp_listheader_rec.dialing_method := p0_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p0_a93);
    ddp_listheader_rec.release_strategy := p0_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p0_a96);
    ddp_listheader_rec.callback_priority_flag := p0_a97;
    ddp_listheader_rec.call_center_ready_flag := p0_a98;
    ddp_listheader_rec.language := p0_a99;
    ddp_listheader_rec.purge_flag := p0_a100;
    ddp_listheader_rec.public_flag := p0_a101;
    ddp_listheader_rec.list_category := p0_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p0_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p0_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p0_a105);
    ddp_listheader_rec.source_lang := p0_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p0_a107);
    ddp_listheader_rec.apply_traffic_cop := p0_a108;


    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.complete_listheader_rec(ddp_listheader_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_header_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.request_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.program_id);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.program_application_id);
    p1_a10 := ddx_complete_rec.program_update_date;
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.view_application_id);
    p1_a12 := ddx_complete_rec.list_name;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.list_used_by_id);
    p1_a14 := ddx_complete_rec.arc_list_used_by;
    p1_a15 := ddx_complete_rec.list_type;
    p1_a16 := ddx_complete_rec.status_code;
    p1_a17 := ddx_complete_rec.status_date;
    p1_a18 := ddx_complete_rec.generation_type;
    p1_a19 := ddx_complete_rec.repeat_exclude_type;
    p1_a20 := ddx_complete_rec.row_selection_type;
    p1_a21 := rosetta_g_miss_num_map(ddx_complete_rec.owner_user_id);
    p1_a22 := ddx_complete_rec.access_level;
    p1_a23 := ddx_complete_rec.enable_log_flag;
    p1_a24 := ddx_complete_rec.enable_word_replacement_flag;
    p1_a25 := ddx_complete_rec.enable_parallel_dml_flag;
    p1_a26 := ddx_complete_rec.dedupe_during_generation_flag;
    p1_a27 := ddx_complete_rec.generate_control_group_flag;
    p1_a28 := ddx_complete_rec.last_generation_success_flag;
    p1_a29 := ddx_complete_rec.forecasted_start_date;
    p1_a30 := ddx_complete_rec.forecasted_end_date;
    p1_a31 := ddx_complete_rec.actual_end_date;
    p1_a32 := ddx_complete_rec.sent_out_date;
    p1_a33 := ddx_complete_rec.dedupe_start_date;
    p1_a34 := ddx_complete_rec.last_dedupe_date;
    p1_a35 := rosetta_g_miss_num_map(ddx_complete_rec.last_deduped_by_user_id);
    p1_a36 := rosetta_g_miss_num_map(ddx_complete_rec.workflow_item_key);
    p1_a37 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_duplicates);
    p1_a38 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_min_requested);
    p1_a39 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_max_requested);
    p1_a40 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_in_list);
    p1_a41 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_in_ctrl_group);
    p1_a42 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_active);
    p1_a43 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_inactive);
    p1_a44 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_manually_entered);
    p1_a45 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_do_not_call);
    p1_a46 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_do_not_mail);
    p1_a47 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_random);
    p1_a48 := rosetta_g_miss_num_map(ddx_complete_rec.org_id);
    p1_a49 := ddx_complete_rec.main_gen_start_time;
    p1_a50 := ddx_complete_rec.main_gen_end_time;
    p1_a51 := rosetta_g_miss_num_map(ddx_complete_rec.main_random_nth_row_selection);
    p1_a52 := rosetta_g_miss_num_map(ddx_complete_rec.main_random_pct_row_selection);
    p1_a53 := rosetta_g_miss_num_map(ddx_complete_rec.ctrl_random_nth_row_selection);
    p1_a54 := rosetta_g_miss_num_map(ddx_complete_rec.ctrl_random_pct_row_selection);
    p1_a55 := ddx_complete_rec.repeat_source_list_header_id;
    p1_a56 := ddx_complete_rec.result_text;
    p1_a57 := ddx_complete_rec.keywords;
    p1_a58 := ddx_complete_rec.description;
    p1_a59 := rosetta_g_miss_num_map(ddx_complete_rec.list_priority);
    p1_a60 := rosetta_g_miss_num_map(ddx_complete_rec.assign_person_id);
    p1_a61 := ddx_complete_rec.list_source;
    p1_a62 := ddx_complete_rec.list_source_type;
    p1_a63 := ddx_complete_rec.list_online_flag;
    p1_a64 := rosetta_g_miss_num_map(ddx_complete_rec.random_list_id);
    p1_a65 := ddx_complete_rec.enabled_flag;
    p1_a66 := rosetta_g_miss_num_map(ddx_complete_rec.assigned_to);
    p1_a67 := rosetta_g_miss_num_map(ddx_complete_rec.query_id);
    p1_a68 := rosetta_g_miss_num_map(ddx_complete_rec.owner_person_id);
    p1_a69 := rosetta_g_miss_num_map(ddx_complete_rec.archived_by);
    p1_a70 := ddx_complete_rec.archived_date;
    p1_a71 := ddx_complete_rec.attribute_category;
    p1_a72 := ddx_complete_rec.attribute1;
    p1_a73 := ddx_complete_rec.attribute2;
    p1_a74 := ddx_complete_rec.attribute3;
    p1_a75 := ddx_complete_rec.attribute4;
    p1_a76 := ddx_complete_rec.attribute5;
    p1_a77 := ddx_complete_rec.attribute6;
    p1_a78 := ddx_complete_rec.attribute7;
    p1_a79 := ddx_complete_rec.attribute8;
    p1_a80 := ddx_complete_rec.attribute9;
    p1_a81 := ddx_complete_rec.attribute10;
    p1_a82 := ddx_complete_rec.attribute11;
    p1_a83 := ddx_complete_rec.attribute12;
    p1_a84 := ddx_complete_rec.attribute13;
    p1_a85 := ddx_complete_rec.attribute14;
    p1_a86 := ddx_complete_rec.attribute15;
    p1_a87 := rosetta_g_miss_num_map(ddx_complete_rec.timezone_id);
    p1_a88 := ddx_complete_rec.user_entered_start_time;
    p1_a89 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
    p1_a90 := rosetta_g_miss_num_map(ddx_complete_rec.quantum);
    p1_a91 := rosetta_g_miss_num_map(ddx_complete_rec.release_control_alg_id);
    p1_a92 := ddx_complete_rec.dialing_method;
    p1_a93 := rosetta_g_miss_num_map(ddx_complete_rec.calling_calendar_id);
    p1_a94 := ddx_complete_rec.release_strategy;
    p1_a95 := rosetta_g_miss_num_map(ddx_complete_rec.custom_setup_id);
    p1_a96 := rosetta_g_miss_num_map(ddx_complete_rec.country);
    p1_a97 := ddx_complete_rec.callback_priority_flag;
    p1_a98 := ddx_complete_rec.call_center_ready_flag;
    p1_a99 := ddx_complete_rec.language;
    p1_a100 := ddx_complete_rec.purge_flag;
    p1_a101 := ddx_complete_rec.public_flag;
    p1_a102 := ddx_complete_rec.list_category;
    p1_a103 := rosetta_g_miss_num_map(ddx_complete_rec.quota);
    p1_a104 := rosetta_g_miss_num_map(ddx_complete_rec.quota_reset);
    p1_a105 := rosetta_g_miss_num_map(ddx_complete_rec.recycling_alg_id);
    p1_a106 := ddx_complete_rec.source_lang;
    p1_a107 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_prev_contacted);
    p1_a108 := ddx_complete_rec.apply_traffic_cop;
  end;

  procedure update_prev_contacted_count(p_used_by_id  NUMBER
    , p_used_by  VARCHAR2
    , p_last_contacted_date  date
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_last_contacted_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_last_contacted_date := rosetta_g_miss_date_in_map(p_last_contacted_date);






    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.update_prev_contacted_count(p_used_by_id,
      p_used_by,
      ddp_last_contacted_date,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure copy_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_listheader_id  NUMBER
    , p_copy_select_actions  VARCHAR2
    , p_copy_list_queries  VARCHAR2
    , p_copy_list_entries  VARCHAR2
    , x_listheader_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  DATE := fnd_api.g_miss_date
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  DATE := fnd_api.g_miss_date
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  NUMBER := 0-1962.0724
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  DATE := fnd_api.g_miss_date
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  DATE := fnd_api.g_miss_date
    , p8_a30  DATE := fnd_api.g_miss_date
    , p8_a31  DATE := fnd_api.g_miss_date
    , p8_a32  DATE := fnd_api.g_miss_date
    , p8_a33  DATE := fnd_api.g_miss_date
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  NUMBER := 0-1962.0724
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  NUMBER := 0-1962.0724
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  NUMBER := 0-1962.0724
    , p8_a42  NUMBER := 0-1962.0724
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  NUMBER := 0-1962.0724
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  NUMBER := 0-1962.0724
    , p8_a48  NUMBER := 0-1962.0724
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  DATE := fnd_api.g_miss_date
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  NUMBER := 0-1962.0724
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  VARCHAR2 := fnd_api.g_miss_char
    , p8_a58  VARCHAR2 := fnd_api.g_miss_char
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  NUMBER := 0-1962.0724
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  NUMBER := 0-1962.0724
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  NUMBER := 0-1962.0724
    , p8_a67  NUMBER := 0-1962.0724
    , p8_a68  NUMBER := 0-1962.0724
    , p8_a69  NUMBER := 0-1962.0724
    , p8_a70  DATE := fnd_api.g_miss_date
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  VARCHAR2 := fnd_api.g_miss_char
    , p8_a77  VARCHAR2 := fnd_api.g_miss_char
    , p8_a78  VARCHAR2 := fnd_api.g_miss_char
    , p8_a79  VARCHAR2 := fnd_api.g_miss_char
    , p8_a80  VARCHAR2 := fnd_api.g_miss_char
    , p8_a81  VARCHAR2 := fnd_api.g_miss_char
    , p8_a82  VARCHAR2 := fnd_api.g_miss_char
    , p8_a83  VARCHAR2 := fnd_api.g_miss_char
    , p8_a84  VARCHAR2 := fnd_api.g_miss_char
    , p8_a85  VARCHAR2 := fnd_api.g_miss_char
    , p8_a86  VARCHAR2 := fnd_api.g_miss_char
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  DATE := fnd_api.g_miss_date
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  NUMBER := 0-1962.0724
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  VARCHAR2 := fnd_api.g_miss_char
    , p8_a95  NUMBER := 0-1962.0724
    , p8_a96  NUMBER := 0-1962.0724
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  VARCHAR2 := fnd_api.g_miss_char
    , p8_a99  VARCHAR2 := fnd_api.g_miss_char
    , p8_a100  VARCHAR2 := fnd_api.g_miss_char
    , p8_a101  VARCHAR2 := fnd_api.g_miss_char
    , p8_a102  VARCHAR2 := fnd_api.g_miss_char
    , p8_a103  NUMBER := 0-1962.0724
    , p8_a104  NUMBER := 0-1962.0724
    , p8_a105  NUMBER := 0-1962.0724
    , p8_a106  VARCHAR2 := fnd_api.g_miss_char
    , p8_a107  NUMBER := 0-1962.0724
    , p8_a108  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_listheader_rec ams_listheader_pvt.list_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_listheader_rec.list_header_id := rosetta_g_miss_num_map(p8_a0);
    ddp_listheader_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a1);
    ddp_listheader_rec.last_updated_by := rosetta_g_miss_num_map(p8_a2);
    ddp_listheader_rec.creation_date := rosetta_g_miss_date_in_map(p8_a3);
    ddp_listheader_rec.created_by := rosetta_g_miss_num_map(p8_a4);
    ddp_listheader_rec.last_update_login := rosetta_g_miss_num_map(p8_a5);
    ddp_listheader_rec.object_version_number := rosetta_g_miss_num_map(p8_a6);
    ddp_listheader_rec.request_id := rosetta_g_miss_num_map(p8_a7);
    ddp_listheader_rec.program_id := rosetta_g_miss_num_map(p8_a8);
    ddp_listheader_rec.program_application_id := rosetta_g_miss_num_map(p8_a9);
    ddp_listheader_rec.program_update_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_listheader_rec.view_application_id := rosetta_g_miss_num_map(p8_a11);
    ddp_listheader_rec.list_name := p8_a12;
    ddp_listheader_rec.list_used_by_id := rosetta_g_miss_num_map(p8_a13);
    ddp_listheader_rec.arc_list_used_by := p8_a14;
    ddp_listheader_rec.list_type := p8_a15;
    ddp_listheader_rec.status_code := p8_a16;
    ddp_listheader_rec.status_date := rosetta_g_miss_date_in_map(p8_a17);
    ddp_listheader_rec.generation_type := p8_a18;
    ddp_listheader_rec.repeat_exclude_type := p8_a19;
    ddp_listheader_rec.row_selection_type := p8_a20;
    ddp_listheader_rec.owner_user_id := rosetta_g_miss_num_map(p8_a21);
    ddp_listheader_rec.access_level := p8_a22;
    ddp_listheader_rec.enable_log_flag := p8_a23;
    ddp_listheader_rec.enable_word_replacement_flag := p8_a24;
    ddp_listheader_rec.enable_parallel_dml_flag := p8_a25;
    ddp_listheader_rec.dedupe_during_generation_flag := p8_a26;
    ddp_listheader_rec.generate_control_group_flag := p8_a27;
    ddp_listheader_rec.last_generation_success_flag := p8_a28;
    ddp_listheader_rec.forecasted_start_date := rosetta_g_miss_date_in_map(p8_a29);
    ddp_listheader_rec.forecasted_end_date := rosetta_g_miss_date_in_map(p8_a30);
    ddp_listheader_rec.actual_end_date := rosetta_g_miss_date_in_map(p8_a31);
    ddp_listheader_rec.sent_out_date := rosetta_g_miss_date_in_map(p8_a32);
    ddp_listheader_rec.dedupe_start_date := rosetta_g_miss_date_in_map(p8_a33);
    ddp_listheader_rec.last_dedupe_date := rosetta_g_miss_date_in_map(p8_a34);
    ddp_listheader_rec.last_deduped_by_user_id := rosetta_g_miss_num_map(p8_a35);
    ddp_listheader_rec.workflow_item_key := rosetta_g_miss_num_map(p8_a36);
    ddp_listheader_rec.no_of_rows_duplicates := rosetta_g_miss_num_map(p8_a37);
    ddp_listheader_rec.no_of_rows_min_requested := rosetta_g_miss_num_map(p8_a38);
    ddp_listheader_rec.no_of_rows_max_requested := rosetta_g_miss_num_map(p8_a39);
    ddp_listheader_rec.no_of_rows_in_list := rosetta_g_miss_num_map(p8_a40);
    ddp_listheader_rec.no_of_rows_in_ctrl_group := rosetta_g_miss_num_map(p8_a41);
    ddp_listheader_rec.no_of_rows_active := rosetta_g_miss_num_map(p8_a42);
    ddp_listheader_rec.no_of_rows_inactive := rosetta_g_miss_num_map(p8_a43);
    ddp_listheader_rec.no_of_rows_manually_entered := rosetta_g_miss_num_map(p8_a44);
    ddp_listheader_rec.no_of_rows_do_not_call := rosetta_g_miss_num_map(p8_a45);
    ddp_listheader_rec.no_of_rows_do_not_mail := rosetta_g_miss_num_map(p8_a46);
    ddp_listheader_rec.no_of_rows_random := rosetta_g_miss_num_map(p8_a47);
    ddp_listheader_rec.org_id := rosetta_g_miss_num_map(p8_a48);
    ddp_listheader_rec.main_gen_start_time := rosetta_g_miss_date_in_map(p8_a49);
    ddp_listheader_rec.main_gen_end_time := rosetta_g_miss_date_in_map(p8_a50);
    ddp_listheader_rec.main_random_nth_row_selection := rosetta_g_miss_num_map(p8_a51);
    ddp_listheader_rec.main_random_pct_row_selection := rosetta_g_miss_num_map(p8_a52);
    ddp_listheader_rec.ctrl_random_nth_row_selection := rosetta_g_miss_num_map(p8_a53);
    ddp_listheader_rec.ctrl_random_pct_row_selection := rosetta_g_miss_num_map(p8_a54);
    ddp_listheader_rec.repeat_source_list_header_id := p8_a55;
    ddp_listheader_rec.result_text := p8_a56;
    ddp_listheader_rec.keywords := p8_a57;
    ddp_listheader_rec.description := p8_a58;
    ddp_listheader_rec.list_priority := rosetta_g_miss_num_map(p8_a59);
    ddp_listheader_rec.assign_person_id := rosetta_g_miss_num_map(p8_a60);
    ddp_listheader_rec.list_source := p8_a61;
    ddp_listheader_rec.list_source_type := p8_a62;
    ddp_listheader_rec.list_online_flag := p8_a63;
    ddp_listheader_rec.random_list_id := rosetta_g_miss_num_map(p8_a64);
    ddp_listheader_rec.enabled_flag := p8_a65;
    ddp_listheader_rec.assigned_to := rosetta_g_miss_num_map(p8_a66);
    ddp_listheader_rec.query_id := rosetta_g_miss_num_map(p8_a67);
    ddp_listheader_rec.owner_person_id := rosetta_g_miss_num_map(p8_a68);
    ddp_listheader_rec.archived_by := rosetta_g_miss_num_map(p8_a69);
    ddp_listheader_rec.archived_date := rosetta_g_miss_date_in_map(p8_a70);
    ddp_listheader_rec.attribute_category := p8_a71;
    ddp_listheader_rec.attribute1 := p8_a72;
    ddp_listheader_rec.attribute2 := p8_a73;
    ddp_listheader_rec.attribute3 := p8_a74;
    ddp_listheader_rec.attribute4 := p8_a75;
    ddp_listheader_rec.attribute5 := p8_a76;
    ddp_listheader_rec.attribute6 := p8_a77;
    ddp_listheader_rec.attribute7 := p8_a78;
    ddp_listheader_rec.attribute8 := p8_a79;
    ddp_listheader_rec.attribute9 := p8_a80;
    ddp_listheader_rec.attribute10 := p8_a81;
    ddp_listheader_rec.attribute11 := p8_a82;
    ddp_listheader_rec.attribute12 := p8_a83;
    ddp_listheader_rec.attribute13 := p8_a84;
    ddp_listheader_rec.attribute14 := p8_a85;
    ddp_listheader_rec.attribute15 := p8_a86;
    ddp_listheader_rec.timezone_id := rosetta_g_miss_num_map(p8_a87);
    ddp_listheader_rec.user_entered_start_time := rosetta_g_miss_date_in_map(p8_a88);
    ddp_listheader_rec.user_status_id := rosetta_g_miss_num_map(p8_a89);
    ddp_listheader_rec.quantum := rosetta_g_miss_num_map(p8_a90);
    ddp_listheader_rec.release_control_alg_id := rosetta_g_miss_num_map(p8_a91);
    ddp_listheader_rec.dialing_method := p8_a92;
    ddp_listheader_rec.calling_calendar_id := rosetta_g_miss_num_map(p8_a93);
    ddp_listheader_rec.release_strategy := p8_a94;
    ddp_listheader_rec.custom_setup_id := rosetta_g_miss_num_map(p8_a95);
    ddp_listheader_rec.country := rosetta_g_miss_num_map(p8_a96);
    ddp_listheader_rec.callback_priority_flag := p8_a97;
    ddp_listheader_rec.call_center_ready_flag := p8_a98;
    ddp_listheader_rec.language := p8_a99;
    ddp_listheader_rec.purge_flag := p8_a100;
    ddp_listheader_rec.public_flag := p8_a101;
    ddp_listheader_rec.list_category := p8_a102;
    ddp_listheader_rec.quota := rosetta_g_miss_num_map(p8_a103);
    ddp_listheader_rec.quota_reset := rosetta_g_miss_num_map(p8_a104);
    ddp_listheader_rec.recycling_alg_id := rosetta_g_miss_num_map(p8_a105);
    ddp_listheader_rec.source_lang := p8_a106;
    ddp_listheader_rec.no_of_rows_prev_contacted := rosetta_g_miss_num_map(p8_a107);
    ddp_listheader_rec.apply_traffic_cop := p8_a108;





    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pvt.copy_list(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_listheader_id,
      ddp_listheader_rec,
      p_copy_select_actions,
      p_copy_list_queries,
      p_copy_list_entries,
      x_listheader_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end ams_listheader_pvt_w;

/
