--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_LEGACY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_LEGACY" AS
/* $Header: IGSEN91B.pls 120.5 2006/04/25 23:37:19 stutta ship $ */

FUNCTION validate_grading_schm (
p_grade IN VARCHAR2 ,
p_uoo_id IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_version_number IN NUMBER)
RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function validates Outcome Grading schema details.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- cursor to find the  default grading schema at Unit section level. Note that only one
-- grading schema can exist as a default grading schema for a Unit offering/ Unit version.
CURSOR ger_grd_schm_usec  IS
SELECT grading_schema_code , grd_schm_version_number
FROM igs_ps_usec_grd_schm
WHERE  uoo_id = p_uoo_id AND
default_flag   = 'Y' ;

--
-- cursor to find the  default grading schema at Unit version level.
CURSOR ger_grd_schm_unit  IS
SELECT grading_schema_code , grd_schm_version_number
FROM igs_ps_unit_grd_schm
WHERE  unit_code = p_unit_cd AND
unit_version_number = p_version_number AND
default_flag   = 'Y' ;

--
--cursor to check if the given grade belongs to the default grading schema of the Unit Offering .
CURSOR check_grade ( p_outcome_grading_schema_code IN VARCHAR2 , p_outcome_gs_version_number IN NUMBER ) IS
SELECT  'x'
FROM igs_as_grd_sch_grade
WHERE grading_schema_cd = p_outcome_grading_schema_code AND
version_number = p_outcome_gs_version_number AND
grade = p_grade;

l_grading_schema_code igs_ps_usec_grd_schm.grading_schema_code%TYPE;
l_grd_schm_version_number igs_ps_usec_grd_schm.grd_schm_version_number%TYPE;
l_dummy VARCHAR2(2) := NULL;

BEGIN

    OPEN ger_grd_schm_usec ;
    FETCH ger_grd_schm_usec INTO l_grading_schema_code ,l_grd_schm_version_number ;

	-- If default grading schema is found at Unit section level, proceed
    IF ger_grd_schm_usec%FOUND THEN

        CLOSE ger_grd_schm_usec;
        OPEN check_grade(l_grading_schema_code ,l_grd_schm_version_number );
        FETCH check_grade INTO l_dummy ;

        IF check_grade%NOTFOUND THEN
            CLOSE check_grade;
            Fnd_Message.Set_Name( 'IGS' , 'IGS_AS_GRADE_INVALID');
            FND_MSG_PUB.ADD;
            RETURN FALSE ;
        END IF;
        CLOSE check_grade;

    ELSE

        -- Check if Grading schema exists at Unit level.
        CLOSE ger_grd_schm_usec;
        OPEN ger_grd_schm_unit ;
        FETCH ger_grd_schm_unit INTO l_grading_schema_code ,l_grd_schm_version_number ;

        IF ger_grd_schm_unit%FOUND THEN
            CLOSE ger_grd_schm_unit ;
            OPEN check_grade(l_grading_schema_code ,l_grd_schm_version_number );
            FETCH check_grade INTO l_dummy ;

            IF check_grade%NOTFOUND THEN
                CLOSE check_grade;
                Fnd_Message.Set_Name( 'IGS' , 'IGS_AS_GRADE_INVALID');
                FND_MSG_PUB.ADD;
                RETURN FALSE ;
            END IF;
            CLOSE check_grade;

        ELSE
            CLOSE ger_grd_schm_unit ;
            -- If default grading schema is not found
            Fnd_Message.Set_Name( 'IGS' , 'IGS_PS_ONE_UGSV_DFLT_MARK' );
            FND_MSG_PUB.ADD;
            RETURN FALSE ;
        END IF ;
    END IF ;

    RETURN TRUE  ;

END validate_grading_schm ;

FUNCTION validate_disc_rsn_cd (
p_discontinuation_reason_cd IN VARCHAR2
) RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function checks if Discontinuation Reason Code exists for a Unit.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- Cursor to to check if the Discontinuation Reason Code is valid, and can be used for discontinuing a Unit.
CURSOR val_discn_cd IS
SELECT dcnt_unit_ind
FROM igs_en_dcnt_reasoncd
WHERE discontinuation_reason_cd = p_discontinuation_reason_cd;

l_discn_ind igs_en_dcnt_reasoncd.dcnt_unit_ind%TYPE;

BEGIN
  OPEN val_discn_cd ;
  FETCH val_discn_cd  INTO l_discn_ind ;
  CLOSE val_discn_cd  ;

  IF NVL (l_discn_ind , 'N' ) = 'N' THEN
      Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_DISC_CD_INV');
      FND_MSG_PUB.ADD;
      RETURN FALSE ;
  END IF ;
  RETURN TRUE;

END validate_disc_rsn_cd ;

FUNCTION validate_trn_unit (
p_person_id IN NUMBER ,
p_program_cd IN VARCHAR2  ,
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_unit_attempt_status OUT NOCOPY VARCHAR2
) RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function validates Unit Transfer Details.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- Cursor to find matching Units Attempts for Transfer.
CURSOR cnt_unit IS
SELECT COUNT(*)
FROM igs_en_su_attempt sua
WHERE sua.person_id = p_person_id AND
sua.course_cd = p_program_cd AND
sua.unit_cd = p_unit_cd AND
sua.cal_type = p_cal_type AND
sua.ci_sequence_number = p_ci_sequence_number AND
sua.location_cd = p_location_cd AND
sua.unit_class = p_unit_class;

--
-- Cursor to get the unit attempt status.
CURSOR val_status IS
SELECT sua.unit_attempt_status
FROM igs_en_su_attempt sua
WHERE sua.person_id = p_person_id AND
sua.course_cd= p_program_cd AND
sua.unit_cd = p_unit_cd AND
sua.cal_type = p_cal_type AND
sua.ci_sequence_number = p_ci_sequence_number AND
sua.location_cd = p_location_cd AND
sua.unit_class = p_unit_class ;

l_count NUMBER := 0;
l_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE ;

BEGIN

    -- Validate unit to be transferred
    -- If any of the transfer columns are specified, then another unit attempt must exist with matching person id,
    -- transfer program code, unit code, teaching alternate code (resolved to calendar type and sequence number),
    -- location code and unit class.

    OPEN cnt_unit ;
    FETCH cnt_unit  INTO l_count ;
    CLOSE cnt_unit ;

    IF l_count = 0 THEN
        Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_TRNSFR_UNT_NT_FND');
        FND_MSG_PUB.ADD;
        RETURN FALSE ;
    ELSE
	    IF l_count > 1 THEN
            Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_MULTI_PRM_FND');
            FND_MSG_PUB.ADD;
            RETURN FALSE ;
	    ELSIF l_count =1 THEN

		    OPEN val_status ;
            FETCH val_status INTO l_unit_attempt_status;
    	    CLOSE val_status ;
    	    IF l_unit_attempt_status NOT IN ( 'COMPLETED','DISCONTIN' ) THEN
                Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_TRN_SUA_STAT_INV');
                FND_MSG_PUB.ADD;
                RETURN FALSE ;
    	    END IF ;
	    END IF ;
    END IF;

    p_unit_attempt_status := l_unit_attempt_status;
    RETURN TRUE ;

END validate_trn_unit;


FUNCTION validate_transfer (
p_person_id IN NUMBER ,
p_transfer_program_cd IN VARCHAR2
) RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function validates Transfer Details.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- Cursor to get the type of discontinuation reason code of a program
CURSOR get_prgm_reasn IS
SELECT 'x'
FROM igs_en_stdnt_ps_att spa , igs_en_dcnt_reasoncd disc
WHERE spa.person_id = p_person_id AND
spa.course_cd = p_transfer_program_cd  AND
disc.discontinuation_reason_cd = spa.discontinuation_reason_cd AND
disc.s_discontinuation_reason_type = 'TRANSFER';

--
-- Cursor to get the program attempt status of the Source Transfer Program
CURSOR get_prgm_stat IS
SELECT sca.course_attempt_status
FROM igs_en_stdnt_ps_att sca
WHERE sca.course_cd = p_transfer_program_cd
AND sca.person_id = p_person_id;

l_dummy VARCHAR2(1) := NULL;
l_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;

BEGIN

    OPEN get_prgm_stat ;
    FETCH get_prgm_stat INTO l_course_attempt_status ;
    CLOSE get_prgm_stat;
    IF l_course_attempt_status  = 'DISCONTIN' THEN

            --
            -- If the Source Program is Discontinued , then
            -- Determine if the source Program has a discontinuation reason code of type 'TRANSFER'.
            OPEN get_prgm_reasn ;
            FETCH get_prgm_reasn INTO l_dummy;
            IF get_prgm_reasn%NOTFOUND THEN
                CLOSE get_prgm_reasn;
                Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_TRNSFR_CD_INV' );
                FND_MSG_PUB.ADD;
                RETURN FALSE ;
           END IF ;
           CLOSE get_prgm_reasn;

    END IF;
    RETURN TRUE;

END validate_transfer;

FUNCTION get_uoo_id (
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_version_number IN NUMBER ,
p_uoo_id OUT NOCOPY NUMBER ,
p_owner_org_unit_cd OUT NOCOPY VARCHAR2
) RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function derives the Unit Offering Option ID.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
    --
    -- Cursor to derive uoo_id
    CURSOR get_uoo_id IS
   	SELECT uoo_id , owner_org_unit_cd
	FROM IGS_PS_UNIT_OFR_OPT
	WHERE unit_cd = p_unit_cd AND
    version_number = p_version_number AND
    cal_type = p_cal_type  AND
    ci_sequence_number = p_ci_sequence_number AND
    location_cd = p_location_cd AND
    unit_class = p_unit_class;

    l_org_unit_cd igs_or_unit.org_unit_cd%TYPE;
    l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;

BEGIN
      -- Derive uoo_id
      OPEN get_uoo_id ;
      FETCH get_uoo_id INTO l_uoo_id , l_org_unit_cd;

      IF get_uoo_id%NOTFOUND THEN
          CLOSE get_uoo_id ;
          Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_UNIT_OFR_OPT_NT_FND');
          FND_MSG_PUB.ADD;
          RETURN FALSE ;
	  END IF;

      CLOSE get_uoo_id ;
      p_uoo_id := l_uoo_id ;
      p_owner_org_unit_cd  := l_org_unit_cd ;
      RETURN TRUE ;

END get_uoo_id;

FUNCTION get_unit_ver (
p_cal_type IN VARCHAR2 ,
p_ci_sequence_number IN NUMBER ,
p_unit_cd IN VARCHAR2 ,
p_location_cd IN VARCHAR2 ,
P_unit_class IN VARCHAR2 ,
p_version_number OUT NOCOPY NUMBER
) RETURN BOOLEAN AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function derives the Unit version Number.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
    --
    -- Cursor to derive Unit version Number
    CURSOR get_unit_ver IS
    SELECT version_number
	FROM igs_ps_unit_ofr_opt
	WHERE cal_type = p_cal_type AND
	unit_cd = p_unit_cd AND
	ci_sequence_number = p_ci_sequence_number AND
    location_cd = p_location_cd AND
    unit_class = p_unit_class;

    --
    -- Cursor to find count of matching Unit version Number(s)
    CURSOR get_unit_ver_count  IS
    SELECT COUNT(*)
	FROM igs_ps_unit_ofr_opt
	WHERE cal_type = p_cal_type AND
	unit_cd = p_unit_cd AND
	ci_sequence_number = p_ci_sequence_number AND
    location_cd = p_location_cd AND
    unit_class = p_unit_class;

    l_version_number igs_en_su_attempt.version_number%TYPE;
    l_count NUMBER := 0;

BEGIN

    OPEN get_unit_ver ;
    FETCH get_unit_ver INTO l_version_number ;

     -- If No matching Unit versions found for a Unit section , Error Out.
     IF get_unit_ver%NOTFOUND THEN
         CLOSE get_unit_ver ;
         Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_UNT_VER_NA');
  	     FND_MSG_PUB.ADD;
         RETURN FALSE ;
     ELSE
         CLOSE get_unit_ver ;
         OPEN get_unit_ver_count  ;
         FETCH get_unit_ver_count INTO l_count ;
         CLOSE get_unit_ver_count ;

         -- If Multiple Unit versions found for a Unit section , Error Out.
         IF l_count > 1 THEN
             Fnd_Message.Set_Name( 'IGS' , 'IGS_EN_MUL_UNT_VER_EXTS');
             FND_MSG_PUB.ADD;
             RETURN FALSE ;
         END IF;
     END IF;
     p_version_number := l_version_number;
    RETURN TRUE;

END get_unit_ver;

FUNCTION validate_grad_sch_cd_ver (
            p_uoo_id IN NUMBER ,
            p_unit_cd IN VARCHAR2 ,
			p_version_number IN NUMBER ,
			p_grading_schema_code IN VARCHAR2 ,
            p_gs_version_number IN NUMBER ,
            P_message_name OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN
AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The function verifies if the Grading Schema Code/Version is  valid within the
                    enrolling unit section/version. It queries for the Grading Schema Code/Version
                    first at the Unit section level , and then at the Unit level. If it is not found
                    at both the levels , it returns an error message.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- cursor to check if the Grading Schema has been defined at the Unit section level
CURSOR val_usec IS
SELECT  'x'
FROM IGS_PS_USEC_GRD_SCHM
WHERE uoo_id = p_uoo_id AND
grading_schema_code            = p_grading_schema_code AND
grd_schm_version_number     =    p_gs_version_number;

--
-- cursor to check if the Grading Schema has been defined at the Unit level
CURSOR val_unit IS
SELECT 'x'
FROM IGS_PS_UNIT_GRD_SCHM
WHERE unit_code        = p_unit_cd   AND
unit_version_number            = p_version_number AND
grading_schema_code            = p_grading_schema_code AND
grd_schm_version_number     =    p_gs_version_number;

l_dummy VARCHAR2(1) := NULL ;

BEGIN
    p_message_name := NULL;
	OPEN val_usec ;
    FETCH val_usec INTO l_dummy ;

	IF val_usec%NOTFOUND THEN

		OPEN val_unit ;
        FETCH val_unit INTO l_dummy ;
	    IF val_unit%NOTFOUND THEN

            -- Grading Schema  has not been defined at the Unit section / Unit level.
            CLOSE val_usec ;
            CLOSE val_unit;
		    p_message_name := 'IGS_EN_GRD_SCH_NT_EXTS';
            RETURN FALSE;

    	END IF ;
        CLOSE val_unit;

    END IF ;

    CLOSE val_usec ;
    RETURN TRUE;

END validate_grad_sch_cd_ver;


FUNCTION validate_prgm_att_stat (
            p_person_id IN NUMBER ,
            p_course_cd IN VARCHAR2 ,
            p_discontin_dt OUT NOCOPY DATE ,
            p_program_type OUT NOCOPY VARCHAR2 ,
            p_commencement_dt OUT NOCOPY DATE ,
            p_version_number OUT NOCOPY NUMBER) RETURN VARCHAR2 AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : The  function Queries the Program Attempt details based on the person_id and course_cd.It does not
                    derive all possible statuses , but derives only the ones that are required for the calling routine.
                    If  the Confirmed Indicator is not set for the Program , the program status is UNCONFIRM.
                    If the discontinued date is set , the program status is DISCONTINUED.
                    If the Program Attempt has a corresponding date of commencement , the date is also fetched
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
--
-- cursor to fetch SPA details
CURSOR get_prgm_stats IS
SELECT student_confirmed_ind , course_attempt_status , discontinued_dt , primary_program_type , commencement_dt , version_number
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id  AND
course_cd = p_course_cd ;

cst_unconfirm 		CONSTANT VARCHAR2(10) := 'UNCONFIRM';
cst_discontin 		CONSTANT VARCHAR2(10) := 'DISCONTIN';

l_prgm_stats igs_en_stdnt_ps_att.course_attempt_status%TYPE;
l_confirmed_ind igs_en_stdnt_ps_att.student_confirmed_ind%TYPE;

BEGIN

    OPEN get_prgm_stats ;
    FETCH get_prgm_stats INTO l_confirmed_ind  , l_prgm_stats, p_discontin_dt, p_program_type ,  p_commencement_dt, p_version_number;
    CLOSE get_prgm_stats ;

    IF l_confirmed_ind  =  'N' THEN
        RETURN cst_unconfirm;
    END IF;

    IF l_prgm_stats = 'DISCONTIN' then
    	RETURN cst_discontin;
    END IF ;

    RETURN l_prgm_stats ;

END validate_prgm_att_stat;

PROCEDURE get_last_dt_of_att (
            x_person_id IN NUMBER,
            x_course_cd IN VARCHAR2,
            x_last_date_of_attendance OUT NOCOPY DATE ) AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           :  This routine  calculates the last date of attendance for a discontinued Unit Attempt.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/
    CURSOR cur_unit_atmpt_dis IS
      SELECT   cal_type,ci_sequence_number,discontinued_dt
      FROM     IGS_EN_SU_ATTEMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      discontinued_dt IS NOT NULL
      ORDER BY discontinued_dt DESC;

    CURSOR cur_term_cal(p_cal_type VARCHAR2,p_ci_sequence_number NUMBER, p_discontinued_dt DATE) IS
      SELECT   *
      FROM     IGS_CA_TEACH_TO_LOAD_V
      WHERE    teach_cal_type = p_cal_type
      AND      teach_ci_sequence_number = p_ci_sequence_number
      AND      load_start_dt <= TRUNC(p_discontinued_dt)
      ORDER BY load_start_dt DESC;

    CURSOR cur_unit_atmpt_grd IS
      SELECT   cal_type,ci_sequence_number
      FROM     IGS_EN_SU_ATTEMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_attempt_status='COMPLETED';


    CURSOR cur_term_cal_grd(p_cal_type VARCHAR2,p_ci_sequence_number NUMBER) IS
      SELECT   *
      FROM     IGS_CA_TEACH_TO_LOAD_V
      WHERE    teach_cal_type = p_cal_type
      AND      teach_ci_sequence_number = p_ci_sequence_number
      ORDER BY load_end_dt DESC;

    lv_cal_type IGS_CA_TEACH_TO_LOAD_V.teach_cal_type%TYPE;
    lv_ci_sequence_number IGS_CA_TEACH_TO_LOAD_V.teach_ci_sequence_number%TYPE;
    lv_discontinued_dt IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;

    cur_unit_atmpt_dis_rec cur_unit_atmpt_dis%ROWTYPE;
    cur_term_cal_rec cur_term_cal%ROWTYPE;
    cur_unit_atmpt_grd_rec cur_unit_atmpt_grd%ROWTYPE;
    cur_term_cal_grd_rec cur_term_cal_grd%ROWTYPE;

  BEGIN

    OPEN cur_unit_atmpt_dis;
    FETCH cur_unit_atmpt_dis INTO cur_unit_atmpt_dis_rec;

    IF cur_unit_atmpt_dis%FOUND THEN

         lv_cal_type := cur_unit_atmpt_dis_rec.cal_type;
         lv_ci_sequence_number := cur_unit_atmpt_dis_rec.ci_sequence_number;
         lv_discontinued_dt := cur_unit_atmpt_dis_rec.discontinued_dt;
         CLOSE cur_unit_atmpt_dis;


         OPEN cur_term_cal(lv_cal_type,lv_ci_sequence_number,lv_discontinued_dt);
         FETCH cur_term_cal INTO cur_term_cal_rec;
         IF (cur_term_cal%FOUND) THEN

             x_last_date_of_attendance := lv_discontinued_dt;
             CLOSE cur_term_cal;
         ELSE
             CLOSE cur_term_cal;
             lv_discontinued_dt := NULL;

             FOR cur_unit_atmpt_grd_rec IN cur_unit_atmpt_grd
             LOOP

                  OPEN cur_term_cal_grd(cur_unit_atmpt_grd_rec.cal_type,cur_unit_atmpt_grd_rec.ci_sequence_number);
                  FETCH cur_term_cal_grd INTO cur_term_cal_grd_rec;

                  IF (cur_term_cal_grd%FOUND) THEN

                        IF lv_discontinued_dt IS NULL THEN
                             lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
                        ELSIF lv_discontinued_dt < cur_term_cal_grd_rec.load_end_dt THEN
                             lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
                        END IF;

                  END IF;
                  CLOSE cur_term_cal_grd;

              END LOOP;

              x_last_date_of_attendance := lv_discontinued_dt;
         END IF;

    ELSE

        CLOSE cur_unit_atmpt_dis;
        lv_discontinued_dt := NULL;

        FOR cur_unit_atmpt_grd_rec IN cur_unit_atmpt_grd
        LOOP

           OPEN cur_term_cal_grd(cur_unit_atmpt_grd_rec.cal_type,cur_unit_atmpt_grd_rec.ci_sequence_number);
           FETCH cur_term_cal_grd INTO cur_term_cal_grd_rec;

           IF (cur_term_cal_grd%FOUND) THEN

              IF lv_discontinued_dt IS NULL THEN
                 lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
              ELSIF lv_discontinued_dt < cur_term_cal_grd_rec.load_end_dt THEN
                 lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
              END IF;

           END IF;

           CLOSE cur_term_cal_grd;

         END LOOP;

         x_last_date_of_attendance := lv_discontinued_dt;


    END IF;

END get_last_dt_of_att ;


FUNCTION get_coo_id(
p_course_cd                   IN  igs_ps_ofr_opt.course_cd%TYPE,
p_version_number              IN  igs_ps_ofr_opt.version_number%TYPE,
p_cal_type                    IN  igs_ps_ofr_opt.cal_type%TYPE,
p_location_cd                 IN  igs_ps_ofr_opt.location_cd%TYPE,
p_attendance_mode             IN  igs_ps_ofr_opt.attendance_mode%TYPE,
p_attendance_type             IN  igs_ps_ofr_opt.attendance_type%TYPE)
RETURN igs_ps_ofr_opt.coo_id%TYPE   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Returns the coo_id for a program offering.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR cur_coo_id IS SELECT coo_id FROM igs_ps_ofr_opt
                                   WHERE course_cd        = p_course_cd
                                   AND   version_number   = p_version_number
                                   AND   cal_type         = p_cal_type
                                   AND   location_cd      = p_location_cd
                                   AND   attendance_mode  = p_attendance_mode
                                   AND   attendance_type  = p_attendance_type;
l_coo_id         igs_ps_ofr_opt.coo_id%TYPE;
BEGIN
     --Return null if any of input parameters is null.
     IF p_course_cd        IS NULL OR
        p_version_number   IS NULL OR
        p_cal_type         IS NULL OR
        p_location_cd      IS NULL OR
        p_attendance_mode  IS NULL OR
        p_attendance_type  IS NULL  THEN
        RETURN NULL;
     END IF;
     --Get the coo_id for a program offering option.
     OPEN cur_coo_id;
     FETCH cur_coo_id INTO l_coo_id;
     IF cur_coo_id%NOTFOUND THEN
        CLOSE cur_coo_id;
        RETURN NULL;
     END IF;
     CLOSE cur_coo_id;
     RETURN l_coo_id;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.get_coo_id');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  get_coo_id;



FUNCTION get_class_std_id(
p_class_standing         IN igs_pr_class_std.class_standing%TYPE)
RETURN igs_pr_class_std.igs_pr_class_std_id%TYPE   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Returns the class standing identifier for a class standing.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR cur_class_std IS SELECT igs_pr_class_std_id FROM IGS_PR_CLASS_STD
                                                   WHERE class_standing = p_class_standing;
l_igs_pr_class_std_id          igs_pr_class_std.igs_pr_class_std_id%TYPE;
BEGIN
     --Return null if input parameters is null.
     IF p_class_standing IS NULL THEN
        RETURN NULL;
     END IF;
     --Get class identifier for the given class standing.
     OPEN cur_class_std;
     FETCH cur_class_std INTO l_igs_pr_class_std_id;
     IF cur_class_std%NOTFOUND THEN
        CLOSE cur_class_std;
        RETURN NULL;
     END IF;
     CLOSE cur_class_std;
     RETURN l_igs_pr_class_std_id;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.get_class_std_id');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END get_class_std_id;

FUNCTION get_course_att_status(
p_person_id                     IN igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd                     IN igs_en_stdnt_ps_att.course_cd%TYPE,
p_student_confirmed_ind         IN igs_en_stdnt_ps_att.student_confirmed_ind%TYPE,
p_discontinued_dt               IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
p_lapsed_dt                     IN igs_en_stdnt_ps_att.lapsed_dt%TYPE,
p_course_rqrmnt_complete_ind    IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
p_primary_pg_type               IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
p_primary_prog_type_source      IN igs_en_stdnt_ps_att.primary_prog_type_source%TYPE,
p_course_type                   IN igs_ps_type.course_type%TYPE,
p_career_flag                   IN VARCHAR2)
RETURN igs_en_stdnt_ps_att.course_attempt_status%TYPE   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose :Derives the program attempt status.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

l_course_att_status           igs_en_stdnt_ps_att.course_attempt_status%TYPE;
l_career_course_att_status    igs_en_stdnt_ps_att.course_attempt_status%TYPE;
BEGIN
        --Get program attempt status by calling following function.
        l_course_att_status :=igs_en_gen_006.enrp_get_sca_status(p_person_id,
                                                                 p_course_cd,
                                                                 'UNKNOWN',
                                                                 p_student_confirmed_ind,
                                                                 p_discontinued_dt,
                                                                 p_lapsed_dt,
                                                                 p_course_rqrmnt_complete_ind,
                                                                 NULL);
       l_career_course_att_status :=NULL;

       --Return the same program attempt status if career model is not enabled or primary program type is PRIMARY
       IF p_career_flag = 'N' OR
          NVL(p_primary_pg_type,'PRIMARY') = 'PRIMARY' THEN
          RETURN l_course_att_status;
       ELSE
         IF  l_course_att_status IN  ('INACTIVE','ENROLLED','LAPSED','INTERMIT') THEN
             l_career_course_att_status :=igs_en_career_model.enrp_get_sec_sca_status(p_person_id,
                                                                                      p_course_cd,
                                                                                      'UNKNOWN',
                                                                                      p_primary_pg_type,
                                                                                      p_primary_prog_type_source,
                                                                                      p_course_type,
                                                                                      NULL);
        END IF;
        RETURN NVL(l_career_course_att_status,l_course_att_status);
      END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.get_course_att_status');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END   get_course_att_status;


FUNCTION get_sca_dropped_by
RETURN igs_en_stdnt_ps_att.dropped_by%TYPE AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function returns the active staff person type.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR cur_per_type IS SELECT person_type_code FROM    igs_pe_person_types_v
                                               WHERE   system_type = 'STAFF'
                                               AND     closed_ind ='N';
l_person_type_code    igs_en_stdnt_ps_att.dropped_by%TYPE;
BEGIN
     l_person_type_code:= NULL;

     --Get  the active person type of STAFF.
     OPEN cur_per_type;
     FETCH cur_per_type INTO l_person_type_code;
     CLOSE cur_per_type;
     RETURN l_person_type_code;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.get_sca_dropped_by');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  get_sca_dropped_by;


FUNCTION get_sca_prog_type(
p_course_cd             IN igs_ps_ver.course_cd%TYPE,
p_version_number         IN igs_ps_ver.version_number%TYPE)
RETURN igs_ps_ver.course_type%TYPE   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Derives the program type for the given program code and version number.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR cur_cour_typ IS SELECT course_type FROM     IGS_PS_VER
                                          WHERE    course_cd      = p_course_cd
                                          AND      version_number = p_version_number;
l_course_type    igs_ps_ver.course_type%TYPE;
BEGIN
     --Return null if any of input parameters is null.
     IF p_course_cd IS NULL OR
        p_version_number IS NULL THEN
        RETURN NULL;
     END IF;

     --Derive the program type for a given program code and version number.
     OPEN cur_cour_typ;
     FETCH cur_cour_typ INTO l_course_type;
     IF cur_cour_typ%NOTFOUND THEN
        CLOSE cur_cour_typ;
        RETURN NULL;
     END IF;
     CLOSE cur_cour_typ;
     RETURN l_course_type;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.get_sca_prog_type');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  get_sca_prog_type;


FUNCTION val_sca_start_dt (
p_student_confirmed_ind  IN igs_en_stdnt_ps_att.student_confirmed_ind%TYPE,
p_commencement_dt        IN igs_en_stdnt_ps_att.commencement_dt%TYPE)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the commencement date against confirmation indicator.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
BEGIN
      IF (p_student_confirmed_ind ='N' AND p_commencement_dt IS NOT NULL) OR
         (p_student_confirmed_ind ='Y' AND p_commencement_dt IS NULL) OR
         (p_student_confirmed_ind IS NULL AND p_commencement_dt IS NOT NULL)THEN
             RETURN FALSE;
     ELSE
             RETURN TRUE;
     END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_start_dt');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_start_dt;


FUNCTION val_sca_disc_date(
p_discontinued_dt      igs_en_stdnt_ps_att.discontinued_dt%TYPE)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the discontinue date.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
BEGIN
    --If discontinue date is greater than the sysdate then return false else return true.
    IF (p_discontinued_dt > TRUNC(SYSDATE)) THEN
         RETURN FALSE;
    ELSE
          RETURN TRUE;
    END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_disc_date');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_disc_date;


FUNCTION val_sca_reqcmpl_dt(
p_course_rqrmnt_comp_ind        IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
p_course_rqrmnts_comp_dt        IN igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
p_message_name                  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validate the requirement completion date against requirement completion indicator
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
BEGIN
      IF p_course_rqrmnt_comp_ind  ='Y' AND  p_course_rqrmnts_comp_dt  IS NULL THEN
            p_message_name := 'IGS_EN_MST_RQRMNT_DT_CMP_FLAG';
            RETURN FALSE;
      ELSIF p_course_rqrmnt_comp_ind ='N' AND  p_course_rqrmnts_comp_dt IS NOT NULL THEN
            p_message_name := 'IGS_EN_RQRMNT_DT_NO_COMP_FLAG';
            RETURN FALSE;
      END IF;
      RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_reqcmpl_dt');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_reqcmpl_dt;


FUNCTION val_sca_key_prg(
p_person_id             IN igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd             IN igs_en_stdnt_ps_att.course_cd%TYPE,
p_key_program           IN igs_en_stdnt_ps_att.key_program%TYPE,
p_primary_prg_type      IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
p_course_attempt_st     IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
p_career_flag           IN VARCHAR2)
RETURN BOOLEAN   AS
/*-------------------------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the key program to a student program attempts.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  kkillams       13-12-2002       Removed code logic which checks key program
||                                  should be a active program w.r.t. bug no : 2708522
||  kkillams       27-12-2002       Bypassing the "minimum one program set as key program"
||                                  validation if course attempt status is UNCONFIRM
||                                  w.r.t. to bug 2721076
----------------------------------------------------------------------------------------------*/

CURSOR cur_count IS SELECT count(*)  FROM  igs_en_stdnt_ps_att
	                             WHERE key_program = 'Y'
	                             AND   person_id = p_person_id;
l_error          NUMBER :=0;
l_key_count      NUMBER :=0;
BEGIN
    --Get the total key program count for a given person.
    OPEN cur_count;
    FETCH cur_count INTO l_key_count;
    CLOSE cur_count;

    --If count is zero and current program is also not a key program then log the error message.
    IF l_key_count =0 AND p_key_program = 'N' AND  (p_course_attempt_st <> 'UNCONFIRM') THEN
       l_error:=1;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_SCA_NO_KEY_PROG');
       FND_MSG_PUB.ADD;
    --If count is one and current program is also a key program then log the error message.
    ELSIF l_key_count =1 AND p_key_program = 'Y' THEN
       l_error:=1;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_KEY_PROG');
       FND_MSG_PUB.ADD;
    --If count is greater than one then log the error message.
    ELSIF l_key_count > 1  THEN
       l_error:=1;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_KEY_PRO');
       FND_MSG_PUB.ADD;
    END IF;
    --In career model, If primary program type is not a primary and key program set to Y then log an error message.
    IF p_career_flag = 'Y' AND
       p_primary_prg_type <> 'PRIMARY' AND
       p_key_program ='Y' THEN
       l_error:=1;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_KEY_PROG_NOT_PRIMARY');
       FND_MSG_PUB.ADD;
    END IF;
    IF l_error = 1 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_key_prg');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END val_sca_key_prg;


FUNCTION val_sca_primary_pg(
p_person_id             IN igs_en_stdnt_ps_att.person_id%TYPE,
p_primary_prog_type     IN igs_en_stdnt_ps_att.primary_program_type%TYPE,
P_course_type           IN igs_ps_type.course_type%TYPE)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the primary program for a student program attempt for
||            a career.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR cur_count IS SELECT count(primary_program_type) FROM   igs_en_stdnt_ps_att sca,
                                                              igs_ps_ver crv
                                                       WHERE  crv.course_type          = p_course_type
                                                       AND    sca.course_cd            = crv.course_cd
                                                       AND    sca.version_number       = crv.version_number
                                                       AND    sca.person_id            = p_person_id
                                                       AND    sca.primary_program_type = 'PRIMARY';
l_count             NUMBER(3) := 0;
BEGIN
     --In career model, primary program type is null then log an error message.
     IF p_primary_prog_type IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRIMARY_PRG_MUST');
                FND_MSG_PUB.ADD;
                RETURN FALSE;
     END IF;
     --In career model, get total number of primary program for a given program type.
     OPEN cur_count;
     FETCH cur_count INTO l_count;
     CLOSE cur_count;

     --If count is zero and current primary program type is not a primary then log error message.
     IF l_count = 0  AND p_primary_prog_type <> 'PRIMARY' THEN
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_SCA_STDNT_NO_PRIMARY');
                 FND_MSG_PUB.ADD;
                 RETURN FALSE;
     --If count is one and current primary program type is a primary then log error message.
     ELSIF l_count = 1  AND p_primary_prog_type = 'PRIMARY' THEN
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_STDNT_PS_MORE_PRIMARY');
                 FND_MSG_PUB.ADD;
                 RETURN FALSE;
     --If count is more than one then log error message.
     ELSIF l_count > 1 THEN
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_STDNT_PS_MORE_PRIMARY');
                 FND_MSG_PUB.ADD;
                 RETURN FALSE;
     ELSE
                 RETURN TRUE;
     END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_primary_pg');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_primary_pg;


FUNCTION val_sca_comp_flag (
p_course_attempt_status         IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
p_course_rqrmnt_complete_ind    IN igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the requiriment compelete indicator against course attempt status.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
BEGIN
      --If requirement completion indicator is set to Y and program attempt status
      --is UNCONFIRM then return false else return ture.
      IF p_course_rqrmnt_complete_ind = 'Y' AND
         p_course_attempt_status = 'UNCONFIRM' THEN
          RETURN FALSE;
      ELSE
          RETURN TRUE;
      END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_comp_flag');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_comp_flag;

PROCEDURE raise_person_type_event(
p_person_id             igs_pe_typ_instances_all.person_id%TYPE,
p_person_type_code      igs_pe_typ_instances_all.person_type_code%TYPE,
p_person_type_start_date  igs_pe_typ_instances_all.start_date%TYPE,
p_person_type_end_date  igs_pe_typ_instances_all.end_date%TYPE,
p_type_instance_id       igs_pe_typ_instances_all.type_instance_id%TYPE,
p_system_person_type    VARCHAR2,
p_action                VARCHAR2
)
AS
 /**********************************************************************************************
  Created By      : pkpatel
  Date Created By : 30-Sep-05
  Purpose         : Raise the Business event to create the Responsibility mapped with the Person type
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

  l_prog_label               CONSTANT VARCHAR2(100) := 'igs.plsql.igs_en_gen_legacy.raise_person_type_event';
  l_label                    VARCHAR2(500);
  l_debug_str                VARCHAR2(3200);

CURSOR get_active_inst_cur(cp_person_id hz_parties.party_id%type,
                           cp_system_type igs_pe_person_types.system_type%type ,
			   cp_type_instance_id  igs_pe_typ_instances_all.type_instance_id%TYPE) IS
SELECT MAX(NVL(end_date,TO_DATE('4712/12/31','YYYY/MM/DD'))) FROM igs_pe_typ_instances_all pti
WHERE pti.person_id = cp_person_id
AND   pti.type_instance_id <> cp_type_instance_id
AND   SYSDATE BETWEEN pti.start_date and NVL(pti.end_date, SYSDATE)
AND   pti.person_type_code IN
      (select  person_type_code from igs_pe_person_types pt where system_type =cp_system_type) ;

  l_max_active_date DATE;
BEGIN

 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_label := 'igs.plsql.igs_en_gen_legacy.raise_person_type_event.'||p_action;
      l_debug_str := 'Person Type Code : '||p_person_type_code||'/'|| ' Person id : ' ||p_person_id ||'/'||
                  ' Start Date :'||p_person_type_start_date ||'/'||' End Date :' ||p_person_type_end_date;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
 END IF;

 IF p_action = 'INSERT' THEN
  -- End date is always passed as NULL, hence raise the Business event without any check
       igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(
              p_person_id,
              p_person_type_code,
              p_action,
              p_person_type_end_date
       );

 ELSIF p_action = 'UPDATE' THEN
 -- End date is always passed as TRUNC(SYSDATE). So if there is any other active record for the same person id type then no need to
 -- raise the business event.
    OPEN get_active_inst_cur(p_person_id, p_system_person_type, p_type_instance_id);
    FETCH get_active_inst_cur INTO l_max_active_date;
    CLOSE get_active_inst_cur;

    IF l_max_active_date IS NULL OR l_max_active_date < p_person_type_end_date THEN
       igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(
              p_person_id,
              p_person_type_code,
              p_action,
              p_person_type_end_date
       );

    END IF;
 END IF;

END raise_person_type_event;

FUNCTION val_sca_per_type(
p_person_id             igs_en_stdnt_ps_att.person_id%TYPE,
p_course_cd             igs_en_stdnt_ps_att.course_cd%TYPE,
p_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE)
RETURN BOOLEAN   AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Validates the person types.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| pkpatel        30-Sep-2005     Bug 4627888 (Raised the Business event after the Insert/update of the person type)
------------------------------------------------------------------------------*/
--Cursor get the person type instance for a person for a given person type.
CURSOR cur_per_inst(p_person_type igs_pe_person_types.system_type%TYPE)
IS SELECT pti.*
   FROM  igs_pe_typ_instances_all pti,
         igs_pe_person_types  pty
   WHERE pti.person_id = p_person_id
        AND   pti.course_cd = p_course_cd
        AND   pti.end_date IS NULL
        AND   pty.person_type_code = pti.person_type_code
        AND   pty.system_type = p_person_type;
rec_per_inst        cur_per_inst%ROWTYPE;

--Cursor get the person type for given system person type.
CURSOR cur_per_type(p_system_type igs_pe_person_types.system_type%TYPE)
                    IS  SELECT person_type_code FROM igs_pe_person_types
                                                WHERE SYSTEM_TYPE = p_system_type
                                                AND   CLOSED_IND = 'N';

CURSOR get_usr_id_cur(cp_person_id fnd_user.person_party_id%type) IS
SELECT user_id
FROM fnd_user
WHERE person_party_id = cp_person_id;

CURSOR cur_pe_seq IS SELECT IGS_PE_TYPE_INSTANCES_S.NEXTVAL FROM DUAL;

l_method            VARCHAR2(50) := 'PERSON_ENROL_UNIT_SECT';
l_error             NUMBER := 0;
l_person_type_code  igs_pe_person_types.person_type_code%TYPE;
l_type_instance_id  igs_pe_typ_instances.type_instance_id%TYPE;
l_user_id           fnd_user.user_id%TYPE;
l_sysdate           DATE := TRUNC(SYSDATE);
BEGIN
     -- Person Type business event should be raised only if the person is associated with a User
     OPEN get_usr_id_cur(p_person_id);
     FETCH get_usr_id_cur INTO l_user_id;
     CLOSE get_usr_id_cur;

     --Do following validation for the program attempt status is inactive and enrolled.
     IF p_course_attempt_status IN ('INACTIVE' ,'ENROLLED')  THEN
        IF p_course_attempt_status = 'INACTIVE' THEN
           --Check whether person type instance of type APPLICANT is exist for the given person id
           -- if exist then update the end date with sysdate.
           OPEN cur_per_inst('APPLICANT');
           FETCH cur_per_inst INTO rec_per_inst;
           IF cur_per_inst%FOUND THEN
                   UPDATE igs_pe_typ_instances_all
                   SET end_date                = l_sysdate ,
                       end_method              = l_method ,
                       last_update_date        = SYSDATE,
                       last_updated_by         = NVL(fnd_global.user_id,-1) ,
                       last_update_login       = NVL(fnd_global.login_id,-1)
                   WHERE type_instance_id      = rec_per_inst.type_instance_id;

              IF l_user_id IS NOT NULL THEN
                raise_person_type_event(
                        p_person_id             => p_person_id,
                        p_person_type_code      => rec_per_inst.person_type_code,
                        p_person_type_start_date  => rec_per_inst.start_date,
                        p_person_type_end_date  => l_sysdate,
                        p_type_instance_id       => rec_per_inst.type_instance_id,
                        p_system_person_type    => 'APPLICANT',
                        p_action                => 'UPDATE'
                      );
              END IF;

           END IF;
           CLOSE cur_per_inst;
        END IF;
        l_person_type_code := NULL;
        OPEN cur_per_type('STUDENT');
        FETCH  cur_per_type INTO l_person_type_code;
        IF cur_per_type%NOTFOUND THEN
           l_error := 1;
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_PERSON_TYPE_NOTFOUND');
           FND_MESSAGE.SET_TOKEN('TYPE','STUDENT');
           FND_MSG_PUB.ADD;
        ELSE
           --Check whether person type instance of type STUDENT is exist for the given person id
           --If not exist then create the person type instance of type STUDENT
           OPEN cur_per_inst('STUDENT');
           FETCH cur_per_inst INTO rec_per_inst;
           IF cur_per_inst%NOTFOUND THEN

                 OPEN cur_pe_seq;
                 FETCH cur_pe_seq INTO l_type_instance_id;
                 CLOSE cur_pe_seq;

                 INSERT INTO igs_pe_typ_instances_all(type_instance_id,
                                                      person_type_code,
                                                      person_id,
                                                      course_cd,
                                                      cc_version_number,
                                                      funnel_status,
                                                      admission_appl_number,
                                                      nominated_course_cd,
                                                      ncc_version_number,
                                                      sequence_number,
                                                      start_date,
                                                      end_date,
                                                      create_method,
                                                      ended_by,
                                                      end_method,
                                                      created_by,
                                                      creation_date,
                                                      last_updated_by,
                                                      last_update_date,
                                                      last_update_login,
                                                      org_id)VALUES(
                                                      l_type_instance_id,
                                                      l_person_type_code,
                                                      p_person_id,
                                                      p_course_cd,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      l_sysdate,
                                                      NULL,
                                                      l_method,
                                                      NULL,
                                                      NULL,
                                                      NVL(fnd_global.user_id,-1),
                                                      SYSDATE,
                                                      NVL(fnd_global.user_id,-1),
                                                      SYSDATE,
                                                      NVL(fnd_global.login_id,-1),
                                                      igs_ge_gen_003.get_org_id);

	              IF l_user_id IS NOT NULL THEN
	                raise_person_type_event(
	                        p_person_id             => p_person_id,
	                        p_person_type_code      => l_person_type_code,
	                        p_person_type_start_date  => l_sysdate,
	                        p_person_type_end_date  => TO_DATE(null),
	                        p_type_instance_id       => TO_NUMBER(null),
	                        p_system_person_type    => 'STUDENT',
	                        p_action                => 'INSERT'
	                      );
	              END IF;
            END IF;
           CLOSE cur_per_inst;
        END IF;
        CLOSE cur_per_type;
        --Check whether person type instance of type FORMER_STUDENT is exist for the given person id
        --if exist then update the end date with sysdate.
        OPEN cur_per_inst('FORMER_STUDENT');
        FETCH cur_per_inst INTO rec_per_inst;
        IF cur_per_inst%FOUND THEN
                   UPDATE igs_pe_typ_instances_all
                   SET end_date                = l_sysdate,
                       end_method              = l_method,
                       last_update_date        = SYSDATE ,
                       last_updated_by         = NVL(fnd_global.user_id,-1) ,
                       last_update_login       = NVL(fnd_global.login_id,-1)
                   WHERE type_instance_id      = rec_per_inst.type_instance_id;

	              IF l_user_id IS NOT NULL THEN
	                raise_person_type_event(
	                        p_person_id             => p_person_id,
	                        p_person_type_code      => rec_per_inst.person_type_code,
	                        p_person_type_start_date  => rec_per_inst.start_date,
	                        p_person_type_end_date  => l_sysdate,
	                        p_type_instance_id       => rec_per_inst.type_instance_id,
	                        p_system_person_type    => 'FORMER_STUDENT',
	                        p_action                => 'UPDATE'
	                      );
	              END IF;
        END IF;
        CLOSE cur_per_inst;
     ELSIF p_course_attempt_status IN ('LAPSED','DISCONTIN' ,'COMPLETED') THEN
        --Check whether person type instance of type STUDENT is exist for the given person id
        --if exist then update the end date with sysdate.
        OPEN cur_per_inst('STUDENT');
        FETCH cur_per_inst INTO rec_per_inst;
        IF cur_per_inst%FOUND THEN
                   UPDATE igs_pe_typ_instances_all
                   SET end_date                = l_sysdate,
                       end_method              = l_method ,
                       last_update_date        = SYSDATE ,
                       last_updated_by         = NVL(fnd_global.user_id,-1) ,
                       last_update_login       = NVL(fnd_global.login_id,-1)
                   WHERE type_instance_id      = rec_per_inst.type_instance_id;

	              IF l_user_id IS NOT NULL THEN
	                raise_person_type_event(
	                        p_person_id             => p_person_id,
	                        p_person_type_code      => rec_per_inst.person_type_code,
	                        p_person_type_start_date  => rec_per_inst.start_date,
	                        p_person_type_end_date  => l_sysdate,
	                        p_type_instance_id       => rec_per_inst.type_instance_id,
	                        p_system_person_type    => 'STUDENT',
	                        p_action                => 'UPDATE'
	                      );
	              END IF;
        END IF;
        CLOSE cur_per_inst;

        l_person_type_code := NULL;
        OPEN cur_per_type('FORMER_STUDENT');
        FETCH  cur_per_type INTO l_person_type_code;
        IF cur_per_type%NOTFOUND THEN
           l_error := 1;
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_PERSON_TYPE_NOTFOUND');
           FND_MESSAGE.SET_TOKEN('TYPE','FORMER_STUDENT');
           FND_MSG_PUB.ADD;
        ELSE
           --Check whether person type instance of type FORMER_STUDENT is exist for the given person id
           -- If not exist then create the person type instance of type FORMER_STUDENT
           OPEN cur_per_inst('FORMER_STUDENT');
           FETCH cur_per_inst INTO rec_per_inst;
           IF cur_per_inst%NOTFOUND THEN

                 OPEN cur_pe_seq;
                 FETCH cur_pe_seq INTO l_type_instance_id;
                 CLOSE cur_pe_seq;

                 INSERT INTO igs_pe_typ_instances_all(type_instance_id,
                                                      person_type_code,
                                                      person_id,
                                                      course_cd,
                                                      cc_version_number,
                                                      funnel_status,
                                                      admission_appl_number,
                                                      nominated_course_cd,
                                                      ncc_version_number,
                                                      sequence_number,
                                                      start_date,
                                                      end_date,
                                                      create_method,
                                                      ended_by,
                                                      end_method,
                                                      created_by,
                                                      creation_date,
                                                      last_updated_by,
                                                      last_update_date,
                                                      last_update_login,
                                                      org_id)VALUES(
                                                      l_type_instance_id,
                                                      l_person_type_code,
                                                      p_person_id,
                                                      p_course_cd,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      l_sysdate,
                                                      NULL,
                                                      l_method,
                                                      NULL,
                                                      NULL,
                                                      NVL(fnd_global.user_id,-1),
                                                      SYSDATE,
                                                      NVL(fnd_global.user_id,-1),
                                                      SYSDATE,
                                                      NVL(fnd_global.login_id,-1),
                                                      igs_ge_gen_003.get_org_id);

	              IF l_user_id IS NOT NULL THEN
	                raise_person_type_event(
	                        p_person_id             => p_person_id,
	                        p_person_type_code      => l_person_type_code,
	                        p_person_type_start_date  => l_sysdate,
	                        p_person_type_end_date  => TO_DATE(null),
	                        p_type_instance_id       => TO_NUMBER(null),
	                        p_system_person_type    => 'FORMER_STUDENT',
	                        p_action                => 'INSERT'
	                      );
	              END IF;
            END IF;
           CLOSE cur_per_inst;
        END IF;
        CLOSE cur_per_type;
     END IF;
     IF l_error = 1 THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.val_sca_per_type');
                FND_MSG_PUB.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END  val_sca_per_type;


FUNCTION check_pre_enroll_prof (p_unit_set_cd	    IN igs_as_su_setatmpt.unit_set_cd%TYPE,
                                p_us_version_number	IN igs_as_su_setatmpt.us_version_number%TYPE)
                                RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 21-Nov-2002
||  Purpose : Check the condition that if profile option is set, unit sets is of
||            category 'pre-enrollment year'
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

CURSOR c_prenrol_unitset IS
SELECT
'x'
FROM
    igs_en_unit_set us,
    igs_en_unit_set_cat usc
WHERE
    us.unit_set_cd      = p_unit_set_cd
AND us.version_number   = p_us_version_number
AND us.unit_set_cat     = usc.unit_set_cat
AND usc.s_unit_set_cat  = 'PRENRL_YR';

    l_dummy     VARCHAR2(1);
BEGIN

    IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'N' THEN
        OPEN c_prenrol_unitset;
        FETCH c_prenrol_unitset INTO l_dummy;
        IF c_prenrol_unitset%FOUND THEN
            CLOSE c_prenrol_unitset;
            RETURN FALSE;
        ELSE
            CLOSE c_prenrol_unitset;
            RETURN TRUE;
        END IF;
    ELSE
        RETURN TRUE;
    END IF;

EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.check_pre_enroll_prof');
                FND_MSG_PUB.Add;
                App_Exception.Raise_Exception;

END check_pre_enroll_prof;



FUNCTION check_usa_overlap (p_person_id		        IN igs_as_su_setatmpt.person_id%TYPE,
                            p_program_cd	        IN igs_as_su_setatmpt.course_cd%TYPE,
                            p_selection_dt	        IN igs_as_su_setatmpt.selection_dt%TYPE,
                            p_rqrmnts_complete_dt	IN igs_as_su_setatmpt.rqrmnts_complete_dt%TYPE,
                            p_end_dt                IN igs_as_su_setatmpt.end_dt%TYPE,
                            p_sequence_number       IN igs_as_su_setatmpt.sequence_number%TYPE,
                            p_unit_set_cd           IN igs_as_su_setatmpt.unit_set_cd%TYPE,
                            p_us_version_number     IN igs_as_su_setatmpt.us_version_number%TYPE,
                            p_message_name          OUT NOCOPY VARCHAR2)
                            RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 21-Nov-2002
||  Purpose : Check the condition that unit sets with category of 'pre-enrollment year'
||            cannot overlap selection/completion dates
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  bdeviset     29-JUL-2004        Added extra parameters p_end_dt,p_sequence_number to
||                                  function check_usa_overlap for Bug 3149133.
||                                  Modified cursor c_usa_ovrlp as unit sets with category of
||                                  'pre-enrollment year' cannot overlap selection,completion
||                                  and end dates for 3149133
||  ckasu        28-OCT-2005        Added code to check whether passed unit_set_cd is PRENRL_YR
||                                  type or not.if so return false else continue
||  stutta       26-APR-2005        Modified c_sua_ovrlp to correct a join conditions bug5070647
------------------------------------------------------------------------------*/

CURSOR c_us_cat (cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE,
                 cp_us_version_number igs_as_su_setatmpt.us_version_number%TYPE) IS
SELECT usc.s_unit_set_cat
FROM igs_en_unit_set us,
     igs_en_unit_set_cat usc
WHERE us.unit_set_cd = cp_unit_set_cd
AND us.version_number = cp_us_version_number
AND us.unit_set_cat     = usc.unit_set_cat;


CURSOR c_usa_ovrlp IS
SELECT
'x'
FROM
    igs_as_su_setatmpt asu,
    igs_en_unit_set us,
    igs_en_unit_set_cat usc
WHERE
    asu.person_id       = p_person_id
AND asu.course_cd       = p_program_cd
AND asu.unit_set_cd     = us.unit_set_cd
AND asu.us_version_number = us.version_number
AND us.unit_set_cat     = usc.unit_set_cat
AND usc.s_unit_set_cat  = 'PRENRL_YR'
AND ((asu.selection_dt BETWEEN p_selection_dt
AND NVL (p_rqrmnts_complete_dt,NVL(p_end_dt,(TO_DATE('9999/12/31','YYYY/MM/DD')))))
OR (p_selection_dt BETWEEN asu.selection_dt
AND NVL (asu.rqrmnts_complete_dt,NVL(asu.end_dt,(TO_DATE('9999/12/31','YYYY/MM/DD'))))))
AND ((p_sequence_number IS NULL) OR (asu.sequence_number <> p_sequence_number));

    l_dummy     VARCHAR2(1);
    l_s_unit_set_cat igs_en_unit_set_cat.s_unit_set_cat%TYPE;
BEGIN

    -- check if the passed in unit set is a pre-enrollment year unit set
    -- if the passed in unit set is not a pre-enr unit set then return true

    l_s_unit_set_cat := NULL;
    OPEN c_us_cat (p_unit_set_cd, p_us_version_number);
    FETCH c_us_cat INTO l_s_unit_set_cat;
    IF l_s_unit_set_cat IS NOT NULL AND l_s_unit_set_cat <> 'PRENRL_YR'  THEN
      CLOSE c_us_cat;
      RETURN TRUE;
    END IF;
    CLOSE c_us_cat;

    OPEN c_usa_ovrlp;
    FETCH c_usa_ovrlp INTO l_dummy;

    IF c_usa_ovrlp%FOUND THEN
        CLOSE c_usa_ovrlp;
        p_message_name := 'IGS_EN_ONLY_ONE_PRENRL_YR_US';
        RETURN FALSE;
    ELSE
        CLOSE c_usa_ovrlp;
        RETURN TRUE;
    END IF;

EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.check_usa_overlap');
                FND_MSG_PUB.Add;
                App_Exception.Raise_Exception;

END check_usa_overlap;



FUNCTION check_dup_susa (p_person_id		    IN igs_as_su_setatmpt.person_id%TYPE,
                         p_program_cd	        IN igs_as_su_setatmpt.course_cd%TYPE,
                         p_unit_set_cd          IN igs_as_su_setatmpt.unit_set_cd%TYPE,
                         p_us_version_number    IN igs_as_su_setatmpt.us_version_number%TYPE,
                         p_selection_dt	        IN igs_as_su_setatmpt.selection_dt%TYPE)
                         RETURN BOOLEAN AS

/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 21-Nov-2002
||  Purpose : Check for duplicate student unit set attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
CURSOR c_dup_susa IS
SELECT
'x'
FROM
    igs_as_su_setatmpt
WHERE
    person_id           = p_person_id
AND course_cd           = p_program_cd
AND unit_set_cd         = p_unit_set_cd
AND us_version_number   = p_us_version_number
AND ((selection_dt  IS NULL AND p_selection_dt IS NULL)
OR  selection_dt       = p_selection_dt );

    l_dummy     VARCHAR2(1);
BEGIN

    OPEN c_dup_susa;
    FETCH c_dup_susa INTO l_dummy;

    IF c_dup_susa%FOUND THEN
        CLOSE c_dup_susa;
        RETURN TRUE;
    ELSE
        CLOSE c_dup_susa;
        RETURN FALSE;
    END IF;

EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_gen_legacy.check_dup_susa');
                FND_MSG_PUB.Add;
                App_Exception.Raise_Exception;

END check_dup_susa;


 FUNCTION validate_intm_ua_ovrlp (
    p_person_id         IN      igs_en_stdnt_ps_intm.person_id%TYPE,
    p_program_cd        IN      igs_en_stdnt_ps_intm.course_cd%TYPE,
    p_start_dt          IN      igs_en_stdnt_ps_intm.start_dt%TYPE,
    p_end_dt            IN      igs_en_stdnt_ps_intm.end_dt%TYPE
 ) RETURN BOOLEAN AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 21-Nov-2002
  Purpose         : This function checks whether intermission period overlaps enrolled/completed
                    unit attempt teaching period census dates.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

 CURSOR c_s_gen_cal_conf IS
   SELECT  census_dt_alias
   FROM    igs_ge_s_gen_cal_con
   WHERE   s_control_num = 1;

 -- Cursor to check whether intermission period overlaps enrolled/completed unit attempt
 -- teaching period census dates.

 CURSOR c_intm_census_ovrlp(l_census_dt_alias  igs_ge_s_gen_cal_con.census_dt_alias%TYPE) IS
   SELECT 'x'
   FROM   igs_en_su_attempt sua,
          igs_ca_da_inst_v da
   WHERE  sua.person_id =  p_person_id
     AND  sua.course_cd =  p_program_cd
     AND  sua.unit_attempt_status IN ('ENROLLED','COMPLETED')
     AND  sua.cal_type  = da.cal_type
     AND  sua.ci_sequence_number = da.ci_sequence_number
     AND  da.dt_alias   =  l_census_dt_alias
     AND  da.alias_val IS NOT NULL
     AND  da.alias_val BETWEEN p_start_dt AND p_end_dt ;

  l_interm_perd VARCHAR2(1);
  l_census_dt_alias igs_ge_s_gen_cal_con.census_dt_alias%TYPE;

 BEGIN

   OPEN c_s_gen_cal_conf;
   FETCH c_s_gen_cal_conf INTO l_census_dt_alias;

   IF c_s_gen_cal_conf%FOUND THEN

     OPEN c_intm_census_ovrlp (l_census_dt_alias);
     FETCH c_intm_census_ovrlp INTO l_interm_perd;
     CLOSE c_s_gen_cal_conf;

     IF c_intm_census_ovrlp%FOUND THEN
        CLOSE c_intm_census_ovrlp;
        RETURN FALSE;
     ELSE
        CLOSE c_intm_census_ovrlp;
        RETURN TRUE;
     END IF;
   END IF;

   IF c_s_gen_cal_conf%ISOPEN THEN
      CLOSE c_s_gen_cal_conf;
   END IF;
   RETURN TRUE;

 END validate_intm_ua_ovrlp;


 FUNCTION check_approv_reqd (
    p_intermission_type IN    igs_en_stdnt_ps_intm.intermission_type%TYPE
 ) RETURN BOOLEAN as

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 21-Nov-2002
  Purpose         : This function is used to check whether approval is required for the
                    intermission or not.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

 CURSOR c_approv IS
   SELECT appr_reqd_ind
   FROM igs_en_intm_types
   WHERE intermission_type = p_intermission_type;

 l_appr_reqd_ind   igs_en_intm_types.appr_reqd_ind%TYPE;

 BEGIN
   -- Cursor to check whether Approval is required for intermission or not.
   OPEN c_approv;
   FETCH c_approv INTO l_appr_reqd_ind;
   CLOSE c_approv;

   IF l_appr_reqd_ind = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

 END check_approv_reqd;



 FUNCTION check_study_antr_instu (
    p_intermission_type   IN   igs_en_stdnt_ps_intm.intermission_type%TYPE
 ) RETURN BOOLEAN as

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         : This function will check whether srudent is studying at another
                    institution or not.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

 CURSOR c_study_antr_instu IS
   SELECT study_antr_inst_ind
   FROM   igs_en_intm_types
   WHERE  intermission_type = p_intermission_type;

 l_study_antr_inst_ind    igs_en_intm_types.study_antr_inst_ind%TYPE;

 BEGIN

   -- Check whether study at another institution is set or not.
   OPEN c_study_antr_instu;
   FETCH c_study_antr_instu INTO l_study_antr_inst_ind;
   CLOSE c_study_antr_instu;

   IF l_study_antr_inst_ind = 'Y' THEN
      RETURN TRUE;
   ELSE
     RETURN FALSE;
   END IF;

END check_study_antr_instu;



 FUNCTION check_institution (
    p_institution_name    IN     igs_en_stdnt_ps_intm.institution_name%TYPE
 ) RETURN BOOLEAN AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 21-Nov-2002
  Purpose         : This function checks the validity of the institution. (i.e) it checks
                    whether the specified institution is present or not.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

   CURSOR c_inst IS
   SELECT 'x'
   FROM hz_parties hp, igs_pe_hz_parties ihp
   WHERE hp.party_id =   ihp.party_id AND
          ihp.inst_org_ind = 'I' AND
          ihp.oi_govt_institution_cd is not null AND
          ihp.oss_org_unit_cd = p_institution_name ;

    CURSOR c_lkups IS
    SELECT 'X'
    FROM igs_lookup_values lk
    WHERE lk.lookup_type =  'OR_INST_EXEMPTIONS' AND
          lk.enabled_flag = 'Y' AND
          lk.lookup_code = p_institution_name ;


 l_inst_name VARCHAR2(1);

 BEGIN
   -- Check whether the institution is present or not. If is is found then return true.
   OPEN c_inst;
   FETCH c_inst INTO l_inst_name;

   IF c_inst%FOUND THEN
      CLOSE c_inst;
      RETURN TRUE;
   ELSE
      CLOSE c_inst;
      OPEN c_lkups;
      FETCH c_lkups INTO l_inst_name;
      IF c_lkups%FOUND THEN
            CLOSE c_lkups;
            RETURN TRUE;
      ELSE
            CLOSE c_lkups;
            RETURN FALSE;
      END IF;

   END IF;

END check_institution;


FUNCTION check_sca_status_upd (
   p_person_id               IN   igs_en_stdnt_ps_intm.person_id%TYPE,
   p_program_cd              IN   igs_en_stdnt_ps_intm.course_cd%TYPE,
   p_called_from             IN   VARCHAR2,
   p_course_attempt_status   OUT  NOCOPY igs_en_stdnt_ps_att.course_attempt_status%TYPE
 ) RETURN BOOLEAN as
 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         : This function is used to check whether program attempt status needs to be
                    updated or not.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

 CURSOR c_sca IS
   SELECT sca.course_attempt_status,
          sca.student_confirmed_ind,
          sca.discontinued_dt,
          sca.lapsed_dt,
          sca.course_rqrmnt_complete_ind,
          sca.logical_delete_dt
   FROM   igs_en_stdnt_ps_att sca
   WHERE  sca.person_id = p_person_id
   AND    sca.course_cd = p_program_cd;

 l_sca_row c_sca%ROWTYPE;
 l_pred_sca_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;

 BEGIN

   OPEN c_sca;
   FETCH c_sca INTO l_sca_row;
   CLOSE c_sca;

   -- Get the program attempt status
   l_pred_sca_status := igs_en_gen_006.enrp_get_sca_status (
                          p_person_id,
                          p_program_cd,
                          l_sca_row.course_attempt_status,
                          l_sca_row.student_confirmed_ind,
                          l_sca_row.discontinued_dt,
                          l_sca_row.lapsed_dt,
                          l_sca_row.course_rqrmnt_complete_ind,
                          l_sca_row.logical_delete_dt
                        );

   p_course_attempt_status := l_pred_sca_status;

   -- Call from Intermission API
   IF p_called_from = 'SPI' THEN
      IF (l_pred_sca_status = 'INTERMIT') AND (l_sca_row.course_attempt_status <> l_pred_sca_status) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
   -- Call from Student Unit Attempt API
   ELSIF p_called_from = 'SUA' THEN
      IF l_sca_row.course_attempt_status <> l_pred_sca_status THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END IF;

   RETURN FALSE;

 END check_sca_status_upd;

FUNCTION validate_awd_offer_pgm(
          p_person_id  IN NUMBER,
          p_program_cd IN VARCHAR2,
          p_award_cd   IN VARCHAR2)
RETURN BOOLEAN AS
/*
||  Created By : nbehera
||  Created On : 22-NOV-2002
||  Purpose    : This function will check whether the award code is
||               offered within the enrolled program version.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  smvk            03-Jun-2003     Bug # 2858436. Modified the cursor c_awd_prg_ver to pick up open
||                                  Program Awards only. As mentioned in TD.
||  (reverse chronological order - newest change first)
*/
CURSOR c_awd_prg_ver IS
SELECT 'X'
FROM   igs_en_stdnt_ps_att spa,
       igs_ps_award psa
WHERE  spa.person_id = p_person_id
AND    spa.course_cd = p_program_cd
AND    psa.award_cd = p_award_cd
AND    spa.course_cd = psa.course_cd
AND    spa.version_number = psa.version_number
AND    psa.closed_ind = 'N';
l_dummy  VARCHAR2(1);

BEGIN
  OPEN c_awd_prg_ver;
  FETCH c_awd_prg_ver INTO l_dummy;

  IF c_awd_prg_ver%FOUND THEN
       CLOSE c_awd_prg_ver;
       RETURN TRUE;
  ELSE
       CLOSE c_awd_prg_ver;
       RETURN FALSE;
  END IF;
END validate_awd_offer_pgm;

END igs_en_gen_legacy;

/
