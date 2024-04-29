--------------------------------------------------------
--  DDL for Package Body AHL_DI_ASSO_DOCASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_ASSO_DOCASO_PVT" AS
/* $Header: AHLVDOAB.pls 115.29 2003/09/15 06:39:31 rroy noship $ */
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_ASSO_DOCASO_PVT';
G_PM_INSTALL            VARCHAR2(30):=ahl_util_pkg.is_pm_installed;
G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE RECORD_IDENTIFIER
(
p_association_rec   IN                AHL_DI_ASSO_DOCASO_PVT.association_rec,
x_record            OUT NOCOPY        VARCHAR2
)
as
Begin
        IF p_association_rec.aso_object_type_code = 'OPERATION'
        THEN
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

                If p_association_rec.figure is not null and p_association_rec.figure<>fnd_api.g_miss_char
                Then
                x_record:=x_record||nvl(p_association_rec.figure,'')||' - ';
                End if;

                If p_association_rec.page is not null and p_association_rec.page<>fnd_api.g_miss_char
                Then
                x_record:=x_record||nvl(p_association_rec.page,'');
                End if;
        ELSIF p_association_rec.aso_object_type_code = 'MR'
        THEN

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
        END IF;
End;


PROCEDURE DEFAULT_MISSING_ATTRIBS
(
p_x_association_tbl   IN OUT NOCOPY AHL_DI_ASSO_DOCASO_PVT.association_TBL
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
        IF p_x_association_tbl.count>0
        THEN

        FOR i in p_x_association_tbl.FIRST .. p_x_association_tbl.LAST
        LOOP
        -- bug 2979987 : pbarman : 29.5.2003
        IF p_x_association_tbl(I).DML_OPERATION<>'D' and p_x_association_tbl(I).DML_OPERATION<>'C'
        THEN
                OPEN  GetDocDet(p_x_association_tbl(i).DOC_TITLE_ASSO_ID);
                FETCH GetDocDet into l_doc_assos_rec;
                CLOSE GetDocDet;

                IF p_x_association_tbl(I).DOC_TITLE_ASSO_ID= FND_API.G_MISS_NUM
                THEN
                p_x_association_tbl(I).DOC_TITLE_ASSO_ID:=NULL;
                ELSIF p_x_association_tbl(I).DOC_TITLE_ASSO_ID IS NULL
                THEN
                p_x_association_tbl(I).DOC_TITLE_ASSO_ID:=l_doc_assos_rec.DOC_TITLE_ASSO_ID;
                END IF;

                IF p_x_association_tbl(I).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                p_x_association_tbl(I).OBJECT_VERSION_NUMBER:=NULL;
                ELSIF p_x_association_tbl(I).OBJECT_VERSION_NUMBER IS NULL
                THEN
                p_x_association_tbl(I).OBJECT_VERSION_NUMBER:=l_doc_assos_rec.OBJECT_VERSION_NUMBER;
                END IF;

                IF p_x_association_tbl(I).LAST_UPDATE_DATE=FND_API.G_MISS_DATE
                THEN
                p_x_association_tbl(I).LAST_UPDATE_DATE:=NULL;
                ELSIF p_x_association_tbl(I).LAST_UPDATE_DATE IS NULL
                THEN
                p_x_association_tbl(I).LAST_UPDATE_DATE:=l_doc_assos_rec.LAST_UPDATE_DATE;
                END IF;

                IF p_x_association_tbl(I).LAST_UPDATED_BY= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).LAST_UPDATED_BY:=NULL;
                ELSIF p_x_association_tbl(I).LAST_UPDATED_BY IS NULL
                THEN
                        p_x_association_tbl(I).LAST_UPDATED_BY:=l_doc_assos_rec.LAST_UPDATED_BY;
                END IF;

                IF p_x_association_tbl(I).CREATION_DATE=FND_API.G_MISS_DATE
                THEN
                        p_x_association_tbl(I).CREATION_DATE:=NULL;
                ELSIF p_x_association_tbl(I).CREATION_DATE IS NULL
                THEN
                        p_x_association_tbl(I).CREATION_DATE:=l_doc_assos_rec.CREATION_DATE;
                END IF;

                IF p_x_association_tbl(I).CREATED_BY= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).CREATED_BY:=NULL;
                ELSIF p_x_association_tbl(I).CREATED_BY IS NULL
                THEN
                        p_x_association_tbl(I).CREATED_BY:=l_doc_assos_rec.CREATED_BY;
                END IF;
                IF p_x_association_tbl(I).LAST_UPDATE_LOGIN= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).LAST_UPDATE_LOGIN:=NULL;
                ELSIF p_x_association_tbl(I).LAST_UPDATE_LOGIN IS NULL
                THEN
                        p_x_association_tbl(I).LAST_UPDATE_LOGIN:=l_doc_assos_rec.LAST_UPDATE_LOGIN;
                END IF;

                IF p_x_association_tbl(I).DOC_REVISION_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).DOC_REVISION_ID:=NULL;
                ELSIF p_x_association_tbl(I).DOC_REVISION_ID IS NULL
                THEN
                        p_x_association_tbl(I).DOC_REVISION_ID:=l_doc_assos_rec.DOC_REVISION_ID;
                END IF;

                IF p_x_association_tbl(I).ASO_OBJECT_TYPE_CODE= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ASO_OBJECT_TYPE_CODE:=NULL;
                ELSIF p_x_association_tbl(I).ASO_OBJECT_TYPE_CODE IS NULL
                THEN
                        p_x_association_tbl(I).ASO_OBJECT_TYPE_CODE:=l_doc_assos_rec.ASO_OBJECT_TYPE_CODE;
                END IF;

                IF p_x_association_tbl(I).ASO_OBJECT_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).ASO_OBJECT_ID:=NULL;
                ELSIF p_x_association_tbl(I).ASO_OBJECT_ID IS NULL
                THEN
                        p_x_association_tbl(I).ASO_OBJECT_ID:=l_doc_assos_rec.ASO_OBJECT_ID;
                END IF;

                IF p_x_association_tbl(I).DOCUMENT_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_association_tbl(I).DOCUMENT_ID:=NULL;
                ELSIF p_x_association_tbl(I).DOCUMENT_ID IS NULL
                THEN
                        p_x_association_tbl(I).DOCUMENT_ID:=l_doc_assos_rec.DOCUMENT_ID;
                END IF;

                IF p_x_association_tbl(I).USE_LATEST_REV_FLAG= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).USE_LATEST_REV_FLAG:=NULL;
                ELSIF p_x_association_tbl(I).USE_LATEST_REV_FLAG IS NULL
                THEN
                        p_x_association_tbl(I).USE_LATEST_REV_FLAG:=l_doc_assos_rec.USE_LATEST_REV_FLAG;
                END IF;

                IF p_x_association_tbl(I).SERIAL_NO= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).SERIAL_NO:=NULL;
                ELSIF p_x_association_tbl(I).SERIAL_NO IS NULL
                THEN
                        p_x_association_tbl(I).SERIAL_NO:=l_doc_assos_rec.SERIAL_NO;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE_CATEGORY:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE_CATEGORY IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE_CATEGORY:=l_doc_assos_rec.ATTRIBUTE_CATEGORY;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE1= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE1:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE1 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE1:=l_doc_assos_rec.ATTRIBUTE1;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE2= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE2:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE2 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE2:=l_doc_assos_rec.ATTRIBUTE2;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE3= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE3:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE3 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE3:=l_doc_assos_rec.ATTRIBUTE3;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE4= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE4:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE4 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE4:=l_doc_assos_rec.ATTRIBUTE4;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE5= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE5:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE5 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE5:=l_doc_assos_rec.ATTRIBUTE5;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE6= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE6:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE6 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE6:=l_doc_assos_rec.ATTRIBUTE6;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE7= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE7:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE7 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE7:=l_doc_assos_rec.ATTRIBUTE7;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE8= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE8:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE8 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE8:=l_doc_assos_rec.ATTRIBUTE8;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE9= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE9:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE9 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE9:=l_doc_assos_rec.ATTRIBUTE9;
                END IF;

                IF p_x_association_tbl(I).ATTRIBUTE10= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE10:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE10 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE10:=l_doc_assos_rec.ATTRIBUTE10;
                END IF;
                IF p_x_association_tbl(I).ATTRIBUTE11= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE11:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE11 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE11:=l_doc_assos_rec.ATTRIBUTE11;
                END IF;
                IF p_x_association_tbl(I).ATTRIBUTE12= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE12:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE12 IS NULL
                THEN
                        p_x_association_tbl(I).ATTRIBUTE12:=l_doc_assos_rec.ATTRIBUTE12;
                END IF;
                IF p_x_association_tbl(I).ATTRIBUTE13= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).ATTRIBUTE13:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE13 IS NULL
                THEN
                p_x_association_tbl(I).ATTRIBUTE13:=l_doc_assos_rec.ATTRIBUTE13;
                END IF;
                IF p_x_association_tbl(I).ATTRIBUTE14= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).ATTRIBUTE14:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE14 IS NULL
                THEN
                p_x_association_tbl(I).ATTRIBUTE14:=l_doc_assos_rec.ATTRIBUTE14;
                END IF;
                IF p_x_association_tbl(I).ATTRIBUTE15= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).ATTRIBUTE15:=NULL;
                ELSIF p_x_association_tbl(I).ATTRIBUTE15 IS NULL
                THEN
                p_x_association_tbl(I).ATTRIBUTE15:=l_doc_assos_rec.ATTRIBUTE15;
                END IF;

                IF p_x_association_tbl(I).SOURCE_REF_CODE= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).SOURCE_REF_CODE:=NULL;
                ELSIF p_x_association_tbl(I).SOURCE_REF_CODE IS NULL
                THEN
                p_x_association_tbl(I).SOURCE_REF_CODE:=l_doc_assos_rec.SOURCE_REF_CODE;
                END IF;
                IF p_x_association_tbl(I).DOC_TITLE_ASSO_ID= FND_API.G_MISS_NUM
                THEN
                p_x_association_tbl(I).DOC_TITLE_ASSO_ID:=NULL;
                ELSIF p_x_association_tbl(I).DOC_TITLE_ASSO_ID IS NULL
                THEN
                p_x_association_tbl(I).DOC_TITLE_ASSO_ID:=l_doc_assos_rec.DOC_TITLE_ASSO_ID;
                END IF;
                IF p_x_association_tbl(I).CHAPTER= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).CHAPTER:=NULL;
                ELSIF p_x_association_tbl(I).CHAPTER IS NULL
                THEN
                p_x_association_tbl(I).CHAPTER:=l_doc_assos_rec.CHAPTER;
                END IF;
                IF p_x_association_tbl(I).SECTION= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).SECTION:=NULL;
                ELSIF p_x_association_tbl(I).SECTION IS NULL
                THEN
                p_x_association_tbl(I).SECTION:=l_doc_assos_rec.SECTION;
                END IF;
                IF p_x_association_tbl(I).SUBJECT= FND_API.G_MISS_CHAR
                THEN
                p_x_association_tbl(I).SUBJECT:=NULL;
                ELSIF p_x_association_tbl(I).SUBJECT IS NULL
                THEN
                p_x_association_tbl(I).SUBJECT:=l_doc_assos_rec.SUBJECT;
                END IF;

                IF p_x_association_tbl(I).PAGE= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).PAGE:=NULL;
                ELSIF p_x_association_tbl(I).PAGE IS NULL
                THEN
                        p_x_association_tbl(I).PAGE:=l_doc_assos_rec.PAGE;
                END IF;

                IF p_x_association_tbl(I).FIGURE= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).FIGURE:=NULL;
                ELSIF p_x_association_tbl(I).FIGURE IS NULL
                THEN
                        p_x_association_tbl(I).FIGURE:=l_doc_assos_rec.FIGURE;
                END IF;

                IF p_x_association_tbl(I).NOTE= FND_API.G_MISS_CHAR
                THEN
                        p_x_association_tbl(I).NOTE:=NULL;
                ELSIF p_x_association_tbl(I).NOTE IS NULL
                THEN
                        p_x_association_tbl(I).NOTE:=l_doc_assos_rec.NOTE;
                END IF;
        END IF;
        END LOOP;
        END IF;
END;

PROCEDURE TRANS_VALUE_ID
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_x_association_tbl         IN OUT NOCOPY AHL_DI_ASSO_DOCASO_PVT.association_tbl
 )
as
CURSOR get_lookup_meaning_to_code(c_meaning  VARCHAR2,c_lookup_type VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(meaning)=upper(c_meaning)
   AND sysdate between NVL(start_date_active,sysdate)
   AND nvl(end_date_active,sysdate);


CURSOR GetDocDet(c_document_no  VARCHAR2)
IS
SELECT  a.document_id,
        a.document_no,
        a.doc_type_code,
        a.doc_sub_type_code,
        a.document_title,
        b.doc_revision_id,
        b.revision_no,
        b.revision_status_code
   FROM ahl_documents_vl a ,AHL_DOC_REVISIONS_B b
   WHERE A.DOCUMENT_ID=B.DOCUMENT_ID
   and upper(a.document_no)=upper(c_document_no);

l_doc_rec       GetDocDet%rowtype;

CURSOR GetDocCheck(c_document_no  VARCHAR2)
IS
   SELECT count(a.document_no)
   FROM ahl_documents_vl a ,AHL_DOC_REVISIONS_B b
   WHERE A.DOCUMENT_ID=B.DOCUMENT_ID(+)
   and upper(a.document_no)=upper(c_document_no);

CURSOR GetRevCheck(c_revision_no  VARCHAR2)
IS
   SELECT count(a.revision_no)
   FROM AHL_DOC_REVISIONS_B a
   WHERE upper(a.revision_no)=upper(c_revision_no);

CURSOR GetdocCount(c_document_no  VARCHAR2)
IS
   SELECT count(a.document_no)
   FROM AHL_DOCUMENTS_B a,AHL_DOC_REVISIONS_B b
   WHERE upper(a.document_no)=upper(c_document_no)
   and   a.document_id=b.document_id;


CURSOR GetDocDetail(c_document_no VARCHAR2,c_revision_no VARCHAR2)
IS
SELECT  a.document_id,
        a.document_no,
        a.doc_type_code,
        a.doc_sub_type_code,
        a.document_title,
        b.doc_revision_id,
        b.revision_no,
        b.revision_status_code
FROM ahl_documents_vl a ,AHL_DOC_REVISIONS_B b
WHERE A.DOCUMENT_ID=B.DOCUMENT_ID
and   A.DOCUMENT_no=c_document_no
and   b.revision_no=c_revision_no;

 l_docdet_rec       GetDocDet%rowtype;
 l_object_version_number number;
 l_num_rec               NUMBER;
 l_return_status         VARCHAR2(1);
 l_lookup_code           VARCHAR2(30):='';
 l_document_id           NUMBER:=0;
 l_counter               NUMBER:=0;
 l_counter2              NUMBER:=0;
 l_counter3              NUMBER:=0;
 l_check_flag            VARCHAR2(1):='Y';
 l_record                VARCHAR2(4000):='';
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;
	 IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.TRANS_VALUE_ID','+DOBJASS+');
     END IF;

        IF p_x_association_tbl.count >0
        THEN

        FOR i IN  p_x_association_tbl.FIRST.. p_x_association_tbl.LAST
        LOOP

        IF p_x_association_tbl(i).DML_OPERATION<>'D'
        THEN
                IF  p_x_association_tbl(i).aso_object_type_code IS  NULL  or
                    p_x_association_tbl(i).aso_object_type_code = FND_API.G_MISS_CHAR
		Then
                        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYP_NOT_EXISTS');
                        FND_MSG_PUB.ADD;
                END IF;
        END IF;

        RECORD_IDENTIFIER
        (
        p_association_rec   =>p_x_association_tbl(i),
        x_record            =>l_record
        );

        IF p_x_association_tbl(i).DML_OPERATION<>'D'
        THEN
                IF  p_x_association_tbl(i).aso_object_type_code<>'MR'
                THEN
                        IF (p_x_association_tbl(i).document_no IS NULL or
                           p_x_association_tbl(i).document_no=FND_API.G_MISS_CHAR)
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCUMENT_NO_NULL');
                                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                FND_MSG_PUB.ADD;
                                IF G_DEBUG='Y' THEN
                                AHL_DEBUG_PUB.debug( 'Stage 002');
                                END IF;
                                l_check_flag:='N';
                        END IF;
                ELSE
                        IF (p_x_association_tbl(i).document_no IS NULL or
                           p_x_association_tbl(i).document_no=FND_API.G_MISS_CHAR)
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCUMENT_NO_NULL');
                                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                FND_MSG_PUB.ADD;
                                IF G_DEBUG='Y' THEN
                                        AHL_DEBUG_PUB.debug( 'Document number Null');
                                END IF;
                                l_check_flag:='N';
                        ELSE
                        OPEN  GetDocCheck(p_x_association_tbl(i).document_no);
                        FETCH GetDocCheck INTO l_counter2;
                        IF    l_counter2=0
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCUMENT_NO_INVALID');
                                FND_MESSAGE.SET_TOKEN('FIELD',p_x_association_tbl(i).document_no);
                                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                FND_MSG_PUB.ADD;
                                IF G_DEBUG='Y' THEN
                                        AHL_DEBUG_PUB.debug( 'Document number Does not exist');
                                END IF;
                                l_check_flag:='N';
                        END IF;
                        CLOSE GetDocCheck;
                        END IF;
                END IF;

                IF l_check_flag='Y'
                Then

                SELECT count(a.document_no) into l_counter3
                FROM ahl_documents_b a ,AHL_DOC_REVISIONS_B b
                WHERE A.DOCUMENT_ID=B.DOCUMENT_ID
                AND   upper(a.document_no)=upper(p_x_association_tbl(i).document_no);

                IF l_counter3=0
                THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOCNO_WITHNO_REV');
                                FND_MESSAGE.SET_TOKEN('FIELD',p_x_association_tbl(i).document_no);
                                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                FND_MSG_PUB.ADD;
                                IF G_DEBUG='Y' THEN
                                        AHL_DEBUG_PUB.debug( 'Revision for Document number does not exist');
                                END IF;

                                l_check_flag:='N';
                END IF;
                End if;

                IF l_check_flag='Y'
                THEN
                                 IF (p_x_association_tbl(i).revision_no is   null or
                                     p_x_association_tbl(i).revision_no=fnd_api.g_miss_char)
                                 THEN
                                        IF l_counter2<>1
                                        THEN
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
                                 ELSE

                                        OPEN  GetRevCheck(p_x_association_tbl(i).revision_no);
                                        FETCH GetRevCheck INTO l_counter2;
                                        IF    l_counter2=0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_REVISION_NO_INVALID');
                                                FND_MESSAGE.SET_TOKEN('FIELD',p_x_association_tbl(i).revision_no);
                                                FND_MESSAGE.SET_TOKEN('RECORD',l_record,false);
                                                FND_MSG_PUB.ADD;
                                                IF G_DEBUG='Y' THEN
                                                AHL_DEBUG_PUB.debug( 'Revision for Document number is invalid');
                                                END IF;

                                                l_check_flag:='N';
                                        END IF;
                                        CLOSE GetRevCheck;
                                 END IF;
                END IF;

                IF l_check_flag='Y'
                THEN
                        OPEN  GetdocCount(p_x_association_tbl(i).document_no);
                        FETCH GetdocCount INTO l_counter;
                        IF    l_counter=0
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOC_REV_COMB_INVLD');
                                FND_MESSAGE.SET_TOKEN('FIELD1',p_x_association_tbl(i).revision_no);
                                FND_MESSAGE.SET_TOKEN('FIELD2',p_x_association_tbl(i).document_no);
                                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                FND_MSG_PUB.ADD;
                                IF G_DEBUG='Y' THEN
                                        AHL_DEBUG_PUB.debug( 'Revision and Document number combination does not exist');
                                END IF;

                        END IF;
                        CLOSE GetdocCount;
                        IF l_counter=1
                        THEN
                                OPEN  GetDocDet(p_x_association_tbl(i).document_no);
                                FETCH GetDocDet INTO l_doc_rec;

                                IF    GetDocDet%FOUND
                                THEN
                                       p_x_association_tbl(i).document_id :=l_doc_rec.document_id;
                                       p_x_association_tbl(i).revision_no:=l_doc_rec.Revision_no;
                                       p_x_association_tbl(i).doc_revision_id:=l_doc_rec.doc_Revision_id;
                                ELSE
                                        FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOC_REV_COMB_INVLD');
                                        FND_MESSAGE.SET_TOKEN('FIELD1',p_x_association_tbl(i).revision_no);
                                        FND_MESSAGE.SET_TOKEN('FIELD2',p_x_association_tbl(i).document_no);
                                        FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                        FND_MSG_PUB.ADD;

                                        IF G_DEBUG='Y' THEN
                                        AHL_DEBUG_PUB.debug( 'Revision and Document number combination does not exist');
                                        END IF;
                                END IF;
                                CLOSE GetDocDet;

                        ELSIF l_counter>1
                        THEN
                                OPEN  GetDocDetail(p_x_association_tbl(i).document_NO,p_x_association_tbl(i).revision_no);
                                FETCH GetDocDetail INTO l_docdet_rec;
                                IF    GetDocDetail%FOUND
                                THEN
                                       IF  l_docdet_rec.document_no=p_x_association_tbl(i).document_no
                                       and l_docdet_rec.revision_no=p_x_association_tbl(i).revision_no
                                       THEN
                                               p_x_association_tbl(i).document_id :=l_docdet_rec.document_id;
                                               p_x_association_tbl(i).revision_no:=l_docdet_rec.Revision_no;
                                               p_x_association_tbl(i).doc_revision_id:=l_docdet_rec.doc_Revision_id;
                                       ELSE
                                               FND_MESSAGE.SET_NAME('AHL','AHL_DI_SELECT_FRM_LOV');
                                               FND_MSG_PUB.ADD;
                                       END IF;
                                ELSE
                                        FND_MESSAGE.SET_NAME('AHL','AHL_DI_TAB_DOC_REV_COMB_INVLD');
                                        FND_MESSAGE.SET_TOKEN('FIELD1',p_x_association_tbl(i).revision_no);
                                        FND_MESSAGE.SET_TOKEN('FIELD2',p_x_association_tbl(i).document_no);
                                        FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                                        FND_MSG_PUB.ADD;
                                END IF;
                                CLOSE GetDocDetail;
                        END IF;
                END IF;

        END IF;
        END LOOP;
END IF;
END;

PROCEDURE VALIDATE_DOC_ASSOCIATION
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_association_rec           IN     association_rec
 )
as
CURSOR GetRevDet(c_doc_revision_id NUMBER)
IS
  SELECT REVISION_STATUS_CODE,
         OBSOLETE_DATE,
         REVISION_NO
   FROM  AHL_DOC_REVISIONS_B
   WHERE DOC_REVISION_ID = c_doc_revision_id;

   l_Rev_rec1   GetRevDet%rowtype;


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

 CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER,
               c_source_ref_code      VARCHAR2,
               c_serial_no            VARCHAR2,
               c_chapter              VARCHAR2,
               c_section              VARCHAR2,
               c_subject              VARCHAR2,
               c_page                 VARCHAR2,
               c_figure               VARCHAR2)
 IS
 SELECT DOC_TITLE_ASSO_ID,aso_object_id,aso_object_type_code,document_id,doc_revision_id
 FROM AHL_DOC_TITLE_ASSOS_vl
 WHERE aso_object_id = nvl(c_aso_object_id,0)
   AND NVL(aso_object_type_code,'X') = NVL(c_aso_object_type_code,'X')
   AND document_id = nvl(c_document_id,0)
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND NVL(SOURCE_REF_CODE,'X')=NVL(C_SOURCE_REF_CODE,'X')
   AND NVL(SERIAL_NO,'X')=NVL(C_SERIAL_NO,'X')
   AND NVL(chapter,'X')  =NVL(c_chapter,'X')
   AND NVL(section,'X')  =NVL(c_section,'X')
   AND NVL(subject,'X')  =NVL(c_subject,'X')
   AND NVL(page,'X')     =NVL(c_page,'X')
   AND NVL(figure,'X')   =NVL(c_figure,'X');

 l_dup_rec        dup_rec%rowtype;

 CURSOR  CheckLatestRevFlag(C_DOC_TITLE_ASSO_ID  NUMBER,C_ASO_OBJECT_ID NUMBER,c_aso_object_type_code VARCHAR2,c_document_id  NUMBER,c_use_latest_rev_flag VARCHAR2)
 IS
 SELECT *
 FROM AHL_DOC_TITLE_ASSOS_B
 WHERE aso_object_id=c_aso_object_id
   AND aso_object_type_code=c_aso_object_type_code
   AND document_id=c_document_id
   AND use_latest_rev_flag<>nvl(c_use_latest_rev_flag,'X')
   AND DOC_TITLE_ASSO_ID <> NVL(C_DOC_TITLE_ASSO_ID,0);
 l_lat_rec   CheckLatestRevFlag%rowtype;

 l_dummy                 VARCHAR2(2000);
 l_doc_title_asso_id     NUMBER;
 l_document_id           NUMBER;
 l_doc_revision_id       NUMBER;
 l_document_no           VARCHAR2(80);
 l_use_latest_rev_flag   VARCHAR2(1);
 l_aso_object_type_code  VARCHAR2(30);
 l_aso_object_id         NUMBER;
 l_status                VARCHAR2(30);
 l_obsolete_date         DATE;
 l_object_version_number NUMBER;
 l_api_name     CONSTANT VARCHAR2(30):= 'VALIDATE_DOC_ASSOCIATION';
 l_api_version  CONSTANT NUMBER:=1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_counter               NUMBER:=0;
 l_counter1               NUMBER:=0;
 l_lookup_code           VARCHAR2(30):='';
 l_record                VARCHAR2(4000):='';
 l_type_code             VARCHAR2(30);

 BEGIN
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
			 IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.enable_debug;
     END IF;

   -- Debug info.

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.VALIDATE_DOC_ASSOCIATION','+DOBJASS+');
     END IF;



   IF p_association_rec.dml_operation <> 'D'
   THEN
        RECORD_IDENTIFIER
        (
        p_association_rec   =>p_association_rec,
        x_record            =>l_record
        );

   IF p_association_rec.aso_object_type_code = 'MR'
   THEN
        IF g_pm_install<>'Y'
        THEN

        IF p_association_rec.ASO_OBJECT_ID IS NOT NULL OR  p_association_rec.ASO_OBJECT_ID<>FND_API.G_MISS_NUM
        THEN
                SELECT TYPE_CODE INTO l_type_code
                FROM AHL_MR_HEADERS_B
                WHERE MR_HEADER_ID=p_association_rec.ASO_OBJECT_ID;

                IF L_TYPE_CODE='PROGRAM'
                THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_DI_MR_NOTEDITABLE');
                    FND_MSG_PUB.ADD;
                END IF;

        END IF;


        END IF;

   END IF;


   IF p_association_rec.doc_title_asso_id IS NOT NULL AND p_association_rec.doc_title_asso_id <> FND_API.G_MISS_NUM
   THEN
        OPEN get_doc_assos_rec_b_info(p_association_rec.doc_title_asso_id);
        FETCH get_doc_assos_rec_b_info INTO l_document_id,
                                            l_doc_revision_id,
                                            l_use_latest_rev_flag,
                                            l_aso_object_type_code,
                                            l_aso_object_id;
        CLOSE get_doc_assos_rec_b_info;
   END IF;

   OPEN get_doc_det(p_association_rec.document_id);
   FETCH get_doc_det INTO l_document_no;
   CLOSE get_doc_det;

   IF p_association_rec.aso_object_type_code = 'OPERATION' THEN
       OPEN get_operation_status(p_association_rec.aso_object_id);
       FETCH get_operation_status INTO l_status;
       CLOSE get_operation_status;
       IF l_status <> 'DRAFT' AND l_status <> 'APPROVAL_REJECTED'
       THEN
               FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_STAT_DRFT_ASO');
               FND_MSG_PUB.ADD;
               RETURN;
       END IF;
   END IF;

    IF p_association_rec.aso_object_type_code = 'ROUTE' THEN
       OPEN get_route_status(p_association_rec.aso_object_id);
       FETCH get_route_status INTO l_status;
       CLOSE get_route_status;

       IF l_status <> 'DRAFT' AND  l_status <> 'APPROVAL_REJECTED'
       THEN
               FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROU_STAT_DRFT_ASO');
               FND_MSG_PUB.ADD;
               RETURN;
       END IF;
    END IF;

    IF p_association_rec.doc_revision_id IS NOT NULL and p_association_rec.doc_revision_id <> FND_API.G_MISS_NUM
    THEN
       OPEN GetRevDet(p_association_rec.doc_revision_id);
       FETCH GetRevDet INTO l_rev_rec1;
       IF GetRevDet%notfound
       then
                FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_INVALID');
                FND_MESSAGE.SET_TOKEN('field',l_record);
                FND_MSG_PUB.ADD;
                RETURN;
       else
                IF TRUNC(NVL(l_rev_rec1.obsolete_date,SYSDATE+1)) < TRUNC(sysdate)
                THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_OBSOLETE');
                FND_MESSAGE.SET_TOKEN('FIELD1',p_association_rec.document_no);
                FND_MESSAGE.SET_TOKEN('FIELD2',l_rev_Rec1.REVISION_NO);
                FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                FND_MSG_PUB.ADD;
                END IF;
       END IF;


       CLOSE GetRevDet;
    END IF;


	IF ((p_association_rec.doc_title_asso_id IS NULL OR
             p_association_rec.doc_title_asso_id = FND_API.G_MISS_NUM) AND
            (p_association_rec.document_id IS NULL OR p_association_rec.document_id = FND_API.G_MISS_NUM))
            OR
            ((p_association_rec.doc_title_asso_id IS NOT NULL OR
              p_association_rec.doc_title_asso_id <> FND_API.G_MISS_NUM) AND l_document_id IS NULL)
        THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
		FND_MSG_PUB.ADD;
	END IF;

     -- This condition checks for Aso Object Type Code is Null

     IF ((p_association_rec.doc_title_asso_id IS NULL OR
          p_association_rec.doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_association_rec.aso_object_type_code IS NULL OR
         p_association_rec.aso_object_type_code = FND_API.G_MISS_CHAR))
        OR
        ((p_association_rec.doc_title_asso_id IS NOT NULL OR
          p_association_rec.doc_title_asso_id <> FND_API.G_MISS_NUM)
        AND l_aso_object_type_code IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_TYPE_NULL');
        FND_MSG_PUB.ADD;
     END IF;

     -- This condiiton checks for Aso Object Id Value Is Null
     IF ((p_association_rec.doc_title_asso_id IS NULL OR
          p_association_rec.doc_title_asso_id = FND_API.G_MISS_NUM) AND
        (p_association_rec.aso_object_id IS NULL OR
         p_association_rec.aso_object_id = FND_API.G_MISS_NUM))
        OR
        ((p_association_rec.doc_title_asso_id IS NOT NULL OR
          p_association_rec.doc_title_asso_id <> FND_API.G_MISS_NUM) AND l_aso_object_id IS NULL)
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJECT_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;

    --Check for Aso Object Type Code in fnd lookups

    IF p_association_rec.aso_object_type_code IS NOT NULL AND
       p_association_rec.aso_object_type_code <> FND_API.G_MISS_CHAR
    THEN
       OPEN get_aso_obj_type_code(p_association_rec.aso_object_type_code);
       FETCH get_aso_obj_type_code INTO l_dummy;
       IF get_aso_obj_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASO_OBJ_TYPE_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_aso_obj_type_code;
     END IF;

    -- Validates for existence of document id in ahl documents table

   IF p_association_rec.DML_OPERATION<>'D'
   THEN

     OPEN dup_rec(p_association_rec.aso_object_type_code,
                  p_association_rec.aso_object_id,
                  p_association_rec.document_id,
                  p_association_rec.doc_revision_id,
                  p_association_Rec.source_Ref_code,
                  p_association_Rec.serial_no,
                  p_association_Rec.chapter,
                  p_association_Rec.section,
                  p_association_Rec.subject,
                  p_association_Rec.page,
                  p_association_Rec.figure
                  );
     FETCH dup_rec INTO l_dup_rec;
     IF dup_Rec%found
     then
             IF p_association_rec.DML_OPERATION='C'
             THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_DI_TABDOC_ASSOS_DUP_RECORD');
                        FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                        FND_MSG_PUB.ADD;
             END IF;
             --bug fix : pbarman : May 23 rd 2003
             --IF p_association_rec.DML_OPERATION='U'
             --THEN

             --  IF nvl(p_association_rec.doc_title_asso_id,0)<>nvl(l_dup_rec.doc_title_asso_id,0)
             --  THEN


             --    FND_MESSAGE.SET_NAME('AHL','AHL_DI_TABDOC_ASSOS_DUP_RECORD');
             --    FND_MESSAGE.SET_TOKEN('RECORD',l_record);
             --    FND_MSG_PUB.ADD;
             --           IF G_DEBUG='Y' THEN
             --              AHL_DEBUG_PUB.debug( 'Dup_record Not Found' ,'+DOBJASS+');
             --           END IF;
             --  END IF;


             --END IF;
     END IF;
     CLOSE dup_rec;


-- Latest Rev Flag Check.
         SELECT count(*) into l_counter1
         FROM AHL_DOC_TITLE_ASSOS_B
         WHERE aso_object_id=nvl(p_association_rec.aso_object_id,0)
           AND aso_object_type_code=nvl(p_association_rec.aso_object_type_code,'x')
           AND document_id=nvl(p_association_rec.document_id,0)
           AND nvl(use_latest_rev_flag,'N')='Y'
           AND NVL(p_association_rec.DOC_TITLE_ASSO_ID,0)=0;


         SELECT count(*) into l_counter
         FROM AHL_DOC_TITLE_ASSOS_B
         WHERE aso_object_id=nvl(p_association_rec.aso_object_id,0)
           AND aso_object_type_code=nvl(p_association_rec.aso_object_type_code,'x')
           AND document_id=nvl(p_association_rec.document_id,0)
           AND use_latest_rev_flag<>NVL(p_association_rec.use_latest_rev_flag,'N');

   if    l_counter1>0
   then
                 FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_DUP_YES');
                 FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                 FND_MSG_PUB.ADD;

   elsif (l_counter>0  and p_association_rec.DML_OPERATION='C') OR  (l_counter>1  and p_association_rec.DML_OPERATION='U')
   then
           open CheckLatestRevFlag(NVL(p_association_rec.DOC_TITLE_ASSO_ID,0),p_association_rec.aso_object_id,p_association_rec.aso_object_type_code,p_association_rec.document_id,NVL(p_association_rec.use_latest_rev_flag,'X'));
           fetch CheckLatestRevFlag intO l_lat_rec;
           IF CheckLatestRevFlag%FOUND
           THEN
                         FND_MESSAGE.SET_NAME('AHL','AHL_DI_USE_LATEST_FLAG');
                         FND_MESSAGE.SET_TOKEN('RECORD',l_record);
                         FND_MSG_PUB.ADD;
           END IF;
           close CheckLatestRevFlag;
   end if;


   END IF;

 END IF;
	 IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'exit ahl_di_asso_doc_aso_pub.VALIDATE_DOC_ASSOCIATION','+DOBJASS+');
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
                            p_procedure_name  =>'VALIDATE_DOC_ASSOCIATION',
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded      => FND_API.G_FALSE,
                               p_count        => x_msg_count,
                               p_data         => X_msg_data);
 END;


PROCEDURE PROCESS_ASSOCIATION
(
 p_api_version               IN     		NUMBER    := 1.0,
 p_init_msg_list             IN     		VARCHAR2  := FND_API.G_TRUE,
 p_commit                    IN     		VARCHAR2  := FND_API.G_FALSE ,
 p_validation_level          IN     		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type               IN     		VARCHAR2 ,
 x_return_status             OUT 		NOCOPY VARCHAR2,
 x_msg_count                 OUT 		NOCOPY NUMBER,
 x_msg_data                  OUT 		NOCOPY VARCHAR2,
 p_x_association_tbl         IN OUT NOCOPY 	association_tbl)
IS

--cursor to check for duplicate records : pbarman 23rd May 2003
CURSOR dup_rec(c_aso_object_type_code VARCHAR2,
               c_aso_object_id        NUMBER,
               c_document_id          NUMBER,
               c_doc_revision_id      NUMBER,
               c_source_ref_code      VARCHAR2,
               c_serial_no            VARCHAR2,
               c_chapter              VARCHAR2,
               c_section              VARCHAR2,
               c_subject              VARCHAR2,
               c_page                 VARCHAR2,
               c_figure               VARCHAR2)
 IS
 SELECT DOC_TITLE_ASSO_ID
 FROM AHL_DOC_TITLE_ASSOS_vl
 WHERE aso_object_id = nvl(c_aso_object_id,0)
   AND NVL(aso_object_type_code,'X') = NVL(c_aso_object_type_code,'X')
   AND document_id = nvl(c_document_id,0)
   AND nvl(doc_revision_id,0) = nvl(c_doc_revision_id,0)
   AND NVL(SOURCE_REF_CODE,'X')=NVL(C_SOURCE_REF_CODE,'X')
   AND NVL(SERIAL_NO,'X')=NVL(C_SERIAL_NO,'X')
   AND NVL(chapter,'X')  =NVL(c_chapter,'X')
   AND NVL(section,'X')  =NVL(c_section,'X')
   AND NVL(subject,'X')  =NVL(c_subject,'X')
   AND NVL(page,'X')     =NVL(c_page,'X')
   AND NVL(figure,'X')   =NVL(c_figure,'X');

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
l_found_flag             VARCHAR2(5)  := 'N';
l_doc_title_asso_id      NUMBER;
l_record                VARCHAR2(4000):='';

BEGIN
  -- Standard Start of API savepoint
     SAVEPOINT process_association;
   -- Check if API is called in debug mode. If yes, enable debug.

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.enable_debug;
     END IF;

   -- Debug info.

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'enter ahl_di_asso_doc_aso_pub.Process Association','+DOBJASS+');
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
                        END IF;
                END IF;
                END LOOP;

                IF FND_API.to_boolean(p_default)
                THEN
                        DEFAULT_MISSING_ATTRIBS
                        (
                        p_x_association_tbl =>p_x_association_tbl
                        );
                END IF;

                TRANS_VALUE_ID
                (
                x_return_status             =>x_return_Status,
                p_x_association_tbl         =>p_x_association_tbl
                );

                l_msg_count := FND_MSG_PUB.count_msg;

                IF l_msg_count > 0 THEN
                   X_msg_count := l_msg_count;
                   X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'before modify');
		END IF;

                FOR i IN p_x_association_tbl.FIRST..p_x_association_tbl.LAST
                LOOP
                l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_msg_count:=0;
                IF l_msg_count > 0 THEN
                	l_msg_count := FND_MSG_PUB.count_msg;
                   	l_msg_count := l_msg_count;
                   	l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                VALIDATE_DOC_ASSOCIATION
                (
                x_return_status             =>l_return_Status,
                x_msg_count                 =>l_msg_count,
                x_msg_data                  =>l_msg_data,
                p_association_rec           =>p_x_association_tbl(i));

        -- check whether the record is there in the database if no then no error.
	-- if yes then check whether the record is there in tbl_rec.
	-- check only for the rec with doc_title_asso_id = doc_title_asso_id of rec that has aduplicate in database
	-- if such a record not found in tbl_rec then throw error.
        -- bug no 2918260 : pbarman : 23 rd April 2003

         IF p_x_association_tbl(i).DML_OPERATION='U'
	 THEN
	 OPEN dup_rec(p_x_association_tbl(i).aso_object_type_code,
                  p_x_association_tbl(i).aso_object_id,
                  p_x_association_tbl(i).document_id,
                  p_x_association_tbl(i).doc_revision_id,
                  p_x_association_tbl(i).source_Ref_code,
                  p_x_association_tbl(i).serial_no,
                  p_x_association_tbl(i).chapter,
                  p_x_association_tbl(i).section,
                  p_x_association_tbl(i).subject,
                  p_x_association_tbl(i).page,
                  p_x_association_tbl(i).figure
                  );
                 FETCH dup_rec INTO l_doc_title_asso_id;
                 IF dup_Rec%found
                 THEN
		  FOR j IN (i+1)..p_x_association_tbl.LAST
		  LOOP
		      IF( p_x_association_tbl(j).doc_title_asso_id = l_doc_title_asso_id)
		      THEN
		      l_found_flag := 'Y';
			      IF(p_x_association_tbl(j).aso_object_type_code = p_x_association_tbl(i).aso_object_type_code AND
				p_x_association_tbl(j).aso_object_id = p_x_association_tbl(i).aso_object_id AND
				p_x_association_tbl(j).document_id = p_x_association_tbl(i).document_id AND
				p_x_association_tbl(j).doc_revision_id = p_x_association_tbl(i).doc_revision_id AND
				p_x_association_tbl(j).source_Ref_code = p_x_association_tbl(i).source_Ref_code AND
				p_x_association_tbl(j).serial_no = p_x_association_tbl(i).serial_no AND
				p_x_association_tbl(j).chapter = p_x_association_tbl(i).chapter AND
				p_x_association_tbl(j).section = p_x_association_tbl(i).section AND
				p_x_association_tbl(j).subject = p_x_association_tbl(i).subject AND
				p_x_association_tbl(j).page = p_x_association_tbl(i).page AND
				p_x_association_tbl(j).figure = p_x_association_tbl(i).figure
			       )
			     THEN


				FND_MESSAGE.SET_NAME('AHL','AHL_DI_TABDOC_ASSOS_DUP_RECORD');
			        RECORD_IDENTIFIER
				(
				p_association_rec   =>p_x_association_tbl(i),
				x_record            =>l_record
				);

				FND_MESSAGE.SET_TOKEN('RECORD',l_record);
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;

			     END IF;
			END IF;

		  END LOOP;

		  IF l_found_flag = 'N'
		  THEN

		    FND_MESSAGE.SET_NAME('AHL','AHL_DI_TABDOC_ASSOS_DUP_RECORD');
		    RECORD_IDENTIFIER
		    (
		    p_association_rec   =>p_x_association_tbl(i),
		    x_record            =>l_record
		    );

		    FND_MESSAGE.SET_TOKEN('RECORD',l_record);
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		  END IF;

                END IF;

                CLOSE dup_Rec;
         END IF;

                IF l_return_status= FND_API.G_RET_STS_SUCCESS
                THEN

                        IF    p_x_association_tbl(i).DML_OPERATION ='D'
                        THEN
                          delete from AHL_DOC_TITLE_ASSOS_TL
                            where DOC_TITLE_ASSO_ID    = p_x_association_tbl(I).DOC_TITLE_ASSO_ID;
                              IF  (sql%notfound)
                              THEN
                                   FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                                   FND_MSG_PUB.ADD;
                              ELSE
                                  delete from AHL_DOC_TITLE_ASSOS_B
                                  where DOC_TITLE_ASSO_ID = p_x_association_tbl(I).DOC_TITLE_ASSO_ID
                                  and   OBJECT_VERSION_NUMBER=p_x_association_tbl(I).OBJECT_VERSION_NUMBER;

                                      IF  (sql%notfound)
                                      THEN
                                           FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                                           FND_MSG_PUB.ADD;
                                      END IF;
                              END IF;
                        ELSIF p_x_association_tbl(i).DML_OPERATION ='U'
                        THEN
                          update AHL_DOC_TITLE_ASSOS_B set
                            SERIAL_NO          = p_x_association_tbl(i).SERIAL_NO,
                            ATTRIBUTE_CATEGORY = p_x_association_tbl(i).ATTRIBUTE_CATEGORY,
                            ATTRIBUTE1         = p_x_association_tbl(i).ATTRIBUTE1,
                            ATTRIBUTE2         = p_x_association_tbl(i).ATTRIBUTE2,
                            ATTRIBUTE3         = p_x_association_tbl(i).ATTRIBUTE3,
                            ATTRIBUTE4         = p_x_association_tbl(i).ATTRIBUTE4,
                            ATTRIBUTE5         = p_x_association_tbl(i).ATTRIBUTE5,
                            ATTRIBUTE6         = p_x_association_tbl(i).ATTRIBUTE6,
                            ATTRIBUTE7         = p_x_association_tbl(i).ATTRIBUTE7,
                            ATTRIBUTE8         = p_x_association_tbl(i).ATTRIBUTE8,
                            ATTRIBUTE9         = p_x_association_tbl(i).ATTRIBUTE9,
                            ATTRIBUTE10        = p_x_association_tbl(i).ATTRIBUTE10,
                            ATTRIBUTE11        = p_x_association_tbl(i).ATTRIBUTE11,
                            ATTRIBUTE12        = p_x_association_tbl(i).ATTRIBUTE12,
                            ATTRIBUTE13        = p_x_association_tbl(i).ATTRIBUTE13,
                            ATTRIBUTE14        = p_x_association_tbl(i).ATTRIBUTE14,
                            ATTRIBUTE15        = p_x_association_tbl(i).ATTRIBUTE15,
                            ASO_OBJECT_TYPE_CODE = p_x_association_tbl(i).ASO_OBJECT_TYPE_CODE,
                            SOURCE_REF_CODE    = p_x_association_tbl(i).SOURCE_REF_CODE,
                            ASO_OBJECT_ID      = p_x_association_tbl(i).ASO_OBJECT_ID,
                            DOCUMENT_ID        = p_x_association_tbl(i).DOCUMENT_ID,
                            USE_LATEST_REV_FLAG= p_x_association_tbl(i).USE_LATEST_REV_FLAG,
                            DOC_REVISION_ID    = p_x_association_tbl(i).DOC_REVISION_ID,
                            OBJECT_VERSION_NUMBER = p_x_association_tbl(i).OBJECT_VERSION_NUMBER+1,
                            LAST_UPDATE_DATE   =SYSDATE,
                            LAST_UPDATED_BY    =fnd_global.user_id,
                            LAST_UPDATE_LOGIN  =fnd_global.user_id
                            where DOC_TITLE_ASSO_ID    = p_x_association_tbl(i).DOC_TITLE_ASSO_ID
                            and   OBJECT_VERSION_NUMBER=p_x_association_tbl(I).OBJECT_VERSION_NUMBER;


                          IF  (sql%notfound)
                          THEN
                                  FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                                  FND_MSG_PUB.ADD;
                          ELSE
                                  update AHL_DOC_TITLE_ASSOS_TL set
                                    CHAPTER = p_x_association_tbl(i).CHAPTER,
                                    SECTION = p_x_association_tbl(i).SECTION,
                                    SUBJECT = p_x_association_tbl(i).SUBJECT,
                                    FIGURE = p_x_association_tbl(i).FIGURE,
                                    PAGE = p_x_association_tbl(i).PAGE,
                                    NOTE = p_x_association_tbl(i).NOTE,
                                    LAST_UPDATE_DATE = p_x_association_tbl(i).LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY = p_x_association_tbl(i).LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN = p_x_association_tbl(i).LAST_UPDATE_LOGIN,
                                    SOURCE_LANG = userenv('LANG')
                                  where DOC_TITLE_ASSO_ID = p_x_association_tbl(i).DOC_TITLE_ASSO_ID
                                  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
                                  IF (sql%notfound)
                                  THEN
                                          FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                                          FND_MSG_PUB.ADD;
                                  END IF;
                          END IF;
                        ELSIF p_x_association_tbl(i).DML_OPERATION ='C'
                        THEN
                            SELECT AHL_DOC_TITLE_ASSOS_B_S.Nextval INTO
                                   p_x_association_tbl(i).doc_title_asso_id from DUAL;

                                AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW(
                                X_ROWID                        =>l_rowid,
                                X_DOC_TITLE_ASSO_ID            =>p_x_association_tbl(i).doc_title_asso_id,
                                X_SERIAL_NO                    =>p_x_association_tbl(i).serial_no,
                                X_ATTRIBUTE_CATEGORY           =>p_x_association_tbl(i).attribute_category,
                                X_ATTRIBUTE1                   =>p_x_association_tbl(i).attribute1,
                                X_ATTRIBUTE2           =>p_x_association_tbl(i).attribute2,
                                X_ATTRIBUTE3           =>p_x_association_tbl(i).attribute3,
                                X_ATTRIBUTE4           =>p_x_association_tbl(i).attribute4,
                                X_ATTRIBUTE5           =>p_x_association_tbl(i).attribute5,
                                X_ATTRIBUTE6           =>p_x_association_tbl(i).attribute6,
                                X_ATTRIBUTE7           =>p_x_association_tbl(i).attribute7,
				X_ATTRIBUTE8           => p_x_association_tbl(i).attribute8,
                                X_ATTRIBUTE9           =>p_x_association_tbl(i).attribute9,
			        X_ATTRIBUTE10          =>p_x_association_tbl(i).attribute10,
                                X_ATTRIBUTE11          =>p_x_association_tbl(i).attribute11,
                                X_ATTRIBUTE12          =>p_x_association_tbl(i).attribute12,
                                X_ATTRIBUTE13          =>p_x_association_tbl(i).attribute13,
                                X_ATTRIBUTE14          =>p_x_association_tbl(i).attribute14,
                                X_ATTRIBUTE15          =>      p_x_association_tbl(i).attribute15,
                                X_ASO_OBJECT_TYPE_CODE =>      p_x_association_tbl(i).aso_object_type_code,
                                X_SOURCE_REF_CODE      =>      p_x_association_tbl(i).SOURCE_REF_CODE,
                                X_ASO_OBJECT_ID        =>      p_x_association_tbl(i).aso_object_id,
                                X_DOCUMENT_ID          =>      p_x_association_tbl(i).document_id,
                               X_USE_LATEST_REV_FLAG =>nvl(p_x_association_tbl(i).use_latest_rev_flag,'N'),
                                X_DOC_REVISION_ID      =>      p_x_association_tbl(i).doc_revision_id,
                                X_OBJECT_VERSION_NUMBER         =>      1,
                                X_CHAPTER                       =>      p_x_association_tbl(i).chapter,
                                X_SECTION                       =>      p_x_association_tbl(i).section,
                                X_SUBJECT                       =>      p_x_association_tbl(i).subject,
                                X_FIGURE                        =>      p_x_association_tbl(i).figure,
                                X_PAGE                          =>      p_x_association_tbl(i).page,
                                X_NOTE                          =>      p_x_association_tbl(i).note,
                                X_CREATION_DATE                 =>      sysdate,
                                X_CREATED_BY                    =>      fnd_global.user_id,
                                X_LAST_UPDATE_DATE              =>      sysdate,
                                X_LAST_UPDATED_BY               =>      fnd_global.user_id,
                                X_LAST_UPDATE_LOGIN             =>      fnd_global.login_id);
                        END IF;
                END IF;
        END LOOP;

        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
				 IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'exit ahl_di_asso_doc_aso_pub.Process Association','+DOBJASS+');
     END IF;

      	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

EXCEPTION
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
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_association;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME ,
                            p_procedure_name  => 'PROCESS_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END PROCESS_ASSOCIATION;

END AHL_DI_ASSO_DOCASO_PVT;

/
