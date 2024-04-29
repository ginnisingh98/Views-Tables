--------------------------------------------------------
--  DDL for Package Body GMD_LCF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LCF_UTIL" AS
/* $Header: GMDLCFUB.pls 120.3 2005/11/15 11:54:27 rajreddy noship $ */

  FUNCTION Get_Cost (
	p_item_id		IN	NUMBER		,
	p_organization_id	IN	NUMBER		,
	p_cost_orgn_id		IN	NUMBER		,
	p_lot_no		IN	VARCHAR2	,
	p_qty			IN	NUMBER		,
	p_uom			IN	VARCHAR2	,
	p_cost_date		IN	DATE		) RETURN NUMBER IS
    CURSOR Cur_get_cost IS
      SELECT unit_cost
      FROM   gmd_lcf_external_cost
      WHERE  inventory_item_id     = p_item_id
      AND    lab_organization_id   = p_organization_id
      AND    cost_organization_id  = p_cost_orgn_id
      AND    NVL(lot_number, '-1') = NVL(p_lot_no, '-1')
      AND    NVL(quantity, -1)     = NVL(p_qty, -1)
      AND    NVL(uom, '-1')        = NVL(p_uom, '-1')
      AND    p_cost_date BETWEEN from_date AND to_date;
    l_cost	NUMBER DEFAULT 0;
  BEGIN
    OPEN Cur_get_cost;
    FETCH Cur_get_cost INTO l_cost;
    CLOSE Cur_get_cost;
    RETURN (l_cost);
  END Get_Cost;
END GMD_LCF_UTIL;


/
