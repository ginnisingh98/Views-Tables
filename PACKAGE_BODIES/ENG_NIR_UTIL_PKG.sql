--------------------------------------------------------
--  DDL for Package Body ENG_NIR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_NIR_UTIL_PKG" AS
/* $Header: ENGNIRB.pls 120.20 2007/07/16 12:12:06 sdarbha ship $ */
PROCEDURE set_nir_item_approval_status (
	p_change_id  	IN NUMBER,
	p_approval_status IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2) IS

type item_id_col is table of NUMBER;
type appr_status_col is table of VARCHAR2(1);
type org_id_col is table of NUMBER;

l_items_array item_id_col;
l_appr_statuses_array appr_status_col;
l_org_id_array org_id_col ;
l_approval_status VARCHAR2(1);
l_ret_item_app_st INTEGER;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF p_approval_status = 1 THEN
		l_approval_status := 'N';
	ELSIF p_approval_status = 3 THEN
		l_approval_status := 'S';
	ELSIF p_approval_status IN (4, 8) THEN
		l_approval_status := 'R';
     ELSIF p_approval_status IN (5) THEN
		l_approval_status := 'A';
	END IF;
	--IF p_approval_status IN (1,3,4, 8)  THEN

		Select	sub.pk1_value,
			sub.pk2_value
     BULK COLLECT into	l_items_array,
			l_org_id_array
		  from	eng_change_subjects sub ,
			eng_change_lines lines
		 where	lines.change_id = p_change_id
		   and lines.change_id = sub.change_id
       and lines.change_line_id = sub.change_line_id
		   and lines.STATUS_CODE not in (G_ENG_NEW_ITEM_REJECTED, G_ENG_NEW_ITEM_CANCELLED)
		   and entity_name='EGO_ITEM';
--	ELSIF p_approval_status = 5 THEN

	/*	Select	sub.pk1_value,
			sub.pk2_value
     BULK COLLECT into	l_items_array,
			l_org_id_array
		--	l_appr_statuses_array
		  from	eng_change_subjects sub ,
			eng_change_lines lines
		 where	lines.change_id = p_change_id
		   and lines.change_id = sub.change_id
		   and lines.STATUS_CODE not in (5, 14)
		   and entity_name='EGO_ITEM';*/

--	END IF;
	for i in l_items_array.FIRST .. l_items_array.LAST
	LOOP
		--IF p_approval_status IN (1,3,4, 8) then

--			l_ret_item_app_st := EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS(l_items_array(i),
			EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS(l_items_array(i),
						   l_org_id_array(i),
						   l_approval_status,
                                                   p_change_id);
			IF p_approval_status IN (4,8) THEN
				UPDATE eng_change_lines
				   SET STATUS_CODE = G_ENG_NEW_ITEM_REJECTED
				 WHERE change_id = p_change_id
		   		   AND status_CODE not in(G_ENG_NEW_ITEM_REJECTED,G_ENG_NEW_ITEM_CANCELLED);
      ELSIF p_approval_status = 3 THEN
				UPDATE eng_change_lines
				   SET STATUS_CODE = G_ENG_NEW_ITEM_SFA
				 WHERE change_id = p_change_id
		   		   AND status_CODE not in(G_ENG_NEW_ITEM_REJECTED,G_ENG_NEW_ITEM_CANCELLED);
      ELSIF p_approval_status IN (5) THEN
				UPDATE eng_change_lines
				   SET STATUS_CODE = G_ENG_NEW_ITEM_APPROVED
				 WHERE change_id = p_change_id
		   		   AND status_CODE not in(G_ENG_NEW_ITEM_REJECTED,G_ENG_NEW_ITEM_CANCELLED);

			END IF;

	/*	ELSIF p_approval_status = 5 THEN

			UPDATE_ITEM_APPROVAL_STATUS(l_items_array(i),
						   l_org_id_array(i),
						   l_approval_status); */

	--	END IF;
	END LOOP;


EXCEPTION WHEN others  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
/*FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS '||'itemId: '||l_item_id||' OrgId: '||l_organization_id|| ' approvalStstus: '||l_approval_status);
                FND_MSG_PUB.Add;*/

END set_nir_item_approval_status;

PROCEDURE Cancel_NIR(
                    p_change_id IN NUMBER,
                    p_org_id IN NUMBER,
                    p_change_notice IN VARCHAR2,
                    p_auto_commit IN VARCHAR2,
                   -- p_item_action IN VARCHAR2 DEFAULT NULL,
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_check_security IN BOOLEAN DEFAULT TRUE,
                    x_nir_cancel_status OUT NOCOPY VARCHAR2
                    )
IS
     l_wf_item_type VARCHAR2(8);
     l_wf_item_key VARCHAR2(240);
     l_wf_process_name VARCHAR2(30);
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER ;
     l_msg_data VARCHAR2(200);
     l_action_id eng_change_actions.action_id%TYPE;
     l_chk_fn_ret_val VARCHAR2(10);
     l_party_id NUMBER;
     l_inventory_item_id VARCHAR2(100); --   ENG_CHANGE_SUBJECTS.PK1_VALUE
     l_organization_id VARCHAR2(100);   --   ENG_CHANGE_SUBJECTS.PK2_VALUE

BEGIN

     x_nir_cancel_status := 'TRUE';
     --   First check whether user has edit privilege on this change or not.
     SELECT PERSON_ID into l_party_id FROM EGO_PEOPLE_V WHERE USER_ID = p_wf_user_id;
/*
     IF p_check_security = TRUE THEN
          l_chk_fn_ret_val := EGO_DATA_SECURITY.check_function
               (
                    p_api_version=>1.0,
                    p_function => 'ENG_EDIT_CHANGE',
                    p_object_name => 'ENG_CHANGE',
                    p_instance_pk1_value => p_change_id,
--                  p_instance_pk2_value => p_instance_pk2_value,
--                  p_instance_pk3_value => p_instance_pk3_value,
--                  p_instance_pk4_value => p_instance_pk4_value,
--                  p_instance_pk5_value => p_instance_pk5_value,
                    p_user_name => 'HZ_PARTY:' || l_party_id
		     );

          --   If the User does not have direct roles for Editing this NIR, We have to check for Inherited roles.
          IF NOT 'T' = l_chk_fn_ret_val THEN
               --   Get the Inventory Item Id and Organization Id of the Item
               SELECT PK1_VALUE, PK2_VALUE INTO l_inventory_item_id, l_organization_id
               FROM ENG_CHANGE_SUBJECTS
               WHERE ENTITY_NAME = 'EGO_ITEM' AND CHANGE_ID = p_change_id;

               l_chk_fn_ret_val := EGO_DATA_SECURITY.check_inherited_function
                 (
                  p_api_version                   => 1.0,
                  p_function                      => 'ENG_EDIT_CHANGE',
                  p_object_name                   => 'ENG_CHANGE',
                  p_instance_pk1_value            => p_change_id,
--                p_instance_pk2_value            => p_org_id,
--                p_instance_pk3_value            => p_instance_pk3_value,
--                p_instance_pk4_value            => p_instance_pk4_value,
--                p_instance_pk5_value            => p_instance_pk5_value,
                  p_user_name                     => 'HZ_PARTY:' || l_party_id,
                  p_object_type                   => 'NEW_ITEM_REQUEST',
                  p_parent_object_name            => 'EGO_ITEM',
                  p_parent_instance_pk1_value     => l_inventory_item_id,
                  p_parent_instance_pk2_value     => l_organization_id
--                p_parent_instance_pk3_value     => p_parent_instance_pk3_value,
--                p_parent_instance_pk4_value     => p_parent_instance_pk4_value,
--                p_parent_instance_pk5_value     => p_parent_instance_pk5_value
                );
          END IF;
     ELSE
          l_chk_fn_ret_val := 'T';
     END IF;

     IF NOT 'T' = l_chk_fn_ret_val THEN
          x_nir_cancel_status := 'ACCESS_DENIED';
          RETURN;
     END IF;
*/
     BEGIN
     --   First check whether any workflow is running for this NIR.
     --   If running, then abort the workflow.
     SELECT WF_ITEM_TYPE, WF_ITEM_KEY, WF_PROCESS_NAME
     INTO l_wf_item_type, l_wf_item_key, l_wf_process_name
     FROM ENG_CHANGE_ROUTES WHERE OBJECT_ID1 = p_change_id AND status_code = 'IN_PROGRESS';

     IF SQL%FOUND THEN

          Eng_Workflow_Util.AbortWorkflow
          (
            p_api_version      =>    1.0
          , p_init_msg_list    =>    FND_API.G_FALSE
          , p_commit           =>    p_auto_commit
          , p_validation_level =>    FND_API.G_VALID_LEVEL_FULL
          , x_return_status    =>    l_return_status
          , x_msg_count        =>    l_msg_count
          , x_msg_data         =>    l_msg_data
          , p_item_type        =>    l_wf_item_type
          , p_item_key         =>    l_wf_item_key
          , p_process_name     =>    l_wf_process_name
          , p_wf_user_id       =>    p_wf_user_id
          , p_debug            =>    FND_API.G_FALSE
          , p_output_dir       =>    NULL
          , p_debug_filename   =>    'Eng_ChangeWF_Abort.log'
          );

     END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
     END;
     --   Cancel the NIR
     ENG_CANCEL_ECO.Cancel_Eco
     (
         org_id                 =>    p_org_id,
         change_order           =>    p_change_notice,
         user_id                =>    p_wf_user_id,
         login                  =>    p_fnd_user_id
     );

     --   We need to set the status of the NIR Manually. Even in the UI flow it is set manually.
     UPDATE ENG_ENGINEERING_CHANGES
     SET STATUS_TYPE = 5, STATUS_CODE = 5, CANCELLATION_DATE = sysdate, CANCELLATION_COMMENTS = p_cancel_comments
     WHERE CHANGE_ID = p_change_id;

     x_nir_cancel_status := 'TRUE';

     --   Create action log entries for the Cancel action.
     ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
     (
          p_api_version          =>    1.0,
          p_init_msg_list        =>    FND_API.G_TRUE,
          p_commit               =>    FND_API.G_FALSE,
          p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL,
          p_debug                =>    FND_API.G_FALSE,
          p_output_dir           =>    '',
          p_debug_filename       =>    '',
          x_return_status        =>    l_return_status,
          x_msg_count            =>    l_msg_count,
          x_msg_data             =>    l_msg_data,
          p_object_id1           =>    p_change_id,
          p_object_id2           =>    NULL,
          p_object_name          =>    'ENG_CHANGE',
          p_action_type          =>    'CANCEL',
          p_parent_action_id     =>    -1,
          p_change_description   =>    p_cancel_comments,
          x_change_action_id     =>    l_action_id
     );

     EXCEPTION
          WHEN OTHERS THEN
               x_nir_cancel_status := 'FALSE';

END Cancel_NIR;


PROCEDURE Cancel_NIR_FOR_ITEM(
                    p_item_id IN NUMBER,
                    p_org_id IN NUMBER,
--		    p_item_number IN VARCHAR2,
                    p_auto_commit IN VARCHAR2,
--		    p_mode        IN VARCHAR2,
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_check_security IN BOOLEAN DEFAULT TRUE,
                    x_nir_cancel_status OUT NOCOPY VARCHAR2
                    )

IS
     l_uncancelled_change_id NUMBER;
     CURSOR c_nirs_for_this_item IS
     SELECT A.CHANGE_ID, B.CHANGE_NOTICE
     FROM ENG_CHANGE_SUBJECTS A,
          ENG_ENGINEERING_CHANGES B,
          ENG_CHANGE_LINES LINES
     WHERE A.PK1_VALUE = p_item_id
       AND A.PK2_VALUE = p_org_id
       AND A.ENTITY_NAME = 'EGO_ITEM'
       AND A.CHANGE_LINE_ID = LINES.CHANGE_LINE_ID
       AND LINES.CHANGE_ID = B.CHANGE_ID
       AND A.CHANGE_ID = B.CHANGE_ID
       AND LINES.STATUS_CODE NOT IN (G_ENG_NEW_ITEM_CANCELLED, G_ENG_NEW_ITEM_REJECTED);

       l_chk_fn_ret_val VARCHAR2(10);
       l_party_id NUMBER;
       l_cancel_comments VARCHAR2(32767);

BEGIN
--     p_check_security := TRUE;
     SELECT PERSON_ID into l_party_id FROM EGO_PEOPLE_V WHERE USER_ID = p_wf_user_id;

     --   Query all the NIRs for this Item in this Organization and Cancel them.
     FOR nirs IN c_nirs_for_this_item
     LOOP

          --   First check whether the user has cancel/edit privilege to cancel the line or NIR
          IF p_check_security = TRUE THEN
               l_chk_fn_ret_val := EGO_DATA_SECURITY.check_function
                    (
                         p_api_version=>1.0,
                         p_function => 'ENG_EDIT_CHANGE',
                         p_object_name => 'ENG_CHANGE',
                         p_instance_pk1_value => nirs.change_id,
     --                  p_instance_pk2_value => p_instance_pk2_value,
     --                  p_instance_pk3_value => p_instance_pk3_value,
     --                  p_instance_pk4_value => p_instance_pk4_value,
     --                  p_instance_pk5_value => p_instance_pk5_value,
                         p_user_name => 'HZ_PARTY:' || l_party_id
                    );

               --   If the User does not have direct roles for Editing this NIR, We have to check for Inherited roles.
               IF NOT 'T' = l_chk_fn_ret_val THEN
                    --   Get the Inventory Item Id and Organization Id of the Item
                    l_chk_fn_ret_val := EGO_DATA_SECURITY.check_inherited_function
                      (
                       p_api_version                   => 1.0,
                       p_function                      => 'ENG_EDIT_CHANGE',
                       p_object_name                   => 'ENG_CHANGE',
                       p_instance_pk1_value            => nirs.change_id,
     --                p_instance_pk2_value            => p_org_id,
     --                p_instance_pk3_value            => p_instance_pk3_value,
     --                p_instance_pk4_value            => p_instance_pk4_value,
     --                p_instance_pk5_value            => p_instance_pk5_value,
                       p_user_name                     => 'HZ_PARTY:' || l_party_id,
                       p_object_type                   => 'NEW_ITEM_REQUEST',
                       p_parent_object_name            => 'EGO_ITEM',
                       p_parent_instance_pk1_value     => p_item_id,
                       p_parent_instance_pk2_value     => p_org_id
     --                p_parent_instance_pk3_value     => p_parent_instance_pk3_value,
     --                p_parent_instance_pk4_value     => p_parent_instance_pk4_value,
     --                p_parent_instance_pk5_value     => p_parent_instance_pk5_value
                     );
               END IF;
          ELSE
               l_chk_fn_ret_val := 'T';
          END IF;
          IF NOT 'T' = l_chk_fn_ret_val THEN
               x_nir_cancel_status := 'ACCESS_DENIED';
               RETURN;
          END IF;
          Cancel_NIR_Line_Item( p_change_id       => nirs.change_id,
                                p_item_id         => p_item_id,
                                p_org_id          => p_org_id,
                             --   p_mode            => p_item_action,    --   (DELETE/CHANGE_ICC)
                                p_wf_user_id      => p_wf_user_id,
                                p_fnd_user_id     => p_fnd_user_id,
                                p_cancel_comments => p_cancel_comments,
                                P_COMMIT          => FND_API.G_FALSE,
                                x_return_status   => x_nir_cancel_status
                     );
         select count(change_id) into l_uncancelled_change_id
         from eng_change_lines where change_id = nirs.change_id
         and status_code <> 5;
      if l_uncancelled_change_id = 0
      then

           FND_MESSAGE.SET_NAME('ENG', 'ENG_NIR_CANCELLED_COMMENT');
           l_cancel_comments := FND_MESSAGE.GET;

          Cancel_NIR(p_change_id             => nirs.CHANGE_ID,
                     p_org_id                => p_org_id,
                     p_change_notice         => nirs.CHANGE_NOTICE,
                     p_auto_commit           => p_auto_commit,
                     p_wf_user_id            => p_wf_user_id,
                     p_fnd_user_id           => p_fnd_user_id,
                     p_cancel_comments       => l_cancel_comments,
--                     p_check_security        => p_check_security,
                     p_check_security        => TRUE,
                     x_nir_cancel_status     => x_nir_cancel_status
                     );
      end if;
     END LOOP;

END Cancel_NIR_FOR_ITEM;

PROCEDURE Delete_Child_Associations(
                    p_parent_icc_id IN NUMBER,
                    p_item_catalog_group_ids IN VARCHAR2,
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_commit IN VARCHAR2
                    )
IS
     l_delete_assocs_stmt VARCHAR2(32767);
     i NUMBER;
     l_child_item_catalog_group_id VARCHAR2(80);
     l_parent_item_catalog_group_id VARCHAR2(1000);
     l_parent_assoc_creation_date VARCHAR2(1000);
     l_parent_route_people_id NUMBER;
     l_parent_attr_group_id NUMBER;

     CURSOR cur_child_icc_assocs IS
          SELECT assoc_obj_pk1_value, route_people_id, object_id1, To_Char(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS') creation_date
          FROM ENG_CHANGE_ROUTE_ASSOCS WHERE ASSOC_OBJ_PK1_VALUE = p_parent_icc_id;

BEGIN
     IF p_parent_icc_id IS NOT NULL THEN
          --   Following code will be called when the AG association is deleted from the ICC directly
          IF p_route_people_id IS NOT NULL AND p_attribute_group_id IS NOT NULL THEN
               i := 1;
               LOOP
                    l_child_item_catalog_group_id := Tokenize( p_item_catalog_group_ids, i , ',') ;
                    EXIT WHEN l_child_item_catalog_group_id IS NULL ;

                    --   We need to check whether the same AG is not associated for the Child ICC directly
                    --   If AG is associated directly to the Child ICC then the creation date will be different as parent's
                    --   else creation date will be same as parent's
                    SELECT To_Char(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS') INTO l_parent_assoc_creation_date FROM ENG_CHANGE_ROUTE_ASSOCS
                    WHERE ASSOC_OBJ_PK1_VALUE = p_parent_icc_id
                    AND ROUTE_PEOPLE_ID = p_route_people_id
                    AND OBJECT_ID1 = p_attribute_group_id;

                    DELETE FROM ENG_CHANGE_ROUTE_ASSOCS
                    WHERE ASSOC_OBJ_PK1_VALUE = l_child_item_catalog_group_id
                    AND ASSOC_OBJ_PK1_VALUE <> p_parent_icc_id
                    AND ROUTE_PEOPLE_ID = p_route_people_id
                    AND OBJECT_ID1 = p_attribute_group_id
                    AND To_Char(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS') = l_parent_assoc_creation_date; -- Delete only if AG assoc is inherited : if inherited then the creation date will be same
--                    AND CREATION_DATE = l_parent_assoc_creation_date;
--                    AND ADHOC_ASSOC_FLAG = 'N'; -- Child ICCs can add more associations, those should not be deleted

                    i := i + 1;
               END LOOP;
--               EXECUTE IMMEDIATE l_delete_assocs_stmt USING p_item_catalog_group_ids, p_route_people_id, p_attribute_group_id;
          ELSE
               --   Following code will be called from API when the ICC NIR setp is changed
               FOR rec IN cur_child_icc_assocs
               LOOP
                    DELETE FROM ENG_CHANGE_ROUTE_ASSOCS WHERE ROUTE_ASSOCIATION_ID IN (
                         SELECT ROUTE_ASSOCIATION_ID FROM (
                         SELECT a.route_association_id,
                         b.item_catalog_group_id,
                         b.parent_catalog_group_id,
                         b.NEW_ITEM_REQUEST_REQD
                         FROM eng_change_route_assocs a, mtl_item_catalog_groups_v b
                         WHERE a.assoc_obj_pk1_value = b.item_catalog_group_id
                         AND a.object_id1= rec.object_id1
                         AND To_Char(a.CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS') = rec.creation_date
                         ) CONNECT BY PRIOR item_catalog_group_id = parent_catalog_group_id AND NEW_ITEM_REQUEST_REQD =  'I'
                         START WITH   item_catalog_group_id = rec.assoc_obj_pk1_value );
               END LOOP;
          END IF;
     END IF;

--     IF p_commit = 'TRUE' THEN
--     commit;
--     END IF;

EXCEPTION
     WHEN OTHERS THEN
          NULL;

END Delete_Child_Associations;

--   Duplicate Validation still to be done while creating the associations like this.     Done
/*
     First Part of the Following API will be called when the ICC NIR setup is changed
     This will do a mass creation of the AG Associations for all the Child ICCs given
     Second Part of the Following API will be created when an attribute group association is created for an ICC
     It will propagate the association to all the ICC's child ICCs.

*/
PROCEDURE Create_Child_Associations(
                    p_source_item_catalog_group_id IN VARCHAR2,
                    p_parent_item_catalog_group_id IN VARCHAR2,
                    p_child_item_catalog_group_ids IN VARCHAR2,
                    --   following parameters will be used while calling only when the AG is associated to ICC directly
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_assoc_creation_date IN DATE DEFAULT NULL,
                    p_assoc_created_by IN NUMBER DEFAULT NULL,
                    p_assoc_last_update_date IN DATE DEFAULT NULL,
                    p_assoc_last_update_login IN NUMBER DEFAULT NULL,
                    p_assoc_last_updated_by IN NUMBER DEFAULT NULL,
                    p_commit IN VARCHAR2
                    )
IS
     l_create_assocs_stmt VARCHAR2(32767);
     l_child_item_catalog_group_id VARCHAR2(1000);
     i NUMBER;
     k NUMBER;
     l_route_association_id        ENG_CHANGE_ROUTE_ASSOCS.ROUTE_ASSOCIATION_ID%TYPE;
     l_source_icc_id VARCHAR2(1000);
     l_child_icc_ids VARCHAR2(32767);

     CURSOR cur_parent_icc_ag_associations IS
          SELECT
               ROUTE_PEOPLE_ID, ASSOC_OBJECT_NAME, ASSOC_OBJ_PK1_VALUE, ASSOC_OBJ_PK2_VALUE, ASSOC_OBJ_PK3_VALUE, ASSOC_OBJ_PK4_VALUE,
               ASSOC_OBJ_PK5_VALUE, ADHOC_ASSOC_FLAG, OBJECT_NAME, OBJECT_ID1, OBJECT_ID2, OBJECT_ID3, OBJECT_ID4, OBJECT_ID5, CREATION_DATE,
               CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_ID, PROGRAM_APPLICATION_ID,
               PROGRAM_UPDATE_DATE, ORIGINAL_SYSTEM_REFERENCE
          FROM ENG_CHANGE_ROUTE_ASSOCS
          WHERE ASSOC_OBJ_PK1_VALUE = l_source_icc_id;

BEGIN
     IF p_source_item_catalog_group_id IS NOT NULL THEN
          --   p_source_item_catalog_group_id This will not be null when an ICC NIR setup is set to Inherit From Parent and
          --   it has a Parent ICC with some associations and some child ICCs. Then the Parent's associations should be copied
          --   to it and its Children
          l_source_icc_id := p_source_item_catalog_group_id;
          l_child_icc_ids := p_child_item_catalog_group_ids;
          --   Check if there are child ICCs for which the association to be propagated, if so append
/*
          IF p_child_item_catalog_group_ids IS NULL OR p_child_item_catalog_group_ids = '' THEN
               l_child_icc_ids := p_parent_item_catalog_group_id;
          ELSE
               l_child_icc_ids := p_child_item_catalog_group_ids || ',' || p_parent_item_catalog_group_id;
          END IF;
*/
     ELSE
          l_source_icc_id := p_parent_item_catalog_group_id;
          l_child_icc_ids := p_child_item_catalog_group_ids;
     END IF;
     --   First Part : Mass Update
     IF l_child_icc_ids IS NOT NULL THEN

          i := 1;
          -- Query all the Parent ICC Associations.
          IF p_route_people_id IS NULL AND p_attribute_group_id IS NULL THEN
               FOR ag_association IN cur_parent_icc_ag_associations LOOP
                    i := 1;
                    LOOP
                         --   For each Child ICC, create the attribute groups associations.
                         l_child_item_catalog_group_id := Tokenize( l_child_icc_ids, i , ',') ;
                         EXIT WHEN l_child_item_catalog_group_id IS NULL ;
                         IF ag_association.object_id1 IS NOT NULL THEN
                              --   First check if there is already an association for this AG at the Child ICC.
                              --   Association Unique combination (ASSOC_OBJ_PK1_VALUE, ROUTE_PEOPLE_ID, OBJECT_ID1)
                              SELECT count(route_association_id) INTO k
                              FROM ENG_CHANGE_ROUTE_ASSOCS
                              WHERE ASSOC_OBJ_PK1_VALUE = l_child_item_catalog_group_id
                              AND ROUTE_PEOPLE_ID = ag_association.route_people_id
                              AND OBJECT_ID1 = ag_association.object_id1;
                              IF k = 0 OR k IS NULL THEN    --   Create association only if it already does not exist
                                   --   Get the Association Id from Sequence.
                                   SELECT ENG_CHANGE_ROUTE_ASSOCS_S.NEXTVAL INTO l_route_association_id FROM DUAL;
                                   --   For each Parent ICC's association, create an association in the Child ICC.
                                   INSERT INTO ENG_CHANGE_ROUTE_ASSOCS (ROUTE_ASSOCIATION_ID, ROUTE_PEOPLE_ID, ASSOC_OBJECT_NAME, ASSOC_OBJ_PK1_VALUE,
                                        ASSOC_OBJ_PK2_VALUE, ASSOC_OBJ_PK3_VALUE, ASSOC_OBJ_PK4_VALUE, ASSOC_OBJ_PK5_VALUE, ADHOC_ASSOC_FLAG,
                                        OBJECT_NAME, OBJECT_ID1, OBJECT_ID2, OBJECT_ID3, OBJECT_ID4, OBJECT_ID5, CREATION_DATE, CREATED_BY,
                                        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_ID, PROGRAM_APPLICATION_ID,
                                        PROGRAM_UPDATE_DATE, ORIGINAL_SYSTEM_REFERENCE)
                                   VALUES (l_route_association_id, ag_association.route_people_id, ag_association.assoc_object_name,
                                        l_child_item_catalog_group_id, ag_association.assoc_obj_pk2_value, ag_association.assoc_obj_pk3_value,
                                        ag_association.assoc_obj_pk4_value, ag_association.assoc_obj_pk5_value, 'N',
                                        ag_association.object_name, ag_association.object_id1, ag_association.object_id2, ag_association.object_id3,
                                        ag_association.object_id4, ag_association.object_id5, ag_association.creation_date, ag_association.created_by,
                                        ag_association.last_update_date, ag_association.last_updated_by, ag_association.last_update_login,
                                        ag_association.request_id, ag_association.program_id, ag_association.program_application_id,
                                        ag_association.program_update_date, ag_association.original_system_reference);
                              END IF;   --   if k = 0 then
                         END IF;
                         i := i + 1;
                         k := 0;
                    END LOOP; --   Child ICCs
               END LOOP ;    -- Parent's associations : For Cursor Loop
          END IF;

          --   Second Part : Single Attribute group creation propagation
          --   Will be called when an attribute group is associated for the parent ICC
          IF p_route_people_id IS NOT NULL AND p_attribute_group_id IS NOT NULL THEN
               i := 1;
               LOOP
                    l_child_item_catalog_group_id := Tokenize( l_child_icc_ids, i , ',') ;
                    EXIT WHEN l_child_item_catalog_group_id IS NULL ;
                    --   First check if there is already an association for this AG at the Child ICC.
                    --   Association Unique combination (ASSOC_OBJ_PK1_VALUE, ROUTE_PEOPLE_ID, OBJECT_ID1)
                    SELECT count(route_association_id) INTO k
                    FROM ENG_CHANGE_ROUTE_ASSOCS
                    WHERE ASSOC_OBJ_PK1_VALUE = l_child_item_catalog_group_id
                    AND ROUTE_PEOPLE_ID = p_route_people_id
                    AND OBJECT_ID1 = p_attribute_group_id;
                    IF (k = 0 OR k IS NULL) AND p_parent_item_catalog_group_id <> l_child_item_catalog_group_id THEN    --   Create association only if it already does not exist
                         SELECT ENG_CHANGE_ROUTE_ASSOCS_S.NEXTVAL INTO l_route_association_id FROM DUAL;
                         --   For each Parent ICC's association, create an association in the Child ICC.
                         INSERT INTO ENG_CHANGE_ROUTE_ASSOCS (ROUTE_ASSOCIATION_ID, ROUTE_PEOPLE_ID, ASSOC_OBJECT_NAME, ASSOC_OBJ_PK1_VALUE,
                              ADHOC_ASSOC_FLAG, OBJECT_NAME, OBJECT_ID1, OBJECT_ID2, OBJECT_ID3, OBJECT_ID4, OBJECT_ID5,
                              CREATION_DATE , CREATED_BY , LAST_UPDATE_DATE,
                              LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
                         VALUES (l_route_association_id, p_route_people_id, 'EGO_CATALOG_GROUP', l_child_item_catalog_group_id, 'N',
                              'EGO_ITEM_ATTR_GROUP', p_attribute_group_id, 0,0,0,0, p_assoc_creation_date, p_assoc_created_by,
                              p_assoc_last_update_date, p_assoc_last_update_login, p_assoc_last_updated_by);
                    END IF;
                    i := i + 1;
                    k := 0;
               END LOOP;
          END IF;
     END IF;
EXCEPTION
     WHEN OTHERS THEN
          NULL;
END Create_Child_Associations;

PROCEDURE Update_Child_Associations(
                    p_parent_item_catalog_group_id IN VARCHAR2,
                    p_child_item_catalog_group_ids IN VARCHAR2,
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_route_association_id IN NUMBER,
                    p_commit IN VARCHAR2
                    )
IS
     l_old_attr_group_id NUMBER;
     i NUMBER;
     l_child_item_catalog_group_id VARCHAR2(1000);
BEGIN
     --   Get the old attribute groups associated
     SELECT object_id1 INTO l_old_attr_group_id FROM ENG_CHANGE_ROUTE_ASSOCS WHERE route_association_id = p_route_association_id;
     i := 1;
     LOOP
          l_child_item_catalog_group_id := Tokenize( p_child_item_catalog_group_ids, i , ',') ;
          EXIT WHEN l_child_item_catalog_group_id IS NULL ;

          IF p_attribute_group_id IS NULL THEN         --   When attribute group association lov field is cleared
               DELETE FROM ENG_CHANGE_ROUTE_ASSOCS
               WHERE ASSOC_OBJ_PK1_VALUE = l_child_item_catalog_group_id
               AND ASSOC_OBJ_PK1_VALUE <> p_parent_item_catalog_group_id
               AND ROUTE_PEOPLE_ID = p_route_people_id
               AND OBJECT_ID1 = l_old_attr_group_id;
          ELSE
               UPDATE ENG_CHANGE_ROUTE_ASSOCS
               SET OBJECT_ID1 = p_attribute_group_id
               WHERE ASSOC_OBJ_PK1_VALUE = l_child_item_catalog_group_id
               AND ASSOC_OBJ_PK1_VALUE <> p_parent_item_catalog_group_id
               AND ROUTE_PEOPLE_ID = p_route_people_id;
          END IF;

          i := i + 1;
     END LOOP;

END Update_Child_Associations;


FUNCTION Tokenize
(
   p_string IN VARCHAR2,         -- input string
   p_start_position IN NUMBER,         -- token number
   p_seperator IN VARCHAR2 DEFAULT ',' -- separator character
)
RETURN VARCHAR2
IS
  l_string VARCHAR2(32767) := p_seperator || p_string ;
  l_position      NUMBER ;
  l_position2     NUMBER ;
BEGIN
  l_position := INSTR( l_string, p_seperator, 1, p_start_position ) ;
  IF l_position > 0 THEN
    l_position2 := INSTR( l_string, p_seperator, 1, p_start_position + 1) ;
    IF l_position2 = 0 THEN
	l_position2 := LENGTH( l_string ) + 1 ;
    END IF ;
    RETURN( SUBSTR( l_string, l_position+1, l_position2 - l_position-1 ) ) ;
  ELSE
    RETURN NULL ;
  END IF ;
END;


PROCEDURE Cancel_NIR_Line_Item(
                    p_change_id NUMBER,
                    p_item_id NUMBER,
                    p_org_id NUMBER,
                   -- p_mode VARCHAR2,    --   (DELETE/CHANGE_ICC)
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_commit IN VARCHAR2 := FND_API.G_FALSE,
                    x_return_status OUT NOCOPY VARCHAR2
                    )
IS
     l_change_line_id NUMBER;
     l_lines_count NUMBER;
     l_change_notice ENG_ENGINEERING_CHANGES.CHANGE_NOTICE%TYPE;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER ;
     l_msg_data VARCHAR2(200);
     l_action_id eng_change_actions.action_id%TYPE;
     l_change_status_code eng_engineering_changes.status_code%TYPE;
BEGIN
     --   First check whether the change(NIR) is in Draft status. If so the remove the line and subjects
     SELECT status_code INTO l_change_status_code FROM eng_engineering_changes WHERE change_id = p_change_id;

     IF l_change_status_code = 0 THEN   --   If Draft then
          --   Delete the line and subject in the NIR since it is in draft
          SELECT change_line_id INTO l_change_line_id FROM eng_change_subjects
          WHERE change_id = p_change_id
          AND pk1_value = p_item_id
          AND pk2_value = p_org_id
          AND entity_name = 'EGO_ITEM';

          DELETE FROM eng_change_subjects WHERE change_id = p_change_id ;
--          AND pk1_value = p_item_id
--          AND pk2_value = p_org_id
--          AND entity_name = 'EGO_ITEM';

          DELETE FROM eng_change_lines WHERE change_id = p_change_id and change_line_id = l_change_line_id;
          DELETE FROM eng_change_lines_tl WHERE change_line_id = l_change_line_id;
     ELSE
          --   Query change line id
          SELECT change_line_id INTO l_change_line_id FROM eng_change_subjects
          WHERE change_id = p_change_id
          AND pk1_value = p_item_id
          AND pk2_value = p_org_id
          AND entity_name = 'EGO_ITEM';
          --   Set change line status to Cancelled
          UPDATE ENG_CHANGE_LINES SET status_code = 5  --   Cancelled
          WHERE change_id = p_change_id AND change_line_id = l_change_line_id;
          --   Update the Action Log of the NIR.
          ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
          (
               p_api_version          =>    1.0,
               p_init_msg_list        =>    FND_API.G_TRUE,
               p_commit               =>    FND_API.G_FALSE,
               p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL,
               p_debug                =>    FND_API.G_FALSE,
               p_output_dir           =>    '',
               p_debug_filename       =>    '',
               x_return_status        =>    l_return_status,
               x_msg_count            =>    l_msg_count,
               x_msg_data             =>    l_msg_data,
               p_object_id1           =>    p_change_id,
               p_object_id2           =>    l_change_line_id,
               p_object_name          =>    'ENG_NEW_ITEM_REQUEST_LINES',
               p_action_type          =>    'CANCEL',
               p_status_code          =>    5,   --   Cancelled
               p_parent_action_id     =>    -1,
               p_change_description   =>    p_cancel_comments,
               x_change_action_id     =>    l_action_id
          );
          --   Check if this is the only Line in the NIR.
     END IF;

   x_return_status := 'TRUE';

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := 'FALSE';

END Cancel_NIR_Line_Item;

/*
     Added for R12C Enhancements
     Now, since there can be more than one line items in an NIR, we have to query the item using change_line_id.
     This method is called when the Line Item in an NIR is Rejected.
     This method calls the Items API to change the Approval Status of the Item.
*/
PROCEDURE Update_Item_Approval_Status (
        p_change_id         IN NUMBER,
	p_change_line_id    IN NUMBER,
	p_approval_status   IN NUMBER,
	x_return_status     OUT NOCOPY VARCHAR2)
IS
l_item_id NUMBER;
l_organization_id NUMBER;
l_approval_status VARCHAR2(1);
l_ret_item_app_st INTEGER;
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF p_approval_status = 1 THEN
		l_approval_status := 'N';
	ELSIF p_approval_status = 3 THEN
		l_approval_status := 'S';
	ELSIF p_approval_status IN (4, 8, 14)  THEN --    14 = Rejected
		l_approval_status := 'R';
	ELSIF p_approval_status = 5 THEN
		l_approval_status := 'A';
	END IF;
/* if p_change_line_ids is not null
    then
    for i in p_change_line_ids.FIRST .. p_change_line_ids.LAST
    LOOP
      /* get item_id and organization_id */
      SELECT to_number(pk1_value), to_number(pk2_value)
      INTO	l_item_id, l_organization_id
      FROM    eng_change_subjects
      WHERE   change_line_id = p_change_line_id
      AND     entity_name='EGO_ITEM';
        /* call API to update approval status on the Item to approved*/

--      l_ret_item_app_st := EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS(l_item_id,l_organization_id, l_approval_status);
      EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS(l_item_id,l_organization_id, l_approval_status, p_change_id);
  --END LOOP;
  --  end if;

EXCEPTION WHEN others  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'EGO_ITEM_PUB.UPDATE_ITEM_APPROVAL_STATUS '||'itemId: '||l_item_id||' OrgId: '||l_organization_id|| ' approvalStstus: '||l_approval_status || ' changeId: ' || p_change_id);
                FND_MSG_PUB.Add;

END Update_Item_Approval_Status;

FUNCTION checkNIRValidForApproval( p_change_id IN NUMBER)
return boolean
is
l_change_line_id number;
BEGIN
	select change_line_id
	  into l_change_line_id
	  from eng_change_lines
	 where change_id = p_change_id
	   and status_code in( 1,3)
     and rownum=1;

return ( l_change_line_id is not null);

EXCEPTION WHEN NO_DATA_FOUND  THEN
return false;

END checkNIRValidForApproval;

/*
This method will be called from ENG_CHANGE_LIFECYCLE_UTIL.Update_Header_Appr_Status() procedure
This method should be called when the Workflow is aborted in the Approval phase and when the NIR is demoted to Approval phase
All the Lines and Line Items status and approval status respectively should be reset to Open and Submitted for Approval respectively.
This method will reset the Approval Status of Items and Status of Lines which are Rejected using the NIR.

Spl Test Case : If there is another NIR with one of the line items and submitted since it is rejected in previous NIR,
and if the previous NIR Workflow is restarted, then the Line Status and Item Approval status will not be reset because it has to
be tracked with the other NIR.
	Test Case :
		SNIR_277 (Line1 - Item1)
		Line is Rejected
		NIR is Approved
		SNIR_279 (Line1 - Item1) Submitted, Item - SFA
		SNIR_277 Wf is Restarted
		Result : Should not update the Item App Status and Line Status in SNIR_277. SNIR_279 should be used to track the Item1.
*/
PROCEDURE Update_Line_Items_App_St(
     p_change_id         IN NUMBER,
     p_item_approval_status IN NUMBER,
     x_sfa_line_items_exists   OUT  NOCOPY  VARCHAR2
     )
IS
     CURSOR cur_line_items_in_nir IS
          SELECT change_line_id, pk1_value, pk2_value, pk3_value FROM ENG_CHANGE_SUBJECTS WHERE change_id = p_change_id
                         AND ENTITY_NAME='EGO_ITEM';

     l_ret_status VARCHAR2(10);
     l_change_line_id ENG_CHANGE_SUBJECTS.change_line_id%TYPE;
     l_pk1_value ENG_CHANGE_SUBJECTS.pk1_value%TYPE;
     l_pk2_value ENG_CHANGE_SUBJECTS.pk2_value%TYPE;
     l_pk3_value ENG_CHANGE_SUBJECTS.pk3_value%TYPE;
     l_item_approval_status MTL_SYSTEM_ITEMS.approval_status%TYPE;
     l_sfa_item VARCHAR2(1000);

BEGIN
     x_sfa_line_items_exists := '';
     --   Get all the Line Items in the NIR
     FOR line_items IN cur_line_items_in_nir
     LOOP
          l_change_line_id := line_items.change_line_id;
          l_pk1_value := line_items.pk1_value;
          l_pk2_value := line_items.pk2_value;
          l_pk3_value := line_items.pk3_value;

       BEGIN
          --   We need to reset the Line status and Item approval status only for the Lines rejected in the NIR.
          SELECT approval_status INTO l_item_approval_status FROM MTL_SYSTEM_ITEMS WHERE inventory_item_id = l_pk1_value AND organization_id = l_pk2_value;
          IF 'R' = l_item_approval_status THEN
               --   Update Item Approval Status
               Update_Item_Approval_Status(p_change_id, line_items.change_line_id, p_item_approval_status, l_ret_status);
               --   Update Line Item Status
               UPDATE eng_change_lines SET STATUS_CODE = 1 WHERE change_line_id = l_change_line_id;
          ELSE
               SELECT CONCATENATED_SEGMENTS INTO l_sfa_item
               FROM MTL_SYSTEM_ITEMS_KFV
               WHERE inventory_item_id = l_pk1_value
               AND organization_id = l_pk2_value
               AND LAST_SUBMITTED_NIR_ID <> p_change_id;

               IF x_sfa_line_items_exists IS NOT NULL AND l_sfa_item IS NOT NULL THEN
                    x_sfa_line_items_exists := x_sfa_line_items_exists || ' , ';
               END IF;
               x_sfa_line_items_exists := x_sfa_line_items_exists || l_sfa_item;
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
               NULL;
       END;
     END LOOP;

END Update_Line_Items_App_St;

END ENG_NIR_UTIL_PKG;

/
