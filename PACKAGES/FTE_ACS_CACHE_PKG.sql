--------------------------------------------------------
--  DDL for Package FTE_ACS_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ACS_CACHE_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEACSCS.pls 120.0 2005/05/26 17:22:26 appldev noship $ */

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- Tables and records for input                                                                --
-- ----------------------------                                                                --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
TYPE fte_cs_entity_attr_rec IS RECORD( group_id			NUMBER,	--cache is built using group id
				       delivery_id		NUMBER,
				       trip_id			NUMBER,
				       weight			NUMBER,
				       weight_uom_code		VARCHAR2(30),
				       volume			NUMBER,
				       volume_uom_code		VARCHAR2(30),
				       transit_time		NUMBER,
				       ship_from_location_id	NUMBER,
				       ship_to_location_id	NUMBER,
				       fob_code			VARCHAR2(30));

TYPE fte_cs_result_attr_rec IS RECORD( result_type		VARCHAR2(30), -- Rank / Multileg / Ranked multileg / Ranked itinerary
				       rank			NUMBER,
				       leg_destination		NUMBER,
				       leg_sequence		NUMBER,
--				       itinerary_id		NUMBER,	      -- Future use for ranked itenerary
				       carrier_id		NUMBER,
				       mode_of_transport	VARCHAR2(30),
				       service_level		VARCHAR2(30),
				       freight_terms_code	VARCHAR2(30),
				       consignee_carrier_ac_no	VARCHAR2(240),
--				       track_only_flag		VARCHAR2(1),
				       result_level		VARCHAR(5));

TYPE fte_cs_entity_attr_tab IS TABLE OF fte_cs_entity_attr_rec INDEX BY BINARY_INTEGER;

TYPE fte_cs_result_attr_tab IS TABLE OF fte_cs_result_attr_rec INDEX BY BINARY_INTEGER;

g_rule_not_found	CONSTANT NUMBER := -1;

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- PROCEDURE DEFINITONS                                                                        --
-- --------------------                                                                        --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_matching_rule            PRIVATE
--
-- PARAMETERS: p_info		          Attributes of the entity to be searched for
--	       x_rule_id		  Matching Rule
--	       x_return_status		  Return Status
--
-- COMMENT   : The API returns the rule which matches attribute values passed in p_info.
--	       If no rule is found matching it returns  g_rule_not_found
--
--***************************************************************************--

PROCEDURE GET_MATCHING_RULE(  p_info		IN		FTE_ACS_CACHE_PKG.fte_cs_entity_attr_rec,
			      x_rule_id		OUT NOCOPY	NUMBER,
			      x_return_status	OUT NOCOPY	VARCHAR2);


--***************************************************************************--
--===========================================================================
-- PROCEDURE : get_results_for_rule      PRIVATE
--
-- PARAMETERS: p_rule_id		 Rule Id.
--	       x_result_tab		 Results Attributes associated with the rule.
--	       x_return_status		 Return Status
--
-- COMMENT   : For a given rule id queries FTE_SEL_RESULT_ASSIGNMENTS and FTE_SEL_RESULT_ATTRIBUTES
--             to return the result.Caching is used in this procedure.
--
--***************************************************************************--
PROCEDURE GET_RESULTS_FOR_RULE( p_rule_id	IN		NUMBER,
			        x_result_tab	OUT NOCOPY	FTE_ACS_CACHE_PKG.fte_cs_result_attr_tab,
			        x_return_status  OUT NOCOPY     VARCHAR2);


END FTE_ACS_CACHE_PKG;

 

/
