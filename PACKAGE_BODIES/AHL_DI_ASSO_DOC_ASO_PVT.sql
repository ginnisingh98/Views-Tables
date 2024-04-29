--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOC_ASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOC_ASO_PVT" AS
/* $Header: AHLVDASB.pls 115.36 2003/08/26 11:52:24 rroy noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_ASSO_DOC_ASO_PVT';
/*---------------------------------------------------------*/
/* procedure name: validate_association(private procedure) */
/* description :  Validation checks for before inserting   */
/*                new record as well before modification   */
/*                takes place                              */
/*---------------------------------------------------------*/

G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE VALIDATE_ASSOCIATION
(
 P_DOC_TITLE_ASSO_ID      IN  NUMBER      ,
 P_DOCUMENT_ID            IN  NUMBER      ,
 P_DOC_REVISION_ID        IN  NUMBER      ,
 P_USE_LATEST_REV_FLAG    IN  VARCHAR2    ,
 P_ASO_OBJECT_TYPE_CODE   IN  VARCHAR2    ,
 P_ASO_OBJECT_ID          IN  NUMBER      ,
 P_DELETE_FLAG            IN  VARCHAR2    := 'N'
)
IS
--Cursor to select document status
CURSOR get_doc_status(c_doc_revision_id NUMBER)
IS
  SELECT REVISION_STATUS_CODE,
         OBSOLETE_DATE
   FROM  AHL_DOC_REVISIONS_B

   WHERE DOC_REVISION_ID = c_doc_revision_id;

--Cursor to retrieve Aso Object Type Code
CURSOR get_aso_obj_type_code(c_aso_object_type_code VARCHAR2)
IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_code = c_aso_object_type_code
   AND lookup_type = 'AHL_OBJECT_TYPE'
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

--Cursor to retrive the doc title record
CURSOR get_doc_assos_rec_b_info (c_doc_title_asso_id NUMBER)
IS
SELECT document_id,
       doc_revision_id,
       use_latest_rev_flag,
       aso_object_type_code,
       aso_object_id
  FROM AHL_DOC_TITLE_ASSOS_B
 WHERE doc_title_asso_id = c_doc_title_asso_id;

 -- Used to validate the document id
 CURSOR check_doc_info(c_document_id  NUMBER)

 IS
 SELECT 'X'
  FROM AHL_DOCUMENTS_B
 WHERE document_id  = c_document_id;
--
 CURSOR get_doc_det(c_document_id NUMBER)
  IS
  SELECT document_no
    FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;
--
 CURSOR get_rev_det(c_doc_revision_id NUMBER)
  IS
  SELECT revision_no
  FROM  AHL_DOC_REVISIONS_B
  WHERE DOC_REVISION_ID = c_doc_revision_id;
--
CURSOR get_operation_status(c_operation_id NUMBER)
IS
  SELECT revision_status_code
    FROM ahl_operations_b
   WHERE operation_id = c_operation_id;

CURSOR get_route_status(c_route_id NUMBER)
IS
  SELECT revision_status_code
    FROM ahl_routes_b
   WHERE route_id = c_route_id;


-- Used to check Duplicate Record
CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER)

IS
SELECT 'X'
  FROM AHL_DOC_TITLE_ASSOS_B
 WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0);




  l_api_name     CONSTANT  VARCHAR2(30) := 'VALIDATE_ASSOCIATION';
  l_api_version  CONSTANT  NUMBER       := 1.0;
  l_dummy                  VARCHAR2(2000);
  l_doc_title_asso_id      NUMBER;
  l_document_id            NUMBER;
  l_doc_revision_id        NUMBER;
  l_document_no            VARCHAR2(80);
  l_use_latest_rev_flag    VARCHAR2(1);
  l_aso_object_type_code   VARCHAR2(30);
  l_aso_object_id          NUMBER;
  l_status                 VARCHAR2(30);
  l_obsolete_date          DATE;
  l_revision_no            VARCHAR2(80);
BEGIN
   -- When the delte flag is 'YES' means either insert or update
   IF p_delete_flag  <> 'Y'
   THEN
     IF p_doc_title_asso_id IS NOT NULL AND p_doc_title_asso_id <> FND_API.G_MISS_NUM
     THEN
        OPEN get_doc_assos_rec_b_info(p_doc_title_asso_id);
        FETCH get_doc_assos_rec_b_info INTO l_document_id,
                                            l_doc_revision_id,
                                            l_use_latest_rev_flag,
                                            l_aso_object_type_code,
                                            l_aso_object_id;
        CLOSE get_doc_assos_rec_b_info;
     END IF;
     --
     OPEN get_doc_det(p_document_id);
     FETCH get_doc_det INTO l_document_no;
     CLOSE get_doc_det;
    --

    IF p_aso_object_type_code = 'OPERATION' THEN
       OPEN get_operation_status(p_aso_object_id);
       FETCH get_operation_status INTO l_status;
       CLOSE get_operation_status;
       IF l_status <> 'DRAFT' THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_STAT_DRFT_ASO');
        FND_MSG_PUB.ADD;
        RETURN;
       END IF;
    END IF;

    IF p_aso_object_type_code = 'ROUTE' THEN
       OPEN get_route_status(p_aso_object_id);
       FETCH get_route_status INTO l_status;
       CLOSE get_route_status;
       IF l_status <> 'DRAFT' THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROU_STAT_DRFT_ASO');
        FND_MSG_PUB.ADD;
        RETURN;
       END IF;
    END IF;

    IF p_doc_revision_id IS NOT NULL and p_doc_revision_id <> FND_API.G_MISS_NUM
    THEN
       OPEN get_doc_status(p_doc_revision_id);
       FETCH get_doc_status INTO l_status,l_obsolete_date;
       CLOSE get_doc_status;
       --Modified pjha 29-Aug-2002 for bug 2459649: status check has been removed
       --IF l_status <> 'CURRENT' OR l_obsolete_date < sysdate THEN
       IF l_obsolete_date < sysdate THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_RM_DOC_INVALID');
        FND_MESSAGE.SET_TOKEN('RECORD',l_document_no);
        FND_MSG_PUB.ADD;
        RETURN;
       END IF;
    END IF;


    IF p_document_id IS NOT NULL AND p_document_id <> FND_API.G_MISS_NUM
    THEN
        l_document_id := p_document_id;
    END IF;
    --
    IF p_doc_revision_id IS NOT NULL AND p_doc_revision_id <> FND_API.G_MISS_NUM
    THEN
        l_doc_revision_id := p_doc_revision_id;
    END IF;
    --
    IF p_use_latest_rev_flag IS NOT NULL AND p_use_latest_rev_flag <> FND_API.G_MISS_CHAR
    THEN
        l_use_latest_rev_flag := p_use_latest_rev_flag;
    END IF;
    --
    IF p_aso_object_type_code IS NOT NULL AND p_aso_object_type_code <> FND_API.G_MISS_CHAR
    THEN
        l_aso_object_type_code := p_aso_object_type_code;
    END IF;
    --
    IF p_aso_object_id IS NOT NULL AND p_aso_object_id <> FND_API.G_MISS_NUM
    THEN
        l_aso_object_id := p_aso_object_id;
    END IF;
    --
    IF p_doc_title_asso_id = FND_API.G_MISS_NUM THEN
       l_doc_title_asso_id := null;
    ELSE
       l_doc_title_asso_id := p_doc_title_asso_id;
    END IF;
    -- This condition checks for Document Id is Null
    IF ((p_doc_title_asso_id IS NULL OR p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
       (p_document_id IS NULL OR p_document_id = FND_API.G_MISS_NUM))
        OR

       ((p_doc_title_asso_id IS NOT NULL OR p_doc_title_asso_id <> FND_API.G_MISS_NUM)
       AND l_document_id IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- This condition checks for Aso Object Type Code is Null
     IF ((p_doc_title_asso_id IS NULL OR p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_aso_object_type_code IS NULL OR p_aso_object_type_code = FND_API.G_MISS_CHAR))
        OR

        ((p_doc_title_asso_id IS NOT NULL OR p_doc_title_asso_id <> FND_API.G_MISS_NUM)
        AND l_aso_object_type_code IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_TYPE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- This condiiton checks for Aso Object Id Value Is Null
     IF ((p_doc_title_asso_id IS NULL OR p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_aso_object_id IS NULL OR p_aso_object_id = FND_API.G_MISS_NUM))
        OR

        ((p_doc_title_asso_id IS NOT NULL OR p_doc_title_asso_id <> FND_API.G_MISS_NUM)
        AND l_aso_object_id IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;
    --Check for Aso Object Type Code in fnd lookups
    IF p_aso_object_type_code IS NOT NULL AND p_aso_object_type_code <> FND_API.G_MISS_CHAR
    THEN
       OPEN get_aso_obj_type_code(p_aso_object_type_code);
       FETCH get_aso_obj_type_code INTO l_dummy;
       IF get_aso_obj_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYPE_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_aso_obj_type_code;
     END IF;
    -- Validates for existence of document id in ahl documents table
    IF p_document_id IS NOT NULL AND p_document_id <> FND_API.G_MISS_NUM
    THEN
       OPEN Check_doc_info(p_document_id);
       FETCH Check_doc_info INTO l_dummy;
       IF Check_doc_info%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE Check_doc_info;
      END IF;
   --Check for Duplicate Record
   IF p_doc_title_asso_id = FND_API.G_MISS_NUM AND p_aso_object_type_code NOT IN ('PC', 'MC','ROUTE','OPERATION')
   THEN
     OPEN dup_rec(p_aso_object_type_code, l_aso_object_id, l_document_id,
                    p_doc_revision_id);
     FETCH dup_rec INTO l_dummy;
       IF dup_rec%FOUND
       THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
         FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
         FND_MSG_PUB.ADD;
       END IF;
     CLOSE dup_rec;
   END IF;
 END IF;
END VALIDATE_ASSOCIATION;
/*-------------------------------------------------------*/
/* procedure name: delete_association                    */
/* description :Removes the record from associations     */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE DELETE_ASSOCIATION
(
 p_api_version              IN    NUMBER    := 1.0              ,
 p_init_msg_list            IN    VARCHAR2  := FND_API.G_TRUE     ,
 p_commit                   IN    VARCHAR2  := FND_API.G_FALSE    ,
 p_validate_only            IN    VARCHAR2  := FND_API.G_TRUE     ,
 p_validation_level         IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_association_rec          IN    association_rec                 ,
 x_return_status              OUT NOCOPY VARCHAR2                        ,
 x_msg_count                  OUT NOCOPY NUMBER                          ,
 x_msg_data                   OUT NOCOPY VARCHAR2)
IS
--
CURSOR get_doc_assos_rec_b_info(c_doc_title_asso_id  NUMBER)
 IS
SELECT ROWID,
       object_version_number
  FROM AHL_DOC_TITLE_ASSOS_B
 WHERE doc_title_asso_id = c_doc_title_asso_id
   FOR UPDATE OF object_version_number NOWAIT;
 --
l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_ASSOCIATION';
l_api_version  CONSTANT NUMBER       := 1.0;
l_rowid                 ROWID;
l_object_version_number NUMBER;
--
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_association;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pvt.Delete Association','+DOBJASS+');

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
    --
    OPEN get_doc_assos_rec_b_info(p_association_rec.doc_title_asso_id);
    FETCH get_doc_assos_rec_b_info INTO l_rowid,
                                        l_object_version_number;
    IF (get_doc_assos_rec_b_info%NOTFOUND)
    THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_INVALID');
        FND_MSG_PUB.ADD;
    END IF;
    CLOSE get_doc_assos_rec_b_info;

   -- Check for version number
   IF (l_object_version_number <> p_association_rec.object_version_number)
   THEN
       FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_CHANGED');
       FND_MSG_PUB.ADD;
   END IF;
/*-------------------------------------------------------- */
/* procedure name: AHL_DOC_TITLE_ASSOS_PKG.DELETE_ROW      */
/* description   : Added by Senthil to call Table Handler  */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
-- Delete the record from document associations table and association Trans table
	AHL_DOC_TITLE_ASSOS_PKG.DELETE_ROW(
		X_DOC_TITLE_ASSO_ID	=> p_association_rec.doc_title_asso_id
					);
/*
   -- Delete the record from document associations table
      DELETE FROM AHL_DOC_TITLE_ASSOS_B
       WHERE doc_title_asso_id = p_association_rec.doc_title_asso_id;
       --
   -- Delete the record from document associations Trans table
      DELETE FROM AHL_DOC_TITLE_ASSOS_TL
       WHERE doc_title_asso_id = p_association_rec.doc_title_asso_id;
       --
*/
   --Standard check for commit;
   IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT;
  END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private procedure Delete Association','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Delete Association','+DOBJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.

		AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Delete Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO delete_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PVT',
                            p_procedure_name  =>  'DELETE_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Delete Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END DELETE_ASSOCIATION;

/*------------------------------------------------------*/
/* procedure name: create_association                   */
/* description :  Creates new association record        */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_ASSOCIATION
(
 p_api_version                IN     NUMBER    :=  1.0             ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl          IN OUT NOCOPY association_tbl        ,
 x_return_status                 OUT NOCOPY VARCHAR2                      ,
 x_msg_count                     OUT NOCOPY NUMBER                        ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
IS
-- Used to check for duplicate records
CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER)

 IS
SELECT 'X'
  FROM AHL_DOC_TITLE_ASSOS_B
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0);

--adharia check for dup recs in pc and mc only
CURSOR dup_rec_check(c_aso_object_type_code VARCHAR2,
                     c_aso_object_id        NUMBER,
                     c_document_id          NUMBER,
                     c_doc_revision_id      NUMBER,
                     c_chapter  	    VARCHAR2,
	             c_section  	    VARCHAR2,
	             c_subject  	    VARCHAR2,
	             c_page     	    VARCHAR2,
	             c_figure   	    VARCHAR2)

 IS
SELECT 'X'
  FROM AHL_DOC_TITLE_ASSOS_VL
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND nvl(chapter, '$#@1X') = nvl(c_chapter,'$#@1X')
   AND nvl(section, '$#@1X') = nvl(c_section,'$#@1X')
   AND nvl(subject, '$#@1X') = nvl(c_subject,'$#@1X')
   AND nvl(page, '$#@1X') = nvl(c_page,'$#@1X')
   AND nvl(figure, '$#@1X') = nvl(c_figure,'$#@1X');
--
 CURSOR get_doc_num(c_document_id NUMBER)
  IS
  SELECT document_no
    FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;
 --
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_ASSOCIATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER       := 0;
 l_rowid                 ROWID;
 l_dummy                 VARCHAR2(2000);
 l_document_no           VARCHAR2(80);
 l_doc_title_asso_id     NUMBER;
 l_association_info      association_rec;
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
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pvt.Create Association','+DOBJASS+');

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
  IF p_x_association_tbl.COUNT > 0
  THEN
     FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
     LOOP
        VALIDATE_ASSOCIATION
        (
          p_doc_title_asso_id       => p_x_association_tbl(i).doc_title_asso_id,
          p_document_id             => p_x_association_tbl(i).document_id,
          p_doc_revision_id         => p_x_association_tbl(i).doc_revision_id,
          p_use_latest_rev_flag     => p_x_association_tbl(i).use_latest_rev_flag,
          p_aso_object_type_code    => p_x_association_tbl(i).aso_object_type_code,
          p_aso_object_id           => p_x_association_tbl(i).aso_object_id,
          p_delete_flag             => p_x_association_tbl(i).delete_flag
         );
      END LOOP;
   --Standard call to message count
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
   LOOP

        IF NVL(p_x_association_tbl(i).document_id, 0) <> FND_API.G_MISS_NUM
        THEN
           l_association_info.document_id := p_x_association_tbl(i).document_id;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).aso_object_type_code, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.aso_object_type_code := p_x_association_tbl(i).aso_object_type_code;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).aso_object_id, 0) <> FND_API.G_MISS_NUM
        THEN
           l_association_info.aso_object_id := p_x_association_tbl(i).aso_object_id;
        END IF;
        --


      IF  p_x_association_tbl(i).doc_title_asso_id = FND_API.G_MISS_NUM OR p_x_association_tbl(i).doc_title_asso_id IS NULL
      THEN
       --The following conditions are required for optional fields
       IF p_x_association_tbl(i).doc_revision_id = FND_API.G_MISS_NUM
       THEN
          l_association_info.doc_revision_id := null;
       ELSE
          l_association_info.doc_revision_id := p_x_association_tbl(i).doc_revision_id;
       END IF;
       -- If document revision doesnt exist then latest rev flag
       -- is 'YES' else which ever user selects (Default 'NO')
       IF (p_x_association_tbl(i).use_latest_rev_flag = FND_API.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NULL)
       THEN
          l_association_info.use_latest_rev_flag := 'Y';
       ELSIF (p_x_association_tbl(i).use_latest_rev_flag <> FND_API.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NULL)
       THEN
          l_association_info.use_latest_rev_flag := p_x_association_tbl(i).use_latest_rev_flag;
       ELSIF (p_x_association_tbl(i).use_latest_rev_flag <> FND_API.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NOT NULL)
       THEN
          l_association_info.use_latest_rev_flag := p_x_association_tbl(i).use_latest_rev_flag;

        ELSE
          l_association_info.use_latest_rev_flag := 'N';
       END IF;
       --
       IF p_x_association_tbl(i).serial_no = FND_API.G_MISS_CHAR
       THEN
          l_association_info.serial_no := null;
        ELSE
          l_association_info.serial_no := p_x_association_tbl(i).serial_no;
        END IF;
        --
       IF p_x_association_tbl(i).chapter = FND_API.G_MISS_CHAR
       THEN
          l_association_info.chapter := null;
        ELSE

          l_association_info.chapter := p_x_association_tbl(i).chapter;
        END IF;
       --
       IF p_x_association_tbl(i).section = FND_API.G_MISS_CHAR
       THEN
          l_association_info.section := null;
        ELSE
          l_association_info.section := p_x_association_tbl(i).section;
        END IF;
        --
       IF p_x_association_tbl(i).subject = FND_API.G_MISS_CHAR
       THEN
          l_association_info.subject := null;
        ELSE
          l_association_info.subject := p_x_association_tbl(i).subject;
        END IF;
        --
       IF p_x_association_tbl(i).page = FND_API.G_MISS_CHAR
       THEN
          l_association_info.page := null;
        ELSE
          l_association_info.page := p_x_association_tbl(i).page;
        END IF;
        --
       IF p_x_association_tbl(i).figure = FND_API.G_MISS_CHAR
       THEN
          l_association_info.figure := null;
        ELSE
          l_association_info.figure := p_x_association_tbl(i).figure;
        END IF;
        --
       IF p_x_association_tbl(i).note = FND_API.G_MISS_CHAR
       THEN
          l_association_info.note := null;
        ELSE
          l_association_info.note := p_x_association_tbl(i).note;
        END IF;
        --
       IF p_x_association_tbl(i).attribute_category = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute_category := null;
        ELSE
          l_association_info.attribute_category := p_x_association_tbl(i).attribute_category;
        END IF;
        --
       IF p_x_association_tbl(i).attribute1 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute1 := null;
        ELSE
          l_association_info.attribute1 := p_x_association_tbl(i).attribute1;
        END IF;
        --
       IF p_x_association_tbl(i).attribute2 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute2 := null;
        ELSE
          l_association_info.attribute2 := p_x_association_tbl(i).attribute2;
        END IF;
        --
       IF p_x_association_tbl(i).attribute3 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute3 := null;
        ELSE
          l_association_info.attribute3 := p_x_association_tbl(i).attribute3;
        END IF;
        --
       IF p_x_association_tbl(i).attribute4 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute4 := null;
        ELSE
          l_association_info.attribute4 := p_x_association_tbl(i).attribute4;
        END IF;
        --
       IF p_x_association_tbl(i).attribute5 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute5 := null;
        ELSE
          l_association_info.attribute5 := p_x_association_tbl(i).attribute5;
        END IF;
        --
       IF p_x_association_tbl(i).attribute6 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute6 := null;
        ELSE
          l_association_info.attribute6 := p_x_association_tbl(i).attribute6;
        END IF;
        --
       IF p_x_association_tbl(i).attribute7 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute7 := null;
        ELSE
          l_association_info.attribute7 := p_x_association_tbl(i).attribute7;
        END IF;
        --
       IF p_x_association_tbl(i).attribute8 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute8 := null;
        ELSE
          l_association_info.attribute8 := p_x_association_tbl(i).attribute8;
        END IF;
        --
       IF p_x_association_tbl(i).attribute9 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute9 := null;
        ELSE
          l_association_info.attribute9 := p_x_association_tbl(i).attribute9;
        END IF;
        --
       IF p_x_association_tbl(i).attribute10 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute10 := null;
        ELSE
          l_association_info.attribute10 := p_x_association_tbl(i).attribute10;
        END IF;
        --
       IF p_x_association_tbl(i).attribute11 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute11 := null;
        ELSE
          l_association_info.attribute11 := p_x_association_tbl(i).attribute11;
        END IF;
        --
       IF p_x_association_tbl(i).attribute12 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute12 := null;
        ELSE
          l_association_info.attribute12 := p_x_association_tbl(i).attribute12;
        END IF;
        --
       IF p_x_association_tbl(i).attribute13 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute13 := null;
        ELSE
          l_association_info.attribute13 := p_x_association_tbl(i).attribute13;
        END IF;
        --
       IF p_x_association_tbl(i).attribute14 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute14 := null;
        ELSE
          l_association_info.attribute14 := p_x_association_tbl(i).attribute14;
        END IF;
        --
       IF p_x_association_tbl(i).attribute15 = FND_API.G_MISS_CHAR
       THEN
          l_association_info.attribute15 := null;
        ELSE
          l_association_info.attribute15 := p_x_association_tbl(i).attribute15;
        END IF;
        --
        -- This check is required for when same record is passed twice
	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;

	END IF;

        IF p_x_association_tbl(i).aso_object_type_code NOT IN ( 'PC', 'MC','ROUTE','OPERATION' )
        THEN


        OPEN dup_rec( p_x_association_tbl(i).aso_object_type_code,
                      p_x_association_tbl(i).aso_object_id,
                      p_x_association_tbl(i).document_id,
                      p_x_association_tbl(i).doc_revision_id);
        FETCH dup_rec INTO l_dummy;
        IF dup_rec%FOUND  THEN
           OPEN get_doc_num(p_x_association_tbl(i).document_id);
	   FETCH get_doc_num INTO l_document_no;
	   CLOSE get_doc_num;


           FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
           FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE dup_rec;
         ELSE
         OPEN dup_rec_check(    c_aso_object_type_code => l_association_info.aso_object_type_code,
			        c_aso_object_id        => l_association_info.aso_object_id,
			        c_document_id          => l_association_info.document_id,
			        c_doc_revision_id      => l_association_info.doc_revision_id,
			        c_chapter  	       => l_association_info.chapter,
			        c_section  	       => l_association_info.section,
			        c_subject  	       => l_association_info.subject,
			        c_page     	       => l_association_info.page,
			        c_figure   	       => l_association_info.figure);
	        FETCH dup_rec_check INTO l_dummy;
		IF dup_rec_check%FOUND  THEN
		   OPEN get_doc_num(p_x_association_tbl(i).document_id);
		   FETCH get_doc_num INTO l_document_no;
		   CLOSE get_doc_num;



	           IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('DCAB -- DUP CHECK FOUND ');

	           END IF;
		  FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
		  FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
		 END IF;
            CLOSE dup_rec_check;
        END IF;
    --Gets the sequence Number
    SELECT AHL_DOC_TITLE_ASSOS_B_S.Nextval INTO
           l_doc_title_asso_id from DUAL;

/*-------------------------------------------------------- */
/* procedure name: AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW      */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
   --Insert the record into doc title assos table and tranlations table
	AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW(
		X_ROWID                        	=>	l_rowid,
		X_DOC_TITLE_ASSO_ID            	=>	l_doc_title_asso_id,
		X_SERIAL_NO                    	=>	l_association_info.serial_no,
		X_ATTRIBUTE_CATEGORY           	=>	l_association_info.attribute_category,
		X_ATTRIBUTE1                   	=>	l_association_info.attribute1,
		X_ATTRIBUTE2                   	=>	l_association_info.attribute2,
		X_ATTRIBUTE3                   	=>	l_association_info.attribute3,
		X_ATTRIBUTE4                   	=>	l_association_info.attribute4,
		X_ATTRIBUTE5                   	=>	l_association_info.attribute5,
		X_ATTRIBUTE6                   	=>	l_association_info.attribute6,
		X_ATTRIBUTE7                   	=>	l_association_info.attribute7,
		X_ATTRIBUTE8                   	=>	l_association_info.attribute8,
		X_ATTRIBUTE9                   	=>	l_association_info.attribute9,
		X_ATTRIBUTE10                  	=>	l_association_info.attribute10,
		X_ATTRIBUTE11                  	=>	l_association_info.attribute11,
		X_ATTRIBUTE12                  	=>	l_association_info.attribute12,
		X_ATTRIBUTE13                  	=>	l_association_info.attribute13,
		X_ATTRIBUTE14                  	=>	l_association_info.attribute14,
		X_ATTRIBUTE15                  	=>	l_association_info.attribute15,
		X_ASO_OBJECT_TYPE_CODE         	=>	p_x_association_tbl(i).aso_object_type_code,
        	X_SOURCE_REF_CODE              =>       NULL,
		X_ASO_OBJECT_ID                	=>	p_x_association_tbl(i).aso_object_id,
		X_DOCUMENT_ID                  	=>	p_x_association_tbl(i).document_id,
		X_USE_LATEST_REV_FLAG          	=>	l_association_info.use_latest_rev_flag,
		X_DOC_REVISION_ID              	=>	l_association_info.doc_revision_id,
		X_OBJECT_VERSION_NUMBER        	=>	1,
		X_CHAPTER                      	=>	l_association_info.chapter,
		X_SECTION                      	=>	l_association_info.section,
		X_SUBJECT                      	=>	l_association_info.subject,
		X_FIGURE                       	=>	l_association_info.figure,
		X_PAGE                         	=>	l_association_info.page,
		X_NOTE                         	=>	l_association_info.note,
		X_CREATION_DATE                	=>	sysdate,
		X_CREATED_BY                   	=>	fnd_global.user_id,
		X_LAST_UPDATE_DATE             	=>	sysdate,
		X_LAST_UPDATED_BY              	=>	fnd_global.user_id,
		X_LAST_UPDATE_LOGIN            	=>	fnd_global.login_id);
     --Assign the doc title asso id,object version number
     p_x_association_tbl(i).doc_title_asso_id     := l_doc_title_asso_id;
     p_x_association_tbl(i).object_version_number := 1;
   --Standard check to count messages
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
		  AHL_DEBUG_PUB.debug( 'End of private api Create Association','+DOBJASS+');

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
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Create Association','+DOBJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Create Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PVT',
                            p_procedure_name  =>  'CREATE_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Create Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_ASSOCIATION;
/*------------------------------------------------------*/
/* procedure name: modify_association                   */
/* description :  Update the existing association record*/
/*                and removes the association record    */
/*                for an associated document            */
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
 x_return_status                OUT NOCOPY VARCHAR2                     ,
 x_msg_count                    OUT NOCOPY NUMBER                       ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
-- To get the existing record
CURSOR get_doc_assos_rec_b_info(c_doc_title_asso_id  NUMBER)
 IS
SELECT ROWID,
       document_id,
       doc_revision_id,
       use_latest_rev_flag,
       aso_object_type_code,
       aso_object_id,
       serial_no,
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
  FROM AHL_DOC_TITLE_ASSOS_B AAB
 WHERE doc_title_asso_id = c_doc_title_asso_id
   FOR UPDATE OF object_version_number NOWAIT;

-- Cursor to retrieve the existing record from trans table
CURSOR get_doc_assos_rec_tl_info(c_doc_title_asso_id NUMBER)
 IS
SELECT chapter,
       section,
       subject,
       page,
       figure,
       note
  FROM AHL_DOC_TITLE_ASSOS_TL
 WHERE doc_title_asso_id = c_doc_title_asso_id
   FOR UPDATE OF doc_title_asso_id NOWAIT;
-- Used to check for duplicate records
CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER)

 IS
SELECT doc_title_asso_id
  FROM AHL_DOC_TITLE_ASSOS_B
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND doc_revision_id = c_doc_revision_id;
-- Used to check for duplicate records
--adharia check for dup recs in pc and mc only
CURSOR dup_rec_check(c_doc_title_asso_id NUMBER,
                     c_aso_object_type_code VARCHAR2,
                     c_aso_object_id        NUMBER,
                     c_document_id          NUMBER,
                     c_doc_revision_id      NUMBER,
                     c_chapter  VARCHAR2,
                     c_section  VARCHAR2,
	             c_subject  VARCHAR2,
	             c_page     VARCHAR2,
	             c_figure   VARCHAR2)

 IS
SELECT doc_title_asso_id
  FROM AHL_DOC_TITLE_ASSOS_VL
  WHERE doc_title_asso_id <> c_doc_title_asso_id
   AND aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND nvl(chapter, '$#@1X') = nvl(c_chapter,'$#@1X')
   AND nvl(section, '$#@1X') = nvl(c_section,'$#@1X')
   AND nvl(subject, '$#@1X') = nvl(c_subject,'$#@1X')
   AND nvl(page, '$#@1X') = nvl(c_page,'$#@1X')
   AND nvl(figure, '$#@1X') = nvl(c_figure,'$#@1X');
--

CURSOR get_doc_det(c_document_id NUMBER)
  IS
  SELECT document_no
    FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;
--
l_api_name     CONSTANT  VARCHAR2(30) := 'MODIFY_ASSOCIATION';
l_api_version  CONSTANT  NUMBER       := 1.0;

l_document_no           VARCHAR2(80);
l_msg_count              NUMBER;
l_num_rec                NUMBER;
l_rowid                  ROWID;
l_dummy                 VARCHAR2(2000);
l_association_info       get_doc_assos_rec_b_info%ROWTYPE;
l_association_tl_info    get_doc_assos_rec_tl_info%ROWTYPE;
l_doc_title_asso_id      NUMBER;
l_found_flag             VARCHAR2(5)  := 'N';
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
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pvt.Modify Association','+DOBJASS+');

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
    IF p_x_association_tbl.COUNT > 0
    THEN
      FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
      LOOP
       VALIDATE_ASSOCIATION
         (
          p_doc_title_asso_id       => p_x_association_tbl(i).doc_title_asso_id,
          p_document_id             => p_x_association_tbl(i).document_id,
          p_doc_revision_id         => p_x_association_tbl(i).doc_revision_id,
          p_use_latest_rev_flag     => p_x_association_tbl(i).use_latest_rev_flag,
          p_aso_object_type_code    => p_x_association_tbl(i).aso_object_type_code,
          p_aso_object_id           => p_x_association_tbl(i).aso_object_id,
          p_delete_flag             => p_x_association_tbl(i).delete_flag
          );
      END LOOP;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
   LOOP
      --Open the record from base table
      OPEN get_doc_assos_rec_b_info(p_x_association_tbl(i).doc_title_asso_id);
      FETCH get_doc_assos_rec_b_info INTO l_association_info;
      CLOSE get_doc_assos_rec_b_info;
      -- Get the record from trans table
      OPEN get_doc_assos_rec_tl_info(p_x_association_tbl(i).doc_title_asso_id);
      FETCH get_doc_assos_rec_tl_info INTO l_association_tl_info;
      CLOSE get_doc_assos_rec_tl_info;
     -- If the delete flag 'N' i.e UPDATE
     IF p_x_association_tbl(i).doc_title_asso_id IS NOT NULL AND
        p_x_association_tbl(i).delete_flag = 'N'

     THEN
        -- The following conditions compare the new record value with old  record
        -- value, if its different then assign the new value else continue

    -- This is a bug fix for lost  update  concurrent users are
    -- updating same record...02/05/02

    if (l_association_info.object_version_number <>p_x_association_tbl(i).object_version_number)
    then
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;
        IF NVL(p_x_association_tbl(i).document_id, 0) <> FND_API.G_MISS_NUM
        THEN
           l_association_info.document_id := p_x_association_tbl(i).document_id;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).doc_revision_id, 0) <> FND_API.G_MISS_NUM
        THEN
           l_association_info.doc_revision_id := p_x_association_tbl(i).doc_revision_id;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).use_latest_rev_flag, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.use_latest_rev_flag := p_x_association_tbl(i).use_latest_rev_flag;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).aso_object_type_code, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.aso_object_type_code := p_x_association_tbl(i).aso_object_type_code;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).aso_object_id,0) <> FND_API.G_MISS_NUM
        THEN
           l_association_info.aso_object_id := p_x_association_tbl(i).aso_object_id;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).serial_no, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.serial_no := p_x_association_tbl(i).serial_no;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).chapter, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.chapter := p_x_association_tbl(i).chapter;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).section, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.section := p_x_association_tbl(i).section;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).subject, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.subject := p_x_association_tbl(i).subject;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).page, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.page := p_x_association_tbl(i).page;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).figure, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.figure := p_x_association_tbl(i).figure;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).note, 'x') <> FND_API.G_MISS_CHAR
        THEN
           l_association_tl_info.note := p_x_association_tbl(i).note;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute_category, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute_category := p_x_association_tbl(i).attribute_category;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute1, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute1 := p_x_association_tbl(i).attribute1;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute2, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute2 := p_x_association_tbl(i).attribute2;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute3, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute3 := p_x_association_tbl(i).attribute3;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute3, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute3 := p_x_association_tbl(i).attribute3;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute4, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute4 := p_x_association_tbl(i).attribute4;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute5, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute5 := p_x_association_tbl(i).attribute5;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute6, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute6 := p_x_association_tbl(i).attribute6;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute7, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute7 := p_x_association_tbl(i).attribute7;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute8, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute8 := p_x_association_tbl(i).attribute8;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute9, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute9 := p_x_association_tbl(i).attribute9;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute10, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute10 := p_x_association_tbl(i).attribute10;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute11, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute11 := p_x_association_tbl(i).attribute11;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute12, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute12 := p_x_association_tbl(i).attribute12;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute13, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute13 := p_x_association_tbl(i).attribute13;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute14, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute14 := p_x_association_tbl(i).attribute14;
        END IF;
        --
        IF NVL(p_x_association_tbl(i).attribute15, 'X') <> FND_API.G_MISS_CHAR
        THEN
           l_association_info.attribute15 := p_x_association_tbl(i).attribute15;
        END IF;
        --
	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;

	END IF;
	--

	OPEN get_doc_det(l_association_info.document_id);
	FETCH get_doc_det INTO l_document_no;
	CLOSE get_doc_det;
	-- check whether the record is there in the database if no then no error.
	-- if yes then check whether the record is there in tbl_rec.
	-- check only for the rec with doc_title_asso_id = doc_title_asso_id of rec that has aduplicate in database
	-- if such a record not found in tbl_rec then throw error.
        -- bug no 2918260 : pbarman : 23 rd April 2003
        IF l_association_info.aso_object_type_code NOT IN ( 'PC', 'MC','ROUTE','OPERATION' )
        THEN
        -- This check is required for when record already exists
        OPEN dup_rec( l_association_info.aso_object_type_code,
                      l_association_info.aso_object_id,
                      l_association_info.document_id,
                      l_association_info.doc_revision_id);
        FETCH dup_rec INTO l_doc_title_asso_id;
        IF dup_rec%FOUND  THEN

            FOR j IN (i+1)..p_x_association_tbl.LAST
	    LOOP
	          IF( p_x_association_tbl(j).doc_title_asso_id = l_doc_title_asso_id)
		  THEN
		     l_found_flag := 'Y';
	   	     IF(p_x_association_tbl(j).aso_object_type_code = p_x_association_tbl(i).aso_object_type_code AND
	   	        p_x_association_tbl(j).aso_object_id = p_x_association_tbl(i).aso_object_id AND
	   	        p_x_association_tbl(j).document_id = p_x_association_tbl(i).document_id AND
	   	        p_x_association_tbl(j).doc_revision_id = p_x_association_tbl(i).doc_revision_id
	   	       )
	   	     THEN

	   	        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
	   	        FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
	   	        FND_MSG_PUB.ADD;
	                RAISE FND_API.G_EXC_ERROR;

	   	     END IF;
	   	   END IF;

	   END LOOP;
	   IF l_found_flag = 'N'
	   THEN
		    FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
		    FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
	    END IF;

         END IF;
         CLOSE dup_rec;
        ELSE
        -- This check is required for when record already exists
        OPEN dup_rec_check(   p_x_association_tbl(i).doc_title_asso_id,
                              l_association_info.aso_object_type_code,
			      l_association_info.aso_object_id,
			      l_association_info.document_id,
			      l_association_info.doc_revision_id,
			      l_association_tl_info.chapter,
			      l_association_tl_info.section,
			      l_association_tl_info.subject,
			      l_association_tl_info.page,
			      l_association_tl_info.figure);
        FETCH dup_rec_check INTO l_doc_title_asso_id;
        IF dup_rec_check%FOUND  THEN

          -- bug no 2918260 : pbarman : 23 rd April 2003
                  FOR j IN (i+1)..p_x_association_tbl.LAST
		  LOOP
		      IF( p_x_association_tbl(j).doc_title_asso_id = l_doc_title_asso_id)
		      THEN
		      l_found_flag := 'Y';
			      IF(p_x_association_tbl(j).aso_object_type_code = p_x_association_tbl(i).aso_object_type_code AND
				p_x_association_tbl(j).aso_object_id = p_x_association_tbl(i).aso_object_id AND
				p_x_association_tbl(j).document_id = p_x_association_tbl(i).document_id AND
				p_x_association_tbl(j).doc_revision_id = p_x_association_tbl(i).doc_revision_id AND
				p_x_association_tbl(j).chapter = p_x_association_tbl(i).chapter AND
				p_x_association_tbl(j).section = p_x_association_tbl(i).section AND
				p_x_association_tbl(j).subject = p_x_association_tbl(i).subject AND
				p_x_association_tbl(j).page = p_x_association_tbl(i).page AND
				p_x_association_tbl(j).figure = p_x_association_tbl(i).figure
			       )
			     THEN

				FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
				FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;

			     END IF;
                       END IF;

		  END LOOP;
	          IF l_found_flag = 'N'
	          THEN
	            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
		    FND_MESSAGE.SET_TOKEN('DUPRECORD',l_document_no);
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		  END IF;

         END IF;
         CLOSE dup_rec_check;
        END IF;
/*-------------------------------------------------------- */
/* procedure name: AHL_DOC_TITLE_ASSOS_PKG.UPDATE_ROW      */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
        -- Update doc title assos table and trans table
	AHL_DOC_TITLE_ASSOS_PKG.UPDATE_ROW(
		X_DOC_TITLE_ASSO_ID            	=>	p_x_association_tbl(i).doc_title_asso_id,
		X_SERIAL_NO                    	=>	l_association_info.serial_no,
		X_ATTRIBUTE_CATEGORY           	=>	l_association_info.attribute_category,
		X_ATTRIBUTE1                   	=>	l_association_info.attribute1,
		X_ATTRIBUTE2                   	=>	l_association_info.attribute2,
		X_ATTRIBUTE3                   	=>	l_association_info.attribute3,
		X_ATTRIBUTE4                   	=>	l_association_info.attribute4,
		X_ATTRIBUTE5                   	=>	l_association_info.attribute5,
		X_ATTRIBUTE6                   	=>	l_association_info.attribute6,
		X_ATTRIBUTE7                   	=>	l_association_info.attribute7,
		X_ATTRIBUTE8                   	=>	l_association_info.attribute8,
		X_ATTRIBUTE9                   	=>	l_association_info.attribute9,
		X_ATTRIBUTE10                  	=>	l_association_info.attribute10,
		X_ATTRIBUTE11                  	=>	l_association_info.attribute11,
		X_ATTRIBUTE12                  	=>	l_association_info.attribute12,
		X_ATTRIBUTE13                  	=>	l_association_info.attribute13,
		X_ATTRIBUTE14                  	=>	l_association_info.attribute14,
		X_ATTRIBUTE15                  	=>	l_association_info.attribute15,
		X_ASO_OBJECT_TYPE_CODE         	=>	l_association_info.aso_object_type_code,
        	X_SOURCE_REF_CODE              =>       NULL,
		X_ASO_OBJECT_ID                	=>	l_association_info.aso_object_id,
		X_DOCUMENT_ID                  	=>	l_association_info.document_id,
		X_USE_LATEST_REV_FLAG          	=>	l_association_info.use_latest_rev_flag,
		X_DOC_REVISION_ID              	=>	l_association_info.doc_revision_id,
		X_OBJECT_VERSION_NUMBER        	=>	l_association_info.object_version_number+1,
		X_CHAPTER                      	=>	l_association_tl_info.chapter,
		X_SECTION                      	=>	l_association_tl_info.section,
		X_SUBJECT                      	=>	l_association_tl_info.subject,
		X_FIGURE                       	=>	l_association_tl_info.figure,
		X_PAGE                         	=>	l_association_tl_info.page,
		X_NOTE                         	=>	l_association_tl_info.note,
		X_LAST_UPDATE_DATE             	=>	sysdate,
		X_LAST_UPDATED_BY              	=>	fnd_global.user_id,
		X_LAST_UPDATE_LOGIN            	=>	fnd_global.login_id);
    --In case of delete
 ELSIF (p_x_association_tbl(i).doc_title_asso_id IS NOT NULL
        AND
        p_x_association_tbl(i).delete_flag = 'Y' )

    THEN
      DELETE_ASSOCIATION
        ( p_api_version        => 1.0               ,
          p_init_msg_list      => FND_API.G_TRUE      ,
          p_commit             => FND_API.G_FALSE     ,
          p_validate_only      => FND_API.G_TRUE      ,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_association_rec    => p_x_association_tbl(i)    ,
          x_return_status      => x_return_status      ,
          x_msg_count          => x_msg_count          ,
          x_msg_data           => x_msg_data);
   END IF;
  END LOOP;
 END IF;
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
		  AHL_DEBUG_PUB.debug( 'End of private api Modify Association','+DOBJASS+');

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
              AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Modify Association','+DOBJASS+');


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
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Modify Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_ASO_PVT',
                            p_procedure_name  =>  'MODIFY_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pvt.Modify Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_ASSOCIATION;
--
PROCEDURE INSERT_ASSOC_REC
(
 p_api_version                IN     NUMBER    :=  1.0             ,
 p_init_msg_list              IN     VARCHAR2  := Fnd_Api.G_TRUE   ,
 p_commit                     IN     VARCHAR2  := Fnd_Api.G_FALSE  ,
 p_validate_only              IN     VARCHAR2  := Fnd_Api.G_TRUE   ,
 p_validation_level           IN     NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
 p_association_rec            IN  ahl_doc_title_assos_vl%ROWTYPE        ,
 x_return_status                 OUT NOCOPY VARCHAR2                      ,
 x_msg_count                     OUT NOCOPY NUMBER                        ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
IS
-- Used to check for duplicate records
CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER)

 IS
SELECT 'X'
  FROM AHL_DOC_TITLE_ASSOS_B
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = NVL(c_doc_revision_id,0);
 --
 CURSOR get_doc_num(c_document_id NUMBER)
  IS
  SELECT document_no
    FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;
 --
 l_api_name     CONSTANT VARCHAR2(30) := 'INSERT_ASSOC_REC';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER       := 0;
 l_rowid                 ROWID;
 l_dummy                 VARCHAR2(2000);
 l_document_no           VARCHAR2(80);
 l_doc_title_asso_id     NUMBER;
 l_association_info      association_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT insert_assoc_rec;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pvt.Insert Assoc Rec','+DOBJASS+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := 'S';
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --Start of API Body
        VALIDATE_ASSOCIATION
        (
          p_doc_title_asso_id       => p_association_rec.doc_title_asso_id,
          p_document_id             => p_association_rec.document_id,
          p_doc_revision_id         => p_association_rec.doc_revision_id,
          p_use_latest_rev_flag     => p_association_rec.use_latest_rev_flag,
          p_aso_object_type_code    => p_association_rec.aso_object_type_code,
          p_aso_object_id           => p_association_rec.aso_object_id,
          p_delete_flag             => 'N'
         );
   --Standard call to message count
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

      IF  p_association_rec.doc_title_asso_id = Fnd_Api.G_MISS_NUM
      THEN
       --The following conditions are required for optional fields
       IF p_association_rec.doc_revision_id = Fnd_Api.G_MISS_NUM
       THEN
          l_association_info.doc_revision_id := NULL;
       ELSE
          l_association_info.doc_revision_id := p_association_rec.doc_revision_id;
       END IF;
       -- If document revision doesnt exist then latest rev flag
       -- is 'YES' else which ever user selects (Default 'NO')
       IF (p_association_rec.use_latest_rev_flag = Fnd_Api.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NULL)
       THEN
          l_association_info.use_latest_rev_flag := 'Y';
       ELSIF (p_association_rec.use_latest_rev_flag <> Fnd_Api.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NULL)
       THEN
          l_association_info.use_latest_rev_flag := p_association_rec.use_latest_rev_flag;
       ELSIF (p_association_rec.use_latest_rev_flag <> Fnd_Api.G_MISS_CHAR
          AND
          l_association_info.doc_revision_id IS NOT NULL)
       THEN
          l_association_info.use_latest_rev_flag := p_association_rec.use_latest_rev_flag;

        ELSE
          l_association_info.use_latest_rev_flag := 'N';
       END IF;
       --
       IF p_association_rec.serial_no = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.serial_no := NULL;
        ELSE
          l_association_info.serial_no := p_association_rec.serial_no;
        END IF;
        --
       IF p_association_rec.chapter = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.chapter := NULL;
        ELSE
          l_association_info.chapter := p_association_rec.chapter;
        END IF;
       --
       IF p_association_rec.SECTION = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.SECTION := NULL;
        ELSE
          l_association_info.SECTION := p_association_rec.SECTION;
        END IF;
        --
       IF p_association_rec.subject = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.subject := NULL;
        ELSE
          l_association_info.subject := p_association_rec.subject;
        END IF;
        --
       IF p_association_rec.page = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.page := NULL;
        ELSE
          l_association_info.page := p_association_rec.page;
        END IF;
        --
       IF p_association_rec.figure = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.figure := NULL;
        ELSE
          l_association_info.figure := p_association_rec.figure;
        END IF;
        --
       IF p_association_rec.note = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.note := NULL;
        ELSE
          l_association_info.note := p_association_rec.note;
        END IF;
        --
       IF p_association_rec.attribute_category = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute_category := NULL;
        ELSE
          l_association_info.attribute_category := p_association_rec.attribute_category;
        END IF;
        --
       IF p_association_rec.attribute1 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute1 := NULL;
        ELSE
          l_association_info.attribute1 := p_association_rec.attribute1;
        END IF;
        --
       IF p_association_rec.attribute2 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute2 := NULL;
        ELSE
          l_association_info.attribute2 := p_association_rec.attribute2;
        END IF;
        --
       IF p_association_rec.attribute3 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute3 := NULL;
        ELSE
          l_association_info.attribute3 := p_association_rec.attribute3;
        END IF;
        --
       IF p_association_rec.attribute4 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute4 := NULL;
        ELSE
          l_association_info.attribute4 := p_association_rec.attribute4;
        END IF;
        --
       IF p_association_rec.attribute5 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute5 := NULL;
        ELSE
          l_association_info.attribute5 := p_association_rec.attribute5;
        END IF;
        --
       IF p_association_rec.attribute6 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute6 := NULL;
        ELSE
          l_association_info.attribute6 := p_association_rec.attribute6;
        END IF;
        --
       IF p_association_rec.attribute7 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute7 := NULL;
        ELSE
          l_association_info.attribute7 := p_association_rec.attribute7;
        END IF;
        --
       IF p_association_rec.attribute8 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute8 := NULL;
        ELSE
          l_association_info.attribute8 := p_association_rec.attribute8;
        END IF;
        --
       IF p_association_rec.attribute9 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute9 := NULL;
        ELSE
          l_association_info.attribute9 := p_association_rec.attribute9;
        END IF;
        --
       IF p_association_rec.attribute10 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute10 := NULL;
        ELSE
          l_association_info.attribute10 := p_association_rec.attribute10;
        END IF;
        --
       IF p_association_rec.attribute11 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute11 := NULL;
        ELSE
          l_association_info.attribute11 := p_association_rec.attribute11;
        END IF;
        --
       IF p_association_rec.attribute12 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute12 := NULL;
        ELSE
          l_association_info.attribute12 := p_association_rec.attribute12;
        END IF;
        --
       IF p_association_rec.attribute13 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute13 := NULL;
        ELSE
          l_association_info.attribute13 := p_association_rec.attribute13;
        END IF;
        --
       IF p_association_rec.attribute14 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute14 := NULL;
        ELSE
          l_association_info.attribute14 := p_association_rec.attribute14;
        END IF;
        --
       IF p_association_rec.attribute15 = Fnd_Api.G_MISS_CHAR
       THEN
          l_association_info.attribute15 := NULL;
        ELSE
          l_association_info.attribute15 := p_association_rec.attribute15;
        END IF;
        --
        OPEN get_doc_num(p_association_rec.document_id);
        FETCH get_doc_num INTO l_document_no;
        CLOSE get_doc_num;
        -- This check is required for when same record is passed twice
        OPEN dup_rec( p_association_rec.aso_object_type_code,
                      p_association_rec.aso_object_id,
                      p_association_rec.document_id,
                      p_association_rec.doc_revision_id);
        FETCH dup_rec INTO l_dummy;
        IF dup_rec%FOUND  THEN
           Fnd_Message.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
           Fnd_Message.SET_TOKEN('DUPRECORD',l_document_no);
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         CLOSE dup_rec;
    --Gets the sequence Number
    SELECT AHL_DOC_TITLE_ASSOS_B_S.NEXTVAL INTO
           l_doc_title_asso_id FROM DUAL;
/*-------------------------------------------------------- */
/* procedure name: AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW      */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
--Insert the record into doc title assos table and tranlations table
	AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW(
		X_ROWID                        	=>	l_rowid,
		X_DOC_TITLE_ASSO_ID            	=>	l_doc_title_asso_id,
		X_SERIAL_NO                    	=>	l_association_info.serial_no,
		X_ATTRIBUTE_CATEGORY           	=>	l_association_info.attribute_category,
		X_ATTRIBUTE1                   	=>	l_association_info.attribute1,
		X_ATTRIBUTE2                   	=>	l_association_info.attribute2,
		X_ATTRIBUTE3                   	=>	l_association_info.attribute3,
		X_ATTRIBUTE4                   	=>	l_association_info.attribute4,
		X_ATTRIBUTE5                   	=>	l_association_info.attribute5,
		X_ATTRIBUTE6                   	=>	l_association_info.attribute6,
		X_ATTRIBUTE7                   	=>	l_association_info.attribute7,
		X_ATTRIBUTE8                   	=>	l_association_info.attribute8,
		X_ATTRIBUTE9                   	=>	l_association_info.attribute9,
		X_ATTRIBUTE10                  	=>	l_association_info.attribute10,
		X_ATTRIBUTE11                  	=>	l_association_info.attribute11,
		X_ATTRIBUTE12                  	=>	l_association_info.attribute12,
		X_ATTRIBUTE13                  	=>	l_association_info.attribute13,
		X_ATTRIBUTE14                  	=>	l_association_info.attribute14,
		X_ATTRIBUTE15                  	=>	l_association_info.attribute15,
		X_ASO_OBJECT_TYPE_CODE         	=>	p_association_rec.aso_object_type_code,
        	X_SOURCE_REF_CODE              =>       NULL,
		X_ASO_OBJECT_ID                	=>	p_association_rec.aso_object_id,
		X_DOCUMENT_ID                  	=>	p_association_rec.document_id,
		X_USE_LATEST_REV_FLAG          	=>	l_association_info.use_latest_rev_flag,
		X_DOC_REVISION_ID              	=>	l_association_info.doc_revision_id,
		X_OBJECT_VERSION_NUMBER        	=>	1,
		X_CHAPTER                      	=>	l_association_info.chapter,
		X_SECTION                      	=>	l_association_info.section,
		X_SUBJECT                      	=>	l_association_info.subject,
		X_FIGURE                       	=>	l_association_info.figure,
		X_PAGE                         	=>	l_association_info.page,
		X_NOTE                         	=>	l_association_info.note,
		X_CREATION_DATE                	=>	sysdate,
		X_CREATED_BY                   	=>	fnd_global.user_id,
		X_LAST_UPDATE_DATE             	=>	sysdate,
		X_LAST_UPDATED_BY              	=>	fnd_global.user_id,
		X_LAST_UPDATE_LOGIN            	=>	fnd_global.login_id);
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
  END IF;
   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'END OF PRIVATE Insret Asso Rec','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO insert_assoc_rec;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

         --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt.INSERT Assoc Rec','+DOBJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO insert_assoc_rec;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt. INSERT Assoc Rec','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO insert_assoc_rec;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'Ahl_Di_Asso_Doc_Aso_Pvt',
                            p_procedure_name  =>  'INSERT_ASSOC_REC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt.INSERT Assoc Rec','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END INSERT_ASSOC_REC;

/*------------------------------------------------------*/
/* procedure name: copy_association                    */
/* description :  Copies the existing document record  */
/*                and inserts new document record with  */
/*                associated aso object(when the association */
/*                changed from old aso object to new aso object */
/*                                                      */
/*------------------------------------------------------*/
Procedure COPY_ASSOCIATION
(
 p_api_version                IN      NUMBER    := 1.0           ,
 p_init_msg_list              IN      VARCHAR2  := Fnd_Api.G_TRUE  ,
 p_commit                     IN      VARCHAR2  := Fnd_Api.G_FALSE ,
 p_validate_only              IN      VARCHAR2  := Fnd_Api.G_TRUE  ,
 p_validation_level           IN      NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
 p_from_object_id             IN      NUMBER,
 p_from_object_type           IN      VARCHAR2,
 p_to_object_id               IN      NUMBER,
 p_to_object_type             IN      VARCHAR2,
 x_return_status                  OUT NOCOPY VARCHAR2                     ,
 x_msg_count                      OUT NOCOPY NUMBER                       ,
 x_msg_data                       OUT NOCOPY VARCHAR2)
 IS
 -- Retrives all the records for passed aso object
 CURSOR get_assos_b_cur (c_object_id  NUMBER,
                          c_object_type_code VARCHAR2)
 IS
 SELECT * FROM AHL_DOC_TITLE_ASSOS_VL
   WHERE ASO_OBJECT_ID        = c_object_id
     AND ASO_OBJECT_TYPE_CODE = c_object_type_code;
 --
 l_api_name     CONSTANT VARCHAR2(30) := 'COPY_ASSOCIATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER       := 0;
 l_dummy                 VARCHAR2(2000);
 l_row_id          VARCHAR2(30);
 l_association_rec    get_assos_b_cur%ROWTYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT copy_association;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter Ahl_Di_Asso_Doc_Aso_Pvt.Copy Association','+DOBJASS+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := 'S';
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter Ahl_Di_Asso_Doc_Aso_Pvt.Copy Association:'||p_from_object_id ,'+DOBJASS+');

	END IF;
    END IF;
   --Start of API Body
   OPEN get_assos_b_cur(p_from_object_id,p_from_object_type);
   LOOP
   FETCH get_assos_b_cur INTO l_association_rec;
   EXIT WHEN get_assos_b_cur%NOTFOUND;
    IF get_assos_b_cur%FOUND THEN
          BEGIN
                SELECT ROWID INTO l_row_id
                FROM   ahl_doc_title_assos_b
                WHERE  doc_title_asso_id = l_association_rec.doc_title_asso_id
                AND object_version_number
                    = l_association_rec.object_version_number
                   FOR UPDATE OF aso_object_id NOWAIT;
             EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
                   Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                   Fnd_Msg_Pub.ADD;
                   x_msg_data := 'AHL_COM_RECORD_CHANGED';
                   x_return_status := 'E' ;
             WHEN NO_DATA_FOUND THEN
                   Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                   Fnd_Msg_Pub.ADD;
                   x_msg_data := 'AHL_COM_RECORD_CHANGED';
                   x_return_status := 'E' ;
             WHEN OTHERS THEN
                   IF SQLCODE = -54 THEN
                      Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                      Fnd_Msg_Pub.ADD;
                      x_msg_data := 'AHL_COM_RECORD_CHANGED';
                      x_return_status := 'E' ;
                   ELSE
                      RAISE;
                   END IF;
              END;
            l_msg_count := Fnd_Msg_Pub.count_msg;
            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
               RAISE  Fnd_Api.G_EXC_ERROR;
            END IF;
      END IF;
      --Assign the new object id and object type
      l_association_rec.doc_title_asso_id := Fnd_Api.G_MISS_NUM;
      l_association_rec.aso_object_id := p_to_object_id;
      l_association_rec.aso_object_type_code := p_from_object_type;
      --Call to insert new association records
      INSERT_ASSOC_REC
        ( p_api_version        => 1.0             ,
          p_init_msg_list      => Fnd_Api.G_TRUE   ,
          p_commit             => Fnd_Api.G_FALSE  ,
          p_validate_only      => Fnd_Api.G_TRUE   ,
          p_validation_level   => Fnd_Api.G_VALID_LEVEL_FULL,
          p_association_rec    => l_association_rec        ,
          x_return_status      => x_return_status      ,
          x_msg_count          => x_msg_count          ,
          x_msg_data           => x_msg_data);

   END LOOP;
   CLOSE get_assos_b_cur;
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'END OF PRIVATE copy Association','+DOBJASS+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_association;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt.Copy Association','+DOBJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO copy_association;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt.Copy Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO copy_association;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'Ahl_Di_Asso_Doc_Aso_Pvt',
                            p_procedure_name  =>  'COPY_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'Ahl_Di_Asso_Doc_Aso_Pvt.Copy Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.

		  AHL_DEBUG_PUB.disable_debug;

	END IF;

END COPY_ASSOCIATION;
--
END AHL_DI_ASSO_DOC_ASO_PVT;

/
