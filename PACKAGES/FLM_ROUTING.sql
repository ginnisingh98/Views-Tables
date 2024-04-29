--------------------------------------------------------
--  DDL for Package FLM_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_ROUTING" AUTHID CURRENT_USER AS
/* $Header: FLMRTGDS.pls 115.6 2004/07/27 23:19:00 ksuleman noship $  */

TYPE item_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE item_rtg_type IS RECORD (
      item_id NUMBER,
      routing_designator BOM_ALTERNATE_DESIGNATORS.ALTERNATE_DESIGNATOR_CODE%TYPE);

 TYPE item_rtg_tbl_type IS TABLE OF item_rtg_type
   INDEX BY BINARY_INTEGER;

g_item_tbl item_tbl_type;
g_tbl_index NUMBER;

/********************************************************
 *	PROCEDURE: retrieve_items			*
 *							*
 *  This procedure returns a list of items which	*
 *  fulfill the filtering criteria passed in.		*
 *  							*
 *  Input:						*
 *	- i_org_id: The organization id	of the items.	*
 *	- i_from_item: The inventory item name of the	*
 *	    lower item.					*
 *	- i_to_item: The inventory item name of the 	*
 *	    higher item.				*
 *	  The retrieved item must be between the lower	*
 *	  and higher item.				*
 *	- i_product_family_id: The product family id of	*
 *	    the items.					*
 *	- i_category_set_id: The category set		*
 *	- i_category_id: Category id inside the		*
 *	    category set.				*
 *	- i_planner_code: The planner code of the items.*
 *      - Added for enhancement #2647023                *
 *      - i_alternate_routing_designator: The retrieved *
 *          item should not have a routing existing     *
 *          with the same item-alternate combination.   *
 *  Output:						*
 *	- o_item_tbl: The returning list of item ids	*
 *	- o_return_code: The status of the execution	*
 *		0:	Success				*
 *		1:	Failed				*
 *  Note: This procedure is designed for retrieving 	*
 *    assembly items to copy primary routing to. To	*
 *    ensure performance, we will filter out all items	*
 *    which are not qualified for this, e.g., items	*
 *    which are not BOM enabled, or items which already *
 *    have primary routing.				*
 ********************************************************/

PROCEDURE retrieve_items (
	i_org_id	IN	NUMBER,
	i_from_item	IN	VARCHAR2,
	i_to_item	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id	IN	NUMBER,
	i_planner_code	IN	VARCHAR2,
	i_alternate_routing_designator	IN	VARCHAR2,
	o_item_tbl	OUT	NOCOPY	item_tbl_type,
	o_return_code	OUT	NOCOPY	NUMBER);



/********************************************************
 *	PROCEDURE: retrieve_option_items		*
 *							*
 *  This procedure returns a list of option classes	*
 *  under a model bom which fulfill the filtering 	*
 *  criteria passed in.					*
 *  This will return all the levels of OC's. Loop nodes	*
 *  will be skipped.					*
 *  							*
 *  Input:						*
 *	- i_org_id: The organization id	of the items.	*
 *	- i_from_item: The inventory item name of the	*
 *	    lower item.					*
 *	- i_to_item: The inventory item name of the 	*
 *	    higher item.				*
 *	  The retrieved item must be between the lower	*
 *	  and higher item.				*
 *	- i_product_family_id: The product family id of	*
 *	    the items.					*
 *	- i_category_set_id: The category set		*
 *	- i_category_id: Category id inside the		*
 *	    category set.				*
 *	- i_planner_code: The planner code of the items.*
 *      - Added for enhancement #2647023                *
 *      - i_alternate_routing_designator: The retrieved *
 *          item should not have a routing existing     *
 *          with the same item-alternate combination.   *
 *  Output:						*
 *	- o_item_tbl: The returning list of item ids	*
 *	- o_return_code: The status of the execution	*
 *		0:	Success				*
 *		1:	Failed				*
 ********************************************************/

PROCEDURE retrieve_option_items (
        i_org_id                IN      NUMBER,
        i_from_item             IN      VARCHAR2,
        i_to_item               IN      VARCHAR2,
        i_product_family_id     IN      NUMBER,
        i_category_set_id       IN      NUMBER,
        i_category_id           IN      NUMBER,
        i_planner_code          IN      VARCHAR2,
	i_alternate_routing_designator	IN	VARCHAR2,
        i_assembly_item_id      IN      NUMBER,
        i_alt_designator        IN      VARCHAR2,
        o_item_tbl              OUT     NOCOPY	item_tbl_type,
        o_return_code           OUT     NOCOPY	NUMBER);

PROCEDURE retrieve_mass_change_items (
	i_org_id	IN	NUMBER,
	i_line_id	IN	NUMBER,
	i_from_item	IN	VARCHAR2,
	i_to_item	IN	VARCHAR2,
	i_product_family_id	IN	NUMBER,
	i_category_set_id	IN	NUMBER,
	i_category_id	IN	NUMBER,
	i_planner_code	IN	VARCHAR2,
	i_alt_desig_code IN   	VARCHAR2,
	i_alt_desig_check IN    NUMBER,
        i_item_type_pf    IN    NUMBER,
	o_item_tbl	OUT	NOCOPY	item_rtg_tbl_type,
	o_return_code	OUT	NOCOPY	NUMBER);

END flm_routing;

 

/
