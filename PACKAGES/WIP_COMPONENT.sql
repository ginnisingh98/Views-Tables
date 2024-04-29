--------------------------------------------------------
--  DDL for Package WIP_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_COMPONENT" AUTHID CURRENT_USER as
/* $Header: wipfnmts.pls 120.2 2005/06/17 12:52:59 appldev  $ */

/* Returns WIP_CONSTANTS.YES if a component should be picked up in
   populate temp based on the action, supply type, and quantities required
   and issued.
   Otherwise returns WIP_CONSTANTS.NO
*/
FUNCTION IS_VALID
(p_transaction_action_id NUMBER,
 p_wip_supply_type NUMBER,
 p_required_quantity NUMBER,
 p_quantity_issued NUMBER,
 p_assembly_quantity NUMBER,
 p_entity_type NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(is_valid, WNDS, WNPS);

/* Returns WIP_CONSTANTS.YES if the component satisfies all criteria
   a user might have entered in the material transactions window.  Otherwise,
   returns WIP_CONSTANTS.NO
*/
FUNCTION MEETS_CRITERIA
(req_op_seq NUMBER,
 crit_op_seq NUMBER,
 req_dept_id NUMBER,
 crit_dept_id NUMBER,
 req_sub VARCHAR2,
 crit_sub VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(meets_criteria, WNDS, WNPS);

/* Returns the proper deafult transaction quantity based on the
   Transaction action, Requirement quantities, and optional assembly quantity
 */
 /* ER 4369064: Component Yield Enhancement */
 /* Added two new parameters include_yield and component_yield_factor */
FUNCTION Determine_Txn_Quantity
                (transaction_action_id IN NUMBER,
                 qty_per_assembly IN NUMBER,
                 required_qty IN NUMBER,
                 qty_issued IN NUMBER,
                 assembly_qty IN NUMBER,
                 include_yield IN NUMBER,
                 component_yield_factor IN NUMBER,
                 basis_type IN NUMBER DEFAULT NULL ) RETURN NUMBER; /* LBM Project */

PRAGMA RESTRICT_REFERENCES(Determine_Txn_Quantity, WNDS, WNPS, TRUST);  /* LBM Project */

/* Returns  'Y' or 'N' depending on whether the subinventory, item, org
   combination is valid */

FUNCTION Valid_Subinventory
		(p_subinventory IN VARCHAR2,
		 p_item_id IN NUMBER,
		 p_org_id IN NUMBER) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Valid_Subinventory, WNDS, WNPS);

/* Returns  'Y' or 'N' depending on whether the subinventory, item, org
   and locator combination is valid */

FUNCTION Valid_Locator
		(p_locator_id IN OUT NOCOPY NUMBER,
		 p_item_id IN NUMBER,
		 p_org_id IN NUMBER,
                 p_org_control IN NUMBER,
                 p_sub_control IN NUMBER,
                 p_item_control IN NUMBER,
                 p_restrict_locators_code IN NUMBER,
                 p_loc_disable_date IN DATE,
                 p_locator_control OUT NOCOPY NUMBER
		 ) RETURN VARCHAR2;

END WIP_COMPONENT;

 

/
