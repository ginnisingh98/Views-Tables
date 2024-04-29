--------------------------------------------------------
--  DDL for Package OZF_FORECAST_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FORECAST_UTIL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwfous.pls 120.0 2005/11/04 18:50 mkothari noship $ */
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
  ) return number;
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
  );
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
  );
end ozf_forecast_util_pvt_w;

 

/
