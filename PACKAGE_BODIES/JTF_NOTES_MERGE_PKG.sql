--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_MERGE_PKG" as
/* $Header: jtfntmgb.pls 115.5 2002/11/16 00:27:08 hbouten noship $ */

PROCEDURE MERGE_NOTES
( p_entity_name         IN            VARCHAR2
, p_from_id             IN            NUMBER
, x_to_id                  OUT NOCOPY NUMBER
, p_from_fk_id          IN            NUMBER
, p_to_fk_id            IN            NUMBER
, p_parent_entity_name  IN            VARCHAR2
, p_batch_id            IN            NUMBER
, p_batch_party_id      IN            NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
)
IS

  l_merge_reason_code VARCHAR2(30);

  CURSOR 	c_duplicate
  IS SELECT 	merge_reason_code
     FROM   	hz_merge_batch
     WHERE  	batch_id = p_batch_id;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (  (p_entity_name <> 'JTF_NOTES_B')
     OR (p_parent_entity_name NOT IN ('HZ_PARTIES','HZ_PARTY_SITES'))
     )
  THEN
    FND_MESSAGE.SET_NAME ('JTF', 'NOTES_MSG');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  OPEN 	c_duplicate;
  FETCH	c_duplicate INTO l_merge_reason_code;
  CLOSE	c_duplicate;

  IF l_merge_reason_code <> 'DUPLICATE'
  THEN
    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.
    NULL;
  END IF;

  -- perform the merge operation
  -- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
  -- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

  IF p_from_fk_id = p_to_fk_id
  THEN
    x_to_id := p_from_id;
    RETURN;
  END IF;

  -- If the parent has changed(ie. Parent is getting merged) then transfer the
  -- dependent record to the new parent.
  -- For example in  JTF_NOTES_B table, if party_id 1 got merged to party_id  2
  -- then, we have to update all records with new_source_object_id  1 to 2
  -- p_to_fk_id is the new value which has to be put
  -- p_from_id is the jtf_note_id
  IF (   (P_FROM_FK_ID  <> P_TO_FK_ID)
     AND (p_parent_entity_name = 'HZ_PARTIES')
     )
  THEN
    UPDATE jtf_notes_b
    SET	source_object_id  = p_to_fk_id
    ,   last_update_date  = hz_utility_pub.last_update_date
    ,   last_updated_by   = hz_utility_pub.user_id
    ,   last_update_login = hz_utility_pub.last_update_login
	WHERE source_object_code IN (SELECT ojt.object_code
                                 FROM jtf_objects_b     ojt
                                 ,    jtf_object_usages oue
                                 WHERE ojt.object_code = oue.object_code
                                 AND oue.object_user_code = 'NOTES'
                                 AND ojt.from_table ='HZ_PARTIES'
                                 )
	AND source_object_id = p_from_fk_id;

  ELSIF (   (P_FROM_FK_ID  <> P_TO_FK_ID)
         AND (p_parent_entity_name = 'HZ_PARTY_SITES')
         )
  THEN
    UPDATE jtf_notes_b
    SET source_object_id  = p_to_fk_id
    ,   last_update_date  = hz_utility_pub.last_update_date
    ,   last_updated_by   = hz_utility_pub.user_id
    ,	last_update_login = hz_utility_pub.last_update_login
	WHERE source_object_code IN (SELECT ojt.object_code
                                 FROM jtf_objects_b     ojt
                                 ,    jtf_object_usages oue
                                 WHERE ojt.object_code = oue.object_code
                                 AND oue.object_user_code = 'NOTES'
                                 AND ojt.from_table ='HZ_PARTY_SITES'
                                 )
	AND source_object_id  = p_from_fk_id;
  END IF;

EXCEPTION
  WHEN OTHERS
    THEN
      IF (c_duplicate%ISOPEN)
      THEN
        CLOSE c_duplicate;
      END IF;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_to_id         := NULL;

END MERGE_NOTES;

PROCEDURE MERGE_CONTEXT
( p_entity_name         IN            VARCHAR2
, p_from_id             IN            NUMBER
, x_to_id                  OUT NOCOPY NUMBER
, p_from_fk_id          IN            NUMBER
, p_to_fk_id            IN            NUMBER
, p_parent_entity_name  IN            VARCHAR2
, p_batch_id            IN            NUMBER
, p_batch_party_id      IN            NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
)
IS

  l_merge_reason_code VARCHAR2(30);

  CURSOR c_duplicate
  IS SELECT merge_reason_code
     FROM   hz_merge_batch
     WHERE  batch_id = p_batch_id;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (  (p_entity_name <> 'JTF_NOTE_CONTEXTS')
     OR (p_parent_entity_name NOT IN ('HZ_PARTIES','HZ_PARTY_SITES'))
     )
  THEN
     FND_MESSAGE.SET_NAME('JTF', 'NOTES_MSG');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN 	c_duplicate;
  FETCH	c_duplicate INTO l_merge_reason_code;
  CLOSE	c_duplicate;

  IF l_merge_reason_code <> 'DUPLICATE'
  THEN
    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.
    NULL;
  END IF;

  -- perform the merge operation
  -- if the parent has NOT changed(i.e. parent  getting transferred)  then
  -- nothing needs to be done. Set merged to id (x_to_id) the same as merged
  -- from id and return

  IF p_from_fk_id = p_to_fk_id
  THEN
    x_to_id := p_from_id;
    RETURN;
  END IF;

  -- If the parent has changed(ie. Parent is getting merged) then transfer the
  -- dependent record to the new parent.
  -- For example in  JTF_NOTES_B table, if party_id 1 got merged to party_id  2
  -- then, we have to update all records with new_source_object_id  1 to 2
  -- p_to_fk_id is the new value which has to be put
  -- p_from_id is the jtf_note_id

  IF (   (p_from_fk_id <> p_to_fk_id)
     AND (p_parent_entity_name = 'HZ_PARTIES')
     )
  THEN
    UPDATE jtf_note_contexts
    SET	note_context_type_id   = p_to_fk_id
    ,   last_update_date  = hz_utility_pub.last_update_date
    ,   last_updated_by   = hz_utility_pub.user_id
    ,   last_update_login = hz_utility_pub.last_update_login
  	WHERE note_context_type IN (SELECT ojt.object_code
                                FROM jtf_objects_b ojt
                                ,    jtf_object_usages oue
                                WHERE ojt.object_code = oue.object_code
                                AND   oue.object_user_code = 'NOTES'
                                AND   ojt.from_table ='HZ_PARTIES'
                                )
    AND note_context_type_id = p_from_fk_id;

  ELSIF (   (p_from_fk_id <> p_to_fk_id)
        AND (p_parent_entity_name = 'HZ_PARTY_SITES')
        )
  THEN
    UPDATE jtf_note_contexts
    SET	note_context_type_id   = p_to_fk_id
    ,   last_update_date  = hz_utility_pub.last_update_date
    ,   last_updated_by   = hz_utility_pub.user_id
    ,   last_update_login = hz_utility_pub.last_update_login
  	WHERE note_context_type IN (SELECT ojt.object_code
                                FROM jtf_objects_b ojt
                                ,    jtf_object_usages oue
                                WHERE ojt.object_code = oue.object_code
                                AND   oue.object_user_code = 'NOTES'
                                AND   ojt.from_table ='HZ_PARTY_SITES'
                                )
    AND note_context_type_id = p_from_fk_id;
  END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_duplicate%ISOPEN)
      THEN
        CLOSE c_duplicate;
      END IF;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_to_id         := NULL;

END MERGE_CONTEXT;


END JTF_NOTES_MERGE_PKG;


/
