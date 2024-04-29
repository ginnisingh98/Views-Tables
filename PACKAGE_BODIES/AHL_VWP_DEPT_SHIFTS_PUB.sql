--------------------------------------------------------
--  DDL for Package Body AHL_VWP_DEPT_SHIFTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_DEPT_SHIFTS_PUB" AS
/* $Header: AHLPDSHB.pls 115.9 2002/12/24 18:34:24 ssurapan noship $ */
--
G_PKG_NAME    VARCHAR2(30):='AHL_VWP_DEPT_SHIFTS_PUB';
G_DEBUG 	  VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
--
PROCEDURE DEFAULT_MISSING_ATTRIBS
(
p_x_vwp_deptshift_rec IN OUT NOCOPY AHL_VWP_DEPT_SHIFTS_PUB.vwp_deptshift_rec
)
AS
BEGIN
        IF p_x_vwp_deptshift_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM
        THEN
                p_x_vwp_deptshift_rec.OBJECT_VERSION_NUMBER:=NULL;
        END IF;

        IF p_x_vwp_deptshift_rec.DEPARTMENT_ID= FND_API.G_MISS_NUM
        THEN
                p_x_vwp_deptshift_rec.DEPARTMENT_ID:=NULL;
        END IF;

        IF p_x_vwp_deptshift_rec.SHIFT_NUM= FND_API.G_MISS_NUM
        THEN
                p_x_vwp_deptshift_rec.SHIFT_NUM:=NULL;
        END IF;

        IF p_x_vwp_deptshift_rec.SEQ_NUM= FND_API.G_MISS_NUM
        THEN
                p_x_vwp_deptshift_rec.SEQ_NUM:=NULL;
        END IF;

        IF p_x_vwp_deptshift_rec.CALENDAR_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_rec.CALENDAR_CODE:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE_CATEGORY IS NULL OR p_x_vwp_deptshift_Rec.ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE_CATEGORY:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE1=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE1:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE2=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE2:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE3=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE3:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE4 IS NULL OR p_x_vwp_deptshift_Rec.ATTRIBUTE4=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE4:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE5=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE5:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE6=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE6:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE7=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE7:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE8=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE8:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE9=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE9:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE10=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE10:=NULL;
        END IF;

        IF  p_x_vwp_deptshift_Rec.ATTRIBUTE11=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE11:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE12 IS NULL OR p_x_vwp_deptshift_Rec.ATTRIBUTE12=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE12:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE13=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE13:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE14=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE14:=NULL;
        END IF;

        IF p_x_vwp_deptshift_Rec.ATTRIBUTE15=FND_API.G_MISS_CHAR
        THEN
                p_x_vwp_deptshift_Rec.ATTRIBUTE15:=NULL;
        END IF;
END;

PROCEDURE TRANSLATE_VALUE_ID
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_vwp_deptshift_rec       IN OUT NOCOPY AHL_VWP_DEPT_SHIFTS_PUB.VWP_DEPTSHIFT_REC
 )
as
 CURSOR get_org_id(C_NAME  VARCHAR2)
 IS
 SELECT ORGANIZATION_ID
 FROM HR_ALL_ORGANIZATION_UNITS
 WHERE NAME=C_NAME;

 CURSOR get_org_dept_id(C_ORG_ID  NUMBER,C_DESCRIPTION  VARCHAR2)
 IS
 SELECT  DEPARTMENT_ID
 FROM BOM_DEPARTMENTS_V
 WHERE ORGANIZATION_ID=C_ORG_ID
 AND DESCRIPTION=C_DESCRIPTION;

 CURSOR get_bom_calendar(C_CALENDAR  VARCHAR2)
 IS
 SELECT CALENDAR_CODE
 FROM  BOM_CALENDARS
 WHERE DESCRIPTION=C_CALENDAR;


 CURSOR get_bom_shift_num(C_CALENDAR_CODE  VARCHAR2,C_SHIFT_NUM NUMBER)
 IS
 SELECT SHIFT_NUM
 FROM BOM_SHIFT_TIMES
 WHERE CALENDAR_CODE=C_CALENDAR_CODE
 AND SHIFT_NUM=C_SHIFT_NUM;

 CURSOR get_bom_workdays(C_CALENDAR_CODE VARCHAR2,C_SHIFT NUMBER,C_DESCRIPTION VARCHAR2)
 IS
 SELECT SEQ_NUM
 FROM BOM_WORKDAY_PATTERNS
 WHERE CALENDAR_CODE=C_CALENDAR_CODE
 AND SHIFT_NUM=C_SHIFT
 AND DESCRIPTION=C_DESCRIPTION;

 l_lookup_code           VARCHAR2(30);
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_mr_header_id          number:=0;
 l_lookup_var  varchar2(1);
 l_object_version_number NUMBER;
 l_check_flag            VARCHAR2(1):='N';
 l_counter               NUMBER:=0;
 BEGIN
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.enable_debug;
        END IF;
        x_return_status:=FND_API.G_RET_STS_SUCCESS;
        --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate1 -- l_check_flag' || l_check_flag);
        IF p_x_vwp_deptshift_rec.ORGANIZATION_NAME IS NULL OR p_x_vwp_deptshift_rec.ORGANIZATION_NAME=FND_API.G_MISS_CHAR
        THEN
                --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside organization-- l_check_flag' || l_check_flag);
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_ORG_NAME_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        ELSE
                l_check_flag:='Y';
                --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside org cursor -- l_check_flag' || l_check_flag);
                OPEN get_org_id(p_x_vwp_deptshift_rec.ORGANIZATION_NAME);
                FETCH get_org_id INTO p_x_vwp_deptshift_rec.ORGANIZATION_ID;
                IF get_org_id%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_ORG_NAME_INVALID');
                        FND_MSG_PUB.ADD;
                        l_check_flag:='N';
                END IF;
                CLOSE get_org_id;
        END IF;

        --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate3 -- l_check_flag' || l_check_flag);
        l_check_flag:='N';
        IF p_x_vwp_deptshift_rec.DEPT_DESCRIPTION IS NULL OR p_x_vwp_deptshift_rec.DEPT_DESCRIPTION=FND_API.G_MISS_CHAR
        THEN
                --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside department-- l_check_flag' || l_check_flag);
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_DEPT_NAME_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        ELSE
                l_check_flag:='Y';
        END IF;

        IF l_check_flag='Y'
        THEN
             OPEN get_org_dept_id(p_x_vwp_deptshift_rec.ORGANIZATION_ID,p_x_vwp_deptshift_rec.DEPT_DESCRIPTION);
             FETCH get_org_dept_id INTO p_x_vwp_deptshift_rec.DEPARTMENT_ID;
             IF get_org_dept_id%NOTFOUND
             THEN
                 FND_MESSAGE.SET_NAME('AHL','AHL_VWP_DEPT_NAME_INVALID');
                 FND_MSG_PUB.ADD;
                 l_check_flag:='N';
             END IF;
             CLOSE get_org_dept_id;
        END IF;

        --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate2 -- l_check_flag' || l_check_flag);

        l_check_flag:='N';
        IF p_x_vwp_deptshift_rec.CALENDAR_DESCRIPTION IS NULL OR p_x_vwp_deptshift_rec.CALENDAR_DESCRIPTION=FND_API.G_MISS_CHAR
        THEN
                --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside calender-- l_check_flag' || l_check_flag);
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CALENDER_NAME_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        ELSE
                l_check_flag:='Y';
        END IF;


        IF l_check_flag='Y'
        THEN
                OPEN get_bom_calendar(p_x_vwp_deptshift_rec.CALENDAR_DESCRIPTION);
                FETCH get_bom_calendar INTO p_x_vwp_deptshift_rec.CALENDAR_CODE;
                IF get_bom_calendar%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CALENDER_INVALID');
                        FND_MSG_PUB.ADD;
                        l_check_flag:='N';
                ELSE
                        l_check_flag:='Y';
                END IF;
                CLOSE get_bom_calendar;
        END IF;

        --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate2 -- l_check_flag' || l_check_flag);

        l_check_flag:='N';
        IF p_x_vwp_deptshift_rec.SHIFT_NUM IS NULL OR p_x_vwp_deptshift_rec.SHIFT_NUM=FND_API.G_MISS_NUM
        THEN
                --AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside shift number-- l_check_flag' || l_check_flag);
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_SHIFT_NUMBER_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        ELSE
                l_check_flag:='Y';
        END IF;

        IF l_check_flag='Y'
        THEN
            OPEN  get_bom_shift_num(p_x_vwp_deptshift_rec.CALENDAR_CODE,p_x_vwp_deptshift_rec.SHIFT_NUM);
            FETCH get_bom_shift_num INTO  p_x_vwp_deptshift_rec.SHIFT_NUM;
            IF get_bom_shift_num%NOTFOUND
            THEN
                 FND_MESSAGE.SET_NAME('AHL','AHL_VWP_SHIFT_NUMBER_INVALID');
                 FND_MSG_PUB.ADD;
                 l_check_flag:='N';
            ELSE
                 l_check_flag:='Y';
            END IF;
            CLOSE get_bom_shift_num;
        END IF;

        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate2 -- l_check_flag' || l_check_flag);
        END IF;

        l_check_flag:='N';
        IF p_x_vwp_deptshift_rec.SEQ_NAME IS NULL OR p_x_vwp_deptshift_rec.SEQ_NAME=FND_API.G_MISS_CHAR
        THEN
                IF G_DEBUG='Y' THEN
		        AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside sequence number-- l_check_flag' || l_check_flag);
                END IF;
				--
		        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_WORK_DAYS_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
        ELSE
                l_check_flag:='Y';
        END IF;
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside translate2 -- l_check_flag' || l_check_flag);
		END IF;
        IF l_check_flag='Y'
        THEN
            IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- inside sequence number ***** -- l_check_flag' || l_check_flag);
			  END IF;
                OPEN  get_bom_workdays(p_x_vwp_deptshift_rec.CALENDAR_CODE,p_x_vwp_deptshift_rec.SHIFT_NUM,p_x_vwp_deptshift_rec.SEQ_NAME);
                FETCH get_bom_workdays INTO p_x_vwp_deptshift_rec.SEQ_NUM;
                IF get_bom_workdays%NOTFOUND
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_SEQ_DESCRIP_INVALID');
                        FND_MSG_PUB.ADD;
                END IF;
                CLOSE get_bom_workdays;
        END IF;
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.disable_debug;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_DEPT_SHIFTS_PUB',
                            p_procedure_name  =>  'TRANSLATE_VALUE_ID',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END;

-- Start of Validate

PROCEDURE VALIDATE_VWP_DEPT_SHIFT
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_vwp_deptshift_rec         IN     AHL_VWP_DEPT_SHIFTS_PUB.vwp_deptshift_rec
 )
as
 l_counter               NUMBER:=0;
 l_prim_key              NUMBER:=0;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_vwp_deptshift_rec.DML_OPERATION='D'
        THEN
                IF p_vwp_deptshift_rec.OBJECT_VERSION_NUMBER  IS NULL OR p_vwp_deptshift_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM
                THEN
                       FND_MESSAGE.SET_NAME('AHL','AHL_COM_OBJECT_VERS_NUM_NULL');
                       FND_MSG_PUB.ADD;
                END IF;

                IF p_vwp_deptshift_rec.AHL_DEPARTMENT_SHIFTS_ID  IS NULL OR p_vwp_deptshift_rec.AHL_DEPARTMENT_SHIFTS_ID=FND_API.G_MISS_NUM
                THEN
                       FND_MESSAGE.SET_NAME('AHL','AHL_DEPARTMENT_SHIFTS_ID_NULL');
                       FND_MSG_PUB.ADD;
                ELSE
                       SELECT   AHL_DEPARTMENT_SHIFTS_ID INTO l_prim_key
                        FROM AHL_DEPARTMENT_SHIFTS
                        WHERE AHL_DEPARTMENT_SHIFTS_ID=p_vwp_deptshift_rec.AHL_DEPARTMENT_SHIFTS_ID;
                END IF;
        ELSE
                Select COUNT(DEPARTMENT_ID) INTO l_counter
                FROM AHL_DEPARTMENT_SHIFTS
                WHERE DEPARTMENT_ID=p_vwp_deptshift_rec.DEPARTMENT_ID;

                IF l_counter>0
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_DEPT_EXISTS');
                        FND_MSG_PUB.ADD;
                END IF;
       END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_DEPT_SHIFTS_PUB',
                            p_procedure_name  =>  'VALIDATE_VWP_DEPT_SHIFT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;

PROCEDURE CREATE_VWP_DEPT_SHIFTS
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT  NOCOPY    VARCHAR2,
 x_msg_count                    OUT  NOCOPY    NUMBER,
 x_msg_data                     OUT  NOCOPY    VARCHAR2,
 p_x_vwp_deptshift_rec      IN OUT NOCOPY  VWP_DEPTSHIFT_REC
 )
 AS
 l_vwp_deptshift_rec     VWP_DEPTSHIFT_REC:=p_x_vwp_deptshift_rec;
 l_lookup_code           VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_VWP_DEPT_SHIFTS';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER:=0;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_department_shifts_id  number:=0;
 l_object_version_number NUMBER;
 l_check_flag            VARCHAR2(1):='Y';
 BEGIN

        SAVEPOINT CREATE_VWP_DEPT_SHIFTS;

   --   Initialize message list if p_init_msg_list is set to TRUE.

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

        IF p_module_type = 'JSP'
        THEN
                l_vwp_deptshift_rec.ORGANIZATION_ID:=NULL;
                l_vwp_deptshift_rec.DEPARTMENT_ID:=NULL;
                l_vwp_deptshift_rec.CALENDAR_CODE:=NULL;
        END IF;

    -- Debug info.

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'AHL_VWP_DEPT_SHIFTS_PUB.','+CREATE_VWP_DEPT_SHIFTS+');
            AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- before translate shift_num ' || l_vwp_deptshift_rec.SHIFT_NUM);
        END IF;

         TRANSLATE_VALUE_ID
         (
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_x_vwp_deptshift_rec      =>l_vwp_deptshift_rec
         );
        IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- after transalate shift_num' || l_vwp_deptshift_rec.SHIFT_NUM);
		 END IF;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.to_boolean(p_default)
        THEN
         DEFAULT_MISSING_ATTRIBS
         (
         p_x_vwp_deptshift_rec      =>l_vwp_deptshift_rec
         );
        END IF;

        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN

         VALIDATE_VWP_DEPT_SHIFT
         (
         x_return_status             =>x_return_status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_vwp_deptshift_rec         =>l_vwp_deptshift_rec);
        END IF;
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- after validation shift_num' || l_vwp_deptshift_rec.SHIFT_NUM);
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- insert process goes here
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug('AHL_VWP_DEPT_SHIFTS_PUB -- before insert shift_num' || l_vwp_deptshift_rec.SHIFT_NUM);
		END IF;
        IF  l_vwp_deptshift_rec.DML_OPERATION='C'
        THEN
                 Select  AHL_DEPARTMENT_SHIFTS_S.nextval into
                          l_department_shifts_id
                         from dual;

                 l_vwp_deptshift_rec.OBJECT_VERSION_NUMBER:=1;
                 l_vwp_deptshift_rec.LAST_UPDATE_DATE:=sysdate;
                 l_vwp_deptshift_rec.LAST_UPDATED_BY:=fnd_global.user_id;
                 l_vwp_deptshift_rec.CREATION_DATE:=sysdate;
                 l_vwp_deptshift_rec.CREATED_BY:=fnd_global.user_id;
                 l_vwp_deptshift_rec.LAST_UPDATE_LOGIN:=fnd_global.user_id;
                 l_vwp_deptshift_rec.AHL_DEPARTMENT_SHIFTS_ID:=l_department_shifts_id;

                INSERT INTO AHL_DEPARTMENT_SHIFTS
                (
                 AHL_DEPARTMENT_SHIFTS_ID,
                 OBJECT_VERSION_NUMBER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 DEPARTMENT_ID,
                 CALENDAR_CODE,
                 SHIFT_NUM,
                 SEQ_NUM,
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
                 l_DEPARTMENT_SHIFTS_ID,
                 l_vwp_deptshift_rec.OBJECT_VERSION_NUMBER,
                 l_vwp_deptshift_rec.LAST_UPDATE_DATE,
                 l_vwp_deptshift_rec.LAST_UPDATED_BY,
                 l_vwp_deptshift_rec.CREATION_DATE,
                 l_vwp_deptshift_rec.CREATED_BY,
                 l_vwp_deptshift_rec.LAST_UPDATE_LOGIN,
                 l_vwp_deptshift_rec.DEPARTMENT_ID,
                 l_vwp_deptshift_rec.CALENDAR_CODE,
                 l_vwp_deptshift_rec.SHIFT_NUM,
                 l_vwp_deptshift_rec.SEQ_NUM,
                 l_vwp_deptshift_rec.ATTRIBUTE_CATEGORY,
                 l_vwp_deptshift_rec.ATTRIBUTE1,
                 l_vwp_deptshift_rec.ATTRIBUTE2,
                 l_vwp_deptshift_rec.ATTRIBUTE3,
                 l_vwp_deptshift_rec.ATTRIBUTE4,
                 l_vwp_deptshift_rec.ATTRIBUTE5,
                 l_vwp_deptshift_rec.ATTRIBUTE6,
                 l_vwp_deptshift_rec.ATTRIBUTE7,
                 l_vwp_deptshift_rec.ATTRIBUTE8,
                 l_vwp_deptshift_rec.ATTRIBUTE9,
                 l_vwp_deptshift_rec.ATTRIBUTE10,
                 l_vwp_deptshift_rec.ATTRIBUTE11,
                 l_vwp_deptshift_rec.ATTRIBUTE12,
                 l_vwp_deptshift_rec.ATTRIBUTE13,
                 l_vwp_deptshift_rec.ATTRIBUTE14,
                 l_vwp_deptshift_rec.ATTRIBUTE15);
         END IF;

         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;
        IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.disable_debug;
         END IF;

 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_VWP_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_VWP_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO CREATE_VWP_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_DEPT_SHIFTS_PUB',
                            p_procedure_name  =>  'CREATE_VWP_DEPT_SHIFTS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

PROCEDURE DELETE_VWP_DEPT_SHIFTS
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_x_vwp_deptshift_rec      IN OUT NOCOPY VWP_DEPTSHIFT_REC
 )
 AS
 l_vwp_deptshift_rec      VWP_DEPTSHIFT_REC:=p_x_vwp_deptshift_rec;
 l_lookup_code           VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_VWP_DEPT_SHIFTS';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_department_shifts_id          number:=0;
 l_lookup_var  varchar2(1);
 l_object_version_number NUMBER;
 l_check_flag            VARCHAR2(1):='Y';

 BEGIN

        SAVEPOINT DELETE_DEPT_SHIFTS;

   --   Initialize message list if p_init_msg_list is set to TRUE.

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

        IF p_module_type = 'JSP'
        THEN
                l_vwp_deptshift_rec.ORGANIZATION_ID:=NULL;
                l_vwp_deptshift_rec.DEPARTMENT_ID:=NULL;
                l_vwp_deptshift_rec.CALENDAR_CODE:=NULL;
                l_vwp_deptshift_rec.SHIFT_NUM:=NULL;
        END IF;

    -- Debug info.

        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug( 'AHL_VWP_DEPT_SHITS_PUB.','+delete_VWP_DEPT_SHIFTS+');
        END IF;



        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN
         VALIDATE_VWP_DEPT_SHIFT
         (
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_vwp_deptshift_rec         =>l_vwp_deptshift_rec);
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

   -- DELETE GOES HERE

        IF  l_vwp_deptshift_rec.DML_OPERATION='D'
        THEN
                DELETE AHL_DEPARTMENT_SHIFTS
                WHERE  AHL_DEPARTMENT_SHIFTS_ID=l_vwp_deptshift_rec.AHL_DEPARTMENT_SHIFTS_ID
                AND OBJECT_VERSION_NUMBER=l_vwp_deptshift_rec.OBJECT_VERSION_NUMBER;
                IF (sql%ROWCOUNT=0)
                THEN
                      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                      FND_MSG_PUB.ADD;
                END IF;
        END IF;

         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;
        IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.disable_debug;
        END IF;

 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO DELETE_DEPT_SHIFTS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_DEPT_SHIFTS_PUB',
                            p_procedure_name  =>  'CREATE_VWP_DEPT_SHIFTS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

END AHL_VWP_DEPT_SHIFTS_PUB;

/
