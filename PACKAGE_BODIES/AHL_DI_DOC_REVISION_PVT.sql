--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_REVISION_PVT" AS
/* $Header: AHLVDORB.pls 120.0.12010000.5 2010/04/23 09:18:52 snarkhed ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_DOC_REVISION_PVT';
--
/*---------------------------------------------------------*/
/* procedure name: validate_revision(private procedure)    */
/* description :  Validation checks for before inserting   */
/*                new record as well before modification   */
/*                takes place                              */
/*---------------------------------------------------------*/

G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE VALIDATE_REVISION
(
 P_DOC_REVISION_ID        IN    NUMBER    ,
 P_DOCUMENT_ID            IN    NUMBER    ,
 P_REVISION_NO            IN    VARCHAR2  ,
 P_REVISION_TYPE_CODE     IN    VARCHAR2  ,
 P_REVISION_STATUS_CODE   IN    VARCHAR2  ,
 P_REVISION_DATE          IN    DATE      ,
 P_APPROVED_BY_PARTY_ID   IN    NUMBER    ,
 P_APPROVED_DATE          IN    DATE      ,
 P_EFFECTIVE_DATE         IN    DATE      ,
 P_OBSOLETE_DATE          IN    DATE      ,
 P_ISSUE_DATE             IN    DATE      ,
 P_RECEIVED_DATE          IN    DATE      ,
 P_MEDIA_TYPE_CODE        IN    VARCHAR2  ,
 P_ISSUE_NUMBER           IN    NUMBER    ,
 P_DELETE_FLAG            IN    VARCHAR2  := 'N' )
IS

--Cursor to retrieve the revision type code
CURSOR get_revision_type_code(c_revision_type_code VARCHAR2)
 IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_code = c_revision_type_code
   AND lookup_type = 'AHL_REVISION_TYPE'
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

--Cursor to retrieve revision status code
CURSOR get_revision_status_code(c_revision_status_code VARCHAR2)
 IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_code = c_revision_status_code
   AND lookup_type = 'AHL_REVISION_STATUS_TYPE'
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

--Cursor to retrieve media type code
CURSOR get_media_type_code(c_media_type_code VARCHAR2)
 IS
SELECT lookup_code
  FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_code = c_media_type_code
   AND lookup_type = 'AHL_MEDIA_TYPE'
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

 -- Used to validate the document id
CURSOR check_doc_info(c_document_id  NUMBER)
 IS
SELECT 'X'
  FROM AHL_DOCUMENTS_B
 WHERE document_id  = c_document_id;

-- Retrieves doc revision record
CURSOR get_doc_revision_rec_info (c_doc_revision_id NUMBER)
 IS
SELECT document_id,
       revision_no,
       revision_type_code,
       revision_status_code,
       revision_date,
       approved_by_party_id,
       approved_date,
       effective_date,
       obsolete_date,
       issue_date,
       received_date,
       media_type_code,
       issue_number
  FROM AHL_DOC_REVISIONS_B
 WHERE doc_revision_id = c_doc_revision_id;

-- Check for Duplicate Record
CURSOR dup_rec(c_document_id  NUMBER,
               c_revision_no VARCHAR2)
 IS
SELECT 'X'
  FROM AHL_DOC_REVISIONS_B
WHERE document_id = c_document_id
  AND revision_no = c_revision_no;

--Modified pjha 25-Jun-2002 for restricting Media Type to Electronic File
--if there is a file uploaded for the document : Begin
--Cursor to check if record exist in IBC_CITEM_LIVE_V
CURSOR get_record_from_AHL(c_doc_revision_id VARCHAR2)
IS
SELECT '1'
FROM AHL_DOC_FILE_ASSOC_V
WHERE revision_id = c_doc_revision_id;
--Modified pjha 25-Jun-2002 for restricting Media Type to Electronic File
--if there is a file uploaded for the document : End
 --
 l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_REVISION';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_dummy                    VARCHAR2(2000);
 l_doc_revision_id          NUMBER;
 l_revision_no              VARCHAR2(30);
 l_document_id              NUMBER;
 l_revision_type_code       VARCHAR2(30);
 l_revision_status_code     VARCHAR2(30);
 l_revision_date            DATE;
 l_approved_by_party_id     NUMBER;
 l_approved_date            DATE;
 l_effective_date           DATE;
 l_obsolete_date            DATE;
 l_issue_date               DATE;
 l_received_date            DATE;
 l_media_type_code          VARCHAR2(30);
 l_media_type_meaning       VARCHAR2(80);
 l_issue_number             NUMBER;

 BEGIN
   --When the delete flag is 'YES' means either insert or update
   IF NVL(p_delete_flag,'N')  <> 'Y'
   THEN
    IF p_doc_revision_id IS NOT NULL
    THEN
       OPEN get_doc_revision_rec_info(p_doc_revision_id);
       FETCH get_doc_revision_rec_info INTO l_document_id,
                                            l_revision_no,
                                            l_revision_type_code,
                                            l_revision_status_code,
                                            l_revision_date,
                                            l_approved_by_party_id,
                                            l_approved_date,
                                            l_effective_date,
                                            l_obsolete_date,
                                            l_issue_date,
                                            l_received_date,
                                            l_media_type_code,
                                            l_issue_number;
       CLOSE get_doc_revision_rec_info;
    END IF;
    --
    IF p_document_id IS NOT NULL
    THEN
        l_document_id := p_document_id;
    END IF;
    --
    IF p_revision_no IS NOT NULL
    THEN
        l_revision_no := p_revision_no;
    END IF;
    --
    IF p_revision_type_code IS NOT NULL
    THEN
        l_revision_type_code := p_revision_type_code;
    END IF;
    --
    IF p_revision_status_code IS NOT NULL
    THEN
        l_revision_status_code := p_revision_status_code;
    END IF;
    --
    IF p_revision_date IS NOT NULL
    THEN
        l_revision_date := p_revision_date;
    END IF;
    --
    IF p_approved_by_party_id IS NOT NULL
    THEN
        l_approved_by_party_id := p_approved_by_party_id;
    END IF;
    --
    IF p_approved_date IS NOT NULL
    THEN
        l_approved_date := p_approved_date;
    END IF;
    --
    IF p_effective_date IS NOT NULL
    THEN
        l_effective_date := p_effective_date;
    END IF;
    --
    IF p_obsolete_date IS NOT NULL
    THEN
        l_obsolete_date := p_obsolete_date;
    END IF;
    --
    IF p_media_type_code IS NOT NULL
    THEN
        l_media_type_code := p_media_type_code;
    END IF;
    --
    IF p_issue_number IS NOT NULL
    THEN
        l_issue_number := p_issue_number;
    END IF;
       l_doc_revision_id := p_doc_revision_id;
    -- This condition checks Document Id, when the action is insert or update
     IF ((p_doc_revision_id IS NULL AND
         p_document_id IS NULL)
        OR

        (p_doc_revision_id IS NOT NULL
        AND l_document_id IS NULL))

     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks fro Revision Number, when the action is insert or update
     IF ((p_doc_revision_id IS NULL AND
        p_revision_no IS NULL)
        OR

        (p_doc_revision_id IS NOT NULL
        AND l_revision_no IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_REVISION_NO_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks for Revision Type Code
     IF ((p_doc_revision_id IS NULL AND
        p_revision_type_code IS NULL)
        OR

        (p_doc_revision_id IS NOT NULL
        AND l_revision_type_code IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_TYPE_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks for Revision Status Code
     IF ((p_doc_revision_id IS NULL AND
        p_revision_status_code IS NULL)
        OR

        (p_doc_revision_id IS NOT NULL
        AND l_revision_status_code IS NULL))

     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_STATUS_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- Checks for existence of Revision type code in fnd lookups
    IF p_revision_type_code IS NOT NULL
    THEN
       OPEN get_revision_type_code(p_revision_type_code);
       FETCH get_revision_type_code INTO l_dummy;
       IF get_revision_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_TYPE_CODE_NOT_EXIST');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_revision_type_code;
     END IF;
     --Checks for existence of Revision Status Code in fnd lookups
    IF p_revision_status_code IS NOT NULL
    THEN
       OPEN get_revision_status_code(p_revision_status_code);
       FETCH get_revision_status_code INTO l_dummy;
       IF get_revision_status_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_STAT_CODE_NOT_EXIST');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_revision_status_code;
     END IF;
    -- Checks for existence of Media Type Code in fnd lookups
    IF p_media_type_code IS NOT NULL
    THEN
       OPEN get_media_type_code(p_media_type_code);
       FETCH get_media_type_code INTO l_dummy;
       IF get_media_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_media_type_code;
     END IF;

     --Modified pjha 25-Jun-2002 for restricting Media Type to Electronic File
     --if there is a file uploaded for the document : Begin
     IF (p_media_type_code IS NULL OR p_media_type_code <> 'E-FILE')
     THEN
        OPEN get_record_from_AHL(l_doc_revision_id);
        FETCH get_record_from_AHL into l_dummy;
        IF get_record_from_AHL%FOUND THEN
          --{{adharia to add a token to the message
          SELECT MEANING into l_media_type_meaning
          FROM FND_LOOKUP_VALUES_VL
          WHERE LOOKUP_TYPE='AHL_MEDIA_TYPE' AND LOOKUP_CODE='E-FILE';

          FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_NOT_EFILE');
          FND_MESSAGE.SET_TOKEN('EFILE',l_media_type_meaning);
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_record_from_AHL;
     END IF;
     --Modified pjha 25-Jun-2002 for restricting Media Type to Electronic File
     --if there is a file uploaded for the document : End

    -- Validates for existence of document id in ahl documents table
    IF p_document_id IS NOT NULL
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

   -- Validates the Issue Number
   IF p_issue_number IS NOT NULL
      OR
      l_issue_number IS NOT NULL
   THEN
     IF(p_issue_number <= 0 or l_issue_number <= 0)
     THEN
       FND_MESSAGE.SET_NAME('AHL','AHL_DI_ISSUE_NUM_INVALID');
       FND_MSG_PUB.ADD;
     END IF;
   END IF;
  --Validations for Duplicate Record
  IF p_doc_revision_id IS NULL
  THEN
     OPEN dup_rec(l_document_id, l_revision_no);
     FETCH dup_rec INTO l_dummy;
        IF dup_rec%FOUND THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_REVISION_DUP_RECORD');
         FND_MSG_PUB.ADD;
        END IF;
     CLOSE dup_rec;
  END IF;

END IF;
END VALIDATE_REVISION;

-- FP for Bug #8410484
PROCEDURE UPDATE_ASSOCIATIONS
(
	p_doc_revision_id	IN	NUMBER	:=NULL,
	p_document_id		IN	NUMBER	:=NULL
)
IS
	--Cursor to get Association Records
	CURSOR get_association_records(c_document_id NUMBER)
	IS
	SELECT doc_title_asso_id,object_version_number,last_update_date,last_updated_by,last_update_login,
		aso_object_type_code,aso_object_id
	FROM AHL_DOC_TITLE_ASSOS_B
	WHERE document_id = c_document_id
	AND use_latest_rev_flag = 'Y';

	l_asso_record	get_association_records%rowtype;

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
	FROM ahl_mc_headers_b header,ahl_mc_relationships relation
	WHERE relation.relationship_id =  c_relationship_id
	AND header.mc_header_id = relation.mc_header_id;

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

		--Cursor to get Operation Status
	CURSOR get_operation_status(c_operation_id NUMBER)
	IS
	SELECT revision_status_code
	FROM ahl_operations_b
	WHERE operation_id = c_operation_id;

		--Cursor to get Route Status
	CURSOR get_route_status(c_route_id NUMBER)
	IS
	SELECT revision_status_code
	FROM ahl_routes_b
	WHERE route_id = c_route_id;

	l_revision_status_code		VARCHAR2(30):= NULL;
	l_object_status_code		VARCHAR2(30):= NULL;
	l_latest_doc_revision_id	NUMBER:= NULL;

BEGIN
	--Query to select the latest revision id
	SELECT MAX(doc_revision_id) INTO l_latest_doc_revision_id
	FROM ahl_doc_revisions_b
	WHERE NVL(effective_date,revision_date) = (SELECT MAX(NVL(effective_date,revision_date))
							   FROM ahl_doc_revisions_b
						           WHERE document_id = p_document_id
                                                	   AND NVL(effective_date,revision_date) <= SYSDATE
							   AND revision_status_code = 'CURRENT')
		AND document_id = p_document_id
		AND revision_status_code = 'CURRENT';
	-- If concurrent program is the caller then p_doc_revision_id is passed as null.So in this case
	-- l_latest_doc_revision_id will be used for updating the association table.
	-- If this procdure is not called by concurrent program then if the new/modified revision(of which
        -- revision id is passed) is not latest then the program will return at this point.
	IF p_doc_revision_id IS NOT NULL AND l_latest_doc_revision_id <> p_doc_revision_id THEN
		RETURN ;
	END IF;
	-- If no 'Current' revision of the document is available(i.e. all the revisions are 'Obsolete'
	-- and the document is associated with Use Latest Flag ='Yes' then keep the association as it is.

	IF l_latest_doc_revision_id IS NULL THEN
		RETURN ;
	END IF;

	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Got Max Revision Id' || l_latest_doc_revision_id);
	END IF;


	-- For each association record which has use_latest_flag = 'Y' and this document is attached,
	-- the following piece of code will update the document association table with the latest revision.
	OPEN get_association_records(p_document_id);
	LOOP
		FETCH get_association_records INTO l_asso_record;
		EXIT WHEN get_association_records%NOTFOUND;
		IF l_asso_record.aso_object_type_code = 'MR' THEN
			OPEN get_mr_status(l_asso_record.aso_object_id);
			FETCH get_mr_status INTO l_object_status_code;
			CLOSE get_mr_status;
		ELSIF l_asso_record.aso_object_type_code = 'ROUTE' THEN
			OPEN get_route_status(l_asso_record.aso_object_id);
			FETCH get_route_status INTO l_object_status_code;
			CLOSE get_route_status;
		ELSIF l_asso_record.aso_object_type_code = 'OPERATION' THEN
			OPEN get_operation_status(l_asso_record.aso_object_id);
			FETCH get_operation_status INTO l_object_status_code;
			CLOSE get_operation_status;
		ELSIF l_asso_record.aso_object_type_code = 'MC' THEN
			OPEN get_mc_status(l_asso_record.aso_object_id);
			FETCH get_mc_status INTO l_object_status_code;
			CLOSE get_mc_status;
		ELSIF l_asso_record.aso_object_type_code = 'PC' THEN
			OPEN get_pc_status(l_asso_record.aso_object_id);
			FETCH get_pc_status INTO l_object_status_code;
			CLOSE get_pc_status;
		END IF;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Object Status Code ' || l_object_status_code);
		END IF;
		-- Updation is allowed only if the associated object status is complete or approval rejected or
		-- draft.
		IF l_object_status_code = 'COMPLETE' OR l_object_status_code = 'APPROVAL_REJECTED'
		   OR l_object_status_code = 'DRAFT' THEN
			IF G_DEBUG='Y' THEN
				AHL_DEBUG_PUB.debug( 'Before Update in New Procedure' );
			END IF;
			UPDATE AHL_DOC_TITLE_ASSOS_B
				SET	doc_revision_id = l_latest_doc_revision_id,
					object_version_number = l_asso_record.object_version_number + 1,
					last_update_date = l_asso_record.last_update_date,
					last_updated_by =l_asso_record.last_updated_by,
					last_update_login = l_asso_record.last_update_login
				WHERE	doc_title_asso_id =l_asso_record.doc_title_asso_id;
		END IF;
	END LOOP;
	CLOSE get_association_records;
END UPDATE_ASSOCIATIONS;

-- FP end

/*------------------------------------------------------*/
/* procedure name: create_revision                      */
/* description :  Creates new revision record           */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE CREATE_REVISION
(
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN OUT NOCOPY revision_tbl              ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS
--
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_REVISION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_rowid                 ROWID;
 l_doc_revision_id       NUMBER;
 l_revision_info         revision_rec;
 --Added for storing local variables to pass to Table Handler- Prakash 26-Dec-2001
 l_row_id                   VARCHAR2(30);
 --End of addition: Prakash 26-dec-2001
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_revision;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_revision_pvt.Create Revision','+REV+');

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
    IF p_x_revision_tbl.COUNT > 0
    THEN
     FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
     LOOP
        -- Calling for Validation
        VALIDATE_REVISION
           (
             p_doc_revision_id        => p_x_revision_tbl(i).doc_revision_id,
             p_document_id            => p_x_revision_tbl(i).document_id,
             p_revision_no            => p_x_revision_tbl(i).revision_no,
             p_revision_type_code     => p_x_revision_tbl(i).revision_type_code,
             p_revision_status_code   => p_x_revision_tbl(i).revision_status_code,
             p_revision_date          => p_x_revision_tbl(i).revision_date,
             p_approved_by_party_id   => p_x_revision_tbl(i).approved_by_party_id,
             p_approved_date          => p_x_revision_tbl(i).approved_date,
             p_effective_date         => p_x_revision_tbl(i).effective_date,
             p_obsolete_date          => p_x_revision_tbl(i).obsolete_date,
             p_issue_date             => p_x_revision_tbl(i).issue_date,
             p_received_date          => p_x_revision_tbl(i).received_date,
             p_media_type_code        => p_x_revision_tbl(i).media_type_code,
             p_issue_number           => p_x_revision_tbl(i).issue_number,
             p_delete_flag            => p_x_revision_tbl(i).delete_flag
           );
      END LOOP;
   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;


   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
   LOOP
      IF  p_x_revision_tbl(i).doc_revision_id IS NULL
      THEN
         -- The following conditions should be checked for Optional Fields
             l_revision_info.approved_by_party_id := p_x_revision_tbl(i).approved_by_party_id;
            l_revision_info.revision_date := p_x_revision_tbl(i).revision_date;
            l_revision_info.approved_date := p_x_revision_tbl(i).approved_date;
            l_revision_info.effective_date := p_x_revision_tbl(i).effective_date;
            l_revision_info.obsolete_date := p_x_revision_tbl(i).obsolete_date;
            l_revision_info.issue_date := p_x_revision_tbl(i).issue_date;
            l_revision_info.received_date := p_x_revision_tbl(i).received_date;
            l_revision_info.url := p_x_revision_tbl(i).url;
            l_revision_info.media_type_code := p_x_revision_tbl(i).media_type_code;
            l_revision_info.volume := p_x_revision_tbl(i).volume;
            l_revision_info.issue := p_x_revision_tbl(i).issue;
            l_revision_info.issue_number := p_x_revision_tbl(i).issue_number;
            l_revision_info.comments := p_x_revision_tbl(i).comments;
            --snarkhed::Added this as part of bug fix for Bug #9532118

	    IF(p_x_revision_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute_category := NULL;
	    ELSE
		l_revision_info.attribute_category := p_x_revision_tbl(i).attribute_category;
	    END IF;


	    IF(p_x_revision_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute1 := NULL;
	    ELSE
		l_revision_info.attribute1 := p_x_revision_tbl(i).attribute1;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute2 := NULL;
	    ELSE
		l_revision_info.attribute2 := p_x_revision_tbl(i).attribute2;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute3 := NULL;
	    ELSE
		l_revision_info.attribute3 := p_x_revision_tbl(i).attribute3;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute4 := NULL;
	    ELSE
		l_revision_info.attribute4 := p_x_revision_tbl(i).attribute4;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute5 := NULL;
	    ELSE
		l_revision_info.attribute5 := p_x_revision_tbl(i).attribute5;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute6 := NULL;
	    ELSE
		l_revision_info.attribute6 := p_x_revision_tbl(i).attribute6;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute7 := NULL;
	    ELSE
		l_revision_info.attribute7 := p_x_revision_tbl(i).attribute7;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute8 := NULL;
	    ELSE
		l_revision_info.attribute8 := p_x_revision_tbl(i).attribute8;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute9 := NULL;
	    ELSE
		l_revision_info.attribute9 := p_x_revision_tbl(i).attribute9;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute10 := NULL;
	    ELSE
		l_revision_info.attribute10 := p_x_revision_tbl(i).attribute10;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute11:= NULL;
	    ELSE
		l_revision_info.attribute11 := p_x_revision_tbl(i).attribute11;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute12 := NULL;
	    ELSE
		l_revision_info.attribute12 := p_x_revision_tbl(i).attribute12;
	    END IF;

	    IF(p_x_revision_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute13 := NULL;
	    ELSE
		l_revision_info.attribute13 := p_x_revision_tbl(i).attribute13;
            END IF;

	    IF(p_x_revision_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute14 := NULL;
	    ELSE
	 	l_revision_info.attribute14 := p_x_revision_tbl(i).attribute14;
            END IF;

	    IF(p_x_revision_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute15 := NULL;
	    ELSE
	 	l_revision_info.attribute15 := p_x_revision_tbl(i).attribute15;
            END IF;

	    /*l_revision_info.attribute_category := p_x_revision_tbl(i).attribute_category;
            l_revision_info.attribute1 := p_x_revision_tbl(i).attribute1;
            l_revision_info.attribute2 := p_x_revision_tbl(i).attribute2;
            l_revision_info.attribute3 := p_x_revision_tbl(i).attribute3;
            l_revision_info.attribute4 := p_x_revision_tbl(i).attribute4;
            l_revision_info.attribute5 := p_x_revision_tbl(i).attribute5;
            l_revision_info.attribute6 := p_x_revision_tbl(i).attribute6;
            l_revision_info.attribute7 := p_x_revision_tbl(i).attribute7;
            l_revision_info.attribute8 := p_x_revision_tbl(i).attribute8;
            l_revision_info.attribute9 := p_x_revision_tbl(i).attribute9;
            l_revision_info.attribute10 := p_x_revision_tbl(i).attribute10;
            l_revision_info.attribute11 := p_x_revision_tbl(i).attribute11;
            l_revision_info.attribute12 := p_x_revision_tbl(i).attribute12;
            l_revision_info.attribute13 := p_x_revision_tbl(i).attribute13;
            l_revision_info.attribute14 := p_x_revision_tbl(i).attribute14;
            l_revision_info.attribute15 := p_x_revision_tbl(i).attribute15;*/
	    --End of changes for Bug 9532118
         -- Gets the value from sequence
        Select AHL_DOC_REVISIONS_B_S.Nextval Into l_doc_revision_id from dual;
        --Insert the record into doc revisions table
             AHL_DOC_REVISIONS_PKG.INSERT_ROW(X_ROWID => l_row_id,
             				      X_DOC_REVISION_ID => l_doc_revision_id,
             				      X_APPROVED_DATE => l_revision_info.approved_date,
             				      X_EFFECTIVE_DATE => l_revision_info.effective_date,
					      X_OBSOLETE_DATE => l_revision_info.obsolete_date,
					      X_ISSUE_DATE => l_revision_info.issue_date,
					      X_RECEIVED_DATE => l_revision_info.received_date,
					      X_URL => l_revision_info.url,
					      X_MEDIA_TYPE_CODE => l_revision_info.media_type_code,
					      X_VOLUME => l_revision_info.volume,
					      X_ISSUE => l_revision_info.issue,
					      X_ISSUE_NUMBER => l_revision_info.issue_number,
					      X_ATTRIBUTE_CATEGORY => l_revision_info.attribute_category,
					      X_ATTRIBUTE1 => l_revision_info.attribute1,
					      X_ATTRIBUTE2 => l_revision_info.attribute2,
					      X_REVISION_DATE => l_revision_info.revision_date,
					      X_ATTRIBUTE15 => l_revision_info.attribute15,
					      X_ATTRIBUTE9 => l_revision_info.attribute9,
					      X_ATTRIBUTE10 => l_revision_info.attribute10,
					      X_ATTRIBUTE11 => l_revision_info.attribute11,
					      X_ATTRIBUTE12 => l_revision_info.attribute12,
					      X_ATTRIBUTE13 => l_revision_info.attribute13,
					      X_DOCUMENT_ID => p_x_revision_tbl(i).document_id,
					      X_REVISION_NO => p_x_revision_tbl(i).revision_no,
					      X_APPROVED_BY_PARTY_ID => l_revision_info.approved_by_party_id,
					      X_REVISION_TYPE_CODE => p_x_revision_tbl(i).revision_type_code,
					      X_REVISION_STATUS_CODE => p_x_revision_tbl(i).revision_status_code,
					      X_OBJECT_VERSION_NUMBER => 1,
					      X_ATTRIBUTE3 => l_revision_info.attribute3,
					      X_ATTRIBUTE4 => l_revision_info.attribute4,
					      X_ATTRIBUTE5 => l_revision_info.attribute5,
					      X_ATTRIBUTE6 => l_revision_info.attribute6,
					      X_ATTRIBUTE7 => l_revision_info.attribute7,
					      X_ATTRIBUTE8 => l_revision_info.attribute8,
					      X_ATTRIBUTE14 => l_revision_info.attribute14,
					      X_COMMENTS => l_revision_info.comments,
					      X_CREATION_DATE => sysdate,
					      X_CREATED_BY => fnd_global.user_id,
					      X_LAST_UPDATE_DATE => sysdate,
					      X_LAST_UPDATED_BY => fnd_global.user_id,
                                              X_LAST_UPDATE_LOGIN => fnd_global.login_id);

	                -- FP for Bug #8410484
			UPDATE_ASSOCIATIONS(p_doc_revision_id => l_doc_revision_id,
					    p_document_id => p_x_revision_tbl(i).document_id);
			-- FP end

             /*Following line have been moved, since table handler does not take care of
             assignments: Prakash : 24-Dec-2001*/
             --Assign doc revision id
	            p_x_revision_tbl(i).doc_revision_id := l_doc_revision_id;
                    p_x_revision_tbl(i).object_version_number := 1;
        l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;
 END LOOP;
END IF;
   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private api Create Revision','+REV+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        --Debug Info
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Create Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Create Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_REVISION_PVT',
                            p_procedure_name  =>  'CREATE_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Create Revision','+REV+');

        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_REVISION;
/*------------------------------------------------------*/
/* procedure name: modify_revision                      */
/* description :  Update the existing revision record   */
/*                and removes the revision record       */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE MODIFY_REVISION
(
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN     revision_tbl                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
-- Used to retrieve the existing record info
CURSOR get_doc_revisions_b_rec_info(c_doc_revision_id  NUMBER)
 IS
SELECT ROWID,
       document_id,
       revision_no,
       revision_type_code,
       revision_status_code,
       revision_date,
       approved_by_party_id,
       approved_date,
       effective_date,
       obsolete_date,
       issue_date,
       received_date,
       url,
       media_type_code,
       volume,
       issue,
       issue_number,
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
  FROM AHL_DOC_REVISIONS_B
 WHERE doc_revision_id = c_doc_revision_id
   FOR UPDATE OF object_version_number NOWAIT;
--Used to retrieve the record from trans table
CURSOR get_doc_revisions_tl_rec_info(c_doc_revision_id NUMBER)
 IS
SELECT comments
  FROM AHL_DOC_REVISIONS_TL
 WHERE doc_revision_id = c_doc_revision_id
   FOR UPDATE OF doc_revision_id NOWAIT;
--
 l_api_name       CONSTANT VARCHAR2(30) := 'MODIFY_REVISION';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_msg_count               NUMBER;
 l_rowid                   ROWID;
 l_doc_revision_id         NUMBER;
 l_language                VARCHAR2(4);
 l_source_lang             VARCHAR2(4);
 l_comments                VARCHAR2(2000);
 l_revision_info           get_doc_revisions_b_rec_info%ROWTYPE;
 --
 BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_revision;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_revision_pvt.Modify Revision','+REV+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := 'S';

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --Start of API Body
   IF p_x_revision_tbl.COUNT > 0
   THEN
     FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
     LOOP
        --Calling for Validation
        VALIDATE_REVISION
         (
          p_doc_revision_id        => p_x_revision_tbl(i).doc_revision_id,
          p_document_id            => p_x_revision_tbl(i).document_id,
          p_revision_no            => p_x_revision_tbl(i).revision_no,
          p_revision_type_code     => p_x_revision_tbl(i).revision_type_code,
          p_revision_status_code   => p_x_revision_tbl(i).revision_status_code,
          p_revision_date          => p_x_revision_tbl(i).revision_date,
          p_approved_by_party_id   => p_x_revision_tbl(i).approved_by_party_id,
          p_approved_date          => p_x_revision_tbl(i).approved_date,
          p_effective_date         => p_x_revision_tbl(i).effective_date,
          p_obsolete_date          => p_x_revision_tbl(i).obsolete_date,
          p_issue_date             => p_x_revision_tbl(i).obsolete_date,
          p_received_date          => p_x_revision_tbl(i).obsolete_date,
          p_media_type_code        => p_x_revision_tbl(i).media_type_code,
          p_issue_number           => p_x_revision_tbl(i).issue_number,
          p_delete_flag            => p_x_revision_tbl(i).delete_flag
        );
      END LOOP;
   --End of Validations
   -- Standard call to get message count
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
   LOOP
      OPEN get_doc_revisions_b_rec_info(p_x_revision_tbl(i).doc_revision_id);
      FETCH get_doc_revisions_b_rec_info INTO l_revision_info;
      CLOSE get_doc_revisions_b_rec_info;
      --
      OPEN get_doc_revisions_tl_rec_info(p_x_revision_tbl(i).doc_revision_id);
      FETCH get_doc_revisions_tl_rec_info INTO l_comments;
      CLOSE get_doc_revisions_tl_rec_info;

    -- This  bug fix when concurrent users  update
    -- updating same record...02/05/02
    if (l_revision_info.object_version_number <>p_x_revision_tbl(i).object_version_number)
    then
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;
      -- The following conditions compare the new record value with old  record
      -- value, if its different then assign the new value else continue
      IF p_x_revision_tbl(i).doc_revision_id IS NOT NULL
      THEN
           l_revision_info.document_id := p_x_revision_tbl(i).document_id;
          l_revision_info.revision_no := p_x_revision_tbl(i).revision_no;
          l_revision_info.revision_type_code := p_x_revision_tbl(i).revision_type_code;
          l_revision_info.revision_date := p_x_revision_tbl(i).revision_date;
          l_revision_info.approved_by_party_id := p_x_revision_tbl(i).approved_by_party_id;
          l_revision_info.approved_date := p_x_revision_tbl(i).approved_date;
          l_revision_info.effective_date := p_x_revision_tbl(i).effective_date;
          l_revision_info.obsolete_date := p_x_revision_tbl(i).obsolete_date;
	  --FP for Bug #8410484
	  IF (trunc(l_revision_info.obsolete_date) <= trunc(sysdate)) THEN
		l_revision_info.revision_status_code := 'OBSOLETE';
	  ELSE
		l_revision_info.revision_status_code := p_x_revision_tbl(i).revision_status_code;
	  END IF;

	  IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'obs date ' || l_revision_info.obsolete_date);
		  AHL_DEBUG_PUB.debug( 'rev_status_code ' || l_revision_info.revision_status_code);
	  END IF;
	  -- End of FP
          l_revision_info.issue_date := p_x_revision_tbl(i).issue_date;
          l_revision_info.received_date := p_x_revision_tbl(i).received_date;
          l_revision_info.url := p_x_revision_tbl(i).url;
          l_revision_info.media_type_code := p_x_revision_tbl(i).media_type_code;
          l_revision_info.volume := p_x_revision_tbl(i).volume;
          l_revision_info.issue := p_x_revision_tbl(i).issue;
          l_revision_info.issue_number := p_x_revision_tbl(i).issue_number;
          l_comments := p_x_revision_tbl(i).comments;
          --snarkhed::Added this as part of bug fix for Bug #9532118

          IF(p_x_revision_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute_category := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute_category IS NOT NULL) THEN
		l_revision_info.attribute_category := p_x_revision_tbl(i).attribute_category;
	  END IF;


	  IF(p_x_revision_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute1 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute1 IS NOT NULL) THEN
		l_revision_info.attribute1 := p_x_revision_tbl(i).attribute1;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute2 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute2 IS NOT NULL) THEN
		l_revision_info.attribute2 := p_x_revision_tbl(i).attribute2;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute3 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute3 IS NOT NULL) THEN
		l_revision_info.attribute3 := p_x_revision_tbl(i).attribute3;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute4 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute4 IS NOT NULL) THEN
		l_revision_info.attribute4 := p_x_revision_tbl(i).attribute4;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute5 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute5 IS NOT NULL) THEN
		l_revision_info.attribute5 := p_x_revision_tbl(i).attribute5;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute6 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute6 IS NOT NULL) THEN
		l_revision_info.attribute6 := p_x_revision_tbl(i).attribute6;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute7 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute7 IS NOT NULL) THEN
		l_revision_info.attribute7 := p_x_revision_tbl(i).attribute7;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute8 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute8 IS NOT NULL) THEN
		l_revision_info.attribute8 := p_x_revision_tbl(i).attribute8;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute9 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute9 IS NOT NULL) THEN
		l_revision_info.attribute9 := p_x_revision_tbl(i).attribute9;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute10 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute10 IS NOT NULL) THEN
		l_revision_info.attribute10 := p_x_revision_tbl(i).attribute10;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute11:= NULL;
	  ELSIF(p_x_revision_tbl(i).attribute11 IS NOT NULL) THEN
		l_revision_info.attribute11 := p_x_revision_tbl(i).attribute11;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute12 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute12 IS NOT NULL) THEN
		l_revision_info.attribute12 := p_x_revision_tbl(i).attribute12;
	  END IF;

	  IF(p_x_revision_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute13 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute13 IS NOT NULL) THEN
		l_revision_info.attribute13 := p_x_revision_tbl(i).attribute13;
          END IF;

	  IF(p_x_revision_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute14 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute14 IS NOT NULL) THEN
	 	l_revision_info.attribute14 := p_x_revision_tbl(i).attribute14;
          END IF;

	  IF(p_x_revision_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
		l_revision_info.attribute15 := NULL;
	  ELSIF(p_x_revision_tbl(i).attribute15 IS NOT NULL) THEN
	 	l_revision_info.attribute15 := p_x_revision_tbl(i).attribute15;
          END IF;


	  /*
	  l_revision_info.attribute_category := p_x_revision_tbl(i).attribute_category;
          l_revision_info.attribute1 := p_x_revision_tbl(i).attribute1;
          l_revision_info.attribute2 := p_x_revision_tbl(i).attribute2;
          l_revision_info.attribute3 := p_x_revision_tbl(i).attribute3;
          l_revision_info.attribute4 := p_x_revision_tbl(i).attribute4;
          l_revision_info.attribute5 := p_x_revision_tbl(i).attribute5;
          l_revision_info.attribute6 := p_x_revision_tbl(i).attribute6;
          l_revision_info.attribute7 := p_x_revision_tbl(i).attribute7;
          l_revision_info.attribute8 := p_x_revision_tbl(i).attribute8;
          l_revision_info.attribute9 := p_x_revision_tbl(i).attribute9;
          l_revision_info.attribute10 := p_x_revision_tbl(i).attribute10;
          l_revision_info.attribute11 := p_x_revision_tbl(i).attribute11;
          l_revision_info.attribute12 := p_x_revision_tbl(i).attribute12;
          l_revision_info.attribute13 := p_x_revision_tbl(i).attribute13;
          l_revision_info.attribute14 := p_x_revision_tbl(i).attribute14;
          l_revision_info.attribute15 := p_x_revision_tbl(i).attribute15;*/
	  --Changes for Bug 9532118 End

     /*Calling Table Handler: Prakash : 26-Dec-2001 */
     AHL_DOC_REVISIONS_PKG.UPDATE_ROW(X_DOC_REVISION_ID => p_x_revision_tbl(i).doc_revision_id,
                                      X_APPROVED_DATE => l_revision_info.approved_date,
                                      X_EFFECTIVE_DATE => l_revision_info.effective_date,
                                      X_OBSOLETE_DATE => l_revision_info.obsolete_date,
                                      X_ISSUE_DATE => l_revision_info.issue_date,
                                      X_RECEIVED_DATE => l_revision_info.received_date,
                                      X_URL => l_revision_info.url,
                                      X_MEDIA_TYPE_CODE => l_revision_info.media_type_code,
                                      X_VOLUME => l_revision_info.volume,
                                      X_ISSUE => l_revision_info.issue,
                                      X_ISSUE_NUMBER => l_revision_info.issue_number,
                                      X_ATTRIBUTE_CATEGORY => l_revision_info.attribute_category,
                                      X_ATTRIBUTE1 => l_revision_info.attribute1,
                                      X_ATTRIBUTE2 => l_revision_info.attribute2,
                                      X_REVISION_DATE => l_revision_info.revision_date,
                                      X_ATTRIBUTE15 => l_revision_info.attribute15,
                                      X_ATTRIBUTE9 => l_revision_info.attribute9,
                                      X_ATTRIBUTE10 => l_revision_info.attribute10,
                                      X_ATTRIBUTE11 => l_revision_info.attribute11,
                                      X_ATTRIBUTE12 => l_revision_info.attribute12,
                                      X_ATTRIBUTE13 => l_revision_info.attribute13,
                                      X_DOCUMENT_ID => l_revision_info.document_id,
                                      X_REVISION_NO => l_revision_info.revision_no,
                                      X_APPROVED_BY_PARTY_ID => l_revision_info.approved_by_party_id,
                                      X_REVISION_TYPE_CODE => l_revision_info.revision_type_code,
                                      X_REVISION_STATUS_CODE => l_revision_info.revision_status_code,
                                      X_OBJECT_VERSION_NUMBER => l_revision_info.object_version_number+1,
                                      X_ATTRIBUTE3 => l_revision_info.attribute3,
                                      X_ATTRIBUTE4 => l_revision_info.attribute4,
                                      X_ATTRIBUTE5 => l_revision_info.attribute5,
                                      X_ATTRIBUTE6 => l_revision_info.attribute6,
                                      X_ATTRIBUTE7 => l_revision_info.attribute7,
                                      X_ATTRIBUTE8 => l_revision_info.attribute8,
                                      X_ATTRIBUTE14 => l_revision_info.attribute14,
                                      X_COMMENTS => l_comments,
                                      X_LAST_UPDATE_DATE => sysdate,
                                      X_LAST_UPDATED_BY => fnd_global.user_id,
                                      X_LAST_UPDATE_LOGIN => fnd_global.login_id);
			-- FP for Bug 8410484
			UPDATE_ASSOCIATIONS(NULL,
					    p_document_id => p_x_revision_tbl(i).document_id);
			--FP end
  -- This will be called to delete revision record, not supported in this phase
 ELSIF ((p_x_revision_tbl(i).doc_revision_id IS NOT NULL) AND
       NVL(p_x_revision_tbl(i).delete_flag, 'N') = 'Y' )

    THEN
       DELETE_REVISION
        (p_api_version      => 1.0               ,
         p_init_msg_list    => FND_API.G_TRUE      ,
         p_commit           => FND_API.G_FALSE     ,
         p_validate_only    => FND_API.G_TRUE      ,
         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         p_x_revision_tbl   =>  p_x_revision_tbl   ,
         x_return_status    => x_return_status     ,
         x_msg_count        => x_msg_count         ,
         x_msg_data         => x_msg_data
         );
  END IF;
 END LOOP;
END IF;
    -- Standard check of p_commit.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of private api Modify Revision','+REV+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Modify Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Modify Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_REVISION_PVT',
                            p_procedure_name  =>  'MODIFY_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pvt.Modify Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_REVISION;
--
PROCEDURE DELETE_REVISION
(
 p_api_version               IN     NUMBER    := 1.0               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN     revision_tbl                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS
-- to get the revision rec
CURSOR get_revision_rec_b_info(c_doc_revision_id  NUMBER)
 IS
SELECT ROWID,
       effective_date,
       obsolete_date,
       object_version_number
  FROM AHL_DOC_REVISIONS_B
 WHERE doc_revision_id = c_doc_revision_id
   FOR UPDATE OF object_version_number NOWAIT;
--
l_api_name         CONSTANT VARCHAR2(30) := 'DELETE_REVISION';
l_api_version      CONSTANT NUMBER       := 1.0;
l_rowid                     ROWID;
l_object_version_number     NUMBER;
l_effective_date            DATE;
l_obsolete_date             DATE;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_revision;
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
   IF p_x_revision_tbl.COUNT > 0
   THEN
      FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
      LOOP
        OPEN get_revision_rec_b_info(p_x_revision_tbl(i).doc_revision_id);
        FETCH get_revision_rec_b_info INTO l_rowid,
                                           l_effective_date,
                                           l_obsolete_date,
                                           l_object_version_number;
        IF (get_revision_rec_b_info%NOTFOUND)
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REVI_RECORD_INVALID');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_revision_rec_b_info;
         -- Check for version number
        IF (l_object_version_number <> p_x_revision_tbl(i).object_version_number)
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REVI_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
        END IF;
        -- Validate with end date
       IF (l_obsolete_date IS NOT NULL AND l_obsolete_date <= SYSDATE)
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REVI_RECORD_CLOSED');
          FND_MSG_PUB.ADD;
       END IF;
       IF (TRUNC(NVL(l_obsolete_date, SYSDATE)) >
          TRUNC(NVL(p_x_revision_tbl(i).obsolete_date,SYSDATE)))
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSOLETE_DATE_INVALID');
          FND_MSG_PUB.ADD;
       END IF;
       -- Update the end date in subscriptions table
      UPDATE AHL_DOC_REVISIONS_B
         SET OBSOLETE_DATE = p_x_revision_tbl(i).obsolete_date
       WHERE ROWID = l_rowid;
  END LOOP;
END IF;
    -- Standard check of p_commit.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_revision;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO delete_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DOC_REVISIONS_PVT',
                            p_procedure_name  =>  'DELETE_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END DELETE_REVISION;

--FP #8410484
PROCEDURE UPDATE_ASSOCIATIONS_CONCURRENT(
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	p_api_version	IN  NUMBER       := 1.0
)
IS
--Cursor to get ids of all the documents which are associated with use latest flag ='Yes'.
CURSOR get_all_document_ids
IS
select distinct(asso.document_id),doc.document_no
from ahl_doc_title_assos_b asso,ahl_documents_b doc
where asso.use_latest_rev_flag='Y'
and asso.document_id=doc.document_id;

l_api_version		NUMBER	:=1.0;
l_api_name		VARCHAR2(40) := 'UPDATE_ASSOCIATIONS_CONCURRENT';
l_document_id		NUMBER;
l_document_no		VARCHAR2(100);

BEGIN
	FND_MSG_PUB.Initialize;
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
                retcode := 2;
                errbuf := FND_MSG_PUB.Get;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	-- To change the status of the documents obsoleted using future obsolete date to 'obsolete' status.
	update ahl_doc_revisions_b
	set revision_status_code ='OBSOLETE'
	where trunc(obsolete_date) <= trunc(sysdate)
	and revision_status_code <> 'OBSOLETE';

	fnd_file.put_line(fnd_file.log,'Associations for following documents are checked and updated appropriately');
	OPEN get_all_document_ids;
	LOOP
		FETCH get_all_document_ids INTO l_document_id,l_document_no;
		EXIT WHEN get_all_document_ids%NOTFOUND;
		UPDATE_ASSOCIATIONS(NULL,l_document_id);
		fnd_file.put_line(fnd_file.log,' document_no -> ' || l_document_no);
	END LOOP;
	CLOSE get_all_document_ids;
	EXCEPTION
	WHEN OTHERS THEN
		retcode := 2;
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_CONC_UPDT_FAILED');
		FND_MSG_PUB.ADD;
		errbuf := FND_MSG_PUB.GET;
		fnd_file.put_line(fnd_file.log, errbuf);

END UPDATE_ASSOCIATIONS_CONCURRENT;
END AHL_DI_DOC_REVISION_PVT;

/
