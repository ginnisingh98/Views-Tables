--------------------------------------------------------
--  DDL for Package Body BOM_RTG_EXP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_EXP_UTIL" AS
/* $Header: BOMREVIB.pls 115.0 2002/11/14 13:11:30 djebar noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBREVIB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_EXP_UTIL
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-02   M V M P Tilak    Initial Creation
***************************************************************************/

FUNCTION Get_Item_Name(P_inventory_item_id IN NUMBER) RETURN VARCHAR2 IS
  l_item_name mtl_system_items_kfv.concatenated_segments%TYPE;
BEGIN
  SELECT concatenated_segments
  INTO   l_item_name
  FROM   mtl_system_items_kfv
  WHERE  inventory_item_id = P_inventory_item_id
  AND    rownum = 1;
  RETURN l_item_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Item_Name;

FUNCTION Get_Item_Id(P_item_name IN VARCHAR2) RETURN NUMBER IS
  l_item_id NUMBER;
BEGIN
  SELECT inventory_item_id
  INTO   l_item_id
  FROM   mtl_system_items_kfv
  WHERE  concatenated_segments = P_item_name
  AND    rownum = 1;
  RETURN l_item_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Item_Id;

FUNCTION Get_Location_Name(P_locator_id IN NUMBER,
                          P_organization_id IN NUMBER) RETURN VARCHAR2 IS
  l_locator_name MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
  RETURN INV_PROJECT.GET_LOCSEGS(p_locator_id, p_organization_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Location_Name;

FUNCTION Get_Locator_Id(P_location_Name    IN VARCHAR2,
                        P_organization_id IN NUMBER) RETURN NUMBER IS
  l_locator_id NUMBER;
  l_ret_code NUMBER;
  x_err_text varchar2(80);
BEGIN
  l_ret_code := INVPUOPI.mtl_pr_parse_flex_name
                         (org_id    => p_organization_id,
                          flex_code => 'MTLL',
                          flex_name => P_location_name,
                          flex_id   => l_locator_id,
                          set_id    => -1,
                          err_text  => x_err_text);
  IF (l_ret_code > 0) THEN
    RETURN l_locator_id;
  ELSE
    RETURN NULL;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Locator_Id;

END BOM_RTG_EXP_UTIL;

/
