--------------------------------------------------------
--  DDL for Package Body OZF_FORECAST_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FORECAST_UTIL_PVT_W" as
  /* $Header: ozfwfoub.pls 120.0 2005/11/04 18:50 mkothari noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function get_best_fit_lift(p_obj_type  VARCHAR2
    , p_obj_id  NUMBER
    , p_forecast_id  NUMBER
    , p_base_quantity_ref  VARCHAR2
    , p_market_type  VARCHAR2
    , p_market_id  NUMBER
    , p_product_attribute_context  VARCHAR2
    , p_product_attribute  VARCHAR2
    , p_product_attr_value  VARCHAR2
    , p_product_id  NUMBER
    , p_tpr_percent  NUMBER
    , p_report_date  date
  ) return number

  as
    ddp_report_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_report_date := rosetta_g_miss_date_in_map(p_report_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ozf_forecast_util_pvt.get_best_fit_lift(p_obj_type,
      p_obj_id,
      p_forecast_id,
      p_base_quantity_ref,
      p_market_type,
      p_market_id,
      p_product_attribute_context,
      p_product_attribute,
      p_product_attr_value,
      p_product_id,
      p_tpr_percent,
      ddp_report_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    return ddrosetta_retval;
  end;

  procedure create_forecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_obj_type  VARCHAR2
    , p_obj_id  NUMBER
    , p_fcst_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_base_quantity_type  VARCHAR2
    , p_base_quantity_ref  VARCHAR2
    , p_last_scenario_id  NUMBER
    , p_offer_code  VARCHAR2
    , x_forecast_id in out nocopy  NUMBER
    , x_activity_metric_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);










    -- here's the delegated call to the old PL/SQL routine
    ozf_forecast_util_pvt.create_forecast(p_api_version,
      p_init_msg_list,
      p_commit,
      p_obj_type,
      p_obj_id,
      p_fcst_uom,
      ddp_start_date,
      ddp_end_date,
      p_base_quantity_type,
      p_base_quantity_ref,
      p_last_scenario_id,
      p_offer_code,
      x_forecast_id,
      x_activity_metric_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure create_base_sales(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_obj_type  VARCHAR2
    , p_obj_id  NUMBER
    , p_forecast_id  NUMBER
    , p_activity_metric_id  NUMBER
    , p_level  VARCHAR2
    , p_dimention  VARCHAR2
    , p_fcst_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_period_level  VARCHAR2
    , p_base_quantity_type  VARCHAR2
    , p_base_quantity_ref  VARCHAR2
    , p_last_forecast_id  NUMBER
    , p_base_quantity_start_date  date
    , p_base_quantity_end_date  date
    , p_offer_code  VARCHAR2
    , p19_a0 out nocopy  NUMBER
    , p19_a1 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddp_base_quantity_start_date date;
    ddp_base_quantity_end_date date;
    ddx_fcst_return_rec ozf_forecast_util_pvt.fcst_return_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    ddp_base_quantity_start_date := rosetta_g_miss_date_in_map(p_base_quantity_start_date);

    ddp_base_quantity_end_date := rosetta_g_miss_date_in_map(p_base_quantity_end_date);






    -- here's the delegated call to the old PL/SQL routine
    ozf_forecast_util_pvt.create_base_sales(p_api_version,
      p_init_msg_list,
      p_commit,
      p_obj_type,
      p_obj_id,
      p_forecast_id,
      p_activity_metric_id,
      p_level,
      p_dimention,
      p_fcst_uom,
      ddp_start_date,
      ddp_end_date,
      p_period_level,
      p_base_quantity_type,
      p_base_quantity_ref,
      p_last_forecast_id,
      ddp_base_quantity_start_date,
      ddp_base_quantity_end_date,
      p_offer_code,
      ddx_fcst_return_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















    p19_a0 := ddx_fcst_return_rec.forecast_id;
    p19_a1 := ddx_fcst_return_rec.spread_count;



  end;

end ozf_forecast_util_pvt_w;

/
