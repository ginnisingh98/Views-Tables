--------------------------------------------------------
--  DDL for Package Body DOM_ASSOCIATIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_ASSOCIATIONS_UTIL" as
/*$Header: DOMPASUB.pls 120.5 2006/09/05 15:16:04 dedatta noship $ */
--  Global constant holding the package name

G_PKG_NAME CONSTANT VARCHAR2(30) := 'DOM_ASSOCIATIONS_UTIL' ;

Procedure Insert_Row(
        p_association_id        IN NUMBER,
        p_from_entity_name      IN VARCHAR2,
        p_from_pk1_value        IN VARCHAR2,
        p_from_pk2_value        IN VARCHAR2,
        p_from_pk3_value        IN VARCHAR2,
        p_from_pk4_value        IN VARCHAR2,
        p_from_pk5_value        IN VARCHAR2,
        p_to_entity_name        IN VARCHAR2,
        p_to_pk1_value          IN VARCHAR2,
        p_to_pk2_value          IN VARCHAR2,
        p_to_pk3_value          IN VARCHAR2,
        p_to_pk4_value          IN VARCHAR2,
        p_to_pk5_value          IN VARCHAR2,
        p_relationship_code     IN VARCHAR2,
        p_created_by            IN NUMBER,
        p_last_update_login     IN NUMBER,
        x_return_status       OUT  NOCOPY  VARCHAR2,
        x_msg_count           OUT  NOCOPY  NUMBER,
        x_msg_data            OUT  NOCOPY  VARCHAR2 )
IS
l_doc_number    VARCHAR2(30);
l_message       VARCHAR2(40);
BEGIN

    l_doc_number := NULL;

    BEGIN
        SELECT doc_number INTO l_doc_number
        FROM DOM_RELATIONSHIPS DR, DOM_DOCUMENTS_VL DD
        WHERE
            from_entity_name =  p_from_entity_name
        AND	from_pk1_value   =  p_from_pk1_value
        AND	from_pk2_value   =  p_from_pk2_value
        AND	((p_from_entity_name = 'EGO_ITEM_REVISION' AND from_pk3_value   =  p_from_pk3_value ) OR
             (p_from_entity_name = 'DOM_DOCUMENT_REVISION' AND from_pk3_value   IS NULL ) OR p_from_entity_name = 'EGO_ITEM' AND from_pk3_value   IS NULL )
        AND	to_entity_name   =  p_to_entity_name
        AND	to_pk1_value     =  p_to_pk1_value
        AND	relationship_code=  p_relationship_code
        AND to_pk1_value = TO_CHAR(dd.document_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    IF l_doc_number IS NOT NULL THEN
           l_message := 'DOM_ADD_IMP_ERROR';
           FND_MESSAGE.Set_Name('DOM', l_message);
           FND_MESSAGE.Set_Token('DOC_NUMBER', l_doc_number);
           FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
        INSERT INTO DOM_RELATIONSHIPS (
            association_id      ,
            from_entity_name      ,
            from_pk1_value        ,
            from_pk2_value        ,
            from_pk3_value        ,
            from_pk4_value        ,
            from_pk5_value        ,
            to_entity_name        ,
            to_pk1_value          ,
            to_pk2_value          ,
            to_pk3_value          ,
            to_pk4_value          ,
            to_pk5_value          ,
            relationship_code     ,
            created_by            ,
            last_update_login     ,
            creation_date	      ,
            last_update_date
        )
        VALUES
        (
            p_association_id        ,
            p_from_entity_name      ,
            p_from_pk1_value        ,
            p_from_pk2_value        ,
            p_from_pk3_value        ,
            p_from_pk4_value        ,
            p_from_pk5_value        ,
            p_to_entity_name        ,
            p_to_pk1_value          ,
            p_to_pk2_value          ,
            p_to_pk3_value          ,
            p_to_pk4_value          ,
            p_to_pk5_value          ,
            p_relationship_code     ,
            p_created_by            ,
            p_last_update_login     ,
            sysdate                 ,
            sysdate
        );
     END IF;


END Insert_Row;

Procedure Delete_Row(
        p_from_entity_name      IN VARCHAR2,
        p_from_pk1_value        IN VARCHAR2,
        p_from_pk2_value        IN VARCHAR2,
        p_from_pk3_value        IN VARCHAR2,
        p_from_pk4_value        IN VARCHAR2,
        p_from_pk5_value        IN VARCHAR2,
        p_to_entity_name        IN VARCHAR2,
        p_to_pk1_value          IN VARCHAR2,
        p_to_pk2_value          IN VARCHAR2,
        p_to_pk3_value          IN VARCHAR2,
        p_to_pk4_value          IN VARCHAR2,
        p_to_pk5_value          IN VARCHAR2,
	p_current_value         IN VARCHAR2,
        p_relationship_code     IN VARCHAR2,
        x_return_status       OUT  NOCOPY  VARCHAR2,
        x_msg_count           OUT  NOCOPY  NUMBER,
        x_msg_data            OUT  NOCOPY  VARCHAR2 )
IS
l_doc_number    VARCHAR2(30);
l_message       VARCHAR2(40);
BEGIN

    l_doc_number := NULL;

    BEGIN
        SELECT doc_number INTO l_doc_number
        FROM DOM_RELATIONSHIPS DR, DOM_DOCUMENTS_VL DD
        WHERE
            from_entity_name =  p_from_entity_name
        AND	from_pk1_value   =  p_from_pk1_value
        AND	from_pk2_value   =  p_from_pk2_value
        AND	((p_from_entity_name = 'EGO_ITEM_REVISION' AND from_pk3_value   =  p_from_pk3_value ) OR
             (p_from_entity_name = 'DOM_DOCUMENT_REVISION' AND from_pk3_value   IS NULL ) OR (p_from_entity_name = 'EGO_ITEM' AND from_pk3_value   IS NULL) )
        AND	to_entity_name   =  p_to_entity_name
        AND	to_pk1_value     =  p_to_pk1_value
        AND	relationship_code=  p_relationship_code
        AND to_pk1_value = TO_CHAR(dd.document_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;




    IF l_doc_number IS NULL THEN
           l_message := 'DOM_DELETE_IMP_ERROR';
           FND_MESSAGE.Set_Name('DOM', l_message);
           FND_MESSAGE.Set_Token('DOC_NUMBER', l_doc_number);
           FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE


        DELETE FROM DOM_RELATIONSHIPS
        WHERE
            from_entity_name =  p_from_entity_name
        AND	from_pk1_value   =  p_from_pk1_value
        AND	from_pk2_value   =  p_from_pk2_value
        AND	((p_from_entity_name = 'EGO_ITEM_REVISION' AND from_pk3_value   =  p_from_pk3_value ) OR
             (p_from_entity_name = 'DOM_DOCUMENT_REVISION' AND from_pk3_value   IS NULL ) OR
             (p_from_entity_name = 'EGO_ITEM' AND from_pk3_value   IS NULL ))
        AND	to_entity_name   =  p_to_entity_name
        AND	to_pk1_value     =  p_to_pk1_value
        --AND	to_pk2_value     =  p_current_value
        AND	relationship_code=  p_relationship_code;
    END IF;

END Delete_Row;

Procedure Change_Revision(
        p_from_entity_name      IN VARCHAR2,
        p_from_pk1_value        IN VARCHAR2,
        p_from_pk2_value        IN VARCHAR2,
        p_from_pk3_value        IN VARCHAR2,
        p_from_pk4_value        IN VARCHAR2,
        p_from_pk5_value        IN VARCHAR2,
        p_to_entity_name        IN VARCHAR2,
        p_to_pk1_value          IN VARCHAR2,
        p_to_pk2_value          IN VARCHAR2,
        p_to_pk3_value          IN VARCHAR2,
        p_to_pk4_value          IN VARCHAR2,
        p_to_pk5_value          IN VARCHAR2,
        p_relationship_code     IN VARCHAR2,
	    p_current_value         IN VARCHAR2,
        x_return_status       OUT  NOCOPY  VARCHAR2,
        x_msg_count           OUT  NOCOPY  NUMBER,
        x_msg_data            OUT  NOCOPY  VARCHAR2 )
IS
l_doc_number    VARCHAR2(30);
l_message       VARCHAR2(40);
BEGIN

    l_doc_number := NULL;

    BEGIN
        SELECT doc_number INTO l_doc_number
        FROM DOM_RELATIONSHIPS DR, DOM_DOCUMENTS_VL DD
        WHERE
            from_entity_name =  p_from_entity_name
        AND	from_pk1_value   =  p_from_pk1_value
        AND	from_pk2_value   =  p_from_pk2_value
        AND	((p_from_entity_name = 'EGO_ITEM_REVISION' AND from_pk3_value   =  p_from_pk3_value ) OR
             (p_from_entity_name = 'DOM_DOCUMENT_REVISION' AND from_pk3_value   IS NULL ) OR (p_from_entity_name = 'EGO_ITEM' AND from_pk3_value   IS NULL) )
        AND	to_entity_name   =  p_to_entity_name
        AND	to_pk1_value     =  p_to_pk1_value
        AND	relationship_code=  p_relationship_code
        AND to_pk1_value = TO_CHAR(dd.document_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;







    IF l_doc_number IS NULL THEN
           l_message := 'DOM_CHANGE_REV_IMP_ERROR';
           FND_MESSAGE.Set_Name('DOM', l_message);
           FND_MESSAGE.Set_Token('DOC_NUMBER', l_doc_number);
           FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE

        UPDATE DOM_RELATIONSHIPS
        SET
            to_pk2_value = p_to_pk2_value
        WHERE
            from_entity_name =  decode(p_from_entity_name,'MTL_ITEM_REVISIONS','EGO_ITEM_REVISION',decode(p_from_entity_name,'MTL__SYSTEM_ITEMS','EGO_ITEM',p_from_entity_name))
        AND	from_pk1_value   =  p_from_pk1_value
        AND	from_pk2_value   =  p_from_pk2_value
        AND	((decode(p_from_entity_name,'MTL_ITEM_REVISIONS','EGO_ITEM_REVISION',decode(p_from_entity_name,'MTL__SYSTEM_ITEMS','EGO_ITEM',p_from_entity_name)) = 'EGO_ITEM_REVISION' AND from_pk3_value   =  p_from_pk3_value ) OR
             (p_from_entity_name = 'DOM_DOCUMENT_REVISION' AND from_pk3_value   IS NULL ) OR
             (p_from_entity_name = 'EGO_ITEM' AND from_pk3_value   IS NULL ))
        AND	to_entity_name   =  p_to_entity_name
        AND	to_pk1_value     =  p_to_pk1_value
        --AND	to_pk2_value     =  p_current_value
        AND	relationship_code=  p_relationship_code;
     END IF;

END Change_Revision;

Procedure Implement_Pending_Association(
        p_association_id        IN NUMBER  ,
        p_action                IN VARCHAR2,
        p_from_entity_name      IN VARCHAR2,
        p_from_pk1_value        IN VARCHAR2,
        p_from_pk2_value        IN VARCHAR2,
        p_from_pk3_value        IN VARCHAR2,
        p_from_pk4_value        IN VARCHAR2,
        p_from_pk5_value        IN VARCHAR2,
        p_to_entity_name        IN VARCHAR2,
        p_to_pk1_value          IN VARCHAR2,
        p_to_pk2_value          IN VARCHAR2,
        p_to_pk3_value          IN VARCHAR2,
        p_to_pk4_value          IN VARCHAR2,
        p_to_pk5_value          IN VARCHAR2,
        p_relationship_code     IN VARCHAR2,
	    p_current_value         IN VARCHAR2,
        p_created_by            IN NUMBER,
        p_last_update_login     IN NUMBER,
        x_return_status       OUT  NOCOPY  VARCHAR2,
        x_msg_count           OUT  NOCOPY  NUMBER,
        x_msg_data            OUT  NOCOPY  VARCHAR2 )
IS

l_action        VARCHAR2(20);


l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_api_name		 VARCHAR2(50) := 'Implement_Pending_Association';


BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_action := p_action;

    IF l_action = 'ADD' THEN

        Insert_Row (    p_association_id     => p_association_id,
                        p_from_entity_name   => p_from_entity_name,
                        p_from_pk1_value     => p_from_pk1_value,
                        p_from_pk2_value     => p_from_pk2_value,
                        p_from_pk3_value     => p_from_pk3_value,
                        p_from_pk4_value     => p_from_pk4_value,
                        p_from_pk5_value     => p_from_pk5_value,
                        p_to_entity_name     => p_to_entity_name,
                        p_to_pk1_value       => p_to_pk1_value,
                        p_to_pk2_value       => p_to_pk2_value,
                        p_to_pk3_value       => p_to_pk3_value,
                        p_to_pk4_value       => p_to_pk4_value,
                        p_to_pk5_value       => p_to_pk5_value,
                        p_relationship_code  => p_relationship_code,
                        p_created_by         => p_created_by,
                        p_last_update_login  => p_last_update_login,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data );

    ELSIF l_action = 'DELETE' THEN

        Delete_Row (
                        p_from_entity_name   => p_from_entity_name,
                        p_from_pk1_value     => p_from_pk1_value,
                        p_from_pk2_value     => p_from_pk2_value,
                        p_from_pk3_value     => p_from_pk3_value,
                        p_from_pk4_value     => p_from_pk4_value,
                        p_from_pk5_value     => p_from_pk5_value,
                        p_to_entity_name     => p_to_entity_name,
                        p_to_pk1_value       => p_to_pk1_value,
                        p_to_pk2_value       => p_to_pk2_value,
                        p_to_pk3_value       => p_to_pk3_value,
                        p_to_pk4_value       => p_to_pk4_value,
                        p_to_pk5_value       => p_to_pk5_value,
                        p_relationship_code  => p_relationship_code,
			            p_current_value      => p_current_value,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data );

    ELSIF l_action = 'CHANGE_REVISION' THEN

         Change_Revision (
                        p_from_entity_name   => p_from_entity_name,
                        p_from_pk1_value     => p_from_pk1_value,
                        p_from_pk2_value     => p_from_pk2_value,
                        p_from_pk3_value     => p_from_pk3_value,
                        p_from_pk4_value     => p_from_pk4_value,
                        p_from_pk5_value     => p_from_pk5_value,
                        p_to_entity_name     => p_to_entity_name,
                        p_to_pk1_value       => p_to_pk1_value,
                        p_to_pk2_value       => p_to_pk2_value,
                        p_to_pk3_value       => p_to_pk3_value,
                        p_to_pk4_value       => p_to_pk4_value,
                        p_to_pk5_value       => p_to_pk5_value,
                        p_relationship_code  => p_relationship_code,
			            p_current_value      => p_current_value,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data );
    END IF;






    -- Standard ending code ------------------------------------------------

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

END Implement_Pending_Association;


END DOM_ASSOCIATIONS_UTIL;

/
