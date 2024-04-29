--------------------------------------------------------
--  DDL for Package WMS_TASK_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_LOAD" AUTHID CURRENT_USER AS
/* $Header: WMSLOADS.pls 120.4.12010000.3 2010/03/26 09:53:31 kjujjuru ship $ */

TYPE lpn_lot_qty_rec IS RECORD(
    lpn_id         NUMBER
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  , lot_number     VARCHAR2(80)
  , pri_qty        NUMBER
  , trx_qty        NUMBER
  , sec_qty    NUMBER      -- Bug #4141928
  , non_alloc_qty  NUMBER   --jxlu 10/22/04 check serial ATT for allocated serial
  );


TYPE lpn_lot_qty_tb IS TABLE OF lpn_lot_qty_rec
    INDEX BY BINARY_INTEGER;

--  PL/SQL TABLE used to store lot_number and qty for passed in lpn_id

--/* Bug 9448490 Lot Substitution Project */ start
PROCEDURE populate_lot_lov(
    p_fromlpn_id            IN            NUMBER
  , p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot                   IN            VARCHAR2
  , p_trx_qty               IN            NUMBER
  , p_trx_uom               IN            VARCHAR2
  , x_match                 OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , p_temp_id               IN            NUMBER
  , p_transaction_type_id   IN            NUMBER
  , p_cost_group_id         IN            NUMBER
  , p_is_sn_alloc           IN            VARCHAR2
  , p_user_id               IN            NUMBER
  , x_lpn_lot_vector        OUT NOCOPY    VARCHAR2
  , p_transaction_action_id IN            NUMBER --BV TODO Add project and task inputs and put in SKU?
  , p_confirmed_sub         IN            VARCHAR2
  , p_confirmed_loc_id      IN            NUMBER
  , p_from_lpn_id           IN            NUMBER
  );

--/* Bug 9448490 Lot Substitution Project */ end

t_lpn_lot_qty_table lpn_lot_qty_tb;


PROCEDURE task_load(
               p_action                          IN            VARCHAR2
              -- LOAD_SINGLE/LOAD_MULTIPLE/SPLIT/UPDATE_LOADED
             , p_organization_id                 IN            NUMBER
             , p_user_id                         IN            NUMBER
             , p_person_id                       IN            NUMBER
             , p_transaction_header_id           IN            NUMBER
             , p_temp_id                         IN            NUMBER
             , p_parent_line_id                  IN            NUMBER    -- For bulk parent
             , p_lpn_id                          IN            NUMBER
             , p_content_lpn_id                  IN            NUMBER
             , p_transfer_lpn_id                 IN            NUMBER
             , p_confirmed_sub                   IN            VARCHAR2
             , p_confirmed_loc_id                IN            NUMBER
             , p_confirmed_uom                   IN            VARCHAR2
             , p_suggested_uom                   IN            VARCHAR2
             , p_primary_uom                     IN            VARCHAR2  -- 03/02/04
             , p_item_id                         IN            NUMBER
             , p_revision                        IN            VARCHAR2
             , p_confirmed_qty                   IN            NUMBER
             , p_confirmed_lots                  IN            VARCHAR2
             , p_confirmed_lot_trx_qty           IN            VARCHAR2
             , p_confirmed_sec_uom               IN            VARCHAR2
             , p_confirmed_sec_qty               IN            VARCHAR2
             , p_confirmed_serials               IN            VARCHAR2
             , p_container_item_id               IN            NUMBER
             , p_transaction_type_id             IN            NUMBER
             , p_transaction_source_type_id      IN            NUMBER
             , p_lpn_match                       IN            NUMBER
             , p_lpn_match_lpn_id                IN            NUMBER
             , p_serial_allocated_flag           IN            VARCHAR2  -- Y/V or NULL
             , p_lot_controlled                  IN            VARCHAR2  -- Y/N
             , p_serial_controlled               IN            VARCHAR2  -- Y/N
             , p_effective_start_date            IN            DATE
             , p_effective_end_date              IN            DATE
             , p_exception                       IN            VARCHAR2  -- SHORT, OVER
             , p_discrepancies                   IN            VARCHAR2
             , p_qty_rsn_id                      IN            NUMBER
             , p_parent_lpn_id                   IN            NUMBER
             , p_lpnpickedasis                   IN            VARCHAR2  -- Y/N
             , x_new_transaction_temp_id         OUT NOCOPY    NUMBER
             , x_cms_check                       OUT NOCOPY    VARCHAR2
             , x_return_status                   OUT NOCOPY    VARCHAR2
             , x_msg_count                       OUT NOCOPY    NUMBER
             , x_msg_data                        OUT NOCOPY    VARCHAR2
	     , p_substitute_lots		 IN            VARCHAR2); --/* Bug 9448490 Lot Substitution Project */

PROCEDURE task_merge_split(
               p_action                    IN            VARCHAR2  -- LOAD_MULTIPLE/LOAD_SINGLE/SPLIT
              ,p_exception                 IN            VARCHAR2  -- SHORT/OVER
              ,p_organization_id           IN            NUMBER
              ,p_user_id                   IN            NUMBER
              ,p_transaction_header_id     IN            NUMBER
              ,p_transaction_temp_id       IN            NUMBER
              ,p_parent_line_id            IN            NUMBER
              ,p_remaining_temp_id         IN            NUMBER
              ,p_lpn_id                    IN            NUMBER
              ,p_content_lpn_id            IN            NUMBER
              ,p_transfer_lpn_id           IN            NUMBER
              ,p_confirmed_sub             IN            VARCHAR2
              ,p_confirmed_locator_id      IN            NUMBER
              ,p_confirmed_uom             IN            VARCHAR2
              ,p_suggested_uom             IN            VARCHAR2
              ,p_primary_uom               IN            VARCHAR2  -- 03/02/04
              ,p_inventory_item_id         IN            NUMBER
              ,p_revision                  IN            VARCHAR2
              ,p_confirmed_trx_qty         IN            NUMBER
              ,p_confirmed_lots            IN            VARCHAR2
              ,p_confirmed_lot_trx_qty     IN            VARCHAR2
              ,p_confirmed_sec_uom         IN            VARCHAR2
              ,p_confirmed_sec_qty         IN            VARCHAR2
              ,p_confirmed_serials         IN            VARCHAR2
              ,p_container_item_id         IN            NUMBER
              ,p_lpn_match                 IN            NUMBER
              ,p_lpn_match_lpn_id          IN            NUMBER
              ,p_serial_allocated_flag     IN            VARCHAR2
              ,p_lot_controlled            IN            VARCHAR2  -- Y/N
              ,p_serial_controlled         IN            VARCHAR2  -- Y/N
              ,p_parent_lpn_id             IN            NUMBER
              ,x_new_transaction_temp_id   OUT NOCOPY    NUMBER
              ,x_cms_check                 OUT NOCOPY    VARCHAR2
              ,x_return_status             OUT NOCOPY    VARCHAR2
              ,x_msg_count                 OUT NOCOPY    NUMBER
              ,x_msg_data                  OUT NOCOPY    VARCHAR2
	      ,p_substitute_lots           IN            VARCHAR2); --/* Bug 9448490 Lot Substitution Project */

PROCEDURE process_F2(
               p_action                 IN            VARCHAR2  -- NULL/CMS
              ,p_organization_id        IN            NUMBER
              ,p_user_id                IN            NUMBER
              ,p_employee_id            IN            NUMBER
              ,p_transaction_header_id  IN            NUMBER
              ,p_transaction_temp_id    IN            NUMBER
              ,p_original_sub           IN            VARCHAR2
              ,p_original_locator_id    IN            NUMBER
              ,p_lot_controlled         IN            VARCHAR2  -- Y/N
              ,p_serial_controlled      IN            VARCHAR2  -- Y/N
              ,p_serial_allocated_flag  IN            VARCHAR2  -- Y/N
              ,p_suggested_uom          IN            VARCHAR2  -- original allocation UOM  -- 03/02/04
              ,p_start_over             IN            VARCHAR2  -- Y/Nstart_over button
              ,p_retain_task            IN            VARCHAR2 -- Y/N for bug 4310093
              ,x_start_over_taskno      OUT NOCOPY    NUMBER    -- start_over
              ,x_return_status          OUT NOCOPY    VARCHAR2
              ,x_msg_count              OUT NOCOPY    NUMBER
              ,x_msg_data               OUT NOCOPY    VARCHAR2) ;

-- This lpn will be used during the picking process. If the user specifies
  -- a from lpn, this procedure will figure out if the lpn in question will
  -- satisfy the pick in question
  -- It will return 1 if this is the case, 0 if not and 2 if the item does
  -- not exist in the lpn, 3 if the qty is not adequate and 4 if it already
  -- has been loaded

PROCEDURE lpn_match(
        p_fromlpn_id            IN            NUMBER
      , p_org_id                IN            NUMBER
      , p_item_id               IN            NUMBER
      , p_rev                   IN            VARCHAR2
      , p_lot                   IN            VARCHAR2
      , p_trx_qty               IN            NUMBER
      , p_trx_uom               IN            VARCHAR2
	  , p_sec_qty             IN            NUMBER     -- Bug #4141928
	  , p_sec_uom             IN            VARCHAR2   -- Bug #4141928
      , x_match                 OUT NOCOPY    NUMBER
      , x_sub                   OUT NOCOPY    VARCHAR2
      , x_loc                   OUT NOCOPY    VARCHAR2
      , x_trx_qty               OUT NOCOPY    NUMBER
	  , x_trx_sec_qty         OUT NOCOPY    NUMBER     -- Bug #4141928
      , x_return_status         OUT NOCOPY    VARCHAR2
      , x_msg_count             OUT NOCOPY    NUMBER
      , x_msg_data              OUT NOCOPY    VARCHAR2
      , p_temp_id               IN            NUMBER
      , p_parent_line_id        IN            NUMBER
      , p_wms_installed         IN            VARCHAR2
      , p_transaction_type_id   IN            NUMBER
      , p_cost_group_id         IN            NUMBER
      , p_is_sn_alloc           IN            VARCHAR2
      , p_action                IN            NUMBER
      , p_split                 IN            VARCHAR2
      , p_user_id               IN            NUMBER
      , x_temp_id               OUT NOCOPY    NUMBER
      , x_loc_id                OUT NOCOPY    NUMBER
      , x_lpn_lot_vector        OUT NOCOPY    VARCHAR2
      , x_cms_check             OUT NOCOPY    VARCHAR2
      , x_parent_lpn_id         OUT NOCOPY    VARCHAR2
      , x_trx_qty_alloc         OUT NOCOPY    NUMBER      --jxlu 10/12/04
      , p_transaction_action_id IN            NUMBER      --jxlu
      , p_pickOverNoException   IN            VARCHAR2
      , p_toLPN_Default         IN            VARCHAR2   -- Bug 3855835
      , p_project_id            IN            NUMBER
      , p_task_id               IN            NUMBER
      , p_confirmed_sub         IN            VARCHAR2
      , p_confirmed_loc_id      IN            NUMBER
      , p_from_lpn_id           IN            NUMBER
      , x_toLPN_status          OUT NOCOPY    VARCHAR2 --Bug 3855835
      , x_lpnpickedasis         OUT NOCOPY    VARCHAR2
      , x_lpn_qoh               OUT NOCOPY    NUMBER
      , p_changelotNoException  IN            VARCHAR2 --/* Bug 9448490 Lot Substitution Project */
  );

  --  during the picking process. If the user does not specifies
    -- a from lpn, this procedure will figure out if the loose quantity  will
    -- satisfy the pick in question, the temp table mtl_allocations_gtmp
   -- will store the available lot and serial numbers for this pick

    PROCEDURE loose_match(
          p_org_id              IN            NUMBER
        , p_item_id             IN            NUMBER
        , p_rev                 IN            VARCHAR2
        , p_trx_qty             IN            NUMBER
        , p_trx_uom             IN            VARCHAR2
        , p_pri_uom             IN            VARCHAR2
			, p_sec_uom             IN            VARCHAR2          -- Bug #4141928
			, p_sec_qty             IN            NUMBER				  -- Bug #4141928
        , p_temp_id             IN            NUMBER
        , p_suggested_locator   IN            NUMBER
        , p_confirmed_locator   IN            NUMBER
        , p_confirmed_sub       IN            VARCHAR2
        , p_is_sn_alloc         IN            VARCHAR2
        , p_is_revision_control IN            VARCHAR2
        , p_is_lot_control      IN            VARCHAR2
        , p_is_serial_control   IN            VARCHAR2
        , p_is_negbal_allowed   IN            VARCHAR2   --vikas 09/07/04 v1
        , p_toLPN_Default       IN            VARCHAR2   -- Bug 3855835
        , p_project_id          IN            NUMBER
        , p_task_id             IN            NUMBER
        , x_trx_qty             OUT NOCOPY    NUMBER
		  , x_trx_sec_qty         OUT NOCOPY    NUMBER				  -- Bug #4141928
        , x_return_status       OUT NOCOPY    VARCHAR2
        , x_msg_count           OUT NOCOPY    NUMBER
        , x_msg_data            OUT NOCOPY    VARCHAR2
        , x_toLPN_status        OUT NOCOPY    VARCHAR2 --Bug 3855835
        , x_lot_att_vector      OUT NOCOPY    VARCHAR2
        , x_trx_qty_alloc       OUT NOCOPY    NUMBER    -- jxlu 10/6/04
        , p_transaction_type_id IN            NUMBER -- Bug 4632519
        , p_transaction_action_id IN          NUMBER -- Bug 4632519
	, p_changelotNoException  IN            VARCHAR2  --/* Bug 9448490 Lot Substitution Project */
  );


  FUNCTION can_pickdrop(p_transaction_temp_id IN NUMBER)
    RETURN VARCHAR2;


  /* This API will return the number of tasks that still need to be performed
    for a given carton. If it returns more than 1, the user should not be
      allowed to drop off the carton*/
  PROCEDURE check_pack_lpn(
      p_lpn                IN            VARCHAR2
    , p_org_id             IN            NUMBER
    , p_container_item_id  IN             NUMBER
    , p_temp_id            IN             NUMBER --Bug7120019
    , x_lpn_id        OUT NOCOPY          NUMBER
    , x_lpn_context   OUT NOCOPY          NUMBER
    , x_outermost_lpn_id   OUT NOCOPY     NUMBER
    , x_pick_to_lpn_exists OUT NOCOPY     BOOLEAN
    , x_return_status OUT NOCOPY    VARCHAR2
    , x_msg_count     OUT NOCOPY    NUMBER
    , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  PROCEDURE validate_pick_to_lpn(
      p_api_version_number          IN            NUMBER
    , p_init_msg_lst                IN            VARCHAR2 := fnd_api.g_false
    , x_return_status               OUT NOCOPY    VARCHAR2
    , x_msg_count                   OUT NOCOPY    NUMBER
    , x_msg_data                    OUT NOCOPY    VARCHAR2
    , p_organization_id             IN            NUMBER
    , p_pick_to_lpn                 IN            VARCHAR2
    , p_temp_id                     IN            NUMBER
    , p_project_id                  IN            NUMBER := NULL
    , p_task_id                     IN            NUMBER := NULL
    , p_container_item              IN            VARCHAR2
    , p_container_item_id           IN            NUMBER
    , p_suggested_container_item    IN            VARCHAR2
    , p_suggested_container_item_id IN            NUMBER
    , p_suggested_carton_name       IN            VARCHAR2
    , p_suggested_tolpn_id          IN            NUMBER
    , x_pick_to_lpn_id              OUT   NOCOPY  NUMBER
    , p_inventory_item_id           IN            NUMBER
    , p_confirmed_sub               IN            VARCHAR2
    , p_confirmed_loc_id            IN            NUMBER
    , p_revision                    IN            VARCHAR2
    , p_confirmed_lots              IN            VARCHAR2
    , p_from_lpn_id                 IN            NUMBER
    , p_lot_control                 IN            VARCHAR2
    , p_revision_control            IN            VARCHAR2
    , p_serial_control              IN            VARCHAR2
    , p_trx_type_id                 IN            VARCHAR2 -- Bug 4632519
    , p_trx_action_id               IN            VARCHAR2 -- Bug 4632519
  );

  PROCEDURE validate_sub_loc_status(
      p_wms_installed    IN            VARCHAR2
    , p_temp_id          IN            NUMBER
    , p_confirmed_sub    IN            VARCHAR2
    , p_confirmed_loc_id IN            NUMBER
    , x_return_status    OUT NOCOPY    VARCHAR2
    , x_msg_count        OUT NOCOPY    NUMBER
    , x_msg_data         OUT NOCOPY    VARCHAR2
    , x_result           OUT NOCOPY    NUMBER
  );


  PROCEDURE insert_serial(
    p_serial_transaction_temp_id IN OUT NOCOPY NUMBER,
    p_organization_id            IN     NUMBER,
    p_item_id                    IN     NUMBER,
    p_revision                   IN     VARCHAR2,
    p_lot                        IN     VARCHAR2,
    p_transaction_temp_id        IN     NUMBER,
    p_created_by                 IN     NUMBER,
    p_from_serial                IN     VARCHAR2,
    p_to_serial                  IN     VARCHAR2,
    p_status_id                  IN     NUMBER := NULL,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  ) ;

END wms_task_load;

/
