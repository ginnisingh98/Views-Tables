--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_ROUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_ROUTE_PVT" AS
 /* $Header: AHLVMRUB.pls 120.2 2006/02/02 23:29:59 amsriniv noship $ */

G_PKG_NAME      VARCHAR2(30)    :='AHL_FMP_MR_ROUTE_PVT';
G_APPLN_USAGE   VARCHAR2(30)    :=FND_PROFILE.VALUE('AHL_APPLN_USAGE');
G_DEBUG         VARCHAR2(1)     :=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_mr_route_tbl       IN OUT NOCOPY AHL_FMP_MR_ROUTE_PVT.MR_ROUTE_tbl)
AS
        Cursor CurGetRouteDet(C_MR_ROUTE_ID IN NUMBER)
        is
        SELECT
        MR_ROUTE_ID,
        OBJECT_VERSION_NUMBER,
        MR_HEADER_ID,
        ROUTE_ID,
        ROUTE_NUMBER,
        ROUTE_REVISION_NUMBER,
        ROUTE_DESCRIPTION,
        OPERATOR,
        PRODUCT_TYPE,
        STAGE,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
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
        FROM AHL_MR_ROUTES_V
        WHERE MR_ROUTE_ID=C_MR_ROUTE_ID;
        l_mr_route_rec  CurGetRouteDet%rowtype;
BEGIN
        IF P_X_MR_ROUTE_TBL.COUNT >0
        THEN

        FOR i IN  P_X_MR_ROUTE_TBL.FIRST.. P_X_MR_ROUTE_TBL.LAST
        LOOP

        IF P_X_MR_ROUTE_TBL(I).DML_OPERATION<>'D'
        THEN
                open  CurGetRouteDet(P_X_MR_ROUTE_TBL(I).MR_ROUTE_ID);
                fetch CurGetRouteDet into l_mr_route_Rec;
                close CurGetRouteDet;

                IF P_X_MR_ROUTE_TBL(I).MR_ROUTE_ID= FND_API.G_MISS_NUM
                THEN
                P_X_MR_ROUTE_TBL(I).MR_ROUTE_ID:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).MR_ROUTE_ID IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).MR_ROUTE_ID:=l_mr_route_rec.MR_ROUTE_ID;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                P_X_MR_ROUTE_TBL(I).OBJECT_VERSION_NUMBER:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).OBJECT_VERSION_NUMBER IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).OBJECT_VERSION_NUMBER:=l_mr_route_rec.OBJECT_VERSION_NUMBER;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).MR_HEADER_ID= FND_API.G_MISS_NUM
                THEN
                P_X_MR_ROUTE_TBL(I).MR_HEADER_ID:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).MR_HEADER_ID IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).MR_HEADER_ID:=l_mr_route_rec.MR_HEADER_ID;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ROUTE_ID= FND_API.G_MISS_NUM
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_ID:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ROUTE_ID IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_ID:=l_mr_route_rec.ROUTE_ID;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ROUTE_NUMBER= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_NUMBER:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ROUTE_NUMBER IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_NUMBER:=l_mr_route_rec.ROUTE_NUMBER;
                END IF;
            /*
                IF P_X_MR_ROUTE_TBL(I).ROUTE_REVISION_NUMBER= FND_API.G_MISS_NUM
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_REVISION_NUMBER:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ROUTE_REVISION_NUMBER IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_REVISION_NUMBER:=l_mr_route_rec.ROUTE_REVISION_NUMBER;
                END IF;
        */
                IF P_X_MR_ROUTE_TBL(I).ROUTE_DESCRIPTION= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_DESCRIPTION:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ROUTE_DESCRIPTION IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ROUTE_DESCRIPTION:=l_mr_route_rec.ROUTE_DESCRIPTION;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).PRODUCT_TYPE= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).PRODUCT_TYPE:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).PRODUCT_TYPE IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).PRODUCT_TYPE:=l_mr_route_rec.PRODUCT_TYPE;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).OPERATOR= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).OPERATOR:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).OPERATOR IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).OPERATOR:=l_mr_route_rec.OPERATOR;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).STAGE= FND_API.G_MISS_NUM
        THEN
            P_X_MR_ROUTE_TBL(I).STAGE:=NULL;
        ELSIF P_X_MR_ROUTE_TBL(I).STAGE IS NULL
        THEN
            P_X_MR_ROUTE_TBL(I).STAGE:=l_mr_route_rec.STAGE;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE_CATEGORY:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE_CATEGORY IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE_CATEGORY:=l_mr_route_rec.ATTRIBUTE_CATEGORY;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE1= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE1:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE1 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE1:=l_mr_route_rec.ATTRIBUTE1;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE2= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE2:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE2 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE2:=l_mr_route_rec.ATTRIBUTE2;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE3= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE3:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE3 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE3:=l_mr_route_rec.ATTRIBUTE3;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE4= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE4:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE4 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE4:=l_mr_route_rec.ATTRIBUTE4;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE5= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE5:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE5 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE5:=l_mr_route_rec.ATTRIBUTE5;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE6= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE6:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE6 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE6:=l_mr_route_rec.ATTRIBUTE6;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE7= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE7:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE7 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE7:=l_mr_route_rec.ATTRIBUTE7;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE8= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE8:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE8 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE8:=l_mr_route_rec.ATTRIBUTE8;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE9= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE9:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE9 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE9:=l_mr_route_rec.ATTRIBUTE9;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE10= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE10:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE10 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE10:=l_mr_route_rec.ATTRIBUTE10;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE11= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE11:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE11 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE11:=l_mr_route_rec.ATTRIBUTE11;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE12= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE12:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE12 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE12:=l_mr_route_rec.ATTRIBUTE12;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE13= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE13:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE13 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE13:=l_mr_route_rec.ATTRIBUTE13;
                END IF;
                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE14= FND_API.G_MISS_CHAR
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE14:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE14 IS NULL
                THEN
                P_X_MR_ROUTE_TBL(I).ATTRIBUTE14:=l_mr_route_rec.ATTRIBUTE14;
                END IF;

                IF P_X_MR_ROUTE_TBL(I).ATTRIBUTE15= FND_API.G_MISS_CHAR
                THEN
                        P_X_MR_ROUTE_TBL(I).ATTRIBUTE15:=NULL;
                ELSIF P_X_MR_ROUTE_TBL(I).ATTRIBUTE15 IS NULL
                THEN
                        P_X_MR_ROUTE_TBL(I).ATTRIBUTE15:=l_mr_route_rec.ATTRIBUTE15;
                END IF;
        END IF;
        END LOOP;
        END IF;
END;



PROCEDURE TRANS_VALUE_ID
 (
 x_return_status               OUT NOCOPY VARCHAR2,
 p_x_mr_route_rec           IN OUT NOCOPY MR_ROUTE_REC
 )
as
CURSOR get_route_frm(c_route_no VARCHAR2,c_revision_number NUMBER)
IS
--AMSRINIV : Bug 4913924 . Below commented query tuned.
 SELECT
   route_id,
   revision_status_code
 FROM
   ahl_routes_b
 WHERE
   UPPER(route_no)=UPPER(c_route_no) AND
   revision_number=NVL(c_revision_number,revision_number) AND
   TRUNC(NVL(end_date_active,SYSDATE+1))>TRUNC(SYSDATE) AND
   revision_status_code='COMPLETE' AND
   application_usg_code = RTRIM(LTRIM(fnd_profile.value('AHL_APPLN_USAGE')));

/*select ROUTE_ID,REVISION_STATUS_CODE
from AHL_ROUTES_V
where UPPER(ROUTE_NO)=upper(C_ROUTE_NO)
and  revision_number=nvl(C_REVISION_NUMBER,revision_number)
and TRUNC(NVL(END_DATE_ACTIVE,SYSDATE+1))>TRUNC(SYSDATE)
AND REVISION_STATUS_CODE='COMPLETE';*/

l_route_rec                get_route_frm%rowtype;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;
        IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug( 'Route Revision number'||p_x_mr_route_rec.route_revision_number);
    END IF;

        IF (p_x_mr_route_rec.route_number IS NULL or
            p_x_mr_route_rec.route_number=FND_API.G_MISS_CHAR) and
            p_x_mr_route_rec.dml_operation<>'D'
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_NULL');
                FND_MSG_PUB.ADD;
        ELSE
                OPEN  get_route_frm(p_x_mr_route_rec.route_number,p_x_mr_route_rec.route_revision_number);
                FETCH get_route_frm INTO l_route_rec;

                IF get_route_frm%NOTFOUND
                THEN
                      FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_INVALID');
                      FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_rec.route_number,false);
                      FND_MSG_PUB.ADD;
                ELSE
                      p_x_mr_route_rec.ROUTE_ID:=l_route_rec.route_id;
                END IF;
                CLOSE get_route_frm;
        END IF;
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;
END;

PROCEDURE VALIDATE_MR_ROUTE
 (
 x_return_status               OUT NOCOPY VARCHAR2,
 p_mr_route_rec              IN     MR_ROUTE_REC
 )
as
-- AHL_FMP_MR_SELCT_RT_FROM_LOV (ROUTE_NUMBER
CURSOR  GetMrDet(c_mr_header_id  NUMBER)
 IS
SELECT MR_STATUS_CODE,TYPE_CODE
   from AHL_MR_HEADERS_APP_V
   where MR_HEADER_ID=c_mr_header_id
   and MR_STATUS_CODE in('DRAFT','APPROVAL_REJECTED');

 l_mr_rec                GetMrDet%rowtype;

 l_api_name     CONSTANT VARCHAR2(30) := 'VALIDATE_MR_ROUTE';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_appln_code                   VARCHAR2(30);
 l_counter              NUMBER:=0;

 -- Tamal [MEL/CDL] -- Begin changes
 l_mr_prog_type         varchar2(30);
 l_route_type           varchar2(30);
 -- Tamal [MEL/CDL] -- End changes

 BEGIN
     x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF G_APPLN_USAGE IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;

-- AHL_FMP_MR_SELCT_RT_FROM_LOV (ROUTE_NUMBER

     IF (p_mr_route_rec.route_revision_number IS NULL OR p_mr_route_rec.route_revision_number=FND_API.G_MISS_NUM) AND p_mr_route_rec.dml_operation<>'D'
     THEN
--AMSRINIV : Bug 4913924 . Below commented query tuned.
         SELECT
           COUNT(*) into l_counter
         FROM
           ahl_routes_b
         WHERE
           route_no=p_mr_route_rec.route_number    AND
           revision_status_code='COMPLETE'    AND
           NVL(end_date_active,SYSDATE+1)>SYSDATE   AND
           application_usg_code = RTRIM(LTRIM(fnd_profile.value('AHL_APPLN_USAGE')));


        /*Select count(*) into l_counter
        From ahl_routes_v
        where route_no=p_mr_route_rec.route_number
        and  revision_status_code='COMPLETE'
        and NVL(end_date_active,SYSDATE+1)>SYSDATE;*/
        IF l_counter >1
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_SELCT_RT_FROM_LOV');
                FND_MESSAGE.SET_TOKEN('ROUTE_NUMBER',p_mr_route_rec.route_number,false);
                FND_MSG_PUB.ADD;
        END IF;
     END IF;


     IF (p_mr_route_rec.MR_HEADER_ID IS NULL OR p_mr_route_rec.MR_HEADER_ID=FND_API.G_MISS_NUM) AND p_mr_route_rec.dml_operation<>'D'
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
        FND_MSG_PUB.ADD;
     ELSE
         OPEN GetMrDet(p_mr_route_rec.MR_HEADER_ID);

         FETCH GetMrDet  into l_mr_rec;

         IF GetMrDet%NOTFOUND
         THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EDIT_STATUS_INVALID');
             FND_MSG_PUB.ADD;
         ELSE
-- PM Code
             IF G_APPLN_USAGE='PM'
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

     IF (p_mr_route_rec.OBJECT_VERSION_NUMBER IS NULL OR p_mr_route_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_num)  and p_mr_route_rec.dml_operation<>'C'
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRR_OBJ_VERSION_NULL');
        FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_rec.route_number,false);
        FND_MSG_PUB.ADD;
     END IF;

     IF (p_mr_route_rec.MR_ROUTE_ID IS NULL OR p_mr_route_rec.MR_ROUTE_ID=FND_API.G_MISS_NUM) AND p_mr_route_rec.dml_operation<>'C'
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_ID_NULL');
        FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_rec.ROUTE_NUMBER,false);
        FND_MSG_PUB.ADD;
     END IF;

     -- Tamal [MEL/CDL] -- Begin changes
     IF (p_mr_route_rec.dml_operation <> 'D')
     THEN
         SELECT program_type_code INTO l_mr_prog_type FROM ahl_mr_headers_app_v WHERE mr_header_id = p_mr_route_rec.mr_header_id;
         SELECT route_type_code INTO l_route_type FROM ahl_routes_app_v WHERE route_id = p_mr_route_rec.route_id;

	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	 THEN
         fnd_log.string
         (
             fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
	     'l_mr_prog_type='||l_mr_prog_type||' - l_route_type='||l_route_type
         );
         END IF;

         IF (l_mr_prog_type = 'MO_PROC' AND nvl(l_route_type, 'X') NOT IN ('M_PROC','O_PROC'))
         THEN
             FND_MESSAGE.SET_NAME('AHL', 'AHL_FMP_MR_ROUTE_TYPE_INV');
             -- Cannot associate route "&RECORD" of non (M), (O) procedure type to maintenance requirement of (M) and (O) procedure program type.
             FND_MESSAGE.SET_TOKEN('RECORD', p_mr_route_rec.ROUTE_NUMBER, false);
             FND_MSG_PUB.ADD;
         END IF;
     END IF;
     -- Tamal [MEL/CDL] -- End changes
 END;

PROCEDURE PROCESS_MR_ROUTE
 (
 p_api_version               IN             NUMBER    := 1.0,
 p_init_msg_list             IN                 VARCHAR2  := FND_API.G_FALSE,
 p_commit                    IN             VARCHAR2  := FND_API.G_FALSE ,
 p_validation_level          IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         VARCHAR2  := FND_API.G_FALSE,
 p_module_type               IN             VARCHAR2  := NULL,
 x_return_status            OUT NOCOPY          VARCHAR2,
 x_msg_count                OUT NOCOPY          NUMBER,
 x_msg_data                 OUT NOCOPY          VARCHAR2,
 p_x_MR_ROUTE_TBL            IN OUT NOCOPY  MR_ROUTE_TBL
 )
As
 l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS_MR_ROUTE';
 l_api_version         CONSTANT NUMBER       := 1.0;
 l_msg_count                    NUMBER;
 l_mr_route_rec                 MR_ROUTE_REC;
 l_max_route_num        NUMBER := NVL(FND_PROFILE.VALUE('AHL_NUMBER_OF_STAGES'), 1);
 l_dummy_varchar        VARCHAR2(1);

 CURSOR check_route_seq_exists
 (
     p_mr_route_id in number
 )
 IS
 SELECT 'X'
 FROM AHL_MR_ROUTE_SEQUENCES
 WHERE mr_route_id = p_mr_route_id OR related_mr_route_id = p_mr_route_id;

 BEGIN

       SAVEPOINT PROCESS_MR_ROUTES_PVT;

   -- Standard call to check for call compatibility.

       IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                          p_api_version,
                                          l_api_name,G_PKG_NAME)  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

       IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
       END IF;

  -- Enable Debug

       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug( 'Begin..'||g_pkg_name,'+PROCESS_MR_ROUTES+');
       END IF;



   --  Initialize API return status to success

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF FND_API.to_boolean(p_default)
       THEN
         DEFAULT_MISSING_ATTRIBS
         (
         p_x_mr_route_tbl             =>p_x_mr_route_tbl
         );
       END IF;


     FOR i IN  P_X_MR_ROUTE_TBL.FIRST.. P_X_MR_ROUTE_TBL.LAST
     LOOP

    -- code for Value_To_ID conversion for parent MR.
        IF (
             p_x_mr_route_tbl(i).mr_header_id IS NULL OR
             p_x_mr_route_tbl(i).mr_header_id = FND_API.G_MISS_NUM
           )
        THEN
        -- Function to convert mr_title,mr_version_number to id
        AHL_FMP_COMMON_PVT.mr_title_version_to_id(
        p_mr_title      =>  p_x_mr_route_tbl(i).mr_title,
        p_mr_version_number =>  p_x_mr_route_tbl(i).mr_version_number,
        x_mr_header_id  =>  p_x_mr_route_tbl(i).mr_header_id,
        x_return_status =>  x_return_status
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

  -- If The Module Type is JSP then Null out the IDs for the attributes based on LOVs.

       IF p_module_type= 'JSP' THEN
          p_x_MR_ROUTE_TBL(i).route_id:=null;
       END IF;

     IF P_X_MR_ROUTE_TBL(I).DML_OPERATION<>'D'
     THEN

        l_mr_route_rec:=p_x_MR_ROUTE_TBL(i);
        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN
                IF P_X_MR_ROUTE_TBL(i).DML_OPERATION<>'D'
                THEN

                        TRANS_VALUE_ID
                         (
                         x_return_status   =>x_return_Status,
                         p_x_mr_route_rec  =>l_mr_route_rec
             );

                p_x_MR_ROUTE_TBL(i).route_id:=l_mr_route_rec.route_id;
                END IF;
         END IF;
      END IF;
     END LOOP;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     FOR i IN  P_X_MR_ROUTE_TBL.FIRST.. P_X_MR_ROUTE_TBL.LAST
     LOOP
        l_mr_route_rec:=p_x_MR_ROUTE_TBL(i);
       IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
       THEN

         VALIDATE_MR_ROUTE
         (
         x_return_status             =>x_return_Status,
         p_mr_route_rec           =>l_mr_route_rec);

       END IF;


       IF P_X_MR_ROUTE_TBL(i).DML_OPERATION='D' then
          DELETE AHL_MR_ROUTE_SEQUENCES a
          where (MR_ROUTE_ID =P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID or RELATED_MR_ROUTE_ID=P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID);


          DELETE AHL_MR_ROUTES
          where  MR_ROUTE_ID =p_x_MR_ROUTE_TBL(i).MR_ROUTE_ID
          and  OBJECT_VERSION_NUMBER=p_x_MR_ROUTE_TBL(i).object_version_number;

          IF sql%rowcount=0 then
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_RECORD_CHANGED');
                   FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_tbl(i).route_number,false);
                   FND_MSG_PUB.ADD;
          END IF;

       ELSIF P_X_MR_ROUTE_TBL(i).DML_operation='U' then

        AHL_MR_ROUTES_PKG.UPDATE_ROW (
                          X_MR_ROUTE_ID                         =>P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID,
                          X_OBJECT_VERSION_NUMBER               =>p_x_MR_ROUTE_TBL(i).object_version_number,
                          X_MR_HEADER_ID                        =>P_X_MR_ROUTE_TBL(i).MR_HEADER_ID,
                          X_ROUTE_ID                            =>P_X_MR_ROUTE_TBL(i).ROUTE_ID,
                          X_STAGE               =>P_X_MR_ROUTE_TBL(i).STAGE,
                          X_ATTRIBUTE_CATEGORY                  =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE15,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);

      ELSIF P_X_MR_ROUTE_TBL(i).DML_operation='C' then


            AHL_MR_ROUTES_PKG.INSERT_ROW (
                          X_MR_ROUTE_ID                         =>P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID,
                          X_OBJECT_VERSION_NUMBER               =>1,
                          X_MR_HEADER_ID                        =>P_X_MR_ROUTE_TBL(i).MR_HEADER_ID,
                          X_ROUTE_ID                            =>P_X_MR_ROUTE_TBL(i).ROUTE_ID,
                          X_STAGE               =>P_X_MR_ROUTE_TBL(i).STAGE,
                          X_ATTRIBUTE_CATEGORY                  =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>P_X_MR_ROUTE_TBL(i).ATTRIBUTE15,
                          X_CREATION_DATE                       =>sysdate,
                          X_CREATED_BY                          =>fnd_global.user_id,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);

        END IF;

     END LOOP;

    -- TAMAL
    IF (P_X_MR_ROUTE_TBL.COUNT > 0)
    THEN
        FOR i IN P_X_MR_ROUTE_TBL.FIRST..P_X_MR_ROUTE_TBL.LAST
        LOOP
            IF (P_X_MR_ROUTE_TBL(i).DML_operation = 'U')
            THEN
                OPEN check_route_seq_exists(P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID);
                FETCH check_route_seq_exists INTO l_dummy_varchar;
                IF (check_route_seq_exists%NOTFOUND)
                THEN
                    IF (P_X_MR_ROUTE_TBL(i).stage < 1 OR P_X_MR_ROUTE_TBL(i).stage > l_max_route_num)
                    THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INV_STAGE_CRT');
                        FND_MESSAGE.SET_TOKEN('ROUTE',P_X_MR_ROUTE_TBL(i).route_number, false);
                        FND_MESSAGE.SET_TOKEN('MAX',l_max_route_num, false);
                        FND_MSG_PUB.ADD;
                    END IF;
                ELSE
                    AHL_FMP_MR_ROUTE_SEQNCE_PVT.VALIDATE_ROUTE_STAGE_SEQ(P_X_MR_ROUTE_TBL(i).MR_ROUTE_ID, true);
                END IF;
                CLOSE check_route_seq_exists;
            ELSIF (P_X_MR_ROUTE_TBL(i).dml_operation = 'C' AND (P_X_MR_ROUTE_TBL(i).stage < 1 OR P_X_MR_ROUTE_TBL(i).stage > l_max_route_num))
            THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INV_STAGE_CRT');
                FND_MESSAGE.SET_TOKEN('ROUTE',P_X_MR_ROUTE_TBL(i).route_number, false);
                FND_MESSAGE.SET_TOKEN('MAX',l_max_route_num, false);
                FND_MSG_PUB.ADD;
            END IF;
        END LOOP;
    END IF;
    -- TAMAL

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
    ROLLBACK TO PROCESS_MR_ROUTES_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;


 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_MR_ROUTES_PVT;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_MR_ROUTES_PVT;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_ROUTE_PVT',
                            p_procedure_name  =>  'PROCESS_MR_ROUTE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END;


END AHL_FMP_MR_ROUTE_PVT;

/
