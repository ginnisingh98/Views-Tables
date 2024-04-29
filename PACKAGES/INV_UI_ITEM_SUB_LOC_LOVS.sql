--------------------------------------------------------
--  DDL for Package INV_UI_ITEM_SUB_LOC_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_ITEM_SUB_LOC_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVITPSS.pls 120.10.12010000.3 2009/10/27 18:37:35 mchemban ship $ */

  TYPE t_genref IS REF CURSOR;

  --      Name: GET_SUB_LOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_sub   which restricts LOV SQL to the user input text
  --                                e.g.  FG%
  --       p_item_id      restrict to those item restricted sub
  --       p_restrict_subinventories_code
  --
  --      Output parameters:
  --       x_sub      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return subinventory for RECEIVING transaction only
  --                 It returns different LOV for item-restricted sub
  --

  PROCEDURE get_sub_lov_rcv(x_sub OUT NOCOPY t_genref
                            , p_organization_id IN NUMBER
                            , p_item_id IN NUMBER
                            , p_sub IN VARCHAR2
                            , p_restrict_subinventories_code IN NUMBER
                            , p_transaction_type_id IN NUMBER
                            , p_wms_installed IN VARCHAR2
                            , p_location_id IN NUMBER DEFAULT NULL
                            , p_lpn_context IN NUMBER DEFAULT NULL
			    , p_putaway_code IN NUMBER DEFAULT NULL
			    );

  --      Name: GET_MO_FROMSUB_LOV
  --
  --      Input parameters:
  --       p_organization_id OrgId
  --       p_MOheader_id     MoveOrder HeaderId
  --       p_subinv_code     SunInv Code
  --
  --      Output parameters:
  --       x_fromsub_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --
  PROCEDURE get_mo_fromsub_lov(x_fromsub_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_subinv_code IN VARCHAR);

  --      Name: GET_MO_TOSUB_LOV
  --
  --      Input parameters:
  --       p_organization_id OrgId
  --       p_MOheader_id     MoveOrder HeaderId
  --       p_subinv_code     SunInv Code
  --
  --      Output parameters:
  --       x_tosub_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --
  PROCEDURE get_mo_tosub_lov(x_tosub_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_subinv_code IN VARCHAR);

  --      Name: GET_LOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  1-1%
  --       p_Inventory_item_id      restrict to those item restricted locators
  --       p_Subinventory_Code      restrict to this sub
  --       p_restrict_Locators_code  item restricted locator flag
  --
  --      Output parameters:
  --       x_sub      returns LOV rows as reference cursor
  --
  --      Functions: This API is to returns locator for given org and sub
  --                 It returns different LOVs for item-restricted locator
  --
  PROCEDURE get_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  );

  --      Name: GET_LOC_LOV_PJM
  --
  --      Input parameters:
  --       p_Organization_Id         restrict LOV SQL to current org
  --       p_Concatenated_Segments   restrict LOV SQL to the user input text
  --                                 e.g.  1-1%
  --       p_Inventory_item_id       restrict to those item restricted locators
  --       p_Subinventory_Code       restrict to this sub
  --       p_restrict_Locators_code  item restricted locator flag
  --
  --      Output parameters:
  --       x_sub      returns Physical LOV rows as reference cursor
  --                  The concatenated segments being returned in the cursor doesnt
  --                  contain SEGMENT 19 and 20.
  --
  --      Functions: This API is to return locator for given org and sub
  --                 without Segment 19 and 20.
  --                 It returns different LOVs for item-restricted locator
  --
  PROCEDURE get_loc_lov_pjm(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  );

  -- This returns the locator id for an existing locator and if
  -- it does not exist then it creates a new one.
  PROCEDURE get_dynamic_locator(x_location_id OUT NOCOPY NUMBER, x_description OUT NOCOPY VARCHAR2, x_result OUT NOCOPY VARCHAR2, x_exist_or_create OUT NOCOPY VARCHAR2, p_org_id IN NUMBER, p_sub_code IN VARCHAR2, p_concat_segs IN VARCHAR2);

  -- This validates a locator
  PROCEDURE check_dynamic_locator(x_result OUT NOCOPY VARCHAR2, p_org_id IN NUMBER, p_sub_code IN VARCHAR2, p_inventory_location_id IN VARCHAR2);

  --
  --
  ----------------------------------
  --  Name:  GET_INQ_LOC_LOV
  --         To query locators of a sub and org without status check
  --         filtered on project and task
  --  Input Parameter:
  --    p_organization_id: Organization ID
  --    p_concatenated_segments  LOV
  --    p_Inventory_item_id   Item ID
  --    p_subinventory_code   Sub
  --    p_restrict_location_code   locator restriction code
  --
  PROCEDURE get_inq_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_project_id             IN     NUMBER := NULL
  , p_task_id                IN     NUMBER := NULL
  );
  PROCEDURE get_inq_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_project_id             IN     NUMBER := NULL
  , p_task_id                IN     NUMBER := NULL
  , p_alias                  IN     VARCHAR2
  );

  -------------------------------------------------
  PROCEDURE get_valid_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  );

  --      Name: GET_MO_FROMLOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  1-1%
  --
  --      Output parameters:
  --       x_Locators      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return "src" locator for a given MO
  --
  PROCEDURE get_mo_fromloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_project_id IN NUMBER := NULL, p_task_id IN NUMBER := NULL);

  PROCEDURE get_mo_fromloc_lov(
            x_locators OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_moheader_id IN NUMBER,
            p_concatenated_segments IN VARCHAR2,
            p_project_id IN NUMBER := NULL,
            p_task_id IN NUMBER := NULL,
            p_alias IN VARCHAR2
            );
  --      Name: GET_MO_TOLOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  1-1%
  --
  --      Output parameters:
  --       x_sub      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return "destination" locator for a given MO
  --
  PROCEDURE get_mo_toloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_project_id IN NUMBER := NULL, p_task_id IN NUMBER := NULL);

  /**kkoothan*** Added two new default null parameters viz   ***/
  /***** Project_id and Task_id to the procedure.            ***/
  PROCEDURE get_loc_with_status(x_locators OUT NOCOPY t_genref,
                                p_organization_id IN NUMBER,
                                p_subinventory_code IN VARCHAR2,
                                p_concatenated_segments IN VARCHAR2,
                                p_project_id IN NUMBER DEFAULT NULL, -- PJM-WMS Integration
                                p_task_id IN NUMBER DEFAULT NULL); -- PJM-WMS Integration);
  PROCEDURE get_loc_with_status(
            x_locators OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_subinventory_code IN VARCHAR2,
            p_concatenated_segments IN VARCHAR2,
            p_project_id IN NUMBER DEFAULT NULL, -- PJM-WMS Integration
            p_task_id IN NUMBER DEFAULT NULL,-- PJM-WMS Integration);
            p_alias IN VARCHAR2
            );

  PROCEDURE get_from_subs(
    x_zones                        OUT    NOCOPY t_genref
  , p_organization_id              IN     NUMBER
  , p_inventory_item_id            IN     NUMBER
  , p_restrict_subinventories_code IN     NUMBER
  , p_secondary_inventory_name     IN     VARCHAR2
  , p_transaction_action_id        IN     NUMBER
  , p_transaction_type_id          IN     NUMBER
  , p_wms_installed                IN     VARCHAR2
  );

  PROCEDURE get_to_sub(
    x_to_sub                       OUT    NOCOPY t_genref
  , p_organization_id              IN     NUMBER
  , p_inventory_item_id            IN     NUMBER
  , p_from_secondary_name          IN     VARCHAR2
  , p_restrict_subinventories_code IN     NUMBER
  , p_secondary_inventory_name     IN     VARCHAR2
  , p_from_sub_asset_inventory     IN     VARCHAR2
  , p_transaction_action_id        IN     NUMBER
  , p_to_organization_id           IN     NUMBER
  , p_serial_number_control_code   IN     NUMBER
  , p_transaction_type_id          IN     NUMBER
  , p_wms_installed                IN     VARCHAR2
  );

  PROCEDURE get_valid_subs(x_zones OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2);

  PROCEDURE get_valid_subinvs(x_zones OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_txn_type_id IN NUMBER := 0, p_wms_installed IN VARCHAR2 := 'TRUE');

  FUNCTION check_loc_existence(p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2)
    RETURN NUMBER;

  PROCEDURE get_sub_with_loc(x_zones OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2);

  PROCEDURE get_sub_lov_ship(x_sub_lov OUT NOCOPY t_genref, p_txn_dock IN VARCHAR2, p_organization_id IN NUMBER, p_dock_appointment_id IN NUMBER, p_sub IN VARCHAR2);

  PROCEDURE get_to_xsubs(x_to_xsubs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2);

  --      Name: GET_PHYINV_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_all_sub_flag          - all subinventories flag which indicates
  --                                 whether all the subs associated with the
  --                                 org are used or only those that are defined
  --                                 for that particular physical inventory
  --       p_physical_inventory_id - The physical inventory for which we are
  --                                 querying up the subs for
  --
  --
  --      Output parameters:
  --       x_phy_inv_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with a
  --                 physical inventory
  --
  PROCEDURE get_phyinv_subs(x_phy_inv_sub_lov OUT NOCOPY t_genref, p_subinventory_code IN VARCHAR2, p_organization_id IN NUMBER, p_all_sub_flag IN NUMBER, p_physical_inventory_id IN NUMBER);

  --      Name: GET_PHYINV_LOCS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts LOV to the current subinventory
  --       p_concatenated_segments - restricts the locator to those that are
  --                                 similar to the user inputted text.
  --                                 locators are a key flex field so this
  --                                 is how the user represents/identifies locators
  --       p_dynamic_entry_flag    - this flag determines whether or not
  --                                 dynamic tag entries are allowed
  --       p_physical_inventory_id - The physical inventory for which we are
  --                                 querying up the locators for
  --
  --       p_project_id              Restricts the locators for this project
  --
  --       p_task_id                 Restricts the locators for this task
  --
  --      Output parameters:
  --       x_locators       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid locators associated with a
  --                 physical inventory
  --
  PROCEDURE get_phyinv_locs(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_project_id            IN     NUMBER := NULL
  , p_task_id               IN     NUMBER := NULL
  );

  PROCEDURE get_phyinv_locs(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_project_id            IN     NUMBER := NULL
  , p_task_id               IN     NUMBER := NULL
  , p_alias                 IN     VARCHAR2
  );

  --      Name: GET_CYC_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_orientation_code      - orientation code which indicates
  --                                 whether all the subs associated with the
  --                                 org are used or only those that are defined
  --                                 for that particular cycle count
  --       p_cycle_count_header_id - The physical inventory for which we are
  --                                 querying up the subs for
  --
  --
  --      Output parameters:
  --       x_cyc_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with a
  --                 cycle count
  --
  PROCEDURE get_cyc_subs(x_cyc_sub_lov OUT NOCOPY t_genref, p_subinventory_code IN VARCHAR2, p_organization_id IN NUMBER, p_orientation_code IN NUMBER, p_cycle_count_header_id IN NUMBER);

--      Patchset I: WMS-PJM Integration
--      Name: GET_CYC_LOCS
--
--      Input parameters:
--       p_organization_id       - restricts LOV SQL to current org
--       p_subinventory_code     - restricts LOV to the current subinventory
--       p_concatenated_segments - restricts the locator to those that are
--                                 similar to the user inputted text.
--                                 locators are a key flex field so this
--                                 is how the user represents/identifies locators
--       p_unscheduled_entry     - this flag determines whether or not
--                                 unscheduled count entries are allowed
--       p_cycle_count_header_id - The cycle count header for which we are
--                                 querying up the locators for.
--       p_project_id            - restrict LOV SQL to this Project Id
--       p_task_id               - restrict LOV SQL to this Task Id
--
--
--      Output parameters:
--       x_locators       - Returns LOV rows as reference cursor
--
--      Functions: This API returns the valid locators associated with a
--                 cycle count
--
PROCEDURE GET_CYC_LOCS(x_locators     OUT  NOCOPY t_genref  ,
                       p_organization_id        IN   NUMBER    ,
                       p_subinventory_code      IN   VARCHAR2  ,
                       p_concatenated_segments  IN   VARCHAR2  ,
                       p_unscheduled_entry      IN   NUMBER    ,
                       p_cycle_count_header_id  IN   NUMBER  ,
                       p_project_id             IN   NUMBER DEFAULT NULL ,
                       p_task_id                           IN   NUMBER DEFAULT NULL);

PROCEDURE GET_CYC_LOCS(
          x_locators     OUT  NOCOPY t_genref  ,
          p_organization_id        IN   NUMBER    ,
          p_subinventory_code      IN   VARCHAR2  ,
          p_concatenated_segments  IN   VARCHAR2  ,
          p_unscheduled_entry      IN   NUMBER    ,
          p_cycle_count_header_id  IN   NUMBER  ,
          p_project_id             IN   NUMBER DEFAULT NULL ,
          p_task_id                IN   NUMBER DEFAULT NULL ,
          p_alias                  IN   VARCHAR2
          );
  -- Consignment and VMI Changes: Added Planning Org, TP Type, Owning Org and TP Type.
  PROCEDURE get_valid_lpn_org_level(
    x_lpns             OUT    NOCOPY t_genref
  , p_organization_id  IN     NUMBER
  , p_lpn_segments     IN     VARCHAR2
  , p_planning_org_id  IN     NUMBER DEFAULT NULL
  , p_planning_tp_type IN     NUMBER DEFAULT NULL
  , p_owning_org_id    IN     NUMBER DEFAULT NULL
  , p_owning_tp_type   IN     NUMBER DEFAULT NULL
  );

  --Bug 5512205 Introduced a new overloaded procedure that validates the LPN status before populating the LPN LOV for sub xfer
  PROCEDURE get_valid_lpn_org_level(
    x_lpns OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_lpn_segments IN VARCHAR2
  , p_planning_org_id IN NUMBER
  , p_planning_tp_type IN NUMBER
  , p_owning_org_id IN NUMBER
  , p_owning_tp_type IN NUMBER
  , p_to_organization_id       IN     NUMBER
  , p_transaction_type_id      IN     NUMBER
  , p_wms_installed            IN     VARCHAR2
  );
  --End Bug 5512205

  FUNCTION validate_lpn_for_toorg(p_lpn_id IN NUMBER
                                  , p_to_organization_id IN NUMBER
                                  , p_orgid IN NUMBER DEFAULT NULL
                                  , p_transaction_type_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  PROCEDURE get_valid_lpn_tosubs(
    x_to_sub                   OUT    NOCOPY t_genref
  , p_organization_id          IN     NUMBER
  , p_lpn_id                   IN     NUMBER
  , p_from_secondary_name      IN     VARCHAR2
  , p_from_sub_asset_inventory IN     VARCHAR2
  , p_transaction_action_id    IN     NUMBER
  , p_to_organization_id       IN     NUMBER
  , p_transaction_type_id      IN     NUMBER
  , p_wms_installed            IN     VARCHAR2
  , p_secondary_inventory_name IN     VARCHAR2
  );

  FUNCTION vaildate_to_lpn_sub(p_lpn_id IN NUMBER, p_to_subinventory IN VARCHAR2, p_orgid IN NUMBER, p_from_sub_asset_inventory IN VARCHAR2, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION vaildate_lpn_toloc(p_lpn_id IN NUMBER, p_to_subinventory IN VARCHAR2, p_orgid IN NUMBER, p_locator_id IN NUMBER, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2;

  PROCEDURE get_lpnloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lpn_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2);

  FUNCTION vaildate_lpn_status(p_lpn_id IN NUMBER, p_orgid IN NUMBER, p_to_org_id IN NUMBER, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION validate_sub_loc_status(p_lpn IN VARCHAR2, p_org_id IN NUMBER, p_sub IN VARCHAR2, p_loc_id IN NUMBER, p_not_lpn_id IN VARCHAR2 := NULL, p_parent_lpn_id IN VARCHAR2 := '0', p_txn_type_id IN NUMBER)
    RETURN VARCHAR2;

  --      Name: GET_CGUPDATE_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_inventory_item_id     - restricts the subs to only those having
  --                                 this item.
  --       p_revision
  --
  --      Output parameters:
  --       x_cgupdate_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with
  --                 the Cost Group Update
  --
  PROCEDURE get_cgupdate_subs(x_cgupdate_sub_lov OUT NOCOPY t_genref, p_subinventory_code IN VARCHAR2, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2);

  --      Name: GET_CGUPDATE_LOCS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts LOV to the current subinventory
  --       p_concatenated_segments - restricts the locator to those that are
  --                                 similar to the user inputted text.
  --                                 locators are a key flex field so this
  --                                 is how the user represents/identifies locators
  --       p_inventory_item_id
  --       p_revision

  --
  --
  --      Output parameters:
  --       x_locators       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid locators associated with a
  --                 cycle count
  --
  PROCEDURE get_cgupdate_locs(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2);

  PROCEDURE get_cgupdate_locs(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_alias IN VARCHAR2);


  PROCEDURE get_with_all_subs(x_zones OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2);

  PROCEDURE get_with_all_loc(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2);

  /* Locator Alias Project - Added for bug # 5166308 */
  PROCEDURE get_with_all_loc(x_locators              OUT   NOCOPY t_genref
                           , p_organization_id       IN    NUMBER
                           , p_subinventory_code     IN    VARCHAR2
                           , p_concatenated_segments IN    VARCHAR2
                           , p_alias                 IN    VARCHAR2);

  PROCEDURE update_dynamic_locator(x_msg_count OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2, x_result OUT NOCOPY VARCHAR2, x_exist_or_create OUT NOCOPY VARCHAR2, p_locator_id IN NUMBER, p_org_id IN NUMBER, p_sub_code IN VARCHAR2);

  --------------------------------------------------------------
  -- Name : GET_VALID_LPN_CONTROLLED_SUBS
  --Description: Procedure to fetch LPN Controlled subinventories
  --------------------------------------------------------------
  PROCEDURE get_valid_lpn_controlled_subs(x_zones OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_txn_type_id IN NUMBER := 0, p_wms_installed IN VARCHAR2 := 'TRUE');

  --------------------------------------------------------------
  -- Name : GET_PRJ_FROM_LOC_LOV
  --Description: Procedure to fetch valid from locators filtered
  --         on sub, item, project and task
  --------------------------------------------------------------
  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  );

  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  );

  PROCEDURE get_valid_prj_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  );
  PROCEDURE get_valid_prj_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  );

  PROCEDURE get_prj_lpnloc_lov(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_lpn_id                IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_transaction_type_id   IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  );
  PROCEDURE get_prj_lpnloc_lov(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_lpn_id                IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_transaction_type_id   IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  , p_alias                 IN     VARCHAR2
  );

  ----------------------------------------------------------------------------------------
  --Name:UPDATE_LOCATOR
  --Description:Procedure to default the values of picking order,status and locator type
  --from the org parameters whenever a dynamic locator is created.
  -----------------------------------------------------------------------------------------

  PROCEDURE update_locator(p_sub_code IN VARCHAR2, p_org_id IN NUMBER, p_locator_id IN NUMBER);


  --      Patchset I: Sub LOV for User Directed LPN Putaway
  --      Name: GET_USERPUT_SUBS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts the subinventory to those that are
  --                                 similar to the user inputted text.
  --       p_lpn_id                - LPN ID for the LPN that is being put away
  --       p_lpn_context           - LPN Context for the putaway LPN
  --       p_rcv_sub_only          - Determines if only receiving subs
  --                                 should be displayed in the LOV in the
  --                                 case of an LPN that is in receiving.
  --                                 1 = Only RCV Subs
  --                                 2 = both RCV and INV Subs w/ no restrictions
  --                                 3 = Only INV Subs
  --                                 4 = Only INV Subs that are reservable AND lpn-controlled
  --                                 5 = Only INV Subs that are non-reservalbe AND non-lpn-controlled
  --                                 6 = Both RCV Subs and INV Subs that are reservable AND lpn_controlled
--                                   7 = Both RCV Subs and INV Subs that are non-reservable AND non-lpn_controlled
  --      Output parameters:
  --       x_sub                   - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with a
  --                 user directed LPN putaway.  This will take care of
  --                 exploding the LPN and checking for item/sub
  --                 restrictions for all of the packed items.  This will
  --                 also take care of checking the sub material status.
  --                 If the LPN is a receiving LPN, it will also show
  --                 receiving as well as inventory subs.
  --
  PROCEDURE get_userput_subs
    (x_sub                OUT  NOCOPY t_genref  ,
     p_organization_id    IN   NUMBER           ,
     p_subinventory_code  IN   VARCHAR2         ,
     p_lpn_id             IN   NUMBER           ,
     p_lpn_context        IN   NUMBER  DEFAULT NULL,
     p_rcv_sub_only       IN   NUMBER  DEFAULT 2
     );

  --      Patchset I: Function used in get_userput_subs procedure
  --                  in the sub LOV for user directed putaway
  --      Function Name: validate_lpn_sub
  --
  --      Input parameters:
  --       p_organization_id       - Organization for user putaway
  --       p_subinventory_code     - Subinventory being considered for user putaway
  --       p_lpn_id                - LPN ID for user putaway
  --
  --      Output value:            'Y' if validation passed
  --                               'N' if validation failed
  --
  --      Functions:  This function will validate the LPN for item/sub restrictions
  --                  and also for sub material status for each move order
  --                  line transaction.  This function should only be
  --                  called from the procedure get_userput_subs in
  --                  this package: INV_UI_ITEM_SUB_LOC_LOVS
  --
  FUNCTION validate_lpn_sub(p_organization_id    IN  NUMBER    ,
			    p_subinventory_code  IN  VARCHAR2  ,
			    p_lpn_id             IN  NUMBER)
    RETURN VARCHAR2;

  --      Patchset I: Loc LOV for User Directed LPN Putaway
  --      Name: GET_USERPUT_LOCS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts LOV SQL to entered  subinventory
  --       p_concatenated_segments - retricts the locator to those that are
  --                                 similar to the user inputted text.
  --       p_project_id            - restricts the locators for this project
  --       p_task_id               - restricts the locators for this task
  --       p_lpn_id                - LPN ID for the LPN that is being put away
  --
  --      Output parameters:
  --       x_locators              - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid locators associated with a
  --                 user directed LPN putaway.  This will take care of
  --                 exploding the LPN and checking for item/sub/loc
  --                 restrictions for all of the packed items.  This will
  --                 also take care of checking the locator material status
  --
  PROCEDURE get_userput_locs
    (x_locators                OUT  NOCOPY t_genref  ,
     p_organization_id         IN   NUMBER    ,
     p_subinventory_code       IN   VARCHAR2  ,
     p_concatenated_segments   IN   VARCHAR2  ,
     p_project_id              IN   NUMBER    ,
     p_task_id                 IN   NUMBER    ,
     p_lpn_id                  IN   NUMBER
     );

  PROCEDURE get_userput_locs
    (x_locators                OUT  NOCOPY t_genref  ,
     p_organization_id         IN   NUMBER    ,
     p_subinventory_code       IN   VARCHAR2  ,
     p_concatenated_segments   IN   VARCHAR2  ,
     p_project_id              IN   NUMBER    ,
     p_task_id                 IN   NUMBER    ,
     p_lpn_id                  IN   NUMBER    ,
     p_alias                   IN   VARCHAR2
     );

  --      Patchset I: Function used in get_userput_locs procedure
  --                  in the locator LOV for user directed putaway
  --      Function Name: validate_lpn_loc
  --
  --      Input parameters:
  --       p_organization_id       - Organization for user putaway
  --       p_subinventory_code     - Subinventory for user putaway
  --       p_locator_id            - Locator ID being considered for user putaway
  --       p_lpn_id                - LPN ID for user putaway
  --
  --      Output value:            'Y' if validation passed
  --                               'N' if validation failed
  --
  --      Functions:  This function will validate the LPN for item/sub/loc restrictions
  --                  and also for locator material status for each move order
  --                  line transaction.  This function should only be
  --                  called from the procedure get_userput_locs in
  --                  this package: INV_UI_ITEM_SUB_LOC_LOVS
  --
  FUNCTION validate_lpn_loc(p_organization_id    IN  NUMBER    ,
			    p_subinventory_code  IN  VARCHAR2  ,
			    p_locator_id         IN  NUMBER    ,
			    p_lpn_id             IN  NUMBER)
    RETURN VARCHAR2;

  PROCEDURE get_pickload_loc_lov(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  );
  /* Added the following Following proceedure as a part of Bug 2769628
  Used for Pick Load Page to list only those locators that are restricted by project and task.
  */
  PROCEDURE get_pickload_loc_lov(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER);

 /* Bug 4990550 : Added the following procedure, in order to handle the Locator text field bean of Pick Load page*/
     PROCEDURE get_pickload_loc(
      x_locators               OUT    NOCOPY t_genref
     , p_organization_id        IN     NUMBER
     , p_subinventory_code      IN     VARCHAR2
     , p_restrict_locators_code IN     NUMBER
     , p_inventory_item_id      IN     NUMBER
     , p_concatenated_segments  IN     VARCHAR2
     , p_transaction_type_id    IN     NUMBER
     , p_wms_installed          IN     VARCHAR2
     , p_project_id             IN     NUMBER
     , p_task_id                IN     NUMBER);


  PROCEDURE validate_pickload_loc
    (p_organization_id        IN         NUMBER,
     p_subinventory_code      IN         VARCHAR2,
     p_restrict_locators_code IN         NUMBER,
     p_inventory_item_id      IN         NUMBER,
     p_locator                IN         VARCHAR2,
     p_transaction_type_id    IN         NUMBER,
     p_project_id             IN         NUMBER,
     p_task_id                IN         NUMBER,
     x_is_valid_locator       OUT nocopy VARCHAR2,
     x_locator_id             OUT nocopy NUMBER);

  /*Added the follwong procedure as a part of bug 2902336:*/
    PROCEDURE get_inq_prj_loc_lov
   (x_Locators                OUT  NOCOPY t_genref,
    p_Organization_Id         IN   NUMBER,
    p_Subinventory_Code       IN   VARCHAR2,
    p_Restrict_Locators_Code  IN   NUMBER,
    p_Inventory_Item_Id       IN   NUMBER,
    p_Concatenated_Segments   IN   VARCHAR2,
    p_project_id              IN   NUMBER := NULL,
    p_task_id                 IN   NUMBER := NULL
    );
    PROCEDURE get_inq_prj_loc_lov
   (x_Locators                OUT  NOCOPY t_genref,
    p_Organization_Id         IN   NUMBER,
    p_Subinventory_Code       IN   VARCHAR2,
    p_Restrict_Locators_Code  IN   NUMBER,
    p_Inventory_Item_Id       IN   NUMBER,
    p_Concatenated_Segments   IN   VARCHAR2,
    p_project_id              IN   NUMBER := NULL,
    p_task_id                 IN   NUMBER := NULL,
    p_alias                   IN   VARCHAR2
    );

   PROCEDURE get_inq_prj_loc_lov_nvl
   (x_Locators                OUT  NOCOPY t_genref,
    p_Organization_Id         IN   NUMBER,
    p_Subinventory_Code       IN   VARCHAR2,
    p_Restrict_Locators_Code  IN   NUMBER,
    p_Inventory_Item_Id       IN   NUMBER,
    p_Concatenated_Segments   IN   VARCHAR2,
    p_project_id              IN   NUMBER := NULL,
    p_task_id                 IN   NUMBER := NULL);

   PROCEDURE get_inq_prj_loc_lov_nvl
   (x_Locators                OUT  NOCOPY t_genref,
    p_Organization_Id         IN   NUMBER,
    p_Subinventory_Code       IN   VARCHAR2,
    p_Restrict_Locators_Code  IN   NUMBER,
    p_Inventory_Item_Id       IN   NUMBER,
    p_Concatenated_Segments   IN   VARCHAR2,
    p_project_id              IN   NUMBER := NULL,
    p_task_id                 IN   NUMBER := NULL,
    p_alias                   IN   VARCHAR2
    );



/* Bug #3075665. ADDED IN PATCHSET J PROJECT  ADVANCED PICKLOAD
 * All the locators for the given org are selected, not restricting on the subinventory
 */
  --      Patchset J: Procedure used to get all the locs in the org
  --                  restricted by proj, task if passed and
  --                  NOT restricted by subinventory
  --      Procedure Name:  get_pickload_all_loc_lov
  --
  --      Input parameters:
  --       p_organization_id       - Organization Id
  --
  --      Output value:
  --                 x_locators     Ref. cursor
  --
 PROCEDURE get_pickload_all_loc_lov
   (
      x_locators               OUT    NOCOPY t_genref
     , p_organization_id        IN     NUMBER
     , p_restrict_locators_code IN     NUMBER
     , p_inventory_item_id      IN     NUMBER
     , p_concatenated_segments  IN     VARCHAR2
     , p_transaction_type_id    IN     NUMBER
     , p_wms_installed          IN     VARCHAR2
     , p_project_id             IN     NUMBER
     , p_task_id                IN     NUMBER
   );

  -- Bug #3075665. ADDED IN PATCHSET J PROJECT  ADVANCED PICKLOAD
  --      Patchset J: Procedure used to get the locs including project locs
  --      Procedure Name:  GET_APL_PRJ_LOC_LOV
  --
  --      Input parameters:
  --       p_organization_id
  --       p_subinventory_code
  --       p_restrict_locators_code
  --       p_inventory_item_id
  --       p_concatenated_segments
  --       p_transaction_type_id
  --       p_wms_installed
  --       p_project_id
  --       p_task_id
  --      Output value:
  --       x_locators     Ref. cursor
  --
PROCEDURE GET_APL_PRJ_LOC_LOV(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER);



  -- Bug #3075665. ADDED IN PATCHSET J PROJECT  ADVANCED PICKLOAD
  --      Patchset J: Procedure used to get the locs including project locs
  --      Procedure Name:  get_pickload_loc_details
  --            This procedure gets the locator details - concat segs, loc desc,
  --            project, task, sub for a given org id, loc id.
  --            The procedure also returns if the given locator exists or not.
  --      Input parameters:
  --        p_organization_id            - Organization Id
  --        p_inventory_location_id      - Inventory Location Id
  --      Output value:
  --        x_subinventory_code          - SubInventory Code
  --        x_concatenated_segments      - Locator concatenated segments
  --        x_description                - loc Description
  --        x_project_id                 - Project Id
  --        x_task_id                    - Task Id
  --        x_loc_exists                 - boolean- Does the loc exists.
PROCEDURE get_pickload_loc_details(
    p_organization_id        IN              NUMBER
  , p_inventory_location_id  IN              NUMBER
  , x_subinventory_code      OUT NOCOPY      VARCHAR2
  , x_concatenated_segments  OUT NOCOPY      VARCHAR2
  , x_description            OUT NOCOPY      VARCHAR2
  , x_project_id             OUT NOCOPY      NUMBER
  , x_task_id                OUT NOCOPY      NUMBER
  , x_loc_exists             OUT NOCOPY      VARCHAR
  , x_msg_count		           OUT NOCOPY      NUMBER
  , x_msg_data		           OUT NOCOPY      VARCHAR2
  , x_return_status		       OUT NOCOPY      VARCHAR2  );

  --
  --
  ----------------------------------
  --  Name:  GET_LOCATION_TYPE_LOCATORS
  --         To query locators of a sub and org without status check
  --         that is also filtered by mtl_item_locations.inventory_location_type
  --  Input Parameter:
  --    p_organization_id:        Organization ID
  --    p_subinventory_code       Sub
  --    p_inventory_location_type Location Type: Dock Door, Staging, Storage
  --    p_concatenated_segments   LOV
  --
  PROCEDURE Get_Location_Type_Locators(
    x_locators                OUT    NOCOPY t_genref
  , p_organization_id         IN     NUMBER
  , p_subinventory_code       IN     VARCHAR2
  , p_inventory_location_type IN     NUMBER
  , p_concatenated_segments   IN     VARCHAR2
  );
  PROCEDURE Get_Location_Type_Locators(
    x_locators                OUT    NOCOPY t_genref
  , p_organization_id         IN     NUMBER
  , p_subinventory_code       IN     VARCHAR2
  , p_inventory_location_type IN     NUMBER
  , p_concatenated_segments   IN     VARCHAR2
  , p_alias                   IN     VARCHAR2
  );
  PROCEDURE get_value_from_alias(
             x_return_status OUT NOCOPY VARCHAR2
            ,x_msg_data      OUT NOCOPY VARCHAR2
            ,x_msg_count     OUT NOCOPY NUMBER
            ,x_match         OUT NOCOPY VARCHAR2
            ,x_value         OUT NOCOPY VARCHAR2
            ,p_org_id        IN  NUMBER
            ,p_sub_code      IN  VARCHAR2
            ,p_alias         IN  VARCHAR2
            ,p_suggested     IN  VARCHAR2
            );

/* Added following procdure for bug 8237335 */
   PROCEDURE get_prj_to_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  );

/*9022877*/
PROCEDURE get_restricted_subs(
            x_zones             OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          ,p_inventory_item_id  IN  NUMBER
 ) ;

END inv_ui_item_sub_loc_lovs;

/
