--------------------------------------------------------
--  DDL for Package Body BOMPCMBM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCMBM" AS
/* $Header: BOMCMBMB.pls 120.27.12010000.26 2015/07/29 06:58:17 nlingamp ship $ */

/*==========================================================================+
|   Copyright (c) 1993, 2015 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCMBMB.pls                                             |
| DESCRIPTION  : This file is a packaged body for creating
|                common bill(s)  for the following organization scope :
|                a) Single organization
|                b) Organization Hierarchy
|                c) All Organizations
| Parameters:   scope           1 - Single Organization, 2-Org Hierarchy
|                               3 - All Orgs
|               org_hierarchy   Organization Hierarchy
|               Current_org_id  Organization from where the concprogram launch
|               Common_item_from Item from which commoning to be done
|               alternate       alternate bom designator of the commonitemfrom
|               common_item_to  Item to which commoning to be done for scope=1
|               common_org_to   Org to which commoning to be done for scope=1
|               error_code      error code
|               error_msg       error message
|
| HISTORY: ..-SEP-03 odaboval added procedures Event_Acknowledgement
|          06-May-05 Abhishek Rudresh Common BOM Attr updates
+==========================================================================*/

-- ERES change begins :

G_PKG_NAME VARCHAR2(30) := 'BOMPCMBM';
-- Added who columns for bug 16813763
who_user_id                 constant number := fnd_global.user_id;
who_login_id                constant number := fnd_global.login_id;
who_request_id              constant number := fnd_global.conc_request_id;
who_program_id              constant number := fnd_global.conc_program_id;
who_program_application_id  constant number := fnd_global.prog_appl_id;
who_creation_date           constant date   := sysdate;

PROCEDURE Event_Acknowledgement( p_event_name   IN VARCHAR2
                               , p_event_key    IN VARCHAR2
                               , p_event_status IN VARCHAR2)
IS

l_erecord_id           NUMBER;
l_return_status        VARCHAR2(2);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_dummy_cnt            NUMBER;
l_trans_status         VARCHAR2(10);
l_ackn_by              VARCHAR2(200);
SEND_ACKN_ERROR        EXCEPTION;

BEGIN

-- First Get the parent event details (BillCreate/BillUpdate)
-- If the call fails or returns and error, the exception is not catched.
QA_EDR_STANDARD.GET_ERECORD_ID
       ( p_api_version   => 1.0
       , p_init_msg_list => FND_API.G_TRUE
       , x_return_status => l_return_status
       , x_msg_count     => l_msg_count
       , x_msg_data      => l_msg_data
       , p_event_name    => p_event_name
       , p_event_key     => p_event_key
       , x_erecord_id    => l_erecord_id);

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking event(commonBill)='||p_event_name||', event_key='||p_event_key||', erecord_id='||l_erecord_id||', msg_cnt='||l_msg_count);

IF (NVL( l_erecord_id, -1) >0)
THEN
  IF (p_event_status = 'SUCCESS')
  THEN
     l_trans_status := 'SUCCESS';
  ELSE
     l_trans_status := 'ERROR';
  END IF;

  -- Get message that will be send to SEND_ACKN :
  FND_MESSAGE.SET_NAME('ENG', 'BOM_ERES_ACKN_BILL');
  l_ackn_by := FND_MESSAGE.GET;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Acknowledging eRecord_id='||l_erecord_id||' with status='||l_trans_status);
  QA_EDR_STANDARD.SEND_ACKN
          ( p_api_version       => 1.0
          , p_init_msg_list     => FND_API.G_TRUE
          , x_return_status     => l_return_status
          , x_msg_count         => l_msg_count
          , x_msg_data          => l_msg_data
          , p_event_name        => p_event_name
          , p_event_key         => p_event_key
          , p_erecord_id        => l_erecord_id
          , p_trans_status      => l_trans_status
          , p_ackn_by           => l_ackn_by
          , p_ackn_note         => p_event_name||', '||p_event_key
          , p_autonomous_commit => FND_API.G_TRUE);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'After QA_EDR_STANDARD.SEND_ACKN msg='||l_msg_count);

  IF (l_return_status <> FND_API.G_TRUE)
  THEN
     RAISE SEND_ACKN_ERROR;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Normal end of acknowledgement part ');
ELSE
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Acknowledgement.');
END IF;

EXCEPTION
WHEN SEND_ACKN_ERROR THEN
          FND_MSG_PUB.Get(
            p_msg_index  => 1,
            p_data       => l_msg_data,
            p_encoded    => FND_API.G_FALSE,
            p_msg_index_out => l_dummy_cnt);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACKN Error: '||l_msg_data);

WHEN OTHERS THEN
          l_msg_data := 'ACKN Others Error='||SQLERRM;
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);


END Event_Acknowledgement;
-- ERES change ends

/*
 * Added for bug 11895331. This Procedure updates the bom_structures_b.request_id column
 * to original value after Common Bom process completes either successfully or
 * with exception.
 * Explicit commit is required, so that other ECO implementation process will be allowed
 * to progress on the same revised item. Autonomous Transaction is not required as
 * COMMIT or ROLLBACK will be performed before call to this procedure.
 *
 * @param p_req_id   Request id to update.
 * @param p_organization_id   Master Bill Organization ID.
 * @param p_assembly_item_id   Master Bill Assembly Item Id.
 * @param p_alternate   Identify Alternate Bill  default value NULL.
 * @param p_seq_num   Identify the place from where this proc being called.
*/

PROCEDURE Update_BSB_Request_Id_Column ( p_request_id        IN  NUMBER,
                                         p_organization_id   IN  NUMBER,
                                         p_assembly_item_id  IN  NUMBER,
                                         p_alternate         IN  VARCHAR2  DEFAULT  NULL,
                                         p_sequence_num      IN  NUMBER,
                                         p_commit            IN  VARCHAR2
                                        ) IS
P_COMMONBOM_IS_RUNNING  CONSTANT  NUMBER := -666;

BEGIN
  FND_FILE.PUT_LINE( FND_FILE.LOG, '************* Update_BSB_Request_Id_Column procedure Start *************') ;
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Sequence number: ' || to_char(p_sequence_num));
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'organization_id: ' || to_char(p_organization_id));
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'assembly_item_id: ' || to_char(p_assembly_item_id));
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'alternate_bom_designator: ' || p_alternate);
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'request_id: ' || to_char(p_request_id));
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_commit: ' || p_commit);
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'System Date: ' || sysdate);
  IF FND_API.To_Boolean(p_commit) THEN
    UPDATE BOM_BILL_OF_MATERIALS bbm
    SET bbm.request_id = p_request_id
    WHERE bbm.organization_id = p_organization_id
      AND bbm.assembly_item_id = p_assembly_item_id
      AND nvl(bbm.alternate_bom_designator,'NONE') = nvl(p_alternate,'NONE')
      AND bbm.request_id = P_COMMONBOM_IS_RUNNING;
    COMMIT ;
  END IF;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '************* Update_BSB_Request_Id_Column procedure End *************') ;
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Exception occured in Update_BSB_Request_Id_Column proc') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Others '||SQLCODE || ':'||SQLERRM) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '************* Update_BSB_Request_Id_Column procedure End *************') ;

END Update_BSB_Request_Id_Column;


PROCEDURE create_common_bills(
  ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  scope     IN  NUMBER    DEFAULT 1,
  org_hierarchy   IN  VARCHAR2  DEFAULT NULL,
  current_org_id    IN  NUMBER,
  common_item_from  IN  NUMBER,
  alternate   IN  VARCHAR2  DEFAULT NULL,
  common_org_to   IN  NUMBER  DEFAULT NULL,
  common_item_to    IN  NUMBER  DEFAULT NULL
  , enable_attrs_update  IN VARCHAR2
  ) IS
  t_org_code_list INV_OrgHierarchy_PVT.OrgID_tbl_type;
  l_org_name    VARCHAR2(60) ;
  common_item_from_name   VARCHAR2(200) ;
  common_item_to_name VARCHAR2(200) ;
  common_org_to_code  VARCHAR2(4) ;
  l_bill_sequence_id  NUMBER ;
  l_bill_exists     NUMBER ;
  l_assembly_type   NUMBER ;
  l_org_code    VARCHAR2(4) ;
  l_org_code_to     VARCHAR2(4) ;
  l_organization_code   VARCHAR2(4) ;
  l_assy_item_name  VARCHAR2(200) ;
  l_assembly_item_name  VARCHAR2(200) ;
  N     NUMBER := 0 ;
  I     NUMBER := 1 ;
  K     NUMBER := 1 ;
  item_not_found    NUMBER := 0 ;
  l_return_status   VARCHAR2(1) ;
  l_msg_count             NUMBER;
  starting_org_counter    NUMBER ;
  success_counter   NUMBER := 0 ;
  failure_counter   NUMBER := 0 ;
  conc_status   BOOLEAN ;
  Current_Error_Code   Varchar2(20) := NULL;
  msg     VARCHAR2(2000) ;

  /* Start changes for bug 11895331 */
  P_COMMONBOM_IS_RUNNING  CONSTANT  NUMBER := -666 ;
  P_ECOIMPL_IS_RUNNING    CONSTANT  NUMBER := -333 ;
  p_orig_request_id                 NUMBER ;
  /* End changes for bug 11895331 */


        l_bom_header_rec    Bom_Bo_Pub.Bom_Head_Rec_Type ;
  l_bom_revision_tbl    Bom_Bo_Pub.Bom_Revision_Tbl_Type ;
  l_bom_component_tbl             Bom_Bo_Pub.Bom_Comps_Tbl_Type ;
  l_bom_sub_component_tbl         Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
  l_bom_ref_designator_tbl        Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type;
  l_error_tbl     Error_Handler.Error_Tbl_Type ;

  /* Bug 3171435 fix to mainline(3386399) */
  l_bill_seq_id   NUMBER;
  delete_group_id   NUMBER;
  delete_entity_id  NUMBER;
  l_item_id   NUMBER;
  l_org_id    NUMBER;
  l_item_desc   VARCHAR2(240);
  to_proceed    NUMBER  := 0;
  common_bill_seq_id  NUMBER ;
  bill_seq_id   NUMBER;
  del_group_name    Varchar2(7);
  delete_error_rec  NUMBER  := 0;
  ERROR_MSG   VARCHAR2(200);
  RETCOD      VARCHAR2(10);
        /* End Bug 3171435 fix to mainline(3386399) */


  Hierarchy_not_specified EXCEPTION;
  invalid_common_itemorg_to EXCEPTION ;
  same_common_itemorg_to EXCEPTION;
  eco_implmentation_is_running  EXCEPTION ;   -- Added for bug 11895331

        -- ERES change begins
        l_erecord_id   NUMBER;
        -- ERES change ends
BEGIN
  /* Print the list of parameters */
  FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
  FND_FILE.PUT_LINE( FND_FILE.LOG,'SCOPE='||to_char(scope));
  FND_FILE.PUT_LINE( FND_FILE.LOG,'ORG_HIERARCHY='||org_hierarchy);
  FND_FILE.PUT_LINE( FND_FILE.LOG,'CURRENT_ORG_ID='||to_char(current_org_id));
  FND_FILE.PUT_LINE( FND_FILE.LOG,'COMMON_ITEM_FROM='||to_char(common_item_from));
  FND_FILE.PUT_LINE( FND_FILE.LOG,'ALTERNATE='||alternate);
  FND_FILE.PUT_LINE( FND_FILE.LOG,'COMMON_ORG_TO='||to_char(common_org_to));
  FND_FILE.PUT_LINE( FND_FILE.LOG,'COMMON_ITEM_TO='||to_char(common_item_to));
  FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;


  /* Start changes of bug 11895331 */

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Start - Getting lock on the bom row') ;
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'System Date: ' || sysdate);

  -- Storing the original request_id column value in a temporary variable
  SELECT request_id INTO p_orig_request_id
  FROM BOM_BILL_OF_MATERIALS bbm1
  WHERE bbm1.organization_id = current_org_id
    AND bbm1.assembly_item_id = common_item_from
    AND nvl(bbm1.alternate_bom_designator,'NONE') = nvl(alternate,'NONE');

  /* Updating the table bom_structuers_b with P_COMMONBOM_IS_RUNNING constant where
     request_id is not P_ECOIMPL_IS_RUNNING.
     If no row got updated means request_id column already stamped with
     P_ECOIMPL_IS_RUNNING and some ECO implementation process is already in progress on that
     assembly, In this case a exception will be raised and the request will be completed with error.
     If a row got updated means no other ECO process is running on that assembly,  In this case
     P_COMMONBOM_IS_RUNNING value will be stamped on request_id column and Common BOM
     request will be continued. To make visible the stamped request_id column value to all sessions
     COMMIT is required. Actual Common BOM process not started yet, so autonomous transaction not
     required in this case. */

  update BOM_BILL_OF_MATERIALS bbm2
  set bbm2.request_id = P_COMMONBOM_IS_RUNNING
  WHERE nvl(bbm2.request_id, 0) <> P_ECOIMPL_IS_RUNNING
    AND bbm2.organization_id = current_org_id
    AND bbm2.assembly_item_id = common_item_from
    AND nvl(bbm2.alternate_bom_designator,'NONE') = nvl(alternate,'NONE') ;
  if(SQL%ROWCOUNT = 0 ) then
    raise eco_implmentation_is_running;
  end if;

  COMMIT ; /* Explicit commit is required to make changes visible to all sessions */
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'End - Successfully got the lock on the bom row and processing Common BOM') ;
  /* End changes of bug 11895331 */

  /* Make sure the right set of parameter are passed */
        IF (scope = 2) AND (org_hierarchy IS NULL) THEN
    raise Hierarchy_not_specified ;
  END IF ;

        IF (scope = 1) AND ((common_item_to IS NULL) OR (common_org_to IS NULL)) THEN
    raise invalid_common_itemorg_to ;
  END IF ;

  /* Get the "common item from" item name */
  SELECT concatenated_segments
      INTO common_item_from_name
  FROM MTL_SYSTEM_ITEMS_VL
  WHERE inventory_item_id = common_item_from
    AND organization_id = current_org_id;

  /* Get the "common org to" Organization code */
  IF (scope = 1) AND (common_org_to is not null) THEN
    SELECT organization_code
         INTO common_org_to_code
    FROM ORG_ORGANIZATION_DEFINITIONS
    WHERE Organization_id = common_org_to ;
  END IF ;

  /* Get the "common Item to" item id */
  IF  (scope = 1) AND (common_item_to is not null) then
    SELECT concatenated_segments, description
        INTO common_item_to_name,l_item_desc
    FROM MTL_SYSTEM_ITEMS_VL
    WHERE inventory_item_id = common_item_to
            AND organization_id = common_org_to ;
  END IF ;


        IF ((scope = 1) AND (common_org_to = current_org_id) AND (common_item_from = common_item_to)) THEN
    raise same_common_itemorg_to ;
  END IF ;

  /* Get bill_sequence_id */
  SELECT bill_sequence_id,assembly_type
  INTO  l_bill_sequence_id,l_assembly_type
  FROM  BOM_STRUCTURES_B
  WHERE  organization_id = current_org_id
    AND assembly_item_id = common_item_from
    AND  nvl(alternate_bom_designator,'NONE') = nvl(alternate,'NONE') ;

  /* If the parameter : Scope = 1 then
                  Take the current Organization
          else If Scope = 2 is passed then
                  Call the Inventory API to get the list of Organizations
                  under the current Organization Hierarchy
  else if Scope = 3 is passed then
                  Find the list of all the Organizations (in same item master and to which access is allowed */

        IF ( scope = 2  ) THEN
                starting_org_counter := 2 ;
                SELECT organization_name
        INTO l_org_name
                FROM   org_organization_definitions
                WHERE  organization_id = current_org_id;
              INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(org_hierarchy,current_org_id,t_org_code_list) ;
         ELSIF  ( scope = 3 ) THEN
                starting_org_counter := 1 ;
                -- bug:4931463 Modified below cursor query to reduce shared memory
                for C1 in (
                            SELECT
                                orgs.ORGANIZATION_ID
                            FROM
                                ORG_ACCESS_VIEW oav,
                                MTL_SYSTEM_ITEMS_B msi,
                                MTL_PARAMETERS orgs,
                                MTL_PARAMETERS child_org
                            WHERE
                                orgs.ORGANIZATION_ID = oav.ORGANIZATION_ID
                            AND msi.ORGANIZATION_ID = orgs.ORGANIZATION_ID
                            AND orgs.MASTER_ORGANIZATION_ID = child_org.MASTER_ORGANIZATION_ID
                            AND oav.RESPONSIBILITY_ID = FND_PROFILE.Value('RESP_ID')
                            AND oav.RESP_APPLICATION_ID = FND_PROFILE.value('RESP_APPL_ID')
                            AND msi.INVENTORY_ITEM_ID =  common_item_from
                            AND orgs.ORGANIZATION_ID <> current_org_id
                            AND child_org.ORGANIZATION_ID = current_org_id
                          )
                LOOP
                        N:=N+1;
                        t_org_code_list(N) := C1.organization_id;
                END LOOP;
           ELSIF  ( scope = 1 ) then
                starting_org_counter := 1 ;
      t_org_code_list(1) := common_org_to;
           END IF;

    SELECT organization_code
         INTO l_org_code
    FROM ORG_ORGANIZATION_DEFINITIONS
    WHERE organization_id = current_org_id ;

        /*** Loop through the organization in the list of organizations ***/
  FOR I in starting_org_counter..t_org_code_list.LAST LOOP
    FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing Organization : '||t_org_code_list(I));

    SELECT organization_code
         INTO l_org_code_to
    FROM ORG_ORGANIZATION_DEFINITIONS
    WHERE organization_id = t_org_code_list(I) ;

    item_not_found := 0 ;
    IF (scope = 2 OR scope = 3) THEN
     BEGIN
      SELECT concatenated_segments, DESCRIPTION
           INTO l_assy_item_name, l_item_desc
      FROM  MTL_SYSTEM_ITEMS_VL
      WHERE organization_id =  t_org_code_list(I)
                  AND inventory_item_id = common_item_from ;
                 EXCEPTION
                       WHEN NO_DATA_FOUND THEN
            item_not_found := 1 ;
     END ;
    END IF;

                IF (item_not_found = 0) THEN
     IF (SCOPE = 2 OR SCOPE = 3) THEN
      SELECT COUNT(*)
           INTO l_bill_exists
      FROM BOM_STRUCTURES_B
      WHERE ASSEMBLY_ITEM_ID = common_item_from
          AND ORGANIZATION_ID = t_org_code_list(I)
        AND NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(alternate,'NONE') ;
    ELSIF (SCOPE = 1) THEN
      SELECT COUNT(*)
           INTO l_bill_exists
      FROM BOM_STRUCTURES_B
      WHERE ASSEMBLY_ITEM_ID = common_item_to
        AND ORGANIZATION_ID =  common_org_to
        AND NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(alternate,'NONE') ;
    END IF ;

    /* Modified if condn to include l_bill_exists = 1. This is being done to support
       Change of ownership of an existing common BOM to an other BOM */
    IF (l_bill_exists = 0 or l_bill_exists = 1) THEN -- bug 3171435 fix to mainline
      to_proceed := 0;  -- Setting this value to 0 intially.

      /* if single org then use Item to and Org to values else use current Item i.e Item from*/
      IF (scope = 1) THEN
        l_assembly_item_name := common_item_to_name ;
        l_organization_code := common_org_to_code ;
        l_org_id :=  common_org_to;
        l_item_id := common_item_to;
      ELSE
        l_assembly_item_name := l_assy_item_name ;
        l_organization_code := l_org_code_to ;
        l_org_id :=  t_org_code_list(I);
        l_item_id := common_item_from;
      END IF ;

      /* If bill exists then check if in the org list if the existing bill is common or not .
        This can be done by comparing the current bill sequence id and common bill sequence id.
        If they are the same then should not commmon the Bill */

      if (l_bill_exists = 1 and (scope = 2 or scope = 3)) then
        SELECT common_bill_sequence_id, bill_sequence_id
                                INTO common_bill_seq_id, bill_seq_id
                          FROM BOM_STRUCTURES_B
                          WHERE ASSEMBLY_ITEM_ID = common_item_from
                            AND ORGANIZATION_ID = t_org_code_list(I)
                            AND NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(alternate,'NONE') ;

      elsif(l_bill_exists =1 and scope = 1) then
        SELECT common_bill_sequence_id, bill_sequence_id
                                INTO common_bill_seq_id, bill_seq_id
                          FROM BOM_STRUCTURES_B
                          WHERE ASSEMBLY_ITEM_ID = common_item_to
                            AND ORGANIZATION_ID =  common_org_to
                            AND NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(alternate,'NONE') ;
      End if;

      If (common_bill_seq_id = bill_seq_id) Then
        l_bill_exists := 0; -- Cannot delete as existing bill is not common
      End if;

      if (l_bill_exists = 1) then
        -- Create delete group records and then call the bom_delete-groups API
        -- that will delete the common bill record.

        If (((scope = 2 or scope = 3) and (t_org_code_list(I) <>  current_org_id))
        OR (scope = 1)) then
         SELECT BILL_SEQUENCE_ID
                                 INTO   l_bill_seq_id
                           FROM   BOM_STRUCTURES_B
                           WHERE  ASSEMBLY_ITEM_ID = l_item_id
                             AND    ORGANIZATION_ID =  l_org_id
                             AND    NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(alternate,'NONE') ;

         SELECT BOM_DELETE_GROUPS_S.NEXTVAL
         INTO   delete_group_id
           FROM   DUAL;

         SELECT BOM_DELETE_ENTITIES_S.NEXTVAL
         INTO   delete_entity_id
           FROM   dual;

         if (length(delete_group_id) > 7) Then
          del_group_name := substr(delete_group_id,length(delete_group_id) - 6,7);
         else
          del_group_name := delete_group_id;
         End if;

         INSERT INTO BOM_DELETE_GROUPS
                      (DELETE_GROUP_SEQUENCE_ID,
                      DELETE_GROUP_NAME,
          DELETE_ORG_TYPE,
                      ORGANIZATION_ID,
                      DELETE_TYPE,
                      ACTION_TYPE,
          DELETE_COMMON_BILL_FLAG,
                      ENGINEERING_FLAG,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY)
         VALUES
          (delete_group_id,
           l_organization_code||del_group_name,
           1,--bug:4201690 The delete group procedure should get executed for every org.
           t_org_code_list(I),
           2,
           1,
           2,
           l_assembly_type,
           SYSDATE,
           to_number(FND_PROFILE.Value('USER_ID')),
           SYSDATE,
           to_number(FND_PROFILE.Value('USER_ID')));


         INSERT INTO bom_delete_entities
                (DELETE_ENTITY_SEQUENCE_ID,
                 DELETE_GROUP_SEQUENCE_ID,
                 DELETE_ENTITY_TYPE,
           DELETE_STATUS_TYPE,
                 BILL_SEQUENCE_ID,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           ITEM_DESCRIPTION,
                 ALTERNATE_DESIGNATOR,
           ITEM_CONCAT_SEGMENTS,
                 PRIOR_PROCESS_FLAG,
                 PRIOR_COMMIT_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY)
         VALUES
           (delete_entity_id,
           delete_group_id,
           2,
           1,
           l_bill_seq_id,
           l_item_id,
           l_org_id,
           l_item_desc,
           nvl(alternate,NULL),
           l_assembly_item_name,
           1,
           1,
           SYSDATE,
           to_number(FND_PROFILE.Value('USER_ID')),
           SYSDATE,
           to_number(FND_PROFILE.Value('USER_ID')));

        Bom_Delete_Groups_Api.Delete_Groups
        (ERRBUF     => ERROR_MSG,
         RETCODE    => RETCOD,
         delete_group_id  => delete_group_id,
         action_type    => 2,
         delete_type    => 2,
         archive    => 2) ;

         --bug:5235742 Delete groups API will return 1 when one or more entities
         --can not be deleted.
         If ( ( RETCOD <> '0' ) AND ( RETCOD <> '1' ) ) Then
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'Existing Common Bill For Item ' || l_assembly_item_name|| ' in organization ' || l_organization_code || ' could not be deleted');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'') ;
          failure_counter := failure_counter + 1 ;
                            ROLLBACK ;
          to_proceed := 1;
        Else
          delete_error_rec := 0;
          Select count(*)
          into   delete_error_rec
          From   bom_delete_errors
          where  DELETE_ENTITY_SEQUENCE_ID = delete_entity_id;

          If (delete_error_rec = 0) then
            to_proceed := 2;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Existing Common Bill For Item ' || l_assembly_item_name|| ' in organization ' || l_organization_code || ' has been deleted succesfully');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'') ;
          Else
            to_proceed := 1;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Existing Common Bill For Item ' || l_assembly_item_name|| ' in organization ' || l_organization_code || ' could not be deleted because of delete constraints');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'') ;
                                          failure_counter := failure_counter + 1 ;
          End if;
        End if;
         END IF;
      END IF;
        if (to_proceed <> 1) then
      l_bom_header_rec.assembly_item_name :=  l_assembly_item_name ;
      l_bom_header_rec.organization_code := l_organization_code ;
      l_bom_header_rec.alternate_bom_code := alternate ;
      l_bom_header_rec.common_assembly_item_name := common_item_from_name ;
      l_bom_header_rec.common_organization_code := l_org_code;
      l_bom_header_rec.assembly_comment := NULL ;
      l_bom_header_rec.assembly_type := l_assembly_type ;
      l_bom_header_rec.transaction_type := 'CREATE' ;
      l_bom_header_rec.return_status := NULL ;
      l_bom_header_rec.attribute_category := NULL ;
      l_bom_header_rec.attribute1 := NULL ;
      l_bom_header_rec.attribute2 := NULL ;
      l_bom_header_rec.attribute3 := NULL ;
      l_bom_header_rec.attribute4 := NULL ;
      l_bom_header_rec.attribute5 := NULL ;
      l_bom_header_rec.attribute6 := NULL ;
      l_bom_header_rec.attribute7 := NULL ;
      l_bom_header_rec.attribute8 := NULL ;
      l_bom_header_rec.attribute9 := NULL ;
      l_bom_header_rec.attribute10 := NULL ;
      l_bom_header_rec.attribute11 := NULL ;
      l_bom_header_rec.attribute12 := NULL ;
      l_bom_header_rec.attribute13:= NULL ;
      l_bom_header_rec.attribute14:= NULL ;
      l_bom_header_rec.attribute15:= NULL ;
      l_bom_header_rec.original_system_reference := NULL ;
      l_bom_header_rec.delete_group_name := NULL ;
      l_bom_header_rec.DG_description := NULL ;
      --Common BOM enh
      l_bom_header_rec.enable_attrs_update := enable_attrs_update;

    /** Initialize the System Information **/
    FND_GLOBAL.apps_initialize
    (user_id=>FND_PROFILE.Value('USER_ID'),
     resp_id=>FND_PROFILE.Value('RESP_ID'),
     resp_appl_id=>FND_PROFILE.Value('RESP_APPL_ID'),
     security_group_id=>FND_PROFILE.Value('SECURITY_GROUP_ID')) ;

    /** Initialize the message list **/
      ERROR_HANDLER.INITIALIZE ;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling BOM_BO_PUB.PROCESS_BOM');

    /** Call the BOM Business Object **/
      BOM_BO_PUB.PROCESS_BOM
      (
      p_bo_identifier => 'BOM',
      p_api_version_number => 1.0,
      p_init_msg_list => FALSE,
      p_bom_header_rec => l_bom_header_rec,
      p_bom_revision_tbl => l_bom_revision_tbl,
      p_bom_component_tbl => l_bom_component_tbl,
      p_bom_ref_designator_tbl => l_bom_ref_designator_tbl,
      p_bom_sub_component_tbl => l_bom_sub_component_tbl,
      x_bom_header_rec => l_bom_header_rec,
      x_bom_revision_tbl => l_bom_revision_tbl,
      x_bom_component_tbl => l_bom_component_tbl,
      x_bom_ref_designator_tbl => l_bom_ref_designator_tbl,
      x_bom_sub_component_tbl => l_bom_sub_component_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      p_debug => 'N',
      p_output_dir => '/sqlcom/log/dom1151',
      p_debug_filename => 'BOM_BO_debug.log'
      ) ;

    IF (l_return_status = 'S') THEN
                   -- ERES change begins
                   Event_Acknowledgement
                     ( p_event_name   => 'oracle.apps.bom.billUpdate'
                     , p_event_key    => TO_CHAR( l_bill_sequence_id)
                     , p_event_status => 'SUCCESS');
                   -- ERES change ends

                   success_counter := success_counter + 1 ;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully commoned for organization : '||t_org_code_list(I)) ;
                   COMMIT ;
    ELSE
                   -- ERES change begins
                   Event_Acknowledgement
                     ( p_event_name   => 'oracle.apps.bom.billUpdate'
                     , p_event_key    => TO_CHAR( l_bill_sequence_id)
                     , p_event_status => 'FAILURE');
                   -- ERES change ends

                   failure_counter := failure_counter + 1 ;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Commoning errored for organization : '||t_org_code_list(I)) ;
      ROLLBACK ;
      ERROR_HANDLER.GET_MESSAGE_LIST(x_message_list=>l_error_tbl) ;
      FOR K in l_error_tbl.FIRST..l_error_tbl.LAST LOOP
                         FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
                         FND_FILE.PUT_LINE(FND_FILE.LOG,'entity_id : '||l_error_tbl(K).entity_id) ;
                         FND_FILE.PUT_LINE(FND_FILE.LOG,'message_text : '||l_error_tbl(K).message_text) ;
      END LOOP ;
    END IF ;
        END IF;
      ELSE
          FND_MESSAGE.SET_NAME('BOM','BOM_BILL_EXISTS');
              FND_MESSAGE.SET_TOKEN('ORG_CODE',t_org_code_list(I));
              msg := FND_MESSAGE.GET ;
              FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill already exists for organization '||t_org_code_list(I)) ;
      END IF ;
    ELSE
          FND_MESSAGE.SET_NAME('BOM','BOM_INVALID_ASSEMBLY');
              FND_MESSAGE.SET_TOKEN('ASSEMBLY_NAME',l_assy_item_name);
              FND_MESSAGE.SET_TOKEN('ORG_CODE',t_org_code_list(I));
              msg := FND_MESSAGE.GET ;
              FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
--         FND_FILE.PUT_LINE(FND_FILE.LOG,'Assembly item'||l_assy_item_name||'does not exists in organization'||t_org_code_list(I)) ;
    END IF ;
  END LOOP ;

      FND_MESSAGE.SET_NAME('BOM','BOM_COMMON_SUMMARY');
  FND_MESSAGE.SET_TOKEN('ENTITY1','SUCCEDED');
  FND_MESSAGE.SET_TOKEN('ENTITY2',success_counter);
      msg := FND_MESSAGE.GET ;
      FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;

      FND_MESSAGE.SET_NAME('BOM','BOM_COMMON_SUMMARY');
  FND_MESSAGE.SET_TOKEN('ENTITY1','FAILED');
  FND_MESSAGE.SET_TOKEN('ENTITY2',failure_counter);
      msg := FND_MESSAGE.GET ;
      FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;

/*
        FND_FILE.PUT_LINE(FND_FILE.LOG,'*************SUMMARY***************') ;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of organizations successfully commoned : '||success_counter) ;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of organizations for which commoning failed : '||failure_counter) ;

*/

        IF (failure_counter > 0) THEN
    RETCODE := 1 ;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);
        ELSE
    RETCODE := 0 ;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
  END IF ;

/* Added for bug 11895331. If Common BOM process completed successfully, updating
   the request_id column to original value. */
  Update_BSB_Request_Id_Column( p_request_id        => p_orig_request_id,
                                p_organization_id   => current_org_id,
                                p_assembly_item_id  => common_item_from,
                                p_alternate         => alternate,
                                p_sequence_num      => 1,
                                p_commit            => FND_API.G_TRUE);

EXCEPTION
 WHEN Hierarchy_not_specified THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_HIERARCHY_MISSING');
    msg := FND_MESSAGE.GET ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Hierarchy Name must be specified') ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
    -- Added for bug 11895331. If Common BOM process raises any exception, updating the request_id column to original value.
    Update_BSB_Request_Id_Column( p_request_id        => p_orig_request_id,
                                  p_organization_id   => current_org_id,
                                  p_assembly_item_id  => common_item_from,
                                  p_alternate         => alternate,
                                  p_sequence_num      => 2,
                                  p_commit            => FND_API.G_TRUE);

 WHEN invalid_common_itemorg_to THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_COMMON_ITEM_ORG_INVALID');
    msg := FND_MESSAGE.GET ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Either common item to or common org to is not specified') ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
    -- Added for bug 11895331. If Common BOM process raises any exception, updating the request_id column to original value.
    Update_BSB_Request_Id_Column( p_request_id        => p_orig_request_id,
                                  p_organization_id   => current_org_id,
                                  p_assembly_item_id  => common_item_from,
                                  p_alternate         => alternate,
                                  p_sequence_num      => 3,
                                  p_commit            => FND_API.G_TRUE);

 WHEN same_common_itemorg_to THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_TO_ORG_ITEM_SAME');
    msg := FND_MESSAGE.GET ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'For Single Organization Scope, both TO org and item cannot be same as From org and item') ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
    -- Added for bug 11895331. If Common BOM process raises any exception, updating the request_id column to original value.
    Update_BSB_Request_Id_Column( p_request_id        => p_orig_request_id,
                                  p_organization_id   => current_org_id,
                                  p_assembly_item_id  => common_item_from,
                                  p_alternate         => alternate,
                                  p_sequence_num      => 4,
                                  p_commit            => FND_API.G_TRUE);


 /* Added for bug 11895331, if eco_implmentation_is_running is raised then errored out the process with appropriate message. */
 WHEN eco_implmentation_is_running THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_ECO_IMPL_INPROGRESS');
    msg := FND_MESSAGE.GET ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,msg) ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Others '||SQLCODE || ':'||SQLERRM) ;
   RETCODE := 2;
   conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
    -- Added for bug 11895331. If Common BOM process raises any exception, updating the request_id column to original value.
    Update_BSB_Request_Id_Column( p_request_id        => p_orig_request_id,
                                  p_organization_id   => current_org_id,
                                  p_assembly_item_id  => common_item_from,
                                  p_alternate         => alternate,
                                  p_sequence_num      => 5,
                                  p_commit            => FND_API.G_TRUE);


END create_common_bills;

/*
 * This Procedure will modify the bill header attributes of a common BOM to make it updateable.
 * @param p_bill_sequence_id IN Bill Sequence Id of the common BOM
 */
PROCEDURE Dereference_Header(p_bill_sequence_id NUMBER)
IS
BEGIN
  Update BOM_STRUCTURES_B
  Set source_bill_sequence_id = common_bill_Sequence_id,
      common_bill_sequence_id = bill_sequence_id
  Where bill_sequence_id = p_bill_sequence_id;
END;

/*
 * Function to return the nextval from Bom_Inventory_Components_S
 */
FUNCTION Get_Component_Sequence
   RETURN NUMBER
  IS
   CURSOR Comp_Seq IS
  SELECT Bom_Inventory_Components_S.NEXTVAL Component_Sequence
  FROM SYS.DUAL;
   BEGIN
  FOR c_Comp_Seq IN Comp_Seq LOOP
    RETURN c_Comp_Seq.Component_Sequence;
  END LOOP ;
  RETURN NULL;
   END Get_Component_Sequence;


/*
 * This Procedure is used to resolve the old comp attrs while propagating changes to dest bills
 * @param p_dest_bill_seq_id IN Bill Sequence Id of the dest component.
 * @param p_orig_old_comp_seq IN old comp seq id in the source bill
 */
Procedure Resolve_Old_Comp_Attrs(p_dest_bill_seq_id IN NUMBER
                               , p_orig_old_comp_seq IN NUMBER
                               , x_old_comp_seq_id IN OUT NOCOPY NUMBER
                               , x_wip_supply_type IN OUT NOCOPY NUMBER
                               , x_wip_supply_subinv IN OUT NOCOPY VARCHAR2
                               , x_wip_supply_locator_id IN OUT NOCOPY NUMBER
                               , x_inc_in_cost_rollup IN OUT NOCOPY NUMBER
                               , x_op_seq IN OUT NOCOPY NUMBER)
IS
  l_impl_date DATE;
  l_old_comp_seq NUMBER;
  b_impl_date DATE ; --Bug 9238945
  l_comp_seq_id NUMBER; --Bug 9238945
  old_comp_seq NUMBER;
  l_count NUMBER;
  l_old_count NUMBER;
BEGIN

  IF p_orig_old_comp_seq is null
  THEN
    RETURN;
  END IF;

  SELECT implementation_date
  INTO l_impl_date
  FROM BOM_COMPONENTS_B
  WHERE component_sequence_id = p_orig_old_comp_seq;
  --bug 9238945 changes begin
  --if parent records is unimplemented, so would be the child one.
  --infact there could be multiple umimplemented ecos on the child bill but corresponds to the same common_component_sequence_id
  --pick up the last one in the series, determined by the highest component_sequence_id
  if l_impl_date is null then
      select max(component_sequence_id) into l_comp_seq_id from BOM_COMPONENTS_B bic
      WHERE bic.bill_sequence_id = p_dest_bill_seq_id
      AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq
      AND bic.implementation_date is null;
  else

      select count(*) into l_count from BOM_COMPONENTS_B bic
      WHERE bic.bill_sequence_id = p_dest_bill_seq_id
      AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq;

      if l_count = 1 then
      select component_sequence_id into l_comp_seq_id from BOM_COMPONENTS_B bic
      WHERE bic.bill_sequence_id = p_dest_bill_seq_id
      AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq;
      else
      --last record in the line of changes
        select max(old_component_sequence_id) into old_comp_seq from BOM_COMPONENTS_B bic
        WHERE bic.bill_sequence_id = p_dest_bill_seq_id
        AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq;

        --if there are only 2 ecos one to create the component and another to change it, for example(both would have
        --same old_component_sequence_id). In that case need to pick up the record with max
        --component_sequence_id among these 2 records

        select count(*) into l_old_count from BOM_COMPONENTS_B bic
        WHERE bic.bill_sequence_id = p_dest_bill_seq_id
        AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq
        and bic.old_component_sequence_id = old_comp_seq;

        if l_old_count = 1 then
          select component_sequence_id into l_comp_seq_id from BOM_COMPONENTS_B bic
          WHERE bic.bill_sequence_id = p_dest_bill_seq_id
          AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq
          and bic.old_component_sequence_id = old_comp_seq;
        else
          select max(component_sequence_id) into l_comp_seq_id from BOM_COMPONENTS_B bic
          WHERE bic.bill_sequence_id = p_dest_bill_seq_id
          AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq
          and bic.old_component_sequence_id = old_comp_seq;
        end if;
      end if;

  end if;

  SELECT component_sequence_id,  wip_supply_type, supply_subinventory, supply_locator_id, include_in_cost_rollup, operation_seq_num
  INTO x_old_comp_seq_id, x_wip_supply_type, x_wip_supply_subinv, x_wip_supply_locator_id, x_inc_in_cost_rollup, x_op_seq
  FROM BOM_COMPONENTS_B bic
  WHERE bic.component_sequence_id = l_comp_seq_id;
 --bug 9238945 changes end

  /* SELECT component_sequence_id,  wip_supply_type, supply_subinventory, supply_locator_id, include_in_cost_rollup, operation_seq_num
  INTO x_old_comp_seq_id, x_wip_supply_type, x_wip_supply_subinv, x_wip_supply_locator_id, x_inc_in_cost_rollup, x_op_seq
  FROM BOM_COMPONENTS_B bic
  WHERE bic.bill_sequence_id = p_dest_bill_seq_id
  AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_orig_old_comp_seq --bic.old_component_sequence_id
  AND (
        (bic.implementation_date is not null
          AND l_impl_date is not null
          /*
           *commented by jewen on 2008-11-6 to fix bug 7487640
          AND sysdate between bic.effectivity_date and nvl (bic.disable_date, sysdate + 1)
          */ /*
        )
        OR
        (l_impl_date is null
          and bic.implementation_date is null
        )
      ); */

END;



PROCEDURE check_comp_fixed_rev_dtls(p_src_bill_seq_id IN NUMBER
                                  , p_src_comp_seq_id IN NUMBER
                                  , x_return_status OUT NOCOPY VARCHAR2)
IS
  Cursor get_common_orgs(p_bill_seq_id NUMBER)
  IS
  SELECT distinct organization_id
  FROM BOM_STRUCTURES_B
  WHERE source_bill_sequence_id = p_bill_seq_id;

  l_comp_rev_id NUMBER;

BEGIN
  SELECT component_item_revision_id
  INTO l_comp_rev_id
  FROM bom_components_b
  WHERE component_sequence_id = p_src_comp_seq_id;

  IF l_comp_rev_id IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  FOR org in get_common_orgs(p_src_bill_seq_id)
  LOOP
    IF get_rev_id_for_local_org(l_comp_rev_id, org.organization_id) IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;



/*
 * This Procedure will replicate the components of the source BOM as components of the Common BOM.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source BOM
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the common BOM
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Replicate_Components (p_src_bill_sequence_id IN NUMBER
                                , p_dest_bill_sequence_id IN NUMBER
                                , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS
  Cursor get_source_components(p_bill_sequence_id Number)
  IS
  SELECT *
  from BOM_COMPONENTS_B
  where bill_sequence_id = p_bill_sequence_id;

  Cursor get_structure_type(p_bill_seq_id NUMBER)
  IS
  SELECT structure_type_id
  from BOM_STRUCTURES_B
  where bill_sequence_id = p_bill_seq_id;
  default_wip_params NUMBER;

  Cursor get_dest_components(p_src_comp_seq_id IN NUMBER, p_dest_bill_sequence_id IN NUMBER)
  IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  and component_sequence_id <> common_component_sequence_id
  AND bill_sequence_id = p_dest_bill_sequence_id;

  l_wip_supply_type number := null;
  l_locator_id number := null;
  l_supply_subinventory varchar2(10) := null;
  l_dest_org_id  number;
  l_src_comp_seq_id NUMBER;
  l_err_text    VARCHAR2(2000);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_src_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_str_type EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_str_type          NUMBER;
  l_errorcode     NUMBER;
  l_msg_data        VARCHAR2(100);
  l_msg_count          NUMBER      :=  0;
  l_src_str_type NUMBER;
  l_assy_item_id NUMBER;
  l_alt_bom_desg varchar2(10);
  l_effectivity_ctrl NUMBER;
  l_token_table Error_Handler.Token_Tbl_Type;

  l_pend_supply_type NUMBER;
  l_pend_supply_subinv VARCHAR2 (10);
  l_pend_supply_locator_id NUMBER;
  l_pend_inc_in_cost_rollup NUMBER;
  l_pend_op_seq NUMBER;

BEGIN

  FND_PROFILE.GET('BOM:DEFAULT_WIP_VALUES', default_wip_params);
  --arudresh_debug('BOM:DEFAULT_WIP_VALUES'|| default_wip_params);
  SELECT assembly_item_id, organization_id, alternate_bom_designator, effectivity_control
  into l_assy_item_id, l_dest_org_id, l_alt_bom_desg, l_effectivity_ctrl
  from BOM_STRUCTURES_B
  where bill_sequence_id = p_dest_bill_sequence_id;

  IF l_effectivity_ctrl in (2,3,4)
  THEN
    x_Return_Status := FND_API.G_RET_STS_ERROR;
--arudresh_debug('adding error token');
    Error_Handler.Add_Error_Token
    (p_Message_Name => 'BOM_EDIT_COMM_INVALID_EFF'
   --  , p_Message_Text => NULL
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     , x_Mesg_Token_Tbl => l_mesg_token_tbl
     , p_Token_Tbl => l_token_table
    );
    fnd_message.set_name('BOM', 'BOM_EDIT_COMM_INVALID_EFF');
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
    /*Error_Handler.Log_Error
    (p_error_status => FND_API.G_RET_STS_ERROR
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     , p_error_scope     => Error_Handler.G_SCOPE_RECORD
     ,  p_error_level    => Error_Handler.G_BH_LEVEL
     , x_bom_header_rec  => Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
     , x_bom_revision_tbl => Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
     , x_bom_component_tbl  => Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
     , x_bom_ref_Designator_tbl => Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
     , x_bom_sub_component_tbl  => Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
    );*/
--arudresh_debug('added error token');
     fnd_message.set_name('BOM', 'BOM_EDIT_COMM_INVALID_EFF');
    return;
  END IF;

  Validate_Operation_Sequence_Id(p_src_bill_sequence_id => p_src_bill_sequence_id
                                         , p_assembly_item_id => l_assy_item_id
                                         , p_organization_id => l_dest_org_id
                                         , p_alt_desg => l_alt_bom_desg
                                         , x_Return_Status => x_Return_Status);
  IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    fnd_message.set_name('BOM', 'BOM_COMM_OP_SEQ_INVALID');
    return;
  END IF;

--  FORALL comp_rec in get_source_components(p_src_bill_sequence_id)
  --loop
    /*l_src_comp_seq_id := comp_rec.component_sequence_id;
    comp_rec.common_component_sequence_id := comp_rec.component_sequence_id;
    comp_rec.bill_sequence_id := p_dest_bill_sequence_id;
    comp_rec.component_sequence_id := Get_Component_Sequence;*/
    --comp_rec.organization_id := l_dest_org_id;

       /*if default_wip_params = 'Y'
       then
         SELECT ITM.WIP_SUPPLY_TYPE, ITM.WIP_SUPPLY_LOCATOR_ID, ITM.WIP_SUPPLY_SUBINVENTORY
         --INTO l_wip_supply_type, l_locator_id, l_supply_subinventory
         FROM MTL_SYSTEM_ITEMS_B ITM
         WHERE inventory_item_id = comp_rec.component_item_id
         AND organization_id = l_dest_org_id;
         comp_rec.supply_locator_id := l_locator_id;
         comp_rec.wip_supply_type := l_wip_supply_type;
         comp_rec.supply_subinventory := l_supply_subinventory;
       else
         comp_rec.supply_locator_id := null;
         --comp_rec.wip_supply_type := null;
         --Cant create a record with null wip_supply_type
         comp_rec.supply_subinventory := null;
       end if;*/
       /*insert into BOM_COMPONENTS_B(<col list>)
       values(<comp_rec>);*/
      INSERT  INTO BOM_COMPONENTS_B
      (       SUPPLY_SUBINVENTORY
      ,       OPERATION_LEAD_TIME_PERCENT
      ,       REVISED_ITEM_SEQUENCE_ID
      ,       COST_FACTOR
      ,       REQUIRED_FOR_REVENUE
      ,       HIGH_QUANTITY
      ,       COMPONENT_SEQUENCE_ID
      ,       PROGRAM_APPLICATION_ID
      ,       WIP_SUPPLY_TYPE
      ,       SUPPLY_LOCATOR_ID
      ,       BOM_ITEM_TYPE
      ,       OPERATION_SEQ_NUM
      ,       COMPONENT_ITEM_ID
      ,       LAST_UPDATE_DATE
      ,       LAST_UPDATED_BY
      ,       CREATION_DATE
      ,       CREATED_BY
      ,       LAST_UPDATE_LOGIN
      ,       ITEM_NUM
      ,       COMPONENT_QUANTITY
      ,       COMPONENT_YIELD_FACTOR
      ,       COMPONENT_REMARKS
      ,       EFFECTIVITY_DATE
      ,       CHANGE_NOTICE
      ,       IMPLEMENTATION_DATE
      ,       DISABLE_DATE
      ,       ATTRIBUTE_CATEGORY
      ,       ATTRIBUTE1
      ,       ATTRIBUTE2
      ,       ATTRIBUTE3
      ,       ATTRIBUTE4
      ,       ATTRIBUTE5
      ,       ATTRIBUTE6
      ,       ATTRIBUTE7
      ,       ATTRIBUTE8
      ,       ATTRIBUTE9
      ,       ATTRIBUTE10
      ,       ATTRIBUTE11
      ,       ATTRIBUTE12
      ,       ATTRIBUTE13
      ,       ATTRIBUTE14
      ,       ATTRIBUTE15
      ,       PLANNING_FACTOR
      ,       QUANTITY_RELATED
      ,       SO_BASIS
      ,       OPTIONAL
      ,       MUTUALLY_EXCLUSIVE_OPTIONS
      ,       INCLUDE_IN_COST_ROLLUP
      ,       CHECK_ATP
      ,       SHIPPING_ALLOWED
      ,       REQUIRED_TO_SHIP
      ,       INCLUDE_ON_SHIP_DOCS
      ,       INCLUDE_ON_BILL_DOCS
      ,       LOW_QUANTITY
      ,       ACD_TYPE
      ,       OLD_COMPONENT_SEQUENCE_ID
      ,       BILL_SEQUENCE_ID
      ,       REQUEST_ID
      ,       PROGRAM_ID
      ,       PROGRAM_UPDATE_DATE
      ,       PICK_COMPONENTS
      ,       Original_System_Reference
      ,       From_End_Item_Unit_Number
      ,       To_End_Item_Unit_Number
      ,       Eco_For_Production -- Added by MK
      ,       Enforce_Int_Requirements
      ,     Auto_Request_Material -- Added in 11.5.9 by ADEY
      ,       Obj_Name -- Added by hgelli.
      ,       pk1_value
      ,       pk2_value
      ,     Suggested_Vendor_Name --- Deepu
      ,     Vendor_Id --- Deepu
      ,     Unit_Price --- Deepu
      ,from_object_revision_id
      , from_minor_revision_id
      , common_component_sequence_id
      , basis_type
      , component_item_revision_id
      )
     SELECT decode(default_wip_params, 1, item.wip_supply_subinventory, null)
      , comp_rec.OPERATION_LEAD_TIME_PERCENT
      , comp_rec.REVISED_ITEM_SEQUENCE_ID
      , comp_rec.COST_FACTOR
      , comp_rec.REQUIRED_FOR_REVENUE
      , comp_rec.HIGH_QUANTITY
      , Bom_Inventory_Components_S.NEXTVAL
      , who_program_application_id   -- Modified for bug 16813763
      --, decode(default_wip_params, 1, item.WIP_SUPPLY_TYPE, null)--supply type can be null --commented out for 9438586
      , decode(default_wip_params, 1, item.WIP_SUPPLY_TYPE, comp_rec.WIP_SUPPLY_TYPE) --changes made for bug 9438586
      , decode(default_wip_params, 1, item.WIP_SUPPLY_LOCATOR_ID, null)
      , comp_rec.BOM_ITEM_TYPE
      , comp_rec.OPERATION_SEQ_NUM
      , comp_rec.COMPONENT_ITEM_ID
      , who_creation_date            -- Modified for bug 16813763
      , who_user_id                  -- Modified for bug 16813763
      , who_creation_date            -- Modified for bug 16813763
      , who_user_id                  -- Modified for bug 16813763
      , who_login_id                 -- Modified for bug 16813763
      , comp_rec.ITEM_NUM
      , comp_rec.COMPONENT_QUANTITY
      , comp_rec.COMPONENT_YIELD_FACTOR
      , comp_rec.COMPONENT_REMARKS
      , comp_rec.EFFECTIVITY_DATE
      , comp_rec.CHANGE_NOTICE
      , comp_rec.IMPLEMENTATION_DATE
      , comp_rec.DISABLE_DATE
      , comp_rec.ATTRIBUTE_CATEGORY
      , comp_rec.ATTRIBUTE1
      , comp_rec.ATTRIBUTE2
      , comp_rec.ATTRIBUTE3
      , comp_rec.ATTRIBUTE4
      , comp_rec.ATTRIBUTE5
      , comp_rec.ATTRIBUTE6
      , comp_rec.ATTRIBUTE7
      , comp_rec.ATTRIBUTE8
      , comp_rec.ATTRIBUTE9
      , comp_rec.ATTRIBUTE10
      , comp_rec.ATTRIBUTE11
      , comp_rec.ATTRIBUTE12
      , comp_rec.ATTRIBUTE13
      , comp_rec.ATTRIBUTE14
      , comp_rec.ATTRIBUTE15
      , comp_rec.PLANNING_FACTOR
      , comp_rec.QUANTITY_RELATED
      , comp_rec.SO_BASIS
      , comp_rec.OPTIONAL
      , comp_rec.MUTUALLY_EXCLUSIVE_OPTIONS
      , comp_rec.INCLUDE_IN_COST_ROLLUP
      , comp_rec.CHECK_ATP
      , comp_rec.SHIPPING_ALLOWED
      , comp_rec.REQUIRED_TO_SHIP
      , comp_rec.INCLUDE_ON_SHIP_DOCS
      , comp_rec.INCLUDE_ON_BILL_DOCS
      , comp_rec.LOW_QUANTITY
      , comp_rec.ACD_TYPE
      , comp_rec.OLD_COMPONENT_SEQUENCE_ID
      , p_dest_bill_sequence_id
      , who_request_id               -- Modified for bug 16813763
      , who_program_id               -- Modified for bug 16813763
      , who_creation_date            -- Modified for bug 16813763
      , comp_rec.PICK_COMPONENTS
      , comp_rec.Original_System_Reference
      , comp_rec.From_End_Item_Unit_Number
      , comp_rec.To_End_Item_Unit_Number
      , comp_rec.Eco_For_Production -- Added by MK
      , comp_rec.Enforce_Int_Requirements
      , comp_rec.Auto_Request_Material -- Added in 11.5.9 by ADEY
      , comp_rec.Obj_Name -- Added by hgelli.
      , comp_rec.pk1_value
      , l_dest_org_id
      , comp_rec.Suggested_Vendor_Name --- Deepu
      , comp_rec.Vendor_Id --- Deepu
      , comp_rec.Unit_Price --- Deepu
      , comp_rec.from_object_revision_id
      , comp_rec.from_minor_revision_id
      , comp_rec.component_sequence_id
      , comp_rec.basis_type
      , decode(comp_rec.component_item_revision_id, null, null, BOMPCMBM.get_rev_id_for_local_org(comp_rec.component_item_revision_id, l_dest_org_id))
      FROM BOM_COMPONENTS_B comp_rec, MTL_SYSTEM_ITEMS_B item, BOM_STRUCTURES_B bom
      WHERE comp_rec.bill_sequence_id = p_src_bill_sequence_id
      AND bom.bill_sequence_id = comp_rec.bill_sequence_id
      AND comp_rec.COMPONENT_ITEM_ID = item.inventory_item_id
      AND item.organization_id = l_dest_org_id
      --and comp_rec.implementation_date is not null
      ;

      --Now update all the change rows(pending/implemented) to refer the replicated component rows.



      --Replicate Structure User Attribute Values
      Open get_structure_type(p_bill_seq_id => p_dest_bill_sequence_id);
      Fetch get_structure_type into l_str_type;
      Close get_structure_type;

      Open get_structure_type(p_bill_seq_id => p_src_bill_sequence_id);
      Fetch get_structure_type into l_src_str_type;
      Close get_structure_type;

      --Copy user attrs only if the str type is same
      IF l_src_str_type = l_str_type
      THEN
        /*l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID',to_char(p_src_bill_sequence_id)));
        l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID',to_char(p_dest_bill_sequence_id)));
        l_new_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('STRUCTURE_TYPE_ID',TO_CHAR(l_str_type)));
         EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data(
         p_api_version                   =>1.0
        ,p_application_id                =>702
        ,p_object_name                   =>'BOM_STRUCTURE'
        ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
        ,p_new_pk_col_value_pairs      =>  l_dest_pk_col_name_val_pairs
        ,p_new_cc_col_value_pairs      => l_new_str_type
        ,x_return_status                 => x_Return_Status
        ,x_errorcode                     => l_errorcode
        ,x_msg_count                     => l_msg_count
        ,x_msg_data                      => l_msg_data
        );*/
        --DOnt copy the structure header user attrs
        Replicate_Comp_User_Attrs(p_src_bill_seq_id => p_src_bill_sequence_id,
                                  p_dest_bill_seq_id => p_dest_bill_sequence_id,
                                  x_Return_Status => x_Return_Status);
        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
          return;
        END IF;
      END IF; /*IF l_src_str_type = l_str_type*/


--start another loop here
      FOR comp_rec in get_source_components(p_src_bill_sequence_id)
      loop
        IF comp_rec.change_notice is not null
        THEN
          FOR destn_comp in get_dest_components(comp_rec.component_sequence_id, p_dest_bill_sequence_id)
          loop
            Resolve_Old_Comp_Attrs(p_dest_bill_seq_id => destn_comp.bill_sequence_id
                               , p_orig_old_comp_seq => destn_comp.old_component_sequence_id
                               , x_old_comp_seq_id => destn_comp.old_component_sequence_id
                               , x_wip_supply_type => destn_comp.wip_supply_type
                               , x_wip_supply_subinv => destn_comp.supply_subinventory
                               , x_wip_supply_locator_id => destn_comp.supply_locator_id
                               , x_inc_in_cost_rollup => destn_comp.include_in_cost_rollup
                               , x_op_seq => destn_comp.operation_seq_num);
            UPDATE BOM_COMPONENTS_B
            SET old_component_sequence_id = destn_comp.old_component_sequence_id,
               wip_supply_type = destn_comp.wip_supply_type,
               supply_subinventory = destn_comp.supply_subinventory,
               supply_locator_id = destn_comp.supply_locator_id,
               include_in_cost_rollup = destn_comp.include_in_cost_rollup,
               operation_seq_num = destn_comp.operation_seq_num
            WHERE component_sequence_id = destn_comp.component_sequence_id;
          end loop;
        END IF;
        Replicate_Ref_Desg(p_component_sequence_id => comp_rec.component_sequence_id
                             , x_Mesg_Token_Tbl =>  x_Mesg_Token_Tbl
                             , x_Return_Status => x_Return_Status);
        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
          return;
        END IF;
        Replicate_Sub_Comp(p_component_sequence_id => comp_rec.component_sequence_id
                             , x_Mesg_Token_Tbl =>  x_Mesg_Token_Tbl
                             , x_Return_Status => x_Return_Status);
        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
          return;
        END IF;
          Replicate_Comp_Ops(p_component_sequence_id => comp_rec.component_sequence_id
                               , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                               , x_Return_Status  => x_Return_Status);

        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
          return;
        END IF;

     end loop; /*FOR comp_rec in get_source_components(p_src_bill_sequence_id) */
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN
      IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected Error occured in Insert . . .' || SQLERRM); END IF;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||' : Utility (Component Replicate) '
                                 || SUBSTR(SQLERRM, 1, 200);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_Text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      END IF;
      --arudresh_debug('Error in replicate component'||SQLERRM);
      fnd_message.set_name('BOM', 'BOM_REPLICATE_FAILED');
      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Replicate_Components;


/*
 * This Procedure will replicate the components of the source BOM as components of the Common BOM.
 * Overloaded to be called from JBO.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source BOM
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the common BOM
 */
PROCEDURE Replicate_Components (p_src_bill_sequence_id IN NUMBER
                                , p_dest_bill_sequence_id IN NUMBER)
IS
l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_Return_Status   VARCHAR2(1);
BEGIN
  Replicate_Components (p_src_bill_sequence_id => p_src_bill_sequence_id
                        , p_dest_bill_sequence_id => p_dest_bill_sequence_id
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END Replicate_Components;

/*
 * This Procedure should be called when a component is added to a bom that is commoned by other boms.
 * This will add the component to the common boms.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source BOM
 * @param p_src_comp_seq_id IN Component Sequence Id of the component added
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Insert_Related_Components
( p_src_bill_seq_id   IN NUMBER
, p_src_comp_seq_id   IN NUMBER
, x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status   IN OUT NOCOPY VARCHAR2
)
IS
  Cursor get_related_bills(p_src_bill_sequence_id NUMBER) IS
  Select *
  from BOM_STRUCTURES_B
  where source_bill_sequence_id <> common_bill_sequence_id
  and source_bill_sequence_id = p_src_bill_sequence_id;

  Cursor get_src_comp_details(p_src_comp_seq_id NUMBER) IS
  Select *
  From BOM_COMPONENTS_B
  where component_sequence_id = p_src_comp_seq_id;

  l_err_text    VARCHAR2(2000);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Bo_Id     VARCHAR2(3);

  l_old_component_sequence_id NUMBER;    -- Bug 2820641
  default_wip_params NUMBER;

  l_object_revision_id NUMBER;
  l_minor_revision_id NUMBER;
  l_comp_revision_id NUMBER;
  l_comp_minor_revision_id NUMBER;
  l_operation_leadtime  NUMBER := NULL;
  l_operation_seq_num  NUMBER;

  l_wip_supply_type number := null;
  l_locator_id number := null;
  l_supply_subinventory varchar2(10) := null;
  l_dest_org_id  number;

  --l_comp_name VARCHAR2(80);
  l_dest_assy_item VARCHAR2(80);
  l_dest_org_code VARCHAR2(3);
  l_token_tbl   Error_Handler.Token_Tbl_Type;

  l_pend_supply_type NUMBER;
  l_pend_supply_subinv VARCHAR2 (10);
  l_pend_supply_locator_id NUMBER;
  l_pend_inc_in_cost_rollup NUMBER;
  l_pend_op_seq NUMBER;

  l_dummy VARCHAR2(10);
  l_comp_name MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;

BEGIN

    l_Bo_Id := Bom_Globals.Get_Bo_Identifier;
    FND_PROFILE.GET('BOM:DEFAULT_WIP_VALUES', default_wip_params);

    SELECT operation_seq_num
    INTO l_operation_seq_num
    FROM BOM_COMPONENTS_B
    WHERE component_Sequence_id = p_src_comp_seq_id;

    Check_Comp_Fixed_Rev_Dtls(p_src_bill_seq_id => p_src_bill_seq_id
                              , p_src_comp_seq_id => p_src_comp_seq_id
                              , x_return_status => x_return_status);

    IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
    THEN

        SELECT concatenated_segments
        into l_comp_name
        from mtl_system_items_kfv item, bom_components_b comp
        where item.inventory_item_id = comp.pk1_value
        and item.organization_id = comp.pk2_value
        and comp.component_sequence_id = p_src_comp_seq_id;

       l_token_tbl.DELETE;
       l_token_tbl(1).token_name  := 'COMP_NAME';
       l_token_tbl(1).token_value := l_comp_name;

        Error_Handler.Add_Error_Token
        (  p_Message_Name   => 'BOM_FIXED_REV_NOT_ALLOWED'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_Token_Tbl      => l_token_tbl
                            );
         x_Return_Status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('BOM', 'BOM_FIXED_REV_NOT_ALLOWED');
         RETURN;

    END IF;

    IF NOT BOMPCMBM.Check_Op_Seq_In_Ref_Boms(p_src_bill_seq_id => p_src_bill_seq_id
                                            , p_op_seq => l_operation_seq_num)
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name   => 'BOM_COMMON_OP_SEQ_INVALID'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_Token_Tbl      => l_token_tbl
                            );
         x_Return_Status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('BOM', 'BOM_COMMON_OP_SEQ_INVALID');
         RETURN;
    END IF;

    for bill_rec in get_related_bills(p_src_bill_seq_id)
    loop
      l_dest_org_id := bill_rec.organization_id;
      for src_comp_details in get_src_comp_details(p_src_comp_seq_id)
      loop
        if default_wip_params = 1
        then
         SELECT WIP_SUPPLY_TYPE, WIP_SUPPLY_LOCATOR_ID, WIP_SUPPLY_SUBINVENTORY
         INTO l_wip_supply_type, l_locator_id, l_supply_subinventory
         FROM MTL_SYSTEM_ITEMS_B
         WHERE inventory_item_id = src_comp_details.component_item_id
         AND organization_id = bill_rec.organization_id;
         src_comp_details.supply_locator_id := l_locator_id;
         src_comp_details.wip_supply_type := l_wip_supply_type;
         src_comp_details.supply_subinventory := l_supply_subinventory;
        else
          --dbms_output.put_line(' insert related comps :: in else of default wip params');
          src_comp_details.supply_locator_id := null;
          src_comp_details.supply_subinventory := null;
        end if; --if default_wip_params = 1
        --dbms_output.put_line(' insert related comps :: after end if ');
        src_comp_details.bill_sequence_id := bill_rec.bill_sequence_id;
        src_comp_details.common_component_sequence_id := src_comp_details.component_sequence_id;
        src_comp_details.component_sequence_id := get_component_sequence;

       --Set the old_component_sequence ids, if any, to refer to comps in the same bill instead of source bill.

        INSERT  INTO BOM_COMPONENTS_B
        (       SUPPLY_SUBINVENTORY
        ,       OPERATION_LEAD_TIME_PERCENT
        ,       REVISED_ITEM_SEQUENCE_ID
        ,       COST_FACTOR
        ,       REQUIRED_FOR_REVENUE
        ,       HIGH_QUANTITY
        ,       COMPONENT_SEQUENCE_ID
        ,       PROGRAM_APPLICATION_ID
        ,       WIP_SUPPLY_TYPE
        ,       SUPPLY_LOCATOR_ID
        ,       BOM_ITEM_TYPE
        ,       OPERATION_SEQ_NUM
        ,       COMPONENT_ITEM_ID
        ,       LAST_UPDATE_DATE
        ,       LAST_UPDATED_BY
        ,       CREATION_DATE
        ,       CREATED_BY
        ,       LAST_UPDATE_LOGIN
        ,       ITEM_NUM
        ,       COMPONENT_QUANTITY
        ,       COMPONENT_YIELD_FACTOR
        ,       COMPONENT_REMARKS
        ,       EFFECTIVITY_DATE
        ,       CHANGE_NOTICE
        ,       IMPLEMENTATION_DATE
        ,       DISABLE_DATE
        ,       ATTRIBUTE_CATEGORY
        ,       ATTRIBUTE1
        ,       ATTRIBUTE2
        ,       ATTRIBUTE3
        ,       ATTRIBUTE4
        ,       ATTRIBUTE5
        ,       ATTRIBUTE6
        ,       ATTRIBUTE7
        ,       ATTRIBUTE8
        ,       ATTRIBUTE9
        ,       ATTRIBUTE10
        ,       ATTRIBUTE11
        ,       ATTRIBUTE12
        ,       ATTRIBUTE13
        ,       ATTRIBUTE14
        ,       ATTRIBUTE15
        ,       PLANNING_FACTOR
        ,       QUANTITY_RELATED
        ,       SO_BASIS
        ,       OPTIONAL
        ,       MUTUALLY_EXCLUSIVE_OPTIONS
        ,       INCLUDE_IN_COST_ROLLUP
        ,       CHECK_ATP
        ,       SHIPPING_ALLOWED
        ,       REQUIRED_TO_SHIP
        ,       INCLUDE_ON_SHIP_DOCS
        ,       INCLUDE_ON_BILL_DOCS
        ,       LOW_QUANTITY
        ,       ACD_TYPE
        ,       OLD_COMPONENT_SEQUENCE_ID
        ,       BILL_SEQUENCE_ID
        ,       REQUEST_ID
        ,       PROGRAM_ID
        ,       PROGRAM_UPDATE_DATE
        ,       PICK_COMPONENTS
        ,       Original_System_Reference
        ,       From_End_Item_Unit_Number
        ,       To_End_Item_Unit_Number
        ,       Eco_For_Production -- Added by MK
        ,       Enforce_Int_Requirements
        ,     Auto_Request_Material -- Added in 11.5.9 by ADEY
        ,       Obj_Name -- Added by hgelli.
        ,       pk1_value
        ,       pk2_value
        ,     Suggested_Vendor_Name --- Deepu
        ,     Vendor_Id --- Deepu
    --    ,     Purchasing_Category_id --- Deepu
        ,     Unit_Price --- Deepu
        ,from_object_revision_id
        , from_minor_revision_id
        --,component_item_revision_id
        --,component_minor_revision_id
        , common_component_sequence_id
        , basis_type
        , component_item_revision_id
        )
        VALUES
        (       src_comp_details.supply_subinventory
        ,       src_comp_details.OPERATION_LEAD_TIME_PERCENT  --check this
        ,       src_comp_details.revised_item_sequence_id
        ,       NULL /* Cost Factor */
        ,       src_comp_details.required_for_revenue
        ,       src_comp_details.HIGH_QUANTITY
        ,       src_comp_details.component_sequence_id
        ,       BOM_Globals.Get_Prog_AppId
        ,       src_comp_details.wip_supply_type
        ,       DECODE(src_comp_details.supply_locator_id, FND_API.G_MISS_NUM,
           NULL, src_comp_details.supply_locator_id)
        ,       src_comp_details.bom_item_type
        ,       src_comp_details.operation_seq_num    --Check this too
        ,       src_comp_details.component_item_id
        ,       SYSDATE /* Last Update Date */
        ,       src_comp_details.last_updated_by /* Last Updated By */
        ,       SYSDATE /* Creation Date */
        ,       src_comp_details.created_by /* Created By */
        ,       src_comp_details.last_update_login /* Last Update Login */
        ,       DECODE(src_comp_details.ITEM_NUM, FND_API.G_MISS_NUM,
           1, NULL,1,src_comp_details.ITEM_NUM)
        ,       src_comp_details.component_quantity
        ,       src_comp_details.COMPONENT_YIELD_FACTOR
        ,       src_comp_details.COMPONENT_REMARKS
        ,       nvl(src_comp_details.effectivity_date,SYSDATE)    --2169237
        ,       src_comp_details.Change_Notice
        ,       src_comp_details.implementation_date/* Implementation Date */
       /*
        ,       DECODE(l_Bo_Id,
                       Bom_Globals.G_BOM_BO,
                       SYSDATE,
                       NULL
                      ) -- Implementation Date
       */
        ,       src_comp_details.disable_date
        ,       src_comp_details.attribute_category
        ,       src_comp_details.attribute1
        ,       src_comp_details.attribute2
        ,       src_comp_details.attribute3
        ,       src_comp_details.attribute4
        ,       src_comp_details.attribute5
        ,       src_comp_details.attribute6
        ,       src_comp_details.attribute7
        ,       src_comp_details.attribute8
        ,       src_comp_details.attribute9
        ,       src_comp_details.attribute10
        ,       src_comp_details.attribute11
        ,       src_comp_details.attribute12
        ,       src_comp_details.attribute13
        ,       src_comp_details.attribute14
        ,       src_comp_details.attribute15
        ,       src_comp_details.planning_factor
        ,       src_comp_details.quantity_related
        ,       src_comp_details.so_basis
        ,       src_comp_details.optional
        ,       src_comp_details.mutually_exclusive_options
        ,       src_comp_details.include_in_cost_rollup
        ,       src_comp_details.check_atp
        ,       src_comp_details.shipping_allowed
        ,       src_comp_details.required_to_ship
        ,       src_comp_details.include_on_ship_docs
        ,       NULL /* Include On Bill Docs */
        ,       src_comp_details.low_quantity
        ,       src_comp_details.acd_type
    --    ,       DECODE( p_rev_comp_Unexp_rec.old_component_sequence_id
    --                  , FND_API.G_MISS_NUM
    --                  , NULL
    --                  ,p_rev_comp_Unexp_rec.old_component_sequence_id
    --                  )
        ,       l_old_component_sequence_id  --Chk this
        ,       src_comp_details.bill_sequence_id
        ,       NULL /* Request Id */
        ,       BOM_Globals.Get_Prog_Id
        ,       SYSDATE /* program_update_date */
        ,       src_comp_details.pick_components
        ,     src_comp_details.original_system_reference
        ,     DECODE(  src_comp_details.from_end_item_unit_number
           , FND_API.G_MISS_CHAR
           , null
           , src_comp_details.from_end_item_unit_number
           )
        ,       DECODE(  src_comp_details.to_end_item_unit_number
                       , FND_API.G_MISS_CHAR
                       , null
                       , src_comp_details.to_end_item_unit_number
           )
        ,       BOM_Globals.Get_Eco_For_Production
                -- DECODE( l_Bo_Id, BOM_Globals.G_ECO_BO, l_Eco_For_Production, 2) /* Eco for Production flag */
        ,       src_comp_details.Enforce_Int_Requirements
        ,     src_comp_details.auto_request_material -- Added in 11.5.9 by ADEY
        ,      NULL-- Added by hgelli. Identifies this record as Bom Component.
        ,     src_comp_details.component_item_id
        ,     bill_rec.organization_id
        ,     src_comp_details.Suggested_Vendor_Name --- Deepu
        ,     src_comp_details.Vendor_Id --- Deepu
    --    ,     p_rev_component_rec.purchasing_category_id --- Deepu
        ,     src_comp_details.Unit_Price --- Deepu
      ,src_comp_details.from_object_revision_id
      ,src_comp_details.from_minor_revision_id
      , src_comp_details.common_component_sequence_id
      , src_comp_details.basis_type
      , decode(src_comp_details.component_item_revision_id, null, null, BOMPCMBM.get_rev_id_for_local_org(src_comp_details.component_item_revision_id, bill_rec.organization_id))
      --,l_comp_revision_id
      --,l_comp_minor_revision_id
        );
        BOMPCMBM.Resolve_Old_Comp_Attrs(p_dest_bill_seq_id => src_comp_details.bill_sequence_id
                                       , p_orig_old_comp_seq => src_comp_details.old_component_sequence_id
                                       , x_old_comp_seq_id => src_comp_details.old_component_sequence_id
                                       , x_wip_supply_type => src_comp_details.wip_supply_type
                                       , x_wip_supply_subinv => src_comp_details.supply_subinventory
                                       , x_wip_supply_locator_id => src_comp_details.supply_locator_id
                                       , x_inc_in_cost_rollup => src_comp_details.include_in_cost_rollup
                                       , x_op_seq => src_comp_details.operation_seq_num);

IF src_comp_details.old_component_sequence_id IS NOT NULL
THEN
  UPDATE BOM_COMPONENTS_B
  SET old_component_sequence_id = src_comp_details.old_component_sequence_id,
     wip_supply_type = src_comp_details.wip_supply_type,
     supply_subinventory = src_comp_details.supply_subinventory,
     supply_locator_id = src_comp_details.supply_locator_id,
     include_in_cost_rollup = src_comp_details.include_in_cost_rollup,
     operation_seq_num = src_comp_details.operation_seq_num
  WHERE COMPONENT_SEQUENCE_ID = src_comp_details.component_Sequence_id;
END IF;

        --Check if the insert caused overlapping components in any of the editable comm bills
        IF BOMPCMBM.Check_Component_Overlap(p_dest_bill_sequence_id => src_comp_details.bill_sequence_id
                                 , p_dest_comp_seq_id => src_comp_details.component_sequence_id
                                 , p_comp_item_id => src_comp_details.component_item_id
                                 , p_op_seq_num => src_comp_details.operation_seq_num
                                 , p_change_notice => src_comp_details.change_notice
                                 , p_eff_date => src_comp_details.effectivity_date
                                 , p_disable_date => src_comp_details.disable_date
                                 , p_impl_date => src_comp_details.implementation_date
                                 , p_rev_item_seq_id => src_comp_details.revised_item_sequence_id
                                 , p_src_bill_seq_id => bill_rec.source_bill_sequence_id
                                 )
        THEN --overlap exists
          x_Return_Status := FND_API.G_RET_STS_ERROR;
          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp_details.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = src_comp_details.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMMON_OVERLAP'
         --  , p_Message_Text => NULL
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMMON_OVERLAP');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;
        END IF;

--Cannot have records with basis type as lot and supply type Phantom.
        BEGIN
          SELECT 'Y'
          INTO l_dummy
          FROM BOM_COMPONENTS_B
          WHERE wip_supply_type = 6
          AND basis_type = 2
          AND component_sequence_id = src_comp_details.component_sequence_id;

          --If such record exists, raise an error
          x_Return_Status := FND_API.G_RET_STS_ERROR;

          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp_details.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = src_comp_details.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMM_SUPPLY_BASIS_CONFLICT'
         --  , p_Message_Text => NULL
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMM_SUPPLY_BASIS_CONFLICT');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
        /*Propagate_Comp_User_Attributes(p_src_comp_seq_id => src_comp_details.common_component_sequence_id,
                                       x_Return_Status => x_Return_Status);*/
        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
          return;
        END IF;
      end loop; --for src_comp_details in get_src_comp_details(p_src_comp_seq_id)
    end loop; --for bill_rec in get_related_bills(p_src_bill_seq_id)

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line(' SQL Error '||SQLERRM);
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected Error occured in Insert . . .' || SQLERRM); END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    l_err_text := G_PKG_NAME ||' : Utility (Related Component Insert) '
                             ||SUBSTR(SQLERRM, 1, 200);
    Error_Handler.Add_Error_Token
    (  p_Message_Name => NULL
     , p_Message_Text => l_err_text
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    );
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Related_Components;



/*
 * This is an overloaded Procedure called when a component is added to a bom that is commoned by other boms.
 * This will add the component to the common boms.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source BOM
 * @param p_src_comp_seq_id IN Component Sequence Id of the component added
 */
PROCEDURE Insert_Related_Components( p_src_bill_seq_id   IN NUMBER
                                     , p_src_comp_seq_id   IN NUMBER)
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status    VARCHAR2(1);
BEGIN
  Insert_Related_Components(p_src_bill_seq_id => p_src_bill_seq_id
                            , p_src_comp_seq_id => p_src_comp_seq_id
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;

END Insert_Related_Components;

--Bug 9238945 begin
PROCEDURE Update_Impl_Rel_Comp
( p_src_comp_seq_id   IN NUMBER
)
IS

 Cursor get_related_Components(p_src_comp_seq_id  NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID order by bill_sequence_id;

  Cursor get_src_comp_details(p_src_comp_seq_id NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE component_sequence_id = p_src_comp_seq_id;

  /*Cursor get_comp_on_same_bill(p_src_comp_seq_id NUMBER, p_dest_bill_seq_id NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  AND   bill_sequence_id = p_dest_bill_seq_id
  AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID;*/

  l_comp_seq_id NUMBER;
  b_impl_date DATE;
  old_bill_seq_id NUMBER := NULL;


  BEGIN

  for src_comp in get_src_comp_details(p_src_comp_seq_id)
    loop

    for dest_comp in get_related_Components(p_src_comp_seq_id)
      loop

      --no need to update any more record in this series, if the disable_date has already been stamped
      if  old_bill_seq_id is null or old_bill_seq_id <> dest_comp.bill_sequence_id then
      --need to identify whose disable date should be changed
      --for dest_same_comp in get_related_Components(p_src_comp_seq_id, dest_comp.bill_sequence_id)
       --loop

       --pick up the last implemented component

       select max(implementation_date) into b_impl_date from BOM_COMPONENTS_B bic
       WHERE bic.bill_sequence_id = dest_comp.bill_sequence_id
       AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq_id
       AND bic.implementation_date is not null;


        select component_sequence_id into l_comp_seq_id from BOM_COMPONENTS_B bic
        WHERE bic.bill_sequence_id = dest_comp.bill_sequence_id
        AND bic.COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq_id
        AND bic.implementation_date = b_impl_date;



      UPDATE  BOM_COMPONENTS_B dest_cmpo
       SET     DISABLE_DATE =  DECODE(src_comp.IMPLEMENTATION_DATE,
                                               NULL, src_comp.DISABLE_DATE,
                                               DECODE(DISABLE_DATE,
                                                        NULL, src_comp.DISABLE_DATE,
                                                        Greatest(src_comp.EFFECTIVITY_DATE, DISABLE_DATE), DECODE(DISABLE_DATE,
                                                                                                                     GREATEST(DISABLE_DATE, SYSDATE), src_comp.DISABLE_DATE,
                                                                                                                     DISABLE_DATE
                                                                                                                 ),
                                                        DISABLE_DATE
                                                      )
                                    ),
               to_object_revision_id = src_comp.to_object_revision_id,
                overlapping_changes = src_comp.overlapping_changes,
                change_notice = src_comp.change_notice,
                last_update_date = sysdate,
                last_updated_by = src_comp.last_updated_by,
                last_update_login = src_comp.last_update_login,
                request_id = src_comp.request_id,
                program_application_id = src_comp.program_application_id,
                program_id = src_comp.program_id,
                program_update_date = sysdate
      WHERE   COMPONENT_SEQUENCE_ID =  l_comp_seq_id
      AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID
    ;
    old_bill_seq_id := dest_comp.bill_sequence_id;
   -- end loop;
    end if;
   end loop;
  end loop;
  END Update_Impl_Rel_Comp;
--Bug 9238945 end

/*
 * This Procedure should be called when a component is updated in a bom that is commoned by other boms.
 * This will update the component in the common boms.
 * @param p_src_comp_seq_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Update_Related_Components
( p_src_comp_seq_id   IN NUMBER
, x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status   IN OUT NOCOPY VARCHAR2
)
IS
 --commented for bug 18189983
  /*Cursor get_related_Components(p_src_comp_seq_id  NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID; */

/* Added new cursors get_related_Components1 and get_related_Components2 for bug 18189983
 * get_related_Components1 selects the Current and future effective components
 * get_related_Components2 selects past effective components */

  Cursor get_related_Components1(p_src_comp_seq_id  NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID
  AND (disable_date > SYSDATE OR disable_date IS NULL)
  AND implementation_date IS NOT NULL
  order by bill_sequence_id, effectivity_date desc;

  Cursor get_related_Components2(p_src_comp_seq_id  NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id
  AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID
  AND disable_date < SYSDATE
  AND implementation_date IS NOT NULL
  order by bill_sequence_id, disable_date desc;

  Cursor get_src_comp_details(p_src_comp_seq_id NUMBER) IS
  SELECT *
  FROM BOM_COMPONENTS_B
  WHERE component_sequence_id = p_src_comp_seq_id;

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);
  l_token_tbl   Error_Handler.Token_Tbl_Type;
  l_comp_name VARCHAR2(80);
  l_dest_assy_item VARCHAR2(80);
  l_dest_org_code VARCHAR2(3);
  l_dest_org_id NUMBER;

  l_dummy VARCHAR2(10);

  --added the below variables for bug 18189983
  l_c_comp_name VARCHAR2(80);
  l_c_assy_item VARCHAR2(80);
  l_c_org_code VARCHAR2(3);
  l_c_org_id NUMBER;
  l_p_comp_name VARCHAR2(80);
  l_p_assy_item VARCHAR2(80);
  l_p_org_code VARCHAR2(3);
  l_p_org_id NUMBER;
  get_comp1_rowcount NUMBER;  --Moved the initialization from delcare block to begin block, bug 19640425
  --dest_comp2_cnt NUMBER := 0; --commented for bug 19640425
  --dest_comp1_cnt NUMBER := 0; --commented for bug 19640425

  --Added new variables for bug 19640425 which will be used for updating disable_date of related components
  l_bill_seq_id1 NUMBER;
  l_bill_seq_id2 NUMBER;
  l_bill_seq_id3 NUMBER;
  l_bill_seq_id4 NUMBER;
BEGIN

/* need to populate Operation Lead Time percent corresponding to the operation
  -vhymavat bug3537394 */
  /*IF((p_rev_component_rec.new_operation_sequence_number IS NULL) OR
     (p_rev_component_rec.new_operation_sequence_number =FND_API.G_MISS_NUM) ) THEN
          l_operation_seq_num := p_rev_component_rec.operation_sequence_number;

  ELSE
         l_operation_seq_num :=p_rev_component_rec.new_operation_sequence_number;
  END IF;*/

--OPEN ISSUE: With our opn Seq no defaulting, op seqs can be different for src and common boms
--Do we need this validation?  Or, since Operation sequence is updateable anyway, should an update
-- of op seq on a component be propagated to related comps? Dont think so. -AR.

 /*IF(l_operation_seq_num <>1 and p_rev_component_rec.acd_type is null) THEN
 l_operation_leadtime :=
        Get_Operation_Leadtime (
                p_assembly_item_id =>p_rev_comp_Unexp_rec.revised_item_id
               ,p_organization_id  =>p_rev_comp_Unexp_rec.organization_id
               ,p_alternate_bom_code =>p_rev_component_rec.alternate_bom_code
               ,p_operation_seq_num => l_operation_seq_num
                              );

 END IF;
*/

--Initialization of variables for bug 19640425
  l_bill_seq_id1 := -999;
  l_bill_seq_id2 := -9999;
  l_bill_seq_id3 := -999;
  l_bill_seq_id4 := -9999;
  get_comp1_rowcount := 0;

for src_comp in get_src_comp_details(p_src_comp_seq_id)
loop
    Check_Comp_Fixed_Rev_Dtls(p_src_bill_seq_id => src_comp.bill_sequence_id
                              , p_src_comp_seq_id => src_comp.component_sequence_id
                              , x_return_status => x_return_status);

    IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
    THEN

        SELECT concatenated_segments
        into l_comp_name
        from mtl_system_items_kfv item, bom_components_b comp
        where item.inventory_item_id = comp.pk1_value
        and item.organization_id = comp.pk2_value
        and comp.component_sequence_id = p_src_comp_seq_id;

       l_token_tbl.DELETE;
       l_token_tbl(1).token_name  := 'COMP_NAME';
       l_token_tbl(1).token_value := l_comp_name;

        Error_Handler.Add_Error_Token
        (  p_Message_Name   => 'BOM_FIXED_REV_NOT_ALLOWED'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_Token_Tbl      => l_token_tbl
                            );
         x_Return_Status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('BOM', 'BOM_FIXED_REV_NOT_ALLOWED');
         fnd_message.set_token('COMP_NAME', l_comp_name, true);
         RETURN;

    END IF;

  /* Changes of 18189983
   * this only updates the current and future effective components. It will not touch the past effective components
   * update the component only if the disable_date of parent is greater than the effective date of child
   * otherwise throw the error BOM_COMMON_COMP_UPD_ERR
   * update the disable_date of child component with the parent's disable_date only for the latest effective component
   * update the respective disable_date for other compnents
   * effectivity_date should be updated with the greatest of child's and parent's effectivity_date */

  for dest_comp1 in get_related_Components1(p_src_comp_seq_id)
  loop
    get_comp1_rowcount := get_related_Components1%ROWCOUNT;
    -- dest_comp1_cnt := dest_comp1_cnt+1; --commented for bug 19640425

    l_bill_seq_id2 := dest_comp1.bill_sequence_id; --Added for bug 19640425

    IF NOT(src_comp.disable_date IS NOT NULL AND src_comp.disable_date < dest_comp1.effectivity_date) THEN

    UPDATE  BOM_COMPONENTS_B dest_cmpo
    SET     REQUIRED_FOR_REVENUE = src_comp.required_for_revenue
    ,       HIGH_QUANTITY        = src_comp.HIGH_QUANTITY
/*    ,       WIP_SUPPLY_TYPE      = p_rev_component_rec.wip_supply_type
    ,       SUPPLY_LOCATOR_ID    =
  DECODE(p_rev_comp_Unexp_rec.supply_locator_id, FND_API.G_MISS_NUM,
         NULL, p_rev_comp_Unexp_rec.supply_locator_id)
    ,       OPERATION_SEQ_NUM    = l_operation_seq_num*/
    ,       EFFECTIVITY_DATE       = greatest(src_comp.effectivity_date, dest_comp1.effectivity_date) --modified for bug 18189983
    ,       LAST_UPDATE_DATE     = SYSDATE
    ,       LAST_UPDATED_BY      = src_comp.LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN    = src_comp.LAST_UPDATE_LOGIN
    ,       ITEM_NUM             = src_comp.ITEM_NUM
    ,       COMPONENT_QUANTITY   = src_comp.COMPONENT_QUANTITY
    ,       COMPONENT_YIELD_FACTOR = src_comp.COMPONENT_YIELD_FACTOR
    ,       COMPONENT_REMARKS      = src_comp.COMPONENT_REMARKS
    --commented for bug 18189983
	/*--Modified DECODE function for bug 9786178
    ,       DISABLE_DATE           = DECODE(src_comp.IMPLEMENTATION_DATE,
                                               NULL, src_comp.DISABLE_DATE,
                                               DECODE(DISABLE_DATE,
                                                        NULL, src_comp.DISABLE_DATE,
                                                        Greatest(src_comp.EFFECTIVITY_DATE, DISABLE_DATE), src_comp.DISABLE_DATE,
                                                        DISABLE_DATE
                                                      )
                                           ) */
    /* modified the decode statement for bug 19640425 to resolve the issue where in it was updating the disable_date of related
       components with NULL even though we update source component with valid disable date. It was not updating correclty for
       multiple common bills scenario. */
    /* ,       DISABLE_DATE           = DECODE(dest_comp1_cnt, 1, src_comp.DISABLE_DATE, DISABLE_DATE) --added for bug 18189983 */
    ,       DISABLE_DATE           = DECODE(l_bill_seq_id2, l_bill_seq_id1, DISABLE_DATE, src_comp.DISABLE_DATE)
    ,       ATTRIBUTE_CATEGORY     = src_comp.attribute_category
    ,       ATTRIBUTE1             = src_comp.attribute1
    ,       ATTRIBUTE2             = src_comp.attribute2
    ,       ATTRIBUTE3             = src_comp.attribute3
    ,       ATTRIBUTE4             = src_comp.attribute4
    ,       ATTRIBUTE5             = src_comp.attribute5
    ,       ATTRIBUTE6             = src_comp.attribute6
    ,       ATTRIBUTE7             = src_comp.attribute7
    ,       ATTRIBUTE8             = src_comp.attribute8
    ,       ATTRIBUTE9             = src_comp.attribute9
    ,       ATTRIBUTE10            = src_comp.attribute10
    ,       ATTRIBUTE11            = src_comp.attribute11
    ,       ATTRIBUTE12            = src_comp.attribute12
    ,       ATTRIBUTE13            = src_comp.attribute13
    ,       ATTRIBUTE14            = src_comp.attribute14
    ,       ATTRIBUTE15            = src_comp.attribute15
    ,       PLANNING_FACTOR        = src_comp.planning_factor
    ,       QUANTITY_RELATED       = src_comp.quantity_related
    ,       SO_BASIS               = src_comp.so_basis
    ,       OPTIONAL               = src_comp.optional
    ,       MUTUALLY_EXCLUSIVE_OPTIONS = src_comp.mutually_exclusive_options
    --,       INCLUDE_IN_COST_ROLLUP = src_comp.include_in_cost_rollup
    ,       CHECK_ATP              = src_comp.check_atp
    ,       SHIPPING_ALLOWED       = src_comp.shipping_allowed
    ,       REQUIRED_TO_SHIP       = src_comp.required_to_ship
    ,       INCLUDE_ON_SHIP_DOCS   = src_comp.include_on_ship_docs
    ,       LOW_QUANTITY          = src_comp.LOW_QUANTITY
    ,       ACD_TYPE               = src_comp.acd_type
    ,       PROGRAM_UPDATE_DATE    = SYSDATE
    ,     PROGRAM_ID       = BOM_Globals.Get_Prog_Id
    ,     OPERATION_LEAD_TIME_PERCENT =  src_comp.operation_lead_time_percent
    ,     Original_System_Reference =
                                 src_comp.original_system_reference
    ,       From_End_Item_Unit_Number = src_comp.From_End_Item_Unit_Number
    ,       To_End_Item_Unit_Number = src_comp.To_End_Item_Unit_Number
    ,       Enforce_Int_Requirements = src_comp.Enforce_Int_Requirements
    ,     Auto_Request_Material = src_comp.auto_request_material -- Added in 11.5.9 by ADEY
    ,     Suggested_Vendor_Name = src_comp.Suggested_Vendor_Name --- Deepu
    ,     Vendor_Id = src_comp.Vendor_Id --- Deepu
--    ,     Purchasing_Category_id = src_comp.purchasing_category_id --- Deepu
    ,     Unit_Price = src_comp.Unit_Price --- Deepu
    ,     Basis_type = src_comp.Basis_type
    ,     COMPONENT_ITEM_REVISION_ID = decode(src_comp.component_item_revision_id, null, null, BOMPCMBM.get_rev_id_for_local_org(src_comp.component_item_revision_id, dest_comp1.pk2_value))
    WHERE   COMPONENT_SEQUENCE_ID = dest_comp1.component_sequence_id
    AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID
    ;

    --Added for bug 19640425
    l_bill_seq_id1 := dest_comp1.bill_sequence_id;

        --Check if the insert caused overlapping components in any of the editable comm bills
        IF BOMPCMBM.Check_Component_Overlap(p_dest_bill_sequence_id => dest_comp1.bill_sequence_id
                                 , p_dest_comp_seq_id => dest_comp1.component_sequence_id
                                 , p_comp_item_id => dest_comp1.component_item_id
                                 , p_op_seq_num => dest_comp1.operation_seq_num
                                 , p_change_notice => dest_comp1.change_notice
                                 , p_eff_date => dest_comp1.effectivity_date
                                 , p_disable_date => dest_comp1.disable_date
                                 , p_impl_date => dest_comp1.implementation_date
                                 , p_rev_item_seq_id => dest_comp1.revised_item_Sequence_id
                                 , p_src_bill_seq_id => src_comp.bill_sequence_id
                                 )
        THEN --overlap exists
          x_Return_Status := FND_API.G_RET_STS_ERROR;

            SELECT Organization_id
            INTO l_dest_org_id
            FROM BOM_STRUCTURES_B
            WHERE bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMMON_OVERLAP'
         --  , p_Message_Text => NULL
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMMON_OVERLAP');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;
        END IF;

        --Cannot have records with basis type as lot and supply type Phantom.
        BEGIN

          SELECT basis_type
          INTO l_dummy
          FROM BOM_COMPONENTS_B
          WHERE component_sequence_id = dest_comp1.component_sequence_id;

          SELECT 'Y'
          INTO l_dummy
          FROM BOM_COMPONENTS_B
          WHERE wip_supply_type = 6
          AND basis_type = 2
          AND component_sequence_id = dest_comp1.component_sequence_id;

          --If such record exists, raise an error
          x_Return_Status := FND_API.G_RET_STS_ERROR;

          SELECT Organization_id
          INTO l_dest_org_id
          FROM BOM_STRUCTURES_B
          WHERE bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMM_SUPPLY_BASIS_CONFLICT'
         --  , p_Message_Text => NULL
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMM_SUPPLY_BASIS_CONFLICT');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;

    /* Added ELSE for bug 18189983 to throw the error BOM_COMMON_COMP_UPD_ERR
    if the new disable_date of parent is less than the effective date of child */
    ELSE

       BEGIN

          SELECT Organization_id
          INTO l_c_org_id
          FROM BOM_STRUCTURES_B
          WHERE bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT concatenated_segments
          into l_c_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = dest_comp1.component_item_id
          and organization_id = l_c_org_id;

          SELECT concatenated_segments
          into l_c_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = dest_comp1.bill_sequence_id;

          SELECT organization_code
          into l_c_org_code
          from mtl_parameters
          where organization_id = l_c_org_id;

	  SELECT Organization_id
            INTO l_p_org_id
            FROM BOM_STRUCTURES_B
            WHERE bill_sequence_id = src_comp.bill_sequence_id;

          SELECT concatenated_segments
          into l_p_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = src_comp.bill_sequence_id;

          SELECT organization_code
          into l_p_org_code
          from mtl_parameters
          where organization_id = l_p_org_id;

          l_token_tbl(1).token_name  := 'C_COMP_NAME';
          l_token_tbl(1).token_value := l_c_comp_name;
          l_token_tbl(2).token_name  := 'C_ORG_CODE';
          l_token_tbl(2).token_value := l_c_org_code;
          l_token_tbl(3).token_name  := 'C_ASSY_NAME';
          l_token_tbl(3).token_value   := l_c_assy_item;
          l_token_tbl(4).token_name  := 'P_ORG_CODE';
          l_token_tbl(4).token_value := l_p_org_code;
          l_token_tbl(5).token_name  := 'P_ASSY_NAME';
          l_token_tbl(5).token_value   := l_p_assy_item;
	  l_token_tbl(6).token_name  := 'C_EFF_DATE';
          l_token_tbl(6).token_value   := TO_CHAR(dest_comp1.effectivity_date, 'DD-MON-YYYY HH24:MI:SS');

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMMON_COMP_UPD_ERR'
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
	   , p_message_type        => 'E'
          );
          x_Return_Status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('BOM', 'BOM_COMMON_COMP_UPD_ERR');
          fnd_message.set_token('C_COMP_NAME', l_c_comp_name);
          fnd_message.set_token('C_ORG_CODE', l_c_org_code);
          fnd_message.set_token('C_ASSY_NAME', l_c_assy_item);
          fnd_message.set_token('P_ORG_CODE', l_p_org_code);
          fnd_message.set_token('P_ASSY_NAME', l_p_assy_item);
	  fnd_message.set_token('C_EFF_DATE', TO_CHAR(dest_comp1.effectivity_date, 'DD-MON-YYYY HH24:MI:SS'));

	  return;
	  EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
       END;

    end if; --end of IF NOT(src_comp.disable_date IS NOT NULL AND src_comp.disable_date < dest_comp1.effectivity_date) THEN
    /*Propagate_Comp_User_Attributes(p_src_comp_seq_id => p_src_comp_seq_id,
                                   x_Return_Status => x_return_status);
      This api will not overwrite data. */
  end loop; --for dest_comp1 in get_related_Components1(p_src_comp_seq_id)

  /* changes of bug 18189983
   * this is only to handle the scenario where we update the disable_date of past effective component to NULL/Future Date
   * to make the component as effective. Note that there will not be any effective components available prior to this update.
   * it first checks whether the cursor get_related_Components1 fetched the zero records to ensure ther are no effective components
   * and updates the latest effective child component. */

  IF get_comp1_rowcount = 0 THEN

  for dest_comp2 in get_related_Components2(p_src_comp_seq_id)
  LOOP

  --dest_comp2_cnt := dest_comp2_cnt+1; --commented for bug 19640425

  l_bill_seq_id3 := dest_comp2.bill_sequence_id; --Added for bug 19640425

   /* Modified the IF condition for bug 19640425 to handle mutliple common bill scenario.
   Prior to this it was updating only one common bill leaving out other common bills. */

   --IF dest_comp2_cnt = 1 THEN
   IF l_bill_seq_id3 <> l_bill_seq_id4 THEN

   UPDATE  BOM_COMPONENTS_B dest_cmpo
    SET     REQUIRED_FOR_REVENUE = src_comp.required_for_revenue
    ,       HIGH_QUANTITY        = src_comp.HIGH_QUANTITY
    ,       EFFECTIVITY_DATE       =  GREATEST(src_comp.effectivity_date, dest_comp2.effectivity_date)
    ,       LAST_UPDATE_DATE     = SYSDATE
    ,       LAST_UPDATED_BY      = src_comp.LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN    = src_comp.LAST_UPDATE_LOGIN
    ,       ITEM_NUM             = src_comp.ITEM_NUM
    ,       COMPONENT_QUANTITY   = src_comp.COMPONENT_QUANTITY
    ,       COMPONENT_YIELD_FACTOR = src_comp.COMPONENT_YIELD_FACTOR
    ,       COMPONENT_REMARKS      = src_comp.COMPONENT_REMARKS
    ,       DISABLE_DATE           = src_comp.DISABLE_DATE
    ,       ATTRIBUTE_CATEGORY     = src_comp.attribute_category
    ,       ATTRIBUTE1             = src_comp.attribute1
    ,       ATTRIBUTE2             = src_comp.attribute2
    ,       ATTRIBUTE3             = src_comp.attribute3
    ,       ATTRIBUTE4             = src_comp.attribute4
    ,       ATTRIBUTE5             = src_comp.attribute5
    ,       ATTRIBUTE6             = src_comp.attribute6
    ,       ATTRIBUTE7             = src_comp.attribute7
    ,       ATTRIBUTE8             = src_comp.attribute8
    ,       ATTRIBUTE9             = src_comp.attribute9
    ,       ATTRIBUTE10            = src_comp.attribute10
    ,       ATTRIBUTE11            = src_comp.attribute11
    ,       ATTRIBUTE12            = src_comp.attribute12
    ,       ATTRIBUTE13            = src_comp.attribute13
    ,       ATTRIBUTE14            = src_comp.attribute14
    ,       ATTRIBUTE15            = src_comp.attribute15
    ,       PLANNING_FACTOR        = src_comp.planning_factor
    ,       QUANTITY_RELATED       = src_comp.quantity_related
    ,       SO_BASIS               = src_comp.so_basis
    ,       OPTIONAL               = src_comp.optional
    ,       MUTUALLY_EXCLUSIVE_OPTIONS = src_comp.mutually_exclusive_options
    ,       CHECK_ATP              = src_comp.check_atp
    ,       SHIPPING_ALLOWED       = src_comp.shipping_allowed
    ,       REQUIRED_TO_SHIP       = src_comp.required_to_ship
    ,       INCLUDE_ON_SHIP_DOCS   = src_comp.include_on_ship_docs
    ,       LOW_QUANTITY          = src_comp.LOW_QUANTITY
    ,       ACD_TYPE               = src_comp.acd_type
    ,       PROGRAM_UPDATE_DATE    = SYSDATE
    ,     PROGRAM_ID       = BOM_Globals.Get_Prog_Id
    ,     OPERATION_LEAD_TIME_PERCENT =  src_comp.operation_lead_time_percent
    ,     Original_System_Reference =
                                 src_comp.original_system_reference
    ,       From_End_Item_Unit_Number = src_comp.From_End_Item_Unit_Number
    ,       To_End_Item_Unit_Number = src_comp.To_End_Item_Unit_Number
    ,       Enforce_Int_Requirements = src_comp.Enforce_Int_Requirements
    ,     Auto_Request_Material = src_comp.auto_request_material -- Added in 11.5.9 by ADEY
    ,     Suggested_Vendor_Name = src_comp.Suggested_Vendor_Name
    ,     Vendor_Id = src_comp.Vendor_Id
    ,     Unit_Price = src_comp.Unit_Price
    ,     Basis_type = src_comp.Basis_type
    ,     COMPONENT_ITEM_REVISION_ID = decode(src_comp.component_item_revision_id, null, null, BOMPCMBM.get_rev_id_for_local_org(src_comp.component_item_revision_id, dest_comp2.pk2_value))
    WHERE   COMPONENT_SEQUENCE_ID =  dest_comp2.component_sequence_id
    AND COMPONENT_SEQUENCE_ID <> COMMON_COMPONENT_SEQUENCE_ID
    ;

    l_bill_seq_id4 := dest_comp2.bill_sequence_id; --Added for bug 19640425

        --Check if the insert caused overlapping components in any of the editable comm bills
        IF BOMPCMBM.Check_Component_Overlap(p_dest_bill_sequence_id => dest_comp2.bill_sequence_id
                                 , p_dest_comp_seq_id => dest_comp2.component_sequence_id
                                 , p_comp_item_id => dest_comp2.component_item_id
                                 , p_op_seq_num => dest_comp2.operation_seq_num
                                 , p_change_notice => dest_comp2.change_notice
                                 , p_eff_date => dest_comp2.effectivity_date
                                 , p_disable_date => dest_comp2.disable_date
                                 , p_impl_date => dest_comp2.implementation_date
                                 , p_rev_item_seq_id => dest_comp2.revised_item_Sequence_id
                                 , p_src_bill_seq_id => src_comp.bill_sequence_id
                                 )
        THEN --overlap exists
          x_Return_Status := FND_API.G_RET_STS_ERROR;

            SELECT Organization_id
            INTO l_dest_org_id
            FROM BOM_STRUCTURES_B
            WHERE bill_sequence_id = dest_comp2.bill_sequence_id;

          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = dest_comp2.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMMON_OVERLAP'
         --  , p_Message_Text => NULL
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMMON_OVERLAP');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;
        END IF;

--Cannot have records with basis type as lot and supply type Phantom.
        BEGIN

          SELECT basis_type
          INTO l_dummy
          FROM BOM_COMPONENTS_B
          WHERE component_sequence_id = dest_comp2.component_sequence_id;

          SELECT 'Y'
          INTO l_dummy
          FROM BOM_COMPONENTS_B
          WHERE wip_supply_type = 6
          AND basis_type = 2
          AND component_sequence_id = dest_comp2.component_sequence_id;

          --If such record exists, raise an error
          x_Return_Status := FND_API.G_RET_STS_ERROR;

          SELECT Organization_id
          INTO l_dest_org_id
          FROM BOM_STRUCTURES_B
          WHERE bill_sequence_id = dest_comp2.bill_sequence_id;

          SELECT concatenated_segments
          into l_comp_name
          from mtl_system_items_kfv
          where inventory_item_id = src_comp.component_item_id
          and organization_id = l_dest_org_id;

          SELECT concatenated_segments
          into l_dest_assy_item
          from mtl_system_items_kfv item, BOM_STRUCTURES_B bom
          where item.inventory_item_id = bom.assembly_item_id
          and item.organization_id = bom.organization_id
          and bom.bill_sequence_id = dest_comp2.bill_sequence_id;

          SELECT organization_code
          into l_dest_org_code
          from mtl_parameters
          where organization_id = l_dest_org_id;

          l_token_tbl(1).token_name  := 'COMP_NAME';
          l_token_tbl(1).token_value := l_comp_name;
          l_token_tbl(2).token_name  := 'ORG_CODE';
          l_token_tbl(2).token_value := l_dest_org_code;
          l_token_tbl(3).token_name  := 'ASSY_NAME';
          l_token_tbl(3).token_value   := l_dest_assy_item;

          Error_Handler.Add_Error_Token
          (p_Message_Name => 'BOM_COMM_SUPPLY_BASIS_CONFLICT'
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl => l_mesg_token_tbl
           , p_Token_Tbl => l_token_tbl
          );

          fnd_message.set_name('BOM', 'BOM_COMM_SUPPLY_BASIS_CONFLICT');
          fnd_message.set_token('COMP_NAME', l_comp_name);
          fnd_message.set_token('ORG_CODE', l_dest_org_code);
          fnd_message.set_token('ASSY_NAME', l_dest_assy_item);

          Return;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;

   end if; --end of IF dest_comp2_cnt = 1 THEN
  end loop; --for dest_comp2 in get_related_Components2(p_src_comp_seq_id)
  END if; --end of IF get_comp1_rowcount = 0 THEN
end loop; --for src_comp in get_src_comp_details(p_src_comp_seq_id)

--If the update is of the editable attrs of a component in an editable common bill

--When the WIP attrs for the old component are modified, the pending changes still referencing
--the ECO on src bill should be synchronized with the same values.
    UPDATE BOM_COMPONENTS_B bic
    SET (wip_supply_type, supply_locator_id, supply_subinventory, operation_seq_num, include_in_cost_rollup) =
              (SELECT wip_supply_type, supply_locator_id, supply_subinventory, operation_seq_num, include_in_cost_rollup
               FROM BOM_COMPONENTS_B
               WHERE component_sequence_id = p_src_comp_Seq_id)
    WHERE old_component_sequence_id = p_src_comp_Seq_id
    AND implementation_date IS NULL
    AND nvl(common_component_sequence_id, component_sequence_id) <> component_sequence_id
    AND bill_sequence_id NOT IN (SELECT bill_sequence_id
                                 FROM eng_revised_items
                                 WHERE change_notice = bic.change_notice);

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
          l_err_text := G_PKG_NAME ||' : Utility (Related Component Update) '
                               ||SUBSTR(SQLERRM, 1, 200);
      Error_Handler.Add_Error_Token
      (  p_Message_Name => NULL
       , p_Message_Text => l_err_text
       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      );
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Related_Components;



/*
 * This overloaded Procedure should be called from java when a component is updated in a bom that is commoned by other boms.
 * This will update the component in the common boms.
 * @param p_src_comp_seq_id IN Component Sequence Id of the component updated
 */
PROCEDURE Update_Related_Components( p_src_comp_seq_id   IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status  VARCHAR2(1);
BEGIN
  Update_Related_Components( p_src_comp_seq_id  => p_src_comp_seq_id
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Return_Status  => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END Update_Related_Components;


/*
 * This Procedure  will replicate the ref designators of components of the source BOM as ref desgs of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
Procedure Replicate_Ref_Desg(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

l_return_status         varchar2(80);
l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_err_text                    VARCHAR2(2000);

BEGIN
  INSERT  INTO BOM_REFERENCE_DESIGNATORS
  (       COMPONENT_REFERENCE_DESIGNATOR
  ,       LAST_UPDATE_DATE
  ,       LAST_UPDATED_BY
  ,       CREATION_DATE
  ,       CREATED_BY
  ,       LAST_UPDATE_LOGIN
  ,       REF_DESIGNATOR_COMMENT
  ,       CHANGE_NOTICE
  ,       COMPONENT_SEQUENCE_ID
  ,       ACD_TYPE
  ,       REQUEST_ID
  ,       PROGRAM_APPLICATION_ID
  ,       PROGRAM_ID
  ,       PROGRAM_UPDATE_DATE
  ,       ATTRIBUTE_CATEGORY
  ,       ATTRIBUTE1
  ,       ATTRIBUTE2
  ,       ATTRIBUTE3
  ,       ATTRIBUTE4
  ,       ATTRIBUTE5
  ,       ATTRIBUTE6
  ,       ATTRIBUTE7
  ,       ATTRIBUTE8
  ,       ATTRIBUTE9
  ,       ATTRIBUTE10
  ,       ATTRIBUTE11
  ,       ATTRIBUTE12
  ,       ATTRIBUTE13
  ,       ATTRIBUTE14
  ,       ATTRIBUTE15
  ,       Original_System_Reference
  ,       Common_component_sequence_id
  )
  SELECT
          ref_desg.component_reference_designator
  ,       SYSDATE
  ,       ref_desg.LAST_UPDATED_BY
  ,       SYSDATE
  ,       ref_desg.CREATED_BY
  ,       ref_desg.LAST_UPDATE_LOGIN
  ,       DECODE( ref_desg.ref_designator_comment
                , FND_API.G_MISS_CHAR
                , NULL
                , ref_desg.ref_designator_comment )
  ,       ref_desg.change_notice
  ,       comp.component_sequence_id
  ,       ref_desg.acd_type
  ,       NULL /* Request Id */
  ,       Bom_Globals.Get_Prog_AppId
  ,       Bom_Globals.Get_Prog_Id
  ,       SYSDATE
  ,       ref_desg.attribute_category
  ,       ref_desg.attribute1
  ,       ref_desg.attribute2
  ,       ref_desg.attribute3
  ,       ref_desg.attribute4
  ,       ref_desg.attribute5
  ,       ref_desg.attribute6
  ,       ref_desg.attribute7
  ,       ref_desg.attribute8
  ,       ref_desg.attribute9
  ,       ref_desg.attribute10
  ,       ref_desg.attribute11
  ,       ref_desg.attribute12
  ,       ref_desg.attribute13
  ,       ref_desg.attribute14
  ,       ref_desg.attribute15
  ,       ref_desg.Original_System_Reference
  ,       p_component_sequence_id
  FROM BOM_COMPONENTS_B comp, BOM_REFERENCE_DESIGNATORS ref_desg
  WHERE comp.component_sequence_id <> comp.common_component_sequence_id
  AND comp.common_component_sequence_id = ref_desg.component_sequence_id
  AND ref_desg.component_sequence_id = p_component_sequence_id
  AND NOT EXISTS
              (
                SELECT 1
                FROM bom_reference_designators ref2
                where ref2.component_sequence_id = comp.component_sequence_id
                and ref2.component_reference_designator = ref_desg.component_reference_designator
              )
  ;
        /*insert into bom_reference_designators(<col_list>)
      values(<ref_desg>);*/
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line(' Error '||SQLERRM);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      l_err_text := G_PKG_NAME ||' : Common BOM (Ref Desg Replicate) '
                               ||SUBSTR(SQLERRM, 1, 200);
      Error_Handler.Add_Error_Token
      (  p_Message_Name => NULL
       , p_Message_Text => l_err_text
       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      );
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;
    fnd_message.set_name('BOM', 'BOM_REPLICATE_FAILED');
    --arudresh_debug('error in replicate ref desg'||SQLERRM);
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Replicate_Ref_Desg;


/*
 * This overloaded Procedure should be called from java to replicate the ref designators of components of
 * the source BOM as ref desgs of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated.
 */
Procedure Replicate_Ref_Desg(p_component_sequence_id IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status  VARCHAR2(1);
BEGIN
  Replicate_Ref_Desg(p_component_sequence_id => p_component_sequence_id
                     , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                     , x_Return_Status  => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;


/*
 * This Procedure is used to add reference designators to the related components of the common boms whenever
 * reference designator is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator added.
 * @param p_acd_type IN ACD TYPE of the reference designator, added for bug 20345308. This is to resolve unique
    constraint error, when we try to save 'disable' and 'add' actions of a reference designator at once in an ECO.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Insert_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_ref_desg IN VARCHAR2
				  , p_acd_type IN VARCHAR2
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS
  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

  Cursor get_ref_desg_details(p_comp_seq_id NUMBER,
                              p_ref_desg VARCHAR2,
			      p_acd_type VARCHAR2)
  IS
  select *
  from bom_reference_designators
  where component_sequence_id = p_comp_seq_id
  and component_reference_designator = p_ref_desg
  AND NVL(acd_type, 0) = NVL(p_acd_type, 0);

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select dest.component_sequence_id
  from BOM_COMPONENTS_B dest, BOM_COMPONENTS_B src
  where dest.component_sequence_id <> dest.common_component_sequence_id
  and dest.common_component_sequence_id = p_comp_seq_id
  and src.component_sequence_id = dest.common_component_sequence_id
  and ((src.implementation_date is null
         and dest.implementation_date is null
        )
        OR
        dest.implementation_date is not null
       );

BEGIN
  for ref_desg in get_ref_desg_details(p_component_sequence_id, p_ref_desg, p_acd_type)
  loop
    for dest_comp in get_destn_comps(p_component_sequence_id)
    loop
      INSERT  INTO BOM_REFERENCE_DESIGNATORS
      (       COMPONENT_REFERENCE_DESIGNATOR
      ,       LAST_UPDATE_DATE
      ,       LAST_UPDATED_BY
      ,       CREATION_DATE
      ,       CREATED_BY
      ,       LAST_UPDATE_LOGIN
      ,       REF_DESIGNATOR_COMMENT
      ,       CHANGE_NOTICE
      ,       COMPONENT_SEQUENCE_ID
      ,       ACD_TYPE
      ,       REQUEST_ID
      ,       PROGRAM_APPLICATION_ID
      ,       PROGRAM_ID
      ,       PROGRAM_UPDATE_DATE
      ,       ATTRIBUTE_CATEGORY
      ,       ATTRIBUTE1
      ,       ATTRIBUTE2
      ,       ATTRIBUTE3
      ,       ATTRIBUTE4
      ,       ATTRIBUTE5
      ,       ATTRIBUTE6
      ,       ATTRIBUTE7
      ,       ATTRIBUTE8
      ,       ATTRIBUTE9
      ,       ATTRIBUTE10
      ,       ATTRIBUTE11
      ,       ATTRIBUTE12
      ,       ATTRIBUTE13
      ,       ATTRIBUTE14
      ,       ATTRIBUTE15
      ,       Original_System_Reference
      ,       Common_component_sequence_id
      )
      VALUES
      (       ref_desg.component_reference_designator
      ,       SYSDATE
      ,       ref_desg.LAST_UPDATED_BY
      ,       SYSDATE
      ,       ref_desg.CREATED_BY
      ,       ref_desg.LAST_UPDATE_LOGIN
      ,       DECODE( ref_desg.ref_designator_comment
                    , FND_API.G_MISS_CHAR
                    , NULL
                    , ref_desg.ref_designator_comment )
      ,       ref_desg.Change_Notice
      ,       dest_comp.component_sequence_id
      ,       ref_desg.acd_type
      ,       NULL /* Request Id */
      ,       Bom_Globals.Get_Prog_AppId
      ,       Bom_Globals.Get_Prog_Id
      ,       SYSDATE
      ,       ref_desg.attribute_category
      ,       ref_desg.attribute1
      ,       ref_desg.attribute2
      ,       ref_desg.attribute3
      ,       ref_desg.attribute4
      ,       ref_desg.attribute5
      ,       ref_desg.attribute6
      ,       ref_desg.attribute7
      ,       ref_desg.attribute8
      ,       ref_desg.attribute9
      ,       ref_desg.attribute10
      ,       ref_desg.attribute11
      ,       ref_desg.attribute12
      ,       ref_desg.attribute13
      ,       ref_desg.attribute14
      ,       ref_desg.attribute15
      ,       ref_desg.Original_System_Reference
      ,       ref_desg.component_sequence_id
      );
    end loop;--for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop;--for ref_desg in get_ref_desg_details(p_component_sequence_id, p_ref_desg)
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||' : Common BOM (Related Ref Desg Insert) '
                                 ||SUBSTR(SQLERRM, 1, 200);
            Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_Text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      END IF;
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Related_Ref_Desg;


/*
 * This overloaded Procedure is called from Java to add reference designators to the related components of the common boms whenever
 * reference designator is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator added.
 * @param p_acd_type IN ACD TYPE of the reference designator, added for bug 20345308 to resolve the issue where in, unique
    constraint error thrown when we try to save both 'disable' and 'add' actions of a reference designator at once in an ECO.
 */
PROCEDURE Insert_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_ref_desg IN VARCHAR2
				  , p_acd_type IN VARCHAR2)
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status   VARCHAR2(1);
BEGIN
  Insert_Related_Ref_Desg(p_component_sequence_id => p_component_sequence_id
                          , p_ref_desg => p_ref_desg
			  , p_acd_type => p_acd_type
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END Insert_Related_Ref_Desg;

/*
 * This Procedure is used to update reference designators of the related components of the common boms whenever
 * reference designator of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator updated.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Update_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_old_ref_desg IN VARCHAR2
                                  , p_new_ref_desg IN VARCHAR2
                                  , p_acd_type IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS
  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

  Cursor get_ref_desg_details(p_comp_seq_id NUMBER,
                              p_ref_desg VARCHAR2)
  IS
  select *
  from bom_reference_designators
  where component_sequence_id = p_comp_seq_id
  and component_reference_designator = p_ref_desg;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select component_sequence_id
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_comp_seq_id;

BEGIN
  for ref_desg in get_ref_desg_details(p_component_sequence_id, p_new_ref_desg)
  loop
    /*for dest_comp in get_destn_comps(p_component_sequence_id)
    loop*/
      UPDATE  BOM_REFERENCE_DESIGNATORS
      SET   COMPONENT_REFERENCE_DESIGNATOR = ref_desg.COMPONENT_REFERENCE_DESIGNATOR
      ,       LAST_UPDATE_DATE  = SYSDATE
      ,       LAST_UPDATED_BY = ref_desg.LAST_UPDATED_BY
      ,       LAST_UPDATE_LOGIN   = ref_desg.LAST_UPDATE_LOGIN
      ,       REF_DESIGNATOR_COMMENT = ref_desg.REF_DESIGNATOR_COMMENT
      ,       ATTRIBUTE_CATEGORY  = ref_desg.attribute_category
      ,       ATTRIBUTE1    = ref_desg.attribute1
      ,       ATTRIBUTE2          = ref_desg.attribute2
      ,       ATTRIBUTE3          = ref_desg.attribute3
      ,       ATTRIBUTE4          = ref_desg.attribute4
      ,       ATTRIBUTE5          = ref_desg.attribute5
      ,       ATTRIBUTE6          = ref_desg.attribute6
      ,       ATTRIBUTE7          = ref_desg.attribute7
      ,       ATTRIBUTE8          = ref_desg.attribute8
      ,       ATTRIBUTE9          = ref_desg.attribute9
      ,       ATTRIBUTE10         = ref_desg.attribute10
      ,       ATTRIBUTE11         = ref_desg.attribute11
      ,       ATTRIBUTE12         = ref_desg.attribute12
      ,       ATTRIBUTE13         = ref_desg.attribute13
      ,       ATTRIBUTE14         = ref_desg.attribute14
      ,       ATTRIBUTE15         = ref_desg.attribute15
      ,       Original_System_Reference =
                                  ref_desg.Original_System_Reference
      WHERE   COMPONENT_REFERENCE_DESIGNATOR = p_old_ref_desg
      AND     COMMON_COMPONENT_SEQUENCE_ID = p_component_sequence_id
      AND     COMMON_COMPONENT_SEQUENCE_ID <> COMPONENT_SEQUENCE_ID
      AND NVL(ACD_TYPE, 0) = nvl(p_acd_type, 0);
    --end loop; --for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop; --for ref_desg in get_ref_desg_details(p_component_sequence_id, p_ref_desg)

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN

        /*IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;*/
      Error_Handler.Add_Error_Token
  (  p_Message_Name => NULL
   , p_Message_Text => 'ERROR in Update Row (Related Ref Desgs)' ||
                       substr(SQLERRM, 1, 100) || ' '    ||
                       to_char(SQLCODE)
   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
   , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl);

  fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
  x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;


END Update_Related_Ref_Desg;


/*
 * This overloaded Procedure is called from Java to update reference designators of the related components of the common boms whenever
 * reference designator of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator updated.
 */
PROCEDURE Update_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_old_ref_desg IN VARCHAR2
                                  , p_new_ref_desg IN VARCHAR2
                                  , p_acd_type IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status VARCHAR2(1);
BEGIN
  Update_Related_Ref_Desg(p_component_sequence_id => p_component_sequence_id
                          , p_new_ref_desg => p_new_ref_desg
                          , p_old_ref_desg  => p_old_ref_desg
                          , p_acd_type => p_acd_type
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;


/*
 * This Procedure  will replicate the substitutes of components of the source BOM as susbtitutes of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Replicate_Sub_Comp(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  Cursor get_sub_comps(p_component_sequence_id NUMBER)
  is
  SELECT * from bom_substitute_components
  where component_sequence_id = p_component_sequence_id;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select component_sequence_id
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_component_sequence_id;

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

BEGIN
  INSERT  INTO BOM_SUBSTITUTE_COMPONENTS
  (       SUBSTITUTE_COMPONENT_ID
  ,       LAST_UPDATE_DATE
  ,       LAST_UPDATED_BY
  ,       CREATION_DATE
  ,       CREATED_BY
  ,       LAST_UPDATE_LOGIN
  ,       SUBSTITUTE_ITEM_QUANTITY
  ,       COMPONENT_SEQUENCE_ID
  ,       ACD_TYPE
  ,       CHANGE_NOTICE
  ,       REQUEST_ID
  ,       PROGRAM_APPLICATION_ID
  ,       PROGRAM_UPDATE_DATE
  ,       ATTRIBUTE_CATEGORY
  ,       ATTRIBUTE1
  ,       ATTRIBUTE2
  ,       ATTRIBUTE3
  ,       ATTRIBUTE4
  ,       ATTRIBUTE5
  ,       ATTRIBUTE6
  ,       ATTRIBUTE7
  ,       ATTRIBUTE8
  ,       ATTRIBUTE9
  ,       ATTRIBUTE10
  ,       ATTRIBUTE11
  ,       ATTRIBUTE12
  ,       ATTRIBUTE13
  ,       ATTRIBUTE14
  ,       ATTRIBUTE15
  ,       PROGRAM_ID
  ,       Original_System_Reference
  ,       Enforce_Int_Requirements
  ,       Common_component_sequence_id
  )
  SELECT
          sub_comp.substitute_component_id
  ,       SYSDATE
  ,       sub_comp.LAST_UPDATED_BY
  ,       SYSDATE
  ,       sub_comp.CREATED_BY
  ,       sub_comp.LAST_UPDATE_LOGIN
  ,       sub_comp.substitute_item_quantity
  ,       dest_comp.component_sequence_id
  ,       sub_comp.acd_type
  ,       sub_comp.Change_Notice
  ,     NULL /* Request Id */
  ,       Bom_Globals.Get_Prog_AppId
  ,       SYSDATE
  ,       sub_comp.attribute_category
  ,       sub_comp.attribute1
  ,       sub_comp.attribute2
  ,       sub_comp.attribute3
  ,       sub_comp.attribute4
  ,       sub_comp.attribute5
  ,       sub_comp.attribute6
  ,       sub_comp.attribute7
  ,       sub_comp.attribute8
  ,       sub_comp.attribute9
  ,       sub_comp.attribute10
  ,       sub_comp.attribute11
  ,       sub_comp.attribute12
  ,       sub_comp.attribute13
  ,       sub_comp.attribute14
  ,       sub_comp.attribute15
  ,       Bom_Globals.Get_Prog_Id
  ,       sub_comp.Original_System_Reference
  ,       sub_comp.enforce_int_requirements
  ,       sub_comp.component_sequence_id
  FROM BOM_SUBSTITUTE_COMPONENTS sub_comp, BOM_COMPONENTS_B dest_comp
  WHERE dest_comp.component_Sequence_id <> dest_comp.common_component_sequence_id
  AND dest_comp.common_component_sequence_id = sub_comp.component_sequence_id
  AND sub_comp.component_sequence_id  = p_component_sequence_id
  AND NOT EXISTS
            (
              SELECT 1
              FROM bom_substitute_components bsc2
              where bsc2.component_sequence_id = dest_comp.component_sequence_id
              and bsc2.substitute_component_id = sub_comp.substitute_component_id
            )
  ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Substitute Component Replicate)'
                                 ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_REPLICATE_FAILED');
      --arudresh_debug('error in replicate sub comp '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Replicate_Sub_Comp;

/*
 * This overloaded Procedure is called from Java to replicate the substitutes of components of the source BOM
 * as susbtitutes of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 */
PROCEDURE Replicate_Sub_Comp(p_component_sequence_id IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status VARCHAR2(1);
BEGIN
  Replicate_Sub_Comp(p_component_sequence_id => p_component_sequence_id
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;


/*
 * This Procedure is used to add Substitute Components to the related components of the common boms whenever
 * a substitute component is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id added.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Insert_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

  Cursor get_sub_comp_details(p_comp_seq_id NUMBER,
                              p_sub_comp_item_id NUMBER)
  IS
  select *
  from bom_substitute_components
  where component_sequence_id = p_comp_seq_id
  and substitute_component_id = p_sub_comp_item_id;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select dest.component_sequence_id
  from BOM_COMPONENTS_B dest, BOM_COMPONENTS_B src
  where dest.component_sequence_id <> dest.common_component_sequence_id
  and dest.common_component_sequence_id = p_comp_seq_id
  and src.component_sequence_id = dest.common_component_sequence_id
  and ((src.implementation_date is null
         and dest.implementation_date is null
        )
        OR
        dest.implementation_date is not null
       );

BEGIN
  for sub_comp in get_sub_comp_details(p_component_sequence_id, p_sub_comp_item_id)
  loop
    for dest_comp in get_destn_comps(p_component_sequence_id)
    loop

      INSERT  INTO BOM_SUBSTITUTE_COMPONENTS
      (       SUBSTITUTE_COMPONENT_ID
      ,       LAST_UPDATE_DATE
      ,       LAST_UPDATED_BY
      ,       CREATION_DATE
      ,       CREATED_BY
      ,       LAST_UPDATE_LOGIN
      ,       SUBSTITUTE_ITEM_QUANTITY
      ,       COMPONENT_SEQUENCE_ID
      ,       ACD_TYPE
      ,       CHANGE_NOTICE
      ,       REQUEST_ID
      ,       PROGRAM_APPLICATION_ID
      ,       PROGRAM_UPDATE_DATE
      ,       ATTRIBUTE_CATEGORY
      ,       ATTRIBUTE1
      ,       ATTRIBUTE2
      ,       ATTRIBUTE3
      ,       ATTRIBUTE4
      ,       ATTRIBUTE5
      ,       ATTRIBUTE6
      ,       ATTRIBUTE7
      ,       ATTRIBUTE8
      ,       ATTRIBUTE9
      ,       ATTRIBUTE10
      ,     ATTRIBUTE11
      ,       ATTRIBUTE12
      ,       ATTRIBUTE13
      ,       ATTRIBUTE14
      ,       ATTRIBUTE15
      ,       PROGRAM_ID
      ,       Original_System_Reference
      ,       Enforce_Int_Requirements
      ,       Common_component_sequence_id
      )
      VALUES
      (       sub_comp.substitute_component_id
      ,       SYSDATE
      ,       sub_comp.LAST_UPDATED_BY
      ,       SYSDATE
      ,       sub_comp.CREATED_BY
      ,       sub_comp.LAST_UPDATE_LOGIN
      ,       sub_comp.substitute_item_quantity
      ,       dest_comp.component_sequence_id
      ,       sub_comp.acd_type
      ,       sub_comp.Change_Notice
      ,     NULL /* Request Id */
      ,       Bom_Globals.Get_Prog_AppId
      ,       SYSDATE
      ,       sub_comp.attribute_category
      ,       sub_comp.attribute1
      ,       sub_comp.attribute2
      ,       sub_comp.attribute3
      ,       sub_comp.attribute4
      ,       sub_comp.attribute5
      ,       sub_comp.attribute6
      ,       sub_comp.attribute7
      ,       sub_comp.attribute8
      ,       sub_comp.attribute9
      ,       sub_comp.attribute10
      ,       sub_comp.attribute11
      ,       sub_comp.attribute12
      ,       sub_comp.attribute13
      ,       sub_comp.attribute14
      ,       sub_comp.attribute15
      ,       Bom_Globals.Get_Prog_Id
      ,       sub_comp.Original_System_Reference
      ,       sub_comp.enforce_int_requirements
      ,       sub_comp.component_sequence_id
      );

    end loop; --for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop;--for sub_comp in get_sub_comp_details(p_component_sequence_id, p_sub_comp_item_id)
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Related Substitute Component Insert)'
                                 ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Related_Sub_Comp;



/*
 * This overloaded Procedure is called from Java to add Substitute Components to the related components of the common boms whenever
 * a substitute component is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id added.
 */
PROCEDURE Insert_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status  VARCHAR2(1);
begin
  Insert_Related_Sub_Comp(p_component_sequence_id => p_component_sequence_id
                          , p_sub_comp_item_id => p_sub_comp_item_id
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
end;

/*
 * This Procedure is used to update substitutes of the related components of the common boms whenever
 * substitute of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id updated.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Update_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_old_sub_comp_item_id IN NUMBER
                                  , p_new_sub_comp_item_id IN NUMBER
                                  , p_acd_type IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);
  l_acd_type              NUMBER;

  Cursor get_sub_comp_details(p_comp_seq_id NUMBER,
                              p_sub_comp_item_id NUMBER)
  IS
  select *
  from bom_substitute_components
  where component_sequence_id = p_comp_seq_id
  and substitute_component_id = p_new_sub_comp_item_id
  and nvl(acd_type, 0) = nvl(p_acd_type, 0);

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select component_sequence_id
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_comp_seq_id;

BEGIN
  for sub_comp in get_sub_comp_details(p_component_sequence_id, p_new_sub_comp_item_id)
  loop
    /*for dest_comp in get_destn_comps(p_component_sequence_id)
    loop
      l_acd_type := sub_comp.acd_type;*/
      UPDATE  BOM_SUBSTITUTE_COMPONENTS
      SET    SUBSTITUTE_COMPONENT_ID =  sub_comp.substitute_component_id
      ,       SUBSTITUTE_ITEM_QUANTITY  = sub_comp.substitute_item_quantity
      ,       ATTRIBUTE_CATEGORY  = sub_comp.attribute_category
      ,       ATTRIBUTE1    = sub_comp.attribute1
      ,       ATTRIBUTE2          = sub_comp.attribute2
      ,       ATTRIBUTE3          = sub_comp.attribute3
      ,       ATTRIBUTE4          = sub_comp.attribute4
      ,       ATTRIBUTE5          = sub_comp.attribute5
      ,       ATTRIBUTE6          = sub_comp.attribute6
      ,       ATTRIBUTE7          = sub_comp.attribute7
      ,       ATTRIBUTE8          = sub_comp.attribute8
      ,       ATTRIBUTE9          = sub_comp.attribute9
      ,       ATTRIBUTE10         = sub_comp.attribute10
      ,       ATTRIBUTE11         = sub_comp.attribute11
      ,       ATTRIBUTE12         = sub_comp.attribute12
      ,       ATTRIBUTE13         = sub_comp.attribute13
      ,       ATTRIBUTE14         = sub_comp.attribute14
      ,       ATTRIBUTE15         = sub_comp.attribute15
      ,       Original_system_Reference =
                                    sub_comp.original_system_reference
      ,       Enforce_Int_Requirements = sub_comp.Enforce_Int_Requirements
      WHERE   SUBSTITUTE_COMPONENT_ID = p_old_sub_comp_item_id
      AND     COMMON_COMPONENT_SEQUENCE_ID = sub_comp.component_sequence_id
      AND     COMMON_COMPONENT_SEQUENCE_ID <> COMPONENT_SEQUENCE_ID
      AND     nvl(ACD_TYPE,0) = nvl(p_acd_type, 0)
      ;
    --end loop;--for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop; --for sub_comp in get_sub_comp_details(p_component_sequence_id, p_sub_comp_item_id)
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Related Substitute Component Insert)'
                                 ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Related_Sub_Comp;

/*
 * This overloaded Procedure is called from Java to update substitutes of the related components of the common boms whenever
 * substitute of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id updated.
 */
PROCEDURE Update_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_old_sub_comp_item_id IN NUMBER
                                  , p_new_sub_comp_item_id IN NUMBER
                                  , p_acd_type IN NUMBER)
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status   VARCHAR2(1);
BEGIN
  Update_Related_Sub_Comp(p_component_sequence_id => p_component_sequence_id
                          , p_old_sub_comp_item_id => p_old_sub_comp_item_id
                          , p_new_sub_comp_item_id => p_new_sub_comp_item_id
                          , p_acd_type => p_acd_type
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;






/*
 * This Procedure  will replicate the component operations of the source BOM as component operations of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Replicate_Comp_Ops(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  Cursor get_comp_ops(p_component_sequence_id NUMBER)
  is
  SELECT * from bom_component_operations
  where component_sequence_id = p_component_sequence_id;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select *
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_comp_seq_id;

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text              VARCHAR2(2000);
  l_dummy                 NUMBER;
  l_token_tbl   Error_Handler.Token_tbl_Type;
  l_comp_op_exists        VARCHAR2(1);

BEGIN

  BEGIN
    SELECT 'Y'
    INTO l_comp_op_exists
    FROM BOM_COMPONENT_OPERATIONS
    WHERE component_sequence_id = p_component_sequence_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --No comp ops to replicate, return
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      Return;
    WHEN TOO_MANY_ROWS THEN
      --Continue with validations
      Null;
  END;
  --Check whether the op seq num of the comp op is valid for dest bills.
  --If not, return with error.


  FOR destn_comps in get_destn_comps(p_comp_seq_id => p_component_sequence_id)
  loop
    BEGIN
      SELECT bco.operation_seq_num
      INTO l_dummy
      FROM bom_component_operations bco, BOM_COMPONENTS_B bic
      WHERE bco.component_sequence_id = bic.component_sequence_id
      AND bic.component_sequence_id = p_component_sequence_id
      AND EXISTS(
                    SELECT operation_seq_num, bos.routing_sequence_id
                    FROM bom_operational_routings bor, bom_operation_sequences bos, BOM_STRUCTURES_B bom
                    WHERE bos.routing_sequence_id = bor.common_routing_sequence_id
                    AND bos.operation_seq_num = bco.operation_seq_num
                    AND bor.assembly_item_id = bom.assembly_item_id
                    AND bor.organization_id = bom.ORGANIZATION_id
                    AND nvl(bor.alternate_routing_designator, 'XXX') = Nvl(bom.alternate_bom_designator, 'XXX')
                    AND bom.bill_sequence_id = destn_comps.bill_sequence_id
                    );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --At least one referring bill's rtg does not have the op seq of the comp op defined.
         Error_Handler.Add_Error_Token
        (  p_Message_Name   => 'BOM_COMMON_OP_SEQ_INVALID'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_Token_Tbl      => l_Token_Tbl
         );
         fnd_message.set_name('BOM', 'BOM_COMMON_OP_SEQ_INVALID');
         x_return_status := FND_API.G_RET_STS_ERROR;
         Return;
       WHEN TOO_MANY_ROWS THEN
        --Means just that more than one comp opn is associated with the comp.
        NULL;
    END;
  END LOOP;

    INSERT INTO bom_component_operations
    (
    COMP_OPERATION_SEQ_ID          ,
    OPERATION_SEQ_NUM              ,
    OPERATION_SEQUENCE_ID          ,
    LAST_UPDATE_DATE               ,
    LAST_UPDATED_BY                ,
    CREATION_DATE                  ,
    CREATED_BY                     ,
    LAST_UPDATE_LOGIN              ,
    COMPONENT_SEQUENCE_ID          ,
    BILL_SEQUENCE_ID               ,
    ATTRIBUTE_CATEGORY           ,
    ATTRIBUTE1                    ,
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
    COMMON_COMPONENT_SEQUENCE_ID)
  SELECT
    bom_component_operations_s.NEXTVAL      ,
    comp_ops.OPERATION_SEQ_NUM              ,
    comp_ops.OPERATION_SEQUENCE_ID          ,
    comp_ops.LAST_UPDATE_DATE               ,
    comp_ops.LAST_UPDATED_BY                ,
    comp_ops.CREATION_DATE                  ,
    comp_ops.CREATED_BY                     ,
    comp_ops.LAST_UPDATE_LOGIN              ,
    dest_comp.COMPONENT_SEQUENCE_ID          ,
    dest_comp.BILL_SEQUENCE_ID               ,
    comp_ops.ATTRIBUTE_CATEGORY           ,
    comp_ops.ATTRIBUTE1                    ,
    comp_ops.ATTRIBUTE2                     ,
    comp_ops.ATTRIBUTE3                     ,
    comp_ops.ATTRIBUTE4                     ,
    comp_ops.ATTRIBUTE5                     ,
    comp_ops.ATTRIBUTE6                     ,
    comp_ops.ATTRIBUTE7                     ,
    comp_ops.ATTRIBUTE8                     ,
    comp_ops.ATTRIBUTE9                     ,
    comp_ops.ATTRIBUTE10                    ,
    comp_ops.ATTRIBUTE11                    ,
    comp_ops.ATTRIBUTE12                    ,
    comp_ops.ATTRIBUTE13                    ,
    comp_ops.ATTRIBUTE14                    ,
    comp_ops.ATTRIBUTE15                    ,
    comp_ops.COMPONENT_SEQUENCE_ID
  FROM BOM_COMPONENT_OPERATIONS comp_ops, BOM_COMPONENTS_B dest_comp
  WHERE dest_comp.component_Sequence_id <> dest_comp.common_component_sequence_id
  AND dest_comp.common_component_sequence_id = comp_ops.component_sequence_id
  AND comp_ops.component_sequence_id  = p_component_sequence_id
  AND NOT EXISTS
            (
              SELECT 1
              FROM BOM_COMPONENT_OPERATIONS ops2
              where ops2.component_sequence_id = dest_comp.component_sequence_id
            )
  ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Component Operations Replicate)'
                                      ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_REPLICATE_FAILED');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Replicate_Comp_Ops;


/*
 * This overloaded Procedure is called from Java to replicate the component operations of the source BOM
 * as component operations of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 */
PROCEDURE Replicate_Comp_Ops(p_component_sequence_id IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status VARCHAR2(1);
BEGIN
  Replicate_Comp_Ops(p_component_sequence_id => p_component_sequence_id
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;


/*
 * This Procedure is used to add Component Operations to the related components of the common boms whenever
 * a component operation is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Number of the component updated
 * @param p_operation_seq_num IN Operation Sequence number added.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Insert_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_operation_seq_num IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

  Cursor get_comp_op_details(p_comp_seq_id NUMBER,
                              p_operation_seq_num NUMBER)
  IS
  select *
  from bom_component_operations
  where component_sequence_id = p_comp_seq_id
  and operation_seq_num= p_operation_seq_num;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select component_sequence_id, bill_sequence_id
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_comp_seq_id;

BEGIN
  for comp_ops in get_comp_op_details(p_component_sequence_id, p_operation_seq_num)
  loop
    for dest_comp in get_destn_comps(p_component_sequence_id)
    loop
      INSERT INTO bom_component_operations
      (
      COMP_OPERATION_SEQ_ID          ,
      OPERATION_SEQ_NUM              ,
      OPERATION_SEQUENCE_ID          ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATED_BY                ,
      CREATION_DATE                  ,
      CREATED_BY                     ,
      LAST_UPDATE_LOGIN              ,
      COMPONENT_SEQUENCE_ID          ,
      BILL_SEQUENCE_ID               ,
      ATTRIBUTE_CATEGORY           ,
      ATTRIBUTE1                    ,
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
      COMMON_COMPONENT_SEQUENCE_ID)
      VALUES(
      bom_component_operations_s.NEXTVAL      ,
      comp_ops.OPERATION_SEQ_NUM              ,
      comp_ops.OPERATION_SEQUENCE_ID          ,
      comp_ops.LAST_UPDATE_DATE               ,
      comp_ops.LAST_UPDATED_BY                ,
      comp_ops.CREATION_DATE                  ,
      comp_ops.CREATED_BY                     ,
      comp_ops.LAST_UPDATE_LOGIN              ,
      dest_comp.COMPONENT_SEQUENCE_ID          ,
      dest_comp.BILL_SEQUENCE_ID               ,
      comp_ops.ATTRIBUTE_CATEGORY           ,
      comp_ops.ATTRIBUTE1                    ,
      comp_ops.ATTRIBUTE2                     ,
      comp_ops.ATTRIBUTE3                     ,
      comp_ops.ATTRIBUTE4                     ,
      comp_ops.ATTRIBUTE5                     ,
      comp_ops.ATTRIBUTE6                     ,
      comp_ops.ATTRIBUTE7                     ,
      comp_ops.ATTRIBUTE8                     ,
      comp_ops.ATTRIBUTE9                     ,
      comp_ops.ATTRIBUTE10                    ,
      comp_ops.ATTRIBUTE11                    ,
      comp_ops.ATTRIBUTE12                    ,
      comp_ops.ATTRIBUTE13                    ,
      comp_ops.ATTRIBUTE14                    ,
      comp_ops.ATTRIBUTE15                    ,
      comp_ops.component_sequence_id
      );
    end loop; --for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop; --for comp_ops in get_comp_op_details(p_component_sequence_id, p_comp_operation_seq_id)
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Related Component Operation Insert)'
                                 ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Related_Comp_Ops;



/*
 * This overloaded Procedure is called from Java to add Component Operations to the related components of the common boms whenever
 * a Component Operation is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence number of the component updated
 * @param p_operation_seq_num IN Operation Sequence Number added.
 */
PROCEDURE Insert_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_operation_seq_num IN NUMBER)
IS
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status  VARCHAR2(1);
begin
  Insert_Related_Comp_Ops(p_component_sequence_id => p_component_sequence_id
                          , p_operation_seq_num => p_operation_seq_num
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
end;

/*
 * This Procedure is used to update Component Operations of the related components of the common boms whenever
 * Component Operations of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_operation_seq_num IN Component Operation Id added.
 * @param p_new_operation_seq_num IN Component Operation Id added.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Update_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_old_operation_seq_num IN NUMBER
                                  , p_new_operation_seq_num IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2)
IS

  l_return_status         varchar2(80);
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_err_text                    VARCHAR2(2000);

  Cursor get_comp_op_details(p_comp_seq_id NUMBER,
                              p_new_operation_seq_num NUMBER)
  IS
  select *
  from bom_component_operations
  where component_sequence_id = p_comp_seq_id
  and operation_seq_num = p_new_operation_seq_num;

  Cursor get_destn_comps(p_comp_seq_id number)
  is
  select component_sequence_id
  from BOM_COMPONENTS_B
  where component_sequence_id <> common_component_sequence_id
  and common_component_sequence_id = p_comp_seq_id;

BEGIN
  for comp_ops in get_comp_op_details(p_component_sequence_id, p_new_operation_seq_num)
  loop
    /*for dest_comp in get_destn_comps(p_component_sequence_id)
    loop*/
      UPDATE bom_component_operations SET
        OPERATION_SEQ_NUM          =  comp_ops.OPERATION_SEQ_NUM  ,
        OPERATION_SEQUENCE_ID      =  comp_ops.OPERATION_SEQUENCE_ID,
        LAST_UPDATE_DATE           =  comp_ops.LAST_UPDATE_DATE    ,
        LAST_UPDATED_BY            =  comp_ops.LAST_UPDATED_BY   ,
        LAST_UPDATE_LOGIN          =  comp_ops.LAST_UPDATE_LOGIN  ,
        ATTRIBUTE_CATEGORY         =  comp_ops.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1                 =  comp_ops.ATTRIBUTE1 ,
        ATTRIBUTE2                 =  comp_ops.ATTRIBUTE2 ,
        ATTRIBUTE3                 =  comp_ops.ATTRIBUTE3 ,
        ATTRIBUTE4                 =  comp_ops.ATTRIBUTE4 ,
        ATTRIBUTE5                 =  comp_ops.ATTRIBUTE5 ,
        ATTRIBUTE6                 =  comp_ops.ATTRIBUTE6 ,
        ATTRIBUTE7                 =  comp_ops.ATTRIBUTE7 ,
        ATTRIBUTE8                 =  comp_ops.ATTRIBUTE8 ,
        ATTRIBUTE9                 =  comp_ops.ATTRIBUTE9 ,
        ATTRIBUTE10                =  comp_ops.ATTRIBUTE10 ,
        ATTRIBUTE11                =  comp_ops.ATTRIBUTE11 ,
        ATTRIBUTE12                =  comp_ops.ATTRIBUTE12 ,
        ATTRIBUTE13                =  comp_ops.ATTRIBUTE13 ,
        ATTRIBUTE14                =  comp_ops.ATTRIBUTE14 ,
        ATTRIBUTE15                =  comp_ops.ATTRIBUTE15,
        REQUEST_ID                 = comp_ops.REQUEST_ID,
        PROGRAM_ID                 = comp_ops.PROGRAM_ID,
        PROGRAM_APPLICATION_ID     = comp_ops.PROGRAM_APPLICATION_ID,
        PROGRAM_UPDATE_DATE        = comp_ops.PROGRAM_UPDATE_DATE
        WHERE OPERATION_SEQ_NUM = p_old_operation_seq_num
        AND COMMON_COMPONENT_SEQUENCE_ID = p_component_sequence_id
        AND COMMON_COMPONENT_SEQUENCE_ID <> COMPONENT_SEQUENCE_ID
        ;
    --end loop; --for dest_comp in get_destn_comps(p_component_sequence_id)
  end loop; --for comp_ops in get_comp_op_details(p_component_sequence_id, p_comp_operation_seq_id)
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        l_err_text := G_PKG_NAME ||'Utility (Related Component Operation Insert)'
                                 ||SUBSTR(SQLERRM, 1, 100);
        Error_Handler.Add_Error_Token
        (  p_Message_Name => NULL
         , p_Message_text => l_err_text
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        );
      END IF; --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Related_Comp_Ops;

/*
 * This overloaded Procedure is called from Java to update Component Operations of the common boms whenever
 * Component Operations of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_operation_seq_num IN Component Operation Id added.
 * @param p_new_operation_seq_num IN Component Operation Id added.
 */
PROCEDURE Update_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_old_operation_seq_num IN NUMBER
                                  , p_new_operation_seq_num IN NUMBER)
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status   VARCHAR2(1);
BEGIN
  Update_Related_Comp_Ops(p_component_sequence_id => p_component_sequence_id
                          , p_old_operation_seq_num => p_old_operation_seq_num
                          , p_new_operation_seq_num => p_new_operation_seq_num
                          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , x_Return_Status => l_Return_Status);
  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    app_exception.raise_exception;
  END IF;
END;




/*
 * This Procedure is used to delete related comp ops from the referencing boms when comp ops
 * from the source bom is deleted.
 * @param p_src_comp_seq_id IN Component Sequence Id of the source component.
 * @param p_operation_seq_num  IN Operation sequence number of the dest source component.
 */
PROCEDURE Delete_Related_Comp_Ops(p_src_comp_seq_id IN NUMBER,
                                   p_operation_seq_num IN NUMBER,
                                   x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM BOM_COMPONENT_OPERATIONS
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq_id
  AND OPERATION_SEQ_NUM = p_operation_seq_num;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


/*
 * This Procedure is used to validate the operation sequences of the source bom.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source bom
 * @param p_assembly_item_id IN Assembly Item Id of the common bom.
 * @param p_organization_id IN Organization Id of the Commmon BOM
 * @param p_alt_desg IN Alternate BOM Designator of the BOM
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 */
PROCEDURE Validate_Operation_Sequence_Id(p_src_bill_sequence_id IN NUMBER
                                         , p_assembly_item_id IN NUMBER
                                         , p_organization_id IN NUMBER
                                         , p_alt_desg IN VARCHAR2
                                         , x_Return_Status  IN OUT NOCOPY VARCHAR2)
IS

/*  Cursor check_src_routing_exists(p_src_bill_sequence_id NUMBER)
  IS
  Select 'Routing Exists'
  from BOM_OPERATIONAL_ROUTINGS bor, BOM_STRUCTURES_B bom
  Where bom.assembly_item_id = bor.assembly_item_id
  And bom.organization_id = bor.organizatin_id
  And nvl(bor.alternate_routing_designator, 'XXX') = nvl(bom.alternate_bom_designator, 'XXX')
  And bom.bill_sequence_id = p_src_bill_sequence_id*/

  Cursor get_src_op_seq(p_src_bill_sequence_id NUMBER)
  IS
  Select OPERATION_SEQ_NUM
  From BOM_COMPONENTS_B
  Where bill_sequence_id = p_src_bill_sequence_id;

/*  Cursor get_primary_rtg_opns(p_assy_item_id NUMBER, p_org_id NUMBER, p_alt_desg VARCHAR2)
  IS
  Select OPERATION_SEQ_NUM
  From BOM_OPERATION_SEQUENCES
  Where Routing_Sequence_Id = (Select common_routing_sequence_id
                               from bom_operational_routings
                               where assembly_item_id = p_assy_item_id
                               and organization_id = p_org_id
                               and alternate_routing_designator is null
                               and not exists
                                    (select 1
                                     from bom_operational_routings
                                     where assembly_item_id = p_assy_item_id
                                     and organization_id = p_org_id
                                     and alternate_routing_designator = p_alt_desg
                                    )
                               )
  UNION
  SELECT 1 from dual;
*/
  Cursor get_rtg_opns(p_assy_item_id NUMBER, p_org_id NUMBER, p_alt_desg VARCHAR2)
  IS
  Select OPERATION_SEQ_NUM
  From BOM_OPERATION_SEQUENCES
  Where Routing_Sequence_Id = (Select common_routing_sequence_id
                               from bom_operational_routings
                               where assembly_item_id = p_assy_item_id
                               and organization_id = p_org_id
                               and nvl(alternate_routing_designator, 'XXX') = nvl(p_alt_desg, 'XXX'))

  UNION
  SELECT 1 from dual;

  l_rtg_exist varchar2(30);
  l_stmt_num number;
  found boolean;
  valid_op_seq boolean;
  l_alt_rtg_exists NUMBER := 0;

BEGIN
  --Check if Routing exists for the source bom
  BEGIN
    Select 'Routing Exists'
    INTO l_rtg_exist
    from BOM_OPERATIONAL_ROUTINGS bor, BOM_STRUCTURES_B bom
    Where bom.assembly_item_id = bor.assembly_item_id
    And bom.organization_id = bor.organization_id
    And (nvl(bor.alternate_routing_designator, 'XXX') = nvl(bom.alternate_bom_designator, 'XXX')
         OR bor.alternate_routing_designator IS NULL)
    And bom.bill_sequence_id = p_src_bill_sequence_id;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
    NULL;
  END;

  IF p_alt_desg IS NOT NULL
  THEN
    BEGIN
      SELECT 1
      INTO l_alt_rtg_exists
      FROM BOM_OPERATIONAL_ROUTINGS
      WHERE assembly_item_id = p_assembly_item_id
      AND organization_id = p_organization_id
      AND alternate_routing_designator = p_alt_desg;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_alt_rtg_exists := 0;
    END;
  END IF;

  for src_op_seq in get_src_op_seq(p_src_bill_sequence_id)
  loop
  --arudresh_debug('Looking for op seq '||src_op_seq.OPERATION_SEQ_NUM);
    found := false;
    IF l_alt_rtg_exists = 1
    THEN
      /* check only in the alt rtg */
      for dest_op_Seq in get_rtg_opns(p_assembly_item_id, p_organization_id, p_alt_desg)
      loop
        if src_op_seq.OPERATION_SEQ_NUM = dest_op_seq.OPERATION_SEQ_NUM
        then
          found := true;
        end if; --if src_op_seq.OPERATION_SEQ_NUM = dest_op_seq.OPERATION_SEQ_NUM
      end loop; --for dest_op_Seq in get_rtg_opns(p_assembly_item_id, p_organization_id, p_alt_desg)
    ELSE
      for dest_op_Seq in get_rtg_opns(p_assembly_item_id, p_organization_id, null)
      loop
        if src_op_seq.OPERATION_SEQ_NUM = dest_op_seq.OPERATION_SEQ_NUM
        then
          found := true;
        end if; --if src_op_seq.OPERATION_SEQ_NUM = dest_op_seq.OPERATION_SEQ_NUM
      end loop; --for dest_op_Seq in get_rtg_opns(p_assembly_item_id, p_organization_id, p_alt_desg)
    END IF;
    if not found then
      valid_op_seq := false;
    end if; --if not found
    EXIT When not valid_op_seq;
  end loop; --for src_op_seq in get_src_op_seq(p_src_bill_sequence_id)

  if not valid_op_seq then
    x_return_status := FND_API.G_RET_STS_ERROR;
  else
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  end if; --if not valid_op_seq
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  --Source bill doesnt have a rtg. No validation reqd.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  WHEN TOO_MANY_ROWS THEN
    NULL;
END;




/*
 * This Procedure is used to replicate the component user attributes from the source bom.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source component.
 * @param p_dest_bill_seq_id IN Bill Sequence Id of the dest source component.
 */
Procedure Replicate_Comp_User_Attrs(p_src_bill_seq_id IN NUMBER,
                                    p_dest_bill_seq_id IN NUMBER,
                                    x_Return_Status OUT NOCOPY VARCHAR2)
IS
  l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_src_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_str_type EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_str_type          NUMBER;
  l_errorcode     NUMBER;
  l_msg_data        VARCHAR2(100);
  l_msg_count          NUMBER      :=  0;
  --l_return_status      VARCHAR2(1);
  l_src_str_type NUMBER;
  l_data_level_name_comp VARCHAR2(30) := 'COMPONENTS_LEVEL';
  l_data_level_id_comp   NUMBER;
  l_old_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;

  Cursor get_source_and_dest_components(p_bill_sequence_id Number)
  IS
  SELECT
  component_sequence_id, common_component_sequence_id
  from BOM_COMPONENTS_B
  where bill_sequence_id = p_bill_sequence_id
  and component_sequence_id <> common_component_sequence_id;

  Cursor get_structure_type(p_bill_seq_id NUMBER)
  IS
  Select structure_type_id
  from BOM_STRUCTURES_B
  where bill_sequence_id = p_bill_seq_id;

  CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
    SELECT DATA_LEVEL_ID
      FROM EGO_DATA_LEVEL_B
     WHERE DATA_LEVEL_NAME = p_data_level_name;

BEGIN

  Open get_structure_type(p_bill_seq_id => p_dest_bill_seq_id);
  Fetch get_structure_type INTO l_str_type;
  Close get_structure_type;

  Open get_structure_type(p_bill_seq_id => p_src_bill_seq_id);
  Fetch get_structure_type INTO l_src_str_type;
  Close get_structure_type;

  FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp) LOOP
    l_data_level_id_comp := c_comp_level.DATA_LEVEL_ID;
  END LOOP;

  IF l_src_str_type <> l_str_type
  THEN
    --Cannot copy user attributes across structure types.
    return;
  END IF; --IF l_src_str_type <> l_str_type

  for comp in get_source_and_dest_components(p_bill_sequence_id => p_dest_bill_seq_id)
  loop
    l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(comp.common_component_sequence_id))
                                                               ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(p_src_bill_seq_id)) );
    l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(comp.component_sequence_id)),
                                                                EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(p_dest_bill_seq_id)) );
    l_new_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID', TO_CHAR(l_str_type)));
    l_old_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
    l_new_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
    EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data(
                                                 p_api_version                   => 1.0
                                                ,p_application_id                => 702
                                                ,p_object_name                   => 'BOM_COMPONENTS'
                                                ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
                                                ,p_new_pk_col_value_pairs      =>  l_dest_pk_col_name_val_pairs
                                                ,p_new_cc_col_value_pairs      => l_new_str_type
                                                ,p_old_data_level_id           => l_data_level_id_comp
                                                ,p_new_data_level_id           => l_data_level_id_comp
                                                ,p_old_dtlevel_col_value_pairs => l_old_dtlevel_col_value_pairs
                                                ,p_new_dtlevel_col_value_pairs => l_new_dtlevel_col_value_pairs
                                                ,x_return_status                 => x_Return_Status
                                                ,x_errorcode                     => l_errorcode
                                                ,x_msg_count                     => l_msg_count
                                                ,x_msg_data                      => l_msg_data
                                                );
  IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
  THEN
    fnd_message.set_name('BOM', 'BOM_REPLICATE_FAILED');
    return;
  END IF;
  end loop; --for comp in get_source_and_dest_components(p_bill_sequence_id => p_dest_bill_seq_id)
END Replicate_Comp_User_Attrs;

/*
 * This Procedure is used to copy the component user attributes from the source bom.
 * @param p_src_comp_seq_id IN Component Sequence Id of the source source component.
 */
Procedure Propagate_Comp_User_Attributes(p_src_comp_seq_id IN NUMBER
                                         , p_attr_grp_id IN NUMBER
                                         , x_Return_Status OUT NOCOPY VARCHAR2)
IS
  l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_src_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_str_type EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_str_type          NUMBER;
  l_errorcode     NUMBER;
  l_msg_data        VARCHAR2(100);
  l_msg_count          NUMBER      :=  0;
  --l_return_status      VARCHAR2(1);
  l_dest_comp_seq_id NUMBER;
  l_dest_comp_seq_id NUMBER;
  l_src_bill_seq_id NUMBER;
  l_src_str_type NUMBER;


  --l_return_status     VARCHAR2(100);
  --l_errorcode     NUMBER;
  --l_msg_count     NUMBER  ;
  --l_msg_data        VARCHAR2(100);
  l_row_table_index       NUMBER := 1;
  l_data_table_index      NUMBER := 1;
  l_failed_row_count      NUMBER;
  --l_pk_column_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_attributes_row_table    EGO_USER_ATTR_ROW_TABLE;
  l_attributes_data_table   EGO_USER_ATTR_DATA_TABLE;
  l_attr_group_request_table    EGO_ATTR_GROUP_REQUEST_TABLE;
  l_current_row_element   EGO_USER_ATTR_ROW_OBJ;
  l_current_data_element    EGO_USER_ATTR_DATA_OBJ;
  l_ego_attr_group_request_obj  EGO_ATTR_GROUP_REQUEST_OBJ;
  l_ego_col_name_value_pair_obj      EGO_COL_NAME_VALUE_PAIR_OBJ;
  --l_attributes_data_table           EGO_USER_ATTR_DATA_TABLE;
  --l_attributes_row_table            EGO_USER_ATTR_ROW_TABLE;

  --Consolidated data and row tables
  --l_cons_attributes_data_table           EGO_USER_ATTR_DATA_TABLE;
  --l_cons_attributes_row_table            EGO_USER_ATTR_ROW_TABLE;

  Cursor get_dest_comps(p_src_comp_seq_id NUMBER, p_str_type_id NUMBER)
  IS
  SELECT bcb.component_sequence_id, bcb.bill_sequence_id
  FROM BOM_COMPONENTS_B bcb, BOM_STRUCTURES_B bsb
  WHERE bcb.common_component_sequence_id = p_src_comp_seq_id
  AND bcb.common_component_sequence_id <> bcb.component_sequence_id
  AND bsb.structure_type_id = p_str_type_id
  AND bsb.bill_sequence_id = bcb.bill_sequence_id
  ;

  Cursor get_structure_type(p_bill_seq_id NUMBER)
  IS
  SELECT structure_type_id
  FROM BOM_STRUCTURES_B
  WHERE bill_sequence_id = p_bill_seq_id;

  Cursor Get_Attribute_Groups(p_component_seq_id NUMBER, p_bill_seq_id NUMBER)
  IS
  SELECT ATTR_GROUP_ID
  FROM BOM_COMPONENTS_EXT_B
  WHERE component_sequence_id = p_component_seq_id
  AND bill_Sequence_id = p_bill_seq_id;

BEGIN
  SELECT bill_sequence_id
  into l_src_bill_seq_id
  from BOM_COMPONENTS_B
  where component_sequence_id = p_src_comp_seq_id;

  Open get_structure_type(p_bill_seq_id => l_src_bill_seq_id);
  Fetch get_structure_type into l_src_str_type;
  Close get_structure_type;

  l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(p_src_comp_seq_id))
                                                             ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(l_src_bill_seq_id)) );
  --Table to maintain the attr grp data
  --l_cons_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();

  --Table to maintain attributes data
  --l_cons_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();

  --For each attr grp, get data from source, and copy in the destn comp

  /*FOR attr_grp IN Get_Attribute_Groups(p_component_seq_id => p_src_comp_seq_id, p_bill_seq_id => l_src_bill_seq_id)
  loop*/
    --EMTAPIA: Start modification to support component uda data levels
    /*l_ego_attr_group_request_obj := EGO_ATTR_GROUP_REQUEST_OBJ(p_attr_grp_id, 702 ,'BOM_COMPONENTMGMT_GROUP',
                                    NULL,NULL,NULL,NULL , NULL, NULL, NULL,NULL);*/

    l_ego_attr_group_request_obj := EGO_ATTR_GROUP_REQUEST_OBJ(p_attr_grp_id, 702 ,'BOM_COMPONENTMGMT_GROUP',
                                    NULL,'COMPONENTS_LEVEL',NULL,NULL , NULL, NULL, NULL,NULL);

    --EMTAPIA: End modification to support component uda data levels

    l_attr_group_request_table :=   EGO_ATTR_GROUP_REQUEST_TABLE(l_ego_attr_group_request_obj);

     EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
      p_api_version                   => 1.0
     ,p_object_name                   => 'BOM_COMPONENTS'
     ,p_pk_column_name_value_pairs    => l_src_pk_col_name_val_pairs
     ,p_attr_group_request_table      => l_attr_group_request_table
     ,p_commit                        => FND_API.G_TRUE
     ,x_attributes_row_table          => l_attributes_row_table
     ,x_attributes_data_table         => l_attributes_data_table
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => l_errorcode
     ,x_msg_count                     => l_msg_count
     ,x_msg_data                      => l_msg_data
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
      fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
      Return;
     END IF;
  /*   IF l_attributes_row_table IS NOT NULL
     THEN
       l_cons_attributes_row_table.EXTEND;
       l_cons_attributes_row_table(l_row_table_index) := l_attributes_row_table(1);
       l_cons_attributes_row_table(l_row_table_index).ROW_IDENTIFIER := l_row_table_index;

       FOR i IN 1..l_attributes_data_table.COUNT
       LOOP
        l_cons_attributes_data_table.EXTEND;
        l_cons_attributes_data_table(l_data_table_index) := l_attributes_data_table(i);
        l_cons_attributes_data_table(l_data_table_index).ROW_IDENTIFIER := l_row_table_index;
        l_data_table_index := l_data_table_index + 1;
       END LOOP;

       l_row_table_index := l_row_table_index + 1;

     END IF; --l_attributes_row_table IS NOT NULL
*/
 -- end loop; --End for attr_grp IN Get_Attribute_Groups

    --Classification code
    l_new_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID', TO_CHAR(l_src_str_type)));
    FOR dest_comps in get_dest_comps(p_src_comp_seq_id => p_src_comp_seq_id, p_str_type_id => l_src_str_type)
    LOOP
      l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(dest_comps.component_sequence_id)),
                                                                  EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(dest_comps.bill_sequence_id)) );
      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data (
        p_api_version                   => 1.0
       ,p_object_name                   => 'BOM_COMPONENTS'
       ,p_attributes_row_table          => l_attributes_row_table
       ,p_attributes_data_table         => l_attributes_data_table
       ,p_pk_column_name_value_pairs    => l_dest_pk_col_name_val_pairs
       ,p_class_code_name_value_pairs   => l_new_str_type
       ,x_failed_row_id_list            => l_failed_row_count
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
       );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
        fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
        Return;
       END IF;
    END LOOP;
END;


/*
 * This Function is used to validate the operation seq num from the source bom
 * whenever a component is added to it.
 * @return boolean
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source bom.
 * @param p_op_seq IN Operation Sequence number
 */
Function Check_Op_Seq_In_Ref_Boms(p_src_bill_seq_id IN NUMBER
                                   , p_op_seq IN NUMBER)
Return boolean
IS

  Cursor get_related_bills(p_src_bill_sequence_id NUMBER) IS
  Select bill_sequence_id, organization_id, assembly_item_id, alternate_bom_designator
  from BOM_STRUCTURES_B
  where source_bill_sequence_id <> common_bill_sequence_id
  and source_bill_sequence_id = p_src_bill_sequence_id;


  Cursor get_rtg_opns(p_assy_item_id NUMBER, p_org_id NUMBER, p_alt_desg VARCHAR2)
  IS
  Select OPERATION_SEQ_NUM
  From BOM_OPERATION_SEQUENCES
  Where Routing_Sequence_Id = (Select common_routing_sequence_id
                               from bom_operational_routings
                               where assembly_item_id = p_assy_item_id
                               and organization_id = p_org_id
                               and nvl(alternate_routing_designator, 'XXX') = nvl(p_alt_desg, 'XXX'));

  l_rtg_exist varchar2(30) :=  null;
  l_stmt_num number;
  found boolean;
  valid_op_seq boolean;
  l_src_assy_item_id number;
  l_src_org_id number;
  l_src_alt varchar2(80);
  l_found_alt boolean := false;

BEGIN

  BEGIN
    Select 'Routing Exists'
    INTO l_rtg_exist
    from BOM_OPERATIONAL_ROUTINGS bor, BOM_STRUCTURES_B bom
    Where bom.assembly_item_id = bor.assembly_item_id
    And bom.organization_id = bor.organization_id
    And (nvl(bor.alternate_routing_designator, 'XXX') = nvl(bom.alternate_bom_designator, 'XXX')
         OR bor.alternate_routing_designator IS NULL
        )
    And bom.bill_sequence_id = p_src_bill_seq_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN TOO_MANY_ROWS THEN
      l_rtg_exist := 'Routing Exists';

  END;

  --If source routing does not exist or op seq entered is 1, no validation is requireed.
  IF l_rtg_exist is null
     OR p_op_seq = 1
  THEN
    return true;
  END IF;


  for bills in get_related_bills(p_src_bill_sequence_id => p_src_bill_seq_id)
  loop
    --Check if each of these bills has a corresponding routing and that routing in turn contains
    -- an operation of opn sequence specified by p_op_seq
    l_found_alt := false;
    found := false;
    for op_seq in get_rtg_opns(p_assy_item_id => bills.assembly_item_id,
                               p_org_id => bills.organization_id,
                               p_alt_desg => bills.alternate_bom_designator)
    loop
      l_found_alt := true;

      if p_op_seq = op_seq.OPERATION_SEQ_NUM
      then
        found := true;
      end if; --if p_op_seq = op_seq.OPERATION_SEQ_NUM

    end loop; --for op_seq in get_rtg_opns

    -- if alt rtg is not found, look in primary rtg
    if not l_found_alt
    then
      for op_seq in get_rtg_opns(p_assy_item_id => bills.assembly_item_id,
                                 p_org_id => bills.organization_id,
                                 p_alt_desg => null)
      loop
        if p_op_seq = op_seq.OPERATION_SEQ_NUM
        then
          found := true;
        end if; --if p_op_seq = op_seq.OPERATION_SEQ_NUM
      end loop; --for op_seq in get_rtg_opns
    end if;

    if not found
    then
      --the current op seq cant be used as at least one of the referecning bills' routing does not have the op seq
      return false;
    end if; --if not found

  end loop; --for bills in get_related_bills


  return true;
END;


--Bug 9356298 Start
/*
 * This Procedure is used to delete components as well as related ref desg and sub comps
 * from the non referencing boms when component
 * from the source bom is deleted.
 * @param p_src_comp_seq IN Component Sequence Id of the source component.
 */

Procedure Delete_Related_Components(p_src_comp_seq IN NUMBER)
IS
BEGIN

  IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('In Delete_Related_Components' ); END IF;
  DELETE FROM BOM_COMPONENTS_B
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq;

  DELETE FROM BOM_REFERENCE_DESIGNATORS
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq;

  DELETE FROM BOM_SUBSTITUTE_COMPONENTS
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq;

END Delete_Related_Components;

--Bug 9356298 End

/*
 * This Procedure is used to delete related ref desgs from the referencing boms when ref desg
 * from the source bom is deleted.
 * @param p_src_comp_seq IN Component Sequence Id of the source component.
 * @param p_ref_desg IN Ref Desg of the dest source component.
 */
Procedure Delete_Related_Ref_Desg(p_src_comp_seq IN NUMBER
                                  , p_ref_desg IN VARCHAR2
                                  , x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM BOM_REFERENCE_DESIGNATORS
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq
  AND COMPONENT_REFERENCE_DESIGNATOR = p_ref_desg;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

/*
 * This Procedure is used to delete related sub comps from the referencing boms when sub comps
 * from the source bom is deleted.
 * @param p_src_comp_seq IN Component Sequence Id of the source component.
 * @param p_sub_comp_item_id IN Sub Comp of the dest source component.
 */
Procedure Delete_Related_Sub_Comp(p_src_comp_seq IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER
                                  , x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM BOM_SUBSTITUTE_COMPONENTS
  WHERE COMMON_COMPONENT_SEQUENCE_ID = p_src_comp_seq
  AND SUBSTITUTE_COMPONENT_ID = p_sub_comp_item_id;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('BOM', 'BOM_PROPAGATE_FAILED');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


/*
 * This Function is used to dedetermine if the insert/update of replicated component records
 * caused an overlap in the destination bill.
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the dest bill.
 * @param p_dest_comp_seq_id IN Component Sequence Id of the dest component.
 * @param p_comp_item_id IN Inv item Id of the component.
 * @param p_op_seq_num IN Op Sequence num of the source component.
 * @param p_change_notice IN change notice of the source component.
 * @param p_eff_date IN Effectivity date of the source component.
 * @param p_disable_date IN disable date component.
 */
Function Check_Component_Overlap(p_dest_bill_sequence_id IN NUMBER
                                 , p_dest_comp_seq_id IN NUMBER
                                 , p_comp_item_id IN NUMBER
                                 , p_op_seq_num IN NUMBER
                                 , p_change_notice IN VARCHAR2
                                 , p_eff_date IN DATE
                                 , p_disable_date IN DATE
                                 , p_impl_date IN DATE
                                 , p_rev_item_seq_id IN NUMBER
                                 , p_src_bill_seq_id IN NUMBER
                                 )
Return Boolean
IS
  l_dummy NUMBER;
  l_rev_itm_bill_seq NUMBER;

BEGIN

  BEGIN
    SELECT bill_Sequence_id
    INTO l_rev_itm_bill_seq
    FROM eng_revised_items
    WHERE revised_item_sequence_id = p_rev_item_seq_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;
  END;

  IF p_impl_date is NULL
    AND l_rev_itm_bill_seq = p_src_bill_seq_id
  THEN

    SELECT 1
    INTO l_dummy
    FROM BOM_COMPONENTS_B bic
     WHERE bill_sequence_id  = p_dest_bill_sequence_id
       AND component_sequence_id <> p_dest_comp_seq_id
       AND component_item_id = p_comp_item_id
       AND operation_seq_num = p_op_seq_num
       AND (
             change_notice is not null
             and(
                 implementation_date is not null and p_change_notice is null
                 OR
                  (implementation_date is null and change_notice = p_change_notice
                   AND EXISTS(
                              SELECT 1 from eng_revised_items eri
                              where eri.revised_item_sequence_id = bic.revised_item_sequence_id
                              and eri.bill_Sequence_id =  l_rev_itm_bill_seq
                             )
                   )

                 )
              OR
                (change_notice is null and p_change_notice is null)
          )
       AND (
               ( p_disable_date IS NULL OR p_disable_date > effectivity_Date ) AND
               ( p_eff_date < disable_Date OR disable_Date IS NULL)
           )
       AND rownum = 1
       ;
  ELSE
    SELECT 1
    INTO l_dummy
    FROM BOM_COMPONENTS_B bic
     WHERE bill_sequence_id  = p_dest_bill_sequence_id
       AND component_sequence_id <> p_dest_comp_seq_id
       AND component_item_id = p_comp_item_id
       AND operation_seq_num = p_op_seq_num
       AND (
             change_notice is not null
             and(
                 implementation_date is not null and p_change_notice is null
                 OR
                  (implementation_date is null and change_notice = p_change_notice
                   AND EXISTS(
                              SELECT 1 from eng_revised_items eri
                              where eri.revised_item_sequence_id = bic.revised_item_sequence_id
                              and eri.bill_Sequence_id = bic.bill_Sequence_id
                             )
                   )

                 )
              OR
                (change_notice is null and p_change_notice is null)
          )
       AND (
               ( p_disable_date IS NULL OR p_disable_date > effectivity_Date ) AND
               ( p_eff_date < disable_Date OR disable_Date IS NULL)
           )
       AND rownum = 1
       ;
  END IF;
  RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Return false;

END;


Procedure Delete_Related_Pending_Comps(p_src_comp_seq_id IN NUMBER
                               , x_Return_Status IN OUT NOCOPY VARCHAR2)
IS

  l_impl_date     DATE;

BEGIN

/*  SELECT implementation_date
  INTO l_impl_date
  FROM BOM_COMPONENTS_B
  where component_sequence_id = p_src_comp_seq_id;

  IF l_impl_date IS NOT NULL
  THEN
    x_Return_Status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;
*/
--Commented
  DELETE BOM_COMPONENTS_B
  WHERE common_component_sequence_id = p_src_comp_seq_id;

  DELETE BOM_SUBSTITUTE_COMPONENTS
  WHERE common_component_sequence_id = p_src_comp_seq_id;

  DELETE BOM_REFERENCE_DESIGNATORS
  WHERE common_component_sequence_id = p_src_comp_seq_id;

  DELETE BOM_COMPONENT_OPERATIONS
  WHERE common_component_sequence_id = p_src_comp_seq_id;

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN
    x_Return_Status := FND_API.G_RET_STS_ERROR;
    app_exception.raise_exception;

END;

------------------------------------------------------------------------
--  API name    : Copy_Pending_Dest_Components                        --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_src_old_comp_seq_id  NUMBER Required              --
--                p_src_comp_seq_id      NUMBER Required              --
--                p_change_notice        vARCHAR2 Required            --
--                p_revised_item_sequence_id  NUMBER Required         --
--                p_effectivity_date     NUMBER Required              --
--       OUT    : x_return_status            VARCHAR2(1)              --
--  Version     : Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : This API is invoked only when a common bill has     --
--                pending changes associated for its WIP supply type  --
--                attributes and the common component in the source   --
--                bill is being implemented.                          --
--                API Copy_Revised_Item is called and then            --
--                A copy of all the destination changes are then made --
--                to this revised item with the effectivity range of  --
--                the component being implemented.                    --
------------------------------------------------------------------------

PROCEDURE Copy_Pending_Dest_Components (
    p_src_old_comp_seq_id IN NUMBER
  , p_src_comp_seq_id     IN NUMBER
  , p_change_notice       IN VARCHAR2
  , p_organization_id     IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_effectivity_date    IN DATE
  , x_return_status       OUT NOCOPY VARCHAR2
) IS

    --
    -- Cursor to fetch the pending components associated to the old component specified.
    -- The cursor is ordered by change notice and revised item sequence id so that the
    -- copying take place one revised item at a time and all its corresponding changes
    -- can be inserted in one go.
    --
    CURSOR c_pending_components ( cp_old_component_sequence_id NUMBER
                                , cp_bill_sequence_id NUMBER ) IS
    SELECT *
    FROM bom_components_b bcb
    WHERE bcb.old_component_sequence_id = cp_old_component_sequence_id
      AND bcb.bill_sequence_id = cp_bill_sequence_id
      AND bcb.implementation_date IS NULL
      -- The following exists clause is to ensure that the pending component is not a source
      -- referenced component but the one actually created for the destination bill itself
      AND EXISTS (SELECT 1 FROM eng_revised_items eri
                  WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
                    AND eri.change_notice= bcb.change_notice
                    AND eri.bill_sequence_id = bcb.bill_sequence_id)
    ORDER BY change_notice, revised_item_sequence_id;

    --
    -- Cursor to fetch the component being implemented wrt the detination bill
    -- for the change in the soruce bill
    --
    CURSOR c_related_components IS
    SELECT bcb.component_sequence_id, old_component_sequence_id, bill_sequence_id, effectivity_date
    FROM bom_components_b bcb
    WHERE bcb.change_notice = p_change_notice
    AND bcb.revised_item_sequence_id = p_revised_item_sequence_id
    AND bcb.common_component_sequence_id = p_src_comp_seq_id
    AND bcb.common_component_sequence_id <> bcb.component_sequence_id
    AND bcb.implementation_date IS NULL;


    l_component_rec         bom_components_b%ROWTYPE;
    l_dest_new_comp_seq_id  NUMBER;
    l_old_rev_item_seq_id   NUMBER;
    l_gen_rev_item_seq_id   NUMBER;
    l_return_status         VARCHAR2(1);
    l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_plsql_block           VARCHAR2(1000);

BEGIN
    --
    -- Initialize
    --
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_old_rev_item_seq_id := NULL;

    Eng_globals.Init_System_Info_Rec
    (   x_mesg_token_tbl    => l_mesg_token_tbl
    ,   x_return_status   => l_return_status
    );
    --
    -- Processing Begins
    -- For each destination component record that will be implemented
    --
    FOR c_dest_comp_rec IN c_related_components
    LOOP
        l_return_status := null;
        FOR l_component_rec IN c_pending_components (c_dest_comp_rec.old_component_sequence_id, c_dest_comp_rec.bill_sequence_id)
        LOOP

            IF l_old_rev_item_seq_id IS NULL
               OR l_old_rev_item_seq_id <> l_component_rec.revised_item_sequence_id
            THEN

                -- Generate a new reviseed item for the copies that are going to be inserted
                l_old_rev_item_seq_id := l_component_rec.revised_item_sequence_id;
                l_gen_rev_item_seq_id := NULL;
                l_plsql_block := 'Begin
                Eng_revised_Item_Util.Copy_revised_Item(
                    p_old_revised_item_seq_id => :1
                  , p_effectivity_date        => :2
                  , x_new_revised_item_seq_id => :3
                  , x_return_status           => :4
                 );
                End;';
                BEGIN
                    Execute Immediate l_plsql_block
                            USING  IN l_old_rev_item_seq_id
                                ,  IN p_effectivity_date
                                , OUT l_gen_rev_item_seq_id
                                --, OUT l_Mesg_Token_Tbl
                                , OUT l_return_status;
                EXCEPTION
                WHEN OTHERS THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                END;
            END IF;
            IF (l_return_status = 'S')
            THEN
                SELECT bom_inventory_components_s.NEXTVAL INTO l_dest_new_comp_seq_id FROM dual;
                -- changed values from other record
                l_component_rec.component_sequence_id       := l_dest_new_comp_seq_id;
                l_component_rec.old_component_sequence_id   := c_dest_comp_rec.component_sequence_id;
                l_component_rec.common_component_sequence_id := p_src_comp_seq_id;
                l_component_rec.revised_item_sequence_id    := l_gen_rev_item_seq_id;
                -- who columns
                l_component_rec.creation_date               := sysdate;
                l_component_rec.created_by                  := FND_PROFILE.value('USER_ID');
                l_component_rec.last_update_date            := sysdate;
                l_component_rec.last_updated_by             := FND_PROFILE.value('USER_ID');
                l_component_rec.last_update_login           := FND_PROFILE.value('LOGIN_ID');
                l_component_rec.request_id                  := FND_PROFILE.value('REQUEST_ID');
                l_component_rec.program_application_id      := FND_PROFILE.value('RESP_APPL_ID');
                l_component_rec.program_id                  := FND_PROFILE.value('PROGRAM_ID');
                l_component_rec.program_update_date         := sysdate;

                INSERT  INTO BOM_COMPONENTS_B
                  ( SUPPLY_SUBINVENTORY
                  , OPERATION_LEAD_TIME_PERCENT
                  , REVISED_ITEM_SEQUENCE_ID
                  , COST_FACTOR
                  , REQUIRED_FOR_REVENUE
                  , HIGH_QUANTITY
                  , COMPONENT_SEQUENCE_ID
                  , PROGRAM_APPLICATION_ID
                  , WIP_SUPPLY_TYPE
                  , SUPPLY_LOCATOR_ID
                  , BOM_ITEM_TYPE
                  , OPERATION_SEQ_NUM
                  , COMPONENT_ITEM_ID
                  , LAST_UPDATE_DATE
                  , LAST_UPDATED_BY
                  , CREATION_DATE
                  , CREATED_BY
                  , LAST_UPDATE_LOGIN
                  , ITEM_NUM
                  , COMPONENT_QUANTITY
                  , COMPONENT_YIELD_FACTOR
                  , COMPONENT_REMARKS
                  , EFFECTIVITY_DATE
                  , CHANGE_NOTICE
                  , IMPLEMENTATION_DATE
                  , DISABLE_DATE
                  , ATTRIBUTE_CATEGORY
                  , ATTRIBUTE1
                  , ATTRIBUTE2
                  , ATTRIBUTE3
                  , ATTRIBUTE4
                  , ATTRIBUTE5
                  , ATTRIBUTE6
                  , ATTRIBUTE7
                  , ATTRIBUTE8
                  , ATTRIBUTE9
                  , ATTRIBUTE10
                  , ATTRIBUTE11
                  , ATTRIBUTE12
                  , ATTRIBUTE13
                  , ATTRIBUTE14
                  , ATTRIBUTE15
                  , PLANNING_FACTOR
                  , QUANTITY_RELATED
                  , SO_BASIS
                  , OPTIONAL
                  , MUTUALLY_EXCLUSIVE_OPTIONS
                  , INCLUDE_IN_COST_ROLLUP
                  , CHECK_ATP
                  , SHIPPING_ALLOWED
                  , REQUIRED_TO_SHIP
                  , INCLUDE_ON_SHIP_DOCS
                  , INCLUDE_ON_BILL_DOCS
                  , LOW_QUANTITY
                  , ACD_TYPE
                  , OLD_COMPONENT_SEQUENCE_ID
                  , BILL_SEQUENCE_ID
                  , REQUEST_ID
                  , PROGRAM_ID
                  , PROGRAM_UPDATE_DATE
                  , PICK_COMPONENTS
                  , Original_System_Reference
                  , From_End_Item_Unit_Number
                  , To_End_Item_Unit_Number
                  , Eco_For_Production -- Added by MK
                  , Enforce_Int_Requirements
                  , Auto_Request_Material -- Added in 11.5.9 by ADEY
                  , Obj_Name -- Added by hgelli.
                  , pk1_value
                  , pk2_value
                  , Suggested_Vendor_Name --- Deepu
                  , Vendor_Id --- Deepu
                  --, Purchasing_Category_id --- Deepu
                  , Unit_Price --- Deepu
                  , from_object_revision_id
                  , from_minor_revision_id
                  --,component_item_revision_id
                  --,component_minor_revision_id
                  , common_component_sequence_id
                  , basis_type
                  , component_item_revision_id
                  ) VALUES
                  ( l_component_rec.supply_subinventory
                  , l_component_rec.OPERATION_LEAD_TIME_PERCENT  --check this
                  , l_component_rec.revised_item_sequence_id
                  , l_component_rec.cost_factor /* Cost Factor */
                  , l_component_rec.required_for_revenue
                  , l_component_rec.HIGH_QUANTITY
                  , l_component_rec.component_sequence_id
                  , l_component_rec.program_application_id
                  , l_component_rec.wip_supply_type
                  , l_component_rec.supply_locator_id
                  , l_component_rec.bom_item_type
                  , l_component_rec.operation_seq_num    --Check this too
                  , l_component_rec.component_item_id
                  , SYSDATE /* Last Update Date */
                  , l_component_rec.last_updated_by /* Last Updated By */
                  , SYSDATE /* Creation Date */
                  , l_component_rec.created_by /* Created By */
                  , l_component_rec.last_update_login /* Last Update Login */
                  , l_component_rec.ITEM_NUM
                  , l_component_rec.component_quantity
                  , l_component_rec.COMPONENT_YIELD_FACTOR
                  , l_component_rec.COMPONENT_REMARKS
                  , nvl(l_component_rec.effectivity_date,SYSDATE)    --2169237
                  , l_component_rec.Change_Notice
                  , l_component_rec.implementation_date/* Implementation Date */
                  , l_component_rec.disable_date
                  , l_component_rec.attribute_category
                  , l_component_rec.attribute1
                  , l_component_rec.attribute2
                  , l_component_rec.attribute3
                  , l_component_rec.attribute4
                  , l_component_rec.attribute5
                  , l_component_rec.attribute6
                  , l_component_rec.attribute7
                  , l_component_rec.attribute8
                  , l_component_rec.attribute9
                  , l_component_rec.attribute10
                  , l_component_rec.attribute11
                  , l_component_rec.attribute12
                  , l_component_rec.attribute13
                  , l_component_rec.attribute14
                  , l_component_rec.attribute15
                  , l_component_rec.planning_factor
                  , l_component_rec.quantity_related
                  , l_component_rec.so_basis
                  , l_component_rec.optional
                  , l_component_rec.mutually_exclusive_options
                  , l_component_rec.include_in_cost_rollup
                  , l_component_rec.check_atp
                  , l_component_rec.shipping_allowed
                  , l_component_rec.required_to_ship
                  , l_component_rec.include_on_ship_docs
                  , l_component_rec.include_on_bill_docs /* Include On Bill Docs */
                  , l_component_rec.low_quantity
                  , l_component_rec.acd_type
                  , l_component_rec.old_component_sequence_id  --Chk this
                  , l_component_rec.bill_sequence_id
                  , l_component_rec.request_id
                  , l_component_rec.program_id
                  , SYSDATE /* program_update_date */
                  , l_component_rec.pick_components
                  , l_component_rec.original_system_reference
                  , l_component_rec.from_end_item_unit_number
                  , l_component_rec.to_end_item_unit_number
                  , l_component_rec.Eco_For_Production
                  , l_component_rec.Enforce_Int_Requirements
                  , l_component_rec.auto_request_material -- Added in 11.5.9 by ADEY
                  , NULL-- Added by hgelli. Identifies this record as Bom Component.
                  , l_component_rec.component_item_id
                  , p_organization_id
                  , l_component_rec.Suggested_Vendor_Name --- Deepu
                  , l_component_rec.Vendor_Id --- Deepu
                  --, p_rev_component_rec.purchasing_category_id --- Deepu
                  , l_component_rec.Unit_Price --- Deepu
                  , l_component_rec.from_object_revision_id
                  , l_component_rec.from_minor_revision_id
                  , l_component_rec.common_component_sequence_id
                  , l_component_rec.basis_type
                  , decode(l_component_rec.component_item_revision_id,
                           NULL, NULL,
                           BOMPCMBM.get_rev_id_for_local_org(l_component_rec.component_item_revision_id, p_organization_id))
                  --, l_comp_revision_id
                  --, l_comp_minor_revision_id
                );
            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            END IF;
        END LOOP;
    END LOOP;
    x_return_status := l_return_status;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Copy_Pending_Dest_Components;



PROCEDURE check_comp_rev_in_local_org(p_src_bill_seq_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
IS
  l_rev_count NUMBER;
  l_comp_count NUMBER;
BEGIN

  SELECT count(*)
  INTO l_comp_count
  FROM bom_components_b
  WHERE bill_sequence_id = p_src_bill_seq_id
  AND COMPONENT_ITEM_REVISION_ID IS NOT NULL;

  IF l_comp_count > 0
  THEN
    SELECT count(*)
    INTO l_rev_count
    FROM MTL_ITEM_REVISIONS_B source, MTL_ITEM_REVISIONS_B dest
    WHERE source.inventory_item_id = dest.inventory_item_id
    AND source.revision_id IN (SELECT COMPONENT_ITEM_REVISION_ID
                               FROM BOM_COMPONENTS_B
                               WHERE BILL_SEQUENCE_ID = p_src_bill_seq_id)
    AND dest.organization_id = p_org_id
    AND source.revision = dest.revision;

    IF l_comp_count <> l_rev_count
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;



/*
 * This function will return the corresponding revision id
 * in the local org for the revision passed.
 */
Function get_rev_id_for_local_org(p_rev_id IN NUMBER, p_org_id IN NUMBER)
Return NUMBER
IS
  l_rev_id NUMBER;
BEGIN
  SELECT dest.revision_id
  INTO l_rev_id
  FROM MTL_ITEM_REVISIONS_B src, MTL_ITEM_REVISIONS_B dest
  WHERE dest.inventory_item_id = src.inventory_item_id
  AND dest.organization_id = p_org_id
  AND dest.revision = src.revision
  AND src.revision_id = p_rev_id;

  RETURN l_rev_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  Return NULL;

END;


/**
 * This function validates the fixed revision of a component
 * wrt common boms in different organizations.
 */

Function Check_comp_rev_for_Com_Boms(p_rev_id IN NUMBER, p_src_bill_seq_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR get_orgs IS
  SELECT DISTINCT organization_id
  FROM bom_structures_b
  WHERE source_bill_Sequence_id = p_src_bill_seq_id;

BEGIN
  FOR org IN get_orgs
  LOOP
    IF get_rev_id_for_local_org(p_rev_id => p_rev_id, p_org_id => org.organization_id) IS NULL
    THEN
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END LOOP;
  RETURN FND_API.G_RET_STS_SUCCESS;
END;

END bompcmbm ;

/
