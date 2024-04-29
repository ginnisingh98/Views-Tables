--------------------------------------------------------
--  DDL for Package Body BOM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_UTIL" as
/* $Header: BOMUTILB.pls 120.1 2006/03/17 12:53:15 seradhak noship $ */
  -- -----------------------------------------------------------------------
  FUNCTION get_first_level_components
      (p_cbill_sequence_id IN BOM_BILL_OF_MATERIALS.bill_sequence_id%TYPE)
     RETURN NUMBER IS
   l_first_level_count NUMBER := 0;
  BEGIN

   if p_cbill_sequence_id is null
   then
  return 0;
   end if;

   SELECT count(bill_sequence_id)  INTO l_first_level_count
   FROM bom_inventory_components
   WHERE bill_sequence_id = p_cbill_sequence_id
   AND implementation_date is NOT NULL;

   RETURN l_first_level_count;

  END get_first_level_components;

  -- -----------------------------------------------------------------------
  FUNCTION get_change_order_count
      (p_bill_sequence_id IN BOM_BILL_OF_MATERIALS.bill_sequence_id%TYPE)
     RETURN NUMBER IS
    l_change_order_count NUMBER := 0;
  BEGIN

    if p_bill_sequence_id is null
    then
  return 0;
    end if;

    SELECT count(distinct change_id)  INTO l_change_order_count
    FROM ENG_REVISED_ITEMS
    WHERE bill_sequence_id = p_bill_sequence_id;

    RETURN l_change_order_count;
  END get_change_order_count;
  -- -----------------------------------------------------------------------
  FUNCTION get_second_level_components
      (p_component_item_id   IN
                BOM_INVENTORY_COMPONENTS.component_item_id%TYPE,
       p_organization_id     IN NUMBER,
       p_alternate_bom_designator IN VARCHAR2)
     RETURN NUMBER is
    l_component_count NUMBER := 0;
  BEGIN

     if (p_component_item_id is null)
     then
   return 0;
     end if;

     SELECT count(*) into l_component_count
     FROM
       BOM_INVENTORY_COMPONENTS bomc
     WHERE
        implementation_date is NOT NULL
       AND bomc.bill_sequence_id IN -- For Bug Fix . 2832017
           (SELECT common_bill_sequence_id
            FROM
              BOM_BILL_OF_MATERIALS bom
            WHERE
                bom.assembly_item_id = p_component_item_id
            AND bom.organization_id  = p_organization_id
             -- Commented for Bug Fix 2832017
             -- AND bom.alternate_bom_designator = p_alternate_bom_designator
           );

     RETURN l_component_count;

  END get_second_level_components;
  -- --------------------------------------------------------------------------
  FUNCTION getFirstLevelComponents(p_component_item_id IN NUMBER,
                                            p_bill_sequence_id  IN NUMBER,
                                            p_top_bill_sequence_id IN NUMBER,
                                            p_plan_level        IN NUMBER,
                                            p_organization_id   IN NUMBER)
     RETURN NUMBER IS
    l_component_count NUMBER := 0;
  BEGIN
      /*
        AND  organization_id = p_organization_id */

      if p_bill_sequence_id is null or p_component_item_id is null
      then
     return 0;
      end if;
     SELECT count(*) into l_component_count
     FROM bom_explosions_V
      WHERE  assembly_item_id = p_component_item_id
        and   top_bill_sequence_id = p_top_bill_sequence_id
       --AND   bill_sequence_id = p_bill_sequence_id
       AND  plan_level = p_plan_level + 1;

    RETURN l_component_count;
  END getFirstLevelComponents;
  -- --------------------------------------------------------------------------
  FUNCTION get_effective_date(p_structure_type_id IN NUMBER)
   RETURN DATE IS
   l_effective_date DATE;
  BEGIN
    SELECT effective_date INTO l_effective_date
    FROM bom_structure_types_b
    WHERE structure_type_id = p_structure_type_id;

    RETURN l_effective_date;

  END get_effective_date;
  -- --------------------------------------------------------------------------
  FUNCTION get_disable_date(p_structure_type_id IN NUMBER)
   RETURN DATE Is
   l_disable_date DATE;
  BEGIN
     SELECT disable_date INTO l_disable_date
     FROM bom_structure_types_b
     WHERE structure_type_id = p_structure_type_id;

   RETURN l_disable_date;

  END get_disable_date;
  -- --------------------------------------------------------------------------
  FUNCTION check_structures_exist(p_structure_type_id IN NUMBER)
   RETURN VARCHAR2 IS
   l_structures_count NUMBER := 0;

  BEGIN
    SELECT count(*) INTO l_structures_count
    FROM bom_bill_of_materials
    WHERE structure_type_id = p_structure_type_id;

    IF l_structures_count = 0 THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;

  END check_structures_exist;
  -- --------------------------------
  FUNCTION check_id_exist(p_structure_type_id IN NUMBER)
   RETURN VARCHAR2 IS
   l_count NUMBER := 0;

  BEGIN
    SELECT count(*) INTO l_count
    FROM bom_structure_types_b
    WHERE structure_type_id = p_structure_type_id;
    IF l_count = 0 THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;

  END check_id_exist;
  -- --------------------------------------------------------------------
    /*************************************************************************
  * Local Procedure: Calculate_both_totals
  * Parameter IN	 : old_component_sequenc_id
  * Parameters OUT : Total Quantity of Designators
  * Purpose	 : Procedure calculate_both_totals will take the component
  *		   sequence_id and calculate the number of designators that
  *		   already exist for it and the how many exist on the same
  *		   component on the ECO with an acd_type of add or disable
  *		   Then by making use of the set operater it will eliminate
  *		   the disable one's from the list. This is the quantity
  *		   of designator that will remain on the component after
  *		   implementation and is returned by the procedure as
  *		   Total Quantity.
  **************************************************************************/
  PROCEDURE Calculate_Both_Totals( p_old_component_sequence_id	IN 	NUMBER,
           x_TotalQuantity		IN OUT NOCOPY 	NUMBER
          )
  IS

    X_OldComp NUMBER;
    X_Add CONSTANT NUMBER := 1;
    X_Delete CONSTANT NUMBER := 3;
    l_Implemented_Count	NUMBER;
    l_dummy		VARCHAR2(80);

    CURSOR GetTotalQty IS
      SELECT brd.component_reference_designator
      FROM bom_reference_designators brd
      WHERE brd.component_sequence_id = p_old_component_sequence_id
      AND NVL(brd.acd_type, X_Add) = X_Add
      UNION
      SELECT brd.component_reference_designator
      FROM bom_reference_designators brd,
           bom_inventory_components bic
      WHERE DECODE(bic.old_component_sequence_id, NULL,
       bic.component_sequence_id,
       bic.old_component_sequence_id) = p_old_component_sequence_id
      AND   bic.component_sequence_id = brd.component_sequence_id
      AND   bic.implementation_date IS NULL
      AND   brd.acd_type = X_Add
      MINUS
      SELECT brd.component_reference_designator
      FROM bom_reference_designators brd,
           bom_inventory_components bic
      WHERE DECODE(bic.old_component_sequence_id, NULL,
       bic.component_sequence_id,
       bic.old_component_sequence_id) = p_old_component_sequence_id
      AND   bic.component_sequence_id = brd.component_sequence_id
      AND   bic.implementation_date IS NULL
      AND   brd.acd_type = X_Delete;

  BEGIN
    FOR X_Designators IN GetTotalQty LOOP
      X_TotalQuantity := GetTotalQty%rowcount;
      RETURN;
    END LOOP;

    -- Else return 0
    X_TotalQuantity := 0;

  END Calculate_Both_Totals;
  -- -------------------------------------------------------------------------------
  PROCEDURE validate_RefDesig_Entity
  ( p_organization_id IN NUMBER
     , p_component_seq_id IN NUMBER
     , p_ref_desig_name IN VARCHAR2
     , p_acd_type IN NUMBER
     , x_return_status IN OUT NOCOPY VARCHAR2
  ) IS
     l_return_status VARCHAR2(1) := 'S';
     l_dummy			      VARCHAR(80);

     CURSOR c_acdtype IS
       SELECT acd_type, old_component_sequence_id
       FROM bom_inventory_components bic
           WHERE bic.component_sequence_id = p_component_seq_id;

     CURSOR c_QuantityRelated IS
    SELECT component_quantity
        FROM bom_inventory_components
          WHERE component_sequence_id = p_component_seq_id
        AND quantity_related = 1;

  BEGIN
     x_return_status := 'SUCCESS';
    /**********************************************************************
    * If the Transaction Type is CREATE and the ACD_Type = Disable, then
    * the reference designator should already exist for the revised
    * component.
    ***********************************************************************/
     IF p_acd_type = 3 THEN

      BEGIN
        SELECT component_reference_designator INTO l_dummy
        FROM bom_reference_designators brd,bom_inventory_components bic
        WHERE bic.component_sequence_id = p_component_seq_id
          AND brd.component_sequence_id = bic.old_component_sequence_id
          AND brd.component_reference_designator = p_ref_desig_name;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- It means that the reference designator does not exist on the
          -- revised component or it is probably not implemented yet.

          x_return_status := 'BOM_DISABLE_DESG_NOT_FOUND';
          l_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
      END;

     END IF;

       /************************************************************************
       * Check if ACD_Type of component is ADD then ref. desg is also add.
       *************************************************************************/

      FOR acd IN c_acdtype LOOP
        --
        -- If the component has an ACD_Type of ADD then ref. Desg must also be ADD
        --
        IF acd.acd_type = 1 /* ADD */ AND
             p_acd_type <> 1
        THEN
        l_return_status := Fnd_Api.G_RET_STS_ERROR;
            x_return_status := 'BOM_RFD_ACD_NOT_COMPATIBLE';
        RETURN;
        END IF;
      END LOOP;


      /************************************************************************
      * If the Transaction Type is CREATE and the ACD_type is ADD then check the
      * type of item to which a ref. designator is being added. Planning bills
      * cannot have ref. desgs and also  components which are not Standard cannot
      * have ref. desgs. This OR so even if either exists Ref. Designators cannot
      * be added.
      *************************************************************************/

      BEGIN
        SELECT 'Non-Standard Comp'
            INTO l_dummy
            FROM bom_inventory_Components bic
           WHERE bic.component_sequence_id = p_component_seq_id
             AND bic.bom_item_type IN (1, 2, 3); /*MODEL,OPTION CLASS,PLANNING*/

       -- If no exception is raised then
       -- Generate an error saying that the component is non-standard.

          l_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_return_status := 'BOM_RFD_NON_STD_PARENT';
      RETURN;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- do nothing
        NULL;
      WHEN OTHERS THEN
        -- do nothing
        NULL;

    END;  /* End Checking for non-standard component */

       BEGIN
      SELECT 'Planning Bill'
        INTO l_dummy
        FROM sys.dual
             WHERE EXISTS (SELECT 'Planning Item'
                 FROM bom_bill_of_materials bom,
                  mtl_system_items msi,
            bom_inventory_components bic
                WHERE msi.bom_item_type	= 3 /* PLANNING */
              AND msi.inventory_item_id = bom.assembly_item_id
                    AND msi.organization_id   = bom.organization_id
              AND bom.bill_sequence_id = bic.bill_sequence_id
              AND bic.component_sequence_id = p_component_seq_id
          );

      -- If a record is found, then log an error because of the above
      -- mentioned comment.
      l_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_return_status := 'BOM_RFD_PLANNING_BILL';
      RETURN;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; -- Do nothing
      WHEN OTHERS THEN
        NULL; -- Do nothing
       END;  /* End Checking for Planning Parent */

  END validate_RefDesig_Entity;
  -- -------------------------------------------------------------------------------
  PROCEDURE check_RefDesig_Access
  ( p_organization_id IN NUMBER
  , p_assembly_item_id IN NUMBER
  , p_alternate_bom_code IN VARCHAR2
  , p_ref_desig_name IN VARCHAR2
  , p_component_item_id IN NUMBER
  , p_component_item_name IN VARCHAR2
  , p_component_seq_id IN NUMBER
  , x_return_status IN OUT NOCOPY VARCHAR2
  )IS
     l_return_status VARCHAR2(1) := 'S';
     l_dummy			      VARCHAR(80);
     l_bom_ref_designator_rec	Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
     l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  BEGIN
        x_return_status := 'SUCCESS';
      Bom_Validate_Bom_Header.Check_Access
      (  p_organization_id=>p_organization_id
            ,  p_assembly_item_id=>p_assembly_item_id
      ,  p_alternate_bom_code=>p_alternate_bom_code
      ,  p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
      ,  x_Mesg_Token_Tbl    	=> l_Mesg_Token_Tbl
            ,  x_return_status     	=> l_Return_Status
      );
      IF l_Mesg_Token_Tbl.COUNT > 0
      THEN
             x_return_status := l_Mesg_Token_Tbl(1).message_text;
           RETURN;
      END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
             x_return_status := 'BOM_RFD_RITACC_FAT_FATAL';
           RETURN;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
             x_return_status := 'BOM_RFD_RITACC_UNEXP_SKIP';
           RETURN;
      END IF;
      -- Check that user has access to Bom component
      Bom_Validate_Bom_Component.Check_Access
      (  p_organization_id	=> p_organization_id
      ,  p_component_item_id => p_component_item_id
      ,  p_component_name     => p_component_item_name
      ,  x_Mesg_Token_Tbl    	=> l_Mesg_Token_Tbl
          ,  x_return_status     	=> l_Return_Status
      );

      IF l_Mesg_Token_Tbl.COUNT > 0
      THEN
             x_return_status := l_Mesg_Token_Tbl(1).message_text;
           RETURN;
      END IF;
        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
             x_return_status := 'BOM_RFD_CMPACC_FAT_FATAL';
           RETURN;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
             x_return_status := 'BOM_RFD_CMPACC_UNEXP_SKIP';
           RETURN;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
        NULL;

      -- Check Reference Designator Access
        BEGIN
            SELECT 'parent not disabled'
              INTO l_dummy
              FROM bom_inventory_components bic
            WHERE bic.component_sequence_id = p_component_seq_id
               AND NVL(bic.acd_type, 0)  <> 3;
        EXCEPTION
      WHEN NO_DATA_FOUND THEN
            -- This means that the parent is disabled as the record search
        -- was fired to get a parent which is not disabled
            x_return_status := 'BOM_RFD_COMP_ACD_TYPE_DISABLE';
        RETURN;
      WHEN OTHERS THEN
            --This means that an unexpected error has occured
            x_return_status := 'ERROR in Entity validation '
               || SUBSTR(SQLERRM, 1, 240) || ' ' || TO_CHAR(SQLCODE);
        RETURN;
        END;
  END check_RefDesig_Access;
  -- -------------------------------------------------------------------------------
  PROCEDURE get_RefDesig_Quantity
     ( p_component_seq_id IN NUMBER
     , p_acd_type IN NUMBER
     , x_refdesig_qty IN OUT NOCOPY NUMBER
     , x_qty_related IN OUT NOCOPY NUMBER
     , x_comp_qty IN OUT NOCOPY NUMBER
     ) IS
     l_ref_qty	NUMBER := 0;
     l_quantity	NUMBER;

     CURSOR c_acdtype IS
       SELECT acd_type, old_component_sequence_id
       FROM bom_inventory_components bic
           WHERE bic.component_sequence_id = p_component_seq_id;

    CURSOR c_QuantityRelated IS
      SELECT component_quantity
              FROM bom_inventory_components
             WHERE component_sequence_id = p_component_seq_id
               AND quantity_related = 1;


  BEGIN
    x_qty_related := 0;
    x_comp_qty := 0;

    OPEN c_QuantityRelated;
    FETCH c_QuantityRelated INTO l_Quantity;
      IF c_QuantityRelated%FOUND THEN

        x_qty_related := 1;
        x_comp_qty := l_Quantity;

        FOR acd IN c_acdtype LOOP
          IF acd.acd_type = 2 /* CHANGE */
          THEN
             Calculate_Both_Totals
             (  p_old_component_sequence_id => acd.old_component_sequence_id
              , x_TotalQuantity  => l_ref_qty
              );
          ELSE
             Calculate_Both_Totals
             (  p_old_component_sequence_id => p_component_seq_id
              , x_TotalQuantity  => l_ref_qty);
          END IF;
        END LOOP;

      END IF;

    CLOSE c_QuantityRelated;

    x_refdesig_qty := l_ref_qty;

  END get_RefDesig_Quantity;
  -- ---------------------------------------------------------------------------------
   FUNCTION get_change_notice(p_change_line_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_get_change_notice(c_p_change_line_id NUMBER)
      IS
         SELECT eec.change_notice
         FROM
           eng_engineering_changes eec,
	   eng_revised_items eri--eng_change_lines ecl
         WHERE eri.change_id/*cl.change_id*/ = eec.change_id
        -- AND  ecl.change_line_id = c_p_change_line_id;
        AND eri.revised_item_sequence_id = c_p_change_line_id;
     l_change_notice eng_engineering_changes.change_notice%type;
   BEGIN
     OPEN c_get_change_notice(p_change_line_id);
     FETCH c_get_change_notice INTO l_change_notice;
     IF c_get_change_notice%FOUND THEN
       CLOSE c_get_change_notice;
       RETURN l_change_notice;
     ELSE
       CLOSE c_get_change_notice;
       RETURN '';
     END IF;
   END get_change_notice;
   -- --------------------------------------------------

   FUNCTION get_person_name(p_user_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_get_person_name(c_p_user_id NUMBER)
    IS
       SELECT  person_first_name ||' '||person_last_name
       FROM hz_parties
       WHERE party_id = (SELECT customer_id FROM FND_USER
                  WHERE user_id = c_p_user_id);
     l_user_name varchar2(400);
   BEGIN
     OPEN c_get_person_name(p_user_id);
     FETCH c_get_person_name INTO l_user_name;
     IF c_get_person_name%FOUND THEN
       CLOSE c_get_person_name;
       RETURN l_user_name;
     ELSE
       CLOSE c_get_person_name;
       RETURN '';
     END IF;
   END get_person_name;
   -- -----------------------------------------------------
   FUNCTION get_implemen_date(p_bill_sequence_id IN NUMBER)
    RETURN DATE is
   BEGIN
       RETURN null;
   END get_implemen_date;
END BOM_UTIL;

/
