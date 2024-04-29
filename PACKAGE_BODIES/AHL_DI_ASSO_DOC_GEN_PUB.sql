--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOC_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOC_GEN_PUB" AS
/* $Header: AHLPDAGB.pls 115.1 2003/10/20 19:36:11 sikumar noship $ */
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


PROCEDURE RECORD_IDENTIFIER
(
p_association_rec   IN                AHL_DI_ASSO_DOC_GEN_PUB.association_rec,
x_record            OUT NOCOPY        VARCHAR2
)
as
Begin
                If p_association_rec.document_no is not null and p_association_rec.document_no<>fnd_api.g_miss_char
                Then
                        x_record:=x_record||nvl(p_association_rec.document_no,'')||' - ';
                End if;

                If p_association_rec.revision_no is not null and p_association_rec.revision_no<>fnd_api.g_miss_char
                Then
                x_record:=x_record||nvl(p_association_rec.revision_no,'')||' - ';
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
                If p_association_rec.page is not null and p_association_rec.page<>fnd_api.g_miss_char
                Then
                x_record:=x_record||nvl(p_association_rec.page,'');
                End if;

                If p_association_rec.figure is not null and p_association_rec.figure<>fnd_api.g_miss_char
                Then
                x_record:=x_record||nvl(p_association_rec.figure,'')||' - ';
                End if;
End;

PROCEDURE DEFAULT_MISSING_ATTRIBS
(
   p_association_rec   IN            AHL_DI_ASSO_DOC_GEN_PUB.association_rec,
   x_association_rec   OUT NOCOPY    AHL_DI_ASSO_DOC_GEN_PVT.association_rec
)
AS
        Cursor  GetDocDet(C_DOC_TITLE_ASSO_ID NUMBER)
        IS
        SELECT A.*,B.CHAPTER,B.SECTION,B.SUBJECT,B.PAGE,B.FIGURE,B.NOTE
        FROM   AHL_DOC_TITLE_ASSOS_B  a, AHL_DOC_TITLE_ASSOS_TL B
        WHERE A.DOC_TITLE_ASSO_ID=B.DOC_TITLE_ASSO_ID
        AND   A.DOC_TITLE_ASSO_ID=C_DOC_TITLE_ASSO_ID
        AND   B.LANGUAGE=USERENV('LANG');

        l_doc_assos_rec         GetDocDet%rowtype;
BEGIN

                OPEN  GetDocDet(p_association_rec.DOC_TITLE_ASSO_ID);
                FETCH GetDocDet into l_doc_assos_rec;
                CLOSE GetDocDet;

                IF p_association_rec.DOC_TITLE_ASSO_ID= FND_API.G_MISS_NUM
                THEN
                    x_association_rec.DOC_TITLE_ASSO_ID:=NULL;
                ELSIF p_association_rec.DOC_TITLE_ASSO_ID IS NULL
                THEN
                    x_association_rec.DOC_TITLE_ASSO_ID:=l_doc_assos_rec.DOC_TITLE_ASSO_ID;
                ELSE
                    x_association_rec.DOC_TITLE_ASSO_ID:=p_association_rec.DOC_TITLE_ASSO_ID;
                END IF;

                IF p_association_rec.OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                x_association_rec.OBJECT_VERSION_NUMBER:=NULL;
                ELSIF p_association_rec.OBJECT_VERSION_NUMBER IS NULL
                THEN
                x_association_rec.OBJECT_VERSION_NUMBER:=l_doc_assos_rec.OBJECT_VERSION_NUMBER;
                ELSE
                x_association_rec.OBJECT_VERSION_NUMBER:=p_association_rec.OBJECT_VERSION_NUMBER;
                END IF;

                IF p_association_rec.DOC_REVISION_ID= FND_API.G_MISS_NUM
                THEN
                        x_association_rec.DOC_REVISION_ID:=NULL;
                ELSIF p_association_rec.DOC_REVISION_ID IS NULL
                THEN
                        x_association_rec.DOC_REVISION_ID:=l_doc_assos_rec.DOC_REVISION_ID;
                ELSE
                        x_association_rec.DOC_REVISION_ID:=p_association_rec.DOC_REVISION_ID;
                END IF;

                IF p_association_rec.ASO_OBJECT_TYPE_CODE= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ASO_OBJECT_TYPE_CODE:=NULL;
                ELSIF p_association_rec.ASO_OBJECT_TYPE_CODE IS NULL
                THEN
                        x_association_rec.ASO_OBJECT_TYPE_CODE:=l_doc_assos_rec.ASO_OBJECT_TYPE_CODE;
                ELSE
                        x_association_rec.ASO_OBJECT_TYPE_CODE:=p_association_rec.ASO_OBJECT_TYPE_CODE;
                END IF;

                IF p_association_rec.ASO_OBJECT_ID= FND_API.G_MISS_NUM
                THEN
                        x_association_rec.ASO_OBJECT_ID:=NULL;
                ELSIF p_association_rec.ASO_OBJECT_ID IS NULL
                THEN
                        x_association_rec.ASO_OBJECT_ID:=l_doc_assos_rec.ASO_OBJECT_ID;
                        ELSE
                        x_association_rec.ASO_OBJECT_ID:=p_association_rec.ASO_OBJECT_ID;
                END IF;

                IF p_association_rec.DOCUMENT_ID= FND_API.G_MISS_NUM
                THEN
                        x_association_rec.DOCUMENT_ID:=NULL;
                ELSIF p_association_rec.DOCUMENT_ID IS NULL
                THEN
                        x_association_rec.DOCUMENT_ID:=l_doc_assos_rec.DOCUMENT_ID;
                        ELSE
                        x_association_rec.DOCUMENT_ID:=p_association_rec.DOCUMENT_ID;
                END IF;

                IF p_association_rec.USE_LATEST_REV_FLAG= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.USE_LATEST_REV_FLAG:=NULL;
                ELSIF p_association_rec.USE_LATEST_REV_FLAG IS NULL
                THEN
                        x_association_rec.USE_LATEST_REV_FLAG:=l_doc_assos_rec.USE_LATEST_REV_FLAG;
                        ELSE
                        x_association_rec.USE_LATEST_REV_FLAG:=p_association_rec.USE_LATEST_REV_FLAG;
                END IF;

                IF p_association_rec.SERIAL_NO= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.SERIAL_NO:=NULL;
                ELSIF p_association_rec.SERIAL_NO IS NULL
                THEN
                        x_association_rec.SERIAL_NO:=l_doc_assos_rec.SERIAL_NO;
                        ELSE
                        x_association_rec.SERIAL_NO:=p_association_rec.SERIAL_NO;
                END IF;

                IF p_association_rec.ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE_CATEGORY:= NULL;
                ELSIF p_association_rec.ATTRIBUTE_CATEGORY IS NULL
                THEN
                        x_association_rec.ATTRIBUTE_CATEGORY:=l_doc_assos_rec.ATTRIBUTE_CATEGORY;
                        ELSE
                        x_association_rec.ATTRIBUTE_CATEGORY:=p_association_rec.ATTRIBUTE_CATEGORY;
                END IF;

                IF p_association_rec.ATTRIBUTE1= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE1:=NULL;
                ELSIF p_association_rec.ATTRIBUTE1 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE1:=l_doc_assos_rec.ATTRIBUTE1;
                ELSE
                        x_association_rec.ATTRIBUTE1:=p_association_rec.ATTRIBUTE1;
                END IF;

                IF p_association_rec.ATTRIBUTE2= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE2:=NULL;
                ELSIF p_association_rec.ATTRIBUTE2 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE2:=l_doc_assos_rec.ATTRIBUTE2;
                ELSE
                        x_association_rec.ATTRIBUTE2:=p_association_rec.ATTRIBUTE2;
                END IF;

                IF p_association_rec.ATTRIBUTE3= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE3:=NULL;
                ELSIF p_association_rec.ATTRIBUTE3 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE3:=l_doc_assos_rec.ATTRIBUTE3;
                ELSE
                        x_association_rec.ATTRIBUTE3:=p_association_rec.ATTRIBUTE3;
                END IF;

                IF p_association_rec.ATTRIBUTE4= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE4:=NULL;
                ELSIF p_association_rec.ATTRIBUTE4 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE4:=l_doc_assos_rec.ATTRIBUTE4;
                ELSE
                        x_association_rec.ATTRIBUTE4:=p_association_rec.ATTRIBUTE4;
                END IF;

                IF p_association_rec.ATTRIBUTE5= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE5:=NULL;
                ELSIF p_association_rec.ATTRIBUTE5 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE5:=l_doc_assos_rec.ATTRIBUTE5;
                ELSE
                        x_association_rec.ATTRIBUTE5:=p_association_rec.ATTRIBUTE5;
                END IF;

                IF p_association_rec.ATTRIBUTE6= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE6:=NULL;
                ELSIF p_association_rec.ATTRIBUTE6 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE6:=l_doc_assos_rec.ATTRIBUTE6;
                ELSE
                        x_association_rec.ATTRIBUTE6:=p_association_rec.ATTRIBUTE6;
                END IF;

                IF p_association_rec.ATTRIBUTE7= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE7:=NULL;
                ELSIF p_association_rec.ATTRIBUTE7 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE7:=l_doc_assos_rec.ATTRIBUTE7;
                ELSE
                        x_association_rec.ATTRIBUTE7:=p_association_rec.ATTRIBUTE7;
                END IF;

                IF p_association_rec.ATTRIBUTE8= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE8:=NULL;
                ELSIF p_association_rec.ATTRIBUTE8 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE8:=l_doc_assos_rec.ATTRIBUTE8;
                ELSE
                        x_association_rec.ATTRIBUTE8:=p_association_rec.ATTRIBUTE8;
                END IF;

                IF p_association_rec.ATTRIBUTE9= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE9:=NULL;
                ELSIF p_association_rec.ATTRIBUTE9 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE9:=l_doc_assos_rec.ATTRIBUTE9;
                ELSE
                        x_association_rec.ATTRIBUTE9:=p_association_rec.ATTRIBUTE9;
                END IF;

                IF p_association_rec.ATTRIBUTE10= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE10:=NULL;
                ELSIF p_association_rec.ATTRIBUTE10 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE10:=l_doc_assos_rec.ATTRIBUTE10;
                ELSE
                        x_association_rec.ATTRIBUTE10:=p_association_rec.ATTRIBUTE10;
                END IF;
                IF p_association_rec.ATTRIBUTE11= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE11:=NULL;
                ELSIF p_association_rec.ATTRIBUTE11 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE11:=l_doc_assos_rec.ATTRIBUTE11;
                ELSE
                        x_association_rec.ATTRIBUTE11:=p_association_rec.ATTRIBUTE11;
                END IF;
                IF p_association_rec.ATTRIBUTE12= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE12:=NULL;
                ELSIF p_association_rec.ATTRIBUTE12 IS NULL
                THEN
                        x_association_rec.ATTRIBUTE12:=l_doc_assos_rec.ATTRIBUTE12;
                ELSE
                        x_association_rec.ATTRIBUTE12:=p_association_rec.ATTRIBUTE12;
                END IF;
                IF p_association_rec.ATTRIBUTE13= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.ATTRIBUTE13:=NULL;
                ELSIF p_association_rec.ATTRIBUTE13 IS NULL
                THEN
                x_association_rec.ATTRIBUTE13:=l_doc_assos_rec.ATTRIBUTE13;
                ELSE
                x_association_rec.ATTRIBUTE13:=p_association_rec.ATTRIBUTE13;
                END IF;
                IF p_association_rec.ATTRIBUTE14= FND_API.G_MISS_CHAR
                THEN
                x_association_rec.ATTRIBUTE14:=NULL;
                ELSIF p_association_rec.ATTRIBUTE14 IS NULL
                THEN
                x_association_rec.ATTRIBUTE14:=l_doc_assos_rec.ATTRIBUTE14;
                ELSE
                x_association_rec.ATTRIBUTE14:=p_association_rec.ATTRIBUTE14;
                END IF;
                IF p_association_rec.ATTRIBUTE15= FND_API.G_MISS_CHAR
                THEN
                x_association_rec.ATTRIBUTE15:=NULL;
                ELSIF p_association_rec.ATTRIBUTE15 IS NULL
                THEN
                x_association_rec.ATTRIBUTE15:=l_doc_assos_rec.ATTRIBUTE15;
                ELSE
                x_association_rec.ATTRIBUTE15:=p_association_rec.ATTRIBUTE15;
                END IF;

                IF p_association_rec.SOURCE_REF_CODE= FND_API.G_MISS_CHAR
                THEN
                x_association_rec.SOURCE_REF_CODE:=NULL;
                ELSIF p_association_rec.SOURCE_REF_CODE IS NULL
                THEN
                x_association_rec.SOURCE_REF_CODE:=l_doc_assos_rec.SOURCE_REF_CODE;
                ELSE
                x_association_rec.SOURCE_REF_CODE:=p_association_rec.SOURCE_REF_CODE;
                END IF;

                IF p_association_rec.DOC_TITLE_ASSO_ID= FND_API.G_MISS_NUM
                THEN
                x_association_rec.DOC_TITLE_ASSO_ID:=NULL;
                ELSIF p_association_rec.DOC_TITLE_ASSO_ID IS NULL
                THEN
                x_association_rec.DOC_TITLE_ASSO_ID:=l_doc_assos_rec.DOC_TITLE_ASSO_ID;
                ELSE
                x_association_rec.DOC_TITLE_ASSO_ID:=p_association_rec.DOC_TITLE_ASSO_ID;
                END IF;


                IF p_association_rec.CHAPTER= FND_API.G_MISS_CHAR
                THEN
                    x_association_rec.CHAPTER:=NULL;

                ELSIF p_association_rec.CHAPTER IS NULL
                THEN
                   x_association_rec.CHAPTER:=l_doc_assos_rec.CHAPTER;
                ELSE
                   x_association_rec.CHAPTER:=p_association_rec.CHAPTER;
                END IF;


                IF p_association_rec.SECTION= FND_API.G_MISS_CHAR
                THEN

                   x_association_rec.SECTION:=NULL;
                ELSIF p_association_rec.SECTION IS NULL
                THEN

                    x_association_rec.SECTION:=l_doc_assos_rec.SECTION;
                ELSE
                x_association_rec.SECTION:=p_association_rec.SECTION;
                END IF;


                IF p_association_rec.SUBJECT= FND_API.G_MISS_CHAR
                THEN
                x_association_rec.SUBJECT:=NULL;
                ELSIF p_association_rec.SUBJECT IS NULL
                THEN
                x_association_rec.SUBJECT:=l_doc_assos_rec.SUBJECT;
                ELSE
                x_association_rec.SUBJECT:=p_association_rec.SUBJECT;
                END IF;

                IF p_association_rec.PAGE= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.PAGE:=NULL;
                ELSIF p_association_rec.PAGE IS NULL
                THEN
                        x_association_rec.PAGE:=l_doc_assos_rec.PAGE;
                ELSE
                        x_association_rec.PAGE:=p_association_rec.PAGE;
                END IF;

                IF p_association_rec.FIGURE= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.FIGURE:=NULL;
                ELSIF p_association_rec.FIGURE IS NULL
                THEN
                        x_association_rec.FIGURE:=l_doc_assos_rec.FIGURE;
                ELSE
                        x_association_rec.FIGURE:=p_association_rec.FIGURE;
                END IF;

                IF p_association_rec.NOTE= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.NOTE:=NULL;
                ELSIF p_association_rec.NOTE IS NULL
                THEN
                        x_association_rec.NOTE:=l_doc_assos_rec.NOTE;
                ELSE
                        x_association_rec.NOTE:=p_association_rec.NOTE;
                END IF;

                IF p_association_rec.dml_operation= FND_API.G_MISS_CHAR
                THEN
                        x_association_rec.dml_operation:=NULL;
                ELSE
                        x_association_rec.dml_operation:=p_association_rec.dml_operation;
                END IF;

END;


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


PROCEDURE VALUEATE_ASSOCIATION
 (
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
	 p_association_rec              IN  AHL_DI_ASSO_DOC_GEN_PUB.association_rec,
	 p_x_association_rec            IN OUT NOCOPY AHL_DI_ASSO_DOC_GEN_PVT.association_rec
 )
AS

 CURSOR GetDocId (c_document_no  VARCHAR2)
 IS
	SELECT document_id
	FROM ahl_documents_b
	WHERE document_no = c_document_no;

 CURSOR GetDocRevId (c_document_id  VARCHAR2)
 IS
	SELECT doc_revision_id
	FROM ahl_doc_revisions_b
	WHERE document_id = c_document_id;

 CURSOR GetDocRevCount (c_document_id  VARCHAR2)
 IS
	SELECT count(*)
	FROM ahl_doc_revisions_b
	WHERE document_id = c_document_id;

 CURSOR GetDocRevNoId (c_document_id  NUMBER, c_doc_rev_no VARCHAR2)
 IS
	SELECT doc_revision_id
	FROM ahl_doc_revisions_b
	WHERE document_id = c_document_id
	  and revision_no= c_doc_rev_no;


 l_document_id           NUMBER;
 l_revision_id           NUMBER;
 l_counter               NUMBER:=0;
 l_rev_counter           NUMBER:=0;
 l_record                VARCHAR2(4000):='';
 l_check_flag            VARCHAR2(1):='Y';

BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;


        RECORD_IDENTIFIER
        (
	        p_association_rec   =>p_association_rec,
	        x_record              =>l_record
        );

        l_check_flag := 'Y';


	IF (p_association_rec.document_no IS NULL or
	    p_association_rec.document_no=FND_API.G_MISS_CHAR)
	THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCUMENT_NO_NULL');
		FND_MESSAGE.SET_TOKEN('RECORD',l_record);
		FND_MSG_PUB.ADD;
		IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Stage 002');
		END IF;
		l_check_flag:='N';
	ELSE

	     OPEN GetDocId (p_association_rec.document_no);
	     FETCH GetDocId INTO l_document_id;

	      IF(GetDocId%NOTFOUND)
	      THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCUMENT_NO_INVALID');
			FND_MESSAGE.SET_TOKEN('FIELD',p_association_rec.document_no);
			FND_MESSAGE.SET_TOKEN('RECORD',l_record);
			FND_MSG_PUB.ADD;
			IF G_DEBUG='Y' THEN
				AHL_DEBUG_PUB.debug( 'Document number Does not exist');
			END IF;
			l_check_flag:='N';
	      ELSE
		      p_x_association_rec.document_id := l_document_id;
	      END IF;
	      CLOSE GetDocId;
	 END IF;-- DOC NULL

	 IF(l_check_flag = 'Y')
	 THEN
		 IF (p_association_rec.revision_no is null or
		     p_association_rec.revision_no=fnd_api.g_miss_char)
		 THEN
			IF(p_association_rec.aso_object_type_code NOT IN ('ROUTE', 'OPERATION'))
			THEN

			     OPEN GetDocRevCount (l_document_id);
			     FETCH GetDocRevCount INTO l_rev_counter;
			     CLOSE GetDocRevCount;

			     IF(l_rev_counter = 1)
			     THEN

			         OPEN GetDocRevId (l_document_id);
			         FETCH GetDocRevId INTO l_revision_id;
			         CLOSE GetDocRevId;
			         p_x_association_rec.doc_revision_id := l_revision_id;
			     ELSE
					FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_REVISION_NO_NULL');
					FND_MESSAGE.SET_TOKEN('RECORD',l_record);
					FND_MSG_PUB.ADD;
					IF G_DEBUG='Y' THEN
						AHL_DEBUG_PUB.debug( 'Revision for Document is null');
					END IF;

					l_check_flag:='N';
					FND_MESSAGE.SET_NAME('AHL','AHL_DI_SELECT_FRM_LOV');
					FND_MSG_PUB.ADD;
					IF G_DEBUG='Y' THEN
						AHL_DEBUG_PUB.debug( 'Select document from lov');
					END IF;
			     END IF;
			ELSE -- ROUTE AND OPER
					FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_REVISION_NO_NULL');
					FND_MESSAGE.SET_TOKEN('RECORD',l_record);
					FND_MSG_PUB.ADD;
					IF G_DEBUG='Y' THEN
						AHL_DEBUG_PUB.debug( 'Revision for Document is null');
					END IF;

					l_check_flag:='N';
					FND_MESSAGE.SET_NAME('AHL','AHL_DI_SELECT_FRM_LOV');
					FND_MSG_PUB.ADD;
					IF G_DEBUG='Y' THEN
						AHL_DEBUG_PUB.debug( 'Select document from lov');
					END IF;
			END IF;-- NOT R O
		 ELSE -- REV NOT NULL
			OPEN GetDocRevNoId (l_document_id,p_association_rec.revision_no );
			FETCH GetDocRevNoId INTO l_revision_id;

			IF(GetDocRevNoId%FOUND)
			THEN
			  p_x_association_rec.doc_revision_id := l_revision_id;
			ELSE
				FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOC_REV_COMB_INVLD');
				FND_MESSAGE.SET_TOKEN('FIELD1',p_association_rec.revision_no);
				FND_MESSAGE.SET_TOKEN('FIELD2',p_association_rec.document_no);
				FND_MESSAGE.SET_TOKEN('RECORD',l_record);
				FND_MSG_PUB.ADD;
			END IF;
			CLOSE GetDocRevNoId;
		 END IF;--REV NULL
	   END IF;
END;


PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version               IN     		NUMBER    := 1.0,
 p_init_msg_list             IN     		VARCHAR2  := FND_API.G_TRUE,
 p_commit                    IN     		VARCHAR2  := FND_API.G_FALSE ,
 p_validation_level          IN     		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_validate_only             IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type               IN     		VARCHAR2 ,
 x_return_status             OUT 		NOCOPY VARCHAR2,
 x_msg_count                 OUT 		NOCOPY NUMBER,
 x_msg_data                  OUT 		NOCOPY VARCHAR2,
 p_x_association_tbl         IN OUT NOCOPY 	association_tbl)
IS
--To retrieve document id
l_api_name     CONSTANT  VARCHAR2(30) := 'PROCESS_ASSOCIATION';
l_api_version  CONSTANT  NUMBER       := 1.0;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_document_id            NUMBER;
l_doc_revision_id        NUMBER;
l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
l_rowid                  VARCHAR2(30);
l_association_tbl        AHL_DI_ASSO_DOC_GEN_PVT.ASSOCIATION_TBL;
l_record varchar2(4000);

BEGIN
  -- Standard Start of API savepoint
     SAVEPOINT process_association;
   -- Check if API is called in debug mode. If yes, enable debug.

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.enable_debug;
     END IF;

   -- Debug info.

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'entering..... ahl_di_asso_doc_aso_pub.Process Association','+DOBJASS+');
     END IF;



    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

    --  Initialize API return status to success

        x_return_status := 'S';

    -- Standard call to check for call compatibility.
        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


   --Module type is 'JSP' then make it null for the following fields

        IF p_x_association_tbl.count >0
        THEN
                FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
                LOOP
                IF (p_module_type = 'JSP') THEN
                        IF p_x_association_tbl(i).DML_OPERATION<>'D'
                        THEN
                            p_x_association_tbl(i).document_id:=null;
		            p_x_association_tbl(i).doc_revision_id := null;
                        END IF;
                END IF;
                END LOOP;
         END IF;


        IF p_x_association_tbl.count >0
        THEN
          FOR i in p_x_association_tbl.FIRST .. p_x_association_tbl.LAST
          LOOP
          null;

	     IF p_x_association_tbl(i).DML_OPERATION = 'D'
	     THEN
		 l_association_tbl(i).doc_title_asso_id    := p_x_association_tbl(i).doc_title_asso_id;
		 l_association_tbl(i).object_version_number:= p_x_association_tbl(i).object_version_number;
		 l_association_tbl(i).dml_operation:= p_x_association_tbl(i).dml_operation;
	     ELSE
		IF FND_API.to_boolean(p_validate_only)
		THEN
			RECORD_IDENTIFIER
			(
			p_association_rec   =>p_x_association_tbl(i),
			x_record              =>l_record
			);
			IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'before the record .... '||l_record,'+adhariamr+');
			END IF;

			DEFAULT_MISSING_ATTRIBS
			(
			   p_association_rec => p_x_association_tbl(i),
			   x_association_rec => l_association_tbl(i)
			);

		ELSE

			l_association_tbl(i).doc_title_asso_id    := p_x_association_tbl(i).doc_title_asso_id;

			l_association_tbl(i).aso_object_id        := p_x_association_tbl(i).aso_object_id;
			l_association_tbl(i).use_latest_rev_flag  := p_x_association_tbl(i).use_latest_rev_flag;
			l_association_tbl(i).serial_no            := p_x_association_tbl(i).serial_no;
			l_association_tbl(i).source_lang          := p_x_association_tbl(i).source_lang;
			l_association_tbl(i).chapter              := p_x_association_tbl(i).chapter;
			l_association_tbl(i).section              := p_x_association_tbl(i).section;
			l_association_tbl(i).subject 	          := p_x_association_tbl(i).subject;
			l_association_tbl(i).page                 := p_x_association_tbl(i).page;
			l_association_tbl(i).figure               := p_x_association_tbl(i).figure;
			l_association_tbl(i).note                 := p_x_association_tbl(i).note;
			l_association_tbl(i).source_ref_code      := p_x_association_tbl(i).source_ref_code;
			l_association_tbl(i).attribute_category   := p_x_association_tbl(i).attribute_category;
			l_association_tbl(i).attribute1           := p_x_association_tbl(i).attribute1;
			l_association_tbl(i).attribute2           := p_x_association_tbl(i).attribute2;
			l_association_tbl(i).attribute3           := p_x_association_tbl(i).attribute3;
			l_association_tbl(i).attribute4           := p_x_association_tbl(i).attribute4;
			l_association_tbl(i).attribute5           := p_x_association_tbl(i).attribute5;
			l_association_tbl(i).attribute6           := p_x_association_tbl(i).attribute6;
			l_association_tbl(i).attribute7           := p_x_association_tbl(i).attribute7;
			l_association_tbl(i).attribute8           := p_x_association_tbl(i).attribute8;
			l_association_tbl(i).attribute9           := p_x_association_tbl(i).attribute9;
			l_association_tbl(i).attribute10          := p_x_association_tbl(i).attribute10;
			l_association_tbl(i).attribute11          := p_x_association_tbl(i).attribute11;
			l_association_tbl(i).attribute12          := p_x_association_tbl(i).attribute12;
			l_association_tbl(i).attribute13          := p_x_association_tbl(i).attribute13;
			l_association_tbl(i).attribute14          := p_x_association_tbl(i).attribute14;
			l_association_tbl(i).attribute15          := p_x_association_tbl(i).attribute15;
			l_association_tbl(i).object_version_number:= p_x_association_tbl(i).object_version_number;
			l_association_tbl(i).dml_operation          := p_x_association_tbl(i).dml_operation;


		END IF;



		VALUEATE_ASSOCIATION
		(
			x_return_status             =>x_return_Status,
			x_msg_count                 =>x_msg_count,
			x_msg_data                  =>x_msg_data,
			p_association_rec           =>p_x_association_tbl(i),
			p_x_association_rec         =>l_association_tbl(i)
		);




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



		l_msg_count := FND_MSG_PUB.count_msg;

		IF l_msg_count > 0 THEN
		   x_msg_count := l_msg_count;
		   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'before modify');
		END IF;


       END IF;
   END LOOP;

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;



	 AHL_DI_ASSO_DOC_GEN_PVT.PROCESS_ASSOCIATION
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

   END IF;--
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
 --Standard check for commit

 IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api PROCESS Association','+DOBJASS+');

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
		  AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.PROCESS Association','+DOCJASS+');
        -- Check if API is called in debug mode. If yes, disable debug.
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => X_msg_data);
     x_msg_count := l_msg_count;

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.PROCESS Association','+DOCJASS+');

	-- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

        END IF;

 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_ASSO_DOC_GEN_PUB',
                            p_procedure_name  =>  'PROCESS_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => X_msg_data);
    x_msg_count := l_msg_count;
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_asso_doc_aso_pub.PROCESS Association','+DOCJASS+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

	END IF;

END PROCESS_ASSOCIATION;

END AHL_DI_ASSO_DOC_GEN_PUB;

/
