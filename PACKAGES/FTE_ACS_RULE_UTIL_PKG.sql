--------------------------------------------------------
--  DDL for Package FTE_ACS_RULE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ACS_RULE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEACSXS.pls 120.1 2005/06/06 09:50:22 appldev  $ */

-- -----------------------------------------------------------------------------------
-- FUNCTION SPECIFICATIONS
-- -----------------------
--
-- -----------------------------------------------------------------------------------
FUNCTION CONV_TO_BASE_UOM(p_input_value IN NUMBER,
                          p_from_uom    IN VARCHAR2,
                          p_to_uom      IN VARCHAR2) RETURN NUMBER;

-- -----------------------------------------------------------------------------------
-- PROCEDURE SPECIFICATIONS
-- ------------------------
--
-- -----------------------------------------------------------------------------------
--
-- R12 Enhancements
--
PROCEDURE GET_FORMATED_REGIONS( p_location_id		IN  NUMBER,
			        x_region_tab		OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			        x_all_region_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			        x_postal_zone_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
				x_return_status		OUT NOCOPY VARCHAR2);

PROCEDURE  GET_POSTAL_CODE(p_location_id   IN	    NUMBER,
			   x_postal_code   OUT NOCOPY VARCHAR2,
			   x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE SET_RANGE_OVERLAP_FLAG(p_group_id IN NUMBER);


PROCEDURE INSERT_INTO_GTT( p_input_data	   IN FTE_ACS_PKG.fte_cs_entity_tab_type,
			   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE FORMAT_ENTITY_INFO( p_input_cs_tab IN OUT NOCOPY FTE_ACS_PKG.fte_cs_entity_tab_type,
			      p_entity	     IN VARCHAR2,
			      x_return_status   OUT NOCOPY VARCHAR2);

PROCEDURE GET_SHIP_METHOD_CODE(p_carrier_id	    IN NUMBER,
			       p_service_level      IN VARCHAR2,
                               p_mode_of_transport  IN VARCHAR2,
                               p_org_id             IN NUMBER,
                               x_ship_method_code   OUT NOCOPY VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_return_message     OUT NOCOPY VARCHAR2);

PROCEDURE GET_CANDIDATE_RECORDS( p_search_level	 IN VARCHAR2,
				 p_query_gtt	 IN BOOLEAN,
				 p_single_rec	 IN FTE_ACS_PKG.FTE_CS_ENTITY_REC_TYPE DEFAULT NULL,
				 x_output_tab	 OUT NOCOPY FTE_ACS_CACHE_PKG.FTE_CS_ENTITY_ATTR_TAB,
				 x_return_status OUT NOCOPY VARCHAR2);

END FTE_ACS_RULE_UTIL_PKG;


 

/
