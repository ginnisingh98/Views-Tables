--------------------------------------------------------
--  DDL for Package Body AMS_TRIGGER_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRIGGER_PVT_OA" as
/* $Header: amsatgrb.pls 120.0 2005/08/30 08:39:11 kbasavar noship $ */
  procedure create_trigger(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  DATE
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  DATE
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  DATE
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  DATE
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  NUMBER
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  DATE
    , p9_a4  NUMBER
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  NUMBER
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  NUMBER
    , p9_a14  VARCHAR2
    , p9_a15  NUMBER
    , p9_a16  NUMBER
    , p9_a17  VARCHAR2
    , p9_a18  NUMBER
    , p9_a19  NUMBER
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  NUMBER
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  NUMBER
    , x_trigger_check_id out nocopy  NUMBER
    , x_trigger_action_id out nocopy  NUMBER
    , x_trigger_id out nocopy  NUMBER
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trig_rec.trigger_id := p7_a0;
    ddp_trig_rec.last_update_date := p7_a1;
    ddp_trig_rec.last_updated_by := p7_a2;
    ddp_trig_rec.creation_date := p7_a3;
    ddp_trig_rec.created_by := p7_a4;
    ddp_trig_rec.last_update_login := p7_a5;
    ddp_trig_rec.object_version_number := p7_a6;
    ddp_trig_rec.process_id := p7_a7;
    ddp_trig_rec.trigger_created_for_id := p7_a8;
    ddp_trig_rec.arc_trigger_created_for := p7_a9;
    ddp_trig_rec.triggering_type := p7_a10;
    ddp_trig_rec.view_application_id := p7_a11;
    ddp_trig_rec.timezone_id := p7_a12;
    ddp_trig_rec.user_start_date_time := p7_a13;
    ddp_trig_rec.start_date_time := p7_a14;
    ddp_trig_rec.user_last_run_date_time := p7_a15;
    ddp_trig_rec.last_run_date_time := p7_a16;
    ddp_trig_rec.user_next_run_date_time := p7_a17;
    ddp_trig_rec.next_run_date_time := p7_a18;
    ddp_trig_rec.user_repeat_daily_start_time := p7_a19;
    ddp_trig_rec.repeat_daily_start_time := p7_a20;
    ddp_trig_rec.user_repeat_daily_end_time := p7_a21;
    ddp_trig_rec.repeat_daily_end_time := p7_a22;
    ddp_trig_rec.repeat_frequency_type := p7_a23;
    ddp_trig_rec.repeat_every_x_frequency := p7_a24;
    ddp_trig_rec.user_repeat_stop_date_time := p7_a25;
    ddp_trig_rec.repeat_stop_date_time := p7_a26;
    ddp_trig_rec.metrics_refresh_type := p7_a27;
    ddp_trig_rec.trigger_name := p7_a28;
    ddp_trig_rec.description := p7_a29;
    ddp_trig_rec.notify_flag := p7_a30;
    ddp_trig_rec.execute_schedule_flag := p7_a31;
    ddp_trig_rec.triggered_status := p7_a32;
    ddp_trig_rec.usage := p7_a33;

    ddp_thldchk_rec.trigger_check_id := p8_a0;
    ddp_thldchk_rec.last_update_date := p8_a1;
    ddp_thldchk_rec.last_updated_by := p8_a2;
    ddp_thldchk_rec.creation_date := p8_a3;
    ddp_thldchk_rec.created_by := p8_a4;
    ddp_thldchk_rec.last_update_login := p8_a5;
    ddp_thldchk_rec.object_version_number := p8_a6;
    ddp_thldchk_rec.trigger_id := p8_a7;
    ddp_thldchk_rec.order_number := p8_a8;
    ddp_thldchk_rec.chk1_type := p8_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p8_a10;
    ddp_thldchk_rec.chk1_act_object_id := p8_a11;
    ddp_thldchk_rec.chk1_source_code := p8_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := p8_a13;
    ddp_thldchk_rec.chk1_source_code_metric_type := p8_a14;
    ddp_thldchk_rec.chk1_workbook_owner := p8_a15;
    ddp_thldchk_rec.chk1_workbook_name := p8_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p8_a17;
    ddp_thldchk_rec.chk2_type := p8_a18;
    ddp_thldchk_rec.chk2_value := p8_a19;
    ddp_thldchk_rec.chk2_low_value := p8_a20;
    ddp_thldchk_rec.chk2_high_value := p8_a21;
    ddp_thldchk_rec.chk2_uom_code := p8_a22;
    ddp_thldchk_rec.chk2_currency_code := p8_a23;
    ddp_thldchk_rec.chk2_source_code := p8_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p8_a25;
    ddp_thldchk_rec.chk2_act_object_id := p8_a26;
    ddp_thldchk_rec.chk2_source_code_metric_id := p8_a27;
    ddp_thldchk_rec.chk2_source_code_metric_type := p8_a28;
    ddp_thldchk_rec.chk2_workbook_name := p8_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p8_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p8_a31;

    ddp_thldact_rec.trigger_action_id := p9_a0;
    ddp_thldact_rec.last_update_date := p9_a1;
    ddp_thldact_rec.last_updated_by := p9_a2;
    ddp_thldact_rec.creation_date := p9_a3;
    ddp_thldact_rec.created_by := p9_a4;
    ddp_thldact_rec.last_update_login := p9_a5;
    ddp_thldact_rec.object_version_number := p9_a6;
    ddp_thldact_rec.process_id := p9_a7;
    ddp_thldact_rec.trigger_id := p9_a8;
    ddp_thldact_rec.order_number := p9_a9;
    ddp_thldact_rec.notify_flag := p9_a10;
    ddp_thldact_rec.generate_list_flag := p9_a11;
    ddp_thldact_rec.action_need_approval_flag := p9_a12;
    ddp_thldact_rec.action_approver_user_id := p9_a13;
    ddp_thldact_rec.execute_action_type := p9_a14;
    ddp_thldact_rec.list_header_id := p9_a15;
    ddp_thldact_rec.list_connected_to_id := p9_a16;
    ddp_thldact_rec.arc_list_connected_to := p9_a17;
    ddp_thldact_rec.deliverable_id := p9_a18;
    ddp_thldact_rec.activity_offer_id := p9_a19;
    ddp_thldact_rec.dscript_name := p9_a20;
    ddp_thldact_rec.program_to_call := p9_a21;
    ddp_thldact_rec.cover_letter_id := p9_a22;
    ddp_thldact_rec.mail_subject := p9_a23;
    ddp_thldact_rec.mail_sender_name := p9_a24;
    ddp_thldact_rec.from_fax_no := p9_a25;
    ddp_thldact_rec.action_for_id := p9_a26;




    -- here's the delegated call to the old PL/SQL routine
    ams_trigger_pvt.create_trigger(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trig_rec,
      ddp_thldchk_rec,
      ddp_thldact_rec,
      x_trigger_check_id,
      x_trigger_action_id,
      x_trigger_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure update_trigger(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  DATE
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  DATE
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  DATE
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  DATE
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  NUMBER
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  DATE
    , p9_a4  NUMBER
    , p9_a5  NUMBER
    , p9_a6  NUMBER
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  NUMBER
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  NUMBER
    , p9_a14  VARCHAR2
    , p9_a15  NUMBER
    , p9_a16  NUMBER
    , p9_a17  VARCHAR2
    , p9_a18  NUMBER
    , p9_a19  NUMBER
    , p9_a20  VARCHAR2
    , p9_a21  VARCHAR2
    , p9_a22  NUMBER
    , p9_a23  VARCHAR2
    , p9_a24  VARCHAR2
    , p9_a25  VARCHAR2
    , p9_a26  NUMBER
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trig_rec.trigger_id := p7_a0;
    ddp_trig_rec.last_update_date := p7_a1;
    ddp_trig_rec.last_updated_by := p7_a2;
    ddp_trig_rec.creation_date := p7_a3;
    ddp_trig_rec.created_by := p7_a4;
    ddp_trig_rec.last_update_login := p7_a5;
    ddp_trig_rec.object_version_number := p7_a6;
    ddp_trig_rec.process_id := p7_a7;
    ddp_trig_rec.trigger_created_for_id := p7_a8;
    ddp_trig_rec.arc_trigger_created_for := p7_a9;
    ddp_trig_rec.triggering_type := p7_a10;
    ddp_trig_rec.view_application_id := p7_a11;
    ddp_trig_rec.timezone_id := p7_a12;
    ddp_trig_rec.user_start_date_time := p7_a13;
    ddp_trig_rec.start_date_time := p7_a14;
    ddp_trig_rec.user_last_run_date_time := p7_a15;
    ddp_trig_rec.last_run_date_time := p7_a16;
    ddp_trig_rec.user_next_run_date_time := p7_a17;
    ddp_trig_rec.next_run_date_time := p7_a18;
    ddp_trig_rec.user_repeat_daily_start_time := p7_a19;
    ddp_trig_rec.repeat_daily_start_time := p7_a20;
    ddp_trig_rec.user_repeat_daily_end_time := p7_a21;
    ddp_trig_rec.repeat_daily_end_time := p7_a22;
    ddp_trig_rec.repeat_frequency_type := p7_a23;
    ddp_trig_rec.repeat_every_x_frequency := p7_a24;
    ddp_trig_rec.user_repeat_stop_date_time := p7_a25;
    ddp_trig_rec.repeat_stop_date_time := p7_a26;
    ddp_trig_rec.metrics_refresh_type := p7_a27;
    ddp_trig_rec.trigger_name := p7_a28;
    ddp_trig_rec.description := p7_a29;
    ddp_trig_rec.notify_flag := p7_a30;
    ddp_trig_rec.execute_schedule_flag := p7_a31;
    ddp_trig_rec.triggered_status := p7_a32;
    ddp_trig_rec.usage := p7_a33;

    ddp_thldchk_rec.trigger_check_id := p8_a0;
    ddp_thldchk_rec.last_update_date := p8_a1;
    ddp_thldchk_rec.last_updated_by := p8_a2;
    ddp_thldchk_rec.creation_date := p8_a3;
    ddp_thldchk_rec.created_by := p8_a4;
    ddp_thldchk_rec.last_update_login := p8_a5;
    ddp_thldchk_rec.object_version_number := p8_a6;
    ddp_thldchk_rec.trigger_id := p8_a7;
    ddp_thldchk_rec.order_number := p8_a8;
    ddp_thldchk_rec.chk1_type := p8_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p8_a10;
    ddp_thldchk_rec.chk1_act_object_id := p8_a11;
    ddp_thldchk_rec.chk1_source_code := p8_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := p8_a13;
    ddp_thldchk_rec.chk1_source_code_metric_type := p8_a14;
    ddp_thldchk_rec.chk1_workbook_owner := p8_a15;
    ddp_thldchk_rec.chk1_workbook_name := p8_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p8_a17;
    ddp_thldchk_rec.chk2_type := p8_a18;
    ddp_thldchk_rec.chk2_value := p8_a19;
    ddp_thldchk_rec.chk2_low_value := p8_a20;
    ddp_thldchk_rec.chk2_high_value := p8_a21;
    ddp_thldchk_rec.chk2_uom_code := p8_a22;
    ddp_thldchk_rec.chk2_currency_code := p8_a23;
    ddp_thldchk_rec.chk2_source_code := p8_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p8_a25;
    ddp_thldchk_rec.chk2_act_object_id := p8_a26;
    ddp_thldchk_rec.chk2_source_code_metric_id := p8_a27;
    ddp_thldchk_rec.chk2_source_code_metric_type := p8_a28;
    ddp_thldchk_rec.chk2_workbook_name := p8_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p8_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p8_a31;

    ddp_thldact_rec.trigger_action_id := p9_a0;
    ddp_thldact_rec.last_update_date := p9_a1;
    ddp_thldact_rec.last_updated_by := p9_a2;
    ddp_thldact_rec.creation_date := p9_a3;
    ddp_thldact_rec.created_by := p9_a4;
    ddp_thldact_rec.last_update_login := p9_a5;
    ddp_thldact_rec.object_version_number := p9_a6;
    ddp_thldact_rec.process_id := p9_a7;
    ddp_thldact_rec.trigger_id := p9_a8;
    ddp_thldact_rec.order_number := p9_a9;
    ddp_thldact_rec.notify_flag := p9_a10;
    ddp_thldact_rec.generate_list_flag := p9_a11;
    ddp_thldact_rec.action_need_approval_flag := p9_a12;
    ddp_thldact_rec.action_approver_user_id := p9_a13;
    ddp_thldact_rec.execute_action_type := p9_a14;
    ddp_thldact_rec.list_header_id := p9_a15;
    ddp_thldact_rec.list_connected_to_id := p9_a16;
    ddp_thldact_rec.arc_list_connected_to := p9_a17;
    ddp_thldact_rec.deliverable_id := p9_a18;
    ddp_thldact_rec.activity_offer_id := p9_a19;
    ddp_thldact_rec.dscript_name := p9_a20;
    ddp_thldact_rec.program_to_call := p9_a21;
    ddp_thldact_rec.cover_letter_id := p9_a22;
    ddp_thldact_rec.mail_subject := p9_a23;
    ddp_thldact_rec.mail_sender_name := p9_a24;
    ddp_thldact_rec.from_fax_no := p9_a25;
    ddp_thldact_rec.action_for_id := p9_a26;

    -- here's the delegated call to the old PL/SQL routine
    ams_trigger_pvt.update_trigger(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trig_rec,
      ddp_thldchk_rec,
      ddp_thldact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

FUNCTION get_ams_monitor_disable_delete(p_triggerId in NUMBER,p_start_date IN DATE)
RETURN VARCHAR2
IS
   l_delete VARCHAR2(1):='Y';

   CURSOR c_get_csch_count(p_trigId IN NUMBER) IS
            SELECT count(1) from ams_campaign_schedules_b
             WHERE trigger_id = p_trigId
                and   triggerable_flag = 'Y';
   l_csch_count NUMBER := 0;
BEGIN

   open c_get_csch_count(p_triggerId);
   fetch c_get_csch_count into l_csch_count;
   close c_get_csch_count;

   IF p_start_date < SYSDATE OR  l_csch_count >0 THEN
      l_delete := 'N';
   END IF;

   RETURN l_delete;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'Y';
   WHEN TOO_MANY_ROWS THEN
      RETURN 'N';
   WHEN OTHERS THEN
      RETURN 'Y';
END get_ams_monitor_disable_delete;

end ams_trigger_pvt_oa;

/
