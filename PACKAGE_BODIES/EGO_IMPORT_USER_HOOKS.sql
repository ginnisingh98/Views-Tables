--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_USER_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_USER_HOOKS" AS
/* $Header: EGOIMUHB.pls 120.0.12010000.1 2009/08/25 05:50:37 mshirkol noship $ */

  PROCEDURE Default_LC_and_Item_Status
  (
    ERRBUF  OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    p_item_interface_rec IN EGO_IMPORT_USER_HOOKS.ITEM_INTERFACE_REC
  ) IS

  BEGIN

   -- Customer's can write custom code to update
   -- mtl_systems_items_interface table with
   -- default Lifecycle, Lifecycle phase and Item Status.

   null;

  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := 'Error in method EGO_IMPORT_USER_HOOKS.Default_LC_and_Item_Status - '||SQLERRM;
  END Default_LC_and_Item_Status;


END EGO_IMPORT_USER_HOOKS;

/
