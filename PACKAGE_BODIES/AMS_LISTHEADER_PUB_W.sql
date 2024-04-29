--------------------------------------------------------
--  DDL for Package Body AMS_LISTHEADER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTHEADER_PUB_W" as
  /* $Header: amszlshb.pls 115.8 2002/11/22 08:58:31 jieli ship $ */
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

  procedure create_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_listheader_id OUT NOCOPY  NUMBER
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


    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pub.create_listheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec,
      x_listheader_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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

    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pub.update_listheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_listheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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

    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pub.validate_listheader(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listheader_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure copy_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_source_listheader_id  NUMBER
    , p_copy_select_actions  VARCHAR2
    , p_copy_list_queries  VARCHAR2
    , p_copy_list_entries  VARCHAR2
    , x_listheader_id OUT NOCOPY  NUMBER
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





    -- here's the delegated call to the old PL/SQL routine
    ams_listheader_pub.copy_list(p_api_version,
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

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

end ams_listheader_pub_w;

/
