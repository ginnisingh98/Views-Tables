--------------------------------------------------------
--  DDL for Package BOM_EXPLODER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_EXPLODER_PUB" AUTHID CURRENT_USER as
/* $Header: BOMPLMXS.pls 120.5.12010000.4 2013/03/28 08:55:25 icyu ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPLMXS.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the BOM exploders
|      This package contains 3 different exploders for the
|      modules it can be called from.  The procedure exploders
|    calls the correct exploder based on the module option.
|    Each of the 3 exploders can be called on directly too.
| Procedure    : exploder_userexit
| Parameters: org_id    organization_id
|   order_by  1 - Op seq, item seq
|       2 - Item seq, op seq
|   grp_id    unique value to identify current explosion
|       use value from sequence bom_small_expl_temp_s
|   session_id  unique value to identify current session
|       use value from bom_small_expl_temp_session_s
|   levels_to_explode
|   bom_or_eng  1 - BOM
|       2 - ENG
|   impl_flag 1 - implemented only
|       2 - both impl and unimpl
|   explode_option  1 - All
|       2 - Current
|       3 - Current and future
|   module    1 - Costing
|       2 - Bom
|       3 - Order entry
|   cst_type_id cost type id for costed explosion
|   std_comp_flag 1 - explode only standard components
|       2 - all components
|   expl_qty  explosion quantity
|   item_id   item id of asembly to explode
|   list_id   unique id for lists in bom_lists for range
|   report_option 1 - cost rollup with report
|       2 - cost rollup no report
|       3 - temp cost rollup with report
|   cst_rlp_id  rollup_id
|   req_id    request id
|   prgm_appl_id  program application id
|   prg_id    program id
|   user_id   user id
|   lock_flag 1 - do not lock the table
|       2 - lock the table
|   alt_rtg_desg  alternate routing designator
|   rollup_option 1 - single level rollup
|       2 - full rollup
|   plan_factor_flag1 - Yes
|       2 - No
|   alt_desg  alternate bom designator
|   rev_date  explosion date
|   comp_code concatenated component code lpad 16
|               show_rev        1 - obtain current revision of component
|       2 - don't obtain current revision
|   material_ctrl   1 - obtain subinventory locator
|       2 - don't obtain subinventory locator
|   lead_time 1 - calculate offset percent
|       2 - don't calculate offset percent
|   err_msg   error message out buffer
|   error_code  error code out.  returns sql error code
|       if sql error, 9999 if loop detected.
|       end_item_revision_id  -- End item Revision id
|       end_item_strc_revision_id -- End item structure revision id
|                                 End item structure revision id is mandatory when
|                                 the end item revision id is passed
|       unit_number  -- Unit number/Serial number for which the BOM explosion needs to be
|                    performed
|        object_name  -- NULL for inventory items, DDD_CADVIEW for CAD components
|        pk_value1...pk_value5  -- Primary key columns for the object
|                               For inventory items, pk_value1 = Inventory Item Id and
|                                                    pk_value2 = Oragnization_id
|                              For CAD Components, pk_value1 = CAD Component id
| Revision
|
|   10-DEC-2003  Refaitheen Farook  Initial creation. PLM specific BOM exploder
|
+==========================================================================*/

p_top_bill_sequence_id  NUMBER;
p_explosion_date     DATE     := SYSDATE;
p_expl_end_item_rev       NUMBER;
p_expl_end_item_rev_code  VARCHAR2(3);
p_expl_end_item_id        NUMBER;
p_expl_end_item_org_id    NUMBER;
p_expl_unit_number   VARCHAR2(30);
p_explode_option     NUMBER;
p_group_id           NUMBER;
p_top_effectivity_control NUMBER;

--bug 15957539: pella-seq:bom_inventory_components_s near to 90% of max value
TYPE VARCHAR_10_TBL IS TABLE OF VARCHAR2(10) INDEX BY LONG;
TYPE NUMBER_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE NUMBER_LONG_TBL IS TABLE OF NUMBER INDEX BY LONG;
TYPE VARCHAR_80_TBL IS TABLE OF VARCHAR2(80) INDEX BY LONG;
--TYPE VARCHAR_10_TBL IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
--TYPE VARCHAR_80_TBL IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE DATE_TBL IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE VARCHAR_4000_TBL IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
--TYPE VARCHAR_1_TBL IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE VARCHAR_1_TBL IS TABLE OF VARCHAR2(1) INDEX BY LONG;

/*
TYPE CSEQ_REVISION_TBL IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE CSEQ_REVISION_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE CSEQ_REVISION_LABEL_TBL IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE REV_HIGHDATE_TBL IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE REV_SPECIFIC_EXCLN_TBL IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE ACCESS_FLAG_TBL IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE ITEMS_WITHOUT_ACCESS_TBL IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE COMPSEQS_WITHOUT_ACCESS_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
*/

component_revision_array        VARCHAR_10_TBL;
--component_revision_id_array     NUMBER_TBL;
component_revision_id_array     NUMBER_LONG_TBL;
--bug 15957539: pella-seq:bom_inventory_components_s near to 90% of max value end
component_revision_label_array  VARCHAR_80_TBL;
revision_highdate_array         DATE_TBL;
rev_specific_exclusions_array   VARCHAR_4000_TBL;
access_flag_array               VARCHAR_1_TBL;
asss_without_access_array       VARCHAR_4000_TBL;
compseqs_without_access_array   NUMBER_TBL;
change_policy_array             VARCHAR_80_TBL;

/*
component_revision_array        CSEQ_REVISION_TBL;
component_revision_id_array     CSEQ_REVISION_ID_TBL;
component_revision_label_array  CSEQ_REVISION_LABEL_TBL;
revision_highdate_array         REV_HIGHDATE_TBL;
rev_specific_exclusions_array   REV_SPECIFIC_EXCLN_TBL;
access_flag_array               ACCESS_FLAG_TBL;
asss_without_access_array       ITEMS_WITHOUT_ACCESS_TBL;
compseqs_without_access_array   COMPSEQS_WITHOUT_ACCESS_TBL;
*/

p_current_revision_id NUMBER;
p_current_revision_code VARCHAR2(10);
p_current_revision_label VARCHAR2(80);

PROCEDURE exploder_userexit (
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN OUT NOCOPY  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 60,
  bom_or_eng    IN  NUMBER DEFAULT 2,
  impl_flag   IN  NUMBER DEFAULT 2,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 3,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  unit_number   IN  VARCHAR2 DEFAULT NULL,
  alt_desg    IN  VARCHAR2 DEFAULT '',
  comp_code               IN  VARCHAR2 DEFAULT '',
  rev_date    IN  DATE DEFAULT sysdate,
  minor_rev_id IN NUMBER DEFAULT NULL,
  material_ctrl     IN NUMBER DEFAULT 2,
  lead_time   IN NUMBER DEFAULT 2,
  object_name       IN VARCHAR2 DEFAULT NULL,
  pk_value1         IN VARCHAR2,
  pk_value2         IN VARCHAR2 DEFAULT NULL,
  pk_value3         IN VARCHAR2 DEFAULT NULL,
  pk_value4         IN VARCHAR2 DEFAULT NULL,
  pk_value5         IN VARCHAR2 DEFAULT NULL,
  end_item_id   IN NUMBER DEFAULT NULL,
  end_item_revision_id   IN NUMBER DEFAULT NULL,
  end_item_minor_revision_id  IN NUMBER DEFAULT NULL,
  err_msg     IN OUT NOCOPY VARCHAR2,
  error_code    IN OUT NOCOPY NUMBER,
  end_item_strc_revision_id  IN NUMBER DEFAULT NULL,
  show_rev          IN NUMBER DEFAULT 1,
  structure_rev_id IN NUMBER DEFAULT NULL,
  structure_type_id     IN NUMBER DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,
  p_autonomous_transaction IN NUMBER DEFAULT 1,

  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'
);

FUNCTION Get_Comp_Bill_Seq_Id (p_obj_name IN VARCHAR2,
                               p_top_alternate_designator IN VARCHAR2,
                               p_organization_id IN NUMBER,
                               p_pk1_value IN VARCHAR2,
                               p_pk2_value IN VARCHAR2) RETURN NUMBER;

FUNCTION Get_Change_Policy_Val (p_item_rev_id IN NUMBER,
                                p_bill_seq_id IN NUMBER) RETURN VARCHAR2;

  /****************************************************************************
  * Procedure : Apply_New_Exclusion_Rules
  * Parameters  : p_bill_sequence_id
  * Scope : Local
  * Purpose : This procedure is invoked when new explosion rules have been added
  ******************************************************************************/
PROCEDURE Apply_New_Exclusion_Rules (p_bill_sequence_id  IN NUMBER);

  /****************************************************************************
  * Procedure : Set_Reapply_Exclusion_Flag
  * Parameters  : p_bill_sequence_id
  * Scope : Local
  * Purpose : This procedure sets the reapply_exclusions flag to 'Y' for all the
  *          structures where this structure is added as substructure.
  *          Only the rows with plan_level=0 will be modified.
  ******************************************************************************/
PROCEDURE Set_Reapply_Exclusion_Flag (p_bill_sequence_id  IN NUMBER);


FUNCTION Get_Top_Bill_Sequence_Id RETURN NUMBER;
FUNCTION Get_Explosion_Date RETURN DATE;
FUNCTION Get_Expl_End_Item_Rev RETURN NUMBER;
FUNCTION Get_Expl_End_Item_Rev_Code RETURN VARCHAR2;
FUNCTION Get_Expl_Unit_Number RETURN VARCHAR2;
FUNCTION Get_Explode_Option RETURN NUMBER;
FUNCTION Get_Group_Id RETURN NUMBER;
FUNCTION Get_Top_Effectivity_Control RETURN NUMBER;

FUNCTION Get_Component_Revision(p_component_sequence_id NUMBER) RETURN VARCHAR2;
FUNCTION Get_Component_Revision_Id(p_component_sequence_id NUMBER) RETURN NUMBER;
FUNCTION Get_Component_Revision_Label(p_component_sequence_id NUMBER) RETURN VARCHAR2;
FUNCTION Get_Revision_HighDate(p_revision_id NUMBER) RETURN DATE;

FUNCTION Get_Component_Access_Flag(p_component_sequence_id NUMBER) RETURN VARCHAR2;

FUNCTION Get_EGO_User RETURN VARCHAR2;

FUNCTION Get_Revision_Code(p_revision_id NUMBER) RETURN VARCHAR2;

FUNCTION Get_Current_Revision_Code RETURN VARCHAR2;
FUNCTION Get_Current_Revision_Id RETURN NUMBER;
FUNCTION Get_Current_Revision_Label RETURN VARCHAR2;

FUNCTION Get_Current_RevisionDetails( p_inventory_item_id  IN NUMBER,
                                      p_organization_id IN NUMBER,
                                      p_effectivity_date IN DATE) RETURN VARCHAR2;


FUNCTION Is_EndItem_Specific ( p_inventory_item_id  IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_revision_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Check_Excluded_By_Rule (p_component_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Change_Policy(p_component_sequence_id NUMBER) RETURN VARCHAR2;

/****************************************************************************
  * Procedure : Returns Revision id
  * Parameters  : p_inventory_item_id,p_organization_id,p_effectivity_date
  * Scope : Public
  * Purpose : This procedure is added to get latest revision id as per
              effectivity_date.
  ******************************************************************************/
FUNCTION Get_Current_RevisionId( p_inventory_item_id  IN NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_effectivity_date IN DATE) RETURN NUMBER;

END BOM_EXPLODER_PUB;

/
