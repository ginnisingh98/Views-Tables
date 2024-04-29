--------------------------------------------------------
--  DDL for Package BOMPECOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPECOD" AUTHID CURRENT_USER AS
/* $Header: BOMECODS.pls 115.1 99/07/16 05:12:15 porting ship $ */


-- ==========================================================================
--   Copyright (c) 1993 Oracle Corporation Belmont, California, USA
--                          All rights reserved.
-- ==========================================================================
--
-- File Name    : BOMPECOD.sql
-- DESCRIPTION  :
--              This file creates a stored procedure that deletes an ECO
--              and all the associated data from the following tables:
--                   ENG_ENGINEERING_CHANGES
--                   ENG_CHANGE_ORDER_REVISIONS
--                   ENG_REVISED_ITEMS
--                   ENG_CURRENT_SCHEDULED_DATES
--                   BOM_INVENTORY_COMPONENTS
--                   BOM_REFERENCE_DESIGNATORS
--                   BOM_SUBSTITUTE_COMPONENTS
--                   ENG_REVISED_COMPONENTS
--                   MTL_ITEM_REVISIONS
--                   BOM_BILL_OF_MATERIALS
-- INPUTS       :  P_CHANGE_NOTICE - engineering change order to be deleted
--                 P_ORGANIZATION_ID - organization id
--
-- ==========================================================================

   PROCEDURE BOM_DELETE_ECO
   (P_CHANGE_NOTICE             IN      VARCHAR2,
    P_ORGANIZATION_ID		IN	NUMBER);

END BOMPECOD;


 

/
