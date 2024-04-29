--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_VISIT_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_VISIT_TYPES_PVT" AS
/* $Header: AHLVMRVB.pls 120.2 2005/10/13 04:51:25 tamdas noship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30):= 'AHL_FMP_MR_VISIT_TYPES_PVT';
G_MODULE_NAME           CONSTANT VARCHAR2(60):= 'AHL.PLSQL.AHL_FMP_MR_VISIT_TYPES_PVT';
G_DEBUG                 CONSTANT VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;
G_APPLN_USAGE   	CONSTANT VARCHAR2(30) :=LTRIM(RTRIM(FND_PROFILE.value('AHL_APPLN_USAGE')));

PROCEDURE INSERT_ROW
 (
 p_x_mr_visit_type_rec              IN OUT  NOCOPY mr_visit_type_REC_type
 )
AS
BEGIN
             INSERT INTO AHL_MR_VISIT_TYPES
                          (
                          MR_VISIT_TYPE_ID,
                          OBJECT_VERSION_NUMBER,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_LOGIN,
                          MR_VISIT_TYPE_CODE,
                          MR_HEADER_ID,
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
                          AHL_MR_VISIT_TYPES_S.NEXTVAL,
                          1,
                          SYSDATE,
                          FND_GLOBAL.user_ID,
                          SYSDATE,
                          FND_GLOBAL.USER_ID,
                          FND_GLOBAL.LOGIN_ID,
                          P_X_MR_VISIT_TYPE_REC.MR_VISIT_TYPE_CODE,
                          P_X_MR_VISIT_TYPE_REC.MR_HEADER_ID,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE_CATEGORY,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE1,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE2,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE3,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE4,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE5,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE6,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE7,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE8,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE9,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE10,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE11,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE12,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE13,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE14,
                          P_X_MR_VISIT_TYPE_REC.ATTRIBUTE15)
                          RETURNING MR_VISIT_TYPE_ID INTO P_X_MR_VISIT_TYPE_REC.MR_VISIT_TYPE_ID;

END;

PROCEDURE UPDATE_ROW
 (
 p_mr_visit_type_rec              IN mr_visit_type_REC_type
 )
AS
BEGIN
                UPDATE AHL_MR_VISIT_TYPES
                SET      mr_visit_type_ID                    =P_MR_VISIT_TYPE_REC.mr_visit_type_ID,
                         OBJECT_VERSION_NUMBER               =P_MR_VISIT_TYPE_REC.OBJECT_VERSION_NUMBER+1,
                         MR_HEADER_ID                        =P_MR_VISIT_TYPE_REC.MR_HEADER_ID,
                         mr_visit_type_CODE                  =P_MR_VISIT_TYPE_REC.mr_visit_type_CODE,
                         ATTRIBUTE_CATEGORY                  =P_MR_VISIT_TYPE_REC.ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE1,
                         ATTRIBUTE2                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE2,
                         ATTRIBUTE3                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE3,
                         ATTRIBUTE4                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE4,
                         ATTRIBUTE5                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE5,
                         ATTRIBUTE6                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE6,
                         ATTRIBUTE7                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE7,
                         ATTRIBUTE8                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE8,
                         ATTRIBUTE9                          =P_MR_VISIT_TYPE_REC.ATTRIBUTE9,
                         ATTRIBUTE10                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE10,
                         ATTRIBUTE11                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE11,
                         ATTRIBUTE12                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE12,
                         ATTRIBUTE13                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE13,
                         ATTRIBUTE14                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE14,
                         ATTRIBUTE15                         =P_MR_VISIT_TYPE_REC.ATTRIBUTE15,
                         LAST_UPDATE_DATE                    =sysdate,
                         LAST_UPDATED_BY                     =fnd_global.user_id,
                         LAST_UPDATE_LOGIN                   =fnd_global.login_id
                         WHERE MR_VISIT_TYPE_ID=P_MR_VISIT_TYPE_REC.mr_visit_type_ID
                        and object_version_number=P_MR_VISIT_TYPE_REC.object_version_number;
                  if (sql%ROWCOUNT=0)
                  then
                      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                      FND_MSG_PUB.ADD;
                  end if;

END;

PROCEDURE DELETE_ROW
 (
 p_mr_visit_type_rec              IN  mr_visit_type_REC_type
 )
AS
BEGIN
                  delete from AHL_mr_visit_types
                  where mr_visit_type_ID = p_mr_visit_type_rec .mr_visit_type_ID
                  and object_version_number=p_mr_visit_type_rec .object_version_number;

                  if (sql%ROWCOUNT=0)
                  then
                      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                      FND_MSG_PUB.ADD;
                  end if;
END;



PROCEDURE SORT_RECORDS(p_x_mr_visit_TYPE_TBL IN OUT NOCOPY MR_VISIT_TYPE_TBL_TYPE)
AS
L_mr_visit_type_tbl     mr_visit_type_TBL_type;
L_TEMP_INDEX            NUMBER;
BEGIN
        IF p_x_mr_visit_type_tbl.COUNT >0
        THEN
            L_TEMP_INDEX:=p_x_mr_visit_type_tbl.FIRST;
        END IF;

        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP
                IF  p_x_mr_visit_type_tbl(I).DML_OPERATION='D'
                THEN
                        L_mr_visit_type_tbl(L_TEMP_INDEX):=p_x_mr_visit_type_tbl(I);
                        L_TEMP_INDEX:=L_TEMP_INDEX+1;
                END IF;

        END LOOP;
        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP
                IF p_x_mr_visit_type_tbl(I).DML_OPERATION='U'
                THEN
                        L_mr_visit_type_tbl(L_TEMP_INDEX):=p_x_mr_visit_type_tbl(I);
                        L_TEMP_INDEX:=L_TEMP_INDEX+1;
                END IF;
        END LOOP;

        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP
                IF p_x_mr_visit_type_tbl(I).DML_OPERATION='C'
                THEN
                        L_mr_visit_type_tbl(L_TEMP_INDEX):=p_x_mr_visit_type_tbl(I);
                        L_TEMP_INDEX:=L_TEMP_INDEX+1;
                END IF;
        END LOOP;
	p_x_mr_visit_type_tbl:=l_mr_visit_type_tbl;
END;

PROCEDURE DEFAULT_MISSING_ATTRIBS(p_x_mr_visit_TYPE_TBL IN OUT NOCOPY MR_VISIT_TYPE_TBL_TYPE)
AS
        CURSOR CurMrVisitType(C_MR_VISIT_TYPE_ID NUMBER)
        IS SELECT
        MR_VISIT_TYPE_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        MR_VISIT_TYPE_CODE,
        MR_VISIT_TYPE,
        DESCRIPTION,
        MR_HEADER_ID,
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
        FROM AHL_MR_VISIT_TYPES_V
        WHERE MR_VISIT_TYPE_ID=C_MR_VISIT_TYPE_ID;

l_mrvisittype_rec    CurMrVisitType%rowtype;

BEGIN
        IF p_x_mr_visit_type_tbl.COUNT >0
        THEN
        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP
        IF p_x_mr_visit_type_tbl(i).DML_OPERATION<>'D'
        THEN
                OPEN CurMrVisitType(p_x_mr_visit_type_tbl(i).mr_visit_type_ID);
                fetch CurMrVisitType into l_mrvisittype_rec ;
                CLOSE CurMrVisitType;

                IF p_x_mr_visit_type_tbl(I).MR_HEADER_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_mr_visit_type_tbl(I).MR_HEADER_ID:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).MR_HEADER_ID IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).MR_HEADER_ID:=l_mrVisitType_rec.MR_HEADER_ID;
                END IF;

                IF p_x_mr_visit_type_tbl(I).mr_visit_type_CODE= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).mr_visit_type_CODE:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).mr_visit_type_CODE IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).mr_visit_type_CODE:=l_mrVisitType_rec.mr_visit_type_CODE;
                END IF;

                IF p_x_mr_visit_type_tbl(I).mr_visit_type= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).mr_visit_type:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).mr_visit_type IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).mr_visit_type:=l_mrVisitType_rec.mr_visit_type;
                END IF;

                IF p_x_mr_visit_type_tbl(I).mr_visit_type_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_mr_visit_type_tbl(I).mr_visit_type_ID:=NULL;
                END IF;

                IF p_x_mr_visit_type_tbl(I).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                    p_x_mr_visit_type_tbl(I).OBJECT_VERSION_NUMBER:=null;
                ELSIF p_x_mr_visit_type_tbl(I).OBJECT_VERSION_NUMBER IS NULL
                THEN
                    p_x_mr_visit_type_tbl(I).OBJECT_VERSION_NUMBER:=l_mrVisitType_rec.OBJECT_VERSION_NUMBER;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE_CATEGORY:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE_CATEGORY IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE_CATEGORY:=l_mrVisitType_rec.ATTRIBUTE_CATEGORY;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE1= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE1:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE1 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE1:=l_mrVisitType_rec.ATTRIBUTE1;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE2= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE2:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE2 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE2:=l_mrVisitType_rec.ATTRIBUTE2;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE3= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE3:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE3 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE3:=l_mrVisitType_rec.ATTRIBUTE3;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE4= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE4:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE4 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE4:=l_mrVisitType_rec.ATTRIBUTE4;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE5= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE5:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE5 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE5:=l_mrVisitType_rec.ATTRIBUTE5;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE6= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE6:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE6 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE6:=l_mrVisitType_rec.ATTRIBUTE6;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE7= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE7:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE7 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE7:=l_mrVisitType_rec.ATTRIBUTE7;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE8= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE8:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE8 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE8:=l_mrVisitType_rec.ATTRIBUTE8;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE9= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE9:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE9 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE9:=l_mrVisitType_rec.ATTRIBUTE9;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE10= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE10:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE10 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE10:=l_mrVisitType_rec.ATTRIBUTE10;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE11= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE11:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE11 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE11:=l_mrVisitType_rec.ATTRIBUTE11;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE12= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE12:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE12 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE12:=l_mrVisitType_rec.ATTRIBUTE12;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE13= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE13:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE13 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE13:=l_mrVisitType_rec.ATTRIBUTE13;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE14= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE14:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE14 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE14:=l_mrVisitType_rec.ATTRIBUTE14;
                END IF;

                IF p_x_mr_visit_type_tbl(I).ATTRIBUTE15= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE15:=NULL;
                ELSIF p_x_mr_visit_type_tbl(I).ATTRIBUTE15 IS NULL
                THEN
                        p_x_mr_visit_type_tbl(I).ATTRIBUTE15:=l_mrVisitType_rec.ATTRIBUTE15;
                END IF;
        END IF;

        END LOOP;
        END IF;
END;

--Tranlate Value to id.

PROCEDURE TRANS_VALUE_ID
 (
 p_x_mr_visit_type_rec              IN OUT  NOCOPY mr_visit_type_REC_type
 )
as
CURSOR get_lookup_meaning_to_code(c_lookup_type VARCHAR2,c_meaning  VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(ltrim(rtrim(meaning)))=upper(ltrim(rtrim(c_meaning)))
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);
BEGIN

        IF p_x_mr_visit_type_rec.mr_visit_type is  null
        OR p_x_mr_visit_type_rec.mr_visit_type=FND_API.G_MISS_CHAR
        THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRVSTTYPE_CODE_NULL');
                     FND_MSG_PUB.ADD;
        ELSE
                 OPEN  get_lookup_meaning_to_code('AHL_PLANNING_VISIT_TYPE',p_x_mr_visit_type_rec.mr_visit_type);
                 FETCH get_lookup_meaning_to_code INTO p_x_mr_visit_type_rec.mr_visit_type_CODE;

                 IF get_lookup_meaning_to_code%NOTFOUND
                 THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRVSTYPE_CODE_INVALID');
                     FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_visit_type_rec.mr_visit_type,false);
                     FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_lookup_meaning_to_code;
        END IF;
 END;

PROCEDURE VALIDATE_MR_VISIT_TYPES
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_mr_visit_type_rec            IN  mr_visit_type_REC_type
 )
as
CURSOR get_visit_id(c_mr_visit_type_id  NUMBER,C_OBJECT_VERSION_NUMBER NUMBER)
 IS
SELECT mr_visit_type_ID
   FROM AHL_MR_VISIT_TYPES_app_v
   WHERE mr_visit_type_ID=c_mr_visit_type_id
   AND   OBJECT_VERSION_NUMBER=C_OBJECT_VERSION_NUMBER
   for update;

 CURSOR GetMrDet(c_mr_header_id  NUMBER )
 IS
  SELECT MR_STATUS_CODE,IMPLEMENT_STATUS_CODE
   FROM AHL_MR_HEADERS_APP_V
   WHERE MR_HEADER_ID=c_mr_header_id
   and MR_STATUS_CODE IN('DRAFT','APPROVAL_REJECTED');


 l_mr_rec                GetMrDet%rowtype;

 CURSOR CHECK_DUP_VISIT_CODE(c_mr_visit_type_code VARCHAR2,c_mr_header_id  NUMBER)
 IS
  SELECT MR_VISIT_TYPE_CODE,MR_VISIT_TYPE_ID,MR_HEADER_ID
   FROM AHL_mr_visit_typeS_app_v
   WHERE MR_HEADER_ID=c_mr_header_id
   and   MR_VISIT_TYPE_CODE=c_mr_visit_type_CODE;

    -- Tamal [MEL/CDL] -- Begin changes
    CURSOR check_mo_proc
    (
        c_mr_header_id number
    )
    IS
    SELECT  'x'
    FROM    ahl_mr_headers_b
    WHERE   mr_header_id = c_mr_header_id AND
            program_type_code = 'MO_PROC';

    l_dummy_char            VARCHAR2(1);
    -- Tamal [MEL/CDL] -- End changes

 l_act_rec               CHECK_DUP_VISIT_CODE%ROWTYPE;
 l_mr_visit_type_id          NUMBER:=0;
 BEGIN
     x_return_status:=FND_API.G_RET_STS_SUCCESS;

	-- Check Profile value
        IF (G_APPLN_USAGE IS NULL)
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
  	ELSIF (G_APPLN_USAGE = 'PM')
	THEN
    		FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_MRV_PM_INSTALL' );
    		FND_MSG_PUB.add;
    		x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
  	END IF;

     IF (p_mr_visit_type_rec.mr_visit_type_ID IS NULL OR p_mr_visit_type_rec.mr_visit_type_ID=FND_API.G_MISS_NUM)
     AND p_mr_visit_type_rec.dml_operation<>'C'
     THEN
                 FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_VSTYPE_ID_NULL');
                 FND_MSG_PUB.ADD;
     END IF;

     IF (p_mr_visit_type_rec.mr_visit_type_ID IS NOT NULL and p_mr_visit_type_rec.mr_visit_type_ID<>FND_API.G_MISS_NUM)
     AND p_mr_visit_type_rec.dml_operation<>'C'
     THEN
         OPEN  get_visit_id(p_mr_visit_type_rec.mr_visit_type_id ,p_mr_visit_type_rec.object_version_number) ;
         FETCH get_visit_id INTO l_mr_visit_type_id;

         IF GET_VISIT_ID%NOTFOUND
         THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
         END IF;
         CLOSE get_visit_id;
     END IF;

     IF (p_mr_visit_type_rec.OBJECT_VERSION_NUMBER IS NULL OR p_mr_visit_type_rec.OBJECT_vERSION_NUMBER=FND_API.G_MISS_num)
     and p_mr_visit_type_rec.dml_operation<>'C'
     THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRA_OBJ_VERSION_NULL');
                FND_MSG_PUB.ADD;
     END IF;

     IF p_mr_visit_type_rec.MR_HEADER_ID IS NULL OR p_mr_visit_type_rec.MR_HEADER_ID=FND_API.G_MISS_NUM
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
        FND_MSG_PUB.ADD;
     ELSE
        OPEN GetMrDet(p_mr_visit_type_rec.MR_HEADER_ID);

        FETCH GetMrDet  into l_mr_rec;

        IF GetMrDet%NOTFOUND
        THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EDIT_STATUS_INVALID');
            FND_MSG_PUB.ADD;
        ELSE
           IF l_mr_rec.IMPLEMENT_STATUS_CODE<>'OPTIONAL_DO_NOT_IMPLEMENT'
           AND p_mr_visit_type_rec.dml_operation<>'D'
           THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_NOTOPT_DONOT_IMPL');
                        FND_MSG_PUB.ADD;
           END IF;
         NULL;
        END IF;
        CLOSE GetMrDet;
     END IF;

     IF  p_mr_visit_type_rec.dml_operation<>'D'
     THEN

             OPEN CHECK_DUP_VISIT_CODE(p_mr_visit_type_rec.mr_visit_type_CODE,p_mr_visit_type_rec.MR_HEADER_ID);
             FETCH CHECK_DUP_VISIT_CODE  into l_act_Rec;

             IF  CHECK_DUP_VISIT_CODE%FOUND
             THEN
                     IF  p_mr_visit_type_rec.dml_operation='C'
                     THEN
                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRVSTYOE_CODE_DUP');
                          FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_mr_visit_type_rec.mr_visit_type,'')||'-''-',false);
                          FND_MSG_PUB.ADD;
                     ELSIF  p_mr_visit_type_rec.dml_operation='U'
                            and l_act_Rec.mr_visit_type_id<>p_mr_visit_type_rec.mr_visit_type_ID
                     THEN
                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRVSTYPE_CODE_DUP');
                          FND_MESSAGE.SET_TOKEN('RECORD',p_mr_visit_type_rec.mr_visit_type,false);
                          FND_MSG_PUB.ADD;
                     END IF;
             END IF;
             CLOSE CHECK_DUP_VISIT_CODE;

            -- Tamal [MEL/CDL] -- Begin changes
            OPEN check_mo_proc(p_mr_visit_type_rec.MR_HEADER_ID);
            FETCH check_mo_proc INTO l_dummy_char;
            IF (check_mo_proc%FOUND)
            THEN
                FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MRV_MO_PROC');
                -- Cannot associate visit types to a Maintenance Requirement of (M) and (0) procedure program type.
                FND_MSG_PUB.ADD;
            END IF;
            -- Tamal [MEL/CDL] -- End changes

     END IF;
END;

PROCEDURE PROCESS_MR_VISIT_TYPES
 (
 p_api_version               IN    		NUMBER,
 p_init_msg_list             IN     		VARCHAR2 := FND_API.G_FALSE,
 p_commit                    IN     		VARCHAR2 := FND_API.G_FALSE,
 p_validation_level          IN     		NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN     		VARCHAR2 := FND_API.G_FALSE,
 p_module_type               IN                 VARCHAR2,
 x_return_status             OUT NOCOPY                VARCHAR2,
 x_msg_count                 OUT NOCOPY                NUMBER,
 x_msg_data                  OUT NOCOPY                VARCHAR2,
 p_x_mr_visit_type_tbl       IN OUT NOCOPY      mr_visit_type_TBL_TYPE
 )

as
 l_api_name    CONSTANT VARCHAR2(30):= 'PROCESS_MR_VISIT_TYPES';
 l_api_version          NUMBER:=1.0;
 l_mr_visit_type_ID     NUMBER:=0;
 BEGIN
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string(fnd_log.level_procedure,
                      'ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.process_mr_visit_types',
                      'At the start of PLSQL procedure process_mr_visit_types');
        END IF;



        SAVEPOINT process_mr_visit_types_pvt;

   --   Standard call to check for call compatibility.

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,p_api_version,l_api_name,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   --   Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

   --   Initialize API return status to success

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_x_mr_visit_type_tbl.COUNT <1
        THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                THEN
                fnd_log.string(fnd_log.level_statement,
                               'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.process_mr_visit_types',
                               'Nothing to  process as p_x_mr_visit_type_tbl.COUNT is :'||p_x_mr_visit_type_tbl.COUNT);
                END IF;
                --RETURN; -- NOTHING TO PROCESS
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
        fnd_log.string(fnd_log.level_statement,
                       'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.sort_records',
                       'IF P_MODULE_TYPE IS JSP SET LOV IDS TO NULLIFY ');
        END IF;


        IF p_module_type = 'JSP' AND p_x_mr_visit_type_tbl.COUNT >0
        THEN
                FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
                LOOP
                        if p_x_mr_visit_type_tbl(i).dml_operation<>'D'
                        then
                                p_x_mr_visit_type_tbl(i).mr_visit_type_code:=NULL;
                        end if;
                --p_x_mr_visit_type_tbl(i).mr_visit_type_code:=FND_API.G_MISS_CHAR;
                END LOOP;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
        fnd_log.string(fnd_log.level_statement,
                       'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.DEFAULT_MISSING_ATTRIBS',
                       'Start of DEFAULT_MISSING_ATTRIBS');
        END IF;

         DEFAULT_MISSING_ATTRIBS
         (
         p_x_mr_visit_type_tbl             =>p_x_mr_visit_type_tbl
         );


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
        fnd_log.string(fnd_log.level_statement,
                       'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.DEFAULT_MISSING_ATTRIBS',
                       'End of DEFAULT_MISSING_ATTRIBS');
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
        fnd_log.string(fnd_log.level_statement,
                       'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.sort_records',
                       'Start of SORT_RECORDS');
        END IF;

        SORT_RECORDS(p_x_mr_visit_type_tbl);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
        fnd_log.string(fnd_log.level_statement,
                       'Ahl.plsql.AHL_FMP_MR_VISIT_TYPES_PVT.sort_records',
                       'End of SORT_RECORDS');
        END IF;

        -- No need to translate meaning to id if dml operation is delete.
        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP

        IF p_x_mr_visit_type_tbl(i).DML_OPERATION<>'D'
        THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                THEN
                fnd_log.string(fnd_log.level_statement,
                               'Local procedure TRANS_VALUE_ID',
                               'Start of TRANS_VALUE_ID');
                END IF;

                 TRANS_VALUE_ID
                 (
                 p_x_mr_visit_type_rec   =>p_x_mr_visit_type_tbl(i)
                 );

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                THEN
                fnd_log.string(fnd_log.level_statement,
                               'Local procedure TRANS_VALUE_ID',
                               'End of TRANS_VALUE_ID');
                END IF;

        END IF;

        END LOOP;

        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                THEN
                fnd_log.string(fnd_log.level_statement,
                               'Local procedure TRANS_VALUE_ID',
                               'End of TRANS_VALUE_ID');
                END IF;

           RAISE FND_API.G_EXC_ERROR;
        END IF;


   --Start of API Body

        FOR i IN  p_x_mr_visit_type_tbl.FIRST.. p_x_mr_visit_type_tbl.LAST
        LOOP

         --IF p_x_mr_visit_type_tbl(i).dml_operation<>'D'
         --THEN
                VALIDATE_MR_VISIT_TYPES
                (
                x_return_status             =>x_return_Status,
                p_mr_visit_type_rec         =>p_x_mr_visit_type_tbl(I)
                );

         --END IF;

         x_msg_count := FND_MSG_PUB.count_msg;

             IF p_x_mr_visit_type_tbl(i).DML_OPERATION='D'  AND x_msg_count <1
             THEN

                        DELETE_ROW (p_x_mr_visit_type_tbl(i) );
             ELSIF p_x_mr_visit_type_tbl(i).DML_operation='U' AND x_msg_count <1
             THEN
                   UPDATE_ROW (p_x_mr_visit_type_tbl(i) );
             ELSIF p_x_mr_visit_type_tbl(i).DML_operation='C' AND x_msg_count <1
             THEN
                   INSERT_ROW (p_x_mr_visit_type_tbl(i) );
             END IF;
        END LOOP;

        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(p_commit)
        THEN
            COMMIT;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_mr_visit_types_pvt;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_mr_visit_types_pvt;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO process_mr_visit_types_pvt;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>l_api_name,
                            p_error_text      =>SUBSTR(SQLERRM,1,240)
                            );
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;
END AHL_FMP_MR_VISIT_TYPES_PVT;

/
