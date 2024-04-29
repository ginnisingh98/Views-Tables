--------------------------------------------------------
--  DDL for Package BOM_RTG_EXP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_EXP_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMREVIS.pls 115.0 2002/11/14 13:11:12 djebar noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMREIVS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_EXP_UTIL
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-02  M V M P Tilak	Initial Creation
--
***************************************************************************/
FUNCTION Get_Item_Name ( p_inventory_item_id IN NUMBER) RETURN VARCHAR2;
FUNCTION Get_Item_Id(P_item_name IN VARCHAR2) RETURN NUMBER;
FUNCTION Get_Location_Name(P_locator_id IN NUMBER,
                          P_organization_id IN NUMBER) RETURN VARCHAR2;
FUNCTION Get_Locator_Id(P_location_name IN VARCHAR2,
                        P_organization_id IN NUMBER) RETURN NUMBER;
END BOM_RTG_EXP_UTIL;

 

/
