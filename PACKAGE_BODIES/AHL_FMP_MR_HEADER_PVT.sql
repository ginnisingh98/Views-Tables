--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_HEADER_PVT" AS
/* $Header: AHLVMRHB.pls 120.4.12010000.2 2008/12/29 01:01:46 sracha ship $ */

G_PKG_NAME    VARCHAR2(30):='AHL_FMP_MR_HEADER_PVT';
G_APPLN_USAGE VARCHAR2(30):=RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));
G_DEBUG       VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_mr_header_rec              IN OUT NOCOPY AHL_FMP_MR_HEADER_PVT.MR_HEADER_REC)
AS
        CURSOR CurHeaderDet(c_mr_header_id NUMBER) IS
        SELECT MR_HEADER_ID,
                       OBJECT_VERSION_NUMBER,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                        TITLE,
                        VERSION_NUMBER,
                        PRECEDING_MR_HEADER_ID,
                        PRECEDING_MR_TITLE,
                        PRECEDING_MR_REVISION,
                        CATEGORY_CODE,
                        CATEGORY,
                        SERVICE_TYPE_CODE,
                        SERVICE_TYPE,
                        MR_STATUS_CODE,
                        STATUS,
                        IMPLEMENT_STATUS_CODE,
                        IMPLEMENT_STATUS,
                        REPETITIVE_FLAG,
                        REPETITIVE,
                        SHOW_REPETITIVE_CODE,
                        SHOW_REPETITIVE,
                        WHICHEVER_FIRST_CODE,
                        WHICHEVER_FIRST,
                        COPY_ACCOMPLISHMENT_FLAG,
                        COPY_ACCOMPLISHMENT,
                        PROGRAM_TYPE_CODE,
                        PROGRAM_TYPE,
                        PROGRAM_SUBTYPE_CODE,
                        PROGRAM_SUBTYPE,
                        EFFECTIVE_FROM,
                        EFFECTIVE_TO,
                        REVISION,
                        DESCRIPTION,
                        COMMENTS,
                        SERVICE_REQUEST_TEMPLATE_ID,
                        TYPE_CODE,
                        TYPE,
                        DOWN_TIME,
                        UOM_CODE,
                        UOM,
                        SPACE_CATEGORY_CODE,
                        SPACE_CATEGORY,
                        BILLING_ITEM_ID,
                        BILLING_ORG_ID,
                        BILLING_ITEM,
                        QA_INSPECTION_TYPE_CODE,
                        QA_INSPECTION_TYPE,
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
                        APPLICATION_USG_CODE,
                        AUTO_SIGNOFF_FLAG,
                        COPY_INIT_ACCOMPL_FLAG,
                        COPY_DEFERRALS_FLAG
        FROM AHL_MR_HEADERS_V
        WHERE MR_HEADER_ID=c_mr_header_id;

        l_MR_header_rec    CurHeaderDet%ROWTYPE;
BEGIN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
        END IF;

        OPEN CurHeaderDet(p_x_mr_header_rec.mr_header_id);
        FETCH CurHeaderDet INTO l_mr_header_rec;
        CLOSE CurHeaderDet;

        IF p_x_mr_header_rec.OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
        THEN
            p_x_mr_header_rec.OBJECT_VERSION_NUMBER:=NULL;
        ELSE
            p_x_mr_header_rec.OBJECT_VERSION_NUMBER:=l_mr_header_rec.OBJECT_VERSION_NUMBER;
        END IF;

        IF p_x_mr_header_rec.TITLE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.TITLE:=NULL;
        ELSIF p_x_mr_header_rec.TITLE IS NULL
        THEN
                p_x_mr_header_rec.TITLE:=l_mr_header_rec.TITLE;
        END IF;

        IF p_x_mr_header_rec.REVISION= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.REVISION:=NULL;
        ELSIF p_x_mr_header_rec.REVISION IS NULL
        THEN
                p_x_mr_header_rec.REVISION:=l_mr_header_Rec.REVISION;
        END IF;
        IF p_x_mr_header_rec.VERSION_NUMBER= FND_API.G_MISS_NUM
        THEN
                p_x_mr_header_rec.VERSION_NUMBER:=NULL;
        ELSIF p_x_mr_header_rec.VERSION_NUMBER IS NULL
        THEN
                p_x_mr_header_rec.VERSION_NUMBER:=l_mr_header_Rec.VERSION_NUMBER;
        END IF;

        IF p_x_mr_header_rec.CATEGORY_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.CATEGORY_CODE:=NULL;
        ELSIF p_x_mr_header_rec.CATEGORY_CODE IS NULL
        THEN
                p_x_mr_header_rec.CATEGORY_CODE
                        :=l_mr_header_Rec.CATEGORY_CODE;
        END IF;
        IF p_x_mr_header_rec.CATEGORY= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.CATEGORY:=NULL;
        ELSIF p_x_mr_header_rec.CATEGORY IS NULL
        THEN
                p_x_mr_header_rec.CATEGORY
                        :=l_mr_header_Rec.CATEGORY;
        END IF;

        IF p_x_mr_header_rec.PROGRAM_TYPE_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.PROGRAM_TYPE_CODE:=NULL;
        ELSIF p_x_mr_header_rec.PROGRAM_TYPE_CODE IS NULL
        THEN
                p_x_mr_header_rec.PROGRAM_TYPE_CODE
                        :=l_mr_header_Rec.PROGRAM_TYPE_CODE;
        END IF;
        IF p_x_mr_header_rec.PROGRAM_TYPE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.PROGRAM_TYPE:=NULL;
        ELSIF p_x_mr_header_rec.PROGRAM_TYPE IS NULL
        THEN
                p_x_mr_header_rec.PROGRAM_TYPE
                        :=l_mr_header_Rec.PROGRAM_TYPE;
        END IF;

        IF p_x_mr_header_rec.PROGRAM_SUBTYPE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.PROGRAM_SUBTYPE:=NULL;
        ELSIF p_x_mr_header_rec.PROGRAM_SUBTYPE IS NULL
        THEN
                p_x_mr_header_rec.PROGRAM_SUBTYPE:=
                                l_mr_header_Rec.PROGRAM_SUBTYPE;
        END IF;

        IF p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=NULL;
        ELSIF p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE IS NULL
        THEN
            p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=l_mr_header_Rec.PROGRAM_SUBTYPE_CODE;
        END IF;


        IF p_x_mr_header_rec.SERVICE_TYPE_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.SERVICE_TYPE_CODE:=NULL;
        ELSIF p_x_mr_header_rec.SERVICE_TYPE_CODE IS NULL
        THEN
                p_x_mr_header_rec.SERVICE_TYPE_CODE:=l_mr_header_Rec.SERVICE_TYPE_CODE;
        END IF;
        IF p_x_mr_header_rec.SERVICE_TYPE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.SERVICE_TYPE:=NULL;
        ELSIF p_x_mr_header_rec.SERVICE_TYPE IS NULL
        THEN
                p_x_mr_header_rec.SERVICE_TYPE:=l_mr_header_Rec.SERVICE_TYPE;
        END IF;

        IF p_x_mr_header_rec.MR_STATUS_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.MR_STATUS_CODE:=NULL;
        ELSIF p_x_mr_header_rec.MR_STATUS_CODE IS NULL
        THEN
                p_x_mr_header_rec.MR_STATUS_CODE:=l_mr_header_Rec.MR_STATUS_CODE;
        END IF;
        IF p_x_mr_header_rec.IMPLEMENT_STATUS_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.IMPLEMENT_STATUS_CODE:=NULL;
        ELSIF p_x_mr_header_rec.IMPLEMENT_STATUS_CODE IS NULL
        THEN
                p_x_mr_header_rec.IMPLEMENT_STATUS_CODE:=l_mr_header_Rec.IMPLEMENT_STATUS_CODE;
        END IF;
        IF p_x_mr_header_rec.IMPLEMENT_STATUS= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.IMPLEMENT_STATUS:=NULL;
        ELSIF p_x_mr_header_rec.IMPLEMENT_STATUS IS NULL
        THEN
                p_x_mr_header_rec.IMPLEMENT_STATUS
                        :=l_mr_header_Rec.IMPLEMENT_STATUS;
        END IF;
        IF p_x_mr_header_rec.EFFECTIVE_FROM=FND_API.G_MISS_DATE
        THEN
                p_x_mr_header_rec.EFFECTIVE_FROM:=NULL;
        ELSIF p_x_mr_header_rec.EFFECTIVE_FROM IS NULL
        THEN
                p_x_mr_header_rec.EFFECTIVE_FROM:=l_mr_header_Rec.EFFECTIVE_FROM;
        END IF;
        IF p_x_mr_header_rec.EFFECTIVE_TO=FND_API.G_MISS_DATE
        THEN
                p_x_mr_header_rec.EFFECTIVE_TO:=NULL;
        ELSIF p_x_mr_header_rec.EFFECTIVE_TO IS NULL
        THEN
                p_x_mr_header_rec.EFFECTIVE_TO:=l_mr_header_Rec.EFFECTIVE_TO;
        END IF;
        IF p_x_mr_header_rec.REPETITIVE_FLAG= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.REPETITIVE_FLAG:=NULL;
        ELSIF p_x_mr_header_rec.REPETITIVE_FLAG IS NULL
        THEN
                p_x_mr_header_rec.REPETITIVE_FLAG:=l_mr_header_Rec.REPETITIVE_FLAG;
        END IF;
        IF p_x_mr_header_rec.REPETITIVE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.REPETITIVE:=NULL;
        ELSIF p_x_mr_header_rec.REPETITIVE IS NULL
        THEN
                p_x_mr_header_rec.REPETITIVE:=l_mr_header_Rec.REPETITIVE;
        END IF;

        IF p_x_mr_header_rec.SHOW_REPETITIVE_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.SHOW_REPETITIVE_CODE:=NULL;
        ELSIF p_x_mr_header_rec.SHOW_REPETITIVE_CODE IS NULL
        THEN
                p_x_mr_header_rec.SHOW_REPETITIVE_CODE:=l_mr_header_Rec.SHOW_REPETITIVE_CODE;
        END IF;

        IF p_x_mr_header_rec.SHOW_REPETITIVE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.SHOW_REPETITIVE:=NULL;
        ELSIF p_x_mr_header_rec.SHOW_REPETITIVE IS NULL
        THEN
                p_x_mr_header_rec.SHOW_REPETITIVE:=l_mr_header_Rec.SHOW_REPETITIVE;
        END IF;
        IF p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG:=NULL;
        ELSIF p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG IS NULL
        THEN
                p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG:=l_mr_header_Rec.COPY_ACCOMPLISHMENT_FLAG;
        END IF;

        IF p_x_mr_header_rec.COPY_ACCOMPLISHMENT= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.COPY_ACCOMPLISHMENT:=NULL;
        ELSIF p_x_mr_header_rec.COPY_ACCOMPLISHMENT IS NULL
        THEN
                p_x_mr_header_rec.COPY_ACCOMPLISHMENT:=l_mr_header_Rec.COPY_ACCOMPLISHMENT;
        END IF;

        IF p_x_mr_header_rec.WHICHEVER_FIRST_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.WHICHEVER_FIRST_CODE:=NULL;
        ELSIF p_x_mr_header_rec.WHICHEVER_FIRST_CODE IS NULL
        THEN
                p_x_mr_header_rec.WHICHEVER_FIRST_CODE:=l_mr_header_Rec.WHICHEVER_FIRST_CODE;
        END IF;

        IF p_x_mr_header_rec.WHICHEVER_FIRST= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.WHICHEVER_FIRST:=NULL;
        ELSIF p_x_mr_header_rec.WHICHEVER_FIRST IS NULL
        THEN
                p_x_mr_header_rec.WHICHEVER_FIRST:=l_mr_header_Rec.WHICHEVER_FIRST;
        END IF;

        IF p_x_mr_header_rec.PRECEDING_MR_HEADER_ID= FND_API.G_MISS_NUM
        THEN
                p_x_mr_header_rec.PRECEDING_MR_HEADER_ID:=NULL;
        ELSIF p_x_mr_header_rec.PRECEDING_MR_HEADER_ID IS NULL
        THEN
                p_x_mr_header_rec.PRECEDING_MR_HEADER_ID:=l_mr_header_Rec.PRECEDING_MR_HEADER_ID;
        END IF;

        IF p_x_mr_header_rec.PRECEDING_MR_TITLE= FND_API.G_MISS_CHAR
        THEN
        p_x_mr_header_rec.PRECEDING_MR_TITLE:=NULL;
        ELSIF p_x_mr_header_rec.PRECEDING_MR_TITLE IS NULL
        THEN
        p_x_mr_header_rec.PRECEDING_MR_TITLE:=l_mr_header_Rec.PRECEDING_MR_TITLE;
        END IF;

        IF p_x_mr_header_rec.PRECEDING_MR_REVISION= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.PRECEDING_MR_REVISION:=NULL;
        ELSIF p_x_mr_header_rec.PRECEDING_MR_REVISION IS NULL
        THEN
                p_x_mr_header_rec.PRECEDING_MR_REVISION:=l_mr_header_Rec.PRECEDING_MR_REVISION;
        END IF;

        IF p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID= FND_API.G_MISS_NUM
        THEN
                p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID:=NULL;
        ELSIF p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID IS NULL
        THEN
                p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID:=l_mr_header_Rec.SERVICE_REQUEST_TEMPLATE_ID;
        END IF;

        IF p_x_mr_header_rec.DOWN_TIME= FND_API.G_MISS_NUM
        THEN
                p_x_mr_header_rec.DOWN_TIME:=NULL;
        ELSIF p_x_mr_header_rec.DOWN_TIME IS NULL
        THEN
                p_x_mr_header_rec.DOWN_TIME:=l_mr_header_Rec.DOWN_TIME;
        END IF;

        IF p_x_mr_header_rec.TYPE_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.TYPE_CODE:=NULL;
        ELSIF p_x_mr_header_rec.TYPE_CODE IS NULL
        THEN
                p_x_mr_header_rec.TYPE_CODE:=l_mr_header_Rec.TYPE_CODE;
        END IF;

        IF p_x_mr_header_rec.AUTO_SIGNOFF_FLAG= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.AUTO_SIGNOFF_FLAG:=NULL;
        ELSIF p_x_mr_header_rec.AUTO_SIGNOFF_FLAG IS NULL
        THEN
                p_x_mr_header_rec.AUTO_SIGNOFF_FLAG:=l_mr_header_Rec.AUTO_SIGNOFF_FLAG;
        END IF;

        IF p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG= FND_API.G_MISS_CHAR
        THEN
               p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG:=NULL;
        ELSIF p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG IS NULL
        THEN
               p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG:=l_mr_header_Rec.COPY_INIT_ACCOMPL_FLAG;
        END IF;

       IF p_x_mr_header_rec.COPY_DEFERRALS_FLAG= FND_API.G_MISS_CHAR
       THEN
               p_x_mr_header_rec.COPY_DEFERRALS_FLAG:=NULL;
       ELSIF p_x_mr_header_rec.COPY_DEFERRALS_FLAG IS NULL
       THEN
               p_x_mr_header_rec.COPY_DEFERRALS_FLAG:=l_mr_header_Rec.COPY_DEFERRALS_FLAG;
        END IF;

        IF p_x_mr_header_rec.UOM_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.UOM_CODE:=NULL;
        ELSIF p_x_mr_header_rec.UOM_CODE IS NULL
        THEN
                p_x_mr_header_rec.UOM_CODE:=l_mr_header_Rec.UOM_CODE;
        END IF;

        IF p_x_mr_header_rec.DESCRIPTION= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.DESCRIPTION:=NULL;
        ELSIF p_x_mr_header_rec.DESCRIPTION IS NULL
        THEN
                p_x_mr_header_rec.DESCRIPTION:=l_mr_header_Rec.DESCRIPTION;
        END IF;
        IF p_x_mr_header_rec.COMMENTS= FND_API.G_MISS_CHAR
        THEN
        p_x_mr_header_rec.COMMENTS:=NULL;
        ELSIF p_x_mr_header_rec.COMMENTS IS NULL
        THEN
        p_x_mr_header_rec.COMMENTS:=l_mr_header_Rec.COMMENTS;
        END IF;
        IF p_x_mr_header_rec.ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
        THEN
        p_x_mr_header_rec.ATTRIBUTE_CATEGORY:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE_CATEGORY IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE_CATEGORY:=l_mr_header_Rec.ATTRIBUTE_CATEGORY;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE1= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE1:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE1 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE1:=l_mr_header_Rec.ATTRIBUTE1;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE2= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE2:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE2 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE2:=l_mr_header_Rec.ATTRIBUTE2;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE3= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE3:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE3 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE3:=l_mr_header_Rec.ATTRIBUTE3;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE4= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE4:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE4 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE4:=l_mr_header_Rec.ATTRIBUTE4;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE5= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE5:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE5 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE5:=l_mr_header_Rec.ATTRIBUTE5;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE6= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE6:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE6 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE6:=l_mr_header_Rec.ATTRIBUTE6;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE7= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE7:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE7 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE7 :=l_mr_header_Rec.ATTRIBUTE7;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE8= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE8:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE8 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE8:=l_mr_header_Rec.ATTRIBUTE8;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE9= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE9:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE9 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE9:=l_mr_header_Rec.ATTRIBUTE9;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE10= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE10:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE10 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE10:=l_mr_header_Rec.ATTRIBUTE10;
        END IF;
        IF p_x_mr_header_rec.ATTRIBUTE11= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE11:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE11 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE11:=l_mr_header_Rec.ATTRIBUTE11;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE12= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE12:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE12 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE12:=l_mr_header_Rec.ATTRIBUTE12;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE13= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE13:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE13 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE13:=l_mr_header_Rec.ATTRIBUTE13;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE14= FND_API.G_MISS_CHAR
        THEN
        p_x_mr_header_rec.ATTRIBUTE14:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE14 IS NULL
        THEN
        p_x_mr_header_rec.ATTRIBUTE14
        :=l_mr_header_Rec.ATTRIBUTE14;
        END IF;

        IF p_x_mr_header_rec.ATTRIBUTE15= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.ATTRIBUTE15:=NULL;
        ELSIF p_x_mr_header_rec.ATTRIBUTE15 IS NULL
        THEN
                p_x_mr_header_rec.ATTRIBUTE15:=l_mr_header_Rec.ATTRIBUTE15;
        END IF;


      --Billing Item
        IF p_x_mr_header_rec.billing_item= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.billing_item:=NULL;
        ELSIF p_x_mr_header_rec.billing_item IS NULL
        THEN
                p_x_mr_header_rec.billing_item:=l_mr_header_Rec.billing_item;
        END IF;
        --Billing Item Id
        IF p_x_mr_header_rec.billing_item_id= FND_API.G_MISS_NUM
        THEN
                p_x_mr_header_rec.billing_item_id:=NULL;
        ELSIF p_x_mr_header_rec.billing_item_id IS NULL
        THEN
                p_x_mr_header_rec.billing_item_id:=l_mr_header_Rec.billing_item_id;
        END IF;

      --qa_inspection_type
        IF p_x_mr_header_rec.qa_inspection_type= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.qa_inspection_type:=NULL;
        ELSIF p_x_mr_header_rec.qa_inspection_type IS NULL
        THEN
                p_x_mr_header_rec.qa_inspection_type:=l_mr_header_Rec.qa_inspection_type;
        END IF;

        IF p_x_mr_header_rec.qa_inspection_type_code= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.qa_inspection_type_code:=NULL;
        ELSIF p_x_mr_header_rec.qa_inspection_type_code IS NULL
        THEN
                p_x_mr_header_rec.qa_inspection_type_code:=l_mr_header_Rec.qa_inspection_type_code;
        END IF;

      --space_category_code
        IF p_x_mr_header_rec.space_category_code= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.space_category_code:=NULL;
        ELSIF p_x_mr_header_rec.space_category_code IS NULL
        THEN
                p_x_mr_header_rec.space_category_code:=l_mr_header_Rec.space_category_code;
        END IF;

        IF p_x_mr_header_rec.space_category= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_header_rec.space_category:=NULL;
        ELSIF p_x_mr_header_rec.space_category IS NULL
        THEN
                p_x_mr_header_rec.space_category:=l_mr_header_Rec.space_category;
        END IF;
END;


PROCEDURE CHECK_LOOKUP_CODE
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_lookup_code                  IN VARCHAR2,
 p_lookup_TYPE                  IN VARCHAR2
 )
as
CURSOR get_lookup_type_code(c_lookup_code VARCHAR2,c_lookup_type VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_code = c_lookup_code
   AND lookup_type = c_lookup_type
   AND sysdate between nvl(start_date_active,sysdate)
   AND nvl(end_date_active,sysdate);

l_lookup_code                   VARCHAR2(30):=null;
begin
       OPEN get_lookup_type_code(p_lookup_code,p_lookup_type);
       FETCH get_lookup_type_code INTO l_lookup_code;
       IF get_lookup_type_code%NOTFOUND
       THEN
           x_return_Status:= FND_API.G_RET_STS_UNEXP_ERROR;
       END IF;
       CLOSE get_lookup_type_code;
end;

PROCEDURE TRANSLATE_VALUE_ID
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_x_mr_header_rec              IN OUT NOCOPY AHL_FMP_MR_HEADER_PVT.MR_HEADER_REC
 )
as
CURSOR get_lookup_meaning_to_code(c_lookup_type VARCHAR2,c_meaning  VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(meaning) =upper(c_meaning)
   AND sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate);

CURSOR get_mr_title(c_mr_header_id NUMBER)
 IS
SELECT title,object_version_number
  FROM AHL_MR_HEADERS_APP_V
  WHERE mr_header_id= c_mr_header_id;

CURSOR get_mr_header(c_title VARCHAR2)
 IS
SELECT mr_header_id,title,object_version_number
  FROM AHL_MR_HEADERS_APP_V
  WHERE UPPER(TITLE)=UPPER(LTRIM(RTRIM(c_title)))
  AND trunc(nvl(effective_to,sysdate+1)) >trunc(sysdate);

CURSOR get_titlecount(c_title VARCHAR2)
 IS
SELECT COUNT(*)
  FROM AHL_MR_HEADERS_APP_V
  WHERE UPPER(TITLE)=UPPER(c_title)
  AND trunc(nvl(effective_to,sysdate+1)) >trunc(sysdate);

CURSOR get_prec_mrheader_info(c_mr_header_id NUMBER)
 IS
SELECT mr_header_id,title,object_version_number,revision
  FROM AHL_MR_HEADERS_APP_V
  WHERE MR_HEADER_ID=C_MR_HEADER_ID
  AND trunc(nvl(effective_to,sysdate+1)) >trunc(sysdate);

CURSOR get_mrItemId(c_billing_item VARCHAR2)
 IS
 --AMSRINIV. Bug 4916286. Removing 'upper' to improve performance.

 SELECT inventory_item_id
  FROM mtl_system_items_kfv
   WHERE STOCK_ENABLED_FLAG='N'
   AND MTL_TRANSACTIONS_ENABLED_FLAG='N'
   AND concatenated_segments= ltrim(rtrim(c_billing_item))
   and rownum <2;

 /*SELECT inventory_item_id
  FROM mtl_system_items_kfv
   WHERE STOCK_ENABLED_FLAG='N'
   AND MTL_TRANSACTIONS_ENABLED_FLAG='N'
   AND upper(concatenated_segments)= upper(ltrim(rtrim(c_billing_item)))
   and rownum <2;*/

 CURSOR get_qainspection_type_code(p_qa_inspection_type_desc VARCHAR2)
  IS
  SELECT short_code
  FROM qa_char_value_lookups_v
  WHERE char_id = 87
  AND upper(description) = upper(ltrim(rtrim(p_qa_inspection_type_desc)));

 l_prec_mr_info  get_prec_mrheader_info%rowtype;

 l_check_impl_status     NUMBER;
 l_title                 VARCHAR2(255);
 l_title_counter         NUMBER:=0;
 l_lookup_code           VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(30) := 'TRANSLATE_VALUE_ID';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_mrItemId              NUMBER:=0;
 l_lookup_var            varchar2(1);
 l_object_version_number NUMBER;
 l_check_flag            VARCHAR2(1):='Y';
 l_program_type_code_ind VARCHAR2(1):='N';
 BEGIN

        IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
      AHL_DEBUG_PUB.debug('Trans TYPE CODE '||p_x_mr_header_rec.TYPE_CODE,'+HEADERS+');
        END IF;

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_x_mr_header_rec.PROGRAM_TYPE IS  NULL OR  p_x_mr_header_rec.PROGRAM_TYPE=FND_API.G_MISS_CHAR
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGTYPE_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        END IF;


        IF l_check_flag='Y'
        THEN
                OPEN  get_lookup_meaning_to_code('AHL_FMP_MR_PROGRAM_TYPE',p_x_mr_header_rec.PROGRAM_TYPE);
                FETCH get_lookup_meaning_to_code INTO l_lookup_code;
                IF get_lookup_meaning_to_code%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGTYPE_INVALID');
                        FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.PROGRAM_TYPE,false);
                        FND_MSG_PUB.ADD;
                        l_check_flag:='N';
                ELSE
            l_program_type_code_ind:='N';
                        p_x_mr_header_rec.PROGRAM_TYPE_CODE:=l_lookup_code;
                        l_check_flag:='Y';
                END IF;

                CLOSE get_lookup_meaning_to_code;
        END IF;


-- Program Sub type

        IF (p_x_mr_header_rec.PROGRAM_SUBTYPE IS NULL OR
            p_x_mr_header_rec.PROGRAM_SUBTYPE=FND_API.G_MISS_CHAR)
        THEN
              p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=FND_API.G_MISS_CHAR;
        ELSE
                IF l_check_flag='Y'
                THEN

        OPEN  get_lookup_meaning_to_code('AHL_FMP_MR_PROGRAM_SUBTYPE',
                                                  p_x_mr_header_rec.PROGRAM_SUBTYPE);
                FETCH get_lookup_meaning_to_code INTO l_lookup_code;

                IF get_lookup_meaning_to_code%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGSUBTYPE_INVALID');
                        FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE,false);
                        FND_MSG_PUB.ADD;
                ELSE
                        p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=l_lookup_code;
                END IF;

                CLOSE get_lookup_meaning_to_code;
                END IF;
        END IF;


--Billing Item Id


        IF (p_x_mr_header_rec.BILLING_ITEM IS NULL OR p_x_mr_header_rec.BILLING_ITEM=FND_API.G_MISS_CHAR)
        THEN
              p_x_mr_header_rec.BILLING_ITEM:=FND_API.G_MISS_CHAR;
        ELSE
                IF l_check_flag='Y'
                THEN

        OPEN  get_mrItemId(p_x_mr_header_rec.BILLING_ITEM);
                FETCH get_mrItemId INTO p_x_mr_header_rec.BILLING_ITEM_ID;

                IF get_mrItemId%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_INVALID_BITEM');
                        FND_MESSAGE.SET_TOKEN('BILLING_ITEM',p_x_mr_header_rec.BILLING_ITEM,false);
                        FND_MSG_PUB.ADD;
                END IF;

                CLOSE get_mrItemId;
                END IF;
        END IF;
        --Implent Status and QA INSPECTION TYPE
                --Chack for the Valid QAInspection Type

                    IF (p_x_mr_header_rec.QA_INSPECTION_TYPE IS NULL
                        OR p_x_mr_header_rec.QA_INSPECTION_TYPE=FND_API.G_MISS_CHAR)
                    THEN
                        p_x_mr_header_rec.QA_INSPECTION_TYPE:=FND_API.G_MISS_CHAR;
                    ELSE
                        IF l_check_flag='Y'
                        THEN

                        OPEN  get_qainspection_type_code(p_x_mr_header_rec.QA_INSPECTION_TYPE);
                        FETCH get_qainspection_type_code INTO p_x_mr_header_rec.QA_INSPECTION_TYPE_CODE;

                        IF get_qainspection_type_code%NOTFOUND
                        THEN
                            FND_MESSAGE.SET_NAME('AHL','AHL_FMP_QA_INSP');
                            FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.QA_INSPECTION_TYPE,false);
                            FND_MSG_PUB.ADD;
            /* Commented the Qa inspection type depedency on IMPLEMENTAT_STATUS_CODE as per ER#3822674
                        ELSE
                            IF p_x_mr_header_rec.IMPLEMENT_STATUS_CODE IS NOT NULL
                            OR p_x_mr_header_rec.IMPLEMENT_STATUS_CODE <>FND_API.G_MISS_CHAR
                            THEN
                             IF p_x_mr_header_rec.IMPLEMENT_STATUS_CODE = 'OPTIONAL_DO_NOT_IMPLEMENT'
                             AND (p_x_mr_header_rec.qa_inspection_type IS NOT NULL
                             OR p_x_mr_header_rec.qa_inspection_type <>FND_API.G_MISS_CHAR)
                             THEN
                                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_IMPL_QA');
                                    FND_MSG_PUB.ADD;
                             END IF;
                           End if;
              */

                        END IF;
                        CLOSE get_qainspection_type_code;
                        END IF;
                    END IF;

--  IF PROGRAM TYPE IS NON-ROUTINE   THEN IMPLMENTATION STATUS HAS TO BE  OPTIONAL DO NOT IMPLEMENT

        IF p_x_mr_header_rec.PROGRAM_TYPE_CODE= 'NON-ROUTINE' AND
           p_x_mr_header_rec.IMPLEMENT_STATUS_CODE <> 'OPTIONAL_DO_NOT_IMPLEMENT'
        THEN
                                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_IMPL_AND_PROGRAM_TYPE');
                                    FND_MSG_PUB.ADD;
        END IF;

        IF p_x_mr_header_rec.implement_status_code <> 'OPTIONAL_DO_NOT_IMPLEMENT' AND
           p_x_mr_header_rec.dml_operation='U'
        THEN
                Select count(*) INTO l_check_impl_status
                From AHL_MR_HEADERS_B
                WHERE Implement_status_code = 'OPTIONAL_DO_NOT_IMPLEMENT'
                AND   MR_HEADER_ID=p_x_mr_header_rec.MR_HEADER_ID;
                IF nvl(l_check_impl_status,0) >0
                THEN
                        l_check_impl_status:=0;

                        Select count(*) INTO l_check_impl_status
                        From  AHL_MR_VISIT_TYPES
                        WHERE MR_HEADER_ID=p_x_mr_header_rec.MR_HEADER_ID;

                        IF nvl(l_check_impl_status,0) >0
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_VTYPE_EXIST');
                                FND_MSG_PUB.ADD;
                                -- Cannot modify if implementation status from unplanned/optional do not implement to some thing else if visit types are defined.
                        END IF;
                END IF;
        END IF;


--  Preceding MR_header_id

        IF p_x_mr_header_rec.PRECEDING_MR_TITLE IS NOT NULL  AND p_x_mr_header_rec.PRECEDING_MR_TITLE<>FND_API.G_MISS_CHAR
        THEN
                OPEN   get_titlecount(p_x_mr_header_rec.PRECEDING_MR_TITLE);
                FETCH  get_titlecount INTO l_title_counter;
                Close  get_titlecount;

                IF  nvl(l_title_counter,0)=0
                THEN
                        IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug( 'PRECEDING MR_TITLE COUNTER');
            END IF;
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_ID_INVALID');
                        FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.PRECEDING_MR_TITLE,false);
                        FND_MSG_PUB.ADD;
                ELSIF nvl(l_title_counter,0)=1
                THEN
                        OPEN  get_mr_header(p_x_mr_header_rec.PRECEDING_MR_TITLE);

                        FETCH get_mr_header INTO p_x_mr_header_rec.PRECEDING_MR_HEADER_ID,l_title,l_object_version_number;

                        IF get_mr_header%NOTFOUND
                        THEN
                                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug(' Preceding MRHEADER_ID NOT FOUND2','+HEADERS+');
                END IF;
                               FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_ID_INVALID');
                               FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.PRECEDING_MR_TITLE,false);
                               FND_MSG_PUB.ADD;
                        END IF;
                        Close get_mr_header;
                ELSIF  NVL(l_title_counter,0)>1
                THEN
                        OPEN  get_prec_mrheader_info(p_x_mr_header_rec.PRECEDING_MR_HEADER_ID);
                        FETCH get_prec_mrheader_info INTO l_prec_mr_info;

                        IF G_DEBUG='Y' THEN
                                AHL_DEBUG_PUB.debug( 'PRECEDING .. MR>1 '||p_x_mr_header_rec.PRECEDING_MR_HEADER_ID,'+HEADERS+');
                        END IF;

                        IF get_prec_mrheader_info%NOTFOUND
                        THEN
                        IF G_DEBUG='Y' THEN
                                  AHL_DEBUG_PUB.debug('Preceding mr title err','+HEADERS+');
            END IF;

                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_ID_INVALID');
                        FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_header_rec.PRECEDING_MR_TITLE,false);
                        FND_MSG_PUB.ADD;

                        ELSIF (l_prec_mr_info.title<>p_x_mr_header_rec.PRECEDING_MR_TITLE
                               and l_prec_mr_info.REVISION<>p_x_mr_header_rec.PRECEDING_MR_REVISION)
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PREC_MR_ID_SELECT_LOV');
                                FND_MSG_PUB.ADD;
                        END IF;

                        Close get_prec_mrheader_info;
                ELSIF  NVL(l_title_counter,0)=0
                THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_ID_INVALID');
                                FND_MSG_PUB.ADD;
                END IF;
        END IF;

        IF p_x_mr_header_rec.DML_OPERATION='U'
        THEN

        IF p_x_mr_header_rec.version_number=FND_API.G_MISS_NUM OR
           p_x_mr_header_rec.version_number IS NULL
        THEN
                select version_number into p_x_mr_header_rec.version_number
                from AHL_MR_HEADERS_APP_V
                where mr_header_id=p_x_mr_header_rec.mr_header_id;
        END IF;

        END IF;
END;

-- Start of Validate
PROCEDURE VALIDATE_MR_TYPE
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_mr_header_rec                IN  AHL_FMP_MR_HEADER_PVT.MR_HEADER_REC
 )
as
Cursor GetMrdet(C_MR_HEADER_ID NUMBER)
IS
SELECT * FROM AHL_MR_HEADERS_APP_V
WHERE MR_HEADER_ID=C_MR_HEADER_ID;
l_mr_rec                GetMrdet%rowtype;
l_counter               NUMBER:=0;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_mr_header_rec.MR_HEADER_ID IS NOT NULL OR p_mr_header_rec.MR_HEADER_ID<>FND_API.G_MISS_NUM
        THEN


                OPEN GetMrDet(p_mr_header_rec.MR_HEADER_ID);
                FETCH GetMrDet into l_mr_rec;
                        IF GetMrDet%NOTFOUND
                        THEN
                           FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                           FND_MSG_PUB.ADD;
                        ELSE

                                IF p_mr_header_rec.TYPE_CODE<>l_mr_rec.type_code
                                THEN
                                        SELECT COUNT(*) INTO l_counter
                                        FROM AHL_MR_RELATIONSHIPS
                                        WHERE MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID;
                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_REL_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;

                                        SELECT COUNT(*) INTO l_counter
                                        FROM AHL_MR_EFFECTIVITIES
                                        WHERE MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID
                                        AND ((PROGRAM_DURATION IS NOT NULL OR PROGRAM_DURATION_UOM_CODE IS NOT NULL)
                                        AND THRESHOLD_DATE  IS NOT NULL);


                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EFF_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;

                                        SELECT COUNT(B.MR_INTERVAL_ID) INTO l_counter
                                        FROM AHL_MR_EFFECTIVITIES A,AHL_MR_INTERVALS B
                                        WHERE A.MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID
                                        AND A.MR_EFFECTIVITY_ID=B.MR_EFFECTIVITY_ID;

                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INT_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;
                                 END IF;

                                 IF p_mr_header_rec.TYPE_CODE='PROGRAM' and l_mr_rec.type_code='ACTIVITY'
                                 THEN
                                        SELECT COUNT(*) INTO l_counter
                                        FROM AHL_MR_ROUTES
                                        WHERE MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID;

                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ROUTS_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;

                                        SELECT COUNT(*) INTO l_counter
                                        FROM AHL_MR_ACTIONS_B
                                        WHERE MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID;
                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ACTNS_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;

                                        SELECT COUNT(*) INTO l_counter
                                        FROM AHL_DOC_TITLE_ASSOS_B
                                        WHERE ASO_OBJECT_ID=p_mr_header_rec.MR_HEADER_ID
                                        AND   ASO_OBJECT_TYPE_CODE='MR';

                                        IF l_counter >0
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_DOC_SHOULDNOT_EXIST');
                                                FND_MSG_PUB.ADD;
                                        END IF;
                                END IF;
                        END IF;
                CLOSE GetMrDet;
        END IF;
END;


PROCEDURE VALIDATE_MR_HEADER
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_mr_header_rec                IN  AHL_FMP_MR_HEADER_PVT.MR_HEADER_REC
 )
as

CURSOR get_lookup_meaning_to_code(c_lookup_type VARCHAR2,c_meaning  VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(meaning) =upper(c_meaning)
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

CURSOR get_mr_title(c_mr_header_id number)
 IS
SELECT title,object_version_number
  FROM AHL_MR_HEADERS_APP_V
  WHERE mr_header_id= c_mr_header_id;

CURSOR
check_prog_subtype(C_PROGRAM_TYPE_CODE VARCHAR2,C_PROGRAM_SUBTYPE_CODE VARCHAR2)
 IS
 SELECT count(*)
  FROM AHL_PROG_TYPE_SUBTYPES
  WHERE
  PROGRAM_TYPE_CODE =C_PROGRAM_TYPE_CODE  AND
  PROGRAM_SUBTYPE_CODE=C_PROGRAM_SUBTYPE_CODE;

--Super user cannot edit these fields
 CURSOR get_super_non_edit(c_mr_header_id number)
 IS
 --AMSRINIV.Bug 4916286. Tuning below commented query for improving performance
  SELECT
   mr.implement_status_code,
   mr.repetitive_flag,
   mr.show_repetitive_code,
   mr.whichever_first_code,
   mr.effective_from,
   mr.copy_accomplishment_flag,
   mr.type_code,
   mtl.concatenated_segments billing_item,
   mr.billing_item_id,
   mr.qa_inspection_type qa_inspection_type_code,
   qa.description    qa_inspection_type,
   mr.space_category_code,
   mr.down_time,
   mr.uom_code
 FROM
   ahl_mr_headers_b mr,
   qa_char_value_lookups qa,
   mtl_system_items_kfv mtl
 WHERE
   mr_header_id= c_mr_header_id AND
   qa.short_code(+) = mr.qa_inspection_type AND
   qa.char_id(+) =    87 AND
   mtl.inventory_item_id(+) = mr.billing_item_id AND
   mtl.organization_id(+) =    mr.billing_org_id AND
   mr.application_usg_code =
   RTRIM(LTRIM(fnd_profile.value('AHL_APPLN_USAGE')));

 /*SELECT IMPLEMENT_STATUS_CODE,
        REPETITIVE_FLAG,
        SHOW_REPETITIVE_CODE,
        WHICHEVER_FIRST_CODE,
        EFFECTIVE_FROM,
        COPY_ACCOMPLISHMENT_FLAG,
        TYPE_CODE,
        BILLING_ITEM,
        BILLING_ITEM_ID,
        QA_INSPECTION_TYPE_CODE,
        QA_INSPECTION_TYPE,
        SPACE_CATEGORY_CODE,
        DOWN_TIME,
        UOM_CODE
 FROM   AHL_MR_HEADERS_V
 WHERE mr_header_id= c_mr_header_id;*/

 l_rec   get_super_non_edit%rowtype;

 Cursor GetHeaderInfo(C_MR_HEADER_ID NUMBER)
 IS
 SELECT MR_HEADER_ID,
        TITLE,
        VERSION_NUMBER,
        MR_STATUS_CODE,
        EFFECTIVE_FROM
 FROM AHL_MR_HEADERS_APP_V
 WHERE MR_HEADER_ID=C_MR_HEADER_ID
 AND object_version_number=p_mr_header_rec.object_Version_number;

 l_mr_rec       GetHeaderInfo%ROWTYPE;


 Cursor GetHeaderInfo1(C_TITLE  VARCHAR2,C_VERSION_NUMBER NUMBER)
 IS
 SELECT MR_HEADER_ID,TITLE,VERSION_NUMBER,MR_STATUS_CODE,EFFECTIVE_FROM
 FROM AHL_MR_HEADERS_APP_V
 WHERE upper(TITLE)=upper(C_TITLE)
 and version_number=c_version_number-1;

 l_mr_rec1                      GetHeaderInfo1%ROWTYPE;

 l_title                        VARCHAR2(255);
 l_object_version_number        NUMBER;
 l_lookup_code                  VARCHAR2(30);
 l_appln_code                   VARCHAR2(80);
 l_msg_count                    NUMBER;
 l_msg_data1                    VARCHAR2(2000);
 l_return_status                VARCHAR2(1);
 l_mr_header_rec                AHL_FMP_MR_HEADER_PVT.mr_header_Rec:=p_mr_header_rec;
 l_lookup_var                   varchar2(1);
 l_title_counter                NUMBER:=0;
 l_check_flag                   VARCHAR2(1):='Y';
 l_counter                      number:=0;
 l_prev_ver_date                DATE;

    -- Tamal [MEL/CDL] -- Begin changes
    CURSOR check_route_mo_proc
    (
        c_mr_header_id number
    )
    IS
    select  'x'
    from    ahl_mr_routes mrr, ahl_routes_b rm
    where   mrr.route_id = rm.route_id and
            nvl(rm.route_type_code, 'X') not in ('M_PROC','O_PROC') and
            mrr.mr_header_id = c_mr_header_id;

    CURSOR check_eff_exists
    (
        c_mr_header_id number
    )
    IS
    select  'x'
    from    ahl_mr_effectivities
    where   mr_header_id = c_mr_header_id;

    l_dummy_char            varchar2(1);
    l_old_prog_type         varchar2(30);
    -- Tamal [MEL/CDL] -- End changes

 BEGIN
     x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
                  AHL_DEBUG_PUB.debug('Application Usage code:'||G_APPLN_USAGE);
          AHL_DEBUG_PUB.debug('TYPE CODE '||p_mr_header_rec.TYPE_CODE,'+HEADERS+');
    END IF;

        IF G_APPLN_USAGE IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;

     IF p_mr_header_rec.PROGRAM_TYPE_CODE IS NULL OR
    p_mr_header_rec.PROGRAM_TYPE_CODE=FND_API.G_MISS_CHAR
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGTYPE_NULL');
        FND_MSG_PUB.ADD;
        l_check_flag:='N';
     END IF;

     IF p_mr_header_rec.AUTO_SIGNOFF_FLAG<>'Y'  AND
        nvl(p_mr_header_rec.AUTO_SIGNOFF_FLAG,'N')<>'N'
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_AUTOSIGNOFF_INVALID');
        FND_MSG_PUB.ADD;
        l_check_flag:='N';
     END IF;


     IF G_APPLN_USAGE='PM'
     THEN
             IF p_mr_header_rec.TYPE_CODE IS NULL OR p_mr_header_rec.TYPE_CODE=FND_API.G_MISS_CHAR
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TYPE_CODE_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
             END IF;
     END IF;


     IF p_mr_header_Rec.PROGRAM_SUBTYPE_CODE IS NULL OR p_mr_header_Rec.PROGRAM_SUBTYPE_CODE=FND_API.G_MISS_char
     THEN
        l_check_flag:='N';
     END IF;

     IF l_check_flag='Y'
     THEN
       OPEN check_prog_subtype(p_mr_header_rec.PROGRAM_TYPE_CODE,p_mr_header_rec.PROGRAM_SUBTYPE_CODE);
       FETCH check_prog_subtype INTO l_counter;
       IF check_prog_subtype%FOUND  and l_counter=0
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGTYPESUBTYPE_INV');
           FND_MESSAGE.SET_TOKEN('FIELD1',p_mr_header_rec.PROGRAM_SUBTYPE_CODE,false);
           FND_MESSAGE.SET_TOKEN('FIELD2',p_mr_header_rec.PROGRAM_TYPE_CODE,false);
           FND_MSG_PUB.ADD;
       END IF;
       CLOSE check_prog_subtype;
     END IF;

-- Service Type
        IF G_APPLN_USAGE<>'PM'
        THEN

        IF p_mr_header_rec.service_type_code IS NOT NULL OR p_mr_header_rec.service_type_code<>FND_API.G_MISS_CHAR
        THEN

                CHECK_LOOKUP_CODE
                (
                x_return_status     =>l_return_status,
                p_lookup_code       =>p_mr_header_rec.service_type_code,
                p_lookup_TYPE       =>'AHL_FMP_MR_SERVICE_TYPE'
                );
                IF l_return_status<>'S'
                THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_SERVICE_INVALID');
                   FND_MESSAGE.SET_TOKEN('FIELD',p_mr_header_rec.service_type_code,false);
                   FND_MSG_PUB.ADD;
                END IF;
        END IF;

        ELSIF G_APPLN_USAGE<>'PM'
        THEN
                CHECK_LOOKUP_CODE
                (
                x_return_status     => l_return_status,
                p_lookup_code       => p_mr_header_rec.uom_code,
                p_lookup_TYPE       =>'AHL_FMP_PM_DOWNTIME_UOM'
                );
                IF l_return_status<>'S'
                THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_UOM_CODE_INV');
                   FND_MSG_PUB.ADD;
                END IF;
        END IF;

-- Implement Status


        CHECK_LOOKUP_CODE
        (
        x_return_status     =>l_return_status,
        p_lookup_code       =>p_mr_header_rec.implement_status_code,
        p_lookup_TYPE       =>'AHL_FMP_MR_IMPLEMENT_STATUS'
        );
        IF l_return_status<>'S'
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_IMPLMNTSTAT_INVALID');
           FND_MESSAGE.SET_TOKEN('FIELD',p_mr_header_rec.implement_status_code,false);
           FND_MSG_PUB.ADD;
        END IF;

-- Qa Inspection type and  autosignoff

         IF p_mr_header_rec.AUTO_SIGNOFF_FLAG='Y'
         THEN

                IF p_mr_header_rec.QA_INSPECTION_TYPE IS NOT NULL
                and  p_mr_header_rec.QA_INSPECTION_TYPE <>FND_API.G_MISS_CHAR
                THEN
                   IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('Error at AHL_FMP_AUTSIGNOFF_QA_INV');
                   END IF;
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_AUTSIGNOFF_QA_INV');
                   FND_MSG_PUB.ADD;
                END IF;
         END IF;


         /*
     -- This validation removed based on er 2972124/3822674
         IF p_mr_header_rec.implement_status_code IS NOT NULL
         and  p_mr_header_rec.implement_status_code <>FND_API.G_MISS_CHAR
         THEN
             IF p_mr_header_rec.implement_status_code = 'OPTIONAL_DO_NOT_IMPLEMENT'
             AND (p_mr_header_rec.qa_inspection_type IS NOT NULL
             AND p_mr_header_rec.qa_inspection_type <>FND_API.G_MISS_CHAR)
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_IMPL_QA');
                FND_MSG_PUB.ADD;
             END IF;
         END IF;
     */
-- Repetitive Flag
        CHECK_LOOKUP_CODE
        (
        x_return_status     =>l_return_status,
        p_lookup_code       =>p_mr_header_rec.repetitive_flag,
        p_lookup_TYPE       =>'AHL_YES_NO_TYPE'
        );

        IF l_return_status<>'S'
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_REPETITIVE_INVALID');
           FND_MESSAGE.SET_TOKEN('FIELD',p_mr_header_rec.repetitive_flag,false);
           FND_MSG_PUB.ADD;
        ELSE
                IF p_mr_header_rec.repetitive_flag ='N'
                   and (p_mr_header_rec.SHOW_REPETITIVE_CODE IS NOT NULL  OR  p_mr_header_rec.SHOW_REPETITIVE_CODE<>FND_API.G_MISS_CHAR)
                THEN
                  IF p_mr_header_rec.SHOW_REPETITIVE_CODE<>'NEXT'
                  THEN
                       FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_REPITITVE_NO');
                       FND_MSG_PUB.ADD;
                  END IF;
                END IF;

                if p_mr_header_rec.dml_operation<>'C'
                then

                        IF p_mr_header_rec.SUPERUSER_ROLE<>'Y'
                        THEN

                                AHL_FMP_COMMON_PVT.validate_mr_interval_threshold
                                (
                                x_return_status=>l_return_status,
                                x_msg_data=>l_msg_data1,
                                p_mr_header_id=>p_mr_header_rec.mr_header_id,
                                p_repetitive_flag=>p_mr_header_rec.repetitive_flag
                                );

                                IF l_return_Status<>FND_API.G_RET_STS_SUCCESS
                                THEN
                                     FND_MESSAGE.SET_NAME('AHL',l_msg_data1);
                                     FND_MSG_PUB.ADD;
                                END IF;
                        END IF;
                end if;
        END IF;

-- Whichever_first_code
        CHECK_LOOKUP_CODE
        (
        x_return_status     =>l_return_status,
        p_lookup_code       =>p_mr_header_rec.whichever_first_code,
        p_lookup_TYPE       =>'AHL_FMP_THRESHOLD_FIRST'
        );

        IF l_return_status<>'S'
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_WHICHEVER_INVALID');
           FND_MESSAGE.SET_TOKEN('FIELD',p_mr_header_rec.whichever_first_code,false);
           FND_MSG_PUB.ADD;
        END IF;

--Space Category

        IF p_mr_header_rec.space_category_code  is not null or p_mr_header_rec.space_category_code<>fnd_api.g_miss_char
        THEN
        CHECK_LOOKUP_CODE
        (
        x_return_status     =>l_return_status,
        p_lookup_code       =>p_mr_header_rec.space_category_code,
        p_lookup_TYPE       =>'AHL_LTP_SPACE_CATEGORY'
        );

        IF l_return_status<>'S'
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_VISIT_CATEGORY');
           FND_MESSAGE.SET_TOKEN('FIELD',p_mr_header_rec.space_category_code,false);
           FND_MSG_PUB.ADD;
        END IF;
        END IF;





 -- Effective From Validate Of Date
       IF l_mr_header_rec.MR_STATUS_CODE='DRAFT'  -- AND nvl(l_mr_header_rec.SUPERUSER_ROLE,'N')='N'
       THEN
        IF p_mr_header_rec.effective_from  is null or p_mr_header_rec.effective_from=fnd_api.g_miss_date
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_EFFECTIVE_FROM_NULL');
           FND_MSG_PUB.ADD;
        ELSIF TRUNC(p_mr_header_rec.effective_from)<TRUNC(SYSDATE)
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_EFFE_FROM_INVALID');
           FND_MSG_PUB.ADD;
        END IF;
       END IF;
        IF P_MR_HEADER_REC.DML_OPERATION='U'
    THEN
        IF l_mr_header_rec.MR_STATUS_CODE='DRAFT'  -- AND nvl(l_mr_header_rec.SUPERUSER_ROLE,'N')='N'
        THEN
                open GetHeaderInfo(P_MR_HEADER_REC.mr_header_id);
                fetch GetHeaderInfo into l_mr_rec;
                close GetHeaderInfo;

                if l_mr_rec.version_number>1
                then
                        open GetHeaderInfo1(l_mr_rec.TITLE,l_mr_rec.VERSION_NUMBER);
                        fetch GetHeaderInfo1 into l_mr_rec1;
                        IF   GetHeaderInfo1%FOUND
                        THEN

                                IF trunc(l_mr_Rec.effective_from) < trunc(l_mr_Rec1.effective_from)
                                THEN
                                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ST_DATE_LESSER');
                                   FND_MESSAGE.SET_TOKEN('FIELD',l_mr_Rec.effective_from,false);
                                   FND_MSG_PUB.ADD;
                                END IF;
                        END IF;
                        close GetHeaderInfo1;
                end if;
    end if;
    END IF;
-- Super User
       IF G_DEBUG='Y'
       THEN
      AHL_DEBUG_PUB.debug('superusermode is ...:'||l_MR_HEADER_REC.SUPERUSER_ROLE);
      AHL_DEBUG_PUB.debug('billing item :'||nvl(l_MR_HEADER_REC.BILLING_ITEM,'X'));
      AHL_DEBUG_PUB.debug('billing item :'||nvl(l_REC.BILLING_ITEM,'X'));
      AHL_DEBUG_PUB.debug('billing item :'||nvl(p_mr_header_rec.mr_header_id,0));
       END IF;
       IF l_mr_header_rec.MR_STATUS_CODE='COMPLETE' AND nvl(l_mr_header_rec.SUPERUSER_ROLE,'N')='N'
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_INVALID_EDIT');
           FND_MSG_PUB.ADD;
       ELSIF l_mr_header_rec.MR_STATUS_CODE='COMPLETE' AND l_mr_header_rec.SUPERUSER_ROLE='Y'
       THEN


               OPEN  get_super_non_edit(p_mr_header_rec.MR_HEADER_ID);
               FETCH get_super_non_edit INTO  l_rec;
            IF G_DEBUG='Y'
            THEN
               AHL_DEBUG_PUB.debug(l_rec.REPETITIVE_FLAG ||'---'||(p_mr_header_rec.REPETITIVE_FLAG));
               AHL_DEBUG_PUB.debug(l_rec.SHOW_REPETITIVE_CODE||'---'|| (p_mr_header_rec.SHOW_REPETITIVE_CODE));
               AHL_DEBUG_PUB.debug(l_rec.WHICHEVER_FIRST_CODE||'---'|| (p_mr_header_rec.WHICHEVER_FIRST_CODE));
               AHL_DEBUG_PUB.debug(l_rec.EFFECTIVE_FROM||'---'||(p_mr_header_rec.EFFECTIVE_FROM));
               AHL_DEBUG_PUB.debug(l_rec.BILLING_ITEM_ID||'---'||(p_mr_header_rec.BILLING_ITEM_ID));
               AHL_DEBUG_PUB.debug(l_rec.BILLING_ITEM);
               AHL_DEBUG_PUB.debug(l_rec.qa_inspection_type_code||'---'||(p_mr_header_rec.qa_inspection_type_code));
               AHL_DEBUG_PUB.debug(l_rec.space_category_code||'---'||(P_mr_header_rec.space_category_code));
               AHL_DEBUG_PUB.debug(l_rec.DOWN_TIME||'---'||(p_mr_header_rec.DOWN_TIME));
               AHL_DEBUG_PUB.debug(l_rec.UOM_CODE||'---'||(p_mr_header_rec.uom_code));
            END IF;

               IF  nvl(l_rec.REPETITIVE_FLAG,'X')        <> nvl(p_mr_header_rec.REPETITIVE_FLAG,'X')
                   or nvl(l_rec.SHOW_REPETITIVE_CODE,'X')<> nvl(p_mr_header_rec.SHOW_REPETITIVE_CODE,'X')
                   or nvl(l_rec.WHICHEVER_FIRST_CODE,'X')<> nvl(p_mr_header_rec.WHICHEVER_FIRST_CODE,'X')
                   or trunc(l_rec.EFFECTIVE_FROM)<>trunc(p_mr_header_rec.EFFECTIVE_FROM)
                   or nvl(l_rec.BILLING_ITEM_ID,0)<>nvl(p_mr_header_rec.BILLING_ITEM_ID,0)
                   or nvl(l_rec.qa_inspection_type_code,'X')<>nvl(p_mr_header_rec.qa_inspection_type_code,'X')
                   or nvl(l_rec.space_category_code,'X')<>nvl(P_mr_header_rec.space_category_code,'X')
                   or NVL(l_rec.DOWN_TIME,0)<>NVL(p_mr_header_rec.DOWN_TIME,0)
                   or nvl(l_rec.UOM_CODE,'X')<>nvl(p_mr_header_rec.uom_code,'X')
               THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_SUPER_NONEDIT_COLS');
                   FND_MSG_PUB.ADD;
                   AHL_DEBUG_PUB.debug('SUPERUSER NONEDIT:'||L_MR_HEADER_REC.SUPERUSER_ROLE);
                   l_check_flag:='N';
               END IF;
               CLOSE get_super_non_edit;
       END IF;

--  Validating null items

     IF p_mr_header_rec.SHOW_REPETITIVE_CODE IS NULL OR p_mr_header_rec.SHOW_REPETITIVE_CODE=FND_API.G_MISS_char
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_REPETITIVE_INVALID');
        FND_MSG_PUB.ADD;
     END IF;

     IF p_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG IS NULL
    OR p_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG=FND_API.G_MISS_CHAR
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACCMPLSHMNT_NULL');
        FND_MSG_PUB.ADD;
     END IF;

     IF p_mr_header_rec.CATEGORY_CODE IS NULL
    OR p_mr_header_rec.CATEGORY_CODE=FND_API.G_MISS_CHAR
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_CATEGORY_NULL');
        FND_MSG_PUB.ADD;
     END IF;

     IF G_APPLN_USAGE='PM'
     THEN
             IF p_mr_header_rec.TYPE_CODE IS NULL
        OR p_mr_header_rec.TYPE_CODE=FND_API.G_MISS_CHAR
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_TYPECODE_NULL');
                FND_MSG_PUB.ADD;
             ELSE
                CHECK_LOOKUP_CODE
                (
                x_return_status     =>l_return_status,
                p_lookup_code       =>p_mr_header_rec.type_code,
                p_lookup_TYPE       =>'AHL_FMP_MR_TYPE'
                );
                IF l_return_status<>'S'
                THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_TYPE_CODE_INVALID');
                   FND_MSG_PUB.ADD;
                END IF;
             END IF;


        IF NVL(p_mr_header_rec.TYPE_CODE,'X')='PROGRAM'
        and NVL(p_mr_header_rec.DOWN_TIME,0)>0
                THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_DOWNTIME_ZERO');
                FND_MSG_PUB.ADD;
             ELSIF NVL(p_mr_header_rec.TYPE_CODE,'X')<>'PROGRAM'
        and NVL(p_mr_header_rec.DOWN_TIME,0)=0
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_DOWNTIME_NO_Z');
                FND_MSG_PUB.ADD;
             END IF;

             IF NVL(p_mr_header_rec.TYPE_CODE,'X')='PROGRAM'
        and NVL(p_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID,0)>0
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_SRVREQ_TEMPLT');
                FND_MSG_PUB.ADD;
             END IF;

             IF p_mr_header_rec.DML_OPERATION='U'
             THEN
                  AHL_DEBUG_PUB.debug('Error.Before calling validate mr_type :'||L_MR_HEADER_REC.SUPERUSER_ROLE);
                     VALIDATE_MR_TYPE
                     (
                     x_return_status             =>x_return_Status,
                     p_mr_header_rec             =>l_mr_header_rec
                     );

             END IF;
    else
            IF  (p_mr_header_rec.DOWN_TIME IS NOT NULL AND
                 p_mr_header_rec.DOWN_TIME<>FND_API.G_MISS_NUM)
            AND p_mr_header_rec.DOWN_TIME <=0
            THEN
            -- FOR CMRO MODE
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_DOWNTIME_NO_Z');
                FND_MSG_PUB.ADD;
            END IF;

     END IF;

    -- Tamal [MEL/CDL] -- Begin changes
    IF (p_mr_header_rec.dml_operation <> 'D')
    THEN
        IF (p_mr_header_rec.program_type_code = 'MO_PROC' AND p_mr_header_rec.implement_status_code <> 'OPTIONAL_DO_NOT_IMPLEMENT')
        THEN
            FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MR_MOPROC_IMPL_INV');
            -- Maintenance Requirements of (M) and (O) procedure program type must be unplanned.
            FND_MSG_PUB.ADD;
        END IF;
    END IF;
    -- Tamal [MEL/CDL] -- End changes

-- DML Operation  Create

   IF p_mr_header_rec.dml_operation='C' THEN
       IF p_mr_header_rec.title is null or p_mr_header_rec.title=fnd_api.g_miss_char
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TITLE_NULL');
           FND_MSG_PUB.ADD;
       ELSIF p_mr_header_rec.title is not null or p_mr_header_rec.title<>fnd_api.g_miss_char
       THEN

-- Title Should not Repeat in Create mode

           SELECT COUNT(*) INTO l_title_counter
                  FROM AHL_MR_HEADERS_APP_V
                  WHERE upper(ltrim(rtrim(TITLE)))=upper(ltrim(rtrim(l_mr_header_rec.title)));
           IF l_title_counter >0 then
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TITLE_INVALID');
                   FND_MSG_PUB.ADD;
           END IF;
       END IF;

   ELSIF  p_mr_header_rec.dml_operation<>'U'  THEN
       IF p_mr_header_rec.title is null or p_mr_header_rec.title=fnd_api.g_miss_char
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TITLE_NULL');
           FND_MSG_PUB.ADD;
       END IF;
       IF p_mr_header_rec.PRECEDING_MR_HEADER_ID=p_mr_header_rec.MR_HEADER_ID
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_ID_INVALID');
           FND_MSG_PUB.ADD;
       END IF;

       IF p_mr_header_rec.mr_header_id is null or  p_mr_header_rec.mr_header_id=fnd_api.g_miss_num
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
           FND_MSG_PUB.ADD;
       END IF;

        IF p_mr_header_rec.SERVICE_TYPE_CODE IS NULL OR p_mr_header_rec.SERVICE_TYPE_CODE=FND_API.G_MISS_char
        THEN
                IF G_APPLN_USAGE<>'PM'
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_SERVICE_NULL');
                        FND_MSG_PUB.ADD;
                END IF;
        ELSE
               OPEN get_mr_title(p_mr_header_rec.mr_header_id);
               FETCH get_mr_title INTO l_title,l_object_version_number;

               IF get_mr_title%NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_INVALID');
                   FND_MSG_PUB.ADD;
               END IF;

       IF p_mr_header_rec.object_version_number <> l_object_version_number or l_object_version_number is null or  l_object_version_number=fnd_api.g_miss_num
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
       END IF;
       IF p_mr_header_rec.title <> l_title
       THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TITLE_NOT_EDITABLE');
           FND_MSG_PUB.ADD;
       END IF;
       CLOSE get_mr_title;
  END IF;
 END IF;

    -- Tamal [MEL/CDL] -- Begin changes
    IF (p_mr_header_rec.dml_operation = 'U')
    THEN
        IF (p_mr_header_rec.program_type_code='MO_PROC')
        THEN
            OPEN check_route_mo_proc(p_mr_header_rec.mr_header_id);
            FETCH check_route_mo_proc INTO l_dummy_char;
            IF (check_route_mo_proc%FOUND)
            THEN
                FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MR_TYPE_ROUTE_INV');
                -- Cannot modify program type to (M) and (O) procedure since routes of non (M), (O) procedure type are already associated.
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE check_route_mo_proc;
        END IF;

        SELECT program_type_code INTO l_old_prog_type FROM ahl_mr_headers_b WHERE mr_header_id = p_mr_header_rec.mr_header_id;
        IF (l_old_prog_type <> p_mr_header_rec.program_type_code AND 'MO_PROC' IN (l_old_prog_type, p_mr_header_rec.program_type_code))
        THEN
            OPEN check_eff_exists(p_mr_header_rec.mr_header_id);
            FETCH check_eff_exists INTO l_dummy_char;
            IF (check_eff_exists%FOUND)
            THEN
                FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MR_TYPE_EFF_INV');
            -- Cannot modify program type to / from(M) and (O) procedure since effectivities already exist.
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE check_eff_exists;
        END IF;
    END IF;
    -- Tamal [MEL/CDL] -- End changes

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;

END;

PROCEDURE  CHECK_CYCLIC_ASSOCIATION
(
 p_api_version               IN     NUMBER:=1.0,
 p_init_msg_list             IN     VARCHAR2:= FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 P_MR_HEADER_ID              IN NUMBER,
 P_PREC_HEADER_ID            IN NUMBER,
 P_RELATED_MR_TITLE          IN VARCHAR2
)
AS
l_cyclic_loop           EXCEPTION;
pragma                  EXCEPTION_INIT(l_cyclic_loop,-1436);
l_counter               NUMBER;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        SELECT COUNT(*) INTO l_counter
        FROM  AHL_MR_HEADERS_B
        WHERE APPLICATION_USG_CODE=G_APPLN_USAGE
        START WITH MR_HEADER_ID=P_MR_HEADER_ID
        CONNECT BY PRIOR MR_HEADER_ID=PRECEDING_MR_HEADER_ID;

EXCEPTION
WHEN l_cyclic_loop  THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PREC_MR_H_ID_CYCLIC');
        FND_MESSAGE.SET_TOKEN('FIELD',P_RELATED_MR_TITLE,false);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_MR_ASSOCIATIONS_PVT',
                            p_procedure_name  =>  'CHECK_CYCLIC_ASSOCIATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;


PROCEDURE CREATE_MR_HEADER
(
 p_api_version               IN         NUMBER:=1.0,
 p_init_msg_list             IN         VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         VARCHAR2:= FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2:= FND_API.G_FALSE ,
 p_module_type               IN         VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_x_mr_header_rec              IN OUT  NOCOPY mr_header_Rec
 )
as
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_MR_HEADER';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_mr_header_id          number:=0;
 l_rowid                 varchar2(30);
 BEGIN
        SAVEPOINT CREATE_MR_HEADER_PVT;

   -- Initialize message list if p_init_msg_list is set to TRUE.

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.to_boolean(l_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;


        x_return_status:=FND_API.G_RET_STS_SUCCESS;


        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
    END IF;


        IF p_module_type = 'JSP' THEN
                p_x_mr_header_rec.PROGRAM_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=NULL;
                p_x_mr_header_rec.BILLING_ITEM_ID:=NULL;
                p_x_mr_header_rec.QA_INSPECTION_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=NULL;
                p_x_mr_header_rec.PRECEDING_MR_HEADER_ID:=NULL;
        END IF;
          AHL_DEBUG_PUB.debug('p_x_mr_header_rec.billing_item_id :'||p_x_mr_header_rec.billing_item_id);
    -- Debug info.

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'AHL_FMP_MR_HEADERS_PVT.','+CREATE_MR_HEADER+');
        END IF;

        IF FND_API.to_boolean(p_default)
        THEN
         DEFAULT_MISSING_ATTRIBS
         (
         p_x_mr_header_rec             =>p_x_mr_header_rec
         );
        END IF;


        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN
         TRANSLATE_VALUE_ID
         (
         x_return_status             =>x_return_Status,
         p_x_mr_header_rec           =>p_x_mr_header_rec);
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_x_mr_header_rec.DML_OPERATION='C'
        THEN
                p_x_mr_header_rec.mr_status_code:='DRAFT';
                p_x_mr_header_rec.VERSION_NUMBER:=1;
                p_x_mr_header_rec.copy_accomplishment_flag:='N';
        END IF;

        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN
         VALIDATE_MR_HEADER
         (
         x_return_status             =>x_return_Status,
         p_mr_header_rec             =>p_x_mr_header_rec);
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


   -- insert process goes here
     /*
         IF p_x_mr_header_rec.EFFECTIVE_FROM is null or p_x_mr_header_rec.EFFECTIVE_FROM=FND_API.G_MISS_DATE
         THEN
                p_x_mr_header_rec.EFFECTIVE_FROM:=sysdate;
         END IF;
     */
         select AHL_MR_HEADERS_B_S.NEXTVAL INTO p_x_mr_header_rec.mr_header_id  from dual;


         /*
         IF p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG IS NULL OR p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG=FND_API.G_MISS_char
         THEN
          p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG:='N';
         END IF;
     */
         AHL_MR_HEADERS_PKG.INSERT_ROW (
          X_MR_HEADER_ID                        =>p_x_mr_header_rec.mr_header_id,
          X_OBJECT_VERSION_NUMBER               =>1,
          X_TITLE                               =>p_x_mr_header_rec.TITLE,
          X_VERSION_NUMBER                      =>1,
          X_EFFECTIVE_FROM                      =>p_x_mr_header_rec.EFFECTIVE_FROM,
          X_EFFECTIVE_TO                        =>NULL,
          X_REVISION                            =>p_x_mr_header_rec.REVISION,
          X_CATEGORY_CODE                       =>p_x_mr_header_rec.CATEGORY_CODE,
          X_SERVICE_TYPE_CODE                   =>p_x_mr_header_rec.SERVICE_TYPE_CODE,
          X_MR_STATUS_CODE                      =>p_x_mr_header_rec.MR_STATUS_CODE,
          X_IMPLEMENT_STATUS_CODE               =>p_x_mr_header_rec.IMPLEMENT_STATUS_CODE,
          X_REPETITIVE_FLAG                     =>p_x_mr_header_rec.REPETITIVE_FLAG,
          X_SHOW_REPETITIVE_CODE                =>p_x_mr_header_rec.SHOW_REPETITIVE_CODE,
          X_WHICHEVER_FIRST_CODE                =>p_x_mr_header_rec.WHICHEVER_FIRST_CODE,
          X_COPY_ACCOMPLISHMENT_FLAG            =>nvl(p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG,'N'),
          X_PROGRAM_TYPE_CODE                   =>p_x_mr_header_rec.PROGRAM_TYPE_CODE ,
          X_PROGRAM_SUBTYPE_CODE                =>p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE,
          X_ATTRIBUTE_CATEGORY                  =>p_x_mr_header_rec.ATTRIBUTE_CATEGORY,
          X_PRECEDING_MR_HEADER_ID              =>p_x_mr_header_rec.PRECEDING_MR_HEADER_ID,
          X_SERVICE_REQUEST_TEMPLATE_ID         =>p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID,
          X_TYPE_CODE                           =>p_x_mr_header_rec.TYPE_CODE,
          X_DOWN_TIME                           =>p_x_mr_header_rec.DOWN_TIME,
          X_UOM_CODE                            =>p_x_mr_header_rec.UOM_CODE,
          X_DESCRIPTION                         =>p_x_mr_header_rec.DESCRIPTION,
          X_COMMENTS                            =>p_x_mr_header_rec.COMMENTS,
          X_SPACE_CATEGORY_CODE                 =>p_x_mr_header_rec.SPACE_CATEGORY_CODE,
          X_QA_INSPECTION_TYPE_CODE             =>p_x_mr_header_rec.QA_INSPECTION_TYPE_CODE,
          X_BILLING_ITEM_ID                     =>p_x_mr_header_rec.BILLING_ITEM_ID,
          X_AUTO_SIGNOFF_FLAG                   =>nvl(p_x_mr_header_rec.AUTO_SIGNOFF_FLAG,'N'),
          X_COPY_INIT_ACCOMPL_FLAG              =>nvl(p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG,'N'),
          X_COPY_DEFERRALS_FLAG                 =>nvl(p_x_mr_header_rec.COPY_DEFERRALS_FLAG,'N'),
          X_ATTRIBUTE1                          =>p_x_mr_header_rec.ATTRIBUTE1,
          X_ATTRIBUTE2                          =>p_x_mr_header_rec.ATTRIBUTE2,
          X_ATTRIBUTE3                          =>p_x_mr_header_rec.ATTRIBUTE3,
          X_ATTRIBUTE4                          =>p_x_mr_header_rec.ATTRIBUTE4,
          X_ATTRIBUTE5                          =>p_x_mr_header_rec.ATTRIBUTE5,
          X_ATTRIBUTE6                          =>p_x_mr_header_rec.ATTRIBUTE6,
          X_ATTRIBUTE7                          =>p_x_mr_header_rec.ATTRIBUTE7,
          X_ATTRIBUTE8                          =>p_x_mr_header_rec.ATTRIBUTE8,
          X_ATTRIBUTE9                          =>p_x_mr_header_rec.ATTRIBUTE9,
          X_ATTRIBUTE10                         =>p_x_mr_header_rec.ATTRIBUTE10,
          X_ATTRIBUTE11                         =>p_x_mr_header_rec.ATTRIBUTE11,
          X_ATTRIBUTE12                         =>p_x_mr_header_rec.ATTRIBUTE12,
          X_ATTRIBUTE13                         =>p_x_mr_header_rec.ATTRIBUTE13,
          X_ATTRIBUTE14                         =>p_x_mr_header_rec.ATTRIBUTE14,
          X_ATTRIBUTE15                         =>p_x_mr_header_rec.ATTRIBUTE15,
          X_CREATION_DATE                       =>sysdate,
          X_CREATED_BY                          =>fnd_global.user_id,
          X_LAST_UPDATE_DATE                    =>sysdate,
          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);

         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;

         IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO CREATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_HEADER_PVT',
                            p_procedure_name  =>  'CREATE_MR_HEADER',
                            p_error_text      => SUBSTR(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
END;


 PROCEDURE UPDATE_MR_HEADER
 (
 p_api_version               IN         NUMBER:=1.0,
 p_init_msg_list             IN         VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         VARCHAR2:= FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2:= FND_API.G_FALSE ,
 p_module_type               IN         VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_mr_header_rec           IN OUT     NOCOPY  MR_HEADER_REC)
as
 l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_MR_HEADER';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 BEGIN
        SAVEPOINT UPDATE_MR_HEADER_PVT;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;


        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.enable_debug;
            AHL_DEBUG_PUB.debug('Service Category CODE:'||p_x_mr_header_Rec.SPACE_CATEGORY_CODE);
            AHL_DEBUG_PUB.debug('Service Category MEANING :'||p_x_mr_header_Rec.SPACE_CATEGORY);
        END IF;
    --11.5.10 public API change.
    IF p_x_mr_header_rec.mr_header_id IS NULL THEN
      -- Function to convert mr_title,mr_version_number to id
      AHL_FMP_COMMON_PVT.mr_title_version_to_id(
      p_mr_title        =>  p_x_mr_header_rec.title,
      p_mr_version_number   =>  p_x_mr_header_rec.version_number,
      x_mr_header_id    =>  p_x_mr_header_rec.mr_header_id,
      x_return_status   =>  x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
             fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'Title,version to id conversion failed.....'
         );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

        IF FND_API.to_boolean( p_default )
        THEN
         DEFAULT_MISSING_ATTRIBS
         (
         p_x_mr_header_rec             =>p_x_mr_header_rec
         );
        END IF;

       -- Set lov id to null if module is jsp


       IF p_module_type = 'JSP'
       and (p_x_mr_header_rec.MR_Status_code='DRAFT' OR
       p_x_mr_header_rec.MR_Status_code='APPROVAL_REJECTED')
       THEN
                p_x_mr_header_rec.PROGRAM_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=NULL;
                p_x_mr_header_rec.BILLING_ITEM_ID:=NULL;
                p_x_mr_header_rec.QA_INSPECTION_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_TYPE_CODE:=NULL;
                p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE:=NULL;
                p_x_mr_header_rec.PRECEDING_MR_HEADER_ID:=NULL;
       END IF;

       IF p_x_mr_header_rec.DML_OPERATION='U' and p_x_mr_header_rec.MR_STATUS_CODE='APPROVAL_REJECTED'
       THEN
                p_x_mr_header_rec.mr_status_code:='DRAFT';
       END IF;

       -- Convert Value to id.

       IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
       THEN

                TRANSLATE_VALUE_ID
                (
                x_return_status             =>x_return_Status,
                p_x_mr_header_rec           =>p_x_mr_header_rec);
       END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;



        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN

        VALIDATE_MR_HEADER
        (
        x_return_status             =>x_return_Status,
        p_mr_header_rec             =>p_x_mr_header_rec
        );

        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_msg_count     := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        AHL_MR_HEADERS_PKG.UPDATE_ROW (
          X_MR_HEADER_ID                        =>p_x_mr_header_rec.mr_header_id,
          X_OBJECT_VERSION_NUMBER               =>p_x_mr_header_rec.object_version_number,
          X_CATEGORY_CODE                       =>p_x_mr_header_rec.CATEGORY_CODE,
          X_SERVICE_TYPE_CODE                   =>p_x_mr_header_rec.SERVICE_TYPE_CODE,
          X_MR_STATUS_CODE                      =>p_x_mr_header_rec.MR_STATUS_CODE,
          X_IMPLEMENT_STATUS_CODE               =>p_x_mr_header_rec.IMPLEMENT_STATUS_CODE,
          X_REPETITIVE_FLAG                     =>p_x_mr_header_rec.REPETITIVE_FLAG,
          X_SHOW_REPETITIVE_CODE                =>p_x_mr_header_rec.SHOW_REPETITIVE_CODE,
          X_WHICHEVER_FIRST_CODE                =>p_x_mr_header_rec.WHICHEVER_FIRST_CODE,
          X_COPY_ACCOMPLISHMENT_FLAG            =>p_x_mr_header_rec.COPY_ACCOMPLISHMENT_FLAG,
          X_PROGRAM_TYPE_CODE                   =>p_x_mr_header_rec.PROGRAM_TYPE_CODE ,
          X_PROGRAM_SUBTYPE_CODE                =>p_x_mr_header_rec.PROGRAM_SUBTYPE_CODE,
          X_EFFECTIVE_FROM                      =>p_x_mr_header_rec.EFFECTIVE_FROM,
          X_EFFECTIVE_TO                        =>NVL(p_x_mr_header_rec.EFFECTIVE_TO,NULL),
          X_REVISION                            =>p_x_mr_header_rec.REVISION,
          X_ATTRIBUTE_CATEGORY                  =>p_x_mr_header_rec.ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1                          =>p_x_mr_header_rec.ATTRIBUTE1,
          X_ATTRIBUTE2                          =>p_x_mr_header_rec.ATTRIBUTE2,
          X_ATTRIBUTE3                          =>p_x_mr_header_rec.ATTRIBUTE3,
          X_ATTRIBUTE4                          =>p_x_mr_header_rec.ATTRIBUTE4,
          X_ATTRIBUTE5                          =>p_x_mr_header_rec.ATTRIBUTE5,
          X_ATTRIBUTE6                          =>p_x_mr_header_rec.ATTRIBUTE6,
          X_ATTRIBUTE7                          =>p_x_mr_header_rec.ATTRIBUTE7,
          X_ATTRIBUTE8                          =>p_x_mr_header_rec.ATTRIBUTE8,
          X_ATTRIBUTE9                          =>p_x_mr_header_rec.ATTRIBUTE9,
          X_ATTRIBUTE10                         =>p_x_mr_header_rec.ATTRIBUTE10,
          X_ATTRIBUTE11                         =>p_x_mr_header_rec.ATTRIBUTE11,
          X_ATTRIBUTE12                         =>p_x_mr_header_rec.ATTRIBUTE12,
          X_ATTRIBUTE13                         =>p_x_mr_header_rec.ATTRIBUTE13,
          X_ATTRIBUTE14                         =>p_x_mr_header_rec.ATTRIBUTE14,
          X_ATTRIBUTE15                         =>p_x_mr_header_rec.ATTRIBUTE15,
          X_TITLE                               =>p_x_mr_header_rec.TITLE,
          X_VERSION_NUMBER                      =>p_x_mr_header_rec.VERSION_NUMBER,
          X_PRECEDING_MR_HEADER_ID              =>p_x_mr_header_rec.PRECEDING_MR_HEADER_ID,
          X_SERVICE_REQUEST_TEMPLATE_ID         =>p_x_mr_header_rec.SERVICE_REQUEST_TEMPLATE_ID,
          X_TYPE_CODE                           =>p_x_mr_header_rec.TYPE_CODE,
          X_DOWN_TIME                           =>p_x_mr_header_rec.DOWN_TIME,
          X_UOM_CODE                            =>p_x_mr_header_rec.UOM_CODE,
          X_DESCRIPTION                         =>p_x_mr_header_rec.DESCRIPTION,
          X_COMMENTS                            =>p_x_mr_header_rec.COMMENTS,
          X_SPACE_CATEGORY_CODE                 =>p_x_mr_header_rec.SPACE_CATEGORY_CODE,
          X_QA_INSPECTION_TYPE_CODE             =>p_x_mr_header_rec.QA_INSPECTION_TYPE_CODE,
          X_BILLING_ITEM_ID                     =>p_x_mr_header_rec.BILLING_ITEM_ID,
          X_AUTO_SIGNOFF_FLAG                   =>p_x_mr_header_rec.AUTO_SIGNOFF_FLAG,
          X_COPY_INIT_ACCOMPL_FLAG              =>p_x_mr_header_rec.COPY_INIT_ACCOMPL_FLAG,
          X_COPY_DEFERRALS_FLAG                 =>p_x_mr_header_rec.COPY_DEFERRALS_FLAG,
          X_LAST_UPDATE_DATE                    =>sysdate,
          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

    -- Check For Cycli Association

       IF (p_x_mr_header_rec.PRECEDING_MR_HEADER_ID IS NOT NULL OR p_x_mr_header_rec.PRECEDING_MR_HEADER_ID<>fnd_api.g_miss_num) and p_x_mr_header_rec.dml_operation<>'D'
       THEN
                 CHECK_CYCLIC_ASSOCIATION
                 (
                 p_api_version,
                 p_init_msg_list,
                 p_validation_level,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_x_mr_header_rec.MR_HEADER_ID,
                 p_x_mr_header_rec.PRECEDING_MR_HEADER_ID,
                 p_x_mr_header_rec.PRECEDING_MR_TITLE
                 );
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
    -- Debug info

--   AHL_DEBUG_PUB.debug( 'End of Private api UPDATE_MR_HEADER','+MR_header+');

    -- Check if API is called in debug mode. If yes, disable debug.

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
 WHEN OTHERS THEN
    ROLLBACK TO UPDATE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
END;

PROCEDURE VALIDATE_DEL_MR_HEADER
(
p_mr_header_id                  IN      NUMBER,
p_object_version_number         IN      NUMBER,
x_return_status                 OUT NOCOPY    VARCHAR2
)
As
L_ERR_FLAG      NUMBER(2);
L_RETURN_STATUS VARCHAR2(1):='S';
CURSOR GetHeaderDet(C_MR_HEADER_ID NUMBER,C_OBJECT_VERSION_NUMBER NUMBER)
IS
--AMSRINIV.Bug 4916286. Tuning below commented query for improving performance
 SELECT
   mr_status_code
 FROM
   ahl_mr_headers_b
 WHERE
   application_usg_code = RTRIM(LTRIM(fnd_profile.value('AHL_APPLN_USAGE'))) AND
   mr_header_id=C_MR_HEADER_ID AND
   object_version_number=C_OBJECT_VERSION_NUMBER;

/*SELECT MR_STATUS_CODE
FROM AHL_MR_HEADERS_V
WHERE MR_HEADER_ID=C_MR_HEADER_ID
AND OBJECT_VERSION_NUMBER=C_OBJECT_VERSION_NUMBER;*/
l_rec  GetHeaderDet%rowtype;
l_appln_code                   VARCHAR2(30);
BEGIN

        IF G_APPLN_USAGE IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;

        IF P_MR_HEADER_ID IS NULL OR  P_MR_HEADER_ID=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
                FND_MSG_PUB.ADD;
                L_ERR_FLAG:=1;
        END IF;

        IF P_OBJECT_VERSION_NUMBER IS NULL OR  P_OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_OBJECT_VERS_NUM_NULL');
                FND_MSG_PUB.ADD;
                L_ERR_FLAG:=1;
        END IF;

        IF L_ERR_FLAG=1
        THEN
                RETURN;
        END IF;
        Open  GetHeaderDet(P_MR_HEADER_ID,P_OBJECT_VERSION_NUMBER);
        Fetch GetHeaderDet into l_rec;
        If GetHeaderDet%NotFound Then
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_INVALID');
                FND_MSG_PUB.ADD;
        Elsif GetHeaderDet%Found and (l_rec.mr_status_code<>'DRAFT' AND
                                      l_rec.mr_status_code<>'APPROVAL_REJECTED')
        Then
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_MR_STATUS');
                FND_MSG_PUB.ADD;
        End if;
        Close GetHeaderDet;
END;
--

 PROCEDURE DELETE_MR_HEADER
 (
 p_api_version               IN         NUMBER:=1.0,
 p_init_msg_list             IN         VARCHAR2:=FND_API.G_FALSE,
 p_commit                    IN         VARCHAR2:= FND_API.G_FALSE,
 p_validation_level          IN         NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2:= FND_API.G_FALSE ,
 p_module_type               IN         VARCHAR2:=NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_mr_header_id              IN                 NUMBER,
 p_object_version_number     IN                 NUMBER)
as
 l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_MR_HEADER';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 Cursor CurGetRoutes(c_mr_header_id number)
 Is
 Select * from ahl_mr_Routes
 Where mr_header_id=c_mr_header_id;
 l_mr_route_rec CurGetRoutes%rowtype;

 Cursor curGetMrEffects(c_mr_header_id number)
 Is
 Select * from ahl_mr_Effectivities
 Where mr_header_id=c_mr_header_id;
 L_MR_EFFECT_REC    curGetMrEffects%ROWTYPE;

 Cursor curGetMrEffDetls(c_mr_effectivity_id number)
 Is
 Select * from ahl_mr_effectivity_dtls
 Where mr_effectivity_id=c_mr_effectivity_id;

 Cursor curGetMrEffIntervals(c_mr_effectivity_id number)
 Is
 Select * from ahl_mr_intervals
 Where mr_effectivity_id=c_mr_effectivity_id;

 Cursor curGetMrdocAssociations(c_mr_header_id number)
 Is
 Select * from AHL_DOC_TITLE_ASSOS_B
 Where  ASO_OBJECT_ID=C_MR_HEADER_ID
 And    ASO_OBJECT_TYPE_CODE='MR';
 l_mr_doc_rec      curGetMrdocAssociations%rowtype;

 BEGIN
        SAVEPOINT DELETE_MR_HEADER_PVT;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(P_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;


        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
        END IF;

    -- Debug info.
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'AHL_FMP_MR_HEADERS_PVT.','+DELETE_MR_HEADER+');
       END IF;

--       IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
--        THEN
        VALIDATE_DEL_MR_HEADER
        (
        p_mr_header_id                  =>p_mr_header_id,
        p_object_version_number         =>p_object_version_number,
        x_return_status                 =>L_return_Status
        );

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                x_msg_count     := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

--      END IF;

    Open  CurGetRoutes(p_mr_header_id);
    Loop
    fetch CurGetRoutes into l_mr_route_rec;
    if CurGetRoutes%NotFound
    Then
        Exit;
    else
        Delete AHL_MR_ROUTE_SEQUENCES
        WHERE MR_ROUTE_ID=l_mr_route_rec.mr_route_id or
        RELATED_MR_ROUTE_ID=l_mr_route_rec.mr_route_id;

        Delete AHL_MR_ROUTES
        WHERE MR_ROUTE_ID=l_mr_route_rec.mr_route_id;
    End if;
    End loop;
    Close CurGetRoutes;

    Open  CurGetMrEffects(p_mr_header_id);
    Loop
        Fetch CurGetMrEffects into l_mr_effect_Rec;
    If CurGetMrEffects%NotFound
    Then
        Exit;
    Else
        Delete AHL_MR_EFFECTIVITY_DTLS
        Where MR_effectivity_id=l_mr_effect_rec.MR_EFFECTIVITY_ID;

        Delete AHL_MR_INTERVALS
        Where MR_effectivity_id=l_mr_effect_rec.mr_effectivity_id;
        Delete AHL_MR_EFFECTIVITIES
        Where mr_effectivity_id=l_mr_effect_rec.mr_effectivity_id;
    End if;

    End loop;
    Close CurGetMrEffects;

        Open   curGetMrdocAssociations(p_mr_header_id);
        loop
        Fetch  curGetMrdocAssociations into l_mr_doc_rec;
        If     curGetMrdocAssociations%Found
        Then
              Delete from AHL_DOC_TITLE_ASSOS_TL
              Where DOC_TITLE_ASSO_ID    = l_mr_doc_rec.DOC_TITLE_ASSO_ID;

              Delete from AHL_DOC_TITLE_ASSOS_B
              Where DOC_TITLE_ASSO_ID = l_mr_doc_rec.DOC_TITLE_ASSO_ID;
        Elsif curGetMrdocAssociations%NotFound
        Then
                Exit;
        End if;
        End loop;
        Close curGetMrdocAssociations;

    Delete AHL_MR_RELATIONSHIPS
    Where mr_header_id=p_mr_header_id
    or RELATED_MR_HEADER_ID=P_MR_HEADER_ID;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                x_msg_count     := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        AHL_MR_HEADERS_PKG.DELETE_ROW
        (
        X_MR_HEADER_ID  =>p_mr_header_id
        );

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.disable_debug;
        END IF;

         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;
EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.disable_debug;
        END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.disable_debug;
        END IF;

 WHEN OTHERS THEN
    ROLLBACK TO DELETE_MR_HEADER_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.disable_debug;
        END IF;

END DELETE_MR_HEADER;

END AHL_FMP_MR_HEADER_PVT;

/
