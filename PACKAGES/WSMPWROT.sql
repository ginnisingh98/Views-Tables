--------------------------------------------------------
--  DDL for Package WSMPWROT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPWROT" AUTHID CURRENT_USER as
/* $Header: WSMWROTS.pls 115.10 2004/06/16 05:27:25 mprathap ship $ */
--BA Phantom project
EXPLOSION_GROUP_ID NUMBER;
USE_PHANTOM_ROUTINGS NUMBER;
--Sortwidth is changed from 4 to 7 for bug 3673369
--X_SortWidth NUMBER:=4;/*to be replaced with the bom profile value*/
X_SortWidth NUMBER:=7;/*to be replaced with the bom profile value*/
--EA Phantom project

PROCEDURE POPULATE_WRO (
	       p_first_flag IN NUMBER,
               p_wip_entity_id IN NUMBER,
               p_organization_id IN NUMBER,
               p_assembly_item_id IN NUMBER,
	       p_bom_revision_date IN DATE,
	       p_alt_bom IN VARCHAR2,
	       p_quantity IN NUMBER,
	       p_operation_sequence_id IN NUMBER,	-- BA: NSO-WLT
	       p_charges_exist	IN NUMBER DEFAULT NULL, -- DEF ENH 0 ,-- EA: NSO-WLT
	       x_err_code OUT NOCOPY NUMBER,
	       x_err_msg OUT NOCOPY VARCHAR2,
/*BA2090293*/
		p_routing_revision_date IN DATE DEFAULT NULL, -- DEF ENH SYSDATE,
		p_wip_supply_type IN NUMBER DEFAULT NULL ); -- DEF ENH 7);
/*EA2090293*/

PROCEDURE POPULATE_WRO (
	       p_first_flag IN NUMBER,
               p_wip_entity_id IN NUMBER,
               p_organization_id IN NUMBER,
               p_assembly_item_id IN NUMBER,
	       p_bom_revision_date IN DATE,
	       p_alt_bom IN VARCHAR2,
	       p_quantity IN NUMBER,
	       p_operation_sequence_id IN NUMBER,	-- BA: NSO-WLT
	       p_charges_exist	IN NUMBER DEFAULT NULL, -- DEF ENH 0, -- EA: NSO-WLT
	       x_err_code OUT NOCOPY NUMBER,
	       x_err_msg OUT NOCOPY VARCHAR2,
/*BA2090293*/
		p_routing_revision_date IN DATE DEFAULT NULL, -- DEF ENH SYSDATE,
		p_wip_supply_type IN NUMBER DEFAULT NULL, -- DEF ENH 7,
/*EA2090293*/
		p_routing_sequence_id IN NUMBER );  --bug 2445489


FUNCTION GET_EXPLOSION_GROUP_ID
RETURN NUMBER;

PROCEDURE SET_EXPLOSION_GROUP_ID_NULL;

END  WSMPWROT;



 

/
