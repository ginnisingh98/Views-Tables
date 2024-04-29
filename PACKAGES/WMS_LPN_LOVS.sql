--------------------------------------------------------
--  DDL for Package WMS_LPN_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LPN_LOVS" AUTHID CURRENT_USER AS
/* $Header: WMSLPNLS.pls 120.4.12010000.4 2013/01/31 11:23:18 ssingams ship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_SOURCE_LOV
--
--      Input parameters:
--       p_lookup_type   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_source_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid source (context) from WMS_PREPACK_SOURCE
--                 in mfg_lookups
--

PROCEDURE GET_SOURCE_LOV(x_source_lov  OUT  NOCOPY t_genref  ,
		         p_lookup_type IN   VARCHAR2  );

--      Name: GET_LABEL_PICK_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id which can
--                 be used in picking by label
--

PROCEDURE GET_LABEL_PICK_LPN_LOV(x_lpn_lov  OUT  NOCOPY t_genref  ,
		      p_lpn      IN   VARCHAR2,
                      p_org_id   IN   NUMBER,
		      p_sub_code IN   VARCHAR2 DEFAULT NULL  );

--      Name: GET_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id
--

PROCEDURE GET_LPN_LOV(x_lpn_lov  OUT  NOCOPY t_genref  ,
                      p_lpn      IN   VARCHAR2  );

PROCEDURE GET_LPN_LOV(x_lpn_lov  OUT  NOCOPY t_genref  ,
                      p_lpn      IN   VARCHAR2 ,
                      p_orgid    IN   VARCHAR2 );

--      Name: GET_WHERE_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--       p_where_clause   pass a where clause
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id
--

PROCEDURE GET_WHERE_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2);

PROCEDURE GET_WHERE_PJM_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2);

PROCEDURE GET_PUTAWAY_WHERE_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id IN VARCHAR2
   );

-- Bug 2774506/2905646 : Added project_id and task_id to show LPN's belonging to PJM locators.
PROCEDURE GET_PICK_LOAD_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_cost_group_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL);

-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, containing the givn Item
PROCEDURE GET_ALL_APL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL);

-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, Sub, containing the givn Item
PROCEDURE GET_SUB_APL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL);


PROCEDURE validate_pick_load_lpn_lov
      (p_fromlpn              IN     VARCHAR2,
       p_organization_id      IN     NUMBER,
				   p_revision             IN     VARCHAR2,
				   p_inventory_item_id    IN     NUMBER,
				   p_cost_group_id        IN     NUMBER,
				   p_subinventory_code    IN     VARCHAR2,
				   p_locator_id           IN     NUMBER,
				   p_project_id           IN     NUMBER := NULL,
       p_task_id              IN     NUMBER := NULL,
       p_transaction_temp_id  IN     NUMBER,
       p_serial_allocated     IN     VARCHAR2,
       x_is_valid_fromlpn     OUT    NOCOPY  VARCHAR2,
       x_fromlpn_id           OUT    NOCOPY  NUMBER);

PROCEDURE GET_PICK_LOAD_TO_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2
   );

PROCEDURE validate_pick_load_to_lpn
							(p_tolpn      IN   VARCHAR2,
								x_is_valid_tolpn  OUT NOCOPY VARCHAR2,
								x_tolpn_id        OUT NOCOPY NUMBER
								);

PROCEDURE GET_PICK_DROP_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_pick_to_lpn_id    IN NUMBER,
   p_org_id            IN NUMBER,
   p_drop_sub          IN VARCHAR2,
   p_drop_loc          IN NUMBER
);
-- Added p_drop_sub and p_drop_loc to be passed to the drop LPN LOV --vipartha

PROCEDURE GET_WHERE_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2
   );


PROCEDURE GET_PICK_LOAD_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_cost_group_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_transaction_temp_id IN NUMBER
   );

-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, containing the givn Item
-- and allocated serials
PROCEDURE GET_ALL_APL_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_transaction_temp_id IN NUMBER
   );

-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, sub, containing the givn Item
-- and allocated serials
PROCEDURE GET_SUB_APL_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_transaction_temp_id IN NUMBER
   );


--      Name: GET_PHYINV_PARENT_LPN_LOV
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_dynamic_entry_flag      - determines whether or not dynamic
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing physical
--                                 - inventory tags are queried up.
--       p_physical_inventory_id   - current physical inventory ID
--       p_organization_id         - Organization that LPN's should be in
--       p_subinventory_code       - Subinventory that LPN's should be in
--       p_locator_id              - Locator that that LPN's should be in
--       p_project_id              - Project that LPN's should be in
--       p_task_id                 - Task that LPN's should be in
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid parent LPN's for use in
--                 physical inventory counting
--

PROCEDURE GET_PHYINV_PARENT_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_project_id             IN   NUMBER := NULL,
   p_task_id                IN   NUMBER := NULL
);


--      Name: GET_PHYINV_LPN_LOV
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_dynamic_entry_flag      - determines whether or not dynamic
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing physical
--                                 - inventory tags are queried up.
--       p_physical_inventory_id   - current physical inventory ID
--       p_organization_id         - Organization that LPN's should be in
--       p_subinventory_code       - Subinventory that LPN's should be in
--       p_locator_id              - Locator that that LPN's should be in
--       p_parent_lpn_id           - Parent LPN for which LPN's should be in
--       p_project_id              - Project that LPN's should be in
--       p_task_id                 - Task that LPN's should be in
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid children LPN's for use in
--                 physical inventory counting
--

PROCEDURE GET_PHYINV_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_parent_lpn_id          IN   NUMBER    ,
   p_project_id             IN   NUMBER := NULL,
   p_task_id                IN   NUMBER := NULL
);

--      Name: GET_PUP_LPN_LOV
--
--      Input parameters:
--       p_org_id      - Organization that LPN's should be in
--       p_sub         - Subinventory that LPN's should be in
--       p_loc_id      - Locator that that LPN's should be in
--       p_not_lpn_id  - the LPN to exclude in query (for merge and split LPN)
--       p_parent_lpn_id  - Parent LPN for which LPN's should be in.  If you want
--			  - want items with parent_lpn is null enter '0' as param
--       p_lpn	       - restricts LOV SQL to the user inputted text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid children LPN's for use in
--                 Pack Unpack functions
--

PROCEDURE GET_PUP_LPN_LOV(x_lpn_lov        OUT  NOCOPY t_genref         ,
			  p_org_id         IN   NUMBER           ,
			  p_sub            IN   VARCHAR2 := NULL ,
			  p_loc_id         IN   VARCHAR2 := NULL ,
			  p_not_lpn_id     IN   VARCHAR2 := NULL ,
			  p_parent_lpn_id  IN   VARCHAR2 := '0'  ,
			  p_lpn            IN   VARCHAR2
			  );
PROCEDURE GET_PKUPK_LPN_LOV(x_lpn_lov        OUT  NOCOPY t_genref         ,
			  p_org_id         IN   NUMBER           ,
			  p_sub            IN   VARCHAR2 := NULL ,
			  p_loc_id         IN   VARCHAR2 := NULL ,
			  p_not_lpn_id     IN   VARCHAR2 := NULL ,
			  p_parent_lpn_id  IN   VARCHAR2 := '0'  ,
			  p_txn_type_id    IN   NUMBER   := 0    ,
			  p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
			  p_lpn            IN   VARCHAR2,
			  p_context	   IN	NUMBER := 0,
                          p_project_id IN NUMBER := NULL,
                          p_task_id IN NUMBER := NULL,
			  p_mtrl_sts_check    IN   VARCHAR2 := 'Y', --Bug 3980914- Added the parameter
		          p_calling           IN   VARCHAR2 := NULL  -- Bug 7210544
			  );

/* WMS - PJM Integration Changes */
PROCEDURE GET_PUTAWAY_LPN_LOV(
                              x_lpn_lov        OUT  NOCOPY t_genref,
                	      p_org_id         IN   NUMBER,
                	      p_sub            IN   VARCHAR2 := NULL,
                	      p_loc_id         IN   VARCHAR2 := NULL,
                	      p_orig_lpn_id    IN   VARCHAR2 := NULL,
                	      p_lpn            IN   VARCHAR2,
                              p_project_id     IN   NUMBER   := NULL,
                              p_task_id        IN   NUMBER   := NULL,
                              p_lpn_context    IN   NUMBER   := NULL,
			      p_rcv_sub_only   IN   NUMBER  DEFAULT 2
                	      );

--      Name: CHILD_LPN_EXISTS
--
--      Input parameters:
--       p_lpn_id   - LPN ID to determine if it contains any child LPN's
--
--      Output parameters:
--       x_out      - output number  1 = Yes, 2 = No
--
--      Functions: This procedure returns a number indicating whether or
--                 not the given LPN ID contains any children
--

PROCEDURE CHILD_LPN_EXISTS(p_lpn_id  IN   NUMBER  ,
			   x_out     OUT  NOCOPY NUMBER
			   );

--      Name: VALIDATE_PHYINV_LPN
--
--      Input parameters:
--       p_lpn_id                  - LPN ID we are trying to validate
--       p_dynamic_entry_flag      - determines whether or not dynamic
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing physical
--                                 - inventory tags are queried up.
--       p_physical_inventory_id   - current physical inventory ID
--       p_organization_id         - Organization that LPN should be in
--       p_subinventory_code       - Subinventory that LPN should be in
--       p_locator_id              - Locator that that LPN should be in
--
--      Output parameters:
--       x_result                  - output result  1 = Yes, 2 = No
--
--      Functions: This procedure validates whether or not the given LPN
--                 along with the given inputs exists.  Used to manually
--                 call the same validations as in the GET_PHYINV_LPN_LOV
--                 procedure.

PROCEDURE VALIDATE_PHYINV_LPN
  (p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER);


--      Name: VALIDATE_CYCLECOUNT_LPN
--
--      Input parameters:
--       p_lpn_id                  - LPN ID we are trying to validate
--       p_unscheduled_entry       - determines whether or not unscheduled
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing cycle
--                                 - count entries are queried up.
--       p_cycle_count_header_id   - current cycle count header ID
--       p_organization_id         - Organization that LPN should be in
--       p_subinventory_code       - Subinventory that LPN should be in
--       p_locator_id              - Locator that that LPN should be in
--
--      Output parameters:
--       x_result                  - output result  1 = Yes, 2 = No
--
--      Functions: This procedure validates whether or not the given LPN
--                 along with the given inputs exists.  Used to manually
--                 call the same validations as in the GET_CYC_LPN_LOV
--                 procedure.

PROCEDURE VALIDATE_CYCLECOUNT_LPN
  (p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER);


--      Name: VALIDATE_LPN_AGAINST_ORG
--
--      Input parameters:
--       p_lpn_id                  - LPN ID we are trying to validate
--       p_organization_id         - Organization that LPN should be in
--
--      Output parameters:
--       x_result                  - output result  1 = Yes, 2 = No
--
--      Functions: This procedure validates whether or not the given LPN
--                 exists in the given org
--

PROCEDURE VALIDATE_LPN_AGAINST_ORG
  (p_lpn                    IN   VARCHAR2  ,
   p_organization_id        IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER);


TYPE LPN_RECORD IS RECORD
  (license_plate_number          VARCHAR2(30) ,
   lpn_id                        NUMBER       ,
   inventory_item_id             NUMBER       ,
   organization_id               NUMBER       ,
   revision                      VARCHAR2(3)  ,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   lot_number                    VARCHAR2(80) ,
   serial_number                 VARCHAR2(30) ,
   subinventory_code             VARCHAR2(10) ,
   locator_id                    NUMBER       ,
   parent_lpn_id                 NUMBER       ,
   sealed_status                 NUMBER       ,
   gross_weight_uom_code         VARCHAR2(3)  ,
   gross_weight                  NUMBER       ,
   content_volume_uom_code       VARCHAR2(3)  ,
   content_volume                NUMBER);

--      Name: GET_LPN_VALUES
--
--      Input parameters:
--       p_lpn_id                  - LPN ID we are trying to retrieve info for
--       p_organization_id         - Organization that LPN is in
--
--      Output parameters:
--       x_license_plate_number    -
--       x_lpn_id                  -
--       x_inventory_item_id       -
--       x_organization_id         -
--       x_revision                -
--       x_lot_number              -
--       x_serial_number           -
--       x_subinventory_code       -
--       x_locator_id              -
--       x_parent_lpn_id           -
--       x_sealed_status           -
--       x_gross_weight_uom_code   -
--       x_gross_weight            -
--       x_content_volume_uom_code -
--       x_content_volume          -
--
--      Functions: This procedure retrieves the LPN information for a given
--                 LPN value.  This is used in the mobile forms to manually
--                 populate the values in an LPN LOV field bean.
--

PROCEDURE GET_LPN_VALUES
  (p_lpn                      IN   VARCHAR2  ,
   p_organization_id          IN   NUMBER    ,
   x_license_plate_number     OUT  NOCOPY VARCHAR2  ,
   x_lpn_id                   OUT  NOCOPY NUMBER    ,
   x_inventory_item_id        OUT  NOCOPY NUMBER    ,
   x_organization_id          OUT  NOCOPY NUMBER    ,
   x_revision                 OUT  NOCOPY VARCHAR2  ,
   x_lot_number               OUT  NOCOPY VARCHAR2  ,
   x_serial_number            OUT  NOCOPY VARCHAR2  ,
   x_subinventory_code        OUT  NOCOPY VARCHAR2  ,
   x_locator_id               OUT  NOCOPY NUMBER    ,
   x_parent_lpn_id            OUT  NOCOPY NUMBER    ,
   x_sealed_status            OUT  NOCOPY NUMBER    ,
   x_gross_weight_uom_code    OUT  NOCOPY VARCHAR2  ,
   x_gross_weight             OUT  NOCOPY NUMBER    ,
   x_content_volume_uom_code  OUT  NOCOPY VARCHAR2  ,
   x_content_volume           OUT  NOCOPY NUMBER);

--      Name: GET_INSPECT_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id whose contents have to be inspected
--		   by Inspection Moboile form
--

PROCEDURE GET_INSPECT_LPN_LOV(
  x_lpn_lov  OUT  NOCOPY t_genref
, p_lpn      IN   VARCHAR2
, p_organization_id IN NUMBER  );



--
--      Name: GET_MO_LPN
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_inv_item_id             - Inventory Item Id
--       p_organization_id         - Organization that LPN's should be in
--       p_subinventory_code       - Subinventory that LPN's should be in
--       p_locator_id              - Locator that that LPN's should be in
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid parent LPN's for use in
--                 physical inventory counting
--
PROCEDURE GET_MO_LPN
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_inv_item_id            IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_qty                    IN   NUMBER );


--
--      Name: GET_VENDOR_LPN
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_shipment_header_id      - shipment header id
--
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid  vendor LPN's for a given shipment
--
--      Nested LPN changes
--      p_mode will have two values
--      1. 'E' -- This means the page is called from Express Page.
--                If the Lov is called for express page then show
--                Check are there any existing Unprocessed RTI records
--                For It, This is because In Exprss Page If user pressed
--                <NextLPN> button, by this time we would not have processed
--                the LPN, so we should not show the same LPN again
--      2. 'C' -- This means the page is called from confirm page.
--                If the page is called from confirm page then show LPNs
--                with immediate contents, and do not show empty LPNs.
--
PROCEDURE GET_VENDOR_LPN
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_shipment_header_id     IN   VARCHAR2  ,
   p_mode                   IN   VARCHAR2 DEFAULT NULL,
   p_inventory_item_id      IN   VARCHAR2 DEFAULT NULL
   );

--      Name: GET_ITEM_LPN_LOV
--
--      Input parameters:
--       p_organization_id     restricts LOV SQL to the user input
--       p_lot_number          restricts LOV SQL to the user input
--       p_inventory_item_id   restricts LOV SQL to the user input
--       p_revision            restricts LOV SQL to the user input
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor

PROCEDURE GET_ITEM_LPN_LOV
              (x_lpn_lov                       OUT  NOCOPY t_genref,
               p_organization_id               IN   NUMBER,
               p_lot_number                    IN   VARCHAR2,
               p_inventory_item_id             IN   NUMBER,
               p_revision                      IN   VARCHAR2,
               p_lpn                           IN   VARCHAR2);

--      Name: GET_LOT_LPN_LOV
--
--      Input parameters:
--       p_organization_id         - Organization that LPNs should be in
--       p_lpn                     - restricts LOV SQL to the user input
--
--      Output parameters:
--       x_lpn_lov                 - returns LOV rows as reference cursor
--
--      Functions: This API returns LPNs for use in the result page of Lot Transactions.

PROCEDURE GET_LOT_LPN_LOV
  (x_lpn_lov           OUT  NOCOPY t_genref,
   p_organization_id   IN   NUMBER,
   p_lpn               IN   VARCHAR2);


PROCEDURE GET_RCV_LPN
  (x_lpn_lov      OUT  NOCOPY t_genref,
   p_org_id       IN   NUMBER,
   p_lpn          IN   VARCHAR2,
   p_from_lpn_id  IN   VARCHAR2,
   p_project_id   IN   NUMBER,
   p_task_id      IN   NUMBER
   );


--      Name: GET_CYC_PARENT_LPN_LOV
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_unscheduled_entry       - determines whether or not unscheduled
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing cycle count
--                                 - entries are queried up.
--       p_cycle_count_header_id   - current cycle count header ID
--       p_organization_id         - Organization that LPN's should be in
--       p_subinventory_code       - Subinventory that LPN's should be in
--       p_locator_id              - Locator that that LPN's should be in
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid parent LPN's for use in
--                 cycle counting
--

PROCEDURE GET_CYC_PARENT_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_project_id             IN   NUMBER    ,
   p_task_id                IN   NUMBER    );


--      Name: GET_CYC_LPN_LOV
--
--      Input parameters:
--       p_lpn   - restricts LOV SQL to the user inputted text
--       p_unscheduled_entry       - determines whether or not unscheduled
--                                 - entries are allowed.  if not allowed,
--                                 - then only those LPN's that are
--                                 - associated WITH existing cycle count
--                                 - entries are queried up.
--       p_cycle_count_header_id   - current cycle count header ID
--       p_organization_id         - Organization that LPN's should be in
--       p_subinventory_code       - Subinventory that LPN's should be in
--       p_locator_id              - Locator that that LPN's should be in
--       p_parent_lpn_id           - Parent LPN for which LPN's should be in
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid children LPN's for use in
--                 cycle counting
--

PROCEDURE GET_CYC_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_parent_lpn_id          IN   NUMBER    ,
   p_project_id             IN   NUMBER    ,
   p_task_id                IN   NUMBER    );

--      Name: GET_CGUPDATE_LPN
--
--      Input parameters:
--       p_org_id                  - Organization that LPNs should be in
--       p_lpn                     - restricts LOV SQL to the user inputted text
--
--      Output parameters:
--       x_lpn_lov                 - returns LOV rows as reference cursor
--
--      Functions: This API returns onhand LPNs for use in the cost group
--                 update UI
PROCEDURE GET_CGUPDATE_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2);

--      Name: GET_PALLET_LPN_LOV
--
--      Input parameters:
--       p_org_id     		 restricts LOV SQL to the user input
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
PROCEDURE GET_PALLET_LPN_LOV(x_lpn_lov OUT NOCOPY t_genref,
		             p_org_id IN NUMBER,
		             p_lpn VARCHAR2
		             );


-- procedure to get the information for a LPN
PROCEDURE CHECK_LPN_LOV
    (		p_lpn			IN  VARCHAR2,
		p_organization_id	IN  NUMBER,
 		x_lpn_id		OUT NOCOPY NUMBER,
		x_inventory_item_id	OUT NOCOPY NUMBER,
		x_organization_id	OUT NOCOPY NUMBER,
         	x_lot_number		OUT NOCOPY VARCHAR2,
		x_revision		OUT NOCOPY VARCHAR2,
		x_serial_number		OUT NOCOPY VARCHAR2,
		x_subinventory		OUT NOCOPY VARCHAR2,
		x_locator_id		OUT NOCOPY NUMBER,
		x_parent_lpn_id		OUT NOCOPY NUMBER,
		x_sealed_status		OUT NOCOPY NUMBER,
		x_gross_weight  	OUT NOCOPY NUMBER,
		x_gross_weight_uom_code	OUT NOCOPY VARCHAR2,
		x_content_volume	OUT NOCOPY NUMBER,
		x_content_volume_uom_code OUT NOCOPY VARCHAR2,
		x_source_type_id	OUT NOCOPY NUMBER,
		x_source_header_id	OUT NOCOPY NUMBER,
		x_source_name		OUT NOCOPY VARCHAR2,
		x_source_line_id	OUT NOCOPY NUMBER,
		x_source_line_detail_id	OUT NOCOPY NUMBER,
		x_cost_group_id		OUT NOCOPY NUMBER,
		x_newLPN 		OUT NOCOPY VARCHAR2,
		x_concat_segments       OUT NOCOPY VARCHAR2,
                x_context               OUT NOCOPY VARCHAR2,
		x_return_status         OUT NOCOPY VARCHAR2,
		x_msg_data              OUT NOCOPY VARCHAR2,
		p_createnewlpn_flag     IN  VARCHAR2
    );

/**********************************************************************************
                        WMS - PJM Integration Enhancements
   Differences from CHECK_LPN_LOV
    1. Returns the locator concatenated segments without SEGMENT19 and SEGMENT20.
    2. Returns the Project ID, Project Number, Task ID and Task Number associated
       with the locator.
**********************************************************************************/

PROCEDURE CHECK_PJM_LPN_LOV
(
      p_lpn                      IN  VARCHAR2,
      p_organization_id          IN  NUMBER,
      x_lpn_id                   OUT NOCOPY NUMBER,
      x_inventory_item_id        OUT NOCOPY NUMBER,
      x_organization_id          OUT NOCOPY NUMBER,
      x_lot_number               OUT NOCOPY VARCHAR2,
      x_revision                 OUT NOCOPY VARCHAR2,
      x_serial_number            OUT NOCOPY VARCHAR2,
      x_subinventory             OUT NOCOPY VARCHAR2,
      x_locator_id               OUT NOCOPY NUMBER,
      x_parent_lpn_id            OUT NOCOPY NUMBER,
      x_sealed_status            OUT NOCOPY NUMBER,
      x_gross_weight             OUT NOCOPY NUMBER,
      x_gross_weight_uom_code    OUT NOCOPY VARCHAR2,
      x_content_volume           OUT NOCOPY NUMBER,
      x_content_volume_uom_code  OUT NOCOPY VARCHAR2,
      x_source_type_id           OUT NOCOPY NUMBER,
      x_source_header_id         OUT NOCOPY NUMBER,
      x_source_name              OUT NOCOPY VARCHAR2,
      x_source_line_id           OUT NOCOPY NUMBER,
      x_source_line_detail_id    OUT NOCOPY NUMBER,
      x_cost_group_id            OUT NOCOPY NUMBER,
      x_newLPN                   OUT NOCOPY VARCHAR2,
      x_concat_segments          OUT NOCOPY VARCHAR2,
      x_project_id               OUT NOCOPY VARCHAR2,
      x_project_number           OUT NOCOPY VARCHAR2,
      x_task_id                  OUT NOCOPY VARCHAR2,
      x_task_number              OUT NOCOPY VARCHAR2,
      x_context                  OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_createnewlpn_flag        IN  VARCHAR2
);

-- procedure to get lpns based on lpn context if context
-- is left blank assumes all contexts are valid
PROCEDURE GET_CONTEXT_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_organization_id IN   NUMBER,
   p_context	IN VARCHAR2,
   p_lpn      IN   VARCHAR2
);

--"Returns"
-- procedure to get lpns that have atleast one Content
-- record as 'To Return'
PROCEDURE GET_RETURN_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2
);
--"Returns"

-- procedure to get the lpns shipped for an internal order.
PROCEDURE GET_REQEXP_LPN (
                                x_lpn_lov                       OUT NOCOPY t_genref,
                                p_lpn                           IN  VARCHAR2 ,
                                p_requisition_header_id         IN VARCHAR2 ,
                                p_mode                          IN VARCHAR2 DEFAULT NULL,
                                p_inventory_item_id             IN   VARCHAR2 DEFAULT NULL
                         );


-- procedure to get lpns available for update
PROCEDURE GET_UPDATE_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2);

PROCEDURE GET_BULK_PACK_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2,
   p_subinventory IN VARCHAR2,
   p_locator      IN NUMBER
);

-- Start of comments
--  API name: Get_Picked_Split_From_LPNs
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns a list of Staged (Picked) LPNs along with
--            the delivery_detail_id in WSH_DELIVERY_DETAILS for
--            that particular LPN.  Used in Oubound LPN Split Page
--            for the From LPN field
--  Parameters:
--  IN: p_organization_id       IN NUMBER   Required
--        Organization ID where the LPN resides
--      p_lpn_id                IN VARCHAR2 Required
--        Partial string value to limit search results
-- OUT: x_order_lov             OUT NOCOPY T_GENREF
--        Standard LOV out parameter
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_Picked_Split_From_LPNs(
  x_lpn_lov          OUT  NOCOPY t_genref
, p_organization_id  IN          NUMBER
, p_lpn_id           IN          VARCHAR2
);

--RTV Change 16197273
--New navigation is created for split,under Inbound flow.
--Created new prceedures for from and to_lpn fields specific for RTV ER.

PROCEDURE Get_Return_Split_From_LPNs(
  x_lpn_lov         OUT NOCOPY t_genref
, p_organization_id IN         NUMBER
, p_lpn_id          IN         VARCHAR2
);

PROCEDURE Get_Return_Split_To_LPNs(
  x_lpn_lov         OUT NOCOPY t_genref
, p_organization_id IN         NUMBER
, p_lpn_id          IN         VARCHAR2
);


--function to check if a sub is LPN Controlled
FUNCTION SUB_LPN_CONTROLLED(p_subinventory_code IN VARCHAR2,
                            p_org_id IN NUMBER)
RETURN VARCHAR2;


--      Name: GET_ITEM_LOAD_LPN_LOV
--
--      Input parameters:
--       p_organization_id         - Organization that LPN's should be in
--       p_lpn_id                  - Source LPN ID we are loading material from
--       p_lpn_context             - LPN context of source LPN
--       p_employee_id             - Employee ID of person loading the material
--       p_into_lpn                - Restricts Into LOV SQL to the user inputted text
--
--      Output parameters:
--       x_lpn_lov      Returns LOV rows as reference cursor
--
--      Functions: This API returns valid Into LPN's for use in
--                 Inbound Item Load for putaway as part of a
--                 patchset J project.
--
PROCEDURE get_item_load_lpn_lov
  (x_lpn_lov              OUT   NOCOPY t_genref   ,
   p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_lpn_context          IN    NUMBER            ,
   p_employee_id          IN    NUMBER            ,
   p_into_lpn             IN    VARCHAR2);


PROCEDURE get_from_gtmp_lov
  (x_lpn_lov              OUT   NOCOPY t_genref   ,
   p_organization_id      IN    NUMBER            ,
   p_drop_type            IN    VARCHAR2          ,
   p_lpn_name             IN    VARCHAR2
   );


-- procedure to get lpns which have innerLPNs and suitable
-- for LPN-merge/LPN-break
PROCEDURE GET_RECONFIG_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2);

-- Procedure to get lpns in status 5 and 1 for the org, sub,locator combination. For bug 6708036
 PROCEDURE GET_PICK_DROP_SUBXFR_LPN_LOV
   ( x_lpn_lov         OUT NOCOPY  t_genref
   , p_lpn             IN          VARCHAR2
   , p_pick_to_lpn_id  IN          NUMBER
   , p_org_id          IN          NUMBER
   , p_drop_sub        IN          VARCHAR2
   , p_drop_loc        IN          NUMBER
   );

END WMS_LPN_LOVS;

/
