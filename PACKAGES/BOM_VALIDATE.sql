--------------------------------------------------------
--  DDL for Package BOM_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: BOMSVATS.pls 120.1 2005/12/04 22:32:45 vhymavat noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSVATS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99   Rahul Chitko    Initial Creation
--
--  08-MAY-01   Refai Farook    EAM changes

--  26-MAY-04   Vani Hymavathi  added new function Is_Preferred_Structure

****************************************************************************/
	FUNCTION Alternate_Designator(  p_alternate_bom_code	IN  VARCHAR2
			              , p_organization_id	IN  NUMBER
				      ) RETURN BOOLEAN;


        FUNCTION End_Item_Unit_Number
        ( p_from_end_item_unit_number IN  VARCHAR2
        , p_revised_item_id           IN  VARCHAR2
        , x_err_text                  IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;

        FUNCTION Wip_Supply_Type
	(  p_wip_supply_type   IN  NUMBER
         , x_err_text          IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;

        FUNCTION Asset_Group_Serial_Number
        ( p_assembly_item_id  IN NUMBER,
          p_organization_id   IN NUMBER,
          p_serial_number     IN  VARCHAR2,
          x_err_text         IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;


        FUNCTION  Is_Preferred_Structure
        ( p_assembly_item_id  IN NUMBER,
          p_organization_id   IN NUMBER,
          p_alternate_bom_code IN  VARCHAR2,
          x_err_text         IN OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

	FUNCTION Object_Exists
	(p_object_type VARCHAR2,p_object_name VARCHAR2) RETURN  VARCHAR2;
END BOM_Validate;

 

/
