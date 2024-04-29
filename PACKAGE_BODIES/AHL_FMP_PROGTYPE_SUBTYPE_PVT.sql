--------------------------------------------------------
--  DDL for Package Body AHL_FMP_PROGTYPE_SUBTYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_PROGTYPE_SUBTYPE_PVT" AS
/* $Header: AHLVFPTB.pls 120.2 2008/03/14 11:50:12 pdoki ship $ */
G_PKG_NAME  VARCHAR2(30)  := 'AHL_FMP_PROGTYPE_SUBTYPE_PVT';

--G_DEBUG      VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_prog_type_subtype_tbl  IN OUT NOCOPY AHL_FMP_PROGTYPE_SUBTYPE_PVT.p_x_prog_type_subtype_tbl)
AS
Cursor CurGetProgTypeDet(C_PROG_TYPE_SUBTYPE_ID NUMBER)
IS
SELECT * FROM AHL_PROG_TYPE_SUBTYPES
WHERE  PROG_TYPE_SUBTYPE_ID=C_PROG_TYPE_SUBTYPE_ID;
l_prog_subtype_rec  CurGetProgTypeDet%rowtype;
BEGIN
        IF p_x_prog_type_subtype_tbl.count >0
        THEN

        FOR i IN  p_x_prog_type_subtype_tbl.FIRST.. p_x_prog_type_subtype_tbl.LAST
        LOOP

        IF p_x_prog_type_subtype_tbl(I).DML_OPERATION='C'
        THEN
                IF p_x_prog_type_subtype_tbl(I).PROGRAM_TYPE_CODE= FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(I).PROGRAM_TYPE_CODE:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(I).PROGRAM_SUBTYPE_CODE= FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(I).PROGRAM_SUBTYPE_CODE:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(I).PROG_TYPE_SUBTYPE_ID= FND_API.G_MISS_NUM
                THEN
                        p_x_prog_type_subtype_tbl(I).PROG_TYPE_SUBTYPE_ID:=NULL;
                END IF;
                IF p_x_prog_type_subtype_tbl(i).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                        IF p_x_prog_type_subtype_tbl(i).dml_operation='C'
                        THEN
                                p_x_prog_type_subtype_tbl(i).OBJECT_VERSION_NUMBER:=1;
                        ELSE
                                p_x_prog_type_subtype_tbl(i).OBJECT_VERSION_NUMBER:=NULL;
                        END IF;
                END IF;

                IF  p_x_prog_type_subtype_tbl(i).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE_CATEGORY:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE1=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE1:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE2=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE2:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE3=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE3:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE4=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE4:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE5=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE5:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE6=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE6:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE7=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE7:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE8=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE8:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE9=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE9:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE10=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE10:=NULL;
                END IF;

                IF  p_x_prog_type_subtype_tbl(i).ATTRIBUTE11=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE11:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE12=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE12:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE13=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE13:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE14=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE14:=NULL;
                END IF;

                IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE15=FND_API.G_MISS_CHAR
                THEN
                        p_x_prog_type_subtype_tbl(i).ATTRIBUTE15:=NULL;
                END IF;
        ELSIF p_x_prog_type_subtype_tbl(I).DML_OPERATION='U'
        THEN
         OPEN   CurGetProgTypeDet(p_x_prog_type_subtype_tbl(i).PROG_TYPE_SUBTYPE_ID);
         FETCH  CurGetProgTypeDet INTO l_prog_subtype_rec;
         CLOSE  CurGetProgTypeDet;
                 IF p_x_prog_type_subtype_tbl(i).PROG_TYPE_SUBTYPE_ID IS NULL
                 THEN
                  p_x_prog_type_subtype_tbl(i).PROG_TYPE_SUBTYPE_ID
                                      :=l_prog_subtype_rec.PROG_TYPE_SUBTYPE_ID;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).OBJECT_VERSION_NUMBER IS NULL
                 THEN
                 p_x_prog_type_subtype_tbl(i).OBJECT_VERSION_NUMBER:=
                                                  l_prog_subtype_rec.OBJECT_VERSION_NUMBER;
                 END IF;



                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE14 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE14:=l_prog_subtype_rec.ATTRIBUTE14;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE15 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE15:=l_prog_subtype_rec.ATTRIBUTE15;
                 END IF;


                 IF p_x_prog_type_subtype_tbl(i).PROGRAM_TYPE_CODE IS NULL
                 THEN
                       p_x_prog_type_subtype_tbl(i).PROGRAM_TYPE_CODE:=
                                      l_prog_subtype_rec.PROGRAM_TYPE_CODE;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).PROGRAM_SUBTYPE_CODE IS NULL
                 THEN
                  p_x_prog_type_subtype_tbl(i).PROGRAM_SUBTYPE_CODE
                                       :=l_prog_subtype_rec.PROGRAM_SUBTYPE_CODE;
                 END IF;


                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE_CATEGORY IS NULL
                 THEN
                  p_x_prog_type_subtype_tbl(i).ATTRIBUTE_CATEGORY:=
                                                l_prog_subtype_rec.ATTRIBUTE_CATEGORY;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE1 IS NULL
                 THEN
                     p_x_prog_type_subtype_tbl(i).ATTRIBUTE1:=l_prog_subtype_rec.ATTRIBUTE1;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE2 IS NULL
                 THEN
                       p_x_prog_type_subtype_tbl(i).ATTRIBUTE2:=l_prog_subtype_rec.ATTRIBUTE2;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE3 IS NULL
                 THEN
                       p_x_prog_type_subtype_tbl(i).ATTRIBUTE3:=l_prog_subtype_rec.ATTRIBUTE3;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE4 IS NULL
                 THEN
                       p_x_prog_type_subtype_tbl(i).ATTRIBUTE4:=l_prog_subtype_rec.ATTRIBUTE4;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE5 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE5:=l_prog_subtype_rec.ATTRIBUTE5;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE6 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE6:=l_prog_subtype_rec.ATTRIBUTE6;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE7 IS NULL
                 THEN
                       p_x_prog_type_subtype_tbl(i).ATTRIBUTE7:=l_prog_subtype_rec.ATTRIBUTE7;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE8 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE8:=l_prog_subtype_rec.ATTRIBUTE8;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE9 IS NULL
                 THEN
                    p_x_prog_type_subtype_tbl(i).ATTRIBUTE9:=l_prog_subtype_rec.ATTRIBUTE9;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE10 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE10:=l_prog_subtype_rec.ATTRIBUTE10;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE11 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE11:=l_prog_subtype_rec.ATTRIBUTE11;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE12 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE12:=l_prog_subtype_rec.ATTRIBUTE12;
                 END IF;

                 IF p_x_prog_type_subtype_tbl(i).ATTRIBUTE13 IS NULL
                 THEN
                      p_x_prog_type_subtype_tbl(i).ATTRIBUTE13:=l_prog_subtype_rec.ATTRIBUTE13;
                 END IF;

        END IF;

        END LOOP;

        END IF;
END;


PROCEDURE TRANS_VALUE_TO_ID
 (
 p_api_version               IN     NUMBER:=1.0,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_module_type               IN     VARCHAR2 ,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_prog_type_subtype_rec  IN OUT  NOCOPY prog_type_subtype_rec
 )
as
CURSOR get_lookup_type_code(c_lookup_code VARCHAR2,c_lookup_type VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_code = c_lookup_code
   AND lookup_type = c_lookup_type
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

CURSOR get_lookup_meaning_to_code(c_lookup_type VARCHAR2,c_meaning  VARCHAR2)
 IS
SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type= c_lookup_type
   AND upper(meaning) =upper(c_meaning)
   AND sysdate between start_date_active
   AND nvl(end_date_active,sysdate);

CURSOR check_prog_subtype(C_PROGRAM_TYPE_CODE VARCHAR2,C_PROGRAM_SUBTYPE_CODE VARCHAR2)
 IS
SELECT count(*)
  FROM AHL_PROG_TYPE_SUBTYPES
  WHERE
  UPPER(PROGRAM_TYPE_CODE)=UPPER(C_PROGRAM_TYPE_CODE)  AND
  UPPER(PROGRAM_SUBTYPE_CODE)=UPPER(C_PROGRAM_SUBTYPE_CODE);

 l_lookup_code           VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(30):= 'TRANS_VALUE_TO_ID';
 l_check_flag            VARCHAR2(1):='N';
 BEGIN

  IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_x_prog_type_subtype_rec.dml_operation='C'
     THEN
        p_x_prog_type_subtype_rec.object_version_number:=1;
     END IF;

     IF p_x_prog_type_subtype_rec.dml_operation<>'C'
     THEN

             IF p_x_prog_type_subtype_rec.object_version_number is null  or
                p_x_prog_type_subtype_rec.object_version_number =FND_API.G_MISS_NUM
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_PT_OBJ_VERSION_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE,false);
                FND_MSG_PUB.ADD;
             END IF;

             IF p_x_prog_type_subtype_rec.PROG_TYPE_SUBTYPE_ID is null or
                p_x_prog_type_subtype_rec.PROG_TYPE_SUBTYPE_ID =fnd_api.g_miss_num
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGSUBTYPE_ID_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE,false);
                FND_MSG_PUB.ADD;
             END IF;
     END IF;

     IF p_x_prog_type_subtype_rec.dml_operation<>'D'
     THEN
             IF p_x_prog_type_subtype_rec.PROGRAM_TYPE is null  or
                p_x_prog_type_subtype_rec.PROGRAM_TYPE=FND_API.G_MISS_CHAR
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGTYPE_NULL');
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
             ELSE
                l_check_flag:='Y';
             END IF;

             IF p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE is null or
                p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE=FND_API.G_MISS_char
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGSUBTYPE_NULL');
                FND_MESSAGE.SET_TOKEN('RECORD',p_x_prog_type_subtype_rec.PROGRAM_TYPE,false);
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
             ELSE
                l_check_flag:='Y';
             END IF;

           IF l_check_flag='Y'
           THEN
--         Program type meaning to ID

               OPEN  get_lookup_meaning_to_code('AHL_FMP_MR_PROGRAM_TYPE',p_x_prog_type_subtype_rec.PROGRAM_TYPE);
               FETCH get_lookup_meaning_to_code INTO l_lookup_code;
               IF get_lookup_meaning_to_code%NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROG_TYPE_INVALID');
                   FND_MESSAGE.SET_TOKEN('RECORD',p_x_prog_type_subtype_rec.PROGRAM_TYPE,false);
                   FND_MSG_PUB.ADD;
               ELSE
                   p_x_prog_type_subtype_rec.PROGRAM_TYPE_CODE:=l_lookup_code;
               END IF;

               CLOSE get_lookup_meaning_to_code;

--          Program Sub type type meaning to ID

               OPEN  get_lookup_meaning_to_code('AHL_FMP_MR_PROGRAM_SUBTYPE',
                                                 p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE);
               FETCH get_lookup_meaning_to_code INTO l_lookup_code;
               IF get_lookup_meaning_to_code%NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROGSUBTYPE_INVALID');
                   FND_MESSAGE.SET_TOKEN('FIELD',p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE,false);
                   FND_MSG_PUB.ADD;
               ELSE
                   p_x_prog_type_subtype_rec.PROGRAM_SUBTYPE_CODE:=l_lookup_code;
               END IF;

               CLOSE get_lookup_meaning_to_code;

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
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  L_API_NAME,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;


PROCEDURE VALIDATE_MR_PROGSUBTYPE
 (
 p_api_version               IN     NUMBER:=1.0,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_module_type               IN     VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_prog_type_subtype_rec     IN     prog_type_subtype_rec
 )
as
 --pdoki commented for bug 6892047
 /*CURSOR check_prog_subtype(C_PROGRAM_TYPE_CODE VARCHAR2,C_PROGRAM_SUBTYPE_CODE VARCHAR2)
  IS
  SELECT count(*)
  FROM AHL_PROG_TYPE_SUBTYPES
  WHERE
  UPPER(PROGRAM_TYPE_CODE)=UPPER(C_PROGRAM_TYPE_CODE)  AND
  UPPER(PROGRAM_SUBTYPE_CODE)=UPPER(C_PROGRAM_SUBTYPE_CODE);*/

 l_lookup_code           VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(30):= 'VALIDATE_MR_PROGSUBTYPE';
 l_check_flag            VARCHAR2(1):='N';
 --l_counter               number:=0; --pdoki commented for bug 6892047
 l_cnt_mrs_subtype       NUMBER;
 l_prog_sub_type         VARCHAR2(30);
 BEGIN

        IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


     IF  p_prog_type_subtype_rec.object_version_number  is null
      or  p_prog_type_subtype_rec.object_version_number=FND_API.G_MISS_NUM
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_OBJ_VERSION_NULL');
        FND_MESSAGE.SET_TOKEN('RECORD',p_prog_type_subtype_rec.PROGRAM_SUBTYPE,false);
        FND_MSG_PUB.ADD;
     END IF;

     IF p_prog_type_subtype_rec.dml_operation<>'D'
     THEN
             IF p_prog_type_subtype_rec.PROGRAM_TYPE is null
              or p_prog_type_subtype_rec.PROGRAM_TYPE=FND_API.G_MISS_char
             THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_PROG_TYPE_INVALID');
                FND_MESSAGE.SET_TOKEN('RECORD',p_prog_type_subtype_rec.PROGRAM_TYPE,false);
                FND_MSG_PUB.ADD;
                l_check_flag:='N';
             ELSE
                l_check_flag:='Y';
             END IF;

           --pdoki commented for bug 6892047
          /* l_counter:=0;
             OPEN  check_prog_subtype(p_prog_type_subtype_rec.PROGRAM_TYPE_CODE,
                                      p_prog_type_subtype_rec.PROGRAM_SUBTYPE_CODE);

             FETCH check_prog_subtype INTO l_counter;

             IF l_counter>0 and p_prog_type_subtype_rec.dml_operation<>'D'
             THEN
                 FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_SUBTYPE_DUP');
                 FND_MESSAGE.SET_TOKEN('RECORD',p_prog_type_subtype_rec.PROGRAM_SUBTYPE, false);
                 FND_MSG_PUB.ADD;
             END IF;
             CLOSE check_prog_subtype; */
      ELSE
      --AMSRINIV. Bug 2730079. Added code to throw error if subtype asccociated to MRs is selected for delete.
      --START
              l_cnt_mrs_subtype :=0;
              SELECT COUNT(MR_HEADER_ID) INTO l_cnt_mrs_subtype
              FROM   AHL_MR_HEADERS_B
              WHERE  PROGRAM_TYPE_CODE = (SELECT PROGRAM_TYPE_CODE
                                            FROM   AHL_PROG_TYPE_SUBTYPES
                                            WHERE  PROG_TYPE_SUBTYPE_ID = p_prog_type_subtype_rec.PROG_TYPE_SUBTYPE_ID)
                       AND PROGRAM_SUBTYPE_CODE = (SELECT PROGRAM_SUBTYPE_CODE
                                                   FROM   AHL_PROG_TYPE_SUBTYPES
                                                   WHERE  PROG_TYPE_SUBTYPE_ID = p_prog_type_subtype_rec.PROG_TYPE_SUBTYPE_ID)
                       AND TRUNC(NVL(EFFECTIVE_TO,SYSDATE + 1)) > TRUNC(SYSDATE);
              if l_cnt_mrs_subtype > 0 then
                        SELECT PROGRAM_SUBTYPE_CODE into l_prog_sub_type
                        FROM   AHL_PROG_TYPE_SUBTYPES
                        WHERE  PROG_TYPE_SUBTYPE_ID = p_prog_type_subtype_rec.PROG_TYPE_SUBTYPE_ID;

                           FND_MESSAGE.SET_NAME('AHL','AHL_FMP_DEL_SUBTYP_MR');
                           FND_MESSAGE.SET_TOKEN('RECORD',l_prog_sub_type,false);
                           FND_MSG_PUB.ADD;
              end if;
      --END
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
    fnd_msg_pub.add_exc_msg(p_pkg_name        => g_pkg_name,
                            p_procedure_name  => l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

 PROCEDURE process_prog_type_subtypes
 (
 p_api_version                  IN  NUMBER     :=1.0,
 p_init_msg_list                IN  VARCHAR2,
 p_commit                       IN  VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_prog_type_subtype_tabl     IN OUT NOCOPY p_x_prog_type_subtype_tbl
 )
 As
 l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_PROG_TYPE_SUBTYPES';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_PROG_TYPE_SUBTYPE_ID  NUMBER:=0;
 l_prog_subtype_rec      prog_type_subtype_rec;
 BEGIN
        SAVEPOINT process_prog_type_subtypes;

    -- Standard call to check for call compatibility.
        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(l_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
      AHL_DEBUG_PUB.debug( 'Begin->'||g_pkg_name,'+PROGTYPE+');
        END IF;

        IF p_module_type = 'JSP'
        THEN
                     FOR i IN  p_x_prog_type_subtype_tabl.FIRST.. p_x_prog_type_subtype_tabl.LAST
                     LOOP
                        p_x_prog_type_subtype_tabl(i).PROGRAM_TYPE_CODE:=NULL;
                        p_x_prog_type_subtype_tabl(i).PROGRAM_SUBTYPE_CODE:=NULL;
                     END LOOP;
        END IF;



     FOR i IN  p_x_prog_type_subtype_tabl.FIRST.. p_x_prog_type_subtype_tabl.LAST
     LOOP
        -- Calling for Validation
        l_prog_subtype_rec:=p_x_prog_type_subtype_tabl(i);

         TRANS_VALUE_TO_ID
         (
         p_api_version               =>l_api_version,
         p_init_msg_list             =>l_init_msg_list,
         p_validation_level          =>p_validation_level ,
         p_module_type               =>p_module_type,
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_x_prog_type_subtype_rec   =>l_prog_subtype_rec
         );

         p_x_prog_type_subtype_tabl(i).object_version_number:=l_prog_subtype_rec.object_version_number;
         p_x_prog_type_subtype_tabl(i).PROG_TYPE_SUBTYPE_ID:=l_prog_subtype_rec.PROG_TYPE_SUBTYPE_ID;
         p_x_prog_type_subtype_tabl(i).PROGRAM_TYPE_CODE:=l_prog_subtype_rec.PROGRAM_TYPE_CODE;
         p_x_prog_type_subtype_tabl(i).PROGRAM_TYPE:=l_prog_subtype_rec.PROGRAM_TYPE;
         p_x_prog_type_subtype_tabl(i).PROGRAM_SUBTYPE_CODE:=l_prog_subtype_rec.PROGRAM_SUBTYPE_CODE;
         p_x_prog_type_subtype_tabl(i).PROGRAM_SUBTYPE:=l_prog_subtype_rec.PROGRAM_SUBTYPE;

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
          p_x_prog_type_subtype_tbl       =>p_x_prog_type_subtype_tabl
         );
        END IF;


   -- Calling for Validation


        FOR i IN  p_x_prog_type_subtype_tabl.FIRST.. p_x_prog_type_subtype_tabl.LAST
        LOOP

        -- Calling for Validation
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
        THEN

        VALIDATE_MR_PROGSUBTYPE
         (
         p_api_version               =>l_api_version,
         p_init_msg_list             =>l_init_msg_list,
         p_validation_level          =>p_validation_level ,
         p_module_type               =>p_module_type,
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_prog_type_subtype_rec     =>p_x_prog_type_subtype_tabl(i)
         );

        END IF;
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         END IF;

        if p_x_prog_type_subtype_tabl(i).DML_operation='D' then
          DELETE from AHL_PROG_TYPE_SUBTYPES
          where PROG_TYPE_SUBTYPE_ID =p_x_prog_type_subtype_tabl(i).PROG_TYPE_SUBTYPE_ID
          and   OBJECT_VERSION_NUMBER=p_x_prog_type_subtype_tabl(i).OBJECT_VERSION_NUMBER;

          if sql%rowcount=0 then
                   FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                   FND_MSG_PUB.ADD;
          end if;
        elsif p_x_prog_type_subtype_tabl(i).DML_operation='U' then
             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN

         AHL_PROG_TYPE_SUBTYPES_PKG.UPDATE_ROW (
                          X_PROG_TYPE_SUBTYPE_ID                =>p_x_prog_type_subtype_tabl(i).PROG_TYPE_SUBTYPE_ID,
                          X_OBJECT_VERSION_NUMBER               =>p_x_prog_type_subtype_tabl(i).object_version_number,
                          X_PROGRAM_TYPE_CODE                   =>p_x_prog_type_subtype_tabl(i).PROGRAM_TYPE_CODE,
                          X_PROGRAM_SUBTYPE_CODE                =>p_x_prog_type_subtype_tabl(i).PROGRAM_SUBTYPE_CODE,
                          X_ATTRIBUTE_CATEGORY                  =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE15,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                end if;

       elsif p_x_prog_type_subtype_tabl(i).DML_operation='C' then
             IF x_return_status=FND_API.G_RET_STS_SUCCESS
             THEN


             select AHL_PROG_TYPE_SUBTYPES_S.nextval
             into  p_x_prog_type_subtype_tabl(i).PROG_TYPE_SUBTYPE_ID
             from dual;

              AHL_PROG_TYPE_SUBTYPES_PKG.INSERT_ROW (
                          X_PROG_TYPE_SUBTYPE_ID                =>p_x_prog_type_subtype_tabl(i).PROG_TYPE_SUBTYPE_ID,
                          X_OBJECT_VERSION_NUMBER               =>1,
                          X_PROGRAM_TYPE_CODE                   =>p_x_prog_type_subtype_tabl(i).PROGRAM_TYPE_CODE,
                          X_PROGRAM_SUBTYPE_CODE                =>p_x_prog_type_subtype_tabl(i).PROGRAM_SUBTYPE_CODE,
                          X_ATTRIBUTE_CATEGORY                  =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE1,
                          X_ATTRIBUTE2                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE2,
                          X_ATTRIBUTE3                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE3,
                          X_ATTRIBUTE4                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE4,
                          X_ATTRIBUTE5                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE5,
                          X_ATTRIBUTE6                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE6,
                          X_ATTRIBUTE7                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE7,
                          X_ATTRIBUTE8                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE8,
                          X_ATTRIBUTE9                          =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE9,
                          X_ATTRIBUTE10                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE10,
                          X_ATTRIBUTE11                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE11,
                          X_ATTRIBUTE12                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE12,
                          X_ATTRIBUTE13                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE13,
                          X_ATTRIBUTE14                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE14,
                          X_ATTRIBUTE15                         =>p_x_prog_type_subtype_tabl(i).ATTRIBUTE15,
                          X_CREATION_DATE                       =>sysdate,
                          X_CREATED_BY                          =>fnd_global.user_id,
                          X_LAST_UPDATE_DATE                    =>sysdate,
                          X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                          X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                 end if;
                 end if;

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
      AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_prog_type_subtypes;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_prog_type_subtypes;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO process_prog_type_subtypes;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        => g_pkg_name,
                            p_procedure_name  => l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;
END AHL_FMP_PROGTYPE_SUBTYPE_PVT;

/
