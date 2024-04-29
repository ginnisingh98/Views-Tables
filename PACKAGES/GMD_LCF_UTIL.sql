--------------------------------------------------------
--  DDL for Package GMD_LCF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LCF_UTIL" AUTHID CURRENT_USER AS
/* $Header: GMDLCFUS.pls 120.3 2005/11/15 11:52:55 rajreddy noship $ */

/*-------------------------------------------------------------------
-- NAME
--    Get_Cost
--
-- SYNOPSIS
--    Function Get_Cost
--
-- DESCRIPTION
--    This function is called when external cost is chosen in Technical
-- parameter form to fetch the cost function
--
--
-- HISTORY
--    Sriram    7/25/2005     Created for LCF Build
--------------------------------------------------------------------*/

FUNCTION Get_Cost (
	p_item_id		IN	NUMBER		,
	p_organization_id	IN	NUMBER		,
	p_cost_orgn_id		IN	NUMBER		,
	p_lot_no		IN	VARCHAR2	,
	p_qty			IN	NUMBER		,
	p_uom			IN	VARCHAR2	,
	p_cost_date		IN	DATE		)
	RETURN NUMBER;

END GMD_LCF_UTIL;


 

/
