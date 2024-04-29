--------------------------------------------------------
--  DDL for Package EGO_ICC_STRUCTURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ICC_STRUCTURE_PVT" AUTHID CURRENT_USER AS
/* $Header: egoistps.pls 120.0.12010000.5 2009/08/20 11:15:42 sisankar noship $ */

/*
 * This Procedure will delete the user attributes for components.
 */
Procedure Delete_Comp_User_Attrs(p_comp_seq_id IN NUMBER);

/*
 * This Procedure will revert the components for the Draft version of the ICC.
 */
PROCEDURE Revert_draft_components (p_item_catalog_grp_id IN NUMBER,
                                   p_version_seq_id      IN NUMBER,
                                   x_Return_Status       OUT NOCOPY NUMBER,
                                   x_Error_Message       OUT NOCOPY VARCHAR2);

/*
 * This Procedure will create the components for the newly released version of the ICC.
 */
PROCEDURE Release_Components (p_item_catalog_grp_id IN NUMBER,
                              p_version_seq_id      IN NUMBER,
                              p_start_date          IN DATE,
                              x_Return_Status       OUT NOCOPY NUMBER,
                              x_Error_Message       OUT NOCOPY VARCHAR2);

/*
 * This Function will get the ICC Name for a given Bill Seq Id.
 */
Function   getIccName(p_item_catalog_grp_id IN NUMBER,
                      p_parent_bill_seq_id  IN NUMBER)
RETURN VARCHAR2;

/*
 * This Function will get the effective version of a ICC for a given date.
 */
Function   Get_Effective_Version(p_item_catalog_grp_id IN NUMBER,
                                 p_start_date          IN DATE)
RETURN NUMBER;

/*
 * This Function will get the effective version of a Parent ICC for a given date.
 */
Function   Get_Parent_Version(p_item_catalog_grp_id IN NUMBER,
                              p_start_date          IN DATE)
RETURN NUMBER;

/*
 * This Function will give whether Draft version has been updated or not.
 */
Function  Is_Structure_Updated(p_item_catalog_grp_id IN NUMBER,
                               p_start_date          IN DATE)
RETURN NUMBER;

/*
 * This Function will compare UDA values for two different components and gives whether they are same or different.
 */

Function Compare_UDA_Values(p_draft_comp_seq_id    IN NUMBER,
                            p_released_comp_seq_id IN NUMBER)
RETURN NUMBER;

Function Compare_components(p_draft_comp_seq_id    IN NUMBER,
                            p_released_comp_seq_id IN NUMBER)
RETURN NUMBER;

/*
 * This Procedure will inherit components to item structure from ICC structure when structure is created.
 */

Procedure create_structure_inherit(p_inventory_item_id   IN NUMBER,
                                   p_organization_id     IN NUMBER,
                                   p_bill_seq_id         IN NUMBER,
       p_comm_bill_seq_id    IN NUMBER,
                                   p_structure_type_id   IN NUMBER,
                                   p_alt_desg            IN VARCHAR2,
                                   x_Return_Status       OUT NOCOPY NUMBER,
                                   x_Error_Message       OUT NOCOPY VARCHAR2,
       p_eff_control         IN NUMBER);



PROCEDURE inherit_icc_components(p_inventory_item_id IN NUMBER,
                                p_organization_id   IN NUMBER,
                                p_revision_id       IN NUMBER,
                                p_rev_date          IN DATE,
    x_Return_Status     OUT NOCOPY NUMBER,
                                x_Error_Message     OUT NOCOPY VARCHAR2);

Function get_revision_start_date(p_rev_id in Number)
Return Date;

Function get_revision_end_date(p_rev_id in Number)
Return Date;

/*
 * This Function will give whether item structure inherits components from icc structure or not.
 */
Function  Is_Structure_Inheriting(p_item_catalog_grp_id IN NUMBER,
                                  p_organization_id     IN NUMBER,
                                  p_inv_item_id         IN NUMBER,
                                  p_structure_type_id   IN NUMBER,
                                  p_alt_desig           IN VARCHAR2)
RETURN NUMBER;

/*
 * This Procedure creates default structure header for versioned ICCs based on its hierarchy.
 */
Procedure Create_Default_Header(p_item_catalog_grp_id IN NUMBER,
                                p_commit_flag IN NUMBER);

/*
 * This Function gives whether Parent-ICC is updatable for a ICC.
 */
Function Is_Parent_Updatable(p_item_catalog_grp_id IN NUMBER)
Return NUMBER;

/*
 * This Function validates whether component Base Attributes are valid.
 */
Function Validate_Base_attributes(
  p_organization_id             IN NUMBER,
  p_operation_seq_num           IN NUMBER,
  p_component_item_id           IN NUMBER,
  p_item_num                    IN NUMBER,
  p_basis_type                  IN NUMBER,
  p_component_quantity          IN NUMBER,
  p_component_yield_factor      IN NUMBER,
  p_component_remarks           IN VARCHAR2,
  p_planning_factor             IN NUMBER,
  p_quantity_related            IN NUMBER,
  p_so_basis                    IN NUMBER,
  p_optional                    IN NUMBER,
  p_mutually_exclusive_options  IN NUMBER,
  p_include_in_cost_rollup      IN NUMBER,
  p_check_atp                   IN NUMBER,
  p_shipping_allowed            IN NUMBER,
  p_required_to_ship            IN NUMBER,
  p_required_for_revenue        IN NUMBER,
  p_include_on_ship_docs        IN NUMBER,
  p_low_quantity                IN NUMBER,
  p_high_quantity               IN NUMBER,
  p_component_sequence_id       IN NUMBER,
  p_bill_sequence_id            IN NUMBER,
  p_wip_supply_type             IN NUMBER,
  p_pick_components             IN NUMBER,
  p_supply_subinventory         IN VARCHAR2,
  p_supply_locator_id           IN NUMBER,
  p_bom_item_type               IN NUMBER,
  p_component_item_revision_id  IN NUMBER,
  p_enforce_int_requirements    IN NUMBER,
  p_auto_request_material       IN VARCHAR2,
  p_component_name              IN VARCHAR2)
Return NUMBER;

END EGO_ICC_STRUCTURE_PVT;

/
