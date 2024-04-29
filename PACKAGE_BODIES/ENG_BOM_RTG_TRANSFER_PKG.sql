--------------------------------------------------------
--  DDL for Package Body ENG_BOM_RTG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_BOM_RTG_TRANSFER_PKG" AS
/* $Header: ENGPTRFB.pls 120.4 2006/03/06 08:13:20 prgopala noship $ */

-- +--------------------------- RAISE_ERROR ----------------------------------+

-- NAME
-- RAISE_ERROR

-- DESCRIPTION
-- Raise generic error message. For sql error failures, places the SQLERRM
-- error on the message stack

-- REQUIRES
-- func_name: function name
-- stmt_num : statement number

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE RAISE_ERROR (
func_name   VARCHAR2,
stmt_num    NUMBER,
message_name    VARCHAR2,
token       VARCHAR2
)
IS
  err_text  VARCHAR2(1000);
BEGIN
  ROLLBACK;
  err_text := func_name || '(' || stmt_num || ') ' || token;
  IF (message_name IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('ENG', message_name);
    FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
  END IF;
  APP_EXCEPTION.RAISE_EXCEPTION;
END RAISE_ERROR;

-- +-------------------------- ENG_BOM_RTG_TRANSFER --------------------------+

-- NAME
-- ENG_BOM_RTG_TRANSFER

-- DESCRIPTION
-- Transfer engineering data from engineering to manufacturing

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- mfg_item_id
-- transfer_option:
--   1. all rows
--   2. current only
--   3. current and pending
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator
-- alt_rtg_designator
-- effectivity_date
-- lastloginid not used internally just kept to support already existing usage
-- bom_rev_starting
-- rtg_rev_starting
-- ecn_name
-- item_code
--   1. transfer yes
--   2. transfer no
-- bom_code
--   1. transfer yes
--   2. transfer no
-- rtg_code
--   1. transfer yes
--   2. transfer no
-- mfg_description
-- segment1
-- segment2
-- segment3
-- segment4
-- segment5
-- segment6
-- segment7
-- segment8
-- segment9
-- segment10
-- segment11
-- segment12
-- segment13
-- segment14
-- segment15
-- segment16
-- segment17
-- segment18
-- segment19
-- segment20
-- implemented_only
--   1. yes
--   2. no
-- commit                    Introduced for BUG 3196478 OCT 2003
--   TRUE or FALSE

-- OUTPUT

-- RETURNS

-- NOTES

-- +--------------------------------------------------------------------------+

-- BUG 3196478
-- Introduce parameter X_commit to give added control over commit handling
PROCEDURE ENG_BOM_RTG_TRANSFER
(
X_org_id            IN NUMBER,
X_eng_item_id           IN NUMBER,
X_mfg_item_id           IN NUMBER,
X_transfer_option       IN NUMBER DEFAULT 2,
X_designator_option     IN NUMBER DEFAULT 1,
X_alt_bom_designator        IN VARCHAR2,
X_alt_rtg_designator        IN VARCHAR2,
X_effectivity_date      IN DATE,
X_last_login_id     IN NUMBER DEFAULT -1,
X_bom_rev_starting      IN VARCHAR2,
X_rtg_rev_starting      IN VARCHAR2,
X_ecn_name          IN VARCHAR2,
X_item_code         IN NUMBER DEFAULT 1,
X_bom_code          IN NUMBER DEFAULT 1,
X_rtg_code          IN NUMBER DEFAULT 1,
X_mfg_description       IN VARCHAR2,
X_segment1          IN VARCHAR2,
X_segment2          IN VARCHAR2,
X_segment3          IN VARCHAR2,
X_segment4          IN VARCHAR2,
X_segment5          IN VARCHAR2,
X_segment6          IN VARCHAR2,
X_segment7          IN VARCHAR2,
X_segment8          IN VARCHAR2,
X_segment9          IN VARCHAR2,
X_segment10         IN VARCHAR2,
X_segment11         IN VARCHAR2,
X_segment12         IN VARCHAR2,
X_segment13         IN VARCHAR2,
X_segment14         IN VARCHAR2,
X_segment15         IN VARCHAR2,
X_segment16         IN VARCHAR2,
X_segment17         IN VARCHAR2,
X_segment18         IN VARCHAR2,
X_segment19         IN VARCHAR2,
X_segment20         IN VARCHAR2,
X_implemented_only      IN NUMBER DEFAULT 2,
X_unit_number           IN VARCHAR2 DEFAULT NULL,
X_commit                        IN BOOLEAN DEFAULT TRUE
)
IS
  X_identical       NUMBER; -- eng_item and mfg_item are the same
                                -- 1 = yes, 2 = no
  X_end         EXCEPTION;
  l_return_status       VARCHAR2(1);                -- ERES
  l_msg_count           NUMBER;                     -- ERES
  l_msg_data            VARCHAR2(2000);             -- ERES

-- Bug#3196367.
  l_Common_Org_Id      NUMBER;
  l_Common_Assembly_Item_Id  NUMBER;
  l_Common_Bill_Sequence_Id  NUMBER;
--  l_Common_Alternate BOM_ALTERNATE_DESIGNATORS.ALTERNATE_DESIGNATOR_CODE%TYPE;
  -- Common Item Cursor to fetch the distinct items
   CURSOR common_item_csr IS
        -- Get DISTINCT items.  This is only item transfer
    SELECT DISTINCT NVL(COMMON_ASSEMBLY_ITEM_ID,ASSEMBLY_ITEM_ID) COMMON_ASSEMBLY_ITEM_ID,
           NVL(COMMON_ORGANIZATION_ID,ORGANIZATION_ID) COMMON_ORG_ID
    FROM BOM_BILL_OF_MATERIALS BOM
    WHERE BOM.ORGANIZATION_ID = X_org_id
    AND BOM.ASSEMBLY_ITEM_ID = X_eng_item_id
    AND nvl(bom.effectivity_control, 1) <> 4 -- Bug 4210718
    AND ((X_designator_option = 2 AND
            BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
               OR (X_designator_option = 3 AND
               BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
               OR (X_designator_option = 1));
   CURSOR other_reference_item_csr IS
         -- Get DISTINCT items.  This is only item transfer Added
	 --AND RBOM.COMMON_BILL_SEQUENCE_ID = NVL(CBOM.COMMON_BILL_SEQUENCE_ID,CBOM.BILL_SEQUENCE_ID)
         --for performance issue.
    SELECT DISTINCT RBOM.ASSEMBLY_ITEM_ID ASSEMBLY_ITEM_ID, RBOM.ORGANIZATION_ID ORG_ID
    FROM BOM_BILL_OF_MATERIALS RBOM, MTL_SYSTEM_ITEMS_B MST, BOM_BILL_OF_MATERIALS CBOM
    WHERE CBOM.ORGANIZATION_ID = X_org_id
    AND CBOM.ASSEMBLY_ITEM_ID = X_eng_item_id
    AND ((X_designator_option = 2 AND
            CBOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
               OR (X_designator_option = 3 AND
               CBOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
               OR (X_designator_option = 1))
    AND RBOM.COMMON_ASSEMBLY_ITEM_ID = NVL(CBOM.COMMON_ASSEMBLY_ITEM_ID,CBOM.ASSEMBLY_ITEM_ID)
    AND RBOM.COMMON_ORGANIZATION_ID = NVL(CBOM.COMMON_ORGANIZATION_ID,CBOM.ORGANIZATION_ID)
    AND RBOM.COMMON_BILL_SEQUENCE_ID = NVL(CBOM.COMMON_BILL_SEQUENCE_ID,CBOM.BILL_SEQUENCE_ID)
    AND NVL(RBOM.ALTERNATE_BOM_DESIGNATOR,'PRIMARY') = NVL(CBOM.ALTERNATE_BOM_DESIGNATOR,'PRIMARY')
    AND MST.INVENTORY_ITEM_ID = RBOM.ASSEMBLY_ITEM_ID
    AND MST.ORGANIZATION_ID = RBOM.ORGANIZATION_ID
    AND nvl(rbom.effectivity_control, 1) <> 4 -- Bug 4210718
    AND MST.ENG_ITEM_FLAG = 'Y'; -- Fetch only engineering items.  Because it could have been just transferred.
  -- Cursor will fetch either the source bill or the bill which is not commoned.
   CURSOR common_bill_csr IS
    SELECT NVL(COMMON_ASSEMBLY_ITEM_ID,ASSEMBLY_ITEM_ID) COMMON_ASSEMBLY_ITEM_ID, NVL(COMMON_ORGANIZATION_ID,ORGANIZATION_ID) COMMON_ORG_ID,
           SOURCE_BILL_SEQUENCE_ID, ALTERNATE_BOM_DESIGNATOR
    FROM BOM_BILL_OF_MATERIALS BOM
    WHERE BOM.ORGANIZATION_ID = X_org_id
    AND BOM.ASSEMBLY_ITEM_ID = X_eng_item_id
    AND ((X_designator_option = 2 AND
            BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
               OR (X_designator_option = 3 AND
               BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
               OR (X_designator_option = 1));
  -- Cursor to fetch all the reference bill if the bill to be transfered is common or reference bill.
/*   CURSOR reference_bill_csr(cp_Common_Org_Id NUMBER, cp_Common_Assembly_Item_Id NUMBER) IS
    SELECT ASSEMBLY_ITEM_ID ASSEMBLY_ITEM_ID, ORGANIZATION_ID ORG_ID
    FROM BOM_BILL_OF_MATERIALS BOM
    WHERE BOM.COMMON_ORGANIZATION_ID = cp_Common_Org_Id
    AND BOM.COMMON_ASSEMBLY_ITEM_ID = cp_Common_Assembly_Item_Id -- Fix for bug 3519193. Changed the cursor parameter name
    AND ((X_designator_option = 2 AND
            BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
               OR (X_designator_option = 3 AND
               BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
               OR (X_designator_option = 1))
    AND BOM.BILL_SEQUENCE_ID <> BOM.COMMON_BILL_SEQUENCE_ID; -- Make sure source not fetched
*/
   CURSOR other_reference_bill_csr( cp_Source_Bill_Sequence_Id NUMBER, cp_Assembly_Item_Id NUMBER) IS
    SELECT ASSEMBLY_ITEM_ID ASSEMBLY_ITEM_ID, ORGANIZATION_ID ORG_ID
    FROM BOM_BILL_OF_MATERIALS BOM
    WHERE BOM.Source_BILL_SEQUENCE_ID = cp_Source_Bill_Sequence_Id
    AND BOM.BILL_SEQUENCE_ID <> BOM.Source_BILL_SEQUENCE_ID; -- Make sure source not fetched
-- End Bug#3196367.
BEGIN

  -- if somehow a row is passed with all transfer options = no, return.
  IF ( X_item_code = 2 and X_bom_code = 2 and X_rtg_code = 2) THEN
    RAISE X_end; -- clean exit from package
  END IF;

  IF ( X_eng_item_id = X_mfg_item_id ) THEN -- no name changes
    X_identical := 1;
  END IF;

  -- call ITEM_TRANSFER function when item is engineering item.

  IF ( X_item_code = 1 ) THEN
     -- Bug#3503220
     -- First Transfer the Item from which the transfer is being called.
     ENG_ITEM_PKG.ITEM_TRANSFER(X_org_id => X_org_id,
                             X_eng_item_id => X_eng_item_id,
                               X_mfg_item_id => X_mfg_item_id,
			       x_last_login_id => -1,
                               X_mfg_description => X_mfg_description,
                               X_ecn_name => X_ecn_name,
                               X_bom_rev_starting => X_bom_rev_starting,
                               X_segment1 => X_segment1,
                               X_segment2 => X_segment2,
                               X_segment3 => X_segment3,
                               X_segment4 => X_segment4,
                               X_segment5 => X_segment5,
                               X_segment6 => X_segment6,
                               X_segment7 => X_segment7,
                               X_segment8 => X_segment8,
                               X_segment9 => X_segment9,
                               X_segment10 => X_segment10,
                               X_segment11 => X_segment11,
                               X_segment12 => X_segment12,
                               X_segment13 => X_segment13,
                               X_segment14 => X_segment14,
                               X_segment15 => X_segment15,
                               X_segment16 => X_segment16,
                               X_segment17 => X_segment17,
                               X_segment18 => X_segment18,
                               X_segment19 => X_segment19,
                               X_segment20 => X_segment20);
      -- Bug#3196367
         -- After transferring the item from which the transfer is called transfer the items for
     -- the common bills which it refers.  This should happen only when it is a bill transfer.
      IF ( X_bom_code = 1 AND X_eng_item_id = X_mfg_item_id) THEN
         FOR common_rec IN common_item_csr LOOP
            l_Common_Org_Id := common_rec.COMMON_ORG_ID;
            l_Common_Assembly_Item_Id := common_rec.COMMON_ASSEMBLY_ITEM_ID;
            -- Call transfer only if Common Item and X_eng_item_id are different
            -- Because the X_eng_item_id is already transferred in the beginning.
            IF ( l_Common_Assembly_Item_Id <> X_eng_item_id ) THEN
                ENG_ITEM_PKG.ITEM_TRANSFER(X_org_id => l_Common_Org_Id,
                         X_eng_item_id => l_Common_Assembly_Item_Id,
                           X_mfg_item_id => l_Common_Assembly_Item_Id,
			   x_last_login_id => -1,
                           X_mfg_description => X_mfg_description,
                           X_ecn_name => X_ecn_name,
                           X_bom_rev_starting => X_bom_rev_starting,
                           X_segment1 => X_segment1,
                           X_segment2 => X_segment2,
                           X_segment3 => X_segment3,
                           X_segment4 => X_segment4,
                           X_segment5 => X_segment5,
                           X_segment6 => X_segment6,
                           X_segment7 => X_segment7,
                           X_segment8 => X_segment8,
                           X_segment9 => X_segment9,
                           X_segment10 => X_segment10,
                           X_segment11 => X_segment11,
                           X_segment12 => X_segment12,
                           X_segment13 => X_segment13,
                           X_segment14 => X_segment14,
                           X_segment15 => X_segment15,
                           X_segment16 => X_segment16,
                           X_segment17 => X_segment17,
                           X_segment18 => X_segment18,
                           X_segment19 => X_segment19,
                           X_segment20 => X_segment20);
                     END IF;
             -- Transfer the Items which are referencing the common bill but it should not be the item from
             -- which the transfer is being called.  X_eng_item_id takes care of the above check.
             FOR other_reference_rec IN other_reference_item_csr LOOP
                ENG_ITEM_PKG.ITEM_TRANSFER(X_org_id => other_reference_rec.ORG_ID,
                         X_eng_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
                           X_mfg_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
			   x_last_login_id => -1,
                           X_mfg_description => X_mfg_description,
                           X_ecn_name => X_ecn_name,
                           X_bom_rev_starting => X_bom_rev_starting,
                           X_segment1 => X_segment1,
                           X_segment2 => X_segment2,
                           X_segment3 => X_segment3,
                           X_segment4 => X_segment4,
                           X_segment5 => X_segment5,
                           X_segment6 => X_segment6,
                           X_segment7 => X_segment7,
                           X_segment8 => X_segment8,
                           X_segment9 => X_segment9,
                           X_segment10 => X_segment10,
                           X_segment11 => X_segment11,
                           X_segment12 => X_segment12,
                           X_segment13 => X_segment13,
                           X_segment14 => X_segment14,
                           X_segment15 => X_segment15,
                           X_segment16 => X_segment16,
                           X_segment17 => X_segment17,
                           X_segment18 => X_segment18,
                           X_segment19 => X_segment19,
                           X_segment20 => X_segment20);
             END LOOP; -- Loop ends for referencing item transfer
         END LOOP; -- Loop ends for common item transfer
         -- Fetch all the reference bills and transfer the corresponding items.
            END IF;     --  FOR IF ( X_bom_code = 1 ) -- Bug#3196367

    -- ERES BEGIN
    -- ==========
    IF NVL(x_identical,2) = 2 THEN
      -- determine eRecord_ID of parent eRecord
      -- if ERES is not in use, this might be NULL
      -- =========================================
      QA_EDR_STANDARD.Get_Erecord_ID
                     ( p_api_version   => 1.0
                     , p_init_msg_list => FND_API.G_TRUE
                     , x_return_status => l_return_status
                     , x_msg_count     => l_msg_count
                     , x_msg_data      => l_msg_data
                     , p_event_name    => 'oracle.apps.eng.copyToManufacturing'
                     , p_event_key     => to_char(X_eng_item_id)||'-'||to_char(X_org_id)||'-'||to_char(X_mfg_item_id)
                     , x_erecord_id    => G_PARENT_ERECORD_ID
                     );
      -- invoke eRecord logging
      -- ======================
      IF G_PARENT_ERECORD_ID is NOT NULL THEN
        -- Retrieve the organization code needed as part of the user key
        -- =============================================================
        select organization_code into G_ORG_CODE
          from mtl_parameters
          where organization_id = X_org_id;

       -- BUG 3503220 - Ensure item name reflects new copy
       -- ================================================
       select concatenated_segments into G_ITEM_NAME
        from mtl_system_items_kfv
        where inventory_item_id = X_mfg_item_id AND organization_id = X_org_id;


        ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord
            ( p_event_name    =>'oracle.apps.inv.itemCreate'
            , p_event_key     =>to_char(X_org_id)||'-'||to_char(X_mfg_item_id)
            , p_user_key      =>G_ORG_CODE||'-'||G_ITEM_NAME
            , p_parent_event_key => to_char(X_eng_item_id)||'-'||to_char(X_org_id)||'-'||to_char(X_mfg_item_id)
            );
      END IF;
    END IF;
    -- ERES END
    -- ========
  END IF;

  -- at this point, all items have been transferred to manufacturing, and
  -- all revisions for bill/item have been set by ITEM_TRANSFER function.
  --
  -- if items are already manufacturing items when passed from the form,
  -- then need to check the revision. if new rev means user wants to put
  -- in new revision.

  IF ( X_rtg_code = 1 ) THEN

    IF ( X_rtg_rev_starting IS NOT null ) THEN

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_RTG_ITEM_REVISIONS(X_inventory_item_id => X_mfg_item_id,
                                                       X_organization_id => X_org_id,
                                                       X_process_revision => X_rtg_rev_starting,
                                                       X_last_update_date => SYSDATE,
                                                       X_last_updated_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                       X_creation_date => SYSDATE,
                                                       X_created_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                       X_last_update_login => to_number(Fnd_Profile.Value('LOGIN_ID')),
                                                       X_effectivity_date => SYSDATE,
                                                       X_change_notice => X_ecn_name,
                                                       X_implementation_date => SYSDATE);

    END IF;

    IF ( X_identical = 1 ) THEN

      -- change routing type to 1 (mfg)

      ENG_ROUTING_PKG.ROUTING_UPDATE(X_org_id => X_org_id,
                                     X_eng_item_id => X_eng_item_id,
                                     X_designator_option => X_designator_option,
                                     X_transfer_option => X_transfer_option,
                                     X_alt_rtg_designator => X_alt_rtg_designator,
                                     X_effectivity_date => X_effectivity_date);
    ELSE

      ENG_ROUTING_PKG.ROUTING_TRANSFER(X_org_id => X_org_id,
                                       X_eng_item_id => X_eng_item_id,
                                       X_mfg_item_id => X_mfg_item_id,
                                       X_designator_option => X_designator_option,
                                       X_transfer_option => X_transfer_option,
                                       X_alt_rtg_designator => X_alt_rtg_designator,
                                       X_effectivity_date => X_effectivity_date,
				       x_last_login_id => -1,
                                       X_ecn_name => X_ecn_name);

    END IF; -- end of IF ( X_identical = 1 ) THEN

  END IF; -- end of IF ( X_rtg_code = 1 ) THEN

  IF ( X_bom_code = 1 ) THEN

    IF ( X_bom_rev_starting IS NOT null AND X_item_code = 2 ) THEN

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_REVISIONS(X_inventory_item_id => X_mfg_item_id,
                                                   X_organization_id => X_org_id,
                                                   X_revision => X_bom_rev_starting,
                                                   X_last_update_date => SYSDATE,
                                                   X_last_updated_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                   X_creation_date => SYSDATE,
                                                   X_created_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                   X_last_update_login => to_number(Fnd_Profile.Value('LOGIN_ID')),
                                                   X_effectivity_date => SYSDATE,
                                                   X_change_notice => X_ecn_name,
                                                   X_implementation_date => SYSDATE);

    END IF;

    IF ( X_identical = 1 ) THEN

      -- change assembly type to 1 (mfg)
      -- Bug#3196367 Starts.
      -- Always transfer the bill from which the transfer is called.
      -- If it is a common bill although component transfer is called it transfers 0 components
      -- if the bill which is calling references some other bill.
      ENG_BOM_PKG.BOM_UPDATE(X_org_id => X_org_id,
          X_eng_item_id => X_eng_item_id,
          X_designator_option => X_designator_option,
          X_transfer_option => X_transfer_option,
          X_alt_bom_designator => X_alt_bom_designator,
          X_effectivity_date => X_effectivity_date,
          X_implemented_only => X_implemented_only,
          X_unit_number      => X_unit_number);
      ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => X_org_id,
          X_eng_item_id =>  X_eng_item_id,
          X_designator_option => X_designator_option,
          X_alt_bom_designator => X_alt_bom_designator);

      ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => X_org_id,
          X_item_id => X_eng_item_id,
          X_designator_option => X_designator_option,
          X_alt_bom_designator => X_alt_bom_designator);
      FOR common_rec IN common_bill_csr LOOP
        IF ( common_rec.COMMON_ASSEMBLY_ITEM_ID <> X_eng_item_id) THEN
          -- If Primary needs to be transferred then Designator Option is 2
          IF ( common_rec.ALTERNATE_BOM_DESIGNATOR IS NULL ) THEN
            ENG_BOM_PKG.BOM_UPDATE(X_org_id => common_rec.COMMON_ORG_ID,
                X_eng_item_id => common_rec.COMMON_ASSEMBLY_ITEM_ID,
                 -- For common bill always transfer particular alternate only.
                X_designator_option => 2,
                                X_transfer_option => X_transfer_option,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR,
                X_effectivity_date => X_effectivity_date,
                X_implemented_only => X_implemented_only,
                X_unit_number      => X_unit_number);
            ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => common_rec.COMMON_ORG_ID,
                X_eng_item_id =>  common_rec.COMMON_ASSEMBLY_ITEM_ID,
                -- For common bill always transfer particular alternate only.
                X_designator_option => 2,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);

            ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => common_rec.COMMON_ORG_ID,
                      X_item_id => common_rec.COMMON_ASSEMBLY_ITEM_ID,
                      -- For common bill always transfer particular alternate only.
                      X_designator_option => 2,
                     -- To transfer particular alternate pass alternate from the cursor
                      X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);
          ELSE
            -- If Specific Alternate needs to be transferred then Designator Option is 3
            ENG_BOM_PKG.BOM_UPDATE(X_org_id => common_rec.COMMON_ORG_ID,
                X_eng_item_id => common_rec.COMMON_ASSEMBLY_ITEM_ID,
                 -- For common bill always transfer particular alternate only.
                X_designator_option => 3,
                                X_transfer_option => X_transfer_option,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR,
                X_effectivity_date => X_effectivity_date,
                X_implemented_only => X_implemented_only,
                X_unit_number      => X_unit_number);
            ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => common_rec.COMMON_ORG_ID,
                X_eng_item_id =>  common_rec.COMMON_ASSEMBLY_ITEM_ID,
                -- For common bill always transfer particular alternate only.
                X_designator_option => 3,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);

            ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => common_rec.COMMON_ORG_ID,
                X_item_id => common_rec.COMMON_ASSEMBLY_ITEM_ID,
                -- For common bill always transfer particular alternate only.
                X_designator_option => 3,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);

          END IF;
        END IF;
        -- If there are references then just update the reference bills alone. Because already source
        -- have been copied.
        FOR other_reference_rec IN other_reference_bill_csr(common_rec.Source_BILL_SEQUENCE_ID, X_eng_item_id) LOOP
          -- For reference bills just transfer the bill.
          -- Components and Operation Sequences are transferred as part of common bill.
          -- If Primary needs to be transferred then Designator Option is 2
          IF ( common_rec.ALTERNATE_BOM_DESIGNATOR IS NULL ) THEN
            ENG_BOM_PKG.BOM_UPDATE(X_org_id => other_reference_rec.ORG_ID,
                X_eng_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
                 -- For reference bill always transfer particular alternate only.
                X_designator_option => 2,
                X_transfer_option => X_transfer_option,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR,
                X_effectivity_date => X_effectivity_date,
                X_implemented_only => X_implemented_only,
                X_unit_number      => X_unit_number);
            -- R12: Added To handle editable common bills
            ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => other_reference_rec.ORG_ID,
                X_eng_item_id =>  other_reference_rec.ASSEMBLY_ITEM_ID,
                X_designator_option => 2,
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);

            ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => other_reference_rec.ORG_ID,
                 X_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
                 X_designator_option => 2,
                 X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);
          ELSE
            -- If Specific Alternate needs to be transferred then Designator Option is 3
            ENG_BOM_PKG.BOM_UPDATE(X_org_id => other_reference_rec.ORG_ID,
                X_eng_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
                 -- For reference bill always transfer particular alternate only.
                X_designator_option => 3,
                X_transfer_option => X_transfer_option,
                -- To transfer particular alternate pass alternate from the cursor
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR,
                X_effectivity_date => X_effectivity_date,
                X_implemented_only => X_implemented_only,
                X_unit_number      => X_unit_number);
            -- R12: Added To handle editable common bills
            ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => other_reference_rec.ORG_ID,
                X_eng_item_id =>  other_reference_rec.ASSEMBLY_ITEM_ID,
                X_designator_option => 3,
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);

            ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => other_reference_rec.ORG_ID,
                X_item_id => other_reference_rec.ASSEMBLY_ITEM_ID,
                X_designator_option => 3,
                X_alt_bom_designator => common_rec.ALTERNATE_BOM_DESIGNATOR);
          END IF;

        END LOOP;   -- Loop ends for reference bills for a particular common bill.
      END LOOP;           -- Loop ends for Common Bill.
      -- Bug#3196367 Ends
    ELSE
      ENG_BOM_PKG.BOM_TRANSFER(X_org_id => X_org_id,
                               X_eng_item_id => X_eng_item_id,
                               X_mfg_item_id => X_mfg_item_id,
			       x_last_login_id => -1,
                               X_designator_option => X_designator_option,
                               X_transfer_option => X_transfer_option,
                               X_alt_bom_designator => X_alt_bom_designator,
                               X_effectivity_date => X_effectivity_date,
                               X_ecn_name => X_ecn_name,
                   X_unit_number => X_unit_number);

/*
      ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => X_org_id,
                                      X_eng_item_id =>  X_eng_item_id,
                                      X_designator_option => X_designator_option,
                                      X_alt_bom_designator => X_alt_bom_designator);
*/

      ENG_ITEM_PKG.SET_OP_SEQ(X_org_id => X_org_id,
                              X_item_id => X_mfg_item_id,
                              X_designator_option => X_designator_option,
                              X_alt_bom_designator => X_alt_bom_designator);

    END IF; -- end of IF ( X_identical = 1 ) THEN

  END IF; -- end of IF ( X_bom_code = 1 ) THEN

  -- BUG 3196478
  -- Introduce parameter to control commit handling.
  -- Default is TRUE
  IF X_commit
  THEN
    COMMIT;
  END IF;
  -- BUG 3196478 END

EXCEPTION
  WHEN X_end THEN
    null;

END ENG_BOM_RTG_TRANSFER;

----------------------------- Procedure ---------------------------------
--
--  NAME
--      Process_Erecord
--  DESCRIPTION
--      Log an electronic record for a child event associated to a parent event
--      of  'oracle.apps.eng.copyToManufacturing';
--  REQUIRES
--      p_event_name        Child event name
--      p_event_key         Child event key
--      p_user_key          Child event user key
--      p_parent_event_key  Parent event key
--  MODIFIES
--      Adds row to edr_psig_documents
--  RETURNS
--
--  NOTES
--     kxhunt               15/OCT/2003
--     Update call to RAISE_ERES_EVENT following denormalization
--     of input params.

PROCEDURE Process_Erecord( p_event_name        IN VARCHAR2
                         , p_event_key         IN VARCHAR2
                         , p_user_key          IN VARCHAR2
                         , p_parent_event_key  IN VARCHAR2)
IS
  l_event                QA_EDR_STANDARD.ERES_EVENT_REC_TYPE;
  l_children             QA_EDR_STANDARD.ERECORD_ID_TBL_TYPE;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_index            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_event_status         VARCHAR2(20);
  l_trans_status         VARCHAR2(30);
  l_overall_status       VARCHAR2(20);
  l_erecord_id           NUMBER;
  l_statement_num        NUMBER;
  l_ackn_by              VARCHAR2(80);
  i                      pls_integer;

BEGIN

    l_statement_num := 100;
    /* BUG 3237159
    Ensure labelling is consistent across the application
    =====================================================*/
    IF p_event_name = 'oracle.apps.inv.itemCreate' THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_ERES_ORG_ITEM_KEY_LABEL');
    ELSIF p_event_name = 'oracle.apps.bom.billCreate' THEN
      FND_MESSAGE.SET_NAME('BOM', 'BOM_ERES_BILL_USER_KEY');
    ELSIF p_event_name = 'oracle.apps.bom.routingCreate' THEN
       FND_MESSAGE.SET_NAME('BOM', 'BOM_ERES_ROUTING_USER_KEY');
    END IF;


    -- This is a child event.  Set up the payload
    -- ==========================================

    l_event.param_name_1  := 'DEFERRED';
    l_event.param_value_1 := 'Y';

    l_event.param_name_2     := 'POST_OPERATION_API';
    l_event.param_value_2    := NULL;

    l_event.param_name_3     := 'PSIG_USER_KEY_LABEL';
    l_event.param_value_3    := FND_MESSAGE.GET;

    l_event.param_name_4     := 'PSIG_USER_KEY_VALUE';
    l_event.param_value_4    := p_user_key;
    l_event.param_name_5     := 'PSIG_TRANSACTION_AUDIT_ID';
    l_event.param_value_5    := '-1';

    l_event.param_name_6     := '#WF_SOURCE_APPLICATION_TYPE';
    l_event.param_value_6    := 'DB';

    l_event.param_name_7     := '#WF_SIGN_REQUESTER';
    l_event.param_value_7    := FND_GLOBAL.USER_NAME;

    --associate the parent
    --====================
    l_event.param_name_10    := 'PARENT_EVENT_NAME';
    l_event.param_value_10   := 'oracle.apps.eng.copyToManufacturing';

    l_event.param_name_11    := 'PARENT_EVENT_KEY';
    l_event.param_value_11   := p_parent_event_key;

    l_event.param_name_12    := 'PARENT_ERECORD_ID';
    l_event.param_value_12   := TO_CHAR(G_PARENT_ERECORD_ID);

    --Load up the EVENT
    --=================
    l_event.event_name   := p_event_name;
    l_event.event_key    := p_event_key;

    --Raise the event
    --===============
    l_statement_num := 200;
    QA_EDR_STANDARD.Raise_ERES_Event
                   (p_api_version      => 1.0
                   ,p_init_msg_list    =>FND_API.G_TRUE
                   ,p_validation_level =>FND_API.G_VALID_LEVEL_FULL
                   ,x_return_status    =>l_return_status
                   ,x_msg_count        =>l_msg_count
                   ,x_msg_data         =>l_msg_data
                   ,p_child_erecords   =>l_children
                   ,x_event            =>l_event
                   );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    l_erecord_id := l_event.erecord_id;
    l_event_status := l_event.event_status;

    --Acknowledge
    --===========
    -- BUG 3201850 - incorporate status of NOACTION
    IF l_event_status in ('COMPLETE', 'PENDING', 'NOACTION', 'SUCCESS') THEN
      l_trans_status := 'SUCCESS';
    ELSE
      l_trans_status := 'ERROR';
    END IF;

    FND_MESSAGE.Set_Name('ENG','ENG_COPY_TITLE');
    l_ackn_by := FND_MESSAGE.Get;

    IF l_erecord_id is not null THEN
      l_statement_num := 200;
      QA_EDR_STANDARD.Send_Ackn
                     (p_api_version       => 1.0
                     ,p_init_msg_list     => FND_API.G_TRUE
                     ,x_return_status     => l_return_status
                     ,x_msg_count         => l_msg_count
                     ,x_msg_data          => l_msg_data
                     ,p_event_name        => p_event_name
                     ,p_event_key         => p_event_key
                     ,p_erecord_id        => l_erecord_id
                     ,p_trans_status      => l_trans_status
                     ,p_ackn_by           => l_ackn_by
                     ,p_ackn_note         => NULL
                     ,p_autonomous_commit => FND_API.G_FALSE
                     );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord',
                                             stmt_num => l_statement_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);

END Process_Erecord;

END ENG_BOM_RTG_TRANSFER_PKG;

/
