--------------------------------------------------------
--  DDL for Package Body IGS_EN_CAREER_MODEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CAREER_MODEL" AS
/* $Header: IGSEN86B.pls 120.0 2005/06/02 00:47:32 appldev noship $ */
-- sarakshi   16-Nov-2004   Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG in the procedure SCA_TBH_AFTER_DML
-- svenkata   7-JAN-2002    Bug No. 2172405  Standard Flex Field columns have been added
--                          to table handler procedure calls as part of CCR - ENCR022.
-- smaddali    25-feb-2002  Bug# 2233348 ENCR018 ccr. modified procedure
-- before_tbh because a utp case failed in IGSEN022
-- ptandon    15-Dec-2003   Modified procedure SCA_TBH_BEFORE_DML to error out if no
--                          program is set as primary program for the given career.
-- amuthu     24-Dec-2004   commented the logic related to the automatic determination of primary program.

  FUNCTION ENRP_GET_SEC_SCA_STATUS (
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_course_attempt_status IN VARCHAR2 ,
    p_primary_program_type IN VARCHAR2,
    p_primary_prog_type_source IN VARCHAR2,
    p_course_type IN VARCHAR2 ,
    p_new_primary_course_cd  IN VARCHAR2 DEFAULT NULL
  )RETURN VARCHAR2 AS


    CURSOR c_sca IS
      SELECT    sca.course_attempt_status,
                sca.primary_program_type,
                sca.primary_prog_type_source
      FROM IGS_EN_STDNT_PS_ATT sca
      WHERE sca.person_id       = p_person_id
      AND   sca.course_cd = p_course_cd;


    CURSOR  c_pri_course_cd is
      SELECT  sca.course_attempt_status
      FROM    IGS_EN_STDNT_PS_ATT sca,
              IGS_PS_VER crv
      WHERE   sca.person_id             = p_person_id
      AND     crv.course_type           = p_course_type
      AND     sca.course_cd             = crv.course_Cd
      AND     sca.version_number        = crv.version_number
      AND     sca.primary_program_type  = 'PRIMARY'
      AND     sca.course_cd             = NVL(p_new_primary_course_cd,sca.course_cd);



    v_pri_course_cd_rec           c_pri_course_cd%ROWTYPE;

    v_course_attempt_status     IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    v_primary_program_type      IGS_EN_STDNT_PS_ATT.primary_program_type%TYPE;
    v_primary_prog_type_source  IGS_EN_STDNT_PS_ATT.primary_prog_type_source%TYPE;

    cst_deleted         CONSTANT VARCHAR2(10) := 'DELETED';
    cst_unconfirm       CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_discontin       CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_lapsed          CONSTANT VARCHAR2(10) := 'LAPSED';
    cst_enrolled        CONSTANT VARCHAR2(10) := 'ENROLLED';
    cst_intermit        CONSTANT VARCHAR2(10) := 'INTERMIT';
    cst_completed       CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_inactive        CONSTANT VARCHAR2(10) := 'INACTIVE';

    cst_primary         CONSTANT VARCHAR2(10) := 'PRIMARY';
    cst_secondary       CONSTANT VARCHAR2(10) := 'SECONDARY';


  BEGIN
  /*
  if this function returns null then it could for one of two reason
  the career model is not enabled or the primary program does not exit for
  the context career (course_type)
  */


    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') <> 'Y' THEN
      return null;
    END IF;

        -- If the values have not been passed in, load them.
        IF p_course_attempt_status IS NULL
          OR p_primary_program_type IS NULL THEN
                OPEN c_sca;
                FETCH c_sca INTO v_course_attempt_status,
                                v_primary_program_type,
                                v_primary_prog_type_source;
                IF (c_sca%NOTFOUND) THEN
                        CLOSE c_sca;
                        RETURN NULL;
                END IF;
                CLOSE c_sca;
        ELSE
                -- Use parameters instead of selected student IGS_PS_COURSE attempt
                -- information to set v_ values.
                v_course_attempt_status := p_course_attempt_status;
                v_primary_program_type := p_primary_program_type;
                v_primary_prog_type_source := p_primary_prog_type_source;
        END IF;


    IF v_primary_program_type = cst_secondary THEN

      OPEN c_pri_course_cd;
      FETCH c_pri_course_cd INTO v_pri_course_cd_rec;

       IF c_pri_course_cd%FOUND THEN

        IF v_pri_course_cd_rec.course_attempt_status = cst_inactive THEN
          CLOSE c_pri_course_cd;
          RETURN cst_inactive;
        END IF;

        IF v_pri_course_cd_rec.course_attempt_status = cst_enrolled THEN
          CLOSE c_pri_course_cd;
          RETURN cst_enrolled;
        END IF;

        IF v_pri_course_cd_rec.course_attempt_status = cst_intermit THEN
          CLOSE c_pri_course_cd;
          RETURN cst_intermit;
        END IF;

        IF v_pri_course_cd_rec.course_attempt_status = cst_lapsed THEN
          CLOSE c_pri_course_cd;
          RETURN cst_lapsed;
        END IF;

        IF v_pri_course_cd_rec.course_attempt_status = cst_discontin
          OR v_pri_course_cd_rec.course_attempt_status = cst_completed THEN
           CLOSE c_pri_course_cd;
           RETURN null; -- status cannot be derived since the primary program is
                                -- is completed or discontinued. The user has to select
                                                -- a new primary progarm.
        END IF;
      END IF;
      CLOSE c_pri_course_cd;
    END IF;

        RETURN null; -- could not find the primary program for this career
  /*
  if this function returns null then it could for one of two reason
  the career model is not enabled or the primary program does not exit for
  the context career (course_type)
  */
  END ENRP_GET_SEC_SCA_STATUS;



  PROCEDURE SCA_TBH_BEFORE_DML(
  p_person_id                   IN NUMBER,
  p_course_cd                   IN VARCHAR2,
  p_version_number              IN NUMBER,
  p_old_course_attempt_status   IN VARCHAR2 ,
  p_new_course_attempt_status   IN OUT NOCOPY VARCHAR2 ,
  p_primary_program_type        IN OUT NOCOPY VARCHAR2,
  p_primary_prog_type_source    IN OUT NOCOPY VARCHAR2,
  p_new_key_program             IN OUT NOCOPY VARCHAR2
  ) AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    08-01-03        Added new validation before changing the primary program type
  --                            to SECONDARY if new program attempt status is DISCONTINU/COMPLETE/UNCONFIRM.
  --                            Which checks whether any active program is exist in the same career other
  --                            than current program , if exist then only set the context program as SECONDARY.
  --                            w.r.t. the bug 2710998.
  -- ptandon    15-12-03        Added validation to error out if no program is set as primary program for the given career.
  -------------------------------------------------------------------------------------------


    v_course_type                   IGS_PS_TYPE.COURSE_TYPE%TYPE;
    v_primary_prog_type_source      IGS_EN_STDNT_PS_ATT_ALL.primary_prog_type_source%TYPE;
    v_course_cd_rank                IGS_PS_VER.PRIMARY_PROGRAM_RANK%TYPE;
    v_exst_primary_rank             IGS_PS_VER.PRIMARY_PROGRAM_RANK%TYPE;
    v_exst_key_program              IGS_EN_STDNT_PS_ATT_ALL.KEY_PROGRAM%TYPE ;
    v_min_sec_rank                  IGS_PS_VER.PRIMARY_PROGRAM_RANK%TYPE;
    cst_system                     CONSTANT VARCHAR2(10) := 'SYSTEM';
    cst_primary                     CONSTANT VARCHAR2(10) := 'PRIMARY';
    cst_secondary                   CONSTANT VARCHAR2(10) := 'SECONDARY';
    l_count                         NUMBER(5);

    CURSOR c_course_type IS
          SELECT crv.course_type
          FROM igs_ps_ver crv
          WHERE course_cd = p_course_cd
          and version_number = p_version_number;

  /*
    CURSOR c_auto_enabled (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE) IS
      SELECT  crv.primary_program_rank
      FROM igs_ps_type pst,
               igs_ps_ver crv
      WHERE pst.course_type = cp_course_type
           AND crv.course_Cd = p_course_Cd
           AND crv.version_number = p_version_number
           AND crv.course_type = pst.course_type;
    */
    CURSOR c_exst_primary_rank (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE) IS
          SELECT PRIMARY_PROGRAM_RANK , key_program
          FROM igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
          WHERE crv.course_type = cp_course_type
          AND sca.course_cd = crv.course_cd
          AND sca.version_number = crv.version_number
          AND sca.person_id = p_person_id
          AND sca.course_cd <> p_course_cd
          AND sca.primary_program_type = cst_primary;


    CURSOR c_key_prog_exists IS
         SELECT 'X'
             FROM IGS_EN_STDNT_PS_ATT
             WHERE person_id = p_person_id
             AND   key_program = 'Y';
/*
    --Cursor gets the total number of courses attempted by student for a given course type.
    CURSOR  c_prg_count(cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE) IS
      SELECT  count(1)
      FROM    IGS_EN_STDNT_PS_ATT sca,
              IGS_PS_VER crv
      WHERE   sca.person_id                  = p_person_id
              AND  crv.course_type           = cp_course_type
              AND  sca.course_cd             = crv.course_cd
              AND  sca.version_number        = crv.version_number
              AND   course_attempt_status IN ('ENROLLED','INACTIVE','LAPSED','INTERMIT');
       */

     l_key_prog_exists    VARCHAR2(1) ;
     v_exst_key_prog  igs_en_stdnt_ps_att_all.key_program%TYPE;
     l_new_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;
  BEGIN

        l_key_prog_exists   := NULL;
        -- Initializing the first active program attempt as the Key Program
        OPEN c_key_prog_exists  ;
        FETCH c_key_prog_exists  INTO l_key_prog_exists ;
        IF c_key_prog_exists %NOTFOUND  AND
           p_new_course_attempt_status IN ('ENROLLED','INACTIVE','LAPSED','INTERMIT')  THEN
           p_new_key_program := 'Y' ;
        END IF;
        CLOSE c_key_prog_exists  ;


        IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') <> 'Y' THEN
          RETURN; -- return if the career model is not enabled
        END IF;

        OPEN c_course_type;
        FETCH c_course_type INTO v_course_type;
        CLOSE c_course_type;
/*
        OPEN c_auto_enabled (v_course_type);
        FETCH c_auto_enabled INTO  v_course_cd_rank;
        CLOSE c_auto_enabled;
*/
        p_primary_prog_type_source  := cst_system ;

       IF p_new_course_attempt_status IN ('ENROLLED','INACTIVE','LAPSED','INTERMIT') THEN
             OPEN c_exst_primary_rank(v_course_type);
             FETCH c_exst_primary_rank INTO v_exst_primary_rank ,v_exst_key_prog ;
             IF c_exst_primary_rank%NOTFOUND THEN
               p_primary_program_type := cst_primary;
/*
             ELSE
               IF v_course_cd_rank IS NOT NULL AND
                   v_course_cd_rank < v_exst_primary_rank THEN
                            -- if the rank of the context progarm is not null
                            -- and less than that of the existing primary program
                            -- and the course attempt status is not unconfirmed then
                            -- set the context program as the primary program
                            p_primary_program_type := cst_primary;
                            IF v_exst_key_prog  = 'Y' THEN
                               p_new_key_program := 'Y' ;
                            END IF;
*/
               ELSE
                       p_primary_program_type := cst_secondary ;
--               END IF;
             END IF;
             CLOSE c_exst_primary_rank;
       END IF;
/*
        --smaddali modified this code to include status UNCONFIRM for bug#2233348
        -- because when we unconfirm a primary program it should be made secondary
       IF p_old_course_attempt_status <> p_new_course_attempt_status
          AND p_new_course_attempt_status IN ('DISCONTIN','COMPLETED','UNCONFIRM') THEN
              --Check is there any other program exists for this career.
              --If more than one active program exist then only change the primary program type
              --to SECONDARY otherwise no. Since there is no other program is active then
              --we should keep this program as PRIMARY.

                 p_primary_program_type := cst_secondary;
                 p_new_key_program := 'N';
       END IF;

*/
        IF p_primary_program_type = cst_secondary THEN
          -- using the same cursor as that for selecting the primary programs
          -- this indirectly tells us if there is a primary program
          --  A secnario will arise when the primary program is manually
          -- set to secondary. In that case there will be no primary in the
          -- data base and get_sec_sca_status will return null
          -- the status for the secondary program in this case will
          -- be handled in the after dml procedure for another program
          -- that could be saved as the primary
          OPEN c_exst_primary_rank(v_course_type);
          FETCH c_exst_primary_rank INTO v_exst_primary_rank ,v_exst_key_program;
          IF c_exst_primary_rank%NOTFOUND THEN
            -- this will over-ride the course attempt status calculated
            -- by igs_en_gen_006.enrp_get_sca_status.
            -- it is important to maintain the order in which this procedure
            -- and igs_en_gen_006.enrp_get_sca_status. are called
            -- the call to the igs_en_gen_006.enrp_get_sca_status. should be
            -- first in the order
            -- If the secondary program is active then recalculate its program attempt status depending on the
            -- primary programs status
            IF p_new_course_attempt_status IN ('INACTIVE','ENROLLED','LAPSED','INTERMIT') THEN
               l_new_course_attempt_status := enrp_get_sec_sca_status( p_person_id ,
                                                      p_course_cd ,
                                                      p_new_course_attempt_status,
                                                      p_primary_program_type ,
                                                      p_primary_prog_type_source,
                                                      v_course_type );
               IF l_new_course_attempt_status IS NULL THEN
                           l_new_course_attempt_status := IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(p_person_id ,
                                                                           p_course_cd,
                                                                           null,null,null,null,null,null);
               END IF;


               -- If there is no primary program for the career error out.
               IF l_new_course_attempt_status IS NULL THEN
                  fnd_message.set_name ('IGS', 'IGS_EN_SCA_STDNT_NO_PRIMARY');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
               ELSE
                  p_new_course_attempt_status := l_new_course_attempt_status;
               END IF;

            END IF; --end if secondary program attempt status is active
          END IF;
          CLOSE c_exst_primary_rank;
        END IF;

  END SCA_TBH_BEFORE_DML;


  PROCEDURE SCA_TBH_AFTER_DML(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_version_number IN NUMBER,
    p_old_course_attempt_status IN VARCHAR2 ,
    p_new_course_attempt_status IN VARCHAR2 ,
    p_primary_prog_type_source IN VARCHAR2,
    p_old_pri_prog_type IN VARCHAR2,
    p_new_pri_prog_type IN VARCHAR2 ,
    p_old_key_program  IN  VARCHAR2
    ) AS

    v_course_type                   IGS_PS_TYPE.COURSE_TYPE%TYPE;
    v_sec_rank                      IGS_PS_VER.PRIMARY_PROGRAM_RANK%TYPE;
    v_test_course_cd                IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE;
    v_primary_prog_type_source      IGS_EN_STDNT_PS_ATT_ALL.primary_prog_type_source%TYPE;
    v_course_attempt_status         IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE;
    cst_primary                     CONSTANT VARCHAR2(10) := 'PRIMARY';
    cst_secondary                   CONSTANT VARCHAR2(10) := 'SECONDARY';
    cst_system                     CONSTANT VARCHAR2(10) := 'SYSTEM';
    v_update                        BOOLEAN;
    lv_dummy                        VARCHAR2(1);
-- saving the context record
    c_person_id   IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE;
    c_course_cd    IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE;
    c_version_number   IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE;
    c_old_course_attempt_status  IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE;
    c_new_course_attempt_status IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE;
    c_primary_prog_type_source IGS_EN_STDNT_PS_ATT_ALL.primary_prog_type_source%TYPE;
    c_old_pri_prog_type   IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE;
    c_new_pri_prog_type      IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE;
    c_old_key_program       IGS_EN_STDNT_PS_ATT_ALL.key_program%TYPE;

    CURSOR c_course_type(cp_course_cd IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE,
     cp_version_number IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE) IS
          SELECT crv.course_type
          FROM igs_ps_ver crv
          WHERE course_cd = cp_course_cd
          and version_number = cp_version_number;

    CURSOR c_sca_upd (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE ,
     cp_person_id  IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
     cp_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE) IS
      SELECT sca.*
      FROM igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
      WHERE crv.course_type = cp_course_type
          and sca.course_cd = crv.course_cd
          and sca.version_number = crv.version_number
          and sca.person_id = cp_person_id
          and sca.course_cd <> cp_course_cd;

    CURSOR c_min_ranked_sec_sca (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE ,
     cp_person_id  IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
     cp_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ) IS
          SELECT crv.PRIMARY_PROGRAM_RANK, sca.course_Cd
          FROM igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
          WHERE crv.course_type = cp_course_type
          and sca.course_cd = crv.course_cd
          and sca.version_number = crv.version_number
          and sca.person_id = cp_person_id
          and sca.course_cd <> cp_course_cd
          and sca.primary_program_type <> cst_primary
          and sca.course_attempt_status IN ('INACTIVE','ENROLLED','LAPSED','INTERMIT')
        order by crv.primary_program_rank asc ; -- ordering it to find the min ranked value first Kamal's idea

      --Following cursor get's key program for other career
      --Added by kkillams
      CURSOR c_ext_oth_prg_key (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE) IS
          SELECT 'X'
          FROM igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
          WHERE crv.course_type <> cp_course_type
          AND sca.course_cd = crv.course_cd
          AND sca.version_number = crv.version_number
          AND sca.person_id = p_person_id
          AND sca.primary_program_type = cst_primary
          AND sca.key_program = 'Y';

      --Following cursor get's any primary program for this career other than current program
      CURSOR c_ext_oth_primprg (cp_course_type IGS_PS_TYPE.COURSE_TYPE%TYPE,cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
          SELECT 'X'
          FROM igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
          WHERE crv.course_type = cp_course_type
          AND sca.course_cd = crv.course_cd
          AND sca.version_number = crv.version_number
          AND sca.person_id = p_person_id
          AND sca.course_cd <> cp_course_cd
          AND sca.primary_program_type = cst_primary ;
         c_ext_oth_primprg_rec c_ext_oth_primprg%ROWTYPE;

  BEGIN

    IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') <> 'Y' THEN
       RETURN; -- return if the career model is not enabled
    END IF;

    c_person_id := p_person_id  ;
    c_course_cd := p_course_cd ;
    c_version_number := p_version_number ;
    c_old_course_attempt_status :=  p_old_course_attempt_status;
    c_new_course_attempt_status := p_new_course_attempt_status ;
    c_primary_prog_type_source :=  p_primary_prog_type_source ;
    c_old_pri_prog_type := p_old_pri_prog_type  ;
    c_new_pri_prog_type :=  p_new_pri_prog_type  ;
    c_old_key_program  :=  p_old_key_program ;
    v_primary_prog_type_source := cst_system;

        OPEN c_course_type(c_course_cd, c_version_number ) ;
        FETCH c_course_type INTO v_course_type;
        CLOSE c_course_type;

        --donot allow calls to before dml and after dml of this package from igs_en_stdnt_ps_att_pkg
        -- this is to prevent recursion of the update row call below
        IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  TRUE ;
        -- update all the records other than the current record if needed
        FOR v_sca_upd_rec  IN c_sca_upd(v_course_type ,c_person_id, c_course_cd)
        LOOP

            v_update := FALSE;
 /*
            -- if the context program is primary
            -- then set all other programs to 'Secondary'
            IF c_new_pri_prog_type = cst_primary
            and ((c_new_pri_prog_type IS NOT NULL AND  c_old_pri_prog_type IS NULL )
            OR c_new_pri_prog_type <> c_old_pri_prog_type ) THEN

                   IF NVL(v_sca_upd_rec.primary_program_type,'NULL') <> cst_secondary  THEN
                      v_update := TRUE;
                      -- if the context program is newly selected as  primary program then
                      -- set the primary program type of all other program to secondary
                      v_sca_upd_rec.primary_program_type := cst_secondary;
                      v_sca_upd_rec.key_program := 'N' ;
                   END IF;

                   -- calculating the course attempt status for all the other records
                   -- that would be looped through
                   -- If the secondary program is active then recalculate its program attempt status depending on the
                   -- primary programs status
                   IF v_sca_upd_rec.course_attempt_status IN ('INACTIVE','ENROLLED','LAPSED','INTERMIT') THEN
                       v_course_attempt_status := enrp_get_sec_sca_status( c_person_id ,
                                                                    v_sca_upd_rec.course_cd ,
                                                                    v_sca_upd_rec.course_attempt_status,
                                                                    v_sca_upd_rec.primary_program_type ,
                                                                    v_sca_upd_rec.primary_prog_type_source,
                                                                        v_course_type ,
                                                                        c_course_cd );
                       IF v_course_attempt_status IS NULL THEN
                           v_course_attempt_status := IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(c_person_id ,
                                                                           v_sca_upd_rec.course_cd,
                                                                           null,null,null,null,null,null);
                       END IF;

                      IF NVL(v_sca_upd_rec.course_attempt_status,'NULL') <> v_course_attempt_status THEN
                             v_update := TRUE;
                            v_sca_upd_rec.course_attempt_status := v_course_attempt_status;
                      END IF;
                  END IF; --end if secondary course_attempt_status is not active

             END IF;
*/
             -- If the primary program attempt status has changed then recalculate the status of the
             -- other programs also
             IF c_new_pri_prog_type = cst_primary and
                NVL(c_old_course_attempt_Status,'NULL') <> NVL(c_new_course_attempt_status,'NULL') THEN
                   -- If the secondary program is active then recalculate its program attempt status depending on the
                   -- primary programs status
                   IF v_sca_upd_rec.course_attempt_status IN ('INACTIVE','ENROLLED','LAPSED','INTERMIT') THEN
                      v_course_attempt_status := enrp_get_sec_sca_status( c_person_id ,
                                                                    v_sca_upd_rec.course_cd ,
                                                                    v_sca_upd_rec.course_attempt_status,
                                                                    v_sca_upd_rec.primary_program_type ,
                                                                    v_sca_upd_rec.primary_prog_type_source,
                                                                        v_course_type ,
                                                                        c_course_cd );
                      IF v_course_attempt_status IS NULL THEN
                         v_course_attempt_status := IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(c_person_id ,
                                                                           v_sca_upd_rec.course_cd,
                                                                           null,null,null,null,null,null);
                      END IF;

                      IF NVL(v_sca_upd_rec.course_attempt_status,'NULL') <> v_course_attempt_status THEN
                         v_update := TRUE;
                         v_sca_upd_rec.course_attempt_status := v_course_attempt_status;
                      END IF;
                  END IF;  --end if secondary program status is active
             END IF;

/*
             IF c_new_pri_prog_type = cst_secondary
                and c_old_pri_prog_type = cst_primary THEN
                   -- set this as primary only if no other primary exists for this career
                   OPEN c_ext_oth_primprg(v_course_type,c_course_cd );
                   FETCH c_ext_oth_primprg INTO c_ext_oth_primprg_rec;
                   IF c_ext_oth_primprg%NOTFOUND THEN
                        CLOSE c_ext_oth_primprg;
                        -- previously testing this cursor if it fetches any rows
                        -- in the sca_tbh_before_dml . Only if the cursor fetches any rows
                        -- are we changing the context program to secondary from the primary
                        -- once it has been completed or discontinued.
                        OPEN c_min_ranked_sec_sca(v_course_type ,c_person_id,c_course_cd);
                        FETCH c_min_ranked_sec_sca INTO v_sec_rank, v_test_course_cd;
                        IF c_min_ranked_sec_sca%FOUND AND
                           v_sca_upd_rec.course_cd = v_test_course_cd THEN
                          v_update := TRUE;
                          v_sca_upd_rec.primary_program_type := cst_primary;
                          IF c_old_key_program = 'Y' THEN
                                --Check whether any key program is exists in other career. If exist then don't set current program as key program.
                                --Previously it's not looking whether any key program is exist in other career, so that there is chances of getting
                                --two key programs for person. Added by kkillams w.r.t. bug 2407760
                                OPEN c_ext_oth_prg_key(v_course_type);
                                FETCH c_ext_oth_prg_key INTO lv_dummy;
                                IF c_ext_oth_prg_key%NOTFOUND THEN
                                    v_sca_upd_rec.key_program := 'Y' ;
                                END IF;
                                CLOSE c_ext_oth_prg_key;
                          END IF ;
                        END IF;
                        CLOSE c_min_ranked_sec_sca;
                  ELSE
                     CLOSE  c_ext_oth_primprg;
                  END IF; -- end of if c_ext_oth_primprg%NOTFOUND

            END IF;
*/

            IF v_update THEN -- update the record only if some thing has changed.

                IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                      X_ROWID                           => v_sca_upd_rec.row_id,
                      X_PERSON_ID                       => v_sca_upd_rec.PERSON_ID,
                      X_COURSE_CD                       => v_sca_upd_rec.COURSE_CD,
                      X_ADVANCED_STANDING_IND           => v_sca_upd_rec.ADVANCED_STANDING_IND,
                      X_FEE_CAT                         => v_sca_upd_rec.fee_cat,
                      X_CORRESPONDENCE_CAT              => v_sca_upd_rec.correspondence_cat,
                      X_SELF_HELP_GROUP_IND             => v_sca_upd_rec.SELF_HELP_GROUP_IND,
                      X_LOGICAL_DELETE_DT               => v_sca_upd_rec.logical_delete_dt,
                      X_ADM_ADMISSION_APPL_NUMBER       => v_sca_upd_rec.adm_admission_appl_number,
                      X_ADM_NOMINATED_COURSE_CD         => v_sca_upd_rec.adm_nominated_course_cd,
                      X_ADM_SEQUENCE_NUMBER             => v_sca_upd_rec.adm_sequence_number,
                      X_VERSION_NUMBER                  => v_sca_upd_rec.version_number,
                      X_CAL_TYPE                        => v_sca_upd_rec.cal_type,
                      X_LOCATION_CD                     => v_sca_upd_rec.location_cd,
                      X_ATTENDANCE_MODE                 => v_sca_upd_rec.attendance_mode,
                      X_ATTENDANCE_TYPE                 => v_sca_upd_rec.attendance_type,
                      X_COO_ID                          => v_sca_upd_rec.coo_id,
                      X_STUDENT_CONFIRMED_IND           => v_sca_upd_rec.student_confirmed_ind,
                      X_COMMENCEMENT_DT                 =>  v_sca_upd_rec.commencement_dt,
                      X_COURSE_ATTEMPT_STATUS           => v_sca_upd_rec.course_attempt_status,
                      X_PROGRESSION_STATUS              => v_sca_upd_rec.PROGRESSION_STATUS,
                      X_DERIVED_ATT_TYPE                => v_sca_upd_rec.DERIVED_ATT_TYPE,
                      X_DERIVED_ATT_MODE                => v_sca_upd_rec.DERIVED_ATT_MODE,
                      X_PROVISIONAL_IND                 => v_sca_upd_rec.provisional_ind,
                      X_DISCONTINUED_DT                 => v_sca_upd_rec.discontinued_dt,
                      X_DISCONTINUATION_REASON_CD       => v_sca_upd_rec.discontinuation_reason_cd,
                      X_LAPSED_DT                       => v_sca_upd_rec.LAPSED_DT,
                      X_FUNDING_SOURCE                  => v_sca_upd_rec.funding_source,
                      X_EXAM_LOCATION_CD                => v_sca_upd_rec.EXAM_LOCATION_CD,
                      X_DERIVED_COMPLETION_YR           => v_sca_upd_rec.DERIVED_COMPLETION_YR,
                      X_DERIVED_COMPLETION_PERD         => v_sca_upd_rec.DERIVED_COMPLETION_PERD,
                      X_NOMINATED_COMPLETION_YR         => v_sca_upd_rec.nominated_completion_yr,
                      X_NOMINATED_COMPLETION_PERD       => v_sca_upd_rec.NOMINATED_COMPLETION_PERD,
                      X_RULE_CHECK_IND                  => v_sca_upd_rec.RULE_CHECK_IND,
                      X_WAIVE_OPTION_CHECK_IND          => v_sca_upd_rec.WAIVE_OPTION_CHECK_IND,
                      X_LAST_RULE_CHECK_DT              => v_sca_upd_rec.LAST_RULE_CHECK_DT,
                      X_PUBLISH_OUTCOMES_IND            => v_sca_upd_rec.PUBLISH_OUTCOMES_IND,
                      X_COURSE_RQRMNT_COMPLETE_IND      => v_sca_upd_rec.COURSE_RQRMNT_COMPLETE_IND,
                      X_COURSE_RQRMNTS_COMPLETE_DT      => v_sca_upd_rec.COURSE_RQRMNTS_COMPLETE_DT,
                      X_S_COMPLETED_SOURCE_TYPE         => v_sca_upd_rec.S_COMPLETED_SOURCE_TYPE,
                      X_OVERRIDE_TIME_LIMITATION        => v_sca_upd_rec.OVERRIDE_TIME_LIMITATION,
                      x_last_date_of_attendance         => v_sca_upd_rec.last_date_of_attendance,
                      x_dropped_by                      => v_sca_upd_rec.dropped_by,
                      X_IGS_PR_CLASS_STD_ID             => v_sca_upd_rec.igs_pr_class_std_id,
                      x_primary_program_type            => v_sca_upd_rec.primary_program_type,
                      x_primary_prog_type_source        => v_sca_upd_rec.primary_prog_type_source,
                      x_catalog_cal_type                => v_sca_upd_rec.catalog_cal_type,
                      x_catalog_seq_num                 => v_sca_upd_rec.catalog_seq_num,
                      x_key_program                     => v_sca_upd_rec.key_program,
                      x_override_cmpl_dt                => v_sca_upd_rec.override_cmpl_dt,
                      x_manual_ovr_cmpl_dt_ind          => v_sca_upd_rec.manual_ovr_cmpl_dt_ind,
                      X_MODE                            =>  'R',
                      X_ATTRIBUTE_CATEGORY              => v_sca_upd_rec.attribute_category,
                      X_ATTRIBUTE1                      => v_sca_upd_rec.attribute1,
                      X_ATTRIBUTE2                      => v_sca_upd_rec.attribute2,
                      X_ATTRIBUTE3                      => v_sca_upd_rec.attribute3,
                      X_ATTRIBUTE4                      => v_sca_upd_rec.attribute4,
                      X_ATTRIBUTE5                      => v_sca_upd_rec.attribute5,
                      X_ATTRIBUTE6                      => v_sca_upd_rec.attribute6,
                      X_ATTRIBUTE7                      => v_sca_upd_rec.attribute7,
                      X_ATTRIBUTE8                      => v_sca_upd_rec.attribute8,
                      X_ATTRIBUTE9                      => v_sca_upd_rec.attribute9,
                      X_ATTRIBUTE10                     => v_sca_upd_rec.attribute10,
                      X_ATTRIBUTE11                     => v_sca_upd_rec.attribute11,
                      X_ATTRIBUTE12                     => v_sca_upd_rec.attribute12,
                      X_ATTRIBUTE13                     => v_sca_upd_rec.attribute13,
                      X_ATTRIBUTE14                     => v_sca_upd_rec.attribute14,
                      X_ATTRIBUTE15                     => v_sca_upd_rec.attribute15,
                      X_ATTRIBUTE16                     => v_sca_upd_rec.attribute16,
                      X_ATTRIBUTE17                     => v_sca_upd_rec.attribute17,
                      X_ATTRIBUTE18                     => v_sca_upd_rec.attribute18,
                      X_ATTRIBUTE19                     => v_sca_upd_rec.attribute19,
                      X_ATTRIBUTE20                     => v_sca_upd_rec.attribute20,
		              X_FUTURE_DATED_TRANS_FLAG         => v_sca_upd_rec.future_dated_trans_flag
             );

            END IF;

          END LOOP;

          --allow calls before dml and after dml to this package from igs_en_stdnt_ps_att_pkg to fire
          IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;

  END SCA_TBH_AFTER_DML;


  FUNCTION ENRP_CHECK_FOR_ONE_PRIMARY (
    p_person_id IN NUMBER,
        p_course_type IN VARCHAR2,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS


    v_primary_count      NUMBER;
        v_confirmed_count     NUMBER;

    CURSOR  c_primary_count IS
      SELECT count(primary_program_type)
      FROM   IGS_EN_STDNT_PS_ATT sca,
             IGS_PS_VER crv
      WHERE  crv.course_type = p_course_type AND
             sca.course_cd = crv.course_cd AND
             sca.version_number = crv.version_number AND
             sca.person_id = p_person_id AND
             sca.primary_program_type = 'PRIMARY';

    CURSOR  c_confirmed_sca IS
      select count(student_confirmed_ind)
          from IGS_EN_STDNT_PS_ATT sca, igs_ps_ver crv
          where crv.course_type = p_course_type and
                    sca.course_cd = crv.course_cd and
                    sca.version_number = crv.version_number and
                    sca.person_id = p_person_id and
                    course_attempt_Status IN ('ENROLLED','INACTIVE','LAPSED','INTERMIT');

  BEGIN

    p_message_name := null;

    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') <> 'Y' THEN
          RETURN TRUE;
        END IF;

    OPEN c_primary_count;
    FETCH c_primary_count INTO v_primary_count;
    IF c_primary_count%FOUND THEN

      CLOSE c_primary_count;
      IF v_primary_count > 1 THEN

        p_message_name := 'IGS_EN_STDNT_PS_MORE_PRIMARY';
        RETURN FALSE;

      ELSIF v_primary_count = 0 THEN
        -- selecting the number of confirmed unit which have not been discontimued
        -- if the count return a value greater than zero then there are program
        -- which are confirmed but no primary has been set.
        OPEN c_confirmed_sca;
        FETCH c_confirmed_sca INTO v_confirmed_count;
        IF c_confirmed_sca%FOUND AND v_confirmed_count > 0 THEN
          CLOSE c_confirmed_sca;
          p_message_name := 'IGS_EN_STDNT_PS_NO_PRIMARY';
          RETURN FALSE;
        END IF;
        CLOSE c_confirmed_sca;
      END IF;

    ELSE
      CLOSE c_primary_count;
      -- selecting the number of confirmed unit which have not been discontimued
      -- if the count return a value greater than zero then there are program
      -- which are confirmed but no primary has been set.
      OPEN c_confirmed_sca;
      FETCH c_confirmed_sca INTO v_confirmed_count;
      IF c_confirmed_sca%FOUND AND v_confirmed_count > 0 THEN
        CLOSE c_confirmed_sca;
        p_message_name := 'IGS_EN_STDNT_PS_NO_PRIMARY';
        RETURN FALSE;
      END IF;
      CLOSE c_confirmed_sca;
    END IF;

        RETURN TRUE;

  END ENRP_CHECK_FOR_ONE_PRIMARY;

END IGS_EN_CAREER_MODEL;

/
