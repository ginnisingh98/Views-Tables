--------------------------------------------------------
--  DDL for Package Body OZF_ACTFORECAST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTFORECAST_PVT_W" as
  /* $Header: ozfwfctb.pls 120.2 2005/07/29 02:55:56 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  DATE
    , p7_a59  DATE
    , p7_a60  VARCHAR2
    , x_forecast_id out nocopy  NUMBER
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_forecast_rec.forecast_id := p7_a0;
    ddp_act_forecast_rec.forecast_type := p7_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p7_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p7_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_act_forecast_rec.created_from := p7_a5;
    ddp_act_forecast_rec.created_by := p7_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_act_forecast_rec.last_updated_by := p7_a8;
    ddp_act_forecast_rec.last_update_login := p7_a9;
    ddp_act_forecast_rec.program_application_id := p7_a10;
    ddp_act_forecast_rec.program_id := p7_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_act_forecast_rec.request_id := p7_a13;
    ddp_act_forecast_rec.object_version_number := p7_a14;
    ddp_act_forecast_rec.hierarchy := p7_a15;
    ddp_act_forecast_rec.hierarchy_level := p7_a16;
    ddp_act_forecast_rec.level_value := p7_a17;
    ddp_act_forecast_rec.forecast_calendar := p7_a18;
    ddp_act_forecast_rec.period_level := p7_a19;
    ddp_act_forecast_rec.forecast_period_id := p7_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_act_forecast_rec.forecast_uom_code := p7_a22;
    ddp_act_forecast_rec.forecast_quantity := p7_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p7_a24;
    ddp_act_forecast_rec.forward_buy_period := p7_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p7_a26;
    ddp_act_forecast_rec.base_quantity := p7_a27;
    ddp_act_forecast_rec.context := p7_a28;
    ddp_act_forecast_rec.attribute_category := p7_a29;
    ddp_act_forecast_rec.attribute1 := p7_a30;
    ddp_act_forecast_rec.attribute2 := p7_a31;
    ddp_act_forecast_rec.attribute3 := p7_a32;
    ddp_act_forecast_rec.attribute4 := p7_a33;
    ddp_act_forecast_rec.attribute5 := p7_a34;
    ddp_act_forecast_rec.attribute6 := p7_a35;
    ddp_act_forecast_rec.attribute7 := p7_a36;
    ddp_act_forecast_rec.attribute8 := p7_a37;
    ddp_act_forecast_rec.attribute9 := p7_a38;
    ddp_act_forecast_rec.attribute10 := p7_a39;
    ddp_act_forecast_rec.attribute11 := p7_a40;
    ddp_act_forecast_rec.attribute12 := p7_a41;
    ddp_act_forecast_rec.attribute13 := p7_a42;
    ddp_act_forecast_rec.attribute14 := p7_a43;
    ddp_act_forecast_rec.attribute15 := p7_a44;
    ddp_act_forecast_rec.org_id := p7_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p7_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p7_a47;
    ddp_act_forecast_rec.base_quantity_type := p7_a48;
    ddp_act_forecast_rec.forecast_spread_type := p7_a49;
    ddp_act_forecast_rec.dimention1 := p7_a50;
    ddp_act_forecast_rec.dimention2 := p7_a51;
    ddp_act_forecast_rec.dimention3 := p7_a52;
    ddp_act_forecast_rec.last_scenario_id := p7_a53;
    ddp_act_forecast_rec.freeze_flag := p7_a54;
    ddp_act_forecast_rec.comments := p7_a55;
    ddp_act_forecast_rec.price_list_id := p7_a56;
    ddp_act_forecast_rec.base_quantity_ref := p7_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p7_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p7_a59);
    ddp_act_forecast_rec.offer_code := p7_a60;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.create_actforecast(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_forecast_rec,
      x_forecast_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  DATE
    , p7_a59  DATE
    , p7_a60  VARCHAR2
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_forecast_rec.forecast_id := p7_a0;
    ddp_act_forecast_rec.forecast_type := p7_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p7_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p7_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_act_forecast_rec.created_from := p7_a5;
    ddp_act_forecast_rec.created_by := p7_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_act_forecast_rec.last_updated_by := p7_a8;
    ddp_act_forecast_rec.last_update_login := p7_a9;
    ddp_act_forecast_rec.program_application_id := p7_a10;
    ddp_act_forecast_rec.program_id := p7_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_act_forecast_rec.request_id := p7_a13;
    ddp_act_forecast_rec.object_version_number := p7_a14;
    ddp_act_forecast_rec.hierarchy := p7_a15;
    ddp_act_forecast_rec.hierarchy_level := p7_a16;
    ddp_act_forecast_rec.level_value := p7_a17;
    ddp_act_forecast_rec.forecast_calendar := p7_a18;
    ddp_act_forecast_rec.period_level := p7_a19;
    ddp_act_forecast_rec.forecast_period_id := p7_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_act_forecast_rec.forecast_uom_code := p7_a22;
    ddp_act_forecast_rec.forecast_quantity := p7_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p7_a24;
    ddp_act_forecast_rec.forward_buy_period := p7_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p7_a26;
    ddp_act_forecast_rec.base_quantity := p7_a27;
    ddp_act_forecast_rec.context := p7_a28;
    ddp_act_forecast_rec.attribute_category := p7_a29;
    ddp_act_forecast_rec.attribute1 := p7_a30;
    ddp_act_forecast_rec.attribute2 := p7_a31;
    ddp_act_forecast_rec.attribute3 := p7_a32;
    ddp_act_forecast_rec.attribute4 := p7_a33;
    ddp_act_forecast_rec.attribute5 := p7_a34;
    ddp_act_forecast_rec.attribute6 := p7_a35;
    ddp_act_forecast_rec.attribute7 := p7_a36;
    ddp_act_forecast_rec.attribute8 := p7_a37;
    ddp_act_forecast_rec.attribute9 := p7_a38;
    ddp_act_forecast_rec.attribute10 := p7_a39;
    ddp_act_forecast_rec.attribute11 := p7_a40;
    ddp_act_forecast_rec.attribute12 := p7_a41;
    ddp_act_forecast_rec.attribute13 := p7_a42;
    ddp_act_forecast_rec.attribute14 := p7_a43;
    ddp_act_forecast_rec.attribute15 := p7_a44;
    ddp_act_forecast_rec.org_id := p7_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p7_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p7_a47;
    ddp_act_forecast_rec.base_quantity_type := p7_a48;
    ddp_act_forecast_rec.forecast_spread_type := p7_a49;
    ddp_act_forecast_rec.dimention1 := p7_a50;
    ddp_act_forecast_rec.dimention2 := p7_a51;
    ddp_act_forecast_rec.dimention3 := p7_a52;
    ddp_act_forecast_rec.last_scenario_id := p7_a53;
    ddp_act_forecast_rec.freeze_flag := p7_a54;
    ddp_act_forecast_rec.comments := p7_a55;
    ddp_act_forecast_rec.price_list_id := p7_a56;
    ddp_act_forecast_rec.base_quantity_ref := p7_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p7_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p7_a59);
    ddp_act_forecast_rec.offer_code := p7_a60;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.update_actforecast(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_forecast_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_actforecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  NUMBER
    , p6_a21  DATE
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  NUMBER
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  DATE
    , p6_a59  DATE
    , p6_a60  VARCHAR2
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_forecast_rec.forecast_id := p6_a0;
    ddp_act_forecast_rec.forecast_type := p6_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p6_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p6_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_act_forecast_rec.created_from := p6_a5;
    ddp_act_forecast_rec.created_by := p6_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a7);
    ddp_act_forecast_rec.last_updated_by := p6_a8;
    ddp_act_forecast_rec.last_update_login := p6_a9;
    ddp_act_forecast_rec.program_application_id := p6_a10;
    ddp_act_forecast_rec.program_id := p6_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_act_forecast_rec.request_id := p6_a13;
    ddp_act_forecast_rec.object_version_number := p6_a14;
    ddp_act_forecast_rec.hierarchy := p6_a15;
    ddp_act_forecast_rec.hierarchy_level := p6_a16;
    ddp_act_forecast_rec.level_value := p6_a17;
    ddp_act_forecast_rec.forecast_calendar := p6_a18;
    ddp_act_forecast_rec.period_level := p6_a19;
    ddp_act_forecast_rec.forecast_period_id := p6_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p6_a21);
    ddp_act_forecast_rec.forecast_uom_code := p6_a22;
    ddp_act_forecast_rec.forecast_quantity := p6_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p6_a24;
    ddp_act_forecast_rec.forward_buy_period := p6_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p6_a26;
    ddp_act_forecast_rec.base_quantity := p6_a27;
    ddp_act_forecast_rec.context := p6_a28;
    ddp_act_forecast_rec.attribute_category := p6_a29;
    ddp_act_forecast_rec.attribute1 := p6_a30;
    ddp_act_forecast_rec.attribute2 := p6_a31;
    ddp_act_forecast_rec.attribute3 := p6_a32;
    ddp_act_forecast_rec.attribute4 := p6_a33;
    ddp_act_forecast_rec.attribute5 := p6_a34;
    ddp_act_forecast_rec.attribute6 := p6_a35;
    ddp_act_forecast_rec.attribute7 := p6_a36;
    ddp_act_forecast_rec.attribute8 := p6_a37;
    ddp_act_forecast_rec.attribute9 := p6_a38;
    ddp_act_forecast_rec.attribute10 := p6_a39;
    ddp_act_forecast_rec.attribute11 := p6_a40;
    ddp_act_forecast_rec.attribute12 := p6_a41;
    ddp_act_forecast_rec.attribute13 := p6_a42;
    ddp_act_forecast_rec.attribute14 := p6_a43;
    ddp_act_forecast_rec.attribute15 := p6_a44;
    ddp_act_forecast_rec.org_id := p6_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p6_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p6_a47;
    ddp_act_forecast_rec.base_quantity_type := p6_a48;
    ddp_act_forecast_rec.forecast_spread_type := p6_a49;
    ddp_act_forecast_rec.dimention1 := p6_a50;
    ddp_act_forecast_rec.dimention2 := p6_a51;
    ddp_act_forecast_rec.dimention3 := p6_a52;
    ddp_act_forecast_rec.last_scenario_id := p6_a53;
    ddp_act_forecast_rec.freeze_flag := p6_a54;
    ddp_act_forecast_rec.comments := p6_a55;
    ddp_act_forecast_rec.price_list_id := p6_a56;
    ddp_act_forecast_rec.base_quantity_ref := p6_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p6_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p6_a59);
    ddp_act_forecast_rec.offer_code := p6_a60;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.validate_actforecast(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_forecast_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_actfcst_items(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_forecast_rec.forecast_id := p0_a0;
    ddp_act_forecast_rec.forecast_type := p0_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p0_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p0_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_act_forecast_rec.created_from := p0_a5;
    ddp_act_forecast_rec.created_by := p0_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_act_forecast_rec.last_updated_by := p0_a8;
    ddp_act_forecast_rec.last_update_login := p0_a9;
    ddp_act_forecast_rec.program_application_id := p0_a10;
    ddp_act_forecast_rec.program_id := p0_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_act_forecast_rec.request_id := p0_a13;
    ddp_act_forecast_rec.object_version_number := p0_a14;
    ddp_act_forecast_rec.hierarchy := p0_a15;
    ddp_act_forecast_rec.hierarchy_level := p0_a16;
    ddp_act_forecast_rec.level_value := p0_a17;
    ddp_act_forecast_rec.forecast_calendar := p0_a18;
    ddp_act_forecast_rec.period_level := p0_a19;
    ddp_act_forecast_rec.forecast_period_id := p0_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p0_a21);
    ddp_act_forecast_rec.forecast_uom_code := p0_a22;
    ddp_act_forecast_rec.forecast_quantity := p0_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p0_a24;
    ddp_act_forecast_rec.forward_buy_period := p0_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p0_a26;
    ddp_act_forecast_rec.base_quantity := p0_a27;
    ddp_act_forecast_rec.context := p0_a28;
    ddp_act_forecast_rec.attribute_category := p0_a29;
    ddp_act_forecast_rec.attribute1 := p0_a30;
    ddp_act_forecast_rec.attribute2 := p0_a31;
    ddp_act_forecast_rec.attribute3 := p0_a32;
    ddp_act_forecast_rec.attribute4 := p0_a33;
    ddp_act_forecast_rec.attribute5 := p0_a34;
    ddp_act_forecast_rec.attribute6 := p0_a35;
    ddp_act_forecast_rec.attribute7 := p0_a36;
    ddp_act_forecast_rec.attribute8 := p0_a37;
    ddp_act_forecast_rec.attribute9 := p0_a38;
    ddp_act_forecast_rec.attribute10 := p0_a39;
    ddp_act_forecast_rec.attribute11 := p0_a40;
    ddp_act_forecast_rec.attribute12 := p0_a41;
    ddp_act_forecast_rec.attribute13 := p0_a42;
    ddp_act_forecast_rec.attribute14 := p0_a43;
    ddp_act_forecast_rec.attribute15 := p0_a44;
    ddp_act_forecast_rec.org_id := p0_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p0_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p0_a47;
    ddp_act_forecast_rec.base_quantity_type := p0_a48;
    ddp_act_forecast_rec.forecast_spread_type := p0_a49;
    ddp_act_forecast_rec.dimention1 := p0_a50;
    ddp_act_forecast_rec.dimention2 := p0_a51;
    ddp_act_forecast_rec.dimention3 := p0_a52;
    ddp_act_forecast_rec.last_scenario_id := p0_a53;
    ddp_act_forecast_rec.freeze_flag := p0_a54;
    ddp_act_forecast_rec.comments := p0_a55;
    ddp_act_forecast_rec.price_list_id := p0_a56;
    ddp_act_forecast_rec.base_quantity_ref := p0_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p0_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p0_a59);
    ddp_act_forecast_rec.offer_code := p0_a60;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.validate_actfcst_items(ddp_act_forecast_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_actfcst_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  VARCHAR2
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  DATE
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  NUMBER
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  DATE
    , p1_a59  DATE
    , p1_a60  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddp_complete_fcst_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_forecast_rec.forecast_id := p0_a0;
    ddp_act_forecast_rec.forecast_type := p0_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p0_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p0_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_act_forecast_rec.created_from := p0_a5;
    ddp_act_forecast_rec.created_by := p0_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_act_forecast_rec.last_updated_by := p0_a8;
    ddp_act_forecast_rec.last_update_login := p0_a9;
    ddp_act_forecast_rec.program_application_id := p0_a10;
    ddp_act_forecast_rec.program_id := p0_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_act_forecast_rec.request_id := p0_a13;
    ddp_act_forecast_rec.object_version_number := p0_a14;
    ddp_act_forecast_rec.hierarchy := p0_a15;
    ddp_act_forecast_rec.hierarchy_level := p0_a16;
    ddp_act_forecast_rec.level_value := p0_a17;
    ddp_act_forecast_rec.forecast_calendar := p0_a18;
    ddp_act_forecast_rec.period_level := p0_a19;
    ddp_act_forecast_rec.forecast_period_id := p0_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p0_a21);
    ddp_act_forecast_rec.forecast_uom_code := p0_a22;
    ddp_act_forecast_rec.forecast_quantity := p0_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p0_a24;
    ddp_act_forecast_rec.forward_buy_period := p0_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p0_a26;
    ddp_act_forecast_rec.base_quantity := p0_a27;
    ddp_act_forecast_rec.context := p0_a28;
    ddp_act_forecast_rec.attribute_category := p0_a29;
    ddp_act_forecast_rec.attribute1 := p0_a30;
    ddp_act_forecast_rec.attribute2 := p0_a31;
    ddp_act_forecast_rec.attribute3 := p0_a32;
    ddp_act_forecast_rec.attribute4 := p0_a33;
    ddp_act_forecast_rec.attribute5 := p0_a34;
    ddp_act_forecast_rec.attribute6 := p0_a35;
    ddp_act_forecast_rec.attribute7 := p0_a36;
    ddp_act_forecast_rec.attribute8 := p0_a37;
    ddp_act_forecast_rec.attribute9 := p0_a38;
    ddp_act_forecast_rec.attribute10 := p0_a39;
    ddp_act_forecast_rec.attribute11 := p0_a40;
    ddp_act_forecast_rec.attribute12 := p0_a41;
    ddp_act_forecast_rec.attribute13 := p0_a42;
    ddp_act_forecast_rec.attribute14 := p0_a43;
    ddp_act_forecast_rec.attribute15 := p0_a44;
    ddp_act_forecast_rec.org_id := p0_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p0_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p0_a47;
    ddp_act_forecast_rec.base_quantity_type := p0_a48;
    ddp_act_forecast_rec.forecast_spread_type := p0_a49;
    ddp_act_forecast_rec.dimention1 := p0_a50;
    ddp_act_forecast_rec.dimention2 := p0_a51;
    ddp_act_forecast_rec.dimention3 := p0_a52;
    ddp_act_forecast_rec.last_scenario_id := p0_a53;
    ddp_act_forecast_rec.freeze_flag := p0_a54;
    ddp_act_forecast_rec.comments := p0_a55;
    ddp_act_forecast_rec.price_list_id := p0_a56;
    ddp_act_forecast_rec.base_quantity_ref := p0_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p0_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p0_a59);
    ddp_act_forecast_rec.offer_code := p0_a60;

    ddp_complete_fcst_rec.forecast_id := p1_a0;
    ddp_complete_fcst_rec.forecast_type := p1_a1;
    ddp_complete_fcst_rec.arc_act_fcast_used_by := p1_a2;
    ddp_complete_fcst_rec.act_fcast_used_by_id := p1_a3;
    ddp_complete_fcst_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_fcst_rec.created_from := p1_a5;
    ddp_complete_fcst_rec.created_by := p1_a6;
    ddp_complete_fcst_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_complete_fcst_rec.last_updated_by := p1_a8;
    ddp_complete_fcst_rec.last_update_login := p1_a9;
    ddp_complete_fcst_rec.program_application_id := p1_a10;
    ddp_complete_fcst_rec.program_id := p1_a11;
    ddp_complete_fcst_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a12);
    ddp_complete_fcst_rec.request_id := p1_a13;
    ddp_complete_fcst_rec.object_version_number := p1_a14;
    ddp_complete_fcst_rec.hierarchy := p1_a15;
    ddp_complete_fcst_rec.hierarchy_level := p1_a16;
    ddp_complete_fcst_rec.level_value := p1_a17;
    ddp_complete_fcst_rec.forecast_calendar := p1_a18;
    ddp_complete_fcst_rec.period_level := p1_a19;
    ddp_complete_fcst_rec.forecast_period_id := p1_a20;
    ddp_complete_fcst_rec.forecast_date := rosetta_g_miss_date_in_map(p1_a21);
    ddp_complete_fcst_rec.forecast_uom_code := p1_a22;
    ddp_complete_fcst_rec.forecast_quantity := p1_a23;
    ddp_complete_fcst_rec.forward_buy_quantity := p1_a24;
    ddp_complete_fcst_rec.forward_buy_period := p1_a25;
    ddp_complete_fcst_rec.cumulation_period_choice := p1_a26;
    ddp_complete_fcst_rec.base_quantity := p1_a27;
    ddp_complete_fcst_rec.context := p1_a28;
    ddp_complete_fcst_rec.attribute_category := p1_a29;
    ddp_complete_fcst_rec.attribute1 := p1_a30;
    ddp_complete_fcst_rec.attribute2 := p1_a31;
    ddp_complete_fcst_rec.attribute3 := p1_a32;
    ddp_complete_fcst_rec.attribute4 := p1_a33;
    ddp_complete_fcst_rec.attribute5 := p1_a34;
    ddp_complete_fcst_rec.attribute6 := p1_a35;
    ddp_complete_fcst_rec.attribute7 := p1_a36;
    ddp_complete_fcst_rec.attribute8 := p1_a37;
    ddp_complete_fcst_rec.attribute9 := p1_a38;
    ddp_complete_fcst_rec.attribute10 := p1_a39;
    ddp_complete_fcst_rec.attribute11 := p1_a40;
    ddp_complete_fcst_rec.attribute12 := p1_a41;
    ddp_complete_fcst_rec.attribute13 := p1_a42;
    ddp_complete_fcst_rec.attribute14 := p1_a43;
    ddp_complete_fcst_rec.attribute15 := p1_a44;
    ddp_complete_fcst_rec.org_id := p1_a45;
    ddp_complete_fcst_rec.forecast_remaining_quantity := p1_a46;
    ddp_complete_fcst_rec.forecast_remaining_percent := p1_a47;
    ddp_complete_fcst_rec.base_quantity_type := p1_a48;
    ddp_complete_fcst_rec.forecast_spread_type := p1_a49;
    ddp_complete_fcst_rec.dimention1 := p1_a50;
    ddp_complete_fcst_rec.dimention2 := p1_a51;
    ddp_complete_fcst_rec.dimention3 := p1_a52;
    ddp_complete_fcst_rec.last_scenario_id := p1_a53;
    ddp_complete_fcst_rec.freeze_flag := p1_a54;
    ddp_complete_fcst_rec.comments := p1_a55;
    ddp_complete_fcst_rec.price_list_id := p1_a56;
    ddp_complete_fcst_rec.base_quantity_ref := p1_a57;
    ddp_complete_fcst_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p1_a58);
    ddp_complete_fcst_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p1_a59);
    ddp_complete_fcst_rec.offer_code := p1_a60;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.validate_actfcst_rec(ddp_act_forecast_rec,
      ddp_complete_fcst_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_actfcst_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  DATE
    , p0_a59  DATE
    , p0_a60  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  VARCHAR2
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  DATE
    , p1_a59 out nocopy  DATE
    , p1_a60 out nocopy  VARCHAR2
  )

  as
    ddp_act_forecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddx_complete_fcst_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_forecast_rec.forecast_id := p0_a0;
    ddp_act_forecast_rec.forecast_type := p0_a1;
    ddp_act_forecast_rec.arc_act_fcast_used_by := p0_a2;
    ddp_act_forecast_rec.act_fcast_used_by_id := p0_a3;
    ddp_act_forecast_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_act_forecast_rec.created_from := p0_a5;
    ddp_act_forecast_rec.created_by := p0_a6;
    ddp_act_forecast_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_act_forecast_rec.last_updated_by := p0_a8;
    ddp_act_forecast_rec.last_update_login := p0_a9;
    ddp_act_forecast_rec.program_application_id := p0_a10;
    ddp_act_forecast_rec.program_id := p0_a11;
    ddp_act_forecast_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_act_forecast_rec.request_id := p0_a13;
    ddp_act_forecast_rec.object_version_number := p0_a14;
    ddp_act_forecast_rec.hierarchy := p0_a15;
    ddp_act_forecast_rec.hierarchy_level := p0_a16;
    ddp_act_forecast_rec.level_value := p0_a17;
    ddp_act_forecast_rec.forecast_calendar := p0_a18;
    ddp_act_forecast_rec.period_level := p0_a19;
    ddp_act_forecast_rec.forecast_period_id := p0_a20;
    ddp_act_forecast_rec.forecast_date := rosetta_g_miss_date_in_map(p0_a21);
    ddp_act_forecast_rec.forecast_uom_code := p0_a22;
    ddp_act_forecast_rec.forecast_quantity := p0_a23;
    ddp_act_forecast_rec.forward_buy_quantity := p0_a24;
    ddp_act_forecast_rec.forward_buy_period := p0_a25;
    ddp_act_forecast_rec.cumulation_period_choice := p0_a26;
    ddp_act_forecast_rec.base_quantity := p0_a27;
    ddp_act_forecast_rec.context := p0_a28;
    ddp_act_forecast_rec.attribute_category := p0_a29;
    ddp_act_forecast_rec.attribute1 := p0_a30;
    ddp_act_forecast_rec.attribute2 := p0_a31;
    ddp_act_forecast_rec.attribute3 := p0_a32;
    ddp_act_forecast_rec.attribute4 := p0_a33;
    ddp_act_forecast_rec.attribute5 := p0_a34;
    ddp_act_forecast_rec.attribute6 := p0_a35;
    ddp_act_forecast_rec.attribute7 := p0_a36;
    ddp_act_forecast_rec.attribute8 := p0_a37;
    ddp_act_forecast_rec.attribute9 := p0_a38;
    ddp_act_forecast_rec.attribute10 := p0_a39;
    ddp_act_forecast_rec.attribute11 := p0_a40;
    ddp_act_forecast_rec.attribute12 := p0_a41;
    ddp_act_forecast_rec.attribute13 := p0_a42;
    ddp_act_forecast_rec.attribute14 := p0_a43;
    ddp_act_forecast_rec.attribute15 := p0_a44;
    ddp_act_forecast_rec.org_id := p0_a45;
    ddp_act_forecast_rec.forecast_remaining_quantity := p0_a46;
    ddp_act_forecast_rec.forecast_remaining_percent := p0_a47;
    ddp_act_forecast_rec.base_quantity_type := p0_a48;
    ddp_act_forecast_rec.forecast_spread_type := p0_a49;
    ddp_act_forecast_rec.dimention1 := p0_a50;
    ddp_act_forecast_rec.dimention2 := p0_a51;
    ddp_act_forecast_rec.dimention3 := p0_a52;
    ddp_act_forecast_rec.last_scenario_id := p0_a53;
    ddp_act_forecast_rec.freeze_flag := p0_a54;
    ddp_act_forecast_rec.comments := p0_a55;
    ddp_act_forecast_rec.price_list_id := p0_a56;
    ddp_act_forecast_rec.base_quantity_ref := p0_a57;
    ddp_act_forecast_rec.base_quantity_start_date := rosetta_g_miss_date_in_map(p0_a58);
    ddp_act_forecast_rec.base_quantity_end_date := rosetta_g_miss_date_in_map(p0_a59);
    ddp_act_forecast_rec.offer_code := p0_a60;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.complete_actfcst_rec(ddp_act_forecast_rec,
      ddx_complete_fcst_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_fcst_rec.forecast_id;
    p1_a1 := ddx_complete_fcst_rec.forecast_type;
    p1_a2 := ddx_complete_fcst_rec.arc_act_fcast_used_by;
    p1_a3 := ddx_complete_fcst_rec.act_fcast_used_by_id;
    p1_a4 := ddx_complete_fcst_rec.creation_date;
    p1_a5 := ddx_complete_fcst_rec.created_from;
    p1_a6 := ddx_complete_fcst_rec.created_by;
    p1_a7 := ddx_complete_fcst_rec.last_update_date;
    p1_a8 := ddx_complete_fcst_rec.last_updated_by;
    p1_a9 := ddx_complete_fcst_rec.last_update_login;
    p1_a10 := ddx_complete_fcst_rec.program_application_id;
    p1_a11 := ddx_complete_fcst_rec.program_id;
    p1_a12 := ddx_complete_fcst_rec.program_update_date;
    p1_a13 := ddx_complete_fcst_rec.request_id;
    p1_a14 := ddx_complete_fcst_rec.object_version_number;
    p1_a15 := ddx_complete_fcst_rec.hierarchy;
    p1_a16 := ddx_complete_fcst_rec.hierarchy_level;
    p1_a17 := ddx_complete_fcst_rec.level_value;
    p1_a18 := ddx_complete_fcst_rec.forecast_calendar;
    p1_a19 := ddx_complete_fcst_rec.period_level;
    p1_a20 := ddx_complete_fcst_rec.forecast_period_id;
    p1_a21 := ddx_complete_fcst_rec.forecast_date;
    p1_a22 := ddx_complete_fcst_rec.forecast_uom_code;
    p1_a23 := ddx_complete_fcst_rec.forecast_quantity;
    p1_a24 := ddx_complete_fcst_rec.forward_buy_quantity;
    p1_a25 := ddx_complete_fcst_rec.forward_buy_period;
    p1_a26 := ddx_complete_fcst_rec.cumulation_period_choice;
    p1_a27 := ddx_complete_fcst_rec.base_quantity;
    p1_a28 := ddx_complete_fcst_rec.context;
    p1_a29 := ddx_complete_fcst_rec.attribute_category;
    p1_a30 := ddx_complete_fcst_rec.attribute1;
    p1_a31 := ddx_complete_fcst_rec.attribute2;
    p1_a32 := ddx_complete_fcst_rec.attribute3;
    p1_a33 := ddx_complete_fcst_rec.attribute4;
    p1_a34 := ddx_complete_fcst_rec.attribute5;
    p1_a35 := ddx_complete_fcst_rec.attribute6;
    p1_a36 := ddx_complete_fcst_rec.attribute7;
    p1_a37 := ddx_complete_fcst_rec.attribute8;
    p1_a38 := ddx_complete_fcst_rec.attribute9;
    p1_a39 := ddx_complete_fcst_rec.attribute10;
    p1_a40 := ddx_complete_fcst_rec.attribute11;
    p1_a41 := ddx_complete_fcst_rec.attribute12;
    p1_a42 := ddx_complete_fcst_rec.attribute13;
    p1_a43 := ddx_complete_fcst_rec.attribute14;
    p1_a44 := ddx_complete_fcst_rec.attribute15;
    p1_a45 := ddx_complete_fcst_rec.org_id;
    p1_a46 := ddx_complete_fcst_rec.forecast_remaining_quantity;
    p1_a47 := ddx_complete_fcst_rec.forecast_remaining_percent;
    p1_a48 := ddx_complete_fcst_rec.base_quantity_type;
    p1_a49 := ddx_complete_fcst_rec.forecast_spread_type;
    p1_a50 := ddx_complete_fcst_rec.dimention1;
    p1_a51 := ddx_complete_fcst_rec.dimention2;
    p1_a52 := ddx_complete_fcst_rec.dimention3;
    p1_a53 := ddx_complete_fcst_rec.last_scenario_id;
    p1_a54 := ddx_complete_fcst_rec.freeze_flag;
    p1_a55 := ddx_complete_fcst_rec.comments;
    p1_a56 := ddx_complete_fcst_rec.price_list_id;
    p1_a57 := ddx_complete_fcst_rec.base_quantity_ref;
    p1_a58 := ddx_complete_fcst_rec.base_quantity_start_date;
    p1_a59 := ddx_complete_fcst_rec.base_quantity_end_date;
    p1_a60 := ddx_complete_fcst_rec.offer_code;
  end;

  procedure init_actforecast_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  VARCHAR2
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  DATE
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  NUMBER
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  DATE
    , p0_a59 out nocopy  DATE
    , p0_a60 out nocopy  VARCHAR2
  )

  as
    ddx_actforecast_rec ozf_actforecast_pvt.act_forecast_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_actforecast_pvt.init_actforecast_rec(ddx_actforecast_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_actforecast_rec.forecast_id;
    p0_a1 := ddx_actforecast_rec.forecast_type;
    p0_a2 := ddx_actforecast_rec.arc_act_fcast_used_by;
    p0_a3 := ddx_actforecast_rec.act_fcast_used_by_id;
    p0_a4 := ddx_actforecast_rec.creation_date;
    p0_a5 := ddx_actforecast_rec.created_from;
    p0_a6 := ddx_actforecast_rec.created_by;
    p0_a7 := ddx_actforecast_rec.last_update_date;
    p0_a8 := ddx_actforecast_rec.last_updated_by;
    p0_a9 := ddx_actforecast_rec.last_update_login;
    p0_a10 := ddx_actforecast_rec.program_application_id;
    p0_a11 := ddx_actforecast_rec.program_id;
    p0_a12 := ddx_actforecast_rec.program_update_date;
    p0_a13 := ddx_actforecast_rec.request_id;
    p0_a14 := ddx_actforecast_rec.object_version_number;
    p0_a15 := ddx_actforecast_rec.hierarchy;
    p0_a16 := ddx_actforecast_rec.hierarchy_level;
    p0_a17 := ddx_actforecast_rec.level_value;
    p0_a18 := ddx_actforecast_rec.forecast_calendar;
    p0_a19 := ddx_actforecast_rec.period_level;
    p0_a20 := ddx_actforecast_rec.forecast_period_id;
    p0_a21 := ddx_actforecast_rec.forecast_date;
    p0_a22 := ddx_actforecast_rec.forecast_uom_code;
    p0_a23 := ddx_actforecast_rec.forecast_quantity;
    p0_a24 := ddx_actforecast_rec.forward_buy_quantity;
    p0_a25 := ddx_actforecast_rec.forward_buy_period;
    p0_a26 := ddx_actforecast_rec.cumulation_period_choice;
    p0_a27 := ddx_actforecast_rec.base_quantity;
    p0_a28 := ddx_actforecast_rec.context;
    p0_a29 := ddx_actforecast_rec.attribute_category;
    p0_a30 := ddx_actforecast_rec.attribute1;
    p0_a31 := ddx_actforecast_rec.attribute2;
    p0_a32 := ddx_actforecast_rec.attribute3;
    p0_a33 := ddx_actforecast_rec.attribute4;
    p0_a34 := ddx_actforecast_rec.attribute5;
    p0_a35 := ddx_actforecast_rec.attribute6;
    p0_a36 := ddx_actforecast_rec.attribute7;
    p0_a37 := ddx_actforecast_rec.attribute8;
    p0_a38 := ddx_actforecast_rec.attribute9;
    p0_a39 := ddx_actforecast_rec.attribute10;
    p0_a40 := ddx_actforecast_rec.attribute11;
    p0_a41 := ddx_actforecast_rec.attribute12;
    p0_a42 := ddx_actforecast_rec.attribute13;
    p0_a43 := ddx_actforecast_rec.attribute14;
    p0_a44 := ddx_actforecast_rec.attribute15;
    p0_a45 := ddx_actforecast_rec.org_id;
    p0_a46 := ddx_actforecast_rec.forecast_remaining_quantity;
    p0_a47 := ddx_actforecast_rec.forecast_remaining_percent;
    p0_a48 := ddx_actforecast_rec.base_quantity_type;
    p0_a49 := ddx_actforecast_rec.forecast_spread_type;
    p0_a50 := ddx_actforecast_rec.dimention1;
    p0_a51 := ddx_actforecast_rec.dimention2;
    p0_a52 := ddx_actforecast_rec.dimention3;
    p0_a53 := ddx_actforecast_rec.last_scenario_id;
    p0_a54 := ddx_actforecast_rec.freeze_flag;
    p0_a55 := ddx_actforecast_rec.comments;
    p0_a56 := ddx_actforecast_rec.price_list_id;
    p0_a57 := ddx_actforecast_rec.base_quantity_ref;
    p0_a58 := ddx_actforecast_rec.base_quantity_start_date;
    p0_a59 := ddx_actforecast_rec.base_quantity_end_date;
    p0_a60 := ddx_actforecast_rec.offer_code;
  end;

end ozf_actforecast_pvt_w;

/
