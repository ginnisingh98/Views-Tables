--------------------------------------------------------
--  DDL for Package Body AHL_DI_PRO_TYPE_ASO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_PRO_TYPE_ASO_PUB" AS
/* $Header: AHLPPTAB.pls 120.0 2005/05/26 00:07:57 appldev noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_PRO_TYPE_ASO_PUB';
--
/*---------------------------------------------------*/
/* procedure name: create_doc_type_assoc             */
/* description :  Creates new association record     */
/*                for doc type and sub type code     */
/*                                                   */
/*---------------------------------------------------*/
--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE CREATE_DOC_TYPE_ASSOC
(
 p_api_version               IN     NUMBER    :=  1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl      IN OUT NOCOPY doc_type_assoc_tbl    ,
 p_module_type               IN     VARCHAR2                     ,
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS
--To retrieve the lookup code
CURSOR lookup_code_info(c_lookup_type VARCHAR2,
                        c_lookup_code VARCHAR2)
IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_type = c_lookup_type
   AND lookup_code = c_lookup_code
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);
--To retrieve the lookup code
CURSOR lookup_code_value(c_lookup_type VARCHAR2,
                         c_meaning VARCHAR2)
IS
 SELECT lookup_code
    FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_type = c_lookup_type
    AND meaning     = c_meaning
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);
--
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_DOC_TYPE_ASSOC';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_doc_type_code         VARCHAR2(30);
 l_doc_sub_type_code     VARCHAR2(30);
 l_doc_type              VARCHAR2(30)  := 'AHL_DOC_TYPE';
 l_sub_type              VARCHAR2(30)  := 'AHL_DOC_SUB_TYPE';
 l_doc_type_assoc_tbl    AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT create_doc_type_assoc;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_pro_type_aso_pub.Create Doc Type','+DOCTY+');

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
    --Start of API Body
   IF p_x_doc_type_assoc_tbl.count > 0
   THEN
     FOR i IN p_x_doc_type_assoc_tbl.FIRST..p_x_doc_type_assoc_tbl.LAST
     LOOP
       -- Module Type is 'JSP' then make it null
       IF (p_module_type = 'JSP') THEN
          p_x_doc_type_assoc_tbl(i).doc_sub_type_code := null;
       END IF;

       -- For Doc Type Code, Description presents
       IF p_x_doc_type_assoc_tbl(i).doc_type_desc IS NOT NULL
         THEN
           OPEN lookup_code_value(l_doc_type,
                                  p_x_doc_type_assoc_tbl(i).doc_type_desc);
           FETCH lookup_code_value INTO l_doc_type_code;
           IF lookup_code_value%NOTFOUND
           THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
           ELSE
           l_doc_type_assoc_tbl(i).doc_type_code := l_doc_type_code;
           END IF;
           CLOSE lookup_code_value;
       END IF;
       -- Doc Type Code Presents
       IF p_x_doc_type_assoc_tbl(i).doc_type_code IS NOT NULL
          THEN
           l_doc_type_assoc_tbl(i).doc_type_code := p_x_doc_type_assoc_tbl(i).doc_type_code;
       --Both missing
       ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NULL');
            FND_MSG_PUB.ADD;
      END IF;

       --For Sub Type Code
       IF p_x_doc_type_assoc_tbl(i).doc_sub_type_desc IS NOT NULL
          THEN
            OPEN lookup_code_value(l_sub_type,
                                   p_x_doc_type_assoc_tbl(i).doc_sub_type_desc);
            FETCH lookup_code_value INTO l_doc_sub_type_code;
            IF lookup_code_value%NOTFOUND
            THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUB_CODE_NOT_EXIST');
             FND_MESSAGE.SET_TOKEN('SUBTYPE',p_x_doc_type_assoc_tbl(i).doc_sub_type_desc);
             FND_MSG_PUB.ADD;
             ELSE
             l_doc_type_assoc_tbl(i).doc_sub_type_code := l_doc_sub_type_code;
             END IF;
            CLOSE lookup_code_value;
        --Sub Type Code is available
        ELSIF p_x_doc_type_assoc_tbl(i).doc_sub_type_code IS NOT NULL
           THEN
            l_doc_type_assoc_tbl(i).doc_sub_type_code := p_x_doc_type_assoc_tbl(i).doc_sub_type_code;
          -- If both missing
         ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUB_TYPE_CODE_NULL');
            FND_MSG_PUB.ADD;
      END IF;

        l_doc_type_assoc_tbl(i).document_sub_type_id := p_x_doc_type_assoc_tbl(i).document_sub_type_id;
        l_doc_type_assoc_tbl(i).attribute_category   := p_x_doc_type_assoc_tbl(i).attribute_category;
        l_doc_type_assoc_tbl(i).attribute1           := p_x_doc_type_assoc_tbl(i).attribute1;
        l_doc_type_assoc_tbl(i).attribute2           := p_x_doc_type_assoc_tbl(i).attribute2;
        l_doc_type_assoc_tbl(i).attribute3           := p_x_doc_type_assoc_tbl(i).attribute3;
        l_doc_type_assoc_tbl(i).attribute4           := p_x_doc_type_assoc_tbl(i).attribute4;
        l_doc_type_assoc_tbl(i).attribute5           := p_x_doc_type_assoc_tbl(i).attribute5;
        l_doc_type_assoc_tbl(i).attribute6           := p_x_doc_type_assoc_tbl(i).attribute6;
        l_doc_type_assoc_tbl(i).attribute7           := p_x_doc_type_assoc_tbl(i).attribute7;
        l_doc_type_assoc_tbl(i).attribute8           := p_x_doc_type_assoc_tbl(i).attribute8;
        l_doc_type_assoc_tbl(i).attribute9           := p_x_doc_type_assoc_tbl(i).attribute9;
        l_doc_type_assoc_tbl(i).attribute10          := p_x_doc_type_assoc_tbl(i).attribute10;
        l_doc_type_assoc_tbl(i).attribute11          := p_x_doc_type_assoc_tbl(i).attribute11;
        l_doc_type_assoc_tbl(i).attribute12          := p_x_doc_type_assoc_tbl(i).attribute12;
        l_doc_type_assoc_tbl(i).attribute13          := p_x_doc_type_assoc_tbl(i).attribute13;
        l_doc_type_assoc_tbl(i).attribute14          := p_x_doc_type_assoc_tbl(i).attribute14;
        l_doc_type_assoc_tbl(i).attribute15          := p_x_doc_type_assoc_tbl(i).attribute15;
        l_doc_type_assoc_tbl(i).delete_flag          := p_x_doc_type_assoc_tbl(i).delete_flag;
        l_doc_type_assoc_tbl(i).object_version_number := p_x_doc_type_assoc_tbl(i).object_version_number;
     --Standard check for messages
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
   END LOOP;
  END IF;


/*------------------------------------------------------------------------- */
/* procedure name:	AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_PRE  */
/*			AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_PRE  */
/* description   :  	Added by Siddhartha to call User Hooks    	    */
/*      Date     : 	Dec 20 2001                                         */
/*--------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','CREATE_DOC_TYPE_ASSOC',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_PRE');

	END IF;

AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_PRE
(
	 p_x_doc_type_assoc_tbl      =>	l_doc_type_assoc_tbl ,
	 x_return_status             =>	l_return_status,
	 x_msg_count                 =>	l_msg_count   ,
	 x_msg_data                  =>	l_msg_data
);

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_PRE');

	END IF;

  	     		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','CREATE_DOC_TYPE_ASSOC',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_PRE');

	END IF;

            AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_PRE(
			p_x_doc_type_assoc_tbl  =>	l_doc_type_assoc_tbl,
			X_RETURN_STATUS        	=>	l_return_status       ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_PRE');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/


  -- Call the Private API
   AHL_DI_PRO_TYPE_ASO_PVT.CREATE_DOC_TYPE_ASSOC
       (
        p_api_version          => 1.0,
        p_init_msg_list        => l_init_msg_list,
        p_commit               => p_commit,
        p_validate_only        => p_validate_only,
        p_validation_level     => p_validation_level,
        p_x_doc_type_assoc_tbl => l_doc_type_assoc_tbl,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data
        );

   -- Standard check for messages assigns out variable
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
     FOR i IN 1..l_doc_type_assoc_tbl.COUNT
     LOOP
        p_x_doc_type_assoc_tbl(i).document_sub_type_id := l_doc_type_assoc_tbl(i).document_sub_type_id;
     END LOOP;
   END IF;


/*-----------------------------------------------------------------------------	*/
/* procedure name: AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_POST		*/
/*		   AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_POST		*/
/*        									*/
/* description   :  Added by siddhartha to call User Hooks   			*/
/*      Date     : Dec 20 2001                             			*/
/*------------------------------------------------------------------------------*/



IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','CREATE_DOC_TYPE_ASSOC',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_POST');

	END IF;

            AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_POST(
		 p_doc_type_assoc_tbl   	=>	l_doc_type_assoc_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_VUHK.Create_Doc_Type_Assoc_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','CREATE_DOC_TYPE_ASSOC',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_POST');

	END IF;

              AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_POST(

			p_doc_type_assoc_tbl    =>	l_doc_type_assoc_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_CUHK.Create_Doc_Type_Assoc_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/


  --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Create Doc Type','+DOCTY+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Create Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Create Doc Type','+DOCTY+');

        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_PRO_TYPE_ASO_PUB',
                            p_procedure_name  =>  'CREATE_DOC_TYPE_ASSOC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Create Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_DOC_TYPE_ASSOC;

/*---------------------------------------------------*/
/* procedure name: modify_doc_type_assoc             */
/* description :  Updates the existing association   */
/*                record, and removes as well        */
/*                                                   */
/*---------------------------------------------------*/
PROCEDURE MODIFY_DOC_TYPE_ASSOC
(
 p_api_version               IN     NUMBER    :=  1.0              ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE    ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE   ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE    ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl      IN OUT NOCOPY doc_type_assoc_tbl      ,
 p_module_type               IN     VARCHAR2                       ,
 x_return_status                OUT NOCOPY VARCHAR2                       ,
 x_msg_count                    OUT NOCOPY NUMBER                         ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
CURSOR lookup_code_info(c_lookup_type VARCHAR2,
                        c_lookup_code VARCHAR2)
 IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_type = c_lookup_type
   AND lookup_code = c_lookup_code
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);
-- To retrieve lookup code
CURSOR lookup_code_value(c_lookup_type VARCHAR2,
                         c_meaning VARCHAR2)
 IS
 SELECT lookup_code
    FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_type = c_lookup_type
    AND meaning     = c_meaning
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

 l_api_name     CONSTANT VARCHAR2(30) := 'MODIFY_DOC_TYPE_ASSOC';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_doc_type_code         VARCHAR2(30);
 l_doc_sub_type_code     VARCHAR2(30);
 l_doc_type              VARCHAR2(30)  := 'AHL_DOC_TYPE';
 l_sub_type              VARCHAR2(30)  := 'AHL_DOC_SUB_TYPE';
 l_doc_type_assoc_tbl    AHL_DI_PRO_TYPE_ASO_PVT.doc_type_assoc_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;



BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT modify_doc_type_assoc;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_pro_type_aso_pub.Modify Doc Type','+DOCTY+');

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
   --Start of API Body
   IF p_x_doc_type_assoc_tbl.count > 0
   THEN
     FOR i IN p_x_doc_type_assoc_tbl.FIRST..p_x_doc_type_assoc_tbl.LAST
     LOOP
       -- If module type is 'JSP' then make it null
       IF (p_module_type = 'JSP') THEN
          p_x_doc_type_assoc_tbl(i).doc_type_desc := null;
          p_x_doc_type_assoc_tbl(i).doc_sub_type_code := null;
       END IF;
       -- For Doc Type Code
       IF p_x_doc_type_assoc_tbl(i).doc_type_code IS NOT NULL
         THEN
           OPEN lookup_code_info(l_doc_type,
                                  p_x_doc_type_assoc_tbl(i).doc_type_code);
           FETCH lookup_code_info INTO l_doc_type_code;
           IF lookup_code_info%NOTFOUND
           THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
           ELSE
           l_doc_type_assoc_tbl(i).doc_type_code := l_doc_type_code;
           END IF;
           CLOSE lookup_code_info;
          -- Code is missing
         ELSE
           l_doc_type_assoc_tbl(i).doc_type_code := p_x_doc_type_assoc_tbl(i).doc_type_code;
        END IF;

        --For Doc Sub Type
        IF p_x_doc_type_assoc_tbl(i).doc_sub_type_desc IS NOT NULL
          THEN
            OPEN lookup_code_value(l_sub_type,
                                   p_x_doc_type_assoc_tbl(i).doc_sub_type_desc);
            FETCH lookup_code_value INTO l_doc_sub_type_code;
            IF lookup_code_value%NOTFOUND
            THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUB_CODE_NOT_EXIST');
             FND_MESSAGE.SET_TOKEN('SUBTYPE',p_x_doc_type_assoc_tbl(i).doc_sub_type_desc);
             FND_MSG_PUB.ADD;
            ELSE
            l_doc_type_assoc_tbl(i).doc_sub_type_code := l_doc_sub_type_code;
            END IF;
            CLOSE lookup_code_value;
            -- If Sub type desc missing
         ELSIF p_x_doc_type_assoc_tbl(i).doc_sub_type_code IS NOT NULL
             THEN
            l_doc_type_assoc_tbl(i).doc_sub_type_code := p_x_doc_type_assoc_tbl(i).doc_sub_type_code;
        ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUB_TYPE_CODE_NULL');
            FND_MSG_PUB.ADD;
        END IF;
        --
        l_doc_type_assoc_tbl(i).document_sub_type_id := p_x_doc_type_assoc_tbl(i).document_sub_type_id;
        l_doc_type_assoc_tbl(i).attribute_category   := p_x_doc_type_assoc_tbl(i).attribute_category;
        l_doc_type_assoc_tbl(i).attribute1           := p_x_doc_type_assoc_tbl(i).attribute1;
        l_doc_type_assoc_tbl(i).attribute2           := p_x_doc_type_assoc_tbl(i).attribute2;
        l_doc_type_assoc_tbl(i).attribute3           := p_x_doc_type_assoc_tbl(i).attribute3;
        l_doc_type_assoc_tbl(i).attribute4           := p_x_doc_type_assoc_tbl(i).attribute4;
        l_doc_type_assoc_tbl(i).attribute5           := p_x_doc_type_assoc_tbl(i).attribute5;
        l_doc_type_assoc_tbl(i).attribute6           := p_x_doc_type_assoc_tbl(i).attribute6;
        l_doc_type_assoc_tbl(i).attribute7           := p_x_doc_type_assoc_tbl(i).attribute7;
        l_doc_type_assoc_tbl(i).attribute8           := p_x_doc_type_assoc_tbl(i).attribute8;
        l_doc_type_assoc_tbl(i).attribute9           := p_x_doc_type_assoc_tbl(i).attribute9;
        l_doc_type_assoc_tbl(i).attribute10          := p_x_doc_type_assoc_tbl(i).attribute10;
        l_doc_type_assoc_tbl(i).attribute11          := p_x_doc_type_assoc_tbl(i).attribute11;
        l_doc_type_assoc_tbl(i).attribute12          := p_x_doc_type_assoc_tbl(i).attribute12;
        l_doc_type_assoc_tbl(i).attribute13          := p_x_doc_type_assoc_tbl(i).attribute13;
        l_doc_type_assoc_tbl(i).attribute14          := p_x_doc_type_assoc_tbl(i).attribute14;
        l_doc_type_assoc_tbl(i).attribute15          := p_x_doc_type_assoc_tbl(i).attribute15;
        l_doc_type_assoc_tbl(i).delete_flag          := p_x_doc_type_assoc_tbl(i).delete_flag;
        l_doc_type_assoc_tbl(i).object_version_number := p_x_doc_type_assoc_tbl(i).object_version_number;
   --Standard check for messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
 END LOOP;
END IF;



/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_PRE     */
/*                 AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_PRE     */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','MODIFY_DOC_TYPE_ASSOC',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_PRE');

	END IF;


            AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_PRE(
			p_x_doc_type_assoc_tbl =>	l_doc_type_assoc_tbl    ,
			X_RETURN_STATUS        	=>	l_return_status        ,
			X_MSG_COUNT            	=>	l_msg_count            ,
			X_MSG_DATA             	=>	l_msg_data             );

IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_PRE');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;



END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','MODIFY_DOC_TYPE_ASSOC',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_PRE');

	END IF;

            AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_PRE(
			p_x_doc_type_assoc_tbl =>	l_doc_type_assoc_tbl    ,
			X_RETURN_STATUS        	=>	l_return_status        ,
			X_MSG_COUNT            	=>	l_msg_count            ,
			X_MSG_DATA             	=>	l_msg_data             );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_PRE');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 10 2001                        */
/*---------------------------------------------------------*/



  -- Call the Private API
   AHL_DI_PRO_TYPE_ASO_PVT.MODIFY_DOC_TYPE_ASSOC
       (
        p_api_version          => 1.0,
        p_init_msg_list        => l_init_msg_list,
        p_commit               => p_commit,
        p_validate_only        => p_validate_only,
        p_validation_level     => p_validation_level,
        p_x_doc_type_assoc_tbl => l_doc_type_assoc_tbl,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data
        );

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_POST    */
/*                 AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_POST    */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','MODIFY_DOC_TYPE_ASSOC',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_POST');

	END IF;

            AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_POST(

			 p_doc_type_assoc_tbl  	=>	l_doc_type_assoc_tbl    ,
			X_RETURN_STATUS        	=>	l_return_status        ,
			X_MSG_COUNT            	=>	l_msg_count            ,
			X_MSG_DATA             	=>	l_msg_data             );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_VUHK.MODIFY_DOC_TYPE_ASSOC_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_PRO_TYPE_ASO_PUB','MODIFY_DOC_TYPE_ASSOC',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_POST');

	END IF;

            AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_POST(
			p_doc_type_assoc_tbl  	=>	l_doc_type_assoc_tbl    ,
			X_RETURN_STATUS        	=>	l_return_status        ,
			X_MSG_COUNT            	=>	l_msg_count            ,
			X_MSG_DATA             	=>	l_msg_data             );

IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_PRO_TYPE_ASO_CUHK.MODIFY_DOC_TYPE_ASSOC_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/




   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Modify Doc Type','+DOCTY+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Modify Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Modify Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_PRO_TYPE_ASO_PUB',
                            p_procedure_name  =>  'MODIFY_DOC_TYPE_ASSOC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pub.Modify Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_DOC_TYPE_ASSOC;

END AHL_DI_PRO_TYPE_ASO_PUB;


/
