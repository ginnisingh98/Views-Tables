--------------------------------------------------------
--  DDL for Package BOM_DELETE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DELETE_ITEMS" AUTHID CURRENT_USER AS
/* $Header: BOMDELTS.pls 115.1 99/07/16 05:12:08 porting ship $ */
-- +==========================================================================+
-- | Copyright (c) 1993 Oracle Corporation Belmont, California, USA           |
-- |                          All rights reserved.                            |
-- +==========================================================================+
-- |                                                                          |
-- | File Name   : BOMDELTS.pls                                               |
-- | Description : Populate BOM_DELETE_ENTITIES and BOM_DELETE_SUB_ENTITIES   |
-- |               when called by BOMFDDEL (Item, BOM and Routing Delete Form |
-- |               under the following conditions:                            |
-- |               - called on return from Item Catalog Search                |
-- |               - Component or Routing Where Used request                  |
-- |               - Master Org to Child Org explosion                        |
-- |               - BOM and Routing explosion                                |
-- | Parameters  : org_id	organization_id                               |
-- |               err_msg	error message out buffer                      |
-- |               error_code	error code out. returns sql error code        |
-- |                         	if sql error.                                 |
-- | Revision                                                                 |
-- |  08-MAR-95	Anand Rajaraman	Creation                                      |
-- |  07-JUL-95 Anand Rajaraman Changes after Code Review (Shreyas Shah)      |
-- |                            Removed expiration_time (Calvin Siew)         |
-- +==========================================================================+

-- +------------------------------- POPULATE_DELETE --------------------------+

-- NAME
-- POPULATE_DELETE

-- DESCRIPTION
-- Populate BOM_DELETE_ENTITIES and BOM_DELETE_SUB_ENTITIES

-- REQUIRES
-- org_id: organization id
-- last_login_id
-- catalog_search_id: item catalog search id
-- component_id
-- delete_group_id
-- delete_type
-- "1" - ITEM
-- "2" - BOM
-- "3" - ROUTING
-- "4" - COMPONENT
-- "5" - OPERATION
-- "6" - BOM and ROUTING
-- "7" - ITEM/BOM and ROUTING
-- del_grp_type
-- "1" - Non-ENG items only
-- "2" - ENG items only
-- process_type
-- "1" - called from form
-- "2" - called from search region
-- expiration_date

-- OUTPUT

-- RETURNS

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE POPULATE_DELETE
(
org_id			IN NUMBER,
last_login_id		IN NUMBER DEFAULT -1,
catalog_search_id	IN NUMBER,
component_id		IN NUMBER,
delete_group_id		IN NUMBER,
delete_type		IN NUMBER,
del_grp_type		IN NUMBER,
process_type		IN NUMBER,
expiration_date		IN DATE);

END BOM_DELETE_ITEMS;

 

/
