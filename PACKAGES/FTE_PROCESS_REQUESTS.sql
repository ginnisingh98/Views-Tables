--------------------------------------------------------
--  DDL for Package FTE_PROCESS_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_PROCESS_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: FTEPRRES.pls 120.0.12000000.1 2007/01/18 21:25:36 appldev ship $ */


TYPE fte_source_line_rec IS RECORD
(source_type		VARCHAR2(10),
 source_header_id	NUMBER,
 source_line_id		NUMBER,
 ship_from_org_id	NUMBER,
 ship_from_location_id	NUMBER,
 ship_to_site_id	NUMBER,
 ship_to_location_id	NUMBER,
 customer_id		NUMBER,
 inventory_item_id	NUMBER,
 source_quantity	NUMBER,
 source_quantity_uom	VARCHAR2(3),
 ship_date		DATE,
 arrival_date		DATE,
 delivery_lead_time	NUMBER,
 scheduled_flag		VARCHAR2(1),
 order_set_type		VARCHAR2(30),
 order_set_id		NUMBER,
 intmed_ship_to_site_id	NUMBER,
 intmed_ship_to_loc_id	NUMBER,
 carrier_id		NUMBER,
 ship_method_flag	VARCHAR2(1),
 ship_method_code	VARCHAR2(30),
 freight_carrier_code	VARCHAR2(30),
 service_level		VARCHAR2(30),
 mode_of_transport	VARCHAR2(30),
 freight_terms		VARCHAR2(30),
 fob_code		VARCHAR2(30),
 weight			NUMBER,
 weight_uom_code	VARCHAR2(3),
 volume			NUMBER,
 volume_uom_code	VARCHAR2(3),
 freight_rating_flag	VARCHAR2(1),
 freight_rate		NUMBER,
 freight_rate_currency	VARCHAR2(3),
 status			VARCHAR2(1),
 message_data		VARCHAR2(2000),
 consolidation_id	NUMBER,
 override_ship_method   VARCHAR2(1),
 currency               VARCHAR2(10),
 currency_conversion_type VARCHAR2(30),
 origin_country         VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_state           VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_city            VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_zip             VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_country    VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_state      VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_city       VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_zip        VARCHAR2(30),        -- FTE J FTE estimate rate
 distance                NUMBER,             -- FTE J FTE estimate rate
 distance_uom            VARCHAR2(30),        -- FTE J FTE estimate rate
 vehicle_item_id         NUMBER,        -- FTE J FTE estimate rate
 commodity_category_id   NUMBER        -- FTE J FTE estimate rate
);

TYPE fte_source_line_tab IS TABLE OF fte_source_line_rec
INDEX BY BINARY_INTEGER;

TYPE fte_source_header_rec IS RECORD
(consolidation_id	NUMBER,
 ship_from_org_id	NUMBER,
 ship_from_location_id	NUMBER,
 ship_to_location_id	NUMBER,
 ship_to_site_id	NUMBER,
 customer_id		NUMBER,
 ship_date		DATE,
 arrival_date		DATE,
 delivery_lead_time	NUMBER,
 scheduled_flag		VARCHAR2(1),
 total_weight		NUMBER,
 weight_uom_code	VARCHAR2(3),
 total_volume		NUMBER,
 volume_uom_code	VARCHAR2(3),
 ship_method_code	VARCHAR2(30),
 carrier_id		NUMBER,
 service_level		VARCHAR2(30),
 mode_of_transport	VARCHAR2(30),
 freight_terms		VARCHAR2(30),
 status			VARCHAR2(1),
 message_data		VARCHAR2(2000),
 enforce_lead_time	VARCHAR2(1),
 currency               VARCHAR2(10),
 currency_conversion_type VARCHAR2(30),
 origin_country         VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_state           VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_city            VARCHAR2(30),        -- FTE J FTE estimate rate
 origin_zip             VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_country    VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_state      VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_city       VARCHAR2(30),        -- FTE J FTE estimate rate
 destination_zip        VARCHAR2(30),        -- FTE J FTE estimate rate
 distance                NUMBER,        -- FTE J FTE estimate rate
 distance_uom            VARCHAR2(30),        -- FTE J FTE estimate rate
 vehicle_item_id         NUMBER,        -- FTE J FTE estimate rate
 commodity_category_id   NUMBER,        -- FTE J FTE estimate rate
 fob_code                VARCHAR2(30)   -- FTE R12
 );

TYPE fte_source_header_tab IS TABLE OF fte_source_header_rec
INDEX BY BINARY_INTEGER;

TYPE fte_source_line_rates_rec IS RECORD
(source_line_id         NUMBER,
 cost_type_id		NUMBER,
 line_type_code		VARCHAR2(30),
 cost_type              VARCHAR2(30),
 cost_sub_type          VARCHAR2(30),
 priced_quantity        NUMBER,
 priced_uom             VARCHAR2(10),
 unit_price             NUMBER,
 base_price             NUMBER,
 adjusted_unit_price    NUMBER,
 adjusted_price         NUMBER,
 currency               VARCHAR2(10),
 consolidation_id	NUMBER,
 lane_id		NUMBER,
 carrier_id		NUMBER,
 carrier_freight_code 	VARCHAR2(30),
 service_level		VARCHAR2(30),
 mode_of_transport	VARCHAR2(30),
 ship_method_code	VARCHAR2(30),
 vehicle_type_id 	NUMBER); --Release 12

TYPE fte_source_line_rates_tab IS TABLE OF fte_source_line_rates_rec
INDEX BY BINARY_INTEGER;

TYPE fte_source_header_rates_rec IS RECORD
(consolidation_id	NUMBER,
 lane_id		NUMBER,
 carrier_id		NUMBER,
 carrier_freight_code 	VARCHAR2(30),
 service_level		VARCHAR2(30),
 mode_of_transport	VARCHAR2(30),
 ship_method_code	VARCHAR2(30),
 cost_type_id		NUMBER,
 cost_type              VARCHAR2(30),
 price             	NUMBER,
 currency               VARCHAR2(10),
 transit_time		NUMBER,
 transit_time_uom	VARCHAR2(10),
 first_line_index	NUMBER,
 vehicle_type_id	NUMBER);--Release 12

TYPE fte_source_header_rates_tab IS TABLE OF fte_source_header_rates_rec
INDEX BY BINARY_INTEGER;

PROCEDURE Process_Lines(p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			p_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			p_source_type			IN		VARCHAR2,
		        p_action			IN		VARCHAR2,
			x_source_line_rates_tab		OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
			x_source_header_rates_tab	OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
		       	x_return_status			OUT NOCOPY	VARCHAR2,
		       	x_msg_count			OUT NOCOPY	NUMBER,
			x_msg_data			OUT NOCOPY	VARCHAR2);


-- FOR BACKWARD (I) COMPATIBILITY ONLY
-- THE FOLLOWING SPEC IS NOT FUNCTIONAL IN THIS BRANCH

TYPE fte_rating_parameters_rec IS RECORD
(param_name	VARCHAR2(30),
 param_value	VARCHAR2(240),
 uom_code	VARCHAR2(10));

TYPE fte_rating_parameters_tab IS TABLE OF fte_rating_parameters_rec INDEX BY BINARY_INTEGER;

FTE_MISS_RATING_PARAMETERS_TAB fte_rating_parameters_tab;

PROCEDURE Process_Lines(p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			p_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			p_source_type			IN		VARCHAR2,
		        p_action			IN		VARCHAR2,
			p_rating_parameters_tab		IN		FTE_PROCESS_REQUESTS.fte_rating_parameters_tab DEFAULT FTE_MISS_RATING_PARAMETERS_TAB,
			p_source_line_rates_tab		OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
		       	x_return_status			OUT NOCOPY	VARCHAR2,
		       	x_msg_count			OUT NOCOPY	NUMBER,
			x_msg_data			OUT NOCOPY	VARCHAR2);


END FTE_PROCESS_REQUESTS;

 

/
