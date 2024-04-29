--------------------------------------------------------
--  DDL for Package FTE_FREIGHT_PRICING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FREIGHT_PRICING" AUTHID CURRENT_USER as
/* $Header: FTEFRPRS.pls 120.2 2005/11/16 14:38:37 mechawla noship $ */

-- Global Variables

g_package_name               CONSTANT        VARCHAR2(50) := 'FTE_FREIGHT_PRICING';

g_hash_base NUMBER := 1;
g_hash_size NUMBER := power(2, 25);

G_CONTAINER_BASIS    NUMBER := 1;
G_VOLUME_BASIS       NUMBER := 2;
G_WEIGHT_BASIS       NUMBER := 3;

G_OBJECTIVE_HIGHEST  VARCHAR2(30) := 'HIGHEST';
G_OBJECTIVE_LOWEST   VARCHAR2(30) := 'LOWEST';

G_GROUPING_SHIPMENT  VARCHAR2(30) := 'SHIPMENT';
G_GROUPING_CONTAINER VARCHAR2(30) := 'CONTAINER';

G_AGGREGATION_WITHIN VARCHAR2(30) := 'WITHIN';
G_AGGREGATION_ACROSS VARCHAR2(30) := 'ACROSS';

G_PATTERN_1          NUMBER := 1;
G_PATTERN_1_NAME     VARCHAR2(30) := 'SC_CB';
G_PATTERN_2          NUMBER := 2;
G_PATTERN_2_NAME     VARCHAR2(30) := 'SC_WB';
G_PATTERN_3          NUMBER := 3;
G_PATTERN_3_NAME     VARCHAR2(30) := 'SC_VB';
G_PATTERN_4          NUMBER := 4;
G_PATTERN_4_NAME     VARCHAR2(30) := 'MC_CB';
G_PATTERN_5          NUMBER := 5;
G_PATTERN_5_NAME     VARCHAR2(30) := 'MC_WB';
G_PATTERN_6          NUMBER := 6;
G_PATTERN_6_NAME     VARCHAR2(30) := 'MC_VB';
G_PATTERN_7          NUMBER := 7;
G_PATTERN_7_NAME     VARCHAR2(30) := 'MC_MY';
G_PATTERN_8          NUMBER := 8;
G_PATTERN_8_NAME     VARCHAR2(30) := 'MC_MN';
G_PATTERN_9          NUMBER := 9;
G_PATTERN_9_NAME     VARCHAR2(30) := 'LI_WB';
G_PATTERN_10         NUMBER := 10;
G_PATTERN_10_NAME    VARCHAR2(30) := 'LI_VB';

-- pricing events
G_LINE_EVENT_NUM    NUMBER := 1;
G_CHARGE_EVENT_NUM  NUMBER := 2;
G_LINE_EVENT_CODE    VARCHAR2(30) := 'LINE';
G_CHARGE_EVENT_CODE  VARCHAR2(30) := 'PRICE_LOAD';  -- should have a proper value (say FTE_CHARGE_EVENT)

  TYPE shipment_line_rec_type IS RECORD
        (delivery_detail_id                     NUMBER,
         delivery_id                            NUMBER,
         delivery_leg_id                        NUMBER,
         reprice_required                       VARCHAR2(1),
         parent_delivery_detail_id              NUMBER,
         customer_id                            NUMBER,
        sold_to_contact_id                      NUMBER,
        inventory_item_id                       NUMBER,
        item_description                        VARCHAR2(250),
        hazard_class_id                         NUMBER,
        country_of_origin                       VARCHAR2(50),
        classification                          VARCHAR2(30),
        requested_quantity                      NUMBER,
        requested_quantity_uom                  VARCHAR2(3),
        master_container_item_id                NUMBER,
        detail_container_item_id                NUMBER,
        customer_item_id                        NUMBER,
        net_weight                              NUMBER,
        organization_id                         NUMBER,
        container_flag                          VARCHAR2(1),
        container_type_code                     VARCHAR2(30),
        container_name                          VARCHAR2(30),
        fill_percent                            NUMBER,
        gross_weight                            NUMBER,
         currency_code                          VARCHAR2(15),
        freight_class_cat_id                    NUMBER,
        commodity_code_cat_id                   NUMBER,
        weight_uom_code                         VARCHAR2(3),
        volume                                  NUMBER,
        volume_uom_code                         VARCHAR2(3),
        tp_attribute_category                   VARCHAR2(240),
        tp_attribute1                           VARCHAR2(240),
        tp_attribute2                           VARCHAR2(240),
        tp_attribute3                           VARCHAR2(240),
        tp_attribute4                           VARCHAR2(240),
        tp_attribute5                           VARCHAR2(240),
        tp_attribute6                           VARCHAR2(240),
        tp_attribute7                           VARCHAR2(240),
        tp_attribute8                           VARCHAR2(240),
        tp_attribute9                           VARCHAR2(240),
        tp_attribute10                          VARCHAR2(240),
        tp_attribute11                          VARCHAR2(240),
        tp_attribute12                          VARCHAR2(240),
        tp_attribute13                          VARCHAR2(240),
        tp_attribute14                          VARCHAR2(240),
        tp_attribute15                          VARCHAR2(240),
        attribute_category                      VARCHAR2(150),
        attribute1                              VARCHAR2(150),
        attribute2                              VARCHAR2(150),
        attribute3                              VARCHAR2(150),
        attribute4                              VARCHAR2(150),
        attribute5                              VARCHAR2(150),
        attribute6                              VARCHAR2(150),
        attribute7                              VARCHAR2(150),
        attribute8                              VARCHAR2(150),
        attribute9                              VARCHAR2(150),
        attribute10                             VARCHAR2(150),
        attribute11                             VARCHAR2(150),
        attribute12                             VARCHAR2(150),
        attribute13                             VARCHAR2(150),
        attribute14                             VARCHAR2(150),
        attribute15                             VARCHAR2(150),
        source_type                             VARCHAR2(10),  --new for om estimation
        source_line_id                          NUMBER,        --new for om estimation
        source_header_id                        NUMBER,        --new for om estimation
        source_consolidation_id                 NUMBER,        --new for om estimation
        ship_date                               DATE,          --new for om estimation
        arrival_date                            DATE,         --new for om estimation
        comm_category_id                        NUMBER,        -- new for FTE J FTE Estimation
	assignment_type				VARCHAR2(1) ,-- MDC TL
	parent_delivery_id			NUMBER,--MDC TL
	parent_delivery_leg_id			NUMBER--MDC TL
       );

  TYPE shipment_line_tab_type IS TABLE OF shipment_line_rec_type INDEX BY BINARY_INTEGER;

-- This is a global table which can be populated with delivery detail records from either
-- of the APIs shipment_price_compare or shipment_price_consolidate or shipment_price_calculate
-- This table should be indexed on delivery_detail_id for better performance

  g_shipment_line_rows         shipment_line_tab_type;

  TYPE Freight_Cost_Temp_Rec_Type IS RECORD (
       FREIGHT_COST_ID                               NUMBER
     , FREIGHT_COST_TYPE_ID                          NUMBER
     , UNIT_AMOUNT                                   NUMBER
     , CALCULATION_METHOD                            VARCHAR2(15)
     , UOM                                           VARCHAR2(15)
     , QUANTITY                                      NUMBER
     , TOTAL_AMOUNT                                  NUMBER
     , CURRENCY_CODE                                 VARCHAR2(15)
     , CONVERSION_DATE                               DATE
     , CONVERSION_RATE                               NUMBER
     , CONVERSION_TYPE_CODE                          VARCHAR2(30)
     , TRIP_ID                                       NUMBER
     , STOP_ID                                       NUMBER
     , DELIVERY_ID                                   NUMBER
     , DELIVERY_LEG_ID                               NUMBER
     , DELIVERY_DETAIL_ID                            NUMBER
     , ATTRIBUTE_CATEGORY                            VARCHAR2(150)
     , ATTRIBUTE1                                    VARCHAR2(150)
     , ATTRIBUTE2                                    VARCHAR2(150)
     , ATTRIBUTE3                                    VARCHAR2(150)
     , ATTRIBUTE4                                    VARCHAR2(150)
     , ATTRIBUTE5                                    VARCHAR2(150)
     , ATTRIBUTE6                                    VARCHAR2(150)
     , ATTRIBUTE7                                    VARCHAR2(150)
     , ATTRIBUTE8                                    VARCHAR2(150)
     , ATTRIBUTE9                                    VARCHAR2(150)
     , ATTRIBUTE10                                   VARCHAR2(150)
     , ATTRIBUTE11                                   VARCHAR2(150)
     , ATTRIBUTE12                                   VARCHAR2(150)
     , ATTRIBUTE13                                   VARCHAR2(150)
     , ATTRIBUTE14                                   VARCHAR2(150)
     , ATTRIBUTE15                                   VARCHAR2(150)
     , CREATION_DATE                                 DATE
     , CREATED_BY                                    NUMBER
     , LAST_UPDATE_DATE                              DATE
     , LAST_UPDATED_BY                               NUMBER
     , LAST_UPDATE_LOGIN                             NUMBER
     , PROGRAM_APPLICATION_ID                        NUMBER
     , PROGRAM_ID                                    NUMBER
     , PROGRAM_UPDATE_DATE                           DATE
     , REQUEST_ID                                    NUMBER
     , LINE_TYPE_CODE                                VARCHAR2(30)
     , PRICING_LIST_HEADER_ID                        NUMBER
     , PRICING_LIST_LINE_ID                          NUMBER
     , APPLIED_TO_CHARGE_ID                          NUMBER
     , CHARGE_UNIT_VALUE                             NUMBER
     , CHARGE_SOURCE_CODE                            VARCHAR2(30)
     , ESTIMATED_FLAG                                VARCHAR2(1)
     , COMPARISON_REQUEST_ID                         NUMBER
     , LANE_ID                                       NUMBER
     , SCHEDULE_ID                                   NUMBER
     , MOVED_TO_MAIN_FLAG                            VARCHAR2(1)
     , SERVICE_TYPE_CODE                             VARCHAR2(30)
     , COMMODITY_CATEGORY_ID                         NUMBER
     , BILLABLE_BASIS 				     VARCHAR2 (30)
     , BILLABLE_UOM                                  VARCHAR2 (15)
     , BILLABLE_QUANTITY                             NUMBER
     , VEHICLE_TYPE_ID				     NUMBER
);

  TYPE Freight_Cost_Temp_Tab_Type IS TABLE OF Freight_Cost_Temp_Rec_Type INDEX BY BINARY_INTEGER;

   TYPE top_level_fc_rec_type IS RECORD
                (delivery_detail_id                         NUMBER ,
                 delivery_leg_id                            NUMBER ,
                 line_type_code                             VARCHAR2(30),
                 freight_cost_type_id                       NUMBER ,
                 applied_to_charge_id                       NUMBER DEFAULT NULL, -- populated only for charges
                 currency_code                              VARCHAR2(30) ,
                 quantity                                   NUMBER ,
                 uom                                        VARCHAR2(30),
                 charge_unit_value                          NUMBER,
                 unit_amount                                NUMBER DEFAULT NULL,
                 total_amount                               NUMBER
                 );

   TYPE top_level_fc_tab_type IS TABLE OF top_level_fc_rec_type INDEX BY BINARY_INTEGER;

  TYPE rolledup_line_rec_type IS RECORD
        (delivery_detail_id                     NUMBER,
         item_id                                NUMBER,
         category_id                            NUMBER,
         rate_basis                             NUMBER,
         container_id                           NUMBER,
         master_container_id                    NUMBER,
         line_quantity                          NUMBER,
         line_uom                               VARCHAR2(30));

  TYPE rolledup_line_tab_type IS TABLE OF rolledup_line_rec_type INDEX BY BINARY_INTEGER;

  g_rolledup_lines         rolledup_line_tab_type;

   TYPE shpmnt_content_rec_type IS RECORD
                (content_id                                     NUMBER ,  -- Container/loose item id (DDetail id)
                 delivery_leg_id                                NUMBER,
                 container_flag                                 VARCHAR2(1),
                 weight_uom                                     VARCHAR2(30),
                 volume_uom                                     VARCHAR2(30),
                 dim_uom                                        mtl_system_items.dimension_uom_code%type,
                 gross_weight                                   NUMBER,
                 volume                                         NUMBER,
                 length                                         NUMBER,
                 width                                          NUMBER,
                 height                                         NUMBER,
		 -- added for J+ Container_all
		 container_type_code				VARCHAR2(30),

		 -- added for J+ Flat shipment rate
		 -- added for J+ LTL rating to include container weight
		 wdd_volume					NUMBER,
		 wdd_volume_uom_code				VARCHAR2(3),
		 wdd_net_weight					NUMBER,
		 wdd_gross_weight				NUMBER,
		 wdd_tare_weight				NUMBER,
		 wdd_weight_uom_code				VARCHAR2(3)
                 );

   TYPE shpmnt_content_tab_type IS TABLE OF shpmnt_content_rec_type INDEX BY BINARY_INTEGER;

   TYPE addl_services_rec_type IS RECORD
                (service_line_index                             NUMBER ,
                 content_id                                     NUMBER ,
                 freight_cost_type_code                         VARCHAR2(200),
                 freight_cost_type_id                           NUMBER
                 );

  TYPE addl_services_tab_type IS TABLE OF addl_services_rec_type INDEX BY BINARY_INTEGER;

   -- How do we store the shpmnt_content_rec_type - instance/QP line? relationship as it is many-to-many ?

   TYPE top_level_pattern_rec_type IS RECORD
                (pattern_index                                  NUMBER ,  --  Do we need this ?
                 pattern_no                                     NUMBER,  -- Assign NUMBERs to 8 possible patterns
                 services_hash                                  VARCHAR2(100),
                 content_id                                     NUMBER ,  -- Container/loose item id (DDetail id)
                 instance_index                                 NUMBER
                 );

   TYPE top_level_pattern_tab_type IS TABLE OF top_level_pattern_rec_type INDEX BY BINARY_INTEGER;

   TYPE pricing_dual_instance_rec_type IS RECORD
                (instance_index                                 NUMBER ,
                 pattern_no                                     NUMBER,  -- Assign NUMBERs to 9 possible patterns
                                                                -- Consolidation possible only for same patterns
                 services_hash                                  VARCHAR2(100),
                 grouping_level                                 VARCHAR2(60) ,
                 aggregation                                    VARCHAR2(60) DEFAULT NULL,
                 objective                                      VARCHAR2(60) DEFAULT NULL,
                 count_pattern                                  NUMBER ,
                 loose_item_flag                                VARCHAR2(1)     DEFAULT 'N' --new for loose item
                 );

   TYPE pricing_dual_instance_tab_type IS TABLE OF pricing_dual_instance_rec_type INDEX BY BINARY_INTEGER;

   TYPE pricing_engine_input_rec_type IS RECORD
                (input_index                                    NUMBER , -- Same as QP engine line_index ?
                 instance_index                                 NUMBER ,  -- Origin pricing dual instance. Can be more than one input rec only in case of pricing objective consideration/percel hundredwt.
                 category_id                                    NUMBER DEFAULT NULL, -- Populated for WITHIN
                 basis                                          NUMBER DEFAULT NULL, -- Populated for ACROSS
                 loose_item_id                                  NUMBER DEFAULT NULL, -- Populated for Loose Item
                 line_quantity                                  NUMBER ,
                 line_uom                                       VARCHAR2(60),
                 input_set_number                               NUMBER DEFAULT 1,  -- indentifies an input set (for stuff like parcel hundred wt),

		 -- added for J+ Container_all
		 container_type_code				VARCHAR2(30),
                 loose_item_flag                                VARCHAR2(1) DEFAULT 'N'
                 );

   TYPE pricing_engine_input_tab_type IS TABLE OF pricing_engine_input_rec_type INDEX BY BINARY_INTEGER;

   TYPE pricing_control_input_rec_type IS RECORD (
        pricing_event_num         NUMBER,
        currency_code             VARCHAR2(30),
        lane_id                   NUMBER,
        price_list_id             NUMBER,
        party_id                  NUMBER
   );


   TYPE pricing_engine_def_rec_type    IS RECORD (
        pricing_event_num         NUMBER,   --index
        pricing_event_code        VARCHAR2(30),
        request_type_code         VARCHAR2(30),
        line_type_code            VARCHAR2(30),
        price_flag                VARCHAR2(1)
   );

   TYPE pricing_engine_def_tab_type IS TABLE OF pricing_engine_def_rec_type INDEX BY BINARY_INTEGER;

   TYPE fte_qual_rec_type IS RECORD
                (supplier_id                                    NUMBER ,
                 pricelist_id                                   NUMBER
                 );

   TYPE pricing_attribute_rec_type IS RECORD
                (attribute_index                                NUMBER ,
                 input_index                                    NUMBER , -- Origin QP engine input line index
                 attribute_name                                 VARCHAR2(60) ,
                 attribute_value                                VARCHAR2(240)
                 );

   TYPE pricing_attribute_tab_type IS TABLE OF pricing_attribute_rec_type INDEX BY BINARY_INTEGER;

  TYPE Freight_Cost_Main_Tab_Type IS TABLE OF WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type INDEX BY BINARY_INTEGER;

  TYPE FtePricingInRecType is RECORD (
                api_version_number       NUMBER,
                delivery_leg_id          NUMBER DEFAULT NULL,   -- Input only one of these two
                segment_id               NUMBER DEFAULT NULL    -- WSH Trip id
                );

  TYPE effectivity_date_rec IS RECORD (
               date_from                DATE,
               date_to                  DATE );

  g_effectivity_dates  effectivity_date_rec;

   TYPE lane_info_rec_type IS RECORD  --  Make these columns as %TYPE
                (lane_id                                        NUMBER ,
                 carrier_id                                     NUMBER ,
                 pricelist_id                                   NUMBER ,
                 mode_of_transportation_code                    VARCHAR2(30) ,
                 origin_id                                      NUMBER ,
                 destination_id                                 NUMBER ,
                 basis                                          VARCHAR2(30) ,
                 commodity_catg_id                              NUMBER ,
                 service_type_code                              VARCHAR2(30),
                 classification_code                            VARCHAR2(10)    --  To be added to fte_lanes
                 );

    TYPE delivery_leg_rec_type IS RECORD
                ( delivery_id            NUMBER,
                  delivery_leg_id        NUMBER,
                  delivery_name          VARCHAR(4000)
                 );

    TYPE delivery_trip_rec_type IS RECORD
                ( delivery_id            NUMBER,
                  trip_id                NUMBER,
                  delivery_leg_id        NUMBER,
                  delivery_name          VARCHAR(4000)
                 );


   TYPE DELIVERY_LEG_TAB_TYPE IS TABLE OF delivery_leg_rec_type INDEX BY BINARY_INTEGER;

   TYPE DELIVERY_TRIP_TAB_TYPE IS TABLE OF delivery_trip_rec_type INDEX BY BINARY_INTEGER;

-- Utility APIs

FUNCTION is_consolidated (
        p_segment_id              IN     NUMBER ) RETURN BOOLEAN;

FUNCTION get_segment_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER;

FUNCTION get_delivery_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER;

PROCEDURE flatten_shipment (
        p_delivery_leg_id         IN     NUMBER DEFAULT NULL,    --  Not required
        x_first_level_rows        OUT NOCOPY     shpmnt_content_tab_type, -- Will get indexed on delivery_detail_id
        x_return_status           OUT NOCOPY     VARCHAR2 ) ;


PROCEDURE shipment_pricing (
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_segment_id              IN     NUMBER DEFAULT NULL,-- Input either Lane/schedule or the trip segment
        p_service_type            IN     VARCHAR2 DEFAULT NULL, -- service type is required with lane/schedule
        p_ship_date               IN     DATE  DEFAULT sysdate, -- VVP (09/30/02)
        p_arrival_date            IN     DATE  DEFAULT sysdate, -- VVP (09/30/02)
        --p_shpmnt_toplevel_rows    IN OUT NOCOPY  shpmnt_content_tab_type,
        p_shpmnt_toplevel_rows    IN     shpmnt_content_tab_type, /* bug# 2501240 -VVP */
        p_shpmnt_toplevel_charges IN     addl_services_tab_type, -- Top level requested additional services
--      p_shpmnt_charges          IN     shpmnt_charges_tab_type,  --  Not supported in Phase I
        p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or MAIN table
        p_request_id              IN     NUMBER DEFAULT NULL, -- Required only in case of saving to TEMP table
        p_currency_code           IN     VARCHAR2 DEFAULT NULL,
        x_summary_lanesched_price      OUT NOCOPY     NUMBER,   -- Only in case of 'T'
        x_summary_lanesched_price_uom  OUT NOCOPY     VARCHAR2,
        x_freight_cost_temp_price  OUT NOCOPY     Freight_Cost_Temp_Tab_Type,
        x_freight_cost_temp_charge OUT NOCOPY     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2 ) ;

-- shipment_rating will be called by
--	WSH-LCSS (FTE_FREIGHT_RATING_DLVY_GRP.Rate_Delivery)
--  and OM-LCSS (FTE_FREIGHT_RATING_PUB.Get_Freight_Costs)
--  and OM-DisplayChoices (FTE_FREIGHT_RATING_PUB.Get_Services)
--
-- shipment_rating rate shipments in g_shipment_line_rows on p_lane_id and p_service_type
-- if p_mode_of_transport = 'TRUCK' it calls tl_shipment_pricing
-- otherwise it calls shipment_pricing
-- shipment_rating always returns rates in pl/sql table
--
PROCEDURE shipment_rating (
        p_lane_id                 	IN     	   NUMBER,
        p_service_type            	IN         VARCHAR2,
	p_mode_of_transport		IN	   VARCHAR2,
        p_ship_date               	IN     	   DATE  DEFAULT sysdate,
        p_arrival_date            	IN     	   DATE  DEFAULT sysdate,
        p_currency_code                 IN         VARCHAR2 DEFAULT NULL,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom	OUT NOCOPY VARCHAR2,
        x_freight_cost_temp_price  	OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_return_status           	OUT NOCOPY VARCHAR2,
        x_msg_count               	OUT NOCOPY NUMBER,
        x_msg_data                	OUT NOCOPY VARCHAR2 );

--      FTE Public APIs to be called from Transportation events

--      This API will result in one qp output line per instance
--      It will delete other engine rows and associated engine output line details

PROCEDURE resolve_pricing_objective(
             p_pricing_dual_instances   IN  pricing_dual_instance_tab_type,
             x_pricing_engine_input     IN OUT NOCOPY  pricing_engine_input_tab_type,
             x_qp_output_line_rows      IN OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
             x_qp_output_line_details   IN OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,-- Not required
             x_return_status            OUT NOCOPY   VARCHAR2);

-- This API is called directly from DWB
-- Modified the signature for 12i. p_delivery_leg_list can contain list of Delivery Ids or Delivery Legs
-- Based on p_deliveries_list_type , it'll call different rating modules.
-- In R12 behavior of rerating will change as in case of a delivery/dleg , with more
-- delivery legs on the same trip we'll call rerating of the complete trip.
-- So in case of rerating Trip level rating will be called always instead of individual delivery leg

PROCEDURE rerate_shipment_online(
            p_api_version           IN  NUMBER DEFAULT 1.0,
            p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
            p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
            p_deliveries_list       IN  FTE_ID_TAB_TYPE,
            p_delivery_name_list    IN  FTE_NAME_TAB_TYPE,
            p_deliveries_list_type  IN VARCHAR2 ,  -- This will have 'DEL' for Delivery IDs or 'DLEG' for Delivery Leg Ids.
            x_success_list          OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_warning_list          OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_fail_list             OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_return_status         OUT NOCOPY  VARCHAR2,
            x_msg_count	            OUT NOCOPY  NUMBER,
            x_msg_data        OUT NOCOPY  VARCHAR2 );

--      This API is called directly from the shipment repricing concurrent program
--      The input to it should be
--      either a FTE trip, segment, delivery or a delivery leg

PROCEDURE shipment_reprice (
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_fte_trip_id         IN     NUMBER DEFAULT NULL, -- Input only ONE of the following FOUR
        p_segment_id          IN     NUMBER DEFAULT NULL,
        p_delivery_id         IN     NUMBER DEFAULT NULL,
        p_delivery_leg_id     IN     NUMBER DEFAULT NULL );

--      This API is called by the shipment repricing concurrent program
--      The input to it should be
--      either a FTE trip, segment, delivery or a delivery leg
--      Calls shipment_price_consolidate API

PROCEDURE shipment_reprice2 (
	p_init_prc_log	      IN     VARCHAR2 DEFAULT 'Y',
        p_fte_trip_id         IN     NUMBER DEFAULT NULL, -- Input only ONE of the following FOUR
        p_segment_id          IN     NUMBER DEFAULT NULL,
        p_delivery_id         IN     NUMBER DEFAULT NULL,
        p_delivery_leg_id     IN     NUMBER DEFAULT NULL,
        x_return_status       OUT NOCOPY     VARCHAR2 ) ;



--      This API is called by the shipment_reprice API or WSH online shipment repricing event
--      to consolidate shipments on a segment. The input to it should be
--      either a delivery leg or a segment
--      Calls shipment hierarchy flattening API

PROCEDURE shipment_price_consolidate (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,--Whether to initialize global message table
        p_in_attributes           IN     FtePricingInRecType,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_msg_count               OUT NOCOPY     NUMBER,      -- Standard FND functionality
        x_msg_data                OUT NOCOPY     VARCHAR2 );  -- Will return message text only if number of messages = 1

-- This API is mainly for internal FTE rating use
PROCEDURE shipment_price_consolidate (
        p_delivery_leg_id         IN     NUMBER DEFAULT NULL,    --  Gets either Dleg or wsh trip
        p_segment_id              IN     NUMBER DEFAULT NULL,
        p_check_reprice_flag      IN     VARCHAR2 DEFAULT 'N',
        x_return_status           OUT NOCOPY     VARCHAR2 );

--      This API is called from the Multi-leg UI for saving chosen shipment price
--      The input to it should be either the chosen lane or schedule,
--      delivery leg and the comparison request id
--      bug : 2763791 : added p_service_type_code

PROCEDURE Move_fc_temp_to_main (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	          IN     VARCHAR2 DEFAULT 'Y',
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        p_delivery_leg_id         IN     NUMBER,
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_service_type_code       IN     VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2);


--      This API is called from FTE_TRIP_RATING_GRP for saving chosen shipment price for a non-TL trip
--      The input to it should be either the chosen lane or schedule,
--      trip and the comparison request id


PROCEDURE Move_fc_temp_to_main (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	          IN     VARCHAR2 DEFAULT 'Y',
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        p_trip_id         	  IN     NUMBER,
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_service_type_code       IN     VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2);


-- 	This API is called by Rate_Delivery of LCSS project
-- 	To move freight costs from pl/sql table to wsh_freight_costs

PROCEDURE Move_fc_temp_to_main (
        p_delivery_leg_id          IN     NUMBER,
        p_freight_cost_temp_price  IN     Freight_Cost_Temp_Tab_Type,
        p_freight_cost_temp_charge IN     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2);

PROCEDURE Move_fc_temp_to_main (
        p_freight_cost_temp  IN     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2);

PROCEDURE delete_invalid_fc_recs (
     p_segment_id      IN  NUMBER DEFAULT NULL,
     p_delivery_leg_id IN  NUMBER DEFAULT NULL,
     x_return_status   OUT NOCOPY  VARCHAR2 );

PROCEDURE unmark_reprice_required (
     p_segment_id      IN  NUMBER DEFAULT NULL,
     p_delivery_leg_id IN  NUMBER DEFAULT NULL,
     x_return_status   OUT NOCOPY  VARCHAR2 );

--      This API is called from the Multi-leg UI when a price comparison request
--      for a delivery is not chosen to go forward with
--      The input to it should be the comparison request id

PROCEDURE delete_fc_temp (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
        p_request_id              IN     NUMBER,     -- Comparison Request ID to delete
        x_return_status           OUT NOCOPY     VARCHAR2);

PROCEDURE print_qp_output_lines (
        p_engine_output_line             IN    QP_PREQ_GRP.LINE_TBL_TYPE,
        p_engine_output_detail           IN    QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        p_return_status                  IN    VARCHAR2 ,
        x_return_status                  OUT NOCOPY    VARCHAR2 );

PROCEDURE print_fc_temp_rows (
        p_fc_temp_rows            IN    Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY    VARCHAR2 ) ;

PROCEDURE Create_Freight_Cost_Temp(
         p_freight_cost_temp_info IN     Freight_Cost_Temp_Rec_Type,
         x_freight_cost_temp_id   OUT NOCOPY     NUMBER,
         x_return_status          OUT NOCOPY     VARCHAR2);

--
-- API: SHIPMENT_PRICE_COMPARE_PVT
--      Internal api for price comparison for LTL and PARCEL
--      Can accept delivery or trip. Can generate its own comparison request id
--      or can be passed in.
--      Not to be called from outside rating
--      Does not initialize the log file
--      Introduced for pack J
--
--      Parameters :
--          p_delivery_id        -> Input either delivery_id or trip_id (not both)
--          p_trip_id            -> Input either delivery_id or trip_id (not both)
--          p_lane_id_tab        -> table of lane ids
--          p_schedule_id_tab    -> table of schedule ids
--          Note : p_lane_id_tab and p_schedule_id_tab can have overlapping indices
--                 For this API both tables are assumed to be independent of each
--                 other
--          p_dep_date           -> departure date
--          p_arr_date           -> arrival date
--          x_sum_lane_price_tab        ->
--          x_sum_lane_price_curr_tab   ->
--          x_sum_sched_price_tab       ->
--          x_sum_sched_price_curr_tab  ->
--          x_request_id              -> Can generate its own id if not passed in
--          x_return_status           -> return status
--

PROCEDURE shipment_price_compare_pvt (
        p_delivery_id             IN     NUMBER DEFAULT NULL,
        p_trip_id                 IN     NUMBER DEFAULT NULL,
        p_lane_id_tab             IN     WSH_UTIL_CORE.id_tab_type,
        p_sched_id_tab            IN     WSH_UTIL_CORE.id_tab_type,
        p_service_lane_tab        IN     WSH_UTIL_CORE.Column_Tab_Type,
        p_service_sched_tab       IN     WSH_UTIL_CORE.Column_Tab_Type,
        p_dep_date                IN     DATE DEFAULT sysdate,
        p_arr_date                IN     DATE DEFAULT sysdate,
        x_sum_lane_price_tab      OUT    NOCOPY  WSH_UTIL_CORE.id_tab_type,
        x_sum_lane_price_curr_tab OUT    NOCOPY  WSH_UTIL_CORE.Column_tab_type,
        x_sum_sched_price_tab      OUT   NOCOPY  WSH_UTIL_CORE.id_tab_type,
        x_sum_sched_price_curr_tab OUT   NOCOPY  WSH_UTIL_CORE.Column_tab_type,
        x_request_id              IN OUT NOCOPY     NUMBER,
        x_return_status           OUT    NOCOPY     VARCHAR2 );

-- Returns the freight_cost_id of the delivery leg summary record in WSH_FREIGHT_COSTS

FUNCTION get_fc_id_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER;

-- Procedure to get total commodity weight (weight used by LTL) for FPA report
PROCEDURE FPA_total_commodity_weight(
                           p_init_msg_list IN  VARCHAR2 DEFAULT fnd_api.g_true,
                           p_delivery_id   IN  NUMBER,
                           x_total_comm_wt   OUT NOCOPY NUMBER,
                           x_wt_uom        OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2 );

PROCEDURE get_currency_code (
          p_carrier_id      IN   NUMBER,
          x_currency_code   OUT NOCOPY   wsh_carriers.currency_code%TYPE,
          x_return_status   OUT NOCOPY   VARCHAR2);

PROCEDURE get_fc_type_id (
            p_line_type_code       IN  VARCHAR2,
            p_charge_subtype_code  IN  VARCHAR2 DEFAULT NULL,
            x_freight_cost_type_id OUT NOCOPY  NUMBER,
            x_return_status        OUT NOCOPY  VARCHAR2 );

PROCEDURE print_top_level_detail (
        p_first_level_rows        IN    shpmnt_content_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 );

PROCEDURE print_engine_rows (
        p_engine_rows             IN    pricing_engine_input_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 );

PROCEDURE print_rolledup_lines (
        p_rolledup_lines          IN    rolledup_line_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 );


--      This API is called from the Multi-leg UI for price comparison across lanes/schedules
--      It stores frieght cost details in WSH_FREIGHT_COSTS_TEMP table for all the lanes
--      for display purpose.
--      It returns PL/SQL tables (dense) of summary price in the same sequence as the input
--      Calls shipment hierarchy flattening API


PROCEDURE shipment_price_compare (
	p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	p_delivery_id             IN     NUMBER,
	p_trip_id		IN 	NUMBER,
	p_lane_sched_id_tab        IN  FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	p_lane_sched_tab           IN  FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	p_mode_tab                 IN  FTE_CODE_TAB_TYPE,
	p_service_type_tab         IN  FTE_CODE_TAB_TYPE,
	p_vehicle_type_tab           IN  FTE_ID_TAB_TYPE,
	p_dep_date                IN     DATE DEFAULT sysdate,
	p_arr_date                IN     DATE DEFAULT sysdate,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	x_lane_sched_id_tab        OUT  NOCOPY FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	x_lane_sched_tab           OUT  NOCOPY FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	x_vehicle_type_tab    OUT  NOCOPY FTE_ID_TAB_TYPE,--Vehicle Type ID
	x_mode_tab                 OUT  NOCOPY FTE_CODE_TAB_TYPE,
	x_service_type_tab         OUT NOCOPY FTE_CODE_TAB_TYPE,
	x_sum_rate_tab             OUT NOCOPY FTE_ID_TAB_TYPE,
	x_sum_rate_curr_tab        OUT NOCOPY FTE_CODE_TAB_TYPE,
	x_request_id              OUT NOCOPY     NUMBER,     -- One request ID per comparison request
	x_return_status           OUT NOCOPY     VARCHAR2 ) ;




END FTE_FREIGHT_PRICING;


 

/
