--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_RELATION_PVT" AS
/* $Header: AHLVMRLB.pls 120.1 2006/02/01 10:57:09 tamdas noship $ */
G_PKG_NAME              VARCHAR2(50):= 'AHL_FMP_MR_RELATION_PVT';
G_PM_INSTALL            VARCHAR2(30):=ahl_util_pkg.is_pm_installed;

--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_mr_relation_tbl  IN OUT NOCOPY AHL_FMP_MR_relation_PVT.MR_relation_TBL)
AS

BEGIN
        IF P_X_MR_relation_TBL.COUNT>0
        THEN
        FOR i IN  P_X_MR_relation_TBL.FIRST.. P_X_MR_relation_TBL.LAST
        LOOP
        IF p_x_mr_relation_tbl(I).RELATIONSHIP_CODE= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(I).RELATIONSHIP_CODE:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(I).MR_HEADER_ID= FND_API.G_MISS_NUM
        THEN
                p_x_mr_relation_tbl(I).MR_HEADER_ID:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(I).RELATED_MR_HEADER_ID= FND_API.G_MISS_NUM
        THEN
                p_x_mr_relation_tbl(I).RELATED_MR_HEADER_ID:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(I).MR_RELATIONSHIP_ID= FND_API.G_MISS_NUM
        THEN
                p_x_mr_relation_tbl(I).MR_RELATIONSHIP_ID:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
        THEN
                IF p_x_mr_relation_tbl(i).dml_operation='C'
                THEN
                        p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER:=1;
                ELSE
                        p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER:=NULL;
                END IF;
        END IF;

        IF  p_x_mr_relation_tbl(i).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE_CATEGORY:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE1=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE1:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE2=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE2:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE3=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE3:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE4 IS NULL OR p_x_mr_relation_tbl(i).ATTRIBUTE4=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE4:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE5=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE5:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE6=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE6:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE7=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE7:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE8=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE8:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE9=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE9:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE10=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE10:=NULL;
        END IF;

        IF  p_x_mr_relation_tbl(i).ATTRIBUTE11=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE11:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE12=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE12:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE13=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE13:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE14=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE14:=NULL;
        END IF;

        IF p_x_mr_relation_tbl(i).ATTRIBUTE15=FND_API.G_MISS_CHAR
        THEN
                p_x_mr_relation_tbl(i).ATTRIBUTE15:=NULL;
        END IF;
        END LOOP;
        END IF;
END;

PROCEDURE TRANS_VALUE_ID
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_x_mr_relation_rec         IN OUT NOCOPY MR_RELATION_REC
 )
as
  CURSOR title_to_relmr_header_id(C_TITLE IN VARCHAR2,C_TYPE_CODE VARCHAR2)
  IS
  SELECT MR_HEADER_ID
  FROM AHL_MR_HEADERS_APP_V A
  WHERE UPPER(TITLE)=(C_TITLE)
  AND  MR_STATUS_CODE<>'TERMINATED'
  AND trunc(NVL(EFFECTIVE_TO,SYSDATE+1))>SYSDATE
  AND NVL(TYPE_CODE,'X')=DECODE(C_TYPE_CODE,'ACTIVITY','PROGRAM', 'PROGRAM','ACTIVITY','X');

  CURSOR c_mr_header_id_to_relmr_title(C_MR_HEADER_ID IN NUMBER,C_TYPE_CODE VARCHAR2)
  IS
  SELECT TITLE
  FROM AHL_MR_HEADERS_APP_V
  WHERE MR_HEADER_ID=C_MR_HEADER_ID
  AND  MR_STATUS_CODE<>'TERMINATED'
  AND trunc(NVL(EFFECTIVE_TO,SYSDATE+1))>SYSDATE
  AND NVL(TYPE_CODE,'X')=DECODE(NVL(C_TYPE_CODE,'X'),'ACTIVITY','PROGRAM','PROGRAM','ACTIVITY','X');


  check_flag                 VARCHAR2(1):='N';
  l_rel_mr_header_id         AHL_MR_HEADERS_B.MR_HEADER_ID%TYPE;
  l_api_name                 VARCHAR2(30):='TRANS_VALUE_ID';
  l_type_code                AHL_MR_HEADERS_B.TYPE_CODE%TYPE;
  l_title                    AHL_MR_HEADERS_B.TITLE%TYPE;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.enable_debug;
        AHL_DEBUG_PUB.debug( 'p_x_mr_relation_rec.related_mr_header_id'||p_x_mr_relation_rec.related_mr_header_id,'+DEBUG_RELATIONS+');
	END IF;

        IF p_x_mr_relation_rec.MR_HEADER_ID IS NOT NULL OR p_x_mr_relation_rec.MR_HEADER_ID<>FND_API.G_MISS_NUM
        THEN
                SELECT TYPE_CODE INTO L_TYPE_CODE
                FROM AHL_MR_HEADERS_B
                WHERE MR_HEADER_ID=p_x_mr_relation_rec.MR_HEADER_ID;
        END IF;

        IF p_x_mr_relation_rec.RELATED_MR_TITLE IS NULL OR p_x_mr_relation_rec.RELATED_MR_TITLE=FND_API.G_MISS_CHAR
        THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TITLE_NULL');
            FND_MSG_PUB.ADD;
            check_flag:='N';
        ELSE
            check_flag:='Y';
        END IF;

        IF check_flag='Y'
        THEN
                IF p_x_mr_relation_rec.related_mr_header_id is not null and
                   p_x_mr_relation_rec.related_mr_header_id<>fnd_api.g_miss_num
                THEN
                        open  c_mr_header_id_to_relmr_title(p_x_mr_relation_rec.related_mr_header_id,l_type_code);
                        fetch c_mr_header_id_to_relmr_title into l_title;
                        close c_mr_header_id_to_relmr_title;
                END IF;

                IF NVL(l_title,'X')<>p_x_mr_relation_rec.RELATED_MR_TITLE
                THEN

                        OPEN  title_to_relmr_header_id(p_x_mr_relation_rec.RELATED_MR_TITLE,nvl(l_type_code,'X'));
                        FETCH title_to_relmr_header_id INTO l_rel_mr_header_id;

                        IF  title_to_relmr_header_id%NOTFOUND
                        THEN
                                    SELECT TITLE INTO l_title
                                    FROM AHL_MR_HEADERS_B
                                    WHERE MR_HEADER_ID=p_x_mr_relation_rec.MR_HEADER_ID;

                                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATED_TITLE_INVAL');
                                    FND_MESSAGE.SET_TOKEN('FIELD',l_title,false);
                                    FND_MESSAGE.SET_TOKEN('RECORD', p_x_mr_relation_rec.RELATED_MR_TITLE, false);
                                    FND_MSG_PUB.ADD;
                        ELSE
                            p_x_mr_relation_rec.related_mr_header_id:=l_rel_mr_header_id;
                        END IF;
                        CLOSE title_to_relmr_header_id;
                END IF;
        END IF;
       AHL_DEBUG_PUB.debug( 'p_x_mr_relation_rec.related_mr_header_id'||p_x_mr_relation_rec.related_mr_header_id,'+DEBUG_RELATIONS+');

 END;

PROCEDURE  NON_CYCLIC_ENF
(
 p_api_version               IN     NUMBER:=1.0,
 p_init_msg_list             IN     VARCHAR2:= FND_API.G_FALSE,
 p_validation_level          IN     NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 P_MR_HEADER_ID              IN NUMBER,
 P_RELATED_MR_HEADER_ID         IN NUMBER,
 P_RELATED_MR_TITLE          IN VARCHAR2
)
AS
l_cyclic_loop           EXCEPTION;
PRAGMA                  EXCEPTION_INIT(l_cyclic_loop,-1436);
l_counter               NUMBER;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        SELECT COUNT(*) INTO l_counter
        FROM   AHL_MR_RELATIONSHIPS
        START WITH RELATED_MR_HEADER_ID=P_RELATED_MR_HEADER_ID
        CONNECT BY PRIOR  RELATED_MR_HEADER_ID=MR_HEADER_ID;
EXCEPTION
WHEN l_cyclic_loop  THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATION_CYCLIC');
        FND_MESSAGE.SET_TOKEN('RECORD', P_RELATED_MR_TITLE ,false);
        FND_MSG_PUB.ADD;
        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>'AHL_FMP_MR_RELATION_PVT',
                            p_procedure_name  =>'NON_CYCLIC_ENF',
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;

PROCEDURE VALIDATE_MR_RELATION
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 p_mr_relation_rec              IN  MR_RELATION_REC
 )
 as
  CURSOR Check_mr_header_stat(C_MR_HEADER_ID IN NUMBER)
  IS
  SELECT MR_STATUS_CODE,TITLE,TYPE_CODE
  FROM AHL_MR_HEADERS_B
  WHERE MR_HEADER_ID=C_MR_HEADER_ID;

  l_head_rec                    Check_mr_header_stat%rowtype;
  l_rel_head_rec                 Check_mr_header_stat%rowtype;

  CURSOR CHECK_UNIQ(c_mr_header_id NUMBER,c_related_mr_header_id NUMBER,c_relationship_code VARCHAR2)
      IS
  select *
  from  AHL_MR_RELATIONSHIPS
  where MR_HEADER_ID=C_MR_HEADER_ID
  and   RELATED_MR_HEADER_ID=C_RELATED_MR_HEADER_ID
  and   relationship_code=c_relationship_code;

  l_rel_rec   CHECK_UNIQ%ROWTYPE;

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

 l_object_version_number number;
 l_api_name     CONSTANT VARCHAR2(30) := 'VALIDATE_MR_RELATION';
 l_mr_header_id          NUMBER:=0;
 l_mr_check_flag         VARCHAR2(1):='N';
 BEGIN
     x_return_status:=FND_API.G_RET_STS_SUCCESS;
     	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;
             IF p_mr_relation_rec.MR_HEADER_ID IS NULL or
		p_mr_relation_rec.MR_HEADER_ID=FND_API.G_MISS_NUM
             THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
                    FND_MSG_PUB.ADD;
             ELSE
                     OPEN  Check_mr_header_stat(p_mr_relation_rec.mr_header_id);
                     FETCH Check_mr_header_stat INTO l_head_rec;
                     IF  Check_mr_header_stat%FOUND
                     THEN
                         IF l_head_rec.mr_status_code='DRAFT' OR
			    l_head_rec.mr_status_code='APPROVAL_REJECTED'
                         THEN
                        IF G_DEBUG='Y' THEN
		  	AHL_DEBUG_PUB.debug( 'mr_Status_code'||l_head_rec.mr_status_code,'+DEBUG_RELATIONS+');
			END IF;
                                 l_mr_check_flag:='Y';
                         ELSE
                                 FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_MR_STATUS');
                                 FND_MSG_PUB.ADD;
                         IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug( 'mr_Status_code'||l_head_rec.mr_status_code,'+DEBUG_RELATIONS+');
			 END IF;
                                 l_mr_check_flag:='N';
                         END IF;

                         IF ltrim(rtrim(l_head_rec.title))=rtrim(ltrim(p_mr_relation_rec.RELATED_MR_TITLE))
                         THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATION_CYCLIC');
                                FND_MESSAGE.SET_TOKEN('RECORD',rtrim(ltrim(p_mr_relation_rec.RELATED_MR_TITLE)),false);
                                FND_MSG_PUB.ADD;
                                l_mr_check_flag:='N';
                         END IF;

                     ELSE
                         FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EDIT_STATUS_INVALID');
                         FND_MSG_PUB.ADD;
                         l_mr_check_flag:='N';
                     END IF;
                     CLOSE Check_mr_header_stat;
             END IF;

       IF l_mr_check_flag='Y'
       THEN
                IF p_mr_relation_rec.dml_operation<>'D'
                THEN
                     IF p_mr_relation_rec.RELATED_MR_HEADER_ID IS NULL OR
                        p_mr_relation_rec.RELATED_MR_HEADER_ID=FND_API.G_MISS_NUM
                     THEN
                             FND_MESSAGE.SET_NAME('AHL','AHL_MR_HEADER_ID_NULL');
                             FND_MSG_PUB.ADD;
                     ELSE
                             OPEN  Check_mr_header_stat(p_mr_relation_rec.RELATED_MR_HEADER_ID);
                             FETCH Check_mr_header_stat INTO l_rel_head_rec;
                             IF Check_mr_header_stat%FOUND
                             THEN
                                 IF G_PM_INSTALL='Y'
                                 THEN

					IF l_head_rec.TYPE_CODE='PROGRAM' and
					p_mr_relation_rec.relationship_code='PARENT'
                                        THEN
                                       FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_PROGRM_RELCODE_INV');
                                       FND_MESSAGE.SET_TOKEN('FIELD', l_head_rec.TITLE,false);
                                       FND_MSG_PUB.ADD;
                                        ELSIF l_head_rec.TYPE_CODE='ACTIVITY' and p_mr_relation_rec.relationship_code='CHILD'
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_ACTVTY_RELCODE_INV');
                                                FND_MESSAGE.SET_TOKEN('FIELD', l_head_rec.TITLE,false);
                                                FND_MSG_PUB.ADD;
                                        END IF;

                                        IF l_head_rec.TYPE_CODE='PROGRAM' and l_rel_head_rec.TYPE_CODE='PROGRAM'
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_PROG_2_PROG_INV');
                                                FND_MESSAGE.SET_TOKEN('FIELD', p_mr_relation_rec.RELATED_MR_TITLE,false);
                                                FND_MSG_PUB.ADD;
                                        ELSIF l_head_rec.TYPE_CODE='ACTIVITY' and l_rel_head_rec.TYPE_CODE='ACTIVITY'
                                        THEN
                                                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PM_ACTV_2_ACTV_INV');
                                                FND_MESSAGE.SET_TOKEN('FIELD', p_mr_relation_rec.RELATED_MR_TITLE,false);
                                                FND_MSG_PUB.ADD;
                                        END IF;
                                 END IF;
                             END IF;
                             CLOSE Check_mr_header_stat;
                     END IF;
                END IF;

             IF p_mr_relation_rec.dml_operation<>'C'
             THEN
                    IF (p_mr_relation_rec.MR_RELATIONSHIP_ID IS NULL OR
                        p_mr_relation_rec.MR_RELATIONSHIP_ID=FND_API.G_MISS_NUM)
                    THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATIONSHIPID_NULL');
                        FND_MESSAGE.SET_TOKEN('RECORD', p_mr_relation_rec.RELATED_MR_TITLE,false);
                        FND_MSG_PUB.ADD;
                    END IF;

                    IF (p_mr_relation_rec.OBJECT_VERSION_NUMBER IS NULL OR
                        p_mr_relation_rec.OBJECT_vERSION_NUMBER=FND_API.G_MISS_NUM)
                    THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_REL_OBJ_VERSION_NULL');
                        FND_MESSAGE.SET_TOKEN('RECORD', p_mr_relation_rec.RELATED_MR_TITLE,false);
                        FND_MSG_PUB.ADD;
                    END IF;
             END IF;


             IF p_mr_relation_rec.dml_operation<>'D'
             THEN
                    IF G_DEBUG='Y' THEN
		  	AHL_DEBUG_PUB.debug( 'Check Uniq Record','+DEBUG_RELATIONS+');
		    END IF;
                    IF p_mr_relation_rec.relationship_code='CHILD'
                    THEN
                             OPEN  check_uniq(p_mr_relation_rec.mr_header_id,p_mr_relation_rec.related_mr_header_id,'PARENT');
                    ELSE
                             OPEN  check_uniq(p_mr_relation_rec.related_mr_header_id,p_mr_relation_rec.mr_header_id,'PARENT');
                    END IF;

                      FETCH check_uniq INTO l_rel_rec;

                      IF  check_uniq%found
                      THEN
                              IF  p_mr_relation_rec.dml_operation='C'
                              THEN
                                  FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATION_DUPLICATE');
                                  FND_MESSAGE.SET_TOKEN('RECORD', p_mr_relation_rec.RELATED_MR_TITLE, false);
                                  FND_MSG_PUB.ADD;
                              ELSIF  P_mr_relation_rec.dml_operation='U'
                              THEN
                                  IF l_rel_rec.MR_RELATIONSHIP_ID<>p_mr_relation_rec.MR_RELATIONSHIP_ID
                                  THEN
                                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_RELATION_DUPLICATE');
                                          FND_MESSAGE.SET_TOKEN('RECORD', p_mr_relation_rec.RELATED_MR_TITLE, false);
                                          FND_MSG_PUB.ADD;
                                  END IF;
                              END IF;
                     END IF;
                      CLOSE check_UNIQ;
               END IF;

            -- Tamal [MEL/CDL] -- Begin changes
            OPEN check_mo_proc(p_mr_relation_rec.MR_HEADER_ID);
            FETCH check_mo_proc INTO l_dummy_char;
            IF (check_mo_proc%FOUND)
            THEN
                FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MRL_MO_PROC');
                -- Relationships are not available for a Maintenance Requirement of (M) and (0) procedure program type.
                FND_MSG_PUB.ADD;
            END IF;
            -- Tamal [MEL/CDL] -- End changes
    END IF;
 END;

PROCEDURE PROCESS_MR_RELATION
 (
 p_api_version                  IN  	NUMBER:= 1.0,
 p_init_msg_list                IN  	VARCHAR2:= FND_API.G_FALSE,
 p_commit                       IN  	VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  	NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  	VARCHAR2:= FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY      VARCHAR2,
 x_msg_count                    OUT NOCOPY      NUMBER,
 x_msg_data                     OUT NOCOPY      VARCHAR2,
 p_x_mr_relation_tbl         	IN OUT NOCOPY  MR_RELATION_TBL
 )
as
 l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_MR_RELATION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 l_mr_header_id          NUMBER:=0;
 l_mr_relation_rec       MR_RELATION_REC;
 BEGIN


       SAVEPOINT PROCESS_MR_RELATION;

       IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
       END IF;


       x_return_status:=FND_API.G_RET_STS_SUCCESS;

       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;
        /*
        IF FND_API.to_boolean(p_default)
        THEN
        DEFAULT_MISSING_ATTRIBS
        (
        p_x_mr_relation_tbl     =>p_x_mr_relation_tbl
        );
        END IF;

        --IF p_module_type = 'JSP'
        --THEN
        --     FOR i IN  P_X_MR_RELATION_TBL.FIRST.. P_X_MR_RELATION_TBL.LAST
        --     LOOP
        --       p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID:=NULL;
        --     END LOOP;
        --END IF;
        */

	-- code for Value_To_ID conversion for parent MR.
        FOR i IN  P_X_MR_RELATION_TBL.FIRST.. P_X_MR_RELATION_TBL.LAST
        LOOP
        	IF (
        	     p_x_mr_relation_tbl(i).mr_header_id IS NULL OR
        	     p_x_mr_relation_tbl(i).mr_header_id = FND_API.G_MISS_NUM
        	   )
        	THEN
		    -- Function to convert mr_title,mr_version_number to id
		    AHL_FMP_COMMON_PVT.mr_title_version_to_id(
		    p_mr_title		=>	p_x_mr_relation_tbl(i).mr_title,
		    p_mr_version_number	=>	p_x_mr_relation_tbl(i).mr_version_number,
		    x_mr_header_id	=>	p_x_mr_relation_tbl(i).mr_header_id,
		    x_return_status	=>	x_return_status
		    );
		    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		  	 fnd_log.string
		  	 (
		  	     fnd_log.level_statement,
		  	    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		  	     'Invalid MR Title, Version Number provided'
		  	 );
		      END IF;
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		 END IF;
        END LOOP;

   --Start of API Body
        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN

                FOR i IN  P_X_MR_RELATION_TBL.FIRST.. P_X_MR_RELATION_TBL.LAST
                LOOP

                l_mr_relation_rec:=p_x_mr_relation_tbl(i);

                IF p_x_mr_relation_tbl(i).DML_operation<>'D'
                THEN
                 TRANS_VALUE_ID
                 (
                 x_return_status             =>x_return_Status,
                 p_x_mr_relation_rec         =>l_mr_relation_rec);
                 END IF;
                 p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID:=l_mr_relation_rec.RELATED_MR_HEADER_ID;

                END LOOP;

              l_msg_count := FND_MSG_PUB.count_msg;
              IF l_msg_count > 0
              THEN
                    X_msg_count := l_msg_count;
                    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    RAISE FND_API.G_EXC_ERROR;
              END IF;
      END IF;

        FOR i IN  P_X_MR_RELATION_TBL.FIRST.. P_X_MR_RELATION_TBL.LAST
        LOOP

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN

        VALIDATE_MR_RELATION
         (
         x_return_status             =>x_return_Status,
         p_mr_relation_rec           =>p_x_mr_relation_tbl(i));

        END IF;
              l_msg_count := FND_MSG_PUB.count_msg;
              IF l_msg_count > 0
              THEN
                    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      END IF;

        IF p_x_mr_relation_tbl(i).DML_operation<>'D'
        THEN
                IF p_x_mr_relation_tbl(i).RELATIONSHIP_CODE='PARENT'
                THEN
                     l_mr_header_id:=p_x_mr_relation_tbl(i).MR_HEADER_ID;
                     p_x_mr_relation_tbl(i).MR_HEADER_ID:=p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID;
                     p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID:=l_mr_header_id;
                     p_x_mr_relation_tbl(i).RELATIONSHIP_CODE:='PARENT';
                ELSIF p_x_mr_relation_tbl(i).RELATIONSHIP_CODE='CHILD'
                THEN
                    p_x_mr_relation_tbl(i).RELATIONSHIP_CODE:='PARENT';
                END IF;
        END IF;

        IF nvl(x_return_status,'X')='S'
        THEN
        IF p_x_mr_relation_tbl(i).DML_OPERATION='D' then
                delete AHL_MR_RELATIONSHIPS
                where MR_RELATIONSHIP_ID = p_x_mr_relation_tbl(i).MR_RELATIONSHIP_ID
                and  OBJECT_VERSION_NUMBER=p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER;

                if sql%rowcount=0 then
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_RECORD_CHANGED');
                   FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_relation_tbl(i).related_mr_title,false);
                   FND_MSG_PUB.ADD;
                end if;
        ELSIF p_x_mr_relation_tbl(i).DML_operation='U'
        then

             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN

                update AHL_mr_RELATIONSHIPS
                  set MR_HEADER_ID = p_x_mr_relation_tbl(i).MR_HEADER_ID,
                    RELATED_MR_HEADER_ID        = p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID,
                    RELATIONSHIP_CODE           = p_x_mr_relation_tbl(i).RELATIONSHIP_CODE,
                    MR_RELATIONSHIP_ID          = p_x_mr_relation_tbl(i).MR_RELATIONSHIP_ID,
                    OBJECT_VERSION_NUMBER       = p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER + 1,
                    ATTRIBUTE_CATEGORY          = p_x_mr_relation_tbl(i).ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1                  = p_x_mr_relation_tbl(i).ATTRIBUTE1,
                    ATTRIBUTE2                  = p_x_mr_relation_tbl(i).ATTRIBUTE2,
                    ATTRIBUTE3                  = p_x_mr_relation_tbl(i).ATTRIBUTE3,
                    ATTRIBUTE4                  = p_x_mr_relation_tbl(i).ATTRIBUTE4,
                    ATTRIBUTE5                  = p_x_mr_relation_tbl(i).ATTRIBUTE5,
                    ATTRIBUTE6                  = p_x_mr_relation_tbl(i).ATTRIBUTE6,
                    ATTRIBUTE7                  = p_x_mr_relation_tbl(i).ATTRIBUTE7,
                    ATTRIBUTE8                  = p_x_mr_relation_tbl(i).ATTRIBUTE8,
                    ATTRIBUTE9                  = p_x_mr_relation_tbl(i).ATTRIBUTE9,
                    ATTRIBUTE10                 = p_x_mr_relation_tbl(i).ATTRIBUTE10,
                    ATTRIBUTE11                 = p_x_mr_relation_tbl(i).ATTRIBUTE11,
                    ATTRIBUTE12                 = p_x_mr_relation_tbl(i).ATTRIBUTE12,
                    ATTRIBUTE13                 = p_x_mr_relation_tbl(i).ATTRIBUTE13,
                    ATTRIBUTE14                 = p_x_mr_relation_tbl(i).ATTRIBUTE14,
                    ATTRIBUTE15                 = p_x_mr_relation_tbl(i).ATTRIBUTE15,
                    LAST_UPDATE_DATE            = sysdate,
                    LAST_UPDATED_BY             = fnd_global.user_id,
                    LAST_UPDATE_LOGIN           = fnd_global.user_id
                 where MR_RELATIONSHIP_ID       = p_x_mr_relation_tbl(i).MR_RELATIONSHIP_ID
                 and   OBJECT_VERSION_NUMBER=p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER;

                  if sql%rowcount=0 then
                           FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                           FND_MSG_PUB.ADD;
                  end if;
                END IF;

        ELSIF p_x_mr_relation_tbl(i).DML_operation='C'
        then

                SELECT  AHL_MR_RELATIONSHIPS_S.NEXTVAL
                        INTO p_x_mr_relation_tbl(i).MR_RELATIONSHIP_ID
                        FROM DUAL;

                p_x_mr_relation_tbl(i).OBJECT_VERSION_NUMBER:=1;

             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN
                  insert into AHl_mr_RELATIONSHIPS(
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
                                        p_x_mr_relation_tbl(i).MR_RELATIONSHIP_ID,
                                        1,
                                        sysdate,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        fnd_global.user_id,
                                        p_x_mr_relation_tbl(i).MR_HEADER_ID,
                                        p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID,
                                        p_x_mr_relation_tbl(i).RELATIONSHIP_CODE,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE_CATEGORY,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE1,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE2,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE3,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE4,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE5,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE6,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE7,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE8,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE9,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE10,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE11,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE12,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE13,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE14,
                                        p_x_mr_relation_tbl(i).ATTRIBUTE15);
                        END IF;
         END IF;
         END IF;

                 IF p_x_mr_relation_tbl(i).DML_operation<>'D'
                 THEN
                   NON_CYCLIC_ENF
                   (
                   p_api_version               =>l_api_version,
                   p_init_msg_list             =>l_init_msg_list,
                   p_validation_level          =>p_validation_level ,
                   x_return_status             =>x_return_Status,
                   x_msg_count                 =>l_msg_count,
                   x_msg_data                  =>l_msg_data,
                   p_mr_header_id =>p_x_mr_relation_tbl(i).MR_HEADER_ID,
                   p_related_mr_header_id  =>p_x_mr_relation_tbl(i).RELATED_MR_HEADER_ID,
                   p_related_mr_title=>p_x_mr_relation_tbl(i).RELATED_MR_TITLE);
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

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_MR_RELATION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_MR_RELATION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_MR_RELATION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'PROCESS-->'||sqlerrm,'DEBUG RELATIONS');
	END IF;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>L_API_NAME,
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;
END AHL_FMP_MR_RELATION_PVT;

/
