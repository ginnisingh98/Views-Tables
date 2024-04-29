--------------------------------------------------------
--  DDL for Package CSTPPCIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPCIC" AUTHID CURRENT_USER AS
/* $Header: CSTPCICS.pls 115.7 2002/11/09 00:28:31 awwang ship $ */


/*---------------------------------------------------------------------------
  This function returns the conversion rate between the 2 Uoms
  This returned rate will be multiplied with the cost to get the new cost
  which will be inserted into CST_ITEM_COSTS in procedure copy_item_period_cost()
----------------------------------------------------------------------------*/

FUNCTION get_uom_conv_rate(
        i_item_id          IN      NUMBER,
        i_from_org_id     IN      NUMBER,
        i_to_org_id    IN      NUMBER)
return NUMBER ;


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       copy_item_period_cost                                                |
|                                                                            |
|  p_copy_option:							     |
|             1:  Merge and update                                           |
|             2:  New cost only                                              |
|             3:  remove and replace                                         |
|  p_range:								     |
|             1:  All items                                                  |
|             2:  Specific Item                                              |
|             5:  Category Items                                             |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE copy_item_period_cost(
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY     NUMBER,
	p_legal_entity		IN	NUMBER,
	p_from_cost_type_id	IN	NUMBER,
	p_from_cost_group_id	IN	NUMBER,
	p_period_id		IN	NUMBER,
	p_to_org_id		IN	NUMBER,
 	p_to_cost_type_id    	IN	NUMBER,
        p_material 		IN	NUMBER,
        p_material_overhead 	IN	NUMBER,
        p_resource 		IN	NUMBER,
        p_outside_processing 	IN	NUMBER,
        p_overhead 		IN	NUMBER,
	p_copy_option		IN	NUMBER,
	p_range 		IN	NUMBER,
	p_item_dummy		IN	NUMBER,
	p_category_dummy	IN	NUMBER,
	p_specific_item_id	IN	NUMBER,
	p_category_set_id	IN	NUMBER,
        p_category_validate_flag IN     VARCHAR2,
        p_category_structure	IN	NUMBER,
	p_category_id		IN	NUMBER,
	p_last_updated_by  	IN	NUMBER,
	p_full_validate  	IN	NUMBER);


END CSTPPCIC;

 

/
