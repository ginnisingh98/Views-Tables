--------------------------------------------------------
--  DDL for Package OZF_FORECAST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FORECAST_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfous.pls 120.0 2005/11/04 18:48:05 mkothari noship $*/

TYPE fcst_return_rec_type
IS RECORD (  forecast_id    NUMBER,
             spread_count   NUMBER
);

FUNCTION get_product_list_price(p_activity_metric_fact_id IN  NUMBER) RETURN NUMBER;

FUNCTION get_product_cost(p_activity_metric_fact_id IN  NUMBER) RETURN NUMBER;

FUNCTION get_best_fit_lift (
  p_obj_type                  IN VARCHAR2,
  p_obj_id                    IN NUMBER,
  p_forecast_id               IN NUMBER,
  p_base_quantity_ref         IN VARCHAR2,
  p_market_type               IN VARCHAR2,
  p_market_id                 IN NUMBER,
  p_product_attribute_context IN VARCHAR2,
  p_product_attribute         IN VARCHAR2,
  p_product_attr_value        IN VARCHAR2,
  p_product_id                IN NUMBER,
  p_tpr_percent               IN NUMBER,
  p_report_date               IN DATE
)
RETURN NUMBER;

PROCEDURE adjust_baseline_spreads
(
  p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2  := FND_API.g_false,
  p_commit                    IN VARCHAR2  := FND_API.g_false,
  p_obj_type                  IN VARCHAR2,
  p_obj_id                    IN NUMBER,
  p_forecast_id               IN NUMBER,
  p_activity_metric_fact_id   IN NUMBER,
  p_new_tpr_percent           IN NUMBER,
  p_new_incremental_sales     OUT NOCOPY NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE create_forecast(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_fcst_uom         IN VARCHAR2,
  p_start_date       IN DATE,
  p_end_date         IN DATE,
  p_base_quantity_type IN VARCHAR2,
  p_base_quantity_ref IN VARCHAR2,
  p_last_scenario_id IN NUMBER,
  p_offer_code       IN VARCHAR2,

  x_forecast_id      IN OUT NOCOPY NUMBER,
  x_activity_metric_id OUT NOCOPY NUMBER, -- 11510
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);


PROCEDURE create_wkst_forecasts(
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
   p_commit           IN  VARCHAR2  := FND_API.g_false,

   p_worksheet_header_id   IN NUMBER,

   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2 ) ;

PROCEDURE create_base_sales(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,
  p_activity_metric_id IN NUMBER,
  p_level            IN VARCHAR2,
  p_dimention        IN VARCHAR2,
  p_fcst_uom         IN VARCHAR2,
  p_start_date       IN DATE,
  p_end_date         IN DATE,
  p_period_level     IN VARCHAR2,
  --R12
  p_base_quantity_type IN VARCHAR2,
  p_base_quantity_ref  IN VARCHAR2,
  p_last_forecast_id   IN NUMBER,
  p_base_quantity_start_date IN DATE,
  p_base_quantity_end_date   IN DATE,
  p_offer_code       IN VARCHAR2,

  x_fcst_return_rec  OUT NOCOPY fcst_return_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE fcst_remqty(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_forecast_id      IN  NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);


PROCEDURE freeze_check(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_forecast_id IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
  );

PROCEDURE copy_forecast(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
  p_commit             IN  VARCHAR2  := FND_API.g_false,
  p_forecast_id        IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
  );


PROCEDURE cascade_update(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_id               IN   NUMBER,
  p_value            IN   NUMBER,
  p_fwd_buy_value    IN   NUMBER,
  p_fcast_id         IN   NUMBER,
  p_cascade_flag     IN   NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
  );

PROCEDURE cascade_first_level(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
  p_commit             IN  VARCHAR2  := FND_API.g_false,

  p_fcast_value        IN   NUMBER,
  p_fwd_buy_value      IN   NUMBER,
  p_fcast_id           IN   NUMBER,
  p_cascade_flag       IN   NUMBER,

  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
  );

procedure calc_perc(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_used_by_id IN NUMBER,
  p_level_num IN NUMBER,
  p_spread_type IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
  );

procedure allocate_facts(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_used_by_id IN NUMBER,
  p_dimention IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
  );



PROCEDURE get_discount_info(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN VARCHAR2,
                    p_obj_id               IN NUMBER,
                    p_forecast_id          IN NUMBER,
                    p_currency_code        IN VARCHAR2,
                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,
                    p_node_id              IN NUMBER,

                    x_list_price           OUT NOCOPY NUMBER,
                    x_discount_type        OUT NOCOPY VARCHAR2,
                    x_discount_value       OUT NOCOPY NUMBER,
                    x_standard_cost        OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 );


PROCEDURE get_actual_sales(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN VARCHAR2,
                    p_obj_id               IN NUMBER,
                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,
                    p_fcst_uom             IN VARCHAR2,
                    p_cogs                 IN NUMBER,

                    x_actual_units         OUT NOCOPY NUMBER,
                    x_actual_revenue       OUT NOCOPY NUMBER,
                    x_actual_costs         OUT NOCOPY NUMBER,
                    x_roi                  OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 );



 PROCEDURE get_volume_offer_discount(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN  VARCHAR2,
                    p_obj_id               IN  NUMBER,
                    p_forecast_id          IN  NUMBER,
                    p_currency_code        IN  VARCHAR2,

                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,

                    x_discount_type_code   OUT NOCOPY VARCHAR2,
                    x_discount             OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 );




PROCEDURE get_list_price(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN  VARCHAR2,
                    p_obj_id               IN  NUMBER,
                    p_forecast_id          IN  NUMBER,
		    p_product_attribute    IN  VARCHAR2,
                    p_product_attr_value   IN  VARCHAR2,
                    p_fcst_uom             IN  VARCHAR2,
                    p_currency_code        IN  VARCHAR2,
                    p_price_list_id        IN  NUMBER,

                    x_list_price           OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2
                   );



PROCEDURE allocate_pg_facts(
                      p_api_version        IN  NUMBER,
                      p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                      p_commit             IN  VARCHAR2  := FND_API.g_false,

                      p_used_by_id IN NUMBER,
                      p_dimention  IN VARCHAR2,
                      p_currency_code IN VARCHAR2,

                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2
                   ) ;

PROCEDURE get_other_costs (p_obj_type           IN VARCHAR2,
                           p_obj_id             IN VARCHAR2,
                           p_product_attribute  IN VARCHAR2,
                           p_product_attr_value IN VARCHAR2,
                           p_uom                IN VARCHAR2,
                           p_other_costs        OUT NOCOPY VARCHAR2) ;

 PROCEDURE cascade_baseline_update(
                    p_api_version       IN  NUMBER,
                    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
                    p_commit            IN  VARCHAR2  := FND_API.g_false,
                    p_id                IN  NUMBER,
                    p_value             IN  NUMBER,
                    p_fcast_id          IN  NUMBER,
                    p_rem_value         IN  NUMBER,
                    p_cascade_flag      IN  NUMBER,
                    p_tpr_percent       IN  NUMBER,
                    p_obj_type          IN  VARCHAR2,
                    p_obj_id            IN  NUMBER,
                    x_return_status     OUT NOCOPY VARCHAR2,
                    x_msg_count         OUT NOCOPY NUMBER,
                    x_msg_data          OUT NOCOPY VARCHAR2
 );

 PROCEDURE cascade_baseline_levels(
                    p_api_version       IN NUMBER,
                    p_init_msg_list     IN VARCHAR2  := FND_API.g_false,
                    p_commit            IN VARCHAR2  := FND_API.g_false,
                    p_fcast_value       IN NUMBER,
                    p_fcast_id          IN NUMBER,
                    p_cascade_flag      IN NUMBER,
                    p_obj_type          IN VARCHAR2,
                    p_obj_id            IN NUMBER,
                    x_return_status     OUT NOCOPY VARCHAR2,
                    x_msg_count         OUT NOCOPY NUMBER,
                    x_msg_data          OUT NOCOPY VARCHAR2
 );

 PROCEDURE fcst_BL_remqty(
                    p_api_version        IN  NUMBER,
                    p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                    p_commit             IN  VARCHAR2  := FND_API.g_false,

                    p_forecast_id        IN  NUMBER,

                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2
 );

END;

 

/
