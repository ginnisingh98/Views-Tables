--------------------------------------------------------
--  DDL for Package Body ENG_REVISED_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_REVISED_ITEMS_PKG" as
/* $Header: engprvib.pls 120.7.12010000.2 2010/01/07 18:53:53 umajumde ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ENG_REVISED_ITEMS_PKG';

FUNCTION Get_High_Rev_ECO (x_organization_id    NUMBER,
                           x_revised_Item_id    NUMBER,
                           x_new_item_revision  VARCHAR2) RETURN VARCHAR2 IS
  ECO   VARCHAR2(10);
  cursor c1 is select change_notice from ENG_REVISED_ITEMS eri
                where eri.Organization_Id = x_organization_id
                  and eri.Revised_Item_Id = x_revised_item_id
                  and eri.New_Item_Revision = x_new_item_revision
                  and eri.Cancellation_Date is null;
BEGIN
  open c1;
  fetch c1 into ECO;
  close c1;
  if ECO is null then
    return(NULL);
  else
    return(ECO);
  end if;
END Get_High_Rev_ECO;


Function Get_BOM_Lists_Seq_Id RETURN NUMBER IS
  seq_id  NUMBER;
BEGIN
  select BOM_LISTS_S.nextval
    into seq_id
    from DUAL;
  return(seq_id);
END Get_BOM_Lists_Seq_Id;


PROCEDURE Insert_BOM_Lists (x_revised_item_id   NUMBER,
                            x_sequence_id       NUMBER,
                            x_bill_sequence_id  NUMBER) IS
BEGIN
  insert into BOM_LISTS (sequence_id, assembly_item_id)
                         values (x_sequence_id, x_revised_item_id);

  insert into BOM_LISTS (sequence_id, assembly_item_id)
                         select distinct(x_sequence_id), component_item_id
                           from BOM_INVENTORY_COMPONENTS
                          where bill_sequence_id = x_bill_sequence_id;
END Insert_BOM_Lists;


PROCEDURE Delete_BOM_Lists (x_sequence_id NUMBER) IS
BEGIN
  delete from BOM_LISTS
   where sequence_id = x_sequence_id;
END Delete_BOM_Lists;


PROCEDURE Delete_Details (x_organization_id             NUMBER,
                          x_revised_item_id             NUMBER,
                          x_revised_item_sequence_id    NUMBER,
                          x_bill_sequence_id            NUMBER,
                          x_change_notice               VARCHAR2)
IS
BEGIN

   delete from MTL_ITEM_REVISIONS_TL
   where revision_id IN (SELECT revision_id
                         FROM   MTL_ITEM_REVISIONS_B
                         WHERE  organization_id = x_organization_id
                         and inventory_item_id  = x_revised_item_id
                         and revised_item_sequence_Id = x_revised_item_sequence_id
                         and change_notice = x_change_notice
                         and implementation_date is null);

   delete from MTL_ITEM_REVISIONS_B
   where organization_id = x_organization_id
   and inventory_item_id = x_revised_item_id
   and revised_item_sequence_Id = x_revised_item_sequence_id
   and change_notice = x_change_notice
   and implementation_date is null;



   delete from ENG_CURRENT_SCHEDULED_DATES
   where organization_id = x_organization_id
   and revised_item_id = x_revised_item_id
   and revised_item_sequence_id = x_revised_item_sequence_id
   and change_notice = x_change_notice;

/* Deletion from BOM_BILL_OF_MATERIALS is stopped from ENGFDECN form
  This was done to fix the bug 1381912 as this causes orphan records
  in bom_inventory_components,if an another session is open that is
  using same bill header for entering the components.Now we change the
  column value of pending_from_ecn to null,instead of deleting  records
  from bom_bill_of_mterials */
/*
   delete from BOM_BILL_OF_MATERIALS bom
   where bom.bill_sequence_id = x_bill_sequence_id
   and bom.pending_from_ecn = x_change_notice
   and not exists (select null
                       from BOM_INVENTORY_COMPONENTS bic
                      where bic.bill_sequence_id = bom.bill_sequence_id
                        and (bic.change_notice is null
                             or
                             bic.change_notice <> x_change_notice
                             or
                             (bic.change_notice = x_change_notice
                             and bic.revised_item_sequence_id <> x_revised_item_sequence_id)))
     and ((bom.alternate_bom_designator is null
           and not exists (select null
                             from BOM_BILL_OF_MATERIALS bom2
                            where bom2.organization_id = bom.organization_id
                              and bom2.assembly_item_id = bom.assembly_item_id
                              and bom2.alternate_bom_designator is not null))
           or
          (bom.alternate_bom_designator is not null
           and not exists (select null
                             from ENG_REVISED_ITEMS eri
                            where eri.organization_id = bom.organization_id
                              and eri.bill_sequence_id = bom.bill_sequence_id
                              and eri.change_notice <> x_change_notice))
         );
*/
   update BOM_BILL_OF_MATERIALS bom
     set pending_from_ecn = null
   where bom.bill_sequence_id = x_bill_sequence_id
     and bom.pending_from_ecn = x_change_notice
     and not exists (select null
                       from BOM_INVENTORY_COMPONENTS bic
                      where bic.bill_sequence_id = bom.bill_sequence_id
                        and (bic.change_notice is null
                             or
                             bic.change_notice <> x_change_notice
                             or
                             (bic.change_notice = x_change_notice
                             and bic.revised_item_sequence_id <> x_revised_item_sequence_id)))
     and ((bom.alternate_bom_designator is null
           and not exists (select null
                             from BOM_BILL_OF_MATERIALS bom2
                            where bom2.organization_id = bom.organization_id
                              and bom2.assembly_item_id = bom.assembly_item_id
                              and bom2.alternate_bom_designator is not null))
           or
          (bom.alternate_bom_designator is not null
           and not exists (select null
                             from ENG_REVISED_ITEMS eri
                            where eri.organization_id = bom.organization_id
                              and eri.bill_sequence_id = bom.bill_sequence_id
                              and eri.change_notice <> x_change_notice))
         );

  update ENG_REVISED_ITEMS
     set bill_sequence_id = ''
   where bill_sequence_id = x_bill_sequence_id
     and organization_id = x_organization_id
     and implementation_date is null
     and not exists (select null
                       from BOM_BILL_OF_MATERIALS bom
                      where bom.bill_sequence_id = x_bill_sequence_id);

END Delete_Details;


PROCEDURE Create_BOM (x_assembly_item_id                NUMBER,
                      x_organization_id                 NUMBER,
                      x_alternate_BOM_designator        VARCHAR2,
                      x_userid                          NUMBER,
                      x_change_notice                   VARCHAR2,
                      x_revised_item_sequence_id        NUMBER,
                      x_bill_sequence_id                NUMBER,
                      x_assembly_type                   NUMBER,
                      x_structure_type_id               NUMBER) IS

  l_structure_type_id NUMBER;
  l_effectivity_control NUMBER;
  l_login_id            NUMBER;
BEGIN
  l_login_id          := Eng_Globals.Get_Login_Id;


  IF x_structure_type_id IS NULL
  THEN
    SELECT structure_type_id
    INTO l_structure_type_id
    FROM bom_alternate_designators
    WHERE
     ((x_alternate_BOM_designator IS NULL
       AND alternate_designator_code IS NULL
       AND organization_id = -1)
      OR
      (x_alternate_BOM_designator IS NOT NULL
       AND alternate_designator_code = x_alternate_BOM_designator
       AND organization_id = x_organization_id));
  ELSE
    l_structure_type_id := x_structure_type_id;
  END IF;

  select effectivity_control
  INTO l_effectivity_control
  from mtl_system_items
  where inventory_item_id = x_assembly_item_id
  and organization_id = x_organization_id;

  insert into BOM_BILL_OF_MATERIALS (
        assembly_item_id,
        organization_id,
        alternate_BOM_designator,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        pending_from_ecn,
        assembly_type,
        common_bill_sequence_id,
        bill_sequence_id,
        structure_type_id,
        implementation_date,
        effectivity_control,
        source_bill_sequence_id,
        pk1_value, --Bug 4707618
        pk2_value) --Bug 4707618
    values (x_assembly_item_id,
        x_organization_id,
        x_alternate_BOM_designator,
        sysdate,
        x_userid,
        sysdate,
        x_userid,
        x_userid,
        x_change_notice,
        x_assembly_type,
        x_bill_sequence_id,
        x_bill_sequence_id,
        l_structure_type_id,
        sysdate,
        l_effectivity_control,
        x_bill_sequence_id,
        x_assembly_item_id, --Bug 4707618
        x_organization_id); --Bug 4707618
END Create_BOM;


PROCEDURE Insert_Current_Scheduled_Dates (x_change_notice               VARCHAR2,
                                          x_organization_id             NUMBER,
                                          x_revised_item_id             NUMBER,
                                          x_scheduled_date              DATE,
                                          x_revised_item_sequence_id    NUMBER,
                                          x_requestor_id                NUMBER,
                                          x_userid                      NUMBER) IS
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
                revised_item_sequence_id )
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
                x_revised_item_sequence_id );
END Insert_Current_Scheduled_Dates;


PROCEDURE Delete_Item_Revisions (x_change_notice            VARCHAR2,
                                 x_organization_id          NUMBER,
                                 x_inventory_item_id        NUMBER,
                                 x_revised_item_sequence_id NUMBER)
IS
l_revision_id   NUMBER;
BEGIN
   -- Before deleting the revision, revision dependent changes should be deleted
   -- 1. Item revision sepcific Attribute changes
   -- 2. Item revision specific AML changes
   -- 3. Item revision specific Attachment changes

   --Bug No: 5530915
   --Removing the attachment changes when deleting revision

   delete from eng_attachment_changes
   where
     change_id IN (select change_id
                   from eng_engineering_changes
                   where change_notice = x_change_notice
                    and organization_id = x_organization_id) and  --change_id is required for index
     revised_item_sequence_id = x_revised_item_sequence_id and
     entity_name = 'MTL_ITEM_REVISIONS' and
     pk3_value IN (select revision_id
                   from MTL_ITEM_REVISIONS_B
                   where organization_id = x_organization_id
                     and inventory_item_id = x_inventory_item_id
                     and revised_item_sequence_Id = x_revised_item_sequence_id
                     and change_notice = x_change_notice
                     and implementation_date is null);



   delete from MTL_ITEM_REVISIONS_TL
   where revision_id IN (select revision_id
                         from MTL_ITEM_REVISIONS_B
                         where organization_id = x_organization_id
                         and inventory_item_id = x_inventory_item_id
                         and revised_item_sequence_Id = x_revised_item_sequence_id
                         and change_notice = x_change_notice
                         and implementation_date is null);

   delete from MTL_ITEM_REVISIONS_B
   where organization_id = x_organization_id
   and inventory_item_id =x_inventory_item_id
   and revised_item_sequence_Id = x_revised_item_sequence_id
   and change_notice = x_change_notice
   and implementation_date is null;


END Delete_Item_Revisions;

PROCEDURE Insert_Item_Revisions (x_inventory_item_id         NUMBER,
                                 x_organization_id           NUMBER,
                                 x_revision                  VARCHAR2,
                                 x_userid                    NUMBER,
                                 x_change_notice             VARCHAR2,
                                 x_scheduled_date            DATE,
                                 x_revised_item_sequence_id             NUMBER,
                                 x_revision_description                 VARCHAR2 := NULL,
                                 p_new_revision_label        VARCHAR2 DEFAULT NULL,
                                 p_new_revision_reason_code  VARCHAR2 DEFAULT NULL,
                                 p_from_revision_id          NUMBER DEFAULT NULL)
 IS
    l_revision_id   NUMBER;

BEGIN
          Insert_Item_Revisions (x_inventory_item_id => x_inventory_item_id,
                                 x_organization_id   => x_organization_id,
                                 x_revision          => x_revision,
                                 x_userid            => x_userid,
                                 x_change_notice     => x_change_notice,
                                 x_scheduled_date    => x_scheduled_date,
                                 x_revised_item_sequence_id => x_revised_item_sequence_id,
                                 x_revision_description     => x_revision_description,
                                 p_new_revision_label       => p_new_revision_label,
                                 p_new_revision_reason_code => p_new_revision_reason_code,
                                 p_from_revision_id         => p_from_revision_id,
                                 x_new_revision_id   => l_revision_id);
END;

PROCEDURE Insert_Item_Revisions (x_inventory_item_id         NUMBER,
                                 x_organization_id           NUMBER,
                                 x_revision                  VARCHAR2,
                                 x_userid                    NUMBER,
                                 x_change_notice             VARCHAR2,
                                 x_scheduled_date            DATE,
                                 x_revised_item_sequence_id  NUMBER,
                                 x_revision_description      VARCHAR2 := NULL,
                                 p_new_revision_label        VARCHAR2 DEFAULT NULL,
                                 p_new_revision_reason_code  VARCHAR2 DEFAULT NULL,
                                 p_from_revision_id          NUMBER DEFAULT NULL,
                                 x_new_revision_id   IN OUT NOCOPY NUMBER)
 IS
        l_language_code VARCHAR2(3);
        l_revision_id   NUMBER;
        l_Return_Status  VARCHAR2(3);

        l_att_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(4000);
        l_change_id NUMBER;
        l_curr_rev_id NUMBER;


BEGIN
 IF (Bom_globals.Get_Caller_Type <> BOM_GLOBALS.G_MASS_CHANGE) THEN -- added for bug 3534567
   insert into MTL_ITEM_REVISIONS_B (
                        inventory_item_id,
                        organization_id,
                        revision,
                        revision_label,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        change_notice,
                        ecn_initiation_date,
                        effectivity_date,
                        revised_item_sequence_id,
                        revision_id,
                        object_version_number,
                        description,
                        revision_reason
                        )
                values (x_inventory_item_id,
                        x_organization_id,
                        x_revision,
                        --x_revision,
                        decode( decode(p_new_revision_label, FND_API.G_MISS_CHAR, NULL, p_new_revision_label),
                                NULL, x_revision, p_new_revision_label),
                        sysdate,
                        x_userid,
                        sysdate,
                        x_userid,
                        x_userid,
                        x_change_notice,
                        sysdate,
                        decode(x_scheduled_date, trunc(sysdate), sysdate, x_scheduled_date),
                        x_revised_item_sequence_id,
                        mtl_item_revisions_b_s.NEXTVAL,
                        1,
                        decode(x_revision_description,FND_API.G_MISS_CHAR,NULL,x_revision_description),
                        decode(p_new_revision_reason_code, FND_API.G_MISS_CHAR, NULL, p_new_revision_reason_code)
                        )RETURNING revision_id INTO l_revision_id;

   SELECT userenv('LANG') INTO l_language_code FROM dual;
   -- description is stored in MTL_ITEM_REVISIONS_TL
   insert into MTL_ITEM_REVISIONS_TL (
                        inventory_item_id,
                        organization_id,
                        revision_id,
                        language,
                        source_lang,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        description )
                 SELECT x_inventory_item_id,
                        x_organization_id,
                        l_revision_id,
                        lang.language_code,
                        l_language_code,
                        sysdate,
                        x_userid,
                        sysdate,
                        x_userid,
                        x_userid,
                        /* Item revision description support for ECO Bug: 1667419 */
                        decode(x_revision_description,FND_API.G_MISS_CHAR,NULL,x_revision_description)
                       FROM FND_LANGUAGES lang
                       where lang.INSTALLED_FLAG in ('I', 'B')
                       and not exists
                      (select NULL
                       from MTL_ITEM_REVISIONS_TL T
                       where T.INVENTORY_ITEM_ID = x_inventory_item_id
                       and   T.ORGANIZATION_ID = x_organization_id
                       and   T.REVISION_ID = l_revision_id
                       and   T.LANGUAGE = lang.LANGUAGE_CODE);
  x_new_revision_id := l_revision_id;

--   Bug : 5520086  Item Revision Level attribute values also have to be copied.
     INV_ITEM_REVISION_PUB.copy_rev_UDA( p_organization_id    => x_organization_id
                                        ,p_inventory_item_id  => x_inventory_item_id
                                        ,p_revision_id        => x_new_revision_id
                                        ,p_revision           => x_revision
                                        ,p_source_revision_id => p_from_revision_id) ;


  -- Bug 3886562
  -- Item revision level attachments is a PLM functionality
  -- Whenever a new revision is created, all the attachments of
  -- the current revision must be copied to the new revision

  BEGIN
    -- Fetch the current revision

    --11.5.10E
    -- Fetching the from revision, if it is null, then fetching the
    -- current revision
    IF (p_from_revision_id is NULL OR
        p_from_revision_id = FND_API.G_MISS_NUM)
    THEN
      l_curr_rev_id := bom_revisions.GET_ITEM_REVISION_ID_FN(
           examine_type => 'IMPL_ONLY'
         , org_id       => x_organization_id
         , item_id      => x_inventory_item_id
         , rev_date     => SYSDATE);
    ELSE
      l_curr_rev_id := p_from_revision_id;
    END IF;

    -- Fetch the change id
    SELECT change_id
    INTO l_change_id
    FROM eng_engineering_changes
    WHERE change_notice = x_change_notice
    AND organization_id = x_organization_id;

    -- Calling API to copy attachments to the detination entity (new revision)
    Eng_attachment_implementation.Copy_Attachments_And_Changes(
           p_api_version      => 1.0
         , x_return_status    => l_att_return_status
         , x_msg_count        => l_msg_count
         , x_msg_data         => l_msg_data
         , p_change_id        => l_change_id
         , p_rev_item_seq_id  => x_revised_item_sequence_id
         , p_org_id           => x_organization_id
         , p_inv_item_id      => x_inventory_item_id
         , p_curr_rev_id      => l_curr_rev_id
         , p_new_rev_id       => l_revision_id);

  EXCEPTION
  WHEN OTHERS THEN
    -- Cannot copy attachments
    -- **No error handling done
    null;
  END;
  -- End Changes for bug 3886562
end if;  -- bug3534567
END Insert_Item_Revisions;



PROCEDURE Update_Item_Revisions (x_revision                  VARCHAR2,
                                 x_scheduled_date            DATE,
                                 x_change_notice             VARCHAR2,
                                 x_organization_id           NUMBER,
                                 x_inventory_item_id         NUMBER,
                                 x_revised_item_sequence_id  NUMBER,
                                 x_revision_description      VARCHAR2 := NULL)
IS
        l_language_code VARCHAR2(3);
        l_revision_id   NUMBER;
        l_user_id       NUMBER := FND_GLOBAL.User_Id;
        l_login_id      NUMBER := FND_GLOBAL.Login_Id;

BEGIN

   update MTL_ITEM_REVISIONS_B
   set revision = x_revision,
   revision_label = x_revision,  -- Bug No:3612330 added by sseraphi to update rev label along with rev code.
         effectivity_date = decode(x_scheduled_date, trunc(sysdate), sysdate, x_scheduled_date),
         last_update_date       = SYSDATE,
         last_update_login      = l_login_id,
         last_updated_by        = l_user_id
   where change_notice = x_change_notice
   and organization_id = x_organization_id
   and inventory_item_id = x_inventory_item_id
   and revised_item_sequence_id = x_revised_item_sequence_id
   RETURNING revision_id INTO l_revision_id;

   SELECT userenv('LANG') INTO l_language_code FROM dual;

   update MTL_ITEM_REVISIONS_TL
   set
         last_update_date       = SYSDATE,     --who column
         last_update_login      = l_login_id,  --who column
         last_updated_by        = l_user_id,   --who column
         description            = x_revision_description,
         source_lang            = l_language_code
   where  revision_id = l_revision_id
   AND  LANGUAGE = l_language_code;

END Update_Item_Revisions;


/* Modifications :
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

PROCEDURE Update_Inventory_Components (x_change_notice                  VARCHAR2,
                                       x_bill_sequence_id               NUMBER,
                                       x_revised_item_sequence_id       NUMBER,
                                       x_scheduled_date                 DATE,
                                       x_from_end_item_unit_number      VARCHAR2 DEFAULT NULL) IS
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
  update BOM_INVENTORY_COMPONENTS
     set effectivity_date = x_scheduled_date,
         from_end_item_unit_number = x_from_end_item_unit_number,
         last_update_date = sysdate,  --Bug 9240045 fix
         last_updated_by      = BOM_Globals.Get_User_Id, --Bug 9240045 fix
         last_update_login    = BOM_Globals.Get_User_Id --Bug 9240045 fix
   where change_notice = x_change_notice
     and bill_sequence_id = x_bill_sequence_id
     and revised_item_sequence_id = x_revised_item_sequence_id
     AND (common_component_sequence_id IS NULL
            OR common_component_sequence_id = component_sequence_id)
       -- This is to ensure that the destination bill's revised item
       -- reschedule doesnt affect its components effectivity date
     and implementation_date is null;

  update BOM_INVENTORY_COMPONENTS
     set disable_date = x_scheduled_date
   where change_notice = x_change_notice
     and bill_sequence_id = x_bill_sequence_id
     and revised_item_sequence_id = x_revised_item_sequence_id
     and implementation_date is null
     and acd_type = 3;

    -- R12 : Common BOM changes
    -- updating the replicated components for the pending changes
    FOR c_sc IN c_source_components(x_change_notice, x_revised_item_sequence_id, x_bill_sequence_id)
    LOOP
        BOMPCMBM.Update_Related_Components(
            p_src_comp_seq_id => c_sc.component_sequence_id
          , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
          , x_Return_Status   => l_return_status);
    END LOOP;
    -- End changes for R12
END Update_Inventory_Components;


 -- Added for bug 3496165
/********************************************************************
 * API Name      : UPDATE_REVISION_CHANGE_NOTICE
 * Parameters IN : p_revision_id, p_change_notice
 * Parameters OUT: None
 * Purpose       : Updates the value of change_notice in the
 * mtl_item_revisions_b/_tl table with the value passed as parameter
 * for the row specified.
 *********************************************************************/
PROCEDURE UPDATE_REVISION_CHANGE_NOTICE ( p_revision_id IN NUMBER
                                        , p_change_notice IN VARCHAR2
) IS
        l_language_code VARCHAR2(3);
        l_revision_id   NUMBER;
        l_user_id       NUMBER := FND_GLOBAL.User_Id;
        l_login_id      NUMBER := FND_GLOBAL.Login_Id;
BEGIN

   UPDATE MTL_ITEM_REVISIONS_B
      SET change_notice = p_change_notice,
          last_update_date = SYSDATE,
          last_update_login = l_login_id,
          last_updated_by = l_user_id
    WHERE revision_id = p_revision_id;

   SELECT userenv('LANG')
     INTO l_language_code
     FROM dual;

   UPDATE MTL_ITEM_REVISIONS_TL
      SET last_update_date = SYSDATE,     --who column
          last_update_login = l_login_id,  --who column
          last_updated_by = l_user_id,   --who column
          source_lang = l_language_code
   where  revision_id = l_revision_id
   AND  LANGUAGE = l_language_code;

 END UPDATE_REVISION_CHANGE_NOTICE;

PROCEDURE Query_Target_Revised_Item (
    p_api_version          IN  NUMBER   := 1.0
  , p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
--  , p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
--  , p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_msg_count            OUT NOCOPY NUMBER
  , x_msg_data             OUT NOCOPY VARCHAR2
  , p_change_id            IN NUMBER
  , p_organization_id      IN NUMBER
  , p_revised_item_id      IN NUMBER
  , p_revision_id          IN NUMBER
  , x_revised_item_seq_id  OUT NOCOPY NUMBER
  )
IS
  CURSOR c_check_revision_id IS
  SELECT 1
  FROM mtl_item_revisions
  WHERE revision_id = p_revision_id
  AND inventory_item_id = p_revised_item_id
  AND organization_id = p_organization_id;

  CURSOR c_query_revised_item IS
  SELECT eri.revised_item_sequence_id
    FROM eng_revised_items eri , mtl_system_items_vl msiv
   WHERE eri.change_id = p_change_id
     AND eri.organization_id = p_organization_id
     AND eri.revised_item_id = p_revised_item_id
     AND eri.revised_item_id = msiv.inventory_item_id
     AND eri.organization_id = msiv.organization_id
     AND decode(msiv.bom_item_type ,
           4 , nvl(FND_PROFILE.value('ENG:STANDARD_ITEM_ECN_ACCESS'), 1) ,
           3 , nvl(FND_PROFILE.value('ENG:PLANNING_ITEM_ECN_ACCESS'), 1) ,
           2 , nvl(FND_PROFILE.value('ENG:MODEL_ITEM_ECN_ACCESS'), 1) ,
           1 , nvl(FND_PROFILE.value('ENG:MODEL_ITEM_ECN_ACCESS'), 1) , 1) = 1
     AND (eri.status_type = 1
          OR (eri.status_type = 10
              AND EXISTS
                 (SELECT 1
                    FROM eng_change_statuses ecsb
                   WHERE ecsb.status_code = eri.status_code
                     AND ecsb.status_type = 1)))
     AND nvl(eri.new_item_revision_id, eri.current_item_revision_id)
             = nvl(p_revision_id, nvl(eri.new_item_revision_id, eri.current_item_revision_id))
     AND eri.scheduled_date IN
             (SELECT eri2.scheduled_date
                FROM eng_revised_items eri2
               WHERE eri2.change_id = eri.change_id
                 AND eri2.organization_id = eri.organization_id
                 AND eri2.revised_item_id = eri.revised_item_id)
  ORDER BY eri.scheduled_date DESC;

  l_dummy         NUMBER;
  l_return_status VARCHAR2(1);
  l_api_name      VARCHAR2(30);
  l_api_version   NUMBER;
BEGIN

    l_api_name := 'QUERY_TARGET_REVISED_ITEM';
    l_api_version := 1.0;

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;
    l_return_status := 'S';

    -- Validate the revision id
    IF p_revision_id IS NOT NULL
    THEN
        OPEN c_check_revision_id;
        FETCH c_check_revision_id INTO l_dummy;
        CLOSE c_check_revision_id;

        IF l_dummy <> 1
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Fnd_message.set_name('ENG', 'ENG_REVISION_INVALID');
                Fnd_msg_pub.Add;
            END IF;
        END IF;
    END IF;
    IF l_return_status = 'S'
    THEN
        OPEN c_query_revised_item;
        FETCH c_query_revised_item INTO x_revised_item_seq_id;
        CLOSE c_query_revised_item;
    END IF;
    -- Closing
    x_return_status := l_return_status;

    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data
      );

EXCEPTION
WHEN OTHERS THEN
    IF c_check_revision_id%ISOPEN THEN
        CLOSE c_check_revision_id;
    END IF;
    IF c_query_revised_item%ISOPEN THEN
        CLOSE c_query_revised_item;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data
      );

END Query_Target_Revised_Item;

PROCEDURE Get_Component_Intf_Change_Dtls (
    p_api_version             IN  NUMBER   := 1.0
  , p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
--  , p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
--  , p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , p_change_id                 IN NUMBER
  , p_change_notice             IN VARCHAR2
  , p_organization_id           IN NUMBER
  , p_revised_item_id           IN NUMBER
  , p_bill_sequence_id          IN NUMBER
  , p_component_item_id         IN NUMBER
  , p_effectivity_date          IN DATE    := NULL
  , p_from_end_item_unit_number IN NUMBER  := NULL
  , p_from_end_item_rev_id      IN NUMBER  := NULL
  , p_old_component_sequence_id IN NUMBER  := NULL
  , p_transaction_type          IN VARCHAR2
  , x_revised_item_sequence_id  OUT NOCOPY NUMBER
  , x_component_sequence_id     OUT NOCOPY NUMBER
  , x_acd_type                  OUT NOCOPY NUMBER
  , x_change_transaction_type   OUT NOCOPY VARCHAR2
  )
IS
  l_return_status          VARCHAR2(1);
  l_api_name               VARCHAR2(30);
  l_api_version            NUMBER;

  CURSOR c_bill_details IS
  SELECT alternate_bom_designator
  FROM bom_structures_b
  WHERE bill_sequence_id = p_bill_sequence_id;

  CURSOR c_query_revised_item
  IS
  SELECT revised_item_sequence_id
    FROM eng_revised_items
   WHERE revised_item_id   = p_revised_item_id
     AND (p_effectivity_date IS NULL OR scheduled_date = p_effectivity_date)
     AND bill_sequence_id  = p_bill_sequence_id
     AND NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR)
                           = nvl(p_from_end_item_unit_number, FND_API.G_MISS_CHAR)
     AND nvl(from_end_item_rev_id, '-1')
                           = nvl(p_from_end_item_rev_id, '-1')
     AND change_id         = p_change_id
     AND status_type IN (1);

  CURSOR c_query_revised_component
  IS
  SELECT revised_item_sequence_id, acd_type, component_sequence_id
    FROM bom_components_b
   WHERE component_item_id = p_component_item_id
     AND (p_effectivity_date IS NULL OR effectivity_date = p_effectivity_date)
     AND bill_sequence_id  = p_bill_sequence_id
     AND NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR)
                           = nvl(p_from_end_item_unit_number, FND_API.G_MISS_CHAR)
     AND nvl(from_end_item_rev_id, '-1')
                           = nvl(p_from_end_item_rev_id, '-1')
     AND change_notice     = p_change_notice
     AND old_component_sequence_id = p_old_component_sequence_id
     AND implementation_date IS NULL;

BEGIN

    l_api_name := 'GET_COMPONENT_INTF_CHANGE_DTLS';
    l_api_version := 1.0;

    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;
    l_return_status := 'S';

 /*     IF l_dummy <> 1
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Fnd_message.set_name('ENG', 'ENG_effectivity_details not provided INVALID');
                Fnd_msg_pub.Add;
            END IF;
        END IF;
*/

    IF (p_transaction_type = 'CREATE')
    THEN
        x_change_transaction_type := 'CREATE';
        x_acd_type := 1;
    ELSIF (p_transaction_type = 'DISABLE')
    THEN
        x_change_transaction_type := 'CREATE';
        x_acd_type := 3;
    ELSIF (p_transaction_type = 'DELETE')
    THEN
        x_change_transaction_type := 'DELETE';
        x_acd_type := 0;
    ELSIF (p_transaction_type = 'UPDATE')
    THEN
        OPEN c_query_revised_component;
        FETCH c_query_revised_component INTO x_revised_item_sequence_id, x_acd_type, x_component_sequence_id;
        IF c_query_revised_component%NOTFOUND
        THEN
            x_change_transaction_type := 'CREATE';
            x_acd_type := 2;
        END IF;
        CLOSE c_query_revised_component;
    END IF;
    -- Closing
    x_return_status := l_return_status;

    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data
      );

EXCEPTION
WHEN OTHERS THEN
    IF c_query_revised_component%ISOPEN
    THEN
        CLOSE c_query_revised_component;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data
      );
END Get_Component_Intf_Change_Dtls;

-- Bug 4290411
/********************************************************************
 * API Name      : Check_Rev_Comp_Editable
 * Parameters IN : p_component_sequence_id
 * Parameters OUT: x_rev_comp_editable_flag
 * Purpose       : The API is called from bom explosion to check if
 *                 revised component is editable.
 *                 This api does not check change header status/workflow
 *                 and user access as PW already handles this.
 *********************************************************************/
PROCEDURE Check_Rev_Comp_Editable (
    p_component_sequence_id   IN NUMBER
  , x_rev_comp_editable_flag  OUT NOCOPY VARCHAR2 -- FND_API.G_TRUE, FND_API.G_FALSE
) IS
  -- Cursor to check if revised component is editable
  -- 1: revised item  privilege based on profile access values
  -- 2: revised item status check
  -- 3: common bom for src pending changes
  CURSOR c_chk_rev_comp_editable IS
  SELECT eri.revised_item_sequence_id
    FROM eng_revised_items eri , mtl_system_items_vl msiv , bom_components_b bcb
   WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
     and bcb.component_sequence_id = p_component_sequence_id
     AND eri.revised_item_id = msiv.inventory_item_id
     AND eri.organization_id = msiv.organization_id
    -- 1: revised item  privilege based on profile access values
     AND decode(msiv.bom_item_type ,
           4 , nvl(FND_PROFILE.value('ENG:STANDARD_ITEM_ECN_ACCESS'), 1) ,
           3 , nvl(FND_PROFILE.value('ENG:PLANNING_ITEM_ECN_ACCESS'), 1) ,
           2 , nvl(FND_PROFILE.value('ENG:MODEL_ITEM_ECN_ACCESS'), 1) ,
           1 , nvl(FND_PROFILE.value('ENG:MODEL_ITEM_ECN_ACCESS'), 1) , 1) = 1
     -- 2: revised item status check
     AND (eri.status_type = 1
          OR (eri.status_type = 10
              AND EXISTS
                 (SELECT 1
                    FROM eng_change_statuses ecsb
                   WHERE ecsb.status_code = eri.status_code
                     AND ecsb.status_type = 1)))
     -- 3: common bom for src pending changes
     AND bcb.bill_sequence_id = eri.bill_sequence_id;
  l_revised_item_seq_id NUMBER;
BEGIN
  x_rev_comp_editable_flag := FND_API.G_FALSE;
  OPEN c_chk_rev_comp_editable;
  FETCH c_chk_rev_comp_editable INTO l_revised_item_seq_id;
  IF (c_chk_rev_comp_editable%FOUND)
  THEN
    x_rev_comp_editable_flag := FND_API.G_TRUE;
  END IF;
  CLOSE c_chk_rev_comp_editable;
EXCEPTION
WHEN OTHERS THEN
  IF (c_chk_rev_comp_editable%ISOPEN)
  THEN
    CLOSE c_chk_rev_comp_editable;
  END IF;
END Check_Rev_Comp_Editable;

END ENG_REVISED_ITEMS_PKG ;

/
