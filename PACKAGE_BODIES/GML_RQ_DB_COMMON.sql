--------------------------------------------------------
--  DDL for Package Body GML_RQ_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RQ_DB_COMMON" AS
/* $Header: GMLRQXCB.pls 115.2 2003/03/17 18:27:48 pbamb noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILENAME                                                               |
--|                                                                        |
--|   GMLRQXCB.pls       This package contains db procedures and functions |
--|                      required by REQUISITIONS                          |
--| DESCRIPTION                                                            |
--|                                                                        |
--|                                                                        |
--| DECLARATION                                                            |
--|                                                                        |
--|  get_opm_cost_price   Function to get opm cost for internal order for  |
--|                       opm item and process org		           |
--| MODIFICATION HISTORY                                                   |
--|                                                                        |
--|    09-JUL-2002      PBamb        Created.    			   |
--|                                                                        |
--+==========================================================================+
-- End of comments

--+==========================================================================+
--|
--|  FUNCTION
--|   get_opm_cost_price
--|
--|  DESCRIPTION
--|
--|      This function computes the cost price for the item,org and uom.
--|
--|
--| MODIFICATION HISTORY
--| 09-JUL-2002  PBamb    Created
--|
--+==========================================================================+

PROCEDURE get_opm_cost_price(	x_item_id IN NUMBER,
				x_org_id  IN NUMBER,
				x_doc_uom IN VARCHAR2,
				x_unit_price IN OUT NOCOPY NUMBER) IS

v_whse_code 		VARCHAR2(4);
v_orgn_code 		VARCHAR2(4);
v_progress 		VARCHAR2(3) := '010';
v_primary_uom_price	NUMBER;
v_primary_opm_uom	VARCHAR2(4);
v_dual_uom_type		NUMBER;
v_multiply_factor	NUMBER;
v_doc_opm_uom		VARCHAR2(4);

BEGIN
	IF x_item_id IS NULL
	THEN
		x_unit_price := 0;
		RETURN;
	END IF;

	/*Get warehouse and organization code*/
	select 	whse_code,
		orgn_code
	into	v_whse_code,
		v_orgn_code
	from	ic_whse_mst
	where	mtl_organization_id = x_org_id;

      	/*get primary uom and dual uom type for the opm item*/
	select 	item_um,
		dualum_ind
	into	v_primary_opm_uom,
		v_dual_uom_type
	from	ic_item_mst
	where	item_id = x_item_id;

      	v_primary_uom_price := nvl(gmf_cmcommon.unit_cost(	x_item_id,
								v_whse_code,
								v_orgn_code,
								sysdate),0);

	v_doc_opm_uom 	:= po_gml_db_common.get_opm_uom_code(x_doc_uom);

	/*If the requisition UOM and the item's primary UOM are same then
	  the unit price is same else we need to calculate (derive) the unit price for
	  the requisiton uom*/
	IF v_doc_opm_uom = v_primary_opm_uom THEN
		x_unit_price := v_primary_uom_price;
	ELSE
		gmicuom.icuomcv ( 	x_item_id,
			  		0, -- lot id always 0
			  		1, -- pass quantity of 1
                          		v_doc_opm_uom, -- requisition uom
                          		v_primary_opm_uom, -- primary uom of item
			  		v_multiply_factor );

	       	x_unit_price := v_primary_uom_price * nvl(v_multiply_factor,0);
        END IF;

EXCEPTION
 WHEN OTHERS THEN
   	x_unit_price	:= 0;

END get_opm_cost_price ;

END GML_RQ_DB_COMMON;

/
