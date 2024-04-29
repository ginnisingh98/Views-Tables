--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_ROUTE_SEQNCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_ROUTE_SEQNCE_PVT" AS
 /* $Header: AHLVMRSB.pls 120.0 2005/05/26 00:59:55 appldev noship $ */

G_PKG_NAME              VARCHAR2(30):='AHL_FMP_MR_ROUTE_SEQNCE_PVT';
G_DEBUG                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
G_APPLN_USAGE           VARCHAR2(30):=RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));
-- TAMAL
-- Procedure to check for correct route sequence w.r.t stage information for given mr_route...
-- Pass p_route_stage_upd = true for calling from AHL_FMP_MR_ROUTE_PVT, and false otherwise...
PROCEDURE VALIDATE_ROUTE_STAGE_SEQ
(
	p_mr_route_id in number,
	p_route_stage_upd in boolean
)
IS
	l_max_stage_num	NUMBER := FND_PROFILE.VALUE('AHL_NUMBER_OF_STAGES');
	l_min_stage 	NUMBER;
	l_max_stage 	NUMBER;
 	l_route_num	VARCHAR2(30);
 	l_route_stage	NUMBER;

	CURSOR get_mr_route_det
	(
		p_mr_route_id in number
	)
	IS
		SELECT 	route_number, stage
		FROM 	ahl_mr_routes_v
		WHERE 	mr_route_id = p_mr_route_id;

BEGIN

	IF (l_max_stage_num IS NULL OR l_max_stage_num < 1)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_VWP_ST_PROFILE_NOT_DEF');
		FND_MSG_PUB.ADD;
	ELSE

		-- Get the minimum bound for route stage, based on routes executed before
		SELECT	nvl(max(mrr.stage), 1)
		INTO 	l_min_stage
		FROM	ahl_mr_routes_v mrr,
			ahl_mr_route_sequences mrs
		WHERE	mrr.mr_route_id = mrs.mr_route_id and
			mrs.related_mr_route_id = p_mr_route_id;

		-- Get the maximum bound for route stage, based on routes executed after
		SELECT 	nvl(min(mrr.stage), l_max_stage_num)
		INTO 	l_max_stage
		FROM	ahl_mr_routes_v mrr,
			ahl_mr_route_sequences mrs
		WHERE	mrr.mr_route_id = mrs.related_mr_route_id and
			mrs.mr_route_id = p_mr_route_id;

		OPEN get_mr_route_det (p_mr_route_id);
		FETCH get_mr_route_det INTO l_route_num, l_route_stage;
		CLOSE get_mr_route_det;

		IF (l_min_stage > l_max_stage)
		THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ROUTE_SEQ_INV_STAGE');
			FND_MESSAGE.SET_TOKEN('ROUTE', l_route_num, false);
			FND_MSG_PUB.ADD;
		ELSIF (l_route_stage IS NOT NULL AND (l_route_stage < l_min_stage OR l_route_stage > l_max_stage))
		THEN
			IF (p_route_stage_upd)
			THEN
				FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INV_STAGE_UPD');
				FND_MESSAGE.SET_TOKEN('ROUTE',l_route_num, false);
				FND_MESSAGE.SET_TOKEN('MIN',l_min_stage, false);
				FND_MESSAGE.SET_TOKEN('MAX',l_max_stage, false);
				FND_MSG_PUB.ADD;
			ELSE
				FND_MESSAGE.SET_NAME('AHL','AHL_FMP_ROUTE_SEQ_INV_STAGE');
				FND_MESSAGE.SET_TOKEN('ROUTE', l_route_num, false);
				FND_MSG_PUB.ADD;
			END IF;
		END IF;

	END IF;

END VALIDATE_ROUTE_STAGE_SEQ;
-- TAMAL

PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_mr_routeseq_tbl   IN OUT NOCOPY AHL_FMP_MR_ROUTE_SEQNCE_PVT.MR_ROUTE_SEQ_TBL)
AS
CURSOR CurGetSeqDet(c_MR_ROUTE_SEQUENCE_ID    NUMBER)
Is
Select
MR_ROUTE_SEQUENCE_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
MR_ROUTE_ID,
RELATED_MR_ROUTE_ID,
SEQUENCE_CODE,
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
FROM AHL_MR_ROUTE_SEQUENCES_APP_V
Where MR_ROUTE_SEQUENCE_ID=c_MR_ROUTE_SEQUENCE_ID;

l_routeseq_rec  CurGetSeqDet%rowtype;

BEGIN
IF P_X_MR_ROUTESEQ_TBL.COUNT >0
THEN
     FOR i IN  P_X_MR_ROUTESEQ_TBL.FIRST.. P_X_MR_ROUTESEQ_TBL.LAST
     LOOP
        IF P_X_MR_ROUTESEQ_TBL(I).DML_OPERATION<>'D' and P_X_MR_ROUTESEQ_TBL(I).DML_OPERATION<>'C'
        THEN
             OPEN  CurGetSeqDet(P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_SEQUENCE_ID);
             FETCH CurGetSeqDet into l_routeseq_rec;
             CLOSE CurGetSeqDet;

             IF P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_SEQUENCE_ID= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_SEQUENCE_ID:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_SEQUENCE_ID IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_SEQUENCE_ID:=l_routeseq_rec.MR_ROUTE_SEQUENCE_ID;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).OBJECT_VERSION_NUMBER:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).OBJECT_VERSION_NUMBER IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).OBJECT_VERSION_NUMBER:=l_routeseq_rec.OBJECT_VERSION_NUMBER;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_DATE=FND_API.G_MISS_DATE
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_DATE:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_DATE IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_DATE:=l_routeseq_rec.LAST_UPDATE_DATE;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATED_BY= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATED_BY:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATED_BY IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATED_BY:=l_routeseq_rec.LAST_UPDATED_BY;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).CREATION_DATE=FND_API.G_MISS_DATE
             THEN
             P_X_MR_ROUTESEQ_TBL(I).CREATION_DATE:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).CREATION_DATE IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).CREATION_DATE:=l_routeseq_rec.CREATION_DATE;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).SEQUENCE_CODE= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).SEQUENCE_CODE:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).SEQUENCE_CODE IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).SEQUENCE_CODE:=l_routeseq_rec.SEQUENCE_CODE;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_LOGIN= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_LOGIN:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_LOGIN IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).LAST_UPDATE_LOGIN:=l_routeseq_rec.LAST_UPDATE_LOGIN;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_ID= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_ID:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_ID IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).MR_ROUTE_ID:=l_routeseq_rec.MR_ROUTE_ID;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).RELATED_MR_ROUTE_ID= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).RELATED_MR_ROUTE_ID:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).RELATED_MR_ROUTE_ID IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).RELATED_MR_ROUTE_ID:=l_routeseq_rec.RELATED_MR_ROUTE_ID;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).CREATED_BY= FND_API.G_MISS_NUM
             THEN
             P_X_MR_ROUTESEQ_TBL(I).CREATED_BY:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).CREATED_BY IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).CREATED_BY:=l_routeseq_rec.CREATED_BY;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE3= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE3:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE3 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE3:=l_routeseq_rec.ATTRIBUTE3;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE_CATEGORY:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE_CATEGORY IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE_CATEGORY:=l_routeseq_rec.ATTRIBUTE_CATEGORY;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE1= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE1:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE1 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE1:=l_routeseq_rec.ATTRIBUTE1;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE2= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE2:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE2 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE2:=l_routeseq_rec.ATTRIBUTE2;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE4= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE4:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE4 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE4:=l_routeseq_rec.ATTRIBUTE4;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE5= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE5:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE5 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE5:=l_routeseq_rec.ATTRIBUTE5;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE6= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE6:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE6 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE6:=l_routeseq_rec.ATTRIBUTE6;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE7= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE7:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE7 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE7:=l_routeseq_rec.ATTRIBUTE7;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE8= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE8:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE8 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE8:=l_routeseq_rec.ATTRIBUTE8;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE9= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE9:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE9 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE9:=l_routeseq_rec.ATTRIBUTE9;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE10= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE10:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE10 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE10:=l_routeseq_rec.ATTRIBUTE10;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE11= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE11:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE11 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE11:=l_routeseq_rec.ATTRIBUTE11;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE12= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE12:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE12 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE12:=l_routeseq_rec.ATTRIBUTE12;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE13= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE13:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE13 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE13:=l_routeseq_rec.ATTRIBUTE13;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE14= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE14:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE14 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE14:=l_routeseq_rec.ATTRIBUTE14;
             END IF;
             IF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE15= FND_API.G_MISS_CHAR
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE15:=NULL;
             ELSIF P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE15 IS NULL
             THEN
             P_X_MR_ROUTESEQ_TBL(I).ATTRIBUTE15:=l_routeseq_rec.ATTRIBUTE15;
             END IF;
     END IF;

     END LOOP;
END IF;
END;

PROCEDURE VALIDATE_MR_ROUTESEQ
(
 x_return_status            OUT NOCOPY VARCHAR2,
 p_mr_route_Seq_rec          IN  mr_route_seq_rec
)
as
  CURSOR check_mr_route_id(C_MR_ROUTE_ID NUMBER)
  IS
  Select COUNT(*)
  From  AHL_MR_ROUTES_APP_V
  Where MR_ROUTE_ID=C_MR_ROUTE_ID;

-- Check For Unique Combination

  CURSOR CHECK_UNIQ(C_MR_ROUTE_ID NUMBER,C_RELATED_MR_ROUTE_ID NUMBER,C_SEQUENCE_CODE VARCHAR2)
  IS
  Select MR_ROUTE_SEQUENCE_ID
  From  AHL_MR_ROUTE_SEQUENCES_APP_V
  Where MR_ROUTE_ID=C_MR_ROUTE_ID
  And   RELATED_MR_ROUTE_ID=C_RELATED_MR_ROUTE_ID
  And   SEQUENCE_CODE=C_SEQUENCE_CODE;

  l_seq_uniqrec    CHECK_UNIQ%rowtype;

  CURSOR GetMrDet(c_mr_header_id  NUMBER)
  IS
  SELECT MR_STATUS_CODE,TYPE_CODE
  From AHL_MR_HEADERS_APP_V
  Where MR_HEADER_ID=c_mr_header_id
  And MR_STATUS_CODE IN('DRAFT','APPROVAL_REJECTED');

  l_mr_rec               GetMrDet%rowtype;

 l_object_version_number number;
 l_api_name     CONSTANT VARCHAR2(30) := 'VALIDATE_MR_ROUTESEQ';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_mr_header_id          NUMBER:=0;
 l_counter               NUMBER:=0;
 l_counter2              NUMBER:=0;
 l_counter3              NUMBER:=0;
 l_route_id              NUMBER:=0;
 l_rel_mr_route_id       NUMBER:=0;
 l_lookup_code           VARCHAR2(30):='';
 l_appln_code           VARCHAR2(30);
 l_check_flag            VARCHAR2(1):='N';
 BEGIN
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF g_appln_usage is null
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
                FND_MSG_PUB.ADD;
                RETURN;
        END IF;


      IF (p_mr_route_Seq_rec.MR_ROUTE_SEQUENCE_ID IS NULL OR p_mr_route_Seq_rec.MR_ROUTE_SEQUENCE_ID=FND_API.G_MISS_NUM) AND p_mr_route_Seq_rec.dml_operation<>'C'
      THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_SEQ_ID_NULL');
        FND_MSG_PUB.ADD;
      END IF;

      IF (p_mr_route_Seq_rec.OBJECT_VERSION_NUMBER IS NULL OR p_mr_route_Seq_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM)  and p_mr_route_Seq_rec.dml_operation<>'C'
      THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MRRD_OBJ_VERSION_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_Seq_rec.ROUTE_NUMBER ,false);
                FND_MSG_PUB.ADD;
      END IF;

      IF p_mr_ROUTE_SEQ_rec.MR_HEADER_ID IS NULL OR p_mr_ROUTE_SEQ_rec.MR_HEADER_ID=FND_API.G_MISS_NUM
      THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
                FND_MSG_PUB.ADD;
      ELSE
                OPEN GetMrDet(p_mr_ROUTE_SEQ_REC.MR_HEADER_ID);

                FETCH GetMrDet  into l_mr_rec;

                IF GetMrDet%NOTFOUND
                THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_EDIT_STATUS_INVALID');
                    FND_MSG_PUB.ADD;
                ELSE
-- Preventive Maintenance Code

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

  IF  p_mr_route_Seq_rec.dml_operation<>'D'
   THEN
      IF (p_mr_route_Seq_rec.RELATED_MR_ROUTE_ID IS NULL OR
          p_mr_route_Seq_rec.RELATED_MR_ROUTE_ID=FND_API.G_MISS_NUM) AND p_mr_route_Seq_rec.dml_operation<>'D'
      THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_ID_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_Seq_rec.ROUTE_NUMBER ,false);
                FND_MSG_PUB.ADD;
      ELSE
        OPEN  check_mr_route_id(p_mr_route_Seq_rec.mr_route_id);
        FETCH check_mr_route_id INTO l_counter2;
        IF  l_counter2=0
        THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_REL_MR_ROUTE_ID_INV');
            FND_MESSAGE.SET_TOKEN('ROUTENUM',p_mr_route_Seq_rec.ROUTE_NUMBER,false);
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE check_mr_route_id;
      END IF;
      l_counter2:=0;

-- Check for uniq ness of the  Route Sequences
              IF (p_mr_route_Seq_rec.MR_ROUTE_ID IS NOT NULL OR p_mr_route_Seq_rec.MR_ROUTE_ID<>FND_API.G_MISS_NUM
                OR p_mr_route_Seq_rec.related_mr_route_id IS NOT NULL OR p_mr_route_Seq_rec.related_mr_route_id<>FND_API.G_MISS_NUM
                OR p_mr_route_Seq_rec.sequence_code IS NOT NULL OR p_mr_route_Seq_rec.sequence_code<>FND_API.G_MISS_CHAR)
              THEN

              IF p_mr_route_Seq_rec.sequence_code='BEFORE' and p_mr_route_Seq_rec.dml_operation<>'D'
              THEN
                  OPEN  check_uniq(p_mr_route_Seq_rec.related_mr_route_id,p_mr_route_Seq_rec.mr_route_id,'AFTER');
              ELSE
                  OPEN  check_uniq(p_mr_route_Seq_rec.mr_route_id,p_mr_route_Seq_rec.related_mr_route_id,p_mr_route_Seq_rec.sequence_code);
              END IF;
                FETCH check_uniq INTO l_seq_uniqrec;
                IF  check_uniq%found and p_mr_route_Seq_rec.dml_operation='C'
                THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_SEQUENCE_DUP');
                    FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_Seq_rec.ROUTE_NUMBER,false);
                    FND_MSG_PUB.ADD;
                ELSIF  check_uniq%found and p_mr_route_Seq_rec.dml_operation='U'
                THEN
                    IF p_mr_route_Seq_rec.MR_ROUTE_SEQUENCE_ID<>l_seq_uniqrec.MR_ROUTE_SEQUENCE_ID
                    THEN
                            FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_SEQUENCE_DUP');
                            FND_MESSAGE.SET_TOKEN('RECORD',p_mr_route_Seq_rec.ROUTE_NUMBER,false);
                            FND_MSG_PUB.ADD;
                    END IF;
                END IF;
                CLOSE check_UNIQ;
                END IF;
     END IF;
 END;


PROCEDURE TRANSLATE_VALUE_MRROUTENUM
 (
 x_return_status               OUT NOCOPY VARCHAR2,
 p_x_mr_route_seq_rec        IN OUT NOCOPY mr_route_seq_rec)
as
  CURSOR get_route_frm(c_route_no VARCHAR2, c_revision_number NUMBER)
  IS
  Select ROUTE_ID
  From AHL_ROUTES_APP_V
  WHERE UPPER(LTRIM(RTRIM(ROUTE_NO)))=UPPER(LTRIM(RTRIM(C_ROUTE_NO)))
  AND   NVL(END_DATE_ACTIVE,SYSDATE+1) >SYSDATE
  AND revision_number = c_revision_number;

  CURSOR  get_mr_route_id(C_ROUTE_ID NUMBER,C_MR_HEADER_ID NUMBER)
  IS
  Select MR_ROUTE_ID
  From  AHL_MR_ROUTES_APP_V
  Where ROUTE_ID=C_ROUTE_ID
  And   MR_HEADER_ID=C_MR_HEADER_ID;
  CURSOR  get_route_num_routeid(C_MR_ROUTE_ID NUMBER)
  IS
  Select ROUTE_NUMBER,ROUTE_ID
  From  AHL_MR_ROUTES_V
  Where MR_ROUTE_ID=C_MR_ROUTE_ID;

  L_ROUTE_NUMBER_REC        get_route_num_routeid%ROWTYPE;


  CURSOR check_mr_route_id(C_MR_HEADER_ID NUMBER,C_ROUTE_ID NUMBER)
  IS
  Select COUNT(*)
  From  AHL_MR_ROUTES_APP_V
  Where MR_HEADER_ID=C_MR_HEADER_ID
  And   ROUTE_ID<>C_ROUTE_ID;

-- Check For Unique Combination

  CURSOR CHECK_UNIQ(C_MR_ROUTE_ID NUMBER,C_RELATED_MR_ROUTE_ID NUMBER,C_SEQUENCE_CODE VARCHAR2)
  IS
  Select count(*)
  From  AHL_MR_ROUTE_SEQUENCES_APP_V
  Where MR_ROUTE_ID=C_MR_ROUTE_ID
  And   RELATED_MR_ROUTE_ID=C_RELATED_MR_ROUTE_ID
  And   SEQUENCE_CODE=C_SEQUENCE_CODE;


 l_object_version_number number;
 l_api_name     CONSTANT VARCHAR2(30) := 'TRANSLATE_VALUE_MRROUTENUM';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_mr_header_id          NUMBER:=0;
 l_counter               NUMBER:=0;
 l_counter2              NUMBER:=0;
 l_counter3              NUMBER:=0;
 l_route_id              NUMBER:=0;
 l_rel_mr_route_id       NUMBER:=0;
 l_lookup_code           VARCHAR2(30):='';
 l_check_flag            VARCHAR2(1):='N';
 BEGIN

      x_return_status:=FND_API.G_RET_STS_SUCCESS;
      -- validation moved to main procedure
      -- Changed for 11.5.10 Public API.
      /*
      IF (p_x_mr_route_seq_rec.MR_HEADER_ID IS NULL OR p_x_mr_route_seq_rec.MR_HEADER_ID=FND_API.G_MISS_NUM) AND p_x_mr_route_seq_rec.dml_operation<>'D'
      THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_HEADER_ID_NULL');
        FND_MSG_PUB.ADD;
      END IF;
      */

      IF (p_x_mr_route_seq_rec.ROUTE_NUMBER IS NULL OR p_x_mr_route_seq_rec.ROUTE_NUMBER=FND_API.G_MISS_CHAR) AND p_x_mr_route_seq_rec.dml_operation<>'D'
      THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_NULL');
        FND_MSG_PUB.ADD;
      ELSIF p_x_mr_route_seq_rec.dml_operation<>'D'
      THEN
        OPEN    get_route_num_routeid(p_x_mr_route_seq_rec.mr_route_id);
        fetch get_route_num_routeid into l_route_number_rec;
        if get_route_num_routeid%found and l_route_number_rec.route_number=p_x_mr_route_seq_rec.route_number
        then
        AHL_DEBUG_PUB.debug( 'Stage 13','+DEBUG+');
                return;
        end if;
        CLOSE   get_route_num_routeid;

        OPEN  get_route_frm(p_x_mr_route_seq_rec.route_number, p_x_mr_route_seq_rec.route_revision_number);

        FETCH get_route_frm INTO l_route_id;
        IF get_route_frm%NOTFOUND
        THEN
                IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug( 'Error 1','+DEBUG+');
                END IF;
           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_INVALID');
           FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_seq_rec.ROUTE_NUMBER ,false);
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_route_frm;

--        p_x_mr_route_seq_rec.route_id:=l_route_id;

        IF l_route_id is not null  or l_route_id<>fnd_api.g_miss_num
        THEN
                Select count(MR_ROUTE_ID) into l_counter
                  From  AHL_MR_ROUTES_APP_V
                  Where ROUTE_ID=l_route_id
                  And   MR_HEADER_ID=p_x_mr_route_seq_rec.mr_header_id;

                  IF l_counter>1 and
                     (p_x_mr_route_seq_rec.related_mr_route_id is not null  OR
                      p_x_mr_route_seq_rec.related_mr_route_id<>fnd_api.g_miss_num)
                  THEN
                    select count(*) into l_counter3
                    from ahl_mr_routes_APP_V
                    where mr_header_id=p_x_mr_route_seq_rec.mr_header_id
                    and   route_id=l_route_id
                    and   mr_route_id=p_x_mr_route_seq_rec.related_mr_route_id;

                    if l_counter3 > 1
                    then
                          FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_ID_SELECT_LOV');
                          FND_MSG_PUB.ADD;
                    end if;
                  ELSIF l_counter=0
                  THEN
                        IF G_DEBUG='Y' THEN
                                  AHL_DEBUG_PUB.enable_debug;
                                  AHL_DEBUG_PUB.debug( 'Error 2','+DEBUG+');
                        END IF;
                         FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_INVALID');
                         FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_seq_rec.ROUTE_NUMBER ,false);
                         FND_MSG_PUB.ADD;
                  ELSIF l_counter=1
                  THEN
                            OPEN  get_mr_route_id(l_route_id,p_x_mr_route_seq_rec.mr_header_id);
                            FETCH get_mr_route_id INTO p_x_mr_route_seq_rec.related_mr_route_id;
                            IF get_mr_route_id%rowcount=0
                            THEN
                                IF G_DEBUG='Y' THEN
                                          AHL_DEBUG_PUB.enable_debug;
                                          AHL_DEBUG_PUB.debug( 'Error 1','+DEBUG+');
                                END IF;
				FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_INVALID');
                                FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_seq_rec.ROUTE_NUMBER);
                                FND_MSG_PUB.ADD;
                            END IF;
                            CLOSE get_mr_route_id;
                  END IF;

         END IF;
       END IF;

      IF (p_x_mr_route_seq_rec.RELATED_MR_ROUTE_ID IS NULL
         OR p_x_mr_route_seq_rec.RELATED_MR_ROUTE_ID =FND_API.G_MISS_NUM)
         AND p_x_mr_route_seq_rec.dml_operation<>'D'
      THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_ID_NULL');
        FND_MESSAGE.SET_TOKEN('RECORD',p_x_mr_route_seq_rec.ROUTE_NUMBER ,false);
        FND_MSG_PUB.ADD;
      END IF;
 END;

PROCEDURE  NON_CYCLIC_ENF
(
 p_api_version               IN     NUMBER:=1.0,
 p_init_msg_list             IN     VARCHAR2:= FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 p_module_type               IN     VARCHAR2:='JSP',
 x_return_status               OUT NOCOPY VARCHAR2,
 x_msg_count                   OUT NOCOPY NUMBER,
 x_msg_data                    OUT NOCOPY VARCHAR2,
 P_MR_ROUTE_ID               IN NUMBER,
 P_MR_HEADER_ID              IN NUMBER,
 P_MR_ROUTE_NUMBER           IN VARCHAR2
)
AS
l_cyclic_loop           EXCEPTION;
PRAGMA                  EXCEPTION_INIT(l_cyclic_loop,-1436);
l_counter               NUMBER;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        SELECT COUNT(*) INTO l_counter
        FROM  AHL_MR_ROUTE_SEQUENCES A
        WHERE MR_ROUTE_ID IN(SELECT MR_ROUTE_ID FROM AHL_MR_ROUTES_APP_V
                             WHERE MR_HEADER_ID=P_MR_HEADER_ID
                               AND MR_ROUTE_ID=A.MR_ROUTE_ID)
        START WITH RELATED_MR_ROUTE_ID=P_MR_ROUTE_ID
        CONNECT BY PRIOR MR_ROUTE_ID = RELATED_MR_ROUTE_ID;
EXCEPTION
WHEN l_cyclic_loop  THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTENO_INVALID_CYC');
        FND_MESSAGE.SET_TOKEN('RECORD',p_mr_ROUTE_NUMBER ,false);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
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
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_MR_ASSOCIATIONS_PVT',
                            p_procedure_name  =>  'NON_CYCLIC_ENF',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;


PROCEDURE PROCESS_MR_ROUTE_SEQ
 (
 p_api_version               IN     		NUMBER    := 1.0,
 p_init_msg_list             IN                 VARCHAR2  := FND_API.G_FALSE,
 p_commit                    IN     		VARCHAR2  := FND_API.G_FALSE ,
 p_validation_level          IN     		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type               IN     		VARCHAR2  := NULL,
 x_return_status            OUT NOCOPY                VARCHAR2,
 x_msg_count                OUT NOCOPY                NUMBER,
 x_msg_data                 OUT NOCOPY                VARCHAR2,
 p_x_mr_route_seq_tbl        IN OUT NOCOPY 	MR_ROUTE_SEQ_TBL
 )
as
 -- cursor for getting mr_route_id from route_number, route_revision and mr_header id
 -- Added for public API in 11.5.10
 CURSOR get_mr_route_id_type(p_mr_header_id NUMBER, p_route_no VARCHAR2, p_route_revision NUMBER) IS
 SELECT mr_route_id
 FROM AHL_MR_ROUTES_APP_V
 WHERE route_id = (SELECT route_id
 		   FROM  AHL_ROUTES_APP_V
 		   WHERE route_no = p_route_no
 		   AND   revision_number = p_route_revision)
 AND mr_header_id = p_mr_header_id;

 l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_MR_ROUTE_SEQ';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_MR_ROUTE_SEQ_ID       NUMBER:=0;
 l_mr_route_seq_tbl      MR_route_SEQ_TBL:=p_x_mr_route_seq_tbl;
 l_mr_route_seq_rec      MR_ROUTE_SEQ_REC;
 l_mr_route_id           NUMBER:=0;
 -- TAMAL
 l_upd_mr_route_id	NUMBER;
 -- TAMAL
 BEGIN

       SAVEPOINT PROCESS_MR_ROUTE_SEQ;

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

    -- Debug info.

       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'enter PROCESS_MR_ROUTE_SEQ','+ROUTE_SEQ+');
	END IF;


    -- Initialize API return status to success

       x_return_status := FND_API.G_RET_STS_SUCCESS;


   --Start of API Body

     FOR i IN  P_X_MR_ROUTE_SEQ_TBL.FIRST.. P_X_MR_ROUTE_SEQ_TBL.LAST
     LOOP

     	-- Added the code for public API.
	-- code for Value_To_ID conversion for parent MR.
       	IF (
       	     p_x_mr_route_seq_tbl(i).mr_header_id IS NULL  OR
       	     p_x_mr_route_seq_tbl(i).mr_header_id = FND_API.G_MISS_NUM
       	   )
       	THEN
	    -- Function to convert mr_title,mr_version_number to id
	    AHL_FMP_COMMON_PVT.mr_title_version_to_id(
	    p_mr_title		=>	p_x_mr_route_seq_tbl(i).mr_title,
	    p_mr_version_number	=>	p_x_mr_route_seq_tbl(i).mr_version_number,
	    x_mr_header_id	=>	p_x_mr_route_seq_tbl(i).mr_header_id,
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

        if p_x_mr_route_seq_tbl(i).DML_OPERATION='C'
        then
        p_x_mr_route_seq_tbl(i).object_version_number:=1;
        end if;

     -- Code for getting mr_route_id if one is not provided.
     -- Added in 11.5.10 for public API.
     IF (
      	   p_x_mr_route_seq_tbl(i).mr_route_id IS NULL OR
           p_x_mr_route_seq_tbl(i).mr_route_id = FND_API.G_MISS_NUM
        )
        AND
        (
           p_x_mr_route_seq_tbl(i).dml_operation<>'D' AND
           p_x_mr_route_seq_tbl(i).dml_operation<>'d'
        )
     THEN
     	OPEN get_mr_route_id_type(p_x_mr_route_seq_tbl(i).mr_header_id,
     				  p_x_mr_route_seq_tbl(i).mr_route_number,
     				  p_x_mr_route_seq_tbl(i).mr_route_revision
     				 );
     	FETCH get_mr_route_id_type INTO p_x_mr_route_seq_tbl(i).mr_route_id;
     	IF p_x_mr_route_seq_tbl(i).mr_route_id IS NULL
     	THEN
     		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_ROUTE_NUMBR_INVALID');
		FND_MESSAGE.SET_TOKEN('FIELD',p_x_mr_route_seq_tbl(i).mr_route_number);
		FND_MSG_PUB.ADD;
		CLOSE get_mr_route_id_type;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
     	CLOSE get_mr_route_id_type;
     END IF;



     IF P_X_MR_ROUTE_SEQ_TBL(I).DML_operation<>'D'
     THEN
        l_mr_route_seq_rec:=P_X_MR_ROUTE_SEQ_TBL(I);

         TRANSLATE_VALUE_MRROUTENUM
         (
         x_return_status             =>x_return_Status,
         p_x_mr_route_seq_rec        =>l_mr_route_seq_rec
         );

         p_x_mr_route_seq_tbl(i).related_mr_route_id:=l_mr_route_seq_rec.related_mr_route_id;
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
        p_x_mr_routeseq_tbl             =>p_x_mr_route_seq_tbl
        );
        END IF;


     FOR i IN  P_X_MR_ROUTE_SEQ_TBL.FIRST.. P_X_MR_ROUTE_SEQ_TBL.LAST
     LOOP

        x_return_status := FND_API.G_RET_STS_SUCCESS;

       	IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug( '<---MR ROUTE_ID---> ',TO_CHAR(p_x_mr_route_seq_tbl(i).mr_route_id));
	AHL_DEBUG_PUB.debug( '<---RELATED MR ROUTE_ID---> ',TO_CHAR(p_x_mr_route_seq_tbl(i).related_mr_route_id));
        END IF;

       l_mr_route_seq_rec:=P_X_MR_ROUTE_SEQ_TBL(I);

	IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
	THEN

       	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Enter Validations level');
       	END IF;

         VALIDATE_MR_ROUTESEQ
         (
         x_return_status             =>x_return_Status,
         p_mr_route_seq_rec          =>l_mr_route_seq_rec);
        END IF;


        l_msg_count := FND_MSG_PUB.count_msg;
	l_msg_count := 0;

        IF  l_msg_count=0
        THEN

        -- TAMAL --
        IF p_x_mr_route_seq_tbl(i).dml_operation<>'D'
        THEN
		IF p_x_mr_route_seq_tbl(i).sequence_code='BEFORE'
		THEN
	-- TAMAL --
                l_mr_route_id:=p_x_mr_route_seq_tbl(i).related_mr_route_id;
                p_x_mr_route_seq_tbl(i).related_mr_route_id:=p_x_mr_route_seq_tbl(i).mr_route_id;
                p_x_mr_route_seq_tbl(i).mr_route_id:=l_mr_route_id;
                p_x_mr_route_seq_tbl(i).sequence_code:='AFTER';  -- Always Before
			-- TAMAL --
			l_upd_mr_route_id := p_x_mr_route_seq_tbl(i).related_mr_route_id;
		ELSE
			l_upd_mr_route_id := p_x_mr_route_seq_tbl(i).mr_route_id;
			-- TAMAL --
		END IF;
        END IF;


       -- Calling for Validation
       IF L_MR_ROUTE_SEQ_TBL(i).DML_OPERATION='D' then
               AHL_MR_ROUTE_SEQUENCES_PKG.DELETE_ROW(
			X_MR_ROUTE_SEQUENCE_ID =>P_X_MR_ROUTE_SEQ_TBL(i).MR_ROUTE_SEQUENCE_ID);

       ELSIF L_MR_ROUTE_SEQ_TBL(i).DML_operation='U' then

       AHL_MR_ROUTE_SEQUENCES_PKG.UPDATE_ROW (
                          X_MR_ROUTE_SEQUENCE_ID    =>p_x_mr_route_seq_tbl(i).MR_ROUTE_SEQUENCE_ID,
                          X_RELATED_MR_ROUTE_ID     =>p_x_mr_route_seq_tbl(i).RELATED_MR_ROUTE_ID,
                          X_SEQUENCE_CODE           =>p_x_mr_route_seq_tbl(i).SEQUENCE_CODE,
                          X_MR_ROUTE_ID             =>p_x_mr_route_seq_tbl(i).MR_ROUTE_ID,
                          X_OBJECT_VERSION_NUMBER   =>p_x_mr_route_seq_tbl(i).OBJECT_VERSION_NUMBER,
                          X_ATTRIBUTE_CATEGORY      =>p_x_mr_route_seq_tbl(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE1,
                          X_ATTRIBUTE2              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE2,
                          X_ATTRIBUTE3              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE3,
                          X_ATTRIBUTE4              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE4,
                          X_ATTRIBUTE5              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE5,
                          X_ATTRIBUTE6              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE6,
                          X_ATTRIBUTE7              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE7,
                          X_ATTRIBUTE8              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE8,
                          X_ATTRIBUTE9              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE9,
                          X_ATTRIBUTE10             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE10,
                          X_ATTRIBUTE11             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE11,
                          X_ATTRIBUTE12             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE12,
                          X_ATTRIBUTE13             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE13,
                          X_ATTRIBUTE14             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE14,
                          X_ATTRIBUTE15             =>p_x_mr_route_seq_tbl(i).ATTRIBUTE15,
                          X_LAST_UPDATE_DATE        =>sysdate,
                          X_LAST_UPDATED_BY         =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN       =>fnd_global.user_id);

      ELSIF p_x_mr_route_seq_tbl(i).DML_operation='C' then

            		AHL_MR_ROUTE_SEQUENCES_PKG.INSERT_ROW
			(
                          X_MR_ROUTE_SEQUENCE_ID     =>p_x_mr_route_seq_tbl(i).MR_ROUTE_SEQUENCE_ID,
                          X_RELATED_MR_ROUTE_ID      =>p_x_mr_route_seq_tbl(i).RELATED_MR_ROUTE_ID,
                          X_SEQUENCE_CODE            =>p_x_mr_route_seq_tbl(i).SEQUENCE_CODE,
                          X_MR_ROUTE_ID              =>p_x_mr_route_seq_tbl(i).MR_ROUTE_ID,
                          X_OBJECT_VERSION_NUMBER    =>1,
                          X_ATTRIBUTE_CATEGORY       =>p_x_mr_route_seq_tbl(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE1,
                          X_ATTRIBUTE2               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE2,
                          X_ATTRIBUTE3               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE3,
                          X_ATTRIBUTE4               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE4,
                          X_ATTRIBUTE5               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE5,
                          X_ATTRIBUTE6               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE6,
                          X_ATTRIBUTE7               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE7,
                          X_ATTRIBUTE8               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE8,
                          X_ATTRIBUTE9               =>p_x_mr_route_seq_tbl(i).ATTRIBUTE9,
                          X_ATTRIBUTE10              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE10,
                          X_ATTRIBUTE11              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE11,
                          X_ATTRIBUTE12              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE12,
                          X_ATTRIBUTE13              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE13,
                          X_ATTRIBUTE14              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE14,
                          X_ATTRIBUTE15              =>p_x_mr_route_seq_tbl(i).ATTRIBUTE15,
                          X_CREATION_DATE            =>sysdate,
                          X_CREATED_BY               =>fnd_global.user_id,
                          X_LAST_UPDATE_DATE         =>sysdate,
                          X_LAST_UPDATED_BY          =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN        =>fnd_global.user_id);
        END IF;

       IF p_x_mr_route_seq_tbl(i).DML_operation<>'D'
       THEN

         NON_CYCLIC_ENF
         (
         p_api_version               =>l_api_version,
         p_init_msg_list             =>l_init_msg_list,
         p_validation_level          =>p_validation_level ,
         p_module_type               =>p_module_type,
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_mr_route_id               =>p_x_mr_route_seq_tbl(i).mr_route_id,
         p_mr_header_id              =>p_x_mr_route_seq_tbl(i).mr_header_id,
         p_mr_route_number           =>p_x_mr_route_seq_tbl(i).route_number
         );
       END IF;

      END IF;

     END LOOP;

	-- TAMAL
	IF (l_upd_mr_route_id IS NOT NULL)
	THEN
		VALIDATE_ROUTE_STAGE_SEQ(l_upd_mr_route_id, false);
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
    -- Debug info

	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of Private api  PROCESS_MR_ROUTE_SEQ','+MR_ROUTE_ID+');
	END IF;

    -- Check if API is called in debug mode. If yes, disable debug.

	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_MR_ROUTE_SEQ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_MR_ROUTE_SEQ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_MR_ROUTE_SEQ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_FMP_MR_ROUTE_SEQNCE_PVT',
                            p_procedure_name  =>  'PROCESS_MR_ROUTE_SEQ',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;



END AHL_FMP_MR_ROUTE_SEQNCE_PVT;

/
