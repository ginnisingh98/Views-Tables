--------------------------------------------------------
--  DDL for Package FTE_FREIGHT_PRICING_SPECIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FREIGHT_PRICING_SPECIAL" AUTHID CURRENT_USER as
/* $Header: FTEFRPSS.pls 120.1 2005/07/15 12:13:52 mechawla noship $ */

-- Global Variables

  g_package_name               CONSTANT        VARCHAR2(100) := 'FTE_FREIGHT_PRICING_SPECIAL';

 -- parameters rec
 TYPE lane_parameter_rec_type IS RECORD (
      parameter_instance_id  fte_prc_parameters.parameter_instance_id%TYPE,
      lane_id                fte_prc_parameters.parameter_instance_id%TYPE,
      lane_function          fte_prc_parameter_defaults.lane_function%TYPE,
      parameter_sub_type     fte_prc_parameter_defaults.parameter_sub_type%TYPE,
      parameter_name         fte_prc_parameter_defaults.parameter_name%TYPE,
      value_from             fte_prc_parameters.value_from%TYPE,
      value_to               fte_prc_parameters.value_to%TYPE,
      uom_class              fte_prc_parameters.uom_class%TYPE,           ---  do we need this?
      uom_code               fte_prc_parameters.uom_code%TYPE,
      currency_code          fte_prc_parameters.currency_code%TYPE
);

   -- use this table to cache parameters for a lane
 TYPE lane_parameter_tab_type IS TABLE OF lane_parameter_rec_type INDEX BY BINARY_INTEGER;
 g_lane_parameters  lane_parameter_tab_type;


TYPE special_process_flags_rec_type IS RECORD (
    lane_id                    NUMBER,
	lane_function              VARCHAR2(30),  -- can we make this a number?
	dim_wt_flag    		       VARCHAR2(1),
	minimum_charge_flag        VARCHAR2(1),
	parcel_hundredwt_flag      VARCHAR2(1),
	flat_containerwt_flag      VARCHAR2(1),
	deficit_wt_flag            VARCHAR2(1));

TYPE lane_rule_rec_type IS RECORD
       ( lane_function                  VARCHAR2(40),
         pattern_name                   VARCHAR2(40),
         grouping_level                 VARCHAR2(40),
         commodity_aggregation          VARCHAR2(40),
         pricing_objective              VARCHAR2(40));

TYPE lane_rule_tab_type IS TABLE OF lane_rule_rec_type  INDEX BY BINARY_INTEGER;

g_special_flags     special_process_flags_rec_type;
g_lane_rules_tab    lane_rule_tab_type;

-- Addded for 12i To Support dimensional weights at Carrier/CVarrier Service level
-- if not defined at Lane level
TYPE carrier_dim_weight_rec_type IS RECORD
       ( dim_factor                  NUMBER,
         dim_weight_uom              mtl_system_items.dimension_uom_code%type,
         dim_volume_uom              VARCHAR2(30),
         dim_dimension_uom              VARCHAR2(30),
         dim_min_volume              VARCHAR2(30)
        );


PROCEDURE initialize(p_lane_id         IN NUMBER,
                     x_lane_function   OUT NOCOPY  VARCHAR2,
                     x_return_status   OUT NOCOPY  VARCHAR2);


PROCEDURE apply_dimensional_weight (
          p_lane_id              IN NUMBER,
          p_carrier_id           IN NUMBER,
          p_service_code         IN VARCHAR2,
          p_top_level_rec        IN OUT NOCOPY   fte_freight_pricing.shpmnt_content_rec_type,
          p_rolledup_rows        IN OUT NOCOPY   fte_freight_pricing.rolledup_line_tab_type,
          x_return_status        OUT NOCOPY              VARCHAR2 );

FUNCTION isLTL RETURN VARCHAR2;

FUNCTION isParcel RETURN VARCHAR2;

PROCEDURE apply_min_charge (p_event_num        IN  NUMBER,
                            p_set_num          IN  NUMBER DEFAULT 1,
                            p_comp_with_price  IN  NUMBER DEFAULT NULL,
                            x_charge_applied   OUT NOCOPY  VARCHAR2,  -- Y/N
                            x_return_status    OUT NOCOPY  VARCHAR2);

PROCEDURE process_LTL (
        p_pricing_control_rec     IN               fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN               fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY    fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN               fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN               fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY    fte_freight_pricing.pricing_attribute_tab_type,
        --p_pricing_qualifier       IN               fte_qual_rec_type,
        --x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        --x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY               VARCHAR2 );

        -- This is called for Parcel
PROCEDURE process_Parcel (
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        --p_pricing_qualifier       IN                fte_qual_rec_type,
        --x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        --x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 );


PROCEDURE process_others (
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        --p_pricing_qualifier       IN                fte_qual_rec_type,
        --x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        --x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 );

-- Is called by the main code after searching for patterns and creating standard engine rows and attributes
-- Checks process flags.
-- Depending upon the mix of conditions it calls other internal procedures to process the input lines.
-- If no special conditions apply, control is returned to the main code line.

PROCEDURE process_special_conditions(
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        x_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        x_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        --x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        --x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 );

-- J+ enhancement for container_all rate basis
-- this procedure is called by shipment_pricing to rate container_all basis
PROCEDURE rate_container_all(
        p_lane_info		     	IN fte_freight_pricing.lane_info_rec_type,
        p_top_level_rows          	IN fte_freight_pricing.shpmnt_content_tab_type,
        p_save_flag               	IN VARCHAR2,
        p_currency_code			IN VARCHAR2 ,
        x_freight_cost_main_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom  	OUT NOCOPY VARCHAR2,
        x_return_status           	OUT NOCOPY VARCHAR2 );

-- J+ enhancement for LTL rating to include container weight
-- this procedure is called by process_shipment_patterns to distribute LTL container weight to
-- pricing_engine_rows and g_rolledup_lines
PROCEDURE distribute_LTL_container_wt(
        p_top_level_rows        IN fte_freight_pricing.shpmnt_content_tab_type,
        x_pricing_engine_rows	IN OUT NOCOPY fte_freight_pricing.pricing_engine_input_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2 ) ;

-- J+ enhancement for shipment flat rating
-- this procedure is called by shipment_pricing to handle shipment flat rating
PROCEDURE process_shipment_flatrate(
        p_lane_info		     	IN fte_freight_pricing.lane_info_rec_type,
        p_top_level_rows          	IN fte_freight_pricing.shpmnt_content_tab_type,
        p_save_flag               	IN VARCHAR2,
        p_currency_code             IN VARCHAR2,
        x_freight_cost_main_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom  	OUT NOCOPY VARCHAR2,
        x_return_status           	OUT NOCOPY VARCHAR2 );

-- 12i Enhancement for loading Dimensional weight parameters at Carrier/Carrier Service
-- level.. called by apply_dimensional_weight
PROCEDURE load_carrier_dim_weight_params(
        p_lane_id                        IN NUMBER,
        p_carrier_id                     IN NUMBER,
        p_service_code                   IN VARCHAR2,
        x_carrier_dim_weight_rec         OUT NOCOPY carrier_dim_weight_rec_type,
        x_return_status                  OUT NOCOPY VARCHAR2 );

--- debugging utils ---
-- exceptions
G_NO_PARAMS_FOUND        EXCEPTION;   -- if parameter table is empty or required param is not available
G_INVALID_PARAM_VAL      EXCEPTION;   -- parameter has an invalid value


END FTE_FREIGHT_PRICING_SPECIAL;

 

/
