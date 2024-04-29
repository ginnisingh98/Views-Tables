--------------------------------------------------------
--  DDL for Package Body BOM_EXPLODER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_EXPLODER_PUB" as
/* $Header: BOMPLMXB.pls 120.22.12010000.21 2013/02/27 01:31:57 chulhale ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPLMXB.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the PLM exploders.
| Parameters: org_id    organization_id
|   order_by  1 - Op seq, item seq
|       2 - Item seq, op seq
|   grp_id    unique value to identify current explosion
|       use value FROM sequence BOM_EXPLOSIONS_ALL_s
|   session_id  unique value to identify current session
|       use value FROM BOM_EXPLOSIONS_ALL_session_s
|   levels_to_explode
|   bom_or_eng  1 - BOM
|       2 - ENG
|   impl_flag 1 - implemented only
|       2 - both impl AND unimpl
|   explode_option  1 - All
|       2 - Current
|       3 - Current AND future
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
|   err_msg   error message IN OUT NOCOPY buffer
|   error_code  error code out.  returns sql error code
|       IF sql error, 9999 IF loop detected.
|                                                                           |
+==========================================================================*/

  temp number := 0;
  no_profile EXCEPTION;
  invalid_org EXCEPTION;
  invalid_assembly_item_name EXCEPTION;
  invalid_comp_seq_id EXCEPTION;
  invalid_bill_seq_id EXCEPTION;
  invalid_locator_id EXCEPTION;
  missing_parameters EXCEPTION;
  exploder_error    EXCEPTION;
  G_EGOUser VARCHAR2(30) := BOM_SECURITY_PUB.Get_EGO_User;
  G_SortWidth constant number := 7; -- no more than 9999999 components per level

  g_parent_sort_order VARCHAR2(2000) := '0000001';
  g_sort_count NUMBER := 0;

  TYPE G_VARCHAR2_TBL_TYPE_2000 IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

  TYPE G_NUMBER_TBL_TYPE IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  g_parent_sort_order_tbl           G_VARCHAR2_TBL_TYPE_2000;
  g_quantity_of_children_tbl        G_NUMBER_TBL_TYPE;
  g_total_qty_at_next_level_tbl     G_NUMBER_TBL_TYPE;

  g_global_count    NUMBER := 1;
  g_total_quantity  NUMBER := 0;

  PROCEDURE Reset_Globals IS
  BEGIN

    /* Reset all the globally used values */

    g_quantity_of_children_tbl.DELETE;
    g_total_qty_at_next_level_tbl.DELETE;
    g_parent_sort_order_tbl.DELETE;
    g_global_count := 1;
    g_total_quantity  := 0;
    g_sort_count := 0;
    g_parent_sort_order := '0000001';

  END;

  FUNCTION Is_Internal_With_Privilege(p_object_name  IN VARCHAR2,
                                p_user_name     IN VARCHAR2,
                                p_function_name IN VARCHAR2) RETURN VARCHAR2
  IS
    l_count NUMBER;
    l_exists VARCHAR2(1);
  BEGIN
  SELECT COUNT(1) INTO l_count FROM ego_internal_people_v
  WHERE user_name =  p_user_name;

        --dbms_output.put_line('User name '||p_user_name);
        --dbms_output.put_line('User Internal '||l_count);

  IF l_count = 0
  THEN
    Return 'N';
  END IF;

  SELECT 'X' INTO l_exists
  FROM fnd_form_functions functions,
  fnd_menu_entries cmf,
  fnd_menus menus
  WHERE functions.function_name = p_function_name
  AND functions.function_id = cmf.function_id
  AND menus.menu_id = cmf.menu_id
  AND menus.menu_name = FND_PROFILE.VALUE('EGO_INTERNAL_USER_DEFAULT_ROLE');

        --dbms_output.put_line('User has privilege');

  Return 'Y';

  EXCEPTION WHEN NO_DATA_FOUND
  THEN
    Return 'N';
  END;

  FUNCTION Is_EndItem_Specific ( p_inventory_item_id  IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_revision_id IN NUMBER)  RETURN VARCHAR2 IS
      l_result VARCHAR2(1);
  BEGIN
      IF p_revision_id IS NULL
      THEN
        Return 'N';
      END IF;
      SELECT  'Y' INTO l_result FROM mtl_item_revisions_b WHERE inventory_item_id = p_inventory_item_id AND
      organization_id = p_organization_id AND revision_id = p_revision_id;
      Return l_result;
      EXCEPTION WHEN NO_DATA_FOUND
      THEN
        Return 'N';
  END;

  FUNCTION Get_Revision_Code ( p_revision_id IN NUMBER) RETURN VARCHAR2 IS
    l_revision VARCHAR2(10);
  BEGIN
    IF p_revision_id IS NULL
    THEN
      Return null;
    END IF;
    SELECT  revision INTO l_revision FROM mtl_item_revisions_b WHERE revision_id = p_revision_id;
    Return l_revision;
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
      Return null;
  END;

  FUNCTION Get_Current_RevisionDetails( p_inventory_item_id  IN NUMBER,
                                        p_organization_id IN NUMBER,
                                        p_effectivity_date IN DATE) RETURN VARCHAR2 IS
    CURSOR c1 IS
    SELECT revision, revision_id,revision_label FROM mtl_item_revisions_b WHERE
    inventory_item_id = p_inventory_item_id AND organization_id = p_organization_id AND
    effectivity_date <= p_effectivity_date
    AND ((BOM_GLOBALS.get_show_Impl_comps_only = 'Y' AND implementation_date IS NOT NULL) OR  BOM_GLOBALS.get_show_Impl_comps_only = 'N')  -- added for Bug 7242865
    ORDER BY effectivity_date DESC;

  BEGIN

    OPEN c1;
    FETCH c1 INTO p_current_revision_code, p_current_revision_id, p_current_revision_label;
    IF c1%ROWCOUNT = 0
    THEN
      p_current_revision_code := null ;
      p_current_revision_id := null;
      p_current_revision_label := null;
    END IF;
    CLOSE c1;
    Return p_current_revision_code;
    EXCEPTION WHEN OTHERS THEN
      p_current_revision_code := null ;
      p_current_revision_id := null;
      p_current_revision_label := null;
      Return null;

  END;


  FUNCTION Get_Comp_Bill_Seq_Id (p_obj_name IN VARCHAR2,
                                 p_top_alternate_designator IN VARCHAR2,
                                 p_organization_id IN NUMBER,
                                 p_pk1_value IN VARCHAR2,
                                 p_pk2_value IN VARCHAR2)

  RETURN NUMBER IS

    l_bill_sequence_id NUMBER;

    CURSOR c1 IS
    SELECT BBOM_C.bill_sequence_id bill_seq_id FROM bom_structures_b BBOM_C
    WHERE BBOM_C.assembly_item_id = p_pk1_value AND BBOM_C.organization_id = p_organization_id AND
    BBOM_C.alternate_bom_designator = p_top_alternate_designator;


  BEGIN

    /*

    SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
    WHERE nvl(BBOM_C.obj_name,'EGO_ITEM') = nvl(p_obj_name,'EGO_ITEM')
      AND BBOM_C.pk1_value = p_pk1_value
      AND nvl(BBOM_C.pk2_value,'-1') = nvl(p_pk2_value,'-1')
      AND   BBOM_C.organization_id = p_organization_id
      AND   nvl(BBOM_C.alternate_bom_designator, 'NONE') = nvl(p_top_alternate_designator, 'NONE');

    RETURN l_bill_sequence_id;

    EXCEPTION WHEN OTHERS THEN
      RETURN 0;
    */

    /* The above code is replaced by the following to make sure the index BOM_STRUCTURES_B_N3 is used */

    IF (p_obj_name IS NULL AND p_top_alternate_designator IS NULL) THEN

      SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
      WHERE BBOM_C.assembly_item_id = p_pk1_value AND BBOM_C.organization_id = p_organization_id AND
      BBOM_C.alternate_bom_designator IS NULL;

    ELSIF (p_obj_name IS NULL AND p_top_alternate_designator IS NOT NULL) THEN
      /*
      FOR r1 IN c1
      LOOP
        Return r1.bill_seq_id;
      END LOOP;
      */

      BEGIN
        SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
        WHERE BBOM_C.assembly_item_id = p_pk1_value AND BBOM_C.organization_id = p_organization_id AND
        BBOM_C.alternate_bom_designator = p_top_alternate_designator;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  BEGIN
            SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
            WHERE BBOM_C.assembly_item_id = p_pk1_value AND BBOM_C.organization_id = p_organization_id AND
            BBOM_C.alternate_bom_designator IS NULL;
          EXCEPTION
	    WHEN OTHERS THEN
              RETURN 0;
	  END;
      END;

    ELSIF (p_obj_name IS NOT NULL  AND p_top_alternate_designator IS NULL)   THEN

      SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
      WHERE BBOM_C.obj_name = P_OBJ_NAME AND  BBOM_C.pk1_value = p_pk1_value AND
      BBOM_C.organization_id = p_organization_id AND BBOM_C.alternate_bom_designator is NULL;

    ELSIF (p_obj_name IS NOT NULL AND p_top_alternate_designator IS NOT NULL) THEN

      SELECT BBOM_C.bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b BBOM_C
      WHERE BBOM_C.obj_name = P_OBJ_NAME AND  BBOM_C.pk1_value = p_pk1_value AND
      BBOM_C.organization_id = p_organization_id AND BBOM_C.alternate_bom_designator = p_top_alternate_designator;

    END IF;

    RETURN l_bill_sequence_id;

    EXCEPTION WHEN OTHERS THEN

      RETURN 0;

  END;

  FUNCTION Get_Sort_Order (p_parent_sort_order IN VARCHAR2,
                           p_component_quantity IN NUMBER := NULL)
  RETURN VARCHAR2 IS

  BEGIN

    IF p_parent_sort_order <> g_parent_sort_order THEN

      g_parent_sort_order_tbl(g_global_count)       := g_parent_sort_order;
      g_quantity_of_children_tbl(g_global_count)    := g_sort_count;
      g_total_qty_at_next_level_tbl(g_global_count) := g_total_quantity;

      g_sort_count        := 0;
      g_total_quantity    := 0;
      g_parent_sort_order := p_parent_sort_order;
      g_global_count      := g_global_count + 1;

    END IF;

    g_sort_count      := g_sort_count + 1;
    g_total_quantity  := g_total_quantity + p_component_quantity;

    Return (g_parent_sort_order||lpad(to_char(g_sort_count), G_SortWidth, '0'));

  END;

  /*****************************************************************************************
  * Procedure  : Get_Change_Policy_Val
  * Parameters : p_item_rev_id -- Item Revi
  *            : p_bill_seq_id -- Bill Sequence Id
  * Purpose    : This procedure is called to get change policy value for the structure.
  *              The values will 1 (ALLOWED) or 2(CHANGE_ORDER_REQUIRED) or 3 (NOT_ALLOWED)
  *
  ********************************************************************************************/
  FUNCTION Get_Change_Policy_Val (p_item_rev_id IN NUMBER,
                                  p_bill_seq_id IN NUMBER)
  RETURN VARCHAR2 IS

  l_change_policy_val NUMBER;
  l_change_policy_char_val VARCHAR2(80);

  BEGIN

    SELECT
        ecp.policy_char_value INTO l_change_policy_char_val
    FROM
         MTL_SYSTEM_ITEMS ITEM_DTLS, ENG_CHANGE_POLICIES_V ECP, Bom_Structures_b bsb
    WHERE
         ecp.policy_object_pk1_value =
              (SELECT TO_CHAR(ic.item_catalog_group_id)
               FROM mtl_item_catalog_groups_b ic
               WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                             FROM EGO_OBJ_TYPE_LIFECYCLES olc
                             WHERE olc.object_id = (SELECT OBJECT_ID
                                                    FROM fnd_objects
                                                    WHERE obj_name = 'EGO_ITEM')
                             AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                             AND olc.object_classification_code = ic.item_catalog_group_id
                             )
                AND ROWNUM = 1
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
    AND ecp.policy_object_pk2_value = ITEM_DTLS.lifecycle_id
    AND ecp.policy_object_pk3_value = ITEM_DTLS.current_phase_id
    AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
    AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
    AND ecp.attribute_code = 'STRUCTURE_TYPE'
    AND bsb.Structure_Type_id = ecp.attribute_number_value
    AND bsb.Assembly_item_id = ITEM_DTLS.inventory_item_id
    AND bsb.organization_id = ITEM_DTLS.organization_id
    AND bsb.Bill_Sequence_id = p_bill_seq_id;


    RETURN l_change_policy_char_val;

  EXCEPTION WHEN OTHERS THEN
    RETURN 'ALLOWED';

  END Get_Change_Policy_Val;


  /*****************************************************************************************
  * Procedure  : Insert_Attachments
  * Scope      : Local
  * Parameters : p_group_id
  * Purpose    : This procedure is called at the end of the explosion call to insert attachments
  *              for all the nodes in the tree
  *              The sort order of the attachment will be computed as sort_order + rowcount of the attachment
  *              so that it pushes the attachments as children of the component
  *
  ********************************************************************************************/
  PROCEDURE Insert_Attachments( p_group_id IN NUMBER
            , p_plan_level IN NUMBER
             )
  IS
  BEGIN
  INSERT INTO BOM_EXPLOSIONS_ALL
  ( top_bill_sequence_id
   ,bill_sequence_id
   ,organization_id
   ,explosion_type
   ,component_sequence_id
   ,component_item_id
   ,plan_level
   ,sort_order
   ,creation_date
   ,created_by
   ,last_update_date
   ,last_updated_by
   ,top_item_id
   ,basis_type
   ,component_quantity
   ,assembly_item_id
   ,item_num
   ,comp_bill_seq_id
   ,group_id
   ,alternate_bom_designator
   ,parent_sort_order
   ,structure_type_id
   ,pk1_value
   ,hgrid_flag
   ,revision_id
   ,effectivity_control
   ,access_flag
   ,line_id
   ,obj_name
         ,exploded_option
         ,rexplode_flag
   ,exploded_date
   ,exploded_unit_number
   ,exploded_end_item_rev
  )
   SELECT
    BET.TOP_BILL_SEQUENCE_ID,
    BET.BILL_SEQUENCE_ID,
    BET.ORGANIZATION_ID,
    BET.EXPLOSION_TYPE,
    ATDOCS.SEQ_NUM COMPONENT_SEQUENCE_ID,
    ATDOCS.ATTACHED_DOCUMENT_ID COMPONENT_ITEM_ID,
    plan_level +1 ,
    bet.sort_order||'99'||LPAD(ROWNUM, 6, '0') SORT_ORDER,
    BET.CREATION_DATE ,
    BET.CREATED_BY ,
    ATDOCS.LAST_UPDATE_DATE ,
    ATDOCS.LAST_UPDATED_BY ,
    BET.TOP_ITEM_ID,
    1 BASIS_TYPE,
    1 COMPONENT_QUANTITY,
    BET.COMPONENT_ITEM_ID ASSEMBLY_ITEM_ID ,
    ATDOCS.ATTACHED_DOCUMENT_ID ITEM_NUM ,
    BET.COMP_BILL_SEQ_ID ,
    BET.GROUP_ID ,
    BOM_GLOBALS.GET_ALTERNATE(BET.BILL_SEQUENCE_ID) ALT_BOM_DESG,
    BET.SORT_ORDER PARENT_SORT_ORDER,
    BET.STRUCTURE_TYPE_ID STRUCTURE_TYPE_ID ,
    TO_CHAR(ATDOCS.ATTACHED_DOCUMENT_ID) PK1_VALUE,
    BET.HGRID_FLAG HGRID_FLAG ,
    BET.REVISION_ID REVISION_ID ,
    BET.EFFECTIVITY_CONTROL EFFECTIVITY_CONTROL,
    BET.ACCESS_FLAG ACCESS_FLAG,
    ATDOCS.category_id,
    'ATTACHMENT',
    BET.EXPLODED_OPTION,
    0,  -- default insert attachment with rexplode flag of 0
    BET.exploded_date,
    BET.exploded_unit_number,
    BET.exploded_end_item_rev
   FROM BOM_EXPLOSIONS_ALL BET ,
        FND_ATTACHED_DOCUMENTS ATDOCS,
        FND_DOCUMENTS_TL DOCTL
  WHERE ATDOCS.DOCUMENT_ID = DOCTL.DOCUMENT_ID
    AND DOCTL.LANGUAGE = USERENV('LANG')
    AND ( ( ATDOCS.ENTITY_NAME = 'MTL_SYSTEM_ITEMS'
       AND ATDOCS.PK1_VALUE = TO_CHAR(BET.ORGANIZATION_ID)
       AND ATDOCS.PK2_VALUE = TO_CHAR(BET.COMPONENT_ITEM_ID) )
     OR
     ( ATDOCS.ENTITY_NAME = 'MTL_ITEM_REVISIONS'
       AND ATDOCS.PK1_VALUE = TO_CHAR(BET.ORGANIZATION_ID)
        AND ATDOCS.PK2_VALUE = TO_CHAR(BET.COMPONENT_ITEM_ID)
      AND ATDOCS.PK3_VALUE = BET.REVISION_ID ) )
    AND ATDOCS.CATEGORY_ID IN
        ( SELECT BIA.attach_category_id FROM BOM_ITEM_ATTACH_CATEGORY_ASSOC BIA
       WHERE BIA.STRUCTURE_TYPE_ID IN
            ( SELECT bst1.structure_type_id
                FROM BOM_STRUCTURE_TYPES_B bst1
                  CONNECT BY PRIOR bst1.parent_structure_type_id = bst1.structure_type_id
                  START WITH bst1.structure_type_id =
              ( select strb.structure_type_id
                        from bom_structures_b strb
           where strb.bill_sequence_id = bet.bill_sequence_id
               )
             )
    )
     AND group_id = p_group_id
     AND plan_level = p_plan_level
     AND NVL(obj_name,'EGO_ITEM') = 'EGO_ITEM';


  --Dbms_Output.put_line('insert for plan level: ' || p_plan_level || ' no: ' || SQL%ROWCOUNT);
  /*
  for c in (select item_name from bom_explosions_v where explode_group_id = p_group_id
                                                           and plan_level = 0
     )
        loop

    Dbms_Output.put_line('file name: ' || c.item_name);
  end loop;
  */
  END Insert_Attachments;


  /****************************************************************************
  * Procedure : Apply_Exclusion_Rules
  * Parameters  : p_Group_Id
  * Scope : Local
  * Purpose : This procedure is invoked at the end of explosion. It will
  *     look at the defined rules for various bills and apply them
  *     to the explosion identified by p_Group_Id.
  *     Instead of pruning the tree based on the exclusion rule, the
  *     nodes in the tree are stamped. Is_Excluded_By_Rule column will
  *     be set to 'Y' if a node is excluded.
  ******************************************************************************/
  PROCEDURE Apply_Exclusion_Rules (p_Group_Id  IN NUMBER, reApply IN  NUMBER DEFAULT 0)
  IS
    exclusion_t dbms_sql.varchar2_table;
  BEGIN
     SELECT '%'||d.exclusion_path || '%'
       BULK COLLECT INTO exclusion_t
       FROM bom_rules_b r,
            bom_exclusion_rule_def d
      WHERE d.rule_id = r.rule_id
        AND d.from_revision_id IS NULL
        AND d.implementation_date IS NOT NULL
        AND d.disable_date IS NULL
        AND d.acd_type = 1
        AND r.bill_sequence_id IN
            (SELECT bill_sequence_id
               FROM BOM_EXPLOSIONS_ALL
              WHERE group_id = p_Group_Id
            );

      IF (reApply = 1) THEN
          UPDATE BOM_EXPLOSIONS_ALL
             SET is_excluded_by_rule = NULL
           WHERE group_id = p_Group_Id
                 AND is_excluded_by_rule = 'Y';
      END IF;

      UPDATE BOM_EXPLOSIONS_ALL
         SET reapply_exclusions = NULL
      WHERE group_id = p_Group_Id AND plan_level = 0;

      FORALL i in 1..exclusion_t.count
          UPDATE BOM_EXPLOSIONS_ALL
             SET is_excluded_by_rule = 'Y'
           WHERE group_id = p_Group_Id
             AND new_component_code like exclusion_t(i);
  END;/* Procedure Apply_Exclusion_Rules Ends */

  /****************************************************************************
  * Procedure : Apply_New_Exclusion_Rules
  * Parameters  : p_bill_sequence_id
  * Scope : Local
  * Purpose : This procedure is invoked when new explosion rules have been added
  ******************************************************************************/
  PROCEDURE Apply_New_Exclusion_Rules (p_bill_sequence_id  IN NUMBER)
  IS
    exclusion_t dbms_sql.varchar2_table;
  BEGIN
     SELECT '%'||d.exclusion_path || '%'
       BULK COLLECT INTO exclusion_t
       FROM bom_rules_b r,
            bom_exclusion_rule_def d
      WHERE d.rule_id = r.rule_id
        AND d.from_revision_id IS NULL
        AND d.implementation_date IS NOT NULL
        AND d.disable_date IS NULL
        AND d.acd_type = 1
        AND r.bill_sequence_id = p_bill_sequence_id;

      FORALL i in 1..exclusion_t.count
          UPDATE BOM_EXPLOSIONS_ALL
             SET is_excluded_by_rule = 'Y'
           WHERE group_id IN
                 (SELECT t.Group_Id FROM BOM_EXPLOSIONS_ALL t
                    WHERE t.bill_sequence_id = p_bill_sequence_id
                 )
             AND new_component_code like exclusion_t(i);
  END; /* Procedure Apply_New_Exclusion_Rules Ends */

  /****************************************************************************
  * Procedure : Set_Reapply_Exclusion_Flag
  * Parameters  : p_bill_sequence_id
  * Scope : Local
  * Purpose : This procedure sets the reapply_exclusions flag to 'Y' for all the
  *          structures where this structure is added as substructure.
  *          Only the rows with plan_level=0 will be modified.
  ******************************************************************************/
  PROCEDURE Set_Reapply_Exclusion_Flag (p_bill_sequence_id  IN NUMBER)
  IS
  BEGIN
    UPDATE BOM_EXPLOSIONS_ALL
      SET reapply_exclusions = 'Y'
    WHERE Top_bill_sequence_id IN
        (SELECT Top_bill_sequence_id FROM BOM_EXPLOSIONS_ALL
           WHERE bill_sequence_id = p_bill_sequence_id
        )
      AND plan_level = 0;
  END;/* Procedure Set_Reapply_Exclusion_Flag Ends */

  /* If the component node is excluded, this function will return 'Y' otherwise null */

  FUNCTION Check_Excluded_By_Rule (p_component_code IN VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    IF rev_specific_exclusions_array.COUNT = 0
    THEN
      Return null;
    END IF;

    FOR i IN 1..rev_specific_exclusions_array.COUNT
    LOOP
      IF instr(p_component_code, rev_specific_exclusions_array(i)) <> 0
      THEN
        Return 'Y';
      END IF;
    END LOOP;
    Return null;
  END;

 /* If the component does not have access, this function will return 'F' otherwise 'T' */
  FUNCTION Check_Component_Access (p_component_code IN VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    FOR i IN 1..asss_without_access_array.COUNT
    LOOP
      IF instr(p_component_code, asss_without_access_array(i)) <> 0
      THEN
        Return 'F';
      END IF;
    END LOOP;
    Return 'T';
  END;


  PROCEDURE bom_exploder(
  verify_flag   IN NUMBER DEFAULT 0,
  online_flag   IN NUMBER DEFAULT 1,
  org_id      IN NUMBER,
  order_by    IN NUMBER DEFAULT 1,
  grp_id      IN NUMBER,
  levels_to_explode   IN NUMBER DEFAULT 1,
  bom_or_eng    IN NUMBER DEFAULT 1,
  impl_flag   IN NUMBER DEFAULT 1,
  plan_factor_flag  IN NUMBER DEFAULT 2,
  explode_option    IN NUMBER DEFAULT 2,
  std_comp_flag   IN NUMBER DEFAULT 2,
  incl_oc_flag    IN NUMBER DEFAULT 1,
  max_level   IN NUMBER,
  unit_number   IN VARCHAR2,
  rev_date    IN DATE DEFAULT sysdate,
  object_rev_id  IN NUMBER,
  minor_rev_id IN NUMBER,
  show_rev          IN NUMBER DEFAULT 2,
  material_ctrl     IN NUMBER DEFAULT 2,
  lead_time   IN NUMBER DEFAULT 2,
  object_name          IN VARCHAR2 DEFAULT NULL,
  pk_value1         IN VARCHAR2 DEFAULT NULL,
  pk_value2         IN VARCHAR2 DEFAULT NULL,
  pk_value3         IN VARCHAR2 DEFAULT NULL,
  pk_value4         IN VARCHAR2 DEFAULT NULL,
  pk_value5         IN VARCHAR2 DEFAULT NULL,
  end_item_id  IN NUMBER DEFAULT NULL,
  end_item_org_id  IN NUMBER DEFAULT NULL,
  end_item_rev_id  IN NUMBER DEFAULT NULL,
  end_item_minor_rev_id  IN NUMBER DEFAULT NULL,
  end_item_minor_rev_code  IN VARCHAR2 DEFAULT NULL,
  filter_pbom       IN VARCHAR2 DEFAULT NULL,
  top_bill_sequence IN NUMBER,
  err_msg     IN OUT NOCOPY VARCHAR2,
  error_code    IN OUT NOCOPY NUMBER,
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'  --change made for P4Telco CMR, bug# 8761845
  ) IS

    prev_sort_order   VARCHAR2(4000);
    prev_top_bill_id    NUMBER;
    cum_count     NUMBER;
    total_rows      NUMBER;
    cat_sort      VARCHAR2(7);
    impl_eco                    varchar2(20);

    -- verify local vars
    cur_component               VARCHAR2(20);
    cur_substr                  VARCHAR2(20);
    cur_loopstr                 VARCHAR2(4000);
    cur_loopflag                VARCHAR2(1);
    loop_found                  BOOLEAN := false;
    max_level_exceeded          BOOLEAN := false;
    start_pos                   NUMBER;

    l_end_item_id   NUMBER := end_item_id;
    l_end_item_org_id   NUMBER := end_item_org_id;
    l_end_item_rev_id   NUMBER := end_item_rev_id;
    l_end_item_minor_rev_id   NUMBER := end_item_minor_rev_id;
    l_end_item_minor_rev_code  VARCHAR2(30) := end_item_minor_rev_code;

    CURSOR exploder (
    c_level NUMBER,
    c_grp_id NUMBER,
    c_org_id NUMBER,
    c_bom_or_eng NUMBER,
    c_rev_date date,
    c_impl_flag NUMBER,
    c_explode_option NUMBER,
    c_order_by NUMBER,
    c_verify_flag NUMBER,
    c_plan_factor_flag NUMBER,
    c_std_comp_flag NUMBER,
    c_incl_oc NUMBER,
    c_std_bom_explode_flag VARCHAR2  --change made for P4Telco CMR, bug# 8761845
    ) IS
    SELECT /*+ LEADING(bet) */
    BET.TOP_BILL_SEQUENCE_ID TBSI,
    BOM.BILL_SEQUENCE_ID BSI,
    BOM.COMMON_BILL_SEQUENCE_ID CBSI,
    nvl(BOM.COMMON_ORGANIZATION_ID,BOM.ORGANIZATION_ID) COI,
    BOM.ORGANIZATION_ID OI,
    BIC.COMPONENT_SEQUENCE_ID CSI,
    BIC.PK1_VALUE CID,
    BIC.BASIS_TYPE BT,
    BIC.COMPONENT_QUANTITY CQ,
    C_LEVEL PLAN_LEVEL,
    (BIC.COMPONENT_QUANTITY *  decode(BIC.BASIS_TYPE, 1,BET.EXTENDED_QUANTITY,1) *
    decode(c_plan_factor_flag, 1, BIC.PLANNING_FACTOR/100, 1) /
    decode(BIC.COMPONENT_YIELD_FACTOR, 0, 1,BIC.COMPONENT_YIELD_FACTOR)) EQ,
    TO_CHAR(NULL) SO,
    C_GRP_ID GROUP_ID,
    BET.TOP_ALTERNATE_DESIGNATOR TAD,
    BIC.COMPONENT_YIELD_FACTOR CYF,
    BET.TOP_ITEM_ID TID,
    BET.COMPONENT_CODE CC,
    BIC.INCLUDE_IN_COST_ROLLUP IICR,
    BET.LOOP_FLAG LF,
    BIC.PLANNING_FACTOR PF,
    BIC.OPERATION_SEQ_NUM OSN,
    BIC.BOM_ITEM_TYPE BIT,
    BET.BOM_ITEM_TYPE PBIT,
    --to_char(BET.COMPONENT_ITEM_ID) PAID,
    BET.PK1_VALUE PAID,
    BOM.ALTERNATE_BOM_DESIGNATOR, -- for routing
    BIC.WIP_SUPPLY_TYPE WST,
    BIC.ITEM_NUM ITN,
    BIC.EFFECTIVITY_DATE ED,
    BIC.DISABLE_DATE DD,
    /*
    Greatest(BIC.EFFECTIVITY_DATE,Nvl(BET.EFFECTIVITY_DATE,BIC.EFFECTIVITY_DATE)) TED,
    Least(Nvl(BIC.DISABLE_DATE,BET.DISABLE_DATE),Nvl(BET.DISABLE_DATE,BIC.DISABLE_DATE)) TDD,
    */
    /* When there is a fixed parent rev, then the trimmed eff dt and trimmed disable dt are same as eff date
       and dis date, as the effectivity check is anyways reapplied in the view */
    decode(BET.COMP_FIXED_REV_HIGH_DATE,
           null,
           Greatest(BIC.EFFECTIVITY_DATE,Nvl(BET.TRIMMED_EFFECTIVITY_DATE,BIC.EFFECTIVITY_DATE)),
           BIC.EFFECTIVITY_DATE) TED,
    --Greatest(BIC.EFFECTIVITY_DATE,Nvl(BET.TRIMMED_EFFECTIVITY_DATE,BIC.EFFECTIVITY_DATE)) TED,
    decode(BET.COMP_FIXED_REV_HIGH_DATE,
           null,
           Least(Nvl(BIC.DISABLE_DATE,BET.TRIMMED_DISABLE_DATE),Nvl(BET.TRIMMED_DISABLE_DATE,BIC.DISABLE_DATE)),
           BIC.DISABLE_DATE) TDD,
    --Least(Nvl(BIC.DISABLE_DATE,BET.TRIMMED_DISABLE_DATE),Nvl(BET.TRIMMED_DISABLE_DATE,BIC.DISABLE_DATE)) TDD,
    BIC.FROM_END_ITEM_UNIT_NUMBER  FUN,
    BIC.TO_END_ITEM_UNIT_NUMBER EUN,
    /*
    Greatest(BIC.FROM_END_ITEM_UNIT_NUMBER,Nvl(BET.FROM_END_ITEM_UNIT_NUMBER,BIC.FROM_END_ITEM_UNIT_NUMBER)) TFUN,
    Least(Nvl(BIC.TO_END_ITEM_UNIT_NUMBER,BET.TO_END_ITEM_UNIT_NUMBER),Nvl(BET.TO_END_ITEM_UNIT_NUMBER,BIC.TO_END_ITEM_UNIT_NUMBER)) TEUN,
    */
    Greatest(BIC.FROM_END_ITEM_UNIT_NUMBER,Nvl(BET.TRIMMED_FROM_UNIT_NUMBER,BIC.FROM_END_ITEM_UNIT_NUMBER)) TFUN,
    Least(Nvl(BIC.TO_END_ITEM_UNIT_NUMBER,BET.TRIMMED_TO_UNIT_NUMBER),Nvl(BET.TRIMMED_TO_UNIT_NUMBER,BIC.TO_END_ITEM_UNIT_NUMBER)) TEUN,
    BIC.IMPLEMENTATION_DATE ID,
    --decode(BIC.IMPLEMENTATION_DATE,null,BIC.IMPLEMENTATION_DATE,decode(BET.IMPLEMENTATION_DATE,null,BET.IMPLEMENTATION_DATE,BIC.IMPLEMENTATION_DATE)) ID,
    --decode(BIC.IMPLEMENTATION_DATE,null,null,decode(BET.IMPLEMENTATION_DATE,null,null,BIC.IMPLEMENTATION_DATE)) ID,
    --decode(BET.IMPLEMENTATION_DATE,null,null,BIC.IMPLEMENTATION_DATE) ID,
    BIC.OPTIONAL OPT,
    BIC.SUPPLY_SUBINVENTORY SS,
    BIC.SUPPLY_LOCATOR_ID SLI,
    BIC.COMPONENT_REMARKS CR,
    BIC.CHANGE_NOTICE CN,
    --decode(BIC.IMPLEMENTATION_DATE,null,BIC.CHANGE_NOTICE,decode(BET.IMPLEMENTATION_DATE,null,BET.CHANGE_NOTICE,BIC.CHANGE_NOTICE)) CN,
    --decode(BET.IMPLEMENTATION_DATE,null,BET.CHANGE_NOTICE,BIC.CHANGE_NOTICE) CN,
    BIC.OPERATION_LEAD_TIME_PERCENT OLTP,
    BIC.MUTUALLY_EXCLUSIVE_OPTIONS MEO,
    BIC.CHECK_ATP CATP,
    BIC.REQUIRED_TO_SHIP RTS,
    BIC.REQUIRED_FOR_REVENUE RFR,
    BIC.INCLUDE_ON_SHIP_DOCS IOSD,
    BIC.LOW_QUANTITY LQ,
    BIC.HIGH_QUANTITY HQ,
    BIC.SO_BASIS SB,
    BET.OPERATION_OFFSET,
    BET.CURRENT_REVISION,
    BET.LOCATOR,
    BIC.ATTRIBUTE_CATEGORY,
    BIC.ATTRIBUTE1,
    BIC.ATTRIBUTE2,
    BIC.ATTRIBUTE3,
    BIC.ATTRIBUTE4,
    BIC.ATTRIBUTE5,
    BIC.ATTRIBUTE6,
    BIC.ATTRIBUTE7,
    BIC.ATTRIBUTE8,
    BIC.ATTRIBUTE9,
    BIC.ATTRIBUTE10,
    BIC.ATTRIBUTE11,
    BIC.ATTRIBUTE12,
    BIC.ATTRIBUTE13,
    BIC.ATTRIBUTE14,
    BIC.ATTRIBUTE15,
    BIC.obj_name,
    BIC.pk1_value,
    BIC.pk2_value,
    BIC.pk3_value,
    BIC.pk4_value,
    BIC.pk5_value,
    BIC.from_end_item_rev_id FEREVID,
    BIC.from_end_item_minor_rev_id FEMREVID,
    BIC.to_end_item_rev_id TEREVID,
    BIC.to_end_item_minor_rev_id TEMREVID,
    BET.NEW_COMPONENT_CODE CLCC,
    BET.SORT_ORDER PARENT_SORT_ORDER,
    to_number(NULL) CCBSI,
    BOM_EXPLODER_PUB.Get_Comp_Bill_Seq_Id (BIC.OBJ_NAME, BET.TOP_ALTERNATE_DESIGNATOR,
                                           --NVL(BET.COMMON_ORGANIZATION_ID,BET.ORGANIZATION_ID),
                                           BET.ORGANIZATION_ID,
                                           BIC.pk1_value,BIC.pk2_value) CBSID, -- comp_bill_seq_id
    'T' ACFLAG,
    BOM.ASSEMBLY_TYPE AST,
    to_char(NULL) REVISION_LABEL,
    to_number(NULL) REVISION_ID,
    BOM.EFFECTIVITY_CONTROL BEFC,
    to_number(NULL) OREVID,
    to_number(NULL) MREVID,
    to_char(NULL) MREVCODE,
    BIC.FROM_OBJECT_REVISION_ID FORI,
    BIC.FROM_MINOR_REVISION_ID FMRI,
    BIC.TO_OBJECT_REVISION_ID TORI,
    BIC.TO_MINOR_REVISION_ID TMRI,
    /* If the BOM is commoned across org, then do not pick up the fixed component item revision id */
    /*DECODE( SIGN(BET.ORGANIZATION_ID - BET.COMMON_ORGANIZATION_ID),
            0,
            BIC.COMPONENT_ITEM_REVISION_ID,
            NULL) COMPONENT_ITEM_REVISION_ID,*/
    --Commented by arudresh for bug 5235768. If a component exists as a fixed rev, the rev must exist
    --in all orgs in which the BOM is commoned. This check is enforced during common bom creation.
    BIC.COMPONENT_ITEM_REVISION_ID,
    BIC.COMPONENT_MINOR_REVISION_ID,
    BOM.IMPLEMENTATION_DATE,
    BET.TOP_GTIN_NUMBER TGTIN,
    BET.TOP_GTIN_DESCRIPTION TGTIN_DESC,
    BET.TOP_TRADE_ITEM_DESCRIPTOR TTRADE_DESC,
    BET.GTIN_NUMBER PGTIN,
    BET.GTIN_DESCRIPTION PGTIN_DESC,
    BET.TRADE_ITEM_DESCRIPTOR PTRADE_DESC,
    BIC.CREATION_DATE CRDATE,
    BIC.CREATED_BY CRBY,
    BIC.LAST_UPDATE_DATE LUDATE,
    BIC.LAST_UPDATED_BY LUBY,
    BIC.AUTO_REQUEST_MATERIAL AREQ,
    decode(nvl(comp_common_bill_seq_id,'0'),'0','0','1') REEXPLODE,
    BIC.ACD_TYPE ACD,
    --decode(BIC.IMPLEMENTATION_DATE,null,BIC.ACD_TYPE,decode(BET.IMPLEMENTATION_DATE,null,BET.ACD_TYPE,BIC.ACD_TYPE)) ACD,
    --decode(BET.IMPLEMENTATION_DATE,null,BET.ACD_TYPE,BIC.ACD_TYPE) ACD,
    BIC.QUANTITY_RELATED QTR,
    'ALLOWED',--BET.CHANGE_POLICY_VALUE,
    BET.EXPLODED_OPTION EXPOP,
    BOM.STRUCTURE_TYPE_ID STYPE,
    BET.COMP_FIXED_REV_HIGH_DATE CRHGDT,
    NVL(BET.COMPONENT_ITEM_REVISION_ID,BET.COMP_FIXED_REVISION_ID) FPR,
    BET.COMPONENT_SEQUENCE_ID PCSEQ,
    BOM.IS_PREFERRED,
    decode(BET.PARENT_IMPLEMENTATION_DATE,null,BET.PARENT_IMPLEMENTATION_DATE,BET.IMPLEMENTATION_DATE) PID,
    NVL( DECODE(BET.IMPLEMENTATION_DATE,null,BET.CHANGE_NOTICE,null), BET.PARENT_CHANGE_NOTICE) PCN    ,
    BOM.SOURCE_BILL_SEQUENCE_ID SBSI,
    BIC.COMMON_COMPONENT_SEQUENCE_ID CCSI,
    to_number(NULL) CSBSI,
    to_number(NULL) COMP_EFFECTIVITY_CONTROL
    FROM
      --BOM_PLM_EXPLOSION_TEMP BET,
      BOM_EXPLOSIONS_ALL BET,
      BOM_STRUCTURES_B BOM,
      BOM_COMPONENTS_B BIC
    WHERE   BET.GROUP_ID = c_grp_id
    AND BET.PLAN_LEVEL = c_level - 1
    /* Do not explode the component if it is a pending change (disable, change)) */
    AND (BET.PLAN_LEVEL = 0
        OR BET.IMPLEMENTATION_DATE IS NOT NULL
        OR BET.ACD_TYPE = 1)
    AND BET.REXPLODE_FLAG = 1
    AND BET.ACCESS_FLAG = 'T'
    AND BET.COMP_BILL_SEQ_ID IS NOT NULL
    AND BET.COMP_BILL_SEQ_ID = BOM.BILL_SEQUENCE_ID

    -- Link BOM AND Components
    AND BOM.COMMON_BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID

    AND NVL(BIC.ECO_FOR_PRODUCTION,2) = 2

    -- This check is valid only IF the BOM AND Component both are inventory items

    AND ( (BET.obj_name IS NULL AND BIC.obj_name IS NULL
    AND (c_std_comp_flag = 1 -- only std components
    AND BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 2)
    OR
    (c_std_comp_flag = 2)
    OR
    (c_std_comp_flag = 3 AND nvl(BET.BOM_ITEM_TYPE, 1) IN (1,2)
    AND (BIC.BOM_ITEM_TYPE IN (1,2)
    OR
    (BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 1)))
    ) OR 1=1 )


    AND ( (c_bom_or_eng = 1 AND BOM.ASSEMBLY_TYPE = 1)
    OR
    (c_bom_or_eng = 2)
    )
    --uncommented by arudresh for bug: 4422266

    -- whether to include option classes AND models under a standard item
    -- special logic added at CST request
    -- This check is valid only IF the BOM AND Component both are inventory items

    AND ( (BET.obj_name IS NULL AND BIC.obj_name IS NULL
    AND (c_incl_oc = 1)
    or
    (c_incl_oc = 2 AND
    ( BET.BOM_ITEM_TYPE = 4 AND BIC.BOM_ITEM_TYPE = 4)
    OR ( BET.BOM_ITEM_TYPE <> 4)))
    OR 1 = 1)

    --change made for P4Telco CMR, bug# 8761845
    AND ( (c_std_bom_explode_flag = 'N' AND BET.BOM_ITEM_TYPE <> 4)
          OR (c_std_bom_explode_flag = 'Y')
        )
    -- do not explode IF immediate parent is standard AND current
    -- component is option class or model - special logic for config items
    AND ( (BET.obj_name IS NULL
    AND NOT ( BET.PARENT_BOM_ITEM_TYPE = 4 AND  BET.BOM_ITEM_TYPE IN (1,2)))
    OR (BET.obj_name IS NOT NULL))

    AND (
    ( NVL(BOM.EFFECTIVITY_CONTROL,1) = 2  -- Unit/Serial Effectivity
    AND ( (c_explode_option = 1)  --  ALL
    OR (c_explode_option IN (2,3) AND BIC.DISABLE_DATE IS NULL
    AND BIC.from_end_item_unit_number IS NOT NULL
    AND ( (c_explode_option = 2
          AND unit_number >= BIC.from_end_item_unit_number
          AND (BIC.to_end_item_unit_number is null OR unit_number <= Nvl( BIC.to_end_item_unit_number, unit_number)))--bug14116670
          OR
          (c_explode_option = 3
          AND (BIC.to_end_item_unit_number is null OR unit_number <= Nvl( BIC.to_end_item_unit_number, unit_number)))--bug14116670
        )
    AND ( (c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
    OR c_impl_flag = 2 ))
    )
    )
    OR
    ( NVL(BOM.EFFECTIVITY_CONTROL,1) = 4 -- End Item rev effectivity
      AND ( (c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
            OR c_impl_flag = 2 )
      AND
      ( (c_explode_option = 1)  --  ALL
       /*Have separated the logic of CURRENT and CURRENT and FUTURE for bug 8635467 with base bug 8628001*/
                       OR (C_EXPLODE_OPTION = 3  --  Current and Future
                           AND BIC.DISABLE_DATE IS NULL
                           AND BIC.FROM_END_ITEM_REV_ID IS NOT NULL
                           AND ((BET.PLAN_LEVEL > 0
                                 AND EXISTS (SELECT NULL
                                             FROM   MTL_ITEM_REVISIONS_B
                                             WHERE  INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                                                    AND ORGANIZATION_ID = BET.ORGANIZATION_ID
                                                    AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID)
                                 AND (BIC.TO_END_ITEM_REV_ID IS NULL
                                      OR (NVL(BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(BET.COMPONENT_ITEM_ID,BET.ORGANIZATION_ID,C_REV_DATE),
                                         (SELECT STARTING_REVISION
                                          FROM   MTL_PARAMETERS
                                          WHERE  ORGANIZATION_ID = BET.ORGANIZATION_ID)) <= (SELECT REVISION
                                                                                             FROM   MTL_ITEM_REVISIONS_B
                                                                                             WHERE  INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                                                                                                    AND ORGANIZATION_ID = BET.ORGANIZATION_ID
                                                                                                    AND REVISION_ID = BIC.TO_END_ITEM_REV_ID))))
                           OR (EXISTS (SELECT NULL
                                        FROM   MTL_ITEM_REVISIONS_B
                                        WHERE  INVENTORY_ITEM_ID = L_END_ITEM_ID
                                        AND ORGANIZATION_ID = L_END_ITEM_ORG_ID
                                        AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID)
                                AND (BIC.TO_END_ITEM_REV_ID IS NULL
                                OR (BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(L_END_ITEM_ID,L_END_ITEM_ORG_ID,C_REV_DATE) <= (SELECT REVISION
                                                                                                                                      FROM   MTL_ITEM_REVISIONS_B
                                                                                                                                      WHERE  INVENTORY_ITEM_ID = L_END_ITEM_ID
                                                                                                                                             AND ORGANIZATION_ID = L_END_ITEM_ORG_ID
                                                                                                                                             AND REVISION_ID = BIC.TO_END_ITEM_REV_ID))))))
                                                OR (C_EXPLODE_OPTION = 2 --Current
                                                    AND BIC.DISABLE_DATE IS NULL
                           AND BIC.FROM_END_ITEM_REV_ID IS NOT NULL
                           AND ((BET.PLAN_LEVEL > 0
                                 AND EXISTS (SELECT NULL
                                             FROM   MTL_ITEM_REVISIONS_B
                                             WHERE  INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                                                    AND ORGANIZATION_ID = BET.ORGANIZATION_ID
                                                    AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID)
                                 AND  ((NVL(BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(BET.COMPONENT_ITEM_ID,BET.ORGANIZATION_ID,C_REV_DATE),
                                         (SELECT STARTING_REVISION
                                          FROM   MTL_PARAMETERS
                                          WHERE  ORGANIZATION_ID = BET.ORGANIZATION_ID)) > = (SELECT REVISION
                                                                                             FROM   MTL_ITEM_REVISIONS_B
                                                                                             WHERE  INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                                                                                                    AND ORGANIZATION_ID = BET.ORGANIZATION_ID
                                                                                                    AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID))
                                 AND (BIC.TO_END_ITEM_REV_ID IS NULL
                                      OR (NVL(BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(BET.COMPONENT_ITEM_ID,BET.ORGANIZATION_ID,C_REV_DATE),
                                         (SELECT STARTING_REVISION
                                          FROM   MTL_PARAMETERS
                                          WHERE  ORGANIZATION_ID = BET.ORGANIZATION_ID)) <= (SELECT REVISION
                                                                                             FROM   MTL_ITEM_REVISIONS_B
                                                                                             WHERE  INVENTORY_ITEM_ID = BET.COMPONENT_ITEM_ID
                                                                                                    AND ORGANIZATION_ID = BET.ORGANIZATION_ID
                                                                                                    AND REVISION_ID = BIC.TO_END_ITEM_REV_ID))))
                                 )
                           OR (EXISTS (SELECT NULL
                                        FROM   MTL_ITEM_REVISIONS_B
                                        WHERE  INVENTORY_ITEM_ID = L_END_ITEM_ID
                                        AND ORGANIZATION_ID = L_END_ITEM_ORG_ID
                                        AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID)
                                AND ((BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(L_END_ITEM_ID,L_END_ITEM_ORG_ID,C_REV_DATE) >= (SELECT REVISION
                                                                                                                                      FROM   MTL_ITEM_REVISIONS_B
                                                                                                                                      WHERE  INVENTORY_ITEM_ID = L_END_ITEM_ID
                                                                                                                                             AND ORGANIZATION_ID = L_END_ITEM_ORG_ID
                                                                                                                                             AND REVISION_ID = BIC.FROM_END_ITEM_REV_ID))
                                   AND (BIC.TO_END_ITEM_REV_ID IS NULL
                                OR (BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(L_END_ITEM_ID,L_END_ITEM_ORG_ID,C_REV_DATE) <= (SELECT REVISION
                                                                                                                                      FROM   MTL_ITEM_REVISIONS_B
                                                                                                                                      WHERE  INVENTORY_ITEM_ID = L_END_ITEM_ID
                                                                                                                                             AND ORGANIZATION_ID = L_END_ITEM_ORG_ID
                                                                                                                                             AND REVISION_ID = BIC.TO_END_ITEM_REV_ID))))
                                                                                                                                             )))
                                                                ))
                                        /*End of change*/
    /*
    ( NVL(BOM.EFFECTIVITY_CONTROL,1) = 4 -- End Item rev effectivity
      AND ( (c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
            OR c_impl_flag = 2 )
      AND
      ( (c_explode_option = 1)  --  ALL
      OR
      (c_explode_option = 3 -- Current and Future
        AND BIC.DISABLE_DATE IS NULL
        AND BIC.FROM_END_ITEM_REV_ID IS NOT NULL
        AND
        (  (l_end_item_minor_rev_code <= (SELECT concat(to_char(decode(BIC.TO_END_ITEM_REV_ID,null,to_date('9999-12-31','YYYY-MM-DD'),effectivity_date),'yyyymmddhh24miss'),
                                                            to_char(nvl(BIC.to_end_item_minor_rev_id,9999999999999999)))
              FROM mtl_item_revisions_b
              WHERE inventory_item_id = l_end_item_id AND
              organization_id  = l_end_item_org_id AND
              revision_id = nvl(BIC.TO_END_ITEM_REV_ID,BIC.FROM_END_ITEM_REV_ID)))
              OR
            (BET.minor_revision_code <= (SELECT concat(to_char(decode(BIC.TO_END_ITEM_REV_ID,null,to_date('9999-12-31','YYYY-MM-DD'),effectivity_date),'yyyymmddhh24miss'),
                                                            to_char(nvl(BIC.to_end_item_minor_rev_id,9999999999999999)))
              FROM mtl_item_revisions_b
              WHERE inventory_item_id = BET.component_item_id AND
              organization_id  = BET.organization_id AND
              revision_id = nvl(BIC.TO_END_ITEM_REV_ID,BIC.FROM_END_ITEM_REV_ID)))
        )
      )
      OR
      ( c_explode_option = 2  -- Current
      AND BIC.DISABLE_DATE IS NULL
      AND BIC.FROM_END_ITEM_REV_ID IS NOT NULL
      AND
      (
      (l_end_item_minor_rev_code >= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
                                                                  to_char(nvl(BIC.from_end_item_minor_rev_id,0)))
                FROM mtl_item_revisions_b
                WHERE inventory_item_id = l_end_item_id AND
                organization_id  = l_end_item_org_id AND
                revision_id = BIC.FROM_END_ITEM_REV_ID)
        AND  (BIC.to_end_item_rev_id IS NULL OR
              l_end_item_minor_rev_code <= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
                                                             to_char(nvl(BIC.to_end_item_minor_rev_id,9999999999999999)))
              FROM mtl_item_revisions_b
              WHERE inventory_item_id = l_end_item_id AND
              organization_id  = l_end_item_org_id AND
              revision_id = BIC.TO_END_ITEM_REV_ID) ))

      OR

      (BET.minor_revision_code >= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
                                                                     to_char(nvl(BIC.from_end_item_minor_rev_id,0)))
                FROM mtl_item_revisions_b
                WHERE inventory_item_id = BET.component_item_id AND
                organization_id  = BET.organization_id AND
                revision_id = BIC.FROM_END_ITEM_REV_ID)
        AND  (BIC.to_end_item_rev_id IS NULL OR
              BET.minor_revision_code <= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
              to_char(nvl(BIC.to_end_item_minor_rev_id,9999999999999999)))
              FROM mtl_item_revisions_b
              WHERE inventory_item_id = BET.component_item_id AND
              organization_id  = BET.organization_id AND
              revision_id = BIC.TO_END_ITEM_REV_ID)) )
          )
      )


      )
    )
    */
      OR
      ( NVL(BOM.EFFECTIVITY_CONTROL,1) =1 -- Date Effectivity
        AND ((c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL) OR c_impl_flag = 2 )
        AND
        ( (c_explode_option = 1 -- ALL
          AND (c_level - 1 = 0 OR
          -- make sure the component is effective for the parent IF it is other than 1st level
          -- though the option is ALL
          ( BIC.effectivity_date <= nvl(BET.disable_date, BIC.effectivity_date) AND
          NVL(BIC.disable_date, BET.effectivity_date) >= BET.effectivity_date)))
          OR
          ( ( BIC.IMPLEMENTATION_DATE IS NOT NULL AND
          ((c_explode_option = 2 AND
          nvl(BET.comp_fixed_rev_high_date,c_rev_date) >= BIC.EFFECTIVITY_DATE AND
          nvl(BET.comp_fixed_rev_high_date,c_rev_date) < nvl(BIC.DISABLE_DATE, nvl(BET.comp_fixed_rev_high_date,c_rev_date)+1)) -- CURRENT
          OR
          (c_explode_option = 3 AND
          nvl(BIC.DISABLE_DATE, nvl(BET.comp_fixed_rev_high_date,c_rev_date)+ 1) > nvl(BET.comp_fixed_rev_high_date,c_rev_date) )) -- CURRENT AND FUTURE
          )
          OR
          ( BIC.IMPLEMENTATION_DATE IS NULL AND
          nvl(BIC.ACD_TYPE,1) = 3
          OR
          (
            ((c_explode_option = 2 AND
            nvl(BET.comp_fixed_rev_high_date,c_rev_date) >= BIC.EFFECTIVITY_DATE AND
            nvl(BET.comp_fixed_rev_high_date,c_rev_date) < nvl(BIC.DISABLE_DATE, nvl(BET.comp_fixed_rev_high_date,c_rev_date)+1)) -- CURRENT
            OR
            (c_explode_option = 3 AND
            nvl(BIC.DISABLE_DATE, nvl(BET.comp_fixed_rev_high_date,c_rev_date)+ 1) > nvl(BET.comp_fixed_rev_high_date,c_rev_date) )) -- CURRENT AND FUTURE
            )
      )
      ) -- OR
      )-- AND
      )--Date eff
      )

     /*
    AND ( BET.minor_revision_code IS NULL
          OR
          ( BET.minor_revision_code IS NOT NULL AND
            (
              ( BET.OBJ_NAME IS NOT NULL AND
                BET.minor_revision_id BETWEEN nvl(BIC.from_minor_revision_id,BET.minor_revision_id) AND
                                                nvl(BIC.to_minor_revision_id,BET.minor_revision_id))
              OR
              ( BET.OBJ_NAME IS NULL AND
                BET.minor_revision_code >= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
                                                                     to_char(nvl(BIC.from_minor_revision_id,0)))
                              FROM mtl_item_revisions_b WHERE revision_id = BIC.FROM_OBJECT_REVISION_ID)
                AND  (BIC.to_object_revision_id IS NULL OR
                      BET.minor_revision_code <= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),
                                                to_char(nvl(BIC.to_minor_revision_id,9999999999999999)))
                            FROM mtl_item_revisions_b WHERE revision_id = BIC.TO_OBJECT_REVISION_ID))
              )
            )
          )
        )
     */
    AND BET.LOOP_FLAG = 2
    AND ( filter_pbom IS NULL
          OR
          EXISTS (SELECT null FROM ego_items_v WHERE inventory_item_id = BIC.component_item_id AND
                  organization_id = NVL(BET.COMMON_ORGANIZATION_ID,BET.ORGANIZATION_ID) AND
                  TRADE_ITEM_DESCRIPTOR IS NOT NULL)
        )
    /*
    ORDER BY BET.TOP_BILL_SEQUENCE_ID, BET.SORT_ORDER,
    decode(c_order_by, 1, BIC.OPERATION_SEQ_NUM, BIC.ITEM_NUM),
    decode(c_order_by, 1, BIC.ITEM_NUM, BIC.OPERATION_SEQ_NUM) */

    ORDER BY BET.TOP_BILL_SEQUENCE_ID, BET.SORT_ORDER; --Added for bug 9341312

    Cursor Get_Locator (P_Locator in number) is
      Select mil.concatenated_segments
      From mtl_item_locations_kfv mil
      Where mil.inventory_location_id = P_Locator;

    Cursor Get_OLTP (P_Assembly in number,
                      P_Alternate in varchar2,
                      P_Operation in number) is
      Select round(bos.operation_lead_time_percent, 2) oltp
      From Bom_Operation_Sequences bos,
           Bom_Operational_Routings bor
      Where bor.assembly_item_id = P_Assembly
      And   bor.organization_Id = org_id
      And  (bor.alternate_routing_designator = P_Alternate
            or
           (bor.alternate_routing_designator is null AND not exists (
              SELECT null
              FROM bom_operational_routings bor2
              WHERE bor2.assembly_item_id = P_Assembly
              AND   bor2.organization_id = org_id
              AND   bor2.alternate_routing_designator = P_Alternate)
           ))
      And   bor.common_routing_sequence_id = bos.routing_sequence_id
      And   bos.operation_seq_num = P_Operation
      And   bos.effectivity_date <=
            trunc(rev_date)
      And   nvl(bos.disable_date,
                   rev_date + 1) >=
            trunc(rev_date);

    Cursor Calculate_Offset(P_ParentItem in number, P_Percent in number) is
      Select  P_Percent/100 * msi.full_lead_time offset
      From mtl_system_items_b msi
            Where msi.inventory_item_id = P_ParentItem
      And   msi.organization_id = Org_Id;

    No_Revision_Found exception;
    Pragma exception_init(no_revision_found, -20001);

    Cursor l_TopBill_csr is
            Select msi.concatenated_segments,
             bom.alternate_bom_designator
      From mtl_system_items_b_kfv msi,
                 bom_structures_b bom,
           BOM_EXPLOSIONS_ALL bet
      Where msi.inventory_item_id = bom.assembly_item_id
      And   msi.organization_id = bom.organization_id
      And   bom.bill_sequence_id = bet.top_bill_sequence_id
      And   bet.group_id = grp_id
      And   rownum = 1;

    total number;

    /*
    CURSOR getItemRevDetails (p_revision_id IN NUMBER) IS
      SELECT revision_id, revision, revision_label FROM mtl_item_revisions_b WHERE revision_id = p_revision_id;
    */

    CURSOR getCurrentMinorRev (p_obj_name IN VARCHAR2,
                               p_pk1_value IN VARCHAR2,
                               p_pk2_value IN VARCHAR2,
                               p_pk3_value IN VARCHAR2) IS
    SELECT nvl(max(minor_revision_id),0) minor_revision_id FROM ego_minor_revisions
    WHERE obj_name = p_obj_name AND
          pk1_value = p_pk1_value AND
    nvl(pk2_value,'-1') = nvl(p_pk2_value,'-1') AND
    nvl(pk3_value,'-1') = nvl(p_pk3_value,'-1');

    CURSOR getCurrentMinorRevCode (p_revision_id IN NUMBER,
                                   p_minor_rev_id IN NUMBER) IS
      SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(p_minor_rev_id)) mrev_code FROM mtl_item_revisions_b
      WHERE revision_id = p_revision_id;


    CURSOR getItemRevision (p_inventory_item_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_revision_date IN DATE,
                            p_impl_flag IN NUMBER) IS
       SELECT revision,revision_label,revision_id
       FROM   mtl_item_revisions_b MIR
       WHERE  mir.inventory_item_id = p_inventory_item_id
       AND    mir.organization_id = p_organization_id
       AND    mir.effectivity_date  <= p_revision_date
       AND (p_impl_flag = 2  OR (p_impl_flag = 1 AND mir.implementation_date IS NOT NULL) )
       ORDER BY mir.effectivity_date DESC;

    CURSOR checkPkgHkyStructureType (p_structure_type_id IN NUMBER) IS
    SELECT nvl(max(structure_type_id),-1) structure_type_id FROM bom_structure_types_b WHERE structure_type_name ='Packaging Hierarchy'
    AND structure_type_id = p_structure_type_id;

    CURSOR c_Pkg_Structure_Type IS
    SELECT structure_type_id
      FROM bom_structure_types_b
     WHERE structure_type_name = 'Packaging Hierarchy';

    CURSOR getItemRevDetails (p_revision_id IN NUMBER) IS
    SELECT
       DECODE( SIGN(high_date-SYSDATE),
            -1 ,
            'P',
            1  ,
            DECODE( SIGN(effectivity_date-SYSDATE),
                1  ,
                'F',
                'C'
            )  ,
            0  ,
            'C'
           ) Revision_Scope,
       DECODE( SIGN(high_date-SYSDATE),
            -1 ,
            high_date,
            1  ,
            DECODE( SIGN(effectivity_date-SYSDATE),
                1  ,
                effectivity_date,
                SYSDATE
            )  ,
            0  ,
            SYSDATE
           ) Revision_high_date,
        Effectivity_Date, High_Date, Implementation_Date,
        Inventory_Item_Id, Organization_Id, Revision, Revision_label
    FROM
     ( SELECT
          rev1.Organization_Id, rev1.Inventory_Item_Id, rev1.Revision_Id, rev1.Revision, rev1.Effectivity_Date,
          NVL( MIN(rev2.Effectivity_Date - 1/(60*60*24)),
               GREATEST(TO_DATE('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss'), reV1.Effectivity_Date)
             ) High_Date,
          rev1.Implementation_Date, rev1.Change_Notice, rev1.revision_label
       FROM Mtl_Item_Revisions_B rev2 , Mtl_Item_Revisions_B rev1
       WHERE rev1.revision_id = p_revision_id AND rev1.Organization_Id = rev2.Organization_Id(+)
          AND rev1.Inventory_Item_Id = rev2.Inventory_Item_Id(+) AND rev2.Effectivity_Date(+) > rev1.Effectivity_Date
          AND rev2.implementation_date (+) IS NOT NULL
          GROUP BY rev1.Organization_Id, rev1.Inventory_Item_Id, rev1.Revision_Id, rev1.Revision, rev1.Effectivity_Date,
          rev1.Implementation_Date, rev1.Change_Notice, rev1.revision_label);

    l_revision_id     NUMBER;
    l_revision_label  VARCHAR2(100);
    l_revision        VARCHAR2(10);

    l_comp_common_bill_seq_id NUMBER;

    /*
    TYPE be_temp_TYPE IS TABLE OF bom_plm_explosion_temp%ROWTYPE;
    be_temp_TBL be_temp_TYPE;
    */

    --l_batch_size NUMBER := 20000;
    l_batch_size NUMBER := 10000;

    /* Declare pl/sql tables for all coulmns in the select list. BULK BIND and INSERT with
       pl/sql table of records work fine in 9i releases but not in 8i. So, the only option is
       to use individual pl/sql table for each column in the cursor select list */


    TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    TYPE DATE_TBL_TYPE IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;

    /* Declared seperate tables based on the column size since pl/sql preallocates the memory for the varchar variable
        when it is lesser than 2000 chars */

    /*
    TYPE VARCHAR2_TBL_TYPE IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;
    */

    TYPE VARCHAR2_TBL_TYPE_1 IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_3 IS TABLE OF VARCHAR2(3)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_10 IS TABLE OF VARCHAR2(10)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_20 IS TABLE OF VARCHAR2(20)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_25 IS TABLE OF VARCHAR2(25)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_30 IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_40 IS TABLE OF VARCHAR2(40)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_80 IS TABLE OF VARCHAR2(80)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_150 IS TABLE OF VARCHAR2(150)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_240 IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_260 IS TABLE OF VARCHAR2(260)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_1000 IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_2000 IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;

    TYPE VARCHAR2_TBL_TYPE_4000 IS TABLE OF VARCHAR2(4000)
    INDEX BY BINARY_INTEGER;

    top_bill_sequence_id_tbl                    NUMBER_TBL_TYPE;
    bill_sequence_id_tbl                        NUMBER_TBL_TYPE;
    common_bill_sequence_id_tbl                 NUMBER_TBL_TYPE;
    common_organization_id_tbl                  NUMBER_TBL_TYPE;
    organization_id_tbl                         NUMBER_TBL_TYPE;
    component_sequence_id_tbl                   NUMBER_TBL_TYPE;
    component_item_id_tbl                       NUMBER_TBL_TYPE;
    basis_type_tbl				NUMBER_TBL_TYPE;
    component_quantity_tbl                      NUMBER_TBL_TYPE;
    plan_level_tbl                              NUMBER_TBL_TYPE;
    extended_quantity_tbl                       NUMBER_TBL_TYPE;
    sort_order_tbl                              VARCHAR2_TBL_TYPE_2000;
    group_id_tbl                                NUMBER_TBL_TYPE;
    top_alternate_designator_tbl                VARCHAR2_TBL_TYPE_10;
    component_yield_factor_tbl                  NUMBER_TBL_TYPE;
    top_item_id_tbl                             NUMBER_TBL_TYPE;
    component_code_tbl                          VARCHAR2_TBL_TYPE_1000;
    include_in_cost_rollup_tbl                  NUMBER_TBL_TYPE;
    loop_flag_tbl                               NUMBER_TBL_TYPE;
    planning_factor_tbl                         NUMBER_TBL_TYPE;
    operation_seq_num_tbl                       NUMBER_TBL_TYPE;
    bom_item_type_tbl                           NUMBER_TBL_TYPE;
    parent_bom_item_type_tbl                    NUMBER_TBL_TYPE;
    parent_item_id_tbl                          NUMBER_TBL_TYPE;
    alternate_bom_designator_tbl                VARCHAR2_TBL_TYPE_10;
    wip_supply_type_tbl                         NUMBER_TBL_TYPE;
    item_num_tbl                                NUMBER_TBL_TYPE;
    effectivity_date_tbl                        DATE_TBL_TYPE;
    disable_date_tbl                            DATE_TBL_TYPE;
    trimmed_effectivity_date_tbl                DATE_TBL_TYPE;
    trimmed_disable_date_tbl                    DATE_TBL_TYPE;
    trimmed_from_unit_number_tbl                VARCHAR2_TBL_TYPE_30;
    trimmed_to_unit_number_tbl                  VARCHAR2_TBL_TYPE_30;
    from_end_item_unit_number_tbl               VARCHAR2_TBL_TYPE_30;
    to_end_item_unit_number_tbl                 VARCHAR2_TBL_TYPE_30;
    implementation_date_tbl                     DATE_TBL_TYPE;
    optional_tbl                                NUMBER_TBL_TYPE;
    supply_subinventory_tbl                     VARCHAR2_TBL_TYPE_10;
    supply_locator_id_tbl                       NUMBER_TBL_TYPE;
    component_remarks_tbl                       VARCHAR2_TBL_TYPE_240;
    change_notice_tbl                           VARCHAR2_TBL_TYPE_10;
    operation_leadtime_percent_tbl              NUMBER_TBL_TYPE;
    mutually_exclusive_options_tbl              NUMBER_TBL_TYPE;
    check_atp_tbl                               NUMBER_TBL_TYPE;
    required_to_ship_tbl                        NUMBER_TBL_TYPE;
    required_for_revenue_tbl                    NUMBER_TBL_TYPE;
    include_on_ship_docs_tbl                    NUMBER_TBL_TYPE;
    low_quantity_tbl                            NUMBER_TBL_TYPE;
    high_quantity_tbl                           NUMBER_TBL_TYPE;
    so_basis_tbl                                NUMBER_TBL_TYPE;
    operation_offset_tbl                        NUMBER_TBL_TYPE;
    current_revision_tbl                        VARCHAR2_TBL_TYPE_3;
    primary_uom_code_tbl                        VARCHAR2_TBL_TYPE_3;
    primary_uom_desc_tbl                        VARCHAR2_TBL_TYPE_80;
    locator_tbl                                 VARCHAR2_TBL_TYPE_40;
    attribute_category_tbl                      VARCHAR2_TBL_TYPE_30;
    attribute1_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute2_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute3_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute4_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute5_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute6_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute7_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute8_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute9_tbl                              VARCHAR2_TBL_TYPE_150;
    attribute10_tbl                             VARCHAR2_TBL_TYPE_150;
    attribute11_tbl                             VARCHAR2_TBL_TYPE_150;
    attribute12_tbl                             VARCHAR2_TBL_TYPE_150;
    attribute13_tbl                             VARCHAR2_TBL_TYPE_150;
    attribute14_tbl                             VARCHAR2_TBL_TYPE_150;
    attribute15_tbl                             VARCHAR2_TBL_TYPE_150;
    obj_name_tbl                                VARCHAR2_TBL_TYPE_30;
    pk1_value_tbl                               VARCHAR2_TBL_TYPE_240;
    pk2_value_tbl                               VARCHAR2_TBL_TYPE_240;
    pk3_value_tbl                               VARCHAR2_TBL_TYPE_240;
    pk4_value_tbl                               VARCHAR2_TBL_TYPE_240;
    pk5_value_tbl                               VARCHAR2_TBL_TYPE_240;
    from_end_item_rev_id_tbl                    NUMBER_TBL_TYPE;
    from_end_item_minor_rev_id_tbl              NUMBER_TBL_TYPE;
    to_end_item_rev_id_tbl                      NUMBER_TBL_TYPE;
    to_end_item_minor_rev_id_tbl                NUMBER_TBL_TYPE;
    new_component_code_tbl                      VARCHAR2_TBL_TYPE_4000;
    parent_sort_order_tbl                       VARCHAR2_TBL_TYPE_2000;
    comp_common_bill_seq_tbl                    NUMBER_TBL_TYPE;
    comp_bill_seq_tbl                           NUMBER_TBL_TYPE;
    access_flag_tbl                             VARCHAR2_TBL_TYPE_1;
    eng_item_flag_tbl                           VARCHAR2_TBL_TYPE_1;
    assembly_type_tbl                           NUMBER_TBL_TYPE;
    revision_label_tbl                          VARCHAR2_TBL_TYPE_260;
    revision_id_tbl                             NUMBER_TBL_TYPE;
    effectivity_control_tbl                     NUMBER_TBL_TYPE;
    object_rev_id_tbl                           NUMBER_TBL_TYPE;
    minor_rev_id_tbl                            NUMBER_TBL_TYPE;
    minor_rev_code_tbl                          VARCHAR2_TBL_TYPE_30;
    from_object_rev_id_tbl                      NUMBER_TBL_TYPE;
    from_minor_rev_id_tbl                       NUMBER_TBL_TYPE;
    to_object_rev_id_tbl                        NUMBER_TBL_TYPE;
    to_minor_rev_id_tbl                         NUMBER_TBL_TYPE;
    component_item_revision_id_tbl              NUMBER_TBL_TYPE;
    component_minorrevision_id_tbl              NUMBER_TBL_TYPE;
    bom_implementation_date_tbl                 DATE_TBL_TYPE;
    gtin_number_tbl                             VARCHAR2_TBL_TYPE_30;
    gtin_description_tbl                        VARCHAR2_TBL_TYPE_240;
    trade_item_descriptor_tbl                   VARCHAR2_TBL_TYPE_40;
    trade_item_descriptor_desc_tbl              VARCHAR2_TBL_TYPE_80;
    top_gtin_number_tbl                         VARCHAR2_TBL_TYPE_30;
    top_gtin_description_tbl                    VARCHAR2_TBL_TYPE_240;
    top_trade_item_descriptor_tbl               VARCHAR2_TBL_TYPE_40;
    parent_gtin_number_tbl                      VARCHAR2_TBL_TYPE_30;
    parent_gtin_description_tbl                 VARCHAR2_TBL_TYPE_240;
    parent_trade_descriptor_tbl                 VARCHAR2_TBL_TYPE_40;
    creation_date_tbl                           DATE_TBL_TYPE;
    created_by_tbl                              NUMBER_TBL_TYPE;
    last_update_date_tbl                        DATE_TBL_TYPE;
    last_updated_by_tbl                         NUMBER_TBL_TYPE;
    gtin_publication_status_tbl                 VARCHAR2_TBL_TYPE_1;
    auto_request_material_tbl                   VARCHAR2_TBL_TYPE_1;
    rexplode_flag_tbl                           VARCHAR2_TBL_TYPE_1;
    explode_option_tbl                          NUMBER_TBL_TYPE;
    change_policy_val_tbl                       VARCHAR2_TBL_TYPE_240;
    acd_type_tbl                                NUMBER_TBL_TYPE;
    quantity_related_tbl                        NUMBER_TBL_TYPE;
    structure_type_id_tbl                       NUMBER_TBL_TYPE;
    comp_fixed_rev_high_date_tbl                DATE_TBL_TYPE;
    comp_fixed_revision_id_tbl                  NUMBER_TBL_TYPE;
    parent_comp_sequence_id_tbl                 NUMBER_TBL_TYPE;
    is_preferred_tbl                            VARCHAR2_TBL_TYPE_1;
    parent_impl_date_tbl            DATE_TBL_TYPE;
    parent_change_notice_tbl                    VARCHAR2_TBL_TYPE_10;
    source_bill_sequence_id_tbl                 NUMBER_TBL_TYPE;
    common_component_seq_id_tbl                 NUMBER_TBL_TYPE;
    comp_source_bill_seq_tbl                    NUMBER_TBL_TYPE;
    comp_effectivity_control_tbl                NUMBER_TBL_TYPE;

    l_rows_fetched NUMBER := 0;
    l_Pkg_Structure_Type_Id NUMBER := -1;
BEGIN

  --Dbms_Output.put_line('end item revision id is '||end_item_rev_id);
  --Dbms_Output.put_line('end item id is '||end_item_id);
  --Dbms_Output.put_line('end item org id is '||end_item_org_id);
  --Dbms_Output.put_line('Group Id '||grp_id);

  /* Pre-fetch the structure type id for Packaging Hierarchy seeded type */
  FOR pkg_type IN c_Pkg_Structure_Type
  LOOP
    l_Pkg_Structure_Type_Id := pkg_type.structure_type_id;
  END LOOP;

  FOR cur_level in 1..levels_to_explode
  LOOP

    --Dbms_Output.put_line('for plan level '||to_char(cur_level-1));

    total_rows  := 0;
    cum_count := 0;

    OPEN exploder (
    cur_level,
    grp_id,
    org_id,
    bom_or_eng,
    rev_date,
    impl_flag,
    explode_option,
    order_by,
    verify_flag,
    plan_factor_flag,
    std_comp_flag,
    incl_oc_flag,
    std_bom_explode_flag  --change made for P4Telco CMR, bug# 8761845
    );

    l_rows_fetched := 0;

    LOOP
      --dbms_output.put_line('cur level is '||cur_level);

      -- FETCH exploder BULK COLLECT INTO be_temp_TBL LIMIT l_batch_size;

      --
      -- Insert attachments
      --

      /*
      IF (exploder%ROWCOUNT <> 0)
      THEN
        --Dbms_Output.put_line('Inserting attachments for level: ' || cur_level);
        Insert_Attachments(  p_group_id   => grp_id
                 , p_plan_level => cur_level
                      );
      END IF;
      */

      FETCH exploder BULK COLLECT INTO
        top_bill_sequence_id_tbl                    ,
        bill_sequence_id_tbl                        ,
        common_bill_sequence_id_tbl                 ,
        common_organization_id_tbl                  ,
        organization_id_tbl                         ,
        component_sequence_id_tbl                   ,
        component_item_id_tbl                       ,
        basis_type_tbl				    ,
        component_quantity_tbl                      ,
        plan_level_tbl                              ,
        extended_quantity_tbl                       ,
        sort_order_tbl                              ,
        group_id_tbl                                ,
        top_alternate_designator_tbl                ,
        component_yield_factor_tbl                  ,
        top_item_id_tbl                             ,
        component_code_tbl                          ,
        include_in_cost_rollup_tbl                  ,
        loop_flag_tbl                               ,
        planning_factor_tbl                         ,
        operation_seq_num_tbl                       ,
        bom_item_type_tbl                           ,
        parent_bom_item_type_tbl                    ,
        parent_item_id_tbl                          ,
        alternate_bom_designator_tbl                ,
        wip_supply_type_tbl                         ,
        item_num_tbl                                ,
        effectivity_date_tbl                        ,
        disable_date_tbl                            ,
        trimmed_effectivity_date_tbl                        ,
        trimmed_disable_date_tbl                            ,
        from_end_item_unit_number_tbl               ,
        to_end_item_unit_number_tbl                 ,
        trimmed_from_unit_number_tbl,
        trimmed_to_unit_number_tbl,
        implementation_date_tbl                     ,
        optional_tbl                                ,
        supply_subinventory_tbl                     ,
        supply_locator_id_tbl                       ,
        component_remarks_tbl                       ,
        change_notice_tbl                           ,
        operation_leadtime_percent_tbl             ,
        mutually_exclusive_options_tbl              ,
        check_atp_tbl                               ,
        required_to_ship_tbl                        ,
        required_for_revenue_tbl                    ,
        include_on_ship_docs_tbl                    ,
        low_quantity_tbl                            ,
        high_quantity_tbl                           ,
        so_basis_tbl                                ,
        operation_offset_tbl                        ,
        Current_revision_tbl                        ,
        locator_tbl                                 ,
        attribute_category_tbl                      ,
        attribute1_tbl                              ,
        attribute2_tbl                              ,
        attribute3_tbl                              ,
        attribute4_tbl                              ,
        attribute5_tbl                              ,
        attribute6_tbl                              ,
        attribute7_tbl                              ,
        attribute8_tbl                              ,
        attribute9_tbl                              ,
        attribute10_tbl                             ,
        attribute11_tbl                             ,
        attribute12_tbl                             ,
        attribute13_tbl                             ,
        attribute14_tbl                             ,
        attribute15_tbl                             ,
        obj_name_tbl                                ,
        pk1_value_tbl                               ,
        pk2_value_tbl                               ,
        pk3_value_tbl                               ,
        pk4_value_tbl                               ,
        pk5_value_tbl                               ,
        from_end_item_rev_id_tbl                    ,
        from_end_item_minor_rev_id_tbl              ,
        to_end_item_rev_id_tbl                      ,
        to_end_item_minor_rev_id_tbl                ,
        new_component_code_tbl                      ,
        parent_sort_order_tbl                       ,
        comp_common_bill_seq_tbl                    ,
        comp_bill_seq_tbl                           ,
        access_flag_tbl                             ,
        assembly_type_tbl                           ,
        revision_label_tbl                          ,
        revision_id_tbl                             ,
        effectivity_control_tbl                     ,
        object_rev_id_tbl                           ,
        minor_rev_id_tbl                            ,
        minor_rev_code_tbl                          ,
        from_object_rev_id_tbl                      ,
        from_minor_rev_id_tbl                       ,
        to_object_rev_id_tbl                        ,
        to_minor_rev_id_tbl                         ,
        component_item_revision_id_tbl              ,
        component_minorrevision_id_tbl             ,
        bom_implementation_date_tbl                ,
        top_gtin_number_tbl                       ,
        top_gtin_description_tbl                  ,
        top_trade_item_descriptor_tbl,
        parent_gtin_number_tbl                        ,
        parent_gtin_description_tbl                 ,
        parent_trade_descriptor_tbl,
        creation_date_tbl,
        created_by_tbl,
        last_update_date_tbl,
        last_updated_by_tbl ,
        auto_request_material_tbl,
        rexplode_flag_tbl,
        acd_type_tbl,
        quantity_related_tbl,
        change_policy_val_tbl,
        explode_option_tbl ,
        structure_type_id_tbl,
        comp_fixed_rev_high_date_tbl,
        comp_fixed_revision_id_tbl ,
        parent_comp_sequence_id_tbl,
        is_preferred_tbl,
        parent_impl_date_tbl,
        parent_change_notice_tbl,
        source_bill_sequence_id_tbl,
        common_component_seq_id_tbl,
        comp_source_bill_seq_tbl,
        comp_effectivity_control_tbl LIMIT l_batch_size;

      --dbms_output.put_line('Befoe exit call: Row count is '||exploder%ROWCOUNT);
      --dbms_output.put_line('Befoe exit call: l_rows_fetched '||l_rows_fetched);
      --dbms_output.put_line('count if tbsi '||top_bill_sequence_id_tbl.COUNT);

      EXIT WHEN exploder%ROWCOUNT = l_rows_fetched;
      l_rows_fetched := exploder%ROWCOUNT;

      --dbms_output.put_line('Row count is '||exploder%ROWCOUNT);

      FOR i IN 1..top_bill_sequence_id_tbl.COUNT
      LOOP

        --dbms_output.put_line('inside expl_rows');

        /*
        IF cur_level > levels_to_explode THEN
          IF cur_level > max_level THEN
            max_level_exceeded := true;
          END IF; -- exceed max level
          exit; -- do not insert extra level
        END IF; -- exceed lowest level
        */

        total_rows  := total_rows + 1;

        -- Get the sort order

        --dbms_output.put_line('calling sort order : '||parent_sort_order_tbl(i));
        sort_order_tbl(i)        := Get_Sort_Order(parent_sort_order_tbl(i), component_quantity_tbl(i));

        -- Get the component code

        loop_found := FALSE;
        cur_loopstr := new_component_code_tbl(i);

        IF obj_name_tbl(i) = 'DDD_CADVIEW' THEN
          cur_component := lpad('C'||pk1_value_tbl(i), 20, '0');
        ELSE
          cur_component := lpad('I'||component_item_id_tbl(i), 20, '0');
        END IF;

        -- search the current loop_string for current component

        FOR i IN 1..cur_level LOOP
          start_pos := 1+( (i-1) * 20 );
          cur_substr := SUBSTR( cur_loopstr, start_pos, 20 );
          IF (cur_component = cur_substr) THEN
            loop_found := TRUE;
            EXIT;
          END IF;
        END LOOP;

        new_component_code_tbl(i) := new_component_code_tbl(i) || cur_component;
        IF loop_found THEN
          loop_flag_tbl(i) := 1;
        ELSE
          loop_flag_tbl(i) := 2;
        END IF;


        current_revision_tbl(i) := Null;

        -- The following pieces are valid only IF the component row is an inventory item

        IF  obj_name_tbl(i) IS NULL THEN

          -- Security check needs to be performed for all the component items
          -- Previously, we were doing it only if the component has a BOM
          -- Note: Security previleges are determined for the org from which the
          --       explosion was initiated. This is true even with a common BOM

          -- Identify the access flag

          access_flag_tbl(i) := 'T';

          /* Security check should be moved to the view as it is user based

          IF (G_EGOUser is null) THEN
            access_flag_tbl(i) := 'T';
          ELSE
            access_flag_tbl(i) := BOM_SECURITY_PUB.CHECK_USER_PRIVILEGE(
            p_api_version => 1,
            p_function => BOM_SECURITY_PUB.FUNCTION_NAME_TO_CHECK,
            p_object_name=>'EGO_ITEM',
            p_instance_pk1_value=> pk1_value_tbl(i),
            p_instance_pk2_value=> org_id, --be_temp_TBL(i).PK2_VALUE,
            p_user_name=> G_EGOUser);
          END IF;
          */


          IF obj_name_tbl(i) IS NULL THEN
            IF component_item_revision_id_tbl(i) IS NOT NULL THEN
              FOR r1 IN getItemRevDetails(component_item_revision_id_tbl(i))
              LOOP
                revision_id_tbl(i)              := component_item_revision_id_tbl(i);
                current_revision_tbl(i)         := r1.revision;
                revision_label_tbl(i)           := r1.revision_label;
                comp_fixed_rev_high_date_tbl(i) := r1.revision_high_date;
              END LOOP;
            END IF;
          END IF;

          IF show_rev = 1 THEN

            IF component_item_revision_id_tbl(i) IS NULL THEN

              FOR r1 IN getItemRevision(component_item_id_tbl(i),
                                        --nvl(common_organization_id_tbl(i),organization_id_tbl(i)),
                                        --common_organization_id_tbl(i),
                                        organization_id_tbl(i),
                                        rev_date,
                                        impl_flag)
              LOOP
                revision_id_tbl(i)        := r1.revision_id;
                current_revision_tbl(i)   := r1.revision;
                revision_label_tbl(i)     := r1.revision_label;
                Exit;
              END LOOP;

            END IF; -- current component revision

            IF effectivity_control_tbl(i) = 4 THEN /* Minor rev code is required only for rev effective BOMs */

              IF component_minorrevision_id_tbl(i) IS NOT NULL THEN
                minor_rev_id_tbl(i) := component_minorrevision_id_tbl(i);
              ELSE
                FOR r1 IN getCurrentMinorRev (p_obj_name => obj_name_tbl(i),
                                              p_pk1_value => pk1_value_tbl(i),
                                              p_pk2_value => pk2_value_tbl(i),
                                              p_pk3_value => Revision_id_tbl(i))
                LOOP
                  minor_rev_id_tbl(i) := r1.minor_revision_id;
                END LOOP;
              END IF;

              IF obj_name_tbl(i) IS NULL THEN
                FOR r1 IN getCurrentMinorRevCode (revision_id_tbl(i), minor_rev_id_tbl(i))
                LOOP
                  minor_rev_code_tbl(i) := r1.mrev_code;
                END LOOP;
              ELSE
                minor_rev_code_tbl(i) := to_char(minor_rev_id_tbl(i));
              END IF;

            END IF; -- effectivity control

          END IF;  -- show rev

          locator_tbl(i) := Null;

          IF  material_ctrl = 1 THEN

            IF FND_FLEX_KEYVAL.validate_ccid
              (appl_short_name         =>     'INV',
              key_flex_code           =>      'MTLL',
              structure_number        =>      101,
              combination_id          =>      supply_locator_id_tbl(i),
              displayable             =>      'ALL',
              data_set                =>      organization_id_tbl(i)
              )
            THEN
              locator_tbl(i) := substr(FND_FLEX_KEYVAL.concatenated_values, 1, 40); -- Bug 16179473
            END IF;

          END IF; -- supply locator

          operation_leadtime_percent_tbl(i) := Null;

          FOR X_Operation in Get_OLTP(
            P_Assembly => parent_item_id_tbl(i),
            P_Alternate => alternate_bom_designator_tbl(i),
            P_Operation => operation_seq_num_tbl(i))
          LOOP
            operation_leadtime_percent_tbl(i) := X_Operation.OLTP;
          END LOOP;

          operation_offset_tbl(i) := Null;

          IF lead_time = 1 THEN
            For X_Item in Calculate_Offset(P_ParentItem => parent_item_id_tbl(i),
              P_Percent => operation_leadtime_percent_tbl(i))
            LOOP
              operation_offset_tbl(i) := X_Item.offset;
            END LOOP;
          END IF; -- operation offset

          -- Get the GTIN attributes if the component is an item

          IF structure_type_id_tbl(i) = l_Pkg_structure_type_id
          THEN
              SELECT gtin
            , description
            , trade_item_descriptor
            , primary_uom_code
            , eng_item_flag
            , primary_uom_code_desc
            , trade_item_descriptor_desc
            , publication_status
               INTO gtin_number_tbl(i)
            , gtin_description_tbl(i)
            , trade_item_descriptor_tbl(i)
            , primary_uom_code_tbl(i)
            , eng_item_flag_tbl(i)
            , primary_uom_desc_tbl(i)
            , trade_item_descriptor_desc_tbl(i)
            ,gtin_publication_status_tbl(i)
               FROM ego_items_v egi
              WHERE inventory_item_id = component_item_id_tbl(i)
                --AND organization_id = nvl(common_organization_id_tbl(i),organization_id_tbl(i));
                AND organization_id = common_organization_id_tbl(i);
           ELSE

              gtin_number_tbl(i)  := null;
              gtin_description_tbl(i) := null;
              trade_item_descriptor_tbl(i) := null;
              gtin_publication_status_tbl(i) := null;
              trade_item_descriptor_desc_tbl(i) := null;
              top_gtin_number_tbl(i) := null;
              top_gtin_description_tbl(i) := null;
              top_trade_item_descriptor_tbl(i) := null;
              parent_gtin_number_tbl(i) := null;
              parent_gtin_description_tbl(i) := null;
              parent_trade_descriptor_tbl(i) := null;
              eng_item_flag_tbl(i) := null;
              primary_uom_desc_tbl(i) := null;
              primary_uom_code_tbl(i) := null;

              /*
               SELECT msi.primary_uom_code
              , msi.eng_item_flag
              , mum.description
                 INTO primary_uom_code_tbl(i)
              , eng_item_flag_tbl(i)
              , primary_uom_desc_tbl(i)
                 FROM mtl_system_items_b msi
              --, mtl_units_of_measure mum
              , mtl_units_of_measure_tl mum
                 WHERE msi.inventory_item_id = component_item_id_tbl(i)
             AND msi.organization_id = nvl(common_organization_id_tbl(i),
                         organization_id_tbl(i))
             AND msi.primary_uom_code = mum.uom_code
             AND mum.language = userenv('LANG');

              gtin_number_tbl(i)  := null;
              gtin_description_tbl(i) := null;
              trade_item_descriptor_tbl(i) := null;
              gtin_publication_status_tbl(i) := null;
              trade_item_descriptor_desc_tbl(i) := null;
              top_gtin_number_tbl(i) := null;
              top_gtin_description_tbl(i) := null;
              top_trade_item_descriptor_tbl(i) := null;
              parent_gtin_number_tbl(i) := null;
              parent_gtin_description_tbl(i) := null;
              parent_trade_descriptor_tbl(i) := null;
              */

          END IF;

        ELSE
          gtin_number_tbl(i)  := null;
          gtin_description_tbl(i) := null;
          trade_item_descriptor_tbl(i) := null;
          gtin_publication_status_tbl(i) := null;
          trade_item_descriptor_desc_tbl(i) := null;
          top_gtin_number_tbl(i) := null;
          top_gtin_description_tbl(i) := null;
          top_trade_item_descriptor_tbl(i) := null;
          parent_gtin_number_tbl(i) := null;
          parent_gtin_description_tbl(i) := null;
          parent_trade_descriptor_tbl(i) := null;
          eng_item_flag_tbl(i) := null;
          primary_uom_desc_tbl(i) := null;
          primary_uom_code_tbl(i) := null;
        END IF; -- Check for obj_name is null ends

        IF comp_bill_seq_tbl(i) <> 0 THEN  -- If the component has a BOM

          object_rev_id_tbl(i) := revision_id_tbl(i);

          -- If there is a BOM for this component and then find out the current
          -- minor rev id and code for this component's revision

          /*
          IF component_minorrevision_id_tbl(i) IS NOT NULL THEN

            minor_rev_id_tbl(i) := component_minorrevision_id_tbl(i);

          ELSE

            FOR r1 IN getCurrentMinorRev (p_obj_name => obj_name_tbl(i),
                                          p_pk1_value => pk1_value_tbl(i),
                                          p_pk2_value => pk2_value_tbl(i),
                                          p_pk3_value => Revision_id_tbl(i))
            LOOP
              minor_rev_id_tbl(i) := r1.minor_revision_id;
            END LOOP;

          END IF;

          IF obj_name_tbl(i) IS NULL THEN
            FOR r1 IN getCurrentMinorRevCode (revision_id_tbl(i), minor_rev_id_tbl(i))
            LOOP
              minor_rev_code_tbl(i) := r1.mrev_code;
            END LOOP;
          ELSE
            minor_rev_code_tbl(i) := to_char(minor_rev_id_tbl(i));
          END IF;
          */

          SELECT max(common_bill_sequence_id), max(structure_type_id), max(is_preferred),
          max(implementation_date), max(source_bill_sequence_id),max(assembly_type), max(effectivity_control)
          INTO comp_common_bill_seq_tbl(i), structure_type_id_tbl(i), is_preferred_tbl(i), bom_implementation_date_tbl(i),
	  comp_source_bill_seq_tbl(i),assembly_type_tbl(i), comp_effectivity_control_tbl(i)
          FROM bom_structures_b WHERE
            bill_sequence_id = comp_bill_seq_tbl(i);

          -- Update the change policy value if the component has a bill
          /*
          IF (comp_bill_seq_tbl(i) <> 0) THEN
            change_policy_val_tbl(i) := Get_Change_Policy_Val(revision_id_tbl(i), comp_bill_seq_tbl(i));
          END IF;
          */

        ELSE

          comp_bill_seq_tbl(i) := null;

        END IF;  -- If the component has a BOM ends here

      END LOOP;

      -- We are doing this to capture the values for the last parent
      g_parent_sort_order_tbl(g_global_count)       := g_parent_sort_order;
      g_quantity_of_children_tbl(g_global_count)    := g_sort_count;
      g_total_qty_at_next_level_tbl(g_global_count) := g_total_quantity;

      /*
      FORALL i IN 1..be_temp_TBL.COUNT
        INSERT INTO bom_plm_explosion_temp VALUES be_temp_TBL(i);
      */

      FORALL i IN 1..top_bill_sequence_id_tbl.COUNT
        --INSERT /*+append */ INTO BOM_EXPLOSIONS_ALL
        INSERT INTO BOM_EXPLOSIONS_ALL
        (
        TOP_BILL_SEQUENCE_ID           ,
        BILL_SEQUENCE_ID               ,
        COMMON_BILL_SEQUENCE_ID        ,
        COMMON_ORGANIZATION_ID         ,
        ORGANIZATION_ID                ,
        COMPONENT_SEQUENCE_ID          ,
        COMPONENT_ITEM_ID              ,
        BASIS_TYPE		       ,
        COMPONENT_QUANTITY             ,
        PLAN_LEVEL                     ,
        EXTENDED_QUANTITY              ,
        SORT_ORDER                     ,
        GROUP_ID                       ,
        TOP_ALTERNATE_DESIGNATOR       ,
        COMPONENT_YIELD_FACTOR         ,
        TOP_ITEM_ID                    ,
        COMPONENT_CODE                 ,
        INCLUDE_IN_ROLLUP_FLAG         ,
        LOOP_FLAG                      ,
        PLANNING_FACTOR                ,
        OPERATION_SEQ_NUM              ,
        BOM_ITEM_TYPE                  ,
        PARENT_BOM_ITEM_TYPE           ,
        PRIMARY_UOM_CODE         ,
        PRIMARY_UNIT_OF_MEASURE        ,
        ASSEMBLY_ITEM_ID               ,
        ALTERNATE_BOM_DESIGNATOR       ,
        WIP_SUPPLY_TYPE                ,
        ITEM_NUM                       ,
        EFFECTIVITY_DATE               ,
        DISABLE_DATE                   ,
        TRIMMED_EFFECTIVITY_DATE               ,
        TRIMMED_DISABLE_DATE                   ,
        TRIMMED_FROM_UNIT_NUMBER      ,
        TRIMMED_TO_UNIT_NUMBER        ,
        FROM_END_ITEM_UNIT_NUMBER      ,
        TO_END_ITEM_UNIT_NUMBER        ,
        IMPLEMENTATION_DATE            ,
        OPTIONAL                       ,
        SUPPLY_SUBINVENTORY            ,
        SUPPLY_LOCATOR_ID              ,
        COMPONENT_REMARKS              ,
        CHANGE_NOTICE                  ,
        OPERATION_LEAD_TIME_PERCENT    ,
        MUTUALLY_EXCLUSIVE_OPTIONS     ,
        CHECK_ATP                      ,
        REQUIRED_TO_SHIP               ,
        REQUIRED_FOR_REVENUE           ,
        INCLUDE_ON_SHIP_DOCS           ,
        LOW_QUANTITY                   ,
        HIGH_QUANTITY                  ,
        SO_BASIS                       ,
        OPERATION_OFFSET               ,
        CURRENT_REVISION               ,
        LOCATOR                        ,
        CONTEXT                        ,
        ATTRIBUTE1                     ,
        ATTRIBUTE2                     ,
        ATTRIBUTE3                     ,
        ATTRIBUTE4                     ,
        ATTRIBUTE5                     ,
        ATTRIBUTE6                     ,
        ATTRIBUTE7                     ,
        ATTRIBUTE8                     ,
        ATTRIBUTE9                     ,
        ATTRIBUTE10                    ,
        ATTRIBUTE11                    ,
        ATTRIBUTE12                    ,
        ATTRIBUTE13                    ,
        ATTRIBUTE14                    ,
        ATTRIBUTE15                    ,
        OBJ_NAME                       ,
        PK1_VALUE                      ,
        PK2_VALUE                      ,
        PK3_VALUE                      ,
        PK4_VALUE                      ,
        PK5_VALUE                      ,
        FROM_END_ITEM_REV_ID           ,
        FROM_END_ITEM_MINOR_REV_ID     ,
        TO_END_ITEM_REV_ID             ,
        TO_END_ITEM_MINOR_REV_ID       ,
        NEW_COMPONENT_CODE             ,
        PARENT_SORT_ORDER              ,
        COMP_COMMON_BILL_SEQ_ID        ,
        COMP_BILL_SEQ_ID               ,
        ACCESS_FLAG                    ,
        ENG_ITEM_FLAG                    ,
        ASSEMBLY_TYPE                  ,
        REVISION_LABEL                 ,
        REVISION_ID                    ,
        EFFECTIVITY_CONTROL            ,
        OBJECT_REVISION_ID             ,
        MINOR_REVISION_ID              ,
        MINOR_REVISION_CODE            ,
        FROM_OBJECT_REVISION_ID        ,
        FROM_MINOR_REVISION_ID         ,
        TO_OBJECT_REVISION_ID          ,
        TO_MINOR_REVISION_ID           ,
        COMPONENT_ITEM_REVISION_ID     ,
        COMPONENT_MINOR_REVISION_ID    ,
        BOM_IMPLEMENTATION_DATE       ,
        GTIN_NUMBER                   ,
        GTIN_DESCRIPTION              ,
        TRADE_ITEM_DESCRIPTOR         ,
        TRADE_ITEM_DESCRIPTOR_DESC    ,
        GTIN_PUBLICATION_STATUS       ,
        TOP_GTIN_NUMBER               ,
        TOP_GTIN_DESCRIPTION          ,
        TOP_TRADE_ITEM_DESCRIPTOR,
        PARENT_GTIN_NUMBER               ,
        PARENT_GTIN_DESCRIPTION          ,
        PARENT_TRADE_ITEM_DESCRIPTOR     ,
        CREATION_DATE          ,
        CREATED_BY             ,
        LAST_UPDATE_DATE       ,
        LAST_UPDATED_BY        ,
        AUTO_REQUEST_MATERIAL,
        REXPLODE_FLAG,
        ACD_TYPE,
        QUANTITY_RELATED,
        CHANGE_POLICY_VALUE,
        EXPLODED_OPTION,
        COMP_FIXED_REV_HIGH_DATE,
        COMP_FIXED_REVISION_ID,
        MAX_BILL_LEVEL,
        PARENT_COMP_SEQ_ID,
        END_ITEM_ID,
        END_ITEM_ORG_ID,
        STRUCTURE_TYPE_ID,
        IS_PREFERRED,
        PARENT_IMPLEMENTATION_DATE,
        PARENT_CHANGE_NOTICE,
        SOURCE_BILL_SEQUENCE_ID,
        COMMON_COMPONENT_SEQUENCE_ID,
        COMP_SOURCE_BILL_SEQ_ID,
        COMP_EFFECTIVITY_CONTROL)
        VALUES
        (
        top_bill_sequence_id_tbl(i)                    ,
        bill_sequence_id_tbl(i)                       ,
        common_bill_sequence_id_tbl(i)                 ,
        common_organization_id_tbl(i)                  ,
        organization_id_tbl(i)                          ,
        component_sequence_id_tbl(i)                   ,
        component_item_id_tbl(i)                        ,
        basis_type_tbl(i)                       ,
        component_quantity_tbl(i)                       ,
        plan_level_tbl(i)                               ,
        extended_quantity_tbl(i)                        ,
        sort_order_tbl(i)                               ,
        group_id_tbl(i)                                   ,
        top_alternate_designator_tbl(i)                 ,
        component_yield_factor_tbl(i)                  ,
        top_item_id_tbl(i)                            ,
        component_code_tbl(i)                           ,
        include_in_cost_rollup_tbl(i)                  ,
        loop_flag_tbl(i)                                ,
        planning_factor_tbl(i)                          ,
        operation_seq_num_tbl(i)                        ,
        bom_item_type_tbl(i)                            ,
        parent_bom_item_type_tbl(i)                    ,
        primary_uom_code_tbl(i)                    ,
        primary_uom_desc_tbl(i)        ,
        parent_item_id_tbl(i)                           ,
        alternate_bom_designator_tbl(i)                 ,
        wip_supply_type_tbl(i)                          ,
        item_num_tbl(i)                               ,
        effectivity_date_tbl(i)                         ,
        disable_date_tbl(i)                             ,
        trimmed_effectivity_date_tbl(i)                         ,
        trimmed_disable_date_tbl(i)                             ,
        trimmed_from_unit_number_tbl(i),
        trimmed_to_unit_number_tbl(i),
        from_end_item_unit_number_tbl(i)              ,
        to_end_item_unit_number_tbl(i)                ,
        implementation_date_tbl(i)                    ,
        optional_tbl(i)                               ,
        supply_subinventory_tbl(i)                    ,
        supply_locator_id_tbl(i)                        ,
        component_remarks_tbl(i)                      ,
        change_notice_tbl(i)                            ,
        operation_leadtime_percent_tbl(i)             ,
        mutually_exclusive_options_tbl(i)              ,
        check_atp_tbl(i)                                ,
        required_to_ship_tbl(i)                       ,
        required_for_revenue_tbl(i)                    ,
        include_on_ship_docs_tbl(i)                    ,
        low_quantity_tbl(i)                           ,
        high_quantity_tbl(i)                          ,
        so_basis_tbl(i)                                 ,
        operation_offset_tbl(i)                       ,
        Current_revision_tbl(i)                         ,
        locator_tbl(i)                                ,
        attribute_category_tbl(i)                       ,
        attribute1_tbl(i)                               ,
        attribute2_tbl(i)                               ,
        attribute3_tbl(i)                               ,
        attribute4_tbl(i)                               ,
        attribute5_tbl(i)                               ,
        attribute6_tbl(i)                               ,
        attribute7_tbl(i)                               ,
        attribute8_tbl(i)                               ,
        attribute9_tbl(i)                               ,
        attribute10_tbl(i)                            ,
        attribute11_tbl(i)                            ,
        attribute12_tbl(i)                            ,
        attribute13_tbl(i)                            ,
        attribute14_tbl(i)                            ,
        attribute15_tbl(i)                            ,
        obj_name_tbl(i)                                 ,
        pk1_value_tbl(i)                              ,
        pk2_value_tbl(i)                              ,
        pk3_value_tbl(i)                              ,
        pk4_value_tbl(i)                              ,
        pk5_value_tbl(i)                              ,
        from_end_item_rev_id_tbl(i)                    ,
        from_end_item_minor_rev_id_tbl(i)              ,
        to_end_item_rev_id_tbl(i)                     ,
        to_end_item_minor_rev_id_tbl(i)                ,
        new_component_code_tbl(i)                       ,
        parent_sort_order_tbl(i)                      ,
        comp_common_bill_seq_tbl(i)                    ,
        comp_bill_seq_tbl(i)                            ,
        access_flag_tbl(i)                            ,
        eng_item_flag_tbl(i)                            ,
        assembly_type_tbl(i)                            ,
        revision_label_tbl(i)                           ,
        revision_id_tbl(i)                            ,
        effectivity_control_tbl(i)                    ,
        object_rev_id_tbl(i)                          ,
        minor_rev_id_tbl(i)                           ,
        minor_rev_code_tbl(i)                           ,
        from_object_rev_id_tbl(i)                     ,
        from_minor_rev_id_tbl(i)                        ,
        to_object_rev_id_tbl(i)                       ,
        to_minor_rev_id_tbl(i)                        ,
        component_item_revision_id_tbl(i)             ,
        component_minorrevision_id_tbl(i)             ,
        decode(comp_bill_seq_tbl(i), null, to_date(null), bom_implementation_date_tbl(i)) ,
        gtin_number_tbl(i),
        gtin_description_tbl(i),
        trade_item_descriptor_tbl(i),
        trade_item_descriptor_desc_tbl(i),
        gtin_publication_status_tbl(i),
        top_gtin_number_tbl(i),
        top_gtin_description_tbl(i),
        top_trade_item_descriptor_tbl(i),
        parent_gtin_number_tbl(i),
        parent_gtin_description_tbl(i),
        parent_trade_descriptor_tbl(i),
        creation_date_tbl(i),
        created_by_tbl(i),
        last_update_date_tbl(i),
        last_updated_by_tbl(i),
        auto_request_material_tbl(i),
        rexplode_flag_tbl(i),
        acd_type_tbl(i),
        quantity_related_tbl(i),
        change_policy_val_tbl(i),
        explode_option_tbl(i),
        comp_fixed_rev_high_date_tbl(i),
        comp_fixed_revision_id_tbl(i),
        max_level,
        parent_comp_sequence_id_tbl(i),
        l_end_item_id,
        l_end_item_org_id,
        decode(comp_bill_seq_tbl(i), null, null, structure_type_id_tbl(i)),
        decode(comp_bill_seq_tbl(i), null, null, is_preferred_tbl(i)),
        parent_impl_date_tbl(i),
        parent_change_notice_tbl(i),
        source_bill_sequence_id_tbl(i) ,
        common_component_seq_id_tbl(i),
        comp_source_bill_seq_tbl(i),
        comp_effectivity_control_tbl(i));

      --EXIT WHEN top_bill_sequence_id_tbl.COUNT < l_batch_size;
    END LOOP;

    CLOSE exploder;
    /* Update the quantity of children for every parent, total quantity for every parent */

    --
    -- IF total rows fetched is 0, THEN break the loop here since nothing
    -- more to explode
    --
    IF total_rows = 0 THEN
      -- Do not break the loop. We might find some dirty nodes somewhere deep in the hierarchy
      --exit;
      null;
    END IF;

  END LOOP; -- while level

  --Dbms_Output.put_line('g_parent_sort_order_tbl.COUNT : '||g_parent_sort_order_tbl.COUNT);

  FORALL i IN 1..g_parent_sort_order_tbl.COUNT
    UPDATE BOM_EXPLOSIONS_ALL
      SET quantity_of_children = g_quantity_of_children_tbl(i),
          total_qty_at_next_level = g_total_qty_at_next_level_tbl(i)
      WHERE group_id = grp_id
        AND sort_order = g_parent_sort_order_tbl(i);

  UPDATE BOM_EXPLOSIONS_ALL bet SET (bet.primary_uom_code, bet.eng_item_flag, bet.primary_unit_of_measure) =
             (SELECT msi.primary_uom_code
            , msi.eng_item_flag
            , mum.unit_of_measure
               FROM mtl_system_items_b msi
            , mtl_units_of_measure_tl mum
               WHERE msi.inventory_item_id = bet.component_item_id
           AND msi.organization_id = bet.common_organization_id
           AND msi.primary_uom_code = mum.uom_code
           AND mum.language = userenv('LANG'))
  WHERE bet.group_id = grp_id AND bet.obj_name IS NULL AND bet.primary_uom_code IS NULL;

  /*
  ** Once the explosion is done, apply the exclusion rules
  ** The reason exclusion is applied after the tree is built, is so that the dataset
  ** can be fetched without or without exclusion. This will prevent exploding the tree
  ** for applying exclusions
  */
  Apply_Exclusion_rules(p_group_id => grp_id);

  IF max_level_exceeded THEN

    error_code  := 9998;
    Fnd_Message.Set_Name('BOM', 'BOM_LEVELS_EXCEEDED');

    FOR l_bill_rec in l_TopBill_csr
    LOOP
      Fnd_Message.Set_Token('ENTITY', l_bill_rec.concatenated_segments);
      Fnd_Message.Set_Token('ENTITY1', l_bill_rec.concatenated_segments);
      Fnd_Message.Set_Token('ENTITY2', l_bill_rec.alternate_bom_designator);
    END LOOP;

    err_msg := Fnd_Message.Get_Encoded;
  ELSE
    error_code  := 0;
    err_msg := null;

  END IF;

  EXCEPTION WHEN OTHERS THEN
    error_code  := SQLCODE;
    Fnd_Msg_Pub.Build_Exc_Msg(
    p_pkg_name => 'BOM_EXPLODER_PUB',
    p_procedure_name => 'BOM_EXPLODER',
    p_error_text => SQLERRM);
    err_msg := Fnd_Message.Get_Encoded;
    Raise exploder_error;
    --ROLLBACK;

END bom_exploder;


procedure exploders(
  verify_flag   IN  NUMBER DEFAULT 0,
  online_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  l_levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  l_explode_option  IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  unit_number   IN  VARCHAR2 DEFAULT '',
  rev_date    IN  DATE DEFAULT sysdate,
  object_rev_id  IN NUMBER,
  minor_rev_id IN NUMBER,
  show_rev          IN NUMBER DEFAULT 1,
  material_ctrl     IN NUMBER DEFAULT 2,
  lead_time   IN NUMBER DEFAULT 2,
  object_name          IN VARCHAR2 DEFAULT NULL,
  pk_value1         IN VARCHAR2 DEFAULT NULL,
  pk_value2         IN VARCHAR2 DEFAULT NULL,
  pk_value3         IN VARCHAR2 DEFAULT NULL,
  pk_value4         IN VARCHAR2 DEFAULT NULL,
  pk_value5         IN VARCHAR2 DEFAULT NULL,
  end_item_id  IN NUMBER DEFAULT NULL,
  end_item_org_id  IN NUMBER DEFAULT NULL,
  end_item_rev_id  IN NUMBER DEFAULT NULL,
  end_item_minor_rev_id  IN NUMBER DEFAULT NULL,
  end_item_minor_rev_code  IN VARCHAR2 DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,
  top_bill_sequence IN NUMBER,
  max_level in NUMBER,
  err_msg     IN OUT NOCOPY VARCHAR2,
  error_code    IN OUT NOCOPY NUMBER,
  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'
  ) AS

    --max_level     NUMBER;
    levels_to_explode   NUMBER;
    explode_option    NUMBER;
    cost_org_id     NUMBER;
    max_levels      NUMBER;
    incl_oc_flag    NUMBER;
    counter     NUMBER;
    l_std_comp_flag   NUMBER;
    l_error_code    NUMBER;
    l_err_msg     VARCHAR2(2000);
    loop_detected   EXCEPTION;

BEGIN

    levels_to_explode := l_levels_to_explode;
    explode_option  := l_explode_option;

    /*
    ** fetch the max permissible levels for explosion
    ** doing a max since IF no row exist to prevent no_Data_found exception
    ** FROM being raised
    */

    /*SELECT max(MAXIMUM_BOM_LEVEL)
    INTO max_level
    FROM BOM_PARAMETERS
    WHERE (org_id = -1
      or
      (org_id <> -1 AND ORGANIZATION_ID = org_id)
          );

    -- maximum level must be at most 60 (plan level 0..59)

    IF nvl(max_level, 60) > 60 THEN
      max_level := 60;
    END IF;*/
    --commented as now, max_level is passed as a parameter.

    /*
    ** IF levels to explode > max levels or < 0, set it to max_levels
    */

    IF (levels_to_explode < 0) OR (levels_to_explode > max_level) THEN
      levels_to_explode := max_level;
    END IF;

    /*
    ** IF levels_to_explode > 1, THEN explode_option = CURRENT is the
    ** only valid option
    ** 05/20/93 removed this condition to make it generic.  Also the verify
    ** needs current+future indented explosion.

    IF levels_to_explode > 1 THEN
      explode_option  := 2;
    END IF;
    */

    IF (module = 1 or module = 2) THEN  /* cst or bom explosion */
      l_std_comp_flag := 2;   /* ALL */
    ELSE
      l_std_comp_flag := std_comp_flag;
    END IF;

    IF (module = 1) THEN    /* CST */
      incl_oc_flag := 2;
    ELSE
      incl_oc_flag := 1;
    END IF;

    bom_exploder(
    verify_flag => verify_flag,
    online_flag => online_flag,
    org_id => org_id,
    order_by => order_by,
    grp_id => grp_id,
    levels_to_explode => levels_to_explode,
    bom_or_eng => bom_or_eng,
    impl_flag => impl_flag,
    std_comp_flag => l_std_comp_flag,
    plan_factor_flag => plan_factor_flag,
    explode_option => explode_option,
    incl_oc_flag => incl_oc_flag,
    unit_number => unit_number,
    max_level => max_level,
    rev_date => rev_date,
    object_rev_id  => object_rev_id,
    minor_rev_id => minor_rev_id,
    show_rev => show_rev,
    material_ctrl => material_ctrl,
    lead_time => lead_time,
    object_name  => object_name,
    pk_value1 => pk_value1,
    pk_value2 => pk_value2,
    pk_value3 => pk_value3,
    pk_value4 => pk_value4,
    pk_value5 => pk_value5,
    end_item_id => end_item_id,
    end_item_org_id => end_item_org_id,
    end_item_rev_id => end_item_rev_id,
    end_item_minor_rev_id => end_item_minor_rev_id,
    end_item_minor_rev_code => end_item_minor_rev_code,
    filter_pbom => filter_pbom,
    top_bill_sequence => top_bill_sequence,
    err_msg => l_err_msg,
    error_code => l_error_code,

    --change made for P4Telco CMR, bug# 8761845
    std_bom_explode_flag => std_bom_explode_flag
    );

    error_code  := l_error_code;
    err_msg := l_err_msg;

        /* insert the attachments for the current explosion
           Attachments are now inserted to improve performance of the view when querying the explosion results
           Only the pk1 and status id, etc is inserted into the explosion. Rest of the user displayed columns
           are still left in the view.
           The following columns are resused for ATTACHMENT node
           pk1_value = ATTACHED_DOCUMENT_ID
           LINE_ID   = DOCUMENT_ID
        */

  --dbms_output.put_line('Inserting Attachments . . .');
        --Insert_Attachments(p_group_id => grp_id);


EXCEPTION WHEN OTHERS THEN
  error_code  := l_error_code;
  err_msg   := l_err_msg;
  Raise exploder_error;
END exploders;

PROCEDURE loopstr2msg(
  grp_id    IN NUMBER,
  verify_msg  IN OUT NOCOPY VARCHAR2
) IS
  top_alt   VARCHAR2(10);
  org_id    NUMBER;
        cur_msgstr      VARCHAR2(240);
        cur_item_id     NUMBER;
        cur_substr      VARCHAR2(16);
        position        NUMBER;
        tmp_msg         VARCHAR2(2000);
  err_msg   VARCHAR2(80);

  CURSOR get_loop_rows(c_group_id NUMBER) IS
    SELECT
      COMPONENT_CODE,
      LOOP_FLAG,
      PLAN_LEVEL
    FROM BOM_EXPLOSIONS_ALL
    WHERE GROUP_ID = c_group_id
    AND LOOP_FLAG = 1;
BEGIN

  SELECT NVL( TOP_ALTERNATE_DESIGNATOR, 'none' ), ORGANIZATION_ID
  INTO top_alt, org_id
  FROM BOM_EXPLOSIONS_ALL
  WHERE GROUP_ID = grp_id
  AND ROWNUM = 1
  AND PLAN_LEVEL = 0;

  FOR loop_rec IN get_loop_rows( grp_id ) LOOP

  tmp_msg := '';
  FOR i IN 0..loop_rec.plan_level LOOP
    position := (i * 16) + 1;
    cur_substr := SUBSTR( loop_rec.component_code, position, 16 );
    cur_item_id := TO_NUMBER( cur_substr );

    SELECT
    substrb(MIF.ITEM_NUMBER || ' ' || BBM.ALTERNATE_BOM_DESIGNATOR,1,16)
    INTO cur_msgstr
    FROM MTL_ITEM_FLEXFIELDS MIF, BOM_BILL_OF_MATERIALS BBM
    WHERE MIF.ORGANIZATION_ID = BBM.ORGANIZATION_ID
    AND MIF.ITEM_ID = BBM.ASSEMBLY_ITEM_ID
    AND BBM.ASSEMBLY_ITEM_ID = cur_item_id
    AND BBM.ORGANIZATION_ID = org_id
    AND (
    ((top_alt = 'none') AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL)
    OR
    ((top_alt <> 'none')
      AND (
          ( EXISTS ( SELECT NULL FROM BOM_BILL_OF_MATERIALS BBM1
            WHERE BBM1.ORGANIZATION_ID = org_id
            AND BBM1.ASSEMBLY_ITEM_ID = cur_item_id
            AND BBM1.ALTERNATE_BOM_DESIGNATOR = top_alt)
            AND BBM.ALTERNATE_BOM_DESIGNATOR = top_alt
                      )
          OR
          ( NOT EXISTS (SELECT NULL FROM BOM_BILL_OF_MATERIALS BBM2
                        WHERE BBM2.ORGANIZATION_ID = org_id
                        AND BBM2.ASSEMBLY_ITEM_ID = cur_item_id
                        AND BBM2.ALTERNATE_BOM_DESIGNATOR = top_alt)
            AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL
                      )
              )
      )
       );

    IF i = 0 THEN
    tmp_msg := cur_msgstr;
    ELSE
      tmp_msg := tmp_msg || ' -> ' || cur_msgstr;
    END IF;

  END LOOP; /* loop through component_code */
    verify_msg := tmp_msg;


    END LOOP; /* for loop_rec cursor loop */


  EXCEPTION
      when others THEN
    err_msg := substrb(SQLERRM, 1, 70);

END loopstr2msg;

procedure exploder_userexit_pvt (
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
  structure_type_id IN NUMBER DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,
  p_autonomous_transaction IN NUMBER,

  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'
) AS

    item_id NUMBER   := pk_value1;
    l_rev_date  DATE := rev_date;

    cbsi NUMBER;
    out_code      NUMBER;
    cost_org_id     NUMBER;
    stmt_num      NUMBER := 1;
    out_message     VARCHAR2(240);
    parameter_error   EXCEPTION;
    inv_uom_conv_exe            EXCEPTION;
    X_SortWidth           number; -- Maximum of 9999999 components per level
    cnt  NUMBER :=0;

    is_cost_organization VARCHAR2(1);
    t_conversion_rate NUMBER;
    t_master_org_id NUMBER;
    t_child_uom varchar(3);
    t_comp_qty NUMBER;
    t_comp_extd_qty NUMBER;
    t_master_uom varchar(3);
    t_item_cost NUMBER;

    -- Added the check for obj_name since cost calculations are applicable only
    -- for inventory item components

  -- Also we need to check Item BOM commoning a CAD BOM. In that case also,
  -- the following cost calculations are not required
    Cursor cur(p_group_id IN NUMBER) is
       Select BET.organization_id curOI,
              BET.bill_sequence_id curBSI,
              BET.component_sequence_id curCSI,
              /*if the top item is not the assigned to both orgs, this can lead to problems bug: 5522821*/
              Decode(BET.component_item_id, BET.top_item_id,BOM.assembly_item_id,BET.component_item_id) curCII,
              BET.common_bill_sequence_id curCBSI,
              BET.group_id curGI,
              BET.primary_uom_code curPUC,
        BET.primary_unit_of_measure curPUM
       FROM   BOM_EXPLOSIONS_ALL BET, bom_structures_b BOM
       WHERE  BET.group_id = p_group_id AND BET.obj_name IS NULL AND
        BET.bill_sequence_id <> BET.common_bill_sequence_id AND
        BET.source_bill_sequence_id = BOM.BILL_SEQUENCE_ID AND
        BET.plan_level <> 0;
        --AND BOM.OBJ_NAME IS NULL;

   cursor conv (t_master_uom varchar2,
                t_child_uom  varchar2,
                t_inv_id     number,
                t_master_org_id number) is
    SELECT conversion_rate
    FROM   mtl_uom_conversions_view
    WHERE primary_uom_code = t_master_uom and
                uom_code = t_child_uom and
                inventory_item_id = t_inv_id and
                organization_id = t_master_org_id;

  -- Cannot use mtl_item_rev_highdate_v because of the way it presents the high_date for the last rev
  -- The high_date of last_rev for an item should always be higher for example like 31-DEC-9999 no matter
  -- the last rev is the current rev or future rev. Otherwise, we can't resolve the revisions as of future date
  -- Replaced with the following cursor

  /*
  CURSOR getItemRev (p_inventory_item_id IN NUMBER,
                     p_organization_id   IN NUMBER,
             p_effective_date    IN DATE) IS
  SELECT revision revision, revision_id revision_id FROM mtl_item_rev_highdate_v
    WHERE inventory_item_id = p_inventory_item_id AND
        organization_id = p_organization_id AND
        p_effective_date BETWEEN effectivity_date AND decode( sign(high_date-effectivity_date), 1 , high_date, p_effective_date) ;
  */

  CURSOR getItemRev (p_inventory_item_id IN NUMBER,
                     p_organization_id   IN NUMBER,
                     p_effective_date    IN DATE) IS
  SELECT revision revision, revision_id revision_id FROM (
  SELECT rev1.organization_id , rev1.inventory_item_id , rev1.revision_id , rev1.revision ,
  rev1.effectivity_date , nvl(min(rev2.effectivity_date - 1/(60*60*24)),
  greatest(to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss'), reV1.effectivity_date)) high_date,
        rev1.implementation_date, rev1.change_notice FROM mtl_item_revisions_b rev2 , mtl_item_revisions_b rev1
  WHERE rev1.inventory_item_id = p_inventory_item_id AND rev1.organization_id = p_organization_id AND
  rev1.organization_id = rev2.organization_id(+) AND
  rev1.inventory_item_id = rev2.inventory_item_id(+) AND
  rev2.effectivity_date(+) > rev1.effectivity_date
  GROUP BY rev1.organization_id , rev1.inventory_item_id , rev1.revision_id ,
  rev1.revision , rev1.effectivity_date , rev1.implementation_date , rev1.change_notice)
  WHERE p_effective_date BETWEEN effectivity_date AND high_date;

  CURSOR getEndItemRev (p_item_revision_id IN NUMBER) IS
  SELECT inventory_item_id, organization_id, revision,effectivity_date FROM mtl_item_revisions_b
  WHERE revision_id = p_item_revision_id;

  CURSOR getCurrentMinorRev (p_obj_name IN VARCHAR2,
                             p_pk1_value IN VARCHAR2,
                             p_pk2_value IN VARCHAR2,
                             p_pk3_value IN VARCHAR2) IS
  SELECT nvl(max(minor_revision_id),0) minor_revision_id FROM ego_minor_revisions
  WHERE obj_name = p_obj_name AND
        pk1_value = p_pk1_value AND
  nvl(pk2_value,'-1') = nvl(p_pk2_value,'-1') AND
  nvl(pk3_value,'-1') = nvl(p_pk3_value,'-1');

  CURSOR getCurrentMinorRevForItemRev (p_item_rev_id IN NUMBER) IS
  SELECT nvl(max(minor_revision_id),0) minor_revision_id FROM ego_minor_revisions
  WHERE obj_name = 'EGO_ITEM_REVISION'
      AND pk3_value = p_item_rev_id;

  CURSOR getEndItemMinorRevCode (p_revision_id IN NUMBER,
                                 p_minor_rev_id IN NUMBER) IS
  SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(p_minor_rev_id)) mrev_code FROM mtl_item_revisions_b
  WHERE revision_id = p_revision_id;

  CURSOR getPreferredStructure ( p_obj_name IN VARCHAR2,
                                 p_pk1_value IN VARCHAR2,
                                 p_pk2_value IN VARCHAR2,
                                 p_structure_type_id IN NUMBER) IS
  SELECT alternate_bom_designator FROM bom_structures_b WHERE ( (p_obj_name IS NULL AND obj_name IS NULL)
  OR (p_obj_name IS NOT NULL AND obj_name = p_obj_name)) AND pk1_value = p_pk1_value AND
  pk2_value = p_pk2_value AND structure_type_id = p_structure_type_id;


  CURSOR c_dirty_nodes (p_group_id IN NUMBER ) IS
  SELECT sort_order, comp_common_bill_seq_id, comp_bill_seq_id FROM BOM_EXPLOSIONS_ALL WHERE
  group_id = grp_id AND comp_bill_seq_id IS NOT NULL AND rexplode_flag = 1
  ORDER BY sort_order;

  CURSOR c_get_first_revision (p_inventory_item_id IN NUMBER,
                              p_organization_id IN NUMBER) IS
  SELECT effectivity_date, revision_id, revision FROM mtl_item_revisions_b WHERE
  inventory_item_id = p_inventory_item_id AND organization_id = p_organization_id AND
  effectivity_date  = ( SELECT min(effectivity_date) FROM mtl_item_revisions_b
  WHERE inventory_item_id = p_inventory_item_id AND organization_id = p_organization_id );

  CURSOR c_Pkg_Structure_Type IS
  SELECT structure_type_id
    FROM bom_structure_types_b
   WHERE structure_type_name = 'Packaging Hierarchy';

  CURSOR getComponentFixedRevisions (p_group_id IN NUMBER)  IS
  SELECT bet.component_sequence_id, bet.component_item_revision_id revision_id,
  mir.revision revision FROM bom_explosions_all bet,  mtl_item_revisions_b mir
  WHERE bet.group_id = p_group_id AND bet.plan_level <> 0 AND nvl(bet.component_item_revision_id,0) <> 0
  AND bet.component_item_revision_id = mir.revision_id;

  CURSOR getFixedRevDetails (p_group_id IN NUMBER) IS
  SELECT
     DECODE( SIGN(high_date-SYSDATE),
          -1 ,
          high_date,
          1  ,
          DECODE( SIGN(effectivity_date-SYSDATE),
              1  ,
              effectivity_date,
              SYSDATE
          )  ,
          0  ,
          SYSDATE
         ) Revision_high_date,
      Revision_id
  FROM
   ( SELECT
        rev1.Organization_Id, rev1.Inventory_Item_Id, rev1.Revision_Id, rev1.Revision, rev1.Effectivity_Date,
        NVL( MIN(rev2.Effectivity_Date - 1/(60*60*24)),
             GREATEST(TO_DATE('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss'), reV1.Effectivity_Date)
           ) High_Date,
        rev1.Implementation_Date, rev1.Change_Notice, rev1.revision_label
     FROM bom_explosions_all bet, Mtl_Item_Revisions_B rev2 , Mtl_Item_Revisions_B rev1
     WHERE bet.group_id = p_group_id AND bet.component_item_revision_id IS NOT NULL AND
     rev1.revision_id = bet.component_item_revision_id AND rev1.Organization_Id = rev2.Organization_Id(+)
        AND rev1.Inventory_Item_Id = rev2.Inventory_Item_Id(+) AND rev2.Effectivity_Date(+) > rev1.Effectivity_Date
        AND rev2.implementation_date (+) IS NOT NULL
        GROUP BY rev1.Organization_Id, rev1.Inventory_Item_Id, rev1.Revision_Id, rev1.Revision, rev1.Effectivity_Date,
        rev1.Implementation_Date, rev1.Change_Notice, rev1.revision_label);

  CURSOR revTable (p_group_id IN NUMBER) IS
  SELECT nvl(BE.component_sequence_id,0) component_sequence_id, --nvl(BE.current_revision,
         --always call Get_Current_RevisionDetails, we want to pick the rev label from items
         -- even for fixed rev comps.
         BOM_EXPLODER_PUB.Get_Current_RevisionDetails(BE.component_item_id,
                                                        BE.organization_id,
                                                        decode(nvl(BE.component_item_revision_id, BE.comp_fixed_revision_id),
                                                            null,
                                                            BOM_EXPLODER_PUB.get_explosion_date,
                                                            BOM_EXPLODER_PUB.Get_Revision_HighDate(nvl(BE.component_item_revision_id, BE.comp_fixed_revision_id)))) current_revision,
         nvl(BE.component_item_revision_id,BOM_EXPLODER_PUB.Get_Current_Revision_Id) REVISION_ID,
         --nvl(BE.revision_label,
         BOM_EXPLODER_PUB.Get_Current_Revision_Label revision_label,
         BE.new_component_code component_code
  FROM bom_explosions_all BE WHERE BE.group_id = p_group_id;

  CURSOR revTableWithAccessFlag (p_group_id IN NUMBER) IS
  SELECT nvl(BE.component_sequence_id,0) component_sequence_id, nvl(BE.current_revision,
         BOM_EXPLODER_PUB.Get_Current_RevisionDetails(BE.component_item_id,
                                                BE.organization_id,
                                                decode(BE.comp_fixed_revision_id,
                                                   null,
                                                   BOM_EXPLODER_PUB.get_explosion_date,
                                                   BOM_EXPLODER_PUB.Get_Revision_HighDate(BE.comp_fixed_revision_id)))) current_revision,
         nvl(BE.component_item_revision_id,BOM_EXPLODER_PUB.Get_Current_Revision_Id) REVISION_ID,
         nvl(BE.revision_label, BOM_EXPLODER_PUB.Get_Current_Revision_Label) revision_label,
         BOM_SECURITY_PUB.CHECK_USER_PRIVILEGE(
               1,
               BOM_SECURITY_PUB.GET_FUNCTION_NAME_TO_CHECK,
               'EGO_ITEM',
               BE.PK1_VALUE,
               BE.ORGANIZATION_ID,
               NULL,
               NULL,
               NULL,
               BOM_EXPLODER_PUB.Get_EGO_User) ACCESS_FLAG
  FROM bom_explosions_all BE WHERE BE.group_id = p_group_id;


  CURSOR changePolicy (p_group_id IN NUMBER) IS
  SELECT
   nvl(item_dtls.component_sequence_id,0) AS component_sequence_id, ecp.policy_char_value
  FROM
   (SELECT NVL(mirb.lifecycle_id, msi.lifecycle_id) AS lifecycle_id,
     NVL(mirb.current_phase_id , msi.current_phase_id) AS phase_id,
     msi.item_catalog_group_id item_catalog_group_id,
     msi.inventory_item_id, msi.organization_id , mirb.revision_id,
     bet.component_sequence_id, bet.structure_type_id
   FROM bom_explosions_all bet, mtl_item_revisions_b mirb, MTL_SYSTEM_ITEMS_b msi
   WHERE bet.group_id = p_group_id AND bet.comp_bill_seq_id IS NOT NULL
     AND bet.component_item_id = msi.INVENTORY_ITEM_ID AND
     bet.organization_id = msi.ORGANIZATION_ID AND
     mirb.revision_id = BOM_EXPLODER_PUB.Get_Component_Revision_Id(NVL(BET.component_sequence_id,0))
     AND (mirb.current_phase_id IS NOT NULL OR msi.current_phase_id IS NOT NULL)) ITEM_DTLS,
     ENG_CHANGE_POLICIES_V ECP
 WHERE --ecp.policy_object_pk1_value = item_dtls.item_catalog_group_id
         ecp.policy_object_pk1_value =
              (SELECT TO_CHAR(ic.item_catalog_group_id)
               FROM mtl_item_catalog_groups_b ic
               WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                             FROM EGO_OBJ_TYPE_LIFECYCLES olc
                             WHERE olc.object_id = (SELECT OBJECT_ID
                                                    FROM fnd_objects
                                                    WHERE obj_name = 'EGO_ITEM')
                             AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                             AND olc.object_classification_code = ic.item_catalog_group_id
                             )
                AND ROWNUM = 1
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
   AND ecp.policy_object_pk2_value = item_dtls.lifecycle_id
   AND ecp.policy_object_pk3_value = item_dtls.phase_id
   AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
   AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
   AND ecp.attribute_code = 'STRUCTURE_TYPE'
   AND ecp.attribute_number_value = item_dtls.structure_type_id;

  l_bill_sequence_id          NUMBER;
  l_common_bill_sequence_id   NUMBER;
  l_top_bill_sequence_id      NUMBER;
  l_effectivity_control       NUMBER;
  l_structure_type_id         NUMBER;
  l_Pkg_Structure_Type_Id     NUMBER;

  l_item_rev         VARCHAR2(9);
  l_item_rev_id      NUMBER;
  l_minor_rev_id     NUMBER;

  l_pk_value1 VARCHAR2(240);
  l_pk_value2 VARCHAR2(240);
  l_obj_name  VARCHAR2(30);

  l_end_item_id          NUMBER;
  l_end_item_org_id      NUMBER;
  l_end_item_revision_id      NUMBER;
  l_end_item_revision_code    VARCHAR2(10);
  l_end_item_minor_revision_id      NUMBER;
  l_end_item_minor_revision_code   VARCHAR2(30);

  l_access_flag VARCHAR2(1);
  l_rexplode_flag VARCHAR2(1);

  l_alt_desg  VARCHAR2(10);

  l_exploded_date       DATE;
  l_exploded_unit_number  VARCHAR2(30);
  l_exploded_end_item_rev NUMBER;
  l_exploded_end_item_id NUMBER;
  l_exploded_end_item_org_id NUMBER;
  l_group_id  NUMBER;
  l_exploded_option NUMBER;

  l_explode_option NUMBER;

  l_explosion_group_id NUMBER;

  l_bill_expl_exists VARCHAR2(1) := 'N';
  l_bill_criteria_exists VARCHAR2(1) := 'N';
  l_dirty_node_exists VARCHAR2(1) := 'Y';
  l_reapply_exclusions VARCHAR2(1) := 'N';

  l_start_rev_date  DATE;

  --bug14116670 l_unit_number  NUMBER;

  l_show_rev        NUMBER := 1;
  l_max_bill_level NUMBER;
  max_level NUMBER;
  l_number NUMBER;

  l_bom_or_eng NUMBER;

  l_internal_user VARCHAR2(1) := 'N';
  l_person VARCHAR2(30);
  l_predicate VARCHAR2(32767);
  l_predicate_api_status VARCHAR2(1);

  --pragma  AUTONOMOUS_TRANSACTION; /* This is now controlled by the caller */

BEGIN

  --DBMS_PROFILER.START_PROFILER(to_char(session_id)||pk_value1||' : '||pk_value2);
    SELECT max(MAXIMUM_BOM_LEVEL)
    INTO max_level
    FROM BOM_PARAMETERS
    WHERE (org_id = -1
     or
    (org_id <> -1 AND ORGANIZATION_ID = org_id)
    );
   --max level cannot be greater than 60
   -- add for bug10107073
   IF nvl(levels_to_explode, 60) < nvl(max_level, 60)  THEN
		 max_level := levels_to_explode;
   END IF ;

   IF nvl(max_level, 60) > 60 THEN
  max_level := 60;
   END IF;

  X_SortWidth := BOMPBXIN.G_SortWidth;

  IF (verify_flag = 1) AND (module <> 2) THEN
    raise parameter_error;
  END IF;

  /* Grp id is not a mandatory parameter anymore
  IF (grp_id is null or item_id is null) THEN
    raise parameter_error;
  END IF;
  */

  IF (item_id is null) THEN
    raise parameter_error;
  END IF;
  stmt_num := 2;

  IF (object_name IS NULL) AND
     (pk_value1 IS NULL OR pk_value2 IS NULL) THEN
    raise parameter_error;
  END IF;

  IF (pk_value1 IS NULL)  THEN
    raise parameter_error;
  END IF;

  /* Resolve the structure name (alt_desg) */
  /* Find out the preferred BOM when the structure type id is passed in, and alt_desg is not passed */

  IF (structure_type_id IS NULL) THEN
    l_alt_desg := alt_desg;
  ELSE
    IF alt_desg IS NOT NULL THEN
      l_alt_desg := alt_desg;
    ELSE
      /* Find out the preferred BOM */
      FOR r1 IN getPreferredStructure ( p_obj_name => object_name,
                                        p_pk1_value => pk_value1,
                                        p_pk2_value => pk_value2,
                                        p_structure_type_id => structure_type_id)
      LOOP
        l_alt_desg := r1.alternate_bom_designator;
      END LOOP;
    END IF;
  END IF;

  /* Reset all the globally used values */

  Reset_Globals;

  G_EGOUser := BOM_SECURITY_PUB.Get_EGO_User;

  -- Get the bill sequence id and common bill sequence id

  BEGIN

    SELECT bill_sequence_id,common_bill_sequence_id,effectivity_control, bill_sequence_id, structure_type_id, assembly_type
    INTO l_bill_sequence_id, l_common_bill_sequence_id, l_effectivity_control,l_top_bill_sequence_id, l_structure_type_id, l_bom_or_eng
    FROM bom_structures_b bom
    WHERE nvl(bom.obj_name,'EGO_ITEM') = nvl(object_name,'EGO_ITEM')
    AND bom.pk1_value = pk_value1
    AND nvl(bom.pk2_value,'-1') = nvl(pk_value2,'-1')
    AND   bom.organization_id = org_id
    AND   nvl(bom.alternate_bom_designator, 'NONE') = nvl(l_alt_desg, 'NONE');
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
      Null;

  END;

  --Dbms_Output.Put_line('Top Bill seq is : '||l_bill_sequence_id);

  /* Resolve the xplode option */

  IF (explode_option IN (2,3))
  THEN
    -- Do the xplosion for "Current and Future" for both "Current" and "Current and Future" options
    -- For rev effective BOMS, explosions are seperately maintained for "Current" and "Current and Future" options
    l_show_rev       := 2;
    --bug 9530687, for effectivity control BOM, when explosion option = 2(Current), set explosion option to 3
    --Current and Future explosion option contains all the components satisfying Current option
    --BOM_EXPLOSIONS_V will filter the components with right explode_option (BOM_EXPLODER_PUB.Get_Explode_Option())
    --this make sure that future components does not shown the explosion structure of Current explode option
    --IF nvl(l_effectivity_control,1) = 1
    --THEN
    --  l_explode_option := explode_option;
    --ELSE
      l_explode_option := explode_option; /*Changed for bug 8635467 with base bug 8628001*/
    --END IF ;

    /*
    IF nvl(l_effectivity_control,1) <> 4
    THEN
      l_explode_option := 3;
      l_show_rev       := 2; -- Revisions are resolved dynamically for non-rev eff BOMs.
    ELSE
      l_explode_option := explode_option;
    END IF;
    */

    /* Also find out the effectivity date of the first rev. This will be the date
    on which we do the explosion*/
    /*
    IF object_name IS NULL
    THEN
      FOR r1 IN c_get_first_revision( p_inventory_item_id => pk_value1,
                                      p_organization_id => pk_value2)
      LOOP
        l_start_rev_date := r1.effectivity_date;
      END LOOP;
    END IF;
    */
  ELSE
    l_show_rev       := 2;
    l_explode_option := 1;
  END IF;

  -- Check if the explosion already exists for this criteria

    --bom_or_eng => bom_or_eng, (always do for ENG)
    --impl_flag => impl_flag, ( always to for both impl and unimpl)
    --l_explode_option => explode_option, (All or Current and Future)
    --unit_number => unit_number,
    --rev_date => l_rev_date,
    --end_item_rev_id => l_end_item_revision_id,

  /* Resolve all the criteria */

  /**** Moved before the insertion of 0th row
        so that revision id is fetched only once and can be inserted
        in the 0th row
  *****/
  l_item_rev     := null;  -- CAD component
  l_item_rev_id  := null;  -- CAD component

  -- Get the item rev IF the explosion is for Item BOM

  --Dbms_Output.Put_line('obj name check');

  IF object_name IS NULL
  THEN

    l_pk_value1 := pk_value1;
    l_pk_value2 := pk_value2;

    /* For end item rev effective common BOM, the end item rev should come FROM the common BOM
       If the user is requesting for a particular end item rev, then don't do this*/


    IF (l_effectivity_control = 4 ) AND (end_item_revision_id IS NULL) -- End item effective
    THEN

      IF (l_bill_sequence_id <> l_common_bill_sequence_id)
      THEN

        -- If item BOM is commoning an item BOM, THEN we get the current item rev FROM the
        -- common BOM to explode in the case of end irem revision effective

        SELECT pk1_value, pk2_value,obj_name INTO l_pk_value1, l_pk_value2, l_obj_name FROM
        bom_structures_b WHERE bill_sequence_id = l_common_bill_sequence_id;

        IF (l_obj_name IS NOT NULL) -- NON ITEM
        THEN
          -- If item BOM is commoning a CAD BOM, THEN we get the current item rev FROM the  same
          -- current item BOM to explode in the case of end irem revision effective
          -- Reset the PK values
          l_pk_value1 := pk_value1;
          l_pk_value2 := pk_value2;
        END IF;

      END IF;

    END IF;

    /* Align the context revision with end item revision when the end item is same as context item */

    IF end_item_revision_id IS NOT NULL
    THEN

      FOR r1 IN getEndItemRev(end_item_revision_id)
      LOOP
        IF (r1.inventory_item_id = l_pk_value1 AND r1.organization_id = l_pk_value2)
        THEN
          l_item_rev_id := end_item_revision_id;
          l_item_rev    := r1.revision;
          l_rev_date    := r1.effectivity_date;
        ELSE
          FOR r1 IN getItemRev(l_pk_value1, l_pk_value2, l_rev_date)
          LOOP
            l_item_rev    := r1.revision;
            l_item_rev_id := r1.revision_id;
          END LOOP;
        END IF;
      END LOOP;

    ELSE

      FOR r1 IN getItemRev(l_pk_value1, l_pk_value2, l_rev_date)
      LOOP
        l_item_rev    := r1.revision;
        l_item_rev_id := r1.revision_id;
      END LOOP;
    END IF;


    IF l_item_rev IS NULL
    THEN
      raise parameter_error;
    END IF;

  END IF;

  BEGIN

    FOR pkg_type IN c_Pkg_Structure_Type
    LOOP
      l_Pkg_Structure_Type_Id := pkg_type.structure_type_id;
    END LOOP;

    SELECT 'Y'
          , rexplode_flag
          , exploded_date
          , exploded_unit_number
          , exploded_end_item_rev
          , exploded_end_item_id
          , exploded_end_item_org_id
          , exploded_option
          , group_id
          , reapply_exclusions
          , max_bill_level
     INTO   l_bill_expl_exists
          , l_rexplode_flag
          , l_exploded_date
          , l_exploded_unit_number
          , l_exploded_end_item_rev
          , l_exploded_end_item_id
          , l_exploded_end_item_org_id
          , l_exploded_option
          , l_explosion_group_id
          , l_reapply_exclusions
          , l_max_bill_level
     FROM BOM_EXPLOSIONS_ALL
    WHERE top_bill_sequence_id = l_bill_sequence_id
      AND exploded_option = l_explode_option
      AND plan_level = 0;

    grp_id := l_explosion_group_id;

    IF nvl(l_rexplode_flag,'0') = '1' OR nvl(max_level, 60) <> nvl(l_max_bill_level, 60) OR
      l_Pkg_Structure_Type_Id = l_structure_type_id
       /*Changes done as part of bug 8635467 with base bug 8628001*/
 	     OR BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(l_pk_value1, l_pk_value2,l_exploded_date) <> BOM_EXPLODER_PUB.GET_CURRENT_REVISIONDETAILS(l_pk_value1, l_pk_value2,l_rev_date)
 	     OR l_exploded_option <> explode_option
 	     /*End of change*/

      -- change made for P4Telco CMR, bug# 8761845
      OR
      nvl(levels_to_explode, 60) > nvl(l_max_bill_level, 60) OR
      nvl(std_bom_explode_flag, 'Y') = 'N'
    THEN
      l_rexplode_flag := 1;
      --set the rexplode flag if max bill level is changed.

      UPDATE BOM_EXPLOSIONS_ALL
       SET rexplode_flag = 1
       WHERE group_id = grp_id
         AND sort_order = '0000001';

      DELETE FROM BOM_EXPLOSIONS_ALL
       WHERE group_id = grp_id
         AND sort_order <> '0000001';

--Always do an engg explosion for packaging hierarchies
--bug:4744303
      IF l_Pkg_Structure_Type_Id = l_structure_type_id
      THEN
        l_bom_or_eng := 2;
      END IF;

    END IF;

    /*
    IF p_autonomous_transaction = 1 THEN
      Commit;
    END IF;
    */

    EXCEPTION WHEN NO_DATA_FOUND
    THEN
      -- Insert for plan level 0

      SELECT BOM_EXPLOSIONS_ALL_S.NEXTVAL INTO grp_id FROM dual;

      insert INTO BOM_EXPLOSIONS_ALL
      (
      group_id,
      bill_sequence_id,
      common_bill_sequence_id,
      common_organization_id,
      component_sequence_id,
      organization_id,
      top_item_id,
      component_item_id,
      plan_level,
      extended_quantity,
      basis_type,
      component_quantity,
      sort_order,
      program_update_date,
      top_bill_sequence_id,
      component_code,
      loop_flag,
      top_alternate_designator,
      obj_name,
      pk1_value,
      pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      new_component_code,
      parent_sort_order,
      comp_common_bill_seq_id,
      comp_source_bill_seq_id,
      comp_bill_seq_id,
      effectivity_control,
      access_flag,
      assembly_type,
      bom_implementation_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      rexplode_flag,
      exploded_option,
      structure_type_id,
      revision_id,
      implementation_date,
      max_bill_level,
      is_preferred,
      parent_implementation_date,
      hgrid_flag,
      source_bill_sequence_id,
      comp_effectivity_control
      )
      (select
      --explosion_group_id,
      grp_id,
      bom.bill_sequence_id,
      bom.common_bill_sequence_id,
      nvl(bom.common_organization_id,org_id),
      NULL,
      org_id,
      item_id,
      item_id,
      0,
      expl_qty,
      1,
      1,
      lpad('1', X_SortWidth, '0'),
      sysdate,
      bom.bill_sequence_id,
      nvl(comp_code, lpad(pk1_value, 16, '0')),
      2,
      l_alt_desg,
      obj_name,
      pk1_value,
      pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      nvl(comp_code, lpad(decode(obj_name,'DDD_CADVIEW','C','I')||pk1_value, 20, '0')),
      null,
      bom.common_bill_sequence_id,
      bom.source_bill_sequence_id,
      bom.bill_sequence_id,
      bom.effectivity_control,
      'T',
      bom.assembly_type,
      bom.implementation_date,
      bom.creation_date,
      bom.created_by,
      bom.last_update_date,
      bom.last_updated_by,
      1,
      l_explode_option,
      structure_type_id,
      l_item_rev_id,
      bom.implementation_date,
      max_level,
      is_preferred,
      bom.implementation_date,
      'Y',
      bom.source_bill_sequence_id,
      bom.effectivity_control
      FROM bom_structures_b bom
      where bill_sequence_id = l_bill_sequence_id);

      IF (SQL%NOTFOUND) THEN
        insert INTO BOM_EXPLOSIONS_ALL
        (
        group_id,
        top_item_id,
        component_item_id,
        organization_id,
        bill_sequence_id,
        top_bill_sequence_id,
        plan_level,
        sort_order,
        gtin_number,
        gtin_description,
        trade_item_descriptor,
        trade_item_descriptor_desc,
        obj_name,
        pk1_value,
        pk2_value,
        pk3_value,
        pk4_value,
        pk5_value,
        hgrid_flag
        )
        (select
        grp_id,
        item_id,
        item_id,
        org_id,
        0,
        0,
        0,
        lpad('1', X_SortWidth, '0'),
        gtin,
        description,
        trade_item_descriptor,
        trade_item_descriptor_desc,
        object_name,
        pk_value1,
        pk_value2,
        pk_value3,
        pk_value4,
        pk_value5,
        'Y'
        FROM ego_items_v eiv
        where
        eiv.inventory_item_id = item_id
        AND eiv.organization_id = org_id);

        IF (SQL%NOTFOUND) THEN
          raise no_data_found;
        END IF;

        /* We can't exit an autonomous transcation without completing it */

        IF p_autonomous_transaction = 1 THEN
          Commit;
        END IF;

        /* Before retuen set the group id context for the view */

        BOM_EXPLODER_PUB.p_explode_option          := explode_option ;
        BOM_EXPLODER_PUB.p_group_id                := grp_id;
        Return;

     END IF;
  END;

  --Dbms_Output.put_line('Row count '||sql%rowcount);

  --Dbms_Output.put_line('l_item_rev is '||l_item_rev);

  -- Get the minor_rev_id IF it is not passed

  IF (minor_rev_id IS NULL)
  THEN
    FOR r1 in getCurrentMinorRev (object_name, l_pk_value1, l_pk_value2,l_item_rev_id)
    LOOP
      l_minor_rev_id := r1.minor_revision_id;
    END LOOP;
  ELSE
    l_minor_rev_id := minor_rev_id;
  END IF;

  IF l_minor_rev_id IS NULL
  THEN
    raise parameter_error;
  END IF;

  IF (l_effectivity_control = 4 ) -- End Item Rev Effective
  THEN

    /* If the top item itself is an end item, then the exploder doesn't
       require end item revision to be passed
       Do the end item explosion for the current item rev and the minor rev
     */

    IF end_item_revision_id IS NULL
    THEN
      l_end_item_revision_id := l_item_rev_id;
    ELSE
      l_end_item_revision_id := end_item_revision_id;
    END IF;

    IF l_end_item_revision_id IS NULL
    THEN
      raise parameter_error;
    END IF;

    -- Get the end item information
    IF l_end_item_id IS NULL THEN

      BEGIN
        SELECT inventory_item_id, organization_id, revision INTO l_end_item_id, l_end_item_org_id,l_end_item_revision_code FROM mtl_item_revisions_b
         WHERE revision_id = l_end_item_revision_id;
        EXCEPTION WHEN OTHERS THEN
          --Dbms_Output.put_line('End item revision is not valid'||sqlerrm);
          raise parameter_error;
      END;

    END IF;

  END IF;

  IF (l_end_item_revision_id IS NOT NULL)
  THEN

    /* If end item minor rev id is not passed, then do it for the current minor rev of that item rev */

    IF (end_item_minor_revision_id IS NULL)
    THEN
      IF (end_item_revision_id IS NULL) -- If the top item itself is an end item
      THEN
        /* If the user did not pass the minor rev AND the top item itself is end item,
           THEN we aleady got the minor rev */
        l_end_item_minor_revision_id := l_minor_rev_id;
      ELSE
        FOR r1 IN getCurrentMinorRevForItemRev(l_end_item_revision_id)
        LOOP
          l_end_item_minor_revision_id := r1.minor_revision_id;
        END LOOP;
      END IF;
    ELSE
      l_end_item_minor_revision_id := end_item_minor_revision_id;
    END IF;

    IF l_end_item_minor_revision_id IS NULL
    THEN
      raise parameter_error;
    END IF;

  END IF;

  /* Also, find out the minor rev code (used internally) */

  IF (l_end_item_minor_revision_id IS NOT NULL)
  THEN
    FOR r1 IN getEndItemMinorRevCode(l_end_item_revision_id, l_end_item_minor_revision_id)
    LOOP
      l_end_item_minor_revision_code := r1.mrev_code;
    END LOOP;

    IF l_end_item_minor_revision_code IS NULL
    THEN
      raise parameter_error;
    END IF;

  END IF;

  /* Now we got object revision id, minor rev id, end item id, end item org id, end item revision id,
     end item minor revision id, end item minor rev code

     Check if we already have an explosion for this criteria
     */

  --Dbms_Output.put_line('Object rev id : '||l_item_rev_id);
  --Dbms_Output.put_line('Minor rev id : '||l_minor_rev_id);
  --Dbms_Output.put_line('end_item_id : '||l_end_item_id);
  --Dbms_Output.put_line('end_item_org_id : '||l_end_item_org_id);
  --Dbms_Output.put_line('end_item_rev_id : '||l_end_item_revision_id);
  --Dbms_Output.put_line('end_item_minor_rev_id : '||l_end_item_minor_revision_id);
  --Dbms_Output.put_line('end_item_minor_rev_code : '||l_end_item_minor_revision_code);

  --Dbms_Output.put_line('l_exploded_option '||l_exploded_option);
  --Dbms_Output.put_line('l_explode_option '||l_explode_option);
  --Dbms_Output.put_line('l_effectivity_control '||l_effectivity_control);
  --Dbms_Output.put_line('l_exploded_date '||to_char(l_exploded_date,'dd-mon-yy hh24:mi:ss'));
  --Dbms_Output.put_line('l_rev_date '||to_char(l_rev_date,'dd-mon-yy hh24:mi:ss'));

  --Dbms_Output.put_line('Group Id '||grp_id);

  /* Assign the context information so that the view filters the data further
     to make it more specific to the current session criteria */

  --BOM_EXPLODER_PUB.p_top_bill_sequence_id    := l_bill_sequence_id;
  BOM_EXPLODER_PUB.p_explode_option          := explode_option ;
  BOM_EXPLODER_PUB.p_explosion_date          := l_rev_date;
  BOM_EXPLODER_PUB.p_expl_end_item_rev       := l_end_item_revision_id;
  BOM_EXPLODER_PUB.p_expl_end_item_rev_code  := l_end_item_revision_code;
  BOM_EXPLODER_PUB.p_expl_end_item_id        := l_end_item_id;
  BOM_EXPLODER_PUB.p_expl_end_item_org_id    := l_end_item_org_id;
  BOM_EXPLODER_PUB.p_expl_unit_number        := unit_number;
  BOM_EXPLODER_PUB.p_group_id                := grp_id;
  BOM_EXPLODER_PUB.p_top_effectivity_control := nvl(l_effectivity_control,1);

  IF l_bill_expl_exists = 'Y' AND nvl(l_rexplode_flag,'0') <> '1'
  THEN

    /* If the explosion exists for the bill and it can satisfy the
    current explosion requirements, then do not reexplode */

    IF ( l_explode_option = 1 AND l_exploded_option = l_explode_option)
      OR
       ( ((Nvl(l_effectivity_control,1) = 1 AND l_exploded_date <= l_rev_date )
         OR (Nvl(l_effectivity_control,1) IN (2,3) AND l_exploded_unit_number <= unit_number)
         OR ( Nvl(l_effectivity_control,1) = 4 AND l_exploded_end_item_id = l_end_item_id
              AND  l_exploded_end_item_org_id = l_end_item_org_id  ))
         AND (l_exploded_option = l_explode_option))
    THEN

      l_bill_criteria_exists := 'Y';
      /* The explosion for this criteria already happened.
         But,do not return as the exploder still needs to reexplode the nodes that are dirty */
    ELSE

      /* Reexplode otherwise */

      UPDATE BOM_EXPLOSIONS_ALL
         SET rexplode_flag = 1
       WHERE group_id = grp_id
           AND sort_order = '0000001';

      DELETE FROM BOM_EXPLOSIONS_ALL
       WHERE group_id = grp_id
           AND sort_order <> '0000001';

      --Commit;

    END IF;

  END IF;

  --bug14116670
  --IF l_effectivity_control IN (2,3)
  --THEN
    /* Get the minimum Unit/Serial number from the BOM */

    /* Actually, just use 0 */
    --l_unit_number := 0;
  --END IF;

  /* Update the top bill with the effectivity and minor rev information.
     Do not do this if the explosion criteria matches with the exploded one */

  IF l_bill_criteria_exists = 'Y' AND nvl(l_rexplode_flag,'0') <> '1'
  THEN

    l_dirty_node_exists := 'N';

    /* Clean up the dirty nodes before the explosion */

    FOR r1 IN c_dirty_nodes(grp_id)
    LOOP

      l_dirty_node_exists := 'Y';

      --Dbms_Output.put_line('Clean up the dirty nodes before the explosion : '||r1.sort_order);
      DELETE FROM BOM_EXPLOSIONS_ALL
      WHERE  group_id = grp_id
      AND sort_order like r1.sort_order||'%' AND sort_order <> r1.sort_order;

      --Update the change_policy value for the leaf component that has become a subassembly.
      UPDATE BOM_EXPLOSIONS_ALL
      SET CHANGE_POLICY_VALUE = Get_Change_Policy_Val(0, r1.comp_bill_seq_id)
      WHERE sort_order = r1.sort_order
      AND group_id = grp_id;

      --Commit;

    END LOOP;

    /* If bill criteria exists and there are no dirty nodes found in the hierarchy, then return */

    IF l_dirty_node_exists = 'N'
    THEN
      IF nvl(l_reapply_exclusions, 'N') = 'Y' THEN
        -- ReApply the exclusion rules
        Apply_Exclusion_Rules(grp_id,1);
      END IF;

      IF p_autonomous_transaction = 1 THEN
        commit;
      END IF;

    ELSE

      UPDATE BOM_EXPLOSIONS_ALL
        SET exploded_date = l_rev_date,
            exploded_unit_number = unit_number,
            --exploded_unit_number = l_unit_number,
            exploded_end_item_rev = l_end_item_revision_id,
            exploded_end_item_id = l_end_item_id,
            exploded_end_item_org_id = l_end_item_org_id,
            object_revision_id = l_item_rev_id,
            minor_revision_id = l_minor_rev_id,
            revision_id = l_item_rev_id, --insert top item's rev id
            max_bill_level = nvl(max_level,60),
            end_item_id = l_end_item_id,
            end_item_org_id = l_end_item_org_id
            --effectivity_date = l_rev_date,
            --from_end_item_unit_number = unit_number
        WHERE  group_id = grp_id
              AND sort_order = '0000001';

    END IF;

  ELSE

    UPDATE BOM_EXPLOSIONS_ALL
      SET exploded_date = l_rev_date,
          exploded_unit_number = unit_number,
          --exploded_unit_number = l_unit_number,
          exploded_end_item_rev = l_end_item_revision_id,
          exploded_end_item_id = l_end_item_id,
          exploded_end_item_org_id = l_end_item_org_id,
          object_revision_id = l_item_rev_id,
          minor_revision_id = l_minor_rev_id,
          revision_id = l_item_rev_id, --insert top item's rev id
          max_bill_level = nvl(max_level,60),
          end_item_id = l_end_item_id,
          end_item_org_id = l_end_item_org_id
          --effectivity_date = l_rev_date,
          --from_end_item_unit_number = unit_number
      WHERE  group_id = grp_id
            AND sort_order = '0000001';
  END IF;

  IF l_dirty_node_exists = 'Y'
  THEN

    IF (object_name IS NULL)
    THEN

      /* Apply the security when the object is an inventory item */

      l_access_flag  := 'T';

      /* Security check should be moved to the view as it is user based

      IF (G_EGOUser is null) THEN
        l_access_flag  := 'T';
      ELSE
        l_access_flag := BOM_SECURITY_PUB.CHECK_USER_PRIVILEGE(
        p_api_version => 1,
        p_function => BOM_SECURITY_PUB.FUNCTION_NAME_TO_CHECK,
        p_object_name=>'EGO_ITEM',
        p_instance_pk1_value=> pk_value1,
        p_instance_pk2_value=> pk_value2,
        p_user_name=> G_EGOUser);
      END IF;
      */

      /* Get the BOM item type and Parent BOM item type for item BOM */

      /*
      UPDATE BOM_EXPLOSIONS_ALL
      SET access_flag = l_access_flag,
       (bom_item_type, parent_bom_item_type, primary_uom_code, eng_item_flag, primary_unit_of_measure) = (SELECT msi.bom_item_type, msi.bom_item_type, msi.primary_uom_code,
        msi.eng_item_flag, (select description from mtl_units_of_measure where uom_code = msi.primary_uom_code) FROM
        mtl_system_items_b msi WHERE  msi.inventory_item_id = item_id AND msi.organization_id = org_id)
      WHERE  group_id = grp_id
          AND sort_order = '0000001';
      */

      UPDATE BOM_EXPLOSIONS_ALL
      SET access_flag = l_access_flag,
       (bom_item_type, parent_bom_item_type, primary_uom_code, eng_item_flag, primary_unit_of_measure) = (SELECT msi.bom_item_type, msi.bom_item_type, msi.primary_uom_code,
        msi.eng_item_flag, muom.unit_of_measure FROM mtl_system_items_b msi, mtl_units_of_measure muom
        WHERE  msi.inventory_item_id = item_id AND msi.organization_id = org_id AND muom.uom_code = msi.primary_uom_code)
      WHERE group_id = grp_id
             AND sort_order = '0000001';

      IF (SQL%NOTFOUND) THEN
        raise no_data_found;
      END IF;

      UPDATE BOM_EXPLOSIONS_ALL
      SET (gtin_number, gtin_description, trade_item_descriptor, top_gtin_number, top_gtin_description, top_trade_item_descriptor, trade_item_descriptor_desc, gtin_publication_status) =
           (SELECT gtin, description, trade_item_descriptor, gtin, description, trade_item_descriptor, trade_item_descriptor_desc, publication_status
            FROM ego_items_v egi
            WHERE inventory_item_id = item_id AND organization_id = org_id)
      WHERE  group_id = grp_id
      AND sort_order = '0000001';

      /* Update the change policy value for the top item */
      UPDATE BOM_EXPLOSIONS_ALL
        SET CHANGE_POLICY_VALUE = Get_Change_Policy_Val(revision_id, Comp_bill_seq_Id)
      WHERE  group_id = grp_id
          AND sort_order = '0000001';

    END IF;


    Exploders(
    verify_flag => verify_flag,
    online_flag => 1,
    org_id => org_id,
    order_by => order_by,
    grp_id => grp_id,
    session_id => session_id,

    -- change made for P4Telco CMR, bug# 8761845
    l_levels_to_explode => levels_to_explode,

    bom_or_eng => l_bom_or_eng,  --changed by arudresh to pass assy type of parent bill. bug: 4422266
    impl_flag => impl_flag , --2 --Bug 7110428
    plan_factor_flag => plan_factor_flag,
    l_explode_option => l_explode_option,
    module => module,
    unit_number => unit_number,
    cst_type_id => cst_type_id,
    std_comp_flag => std_comp_flag,
    rev_date => l_rev_date,
    object_rev_id => l_item_rev_id,
    minor_rev_id => l_minor_rev_id,
    --show_rev => 1,
    show_rev => l_show_rev,
    material_ctrl => material_ctrl,
    lead_time => lead_time,
    object_name => object_name,
    pk_value1 => pk_value1,
    pk_value2 => pk_value2,
    pk_value3 => pk_value3,
    pk_value4 => pk_value4,
    pk_value5 => pk_value5,
    end_item_id => l_end_item_id,
    end_item_org_id => l_end_item_org_id,
    end_item_rev_id => l_end_item_revision_id,
    end_item_minor_rev_id => l_end_item_minor_revision_id,
    end_item_minor_rev_code => l_end_item_minor_revision_code,
    filter_pbom  => filter_pbom,
    top_bill_sequence => l_top_bill_sequence_id,
    max_level => max_level,
    err_msg => out_message,
    error_code => out_code,

    --change made for P4Telco CMR, bug# 8761845
    std_bom_explode_flag => std_bom_explode_flag
    );

    IF (verify_flag <> 1 AND (out_code = 9999 or out_code = 9998
      or out_code < 0)) THEN
      raise exploder_error;
    ELSIF (verify_flag = 1 AND (out_code = 9998 or out_code < 0)) THEN
      raise exploder_error;
    END IF;

    IF (module = 1) THEN
      BOMPCEXP.cst_exploder(
      grp_id => grp_id,
      org_id => org_id,
      cst_type_id => cst_type_id,
      inq_flag => 1,
      err_msg => out_message,
        error_code => out_code);
    END IF;

      IF (verify_flag = 1) THEN
         Loopstr2msg( grp_id, out_message );
      END IF;

  -- If the master organization is referenced as the costing organization THEN
  -- is_cost_organzation flag is set to 'N' ELSE IF the child organization itself
  -- referenced as the costing organization THEN the is_cost_organization flag is
  -- set to 'Y'.

     SELECT count(*) INTO  cnt
     FROM   mtl_parameters
     WHERE  organization_id = cost_organization_id
            AND organization_id = org_id;

     IF (cnt >0) THEN
       is_cost_organization := 'Y';
     ELSE
       is_cost_organization := 'N';
     END IF;

  -- If the Intended Bill is referenced some other bill of different organization
  -- THEN the conversion rate, uom of the component in the child organization
  -- should be calculated.

    IF (object_name IS NULL) THEN

     FOR cr IN cur(grp_id)  LOOP
      BEGIN

      SELECT msi.primary_uom_code, msi.organization_id into
             t_master_uom, t_master_org_id
      FROM   mtl_system_items_b msi, bom_structures_b bbm
      WHERE  cr.curCBSI = bbm.bill_sequence_id and
             bbm.organization_id = msi.organization_id and
             msi.inventory_item_id = cr.curCII;

      SELECT msi.primary_uom_code INTO t_child_uom
      FROM   mtl_system_items_b msi
      WHERE  msi.inventory_item_id = cr.curCII and
             msi.organization_id = cr.curOI;

     OPEN conv(t_master_uom, t_child_uom, cr.curCII, t_master_org_id);
     Fetch conv INTO t_conversion_rate;
     IF conv%NOTFOUND THEN
       close conv;
       raise inv_uom_conv_exe;
     End if;
     close conv;

  -- If cost_organization is Master organization THEN the item cost should be
  -- calculated by multiplying the conversion_rate.

      IF is_cost_organization <> 'Y' THEN
         UPDATE BOM_EXPLOSIONS_ALL
         SET    item_cost = item_cost*t_conversion_rate
         WHERE  group_id = cr.curGI and
                component_sequence_id = cr.curCSI and
                bill_sequence_id = cr.curBSI and
                common_bill_sequence_id = cr.curCBSI;
      END IF;

      UPDATE BOM_EXPLOSIONS_ALL
      SET    component_quantity = component_quantity/t_conversion_rate,
             extended_quantity = extended_quantity/t_conversion_rate,
  --           item_cost = item_cost*t_conversion_rate,
             primary_uom_code = cr.curPUC,
       primary_unit_of_measure = cr.curPUM
      WHERE  group_id = cr.curGI and
             component_sequence_id = cr.curCSI and
             bill_sequence_id = cr.curBSI and
             common_bill_sequence_id = cr.curCBSI;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
      END;
     END LOOP;
   END IF;

    /* Update the explosion to make sure reexplosion doesn't happen */

    /* insert attachments for level 0 */

    /*
    for c in (select rexplode_flag from BOM_EXPLOSIONS_ALL
                where group_id = grp_id
                  and plan_level = 0)
    loop
    if c.rexplode_flag = 1
    then
      --Dbms_Output.put_line('Inserting attachments for level 0 .....................2');
                  Insert_Attachments( p_group_id   => grp_id
                                    , p_plan_level => 0
                                    );
     end if;
    end loop;
    */


    /* Fetch the structure type id for Packaging Hierarchy seeded type */
    /* Packaging hierarchy will always be rexploded
    FOR pkg_type IN c_Pkg_Structure_Type
    LOOP
      l_Pkg_Structure_Type_Id := pkg_type.structure_type_id;
    END LOOP;

    -- Remove the rows that are disabled so far and
    -- recompute the pkg hky attributes (total quantity and qty at next level)
    IF l_Pkg_Structure_Type_Id = l_Structure_Type_Id
    THEN

      DELETE FROM bom_explosions_all
      WHERE group_id = grp_id
      AND nvl(trimmed_disable_date, l_rev_date+1) <= l_rev_date;

      UPDATE bom_explosions_all
        SET exploded_date = l_rev_date,
            object_revision_id = l_item_rev_id,
            minor_revision_id = l_minor_rev_id,
            revision_id = l_item_rev_id --insert top item's rev id
            --effectivity_date = l_rev_date
        WHERE  group_id = grp_id
              AND sort_order = '0000001';

      UPDATE BOM_EXPLOSIONS_ALL BE
        SET (quantity_of_children, total_qty_at_next_level) =
            (SELECT count(*), sum(component_quantity) FROM bom_explosions_all
            WHERE group_id = BE.group_id AND
                  parent_sort_order = BE.sort_order)
        WHERE group_id = grp_id AND comp_bill_seq_id IS NOT NULL;

      IF p_autonomous_transaction = 1 THEN
        Commit;
      END IF;

    END IF;
    */

    UPDATE BOM_EXPLOSIONS_ALL
       SET rexplode_flag = 0
     WHERE group_id = grp_id AND comp_bill_seq_id IS NOT NULL AND rexplode_flag = 1;

    -- change made for P4Telco CMR, bug# 8761845
    -- if Explode Standard BOM is unchecked (defaultly checked),
    -- or if the level for explosion is not the same with max bom level
    -- bom explosion should be done again next time to make sure the structure is correct.
    --comment for bug10107073
    /*
    IF ( nvl(levels_to_explode, 60) <> nvl(l_max_bill_level, 60) OR
         nvl(std_bom_explode_flag, 'Y') = 'N') THEN
      UPDATE BOM_EXPLOSIONS_ALL
         SET rexplode_flag = 1
       WHERE group_id = grp_id AND comp_bill_seq_id IS NOT NULL AND rexplode_flag = 0;
    END IF;
 */
    IF p_autonomous_transaction = 1 THEN
      Commit;
    END IF;

  END IF; -- IF l_dirty_node_exists = 'Y' ends here

  /* Clear the pl/sql tables used for caching the rev information */
  revision_highdate_array.DELETE;
  component_revision_array.DELETE;
  component_revision_id_array.DELETE;
  component_revision_label_array.DELETE;
  asss_without_access_array.DELETE;
  compseqs_without_access_array.DELETE;
  access_flag_array.DELETE;
  change_policy_array.DELETE;

  /* For Date effective BOMs:
     Cache the revision high date information using revision id as the index */

  --Get the fixed revisions from the explosion

  /*
  IF l_effectivity_control = 1
  THEN
  */

   FOR r1 IN getFixedRevDetails(grp_id)
   LOOP
    --dbms_output.put_line('FR : '||r1.revision_id||'/'||r1.revision_high_date);
    revision_highdate_array(r1.revision_id) := r1.revision_high_date;
   END LOOP;
  /*
  END IF;
  */

  /*
  IF l_effectivity_control = 4
  THEN
  */
    /* For the components that come under a fixed rev hiearrchy, the revisions should be
        derived based on the high date of the fixed rev.
        The fixed rev hierarchy is identified by a value at comp_fixed_revision_id
        BE.comp_fixed_revision_id is the revision_id of the parent node (or it could be prior to that)*/

    /* For the components that do not come under a fixed rev hiearrchy, the revisions should be
        derived based on the high date of the end item rev */
      --dbms_output.put_line('rev table is getting built ');

  /* Get the security predicate */

  SELECT 'HZ_PARTY'||':'||person_party_id INTO l_person
  FROM fnd_user WHERE user_name = FND_Global.User_Name;

  --dbms_output.put_line('l_person  : '||l_person);

  EGO_DATA_SECURITY.get_security_predicate(
           p_api_version      =>1.0,
           p_function         =>'EGO_VIEW_ITEM',
           p_object_name      =>'EGO_ITEM',
           p_user_name        => l_person,
           p_statement_type   =>'EXISTS',
           p_pk1_alias        =>'BE.PK1_VALUE',
           p_pk2_alias        =>'BE.ORGANIZATION_ID',
           p_pk3_alias        =>NULL,
           p_pk4_alias        =>NULL,
           p_pk5_alias        =>NULL,
           x_predicate        => l_predicate,
           x_return_status    => l_predicate_api_status);
  /*
  dbms_output.put_line('l_predicate_api_status  : '||l_predicate_api_status);
  dbms_output.put_line(substr(l_predicate,1,250));
  dbms_output.put_line(substr(l_predicate,251,250));
  dbms_output.put_line(substr(l_predicate,501,250));
  dbms_output.put_line(substr(l_predicate,751,250));
  dbms_output.put_line(substr(l_predicate,1001,250));
  dbms_output.put_line(substr(l_predicate,1251,250));
  */
  IF l_predicate_api_status <> 'T'
  THEN
    Raise NO_DATA_FOUND;
  END IF;

  IF l_predicate IS NULL
  THEN
    l_internal_user := 'Y';
  ELSE
    /* Select all the assemblies for which the user has no access */

    EXECUTE IMMEDIATE 'SELECT BE.new_component_code FROM bom_explosions_all BE WHERE BE.group_id = '||grp_id||' AND comp_bill_seq_id IS NOT NULL AND NOT '|| l_predicate
    BULK COLLECT INTO asss_without_access_array;
   --dbms_output.put_line('assss without access : '||asss_without_access_array.COUNT);

    /* Select all the leaf nodes for which the user has no access */

    EXECUTE IMMEDIATE 'SELECT BE.component_sequence_id FROM bom_explosions_all BE WHERE BE.group_id = '||grp_id||' AND comp_bill_seq_id IS NULL AND NOT '|| l_predicate
    BULK COLLECT INTO compseqs_without_access_array;

   --dbms_output.put_line('comps without access : '||compseqs_without_access_array.COUNT);

  END IF;

  --dbms_output.put_line('Is Internal user : '||l_internal_user);

  /* For an internal user with view item privilege, there is no check.
     Also, if the user has view privilege on all the assemblies then there is
     no propagation of security within the hierarchy. In this case security for the
     leaf nodes will be applied later */

  IF l_internal_user = 'Y' OR asss_without_access_array.COUNT = 0
  THEN
      FOR r1 IN revTable(grp_id)
      LOOP
        component_revision_array (r1.component_sequence_id) := r1.current_revision;
        component_revision_id_array (r1.component_sequence_id) := r1.revision_id;
        component_revision_label_array (r1.component_sequence_id) := r1.revision_label;
        access_flag_array (r1.component_sequence_id) := 'T';
      END LOOP;
  ELSE
      FOR r1 IN revTable(grp_id)
      LOOP
        component_revision_array (r1.component_sequence_id) := r1.current_revision;
        component_revision_id_array (r1.component_sequence_id) := r1.revision_id;
        component_revision_label_array (r1.component_sequence_id) := r1.revision_label;
        access_flag_array (r1.component_sequence_id) := Check_Component_Access(r1.component_code);
      END LOOP;
  END IF;

  /* Apply the security for the leaf nodes */

  IF compseqs_without_access_array.COUNT <> 0
  THEN
    FOR i IN 1..compseqs_without_access_array.COUNT
    LOOP
      access_flag_array (compseqs_without_access_array(i)) := 'F';
    END LOOP;
  END IF;
  /*
  END IF;
  */
 --dbms_output.put_line('rev table is DONE ');

  /* Construct the change policy table. This will hold all the components(sub assemblies) for which
    there is a structure change policy */

  --change_policy_array (0) := 'ALLOWED';

  FOR r1 IN changePolicy(grp_id)
  LOOP
    change_policy_array (r1.component_sequence_id) := r1.policy_char_value;
  END LOOP;

  /* Bulk collect all the rev specific exclusions into a table */

  SELECT exclusion_path
  BULK COLLECT INTO rev_specific_exclusions_array
  FROM bom_explosions_all be,
       bom_rules_b rule,
       bom_exclusion_rule_def excl
  WHERE be.group_id = grp_id
  AND be.comp_bill_seq_id IS NOT NULL --get only the bills not its components
  AND be.comp_bill_seq_id = rule.bill_sequence_id
  AND rule.rule_id = excl.rule_id
  AND excl.from_revision_id IS NOT NULL --conditions to pickup only rev level exclusions
  AND excl.implementation_date IS NOT NULL -- do not pickup the pending exclusions
  AND excl.disable_date IS NULL -- do not pickup the disabled exclusions
  AND excl.acd_type = 1 -- pickup only the exclusion entries
  AND Get_Component_Revision(nvl(be.component_sequence_id,0)) >= (SELECT revision FROM mtl_item_revisions_b WHERE
                                                                  revision_id = excl.from_revision_id) AND
      ( excl.to_revision_id IS NULL OR
        Get_Component_Revision(nvl(be.component_sequence_id,0)) <= (SELECT revision FROM mtl_item_revisions_b WHERE
                                                                  revision_id = excl.to_revision_id));
 error_code  := out_code;
 err_msg := out_message;

 /*
 FND_STATS.GATHER_TABLE_STATS (
     errbuf           => out_message,
     retcode          => out_message,
     ownname          => 'BOM',
     tabname          => 'BOM_EXPLOSIONS_ALL'
     );
 */
  --DBMS_PROFILER.STOP_PROFILER;

EXCEPTION
    when exploder_error THEN
      IF p_autonomous_transaction = 1 THEN
        rollback;
      END IF;
      error_code := out_code;
      err_msg  := out_message;
    WHEN parameter_error THEN
      IF p_autonomous_transaction = 1 THEN
        rollback;
      END IF;
      error_code  := -1;
      err_msg := 'parameter error';
      Fnd_Msg_Pub.Build_Exc_Msg(
        p_pkg_name => 'BOM_EXPLODER_PUB',
        p_procedure_name => 'exploder_userexit',
        p_error_text => 'verify parameters');
      err_msg := Fnd_Message.Get_Encoded;
    WHEN  inv_uom_conv_exe THEN
      IF p_autonomous_transaction = 1 THEN
        rollback;
      END IF;
      FND_MESSAGE.SET_NAME('BOM','BOM_UOMCV_INVUOMTYPE_ERR');
      fnd_message.Set_Token('FROMUOM',t_master_uom);
      fnd_message.Set_Token('TOUOM',t_child_uom);
      fnd_message.raise_error;
    WHEN OTHERS THEN
      IF p_autonomous_transaction = 1 THEN
        rollback;
      END IF;
      error_code      := SQLCODE;
      Fnd_Msg_Pub.Build_Exc_Msg(
        p_pkg_name => 'BOM_EXPLODER_PUB',
        p_procedure_name => 'exploder_userexit',
        p_error_text => SQLERRM);
      err_msg := Fnd_Message.Get_Encoded;
      --ROLLBACK;
END exploder_userexit_pvt;

procedure exploder_userexit_autonomous (
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
  structure_type_id IN NUMBER DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,


  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'
  ) AS

  pragma  AUTONOMOUS_TRANSACTION;

BEGIN

  exploder_userexit_pvt (
  verify_flag                 => verify_flag ,
  org_id                      => org_id ,
  order_by                    => order_by,
  grp_id                      => grp_id,
  session_id                  => session_id,
  levels_to_explode           => levels_to_explode,
  bom_or_eng                  => bom_or_eng,
  impl_flag                   => impl_flag,
  plan_factor_flag            => plan_factor_flag,
  explode_option              => explode_option,
  module                      => module,
  cst_type_id                 => cst_type_id,
  std_comp_flag               => std_comp_flag,
  expl_qty                    => expl_qty,
  unit_number                 => unit_number,
  alt_desg                    => alt_desg,
  comp_code                   => comp_code,
  rev_date                    => rev_date,
  minor_rev_id                => minor_rev_id,
  material_ctrl               => material_ctrl,
  lead_time                   => lead_time,
  object_name                 => object_name,
  pk_value1                   => pk_value1,
  pk_value2                   => pk_value2,
  pk_value3                   => pk_value3,
  pk_value4                   => pk_value4,
  pk_value5                   => pk_value5,
  end_item_id                 => end_item_id,
  end_item_revision_id        => end_item_revision_id,
  end_item_minor_revision_id  => end_item_minor_revision_id,
  err_msg                     => err_msg,
  error_code                  => error_code,
  end_item_strc_revision_id   => end_item_strc_revision_id,
  show_rev                    => show_rev,
  structure_rev_id            => structure_rev_id,
  structure_type_id           => structure_type_id,
  filter_pbom                 => filter_pbom,
  p_autonomous_transaction    => 1,
  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag => std_bom_explode_flag
  );

END;

procedure exploder_userexit_non_auto (
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
  structure_type_id IN NUMBER DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,
  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y'
  ) AS

BEGIN

  exploder_userexit_pvt (
  verify_flag                 => verify_flag ,
  org_id                      => org_id ,
  order_by                    => order_by,
  grp_id                      => grp_id,
  session_id                  => session_id,
  levels_to_explode           => levels_to_explode,
  bom_or_eng                  => bom_or_eng,
  impl_flag                   => impl_flag,
  plan_factor_flag            => plan_factor_flag,
  explode_option              => explode_option,
  module                      => module,
  cst_type_id                 => cst_type_id,
  std_comp_flag               => std_comp_flag,
  expl_qty                    => expl_qty,
  unit_number                 => unit_number,
  alt_desg                    => alt_desg,
  comp_code                   => comp_code,
  rev_date                    => rev_date,
  minor_rev_id                => minor_rev_id,
  material_ctrl               => material_ctrl,
  lead_time                   => lead_time,
  object_name                 => object_name,
  pk_value1                   => pk_value1,
  pk_value2                   => pk_value2,
  pk_value3                   => pk_value3,
  pk_value4                   => pk_value4,
  pk_value5                   => pk_value5,
  end_item_id                 => end_item_id,
  end_item_revision_id        => end_item_revision_id,
  end_item_minor_revision_id  => end_item_minor_revision_id,
  err_msg                     => err_msg,
  error_code                  => error_code,
  end_item_strc_revision_id   => end_item_strc_revision_id,
  show_rev                    => show_rev,
  structure_rev_id            => structure_rev_id,
  structure_type_id           => structure_type_id,
  filter_pbom                 => filter_pbom,
  p_autonomous_transaction    => 2,
  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag => std_bom_explode_flag
  );

END;

procedure exploder_userexit (
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
  structure_type_id IN NUMBER DEFAULT NULL,
  filter_pbom  IN VARCHAR2 DEFAULT NULL,
  p_autonomous_transaction IN NUMBER DEFAULT 1,

  --change made for P4Telco CMR, bug# 8761845
  std_bom_explode_flag IN VARCHAR2 DEFAULT 'Y' ) AS

BEGIN

  IF p_autonomous_transaction = 1
  THEN
    exploder_userexit_autonomous (
    verify_flag                 => verify_flag ,
    org_id                      => org_id ,
    order_by                    => order_by,
    grp_id                      => grp_id,
    session_id                  => session_id,
    levels_to_explode           => levels_to_explode,
    bom_or_eng                  => bom_or_eng,
    impl_flag                   => impl_flag,
    plan_factor_flag            => plan_factor_flag,
    explode_option              => explode_option,
    module                      => module,
    cst_type_id                 => cst_type_id,
    std_comp_flag               => std_comp_flag,
    expl_qty                    => expl_qty,
    unit_number                 => unit_number,
    alt_desg                    => alt_desg,
    comp_code                   => comp_code,
    rev_date                    => rev_date,
    minor_rev_id                => minor_rev_id,
    material_ctrl               => material_ctrl,
    lead_time                   => lead_time,
    object_name                 => object_name,
    pk_value1                   => pk_value1,
    pk_value2                   => pk_value2,
    pk_value3                   => pk_value3,
    pk_value4                   => pk_value4,
    pk_value5                   => pk_value5,
    end_item_id                 => end_item_id,
    end_item_revision_id        => end_item_revision_id,
    end_item_minor_revision_id  => end_item_minor_revision_id,
    err_msg                     => err_msg,
    error_code                  => error_code,
    end_item_strc_revision_id   => end_item_strc_revision_id,
    show_rev                    => show_rev,
    structure_rev_id            => structure_rev_id,
    structure_type_id           => structure_type_id,
    filter_pbom                 => filter_pbom,
    --change made for P4Telco CMR, bug# 8761845
    std_bom_explode_flag => std_bom_explode_flag);
  ELSE
    exploder_userexit_non_auto (
    verify_flag                 => verify_flag ,
    org_id                      => org_id ,
    order_by                    => order_by,
    grp_id                      => grp_id,
    session_id                  => session_id,
    levels_to_explode           => levels_to_explode,
    bom_or_eng                  => bom_or_eng,
    impl_flag                   => impl_flag,
    plan_factor_flag            => plan_factor_flag,
    explode_option              => explode_option,
    module                      => module,
    cst_type_id                 => cst_type_id,
    std_comp_flag               => std_comp_flag,
    expl_qty                    => expl_qty,
    unit_number                 => unit_number,
    alt_desg                    => alt_desg,
    comp_code                   => comp_code,
    rev_date                    => rev_date,
    minor_rev_id                => minor_rev_id,
    material_ctrl               => material_ctrl,
    lead_time                   => lead_time,
    object_name                 => object_name,
    pk_value1                   => pk_value1,
    pk_value2                   => pk_value2,
    pk_value3                   => pk_value3,
    pk_value4                   => pk_value4,
    pk_value5                   => pk_value5,
    end_item_id                 => end_item_id,
    end_item_revision_id        => end_item_revision_id,
    end_item_minor_revision_id  => end_item_minor_revision_id,
    err_msg                     => err_msg,
    error_code                  => error_code,
    end_item_strc_revision_id   => end_item_strc_revision_id,
    show_rev                    => show_rev,
    structure_rev_id            => structure_rev_id,
    structure_type_id           => structure_type_id,
    filter_pbom                 => filter_pbom,
    --change made for P4Telco CMR, bug# 8761845
    std_bom_explode_flag => std_bom_explode_flag);
  END IF;
END;

FUNCTION Get_Top_Bill_Sequence_Id RETURN NUMBER
IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Top_Bill_Sequence_Id;
END;

FUNCTION Get_Explosion_Date RETURN DATE IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Explosion_Date;
END;

FUNCTION Get_Expl_End_Item_Rev RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Expl_End_Item_Rev;
END;

FUNCTION Get_Expl_End_Item_Rev_Code RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Expl_End_Item_Rev_Code;
END;

FUNCTION Get_Expl_Unit_Number RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Expl_Unit_Number;
END;

FUNCTION Get_Explode_Option RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Explode_Option;
END;

FUNCTION Get_Group_Id RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Group_Id;
END;

FUNCTION Get_Top_Effectivity_Control RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.p_Group_Id;
END;

FUNCTION Get_Component_Revision(p_component_sequence_id NUMBER) RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.component_revision_array(p_component_sequence_id);
END;

FUNCTION Get_Component_Revision_Id(p_component_sequence_id NUMBER) RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.component_revision_id_array(p_component_sequence_id);
END;

FUNCTION Get_Component_Revision_Label(p_component_sequence_id NUMBER) RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.component_revision_label_array(p_component_sequence_id);
END;

FUNCTION Get_Revision_HighDate(p_revision_id NUMBER) RETURN DATE IS
BEGIN
  Return BOM_EXPLODER_PUB.revision_highdate_array(p_revision_id);
END;

FUNCTION Get_Component_Access_Flag(p_component_sequence_id NUMBER) RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.access_flag_array(p_component_sequence_id);
END;

FUNCTION Get_EGO_User RETURN VARCHAR2 IS
BEGIN
  Return G_EGOUser;
END;

FUNCTION Get_Current_Revision_Code RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.p_current_revision_code;
END;

FUNCTION Get_Current_Revision_Id RETURN NUMBER IS
BEGIN
  Return BOM_EXPLODER_PUB.p_current_revision_id;
END;

FUNCTION Get_Current_Revision_Label RETURN VARCHAR2 IS
BEGIN
  Return BOM_EXPLODER_PUB.p_current_revision_label;
END;

FUNCTION Get_Change_Policy(p_component_sequence_id NUMBER) RETURN VARCHAR2 IS
BEGIN
  --Return nvl(BOM_EXPLODER_PUB.change_policy_array(p_component_sequence_id),'ALLOWED');
  Return BOM_EXPLODER_PUB.change_policy_array(p_component_sequence_id);
END;

FUNCTION Get_Current_RevisionId( p_inventory_item_id  IN NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_effectivity_date IN DATE) RETURN NUMBER IS
    CURSOR c1 IS
    SELECT revision, revision_id,revision_label FROM mtl_item_revisions_b WHERE
    inventory_item_id = p_inventory_item_id AND organization_id = p_organization_id AND
    effectivity_date <= p_effectivity_date
    AND ((BOM_GLOBALS.get_show_Impl_comps_only = 'Y' AND implementation_date IS NOT NULL) OR  BOM_GLOBALS.get_show_Impl_comps_only = 'N')  -- added for Bug 7242865
    ORDER BY effectivity_date DESC;

  BEGIN

    OPEN c1;
    FETCH c1 INTO p_current_revision_code, p_current_revision_id, p_current_revision_label;
    IF c1%ROWCOUNT = 0
    THEN
      p_current_revision_code := null ;
      p_current_revision_id := null;
      p_current_revision_label := null;
    END IF;
    CLOSE c1;
    Return p_current_revision_id;
    EXCEPTION WHEN OTHERS THEN
      p_current_revision_code := null ;
      p_current_revision_id := null;
      p_current_revision_label := null;
      Return null;

  END;

END BOM_EXPLODER_PUB;

/
