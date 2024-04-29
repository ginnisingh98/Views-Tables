--------------------------------------------------------
--  DDL for Package EGO_IMPORT_USER_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_USER_HOOKS" AUTHID CURRENT_USER AS
/* $Header: EGOIMUHS.pls 120.0.12010000.2 2009/08/25 05:55:20 mshirkol noship $ */

 /*-------------------------------------------------+
 | Record name : ITEM_INTERFACE_REC                 |
 | description : Record to assign interface rec     |
 |               values                             |
 |                                                  |
 *--------------------------------------------------*/
 TYPE ITEM_INTERFACE_REC IS RECORD
  ( org_id           NUMBER,
    set_process_id   NUMBER,
    request_id       NUMBER,
    commit_flag      NUMBER
  );

 /*-------------------------------------------------+
 | Procedure : Default_LC_and_Item_Status           |
 | description : User hook procedure to allow       |
 |               customers to default Lifecycle,    |
 |               Lifecycle phase and Item status    |
 *--------------------------------------------------*/

  PROCEDURE Default_LC_and_Item_Status
  (
   ERRBUF  OUT NOCOPY VARCHAR2,
   RETCODE OUT NOCOPY VARCHAR2,
   p_item_interface_rec IN EGO_IMPORT_USER_HOOKS.ITEM_INTERFACE_REC
  );

END EGO_IMPORT_USER_HOOKS;

/
