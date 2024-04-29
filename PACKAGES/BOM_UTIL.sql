--------------------------------------------------------
--  DDL for Package BOM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_UTIL" AUTHID CURRENT_USER as
/* $Header: BOMUTILS.pls 120.0 2006/03/14 15:51:22 seradhak noship $ */
  FUNCTION get_first_level_components
      (p_cbill_sequence_id   IN
                BOM_BILL_OF_MATERIALS.bill_sequence_id%TYPE)
     RETURN NUMBER;
  -- --------------------------------
  FUNCTION get_second_level_components
      (p_component_item_id   IN
                BOM_INVENTORY_COMPONENTS.component_item_id%TYPE,
       p_organization_id     IN NUMBER,
       p_alternate_bom_designator IN VARCHAR2)
     RETURN NUMBER;
  -- --------------------------------
  FUNCTION get_change_order_count
      (p_bill_sequence_id    IN
                BOM_BILL_OF_MATERIALS.bill_sequence_id%TYPE)
     RETURN NUMBER;
  -- --------------------------------
  FUNCTION get_effective_date(p_structure_type_id IN NUMBER)
   RETURN DATE ;
  -- --------------------------------
  FUNCTION get_disable_date(p_structure_type_id IN NUMBER)
   RETURN DATE ;
  -- --------------------------------
  FUNCTION check_structures_exist(p_structure_type_id IN NUMBER)
   RETURN VARCHAR2;
  -- --------------------------------
  FUNCTION check_id_exist(p_structure_type_id IN NUMBER)
   RETURN VARCHAR2;
  -- --------------------------------
  FUNCTION getFirstLevelComponents(p_component_item_id IN NUMBER,
                                            p_bill_sequence_id  IN NUMBER,
                                            p_top_bill_sequence_id IN NUMBER,
                                            p_plan_level        IN NUMBER,
                                            p_organization_id   IN NUMBER)
    RETURN NUMBER;
  -- ---------------------------------------
     PROCEDURE validate_RefDesig_Entity
   ( p_organization_id IN NUMBER
   , p_component_seq_id IN NUMBER
   , p_ref_desig_name IN VARCHAR2
   , p_acd_type IN NUMBER
   , x_return_status IN OUT NOCOPY VARCHAR2
   );
  -- ----------------------------------------------------------------------
   PROCEDURE check_RefDesig_Access
   ( p_organization_id IN NUMBER
   , p_assembly_item_id IN NUMBER
   , p_alternate_bom_code IN VARCHAR2
   , p_ref_desig_name IN VARCHAR2
   , p_component_item_id IN NUMBER
   , p_component_item_name IN VARCHAR2
   , p_component_seq_id IN NUMBER
   , x_return_status IN OUT NOCOPY VARCHAR2
   );
   -- -----------------------------------------------------------------------
   PROCEDURE get_RefDesig_Quantity
   ( p_component_seq_id IN NUMBER
   , p_acd_type IN NUMBER
   , x_refdesig_qty IN OUT NOCOPY NUMBER
   , x_qty_related IN OUT NOCOPY NUMBER
   , x_comp_qty IN OUT NOCOPY NUMBER
   );
   -- -----------------------------------------------------------------------
   FUNCTION get_person_name(p_user_id IN NUMBER) RETURN VARCHAR2;
   -- -----------------------------------------------------------------------
   FUNCTION get_change_notice(p_change_line_id IN NUMBER) return VARCHAR2;
   -- -----------------------------------------------------------------------
   FUNCTION get_implemen_date(p_bill_sequence_id IN NUMBER)
    RETURN DATE;
END BOM_UTIL;

 

/
