--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOC_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOC_GEN_PVT" AS
/* $Header: AHLVDAGB.pls 120.0.12010000.2 2010/01/11 07:06:41 snarkhed ship $ */
--
G_PKG_NAME  		VARCHAR2(30)  := 'AHL_DI_ASSO_DOC_GEN_PVT';
G_PM_INSTALL            VARCHAR2(30):=ahl_util_pkg.is_pm_installed;
G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

/*---------------------------------------------------------*/
/* procedure name: validate_association(private procedure) */
/* description :  Validation checks for before inserting   */
/*                new record as well before modification   */
/*                takes place                              */
/*---------------------------------------------------------*/


PROCEDURE RECORD_IDENTIFIER
(
p_association_rec   IN                AHL_DI_ASSO_DOC_GEN_PVT.association_rec,
x_record            OUT NOCOPY        VARCHAR2
)
as
CURSOR get_rev_dat(c_document_id NUMBER, c_doc_revision_id NUMBER)
IS
  SELECT DOCUMENT_NO, REVISION_NO
   FROM  AHL_DOCUMENTS_B D, AHL_DOC_REVISIONS_B R
   WHERE D.DOCUMENT_ID = R.DOCUMENT_ID
      AND R.DOC_REVISION_ID = c_doc_revision_id
      AND D.DOCUMENT_ID  = c_document_id;

l_doc_no             varchar2(80);
l_doc_rev_no         varchar2(30);
Begin
                open get_rev_dat(p_association_rec.document_id, p_association_rec.doc_revision_id);
                fetch get_rev_dat into l_doc_no, l_doc_rev_no;
                close get_rev_dat;

                If l_doc_no is not null and l_doc_no<>fnd_api.g_miss_char
                Then
                        x_record:=x_record||nvl(l_doc_no,'')||' - ';
                End if;

                If l_doc_rev_no is not null and l_doc_rev_no<>fnd_api.g_miss_char
                Then
	                x_record:=x_record||nvl(l_doc_rev_no ,'')||' - ';
                End if;

                If p_association_rec.chapter is not null and p_association_rec.chapter<>fnd_api.g_miss_char
                Then
	                x_record:=x_record||nvl(p_association_rec.chapter,'')||' - ';
                End if;

                If p_association_rec.section is not null and p_association_rec.section<>fnd_api.g_miss_char
                Then
	                x_record:=x_record||nvl(p_association_rec.section,'')||' - ';
                End if;

                If p_association_rec.subject is not null and p_association_rec.subject<>fnd_api.g_miss_char
                Then
	               x_record:=x_record||nvl(p_association_rec.subject,'')||' - ';
                End if;

                If p_association_rec.figure is not null and p_association_rec.figure<>fnd_api.g_miss_char
                Then
	                x_record:=x_record||nvl(p_association_rec.figure,'')||' - ';
                End if;

                If p_association_rec.page is not null and p_association_rec.page<>fnd_api.g_miss_char
                Then
	                x_record:=x_record||nvl(p_association_rec.page,'');
                End if;

End;


PROCEDURE VALIDATE_ASSOCIATION
 (
  P_DOC_TITLE_ASSO_ID      IN  NUMBER      := NULL,
  P_DOCUMENT_ID            IN  NUMBER      := NULL,
  P_DOC_REVISION_ID        IN  NUMBER      := NULL,
  P_USE_LATEST_REV_FLAG    IN  VARCHAR2    := NULL,
  P_ASO_OBJECT_TYPE_CODE   IN  VARCHAR2    := NULL,
  P_ASO_OBJECT_ID          IN  NUMBER      := NULL,
  P_OBJECT_VERSION_NUM     IN  NUMBER      := NULL,
  P_DML_OPERATION	   IN  VARCHAR2    ,
  p_record                 IN VARCHAR2     ,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
 )
as
CURSOR get_rev_dat(c_doc_revision_id NUMBER)
IS
  SELECT REVISION_STATUS_CODE,
         OBSOLETE_DATE,
         REVISION_NO
   FROM  AHL_DOC_REVISIONS_B
   WHERE DOC_REVISION_ID = c_doc_revision_id;

   l_Rev_rec1   get_rev_dat%rowtype;


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

 CURSOR  CheckLatestRevFlag(C_DOC_TITLE_ASSO_ID  NUMBER,C_ASO_OBJECT_ID NUMBER,c_aso_object_type_code VARCHAR2,c_document_id  NUMBER,c_use_latest_rev_flag VARCHAR2)
 IS
 SELECT 'X'
 FROM AHL_DOC_TITLE_ASSOS_B
 WHERE aso_object_id=c_aso_object_id
   AND aso_object_type_code=c_aso_object_type_code
   AND document_id=c_document_id
   AND use_latest_rev_flag<>nvl(c_use_latest_rev_flag,'X')
   AND DOC_TITLE_ASSO_ID <> NVL(C_DOC_TITLE_ASSO_ID,0);


CURSOR get_mr_type_code (C_ASO_OBJECT_ID NUMBER)
IS
SELECT TYPE_CODE
FROM AHL_MR_HEADERS_B
WHERE MR_HEADER_ID=C_ASO_OBJECT_ID;

CURSOR get_doc_assos_ovn(c_doc_title_asso_id  NUMBER)
 IS
SELECT object_version_number
  FROM AHL_DOC_TITLE_ASSOS_B
 WHERE doc_title_asso_id = c_doc_title_asso_id;

	-- FP #8410484
	 --Cursor To get revision status code
	CURSOR get_revision_status_code(c_doc_revision_id NUMBER)
	IS
	SELECT revision_status_code
	FROM AHL_DOC_REVISIONS_B
	WHERE doc_revision_id = c_doc_revision_id;

		-- Cursor to get MC status
	CURSOR get_mc_status(c_relationship_id NUMBER)
	IS
	SELECT CONFIG_STATUS_CODE
	FROM ahl_mc_headers_b header,ahl_mc_relationships relationship
	WHERE relationship.relationship_id =  c_relationship_id
	AND header.mc_header_id = relationship.mc_header_id;

		--Cursor to get PC status
	CURSOR get_pc_status(c_node_id NUMBER)
	IS
	SELECT STATUS
	FROM ahl_pc_headers_b header,ahl_pc_nodes_b node
	WHERE node.pc_node_id = c_node_id
	AND header.pc_header_id = node.pc_header_id;

		--Cursor to get MR status
	CURSOR get_mr_status(c_mr_header_id Number)
	IS
	SELECT mr_status_code
	FROM ahl_mr_headers_b
	where mr_header_id = c_mr_header_id;

	--FP #8410484


 l_dummy_char	         VARCHAR2(1);
 l_dummy                 VARCHAR2(2000);
 l_doc_title_asso_id     NUMBER;
 l_document_id           NUMBER;
 l_doc_revision_id       NUMBER;
 l_document_no           VARCHAR2(80);
 l_use_latest_rev_flag   VARCHAR2(1);
 l_aso_object_type_code  VARCHAR2(30);
 l_revision_status_code  VARCHAR2(30);
 l_aso_object_id         NUMBER;
 l_status                VARCHAR2(30);
 l_obsolete_date         DATE;
 l_max_doc_date		       DATE;
 l_latest_doc_revision_id NUMBER :=0;
 l_object_version_number NUMBER;
 l_api_name              CONSTANT VARCHAR2(30):= 'VALIDATE_ASSOCIATION';
 l_api_version           CONSTANT NUMBER:=1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_counter               NUMBER:=0;
 l_counter1              NUMBER:=0;
 l_lookup_code           VARCHAR2(30):='';
 l_record                VARCHAR2(4000):=P_RECORD;
 l_type_code             VARCHAR2(30);
 BEGIN
   x_return_status:=FND_API.G_RET_STS_SUCCESS;

   IF p_dml_operation <> 'D'
   THEN
   IF p_aso_object_type_code = 'MR'
   THEN
        IF g_pm_install<>'Y'
        THEN

		IF p_ASO_OBJECT_ID IS NOT NULL OR  p_ASO_OBJECT_ID<>FND_API.G_MISS_NUM
		THEN
			OPEN get_mr_type_code (P_ASO_OBJECT_ID);
			fetch get_mr_type_code into l_type_code;
			close get_mr_type_code ;

			IF L_TYPE_CODE='PROGRAM'
			THEN
				FND_MESSAGE.SET_NAME('AHL','AHL_DI_MR_NOTEDITABLE');
				FND_MSG_PUB.ADD;
			END IF;
		END IF;
        END IF;
   END IF;
   IF p_doc_title_asso_id IS NOT NULL AND p_doc_title_asso_id <> FND_API.G_MISS_NUM
   THEN
        OPEN get_doc_assos_rec_b_info(p_doc_title_asso_id);
        FETCH get_doc_assos_rec_b_info INTO l_document_id,
                                            l_doc_revision_id,
                                            l_use_latest_rev_flag,
                                            l_aso_object_type_code,
                                            l_aso_object_id;
        IF(get_doc_assos_rec_b_info%NOTFOUND)
        THEN
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TITLE_INVALID');
               FND_MESSAGE.SET_TOKEN('RECORD',l_record);
               FND_MSG_PUB.ADD;
               CLOSE get_doc_assos_rec_b_info;
               RETURN;
        END IF;
        CLOSE get_doc_assos_rec_b_info;
   END IF;
   OPEN get_doc_det(p_document_id);
   FETCH get_doc_det INTO l_document_no;
   CLOSE get_doc_det;

   /*check for obj version num*/
   IF p_dml_operation = 'U'
   THEN
	    OPEN get_doc_assos_ovn(p_doc_title_asso_id);
	    FETCH get_doc_assos_ovn INTO l_object_version_number;
	    IF (get_doc_assos_ovn%NOTFOUND)
	    THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_INVALID');
		FND_MSG_PUB.ADD;
	    END IF;
	    CLOSE get_doc_assos_ovn;
	   -- Check for version number
	   IF (l_object_version_number <> p_object_version_num)
	   THEN
	       FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_CHANGED');
	       FND_MSG_PUB.ADD;
	   END IF;
   END IF;
   /**/

   IF p_aso_object_type_code = 'OPERATION' THEN
       OPEN get_operation_status(p_aso_object_id);
       FETCH get_operation_status INTO l_status;
       CLOSE get_operation_status;
       --FP #8410484
       --IF l_status <> 'DRAFT' AND l_status <> 'APPROVAL_REJECTED'
       --THEN
               --FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_STAT_DRFT_ASO');
               --FND_MSG_PUB.ADD;
               --RETURN;
       --END IF;
       -- End of FP #8410484
   END IF;

    IF p_aso_object_type_code = 'ROUTE' THEN
       OPEN get_route_status(p_aso_object_id);
       FETCH get_route_status INTO l_status;
       CLOSE get_route_status;
       --FP #8410484
       --IF l_status <> 'DRAFT' AND  l_status <> 'APPROVAL_REJECTED'
       --THEN
               --FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROU_STAT_DRFT_ASO');
               --FND_MSG_PUB.ADD;
               --RETURN;
       --END IF;
       -- End of FP #8410484
    END IF;

    -- FP #8410484
    IF p_aso_object_type_code = 'PC' THEN
		OPEN get_pc_status(p_aso_object_id);
		FETCH get_pc_status INTO l_status;
		CLOSE get_pc_status;
	ELSIF p_aso_object_type_code = 'MC' THEN
		OPEN get_mc_status(p_aso_object_id);
		FETCH get_mc_status INTO l_status;
		CLOSE get_mc_status;
	ELSIF p_aso_object_type_code = 'MR' THEN
		OPEN get_mr_status(p_aso_object_id);
		FETCH get_mr_status into l_status;
		CLOSE get_mr_status;
     END IF;

     IF l_status = 'COMPLETE' THEN
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'Checking when object status is complete');
		END IF;

		OPEN get_doc_assos_rec_b_info(p_doc_title_asso_id);
		FETCH get_doc_assos_rec_b_info INTO l_document_id,
                                            l_doc_revision_id,
                                            l_use_latest_rev_flag,
                                            l_aso_object_type_code,
                                            l_aso_object_id;
		CLOSE get_doc_assos_rec_b_info;
		-- If object status is complete then only updation is allowed.This means there should be one
		-- present in the table which have this association
		IF (p_document_id <> l_document_id OR p_doc_revision_id <> l_doc_revision_id OR
		   l_aso_object_type_code <> p_aso_object_type_code OR l_aso_object_id <> p_aso_object_id) THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_DI_INVALID_ASSOC_STATUS');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Checked Object Status Complete');
	END IF;
	-- Document Association/Updation is only allowed in DRAFT,APPROVAL_REJECTED and COMPLETE status.
	IF l_status <> 'DRAFT' AND l_status <> 'APPROVAL_REJECTED' AND l_status<>'COMPLETE'
	THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBJ_STAT_INVALID');
		FND_MSG_PUB.ADD;
		RETURN;
	END IF;
    -- End of FP #8410484
    IF p_Doc_revision_id IS NOT NULL and p_doc_revision_id <> FND_API.G_MISS_NUM
    THEN
       OPEN get_rev_dat(p_doc_revision_id);
       FETCH get_rev_dat INTO l_rev_rec1;
       IF get_rev_dat%notfound
       THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_INVALID');
                FND_MESSAGE.SET_TOKEN('field',l_record);
                FND_MSG_PUB.ADD;
                CLOSE get_rev_dat;
                RETURN;
       ELSE
                IF TRUNC(NVL(l_rev_rec1.obsolete_date,SYSDATE+1)) <= TRUNC(sysdate)
                THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_OBSOLETE');
                FND_MESSAGE.SET_TOKEN('FIELD1',l_record);
                FND_MESSAGE.SET_TOKEN('FIELD2',l_rev_Rec1.REVISION_NO);
                --FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                FND_MSG_PUB.ADD;
                CLOSE get_rev_dat;
                RETURN;
                END IF;
       END IF;
    END IF;
    IF ((p_doc_title_asso_id IS NULL OR
             p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
            (p_document_id IS NULL OR p_document_id = FND_API.G_MISS_NUM))
            OR
            ((p_doc_title_asso_id IS NOT NULL AND
              p_doc_title_asso_id <> FND_API.G_MISS_NUM) AND l_document_id IS NULL)
        THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
		FND_MSG_PUB.ADD;
		RETURN;
	END IF;

     -- This condition checks for Aso Object Type Code is Null

     IF ((p_doc_title_asso_id IS NULL OR
          p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_aso_object_type_code IS NULL OR
         p_aso_object_type_code = FND_API.G_MISS_CHAR))
        OR
        ((p_doc_title_asso_id IS NOT NULL AND
          p_doc_title_asso_id <> FND_API.G_MISS_NUM)
        AND l_aso_object_type_code IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_TYPE_NULL');
        FND_MSG_PUB.ADD;
	RETURN;
     END IF;

     -- This condiiton checks for Aso Object Id Value Is Null
     IF ((p_doc_title_asso_id IS NULL OR
          p_doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_aso_object_id IS NULL OR
         p_aso_object_id = FND_API.G_MISS_NUM))
        OR
        ((p_doc_title_asso_id IS NOT NULL AND
          p_doc_title_asso_id <> FND_API.G_MISS_NUM) AND l_aso_object_id IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_ID_NULL');
        FND_MSG_PUB.ADD;
        RETURN;
     END IF;

    --Check for Aso Object Type Code in fnd lookups
    IF p_aso_object_type_code IS NOT NULL AND
       p_aso_object_type_code <> FND_API.G_MISS_CHAR
    THEN
       OPEN get_aso_obj_type_code(p_aso_object_type_code);
       FETCH get_aso_obj_type_code INTO l_dummy;
       IF get_aso_obj_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYPE_NOT_EXISTS');
          FND_MSG_PUB.ADD;
          CLOSE get_aso_obj_type_code;
          RETURN;
        END IF;
        CLOSE get_aso_obj_type_code;
     END IF;
-- Latest Rev Flag Check.
   IF p_aso_object_type_code IN ('ROUTE','OPERATION')
   THEN
         SELECT count(*) into l_counter1
         FROM AHL_DOC_TITLE_ASSOS_B
         WHERE aso_object_id=nvl(p_aso_object_id,0)
           AND aso_object_type_code=nvl(p_aso_object_type_code,'x')
           AND document_id=nvl(p_document_id,0)
           AND nvl(use_latest_rev_flag,'N')='Y'
           AND NVL(p_DOC_TITLE_ASSO_ID,0)=0;


         SELECT count(*) into l_counter
         FROM AHL_DOC_TITLE_ASSOS_B
         WHERE aso_object_id=nvl(p_aso_object_id,0)
           AND aso_object_type_code=nvl(p_aso_object_type_code,'x')
           AND document_id=nvl(p_document_id,0)
           AND use_latest_rev_flag<>NVL(p_use_latest_rev_flag,'N');

	  if    l_counter1>0
	  then
                FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_ERROR');
		FND_MESSAGE.SET_TOKEN('DOC_NO',l_record);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	  elsif (l_counter>0  and p_DML_OPERATION='C') OR  (l_counter>1  and p_DML_OPERATION='U')
	  then
		open CheckLatestRevFlag(NVL(p_DOC_TITLE_ASSO_ID,0),p_aso_object_id,p_aso_object_type_code,p_document_id,NVL(p_use_latest_rev_flag,'X'));
		fetch CheckLatestRevFlag into l_dummy_char;
		IF CheckLatestRevFlag%FOUND
		THEN
                         FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_ERROR');
			 FND_MESSAGE.SET_TOKEN('DOC_NO',l_record);
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
			 RETURN;
		END IF;
		close CheckLatestRevFlag;
	   end if;
   END IF;
   -- FP for #8410484
        IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Checking obsolete doc attach');
	END IF;

	OPEN get_revision_status_code(P_DOC_REVISION_ID);
	FETCH get_revision_status_code INTO l_revision_status_code;
	CLOSE get_revision_status_code;
	--Obsolete document cannot be attached
	IF l_revision_status_code = 'OBSOLETE'
	THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSOLETE_DOC_ATTACH');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- To validate that two revisions of same document are not added if the use latest = yes for that
	-- document

	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Checking latest revision doc attach');
	END IF;
	--Number of records(other than this record) having this document attached and use_latest =Yes
	Select count(*) into l_counter
	From AHL_DOC_TITLE_ASSOS_B
	Where Aso_object_id = P_ASO_OBJECT_ID
	And Aso_object_type_code = p_aso_object_type_code
	And document_id = p_document_id
	And  USE_LATEST_REV_FLAG = 'Y'
	And doc_title_Asso_id <> nvl(p_doc_title_asso_id,0);

	-- Number of records having this document attached
	Select count(*) into l_counter1
	From AHL_DOC_TITLE_ASSOS_B
	Where Aso_object_id = p_aso_object_id
	And Aso_object_type_code = p_aso_object_type_code
	And document_id = p_document_id
	And doc_title_Asso_id <> nvl(p_doc_title_asso_id,0);

	-- If the new association is having Use Latest='Y' and some asssociaiton with this document id and object
	-- is already there in the table OR the table have at least one record with Use Latest ='Y' then error
	IF(P_USE_LATEST_REV_FLAG = 'Y' and  l_counter1 >0) OR (l_counter > 0 ) Then
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_ERROR');
		FND_MESSAGE.SET_TOKEN('DOC_NO',l_record);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	--To validate that if the Use Latest Flag='Y' then only the latest revision is allowed to attach.
	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Checking latest revsion 2');
	END IF;
	IF(P_USE_LATEST_REV_FLAG = 'Y')
	THEN
		-- If use latest = 'Y' then
		-- Validate that the revision to be associated is the latest revision
		SELECT MAX(doc_revision_id) INTO l_latest_doc_revision_id
		FROM ahl_doc_revisions_b
		WHERE NVL(effective_date,revision_date) = (SELECT MAX(NVL(effective_date,revision_date))
							   FROM ahl_doc_revisions_b
						           WHERE document_id = p_document_id
                                                	   AND NVL(effective_date,revision_date) <= SYSDATE
							   AND revision_status_code = 'CURRENT')
		AND document_id = p_document_id
	        AND revision_status_code = 'CURRENT';

		IF(p_doc_revision_id <> l_latest_doc_revision_id) THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_DI_NOT_LATEST_REVISION');
			FND_MESSAGE.SET_TOKEN('DOC_NO',l_record);
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'latest revision checked');
	END IF;
	-- End of FP #8410484
 END IF;
 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded      => FND_API.G_FALSE,
                               p_count        => x_msg_count,
                               p_data         => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded      => FND_API.G_FALSE,
                               p_count        => x_msg_count,
                               p_data         => X_msg_data);
 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>g_pkg_name,
                            p_procedure_name  =>'VALIDATE_ASSOCIATION',
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded      => FND_API.G_FALSE,
                               p_count        => x_msg_count,
                               p_data         => X_msg_data);
 END;




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
 x_return_status            OUT NOCOPY VARCHAR2                        ,
 x_msg_count                OUT NOCOPY NUMBER                          ,
 x_msg_data                 OUT NOCOPY VARCHAR2)
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
l_record                VARCHAR2(4000);
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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.Delete Association','+DOBJASS+');

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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Delete Association','+DOBJASS+');


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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Delete Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO delete_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PVT',
                            p_procedure_name  =>  'DELETE_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Delete Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END DELETE_ASSOCIATION;



/*------------------------------------------------------*/
/* procedure name: process_association                  */
/* description :  Creates/updates associations record   */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version                IN     NUMBER    :=  1.0             ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_association_tbl          IN OUT NOCOPY association_tbl        ,
 x_return_status              OUT NOCOPY VARCHAR2                      ,
 x_msg_count                  OUT NOCOPY NUMBER                        ,
 x_msg_data                   OUT NOCOPY VARCHAR2)
IS
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
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0);

--adharia check for dup recs in pc and mc only
CURSOR dup_rec_check_cre(c_aso_object_type_code VARCHAR2,
                     c_aso_object_id        NUMBER,
                     c_document_id          NUMBER,
                     c_doc_revision_id      NUMBER,
                     c_source_ref_code 	    VARCHAR2,
                     c_serial_no  	    VARCHAR2,
                     c_chapter  	    VARCHAR2,
	             c_section  	    VARCHAR2,
	             c_subject  	    VARCHAR2,
	             c_page     	    VARCHAR2,
	             c_figure   	    VARCHAR2)

 IS
SELECT doc_title_asso_id
  FROM AHL_DOC_TITLE_ASSOS_VL
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND nvl(source_ref_code,'$#@1X')=nvl(c_source_ref_code,'$#@1X')
   AND nvl(serial_no,'$#@1X')=nvl(c_serial_no,'$#@1X')
   AND nvl(chapter, '$#@1X') = nvl(c_chapter,'$#@1X')
   AND nvl(section, '$#@1X') = nvl(c_section,'$#@1X')
   AND nvl(subject, '$#@1X') = nvl(c_subject,'$#@1X')
   AND nvl(page, '$#@1X') = nvl(c_page,'$#@1X')
   AND nvl(figure, '$#@1X') = nvl(c_figure,'$#@1X');
--
CURSOR dup_rec_check_upd(c_doc_title_asso_id NUMBER,
		     c_aso_object_type_code VARCHAR2,
                     c_aso_object_id        NUMBER,
                     c_document_id          NUMBER,
                     c_doc_revision_id      NUMBER,
                     c_source_ref_code 	    VARCHAR2,
                     c_serial_no  	    VARCHAR2,
                     c_chapter  	    VARCHAR2,
	             c_section  	    VARCHAR2,
	             c_subject  	    VARCHAR2,
	             c_page     	    VARCHAR2,
	             c_figure   	    VARCHAR2)

 IS
SELECT doc_title_asso_id
  FROM AHL_DOC_TITLE_ASSOS_VL
  WHERE doc_title_asso_id <> c_doc_title_asso_id
   AND aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND nvl(source_ref_code,'$#@1X')=nvl(c_source_ref_code,'$#@1X')
   AND nvl(serial_no,'$#@1X')=nvl(c_serial_no,'$#@1X')
   AND nvl(chapter, '$#@1X') = nvl(c_chapter,'$#@1X')
   AND nvl(section, '$#@1X') = nvl(c_section,'$#@1X')
   AND nvl(subject, '$#@1X') = nvl(c_subject,'$#@1X')
   AND nvl(page, '$#@1X') = nvl(c_page,'$#@1X')
   AND nvl(figure, '$#@1X') = nvl(c_figure,'$#@1X');
-----------

 CURSOR get_doc_num(c_document_id NUMBER)
  IS
  SELECT document_no
    FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;
 --
---------- for update only
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
---------- for update only
 l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_ASSOCIATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_rowid                 ROWID;
 l_dummy                 VARCHAR2(2000);
 l_document_no           VARCHAR2(80);
 l_doc_title_asso_id     NUMBER;
 l_association_upd_info  get_doc_assos_rec_b_info%ROWTYPE;
 l_association_tl_info   get_doc_assos_rec_tl_info%ROWTYPE;
 l_record                VARCHAR(4000);
 l_found_flag             VARCHAR2(5)  := 'N';
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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.Process Association','+DOBJASS+');

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
        RECORD_IDENTIFIER
        (
	        p_association_rec     =>p_x_association_tbl(i),
	        x_record              =>l_record
        );
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'at end of validate the record pvt .... '||l_record,'+adhariamr+');
     END IF;
     IF G_DEBUG='Y' THEN
	   AHL_DEBUG_PUB.debug('DML FLAG ' || p_x_association_tbl(i).DML_OPERATION || ' Record ' || i || ' assos id ' ||  to_char(p_x_association_tbl(i).doc_title_asso_id));
     END IF;
        FOR j in p_x_association_tbl.FIRST..p_x_association_tbl.LAST
        LOOP
		IF((i <> j) AND (p_x_association_tbl(i).document_id=p_x_association_tbl(j).document_id) AND
                   (p_x_association_tbl(i).use_latest_rev_flag  = 'Y' OR
	            p_x_association_tbl(j).use_latest_rev_flag  = 'Y')) THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_ERROR');
			FND_MESSAGE.SET_TOKEN('DOC_NO',l_record);
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END LOOP;
        VALIDATE_ASSOCIATION
        (
	  x_return_status           => l_return_Status,
	  x_msg_count               => l_msg_count,
	  x_msg_data                => l_msg_data,
	  p_doc_title_asso_id       => p_x_association_tbl(i).doc_title_asso_id,
	  p_document_id             => p_x_association_tbl(i).document_id,
	  p_doc_revision_id         => p_x_association_tbl(i).doc_revision_id,
	  p_use_latest_rev_flag     => p_x_association_tbl(i).use_latest_rev_flag,
	  p_aso_object_type_code    => p_x_association_tbl(i).aso_object_type_code,
	  p_aso_object_id           => p_x_association_tbl(i).aso_object_id,
	  p_object_version_num      => p_x_association_tbl(i).object_version_number,
	  P_DML_OPERATION           => p_x_association_tbl(i).DML_OPERATION,
	  P_RECORD                  => L_RECORD
        );
        IF G_DEBUG='Y' THEN
	     AHL_DEBUG_PUB.debug( 'after validation check: '||l_record,'+adharia+');
        END IF;
	l_msg_count := FND_MSG_PUB.count_msg;

	IF l_msg_count > 0 THEN
		X_msg_count := l_msg_count;
		X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
     END LOOP;
   END IF;


   IF p_x_association_tbl.COUNT > 0
  THEN
     FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
     LOOP


      l_found_flag := 'N';

      IF    p_x_association_tbl(i).DML_OPERATION <> 'D'
      THEN
          IF p_x_association_tbl(i).aso_object_type_code IN ( 'PC', 'MC','ROUTE','OPERATION' ,'MR')
          THEN
           IF    p_x_association_tbl(i).DML_OPERATION = 'C'
           THEN

            OPEN dup_rec_check_cre(    c_aso_object_type_code => p_x_association_tbl(i).aso_object_type_code,
			        c_aso_object_id        => p_x_association_tbl(i).aso_object_id,
			        c_document_id          => p_x_association_tbl(i).document_id,
			        c_doc_revision_id      => p_x_association_tbl(i).doc_revision_id,
				c_source_ref_code      => p_x_association_tbl(i).source_Ref_code,
				c_serial_no            => p_x_association_tbl(i).serial_no,
			        c_chapter  	       => p_x_association_tbl(i).chapter,
			        c_section  	       => p_x_association_tbl(i).section,
			        c_subject  	       => p_x_association_tbl(i).subject,
			        c_page     	       => p_x_association_tbl(i).page,
			        c_figure   	       => p_x_association_tbl(i).figure);
	        FETCH dup_rec_check_cre INTO l_doc_title_asso_id;
		IF dup_rec_check_cre%FOUND  THEN

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
					FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;

				     END IF;
			       END IF;

			  END LOOP;
			  IF l_found_flag = 'N'
			  THEN
			    FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
			    FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
			    FND_MSG_PUB.ADD;
			    RAISE FND_API.G_EXC_ERROR;
			  END IF;

		 END IF;
		 CLOSE dup_rec_check_cre;




        ELSIF    p_x_association_tbl(i).DML_OPERATION = 'U'
        THEN
              AHL_DEBUG_PUB.debug( 'in update prithwi71+');
              OPEN dup_rec_check_upd(c_doc_title_asso_id => p_x_association_tbl(i).doc_title_asso_id,
		                c_aso_object_type_code => p_x_association_tbl(i).aso_object_type_code,
			        c_aso_object_id        => p_x_association_tbl(i).aso_object_id,
			        c_document_id          => p_x_association_tbl(i).document_id,
			        c_doc_revision_id      => p_x_association_tbl(i).doc_revision_id,
				c_source_ref_code      => p_x_association_tbl(i).source_Ref_code,
				c_serial_no            => p_x_association_tbl(i).serial_no,
			        c_chapter  	       => p_x_association_tbl(i).chapter,
			        c_section  	       => p_x_association_tbl(i).section,
			        c_subject  	       => p_x_association_tbl(i).subject,
			        c_page     	       => p_x_association_tbl(i).page,
			        c_figure   	       => p_x_association_tbl(i).figure);
	        FETCH dup_rec_check_upd INTO l_doc_title_asso_id;

		IF dup_rec_check_upd%FOUND  THEN

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
					FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;

				     END IF;
			       END IF;

			  END LOOP;
			  IF l_found_flag = 'N'
			  THEN
			    FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
			    FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
			    FND_MSG_PUB.ADD;
			    RAISE FND_API.G_EXC_ERROR;
			  END IF;

		 END IF;
		 CLOSE dup_rec_check_upd;
         END IF;

--------------------------------------------------------------------------

        ELSE
                OPEN dup_rec( p_x_association_tbl(i).aso_object_type_code,
			      p_x_association_tbl(i).aso_object_id,
			      p_x_association_tbl(i).document_id,
			      p_x_association_tbl(i).doc_revision_id);
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
				FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;

			     END IF;
			   END IF;

		   END LOOP;
		   IF l_found_flag = 'N'
		   THEN
			    FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
			    FND_MESSAGE.SET_TOKEN('DUPRECORD',l_record);
			    FND_MSG_PUB.ADD;
			    RAISE FND_API.G_EXC_ERROR;
		    END IF;
		 END IF;
		 CLOSE dup_rec;

        END IF;
     END IF;-- chk dup for not delete recs

--------END CHECK FOR DUPLICATES-------------------------------------------------------------------

 --  END LOOP;

/*   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'after dup check: '||l_record,'+adharia+');
   END IF;

   --Standard call to message count
	   l_msg_count := FND_MSG_PUB.count_msg;

	   IF l_msg_count > 0 THEN
	      X_msg_count := l_msg_count;
	      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
*/
 --prithwi changing code
    -- FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
    -- LOOP

--------START DELETE-------------------------------------------------------------------------------
 IF    p_x_association_tbl(i).DML_OPERATION ='D'
 THEN
      DELETE_ASSOCIATION
        ( p_api_version        => 1.0                 ,
          p_init_msg_list      => FND_API.G_TRUE      ,
          p_commit             => FND_API.G_FALSE     ,
          p_validate_only      => FND_API.G_TRUE      ,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_association_rec    => p_x_association_tbl(i)    ,
          x_return_status      => x_return_status      ,
          x_msg_count          => x_msg_count          ,
          x_msg_data           => x_msg_data);
-----------------------------END DELETE-----------------------------------------------------------------------
-----------------------------START UPDATE-----------------------------------------------------------------------
 ELSIF    p_x_association_tbl(i).DML_OPERATION ='U'
 THEN
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'bafore update Association','+DOBJASS+');
   END IF;

       --Open the record from base table
       OPEN get_doc_assos_rec_b_info(p_x_association_tbl(i).doc_title_asso_id);
       FETCH get_doc_assos_rec_b_info INTO l_association_upd_info;
       CLOSE get_doc_assos_rec_b_info;
       -- Get the record from trans table
       OPEN get_doc_assos_rec_tl_info(p_x_association_tbl(i).doc_title_asso_id);
       FETCH get_doc_assos_rec_tl_info INTO l_association_tl_info;
       CLOSE get_doc_assos_rec_tl_info;

    IF (l_association_upd_info.object_version_number <>p_x_association_tbl(i).object_version_number)
    THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
    ELSE
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'bafore 3 update Association','+DOBJASS+');
   END IF;

/*-------------------------------------------------------- */
/* procedure name: AHL_DOC_TITLE_ASSOS_PKG.UPDATE_ROW      */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
        -- Update doc title assos table and trans table
	AHL_DOC_TITLE_ASSOS_PKG.UPDATE_ROW(
		X_DOC_TITLE_ASSO_ID            	=>	p_x_association_tbl(i).doc_title_asso_id,
		X_SERIAL_NO                    	=>	p_x_association_tbl(i).serial_no,
		X_ATTRIBUTE_CATEGORY           	=>	p_x_association_tbl(i).attribute_category,
		X_ATTRIBUTE1                   	=>	p_x_association_tbl(i).attribute1,
		X_ATTRIBUTE2                   	=>	p_x_association_tbl(i).attribute2,
		X_ATTRIBUTE3                   	=>	p_x_association_tbl(i).attribute3,
		X_ATTRIBUTE4                   	=>	p_x_association_tbl(i).attribute4,
		X_ATTRIBUTE5                   	=>	p_x_association_tbl(i).attribute5,
		X_ATTRIBUTE6                   	=>	p_x_association_tbl(i).attribute6,
		X_ATTRIBUTE7                   	=>	p_x_association_tbl(i).attribute7,
		X_ATTRIBUTE8                   	=>	p_x_association_tbl(i).attribute8,
		X_ATTRIBUTE9                   	=>	p_x_association_tbl(i).attribute9,
		X_ATTRIBUTE10                  	=>	p_x_association_tbl(i).attribute10,
		X_ATTRIBUTE11                  	=>	p_x_association_tbl(i).attribute11,
		X_ATTRIBUTE12                  	=>	p_x_association_tbl(i).attribute12,
		X_ATTRIBUTE13                  	=>	p_x_association_tbl(i).attribute13,
		X_ATTRIBUTE14                  	=>	p_x_association_tbl(i).attribute14,
		X_ATTRIBUTE15                  	=>	p_x_association_tbl(i).attribute15,
		X_ASO_OBJECT_TYPE_CODE         	=>	p_x_association_tbl(i).aso_object_type_code,
        	X_SOURCE_REF_CODE               =>      p_x_association_tbl(i).source_ref_code,
		X_ASO_OBJECT_ID                	=>	p_x_association_tbl(i).aso_object_id,
		X_DOCUMENT_ID                  	=>	p_x_association_tbl(i).document_id,
		X_USE_LATEST_REV_FLAG          	=>	p_x_association_tbl(i).use_latest_rev_flag,
		X_DOC_REVISION_ID              	=>	p_x_association_tbl(i).doc_revision_id,
		X_OBJECT_VERSION_NUMBER        	=>	p_x_association_tbl(i).object_version_number+1,
		X_CHAPTER                      	=>	p_x_association_tbl(i).chapter,
		X_SECTION                      	=>	p_x_association_tbl(i).section,
		X_SUBJECT                      	=>	p_x_association_tbl(i).subject,
		X_FIGURE                       	=>	p_x_association_tbl(i).figure,
		X_PAGE                         	=>	p_x_association_tbl(i).page,
		X_NOTE                         	=>	p_x_association_tbl(i).note,
		X_LAST_UPDATE_DATE             	=>	sysdate,
		X_LAST_UPDATED_BY              	=>	fnd_global.user_id,
		X_LAST_UPDATE_LOGIN            	=>	fnd_global.login_id);

    END IF;

-----------------------------END UPDATE-----------------------------------------------------------------------

-----------------------------START CREATE-----------------------------------------------------------------------
 ELSIF    p_x_association_tbl(i).DML_OPERATION ='C'
 THEN
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
		X_SERIAL_NO                    	=>	p_x_association_tbl(i).serial_no,
		X_ATTRIBUTE_CATEGORY           	=>	p_x_association_tbl(i).attribute_category,
		X_ATTRIBUTE1                   	=>	p_x_association_tbl(i).attribute1,
		X_ATTRIBUTE2                   	=>	p_x_association_tbl(i).attribute2,
		X_ATTRIBUTE3                   	=>	p_x_association_tbl(i).attribute3,
		X_ATTRIBUTE4                   	=>	p_x_association_tbl(i).attribute4,
		X_ATTRIBUTE5                   	=>	p_x_association_tbl(i).attribute5,
		X_ATTRIBUTE6                   	=>	p_x_association_tbl(i).attribute6,
		X_ATTRIBUTE7                   	=>	p_x_association_tbl(i).attribute7,
		X_ATTRIBUTE8                   	=>	p_x_association_tbl(i).attribute8,
		X_ATTRIBUTE9                   	=>	p_x_association_tbl(i).attribute9,
		X_ATTRIBUTE10                  	=>	p_x_association_tbl(i).attribute10,
		X_ATTRIBUTE11                  	=>	p_x_association_tbl(i).attribute11,
		X_ATTRIBUTE12                  	=>	p_x_association_tbl(i).attribute12,
		X_ATTRIBUTE13                  	=>	p_x_association_tbl(i).attribute13,
		X_ATTRIBUTE14                  	=>	p_x_association_tbl(i).attribute14,
		X_ATTRIBUTE15                  	=>	p_x_association_tbl(i).attribute15,
		X_ASO_OBJECT_TYPE_CODE         	=>	p_x_association_tbl(i).aso_object_type_code,
        	X_SOURCE_REF_CODE               =>      p_x_association_tbl(i).source_ref_code,
		X_ASO_OBJECT_ID                	=>	p_x_association_tbl(i).aso_object_id,
		X_DOCUMENT_ID                  	=>	p_x_association_tbl(i).document_id,
		X_USE_LATEST_REV_FLAG          	=>	nvl(p_x_association_tbl(i).use_latest_rev_flag,'N'),
		X_DOC_REVISION_ID              	=>	p_x_association_tbl(i).doc_revision_id,
		X_OBJECT_VERSION_NUMBER        	=>	1,
		X_CHAPTER                      	=>	p_x_association_tbl(i).chapter,
		X_SECTION                      	=>	p_x_association_tbl(i).section,
		X_SUBJECT                      	=>	p_x_association_tbl(i).subject,
		X_FIGURE                       	=>	p_x_association_tbl(i).figure,
		X_PAGE                         	=>	p_x_association_tbl(i).page,
		X_NOTE                         	=>	p_x_association_tbl(i).note,
		X_CREATION_DATE                	=>	sysdate,
		X_CREATED_BY                    =>	fnd_global.user_id,
		X_LAST_UPDATE_DATE             	=>	sysdate,
		X_LAST_UPDATED_BY              	=>	fnd_global.user_id,
		X_LAST_UPDATE_LOGIN            	=>	fnd_global.login_id);
     --Assign the doc title asso id,object version number
     p_x_association_tbl(i).doc_title_asso_id     := l_doc_title_asso_id;
     p_x_association_tbl(i).object_version_number := 1;
   --Standard check to count messages
-----------------------------END CREATE------------------------------------------------------------------------
  END IF;--CREATE/EDIT/DELETE
 END LOOP;

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'afte all  update Association','+DOBJASS+');
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'l_msg_count- ' || l_msg_count);
   END IF;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

END IF;
   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'before commit');
      END IF;
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
    ROLLBACK TO process_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

         --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Create Association','+DOBJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Create Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO process_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PVT',
                            p_procedure_name  =>  'PROCESS_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Create Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END PROCESS_ASSOCIATION;

PROCEDURE INSERT_ASSOC_REC
(
 p_api_version                IN     NUMBER    :=  1.0             ,
 p_init_msg_list              IN     VARCHAR2  := Fnd_Api.G_TRUE   ,
 p_commit                     IN     VARCHAR2  := Fnd_Api.G_FALSE  ,
 p_validate_only              IN     VARCHAR2  := Fnd_Api.G_TRUE   ,
 p_validation_level           IN     NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
 p_association_rec            IN     ahl_doc_title_assos_vl%ROWTYPE        ,
 x_return_status              OUT NOCOPY VARCHAR2                      ,
 x_msg_count                  OUT NOCOPY NUMBER                        ,
 x_msg_data                   OUT NOCOPY VARCHAR2)
IS
-- Used to check for duplicate records
CURSOR dup_rec_check(c_aso_object_type_code VARCHAR2,
                     c_aso_object_id        NUMBER,
                     c_document_id          NUMBER,
                     c_doc_revision_id      NUMBER,
                     c_source_ref_code 	    VARCHAR2,
                     c_serial_no  	    VARCHAR2,
                     c_chapter  	    VARCHAR2,
	             c_section  	    VARCHAR2,
	             c_subject  	    VARCHAR2,
	             c_page     	    VARCHAR2,
	             c_figure   	    VARCHAR2)

 IS
SELECT doc_title_asso_id
  FROM AHL_DOC_TITLE_ASSOS_VL
  WHERE aso_object_id = c_aso_object_id
   AND aso_object_type_code = c_aso_object_type_code
   AND document_id = c_document_id
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND nvl(source_ref_code,'$#@1X')=nvl(c_source_ref_code,'$#@1X')
   AND nvl(serial_no,'$#@1X')=nvl(c_serial_no,'$#@1X')
   AND nvl(chapter, '$#@1X') = nvl(c_chapter,'$#@1X')
   AND nvl(section, '$#@1X') = nvl(c_section,'$#@1X')
   AND nvl(subject, '$#@1X') = nvl(c_subject,'$#@1X')
   AND nvl(page, '$#@1X') = nvl(c_page,'$#@1X')
   AND nvl(figure, '$#@1X') = nvl(c_figure,'$#@1X');


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
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_rowid                 ROWID;
 l_dummy                 VARCHAR2(2000);
 l_document_no           VARCHAR2(80);
 l_doc_title_asso_id     NUMBER;
 l_association_info      association_rec;
 l_record                VARCHAR2(4000);
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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.Insert Assoc Rec','+DOBJASS+');

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
        L_RECORD:='';
        VALIDATE_ASSOCIATION
        (
	  x_return_status           => l_return_Status,
	  x_msg_count               => l_msg_count,
	  x_msg_data                => l_msg_data,
	  p_doc_title_asso_id       => p_association_rec.doc_title_asso_id,
	  p_document_id             => p_association_rec.document_id,
	  p_doc_revision_id         => p_association_rec.doc_revision_id,
	  p_use_latest_rev_flag     => p_association_rec.use_latest_rev_flag,
	  p_aso_object_type_code    => p_association_rec.aso_object_type_code,
	  p_aso_object_id           => p_association_rec.aso_object_id,
	  p_object_version_num      => '1',
	  P_DML_OPERATION           => 'X',
	  P_RECORD                  => L_RECORD
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
	IF (p_association_rec.aso_object_type_code IN ('MC'))
        THEN
                   OPEN dup_rec_check(  c_aso_object_type_code =>p_association_rec.aso_object_type_code,
				        c_aso_object_id        => p_association_rec.aso_object_id,
				        c_document_id          => p_association_rec.document_id,
				        c_doc_revision_id      => p_association_rec.doc_revision_id,
					c_source_ref_code      => p_association_rec.source_Ref_code,
					c_serial_no            => p_association_rec.serial_no,
				        c_chapter  	       => p_association_rec.chapter,
				        c_section  	       => p_association_rec.section,
				        c_subject  	       => p_association_rec.subject,
				        c_page     	       => p_association_rec.page,
				        c_figure   	       => p_association_rec.figure);
	        FETCH dup_rec_check INTO l_dummy;
	        IF dup_rec_check%FOUND  THEN
	    	   Fnd_Message.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DUP_RECORD');
	           Fnd_Message.SET_TOKEN('DUPRECORD',l_document_no);
	           Fnd_Msg_Pub.ADD;
	           RAISE Fnd_Api.G_EXC_ERROR;
	         END IF;
	         CLOSE dup_rec_check;
	ELSE
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
        END IF;



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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.INSERT Assoc Rec','+DOBJASS+');


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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT. INSERT Assoc Rec','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO insert_assoc_rec;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PVT',
                            p_procedure_name  =>  'INSERT_ASSOC_REC',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.INSERT Assoc Rec','+DOCJASS+');


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
 x_return_status              OUT NOCOPY VARCHAR2                     ,
 x_msg_count                  OUT NOCOPY NUMBER                       ,
 x_msg_data                   OUT NOCOPY VARCHAR2)
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
 l_row_id                VARCHAR2(30);
 l_association_rec       get_assos_b_cur%ROWTYPE;
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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.Copy Association','+DOBJASS+');

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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.Copy Association:'||p_from_object_id ,'+DOBJASS+');

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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Copy Association','+DOBJASS+');


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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Copy Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO copy_association;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PVT',
                            p_procedure_name  =>  'COPY_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.Copy Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.

		  AHL_DEBUG_PUB.disable_debug;

	END IF;

END COPY_ASSOCIATION;
--



PROCEDURE DELETE_ALL_ASSOCIATIONS
(
 p_api_version              IN    NUMBER    := 1.0              ,
 p_init_msg_list            IN    VARCHAR2  := FND_API.G_TRUE     ,
 p_commit                   IN    VARCHAR2  := FND_API.G_FALSE    ,
 p_validate_only            IN    VARCHAR2  := FND_API.G_TRUE     ,
 p_validation_level         IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_aso_object_type_code       IN      VARCHAR2 ,
 p_aso_object_id              IN      NUMBER ,
 x_return_status            OUT NOCOPY VARCHAR2                        ,
 x_msg_count                OUT NOCOPY NUMBER                          ,
 x_msg_data                 OUT NOCOPY VARCHAR2)
IS


 l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_ALL_ASSOCIATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER       := 0;
CURSOR get_all_doc_assos (c_object_id  NUMBER,
                          c_object_type_code VARCHAR2)
 IS
 SELECT * FROM AHL_DOC_TITLE_ASSOS_B
   WHERE ASO_OBJECT_ID        = c_object_id
     AND ASO_OBJECT_TYPE_CODE = c_object_type_code;

 l_doc_asso_rec    get_all_doc_assos%ROWTYPE;
 l_count_assoc     NUMBER := 0;
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
		  AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.delete all Association','+DOBJASS+');

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

	 AHL_DEBUG_PUB.debug( 'enter AHL_DI_ASSO_DOC_GEN_PVT.delete all Association:'||p_aso_object_id   ,'+DOBJASS+');

   END IF;
   --Start of API Body

   --for validation purposes

   IF (p_validate_only = 'Y') THEN
        OPEN get_all_doc_assos( c_object_id        =>  p_aso_object_id ,
                                c_object_type_code =>  p_aso_object_type_code );
        LOOP

   	FETCH get_all_doc_assos INTO l_doc_asso_rec;
   	EXIT WHEN get_all_doc_assos%NOTFOUND;
   	IF get_all_doc_assos%FOUND
   	THEN

   	   l_count_assoc := l_count_assoc + 1;
   	   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_NOT_FOUND');
   	   FND_MSG_PUB.ADD;
   	   AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.delete all Association: the revision id of revision deleted is '|| l_doc_asso_rec.doc_revision_id);
   	END IF;

   	END LOOP;

	CLOSE get_all_doc_assos;

	IF l_count_assoc = 0
	THEN
	   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_NOT_FOUND');
	   FND_MSG_PUB.ADD;
   	   AHL_DEBUG_PUB.debug( 'no revisions found that are attached to the object id'||  p_aso_object_id );
	ELSE

	   FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ASSOS_DELETED');
	   FND_MSG_PUB.ADD;
   	   AHL_DEBUG_PUB.debug( 'number of revisions found that are attached to the object id'||  p_aso_object_id ||' are '|| l_count_assoc);

	END IF;

   END IF;

   -- Knocking off all doc associations from the particular ASO object...
	DELETE
	FROM AHL_DOC_TITLE_ASSOS_TL
	WHERE	DOC_TITLE_ASSO_ID IN (
		SELECT DOC_TITLE_ASSO_ID
		FROM   AHL_DOC_TITLE_ASSOS_B
		WHERE	aso_object_type_code = p_aso_object_type_code  and
			aso_object_id = p_aso_object_id
	);

	DELETE
	FROM AHL_DOC_TITLE_ASSOS_B
	WHERE	aso_object_type_code = p_aso_object_type_code and
		aso_object_id = p_aso_object_id;

	 AHL_DEBUG_PUB.debug( 'exit AHL_DI_ASSO_DOC_GEN_PVT.delete all Association:'||p_aso_object_id   ,'+DOBJASS+');

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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.delete all Association','+DOBJASS+');


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
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.delete all Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO copy_association;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PVT',
                            p_procedure_name  =>  'DELETE_ALL_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PVT.delete all Association','+DOCJASS+');


        -- Check if API is called in debug mode. If yes, disable debug.

		  AHL_DEBUG_PUB.disable_debug;

	END IF;




END DELETE_ALL_ASSOCIATIONS;

--
END AHL_DI_ASSO_DOC_GEN_PVT;

/
