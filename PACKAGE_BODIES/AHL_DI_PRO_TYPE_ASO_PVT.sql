--------------------------------------------------------
--  DDL for Package Body AHL_DI_PRO_TYPE_ASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_PRO_TYPE_ASO_PVT" AS
/* $Header: AHLVPTAB.pls 115.28 2003/08/26 12:15:44 rroy noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_PRO_TYPE_ASO_PVT';
-- Validates the Doc Type associations

/*-----------------------------------------------------------*/
/* procedure name: validate_doc_type_assoc(private procedure)*/
/* description :  Validation checks for before inserting     */
/*                new record as well before modification     */
/*                takes place                                */
/*-----------------------------------------------------------*/
G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE VALIDATE_DOC_TYPE_ASSOC
(
 P_DOCUMENT_SUB_TYPE_ID    IN NUMBER    ,
 P_DOC_TYPE_CODE           IN VARCHAR2  ,
 P_DOC_SUB_TYPE_CODE       IN VARCHAR2  ,
 P_DELETE_FLAG             IN VARCHAR2  := 'N')
IS

-- Cursor to retrieve the doc type code from fnd lookups table
 CURSOR get_doc_type_code(c_doc_type_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUPS
  WHERE lookup_code = c_doc_type_code
    AND lookup_type = 'AHL_DOC_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

-- Cursor to retrieve the doc sub type code from fnd lookups
 CURSOR get_doc_sub_type_code(c_doc_sub_type_code VARCHAR2)
  IS
 SELECT lookup_code,meaning
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_doc_sub_type_code
    AND lookup_type = 'AHL_DOC_SUB_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

-- Cursor to retrieve the exisiting subscription record from base table
 CURSOR get_doc_sub_type_rec_info (c_document_sub_type_id NUMBER)
  IS
 SELECT doc_type_code,
        doc_sub_type_code
   FROM AHL_DOCUMENT_SUB_TYPES
  WHERE document_sub_type_id = c_document_sub_type_id;

-- Cursor is used to check for duplicate record
 CURSOR dup_rec(c_doc_type_code  VARCHAR2,
                c_doc_sub_type_code VARCHAR2)

  IS
 SELECT 'X'
   FROM AHL_DOCUMENT_SUB_TYPES
  WHERE doc_type_code  = c_doc_type_code
    AND doc_sub_type_code = c_doc_sub_type_code;


--
  l_api_name       CONSTANT VARCHAR2(30) := 'VALIDATE_DOC_TYPE_ASSOC';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_dummy                   VARCHAR2(2000);
  l_meaning                 VARCHAR2(80);
  l_document_sub_type_id    NUMBER;
  l_doc_type_code           VARCHAR2(30);
  l_doc_sub_type_code       VARCHAR2(30);

BEGIN
   -- when the action is insert or update validations should be done
   IF p_delete_flag  <> 'Y'
   THEN
     IF p_document_sub_type_id IS NOT NULL
     THEN
        OPEN get_doc_sub_type_rec_info (p_document_sub_type_id);
        FETCH get_doc_sub_type_rec_info INTO l_doc_type_code, l_doc_sub_type_code;
        CLOSE get_doc_sub_type_rec_info;
     END IF;
     --
     IF p_doc_type_code IS NOT NULL
     THEN
         l_doc_type_code := p_doc_type_code;
     END IF;
     --
     IF p_doc_sub_type_code IS NOT NULL
     THEN
         l_doc_sub_type_code := p_doc_sub_type_code;
     END IF;
     --This condition checks for doc type code, is null
     IF (p_document_sub_type_id IS NULL  AND
         p_doc_type_code IS NULL )   OR

         (p_document_sub_type_id IS NOT NULL
         AND l_doc_type_code IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- This condition checks for doc sub type code
     IF (p_document_sub_type_id IS NULL AND
        p_doc_sub_type_code IS NULL)   OR

        (p_document_sub_type_id IS NOT NULL
        AND l_doc_sub_type_code IS NULL)

     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUB_TYPE_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- This condiiton checks for existence of Doc Type code in fnd lookups
     IF p_doc_type_code IS NOT NULL
     THEN
        OPEN get_doc_type_code(p_doc_type_code);
        FETCH get_doc_type_code INTO l_dummy;
        IF get_doc_type_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_doc_type_code;
      END IF;
      -- This condition checks for existence of Doc Sub Type code in fnd lookups
      IF p_doc_sub_type_code IS NOT NULL
      THEN
         OPEN get_doc_sub_type_code(p_doc_sub_type_code);
         FETCH get_doc_sub_type_code INTO l_dummy,l_meaning;
         IF get_doc_sub_type_code%NOTFOUND
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCSUBT_COD_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE get_doc_sub_type_code;
      END IF;
      --Checks for Duplicate Record
      -- For Bug No:2423646
/*         OPEN dup_rec(l_doc_type_code ,  l_doc_sub_type_code );
         FETCH dup_rec INTO l_dummy;
            IF dup_rec%FOUND THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCSUB_DUP_RECORD');
            FND_MESSAGE.SET_TOKEN('DUPRECORD',l_meaning);
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE dup_rec;
*/
 END IF;

END VALIDATE_DOC_TYPE_ASSOC;
/*-------------------------------------------------------*/
/* procedure name: delete_doc_type_assoc                 */
/* description :Removes record from doc title assos table*/
/*               only if that associate type doesnt exist*/
/*               in documents table                      */
/*-------------------------------------------------------*/

/*
Commented by Senthil on 27 June 2002
The delete code is incorporated in modify_doc_type_assoc
so that a array of update and delete error messages can be formed.

PROCEDURE DELETE_DOC_TYPE_ASSOC
(
 p_api_version               IN     NUMBER    := 1.0               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_doc_type_assoc_tbl        IN     doc_type_assoc_tbl               ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS
--Used to retrive the existing record
CURSOR get_doc_sub_rec_info(c_document_sub_type_id  NUMBER)
 IS
SELECT ROWID,
       doc_type_code,
       doc_sub_type_code,
       object_version_number
  FROM AHL_DOCUMENT_SUB_TYPES
 WHERE document_sub_type_id = c_document_sub_type_id
   FOR UPDATE OF object_version_number NOWAIT;
-- Used to check the associate type exists
CURSOR Check_Doc_Record(c_doc_type_code VARCHAR2,
                        c_doc_sub_type_code VARCHAR2)
 IS
SELECT 'X'
  FROM AHL_DOCUMENTS_B
 WHERE doc_type_code               = c_doc_type_code
   AND nvl(doc_sub_type_code,'x')  = c_doc_sub_type_code;

-- Cursor to retrieve the doc sub type code from fnd lookups
 CURSOR get_doc_sub_type_code(c_doc_sub_type_code VARCHAR2)
  IS
 SELECT lookup_code,meaning
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_doc_sub_type_code
    AND lookup_type = 'AHL_DOC_SUB_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

--
l_api_name     CONSTANT  VARCHAR2(30) := 'DELETE_DOC_TYPE_ASSOC';
l_api_version  CONSTANT  NUMBER       := 1.0;
l_msg_count              NUMBER;
l_rowid                  ROWID;
l_dummy                  VARCHAR2(2000);
l_doc_type_code          VARCHAR2(30);
l_doc_sub_type_code      VARCHAR2(30);
l_object_version_number  NUMBER;
l_meaning                VARCHAR2(80);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT delete_doc_type_assoc;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_pro_type_aso_pvt.Delete Doc Type','+DOCTY+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
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
   FOR i IN p_doc_type_assoc_tbl.FIRST..p_doc_type_assoc_tbl.LAST
     LOOP

    IF p_doc_type_assoc_tbl(i).document_sub_type_id IS NOT NULL AND
        p_doc_type_assoc_tbl(i).delete_flag = 'Y'

    THEN
   --Checks for weather the exists or not
   OPEN get_doc_sub_rec_info(p_doc_type_assoc_tbl(i).document_sub_type_id);
   FETCH get_doc_sub_rec_info INTO l_rowid,
                                   l_doc_type_code,
                                   l_doc_sub_type_code,
                                   l_object_version_number;
   IF (get_doc_sub_rec_info%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCSUB_REC_NOT_FOUND');
       FND_MSG_PUB.ADD;
   END IF;
   CLOSE get_doc_sub_rec_info;

   -- Check for version number
   IF (l_object_version_number <> p_doc_type_assoc_tbl(i).object_version_number)
       THEN
              FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBTYPE_REC_CHANGED');
              FND_MESSAGE.SET_TOKEN('SUBTYPE',initcap(l_doc_sub_type_code));

       FND_MSG_PUB.ADD;
   END IF;

   -- Check for association type Exists in Documents table
   IF p_doc_type_assoc_tbl(i).document_sub_type_id IS NOT NULL
   THEN
     OPEN Check_Doc_Record(l_doc_type_code,l_doc_sub_type_code);
     FETCH Check_Doc_Record INTO l_dummy;
     IF Check_Doc_Record%FOUND
     THEN
       OPEN get_doc_sub_type_code(l_doc_sub_type_code);
       FETCH get_doc_sub_type_code INTO l_dummy,l_meaning;
       CLOSE get_doc_sub_type_code;


--       FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REC_EXISTS');
--       FND_MESSAGE.SEt_TOKEN('SUBTYPNAME',l_meaning);

--       FND_MSG_PUB.ADD;


     CLOSE Check_Doc_Record;
     ELSE
     CLOSE Check_Doc_Record;
     END IF;
   END IF;


   -- Delete the record from document subtypes table
   DELETE FROM  AHL_DOCUMENT_SUB_TYPES
         WHERE ROWID = l_rowid;
   END IF;
  END LOOP;

   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  --Standard check for commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT;
  END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private api Delete Doc Type','+DOCTY+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Delete Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Delete Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO delete_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_PRO_TYPE_ASO_PVT',
                            p_procedure_name  =>  'DELETE_DOC_TYPE_ASSOC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Delete Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END DELETE_DOC_TYPE_ASSOC;
*/
/*------------------------------------------------------*/
/* procedure name: create_doc_type_assoc                */
/* description :  Creates new association record        */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_DOC_TYPE_ASSOC
(
 p_api_version               IN     NUMBER    :=  1.0            ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl      IN OUT NOCOPY doc_type_assoc_tbl    ,
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS
-- Cursor is used to check for duplicate record
 CURSOR dup_rec(c_doc_type_code  VARCHAR2,
                c_doc_sub_type_code VARCHAR2)
  IS
 SELECT 'x'
   FROM AHL_DOCUMENT_SUB_TYPES
  WHERE doc_type_code  = c_doc_type_code
    AND doc_sub_type_code = c_doc_sub_type_code;

-- Cursor to retrieve the doc sub type code from fnd lookups
 CURSOR get_doc_sub_type_code(c_doc_sub_type_code VARCHAR2)
  IS
 SELECT lookup_code,meaning
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_doc_sub_type_code
    AND lookup_type = 'AHL_DOC_SUB_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

--
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_DOC_TYPE_ASSOC';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_dummy                  VARCHAR2(2000);
 l_rowid                 ROWID;
 l_meaning                 VARCHAR2(80);
 l_document_sub_type_id  NUMBER;
 l_doc_type_assoc_info   doc_type_assoc_rec;
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
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_pro_type_aso_pvt.Create Doc Type','+DOCTY+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
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
        VALIDATE_DOC_TYPE_ASSOC
        (
         p_document_sub_type_id => p_x_doc_type_assoc_tbl(i).document_sub_type_id,
         p_doc_type_code        => p_x_doc_type_assoc_tbl(i).doc_type_code,
         p_doc_sub_type_code    => p_x_doc_type_assoc_tbl(i).doc_sub_type_code,
         p_delete_flag          => p_x_doc_type_assoc_tbl(i).delete_flag);
     END LOOP;
    --Standard check for count messages
    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN p_x_doc_type_assoc_tbl.FIRST..p_x_doc_type_assoc_tbl.LAST
    LOOP
      IF (p_x_doc_type_assoc_tbl(i).document_sub_type_id IS NULL)
      THEN
         -- These conditions are required for optional fields, Frequency code
            l_doc_type_assoc_info.attribute_category := p_x_doc_type_assoc_tbl(i).attribute_category;
            l_doc_type_assoc_info.attribute1 := p_x_doc_type_assoc_tbl(i).attribute1;
            l_doc_type_assoc_info.attribute2 := p_x_doc_type_assoc_tbl(i).attribute2;
            l_doc_type_assoc_info.attribute3 := p_x_doc_type_assoc_tbl(i).attribute3;
            l_doc_type_assoc_info.attribute4 := p_x_doc_type_assoc_tbl(i).attribute4;
            l_doc_type_assoc_info.attribute5 := p_x_doc_type_assoc_tbl(i).attribute5;
            l_doc_type_assoc_info.attribute6 := p_x_doc_type_assoc_tbl(i).attribute6;
            l_doc_type_assoc_info.attribute7 := p_x_doc_type_assoc_tbl(i).attribute7;
            l_doc_type_assoc_info.attribute8 := p_x_doc_type_assoc_tbl(i).attribute8;
            l_doc_type_assoc_info.attribute9 := p_x_doc_type_assoc_tbl(i).attribute9;
            l_doc_type_assoc_info.attribute10 := p_x_doc_type_assoc_tbl(i).attribute10;
            l_doc_type_assoc_info.attribute11 := p_x_doc_type_assoc_tbl(i).attribute11;
            l_doc_type_assoc_info.attribute12 := p_x_doc_type_assoc_tbl(i).attribute12;
            l_doc_type_assoc_info.attribute13 := p_x_doc_type_assoc_tbl(i).attribute13;
            l_doc_type_assoc_info.attribute14 := p_x_doc_type_assoc_tbl(i).attribute14;
            l_doc_type_assoc_info.attribute15 := p_x_doc_type_assoc_tbl(i).attribute15;
         --Check for duplicate records
         OPEN dup_rec(p_x_doc_type_assoc_tbl(i).doc_type_code ,
                      p_x_doc_type_assoc_tbl(i).doc_sub_type_code );
         FETCH dup_rec INTO l_dummy;
            IF dup_rec%FOUND THEN
            OPEN get_doc_sub_type_code(p_x_doc_type_assoc_tbl(i).doc_sub_type_code);
            FETCH get_doc_sub_type_code INTO l_dummy,l_meaning;
            CLOSE get_doc_sub_type_code ;
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCSUB_DUP_RECORD');
            FND_MESSAGE.SET_TOKEN('DUPRECORD',l_meaning);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE dup_rec;
         --
    -- Gets the sequence number
    SELECT AHL_DOCUMENT_SUB_TYPES_S.Nextval INTO
              l_document_sub_type_id from DUAL;
    -- Insert the new record into subscriptions table
    INSERT INTO AHL_DOCUMENT_SUB_TYPES
                (
                 DOCUMENT_SUB_TYPE_ID,
                 DOC_TYPE_CODE,
                 DOC_SUB_TYPE_CODE,
                 OBJECT_VERSION_NUMBER,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN
                )
         VALUES
               (
                l_document_sub_type_id,
                p_x_doc_type_assoc_tbl(i).doc_type_code,
                p_x_doc_type_assoc_tbl(i).doc_sub_type_code,
                1,
                l_doc_type_assoc_info.attribute_category,
                l_doc_type_assoc_info.attribute1,
                l_doc_type_assoc_info.attribute2,
                l_doc_type_assoc_info.attribute3,
                l_doc_type_assoc_info.attribute4,
                l_doc_type_assoc_info.attribute5,
                l_doc_type_assoc_info.attribute6,
                l_doc_type_assoc_info.attribute7,
                l_doc_type_assoc_info.attribute8,
                l_doc_type_assoc_info.attribute9,
                l_doc_type_assoc_info.attribute10,
                l_doc_type_assoc_info.attribute11,
                l_doc_type_assoc_info.attribute12,
                l_doc_type_assoc_info.attribute13,
                l_doc_type_assoc_info.attribute14,
                l_doc_type_assoc_info.attribute15,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id
              );
   p_x_doc_type_assoc_tbl(i).document_sub_type_id := l_document_sub_type_id;
   --Standard check for messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;
 END LOOP;
END IF;
    --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private api Create Doc Type','+DOCTY+');

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
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Create Doc Type','+DOCTY+');


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
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Create Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_PRO_TYPE_ASO_PVT',
                            p_procedure_name  =>  'CREATE_DOC_TYPE_ASSOC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Create Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_DOC_TYPE_ASSOC;
/*------------------------------------------------------*/
/* procedure name: modify_doc_type_assoc                */
/* description :  Update the existing association record*/
/*                and removes the association record    */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE MODIFY_DOC_TYPE_ASSOC
(
 p_api_version              IN      NUMBER    :=  1.0            ,
 p_init_msg_list            IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                   IN      VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only            IN      VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level         IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_doc_type_assoc_tbl     IN  OUT NOCOPY doc_type_assoc_tbl    ,
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
-- Cursor is used to retrieve the record from Document sub types table
CURSOR get_doc_sub_rec_info(c_document_sub_type_id  NUMBER)
 IS
SELECT ROWID ROW_ID,
       doc_type_code,
       doc_sub_type_code,
       object_version_number,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
  FROM AHL_DOCUMENT_SUB_TYPES
 WHERE document_sub_type_id = c_document_sub_type_id
   FOR UPDATE OF object_version_number NOWAIT;

-- Cursor to retrieve the doc sub type code from fnd lookups
 CURSOR get_doc_sub_type_code(c_doc_sub_type_code VARCHAR2)
  IS
 SELECT meaning
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_doc_sub_type_code
    AND lookup_type = 'AHL_DOC_SUB_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);


--Used to retrive the existing record
/*CURSOR get_doc_sub_rec_info(c_document_sub_type_id  NUMBER)
 IS
SELECT ROWID,
       doc_type_code,
       doc_sub_type_code,
       object_version_number
  FROM AHL_DOCUMENT_SUB_TYPES
 WHERE document_sub_type_id = c_document_sub_type_id
   FOR UPDATE OF object_version_number NOWAIT;
   */
-- Used to check the associate type exists
CURSOR Check_Doc_Record(c_doc_type_code VARCHAR2,
                        c_doc_sub_type_code VARCHAR2)
 IS
SELECT 'X'
  FROM AHL_DOCUMENTS_B
 WHERE doc_type_code               = c_doc_type_code
   AND nvl(doc_sub_type_code,'x')  = c_doc_sub_type_code;



l_dummy                  VARCHAR2(2000);
l_doc_type_code          VARCHAR2(30);
l_doc_sub_type_code      VARCHAR2(30);
l_object_version_number  NUMBER;


--
l_api_name     CONSTANT   VARCHAR2(30) := 'MODIFY_DOC_TYPE_ASSOC';
l_api_version  CONSTANT   NUMBER       := 1.0;
l_document_sub_type_id    NUMBER;
l_msg_count               NUMBER;
l_rowid                   ROWID;
l_meaning                 VARCHAR2(80);
l_msg_count_temp          NUMBER(3);
l_doc_type_assoc_info     get_doc_sub_rec_info%ROWTYPE;
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
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_pro_type_aso_pvt.Modify Doc Type','+DOCTY+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
    IF FND_API.to_boolean(p_init_msg_list)
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
    IF p_x_doc_type_assoc_tbl.COUNT > 0
    THEN
        FOR i IN p_x_doc_type_assoc_tbl.FIRST..p_x_doc_type_assoc_tbl.LAST
        LOOP
           VALIDATE_DOC_TYPE_ASSOC
           (
            p_document_sub_type_id => p_x_doc_type_assoc_tbl(i).document_sub_type_id,
            p_doc_type_code        => p_x_doc_type_assoc_tbl(i).doc_type_code,
            p_doc_sub_type_code    => p_x_doc_type_assoc_tbl(i).doc_sub_type_code,
            p_delete_flag          => p_x_doc_type_assoc_tbl(i).delete_flag);
        END LOOP;
        --Standard check for messages
        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        FOR i IN p_x_doc_type_assoc_tbl.FIRST..p_x_doc_type_assoc_tbl.LAST
        LOOP
            OPEN get_doc_sub_rec_info(p_x_doc_type_assoc_tbl(i).document_sub_type_id);
            FETCH get_doc_sub_rec_info INTO l_doc_type_assoc_info;
            CLOSE get_doc_sub_rec_info;
    -- This is a bug fix for  lost update data  when concurrent users are
    -- updating same record...02/05/02
           /*
            IF (l_doc_type_assoc_info.object_version_number <>p_x_doc_type_assoc_tbl(i).object_version_number)
            THEN
           --   FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
           --            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBTYPE_REC_CHANGED');
	   --            FND_MESSAGE.SET_TOKEN('SUBTYPE',initcap(l_doc_sub_type_code));


           -- FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            End IF;
           */

            IF p_x_doc_type_assoc_tbl(i).document_sub_type_id IS NOT NULL
               AND
               p_x_doc_type_assoc_tbl(i).delete_flag <> 'Y'
            THEN
              -- The following conditions compare the new record value with old  record
              -- value, if its different then assign the new value else continue

                 l_doc_type_assoc_info.doc_type_code := p_x_doc_type_assoc_tbl(i).doc_type_code;
              --
                 l_doc_type_assoc_info.doc_sub_type_code := p_x_doc_type_assoc_tbl(i).doc_sub_type_code;
              --
                 l_doc_type_assoc_info.attribute_category := p_x_doc_type_assoc_tbl(i).attribute_category;
              --
                 l_doc_type_assoc_info.attribute1 := p_x_doc_type_assoc_tbl(i).attribute1;
              --
                 l_doc_type_assoc_info.attribute2 := p_x_doc_type_assoc_tbl(i).attribute2;
              --
                 l_doc_type_assoc_info.attribute3 := p_x_doc_type_assoc_tbl(i).attribute3;
              --
                 l_doc_type_assoc_info.attribute3 := p_x_doc_type_assoc_tbl(i).attribute3;
              --
                 l_doc_type_assoc_info.attribute4 := p_x_doc_type_assoc_tbl(i).attribute4;
              --
                 l_doc_type_assoc_info.attribute5 := p_x_doc_type_assoc_tbl(i).attribute5;
              --
                 l_doc_type_assoc_info.attribute6 := p_x_doc_type_assoc_tbl(i).attribute6;
              --
                  l_doc_type_assoc_info.attribute7 := p_x_doc_type_assoc_tbl(i).attribute7;
              --
                 l_doc_type_assoc_info.attribute8 := p_x_doc_type_assoc_tbl(i).attribute8;
              --
                 l_doc_type_assoc_info.attribute9 := p_x_doc_type_assoc_tbl(i).attribute9;
              --
                 l_doc_type_assoc_info.attribute10 := p_x_doc_type_assoc_tbl(i).attribute10;
              --
                 l_doc_type_assoc_info.attribute11 := p_x_doc_type_assoc_tbl(i).attribute11;
              --
                 l_doc_type_assoc_info.attribute12 := p_x_doc_type_assoc_tbl(i).attribute12;
              --
                 l_doc_type_assoc_info.attribute13 := p_x_doc_type_assoc_tbl(i).attribute13;
              --
                 l_doc_type_assoc_info.attribute14 := p_x_doc_type_assoc_tbl(i).attribute14;
              --
                 l_doc_type_assoc_info.attribute15 := p_x_doc_type_assoc_tbl(i).attribute15;

              BEGIN
               --Updates document sub types table
                 UPDATE AHL_DOCUMENT_SUB_TYPES
	             SET doc_type_code         = l_doc_type_assoc_info.doc_type_code,
			doc_sub_type_code     = l_doc_type_assoc_info.doc_sub_type_code,
			object_version_number = l_doc_type_assoc_info.object_version_number+1,
			attribute_category    = l_doc_type_assoc_info.attribute_category,
			attribute1            = l_doc_type_assoc_info.attribute1,
			attribute2            = l_doc_type_assoc_info.attribute2,
			attribute3            = l_doc_type_assoc_info.attribute3,
			attribute4            = l_doc_type_assoc_info.attribute4,
			attribute5            = l_doc_type_assoc_info.attribute5,
			attribute6            = l_doc_type_assoc_info.attribute6,
			attribute7            = l_doc_type_assoc_info.attribute7,
			attribute8            = l_doc_type_assoc_info.attribute8,
			attribute9            = l_doc_type_assoc_info.attribute9,
			attribute10           = l_doc_type_assoc_info.attribute10,
			attribute11           = l_doc_type_assoc_info.attribute11,
			attribute12           = l_doc_type_assoc_info.attribute12,
			attribute13           = l_doc_type_assoc_info.attribute13,
			attribute14           = l_doc_type_assoc_info.attribute14,
			attribute15           = l_doc_type_assoc_info.attribute15,
			last_update_date      = sysdate,
			last_updated_by       = fnd_global.user_id,
			last_update_login     = fnd_global.login_id
                 WHERE  document_sub_type_id  = p_x_doc_type_assoc_tbl(i).document_sub_type_id;
              Exception
                WHEN DUP_VAL_ON_INDEX THEN
                  OPEN get_doc_sub_type_code(l_doc_type_assoc_info.doc_sub_type_code);
                  FETCH get_doc_sub_type_code INTO l_meaning;
                  CLOSE get_doc_sub_type_code;
                  FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCSUB_DUP_RECORD');
                  FND_MESSAGE.SET_TOKEN('DUPRECORD',l_meaning);
                  FND_MSG_PUB.ADD;
              END;

              IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'The error count inside update'||FND_MSG_PUB.count_msg);

	END IF;

           END IF;
           -- Modified by Senthil on 28 June 2002
           -- Incase of delte document sub type record
           IF p_x_doc_type_assoc_tbl(i).document_sub_type_id IS NOT NULL AND
              p_x_doc_type_assoc_tbl(i).delete_flag = 'Y'

           THEN
            IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'documetn sub type id '||p_x_doc_type_assoc_tbl(i).document_sub_type_id);

	END IF;
            --Checks for weather the exists or not
		   OPEN get_doc_sub_rec_info(p_x_doc_type_assoc_tbl(i).document_sub_type_id);
		   FETCH get_doc_sub_rec_info INTO l_doc_type_assoc_info;
		   IF (get_doc_sub_rec_info%NOTFOUND) THEN
		          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBTYPE_REC_CHANGED');
		          FND_MESSAGE.SET_TOKEN('SUBTYPE',initcap(p_x_doc_type_assoc_tbl(i).doc_sub_type_code));
	  	          FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE get_doc_sub_rec_info;

		   -- Check for version number
		   IF (l_object_version_number <>p_x_doc_type_assoc_tbl(i).object_version_number)
		       THEN
	               FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBTYPE_REC_CHANGED');
	               FND_MESSAGE.SET_TOKEN('SUBTYPE',l_doc_sub_type_code);
		   END IF;

		   -- Check for association type Exists in Documents table
		   IF p_x_doc_type_assoc_tbl(i).document_sub_type_id IS NOT NULL
		   THEN
		     OPEN Check_Doc_Record(l_doc_type_assoc_info.doc_type_code,l_doc_type_assoc_info.doc_sub_type_code);
		     FETCH Check_Doc_Record INTO l_dummy;
		     IF Check_Doc_Record%FOUND
		     THEN
		       OPEN get_doc_sub_type_code(l_doc_type_assoc_info.doc_sub_type_code);
		       FETCH get_doc_sub_type_code INTO l_meaning;
		       CLOSE get_doc_sub_type_code;

		       FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REC_EXISTS');
		       FND_MESSAGE.SET_TOKEN('SUBTYPNAME',l_meaning);
		       FND_MSG_PUB.ADD;


		     CLOSE Check_Doc_Record;
		     ELSE
		     CLOSE Check_Doc_Record;
		     END IF;
		   END IF;

		    IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'The error count inside delete'||FND_MSG_PUB.count_msg);

	END IF;
		   IF (NVL(FND_MSG_PUB.count_msg,0) = 0) THEN
		   -- Delete the record from document subtypes table
		   DELETE FROM  AHL_DOCUMENT_SUB_TYPES
			 WHERE ROWID = l_doc_type_assoc_info.ROW_ID;
		   END IF;


/*       DELETE_DOC_TYPE_ASSOC
        (p_api_version      => 1.0               ,
         p_init_msg_list    => FND_API.G_TRUE    ,
         p_commit           => FND_API.G_FALSE   ,
         p_validate_only    => FND_API.G_TRUE    ,
         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         p_doc_type_assoc_tbl =>  p_x_doc_type_assoc_tbl ,
         x_return_status    => x_return_status   ,
         x_msg_count        => x_msg_count       ,
         x_msg_data         => x_msg_data);
*/

                  END IF;
        END LOOP;
      END IF;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'The error count '||FND_MSG_PUB.count_msg);

	END IF;
        --Standard check for messages
        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

  --Standard check for commit
 IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
 END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private api Modify Doc Type','+DOCTY+');

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
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Modify Doc Type','+DOCTY+');


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
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Modify Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_doc_type_assoc;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_PRO_TYPE_ASO_PVT',
                            p_procedure_name  =>  'MODIFY_DOC_TYPE_ASSOC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_pro_type_aso_pvt.Modify Doc Type','+DOCTY+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_DOC_TYPE_ASSOC;
--
END AHL_DI_PRO_TYPE_ASO_PVT;


/
