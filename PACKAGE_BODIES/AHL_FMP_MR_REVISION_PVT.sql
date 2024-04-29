--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_REVISION_PVT" AS
/* $Header: AHLVMRRB.pls 120.5.12010000.5 2009/09/04 04:50:12 sikumar ship $ */

G_PKG_NAME  		VARCHAR2(30):='AHL_FMP_MR_REVISION_PVT';
G_DEBUG                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
G_APPLN_USAGE           VARCHAR2(30) :=LTRIM(RTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));

TYPE TEMP_MR_ROUTE_REC IS RECORD
(
OLD_MR_ROUTE_ID                         NUMBER,
NEW_MR_ROUTE_ID                         NUMBER
);

TYPE TEMP_MR_ROUTE_TBL IS TABLE OF TEMP_MR_ROUTE_REC INDEX BY BINARY_INTEGER;



PROCEDURE VALIDATE_MR_REV
 (
 x_return_status                OUT NOCOPY      VARCHAR2,
 x_msg_count                    OUT NOCOPY      NUMBER,
 x_msg_data                     OUT NOCOPY      VARCHAR2,
 p_source_mr_header_id          IN              NUMBER
 )
 AS
 CURSOR CheckAnyExistingMr(C_TITLE VARCHAR2)
 is
 Select count(title)
 From AHL_MR_HEADERS_APP_V
 Where title=C_TITLE
 And (MR_STATUS_CODE='DRAFT'
   OR MR_STATUS_CODE='APPROVAL_REJECTED'
   OR MR_STATUS_CODE='APPROVAL_PENDING')
   AND MR_HEADER_ID > p_source_mr_header_id ;

 Cursor CheckCurrentlyActive(C_TITLE 		VARCHAR2,
			     C_MR_HEADER_ID  	NUMBER,
			     C_VERSION_NUMBER  	NUMBER)
 Is
 Select count(*)
 From ahl_mr_headers_APP_V
 Where title=C_TITLE
-- And mr_status_code='COMPLETE'
 And mr_header_id >C_MR_HEADER_ID
 And version_number>C_VERSION_NUMBER;

 l_status               VARCHAR2(30);
 l_appln_code           AHL_MR_HEADERS_B.APPLICATION_USG_CODE%TYPE;
 l_title                AHL_MR_HEADERS_B.TITLE%TYPE;
 l_version_number       NUMBER:=0;
 l_counter              NUMBER:=0;
 l_check_flag           VARCHAR2(1):='N';
 BEGIN
        x_return_status:=fnd_api.g_ret_sts_success;


       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;

        IF g_appln_usage is null
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        ELSIF (g_appln_usage = 'PM')
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_MRR_PM_INSTALL');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;


        Select MR_STATUS_CODE,TITLE,VERSION_NUMBER
                 into l_status,l_title,l_version_number
        From ahl_mr_headers_app_v
        Where mr_header_id=p_source_mr_header_id;


      IF SQL%ROWCOUNT>0
      THEN
             IF l_status<>'COMPLETE'
             THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_CANNOT_CREATE_REV');
                   FND_MESSAGE.SET_TOKEN('RECORD',l_title,false);
                   FND_MSG_PUB.ADD;
                   l_check_flag:='N';
             ELSE
                   l_check_flag:='Y';
             END IF;

              IF l_check_flag='Y'
              THEN

                  OPEN  CheckAnyExistingMr(upper(l_title));
                  FETCH CheckAnyExistingMr INTO l_counter;
                  IF    CheckAnyExistingMr%FOUND
                  THEN
                      IF l_counter>0
                      THEN
                      FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_REVISION_CREATED');
                      FND_MESSAGE.SET_TOKEN('RECORD',l_title,false);
                      FND_MSG_PUB.ADD;
                      l_check_flag:='N';
                      END IF;
                  END IF;
                  CLOSE CheckAnyExistingMr;
               END IF;
      END IF;

    IF l_check_flag='Y'
    THEN
       OPEN  CheckCurrentlyActive(l_title,p_source_mr_header_id,l_version_number);
       FETCH CheckCurrentlyActive INTO l_counter;
       IF    CheckCurrentlyActive%FOUND
       THEN
           IF l_counter>0
           THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_NOT_LATEST');
                   FND_MSG_PUB.ADD;
           END IF;
       END IF;
       CLOSE CheckCurrentlyActive;
    END IF;


 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_REVISION_PVT',
                            p_procedure_name  =>  'VALIDATE_MR_REV',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 END;

PROCEDURE CREATE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id          IN      NUMBER,
 x_new_mr_header_id             OUT NOCOPY     NUMBER
 )
 AS
CURSOR LckGetHeader
is
select mr_header_id
from AHL_MR_HEADERS_APP_V
where mr_header_id=p_source_mr_header_id;

CURSOR CurGetHeaderdet
Is
SELECT
MR_HEADER_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
TITLE,
VERSION_NUMBER,
PRECEDING_MR_HEADER_ID,
CATEGORY_CODE,
SERVICE_TYPE_CODE,
MR_STATUS_CODE,
IMPLEMENT_STATUS_CODE,
REPETITIVE_FLAG,
SHOW_REPETITIVE_CODE,
WHICHEVER_FIRST_CODE,
COPY_ACCOMPLISHMENT_FLAG,
PROGRAM_TYPE_CODE,
PROGRAM_SUBTYPE_CODE,
EFFECTIVE_FROM,
EFFECTIVE_TO,
REVISION,
BILLING_ITEM_ID,
BILLING_ORG_ID,
SPACE_CATEGORY_CODE,
QA_INSPECTION_TYPE_CODE,
DESCRIPTION,
COMMENTS,
SERVICE_REQUEST_TEMPLATE_ID,
TYPE_CODE,
DOWN_TIME,
UOM_CODE,
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
AUTO_SIGNOFF_FLAG,
COPY_INIT_ACCOMPL_FLAG,
COPY_DEFERRALS_FLAG,
APPLICATION_USG_CODE
from AHL_MR_HEADERS_APP_V
where mr_header_id=p_source_mr_header_id;

CURSOR CurGetDocTitledet
is
select
A.DOC_TITLE_ASSO_ID,
A.OBJECT_VERSION_NUMBER,
A.LAST_UPDATE_DATE,
A.LAST_UPDATED_BY,
A.CREATION_DATE,
A.CREATED_BY,
A.LAST_UPDATE_LOGIN,
A.DOC_REVISION_ID,
A.ASO_OBJECT_TYPE_CODE,
A.ASO_OBJECT_ID,
A.DOCUMENT_ID,
A.USE_LATEST_REV_FLAG,
A.SERIAL_NO,
A.SECURITY_GROUP_ID,
A.ATTRIBUTE_CATEGORY,
A.ATTRIBUTE1,
A.ATTRIBUTE2,
A.ATTRIBUTE3,
A.ATTRIBUTE4,
A.ATTRIBUTE5,
A.ATTRIBUTE6,
A.ATTRIBUTE7,
A.ATTRIBUTE8,
A.ATTRIBUTE9,
A.ATTRIBUTE10,
A.ATTRIBUTE11,
A.ATTRIBUTE12,
A.ATTRIBUTE13,
A.ATTRIBUTE14,
A.ATTRIBUTE15,
A.SOURCE_REF_CODE,
b.chapter,
b.section,
b.subject,
b.page,
b.figure,
b.note
from AHL_DOC_TITLE_ASSOS_B A,AHL_DOC_TITLE_ASSOS_TL B
where  A.ASO_OBJECT_TYPE_CODE='MR'
AND    A.ASO_OBJECT_ID=p_source_mr_header_id
and    A.doc_title_asso_id=B.doc_title_asso_id
AND    B.LANGUAGE=USERENV('LANG')
AND    A.ASO_OBJECT_ID NOT IN (SELECT DOCUMENT_ID
                               FROM  AHL_DOC_REVISIONS_VL
                               WHERE DOCUMENT_ID=A.ASO_OBJECT_ID
                               AND NVL(REVISION_STATUS_CODE,'CURRENT')='OBSOLETE');

l_doc_title_asso_id             NUMBER:=0;

-- Routes
CURSOR CurGetRoutedet
IS
SELECT
MR_ROUTE_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
MR_HEADER_ID,
ROUTE_ID,
SECURITY_GROUP_ID,
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
STAGE
FROM  AHL_MR_ROUTES A
WHERE MR_HEADER_ID=P_SOURCE_MR_HEADER_ID
AND   ROUTE_ID IN (SELECT ROUTE_ID
                   FROM AHL_ROUTES_B
                   WHERE ROUTE_ID=A.ROUTE_ID
                   AND NVL(END_DATE_ACTIVE,sysdate+1)>SYSDATE
                   AND REVISION_STATUS_CODE='COMPLETE'
                  );

l_TEMP_MR_ROUTE_TBL             TEMP_MR_ROUTE_TBL;

-- Route Sequences
CURSOR CurGetRouteSeqDet(C_MR_ROUTE_ID NUMBER)
iS
SELECT  MR_ROUTE_SEQUENCE_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
MR_ROUTE_ID,
RELATED_MR_ROUTE_ID,
SEQUENCE_CODE,
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
ATTRIBUTE15
FROM  AHL_MR_ROUTE_SEQUENCES C
WHERE MR_ROUTE_ID=C_MR_ROUTE_ID
AND  EXISTS
(SELECT MR_ROUTE_ID
FROM  AHL_MR_ROUTES A
WHERE MR_HEADER_ID=P_SOURCE_MR_HEADER_ID
AND   MR_ROUTE_ID=C.RELATED_MR_ROUTE_ID
AND   ROUTE_ID IN (SELECT ROUTE_ID
                   FROM AHL_ROUTES_B
                   WHERE ROUTE_ID=A.ROUTE_ID
                   AND NVL(END_DATE_ACTIVE,sysdate+1)>SYSDATE
                   AND REVISION_STATUS_CODE='COMPLETE'
                  )
);


l_mr_route_seq_rec              CurGetRouteSeqDet%rowtype;
l_seq_mr_route_id               NUMBER:=0;
l_seq_rel_mr_route_id           NUMBER:=0;
l_mr_route_index                NUMBER:=0;


-- Effectivity
CURSOR CurGetEffectDet
        IS
        SELECT
        MR_EFFECTIVITY_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_HEADER_ID,
        NAME,
        THRESHOLD_DATE,
        INVENTORY_ITEM_ID,
        INVENTORY_ORG_ID,
        RELATIONSHIP_ID,
        PC_NODE_ID,
        DEFAULT_FLAG,
        PROGRAM_DURATION,
        PROGRAM_DURATION_UOM_CODE,
        SECURITY_GROUP_ID,
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
        ATTRIBUTE15
        FROM AHL_MR_EFFECTIVITIES_APP_V
        WHERE MR_HEADER_ID=P_SOURCE_MR_HEADER_ID;

CURSOR CurGetMrIntervals(C_MR_EFFECTIVITY_ID NUMBER)
        IS
        SELECT
        MR_INTERVAL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_EFFECTIVITY_ID,
        COUNTER_ID,
        INTERVAL_VALUE,
        EARLIEST_DUE_VALUE,
        START_VALUE,
        STOP_VALUE,
        START_DATE,
	CALC_DUEDATE_RULE_CODE, --pdoki added for ADAT ER
        STOP_DATE,
        TOLERANCE_BEFORE,
        TOLERANCE_AFTER,
        SECURITY_GROUP_ID,
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
        RESET_VALUE
        FROM AHL_MR_INTERVALS_APP_V
        WHERE MR_EFFECTIVITY_ID=C_MR_EFFECTIVITY_ID;
l_interval_rec          CurGetMrIntervals%rowtype;


-- Effectivity Details
CURSOR CurGetEffectDTLS(C_MR_EFFECTIVITY_ID NUMBER)
        IS
        SELECT
        MR_EFFECTIVITY_DETAIL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_EFFECTIVITY_ID,
        EXCLUDE_FLAG,
        MANUFACTURER_ID,
        COUNTRY_CODE,
        SERIAL_NUMBER_FROM,
        SERIAL_NUMBER_TO,
        MANUFACTURE_DATE_FROM,
        MANUFACTURE_DATE_TO,
        SECURITY_GROUP_ID,
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
        ATTRIBUTE15
        FROM AHL_MR_EFFECTIVITY_DTLS_APP_V
        WHERE MR_EFFECTIVITY_ID=C_MR_EFFECTIVITY_ID;

-- Effectivity Details
CURSOR CurGetEffectExtDTLS(C_MR_EFFECTIVITY_ID NUMBER)
        IS
        SELECT
        MR_EFFECTIVITY_EXT_DTL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_EFFECTIVITY_ID,
        EXCLUDE_FLAG,
        EFFECT_EXT_DTL_REC_TYPE,
        OWNER_ID,
        LOCATION_TYPE_CODE,
        CSI_EXT_ATTRIBUTE_CODE,
        CSI_EXT_ATTRIBUTE_VALUE,
        SECURITY_GROUP_ID,
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
        ATTRIBUTE15
        FROM AHL_MR_EFFECTIVITY_EXT_DTLS
        WHERE MR_EFFECTIVITY_ID=C_MR_EFFECTIVITY_ID;

l_mr_effect_ext_dtls_rec            CurGetEffectExtDTLS%rowtype;

CURSOR CurGetRelationDet
        IS
        SELECT
        MR_RELATIONSHIP_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_HEADER_ID,
        RELATED_MR_HEADER_ID,
        RELATIONSHIP_CODE,
        SECURITY_GROUP_ID,
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
        ATTRIBUTE15
        FROM  AHL_MR_RELATIONSHIPS_APP_V A
        WHERE (MR_HEADER_ID=P_SOURCE_MR_HEADER_ID  or RELATED_MR_HEADER_ID=P_SOURCE_MR_HEADER_ID)
        AND EXISTS(SELECT MR_HEADER_ID
                   FROM AHL_MR_HEADERS_APP_V
                   WHERE ( MR_HEADER_ID=A.MR_HEADER_ID
                   OR MR_HEADER_ID=A.RELATED_MR_HEADER_ID)
                   AND MR_STATUS_CODE<>'TERMINATED'
                   AND NVL(EFFECTIVE_TO,SYSDATE+1) >SYSDATE);


l_rel_rec                       CurGetRelationDet%rowtype;

l_mr_effect_dtls_rec            CurGetEffectDTLS%rowtype;

Cursor CurGetMrVisitTypes
Is
SELECT
MR_VISIT_TYPE_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
MR_VISIT_TYPE_CODE,
MR_HEADER_ID,
SECURITY_GROUP_ID,
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
ATTRIBUTE15
FROM AHL_MR_VISIT_TYPES
WHERE MR_HEADER_ID=P_SOURCE_MR_HEADER_ID;

l_mrvsttype_rec                 CurGetMrVisitTypes%rowtype;
l_row_id                        VARCHAR2(30);
l_mr_relationship_id            NUMBER:=0;
l_old_mr_route_id               NUMBER:=0;
l_new_mr_route_id               NUMBER:=0;
l_new_mr_route_seq_id           NUMBER:=0;
l_new_mr_effectivity_id         NUMBER:=0;
l_old_mr_effectivity_id         NUMBER:=0;
l_new_mr_effectivity_dtl_id     NUMBER:=0;
l_old_mr_effectivity_dtl_id     NUMBER:=0;
l_version_number                NUMBER:=0;

l_api_name     CONSTANT         VARCHAR2(30) := 'CREATE_MR_REVISION';
l_api_version  CONSTANT         NUMBER       := 1.0;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_date                          DATE;
BEGIN

       SAVEPOINT  CREATE_MR_REVISION_PVT;

       IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.enable_debug;
                AHL_DEBUG_PUB.debug( ' START CREATE MR REVISION ');
       END IF;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
      IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   --Start of API Body

         VALIDATE_MR_REV
         (
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_source_mr_header_id       =>p_source_mr_header_id
         );

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   --Start of API Body


        for l_mr_header_rec in  CurGetHeaderdet
        loop
        l_date:=sysdate;
        IF l_mr_header_Rec.EFFECTIVE_FROM>SYSDATE
        THEN
                l_date:=l_mr_header_Rec.EFFECTIVE_FROM;
        END IF;

        l_version_number:=l_mr_header_Rec.version_number + 1;
         AHL_MR_HEADERS_PKG.INSERT_ROW (
          X_MR_HEADER_ID		=>x_new_mr_header_id,
          X_OBJECT_VERSION_NUMBER	=>1,
          X_CATEGORY_CODE		=>l_mr_header_Rec.CATEGORY_CODE,
          X_SERVICE_TYPE_CODE		=>l_mr_header_Rec.SERVICE_TYPE_CODE,
          X_MR_STATUS_CODE		=>'DRAFT',
          X_IMPLEMENT_STATUS_CODE	=>l_mr_header_Rec.IMPLEMENT_STATUS_CODE,
          X_REPETITIVE_FLAG		=>l_mr_header_Rec.REPETITIVE_FLAG,
          X_SHOW_REPETITIVE_CODE	=>l_mr_header_Rec.SHOW_REPETITIVE_CODE,
          X_WHICHEVER_FIRST_CODE	=>l_mr_header_Rec.WHICHEVER_FIRST_CODE,
          X_COPY_ACCOMPLISHMENT_FLAG=> 'Y',-- defaulting l_mr_header_Rec.COPY_ACCOMPLISHMENT_FLAG,
          X_PROGRAM_TYPE_CODE		=>l_mr_header_Rec.PROGRAM_TYPE_CODE ,
          X_PROGRAM_SUBTYPE_CODE	=>l_mr_header_Rec.PROGRAM_SUBTYPE_CODE,
          X_EFFECTIVE_FROM		=>l_date,
          X_EFFECTIVE_TO		=>NULL,
          X_REVISION			=>l_mr_header_Rec.REVISION,
          X_ATTRIBUTE_CATEGORY		=>l_mr_header_Rec.ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1			=>l_mr_header_Rec.ATTRIBUTE1,
          X_ATTRIBUTE2			=>l_mr_header_Rec.ATTRIBUTE2,
          X_ATTRIBUTE3			=>l_mr_header_Rec.ATTRIBUTE3,
          X_ATTRIBUTE4			=>l_mr_header_Rec.ATTRIBUTE4,
          X_ATTRIBUTE5			=>l_mr_header_Rec.ATTRIBUTE5,
          X_ATTRIBUTE6			=>l_mr_header_Rec.ATTRIBUTE6,
          X_ATTRIBUTE7			=>l_mr_header_Rec.ATTRIBUTE7,
          X_ATTRIBUTE8			=>l_mr_header_Rec.ATTRIBUTE8,
          X_ATTRIBUTE9			=>l_mr_header_Rec.ATTRIBUTE9,
          X_ATTRIBUTE10			=>l_mr_header_Rec.ATTRIBUTE10,
          X_ATTRIBUTE11			=>l_mr_header_Rec.ATTRIBUTE11,
          X_ATTRIBUTE12			=>l_mr_header_Rec.ATTRIBUTE12,
          X_ATTRIBUTE13			=>l_mr_header_Rec.ATTRIBUTE13,
          X_ATTRIBUTE14			=>l_mr_header_Rec.ATTRIBUTE14,
          X_ATTRIBUTE15			=>l_mr_header_Rec.ATTRIBUTE15,
          X_TITLE			=>l_mr_header_Rec.TITLE,
          X_VERSION_NUMBER		=>l_version_number,
          X_PRECEDING_MR_HEADER_ID=>l_mr_header_Rec.PRECEDING_MR_HEADER_ID,
          X_SERVICE_REQUEST_TEMPLATE_ID=>l_mr_header_Rec.SERVICE_REQUEST_TEMPLATE_ID,
          X_TYPE_CODE			=>l_mr_header_Rec.TYPE_CODE,
          X_DOWN_TIME			=>l_mr_header_Rec.DOWN_TIME,
          X_UOM_CODE			=>l_mr_header_Rec.UOM_CODE,
          X_DESCRIPTION			=>l_mr_header_Rec.DESCRIPTION,
          X_COMMENTS			=>l_mr_header_Rec.COMMENTS,
          X_SPACE_CATEGORY_CODE         =>l_mr_header_Rec.SPACE_CATEGORY_CODE,
          X_QA_INSPECTION_TYPE_CODE     =>l_mr_header_Rec.QA_INSPECTION_TYPE_CODE,
          X_BILLING_ITEM_ID             =>l_mr_header_Rec.BILLING_ITEM_ID,
          X_AUTO_SIGNOFF_FLAG            =>l_mr_header_Rec.AUTO_SIGNOFF_FLAG,
          -- defaulting to Yes for these attributes when new revision is created
          X_COPY_INIT_ACCOMPL_FLAG              =>'Y',
          X_COPY_DEFERRALS_FLAG                 =>'Y',
          X_CREATION_DATE		=>sysdate,
          X_CREATED_BY			=>fnd_global.user_id,
          X_LAST_UPDATE_DATE		=>sysdate,
          X_LAST_UPDATED_BY		=>fnd_global.user_id,
          X_LAST_UPDATE_LOGIN		=>fnd_global.user_id);
        end loop;


        for l_association_rec in  CurGetDocTitledet
        loop

            SELECT AHL_DOC_TITLE_ASSOS_B_S.Nextval INTO
                   l_doc_title_asso_id from DUAL;


        AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW(
                X_ROWID                         =>l_row_id,
                X_DOC_TITLE_ASSO_ID             =>l_doc_title_asso_id,
                X_SERIAL_NO                     =>l_association_rec.serial_no,
                X_ATTRIBUTE_CATEGORY            =>l_association_rec.attribute_category,
                X_ATTRIBUTE1                    =>l_association_rec.attribute1,
                X_ATTRIBUTE2                    =>l_association_rec.attribute2,
                X_ATTRIBUTE3                    =>l_association_rec.attribute3,
                X_ATTRIBUTE4                    =>l_association_rec.attribute4,
                X_ATTRIBUTE5                    =>l_association_rec.attribute5,
                X_ATTRIBUTE6                    =>l_association_rec.attribute6,
                X_ATTRIBUTE7                    =>l_association_rec.attribute7,
                X_ATTRIBUTE8                    =>l_association_rec.attribute8,
                X_ATTRIBUTE9                    =>l_association_rec.attribute9,
                X_ATTRIBUTE10                   =>l_association_rec.attribute10,
                X_ATTRIBUTE11                   =>l_association_rec.attribute11,
                X_ATTRIBUTE12                   =>l_association_rec.attribute12,
                X_ATTRIBUTE13                   =>l_association_rec.attribute13,
                X_ATTRIBUTE14                   =>l_association_rec.attribute14,
                X_ATTRIBUTE15                   =>l_association_rec.attribute15,
                X_ASO_OBJECT_TYPE_CODE          =>l_association_rec.aso_object_type_code,
                X_SOURCE_REF_CODE               =>l_association_rec.source_ref_code,
                X_ASO_OBJECT_ID                 =>x_new_mr_header_id,
                X_DOCUMENT_ID                   =>l_association_rec.document_id,
                X_USE_LATEST_REV_FLAG           =>l_association_rec.use_latest_rev_flag,
                X_DOC_REVISION_ID               =>l_association_rec.doc_revision_id,
                X_OBJECT_VERSION_NUMBER         =>1,
                X_CHAPTER                       =>l_association_rec.chapter,
                X_SECTION                       =>l_association_rec.section,
                X_SUBJECT                       =>l_association_rec.subject,
                X_FIGURE                        =>l_association_rec.figure,
                X_PAGE                          =>l_association_rec.page,
                X_NOTE                          =>l_association_rec.note,
                X_CREATION_DATE                 =>sysdate,
                X_CREATED_BY                    =>fnd_global.user_id,
                X_LAST_UPDATE_DATE              =>sysdate,
                X_LAST_UPDATED_BY               =>fnd_global.user_id,
                X_LAST_UPDATE_LOGIN             => fnd_global.login_id);

        end loop;

        for l_mr_route_rec in  CurGetRoutedet
        loop


        l_old_mr_route_id:=l_mr_route_Rec.mr_route_id;

            AHL_MR_ROUTES_PKG.INSERT_ROW (
		X_MR_ROUTE_ID		=>l_new_mr_ROUTE_ID,
		X_STAGE			=>l_mr_route_rec.STAGE,
		X_OBJECT_VERSION_NUMBER =>1,
                X_MR_HEADER_ID          =>x_new_mr_header_id,
                X_ROUTE_ID              =>l_mr_route_Rec.ROUTE_ID,
		X_ATTRIBUTE_CATEGORY	=>l_mr_route_Rec.ATTRIBUTE_CATEGORY,
		X_ATTRIBUTE1		=>l_mr_route_Rec.ATTRIBUTE1,
		X_ATTRIBUTE2		=>l_mr_route_Rec.ATTRIBUTE2,
		X_ATTRIBUTE3		=>l_mr_route_Rec.ATTRIBUTE3,
		X_ATTRIBUTE4		=>l_mr_route_Rec.ATTRIBUTE4,
		X_ATTRIBUTE5		=>l_mr_route_Rec.ATTRIBUTE5,
		X_ATTRIBUTE6		=>l_mr_route_Rec.ATTRIBUTE6,
		X_ATTRIBUTE7		=>l_mr_route_Rec.ATTRIBUTE7,
		X_ATTRIBUTE8		=>l_mr_route_Rec.ATTRIBUTE8,
		X_ATTRIBUTE9		=>l_mr_route_Rec.ATTRIBUTE9,
		X_ATTRIBUTE10		=>l_mr_route_Rec.ATTRIBUTE11,
		X_ATTRIBUTE11		=>l_mr_route_Rec.ATTRIBUTE12,
		X_ATTRIBUTE12		=>l_mr_route_Rec.ATTRIBUTE13,
		X_ATTRIBUTE13		=>l_mr_route_Rec.ATTRIBUTE14,
		X_ATTRIBUTE14		=>l_mr_route_Rec.ATTRIBUTE15,
		X_ATTRIBUTE15		=>l_mr_route_Rec.ATTRIBUTE15,
		X_CREATION_DATE		=>sysdate,
		X_CREATED_BY		=>fnd_global.user_id,
		X_LAST_UPDATE_DATE	=>sysdate,
		X_LAST_UPDATED_BY	=>fnd_global.user_id,
		X_LAST_UPDATE_LOGIN	=>fnd_global.user_id);
                L_MR_ROUTE_INDEX:=L_MR_ROUTE_INDEX+1;
                l_temp_mr_route_tbl(L_MR_ROUTE_INDEX).OLD_MR_ROUTE_ID:=l_old_mr_route_id;
                l_temp_mr_route_tbl(L_MR_ROUTE_INDEX).NEW_MR_ROUTE_ID:=l_new_mr_ROUTE_ID;
        End loop;


-- Route Sequences

       FOR I IN l_temp_mr_route_tbl.FIRST.. l_temp_mr_route_tbl.LAST
       LOOP

       OPEN  CurGetRouteSeqDet(l_temp_mr_route_tbl(I).OLD_MR_ROUTE_ID);
       loop

                FETCH CurGetRouteSeqDet INTO l_mr_route_seq_rec;
                EXIT WHEN CurGetRouteSeqDet%NOTFOUND;

                l_seq_mr_route_id       :=l_temp_mr_route_tbl(I).NEW_MR_ROUTE_ID;

                FOR J IN l_temp_mr_route_tbl.FIRST..l_temp_mr_route_tbl.LAST
                LOOP
                       IF  l_temp_mr_route_tbl(J).OLD_MR_ROUTE_ID=l_mr_route_seq_rec.related_mr_route_id
                       THEN
                        l_seq_rel_mr_route_id:=l_temp_mr_route_tbl(J).NEW_MR_ROUTE_ID;
                        EXIT WHEN l_temp_mr_route_tbl(J).OLD_MR_ROUTE_ID=l_mr_route_seq_rec.related_mr_route_id;
                       END IF;
                END LOOP;


                   AHL_MR_ROUTE_SEQUENCES_PKG.INSERT_ROW (
                                  X_MR_ROUTE_SEQUENCE_ID                =>l_new_mr_route_seq_id,
                                  X_RELATED_MR_ROUTE_ID                 =>l_seq_rel_mr_route_id,
                                  X_SEQUENCE_CODE                       =>l_mr_route_seq_rec.SEQUENCE_CODE,
                                  X_MR_ROUTE_ID                         =>l_seq_mr_route_id,
                                  X_OBJECT_VERSION_NUMBER               =>1,
                                  X_ATTRIBUTE_CATEGORY                  =>l_mr_route_seq_rec.ATTRIBUTE_CATEGORY,
                                  X_ATTRIBUTE1                          =>l_mr_route_seq_rec.ATTRIBUTE1,
                                  X_ATTRIBUTE2                          =>l_mr_route_seq_rec.ATTRIBUTE2,
                                  X_ATTRIBUTE3                          =>l_mr_route_seq_rec.ATTRIBUTE3,
                                  X_ATTRIBUTE4                          =>l_mr_route_seq_rec.ATTRIBUTE4,
                                  X_ATTRIBUTE5                          =>l_mr_route_seq_rec.ATTRIBUTE5,
                                  X_ATTRIBUTE6                          =>l_mr_route_seq_rec.ATTRIBUTE6,
                                  X_ATTRIBUTE7                          =>l_mr_route_seq_rec.ATTRIBUTE7,
                                  X_ATTRIBUTE8                          =>l_mr_route_seq_rec.ATTRIBUTE8,
                                  X_ATTRIBUTE9                          =>l_mr_route_seq_rec.ATTRIBUTE9,
                                  X_ATTRIBUTE10                         =>l_mr_route_seq_rec.ATTRIBUTE10,
                                  X_ATTRIBUTE11                         =>l_mr_route_seq_rec.ATTRIBUTE11,
                                  X_ATTRIBUTE12                         =>l_mr_route_seq_rec.ATTRIBUTE12,
                                  X_ATTRIBUTE13                         =>l_mr_route_seq_rec.ATTRIBUTE13,
                                  X_ATTRIBUTE14                         =>l_mr_route_seq_rec.ATTRIBUTE14,
                                  X_ATTRIBUTE15                         =>l_mr_route_seq_rec.ATTRIBUTE15,
                                  X_CREATION_DATE                       =>sysdate,
                                  X_CREATED_BY                          =>fnd_global.user_id,
                                  X_LAST_UPDATE_DATE                    =>sysdate,
                                  X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                                  X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
       end loop;
       CLOSE CurGetRouteSeqDet;

       END LOOP;
-- Effectivity
     for  l_mr_eff_rec in CurGetEffectDet
     loop
        l_old_mr_effectivity_id:=l_mr_eff_rec.mr_effectivity_id;

                 INSERT INTO  AHL_MR_EFFECTIVITIES
                 (
                 MR_EFFECTIVITY_ID,
                 OBJECT_VERSION_NUMBER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 MR_HEADER_ID,
                 NAME,
                 THRESHOLD_DATE,
                 INVENTORY_ITEM_ID,
                 INVENTORY_ORG_ID,
                 RELATIONSHIP_ID,
                 PC_NODE_ID,
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
                 ATTRIBUTE15
                 )
                 VALUES
                 (
                 AHL_MR_EFFECTIVITIES_S.NEXTVAL,
                 1,
                 SYSDATE,
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.user_id,
                 fnd_global.user_id,
                 x_new_mr_header_id,
                 l_mr_eff_rec.NAME,
                 l_mr_eff_rec.THRESHOLD_DATE,
                 l_mr_eff_rec.INVENTORY_ITEM_ID,
                 l_mr_eff_rec.INVENTORY_ORG_ID,
                 l_mr_eff_rec.RELATIONSHIP_ID,
                 l_mr_eff_rec.PC_NODE_ID,
                 l_mr_eff_rec.ATTRIBUTE_CATEGORY,
                 l_mr_eff_rec.ATTRIBUTE1,
                 l_mr_eff_rec.ATTRIBUTE2,
                 l_mr_eff_rec.ATTRIBUTE3,
                 l_mr_eff_rec.ATTRIBUTE4,
                 l_mr_eff_rec.ATTRIBUTE5,
                 l_mr_eff_rec.ATTRIBUTE6,
                 l_mr_eff_rec.ATTRIBUTE7,
                 l_mr_eff_rec.ATTRIBUTE8,
                 l_mr_eff_rec.ATTRIBUTE9,
                 l_mr_eff_rec.ATTRIBUTE10,
                 l_mr_eff_rec.ATTRIBUTE11,
                 l_mr_eff_rec.ATTRIBUTE12,
                 l_mr_eff_rec.ATTRIBUTE13,
                 l_mr_eff_rec.ATTRIBUTE14,
                 l_mr_eff_rec.ATTRIBUTE15
                 )
                 RETURNING mr_effectivity_id INTO l_new_mr_effectivity_id;
       OPEN  CurGetMrIntervals(l_old_mr_effectivity_id);
       LOOP

       FETCH CurGetMrIntervals into l_interval_rec;

       IF    CurGetMrIntervals%FOUND
       THEN

               l_interval_rec.OBJECT_VERSION_NUMBER:=1;

               INSERT INTO AHL_MR_INTERVALS
               (
               MR_INTERVAL_ID,
               OBJECT_VERSION_NUMBER,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN,
               MR_EFFECTIVITY_ID,
               COUNTER_ID,
               INTERVAL_VALUE,
               EARLIEST_DUE_VALUE,
               START_VALUE,
               STOP_VALUE,
               START_DATE,
	       CALC_DUEDATE_RULE_CODE, --pdoki added for ADAT ER
               STOP_DATE,
               TOLERANCE_BEFORE,
               TOLERANCE_AFTER,
               SECURITY_GROUP_ID,
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
               ATTRIBUTE15
               )
               VALUES
               (
               AHL_MR_INTERVALS_S.NEXTVAL,
               l_interval_rec.OBJECT_VERSION_NUMBER,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.user_id,
               l_new_mr_effectivity_id,
               l_interval_rec.COUNTER_ID,
               l_interval_rec.INTERVAL_VALUE,
               l_interval_rec.EARLIEST_DUE_VALUE,
               l_interval_rec.START_VALUE,
               l_interval_rec.STOP_VALUE,
               l_interval_rec.START_DATE,
	       l_interval_rec.CALC_DUEDATE_RULE_CODE, --pdoki added for ADAT ER
               l_interval_rec.STOP_DATE,
               l_interval_rec.TOLERANCE_BEFORE,
               l_interval_rec.TOLERANCE_AFTER,
               l_interval_rec.SECURITY_GROUP_ID,
               l_interval_rec.ATTRIBUTE_CATEGORY,
               l_interval_rec.ATTRIBUTE1,
               l_interval_rec.ATTRIBUTE2,
               l_interval_rec.ATTRIBUTE3,
               l_interval_rec.ATTRIBUTE4,
               l_interval_rec.ATTRIBUTE5,
               l_interval_rec.ATTRIBUTE6,
               l_interval_rec.ATTRIBUTE7,
               l_interval_rec.ATTRIBUTE8,
               l_interval_rec.ATTRIBUTE9,
               l_interval_rec.ATTRIBUTE10,
               l_interval_rec.ATTRIBUTE11,
               l_interval_rec.ATTRIBUTE12,
               l_interval_rec.ATTRIBUTE13,
               l_interval_rec.ATTRIBUTE14,
               l_interval_rec.ATTRIBUTE15
               );
       ELSE
                 EXIT WHEN CurGetMrIntervals%NOTFOUND;
       END IF;

       END LOOP;

       CLOSE CurGetMrIntervals;

       OPEN  CurGetEffectDTLS(l_old_mr_effectivity_id);
       loop
       FETCH CurGetEffectDTLS INTO l_mr_effect_dtls_rec;

       IF    CurGetEffectDTLS%FOUND
       THEN

                 INSERT INTO  AHL_MR_EFFECTIVITY_DTLS
                 (
                 MR_EFFECTIVITY_DETAIL_ID,
                 MR_EFFECTIVITY_ID,
                 EXCLUDE_FLAG,
                 MANUFACTURER_ID,
                 COUNTRY_CODE,
                 SERIAL_NUMBER_FROM,
                 SERIAL_NUMBER_TO,
                 MANUFACTURE_DATE_FROM,
                 MANUFACTURE_DATE_TO,
                 OBJECT_VERSION_NUMBER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
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
                 ATTRIBUTE15
                 )
                 VALUES
                 (
                 AHL_MR_EFFECTIVITY_DTLS_S.NEXTVAL,
                 l_new_mr_EFFECTIVITY_ID,
                 l_mr_effect_dtls_rec.EXCLUDE_FLAG,
                 l_mr_effect_dtls_rec.MANUFACTURER_ID,
                 l_mr_effect_dtls_rec.COUNTRY_CODE,
                 l_mr_effect_dtls_rec.SERIAL_NUMBER_FROM,
                 l_mr_effect_dtls_rec.SERIAL_NUMBER_TO,
                 l_mr_effect_dtls_rec.MANUFACTURE_DATE_FROM,
                 l_mr_effect_dtls_rec.MANUFACTURE_DATE_TO,
                 1,
                 SYSDATE,
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.user_id,
                 fnd_global.user_id,
                 l_mr_effect_dtls_rec.ATTRIBUTE_CATEGORY,
                 l_mr_effect_dtls_rec.ATTRIBUTE1,
                 l_mr_effect_dtls_rec.ATTRIBUTE2,
                 l_mr_effect_dtls_rec.ATTRIBUTE3,
                 l_mr_effect_dtls_rec.ATTRIBUTE4,
                 l_mr_effect_dtls_rec.ATTRIBUTE5,
                 l_mr_effect_dtls_rec.ATTRIBUTE6,
                 l_mr_effect_dtls_rec.ATTRIBUTE7,
                 l_mr_effect_dtls_rec.ATTRIBUTE8,
                 l_mr_effect_dtls_rec.ATTRIBUTE9,
                 l_mr_effect_dtls_rec.ATTRIBUTE10,
                 l_mr_effect_dtls_rec.ATTRIBUTE11,
                 l_mr_effect_dtls_rec.ATTRIBUTE12,
                 l_mr_effect_dtls_rec.ATTRIBUTE13,
                 l_mr_effect_dtls_rec.ATTRIBUTE14,
                 l_mr_effect_dtls_rec.ATTRIBUTE15
                 );
               ELSE
                 EXIT WHEN CurGetEffectDTLS%NOTFOUND;
               END IF;
           end loop;
           CLOSE CurGetEffectDTLS;

       OPEN  CurGetEffectExtDTLS(l_old_mr_effectivity_id);
       loop
       FETCH CurGetEffectExtDTLS INTO l_mr_effect_ext_dtls_rec;

       IF    CurGetEffectExtDTLS%FOUND
       THEN

                 INSERT INTO  AHL_MR_EFFECTIVITY_EXT_DTLS
                 (
                 MR_EFFECTIVITY_EXT_DTL_ID,
                 MR_EFFECTIVITY_ID,
                 EXCLUDE_FLAG,
                 EFFECT_EXT_DTL_REC_TYPE,
		 OWNER_ID,
		 LOCATION_TYPE_CODE,
		 CSI_EXT_ATTRIBUTE_CODE,
                 CSI_EXT_ATTRIBUTE_VALUE,
                 OBJECT_VERSION_NUMBER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
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
                 ATTRIBUTE15
                 )
                 VALUES
                 (
                 AHL_MR_EFFECTIVITY_EXT_DTLS_S.NEXTVAL,
                 l_new_mr_EFFECTIVITY_ID,
                 l_mr_effect_ext_dtls_rec.EXCLUDE_FLAG,
                 l_mr_effect_ext_dtls_rec.EFFECT_EXT_DTL_REC_TYPE,
                 l_mr_effect_ext_dtls_rec.OWNER_ID,
                 l_mr_effect_ext_dtls_rec.LOCATION_TYPE_CODE,
                 l_mr_effect_ext_dtls_rec.CSI_EXT_ATTRIBUTE_CODE,
                 l_mr_effect_ext_dtls_rec.CSI_EXT_ATTRIBUTE_VALUE,
                 1,
                 SYSDATE,
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.user_id,
                 fnd_global.user_id,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE_CATEGORY,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE1,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE2,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE3,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE4,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE5,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE6,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE7,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE8,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE9,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE10,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE11,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE12,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE13,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE14,
                 l_mr_effect_ext_dtls_rec.ATTRIBUTE15
                 );
               ELSE
                 EXIT WHEN CurGetEffectExtDTLS%NOTFOUND;
               END IF;
           end loop;
           CLOSE CurGetEffectExtDTLS;

    End loop;

    for l_mr_relation_rec in CurGetRelationDet
    loop

    IF l_mr_relation_Rec.MR_HEADER_ID=p_source_mr_header_id
    THEN
    -- Parent Relation
            l_rel_rec.mr_header_id         :=x_new_mr_header_id;
            l_rel_rec.RELATED_MR_HEADER_ID :=l_mr_relation_Rec.RELATED_MR_HEADER_ID;
    ELSE
    -- Child Relation
            l_rel_rec.mr_header_id         :=l_mr_relation_Rec.MR_HEADER_ID;
            l_rel_rec.related_mr_header_id :=x_new_mr_header_id;
    END IF;

    INSERT INTO AHL_MR_RELATIONSHIPS(
                MR_RELATIONSHIP_ID,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                MR_HEADER_ID,
                RELATED_MR_HEADER_ID,
                RELATIONSHIP_CODE,
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
                ATTRIBUTE15)
                values(
                AHL_MR_RELATIONSHIPS_S.NEXTVAL,
                1,
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                fnd_global.user_id,
                l_rel_Rec.MR_HEADER_ID,
                l_rel_Rec.RELATED_MR_HEADER_ID,
                l_mr_relation_Rec.RELATIONSHIP_CODE,
                l_mr_relation_Rec.ATTRIBUTE_CATEGORY,
                l_mr_relation_Rec.ATTRIBUTE1,
                l_mr_relation_Rec.ATTRIBUTE2,
                l_mr_relation_Rec.ATTRIBUTE3,
                l_mr_relation_Rec.ATTRIBUTE4,
                l_mr_relation_Rec.ATTRIBUTE5,
                l_mr_relation_Rec.ATTRIBUTE6,
                l_mr_relation_Rec.ATTRIBUTE7,
                l_mr_relation_Rec.ATTRIBUTE8,
                l_mr_relation_Rec.ATTRIBUTE9,
                l_mr_relation_Rec.ATTRIBUTE10,
                l_mr_relation_Rec.ATTRIBUTE11,
                l_mr_relation_Rec.ATTRIBUTE12,
                l_mr_relation_Rec.ATTRIBUTE13,
                l_mr_relation_Rec.ATTRIBUTE14,
                l_mr_relation_Rec.ATTRIBUTE15);
     END LOOP;
-- start visit types

    FOR l_mrvisttype_rec in CurGetMrVisitTypes
    LOOP
             INSERT INTO AHL_MR_VISIT_TYPES
                          (
                            MR_VISIT_TYPE_ID,
                            OBJECT_VERSION_NUMBER,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            MR_HEADER_ID,
                            SECURITY_GROUP_ID,
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
                            MR_VISIT_TYPE_CODE
                            )
                          VALUES
                          (
                            AHL_MR_VISIT_TYPES_S.NEXTVAL,
                            1,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            fnd_global.user_id,
                            x_new_MR_HEADER_ID,
                            l_mrvisttype_rec.SECURITY_GROUP_ID,
                            l_mrvisttype_rec.ATTRIBUTE_CATEGORY,
                            l_mrvisttype_rec.ATTRIBUTE1,
                            l_mrvisttype_rec.ATTRIBUTE2,
                            l_mrvisttype_rec.ATTRIBUTE3,
                            l_mrvisttype_rec.ATTRIBUTE4,
                            l_mrvisttype_rec.ATTRIBUTE5,
                            l_mrvisttype_rec.ATTRIBUTE6,
                            l_mrvisttype_rec.ATTRIBUTE7,
                            l_mrvisttype_rec.ATTRIBUTE8,
                            l_mrvisttype_rec.ATTRIBUTE9,
                            l_mrvisttype_rec.ATTRIBUTE10,
                            l_mrvisttype_rec.ATTRIBUTE11,
                            l_mrvisttype_rec.ATTRIBUTE12,
                            l_mrvisttype_rec.ATTRIBUTE13,
                            l_mrvisttype_rec.ATTRIBUTE14,
                            l_mrvisttype_rec.ATTRIBUTE15,
                            l_mrvisttype_rec.MR_VISIT_TYPE_CODE
                          );
    END LOOP;

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
                AHL_DEBUG_PUB.DEBUG('CREATION OF MR_REVISION  IS COMPLETE');
                AHL_DEBUG_PUB.disable_debug;
	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.DEBUG('CREATION OF MR_REVISION  IS NOT COMPLETE');
          AHL_DEBUG_PUB.disable_debug;
    END IF;


 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.DEBUG('CREATION OF MR_REVISION  IS NOT COMPLETE');
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
     ROLLBACK TO CREATE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_REVISION_PVT',
                            p_procedure_name  =>  'CREATE_MR_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.DEBUG('CREATION OF MR_REVISION  IS NOT COMPLETE');
          AHL_DEBUG_PUB.DEBUG(SQLERRM||' IN '||L_API_NAME);
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END;

PROCEDURE INITIATE_MR_APPROVAL
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id       IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprv_type                IN                 VARCHAR2:='COMPLETE'
 )
 AS
 l_counter                      NUMBER:=0;
 l_status                       VARCHAR2(30);
 l_upd_mr_status_code           VARCHAR2(30);
 l_object                       VARCHAR2(30):='FMPMR';
 l_approval_type                VARCHAR2(100):='CONCEPT';
 l_active                       VARCHAR2(50):= 'N';
 l_process_name                 VARCHAR2(50):='AHLGAPP';
 l_item_type                    VARCHAR2(50);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);
 l_activity_id                  NUMBER:=p_source_mr_header_id;
 l_Status                       VARCHAR2(1);
 l_init_msg_list                VARCHAR2(10):=FND_API.G_TRUE;
 l_object_Version_number        NUMBER:=p_object_version_number;

 Cursor GetHeaderInfo(C_MR_HEADER_ID NUMBER)
 IS
 SELECT MR_HEADER_ID,
        TITLE,
        VERSION_NUMBER,
        MR_STATUS_CODE,
        EFFECTIVE_FROM,
        EFFECTIVE_TO,
        TYPE_CODE
 FROM AHL_MR_HEADERS_APP_V
 WHERE MR_HEADER_ID=C_MR_HEADER_ID
 and object_version_number=p_object_Version_number;
 l_mr_rec       	GetHeaderInfo%ROWTYPE;

 Cursor GetHeaderInfo1(C_TITLE  VARCHAR2,C_VERSION_NUMBER NUMBER)
 IS
 SELECT MR_HEADER_ID,
        TITLE,
        VERSION_NUMBER,
        MR_STATUS_CODE,
        EFFECTIVE_FROM,
        EFFECTIVE_TO
 FROM AHL_MR_HEADERS_APP_V
 WHERE TITLE=C_TITLE
 And version_number=c_version_number-1;
 l_mr_rec1       		GetHeaderInfo1%ROWTYPE;

 l_mr_appr_enabled  		VARCHAR2(30);
 l_check_flag			VARCHAR2(1):='Y';
 l_program_id                   NUMBER;
 l_pm_activity_id               NUMBER;
 l_contract_ref_exists          VARCHAR2(1);

 l_approved_status_code VARCHAR2(30);
BEGIN
        SAVEPOINT  INITIATE_MR_APPROVAL_PVT;

       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Start Initiate_MR_Approval');
        END IF;

        IF FND_API.to_boolean(l_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;


        x_return_status := FND_API.G_RET_STS_SUCCESS;


    	l_mr_appr_enabled:=FND_PROFILE.VALUE('AHL_FMP_MR_APPRV_ENABLED');

        IF (G_APPLN_USAGE = 'PM') THEN
    		l_mr_appr_enabled:=nvl(l_mr_appr_enabled,'N');
        ELSE
    		l_mr_appr_enabled:=nvl(l_mr_appr_enabled,'Y');
        END IF;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'l_mr_appr_enabled : ' || l_mr_appr_enabled);
           AHL_DEBUG_PUB.debug( 'P_APPRV_TYPE : ' || P_APPRV_TYPE);
        END IF;

        IF p_source_mr_header_id is null or
        	p_source_mr_header_id=FND_API.G_MISS_NUM
        THEN
           	FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_INVALID');
           	FND_MSG_PUB.ADD;
		l_check_flag:='N';
        ELSE
                open  GetHeaderInfo(p_source_mr_header_id);

                fetch GetHeaderInfo into l_mr_rec;
                If    GetHeaderInfo%FOUND
                Then

                        -- If    P_APPRV_TYPE='COMPLETE'
                        If    P_APPRV_TYPE IN ('COMPLETE','COMPLETE_DCALC')
                        Then
                                l_upd_mr_status_code:='APPROVAL_PENDING';

                                IF trunc(l_mr_Rec.effective_from)<trunc(sysdate)
                                THEN
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ST_DATE_LESSER_SYSDATE');
                                   FND_MSG_PUB.ADD;
                                END IF;

                                If l_mr_rec.MR_STATUS_CODE<>'DRAFT'
				   AND l_mr_rec.MR_STATUS_CODE<>'APPROVAL_REJECTED'
                                Then
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_CANNOT_APRV');
                                   FND_MSG_PUB.ADD;
                                End if;
                        ElsIf P_APPRV_TYPE='TERMINATE'
			Then
				IF G_APPLN_USAGE='PM'
				THEN

                                IF l_mr_rec.type_code='ACTIVITY'
                                THEN
                                        l_pm_activity_id:=p_source_mr_header_id;
                                        l_program_id:=null;
                                ELSIF l_mr_rec.type_code='PROGRAM'
                                THEN
                                        l_pm_Activity_id:=null;
                                        l_program_id:=p_source_mr_header_id;
                                END IF;

                                IF G_DEBUG='Y' THEN
                                   AHL_DEBUG_PUB.debug( ' Before Call to OKS_PM_ENTITLEMENTS_PUB.Check_PM_Exists');
                                   AHL_DEBUG_PUB.debug( 'l_pm_activity_id'||l_pm_activity_id);
                                   AHL_DEBUG_PUB.debug( 'l_program_id'||l_program_id);
                                END IF;


                                OKS_PM_ENTITLEMENTS_PUB.Check_PM_Exists
                                (
                                p_api_version          =>p_api_version,
                                p_init_msg_list        =>FND_API.G_FALSE,
                                p_pm_program_id        =>l_program_id,
                                p_pm_activity_id       =>l_pm_activity_id,
                                x_return_status        =>x_return_status,
                                x_msg_count            =>x_msg_count,
                                x_msg_data             =>x_msg_data,
                                x_pm_reference_exists  =>l_contract_ref_exists
                                );

                                IF G_DEBUG='Y' THEN
                                   AHL_DEBUG_PUB.debug( 'After call to OKS_PM_ENTITLEMENTS_PUB.Check_PM_Exists');
                                END IF;


                                --l_contract_ref_exists:='Y';  -- TEMP CHECK
                                --l_contract_ref_exists:=NULL;  -- TEMP CHECK
                                --l_contract_ref_exists:=FND_API.G_MISS_CHAR;  -- TEMP CHECK

                                IF l_contract_ref_exists='Y'
                                THEN
                                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_CONTRACTS_EXIST');
                                        FND_MESSAGE.SET_TOKEN('MRTITLE',l_mr_Rec.TITLE);
                                	FND_MSG_PUB.ADD;

                                        IF G_DEBUG='Y' THEN
                                           AHL_DEBUG_PUB.debug( 'l_contract_ref_exists---->'||l_contract_ref_exists);
                                        END IF;

                                ELSIF l_contract_ref_exists IS NULL OR l_contract_ref_exists=FND_API.G_MISS_CHAR
                                THEN
                                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_INVALID_RET_PARAM');
                                	FND_MSG_PUB.ADD;

                                        IF G_DEBUG='Y' THEN
                                           AHL_DEBUG_PUB.debug( 'l_contract_ref_exists----> is either null or g_misschar'||l_contract_ref_exists);
                                        END IF;

                                END IF;



				END IF;

                                -- END OF CHECK FOR CONTRACTS EXISTING WHEN TERMINATING IN PM MODE

                                l_upd_mr_status_code:='TERMINATE_PENDING';
                                If l_mr_rec.MR_STATUS_CODE<>'COMPLETE' OR
                                (l_mr_rec.EFFECTIVE_TO IS NOT NULL
				AND l_mr_rec.EFFECTIVE_TO<>FND_API.G_MISS_DATE)
                                Then
                               		FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_CANNOT_TERMIN');
                                	FND_MSG_PUB.ADD;
                                End if;
                        End If;
       		--	If mr_header_id is invalid or not found
                ElsIf  GetHeaderInfo%NOTFOUND
                Then
                     	FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_INVALID');
                     	FND_MSG_PUB.ADD;
			l_check_flag:='N';
                End If;
                Close GetHeaderInfo;
        End If;


        -- If    P_APPRV_TYPE='COMPLETE' and l_check_flag='Y'
        If    P_APPRV_TYPE IN ('COMPLETE','COMPLETE_DCALC') and l_check_flag='Y'
        Then

                If l_mr_rec.version_number>1 and (l_mr_rec.MR_STATUS_CODE='DRAFT'
                   or l_mr_rec.MR_STATUS_CODE='APPROVAL_REJECTED')
                Then
                        Open GetHeaderInfo1(upper(l_mr_rec.TITLE),
						l_mr_rec.VERSION_NUMBER);
                        Fetch GetHeaderInfo1 Into l_mr_rec1;
                        If   GetHeaderInfo1%FOUND
                        Then
                                If trunc(l_mr_Rec.effective_from) < trunc(l_mr_Rec1.effective_from)
                                TheN
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ST_DATE_LESSER');
                                   FND_MESSAGE.SET_TOKEN('FIELD',l_mr_Rec1.effective_from);
                                   FND_MSG_PUB.ADD;
                                End If;
                        End If;
                        Close GetHeaderInfo1;
                End if;

                SELECT COUNT(*) INTO l_counter
                FROM AHL_MR_ROUTES A
                WHERE MR_HEADER_ID=l_activity_id
                AND  ROUTE_ID IN (SELECT ROUTE_ID FROM AHL_ROUTES_APP_V
                                  WHERE ROUTE_ID=A.ROUTE_id
                                  AND NVL(END_DATE_ACTIVE,SYSDATE+1)>SYSDATE
                                  AND REVISION_STATUS_CODE='COMPLETE');

                If G_APPLN_USAGE='PM' and l_mr_Rec.type_code<>'PROGRAM'
                Then
                        If l_counter=0
                        TheN
                      		FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_INIT_APPRV_ABORT');
                          	FND_MSG_PUB.ADD;
                        End If;
                ElsIf G_APPLN_USAGE<>'PM'
                Then
                        IF l_counter=0
                        Then
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_INIT_APPRV_ABORT');
                                   FND_MSG_PUB.ADD;
                        End If;
                End If;

        End If;
        /*

	If P_APPRV_TYPE='TERMINATE' and l_check_flag='Y'
	Then
                SELECT COUNT(*) INTO l_counter
                FROM AHL_MR_HEADERS_APP_V
                WHERE MR_HEADER_ID>l_activity_id
		And Title=l_mr_rec.title
		And Version_number >l_mr_rec.version_number;
                        IF l_counter>0
                        Then
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TERMIN_OLD');
                                   FND_MESSAGE.SET_TOKEN('TITLE',l_mr_Rec.TITLE);
                                   FND_MSG_PUB.ADD;
                        End If;
                        IF l_mr_rec.effective_to IS NOT NULL
                        Then
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TERMINATED');
                                   FND_MESSAGE.SET_TOKEN('TITLE',l_mr_Rec.title);
                                   FND_MSG_PUB.ADD;
                        End If;
	End if;
        */
        l_msg_count := FND_MSG_PUB.count_msg;

        If G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug( 'Check Error l_msg_count:'||l_msg_count);
	End If;

        IF l_msg_count > 0
        THEN
                X_msg_count := l_msg_count;
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

    IF(P_APPRV_TYPE = 'COMPLETE_DCALC')THEN
       l_approved_status_code := 'APPROVED_DCALC';
    ELSE
       l_approved_status_code := 'APPROVED';
    END IF;

-- Start work Flow Process
	IF (l_mr_appr_enabled = 'Y')
	THEN
        ahl_utility_pvt.get_wf_process_name(
        p_object     		=>l_object,
	p_application_usg_code 	=>g_appln_usage,
        x_active       		=>l_active,
        x_process_name 		=>l_process_name ,
        x_item_type    		=>l_item_type,
        x_return_status		=>x_return_status,
        x_msg_count    		=>l_msg_count,
        x_msg_data     		=>l_msg_data);
	END IF;

        IF  l_ACTIVE='Y'
        THEN
               UPDATE  AHL_MR_HEADERS_B
               SET MR_STATUS_CODE=l_upd_mr_status_code,
               OBJECT_VERSION_number=object_version_number+1
               WHERE MR_HEADER_ID=p_source_mr_header_id
               And OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               ELSE

               Ahl_generic_aprv_pvt.Start_Wf_Process(
                         P_OBJECT                =>l_object,
                         P_ACTIVITY_ID           =>l_activity_id,
                         P_APPROVAL_TYPE         =>'CONCEPT',
                         P_OBJECT_VERSION_NUMBER =>p_object_version_number+1,
                         P_ORIG_STATUS_CODE      =>'ACTIVE',
                         -- P_NEW_STATUS_CODE       =>'APPROVED',
                         P_NEW_STATUS_CODE       => l_approved_status_code,
                         P_REJECT_STATUS_CODE    =>'REJECTED',
                         P_REQUESTER_USERID      =>fnd_global.user_id,
                         P_NOTES_FROM_REQUESTER  =>'',
                         P_WORKFLOWPROCESS       =>'AHL_GEN_APPROVAL',
                         P_ITEM_TYPE             =>'AHLGAPP',
			 p_application_usg_code  =>G_APPLN_USAGE
			);
               END IF;
        ELSE
               UPDATE  AHL_MR_HEADERS_B
               SET MR_STATUS_CODE=L_UPD_MR_STATUS_CODE,
               OBJECT_VERSION_number=OBJECT_VERSION_number+1
               WHERE MR_HEADER_ID=p_source_mr_header_id
               AND OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF;

                AHL_FMP_MR_REVISION_PVT.COMPLETE_MR_REVISION
                 (
                 p_api_version               =>1.0,
                 p_init_msg_list             =>FND_API.G_FALSE,
                 p_commit                    =>FND_API.G_FALSE,
                 p_validation_level          =>NULL,
                 p_default                   =>NULL,
                 p_module_type               =>NULL,
                 x_return_status             =>x_return_status,
                 x_msg_count                 =>x_msg_count ,
                 x_msg_data                  =>x_msg_data  ,
                 -- p_appr_status               =>'APPROVED',
                 p_appr_status       => l_approved_status_code,
                 p_mr_header_id              =>l_activity_id,
                 p_object_version_number     =>l_object_version_number+1
                 );

        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_MR_APPROVAL_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;


 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_MR_APPROVAL_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_MR_APPROVAL_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_REVISION_PVT',
                            p_procedure_name  =>  'INITIATE_MR_APPROVAL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

END;


PROCEDURE COMPLETE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_mr_header_id              IN         NUMBER,
 p_object_version_number     IN         NUMBER
  )
 AS

 CURSOR GetMR_headerDet(C_MR_HEADER_ID NUMBER)
 IS
 SELECT MR_HEADER_ID,
        VERSION_NUMBER,
        EFFECTIVE_FROM,
        TITLE,
        MR_STATUS_CODE,
        APPLICATION_USG_CODE
 FROM AHL_MR_HEADERS_B
 WHERE MR_HEADER_ID=C_MR_HEADER_ID;

 CURSOR GetPrevMR_headerid(C_VERSION_NUMBER NUMBER,C_TITLE  VARCHAR2,C_APP_CODE VARCHAR2)
 IS
 SELECT MR_HEADER_ID,
        VERSION_NUMBER,
        EFFECTIVE_FROM,
        TITLE,
        MR_STATUS_CODE
 FROM AHL_MR_HEADERS_B
 WHERE TITLE=C_TITLE
 AND VERSION_NUMBER=C_VERSION_NUMBER-1
 AND APPLICATION_USG_CODE=C_APP_CODE;

 l_mr_rec                       GetMR_headerDet%rowtype;
 l_prev_mr_rec                  GetPrevMR_headerid%rowtype;
 l_status                       VARCHAR2(30);
 l_mr_status                    VARCHAR2(30);
 l_check_flag                   VARCHAR2(1):='N';
 l_check_flag2                  VARCHAR2(1):='N';
 l_check_flag3                  VARCHAR2(1):='Y';
 l_api_name     CONSTANT        VARCHAR2(30):='COMPLETE_MR_REVISION';
 l_api_version  CONSTANT        NUMBER       := 1.0;
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);
 l_fr_date                      DATE:=SYSDATE;
 l_to_Date                      DATE:=SYSDATE;
 l_commit                       VARCHAR2(10):=FND_API.G_TRUE;

/* Vo comments: No need to copy newer revisions of the MR to the ATA Sequences,
 *              the User will need to add them on a case-to-case basis...
-- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
l_prev_program_type             VARCHAR2(30);
l_program_type                  VARCHAR2(30);
-- Tamal [MEL/CDL RM-FMP Enhancements] Ends here...
*/

l_req_id                   number;

BEGIN

        SAVEPOINT  COMPLETE_MR_REVISION_PVT;

 	x_return_status:=FND_API.G_RET_STS_SUCCESS;
     	IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.enable_debug;
                AHL_DEBUG_PUB.debug( 'p_appr_Status'||p_appr_status);
                AHL_DEBUG_PUB.debug( 'Header Id '||p_mr_header_id);
	END IF;

     IF p_mr_header_id is not null and p_mr_header_id<>fnd_api.g_miss_num
     THEN
             OPEN GetMR_headerDet(p_mr_header_id);
             FETCH GetMR_headerDet INTO  l_mr_rec;

             IF GetMR_headerDet%NOTFOUND
             THEN
                 l_check_flag:='N';
             ELSE
                     IF p_appr_status IN ('APPROVED', 'APPROVED_DCALC')
                     THEN
                         IF l_mr_rec.mr_status_code='APPROVAL_PENDING'
                         THEN
                                 l_status:='COMPLETE';
                         ELSIF l_mr_rec.mr_status_code='TERMINATE_PENDING'
                         THEN
                                 l_status:='TERMINATED';
                         END IF;
                            l_check_flag:='Y';
                     ELSE
                         l_check_flag:='N';
                         l_status:='APPROVAL_REJECTED';
                         IF l_mr_rec.mr_status_code='TERMINATE_PENDING'
                         THEN
                                 l_status:='COMPLETE';
                         END IF;
                         l_check_flag3:='N';
                         UPDATE AHL_MR_HEADERS_B
                         SET MR_STATUS_CODE=DECODE(MR_STATUS_CODE,'APPROVAL_PENDING','APPROVAL_REJECTED','TERMINATE_PENDING','COMPLETE')
                         WHERE MR_HEADER_ID=P_MR_HEADER_ID;
                     END IF;

                IF l_mr_rec.effective_from >sysdate
                THEN
                   l_fr_date:=l_mr_rec.effective_from;
                   l_to_date:=l_mr_rec.effective_from;
                ELSE
                   l_fr_date:=sysdate;
                   l_to_date:=sysdate;
                END IF;
             END IF;

             CLOSE GetMR_headerDet;

             IF l_check_flag='Y' and l_mr_rec.version_number=1
             THEN
                     IF l_mr_rec.MR_STATUS_CODE='APPROVAL_PENDING'
                     THEN
                     UPDATE AHL_MR_HEADERS_B
                            SET MR_STATUS_CODE=l_status,
                            EFFECTIVE_FROM=L_FR_DATE,
                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE MR_HEADER_ID=P_MR_HEADER_ID;
                     ELSIF l_mr_rec.MR_STATUS_CODE='TERMINATE_PENDING'
                     THEN
                     UPDATE AHL_MR_HEADERS_B
                            SET MR_STATUS_CODE=l_status,
                            EFFECTIVE_TO=nvl(EFFECTIVE_TO,L_TO_DATE),
                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE MR_HEADER_ID=P_MR_HEADER_ID;

                     END IF;

                     IF L_MR_REC.MR_STATUS_CODE='TERMINATE_PENDING'
                     THEN
                        IF G_DEBUG='Y'
                        THEN
                                AHL_DEBUG_PUB.debug( 'l_status:'||l_status);
                                AHL_DEBUG_PUB.debug( 'Before Call to Terminate MR Instances');
                        END IF;

                        AHL_UMP_UNITMAINT_PUB.Terminate_MR_Instances(
                        p_api_version           =>l_api_version,
                        p_init_msg_list         =>FND_API.G_FALSE,
                        p_commit                =>p_commit,
                        p_validation_level      =>p_validation_level,
                        p_default               =>p_default,
                        p_module_type           =>p_module_type,
                        p_old_mr_header_id      =>l_mr_rec.MR_HEADER_ID,
                        p_old_mr_title          =>l_mr_rec.TITLE,
                        p_old_version_number    =>l_mr_rec.VERSION_NUMBER,
                        p_new_mr_header_id      =>NULL,
                        p_new_mr_title          =>NULL,
                        p_new_version_number    =>NULL,
                        x_return_status         =>x_return_Status,
                        x_msg_count             =>l_msg_count,
                        x_msg_data              =>l_msg_data);

                        IF FND_MSG_PUB.count_msg > 0
                        THEN
                        IF G_DEBUG='Y' THEN
                           AHL_DEBUG_PUB.debug( 'Terminate inst fail');
                        END IF;

                        END IF;

                     END IF;



                     l_check_flag:='Y';

                     l_check_flag2:='Y';

             ELSIF l_check_flag='Y' and l_mr_rec.version_number>1
             THEN
             AHL_DEBUG_PUB.debug( ' For version_number >1');

                     OPEN GetPrevMR_headerid(l_mr_rec.version_number,
                                             l_mr_rec.title,
                                             l_mr_rec.application_usg_code);

                     FETCH GetPrevMR_headerid INTO  l_prev_mr_rec;

                     IF GetPrevMR_headerid%NOTFOUND
                     THEN
                         l_check_flag2:='N';
                     ELSE
                        l_check_flag2:='Y';
                     END IF;

                     CLOSE GetPrevMR_headerid;

                     IF l_check_flag2='Y'
                     THEN

                             IF l_mr_rec.MR_STATUS_CODE='APPROVAL_PENDING'
                             THEN
                             UPDATE AHL_MR_HEADERS_B
                                    SET MR_STATUS_CODE=l_status,
                                    EFFECTIVE_FROM=L_FR_DATE,
                             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                             WHERE MR_HEADER_ID=P_MR_HEADER_ID;

                             UPDATE AHL_MR_HEADERS_B
                                    SET EFFECTIVE_TO=L_TO_DATE,
                             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                             WHERE MR_HEADER_ID=l_prev_mr_rec.MR_HEADER_ID;

                            /* Vo comments: No need to copy newer revisions of the MR to the ATA Sequences,
                             *              the User will need to add them on a case-to-case basis...

                            -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...

                            -- Verify whether both old  revisions of the MR are M  Procedures...
                            SELECT  program_type_code
                            INTO    l_prev_program_type
                            FROM    ahl_mr_headers_app_v
                            WHERE   mr_header_id = l_prev_mr_rec.MR_HEADER_ID;

                            SELECT  program_type_code
                            INTO    l_program_type
                            FROM    ahl_mr_headers_app_v
                            WHERE   mr_header_id = P_MR_HEADER_ID;

                            -- If old revision of the MO_PROC is being made inactive, need to associated the new revision to ATA Sequences too
                            IF (l_prev_program_type = 'MO_PROC' AND l_program_type = 'MO_PROC')
                            THEN
                                AHL_MEL_CDL_ATA_SEQS_PVT.Copy_MO_Proc_Revision
                                (
                                    -- Standard IN params
                                    p_api_version           => 1.0,
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_commit                => FND_API.G_FALSE,
                                    p_validation_level      => p_validation_level,
                                    p_default               => p_default,
                                    p_module_type           => p_module_type,
                                    -- Standard OUT params
                                    x_return_status         => x_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data,
                                    -- Procedure IN, OUT, IN/OUT params
                                    p_old_mr_header_id      => l_prev_mr_rec.MR_HEADER_ID,
                                    p_new_mr_header_id      => P_MR_HEADER_ID
                                );
                            END IF;
                            -- Tamal [MEL/CDL RM-FMP Enhancements] Ends here...

                            */

                             ELSIF l_mr_rec.MR_STATUS_CODE='TERMINATE_PENDING'
                             THEN
                             UPDATE AHL_MR_HEADERS_B
                                    SET MR_STATUS_CODE=l_status,
                                    EFFECTIVE_TO=NVL(EFFECTIVE_TO,l_to_date),
                             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                             WHERE MR_HEADER_ID=P_MR_HEADER_ID;
                             END IF;

		        IF l_check_flag3='Y'
                        THEN
                                IF l_check_flag2='Y'  AND l_check_flag='Y'
                                THEN

                                      IF FND_MSG_PUB.count_msg > 0
                                      THEN
                                            IF G_DEBUG='Y' THEN
                                                AHL_DEBUG_PUB.debug( 'Error Before TerminateInstances');
                                            END IF;
                                            X_msg_count := l_msg_count;
                                            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                            RAISE FND_API.G_EXC_ERROR;
                                      END IF;

                                IF G_DEBUG='Y'
                                THEN
                                        AHL_DEBUG_PUB.debug( 'l_status:'||l_status);
                                END IF;

                                IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
				THEN

                        IF(TRUNC(NVL(l_to_date,SYSDATE)) > TRUNC(SYSDATE) )THEN
                                UPDATE AHL_MR_HEADERS_B
                                SET TERMINATION_REQUIRED_FLAG = 'Y'
                                WHERE MR_HEADER_ID=l_prev_mr_rec.MR_HEADER_ID;

                                AHL_UMP_UNITMAINT_PUB.Terminate_MR_Instances(
                                p_api_version         	=>l_api_version,
                                p_init_msg_list         =>FND_API.G_FALSE,
                                p_commit              	=>p_commit,
                                p_validation_level    	=>p_validation_level,
                                p_default             	=>p_default,
                                p_module_type         	=>p_module_type,
                                p_old_mr_header_id    	=>l_prev_mr_rec.MR_HEADER_ID,
                                p_old_mr_title        	=>l_prev_mr_rec.TITLE,
                                p_old_version_number	=>l_prev_mr_rec.VERSION_NUMBER,
                                p_new_mr_header_id    	=>NULL,
                                p_new_mr_title        	=>NULL,
                                p_new_version_number  	=>NULL,
                                x_return_status       	=>x_return_Status,
                                x_msg_count           	=>l_msg_count,
                                x_msg_data            	=>l_msg_data);
                        ELSE

                                AHL_UMP_UNITMAINT_PUB.Terminate_MR_Instances(
                                p_api_version         	=>l_api_version,
                                p_init_msg_list         =>FND_API.G_FALSE,
                                p_commit              	=>p_commit,
                                p_validation_level    	=>p_validation_level,
                                p_default             	=>p_default,
                                p_module_type         	=>p_module_type,
                                p_old_mr_header_id    	=>l_prev_mr_rec.MR_HEADER_ID,
                                p_old_mr_title        	=>l_prev_mr_rec.TITLE,
                                p_old_version_number	=>l_prev_mr_rec.VERSION_NUMBER,
                                p_new_mr_header_id    	=>l_mr_rec.MR_HEADER_ID,
                                p_new_mr_title        	=>l_mr_rec.TITLE,
                                p_new_version_number  	=>l_mr_rec.VERSION_NUMBER,
                                x_return_status       	=>x_return_Status,
                                x_msg_count           	=>l_msg_count,
                                x_msg_data            	=>l_msg_data);
                        END IF;
                         ELSIF L_MR_REC.MR_STATUS_CODE='TERMINATE_PENDING'
				THEN
                                AHL_UMP_UNITMAINT_PUB.Terminate_MR_Instances(
                                p_api_version         	=>l_api_version,
                                p_init_msg_list         =>FND_API.G_FALSE,
                                p_commit              	=>p_commit,
                                p_validation_level    	=>p_validation_level,
                                p_default             	=>p_default,
                                p_module_type         	=>p_module_type,
                                p_old_mr_header_id    	=>l_mr_rec.MR_HEADER_ID,
                                p_old_mr_title        	=>l_mr_rec.TITLE,
                                p_old_version_number	=>l_mr_rec.VERSION_NUMBER,
                                p_new_mr_header_id    	=>NULL,
                                p_new_mr_title        	=>NULL,
                                p_new_version_number  	=>null,
                                x_return_status       	=>x_return_Status,
                                x_msg_count           	=>l_msg_count,
                                x_msg_data            	=>l_msg_data);

                                END IF;
                                END IF;

                                IF FND_MSG_PUB.count_msg > 0
				THEN

				IF G_DEBUG='Y' THEN
                                   AHL_DEBUG_PUB.debug( 'Terminate inst fail');
				END IF;

                                END IF;
                        END IF;
                  END IF;
             END IF;
      END IF;

      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0
      THEN
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Failed To Complete:');
	END IF;
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF p_appr_status = 'APPROVED_DCALC' THEN
      l_req_id := fnd_request.submit_request('AHL','AHLWUEFF',NULL,NULL,FALSE,
                                         l_prev_mr_rec.MR_HEADER_ID, l_mr_rec.MR_HEADER_ID);
      IF (l_req_id = 0 OR l_req_id IS NULL) THEN
        IF G_debug = 'Y' THEN
          AHL_DEBUG_PUB.debug('Tried to submit concurrent request but failed');
        END IF;
      ELSE
        IF G_debug = 'Y' THEN
          AHL_DEBUG_PUB.debug('submit concurrent request : ' || l_req_id);
        END IF;
      END IF;
    END IF;

    IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug( 'Before commit Complete_mr_revision ');
	END IF;

      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT;
      END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COMPLETE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COMPLETE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO COMPLETE_MR_REVISION_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_REVISION_PVT',
                            p_procedure_name  =>  'COMPLETE_MR_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END;

PROCEDURE VALIDATE_MR_REVISION
 (
 p_api_version               IN                 NUMBER:=1.0,
 p_init_msg_list             IN                 VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN                 VARCHAR2:=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN                 VARCHAR2:=FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_mr_header_id       IN         NUMBER,
 p_object_version_number        IN      NUMBER
 )
 AS
 l_counter1                 NUMBER:=0;
 l_counter2                 NUMBER:=0;
 l_appln_code           VARCHAR2(30);
BEGIN

 SAVEPOINT VALIDATE_MR_REVISION;

        IF G_APPLN_USAGE IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;


 x_return_status:=FND_API.G_RET_STS_SUCCESS;

 SELECT count(*) into l_counter1
 FROM AHL_MR_HEADERS_APP_V
 Where mr_header_id=p_source_mr_header_id;

 IF l_counter1=0
 THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_MR_HEADER_ID_INVALID');
      FND_MSG_PUB.ADD;
 END IF;

 SELECT count(*) into l_counter2
 FROM AHL_MR_HEADERS_APP_V
 Where mr_header_id=p_source_mr_header_id
 And   mr_status_code='DRAFT' or  mr_status_code='APPROVAL_REJECTED';

 IF l_counter2=0
 THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
 END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_MR_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_MR_REVISION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_MR_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        => G_PKG_NAME ,
                            p_procedure_name  => 'VALIDATE_MR_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
END;
END AHL_FMP_MR_REVISION_PVT;

/
