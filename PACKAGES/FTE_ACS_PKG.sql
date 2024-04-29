--------------------------------------------------------
--  DDL for Package FTE_ACS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ACS_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEACSMS.pls 120.2 2005/06/23 14:16:56 appldev ship $ */

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- Tables and records for input                                                                --
-- ----------------------------                                                                --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
TYPE fte_cs_output_message_rec IS RECORD (sequence_number   NUMBER,
                                          message_type      VARCHAR2(1),
                                          message_code      VARCHAR2(30),
                                          message_text      VARCHAR2(2000),
                                          level             NUMBER,
                                          query_id          NUMBER,
                                          group_id          NUMBER,
                                          rule_id           NUMBER,
                                          result_id         NUMBER);

TYPE fte_cs_output_message_tab IS TABLE OF fte_cs_output_message_rec INDEX BY BINARY_INTEGER;

-- ----------------------------------------------------------------------------------------- --

TYPE fte_car_sel_tmp_num_table  IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE fte_flag_tab_type          IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_tmp_uom_table  IS TABLE OF VARCHAR2(3)    INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_char4_table    IS TABLE OF VARCHAR2(4)    INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_tmp_code_table IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_tmp_char_table IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_msg_table      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE fte_car_sel_date_table     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;


--
-- R12 Definations;
--
TYPE fte_cs_entity_rec_type IS RECORD(
		delivery_id				NUMBER,
		delivery_name				VARCHAR2(30),
	        trip_id					NUMBER,
                trip_name				VARCHAR2(30),
                organization_id				NUMBER,
                triporigin_internalorg_id		NUMBER,
		gross_weight				NUMBER,
                weight_uom_code				VARCHAR2(3),
                volume					NUMBER,
                volume_uom_code				VARCHAR2(3),
                initial_pickup_loc_id			NUMBER,
                ultimate_dropoff_loc_id			NUMBER,
		customer_id				NUMBER,
		customer_site_id			NUMBER,
		freight_terms_code			VARCHAR2(30),
                initial_pickup_date			DATE,
                ultimate_dropoff_date			DATE,
                fob_code				VARCHAR2(30),
                start_search_level			VARCHAR2(10),
		transit_time				NUMBER,
		rule_id					NUMBER,
		result_found_flag			VARCHAR2(1));

TYPE fte_cs_entity_tab_type IS TABLE OF FTE_CS_ENTITY_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE fte_cs_result_rec_type IS RECORD(
                rule_id					NUMBER,
		rule_name				VARCHAR2(30),
		delivery_id				NUMBER,
                organization_id                         NUMBER,
                initial_pickup_location_id		NUMBER,
                ultimate_dropoff_location_id		NUMBER,
                trip_id					NUMBER,
                result_type				VARCHAR2(30), -- Rank / Multileg / Ranked multileg / Ranked itinerary
                rank					NUMBER,
                leg_destination				NUMBER,
                leg_sequence				NUMBER,
--              itinerary_id				NUMBER,	-- Future use for ranked itenerary
                carrier_id				NUMBER,
                mode_of_transport			VARCHAR2(30),
                service_level				VARCHAR2(30),
                ship_method_code			VARCHAR2(30),
                freight_terms_code			VARCHAR2(30),
		consignee_carrier_ac_no			VARCHAR2(240), --WSH_TRIPS
--              track_only_flag				VARCHAR2(1),
                result_level				VARCHAR(5),
		pickup_date				DATE,
		dropoff_date				DATE,
		min_transit_time			NUMBER,
		max_transit_time			NUMBER,
		append_flag				VARCHAR2(1)
		--,routing_rule_id				NUMBER
                );

TYPE fte_cs_result_tab_type IS TABLE OF fte_cs_result_rec_type INDEX BY BINARY_INTEGER;

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- PROCEDURE DEFINITONS                                                                        --
-- --------------------                                                                        --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
/*
PROCEDURE START_ACS(p_cs_input_header_rec    IN OUT NOCOPY FTE_ACS_PKG.fte_cs_input_header_rec,
                    p_cs_input_attribute_tab IN OUT NOCOPY FTE_ACS_PKG.fte_cs_input_attribute_tab,
                    p_object_name            IN  VARCHAR2,
                    p_object_id              IN  NUMBER,
                    p_messaging_yn           IN  VARCHAR2,
                    x_cs_output_result_tab   OUT NOCOPY FTE_ACS_PKG.fte_cs_output_result_tab,
                    x_cs_output_message_tab  OUT NOCOPY FTE_ACS_PKG.fte_cs_output_message_tab,
                    x_return_message         OUT NOCOPY VARCHAR2,
                    x_return_status          OUT NOCOPY VARCHAR2);
*/

PROCEDURE LOG_CS_MESSAGES(p_message_type_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_flag_tab_type,
                          p_message_code_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_code_table,
                          p_message_text_tab   IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_msg_table,
                          p_level_tab          IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_query_id           IN NUMBER,
                          p_group_id_tab       IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_rule_id_tab        IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          p_result_id_tab      IN OUT NOCOPY FTE_ACS_PKG.fte_car_sel_tmp_num_table,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_return_message     OUT NOCOPY VARCHAR2);


--
-- R12 Routing Enhancement
--
PROCEDURE GET_ROUTING_RESULTS( p_format_cs_tab		 IN OUT	NOCOPY	FTE_ACS_PKG.fte_cs_entity_tab_type,
			       p_entity			 IN		VARCHAR2,--trip/dlvy/pseudo_dlvy
			       p_messaging_yn		 IN		VARCHAR2,
			       p_caller			 IN		VARCHAR2,
			       x_cs_output_tab		 OUT	NOCOPY	FTE_ACS_PKG.fte_cs_result_tab_type,
		               x_cs_output_message_tab	 OUT	NOCOPY	FTE_ACS_PKG.fte_cs_output_message_tab,
			       x_return_message		 OUT	NOCOPY	VARCHAR2,
			       x_return_status		 OUT	NOCOPY	VARCHAR2);

--
-- R12 Routing Enhancement
--

END FTE_ACS_PKG;

 

/
