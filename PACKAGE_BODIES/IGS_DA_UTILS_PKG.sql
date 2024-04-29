--------------------------------------------------------
--  DDL for Package Body IGS_DA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_UTILS_PKG" AS
/* $Header: IGSDA09B.pls 115.4 2004/02/20 15:09:07 kdande noship $ */

/********************************************************************************************************
 Created By         : Jitendra Handa
 Date Created By    : 27-Mar-2003

 Purpose            : This package is to be used for the Self Service
                      activities that happen during the Degree Audit
                      Request Process.  The procedures in this package
                      will be using procedures defined for the processing
                      of request information as well.

 remarks            :

 Change History

Who                  When            What
---------------------------------------------------------------
smanglm              05-Aug-2003     Bug 3084766: Make use of Dynamic Person ID Group if the igs_pe_persid_group_all.FILE_NAME
                                     is not null else make use of static query. Changes made in the CURSOR c_stud_grp_mem of
                                     create_req_stdnts_rec procedure
Jitendra Handa       27-Mar-2003     New Package Created.

***********************************************************************************************************/

 g_pkg_name          CONSTANT     VARCHAR2(30) := 'IGS_DA_UTILS_PKG';

-- This procedure is caled to set the STUDENT_RELEASE_IND to Y
-- Indicating that the report has been released to students and
-- can be viewed by students .
PROCEDURE release_report_to_students
  (
    p_batch_id IN Number
  )IS
begin
 DECLARE

                CURSOR c_da_rqst IS
                    SELECT rowid, da.*
                     FROM IGS_DA_RQST da
                     WHERE BATCH_ID = p_batch_id;

-- Declare local variables :
V_RETURN_STATUS     VARCHAR2(30);
V_MSG_DATA          VARCHAR2(100);
V_MSG_COUNT         NUMBER;
V_DA_RQST           c_da_rqst%ROWTYPE;
BEGIN
-- STUDENT_RELEASE_IND flag will be updated to Y
  OPEN c_da_rqst;
  FETCH c_da_rqst INTO v_da_rqst;
  IF c_da_rqst%ROWCOUNT = 1 THEN
     -- call update_row
     IGS_DA_RQST_PKG.UPDATE_ROW(
                                X_ROWID                          =>   v_da_rqst.ROWID                     ,
                                X_BATCH_ID                       =>   v_da_rqst.BATCH_ID                  ,
                                X_REQUEST_TYPE_ID                =>   v_da_rqst.REQUEST_TYPE_ID           ,
                                X_REQUEST_MODE                   =>   v_da_rqst.REQUEST_MODE              ,
                                X_PROGRAM_COMPARISON_TYPE        =>   v_da_rqst.PROGRAM_COMPARISON_TYPE   ,
                                X_REQUEST_STATUS                 =>   v_da_rqst.REQUEST_STATUS            ,
                                X_PERSON_ID_GROUP_ID             =>   v_da_rqst.PERSON_ID_GROUP_ID        ,
                                X_PERSON_ID                      =>   v_da_rqst.PERSON_ID                 ,
                                X_REQUESTOR_ID                   =>   v_da_rqst.REQUESTOR_ID              ,
                                X_STUDENT_RELEASE_IND            =>   'Y'                                 ,
                                X_SPECIAL_PROGRAM                =>   v_da_rqst.SPECIAL_PROGRAM           ,
                                X_SPECIAL_PROGRAM_CATALOG        =>   v_da_rqst.SPECIAL_PROGRAM_CATALOG   ,
                                X_ATTRIBUTE_CATEGORY             =>   v_da_rqst.ATTRIBUTE_CATEGORY        ,
                                X_ATTRIBUTE1                     =>   v_da_rqst.ATTRIBUTE1                ,
                                X_ATTRIBUTE2                     =>   v_da_rqst.ATTRIBUTE2                ,
                                X_ATTRIBUTE3                     =>   v_da_rqst.ATTRIBUTE3                ,
                                X_ATTRIBUTE4                     =>   v_da_rqst.ATTRIBUTE4                ,
                                X_ATTRIBUTE5                     =>   v_da_rqst.ATTRIBUTE5                ,
                                X_ATTRIBUTE6                     =>   v_da_rqst.ATTRIBUTE6                ,
                                X_ATTRIBUTE7                     =>   v_da_rqst.ATTRIBUTE7                ,
                                X_ATTRIBUTE8                     =>   v_da_rqst.ATTRIBUTE8                ,
                                X_ATTRIBUTE9                     =>   v_da_rqst.ATTRIBUTE9                ,
                                X_ATTRIBUTE10                    =>   v_da_rqst.ATTRIBUTE10               ,
                                X_ATTRIBUTE11                    =>   v_da_rqst.ATTRIBUTE11               ,
                                X_ATTRIBUTE12                    =>   v_da_rqst.ATTRIBUTE12               ,
                                X_ATTRIBUTE13                    =>   v_da_rqst.ATTRIBUTE13               ,
                                X_ATTRIBUTE14                    =>   v_da_rqst.ATTRIBUTE14               ,
                                X_ATTRIBUTE15                    =>   v_da_rqst.ATTRIBUTE15               ,
                                X_ATTRIBUTE16                    =>   v_da_rqst.ATTRIBUTE16               ,
                                X_ATTRIBUTE17                    =>   v_da_rqst.ATTRIBUTE17               ,
                                X_ATTRIBUTE18                    =>   v_da_rqst.ATTRIBUTE18               ,
                                X_ATTRIBUTE19                    =>   v_da_rqst.ATTRIBUTE19               ,
                                X_ATTRIBUTE20                    =>   v_da_rqst.ATTRIBUTE20               ,
                                X_MODE                           =>   'R'                                 ,
                                X_RETURN_STATUS                  =>   v_RETURN_STATUS                     ,
                                X_MSG_DATA                       =>   v_MSG_DATA                          ,
                                X_MSG_COUNT                      =>   v_MSG_COUNT
     );
  END IF;

  CLOSE c_da_rqst;

  EXCEPTION
        WHEN OTHERS THEN
        NULL;
  END;

END release_report_to_students;

PROCEDURE create_req_stdnts_rec (p_batch_id                          IN NUMBER,
                                 X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
                                 X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
                                 X_MSG_COUNT                         OUT NOCOPY    NUMBER
                                ) IS
    l_rowid                VARCHAR2(100);
    l_igs_da_req_stdnts_id NUMBER(30);
    l_return_status        VARCHAR2(100);
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER(25);

    --
    -- declare the ref cursor
    --
      TYPE REF_CUR IS REF CURSOR;

    --
    -- now declare the variables for the above ref curosr
    --
      c_stud_grp_mem   REF_CUR;

    --
    -- declare the out param for the funtion IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL
    --
      l_status VARCHAR2(2000);

    --
    -- declare a variablt to store the person_id that would be obtained from the above ref cursors
    --
      l_person_id igs_pe_person.person_id%TYPE;
    --
    -- cursor to check whether dynamic person_id_group has to be used or not based on the value
    -- of igs_pe_persid_group_all.file_name for the given group_id
    --
    CURSOR c_is_filename_null (cp_group_id igs_pe_persid_group_all.group_id%TYPE) IS
        SELECT 'Y' FROM igs_pe_persid_group_all WHERE group_id = cp_group_id AND file_name IS NULL;
     l_is_filename_null varchar2(1) := 'N';

    CURSOR c_igs_da_rqst (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
           SELECT dr.rowid, dr.*
           FROM   igs_da_rqst dr
           WHERE  batch_id = cp_batch_id;
    rec_igs_da_rqst c_igs_da_rqst%ROWTYPE;

    l_stc_stud_grp_mem VARCHAR2(2000) := ' SELECT person_id FROM igs_pe_prsid_grp_mem WHERE  group_id = :1 ';
    l_dyn_stud_grp_mem VARCHAR2(2000);

    CURSOR c_igs_da_rec_wif (cp_batch_id  igs_da_rqst.batch_id%TYPE) IS
           SELECT *
           FROM   igs_da_req_wif
           WHERE  batch_id = cp_batch_id;

    CURSOR c_prog_attempt (cp_person_id igs_da_rqst.person_id%TYPE) IS
           SELECT course_cd
           FROM  igs_en_stdnt_ps_att
           WHERE person_id = cp_person_id
           AND   course_attempt_status NOT IN ('DISCONTIN','UNCONFIRM');

    CURSOR c_dff (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
           SELECT crt.*
           FROM   igs_da_cnfg_req_typ  crt,
                  igs_da_rqst dr
           WHERE  crt.request_type_id = dr.request_type_id
           AND    dr.batch_id = cp_batch_id;
    rec_dff c_dff%ROWTYPE;

    CURSOR c_req_ftrs (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
           SELECT cf.feature_code,
                  cf.feature_value
           FROM   igs_da_cnfg_ftr cf,
                  igs_da_rqst dr
           WHERE  dr.request_type_id = cf.request_type_id
           AND    dr.batch_id = cp_batch_id
           AND    cf.feature_code IN (SELECT feature_code
                                      FROM   igs_da_cnfg_ftr cf_in
                                      WHERE  cf_in.request_type_id = dr.request_type_id
                                      MINUS
                                      SELECT feature_code
                                      FROM   igs_da_req_ftrs rf_in
                                      WHERE  rf_in.batch_id = dr.batch_id);
BEGIN
  FND_MSG_PUB.initialize;
  OPEN c_igs_da_rqst (p_batch_id);
  LOOP
     FETCH c_igs_da_rqst INTO rec_igs_da_rqst;
     EXIT WHEN c_igs_da_rqst%NOTFOUND;
     -- check whether the dynamic persid group has to be used or not
     OPEN c_is_filename_null (rec_igs_da_rqst.person_id_group_id);
     FETCH c_is_filename_null INTO l_is_filename_null;
     CLOSE c_is_filename_null;

     IF rec_igs_da_rqst.program_comparison_type = 'SP' THEN
        -- insert a corresponding record in igs_da_req_stdnts if a single student
        IF rec_igs_da_rqst.request_mode = 'SINGLE' THEN
             l_rowid := null;
             l_igs_da_req_stdnts_id := null;
             igs_da_req_stdnts_pkg.insert_row (
                                                X_ROWID                        => l_rowid,
                                                X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                X_PERSON_ID                    => rec_igs_da_rqst.person_id,
                                                X_PROGRAM_CODE                 => NULL,
                                                X_WIF_PROGRAM_CODE             => NULL,
                                                X_SPECIAL_PROGRAM_CODE         => rec_igs_da_rqst.special_program,
                                                X_MAJOR_UNIT_SET_CD            => NULL,
                                                X_PROGRAM_MAJOR_CODE           => NULL,
                                                X_REPORT_TEXT                  => NULL,
                                                X_WIF_ID                       => NULL,
                                                X_MODE                         => 'R',
                                                x_error_code                   => NULL
                                              );
        ELSE
       IF l_is_filename_null = 'N' THEN
                l_dyn_stud_grp_mem := IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL (rec_igs_da_rqst.person_id_group_id,l_status);
                IF l_status <> FND_API.G_RET_STS_SUCCESS THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_AZ_DYN_PERS_ID_GRP_ERR');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                OPEN c_stud_grp_mem FOR l_dyn_stud_grp_mem;
             ELSE
                OPEN c_stud_grp_mem FOR l_stc_stud_grp_mem USING rec_igs_da_rqst.person_id_group_id;
             END IF;
       LOOP
               FETCH c_stud_grp_mem INTO l_person_id;
                     EXIT WHEN c_stud_grp_mem%NOTFOUND;
                     l_rowid := null;
                     l_igs_da_req_stdnts_id := null;
                     igs_da_req_stdnts_pkg.insert_row (
                                                        X_ROWID                        => l_rowid,
                                                        X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                        X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                        X_PERSON_ID                    => l_person_id,
                                                        X_PROGRAM_CODE                 => NULL,
                                                        X_WIF_PROGRAM_CODE             => NULL,
                                                        X_SPECIAL_PROGRAM_CODE         => rec_igs_da_rqst.special_program,
                                                        X_MAJOR_UNIT_SET_CD            => NULL,
                                                        X_PROGRAM_MAJOR_CODE           => NULL,
                                                        X_REPORT_TEXT                  => NULL,
                                                        X_WIF_ID                       => NULL,
                                                        X_MODE                         => 'R',
                                                        x_error_code                   => NULL
                                                      );
             END LOOP;
       CLOSE c_stud_grp_mem;
        END IF;  -- rec_igs_da_rqst.request_mode = 'SINGLE' SP
     ELSIF rec_igs_da_rqst.program_comparison_type = 'WIF' THEN
        FOR rec_igs_da_rec_wif IN c_igs_da_rec_wif(rec_igs_da_rqst.batch_id) LOOP
                IF rec_igs_da_rqst.request_mode = 'SINGLE' THEN
                     l_rowid := null;
                     l_igs_da_req_stdnts_id := null;
                     igs_da_req_stdnts_pkg.insert_row (
                                                        X_ROWID                        => l_rowid,
                                                        X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                        X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                        X_PERSON_ID                    => rec_igs_da_rqst.person_id,
                                                        X_PROGRAM_CODE                 => NULL,
                                                        X_WIF_PROGRAM_CODE             => rec_igs_da_rec_wif.program_code,
                                                        X_SPECIAL_PROGRAM_CODE         => NULL,
                                                        X_MAJOR_UNIT_SET_CD            => rec_igs_da_rec_wif.major_unit_set_cd1,
                                                        X_PROGRAM_MAJOR_CODE           => NULL,
                                                        X_REPORT_TEXT                  => NULL,
                                                        X_WIF_ID                       => rec_igs_da_rec_wif.wif_id,
                                                        X_MODE                         => 'R',
                                                        x_error_code                   => NULL
                                                      );
                ELSE
                     IF l_is_filename_null = 'N' THEN
                        l_dyn_stud_grp_mem := IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL (rec_igs_da_rqst.person_id_group_id,l_status);
                        IF l_status <> FND_API.G_RET_STS_SUCCESS THEN
                           FND_MESSAGE.SET_NAME('IGS','IGS_AZ_DYN_PERS_ID_GRP_ERR');
                           FND_MSG_PUB.ADD;
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        OPEN c_stud_grp_mem FOR l_dyn_stud_grp_mem;
                     ELSE
                        OPEN c_stud_grp_mem FOR l_stc_stud_grp_mem USING rec_igs_da_rqst.person_id_group_id;
                     END IF;
                     LOOP
                             FETCH c_stud_grp_mem INTO l_person_id;
                             EXIT WHEN c_stud_grp_mem%NOTFOUND;
                             l_rowid := null;
                             l_igs_da_req_stdnts_id := null;
                             igs_da_req_stdnts_pkg.insert_row (
                                                                X_ROWID                        => l_rowid,
                                                                X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                                X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                                X_PERSON_ID                    => l_person_id,
                                                                X_PROGRAM_CODE                 => NULL,
                                                                X_WIF_PROGRAM_CODE             => rec_igs_da_rec_wif.program_code,
                                                                X_SPECIAL_PROGRAM_CODE         => NULL,
                                                                X_MAJOR_UNIT_SET_CD            => rec_igs_da_rec_wif.major_unit_set_cd1,
                                                                X_PROGRAM_MAJOR_CODE           => NULL,
                                                                X_REPORT_TEXT                  => NULL,
                                                                X_WIF_ID                       => rec_igs_da_rec_wif.wif_id,
                                                                X_MODE                         => 'R',
                                                                x_error_code                   => NULL
                                                              );
                     END LOOP;
         CLOSE c_stud_grp_mem;
                END IF;  -- rec_igs_da_rqst.request_mode = 'SINGLE' WIF
        END LOOP;

     ELSIF rec_igs_da_rqst.program_comparison_type = 'DP' THEN
        IF rec_igs_da_rqst.request_mode = 'SINGLE' THEN
             -- insert each program attempt of the student
             FOR rec_prog_attempt IN c_prog_attempt (rec_igs_da_rqst.person_id) LOOP
                     l_rowid := null;
                     l_igs_da_req_stdnts_id := null;
         igs_da_req_stdnts_pkg.insert_row (
                                                        X_ROWID                        => l_rowid,
                                                        X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                        X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                        X_PERSON_ID                    => rec_igs_da_rqst.person_id,
                                                        X_PROGRAM_CODE                 => rec_prog_attempt.course_cd,
                                                        X_WIF_PROGRAM_CODE             => NULL,
                                                        X_SPECIAL_PROGRAM_CODE         => NULL,
                                                        X_MAJOR_UNIT_SET_CD            => NULL,
                                                        X_PROGRAM_MAJOR_CODE           => NULL,
                                                        X_REPORT_TEXT                  => NULL,
                                                        X_WIF_ID                       => NULL,
                                                        X_MODE                         => 'R',
                                                        x_error_code                   => NULL
                                                      );
             END LOOP;
        ELSE
             IF l_is_filename_null = 'N' THEN
                l_dyn_stud_grp_mem := IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL (rec_igs_da_rqst.person_id_group_id,l_status);
                IF l_status <> FND_API.G_RET_STS_SUCCESS THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_AZ_DYN_PERS_ID_GRP_ERR');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                OPEN c_stud_grp_mem FOR l_dyn_stud_grp_mem;
             ELSE
                OPEN c_stud_grp_mem FOR l_stc_stud_grp_mem USING rec_igs_da_rqst.person_id_group_id;
             END IF;
             LOOP
                     FETCH c_stud_grp_mem INTO l_person_id;
                     EXIT WHEN c_stud_grp_mem%NOTFOUND;
                     FOR rec_prog_attempt IN c_prog_attempt (l_person_id) LOOP
                 l_rowid := null;
                             l_igs_da_req_stdnts_id := null;
                             igs_da_req_stdnts_pkg.insert_row (
                                                                X_ROWID                        => l_rowid,
                                                                X_BATCH_ID                     => rec_igs_da_rqst.batch_id,
                                                                X_IGS_DA_REQ_STDNTS_ID         => l_igs_da_req_stdnts_id,
                                                                X_PERSON_ID                    => l_person_id,
                                                                X_PROGRAM_CODE                 => rec_prog_attempt.course_cd,
                                                                X_WIF_PROGRAM_CODE             => NULL,
                                                                X_SPECIAL_PROGRAM_CODE         => NULL,
                                                                X_MAJOR_UNIT_SET_CD            => NULL,
                                                                X_PROGRAM_MAJOR_CODE           => NULL,
                                                                X_REPORT_TEXT                  => NULL,
                                                                X_WIF_ID                       => NULL,
                                                                X_MODE                         => 'R',
                                                                x_error_code                   => NULL
                                                              );
        END LOOP;
             END LOOP;
       CLOSE c_stud_grp_mem;
        END IF;  -- rec_igs_da_rqst.request_mode = 'SINGLE' DP
     END IF; -- rec_igs_da_rqst.program_comparison_type = 'SP''
    /*
       copy the DFF values from IGS_DA_CNFG_REQ_TYP to IGS_DARQST
    */
    OPEN c_dff(p_batch_id);
    FETCH c_dff INTO rec_dff;
    CLOSE c_dff;
    igs_da_rqst_pkg.update_row
                        (
                        X_ROWID                        => rec_igs_da_rqst.rowid                   ,
                        X_BATCH_ID                     => rec_igs_da_rqst.batch_id                ,
                        X_REQUEST_TYPE_ID              => rec_igs_da_rqst.request_type_id         ,
                        X_REQUEST_MODE                 => rec_igs_da_rqst.request_mode            ,
                        X_PROGRAM_COMPARISON_TYPE      => rec_igs_da_rqst.program_comparison_type ,
                        X_REQUEST_STATUS               => rec_igs_da_rqst.request_status          ,
                        X_PERSON_ID_GROUP_ID           => rec_igs_da_rqst.person_id_group_id      ,
                        X_PERSON_ID                    => rec_igs_da_rqst.person_id               ,
                        X_REQUESTOR_ID                 => rec_igs_da_rqst.requestor_id            ,
                        X_STUDENT_RELEASE_IND          => rec_igs_da_rqst.student_release_ind     ,
                        X_SPECIAL_PROGRAM              => rec_igs_da_rqst.special_program         ,
                        X_SPECIAL_PROGRAM_CATALOG      => rec_igs_da_rqst.special_program_catalog ,
                        X_ATTRIBUTE_CATEGORY           => rec_dff.attribute_category ,
                        X_ATTRIBUTE1                   => rec_dff.attribute1         ,
                        X_ATTRIBUTE2                   => rec_dff.attribute2         ,
                        X_ATTRIBUTE3                   => rec_dff.attribute3         ,
                        X_ATTRIBUTE4                   => rec_dff.attribute4         ,
                        X_ATTRIBUTE5                   => rec_dff.attribute5         ,
                        X_ATTRIBUTE6                   => rec_dff.attribute6         ,
                        X_ATTRIBUTE7                   => rec_dff.attribute7         ,
                        X_ATTRIBUTE8                   => rec_dff.attribute8         ,
                        X_ATTRIBUTE9                   => rec_dff.attribute9         ,
                        X_ATTRIBUTE10                  => rec_dff.attribute10        ,
                        X_ATTRIBUTE11                  => rec_dff.attribute11        ,
                        X_ATTRIBUTE12                  => rec_dff.attribute12        ,
                        X_ATTRIBUTE13                  => rec_dff.attribute13        ,
                        X_ATTRIBUTE14                  => rec_dff.attribute14        ,
                        X_ATTRIBUTE15                  => rec_dff.attribute15        ,
                        X_ATTRIBUTE16                  => rec_dff.attribute16        ,
                        X_ATTRIBUTE17                  => rec_dff.attribute17        ,
                        X_ATTRIBUTE18                  => rec_dff.attribute18        ,
                        X_ATTRIBUTE19                  => rec_dff.attribute19        ,
                        X_ATTRIBUTE20                  => rec_dff.attribute20        ,
                        X_MODE                         => 'R'                        ,
                        X_RETURN_STATUS                => l_return_status            ,
                        X_MSG_DATA                     => l_msg_data                 ,
                        X_MSG_COUNT                    => l_msg_count
                        );
    IF l_return_status <>'S' THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_DA_CR_PLS_ERROR');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;
  CLOSE c_igs_da_rqst;

  /*
     now insert the records (IGS_DA_CNFG_FTR) not shown to the user
     in the table IGS_DA_REQ_FTRS
  */
  FOR rec_req_ftrs IN c_req_ftrs(p_batch_id)
  LOOP
          l_rowid := null;
          igs_da_req_ftrs_pkg.insert_row
                                (
                                X_ROWID                => l_rowid       ,
                                X_BATCH_ID             => p_batch_id    ,
                                X_FEATURE_CODE         => rec_req_ftrs.feature_code ,
                                X_FEATURE_VALUE        => rec_req_ftrs.feature_value,
                                X_MODE                 => 'R'            ,
                                X_RETURN_STATUS        => l_return_status,
                                X_MSG_DATA             => l_msg_data     ,
                                X_MSG_COUNT            => l_msg_count
                                );
  END LOOP;

  -- now raise the business event
  BEGIN
     igs_da_xml_pkg.Pre_Submit_Event(p_batch_id => p_batch_id);
  EXCEPTION
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_DA_XML_ERROR');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
  END;

  -- Initialize API return status to success.
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_TRUE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
             p_encoded => FND_API.G_TRUE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_TRUE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','create_req_stdnts_rec : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                       p_encoded => FND_API.G_TRUE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;
END create_req_stdnts_rec;

END IGS_DA_UTILS_PKG;

/
