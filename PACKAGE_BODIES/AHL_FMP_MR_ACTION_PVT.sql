--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_ACTION_PVT" AS
/* $Header: AHLVMRAB.pls 115.19 2003/10/20 19:36:45 sikumar noship $ */
G_PKG_NAME  VARCHAR2(30):= 'AHL_FMP_MR_ACTION_PVT';
G_PM_INSTALL            VARCHAR2(30):=ahl_util_pkg.is_pm_installed;
--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE DEFAULT_MISSING_ATTRIBS(p_x_mr_action_tbl IN OUT NOCOPY AHL_FMP_MR_ACTION_PVT.MR_ACTION_TBL)
AS
 CURSOR CurAction(C_MR_ACTION_ID NUMBER)
 IS
 SELECT * FROM AHL_MR_ACTIONS_V
        WHERE MR_ACTION_ID=C_MR_ACTION_ID;

 l_action_rec    CurAction%rowtype;
BEGIN
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;
        IF P_X_MR_ACTION_TBL.COUNT >0
        THEN
        FOR i IN  P_X_MR_ACTION_TBL.FIRST.. P_X_MR_ACTION_TBL.LAST
        LOOP
        IF p_x_mr_action_TBL(i).DML_OPERATION<>'D'
        THEN

                OPEN CurAction (p_x_mr_action_TBL(i).MR_ACTION_ID);
                        fetch CurAction into l_action_rec;
                CLOSE CurAction;

                IF p_x_mr_action_TBL(I).MR_HEADER_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_mr_action_TBL(I).MR_HEADER_ID:=NULL;
                ELSIF p_x_mr_action_TBL(I).MR_HEADER_ID IS NULL
                THEN
                        p_x_mr_action_TBL(I).MR_HEADER_ID:=l_action_rec.MR_HEADER_ID;
                END IF;

                IF p_x_mr_action_TBL(I).MR_ACTION_CODE= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).MR_ACTION_CODE:=NULL;
                ELSIF p_x_mr_action_TBL(I).MR_ACTION_CODE IS NULL
                THEN
                        p_x_mr_action_TBL(I).MR_ACTION_CODE:=l_action_rec.MR_ACTION_CODE;
                END IF;

                IF p_x_mr_action_TBL(I).MR_ACTION= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).MR_ACTION:=NULL;
                ELSIF p_x_mr_action_TBL(I).MR_ACTION IS NULL
                THEN
                        p_x_mr_action_TBL(I).MR_ACTION:=l_action_rec.MR_ACTION;
                END IF;

                IF p_x_mr_action_TBL(I).MR_ACTION_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_mr_action_TBL(I).MR_ACTION_ID:=NULL;
                END IF;

                IF p_x_mr_action_TBL(I).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                    p_x_mr_action_TBL(I).OBJECT_VERSION_NUMBER:=null;
                ELSIF p_x_mr_action_TBL(I).OBJECT_VERSION_NUMBER IS NULL
                THEN
                    p_x_mr_action_TBL(I).OBJECT_VERSION_NUMBER:=l_action_rec.OBJECT_VERSION_NUMBER;
                END IF;

                IF p_x_mr_action_TBL(I).PLAN= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).PLAN:=NULL;
                ELSIF p_x_mr_action_TBL(I).PLAN IS NULL
                THEN
                        p_x_mr_action_TBL(I).PLAN:=l_action_rec.PLAN_name;
                END IF;


                IF p_x_mr_action_TBL(I).PLAN_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_mr_action_TBL(I).PLAN_ID:=NULL;
                ELSIF p_x_mr_action_TBL(I).PLAN_ID IS NULL
                THEN
                        p_x_mr_action_TBL(I).PLAN_ID:=l_action_rec.PLAN_ID;
                END IF;

                IF p_x_mr_action_TBL(I).PLAN= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).PLAN:=NULL;
                ELSIF p_x_mr_action_TBL(I).PLAN IS NULL
                THEN
                        p_x_mr_action_TBL(I).PLAN:=l_action_rec.PLAN_NAME;
                END IF;

                IF p_x_mr_action_TBL(I).DESCRIPTION= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).DESCRIPTION:=NULL;
                ELSIF p_x_mr_action_TBL(I).DESCRIPTION IS NULL
                THEN
                        p_x_mr_action_TBL(I).DESCRIPTION:=l_action_rec.DESCRIPTION;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE_CATEGORY:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE_CATEGORY IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE_CATEGORY:=l_action_rec.ATTRIBUTE_CATEGORY;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE1= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE1:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE1 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE1:=l_action_rec.ATTRIBUTE1;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE2= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE2:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE2 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE2:=l_action_rec.ATTRIBUTE2;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE3= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE3:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE3 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE3:=l_action_rec.ATTRIBUTE3;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE4= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE4:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE4 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE4:=l_action_rec.ATTRIBUTE4;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE5= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE5:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE5 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE5:=l_action_rec.ATTRIBUTE5;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE6= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE6:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE6 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE6:=l_action_rec.ATTRIBUTE6;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE7= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE7:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE7 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE7:=l_action_rec.ATTRIBUTE7;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE8= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE8:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE8 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE8:=l_action_rec.ATTRIBUTE8;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE9= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE9:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE9 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE9:=l_action_rec.ATTRIBUTE9;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE10= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE10:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE10 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE10:=l_action_rec.ATTRIBUTE10;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE11= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE11:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE11 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE11:=l_action_rec.ATTRIBUTE11;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE12= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE12:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE12 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE12:=l_action_rec.ATTRIBUTE12;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE13= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE13:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE13 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE13:=l_action_rec.ATTRIBUTE13;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE14= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE14:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE14 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE14:=l_action_rec.ATTRIBUTE14;
                END IF;

                IF p_x_mr_action_TBL(I).ATTRIBUTE15= FND_API.G_MISS_CHAR
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE15:=NULL;
                ELSIF p_x_mr_action_TBL(I).ATTRIBUTE15 IS NULL
                THEN
                        p_x_mr_action_TBL(I).ATTRIBUTE15:=l_action_rec.ATTRIBUTE15;
                END IF;
        END IF;
        END LOOP;
        END IF;
END;

--Tranlate Value to id.

PROCEDURE TRANS_VALUE_ID
 (
 x_return_status                OUT NOCOPY     VARCHAR2,
 p_x_mr_action_rec              IN OUT  NOCOPY MR_ACTION_REC
 )
as
CURSOR get_lookup_meaning_to_code(c_lookup_type VARCHAR2,c_meaning  VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(meaning)=upper(c_meaning)
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

CURSOR get_planid_frm_name(c_plan_name  VARCHAR2)
 IS
SELECT plan_id
   FROM QA_PLANS
   WHERE upper(name)=upper(c_plan_name)
   AND sysdate between EFFECTIVE_FROM
   AND nvl(EFFECTIVE_TO,sysdate);
BEGIN

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;

        IF p_x_mr_action_rec.mr_action is  null  OR p_x_mr_action_rec.mr_action=FND_API.G_MISS_CHAR
        THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACTION_CODE_NULL');
                     FND_MSG_PUB.ADD;
        ELSE
                 OPEN  get_lookup_meaning_to_code('AHL_FMP_MR_ACTION',p_x_mr_action_rec.MR_ACTION);
                 FETCH get_lookup_meaning_to_code INTO p_x_mr_action_rec.MR_ACTION_CODE;

                 IF get_lookup_meaning_to_code%NOTFOUND
                 THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACTION_CODE_INVALID');
                     FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_action_rec.MR_ACTION,false);
                     FND_MESSAGE.SET_TOKEN('RECORD',nvl(p_x_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_x_mr_action_rec.description,'')||'-'||NVL(p_x_mr_action_rec.plan,''),false);
                     FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_lookup_meaning_to_code;
        END IF;

        IF (p_x_mr_action_rec.plan is null  OR p_x_mr_action_rec.plan=FND_API.G_MISS_CHAR)
        THEN
                 p_x_mr_action_rec.PLAN:=FND_API.G_MISS_CHAR;
                 p_x_mr_action_rec.PLAN_ID:=FND_API.G_MISS_NUM;
        ELSE
                 OPEN  get_planid_frm_name(p_x_mr_action_rec.PLAN);
                 FETCH get_planid_frm_name INTO p_x_mr_action_rec.PLAN_ID;
                 IF get_planid_frm_name%NOTFOUND
                 THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PLAN_ID_INVALID');
                     FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_action_rec.MR_ACTION,false);
                     FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_x_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_x_mr_action_rec.description,'')||'-'||NVL(p_x_mr_action_rec.plan,''),false);
                     FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_planid_frm_name;

        END IF;
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;
 END;

PROCEDURE VALIDATE_MR_ACTION
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_mr_action_rec                IN  MR_ACTION_REC
 )
as
CURSOR get_ACTION_id(c_mr_action_id  NUMBER)
 IS
SELECT MR_ACTION_ID
   FROM AHL_MR_ACTIONS_B
   WHERE MR_ACTION_ID=c_mr_action_id;

 CURSOR GetMrDet(c_mr_header_id  NUMBER )
 IS
 SELECT MR_STATUS_CODE,nvl(TYPE_CODE,'X') TYPE_CODE
   FROM AHL_MR_HEADERS_B
   WHERE MR_HEADER_ID=c_mr_header_id
   and MR_STATUS_CODE IN('DRAFT','APPROVAL_REJECTED');

 l_mr_rec                GetMrDet%rowtype;

 CURSOR CHECK_DUP_ACTION_CODE(c_mr_action_code VARCHAR2,c_mr_header_id  NUMBER)
 IS
 SELECT *
   FROM AHL_MR_ACTIONS_B
   WHERE MR_HEADER_ID=c_mr_header_id
   and   MR_ACTION_CODE=c_MR_ACTION_CODE;

 l_act_rec               CHECK_DUP_ACTION_CODE%ROWTYPE;
 l_mr_action_id          NUMBER:=0;
 BEGIN

	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;

     x_return_status:=FND_API.G_RET_STS_SUCCESS;

     IF p_mr_action_rec.dml_operation<>'C'
     THEN
             IF (p_mr_action_rec.MR_ACTION_ID IS NULL OR p_mr_action_rec.MR_ACTION_ID=FND_API.G_MISS_NUM)
             THEN
                 FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACTION_ID_NULL');
                 FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_mr_action_rec.description,'')||'-'||NVL(p_mr_action_rec.plan,''),false);
                 FND_MSG_PUB.ADD;
             END IF;
     END IF;

     IF (p_mr_action_rec.MR_ACTION_ID IS NOT NULL OR p_mr_action_rec.MR_ACTION_ID<>FND_API.G_MISS_NUM) AND p_mr_action_rec.dml_operation<>'C'
     THEN
         OPEN  get_ACTION_id(p_mr_action_rec.mr_action_id) ;
         FETCH get_ACTION_id INTO l_mr_action_id;

         IF GET_ACTION_ID%NOTFOUND
         THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_RECORD_CHANGED');
                 FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_mr_action_rec.description,'')||'-'||NVL(p_mr_action_rec.plan,''),false);
                FND_MSG_PUB.ADD;
         END IF;
         CLOSE get_ACTION_id;
     END IF;

     IF (p_mr_action_rec.OBJECT_VERSION_NUMBER IS NULL OR p_mr_action_rec.OBJECT_vERSION_NUMBER=FND_API.G_MISS_num)
     THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRA_OBJ_VERSION_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_mr_action_rec.description,'')||'-'||NVL(p_mr_action_rec.plan,''),false);
                FND_MSG_PUB.ADD;
     END IF;

     IF p_mr_action_rec.dml_operation<>'D'
     THEN

             IF p_mr_action_rec.MR_HEADER_ID IS NULL OR p_mr_action_rec.MR_HEADER_ID=FND_API.G_MISS_NUM
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
                FND_MSG_PUB.ADD;
             ELSE
                OPEN GetMrDet(p_mr_action_rec.MR_HEADER_ID);

                FETCH GetMrDet  into l_mr_rec;

                IF GetMrDet%NOTFOUND
                THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EDIT_STATUS_INVALID');
                    FND_MSG_PUB.ADD;
                ELSE
                     IF G_PM_INSTALL='Y'
                     THEN
                        IF l_mr_rec.TYPE_CODE='PROGRAM'
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TYPE_CODE_PROGRAM');
                                FND_MSG_PUB.ADD;
                        END IF;
                     END IF;
                END IF;
                CLOSE GetMrDet;
             END IF;

             OPEN CHECK_DUP_ACTION_CODE(p_mr_action_rec.MR_ACTION_CODE,p_mr_action_rec.MR_HEADER_ID);
             FETCH CHECK_DUP_ACTION_CODE  into l_act_Rec;

             IF  CHECK_DUP_ACTION_CODE%FOUND
             THEN
                     IF  p_mr_action_rec.dml_operation='C'
                     THEN
                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACTION_CODE_DUP');
                          FND_MESSAGE.SET_TOKEN('RECORD',NVL(p_mr_action_rec.MR_ACTION,'')||'-'||NVL(p_mr_action_rec.description,'')||'-'||NVL(p_mr_action_rec.plan,''),false);
                          FND_MSG_PUB.ADD;
                     ELSIF  p_mr_action_rec.dml_operation='U'
                            and l_act_Rec.mr_action_id<>p_mr_action_rec.MR_ACTION_ID
                     THEN
                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ACTION_CODE_DUP');
                          FND_MESSAGE.SET_TOKEN('ACTION',p_mr_action_rec.MR_ACTION,false);
                          FND_MSG_PUB.ADD;
                     END IF;
             END IF;
             CLOSE CHECK_DUP_ACTION_CODE;
        END IF;
END;

PROCEDURE PROCESS_MR_ACTION
 (
 p_api_version               IN     		NUMBER   := 1.0,
 p_init_msg_list             IN     		VARCHAR2 := FND_API.G_TRUE,
 p_commit                    IN     		VARCHAR2 := FND_API.G_FALSE,
 p_validation_level          IN     		NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN     		VARCHAR2 := FND_API.G_FALSE,
 p_module_type               IN    		VARCHAR2 := NULL,
 x_return_status             OUT NOCOPY                VARCHAR2,
 x_msg_count                 OUT NOCOPY                NUMBER,
 x_msg_data                  OUT NOCOPY                VARCHAR2,
 p_x_mr_ACTION_TBL           IN OUT NOCOPY 	MR_ACTION_TBL
 )
as
 l_api_name     CONSTANT VARCHAR2(30):= 'PROCESS_MR_ACTION';
 l_api_version  CONSTANT NUMBER:= 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_rowid                 VARCHAR2(30):=fnd_api.g_miss_char;
 l_MR_ACTION_ID          NUMBER:=0;
 l_mr_action_rec         MR_ACTION_REC;
 BEGIN
        SAVEPOINT PROCESS_MR_ACTION;

   --   Standard call to check for call compatibility.

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                         p_api_version,
                                         l_api_name,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   --   Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_boolean(l_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

   --   Initialize API return status to success

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

   --   Enable Debug

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Enter PROCESS_MR_ACTION','+FMP_ACTION+');
	END IF;

        IF p_module_type = 'JSP'
        THEN
                FOR i IN  P_X_MR_ACTION_TBL.FIRST.. P_X_MR_ACTION_TBL.LAST
                LOOP
                        p_x_mr_ACTION_TBL(i).mr_action_code:=FND_API.G_MISS_CHAR;
                        p_x_mr_ACTION_TBL(i).plan_id:=FND_API.G_MISS_NUM;
                        if p_x_mr_ACTION_TBL(i).dml_operation='C'
                        then
                                p_x_mr_ACTION_TBL(i).OBJECT_VERSION_NUMBER:=1;
                        end if;
                END LOOP;
        END IF;

        -- No need to translate meaning to id if dml operation is delete.
        FOR i IN  P_X_MR_ACTION_TBL.FIRST.. P_X_MR_ACTION_TBL.LAST
        LOOP

        IF p_x_mr_ACTION_TBL(i).DML_OPERATION<>'D'
        THEN
                l_mr_action_rec:=p_x_mr_ACTION_TBL(i);

                 TRANS_VALUE_ID
                 (
                 x_return_status             =>x_return_Status,
                 p_x_mr_action_rec           =>l_mr_action_rec);

                 p_x_mr_ACTION_TBL(i).mr_Action_code:=l_mr_action_rec.mr_Action_code;
                 p_x_mr_ACTION_TBL(i).plan_id:=l_mr_action_rec.plan_id;
         END IF;


        END LOOP;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.to_boolean(p_default)
        THEN
         DEFAULT_MISSING_ATTRIBS
         (
         p_x_mr_action_tbl             =>p_x_mr_action_tbl
         );
        END IF;


   --Start of API Body

        FOR i IN  P_X_MR_ACTION_TBL.FIRST.. P_X_MR_ACTION_TBL.LAST
        LOOP

         x_return_status:=FND_API.G_RET_STS_SUCCESS;

         IF l_mr_action_rec.dml_operation<>'D'
         THEN

         IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
         THEN

                 VALIDATE_MR_ACTION
                 (
                 x_return_status             =>x_return_Status,
                 p_mr_action_rec             =>P_X_MR_ACTION_TBL(I));

         END IF;

         END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;

             IF p_x_mr_ACTION_TBL(i).DML_OPERATION='D' then

                  delete from AHL_MR_ACTIONS_TL
                  where MR_ACTION_ID = p_x_mr_ACTION_TBL(i).MR_ACTION_ID;

                  if (sql%ROWCOUNT=0)
                  then
                      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                      FND_MSG_PUB.ADD;
                   else
                     delete from AHL_MR_ACTIONS_B
                     where MR_ACTION_ID = p_x_mr_ACTION_TBL(i).MR_ACTION_ID
                     AND OBJECT_VERSION_NUMBER=p_x_mr_ACTION_TBL(i).OBJECT_VERSION_NUMBER;

                          if (sql%ROWCOUNT=0) then
                                     FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                                     FND_MSG_PUB.ADD;
                          end if;
                  end if;
             ELSIF p_x_mr_ACTION_TBL(i).DML_operation='U' then

             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN
                AHL_MR_ACTIONS_PKG.UPDATE_ROW (
                          X_MR_ACTION_ID                        =>p_x_mr_ACTION_TBL(i).MR_ACTION_ID,
                          X_OBJECT_VERSION_NUMBER               =>p_x_mr_ACTION_TBL(i).OBJECT_VERSION_NUMBER,
                          X_MR_HEADER_ID                        =>p_x_mr_ACTION_TBL(i).MR_HEADER_ID,
                          X_MR_ACTION_CODE                      =>p_x_mr_ACTION_TBL(i).MR_ACTION_CODE,
                          X_PLAN_ID                             =>p_x_mr_ACTION_TBL(i).PLAN_ID,
                          X_DESCRIPTION                         =>p_x_mr_ACTION_TBL(i).DESCRIPTION,
                          X_ATTRIBUTE_CATEGORY                  =>p_x_mr_ACTION_TBL(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE15,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                        END IF;
             ELSIF p_x_mr_ACTION_TBL(i).DML_operation='C' then

             SELECT AHL_MR_ACTIONS_B_S.NEXTVAL
                    INTO  l_MR_ACTION_ID
                    FROM DUAL;
             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN
             AHL_MR_ACTIONS_PKG.INSERT_ROW (
                          X_ROWID                               =>l_ROWID,
                          X_MR_ACTION_ID                        =>l_MR_ACTION_ID,
                          X_OBJECT_VERSION_NUMBER               =>1,
                          X_MR_HEADER_ID                        =>p_x_mr_ACTION_TBL(i).MR_HEADER_ID,
                          X_MR_ACTION_CODE                      =>p_x_mr_ACTION_TBL(i).MR_ACTION_CODE,
                          X_PLAN_ID                             =>p_x_mr_ACTION_TBL(i).PLAN_ID,
                          X_DESCRIPTION                         =>p_x_mr_ACTION_TBL(i).DESCRIPTION,
                          X_ATTRIBUTE_CATEGORY                  =>p_x_mr_ACTION_TBL(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>p_x_mr_ACTION_TBL(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>p_x_mr_ACTION_TBL(i).ATTRIBUTE15,
                          X_CREATION_DATE                       =>sysdate,
                          X_CREATED_BY                          =>fnd_global.user_id,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                END IF;
               END IF;
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

    -- Debug info

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of Private api '||l_api_name,'+debug+');
	END IF;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_MR_ACTION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_MR_ACTION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_MR_ACTION;
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
END AHL_FMP_MR_ACTION_PVT;

/
