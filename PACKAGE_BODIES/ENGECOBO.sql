--------------------------------------------------------
--  DDL for Package Body ENGECOBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENGECOBO" AS
/* $Header: ENGECOBB.pls 120.30.12010000.17 2019/04/01 13:58:10 nlingamp ship $ */

---------------------------------------------------------------
--  Global constant holding the package name                 --
---------------------------------------------------------------
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ENGECOBO';

---------------------------------------------------------------
--  Global constants                                         --
---------------------------------------------------------------
G_VAL_NOT_EXISTS CONSTANT NUMBER := 0;
G_VAL_EXISTS     CONSTANT NUMBER := 1;

G_VAL_FALSE CONSTANT NUMBER := 0;
G_VAL_TRUE CONSTANT NUMBER := 1;

---------------------------------------------------------------
--  DB hardcoded values                                      --
---------------------------------------------------------------
 G_PROPAGATED_TO  CONSTANT VARCHAR2(15) := 'PROPAGATED_TO';
 G_ENG_CHANGE     CONSTANT VARCHAR2(10) := 'ENG_CHANGE';
 G_LOG_PROC       CONSTANT NUMBER := 2;
 G_LOG_STMT       CONSTANT NUMBER := 1;
---------------------------------------------------------------
--  Global variables                                         --
---------------------------------------------------------------
 g_global_change_id     NUMBER;
 g_global_org_id        NUMBER;
 G_STATUS_CONTROL_LEVEL NUMBER;
---------------------------------------------------------------
-- User Defined Exception
---------------------------------------------------------------
EXC_EXP_SKIP_OBJECT     EXCEPTION;
EXC_ERR_PVT_API_MAIN    EXCEPTION;
---------------------------------------------------------------
--  Global Types Declaration                                 --
---------------------------------------------------------------
TYPE Eco_Struc_Line_rec_Type IS RECORD
 (
    Revised_item_sequence_id    NUMBER
  , bill_sequence_id        NUMBER
  , alternate_bom_designator    VARCHAR2(10)
  , local_bill_sequence_id  NUMBER
  , comn_bill_sequence_id   NUMBER
  , from_end_item_minor_rev_id   NUMBER
  , from_end_item_rev_id    NUMBER
 );

 TYPE Eco_Struc_Line_Tbl_Type IS TABLE OF Eco_Struc_Line_rec_Type
    INDEX BY BINARY_INTEGER;

 /*TYPE Eco_Error_rec_Type IS RECORD
 (
    Revised_item_sequence_id   NUMBER
  , revised_line_type          VARCHAR2(20)
  , revised_line_id1           NUMBER
  , log_text                VARCHAR2(2000)
  , log_type                VARCHAR2(10)
 );

TYPE Eco_Error_Tbl_Type IS TABLE OF Eco_Error_rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Prop_Rev_Items_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;*/

---------------------------------------------------------------
--  Start functions and Procedures Here                      --
---------------------------------------------------------------
-- Bug : 5356082
/*
The problem is that the document_id for each attachment in the
master org and child org for the same item is not same.
The previous logic for propogation was written in such a way that the item
attachments will be queried in the child organization with the same
document_id as in master organization.
Since because of the document_id's are different it was not able to find the
attachments in the child organization.
Now, we need to somehow match the attachments in the master organization to
the attachment in the child organization.
Steps :
     1. Get the media_id, node_id for the master org item attachments
     2. Get the repository type
     3. If repository type is web services, compare master org item attachment media id with that of child org item.
     4. If repository is webdav, compare master org item attachment file and folder path with that of child org item.
This function should be called for item attachment changes other than Attach to get the correct existing document_id.
*/
FUNCTION Get_Child_Org_Item_AttId
(
   p_item_id                  IN   NUMBER
 , p_item_revision_id         IN   NUMBER
 , p_master_org_id            IN   NUMBER
 , p_master_org_document_id   IN   NUMBER
 , p_child_org_id             IN   NUMBER
)
RETURN NUMBER IS
     l_master_item_media_id        FND_DOCUMENTS.MEDIA_ID%TYPE;
     l_master_item_node_id         FND_DOCUMENTS.DM_NODE%TYPE;
     l_master_item_folder_path     FND_DOCUMENTS.DM_FOLDER_PATH%TYPE;
     l_master_item_file_name       FND_DOCUMENTS.FILE_NAME%TYPE;
     l_master_item_dm_doc_id       FND_DOCUMENTS.DM_DOCUMENT_ID%TYPE;

     l_item_attachment_protocol    DOM_REPOSITORIES.PROTOCOL%TYPE;
     l_child_item_media_id         FND_DOCUMENTS.MEDIA_ID%TYPE;
     l_child_org_document_id       FND_DOCUMENTS.DOCUMENT_ID%TYPE;
     l_child_item_folder_path      FND_DOCUMENTS.DM_FOLDER_PATH%TYPE;
     l_child_item_file_name        FND_DOCUMENTS.FILE_NAME%TYPE;
     l_master_folder_and_file      VARCHAR2(3500);     --   DM_FOLDER_PATH || '/' || FILE_NAME
BEGIN
     --   Get the master item attachments information
     SELECT dm_node, media_id, dm_folder_path, file_name, dm_document_id
     INTO l_master_item_node_id, l_master_item_media_id, l_master_item_folder_path, l_master_item_file_name, l_master_item_dm_doc_id
     FROM fnd_documents
     WHERE document_id = p_master_org_document_id;
     l_master_folder_and_file := l_master_item_folder_path || '/' || l_master_item_file_name;

     --   Get the Protocol
     --bug 20787517, l_master_item_node_id is null for detach
     if(l_master_item_node_id is not null) then
     		 SELECT protocol INTO l_item_attachment_protocol FROM dom_repositories WHERE id = l_master_item_node_id;
		 else
         l_item_attachment_protocol := null;
     end if;

      if l_item_attachment_protocol is null then
          begin
           SELECT b.document_id, nvl(a.media_id , a.dm_document_id)
               INTO l_child_org_document_id, l_child_item_media_id
               FROM fnd_documents a, fnd_attached_documents b
               WHERE b.document_id = a.document_id AND
                    b.pk2_value = to_char(p_item_id) AND
                    b.pk1_value = to_char(p_child_org_id) AND
                    b.pk3_value = to_char(p_item_revision_id) AND
                    b.entity_name = 'MTL_ITEM_REVISIONS' AND -- 25049730
                   ( ( (l_master_item_media_id IS NOT NULL AND a.media_id = l_master_item_media_id) OR
                      (l_master_item_media_id IS NULL AND a.dm_document_id = l_master_item_dm_doc_id))
                      or((a.dm_folder_path || '/' || a.file_name) = l_master_folder_and_file));

               l_child_org_document_id := l_child_org_document_id;
          EXCEPTION
               WHEN OTHERS THEN
                    l_child_org_document_id := -1;
          end;

      end if;

     --   If web services, then we have to compare the media and node ids of master org item attachments
     --   with child org item attachments
     IF l_item_attachment_protocol = 'WEBSERVICES' THEN
          BEGIN
               SELECT b.document_id, nvl(a.media_id , a.dm_document_id)
               INTO l_child_org_document_id, l_child_item_media_id
               FROM fnd_documents a, fnd_attached_documents b
               WHERE b.document_id = a.document_id AND
                    b.pk2_value = p_item_id AND
                    b.pk1_value = p_child_org_id AND
                    b.pk3_value = p_item_revision_id AND
                    b.entity_name = 'MTL_ITEM_REVISIONS' AND -- 25049730
                    ( (l_master_item_media_id IS NOT NULL AND a.media_id = l_master_item_media_id) OR      -- file
                      (l_master_item_media_id IS NULL AND a.dm_document_id = l_master_item_dm_doc_id))AND  -- folder
                    a.dm_node = l_master_item_node_id;

          EXCEPTION
               WHEN OTHERS THEN
                    l_child_org_document_id := -1;
          END;
     END IF;

     --   If web dav, then we have to compare the folder and file name of master org item attachments
     --   with child org item attachments
     IF l_item_attachment_protocol = 'WEBDAV' THEN
          BEGIN
               SELECT b.document_id, a.dm_folder_path, a.file_name
               INTO l_child_org_document_id, l_child_item_folder_path, l_child_item_file_name
               FROM fnd_documents a, fnd_attached_documents b
               WHERE b.document_id = a.document_id AND
                    b.pk2_value = p_item_id AND
                    b.pk1_value = p_child_org_id AND
                    b.pk3_value = p_item_revision_id AND
                    b.entity_name = 'MTL_ITEM_REVISIONS' AND -- 25049730
                    (a.dm_folder_path || '/' || a.file_name) = l_master_folder_and_file AND
                    a.dm_node = l_master_item_node_id;
--FND_FILE.PUT_LINE(FND_FILE.LOG, 'MMITC : WEBDAV : ' || l_child_org_document_id );
               --   Only one row should be found
               l_child_org_document_id := l_child_org_document_id;
          EXCEPTION
               WHEN OTHERS THEN    --   when no data found or if it returns more than one row
--FND_FILE.PUT_LINE(FND_FILE.LOG, 'MMITC : WEBDAV Exception : ' || SQLERRM );
                    l_child_org_document_id := -1;
          END;
     END IF;

     RETURN l_child_org_document_id;

EXCEPTION
     WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'MMITC : Main Exception : ' ||SQLERRM );

END Get_Child_Org_Item_AttId;

PROCEDURE Propagated_Local_Change (
    p_change_id             IN NUMBER
  , p_local_organization_id IN NUMBER
  , x_local_change_id       OUT NOCOPY NUMBER
) IS

    CURSOR c_local_change_order IS
    SELECT eec.change_id
      FROM eng_engineering_changes eec
         , eng_change_obj_relationships ecor
     WHERE eec.change_id = ecor.object_to_id1
       AND ecor.relationship_code IN ( 'PROPAGATED_TO', 'TRANSFERRED_TO' )
       AND ecor.object_to_name ='ENG_CHANGE'
       AND ecor.object_to_id3 = p_local_organization_id
       AND ecor.change_id = p_change_id;

BEGIN
    OPEN c_local_change_order;
    FETCH c_local_change_order INTO x_local_change_id;
    CLOSE c_local_change_order;
EXCEPTION
WHEN OTHERS THEN
    IF c_local_change_order%ISOPEN
    THEN
        CLOSE c_local_change_order;
    END IF;
    x_local_change_id := NULL;

END Propagated_Local_Change;

FUNCTION Get_local_org_attachment_id (
    p_local_entity_name  IN VARCHAR2 -- MTL_ITEM_REVISIONS or MTL_SYSTEM_ITEMS
  , p_local_pk1_value    IN VARCHAR2  -- Org_id
  , p_local_pk2_value    IN VARCHAR2  -- item id
  , p_local_pk3_value    IN VARCHAR2  -- current item_revision_id
  , p_global_document_id IN NUMBER
  , x_att_status         IN OUT NOCOPY VARCHAR2 -- Bug 3599366
) RETURN NUMBER IS

  l_local_attachment_id NUMBER := -1;

  CURSOR c_local_attachment
  IS
  SELECT fad.attached_document_id, fad.status
    FROM fnd_documents_vl fdv, fnd_attached_documents fad
   WHERE fdv.document_id = fad.document_id
     AND fad.entity_name = p_local_entity_name
     AND fad.pk1_value= p_local_pk1_value
     AND fad.pk2_value = p_local_pk2_value
     AND fad.pk3_value = p_local_pk3_value
     AND (fdv.document_id = p_global_document_id
          OR
          (fdv.document_id <> p_global_document_id
           AND ( Nvl(fdv.dm_folder_path, '*NULL*'), fdv.dm_node, fdv.file_name)=
               (SELECT Nvl(dm_folder_path, '*NULL*'), dm_node, file_name
                  FROM fnd_documents_vl
                 WHERE document_id = p_global_document_id)
          )
          OR
          (fdv.document_id <> p_global_document_id
           AND fdv.dm_node = 0
           AND (fdv.file_name, fdv.datatype_id) =
               (SELECT file_name, datatype_id
                  FROM fnd_documents_vl
                 WHERE document_id = p_global_document_id)
          )
         );

BEGIN
    OPEN c_local_attachment;
    FETCH c_local_attachment INTO l_local_attachment_id
                                , x_att_status; -- Bug 3599366
    CLOSE c_local_attachment;
    RETURN l_local_attachment_id;

EXCEPTION
WHEN OTHERS THEN
    IF c_local_attachment%ISOPEN
    THEN
        CLOSE c_local_attachment;
    END IF;
    RETURN -1;
END Get_local_org_attachment_id;

PROCEDURE Propagate_Attach_Lines (
    p_change_id                IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_revised_item_rec         IN Eng_Eco_Pub.Revised_Item_Rec_Type
  , p_revised_item_unexp_rec   IN Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
  , p_local_organization_id    IN NUMBER
  , p_local_line_rev_id        IN NUMBER
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) IS
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(3);

  l_local_change_id     NUMBER;
  l_local_attachment_id NUMBER := -1;
  l_pk3_value           VARCHAR2(100);
  l_change_document_id  NUMBER;
  l_local_att_status    fnd_attached_documents.status%TYPE; -- Bug 3599366
  l_temp_document_id    NUMBER;

  CURSOR c_attachment_changes (cp_revised_item_sequence_id NUMBER)
  IS
  SELECT eac.action_type, eac.attachment_id, eac.source_document_id, eac.SOURCE_VERSION_LABEL
       , eac.SOURCE_PATH, eac.DEST_DOCUMENT_ID, eac.DEST_VERSION_LABEL, eac.DEST_PATH
       , eac.CHANGE_DOCUMENT_ID, eac.entity_name, eac.pk1_value, eac.pk2_value, eac.pk3_value
       , decode(eac.action_type, 'ATTACH', eac.source_document_id,fad.document_id) document_id
       , eac.FAMILY_ID, eac.REPOSITORY_ID, eac.PK4_VALUE, eac.PK5_VALUE, eac.NEW_FILE_NAME
       , eac.DESCRIPTIOn, eac.NEW_DESCRIPTIOn, eac.NEW_CATEGORY_ID
  FROM eng_attachment_changes eac, fnd_attached_documents fad
  WHERE eac.change_id = p_change_id -- 4517503
  AND eac.revised_item_sequence_id = cp_revised_item_sequence_id
  AND eac.attachment_id =  fad.attached_document_id(+)
  AND (eac.entity_name = 'MTL_ITEM_REVISIONS'
        OR (eac.entity_name = 'MTL_SYSTEM_ITEMS'
        AND NOT EXISTS (SELECT 1 FROM MTL_PARAMETERS MP
            WHERE MP.organization_id = g_global_org_id
            AND MP.master_organization_id = MP.organization_id)
    ))
  AND NOT EXISTS (SELECT 1 FROM eng_change_propagation_maps ecpm
                   WHERE ecpm.change_id = p_change_id
                     AND ecpm.local_organization_id = p_local_organization_id
                     AND ecpm.revised_line_type = Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
                     AND ecpm.revised_line_id1 = eac.change_document_id
                     AND ecpm.entity_action_status = 3);

  CURSOR c_attachment_details(cp_attached_document_id IN NUMBER
                            , cp_attach_action_type   IN eng_attachment_changes.action_type%TYPE
                            , cp_change_document_id   IN NUMBER)
  IS
  SELECT fad.category_id, fad.status, fad.document_id
       , fad.attached_document_id, fdv.file_name, fad.last_updated_by
       , fdv.dm_type, fdv.datatype_id, fdv.document_id source_document_id
    FROM fnd_attached_documents fad, fnd_documents_vl fdv
   WHERE fad.attached_document_id = cp_attached_document_id
     AND fad.document_id = fdv.document_id
     AND cp_attach_action_type <> 'ATTACH'
  UNION ALL
  SELECT eac.category_id, eac.previous_status, eac.source_document_id
       , eac.attachment_id, eac.file_name, eac.last_updated_by
       , eac.dm_type, eac.datatype_id, eac.source_document_id
    FROM eng_attachment_changes eac, fnd_documents_vl fdv
   WHERE eac.change_document_id =  cp_change_document_id
     AND eac.source_document_id = fdv.document_id
     AND cp_attach_action_type = 'ATTACH';

  l_attachment_details_rec c_attachment_details%ROWTYPE;

BEGIN
    Eng_Propagation_log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Attach_Lines.BEGIN');
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Input Param: p_change_id               '||p_change_id);
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Input Param: p_revised_item_sequence_id'||p_revised_item_sequence_id );

    -- get the local change id
    Propagated_Local_Change(
        p_change_id             => p_change_id
      , p_local_organization_id => p_local_organization_id
      , x_local_change_id       => l_local_change_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value: l_local_change_id'||l_local_change_id);
    IF l_local_change_id IS null
    THEN
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value: l_local_change_id'||p_revised_item_unexp_rec.change_id);
        l_local_change_id := p_revised_item_unexp_rec.change_id;
    END IF;
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value:  p_revised_item_unexp_rec.revised_item_sequence_id'|| p_revised_item_unexp_rec.revised_item_sequence_id);

    IF (l_local_change_id IS NOT NULL AND p_revised_item_unexp_rec.revised_item_sequence_id IS NOT NULL)
    THEN
        FOR ac in c_attachment_changes (p_revised_item_sequence_id) /* loop 2*/
        LOOP
            -- initialize pk value and local attachment id
            l_pk3_value := NULL;
            l_local_attachment_id := -1;
            l_return_status := FND_API.G_RET_STS_SUCCESS;
            -- set the pk3 value if the attachment belongs to item revision
            IF (ac.entity_name = 'MTL_ITEM_REVISIONS')
            THEN
                Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value:  p_revised_item_unexp_rec.new_item_revision_id'|| p_revised_item_unexp_rec.new_item_revision_id);
                Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value:  p_revised_item_unexp_rec.CURRENT_item_revision_id'|| p_revised_item_unexp_rec.CURRENT_item_revision_id);

               -- Bug : 5355614
               -- For item attachment changes with new revisions we need to get the correct revision id (eng_attachment_changes.pk3_value)
               BEGIN
                    select revision_id
                    into l_pk3_value from mtl_item_revisions
                    where inventory_item_id = (select revised_item_id
                                               from eng_revised_items
                                               where revised_item_sequence_id = p_revised_item_unexp_rec.Revised_Item_Sequence_Id)
                    and revised_item_sequence_id = p_revised_item_unexp_rec.Revised_Item_Sequence_Id;
               EXCEPTION
                    WHEN OTHERS THEN
                         --   this will be called for item attachment changes with default revision
                         l_pk3_value := nvl(p_revised_item_unexp_rec.new_item_revision_id,
                                            p_revised_item_unexp_rec.CURRENT_item_revision_id);
               END;
            END IF;
                -- Bug : 5356082
                l_temp_document_id := ac.document_id;
                     l_temp_document_id := Get_Child_Org_Item_AttId
                                           (
                                           p_item_id                => ac.pk2_value
                                          ,p_item_revision_id       => l_pk3_value
                                          ,p_master_org_id          => g_global_org_id
                                          ,p_master_org_document_id => ac.document_id
                                          ,p_child_org_id           => p_revised_item_unexp_rec.organization_id
                                           );
                l_local_attachment_id := Get_local_org_attachment_id(
                                             p_local_entity_name  => ac.entity_name
                                           , p_local_pk1_value    => p_local_organization_id
                                           , p_local_pk2_value    => ac.pk2_value
                                           , p_local_pk3_value    => l_pk3_value
                                           , p_global_document_id => l_temp_document_id
                                           , x_att_status         => l_local_att_status); -- Bug 3599366
            Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value: ac.action_type:'||ac.action_type);
            Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value: l_local_attachment_id:'||l_local_attachment_id);
            Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Value: ac.change_document_id:'||ac.change_document_id);
            IF (ac.action_type = 'ATTACH' OR l_local_attachment_id <> -1)
            THEN
                FOR cad IN c_attachment_details(l_local_attachment_id, ac.action_type, ac.change_document_id)
                LOOP
                    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Inserting into eng_attachment_changes..');
                    SELECT ENG_ATTACHMENT_CHANGES_S.nextval
                    INTO l_change_document_id
                    FROM dual;

                    INSERT INTO eng_attachment_changes (
                        CHANGE_ID
                      , REVISED_ITEM_SEQUENCE_ID
                      , ACTION_TYPE
                      , ATTACHMENT_ID
                      , SOURCE_document_ID
                      , SOURCE_VERSION_LABEL
                      , SOURCE_PATH
                      , DEST_DOCUMENT_ID
                      , DEST_VERSION_LABEL
                      , DEST_PATH
                      , CREATION_DATE
                      , CREATED_BY
                      , LAST_UPDATE_DATE
                      , LAST_UPDATED_BY
                      , LAST_UPDATE_LOGIN
                      , CHANGE_DOCUMENT_ID
                      , FILE_NAME
                      , CATEGORY_ID
                      , ATTACHED_USER_ID
                      , PREVIOUS_STATUS
                      , FAMILY_ID
                      , REPOSITORY_ID
                      , DM_TYPE
                      , ENTITY_NAME
                      , PK1_VALUE
                      , PK2_VALUE
                      , PK3_VALUE
                      , PK4_VALUE
                      , PK5_VALUE
                      , NEW_FILE_NAME
                      , DESCRIPTION
                      , NEW_DESCRIPTION
                      , NEW_CATEGORY_ID
                      , DATATYPE_ID
                      ) VALUES (
                        l_local_change_id
                      , p_revised_item_unexp_rec.revised_item_sequence_id
                      , ac.action_type
                      , decode(l_local_attachment_id, -1, ac.attachment_id, l_local_attachment_id)
                      , cad.source_document_id
                      , ac.SOURCE_VERSION_LABEL
                      , ac.SOURCE_PATH
                      , ac.DEST_DOCUMENT_ID
                      , ac.DEST_VERSION_LABEL
                      , ac.DEST_PATH
                      , sysdate
                      , FND_GLOBAL.USER_ID
                      , sysdate
                      , FND_GLOBAL.USER_ID
                      , FND_GLOBAL.USER_ID
                      , l_change_document_id
                      , cad.file_name
                      , cad.category_id
                      , cad.last_updated_by
                      , cad.status
                      , ac.FAMILY_ID
                      , ac.REPOSITORY_ID
                      , cad.DM_TYPE
                      , ac.ENTITY_NAME
                      , p_revised_item_unexp_rec.organization_id
                      , ac.PK2_VALUE
                      , l_pk3_value
                      , ac.PK4_VALUE
                      , ac.PK5_VALUE
                      , ac.NEW_FILE_NAME
                      , ac.DESCRIPTION
                      , ac.NEW_DESCRIPTION
                      , ac.NEW_CATEGORY_ID
                      , cad.DATATYPE_ID
                      );
                END LOOP;
            ELSE
                Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Could not process attachment_changes..Add Error');
                Eng_Propagation_Log_Util.add_entity_map(
                    p_change_id                 => p_change_id
                  , p_revised_item_sequence_id  => p_revised_item_sequence_id
                  , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
                  , p_revised_line_id1          => ac.CHANGE_DOCUMENT_ID
                  , p_local_organization_id     => p_local_organization_id
                  , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
                  , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
                  , p_bo_entity_identifier      => 'ATCH'--Eco_Error_Handler.G_ATCH_LEVEL
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
                -- this case should not be reached as validation of attachments has already been done.
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Attachment does not exist');
            END IF;
            Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Processed attachment change with l_return_status'|| l_return_status);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN
                Eng_Propagation_Log_Util.add_entity_map(
                    p_change_id                 => p_change_id
                  , p_revised_item_sequence_id  => p_revised_item_sequence_id
                  , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
                  , p_revised_line_id1          => ac.CHANGE_DOCUMENT_ID
                  , p_local_organization_id     => p_local_organization_id
                  , p_local_revised_item_seq_id => p_revised_item_unexp_rec.revised_item_sequence_id
                  , p_local_revised_line_id1    => l_change_document_id
                  , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
                  , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS
                  , p_bo_entity_identifier      => 'ATCH'--Eco_Error_Handler.G_ATCH_LEVEL
                 );
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
                x_return_status := l_return_status;
            END IF;
        END LOOP;   /* end loop 2 */
    END IF;
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Processed All attachment change with x_return_status'||x_return_status);
    IF x_return_status = FND_API.G_RET_STS_ERROR
    THEN
        Error_Handler.Add_Error_Token(
            p_Message_Name       => 'ENG_PRP_ATT_REVITEM_ERR'
          , p_Mesg_Token_Tbl     => x_mesg_token_tbl
          , x_Mesg_Token_Tbl     => x_mesg_token_tbl
         );
    END IF;
    Eng_Propagation_log_Util.Debug_Log(G_LOG_STMT, 'Propagate_Attach_Lines.END');

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    Error_Handler.Add_Error_Token(
        p_Message_Name   => NULL
      , p_Message_Text   => 'Unexpected Error Occurred when propagating attachment changes' ||SQLERRM
      , p_Mesg_Token_Tbl => x_Mesg_Token_Tbl
      , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
     );
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error propagating attachment changes' ||SQLERRM);
    Eng_Propagation_log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Attach_Lines.END.ERROR');
END Propagate_Attach_Lines;

PROCEDURE BREAK_COMMON_BOM (
    p_to_sequence_id   IN NUMBER
  , p_from_sequence_id IN NUMBER
  , p_from_org_id      IN NUMBER
  , p_to_org_id        IN NUMBER
  , p_to_item_id       IN NUMBER
  , p_to_alternate     IN VARCHAR2
  , p_from_item_id     IN NUMBER
) IS
    l_null_val NUMBER;

BEGIN
    /* copy bom */
    BOM_COPY_BILL.COPY_BILL(
        to_sequence_id          => p_to_sequence_id
      , from_sequence_id        => p_from_sequence_id
      , from_org_id             => p_from_org_id
      , to_org_id               => p_to_org_id
      , display_option          => 1
      , user_id                 => FND_PROFILE.value('USER_ID')
      , to_item_id              => p_to_item_id
      , direction               => 3
      , to_alternate            => p_to_alternate
      , rev_date                => sysdate
      , e_change_notice         => NULL
      , rev_item_seq_id         => NULL
      , bill_or_eco             => 1
      , eco_eff_date            => NULL
      , eco_unit_number         => NULL
      , unit_number             => NULL
      , from_item_id            => p_from_item_id
     );
    /* update the commoned information in bom_bill_of_materials */
    update bom_bill_of_materials set
    common_bill_sequence_id = p_to_sequence_id,
    common_organization_id = NULL,
    common_assembly_item_id = NULL
    where bill_sequence_id = p_to_sequence_id;
END BREAK_COMMON_BOM;


FUNCTION Check_Sourcing_Rules (
    p_local_org_id    IN NUMBER
  , p_revised_item_id IN NUMBER
) RETURN NUMBER IS
   l_item_sourced NUMBER := 2;
BEGIN
    l_item_sourced := ENG_SOURCING_CHECK.IS_ITEM_SOURCED(p_revised_item_id, p_local_org_id, g_global_org_id);
    IF(l_item_sourced = 3)  /* public api not overridden */
    THEN
        l_item_sourced := 2;
        -- Scoped out
        /*BEGIN
            select 1 into l_item_sourced from dual
            where exists (select 1 from mrp_sources_v
            where assignment_set_id = FND_PROFILE.VALUE( 'MRP_DEFAULT_ASSIGNMENT_SET' )
            and organization_id = g_global_org_id
            and inventory_item_id = p_revised_item_id
            and source_organization_id = p_local_org_id
            and source_type = 2);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_item_sourced := 2;
        END;*/
    END IF;
    RETURN l_item_sourced;
END Check_Sourcing_Rules;

PROCEDURE Auto_Enable_Item_In_Org (
    p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , x_error_table       OUT NOCOPY INV_ITEM_GRP.Error_Tbl_Type
  , x_return_status     OUT NOCOPY VARCHAR2
) IS
    l_Item_rec_in        INV_ITEM_GRP.Item_Rec_Type;
    l_revision_rec       INV_ITEM_GRP.Item_Revision_Rec_Type;
    l_Item_rec_out       INV_ITEM_GRP.Item_Rec_Type;
    l_return_status      VARCHAR2(1);
    l_Error_tbl          INV_ITEM_GRP.Error_Tbl_Type;
BEGIN
    l_Item_rec_in.INVENTORY_ITEM_ID :=  p_Inventory_Item_Id;
    l_Item_rec_in.ORGANIZATION_ID :=  p_Organization_Id;

    INV_ITEM_GRP.Create_Item(
        p_Item_rec         =>  l_Item_rec_in
      , p_Revision_rec     =>  l_revision_rec
      , p_Template_Id      =>  NULL
      , p_Template_Name    =>  NULL
      , x_Item_rec         =>  l_Item_rec_out
      , x_return_status    =>  l_return_status
      , x_Error_tbl        =>  l_Error_tbl
     );
    x_return_status :=  l_return_status;
    x_error_table := l_Error_tbl;

END Auto_Enable_Item_In_Org;

PROCEDURE Auto_Enable_Item (
    p_api_version           IN NUMBER
  , p_init_msg_list         IN VARCHAR2
  , p_commit                IN VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , p_inventory_item_id     IN NUMBER
  , p_local_organization_id IN NUMBER
) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Auto_Enable_Item';
    l_api_version    CONSTANT NUMBER := 1.0;
    l_error_table    INV_ITEM_GRP.Error_Tbl_Type;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard Start of API savepoint
    SAVEPOINT Auto_Enable_Item;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    AUTO_ENABLE_ITEM_IN_ORG(
        p_inventory_item_id   => p_inventory_item_id
      , p_organization_id     => p_local_organization_id
      , X_error_table         =>  l_error_table
      , x_return_status       => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        FOR i IN 1..l_error_table.COUNT
        LOOP
           FND_MESSAGE.Set_Name('INV', l_error_table(i).message_name);
           FND_MSG_PUB.Add;
        END loop;
        FND_MSG_PUB.Count_And_Get(
            p_count => x_msg_count
          , p_data  => x_msg_data);
    END IF;
    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO Auto_Enable_Item;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count
       , p_data  => x_msg_data);
END Auto_Enable_Item;

/* added this procedure to stop propogation of attachment having not allowed
    change policy in child org.
    added nvl condition for lifecycle  & phase id because if no lifecycle defined at revision level
    it takes item level's by default. */
FUNCTION Check_Attachment_Policy (
      p_inventory_item_id        IN            NUMBER,
      p_organization_id     IN            NUMBER,
      p_category_id     IN            VARCHAR2,
      p_revision_id  IN NUMBER
) RETURN NUMBER IS
 l_strc_cp_not_allowed   NUMBER := 2;

  CURSOR c_check_attach_policy IS
   SELECT 1
   FROM (SELECT nvl(mir.lifecycle_id,msi.lifecycle_id) lifecycle_id,
            nvl(mir.current_phase_id,msi.current_phase_id) current_phase_id, msi.item_catalog_group_id,
            mir.inventory_item_id, mir.organization_id
            FROM MTL_ITEM_REVISIONS mir ,MTL_SYSTEM_ITEMS msi
            WHERE mir.INVENTORY_ITEM_ID = p_inventory_item_id
            AND mir.ORGANIZATION_ID = p_organization_id
            AND mir.revision_id = p_revision_id
            AND  msi.INVENTORY_ITEM_ID = mir.INVENTORY_ITEM_ID
            AND msi.ORGANIZATION_ID = mir.ORGANIZATION_ID) ITEM_DTLS, ENG_CHANGE_POLICIES_V ECP
   WHERE ecp.policy_object_pk1_value =
        (SELECT TO_CHAR(ic.item_catalog_group_id)
         FROM mtl_item_catalog_groups_b ic
         WHERE EXISTS
           (SELECT olc.object_classification_code CatalogId
            FROM EGO_OBJ_TYPE_LIFECYCLES olc
            WHERE olc.object_id = (SELECT OBJECT_ID FROM fnd_objects WHERE obj_name = 'EGO_ITEM')
            AND olc.lifecycle_id = ITEM_DTLS.lifecycle_id
            AND olc.object_classification_code = ic.item_catalog_group_id)
         AND ROWNUM = 1
         CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
         START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
   AND ecp.policy_object_pk2_value = ITEM_DTLS.lifecycle_id
   AND ecp.policy_object_pk3_value = ITEM_DTLS.current_phase_id
   AND ecp.policy_object_name = 'CATALOG_LIFECYCLE_PHASE'
   AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
   AND ecp.attribute_code = 'ATTACHMENT'
   AND ecp.ATTRIBUTE_NUMBER_VALUE = p_category_id
   AND ecp.policy_char_value = 'NOT_ALLOWED';

 BEGIN
      l_strc_cp_not_allowed := 2;
     OPEN c_check_attach_policy;
     FETCH c_check_attach_policy INTO l_strc_cp_not_allowed;
     CLOSE c_check_attach_policy;
      RETURN  l_strc_cp_not_allowed;

 EXCEPTION
 WHEN OTHERS THEN
     IF c_check_attach_policy%ISOPEN THEN
         CLOSE c_check_attach_policy;
     END IF;
     l_strc_cp_not_allowed := 2;
     RETURN  l_strc_cp_not_allowed;
 END Check_Attachment_Policy;

PROCEDURE Validate_Attach_Lines (
    p_change_id                   IN NUMBER
  , p_rev_item_sequence_id        IN NUMBER
  , p_global_organization_id      IN NUMBER
  , p_global_new_item_rev         IN VARCHAR2
  , p_global_current_item_rev_id  IN NUMBER
  , p_local_organization_id       IN NUMBER
  , p_local_line_rev_id           IN NUMBER
  , p_revised_item_rec            IN Eng_Eco_Pub.Revised_Item_Rec_Type
  , p_revised_item_unexp_rec      IN Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
  , x_return_status               OUT NOCOPY VARCHAR2
  , x_mesg_token_tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) IS

   CURSOR c_attachment_changes IS
   SELECT eac.action_type, eac.entity_name, eac.pk1_value, eac.pk2_value
        , eac.pk3_value, eac.file_name, fad.status, eac.change_document_id
        , decode(eac.action_type, 'ATTACH', eac.source_document_id,fad.document_id) document_id,eac.category_id
   FROM eng_attachment_changes eac, fnd_attached_documents fad
   WHERE eac.change_id = p_change_id
   AND eac.revised_item_sequence_id = p_rev_item_sequence_id
   AND eac.attachment_id =  fad.attached_document_id(+)
   AND (eac.entity_name = 'MTL_ITEM_REVISIONS'
        OR (eac.entity_name = 'MTL_SYSTEM_ITEMS'
        AND NOT EXISTS (SELECT 1 FROM MTL_PARAMETERS MP
            WHERE MP.organization_id = p_global_organization_id
            AND MP.master_organization_id = MP.organization_id)
    ))
   AND NOT EXISTS (SELECT 1 FROM eng_change_propagation_maps ecpm
                    WHERE ecpm.change_id = p_change_id
                      AND ecpm.local_organization_id = p_local_organization_id
                      AND ecpm.revised_line_type = Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
                      AND ecpm.revised_line_id1 = eac.change_document_id
                      AND ecpm.entity_action_status = 3);

   CURSOR c_check_item_level_changes IS
   SELECT 1
   FROM eng_attachment_changes eac
   WHERE eac.change_id = p_change_id
   AND eac.revised_item_sequence_id = p_rev_item_sequence_id
   AND eac.entity_name = 'MTL_SYSTEM_ITEMS'
   AND EXISTS(SELECT 1 FROM MTL_PARAMETERS MP
              WHERE MP.organization_id = p_global_organization_id
                AND MP.master_organization_id = MP.organization_id)
   AND NOT EXISTS (SELECT 1 FROM eng_change_propagation_maps ecpm
                    WHERE ecpm.change_id = p_change_id
                      AND ecpm.local_organization_id = p_local_organization_id
                      AND ecpm.revised_line_type = Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
                      AND ecpm.revised_line_id1 = eac.change_document_id
                      AND ecpm.entity_action_status = 3);


   l_current_revision_id NUMBER;
   l_action_name         fnd_lookups.meaning%TYPE;
   l_local_attachment_id NUMBER;
   l_pk3_value           VARCHAR2(100);
   l_status_name         fnd_lookups.meaning%TYPE;
   l_check_item_changes  NUMBER;
   l_local_att_status    fnd_attached_documents.status%TYPE; -- Bug 3599366
   l_Mesg_token_Tbl      Error_Handler.Mesg_Token_Tbl_Type;
   l_Token_Tbl           Error_Handler.Token_Tbl_Type;
   l_error_logged        NUMBER;
   l_cp_not_allowed      NUMBER;
   l_temp_document_id    NUMBER;
   l_local_revision      VARCHAR2(30);
   l_global_revision     VARCHAR2(30);
   l_rev_mismatch        NUMBER;

BEGIN
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Validate_Attach_Lines.BEGIN');
    --
    -- Initialize
    l_error_logged := G_VAL_FALSE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- validate attachment changes propagation
    FOR ac IN c_attachment_changes
    LOOP
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Processing attachment change record with change_document_id: '||ac.change_document_id);

        Error_Handler.Delete_Message(p_entity_id => Eco_Error_Handler.G_ATCH_LEVEL);

        l_mesg_token_tbl.delete;

        -- initialize pk value and local attachment id
        l_pk3_value := NULL;
        l_local_attachment_id := -1;
        l_rev_mismatch := G_VAL_FALSE;

        -- set the pk3 value if the attachment belongs to item revision
        IF (ac.entity_name = 'MTL_ITEM_REVISIONS')
        THEN
          l_pk3_value := p_local_line_rev_id;

          BEGIN
            SELECT revision
            INTO l_local_revision
            FROM MTL_ITEM_REVISIONS
            WHERE revision_id = p_local_line_rev_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_local_revision := NULL;
          END;

          IF  p_global_new_item_rev IS NOT NULL AND
              p_global_new_item_rev <> FND_API.G_MISS_CHAR AND
              p_global_new_item_rev <> l_local_revision
          THEN
            l_Token_Tbl.delete;
            l_Token_Tbl(1).Token_name := 'REVISION';
            l_Token_Tbl(1).Token_Value := p_global_new_item_rev;

            Error_Handler.Add_Error_Token(
                p_Message_Name       => 'ENG_NEW_REV_PROP_ERROR'
              , p_Mesg_Token_Tbl     => l_mesg_token_tbl
              , x_Mesg_Token_Tbl     => l_mesg_token_tbl
              , p_Token_Tbl          => l_token_tbl
             );

            l_error_logged := G_VAL_TRUE;
            l_rev_mismatch := G_VAL_TRUE;

          ELSIF p_global_new_item_rev IS NULL OR
                p_global_new_item_rev = FND_API.G_MISS_CHAR
          THEN
            BEGIN
              SELECT revision
              INTO l_global_revision
              FROM MTL_ITEM_REVISIONS
              WHERE revision_id = p_global_current_item_rev_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_global_revision := NULL;
            END;

            IF l_global_revision <> l_local_revision
            THEN
              l_Token_Tbl.delete;
              l_Token_Tbl(1).Token_name := 'REVISION';
              l_Token_Tbl(1).Token_Value := l_global_revision;

              Error_Handler.Add_Error_Token(
                  p_Message_Name       => 'ENG_CUR_REV_PROP_ERROR'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
               );

              l_error_logged := G_VAL_TRUE;
              l_rev_mismatch := G_VAL_TRUE;
            END IF;
          END IF;

          Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value: l_pk3_value '||l_pk3_value);
        END IF;

        IF l_rev_mismatch = G_VAL_FALSE
        THEN
          --added for bug 5151075
          l_cp_not_allowed := Check_Attachment_Policy( p_inventory_item_id   => ac.pk2_value
                                                     , p_organization_id     => p_local_organization_id
                                                     , p_category_id         => ac.category_id
                                                     , p_revision_id         => l_pk3_value);
          IF l_cp_not_allowed = 1
          THEN
            -- If revision level attachment has change allowed policy is set to 'NO'
            l_Token_Tbl.delete;
            Error_Handler.Add_Error_Token(p_Message_Name       => 'ENG_ATT_NO_ALLOW_CHG_POLICY'
                                        , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                        , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                        , p_Token_Tbl          => l_token_tbl);
            l_error_logged := G_VAL_TRUE;
          END IF;

          -- Bug : 5356082
          --bug 20787517, need to pass current revision id for detach to find document id
          IF ac.action_type = 'DETACH' then
          l_temp_document_id := Get_Child_Org_Item_AttId(p_item_id                => ac.pk2_value
                                                        ,p_item_revision_id       => p_revised_item_unexp_rec.current_item_revision_id
                                                        ,p_master_org_id          => g_global_org_id
                                                        ,p_master_org_document_id => ac.document_id
                                                        ,p_child_org_id           => p_revised_item_unexp_rec.organization_id);

          else

          l_temp_document_id := Get_Child_Org_Item_AttId(p_item_id                => ac.pk2_value
                                                        ,p_item_revision_id       => l_pk3_value
                                                        ,p_master_org_id          => g_global_org_id
                                                        ,p_master_org_document_id => ac.document_id
                                                        ,p_child_org_id           => p_revised_item_unexp_rec.organization_id);
          end if;
          --bug 20787517, need to pass current revision id for detach to find attachment id
          IF ac.action_type = 'DETACH' then

          l_local_attachment_id := Get_local_org_attachment_id(p_local_entity_name   => ac.entity_name
                                                             , p_local_pk1_value     => p_revised_item_unexp_rec.organization_id
                                                             , p_local_pk2_value     => ac.pk2_value
                                                             , p_local_pk3_value     => p_revised_item_unexp_rec.current_item_revision_id
                                                             , p_global_document_id  => l_temp_document_id
                                                             , x_att_status          => l_local_att_status); -- Bug 3599366

          else
          l_local_attachment_id := Get_local_org_attachment_id(p_local_entity_name   => ac.entity_name
                                                             , p_local_pk1_value     => p_revised_item_unexp_rec.organization_id
                                                             , p_local_pk2_value     => ac.pk2_value
                                                             , p_local_pk3_value     => l_pk3_value
                                                             , p_global_document_id  => l_temp_document_id
                                                             , x_att_status          => l_local_att_status); -- Bug 3599366

           end if;
          SELECT meaning
          INTO l_action_name
          FROM fnd_lookups
          WHERE lookup_type = 'DOM_CHANGE_ACTION_TYPES'
          AND lookup_code = ac.action_type;

          Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value: l_local_attachment_id'||l_local_attachment_id||' l_local_att_status'||l_local_att_status);
          Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value: ac.action_type'||ac.action_type);

          IF (ac.action_type = 'ATTACH' AND l_local_attachment_id <> -1)
          THEN
              -- For attach action, if Attachment already exists log error
              l_Token_Tbl.delete;
              l_Token_Tbl(1).Token_name := 'FILE';
              l_Token_Tbl(1).Token_Value := ac.file_name;

              Error_Handler.Add_Error_Token(
                  p_Message_Name       => 'ENG_PRP_ATT_ADD_FAIL'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
               );
              l_error_logged := G_VAL_TRUE;

          ELSIF (ac.action_type <> 'ATTACH' AND l_local_attachment_id = -1)
          THEN
              -- For all actions except attach, if attachment does not exist in local org, log error
              l_Token_Tbl.delete;
              l_Token_Tbl(1).Token_name := 'ACTION';
              l_Token_Tbl(1).Token_Value := l_action_name;
              l_Token_Tbl(2).Token_name := 'FILE';
              l_Token_Tbl(2).Token_Value := ac.file_name;

              Error_Handler.Add_Error_Token(
                  p_Message_Name       => 'ENG_PRP_ATT_ACTION_FAIL'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
               );
              l_error_logged := G_VAL_TRUE;

          ELSIF (ac.action_type <> 'ATTACH' AND
                 l_local_attachment_id <> -1 AND
                 l_local_att_status IN ('PENDING', 'PENDING_CHANGE', 'SUBMITTED_FOR_APPROVAL')) -- Bug 3599366
          THEN
              SELECT meaning
              INTO l_status_name
              FROM fnd_lookups
              WHERE lookup_type = 'DOM_ATTACHED_DOC_STATUS'
              AND lookup_code = l_local_att_status; -- Bug 3599366

              -- For all actions except attach, if attachment exists but it is not in a valid status for change, log error
              l_Token_Tbl.delete;
              l_Token_Tbl(1).Token_name := 'ACTION';
              l_Token_Tbl(1).Token_Value := l_action_name;
              l_Token_Tbl(2).Token_name := 'STATUS';
              l_Token_Tbl(2).Token_Value := l_status_name;
              l_Token_Tbl(3).Token_name := 'FILE';
              l_Token_Tbl(3).Token_Value := ac.file_name;

              Error_Handler.Add_Error_Token(
                  p_Message_Name       => 'ENG_PRP_ATT_STATUS_FAIL'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
               );

              l_error_logged := G_VAL_TRUE;

          END IF;
        END IF;

        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value: l_error_logged'||l_error_logged);

        IF (l_error_logged = G_VAL_TRUE)
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            -- Log any messages that have been logged with the additional error
            -- message into error handler
            Eco_Error_Handler.Log_Error(
                p_error_status         => FND_API.G_RET_STS_ERROR
              , p_mesg_token_tbl       => l_mesg_token_tbl
              , p_error_scope          => Error_Handler.G_SCOPE_ALL
              , p_error_level          => Eco_Error_Handler.G_ATCH_LEVEL
              , x_eco_rec              => ENG_Eco_PUB.G_MISS_ECO_REC
              , x_eco_revision_tbl     => ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
              , x_change_line_tbl      => ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL -- Eng Change
              , x_revised_item_tbl     => ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
              , x_rev_component_tbl    => ENG_Eco_PUB.G_MISS_REV_COMPONENT_TBL
              , x_ref_designator_tbl   => ENG_Eco_PUB.G_MISS_REF_DESIGNATOR_TBL
              , x_sub_component_tbl    => ENG_Eco_PUB.G_MISS_SUB_COMPONENT_TBL
              , x_rev_operation_tbl    => ENG_Eco_PUB.G_MISS_REV_OPERATION_TBL
              , x_rev_op_resource_tbl  => ENG_Eco_PUB.G_MISS_REV_OP_RESOURCE_TBL
              , x_rev_sub_resource_tbl => ENG_Eco_PUB.G_MISS_REV_SUB_RESOURCE_TBL
             );
            -- local change id is set later
            -- if there are errors, based on the level they are not populated in the
            -- maps table.
            Eng_Propagation_Log_Util.add_entity_map(
                p_change_id                 => p_change_id
              , p_revised_item_sequence_id  => p_rev_item_sequence_id
              , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
              , p_revised_line_id1          => ac.change_document_id
              , p_local_organization_id     => p_local_organization_id
              , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
              , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
              , p_bo_entity_identifier      => 'ATCH'--Eco_Error_Handler.G_ATCH_LEVEL
             );
        ELSE
            /*Eng_Propagation_Log_Util.add_entity_map(
                p_change_id                 => p_change_id
              , p_revised_item_sequence_id  => p_rev_item_sequence_id
              , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_ATCH_CHG
              , p_revised_line_id1          => ac.change_document_id
              , p_local_organization_id     => p_local_organization_id
              , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
              , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS
              , p_bo_entity_identifier      => 'ATCH'--Eco_Error_Handler.G_ATCH_LEVEL
             );*/
             null;-- do nothing
        END IF;

    END LOOP;

    IF(l_error_logged <> G_VAL_TRUE)
    THEN
        OPEN c_check_item_level_changes;
        FETCH c_check_item_level_changes INTO l_check_item_changes;
        IF c_check_item_level_changes%FOUND
        THEN
            l_token_tbl.delete;
            Error_Handler.Add_Error_Token(
                p_Message_Name       => 'ENG_PRP_ATT_ITEMCHG_INFO'
              , p_Mesg_Token_Tbl     => x_mesg_token_tbl -- to be passed as o/p to the RI log error
              , x_Mesg_Token_Tbl     => x_mesg_token_tbl
              , p_Token_Tbl          => l_token_tbl
              , p_message_type       => 'I'
             );
        END IF;
    ELSE
        l_token_tbl.delete;
        Error_Handler.Add_Error_Token(
            p_Message_Name       => 'ENG_PRP_ATT_REVITEM_ERR'
          , p_Mesg_Token_Tbl     => x_mesg_token_tbl
          , x_Mesg_Token_Tbl     => x_mesg_token_tbl
          , p_Token_Tbl          => l_token_tbl
         );
    END IF;
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Validate_Attach_Lines.END');

EXCEPTION
WHEN OTHERS THEN
    IF (c_check_item_level_changes%ISOPEN)
    THEN
        CLOSE c_check_item_level_changes;
    END IF;
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Validate_Attach_Lines.ERROR');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in validation attachments ' || SQLERRM);
    l_error_logged := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    Error_Handler.Add_Error_Token(
        p_Message_Name   => NULL
      , p_Message_Text   => 'Unexpected Error Occurred when validating attachment changes' ||SQLERRM
      , p_Mesg_Token_Tbl => x_Mesg_Token_Tbl
      , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
     );

END Validate_Attach_Lines;

PROCEDURE Check_Revised_Item_Errors (
    p_change_notice            IN VARCHAR2
  , p_global_org_id            IN NUMBER
  , p_local_org_id             IN NUMBER
  , p_rev_item_seq_id          IN NUMBER
  , p_revised_item_id          IN NUMBER
  , p_use_up_item_id           IN NUMBER
  , p_transfer_item_enable     IN NUMBER
  , p_transfer_or_copy         IN VARCHAR2
  , p_transfer_or_copy_item    IN NUMBER
  , p_status_master_controlled IN NUMBER
  , x_error_logged             OUT NOCOPY NUMBER
  , x_mesg_token_tbl           OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_propagate_strc_changes   OUT NOCOPY NUMBER
  , x_sourcing_rules_exists    OUT NOCOPY NUMBER
  , x_revised_item_name        OUT NOCOPY VARCHAR2
) IS

   CURSOR c_rev_item_struc_lines (v_rev_item_seq_id NUMBER)
   IS
   SELECT eri.revised_item_id, eri.revised_item_sequence_id, eri.alternate_bom_designator
        , eri.change_notice, eri.from_end_item_rev_id, eri.from_end_item_strc_rev_id
        , bsb.source_bill_sequence_id, eri.bill_sequence_id
     FROM eng_revised_items eri, bom_structures_b bsb
    WHERE eri.bill_sequence_id = bsb.bill_sequence_id
      AND ((eri.revised_item_sequence_id = v_rev_item_seq_id
           AND eri.bill_sequence_id IS NOT NULL
           AND (eri.transfer_or_copy IS NULL
                OR (eri.transfer_or_copy IS NOT NULL
                    AND eri.enable_item_in_local_org IS NOT NULL
                    AND nvl(eri.transfer_or_copy_bill, 2) = 2
                    AND nvl(eri.transfer_or_copy_routing, 2) = 2)
               )
          )
          -- Commented for bug 4946796
          /*OR (eri.parent_revised_item_seq_id = v_rev_item_seq_id
              AND eri.transfer_or_copy is null)*/);

   -- Commented for bug 4946796
   /*CURSOR c_rev_items_for_enable (v_rev_item_seq_id NUMBER)
   IS
   select distinct eri.revised_item_id, msikfv.concatenated_segments item_name
   from eng_revised_items eri, mtl_system_items_b_kfv msikfv
   where eri.revised_item_id = msikfv.inventory_item_id
   and eri.organization_id = msikfv.organization_id
   and eri.parent_revised_item_seq_id = v_rev_item_seq_id
   and (eri.transfer_or_copy is not null and eri.transfer_or_copy = 'T')
   and eri.enable_item_in_local_org = 'Y'
   and eri.revised_item_id not in (SELECT inventory_item_id
    FROM   mtl_system_items_b_kfv
    WHERE  inventory_item_id = eri.revised_item_id
    AND    organization_id = p_local_org_id);*/

   -- Commented for bug 4946796
  /* Cursor for transfer, obsolete, lifecycle_phase_change , copy items */

  /*CURSOR c_tolc_items
  IS
  select *
  from eng_revised_items
  where (parent_revised_item_seq_id = p_rev_item_seq_id
  or revised_item_sequence_id = p_rev_item_seq_id)
  and transfer_or_copy is not null
  AND revised_item_sequence_id NOT IN (SELECT revised_item_sequence_id
      FROM eng_revised_items
      WHERE parent_revised_item_seq_id = p_rev_item_seq_id
      AND (transfer_or_copy = 'L' OR transfer_or_copy = 'O')
      AND 1 = p_status_master_controlled);*/

  l_item_exists_in_org_flag   NUMBER;
  l_check_invalid_objects     NUMBER;
  l_return_status             VARCHAR2(1);

  l_use_up_item_exists         NUMBER;
  l_item_sourced_flag          NUMBER := 2;
  l_structure_exists_flag      NUMBER;
  l_revised_item_number        mtl_system_items_kfv.concatenated_segments%TYPE;
  l_common_bom_flag            NUMBER;
  l_local_bill_sequence_id     NUMBER;
  l_comn_bill_sequence_id      NUMBER;
  l_eng_bill_flag              NUMBER;
  l_error_logged               NUMBER := 0;
--  l_eco_error_tbl              Eco_Error_Tbl_Type;
--  l_err_counter                NUMBER;
--  l_eco_mesg_tbl               Eco_Error_Tbl_Type;
--  l_mesg_counter               NUMBER;
  l_local_revised_item_exists  NUMBER := 0;

  l_struc_line_tbl             Eco_Struc_Line_Tbl_Type;
  l_struc_count                NUMBER := 1;
  l_component_not_available    NUMBER;

  l_fei_strc_revision          VARCHAR2(80);
  l_fei_bill_sequence_id       NUMBER;
  l_fei_strc_item_rev_id       NUMBER;
  --l_fei_alternate              VARCHAR2(80);
  l_fei_strc_item_id           NUMBER;
  l_dummy                      NUMBER;
  l_message_log_text           VARCHAR2(2000);
  l_temp_mesg                  VARCHAR2(2000);
  --l_temp_item_name              VARCHAR2(4000);
  l_transfer_item_sourced_flag NUMBER;
  --l_propagate_strc_changes     NUMBER
  l_item_error_table           INV_ITEM_GRP.Error_Tbl_Type;
  l_create_bill_for_item       NUMBER;
  l_from_end_item_minor_rev_id NUMBER;
  l_from_end_item_rev_id       NUMBER;

  l_Mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  l_Token_Tbl             Error_Handler.Token_Tbl_Type;

  l_eco_chg_exists VARCHAR2(1); -- bug 10146196 added
BEGIN

  Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, '-------------------------------');
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'CHECK_REVISED_ITEM_ERRORS.begin');
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_change_notice    '|| p_change_notice);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_global_org_id    '|| p_global_org_id);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_local_org_id     '|| p_local_org_id);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_rev_item_seq_id  '|| p_rev_item_seq_id);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_transfer_item_enable'|| p_transfer_item_enable);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_use_up_item_id   '|| p_use_up_item_id);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_revised_item_id  '|| p_revised_item_id);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_transfer_or_copy  '|| p_transfer_or_copy);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_transfer_or_copy_item   '||  p_transfer_or_copy_item);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Input Param:  p_status_master_controlled'|| p_status_master_controlled);

  BEGIN

    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Validation: Checking if revised item already exists in local Change');

    SELECT G_VAL_TRUE
      into l_local_revised_item_exists
      FROM eng_revised_items eri1
     WHERE eri1.change_notice = p_change_notice
       AND eri1.organization_id = p_local_org_id
       AND EXISTS
          (SELECT 1
             FROM eng_revised_items eri2
            WHERE revised_item_sequence_id = p_rev_item_seq_id
              AND eri2.organization_id = p_local_org_id -- bug 10146196 added
              AND eri2.revised_item_id = eri1.revised_item_id
              AND eri2.scheduled_date = eri1.scheduled_date
              AND NVL(eri2.alternate_bom_designator, 'primary') = NVL(eri1.alternate_bom_designator, 'primary'))
       AND eri1.parent_revised_item_seq_id IS NULL
       AND eri1.status_type <> 5
       AND ROWNUM < 2;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_local_revised_item_exists := G_VAL_FALSE;
  END;
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_local_revised_item_exists: '||l_local_revised_item_exists);

  IF (l_local_revised_item_exists = G_VAL_TRUE)
  THEN
      Error_Handler.Add_Error_Token(
          p_Message_Name       => 'ENG_PRP_EXISTS_IN_CO'
        , p_Mesg_Token_Tbl     => l_mesg_token_tbl
        , x_Mesg_Token_Tbl     => l_mesg_token_tbl
        , p_Token_Tbl          => l_token_tbl
       );
       l_error_logged := G_VAL_TRUE;
  ELSE
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Validation: Checking if item exists in local Organization');
    BEGIN
        SELECT 1
        into l_item_exists_in_org_flag
        FROM   mtl_system_items_b_kfv
        WHERE  inventory_item_id = p_revised_item_id
        AND    organization_id = p_local_org_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_item_exists_in_org_flag := 0;
    END;

    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_item_exists_in_org_flag: '||l_item_exists_in_org_flag);

    SELECT concatenated_segments
    into l_revised_item_number
    FROM   mtl_system_items_b_kfv
    WHERE  inventory_item_id = p_revised_item_id
    AND    organization_id = g_global_org_id;

    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_revised_item_number: '||l_revised_item_number);

    -- 11.5.10 Feature: Scoped Out
    -- If item does not exist in local organization but it is set to be enabled per organization
    -- at the change type level, then check if it is a transfer item and Auto Enable
    IF (l_item_exists_in_org_flag = 0 AND  p_transfer_item_enable = 1)
    THEN
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Item does not exist in Organization and it is supposed to be enabled for tranfer');
        -- Enable item in local org
        IF (p_transfer_or_copy = 'T' AND p_transfer_or_copy_item = 1 )
        THEN
            Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Transfer Item Enabling In Progress ..');
            AUTO_ENABLE_ITEM_IN_ORG(
                p_inventory_item_id   => p_revised_item_id
              , p_organization_id => p_local_org_id
              , x_error_table     => l_item_error_table
              , x_return_status   => l_return_status);

            IF (l_return_status = 'S')
            THEN
                Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Transfer Item Enabling Successful');
                l_item_exists_in_org_flag := 1;

                l_token_tbl.delete;
                l_token_tbl(1).token_name  := 'ITEM';
                l_token_tbl(1).token_value := l_revised_item_number;
                Error_Handler.Add_Error_Token(
                    p_Message_Name       => 'ENG_PRP_TRNSMFG_ENABLED'
                  , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                  , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                  , p_Token_Tbl          => l_token_tbl
                  , p_message_type       => 'I' );
            ELSE
                l_error_logged := G_VAL_TRUE;
                Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Transfer Item Enabling Error');
                FOR i IN 1..l_item_error_table.COUNT
                LOOP
                    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Transfer Item Enabling Error:'||l_item_error_table(i).message_name);
                    Error_Handler.Add_Error_Token(
                        p_Message_Name   => NULL
                      , p_Message_Text   => l_item_error_table(i).message_text
                      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     );
                END LOOP;
                -- Resetting the item error table
                l_item_error_table.delete;
            END IF;
        END IF;
    END IF;

    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value Post Auto Enable for transfer l_item_exists_in_org_flag: '||l_item_exists_in_org_flag);

    -- If Item does not exist in local organization throw an error
    IF (l_item_exists_in_org_flag = 0)
    THEN
        Error_Handler.Add_Error_Token(
            p_Message_Name       => 'ENG_PRP_DOES_NOT_EXIST'
          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
          , p_Token_Tbl          => l_token_tbl
         );
        l_error_logged := 1;
    ELSIF (l_item_exists_in_org_flag = 1 AND p_use_up_item_id IS NOT NULL)
    THEN
        -- If item exists check for use up item
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Validation: Check if use up item Exists');
        BEGIN
            SELECT 1
              INTO l_use_up_item_exists
              FROM mtl_system_items
             WHERE inventory_item_id = p_use_up_item_id
               AND organization_id = p_local_org_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            Error_Handler.Add_Error_Token(
                p_Message_Name       => 'ENG_PRP_INVAL_USEUP'
              , p_Mesg_Token_Tbl     => l_mesg_token_tbl
              , x_Mesg_Token_Tbl     => l_mesg_token_tbl
              , p_Token_Tbl          => l_token_tbl);
            l_error_logged := 1;
            l_item_exists_in_org_flag := 0;
        END;
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_use_up_item_exists'|| l_use_up_item_exists);
    END IF;

    --
    -- Proceed with processing only if item and Use up exists in local Organization
    IF (l_item_exists_in_org_flag = 1)
    THEN
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Proceed with processing as item and use up are valid for local Organization');
        x_propagate_strc_changes := G_VAL_TRUE;
        --
        -- Check if sourcing rules exist for item
        l_item_sourced_flag := CHECK_SOURCING_RULES(p_local_org_id , p_revised_item_id);
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Fetch sourcing rules for item in local organization Value: l_item_sourced_flag'||l_item_sourced_flag);

        --
        -- Check if structure line - bill exists
        FOR sl in c_rev_item_struc_lines(p_rev_item_seq_id)
        LOOP
            l_structure_exists_flag := 1;
            BEGIN
                select bill_sequence_id, source_bill_sequence_id
                  into l_local_bill_sequence_id, l_comn_bill_sequence_id
                  FROM BOM_BILL_OF_MATERIALS
                 WHERE assembly_item_id = sl.revised_item_id
                   AND organization_id  = p_local_org_id
                   AND nvl(alternate_bom_designator, 'PRIMARY') = nvl(sl.alternate_bom_designator, 'PRIMARY');
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_structure_exists_flag := 0;
            END;

            -- Bug 3503525:
            -- If all the components are of type add and stryctur does not exist,
            -- then the ECO BO create the primary bill.
            -- Hence should not throw error "Structute does not exist" in such a case.
            IF(l_structure_exists_flag = 0)
            THEN
                l_create_bill_for_item := 0;
                BEGIN
                    -- Check if all components are of type add the l_create_bill_for_item = 1
                    -- l_create_bill_for_item = 0 otherwise
                    SELECT 1, 1
                    INTO l_structure_exists_flag, l_create_bill_for_item
                    FROM dual
                    WHERE NOT EXISTS (SELECT 1
                        FROM bom_inventory_components
                        WHERE change_notice = sl.change_notice
                        AND revised_item_sequence_id = sl.revised_item_sequence_id
                        AND acd_type IN (2,3));
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
                END;
            END IF;
            Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_structure_exists_flag:' || l_structure_exists_flag);
            Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value l_create_bill_for_item:' || l_create_bill_for_item);

            IF (l_item_sourced_flag = 1 AND l_structure_exists_flag = 1)
            THEN
                -- Log a message and do not continue
                Error_Handler.Add_Error_Token(
                    p_Message_Name       => 'ENG_PRP_SRC_RULES'
                  , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                  , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                  , p_Token_Tbl          => l_token_tbl
                  , p_message_type       => 'I');

                EXIT; --  Exits Loop
            ELSIF (l_item_sourced_flag = 2)
            THEN
                -- if this is an end item effective structure change
                -- then it will not be propgated to the child organization
                IF sl.from_end_item_rev_id IS NOT NULL
                THEN
                    x_propagate_strc_changes := G_VAL_FALSE;
                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_REVEFF_STRC_DISABLED'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl
                      , p_message_type       => 'I' );

                ELSIF sl.bill_sequence_id <> nvl(sl.source_bill_sequence_id, sl.bill_sequence_id)
                THEN
                    x_propagate_strc_changes := G_VAL_FALSE;
                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_COMN_STRC_DISABLED'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl
                      , p_message_type       => 'I' );
                ELSIF l_structure_exists_flag = 0
                THEN
                    l_token_tbl.delete;
                    l_token_tbl(1).token_name  := 'STRUCTURE';
                    l_token_tbl(1).token_value := sl.alternate_bom_designator;
                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_STRC_NOT_EXISTS'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl);
                    l_error_logged := 1;
                ELSIF l_structure_exists_flag = 1
                THEN
                    -- if all components are of type add,
                    -- initialize the structure line pl/sql table with defaults, so that they are not validated
                    IF (l_create_bill_for_item = 1)
                    THEN
                        l_local_bill_sequence_id := 0;
                        l_comn_bill_sequence_id := 0;
                        l_from_end_item_minor_rev_id := null;
                        l_from_end_item_rev_id := null;
                    ELSE
                        l_from_end_item_minor_rev_id := sl.from_end_item_strc_rev_id;
                        l_from_end_item_rev_id := sl.from_end_item_rev_id;
                    END IF;

                    l_struc_line_tbl(l_struc_count).revised_item_sequence_id := sl.revised_item_sequence_id;
                    l_struc_line_tbl(l_struc_count).alternate_bom_designator := sl.alternate_bom_designator;
                    l_struc_line_tbl(l_struc_count).bill_sequence_id := sl.bill_sequence_id;
                    l_struc_line_tbl(l_struc_count).local_bill_sequence_id := l_local_bill_sequence_id;
                    l_struc_line_tbl(l_struc_count).comn_bill_sequence_id := l_comn_bill_sequence_id;
                    l_struc_line_tbl(l_struc_count).from_end_item_minor_rev_id := l_from_end_item_minor_rev_id;
                    l_struc_line_tbl(l_struc_count).from_end_item_rev_id := l_from_end_item_rev_id;

                END IF;
            END IF;
        END LOOP;

        --
        -- if all structures exist
        -- auto enable transfer items with enable item in local org -> 'Y'. Log Info
        -- auto enable comps and subs comps of acd_type add if item is not sourced. Log Info
        -- For all components and substitute comps not in local org, log error
        -- For invalid from_end_item dtls , log error
        /*IF (l_error_logged = 0)
        THEN
            -- get all items with enable item for transfer
            -- Scoped out
            FOR tle in c_rev_items_for_enable(p_rev_item_seq_id)
            LOOP
                AUTO_ENABLE_ITEM_IN_ORG(
                    p_inventory_item_id   => tle.revised_item_id
                  , p_organization_id => p_local_org_id
                  , x_error_table     => l_item_error_table
                  , x_return_status   => l_return_status);
                IF (l_return_status = 'S')
                THEN
                    l_token_tbl.delete;
                    l_token_tbl(1).token_name  := 'ITEM';
                    l_token_tbl(1).token_value := tle.item_name;
                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_TRNSMFG_ENABLED'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl
                      , p_message_type       => 'I' );
                ELSE
                    FOR i IN 1..l_item_error_table.COUNT
                    LOOP
                        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Transfer Item Enabling Error:'||l_item_error_table(i).message_name);
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'MESSAGE';
                        l_token_tbl(1).token_value := l_item_error_table(i).message_name;
                        Error_Handler.Add_Error_Token(
                            p_Message_Name       => 'ENG_ERROR_MESSAGE'
                          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , p_Token_Tbl          => l_token_tbl
                         );

                        l_error_logged := 1;
                    END LOOP;
                    l_item_error_table.delete;
                END IF;
            END LOOP;
        END IF;*/

        IF (l_error_logged = 0)
        THEN
            -- If no errors logged so far then process Transfer components
            -- Currently scoped out , transfer/copy components are not propagated. Loop does not process
            /*FOR tolc IN c_tolc_items
            LOOP

                BEGIN
                    select 1
                    into    l_item_exists_in_org_flag
                    FROM   mtl_system_items_b
                    WHERE  inventory_item_id = tolc.revised_item_id
                    AND    organization_id = p_local_org_id;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_item_exists_in_org_flag := 0;
                END;
                IF (l_item_exists_in_org_flag = 0)
                THEN
                    select concatenated_segments
                    into l_temp_item_name
                    from mtl_system_items_b_kfv
                    where inventory_item_id = tolc.revised_item_id
                    and organization_id = p_global_org_id;

                    Fnd_message.set_name('ENG', 'ENG_PRP_ITM_NOT_EXISTS');
                    fnd_message.set_token('ITEM', l_temp_item_name);
                    l_message_log_text := fnd_message.get();

                    l_eco_error_tbl(l_err_counter).Revised_item_sequence_id := p_rev_item_seq_id;
                    l_eco_error_tbl(l_err_counter).log_text := l_message_log_text;
                    l_eco_error_tbl(l_err_counter).log_type := 'ERROR';
                    l_err_counter := l_err_counter + 1;
                    l_error_logged := 1;

                ELSIF (l_item_exists_in_org_flag = 1 AND tolc.transfer_or_copy_bill = 1)
                THEN
                        BEGIN
                        l_structure_exists_flag := 1;
                        select bill_sequence_id, common_bill_sequence_id, assembly_type
                        into l_local_bill_sequence_id, l_comn_bill_sequence_id, l_eng_bill_flag
                        FROM BOM_BILL_OF_MATERIALS
                        WHERE assembly_item_id = tolc.revised_item_id
                        AND   organization_id  = p_local_org_id
                        AND   nvl(alternate_bom_designator, 'PRIMARY') = nvl(tolc.alternate_bom_designator, 'PRIMARY');
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_structure_exists_flag := 0;
                    END;
                    IF (l_structure_exists_flag = 0)
                    THEN
                        Fnd_message.set_name('ENG', 'ENG_ITEM_LC_PHASE_CHG_LINE');
                        l_temp_mesg := fnd_message.get();
                        Fnd_message.set_name('ENG', 'ENG_PRP_STRC_NOT_EXISTS');
                        fnd_message.set_token('STRUCTURE', tolc.alternate_bom_designator);
                        fnd_message.set_token('LINE', l_temp_mesg);
                        l_message_log_text := fnd_message.get();

                        l_error_logged := 1;
                        l_eco_error_tbl(l_err_counter).Revised_item_sequence_id := p_rev_item_seq_id;
                        l_eco_error_tbl(l_err_counter).log_text := l_message_log_text;
                        l_eco_error_tbl(l_err_counter).log_type := 'ERROR';
                        l_err_counter := l_err_counter + 1;
                    ELSE
                        l_transfer_item_sourced_flag := 2;

                        IF (l_comn_bill_sequence_id <> l_local_bill_sequence_id
                            AND tolc.transfer_or_copy = 'T'
                            AND tolc.create_bom_in_local_org = 'Y'
                            AND l_comn_bill_sequence_id = tolc.bill_sequence_id
                            AND l_eng_bill_flag <> 1)
                        THEN

                            -- check if sourcing rules exist for item
                            l_transfer_item_sourced_flag := CHECK_SOURCING_RULES(p_local_org_id, tolc.revised_item_id);

                            IF ( l_transfer_item_sourced_flag = 2)
                            THEN
                                BREAK_COMMON_BOM(
                                    p_to_sequence_id    => l_local_bill_sequence_id
                                  , p_from_sequence_id  => tolc.bill_sequence_id
                                  , p_from_org_id       => p_global_org_id
                                  , p_to_org_id         => p_local_org_id
                                  , p_to_item_id        => tolc.revised_item_id
                                  , p_to_alternate      => tolc.alternate_bom_designator
                                  , p_from_item_id      => tolc.revised_item_id);

                                l_comn_bill_sequence_id := l_local_bill_sequence_id;

                                Fnd_message.set_name('ENG', 'ENG_PRP_COMN_BOM_BREAK');
                                fnd_message.set_token('STRUCTURE', tolc.alternate_bom_designator);
                                l_message_log_text := fnd_message.get();
                                l_eco_mesg_tbl(l_mesg_counter).Revised_item_sequence_id := p_rev_item_seq_id;
                                l_eco_mesg_tbl(l_mesg_counter).log_text := l_message_log_text;
                                l_eco_mesg_tbl(l_mesg_counter).log_type := 'INFO';
                                l_mesg_counter := l_mesg_counter + 1;
                            END IF;

                            IF (l_comn_bill_sequence_id <> l_local_bill_sequence_id
                                AND l_transfer_item_sourced_flag = 2
                                AND l_eng_bill_flag <> 1)
                            THEN
                                Fnd_message.set_name('ENG', 'ENG_ITEM_LC_PHASE_CHG_LINE');
                                l_temp_mesg := fnd_message.get();
                                Fnd_message.set_name('ENG', 'ENG_PRP_COMMON_BOM');
                                fnd_message.set_token('STRUCTURE', tolc.alternate_bom_designator);
                                fnd_message.set_token('LINE', l_temp_mesg);
                                l_message_log_text := fnd_message.get();

                                l_error_logged := 1;
                                l_eco_error_tbl(l_err_counter).Revised_item_sequence_id := p_rev_item_seq_id;
                                l_eco_error_tbl(l_err_counter).log_text := l_message_log_text;
                                l_eco_error_tbl(l_err_counter).log_type := 'ERROR';
                                l_err_counter := l_err_counter + 1;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END LOOP;*/

            -- Further Process structure changes
            -- Doing this validation after break common for tolc revised items
            -- Check if the structure is common an delete sturcture line from being processed.
            -- Only attachment changes should be processed for there revised items
            IF (l_item_sourced_flag = 2)
            THEN
                -- bug 10146196, check added to see if ECO has bill changes
                BEGIN
                  select decode(count(*),0,'N','Y') --bug 14573265
                  into l_eco_chg_exists
                  from bom_inventory_components
                  where change_notice = p_change_notice
                  and pk2_value = p_local_org_id;    --bug 14051321, add org_id to avoid error ORA-01422

                  EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_eco_chg_exists := 'N';
                END;

                if (l_eco_chg_exists = 'Y' ) then -- with 'end if', end 10146196
                -- check all structures lines for common bom
                FOR i IN 1..l_struc_line_tbl.COUNT
                LOOP
                    IF (l_struc_line_tbl(i).local_bill_sequence_id <> l_struc_line_tbl(i).comn_bill_sequence_id)
                    THEN
                        Fnd_message.set_name('ENG', 'ENG_STRUCTURE_CHG_LINE');
                        l_temp_mesg := fnd_message.get();
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'STRUCTURE';
                        l_token_tbl(1).token_value := l_struc_line_tbl(i).alternate_bom_designator;
                        l_token_tbl(2).token_name  := 'LINE';
                        l_token_tbl(2).token_value := l_temp_mesg;
                        Error_Handler.Add_Error_Token(
                            p_Message_Name       => 'ENG_PRP_COMMON_BOM'
                          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , p_Token_Tbl          => l_token_tbl);
                        l_error_logged := 1;
                        --l_struc_line_tbl(i).delete;
                    END IF;
                END LOOP;
                END IF; -- if (l_eco_chg_exists = 'Y') then
            END IF;
        END IF;
    END IF;
  END IF;

  x_sourcing_rules_exists := l_item_sourced_flag;
  x_error_logged := l_error_logged;
  x_revised_item_name := l_revised_item_number;
  x_Mesg_Token_Tbl := l_mesg_token_tbl;

  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Output Param:  p_propagate_revised_item    '|| l_item_exists_in_org_flag);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Output Param:  p_sourcing_rules_exists    '|| l_item_sourced_flag);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Output Param:  p_error_logged     '|| l_error_logged);
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Output Param:  p_revised_item_name  '|| l_revised_item_number);

  Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'CHECK_REVISED_ITEM_ERRORS.end');
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, '-------------------------------');
EXCEPTION
WHEN OTHERS THEN
  Eng_Propagation_Log_Util.Debug_Log(Eng_Propagation_Log_Util.G_LOG_ERROR, 'CHECK_REVISED_ITEM_ERRORS.Unexpected error'|| SQLERRM);
END Check_Revised_Item_Errors;

PROCEDURE PROPAGATE_ECO_ERP
(
   errbuf                 OUT NOCOPY   VARCHAR2,
   retcode                OUT NOCOPY    VARCHAR2,
   p_change_notice        IN     VARCHAR2,
   p_org_hierarchy_name   IN     VARCHAR2,
   p_org_hierarchy_level  IN     VARCHAR2
)
IS
   l_eco_rec                   Eng_Eco_Pub.Eco_Rec_Type;
   l_change_lines_tbl          Eng_Eco_Pub.Change_Line_Tbl_Type;
   l_eco_revision_tbl          Eng_Eco_Pub.Eco_Revision_Tbl_Type;
   l_revised_item_tbl          Eng_Eco_Pub.Revised_Item_Tbl_Type;
   l_rev_component_tbl         Bom_Bo_Pub.Rev_Component_Tbl_Type;
   l_sub_component_tbl         Bom_Bo_Pub.Sub_Component_Tbl_Type;
   l_ref_designator_tbl        Bom_Bo_Pub.Ref_Designator_Tbl_Type;
   l_rev_operation_tbl         Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
   l_rev_op_resource_tbl       Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
   l_rev_sub_resource_tbl      Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

   l_org_code_list             INV_OrgHierarchy_PVT.OrgID_tbl_type;
   l_org_hierarchy_level_id    NUMBER;
   l_org_code                  VARCHAR2(3);
   l_org_id                    NUMBER;
   l_change_type_code          VARCHAR2(80);
   l_requestor_name            VARCHAR2(30);
   l_assignee_name             VARCHAR2(30);
   l_Task_Number           VARCHAR2(25);
   /* changing for UTF8 Column Expansion */
   l_Project_Number        VARCHAR2(30);
   l_rev_description           VARCHAR2(240);
   l_rev_label                 mtl_item_revisions.revision_label%type; --added for bug 26076967
   l_approval_list_name        VARCHAR2(10);
   /* changing for UTF8 Column Expansion */
   l_department_name           VARCHAR2(240);
   l_revised_item_number       VARCHAR2(801);
   l_use_up_item_name          VARCHAR2(801);
   l_revised_item_name         VARCHAR2(801);
   l_new_item_revision         VARCHAR2(3);
   l_effectivity_date          DATE;
   l_revised_item_name1        VARCHAR2(801);
   l_revised_item_name2        VARCHAR2(801);
   l_component_item_name       VARCHAR2(801);
   l_component_item_name1      VARCHAR2(801);
   l_component_item_name2      VARCHAR2(801);
   l_location_name             VARCHAR2(81);
   l_substitute_component_name VARCHAR2(801);
   l_operation_seq_num         NUMBER;
   l_item_exits_in_org_flag    NUMBER;
   l_check_invalid_objects     NUMBER := 1;

   l_return_status             VARCHAR2(1);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);
   l_Error_Table               Error_Handler.Error_Tbl_Type;
   l_Message_text              VARCHAR2(2000);

   l_org_count                 NUMBER;
   l_count                     NUMBER;
   temp_count                  NUMBER := 0;
   i                           NUMBER;
   item_id                     NUMBER;
   bill_id                     NUMBER;
   old_operation_seq_num       NUMBER;
   old_effectivity_date        DATE;
   l_old_effectivity_date        DATE;
   component_seq_id            NUMBER;
   St_Number               NUMBER;

   l_eco_status_name          eng_change_statuses_vl.status_name%TYPE; -- bug 3571079

-- Added for Bug-5725081

   v_component_quantity_to     NUMBER ;
   v_component_low_quantity    NUMBER ;
   v_component_high_quantity   NUMBER ;
   v_substitute_item_quantity  NUMBER ;
   l_new_change_id NUMBER; /* bug #7496156*/
   l_alternate_bom  VARCHAR2(10) ; /* for bug 9368374 */
/* Cursor to Pick all ECO header for the Top Organization for the given Change N
otice */

   CURSOR c_eco_rec IS
   SELECT *
   FROM   eng_changes_v
   WHERE  change_notice = p_change_notice
   AND    organization_id = l_org_hierarchy_level_id;

/* Cursor to Pick all Revised Items for the Top Organization  for the given Chan
ge Notice*/

   CURSOR c_eco_revision IS
   SELECT *
   FROM   eng_change_order_revisions
   WHERE  change_notice = p_change_notice
   AND    organization_id = l_org_hierarchy_level_id;

/* Cursor to Pick all Revised Items for the Top Organization  for the given Chan
ge Notice.Bug no 4327321  only revised items will get propagate.No transfer and copy items.*/

   CURSOR c_rev_items IS
   SELECT *
   FROM   eng_revised_items
   WHERE  change_notice = p_change_notice
   AND    organization_id = l_org_hierarchy_level_id
   AND  transfer_or_copy is NULL;


/* cursor to pick up Revised component records for the top organization for
  the given change notice which have the ACD_type of Disable and have been
  implementedfrom eng_revised_items table. These records are not present in
  bom_inventory_components table hence this extra cursor. */

   CURSOR c_rev_comps_disable IS
   SELECT *
   FROM   eng_revised_components
   WHERE  change_notice = p_change_notice
   AND    ACD_TYPE = 3
   AND    revised_item_sequence_id in
      (SELECT revised_item_sequence_id
          FROM   eng_revised_items
          WHERE  change_notice = p_change_notice
          AND    organization_id = l_org_hierarchy_level_id);

/* Cursor to Pick all Revised Component Items for the Top Organization  for the
given Change Notice*/

   CURSOR c_rev_comps IS
   SELECT *
   FROM   bom_inventory_components
   WHERE  change_notice = p_change_notice
   AND    revised_item_sequence_id in
          (SELECT revised_item_sequence_id
          FROM   eng_revised_items
          WHERE  change_notice = p_change_notice
          AND    organization_id = l_org_hierarchy_level_id);

/* Cursor to Pick all substitute Component Items for the Top Organization  for t
he given Change Notice*/

   CURSOR c_sub_comps IS
   SELECT *
   FROM   bom_substitute_components
   WHERE  change_notice = p_change_notice
   AND    component_sequence_id in
          (SELECT component_sequence_id
          FROM   bom_inventory_components
          WHERE  change_notice = p_change_notice
          AND    revised_item_sequence_id in
                 (SELECT revised_item_sequence_id
                 FROM   eng_revised_items
                 WHERE  change_notice = p_change_notice
                 AND    organization_id = l_org_hierarchy_level_id));

/* Cursor to Pick all reference designators for the Top Organization  for the gi
ven Change Notice*/

   CURSOR c_ref_desgs IS
   SELECT *
   FROM   bom_reference_designators
   WHERE  change_notice = p_change_notice
   AND    component_sequence_id in
          (SELECT component_sequence_id
          FROM   bom_inventory_components
          WHERE  change_notice = p_change_notice
          AND    revised_item_sequence_id in
                 (SELECT revised_item_sequence_id
                 FROM   eng_revised_items
                 WHERE  change_notice = p_change_notice
                 AND    organization_id = l_org_hierarchy_level_id));

   -- Modified query for performance bug 4251776
   -- Bug No: 4327218
   -- Modified query to refer to 'person_party_id' instead of 'customer_id'
   CURSOR c_user_name(v_party_id IN NUMBER) IS
   SELECT us.user_name FROM fnd_user us, hz_parties pa
   WHERE ((us.employee_id IS NOT NULL AND us.employee_id = pa.person_identifier))
   AND pa.party_id = v_party_id
   union all
   SELECT us.user_name
   FROM fnd_user us, hz_parties pa
   WHERE (us.employee_id IS NULL AND (us.person_party_id= pa.party_id or (us.person_party_id is null and us.supplier_id = pa.party_id)))
   AND pa.party_id = v_party_id;

/*   WHERE nvl(us.employee_id, nvl(us.customer_id, us.supplier_id)) = pa.person_identifier
     AND pa.party_id = v_party_id;*/

  -- Bug 4339626
  l_status_type     NUMBER;

BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting PROPAGATE_ECO');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'CHANGE_NOTICE '|| p_change_notice);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'HIERARCHY_NAME '|| p_org_hierarchy_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'HIERARCHY_LEVEL '|| p_org_hierarchy_level);

   /* Need the Organization Id to fetch the records */
      SELECT MP.organization_id
      INTO   l_org_hierarchy_level_id
      FROM HR_ORGANIZATION_UNITS HOU
      , HR_ORGANIZATION_INFORMATION HOI1
      , MTL_PARAMETERS MP
      WHERE HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
      AND HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
      AND HOI1.ORG_INFORMATION1 = 'INV'
      AND HOI1.ORG_INFORMATION2 = 'Y'
      AND HOU.NAME = p_org_hierarchy_level;
   /*SELECT organization_id
   INTO   l_org_hierarchy_level_id
   FROM   org_organization_definitions
   WHERE  organization_name = p_org_hierarchy_level;*/

   INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(p_org_hierarchy_name,
                   l_org_hierarchy_level_id,l_org_code_list);


   IF (l_org_code_list.COUNT = 0) THEN

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Organization exists under the Hierarchy Level '|| p_org_hierarchy_name||' and '||p_org_hierarchy_level);

      RETURN;
   END IF;

   IF (l_org_code_list.COUNT = 1) THEN

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Only Organization '|| p_org_hierarchy_level|| ' exists under the Hierarchy Level'|| p_org_hierarchy_name||' and '||p_org_hierarchy_level);

      RETURN;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Organizations in Hierarchy ');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Orgs in Hierarchy = '||l_org_code_list.COUNT);

   FOR l_org_count in 1..l_org_code_list.COUNT
   Loop
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Org : '||l_org_code_list(l_org_count));
   end loop;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'');

   FOR l_org_count in 2..l_org_code_list.LAST
   LOOP                                                /* Loop 1 */

     l_org_id := l_org_code_list(l_org_count);

     /* Need the Organization Code for Populating PL/SQL table */
    -- Bug 4546616
    -- Check Organization is valid using exception handling
    BEGIN

     SELECT organization_code
     INTO   l_org_code
     FROM   mtl_parameters
     WHERE  organization_id = l_org_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    IF l_org_code IS NOT NULL  /* Organization Check*/
    THEN

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Organization '|| l_org_code);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'');


     SELECT count(*)
     into temp_count
     FROM   eng_engineering_changes
     WHERE  change_notice = p_change_notice
     AND    organization_id = l_org_id;

     -- Fetch ECO Masters

     IF temp_count > 0 THEN        /* ECO Check */

         FND_FILE.PUT_LINE(FND_FILE.LOG,'This ECO '||p_change_notice|| 'will not be processed as it already exists in Organization '|| l_org_code);

     ELSE

      FOR eco_rec IN c_eco_rec
      LOOP                                               /* Loop 2 */

         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing ECO Header ...');

         IF (eco_rec.change_order_type_id IS NOT NULL) THEN

            SELECT CHANGE_ORDER_TYPE
            INTO   l_change_type_code
            FROM   eng_change_order_types_v  --11.5.10 Changes
            WHERE  change_order_type_id = eco_rec.change_order_type_id;

         ELSE

            l_change_type_code := NULL;

         END IF;

         IF (eco_rec.responsible_organization_id IS NOT NULL) THEN

            SELECT name
            INTO   l_department_name
            FROM   hr_all_organization_units
            WHERE  organization_id = eco_rec.responsible_organization_id;

         ELSE

            l_department_name := NULL;

         END IF;

         IF (eco_rec.approval_list_id IS NOT NULL) THEN

            SELECT approval_list_name
            INTO   l_approval_list_name
            FROM   eng_ecn_approval_lists
            WHERE  approval_list_id = eco_rec.approval_list_id;

         ELSE

            l_approval_list_name := NULL;

         END IF;

         IF (eco_rec.requestor_id IS NOT NULL) THEN
           begin
             OPEN c_user_name(eco_rec.requestor_id);
             FETCH c_user_name INTO l_requestor_name;
             CLOSE c_user_name;
           exception
             When No_Data_found then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for requestor id ' || to_char( eco_rec.requestor_id) || ' in org ' || to_char(l_org_hierarchy_level_id));
               l_requestor_name := NULL;
           end;

/*
    -- Replaced the before sql for performance.
       Begin
        SELECT employee_num
        INTO   l_requestor_name
        FROM   mtl_employees_view
        WHERE  organization_id = l_org_hierarchy_level_id
        AND    employee_id = eco_rec.requestor_id;
      Exception
        When No_Data_found then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for requestor id ' || to_char( eco_rec.requestor_id) || ' in org ' || to_char(l_org_hierarchy_level_id));
            l_requestor_name := NULL;
      End;
*/
         ELSE

            l_requestor_name := NULL;

         END IF;

         IF (eco_rec.assignee_id IS NOT NULL) THEN
           begin
             OPEN c_user_name(eco_rec.assignee_id);
             FETCH c_user_name INTO l_assignee_name;
             CLOSE c_user_name;
           exception
             When No_Data_found then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for assignee id ' || to_char( eco_rec.assignee_id) || ' in org ' || to_char(l_org_hierarchy_level_id));
               l_assignee_name := NULL;
           end;
         ELSE
            l_assignee_name := NULL;
         END IF;


    IF (eco_rec.PROJECT_ID IS NOT NULL) THEN
         Begin
        SELECT name
        into   l_Project_Number
        FROM   pa_projects_all
        WHERE  project_id = eco_rec.PROJECT_ID;
         Exception
        When No_Data_found then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for project id ' || to_char( eco_rec.PROJECT_ID));
            l_Project_Number := NULL;
      End;
    ELSE
        l_Project_Number := NULL;
    END IF;

    IF (eco_rec.TASK_ID IS NOT NULL) THEN
           Begin
        SELECT task_number
        into   l_Task_Number
        FROM   pa_tasks
        WHERE  TASK_ID = eco_rec.TASK_ID;
       Exception
                When No_Data_found then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for task id ' || to_char( eco_rec.TASK_ID));
            l_Task_Number := NULL;
          End;
    ELSE
        l_Task_Number := NULL;
    END IF;

    --
    -- Bug 4339626
    -- Use the Eng_globals to initialize the details for the process associated to the type
    ENG_Globals.Init_Process_Name(
        p_change_order_type_id => eco_rec.change_order_type_id
      , p_priority_code        => eco_rec.priority_code
      , p_organization_id      => l_org_id);
    -- Setting the destination eco status as scheduled by default
    l_status_type := 4;
    -- If there is no process associated , then schedule the detination eco
    -- Create the destination ECO in Open otherwise.
    -- The following condition is to set the detinaion eco and revised items to open
    IF ENG_Globals.Get_Process_Name IS NOT NULL
    THEN
        l_status_type := 1;
    END IF;
    -- End of Bug 4339626

    -- Added for bug 3571079
    -- Fetch the status corresponding to status_code =4 i.e 'Scheduled'
    BEGIN
        SELECT status_name
        INTO l_eco_status_name
        FROM eng_change_statuses_vl
        WHERE status_code = l_status_type;
    EXCEPTION
    WHEN OTHERS THEN
        l_eco_status_name := eco_rec.eco_status;
    END;
    -- End changes for bug 3571079


    /*  Popuating PL/SQL record for ECO Header    */


         l_eco_rec.eco_name := eco_rec.change_notice;
         l_eco_rec.change_name := eco_rec.change_name; --Added for bug 9405365
         l_eco_rec.organization_code := l_org_code;
         l_eco_rec.change_type_code := l_change_type_code;
         l_eco_rec.status_name := l_eco_status_name; -- eco_rec.eco_status; -- bug 3571079
         l_eco_rec.eco_department_name := l_department_name;
         l_eco_rec.priority_code := eco_rec.priority_code;
         l_eco_rec.approval_list_name := l_approval_list_name;
         l_eco_rec.Approval_Status_Name := eco_rec.approval_status;
         l_eco_rec.reason_code := eco_rec.reason_code;
         l_eco_rec.eng_implementation_cost := eco_rec.estimated_eng_cost;
         l_eco_rec.mfg_implementation_cost := eco_rec.estimated_mfg_cost;
         l_eco_rec.cancellation_comments:=eco_rec.cancellation_comments;
         l_eco_rec.requestor :=  l_requestor_name;
         l_eco_rec.assignee :=  l_assignee_name;
         l_eco_rec.description := eco_rec.description;
     l_eco_rec.attribute_category := eco_rec.attribute_category;
         l_eco_rec.attribute1  := eco_rec.attribute1;
         l_eco_rec.attribute2  := eco_rec.attribute2;
         l_eco_rec.attribute3  := eco_rec.attribute3;
         l_eco_rec.attribute4  := eco_rec.attribute4;
         l_eco_rec.attribute5  := eco_rec.attribute5;
         l_eco_rec.attribute6  := eco_rec.attribute6;
         l_eco_rec.attribute7  := eco_rec.attribute7;
         l_eco_rec.attribute8  := eco_rec.attribute8;
         l_eco_rec.attribute9  := eco_rec.attribute9;
         l_eco_rec.attribute10  := eco_rec.attribute10;
         l_eco_rec.attribute11  := eco_rec.attribute11;
         l_eco_rec.attribute12  := eco_rec.attribute12;
         l_eco_rec.attribute13  := eco_rec.attribute13;
         l_eco_rec.attribute14  := eco_rec.attribute14;
         l_eco_rec.attribute15  := eco_rec.attribute15;
     --l_eco_rec.Original_System_Reference := eco_rec.Original_System_Reference;
         l_eco_rec.Project_Name := eco_rec.Project_Name;
         l_eco_rec.Task_Number := eco_rec.Task_Number;
         --l_eco_rec.hierarchy_flag := 2;
         l_eco_rec.organization_hierarchy := NULL;
         l_eco_rec.return_status := NULL;
         l_eco_rec.transaction_type := 'CREATE';
         --11.5.10
     l_eco_rec.plm_or_erp_change := eco_rec.plm_or_erp_change;
         -- Fetch ECO Revisions

         i := 1;

         FOR rev IN c_eco_revision
         LOOP                                            /* Loop 3 */

         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing ECO Revision ...');

            l_eco_revision_tbl(i).eco_name := rev.change_notice;
            l_eco_revision_tbl(i).organization_code:= l_org_code;
            l_eco_revision_tbl(i).revision := rev.revision;
       --     l_eco_revision_tbl(i).new_revision := rev.new_revision;
        l_eco_revision_tbl(i).new_revision := NULL;
        l_eco_revision_tbl(i).Attribute_category := rev.Attribute_category;
            l_eco_revision_tbl(i).attribute1  := rev.attribute1;
            l_eco_revision_tbl(i).attribute2  := rev.attribute2;
            l_eco_revision_tbl(i).attribute3  := rev.attribute3;
            l_eco_revision_tbl(i).attribute4  := rev.attribute4;
            l_eco_revision_tbl(i).attribute5  := rev.attribute5;
            l_eco_revision_tbl(i).attribute6  := rev.attribute6;
            l_eco_revision_tbl(i).attribute7  := rev.attribute7;
            l_eco_revision_tbl(i).attribute8  := rev.attribute8;
            l_eco_revision_tbl(i).attribute9  := rev.attribute9;
            l_eco_revision_tbl(i).attribute10  :=rev.attribute10;
            l_eco_revision_tbl(i).attribute11  :=rev.attribute11;
            l_eco_revision_tbl(i).attribute12  :=rev.attribute12;
            l_eco_revision_tbl(i).attribute13  := rev.attribute13;
            l_eco_revision_tbl(i).attribute14  := rev.attribute14;
            l_eco_revision_tbl(i).attribute15  := rev.attribute15;
        l_eco_revision_tbl(i).Original_System_Reference :=
                                 rev.Original_System_Reference;
            l_eco_revision_tbl(i).comments := rev.comments;
            l_eco_revision_tbl(i).return_status := NULL;
            l_eco_revision_tbl(i).transaction_type := 'CREATE';

            i := i + 1;

         END LOOP;                                     /* End Loop 3 */

         FND_FILE.PUT_LINE(FND_FILE.LOG,'');

         -- Fetch revised items

         i := 1;

         FOR ri IN c_rev_items
         LOOP                                         /* Loop 4 */

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Revised Items ...');

          BEGIN

             l_item_exits_in_org_flag := 1;

             SELECT concatenated_segments
             INTO   l_revised_item_number
             FROM   mtl_system_items_b_kfv
             WHERE  inventory_item_id = ri.revised_item_id
             AND    organization_id = l_org_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
          l_item_exits_in_org_flag := 0;
              l_check_invalid_objects := 0;
          END;
          /* Added for bug9368374 */
          IF ri.alternate_bom_designator is NOT NULL then
                    BEGIN

                    SELECT ALTERNATE_DESIGNATOR_CODE
                    INTO l_alternate_bom
                    FROM   BOM_ALTERNATE_DESIGNATORS
                    WHERE  ORGANIZATION_ID           = l_org_id
                    AND    ALTERNATE_DESIGNATOR_CODE = ri.alternate_bom_designator;

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          FND_FILE.PUT_LINE(FND_FILE.LOG,'Alternate BOM Designator ' || ri.alternate_bom_designator||' is not defined for Org '||l_org_code);
                          l_check_invalid_objects := 0;
                    END;

                    BEGIN

                    select 1
                    INTO l_alternate_bom
                    FROM BOM_BILL_OF_MATERIALS
                    WHERE assembly_item_id = ri.revised_item_id
                    AND   organization_id  = l_org_id
                    AND   alternate_bom_designator is NULL;

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          FND_FILE.PUT_LINE(FND_FILE.LOG,'Cannot define an Alternate BOM Designator ' ||ri.alternate_bom_designator||' without primary bill for revised item id '|| ri.revised_item_id|| ' in org '||l_org_code);
                          l_check_invalid_objects := 0;
                    END;

          END IF;
           /* Added for bug9368374 */
          IF (l_item_exits_in_org_flag = 1) THEN

             IF (ri.use_up_item_id IS NOT NULL) THEN

               BEGIN
                 SELECT concatenated_segments
                 INTO   l_use_up_item_name
                 FROM   mtl_system_items_b_kfv
                 WHERE  inventory_item_id = ri.use_up_item_id
                 AND    organization_id = l_org_id;
               EXCEPTION WHEN NO_DATA_FOUND THEN
                 l_item_exits_in_org_flag := 0;
                 l_check_invalid_objects := 0;
               END;

             ELSE

               l_use_up_item_name := NULL;

             END IF;

             FND_FILE.PUT_LINE(FND_FILE.LOG,'');

             IF (l_item_exits_in_org_flag = 1) THEN
               l_revised_item_tbl(i).eco_name := ri.change_notice;
               l_revised_item_tbl(i).organization_code := l_org_code;
               l_revised_item_tbl(i).revised_item_name := l_revised_item_number;
               IF ((ri.new_item_revision = FND_API.G_MISS_CHAR) OR
            (ri.new_item_revision IS NULL)) THEN
                  l_revised_item_tbl(i).new_revised_item_revision := NULL;
               ELSE
                  l_revised_item_tbl(i).new_revised_item_revision :=
                                   ri.new_item_revision;
	  /* Modified the query to include revision label for bug 26076967.
	     Prior to this fix, revision label was not propagated correctly.
	     It used to propagate with revision value although user passes
	     some value for revision label. */
              SELECT DESCRIPTION, revision_label
          INTO   l_rev_description, l_rev_label
          FROM   mtl_item_revisions
          WHERE  inventory_item_id = ri.revised_item_id
          AND    organization_id = ri.organization_id
          AND    revision    = ri.new_item_revision ;
              l_revised_item_tbl(i).New_Revised_Item_Rev_Desc :=
                    l_rev_description;
	      l_revised_item_tbl(i).New_Revision_Label := l_rev_label; --added for bug 26076967
              l_revised_item_tbl(i).Updated_Revised_Item_Revision := NULL;
               END IF;
               l_revised_item_tbl(i).start_effective_date :=
            ri.scheduled_date;
           l_revised_item_tbl(i).New_Effective_Date := NULL;
               l_revised_item_tbl(i).alternate_bom_code := ri.alternate_bom_designator; /* for bug 9368374 */
                                     -- NULL;

/*    This is always NULL as we are not creating ALternate Bills in the
      Hierarchy */
/*    Revised Item Status has to be Scheduled as the Propagated ECOs
      have to be scheduled automatically so that they will be picked
      by Auto Implement for Implementation
*/
               l_revised_item_tbl(i).status_type := l_status_type;
               l_revised_item_tbl(i).mrp_active := ri.mrp_active;
               l_revised_item_tbl(i).earliest_effective_date :=
                                   ri.early_schedule_date;
               l_revised_item_tbl(i).use_up_item_name := l_use_up_item_name;
               l_revised_item_tbl(i).use_up_plan_name := ri.use_up_plan_name;
           l_revised_item_tbl(i).Requestor := NULL;
               l_revised_item_tbl(i).disposition_type := ri.disposition_type;
               l_revised_item_tbl(i).update_wip := ri.update_wip;
               l_revised_item_tbl(i).cancel_comments := ri.cancel_comments;
--             l_revised_item_tbl(i).cfm_routing_flag :=
--          ri.cfm_routing_flag;
               l_revised_item_tbl(i).ctp_flag := ri.ctp_flag;
               l_revised_item_tbl(i).return_status := NULL;
               l_revised_item_tbl(i).change_description :=
            ri.descriptive_text;
           l_revised_item_tbl(i).Attribute_category :=
            ri.Attribute_category;
               l_revised_item_tbl(i).attribute1  := ri.attribute1;
               l_revised_item_tbl(i).attribute2  := ri.attribute2;
               l_revised_item_tbl(i).attribute3  := ri.attribute3;
               l_revised_item_tbl(i).attribute4  := ri.attribute4;
               l_revised_item_tbl(i).attribute5  := ri.attribute5;
               l_revised_item_tbl(i).attribute6  := ri.attribute6;
               l_revised_item_tbl(i).attribute7  := ri.attribute7;
               l_revised_item_tbl(i).attribute8  := ri.attribute8;
               l_revised_item_tbl(i).attribute9  := ri.attribute9;
               l_revised_item_tbl(i).attribute10  := ri.attribute10;
               l_revised_item_tbl(i).attribute11  := ri.attribute11;
               l_revised_item_tbl(i).attribute12  := ri.attribute12;
               l_revised_item_tbl(i).attribute13  := ri.attribute13;
               l_revised_item_tbl(i).attribute14  := ri.attribute14;
               l_revised_item_tbl(i).attribute15  := ri.attribute15;
           l_revised_item_tbl(i).From_End_Item_Unit_Number :=
                ri.From_End_Item_Unit_Number;
           l_revised_item_tbl(i).New_From_End_Item_Unit_Number := NULL;
           l_revised_item_tbl(i).Original_System_Reference :=
                    ri.Original_System_Reference;
               l_revised_item_tbl(i).transaction_type := 'CREATE';
--11.5.10 chnages
           l_revised_item_tbl(i).Transfer_Or_Copy          := ri.Transfer_Or_Copy;
           l_revised_item_tbl(i).Transfer_OR_Copy_Item     := ri.Transfer_OR_Copy_Item ;
           l_revised_item_tbl(i).Transfer_OR_Copy_Bill     := ri.Transfer_OR_Copy_Bill  ;
           l_revised_item_tbl(i).Transfer_OR_Copy_Routing  := ri.Transfer_OR_Copy_Routing;
           l_revised_item_tbl(i).Copy_To_Item              := ri.Copy_To_Item;
           l_revised_item_tbl(i).Copy_To_Item_Desc         := ri.Copy_To_Item_Desc;

--11.5.10 changes






               i := i + 1;

            ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Use_Up_Item_id = '||
                               ri.use_up_item_id||' for Org '||l_org_code);

            END IF;

         ELSE

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid revised_item_id = '||
                             ri.revised_item_id||' for Org '||l_org_code);

         END IF;

        END LOOP;                                          /* End Loop 4 */

    -- Fetch revised components for disable and implemented ECO
     i := 1;
     For rcd IN c_rev_comps_disable
     LOOP

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Revised Components For Implemented Ecos having ACD type as Disable for Components...');

      BEGIN
            l_item_exits_in_org_flag := 1;
            SELECT msi.concatenated_segments,eri.new_item_revision
            INTO   l_revised_item_name,l_new_item_revision
            FROM   mtl_system_items_b_kfv msi,
                   eng_revised_items eri
            WHERE  eri.revised_item_sequence_id = rcd.revised_item_sequence_id
            AND    eri.revised_item_id = msi.inventory_item_id
            AND    msi.organization_id = l_org_id;

          EXCEPTION WHEN NO_DATA_FOUND THEN
            l_item_exits_in_org_flag := 0;
            l_check_invalid_objects := 0;
      END;
      IF (l_item_exits_in_org_flag = 1) THEN

             BEGIN
               SELECT concatenated_segments
               INTO   l_component_item_name
               FROM   mtl_system_items_b_kfv
               WHERE  inventory_item_id = rcd.component_item_id
               AND    organization_id = l_org_id;
             EXCEPTION WHEN NO_DATA_FOUND THEN
               l_item_exits_in_org_flag := 0;
               l_check_invalid_objects := 0;
             END;

             IF (l_item_exits_in_org_flag = 1) THEN

                IF (rcd.supply_locator_id is NOT NULL) THEN

                  SELECT CONCATENATED_SEGMENTS
                  INTO   l_location_name
                  FROM   mtl_item_locations_kfv
                  WHERE inventory_location_id = rcd.supply_locator_id;
                ELSE
                  l_location_name := NULL;
                END IF;
        BEGIN
               St_Number := 10;
                   select assembly_item_id
                   into   item_id
                   from   bom_bill_of_materials
                   where  bill_sequence_id = rcd.bill_sequence_id;
                   /* for bug 9368374 */
                   St_Number := 15;
                   select alternate_bom_designator
                   into   l_alternate_bom
                   from   bom_bill_of_materials
                   where  bill_sequence_id = rcd.bill_sequence_id;
                   /* for bug 9368374 */
                   St_Number := 20;
                   select bill_sequence_id
                   into   bill_id
                   from   bom_bill_of_materials
                   where  assembly_item_id =  item_id
                   and    organization_id = l_org_id
                   and    NVL(alternate_bom_designator,'-999')= NVL(l_alternate_bom,'-999');  /* for bug 9368374 */

                   St_Number := 30;
                   select operation_seq_num,trunc(effectivity_date)
                   into   old_operation_seq_num,l_old_effectivity_date
                   from   bom_inventory_components
                   where  COMPONENT_SEQUENCE_ID = rcd.OLD_COMPONENT_SEQUENCE_ID;

                   St_Number := 40;
                   select max(component_sequence_id)
                   into   component_seq_id
                   from   bom_inventory_components
                   where ((trunc(effectivity_date) = l_old_effectivity_date) OR
                          (rcd.effectivity_date between
                            trunc(effectivity_date) and
                            NVL(disable_date, rcd.effectivity_date + 1)))
           -- Bug 3041105 : Commenting code to pick unimplemented components
           -- and    implementation_date IS NOT NULL
                   and    component_item_id = rcd.COMPONENT_ITEM_ID
                   and    bill_sequence_id = bill_id
                   and    operation_seq_num = old_operation_seq_num;

                   St_Number := 50;
                   select effectivity_date
                   into old_effectivity_date
                   from bom_inventory_components
                   where component_sequence_id = component_seq_id;

                 EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                old_operation_seq_num := NULL;
                                old_effectivity_date := NULL;
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found error in Disable After implementation for sql statement Number :' || to_char(St_Number));
                        WHEN OTHERS THEN
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'Sql error in Disable after implementation statement number: '|| to_char(St_Number) || ':' || TO_CHAR(SQLCODE) || ' ' || SUBSTR(SQLERRM, 1, 100));
                 END;
                l_rev_component_tbl(i).eco_name := rcd.change_notice;
                l_rev_component_tbl(i).organization_code:= l_org_code;
                l_rev_component_tbl(i).revised_item_name :=
                    l_revised_item_name;
                l_rev_component_tbl(i).new_revised_item_revision :=
                l_new_item_revision;
                l_rev_component_tbl(i).start_effective_date :=
                rcd.effectivity_date;
        l_rev_component_tbl(i).new_effectivity_date := NULL;
        l_rev_component_tbl(i).COMMENTS := rcd.COMPONENT_REMARKS;
                l_rev_component_tbl(i).disable_date := rcd.disable_date;
                l_rev_component_tbl(i).operation_sequence_number :=
                rcd.operation_sequence_num;
                l_rev_component_tbl(i).component_item_name :=
                l_component_item_name;
                l_rev_component_tbl(i).alternate_bom_code := l_alternate_bom;  /* for bug 9368374 */
                                   -- NULL;
                l_rev_component_tbl(i).acd_type := rcd.acd_type;
                l_rev_component_tbl(i).old_effectivity_date :=
                                              old_effectivity_date;
                l_rev_component_tbl(i).old_operation_sequence_number :=
                                                old_operation_seq_num;
                l_rev_component_tbl(i).new_operation_sequence_number :=
                                                NULL;
                l_rev_component_tbl(i).item_sequence_number := rcd.item_num;
                l_rev_component_tbl(i).quantity_per_assembly :=
                       rcd.component_quantity;
                l_rev_component_tbl(i).planning_percent := rcd.planning_factor;
                l_rev_component_tbl(i).projected_yield :=
                rcd.component_yield_factor;
                l_rev_component_tbl(i).include_in_cost_rollup :=
                                 rcd.include_in_cost_rollup;
                l_rev_component_tbl(i).wip_supply_type :=
                 rcd.wip_supply_type;
                l_rev_component_tbl(i).so_basis :=  rcd.so_basis;
                l_rev_component_tbl(i).basis_type :=  rcd.basis_type;
                l_rev_component_tbl(i).optional := rcd.optional;
                l_rev_component_tbl(i).mutually_exclusive :=
                                      rcd.mutually_exclusive_options;
                l_rev_component_tbl(i).check_atp := rcd.check_atp;
                l_rev_component_tbl(i).shipping_allowed :=
                rcd.shipping_allowed;
                l_rev_component_tbl(i).required_to_ship :=
            rcd.required_to_ship;
                l_rev_component_tbl(i).required_for_revenue :=
                        rcd.required_for_revenue;
                l_rev_component_tbl(i).include_on_ship_docs :=
                    rcd.include_on_ship_docs;
                l_rev_component_tbl(i).quantity_related :=
                rcd.quantity_related;
                l_rev_component_tbl(i).supply_subinventory :=
                                rcd.supply_subinventory;
                l_rev_component_tbl(i).location_name := l_location_name;
                l_rev_component_tbl(i).minimum_allowed_quantity :=
                                rcd.low_quantity;
                l_rev_component_tbl(i).maximum_allowed_quantity :=
                rcd.high_quantity;
                l_rev_component_tbl(i).attribute_category  :=
                                rcd.attribute_category;
                l_rev_component_tbl(i).attribute1  := rcd.attribute1;
                l_rev_component_tbl(i).attribute2  := rcd.attribute2;
                l_rev_component_tbl(i).attribute3  := rcd.attribute3;
                l_rev_component_tbl(i).attribute4  := rcd.attribute4;
                l_rev_component_tbl(i).attribute5  := rcd.attribute5;
                l_rev_component_tbl(i).attribute6  := rcd.attribute6;
                l_rev_component_tbl(i).attribute7  := rcd.attribute7;
                l_rev_component_tbl(i).attribute8  := rcd.attribute8;
                l_rev_component_tbl(i).attribute9  := rcd.attribute9;
                l_rev_component_tbl(i).attribute10  := rcd.attribute10;
                l_rev_component_tbl(i).attribute11  := rcd.attribute11;
                l_rev_component_tbl(i).attribute12  := rcd.attribute12;
                l_rev_component_tbl(i).attribute13  := rcd.attribute13;
                l_rev_component_tbl(i).attribute14  := rcd.attribute14;
                l_rev_component_tbl(i).attribute15  := rcd.attribute15;
                l_rev_component_tbl(i).from_end_item_unit_number :=
                                rcd.from_end_item_unit_number;
                l_rev_component_tbl(i).to_end_item_unit_number  :=
                                rcd.to_end_item_unit_number;
                l_rev_component_tbl(i).original_system_reference :=
                                rcd.original_system_reference;
                l_rev_component_tbl(i).new_from_end_item_unit_number := NULL;
                l_rev_component_tbl(i).old_from_end_item_unit_number := NULL;
                l_rev_component_tbl(i).return_status := NULL;
                l_rev_component_tbl(i).transaction_type := 'CREATE';

                i := i + 1;

               ELSE

                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Component_Item_id = '|| rcd.component_item_id||' for Org '||l_org_code);
        END IF;
             ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid revised_item_seq_id = '||rcd.revised_item_sequence_id||' for Org '||l_org_code);
             END IF;
     END LOOP;

         -- Fetch revised components

         FOR rc IN c_rev_comps
         LOOP                                             /* Loop 5 */

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Revised Components ...');

          BEGIN

	    l_item_exits_in_org_flag := 1;


            SELECT msi.concatenated_segments,eri.new_item_revision
            INTO   l_revised_item_name,l_new_item_revision
            FROM   mtl_system_items_b_kfv msi,
                   eng_revised_items eri
            WHERE  eri.revised_item_sequence_id = rc.revised_item_sequence_id
            AND    eri.revised_item_id = msi.inventory_item_id
            AND    msi.organization_id = l_org_id;


	  EXCEPTION WHEN NO_DATA_FOUND THEN
            l_item_exits_in_org_flag := 0;
            l_check_invalid_objects := 0;
          END;

          IF (l_item_exits_in_org_flag = 1) THEN

             BEGIN

	      /*  SELECT concatenated_segments   -- Commented for bug-5725081
                  INTO   l_component_item_name
                  FROM   mtl_system_items_b_kfv
                  WHERE  inventory_item_id = rc.component_item_id
                  AND    organization_id = l_org_id;
	      */

	      -- Code added for bug number 5725081 starts here

	       v_component_quantity_to := 0 ;
	       v_component_low_quantity := 0 ;
	       v_component_high_quantity := 0 ;

	       SELECT msit.concatenated_segments,
  	              DECODE(msif.primary_unit_of_measure,
                             msit.primary_unit_of_measure,
	   	             rc.component_quantity,
  		             inv_convert.INV_UM_CONVERT(rc.component_item_id,
 		                                        NULL,
		                                        rc.component_quantity,
		                                        NULL,
                                                        NULL,
 		                                        msif.primary_unit_of_measure,
		                                        msit.primary_unit_of_measure
							)
 		             ),
  	              DECODE(msif.primary_unit_of_measure,
                             msit.primary_unit_of_measure,
	   	             rc.low_quantity,
  		             DECODE(rc.low_quantity, NULL, NULL,
                                        inv_convert.INV_UM_CONVERT(
	    					       rc.component_item_id,
 	   	                                        NULL,
		                                        rc.low_quantity,
		                                        NULL,
                                                        NULL,
 		                                        msif.primary_unit_of_measure,
		                                        msit.primary_unit_of_measure
							           )
                                    )
			      ),
  	              DECODE(msif.primary_unit_of_measure,
                             msit.primary_unit_of_measure,
	   	             rc.high_quantity,
  		             DECODE(rc.high_quantity, NULL, NULL,
			                  inv_convert.INV_UM_CONVERT(
					                rc.component_item_id,
 		                                        NULL,
		                                        rc.high_quantity,
		                                        NULL,
                                                        NULL,
 		                                        msif.primary_unit_of_measure,
		                                        msit.primary_unit_of_measure
							             )
                                    )
  			     )
               INTO l_component_item_name,
                    v_component_quantity_to,
                    v_component_low_quantity,
	            v_component_high_quantity
               FROM mtl_system_items_b_kfv MSIF ,
                    mtl_system_items_b_kfv MSIT
              WHERE msif.inventory_item_id = msit.inventory_item_id
                AND msif.inventory_item_id = rc.component_item_id
                AND msit.organization_id = l_org_id
                AND msif.organization_id = l_org_hierarchy_level_id ;

	          -- Code added for bug 5725081 ends here
	     EXCEPTION WHEN NO_DATA_FOUND THEN
               l_item_exits_in_org_flag := 0;
               l_check_invalid_objects := 0;
             END;

             IF (l_item_exits_in_org_flag = 1) THEN

                IF (rc.supply_locator_id is NOT NULL) THEN

                  SELECT CONCATENATED_SEGMENTS
                  INTO   l_location_name
                  FROM   mtl_item_locations_kfv
                  WHERE inventory_location_id = rc.supply_locator_id;
                ELSE
                  l_location_name := NULL;
                END IF;
                /* for bug 9368374 */
                BEGIN
                   select alternate_bom_designator
                   into   l_alternate_bom
                   from   bom_bill_of_materials
                   where  bill_sequence_id = rc.bill_sequence_id;

                EXCEPTION WHEN NO_DATA_FOUND THEN
                    l_check_invalid_objects := 0;
                END;
                /* for bug 9368374 */
        IF (rc.acd_type in (2,3)) then
         BEGIN
           St_Number := 10;
                   select assembly_item_id
                   into   item_id
                   from   bom_bill_of_materials
                   where  bill_sequence_id = rc.bill_sequence_id;

           St_Number := 20;
                   select bill_sequence_id
                   into   bill_id
                   from   bom_bill_of_materials
                   where  assembly_item_id =  item_id
                   and    organization_id = l_org_id
                   and    NVL(alternate_bom_designator,'-999') = NVL(l_alternate_bom,'-999');  /* for bug 9368374 */

           St_Number := 30;
                   select operation_seq_num,trunc(effectivity_date)
                   into   old_operation_seq_num,l_old_effectivity_date
                   from   bom_inventory_components
                   where  COMPONENT_SEQUENCE_ID = rc.OLD_COMPONENT_SEQUENCE_ID;

           St_Number := 40;
                   select max(component_sequence_id)
                   into   component_seq_id
                   from   bom_inventory_components
           where ((trunc(effectivity_date) = l_old_effectivity_date) OR
                          (rc.effectivity_date between
                    trunc(effectivity_date) and
                            NVL(disable_date, rc.effectivity_date + 1))
                         )
                   -- Bug 3041105 : Commenting code to pick unimplemented components
                   -- and    implementation_date IS NOT NULL
                   and    component_item_id = rc.COMPONENT_ITEM_ID
                   and    bill_sequence_id = bill_id
                   and    operation_seq_num = old_operation_seq_num;


           St_Number := 50;
                   select effectivity_date
                   into old_effectivity_date
                   from bom_inventory_components
                   where component_sequence_id = component_seq_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                old_operation_seq_num := NULL;
                old_effectivity_date := NULL;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found error for sql statement Number :' || to_char(St_Number));
            WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Sql error in statement number: '|| to_char(St_Number) || ':' || TO_CHAR(SQLCODE) || ' ' || SUBSTR(SQLERRM, 1, 100));
         END;
            ELSE
                        old_operation_seq_num := NULL;
                        old_effectivity_date := NULL;
            END IF;

                l_rev_component_tbl(i).eco_name := rc.change_notice;
                l_rev_component_tbl(i).organization_code:= l_org_code;
                l_rev_component_tbl(i).revised_item_name :=
                    l_revised_item_name;
                l_rev_component_tbl(i).new_revised_item_revision :=
                l_new_item_revision;
                l_rev_component_tbl(i).start_effective_date :=
                rc.effectivity_date;
                l_rev_component_tbl(i).new_effectivity_date := NULL;
                l_rev_component_tbl(i).COMMENTS := rc.COMPONENT_REMARKS;
                l_rev_component_tbl(i).disable_date := rc.disable_date;
                l_rev_component_tbl(i).operation_sequence_number :=
                rc.operation_seq_num;
                l_rev_component_tbl(i).component_item_name :=
                l_component_item_name;
                l_rev_component_tbl(i).alternate_bom_code := l_alternate_bom;  /* for bug 9368374 */
                                    -- NULL;
                l_rev_component_tbl(i).acd_type := rc.acd_type;
                l_rev_component_tbl(i).old_effectivity_date :=
                                              old_effectivity_date;
                l_rev_component_tbl(i).old_operation_sequence_number :=
                                                old_operation_seq_num;
                l_rev_component_tbl(i).new_operation_sequence_number :=
                                                NULL;
                l_rev_component_tbl(i).item_sequence_number := rc.item_num;
/*                l_rev_component_tbl(i).quantity_per_assembly :=    -- Commented for bug 5725081
                       rc.component_quantity;*/
		l_rev_component_tbl(i).quantity_per_assembly :=      -- Added for bug 5725081
		                v_component_quantity_to;

                l_rev_component_tbl(i).planning_percent := rc.planning_factor;
                l_rev_component_tbl(i).projected_yield :=
                rc.component_yield_factor;
                l_rev_component_tbl(i).include_in_cost_rollup :=
                                 rc.include_in_cost_rollup;
                l_rev_component_tbl(i).wip_supply_type :=
                 rc.wip_supply_type;
                l_rev_component_tbl(i).so_basis :=  rc.so_basis;
                 l_rev_component_tbl(i).basis_type :=  rc.basis_type;
                l_rev_component_tbl(i).optional := rc.optional;
                l_rev_component_tbl(i).mutually_exclusive :=
                                      rc.mutually_exclusive_options;
                l_rev_component_tbl(i).check_atp := rc.check_atp;
                l_rev_component_tbl(i).shipping_allowed :=
                rc.shipping_allowed;
                l_rev_component_tbl(i).required_to_ship :=
            rc.required_to_ship;
                l_rev_component_tbl(i).required_for_revenue :=
                        rc.required_for_revenue;
                l_rev_component_tbl(i).include_on_ship_docs :=
                    rc.include_on_ship_docs;
                l_rev_component_tbl(i).quantity_related :=
                rc.quantity_related;
                l_rev_component_tbl(i).supply_subinventory :=
                rc.supply_subinventory;
                l_rev_component_tbl(i).location_name := l_location_name;
             /*   l_rev_component_tbl(i).minimum_allowed_quantity :=   -- Commented for bug 5725081
                rc.low_quantity;
                l_rev_component_tbl(i).maximum_allowed_quantity :=
                rc.high_quantity;*/
   	        l_rev_component_tbl(i).minimum_allowed_quantity :=   -- Added for bug-5725081
				            v_component_low_quantity;

		l_rev_component_tbl(i).maximum_allowed_quantity :=   -- Added for bug-5725081
   				            v_component_high_quantity;

                l_rev_component_tbl(i).attribute_category  :=
                                            rc.attribute_category;
                l_rev_component_tbl(i).attribute1  := rc.attribute1;
                l_rev_component_tbl(i).attribute2  := rc.attribute2;
                l_rev_component_tbl(i).attribute3  := rc.attribute3;
                l_rev_component_tbl(i).attribute4  := rc.attribute4;
                l_rev_component_tbl(i).attribute5  := rc.attribute5;
                l_rev_component_tbl(i).attribute6  := rc.attribute6;
                l_rev_component_tbl(i).attribute7  := rc.attribute7;
                l_rev_component_tbl(i).attribute8  := rc.attribute8;
                l_rev_component_tbl(i).attribute9  := rc.attribute9;
                l_rev_component_tbl(i).attribute10  := rc.attribute10;
                l_rev_component_tbl(i).attribute11  := rc.attribute11;
                l_rev_component_tbl(i).attribute12  := rc.attribute12;
                l_rev_component_tbl(i).attribute13  := rc.attribute13;
                l_rev_component_tbl(i).attribute14  := rc.attribute14;
                l_rev_component_tbl(i).attribute15  := rc.attribute15;
        l_rev_component_tbl(i).from_end_item_unit_number :=
                rc.from_end_item_unit_number;
        l_rev_component_tbl(i).to_end_item_unit_number  :=
                rc.to_end_item_unit_number;
        l_rev_component_tbl(i).original_system_reference :=
                rc.original_system_reference;
        l_rev_component_tbl(i).new_from_end_item_unit_number := NULL;
        l_rev_component_tbl(i).old_from_end_item_unit_number := NULL;
                l_rev_component_tbl(i).return_status := NULL;
                l_rev_component_tbl(i).transaction_type := 'CREATE';

                i := i + 1;

               ELSE

                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Component_Item_id = '|| rc.component_item_id||' for Org '||l_org_code);

               END IF;

             ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid revised_item_seq_id = '||
                                rc.revised_item_sequence_id||' for Org '||l_org_code);
             END IF;

         END LOOP;                                      /* End Loop 5 */

         -- Fetch substitute component records

         i := 1;

         FOR sc IN c_sub_comps
         LOOP                                          /* Loop 6 */

         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Substitute Components ...');

            BEGIN

           l_item_exits_in_org_flag := 1;

               SELECT msi.concatenated_segments,eri.new_item_revision
               INTO   l_revised_item_name1,l_new_item_revision
               FROM   mtl_system_items_b_kfv msi,
                      eng_revised_items eri,
                      bom_inventory_components bic
               WHERE  bic.component_sequence_id = sc.component_sequence_id
               AND  eri.revised_item_sequence_id = bic.revised_item_sequence_id
               AND    eri.revised_item_id = msi.inventory_item_id
               AND    msi.organization_id = l_org_id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
               l_item_exits_in_org_flag := 0;
               l_check_invalid_objects := 0;
            END;

            IF (l_item_exits_in_org_flag = 1) THEN

               BEGIN
                  SELECT concatenated_segments,bic.effectivity_date,
                         bic.operation_seq_num
                  INTO   l_component_item_name1,l_effectivity_date,
                         l_operation_seq_num
                  FROM   mtl_system_items_b_kfv msi,
                         bom_inventory_components bic
                  WHERE  bic.component_sequence_id = sc.component_sequence_id
                  AND    msi.inventory_item_id = bic.component_item_id
                  AND    msi.organization_id = l_org_id;
               EXCEPTION WHEN NO_DATA_FOUND THEN
                  l_item_exits_in_org_flag := 0;
                  l_check_invalid_objects := 0;
               END;

               IF (l_item_exits_in_org_flag = 1) THEN

                  BEGIN

  		    v_substitute_item_quantity := 0;   -- Added for bug-5725081

		   /*  SELECT concatenated_segments   -- Commented for bug-5725081
                     INTO   l_substitute_component_name
                     FROM   mtl_system_items_b_kfv
                     WHERE  inventory_item_id = sc.substitute_component_id
                     AND    organization_id = l_org_id;
             	     */

		     SELECT msit.concatenated_segments,  -- Added for bug-5725081
                         DECODE(msif.primary_unit_of_measure,
                                msit.primary_unit_of_measure,
                                sc.substitute_item_quantity ,
  		                inv_convert.INV_UM_CONVERT(sc.substitute_component_id,
 		                                           NULL,
		                                           sc.substitute_item_quantity,
		                                           NULL,
                                                           NULL,
   		                                           msif.primary_unit_of_measure,
		                                           msit.primary_unit_of_measure)
 		  				           )
  	              INTO  l_substitute_component_name,
       	                    v_substitute_item_quantity
                      FROM  mtl_system_items_b_kfv MSIF,
                            mtl_system_items_b_kfv MSIT
                     WHERE  msif.inventory_item_id = msit.inventory_item_id
                       AND  msif.inventory_item_id = sc.substitute_component_id
                       AND  msit.organization_id   = l_org_id
                       AND  msif.organization_id   = l_org_hierarchy_level_id;


                  EXCEPTION WHEN NO_DATA_FOUND THEN
                     l_item_exits_in_org_flag := 0;
                     l_check_invalid_objects := 0;
                  END;
                  /* for bug 9368374 */
                  BEGIN
                  SELECT bom.alternate_bom_designator
                  INTO   l_alternate_bom
                  FROM   bom_inventory_components bic,
                         bom_structures_b bom
                  WHERE  bic.component_sequence_id = sc.component_sequence_id
                  AND    bic.bill_sequence_id      = bom.bill_sequence_id;

                  EXCEPTION WHEN NO_DATA_FOUND THEN
                     l_check_invalid_objects := 0;
                  END;
                  /* for bug 9368374 */
                  IF (l_item_exits_in_org_flag = 1) THEN

                     l_sub_component_tbl(i).eco_name := sc.change_notice;
                     l_sub_component_tbl(i).organization_code:= l_org_code;
                     l_sub_component_tbl(i).revised_item_name :=
                        l_revised_item_name1;
                     l_sub_component_tbl(i).start_effective_date :=
                        l_effectivity_date;
                     l_sub_component_tbl(i).new_revised_item_revision :=
                        l_new_item_revision;
                     l_sub_component_tbl(i).component_item_name :=
                        l_component_item_name1;
                     l_sub_component_tbl(i).alternate_bom_code := l_alternate_bom;  /* for bug 9368374 */
                                                        -- NULL;
                     l_sub_component_tbl(i).substitute_component_name :=
                                                l_substitute_component_name;
                     l_sub_component_tbl(i).acd_type := sc.acd_type;
                     l_sub_component_tbl(i).operation_sequence_number :=
                                                        l_operation_seq_num;
                 /*    l_sub_component_tbl(i).substitute_item_quantity :=
                                             sc.substitute_item_quantity;*/
	            l_sub_component_tbl(i).substitute_item_quantity :=      -- Added for bug#5725081
                                             v_substitute_item_quantity;
                     l_sub_component_tbl(i).attribute_category  :=
                         sc.attribute_category;
                     l_sub_component_tbl(i).attribute1  := sc.attribute1;
                     l_sub_component_tbl(i).attribute2  := sc.attribute2;
                     l_sub_component_tbl(i).attribute3  := sc.attribute3;
                     l_sub_component_tbl(i).attribute4  := sc.attribute4;
                     l_sub_component_tbl(i).attribute5  := sc.attribute5;
                     l_sub_component_tbl(i).attribute6  := sc.attribute6;
                     l_sub_component_tbl(i).attribute7  := sc.attribute7;
                     l_sub_component_tbl(i).attribute8  := sc.attribute8;
                     l_sub_component_tbl(i).attribute9  := sc.attribute9;
                     l_sub_component_tbl(i).attribute10  := sc.attribute10;
                     l_sub_component_tbl(i).attribute11  := sc.attribute11;
                     l_sub_component_tbl(i).attribute12  := sc.attribute12;
                     l_sub_component_tbl(i).attribute13  := sc.attribute13;
                     l_sub_component_tbl(i).attribute14  := sc.attribute14;
                     l_sub_component_tbl(i).attribute15  := sc.attribute15;
                     l_sub_component_tbl(i).from_end_item_unit_number  := NULL;
             l_sub_component_tbl(i).Original_System_Reference :=
                    sc.Original_System_Reference;
                     l_sub_component_tbl(i).return_status := NULL;
                     l_sub_component_tbl(i).transaction_type := 'CREATE';

                     i := i + 1;

                  ELSE

                     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Substitute_Component_Id = '|| sc.substitute_component_id||' for Org '||l_org_code);

                  END IF;

               ELSE

                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Component_seq_id = '|| sc.component_sequence_id||' for Org '||l_org_code);

               END IF;

            ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid revised_item_id for Component_Seq_Id = '|| sc.component_sequence_id||' for Org '||l_org_code);

            END IF;

         END LOOP;                                      /* End Loop 6 */

         -- Fetch reference designators

         i := 1;

         FOR rd IN c_ref_desgs
         LOOP                                          /* Loop 7 */

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Reference Designators ...');
            BEGIN

               l_item_exits_in_org_flag := 1;

               SELECT msi.concatenated_segments,eri.new_item_revision,
              bic.effectivity_date,bic.operation_seq_num
               INTO   l_revised_item_name2,l_new_item_revision,
              l_effectivity_date,l_operation_seq_num
               FROM   mtl_system_items_b_kfv msi,
                      eng_revised_items eri,
                      bom_inventory_components bic
               WHERE  bic.component_sequence_id = rd.component_sequence_id
               AND  eri.revised_item_sequence_id = bic.revised_item_sequence_id
               AND    eri.revised_item_id = msi.inventory_item_id
               AND    msi.organization_id = l_org_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_item_exits_in_org_flag := 0;
                  l_check_invalid_objects := 0;
            END;

            IF (l_item_exits_in_org_flag = 1) THEN

               BEGIN
                  SELECT concatenated_segments
                  INTO   l_component_item_name2
                  FROM   mtl_system_items_b_kfv msi,
                         bom_inventory_components bic
                  WHERE  bic.component_sequence_id = rd.component_sequence_id
                  AND    msi.inventory_item_id = bic.component_item_id
                  AND    msi.organization_id = l_org_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     l_item_exits_in_org_flag := 0;
                     l_check_invalid_objects := 0;
               END;
               /* for bug 9368374 */
               BEGIN
                  SELECT bom.alternate_bom_designator
                  INTO   l_alternate_bom
                  FROM   bom_inventory_components bic,
                         bom_structures_b bom
                  WHERE  bic.component_sequence_id = rd.component_sequence_id
                  AND    bic.bill_sequence_id      = bom.bill_sequence_id;

                  EXCEPTION WHEN NO_DATA_FOUND THEN
                     l_check_invalid_objects := 0;
               END;
               /* for bug 9368374 */
               IF (l_item_exits_in_org_flag = 1) THEN

                  l_ref_designator_tbl(i).eco_name := rd.change_notice;
                  l_ref_designator_tbl(i).organization_code := l_org_code;
                  l_ref_designator_tbl(i).revised_item_name :=
                    l_revised_item_name2;
                  l_ref_designator_tbl(i).start_effective_date :=
                    l_effectivity_date;
                  l_ref_designator_tbl(i).new_revised_item_revision :=
                    l_new_item_revision;
                  l_ref_designator_tbl(i).operation_sequence_number :=
                                    l_operation_seq_num;
                  l_ref_designator_tbl(i).component_item_name :=
                    l_component_item_name2;
                  l_ref_designator_tbl(i).alternate_bom_code := l_alternate_bom;  /* for bug 9368374 */
                                       -- NULL;
                  l_ref_designator_tbl(i).reference_designator_name :=
                                        rd.component_reference_designator;
                  l_ref_designator_tbl(i).acd_type := rd.acd_type;
                  l_ref_designator_tbl(i).ref_designator_comment :=
                                        rd.ref_designator_comment;
                  l_ref_designator_tbl(i).attribute_category  :=
                    rd.attribute_category;
                  l_ref_designator_tbl(i).attribute1  := rd.attribute1;
                  l_ref_designator_tbl(i).attribute2  := rd.attribute2;
                  l_ref_designator_tbl(i).attribute3  := rd.attribute3;
                  l_ref_designator_tbl(i).attribute4  := rd.attribute4;
                  l_ref_designator_tbl(i).attribute5  := rd.attribute5;
                  l_ref_designator_tbl(i).attribute6  := rd.attribute6;
                  l_ref_designator_tbl(i).attribute7  := rd.attribute7;
                  l_ref_designator_tbl(i).attribute8  := rd.attribute8;
                  l_ref_designator_tbl(i).attribute9  := rd.attribute9;
                  l_ref_designator_tbl(i).attribute10  := rd.attribute10;
                  l_ref_designator_tbl(i).attribute11  := rd.attribute11;
                  l_ref_designator_tbl(i).attribute12  := rd.attribute12;
                  l_ref_designator_tbl(i).attribute13  := rd.attribute13;
                  l_ref_designator_tbl(i).attribute14  := rd.attribute14;
                  l_ref_designator_tbl(i).attribute15  := rd.attribute15;
              l_ref_designator_tbl(i).Original_System_Reference :=
                rd.Original_System_Reference;
                  l_ref_designator_tbl(i).new_reference_designator := NULL;
                  l_ref_designator_tbl(i).from_end_item_unit_number := NULL;
                  l_ref_designator_tbl(i).return_status := NULL;
                  l_ref_designator_tbl(i).transaction_type := 'CREATE';

                  i:= i + 1;

               ELSE

                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Component_seq_id = '||rd.component_sequence_id||' for Org '||l_org_code);

               END IF;

            ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invalid revised_item_id for Component_Seq_Id = '|| rd.component_sequence_id||' for Org '||l_org_code);

            END IF;
         END LOOP;                                        /* End Loop 7 */

       IF l_check_invalid_objects = 1 THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'');

         Eng_Globals.G_WHO_REC.org_id := l_org_id;
         Eng_Globals.G_WHO_REC.user_id := FND_PROFILE.value('USER_ID');
         Eng_Globals.G_WHO_REC.login_id :=  FND_PROFILE.value('LOGIN_ID');
         Eng_Globals.G_WHO_REC.prog_appid := FND_PROFILE.value('RESP_APPL_ID');
         Eng_Globals.G_WHO_REC.prog_id := NULL;
         Eng_Globals.G_WHO_REC.req_id := NULL;

         fnd_global.apps_initialize
         (user_id => Eng_Globals.G_WHO_REC.user_id,
          resp_id => FND_PROFILE.value('RESP_ID'),
          resp_appl_id =>  Eng_Globals.G_WHO_REC.prog_appid
         );

      /* Initializing the Error Handler */

      Error_Handler.Initialize;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling ECO Business Objects');
          ENG_GLOBALS.G_ENG_LAUNCH_IMPORT := 2 ;--Indicates call is from propagation

		  /* Bug 29557563 changes - Removed hard code path reference for parameter p_output_dir since
		     we are passing 'N' for p_debug. Also modified p_debug_filename to pass NULL. */

          Eng_Eco_Pub.Process_Eco
         (
           p_api_version_number => 1.0
          ,p_init_msg_list => FALSE
          ,x_return_status => l_return_status
          ,x_msg_count => l_msg_count
          ,p_bo_identifier => 'ECO'
          ,p_ECO_rec => l_eco_rec
          ,p_eco_revision_tbl => l_eco_revision_tbl
          ,p_change_line_tbl => l_change_lines_tbl
          ,p_revised_item_tbl => l_revised_item_tbl
          ,p_rev_component_tbl => l_rev_component_tbl
          ,p_sub_component_tbl => l_sub_component_tbl
          ,p_ref_designator_tbl => l_ref_designator_tbl
          ,p_rev_operation_tbl => l_rev_operation_tbl
          ,p_rev_op_resource_tbl => l_rev_op_resource_tbl
          ,p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
          ,x_ECO_rec => l_eco_rec
          ,x_eco_revision_tbl => l_eco_revision_tbl
          ,x_change_line_tbl => l_change_lines_tbl
          ,x_revised_item_tbl => l_revised_item_tbl
          ,x_rev_component_tbl => l_rev_component_tbl
          ,x_sub_component_tbl => l_sub_component_tbl
          ,x_ref_designator_tbl => l_ref_designator_tbl
          ,x_rev_operation_tbl => l_rev_operation_tbl
          ,x_rev_op_resource_tbl => l_rev_op_resource_tbl
          ,x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
          ,p_debug => 'N'
          ,p_output_dir => ''
          ,p_debug_filename => ''
         );
         ENG_GLOBALS.G_ENG_LAUNCH_IMPORT :=0; --resetting values
         FND_FILE.PUT_LINE(FND_FILE.LOG,'ECO Business Object Processing Done');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'');
         --
         -- On return from the PUB API
         -- Perform all the error handler operations to verify that the
         -- error or warning are displayed and all the error table interface
         -- function provided to the user work corrently;
         --

         /*if (l_return_status = 'S') THEN
           propagate_eco_lines
           (
             p_ECO_rec => l_eco_rec,
             p_source_org_id => l_org_hierarchy_level_id,
             p_dest_org_id => l_org_id,
             x_return_status => l_return_status
           );
         end if;*/

         if (l_return_status = 'S') THEN
          /*bug #7496156 to Copy attached Document*/
	   BEGIN
                SELECT change_id INTO l_new_change_id
                  FROM  eng_engineering_changes
                 WHERE  change_notice = p_change_notice
                   AND    organization_id = l_org_id;
                FND_File.put_line(FND_FILE.log, 'Copy ECO attachment Start for  Org '||l_org_id );
                FND_File.put_line(FND_FILE.log, 'Copy ECO attachment Start for  Org Code '||l_org_Code );
                FND_File.put_line(FND_FILE.log, 'Copy ECO attachment Start for  Change_id '||l_new_change_id );
                fnd_attached_documents2_pkg.copy_attachments(
                                X_from_entity_name      =>  'ENG_ENGINEERING_CHANGES',
                                X_from_pk1_value        =>  ECO_rec.change_id,
                                X_from_pk2_value        =>  '',
                                X_from_pk3_value        =>  '',
                                X_from_pk4_value        =>  '',
                                X_from_pk5_value        =>  '',
                                X_to_entity_name        =>  'ENG_ENGINEERING_CHANGES',
                                X_to_pk1_value          =>  l_new_change_id,
                                X_to_pk2_value          =>  '',
                                X_to_pk3_value          =>  '',
                                X_to_pk4_value          =>  '',
                                X_to_pk5_value          =>  '',
                                X_created_by            =>  FND_GLOBAL.USER_ID,
                                X_last_update_login     =>  '',
                                X_program_application_id=>  '',
                                X_program_id            =>  '',
                                X_request_id            =>  ''
                            );
                FND_File.put_line(FND_FILE.log, 'Copy ECO attachment done for Org Code '|| l_org_Code||' and Change Id '||l_new_change_id );
          EXCEPTION WHEN OTHERS THEN
                FND_File.put_line(FND_FILE.log, 'Could not Copy ECO attachment for  Org Code '|| l_org_Code||' and Change Id '||l_new_change_id );
          END;
       /*End bug #7496156 to Copy attached Document*/
	   COMMIT;
         else
           ROLLBACK;
         Error_Handler.Get_Message_List( x_message_list  => l_error_table);
     i:=0;
         FOR i IN 1..l_error_table.COUNT
         LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Entity Id: '||l_error_table(i).entity_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Index: '||l_error_table(i).entity_index);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Mesg: '||l_error_table(i).message_text);
         END LOOP;

        end if;

       ELSE

          FND_FILE.PUT_LINE(FND_FILE.LOG,'This ECO '||p_change_notice|| ' cannot be processed as there are invalid Items as listed above . Please correct these Items and re-run the propagate ECO');

        l_check_invalid_objects := 1;

       END IF;

      END LOOP;                                           /* End Loop 2 */

    END IF;                                               /* ECO Chack */
   END IF;     /*End of  IF l_org_code IS NOT NULL Organization Check */ -- Bug 4546616
  END LOOP;                                              /* End Loop 1 */

END PROPAGATE_ECO_ERP;

PROCEDURE Initialize_Business_Object (
    p_debug IN VARCHAR2
  , p_debug_filename IN VARCHAR2
  , p_output_dir IN VARCHAR2
  , p_bo_identifier IN VARCHAR2
  , p_organization_id IN NUMBER
  , x_return_status IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
l_return_status         VARCHAR2(1);

BEGIN
    IF p_debug = 'Y'
    THEN
        BOM_Globals.Set_Debug(p_debug);
        BOM_Rtg_Globals.Set_Debug(p_debug) ; -- Added by MK on 11/08/00

        Error_Handler.Open_Debug_Session
        (  p_debug_filename     => p_debug_filename
         , p_output_dir         => p_output_dir
         , x_return_status      => l_return_status
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
         );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                BOM_Globals.Set_Debug('N');
                BOM_Rtg_Globals.Set_Debug('N'); -- Added by MK on 11/08/00
        END IF;
    END IF;
    --
    -- Set Business Object Idenfier in the System Information record.
    --
    Eng_Globals.Set_Bo_Identifier(p_bo_identifier  => p_bo_identifier);
    Eng_Globals.Set_Org_Id( p_org_id    => p_organization_id);
    -- Load environment information into the SYSTEM_INFORMATION record
    -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    ENG_GLOBALS.Init_System_Info_Rec(
        x_mesg_token_tbl => l_mesg_token_tbl
      , x_return_status  => l_return_status
     );

    -- Initialize System_Information Unit_Effectivity flag
    IF PJM_UNIT_EFF.Enabled = 'Y'
    THEN
        BOM_Globals.Set_Unit_Effectivity (TRUE);
        ENG_Globals.Set_Unit_Effectivity (TRUE);
    ELSE
        BOM_Globals.Set_Unit_Effectivity (FALSE);
        ENG_Globals.Set_Unit_Effectivity (FALSE);
    END IF;
    x_return_status := l_return_status;
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE EXC_ERR_PVT_API_MAIN;
    END IF;
END Initialize_Business_Object;

PROCEDURE Reset_Business_Object IS
BEGIN
    -- Reset system_information business object flags
    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);
    Eng_Globals.Set_Org_Id( p_org_id        => NULL);
    Eng_Globals.Set_Eco_Name( p_eco_name    => NULL);
END Reset_Business_Object;

PROCEDURE Propagate_Revised_Component (
    p_component_sequence_id     IN NUMBER
  , p_revised_item_sequence_id  IN NUMBER
  , p_change_id                 IN NUMBER
  , p_revised_item_rec          IN Eng_Eco_Pub.Revised_Item_Rec_Type
  , p_revised_item_unexp_rec    IN Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
  , p_local_organization_id     IN NUMBER
  , x_Return_Status             OUT NOCOPY VARCHAR2
) IS

    l_rev_component_count       NUMBER := 1;
    l_sub_component_count       NUMBER := 1;
    l_ref_designator_count      NUMBER := 1;

    l_component_item_name       mtl_system_items_vl.concatenated_segments%type;
    l_location_name             mtl_item_locations_kfv.concatenated_segments%type;
    l_substitute_component_name mtl_system_items_vl.concatenated_segments%type;
    l_revised_item_name         mtl_system_items_vl.concatenated_segments%type;
    l_new_item_revision         VARCHAR2(3);
    l_effectivity_date          DATE;
    st_number                   NUMBER;
    item_id                     NUMBER;
    bill_id                     NUMBER;
    old_operation_seq_num       NUMBER;
    old_effectivity_date        DATE;
    l_old_effectivity_date      DATE;
    component_seq_id            NUMBER;
    l_item_exits_in_org_flag    NUMBER;
    l_has_invalid_objects       NUMBER := G_VAL_FALSE;
    l_entity_action_status      NUMBER;
    l_comp_exists_in_org        NUMBER;

    L_MSG_COUNT                 NUMBER;
    l_Mesg_token_Tbl            Error_Handler.Mesg_Token_Tbl_Type;
    l_bo_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status             VARCHAR2(1);
    l_Token_Tbl                 Error_Handler.Token_Tbl_Type;
    l_item_error_table          INV_ITEM_GRP.Error_Tbl_Type;
    l_message_log_text          VARCHAR2(4000);
    l_temp_mesg                 VARCHAR2(4000);

    l_rev_component_tbl         Bom_Bo_Pub.Rev_Component_Tbl_Type;
    l_sub_component_tbl         Bom_Bo_Pub.Sub_Component_Tbl_Type;
    l_ref_designator_tbl        Bom_Bo_Pub.Ref_Designator_Tbl_Type;
    l_rev_comp_unexp_rec        BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;

    CURSOR c_component_details IS
    SELECT component_item_id, supply_locator_id, bill_sequence_id, old_component_sequence_id
         , effectivity_date , attribute_category, ACD_TYPE, change_notice, disable_date
         , component_remarks, operation_seq_num, attribute1, attribute2, attribute3
         , attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10
         , attribute11, attribute12, attribute13, attribute14, attribute15, item_num
         , component_quantity, planning_factor, component_yield_factor, include_in_cost_rollup
         , wip_supply_type, so_basis, basis_type, optional, mutually_exclusive_options
         , check_atp, shipping_allowed, required_to_ship, required_for_revenue, include_on_ship_docs
         , quantity_related, supply_subinventory, low_quantity, high_quantity, from_end_item_unit_number
         , TO_END_ITEM_UNIT_NUMBER, ORIGINAL_SYSTEM_REFERENCE
      FROM bom_components_b
    WHERE component_sequence_id = p_component_sequence_id
    UNION ALL
    SELECT  component_item_id, supply_locator_id, bill_sequence_id, old_component_sequence_id
         , effectivity_date , attribute_category, ACD_TYPE, change_notice, disable_date
         , component_remarks, OPERATION_SEQUENCE_NUM, attribute1, attribute2, attribute3
         , attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10
         , attribute11, attribute12, attribute13, attribute14, attribute15, item_num
         , component_quantity, planning_factor, component_yield_factor, include_in_cost_rollup
         , wip_supply_type, so_basis, basis_type, optional, mutually_exclusive_options
         , check_atp, shipping_allowed, required_to_ship, required_for_revenue, include_on_ship_docs
         , quantity_related, supply_subinventory, low_quantity, high_quantity, from_end_item_unit_number
         , TO_END_ITEM_UNIT_NUMBER, ORIGINAL_SYSTEM_REFERENCE FROM eng_revised_components
     WHERE component_sequence_id = p_component_sequence_id
       AND acd_type = 3;

    -- Cursor to Pick all substitute Component Items for the Top Organization  for
    -- the given Change Notice
    CURSOR c_plm_sub_comps IS
    SELECT *
    FROM   bom_substitute_components
    WHERE  change_notice = p_revised_item_rec.eco_name
    AND    component_sequence_id = p_component_sequence_id;

    -- Cursor to Pick all reference designators for the Top Organization  for the
    -- given Change Notice

    CURSOR c_plm_ref_desgs IS
    SELECT *
    FROM   bom_reference_designators
    WHERE  change_notice = p_revised_item_rec.eco_name
    AND    component_sequence_id = p_component_sequence_id;

    CURSOR c_get_item_details(cp_inventory_item_id NUMBER, cp_organization_id NUMBER) IS
    SELECT concatenated_segments
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = cp_inventory_item_id
       AND organization_id = cp_organization_id;
BEGIN
  -- Initialize this API for error handling
  Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Revised_Component.BEGIN');
  Error_Handler.Initialize;

  l_entity_action_status := Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Strat processing for each component
  FOR rc in c_component_details
  LOOP

      l_revised_item_name := p_revised_item_rec.revised_item_name;
      l_new_item_revision := p_revised_item_rec.New_Revised_Item_Revision;

      -- Check if the component exists in the local organization
      l_comp_exists_in_org := G_VAL_TRUE;
      OPEN c_get_item_details(rc.component_item_id, p_local_organization_id);
      FETCH c_get_item_details INTO l_component_item_name;
      IF c_get_item_details%NOTFOUND
      THEN
          l_comp_exists_in_org := G_VAL_FALSE;
      END IF;
      CLOSE c_get_item_details;


      -- If component ACD type is ADD
      -- then it has to be auto enabled in the child organization
      -- Proceed to auto enable component
      IF rc.acd_type = 1 AND l_comp_exists_in_org = G_VAL_FALSE
      THEN
          Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Component Item Is being auto enabled. rc.component_item_id:'|| rc.component_item_id);
          Auto_enable_item_in_org(
              p_inventory_item_id => rc.component_item_id
            , p_organization_id  => p_local_organization_id
            , x_error_table      => l_item_error_table
            , x_return_status    => l_return_status);
          Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'After Component Item Is auto enabled. l_return_status'||l_return_status);
          IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
          THEN
              OPEN c_get_item_details(rc.component_item_id, p_local_organization_id);
              FETCH c_get_item_details INTO l_component_item_name;
              IF c_get_item_details%NOTFOUND
              THEN
                  l_comp_exists_in_org := G_VAL_FALSE;
              ELSE
                  l_comp_exists_in_org := G_VAL_TRUE;
                  Fnd_message.set_name('ENG', 'ENG_PRP_COMP_NOT_ENABLED');
                  fnd_message.set_token('ITEM', l_component_item_name);
                  fnd_message.set_token('STRUCTURE', p_revised_item_rec.Alternate_Bom_Code);
                  l_message_log_text := fnd_message.get();
                  fnd_message.set_name('ENG', 'ENG_PRP_COMP_ENABLED');
                  l_temp_mesg := fnd_message.get();
                  Error_Handler.Add_Error_Token(
                      p_Message_Name   => NULL
                    , p_Message_Text   => l_message_log_text || l_temp_mesg
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_message_type       => 'I'
                   );
              END IF;
              CLOSE c_get_item_details;
          ELSE
              FOR i IN 1..l_item_error_table.COUNT
              LOOP
                  Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Component Item Enabling Error:'||l_item_error_table(i).message_name);
                  Error_Handler.Add_Error_Token(
                      p_Message_Name   => NULL
                    , p_Message_Text   => l_item_error_table(i).message_text
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   );
              END LOOP;

          END IF;
      END IF;

      IF l_comp_exists_in_org = G_VAL_FALSE
      THEN
          OPEN c_get_item_details(rc.component_item_id, p_revised_item_unexp_rec.organization_id);
          FETCH c_get_item_details INTO l_component_item_name;
          CLOSE c_get_item_details;

          l_token_tbl.delete;
          l_token_tbl(1).token_name  := 'ITEM';
          l_token_tbl(1).token_value := l_component_item_name;
          l_token_tbl(1).token_name  := 'STRUCTURE';
          l_token_tbl(1).token_value := p_revised_item_rec.Alternate_Bom_Code;

          Error_Handler.Add_Error_Token(
              p_Message_Name       => 'ENG_PRP_COMP_NOT_EXIST'
            , p_Mesg_Token_Tbl     => l_mesg_token_tbl
            , x_Mesg_Token_Tbl     => l_mesg_token_tbl
            , p_Token_Tbl          => l_token_tbl
           );
          RAISE EXC_EXP_SKIP_OBJECT;
      END IF;

      IF (rc.supply_locator_id is NOT NULL)
      THEN
          SELECT CONCATENATED_SEGMENTS
          INTO   l_location_name
          FROM   mtl_item_locations_kfv
          WHERE inventory_location_id = rc.supply_locator_id;
      ELSE
          l_location_name := NULL;
      END IF;

      IF (rc.acd_type in (2,3))
      THEN
          BEGIN
              St_Number := 10;
              select assembly_item_id
              into   item_id
              from   bom_bill_of_materials
              where  bill_sequence_id = rc.bill_sequence_id;

              St_Number := 20;
              select bill_sequence_id
              into   bill_id
              from   bom_bill_of_materials
              where  assembly_item_id =  item_id
              and    organization_id = p_local_organization_id
              and    nvl(ALTERNATE_BOM_DESIGNATOR, 'primary') = nvl(p_revised_item_rec.alternate_bom_code,'primary');

              St_Number := 30;
              select operation_seq_num,trunc(effectivity_date)
              into   old_operation_seq_num,l_old_effectivity_date
              from   bom_inventory_components
              where  COMPONENT_SEQUENCE_ID = rc.OLD_COMPONENT_SEQUENCE_ID;

              St_Number := 40;
              select max(component_sequence_id)
              into   component_seq_id
              from   bom_inventory_components
              where ((trunc(effectivity_date) = l_old_effectivity_date) OR
                     (rc.effectivity_date between
                       trunc(effectivity_date) and
                           NVL(disable_date, rc.effectivity_date + 1))
                        )
              -- Bug 3041105 : Commenting code to pick unimplemented components
              -- and implementation_date IS NOT NULL
              and    component_item_id = rc.COMPONENT_ITEM_ID
              and    bill_sequence_id = bill_id
              and    operation_seq_num = old_operation_seq_num;

              St_Number := 50;
              select effectivity_date
              into old_effectivity_date
              from bom_inventory_components
              where component_sequence_id = component_seq_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
              old_operation_seq_num := NULL;
              old_effectivity_date := NULL;
          WHEN OTHERS THEN
              null;
          END;
      ELSE
          old_operation_seq_num := NULL;
          old_effectivity_date := NULL;
      END IF;

      /* Populate the revised components table for this revised item */

      l_rev_component_tbl(l_rev_component_count).eco_name := rc.change_notice;
      l_rev_component_tbl(l_rev_component_count).organization_code:= p_revised_item_rec.organization_code;
      l_rev_component_tbl(l_rev_component_count).revised_item_name := l_revised_item_name;
      l_rev_component_tbl(l_rev_component_count).new_revised_item_revision := l_new_item_revision;
      l_rev_component_tbl(l_rev_component_count).start_effective_date := rc.effectivity_date;
      l_rev_component_tbl(l_rev_component_count).new_effectivity_date := NULL;
      l_rev_component_tbl(l_rev_component_count).COMMENTS := rc.COMPONENT_REMARKS;
      l_rev_component_tbl(l_rev_component_count).disable_date := rc.disable_date;
      l_rev_component_tbl(l_rev_component_count).operation_sequence_number := rc.operation_seq_num;
      l_rev_component_tbl(l_rev_component_count).component_item_name := l_component_item_name;
      l_rev_component_tbl(l_rev_component_count).alternate_bom_code := p_revised_item_rec.alternate_bom_code;
      l_rev_component_tbl(l_rev_component_count).acd_type := rc.acd_type;
      l_rev_component_tbl(l_rev_component_count).old_effectivity_date := old_effectivity_date;
      l_rev_component_tbl(l_rev_component_count).old_operation_sequence_number := old_operation_seq_num;
      l_rev_component_tbl(l_rev_component_count).new_operation_sequence_number := NULL;
      l_rev_component_tbl(l_rev_component_count).item_sequence_number := rc.item_num;
      l_rev_component_tbl(l_rev_component_count).quantity_per_assembly := rc.component_quantity;
      l_rev_component_tbl(l_rev_component_count).planning_percent := rc.planning_factor;
      l_rev_component_tbl(l_rev_component_count).projected_yield := rc.component_yield_factor;
      l_rev_component_tbl(l_rev_component_count).include_in_cost_rollup := rc.include_in_cost_rollup;
      l_rev_component_tbl(l_rev_component_count).wip_supply_type := rc.wip_supply_type;
      l_rev_component_tbl(l_rev_component_count).so_basis :=  rc.so_basis;
      l_rev_component_tbl(l_rev_component_count).basis_type :=  rc.basis_type;
      l_rev_component_tbl(l_rev_component_count).optional := rc.optional;
      l_rev_component_tbl(l_rev_component_count).mutually_exclusive := rc.mutually_exclusive_options;
      l_rev_component_tbl(l_rev_component_count).check_atp := rc.check_atp;
      l_rev_component_tbl(l_rev_component_count).shipping_allowed := rc.shipping_allowed;
      l_rev_component_tbl(l_rev_component_count).required_to_ship := rc.required_to_ship;
      l_rev_component_tbl(l_rev_component_count).required_for_revenue := rc.required_for_revenue;
      l_rev_component_tbl(l_rev_component_count).include_on_ship_docs := rc.include_on_ship_docs;
      l_rev_component_tbl(l_rev_component_count).quantity_related := rc.quantity_related;
      l_rev_component_tbl(l_rev_component_count).supply_subinventory := rc.supply_subinventory;
      l_rev_component_tbl(l_rev_component_count).location_name := l_location_name;
      l_rev_component_tbl(l_rev_component_count).minimum_allowed_quantity := rc.low_quantity;
      l_rev_component_tbl(l_rev_component_count).maximum_allowed_quantity := rc.high_quantity;
      l_rev_component_tbl(l_rev_component_count).attribute_category  := rc.attribute_category;
      l_rev_component_tbl(l_rev_component_count).attribute1  := rc.attribute1;
      l_rev_component_tbl(l_rev_component_count).attribute2  := rc.attribute2;
      l_rev_component_tbl(l_rev_component_count).attribute3  := rc.attribute3;
      l_rev_component_tbl(l_rev_component_count).attribute4  := rc.attribute4;
      l_rev_component_tbl(l_rev_component_count).attribute5  := rc.attribute5;
      l_rev_component_tbl(l_rev_component_count).attribute6  := rc.attribute6;
      l_rev_component_tbl(l_rev_component_count).attribute7  := rc.attribute7;
      l_rev_component_tbl(l_rev_component_count).attribute8  := rc.attribute8;
      l_rev_component_tbl(l_rev_component_count).attribute9  := rc.attribute9;
      l_rev_component_tbl(l_rev_component_count).attribute10  := rc.attribute10;
      l_rev_component_tbl(l_rev_component_count).attribute11  := rc.attribute11;
      l_rev_component_tbl(l_rev_component_count).attribute12  := rc.attribute12;
      l_rev_component_tbl(l_rev_component_count).attribute13  := rc.attribute13;
      l_rev_component_tbl(l_rev_component_count).attribute14  := rc.attribute14;
      l_rev_component_tbl(l_rev_component_count).attribute15  := rc.attribute15;
      l_rev_component_tbl(l_rev_component_count).from_end_item_unit_number := rc.from_end_item_unit_number;
      l_rev_component_tbl(l_rev_component_count).to_end_item_unit_number := rc.to_end_item_unit_number;
      l_rev_component_tbl(l_rev_component_count).original_system_reference := rc.original_system_reference;
      l_rev_component_tbl(l_rev_component_count).new_from_end_item_unit_number := NULL;
      l_rev_component_tbl(l_rev_component_count).old_from_end_item_unit_number := NULL;
      l_rev_component_tbl(l_rev_component_count).return_status := NULL;
      l_rev_component_tbl(l_rev_component_count).transaction_type := 'CREATE';

      l_rev_component_count := l_rev_component_count + 1;

      /* Fetch all revised substitute component items of this structure of this component */

      FOR sc IN c_plm_sub_comps
      LOOP            /* Loop 6 */

          --FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Substitute Components ...');
          l_item_exits_in_org_flag := G_VAL_TRUE;
          OPEN c_get_item_details(sc.substitute_component_id, p_local_organization_id);
          FETCH c_get_item_details INTO l_substitute_component_name;
          IF c_get_item_details%NOTFOUND
          THEN
              l_item_exits_in_org_flag := G_VAL_FALSE;
          END IF;
          CLOSE c_get_item_details;

          IF sc.acd_type = 1 AND l_item_exits_in_org_flag = G_VAL_FALSE
          THEN
              l_item_error_table.delete;

              Auto_enable_item_in_org(
                  p_inventory_item_id => sc.substitute_component_id
                , p_organization_id  => p_local_organization_id
                , x_error_table      => l_item_error_table
                , x_return_status    => l_return_status);

              IF (l_return_status = 'S')
              THEN
                  OPEN c_get_item_details(sc.substitute_component_id, p_local_organization_id);
                  FETCH c_get_item_details INTO l_substitute_component_name;
                  IF c_get_item_details%NOTFOUND
                  THEN
                      l_item_exits_in_org_flag := G_VAL_FALSE;
                  ELSE
                      l_item_exits_in_org_flag := G_VAL_TRUE;

                      Fnd_message.set_name('ENG', 'ENG_PRP_SUBS_NOT_ENABLED');
                      fnd_message.set_token('ITEM1', l_substitute_component_name);
                      fnd_message.set_token('ITEM2', l_component_item_name);
                      fnd_message.set_token('STRUCTURE', p_revised_item_rec.Alternate_Bom_Code);
                      l_message_log_text := fnd_message.get();
                      fnd_message.set_name('ENG', 'ENG_PRP_COMP_ENABLED');
                      l_temp_mesg := fnd_message.get();
                      Error_Handler.Add_Error_Token(
                          p_Message_Name   => NULL
                        , p_Message_Text   => l_message_log_text || l_temp_mesg
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       );
                  END IF;
                  CLOSE c_get_item_details;
              ELSE
                  FOR i IN 1..l_item_error_table.COUNT
                  LOOP
                      Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Component Item Enabling Error:'||l_item_error_table(i).message_name);
                      Error_Handler.Add_Error_Token(
                          p_Message_Name   => NULL
                        , p_Message_Text   => l_item_error_table(i).message_text
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       );
                  END LOOP;
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Component Enabling Failed ..');
                  l_item_error_table.delete;
              END IF;
          END IF;
          IF l_item_exits_in_org_flag = G_VAL_FALSE
          THEN
              l_has_invalid_objects := G_VAL_TRUE;
              OPEN c_get_item_details(sc.substitute_component_id, p_revised_item_unexp_rec.organization_id);
              FETCH c_get_item_details INTO l_substitute_component_name;
              CLOSE c_get_item_details;

              l_token_tbl.delete;
              l_token_tbl(1).token_name  := 'ITEM1';
              l_token_tbl(1).token_value := l_substitute_component_name;
              l_token_tbl(1).token_name  := 'ITEM2';
              l_token_tbl(1).token_value := l_component_item_name;
              l_token_tbl(3).token_name  := 'STRUCTURE';
              l_token_tbl(3).token_value := p_revised_item_rec.alternate_bom_code;

              Error_Handler.Add_Error_Token(
                  p_Message_Name       => 'ENG_PRP_SUBS_NOT_EXIST'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
               );
          ELSE
              l_sub_component_tbl(l_sub_component_count).eco_name := sc.change_notice;
              l_sub_component_tbl(l_sub_component_count).organization_code:= p_revised_item_rec.organization_code;
              l_sub_component_tbl(l_sub_component_count).revised_item_name := l_revised_item_name;
              l_sub_component_tbl(l_sub_component_count).start_effective_date := rc.effectivity_date;
              l_sub_component_tbl(l_sub_component_count).new_revised_item_revision := l_new_item_revision;
              l_sub_component_tbl(l_sub_component_count).component_item_name := l_component_item_name;
              l_sub_component_tbl(l_sub_component_count).alternate_bom_code := p_revised_item_rec.alternate_bom_code;
              l_sub_component_tbl(l_sub_component_count).substitute_component_name := l_substitute_component_name;
              l_sub_component_tbl(l_sub_component_count).acd_type := sc.acd_type;
              l_sub_component_tbl(l_sub_component_count).operation_sequence_number := rc.operation_seq_num;
              l_sub_component_tbl(l_sub_component_count).substitute_item_quantity := sc.substitute_item_quantity;
              l_sub_component_tbl(l_sub_component_count).attribute_category  := sc.attribute_category;
              l_sub_component_tbl(l_sub_component_count).attribute1  := sc.attribute1;
              l_sub_component_tbl(l_sub_component_count).attribute2  := sc.attribute2;
              l_sub_component_tbl(l_sub_component_count).attribute3  := sc.attribute3;
              l_sub_component_tbl(l_sub_component_count).attribute4  := sc.attribute4;
              l_sub_component_tbl(l_sub_component_count).attribute5  := sc.attribute5;
              l_sub_component_tbl(l_sub_component_count).attribute6  := sc.attribute6;
              l_sub_component_tbl(l_sub_component_count).attribute7  := sc.attribute7;
              l_sub_component_tbl(l_sub_component_count).attribute8  := sc.attribute8;
              l_sub_component_tbl(l_sub_component_count).attribute9  := sc.attribute9;
              l_sub_component_tbl(l_sub_component_count).attribute10  := sc.attribute10;
              l_sub_component_tbl(l_sub_component_count).attribute11  := sc.attribute11;
              l_sub_component_tbl(l_sub_component_count).attribute12  := sc.attribute12;
              l_sub_component_tbl(l_sub_component_count).attribute13  := sc.attribute13;
              l_sub_component_tbl(l_sub_component_count).attribute14  := sc.attribute14;
              l_sub_component_tbl(l_sub_component_count).attribute15  := sc.attribute15;
              l_sub_component_tbl(l_sub_component_count).from_end_item_unit_number  := rc.from_end_item_unit_number;
              l_sub_component_tbl(l_sub_component_count).Original_System_Reference := sc.Original_System_Reference;
              l_sub_component_tbl(l_sub_component_count).return_status := NULL;
              l_sub_component_tbl(l_sub_component_count).transaction_type := 'CREATE';

              l_sub_component_count := l_sub_component_count + 1;
          END IF;
      END LOOP;                                               /* End Loop 6  */
      IF (l_has_invalid_objects = G_VAL_TRUE)
      THEN
          RAISE EXC_EXP_SKIP_OBJECT;
      END IF;
      /* Fetch all revised reference designators on this structure of this revised item */
      FOR rd IN c_plm_ref_desgs
      LOOP                                                    /* Loop 7 */

          --FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Reference Designators ...');
          l_ref_designator_tbl(l_ref_designator_count).eco_name := rd.change_notice;
          l_ref_designator_tbl(l_ref_designator_count).organization_code := p_revised_item_rec.organization_code;
          l_ref_designator_tbl(l_ref_designator_count).revised_item_name := l_revised_item_name;
          l_ref_designator_tbl(l_ref_designator_count).start_effective_date := rc.effectivity_date;
          l_ref_designator_tbl(l_ref_designator_count).new_revised_item_revision := l_new_item_revision;
          l_ref_designator_tbl(l_ref_designator_count).operation_sequence_number := rc.operation_seq_num;
          l_ref_designator_tbl(l_ref_designator_count).component_item_name := l_component_item_name;
          l_ref_designator_tbl(l_ref_designator_count).alternate_bom_code :=  p_revised_item_rec.alternate_bom_code;
          l_ref_designator_tbl(l_ref_designator_count).reference_designator_name := rd.component_reference_designator;
          l_ref_designator_tbl(l_ref_designator_count).acd_type := rd.acd_type;
          l_ref_designator_tbl(l_ref_designator_count).ref_designator_comment := rd.ref_designator_comment;
          l_ref_designator_tbl(l_ref_designator_count).attribute_category := rd.attribute_category;
          l_ref_designator_tbl(l_ref_designator_count).attribute1  := rd.attribute1;
          l_ref_designator_tbl(l_ref_designator_count).attribute2  := rd.attribute2;
          l_ref_designator_tbl(l_ref_designator_count).attribute3  := rd.attribute3;
          l_ref_designator_tbl(l_ref_designator_count).attribute4  := rd.attribute4;
          l_ref_designator_tbl(l_ref_designator_count).attribute5  := rd.attribute5;
          l_ref_designator_tbl(l_ref_designator_count).attribute6  := rd.attribute6;
          l_ref_designator_tbl(l_ref_designator_count).attribute7  := rd.attribute7;
          l_ref_designator_tbl(l_ref_designator_count).attribute8  := rd.attribute8;
          l_ref_designator_tbl(l_ref_designator_count).attribute9  := rd.attribute9;
          l_ref_designator_tbl(l_ref_designator_count).attribute10  := rd.attribute10;
          l_ref_designator_tbl(l_ref_designator_count).attribute11  := rd.attribute11;
          l_ref_designator_tbl(l_ref_designator_count).attribute12  := rd.attribute12;
          l_ref_designator_tbl(l_ref_designator_count).attribute13  := rd.attribute13;
          l_ref_designator_tbl(l_ref_designator_count).attribute14  := rd.attribute14;
          l_ref_designator_tbl(l_ref_designator_count).attribute15  := rd.attribute15;
          l_ref_designator_tbl(l_ref_designator_count).Original_System_Reference := rd.Original_System_Reference;
          l_ref_designator_tbl(l_ref_designator_count).new_reference_designator := NULL;
          l_ref_designator_tbl(l_ref_designator_count).from_end_item_unit_number := NULL;
          l_ref_designator_tbl(l_ref_designator_count).return_status := NULL;
          l_ref_designator_tbl(l_ref_designator_count).transaction_type := 'CREATE';
          l_ref_designator_count := l_ref_designator_count + 1;
      END LOOP;        /* End Loop 7 */

  END LOOP; -- End of loop of revised components Only one is selected

  Eng_Eco_Pvt.Process_Rev_Comp(
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    , p_change_notice      => p_revised_item_rec.eco_name
    , p_organization_id    => p_local_organization_id
    , I                    => 1
    , p_rev_component_rec  => l_rev_component_tbl(1)
    , p_ref_designator_tbl => l_ref_designator_tbl
    , p_sub_component_tbl  => l_sub_component_tbl
    , x_rev_component_tbl  => l_rev_component_tbl
    , x_ref_designator_tbl => l_ref_designator_tbl
    , x_sub_component_tbl  => l_sub_component_tbl
    , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
    , x_Mesg_Token_Tbl     => l_bo_Mesg_Token_Tbl
    , x_return_status      => l_return_status
    , x_bill_sequence_id   => p_revised_item_unexp_rec.bill_sequence_id
   );
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
      RAISE EXC_EXP_SKIP_OBJECT;
  END IF;
  --
  -- Add messages through propagation Maps
  -- Calling log_errors first as in case of successful propagation the messages are not being displayed
  --
  Eco_Error_Handler.Log_Error(
      p_error_status         => l_return_status
    , p_mesg_token_tbl       => l_mesg_token_tbl
    , p_error_scope          => Error_Handler.G_SCOPE_RECORD
    , p_error_level          => Eco_Error_Handler.G_RC_LEVEL
    , x_eco_rec              => ENG_Eco_PUB.G_MISS_ECO_REC
    , x_eco_revision_tbl     => ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
    , x_change_line_tbl      => ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL -- Eng Change
    , x_revised_item_tbl     => ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
    , x_rev_component_tbl    => l_rev_component_tbl
    , x_ref_designator_tbl   => l_ref_designator_tbl
    , x_sub_component_tbl    => l_sub_component_tbl
    , x_rev_operation_tbl    => ENG_Eco_PUB.G_MISS_REV_OPERATION_TBL
    , x_rev_op_resource_tbl  => ENG_Eco_PUB.G_MISS_REV_OP_RESOURCE_TBL
    , x_rev_sub_resource_tbl => ENG_Eco_PUB.G_MISS_REV_SUB_RESOURCE_TBL
   );

  Eng_Propagation_Log_Util.Add_Entity_Map(
      p_change_id                 => p_change_id
    , p_revised_item_sequence_id  => p_revised_item_sequence_id
    , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_CMP_CHG
    , p_revised_line_id1          => p_component_sequence_id
    , p_local_organization_id     => p_local_organization_id
    , p_local_revised_item_seq_id => p_revised_item_unexp_rec.revised_item_sequence_id
    , p_local_revised_line_id1    => l_rev_comp_unexp_rec.component_sequence_id
    , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
    , p_entity_action_status      => l_entity_action_status
    , p_bo_entity_identifier      => 'RC'--Eco_Error_Handler.G_RC_LEVEL
   );
  -- TODO: How to handle substitue component and reference designator errors
EXCEPTION
WHEN EXC_EXP_SKIP_OBJECT THEN
    -- Set the return status
    l_return_status := FND_API.G_RET_STS_ERROR;
    -- Log any messages that have been logged with the additional error
    -- message into error handler
    Eco_Error_Handler.Log_Error(
        p_error_status         => l_return_status
      , p_mesg_token_tbl       => l_mesg_token_tbl
      , p_error_scope          => Error_Handler.G_SCOPE_RECORD
      , p_error_level          => Eco_Error_Handler.G_RC_LEVEL
      , x_eco_rec              => ENG_Eco_PUB.G_MISS_ECO_REC
      , x_eco_revision_tbl     => ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
      , x_change_line_tbl      => ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL -- Eng Change
      , x_revised_item_tbl     => ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_rev_operation_tbl    => ENG_Eco_PUB.G_MISS_REV_OPERATION_TBL
      , x_rev_op_resource_tbl  => ENG_Eco_PUB.G_MISS_REV_OP_RESOURCE_TBL
      , x_rev_sub_resource_tbl => ENG_Eco_PUB.G_MISS_REV_SUB_RESOURCE_TBL
     );
    -- local change id is set later
    -- if there are errors, based on the level they are not populated in the
    -- maps table.
    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => p_change_id
      , p_revised_item_sequence_id  => p_revised_item_sequence_id
      , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_CMP_CHG
      , p_revised_line_id1          => p_component_sequence_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
      , p_bo_entity_identifier      => 'RC'--Eco_Error_Handler.G_RC_LEVEL
     );
    x_return_status := l_return_status;
END Propagate_Revised_Component;

PROCEDURE Check_Change_Existance (
    p_change_notice       IN VARCHAR2
  , p_organization_id     IN NUMBER
  , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_Status       OUT NOCOPY VARCHAR2
) IS

    CURSOR c_change_notice IS
    SELECT G_VAL_EXISTS
      FROM eng_engineering_changes
     WHERE change_notice = p_change_notice
       AND organization_id = p_organization_id;

    l_change_exists    NUMBER;
    l_Mesg_token_Tbl   Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status    VARCHAR2(1);
    l_err_text         VARCHAR2(2000);
    l_Token_Tbl        Error_Handler.Token_Tbl_Type;

BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_change_exists := G_VAL_NOT_EXISTS;

    OPEN c_change_notice;
    FETCH c_change_notice INTO l_change_exists;
    CLOSE c_change_notice;

    IF l_change_exists = G_VAL_EXISTS
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        Error_Handler.Add_Error_Token(
            p_Message_Name       => 'ENG_PRP_ECO_EXISTS'
          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
          , p_Token_Tbl          => l_token_tbl
         );
    END IF;
EXCEPTION
WHEN OTHERS THEN
    IF c_change_notice%ISOPEN
    THEN
        CLOSE c_change_notice;
    END IF;
    l_return_status := FND_API.G_RET_STS_ERROR;
END Check_Change_Existance;

PROCEDURE Init_Local_Change_Lifecycle (
    p_local_change_id    IN NUMBER
  , p_organization_id    IN NUMBER
  , p_org_hierarchy_name IN VARCHAR2
  , x_return_status      OUT NOCOPY VARCHAR2
) IS
  l_status_code          NUMBER;
  l_msg_count            NUMBER;
  l_mesg_data            VARCHAR2(2000);
  l_schedule_immediately ENG_ORG_HIERARCHY_POLICIES.SCHEDULE_IMMEDIATELY_FLAG%TYPE;
  l_new_status_type      NUMBER;
  CURSOR c_get_schedule_enabled IS
  SELECT eohp.SCHEDULE_IMMEDIATELY_FLAG
    FROM ENG_ORG_HIERARCHY_POLICIES eohp, ENG_TYPE_ORG_HIERARCHIES etoh, eng_engineering_changes eec
   WHERE eec.change_id = p_local_change_id
     AND eohp.organization_id = eec.organization_id
     AND eohp.SCHEDULE_IMMEDIATELY_FLAG = 'Y'
     AND eohp.change_type_org_hierarchy_id = etoh.change_type_org_hierarchy_id
     AND etoh.change_type_id = eec.change_order_type_id
     AND etoh.organization_id = p_organization_id
     AND EXISTS (SELECT 1
                   FROM per_organization_structures hier
                  WHERE hier.name = p_org_hierarchy_name
                    AND etoh.hierarchy_id =  hier.organization_structure_id);

  -- cursor to fetch the status in which the change is to be initialized
  -- this cursor fetches the shduled status of the change if
  -- schedule immediately is set for the selected hierarchy at the change level
  -- for TTM case since the processing is per organization and the submit change
  -- would have been enabled this is not going to be called
  CURSOR c_get_init_status IS
  SELECT els.status_code
    FROM eng_lifecycle_statuses els
   WHERE els.entity_id1  = p_local_change_id
     AND els.entity_name = 'ENG_CHANGE'
     AND els.sequence_number =
                (SELECT min(sequence_number)
                   FROM eng_lifecycle_statuses els1, eng_change_statuses_vl ecs1
                  WHERE els1.entity_id1  = p_local_change_id
                    AND els1.entity_name = 'ENG_CHANGE'
                    AND els1.status_code = ecs1.status_code
                    AND ((ecs1.status_type = 4 AND l_schedule_immediately = 'Y')
                         OR nvl(l_schedule_immediately, 'N') = 'N'))
     AND EXISTS (SELECT 1
                   FROM eng_engineering_changes
                  WHERE change_id = els.entity_id1
                    AND status_type = 0);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_get_schedule_enabled;
    FETCH c_get_schedule_enabled INTO l_schedule_immediately;
    CLOSE c_get_schedule_enabled;
    OPEN c_get_init_status;
    FETCH c_get_init_status INTO l_status_code;
    IF c_get_init_status%FOUND
    THEN
        ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle(
            p_api_version       => 1.0
          , p_change_id         => p_local_change_id
          , x_return_status     => x_return_status
          , x_msg_count         => l_msg_count
          , x_msg_data          => l_mesg_data
          , p_api_caller        => 'CP'
          , p_init_status_code  => l_status_code
         );

        SELECT status_type
          INTO l_new_status_type
          FROM eng_change_statuses
         WHERE status_code = l_status_code
           AND rownum = 1;
        -- The following update should be moved to init lifecycle
        UPDATE eng_revised_items
           SET status_code = l_status_code,
               status_type = l_new_status_type,
               last_update_date = sysdate,
               last_updated_by = FND_PROFILE.VALUE('USER_ID'),
               last_update_login = FND_PROFILE.VALUE('LOGIN_ID')
         WHERE change_id = p_local_change_id;
    END IF;
    CLOSE c_get_init_status;
EXCEPTION
WHEN OTHERS THEN
    IF c_get_init_status%ISOPEN
    THEN
        CLOSE c_get_init_status;
    END IF;
    IF c_get_schedule_enabled%ISOPEN
    THEN
        CLOSE c_get_schedule_enabled;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
END Init_Local_Change_Lifecycle;

PROCEDURE Propagate_Change_Header (
    p_change_id               IN NUMBER
  , p_change_notice           IN VARCHAR2
  , p_organization_code       IN VARCHAR2
  , p_organization_id         IN NUMBER
  , p_org_hierarchy_name      IN VARCHAR2
  , p_local_organization_code IN VARCHAR2
  , p_local_organization_id   IN NUMBER
  , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_Status           OUT NOCOPY VARCHAR2
) IS
    -- Local Identifiers
    l_local_change_id       NUMBER;
    -- Exposed Column Data
    l_change_type_code      VARCHAR2(80);
    l_change_mgmt_type      Eng_change_order_types_tl.type_name%TYPE; --Bug 3544760
    l_requestor_name        VARCHAR2(30);
    l_assignee_name         VARCHAR2(360);
    l_Task_Number           VARCHAR2(25);
    l_Project_Number        VARCHAR2(30);
    -- Some internl variables
    l_sched_immediately     NUMBER := 1;
    l_pk1_value             VARCHAR2(100);
    l_pk2_value             VARCHAR2(100);
    l_pk3_value             VARCHAR2(100);
    l_entity_name           VARCHAR2(30);
    l_header_subject_exists NUMBER := 1;
    i                       NUMBER;
    l_invalid_subject       NUMBER := 0;
    l_pk1_name              VARCHAR2(40);
    l_pk2_name              VARCHAR2(3);
    l_pk3_name              VARCHAR2(3);
    l_approval_status       VARCHAR2(80);
    l_task_number1          VARCHAR2(100);
    l_party_id              NUMBER;
    l_party_type            VARCHAR2(30);
    l_default_assignee_type eng_change_order_types.default_assignee_type%TYPE;
    l_assignee_role_id      NUMBER;
    l_status_name           eng_change_statuses_tl.status_name%TYPE;
    l_department_name           VARCHAR2(240);
    l_change_type_id        NUMBER;
    -- Variables for error handling
    l_msg_count             NUMBER;
    l_Mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status         VARCHAR2(1);
    l_err_text              VARCHAR2(2000);
    l_Token_Tbl             Error_Handler.Token_Tbl_Type;
    -- Variables for Call to Process ECO
    l_eco_rec               Eng_Eco_Pub.Eco_Rec_Type;
    l_change_lines_tbl      Eng_Eco_Pub.Change_Line_Tbl_Type;
    l_eco_revision_tbl      Eng_Eco_Pub.Eco_Revision_Tbl_Type;
    l_revised_item_tbl      Eng_Eco_Pub.Revised_Item_Tbl_Type;
    l_rev_component_tbl     Bom_Bo_Pub.Rev_Component_Tbl_Type;
    l_sub_component_tbl     Bom_Bo_Pub.Sub_Component_Tbl_Type;
    l_ref_designator_tbl    Bom_Bo_Pub.Ref_Designator_Tbl_Type;
    l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
    l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
    l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

   --
   -- Cursor to Pick all ECO header for the Top Organization for the given
   -- Change Notice
   CURSOR c_eco_rec IS
   SELECT *
     FROM eng_engineering_changes
    WHERE change_notice = p_change_notice
      AND organization_id = p_organization_id;

   -- Cursor to Pick all Revised Items for the Top Organization for the given
   -- Change Notice
   CURSOR c_eco_revision IS
   SELECT *
     FROM eng_change_order_revisions
    WHERE change_notice = p_change_notice
      AND organization_id = p_organization_id
      AND nvl(start_date, sysdate) > sysdate; -- Added this condtion as only future revisions need to be fetched
   /* Cursor to fetch the group name given the party id */
   CURSOR c_group_name(cp_party_id NUMBER) IS
   SELECT party_name
   FROM hz_parties
   WHERE party_id = cp_party_id
   AND party_type = 'GROUP';

   /* Cursor to fetch the assignees with direct item roles at item level */
   CURSOR c_item_assignee(cp_assignee_role_id NUMBER, cp_item_id NUMBER, cp_org_id NUMBER) IS
   SELECT party.party_id, party.party_name, party.party_type
   FROM  HZ_PARTIES party, fnd_grants grants, fnd_objects obj
   WHERE obj.obj_name = 'EGO_ITEM'
   AND grants.object_id = obj.object_id
   AND grants.GRANTEE_ORIG_SYSTEM_ID =  party.party_id
   AND (
        (grants.GRANTEE_ORIG_SYSTEM = 'HZ_PARTY' AND grants.grantee_type ='USER' AND party.party_type= 'PERSON')
        OR (grants.GRANTEE_ORIG_SYSTEM = 'HZ_GROUP' AND grants.grantee_type ='GROUP' AND party.party_type= 'GROUP')
       )
   AND grants.start_date <= SYSDATE
   AND NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
   AND grants.instance_type = 'INSTANCE'
   AND grants.menu_id = cp_assignee_role_id
   AND grants.instance_pk1_value = cp_item_id
   AND grants.instance_pk2_value = cp_org_id
   AND ROWNUM = 1;

   /* Cursor to fetch the assignees with item roles at catalog category level */
   CURSOR c_category_item_assignee(cp_assignee_role_id NUMBER, cp_item_id NUMBER, cp_org_id NUMBER) IS
   SELECT party.party_id, party.party_name, party.party_type
   FROM  HZ_PARTIES party, fnd_grants grants, fnd_objects obj
   WHERE obj.obj_name = 'EGO_ITEM'
   AND grants.object_id = obj.object_id
   AND grants.GRANTEE_ORIG_SYSTEM_ID =  party.party_id
   AND (
    (grants.GRANTEE_ORIG_SYSTEM = 'HZ_PARTY' AND grants.grantee_type ='USER' AND party.party_type= 'PERSON')
        OR (grants.GRANTEE_ORIG_SYSTEM = 'HZ_GROUP' AND grants.grantee_type ='GROUP' AND party.party_type= 'GROUP')
       )
   AND grants.start_date <= SYSDATE
   AND NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
   AND grants.instance_type= 'SET'
   AND grants.menu_id = cp_assignee_role_id
   AND grants.instance_set_id IN ( SELECT instance_set.instance_set_id
                   FROM fnd_object_instance_sets instance_set, mtl_system_items_b item1
                   WHERE instance_set.object_id = grants.object_id
                   AND instance_set.instance_set_name = 'EGO_ORG_CAT_ITEM_' ||
                    to_char(item1.organization_id) || '_' || to_char(item1.ITEM_CATALOG_GROUP_ID)
                   AND item1.INVENTORY_ITEM_ID= cp_item_id
                   AND item1.ORGANIZATION_ID = cp_org_id  )
   AND ROWNUM = 1;

   /* Cursor to fetch the assignees with item roles at organization level */
   CURSOR  c_org_assignee(cp_assignee_role_id NUMBER, cp_org_id NUMBER) IS
   SELECT  party.party_id, party.party_name, party.party_type
   FROM  HZ_PARTIES party, fnd_grants grants, fnd_objects obj
   WHERE obj.obj_name = 'EGO_ITEM'
   AND grants.object_id = obj.object_id
   AND grants.GRANTEE_ORIG_SYSTEM_ID =  party.party_id
   AND (
    (grants.GRANTEE_ORIG_SYSTEM = 'HZ_PARTY' AND grants.grantee_type ='USER' AND party.party_type= 'PERSON')
        OR (grants.GRANTEE_ORIG_SYSTEM = 'HZ_GROUP' AND grants.grantee_type ='GROUP' AND party.party_type= 'GROUP')
       )
   AND grants.start_date <= SYSDATE
   AND NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
   AND grants.instance_type= 'SET'
   AND grants.menu_id = cp_assignee_role_id
   AND grants.instance_set_id IN ( SELECT instance_set.instance_set_id
                   FROM fnd_object_instance_sets instance_set
                   WHERE instance_set.object_id = grants.object_id
                   AND instance_set.instance_set_name = 'EGO_ORG_ITEM_' ||cp_org_id)
   AND ROWNUM = 1;

   -- Bug No: 4327218
   -- Modified query to refer to 'person_party_id' instead of 'customer_id'
   CURSOR c_user_name(v_party_id IN NUMBER) IS
   SELECT us.user_name FROM fnd_user us, hz_parties pa
   WHERE ((us.employee_id IS NOT NULL AND us.employee_id = pa.person_identifier))
   AND pa.party_id = v_party_id
   union all
   SELECT us.user_name
   FROM fnd_user us, hz_parties pa
   WHERE (us.employee_id IS NULL AND (us.person_party_id = pa.party_id or (us.person_party_id is null and us.supplier_id = pa.party_id)))
   AND pa.party_id = v_party_id;

BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- Check if the change header has already been propagated
    --
    Propagated_Local_Change(
        p_change_id             => p_change_id
      , p_local_organization_id => p_local_organization_id
      , x_local_change_id       => l_local_change_id
     );
    --
    -- If propagated local change exists , then the header processing will
    -- not continue . Return control to calling program .
    --
    IF l_local_change_id IS NOT NULL
    THEN
        Error_Handler.Add_Error_Token(
            p_Message_Name       => 'ENG_PRP_ECO_PROPAGATED'
          , p_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
          , p_Token_Tbl          => l_token_tbl
          , p_message_type       => 'W'
         );
        RETURN;
    END IF;

    --
    -- Check if the change order already exists in the organization
    -- with the same change_notice value. Then raise an error
    --
    Check_Change_Existance(
        p_change_notice       => p_change_notice
      , p_organization_id     => p_local_organization_id
      , x_Mesg_Token_Tbl      => l_mesg_token_tbl
      , x_Return_Status       => l_return_status
     );
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        RAISE EXC_EXP_SKIP_OBJECT;
    END IF;

    FOR eco_rec IN c_eco_rec  -- Loop 1
    LOOP
        IF (eco_rec.status_type IS NOT NULL AND eco_rec.status_type = 5)       /* Cancelled ECO check */
        THEN
            RAISE EXC_EXP_SKIP_OBJECT;
        END IF;

        IF (eco_rec.change_order_type_id IS NOT NULL)
        THEN
            -- Changes for bug 3544760
            -- Fetching the change category name also
            SELECT ecotv.CHANGE_ORDER_TYPE
                 , ecmtv.name
                 , ecotv.default_assignee_type
                 , ecotv.default_assignee_id
              INTO l_change_type_code
                 , l_change_mgmt_type
                 , l_default_assignee_type
                 , l_assignee_role_id
              FROM eng_change_order_types_v ecotv
                 , eng_change_mgmt_types_vl ecmtv
             WHERE ecotv.change_order_type_id = eco_rec.change_order_type_id
               AND ecotv.CHANGE_MGMT_TYPE_CODE = ecmtv.CHANGE_MGMT_TYPE_CODE;
        ELSE
            l_change_type_code := NULL;
            l_change_mgmt_type := NULL; -- bug 3544760
        END IF;

        IF (eco_rec.responsible_organization_id IS NOT NULL)
        THEN
            SELECT name
            INTO   l_department_name
            FROM   hr_all_organization_units
            WHERE  organization_id = eco_rec.responsible_organization_id;
        ELSE
            l_department_name := NULL;
        END IF;

        IF (eco_rec.requestor_id IS NOT NULL)
        THEN
            BEGIN
                OPEN c_user_name(eco_rec.requestor_id);
                FETCH c_user_name INTO l_requestor_name;
                CLOSE c_user_name;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,
                                  'No_Data_found for requestor id '
                                  || to_char( eco_rec.requestor_id)
                                  || ' in org ' || to_char(p_organization_id));
                l_requestor_name := NULL;
            END;
        ELSE
            l_requestor_name := NULL;
        END IF;

        IF (eco_rec.PROJECT_ID IS NOT NULL)
        THEN
            BEGIN
                SELECT name
                into   l_Project_Number
                FROM   pa_projects_all
                WHERE  project_id = eco_rec.PROJECT_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for project id ' || to_char( eco_rec.PROJECT_ID));
                l_Project_Number := NULL;
            END;
        ELSE
            l_Project_Number := NULL;
        END IF;

        IF (eco_rec.TASK_ID IS NOT NULL)
        THEN
            BEGIN
                SELECT task_number
                INTO   l_Task_Number
                FROM   pa_tasks
                WHERE  TASK_ID = eco_rec.TASK_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'No_Data_found for task id ' || to_char( eco_rec.TASK_ID));
                l_Task_Number := NULL;
            END;
        ELSE
            l_Task_Number := NULL;
        END IF;

        IF(eco_rec.PROJECT_ID IS NOT NULL AND eco_rec.TASK_ID IS NOT NULL)
        THEN
            BEGIN
                SELECT PPE.ELEMENT_NUMBER
                INTO l_task_number1
                FROM PA_PROJ_ELEMENTS PPE
                WHERE PPE.PROJECT_ID = Eco_rec.PROJECT_ID
                AND PPE.PROJ_ELEMENT_ID = Eco_rec.TASK_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_task_number1 := NULL;
            END;
        ELSE
             l_task_number1 := NULL;
        END IF;

        /* check whether the local organization eco needs to be scheduled immediately */
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing ECO Fetch status..' );
        BEGIN
            SELECT 1
            INTO l_sched_immediately
            FROM ENG_ORG_HIERARCHY_POLICIES
            WHERE organization_id = p_local_organization_id
            AND SCHEDULE_IMMEDIATELY_FLAG = 'Y'
            AND change_type_org_hierarchy_id =
                  (SELECT change_type_org_hierarchy_id
                   FROM ENG_TYPE_ORG_HIERARCHIES
                   WHERE change_type_id = l_change_type_id
                   AND organization_id = p_organization_id
                   AND hierarchy_id = (SELECT organization_structure_id
                           FROM per_organization_structures
                           WHERE name = p_org_hierarchy_name));
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_sched_immediately  := 0;
        END;

        IF (l_sched_immediately = 1)
        THEN
             --
             -- To be handled differently wrt init lifecycle
             -- The status to the BO for processing the header should be draft in all cases
             --
             null;
        END IF;
        -- Fetch status details
        SELECT ecs.status_name
          INTO l_status_name
          FROM eng_change_statuses_vl ecs
         WHERE ecs.status_code = 0;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Status = ' || l_status_name);

        ENGECOBO.GLOBAL_CHANGE_ID := p_change_id;
        ENGECOBO.GLOBAL_ORG_ID := eco_rec.organization_id;

        -- Fetch change subjects
        BEGIN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing Subject .. ');

            l_header_subject_exists := 1;

            select sub1.pk1_value, sub1.pk2_value, sub2.pk3_value, sub2.entity_name
            INTO l_pk1_value, l_pk2_value, l_pk3_value, l_entity_name
            from eng_change_subjects sub1,eng_change_subjects sub2
            where sub1.change_id = sub2.change_id
            and sub1.change_id = p_change_id
            and sub1.change_line_id is null
            and sub2.change_line_id is null
            and sub1.entity_name = 'EGO_ITEM'
            and ((sub2.entity_name = 'EGO_ITEM_REVISION' and sub2.subject_level =1 and sub1.subject_level=2 )
            or (sub2.entity_name = sub1.entity_name and sub2.subject_level = sub1.subject_level and sub1.subject_level=1 ))
            and rownum =1;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_header_subject_exists := 0;
        END;

        IF (l_header_subject_exists = 1)
        THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing Subject 2.. ');
            --
            -- Setting Pk1 Value
            IF (l_pk1_value IS NOT NULL)
            THEN
                BEGIN
                    SELECT concatenated_segments
                    INTO   l_pk1_name
                    FROM   mtl_system_items_b_kfv
                    WHERE  inventory_item_id = l_pk1_value
                    AND    organization_id   = p_local_organization_id;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_SUBJECT_ITEM_INVALID'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl
                     );
                    RAISE EXC_EXP_SKIP_OBJECT;
                END;
            END IF;
            --
            -- Setting Pk2 Value
            l_pk2_name := p_local_organization_code;
            --
            -- Setting Pk3 Value
            IF (l_entity_name = 'EGO_ITEM_REVISION' AND l_invalid_subject <> 1
               AND l_pk1_value IS NOT NULL AND l_pk3_value IS NOT NULL)
            THEN
                BEGIN
                    select revision
                    into l_pk3_name
                    from mtl_item_revisions
                    where inventory_item_id = l_pk1_value
                    AND    organization_id = p_local_organization_id
                    and revision = ( select revision
                            from mtl_item_revisions
                            where revision_id = l_pk3_value);
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;

                    l_token_tbl(1).token_name  := 'ITEM';
                    l_token_tbl(1).token_value := l_pk1_name;

                    Error_Handler.Add_Error_Token(
                        p_Message_Name       => 'ENG_PRP_SUBJECT_REV_INVALID'
                      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                      , p_Token_Tbl          => l_token_tbl
                     );
                    RAISE EXC_EXP_SKIP_OBJECT;
                END;
            END IF;
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing Subject Status  ' || l_invalid_subject);

        -- Changes for bug 3547805
        -- Assignee Name Processing
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing Assignee ..');
        l_party_id := eco_rec.assignee_id;
        l_assignee_name := NULL ;
        BEGIN
            -- if subject item is not null then process the role based assignee types
            IF (l_pk1_value IS NOT NULL AND l_assignee_role_id IS NOT NULL AND l_default_assignee_type IS NOT NULL)
            THEN
                -- Process role based types
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing Assignee Roles..');
                IF (l_default_assignee_type = 'EGO_ITEM')
                THEN
                    OPEN c_item_assignee(l_assignee_role_id , l_pk1_value , p_local_organization_id );
                    FETCH c_item_assignee INTO l_party_id, l_assignee_name, l_party_type;
                    CLOSE c_item_assignee;
                ELSIF (l_default_assignee_type = 'EGO_CATALOG_GROUP')
                THEN
                    OPEN c_category_item_assignee(l_assignee_role_id , l_pk1_value , p_local_organization_id );
                    FETCH c_category_item_assignee INTO l_party_id, l_assignee_name, l_party_type;
                    CLOSE c_category_item_assignee;
                ELSIF (l_default_assignee_type = 'ENG_CHANGE')
                THEN
                    OPEN c_org_assignee(l_assignee_role_id , p_local_organization_id );
                    FETCH c_org_assignee INTO l_party_id, l_assignee_name, l_party_type;
                    CLOSE c_org_assignee;
                END IF;
            END IF;

            -- For all other cases and if role based type has person as assignee then
            -- Fetch the assignee name
            IF (l_party_id IS NOT NULL AND (l_party_type IS NULL OR l_party_type <> 'GROUP'))
            THEN
                OPEN c_user_name(l_party_id);
                FETCH c_user_name INTO l_assignee_name;
                IF c_user_name%NOTFOUND
                THEN
                    OPEN c_group_name(l_party_id);
                    FETCH c_group_name INTO l_assignee_name;
                    CLOSE c_group_name;
                END IF;
                CLOSE c_user_name;
            END IF;
        EXCEPTION
        WHEN OTHERS THEN
            IF c_item_assignee%ISOPEN THEN
                CLOSE c_item_assignee;
            END IF;
            IF c_category_item_assignee%ISOPEN THEN
                CLOSE c_category_item_assignee;
            END IF;
            IF c_org_assignee%ISOPEN THEN
                CLOSE c_org_assignee;
            END IF;
            IF c_user_name%ISOPEN THEN
                CLOSE c_user_name;
            END IF;
            IF c_user_name%ISOPEN THEN
                CLOSE c_user_name;
            END IF;
            l_assignee_name := null;
        END;
         -- End changes for bug 3547805

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Population ECO Header Info.. ');
         /*  Popuating PL/SQL record for ECO Header    */
        l_eco_rec.eco_name := eco_rec.change_notice;
	l_eco_rec.change_name := eco_rec.change_name; --Added for bug 9405365
        l_eco_rec.organization_code := p_local_organization_code;
        l_eco_rec.change_type_code := l_change_type_code;
        l_eco_rec.status_name := l_status_name;
        l_eco_rec.eco_department_name := l_department_name;
        l_eco_rec.priority_code := eco_rec.priority_code;
        -- l_eco_rec.approval_list_name := l_approval_list_name;
        -- l_eco_rec.Approval_Status_Name := l_approval_status;
        -- Bug 3897954:For PLM records, the master org approval status will
        -- not be propagated as PLM ECOs are always created with an initialized
        -- lifecycle by ECO BO.
        l_eco_rec.reason_code := eco_rec.reason_code;
        l_eco_rec.eng_implementation_cost := eco_rec.estimated_eng_cost;
        l_eco_rec.mfg_implementation_cost := eco_rec.estimated_mfg_cost;
        l_eco_rec.cancellation_comments := eco_rec.cancellation_comments;
        l_eco_rec.requestor :=  l_requestor_name;
        l_eco_rec.assignee :=  l_assignee_name;
        l_eco_rec.description := eco_rec.description;
        l_eco_rec.attribute_category := eco_rec.attribute_category;
        l_eco_rec.attribute1  := eco_rec.attribute1;
        l_eco_rec.attribute2  := eco_rec.attribute2;
        l_eco_rec.attribute3  := eco_rec.attribute3;
        l_eco_rec.attribute4  := eco_rec.attribute4;
        l_eco_rec.attribute5  := eco_rec.attribute5;
        l_eco_rec.attribute6  := eco_rec.attribute6;
        l_eco_rec.attribute7  := eco_rec.attribute7;
        l_eco_rec.attribute8  := eco_rec.attribute8;
        l_eco_rec.attribute9  := eco_rec.attribute9;
        l_eco_rec.attribute10  := eco_rec.attribute10;
        l_eco_rec.attribute11  := eco_rec.attribute11;
        l_eco_rec.attribute12  := eco_rec.attribute12;
        l_eco_rec.attribute13  := eco_rec.attribute13;
        l_eco_rec.attribute14  := eco_rec.attribute14;
        l_eco_rec.attribute15  := eco_rec.attribute15;
         -- l_eco_rec.Original_System_Reference := eco_rec.Original_System_Reference;
        l_eco_rec.Project_Name := l_project_number;
        l_eco_rec.Task_Number := l_Task_Number1;
         --l_eco_rec.hierarchy_flag := 2;
        l_eco_rec.organization_hierarchy := NULL;
        l_eco_rec.return_status := NULL;

        --lkasturi: 11.5.10 changes

        l_eco_rec.plm_or_erp_change := 'PLM';
        l_eco_rec.pk1_name := l_pk1_name;
        l_eco_rec.pk2_name := l_pk2_name;
        l_eco_rec.pk3_name := l_pk3_name;
        l_eco_rec.change_management_type := l_change_mgmt_type; -- Bug 3544760
        --lkasturi: 11.5.10 end changes
        l_eco_rec.transaction_type := 'CREATE';
        -- Fetch ECO Revisions
        i := 1;
        FOR rev IN c_eco_revision
        LOOP
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing ECO Revision ...');
            l_eco_revision_tbl(i).eco_name := rev.change_notice;
            l_eco_revision_tbl(i).organization_code:= p_local_organization_code;
            l_eco_revision_tbl(i).revision := rev.revision;
            -- l_eco_revision_tbl(i).new_revision := rev.new_revision;
            l_eco_revision_tbl(i).new_revision := NULL;
            l_eco_revision_tbl(i).Attribute_category := rev.Attribute_category;
            l_eco_revision_tbl(i).attribute1  := rev.attribute1;
            l_eco_revision_tbl(i).attribute2  := rev.attribute2;
            l_eco_revision_tbl(i).attribute3  := rev.attribute3;
            l_eco_revision_tbl(i).attribute4  := rev.attribute4;
            l_eco_revision_tbl(i).attribute5  := rev.attribute5;
            l_eco_revision_tbl(i).attribute6  := rev.attribute6;
            l_eco_revision_tbl(i).attribute7  := rev.attribute7;
            l_eco_revision_tbl(i).attribute8  := rev.attribute8;
            l_eco_revision_tbl(i).attribute9  := rev.attribute9;
            l_eco_revision_tbl(i).attribute10  :=rev.attribute10;
            l_eco_revision_tbl(i).attribute11  :=rev.attribute11;
            l_eco_revision_tbl(i).attribute12  :=rev.attribute12;
            l_eco_revision_tbl(i).attribute13  := rev.attribute13;
            l_eco_revision_tbl(i).attribute14  := rev.attribute14;
            l_eco_revision_tbl(i).attribute15  := rev.attribute15;
            l_eco_revision_tbl(i).Original_System_Reference := rev.Original_System_Reference;
            l_eco_revision_tbl(i).comments := rev.comments;
            l_eco_revision_tbl(i).return_status := NULL;
            l_eco_revision_tbl(i).transaction_type := 'CREATE';
            i := i + 1;
        END LOOP; -- End rev IN c_eco_revision
    END LOOP;

    -- Process Header and ECO Revisions
    Eng_Eco_Pub.Process_Eco(
        p_api_version_number   => 1.0
      , p_init_msg_list        => FALSE
      , x_return_status        => l_return_status
      , x_msg_count            => l_msg_count
      , p_bo_identifier        => 'ECO'
      , p_ECO_rec              => l_eco_rec
      , p_eco_revision_tbl     => l_eco_revision_tbl
      , x_ECO_rec              => l_eco_rec
      , x_eco_revision_tbl     => l_eco_revision_tbl
      , x_change_line_tbl      => l_change_lines_tbl
      , x_revised_item_tbl     => l_revised_item_tbl
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_rev_operation_tbl    => l_rev_operation_tbl
      , x_rev_op_resource_tbl  => l_rev_op_resource_tbl
      , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
     );
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'After Propagation ECO l_return_status'|| l_return_status);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

        Eco_Error_Handler.Log_Error(
            p_error_status         => FND_API.G_RET_STS_SUCCESS
          , p_error_scope          => Error_Handler.G_SCOPE_RECORD
          , p_error_level          => Eco_Error_Handler.G_ECO_LEVEL
          , p_other_message        => 'ENG_PRP_CHG_ORDER_SUCC'
          , p_other_status         => l_return_status
          , p_other_token_tbl      => l_token_tbl
          , x_eco_rec              => l_eco_rec
          , x_eco_revision_tbl     => l_eco_revision_tbl
          , x_change_line_tbl      => l_change_lines_tbl -- Eng Change
          , x_revised_item_tbl     => l_revised_item_tbl
          , x_rev_component_tbl    => l_rev_component_tbl
          , x_ref_designator_tbl   => l_ref_designator_tbl
          , x_sub_component_tbl    => l_sub_component_tbl
          , x_rev_operation_tbl    => l_rev_operation_tbl         --L1
          , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
          , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
         );
        COMMIT;
    ELSE
        RAISE EXC_EXP_SKIP_OBJECT;
    END IF;

EXCEPTION
WHEN EXC_EXP_SKIP_OBJECT THEN
    --
    -- Rollback any changes that may have been made to the DB
    --
    ROLLBACK;
    -- Set the return status
    l_return_status := FND_API.G_RET_STS_ERROR;
    -- Log any messages that have been logged with the additional error
    -- message into error handler
    Eco_Error_Handler.Log_Error(
        p_error_status         => l_return_status
      , p_mesg_token_tbl       => l_mesg_token_tbl
      , p_error_scope          => Error_Handler.G_SCOPE_RECORD
      , p_error_level          => Eco_Error_Handler.G_ECO_LEVEL
      , p_other_message        => 'ENG_PRP_CHG_ORDER_ERR'
      , p_other_status         => l_return_status
      , p_other_token_tbl      => l_token_tbl
      , x_eco_rec              => l_eco_rec
      , x_eco_revision_tbl     => l_eco_revision_tbl
      , x_change_line_tbl      => l_change_lines_tbl -- Eng Change
      , x_revised_item_tbl     => l_revised_item_tbl
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_rev_operation_tbl    => l_rev_operation_tbl         --L1
      , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
      , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
     );

    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => p_change_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_CHANGE
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
      , p_bo_entity_identifier      => 'ECO'--Eco_Error_Handler.G_ECO_LEVEL
     );

-- WHEN OTHERS THEN
-- LK: Do we need to handle this here ?
END Propagate_Change_Header;

FUNCTION Inventory_Status_Control_Level
RETURN NUMBER
IS
    CURSOR c_status_control_attribute IS
    SELECT control_level
      FROM MTL_ITEM_ATTRIBUTES
     WHERE ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';
BEGIN

   IF G_STATUS_CONTROL_LEVEL IS NULL
   THEN
       OPEN c_status_control_attribute;
       FETCH c_status_control_attribute INTO G_STATUS_CONTROL_LEVEL;
       CLOSE c_status_control_attribute;
   END IF;
   RETURN G_STATUS_CONTROL_LEVEL;

END Inventory_Status_Control_Level;


PROCEDURE Propagate_Revised_Item (
    p_revised_item_sequence_id IN NUMBER
  , p_change_id                IN NUMBER
  , p_change_notice            IN VARCHAR2
  , p_organization_code        IN VARCHAR2
  , p_organization_id          IN NUMBER
  , p_local_organization_code  IN VARCHAR2
  , p_local_organization_id    IN NUMBER
  , p_commit                   IN VARCHAR2
  , x_Return_Status            OUT NOCOPY VARCHAR2
) IS

    l_transfer_item_enable  NUMBER;
    l_error_logged          NUMBER;
    --l_attach_error_logged   NUMBER;
    l_sourcing_rules_exists NUMBER;
    --l_propagated_rev_items_tbl  Prop_Rev_Items_Tbl_Type;
    --l_prop_rev_items_count      NUMBER;
    l_propagate_revised_item    NUMBER;
    l_parent_revised_item_name  mtl_system_items_vl.concatenated_segments%TYPE;
    l_use_up_plan_name          mrp_bom_plan_name_lov_v.plan_name%TYPE;
    l_revised_item_number       mtl_system_items_vl.concatenated_segments%TYPE;
    l_use_up_item_name          mtl_system_items_vl.concatenated_segments%TYPE;
    l_revised_item_name         mtl_system_items_vl.concatenated_segments%TYPE;
    l_new_item_revision         mtl_item_revisions.revision%TYPE;
    l_new_struc_revision        VARCHAR2(3);
    l_current_struc_revision    VARCHAR2(3);
    l_from_end_item_name        mtl_system_items_vl.concatenated_segments%TYPE;
    l_from_end_item_alternate   VARCHAR2(10);
    l_from_end_item_revision    mtl_item_revisions.revision%TYPE;
    l_current_local_revision_id NUMBER;
    l_current_local_revision    VARCHAR2(3);
    l_current_lifecycle_seq     NUMBER;
    l_current_lifecycle_name    VARCHAR2(150);
    l_new_lifecycle_seq         NUMBER;
    l_new_lifecycle_name        VARCHAR2(150);
    l_new_revision_exists       NUMBER;
    l_status_master_controlled  NUMBER;
    l_sql_stmt                  VARCHAR2(2000);
    l_revised_item_count        NUMBER := 1;
    l_local_bill_sequence_id    NUMBER;
    l_rev_description           mtl_item_revisions.description%type;
    l_rev_label                 mtl_item_revisions.revision_label%type;  -- Fixed bug10255737, can update revision label correctly
    l_structure_exists_flag     NUMBER;
    l_rev_item_status_type      NUMBER;
    l_new_item_revision_exists  NUMBER;
    l_from_end_item_minor_rev   VARCHAR2(3);
    l_disable_revision          NUMBER;
    l_propagate_strc_changes    NUMBER;
    l_structure_type_name       VARCHAR2(80);
    l_local_line_rev_id       NUMBER;

    l_attach_return_status  VARCHAR2(1);
    l_Mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_bo_mesg_token_tbl     Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status         VARCHAR2(1);
    l_err_text              VARCHAR2(2000);
    l_Token_Tbl             Error_Handler.Token_Tbl_Type;
    l_msg_count             NUMBER;

    l_eco_rec               Eng_Eco_Pub.Eco_Rec_Type;
    l_change_lines_tbl      Eng_Eco_Pub.Change_Line_Tbl_Type;
    l_eco_revision_tbl      Eng_Eco_Pub.Eco_Revision_Tbl_Type;
    l_revised_item_tbl      Eng_Eco_Pub.Revised_Item_Tbl_Type;
    l_rev_component_tbl     Bom_Bo_Pub.Rev_Component_Tbl_Type;
    l_sub_component_tbl     Bom_Bo_Pub.Sub_Component_Tbl_Type;
    l_ref_designator_tbl    Bom_Bo_Pub.Ref_Designator_Tbl_Type;
    l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
    l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
    l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;
    l_revised_item_unexp_rec  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;

    CURSOR c_revised_items_data IS
    SELECT use_up_item_id
         , revised_item_id
         , enable_item_in_local_org
         , transfer_or_copy
         , transfer_or_copy_item
         , alternate_bom_designator
         , revised_item_sequence_id
      FROM eng_revised_items
     WHERE revised_item_sequence_id = p_revised_item_sequence_id;

    l_ris c_revised_items_data%ROWTYPE;

   -- The following cursor will return only one revised item
   -- Changes to design of handling component changes
   -- will have to be done otherwise
   CURSOR c_rev_items_all (cp_revised_item_sequence_id NUMBER)
   IS
   SELECT *
     FROM eng_revised_items
    WHERE (revised_item_sequence_id = cp_revised_item_sequence_id)
           /*OR parent_revised_item_seq_id = cp_revised_item_sequence_id)
      AND revised_item_sequence_id NOT IN
               (SELECT revised_item_sequence_id
                  FROM eng_revised_items
                 WHERE parent_revised_item_seq_id = cp_revised_item_sequence_id
                   AND (transfer_or_copy = 'L' OR transfer_or_copy = 'O')
                   AND 1 = l_status_master_controlled
                )
   ORDER BY parent_revised_item_seq_id DESC*/;

  -- Cursor to pick up Revised component records for the top organization for
  -- the given change notice which have the ACD_type of Disable and have been
  -- implemented from eng_revised_items table. These records are not present in
  -- bom_inventory_components table hence this extra cursor.

   CURSOR c_plm_rev_comps_disable (cp_revised_item_sequence_id NUMBER)
   IS
   SELECT *
   FROM   eng_revised_components erc
   WHERE  erc.change_notice = p_change_notice
   AND    erc.ACD_TYPE = 3
   AND    erc.revised_item_sequence_id = cp_revised_item_sequence_id
   AND    NOT EXISTS (SELECT 1 FROM eng_change_propagation_maps ecpm
                      WHERE ecpm.change_id = p_change_id
                      AND ecpm.local_organization_id = p_local_organization_id
                      AND ecpm.revised_line_type = Eng_Propagation_Log_Util.G_REV_LINE_CMP_CHG
                      AND ecpm.revised_line_id1 = erc.component_sequence_id
                      AND ecpm.entity_action_status IN (3,4))
   AND EXISTS (SELECT 1 FROM eng_revised_items eri
                WHERE eri.revised_item_sequence_id = erc.revised_item_sequence_id
                  AND eri.bill_sequence_id = erc.bill_sequence_id);


   -- Cursor to Pick all Revised Component Items for the Top Organization  for the
   -- given Change Notice

   CURSOR c_plm_rev_comps (cp_revised_item_sequence_id NUMBER)  IS
   SELECT *
   FROM   bom_components_b bcb
   WHERE  change_notice = p_change_notice
   AND    revised_item_sequence_id = cp_revised_item_sequence_id
   AND    NOT EXISTS (SELECT 1 FROM eng_change_propagation_maps ecpm
                      WHERE ecpm.change_id = p_change_id
                      AND ecpm.local_organization_id = p_local_organization_id
                      AND ecpm.revised_line_type = Eng_Propagation_Log_Util.G_REV_LINE_CMP_CHG
                      AND ecpm.revised_line_id1 = bcb.component_sequence_id
                      AND ecpm.entity_action_status IN (3,4))
   AND EXISTS (SELECT 1 FROM eng_revised_items eri
                WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
                  AND eri.bill_sequence_id = bcb.bill_sequence_id);

BEGIN
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Revised_Item.BEGIN');
    -- Step 1:
    -- Initialize
    l_propagate_revised_item := G_VAL_TRUE;
    l_transfer_item_enable := G_VAL_FALSE;
    l_sourcing_rules_exists := 2;
    -- Set Savepoint
    SAVEPOINT BEGIN_REV_ITEM_PROCESSING;
    -- Error Handling
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_error_logged := G_VAL_FALSE;
    l_attach_return_status := FND_API.G_RET_STS_SUCCESS;

    Error_Handler.Initialize;

    IF (l_ris.enable_item_in_local_org = 'Y')
    THEN
        l_transfer_item_enable := G_VAL_TRUE;
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Enable item in local org .. ' || l_transfer_item_enable);
    END IF;
    l_status_master_controlled := Inventory_Status_Control_Level;

    OPEN c_revised_items_data;
    FETCH c_revised_items_data INTO l_ris;

    -- Step 2:
    -- Preprocess Revised Item
    -- If Errors then RAISE EXC_EXP_SKIP_OBJECT
    Check_Revised_Item_Errors (
        p_change_notice          => p_change_notice
      , p_global_org_id          => p_organization_id
      , p_local_org_id           => p_local_organization_id
      , p_rev_item_seq_id        => p_revised_item_sequence_id
      , p_revised_item_id        => l_ris.revised_item_id
      , p_use_up_item_id         => l_ris.use_up_item_id
      , p_transfer_item_enable   => l_transfer_item_enable
      , p_transfer_or_copy       => l_ris.transfer_or_copy
      , p_transfer_or_copy_item  => l_ris.transfer_or_copy_item
      , p_status_master_controlled => l_status_master_controlled
      , x_error_logged           => l_error_logged
      , x_mesg_token_tbl         => l_mesg_token_tbl
      , x_propagate_strc_changes => l_propagate_strc_changes
      , x_sourcing_rules_exists  => l_sourcing_rules_exists
      , x_revised_item_name      => l_parent_revised_item_name
     );
    IF l_error_logged = G_VAL_TRUE
    THEN
        RAISE EXC_EXP_SKIP_OBJECT;
    END IF;

    -- Step 3:
    -- Populating the l_propagated_rev_items_tbl
    --l_prop_rev_items_count := l_prop_rev_items_count + 1;
    --l_propagated_rev_items_tbl(l_prop_rev_items_count) := p_revised_item_sequence_id;
    -- Step 4: Processing
    -- Now get all revised items for this revised item sequence id.
    -- This will be used only when the functionality of parent_revised_item_seq_id
    -- gets defined. Currently not been scoped.
    FOR ri in c_rev_items_all (p_revised_item_sequence_id)
    LOOP
        Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Start revised item processing p_revised_item_sequence_id'|| p_revised_item_sequence_id);
        IF (l_sourcing_rules_exists = 2
            OR (l_sourcing_rules_exists = 1 AND ri.parent_revised_item_seq_id IS NULL)
            OR (l_sourcing_rules_exists = 1 AND ri.parent_revised_item_seq_id IS NOT NULL AND ri.transfer_or_copy IS NOT NULL))
        THEN
            -- get the item name, use up item name and plan name
            SELECT concatenated_segments
              INTO l_revised_item_number
              FROM mtl_system_items_b_kfv
             WHERE inventory_item_id = ri.revised_item_id
               AND organization_id = p_local_organization_id;

            l_use_up_item_name := null;
            IF (ri.use_up_item_id IS NOT NULL)
            THEN
                SELECT concatenated_segments
                INTO   l_use_up_item_name
                FROM   mtl_system_items_b_kfv
                WHERE  inventory_item_id = ri.use_up_item_id
                AND    organization_id = p_local_organization_id;
            END IF;

            IF (ri.use_up_plan_name IS NOT NULL)
            THEN
                BEGIN
                    SELECT pl.plan_name
                    INTO   l_use_up_plan_name
                    FROM   mrp_bom_plan_name_lov_v pl
                    WHERE  pl.item_id = ri.use_up_item_id
                    AND    pl.organization_id = p_local_organization_id
                    AND    pl.plan_name = ri.use_up_plan_name;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_use_up_plan_name := NULL;
                END;
            ELSE
                l_use_up_plan_name := NULL;
            END IF;

            /* Get current and new item revisions of the item in the local org */
            BEGIN
                SELECT BOM_REVISIONS.get_item_revision_fn('ALL', 'ALL', p_local_organization_id,
                                                        ri.revised_item_id, SYSDATE) revision ,
                       BOM_REVISIONS.get_item_revision_id_fn('ALL', 'ALL', p_local_organization_id,
                                                        ri.revised_item_id, SYSDATE) revision_id
                INTO l_current_local_revision, l_current_local_revision_id
                FROM dual;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_current_local_revision := NULL;
            END;

            l_new_item_revision := ri.new_item_revision;

            IF (l_new_item_revision IS NOT NULL AND l_new_item_revision <> FND_API.G_MISS_CHAR)
            THEN
                BEGIN
                    select 1
                    into l_new_revision_exists
                    from mtl_item_revisions
                    where revision = l_new_item_revision
                    and inventory_item_id = ri.revised_item_id
                    and organization_id = p_local_organization_id;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_new_revision_exists := 0;
                END;

                IF ((l_new_revision_exists = 1 )
                    OR (l_current_local_revision IS NOT NULL AND
                        l_new_revision_exists = 0 AND
                        l_current_local_revision > l_new_item_revision))
                THEN
                    l_new_item_revision := NULL;
                END IF;

            ELSE
                l_new_item_revision := NULL;
            END IF;

            IF (FND_PROFILE.VALUE('ENG:ECO_REVISED_ITEM_REVISION') = '1') AND
                (l_new_item_revision IS NULL OR l_new_item_revision = FND_API.G_MISS_CHAR) AND
                ri.new_item_revision IS NOT NULL
            THEN
              l_token_tbl.delete;

              l_token_tbl(1).token_name  := 'REVISION';
              l_token_tbl(1).token_value := ri.new_item_revision;
              Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_NEW_REV_PROP_MISS'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl);

              RAISE EXC_EXP_SKIP_OBJECT;
            END IF;

            /* Get current and new item revisions of the structure in the local org */

            l_new_struc_revision := ri.new_structure_revision;
            l_current_struc_revision := NULL;


            IF (ri.CURRENT_STRUCTURE_REV_ID IS NOT NULL)
            THEN
                select bill_sequence_id
                into l_local_bill_sequence_id
                FROM BOM_BILL_OF_MATERIALS
                WHERE assembly_item_id = ri.revised_item_id
                AND   organization_id  = p_local_organization_id
                AND   nvl(alternate_bom_designator, 'PRIMARY') = nvl(ri.alternate_bom_designator, 'PRIMARY');

                l_current_struc_revision := NULL;
                /* not supported in 11.5.10
                BEGIN
                    select bsr.revision
                    into l_current_struc_revision
                    from should use minor revision table  bsr
                    where bsr.bill_sequence_id = l_local_bill_sequence_id
                    and bsr.object_revision_id = l_current_local_revision_id
                    and bsr.effective_date = (select max(effective_date)
                            from should use minor revision table
                            where structure_revision_id = bsr.structure_revision_id
                            and bsr.effective_date < sysdate);
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_current_struc_revision := NULL;
                END;*/
                IF (l_new_struc_revision IS NOT NULL AND l_new_struc_revision <> FND_API.G_MISS_CHAR)
                THEN
                    l_new_revision_exists := 0;
                    /* not supported in 11.5.10
                    BEGIN
                        select 1
                        into l_new_revision_exists
                        from should use minor revision table
                        where bill_sequence_id = l_local_bill_sequence_id
                        and object_revision_id = l_current_local_revision_id
                        and revision = l_new_struc_revision;

                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_new_revision_exists := 0;
                    END;*/

                    IF ((l_new_revision_exists = 1 )
                        OR (l_current_struc_revision IS NOT NULL AND l_new_revision_exists = 0
                            AND l_current_struc_revision > l_new_struc_revision))
                    THEN
                            l_new_struc_revision := NULL;
                    END IF;
                ELSE
                    l_new_struc_revision := NULL;
                END IF;
            END IF;

            /* get the from end item details */
            IF (ri.from_end_item_rev_id IS NOT NULL)
            THEN
                select msikfv.concatenated_segments, mir.revision
                into  l_from_end_item_name, l_from_end_item_revision
                from mtl_system_items_b_kfv msikfv, mtl_item_revisions mir
                where mir.revision_id = ri.from_end_item_rev_id
                and mir.inventory_item_id = msikfv.inventory_item_id
                and mir.organization_id = msikfv.organization_id;
            END IF;

            /* not supported in 11.5.10
            IF (ri.from_end_item_strc_rev_id IS NOT NULL)
            THEN
                select bsr.revision, bbm.alternate_bom_designator
                into l_from_end_item_minor_rev, l_from_end_item_alternate
                from should use minor revision table  bsr, bom_bill_of_materials bbm
                where bsr.structure_revision_id = ri.from_end_item_strc_rev_id
                and bsr.bill_sequence_id = bbm.bill_sequence_id;
            END IF;*/

            /* Get the current and new item lifecycle phases of the item in the local org */
            l_current_lifecycle_name := NULL;
            l_new_lifecycle_name := NULL;

            BEGIN
                -- Bug 3311072: Made the query dynamic
                -- Modified By LKASTURI
                l_sql_stmt := 'SELECT LP.DISPLAY_SEQUENCE, LP.NAME      '
                || 'FROM pa_ego_phases_v LP, MTL_System_items_vl msiv        '
                || 'WHERE  LP.PROJ_ELEMENT_ID = msiv.CURRENT_PHASE_ID   '
                || 'AND msiv.INVENTORY_ITEM_ID = :1                     '
                || 'AND msiv.ORGANIZATION_ID =  :2                      ';
                -- End Changes 3311072
                EXECUTE IMMEDIATE l_sql_stmt
                INTO l_current_lifecycle_seq , l_current_lifecycle_name
                USING ri.revised_item_id, p_local_organization_id;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_current_lifecycle_seq := NULL;
                l_current_lifecycle_name := NULL;
            END;

            IF (ri.transfer_or_copy IS NOT NULL and ri.transfer_or_copy <> 'C' AND l_status_master_controlled = 2)
            THEN
                IF (ri.new_lifecycle_state_id IS NOT NULL)
                THEN
                    -- Bug 3311072: Made the query dynamic
                    -- Modified By LKASTURI
                    l_sql_stmt := 'SELECT LP.DISPLAY_SEQUENCE, LP.NAME      '
                    || 'FROM pa_ego_phases_v LP                  '
                    || 'WHERE  LP.PROJ_ELEMENT_ID = :1                      ';
                    -- End Changes 3311072

                    EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_new_lifecycle_seq , l_new_lifecycle_name
                    USING ri.new_lifecycle_state_id;

                ELSE
                    l_new_lifecycle_seq := l_current_lifecycle_seq;
                    l_new_lifecycle_name := l_current_lifecycle_name;
                END IF;
            END IF;

            --Defaulting the structure type name (propagation)
            l_structure_type_name := NULL;
            BEGIN
              SELECT BSTV.structure_type_name
              INTO l_structure_type_name
              FROM bom_structures_b BSB,
                bom_structure_types_vl BSTV
              WHERE BSB.structure_type_id = BSTV.structure_type_id
                AND BSB.bill_sequence_id = ri.bill_sequence_id;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            END;


            l_revised_item_tbl(l_revised_item_count).eco_name := ri.change_notice;
            l_revised_item_tbl(l_revised_item_count).organization_code := p_local_organization_code;
            l_revised_item_tbl(l_revised_item_count).revised_item_name := l_revised_item_number;
            IF (l_new_item_revision IS NULL)
            THEN
                l_revised_item_tbl(l_revised_item_count).new_revised_item_revision := NULL;
            ELSE
                l_revised_item_tbl(l_revised_item_count).new_revised_item_revision := l_new_item_revision;
                SELECT DESCRIPTION, revision_label
                INTO   l_rev_description, l_rev_label
                FROM   mtl_item_revisions
                WHERE  inventory_item_id = ri.revised_item_id
                AND    organization_id = ri.organization_id
                AND    revision  = l_new_item_revision ;
                l_revised_item_tbl(l_revised_item_count).New_Revised_Item_Rev_Desc := l_rev_description;
                l_revised_item_tbl(l_revised_item_count).New_Revision_Label := l_rev_label;  -- Fixed bug10255737, can update revision label correctly
                l_revised_item_tbl(l_revised_item_count).Updated_Revised_Item_Revision := NULL;
            END IF;
            l_revised_item_tbl(l_revised_item_count).start_effective_date := ri.scheduled_date;
            l_revised_item_tbl(l_revised_item_count).New_Effective_Date := NULL;
            l_revised_item_tbl(l_revised_item_count).alternate_bom_code := ri.alternate_bom_designator;
            l_revised_item_tbl(l_revised_item_count).status_type := l_rev_item_status_type;
            l_revised_item_tbl(l_revised_item_count).mrp_active := ri.mrp_active;
            l_revised_item_tbl(l_revised_item_count).earliest_effective_date := ri.early_schedule_date;
            l_revised_item_tbl(l_revised_item_count).use_up_item_name := l_use_up_item_name;
            l_revised_item_tbl(l_revised_item_count).use_up_plan_name := l_use_up_plan_name;
            l_revised_item_tbl(l_revised_item_count).Requestor := NULL;
            l_revised_item_tbl(l_revised_item_count).disposition_type := ri.disposition_type;
            l_revised_item_tbl(l_revised_item_count).update_wip := ri.update_wip;
            l_revised_item_tbl(l_revised_item_count).cancel_comments := ri.cancel_comments;
            --l_revised_item_tbl(l_revised_item_count).cfm_routing_flag := ri.cfm_routing_flag;
            l_revised_item_tbl(l_revised_item_count).ctp_flag := ri.ctp_flag;
            l_revised_item_tbl(l_revised_item_count).return_status := NULL;
            l_revised_item_tbl(l_revised_item_count).change_description := ri.descriptive_text;
            l_revised_item_tbl(l_revised_item_count).Attribute_category := ri.Attribute_category;
            l_revised_item_tbl(l_revised_item_count).attribute1  := ri.attribute1;
            l_revised_item_tbl(l_revised_item_count).attribute2  := ri.attribute2;
            l_revised_item_tbl(l_revised_item_count).attribute3  := ri.attribute3;
            l_revised_item_tbl(l_revised_item_count).attribute4  := ri.attribute4;
            l_revised_item_tbl(l_revised_item_count).attribute5  := ri.attribute5;
            l_revised_item_tbl(l_revised_item_count).attribute6  := ri.attribute6;
            l_revised_item_tbl(l_revised_item_count).attribute7  := ri.attribute7;
            l_revised_item_tbl(l_revised_item_count).attribute8  := ri.attribute8;
            l_revised_item_tbl(l_revised_item_count).attribute9  := ri.attribute9;
            l_revised_item_tbl(l_revised_item_count).attribute10  := ri.attribute10;
            l_revised_item_tbl(l_revised_item_count).attribute11  := ri.attribute11;
            l_revised_item_tbl(l_revised_item_count).attribute12  := ri.attribute12;
            l_revised_item_tbl(l_revised_item_count).attribute13  := ri.attribute13;
            l_revised_item_tbl(l_revised_item_count).attribute14  := ri.attribute14;
            l_revised_item_tbl(l_revised_item_count).attribute15  := ri.attribute15;
            l_revised_item_tbl(l_revised_item_count).From_End_Item_Unit_Number := ri.From_End_Item_Unit_Number;
            l_revised_item_tbl(l_revised_item_count).New_From_End_Item_Unit_Number := NULL;
            l_revised_item_tbl(l_revised_item_count).Original_System_Reference := ri.Original_System_Reference;
            -- lkasturi: new columns in 11.5.10 changes

            l_revised_item_tbl(l_revised_item_count).Transfer_Or_Copy := ri.transfer_or_copy;
            l_revised_item_tbl(l_revised_item_count).Transfer_OR_Copy_Item := ri.transfer_or_copy_item;
            l_revised_item_tbl(l_revised_item_count).Transfer_OR_Copy_Bill := ri.transfer_or_copy_bill;
            l_revised_item_tbl(l_revised_item_count).Copy_To_Item := ri.Copy_To_Item;
            l_revised_item_tbl(l_revised_item_count).Copy_To_Item_Desc := ri.Copy_To_Item_Desc;

            l_revised_item_tbl(l_revised_item_count).parent_revised_item_name := l_parent_revised_item_name;
            l_revised_item_tbl(l_revised_item_count).parent_alternate_name := l_ris.alternate_bom_designator;

            l_revised_item_tbl(l_revised_item_count).selection_option := ri.selection_option;
            l_revised_item_tbl(l_revised_item_count).selection_date := ri.selection_date;
            l_revised_item_tbl(l_revised_item_count).selection_unit_number := ri.selection_unit_number;
            l_revised_item_tbl(l_revised_item_count).current_lifecycle_phase_name := l_current_lifecycle_name;
            l_revised_item_tbl(l_revised_item_count).new_lifecycle_phase_name := l_new_lifecycle_name;

            l_revised_item_tbl(l_revised_item_count).enable_item_in_local_org := ri.enable_item_in_local_org;
            l_revised_item_tbl(l_revised_item_count).new_structure_revision :=  l_new_struc_revision;
            l_revised_item_tbl(l_revised_item_count).current_structure_rev_name := l_current_struc_revision;

            l_revised_item_tbl(l_revised_item_count).plan_level := ri.plan_level;
            l_revised_item_tbl(l_revised_item_count).from_end_item_name := l_from_end_item_name;
            l_revised_item_tbl(l_revised_item_count).FROM_END_ITEM_ALTERNATE := l_from_end_item_alternate;
            l_revised_item_tbl(l_revised_item_count).from_end_item_revision := l_from_end_item_revision;
            l_revised_item_tbl(l_revised_item_count).from_end_item_strc_rev := l_from_end_item_minor_rev;

             -- lkasturi: new columns in 11.5.10    end changes
            l_revised_item_tbl(l_revised_item_count).transaction_type := 'CREATE';
            l_revised_item_tbl(l_revised_item_count).structure_type_name := l_structure_type_name;

            Eng_Eco_Pvt.Process_Rev_Item(
                p_validation_level        => FND_API.G_VALID_LEVEL_FULL
              , p_change_notice           => p_change_notice
              , p_organization_id         => p_local_organization_id
              , I                         => l_revised_item_count
              , p_revised_item_rec        => l_revised_item_tbl(l_revised_item_count)
              , p_rev_component_tbl       => l_rev_component_tbl
              , p_ref_designator_tbl      => l_ref_designator_tbl
              , p_sub_component_tbl       => l_sub_component_tbl
              , p_rev_operation_tbl       => l_rev_operation_tbl
              , p_rev_op_resource_tbl     => l_rev_op_resource_tbl
              , p_rev_sub_resource_tbl    => l_rev_sub_resource_tbl
              , x_revised_item_tbl        => l_revised_item_tbl
              , x_rev_component_tbl       => l_rev_component_tbl
              , x_ref_designator_tbl      => l_ref_designator_tbl
              , x_sub_component_tbl       => l_sub_component_tbl
              , x_rev_operation_tbl       => l_rev_operation_tbl
              , x_rev_op_resource_tbl     => l_rev_op_resource_tbl
              , x_rev_sub_resource_tbl    => l_rev_sub_resource_tbl
              , x_revised_item_unexp_rec  => l_revised_item_unexp_rec
              , x_Mesg_Token_Tbl          => l_bo_mesg_token_tbl -- Using another message token table as these are logged by BO itself
              , x_return_status           => l_return_status
              , x_disable_revision        => l_disable_revision
             );

            Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'After processing revised item through BO return status is '||l_return_status);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE EXC_EXP_SKIP_OBJECT;
            END IF;

            IF (l_sourcing_rules_exists = 2 AND l_propagate_strc_changes = G_VAL_TRUE)
            THEN
                FOR rcd in c_plm_rev_comps_disable(p_revised_item_sequence_id)
                LOOP
                    Propagate_Revised_Component (
                        p_component_sequence_id    => rcd.component_sequence_id
                      , p_revised_item_sequence_id => rcd.revised_item_sequence_id
                      , p_change_id                => p_change_id
                      , p_revised_item_rec         => l_revised_item_tbl(l_revised_item_count)
                      , p_revised_item_unexp_rec   => l_revised_item_unexp_rec
                      , p_local_organization_id    => p_local_organization_id
                      , x_Return_Status            => l_return_status
                     );
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                        l_propagate_revised_item := G_VAL_FALSE;
                    END IF;
                END LOOP;

                FOR rc in c_plm_rev_comps(p_revised_item_sequence_id)
                LOOP
                    Propagate_Revised_Component (
                        p_component_sequence_id    => rc.component_sequence_id
                      , p_revised_item_sequence_id => rc.revised_item_sequence_id
                      , p_change_id                => p_change_id
                      , p_revised_item_rec         => l_revised_item_tbl(l_revised_item_count)
                      , p_revised_item_unexp_rec   => l_revised_item_unexp_rec
                      , p_local_organization_id    => p_local_organization_id
                      , x_Return_Status            => l_return_status
                     );
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                        l_propagate_revised_item := G_VAL_FALSE;
                    END IF;
                END LOOP;
            END IF;

            -- Getting the revision id for the items attachment lines context.
            -- This is the revision id to which the revision specific lines would be added
            BEGIN
              select revision_id
              into l_local_line_rev_id
              from mtl_item_revisions
              where inventory_item_id = (select revised_item_id
                                         from eng_revised_items
                                         where revised_item_sequence_id = l_revised_item_unexp_rec.revised_item_sequence_id)
              and revised_item_sequence_id = l_revised_item_unexp_rec.revised_item_sequence_id;
            EXCEPTION
              WHEN OTHERS THEN
                --this will be called for item attachment changes with default revision
                l_local_line_rev_id := nvl(l_revised_item_unexp_rec.new_item_revision_id,
                                           l_revised_item_unexp_rec.current_item_revision_id);
            END;


            Validate_Attach_Lines(
                p_change_id                  => p_change_id
              , p_rev_item_sequence_id       => p_revised_item_sequence_id
              , p_global_organization_id     => p_organization_id
              , p_global_new_item_rev        => ri.new_item_revision
              , p_global_current_item_rev_id => ri.current_item_revision_id
              , p_local_organization_id      => p_local_organization_id
              , p_local_line_rev_id          => l_local_line_rev_id
              , p_revised_item_rec           => l_revised_item_tbl(l_revised_item_count)
              , p_revised_item_unexp_rec     => l_revised_item_unexp_rec
              , x_return_status              => l_attach_return_status
              , x_mesg_token_tbl             => l_mesg_token_tbl
             );

            IF l_attach_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                l_propagate_revised_item := G_VAL_FALSE;
            END IF;
            IF l_propagate_revised_item = G_VAL_TRUE
            THEN
                Propagate_Attach_Lines(
                    p_change_id                => p_change_id
                  , p_revised_item_sequence_id => p_revised_item_sequence_id
                  , p_revised_item_rec         => l_revised_item_tbl(l_revised_item_count)
                  , p_revised_item_unexp_rec   => l_revised_item_unexp_rec
                  , p_local_organization_id    => p_local_organization_id
                  , p_local_line_rev_id        => l_local_line_rev_id
                  , x_Return_Status            => l_attach_return_status
                  , x_mesg_token_tbl           => l_mesg_token_tbl
                 );
                IF l_attach_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    l_propagate_revised_item := G_VAL_FALSE;
                END IF;
            END IF;
            IF l_propagate_revised_item = G_VAL_FALSE
            THEN
                RAISE EXC_EXP_SKIP_OBJECT;
            END IF;

            l_revised_item_count := l_revised_item_count + 1;
        END IF;

    END LOOP;

    -- Commit the changes if the api hasnt exit so far
    IF (p_commit = FND_API.G_TRUE)
    THEN
        COMMIT;
    END IF;
    Eco_Error_Handler.Log_Error(
        p_error_status         => l_return_status
      , p_mesg_token_tbl       => l_mesg_token_tbl
      , p_error_scope          => Error_Handler.G_SCOPE_RECORD
      , p_error_level          => Eco_Error_Handler.G_RI_LEVEL
      , x_eco_rec              => l_eco_rec
      , x_eco_revision_tbl     => l_eco_revision_tbl
      , x_change_line_tbl      => l_change_lines_tbl -- Eng Change
      , x_revised_item_tbl     => l_revised_item_tbl
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_rev_operation_tbl    => l_rev_operation_tbl         --L1
      , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
      , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
     );
    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => p_change_id
      , p_revised_item_sequence_id  => p_revised_item_sequence_id
      , p_local_organization_id     => p_local_organization_id
      , p_local_revised_item_seq_id => l_revised_item_unexp_rec.revised_item_sequence_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_ITEM
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS
      , p_bo_entity_identifier      => 'RI'--Eco_Error_Handler.G_RI_LEVEL
     );
    CLOSE c_revised_items_data;

    x_return_status := l_return_status;

    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Revised_Item.END');
EXCEPTION
WHEN EXC_EXP_SKIP_OBJECT THEN
    IF c_revised_items_data%ISOPEN
    THEN
        CLOSE c_revised_items_data;
    End IF;

    -- Set the return status
    l_return_status := FND_API.G_RET_STS_ERROR;
    -- Log any messages that have been logged with the additional error
    -- message into error handler
    Eco_Error_Handler.Log_Error(
        p_error_status         => l_return_status
      , p_mesg_token_tbl       => l_mesg_token_tbl
      , p_error_scope          => Error_Handler.G_SCOPE_RECORD
      , p_error_level          => Eco_Error_Handler.G_RI_LEVEL
      , p_other_message        => 'ENG_PRP_REV_ITEM_ERR'
      , p_other_status         => l_return_status
      , p_other_token_tbl      => l_token_tbl
      , x_eco_rec              => l_eco_rec
      , x_eco_revision_tbl     => l_eco_revision_tbl
      , x_change_line_tbl      => l_change_lines_tbl -- Eng Change
      , x_revised_item_tbl     => l_revised_item_tbl
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_rev_operation_tbl    => l_rev_operation_tbl         --L1
      , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
      , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
     );
    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => p_change_id
      , p_revised_item_sequence_id  => p_revised_item_sequence_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_ITEM
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
      , p_bo_entity_identifier      => 'RI'--Eco_Error_Handler.G_RI_LEVEL
     );
    x_return_status := l_return_status;
    --
    -- Rollback any changes that may have been made to the DB
    --
    ROLLBACK TO BEGIN_REV_ITEM_PROCESSING;
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'Propagate_Revised_Item.END');
WHEN OTHERS THEN
    IF c_revised_items_data%ISOPEN
    THEN
        CLOSE c_revised_items_data;
    End IF;
    -- Set the return status
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_err_text := G_PKG_NAME || ' : (Revised Item Propagation) ' || substrb(SQLERRM,1,200);

    Error_Handler.Add_Error_Token(
        p_Message_Name   => NULL
      , p_Message_Text   => l_Err_Text
      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );
    -- Log any messages that have been logged with the additional error
    -- message into error handler
    Eco_Error_Handler.Log_Error(
        p_error_status         => l_return_status
      , p_mesg_token_tbl       => l_mesg_token_tbl
      , p_error_scope          => Error_Handler.G_SCOPE_RECORD
      , p_error_level          => Eco_Error_Handler.G_RI_LEVEL
      , p_other_message        => 'ENG_PRP_REV_ITEM_ERR'
      , p_other_status         => l_return_status
      , p_other_token_tbl      => l_token_tbl
      , x_eco_rec              => l_eco_rec
      , x_eco_revision_tbl     => l_eco_revision_tbl
      , x_change_line_tbl      => l_change_lines_tbl -- Eng Change
      , x_revised_item_tbl     => l_revised_item_tbl
      , x_rev_component_tbl    => l_rev_component_tbl
      , x_ref_designator_tbl   => l_ref_designator_tbl
      , x_sub_component_tbl    => l_sub_component_tbl
      , x_rev_operation_tbl    => l_rev_operation_tbl         --L1
      , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
      , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
     );

    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => p_change_id
      , p_revised_item_sequence_id  => p_revised_item_sequence_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_ITEM
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
      , p_bo_entity_identifier      => 'RI'--Eco_Error_Handler.G_RI_LEVEL
     );
    x_return_status := l_return_status;
    --
    -- Rollback any changes that may have been made to the DB
    --
    ROLLBACK TO BEGIN_REV_ITEM_PROCESSING;
END Propagate_Revised_Item;

-- ****************************************************************** --
--  API name    : Propagate_ECO_PLM                                   --
--  Type        : Private                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_api_version              NUMBER     Required      --
--                p_change_id                VARCHAR2   Required      --
--                p_organization_id          NUMBER     Required      --
--                p_org_hierarchy_id         VARCHAR2                 --
--                p_local_organization_id    NUMBER := NULL           --
--                p_calling_api NUMBER := NULL           --
--       OUT    : x_return_status            VARCHAR2(1)              --
--                x_error_buf                VARCHAR2(30)             --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
--                if org hierarchy id is -1 then the list of orgs     --
--                associated to the change are picked for propagation --
--                if p_org_hierarchy_id is null, check that the value --
--                local_organization_id has been specified            --
--                Validate that the local organization id either      --
--                belongs to the hierarchy or to the list of local    --
--                 orgs of thesource change order                     --
--                 p_calling API is TTM then the change header        --
--                 relation is checked first 'TRANSFERRED_TO'        --
-- ****************************************************************** --

PROCEDURE Propagate_ECO_PLM (
    p_api_version              IN NUMBER           := 1.0
  , x_error_buf                OUT NOCOPY VARCHAR2
  , x_return_status            OUT NOCOPY VARCHAR2
  , p_change_notice            IN VARCHAR2
  , p_organization_id          IN NUMBER
  , p_org_hierarchy_name       IN VARCHAR2
  , p_local_organization_id    IN NUMBER           := NULL
  , p_calling_api              IN VARCHAR2         := NULL
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'PROPAGATE_ECO_PLM';
    l_api_version     CONSTANT NUMBER := 1.0;

    l_org_code        mtl_parameters.organization_code%TYPE;
    l_global_org_code mtl_parameters.organization_code%TYPE;
    l_global_change_id NUMBER;
    l_local_change_id NUMBER;
    -- this corresponds to the processing status that will have to be updated to the change
    l_top_entity_process_status NUMBER;

    l_Mesg_Token_Tbl   Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status    VARCHAR2(1);

-- Bug# 9498305
   l_propagated_to_chg_id NUMBER;
   l_ext_id_nextval     NUMBER;
-- Bug# 9498305 End

-- Bug# 9498305
	 CURSOR c_extention_id_all (v_change_id NUMBER)
	 IS
	 SELECT EXTENSION_ID
	 FROM ENG_CHANGES_EXT_B
	 WHERE CHANGE_ID = v_change_id;
-- Bug# 9498305 End

    CURSOR c_fetch_org_code(cp_organization_id NUMBER) IS
    SELECT organization_code
      FROM mtl_parameters
     WHERE organization_id = cp_organization_id;

    CURSOR c_change_header IS
    SELECT change_id
      FROM eng_engineering_changes
     WHERE change_notice = p_change_notice
       AND organization_id = p_organization_id;
---added Bug no 4327321  only revised items will get propagate.No transfer and copy items
   CURSOR c_prp_revised_item IS
   SELECT eri.revised_item_sequence_id,
   eri.bill_sequence_id,eri.revised_item_id
     FROM eng_revised_items eri
    WHERE eri.change_id = l_global_change_id
    AND  transfer_or_copy is NULL
      AND NOT EXISTS
         (SELECT 1
            FROM eng_change_propagation_maps ecpm
           WHERE ecpm.change_id = eri.change_id
             AND ecpm.local_organization_id = p_local_organization_id
             AND ecpm.revised_item_sequence_id = eri.revised_item_sequence_id
             AND ecpm.entity_name = Eng_Propagation_Log_Util.G_ENTITY_REVISED_ITEM
             AND ecpm.entity_action_status IN (Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS, Eng_Propagation_Log_Util.G_PRP_PRC_STS_EXCL_TTM));

		l_bill_count NUMBER;
BEGIN
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'PROPAGATE_ECO_PLM.Begin For Organization: '|| l_org_code);
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (  l_api_version
                                        , p_api_version
                                        , l_api_name
                                        , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize return status
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    Error_Handler.Initialize;
    ENG_GLOBALS.G_ENG_LAUNCH_IMPORT := 2 ;--Indicates call is from propagation
    -- Removed check for local orgs same master org when propagating change orders
    -- as if required this can be added to the Business Object ---- 6/15/2005

    --
    -- Fetch Organization Code for further processing
    OPEN c_fetch_org_code(p_organization_id);
    FETCH c_fetch_org_code INTO l_global_org_code;
    CLOSE c_fetch_org_code;

    OPEN c_fetch_org_code(p_local_organization_id);
    FETCH c_fetch_org_code INTO l_org_code;
    CLOSE c_fetch_org_code;
    --
    -- Fetch change_id for further processing
    OPEN c_change_header;
    FETCH c_change_header INTO l_global_change_id;
    CLOSE c_change_header;

    IF p_calling_API IS NULL
    THEN
        -- Progress with call to propagate the change header when
        -- calling api is not TTM
        -- Currently this is the only case possible

        Propagate_Change_Header(
            p_change_id               => l_global_change_id
          , p_change_notice           => p_change_notice
          , p_organization_code       => l_global_org_code
          , p_organization_id         => p_organization_id
          , p_org_hierarchy_name      => p_org_hierarchy_name
          , p_local_organization_code => l_org_code
          , p_local_organization_id   => p_local_organization_id
          , x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
          , x_Return_Status           => l_return_status
         );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
            l_top_entity_process_status := Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR;
            RAISE EXC_EXP_SKIP_OBJECT;
        END IF;
    END IF; -- **** END of p_calling_API <> 'TTM' **** --

        -- p_calling_API = 'TTM' and even after normal processing check if the ecdo already exists
        -- if the calling api is TTM then check if the change has already
        -- been propagated , only then continue processing
        -- if local change does not already exist , then the organization
        -- need not be propagated.
        -- calling api will be TTM only when the automatic change prpagation
        -- request has been triggered off by the BOM COPY process from
        -- Product Workbench
        Propagated_Local_Change(
            p_change_id             => l_global_change_id
          , p_local_organization_id => p_local_organization_id
          , x_local_change_id       => l_local_change_id
         );
        IF (l_local_change_id IS NULL)
        THEN
            Eng_Propagation_Log_Util.Debug_Log(G_LOG_PROC, 'PROPAGATE_ECO_PLM.End For Organization: '|| l_org_code);
            RETURN;
        END IF;
    Eng_Propagation_Log_Util.Debug_Log(G_LOG_STMT, 'Value x_local_change_id: '|| l_local_change_id);
    Initialize_Business_object(
        p_debug           => 'N'
      , p_debug_filename  => ''
      , p_output_dir      => ''
      , p_bo_identifier   => 'ECO'
      , p_organization_id => p_local_organization_id
      , x_return_status   => l_return_status
     );
    FOR eri IN c_prp_revised_item
    LOOP
    		select count(*) into l_bill_count
		    from bom_structures_b
		    where bill_sequence_id=eri.bill_sequence_id
		    AND assembly_item_id=eri.revised_item_id
		    AND organization_id=p_organization_id;

	      /*Bug:20617988 If the bill for the revised item does not exist,
	      then it means that it was created in change order. Need to create a bill for the child item.
	      In ENG_Revised_Item_Util.Insert_Row, this value will be considered as condition whether to set Eng_Default_Revised_Item.G_CREATE_ALTERNATE to true
	      */
	      IF l_bill_count>0 then
			    BOM_GLOBALS.Set_Caller_Type('PROPAGATE');
	      END IF;
        Propagate_Revised_Item(
            p_revised_item_sequence_id => eri.revised_item_sequence_id
          , p_change_id                => l_global_change_id
          , p_change_notice            => p_change_notice
          , p_organization_code        => l_global_org_code
          , p_organization_id          => p_organization_id
          , p_local_organization_code  => l_org_code
          , p_local_organization_id    => p_local_organization_id
          , p_commit                   => FND_API.G_TRUE
          , x_Return_Status            => l_return_status
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
            l_top_entity_process_status := Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR;
        END IF;
    END LOOP;
    Reset_Business_Object;
    IF l_top_entity_process_status = Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
    THEN
        RAISE EXC_EXP_SKIP_OBJECT;
    END IF;

      -- Bug# 9498305
                SELECT object_to_id1
                INTO l_propagated_to_chg_id
                FROM eng_change_obj_relationships
                WHERE relationship_code = 'PROPAGATED_TO'
                AND object_to_name ='ENG_CHANGE'
                AND change_id = l_global_change_id
                AND object_to_id2 = p_organization_id
                AND object_to_id3 = p_local_organization_id;

                FOR ri in c_extention_id_all (l_global_change_id)
                LOOP

                  SELECT EGO_EXTFWK_S.NEXTVAL
                  INTO l_ext_id_nextval
                  FROM DUAL;

                  INSERT INTO ENG_CHANGES_EXT_B (
                  	EXTENSION_ID      ,
                  	CHANGE_ID         ,
                  	CHANGE_TYPE_ID    ,
                  	ATTR_GROUP_ID     ,
                  	CREATED_BY        ,
                  	CREATION_DATE     ,
                  	LAST_UPDATED_BY   ,
                  	LAST_UPDATE_DATE  ,
                  	LAST_UPDATE_LOGIN ,
                  	C_EXT_ATTR1       ,
                  	C_EXT_ATTR2       ,
                  	C_EXT_ATTR3       ,
                  	C_EXT_ATTR4       ,
                  	C_EXT_ATTR5       ,
                  	C_EXT_ATTR6       ,
                  	C_EXT_ATTR7       ,
                  	C_EXT_ATTR8       ,
                  	C_EXT_ATTR9       ,
                  	C_EXT_ATTR10      ,
                  	C_EXT_ATTR11      ,
                  	C_EXT_ATTR12      ,
                  	C_EXT_ATTR13      ,
                  	C_EXT_ATTR14      ,
                  	C_EXT_ATTR15      ,
                  	C_EXT_ATTR16      ,
                  	C_EXT_ATTR17      ,
                  	C_EXT_ATTR18      ,
                  	C_EXT_ATTR19      ,
                  	C_EXT_ATTR20      ,
                  	N_EXT_ATTR1       ,
                  	N_EXT_ATTR2       ,
                  	N_EXT_ATTR3       ,
                  	N_EXT_ATTR4       ,
                  	N_EXT_ATTR5       ,
                  	N_EXT_ATTR6       ,
                  	N_EXT_ATTR7       ,
                  	N_EXT_ATTR8       ,
                  	N_EXT_ATTR9       ,
                  	N_EXT_ATTR10      ,
                  	D_EXT_ATTR1       ,
                  	D_EXT_ATTR2       ,
                  	D_EXT_ATTR3       ,
                  	D_EXT_ATTR4       ,
                  	D_EXT_ATTR5       ,
                  	C_EXT_ATTR21      ,
                  	C_EXT_ATTR22      ,
                  	C_EXT_ATTR23      ,
                  	C_EXT_ATTR24      ,
                  	C_EXT_ATTR25      ,
                  	C_EXT_ATTR26      ,
                  	C_EXT_ATTR27      ,
                  	C_EXT_ATTR28      ,
                  	C_EXT_ATTR29      ,
                  	C_EXT_ATTR30      ,
                  	C_EXT_ATTR31      ,
                  	C_EXT_ATTR32      ,
                  	C_EXT_ATTR33      ,
                  	C_EXT_ATTR34      ,
                  	C_EXT_ATTR35      ,
                  	C_EXT_ATTR36      ,
                  	C_EXT_ATTR37      ,
                  	C_EXT_ATTR38      ,
                  	C_EXT_ATTR39      ,
                  	C_EXT_ATTR40      ,
                  	N_EXT_ATTR11      ,
                  	N_EXT_ATTR12      ,
                  	N_EXT_ATTR13      ,
                  	N_EXT_ATTR14      ,
                  	N_EXT_ATTR15      ,
                  	N_EXT_ATTR16      ,
                  	N_EXT_ATTR17      ,
                  	N_EXT_ATTR18      ,
                  	N_EXT_ATTR19      ,
                  	N_EXT_ATTR20      ,
                  	UOM_EXT_ATTR1     ,
                  	UOM_EXT_ATTR2     ,
                  	UOM_EXT_ATTR3     ,
                  	UOM_EXT_ATTR4     ,
                  	UOM_EXT_ATTR5     ,
                  	UOM_EXT_ATTR6     ,
                  	UOM_EXT_ATTR7     ,
                  	UOM_EXT_ATTR8     ,
                  	UOM_EXT_ATTR9     ,
                  	UOM_EXT_ATTR10    ,
                  	UOM_EXT_ATTR11    ,
                  	UOM_EXT_ATTR12    ,
                  	UOM_EXT_ATTR13    ,
                  	UOM_EXT_ATTR14    ,
                  	UOM_EXT_ATTR15    ,
                  	UOM_EXT_ATTR16    ,
                  	UOM_EXT_ATTR17    ,
                  	UOM_EXT_ATTR18    ,
                  	UOM_EXT_ATTR19    ,
                  	UOM_EXT_ATTR20    ,
                  	D_EXT_ATTR6       ,
                  	D_EXT_ATTR7       ,
                  	D_EXT_ATTR8       ,
                  	D_EXT_ATTR9       ,
                  	D_EXT_ATTR10
                  ) SELECT
                  		l_ext_id_nextval  ,
                  		l_propagated_to_chg_id   ,
                  		CHANGE_TYPE_ID    ,
                  		ATTR_GROUP_ID     ,
                  		Eng_Globals.Get_User_Id  ,
                  		sysdate           ,
                  		Eng_Globals.Get_User_Id  ,
                  		sysdate           ,
                  		Eng_Globals.Get_Login_id ,
                  		C_EXT_ATTR1       ,
                  		C_EXT_ATTR2       ,
                  		C_EXT_ATTR3       ,
                  		C_EXT_ATTR4       ,
                  		C_EXT_ATTR5       ,
                  		C_EXT_ATTR6       ,
                  		C_EXT_ATTR7       ,
                  		C_EXT_ATTR8       ,
                  		C_EXT_ATTR9       ,
                  		C_EXT_ATTR10      ,
                  		C_EXT_ATTR11      ,
                  		C_EXT_ATTR12      ,
                  		C_EXT_ATTR13      ,
                  		C_EXT_ATTR14      ,
                  		C_EXT_ATTR15      ,
                  		C_EXT_ATTR16      ,
                  		C_EXT_ATTR17      ,
                  		C_EXT_ATTR18      ,
                  		C_EXT_ATTR19      ,
                  		C_EXT_ATTR20      ,
                  		N_EXT_ATTR1       ,
                  		N_EXT_ATTR2       ,
                  		N_EXT_ATTR3       ,
                  		N_EXT_ATTR4       ,
                  		N_EXT_ATTR5       ,
                  		N_EXT_ATTR6       ,
                  		N_EXT_ATTR7       ,
                  		N_EXT_ATTR8       ,
                  		N_EXT_ATTR9       ,
                  		N_EXT_ATTR10      ,
                  		D_EXT_ATTR1       ,
                  		D_EXT_ATTR2       ,
                  		D_EXT_ATTR3       ,
                  		D_EXT_ATTR4       ,
                  		D_EXT_ATTR5       ,
                  		C_EXT_ATTR21      ,
                  		C_EXT_ATTR22      ,
                  		C_EXT_ATTR23      ,
                  		C_EXT_ATTR24      ,
                  		C_EXT_ATTR25      ,
                  		C_EXT_ATTR26      ,
                  		C_EXT_ATTR27      ,
                  		C_EXT_ATTR28      ,
                  		C_EXT_ATTR29      ,
                  		C_EXT_ATTR30      ,
                  		C_EXT_ATTR31      ,
                  		C_EXT_ATTR32      ,
                  		C_EXT_ATTR33      ,
                  		C_EXT_ATTR34      ,
                  		C_EXT_ATTR35      ,
                  		C_EXT_ATTR36      ,
                  		C_EXT_ATTR37      ,
                  		C_EXT_ATTR38      ,
                  		C_EXT_ATTR39      ,
                  		C_EXT_ATTR40      ,
                  		N_EXT_ATTR11      ,
                  		N_EXT_ATTR12      ,
                  		N_EXT_ATTR13      ,
                  		N_EXT_ATTR14      ,
                  		N_EXT_ATTR15      ,
                  		N_EXT_ATTR16      ,
                  		N_EXT_ATTR17      ,
                  		N_EXT_ATTR18      ,
                  		N_EXT_ATTR19      ,
                  		N_EXT_ATTR20      ,
                  		UOM_EXT_ATTR1     ,
                  		UOM_EXT_ATTR2     ,
                  		UOM_EXT_ATTR3     ,
                  		UOM_EXT_ATTR4     ,
                  		UOM_EXT_ATTR5     ,
                  		UOM_EXT_ATTR6     ,
                  		UOM_EXT_ATTR7     ,
                  		UOM_EXT_ATTR8     ,
                  		UOM_EXT_ATTR9     ,
                  		UOM_EXT_ATTR10    ,
                  		UOM_EXT_ATTR11    ,
                  		UOM_EXT_ATTR12    ,
                  		UOM_EXT_ATTR13    ,
                  		UOM_EXT_ATTR14    ,
                  		UOM_EXT_ATTR15    ,
                  		UOM_EXT_ATTR16    ,
                  		UOM_EXT_ATTR17    ,
                  		UOM_EXT_ATTR18    ,
                  		UOM_EXT_ATTR19    ,
                  		UOM_EXT_ATTR20    ,
                  		D_EXT_ATTR6       ,
                  		D_EXT_ATTR7       ,
                  		D_EXT_ATTR8       ,
                  		D_EXT_ATTR9       ,
                  		D_EXT_ATTR10
                    FROM ENG_CHANGES_EXT_B
                    WHERE CHANGE_ID = l_global_change_id
                                 AND EXTENSION_ID = ri.EXTENSION_ID;

                  INSERT INTO ENG_CHANGES_EXT_TL (
                  	EXTENSION_ID         ,
                  	CHANGE_ID            ,
                  	CHANGE_TYPE_ID       ,
                  	ATTR_GROUP_ID        ,
                  	SOURCE_LANG          ,
                  	LANGUAGE             ,
                  	LAST_UPDATE_DATE     ,
                  	LAST_UPDATED_BY      ,
                  	LAST_UPDATE_LOGIN    ,
                  	CREATED_BY           ,
                  	CREATION_DATE        ,
                  	TL_EXT_ATTR1         ,
                  	TL_EXT_ATTR2         ,
                  	TL_EXT_ATTR3         ,
                  	TL_EXT_ATTR4         ,
                  	TL_EXT_ATTR5         ,
                  	TL_EXT_ATTR6         ,
                  	TL_EXT_ATTR7         ,
                  	TL_EXT_ATTR8         ,
                  	TL_EXT_ATTR9         ,
                  	TL_EXT_ATTR10        ,
                  	TL_EXT_ATTR11        ,
                  	TL_EXT_ATTR12        ,
                  	TL_EXT_ATTR13        ,
                  	TL_EXT_ATTR14        ,
                  	TL_EXT_ATTR15        ,
                  	TL_EXT_ATTR16        ,
                  	TL_EXT_ATTR17        ,
                  	TL_EXT_ATTR18        ,
                  	TL_EXT_ATTR19        ,
                  	TL_EXT_ATTR20        ,
                  	TL_EXT_ATTR21        ,
                  	TL_EXT_ATTR22        ,
                  	TL_EXT_ATTR23        ,
                  	TL_EXT_ATTR24        ,
                  	TL_EXT_ATTR25        ,
                  	TL_EXT_ATTR26        ,
                  	TL_EXT_ATTR27        ,
                  	TL_EXT_ATTR28        ,
                  	TL_EXT_ATTR29        ,
                  	TL_EXT_ATTR30        ,
                  	TL_EXT_ATTR31        ,
                  	TL_EXT_ATTR32        ,
                  	TL_EXT_ATTR33        ,
                  	TL_EXT_ATTR34        ,
                  	TL_EXT_ATTR35        ,
                  	TL_EXT_ATTR36        ,
                  	TL_EXT_ATTR37        ,
                  	TL_EXT_ATTR38        ,
                  	TL_EXT_ATTR39        ,
                  	TL_EXT_ATTR40
                  ) SELECT
                  		l_ext_id_nextval     ,
                  		l_propagated_to_chg_id       ,
                  		CHANGE_TYPE_ID       ,
                  		ATTR_GROUP_ID        ,
                  		SOURCE_LANG          ,
                  		LANGUAGE             ,
                  		sysdate              ,
                  		Eng_Globals.Get_User_Id      ,
                  		Eng_Globals.Get_Login_id     ,
                  		Eng_Globals.Get_User_Id      ,
                  		sysdate              ,
                  		TL_EXT_ATTR1         ,
                  		TL_EXT_ATTR2         ,
                  		TL_EXT_ATTR3         ,
                  		TL_EXT_ATTR4         ,
                  		TL_EXT_ATTR5         ,
                  		TL_EXT_ATTR6         ,
                  		TL_EXT_ATTR7         ,
                  		TL_EXT_ATTR8         ,
                  		TL_EXT_ATTR9         ,
                  		TL_EXT_ATTR10        ,
                  		TL_EXT_ATTR11        ,
                  		TL_EXT_ATTR12        ,
                  		TL_EXT_ATTR13        ,
                  		TL_EXT_ATTR14        ,
                  		TL_EXT_ATTR15        ,
                  		TL_EXT_ATTR16        ,
                  		TL_EXT_ATTR17        ,
                  		TL_EXT_ATTR18        ,
                  		TL_EXT_ATTR19        ,
                  		TL_EXT_ATTR20        ,
                  		TL_EXT_ATTR21        ,
                  		TL_EXT_ATTR22        ,
                  		TL_EXT_ATTR23        ,
                  		TL_EXT_ATTR24        ,
                  		TL_EXT_ATTR25        ,
                  		TL_EXT_ATTR26        ,
                  		TL_EXT_ATTR27        ,
                  		TL_EXT_ATTR28        ,
                  		TL_EXT_ATTR29        ,
                  		TL_EXT_ATTR30        ,
                  		TL_EXT_ATTR31        ,
                  		TL_EXT_ATTR32        ,
                  		TL_EXT_ATTR33        ,
                  		TL_EXT_ATTR34        ,
                  		TL_EXT_ATTR35        ,
                  		TL_EXT_ATTR36        ,
                  		TL_EXT_ATTR37        ,
                  		TL_EXT_ATTR38        ,
                  		TL_EXT_ATTR39        ,
                  		TL_EXT_ATTR40
                    FROM ENG_CHANGES_EXT_TL
                    WHERE CHANGE_ID = l_global_change_id
                                 AND EXTENSION_ID = ri.EXTENSION_ID;
                END LOOP;
      -- Bug# 9498305 End


    Init_Local_Change_Lifecycle (
        p_local_change_id    => l_local_change_id
      , p_organization_id    => p_organization_id
      , p_org_hierarchy_name => p_org_hierarchy_name
      , x_return_status      => l_return_status
     );
    -- Not doing anythig for processing the Init_Local_Change_Lifecycle return status as
    -- the changes to the change order in local org can go through .user can then
    -- manually init the lifecycle if required
    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => l_global_change_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_CHANGE
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_SUCCESS
      , p_bo_entity_identifier      => 'ECO'--Eco_Error_Handler.G_ECO_LEVEL
     );
EXCEPTION
WHEN EXC_EXP_SKIP_OBJECT THEN
    Eng_Propagation_Log_Util.add_entity_map(
        p_change_id                 => l_global_change_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_CHANGE
      , p_entity_action_status      => Eng_Propagation_Log_Util.G_PRP_PRC_STS_ERROR
      , p_bo_entity_identifier      => 'ECO'--Eco_Error_Handler.G_ECO_LEVEL
     );
    ROLLBACK;
WHEN OTHERS THEN
    ROLLBACK;
END Propagate_ECO_PLM;

PROCEDURE Get_Local_Orgs_List (
    p_change_notice         IN VARCHAR2
  , p_organization_id       IN NUMBER
  , p_hierarchy_name        IN VARCHAR2
  , p_local_organization_id IN NUMBER
  , x_organizations_list    OUT NOCOPY INV_OrgHierarchy_PVT.OrgID_tbl_type
  , x_return_status         OUT NOCOPY VARCHAR2
) IS

  CURSOR c_local_orgs IS
  SELECT eclo.local_organization_id
    FROM eng_engineering_changes eec
       , eng_change_local_orgs eclo
       , hr_all_organization_units  org
       , hr_organization_information hoi
       , mtl_parameters mp
   WHERE eec.change_notice = p_change_notice
     AND eec.organization_id = p_organization_id
     AND eclo.change_id = eec.change_id
     AND org.organization_id  = hoi.organization_id
     AND org.organization_id  = mp.organization_id
     AND hoi.org_information1 = 'INV'
     AND hoi.org_information2 = 'Y' -- inventory enabled flag
     AND hoi.org_information_context = 'CLASS'
     -- expiration check
     AND org.organization_id  =  eclo.local_organization_id
     AND (org.date_to >= SYSDATE OR org.date_to IS NULL)
     -- inv security access check
     AND (NOT EXISTS(SELECT 1 FROM ORG_ACCESS  acc
                      WHERE acc.organization_id =  eclo.local_organization_id )
          OR  EXISTS(SELECT 1 FROM ORG_ACCESS  acc
                      WHERE acc.organization_id =  eclo.local_organization_id
                        AND acc.responsibility_id = TO_NUMBER(fnd_profile.value('RESP_ID'))));
  l_org_Idx NUMBER;
  l_orgs_Cnt NUMBER;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_local_organization_id IS NOT NULL
    THEN
        x_organizations_list(1) := p_organization_id;
        x_organizations_list(2) := p_local_organization_id;
    ELSIF p_hierarchy_name IS NOT NULL
    THEN
        -- Fetch the list of organizations from hierarchy if specified
        Inv_OrgHierarchy_Pvt.Org_Hierarchy_List(p_hierarchy_name, p_organization_id, x_organizations_list);
    ELSE
        -- from eng_change_local_organizations for TTM
        -- The following APIs fetch the list of all organizations for which the user has access
        -- by responsibility and by business group.
        l_org_Idx := 1;
        x_organizations_list(l_org_Idx) := p_organization_id;
        x_organizations_list(l_org_Idx+1) := 209;
        FOR c_org IN c_local_orgs
        LOOP
            l_org_Idx := l_org_Idx+1;
            x_organizations_list(l_org_Idx) := c_org.local_organization_id;
        END LOOP;
    END IF;

    l_orgs_Cnt := x_organizations_list.COUNT;
    IF (l_orgs_Cnt IN  (0, 1))
    THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Organization exists for propagating changes');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
END Get_Local_Orgs_List;

-- ****************************************************************** --
--  API name    : Propagate_ECO                                       --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_change_notice            VARCHAR2   Required      --
--                p_org_hierarchy_name       varchar2                 --
--                p_org_hierarchy_level      VARCHAR2                 --
--                p_local_organization_id    NUMBER := NULL           --
--                p_calling_api              NUMBER := NULL           --
--       OUT    : retcode                    VARCHAR2(1)              --
--                error_buf                  VARCHAR2(30)             --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
--                if org hierarchy id is -1 then the list of orgs     --
--                associated to the change are picked for propagation --
--                if p_org_hierarchy_id is null, check that the value --
--                local_organization_id has been specified            --
--                Validate that the local organization id either      --
--                belongs to the hierarchy or to the list of local    --
--                 orgs of thesource change order                     --
--                 p_calling API is TTM then the change header        --
--                 relation is checked first 'TRANSFERRED_TO'         --
-- ****************************************************************** --
PROCEDURE PROPAGATE_ECO (
   errbuf                 OUT NOCOPY    VARCHAR2
 , retcode                OUT NOCOPY    VARCHAR2
 , p_change_notice        IN            VARCHAR2
 , p_org_hierarchy_name   IN            VARCHAR2
 , p_org_hierarchy_level  IN            VARCHAR2
 , p_local_organization_id IN           NUMBER := NULL
 , p_calling_API           IN           VARCHAR2 := NULL
) IS

    l_plm_or_erp_flag               VARCHAR2(3);
    l_org_hierarchy_level_id        NUMBER;
    l_org_code_list                 INV_OrgHierarchy_PVT.OrgID_tbl_type;

    CURSOR c_organization_details IS
    SELECT MP.organization_id
    FROM HR_ORGANIZATION_UNITS HOU
    , HR_ORGANIZATION_INFORMATION HOI1
    , MTL_PARAMETERS MP
    WHERE HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND HOI1.ORG_INFORMATION1 = 'INV'
    AND HOI1.ORG_INFORMATION2 = 'Y'
    AND HOU.NAME = p_org_hierarchy_level;
      /*FROM org_organization_definitions
     WHERE organization_name = p_org_hierarchy_level;*/

    l_return_status VARCHAR2(1);
BEGIN
    -- Fetch the global organization id
    OPEN c_organization_details;
    FETCH c_organization_details INTO l_org_hierarchy_level_id;
    CLOSE c_organization_details;
    -- Fetch the value of plm_or_erp_change
    -- The processing will be routed differently for PLM ECOs and ERP ECOs
    l_plm_or_erp_flag := Eng_Globals.Get_PLM_Or_ERP_Change(
                              p_change_notice  => p_change_notice
                            , p_organization_id => l_org_hierarchy_level_id);
    -- Begin Processing for PLM
    IF (l_plm_or_erp_flag = 'PLM')
    THEN
         --   Bug : 5326333 ECO Propagation was failing because validations not required from PLM flow are happening from BOM API.
         --   If we set the following flag, then bom validations will be skipped for PLM flow.
        Bom_Globals.Set_Validate_For_Plm('Y');
        -- Set OrganizationId as global variable
        g_global_org_id := l_org_hierarchy_level_id;
        -- This following validation needs to be done for all orgs in the list
        -- Eng_Validate.Organization_Id(p_organization_id => l_org_id);
        Get_Local_Orgs_List(
            p_change_notice         => p_change_notice
          , p_organization_id       => l_org_hierarchy_level_id
          , p_hierarchy_name        => p_org_hierarchy_name
          , p_local_organization_id => p_local_organization_id
          , x_organizations_list    => l_org_code_list
          , x_return_status         => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            RETURN;
        END IF;

        FOR l_org_count IN 2..l_org_code_list.LAST
        LOOP
            Eng_Propagation_Log_Util.Initialize;
            Propagate_ECO_PLM(
                x_error_buf             => errbuf
              , x_return_status         => retcode
              , p_change_notice         => p_change_notice
              , p_organization_id       => l_org_hierarchy_level_id
              , p_org_hierarchy_name    => p_org_hierarchy_name
              , p_local_organization_id => l_org_code_list(l_org_count)
              , p_calling_API           => p_calling_API
             );
            Eng_Propagation_Log_Util.Write_Propagation_Log;
            commit;

        END LOOP; -- end FOR l_org_count IN 2..l_org_code_list.LAST
    ELSE
        PROPAGATE_ECO_ERP(
          errbuf                 => errbuf ,
          retcode                => retcode,
          p_change_notice        => p_change_notice,
          p_org_hierarchy_name   => p_org_hierarchy_name,
          p_org_hierarchy_level  => p_org_hierarchy_level
        );

    END IF;  -- end l_plm_or_erp_flag = 'PLM'

END PROPAGATE_ECO;

-- ****************************************************************** --
--  API name    : PreProcess_Propagate_Request                        --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Procedure   : Adds a row into the Propagation maps table          --
--  Parameters  :                                                     --
--       IN     :  p_api_version               IN   NUMBER            --
--                   p_init_msg_list             IN   VARCHAR2        --
--                   p_commit                    IN   VARCHAR2        --
--                   p_request_id                IN   NUMBER          --
--                   p_change_id                 IN   VARCHAR2        --
--                   p_org_hierarchy_name        IN   VARCHAR2        --
--                   p_local_organization_id     IN   NUMBER          --
--                   p_calling_API               IN   VARCHAR2        --
--                                                                    --
--       OUT    : x_msg_count                 OUT NOCOPY  NUMBER      --
--                x_msg_data                  OUT NOCOPY  VARCHAR2    --
--                x_return_status                    VARCHAR2(1)      --
--                                                                    --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                     --
-- ****************************************************************** --
PROCEDURE PreProcess_Propagate_Request (
   p_api_version               IN   NUMBER                             --
 , p_init_msg_list             IN   VARCHAR2                           --
 , p_commit                    IN   VARCHAR2                           --
 , p_request_id                IN   NUMBER
 , p_change_id                 IN   VARCHAR2
 , p_org_hierarchy_name        IN   VARCHAR2
 , p_local_organization_id     IN   NUMBER
 , p_calling_API               IN   VARCHAR2
 , x_return_status             OUT NOCOPY  VARCHAR2                    --
 , x_msg_count                 OUT NOCOPY  NUMBER                      --
 , x_msg_data                  OUT NOCOPY  VARCHAR2                    --
) IS

    l_org_hierarchy_level_id        NUMBER;
    l_change_notice                 eng_engineering_changes.change_notice%TYPE;
    l_org_code_list                 INV_OrgHierarchy_PVT.OrgID_tbl_type;

    CURSOR c_change_details IS
    SELECT change_notice, organization_id
      FROM eng_engineering_changes
     WHERE change_id = p_change_id;

    l_api_name        CONSTANT VARCHAR2(30) := 'PreProcess_Propagate_Request';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);
    l_change_map_id   NUMBER;
BEGIN
    --
    -- Standard Start of API savepoint
    SAVEPOINT PreProcess_Propagate_Request;
    --
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;
    --
    -- Fetch the change details
    OPEN c_change_details;
    FETCH c_change_details INTO l_change_notice, l_org_hierarchy_level_id;
    CLOSE c_change_details;
    --
    -- Fetch the list of organizations that are going to be processed
    -- by the request submitted
    Get_Local_Orgs_List(p_change_notice         => l_change_notice
                      , p_organization_id       => l_org_hierarchy_level_id
                      , p_hierarchy_name        => p_org_hierarchy_name
                      , p_local_organization_id => p_local_organization_id
                      , x_organizations_list    => l_org_code_list
                      , x_return_status         => l_return_status);
    --
    -- If successful , then proceed
    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        --
        -- For each organization, check if propagation process had already been
        -- initiated for the change in that organization
        -- If the map does not exist then create a new map entry with entity action status
        -- as G_PRP_PRC_STS_NOACTION CONSTANT NUMBER := 0 => Meaning: No action yet
        -- if the map already exists , then update just the value of request id on the
        -- change map, so that the UI can reference to the latest reqeust as soon as
        -- it is submitted.
        FOR l_org_count IN 2..l_org_code_list.LAST
        LOOP
            --
            -- Check for header map existance for the change and specific local org
            Eng_Propagation_Log_Util.Check_Entity_Map_Existance (
                p_change_id             => p_change_id
              , p_entity_name           => Eng_Propagation_Log_Util.G_ENTITY_CHANGE--'ENG_CHANGE'
              , p_local_organization_id => l_org_code_list(l_org_count)
              , x_change_map_id         => l_change_map_id
            );
            --
            -- If it deoes not exist, INSERT
            IF l_change_map_id IS NULL
            THEN
                SELECT eng_change_propagation_maps_s.nextval
                INTO l_change_map_id
                FROM DUAL;

                INSERT INTO eng_change_propagation_maps(
                    change_propagation_map_id
                  , change_id
                  , request_id
                  , local_organization_id
                  , entity_name
                  , creation_date
                  , created_by
                  , last_update_date
                  , last_updated_by
                  , last_update_login
                  , entity_action_status
                  )
                VALUES(
                    l_CHANGE_MAP_ID
                  , p_CHANGE_ID
                  , p_request_id
                  , l_org_code_list(l_org_count)
                  , Eng_Propagation_Log_Util.G_ENTITY_CHANGE--'ENG_CHANGE'
                  , SYSDATE
                  , FND_GLOBAL.USER_ID
                  , SYSDATE
                  , FND_GLOBAL.USER_ID
                  , FND_GLOBAL.LOGIN_ID
                  , Eng_Propagation_Log_Util.G_PRP_PRC_STS_NOACTION
                 );
            --
            -- Else UPDATE
            ELSE
                UPDATE eng_change_propagation_maps
                   SET request_id        = p_request_id
                     , creation_date     = SYSDATE
                     , created_by        = FND_GLOBAL.USER_ID
                     , last_update_date  = SYSDATE
                     , last_updated_by   = FND_GLOBAL.USER_ID
                     , last_update_login = FND_GLOBAL.LOGIN_ID
                 WHERE change_propagation_map_id = l_change_map_id;
            END IF; -- IF l_change_map_id IS NULL
        END LOOP; -- FOR l_org_count IN 2..l_org_code_list.LAST
    END IF; -- IF l_return_status = FND_API.G_RET_STS_SUCCESS

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF c_change_details%ISOPEN THEN
        CLOSE c_change_details;
    END IF;
    -- Begin Exception handling
    ROLLBACK TO PreProcess_Propagate_Request;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
      , p_data  => x_msg_data );
    -- End Exception handling
END PreProcess_Propagate_Request;

END ENGECOBO;


/
