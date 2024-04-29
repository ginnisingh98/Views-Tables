--------------------------------------------------------
--  DDL for Package Body INV_MATERIAL_STATUS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MATERIAL_STATUS_HOOK" AS
/* $Header: INVMSHKB.pls 120.0.12010000.2 2009/04/27 22:51:50 musinha noship $ */

   PROCEDURE validate_rsv_matstatus (p_old_status_id         IN mtl_material_statuses.status_id%TYPE,
                                     p_new_status_id         IN mtl_material_statuses.status_id%TYPE,
                                     p_subinventory_code     IN mtl_onhand_quantities_detail.subinventory_code%TYPE,
                                     p_locator_id            IN mtl_onhand_quantities_detail.locator_id%TYPE,
                                     p_organization_id       IN mtl_secondary_inventories.organization_id%TYPE,
                                     p_inventory_item_id     IN mtl_onhand_quantities_detail.inventory_item_id%TYPE,
                                     p_lot_number            IN mtl_onhand_quantities_detail.lot_number%TYPE,
                                     x_ret_status            IN OUT NOCOPY BOOLEAN) IS

      l_debug NUMBER;
   BEGIN

      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      IF (l_debug = 1) THEN
         inv_trx_util_pub.TRACE('Entered validate_rsv_matstatus', 'INV_MATERIAL_STATUS_HOOK', 9);
         IF (x_ret_status) THEN
           inv_trx_util_pub.TRACE('return status: TRUE', 'INV_MATERIAL_STATUS_HOOK', 9);
         ELSE
           inv_trx_util_pub.TRACE('return status: FALSE', 'INV_MATERIAL_STATUS_HOOK', 9);
         END IF;
      END IF;

      /* If a custom logic is put then set the x_ret_status accordingly. */
      ------------------------------------

      ------------------------------------

      IF (l_debug = 1 ) THEN
         IF (x_ret_status) THEN
           inv_trx_util_pub.TRACE('return status: TRUE', 'INV_MATERIAL_STATUS_HOOK', 9);
         ELSE
           inv_trx_util_pub.TRACE('return status: FALSE', 'INV_MATERIAL_STATUS_HOOK', 9);
         END IF;
         inv_trx_util_pub.TRACE('Exiting validate_rsv_matstatus', 'INV_MATERIAL_STATUS_HOOK', 9);
      END IF;

   EXCEPTION
      when others then
         null;
   END validate_rsv_matstatus;

END INV_MATERIAL_STATUS_HOOK;

/
