--------------------------------------------------------
--  DDL for Package INV_CREATE_MOVE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CREATE_MOVE_ORDER_PVT" AUTHID CURRENT_USER as
/* $Header: INVTOMMS.pls 120.0 2005/05/25 05:53:15 appldev noship $ */

FUNCTION Create_Move_Orders(p_item_id 	          IN NUMBER,
			    p_quantity            IN NUMBER,
			    p_secondary_quantity  IN NUMBER    DEFAULT NULL, ---INVCONV Changes
			    p_need_by_date        IN DATE,
			    p_primary_uom_code    IN VARCHAR2,
			    p_secondary_uom_code  IN VARCHAR2  DEFAULT NULL, ---INVCONV Changes
			    p_grade_code          IN VARCHAR2  DEFAULT NULL, ---INVCONV Changes
			    p_user_id	          IN NUMBER,
			    p_organization_id     IN NUMBER,
			    p_src_type            IN NUMBER,
			    p_src_subinv          IN VARCHAR2,
			    p_subinv	          IN VARCHAR2,
                            p_locator_id          IN NUMBER    DEFAULT NULL,
                            p_reference           IN VARCHAR2  DEFAULT NULL,
                            p_reference_source    IN NUMBER    DEFAULT NULL,
                            p_reference_type      IN NUMBER    DEFAULT NULL)
RETURN VARCHAR2;

END INV_Create_Move_Order_PVT;

 

/
