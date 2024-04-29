--------------------------------------------------------
--  DDL for Package Body ENG_RELATED_ENTITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_RELATED_ENTITY_PKG" as
/*$Header: ENGRENTB.pls 120.15 2006/09/05 09:32:46 rnarveka noship $ */
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) :=
                              'ENG_RELATED_ENTITY_PKG' ;
-- For Debug
  g_debug_file      UTL_FILE.FILE_TYPE ;
  g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
  g_output_dir      VARCHAR2(80) := NULL ;
  g_debug_filename  VARCHAR2(30) := 'eng.chgmt.relationship.log' ;
  g_debug_errmesg   VARCHAR2(240);


change_policy_defined EXCEPTION;
duplicate_related_doc EXCEPTION;

  -- Seeded approval_status_type for change header
  /********************************************************************
  * Debug APIs    : Open_Debug_Session, Close_Debug_Session,
  *                 Write_Debug
  * Parameters IN :
  * Parameters OUT:
  * Purpose       : These procedures are for test and debug
  *********************************************************************/
  -- Open_Debug_Session
  Procedure Open_Debug_Session
  (  p_output_dir IN VARCHAR2 := NULL
  ,  p_file_name  IN VARCHAR2 := NULL
  )
  IS
       l_found NUMBER := 0;
       l_utl_file_dir    VARCHAR2(2000);

  BEGIN

       IF p_output_dir IS NOT NULL THEN
          g_output_dir := p_output_dir ;

       END IF ;

       IF p_file_name IS NOT NULL THEN
          g_debug_filename := p_file_name ;
       END IF ;

       IF g_output_dir IS NULL
       THEN

           g_output_dir := FND_PROFILE.VALUE('ECX_UTL_LOG_DIR') ;

       END IF;

       select  value
       INTO l_utl_file_dir
       FROM v$parameter
       WHERE name = 'utl_file_dir';

       l_found := INSTR(l_utl_file_dir, g_output_dir);

       IF l_found = 0
       THEN
            RETURN;
       END IF;

       g_debug_file := utl_file.fopen(  g_output_dir
                                      , g_debug_filename
                                      , 'w');
       g_debug_flag := TRUE ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Open_Debug_Session ;

  -- Close Debug_Session
  Procedure Close_Debug_Session
  IS
  BEGIN
      IF utl_file.is_open(g_debug_file)
      THEN
        utl_file.fclose(g_debug_file);
      END IF ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Close_Debug_Session ;

  -- Test Debug
  Procedure Write_Debug
  (  p_debug_message      IN  VARCHAR2 )
  IS
  BEGIN

      IF utl_file.is_open(g_debug_file)
      THEN
       utl_file.put_line(g_debug_file, p_debug_message);
      END IF ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Write_Debug;
--added l_to_current _value as defination change from DOm side.
Procedure Implement_Relationship_Changes
(
       p_api_version                IN   NUMBER                             --
       ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
       ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_output_dir                IN   VARCHAR2 := NULL                   --
       ,p_debug_filename            IN   VARCHAR2 := 'ENGRENTB.Implement_Relationship_Changes.log'
       ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
       ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
       ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
       ,p_change_id                 IN   NUMBER                             -- header's change_id
       ,p_entity_id                 IN   NUMBER        --   ed item sequence id
)
IS
l_action_type           VARCHAR2(30);
l_from_entity_name      VARCHAR2(40);
l_from_pk1_value        VARCHAR2(100);
l_from_pk2_value        VARCHAR2(100);
l_from_pk3_value        VARCHAR2(100);
l_from_pk4_value        VARCHAR2(100);
l_from_pk5_value        VARCHAR2(100);
l_to_entity_name        VARCHAR2(40);
l_to_pk1_value          VARCHAR2(100);
l_to_pk2_value          VARCHAR2(100);
l_to_current_value     VARCHAR2(100);
l_to_pk3_value          VARCHAR2(100);
l_to_pk4_value          VARCHAR2(100);
l_to_pk5_value          VARCHAR2(100);
l_relationship_code     VARCHAR2(30);
l_created_by            NUMBER;
l_last_update_login     NUMBER;

cursor C IS
   select association_id,action, relationship_code, from_entity_name, from_pk1_value,
          from_pk2_value, from_pk3_value, from_pk4_value, from_pk5_value,
          to_entity_name, to_pk1_value, to_pk2_value, to_pk3_value,
          to_pk4_value, to_pk5_value, created_by, last_update_login,to_current_value
   from   eng_relationship_changes
   where  change_id = p_change_id
   and    entity_id = p_entity_id;


l_api_name           CONSTANT VARCHAR2(30)  := 'Implement_Relationship_Changes';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_message            VARCHAR2(4000);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Implement_Relationship_Changes;

    --If BIS_COLLECTION_UTILITIES.SETUP(p_object_name => 'ENI_OLTP_ITEM_STAR')=false then
    --RAISE_APPLICATION_ERROR(-20000,errbuf);
    --End if;


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
    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
       Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_RELATED_ENTITY_PKG.Implement_Relationship_Change_log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id   : ' || p_change_id );
       Write_Debug('p_entity_id   : ' || p_entity_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------------------

    -- First check if there are floating versions in the CO to be implemented.
    -- if there are flaoting version, check its change policy and ensure that
    -- it is not under CO Required. If it is CO required, the implementation
    -- should fail.

    --BIS_COLLECTION_UTILITIES.log('Before Validation');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for floating revision');
    Validate_floating_revision (
       p_api_version     => 1
      ,p_change_id       => p_change_id
      ,p_rev_item_seq_id => p_entity_id
      , x_return_status  => l_return_status
      , x_msg_count      => l_msg_count
      , x_msg_data       => l_msg_data
    );
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Completed validation');
    --BIS_COLLECTION_UTILITIES.log('After Validation');
    --In C cursor l_created_by was getting selected.that was causing un-expected error.
    FOR REL_CHANGES IN C  LOOP

        -- Call DOM API with the action
        -- if action = 'ADD' then the API will add the record in the DOM
        --   relationship table
        -- if action = 'DELETE' then the record will be deleted
        -- If action = 'CHANGE_REVISION' then the revision id will be modified
        --   for that related document
        --  added assocaition id for dom changes.
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating record in DOM tables');
        DOM_ASSOCIATIONS_UTIL.Implement_Pending_Association(
	    p_ASSOCIATION_ID      => REL_CHANGES.association_id,
            P_ACTION                    =>  REL_CHANGES.action,
            P_FROM_ENTITY_NAME  =>  REL_CHANGES.from_entity_name,
            P_FROM_PK1_VALUE     =>  REL_CHANGES.from_pk1_value,
            P_FROM_PK2_VALUE     =>  REL_CHANGES.from_pk2_value,
            P_FROM_PK3_VALUE     =>  REL_CHANGES.from_pk3_value,
            P_FROM_PK4_VALUE     =>  REL_CHANGES.from_pk4_value,
            P_FROM_PK5_VALUE     =>  REL_CHANGES.from_pk5_value,
            P_TO_ENTITY_NAME     =>  REL_CHANGES.to_entity_name,
            P_TO_PK1_VALUE       =>  REL_CHANGES.to_pk1_value,
            P_TO_PK2_VALUE       =>  REL_CHANGES.to_pk2_value,
            P_TO_PK3_VALUE       =>  REL_CHANGES.to_pk3_value,
            P_TO_PK4_VALUE       =>  REL_CHANGES.to_pk4_value,
            P_TO_PK5_VALUE       =>  REL_CHANGES.to_pk5_value,
            P_RELATIONSHIP_CODE  =>  REL_CHANGES.relationship_code,
	    P_CURRENT_VALUE =>  REL_CHANGES.to_current_value,
            P_CREATED_BY	 =>  REL_CHANGES.created_by,
            P_LAST_UPDATE_LOGIN  =>  REL_CHANGES.last_update_login,
            X_RETURN_STATUS      => l_return_status,
            X_MSG_COUNT          =>  l_msg_count,
            X_MSG_DATA           =>  l_msg_data
         );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           EXIT;
        END IF;

	 IF ( l_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE duplicate_related_doc;
           EXIT;
        END IF;
       END LOOP;

  -- Standard ending code ------------------------------------------------
    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
   WHEN change_policy_defined THEN
        ROLLBACK TO Implement_Relationship_Changes;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Error: This Change Order has documents with floating revision that are under change required change policy. Such CO cannot be implemented';
        -- BIS_COLLECTION_UTILITIES.log('In exception'|| x_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
     WHEN duplicate_related_doc THEN
        ROLLBACK TO Implement_Relationship_Changes;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Error: Duplicate operation on same related document of item . ';
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Implement_Relationship_Changes;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      l_msg_count
       ,p_data         =>      l_msg_data );
        --BIS_COLLECTION_UTILITIES.log('In exception'|| l_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
      IF g_debug_flag THEN
        Write_Debug('Error Msg ' || l_msg_data);
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Implement_Relationship_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      l_msg_count
       ,p_data         =>      l_msg_data );
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
      IF g_debug_flag THEN
        Write_Debug('Error Msg ' || l_msg_data);
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
          ROLLBACK TO Implement_Relationship_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      l_msg_count
       ,p_data         =>      l_msg_data );
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
      IF g_debug_flag THEN
        Write_Debug('Error Msg ' || l_msg_data);
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;

  END Implement_Relationship_Changes;

-- Procedure to check if the floating revision is under change control
-- change policy.

Procedure Validate_floating_revision (
    p_api_version               IN   NUMBER
   ,p_change_id                 IN   NUMBER
   ,p_rev_item_seq_id           IN   NUMBER  := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2
   ,x_msg_count                 OUT  NOCOPY  NUMBER
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
)
IS
   Cursor get_floating_revisions(l_change_id NUMBER,
                                 l_revised_item_seq_id NUMBER) is
   select change_id, entity_id, b.category_id,
          from_pk1_value pk1_value, from_pk2_value pk2_value,
          from_pk3_value pk3_value
     from eng_relationship_changes a, dom_documents b
    where a.change_id = l_change_id
      and a.to_pk1_value = b.document_id
      and to_pk2_value = -1                 -- for floating revision documents
      and action in ('ADD','CHANGE_REVISION')
      and entity_id in (select decode(l_revised_item_seq_id,null,                                       (select revised_item_sequence_id
                                          from eng_revised_items
                                         where change_id = a.change_id),
                                             l_revised_item_seq_id)  from dual);

   l_change_id           NUMBER;
   l_revised_item_seq_id NUMBER;
   l_change_policy       VARCHAR2(100);
   l_api_name            VARCHAR2(100) := 'Validate_floating_revision';

BEGIN
   SAVEPOINT Implement_Relationship_Changes;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_change_id := p_change_id;
   l_revised_item_seq_id := p_rev_item_seq_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Validating floating revision');

   FOR c2 in get_floating_revisions(l_change_id, l_revised_item_seq_id)
   LOOP

     BEGIN

     -- The foll. SQL checks if the category passed has changepolicy defined
     -- on it or not
     SELECT ecp.policy_char_value INTO l_change_policy
       FROM
    (select nvl(mirb.lifecycle_id, msi.lifecycle_id) as lifecycle_id,
       nvl(mirb.current_phase_id , msi.current_phase_id) as phase_id,
       msi.item_catalog_group_id item_catalog_group_id,
       msi.inventory_item_id, msi.organization_id , mirb.revision_id
     from mtl_item_revisions_b mirb,
          MTL_SYSTEM_ITEMS msi
     where mirb.INVENTORY_ITEM_ID(+) = msi.INVENTORY_ITEM_ID
       and mirb.ORGANIZATION_ID(+)= msi.ORGANIZATION_ID
       and mirb.revision_id(+) = c2.pk3_value
       and msi.INVENTORY_ITEM_ID = c2.pk2_value
       and msi.ORGANIZATION_ID = c2.pk1_value) ITEM_DTLS,
      ENG_CHANGE_POLICIES_V ECP
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
     AND ecp.policy_object_pk3_value = ITEM_DTLS.phase_id
     and ecp.policy_object_name = 'CATALOG_LIFECYCLE_PHASE'
     and ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
     and ecp.attribute_code = 'AML_RULE'
     and ecp.attribute_number_value = 2;

     IF l_change_policy = 'CHANGE_ORDER_REQUIRED' THEN
        RAISE change_policy_defined;
        ROLLBACK TO Implement_Relationship_Changes;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Change policy required exception');
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN -- no data found means there are no change
                               -- policy defined for the category
         null;
     END;

   END LOOP;

END Validate_floating_revision;

END ENG_RELATED_ENTITY_PKG;

/
