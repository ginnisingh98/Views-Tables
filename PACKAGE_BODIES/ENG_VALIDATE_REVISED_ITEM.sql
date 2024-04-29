--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_REVISED_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_REVISED_ITEM" AS
/* $Header: ENGLRITB.pls 120.13.12010000.11 2013/07/16 18:49:51 umajumde ship $ */

--  Global constant holding the package name

        G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ENG_Validate_Revised_Item';

        /* Added by MK on 09/01/2000 ECO for Routing */
        l_sub_locator_control         NUMBER;
        l_locator_control             NUMBER;
        l_org_locator_control         NUMBER;
        l_item_locator_control        NUMBER;
        l_item_loc_restricted         NUMBER; -- 1,Locator is Restricted,else 2


/****************************************************************************
* Function      : Compatible_Item_Type
* Parameters IN : Change Notice
*                 Organization ID
*                 Revised item ID
* Returns       : True or False
* Purpose       : Function will look at the type of ECO by looking at the
*                 change order type. If it has Engineering as checked, then the
*                 ECO can allow for manufacturing as well as engineering item
*                 else it can have only manufacturing items. To verify the type
*                 of item, the function will also look at the item's
*                 eng_item_flag attribute.
******************************************************************************/
FUNCTION Compatible_Item_Type
( p_organization_id             IN  NUMBER
, p_revised_item_id             IN NUMBER
, p_assembly_type               IN NUMBER)RETURN BOOLEAN
IS
        l_assembly_type         NUMBER := 0;

        l_eng_item_flag         VARCHAR2(1) := NULL;
        CURSOR eng_item_cur IS
                SELECT eng_item_flag
                  FROM mtl_system_items
                 WHERE inventory_item_id = p_revised_item_id
                   AND organization_id = p_organization_id;

BEGIN

  OPEN eng_item_cur;
  FETCH eng_item_cur into l_eng_item_flag;
  CLOSE eng_item_cur;

  IF (p_assembly_type = 1 and l_eng_item_flag = 'N') or
     (p_assembly_type = 2)
  THEN
        RETURN TRUE;
  ELSE
        RETURN FALSE;
  END IF;

END Compatible_Item_Type;


/******************************************************************************
* Function      : Pending_High_Rev (Local function)
* Parameters    : Change Notice
*                 Organization Id
*                 revised item id
* Returns       : True if the highest revision exists on another ECO else False
* Purpose       : Checks if the (currently) highest un-implemented revision of
*                 the revised item exists on another ECO
******************************************************************************/
PROCEDURE Pending_High_Rev
( p_change_notice               IN  VARCHAR2
, p_organization_id             IN  NUMBER
, p_revised_item_id             IN  NUMBER
, x_change_notice               OUT NOCOPY VARCHAR2
, x_revision                    OUT NOCOPY VARCHAR2
)
IS
        l_change_notice         VARCHAR2(10) := NULL;

        l_item_rev      VARCHAR2(3) := NULL;

        CURSOR ITEM_REV IS
               SELECT revision
                 FROM Mtl_Item_Revisions
                WHERE inventory_item_id = p_revised_item_id
                  AND organization_id = p_organization_id
             ORDER BY effectivity_date desc, revision desc;

BEGIN
        OPEN ITEM_REV;
        FETCH ITEM_REV into l_item_rev;
        CLOSE ITEM_REV;

        IF l_item_rev IS NOT NULL
        THEN
                l_change_notice :=
                        ENG_REVISED_ITEMS_PKG.Get_High_Rev_ECO
                        ( X_Organization_Id       => p_organization_id
                        , X_Revised_Item_Id       => p_revised_item_id
                        , X_New_Item_Revision     => l_item_rev
                        );

        END IF;
        x_change_notice := l_change_notice;
        x_revision := l_item_rev;
END Pending_High_Rev;

/******************************************************************************
* Added by MK on 08/26/2000
* Function      :  Get_High_Rtg_Rev_ECO (Local function)
* Parameters    : New Routing Revision
*                 Organization Id
*                 revised item id
* Returns       : ECO Name if the routing revision exists on revised item
******************************************************************************/

FUNCTION Get_High_Rtg_Rev_ECO
( p_organization_id      IN NUMBER
, p_revised_item_id      IN NUMBER
, p_new_routing_revision IN VARCHAR2)
RETURN VARCHAR2
IS

l_eco_name  VARCHAR2(10) ;

CURSOR l_change_notice_csr ( p_organization_id NUMBER
                           , p_revised_item_id NUMBER
                           , p_new_routing_revision VARCHAR2 )
IS
   SELECT change_notice
   FROM   ENG_REVISED_ITEMS
   WHERE  cancellation_date IS NULL
   AND implementation_date IS NULL -- Added for bug 3598711, Query to fetch un-implemented ECOs only.
   AND    revised_item_id   =  p_revised_item_id
   AND    new_routing_revision = p_new_routing_revision
   AND    organization_id      = p_organization_id ;

BEGIN

   OPEN l_change_notice_csr ( p_organization_id
                            , p_revised_item_id
                            , p_new_routing_revision );
   FETCH l_change_notice_csr INTO l_eco_name ;

   IF l_change_notice_csr%FOUND THEN
   	CLOSE l_change_notice_csr ;
       RETURN l_eco_name ;
   ELSE
   	CLOSE l_change_notice_csr ;
   RETURN NULL ;

   END IF ;

END Get_High_Rtg_Rev_ECO ;

/******************************************************************************
* Added by MK on 08/26/2000
* Function      : Pending_High_Rtg_Rev (Local function)
* Parameters    : Change Notice
*                 Organization Id
*                 revised item id
* Returns       : True if the highest routing revision exists on another ECO else False
* Purpose       : Checks if the (currently) highest un-implemented revision of
*                 the revised item exists on another ECO
******************************************************************************/
PROCEDURE Pending_High_Rtg_Rev
( p_change_notice               IN  VARCHAR2
, p_organization_id             IN  NUMBER
, p_revised_item_id             IN  NUMBER
, x_change_notice               OUT NOCOPY VARCHAR2
, x_revision                    OUT NOCOPY VARCHAR2
)
IS
        l_change_notice         VARCHAR2(10) := NULL;

        l_routing_rev      VARCHAR2(3) := NULL;

        CURSOR RTG_REV IS
               SELECT process_revision
                 FROM MTL_RTG_ITEM_REVISIONS
                WHERE inventory_item_id = p_revised_item_id
                  AND organization_id   = p_organization_id
             ORDER BY effectivity_date desc, process_revision desc;

BEGIN

        OPEN  RTG_REV;
        FETCH RTG_REV into l_routing_rev;
        CLOSE RTG_REV;

        IF l_routing_rev IS NOT NULL
        THEN
                l_change_notice :=
                        Get_High_Rtg_Rev_ECO
                        ( p_organization_id       => p_organization_id
                        , p_revised_item_id       => p_revised_item_id
                        , p_new_routing_revision  => l_routing_rev
                        );

        END IF;
        x_change_notice := l_change_notice;
        x_revision      := l_routing_rev;

END Pending_High_Rtg_Rev;




FUNCTION Validate_Use_Up_Plan
( p_use_up_plan_name IN VARCHAR2
, p_use_up_item_id IN NUMBER
, p_organization_id IN NUMBER
)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10) := NULL;
l_err_text      VARCHAR2(2000) := NULL;

CURSOR USE_UP_PLAN IS
    SELECT 'VALID'
    FROM   mrp_system_items
    WHERE  inventory_item_id = p_use_up_item_id
    AND    organization_id = p_organization_id
    AND    compile_designator = p_use_up_plan_name
    AND    inventory_use_up_date >= SYSDATE;

BEGIN
   OPEN USE_UP_PLAN;
   FETCH USE_UP_PLAN INTO l_dummy;
   CLOSE USE_UP_PLAN;

    IF p_use_up_item_id IS NOT NULL AND
       l_dummy IS NULL
    THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END Validate_Use_Up_Plan;

/******************************************************************************
* Function      : Get_Current_Item_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 Revision Date
* Returns       : VARCHAR2
* Purpose       : Function will return the current revision of the given revised
*                 item.
******************************************************************************/
FUNCTION Get_Current_Item_Revision
( p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_revision_date IN DATE
) RETURN VARCHAR2
IS
l_current_revision      VARCHAR2(3) := NULL;

CURSOR NO_ECO_ITEM_REV IS
       SELECT REVISION
       FROM   MTL_ITEM_REVISIONS
       WHERE  INVENTORY_ITEM_ID = p_revised_item_id
       AND    ORGANIZATION_ID = p_organization_id
       AND    EFFECTIVITY_DATE <= p_revision_date
       AND    IMPLEMENTATION_DATE IS NOT NULL
       ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;
BEGIN
   OPEN NO_ECO_ITEM_REV;
   FETCH NO_ECO_ITEM_REV INTO l_current_revision;
   CLOSE NO_ECO_ITEM_REV;

   RETURN l_current_revision;
END Get_Current_Item_Revision;


/*****************************************************************************
* Function      : Validate_New_Item_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 New Revised item Revision
*                 Revised item sequence Id
*                 Updated Revised item Revision
* Returns       : Number - 1 - if the revision is less than the current rev.
*                          2 - if the
*                          3 - if the
* Purpose       : Function will check if the new_revised_item_revision or the
*                 updated_revised_item_revision is not less than the current
*                 item revision. If it is then the function will return a
*                 value of 1. Else it will proceed to check if the revision
*                 is being created by another ECO and is still un-implemented
*                 If it finds this, then the function will return a value of 2.
*                 Else it will check if the revision exists in an implemented
*                 state. If it does exist then the function will return 3
*                 indicating that the revision already exists. If none of the
*                 conditions are true then the function returns a 0.
*
*                 11.5.10E
*                 If from PLM, the validation is done against the 'From Revision'
*                 instead of the current revision.
******************************************************************************/
FUNCTION Validate_New_Item_Revision
( p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_from_revision IN VARCHAR2
, p_new_item_revision IN VARCHAR2
, p_revised_item_sequence_id IN NUMBER
, x_change_notice OUT NOCOPY VARCHAR2
) RETURN NUMBER
IS
  l_Rev_Compare         NUMBER          := NULL;
  l_Change_Notice       VARCHAR2(10)    := NULL;
  l_Curr_Rev            VARCHAR2(4)     := NULL;
  l_Pending_Rev         NUMBER          := 0;
  l_rev_sequence        NUMBER;

  CURSOR c1 IS          SELECT change_notice
                          FROM MTL_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND revision = p_new_item_revision
                           AND revised_item_sequence_id <>
                                NVL(p_revised_item_sequence_id,
                                    revised_item_sequence_id+99)
                           AND implementation_date is null;

  CURSOR c2 IS          SELECT 1
                          FROM MTL_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND revision = p_new_item_revision
                           AND implementation_date is not null;
BEGIN

      -- verify revised item has a valid current revision

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Validating revised item revision . . .' ||
p_new_item_revision);
END IF;
      --11.5.10E
      --Commented out as From revision is being supported.
      /*l_Curr_Rev := Get_Current_Item_Revision
                    (  p_revised_item_id => p_revised_item_id
                     , p_organization_id => p_organization_id
                     , p_revision_date   => SYSDATE
                     );*/
      l_Curr_Rev := p_from_revision;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Current revision. . . ' || l_Curr_Rev); END IF;
      -- revision must be greater than the current revision

      l_Rev_Compare := BOM_REVISIONS.Compare_Revision(
                                rev1    => p_new_item_revision,
                                rev2    => l_Curr_Rev);
      IF l_Rev_Compare = 1 THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision not the latest . . .'); END IF;

        RETURN 1;
      END IF;

      -- check if revision has been created in another ECO

      OPEN c1;
      FETCH c1 INTO l_Change_Notice;
      CLOSE c1;
      IF l_Change_Notice IS NOT NULL
      THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision created thru another ECO . . .'); END IF;
        x_Change_Notice := l_Change_Notice;
        RETURN 2;
      END IF;

      -- check if this revision has already been implemented

      IF p_new_item_revision <> l_Curr_Rev THEN

        l_Pending_Rev := 0;
        FOR x_count IN c2 LOOP
          l_Pending_Rev := 1;
          RETURN 3;
        END LOOP;

      END IF;

      RETURN 0;

END Validate_New_Item_Revision;

-- Added for bug 3618662
/*****************************************************************************
* Function      : High_Date_Low_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 New Revised item Revision
*                 Scheduled Date
*                 Revised item sequence Id
* Returns       : Number - 1 - if the revision is invalid
*                          2 - if the revision is valid
* Purpose       : Function will check if the revisions and effectivity dates
*                 in ascending order. Return 1 if there exists an invalid combination.
*                 Return 2 otherwise.
******************************************************************************/
FUNCTION High_Date_Low_Revision (
    p_revised_item_id	IN NUMBER
  , p_organization_id	IN NUMBER
  , p_new_item_revision	IN VARCHAR2
  , p_scheduled_date	IN DATE
  , p_rev_item_seq_id	IN NUMBER
) RETURN NUMBER
IS

 CURSOR check_high_date_low_rev
 IS
 SELECT 1
 FROM mtl_item_revisions r
 WHERE r.inventory_item_id = p_revised_item_id
 AND   r.organization_id = p_organization_id
 AND   NVL(r.revised_item_sequence_id, -1) <> NVL(p_rev_item_seq_id, -2)
 AND ((r.effectivity_date >= p_scheduled_date and r.revision < p_new_item_revision)
   OR (r.effectivity_date <= p_scheduled_date and r.revision > p_new_item_revision)
     );

 l_is_revision_invalid NUMBER;

BEGIN
	l_is_revision_invalid := 2; -- Revision is not INVALID

	OPEN check_high_date_low_rev;
	FETCH check_high_date_low_rev INTO l_is_revision_invalid;
	CLOSE check_high_date_low_rev;

	RETURN l_is_revision_invalid;
END High_Date_Low_Revision;

-- 11.5.10E
/*****************************************************************************
* Function      : Scheduled_Date_From_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 From Item Revision
*                 Scheduled Date
*                 From Revision ID
*                 Revised item sequence Id
* Returns       : Number - 1 - if the schedule date is invalid
*                          2 - if the schedule date is valid
* Purpose       : Function will check if the scheduled date is valid for a revised
*                 item.
******************************************************************************/
FUNCTION Scheduled_Date_From_Revision (
    p_revised_item_id    IN NUMBER
  , p_organization_id    IN NUMBER
  , p_from_item_revision IN VARCHAR2
  , p_scheduled_date     IN DATE
  , p_rev_item_seq_id    IN NUMBER
) RETURN NUMBER
IS

 CURSOR sheduled_date_from_revision
 IS
 SELECT 1
 FROM mtl_item_revisions r
 WHERE r.inventory_item_id = p_revised_item_id
 AND   r.organization_id = p_organization_id
 AND   r.effectivity_date >= p_scheduled_date
 AND   r.revision = p_from_item_revision;

 l_is_scheduled_date_valid NUMBER;

BEGIN
  l_is_scheduled_date_valid := 2; -- Date is VALID

  OPEN sheduled_date_from_revision;
  FETCH sheduled_date_from_revision INTO l_is_scheduled_date_valid;
  CLOSE sheduled_date_from_revision;

  RETURN l_is_scheduled_date_valid;

  EXCEPTION
    WHEN OTHERS THEN
      IF sheduled_date_from_revision%ISOPEN
      THEN
        CLOSE sheduled_date_from_revision;
      END IF;
      RETURN l_is_scheduled_date_valid;

END Scheduled_Date_From_Revision;

-- Fix for bug 3311749
/*****************************************************************************
* Function      : Exp_Validate_New_Item_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 New Revised item Revision
*                 Revised item sequence Id
*                 Updated Revised item Revision
* Returns       : Number - 1 - if the revision is less than the current rev.
*                          2 - if the
*                          3 - if the
* Purpose       : Function will check if the new_revised_item_revision or the
*                 updated_revised_item_revision is not less than the current
*                 item revision. If it is then the function will return a
*                 value of 1. Else it will proceed to check if the revision
*                 is being created by another ECO and is still un-implemented
*                 If it finds this, then the function will return a value of 2.
*                 Else it will check if the revision exists in an implemented
*                 state. If it does exist then the function will return 3
*                 indicating that the revision already exists. If none of the
*                 conditions are true then the function returns a 0.
******************************************************************************/
FUNCTION Exp_Validate_New_Item_Revision
( p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_new_item_revision IN VARCHAR2
, p_revised_item_sequence_id IN NUMBER
, x_change_notice OUT NOCOPY VARCHAR2
) RETURN NUMBER
IS
  l_Rev_Compare         NUMBER          := NULL;
  l_Change_Notice       VARCHAR2(10)    := NULL;
  l_Curr_Rev            VARCHAR2(4)     := NULL;
  l_Pending_Rev         NUMBER          := 0;
  l_rev_sequence        NUMBER;

  CURSOR c1 IS          SELECT change_notice
                          FROM MTL_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND revision = p_new_item_revision
                           AND implementation_date is null;

  CURSOR c2 IS          SELECT 1
                          FROM MTL_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND revision = p_new_item_revision
                           AND implementation_date is not null;
BEGIN

      -- verify revised item has a valid current revision

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Validating revised item revision . . .' ||
p_new_item_revision);
END IF;
      l_Curr_Rev := Get_Current_Item_Revision
                    (  p_revised_item_id => p_revised_item_id
                     , p_organization_id => p_organization_id
                     , p_revision_date   => SYSDATE
                     );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Current revision. . . ' || l_Curr_Rev); END IF;
      -- revision must be greater than the current revision

      l_Rev_Compare := BOM_REVISIONS.Compare_Revision(
                                rev1    => p_new_item_revision,
                                rev2    => l_Curr_Rev);
      IF l_Rev_Compare = 1 THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision not the latest . . .'); END IF;

        RETURN 1;
      END IF;

      -- check if revision has been created in another ECO

      OPEN c1;
      FETCH c1 INTO l_Change_Notice;
      CLOSE c1;
      IF l_Change_Notice IS NOT NULL
      THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision created thru another ECO . . .'); END IF;
        x_Change_Notice := l_Change_Notice;
        RETURN 2;
      END IF;

      -- check if this revision has already been implemented

     -- IF p_new_item_revision <> l_Curr_Rev THEN

        l_Pending_Rev := 0;
        FOR x_count IN c2 LOOP
          l_Pending_Rev := 1;
          RETURN 3;
        END LOOP;

      -- END IF;

      RETURN 0;

END Exp_Validate_New_Item_Revision;




/******************************************************************************
* Function      : Get_Current_Rtg_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 Revision Date
* Returns       : VARCHAR2
* Purpose       : Function will return the current revision of the given revised
*                 item.
******************************************************************************/
FUNCTION Get_Current_Rtg_Revision
( p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_revision_date IN DATE
) RETURN VARCHAR2
IS
l_current_revision      VARCHAR2(3) := NULL;

CURSOR NO_ECO_ROUTING_REV IS
       SELECT process_revision
       FROM   MTL_RTG_ITEM_REVISIONS
       WHERE  INVENTORY_ITEM_ID  = p_revised_item_id
       AND    ORGANIZATION_ID    = p_organization_id
       AND    EFFECTIVITY_DATE   <= p_revision_date
       AND    IMPLEMENTATION_DATE IS NOT NULL
       ORDER BY EFFECTIVITY_DATE DESC, PROCESS_REVISION DESC;
BEGIN
   OPEN NO_ECO_ROUTING_REV;
   FETCH NO_ECO_ROUTING_REV INTO l_current_revision;

       -- Added by MK on 11/27/00
       IF NO_ECO_ROUTING_REV%NOTFOUND THEN
          SELECT mp.starting_revision
          INTO   l_current_revision
          FROM  MTL_PARAMETERS mp
          WHERE mp.organization_id = p_organization_id
          AND   NOT EXISTS( SELECT NULL
                            FROM MTL_RTG_ITEM_REVISIONS
                            WHERE implementation_date IS NOT NULL
                            AND   organization_id = p_organization_id
                            AND   inventory_item_id = p_revised_item_id
                           ) ;
       END IF ;

   CLOSE NO_ECO_ROUTING_REV;

   RETURN l_current_revision;
END Get_Current_Rtg_Revision;
-- Added by MK on 08/26/2000

/*****************************************************************************
* Added by MK on 08/26/2000
* Function      : Validate_New_Rtg_Revision
* Parameters IN : Revised Item ID
*                 Organization ID
*                 New Routing Revision
*                 Revised item sequence Id
* Returns       : Number - 1 - if the revision is less than the current rev.
*                          2 - if the
*                          3 - if the
* Purpose       : Function will check if the new_routing_revision or the updated
*                 _routing_revision is not less than the current routing revision.
*                 If it is then the function will return a value of 1.
*                 Else it will proceed to check if the revision is being created
*                 by another ECO and is still un-implemented.
*                 If it finds this, then the function will return a value of 2.
*                 Else it will check if the revision exists in an implemented
*                 state. If it does exist then the function will return 3
*                 indicating that the revision already exists. If none of the
*                 conditions are true then the function returns a 0.
******************************************************************************/
FUNCTION Validate_New_Rtg_Revision
( p_revised_item_id   IN NUMBER
, p_organization_id   IN NUMBER
, p_new_routing_revision IN VARCHAR2
, p_revised_item_sequence_id IN NUMBER
, x_change_notice OUT NOCOPY VARCHAR2
) RETURN NUMBER
IS
  l_Rev_Compare         NUMBER          := NULL;
  l_Change_Notice       VARCHAR2(10)    := NULL;
  l_Curr_Rev            VARCHAR2(4)     := NULL;
  l_Pending_Rev         NUMBER          := 0;
  l_rev_sequence        NUMBER;

  CURSOR c1 IS          SELECT change_notice
                          FROM MTL_RTG_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND process_revision = p_new_routing_revision
                           AND revised_item_sequence_id <>
                                NVL(p_revised_item_sequence_id,
                                    revised_item_sequence_id+99)
                           AND implementation_date is null;

  CURSOR c2 IS          SELECT 1
                          FROM MTL_RTG_ITEM_REVISIONS
                         WHERE inventory_item_id = p_revised_item_id
                           AND organization_id = p_organization_id
                           AND process_revision = p_new_routing_revision
                           AND implementation_date is not null;
BEGIN

      -- verify revised item has a valid current revision
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Validating routing revision . . .' ||
p_new_routing_revision);
END IF;
      l_Curr_Rev := Get_Current_Rtg_Revision
                    (  p_revised_item_id => p_revised_item_id
                     , p_organization_id => p_organization_id
                     , p_revision_date   => SYSDATE
                     );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Current revision. . . ' || l_Curr_Rev); END IF;
      -- revision must be greater than the current revision

      l_Rev_Compare := BOM_REVISIONS.Compare_Revision(
                                rev1    => p_new_routing_revision,
                                rev2    => l_Curr_Rev);
      IF l_Rev_Compare = 1 THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision not the latest . . .'); END IF;

        RETURN 1;
      END IF;

      -- check if revision has been created in another ECO

      OPEN c1;
      FETCH c1 INTO l_Change_Notice;
      CLOSE c1;
      IF l_Change_Notice IS NOT NULL
      THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision created thru another ECO . . .'); END IF;
        x_Change_Notice := l_Change_Notice;
        RETURN 2;
      END IF;

      -- check if this revision has already been implemented

      IF p_new_routing_revision <> l_Curr_Rev THEN

        l_Pending_Rev := 0;
        FOR x_count IN c2 LOOP
          l_Pending_Rev := 1;
          RETURN 3;
        END LOOP;

      END IF;

      RETURN 0;

END Validate_New_Rtg_Revision;
-- Added by MK on 08/26/2000


/*****************************************************************************
* Function      : Pending_ECO_Hint
* Parameters IN : Revised item ID
*                 Change Notice
* Returns       : True if the revised item is found pending on other ECO, False
*                 otherwise.
* Purpose       : Function will verify if the revised item is pending on any
*                 other ECO in the same organization.
******************************************************************************/
FUNCTION Pending_ECO_Hint(  p_change_notice     VARCHAR2
                          , p_revised_item_id   NUMBER
                          , p_organization_id   NUMBER
                         )
RETURN BOOLEAN
IS
        CURSOR c_CheckPendingECO
        IS SELECT 1
             FROM ENG_REVISED_ITEMS
            WHERE implementation_date IS NULL
              AND cancellation_date   IS NULL
              AND change_notice       <> p_change_notice
              AND revised_item_id      = p_revised_item_id
              AND organization_id      = p_organization_id;

BEGIN

  FOR CheckPendingECO IN c_CheckPendingECO LOOP
      RETURN TRUE;
  END LOOP;

  RETURN FALSE;

END Pending_ECO_Hint;

/*****************************************************************************
* Function      : Eng_Primary_Bill_Exists
* Parameters IN : Revised item Id
*                 Organization Id
* Returns       : True if the revised item has a Primary bill, False otherwise
* Purpose       : Verify if the given revised item has a primary bill
*                 associated with it. If yes then return a TRUE else return
*                 False.
******************************************************************************/
FUNCTION Eng_Primary_Bill_Exists(  p_Revised_Item_Id NUMBER
                                 , p_Organization_Id NUMBER
                                 , p_assembly_type   NUMBER)
RETURN BOOLEAN
IS
        l_Bill_Exists NUMBER := 0;
        CURSOR c_CheckPrimary IS
        SELECT bill_sequence_id
          FROM Bom_Bill_Of_Materials
         WHERE assembly_item_id = p_Revised_Item_Id
           AND organization_id  = p_Organization_Id
           AND alternate_bom_designator is null
           AND ((assembly_type = 1 and p_Assembly_Type = 1)
                        or p_Assembly_Type = 2);
BEGIN

        FOR l_Count in c_CheckPrimary LOOP
                RETURN TRUE;

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Check Primary Bill fuction, return True ' );
END IF;

        END LOOP;

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Check Primary Bill fuction, return False ' );
END IF;

        RETURN FALSE;

END Eng_Primary_Bill_Exists;



/*****************************************************************************
* Added by MK 08/26/2000
* Function      : Eng_Primary_Routing_Exists
* Parameters IN : Revised item Id
*                 Organization Id
* Returns       : True if the revised item has a Primary Routing, False otherwise
* Purpose       : Verify if the given revised item has a primary bill
*                 associated with it. If yes then return a TRUE else return
*                 False.
******************************************************************************/
FUNCTION Eng_Primary_Routing_Exists(  p_revised_item_id NUMBER
                                    , p_organization_id NUMBER
                                    , p_assembly_type   NUMBER)
RETURN BOOLEAN
IS
        l_rtg_exists    NUMBER := 0;

        CURSOR l_checkprimary IS
        SELECT routing_sequence_id
          FROM BOM_OPERATIONAL_ROUTINGS
         WHERE assembly_item_id =  p_revised_item_id
           AND organization_id  =  p_organization_id
           AND alternate_routing_designator IS NULL
           AND ( (routing_type = 1 and p_assembly_type = 1)
               OR p_assembly_type = 2 )  ;
BEGIN

        FOR l_check_primary_rec in l_checkprimary LOOP
            RETURN TRUE;

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Check Primary Routing fuction, return True ' );
END IF;
        END LOOP;


IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Check Primary Routing fuction, return False ' );
END IF;

        RETURN FALSE;

END Eng_Primary_Routing_Exists;
-- Added by MK 08/26/2000


-- Function Check_Reference_Common
-- Cannot delete revised item if another bill references it as a common bill

FUNCTION Check_Reference_Common
( p_change_notice       VARCHAR2
, p_bill_sequence_id    NUMBER
)RETURN NUMBER
IS
  l_count1                      NUMBER := 0;
  l_count2                      NUMBER := 0;
  cursor pending_on_eco is
                select 1
                  from BOM_BILL_OF_MATERIALS
                 where bill_sequence_id = p_bill_sequence_id
                   and pending_from_ecn is not null
                   and pending_from_ecn = p_change_notice;
  cursor reference_common is
                select 1
                  from BOM_BILL_OF_MATERIALS
                 where source_bill_sequence_id = p_bill_sequence_id -- R12: Common Bom
                   and source_bill_sequence_id <> bill_sequence_id;
BEGIN

  l_count1 := 0;

  for l_pending_on_eco in pending_on_eco loop
    l_count1 := 1;
  end loop;

  if l_count1 = 1
  then
    l_count2 := 0;

    for l_reference_common in reference_common loop
      l_count2 := 1;
    end loop;
  end if;

  return (l_count2);
END Check_Reference_Common;

/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
*********************************************************************/
-- Function Check_Reference_Rtg_Common
-- Cannot delete revised item if another Routing references it as a common routing

FUNCTION Check_Reference_Rtg_Common
( p_change_notice          VARCHAR2
, p_routing_sequence_id    NUMBER
)RETURN NUMBER
IS
  l_count1                      NUMBER := 0;
  l_count2                      NUMBER := 0;
  cursor pending_on_eco is
                select 1
                  from BOM_OPERATIONAL_ROUTINGS
                 where routing_sequence_id = p_routing_sequence_id
                   and pending_from_ecn is not null
                   and pending_from_ecn = p_change_notice;
  cursor reference_common is
                select 1
                  from BOM_OPERATIONAL_ROUTINGS
                 where common_routing_sequence_id = p_routing_sequence_id
                   and common_routing_sequence_id <> routing_sequence_id;
BEGIN

  l_count1 := 0;

  for l_pending_on_eco in pending_on_eco loop
    l_count1 := 1;
  end loop;

  if l_count1 = 1
  then
    l_count2 := 0;

    for l_reference_common in reference_common loop
      l_count2 := 1;
    end loop;
  end if;

  return (l_count2);
END Check_Reference_Rtg_Common;
-- Added by MK on 08/26/2000


-- Function Check_Common
-- Checks if the bill is referencing another bill as a common bill

FUNCTION Check_Common
( p_bill_sequence_id    IN NUMBER
)RETURN BOOLEAN
IS
l_dummy         NUMBER;
cursor common_exists is select common_assembly_item_id
                          from BOM_BILL_OF_MATERIALS
                         where bill_sequence_id = p_bill_sequence_id
                           and bill_sequence_id <> source_bill_sequence_id; --R12
BEGIN
  open common_exists;
  fetch common_exists into l_dummy;
  close common_exists;

  IF l_dummy IS NULL
  THEN
    return FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END Check_Common;

/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
*********************************************************************/
-- Function Check Rtg_Common
-- Checks if the routing is referencing another routing as a common routing

FUNCTION Check_Rtg_Common
( p_routing_sequence_id    IN NUMBER
)RETURN BOOLEAN
IS
l_dummy         NUMBER;
cursor common_exists is select 'Referencing'
                          from BOM_OPERATIONAL_ROUTINGS
                         where routing_sequence_id = p_routing_sequence_id
                           and routing_sequence_id <> common_routing_sequence_id;
BEGIN
  open common_exists;
  fetch common_exists into l_dummy;
  close common_exists;

  IF l_dummy IS NULL
  THEN
    return FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END Check_Rtg_Common;


/******************************************************************************
* Function      : ECO_Approval_Requested
* Parameters IN : Change Notice
*                 Organization ID
* Returns       : True or False
* Purpose       : Function will verify if the change notice has an approval
*                 status of "Approval Requested". If it does then the procedure
*                 will return True else it will return False.
******************************************************************************/
FUNCTION ECO_Approval_Requested
( p_change_notice       IN VARCHAR2
, p_organization_id     IN NUMBER
)RETURN BOOLEAN
IS
  l_ret                         BOOLEAN := FALSE;

  CURSOR check_ECO IS
                SELECT 1
                  FROM ENG_ENGINEERING_CHANGES
                 WHERE change_notice = p_change_notice
                   AND organization_id = p_organization_id
                   AND approval_status_type = 3;
BEGIN
  for l_approval_requested IN check_ECO loop
    l_ret := TRUE;
  end loop;

  RETURN l_ret;
END ECO_Approval_Requested;

FUNCTION ECO_Is_Approval_Route_Type
( p_change_notice       IN VARCHAR2
, p_organization_id     IN NUMBER
)RETURN BOOLEAN
IS
  l_ret                         BOOLEAN := FALSE;
  l_change_id                   NUMBER;
  l_route_type_code             VARCHAR2(30);

  CURSOR get_change_id IS
                SELECT CHANGE_ID
		FROM ENG_ENGINEERING_CHANGES
		WHERE CHANGE_NOTICE = p_change_notice
		AND ORGANIZATION_ID = p_organization_id;

  CURSOR check_eco_route_type(p_change_id NUMBER) IS
                SELECT ecr.ROUTE_TYPE_CODE
                FROM ENG_ENGINEERING_CHANGES eec,
                     ENG_LIFECYCLE_STATUSES els,
                     ENG_CHANGE_ROUTES ecr
                WHERE eec.CHANGE_ID = p_change_id
                AND els.ENTITY_NAME(+) = 'ENG_CHANGE'
                AND els.ENTITY_ID1(+) = eec.CHANGE_ID
                AND els.STATUS_CODE(+) = eec.STATUS_CODE
                AND els.ACTIVE_FLAG(+) = 'Y'
                AND ecr.OBJECT_NAME(+) = 'ENG_CHANGE'
                AND ecr.OBJECT_ID1(+) = p_change_id
                AND ecr.ROUTE_ID(+) = els.CHANGE_WF_ROUTE_ID;
BEGIN
  OPEN get_change_id;
  FETCH get_change_id INTO l_change_id;
  CLOSE get_change_id;

  IF l_change_id IS NOT NULL THEN
    OPEN check_eco_route_type(p_change_id => l_change_id);
    FETCH check_eco_route_type INTO l_route_type_code;
    CLOSE check_eco_route_type;

    IF (l_route_type_code IS NOT NULL AND l_route_type_code = 'APPROVAL') THEN
      l_ret := TRUE;
    END IF;
  END IF;

  RETURN l_ret;
EXCEPTION
  WHEN OTHERS THEN
    IF get_change_id%ISOPEN THEN
      CLOSE get_change_id;
    END IF;
    IF check_eco_route_type%ISOPEN THEN
      CLOSE check_eco_route_type;
    END IF;

    RETURN l_ret;
END ECO_Is_Approval_Route_Type;

/*****************************************************************************
* Function      : ECO_Open
* Parameters IN : Change Notice
*                 Organization ID
* Returns       : True or False
* Purpose       : Function will check if the ECO status is Open. If the status
*                 is Open, then the function will return TRUE otherwise FALSE.
******************************************************************************/
FUNCTION ECO_Open
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
)RETURN BOOLEAN
IS
  l_ret                         BOOLEAN := FALSE;

  CURSOR check_ECO  IS
                SELECT 1
                  FROM ENG_ENGINEERING_CHANGES
                 WHERE change_notice = p_change_notice
                   AND organization_id = p_organization_id
                   AND status_type = 1;
BEGIN
  FOR l_open IN check_ECO LOOP
    l_ret := TRUE;
  END LOOP;

  RETURN l_ret;
END ECO_Open;



/****************************************************************************
* Added by MK on 08/26/2000
* Function      : Check_Rtg_Reschedule
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record.
* Returns       : BOOLEAN
*                 If the ECO has date that is greater than the disable
*                 date of the any of the revised operations, return False.
* Purpose       : Function will check if the new effective date is greater
*                 than the disable date of any operations on that revised item
*                 and this change notice. If there are any such components then
*                 the function will return FALSE  and the revised item will
*                 not be rescheduled.
******************************************************************************/

FUNCTION Check_Rtg_Reschedule
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_item_unexposed_rec_type
)RETURN BOOLEAN
IS

    l_ret_status BOOLEAN := TRUE ;

    CURSOR rtg_reschedule_valid
    IS
        SELECT 'Invalid Op Seq Exists'
        FROM   SYS.DUAL
        WHERE  EXISTS     ( SELECT 'X'
                            FROM BOM_OPERATION_SEQUENCES
                            WHERE change_notice = p_revised_item_rec.eco_name
                            AND routing_sequence_id = p_rev_item_unexp_rec.routing_sequence_id
                            AND revised_item_sequence_id =
                                                    p_rev_item_unexp_rec.Revised_Item_Sequence_Id
                            AND nvl(disable_date, p_revised_item_rec.new_effective_date+ 1)
                                        <= p_revised_item_rec.new_effective_date ) ;
BEGIN
    FOR Is_Resched_Valid IN rtg_reschedule_valid
    LOOP
        -- Before returning result, set G_SCHED_DATE_CHANGED. Database
        -- writes to ENG_CURRENT_SCHEDULED_DATES in Eng_Revised_Item_Util
        -- happen based on this flag.

        Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED := FALSE;
        l_ret_status := FALSE ;
    END LOOP ;

        RETURN l_ret_status ;


END Check_Rtg_Reschedule ;
-- Added by MK on 08/26/2000


/****************************************************************************
* Function      : Check_Reschedule
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record.
* Returns       : NUMBER
*                 1 - If the ECO  is Approval Requested
*                 2 - If the ECO  has date that is greater than the disable
*                     date of the any of the revised components.
*                 3 - If the ECO has date that is greater than the disable
*                     date of the any of the revised operations.
*                     Added by MK on 08/26/2000
*
* Purpose       : Function will check if the new effective date is greater
*                 than the disable date of any components on that revised item
*                 and this change notice. If there are any such components then
*                 the function will return a 2 and the revised item will
*                 not be rescheduled otherwise it will check if the ECO has
*                 approval requested, if yes even then the revised item cannot
*                 be rescheduled. If none of these conitions are satisfied then
*                 the function return True and the revised item can be re-
*                 scheduled.
******************************************************************************/
FUNCTION Check_Reschedule
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_item_unexposed_rec_type
)RETURN NUMBER
IS
  l_count1                      NUMBER  := 0;
  l_count2                      NUMBER  := NULL;
  CURSOR reschedule_valid IS
                SELECT 1
                  FROM BOM_INVENTORY_COMPONENTS
                 WHERE change_notice = p_revised_item_rec.eco_name
                   AND bill_sequence_id = p_rev_item_unexp_rec.Bill_Sequence_Id
                   AND revised_item_sequence_id =
                        p_rev_item_unexp_rec.Revised_Item_Sequence_Id
                   AND nvl(disable_date,
                           p_revised_item_rec.new_effective_date+ 1)
                        <= p_revised_item_rec.new_effective_date
                   AND acd_type in (1,2);



BEGIN
        l_count1 := 0;
        for Is_Resched_Valid in reschedule_valid loop
                l_count1 := 1;
        end loop;

        -- Before returning result, set G_SCHED_DATE_CHANGED. Database
        -- writes to ENG_CURRENT_SCHEDULED_DATES in Eng_Revised_Item_Util
        -- happen based on this flag.
        -- By AS on 10/12/99

        IF l_count1 <> 0
        THEN
                Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED := FALSE;
                return 2;
        ELSIF ECO_Approval_Requested
              (  p_change_notice => p_revised_item_rec.eco_name
               , p_organization_id => p_rev_item_unexp_rec.organization_id
               ) = TRUE
        THEN
                IF ECO_Is_Approval_Route_Type
                (  p_change_notice => p_revised_item_rec.eco_name
                 , p_organization_id => p_rev_item_unexp_rec.organization_id
                 ) = TRUE
		THEN
                  Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED := FALSE;
                  RETURN 1;
		ELSE
                  Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED := TRUE;
                  RETURN 0;
		END IF;
        ELSE
                Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED := TRUE;
                RETURN 0;
        END IF;

END Check_Reschedule;

/****************************************************************************
* Function      : Check_Date
* Parameters IN : Revised item id
*                 organization id
*                 Plan Name
*                 Schedule date or the new schedule date
* Returns       : True on Success, False otherwise
* Purpose       : Function will check if the schedule date of the revised item
*                 matches with the inventory_use_up_date of the plan. If it
*                 does then the function will return with True otherwise False.
*****************************************************************************/
FUNCTION Check_Date(  p_revised_item_id IN  NUMBER
                    , p_organization_id IN  NUMBER
                    , p_use_up_plan     IN  VARCHAR2
                    , p_schedule_date   IN  DATE
                    , x_inventory_use_up_date   OUT NOCOPY DATE
                    )
RETURN BOOLEAN
IS
        CURSOR c_CheckUseUpDate IS
                SELECT inventory_use_up_date
                  FROM mrp_system_items
                 WHERE inventory_use_up_date = p_schedule_date
                   AND inventory_item_id     = p_revised_item_id
                   AND organization_id       = p_organization_id
                   AND compile_designator    = p_use_up_plan;
BEGIN
        FOR CheckUseUpDate IN c_CheckUseUpDate LOOP
                x_inventory_use_up_date := CheckUseUpDate.inventory_use_up_date;
                RETURN TRUE;
        END LOOP;

        x_inventory_use_up_date := SYSDATE;
        RETURN FALSE;

END Check_Date;




/*****************************************************************************
* Added by MK on 12/01/2000
* Function      : Val_Rev_Item_for_Rtg
* Parameters IN : Revised item Id
*                 Organization Id
* Returns       : True if the revised item can be on Routing.
* Purpose       : Verify if the given revised item is not planning item, pto item
*                 and its attribute: Bom allowed is true.
******************************************************************************/
FUNCTION Val_Rev_Item_for_Rtg
                          ( p_revised_item_id   NUMBER
                          , p_organization_id   NUMBER  )
RETURN BOOLEAN
IS
    l_PLANNING          CONSTANT NUMBER := 3 ;

    -- Get Revised Item Attr. Value
    CURSOR   l_item_cur (p_org_id NUMBER, p_item_id NUMBER) IS
       SELECT   bom_item_type
              , pick_components_flag
              , bom_enabled_flag
              , eng_item_flag
       FROM  MTL_SYSTEM_ITEMS
       WHERE (  bom_enabled_flag <> 'Y'
             OR pick_components_flag <> 'N'
             OR bom_item_type = l_PLANNING )
       AND   organization_id   = p_org_id
       AND   inventory_item_id = p_item_id
       ;

BEGIN

       -- First Query all the attributes for the Assembly item used Entity Validation
       FOR l_item_rec IN l_item_cur(  p_org_id  => p_organization_id
                                    , p_item_id => p_revised_item_id
                                    )
       LOOP
           RETURN FALSE;
       END LOOP ;

           RETURN TRUE;

END Val_Rev_Item_for_Rtg ;
-- Added by MK 12/01/2000


/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
-- Check CTP Flag:Yes is Unique
*********************************************************************/
FUNCTION Check_CTP_Flag (  p_revised_item_id  	 IN  NUMBER
                         , p_organization_id  	 IN  NUMBER
                         , p_cfm_routing_flag    IN  NUMBER
			 , p_routing_sequence_id IN NUMBER)
RETURN BOOLEAN
IS

     CURSOR l_ctp_csr    (  p_revised_item_id  NUMBER
                          , p_organization_id  NUMBER
                          , p_cfm_routing_flag NUMBER
			  , p_routing_sequence_id NUMBER)

     IS
         SELECT 'CTP not unique'
         FROM   SYS.DUAL
         WHERE  EXISTS  (SELECT NULL
                         FROM   BOM_OPERATIONAL_ROUTINGS
                         WHERE  ctp_flag = 1 -- Yes
                         AND    NVL(cfm_routing_flag, 2)  = NVL(p_cfm_routing_flag, 2)
                         AND    organization_id = p_organization_id
                         AND    assembly_item_id = p_revised_item_id
			 AND    routing_sequence_id <> p_routing_sequence_id) ;

l_ret_status BOOLEAN := TRUE ;

BEGIN
    FOR l_ctp_rec IN l_ctp_csr (  p_revised_item_id
                                , p_organization_id
                                , p_cfm_routing_flag
				, p_routing_sequence_id)
    LOOP
        l_ret_status := FALSE ;
    END LOOP ;
        RETURN l_ret_status ;

END Check_CTP_Flag ;
-- Added by MK on 08/26/2000


/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
-- Check if Priority is unique
*********************************************************************/
FUNCTION Check_Priority (  p_revised_item_id  IN  NUMBER
                         , p_organization_id  IN  NUMBER
                         , p_cfm_routing_flag IN  NUMBER
                         , p_priority         IN  NUMBER )
RETURN BOOLEAN
IS

     CURSOR l_priority_csr   (  p_revised_item_id  NUMBER
                              , p_organization_id  NUMBER
                              , p_cfm_routing_flag NUMBER
                              , p_priority         NUMBER )

     IS
         SELECT 'Priority not unique'
         FROM   SYS.DUAL
         WHERE  EXISTS  (SELECT NULL
                         FROM   BOM_OPERATIONAL_ROUTINGS
                         WHERE  priority = p_priority
                         AND    NVL(cfm_routing_flag, 2)  = NVL(p_cfm_routing_flag, 2)
                         AND    organization_id = p_organization_id
                         AND    assembly_item_id = p_revised_item_id) ;

l_ret_status BOOLEAN := TRUE ;

BEGIN

    FOR l_priority_rec  IN l_priority_csr (  p_revised_item_id
                                           , p_organization_id
                                           , p_cfm_routing_flag
                                           , p_priority         )
    LOOP
        l_ret_status := FALSE ;
    END LOOP ;
        RETURN l_ret_status ;

END Check_Priority ;
-- Added by MK on 08/26/2000


/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
-- Check if Subinventory Exists
*********************************************************************/
FUNCTION Check_SubInv_Exists(  p_organization_id  IN  NUMBER
                             , p_subinventory     IN VARCHAR2 )
RETURN BOOLEAN
IS

   -- cursor for checking subinventory exsiting
   CURSOR l_subinv_csr         ( p_organization_id NUMBER
                               , p_subinventory    VARCHAR2)
   IS
      SELECT 'SubInv exists'
      FROM   SYS.DUAL
      WHERE  NOT EXISTS ( SELECT  null
                          FROM mtl_secondary_inventories
                          WHERE organization_id =  p_organization_id
                          AND secondary_inventory_name = p_subinventory
                         );


l_ret_status BOOLEAN := TRUE ;

BEGIN

    FOR l_subinv_rec  IN l_subinv_csr  ( p_organization_id
                                       , p_subinventory )
    LOOP
        l_ret_status := FALSE ;
    END LOOP ;
        RETURN l_ret_status ;

END Check_SubInv_Exists ;
-- Added by MK on 08/26/2000


/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
--  Get Restrict Subinventory Flag and Inventory Asset Flag for the Item
*********************************************************************/
PROCEDURE Get_SubInv_Flag (    p_revised_item_id   IN  NUMBER
                              , p_organization_id  IN  NUMBER
                              , x_rest_subinv_code OUT NOCOPY VARCHAR2
                              , x_inv_asset_flag   OUT NOCOPY VARCHAR2 )
IS

   -- cursor for checking subinventory exsiting
   CURSOR l_subinv_flag_csr  ( p_organization_id NUMBER
                             , p_revised_item_id NUMBER)
   IS
       SELECT   DECODE(restrict_subinventories_code, 1, 'Y', 'N') restrict_code
              , inventory_asset_flag
       FROM   MTL_SYSTEM_ITEMS
       WHERE  inventory_item_id = p_revised_item_id
       AND    organization_id  = p_organization_id  ;


BEGIN

    FOR l_subinv_flag_rec  IN l_subinv_flag_csr  ( p_organization_id
                                                 , p_revised_item_id)
    LOOP
        x_rest_subinv_code := l_subinv_flag_rec.restrict_code ;
        x_inv_asset_flag   := l_subinv_flag_rec.inventory_asset_flag ;
    END LOOP ;

END Get_SubInv_Flag ;
-- Added by MK on 08/26/2000



/*********************************************************************
-- Added by MK on 08/26/2000
-- Enhancements for ECO Routing
-- Check Locator
*********************************************************************/

-- Local function to verify locators
FUNCTION Check_Locators (  p_organization_id  IN NUMBER
                         , p_revised_item_id  IN NUMBEr
                         , p_locator_id       IN NUMBER
                         , p_subinventory     IN VARCHAR2 )
RETURN BOOLEAN
IS
    Cursor CheckDuplicate is
    SELECT 'checking for duplicates' dummy
    FROM sys.dual
    WHERE EXISTS (
                   SELECT null
                   FROM mtl_item_locations
                   WHERE organization_id = p_organization_id
                   AND   inventory_location_id = p_locator_id
                   AND subinventory_code <>  p_subinventory
                  );

    x_control   NUMBER;
    l_success   BOOLEAN;
    l_dummy     VARCHAR2(20) ;

BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check Locators. . .Locator Id is ' || to_char(p_locator_id));
END IF;

   l_org_locator_control := 0 ;
   l_item_locator_control := 0;


   -- Get Value of Org_Locator and item_Locator.
   SELECT stock_locator_control_code
   INTO l_org_locator_control
   FROM mtl_parameters
   WHERE organization_id = p_organization_id;

   -- Get Value of Item Locator
   SELECT location_control_code
   INTO l_item_locator_control
   FROM mtl_system_items
   WHERE organization_id = p_organization_id
   AND inventory_item_id = p_revised_item_id;

   -- Get if locator is restricted or unrestricted
   SELECT RESTRICT_LOCATORS_CODE
   INTO l_item_loc_restricted
   FROM mtl_system_items
   WHERE organization_id = p_organization_id
   AND inventory_item_id = p_revised_item_id;


IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Org - Stock Locator Control : '|| to_char(l_org_locator_control)  );
    Error_Handler.Write_Debug('Item - Location Control : '|| to_char(l_item_locator_control)  );
    Error_Handler.Write_Debug('Item - Restrict Locator : '|| to_char(l_item_loc_restricted)  );
END IF;

/**************************************
-- Locator_Control_Code
-- 1 : No Locator Control
-- 2 : Prespecified Locator Control
-- 3 : Dynamic Entiry Locator Control
-- 4 : Determined by Sub Inv Level
-- 5 : Determined at Item Level
***************************************/

/*
   --
   -- Locator cannot be NULL is if locator restricted
   --
   IF p_locator_id IS NULL
   AND l_item_loc_restricted = 1
   THEN
       l_locator_control := 4;
       RETURN FALSE;
   ELSIF p_locator_id IS NULL
   AND l_item_loc_restricted = 2
   THEN
       RETURN TRUE;
   END IF;
*/

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Sub Inv - Loc Control : '|| to_char(l_sub_locator_control)  );
END IF;



   IF l_org_locator_control  is not null AND
      l_sub_locator_control  is not null AND
      l_item_locator_control is not null
   THEN
         --   dbms_output.put_line
         --   ('Org _Control: ' || to_char(l_org_locator_control));
         --    dbms_output.put_line('Sub _Control: ' ||
         --    to_char(l_sub_locator_control));
         --    dbms_output.put_line('Item Control: ' ||
         --    to_char(l_item_locator_control));


       x_control := BOM_Validate_Rtg_Header.Control
       (  Org_Control  => l_org_locator_control,
          Sub_Control  => l_sub_locator_control,
          Item_Control => l_item_locator_control
       );

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Calling BOM_Validate_Rtg_Header.Control. Loc Control '||
                              to_char(x_control)  );
END IF;

       l_locator_control := x_control;
       -- Variable to identify if the dynamic loc.
       -- Message must be logged.

       IF x_Control = 1  AND p_locator_id IS NOT  NULL  THEN  -- No Locator Control
         RETURN FALSE;
     /* - Validating this condition after checking  x_Control for 2 and 3-- for bug 16069406
	 ELSIF   p_locator_id IS  NULL  THEN   -- Moved this ELSIF after checking for x_Control = 2 OR x_Control = 3
	 RETURN TRUE;  -- No Locator and Locator Id is
                              -- supplied then raise Error */
       ELSIF x_Control = 2 OR x_Control = 3 THEN   -- PRESPECIFIED or DYNAMIC
	   -- Added OR x_Control = 3 as part of fix for bug 16069406 for dynamic locators
	   -- Clubbing prespecified and dynamic checking logic to sink ENG code with existing BOM API code (BOMLRTGB.pls) BUG# 3761854.
          BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Checking when x_control returned 2 and ' ||
                                ' item locator is ' ||
                                to_char(l_item_locator_control));
END IF;
--bug 2463393 modified the above check
            --
            -- Locator cannot be NULL is if locator control is prespecified
            --
            IF p_locator_id IS NULL
            AND p_subinventory is NOT NULL
            THEN
                l_locator_control := 4;
                RETURN FALSE;
            END IF;

-- If restrict locators is Y then check in
-- mtl_secondary_locators if the item is
-- assigned to the subinventory/location
-- combination If restrict locators is N then
-- check that the locator exists
-- and is assigned to the subinventory and this
-- combination is found in mtl_item_locations.

            IF l_item_loc_restricted = 1 -- Restrict Locators  = YES
            THEN
                -- Check for restrict Locators YES
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Before Checking for restrict Locators Yes. ' );
END IF;
                SELECT 'Valid'
                INTO l_dummy
                FROM mtl_item_locations mil,
                     mtl_secondary_locators msl
                WHERE msl.inventory_item_id = p_revised_item_id
                AND msl.organization_id     = p_organization_id
                AND msl.subinventory_code   = p_subinventory
                AND msl.secondary_locator   = p_locator_id
                AND mil.inventory_location_id = msl.secondary_locator
                AND mil.organization_id     =   msl.organization_id
                AND NVL(mil.disable_date, SYSDATE+1) > SYSDATE ;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Restrict locators is Y . ' ||
                                'Sub Inv :  ' || p_subinventory || 'Comp Loc : ' || to_char(p_locator_id )
                                || ' are valid.'  );
END IF;

                -- If no exception is raised then the
                -- Locator is Valid
                RETURN TRUE;

            ELSE
                -- Check for restrict Locators NO

                SELECT 'Valid'
                INTO l_dummy
                FROM mtl_item_locations mil
                WHERE mil.subinventory_code = p_subinventory
                AND   mil.inventory_location_id = p_locator_id
                AND    mil.organization_id      = p_organization_id
                AND NVL(mil.DISABLE_DATE, SYSDATE+1) > SYSDATE;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Restrict locators is No . ' ||
                                'Sub Inv :  ' || p_subinventory || 'Comp Loc : ' || to_char(p_locator_id )
                                || ' are valid.'  );
END IF;

                -- If no exception is raised then the
                -- Locator is Valid
                RETURN TRUE;

            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Locator is invlaid . ' );
END IF ;

               RETURN FALSE;
         END; -- x_control=2 Ends
   /* Commented Else condition as part of fix for bug 16069406
   -- commenting the code already done in BOM API code (BOMLRTGB.pls) via bug#3761854
      ELSIF x_Control = 3 THEN
         -- DYNAMIC LOCATORS ARE NOT ALLOWED IN OI.
         -- Dynamic locators are not allowed in open
         -- interface, so raise an error if the locator
         -- control is dynamic.
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Dynamic Locator Control. ' ) ;
END IF ;
         l_locator_control := 3;


         RETURN FALSE; */
	  ELSIF p_locator_id IS NULL THEN
       RETURN TRUE; -- No Locator and Locator Id is
      -- supplied then raise Error
      ELSE
         -- dbms_output.put_line
         -- ('Finally returing a true value . . .');
         RETURN TRUE;

      END IF; -- X_control Checking Ends

   ELSE
      RETURN TRUE;
   END IF;  -- If Locator Control check Ends.

END Check_Locators;
-- Added by MK on 08/26/2000


--
-- Function Check_RevItem_BillAlternate
-- Called from Check_Access
--
-- This fuction moved from Rev Comp(Check_Access) to resolove ECO dependency
-- by MK on 12/03/00
FUNCTION Check_RevItem_BillAlternate(  p_revised_item_id         IN  NUMBER
                                     , p_organization_id         IN  NUMBER
                                     , p_change_notice           IN  VARCHAR2
                                     , p_new_item_revision       IN  VARCHAR2
                                     , p_new_routing_revsion     IN  VARCHAR2
                                     , p_effective_date          IN  DATE
                                     , p_from_end_item_number    IN  VARCHAR2
                                     )
RETURN BOOLEAN
IS

                l_return_status BOOLEAN ;

                CURSOR c_CheckPrimary    (  p_revied_item_id   NUMBER
                                          , p_organization_id  NUMBER)
                IS

                    SELECT 1
                    FROM bom_bill_of_materials
                    WHERE assembly_item_id = p_revied_item_id
                    AND   organization_id    = p_organization_id
                    AND   NVL(alternate_bom_designator, 'NONE') = 'NONE';

                CURSOR c_Alternate_Check    (  p_revised_item_id         NUMBER
                                             , p_organization_id         NUMBER
                                             , p_change_notice           VARCHAR2
                                             , p_new_item_revision       VARCHAR2
                                             , p_new_routing_revsion     VARCHAR2
                                             , p_from_end_item_number    VARCHAR2
                                             , p_effective_date          DATE
                                             )
                IS

                    SELECT   'Rev Item is only Eco for altenate routing'
                    FROM     ENG_REVISED_ITEMS  eri
                          ,  BOM_OPERATIONAL_ROUTINGS bor
                    WHERE    bor.alternate_routing_designator  IS NOT NULL
                    AND      eri.routing_sequence_id         =   bor.routing_sequence_id(+)
                    AND      eri.routing_sequence_id        IS NOT NULL
                    AND      eri.bill_sequence_id           IS NULL
                    AND      NVL(eri.from_end_item_unit_number,FND_API.G_MISS_CHAR)
                                                   = NVL(p_from_end_item_number,FND_API.G_MISS_CHAR )
                    AND      NVL(eri.new_item_revision,FND_API.G_MISS_CHAR)
                                                   = NVL(p_new_item_revision ,FND_API.G_MISS_CHAR)
                    AND      NVL(eri.new_routing_revision,FND_API.G_MISS_CHAR)
                                                   = NVL(p_new_routing_revsion,FND_API.G_MISS_CHAR)
                    AND      TRUNC(eri.scheduled_date)      = TRUNC(p_effective_date)
                    AND      eri.change_notice              = p_change_notice
                    AND      eri.organization_id            = p_organization_id
                    AND      eri.revised_item_id            = p_revised_item_id ;


BEGIN

                FOR CheckPrimary IN c_CheckPrimary(p_revised_item_id, p_organization_id)
                LOOP
                        RETURN TRUE ;
                END LOOP;


                FOR CheckRevAlt IN c_Alternate_Check
                                   (  p_revised_item_id
                                    , p_organization_id
                                    , p_change_notice
                                    , p_new_item_revision
                                    , p_new_routing_revsion
                                    , p_from_end_item_number
                                    , p_effective_date
                                    )
                LOOP
                        RETURN FALSE ;
                END LOOP;



                -- If the loop does not execute then
                -- return True`

                RETURN TRUE ;

END Check_RevItem_BillAlternate ;

-- Bug 4210718
/*****************************************************************************
* Procedure      : Get_Structure_Type
* Parameters IN  : p_inventory_item_id => Revised item
*                  p_organization_id => Organization Id
*                  p_alternate_bom_code => Alternate_Bom_Designator
* Parameters OUT : x_structure_type_id => Structure Type Id of the bill/alternate
* Purpose        : Fetches the bill's/alternate's structure type.
*******************************************************************************/
PROCEDURE Get_Structure_Type
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
, p_alternate_bom_code  IN VARCHAR2
, x_structure_type_id   OUT NOCOPY NUMBER
) IS
  CURSOR get_bill_structure_type IS
  SELECT structure_type_id
  FROM bom_structures_b
  WHERE assembly_item_id = p_inventory_item_id
  AND organization_id = p_organization_id
  AND ((alternate_bom_designator IS NULL AND p_alternate_bom_code IS NULL)
      OR (p_alternate_bom_code IS NOT NULL AND alternate_bom_designator = p_alternate_bom_code));

  CURSOR get_alt_structure_type IS
  SELECT bad.structure_type_id
  FROM bom_alternate_designators bad
  WHERE ((p_alternate_bom_code IS NULL AND bad.alternate_designator_code IS NULL AND bad.organization_id = -1)
        OR (p_alternate_bom_code IS NOT NULL AND bad.alternate_designator_code = p_alternate_bom_code
            AND bad.organization_id = p_organization_id));

BEGIN
    IF x_structure_type_id IS NULL
    THEN
      OPEN get_bill_structure_type;
      FETCH get_bill_structure_type INTO x_structure_type_id ;
      CLOSE get_bill_structure_type;
      IF x_structure_type_id IS NULL
      THEN
        OPEN get_alt_structure_type;
        FETCH get_alt_structure_type INTO x_structure_type_id ;
        CLOSE get_alt_structure_type;
      END IF;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    IF get_bill_structure_type%ISOPEN THEN
       CLOSE get_bill_structure_type;
    END IF;
    IF get_alt_structure_type%ISOPEN THEN
       CLOSE get_alt_structure_type;
    END IF;
END Get_Structure_Type;

-- Bug 4210718
/*****************************************************************************
* Procedure      : Check_Structure_Type_Policy
* Parameters IN  : p_inventory_item_id => Revised item
*                  p_organization_id => Organization Id
*                  p_alternate_bom_code => Alternate_Bom_Designator
* Parameters OUT : x_structure_type_id => Structure Type Id of the bill/alternate
*                  x_strc_cp_not_allowed => 1 if change policy is not allowed
*                                              , 2 otherwise
* Purpose        : To check if the a bill for given revised item with the given
*                  alternate designator has structure policy NOT_ALLOWED
*                  associated with its structure type.
*******************************************************************************/
PROCEDURE Check_Structure_Type_Policy
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
, p_alternate_bom_code  IN VARCHAR2
, x_structure_type_id   OUT NOCOPY NUMBER
, x_strc_cp_not_allowed OUT NOCOPY NUMBER
) IS

  l_rev_policy  VARCHAR2(30);
BEGIN
    Get_Structure_Type(p_inventory_item_id, p_organization_id, p_alternate_bom_code, x_structure_type_id);
    x_strc_cp_not_allowed := 2;

    l_rev_policy := BOM_GLOBALS.Get_Change_Policy_Val (p_item_id => p_inventory_item_id,
                                                       p_org_id => p_organization_id,
                                                       p_rev_id => NULL,
                                                       p_rev_date => sysdate,
                                                       p_structure_type_id => x_structure_type_id);
    IF l_rev_policy = 'NOT_ALLOWED'
    THEN
      x_strc_cp_not_allowed := 1;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_strc_cp_not_allowed := 2;
END Check_Structure_Type_Policy;
--
-- Function Check_RevItem_BillAlternate
-- Called from Check_Access
--
-- This fuction moved from Rev Op(Check_Access) to resolove ECO dependency
-- by MK on 12/03/00
--
FUNCTION Check_RevItem_RtgAlternate    (  p_revised_item_id         IN  NUMBER
                                         , p_organization_id         IN  NUMBER
                                         , p_change_notice           IN  VARCHAR2
                                         , p_new_item_revision       IN  VARCHAR2
                                         , p_new_routing_revsion     IN  VARCHAR2
                                         , p_effective_date          IN  DATE
                                         , p_from_end_item_number    IN VARCHAR2
                                         )
RETURN BOOLEAN
IS

                l_return_status BOOLEAN ;

                CURSOR c_CheckPrimary    (  p_revied_item_id   NUMBER
                                          , p_organization_id  NUMBER)
                IS

                    SELECT 1
                    FROM  BOM_OPERATIONAL_ROUTINGS
                    WHERE assembly_item_id = p_revied_item_id
                    AND   organization_id    = p_organization_id
                    AND   NVL(alternate_routing_designator, 'NONE') = 'NONE';

                CURSOR c_Alternate_Check    (  p_revised_item_id         NUMBER
                                             , p_organization_id         NUMBER
                                             , p_change_notice           VARCHAR2
                                             , p_new_item_revision       VARCHAR2
                                             , p_new_routing_revsion     VARCHAR2
                                             , p_from_end_item_number    VARCHAR2
                                             , p_effective_date          DATE
                                             )
                IS


                    SELECT   'Rev Item is only Eco for altenate routing'
                    FROM     ENG_REVISED_ITEMS  eri
                          ,  BOM_BILL_OF_MATERIALS bom
                    WHERE    bom.alternate_bom_designator   IS NOT NULL
                    AND      eri.bill_sequence_id           =   bom.bill_sequence_id(+)
                    AND      eri.bill_sequence_id           IS NOT NULL
                    AND      eri.routing_sequence_id        IS NULL
                    AND      NVL(eri.from_end_item_unit_number, FND_API.G_MISS_CHAR)
                                                   = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR)
                    AND      NVL(eri.new_item_revision,FND_API.G_MISS_CHAR)
                                                   = NVL(p_new_item_revision ,FND_API.G_MISS_CHAR)
                    AND      NVL(eri.new_routing_revision,FND_API.G_MISS_CHAR)
                                                   = NVL(p_new_routing_revsion,FND_API.G_MISS_CHAR)
                    AND      TRUNC(eri.scheduled_date)      = trunc(p_effective_date)
                    AND      eri.change_notice              = p_change_notice
                    AND      eri.organization_id            = p_organization_id
                    AND      eri.revised_item_id            = p_revised_item_id ;



BEGIN

                FOR CheckPrimary IN c_CheckPrimary(p_revised_item_id, p_organization_id)
                LOOP
                        RETURN TRUE ;
                END LOOP;


                FOR CheckRevAlt IN c_Alternate_Check
                                            (  p_revised_item_id
                                             , p_organization_id
                                             , p_change_notice
                                             , p_new_item_revision
                                             , p_new_routing_revsion
                                             , p_from_end_item_number
                                             , p_effective_date
                                             )

                LOOP
                        RETURN FALSE ;
                END LOOP;



                -- If the loop does not execute then
                -- return True`

                RETURN TRUE ;

END Check_RevItem_RtgAlternate ;


/*****************************************************************************
* Procedure     : Check_Required
* Parameters IN : Revised item Exposed column record
* Parameters OUT: Mesg Token Table
*                 Return_Status
* Purpose       : Check_Required procedure will verifu that all the required
*                 columns for the revised item entity have been given by the
*                 user. One error message per missing value will be returned
*                 with an error status.
*****************************************************************************/
PROCEDURE Check_Required
(  x_return_status      OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_Rec   IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 )
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_Token_Tbl(1).Token_name := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_Rec.revised_item_name;

        BOM_Globals.Set_Require_Item_Rev
                (FND_PROFILE.VALUE('ENG:ECO_REVISED_ITEM_REVISION'));

    IF (Bom_globals.Get_Caller_Type = BOM_GLOBALS.G_MASS_CHANGE) THEN
                Null;
    ELSE
        IF ( p_revised_item_rec.new_revised_item_revision IS NULL OR
             p_revised_item_rec.new_revised_item_revision = FND_API.G_MISS_CHAR
            ) AND
            NVL(BOM_Globals.Is_Item_Rev_Required, 0) = 1
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_NEW_REVISION_MISSING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

        IF NVL(BOM_Globals.Is_Item_Rev_Required, 0) = 1 AND
           p_revised_item_rec.updated_revised_item_revision =
                                        FND_API.G_MISS_CHAR
           AND
           p_revised_item_rec.alternate_bom_code IS NULL AND
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       =>'ENG_UPDATED_REVISION_MISSING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Required;

/******************************************************************************
* Procedure     : Check_Entity
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record
*                 Old revised item exposed column record
*                 Old revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return_Status
* Purpose       : Check_Entity procedure will execute the business logic to
*                 validate the revised item entity. It will perform all the
*                 necessary cross entity validations and will also make sure
*                 the user is not entering conflicting values for columns.
******************************************************************************/
PROCEDURE Check_Entity
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_old_revised_item_rec       IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_old_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_control_rec                IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
        l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_new_revision_status         NUMBER := 0;
        l_assembly_type               NUMBER := 0;
        l_err_text                    VARCHAR2(2000) := NULL;
        l_current_item_revision       VARCHAR2(3);
        l_result                      NUMBER;
        l_change_notice               VARCHAR2(10) := NULL;
        l_revision                    VARCHAR2(3) := NULL;
        l_is_item_unit_controlled     BOOLEAN := FALSE;

        l_dup_exists                  NUMBER := 0;
	l_ret_Value                   BOOLEAN ;
	l_plm_or_erp_change           VARCHAR2(3); -- Added for bug 3618676
        l_from_revision               VARCHAR2(3);
        l_message_name                VARCHAR2(80);

        CURSOR CheckDupUnit IS
        SELECT 'x'
          FROM eng_revised_items
         WHERE revised_item_id = p_rev_item_unexp_rec.revised_item_id
           AND from_end_item_unit_number = p_revised_item_rec.From_End_Item_Unit_Number
           AND revised_item_sequence_id <> NVL(p_rev_item_unexp_rec.revised_item_sequence_id,0)
           AND change_notice = p_revised_item_rec.eco_name;

        CURSOR CheckDupDateUnit IS
        SELECT 'x'
          FROM eng_revised_items
         WHERE revised_item_id = p_rev_item_unexp_rec.revised_item_id
           AND from_end_item_unit_number = NVL(p_revised_item_rec.New_From_End_Item_Unit_Number,
                                        (NVL(p_revised_item_rec.From_End_Item_Unit_Number,
                                                FND_API.G_MISS_NUM)))
           AND scheduled_date = NVL(p_revised_item_rec.New_Effective_Date,
                                                p_revised_item_rec.Start_Effective_Date)
           AND new_item_revision = NVL(p_revised_item_rec.updated_revised_item_revision,
                                        (NVL(p_revised_item_rec.new_revised_item_revision,
                                                FND_API.G_MISS_NUM)))
           AND organization_id = p_rev_item_unexp_rec.organization_id
           AND change_notice = p_revised_item_rec.eco_name;

        l_ECO_approved  NUMBER := 0;
        cursor c_CheckEcoApproval IS
                SELECT 1
                  FROM eng_engineering_changes
                 WHERE change_notice = p_revised_item_rec.eco_name
                   AND organization_id = p_rev_item_unexp_rec.organization_id
                   AND approval_status_type = 5;

        l_bom_enabled_flag      VARCHAR2(1);
        CURSOR c_CheckBomEnabled IS
                SELECT bom_enabled_flag
                  FROM mtl_system_items msi
                 WHERE msi.inventory_item_id =
                                p_rev_item_unexp_rec.revised_item_id
                   AND msi.organization_id =
                                p_rev_item_unexp_rec.organization_id;

        l_alternate_bom_designator VARCHAR2(10) := NULL;

        CURSOR c_GetAlternateDesignator IS
                 SELECT alternate_bom_designator
                   FROM bom_bill_of_materials
                  WHERE bill_sequence_id =
                                nvl(p_rev_item_unexp_rec.bill_sequence_id,
                                        FND_API.G_MISS_NUM);

        l_product_family        BOOLEAN := FALSE;
        CURSOR c_CheckItemProductFamily IS
                SELECT 'Product Family'
                  FROM mtl_system_items
                 WHERE inventory_item_id = p_rev_item_unexp_rec.revised_item_id
                   AND organization_id   = p_rev_item_unexp_rec.organization_id
                   AND bom_item_type     = 5;    -- Product Family

        /*******************************************************************
        --
        -- Cursor will check if the given use_up_item is one from the
        -- list of implemented components on the bill
        -- The value for use_up_date is queried in the previous validation
        -- where it is checked if the inventory_use_up_date must be equal to
        -- the schedule date.
        -- This quering may actually not be required and the scheduled date
        -- can just be used.
        --
        ********************************************************************/
         CURSOR c_CheckUseUpItem(   p_revised_item_id           NUMBER
                                  , p_alternate_designator      VARCHAR2
                                  , p_organization_id           NUMBER
                                  , p_use_up_item_id            NUMBER
                                  , p_use_up_date               DATE
                                  )
        IS
        SELECT component_sequence_id
          FROM bom_inventory_components bic,
               bom_bill_of_materials    bom
         WHERE bic.component_item_id = p_use_up_item_id
           AND bic.implementation_date IS NOT NULL
           AND bic.bill_sequence_id = bom.bill_sequence_id
           AND bom.assembly_item_id = p_revised_item_id
           AND bom.organization_id  = p_organization_id
           AND NVL(bom.alternate_bom_designator, 'NONE') =
               NVL(p_alternate_designator, 'NONE')
           AND NVL(bic.acd_type, -1) <> 3   -- Modified by MK on 10/30/2000
           AND bic.effectivity_date <= NVL(p_use_up_date,SYSDATE)
           AND NVL(bic.disable_date,p_use_up_date) >= NVL(p_use_up_date,SYSDATE);                                            -- 2199507


        /*******************************************************************
        -- Following Cusrsors are for New ECO Effectivites and ECO Routing
        -- Added by MK on 08/26/2000
        ********************************************************************/

        -- Check ECO for Cum Qty
        CURSOR l_wipjob_for_eco_cum_csr( p_wip_entity_id       NUMBER
                                       , p_bill_sequence_id    NUMBER
                                       , p_routing_sequence_id NUMBER )
        IS
           SELECT    scheduled_start_date
                   , start_quantity
           FROM    WIP_DISCRETE_JOBS
           WHERE   status_type   = 1
           AND     wip_entity_id = p_wip_entity_id
           AND    ( common_bom_sequence_id = p_bill_sequence_id
                    OR  common_routing_sequence_id = p_routing_sequence_id
                   ) ;

        l_wipjob_for_eco_cum_rec l_wipjob_for_eco_cum_csr%ROWTYPE ;


        -- Check ECO for Lot Number
        CURSOR l_wipjob_for_eco_lot_csr(  p_lot_number           VARCHAR2
                                        , p_start_effective_date DATE
                                        , p_org_id               NUMBER
                                        , p_rev_item_id          NUMBER
                                       )
        IS
           SELECT    'Lot Number is invalid'
           FROM     SYS.DUAL
           WHERE    NOT EXISTS  ( SELECT 'Valid Lot'
                                  FROM   WIP_DISCRETE_JOBS wdj1
                                  WHERE   wdj1.lot_number  = p_lot_number
                                  AND     wdj1.status_type = 1
                                  AND     wdj1.scheduled_start_date  >= p_start_effective_date
                                  AND     wdj1.organization_Id = p_org_id
                                  AND     wdj1.primary_item_id = p_rev_item_id
                                 )
           OR       EXISTS     (SELECT 'Invalid Lot'
                                FROM WIP_DISCRETE_JOBS  wdj2
                                WHERE  wdj2.lot_number = p_lot_number
                                AND    ( wdj2.status_type <> 1 OR
                                         wdj2.scheduled_start_date  < p_start_effective_date)
                                AND    wdj2.organization_Id = p_org_id
                                AND    wdj2.primary_item_id = p_rev_item_id
                                 ) ;


         -- Check ECO for WO Order
        CURSOR l_wipjob_for_eco_wo_csr(  p_from_wo_num          VARCHAR2
                                       , p_to_wo_num            VARCHAR2
                                       , p_org_id               NUMBER
                                       , p_start_effective_date DATE
                                       , p_bill_sequence_id     NUMBER
                                       , p_routing_sequence_id  NUMBER )
        IS
           SELECT    'WO Range is invalid'
           FROM     SYS.DUAL
           WHERE    NOT  EXISTS  ( SELECT 'Valid WO'
                                   FROM    WIP_DISCRETE_JOBS wdj1
                                         , WIP_ENTITIES      we1
                                   WHERE   wdj1.status_type = 1
                                   AND    ( wdj1.common_bom_sequence_id = p_bill_sequence_id
                                           OR  wdj1.common_routing_sequence_id = p_routing_sequence_id
                                          )
                                   AND     wdj1.scheduled_start_date  >= p_start_effective_date
                                   AND     wdj1.wip_entity_id = we1.wip_entity_id
                                   AND     we1.organization_id = p_org_id
                                   AND     we1.wip_entity_name >= p_from_wo_num
                                   AND     we1.wip_entity_name <= NVL(p_to_wo_num, p_from_wo_num)
                                  )
           OR       EXISTS       ( SELECT 'Invalid WO'
                                   FROM   WIP_DISCRETE_JOBS wdj2
                                       , WIP_ENTITIES      we2
                                   WHERE   ( wdj2.status_type <> 1 OR
                                            wdj2.scheduled_start_date  < p_start_effective_date )
                                   AND    ( wdj2.common_bom_sequence_id = p_bill_sequence_id
                                           OR  wdj2.common_routing_sequence_id = p_routing_sequence_id
                                          )
                                   AND     wdj2.wip_entity_id = we2.wip_entity_id
                                   AND     we2.organization_id = p_org_id
                                   AND     we2.wip_entity_name >= p_from_wo_num
                                   AND     we2.wip_entity_name <= NVL(p_to_wo_num, p_from_wo_num)
                                 ) ;


         -- Check if Routing Info is updated
        CURSOR l_rtg_header_csr (  p_revised_item_id        NUMBER
                                 , p_alternate_routing_code VARCHAR2
                                 , p_org_id                 NUMBER
                                )
        IS
            SELECT   completion_subinventory
                   , completion_locator_id
                   , ctp_flag
                   , priority
            FROM     BOM_OPERATIONAL_ROUTINGS
            WHERE    assembly_item_id     =  p_revised_item_id
            AND      organization_id      =  p_org_id
            AND      alternate_routing_designator = p_alternate_routing_code
            ;

       l_rtg_header_rec l_rtg_header_csr%ROWTYPE ;



        -- Cursors for completion_subinventory check
        CURSOR c_Restrict_SubInv_Asset ( p_revised_item_id NUMBER
                                       , p_organization_id NUMBER
                                       , p_subinventory    VARCHAR2 )
        IS
            SELECT locator_type
            FROM mtl_item_sub_ast_trk_val_v
            WHERE inventory_item_id =  p_revised_item_id
            AND organization_id = p_organization_id
            AND secondary_inventory_name = p_subinventory;


        CURSOR c_Restrict_SubInv_Trk  (  p_revised_item_id NUMBER
                                       , p_organization_id NUMBER
                                       , p_subinventory    VARCHAR2 )

        IS
            SELECT locator_type
            FROM  mtl_item_sub_trk_val_v
            WHERE inventory_item_id =  p_revised_item_id
            AND organization_id = p_organization_id
            AND secondary_inventory_name = p_subinventory;


        CURSOR c_SubInventory_Asset   (  p_organization_id NUMBER
                                       , p_subinventory    VARCHAR2 )
        IS
            SELECT locator_type
            FROM mtl_sub_ast_trk_val_v
            WHERE organization_id = p_organization_id
            AND   secondary_inventory_name = p_subinventory;



        CURSOR c_SubInventory_Tracked  ( p_organization_id NUMBER
                                       , p_subinventory    VARCHAR2 )
        IS
            SELECT locator_type
            FROM  mtl_subinventories_trk_val_v
            WHERE organization_id = p_organization_id
            AND   secondary_inventory_name = p_subinventory;


        l_alternate_rtg_designator VARCHAR2(10) := NULL ;

        CURSOR c_GetRtgAltDesignator
        IS
           SELECT alternate_routing_designator
           FROM   BOM_OPERATIONAL_ROUTINGS
           WHERE  routing_sequence_id = NVL(  p_rev_item_unexp_rec.routing_sequence_id
                                            , FND_API.G_MISS_NUM );


        /*******************************************************************
        --End of Cursor Definition  Added by MK on 08/26/2000
        ********************************************************************/


        l_IsUseUpValid          BOOLEAN;
        l_IsDateValid           BOOLEAN;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_use_up_date           DATE := SYSDATE;
        l_new_rev_required      NUMBER := 0;

        -- Followings are added by MK on 08/26/2000
        l_allow_expense_to_asset    VARCHAR2(10);
        l_rest_subinv_code          VARCHAR2(1);
        l_inv_asset_flag            VARCHAR2(1);


        l_is_revision_invalid  NUMBER;
        l_is_scheduled_date_invalid   NUMBER;

BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Performing Check Entity in Revised Item - Trans type: ' || p_revised_item_rec.transaction_Type );
END IF;

        --
        -- Set revised item token name and value.
        --
        l_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        IF p_control_rec.caller_type = 'FORM' AND
           p_rev_item_unexp_rec.revised_item_id IS NULL
        THEN
                --  Done validating entity

                x_return_status := l_return_status;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                RETURN;
        END IF;
        IF p_control_rec.caller_type <> 'FORM'
        THEN
                l_new_rev_required := BOM_Globals.Is_Item_Rev_Required;
                l_is_item_unit_controlled := BOM_Globals.Get_Unit_Controlled_Item;
        ELSE
                l_new_rev_required := p_control_rec.require_item_rev;
                l_is_item_unit_controlled := p_control_rec.unit_controlled_item;
        END IF;

	-- Initialize PLM or ERP Change
	-- Added for 3618676
	IF (p_control_rec.caller_type = 'SSWA')
	THEN
            l_plm_or_erp_change := 'PLM';
	ELSE
            l_plm_or_erp_change := Eng_Globals.Get_PLM_Or_ERP_Change(p_revised_item_rec.eco_name, p_rev_item_unexp_rec.organization_id);
	END IF;
/*********************************************************************************
** Added by MK on 08/25/2000.
** Check Entity for New ECO Effectivities and ECO Routing.
**********************************************************************************/

        /*********************************************************************
         -- If revised item is unit controlled, From Work Order, To Work Order
         -- Lot Number and Cum Qty must be null
         -- Added by MK 08/25/2000
        **********************************************************************/
        IF l_is_item_unit_controlled AND
           ((p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE)
             AND
             ( p_revised_item_rec.lot_number               IS NOT NULL OR
               p_revised_item_rec.from_cumulative_quantity IS NOT NULL OR
               p_rev_item_unexp_rec.to_wip_entity_id       IS NOT NULL OR
               p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL   )
             )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_ACCESS_WOECTV_DENIED'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('After check if rev item is unit conrolled in new eco type. . . the return status : ' ||
                              l_Return_Status );
END IF;


        /*********************************************************************
         -- If MRP Active is not No and Update WIP is not Yes, From Work Order,
         -- To Work Order Lot Number and Cum Qty must be null
         -- Added by MK 08/25/2000
        **********************************************************************/
        IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
            p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
          AND ( p_revised_item_rec.mrp_active <> 2  OR
                p_revised_item_rec.update_wip <> 1    )
          AND
             ( p_revised_item_rec.lot_number               IS NOT NULL OR
               p_revised_item_rec.from_cumulative_quantity IS NOT NULL OR
               p_rev_item_unexp_rec.to_wip_entity_id       IS NOT NULL OR
               p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
             )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_MAC_UWIP_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('After check new eco type attributes, the return status is ' ||
                              l_Return_Status);
END IF;

        /*********************************************************************
         -- Followings are Entity Validation for New Effectivities
        **********************************************************************/
        IF p_revised_item_rec.mrp_active = 2 AND p_revised_item_rec.update_wip = 1
        THEN

            /*****************************************************************
             -- If From Work Order is not Null then Lot Number must be Null
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.from_wip_entity_id IS NOT NULL
            AND  p_revised_item_rec.lot_number           IS NOT NULL
            THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_LOTNUM_MUSTBE_NULL'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check lot number and type, the return status is ' ||
                               l_Return_Status);
END IF;

            /*****************************************************************
             -- If To Work Order is not Null then
             -- From Work Order must not be null
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.to_wip_entity_id     IS NOT NULL
            AND  p_rev_item_unexp_rec.from_wip_entity_id   IS NULL
            THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_FROMWO_MUSTNOT_NULL'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check wip id, the return status is ' || l_Return_Status);
END IF;
            /*****************************************************************
             -- If To Work Order is not Null then
             -- To Work Order must be greater than From Work Order
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.to_wip_entity_id   IS NOT NULL
            AND  ( p_revised_item_rec.from_work_order  >  p_revised_item_rec.to_work_order
                   OR p_rev_item_unexp_rec.from_wip_entity_id IS NULL)
            THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_FROMWO_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check work order, the return status is ' || l_Return_Status);
END IF;

           /*****************************************************************
             -- If From Work Order and To Work Order is not Null then
             -- Cumulative Quantity must be null.
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.to_wip_entity_id   IS NOT NULL
            AND  p_rev_item_unexp_rec.from_wip_entity_id IS NOT NULL
            AND  p_revised_item_rec.from_cumulative_quantity IS NOT NULL
            THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_CUMQTY_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check type and cumu, the return status is ' ||
                                l_Return_Status);
END IF;
           /*****************************************************************
             -- If Cumulative Quantity is not null then
             -- From Work Order must not be null and To Work Order must be null.
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  ( p_rev_item_unexp_rec.from_wip_entity_id     IS NULL
                 OR  p_rev_item_unexp_rec.to_wip_entity_id     IS NOT NULL )
            AND  p_revised_item_rec.from_cumulative_quantity IS NOT NULL
            THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_ECO_BY_CUMQTY_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check cumulative qty and from/to id, the return status is ' ||
                                l_Return_Status);
END IF;

           /*****************************************************************
             -- If From Work Order is not null then
             -- To Work Order or Cumulative Quantity must not be null.
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
            AND  p_rev_item_unexp_rec.to_wip_entity_id        IS NULL
            AND  p_revised_item_rec.from_cumulative_quantity  IS  NULL
            THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_FROMWO_ISNOT_NULL'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check work order and cumulative qty, the return status is ' ||
                                l_Return_Status);
END IF;

            /*****************************************************************
             -- If Lot Number is not null then
             -- From Work Order, To Work Order and Cum Quantity  must be null.
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_revised_item_rec.lot_number IS NOT NULL
            THEN

                IF ( p_revised_item_rec.from_cumulative_quantity IS NOT NULL OR
                     p_rev_item_unexp_rec.to_wip_entity_id       IS NOT NULL OR
                     p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
                   )
                THEN
                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_ECO_BY_LOT_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                    END IF;
                    l_return_status := FND_API.G_RET_STS_ERROR;

                /*************************************************************
                -- Validation for ECO Lot
                -- Check if there is unreleased work order with lot number
                -- with start date < effective date
                -- Added by MK 08/26/2000
                *************************************************************/
                ELSE

                    FOR l_wipjob_for_eco_lot_rec IN l_wipjob_for_eco_lot_csr
                        (  p_lot_number  =>  p_revised_item_rec.lot_number
                         , p_start_effective_date
                                         =>  p_revised_item_rec.start_effective_date
                         , p_org_id      =>  p_rev_item_unexp_rec.organization_id
                         , p_rev_item_id =>  p_rev_item_unexp_rec.revised_item_id
                        )
                    LOOP
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            Error_Handler.Add_Error_Token
                            (  p_Message_Name       => 'ENG_RIT_LOTNUM_WO_RELEASED'
                             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Token_Tbl          => l_Token_Tbl
                            );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                    END LOOP ;
                END IF ;
            END IF ;

IF BOM_Globals.get_debug = 'Y'THEN
    error_handler.write_debug('After check release status, the return status is ' ||
                               l_Return_Status);
END IF;

            /*****************************************************************
             -- Validation for ECO Cum Qty
             -- From Work Order must be unreleased order.
             -- From Cum Qty must be smaller or equal than Wip Job's Start Qty
             -- Rev Item Effective Date msut be past than WIP Job's start date
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
            AND  p_revised_item_rec.from_cumulative_quantity IS NOT NULL
            AND  p_revised_item_rec.lot_number               IS NULL
            AND  p_rev_item_unexp_rec.to_wip_entity_id       IS NULL
            THEN

                OPEN  l_wipjob_for_eco_cum_csr
                      (  p_wip_entity_id       => p_rev_item_unexp_rec.from_wip_entity_id
                      ,  p_bill_sequence_id    => p_rev_item_unexp_rec.bill_sequence_id
                      ,  p_routing_sequence_id => p_rev_item_unexp_rec.routing_sequence_id
                      );

                FETCH l_wipjob_for_eco_cum_csr INTO l_wipjob_for_eco_cum_rec ;
                    IF l_wipjob_for_eco_cum_csr%NOTFOUND THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN

                            Error_Handler.Add_Error_Token
                            (  p_Message_Name       => 'ENG_RIT_CUMQTY_WO_RELEASED'
                             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Token_Tbl          => l_Token_Tbl
                            );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                    ELSE
                        IF p_revised_item_rec.from_cumulative_quantity > l_wipjob_for_eco_cum_rec.start_quantity
                           OR p_revised_item_rec.from_cumulative_quantity < 0
                        THEN
                            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                                    l_Token_Tbl(2).Token_Name  := 'WORK_ORDER';
                                    l_Token_Tbl(2).Token_Value := p_revised_item_rec.from_work_order ;

                                    Error_Handler.Add_Error_Token
                                    (  p_Message_Name       => 'ENG_RIT_CUMQTY_WO_QTY_INVALID'
                                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                     , p_Token_Tbl          => l_Token_Tbl
                                    );
                            END IF;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF ;

                        IF p_revised_item_rec.start_effective_date > l_wipjob_for_eco_cum_rec.scheduled_start_date
                        THEN
                            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                                    l_Token_Tbl(2).Token_Name  := 'WORK_ORDER';
                                    l_Token_Tbl(2).Token_Value := p_revised_item_rec.from_work_order ;

                                    Error_Handler.Add_Error_Token
                                    (  p_Message_Name       => 'ENG_RIT_CUMQTY_WO_DATE_INVALID'
                                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                     , p_Token_Tbl          => l_Token_Tbl
                                    );
                            END IF;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF ;
                    END IF ;
               CLOSE l_wipjob_for_eco_cum_csr ;
           END IF ;

IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('After check released status and cum, the return status is ' ||
                               l_Return_Status);
END IF;

            /*****************************************************************
             -- Validation for ECO WO Number
             -- The WOs between From Work Order and To Work Order
             -- must be unreleased order.
             -- Rev Item Effective Date msut be past than WIP Job's start date
             -- Added by MK 08/25/2000
            ******************************************************************/
            IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
            AND  p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
            AND  p_revised_item_rec.from_cumulative_quantity IS NULL
            AND  p_revised_item_rec.lot_number               IS NULL
            AND  p_revised_item_rec.from_work_order <=  p_revised_item_rec.to_work_order

            THEN

                FOR l_wipjob_for_eco_wo_rec IN l_wipjob_for_eco_wo_csr
                (  p_from_wo_num =>  p_revised_item_rec.from_work_order
                 , p_to_wo_num   =>  p_revised_item_rec.to_work_order
                 , p_org_id      =>  p_rev_item_unexp_rec.organization_id
                 , p_start_effective_date =>  p_revised_item_rec.start_effective_date
                 , p_bill_sequence_id     => p_rev_item_unexp_rec.bill_sequence_id
                 , p_routing_sequence_id  => p_rev_item_unexp_rec.routing_sequence_id
                )
                LOOP
                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_WORANGE_WO_RELEASED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                     END IF;
                     l_return_status := FND_API.G_RET_STS_ERROR;
                END LOOP ;

IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('From WO Num : ' || p_revised_item_rec.from_work_order );
    error_handler.write_debug('To WO Num : ' ||   p_revised_item_rec.to_work_order );
    error_handler.write_debug('Effective Date : ' || to_char(p_revised_item_rec.start_effective_date
                                                            ,'YYYY-MM-DD') );
    error_handler.write_debug('After check ECO WO Number, the return status is');
END IF;
            END IF ;

        END IF ;
         --End of Entity Validation for New Effectivities

IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('After check new  Effectivities, the return status is ' ||
                                l_Return_Status);
END IF;

        /*****************************************************************
        -- Validation for ECO For Production Flag
        -- If Eco For Production is Yes, ECO Type should be either
        -- ECO by Lot Num, ECO by WO, or ECO by Cum Qty
        -- Added by MK 10/06/2000
        -- Modified by MK 01/29/2001
        -- Eco for produciton must be Yes when Eco type is Eco by Prod
        -- also Eco for production must be No when Eco Type is not Eco by Prod.
        ******************************************************************/
        IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
            p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
          AND p_revised_item_rec.eco_for_production = 1 -- Yes
          AND
             ( p_revised_item_rec.lot_number               IS NULL AND
               p_rev_item_unexp_rec.from_wip_entity_id     IS NULL
             )
        THEN

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_ECO_FOR_PROD_MUSTBE_NO'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF
           (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
            p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
          AND p_revised_item_rec.eco_for_production = 2 -- No
          AND
             ( p_revised_item_rec.lot_number               IS NOT NULL OR
               p_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
             )
        THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_ECO_FOR_PROD_MUSTBE_Y'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF ;


        /*********************************************************************
         -- Added by MK on 08/26/2000.
         -- If revised item is unit controlled, the user must not update
         -- modifiy current routing
        **********************************************************************/
        IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE  )
        AND l_is_item_unit_controlled
        AND ( p_revised_item_rec.completion_subinventory  IS NOT NULL OR
              p_revised_item_rec.new_routing_revision     IS NOT NULL OR
              p_revised_item_rec.updated_routing_revision IS NOT NULL OR
              p_rev_item_unexp_rec.completion_locator_id  IS NOT NULL OR
              NVL(p_revised_item_rec.ctp_flag, Bom_Default_Rtg_Header.Get_Ctp_Flag)
                                               <> Bom_Default_Rtg_Header.Get_Ctp_Flag  OR
              p_revised_item_rec.routing_comment          IS NOT NULL OR
              p_revised_item_rec.priority                 IS NOT NULL   )
        THEN

                OPEN  l_rtg_header_csr ( p_revised_item_id        => p_rev_item_unexp_rec.revised_item_id
                                       , p_alternate_routing_code => p_revised_item_rec.alternate_bom_code
                                       , p_org_id                 => p_rev_item_unexp_rec.organization_id
                                       );


                FETCH l_rtg_header_csr INTO l_rtg_header_rec ;
                    IF l_rtg_header_csr%FOUND
                    AND
                    (      l_rtg_header_rec.completion_subinventory <> p_revised_item_rec.completion_subinventory
                      OR   p_revised_item_rec.updated_routing_revision <> p_revised_item_rec.new_routing_revision
                      OR   l_rtg_header_rec.completion_locator_id <> p_rev_item_unexp_rec.completion_locator_id
                      OR   l_rtg_header_rec.ctp_flag <> p_revised_item_rec.ctp_flag
                      OR   l_rtg_header_rec.priority <> p_revised_item_rec.priority
                    )
                    THEN

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            Error_Handler.Add_Error_Token
                            (  p_Message_Name       => 'ENG_RIT_CANNOT_CHANGE_RTG'
                             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Token_Tbl          => l_Token_Tbl
                            );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                    END IF ;
               close l_rtg_header_csr;
         END IF ;

IF BOM_Globals.get_debug = 'Y' THEN
    error_handler.write_debug('After check unit control for Routing, the return status is ' ||
                               l_Return_Status);
END IF;


        /*********************************************************************
        -- Added by MK on 02/15/2001 insted of below the validation
        -- Cannot update alternate routing designator
        **********************************************************************/
        IF p_revised_item_rec.alternate_bom_code IS NOT NULL AND
	 p_revised_item_rec.alternate_bom_code <> p_old_revised_item_rec.alternate_bom_code AND -- R12:LKASTURI:7/11/2005
           p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE AND
           ( NVL(p_rev_item_unexp_rec.routing_sequence_id, 0) <>
                  NVL(p_old_rev_item_unexp_rec.routing_sequence_id, 0) OR
             NVL(p_rev_item_unexp_rec.bill_sequence_id, 0) <>
                  NVL(p_old_rev_item_unexp_rec.bill_sequence_id, 0)
           )
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Alternate you have entered : '
                                            || p_revised_item_rec.alternate_bom_code ); END IF;

                l_token_tbl.DELETE;
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ALT_DESG_NOT_UPDATEABLE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After check if alternate code is changed, the return status is ' ||
                               l_Return_Status);
END IF;


        END IF ;


        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- Cannot update alternate routing designator
        -- Comment out by MK on 02/15/2001 no longer used.
        FOR  alt IN c_GetRtgAltDesignator
        LOOP
             l_alternate_rtg_designator := alt.alternate_routing_designator ;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('alternate: ' || l_alternate_rtg_designator); END IF;

        END LOOP;

        IF l_alternate_rtg_designator IS NOT NULL AND
           p_revised_item_rec.alternate_bom_code <> l_alternate_rtg_designator AND
           p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE
        THEN
                l_token_tbl.DELETE;
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ALT_DESG_NOT_UPDATEABLE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        **********************************************************************/

        l_token_tbl.delete;
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;


        /*********************************************************************
        -- Added by MK on 12/01/2000
        -- Cannot enter New Routing Revision and Routings's Attributes
        -- if the revised item is PTO item, Planning Item ,Not Bom Allowed
        -- or referencing a common rouitng.
        **********************************************************************/
	 IF((p_revised_item_rec.new_routing_revision IS NOT NULL AND
            p_revised_item_rec.new_routing_revision <> FND_API.G_MISS_CHAR) OR
           (p_revised_item_rec.updated_routing_revision IS NOT NULL AND
            p_revised_item_rec.updated_routing_revision <> FND_API.G_MISS_CHAR) OR
           ( p_revised_item_rec.completion_subinventory IS NOT NULL AND
             p_revised_item_rec.completion_subinventory <> FND_API.G_MISS_CHAR )OR
           (p_revised_item_rec.completion_location_name IS NOT NULL AND
            p_revised_item_rec.completion_location_name <> FND_API.G_MISS_CHAR )
           ) AND
        	Not Val_Rev_Item_for_Rtg(  p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
                                     , p_organization_id => p_rev_item_unexp_rec.organization_id
                                     )
        AND  ( ((p_revised_item_rec.new_routing_revision IS NOT NULL) AND
	       (p_revised_item_rec.new_routing_revision <> FND_API.G_MISS_CHAR))
	     OR	(p_revised_item_rec.updated_routing_revision IS NOT NULL AND
                 p_revised_item_rec.updated_routing_revision <> FND_API.G_MISS_CHAR)
             OR  p_revised_item_rec.ctp_flag <> Bom_Default_Rtg_Header.Get_Ctp_Flag
             OR  p_revised_item_rec.completion_subinventory IS NOT NULL
             OR  p_revised_item_rec.completion_location_name IS NOT NULL
             OR  p_revised_item_rec.priority IS NOT NULL
             OR  p_revised_item_rec.routing_comment IS NOT NULL
             )
        AND  p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_CANNOT_BE_ON_RTG'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After check if a rtg can be created for this rev item, the return status is ' || l_Return_Status);
END IF;


        END IF ;

        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- Cannot have routing revision, if routing is an alternate.
        **********************************************************************/
        IF p_revised_item_rec.new_routing_revision IS NOT NULL AND
           p_revised_item_rec.alternate_bom_code IS NOT NULL AND
           p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_CREATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_HAVE_RTG_REVISION'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );

                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE AND
              p_revised_item_rec.alternate_bom_code IS NOT NULL AND
              p_revised_item_rec.updated_routing_revision IS NOT NULL
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => 'ENG_CANNOT_HAVE_RTG_REVISION'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('After checking rtg revision is null when alt code is not null, the return status is ' || l_return_status );
END IF;



        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- New Routing Revision name is not allowed to use 'Quote'.
        **********************************************************************/

         IF INSTR(NVL(p_revised_item_rec.updated_routing_revision,
                      p_revised_item_rec.new_routing_revision     )
                  , '''') <> 0
         THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'ENG_RIT_RTGREV_QTE_NOT_ALLOWED'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , p_Token_Tbl          => l_Token_Tbl
                    );
              END IF;
              l_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check routing rev, the return status is ' || l_Return_Status);
END IF;


        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- Check if the (currently) highest un-implemented routing revision of the
        -- revised item exists on another ECO - log warning
        *********************************************************************/

        IF (p_control_rec.caller_type = 'FORM'
          AND p_revised_item_rec.transaction_type = 'CREATE'
          AND p_control_rec.validation_controller = 'REVISED_ITEM')
          OR
          (p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA')
        THEN

            Pending_High_Rtg_Rev
            ( p_change_notice   => p_revised_item_rec.eco_name
            , p_organization_id => p_rev_item_unexp_rec.organization_id
            , p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
            , x_change_notice   => l_change_notice
            , x_revision        => l_revision
            );

IF BOM_Globals.get_debug = 'Y'THEN
     error_handler.write_debug('After Pending_High_Rtg_Rev, the return status is ' || l_Return_Status);
END IF;



            --  Modified by MK on 10/27/2000
            --  Warnig is occurred when the current highest un-implemented revision
            --  for the revised item exists on another ECO.
            --
            --  IF l_change_notice IS NOT NULL

            IF l_change_notice <> p_revised_item_rec.eco_name
            THEN
                l_token_tbl.delete;
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := l_change_notice;
                l_token_tbl(3).token_name  := 'REVISION';
                l_token_tbl(3).token_value := l_revision;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_HIGH_RTG_REV_PENDING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
                END IF;
            END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check pending eco, the return status is '  ||  l_Return_Status);
END IF;

        END IF;

        /*********************************************************************
        -- Added by MK 08/26/2000
        -- if the transaction type is create or update, the check new_routing_revision
        **********************************************************************/

        IF ( p_revised_item_rec.updated_routing_revision <>
             p_old_revised_item_rec.new_routing_revision AND
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
           ) OR
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN
                --
                -- if the transaction type is create, the check new_routing_revision
                --
               IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               THEN
                  l_new_revision_status :=
                  Validate_New_Rtg_Revision
                  ( p_revised_item_id     => p_rev_item_unexp_rec.revised_item_id
                  , p_organization_id     => p_rev_item_unexp_rec.organization_id
                  , p_new_routing_revision      =>
                                p_revised_item_rec.new_routing_revision
                  , p_revised_item_sequence_id  =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                  , x_change_notice       => l_change_notice
                  );
               ELSE /* If Update, pass updated_routing_revision */
                  l_new_revision_status :=
                  Validate_New_Rtg_Revision
                 ( p_revised_item_id         => p_rev_item_unexp_rec.revised_item_id
                  , p_organization_id        => p_rev_item_unexp_rec.organization_id
                  , p_new_routing_revision   =>
                        p_revised_item_rec.updated_routing_revision
                  , p_revised_item_sequence_id    =>
                        p_rev_item_unexp_rec.revised_item_sequence_id
                  , x_change_notice          => l_change_notice
                  );
               END IF;

               IF l_new_revision_status = 1
               THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN

                            l_token_tbl(1).token_name :=  'REVISED_ITEM_NAME';
                            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;

                            Error_Handler.Add_Error_Token
                            ( p_Message_Name  => 'ENG_RIT_NEW_RTG_REV_NOT_CURR'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_Token_Tbl      => l_Token_Tbl );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
               ELSIF l_new_revision_status = 2
               THEN
                        l_token_tbl.delete;

                        l_token_tbl(1).token_name :=  'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;

                        -- Added by MK on 11/05/00
                        IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                        THEN
                            l_token_tbl(2).token_name  := 'NEW_RTG_REVISION';
                            l_token_tbl(2).token_value := p_revised_item_rec.new_routing_revision;
                        ELSE
                            l_token_tbl(2).token_name  := 'NEW_RTG_REVISION';
                            l_token_tbl(2).token_value := p_revised_item_rec.updated_routing_revision;
                        END IF ;

                        l_token_tbl(3).token_name := 'ECO_NAME';
                        l_token_tbl(3).token_value := l_change_notice;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name   => 'ENG_RIT_NEW_RTG_REV_EXISTS'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_token_tbl      => l_token_tbl
                                 , p_message_type   => 'E'
                                );
                        END IF;

                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSIF l_new_revision_status = 3
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN

                            l_token_tbl(1).token_name :=  'REVISED_ITEM_NAME';
                            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;

                            Error_Handler.Add_Error_Token
                                (  p_Message_Name   => 'ENG_RIT_NEW_RTG_REV_IMPL'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check transaction type, the return status is ' ||  l_Return_Status);
END IF;


        /*********************************************************************
        -- Added by MK 08/26/2000
        -- if the transaction type is create or update, the check ctp_flag
        **********************************************************************/
        IF ( p_revised_item_rec.ctp_flag <> p_old_revised_item_rec.ctp_flag AND
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
           ) OR
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
           p_revised_item_rec.ctp_flag = 1
        THEN
            IF NOT Check_CTP_Flag
               (  p_revised_item_id    => p_rev_item_unexp_rec.revised_item_id
                , p_organization_id    => p_rev_item_unexp_rec.organization_id
                , p_cfm_routing_flag   => p_rev_item_unexp_rec.cfm_routing_flag
		, p_routing_sequence_id =>
				p_rev_item_unexp_rec.routing_sequence_id
                )
            THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name   => 'ENG_RIT_CTP_ALREADY_EXISTS'
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_Token_Tbl      => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check ctp flag, the return status is '  ||  l_Return_Status);
END IF;
        END IF ;

        /*********************************************************************
        -- Added by MK 08/26/2000
        -- if the transaction type is create or update, the check priority
        **********************************************************************/
        IF ( p_revised_item_rec.priority <> p_old_revised_item_rec.priority AND
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
           ) OR
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
           p_revised_item_rec.priority  IS NOT NULL
        THEN
            IF NOT Check_Priority
               (  p_revised_item_id    => p_rev_item_unexp_rec.revised_item_id
                , p_organization_id    => p_rev_item_unexp_rec.organization_id
                , p_cfm_routing_flag   => p_rev_item_unexp_rec.cfm_routing_flag
                , p_priority           => p_revised_item_rec.priority  )
            THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name   => 'ENG_RIT_PRIORITY_DUPLICATE'
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_Token_Tbl      => l_Token_Tbl
                    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After check priority, the return status is ' ||  l_Return_Status);
END IF;

        END IF ;


        /*********************************************************************
        -- Added by MK 08/26/2000
        -- Check Completion Subinventory
        **********************************************************************/
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Performing completeion subinventory check. . . Sub Inv : '
                             || p_revised_item_rec.completion_subinventory ) ;
    Error_Handler.Write_Debug('Old Completion_subinv is:'||p_old_revised_item_rec.completion_subinventory );
END IF;

        IF (( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
              AND
                  NVL(p_revised_item_rec.completion_subinventory, '0') <>
                  NVL(p_old_revised_item_rec.completion_subinventory, '0')
          )
             OR p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
             )
        AND ( p_revised_item_rec.completion_subinventory IS  NULL
             OR p_revised_item_rec.completion_subinventory =  FND_API.G_MISS_CHAR)
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Inside the process when subinventory is null' ) ;
END IF;

            IF  p_rev_item_unexp_rec.completion_locator_id IS NOT NULL
            AND  p_rev_item_unexp_rec.completion_locator_id <>  FND_API.G_MISS_NUM
            -- OR  p_rev_item_unexp_rec.completion_locator_id <>  FND_API.G_MISS_NUM
            -- updated by MK on 11/15/00
            THEN
                l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                -- l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                -- l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                Error_Handler.Add_Error_Token
                (  p_message_name       =>  'BOM_RTG_LOCATOR_MUST_BE_NULL'
                 , p_token_tbl          => l_token_tbl
                 , p_mesg_token_tbl     => l_mesg_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;

        -- Check if Subinventory exists
        ELSIF
            (( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
              AND NVL(p_revised_item_rec.completion_subinventory, '0') <>
                  NVL(p_old_revised_item_rec.completion_subinventory, '0')
            )
             OR p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
             )
        AND    ( p_revised_item_rec.completion_subinventory IS NOT NULL
               OR p_revised_item_rec.completion_subinventory <>  FND_API.G_MISS_CHAR)
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Inside the process when subinventory is not null' ) ;
END IF;

            IF NOT Check_SubInv_Exists(p_organization_id =>  p_rev_item_unexp_rec.organization_id
                                     , p_subinventory    => p_revised_item_rec.completion_subinventory
                                       )
            THEN

                l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name ;
                l_token_tbl(2).token_name  := 'COMPLETION_SUBINVENTORY' ;
                l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory ;

                Error_Handler.Add_Error_Token
                (  p_message_name       =>  'BOM_RTG_SUBINV_NAME_INVALID'
                 , p_token_tbl          => l_token_tbl
                 , p_mesg_token_tbl     => l_mesg_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                ) ;

           ELSE

               l_allow_expense_to_asset := fnd_profile.value
                                    ('INV:EXPENSE_TO_ASSET_TRANSFER');


              Get_SubInv_Flag
              (    p_revised_item_id   =>  p_rev_item_unexp_rec.revised_item_id
                ,  p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                ,  x_rest_subinv_code  =>  l_rest_subinv_code
                ,  x_inv_asset_flag    =>  l_inv_asset_flag ) ;


IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Get Sub Inv Flag . . . ');
     error_handler.write_debug('Expense to asset transfer : '||  l_allow_expense_to_asset );
     error_handler.write_debug('Restrict Sub Inv Code : ' || l_rest_subinv_code );
     error_handler.write_debug('Inv Asset Flag : '||  l_inv_asset_flag );

END IF;

              IF l_rest_subinv_code = 'Y' THEN
                  IF l_allow_expense_to_asset = '1' THEN

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before  OPEN c_Restrict_SubInv_Trk');
END IF;
                      OPEN c_Restrict_SubInv_Trk
                          ( p_revised_item_id   =>  p_rev_item_unexp_rec.revised_item_id
                          , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                          , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                      FETCH c_Restrict_SubInv_Trk INTO l_sub_locator_control ;


                      IF c_Restrict_SubInv_Trk%NOTFOUND THEN
                           CLOSE c_Restrict_SubInv_Trk;

                          l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                          l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                          l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                          l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                          Error_Handler.Add_Error_Token
                          (  p_message_name       => 'BOM_RTG_SINV_RSTRCT_EXPASST'
                           , p_token_tbl          => l_token_tbl
                           , p_mesg_token_tbl     => l_mesg_token_tbl
                           , x_mesg_token_tbl     => l_mesg_token_tbl
                          ) ;
                         l_return_status := FND_API.G_RET_STS_ERROR;
                      ELSE
                         CLOSE  c_Restrict_SubInv_Trk;

                      END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_Restrict_SubInv_Trk, the return status is ' ||  l_Return_Status);
END IF;

                ELSE
                   IF l_inv_asset_flag = 'Y' THEN

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before  OPEN c_Restrict_SubInv_Asset');
END IF;

                         OPEN c_Restrict_SubInv_Asset
                         ( p_revised_item_id   =>  p_rev_item_unexp_rec.revised_item_id
                         , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                         , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                         FETCH c_Restrict_SubInv_Asset INTO l_sub_locator_control ;
                         IF c_Restrict_SubInv_Asset%NOTFOUND THEN
                             CLOSE c_Restrict_SubInv_Asset;

                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                            l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                            l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                            Error_Handler.Add_Error_Token
                            (  p_message_name       =>  'BOM_RTG_SINV_RSTRCT_INVASST'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                            ) ;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                         ELSE
                            CLOSE  c_Restrict_SubInv_Asset ;
                         END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_Restrict_SubInv_Asset, the return status is ' ||  l_Return_Status);
END IF;
                   ELSE

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before second  c_Restrict_SubInv_Trk');
END IF;
                      OPEN c_Restrict_SubInv_Trk
                     ( p_revised_item_id   =>  p_rev_item_unexp_rec.revised_item_id
                     , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                     , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                      FETCH c_Restrict_SubInv_Trk INTO  l_sub_locator_control ;
                      IF c_Restrict_SubInv_Trk%NOTFOUND THEN
                          CLOSE c_Restrict_SubInv_Trk;


                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                            l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                            l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                            Error_Handler.Add_Error_Token
                            (  p_message_name       =>  'BOM_RTG_SINV_RSTRCT_NOASST'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                            ) ;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSE
                            CLOSE c_Restrict_SubInv_Trk;
                        END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_Restrict_SubInv_Trk, the return status is '|| l_Return_Status);
END IF;
                  END IF ; -- End of l_inv_asset_flag = 'Y'
               END IF ; -- End of l_allow_expense_to_asset = '1'


          ELSE -- l_rest_subinv_code <> 'Y'
              IF l_allow_expense_to_asset = '1' THEN

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before open c_SubInventory_Tracked');
END IF;
                  OPEN c_SubInventory_Tracked
                     ( p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                     , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                  FETCH c_SubInventory_Tracked INTO l_sub_locator_control ;

                  IF c_SubInventory_Tracked%NOTFOUND THEN
                       CLOSE c_SubInventory_Tracked;

                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                            l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                            l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                            Error_Handler.Add_Error_Token
                            (  p_message_name       => 'BOM_RTG_SINV_NOTRSTRCT_EXPASST'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                            ) ;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                  ELSE
                      CLOSE c_SubInventory_Tracked;
                  END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_SubInventory_Tracked, the return status is '||  l_Return_Status);
END IF;

              ELSE
                  IF l_inv_asset_flag = 'Y' THEN

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before open second c_SubInventory_Asset');
END IF;
                      OPEN c_SubInventory_Asset
                     ( p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                     , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                      FETCH c_SubInventory_Asset INTO l_Sub_Locator_Control;
                      IF c_SubInventory_Asset%NOTFOUND THEN
                           CLOSE c_SubInventory_Asset;

                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME' ;
                            l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                            l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                            Error_Handler.Add_Error_Token
                            (  p_message_name       => 'BOM_RTG_SINV_NOTRSTRCT_ASST'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                             ) ;
                            l_return_status := FND_API.G_RET_STS_ERROR;
                      ELSE
                          CLOSE c_SubInventory_Asset;
                      END IF;
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_SubInventory_Asset, the return status is ' || l_Return_Status);
END IF;
                  ELSE
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Before open  second c_SubInventory_tracked');
END IF;
                   IF p_revised_item_rec.completion_subinventory IS NOT NULL THEN

                       OPEN c_Subinventory_Tracked
                     ( p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                     , p_subinventory      =>  p_revised_item_rec.completion_subinventory);

                       FETCH c_Subinventory_Tracked INTO  l_Sub_Locator_Control;
                       IF c_SubInventory_Tracked%NOTFOUND THEN
                            CLOSE c_Subinventory_Tracked;

                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                            l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  :=  'COMPLETION_SUBINVENTORY';
                            l_token_tbl(2).token_value :=  p_revised_item_rec.completion_subinventory;

                            Error_Handler.Add_Error_Token
                            (  p_message_name       => 'BOM_RTG_SINV_NOTRSTRCT_NOASST'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                            ) ;
                            l_return_status := FND_API.G_RET_STS_ERROR;

                       ELSE
                           CLOSE c_Subinventory_Tracked;
                       END IF;
                   END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After c_Subinventory_Tracked, the return status is '|| l_Return_Status);
END IF;

                  END IF ; -- End of l_inv_asset_flag = 'Y'
              END IF ;  -- End of l_allow_expense_to_asset = '1'
          END IF; -- End of -- l_rest_subinv_code = 'Y'

       END IF ;   -- End of IF NOT Check_SubInv_Exists

    END IF ;

        /*********************************************************************
        -- Added by MK 08/26/2000
        -- Check Completion Locator
        **********************************************************************/

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Performing completion locator. . .') ;
    Error_Handler.Write_Debug('Sub Inv - Loc Control : '|| to_char(l_sub_locator_control)  );
END IF;

    IF (Bom_globals.Get_Caller_Type = BOM_GLOBALS.G_MASS_CHANGE) THEN
                Null;
    Else
        IF  p_control_rec.caller_type <> 'FORM'
	AND p_revised_item_rec.completion_subinventory is not null -- Bug 2871420 added this condition
        AND (( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
              AND NVL(p_rev_item_unexp_rec.completion_locator_id , 0) <>
                  NVL(p_old_rev_item_unexp_rec.completion_locator_id , 0)
              )
             OR (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
			AND  p_revised_item_rec.completion_subinventory is not null
                       AND p_revised_item_rec.completion_subinventory <> FND_API.G_MISS_CHAR)
             )
        AND  NOT Check_Locators( p_organization_id => p_rev_item_unexp_rec.organization_id
                               , p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
                               , p_locator_id      => p_rev_item_unexp_rec.completion_locator_id
                               , p_subinventory    => p_revised_item_rec.completion_subinventory )
        THEN

             IF l_locator_control = 4 THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
                    Error_Handler.Add_Error_Token
                      (  p_message_name       => 'BOM_RTG_LOCATOR_REQUIRED'
                       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => l_Token_Tbl
                      );
                END IF;

             ELSIF l_locator_control = 3 THEN
                -- Log the Dynamic locator control message.
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;

                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RTG_LOC_CANNOT_BE_DYNAMIC'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      );
                END IF;
             ELSIF l_locator_control = 2 THEN
                IF  l_item_loc_restricted  = 1 THEN

                    -- if error occured when item_locator_control was
                    -- restrcited

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RTG_ITEM_LOC_RESTRICTED'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                         );
                    END IF;
                ELSE
                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RTG_LOCATOR_NOT_IN_SUBINV'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                         );
                    END IF;
                END IF;
             ELSIF l_locator_control = 1 THEN

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RTG_ITEM_NO_LOC_CONTROL'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                         );
                    END IF;
             END IF;

             l_return_status := FND_API.G_RET_STS_ERROR;

        -- Comment out by MK, already checked in validation for Sub Inv.
        --
        -- ELSIF p_revised_item_rec.completion_location_name IS NOT NULL AND
        --       p_revised_item_rec.completion_subinventory IS NULL
        -- THEN
        --        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        --        THEN
        --        Error_Handler.Add_Error_Token
        --        (  p_message_name       => 'BOM_RTG_LOCATOR_MUST_BE_NULL'
        --         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        --         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        --          , p_Token_Tbl          => l_Token_Tbl
        --         );
        --         END IF;
        --         l_return_status := FND_API.G_RET_STS_ERROR;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('completion locator check  when locator name is not null,the return status is ' ||
                                l_Return_Status);
END IF;

        END IF;  ---end of locator check
    END IF;
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After locator check,the return status is '|| l_Return_Status);
END IF;

        /*********************************************************************
        -- Added by MK 08/26/2000
        -- Check Mixed_Model_Map_Flag for future release

        IF ( p_revised_item_rec.mixed_model_map <> p_old_revised_item_rec.mixed_model_map AND
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
           ) OR
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
           p_revised_item_rec.mixed_model_map = 1
        THEN
            IF NOT Check_Mixed_Model_Map THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name   => 'ENG_MMMF_ALREADY_EXISTS'
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_Token_Tbl      => l_Token_Tbl
                    );
                END IF;
        **********************************************************************/


/*********************************************************************************
** End of Check Entity for New ECO Effectivities and ECO Routing.
** Added by MK on 08/25/2000.
**********************************************************************************/

        --
        --  Check conditionally required attributes here.
        --
        /*********************************************************************
         -- Added by AS on 07/06.
         -- If revised item is unit controlled, the user must enter a
         -- From End Item Unit Number
        **********************************************************************/
        IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
           l_plm_or_erp_change <> 'PLM' AND -- not required for plm
           l_is_item_unit_controlled AND
           p_revised_item_rec.from_end_item_unit_number IS NULL
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_FROM_UNIT_NUM_REQUIRED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /*********************************************************************
        --
        -- If the user has entered the use_us_plan_name but not given a
        -- use_up_item and the vice-versa then it should get an error.
        --
        **********************************************************************/
        /**** Form allows the user to enter the useup item even when the plan name is
              not chosen.

        IF p_revised_item_rec.use_up_plan_name IS NOT NULL AND
           p_revised_item_rec.use_up_item_name IS NULL     AND
           p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_USE_UP_ITEM_MISSING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF p_revised_item_rec.use_up_plan_name IS NULL     AND
              p_revised_item_rec.use_up_item_name IS NOT NULL AND
              p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_USE_UP_PLAN_MISSING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        ELS

        *** End of Comment */


         IF p_revised_item_rec.use_up_plan_name IS NOT NULL AND
              p_rev_item_unexp_rec.use_up_item_id IS NOT NULL AND
              NOT Validate_Use_Up_Plan
                  (  p_use_up_plan_name => p_revised_item_rec.use_up_plan_name
                   , p_use_up_item_id   => p_rev_item_unexp_rec.use_up_item_id
                   , p_organization_id  => p_rev_item_unexp_rec.organization_id
                   )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_USE_UP_PLANITEM_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- End of check for conditionally required attributes
        --

        IF p_control_rec.caller_type = 'FORM'
        THEN
                l_dup_exists := 0;
                FOR X_CheckDupUnit IN CheckDupUnit LOOP
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name       => 'ENG_UNIT_NUM_DUPLICATE'
                                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Token_Tbl          => l_Token_Tbl
                                 );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END LOOP;

        ELSIF p_control_rec.caller_type <> 'SSWA' THEN -- not required for plm
	-- Peform the following validation only if called thru open interface

                l_dup_exists := 0;
                --
                -- If the user is trying to update the revised item with new values then make sure that
                -- the new values are not creating a duplicate row in the table.
                --
                IF  ( p_revised_item_rec.new_effective_date IS NOT NULL AND
                      p_revised_item_rec.new_effective_date <> FND_API.G_MISS_DATE
                    ) OR
                    ( p_revised_item_rec.updated_revised_item_revision IS NOT NULL AND
                       p_revised_item_rec.updated_revised_item_revision <> FND_API.G_MISS_CHAR
                    )
                THEN
                        FOR X_CheckDupUnit IN CheckDupDateUnit LOOP
                        --
                        -- The message text for this message is:
                        -- The revised item REVISED_ITEM_NAME already exists on ECO ECO_NAME with revision
                        -- NEW_OR_UPDATED_ITEM_REVISION and effective date NEW_OR_UPDATED_EFFECTIVE_DATE
                        -- So the tokens updated_item_revision and effective_date would need to replaced
                        -- depending
                        -- on what is being changed, since the user can change one and then leave the other
                        -- column to default.
                        --
                                SELECT DECODE(p_revised_item_rec.updated_revised_item_revision, NULL,
                                              p_revised_item_rec.new_revised_item_revision,
                                              p_revised_item_rec.updated_revised_item_revision
                                              ),
                                       DECODE(p_revised_item_rec.new_effective_date, NULL,
                                              p_revised_item_rec.start_effective_date,
                                              p_revised_item_rec.new_effective_date
                                              )
                                    INTO l_token_tbl(3).token_value,
                                         l_token_tbl(4).token_value
                                    FROM SYS.DUAL;

                                    l_token_tbl(2).token_name := 'ECO_NAME';
                                    l_token_tbl(2).token_value := p_revised_item_rec.eco_name;

                                    l_token_tbl(3).token_name := 'NEW_OR_UPDATED_ITEM_REVISION';
                                    l_token_tbl(4).token_name := 'NEW_OR_UPDATED_EFFECTIVE_DATE';

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name       => 'ENG_RIT_UPD_ALREADY_EXISTS'
                                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Token_Tbl          => l_Token_Tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        END LOOP;
                 END IF; /* If updating revision or effective date Ends */

          /*********************************************************************
          --
          -- Cannot update an ECO that has
          -- (a process and Approval Status of 'Approval Requested')
          -- or is cancelled or implemented
          --
          *********************************************************************/
          IF ENG_Globals.ECO_Cannot_Update
             (  p_change_notice   => p_revised_item_rec.Eco_Name
             , p_organization_id => p_rev_item_unexp_rec.organization_id
             )
	     AND p_control_rec.caller_type <> 'SSWA'  -- not required for plm
          THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_PROC_UPD_DISALLOWED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;


          /*********************************************************************
          --
          -- Creating a record with status of Cancelled should get an error.
          --
          *********************************************************************/
          IF p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE AND
             p_revised_item_rec.status_type = 5
          THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_STAT_MUST_NOT_BE_CANCL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          /********************************************************************
          --
          -- For Creates, Product Family item cannot be added on an ECO
          --
          *********************************************************************/

          l_product_family := FALSE;

          FOR x_count IN c_CheckItemProductFamily LOOP
                l_product_family := TRUE;
          END LOOP;

          IF p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE AND
             l_product_family
          THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_ADD_PF_ITEM'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        /*********************************************************************
         -- Added by AS on 07/06.
         -- If revised item is unit controlled, no effective date must be
         -- entered
        **********************************************************************/
      -- removed for solving conflicting with unique check in ENGSVIDB.pls
      /*  IF l_is_item_unit_controlled AND
           ((p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
             p_revised_item_rec.start_effective_date IS NOT NULL)
            OR
            (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE AND
             p_revised_item_rec.new_effective_date IS NOT NULL))
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_UNIT_EFFDATE_NULL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

     */
        /*********************************************************************
         -- Added by AS on 07/06.
         -- If revised item is not unit controlled, no unit number must be
         -- entered
        **********************************************************************/
        IF NOT l_is_item_unit_controlled AND
           ((p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
             p_revised_item_rec.from_end_item_unit_number IS NOT NULL)
            OR
            (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE AND
             p_revised_item_rec.new_from_end_item_unit_number IS NOT NULL))
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_DATE_UNIT_NULL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF l_is_item_unit_controlled AND
           p_revised_item_rec.update_wip = 1
        THEN
                /**********************************************************************
                 -- Added by AS on 07/06.
                 -- If revised item is unit controlled, Update_WIP must not be set
                 -- to Yes.
                **********************************************************************/
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ITEM_UNIT_UPDATE_WIP'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => l_Token_Tbl
                        );
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /**********************************************************************
          --
          -- Revised item status cannot be updated to 'scheduled' if ECO has not
          -- been approved
          --
          **********************************************************************/
        IF l_plm_or_erp_change <> 'PLM'  -- not required for plm
	THEN
          l_ECO_approved := 0;
          FOR x_count IN c_CheckECOApproval LOOP
                -- Eco Approved will be set to 1 only if the cursor executes
                -- indicating that the eco is approved.
                l_ECO_approved := 1;
          END LOOP;

          IF p_revised_item_rec.status_type = 4 /* Scheduled */
             AND
             l_ECO_approved <> 1  /* if not approved */
          THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                        l_token_tbl(2).token_name  := 'ECO_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.eco_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_STAT_MUST_NOT_BE_SCHED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
          /*********************************************************************
          --
          -- If the user is trying to update schedule date to NULL by giving a
          -- missing value in the input record then that should get an error.
          -- Check if scheduled_date is being set to null
          --
          **********************************************************************/

          IF p_revised_item_rec.new_effective_date = FND_API.G_MISS_DATE AND
             p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_UPDATE
          THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_SCHED_DATE_NOT_NULL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        END IF; -- End of code executed only if called thru open interface

        /*********************************************************************
        --
        -- Check if the (currently) highest un-implemented revision of the
        -- revised item exists on another ECO - log warning
        --
        *********************************************************************/
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('caller type: ' || p_control_rec.caller_type); END IF;

      IF (p_control_rec.caller_type = 'FORM'
          AND p_revised_item_rec.transaction_type = 'CREATE'
          AND p_control_rec.validation_controller = 'REVISED_ITEM')
         OR
         (p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA')
      THEN
        Pending_High_Rev
        ( p_change_notice   => p_revised_item_rec.eco_name
        , p_organization_id => p_rev_item_unexp_rec.organization_id
        , p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
        , x_change_notice   => l_change_notice
        , x_revision        => l_revision
        );

            --  Modified by MK on 10/27/2000
            --  Warnig is occurred when the current highest un-implemented revision
            --  for the revised item exists on another ECO.
            --
            --  IF l_change_notice IS NOT NULL

            IF l_change_notice <> p_revised_item_rec.eco_name
            THEN
                l_token_tbl.delete;
/* Bug 1492149
  Changed the message ENG_ITEM_HIGH_REV_PENDING to ENG_ECN_REVISION
  As the prior message is misleading
*/

/*
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := l_change_notice;
                l_token_tbl(3).token_name  := 'REVISION';
                l_token_tbl(3).token_value := l_revision;
*/
                l_token_tbl(1).token_name  := 'ENTITY1';
                l_token_tbl(1).token_value := l_revision;
                l_token_tbl(2).token_name  := 'ENTITY2';
                l_token_tbl(2).token_value := l_change_notice;

                --Below change is for bug 8872001. Added item name token to error message
                l_token_tbl(3).token_name  := 'REVISED_ITEM_NAME_ENTITY';
 	              l_token_tbl(3).token_value := p_revised_item_rec.revised_item_name;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_Message_Name       => 'ENG_ECN_REVISION'
                     --  , p_Message_Name       => 'ENG_ITEM_HIGH_REV_PENDING'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
                END IF;
          END IF;
      END IF;

      -- Added by MK on 11/01/2000
      IF p_control_rec.caller_type = 'FORM' OR p_control_rec.caller_type = 'SSWA'
      THEN
           l_assembly_type := p_control_rec.eco_assembly_type ;
      ELSE
           l_assembly_type :=
                ENG_Globals.Get_ECO_Assembly_Type
                (  p_change_notice   => p_revised_item_rec.eco_name
                 , p_organization_id => p_rev_item_unexp_rec.organization_id
                );
      END IF ;

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Get Eco Assembly Type, Assebly Type : '|| to_char(l_assembly_type) );
END IF;

        /********************************************************************
        --
        -- Check if revised item assembly type is compatible with that of the
        -- change order type. Manufacuturing ECO's can only have manufacturing
        -- items.
        --
        *********************************************************************/

        IF  p_control_rec.caller_type <> 'FORM' AND
            p_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE AND
            NOT Compatible_Item_Type
                (  p_assembly_type  => l_assembly_type
                 , p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
                 , p_organization_id => p_rev_item_unexp_rec.organization_id
                )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'ECO_NAME';
                        l_token_tbl(1).token_value :=
                                                p_revised_item_rec.eco_name;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_INCOMPATIBLE_ITEM_TYPE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- Early Scheduled date must be <= Scheduled Date
        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Early effective Date: '
                     || to_char(p_revised_item_rec.earliest_effective_date));
END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Start effective Date: ' ||
                    to_char(p_revised_item_rec.start_effective_date));
END IF;
        IF NOT l_is_item_unit_controlled AND
           ((p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
             trunc(p_revised_item_rec.earliest_effective_date) >
             trunc(p_revised_item_rec.start_effective_date))
            OR
            (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE AND
             trunc(p_revised_item_rec.earliest_effective_date) >
             NVL(trunc(p_revised_item_rec.new_effective_date),
                        p_revised_item_rec.start_effective_date)))
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                p_revised_item_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       =>'ENG_EARLY_SCHED_DATE_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /********************************************************************
        --
        -- If the use_up_plan is given then verify that the schedule_date
        -- for the revised component matches with the inventory_use_up_date
        -- for that plan and item in MRP_System_Items
        -- Similarly if the user is trying to update the schedule_date and
        -- the use_up_item is not null, then check if the new_effective_date
        -- matches the inventory_use_up_date
        --
        *********************************************************************/

        IF p_revised_item_rec.use_up_plan_name IS NOT NULL AND
           p_rev_item_unexp_rec.use_up_item_id IS NOT NULL AND  -- Added by MK on 10/31/00
           p_revised_item_rec.start_effective_date IS NOT NULL AND
           p_revised_item_rec.start_effective_date <> FND_API.G_MISS_DATE AND
           (  p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
              (  p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
                 AND
                 ( p_revised_item_rec.new_effective_date IS NOT NULL AND
                   p_revised_item_rec.new_effective_date <> FND_API.G_MISS_DATE
                  )
               )
            )
        THEN
                l_IsDateValid := FALSE;
                IF p_revised_item_rec.transaction_type=ENG_GLOBALS.G_OPR_CREATE
                THEN
                        l_IsDateValid :=
                        Check_Date
                        (  p_revised_item_id    =>
                           p_rev_item_unexp_rec.use_up_item_id
--                         p_rev_item_unexp_rec.revised_item_id    /*2199507*/
                         , p_organization_id    =>
                           p_rev_item_unexp_rec.organization_id
                         , p_use_up_plan        =>
                           p_revised_item_rec.use_up_plan_name
                         , p_schedule_date      =>
                           p_revised_item_rec.start_effective_date
                         , x_inventory_use_up_date => l_use_up_date
                        );

                ELSE
                        l_IsDateValid :=
                        Check_Date
                        (  p_revised_item_id    =>
                           p_rev_item_unexp_rec.use_up_item_id
--                         p_rev_item_unexp_rec.revised_item_id    /*2199507*/
                         , p_organization_id    =>
                           p_rev_item_unexp_rec.organization_id
                         , p_use_up_plan        =>
                           p_revised_item_rec.use_up_plan_name
                         , p_schedule_date      =>
                           p_revised_item_rec.new_effective_date
                         , x_inventory_use_up_date => l_use_up_date
                        );
                END IF;

                IF l_IsDateValid = FALSE
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                l_token_tbl.delete;
                                l_token_tbl(1).token_name  :=
                                                'REVISED_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name    =>'ENG_SCHD_DATE_NOT_MATCH'
                                 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , p_Token_Tbl       => l_Token_Tbl
                                );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After validation for shedule date, the return status is ' ||
                                l_Return_Status);
END IF;

        END IF;


        /**********************************************************************
        --
        -- Use up item must be either revised item or any of its implemented
        -- components
        --
        ***********************************************************************/

        IF ( ( p_rev_item_unexp_rec.use_up_item_id IS NOT NULL AND
               p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE
             )   OR
             (  p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
                AND
                p_rev_item_unexp_rec.use_up_item_id <>
                NVL(p_old_rev_item_unexp_rec.use_up_item_id, 0)
             )
           ) AND
           p_rev_item_unexp_rec.use_up_item_id <>
           p_rev_item_unexp_rec.revised_item_id AND
           p_rev_item_unexp_rec.use_up_item_id <> FND_API.G_MISS_NUM
        THEN
                l_IsUseUpValid := FALSE;

                FOR CheckItem IN c_CheckUseUpItem
                                 (  p_revised_item_id       =>
                                    p_rev_item_unexp_rec.revised_item_id
                                  , p_alternate_designator  =>
                                    p_revised_item_rec.alternate_bom_code
                                  , p_organization_id       =>
                                    p_rev_item_unexp_rec.organization_id
                                  , p_use_up_item_id        =>
                                    p_rev_item_unexp_rec.use_up_item_id
                                  , p_use_up_date           =>
                                        l_use_up_date
                                  )
                LOOP
                        -- If loop executes then the use-up-item is valid.
                        -- else set the Use_Up_Item invalid variable.

                        l_IsUseUpValid := TRUE;

                END LOOP;

                IF l_IsUseUpValid = FALSE THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                l_token_tbl.delete;
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name    =>'ENG_USE_UP_ITEM_INVALID'
                                 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                );
                        END IF;



                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('After validation for Use Up Item, the return status is '|| l_Return_Status);
END IF;
        END IF;

        /*********************************************************************
        --
        -- Cannot create an alternate if primary bill does not already exist.
        -- and primary routing does not already exist.
        -- Modified by MK on 10/31/2000
        -- Also added Eng_Primary_Bill_Exists check in Rev Comp and
        -- Eng_Primary_Routing_Exists in Rev Op
        **********************************************************************/

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Org Id : ' || to_char(p_rev_item_unexp_rec.organization_id) );
     error_handler.write_debug('Rev Item Id : ' || to_char(p_rev_item_unexp_rec.revised_item_id) );
     error_handler.write_debug('Assem Type  : ' || to_char(l_assembly_type) );
END IF;


        IF p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE AND
           p_revised_item_rec.alternate_bom_code IS NOT NULL       AND
           (    NOT Eng_Primary_Bill_Exists
                ( p_Revised_Item_Id => p_rev_item_unexp_rec.revised_item_id
                , p_Organization_Id => p_rev_item_unexp_rec.organization_id
                , p_assembly_type   => l_assembly_type)
           AND
                NOT Eng_Primary_Routing_Exists
                ( p_revised_Item_Id => p_rev_item_unexp_rec.revised_item_id
                , p_organization_Id => p_rev_item_unexp_rec.organization_id
                , p_assembly_type   => l_assembly_type)
           )
	   AND l_plm_or_erp_change <> 'PLM'
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_ADD_ALTERNATE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_RTG_CANT_ADD_ALTERNATE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );

                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /*********************************************************************
        -- Added by MK on 08/26/2000
        IF p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_CREATE AND
           p_revised_item_rec.alternate_bom_code IS NOT NULL       AND
           NOT Eng_Primary_Routing_Exists
                ( p_revised_Item_Id => p_rev_item_unexp_rec.revised_item_id
                , p_organization_Id => p_rev_item_unexp_rec.organization_id
                , p_assembly_type   => l_assembly_type)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    l_token_tbl.delete;
                    l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                    l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'ENG_RIT_RTG_CANT_ADD_ALTERNATE'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- Added by MK on 08/26/2000
        **********************************************************************/

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of check primary routing and bill, the return status is ' || l_Return_Status);
END IF;


        /*********************************************************************
        --
        -- If revised item is being referenced as pending on another ECO
        -- then log warning
        --
        **********************************************************************/

        IF (p_control_rec.caller_type = 'FORM'
            AND p_revised_item_rec.transaction_type = 'CREATE'
            AND p_control_rec.validation_controller = 'ALTERNATE_BOM_DESIGNATOR')
           OR
           (p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA')
        THEN
                IF Pending_ECO_Hint
                   ( p_Change_Notice    => p_revised_item_rec.eco_name
                   , p_Revised_Item_Id  => p_rev_item_unexp_rec.revised_item_id
                   , p_organization_id  => p_rev_item_unexp_rec.organization_id
                   )
                THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ENG_ITEM_IN_OTHER_ECOS Warning . . .'); END IF;

                        l_token_tbl.delete;

                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ITEM_IN_OTHER_ECOS'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
                END IF;
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('checked - if item is on other ECOs'); END IF;


        /*********************************************************************
        --
        -- Revised item scheduled_date cannot be greater than the disable date
        -- of any of its revised components with acd_type of Add or Change
        -- or if the ECO has an approval status of 'Approval Requested'
        --
        -- The below condition was modified by MK on 11/13/00
        **********************************************************************/
        IF p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
           AND
           (  -- (p_control_rec.caller_type = 'FORM' AND
              --  p_control_rec.validation_controller = 'SCHEDULED_DATE')
              --  OR
              -- (p_control_rec.caller_type = 'OI' AND
              NVL( p_revised_item_rec.new_effective_date,
                   p_revised_item_rec.start_effective_date
                  ) <> p_old_revised_item_rec.start_effective_date
            )
        THEN
                l_result := Check_Reschedule
                            (  p_revised_item_rec   => p_revised_item_rec
                             , p_rev_item_unexp_rec => p_rev_item_unexp_rec
                             );
                IF l_result = 1 THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            l_token_tbl.delete;
                            l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                            l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                            l_token_tbl(2).token_name  := 'ECO_NAME';
                            l_token_tbl(2).token_value :=
                                        p_revised_item_rec.eco_name;
                            Error_Handler.Add_Error_Token
                            (  p_Message_Name   => 'ENG_ITEM_RESCHED_ECO_APPREQ'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl              => l_Token_Tbl
                             );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSIF l_result = 2 THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            l_token_tbl.delete;
                            l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                            l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;

                            Error_Handler.Add_Error_Token
                            (  p_Message_Name=> 'ENG_ITEM_RESCHED_COMP_DISABLED'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl              => l_Token_Tbl
                             );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of new revised item, the return status is ' ||  l_Return_Status);
END IF;

        /*********************************************************************
        -- Added by MK on 09/01/2000
        -- Revised item scheduled_date cannot be greater than the disable date
        -- of any of its revised operations with acd_type of Add or Change
        -- Modified below condition by MK on 11/13/00
        **********************************************************************/
        IF p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE
           AND
           (  -- (p_control_rec.caller_type = 'FORM' AND
              --  p_control_rec.validation_controller = 'SCHEDULED_DATE')
              -- OR
              -- (p_control_rec.caller_type = 'OI' AND
             NVL( p_revised_item_rec.new_effective_date,
                 p_revised_item_rec.start_effective_date
                 ) <> p_old_revised_item_rec.start_effective_date
           )
        THEN
                IF NOT Check_Rtg_Reschedule
                            (  p_revised_item_rec   => p_revised_item_rec
                             , p_rev_item_unexp_rec => p_rev_item_unexp_rec
                             )
                THEN
                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                            (  p_Message_Name=> 'ENG_ITEM_RESCHED_OP_DISABLED'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                             );

                     END IF;
                     l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END IF;
        -- Added by MK on 09/01/2000
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of transaction type and call type chceck, the return status is '||
                                l_Return_Status);
END IF;



        /*********************************************************************
        --
        -- Revised item status_type cannot change to 'Open', 'Hold', 'Released',
        -- 'Scheduled' if ECO status is not 'Open'
        --
        **********************************************************************/

        IF  p_control_rec.caller_type <> 'FORM' AND
            (( p_revised_item_rec.transaction_type=ENG_Globals.G_OPR_UPDATE AND
               NVL( p_revised_item_rec.status_type, 0) <>
                    p_old_revised_item_rec.status_type
              )
            )
           AND
           NOT ECO_Open
               (  p_change_notice   => p_revised_item_rec.eco_name
                , p_organization_id => p_rev_item_unexp_rec.organization_id
                )
           AND
           p_revised_item_rec.status_type IN (1,2,4,7)
	   AND p_control_rec.caller_type <> 'SSWA'
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                        l_token_tbl(2).token_name  := 'STATUS_TYPE';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.status_type;
                        l_token_tbl(3).token_name  := 'ECO_NAME';
                        l_token_tbl(3).token_value := p_revised_item_rec.eco_name;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_STAT_ECO_NOT_OPEN'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl);
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of call type check for form, the return status is ' ||
                                l_Return_Status);
END IF;


        /*******************************************************************
        --
        -- If creates, then the revised item status type must be the same
        -- as the status type of the ECO. This excludes ECO status of
        -- cancel because in that case ECO is not updateable.
        --
        ********************************************************************/
        IF p_control_rec.caller_type <> 'FORM' AND
           p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_CREATE
	   AND l_plm_or_erp_change = 'ERP'          -- Added for bug 3618676
        THEN
                BEGIN
                        SELECT 1
                          INTO l_result
                          FROM eng_engineering_changes
                         WHERE change_notice   = p_revised_item_rec.eco_name
                           AND organization_id =
                                        p_rev_item_unexp_rec.organization_id
                           AND status_type = p_revised_item_rec.status_type;


                        --
                        -- if no exceptions are raised then the status
                        -- type match. Other wise it is an error.
                        --
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                                IF FND_MSG_PUB.Check_Msg_Level
                                   (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                                  l_token_tbl.delete;
                                  Error_Handler.Add_Error_Token
                                  ( p_Message_Name    =>
                                                 'ENG_RIT_CREATE_STAT_INVALID'
                                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                   );
                                END IF;
                                l_return_status := FND_API.G_RET_STS_ERROR;
                END;
        END IF;
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of check call type, the return status is '|| l_Return_Status);
END IF;


        /*********************************************************************
        --
        -- Revised item status_type cannot change if ECO status_type
        -- is set to 'Approval Requested'
        --
        **********************************************************************/

        IF  p_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE AND
            NVL(p_revised_item_rec.status_type, 0) <>
                p_old_revised_item_rec.status_type
            AND p_control_rec.caller_type <> 'SSWA'
	    AND
            ECO_Approval_Requested
            (  p_change_notice => p_revised_item_rec.eco_name
             , p_organization_id => p_rev_item_unexp_rec.organization_id
             )

        THEN
               l_token_tbl.delete;
               l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
               l_token_tbl(1).token_value :=
                                   p_revised_item_rec.revised_item_name;
               l_token_tbl(2).token_name  := 'STATUS_TYPE';
               l_token_tbl(2).token_value :=
                                   p_revised_item_rec.status_type;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_STAT_ECO_APPREQ'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('checked - is status updateable'); END IF;

        -- Cannot have new revision for alternate bill item

        /*********************************************************************
        -- Comment out by MK on 02/15/2001
        -- No longer used. Instead of this validation, Added new the new
        -- validation
        FOR alt IN c_GetAlternateDesignator
        LOOP
                l_alternate_bom_designator :=
                        alt.alternate_bom_designator;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('alternate: ' || l_alternate_bom_designator); END IF;
        END LOOP;

        IF l_alternate_bom_designator IS NOT NULL AND
           (p_revised_item_rec.alternate_bom_code <>
            l_alternate_bom_designator
            ) AND
            p_revised_item_rec.transaction_type = Eng_globals.G_OPR_UPDATE
        THEN
                l_token_tbl.DELETE;
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ALT_DESG_NOT_UPDATEABLE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        **********************************************************************/

        l_token_tbl.delete;
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;


        IF p_revised_item_rec.new_revised_item_revision IS NOT NULL AND
           p_revised_item_rec.alternate_bom_code IS NOT NULL AND
           p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_CREATE
           AND l_plm_or_erp_change <> 'PLM'
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_HAVE_REVISION'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_UPDATE AND
              p_revised_item_rec.alternate_bom_code IS NOT NULL AND
              p_revised_item_rec.updated_revised_item_revision IS NOT NULL
              AND l_plm_or_erp_change <> 'PLM'
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => 'ENG_CANNOT_HAVE_REVISION'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('After checking item  revision is null when alt code is not null, the return status is ' || l_return_status );
END IF;


        -- Revised Item must have a current (implemented) revision

        l_current_item_revision := Get_Current_Item_Revision
           (  p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
            , p_organization_id => p_rev_item_unexp_rec.organization_id
            , p_revision_date   => SYSDATE
            );
        IF l_current_item_revision IS NULL AND
           p_Revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ITEM_NO_CURR_REV'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('checked - is there current item rev. for item'); END IF;

        l_token_tbl.delete;
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;

        /*********************************************************************
        --
        -- Added by AS on 09/13/99.
        -- Fixed bug 902423 in business object APIs also.
        -- Cannot enter a revision that is equal to CURRENT revision if
        -- profile ENG: Require Revised Item New Revision is set to Yes.
        **********************************************************************/

        IF  l_new_rev_required = 1 AND
            (( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
              p_revised_item_rec.new_revised_item_revision = l_current_item_revision)
             OR
             ( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE AND
               p_revised_item_rec.updated_revised_item_revision = l_current_item_revision))
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ITEM_REV_NOT_EQ_CURR_REV'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of validating revision, the return status is ' || l_Return_Status);
END IF;

        /*********************************************************************
        --
        -- if the operation is create, the check new_revised_item_rev
        -- else check updated_revised_item_revision
        --
        **********************************************************************/

        IF ( p_revised_item_rec.updated_revised_item_revision <>
             p_old_revised_item_rec.new_revised_item_revision AND
             p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
           ) OR
           (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
            p_revised_item_rec.new_revised_item_revision IS NOT NULL)
        THEN

            -- 11.5.10E
            -- Using from revision instead of the current revision in case
            -- of PLM.
            IF (l_plm_or_erp_change = 'PLM' AND
                p_revised_item_rec.from_item_revision IS NOT NULL AND
                p_revised_item_rec.from_item_revision <> FND_API.G_MISS_CHAR)
            THEN
              l_from_revision := p_revised_item_rec.from_item_revision;
              l_message_name := 'ENG_NEW_ITEM_REV_NOT_VALID';
            ELSE
              l_from_revision := Get_Current_Item_Revision
                                  ( p_revised_item_id => p_rev_item_unexp_rec.revised_item_id
                                  , p_organization_id => p_rev_item_unexp_rec.organization_id
                                  , p_revision_date   => SYSDATE
                                   );
              l_message_name := 'ENG_NEW_ITEM_REV_NOT_CURR';
            END IF;

                --
                -- if the operation is create, the check new_revised_item_rev
                -- else check updated_revised_item_revision
                --

            IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
            THEN
                l_new_revision_status :=
                Validate_New_Item_Revision
                (  p_revised_item_id    => p_rev_item_unexp_rec.revised_item_id
                , p_organization_id     => p_rev_item_unexp_rec.organization_id
                , p_from_revision       => l_from_revision
                , p_new_item_revision   =>
                                p_revised_item_rec.new_revised_item_revision
                , p_revised_item_sequence_id    =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                , x_change_notice       => l_change_notice
                );
		if ((l_new_revision_status = 2) and (l_change_notice =  p_revised_item_rec.eco_name)
		and p_control_rec.caller_type = 'FORM' -- Added for bug 3432944
		-- Skipping the validation of revision of a revised item when craeted using form, since
		-- it is done at form commit.
		) then
			l_new_revision_status := 0;
		end if;
            ELSE /* If Update, pass updated_revised_item_revision */
                  l_new_revision_status :=
                Validate_New_Item_Revision
                (  p_revised_item_id    => p_rev_item_unexp_rec.revised_item_id
                , p_organization_id     => p_rev_item_unexp_rec.organization_id
                , p_from_revision       => l_from_revision
                , p_new_item_revision   =>
                        p_revised_item_rec.updated_revised_item_revision
                , p_revised_item_sequence_id    =>
                        p_rev_item_unexp_rec.revised_item_sequence_id
                , x_change_notice       => l_change_notice
                );
            END IF;

            IF l_new_revision_status = 1
            THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( --p_Message_Name  => 'ENG_NEW_ITEM_REV_NOT_CURR'
                                  p_Message_Name   => l_message_name
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl      => l_Token_Tbl);
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF l_new_revision_status = 2
            THEN
                        l_token_tbl.delete;

                 -- Added by MK on 11/05/00
                 IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                 THEN
                        l_token_tbl(1).token_name  := 'NEW_UPD_ITEM_REVISION';
                        l_token_tbl(1).token_value := p_revised_item_rec.new_revised_item_revision;
                 ELSE
                        l_token_tbl(1).token_name  := 'NEW_UPD_ITEM_REVISION';
                        l_token_tbl(1).token_value := p_revised_item_rec.updated_revised_item_revision ;
                 END IF ;


                        l_token_tbl(2).token_name :=  'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value := p_revised_item_rec.revised_item_name;

                        l_token_tbl(3).token_name := 'ECO_NAME';
                        l_token_tbl(3).token_value := l_change_notice;
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name   => 'ENG_NEW_ITEM_REV_EXISTS'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_token_tbl      => l_token_tbl
                                );
                        END IF;

                        l_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF l_new_revision_status = 3
            THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name   => 'ENG_NEW_ITEM_REV_IMPL'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('checked - is new item revision valid'); END IF;

        -- Changes for bug 3618662
	IF Bom_Globals.Get_Debug = 'Y'
	THEN
		Error_Handler.Write_Debug('Validate if the revisions and effectivity dates in ascending order. . . . ');
        END IF;

        IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
	      AND p_revised_item_rec.new_revised_item_revision IS NOT NULL
	      AND p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA')
        THEN
		l_is_revision_invalid := High_Date_Low_Revision (
			    p_revised_item_id	=> p_rev_item_unexp_rec.revised_item_id
			  , p_organization_id	=> p_rev_item_unexp_rec.organization_id
			  , p_new_item_revision	=> p_revised_item_rec.new_revised_item_revision
			  , p_scheduled_date	=> p_revised_item_rec.Start_Effective_Date
			  , p_rev_item_seq_id	=> p_rev_item_unexp_rec.revised_item_sequence_id);
	ELSIF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
	       AND p_revised_item_rec.updated_revised_item_revision IS NOT NULL
	       AND ((p_revised_item_rec.new_revised_item_revision IS NOT NULL
	             AND p_revised_item_rec.updated_revised_item_revision <> p_revised_item_rec.new_revised_item_revision)
		    OR (p_revised_item_rec.new_revised_item_revision IS NULL))
	       AND p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA')
	THEN
		l_is_revision_invalid := High_Date_Low_Revision (
			    p_revised_item_id	=> p_rev_item_unexp_rec.revised_item_id
			  , p_organization_id	=> p_rev_item_unexp_rec.organization_id
			  , p_new_item_revision	=> p_revised_item_rec.updated_revised_item_revision
			  , p_scheduled_date	=> NVL(p_revised_item_rec.New_Effective_Date, p_revised_item_rec.Start_Effective_Date)
			  , p_rev_item_seq_id	=> p_rev_item_unexp_rec.revised_item_sequence_id);
	END IF;

	IF l_is_revision_invalid = 1
	THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
			l_Token_Tbl.delete;
                            Error_Handler.Add_Error_Token
                            (  p_Message_Name   => 'ENG_REVISION_ORDER'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                            );
                    END IF;
                    l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
        IF Bom_Globals.Get_Debug = 'Y'
	THEN
	Error_Handler.Write_Debug('End of validation of revisions and effectivity dates in ascending order.'
	||' The return status is ' || l_Return_Status);
        END IF;
	-- End changes for bug 3618662

        -- 11.5.10E
        -- The scheduled date must be greater than the effectivity date of the from revision
        IF (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
	      AND p_revised_item_rec.new_revised_item_revision IS NULL
	      AND p_control_rec.caller_type <> 'FORM' AND p_control_rec.caller_type <> 'SSWA'
              AND p_revised_item_rec.from_item_revision IS NOT NULL
              AND p_revised_item_rec.from_item_revision <> FND_API.G_MISS_CHAR)
        THEN
          l_is_scheduled_date_invalid := Scheduled_Date_From_Revision (
			    p_revised_item_id    => p_rev_item_unexp_rec.revised_item_id
			  , p_organization_id    => p_rev_item_unexp_rec.organization_id
			  , p_from_item_revision => p_revised_item_rec.from_item_revision
			  , p_scheduled_date     => p_revised_item_rec.Start_Effective_Date
			  , p_rev_item_seq_id    => p_rev_item_unexp_rec.revised_item_sequence_id);

          IF l_is_scheduled_date_invalid = 1
          THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              Error_Handler.Add_Error_Token
                  (  p_Message_Name   => 'ENG_INVALID_SCHED_DATE'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_Token_Tbl      => l_Token_Tbl
                   );
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        END IF;

-- Fix for bug 3577967
  /*********************************************************************
          --  Bug No:3577967
          -- If the user is trying to  add Revised Items to the ECO and the Catalogue Catagory associated at the Subject Level
	  -- to the header type of the ECO is not same as that of the Revised items the item should not get added as revised item.
          --
   **********************************************************************/
   /* Bug 7678438 : The below code is getting executed only for ERP not for PLM
      and causing performance problem.
      However, as per the comments the below code is required only for PLM.

   IF p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND p_control_rec.caller_type <> 'SSWA'
   THEN
   IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Verifying the subject level security for PLM ' );
   END IF;
   validate_rev_items_for_sub(
                 p_change_notice     => p_revised_item_rec.eco_name
                ,p_inventory_item_id => p_rev_item_unexp_rec.revised_item_id
                ,p_org_id            => p_rev_item_unexp_rec.organization_id
                ,x_ret_Value         => l_ret_Value);

   IF (l_ret_Value = FALSE)   THEN
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
        l_token_tbl(2).token_name  := 'ECO_NAME';
        l_token_tbl(2).token_value :=  p_revised_item_rec.eco_name;
        Error_Handler.Add_Error_Token
             (  p_Message_Name   => 'ENG_REV_ITEM_SUB_DIFF'
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , p_Token_Tbl      => l_Token_Tbl
             );
       l_return_status :=FND_API.G_RET_STS_ERROR;
   END IF;
   END IF;  */
    --  Done validating entity
IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('End of validating entity, the return status is ' || l_Return_Status);
END IF;

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Entity Validation) ' ||
                          substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_err_text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
        END IF;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Entity;


/******************************************************************************
* Function      : Get_Approval_Status (Local function)
* Parameters    : Revised item id
*                 Organization Id
* Returns       : The Approval Status of the item.
******************************************************************************/

FUNCTION Get_Approval_Status
(  p_item_id     IN    NUMBER,
   p_org_id      IN    NUMBER)
RETURN VARCHAR2 IS
    l_approval_status  VARCHAR2(30);

    CURSOR c_approval_status IS
    SELECT nvl(approval_status,'A')
    FROM MTL_SYSTEM_ITEMS_B
    WHERE inventory_item_id = p_item_id
    AND   organization_id   = p_org_id;
BEGIN
    OPEN c_approval_status;
    FETCH c_approval_status INTO l_approval_status;
    CLOSE c_approval_status;
    RETURN l_approval_status;
END Get_Approval_Status;


--  Procedure Attributes
/****************************************************************************
* Procedure     : Check_Attributes
* Parameters IN : Revised Item Exposed Column record
*                 Revised Item Unexposed Column record
*                 Old Revised Item Exposed Column record
*                 Old Revised Item unexposed column record
* Parameters OUT: Return Status
*                 Mesg Token Table
* Purpose       : Check_Attrbibutes procedure will validate every revised item
*                 attrbiute in its entirety.
*****************************************************************************/
PROCEDURE Check_Attributes
(  x_return_status              OUT  NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_old_revised_item_rec       IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_old_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
)
IS
   l_err_text              VARCHAR2(2000) := NULL;
   l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
   l_Token_Tbl             Error_Handler.Token_Tbl_Type;

   -- Added by MK on 02/15/2001
   -- to validate alternate designator.
   CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                              p_organization_id    NUMBER ) IS
   SELECT 'Invalid Alaternatae'
   FROM   SYS.DUAL
   WHERE  NOT EXISTS ( SELECT NULL
                       FROM bom_alternate_designators
                       WHERE alternate_designator_code = p_alt_designator
                       AND organization_id = p_organization_id
                     ) ;


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within Revised Item Check Attributes . . .'); END IF;

    -- Set revised item token name and value.

    l_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
    l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

    --  Validate revised_item attributes

    IF  p_revised_item_rec.status_type IS NOT NULL AND
        (   p_revised_item_rec.status_type <>
            p_old_revised_item_rec.status_type OR
            p_old_revised_item_rec.status_type IS NULL )
    THEN
        IF NOT ENG_Validate.Status_Type(p_revised_item_rec.status_type ,
                                        l_err_text ) THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                l_token_tbl(2).token_name  := 'STATUS_TYPE';
                l_token_tbl(2).token_value := p_revised_item_rec.status_type;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_STAT_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl);
           END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Status Type cannot be missing.
        IF p_revised_item_rec.status_type = FND_API.G_MISS_NUM
        THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_STAT_TYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl);
           END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Status Type Validated . . . ' ); END IF;

        --  Creates or Updates of records marked Implemented is not allowed
        IF p_revised_item_rec.status_type = 6
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_STAT_CANNOT_BE_IMPL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        /* Comment out by MK on 12/06/00
        --  This validation is no longer used.
        --  Creates of revised items that are not OPEN is not allowed
        IF p_revised_item_rec.transaction_type = 'CREATE'
           AND
           ( p_revised_item_rec.status_type <> 1 AND
             p_revised_item_rec.status_type <> 4
            )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_CREATE_STAT_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        */   -- Comment out


    END IF;

    IF  p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE AND
        (p_revised_item_rec.from_end_item_unit_number IS NOT NULL
         AND
         p_revised_item_rec.from_end_item_unit_number <> FND_API.G_MISS_CHAR)
    THEN
        IF NOT  ENG_Validate.End_Item_Unit_Number
                ( p_from_end_item_unit_number =>
                        p_revised_item_rec.from_end_item_unit_number
                , p_revised_item_id =>
                        p_rev_item_unexp_rec.revised_item_id
                , x_err_text => l_err_text
                )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                     l_token_tbl(2).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
                     l_token_tbl(2).token_value :=
                                    p_revised_item_rec.from_end_item_unit_number;
                     Error_Handler.Add_Error_Token
                     ( p_Message_Name       => 'ENG_FROM_END_ITEM_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     );
            END IF;
        END IF;
    END IF;

    IF  p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE AND
        (p_revised_item_rec.new_from_end_item_unit_number IS NOT NULL
         AND
         p_revised_item_rec.new_from_end_item_unit_number <> FND_API.G_MISS_CHAR)
    THEN
        IF NOT  ENG_Validate.End_Item_Unit_Number
                ( p_from_end_item_unit_number =>
                        p_revised_item_rec.new_from_end_item_unit_number
                , p_revised_item_id =>
                        p_rev_item_unexp_rec.revised_item_id
                , x_err_text => l_err_text
                )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                     l_token_tbl(2).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
                     l_token_tbl(2).token_value :=
                                    p_revised_item_rec.new_from_end_item_unit_number;
                     Error_Handler.Add_Error_Token
                     ( p_Message_Name       => 'ENG_FROM_END_ITEM_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     );
            END IF;
        END IF;
    END IF;

    IF  p_revised_item_rec.mrp_active IS NOT NULL AND
        (   p_revised_item_rec.mrp_active <>
            p_old_revised_item_rec.mrp_active OR
            p_old_revised_item_rec.mrp_active IS NULL )
    THEN
        IF NOT ENG_Validate.Mrp_Active(p_revised_item_rec.mrp_active ,
                                        l_err_text ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name  := 'MRP_ACTIVE';
                        l_token_tbl(2).token_value :=
                                                p_revised_item_rec.mrp_active;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_MRP_ACTIVE_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
                END IF;

        END IF;
    END IF;

    IF p_revised_item_rec.mrp_active = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_MRP_ACTIVE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
        END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('MRP Active Validated . . .'); END IF;

    IF  p_revised_item_rec.update_wip IS NOT NULL AND
        (   p_revised_item_rec.update_wip <>
            p_old_revised_item_rec.update_wip OR
            p_old_revised_item_rec.update_wip IS NULL )
    THEN
        IF NOT ENG_Validate.Update_Wip(p_revised_item_rec.update_wip ,
                                        l_err_text ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                        l_token_tbl(2).token_name  := 'UPDATE_WIP';
                        l_token_tbl(2).token_value :=
                                                p_revised_item_rec.update_wip;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_UPDATE_WIP_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                        );
             END IF;
        END IF;
    END IF;

    IF p_revised_item_rec.update_wip = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_UPDATE_WIP_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
        END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Update WIP Validated . . .'); END IF;

    IF  p_revised_item_rec.use_up_plan_name IS NOT NULL AND
        (   p_revised_item_rec.use_up_plan_name <>
            p_old_revised_item_rec.use_up_plan_name OR
            p_old_revised_item_rec.use_up_plan_name IS NULL )
    THEN
        IF NOT ENG_Validate.Use_Up_Plan_Name
                        (  p_revised_item_rec.use_up_plan_name
                         , p_rev_item_unexp_rec.organization_id
                         , l_err_text )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        -- If the function returns with an error then
                        -- l_err_text will carry the message_name to be
                        -- displayed.
                        l_token_tbl(1).token_name  := 'USE_UP_PLAN_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.use_up_plan_name;

                        IF l_err_text = 'ENG_USE_UP_PLAN_INVALID'
                        THEN
                           l_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                           l_token_tbl(2).token_value :=
                                        p_revised_item_rec.organization_code;
                        ELSIF l_err_text = 'ENG_DATA_COMPL_DATE_INVALID' OR
                              l_err_text = 'ENG_PLAN_COMPL_DATE_INVALID'
                        THEN
                           l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                           l_token_tbl(2).token_value :=
                                        p_revised_item_rec.revised_item_name;
                        END IF;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                         );
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Use_Up_Plan validation returned with an error ' ||
                              l_err_text);
END IF;
                END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_revised_item_rec.disposition_type IS NOT NULL AND
        (   p_revised_item_rec.disposition_type <>
            p_old_revised_item_rec.disposition_type OR
            p_old_revised_item_rec.disposition_type IS NULL )
    THEN
        IF NOT ENG_Validate.Disposition_Type
                (  p_revised_item_rec.disposition_type
                 , l_err_text )
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.revised_item_name;
                        l_token_tbl(2).token_name  := 'DISPOSITION_TYPE';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.disposition_type;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => 'ENG_DISPOSITION_TYPE_INVALID'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                         );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_revised_item_rec.disposition_type = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             Error_Handler.Add_Error_Token
             (  p_Message_Name    => 'ENG_DISPOSITION_TYPE_MISSING'
              , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
              , p_Token_Tbl       => l_Token_Tbl
              );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


--begin bug 16340624
 IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('Validating transfer or copy parameter . . . ' );
           END IF;

          IF p_revised_item_rec.transfer_or_copy IS NOT NULL AND
             p_revised_item_rec.transfer_or_copy <> FND_API.G_MISS_CHAR AND
             p_revised_item_rec.transfer_or_copy NOT IN ('T', 'C')
           THEN
            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
            l_token_tbl(2).token_name  := 'ECO_NAME';
            l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
            l_token_tbl(3).token_name  := 'ORG_CODE';
            l_token_tbl(3).token_value := p_revised_item_rec.organization_code;



              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_XFR_CPY_INVALID'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('No dependent transfer/copy parameter can be set when transfer or copy parameter is not set. . . ' );
           END IF;

  IF (
              (
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               AND (p_revised_item_rec.transfer_or_copy IS NULL OR
                   p_revised_item_rec.transfer_or_copy = FND_API.G_MISS_CHAR)
              )
              OR
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
               AND (p_revised_item_rec.transfer_or_copy IS NULL OR
                   p_revised_item_rec.transfer_or_copy = FND_API.G_MISS_CHAR)
               AND (p_old_revised_item_rec.transfer_or_copy IS NULL OR
                   p_old_revised_item_rec.transfer_or_copy =
FND_API.G_MISS_CHAR)
               )
              )
              AND
               (p_revised_item_rec.transfer_or_copy_item = 1 OR
                p_revised_item_rec.transfer_or_copy_bill = 1 OR
                p_revised_item_rec.transfer_or_copy_routing = 1
               )
              )
           THEN
            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
            l_token_tbl(2).token_name  := 'ECO_NAME';
            l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
            l_token_tbl(3).token_name  := 'ORG_CODE';
            l_token_tbl(3).token_value := p_revised_item_rec.organization_code;
 Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_XFR_CPY_ERROR'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('Checking dependent parameters for transfer/copy item. . . ' );
           END IF;

          IF (
               (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                AND (p_revised_item_rec.transfer_or_copy = 'T' OR
p_revised_item_rec.transfer_or_copy = 'C' ))
            OR (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
                AND ((p_revised_item_rec.transfer_or_copy = 'T'
                     OR (p_revised_item_rec.transfer_or_copy is NULL
                         AND p_old_revised_item_rec.transfer_or_copy = 'T')
                     )
                                 OR
                                 (p_revised_item_rec.transfer_or_copy = 'C'
                     OR (p_revised_item_rec.transfer_or_copy is NULL
                         AND p_old_revised_item_rec.transfer_or_copy = 'C')
                     )
                                 )
                )
             )
           THEN
 IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating selection option. . . '
);
           END IF;

           IF p_revised_item_rec.selection_option IS NOT NULL AND
               p_revised_item_rec.selection_option <> FND_API.G_MISS_NUM AND
               p_revised_item_rec.selection_option NOT IN (1, 2, 3)
           THEN
              l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
              l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
              l_token_tbl(2).token_name  := 'ECO_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
              l_token_tbl(3).token_name  := 'ORG_CODE';
              l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;

              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_SEL_CODE_INVALID'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating transfer/copy item option. . . ' );
           END IF;
  IF p_revised_item_rec.transfer_or_copy_item IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_item <> FND_API.G_MISS_NUM AND
              p_revised_item_rec.transfer_or_copy_item NOT IN (1, 2)
           THEN
              l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
              l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
              l_token_tbl(2).token_name  := 'ECO_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
              l_token_tbl(3).token_name  := 'ORG_CODE';
              l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;
              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_XFR_ITM_INVALID'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

          IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating transfer/copy bill option. . . ' );
           END IF;

           IF p_revised_item_rec.transfer_or_copy_bill IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_bill <> FND_API.G_MISS_NUM AND
              p_revised_item_rec.transfer_or_copy_bill NOT IN (1, 2)
           THEN
              l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
 l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
              l_token_tbl(2).token_name  := 'ECO_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
              l_token_tbl(3).token_name  := 'ORG_CODE';
              l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;
              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_XFR_BIL_INVALID'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;


           IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating transfer/copy routing option. . . ' );
           END IF;

           IF p_revised_item_rec.transfer_or_copy_routing IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_routing <> FND_API.G_MISS_NUM
AND
              p_revised_item_rec.transfer_or_copy_routing NOT IN (1, 2)
           THEN
              l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
              l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
              l_token_tbl(2).token_name  := 'ECO_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
              l_token_tbl(3).token_name  := 'ORG_CODE';
              l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;
 Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_XFR_RTG_INVALID'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
         END IF; --end of checks common to both transfer and copy flow

         IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating copy specific options. .. ' );
         END IF;
         --start of check specific to only copy flow
         IF (
               (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                AND p_revised_item_rec.transfer_or_copy = 'C' )
            OR (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
                AND (p_revised_item_rec.transfer_or_copy = 'C'
                     OR (p_revised_item_rec.transfer_or_copy is NULL
                         AND p_old_revised_item_rec.transfer_or_copy = 'C')
                     )
                )
             )
           THEN
            IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating copy to item. . . ' );
            END IF;
             IF (
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               AND (p_revised_item_rec.Copy_To_Item IS NULL OR
                   p_revised_item_rec.Copy_To_Item = FND_API.G_MISS_CHAR)
              )
 OR
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
               AND (p_revised_item_rec.Copy_To_Item IS NULL OR
                   p_revised_item_rec.Copy_To_Item = FND_API.G_MISS_CHAR)
               AND (p_old_revised_item_rec.Copy_To_Item IS NULL OR
                   p_old_revised_item_rec.Copy_To_Item = FND_API.G_MISS_CHAR)
               )
              ) THEN
                  l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
            l_token_tbl(2).token_name  := 'ECO_NAME';
            l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
            l_token_tbl(3).token_name  := 'ORG_CODE';
            l_token_tbl(3).token_value := p_revised_item_rec.organization_code;

              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_CPY_ITM_ERROR'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

                  IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating copy to item description.. . ' );
            END IF;
             IF (
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               AND (p_revised_item_rec.Copy_To_Item_Desc IS NULL OR
                   p_revised_item_rec.Copy_To_Item_Desc = FND_API.G_MISS_CHAR)
              )
 OR
              (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
               AND (p_revised_item_rec.Copy_To_Item_Desc IS NULL OR
                   p_revised_item_rec.Copy_To_Item_Desc = FND_API.G_MISS_CHAR)
               AND (p_old_revised_item_rec.Copy_To_Item_Desc IS NULL OR
                   p_old_revised_item_rec.Copy_To_Item_Desc =
FND_API.G_MISS_CHAR)
               )
              ) THEN
                  l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
            l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
            l_token_tbl(2).token_name  := 'ECO_NAME';
            l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
            l_token_tbl(3).token_name  := 'ORG_CODE';
            l_token_tbl(3).token_value := p_revised_item_rec.organization_code;

              Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_CPY_ITM_DESC_ERROR'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

                   IF Bom_Globals.Get_Debug = 'Y'
            THEN Error_Handler.Write_Debug('validating copy to item name        does not already exist in manufacturing. . . ' );
                END IF;
                --no need to do separate validation for bill or routing since
                -- item should not exist in the first place.
 IF p_revised_item_rec.Copy_To_Item IS NOT NULL AND
              p_revised_item_rec.Copy_To_Item <> FND_API.G_MISS_CHAR
            THEN
            declare
               l_dummy VARCHAR2(10) := NULL;
              begin
               select 'Exists' into l_dummy from mtl_system_items_kfv where
eng_item_flag = 'N' and
               concatenated_segments = p_revised_item_rec.Copy_To_Item
               and organization_id = p_rev_item_unexp_rec.organization_id;
                   --mfg item already exists;
                   if (l_dummy is not null) THEN
                   l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                l_token_tbl(3).token_name  := 'ORG_CODE';
                l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;

                Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_MFG_ITM_EXISTS'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
               x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
              exception
               WHEN NO_DATA_FOUND THEN
                --no mfg item found, hence, no issue
                 null;
               WHEN OTHERS THEN
  Error_Handler.Add_Error_Token
                 (  p_message_name       => NULL
                  , p_message_text       => 'ERROR revised item check attributes' ||
                                              SUBSTR(SQLERRM, 1, 30) || ' '
||
                                              TO_CHAR(SQLCODE)
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              end;
            END IF;
         END IF;

         --start of check common to transfer/copy flow
         IF (
               (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                AND (p_revised_item_rec.transfer_or_copy = 'T' OR
p_revised_item_rec.transfer_or_copy = 'C' ))
            OR (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
                AND ((p_revised_item_rec.transfer_or_copy = 'T'
                     OR (p_revised_item_rec.transfer_or_copy is NULL
                         AND p_old_revised_item_rec.transfer_or_copy = 'T')
                     )
                                 OR
                                 (p_revised_item_rec.transfer_or_copy = 'C'
                     OR (p_revised_item_rec.transfer_or_copy is NULL
                         AND p_old_revised_item_rec.transfer_or_copy = 'C')
                     )
                                 )
                )
             )
           THEN

           IF p_revised_item_rec.transfer_or_copy_item IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_item <> FND_API.G_MISS_NUM AND
              p_revised_item_rec.transfer_or_copy_item = 1
           THEN
              IF Bom_Globals.Get_Debug = 'Y'
               THEN Error_Handler.Write_Debug('Validating eng item exists as transfer_o
r_copy_item is set . . . ' );
              END IF;
              declare
               l_dummy VARCHAR2(10);
              begin
               select 'Exists' into l_dummy from mtl_system_items_b where
eng_item_flag = 'Y' and
               inventory_item_id = p_rev_item_unexp_rec.revised_item_id
               and organization_id = p_rev_item_unexp_rec.organization_id;
              exception
               WHEN NO_DATA_FOUND THEN
                --no eng item found
                l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                l_token_tbl(3).token_name  := 'ORG_CODE';
                l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;

                Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_NO_ENG_ITEM'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
 x_return_status := FND_API.G_RET_STS_ERROR;
               WHEN OTHERS THEN
                Error_Handler.Add_Error_Token
                 (  p_message_name       => NULL
                  , p_message_text       => 'ERROR revised item check attributes' ||
                                              SUBSTR(SQLERRM, 1, 30) || ' '
||
                                              TO_CHAR(SQLCODE)
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              end;
           END IF;


           IF p_revised_item_rec.transfer_or_copy_bill IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_bill <> FND_API.G_MISS_NUM AND
              p_revised_item_rec.transfer_or_copy_bill = 1
           THEN
              IF Bom_Globals.Get_Debug = 'Y'
               THEN Error_Handler.Write_Debug('Validating if eng bill exists as transfer_or_copy_bill is set . . . ' );
              END IF;
              declare
               l_dummy VARCHAR2(10);
              begin
               IF p_revised_item_rec.alternate_selection_code IS NOT NULL AND
                  p_revised_item_rec.alternate_selection_code <>
FND_API.G_MISS_NUM
               THEN
                IF p_revised_item_rec.alternate_selection_code = 1  THEN
                select 'Exists' into l_dummy  from sys.dual where exists (
select 1
                 from bom_structures_b where assembly_type = 2  and
                 assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id);

                ELSIF p_revised_item_rec.alternate_selection_code = 2  THEN
                 select 'Exists' into l_dummy from bom_structures_b where
assembly_type = 2
                 and assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id
                 and alternate_bom_designator is null;

                ELSIF p_revised_item_rec.alternate_selection_code = 3 THEN
                 select 'Exists' into l_dummy from bom_structures_b where
assembly_type = 2
                 and assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id
                 and alternate_bom_designator =
p_revised_item_rec.Alternate_Bom_Code;

                ELSE
                  --alternate_selection_code is invalid
                  l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                  l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                  l_token_tbl(2).token_name  := 'ECO_NAME';
                  l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                  l_token_tbl(3).token_name  := 'ORG_CODE';
                  l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;
                   Error_Handler.Add_Error_Token
                   (  p_message_name       => 'ENG_ALT_CODE_INVALID'
                    , p_token_tbl          => l_token_tbl
                    , p_mesg_token_tbl     => l_mesg_token_tbl
                    , x_mesg_token_tbl     => l_mesg_token_tbl
     );
                  x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
              ELSE --if alternate_selection_code is null then at least one eng bill should exist
                 select 'Exists' into l_dummy from sys.dual where exists (
select 1
                 from bom_structures_b where assembly_type = 2  and
                 assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id);
               END IF;
              exception
               WHEN NO_DATA_FOUND THEN
                --no eng item found
                l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                l_token_tbl(3).token_name  := 'ORG_CODE';
                l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;

               --an engineering bill does not exist for the given choice of alternate_selection_code
               -- and alternate_bom_code
                Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_NO_ENG_BIL'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
               WHEN OTHERS THEN
 Error_Handler.Add_Error_Token
                 (  p_message_name       => NULL
                  , p_message_text       => 'ERROR revised item check attributes' ||
                                              SUBSTR(SQLERRM, 1, 30) || ' '
||
                                              TO_CHAR(SQLCODE)
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              end;
           END IF;

           IF p_revised_item_rec.transfer_or_copy_routing IS NOT NULL AND
              p_revised_item_rec.transfer_or_copy_routing <> FND_API.G_MISS_NUM
AND
              p_revised_item_rec.transfer_or_copy_routing = 1
           THEN
              IF Bom_Globals.Get_Debug = 'Y'
               THEN Error_Handler.Write_Debug('Validating if eng routing exists as transfer_or_copy_routing is set . . . ' );
              END IF;
              declare
               l_dummy VARCHAR2(10);
              begin
               IF p_revised_item_rec.alternate_selection_code IS NOT NULL AND
                  p_revised_item_rec.alternate_selection_code <>
FND_API.G_MISS_NUM
               THEN
                IF p_revised_item_rec.alternate_selection_code = 1  THEN
                 select 'Exists' into l_dummy from sys.dual where exists (select
1 from bom_operational_routings where routing_type = 2  and
                 assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id);
 ELSIF p_revised_item_rec.alternate_selection_code = 2  THEN
                 select 'Exists' into l_dummy from bom_operational_routings
where routing_type = 2
                 and assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id
                 and alternate_routing_designator is null;

                ELSIF p_revised_item_rec.alternate_selection_code = 3 THEN
                 select 'Exists' into l_dummy from bom_operational_routings
where routing_type = 2
                 and assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id
                 and alternate_routing_designator =
p_revised_item_rec.Alternate_Bom_Code;

                ELSE
                  --alternate_selection_code is invalid
                  l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                  l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                  l_token_tbl(2).token_name  := 'ECO_NAME';
                  l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                  l_token_tbl(3).token_name  := 'ORG_CODE';
                  l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;
                   Error_Handler.Add_Error_Token
                   (  p_message_name       => 'ENG_ALT_CODE_INVALID'
                    , p_token_tbl          => l_token_tbl
                    , p_mesg_token_tbl     => l_mesg_token_tbl
                    , x_mesg_token_tbl     => l_mesg_token_tbl
                   );
                  x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
              ELSE --if alternate_selection_code is null then at least one eng bill should exist
                 select 'Exists' into l_dummy from sys.dual where exists (select
1
               from bom_operational_routings where routing_type = 2  and
                 assembly_item_id = p_rev_item_unexp_rec.revised_item_id
                 and organization_id = p_rev_item_unexp_rec.organization_id);
               END IF;
              exception
               WHEN NO_DATA_FOUND THEN
                --no eng item found
                l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                l_token_tbl(1).token_value :=
p_revised_item_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'ECO_NAME';
                l_token_tbl(2).token_value := p_revised_item_rec.eco_name;
                l_token_tbl(3).token_name  := 'ORG_CODE';
                l_token_tbl(3).token_value :=
p_revised_item_rec.organization_code;

               --an engineering routing does not exist for the given choice of alternate_selection_code
               -- and alternate_bom_code
                Error_Handler.Add_Error_Token
                 (  p_message_name       => 'ENG_NO_ENG_RTG'
                  , p_token_tbl          => l_token_tbl
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
              x_return_status := FND_API.G_RET_STS_ERROR;
               WHEN OTHERS THEN
                Error_Handler.Add_Error_Token
                 (  p_message_name       => NULL
                  , p_message_text       => 'ERROR revised item check attributes' ||
                                              SUBSTR(SQLERRM, 1, 30) || ' '
||
                                              TO_CHAR(SQLCODE)
                  , p_mesg_token_tbl     => l_mesg_token_tbl
                  , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              end;
           END IF;

          END IF; -- transfer/copy common block check end
          -- end of Bug 16340624


    /**********************************************************************
    -- Following Attribute Validations are for ECO Routing or
    -- New ECO Effectivities
    -- Added by MK 08/24/2000
    **********************************************************************/
    -- CTP Flag
    IF p_revised_item_rec.ctp_flag IS NOT NULL AND
       p_revised_item_rec.ctp_flag <> FND_API.G_MISS_NUM AND
       p_revised_item_rec.ctp_flag NOT IN (1,2)
    THEN
        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
        Error_Handler.Add_Error_Token
        (  p_message_name       => 'BOM_RTG_CTP_INVALID'
         , p_token_tbl          => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Eco For Production Added by MK on 10/06/2000
    IF p_revised_item_rec.eco_for_production IS NOT NULL AND
       p_revised_item_rec.eco_for_production <> FND_API.G_MISS_NUM AND
       p_revised_item_rec.eco_for_production NOT IN (1,2)
    THEN
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
        Error_Handler.Add_Error_Token
        (  p_message_name       => 'ENG_RIT_ECO_FOR_PROD_INVALID'
         , p_token_tbl          => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Missing Eco For Production Added by MK on 10/06/2000
    IF p_revised_item_rec.eco_for_production = FND_API.G_MISS_NUM AND
       p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_ECO_FOR_PROD_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
        END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /* Comment Out by MK Flow Routing is not supported in Current Rel
    IF p_revised_item_rec.mixed_model_map_flag IS NOT NULL AND
       p_revised_item_rec.mixed_model_map_flag <> FND_API.G_MISS_NUM AND
       p_revised_item_rec.mixed_model_map_flag NOT IN (1,2)
    THEN
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value :=  p_revised_item_rec.revised_item_name;
        l_token_tbl(2).token_name  := 'MODEL_MAP_FLAG';
        l_token_tbl(2).token_value :=  p_revised_item_rec.mixed_model_map_flag;
        Error_Handler.Add_Error_Token
        (  p_message_name       =>'BOM_RIT_MIXED_MDL_MAP_INVALID'
         , p_token_tbl          => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    */
    -- Added by MK on 08/24/2000


    -- Added by MK on 02/15/2001
    -- Validate alternate bom code
    IF p_revised_item_rec.alternate_bom_code IS NOT NULL AND
       p_revised_item_rec.alternate_bom_code <> FND_API.G_MISS_CHAR
    THEN

         FOR check_alternate IN
             c_Check_Alternate
             ( p_alt_designator  => p_revised_item_rec.alternate_bom_code,
               p_organization_id => p_rev_item_unexp_rec.organization_id )
         LOOP

             l_token_tbl(1).token_name := 'ALTERNATE_BOM_CODE';
             l_token_tbl(1).token_value :=
                                        p_revised_item_rec.alternate_bom_code;
             l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
             l_token_tbl(2).token_value := p_revised_item_rec.organization_code;

             Error_Handler.Add_Error_Token
             (  p_Message_Name       => 'BOM_ALT_DESIGNATOR_INVALID'
              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_token_tbl          => l_token_tbl
             );

             x_return_status := FND_API.G_RET_STS_ERROR;
             l_token_tbl.delete ;
             l_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
             l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;

         END LOOP;


IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Alternate Desig Validated . . . status : '||x_return_status );
END IF;

    END IF;

--  Check if the revised item is an approved item. Unapproved items cannot be added as revised items.
    IF Get_Approval_Status(p_rev_item_unexp_rec.revised_item_id,
                           p_rev_item_unexp_rec.organization_id) <> 'A'
    THEN
        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
        Error_Handler.Add_Error_Token
        (  p_message_name       => 'ENG_REV_ITEM_UNAPPROVED'
         , p_token_tbl          => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Done validating attributes
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Attribute Validation) ' ||
                          substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
        END IF;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Attributes;


/*****************************************************************************
* Procedure     : Entity_Delete
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Entity Delete procedure will check if the given revised item
*                 can be deleted without violating any business rules or
*                 constraints. Revised item's cannot be deleted if there are
*                 components on the bill or it revised item's bill is being
*                 referenced as common by any other bills in the same org or
*                 any other org.
*                 (Check of revised item being implemented or cancelled is done
*                  in the previous steps of the process flow)
******************************************************************************/
PROCEDURE Check_Entity_Delete
(  x_return_status              OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
)
IS
  l_err_text                  VARCHAR2(2000) := NULL;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  check_delete          NUMBER := 0;
  l_count1              NUMBER := 0;
  l_allow_rev           NUMBER := 0;

  CURSOR rev_comps IS
      SELECT 1
      FROM BOM_INVENTORY_COMPONENTS
      WHERE revised_item_sequence_id =
               p_rev_item_unexp_rec.revised_item_sequence_id;


  /******************************************************************
  -- Added by MK on 08/26/2000
  -- Enhancement for ECO Routing
  ******************************************************************/
  CURSOR rev_op_seq IS
  SELECT 'Rev Op Exist'
  FROM    SYS.DUAL
  WHERE EXISTS  ( SELECT NULL
                  FROM BOM_OPERATION_SEQUENCES
                  WHERE revised_item_sequence_id =
                       p_rev_item_unexp_rec.revised_item_sequence_id) ;
  -- Added by MK on 08/26/2000

  -- 11.5.10E
  -- Delete should be allowed only if the new revision doesn't appear as
  -- from revision for some other revised item

  -- Bug No: 4273087
  -- Checking for additional references when removing the 'New Revision'
  -- Bug 4946817: Fixed performance issues
  /* Bug 8491180: Do not consider the rows that has same CURRENT_ITEM_REVISION_ID and NEW_ITEM_REVISION_ID in the first SELECT
     statement, as NEW_ITEM_REVISION_ID refer to existing current revision, but not the new revision, while deleting Item
     Revision from Change Order. */

  CURSOR allow_delete_rev IS
  SELECT 1
  FROM ENG_REVISED_ITEMS itm,
  ENG_REVISED_ITEMS sitm
  WHERE itm.REVISED_ITEM_ID = sitm.REVISED_ITEM_ID
  AND itm.ORGANIZATION_ID = sitm.ORGANIZATION_ID
  AND sitm.revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id
  AND itm.STATUS_TYPE not in (5, 6)
  AND (itm.CURRENT_ITEM_REVISION_ID = sitm.new_item_revision_id
       OR itm.FROM_END_ITEM_REV_ID = sitm.new_item_revision_id)
  AND (sitm.CURRENT_ITEM_REVISION_ID<>sitm.NEW_ITEM_REVISION_ID)
  UNION ALL
  SELECT 1
  FROM ENG_REVISED_ITEMS sitm  , bom_structures_b bsb
  WHERE sitm.revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id
  AND bsb.assembly_item_id = sitm.revised_item_id
  AND bsb.organization_id = sitm.organization_id
  AND EXISTS ( SELECT 1
               FROM BOM_COMPONENTS_B bic
               WHERE bic.bill_sequence_id = bsb.bill_sequence_id   and
               (bic.FROM_END_ITEM_REV_ID = sitm.new_item_revision_id
               OR bic.TO_END_ITEM_REV_ID = sitm.new_item_revision_id
               ))
  UNION ALL
  SELECT 1
  FROM eng_revised_items sitm
  WHERE sitm.revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id
  AND EXISTS ( SELECT 1
               FROM BOM_COMPONENTS_B bic
               WHERE bic.component_item_id = sitm.revised_item_id   and
               bic.COMPONENT_ITEM_REVISION_ID = sitm.new_item_revision_id);

        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN
        --
        -- Set the revised item token name and value
        --
        l_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        FOR l_rev_comps IN rev_comps
        LOOP
                --
                -- if loop executes, then component exist on that bill
                -- so it cannot be deleted.
                --
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_COMP_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END LOOP;



        /******************************************************************
        -- Added by MK on 08/26/2000
        -- Enhancement for ECO Routing
        ******************************************************************/
        FOR l_rev_op_seq IN rev_op_seq
        LOOP
                --
                -- if loop executes, then revised operation exist on that
                -- routing so it cannot be deleted.
                --
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_OP_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END LOOP;
        -- Added by MK on 08/26/2000



        /*********************************************************************
        --
        -- Check if the revised item's bill is being referenced as common
        --
        **********************************************************************/
        check_delete := Check_Reference_Common
                  ( p_change_notice     => p_revised_item_rec.eco_name
                  , p_bill_sequence_id  => p_rev_item_unexp_rec.bill_sequence_id
                  );

        IF check_delete <> 0
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_COMMON_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- Check if the revised item's routing is being referenced as common
        **********************************************************************/
        check_delete := 0 ;
        check_delete :=  Check_Reference_Rtg_Common
                  ( p_change_notice     => p_revised_item_rec.eco_name
                  , p_routing_sequence_id  => p_rev_item_unexp_rec.routing_sequence_id
                  );

        IF check_delete <> 0
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_RTG_COMMON_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- Added by MK on 08/26/2000

        -- 11.5.10E
        -- Validation for new_revision while deleting rev items
        OPEN allow_delete_rev;
        FETCH allow_delete_rev into l_allow_rev;
        IF l_allow_rev = 1
        THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            Error_Handler.Add_Error_Token
              (  p_Message_Name       => 'ENG_CANNOT_DEL_REVISION_IN_USE'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => l_Token_Tbl
              );
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE allow_delete_rev;
        -- Done with the validations
        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF allow_delete_rev%ISOPEN
        THEN
          CLOSE allow_delete_rev;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Entity Delete Validation) ' ||
                          substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
        END IF;

END Check_Entity_Delete;

/*****************************************************************************
* Procedure     : Check_Existence
* Parameters IN : Revised Item exposed column record
*                 Revised Item unexposed column record
* Parameters OUT: Old Revised Item exposed column record
*                 Old Revised Item unexposed column record
*                 Mesg Token Table
*                 Return Status
* Purpose       : Check_Existence will poerform a query using the primary key
*                 information and will return a success if the operation is
*                 CREATE and the record EXISTS or will return an
*                 error if the operation is UPDATE and the record DOES NOT
*                 EXIST.
*                 In case of UPDATE if the record exists then the procedure
*                 will return the old record in the old entity parameters
*                 with a success status.
****************************************************************************/

PROCEDURE Check_Existence
(  p_revised_item_rec       IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_old_revised_item_rec   IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
 , x_old_rev_item_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status          OUT NOCOPY VARCHAR2
 , x_disable_revision       OUT NOCOPY NUMBER --Bug no:3034642
)
IS
        l_token_tbl      Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status  VARCHAR2(1);
	--Start of changes Bug no:3034642
        l_profile_exist     BOOLEAN;
        l_profile_val       VARCHAR2(30);
        l_phase_change_code VARCHAR2(30)       :='REVISE';
        l_catalog_category_id MTL_SYSTEM_ITEMS_B.ITEM_CATALOG_GROUP_ID%TYPE;
        l_Lifecycle_Id        NUMBER;
        l_policy_code         VARCHAR2(100);
        l_Old_Phase_Id        mtl_item_revisions_b.current_phase_id%TYPE;
        l_Error_Code          NUMBER;
        l_Msg_Data            VARCHAR2(2000);
        l_api_version         CONSTANT NUMBER           := 1.0;
        l_project_id          NUMBER :=NULL;
        l_msg_count           NUMBER;
	l_package_name   varchar2(100) := 'EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change';

	CURSOR c_get_default_life(inv_id NUMBER,cp_org_id NUMBER)
        IS
          select current_phase_id, LIFECYCLE_ID  ,ITEM_CATALOG_GROUP_ID  from  mtl_system_items
          where INVENTORY_ITEM_ID =inv_id and organization_id =cp_org_id;

--End  of changes Bug no:3034642
BEGIN
        l_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;
        l_token_tbl(2).token_name  := 'ECO_NAME';
        l_token_tbl(2).token_value := p_revised_item_rec.eco_name;

        ENG_Revised_Item_Util.Query_Row
        ( p_revised_item_id     => p_rev_item_unexp_rec.revised_item_id
        , p_organization_id     => p_rev_item_unexp_rec.organization_id
        , p_change_notice       => p_revised_item_rec.eco_name
        , p_new_item_revision   => p_revised_item_rec.new_revised_item_revision
        , p_new_routing_revision => p_revised_item_rec.new_routing_revision
        , p_start_eff_date      => p_revised_item_rec.start_effective_date
        , p_from_end_item_number => p_revised_item_rec.from_end_item_unit_number
        , p_alternate_designator => p_revised_item_rec.alternate_bom_code  -- To Fix 2869146
        , x_revised_item_rec    => x_old_revised_item_rec
        , x_rev_item_unexp_rec  => x_old_rev_item_unexp_rec
        , x_Return_status       => l_return_status
        );
        IF l_return_status = Eng_Globals.G_RECORD_FOUND AND
           p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REV_ITEM_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = Eng_Globals.G_RECORD_NOT_FOUND AND
              p_revised_item_rec.transaction_type IN
                (Eng_Globals.G_OPR_UPDATE, Eng_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REV_ITEM_DOESNOT_EXIST'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_message_name       => NULL
                 , p_message_text       =>
                   'Unexpected error while existence verification of ' ||
                   'Revised Item ' || p_revised_item_rec.revised_item_name
                 , p_token_tbl          => l_token_tbl
                 );
        ELSE
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;
	 --Start of changes Bug no:3034642

	x_disable_revision :=2;
        l_profile_exist := FND_PROFILE.DEFINED ( 'EGO_ITEM_RESTRICT_INV_ACTIONS' );
        if (l_profile_exist = TRUE) then
            FND_PROFILE.GET ( 'EGO_ITEM_RESTRICT_INV_ACTIONS', l_profile_val );
            if ( l_profile_val = '2') then
               FOR sc IN c_get_default_life(p_rev_item_unexp_rec.Revised_Item_Id ,  p_rev_item_unexp_rec.Organization_Id)
                LOOP
                  l_Old_Phase_Id := sc.current_phase_id;
                  l_Lifecycle_Id     := sc.LIFECYCLE_ID;
                  l_catalog_category_id :=sc.ITEM_CATALOG_GROUP_ID;
               END LOOP;
              execute immediate 'begin ' || l_package_name || '(:1,:2, :3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13); end;'
               using in l_api_version ,in l_project_id, in p_rev_item_unexp_rec.Revised_Item_Id , in p_rev_item_unexp_rec.Organization_Id,in l_Old_Phase_Id,in l_Old_Phase_Id,in l_phase_change_code ,in l_Lifecycle_Id    ,
               out l_Policy_Code,out l_Return_Status,out l_Error_Code,out l_Msg_Count,out l_Msg_Data ;
              if  l_Policy_Code <> 'ALLOWED' THEN
	           x_disable_revision := 1; --not allowed thus revison field should be disabled
      	      end if;
            end if; --end of if l_profile_val = '1'
            if UPPER(p_revised_item_rec.Transaction_Type) =UPPER('Create')
	       and p_revised_item_rec.New_Revised_Item_Revision is not null
	       and x_disable_revision = 1
            then
               	  error_handler.add_error_token (
                        p_message_name=> 'ENG_ITEMREV_NOT_ALLOW',
                        p_mesg_token_tbl=> l_mesg_token_tbl,
                        x_mesg_token_tbl=> l_mesg_token_tbl,
                        p_token_tbl=> l_token_tbl
                     );
                     l_return_status := fnd_api.g_ret_sts_error;
            end if;
        end if;   --end of if profile value exists

  --end of changes Bug no:3034642

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

/*****************************************************************************
* Procedure     : Check_Access_Scheduled
* Parameters IN : Revised Item exposed column record
*                 Revised Item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Check_Access_Scheduled will check the validity of the revised item
*                 record when the CO is in scheduled status
*                 Added for Enhancement 5470261

****************************************************************************/
PROCEDURE Check_Access_Scheduled
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type

 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_token_tbl      Error_Handler.Token_Tbl_Type;

BEGIN


  l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
  l_token_tbl(1).token_value := p_revised_item_rec.revised_item_name;
  IF(
     p_rev_item_unexp_rec.implementation_date IS NOT NULL
     OR p_rev_item_unexp_rec.cancellation_date IS NOT NULL
     OR p_revised_item_rec.cancel_comments IS NOT NULL
     OR p_revised_item_rec.disposition_type IS NOT NULL
     OR p_revised_item_rec.updated_revised_item_revision IS NOT NULL
     OR p_revised_item_rec.earliest_effective_date IS NOT NULL
     OR p_revised_item_rec.attribute_category IS NOT NULL
     OR p_revised_item_rec.attribute2 IS NOT NULL
     OR p_revised_item_rec.attribute3 IS NOT NULL
     OR p_revised_item_rec.attribute4  IS NOT NULL
     OR p_revised_item_rec.attribute5 IS NOT NULL
     OR p_revised_item_rec.attribute7  IS NOT NULL
     OR p_revised_item_rec.attribute8 IS NOT NULL
     OR p_revised_item_rec.attribute9 IS NOT NULL
     OR p_revised_item_rec.attribute11 IS NOT NULL
     OR p_revised_item_rec.attribute12 IS NOT NULL
     OR p_revised_item_rec.attribute13 IS NOT NULL
     OR p_revised_item_rec.attribute14 IS NOT NULL
     OR p_revised_item_rec.attribute15 IS NOT NULL
     OR p_revised_item_rec.status_type IS NOT NULL
     --p_revised_item_rec.new_effective_date --scheduled date
     --p_rev_item_unexp_rec.bill_sequence_id IS NOT NULL
     OR p_revised_item_rec.mrp_active IS NOT NULL
     OR p_revised_item_rec.update_wip IS NOT NULL
     OR p_rev_item_unexp_rec.use_up IS NOT NULL
     OR p_rev_item_unexp_rec.use_up_item_id IS NOT NULL
     OR p_rev_item_unexp_rec.revised_item_sequence_id IS NOT NULL
     OR p_revised_item_rec.use_up_plan_name IS NOT NULL
     OR p_revised_item_rec.change_description IS NOT NULL
     OR p_rev_item_unexp_rec.auto_implement_date IS NOT NULL
     OR p_revised_item_rec.from_end_item_unit_number IS NOT NULL
     OR p_revised_item_rec.attribute1 IS NOT NULL
     OR p_revised_item_rec.attribute6 IS NOT NULL
     OR p_revised_item_rec.attribute10 IS NOT NULL
     OR p_revised_item_rec.original_system_reference IS NOT NULL
     OR p_rev_item_unexp_rec.from_wip_entity_id IS NOT NULL
     OR p_rev_item_unexp_rec.to_wip_entity_id IS NOT NULL
     OR p_revised_item_rec.from_cumulative_quantity IS NOT NULL
     OR p_revised_item_rec.lot_number IS NOT NULL
     OR p_rev_item_unexp_rec.cfm_routing_flag IS NOT NULL
     OR p_revised_item_rec.completion_subinventory IS NOT NULL
     OR p_rev_item_unexp_rec.completion_locator_id IS NOT NULL
     OR p_revised_item_rec.priority IS NOT NULL
     OR p_revised_item_rec.ctp_flag IS NOT NULL
     OR p_rev_item_unexp_rec.routing_sequence_id IS NOT NULL
     OR p_revised_item_rec.updated_routing_revision IS NOT NULL
     OR p_revised_item_rec.routing_comment IS NOT NULL
     OR p_revised_item_rec.eco_for_production IS NOT NULL
     --p_rev_item_unexp_rec.change_id IS NOT NULL
     OR p_revised_item_rec.Transfer_Or_Copy IS NOT NULL
     OR p_revised_item_rec.Transfer_OR_Copy_Item IS NOT NULL
     OR p_revised_item_rec.Transfer_OR_Copy_Bill IS NOT NULL
     OR p_revised_item_rec.Transfer_OR_Copy_Routing IS NOT NULL
     OR p_revised_item_rec.Copy_To_Item IS NOT NULL
     OR p_revised_item_rec.Copy_To_Item_Desc IS NOT NULL
     OR p_revised_item_rec.selection_option IS NOT NULL
     OR p_revised_item_rec.selection_date IS NOT NULL
     OR p_revised_item_rec.selection_unit_number IS NOT NULL
     OR p_rev_item_unexp_rec.status_code IS NOT NULL
     OR p_revised_item_rec.status_type IS NOT NULL

    ) THEN
	-- The user has given values for some other colums
	-- Thus, it is assumed that the user is trying to update these columns
	-- Since these values cannot be updated when the CO is in scheduled status
	-- Error is thrown
         Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_NO_UPDATE_SCHEDULED'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF  (p_revised_item_rec.new_effective_date IS NULL) THEN
	 -- The change is in scheduled status and the user has not given a
	 -- value for the new scheduled date.
	 Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_SCHEDULED_DATE_NULL'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
       ELSIF (p_revised_item_rec.new_effective_date < SYSDATE) THEN
	  -- While rescheduling the new effective date shall not be less than
	  -- the current date...
	 Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_EFF_DATE_INVALID'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
    end if;
    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Access_Scheduled;


PROCEDURE Check_Access
(  p_change_notice              IN  VARCHAR2
 , p_organization_id            IN  NUMBER
 , p_revised_item_id            IN  NUMBER
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_new_routing_revsion        IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_from_end_item_number       IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_revised_item_name          IN  VARCHAR2
 , p_entity_processed           IN  VARCHAR2 := NULL
 , p_operation_seq_num          IN  NUMBER   := NULL
 , p_routing_sequence_id        IN  NUMBER   := NULL
 , p_operation_type             IN  NUMBER   := NULL
 , p_alternate_bom_code         IN  VARCHAR2   := NULL
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                        Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
 , p_check_scheduled_status IN BOOLEAN DEFAULT TRUE  -- Added for bug 5756870
)
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type :=
                                p_Mesg_Token_Tbl;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_Return_Status         VARCHAR2(1);
        l_is_item_unit_controlled BOOLEAN := FALSE;

        CURSOR c_CheckRevisedItem IS
        SELECT status_type
          FROM eng_revised_items
         WHERE revised_item_id   = p_revised_item_id
	   AND organization_id = p_organization_id --* Added for Bug 5174223
           AND change_notice     = p_change_notice
           AND NVL(from_end_item_unit_number, 'NONE')
                      = NVL(p_from_end_item_number, 'NONE')
           AND NVL(new_routing_revision,'NULL')
                      = NVL(p_new_routing_revsion,'NULL')
           AND NVL(new_item_revision, 'NULL') = NVL(p_new_item_revision, 'NULL')
           AND trunc(scheduled_date)    = trunc(p_effectivity_date);

        CURSOR c_RevItemType IS
        SELECT bom_item_type,eng_item_flag
          FROM mtl_system_items
         WHERE inventory_item_id = p_revised_item_id
           AND organization_id   = p_organization_id;

        -- Moved from BOM_Validate_Op_Seq.Check_Access by MK on 12/04
        CURSOR c_CheckCancelled IS
           SELECT 1
           FROM SYS.DUAL
           WHERE NOT EXISTS
                        ( SELECT NULL
                          FROM   BOM_OPERATION_SEQUENCES
                          WHERE  NVL(operation_type, 1) = NVL(p_operation_type, 1)
                          AND    effectivity_date       = p_effectivity_date
                          AND    routing_sequence_id    = p_routing_sequence_id
                          AND    operation_seq_num      = p_operation_seq_num
                        )
            AND  EXISTS
                        ( SELECT NULL
                          FROM ENG_REVISED_OPERATIONS
                          WHERE  NVL(operation_type, 1) = NVL(p_operation_type, 1)
                          AND    TRUNC(effectivity_date)     = TRUNC(p_effectivity_date)
                          AND    routing_sequence_id  = p_routing_sequence_id
                          AND    operation_seq_num    = p_operation_seq_num
                          );
        -- Bug 4210718
        l_cp_not_allowed        NUMBER;
        l_structure_type_id     NUMBER;
        -- Bug 4276451
        l_status_type_name      fnd_lookup_values_vl.meaning%TYPE;
	l_status_valid		BOOLEAN;


BEGIN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
        l_token_tbl(1).token_value := p_revised_item_name;

        l_is_item_unit_controlled := BOM_Globals.Get_Unit_Controlled_Item;

        --
        -- The driving procedure must make sure that the ECO
        -- Check_Access has been called and has returned with a success.
        --
        /*******************************
        Eng_Validate_ECO.Check_Access
        (  p_change_notice      => p_change_notice
         , p_organization_id    => p_organization_id
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Return_Status      => l_return_status
        );
        ***********************************/

	  ---Check if user has access to Engineering item or not bug:4942705
	  IF (NVL(fnd_profile.value('ENG:ENG_ITEM_ECN_ACCESS'), 1) = 2)
          THEN
	    FOR revised_item IN c_RevItemType
                LOOP
                        IF revised_item.eng_item_flag = 'Y' THEN
                            Error_Handler.Add_Error_Token
                                  (  p_Message_Name       => 'ENG_ITEM_ACCESS_DENIED'
                                   , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                   , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                   , p_Token_Tbl          => l_token_tbl
                                  );
                             l_return_status := FND_API.G_RET_STS_ERROR;
                         END IF;
                 END LOOP;
	END IF;

        --
        -- Check revised item is not implemented or Cancelled
        --
        IF BOM_Globals.Is_RItem_Cancl IS NULL AND
           BOM_Globals.Is_RItem_Impl  IS NULL
        THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Checking for revised item impl /canceled . . .'); END IF;

                FOR revised_item IN c_CheckRevisedItem
                LOOP
                        IF revised_item.status_type = 5 THEN
                                BOM_Globals.Set_RItem_Cancl
                                (p_ritem_cancl  => TRUE);
                        ELSIF revised_item.status_type = 6 THEN
                                BOM_Globals.Set_RItem_Impl
                                (p_ritem_impl   => TRUE);
                        ELSE
                                BOM_Globals.Set_RItem_Cancl
                                (p_ritem_cancl  => FALSE);
                                BOM_Globals.Set_RItem_Impl
                                (p_ritem_impl   => FALSE);
                        END IF;
                        -- Bug 4276451
                        -- Check if the revised item is updateable for PLM ECOs
                        IF ENG_Globals.Get_PLM_Or_ERP_Change(p_change_notice, p_organization_id) = 'PLM'
                           AND ENG_GLOBALS.G_ENG_LAUNCH_IMPORT <> 2 -- should not be checked for propagation
                        THEN
                            l_status_valid := TRUE;
			    IF revised_item.status_type NOT in( 1, 4) THEN
				l_status_valid := FALSE;
			    ELSIF ((revised_item.status_type = 4) AND (p_check_scheduled_status = TRUE)) THEN
				l_status_valid := FALSE;
			    END IF;

			    IF (l_status_valid = FALSE)
                            THEN
                                BEGIN
                                    SELECT meaning
                                    INTO l_status_type_name
                                    FROM fnd_lookup_values_vl
                                    WHERE lookup_type='ECG_ECN_STATUS'
                                    AND lookup_code = revised_item.status_type;
                                    l_Token_Tbl(2).token_name  := 'STATUS_TYPE_NAME';
                                    l_token_tbl(2).token_value := l_status_type_name;
                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    l_status_type_name := NULL;
                                END;
                                Error_Handler.Add_Error_Token
                                  (  p_Message_Name       => 'ENG_RIT_PLM_NO_ACCESS_STATUS'
                                   , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                   , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                   , p_Token_Tbl          => l_token_tbl
                                  );

                                l_return_status := FND_API.G_RET_STS_ERROR;
                            END IF;
                        END IF;
                        -- End fix for Bug 4276451
                END LOOP;
        END IF;

        IF NVL(BOM_Globals.Is_RItem_Impl, FALSE) = TRUE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_IMPLEMENTED'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF NVL(BOM_Globals.Is_RItem_Cancl, FALSE) = TRUE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RIT_CANCELLED'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;



        --
        -- Check that the user has access to the BOM Item Type
        -- of the revised item
        --
        IF BOM_Globals.Get_STD_Item_Access IS NULL AND
           BOM_Globals.Get_PLN_Item_Access IS NULL AND
           BOM_Globals.Get_MDL_Item_Access IS NULL
        THEN

                --
                -- Get respective profile values
                --
                IF NVL(fnd_profile.value('ENG:STANDARD_ITEM_ECN_ACCESS'), 1) = 1
                THEN
                        BOM_Globals.Set_STD_Item_Access
                        ( p_std_item_access     => 4);
                ELSE
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('no access to standard items'); END IF;
                        BOM_Globals.Set_STD_Item_Access
                        (p_std_item_access      => NULL);
                END IF;

                IF fnd_profile.value('ENG:MODEL_ITEM_ECN_ACCESS') = '1'
                THEN
                        BOM_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => 1);
                        BOM_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => 2);
                ELSE
                        BOM_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => NULL);
                        BOM_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => NULL);
                END IF;

                IF fnd_profile.value('ENG:PLANNING_ITEM_ECN_ACCESS') = '1'
                THEN
                        BOM_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => 3);
                ELSE
                        BOM_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => NULL);
                END IF;
        END IF;

        FOR RevItem IN  c_RevItemType
        LOOP
                IF RevItem.Bom_Item_Type = 5
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_REV_ITEM_PROD_FAMILY'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSIF RevItem.Bom_Item_Type NOT IN
                      ( NVL(BOM_Globals.Get_STD_Item_Access, 0),
                        NVL(BOM_Globals.Get_PLN_Item_Access, 0),
                        NVL(BOM_Globals.Get_OC_Item_Access, 0) ,
                        NVL(BOM_Globals.Get_MDL_Item_Access, 0)
                       )
                THEN
                        l_Token_Tbl(2).Token_Name := 'BOM_ITEM_TYPE';
                        l_Token_Tbl(2).Translate  := TRUE;
                        IF RevItem.Bom_Item_Type = 1
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_MODEL';
                        ELSIF RevItem.Bom_Item_Type = 2
                        THEN
                                l_Token_Tbl(2).Token_Value:='ENG_OPTION_CLASS';
                        ELSIF RevItem.Bom_Item_Type = 3
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_PLANNING';
                        ELSIF RevItem.Bom_Item_Type = 4
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_STANDARD';
                        END IF;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_REV_ITEM_ACCESS_DENIED'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;

                END IF;
        END LOOP;

        /*********************************************************************
         -- Added by AS on 07/06/99
         -- Checks that unit effective items are allowed only if the profile
         -- value allows them (profile value stored in system_information)
        *********************************************************************/

        IF NOT BOM_Globals.Get_Unit_Effectivity AND
           l_is_item_unit_controlled
        THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_REV_ITEM_UNIT_CONTROL'
                , p_Mesg_Token_Tbl => l_mesg_token_tbl
                , x_Mesg_Token_Tbl => l_mesg_token_tbl
                , p_Token_Tbl      => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;



        /**************************************************************
        -- Added by MK on 11/01/2000
        -- If bill sequence id is null(Trans Type : CREATE) and this revised
        --  item does not have primary bill, verify that parent revised
        -- item does not have routing sequence id which has alternate code.
        -- (Verify this eco is not only for alternate routing)
        --
        -- Moved to Engineering space to resolve ECO dependency
        -- by MK on 12/03/00
        **************************************************************/
        IF p_entity_processed = 'RC'
        AND Not Check_RevItem_BillAlternate
                                    (  p_revised_item_id   =>  p_revised_item_id
                                     , p_organization_id   =>  p_organization_id
                                     , p_change_notice     =>  p_change_notice
                                     , p_new_item_revision =>  p_new_item_revision
                                     , p_new_routing_revsion => p_new_routing_revsion
                                     , p_effective_date    =>  p_effectivity_date
                                     , p_from_end_item_number => p_from_end_item_number
                                     )

        THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value := p_revised_item_name ;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_ADD_ALTERNATE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;



        /**************************************************************
        -- Added by MK on 11/01/2000
        -- If routing sequence id is null(Trans Type : CREATE) and this
        -- revised item does not have primary routing, verify that parent revised
        -- item does not have bill sequence id which has alternate code.
        -- (Verify this eco is not only for alternate bill )
        --
        **************************************************************/
        ELSIF p_entity_processed = 'ROP'
        AND Not Check_RevItem_RtgAlternate
                                    (  p_revised_item_id   =>  p_revised_item_id
                                     , p_organization_id   =>  p_organization_id
                                     , p_change_notice     =>  p_change_notice
                                     , p_new_item_revision =>  p_new_item_revision
                                     , p_new_routing_revsion => p_new_routing_revsion
                                     , p_effective_date    =>  p_effectivity_date
                                     , p_from_end_item_number => p_from_end_item_number
                                     )

        THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value := p_revised_item_name ;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_RTG_CANT_ADD_ALTERNATE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;



        IF   p_entity_processed IN ('ROP', 'RES', 'SR')
        THEN

            IF BOM_Rtg_Globals.Is_ROP_Cancl IS NULL THEN
                FOR RevOp IN c_CheckCancelled
                LOOP
                    l_token_tbl.DELETE;
                    l_Token_Tbl(1).Token_Name  := 'OP_SEQ_NUMBER';
                    l_Token_Tbl(1).Token_value := p_operation_seq_num;
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'BOM_REV_OP_CANCELLED'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_token_tbl
                    );

                    l_return_status := FND_API.G_RET_STS_ERROR;
                END LOOP;
             END IF;
        END IF ;
        -- Bug 4210718
        -- Added the check for change policy for bill
        IF p_entity_processed IN ('SBC', 'RFD', 'RC')
        THEN
                Check_Structure_Type_Policy
                    ( p_inventory_item_id   => p_revised_item_id
                    , p_organization_id     => p_organization_id
                    , p_alternate_bom_code  => p_alternate_bom_code
                    , x_structure_type_id   => l_structure_type_id
                    , x_strc_cp_not_allowed => l_cp_not_allowed
                    );
                IF l_cp_not_allowed = 1
                THEN
                    l_token_tbl.DELETE;
                    l_Token_Tbl(1).Token_Name  := 'STRUCTURE_NAME';
                    l_Token_Tbl(1).Token_value := p_alternate_bom_code;
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name    => 'ENG_BILL_CHANGES_NOT_ALLOWED'
                     , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                     , p_Token_Tbl       => l_token_tbl
                    );

                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END IF;
        --
        -- If all the access checks are satisfied then return a status of
        -- success, else return error.
        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item Check Access returning . . . ' ||
        l_return_status);
END IF;

        x_Return_Status := l_return_status;
        x_Mesg_Token_Tbl := l_mesg_token_tbl;
END Check_Access;

-- Fix for bug 3577967
/******************************************************************************
* Procedure        : Get_Where_Clause_For_Subjects
* Parameters IN    : Change Notice
* Returns  IN OUT  : All ITEM_LIFECYCLE_PHASE_ID concatenated value for  where clause
*                  : All ITEM_CATALOGUE_GROUP_ID concatenated value for  where clause
*                  : All ITEM_TYPE_ID concatenated value for where clause
* Purpose          : Procedure will verify if the change notice has subjects
*                    at the header type level . If it does then the procedure
*                    will return the subject values.
******************************************************************************/
 PROCEDURE Get_Where_Clause_For_Subjects(p_change_notice            IN VARCHAR2
                                        ,x_item_lifecycle_Phase     IN OUT NOCOPY VARCHAR2
                                        ,x_item_catalogue_Group     IN OUT NOCOPY VARCHAR2
                                        ,x_item_type                IN OUT NOCOPY VARCHAR2)
   IS
     l_item_lifecycle_Phase   VARCHAR2(2000) :=null;
     l_item_catalogue_Group   VARCHAR2(2000) :=null;
     l_item_type              VARCHAR2(2000) :=null;

     CURSOR GetSubjects IS
         SELECT ecpv.attribute_code ,
                ecpv.attribute_char_value
           FROM eng_change_policies_v ecpv ,
                eng_engineering_changes eec
          WHERE ecpv.policy_object_name = 'EGO_CHANGE_TYPE'
            AND ecpv.policy_object_pk1_value  = eec.change_order_type_id
            AND eec.change_notice = p_change_notice;
 BEGIN
      FOR c8rec IN GetSubjects LOOP
        IF( c8rec.ATTRIBUTE_CODE ='ITEM_LIFECYCLE_PHASE'  ) THEN
          IF(l_item_lifecycle_Phase  IS NOT  NULL) THEN
             l_item_lifecycle_Phase := l_item_lifecycle_Phase ||',';
          END IF;
          l_item_lifecycle_Phase := l_item_lifecycle_Phase || c8rec.ATTRIBUTE_CHAR_VALUE;
        END IF ;
        IF( c8rec.ATTRIBUTE_CODE ='CATALOG_CATEGORY') THEN
          IF(l_item_catalogue_Group  IS NOT  NULL) THEN
             l_item_catalogue_Group := l_item_catalogue_Group ||',';
          END IF;
          l_item_catalogue_Group := l_item_catalogue_Group || c8rec.ATTRIBUTE_CHAR_VALUE;
        END IF;
        IF(c8rec.ATTRIBUTE_CODE ='ITEM_TYPE' ) THEN
          IF(l_item_type  IS NOT  NULL ) THEN
            l_item_type := l_item_type ||',';
          END IF;
          l_item_type := l_item_type || '''' || c8rec.ATTRIBUTE_CHAR_VALUE ||'''';
        END IF;
      END LOOP;
      x_item_lifecycle_Phase :=l_item_lifecycle_Phase;
      x_item_catalogue_Group := l_item_catalogue_Group;
      x_item_type := l_item_type;
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
        x_item_lifecycle_Phase :=null;
        x_item_catalogue_Group :=null;
        x_item_type            :=null;
 END Get_Where_Clause_For_Subjects;

-- Fix for bug 3577967
/******************************************************************************
* Procedure        : validate_rev_items_for_sub
* Parameters IN    : Change Notice
*                  : Organization Id
* Returns  IN OUT  : True If this item has same subjects same as the header type of change notice else
*                  : False
* Purpose          : Procedure will verify if the Item  has same subjects as
*                    at the header type level of the change order.
******************************************************************************/
 PROCEDURE validate_rev_items_for_sub(
                           p_change_notice     IN VARCHAR2
                          ,p_inventory_item_id IN NUMBER
                          ,p_org_id            IN NUMBER
                          ,x_ret_Value         OUT NOCOPY BOOLEAN
                           ) IS
        l_current_phase_id          VARCHAR2(2000) ;
        l_item_catalog_group_id     VARCHAR2(2000) ;
        l_item_type                 VARCHAR2(2000) ;
        l_count_items               NUMBER  :=0;
        l_sql varchar2(2000);
 BEGIN
       Get_Where_Clause_For_Subjects(
                               p_change_notice          =>   p_change_notice
                              ,x_item_lifecycle_Phase   =>   l_current_phase_id
                              ,x_item_catalogue_Group   =>   l_item_catalog_group_id
                              ,x_item_type              =>   l_item_type);
       -- Added bom_parameters, bom_delete_status_code condition for bug 13362684
       l_sql := 'SELECT COUNT(*)
                 FROM mtl_system_items_b i,
                       bom_parameters bp
                 WHERE i.organization_id = :1
                   AND i.inventory_item_status_code not in (''Inactive'', ''Obsolete'')
                   AND i.inventory_item_status_code <> nvl(bp.bom_delete_status_code, FND_API.G_MISS_CHAR)
                   AND i.organization_id = bp.organization_id
                   AND i.inventory_item_id = :2';
        if l_current_phase_id IS NOT NULL then
          l_sql := l_sql||' AND current_phase_id in ('||l_current_phase_id||')';
        end if;
        if l_item_catalog_group_id IS NOT NULL then
          l_sql := l_sql || ' AND item_catalog_group_id in ('|| l_item_catalog_group_id||')';
        end if;
        IF l_item_type IS NOT NULL THEN
          l_sql := l_sql || ' AND item_type in('||l_item_type||')';
        END IF;
        EXECUTE IMMEDIATE l_sql into l_count_items using p_org_id, p_inventory_item_id;
        IF(l_count_items = 0 )
           THEN  x_ret_Value := FALSE;
           ELSE x_ret_Value  :=  TRUE;
        END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_ret_Value := FALSE;
 END validate_rev_items_for_sub;

PROCEDURE Validate_Revised_Item (
    p_api_version               IN NUMBER := 1.0                         --
  , p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE           --
  , p_commit                    IN VARCHAR2 := FND_API.G_FALSE           --
  , p_validation_level          IN NUMBER  := FND_API.G_VALID_LEVEL_FULL --
  , p_debug                     IN VARCHAR2 := 'N'                       --
  , p_output_dir                IN VARCHAR2 := NULL                      --
  , p_debug_filename            IN VARCHAR2 := 'VALREVITEMS.log'       --
  , x_return_status             OUT NOCOPY VARCHAR2                      --
  , x_msg_count                 OUT NOCOPY NUMBER                        --
  , x_msg_data                  OUT NOCOPY VARCHAR2                      --
  -- Initialization
  , p_bo_identifier             IN VARCHAR2 := 'ECO'
  , p_transaction_type          IN VARCHAR2
  -- Change context
  , p_organization_id           IN NUMBER
  , p_change_id                 IN NUMBER
  , p_change_notice             IN VARCHAR2
  , p_assembly_type             IN NUMBER
  -- revised item
  , p_revised_item_sequence_id  IN NUMBER
  , p_revised_item_id           IN NUMBER
  , p_status_type               IN NUMBER
  , p_status_code               IN NUMBER
  -- new revision
  , p_new_revised_item_revision IN VARCHAR2
  , p_new_revised_item_rev_desc IN VARCHAR2
  , p_from_item_revision_id     IN NUMBER
  , p_new_revision_reason_code  IN VARCHAR2
  , p_new_revision_label        IN VARCHAR2
  , p_updated_revision          IN VARCHAR2
  , p_new_item_revision_id      IN NUMBER
  , p_current_item_revision_id  IN NUMBER
  -- effectivity
  , p_start_effective_date      IN DATE
  , p_new_effective_date        IN DATE
  , p_earliest_effective_date   IN DATE
  -- bill and routing
  , p_alternate_bom_code        IN VARCHAR2
  , p_bill_sequence_id          IN NUMBER
  , p_from_unit_number          IN VARCHAR2
  , p_new_from_unit_number      IN VARCHAR2
  , p_from_end_item_id          IN NUMBER
  , p_from_end_item_revision_id IN NUMBER
  , p_routing_sequence_id       IN NUMBER
  , p_completion_subinventory   IN VARCHAR2
  , p_completion_locator_id     IN NUMBER
  , p_priority                  IN NUMBER
  , p_ctp_flag                  IN NUMBER
  , p_new_routing_revision      IN VARCHAR2
  , p_updated_routing_revision  IN VARCHAR2
  , p_eco_for_production        IN NUMBER
  , p_cfm_routing_flag          IN NUMBER
  -- useup
  , p_use_up_plan_name          IN VARCHAR2
  , p_use_up_item_id            IN NUMBER
  , p_use_up                    IN NUMBER
  -- wip
  , p_disposition_type          IN NUMBER
  , p_update_wip                IN NUMBER
  , p_mrp_active                IN NUMBER
  , p_from_wip_entity_id        IN NUMBER
  , p_to_wip_entity_id          IN NUMBER
  , p_from_cumulative_quantity  IN NUMBER
  , p_lot_number                IN VARCHAR2
)
IS
    l_api_name                  CONSTANT VARCHAR2(30)   := 'Validate_Revised_Item';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1);
    l_mesg_token_tbl            Error_Handler.Mesg_Token_Tbl_Type;

    l_revised_item_rec          ENG_Eco_PUB.Revised_Item_Rec_Type;
    l_rev_item_unexp_rec        Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
    l_old_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type;
    l_old_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
    l_control_rec               BOM_BO_Pub.Control_Rec_Type;

    EXC_ERR_PVT_API_MAIN        EXCEPTION;

    -- init the following
    l_org_code                  VARCHAR2(3);
    l_revised_item_number       mtl_system_items_vl.concatenated_segments%TYPE;
    l_use_up_item_name          mtl_system_items_vl.concatenated_segments%TYPE;
    l_from_item_revision        mtl_item_revisions.revision%TYPE;
    l_completion_location_name  VARCHAR2(1);
    l_from_work_order           VARCHAR2(1);
    l_to_work_order             VARCHAR2(1);
    l_msg_data                  VARCHAR2(32000);

    l_alternate_bom_code        VARCHAR2(10); -- Bug 12310735
BEGIN

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
        Error_Handler.Initialize;
    END IF;

    IF p_debug = 'Y'
    THEN
        BOM_Globals.Set_Debug(p_debug);
        Error_Handler.Open_Debug_Session(
            p_debug_filename     => p_debug_filename
          , p_output_dir         => p_output_dir
          , x_return_status      => l_return_status
          , x_error_mesg         => x_msg_data
          );
        IF l_return_status <> 'S'
        THEN
            BOM_Globals.Set_Debug('N');
        END IF;
    END IF;
    -- Initialize System_Information
    ENG_GLOBALS.Init_System_Info_Rec(
        x_mesg_token_tbl => l_mesg_token_tbl
      , x_return_status  => l_return_status
      );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE EXC_ERR_PVT_API_MAIN;
    END IF;
    -- Initialize Unit_Effectivity flag
    IF PJM_UNIT_EFF.Enabled = 'Y'
    THEN
        BOM_Globals.Set_Unit_Effectivity (TRUE);
        ENG_Globals.Set_Unit_Effectivity (TRUE);
    ELSE
        BOM_Globals.Set_Unit_Effectivity (FALSE);
        ENG_Globals.Set_Unit_Effectivity (FALSE);
    END IF;
    --
    BOM_Globals.Set_Unit_Controlled_Item(
        p_inventory_item_id => p_revised_item_id
      , p_organization_id   => p_organization_id
      );
    BOM_Globals.Set_Require_Item_Rev(FND_PROFILE.VALUE('ENG:ECO_REVISED_ITEM_REVISION'));
    Eng_Globals.Set_Bo_Identifier( p_bo_identifier => p_bo_identifier);
    Eng_Globals.Set_Org_Id( p_org_id => p_organization_id);

    -- Bug 12310735. If alternate designator is Primary, set it to NULL.
    -- Bug 14639944 extends bug 12310735 to multiple languages,
    l_alternate_bom_code := p_alternate_bom_code;
    IF l_alternate_bom_code IS NOT NULL
       AND (    l_alternate_bom_code = 'Primary'
             or l_alternate_bom_code = BOM_GLOBALS.RETRIEVE_MESSAGE('BOM','BOM_PRIMARY') )
    THEN
        l_alternate_bom_code := NULL;
    END IF;

    l_return_status := 'S';

    -- Start processing
    l_control_rec.caller_type                       := 'SSWA';
    l_control_rec.eco_assembly_type                 := p_assembly_type;
    -- Initialize the revised Item records
    -- change context
    l_rev_item_unexp_rec.organization_id            := p_organization_id;
    l_revised_item_rec.organization_code            := l_org_code;
    l_rev_item_unexp_rec.change_id                  := p_change_id;
    l_revised_item_rec.eco_name                     := p_change_notice;
    -- revised item
    l_rev_item_unexp_rec.revised_item_sequence_id   := p_revised_item_sequence_id;
    l_rev_item_unexp_rec.revised_item_id            := p_revised_item_id;
    l_revised_item_rec.status_type                  := p_status_type;
    l_rev_item_unexp_rec.status_code                := p_status_code;
    l_revised_item_rec.revised_item_name            := l_revised_item_number;
    -- new revision
    l_revised_item_rec.new_revised_item_revision    := p_new_revised_item_revision;
    l_revised_item_rec.New_Revised_Item_Rev_Desc    := p_new_revised_item_rev_desc;
    l_revised_item_rec.Updated_Revised_Item_Revision:= p_updated_revision;
    l_revised_item_rec.New_Revision_Label           := p_new_revision_label;
    l_revised_item_rec.New_Revised_Item_Rev_Desc    := p_new_revised_item_rev_desc;
    l_rev_item_unexp_rec.from_item_revision_id      := p_from_item_revision_id;
    l_rev_item_unexp_rec.new_revision_reason_code   := p_new_revision_reason_code;
    l_rev_item_unexp_rec.new_item_revision_id       := p_new_item_revision_id;
    l_rev_item_unexp_rec.current_item_revision_id   := p_current_item_revision_id;
    l_revised_item_rec.from_item_revision           := l_from_item_revision;
    -- Effectivity
    l_revised_item_rec.start_effective_date         := p_start_effective_date;
    l_revised_item_rec.New_Effective_Date           := p_new_effective_date;
    l_revised_item_rec.earliest_effective_date      := p_earliest_effective_date;
    -- Bill and routing
    l_revised_item_rec.alternate_bom_code           := l_alternate_bom_code; -- Bug 12310735
    l_rev_item_unexp_rec.Bill_Sequence_Id           := p_Bill_Sequence_Id;
    l_rev_item_unexp_rec.from_end_item_id           := p_from_end_item_id;
    l_rev_item_unexp_rec.from_end_item_revision_id  := p_from_end_item_revision_id;
    l_revised_item_rec.From_End_Item_Unit_Number    := p_from_unit_number;
    l_revised_item_rec.New_From_End_Item_Unit_Number:= p_new_from_unit_number;
    l_rev_item_unexp_rec.routing_sequence_id        := p_routing_sequence_id;
    l_rev_item_unexp_rec.cfm_routing_flag           := p_cfm_routing_flag;
    l_revised_item_rec.ctp_flag                     := p_ctp_flag;
    l_revised_item_rec.completion_subinventory      := p_completion_subinventory;
    l_revised_item_rec.completion_location_name     := l_completion_location_name;
    l_rev_item_unexp_rec.completion_locator_id      := p_completion_locator_id;
    l_revised_item_rec.new_routing_revision         := p_new_routing_revision;
    l_revised_item_rec.updated_routing_revision     := p_updated_routing_revision;
    l_revised_item_rec.priority                     := p_priority;
    l_revised_item_rec.eco_for_production           := p_eco_for_production;
    -- use up
    l_revised_item_rec.use_up_item_name             := l_use_up_item_name;
    l_revised_item_rec.use_up_plan_name             := p_use_up_plan_name;
    l_rev_item_unexp_rec.use_up_item_id             := p_use_up_item_id;
    l_rev_item_unexp_rec.use_up                     := p_use_up;
    -- WIP
    l_revised_item_rec.disposition_type             := p_disposition_type;
    l_revised_item_rec.update_wip                   := p_update_wip;
    l_revised_item_rec.mrp_active                   := p_mrp_active;
    l_rev_item_unexp_rec.from_wip_entity_id         := p_from_wip_entity_id;
    l_rev_item_unexp_rec.to_wip_entity_id           := p_to_wip_entity_id;
    l_revised_item_rec.from_work_order              := l_from_work_order;
    l_revised_item_rec.to_work_order                := l_to_work_order;
    l_revised_item_rec.from_cumulative_quantity     := p_from_cumulative_quantity;
    l_revised_item_rec.lot_number                   := p_lot_number;
    -- Other
    l_revised_item_rec.return_status                := l_return_status;
    l_revised_item_rec.transaction_type             := p_transaction_type;
    -- End Initialize the revised item record
    -- Start initialize the old revised item record

    BEGIN
        SELECT
            change_notice
          , organization_id
          , revised_item_id
          , implementation_date
          , cancellation_date
          , cancel_comments
          , disposition_type
          , new_item_revision
          , early_schedule_date
          , attribute_category
          , attribute2
          , attribute3
          , attribute4
          , attribute5
          , attribute7
          , attribute8
          , attribute9
          , attribute11
          , attribute12
          , attribute13
          , attribute14
          , attribute15
          , status_type
          , scheduled_date
          , bill_sequence_id
          , mrp_active
          , update_wip
          , use_up
          , use_up_item_id
          , revised_item_sequence_id
          , use_up_plan_name
          , descriptive_text
          , auto_implement_date
          , attribute1
          , attribute6
          , attribute10
          , from_wip_entity_id
          , to_wip_entity_id
          , from_cum_qty
          , lot_number
          , cfm_routing_flag
          , completion_subinventory
          , completion_locator_id
          , priority
          , ctp_flag
          , routing_sequence_id
          , new_routing_revision
          , routing_comment
          , eco_for_production
          , change_id
          , status_code
        INTO
            l_old_revised_item_rec.eco_name
          , l_old_rev_item_unexp_rec.organization_id
          , l_old_rev_item_unexp_rec.revised_item_id
          , l_old_rev_item_unexp_rec.implementation_date
          , l_old_rev_item_unexp_rec.cancellation_date
          , l_old_revised_item_rec.cancel_comments
          , l_old_revised_item_rec.disposition_type
          , l_old_revised_item_rec.new_revised_item_revision
          , l_old_revised_item_rec.earliest_effective_date
          , l_old_revised_item_rec.attribute_category
          , l_old_revised_item_rec.attribute2
          , l_old_revised_item_rec.attribute3
          , l_old_revised_item_rec.attribute4
          , l_old_revised_item_rec.attribute5
          , l_old_revised_item_rec.attribute7
          , l_old_revised_item_rec.attribute8
          , l_old_revised_item_rec.attribute9
          , l_old_revised_item_rec.attribute11
          , l_old_revised_item_rec.attribute12
          , l_old_revised_item_rec.attribute13
          , l_old_revised_item_rec.attribute14
          , l_old_revised_item_rec.attribute15
          , l_old_revised_item_rec.status_type
          , l_old_revised_item_rec.start_effective_date
          , l_rev_item_unexp_rec.bill_sequence_id
          , l_old_revised_item_rec.mrp_active
          , l_old_revised_item_rec.update_wip
          , l_old_rev_item_unexp_rec.use_up
          , l_old_rev_item_unexp_rec.use_up_item_id
          , l_old_rev_item_unexp_rec.revised_item_sequence_id
          , l_old_revised_item_rec.use_up_plan_name
          , l_old_revised_item_rec.change_description
          , l_old_rev_item_unexp_rec.auto_implement_date
          , l_old_revised_item_rec.attribute1
          , l_old_revised_item_rec.attribute6
          , l_old_revised_item_rec.attribute10
          , l_old_rev_item_unexp_rec.from_wip_entity_id
          , l_old_rev_item_unexp_rec.to_wip_entity_id
          , l_old_revised_item_rec.from_cumulative_quantity
          , l_old_revised_item_rec.lot_number
          , l_old_rev_item_unexp_rec.cfm_routing_flag
          , l_old_revised_item_rec.completion_subinventory
          , l_old_rev_item_unexp_rec.completion_locator_id
          , l_old_revised_item_rec.priority
          , l_old_revised_item_rec.ctp_flag
          , l_old_rev_item_unexp_rec.routing_sequence_id
          , l_old_revised_item_rec.new_routing_revision
          , l_old_revised_item_rec.routing_comment
          , l_old_revised_item_rec.eco_for_production
          , l_old_rev_item_unexp_rec.change_id
          , l_old_rev_item_unexp_rec.status_code
        FROM eng_revised_items
        WHERE revised_item_sequence_id = p_revised_item_sequence_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        null;
    END;

    IF l_return_status = 'S'
    THEN
        Check_Attributes(
            x_return_status           => l_return_status
          , x_Mesg_Token_Tbl          => l_mesg_token_tbl
          , p_revised_item_rec        => l_revised_item_rec
          , p_rev_item_unexp_rec      => l_rev_item_unexp_rec
          , p_old_revised_item_rec    => l_old_revised_item_rec
          , p_old_rev_item_unexp_rec  => l_old_rev_item_unexp_rec
          );
    END IF;

    IF l_return_status = 'S'
    THEN
        Check_Entity(
            p_revised_item_rec         => l_revised_item_rec
          , p_rev_item_unexp_rec       => l_rev_item_unexp_rec
          , p_old_revised_item_rec     => l_old_revised_item_rec
          , p_old_rev_item_unexp_rec   => l_old_rev_item_unexp_rec
          , p_control_rec              => l_control_rec
          , x_Mesg_Token_Tbl           => l_mesg_token_tbl
          , x_Return_Status            => l_return_status
          );
    END IF;

    IF l_return_status <> 'S'
    THEN
        FOR l_LoopIndex IN 1..l_mesg_token_tbl.COUNT
        LOOP
            fnd_message.clear;
            FND_MESSAGE.Set_Name(
                application => 'ENG'
              , name        => 'ENG_ACTION_MESSAGE'
              );
            /*IF l_mesg_token_tbl(l_LoopIndex).token_name IS NOT NULL
            THEN*/
                fnd_message.set_token(
                    token     => 'ACTION'
                  , value     => l_mesg_token_tbl(l_LoopIndex).message_text
                  );
                fnd_message.set_token(
                    token     => 'ENTITY'
                  , value     => ' '
                  );
/*            END IF;*/
            Fnd_msg_pub.add;
        END LOOP;
    END IF;

    -- Start of Closure to procedure
    x_return_status := l_return_status;

    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => l_msg_data
      );

    x_msg_data := l_msg_data;
    IF Bom_Globals.Get_Debug = 'Y'
    THEN
        Error_Handler.Write_Debug('-***-End API Validate_Revised_Item-***-');
        Error_Handler.Close_Debug_Session;
    END IF;


EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data
      );
    IF Bom_Globals.Get_Debug = 'Y'
    THEN
        Error_Handler.Write_Debug('Unexpected Error ');
        Error_Handler.Close_Debug_Session;
    END IF;

END Validate_Revised_Item;

END ENG_Validate_Revised_Item;

/
