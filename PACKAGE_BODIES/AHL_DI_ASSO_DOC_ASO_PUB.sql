--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOC_ASO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOC_ASO_PUB" AS
/* $Header: AHLPDASB.pls 115.26 2003/10/20 19:36:13 sikumar noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_ASSO_DOC_ASO_PUB';
--
/*-----------------------------------------------------------*/
/* procedure name: Check_lookup_name_Or_Id(private procedure)*/
/* description :  used to retrieve lookup code               */
/*                                                           */
/*-----------------------------------------------------------*/

--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
BEGIN
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND meaning     = p_meaning
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
    END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN too_many_rows THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END;
/*------------------------------------------------------*/
/* procedure name: create_association                   */
/* description :  Creates new association record        */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_ASSOCIATION
(
 p_api_version               IN      NUMBER    :=  1.0            ,
 p_init_msg_list             IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                    IN      VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only             IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl         IN  OUT NOCOPY association_tbl       ,
 p_module_type               IN      VARCHAR2                     ,
 x_return_status                 OUT NOCOPY VARCHAR2                     ,
 x_msg_count                     OUT NOCOPY NUMBER                       ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
IS
--Used to retrieve document id
CURSOR get_doc_id_info(c_document_no  VARCHAR2)
IS
 SELECT document_id
   FROM AHL_DOCUMENTS_B
  WHERE document_no = c_document_no;
-- Used to retrieve document revision
CURSOR get_doc_rev_id_info(c_revision_no VARCHAR2,
                           c_document_id  NUMBER)
IS
 SELECT doc_revision_id
   FROM AHL_DOC_REVISIONS_B
  WHERE revision_no = c_revision_no
    AND document_id = c_document_id;

-- {{ adharia bug #2450326 - added- 9/7/2002
--To retrieve document id
CURSOR get_doc_rev_count(c_document_id  VARCHAR2)
IS
 SELECT COUNT(*)
   FROM AHL_DOC_REVISIONS_B
  WHERE document_id = c_document_id;

--to get the rev info based on the doc id used if only one rev is present for the document
CURSOR get_doc_rev_info(c_document_id  NUMBER)
IS
 SELECT doc_revision_id, revision_no
   FROM AHL_DOC_REVISIONS_B
  WHERE document_id = c_document_id;
-- }} adharia bug #2450326 - added- 9/7/2002

--
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_ASSOCIATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_document_id           NUMBER;
 l_doc_revision_id       NUMBER;
 l_aso_object_type_code  VARCHAR2(30);
 l_association_tbl       AHL_DI_ASSO_DOC_ASO_PVT.association_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;

 l_pre_V_msg_count             NUMBER;
 l_pre_V_msg_data              VARCHAR2(2000);
 l_pre_V_return_status         VARCHAR2(1);
 l_post_V_msg_count             NUMBER;
 l_post_V_msg_data              VARCHAR2(2000);
 l_post_V_return_status         VARCHAR2(1);
 l_pre_C_msg_count             NUMBER;
 l_pre_C_msg_data              VARCHAR2(2000);
 l_pre_C_return_status         VARCHAR2(1);
 l_post_C_msg_count             NUMBER;
 l_post_C_msg_data              VARCHAR2(2000);
 l_post_C_return_status         VARCHAR2(1);
-- {{ adharia bug #2450326 - added- 9/7/2002
l_rev_count              NUMBER;
l_doc_revision_no        VARCHAR2(30);
-- }} adharia bug #2450326 - added- 9/7/2002


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT create_association;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.Create Association','+DOBJASS+');

	END IF;
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
    x_return_status := 'S';
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --Starts API Body
   IF p_x_association_tbl.COUNT > 0
   THEN
     FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_association_tbl(i).document_id := null;
            p_x_association_tbl(i).doc_revision_id := null;
        END IF;

 --{{adharia-- bug #2450326 - added- 9/7/2002
         IF (p_x_association_tbl(i).document_no IS NULL) OR
            (p_x_association_tbl(i).document_no = FND_API.G_MISS_CHAR)
          THEN
		 FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_NO_NULL');
                 FND_MSG_PUB.ADD;
          ELSE

                 OPEN get_doc_id_info(p_x_association_tbl(i).document_no);
                 FETCH get_doc_id_info INTO l_document_id;
                 IF get_doc_id_info%FOUND
                 THEN
                   l_association_tbl(i).document_id := l_document_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_id_info;

                 OPEN  get_doc_rev_count(l_document_id);
                 FETCH get_doc_rev_count INTO l_rev_count;
                 CLOSE get_doc_rev_count;
                 IF l_rev_count = 0
                 THEN
                   l_association_tbl(i).doc_revision_id := NULL;
                 ELSIF l_rev_count =1
                 THEN
			 OPEN get_doc_rev_info(l_document_id);
			 FETCH get_doc_rev_info INTO l_doc_revision_id, l_doc_revision_no;
			 IF get_doc_rev_info%FOUND
			 THEN
	                   l_association_tbl(i).doc_revision_id := l_doc_revision_id;
	                 ELSE
	                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
	                   FND_MSG_PUB.ADD;
	                 END IF;
	                 CLOSE get_doc_rev_info;
                 ELSIF l_rev_count > 1
                 THEN

			 OPEN  get_doc_rev_id_info(p_x_association_tbl(i).revision_no,
						   l_document_id);
			 FETCH get_doc_rev_id_info INTO l_doc_revision_id;
			 IF get_doc_rev_id_info%FOUND
			 THEN
			  l_association_tbl(i).doc_revision_id := l_doc_revision_id;
			  ELSE
			   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
			   FND_MSG_PUB.ADD;
			 END IF;
			 CLOSE get_doc_rev_id_info;
                 END IF;
          END IF;
--}} adharia -- bug #2450326 - added- 9/7/2002
         -- For Aso Object Type code, meaning presents
         IF p_x_association_tbl(i).aso_object_desc IS NOT NULL AND
            p_x_association_tbl(i).aso_object_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_OBJECT_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tbl(i).aso_object_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tbl(i).aso_object_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYP_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Type Code presents
        IF p_x_association_tbl(i).aso_object_type_code IS NOT NULL AND
           p_x_association_tbl(i).aso_object_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tbl(i).aso_object_type_code := p_x_association_tbl(i).aso_object_type_code;
       --If both missing
       ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_TYPE_NULL');
            FND_MSG_PUB.ADD;
        END IF;
        l_association_tbl(i).aso_object_id         := p_x_association_tbl(i).aso_object_id;
        l_association_tbl(i).use_latest_rev_flag   := p_x_association_tbl(i).use_latest_rev_flag;
        l_association_tbl(i).serial_no             := p_x_association_tbl(i).serial_no;
        l_association_tbl(i).source_lang           := p_x_association_tbl(i).source_lang;
        l_association_tbl(i).chapter               := p_x_association_tbl(i).chapter;
        l_association_tbl(i).section               := p_x_association_tbl(i).section;
        l_association_tbl(i).subject 	           := p_x_association_tbl(i).subject;
        l_association_tbl(i).page                  := p_x_association_tbl(i).page;
        l_association_tbl(i).figure                := p_x_association_tbl(i).figure;
        l_association_tbl(i).note                  := p_x_association_tbl(i).note;
        l_association_tbl(i).attribute_category    := p_x_association_tbl(i).attribute_category;
        l_association_tbl(i).attribute1            := p_x_association_tbl(i).attribute1;
        l_association_tbl(i).attribute2            := p_x_association_tbl(i).attribute2;
        l_association_tbl(i).attribute3            := p_x_association_tbl(i).attribute3;
        l_association_tbl(i).attribute4            := p_x_association_tbl(i).attribute4;
        l_association_tbl(i).attribute5            := p_x_association_tbl(i).attribute5;
        l_association_tbl(i).attribute6            := p_x_association_tbl(i).attribute6;
        l_association_tbl(i).attribute7            := p_x_association_tbl(i).attribute7;
        l_association_tbl(i).attribute8            := p_x_association_tbl(i).attribute8;
        l_association_tbl(i).attribute9            := p_x_association_tbl(i).attribute9;
        l_association_tbl(i).attribute10           := p_x_association_tbl(i).attribute10;
        l_association_tbl(i).attribute11           := p_x_association_tbl(i).attribute11;
        l_association_tbl(i).attribute12           := p_x_association_tbl(i).attribute12;
        l_association_tbl(i).attribute13           := p_x_association_tbl(i).attribute13;
        l_association_tbl(i).attribute14           := p_x_association_tbl(i).attribute14;
        l_association_tbl(i).attribute15           := p_x_association_tbl(i).attribute15;
        l_association_tbl(i).delete_flag           := p_x_association_tbl(i).delete_flag;
        l_association_tbl(i).object_version_number := p_x_association_tbl(i).object_version_number;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
 END LOOP;
END IF;

/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_ASSO_DOC_ASO_CUHK.CREATE_ASSOCIATION_PRE        */
/*                 AHL_DI_ASSO_DOC_ASO_VUHK.CREATE_ASSOCIATION_PRE        */
/* description   :  Added by Senthil to call User Hooks                   */
/* Date     : Dec 10 2001                                                 */
/*------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','CREATE_ASSOCIATION',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Customer Create Association_Pre');

	END IF;
            AHL_DI_ASSO_DOC_ASO_CUHK.CREATE_ASSOCIATION_PRE(
			P_X_ASSOCIATION_TBL    	=>	l_association_tbl,
			X_RETURN_STATUS        	=>	l_pre_C_return_status      ,
			X_MSG_COUNT            	=>	l_pre_C_msg_count           ,
			X_MSG_DATA             	=>	l_pre_C_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of api Customer Create Association_Pre');

	END IF;

      		IF   l_pre_C_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_pre_C_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','CREATE_ASSOCIATION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Vertical Create Association_Pre');

	END IF;
            AHL_DI_ASSO_DOC_ASO_VUHK.CREATE_ASSOCIATION_PRE(
			P_X_ASSOCIATION_TBL    	=>	l_association_tbl,
			X_RETURN_STATUS        	=>	l_pre_V_return_status      ,
			X_MSG_COUNT            	=>	l_pre_V_msg_count           ,
			X_MSG_DATA             	=>	l_pre_V_msg_data  );
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of api Vertical Create Association_Pre');

	END IF;
      		IF   l_pre_V_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_pre_V_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;
/*---------------------------------------------------------*/
/*     End ; Date     : Dec 10 2001                             */
/*---------------------------------------------------------*/

-- Call the Private API
 AHL_DI_ASSO_DOC_ASO_PVT.CREATE_ASSOCIATION
        (
         p_api_version       => 1.0,
         p_init_msg_list     => l_init_msg_list,
         p_commit            => p_commit,
         p_validate_only     => p_validate_only,
         p_validation_level  => p_validation_level,
         p_x_association_tbl => l_association_tbl,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
         );

   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

 --Assign values
 IF l_association_tbl.COUNT > 0
 THEN
   FOR i IN l_association_tbl.FIRST..l_association_tbl.LAST
   LOOP
     p_x_association_tbl(i).doc_title_asso_id := l_association_tbl(i).doc_title_asso_id;
   END LOOP;
 END IF;

/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_ASSO_DOC_ASO_CUHK.CREATE_ASSOCIATION_POST       */
/*                 AHL_DI_ASSO_DOC_ASO_VUHK.CREATE_ASSOCIATION_POST       */
/* description   :  Added by Senthil to call User Hooks                   */
/* Date     : Dec 10 2001                                                 */
/*------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','CREATE_ASSOCIATION',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Customer Create Association_Post');

	END IF;
            AHL_DI_ASSO_DOC_ASO_CUHK.CREATE_ASSOCIATION_POST(
			P_ASSOCIATION_TBL    	=>	l_association_tbl,
			X_RETURN_STATUS        	=>	l_post_C_return_status      ,
			X_MSG_COUNT            	=>	l_post_C_msg_count           ,
			X_MSG_DATA             	=>	l_post_C_msg_data  );
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of api Customer Create Association_Post');

	END IF;
      		IF   l_post_C_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_post_C_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','CREATE_ASSOCIATION',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Vertical Create Association_Post');

	END IF;
            AHL_DI_ASSO_DOC_ASO_VUHK.CREATE_ASSOCIATION_POST(
			P_ASSOCIATION_TBL    	=>	l_association_tbl,
			X_RETURN_STATUS        	=>	l_post_V_return_status      ,
			X_MSG_COUNT            	=>	l_post_V_msg_count           ,
			X_MSG_DATA             	=>	l_post_V_msg_data  );
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of api Vertical Create Association_Post');

	END IF;
      		IF   l_post_V_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_post_V_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 10 2001                        */
/*---------------------------------------------------------*/

   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Create Association','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        --Debug Info
        IF G_DEBUG='Y' THEN

		  AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );




		  AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Create Association','+DOCJASS+');



        -- Check if API is called in debug mode. If yes, disable debug.

		  AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => X_msg_data);
     x_msg_count := l_msg_count;

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Create Association','+DOCJASS+');

	-- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

        END IF;


 WHEN OTHERS THEN
    ROLLBACK TO create_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PUB',
                            p_procedure_name  =>  'CREATE_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => X_msg_data);
    x_msg_count := l_msg_count;
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Create Association','+DOCJASS+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_ASSOCIATION;

/*------------------------------------------------------*/
/* procedure name: modify_association                   */
/* description :  Updates and removes the association   */
/*                record                                */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE MODIFY_ASSOCIATION
(
 p_api_version               IN     NUMBER    :=  1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl         IN OUT NOCOPY association_tbl       ,
 p_module_type               IN     VARCHAR2                     ,
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
-- {{ adharia -- bug #2450326 - added- 9/7/2002
--To retrieve document id
CURSOR get_doc_id_info(c_document_no  VARCHAR2)
IS
 SELECT document_id
   FROM AHL_DOCUMENTS_B
  WHERE document_no = c_document_no;

--To retrieve count of revisions of the doc
CURSOR get_doc_rev_count(c_document_id  VARCHAR2)
IS
 SELECT COUNT(*)
   FROM AHL_DOC_REVISIONS_B
  WHERE document_id = c_document_id;

--to get the rev info based on the doc id used if only one rev is present for the document
CURSOR get_doc_rev_info(c_document_id  NUMBER)
IS
 SELECT doc_revision_id, revision_no
   FROM AHL_DOC_REVISIONS_B
  WHERE document_id = c_document_id;
-- }} adharia -- bug #2450326 - added- 9/7/2002

--To retrieve document revision
CURSOR get_doc_rev_id_info(c_revision_no VARCHAR2,
                           c_document_id  NUMBER)
IS
 SELECT doc_revision_id
   FROM AHL_DOC_REVISIONS_B A
  WHERE revision_no = c_revision_no
    AND document_id = c_document_id;
--
l_api_name     CONSTANT  VARCHAR2(30) := 'MODIFY_ASSOCIATION';
l_api_version  CONSTANT  NUMBER       := 1.0;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_aso_object_type_code   VARCHAR2(30);
l_document_id            NUMBER;
l_doc_revision_id        NUMBER;
l_association_tbl        AHL_DI_ASSO_DOC_ASO_PVT.association_tbl;
l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;

l_pre_V_msg_count        NUMBER;
l_pre_V_msg_data         VARCHAR2(2000);
l_pre_V_return_status    VARCHAR2(1);
l_post_V_msg_count       NUMBER;
l_post_V_msg_data        VARCHAR2(2000);
l_post_V_return_status   VARCHAR2(1);
l_pre_C_msg_count        NUMBER;
l_pre_C_msg_data         VARCHAR2(2000);
l_pre_C_return_status    VARCHAR2(1);
l_post_C_msg_count       NUMBER;
l_post_C_msg_data        VARCHAR2(2000);
l_post_C_return_status   VARCHAR2(1);
-- {{ adharia -- bug #2450326 - added- 9/7/2002
l_rev_count              NUMBER;
l_doc_revision_no        VARCHAR2(30);
-- }} adharia -- bug #2450326 - added- 9/7/2002

BEGIN
    -- Standard Start of API savepoint
   SAVEPOINT modify_association;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.Rajanth Testing the code','+DOBJASS+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
    IF FND_API.to_boolean(l_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := 'S';
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   --Starts API Body
   IF p_x_association_tbl.COUNT > 0
   THEN
     FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_association_tbl(i).document_id := null;
            p_x_association_tbl(i).doc_revision_id := null;
        END IF;

        -- {{adharia  -- bug #2450326 - added- 9/7/2002
 -- EDIT OPERATION  ...START
     IF (p_x_association_tbl(i).delete_flag <> 'Y')
     THEN
         IF (p_x_association_tbl(i).document_no IS NULL) OR
            (p_x_association_tbl(i).document_no = FND_API.G_MISS_CHAR)
          THEN
		 FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_NO_NULL');
                 FND_MSG_PUB.ADD;
          ELSE
        -- For document id
                 OPEN get_doc_id_info(p_x_association_tbl(i).document_no);
                 FETCH get_doc_id_info INTO l_document_id;
                 IF get_doc_id_info%FOUND
                 THEN
                   l_association_tbl(i).document_id := l_document_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_id_info;

        -- For count of rev for the document
                 OPEN  get_doc_rev_count(l_document_id);
                 FETCH get_doc_rev_count INTO l_rev_count;
                 CLOSE get_doc_rev_count;
                 -- if no rev doc revid =null and you can associate the doc
                 IF l_rev_count = 0
                 THEN
                   l_association_tbl(i).doc_revision_id := NULL;
                 -- if one   rev is present associate it directly
                 ELSIF l_rev_count =1
                 THEN

			 OPEN get_doc_rev_info(l_document_id);
			 FETCH get_doc_rev_info INTO l_doc_revision_id, l_doc_revision_no;
			 IF get_doc_rev_info%FOUND
			 THEN
	                   l_association_tbl(i).doc_revision_id := l_doc_revision_id;
	                 ELSE
	                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
	                   FND_MSG_PUB.ADD;
	                 END IF;
	                 CLOSE get_doc_rev_info;
	         -- if more than one rev are present then check if the rev id passes is valid else throw error
                 ELSIF l_rev_count > 1
                 THEN

			 OPEN  get_doc_rev_id_info(p_x_association_tbl(i).revision_no,
						   l_document_id);
			 FETCH get_doc_rev_id_info INTO l_doc_revision_id;
			 IF get_doc_rev_id_info%FOUND
			 THEN
			  l_association_tbl(i).doc_revision_id := l_doc_revision_id;
			  ELSE
			   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
			   FND_MSG_PUB.ADD;
			 END IF;
			 CLOSE get_doc_rev_id_info;
                 END IF;
          END IF;
   -- EDIT OPERATION      ... END

   -- DELETE OPERATION
     ELSIF (p_x_association_tbl(i).delete_flag = 'Y')
     THEN
         --For Document Id,
      IF (p_x_association_tbl(i).document_id IS NULL OR
         p_x_association_tbl(i).document_id = FND_API.G_MISS_NUM)
         THEN

          -- If name is available
           IF (p_x_association_tbl(i).document_no IS NOT NULL) AND
              (p_x_association_tbl(i).document_no <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  get_doc_id_info(p_x_association_tbl(i).document_no);
                 FETCH get_doc_id_info INTO l_document_id;
                 IF get_doc_id_info%FOUND
                 THEN
                  l_association_tbl(i).document_id := l_document_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_id_info;
           --If Document Id is present
         ELSIF (p_x_association_tbl(i).document_id IS NOT NULL) AND
               (p_x_association_tbl(i).document_id <> FND_API.G_MISS_NUM)
            THEN
               l_association_tbl(i).document_id := l_document_id;
         ELSE
              --Both Document Id and Name are missing
               l_association_tbl(i).document_id := l_document_id;
        END IF;
       END IF;

         --For Document Revision Id,
         -- If Revision no is available
         IF p_x_association_tbl(i).doc_revision_id IS NULL OR
            p_x_association_tbl(i).doc_revision_id = FND_API.G_MISS_NUM
           THEN
           IF (p_x_association_tbl(i).revision_no IS NOT NULL) AND
              (p_x_association_tbl(i).revision_no <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  get_doc_rev_id_info(p_x_association_tbl(i).revision_no,
                                           l_document_id);
                 FETCH get_doc_rev_id_info INTO l_doc_revision_id;
                 IF get_doc_rev_id_info%FOUND
                 THEN
                  l_association_tbl(i).doc_revision_id := l_doc_revision_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_rev_id_info;
           --If Doc Revision Id is present
         ELSIF (p_x_association_tbl(i).doc_revision_id IS NOT NULL) AND
               (p_x_association_tbl(i).doc_revision_id <> FND_API.G_MISS_NUM)
            THEN
               l_association_tbl(i).doc_revision_id := l_doc_revision_id;
        END IF;
      END IF;
    END IF;--END IF DELETE FLAG
-- }}adharia -- bug #2450326 - added- 9/7/2002

           -- For Aso Object Type code, meaning presents
         IF p_x_association_tbl(i).aso_object_desc IS NOT NULL AND
            p_x_association_tbl(i).aso_object_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_OBJECT_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tbl(i).aso_object_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tbl(i).aso_object_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYPE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Type Code presents
        IF p_x_association_tbl(i).aso_object_type_code IS NOT NULL AND
           p_x_association_tbl(i).aso_object_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tbl(i).aso_object_type_code := p_x_association_tbl(i).aso_object_type_code;
       --If both missing
       ELSE
           l_association_tbl(i).aso_object_type_code := p_x_association_tbl(i).aso_object_type_code;
        END IF;

        l_association_tbl(i).doc_title_asso_id   := p_x_association_tbl(i).doc_title_asso_id;
        l_association_tbl(i).use_latest_rev_flag := p_x_association_tbl(i).use_latest_rev_flag;
        l_association_tbl(i).aso_object_id       := p_x_association_tbl(i).aso_object_id;
        l_association_tbl(i).serial_no           := p_x_association_tbl(i).serial_no;
        l_association_tbl(i).source_lang         := p_x_association_tbl(i).source_lang;
        l_association_tbl(i).chapter             := p_x_association_tbl(i).chapter;
        l_association_tbl(i).section             := p_x_association_tbl(i).section;
        l_association_tbl(i).subject 	         := p_x_association_tbl(i).subject;
        l_association_tbl(i).page                := p_x_association_tbl(i).page;
        l_association_tbl(i).figure              := p_x_association_tbl(i).figure;
        l_association_tbl(i).note                := p_x_association_tbl(i).note;
        l_association_tbl(i).attribute_category  := p_x_association_tbl(i).attribute_category;
        l_association_tbl(i).attribute1          := p_x_association_tbl(i).attribute1;
        l_association_tbl(i).attribute2          := p_x_association_tbl(i).attribute2;
        l_association_tbl(i).attribute3          := p_x_association_tbl(i).attribute3;
        l_association_tbl(i).attribute4          := p_x_association_tbl(i).attribute4;
        l_association_tbl(i).attribute5          := p_x_association_tbl(i).attribute5;
        l_association_tbl(i).attribute6          := p_x_association_tbl(i).attribute6;
        l_association_tbl(i).attribute7          := p_x_association_tbl(i).attribute7;
        l_association_tbl(i).attribute8          := p_x_association_tbl(i).attribute8;
        l_association_tbl(i).attribute9          := p_x_association_tbl(i).attribute9;
        l_association_tbl(i).attribute10         := p_x_association_tbl(i).attribute10;
        l_association_tbl(i).attribute11         := p_x_association_tbl(i).attribute11;
        l_association_tbl(i).attribute12         := p_x_association_tbl(i).attribute12;
        l_association_tbl(i).attribute13         := p_x_association_tbl(i).attribute13;
        l_association_tbl(i).attribute14         := p_x_association_tbl(i).attribute14;
        l_association_tbl(i).attribute15         := p_x_association_tbl(i).attribute15;
        l_association_tbl(i).delete_flag         := p_x_association_tbl(i).delete_flag;
        l_association_tbl(i).object_version_number := p_x_association_tbl(i).object_version_number;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
 END LOOP;
END IF;

/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_ASSO_DOC_ASO_CUHK.MODIFY_ASSOCIATION_PRE        */
/*                 AHL_DI_ASSO_DOC_ASO_VUHK.MODIFY_ASSOCIATION_PRE        */
/* description   :  Added by Senthil to call User Hooks                   */
/* Date     : Dec 10 2001                                                 */
/*------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','MODIFY_ASSOCIATION',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Customer MODIFY_ASSOCIATION_PRE');

	END IF;
            AHL_DI_ASSO_DOC_ASO_CUHK.MODIFY_ASSOCIATION_PRE(
			P_X_ASSOCIATION_TBL    	=>	l_association_tbl    ,
			X_RETURN_STATUS        	=>	l_pre_C_return_status        ,
			X_MSG_COUNT            	=>	l_pre_C_msg_count            ,
			X_MSG_DATA             	=>	l_pre_C_msg_data             );

      		IF   l_pre_C_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_pre_C_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','MODIFY_ASSOCIATION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Vertical MODIFY_ASSOCIATION_PRE');

	END IF;
            AHL_DI_ASSO_DOC_ASO_VUHK.MODIFY_ASSOCIATION_PRE(
			P_X_ASSOCIATION_TBL    	=>	l_association_tbl    ,
			X_RETURN_STATUS        	=>	l_pre_V_return_status        ,
			X_MSG_COUNT            	=>	l_pre_V_msg_count            ,
			X_MSG_DATA             	=>	l_pre_V_msg_data             );

      		IF   l_pre_V_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_pre_V_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 10 2001                        */
/*---------------------------------------------------------*/

 -- Call the Private API
 AHL_DI_ASSO_DOC_ASO_PVT.MODIFY_ASSOCIATION
        (
         p_api_version       => 1.0,
         p_init_msg_list     => l_init_msg_list,
         p_commit            => p_commit,
         p_validate_only     => p_validate_only,
         p_validation_level  => p_validation_level,
         p_x_association_tbl => l_association_tbl,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
         );
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_ASSO_DOC_ASO_CUHK.MODIFY_ASSOCIATION_POST       */
/*                 AHL_DI_ASSO_DOC_ASO_VUHK.MODIFY_ASSOCIATION_POST       */
/* description   :  Added by Senthil to call User Hooks                   */
/* Date     : Dec 10 2001                                                 */
/*------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','MODIFY_ASSOCIATION',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Customer MODIFY_ASSOCIATION_POST');

	END IF;
            AHL_DI_ASSO_DOC_ASO_CUHK.MODIFY_ASSOCIATION_POST(
			P_ASSOCIATION_TBL    	=>	l_association_tbl    ,
			X_RETURN_STATUS        	=>	l_post_C_return_status        ,
			X_MSG_COUNT            	=>	l_post_C_msg_count            ,
			X_MSG_DATA             	=>	l_post_C_msg_data             );

      		IF   l_post_C_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_post_C_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_ASSO_DOC_ASO_PUB','MODIFY_ASSOCIATION',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start of api Vertical MODIFY_ASSOCIATION_POST');

	END IF;
            AHL_DI_ASSO_DOC_ASO_VUHK.MODIFY_ASSOCIATION_POST(
			P_ASSOCIATION_TBL    	=>	l_association_tbl    ,
			X_RETURN_STATUS        	=>	l_post_V_return_status        ,
			X_MSG_COUNT            	=>	l_post_V_msg_count            ,
			X_MSG_DATA             	=>	l_post_V_msg_data             );

      		IF   l_post_V_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_post_V_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 10 2001                        */
/*---------------------------------------------------------*/

   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Modify Association','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Modify Association','+DOCJASS+');

        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Modify Association','+DOCJASS+');

        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PUB',
                            p_procedure_name  =>  'MODIFY_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Modify Association','+DOCJASS+');

        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_ASSOCIATION;
----------------------------PROCESS_ASSOCIATION------------------------------
PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version               IN     NUMBER    :=  1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tblm         IN OUT NOCOPY association_tbl       ,
 p_x_association_tblc         IN OUT NOCOPY association_tbl       ,
 p_module_type               IN     VARCHAR2                     ,
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
--To retrieve document id
CURSOR get_doc_id_info(c_document_no  VARCHAR2)
IS
 SELECT document_id
   FROM AHL_DOCUMENTS_B
  WHERE document_no = c_document_no;
--To retrieve document revision
CURSOR get_doc_rev_id_info(c_revision_no VARCHAR2,
                           c_document_id  NUMBER)
IS
 SELECT doc_revision_id
   FROM AHL_DOC_REVISIONS_B A
  WHERE revision_no = c_revision_no
    AND document_id = c_document_id;
--
l_api_name     CONSTANT  VARCHAR2(30) := 'PROCESS_ASSOCIATION';
l_api_version  CONSTANT  NUMBER       := 1.0;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_aso_object_type_code   VARCHAR2(30);
l_document_id            NUMBER;
l_doc_revision_id        NUMBER;
l_association_tbl        AHL_DI_ASSO_DOC_ASO_PVT.association_tbl;
l_association_tblc       AHL_DI_ASSO_DOC_ASO_PVT.association_tbl;
l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
l_pre_V_msg_count        NUMBER;
l_pre_V_msg_data         VARCHAR2(2000);
l_pre_V_return_status    VARCHAR2(1);
l_post_V_msg_count       NUMBER;
l_post_V_msg_data        VARCHAR2(2000);
l_post_V_return_status   VARCHAR2(1);
l_pre_C_msg_count        NUMBER;
l_pre_C_msg_data         VARCHAR2(2000);
l_pre_C_return_status    VARCHAR2(1);
l_post_C_msg_count       NUMBER;
l_post_C_msg_data        VARCHAR2(2000);
l_post_C_return_status   VARCHAR2(1);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT process_association;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.Process Association','+DOBJASS+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
    IF FND_API.to_boolean(l_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := 'S';
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   --Starts API to modify Body
   IF p_x_association_tblm.COUNT > 0
   THEN
     FOR i IN p_x_association_tblm.FIRST..p_x_association_tblm.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_association_tblm(i).document_id := null;
            p_x_association_tblm(i).doc_revision_id := null;
        END IF;

         --For Document Id,
      IF (p_x_association_tblm(i).document_id IS NULL OR
         p_x_association_tblm(i).document_id <> FND_API.G_MISS_NUM)
         THEN

          -- If name is available
           IF (p_x_association_tblm(i).document_no IS NOT NULL) AND
              (p_x_association_tblm(i).document_no <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  get_doc_id_info(p_x_association_tblm(i).document_no);
                 FETCH get_doc_id_info INTO l_document_id;
                 IF get_doc_id_info%FOUND
                 THEN
                  l_association_tbl(i).document_id := l_document_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_id_info;
           --If Document Id is present
         ELSIF (p_x_association_tblm(i).document_id IS NOT NULL) AND
               (p_x_association_tblm(i).document_id <> FND_API.G_MISS_NUM)
            THEN
               l_association_tbl(i).document_id := l_document_id;
         ELSE
              --Both Document Id and Name are missing
               l_association_tbl(i).document_id := l_document_id;
        END IF;
       END IF;
         --For Document Revision Id,
          -- If Revision no is available
         IF p_x_association_tblm(i).doc_revision_id IS NULL OR
            p_x_association_tblm(i).doc_revision_id = FND_API.G_MISS_NUM
           THEN
           IF (p_x_association_tblm(i).revision_no IS NOT NULL) AND
              (p_x_association_tblm(i).revision_no <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  get_doc_rev_id_info(p_x_association_tblm(i).revision_no,
                                           l_document_id);
                 FETCH get_doc_rev_id_info INTO l_doc_revision_id;
                 IF get_doc_rev_id_info%FOUND
                 THEN
                  l_association_tbl(i).doc_revision_id := l_doc_revision_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_rev_id_info;
           --If Doc Revision Id is present
         ELSIF (p_x_association_tblm(i).doc_revision_id IS NOT NULL) AND
               (p_x_association_tblm(i).doc_revision_id <> FND_API.G_MISS_NUM)
            THEN
               l_association_tbl(i).doc_revision_id := l_doc_revision_id;
        END IF;
      END IF;
           -- For Aso Object Type code, meaning presents
         IF p_x_association_tblm(i).aso_object_desc IS NOT NULL AND
            p_x_association_tblm(i).aso_object_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_OBJECT_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tblm(i).aso_object_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tbl(i).aso_object_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYPE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Type Code presents
        IF p_x_association_tblm(i).aso_object_type_code IS NOT NULL AND
           p_x_association_tblm(i).aso_object_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tbl(i).aso_object_type_code := p_x_association_tblm(i).aso_object_type_code;
       --If both missing
       ELSE
           l_association_tbl(i).aso_object_type_code := p_x_association_tblm(i).aso_object_type_code;
        END IF;
           -- For Source Ref Code, meaning presents
         IF p_x_association_tblm(i).source_ref_mean IS NOT NULL AND
            p_x_association_tblm(i).source_ref_mean <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DI_SOURCE_REF',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tblm(i).source_ref_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tbl(i).source_ref_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_REF_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;

        -- If Type Code presents
        IF p_x_association_tblm(i).source_ref_code IS NOT NULL AND
           p_x_association_tblm(i).source_ref_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tbl(i).source_ref_code := p_x_association_tblm(i).source_ref_code;
       --If both missing
       ELSE
           l_association_tbl(i).source_ref_code := p_x_association_tblm(i).source_ref_code;
        END IF;

        l_association_tbl(i).doc_title_asso_id   := p_x_association_tblm(i).doc_title_asso_id;
        l_association_tbl(i).use_latest_rev_flag := p_x_association_tblm(i).use_latest_rev_flag;
        l_association_tbl(i).aso_object_id       := p_x_association_tblm(i).aso_object_id;
        l_association_tbl(i).serial_no           := p_x_association_tblm(i).serial_no;
        l_association_tbl(i).source_lang         := p_x_association_tblm(i).source_lang;
        l_association_tbl(i).chapter             := p_x_association_tblm(i).chapter;
        l_association_tbl(i).section             := p_x_association_tblm(i).section;
        l_association_tbl(i).subject             := p_x_association_tblm(i).subject;
        l_association_tbl(i).page                := p_x_association_tblm(i).page;
        l_association_tbl(i).figure              := p_x_association_tblm(i).figure;
        l_association_tbl(i).note                := p_x_association_tblm(i).note;
        l_association_tbl(i).source_ref_code     := p_x_association_tblm(i).source_ref_code;
        l_association_tbl(i).attribute_category  := p_x_association_tblm(i).attribute_category;
        l_association_tbl(i).attribute1          := p_x_association_tblm(i).attribute1;
        l_association_tbl(i).attribute2          := p_x_association_tblm(i).attribute2;
        l_association_tbl(i).attribute3          := p_x_association_tblm(i).attribute3;
        l_association_tbl(i).attribute4          := p_x_association_tblm(i).attribute4;
        l_association_tbl(i).attribute5          := p_x_association_tblm(i).attribute5;
        l_association_tbl(i).attribute6          := p_x_association_tblm(i).attribute6;
        l_association_tbl(i).attribute7          := p_x_association_tblm(i).attribute7;
        l_association_tbl(i).attribute8          := p_x_association_tblm(i).attribute8;
        l_association_tbl(i).attribute9          := p_x_association_tblm(i).attribute9;
        l_association_tbl(i).attribute10         := p_x_association_tblm(i).attribute10;
        l_association_tbl(i).attribute11         := p_x_association_tblm(i).attribute11;
        l_association_tbl(i).attribute12         := p_x_association_tblm(i).attribute12;
        l_association_tbl(i).attribute13         := p_x_association_tblm(i).attribute13;
        l_association_tbl(i).attribute14         := p_x_association_tblm(i).attribute14;
        l_association_tbl(i).attribute15         := p_x_association_tblm(i).attribute15;
        l_association_tbl(i).delete_flag         := p_x_association_tblm(i).delete_flag;
        l_association_tbl(i).object_version_number := p_x_association_tblm(i).object_version_number;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
 END LOOP;
END IF;
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'before modify');

	END IF;
    END IF;

IF p_x_association_tblm.COUNT > 0
THEN

 -- Call the Private API
 AHL_DI_ASSO_DOC_ASO_PVT.MODIFY_ASSOCIATION
        (
         p_api_version       => 1.0,
         p_init_msg_list     => l_init_msg_list,
         p_commit            => p_commit,
         p_validate_only     => p_validate_only,
         p_validation_level  => p_validation_level,
         p_x_association_tbl => l_association_tbl,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
         );
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;
---------------------------------CREATE PART OF CODE---------------------
   IF p_x_association_tblc.COUNT > 0
   THEN
     FOR i IN p_x_association_tblc.FIRST..p_x_association_tblc.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_association_tblc(i).document_id := null;
            p_x_association_tblc(i).doc_revision_id := null;
        END IF;


     IF (p_x_association_tblc(i).document_id IS NULL OR
         p_x_association_tblc(i).document_id = FND_API.G_MISS_NUM)
      THEN

        -- For Document Id, If docuemnt no is passed
           IF (p_x_association_tblc(i).document_no IS NOT NULL) AND
              (p_x_association_tblc(i).document_no <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  get_doc_id_info(p_x_association_tblc(i).document_no);
                 FETCH get_doc_id_info INTO l_document_id;
              	   IF get_doc_id_info%FOUND
                 THEN
                  l_association_tblc(i).document_id := l_document_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_id_info;
             ELSE
                 FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_INVALID');
                 FND_MSG_PUB.ADD;
             END IF;

           --If Document Id is present
           ELSIF (p_x_association_tblc(i).document_id IS NOT NULL)  AND
              (p_x_association_tblc(i).document_id <> FND_API.G_MISS_NUM)
              THEN
                  l_association_tblc(i).document_id := p_x_association_tblc(i).document_id;
           ELSE
              --Both Document Id and Name are missing
              FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_NOT_EXISTS');
              FND_MSG_PUB.ADD;
            END IF;
        -- For Document Revision Id
     IF (p_x_association_tblc(i).doc_revision_id IS NULL OR
         p_x_association_tblc(i).doc_revision_id = FND_API.G_MISS_NUM)
      THEN

         -- If Revision No is available
           IF (p_x_association_tblc(i).revision_no IS NOT NULL) AND
              (p_x_association_tblc(i).revision_no <> FND_API.G_MISS_CHAR)
              THEN

                 OPEN  get_doc_rev_id_info(p_x_association_tblc(i).revision_no,
                                           l_document_id);
                 FETCH get_doc_rev_id_info INTO l_doc_revision_id;
                 IF get_doc_rev_id_info%FOUND
                 THEN
                  l_association_tblc(i).doc_revision_id := l_doc_revision_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_doc_rev_id_info;
            ELSE
             l_association_tblc(i).doc_revision_id := p_x_association_tblc(i).doc_revision_id;
            END IF;
           --If Revision Id is present
          ELSIF (p_x_association_tblc(i).doc_revision_id IS NOT NULL) AND
              (p_x_association_tblc(i).doc_revision_id <> FND_API.G_MISS_NUM)
              THEN
                  l_association_tblc(i).doc_revision_id := p_x_association_tblc(i).doc_revision_id;
           ELSE
             l_association_tblc(i).doc_revision_id := p_x_association_tblc(i).doc_revision_id;
         END IF;

         -- For Aso Object Type code, meaning presents
         IF p_x_association_tblc(i).aso_object_desc IS NOT NULL AND
            p_x_association_tblc(i).aso_object_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_OBJECT_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tblc(i).aso_object_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tblc(i).aso_object_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYP_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Type Code presents
        IF p_x_association_tblc(i).aso_object_type_code IS NOT NULL AND
           p_x_association_tblc(i).aso_object_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tblc(i).aso_object_type_code := p_x_association_tblc(i).aso_object_type_code;
       --If both missing
       ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_TYPE_NULL');
            FND_MSG_PUB.ADD;
        END IF;
           -- For Source Ref Code, meaning presents
/*         IF p_x_association_tblc(i).source_ref_mean IS NOT NULL AND
            p_x_association_tblc(i).source_ref_mean <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DI_SOURCE_REF',
                  p_lookup_code  => null,
                  p_meaning      => p_x_association_tblc(i).source_ref_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_association_tbl(i).source_ref_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_REF_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;   */
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('SOURCE CODE :' ||p_x_association_tblc(i).source_ref_code);

	END IF;
    END IF;

        -- If Type Code presents
        IF p_x_association_tblc(i).source_ref_code IS NOT NULL AND
           p_x_association_tblc(i).source_ref_code <> FND_API.G_MISS_CHAR
         THEN
           l_association_tbl(i).source_ref_code := p_x_association_tblc(i).source_ref_code;
       --If both missing
       ELSE
           l_association_tbl(i).source_ref_code := p_x_association_tblc(i).source_ref_code;
        END IF;

        l_association_tblc(i).aso_object_id         := p_x_association_tblc(i).aso_object_id;
        l_association_tblc(i).use_latest_rev_flag   := p_x_association_tblc(i).use_latest_rev_flag;
        l_association_tblc(i).serial_no             := p_x_association_tblc(i).serial_no;
        l_association_tblc(i).source_lang           := p_x_association_tblc(i).source_lang;
        l_association_tblc(i).chapter               := p_x_association_tblc(i).chapter;
        l_association_tblc(i).section               := p_x_association_tblc(i).section;
        l_association_tblc(i).subject               := p_x_association_tblc(i).subject;
        l_association_tblc(i).page                  := p_x_association_tblc(i).page;
        l_association_tblc(i).figure                := p_x_association_tblc(i).figure;
        l_association_tblc(i).note                  := p_x_association_tblc(i).note;
        l_association_tblc(i).source_ref_code       := p_x_association_tblc(i).source_ref_code;
        l_association_tblc(i).attribute_category    := p_x_association_tblc(i).attribute_category;
        l_association_tblc(i).attribute1            := p_x_association_tblc(i).attribute1;
        l_association_tblc(i).attribute2            := p_x_association_tblc(i).attribute2;
        l_association_tblc(i).attribute3            := p_x_association_tblc(i).attribute3;
        l_association_tblc(i).attribute4            := p_x_association_tblc(i).attribute4;
        l_association_tblc(i).attribute5            := p_x_association_tblc(i).attribute5;
        l_association_tblc(i).attribute6            := p_x_association_tblc(i).attribute6;
        l_association_tblc(i).attribute7            := p_x_association_tblc(i).attribute7;
        l_association_tblc(i).attribute8            := p_x_association_tblc(i).attribute8;
        l_association_tblc(i).attribute9            := p_x_association_tblc(i).attribute9;
        l_association_tblc(i).attribute10           := p_x_association_tblc(i).attribute10;
        l_association_tblc(i).attribute11           := p_x_association_tblc(i).attribute11;
        l_association_tblc(i).attribute12           := p_x_association_tblc(i).attribute12;
        l_association_tblc(i).attribute13           := p_x_association_tblc(i).attribute13;
        l_association_tblc(i).attribute14           := p_x_association_tblc(i).attribute14;
        l_association_tblc(i).attribute15           := p_x_association_tblc(i).attribute15;
        l_association_tblc(i).delete_flag           := p_x_association_tblc(i).delete_flag;
        l_association_tblc(i).object_version_number := p_x_association_tblc(i).object_version_number;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
 END LOOP;
END IF;

/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_ASSO_DOC_ASO_CUHK.CREATE_ASSOCIATION_PRE        */
/*                 AHL_DI_ASSO_DOC_ASO_VUHK.CREATE_ASSOCIATION_PRE        */
/* description   :  Added by Senthil to call User Hooks                   */
/* Date     : Dec 10 2001                                                 */
/*------------------------------------------------------------------------*/


-- Call the Private API
   IF p_x_association_tblC.COUNT > 0
   THEN
    x_return_status := 'S';
 AHL_DI_ASSO_DOC_ASO_PVT.CREATE_ASSOCIATION
        (
         p_api_version       => 1.0,
         p_init_msg_list     => l_init_msg_list,
         p_commit            => p_commit,
         p_validate_only     => p_validate_only,
         p_validation_level  => p_validation_level,
         p_x_association_tbl => l_association_tblc,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
         );

   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

 --Assign values
 IF l_association_tblc.COUNT > 0
 THEN
   FOR i IN l_association_tblc.FIRST..l_association_tblc.LAST
   LOOP
     p_x_association_tblc(i).doc_title_asso_id := l_association_tblc(i).doc_title_asso_id;
   END LOOP;
 END IF;
END IF;
--
--Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Process Association','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Proces Association','+DOCJASS+');

	-- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;



 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Process Association','+DOCJASS+');

        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PUB',
                            p_procedure_name  =>  'PROCESS_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.Process Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END PROCESS_ASSOCIATION;

END AHL_DI_ASSO_DOC_ASO_PUB;

/
