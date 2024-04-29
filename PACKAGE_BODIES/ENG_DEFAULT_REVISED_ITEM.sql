--------------------------------------------------------
--  DDL for Package Body ENG_DEFAULT_REVISED_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DEFAULT_REVISED_ITEM" AS
/* $Header: ENGDRITB.pls 120.9.12010000.12 2015/11/12 11:04:39 nlingamp ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ENG_Default_Revised_Item';

--  Package global used within the package.

g_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type;
g_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;

--  Local Function used for defualting.

/***************************************************************************
* Function      : Get_Status_Type
* Returns       : NUMBER
* Purpose       : Function will look at the ECO and will return the status
*                 type of the ECO as the default status type for the revised
*                 item.
*****************************************************************************/
FUNCTION Get_Status_Type
RETURN NUMBER
IS
l_status_type   NUMBER := NULL;
BEGIN

    SELECT   status_type
    INTO     l_status_type
    FROM     eng_engineering_changes
    WHERE    change_notice = g_revised_item_rec.eco_name
             AND organization_id = g_rev_item_unexp_rec.organization_id;

    RETURN l_status_type;

EXCEPTION

    WHEN OTHERS THEN

        RETURN NULL;

END Get_Status_Type;

/*****************************************************************************
* Function      : Get_Bill_Sequence
* Return        : NUMBER
* Purpose       : Function will query the bill record for the current revised
*                 item and return the bill_sequence_id.
******************************************************************************/
FUNCTION Get_Bill_Sequence
RETURN NUMBER
IS
l_bill_sequence_id      NUMBER := NULL;
BEGIN

    SELECT   bill_sequence_id
    INTO     l_bill_sequence_id
    FROM     bom_bill_of_materials
    WHERE    assembly_item_id = g_rev_item_unexp_rec.revised_item_id
             AND NVL(alternate_bom_designator, 'NONE') =
                        NVL(g_revised_item_rec.alternate_bom_code, 'NONE')
             AND organization_id = g_rev_item_unexp_rec.organization_id;

    RETURN l_bill_sequence_id;

EXCEPTION

    WHEN OTHERS THEN

        RETURN NULL;

END Get_Bill_Sequence;

/*****************************************************************************
* Function      : Get_Routing_Sequence
* Return        : NUMBER
* Purpose       : Function will query the rtg record for the current revised
*                 item and return the rtg_sequence_id.
******************************************************************************/
FUNCTION Get_Routing_Sequence
RETURN NUMBER
IS
l_rtg_sequence_id      NUMBER := NULL;
BEGIN

    SELECT   routing_sequence_id
    INTO     l_rtg_sequence_id
    FROM     bom_operational_routings
    WHERE    assembly_item_id = g_rev_item_unexp_rec.revised_item_id
             AND NVL(alternate_routing_designator, 'NONE') =
                        NVL(g_revised_item_rec.alternate_bom_code, 'NONE')
             AND organization_id = g_rev_item_unexp_rec.organization_id;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('FUNCTION Get_Routing_Sequence, RTG Seq Id is: ' || to_char(l_rtg_sequence_id));
END IF;

    RETURN l_rtg_sequence_id;


EXCEPTION

    WHEN OTHERS THEN

        RETURN NULL;

END Get_Routing_Sequence;


/*****************************************************************************
* Function      : Get_Update_WIP
* Returns       : Number
* Purpose       : Function will look at the item attribute build_in_wip for the
*                 the current revised item and will return that as the default
*                 value for the column.
*****************************************************************************/
FUNCTION Get_Update_Wip
RETURN NUMBER
IS
l_build_in_wip  VARCHAR2(1) := NULL;
l_update_wip    NUMBER := NULL;
BEGIN

    SELECT   build_in_wip_flag
    INTO     l_build_in_wip
    FROM     mtl_system_items
    WHERE    inventory_item_id = g_rev_item_unexp_rec.revised_item_id
             AND organization_id = g_rev_item_unexp_rec.organization_id;

    IF (l_build_in_wip = 'Y')
    THEN
      l_update_wip := 1;
    ELSIF (l_build_in_wip = 'N')
    THEN
      l_update_wip := 2;
    END IF;

    RETURN l_update_wip;

EXCEPTION

    WHEN OTHERS THEN

        RETURN NULL;

END Get_Update_Wip;

FUNCTION Get_Revised_Item_Sequence
RETURN NUMBER
IS
l_revised_item_seq_id NUMBER := NULL;
BEGIN

    SELECT eng_revised_items_s.NEXTVAL
    INTO l_revised_item_seq_id
    FROM DUAL;

    RETURN l_revised_item_seq_id;

    EXCEPTION

        WHEN OTHERS THEN
                RETURN NULL;

END Get_Revised_Item_Sequence;

PROCEDURE Get_Flex_Revised_Item
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_revised_item_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute_category := NULL;
    END IF;

    IF g_revised_item_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute2  := NULL;
    END IF;

    IF g_revised_item_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute3  := NULL;
    END IF;

    IF g_revised_item_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute4  := NULL;
    END IF;

    IF g_revised_item_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute5  := NULL;
    END IF;

    IF g_revised_item_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute7  := NULL;
    END IF;

    IF g_revised_item_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute8  := NULL;
    END IF;

    IF g_revised_item_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute9  := NULL;
    END IF;

    IF g_revised_item_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute11 := NULL;
    END IF;

    IF g_revised_item_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute12 := NULL;
    END IF;

    IF g_revised_item_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute13 := NULL;
    END IF;

    IF g_revised_item_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute14 := NULL;
    END IF;

    IF g_revised_item_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute15 := NULL;
    END IF;

    IF g_revised_item_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute1  := NULL;
    END IF;

    IF g_revised_item_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute6  := NULL;
    END IF;

    IF g_revised_item_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_revised_item_rec.attribute10 := NULL;
    END IF;

END Get_Flex_Revised_Item;


-- Eco For Production added by MK on 10/06/2000
FUNCTION  Get_Eco_For_Production
RETURN NUMBER
IS
BEGIN
    IF  ( g_revised_item_rec.lot_number               IS NOT NULL
          AND g_revised_item_rec.lot_number <> FND_API.G_MISS_CHAR ) OR
        ( g_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
          AND g_rev_item_unexp_rec.from_wip_entity_id <> FND_API.G_MISS_NUM)
    THEN
        RETURN 1 ;   -- Return 1 : Yes
    ELSE
        RETURN 2 ;   -- Return 2 : No
    END IF ;

END Get_Eco_For_Production ;

--11.5.10 to get current life_cycle_id
FUNCTION  Get_Current_LifeCycle_Id
(   p_rev_item_id         IN  NUMBER
,   p_org_id              IN  NUMBER
,   p_current_revision    IN  VARCHAR2
)
RETURN NUMBER
IS
l_id NUMBER;
BEGIN

/*SELECT LP.PROJ_ELEMENT_ID
   into l_id
FROM PA_EGO_LIFECYCLES_PHASES_V LP, MTL_ITEM_REVISIONS MIR
WHERE
    LP.PROJ_ELEMENT_ID =MIR.CURRENT_PHASE_ID
AND MIR.INVENTORY_ITEM_ID = p_rev_item_id
AND MIR.ORGANIZATION_ID = p_org_id
AND MIR.REVISION = p_current_revision; */ -- Commented By LKASTURI

	-- Bug 3311072: Change the query to select item phase
	-- Added By LKASTURI
	SELECT CURRENT_PHASE_ID
	INTO l_id
	FROM MTL_System_items_vl
	WHERE INVENTORY_ITEM_ID = p_rev_item_id
	AND ORGANIZATION_ID = p_org_id;
	-- End Changes 3311072

RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
         RETURN  FND_API.G_MISS_NUM;


END Get_Current_LifeCycle_Id;

--11.5.10 to get current life_cycle_id
FUNCTION  Get_Current_Structure_Rev_Id
(   p_bill_seq_id         IN  NUMBER
,   p_item_rev_id              IN  NUMBER
,   p_current_revision    IN  VARCHAR2
)
RETURN NUMBER
IS
l_id NUMBER;
BEGIN

/* not supported for 11.5.10
select STRUCTURE_REVISION_ID  into l_id
	from  should use minor revision
	where
	BILL_SEQUENCE_ID = p_bill_seq_id
	and REVISION   = p_current_revision
	and  OBJECT_REVISION_ID = p_item_rev_id;
*/

RETURN null;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
         RETURN  FND_API.G_MISS_NUM;


END Get_Current_Structure_Rev_Id;



/****************************************************************************
* Function      : Get_Current_Item_Revision
* Paramters IN  : Revised itemid
*                 Organization ID
*                 Revision Date
* Purpose       : Function will return the current item revision bu looking
*                 at the mtl_item_revisions table and return the revision that
*                 has implementation date NOT NULL and is currently effective.
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




/*******************************************************************************
* Procedure     : Attribute_Defaulting
* Parameters IN : Revised item exposed record
*                 Revised item unexposed record
* Parameters OUT: Revised item exposed record after defaulting
*                 Revised item unexposed record after defaulting
*                 Mesg_Token_Table
*                 Return_Status
* Purpose       : Attribute Defaulting will default the necessary null attribute
*                 with appropriate values.
*******************************************************************************/
PROCEDURE Attribute_Defaulting
(   p_revised_item_rec          IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_item_unexp_rec        IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   x_revised_item_rec          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Rec_Type
,   x_rev_item_unexp_rec        IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_rec_type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_revision VARCHAR2(3);
l_default_lifecycle	NUMBER := 0;

CURSOR c_status (cp_change_id IN NUMBER)
IS
SELECT ecsv.status_code , ecsv.status_type
FROM   eng_change_statuses_vl ecsv
WHERE  ecsv.status_code IN (SELECT els1.status_code
			FROM eng_lifecycle_statuses els1
                        WHERE els1.entity_name='ENG_CHANGE'
                        AND els1.entity_id1 = cp_change_id
			AND els1.active_flag = 'Y'
                        AND els1.sequence_number = (SELECT min(els2.sequence_number)
			                       FROM eng_lifecycle_statuses els2
					       WHERE els2.entity_name='ENG_CHANGE'
					       AND els2.entity_id1 = cp_change_id
					       AND els2.active_flag = 'Y'));

CURSOR c_rev_item_status (cp_rev_item_seq_id IN NUMBER)
IS
SELECT status_code ,status_type
FROM eng_revised_items
WHERE revised_item_sequence_id = cp_rev_item_seq_id;

BEGIN

    --  Initialize g_revised_item_rec

    g_revised_item_rec := p_revised_item_rec;
    g_rev_item_unexp_rec := p_rev_item_unexp_rec;

    --  Default NULL attributes.

    IF g_revised_item_rec.disposition_type IS NULL THEN

        g_revised_item_rec.disposition_type := 1;  -- 'No Change Required'

    END IF;

    IF g_revised_item_rec.earliest_effective_date IS NULL
       OR g_revised_item_rec.earliest_effective_date = FND_API.G_MISS_DATE
    THEN
	-- commenting the defaulting of earliest_effective_date to sysdate for bug 3575375
        g_revised_item_rec.earliest_effective_date := NULL;--SYSDATE;

    END IF;

    /***********************************************************************************
    --
    -- Defaulting Logic for status_code and status_type.
    -- If Change Order is a PLM change, then the revised item.
    -- status_type and status_code are defaulted to the First lifecycle phase of the change.
    -- This is the behaviour when the revised item is added from the SSWA UI to the change order.
    -- Default to the current_status_type and status_code if transaction type is not create.
    -- Added For bug 3618676
    --
    ***********************************************************************************/

    IF (Eng_Globals.Get_PLM_Or_ERP_Change(g_revised_item_rec.eco_name, g_rev_item_unexp_rec.organization_id) = 'PLM'
        AND g_rev_item_unexp_rec.status_code IS NULL)
    THEN
        IF g_revised_item_rec.transaction_type = 'CREATE'
	THEN
		OPEN c_status(g_rev_item_unexp_rec.change_id);
		FETCH c_status INTO g_rev_item_unexp_rec.status_code, g_revised_item_rec.status_type;
		CLOSE c_status;
	ELSE
	       -- The following has to be commented out once Status code promotion logic is added to the BO for PLM ECOs
	       -- and the status code being populated in Populate_Null_Columns for PLM
	       -- As no exposed field is available for status code. This is being done here.
		OPEN c_rev_item_status(g_rev_item_unexp_rec.revised_item_sequence_id);
		FETCH c_rev_item_status INTO g_rev_item_unexp_rec.status_code, g_revised_item_rec.status_type;
		CLOSE c_rev_item_status;

	END IF;
    END IF;

    /***********************************************************************************
    --
    -- For Other case, i.e ERP change set status type as the header status_type
    -- And status_code as the status_type .
    --
    ***********************************************************************************/

    IF g_revised_item_rec.status_type IS NULL THEN

        g_revised_item_rec.status_type := Get_Status_Type;

    END IF;

    -- Added for bug 3618676
    IF g_rev_item_unexp_rec.status_code IS NULL	THEN

	g_rev_item_unexp_rec.status_code := g_revised_item_rec.status_type;

    END IF;


    IF g_revised_item_rec.start_effective_date IS NULL AND
       g_revised_item_rec.use_up_plan_name IS NULL THEN

        g_revised_item_rec.start_effective_date := SYSDATE;

    END IF;

   /***********************************************************************
    -- Copied this defaulting logic to ENG_Val_To_Id.Revised_Item_VID
    -- by MK on 02/15/2001. BO doest not need  this logic
    -- but ECO Form is still using it. Hence not comment out.
   ***********************************************************************/
    IF g_rev_item_unexp_rec.bill_sequence_id IS NULL  OR
       g_rev_item_unexp_rec.bill_sequence_id = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.bill_sequence_id := Get_Bill_Sequence;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Getting Bill Seq Id . . . : ' ||
                             to_char(g_rev_item_unexp_rec.bill_sequence_id));
END IF;

    END IF;

    IF g_revised_item_rec.mrp_active IS NULL THEN
        -- Modified for bug 17444824.
        -- Default value of 'MRP Active' has to take from the profile 'ENG: MRP Active flag default for ECO'
        -- g_revised_item_rec.mrp_active := 1;
        IF nvl(fnd_profile.value('ENG:DEFAULT_MRP_ACTIVE'), 2) = 1
        THEN
          g_revised_item_rec.mrp_active := 1;
        ELSE
          g_revised_item_rec.mrp_active := 2;
        END IF;
    END IF;

          --Bug 16340624 begin
 	  IF (g_revised_item_rec.transfer_or_copy = 'T' OR
g_revised_item_rec.transfer_or_copy = 'C')
 	  THEN
 	   IF g_revised_item_rec.alternate_selection_code is NULL OR
 	      g_revised_item_rec.alternate_selection_code = FND_API.G_MISS_NUM
 	   THEN
 	      g_revised_item_rec.alternate_selection_code := 1; --All
 	   END IF;

 	   IF g_revised_item_rec.selection_option is NULL OR
 	      g_revised_item_rec.selection_option = FND_API.G_MISS_NUM
 	   THEN
 	      g_revised_item_rec.selection_option := 3; --Future and Current
 	   END IF;

 	  IF g_revised_item_rec.selection_date is NULL OR
 	     g_revised_item_rec.selection_date = FND_API.G_MISS_DATE
 	   THEN
 	     g_revised_item_rec.selection_date := sysdate;
 	   END IF;

 	  IF g_revised_item_rec.transfer_or_copy_item is NULL OR
 	     g_revised_item_rec.transfer_or_copy_item = FND_API.G_MISS_NUM
 	   THEN
 	     g_revised_item_rec.transfer_or_copy_item := 2;
 	   END IF;

 	  IF g_revised_item_rec.transfer_or_copy_bill is NULL OR
 	     g_revised_item_rec.transfer_or_copy_bill = FND_API.G_MISS_NUM
 	   THEN
 	     g_revised_item_rec.transfer_or_copy_bill := 2;
 	   END IF;

 	  IF g_revised_item_rec.transfer_or_copy_routing is NULL OR
 	     g_revised_item_rec.transfer_or_copy_routing = FND_API.G_MISS_NUM
 	   THEN
 	     g_revised_item_rec.transfer_or_copy_routing := 2;
 	   END IF;

 	  END IF;
 	    --bug 16340624 (end)


      IF g_revised_item_rec.update_wip IS NULL THEN

        -- Added IF condition because update_wip will be set to No
        -- for Unit Controlled items.
        -- Added by AS on 07/06/99


      IF NOT BOM_Globals.Get_Unit_Controlled_Item
        THEN
                g_revised_item_rec.update_wip := Get_Update_Wip;
        ELSE
                g_revised_item_rec.update_wip := 2;
        END IF;
    END IF;

    IF g_rev_item_unexp_rec.use_up IS NULL OR
       g_rev_item_unexp_rec.use_up = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.use_up := 2;
    END IF;

    IF g_rev_item_unexp_rec.use_up_item_id IS NULL OR
       g_revised_item_rec.use_up_item_name = FND_API.G_MISS_CHAR
    THEN
        g_rev_item_unexp_rec.use_up := 2;
    END IF;

    IF g_rev_item_unexp_rec.requestor_id = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.requestor_id := NULL;
    END IF;

    g_rev_item_unexp_rec.revised_item_sequence_id := Get_Revised_Item_Sequence;

    IF g_revised_item_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_revised_item_rec.attribute10 = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Revised_Item;

    END IF;

    /***********************************************************************
    -- Added by MK on 09/01/2000
    -- For New ECO Effectivities and ECO Routing
    ***********************************************************************/

    /***********************************************************************
    -- Copied this defaulting logic to ENG_Val_To_Id.Revised_Item_VID
    -- by MK on 02/15/2001. BO doest not need  this logic
    -- but ECO Form is still using it. Hence not comment out.
    ***********************************************************************/
    IF g_rev_item_unexp_rec.routing_sequence_id IS NULL  OR
       g_rev_item_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.routing_sequence_id := Get_Routing_Sequence;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Getting Routing Seq Id . . . : ' ||
                             to_char(g_rev_item_unexp_rec.routing_sequence_id));
END IF;

    END IF;

    IF g_rev_item_unexp_rec.routing_sequence_id is NOT NULL THEN

        Select CFM_ROUTING_FLAG,CTP_FLAG
        into   g_rev_item_unexp_rec.cfm_routing_flag,g_revised_item_rec.ctp_flag
        from   BOM_OPERATIONAL_ROUTINGS
        where  ROUTING_SEQUENCE_ID = g_rev_item_unexp_rec.routing_sequence_id;

    END IF;

    IF g_rev_item_unexp_rec.cfm_routing_flag IS NULL OR
       g_rev_item_unexp_rec.cfm_routing_flag = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.cfm_routing_flag  := Bom_Default_Rtg_Header.Get_Cfm_Routing_Flag ;
    END IF ; -- to Suppport Flow Routing, This should be exposed column.


    IF g_revised_item_rec.ctp_flag IS NULL OR
       g_revised_item_rec.ctp_flag = FND_API.G_MISS_NUM THEN
       g_revised_item_rec.ctp_flag
                 := Bom_Default_Rtg_Header.Get_Ctp_Flag ;
    END IF;

    /* Comment out. For Future Release
    IF g_revised_item_rec.mixed_model_map_flag IS NULL OR
       g_revised_item_rec.mixed_model_map_flag = FND_API.G_MISS_NUM THEN
        g_revised_item_rec.mixed_model_map_flag
                 := Bom_Default_Rtg_Header.Get_Get_Mixed_Model_Map_Flag ;
    END IF;
    */
    -- Added by MK on 09/01/2000

    -- Eco For Production Added by MK on 10/06/2000
    IF g_revised_item_rec.eco_for_production IS NULL OR
       g_revised_item_rec.eco_for_production = FND_API.G_MISS_NUM
    THEN
        g_revised_item_rec.eco_for_production := Get_Eco_For_Production ;
    END IF;
    --11.5.10 Defaulting current_item_revision_id  and  current_lifecycle_state_id

   IF g_rev_item_unexp_rec.current_item_revision_id IS NULL  OR
       g_rev_item_unexp_rec.current_item_revision_id = FND_API.G_MISS_NUM
    THEN
         g_rev_item_unexp_rec.current_item_revision_id :=
	   BOM_REVISIONS.get_item_revision_id_fn(
           'ALL',
           'IMPL_ONLY',
           g_rev_item_unexp_rec.organization_id,
           g_rev_item_unexp_rec.revised_item_id, SYSDATE);
   END IF;

  IF g_rev_item_unexp_rec.current_lifecycle_state_id IS NULL  OR
       g_rev_item_unexp_rec.current_lifecycle_state_id = FND_API.G_MISS_NUM
    THEN
/*        l_revision :=
	   BOM_REVISIONS.GET_ITEM_REVISION_FN (
           'ALL',
           'ALL',
           g_rev_item_unexp_rec.organization_id,
           g_rev_item_unexp_rec.revised_item_id, SYSDATE); */ -- Commented By LKASTURI

	g_rev_item_unexp_rec.current_lifecycle_state_id :=
	Get_Current_LifeCycle_Id	 (
	 p_rev_item_id     =>g_rev_item_unexp_rec.revised_item_id,
	 p_org_id         =>g_rev_item_unexp_rec.organization_id,
	 p_current_revision =>l_revision);

  END IF;


    --  Done defaulting attributes
IF g_revised_item_rec.current_structure_rev_name is not  NULL THEN

 g_rev_item_unexp_rec.current_structure_rev_id:=
Get_Current_Structure_Rev_Id
(   p_bill_seq_id    =>     g_rev_item_unexp_rec.bill_sequence_id
,   p_item_rev_id          => g_rev_item_unexp_rec.current_item_revision_id
,   p_current_revision  =>g_revised_item_rec.current_structure_rev_name);

END IF;

  --end of 11.5.10 changes

    -- 11.5.10E
    -- Setting the values of new_rev_label, new_rev_description, new_rev_reason as null
    -- for ERP case or when the new revision is not specified.
    IF (Eng_Globals.Get_PLM_Or_ERP_Change(g_revised_item_rec.eco_name,
        g_rev_item_unexp_rec.organization_id) <> 'PLM')
    THEN
      g_revised_item_rec.from_item_revision := FND_API.G_MISS_CHAR;

      -- Commented for bug fix 4517503
      -- g_rev_item_unexp_rec.from_item_revision_id := FND_API.G_MISS_NUM;
      g_rev_item_unexp_rec.new_revision_reason_code := FND_API.G_MISS_CHAR;
    ELSE
      g_revised_item_rec.from_item_revision
                      := Get_Current_Item_Revision
                        ( p_revised_item_id => g_rev_item_unexp_rec.revised_item_id
                        , p_organization_id => g_rev_item_unexp_rec.organization_id
                        , p_revision_date   => SYSDATE
                        );
    END IF;
    --
    -- Added for bug fix 4517503
    -- Setting the from item revision id to current item revision id
    -- In ENGURITB.pls this value is being used to populate eng_revised_items.
    -- current_item_revision_id in procedure insert_row.
    -- Moved from ENGURITB.pls => Eng_revised_item_util.Insert_Row
    IF g_rev_item_unexp_rec.from_item_revision_id IS NULL  OR
       g_rev_item_unexp_rec.from_item_revision_id = FND_API.G_MISS_NUM
    THEN
        g_rev_item_unexp_rec.from_item_revision_id := g_rev_item_unexp_rec.current_item_revision_id;
    END IF;
    -- End of bug fix 4517503

    -- The new revision related fields are being nulled out if the new
    -- revision is not provided.
    IF (g_revised_item_rec.new_revised_item_revision IS NULL OR
        g_revised_item_rec.new_revised_item_revision = FND_API.G_MISS_CHAR)
    THEN
      g_rev_item_unexp_rec.new_revision_reason_code := FND_API.G_MISS_CHAR;
    END IF;

    -- Validation for the scheduled_date

    x_revised_item_rec := g_revised_item_rec;
    x_rev_item_unexp_rec := g_rev_item_unexp_rec;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

END Attribute_Defaulting;

/******************************************************************************
* Procedure     : Populate_Null_Columns
* Parameters IN : Revised component exposed column record
*                 Revised component unexposed column record
*                 Old Revised component record
*                 Old Revised component unexposed record
* Parameters OUT: Revised component exposed column record
*                 Revised component unexposed column record
* Purpose       : The procedure will look at the columns that the user has  not
*                 filled in for an update record and will copy values for those
*                 columns from the old record. If the columns that the user has
*                 given are having a missing or any other then those columns
*                 are not copied.
********************************************************************************/
PROCEDURE Populate_Null_Columns
( p_revised_item_rec           IN  ENG_Eco_PUB.Revised_item_Rec_Type
, p_old_revised_item_rec       IN  Eng_Eco_Pub.Revised_item_Rec_Type
, p_rev_item_unexp_Rec         IN  Eng_Eco_Pub.Rev_item_Unexposed_Rec_Type
, p_old_rev_item_unexp_Rec     IN  Eng_Eco_Pub.Rev_item_Unexposed_Rec_Type
, x_revised_item_Rec           IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
, x_rev_item_unexp_Rec         IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
)
IS
l_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type :=
                        p_revised_item_rec;
l_rev_item_unexp_rec    Eng_Eco_Pub.Rev_item_Unexposed_Rec_Type :=
                        p_rev_item_unexp_rec;
BEGIN
    IF l_revised_item_rec.disposition_type IS NULL THEN
       l_revised_item_rec.disposition_type :=
                        p_old_revised_item_rec.disposition_type;
    END IF;
             --Bug 16340624 begin

 	    IF l_revised_item_rec.transfer_or_copy is NULL OR
 	      l_revised_item_rec.transfer_or_copy = FND_API.G_MISS_CHAR
 	   THEN
 	      l_revised_item_rec.transfer_or_copy :=
p_old_revised_item_rec.transfer_or_copy;
 	   END IF;

 	    IF (l_revised_item_rec.transfer_or_copy = 'T' OR
l_revised_item_rec.transfer_or_copy = 'C')
 	  THEN
 	    IF l_revised_item_rec.alternate_selection_code is NULL OR
 	      l_revised_item_rec.alternate_selection_code = FND_API.G_MISS_NUM
 	   THEN
 	      l_revised_item_rec.alternate_selection_code :=
p_old_revised_item_rec.alternate_selection_code;
 	   END IF;

 	   IF l_revised_item_rec.selection_option is NULL OR
 	      l_revised_item_rec.selection_option = FND_API.G_MISS_NUM
 	   THEN
 	      l_revised_item_rec.selection_option :=
p_old_revised_item_rec.selection_option;
 	   END IF;

 	  IF l_revised_item_rec.selection_date is NULL OR
 	      l_revised_item_rec.selection_date = FND_API.G_MISS_DATE
 	   THEN
 	      l_revised_item_rec.selection_date :=
p_old_revised_item_rec.selection_date;
 	   END IF;

 	  IF l_revised_item_rec.transfer_or_copy_item is NULL OR
 	      l_revised_item_rec.transfer_or_copy_item = FND_API.G_MISS_NUM
 	   THEN
 	      l_revised_item_rec.transfer_or_copy_item :=
p_old_revised_item_rec.transfer_or_copy_item;
 	  END IF;

 	  IF l_revised_item_rec.transfer_or_copy_bill is NULL OR
 	      l_revised_item_rec.transfer_or_copy_bill = FND_API.G_MISS_NUM
 	   THEN
 	      l_revised_item_rec.transfer_or_copy_bill :=
p_old_revised_item_rec.transfer_or_copy_bill;
 	  END IF;

 	  IF l_revised_item_rec.transfer_or_copy_routing is NULL OR
 	      l_revised_item_rec.transfer_or_copy_routing = FND_API.G_MISS_NUM
 	   THEN
 	      l_revised_item_rec.transfer_or_copy_routing :=
p_old_revised_item_rec.transfer_or_copy_routing;
 	  END IF;

 	 END IF;
 	    --bug 16340624 (end)


       IF l_revised_item_rec.earliest_Effective_date IS NULL THEN
        l_revised_item_rec.earliest_effective_date :=
                        p_old_revised_item_rec.earliest_effective_date;
    END IF;

    IF l_revised_item_rec.attribute_category IS NULL THEN
        l_revised_item_rec.attribute_category :=
                        p_old_revised_item_rec.attribute_category;
    END IF;

    IF l_revised_item_rec.attribute2 IS NULL THEN
        l_revised_item_rec.attribute2 := p_old_revised_item_rec.attribute2;
    END IF;

    IF l_revised_item_rec.attribute3 IS NULL THEN
        l_revised_item_rec.attribute3 := p_old_revised_item_rec.attribute3;
    END IF;

    IF l_revised_item_rec.attribute4 IS NULL THEN
        l_revised_item_rec.attribute4 := p_old_revised_item_rec.attribute4;
    END IF;

    IF l_revised_item_rec.attribute5 IS NULL THEN
        l_revised_item_rec.attribute5 := p_old_revised_item_rec.attribute5;
    END IF;

    IF l_revised_item_rec.attribute7 IS NULL THEN
        l_revised_item_rec.attribute7 := p_old_revised_item_rec.attribute7;
    END IF;

    IF l_revised_item_rec.attribute8 IS NULL THEN
        l_revised_item_rec.attribute8 := p_old_revised_item_rec.attribute8;
    END IF;

    IF l_revised_item_rec.attribute9 IS NULL THEN
        l_revised_item_rec.attribute9 := p_old_revised_item_rec.attribute9;
    END IF;

    IF l_revised_item_rec.attribute11 IS NULL THEN
        l_revised_item_rec.attribute11 := p_old_revised_item_rec.attribute11;
    END IF;

    IF l_revised_item_rec.attribute12 IS NULL THEN
        l_revised_item_rec.attribute12 := p_old_revised_item_rec.attribute12;
    END IF;

    IF l_revised_item_rec.attribute13 IS NULL THEN
        l_revised_item_rec.attribute13 := p_old_revised_item_rec.attribute13;
    END IF;

    IF l_revised_item_rec.attribute14 IS NULL THEN
        l_revised_item_rec.attribute14 := p_old_revised_item_rec.attribute14;
    END IF;

    IF l_revised_item_rec.attribute15 IS NULL THEN
        l_revised_item_rec.attribute15 := p_old_revised_item_rec.attribute15;
    END IF;

    IF l_revised_item_rec.status_type IS NULL THEN
        l_revised_item_rec.status_type := p_old_revised_item_rec.status_type;
        l_rev_item_unexp_rec.status_code := p_old_rev_item_unexp_rec.status_code; -- Added for bug 3618676
    END IF;

    IF l_revised_item_rec.start_effective_date IS NULL THEN
        l_revised_item_rec.start_effective_date :=
                        p_old_revised_item_rec.start_effective_date;
    END IF;

    IF l_rev_item_unexp_rec.bill_sequence_id IS NULL THEN
        l_rev_item_unexp_rec.bill_sequence_id :=
                p_old_rev_item_unexp_rec.bill_sequence_id;
    END IF;

    IF l_revised_item_rec.mrp_active  IS NULL THEN
        l_revised_item_rec.mrp_active := p_old_revised_item_rec.mrp_active;
    END IF;

    IF l_revised_item_rec.update_wip IS NULL THEN
        l_revised_item_rec.update_wip := p_old_revised_item_rec.update_wip;
    END IF;

    /* Added below code for bug 22134406 to handle NULL values of 'Change Description'.
       It retais the old value if we do not provide any value for 'Change Description'. */

    IF l_revised_item_rec.Change_Description is NULL THEN
 	l_revised_item_rec.Change_Description := p_old_revised_item_rec.Change_Description;
    END IF;



    --
    -- Simply copy the unexposed columns from the old record to the new record
    -- so that no values are lost in the return process.
    --
    IF l_rev_item_unexp_rec.use_up_item_id IS NULL
    THEN
        l_rev_item_unexp_rec.use_up_item_id :=
                        p_old_rev_item_unexp_rec.use_up_item_id;
    END IF;


    l_rev_item_unexp_rec.revised_item_sequence_id :=
                        p_old_rev_item_unexp_rec.revised_item_sequence_id;

    l_rev_item_unexp_rec.auto_implement_date :=
                        p_old_rev_item_unexp_rec.auto_implement_date;

    l_rev_item_unexp_rec.cancellation_date :=
                        p_old_rev_item_unexp_rec.cancellation_date;

    -- Added the 'null' condition by MK on 02/15/2001
    IF l_rev_item_unexp_rec.bill_sequence_id IS NULL
    THEN
        l_rev_item_unexp_rec.bill_sequence_id :=
                p_old_rev_item_unexp_rec.bill_sequence_id;
    END IF ;

    l_rev_item_unexp_rec.requestor_id :=
                p_old_rev_item_unexp_rec.requestor_id;

    l_rev_item_unexp_rec.use_up := p_old_rev_item_unexp_rec.use_up;

    IF l_revised_item_rec.use_up_plan_name IS NULL THEN
        l_revised_item_rec.use_up_plan_name :=
                p_old_revised_item_rec.use_up_plan_name;
    END IF;

    IF l_revised_item_rec.attribute1 IS NULL THEN
        l_revised_item_rec.attribute1 := p_old_revised_item_rec.attribute1;
    END IF;

    IF l_revised_item_rec.attribute6 IS NULL THEN
        l_revised_item_rec.attribute6 := p_old_revised_item_rec.attribute6;
    END IF;

    IF l_revised_item_rec.attribute10 IS NULL THEN
        l_revised_item_rec.attribute10 := p_old_revised_item_rec.attribute10;
    END IF;

    -- Added by MK on 10/24/2000
    IF l_revised_item_rec.updated_revised_item_revision IS NULL THEN
        l_revised_item_rec.updated_revised_item_revision := p_old_revised_item_rec.new_revised_item_revision ;
    END IF;

    /*********************************************************************
    -- Added by MK on 09/01/2000
    -- Enhancement for New ECO Effectivities and ECO Routing
    --
    *********************************************************************/

    IF l_revised_item_rec.from_cumulative_quantity IS NULL THEN
        l_revised_item_rec.from_cumulative_quantity := p_old_revised_item_rec.from_cumulative_quantity;
    END IF;

    IF l_revised_item_rec.lot_number IS NULL THEN
        l_revised_item_rec.lot_number := p_old_revised_item_rec.lot_number ;
    END IF;

    IF l_revised_item_rec.completion_subinventory IS NULL THEN
        l_revised_item_rec.completion_subinventory := p_old_revised_item_rec.completion_subinventory;
    END IF;

    IF l_revised_item_rec.priority IS NULL THEN
        l_revised_item_rec.priority := p_old_revised_item_rec.priority;
    END IF;

    IF l_revised_item_rec.ctp_flag IS NULL THEN
        l_revised_item_rec.ctp_flag := p_old_revised_item_rec.ctp_flag ;
    END IF;

    -- Added by MK on 10/24/2000
    IF l_revised_item_rec.updated_routing_revision IS NULL THEN
        l_revised_item_rec.updated_routing_revision := p_old_revised_item_rec.new_routing_revision ;
    END IF;

    IF l_revised_item_rec.routing_comment IS NULL THEN
        l_revised_item_rec.routing_comment := p_old_revised_item_rec.routing_comment ;
    END IF;

    -- Added by MK on 10/06/2000
    IF l_revised_item_rec.eco_for_production IS NULL THEN
        l_revised_item_rec.eco_for_production :=
                     p_old_revised_item_rec.eco_for_production ;
    END IF;

    --
    -- Simply copy the unexposed columns from the old record to the new record
    -- so that no values are lost in the return process.
    --
    IF l_rev_item_unexp_rec.from_wip_entity_id IS NULL
    THEN
        l_rev_item_unexp_rec.from_wip_entity_id :=
                        p_old_rev_item_unexp_rec.from_wip_entity_id ;
    END IF;

    IF l_rev_item_unexp_rec.to_wip_entity_id IS NULL
    THEN
        l_rev_item_unexp_rec.to_wip_entity_id :=
                        p_old_rev_item_unexp_rec.to_wip_entity_id ;
    END IF;

    IF l_rev_item_unexp_rec.completion_locator_id IS NULL
    THEN
        l_rev_item_unexp_rec.completion_locator_id :=
                        p_old_rev_item_unexp_rec.completion_locator_id ;
    END IF;

    -- Added the 'null' condition by MK on 02/15/2001
    IF l_rev_item_unexp_rec.routing_sequence_id IS NULL
    THEN
       l_rev_item_unexp_rec.routing_sequence_id :=
                p_old_rev_item_unexp_rec.routing_sequence_id;
    END IF ;

    l_rev_item_unexp_rec.cfm_routing_flag :=
                p_old_rev_item_unexp_rec.cfm_routing_flag ;

    -- Added by MK on 09/01/2000


    x_revised_item_rec := l_revised_item_rec;
    x_rev_item_unexp_rec := l_rev_item_unexp_rec;

END Populate_Null_Columns;


/*****************************************************************************
* Function      : Check_Alternate_Already_Exists
* Parameters IN : Revised item
*                 Alternate_Bom_Designator
*                 Organization Id
* Returns       : True if the Alternate bill exists otherwise False.
* Purpose       : Function will check if the a bill for given revised item with
*                 the given alternate designator exists. If it does then the
*                 function returns TRUE otherwise FALSE.
*******************************************************************************/
FUNCTION Check_Alternate_Already_Exists
( p_revised_item_id IN NUMBER
, p_alternate_bom_designator IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN BOOLEAN
IS
  cursor c_CheckAlternate IS
        SELECT 1
          FROM BOM_BILL_OF_MATERIALS
         WHERE assembly_item_id = p_revised_item_id
           AND organization_id = p_organization_id
           AND ((alternate_bom_designator IS NULL
                 AND p_alternate_bom_designator IS NULL)
             OR alternate_bom_designator = p_alternate_bom_designator);
BEGIN

  FOR l_Count IN c_CheckAlternate LOOP
        RETURN TRUE;

  END LOOP;

  RETURN FALSE;

END Check_Alternate_Already_Exists;

/*****************************************************************************
* Function      : Compatible_Primary_Bill_Exists
* Parameters IN : Revised item Id
*                 Change Notice
*                 Organization Id
* Returns       : True if the process succeed, False otherwise
* Purpose       : Function will check if the primary bill exists with a
*                 compatible type.
******************************************************************************/
FUNCTION Compatible_Primary_Bill_Exists
(  p_revised_item_id    IN NUMBER
 , p_change_notice      IN VARCHAR2
 , p_organization_id    IN NUMBER
) RETURN BOOLEAN
IS
  l_assembly_type       NUMBER := 0;

  cursor c_CheckBillType IS
                SELECT 1
                  FROM BOM_BILL_OF_MATERIALS
                 WHERE assembly_item_id = p_revised_item_id
                   AND organization_id  = p_organization_id
                   AND alternate_bom_designator is null
                   AND ((assembly_type = 1 and l_assembly_type = 1)
                        or l_assembly_type = 2);
BEGIN

        l_assembly_type := ENG_Globals.Get_ECO_Assembly_Type
                           (  p_change_notice   => p_change_notice
                            , p_organization_id => p_organization_id
                            );

        FOR l_Count IN c_CheckBillType LOOP

                RETURN TRUE;
        END LOOP;

        RETURN FALSE;

END Compatible_Primary_Bill_Exists;



/*****************************************************************************
* Added by MK on 09/01/2000 for New ECO Effectivity and ECO Routing
*
* Function      : Check_Alt_Rtg_Already_Exists
* Parameters IN : Revised item
*                 Alternate_Bom_Designator
*                 Organization Id
* Returns       : True if the Alternate bill exists otherwise False.
* Purpose       : Function will check if the a bill for given revised item with
*                 the given alternate designator exists. If it does then the
*                 function returns TRUE otherwise FALSE.
*******************************************************************************/
FUNCTION Check_Alt_Rtg_Already_Exists
( p_revised_item_id IN NUMBER
, p_alternate_bom_designator IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN BOOLEAN
IS
  cursor c_CheckAlternate IS
        SELECT 1
        FROM BOM_OPERATIONAL_ROUTINGS
        WHERE assembly_item_id = p_revised_item_id
        AND   organization_id  = p_organization_id
        AND   alternate_routing_designator = p_alternate_bom_designator;
BEGIN

  FOR l_Count IN c_CheckAlternate LOOP
        RETURN TRUE;
  END LOOP;

  RETURN FALSE;

END Check_Alt_Rtg_Already_Exists;

/*****************************************************************************
* Function      : Compatible_Primary_Rtg_Exists
* Parameters IN : Revised item Id
*                 Change Notice
*                 Organization Id
* Returns       : True if the process succeed, False otherwise
* Purpose       : Function will check if the primary routing exists with a
*                 compatible type.
******************************************************************************/
FUNCTION Compatible_Primary_Rtg_Exists
(  p_revised_item_id    IN NUMBER
 , p_change_notice      IN VARCHAR2
 , p_organization_id    IN NUMBER
) RETURN BOOLEAN
IS
  l_routing_type       NUMBER := 0;

  cursor c_CheckRtgType IS
                SELECT 1
                  FROM BOM_OPERATIONAL_ROUTINGS
                 WHERE assembly_item_id = p_revised_item_id
                   AND organization_id  = p_organization_id
                   AND alternate_routing_designator is null
                   AND ((routing_type = 1 and l_routing_type = 1)
                        or l_routing_type = 2);
BEGIN

        l_routing_type := ENG_Globals.Get_ECO_Assembly_Type
                           (  p_change_notice   => p_change_notice
                            , p_organization_id => p_organization_id
                            );

        FOR l_Count IN c_CheckRtgType LOOP
                RETURN TRUE;
        END LOOP;

        RETURN FALSE;

END Compatible_Primary_Rtg_Exists;
-- Added by MK on 09/01/2000

/****************************************************************************
* Function      : Initialize Bill Sequence Id
* Returns       : Number
* Purpose       : Will generate a new bill sequence id and return
*
*****************************************************************************/
FUNCTION Initialize_Bill_Sequence_Id
RETURN NUMBER
IS
  l_bill_sequence_id NUMBER;
  cursor bill_seq_id is select bom_inventory_components_s.nextval from sys.dual;
BEGIN
    open bill_seq_id;
    fetch bill_seq_id into l_bill_sequence_id;
    close bill_seq_id;

    RETURN l_bill_sequence_id;
END Initialize_Bill_Sequence_Id;


/****************************************************************************
* Added by MK on 09/01/2000 for New ECO Effectivity and ECO Routing
*
* Function      : Get_Current_Rtg_Revision
* Paramters IN  : Revised itemid
*                 Organization ID
*                 Revision Date
* Purpose       : Function will return the current item revision by looking
*                 at the mtl_rtg_item_revisions table and return the revision that
*                 has implementation date NOT NULL and is currently effective.
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
       WHERE  INVENTORY_ITEM_ID = p_revised_item_id
       AND    ORGANIZATION_ID = p_organization_id
       AND    EFFECTIVITY_DATE <= p_revision_date
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
-- Added by MK on 09/02/2000


/******************************************************************************
* Function      : Get_Schedule_Date
* Parameters IN : Use_UP_Item_Id
*                 Plan Name
*                 Organization Id
*                 Revised Item ID
*                 Bill Sequence ID
* Returns       : Date
* Purpose       : If the user has update the use up plan or the use up item
*                 then the schedule date also needs to be changed. This schedule
*                 is has to be such that it is not greater than any of the
*                 components on the ECO and should be within the range of the
*                 given mrp plan.
******************************************************************************/
FUNCTION Get_Scheduled_Date
( p_use_up_item_id IN NUMBER
, p_use_up_plan_name IN VARCHAR2
, p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_bill_sequence_id IN NUMBER
) RETURN DATE
IS
        l_scheduled_date        DATE := NULL;
        l_sequence_id           NUMBER := NULL;
        l_assembly_item_id      NUMBER := NULL;
        l_inventory_use_up_date DATE := NULL;
        CURSOR SCHED_DATE IS
        SELECT si.inventory_use_up_date, bl.assembly_item_id
          FROM mrp_system_items si,
               bom_lists bl
         WHERE bl.sequence_id = l_sequence_id
           AND ( bl.assembly_item_id = p_revised_item_id
                 OR bl.assembly_item_id IN
                 ( SELECT component_item_id
                     FROM bom_inventory_components
                    WHERE bill_sequence_id = p_bill_sequence_id
                      AND nvl(acd_type,1) <> 3
                      AND effectivity_date <= si.inventory_use_up_date
                      AND nvl(disable_date, si.inventory_use_up_date + 1) >
                          si.inventory_use_up_date
                    )
                 )
           AND si.organization_id =  p_organization_id
           AND si.compile_designator = p_use_up_plan_name
           AND si.inventory_item_id = bl.assembly_item_id
           AND si.inventory_use_up_date >= trunc(sysdate)
           AND (EXISTS ( SELECT 'valid'
                          FROM mrp_plans pl2
                         WHERE pl2.organization_id = p_organization_id
                           AND pl2.explosion_completion_date <=
                               pl2.data_completion_date
                           AND pl2.data_completion_date <=
                               pl2.plan_completion_date
                           AND pl2.plan_type in (1,2)
                           AND pl2.compile_designator = p_use_up_plan_name
                        )
		OR
		EXISTS ( --added by arudresh, bug: 3725067
                         SELECT plan_completion_date
			 FROM mrp_plan_organizations_v
			 WHERE compile_designator = p_use_up_plan_name
			 AND planned_organization = p_organization_id
		       )
		);
BEGIN
        l_sequence_id := ENG_REVISED_ITEMS_PKG.Get_BOM_Lists_Seq_Id;

        ENG_REVISED_ITEMS_PKG.Insert_BOM_Lists
                       (  X_Revised_Item_Id       => p_revised_item_id
                        , X_Sequence_Id           => l_sequence_id
                        , X_Bill_Sequence_Id      => p_bill_sequence_id
                        );

        FOR l_sched_date IN SCHED_DATE LOOP
                IF l_sched_date.assembly_item_id = p_use_up_item_id
                THEN
                        l_scheduled_date := l_sched_date.inventory_use_up_date;
                END IF;
        END LOOP;

        ENG_REVISED_ITEMS_PKG.Delete_BOM_Lists (X_Sequence_Id => l_sequence_id);

        RETURN l_scheduled_date;

END Get_Scheduled_Date;

/***************************************************************************
* Function      : Get_Requestor
* Pramaeters IN : Change notice
*                 Organization Id
* Returns       : Requestor Id
* Purpose       : The function will query the requestor from the change notice
*                 and return it as the requestor for cancellation, if the user
*                 has not given a requestor name.
******************************************************************************/
FUNCTION Get_Requestor (  p_Change_Notice       IN  VARCHAR2
                        , p_organization_id     IN  NUMBER
                        )
RETURN NUMBER
IS
        l_requestor     NUMBER;
BEGIN
        SELECT requestor_id
          INTO l_requestor
          FROM eng_engineering_changes
         WHERE change_notice   = p_change_notice
           AND organization_id = p_organization_id;

        RETURN l_requestor;

        EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;

END Get_Requestor;


/*******************************************************************************
* Procedure     : Entity Defaulting
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record
* Parameters OUT: Revised item exposed column record
*                 Revised item unexposed column record
* Returns       : None
* Purpose       : Entity defaulting will default any values remaining values that
*                 need conditional defaulting i.e defaulting which is based on
*                 one or more columns from the entity column values.
******************************************************************************/
PROCEDURE Entity_Defaulting
(   p_revised_item_rec          IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_item_unexp_rec        IN  ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   p_old_revised_item_rec      IN  Eng_Eco_Pub.Revised_Item_Rec_Type
,   p_old_rev_item_unexp_rec    IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   p_control_rec               IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_revised_item_rec          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Rec_Type
,   x_rev_item_unexp_rec        IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
        l_schedule_id           NUMBER := NULL;
        l_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type :=
                                p_revised_item_rec;
        l_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type :=
                                p_rev_item_unexp_rec;
        l_processed             BOOLEAN := FALSE;
        l_current_revision      VARCHAR2(3) := 999;
        l_err_text              VARCHAR2(2000);

        l_ECO_approved          NUMBER := 0;

        CURSOR c_status (cp_change_id IN NUMBER)
        IS
        SELECT ecsv.status_code
        FROM   eng_change_statuses_vl ecsv
        WHERE  ecsv.status_code IN (SELECT els1.status_code
			                              FROM eng_lifecycle_statuses els1
                                    WHERE els1.entity_name='ENG_CHANGE'
                                          AND els1.entity_id1 = cp_change_id
			                                    AND els1.active_flag = 'Y'
                                          AND els1.sequence_number = (SELECT min(els2.sequence_number)
			                                                                FROM eng_lifecycle_statuses els2
					                                                            WHERE els2.entity_name='ENG_CHANGE'
					                                                                  AND els2.entity_id1 = cp_change_id
					                                                                  AND els2.active_flag = 'Y'));
        CURSOR c_CheckApproval IS SELECT 1
                      FROM ENG_ENGINEERING_CHANGES
                     WHERE change_notice = p_revised_item_rec.eco_name
                       AND organization_id =
                                        p_rev_item_unexp_rec.organization_id
                       AND approval_status_type = 5;

                l_rev_already_exists    NUMBER := 0;
        CURSOR c_CheckRevision ( p_revision     VARCHAR2) IS
                SELECT 1
                  FROM MTL_ITEM_REVISIONS
                 WHERE inventory_item_id = p_rev_item_unexp_rec.revised_item_id
                   AND organization_id   = p_rev_item_unexp_rec.organization_id
                   AND revision = p_revision;

        CURSOR c_Get_Bill_Seq
        IS
        SELECT bill_sequence_id
          FROM bom_bill_of_materials
         WHERE assembly_item_id = p_rev_item_unexp_rec.revised_item_id
           AND organization_id   = p_rev_item_unexp_rec.organization_id
           AND NVL(alternate_bom_designator, 'none') =
               NVL(p_revised_item_rec.alternate_bom_code, 'none');


        /************************************************************************
        -- Followings are added for New ECO Effectivity and ECO Routing
        -- by MK 09/01/2000
        ************************************************************************/
        l_current_rtg_revision      VARCHAR2(3) := 999;

        CURSOR c_Rtg_CheckRevision ( p_revision     VARCHAR2) IS
                SELECT 1
                FROM   MTL_RTG_ITEM_REVISIONS
                WHERE  inventory_item_id = p_rev_item_unexp_rec.revised_item_id
                AND    organization_id   = p_rev_item_unexp_rec.organization_id
                AND    process_revision  = p_revision;

        l_rtg_rev_already_exists    NUMBER := 0;

        CURSOR c_Get_Routing_Seq
        IS
             SELECT routing_sequence_id
             FROM   BOM_OPERATIONAL_ROUTINGS
             WHERE  assembly_item_id = p_rev_item_unexp_rec.revised_item_id
             AND    organization_id   = p_rev_item_unexp_rec.organization_id
             AND    NVL(alternate_routing_designator, 'none') =
                    NVL(p_revised_item_rec.alternate_bom_code, 'none');

        -- Added by MK on 09/01/2000


        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        -- Added for bug 4210718
        l_revEffStrc_exists     NUMBER;
        l_structure_type_id     NUMBER;
        l_cp_not_allowed        NUMBER;

    -- R12: OPM Convergence Project
    CURSOR c_Get_Item_Details
    IS
    SELECT msi.bom_item_type , msi.tracking_quantity_ind
      FROM mtl_system_items msi
     WHERE msi.inventory_item_id = p_rev_item_unexp_rec.revised_item_id
       AND msi.organization_id   = p_rev_item_unexp_rec.organization_id;

    CURSOR c_Get_Org_Details
    IS
    SELECT process_enabled_flag
      FROM mtl_parameters
     WHERE organization_id = p_rev_item_unexp_rec.organization_id;

    l_Item_Details_Rec c_Get_Item_Details%ROWTYPE;
    l_Org_Details_Rec  c_Get_Org_Details%ROWTYPE;
   l_caller_type varchar2(20);
BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing Entity Level Defaulting . . .'); END IF;

        -- Initialize flags

        G_SCHED_DATE_CHANGED := FALSE;

        G_DEL_UPD_INS_ITEM_REV := 0;

        G_CREATE_ALTERNATE := FALSE;

        G_ECO_FOR_PROD_CHANGED := FALSE ; -- Added by MK on 10/24/2000

        G_OLD_SCHED_DATE := NULL; -- Bug 6657209

        l_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        ENG_Globals.Check_Approved_For_Process
        ( p_change_notice       => l_revised_item_rec.eco_name
        , p_organization_id     => l_rev_item_unexp_rec.organization_id
        , x_processed           => l_processed
        , x_err_text            => l_err_text
        );

        IF l_processed
        THEN
            IF p_old_revised_item_rec.status_type = 4
            THEN
                l_revised_item_rec.status_type := 1;    -- Open
            END IF;

            l_Token_Tbl(1).Token_Name := 'ECO_NAME';
            l_Token_Tbl(1).Token_Value := p_revised_item_rec.eco_name;

            Error_Handler.Add_Error_Token
            (  p_Message_Name   => 'ENG_APPROVE_WARNING'
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_Token_Tbl      => l_Token_Tbl
             , p_message_type   => 'W'
              );

            l_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
            l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        END IF;

       	-- Syalaman - Added for bug 6371493.
        IF (Eng_Globals.Get_PLM_Or_ERP_Change(l_revised_item_rec.eco_name, l_rev_item_unexp_rec.organization_id) = 'PLM'
            AND l_rev_item_unexp_rec.status_code IS NULL)
        THEN
          IF l_revised_item_rec.transaction_type = 'CREATE'
	        THEN
		        OPEN c_status(l_rev_item_unexp_rec.change_id);
            FETCH c_status INTO l_rev_item_unexp_rec.status_code;
		        CLOSE c_status;
	        ELSE
            l_rev_item_unexp_rec.status_code := p_old_rev_item_unexp_rec.status_code;
          END IF;
        END IF;

        -- Added by MK on 01/03/01
        -- If eco for production flag is Y ,
        -- Revisions should be null. Because this eco is only
        -- applied to work orders.
        --
        IF l_revised_item_rec.eco_for_production = 1 THEN

           IF  l_revised_item_rec.new_revised_item_revision IS NOT NULL OR
               l_revised_item_rec.new_revised_item_revision <> FND_API.G_MISS_CHAR OR
               l_revised_item_rec.updated_revised_item_revision IS NOT NULL OR
               l_revised_item_rec.updated_revised_item_revision <> FND_API.G_MISS_CHAR OR
               l_revised_item_rec.new_routing_revision IS NOT NULL OR
               l_revised_item_rec.new_routing_revision <> FND_API.G_MISS_CHAR OR
               l_revised_item_rec.updated_routing_revision IS NOT NULL OR
               l_revised_item_rec.updated_routing_revision <> FND_API.G_MISS_CHAR
           THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RIT_SET_REV_NULL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
               END IF;
           END IF ;

           /**********************************************************************************
	      Changes of bug 19362617:
	      Added delete statements on mtl_item_revisions_b and mtl_rtg_item_revisions.
	      Added these delete statements conditionally since it is not required to execute
	      both delete statements for the scenario where we define only one revision.
	   ***********************************************************************************/
	   IF l_revised_item_rec.new_revised_item_revision IS NOT NULL OR
	      l_revised_item_rec.updated_revised_item_revision IS NOT NULL
	   THEN
              DELETE FROM mtl_item_revisions_b
	      WHERE inventory_item_id  = l_rev_item_unexp_rec.revised_item_id
	      AND organization_id      = l_rev_item_unexp_rec.organization_id
	      AND revision             = NVL(l_revised_item_rec.new_revised_item_revision, l_revised_item_rec.updated_revised_item_revision)
	      AND change_notice        = l_revised_item_rec.Eco_Name
	      AND implementation_date IS NULL;
	   END IF;

           IF l_revised_item_rec.new_routing_revision IS NOT NULL OR
	      l_revised_item_rec.updated_routing_revision IS NOT NULL
	   THEN
	      DELETE FROM mtl_rtg_item_revisions
              WHERE inventory_item_id  = l_rev_item_unexp_rec.revised_item_id
              AND organization_id      = l_rev_item_unexp_rec.organization_id
              AND process_revision     = NVL(l_revised_item_rec.new_routing_revision, l_revised_item_rec.updated_routing_revision)
              AND change_notice        = l_revised_item_rec.Eco_Name
              AND implementation_date IS NULL;
	   END IF;

           l_revised_item_rec.new_revised_item_revision := NULL ;
           l_revised_item_rec.updated_revised_item_revision := NULL ;
           l_revised_item_rec.new_routing_revision := NULL ;
           l_revised_item_rec.updated_routing_revision := NULL ;

        END IF ;


        -- Modified by MK on 10/24/00
        IF ((  (l_revised_item_rec.updated_revised_item_revision <>
                                 l_revised_item_rec.new_revised_item_revision )
               OR
               ( l_revised_item_rec.updated_revised_item_revision IS NULL AND
                 l_revised_item_rec.new_revised_item_revision IS NOT NULL )
               OR
               ( l_revised_item_rec.updated_revised_item_revision IS NOT NULL AND
                 l_revised_item_rec.new_revised_item_revision IS NULL )
             )
             AND
             l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
            )
        OR
            l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN


                IF l_revised_item_rec.transaction_type =
                   ENG_Globals.G_OPR_CREATE
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug('In transaction type = Create, Checking for revised item revision: ' ||
        p_revised_item_rec.new_revised_item_revision);
END IF;
                        FOR x_count IN
                            c_CheckRevision
                            ( p_revision        =>
                              l_revised_item_rec.new_revised_item_revision
                             )
                        LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Current Revision Found . . .'); END IF;

                                 l_rev_already_exists := 1;
                         END LOOP;

                        l_current_revision :=
                        Get_Current_Item_Revision
                        (  p_revised_item_id    =>
                                        l_rev_item_unexp_rec.revised_item_id
                        , p_organization_id     =>
                                        l_rev_item_unexp_rec.organization_id
                        , p_revision_date       => SYSDATE
                        );

                        -- Can insert a revision into MTL_ITEM_REVISIONS only
                        -- if it is not the same as the Current Revision

                        IF l_revised_item_rec.new_revised_item_revision <>
                           l_current_revision AND
                           l_rev_already_exists = 0
                        THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Insert . . .'); END IF;

                                G_DEL_UPD_INS_ITEM_REV := 3;
                        ELSIF l_rev_already_exists = 1 THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Update . . .'); END IF;

                                G_DEL_UPD_INS_ITEM_REV := 2;
                        END IF;

                ELSIF l_revised_item_rec.transaction_type =
                      ENG_Globals.G_OPR_UPDATE
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug('In transaction type = Update , Checking for revised item revision: ' ||
        l_revised_item_rec.updated_revised_item_revision );
END IF;

                        l_current_revision :=
                        Get_Current_Item_Revision
                        (  p_revised_item_id =>
                                        l_rev_item_unexp_rec.revised_item_id
                        , p_organization_id =>
                                        l_rev_item_unexp_rec.organization_id
                        , p_revision_date => SYSDATE
                        );

                        FOR x_count IN
                            c_CheckRevision
                            ( p_revision        =>
                              l_revised_item_rec.updated_revised_item_revision
                             )
                        LOOP
                                l_rev_already_exists := 1;
                        END LOOP;

                        IF  l_rev_already_exists = 0 AND
                            l_revised_item_rec.updated_revised_item_revision <>
                            FND_API.G_MISS_CHAR
                        THEN
                                --
                                -- Insert new revision information into
                                -- MTL_ITEM_REVISIONS
                                --
                             IF l_revised_item_rec.new_revised_item_revision IS NULL OR
                                l_revised_item_rec.new_revised_item_revision
                                =  l_current_revision -- Added by MK on 02/13/2001
                             THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Insert . . .'); END IF;

                                G_DEL_UPD_INS_ITEM_REV := 3;
                             ELSE
                                --
                                -- Modified by MK on 10/24/00
                                -- Update new revision information into
                                -- MTL_ITEM_REVISIONS
                                --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Update. . .'); END IF;
                                G_DEL_UPD_INS_ITEM_REV := 2 ;
                             END IF ;

                        ELSIF ( ( l_rev_already_exists = 0
			        AND
                                (
				  l_revised_item_rec.updated_revised_item_revision =
                                  FND_API.G_MISS_CHAR OR
                                  l_revised_item_rec.updated_revised_item_revision
                                  IS NULL )
                              )
                              OR  -- Added by MK on 02/13/2001 for Bug 1641488
                              ( l_rev_already_exists = 1 AND
                                l_revised_item_rec.updated_revised_item_revision
                                =  l_current_revision
                              ))
                              -- and l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_DELETE
			      -- Bug 3629755
			      -- Commented as it is within the
			      -- l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE Condition
                        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Delete  . . .'); END IF;

                                G_DEL_UPD_INS_ITEM_REV := 1;

                        ELSIF l_rev_already_exists = 1 AND
                              l_revised_item_rec.updated_revised_item_revision
                              <> l_current_revision
                        THEN

                                -- Update new item revision information in
                                -- MTL_ITEM_REVISIONS
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Item Revision set for Update. . .'); END IF;
                                G_DEL_UPD_INS_ITEM_REV := 2;

                        END IF; /* If Update Ends */

                END IF; /* If Create or Update Ends */

        END IF; /* Main If  ends */
        --
        -- Set the global flag g_create_alternate to TRUE if the user is
        -- trying to create an alternate
        --
        IF ((Eng_Globals.Get_PLM_Or_ERP_Change(l_revised_item_rec.eco_name, l_rev_item_unexp_rec.organization_id) = 'PLM' AND
             (l_revised_item_rec.alternate_bom_code IS NOT NULL OR
              l_rev_item_unexp_rec.structure_type_id IS NOT NULL)
            )
            OR
            (l_revised_item_rec.alternate_bom_code IS NOT NULL AND
             Compatible_Primary_Bill_Exists
             (  p_revised_item_id => l_rev_item_unexp_rec.revised_item_id
              , p_change_notice   => l_revised_item_rec.eco_name
              , p_organization_id => l_rev_item_unexp_rec.organization_id
             ) AND
             l_revised_item_rec.alternate_bom_code <> fnd_api.G_MISS_CHAR)
            ) AND
            NOT Check_Alternate_Already_Exists
            (  p_revised_item_id          => l_rev_item_unexp_rec.revised_item_id
             , p_alternate_bom_designator => l_revised_item_rec.alternate_bom_code
             , p_organization_id          => l_rev_item_unexp_rec.organization_id
            )
        THEN
            -- Bug : 4210718
            -- Before creating the alternate check if there is change policy
            -- associated with it or a revision eff structure of the structure type
            -- has been created. Skip the alternate bom creation in these cases.
            l_cp_not_allowed := 2;
            l_structure_type_id := l_rev_item_unexp_rec.structure_type_id;
            Eng_Validate_Revised_Item.Check_Structure_Type_Policy
                ( p_inventory_item_id   => l_rev_item_unexp_rec.revised_item_id
                , p_organization_id     => l_rev_item_unexp_rec.organization_id
                , p_alternate_bom_code  => l_revised_item_rec.alternate_bom_code
                , x_structure_type_id   => l_structure_type_id
                , x_strc_cp_not_allowed => l_cp_not_allowed
                );
            IF Bom_Globals.Get_Debug = 'Y' THEN
                Error_Handler.Write_Debug('After Check if structure change policy is existing...'||to_char(l_cp_not_allowed)) ;
                Error_Handler.Write_Debug('structure change policy Structure Type Id...'||to_char(l_structure_type_id)) ;
            END IF;
            IF l_cp_not_allowed = 2
            THEN
                BEGIN
                    l_revEffStrc_exists := 2;
                    SELECT 1
                    INTO l_revEffStrc_exists
                    FROM bom_structures_b
                    WHERE effectivity_control = 4
                    AND assembly_item_id = l_rev_item_unexp_rec.revised_item_id
                    AND organization_id = l_rev_item_unexp_rec.organization_id
                    AND structure_type_id = l_structure_type_id
                    AND ROWNUM = 1;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     NULL;
                END;

                OPEN c_Get_Item_Details;
                FETCH c_Get_Item_Details INTO l_Item_Details_Rec;
                CLOSE c_Get_Item_Details;
                OPEN c_Get_Org_Details;
                FETCH c_Get_Org_Details INTO l_Org_Details_Rec;
                CLOSE c_Get_Org_Details;
                IF Bom_Globals.Get_Debug = 'Y' THEN
                    Error_Handler.Write_Debug('After Check if revision eff structure is existing...'||to_char(l_revEffStrc_exists)) ;
                END IF;
                -- Added check for OPM Convergence
                -- Bills shouldnt get created when the organization is a process enabled org
                -- and the assembly item is model or optional or it is dual UOM contralled
                -- then cannot create the bill
                l_caller_type:=BOM_GLOBALS.Get_Caller_Type();
                IF (l_revEffStrc_exists = 2
                    AND (l_Org_Details_Rec.process_enabled_flag = 'N'
                      OR (l_Org_Details_Rec.process_enabled_flag = 'Y' AND l_Item_Details_Rec.bom_item_type NOT IN (1,2)))
                    AND l_Item_Details_Rec.tracking_quantity_ind = 'P')
                    AND (l_caller_type<>'PROPAGATE') --If caller type is 'PROPAGATE' ,do not set G_CREATE_ALTERNATE to true
                THEN
                    l_rev_item_unexp_rec.bill_sequence_id := Initialize_Bill_Sequence_Id;
                    IF Bom_Globals.Get_Debug = 'Y' THEN
                        Error_Handler.Write_Debug('Bill seq id is generated for an alternate BOM . . .  : ' ||
                                                   to_char(l_rev_item_unexp_rec.bill_sequence_id ));
                    END IF;
                    IF Bom_Globals.Get_Debug = 'Y' THEN
                        Error_Handler.Write_Debug('Setting creat alternate bill flag to True. . .  ' ) ;
                    END IF;
                    G_CREATE_ALTERNATE := TRUE;
                END IF;
            END IF;
            -- End changes for Bug : 4210718


        END IF;

		    /*To fix the bug 21867082 as this code is related to PLM introduced a new condition to check is the request is from PLM or not*/
			-- fix for bug 13009796
			-- raise warning message if the existing structure presents and passed in parameter contains a new structure creation
			--
			IF (l_revised_item_rec.alternate_bom_code IS NOT NULL OR
				l_rev_item_unexp_rec.structure_type_id IS NOT NULL) AND NOT G_CREATE_ALTERNATE
				AND upper(l_revised_item_rec.transaction_type) = ENG_GLOBALS.G_OPR_CREATE
                AND Eng_Globals.Get_PLM_Or_ERP_Change(l_revised_item_rec.eco_name, l_rev_item_unexp_rec.organization_id) = 'PLM'
			THEN
				l_token_tbl.delete;
					Error_Handler.Add_Error_Token
							(  p_Message_Name       => 'ENG_IGNORE_STRUCTURE_CREATION'
							 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
							 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
							 , p_Token_Tbl          => l_Token_Tbl
							 , p_message_type       => 'W');
			END IF;
			-- End changes for Bug : 13009796



        /***********************************************************************
        -- Comment out by MK on 02/15/2001
        -- Because this code is duplicate the logic in Attribute Defaulting and
        -- ENG_Val_To_Id.Revised_Item_VID
        IF (l_rev_item_unexp_rec.bill_sequence_id IS NULL OR
            l_rev_item_unexp_rec.bill_sequence_id = FND_API.G_MISS_NUM)
           AND l_revised_item_rec.alternate_bom_code IS NULL  -- Added by MK on 10/31/00
        THEN
                --
                -- If the user is simply trying to add a revised item that
                -- already exists on another ECO and has a bill for it
                -- then get the bill sequence and default it.
                --
                FOR bill_seq IN c_Get_Bill_Seq LOOP
                        l_rev_item_unexp_rec.bill_sequence_id :=
                                bill_seq.bill_sequence_id;
                END LOOP;

                IF Bom_Globals.Get_Debug = 'Y'
                THEN
                        Error_Handler.Write_Debug('BillSeq Defaulted to: ' ||
                                to_char(l_rev_item_unexp_rec.bill_sequence_id));
                END IF;
        END IF;
        ************************************************************************/


    -- If either Use Up Plan or Use Up Item has changed, get new scheduled date

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Before Getting New Scheduled Date, Start Effective Date : '
                               ||to_char(l_revised_item_rec.start_effective_date) );
END IF;

      IF p_control_rec.caller_type <> 'FORM'             -- Bug1906633
      THEN


        IF ( l_revised_item_rec.use_up_plan_name <>
             p_old_revised_item_rec.use_up_plan_name OR
             ( l_revised_item_rec.use_up_plan_name IS NULL AND
               p_old_revised_item_rec.use_up_plan_name IS NOT NULL
              ) OR
             ( p_old_revised_item_rec.use_up_plan_name IS NULL AND
               l_revised_item_rec.use_up_plan_name IS NOT NULL
              )
            )
            OR
            ( l_rev_item_unexp_rec.use_up_item_id <>
              p_old_rev_item_unexp_rec.use_up_item_id OR
              ( l_rev_item_unexp_rec.use_up_item_id IS NULL AND
                p_old_rev_item_unexp_rec.use_up_item_id IS NOT NULL
               ) OR
               ( p_old_rev_item_unexp_rec.use_up_item_id IS NULL AND
                 l_rev_item_unexp_rec.use_up_item_id IS NOT NULL
               )
             )
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('If either Use Up Plan or Use Up Item has changed, get new scheduled date');
    Error_Handler.Write_Debug('Use Up Item Id   : ' ||to_char(l_rev_item_unexp_rec.use_up_item_id ) );
    Error_Handler.Write_Debug('Use Up Plan Name : ' ||l_revised_item_rec.use_up_plan_name );
END IF;

                IF l_rev_item_unexp_rec.use_up_item_id IS NOT NULL AND
                   l_rev_item_unexp_rec.use_up_item_id <> FND_API.G_MISS_NUM AND -- Added by MK on 10/31/00
                   l_revised_item_rec.use_up_plan_name IS NOT NULL
                THEN
                        G_OLD_SCHED_DATE := l_revised_item_rec.start_effective_date; -- 6657209
                        l_revised_item_rec.start_effective_date :=
                        Get_Scheduled_Date(  p_use_up_item_id   =>
                                           l_rev_item_unexp_rec.use_up_item_id
                                           , p_use_up_plan_name =>
                                           l_revised_item_rec.use_up_plan_name
                                           , p_revised_item_id  =>
                                           l_rev_item_unexp_rec.revised_item_id
                                           , p_organization_id  =>
                                           l_rev_item_unexp_rec.organization_id
                                           , p_bill_sequence_id =>
                                           l_rev_item_unexp_rec.bill_sequence_id
                                           );
                        -- Also set Use_Up to 1
                        l_rev_item_unexp_rec.use_up := 1;

                ELSIF l_revised_item_rec.start_effective_date IS NULL
                THEN
                        l_revised_item_rec.start_effective_date := SYSDATE;
                        l_rev_item_unexp_rec.use_up := 2;
                        G_OLD_SCHED_DATE := null; -- 6657209
                END IF;
        END IF;

     END IF;                                            -- Bug 1906633
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After getting new schedule date, Start Effective Date : '
                             ||to_char(l_revised_item_rec.start_effective_date) );
END IF;

/*      -- Moved to ENGLRITB.pls where this flag is set based on
        -- validation in Check_Reschedule
        -- By AS on 10/12/99

        IF l_revised_item_rec.new_effective_date IS NOT NULL AND
           l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
        THEN
                G_SCHED_DATE_CHANGED := TRUE;
        END IF;
*/

        -- Added by MK on 11/13/00
        -- If user is tring to reschedule revised item , set
        -- G_SCHED_DATE_CHANGED to True
        -- For the Eco form, this flag should be set to true in Entity Defaulting
        -- once, this flag is overwritten based on validation in ENGLRITB.pls
        -- set this flag, if from unit number is changed, we need to update
        -- components in this case also.
        IF p_revised_item_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
           AND (NVL( p_revised_item_rec.new_effective_date,
                       p_revised_item_rec.start_effective_date )
                     <> p_old_revised_item_rec.start_effective_date)
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Scheduled Date is been trying to udpate. . .');
END IF;
                G_SCHED_DATE_CHANGED := TRUE;
        END IF;


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Defualting based on Status Type . . .'); END IF;

        IF l_revised_item_rec.status_type <>
           p_old_revised_item_rec.status_type
        THEN

                -- Scheduled

                IF l_revised_item_rec.status_type = 4
                THEN

                        l_ECO_Approved := 0;
                        FOR x_count IN c_CheckApproval LOOP
                                l_ECO_Approved := 1;
                        END LOOP;

                        IF l_ECO_approved = 1
                        THEN
                                l_rev_item_unexp_rec.auto_implement_date :=
                                SYSDATE;
                        ELSE
                                l_rev_item_unexp_rec.auto_implement_date :=
                                 NULL;
                        END IF;

                ELSE
                        l_rev_item_unexp_rec.auto_implement_date := NULL;
                END IF;

                -- Hold

/* IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Checking if status type = HOLD . . .'); END IF;*/

                /* Changed upon ITI's request. Earlier warnings weren't being
                   logged and mrp_active blindly being overwritten
                   By AS on 11/10/99
                */
              /*  IF l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE AND
                   l_revised_item_rec.status_type = 2 AND
                   l_revised_item_rec.status_type <>
                        p_old_revised_item_rec.status_type AND
                   l_revised_item_rec.mrp_active <> 2
                THEN
                   l_revised_item_rec.mrp_active := 2;
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_SET_MRP_ACTIVE_NO'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
                   END IF;
                ELSIF l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE AND
                   l_revised_item_rec.status_type <> 2 AND
                   l_revised_item_rec.status_type <>
                        p_old_revised_item_rec.status_type AND
                      l_revised_item_rec.mrp_active <> 1
                   -- add the next line for fixing BUG 1577957
                   AND nvl(l_revised_item_rec.eco_for_production,2) = 2
                   -- add the next line for fixing BUG 2218574
                   AND fnd_profile.value('ENG:DEFAULT_MRP_ACTIVE') = '1'
                THEN
                   l_revised_item_rec.mrp_active := 1;
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_SET_MRP_ACTIVE_YES'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
                   END IF;
                END IF;*/

                -- Cancelled

                IF l_revised_item_rec.status_type = 5
                THEN
                        -- get the requestor id.
                        IF l_rev_item_unexp_rec.requestor_id IS NULL
                        THEN
                                l_rev_item_unexp_rec.requestor_id :=
                                Get_Requestor
                                (  p_change_notice      =>
                                   l_revised_item_rec.eco_name
                                , p_organization_id     =>
                                   l_rev_item_unexp_rec.organization_id
                                );
                        END IF;
                        l_rev_item_unexp_rec.cancellation_date := SYSDATE;
                END IF;

        END IF; /* Status Type updation Ends */


        IF l_revised_item_rec.updated_revised_item_revision = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.updated_revised_item_revision := NULL;
        END IF;

        IF l_revised_item_rec.new_effective_date = FND_API.G_MISS_DATE
        THEN
                l_revised_item_rec.new_effective_date := NULL;
        END IF;

        IF l_rev_item_unexp_rec.use_up_item_id = FND_API.G_MISS_NUM
        THEN
                l_rev_item_unexp_rec.use_up_item_id := NULL;
        END IF;

        -- Code section from From End Item Unit Number and
        -- New From End ITem Unit Number added by As on 07/06/99

        IF l_revised_item_rec.from_end_item_unit_number = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.from_end_item_unit_number := NULL;
        END IF;

        IF l_revised_item_rec.new_from_end_item_unit_number = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.new_from_end_item_unit_number := NULL;
        END IF;

        -- Added by MK on 11/15/00
        IF l_revised_item_rec.new_revised_item_revision = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.new_revised_item_revision := NULL;
        END IF;

        IF l_revised_item_rec.new_routing_revision = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.new_routing_revision := NULL;
        END IF;

        IF l_revised_item_rec.updated_routing_revision = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.updated_routing_revision := NULL;
        END IF;

	/* Added below code for bug 22134406 to handle G_MISS_CHAR values of 'Change Description'.
           It updates to NULL if we choose G_MISS_CHAR for 'Change Description'. */

	IF l_revised_item_rec.change_description = FND_API.G_MISS_CHAR
        THEN
                l_revised_item_rec.change_description := NULL;

        END IF;


    /***********************************************************************
    -- Added by MK on 09/01/2000
    -- For New ECO Effectivities and ECO Routing
    ***********************************************************************/
        -- Initialize flags
        G_CREATE_RTG_ALTERNATE := FALSE;
        G_DEL_UPD_INS_RTG_REV  := 0;

        /***********************************************************************
        -- Routing Revision Defaulting
        -- Added by MK on 09/01/2000
        ***********************************************************************/
        -- Modified by MK on 10/24/00
        IF ((   (l_revised_item_rec.updated_routing_revision <>
                                 l_revised_item_rec.new_routing_revision )
                 OR
                ( l_revised_item_rec.updated_routing_revision IS NULL AND
                  l_revised_item_rec.new_routing_revision     IS NOT NULL )
                 OR
                ( l_revised_item_rec.updated_routing_revision IS NOT NULL AND
                  l_revised_item_rec.new_routing_revision     IS NULL )
             )
             AND  l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
            )
        OR
            l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN  Error_Handler.Write_Debug
  ( 'Checking for routing revision: ' ||  p_revised_item_rec.new_routing_revision );
END IF;

            IF l_revised_item_rec.transaction_type =
                ENG_Globals.G_OPR_CREATE
            THEN
                FOR x_count IN c_Rtg_CheckRevision
                ( p_revision    => l_revised_item_rec.new_routing_revision)
                LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Current Routing Revision Found . . .'); END IF;

                    l_rtg_rev_already_exists := 1;
                END LOOP;

                l_current_rtg_revision :=
                        Get_Current_Rtg_Revision
                        (  p_revised_item_id    =>  l_rev_item_unexp_rec.revised_item_id
                         , p_organization_id    =>  l_rev_item_unexp_rec.organization_id
                         , p_revision_date      =>  SYSDATE
                         );

                -- Can insert a revision into MTL_RTG_ITEM_REVISIONS only
                -- if it is not the same as the Current Revision
                -- Bug 4311691: Modified the if clause to check for l_rtg_rev_already_exists
                IF l_revised_item_rec.new_routing_revision  <>  l_current_rtg_revision AND
                   l_rtg_rev_already_exists = 0
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Insert . . .'); END IF;

                                G_DEL_UPD_INS_RTG_REV := 3;
                ELSIF l_rtg_rev_already_exists = 1 THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Update . . .'); END IF;

                                G_DEL_UPD_INS_RTG_REV := 2;
                END IF;

            ELSIF l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_UPDATE
            THEN

                l_current_rtg_revision :=
                        Get_Current_Rtg_Revision
                        (  p_revised_item_id    =>  l_rev_item_unexp_rec.revised_item_id
                         , p_organization_id    =>  l_rev_item_unexp_rec.organization_id
                         , p_revision_date      => SYSDATE
                         );

                FOR x_count IN c_Rtg_CheckRevision
                            ( p_revision        =>
                              l_revised_item_rec.updated_routing_revision
                             )
                LOOP
                        l_rtg_rev_already_exists := 1;
                END LOOP;

                IF  l_rtg_rev_already_exists = 0 AND
                    l_revised_item_rec.updated_routing_revision <>
                                                FND_API.G_MISS_CHAR
                THEN
                    --
                    -- Insert updated routing revision information into
                    -- MTL_RTG_ITEM_REVISIONS
                    IF l_revised_item_rec.new_routing_revision IS NULL  OR
                       l_revised_item_rec.new_routing_revision
                       =  l_current_rtg_revision -- Added by MK on 02/13/2001
                    THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Insert . . .'); END IF;

                                G_DEL_UPD_INS_RTG_REV := 3;
                    ELSE
                    --
                    -- Modified by MK on 10/24/00
                    -- Update new routing revision information into
                    -- MTL_RTG_ITEM_REVISIONS
                    --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Update. . .'); END IF;

                                G_DEL_UPD_INS_RTG_REV := 2 ;

                    END IF ;

                ELSIF ( l_rtg_rev_already_exists = 0 AND
                        ( l_revised_item_rec.updated_routing_revision
                          =  FND_API.G_MISS_CHAR OR
                          l_revised_item_rec.updated_routing_revision
                          IS NULL )
                       )
                      OR -- Added by MK on 02/13/2001 for Bug 1641488
                       ( l_rtg_rev_already_exists = 1 AND
                        l_revised_item_rec.updated_routing_revision
                        =  l_current_rtg_revision
                        )
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Delete. . .'); END IF;

                                G_DEL_UPD_INS_RTG_REV := 1;

                ELSIF l_rtg_rev_already_exists = 1 AND
                      l_revised_item_rec.updated_routing_revision <> l_current_revision
                THEN
                    -- Update new routing revision information in
                    -- MTL_RTG_ITEM_REVISIONS

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision set for Update. . .'); END IF;
                                G_DEL_UPD_INS_RTG_REV := 2;

                END IF; /* If Update Ends */
            END IF; /* If Create or Update Ends */

        END IF; /* Main If  ends */

        /***********************************************************************
        -- Routing Sequence Id Defaulting
        -- Added by MK on 09/01/2000
        -- Set the global flag G_CREATE_RTG_ALTERNATE to TRUE if the user is
        -- trying to create an alternate
        -- if Primary Routing has already existed.
        ***********************************************************************/

        /*IF l_revised_item_rec.alternate_bom_code IS NOT NULL AND
           NOT Check_Alt_Rtg_Already_Exists
           (  p_revised_item_id          => l_rev_item_unexp_rec.revised_item_id
            , p_alternate_bom_designator => l_revised_item_rec.alternate_bom_code
            , p_organization_id          => l_rev_item_unexp_rec.organization_id
            )
           AND
           Compatible_Primary_Rtg_Exists
           (  p_revised_item_id  => l_rev_item_unexp_rec.revised_item_id
            , p_change_notice    => l_revised_item_rec.eco_name
            , p_organization_id  => l_rev_item_unexp_rec.organization_id
            )
           AND (Bom_globals.Get_Caller_Type <> BOM_GLOBALS.G_MASS_CHANGE)
        THEN
                l_rev_item_unexp_rec.routing_sequence_id :=
                        Bom_Default_Rtg_Header.Get_Routing_Sequence ;
                        -- to generate new routing sequence id

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Routing seq id is generated for an alternate routing . . .  : ' ||
                               to_char(l_rev_item_unexp_rec.routing_sequence_id));
END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Setting creat alternate bill flag to True. . .  ' ) ;
END IF;

            G_CREATE_RTG_ALTERNATE := TRUE;


        END IF;
*/
        /***********************************************************************
        -- Comment out by MK on 02/15/2001
        -- Because this code is duplicate the logic in Attribute Defaulting and
        -- ENG_Val_To_Id.Revised_Item_VID

        IF ( l_rev_item_unexp_rec.routing_sequence_id IS NULL OR
             l_rev_item_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM )
           AND l_revised_item_rec.alternate_bom_code IS NULL  -- Added by MK on 10/31/00
        THEN
                --
                -- If the user is simply trying to add a revised item that
                -- already exists on another ECO and has a routing for it
                -- then get the routing sequence and default it.
                --
                FOR routing_seq IN c_Get_Routing_Seq LOOP
                    l_rev_item_unexp_rec.routing_sequence_id :=
                                routing_seq.routing_sequence_id;
                END LOOP;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Routing Seq Id Defaulted to: ' ||
                                to_char(l_rev_item_unexp_rec.routing_sequence_id));
END IF;

        END IF;
        ***********************************************************************/

        /***********************************************************************
        -- Set Missig Columns to Null
        -- Added by MK on 09/01/2000
        ***********************************************************************/
        -- Added by MK for ECO Routing

        IF  l_revised_item_rec.from_cumulative_quantity = FND_API.G_MISS_NUM
        THEN
            l_revised_item_rec.from_cumulative_quantity := NULL ;
        END IF ;

        IF  l_revised_item_rec.lot_number  = FND_API.G_MISS_CHAR
        THEN
            l_revised_item_rec.lot_number := NULL ;
        END IF ;

        IF l_revised_item_rec.completion_subinventory = FND_API.G_MISS_CHAR
        THEN
           l_revised_item_rec.completion_subinventory := NULL ;
        END IF ;

        IF l_revised_item_rec.priority = FND_API.G_MISS_NUM
        THEN
           l_revised_item_rec.priority := NULL ;
        END IF ;

        IF l_revised_item_rec.routing_comment = FND_API.G_MISS_CHAR
        THEN
            l_revised_item_rec.routing_comment := NULL ;
        END IF ;

        IF l_rev_item_unexp_rec.from_wip_entity_id = FND_API.G_MISS_NUM
        THEN
            l_rev_item_unexp_rec.from_wip_entity_id := NULL ;
        END IF ;


        IF l_rev_item_unexp_rec.to_wip_entity_id = FND_API.G_MISS_NUM
        THEN
            l_rev_item_unexp_rec.to_wip_entity_id := NULL ;
        END IF ;

        IF  l_rev_item_unexp_rec.completion_locator_id  = FND_API.G_MISS_NUM
        THEN
            l_rev_item_unexp_rec.completion_locator_id  := NULL ;
        END IF ;


        -- Updated by MK on 09/01/2000
        /***********************************************************************
        -- MRP Active and WIP Update Defaulting
        -- Added by MK on 09/01/2000
        ***********************************************************************/

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Before MRP Active and WIP Update Defaulting') ;
     Error_Handler.Write_Debug('MRP Active : ' || to_char(l_revised_item_rec.mrp_active )) ;
     Error_Handler.Write_Debug('Update Wip: ' || to_char(l_revised_item_rec.update_wip )) ;
     Error_Handler.Write_Debug('Lot Num : ' || l_revised_item_rec.lot_number ) ;
     Error_Handler.Write_Debug('Cum Qty : ' || to_char(l_revised_item_rec.from_cumulative_quantity)) ;
     Error_Handler.Write_Debug('From Wo : ' || to_char(l_rev_item_unexp_rec.from_wip_entity_id )) ;
     Error_Handler.Write_Debug('To Wo : ' || to_char(l_rev_item_unexp_rec.to_wip_entity_id)) ;
END IF ;

        -- Modified by MK on 10/30/2000
        IF l_revised_item_rec.transaction_type = ENG_Globals.G_OPR_CREATE
           AND  (l_revised_item_rec.mrp_active <> 2 OR
                 l_revised_item_rec.update_wip <> 1 )
           AND
                ( l_revised_item_rec.lot_number               IS NOT NULL OR
                  l_revised_item_rec.from_cumulative_quantity IS NOT NULL OR
                  l_rev_item_unexp_rec.to_wip_entity_id       IS NOT NULL OR
                  l_rev_item_unexp_rec.from_wip_entity_id     IS NOT NULL
                 )
        THEN
            -- Set MRP_Active to No and Update_Wip to Yes
            l_revised_item_rec.mrp_active := 2;
            l_revised_item_rec.update_wip := 1;

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Mrp Active and Update Wip are set to Yes') ;
     Error_Handler.Write_Debug('MRP Active : ' || to_char(l_revised_item_rec.mrp_active )) ;
     Error_Handler.Write_Debug('UPDATE Wip: ' || to_char(l_revised_item_rec.update_wip )) ;
END IF ;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                 Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_SET_WO_EFFECTIVITY_FLAG'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         , p_message_type       => 'W');
            END IF;
        END IF ;

        /***********************************************************************
        -- Set G_ECO_FOR_PROD_CHANGED to True if user is trying to
        -- update ECO_FOR_PRODUCTION
        -- Added by MK on 10/24/2000
        ***********************************************************************/
        IF   l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
        AND  ( l_revised_item_rec.eco_for_production
                   <> p_old_revised_item_rec.eco_for_production     OR
               ( l_revised_item_rec.eco_for_production IS NOT NULL AND
                 p_old_revised_item_rec.eco_for_production IS NULL    )
             )
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Eco for Prod has been changed. . . Yes') ;
END IF ;
              G_ECO_FOR_PROD_CHANGED := TRUE;
        END IF;

        --  Load out record
        x_revised_item_rec := l_revised_item_rec;
        x_rev_item_unexp_rec := l_rev_item_unexp_rec;
        x_Mesg_Token_Tbl  := l_MEsg_Token_Tbl;
        x_Return_Status := FND_API.G_RET_STS_SUCCESS;

END Entity_Defaulting;


END ENG_Default_Revised_Item;

/
