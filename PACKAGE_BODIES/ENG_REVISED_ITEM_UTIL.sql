--------------------------------------------------------
--  DDL for Package Body ENG_REVISED_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_REVISED_ITEM_UTIL" AS
/* $Header: ENGURITB.pls 120.7.12010000.11 2013/07/18 17:38:33 umajumde ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ENG_Revised_Item_Util';

-- Code changes for enhancement 6084027 start
/*****************************************************************************
* Added by vggarg on 09 Oct 2007
* Procedure     : update_new_description
* Parameters IN : p_api_version, p_revised_item_sequence_id, p_new_description
* Purpose       : Update the new_item_description column of the eng_revised_items table with the given value
*****************************************************************************/
PROCEDURE update_new_description
(
  p_api_version IN NUMBER := 1.0
  , p_revised_item_sequence_id IN NUMBER
  , p_new_description mtl_system_items_b.description%TYPE
) IS

BEGIN
  UPDATE ENG_REVISED_ITEMS SET NEW_ITEM_DESCRIPTION =   p_new_description WHERE REVISED_ITEM_SEQUENCE_ID = p_revised_item_sequence_id;
END;
-- Code changes for enhancement 6084027 end

/*****************************************************************************
* Added by MK on 09/01/2000
* Procedure     : Delete_Routing_Details
* Parameters IN : Revised Item and Routing Header Key Column.
* Purpose       : Delete Routing Details Routing from Tables.
*****************************************************************************/
PROCEDURE Delete_Routing_Details
(   p_organization_id          IN NUMBER
  , p_revised_item_id          IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_routing_sequence_id      IN NUMBER
  , p_change_notice            IN VARCHAR2 )
IS


BEGIN
   DELETE FROM MTL_RTG_ITEM_REVISIONS
   where organization_id   = p_organization_id
     and inventory_item_id = p_revised_item_id
     and revised_item_sequence_Id = p_revised_item_sequence_id
     and change_notice = p_change_notice
     and implementation_date is null;

  DELETE FROM  ENG_CURRENT_SCHEDULED_DATES
   where organization_id   = p_organization_id
     and revised_item_id = p_revised_item_id
     and revised_item_sequence_Id = p_revised_item_sequence_id
     and change_notice = p_change_notice ;

  DELETE FROM BOM_OPERATIONAL_ROUTINGS  bor
   where bor.routing_sequence_id = p_routing_sequence_id
     and bor.pending_from_ecn = p_change_notice
     and not exists (select null
                       from BOM_OPERATION_SEQUENCES bos
                      where bos.routing_sequence_id = bor.routing_sequence_id
                        and (bos.change_notice is null
                             or
                             bos.change_notice <> p_change_notice
                             or
                             (bos.change_notice = p_change_notice
                             and bos.revised_item_sequence_id <> p_revised_item_sequence_id)))
     and ((bor.alternate_routing_designator is null
           and not exists (select null
                             from BOM_OPERATIONAL_ROUTINGS bor2
                            where bor2.organization_id  = bor.organization_id
                              and bor2.assembly_item_id = bor.assembly_item_id
                              and bor2.alternate_routing_designator is not null))
           or
          (bor.alternate_routing_designator is not null))
     and not exists (select null
                             from ENG_REVISED_ITEMS eri
                            where eri.organization_id = bor.organization_id
                              and eri.bill_sequence_id = bor.routing_sequence_id
                              and eri.change_notice <> p_change_notice
         );

END Delete_Routing_Details;
-- Added by MK on 09/01/2000


/*****************************************************************************
* Added by MK on 09/01/2000
* Procedure     : Insert_Routing_Revisions
* Parameters IN : Routing Revision Column.
* Purpose       : Insert the New Routing Revision Record into MTL_RTG_ITEM_REVISIONS
****************************************************************************/
PROCEDURE Insert_Routing_Revisions
(  p_inventory_item_id        IN NUMBER
 , p_organization_id          IN NUMBER
 , p_revision                 IN VARCHAR2
 , p_user_id                  IN NUMBER
 , p_login_id                 IN NUMBER
 , p_change_notice            IN VARCHAR2
 , p_effectivity_date         IN DATE
 , p_revised_item_sequence_id IN NUMBER
)
IS
BEGIN

                       INSERT INTO MTL_RTG_ITEM_REVISIONS
                       (  inventory_item_id
                        , organization_id
                        , process_revision
                        , last_update_date
                        , last_updated_by
                        , creation_date
                        , created_by
                        , last_update_login
                        , change_notice
                        , ecn_initiation_date
                        , effectivity_date
                        , revised_item_sequence_id
                        )
                        VALUES
                        ( p_inventory_item_id
                        , p_organization_id
                        , p_revision
                        , SYSDATE
                        , p_user_id
                        , SYSDATE
                        , p_user_id
                        , p_login_id
                        , p_change_notice
                        , SYSDATE
                        , DECODE(p_effectivity_date
                                 , TRUNC(SYSDATE), SYSDATE
                                 , p_effectivity_date)
                        , p_revised_item_sequence_id
                        ) ;

END Insert_Routing_Revisions ;
-- Added by MK on 09/01/2000




/*****************************************************************************
* Procedure     : Cancel_ECO
* Parameters IN : Organization_id
*                 Change notice
*                 Mesg Token Table
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : If revised item is being cancelled, AND the revised item is
*                 the last revised item on the ECO, AND all the existing
*                 revised items have been implemented or cancelled, do one of
*                 the following:
*                 1) Set ECO status to IMPLEMENTED if there are any implemented
*                    revised items on the ECO
*                 2) Set ECO status to CANCELLED if there are no implemented
*                    revised items on the ECO
* History       : Added by AS on 09/22/99 to include bug fix for 980294.
******************************************************************************/
Procedure Cancel_ECO
( p_organization_id     IN  NUMBER
, p_change_notice       IN  VARCHAR2
, p_user_id             IN  NUMBER
, p_login               IN  NUMBER
, p_Mesg_Token_Tbl      IN  Error_Handler.Mesg_Token_Tbl_Type
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
)
IS
  l_err_text              VARCHAR2(2000) := NULL;
  l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type := p_Mesg_Token_Tbl;
  l_token_tbl             Error_Handler.Token_Tbl_Type;
  X_EcoStatus number;
  Cursor CheckEco is
    Select 'x' dummy
    From dual
    Where not exists (
      Select null
      From eng_revised_items eri
      Where eri.change_notice = p_change_notice
      And   eri.organization_id = p_organization_id
      And   eri.status_type not in (6, 5));

  Cursor CheckStatusEco is
    Select 'x' dummy
    From dual
    Where exists (
      Select null
      From eng_revised_items eri
      Where eri.change_notice = p_change_notice
      And   eri.organization_id = p_organization_id
      And   eri.status_type = 6);
BEGIN
        X_EcoStatus := 5;
        For X_NewStatus in CheckEco loop
                l_token_tbl.delete;
                l_token_tbl(1).token_name  := 'ECO_NAME';
                l_token_tbl(1).token_value := p_change_notice;
                For X_NewStatus in CheckStatusEco loop

                        -- Change ECO status to implemented.

                        UPDATE ENG_ENGINEERING_CHANGES
                                SET IMPLEMENTATION_DATE = SYSDATE,
                                STATUS_TYPE = 6,
                                LAST_UPDATED_BY = p_user_id,
                                LAST_UPDATE_LOGIN = p_login
                        WHERE ORGANIZATION_ID = p_organization_id
                        AND CHANGE_NOTICE = p_change_notice;
                        X_EcoStatus := 6;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Name       => 'ENG_LAST_ITEM_CANCL_ECO_IMPL'
                                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                , p_Token_Tbl          => l_Token_Tbl
                                , p_message_type       => 'W');
                        END IF;
                End loop;

                if (X_EcoStatus = 5) then

                        -- Change ECO status to canceled.

                        UPDATE ENG_ENGINEERING_CHANGES
                                SET CANCELLATION_DATE = SYSDATE,
                                STATUS_TYPE = 5,
                                LAST_UPDATED_BY = p_user_id,
                                LAST_UPDATE_LOGIN = p_login
                        WHERE ORGANIZATION_ID = p_organization_id
                        AND CHANGE_NOTICE = p_change_notice;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Name       => 'ENG_LAST_ITEM_CANCL_ECO_CANCL'
                                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                , p_Token_Tbl          => l_Token_Tbl
                                , p_message_type       => 'W');
                        END IF;
                end if;
       End loop;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
            l_err_text := G_PKG_NAME || ' :(Cancel_ECO)-Revised Item '
                                     || substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
            x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cancel_ECO;

/*****************************************************************************
* Procedure     : Cancel_Revised_Item
* Parameters IN : Revised item sequence Id
*                 Bill Sequence Id
*                 User Id
*                 Login Id
*                 Change notice
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Procedure will perform the cancellation of a revised item.
*                 In doing so the procedure will delete the corresponding
*                 revisions and will also make sure that the underlying
*                 entities also get cancelled.
*
* History       : 09/01/2000   MK    ECO for Routing.
******************************************************************************/
Procedure Cancel_Revised_Item
( rev_item_seq          IN  NUMBER
, bill_seq_id           IN  NUMBER
, routing_seq_id        IN  NUMBER -- Added by MK on 09/01/2000
, user_id               IN  NUMBER
, login                 IN  NUMBER
, change_order          IN  VARCHAR2
, cancel_comments       IN  VARCHAR2
, p_Mesg_Token_Tbl      IN  Error_Handler.Mesg_Token_Tbl_Type
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_err_text              VARCHAR2(2000) := NULL;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type := p_Mesg_Token_Tbl;

CURSOR c_getRevisedComps IS
        SELECT component_sequence_id
          FROM bom_inventory_components
         WHERE revised_item_sequence_id = rev_item_seq;


CURSOR c_getRevisedOps IS
       SELECT operation_sequence_id
            , operation_seq_num
       FROM   BOM_OPERATION_SEQUENCES
       WHERE  revised_item_sequence_id = rev_item_seq ;

-- Changes for Bug 3668603
-- Cursor to check if the routing header used in the revised item has any references
Cursor c_check_rtg_header_del is
  select routing_sequence_id
    from bom_operational_routings bor
   where bor.routing_sequence_id = routing_seq_id
     and bor.pending_from_ecn = change_order
     and not exists (select null
                       from BOM_OPERATION_SEQUENCES bos
                      where bos.routing_sequence_id = bor.routing_sequence_id
                        and (bos.change_notice is null
                             or
                             bos.change_notice <> change_order
                             or
                             (bos.change_notice = change_order
                             and bos.revised_item_sequence_id <> rev_item_seq)))
     and ((bor.alternate_routing_designator is null
           and not exists (select null
                             from BOM_OPERATIONAL_ROUTINGS bor2
                            where bor2.organization_id  = bor.organization_id
                              and bor2.assembly_item_id = bor.assembly_item_id
                              and bor2.alternate_routing_designator is not null)
	   and not exists (select null
                             from MTL_RTG_ITEM_REVISIONS mriv
      	 	            where mriv.organization_id  = bor.organization_id
                              and mriv.inventory_item_id = bor.assembly_item_id
		              and mriv.implementation_date is not null
			      and mriv.change_notice is null))
           or
          (bor.alternate_routing_designator is not null))
     and not exists (select null
                       from ENG_REVISED_ITEMS eri
                      where eri.organization_id = bor.organization_id
                        and eri.routing_sequence_id = bor.routing_sequence_id
                        and eri.revised_item_sequence_id <> rev_item_seq
			and eri.status_type <> 5);

l_del_rtg_header	NUMBER;
-- End changes for bug 3668603

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR rev_comp IN c_getRevisedComps
    LOOP
        Bom_Bom_Component_Util.Cancel_Component
                (  p_component_sequence_id  => rev_comp.component_sequence_id
                 , p_cancel_comments        => cancel_comments
                 , p_user_id                => user_id
                 , p_login_id               => login
                 );
    END LOOP;

    -- Delete the rows from bom_inventory_components

    DELETE FROM bom_components_b --BOM_INVENTORY_COMPONENTS IC -- R12: Modified for common bom changes
    WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;

    -- Delete item revisions created by revised items on ECO
    /* delete from MTL_ITEM_REVISIONS_TL
     where revision_id IN (select revision_id
                           from MTL_ITEM_REVISIONS_B
                          where   REVISED_ITEM_SEQUENCE_ID = rev_item_seq);*/
     -- Added revision_id to where clause for performance bug 4251776
     delete from MTL_ITEM_REVISIONS_TL
     where revision_id IN (select new_item_revision_id
                          from eng_revised_items I
                          WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq);
     DELETE FROM MTL_ITEM_REVISIONS_B I
     where revision_id IN (select new_item_revision_id
                           from eng_revised_items I
                           WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq);
     /*WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;*/


    -- Delete the bom header if bill was created by this revised item and
    -- nothing else references this

  DELETE FROM BOM_BILL_OF_MATERIALS B
    WHERE B.BILL_SEQUENCE_ID = bill_seq_id
    AND   B.PENDING_FROM_ECN = change_order
    AND   NOT EXISTS (SELECT NULL
                  FROM BOM_INVENTORY_COMPONENTS C
                  WHERE C.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                  AND  (C.REVISED_ITEM_SEQUENCE_ID IS NULL
                      OR C.REVISED_ITEM_SEQUENCE_ID <> rev_item_seq))
    AND ( (B.ALTERNATE_BOM_DESIGNATOR IS NULL
         AND NOT EXISTS (SELECT NULL
                       FROM BOM_BILL_OF_MATERIALS B2
                       WHERE B2.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   B2.ASSEMBLY_ITEM_ID = B.ASSEMBLY_ITEM_ID
                       AND   B2.ALTERNATE_BOM_DESIGNATOR IS NOT NULL))
         OR
        (NOT EXISTS (SELECT NULL
                       FROM ENG_REVISED_ITEMS R
                       WHERE R.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   R.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                        AND   R.REVISED_ITEM_SEQUENCE_ID <> rev_item_seq
			  AND    R.STATUS_TYPE <> 5)));



    -- If bill was deleted, then unset the bill_sequence_id on the revised item

    if (SQL%ROWCOUNT > 0) then
        UPDATE ENG_REVISED_ITEMS  R
        SET    BILL_SEQUENCE_ID = ''
             , cancel_comments  = cancel_comments
             , cancellation_date = SYSDATE
        WHERE  R.REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
    end if;


/***********************************************************************
-- Added by MK on 09/01/2000
-- Cancel Revised Item for ECO Routing
***********************************************************************/

    FOR rev_opseq IN c_getRevisedOps
    LOOP
        ENG_Globals.Cancel_Operation
        ( p_operation_sequence_id  => rev_opseq.operation_sequence_id
        , p_cancel_comments        => cancel_comments
        , p_op_seq_num             => rev_opseq.operation_seq_num -- Added by MK on 11/27/00
        , p_user_id                => user_id
        , p_login_id               => login
        , p_prog_id                => Bom_Rtg_Globals.Get_Prog_Id
        , p_prog_appid             => Bom_Rtg_Globals.Get_Prog_AppId
        , x_return_status          => x_return_status
        , x_mesg_token_tbl         => x_mesg_token_tbl
        ) ;

    END LOOP;

    -- Delete the rows from bom_operation_sequences

    DELETE FROM BOM_OPERATION_SEQUENCES
    WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;

    -- Delete item revisions created by revised items on ECO

    DELETE FROM MTL_RTG_ITEM_REVISIONS I
    WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq
    AND implementation_date IS NULL; -- bug 3668603: delete only unimplemented revisions

    -- Delete the routing header if routing was created by this revised item and
    -- nothing else references this
    -- Bug 3668603
    -- Before deleting the routing header, Check using cursor c_check_rtg_header_del, if it is referenced.
    -- If referenced, the header is not deleted and bom_operational_routings.pending_for_ecn is
    -- set to null for the routing header header if pending_form_eco =change_order
    -- If not referenced, then delete the routing revisions if the header is a primary routing
    -- Delete the header and unset the routing_sequence_id on the revised items
    -- using the routing_sequence_id.
    --
    l_del_rtg_header := 0;
    FOR crh IN c_check_rtg_header_del
    LOOP
	l_del_rtg_header := 1;
    END LOOP;

    IF (l_del_rtg_header = 1)
    THEN
        DELETE FROM MTL_RTG_ITEM_REVISIONS rev
        WHERE EXISTS (SELECT 1
	                FROM BOM_OPERATIONAL_ROUTINGS bor
		       WHERE bor.routing_sequence_id = routing_seq_id
		         AND bor.alternate_routing_designator IS NULL
		         AND bor.assembly_item_id = rev.INVENTORY_ITEM_ID
		         AND bor.organization_id = rev.organization_id);

        DELETE FROM BOM_OPERATIONAL_ROUTINGS
        WHERE routing_sequence_id = routing_seq_id;
    ELSE
        UPDATE BOM_OPERATIONAL_ROUTINGS
           SET last_update_date = SYSDATE,
               last_updated_by = user_id,
               last_update_login = login,
               pending_from_ecn = null
         WHERE routing_sequence_id = routing_seq_id
           AND pending_from_ecn = change_order;
    END IF;


   /* DELETE FROM BOM_OPERATIONAL_ROUTINGS bor1
    WHERE bor1.routing_sequence_id = routing_seq_id
    AND   bor1.pending_from_ecn    = change_order
    AND   NOT EXISTS (SELECT NULL
                      FROM BOM_OPERATION_SEQUENCES  bos
                      WHERE bos.ROUTING_SEQUENCE_ID = bor1.ROUTING_SEQUENCE_ID
                      AND (bos.CHANGE_NOTICE     IS NULL
                      OR   bos.CHANGE_NOTICE       <> change_order)
                      )
    AND  ((bor1.ALTERNATE_ROUTING_DESIGNATOR IS NULL
           AND NOT EXISTS (SELECT NULL
                           FROM BOM_OPERATIONAL_ROUTINGS bor2
                           WHERE bor2.ORGANIZATION_ID  = bor1.ORGANIZATION_ID
                           AND   bor2.ASSEMBLY_ITEM_ID = bor1.ASSEMBLY_ITEM_ID
                           AND   bor2.ALTERNATE_ROUTING_DESIGNATOR IS NOT NULL))
         OR
          (bor1.ALTERNATE_ROUTING_DESIGNATOR IS NOT NULL
           AND NOT EXISTS (SELECT NULL
                           FROM ENG_REVISED_ITEMS eri
                           WHERE eri.ORGANIZATION_ID = bor1.ORGANIZATION_ID
                           AND   eri.ROUTING_SEQUENCE_ID = bor1.ROUTING_SEQUENCE_ID
                           AND   eri.CHANGE_NOTICE <> change_order)));*/



    -- If routing was deleted, then unset the routing_sequence_id on the revised item

    --if (SQL%ROWCOUNT > 0) then
    IF (l_del_rtg_header = 1) THEN     -- Bug 3668603
        UPDATE ENG_REVISED_ITEMS  eri
        SET    routing_sequence_id = ''
             , cancel_comments  = cancel_comments
             , cancellation_date = SYSDATE
        WHERE  eri.REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
    end if;
-- Added by MK on 09/01/2000

    -- End Changes for Bug 3668603




EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    WHEN OTHERS THEN
            l_err_text := G_PKG_NAME || ' :(Cancel_Revised_Item)-Revised Item '
                                     || substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
            x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cancel_Revised_Item;


-- Insert a record into the scheduled dates history table
-- when a revised item is rescheduled.

PROCEDURE Insert_Current_Scheduled_Dates (x_change_notice               VARCHAR2,
                                          x_organization_id             NUMBER,
                                          x_revised_item_id             NUMBER,
                                          x_scheduled_date              DATE,
                                          x_revised_item_sequence_id    NUMBER,
                                          x_requestor_id                NUMBER,
                                          x_userid                      NUMBER,
                                          x_original_system_reference   VARCHAR2,
					  x_comments			VARCHAR2) -- Bug 3589974
IS
  x_schedule_id         NUMBER;
BEGIN
  select ENG_CURRENT_SCHEDULED_DATES_S.nextval
    into x_schedule_id
    from sys.dual;
  insert into ENG_CURRENT_SCHEDULED_DATES (
                change_notice,
                organization_id,
                revised_item_id,
                scheduled_date,
                last_update_date,
                last_updated_by,
                schedule_id,
                creation_date,
                created_by,
                last_update_login,
                employee_id,
                revised_item_sequence_id,
                original_system_reference,
		comments 	-- Bug 3589974
		)
        values (x_change_notice,
                x_organization_id,
                x_revised_item_id,
                x_scheduled_date,
                sysdate,
                x_userid,
                x_schedule_id,
                sysdate,
                x_userid,
                x_userid,
                x_requestor_id,
                x_revised_item_sequence_id,
                x_original_system_reference,
		x_comments	-- Bug 3589974
		);
END Insert_Current_Scheduled_Dates;

PROCEDURE Update_Component_Unit_Number
( p_new_from_end_item_number    VARCHAR2
, p_revised_item_sequence_id    NUMBER
)
IS
BEGIN
        UPDATE bom_inventory_components
           SET from_end_item_unit_number = p_new_from_end_item_number
         WHERE revised_item_sequence_id = p_revised_item_sequence_id
           AND implementation_date IS NOT NULL;
END Update_Component_Unit_Number;



/*****************************************************************************
* Procedure     : Update_Rev_Operations
* Parameters IN : Revised item sequence Id
*                 Routing Sequence Id
*                 Scheduled Date(Effectivity Date)
*                 Change notice
* Purpose       : Procedure will perform the update of effectivity date
*                 and disable date in revised operations when user trying
*                 to reschedule parent revised item.
* History       : 11/13/2000   MK    Added in ECO for Routing.
******************************************************************************/

PROCEDURE Update_Rev_Operations (x_change_notice                  VARCHAR2,
                                 x_routing_sequence_id            NUMBER,
                                 x_revised_item_sequence_id       NUMBER,
                                 x_scheduled_date                 DATE,
                                 x_from_end_item_unit_number      VARCHAR2 DEFAULT NULL)
IS
BEGIN
    UPDATE BOM_OPERATION_SEQUENCES
    SET    effectivity_date = x_scheduled_date
    --    ,  from_end_item_unit_number = x_from_end_item_unit_number
    WHERE  implementation_date IS NULL
    AND    change_notice               = x_change_notice
    AND    revised_item_sequence_id    = x_revised_item_sequence_id
    AND    routing_sequence_id         = x_routing_sequence_id ;

    UPDATE BOM_OPERATION_SEQUENCES
    SET    disable_date = x_scheduled_date
    WHERE  implementation_date IS NULL
    AND    acd_type = 3
    AND    change_notice               = x_change_notice
    AND    revised_item_sequence_id    = x_revised_item_sequence_id
    AND    routing_sequence_id         = x_routing_sequence_id ;

END Update_Rev_Operations ;



/*********************************************************************
* Procedure : Updating new_item_revision_id and new_lifecycle_state_id
* Parameters IN :Revised_item_sequence_id
                 Revised_item_id
		 organization_id
                 new_item_revision
		 new_lifecycle_phase_name
********************************************************************* */
PROCEDURE Update_New_Rev_Lifecycle(
 p_revised_item_seq_id      IN  NUMBER
, p_revised_item_id         IN  NUMBER
, p_org_id                  IN  NUMBER
,p_lifecycle_name          IN VARCHAR2
,p_new_item_revision     IN VARCHAR2
,p_change_notice	 IN VARCHAR2
, x_Return_Status               OUT NOCOPY VARCHAR2
)

is
l_new_life_cycle_state_id NUMBER;
l_new_item_rev_id NUMBER;
l_err_text              VARCHAR2(2000) := NULL;
l_fetch_lifecycle	NUMBER := 0;
BEGIN

l_new_item_rev_id := ENG_Val_To_Id.Revised_Item_Code (
                        p_revised_item_num => p_revised_item_id,
                        p_organization_id =>  p_org_id,
                        p_revison_code  =>    p_new_item_revision );
	--
	-- Bug 3311072: Added check if lifecycle name is not null and if plm or erp record
	-- Modified by LKASTURI
IF (p_lifecycle_name IS NOT NULL)
THEN
	BEGIN

	SELECT 1
	INTO l_fetch_lifecycle
	FROM eng_engineering_changes
	WHERE nvl(plm_or_erp_change , 'PLM') = 'PLM'
	AND change_notice = p_change_notice
	AND organization_id = p_org_id;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_new_life_cycle_state_id := null;
	END;

	IF (l_fetch_lifecycle = 1)
	THEN

		l_new_life_cycle_state_id :=ENG_Val_To_Id.Lifecycle_id (
			p_lifecycle_name =>  p_lifecycle_name,
			p_inventory_item_id => p_revised_item_id,
                        p_org_id =>  p_org_id,
			x_err_text   =>   l_err_text);
	END IF;
END IF;

UPDATE  ENG_REVISED_ITEMS
    SET new_item_revision_id   = l_new_item_rev_id,
        new_lifecycle_state_id = l_new_life_cycle_state_id
WHERE REVISED_ITEM_SEQUENCE_ID = p_revised_item_seq_id;

x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end Update_New_Rev_Lifecycle;



/*****************************************************************************
* Procedure     : Update_Row
* Parameters IN : Revised item exposed column record.
*                 Revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Update row procedure will update the revised item record. It
*                 will check if the user has tried to update the schedule date
*                 and if the date has been updated then it will update the
*                 dates on it revision and will also update the dates on all
*                 revised components on that revised item. If the user has
*                 updated the use up plan name or the item, then a new schedule
*                 must be fetched and updated in all the corresponding entities.
******************************************************************************/
PROCEDURE Update_Row
( p_revised_item_rec            IN  ENG_Eco_PUB.Revised_Item_Rec_Type
, p_rev_item_unexp_rec          IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
, p_control_rec                 IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
, x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status               OUT NOCOPY VARCHAR2
)
IS
l_err_text              VARCHAR2(2000);
l_stmt_num              NUMBER := 0;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
req_id			NUMBER;
l_language_code	        VARCHAR2(3);
l_revision_id	        NUMBER;

--begin Bug 16340624
l_delimiter varchar2(10);
l_concatenated_copy_segments  VARCHAR2(2000);
l_new_item  VARCHAR2(2000);
TYPE SEGMENTARRAY IS table of VARCHAR2(150) index by BINARY_INTEGER;
copy_segments SEGMENTARRAY;
l_count number;

--end Bug 16340624

BEGIN

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;


 --added for Bug 16340624 (begin)
IF ((p_control_rec.caller_type <> 'FORM') AND  (nvl(p_revised_item_rec.transfer_or_copy, 'T') = 'C')) THEN

l_new_item:= p_revised_item_rec.copy_to_item;
SELECT concatenated_segment_delimiter
INTO l_delimiter
FROM fnd_id_flex_structures
WHERE application_id = 401
AND id_flex_code     = 'MSTK'
AND id_flex_num      = 101;

SELECT (LENGTH(l_new_item) - LENGTH(REPLACE(l_new_item, l_delimiter)))
INTO l_count
FROM dual;

FOR i IN 1..20
LOOP
  copy_segments(i) := NULL;
END LOOP;
copy_segments(1) := SUBSTR(l_new_item, 1, to_number( instr(l_new_item,l_delimiter,1,1))-1);
FOR i IN 2..l_count
LOOP
  copy_segments(i) := SUBSTR(l_new_item, to_number(instr(l_new_item,l_delimiter,1,i-1))+1, ( to_number( instr(l_new_item,l_delimiter,1,i) ) -
  to_number(instr(l_new_item,l_delimiter,1,i-1)+1)) );
END LOOP;
copy_segments(l_count+1)     := SUBSTR(l_new_item, to_number( instr(l_new_item,l_delimiter,-1,1))+1);
l_concatenated_copy_segments := NULL;
FOR i IN 1..20
LOOP
  l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, fnd_global.local_chr(1));
  l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, copy_segments(i));

END LOOP;

l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, fnd_global.local_chr(1));

END IF;

 --added for Bug 16340624 (end)



IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating revised item . . . seq id : ' ||
    to_char(p_rev_item_unexp_rec.revised_item_sequence_id));
END IF;

  IF (p_control_rec.caller_type = 'FORM' AND
      p_control_rec.validation_controller = 'MAIN_EFFECTS')
     OR
     p_control_rec.caller_type <> 'FORM'
  THEN
    BEGIN
    l_stmt_num := 1;
    UPDATE  ENG_REVISED_ITEMS
    SET   CHANGE_NOTICE            = p_revised_item_rec.eco_name
    ,     ORGANIZATION_ID          = p_rev_item_unexp_rec.organization_id
    ,     REVISED_ITEM_ID          = p_rev_item_unexp_rec.revised_item_id
    ,     LAST_UPDATE_DATE         = SYSDATE
    ,     LAST_UPDATED_BY          = l_User_Id
    ,     LAST_UPDATE_LOGIN        = l_Login_Id
    ,     IMPLEMENTATION_DATE      =
                        DECODE( p_rev_item_unexp_rec.implementation_date,
                                FND_API.G_MISS_DATE,
                                to_date(NULL),
                                p_rev_item_unexp_rec.implementation_date
                                )
    ,     CANCELLATION_DATE        =
                        DECODE(p_rev_item_unexp_rec.cancellation_date,
                               FND_API.G_MISS_DATE,
                               to_date(NULL),
                               p_rev_item_unexp_rec.cancellation_date
                               )
    ,     CANCEL_COMMENTS          = p_revised_item_rec.cancel_comments
    ,     DISPOSITION_TYPE         = p_revised_item_rec.disposition_type

    ,     NEW_ITEM_REVISION        = --p_revised_item_rec.updated_revised_item_revision -- Added by MK
                                   --  Comment Out by MK on 10/24/00   --Bug  2953132
                                     DECODE(p_revised_item_rec.updated_revised_item_revision,
                                           NULL,
                                           p_revised_item_rec.new_revised_item_revision,
                                           p_revised_item_rec.updated_revised_item_revision
                                           )
    ,     EARLY_SCHEDULE_DATE      =
                        DECODE(p_revised_item_rec.earliest_effective_date,
                               FND_API.G_MISS_DATE,
                               to_date(NULL),
                               p_revised_item_rec.earliest_effective_date
                               )
    ,     ATTRIBUTE_CATEGORY       = p_revised_item_rec.attribute_category
    ,     ATTRIBUTE2               = p_revised_item_rec.attribute2
    ,     ATTRIBUTE3               = p_revised_item_rec.attribute3
    ,     ATTRIBUTE4               = p_revised_item_rec.attribute4
    ,     ATTRIBUTE5               = p_revised_item_rec.attribute5
    ,     ATTRIBUTE7               = p_revised_item_rec.attribute7
    ,     ATTRIBUTE8               = p_revised_item_rec.attribute8
    ,     ATTRIBUTE9               = p_revised_item_rec.attribute9
    ,     ATTRIBUTE11              = p_revised_item_rec.attribute11
    ,     ATTRIBUTE12              = p_revised_item_rec.attribute12
    ,     ATTRIBUTE13              = p_revised_item_rec.attribute13
    ,     ATTRIBUTE14              = p_revised_item_rec.attribute14
    ,     ATTRIBUTE15              = p_revised_item_rec.attribute15
    ,     STATUS_TYPE              = p_revised_item_rec.status_type
    ,     SCHEDULED_DATE           =
                        DECODE(p_revised_item_rec.new_effective_date, to_date(NULL),
                               p_revised_item_rec.start_effective_date,
                               p_revised_item_rec.new_effective_date
                               )
    ,     BILL_SEQUENCE_ID         = p_rev_item_unexp_rec.bill_sequence_id
    ,     MRP_ACTIVE               = p_revised_item_rec.mrp_active
    ,     PROGRAM_ID               = l_Prog_Id
    ,     PROGRAM_UPDATE_DATE      = SYSDATE
    ,     UPDATE_WIP               = p_revised_item_rec.update_wip
    ,     USE_UP                   = p_rev_item_unexp_rec.use_up
    ,     USE_UP_ITEM_ID           = p_rev_item_unexp_rec.use_up_item_id
    ,     REVISED_ITEM_SEQUENCE_ID=p_rev_item_unexp_rec.revised_item_sequence_id
    ,     USE_UP_PLAN_NAME         = p_revised_item_rec.use_up_plan_name
    ,     DESCRIPTIVE_TEXT         = p_revised_item_rec.change_description
    ,     AUTO_IMPLEMENT_DATE      = trunc(p_rev_item_unexp_rec.auto_implement_date)
    ,     FROM_END_ITEM_UNIT_NUMBER= p_revised_item_rec.from_end_item_unit_number
    ,     ATTRIBUTE1               = p_revised_item_rec.attribute1
    ,     ATTRIBUTE6               = p_revised_item_rec.attribute6
    ,     ATTRIBUTE10              = p_revised_item_rec.attribute10
    ,     Original_System_Reference =
                                 p_revised_item_rec.original_system_reference
    --   Added by MK on 08/26/2000 ECO for Routing
    ,     FROM_WIP_ENTITY_ID       = p_rev_item_unexp_rec.from_wip_entity_id
    ,     TO_WIP_ENTITY_ID         = p_rev_item_unexp_rec.to_wip_entity_id
    ,     FROM_CUM_QTY             = p_revised_item_rec.from_cumulative_quantity
    ,     LOT_NUMBER               = p_revised_item_rec.lot_number
    ,     CFM_ROUTING_FLAG         = p_rev_item_unexp_rec.cfm_routing_flag
    ,     COMPLETION_SUBINVENTORY  = p_revised_item_rec.completion_subinventory
    ,     COMPLETION_LOCATOR_ID    = p_rev_item_unexp_rec.completion_locator_id
    --  ,     MIXED_MODEL_MAP_FLAG     = p_rev_item_unexp_rec.mixed_model_map_flag
    ,     PRIORITY                 = p_revised_item_rec.priority
    ,     CTP_FLAG                 = p_revised_item_rec.ctp_flag
    ,     ROUTING_SEQUENCE_ID      = p_rev_item_unexp_rec.routing_sequence_id
    ,     NEW_ROUTING_REVISION     = p_revised_item_rec.updated_routing_revision -- Added by MK
                                   --    Comment out by MK on 10/24/00
                                   --    DECODE(p_revised_item_rec.updated_routing_revision ,
                                   --           NULL,
                                   --           p_revised_item_rec.new_routing_revision,
                                   --           p_revised_item_rec.updated_routing_revision
                                   --           )
    ,     ROUTING_COMMENT          = p_revised_item_rec.routing_comment
    ,     ECO_FOR_PRODUCTION       = p_revised_item_rec.eco_for_production -- Added by MK on 10/06/00
    ,     CHANGE_ID                = p_rev_item_unexp_rec.change_id    --Added on 12/12/02
    ,     Transfer_Or_Copy         = p_revised_item_rec.Transfer_Or_Copy
    ,     Transfer_OR_Copy_Item    = p_revised_item_rec.Transfer_OR_Copy_Item
    ,     Transfer_OR_Copy_Bill    = p_revised_item_rec.Transfer_OR_Copy_Bill
    ,     Transfer_OR_Copy_Routing = p_revised_item_rec.Transfer_OR_Copy_Routing
    ,     Copy_To_Item             = p_revised_item_rec.Copy_To_Item
    ,     Copy_To_Item_Desc        = p_revised_item_rec.Copy_To_Item_Desc
    ,     selection_option=	    p_revised_item_rec.selection_option
    ,     selection_date      =      p_revised_item_rec.selection_date
    ,     selection_unit_number=     p_revised_item_rec.selection_unit_number
    ,     STATUS_code              = nvl(p_rev_item_unexp_rec.status_code, p_revised_item_rec.status_type) -- Bug 3424007
    ,     designator_selection_type = p_revised_item_rec.alternate_selection_code
--Bug 16340624
    , concatenated_copy_segments = decode(nvl(p_revised_item_rec.transfer_or_copy, 'T'), 'C', l_concatenated_copy_segments, null)  --Bug 16340624
    WHERE REVISED_ITEM_SEQUENCE_ID = p_rev_item_unexp_rec.revised_item_sequence_id
    ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating revised item is completed'); END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('no data stmt_num '|| l_stmt_num); END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REV_ITEM_REC_DELETED'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('un exp stmt_num '|| l_stmt_num); END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Utility (Revised Item Update) '
                                         || SUBSTR(SQLERRM, 1, 200);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(l_err_text); END IF;
                IF FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_Err_Text
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                END IF;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END IF; -- if call is from form, and side effects processing not requested.

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Validation controller is '||p_control_rec.validation_controller); END IF;

        -- If call if from form, execute this block of code only if side effects
        -- processing has been requested
        -- By AS on 10/13/99
        IF (p_control_rec.caller_type = 'FORM' AND
            p_control_rec.validation_controller = 'SIDE_EFFECTS')
           OR
           p_control_rec.caller_type <> 'FORM'
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing SIDE_EFFECTS'); END IF;

           /*********************************************************************
           --
           -- If the user has updated the status to 5 i.e. cancel, then
           -- Call the cancel_revised_item procedure that will do all
           -- that needs to be done for cancellation
           --
           **********************************************************************/
           IF p_revised_item_rec.status_type = 5
           THEN
                -- Mark revised item as 'Cancelled' and process children accordingly

                l_stmt_num := 2;
                Cancel_Revised_Item
                (  rev_item_seq         => p_rev_item_unexp_rec.revised_item_sequence_id
                 , bill_seq_id          => p_rev_item_unexp_rec.bill_sequence_id
                 , routing_seq_id       => p_rev_item_unexp_rec.routing_sequence_id
                 , user_id              => l_User_ID
                 , login                => l_Login_ID
                 , change_order         => p_revised_item_rec.eco_name
                 , cancel_comments      =>p_revised_item_rec.cancel_comments
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_return_status      => x_return_status
                 );

                IF p_control_rec.caller_type <> 'FORM'
                THEN
                    Cancel_ECO
                    (  p_organization_id        => p_rev_item_unexp_rec.organization_id
                     , p_change_notice  => p_revised_item_rec.eco_name
                     , p_user_id        => l_User_ID
                     , p_login          => l_Login_ID
                     , p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                     , x_return_status          => x_return_status
                     );
                END IF;

                /************************************************************
                --
                -- irrespective of the return type from the procedures, if the
                -- user has tried to cancel a revised item, then procedure
                -- should not do any further processing, b'coz if the revised
                -- item cancellation succeeds then, the revised item should not
                -- be operated on and if the procedure to cancel the revised
                -- item failed then there is some unexpected error.
                --
                **************************************************************/
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
           END IF;

           /* Start of new block to check if new revision needs to be created or
              if any existing need to be deleted ro modified.
           */

           BEGIN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Action on Item Revision  is :'||to_char(Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV) ); END IF;
                IF Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV = 1
                THEN
                        -- Delete record from MTL_ITEM_REVISIONS if it already
                        -- exists
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Deleting Item Revisions . . .'); END IF;

                        l_stmt_num := 3;
                        ENG_REVISED_ITEMS_PKG.Delete_Item_Revisions
                        (  x_change_notice      =>
                                p_revised_item_rec.eco_name
                         , x_organization_id    =>
                                p_rev_item_unexp_rec.organization_id
                         , x_inventory_item_id  =>
                                p_rev_item_unexp_rec.revised_item_id
                         , x_revised_item_sequence_id =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                         );
                ELSIF Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV = 2
                THEN
                        -- Update new item revision information in
                        -- MTL_ITEM_REVISIONS

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating Item Revisions . . .');
END IF;

/*
IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug(p_revised_item_rec.updated_revised_item_revision
                            || p_revised_item_rec.start_effective_date
                            ||p_revised_item_rec.new_effective_date
                            || p_revised_item_rec.eco_name
                            || p_rev_item_unexp_rec.organization_id
                            || p_rev_item_unexp_rec.revised_item_id
                            || p_rev_item_unexp_rec.revised_item_sequence_id);
END IF;
*/


                        l_stmt_num := 4;

                /*        ENG_REVISED_ITEMS_PKG.Update_Item_Revisions
                        (  x_revision           =>
                                p_revised_item_rec.updated_revised_item_revision
                        -- , x_scheduled_date     => p_revised_item_rec.new_effective_date
                           , x_scheduled_date     =>
                               DECODE(
                                  DECODE(p_revised_item_rec.new_effective_date,
                                        to_date(NULL), p_revised_item_rec.start_effective_date,
                                         p_revised_item_rec.new_effective_date),
                                  TRUNC(SYSDATE), SYSDATE,
                                  DECODE(p_revised_item_rec.new_effective_date,
                                        to_date(NULL), p_revised_item_rec.start_effective_date,
                                         p_revised_item_rec.new_effective_date)
                               )
                         , x_change_notice      =>
                                p_revised_item_rec.eco_name
                         , x_organization_id    =>
                                p_rev_item_unexp_rec.organization_id
                         , x_inventory_item_id  =>
                                p_rev_item_unexp_rec.revised_item_id
                         , x_revised_item_sequence_id =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                         );
                 */


                        UPDATE MTL_ITEM_REVISIONS_B
                        SET revision =
			    DECODE(  p_revised_item_rec.updated_revised_item_revision
				   , FND_API.G_MISS_CHAR
				   , p_revised_item_rec.new_revised_item_revision
				   , NULL
				   , p_revised_item_rec.new_revised_item_revision
				   , p_revised_item_rec.updated_revised_item_revision
				   )
                           --Bug No:3612330 added by sseraphi to update the rev label also with rev code.
                           , revision_label =
			    DECODE(  p_revised_item_rec.updated_revised_item_revision
				   , FND_API.G_MISS_CHAR
				   , p_revised_item_rec.new_revised_item_revision
				   , NULL
				   , p_revised_item_rec.new_revised_item_revision
				   , p_revised_item_rec.updated_revised_item_revision
				   )
                         ,  effectivity_date =
			     DECODE( DECODE(  p_revised_item_rec.new_effective_date
                                            , to_date(NULL)
					    , p_revised_item_rec.start_effective_date
                                            , p_revised_item_rec.new_effective_date
					    ),
                                            TRUNC(SYSDATE), SYSDATE,
                                            DECODE( p_revised_item_rec.new_effective_date
                                                   , NULL
						   , p_revised_item_rec.start_effective_date
                                                   , p_revised_item_rec.new_effective_date
						   )
                                    )
                            , description = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                FND_API.G_MISS_CHAR,
                                                description,
                                                p_revised_item_rec.new_revised_item_rev_desc)
                            , last_update_date	= SYSDATE
                            , last_update_login = l_login_id
                            , last_updated_by	= l_user_id

                        WHERE change_notice      =  p_revised_item_rec.eco_name
                        AND   organization_id    =  p_rev_item_unexp_rec.organization_id
                        AND   inventory_item_id  =  p_rev_item_unexp_rec.revised_item_id
                        AND   revised_item_sequence_id =
					 p_rev_item_unexp_rec.revised_item_sequence_id
                        AND   revision =  nvl( p_revised_item_rec.new_revised_item_revision,'NULL')
			RETURNING revision_id INTO l_revision_id;


                        SELECT userenv('LANG') INTO l_language_code FROM dual;
                        update MTL_ITEM_REVISIONS_TL
                        set
			 last_update_date	= SYSDATE,     --who column
		         last_update_login      = l_login_id,  --who column
		         last_updated_by	= l_user_id,   --who column
			  /* Item revision description support Bug: 1667419*/
                          description = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                FND_API.G_MISS_CHAR,
                                                description,
                                                p_revised_item_rec.new_revised_item_rev_desc),
		         source_lang            = l_language_code
			 where  revision_id = l_revision_id
			 AND  LANGUAGE = l_language_code;

 /*Start Bug:16231299*/
									update ENG_REVISED_ITEMS
									set new_item_revision_id=l_revision_id
									where change_notice      =  p_revised_item_rec.eco_name
                        AND   organization_id    =  p_rev_item_unexp_rec.organization_id
                        AND   revised_item_id  =  p_rev_item_unexp_rec.revised_item_id
                        AND   revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id;
 /*End Bug:16231299*/
                ELSIF Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV = 3
                THEN
                        -- Insert new record if revision record doesn't already
                        -- exist

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting Item Revisions . . .'); END IF;
                        l_stmt_num := 5;
	            IF (p_revised_item_rec.new_effective_date is NULL) THEN
                        ENG_REVISED_ITEMS_PKG.Insert_Item_Revisions
                        (  x_inventory_item_id          =>
                                p_rev_item_unexp_rec.revised_item_id
                         , x_organization_id            =>
                                p_rev_item_unexp_rec.organization_id
                         , x_revision                   =>
                                p_revised_item_rec.updated_revised_item_revision
                         , x_userid                     =>
                                l_User_Id
                         , x_change_notice              =>
                                p_revised_item_rec.eco_name
                         , x_scheduled_date     => p_revised_item_rec.start_effective_date
                         , x_revised_item_sequence_id   =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                          /* Item revision description support Bug: 1667419*/
                         , x_revision_description =>
                                p_revised_item_rec.new_revised_item_rev_desc
                        );
	            ELSE
                        ENG_REVISED_ITEMS_PKG.Insert_Item_Revisions
                        (  x_inventory_item_id          =>
                                p_rev_item_unexp_rec.revised_item_id
                         , x_organization_id            =>
                                p_rev_item_unexp_rec.organization_id
                         , x_revision                   =>
                                p_revised_item_rec.updated_revised_item_revision
                         , x_userid                     =>
                                l_User_Id
                         , x_change_notice              =>
                                p_revised_item_rec.eco_name
                         , x_scheduled_date     => p_revised_item_rec.new_effective_date
                         , x_revised_item_sequence_id   =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                          /* Item revision description support Bug: 1667419*/
                         , x_revision_description =>
                                p_revised_item_rec.new_revised_item_rev_desc
                        );
	            END IF ;

	            /*Start Bug:16231299*/
	            Select revision_id into l_revision_id
	            From MTL_ITEM_REVISIONS_B
	            Where change_notice=p_revised_item_rec.eco_name
	            		   and organization_id = p_rev_item_unexp_rec.organization_id
									   and inventory_item_id = p_rev_item_unexp_rec.revised_item_id
									   and revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id ;

							UPDATE  ENG_REVISED_ITEMS
							SET			New_Item_Revision_ID =l_revision_id
							WHERE REVISED_ITEM_SEQUENCE_ID = p_rev_item_unexp_rec.revised_item_sequence_id;
							/*End Bug:16231299*/
                /* Item revision description support Bug: 1667419*/
                ELSIF Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV = 0
                THEN

                        UPDATE MTL_ITEM_REVISIONS_B
                        SET
                            description = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                 FND_API.G_MISS_CHAR,
                                                 description,
                                                 p_revised_item_rec.new_revised_item_rev_desc)
             		 /* Bug no :2905537
		            Revised item effectivity date updation doesnt update in item revisions table
			    adding effectivity_date to the update statement */

                 	   ,  effectivity_date =
			     DECODE( DECODE(  p_revised_item_rec.new_effective_date
                                            , to_date(NULL)
					    , p_revised_item_rec.start_effective_date
                                            , p_revised_item_rec.new_effective_date
					    ),
                                            TRUNC(SYSDATE), SYSDATE,
                                            DECODE( p_revised_item_rec.new_effective_date
                                                   , to_date(NULL)
						   , p_revised_item_rec.start_effective_date
                                                   , p_revised_item_rec.new_effective_date
						   )
                                    )
                          /* End of bug 2905537 */
                            , last_update_date	= SYSDATE
                            , last_update_login = l_login_id
                            , last_updated_by	= l_user_id
                        WHERE change_notice      =  p_revised_item_rec.eco_name
                        AND   organization_id    =  p_rev_item_unexp_rec.organization_id
                        AND   inventory_item_id  =  p_rev_item_unexp_rec.revised_item_id
                        AND   revised_item_sequence_id =
					 p_rev_item_unexp_rec.revised_item_sequence_id
                        AND   revision =  nvl( p_revised_item_rec.new_revised_item_revision,'NULL')
			 RETURNING revision_id INTO l_revision_id;

                       SELECT userenv('LANG') INTO l_language_code FROM dual;
                       update MTL_ITEM_REVISIONS_TL
                       set
		       last_update_date	= SYSDATE,     --who column
                       last_update_login      = l_login_id,  --who column
                       last_updated_by	= l_user_id,   --who column
                        description            = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                FND_API.G_MISS_CHAR,
                                                description,
                                                p_revised_item_rec.new_revised_item_rev_desc),
			 source_lang            = l_language_code
			 where  revision_id = l_revision_id
			  AND  LANGUAGE = l_language_code;


                END IF;  /* If G_DEL_UPD_INS_ITEM_REV Check Ends */


                /****************************************************************
                -- Added by MK on 08/26/2000
                -- ECO for Routing
                ****************************************************************/

                IF Eng_Default_Revised_Item.G_DEL_UPD_INS_RTG_REV = 1
                THEN
                        -- Delete record from MTL_RTG_ITEM_REVISIONS if it already
                        -- exists
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Deleting Routing Revisions . . .'); END IF;

                     DELETE FROM MTL_RTG_ITEM_REVISIONS
                     WHERE  implementation_date      IS NULL
                     AND    change_notice            = p_revised_item_rec.eco_name
                     AND    revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id
                     AND    organization_id          = p_rev_item_unexp_rec.organization_id
                     AND    inventory_item_id        = p_rev_item_unexp_rec.revised_item_id ;
                     -- AND    process_revision         = p_revised_item_rec.new_routing_revision ;
                     -- Modified by MK on 02/13/2001 for Bug 1641488

                ELSIF Eng_Default_Revised_Item.G_DEL_UPD_INS_RTG_REV = 2
                THEN
                        -- Update new item revision information in
                        -- MTL_ITEM_REVISIONS

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating Routing Revisions . . .'); END IF;

                      UPDATE MTL_RTG_ITEM_REVISIONS
                      SET  process_revision  = p_revised_item_rec.updated_routing_revision
                         , effectivity_date  = DECODE( DECODE(p_revised_item_rec.new_effective_date,
                                                              to_date(NULL), p_revised_item_rec.start_effective_date,
                                                              p_revised_item_rec.new_effective_date)
                                                     , TRUNC(SYSDATE), SYSDATE
                                                     , DECODE(p_revised_item_rec.new_effective_date,
                                                              to_date(NULL), p_revised_item_rec.start_effective_date,
                                                              p_revised_item_rec.new_effective_date)
                                                      )
                         , last_update_date  = SYSDATE
                         , last_updated_by   = l_user_id
                         , last_update_login = l_login_id
                      WHERE  change_notice            = p_revised_item_rec.eco_name
                      AND    revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id
                      AND    organization_id          = p_rev_item_unexp_rec.organization_id
                      AND    inventory_item_id        = p_rev_item_unexp_rec.revised_item_id
                      AND    process_revision         = nvl(p_revised_item_rec.new_routing_revision, 'NULL') ;



                ELSIF Eng_Default_Revised_Item.G_DEL_UPD_INS_RTG_REV = 3
                THEN
                        -- Insert new record if revision record doesn't already
                        -- exist
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting Routing Revisions . . . '); END IF;

	            IF ( p_revised_item_rec.new_effective_date is NULL) THEN
                        Insert_Routing_Revisions
                        (  p_inventory_item_id =>  p_rev_item_unexp_rec.revised_item_id
                         , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                         , p_revision          =>  p_revised_item_rec.updated_routing_revision
                         , p_user_id           =>  l_user_id
                         , p_login_id          =>  l_login_id
                         , p_change_notice     =>  p_revised_item_rec.eco_name
                         , p_effectivity_date  =>  p_revised_item_rec.start_effective_date
                         , p_revised_item_sequence_id   => p_rev_item_unexp_rec.revised_item_sequence_id
                        );
	            ELSE
                        Insert_Routing_Revisions
                        (  p_inventory_item_id =>  p_rev_item_unexp_rec.revised_item_id
                         , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
                         , p_revision          =>  p_revised_item_rec.updated_routing_revision
                         , p_user_id           =>  l_user_id
                         , p_login_id          =>  l_login_id
                         , p_change_notice     =>  p_revised_item_rec.eco_name
                         , p_effectivity_date  =>  p_revised_item_rec.new_effective_date
                         , p_revised_item_sequence_id   => p_rev_item_unexp_rec.revised_item_sequence_id
                        );
	            END IF ;


                END IF;

                --  If G_DEL_UPD_INS_RTG_REV Check Ends. Added by MK on 08/26/2000


                /************************************************************
                --
                -- If the user has tried to reschedule a revised item, then
                -- this flag is set during the entity defaulting phase.
                --
                ************************************************************/
                IF Eng_Default_Revised_Item.G_SCHED_DATE_CHANGED
                THEN
                        l_stmt_num := 6;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating effective daste for child rev comps . . .'); END IF;

                        ENG_REVISED_ITEMS_PKG.Update_Inventory_Components
                        (  x_change_notice              =>
                                p_revised_item_rec.eco_name
                         , x_bill_sequence_id           =>
                                p_rev_item_unexp_rec.bill_sequence_id
                         , x_revised_item_sequence_id     =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                         , x_scheduled_date               =>
                                -- p_revised_item_rec.start_effective_date
                                p_revised_item_rec.new_effective_date -- Added by MK on 11/13/00
                         , x_from_end_item_unit_number               =>
                                p_revised_item_rec.from_end_item_unit_number
                        );



IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updating effective date for child rev operations . . . '); END IF;

                        Update_Rev_Operations
                        (  x_change_notice                => p_revised_item_rec.eco_name
                         , x_routing_sequence_id          => p_rev_item_unexp_rec.routing_sequence_id
                         , x_revised_item_sequence_id     => p_rev_item_unexp_rec.revised_item_sequence_id
                         , x_scheduled_date               => p_revised_item_rec.new_effective_date
                        ) ;


                        l_stmt_num := 7;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting current schedule date . . .'); END IF;
   if (p_revised_item_rec.status_type = 4) then
        if (p_rev_item_unexp_rec.requestor_id is null ) then
                -- req_id := l_User_Id;
		-- Bug 3589974 : Fetching the party_id for the current user_id
		BEGIN
			/*SELECT person_id
			INTO req_id
			FROM eng_security_people_v
			WHERE user_id = l_User_Id;*/
			-- Commented the above query as eng_security_people_v in engestd.odf
			-- will not be available in DMF patchset
			/*SELECT party.PARTY_ID
			  INTO req_id
			  FROM HZ_PARTIES party, fnd_user fu
			 WHERE fu.user_id = l_User_Id
			   AND to_char(fu.employee_id) = party.person_identifier
			   AND ROWNUM = 1;*/
                    -- Modified query for performance bug 4240438
            SELECT ppf.party_id INTO req_id
            FROM per_people_f ppf, fnd_user fu
            WHERE fu.user_id = l_User_Id
            AND fu.employee_id = ppf.person_id
            AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date; -- Fix for 4293553
		EXCEPTION
		WHEN OTHERS THEN
			req_id := NULL;
		END;

        else
                req_id := p_rev_item_unexp_rec.requestor_id;
        end if;
                        Insert_Current_Scheduled_Dates
                        (  x_change_notice              =>
                                p_revised_item_rec.eco_name
                         , x_organization_id               =>
                                p_rev_item_unexp_rec.organization_id
                         , x_revised_item_id               =>
                                p_rev_item_unexp_rec.revised_item_id
                         , x_scheduled_date                =>
                                p_revised_item_rec.start_effective_date
                                                        /* bug 8744651 p_revised_item_rec.new_effective_date -- p_revised_item_rec.start_effective_date
								      -- Bug 3589974 : Using the new effectivity date */
                         , x_revised_item_sequence_id      =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                         , x_requestor_id                  =>
                                req_id
                         , x_userid                        =>
                                l_User_Id
                         , x_original_system_reference     =>
                                p_revised_item_rec.original_system_reference
			 , x_comments => p_revised_item_rec.reschedule_comments -- Bug 3589974
				);
   end if;

IF Bom_Globals.Get_Debug = 'Y' THEN
Error_Handler.Write_Debug('Updating effective dates of pending item/rtg rev in this revised item record . . . ');
END IF;

                        UPDATE MTL_RTG_ITEM_REVISIONS
                        SET effectivity_date =
                            DECODE( DECODE(  p_revised_item_rec.new_effective_date
                                           , to_date(NULL)
                                           , p_revised_item_rec.start_effective_date
                                           , p_revised_item_rec.new_effective_date
                                           )
                                           , TRUNC(SYSDATE), SYSDATE
                                           , DECODE(  p_revised_item_rec.new_effective_date
                                                    , to_date(NULL)
                                                    , p_revised_item_rec.start_effective_date
                                                    , p_revised_item_rec.new_effective_date
                                                    )
                                           )
                           , last_update_date  = SYSDATE
                           , last_updated_by   = l_user_id
                           , last_update_login = l_login_id
                        WHERE  change_notice            = p_revised_item_rec.eco_name
                        AND    organization_id          = p_rev_item_unexp_rec.organization_id
                        AND    inventory_item_id        = p_rev_item_unexp_rec.revised_item_id
                        AND    revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id ;


                        UPDATE MTL_ITEM_REVISIONS_B
                        SET  effectivity_date =
                             DECODE( DECODE(  p_revised_item_rec.new_effective_date
                                            , to_date(NULL)
                                            , p_revised_item_rec.start_effective_date
                                            , p_revised_item_rec.new_effective_date
                                            ),
                                            TRUNC(SYSDATE), SYSDATE,
                                            DECODE( p_revised_item_rec.new_effective_date
                                                   , to_date(NULL)
                                                   , p_revised_item_rec.start_effective_date
                                                   , p_revised_item_rec.new_effective_date
                                                   )
                                    )
                           , description  = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                FND_API.G_MISS_CHAR,
                                                description,
                                                p_revised_item_rec.new_revised_item_rev_desc)
                           , last_update_date  = SYSDATE
                           , last_updated_by   = l_user_id
                           , last_update_login = l_login_id
                        WHERE change_notice     =  p_revised_item_rec.eco_name
                        AND   organization_id    =  p_rev_item_unexp_rec.organization_id
                        AND   inventory_item_id  =  p_rev_item_unexp_rec.revised_item_id
                        AND   revised_item_sequence_id =
                                         p_rev_item_unexp_rec.revised_item_sequence_id
 			RETURNING revision_id INTO l_revision_id;

			 /* Item revision description support Bug: 1667419*/

                       SELECT userenv('LANG') INTO l_language_code FROM dual;
                       update MTL_ITEM_REVISIONS_TL
                       set
		       last_update_date	= SYSDATE,     --who column
                       last_update_login      = l_login_id,  --who column
                       last_updated_by	= l_user_id,   --who column
                        description            = Decode(p_revised_item_rec.new_revised_item_rev_desc,
                                                FND_API.G_MISS_CHAR,
                                                description,
                                                p_revised_item_rec.new_revised_item_rev_desc),
			 source_lang            = l_language_code
			 where  revision_id = l_revision_id
			  AND  LANGUAGE = l_language_code;



                END IF;  /* Reschedule Ends */

                IF p_revised_item_rec.new_from_end_item_unit_number IS NOT NULL
                THEN
                        Update_Component_Unit_Number
                        ( p_new_from_end_item_number =>
                                p_revised_item_rec.new_from_end_item_unit_number
                        , p_revised_item_sequence_id =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                        );
                END IF;



                /************************************************************
                -- If the user has tried to update Eco For Production, then
                -- this flag is set during the entity defaulting phase.
                -- Added by MK on 24-OCT-00
                ************************************************************/
                IF Eng_Default_Revised_Item.G_ECO_FOR_PROD_CHANGED
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Before Updating Eco_For_Production in Rev Comps and Rev Ops'); END IF;

                    UPDATE BOM_OPERATION_SEQUENCES
                    SET    eco_for_production = p_revised_item_rec.eco_for_production
                    WHERE  revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id ;

                    UPDATE BOM_INVENTORY_COMPONENTS
                    SET    eco_for_production = p_revised_item_rec.eco_for_production
                    WHERE  revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id ;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After Updating Eco_For_Production in Rev Comps and Rev Ops'); END IF;

                END IF;  /* Eco For Production */

               /* 11.5.10 chnages */
    if p_revised_item_rec.New_Revised_Item_Revision is not null
    or p_revised_item_rec.updated_revised_item_revision is not null
       or p_revised_item_rec.new_lifecycle_phase_name is not null then
      Update_New_Rev_Lifecycle(
       p_revised_item_seq_id     => p_rev_item_unexp_rec.revised_item_sequence_id
      , p_revised_item_id        => p_rev_item_unexp_rec.revised_item_id
      , p_org_id                 => p_rev_item_unexp_rec.organization_id
      , p_lifecycle_name         => p_revised_item_rec.new_lifecycle_phase_name
      , p_new_item_revision      => NVL(p_revised_item_rec.updated_revised_item_revision,p_revised_item_rec.New_Revised_Item_Revision)
      , p_change_notice     => p_revised_item_rec.eco_name
      , x_Return_Status          => x_return_status);

		end if;
             x_return_status := FND_API.G_RET_STS_SUCCESS;
                EXCEPTION
                        WHEN OTHERS THEN
                                l_err_text := G_PKG_NAME ||
                                              ' : (Updating Record) ' ||
                                              SUBSTRB(SQLERRM,1,200);
                                Error_Handler.Add_Error_Token
                                (   p_Message_Name      => NULL
                                  , p_Message_Text      => l_Err_Text
                                  , p_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                                  , x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                                );
                        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

           END; /* Inser/Update/Delete revision and check reschedule block Ends */
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('returning from update_row'); END IF;

END Update_Row;

/*****************************************************************************
* Procedure     : Insert_Row
* Paramaters IN : Revised item exposed column record
*                 Revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Procedure will insert a new revised item record. It will also
*                 add any new revision if the user has added a revision that
*                 does not exist. Also an entry into the table eng_current_
*                 effective dates is also made for the new item.
*****************************************************************************/
PROCEDURE Insert_Row
( p_revised_item_rec            IN  ENG_Eco_PUB.Revised_Item_Rec_Type
, p_rev_item_unexp_rec          IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
, p_control_rec                 IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
, x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status               OUT NOCOPY VARCHAR2
)
IS
l_assembly_type         NUMBER := NULL;
l_err_text              VARCHAR2(2000) := NULL;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_current_item_revision_id      NUMBER;


--begin Bug 16340624
l_delimiter varchar2(10);
l_concatenated_copy_segments  VARCHAR2(2000);
l_new_item  VARCHAR2(2000);
TYPE SEGMENTARRAY IS table of VARCHAR2(150) index by BINARY_INTEGER;
copy_segments SEGMENTARRAY;
l_count number;

--end Bug 16340624


--added for 3972225
CURSOR c_revised_phase_id (cp_revised_item_id NUMBER,cp_organization_id NUMBER) IS
    SELECT current_phase_id
    FROM mtl_system_items
    WHERE inventory_item_id = cp_revised_item_id
               and organization_id = cp_organization_id ;

 l_current_lifecycle_phase_id    NUMBER;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

    -- 11.5.10E
    -- populating the current_item_revision_id to from_revision_id
    l_current_item_revision_id := p_rev_item_unexp_rec.from_item_revision_id;

    IF l_current_item_revision_id is null
    THEN
      l_current_item_revision_id  := p_rev_item_unexp_rec.current_item_revision_id;
    END IF;

    IF l_current_item_revision_id is null
    THEN
      l_current_item_revision_id := BOM_REVISIONS.get_item_revision_id_fn(
           'ALL',
           'IMPL_ONLY',
           p_rev_item_unexp_rec.organization_id,
           p_rev_item_unexp_rec.revised_item_id,
           SYSDATE);
    END IF;
   --added for 3972225
   OPEN c_revised_phase_id(cp_revised_item_id => p_rev_item_unexp_rec.revised_item_id,cp_organization_id => p_rev_item_unexp_rec.organization_id);
   FETCH c_revised_phase_id INTO l_current_lifecycle_phase_id;
   CLOSE c_revised_phase_id;


   --added for Bug 16340624 (begin)
IF ((p_control_rec.caller_type <> 'FORM') AND  (nvl(p_revised_item_rec.transfer_or_copy, 'T') = 'C')) THEN

  l_new_item:= p_revised_item_rec.copy_to_item;
  SELECT concatenated_segment_delimiter
INTO l_delimiter
FROM fnd_id_flex_structures
WHERE application_id = 401
AND id_flex_code     = 'MSTK'
AND id_flex_num      = 101;

SELECT (LENGTH(l_new_item) - LENGTH(REPLACE(l_new_item, l_delimiter)))
INTO l_count
FROM dual;

FOR i IN 1..20
LOOP
  copy_segments(i) := NULL;
END LOOP;
copy_segments(1) := SUBSTR(l_new_item, 1, to_number( instr(l_new_item,l_delimiter,1,1))-1);
FOR i IN 2..l_count
LOOP
  copy_segments(i) := SUBSTR(l_new_item, to_number(instr(l_new_item,l_delimiter,1,i-1))+1, ( to_number( instr(l_new_item,l_delimiter,1,i) ) -
  to_number(instr(l_new_item,l_delimiter,1,i                                       -1)+1)) );
END LOOP;
copy_segments(l_count+1)     := SUBSTR(l_new_item, to_number( instr(l_new_item,l_delimiter,-1,1))+1);
l_concatenated_copy_segments := NULL;
FOR i IN 1..20
LOOP
  l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, fnd_global.local_chr(1));
  l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, copy_segments(i));
END LOOP;

l_concatenated_copy_segments:= concat(l_concatenated_copy_segments, fnd_global.local_chr(1));

END IF;

 --added for Bug 16340624 (end)


  IF (p_control_rec.caller_type = 'FORM' AND
      p_control_rec.validation_controller = 'MAIN_EFFECTS')
     OR
     p_control_rec.caller_type <> 'FORM'
  THEN
    INSERT  INTO ENG_REVISED_ITEMS
    (
            CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       REVISED_ITEM_ID
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       IMPLEMENTATION_DATE
    ,       CANCELLATION_DATE
    ,       CANCEL_COMMENTS
    ,       DISPOSITION_TYPE
    ,       NEW_ITEM_REVISION
    ,       EARLY_SCHEDULE_DATE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       STATUS_TYPE
    ,       SCHEDULED_DATE
    ,       BILL_SEQUENCE_ID
    ,       MRP_ACTIVE
    ,       REQUEST_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       UPDATE_WIP
    ,       USE_UP
    ,       USE_UP_ITEM_ID
    ,       REVISED_ITEM_SEQUENCE_ID
    ,       USE_UP_PLAN_NAME
    ,       DESCRIPTIVE_TEXT
    ,       AUTO_IMPLEMENT_DATE
    ,       FROM_END_ITEM_UNIT_NUMBER
    ,       ATTRIBUTE1
    ,       ATTRIBUTE6
    ,       ATTRIBUTE10
    ,       Original_System_Reference

    /* Added by MK on 08/26/2000 ECO for Routing */
    ,       FROM_WIP_ENTITY_ID
    ,       TO_WIP_ENTITY_ID
    ,       FROM_CUM_QTY
    ,       LOT_NUMBER
    ,       CFM_ROUTING_FLAG
    ,       COMPLETION_SUBINVENTORY
    ,       COMPLETION_LOCATOR_ID
   --  ,     MIXED_MODEL_MAP_FLAG
    ,       PRIORITY
    ,       CTP_FLAG
    ,       ROUTING_SEQUENCE_ID
    ,       NEW_ROUTING_REVISION
    ,       ROUTING_COMMENT
    ,       ECO_FOR_PRODUCTION -- Added by MK on 10/06/00
    ,       CHANGE_ID       --Added on 12/12/02
    ,       ALTERNATE_BOM_DESIGNATOR -- Added by Maloy so that ALTERNATE_BOM_DESIGNATOR Get saved and 2871651 works fine
    --11.5.10 Changes
    ,TRANSFER_OR_COPY
    ,TRANSFER_OR_COPY_ITEM
    ,TRANSFER_OR_COPY_BILL
    ,TRANSFER_OR_COPY_ROUTING
    ,COPY_TO_ITEM
    ,COPY_TO_ITEM_DESC
    ,STATUS_CODE
    --end of 11.5.10 changes
    ,parent_revised_item_seq_id
    ,selection_option
    ,selection_date
    ,selection_unit_number
    ,new_item_revision_id
    ,current_item_revision_id
    ,current_lifecycle_state_id
    ,new_lifecycle_state_id
    ,enable_item_in_local_org
    ,create_bom_in_local_org
    ,concatenated_copy_segments  --bug 16340624
    ,designator_selection_type)  --bug 16340624

    VALUES
    (
           p_revised_item_rec.eco_name
    ,       p_rev_item_unexp_rec.organization_id
    ,       p_rev_item_unexp_rec.revised_item_id
    ,       SYSDATE
    ,       l_User_Id
    ,       SYSDATE
    ,       l_User_Id
    ,       l_Login_Id
    ,       DECODE(p_rev_item_unexp_rec.implementation_date,
                   FND_API.G_MISS_DATE,
                   to_date(NULL),
                   p_rev_item_unexp_rec.implementation_date
                   )
    ,       DECODE(p_rev_item_unexp_rec.cancellation_date,
                   FND_API.G_MISS_DATE,
                   to_date(NULL),
                   p_rev_item_unexp_rec.cancellation_date
                   )
    ,       p_revised_item_rec.cancel_comments
    ,       p_revised_item_rec.disposition_type
    ,       p_revised_item_rec.new_revised_item_revision
    ,       p_revised_item_rec.earliest_effective_date
    ,       p_revised_item_rec.attribute_category
    ,       p_revised_item_rec.attribute2
    ,       p_revised_item_rec.attribute3
    ,       p_revised_item_rec.attribute4
    ,       p_revised_item_rec.attribute5
    ,       p_revised_item_rec.attribute7
    ,       p_revised_item_rec.attribute8
    ,       p_revised_item_rec.attribute9
    ,       p_revised_item_rec.attribute11
    ,       p_revised_item_rec.attribute12
    ,       p_revised_item_rec.attribute13
    ,       p_revised_item_rec.attribute14
    ,       p_revised_item_rec.attribute15
    ,       p_revised_item_rec.status_type
    ,       p_revised_item_rec.start_effective_date
    ,       DECODE(p_rev_item_unexp_rec.bill_sequence_id, FND_API.G_MISS_NUM,
                   NULL, p_rev_item_unexp_rec.bill_sequence_id)
    ,       p_revised_item_rec.mrp_active
    ,       NULL /* Request ID */
    ,       l_prog_id
    ,       SYSDATE
    ,       p_revised_item_rec.update_wip
    ,       p_rev_item_unexp_rec.use_up
    ,       DECODE(p_rev_item_unexp_rec.use_up_item_id, FND_API.G_MISS_NUM,
                   NULL, p_rev_item_unexp_rec.use_up_item_id)
    ,       p_rev_item_unexp_rec.revised_item_sequence_id
    ,       p_revised_item_rec.use_up_plan_name
    ,       p_revised_item_rec.change_description
    ,       trunc(p_rev_item_unexp_rec.auto_implement_date)
    ,       p_revised_item_rec.from_end_item_unit_number
    ,       p_revised_item_rec.attribute1
    ,       p_revised_item_rec.attribute6
    ,       p_revised_item_rec.attribute10
    ,       p_revised_item_rec.original_system_reference

    /* Added by MK on 08/26/2000 ECO for Routing */
    ,       p_rev_item_unexp_rec.from_wip_entity_id
    ,       p_rev_item_unexp_rec.to_wip_entity_id
    ,       p_revised_item_rec.from_cumulative_quantity
    ,       p_revised_item_rec.lot_number
    ,       p_rev_item_unexp_rec.cfm_routing_flag
    ,       p_revised_item_rec.completion_subinventory
    ,       p_rev_item_unexp_rec.completion_locator_id
   --  ,    p_rev_item_unexp_rec.mixed_model_map_flag
    ,       p_revised_item_rec.priority
    ,       p_revised_item_rec.ctp_flag
    ,       DECODE(p_rev_item_unexp_rec.routing_sequence_id,  FND_API.G_MISS_NUM,
                   NULL, p_rev_item_unexp_rec.routing_sequence_id )
    ,       p_revised_item_rec.new_routing_revision
    ,       p_revised_item_rec.routing_comment
    ,       p_revised_item_rec.eco_for_production
    ,       p_rev_item_unexp_rec.change_id
    ,	    p_revised_item_rec.alternate_bom_code -- Added by Maloy so that ALTERNATE_BOM_DESIGNATOR Get saved and 2871651 works fine
    --Start of 11.5.10 changes
    ,       p_revised_item_rec.Transfer_Or_Copy
    ,       p_revised_item_rec.Transfer_OR_Copy_Item
    ,       p_revised_item_rec.Transfer_OR_Copy_Bill
    ,       p_revised_item_rec.Transfer_OR_Copy_Routing
    ,       p_revised_item_rec.Copy_To_Item
    ,       p_revised_item_rec.Copy_To_Item_Desc
    ,       nvl(p_rev_item_unexp_rec.status_code,p_revised_item_rec.status_type)
    ,       p_rev_item_unexp_rec.parent_revised_item_seq_id
    ,	    p_revised_item_rec.selection_option
    ,       p_revised_item_rec.selection_date
    ,       p_revised_item_rec.selection_unit_number
    ,       p_rev_item_unexp_rec.new_item_revision_id
    ,       l_current_item_revision_id
--    ,       p_rev_item_unexp_rec.current_item_revision_id
    ,       nvl(p_rev_item_unexp_rec.current_lifecycle_state_id ,l_current_lifecycle_phase_id)
    ,       p_rev_item_unexp_rec.new_lifecycle_state_id
    ,       p_revised_item_rec.enable_item_in_local_org
    ,       p_revised_item_rec.create_bom_in_local_org    --End of 11.5.10  changes
    ,       decode(nvl(p_revised_item_rec.transfer_or_copy, 'T'), 'C', l_concatenated_copy_segments, null)  --bug 16340624
    ,       p_revised_item_rec.alternate_selection_code);   --bug 16340624

  END IF;

  -- If call if from form, execute this block of code only if side effects
  -- processing has been requested
  -- By AS on 10/13/99

  IF (p_control_rec.caller_type = 'FORM' AND
      p_control_rec.validation_controller = 'SIDE_EFFECTS')
     OR
     --p_control_rec.caller_type <> 'FORM'
	      (p_control_rec.caller_type <> 'FORM' AND
 	       /* Revision should not be created for transfer items
 	       The two conditions below were added for bug 8718625 */
 	      ((p_revised_item_rec.Transfer_Or_Copy <> 'T' AND
 	      p_revised_item_rec.Transfer_Or_Copy <> 'C') OR
        p_revised_item_rec.Transfer_Or_Copy is null )) --fix for bug 9556976
  THEN
    IF Eng_Default_Revised_Item.G_DEL_UPD_INS_ITEM_REV = 3 AND
       (  p_revised_item_rec.new_revised_item_revision IS NOT NULL OR
          p_revised_item_rec.new_revised_item_revision <> FND_API.G_MISS_CHAR
	)
    THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting item revisions . . . '); END IF;
        ENG_REVISED_ITEMS_PKG.Insert_Item_Revisions
        (  x_inventory_item_id          =>
                        p_rev_item_unexp_rec.revised_item_id
         , x_organization_id            =>
                        p_rev_item_unexp_rec.organization_id
         , x_revision                   =>
                        p_revised_item_rec.new_revised_item_revision
         , x_userid                     =>
                        l_User_Id
         , x_change_notice              =>
                        p_revised_item_rec.eco_name
         , x_scheduled_date             =>
                        p_revised_item_rec.start_effective_date
         , x_revised_item_sequence_id   =>
                        p_rev_item_unexp_rec.revised_item_sequence_id
         /* Item revision description support Bug: 1667419*/
         , x_revision_description       =>
                        p_revised_item_rec.new_revised_item_rev_desc
         , p_new_revision_label         =>
                        p_revised_item_rec.new_revision_label
         , p_new_revision_reason_code   =>
                        p_rev_item_unexp_rec.new_revision_reason_code
         , p_from_revision_id           =>
                        p_rev_item_unexp_rec.from_item_revision_id
        );
    END IF;

    IF Eng_Default_Revised_Item.G_DEL_UPD_INS_RTG_REV = 3 AND
       (  p_revised_item_rec.new_routing_revision IS NOT NULL OR
          p_revised_item_rec.new_routing_revision <> FND_API.G_MISS_CHAR
	)
    THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting routing revisions . . .'); END IF;


        Insert_Routing_Revisions
        (  p_inventory_item_id =>  p_rev_item_unexp_rec.revised_item_id
         , p_organization_id   =>  p_rev_item_unexp_rec.organization_id
         , p_revision          =>  p_revised_item_rec.new_routing_revision
         , p_user_id           =>  l_user_id
         , p_login_id          =>  l_login_id
         , p_change_notice     =>  p_revised_item_rec.eco_name
         , p_effectivity_date  =>  p_revised_item_rec.start_effective_date
         , p_revised_item_sequence_id   => p_rev_item_unexp_rec.revised_item_sequence_id
        );
    END IF ;


    IF p_revised_item_rec.start_effective_date IS NOT NULL
    THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Inserting cur_sch_dates . . .'); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ECO : ' || p_revised_item_rec.eco_name); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Organization: ' ||
                to_char(p_rev_item_unexp_rec.organization_id));
END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item: ' ||
                        to_char(p_rev_item_unexp_rec.revised_item_id));
END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Effective Date: ' ||
                        to_char(p_revised_item_rec.start_effective_date));
END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item Sequence: ' ||
                        to_char(p_rev_item_unexp_rec.revised_item_sequence_id));
END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Requestor: ' ||
                to_char(p_rev_item_unexp_rec.requestor_id));
END IF;

        /*Insert_Current_Scheduled_Dates
        (  x_change_notice                 =>
                p_revised_item_rec.eco_name
         , x_organization_id               =>
                p_rev_item_unexp_rec.organization_id
         , x_revised_item_id               =>
                p_rev_item_unexp_rec.revised_item_id
         , x_scheduled_date                =>
                p_revised_item_rec.start_effective_date
         , x_revised_item_sequence_id      =>
                p_rev_item_unexp_rec.revised_item_sequence_id
         , x_requestor_id                  =>
                p_rev_item_unexp_rec.requestor_id
         , x_userid                        =>
                l_User_Id
         , x_original_system_reference     =>
                p_revised_item_rec.original_system_reference);*/

    END IF;

    IF Eng_Default_Revised_Item.G_CREATE_ALTERNATE
    THEN

        l_assembly_type := ENG_Globals.Get_ECO_Assembly_Type
                           (  p_change_notice   =>
                                        p_revised_item_rec.eco_name
                            , p_organization_id =>
                                        p_rev_item_unexp_rec.organization_id
                           );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Creating Altenate BOM . . .'); END IF;

        ENG_REVISED_ITEMS_PKG.Create_BOM
        (  x_assembly_item_id           =>
                        p_rev_item_unexp_rec.revised_item_id
         , x_organization_id            =>
                        p_rev_item_unexp_rec.organization_id
         , x_alternate_BOM_designator   =>
                        p_revised_item_rec.alternate_bom_code
         , x_userid                     =>
                        l_User_Id
         , x_change_notice              =>
                        p_revised_item_rec.eco_name
         , x_revised_item_sequence_id   =>
                        p_rev_item_unexp_rec.revised_item_sequence_id
         , x_bill_sequence_id           =>
                        p_rev_item_unexp_rec.bill_sequence_id
         , x_assembly_type              =>
                        l_assembly_type
         , x_structure_type_id          =>
                        p_rev_item_unexp_rec.structure_type_id
        );

        -- Added by MK on 02/15/2001  for Bug#1647352
        -- Set Bill Sequence Id to Revised Item table
        --
        UPDATE ENG_REVISED_ITEMS
        SET    bill_sequence_id  = p_rev_item_unexp_rec.bill_sequence_id
          ,    last_update_date  = SYSDATE     --  Last Update Date
          ,    last_updated_by   = l_user_id   --  Last Updated By
          ,    last_update_login = l_login_id  --  Last Update Login
        WHERE revised_item_sequence_id = p_rev_item_unexp_rec.revised_item_sequence_id ;

        IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Set created bill sequence id : ' || to_char(p_rev_item_unexp_rec.bill_sequence_id )
               || '  to the parenet revised item . . .') ;
        END IF ;

    END IF;


    /******************************************************************
    -- Added by MK on 09/01/2000
    -- ECO for Routing
    -- Create Alternate Routing
    ******************************************************************/

    /*IF Eng_Default_Revised_Item.G_CREATE_RTG_ALTERNATE
    THEN
        IF l_assembly_type IS NULL THEN
           l_assembly_type := ENG_Globals.Get_ECO_Assembly_Type
                           (  p_change_notice   => p_revised_item_rec.eco_name
                            , p_organization_id => p_rev_item_unexp_rec.organization_id
                           );
        END IF ;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Creating Alternate Routing. . . ');

   Error_Handler.Write_Debug('Rtg Sequence Id : '|| to_char(p_rev_item_unexp_rec.routing_sequence_id));
   Error_Handler.Write_Debug('Assembly Item : '|| to_char(p_rev_item_unexp_rec.revised_item_id));
   Error_Handler.Write_Debug('Org Id: '|| to_char(p_rev_item_unexp_rec.organization_id));
   Error_Handler.Write_Debug('Alt Code : '|| p_revised_item_rec.alternate_bom_code );
   Error_Handler.Write_Debug('Routing Type : '|| to_char(l_assembly_type));
   Error_Handler.Write_Debug('User Id: '|| to_char(l_user_id));
   Error_Handler.Write_Debug('Login Id: '|| to_char(l_login_id));


END IF;


            ENG_Globals.Create_New_Routing
            ( p_assembly_item_id            => p_rev_item_unexp_rec.revised_item_id
            , p_organization_id             => p_rev_item_unexp_rec.organization_id
            , p_alternate_routing_code      => p_revised_item_rec.alternate_bom_code
            , p_pending_from_ecn            => p_revised_item_rec.eco_name
            , p_routing_sequence_id         => p_rev_item_unexp_rec.routing_sequence_id
            , p_common_routing_sequence_id  => p_rev_item_unexp_rec.routing_sequence_id
            , p_routing_type                => l_assembly_type
            , p_last_update_date            => SYSDATE
            , p_last_updated_by             => l_user_id
            , p_creation_date               => SYSDATE
            , p_created_by                  => l_user_id
            , p_login_id                    => l_login_id
            , p_revised_item_sequence_id    => p_rev_item_unexp_rec.revised_item_sequence_id
            , p_original_system_reference   => p_revised_item_rec.original_system_reference
            , x_Mesg_Token_Tbl              => l_Mesg_Token_Tbl
            , x_return_status               => x_return_status
            ) ;

         END IF ;
*/
    END IF;


  if p_revised_item_rec.New_Revised_Item_Revision is not null
   or p_revised_item_rec.new_lifecycle_phase_name is not null then

   Update_New_Rev_Lifecycle(
    p_revised_item_seq_id     => p_rev_item_unexp_rec.revised_item_sequence_id
   , p_revised_item_id        => p_rev_item_unexp_rec.revised_item_id
   , p_org_id                 => p_rev_item_unexp_rec.organization_id
   ,p_lifecycle_name          => p_revised_item_rec.new_lifecycle_phase_name
   ,p_new_item_revision       => p_revised_item_rec.New_Revised_Item_Revision
   , p_change_notice	   => p_revised_item_rec.eco_name
  , x_Return_Status        => x_return_status);

end if;



EXCEPTION

    WHEN OTHERS THEN

            l_err_text := G_PKG_NAME || ' : (Inserting Record - Revised Item) '
                                     || substrb(SQLERRM,1,200);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(l_err_text); END IF;
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;

/*****************************************************************************
* Procedure     : Delete_Row
* Parameters IN : Revised item Key
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Procedure will perfrom the deletion of revised item and all
*                 other entities depending on that revised item.
*****************************************************************************/
PROCEDURE Delete_Row
(  p_revised_item_sequence_id   IN  NUMBER
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
l_organization_id               NUMBER := NULL;
l_revised_item_id               NUMBER := NULL;
l_revised_item_sequence_id      NUMBER := NULL;
l_bill_sequence_id              NUMBER := NULL;

l_routing_sequence_id           NUMBER := NULL ;
-- Added by MK on 09/01/2000

l_change_notice                 VARCHAR2(10) := NULL;
l_err_text                      VARCHAR2(2000) := NULL;
l_Mesg_Token_Tbl                Error_Handler.Mesg_Token_Tbl_Type;

BEGIN

    BEGIN
        SELECT  change_notice, organization_id, revised_item_id,
                revised_item_sequence_id, bill_sequence_id
                , routing_sequence_id -- Added by MK

        INTO    l_change_notice, l_organization_id, l_revised_item_id,
                l_revised_item_sequence_id, l_bill_sequence_id
                , l_routing_sequence_id -- Added by MK
        FROM    eng_revised_items
        WHERE   revised_item_sequence_id = p_revised_item_sequence_id;

        DELETE  FROM ENG_REVISED_ITEMS
        WHERE   REVISED_ITEM_SEQUENCE_ID = p_revised_item_sequence_id;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
        WHEN OTHERS THEN
                l_err_text := G_PKG_NAME ||
                              ' : (Deleting Record) - Revised Item'
                              || substrb(SQLERRM,1,200);
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => NULL
                 , p_Message_Text       => l_Err_Text
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;
    END;

    BEGIN
         ENG_REVISED_ITEMS_PKG.Delete_Details
         (  x_organization_id   => l_organization_id
          , x_revised_item_id   => l_revised_item_id
          , x_revised_item_sequence_id => p_revised_item_sequence_id
          , x_bill_sequence_id  => l_bill_sequence_id
          , x_change_notice     => l_change_notice);


        -- Added by MK on 09/01/2000
        IF l_routing_sequence_id IS NOT NULL
        THEN
            Delete_Routing_Details
            (   p_organization_id          => l_organization_id
              , p_revised_item_id          => l_revised_item_id
              , p_revised_item_sequence_id => p_revised_item_sequence_id
              , p_routing_sequence_id      => l_routing_sequence_id
              , p_change_notice            => l_change_notice) ;
        END IF ;


        EXCEPTION

             WHEN NO_DATA_FOUND THEN
                NULL;

             WHEN OTHERS THEN
                IF FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                     l_err_text := G_PKG_NAME ||
                                   ' : (Deleting Revised Item Details ' ||
                                substrb(SQLERRM,1,200);
                     Error_Handler.Add_Error_Token
                     (  p_Message_Name       => NULL
                      , p_Message_Text       => l_Err_Text
                      , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     );
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END;
END Delete_Row;

/*****************************************************************************
* Procedure     : Query_Row
* Parameters IN : Revised item id
*                 Organization Id
*                 Change Notice
*                 New Revised item revision
* Parameters OUT: Revised item exposed column record
*                 Revised item unexposed column record
*                 Mesg token Table
*                 Return Status
* Purpose       : Procedure will query the database record, seperate the values
*                 into exposed columns and unexposed columns are will return
*                 with those records.
******************************************************************************/
PROCEDURE Query_Row
( p_revised_item_id     IN  NUMBER
, p_organization_id     IN  NUMBER
, p_change_notice       IN  VARCHAR2
, p_start_eff_date      IN  DATE := NULL
, p_new_item_revision   IN  VARCHAR2
, p_new_routing_revision IN VARCHAR2 -- Added by MK
, p_from_end_item_number IN VARCHAR2 := NULL
, p_alternate_designator   IN VARCHAR2 := NULL -- To Fix 2869146
, x_revised_item_rec    OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
, x_rev_item_unexp_rec  OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
, x_Return_status       OUT NOCOPY VARCHAR2
)
IS
l_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type;
l_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item: ' || to_char(p_revised_item_id)); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Organization: ' || to_char(p_organization_id)); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ChangeNotice: ' || p_change_notice); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revision: ' || p_new_item_revision); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rtg Revision: ' || p_new_routing_revision); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Effective Date: ' || to_char(p_start_eff_date));
END IF;

    SELECT
            CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       REVISED_ITEM_ID
    ,       IMPLEMENTATION_DATE
    ,       CANCELLATION_DATE
    ,       CANCEL_COMMENTS
    ,       DISPOSITION_TYPE
    ,       NEW_ITEM_REVISION
    ,       EARLY_SCHEDULE_DATE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       STATUS_TYPE
    ,       SCHEDULED_DATE
    ,       BILL_SEQUENCE_ID
    ,       MRP_ACTIVE
    ,       UPDATE_WIP
    ,       USE_UP
    ,       USE_UP_ITEM_ID
    ,       REVISED_ITEM_SEQUENCE_ID
    ,       USE_UP_PLAN_NAME
    ,       DESCRIPTIVE_TEXT
    ,       AUTO_IMPLEMENT_DATE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE6
    ,       ATTRIBUTE10

    -- Added by MK on 09/01/2000 ECO for ROUTINGS
    ,       FROM_WIP_ENTITY_ID
    ,       TO_WIP_ENTITY_ID
    ,       FROM_CUM_QTY
    ,       LOT_NUMBER
    ,       CFM_ROUTING_FLAG
    ,       COMPLETION_SUBINVENTORY
    ,       COMPLETION_LOCATOR_ID
--     ,       MIXED_MODEL_MAP_FLAG
    ,       PRIORITY
    ,       CTP_FLAG
    ,       ROUTING_SEQUENCE_ID
    ,       NEW_ROUTING_REVISION
    ,       ROUTING_COMMENT    -- End of ECO for Routing
    ,       ECO_FOR_PRODUCTION -- Added by MK 10/06/00
    ,       CHANGE_ID
    ,       STATUS_CODE -- Added for bug 3618676
    ,       designator_selection_type --Bug 16340624
    ,       selection_option  --Bug 16340624
    ,       selection_date  --Bug 16340624

    INTO
            l_revised_item_rec.eco_name
    ,       l_rev_item_unexp_rec.organization_id
    ,       l_rev_item_unexp_rec.revised_item_id
    ,       l_rev_item_unexp_rec.implementation_date
    ,       l_rev_item_unexp_rec.cancellation_date
    ,       l_revised_item_rec.cancel_comments
    ,       l_revised_item_rec.disposition_type
    ,       l_revised_item_rec.new_revised_item_revision
    ,       l_revised_item_rec.earliest_effective_date
    ,       l_revised_item_rec.attribute_category
    ,       l_revised_item_rec.attribute2
    ,       l_revised_item_rec.attribute3
    ,       l_revised_item_rec.attribute4
    ,       l_revised_item_rec.attribute5
    ,       l_revised_item_rec.attribute7
    ,       l_revised_item_rec.attribute8
    ,       l_revised_item_rec.attribute9
    ,       l_revised_item_rec.attribute11
    ,       l_revised_item_rec.attribute12
    ,       l_revised_item_rec.attribute13
    ,       l_revised_item_rec.attribute14
    ,       l_revised_item_rec.attribute15
    ,       l_revised_item_rec.status_type
    ,       l_revised_item_rec.start_effective_date
    ,       l_rev_item_unexp_rec.bill_sequence_id
    ,       l_revised_item_rec.mrp_active
    ,       l_revised_item_rec.update_wip
    ,       l_rev_item_unexp_rec.use_up
    ,       l_rev_item_unexp_rec.use_up_item_id
    ,       l_rev_item_unexp_rec.revised_item_sequence_id
    ,       l_revised_item_rec.use_up_plan_name
    ,       l_revised_item_rec.change_description
    ,       l_rev_item_unexp_rec.auto_implement_date
    ,       l_revised_item_rec.attribute1
    ,       l_revised_item_rec.attribute6
    ,       l_revised_item_rec.attribute10

    /* Added by MK on 09/01/2000 ECO for Routing */
    ,       l_rev_item_unexp_rec.from_wip_entity_id
    ,       l_rev_item_unexp_rec.to_wip_entity_id
    ,       l_revised_item_rec.from_cumulative_quantity
    ,       l_revised_item_rec.lot_number
    ,       l_rev_item_unexp_rec.cfm_routing_flag
    ,       l_revised_item_rec.completion_subinventory
    ,       l_rev_item_unexp_rec.completion_locator_id
   --  ,    l_rev_item_unexp_rec.mixed_model_map_flag
    ,       l_revised_item_rec.priority
    ,       l_revised_item_rec.ctp_flag
    ,       l_rev_item_unexp_rec.routing_sequence_id
    ,       l_revised_item_rec.new_routing_revision
    ,       l_revised_item_rec.routing_comment
    ,       l_revised_item_rec.eco_for_production -- Added by MK on 10/06/00
    ,       l_rev_item_unexp_rec.CHANGE_ID    --Added  ON 12/12/02
    ,       l_rev_item_unexp_rec.status_code -- Added for bug 3618676
    ,        l_revised_item_rec.alternate_selection_code --Bug 16340624
    ,       l_revised_item_rec.selection_option --Bug 16340624
    ,        l_revised_item_rec.selection_date --Bug 16340624
   FROM    ENG_REVISED_ITEMS
   WHERE   revised_item_id = p_revised_item_id
     AND   organization_id = p_organization_id
     AND   change_notice   = p_change_notice
     AND   NVL(new_item_revision, 'NONE') = NVL(p_new_item_revision, 'NONE')
     AND   NVL(new_routing_revision, 'NONE') = NVL(p_new_routing_revision, 'NONE') -- Added by MK
--     AND   TRUNC(scheduled_date)  = TRUNC(p_start_eff_date)
     AND   scheduled_date  = p_start_eff_date -- Bug 3593861: Scheduled date not truncated when querying for existing records.
     AND   NVL(from_end_item_unit_number, 'NONE')
                        = NVL(p_from_end_item_number, 'NONE')
     AND   NVL(alternate_bom_designator,'-9999999999') = NVL(p_alternate_designator,'-9999999999');

        x_return_status         := ENG_Globals.G_RECORD_FOUND;

        x_revised_item_Rec      := l_revised_item_rec;
        x_rev_item_unexp_rec    := l_rev_item_unexp_rec;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Execution of Query row over . . .'); END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Query Revised Item: ' || SQLERRM); END IF;

        x_return_status := Eng_Globals.G_RECORD_NOT_FOUND;
        x_revised_item_Rec := l_revised_item_rec;
        x_rev_item_unexp_rec := l_rev_item_unexp_rec;

    WHEN OTHERS THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Query Revised Item: ' || SQLERRM); END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_revised_item_Rec := l_revised_item_rec;
        x_rev_item_unexp_rec := l_rev_item_unexp_rec;

END Query_Row;


/*****************************************************************************
* Procedure     : Perform_Writes
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : This is the only procedure exposed for the user to perform
*                 insert update and delete operations on a revised item.
*                 So based on the transaction type this procedure will call
*                 the internal insert, update and delete procedures.
******************************************************************************/
PROCEDURE Perform_Writes( p_revised_item_rec    IN
                                        Eng_Eco_Pub.Revised_Item_Rec_Type
                        , p_rev_item_unexp_rec  IN
                                        Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
                        , p_control_rec         IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
                        , x_Mesg_Token_Tbl      OUT NOCOPY
                                        Error_Handler.Mesg_Token_Tbl_Type
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        )
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

        IF p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_CREATE
        THEN
                Insert_Row(  p_revised_item_rec         => p_revised_item_rec
                           , p_rev_item_unexp_rec       => p_rev_item_unexp_rec
                           , p_control_rec              => p_control_rec
                           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                           , x_Return_Status            => l_return_status
                           );
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_return_status  := l_return_status;

        ELSIF p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_UPDATE
        THEN
                Update_Row(  p_revised_item_rec         => p_revised_item_rec
                           , p_rev_item_unexp_rec       => p_rev_item_unexp_rec
                           , p_control_rec              => p_control_rec
                           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                           , x_Return_Status            => l_return_status
                           );
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_return_status  := l_return_status;

        ELSIF p_revised_item_rec.transaction_type = Eng_Globals.G_OPR_DELETE
        THEN
                l_return_status := FND_API.G_RET_STS_SUCCESS;

                IF p_control_rec.caller_type <> 'FORM'
                THEN
                --      ENG_Validate_Revised_Item.Check_Entity_Delete
                        ENG_Validate.Check_Entity_Delete
                        (  x_return_status      => l_return_status
                        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        , p_revised_item_rec    => p_revised_item_rec
                        , p_rev_item_unexp_rec  => p_rev_item_unexp_rec
                        );
                END IF;

                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        -- Okay to Delete the item.
                        Delete_Row
                        (  p_revised_item_sequence_id =>
                                p_rev_item_unexp_rec.revised_item_sequence_id
                         , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                         , x_return_status            => l_Return_Status
                         );
                END IF;

                x_return_status := l_return_status;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

END Perform_Writes;


/********************************************************************
* API Name : Reschedule_Revised_Item
* API Type : Public PROCEDURE
* Purpose  : API to reschedule the revised item.
*            This API is called from the JAVA layer.
* Input    : p_revised_item_sequence_id , p_effectivity_date
* Output   : x_return_status
* Modifications :
*            For R12 changes have been made to this API for
*            special handling of component changes created for
*            destination bill.
*            a. Acd_type 1,3 will not exist for this case
*            b. When Acd_type = 2 , effectivity date should not be
*            updated for the components on destination bill ECOs.
*
*            For source bill ECO changes,
*            these changes in effectivity should be propagated to the
*            related replicated components.
*********************************************************************/
PROCEDURE Reschedule_Revised_Item
(   p_api_version              IN NUMBER := 1.0                         --
  , p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE           --
  , p_commit                   IN VARCHAR2 := FND_API.G_FALSE           --
  , p_validation_level         IN NUMBER  := FND_API.G_VALID_LEVEL_FULL --
  , p_debug                    IN VARCHAR2 := 'N'                       --
  , p_output_dir               IN VARCHAR2 := NULL                      --
  , p_debug_filename           IN VARCHAR2 := 'Resch_RevItem.log'       --
  , x_return_status            OUT NOCOPY VARCHAR2                      --
  , x_msg_count                OUT NOCOPY NUMBER                        --
  , x_msg_data                 OUT NOCOPY VARCHAR2                      --
  , p_revised_item_sequence_id IN NUMBER
  , p_effectivity_date         IN DATE
) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'Change_Effectivity_Date';
    l_api_version  CONSTANT NUMBER := 1.0;
    l_user_id      NUMBER;
    l_login_id     NUMBER;
    l_error_mesg   VARCHAR2(2000);

    CURSOR c_revised_item (cp_revised_item_sequence_id NUMBER) IS
    SELECT revised_item_id, bill_sequence_id, routing_sequence_id,
           change_notice, organization_id
    FROM eng_revised_items
    WHERE revised_item_sequence_id = cp_revised_item_sequence_id;

    l_rev_item     c_revised_item%ROWTYPE;
    -- R12 Changes for common BOM
    l_return_status        varchar2(80);
    l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
    -- Cursor to Fetch all source bill's component changes that are being updated
    -- by reschedule
    CURSOR c_source_components(
             cp_change_notice       eng_engineering_changes.change_notice%TYPE
           , cp_revised_item_seq_id eng_revised_items.revised_item_sequence_id%TYPE
           , cp_bill_sequence_id    bom_structures_b.bill_sequence_id%TYPE) IS
    SELECT bcb.component_sequence_id
    FROM bom_components_b bcb
    WHERE bcb.CHANGE_NOTICE = cp_change_notice
      AND bcb.revised_item_sequence_id = cp_revised_item_seq_id
      AND bcb.bill_sequence_id = cp_bill_sequence_id
      AND (bcb.common_component_sequence_id IS NULL
           OR bcb.common_component_sequence_id = bcb.component_sequence_id)
      AND bcb.IMPLEMENTATION_DATE IS NULL;

BEGIN

    l_user_id := to_number(Fnd_Profile.Value('USER_ID'));
    l_login_id := to_number(Fnd_Profile.Value('LOGIN_ID'));

    IF (p_debug = 'Y')
    THEN
        BOM_Globals.Set_Debug(p_debug);
        Error_Handler.Open_Debug_Session
        (  p_debug_filename     => p_debug_filename
         , p_output_dir         => p_output_dir
         , x_return_status      => x_return_status
         , x_error_mesg         => l_error_mesg
         );
    END IF;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('-***-Start API Reschedule_Revised_Item-***-'); END IF;
    SAVEPOINT Reschedule_Revised_Item_SP;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Fetch the revised Item Details'); END IF;
    OPEN c_revised_item(cp_revised_item_sequence_id => p_revised_item_sequence_id);
    FETCH c_revised_item INTO l_rev_item;

    -- update item revision
    UPDATE MTL_ITEM_REVISIONS_B
       SET effectivity_date = p_effectivity_date,
           last_update_date = sysdate,
	   last_updated_by = l_user_id,
	   last_update_login = l_login_id
     WHERE change_notice = l_rev_item.change_notice
       AND organization_id = l_rev_item.organization_id
       AND implementation_date is NULL
        AND inventory_item_id = l_rev_item.revised_item_id
       AND revised_item_sequence_id = p_revised_item_sequence_id;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updated '|| SQL%ROWCOUNT ||'rows for item revision effectivity'); END IF;

    -- update revised components EFFECTIVITY_DATE
    UPDATE BOM_INVENTORY_COMPONENTS bic
       SET bic.EFFECTIVITY_DATE = p_effectivity_date
     WHERE bic.CHANGE_NOTICE = l_rev_item.change_notice
       AND bic.revised_item_sequence_id = p_revised_item_sequence_id
       AND bic.bill_sequence_id = l_rev_item.bill_sequence_id
       AND (bic.common_component_sequence_id IS NULL
            OR bic.common_component_sequence_id = bic.component_sequence_id)
       -- This is to ensure that the destination bill's revised item
       -- reschedule doesnt affect its components effectivity date
       AND bic.IMPLEMENTATION_DATE IS NULL;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updated '|| SQL%ROWCOUNT ||'rows for component effectivity' ); END IF;

    -- update revised components DISABLE_DATE
    UPDATE BOM_INVENTORY_COMPONENTS bic1
       SET bic1.DISABLE_DATE = p_effectivity_date
     WHERE bic1.CHANGE_NOTICE = l_rev_item.change_notice
       AND bic1.ACD_TYPE = 3  -- ACD Type: Disable
       AND revised_item_sequence_id = p_revised_item_sequence_id
       AND bill_sequence_id = l_rev_item.bill_sequence_id
       AND bic1.IMPLEMENTATION_DATE IS NULL;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updated '|| SQL%ROWCOUNT ||'rows for component disable date' ); END IF;
    -- R12 : Common BOM changes
    -- updating the replicated components for the pending changes
    FOR c_sc IN c_source_components(l_rev_item.change_notice, p_revised_item_sequence_id, l_rev_item.bill_sequence_id)
    LOOP
        BOMPCMBM.Update_Related_Components(
            p_src_comp_seq_id => c_sc.component_sequence_id
          , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
          , x_Return_Status   => l_return_status);
    END LOOP;
    -- End changes for R12

    -- update revised operation details
    Update_Rev_Operations
     ( x_change_notice            => l_rev_item.change_notice
     , x_routing_sequence_id      => l_rev_item.routing_sequence_id
     , x_revised_item_sequence_id => p_revised_item_sequence_id
     , x_scheduled_date           => p_effectivity_date);
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updated operation sequences effectivity'); END IF;

    -- update routing revision details
    UPDATE MTL_RTG_ITEM_REVISIONS
       SET effectivity_date = p_effectivity_date,
           last_update_date = sysdate,
	   last_updated_by = l_user_id,
	   last_update_login = l_login_id
     WHERE change_notice = l_rev_item.change_notice
       AND organization_id = l_rev_item.organization_id
       AND implementation_date is NULL
       AND inventory_item_id = l_rev_item.revised_item_id
       AND revised_item_sequence_id = p_revised_item_sequence_id;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Updated '|| SQL%ROWCOUNT ||'rows for routing revision effectivity'); END IF;

    CLOSE c_revised_item;
    IF FND_API.To_Boolean (p_commit)
    THEN
        COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data );
    IF Bom_Globals.Get_Debug = 'Y'
    THEN
        Error_Handler.Write_Debug('-***-End API Reschedule_Revised_Item-***-');
        Error_Handler.Close_Debug_Session;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO Reschedule_Revised_Item_SP;
    CLOSE c_revised_item;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data );
    IF Bom_Globals.Get_Debug = 'Y'
    THEN
        Error_Handler.Write_Debug('Unexpected Error in API Reschedule_Revised_Item');
        Error_Handler.Close_Debug_Session;
    END IF;

END Reschedule_Revised_Item;

------------------------------------------------------------------------
--  API name    : Copy_Revised_Item                             --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_old_revised_item_seq_id  NUMBER     Required      --
--                p_effectivity_date         DATE       Required      --
--       OUT    : x_new_revised_item_seq_id  VARCHAR2(1)              --
--                x_return_status            VARCHAR2(30)             --
--  Version     : Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : This API is invoked only when a common bill has     --
--                pending changes associated for its WIP supply type  --
--                attributes and the common component in the source   --
--                bill is being implemented.                          --
--                This API will create a revised item in the same     --
--                status as the old revised item being passed as an   --
--                input parameter.                                    --
--                A copy of all the destination changes are then made --
--                to this revised item with the effectivity range of  --
--                the component being implemented.                    --
------------------------------------------------------------------------
PROCEDURE Copy_Revised_Item (
    p_old_revised_item_seq_id IN NUMBER
  , p_effectivity_date        IN DATE
  , x_new_revised_item_seq_id OUT NOCOPY NUMBER
--  , x_Mesg_Token_Tbl          OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
  , x_return_status           OUT NOCOPY VARCHAR2
) IS

    CURSOR c_revised_item (cp_revised_item_sequence_id NUMBER) IS
    SELECT change_notice, organization_id, revised_item_id, disposition_type
         , early_schedule_date, status_type, bill_sequence_id, mrp_active
         , DESCRIPTIVE_TEXT, change_id, ALTERNATE_BOM_DESIGNATOR, status_code
    FROM eng_revised_items
    WHERE revised_item_sequence_id = cp_revised_item_sequence_id;

    l_old_revised_item_rec  c_revised_item%ROWTYPE;
    l_revised_item_rec      Eng_Eco_Pub.Revised_Item_Rec_Type;
    l_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
    l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
BEGIN
    --
    -- Initialize OUT variables
    --
    x_new_revised_item_seq_id := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- Processing Begins
    --
    OPEN c_revised_item(p_old_revised_item_seq_id);
    FETCH c_revised_item INTO l_old_revised_item_rec;
    CLOSE c_revised_item;
    --
    -- Generate a sequence_number for the new revised item
    -- Copy only attributes required for creation of revised item context
    --
    SELECT eng_revised_items_s.NEXTVAL INTO x_new_revised_item_seq_id FROM dual;
    l_revised_item_rec.eco_name                := l_old_revised_item_rec.change_notice;
    l_rev_item_unexp_rec.organization_id       := l_old_revised_item_rec.organization_id;
    l_rev_item_unexp_rec.revised_item_id       := l_old_revised_item_rec.revised_item_id;
    l_revised_item_rec.disposition_type        := l_old_revised_item_rec.disposition_type;
    l_revised_item_rec.earliest_effective_date := l_old_revised_item_rec.early_schedule_date;
    l_revised_item_rec.status_type             := l_old_revised_item_rec.status_type;
    l_revised_item_rec.start_effective_date    := p_effectivity_date;
    l_rev_item_unexp_rec.bill_sequence_id      := l_old_revised_item_rec.bill_sequence_id;
    l_revised_item_rec.mrp_active              := l_old_revised_item_rec.mrp_active;
    l_rev_item_unexp_rec.revised_item_sequence_id := x_new_revised_item_seq_id;
    l_revised_item_rec.change_description      := l_old_revised_item_rec.DESCRIPTIVE_TEXT;
    l_rev_item_unexp_rec.cfm_routing_flag      := Bom_Default_Rtg_Header.Get_Cfm_Routing_Flag;
    l_revised_item_rec.eco_for_production      := 2;
    l_rev_item_unexp_rec.change_id             := l_old_revised_item_rec.change_id;
    l_revised_item_rec.alternate_bom_code      := l_old_revised_item_rec.ALTERNATE_BOM_DESIGNATOR;
    l_rev_item_unexp_rec.status_code           := l_old_revised_item_rec.status_code;
    l_revised_item_rec.transaction_type        := Eng_Globals.G_OPR_CREATE;
    --
    -- Call attribute defaulting
    --
    Eng_Default_Revised_Item.Attribute_Defaulting(
       p_revised_item_rec    => l_revised_item_rec
     , p_rev_item_unexp_rec  => l_rev_item_unexp_rec
     , x_revised_item_rec    => l_revised_item_rec
     , x_rev_item_unexp_rec  => l_rev_item_unexp_rec
     , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
     , x_return_status       => x_Return_Status
    );
    --
    -- Call Perform writes
    --
    Eng_Revised_Item_Util.Perform_Writes(
         p_revised_item_rec    => l_revised_item_rec
       , p_rev_item_unexp_rec  => l_rev_item_unexp_rec
       , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
       , x_Return_Status       => x_Return_Status
      );
--
-- Begin Exception handling
--
EXCEPTION
WHEN OTHERS THEN
    IF c_revised_item%ISOPEN THEN
        CLOSE c_revised_item;
    END IF;
    x_new_revised_item_seq_id := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Copy_Revised_Item;

END ENG_Revised_Item_Util;

/
