--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPA_TERMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPA_TERMS_API" AS
/* $Header: IGSENB1B.pls 120.14 2005/11/28 02:26:46 appldev noship $ */

CURSOR c_term_exists(cp_person_id IGS_PE_PERSON.person_id%TYPE,
                     cp_program_cd IGS_PS_VER.course_cd%TYPE,
                     cp_program_version IGS_PS_VER.version_number%TYPE,
                     cp_term_cal_type IGS_CA_INST.cal_type%TYPE,
                     cp_term_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
SELECT spat.term_record_id
       FROM IGS_EN_SPA_TERMS spat, igs_ps_ver cv1
       WHERE spat.person_id = cp_person_id
       AND   spat.term_cal_type = cp_term_cal_type
       AND   spat.term_sequence_number = cp_term_sequence_number
       AND   cv1.course_cd = spat.program_cd
       AND   cv1.version_number = spat.program_version
       AND
       (    (
                 NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y'
                 AND  cv1.course_type = (SELECT cv2.course_type
                               FROM IGS_PS_VER cv2
                               WHERE cv2.course_cd      = cp_program_cd
                               AND   cv2.version_number = cp_program_version)
            )
            OR
            (   NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N'
                AND spat.program_cd = cp_program_cd
            )
       );

PROCEDURE set_spa_term_cal_type(p_spa_term_cal_type IN VARCHAR2)
AS
BEGIN
        g_spa_term_cal_type := p_spa_term_cal_type;
END;

PROCEDURE set_spa_term_sequence_number(p_spa_term_sequence_number IN NUMBER)
AS
BEGIN
        g_spa_term_sequence_number := p_spa_term_sequence_number;
END;

PROCEDURE validate_term_rec(p_term_rec EN_SPAT_REC_TYPE%TYPE) AS

-- Check if the term calendar is subordinate to the acad cal type
-- as defined in its term record
cursor c_term_acad IS
SELECT 'x'
FROM  igs_ca_inst_rel
WHERE sub_cal_type = p_term_rec.term_cal_type
AND   sub_ci_sequence_number = p_term_rec.term_sequence_number
AND   sup_cal_type = p_term_rec.acad_cal_type;

-- Check if the program offering option with the values specified
-- in term record exists
cursor c_coo_valid IS
SELECT 'x'
FROM igs_ps_ofr_opt
WHERE coo_id = p_term_rec.coo_id
AND   location_cd = p_term_rec.location_cd
AND   version_number = p_term_rec.program_version
AND   attendance_type = p_term_rec.attendance_type
AND   attendance_mode = p_term_rec.attendance_mode
AND   cal_type = p_term_rec.acad_cal_type
AND   course_cd = p_term_rec.program_cd;

l_dummy VARCHAR2(1);
BEGIN
    OPEN c_term_acad;
    FETCH c_term_acad INTO l_dummy;
    IF (c_term_acad%NOTFOUND) THEN
          CLOSE c_term_acad;

          FND_MESSAGE.SET_NAME('IGS','IGS_EN_TERM_VALID_FAILED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE c_term_acad;
    OPEN c_coo_valid;
    FETCH c_coo_valid INTO l_dummy;
    IF (c_coo_valid%NOTFOUND) THEN
        CLOSE c_coo_valid;
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_TERM_VALID_FAILED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE c_coo_valid;

END validate_term_rec;


FUNCTION find_key_effective_for(p_person_id IN IGS_PE_PERSON.PERSON_ID%TYPE,
                p_term_cal_type IN igs_ca_inst.cal_type%TYPE,
                p_term_sequence_number IN igs_ca_inst.sequence_number%TYPE) RETURN VARCHAR2
AS
-- Check if key term record exists for the passed in term calendar
cursor c_key_record_exists IS
select program_cd from igs_en_spa_terms where person_id = p_person_id
and key_program_flag = 'Y'
and term_cal_type = p_term_cal_type
and term_sequence_number = p_term_sequence_number;

-- Check the oldest key term record in terms table
CURSOR c_oldest_term IS
SELECT program_cd, acad_cal_type
FROM igs_en_spa_terms spat, igs_ca_inst ca1
WHERE person_id = p_person_id
AND   spat.term_cal_type = ca1.cal_type
AND   spat.term_sequence_number = ca1.sequence_number
AND   spat.key_program_flag = 'Y'
ORDER BY ca1.start_dt ASC;

-- Check the key term record before this term
CURSOR c_key_from_prev_term IS
select program_cd, acad_cal_type from igs_en_spa_terms spat, igs_ca_inst ca1, igs_ca_inst ca2
where key_program_flag = 'Y'
and person_id = p_person_id
and ca1.cal_type = term_cal_type
and ca1.sequence_number = term_sequence_number
and ca2.cal_type = p_term_cal_type
and ca2.sequence_number = p_term_sequence_number
and ca1.start_dt < ca2.start_dt order by ca1.start_dt desc;

-- Key program as in student program attempt and its academic calendar
CURSOR c_key_from_spa IS
select course_cd, cal_type from igs_en_stdnt_ps_att where person_id = p_person_id and key_program ='Y';

-- Check if the academic calendar for the key determined is same as that of passed in term.
CURSOR c_key_in_same_acad(cp_acad_cal_type IGS_CA_INST.CAL_TYPE%TYPE) IS
SELECT 'x'
FROM igs_ca_inst_rel
WHERE sub_cal_type = p_term_cal_type
and   sub_ci_sequence_number = p_term_sequence_number
and sup_cal_type = cp_acad_cal_type;

l_program_cd IGS_PS_VER.course_cd%TYPE;
l_dummy VARCHAR2(1);
l_acad_cal_type IGS_CA_INST.CAL_TYPE%TYPE;
BEGIN
OPEN c_key_record_exists;
FETCH c_key_record_exists INTO l_program_cd;
IF (c_key_record_exists%FOUND) THEN
        CLOSE c_key_record_exists;
        RETURN l_program_cd;
END IF;
CLOSE c_key_record_exists;
OPEN c_key_from_prev_term;
FETCH c_key_from_prev_term INTO l_program_cd, l_acad_cal_type;
IF (c_key_from_prev_term%NOTFOUND) THEN
        OPEN c_oldest_term;
        FETCH c_oldest_term INTO l_program_cd, l_acad_cal_type;
        IF  c_oldest_term%NOTFOUND THEN
                OPEN c_key_from_spa;
                FETCH c_key_from_spa INTO l_program_cd, l_acad_cal_type;
                CLOSE c_key_from_spa;
        END IF;
        CLOSE c_oldest_term;
END IF;
CLOSE c_key_from_prev_term;
OPEN c_key_in_same_acad(l_acad_cal_type);
FETCH c_key_in_same_acad INTO l_dummy;
IF c_key_in_same_acad%NOTFOUND THEN
     return NULL;
ELSE
        return l_program_cd;
END IF;
END find_key_effective_for;

PROCEDURE get_effective_attribute_values(p_person_id IN NUMBER,
                        p_program_cd IN VARCHAR2,
                        p_term_cal_type IN VARCHAR2,
                        p_term_sequence_number IN NUMBER, p_term_rec OUT NOCOPY EN_SPAT_REC_TYPE%TYPE) AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT * from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.*
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = P_TERM_CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = P_TERM_SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT person_id,
       course_cd,
       version_number,
       cal_type,
       key_program,
       location_cd,
       attendance_mode,
       attendance_type,
       fee_cat,
       coo_id,
       IGS_PR_CLASS_STD_ID
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_program_cd IGS_PS_VER.COURSE_CD%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO p_term_rec;
    IF (c_term%FOUND) THEN
        CLOSE c_term;
        p_term_rec.person_id := p_person_id;
        p_term_rec.program_cd := p_program_cd;
        p_term_rec.term_cal_type := p_term_cal_type;
        p_term_rec.term_sequence_number := p_term_sequence_number;
        RETURN;
     ELSE
        CLOSE c_term;
     END IF;


     OPEN c_prev_term;
     FETCH c_prev_term INTO p_term_rec;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        p_term_rec.person_id := p_person_id;
        p_term_rec.program_cd := p_program_cd;
        p_term_rec.term_cal_type := p_term_cal_type;
        p_term_rec.term_sequence_number := p_term_sequence_number;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO p_term_rec.person_id,
                 p_term_rec.program_cd,
                 p_term_rec.program_version,
                 p_term_Rec.acad_cal_type,
                 p_term_rec.key_program_flag,
                 p_term_rec.location_cd,
                 p_term_rec.attendance_mode,
                 p_term_rec.attendance_type,
                 p_term_rec.fee_cat,
                 p_term_rec.coo_id,
                 p_term_rec.class_standing_id;

          p_term_rec.person_id := p_person_id;
          p_term_rec.program_cd := p_program_cd;
          p_term_rec.term_cal_type := p_term_cal_type;
          p_term_rec.term_sequence_number := p_term_sequence_number;
          CLOSE c_spa;
       END IF;
       l_program_cd := find_key_effective_for(
                p_person_id => p_person_id,
                p_term_cal_type => p_term_cal_type,
                p_term_sequence_number => p_term_sequence_number);
       IF l_program_cd = p_program_cd THEN
           p_term_rec.key_program_flag := 'Y';
       ELSE
           p_term_rec.key_program_flag := 'N';
       END IF;

END get_effective_attribute_values;

PROCEDURE set_param_attributes
(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_number IN NUMBER,
p_coo_id IN NUMBER,
p_key_program_flag IN VARCHAR2,
p_fee_cat IN VARCHAR2,
p_class_standing_id IN NUMBER,
p_plan_sht_status IN VARCHAR2,
p_old_term_rec IN EN_SPAT_REC_TYPE%TYPE,
p_new_term_rec IN OUT NOCOPY  EN_SPAT_REC_TYPE%TYPE,
p_program_changed IN BOOLEAN
)  AS
/*   p_old_term_rec is input record
     p_new_term_rec is the output record
     - Set the changed attributes in p_new_term_rec
     - All attributes which are not changing, use the values in p_old_term_rec
*/
CURSOR c_prg_attributes IS
SELECT  version_number,
        location_cd,
        attendance_type,
        attendance_mode,
        cal_type
FROM    igs_ps_ofr_opt
WHERE coo_id = p_coo_id;
BEGIN

        p_new_term_rec := p_old_term_rec;
        IF p_program_changed THEN
            p_new_term_rec := NULL;
            get_effective_attribute_values (
                        p_person_id => p_person_id,
                        p_program_cd => p_program_cd,
                        p_term_cal_type => p_term_cal_type,
                        p_term_sequence_number => p_term_sequence_number,
                        p_term_rec => p_new_term_rec);

            p_new_term_rec.term_cal_type := p_term_cal_type;
            p_new_term_rec.term_sequence_number := p_term_sequence_number;
        END IF;

        IF (p_coo_id <> -1) THEN
                p_new_term_rec.coo_id := p_coo_id;
                OPEN c_prg_attributes;
                FETCH c_prg_attributes INTO p_new_term_rec.program_version,
                                            p_new_term_rec.location_cd,
                                            p_new_term_rec.attendance_type,
                                            p_new_term_rec.attendance_mode,
                                            p_new_term_rec.acad_cal_type;
                CLOSE c_prg_attributes;

        END IF;
        IF (p_key_program_flag <> FND_API.G_MISS_CHAR) THEN
                p_new_term_rec.key_program_flag := p_key_program_flag;
        END IF;
        IF (p_fee_cat = FND_API.G_MISS_CHAR) THEN
          null;
        ELSE
                p_new_term_rec.fee_cat := p_fee_cat;
        END IF;
        IF (p_class_standing_id = -1) THEN
            NULL;
        ELSE
                p_new_term_rec.class_standing_id := p_class_standing_id;
        END IF;
        IF (p_plan_sht_status = FND_API.G_MISS_CHAR) THEN
            null;
        ELSE
                p_new_term_rec.plan_sht_status := p_plan_sht_status;
        END IF;

END set_param_attributes;


PROCEDURE find_and_create_key_record(p_person_id IN NUMBER, p_term_cal_type IN VARCHAR2,p_term_sequence_number IN NUMBER) AS
l_key_program VARCHAR2(100);
l_message_name varchar2(2000);
BEGIN
    l_key_program := find_key_effective_for(p_person_id, p_term_cal_type, p_term_sequence_number);
    IF l_key_program IS NOT NULL THEN
        create_update_term_rec(  -- can it be check_and_create
            p_person_id => p_person_id,
            p_program_cd => l_key_program,
            p_term_cal_type => p_term_cal_type,
            p_term_sequence_number => p_term_sequence_number,
            p_ripple_frwrd => FALSE,
            p_update_rec => FALSE,
            p_message_name => l_message_name);
    END IF;
END;
PROCEDURE check_term_exists(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_program_version IN NUMBER,
p_term_cal_type IN VARCHAR2,
p_term_sequence_number IN NUMBER,
p_insert_rec OUT NOCOPY BOOLEAN,
p_term_record_id OUT NOCOPY NUMBER) AS
/* -----------------------------------------------------------------------
   Created By        : Susmitha Tutta
   Date Created By   : 16-Mar-2004
   Purpose           : Checks whether a term record exists and returns
                      term_record_id and p_insert_rec = FALSE if exists.
                      If term doesn't exist returns p_insert_rec = TRUE.

   Change History
   Who         When        What
   ----------------------------------------------------------------------*/

vc_career_model_enabled VARCHAR2(1);
CURSOR c_term_rec_exists(cp_person_id IGS_PE_PERSON.person_id%TYPE,
                     cp_program_cd IGS_PS_VER.course_cd%TYPE,
                     cp_program_version IGS_PS_VER.version_number%TYPE,
                     cp_term_cal_type IGS_CA_INST.cal_type%TYPE,
                     cp_term_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
SELECT spat.term_record_id
       FROM IGS_EN_SPA_TERMS spat, igs_ps_ver cv1
       WHERE spat.person_id = cp_person_id
       AND   spat.term_cal_type = cp_term_cal_type
       AND   spat.term_sequence_number = cp_term_sequence_number
       AND   cv1.course_cd = spat.program_cd
       AND   cv1.version_number = spat.program_version
       AND
       (    (
                 NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y'
                 AND  cv1.course_type = (SELECT cv2.course_type
                               FROM IGS_PS_VER cv2
                               WHERE cv2.course_cd      = cp_program_cd
                               AND   cv2.version_number = cp_program_version)
            )
            OR
            (   NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N'
                AND spat.program_cd = cp_program_cd
            )
       );

vr_term_rec c_term_rec_exists%ROWTYPE;
BEGIN

   p_insert_rec := TRUE;

  OPEN c_term_rec_exists (p_person_id,
                          p_program_cd,
                          p_program_version,
                          p_term_cal_type,
                          p_term_sequence_number) ;
  -- fetch term record details
  FETCH c_term_rec_exists INTO vr_term_rec;
   -- if term record details are found for passed parameters
   -- new term record need not be created
   IF c_term_rec_exists%FOUND THEN
            -- set flag to indicate that no insert be allowed
            p_insert_rec := FALSE;
            -- retrieve rowid for the term record to be updated
            p_term_record_id := vr_term_rec.term_record_id;
   END IF;
   CLOSE c_term_rec_exists;

END check_term_exists;

PROCEDURE check_and_create(
p_term_rec IN EN_SPAT_REC_TYPE%TYPE,
p_update_rec  IN BOOLEAN DEFAULT FALSE,
p_program_changed IN BOOLEAN DEFAULT FALSE
) AS
    vc_row_id VARCHAR2(25);

    -- flag to indicate whether term record details should be inserted or not
    -- defailt TRUE
    v_insert_rec BOOLEAN;

    l_rowid VARCHAR2(25);
    l_term_record_id IGS_EN_SPA_TERMS.TERM_RECORD_ID%TYPE;


    -- cursor to fetch rowid for given term record details
    -- used in updating an existing term record
    Cursor cur_spat (cp_term_record_id IN NUMBER) IS
    SELECT spat.rowid, spat.program_cd, spat.acad_cal_type
    FROM IGS_EN_SPA_TERMS spat
    WHERE spat.term_record_id = cp_term_record_id;

    vc_cur_spat_rec cur_spat%ROWTYPE;
    CURSOR c_check_planning_sheet (p_person_id        IGS_EN_PLAN_UNITS.PERSON_ID%TYPE,
                                   p_course_cd        IGS_EN_PLAN_UNITS.COURSE_CD%TYPE,
                                   p_term_cal_type    IGS_EN_PLAN_UNITS.TERM_CAL_TYPE%TYPE,
                                   p_term_ci_sequence IGS_EN_PLAN_UNITS.TERM_CI_SEQUENCE_NUMBER%TYPE
                                    ) IS
           SELECT person_id
           FROM   IGS_EN_PLAN_UNITS
           WHERE  person_id               = p_person_id
           AND    course_cd               = p_course_cd
           AND    term_cal_type           = p_term_cal_type
           AND    term_ci_sequence_number = p_term_ci_sequence
           AND    cart_error_flag         = 'N';

    v_planning_sheet_rec c_check_planning_sheet%ROWTYPE;
    l_plan_sht_status      IGS_EN_SPA_TERMS.PLAN_SHT_STATUS%TYPE;
BEGIN

  OPEN c_term_exists (p_term_rec.person_id,p_term_rec.program_cd,
       p_term_rec.program_version,p_term_rec.term_cal_type,
       p_term_rec.term_sequence_number);
  FETCH c_term_exists INTO l_term_record_id;
  IF (c_term_exists%NOTFOUND) THEN
    v_insert_rec := TRUE;
  ELSE
    v_insert_rec := FALSE;
  END IF;
  CLOSE c_term_exists;

  IF v_insert_rec=TRUE THEN


    -- call table handler to insert new term record details
    l_term_record_id := NULL;
    l_rowid := NULL;

    IGS_EN_SPA_TERMS_PKG.insert_row(
        x_rowid                => l_rowid,
        x_term_record_id       => l_term_record_id,
        x_person_id            => p_term_rec.person_id,
        x_program_cd           => p_term_rec.program_cd,
        x_program_version      => p_term_rec.program_version,
        x_acad_cal_type        => p_term_rec.acad_cal_type,
        x_term_cal_type        => p_term_rec.term_cal_type,
        x_term_sequence_number => p_term_rec.term_sequence_number,
        x_key_program_flag     => p_term_rec.key_program_flag,
        x_location_cd          => p_term_rec.location_cd,
        x_attendance_mode      => p_term_rec.attendance_mode,
        x_attendance_type      => p_term_rec.attendance_type,
        x_fee_cat              => p_term_rec.fee_cat,
        x_coo_id               => p_term_rec.coo_id,
        x_class_standing_id    => p_term_rec.class_standing_id,
        x_attribute_category   => null,
        x_attribute1           => null,
        x_attribute2           => null,
        x_attribute3           => null,
        x_attribute4           => null,
        x_attribute5           => null,
        x_attribute6           => null,
        x_attribute7           => null,
        x_attribute8           => null,
        x_attribute9           => null,
        x_attribute10          => null,
        x_attribute11          => null,
        x_attribute12          => null,
        x_attribute13          => null,
        x_attribute14          => null,
        x_attribute15          => null,
        x_attribute16          => null,
        x_attribute17          => null,
        x_attribute18          => null,
        x_attribute19          => null,
        x_attribute20          => null,
        x_mode                 => 'R',
        x_plan_sht_status      => NVL(p_term_rec.plan_sht_status, 'NONE')
      );


   -- if update flag is set to TRUE
   ELSIF p_update_rec=TRUE THEN

-- in career mode, check if the primary program is changing,
-- in case the primary program is chaning then change the program code
-- and other related parameters as well in the term records.
-- If the primary program is not changing in the current updated
-- then do not ripple forward the changes to other programs in the
-- same career.
-- After the program transfer build, the only place from where
-- the primary program can be switched in the program transfer
-- page. Hence we check if the call to the term API was initialized
-- from the page/program transfer API. in that case the program
-- code would be rippled forward otherwise it wont.
-- To identify if the call has be initialized from the program transfer
-- the logic would use a global variable.

    OPEN cur_spat(l_term_record_id);
    FETCH cur_spat INTO vc_cur_spat_rec ;
    CLOSE cur_spat;

    l_plan_sht_status := p_term_rec.plan_sht_status;
    IF l_plan_sht_status IS NULL OR l_plan_sht_status = FND_API.G_MISS_CHAR THEN
      l_plan_sht_status := 'NONE';
    END IF;
    IF (p_program_changed OR p_term_rec.acad_cal_type <> vc_cur_spat_rec.acad_cal_type ) THEN
        --check for planning sheet exist.
        OPEN c_check_planning_sheet(p_term_rec.person_id, p_term_rec.program_cd,
                p_term_rec.term_cal_type,p_term_rec.term_sequence_number);
        FETCH c_check_planning_sheet INTO v_planning_sheet_rec;
        IF c_check_planning_sheet%FOUND THEN
           l_plan_sht_status := 'SKIP';
        END IF;
        CLOSE c_check_planning_sheet;
   END IF;


   -- if rowid for term record was found
   -- term record details exist and will be updated
    -- call table handler to update term record details


    IGS_EN_SPA_TERMS_PKG.update_row(
        x_rowid                => vc_cur_spat_rec.rowid,
        x_term_record_id       => p_term_rec.term_record_id,
        x_person_id            => p_term_rec.person_id,
        x_program_cd           => p_term_rec.program_cd,
        x_program_version      => p_term_rec.program_version,
        x_acad_cal_type        => p_term_rec.acad_cal_type,
        x_term_cal_type        => p_term_rec.term_cal_type,
        x_term_sequence_number => p_term_rec.term_sequence_number,
        x_key_program_flag     => p_term_rec.key_program_flag,
        x_location_cd          => p_term_rec.location_cd,
        x_attendance_mode      => p_term_rec.attendance_mode,
        x_attendance_type      => p_term_rec.attendance_type,
        x_fee_cat              => p_term_rec.fee_cat,
        x_coo_id               => p_term_rec.coo_id,
        x_class_standing_id    => p_term_rec.class_standing_id,
        x_attribute_category   => p_term_rec.attribute_category,
        x_attribute1           => p_term_rec.attribute1,
        x_attribute2           => p_term_rec.attribute2,
        x_attribute3           => p_term_rec.attribute3,
        x_attribute4           => p_term_rec.attribute4,
        x_attribute5           => p_term_rec.attribute5,
        x_attribute6           => p_term_rec.attribute6,
        x_attribute7           => p_term_rec.attribute7,
        x_attribute8           => p_term_rec.attribute8,
        x_attribute9           => p_term_rec.attribute9,
        x_attribute10          => p_term_rec.attribute10,
        x_attribute11          => p_term_rec.attribute11,
        x_attribute12          => p_term_rec.attribute12,
        x_attribute13          => p_term_rec.attribute13,
        x_attribute14          => p_term_rec.attribute14,
        x_attribute15          => p_term_rec.attribute15,
        x_attribute16          => p_term_rec.attribute16,
        x_attribute17          => p_term_rec.attribute17,
        x_attribute18          => p_term_rec.attribute18,
        x_attribute19          => p_term_rec.attribute19,
        x_attribute20          => p_term_rec.attribute20,
        x_mode                 => 'R',
        x_plan_sht_status      => l_plan_sht_status
      );

  END IF;

END check_and_create;



PROCEDURE ripple_frwd
(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_number IN NUMBER,
p_coo_id IN NUMBER,
p_fee_cat IN VARCHAR2,
p_class_standing_id IN NUMBER,
p_term_rec IN EN_SPAT_REC_TYPE%TYPE,
p_program_changed IN BOOLEAN
)  AS
--## PROCEDURE DESCRIPTION:
--## the attribute values for the effective term are mirrored onto the
--## the future term records (that exist in the term records table and
--## are in future to the effective term).

      -- cursor to fetch term records occuring in future
    CURSOR c_future_terms (cp_chk_othr_prms VARCHAR2,
                        cp_program_version NUMBER,
                        cp_acad_cal_type igs_ca_inst.cal_type%TYPE) IS
    SELECT spat.*
    FROM IGS_EN_SPA_TERMS spat,
         IGS_CA_INST_REL cr,
         IGS_CA_INST_REL cr2,
         IGS_CA_INST ci,
         IGS_PS_VER cv
    WHERE cr.sup_cal_type            = cp_acad_cal_type
    AND   cr.sub_cal_type            = p_term_cal_type
    AND   cr.sub_ci_sequence_number  = p_term_sequence_number
    AND   cr.sup_cal_type            = cr2.sup_cal_type
    AND   cr2.sub_cal_type           = spat.term_cal_type
    AND   cr2.sub_ci_sequence_number = spat.term_sequence_number
    AND   spat.person_id             = p_person_id
    AND   ci.cal_type                = cr2.sub_cal_type
    AND   ci.sequence_number         = cr2.sub_ci_sequence_number
    AND   exists (SELECT 'x'
                  FROM   IGS_CA_INST cii
                  WHERE  cal_type = p_term_cal_type
                  AND    sequence_number = p_term_sequence_number
                  AND ci.start_dt >= cii.start_dt)
    AND   ci.sequence_number         <> p_term_sequence_number
    AND   cv.course_cd               = spat.program_cd
    AND   cv.version_number          = spat.program_version
    AND (
         (
             cp_chk_othr_prms = 'Y' AND
             cv.course_type = (SELECT course_type
                                FROM IGS_PS_VER cv2
                                WHERE cv2.course_cd      = p_program_cd
                                AND   cv2.version_number = cp_program_version)
          )
    OR
    ( cp_chk_othr_prms <> 'Y'  AND  spat.program_cd = p_program_cd));


    vc_career_model_enabled VARCHAR2(1);
    vd_start_dt IGS_CA_INST.START_DT%TYPE;
    v_program_changed BOOLEAN;
    v_check_othr_prgms VARCHAR2(1);
    v_changed_term_rec EN_SPAT_REC_TYPE%TYPE;
BEGIN

 -- check if Career Model is enabled for the System and if called from program transfer
 IF (p_program_changed AND NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N') = 'Y' ) THEN
    v_check_othr_prgms := 'Y';
 ELSE
    v_check_othr_prgms := 'N';
 END IF;
  -- Select all the term records for the passed in person id,
  -- term calendar and academic calendar either in the same program (in program mode)
  -- or in the same career (in the career mode)
  FOR vr_future_term_rec
   IN c_future_terms
        (v_check_othr_prgms,
         p_term_rec.program_version,
         p_term_rec.acad_cal_type) LOOP

        IF (NOT p_program_changed AND vr_future_term_rec.program_cd <> p_term_rec.program_cd ) THEN
                null;
        ELSE

              set_param_attributes(
                             p_person_id  => p_person_id,
                             p_program_cd => p_program_cd,
                             p_term_cal_type => vr_future_term_rec.term_cal_type,
                             p_term_sequence_number => vr_future_term_rec.term_sequence_number,
                             p_coo_id => p_coo_id,
                             p_key_program_flag => FND_API.G_MISS_CHAR,
                             p_fee_cat => p_fee_cat,
                             p_class_standing_id => p_class_standing_id,
                             p_plan_sht_status => FND_API.G_MISS_CHAR,
                             p_old_term_rec => vr_future_term_rec,
                             p_new_term_rec => v_changed_term_rec,
                             p_program_changed => p_program_changed);

                CHECK_AND_CREATE(
                          p_term_rec => v_changed_term_rec,
                          p_update_rec            => TRUE,
                          p_program_changed => p_program_changed);
        END IF;

  END LOOP;

END ripple_frwd;


PROCEDURE backward_gap_fill
(
p_term_rec IN EN_SPAT_REC_TYPE%TYPE
) AS
    TYPE t_ref_cur IS REF CURSOR;
    c_backward_gap_exists t_ref_cur;

    v_backward_gap_exists_stmt VARCHAR2 (4000);

    v_context_cal_type        IGS_CA_INST.CAL_TYPE%TYPE;
    v_context_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    v_next_cal_type           IGS_CA_INST.CAL_TYPE%TYPE;
    v_next_sequence_number    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;

    v_person_id               IGS_EN_SPA_TERMS.PERSON_ID%TYPE;
    v_program_cd              IGS_EN_SPA_TERMS.PROGRAM_CD%TYPE;
    v_program_version         IGS_EN_SPA_TERMS.PROGRAM_VERSION%TYPE;
    v_coo_id                  IGS_EN_SPA_TERMS.COO_ID%TYPE;
    v_acad_cal_type           IGS_EN_SPA_TERMS.ACAD_CAL_TYPE%TYPE;
    v_key_program_flag        IGS_EN_SPA_TERMS.KEY_PROGRAM_FLAG%TYPE;
    v_location_cd             IGS_EN_SPA_TERMS.LOCATION_CD%TYPE;
    v_attendance_mode         IGS_EN_SPA_TERMS.ATTENDANCE_MODE%TYPE;
    v_attendance_type         IGS_EN_SPA_TERMS.ATTENDANCE_TYPE%TYPE;
    v_fee_cat                 IGS_EN_SPA_TERMS.FEE_CAT%TYPE;
    v_class_standing_id       IGS_EN_SPA_TERMS.CLASS_STANDING_ID%TYPE;

    -- cursor to fetch backward term gaps
    CURSOR c_backward_gap(cp_context_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_context_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                          cp_next_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_next_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE)
        IS
        SELECT  ci.cal_type, ci.sequence_number, ci.start_dt,
                ci.alternate_code, ci.description
        FROM igs_ca_inst ci,
            igs_ca_inst endterm,
            igs_ca_inst beginterm,
            igs_ca_type ct,
            igs_ca_stat cs,
            igs_ca_inst_rel cr,
            igs_ca_inst_rel cr2,
            igs_ca_type ct2
        WHERE ci.cal_type               = cr.sub_cal_type
        AND   ci.sequence_number        = cr.sub_ci_sequence_number
        AND   cr.sup_cal_type           = ct2.cal_type
        AND   ct2.s_cal_cat             = 'ACADEMIC'
        AND   cr.sup_cal_type           = cr2.sup_cal_type
        AND   beginterm.cal_type        = cr2.sub_cal_type
        AND   beginterm.sequence_number = cr2.sub_ci_sequence_number
        AND   ci.start_dt               >= beginterm.start_dt
        AND   ci.start_dt               < endterm.start_dt
        AND   endterm.cal_type          = cp_next_cal_type
        AND   endterm.sequence_number   = cp_next_sequence_number
        AND   beginterm.cal_type        = cp_context_cal_type
        AND   beginterm.sequence_number = cp_context_sequence_number
        AND   ci.sequence_number        <> endterm.sequence_number
        AND   ci.sequence_number        <> beginterm.sequence_number
        AND   ct.cal_type               = ci.cal_type
        AND   ct.s_cal_cat              = 'LOAD'
        AND   cs.cal_status             = ci.cal_status
        AND   cs.s_cal_status           =  'ACTIVE'
        ORDER BY ci.start_dt ASC;

    -- checks if a term record exists in the same term for the given person
    -- and academic calendar
    v_term_rec EN_SPAT_REC_TYPE%TYPE;
     vc_career_model_enabled varchar2(1);
BEGIN
   -- fetch if Career Model is enabled for the System or not
   vc_career_model_enabled := nvl(fnd_profile.value('CAREER_MODEL_ENABLED'),'N');
    v_term_rec := p_term_rec;
   -- if Career Model is enabled
   -- if Career Model is enabled
   IF vc_career_model_enabled = 'Y' THEN

       -- set query statement to fetch any backward gap terms
       v_backward_gap_exists_stmt := 'SELECT CI2.CAL_TYPE,
                                         CI2.SEQUENCE_NUMBER,
                                         CI.CAL_TYPE,
                                         CI.SEQUENCE_NUMBER,
                                         SPT.PERSON_ID,
                                         SPT.PROGRAM_CD,
                                         SPT.PROGRAM_VERSION,
                                         SPT.COO_ID,
                                         SPT.ACAD_CAL_TYPE,
                                         SPT.KEY_PROGRAM_FLAG,
                                         SPT.LOCATION_CD,
                                         SPT.ATTENDANCE_MODE,
                                         SPT.ATTENDANCE_TYPE,
                                         SPT.FEE_CAT,
                                         SPT.CLASS_STANDING_ID
                                  FROM IGS_EN_SPA_TERMS SPT,
                                       IGS_PS_VER CV,
                                       IGS_CA_INST CI,
                                       IGS_CA_INST CI2
                                  WHERE SPT.PERSON_ID = :1
                                  AND   SPT.PROGRAM_CD = CV.COURSE_CD
                                  AND   SPT.PROGRAM_VERSION = CV.VERSION_NUMBER
                                  AND   CV.COURSE_TYPE IN (SELECT CV2.COURSE_TYPE
                                                           FROM IGS_PS_VER CV2
                                                           WHERE CV2.COURSE_CD = :2
                                                           AND CV2.VERSION_NUMBER = :3)
                                  AND   CI2.CAL_TYPE = SPT.TERM_CAL_TYPE
                                  AND   CI2.SEQUENCE_NUMBER = SPT.TERM_SEQUENCE_NUMBER
                                  AND   CI.CAL_TYPE = :4
                                  AND   CI.SEQUENCE_NUMBER = :5
                                  AND   SPT.ACAD_CAL_TYPE = :6
                                  AND   CI2.START_DT < CI.START_DT
                                  AND   CI2.SEQUENCE_NUMBER <> CI.SEQUENCE_NUMBER
                                  ORDER BY CI2.START_DT DESC';

    -- open cursor to fetch backward gap terms
      OPEN c_backward_gap_exists FOR v_backward_gap_exists_stmt
      USING p_term_rec.person_id,
            p_term_rec.program_cd,
            p_term_rec.program_version,
            p_term_rec.term_cal_type,
            p_term_rec.term_sequence_number,
            p_term_rec.acad_cal_type;

  ELSE   -- if career model is not enabled
    -- set query statement to fetch any backward gap terms
    v_backward_gap_exists_stmt := 'SELECT CI2.CAL_TYPE,
                                         CI2.SEQUENCE_NUMBER,
                                         CI.CAL_TYPE,
                                         CI.SEQUENCE_NUMBER,
                                         SPT.PERSON_ID,
                                         SPT.PROGRAM_CD,
                                         SPT.PROGRAM_VERSION,
                                         SPT.COO_ID,
                                         SPT.ACAD_CAL_TYPE,
                                         SPT.KEY_PROGRAM_FLAG,
                                         SPT.LOCATION_CD,
                                         SPT.ATTENDANCE_MODE,
                                         SPT.ATTENDANCE_TYPE,
                                         SPT.FEE_CAT,
                                         SPT.CLASS_STANDING_ID
                                  FROM IGS_EN_SPA_TERMS SPT,
                                       IGS_CA_INST CI,
                                       IGS_CA_INST CI2
                                  WHERE SPT.PERSON_ID = :1
                                  AND   SPT.PROGRAM_CD = :2
                                  AND   CI2.CAL_TYPE = SPT.TERM_CAL_TYPE
                                  AND   CI2.SEQUENCE_NUMBER = SPT.TERM_SEQUENCE_NUMBER
                                  AND   CI.CAL_TYPE = :3
                                  AND   CI.SEQUENCE_NUMBER = :4
                                  AND   SPT.ACAD_CAL_TYPE = :6
                                  AND   CI2.START_DT < CI.START_DT
                                  AND   CI2.SEQUENCE_NUMBER <> CI.SEQUENCE_NUMBER
                                  ORDER BY CI2.START_DT DESC';
      -- open cursor to fetch backward gap terms
      OPEN c_backward_gap_exists FOR v_backward_gap_exists_stmt
      USING p_term_rec.person_id,
            p_term_rec.program_cd,
            p_term_rec.term_cal_type,
            p_term_rec.term_sequence_number,
            p_term_rec.acad_cal_type;

 END IF;

  --fetch backward gap terms
  FETCH c_backward_gap_exists INTO v_context_cal_type,
                                   v_context_sequence_number,
                                   v_next_cal_type,
                                   v_next_sequence_number,
                                   v_term_rec.person_id,
                                   v_term_rec.program_cd,
                                   v_term_rec.program_version,
                                   v_term_rec.coo_id,
                                   v_term_rec.acad_cal_type,
                                   v_term_rec.key_program_flag,
                                   v_term_rec.location_cd,
                                   v_term_rec.attendance_mode,
                                   v_term_rec.attendance_type,
                                   v_term_rec.fee_cat,
                                   v_term_rec.class_standing_id;

  -- if no backward term gaps exist
  IF c_backward_gap_exists%NOTFOUND THEN
    CLOSE c_backward_gap_exists;
    RETURN;

  -- if backward term gaps exist
  ELSE
    CLOSE c_backward_gap_exists;
  END IF;

  -- fetch backward gap term records
  FOR vr_backward_gap_rec IN c_backward_gap(v_context_cal_type,
                                          v_context_sequence_number,
                                          v_next_cal_type,
                                          v_next_sequence_number) LOOP
      v_term_rec.term_cal_type := vr_backward_gap_rec.cal_type;
      v_term_rec.term_sequence_number := vr_backward_gap_rec.sequence_number;
      v_term_rec.plan_sht_status := 'NONE';
      IF (v_term_rec.program_cd = find_key_effective_for(v_term_rec.person_id,
                                                         vr_backward_gap_rec.cal_type,
                                                         vr_backward_gap_rec.sequence_number)) THEN

                v_term_rec.key_program_flag := 'Y';
          ELSE

        v_term_rec.key_program_flag := 'N';
          END IF;

          check_and_create(
                        p_term_rec              => v_term_rec,
                        p_update_rec    => FALSE);

  END LOOP;

END backward_gap_fill;

PROCEDURE forward_gap_fill
(
p_term_rec IN EN_SPAT_REC_TYPE%TYPE
)
AS
 /* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Checks if any term future or forward gaps exists,
                       and updates them if necessary.

   Change History
   Who         When        What
  stutta   31-Dec-2004   Modified c_forward_gap to pickup only records whose
                         start date is < the next calendar( not <= next calendar)
                         This is to avoid the same calendar being consider a
                         future and past calendar.
  ----------------------------------------------------------------------*/
    TYPE t_ref_cur IS REF CURSOR;
    c_forward_gap_exists t_ref_cur;

    v_forward_gap_exists_stmt VARCHAR2(4000);

    vc_curr_cal_type        IGS_CA_INST.CAL_TYPE%TYPE;
    vn_curr_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    vc_next_cal_type           IGS_CA_INST.CAL_TYPE%TYPE;
    vn_next_sequence_number    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;

    vn_person_id               IGS_EN_SPA_TERMS.PERSON_ID%TYPE;
    vc_program_cd              IGS_EN_SPA_TERMS.PROGRAM_CD%TYPE;
    vn_program_version         IGS_EN_SPA_TERMS.PROGRAM_VERSION%TYPE;
    vn_coo_id                  IGS_EN_SPA_TERMS.COO_ID%TYPE;
    vc_acad_cal_type           IGS_EN_SPA_TERMS.ACAD_CAL_TYPE%TYPE;
    vc_key_program_flag        IGS_EN_SPA_TERMS.KEY_PROGRAM_FLAG%TYPE;
    vc_location_cd             IGS_EN_SPA_TERMS.LOCATION_CD%TYPE;
    vc_attendance_mode         IGS_EN_SPA_TERMS.ATTENDANCE_MODE%TYPE;
    vc_attendance_type         IGS_EN_SPA_TERMS.ATTENDANCE_TYPE%TYPE;
    vc_fee_cat                 IGS_EN_SPA_TERMS.FEE_CAT%TYPE;
    vc_class_standing_id          IGS_EN_SPA_TERMS.CLASS_STANDING_ID%TYPE;

    CURSOR c_forward_gap (cp_next_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_next_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                          cp_curr_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_curr_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE)
        IS
        SELECT ci.cal_type, ci.sequence_number,
               ci.start_dt, ci.alternate_code, ci.description
        FROM IGS_CA_INST ci,
             IGS_CA_INST ci2,
             IGS_CA_INST ci3,
             IGS_CA_TYPE ct,
             IGS_CA_STAT cs,
             IGS_CA_INST_REL cr,
             IGS_CA_INST_REL cr2,
             IGS_CA_TYPE ct2
        WHERE ci.cal_type          = cr.sub_cal_type
        AND   ci.sequence_number   = cr.sub_ci_sequence_number
        AND   cr.sup_cal_type      = ct2.cal_type
        AND   ct2.s_cal_cat        = 'ACADEMIC'
        AND   cr.sup_cal_type      = cr2.sup_cal_type
        AND   ci2.cal_type         = cr2.sub_cal_type
        AND   ci2.sequence_number  = cr2.sub_ci_sequence_number
        AND   ci.start_dt          < ci3.start_dt
        AND   ci.start_dt          >= ci2.start_dt
        AND   ci2.cal_type         = cp_curr_cal_type
        AND   ci2.sequence_number  = cp_curr_sequence_number
        AND   ci3.cal_type         = cp_next_cal_type
        AND   ci3.sequence_number  = cp_next_sequence_number
        AND   ci.sequence_number   <> ci2.sequence_number
        AND   ci.sequence_number   <> ci3.sequence_number
        AND   ct.cal_type          = ci.cal_type
        AND   ct.s_cal_cat         = 'LOAD'
        AND   cs.cal_status        = ci.cal_status
        AND   cs.s_cal_status      = 'ACTIVE'
        ORDER BY  ci.start_dt ASC;

    CURSOR c_other_recs ( cp_term_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                      cp_term_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                      cp_program_cd IGS_PS_VER.COURSE_CD%TYPE) IS
        SELECT *
        FROM  IGS_EN_SPA_TERMS
        WHERE person_id            = p_term_rec.person_id
        AND   program_cd           <> cp_program_cd
        AND   term_cal_type        = cp_term_cal_type
        AND   term_sequence_number = cp_term_sequence_number
        AND   acad_cal_type        = p_term_rec.acad_cal_type
        AND   key_program_flag     = 'Y';

    vc_career_model_enabled VARCHAR2(1);
    v_term_rec EN_SPAT_REC_TYPE%TYPE;

BEGIN

   -- fetch if Career Model is enabled for the System or not
   vc_career_model_enabled := NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N');

   -- if Career Model is enabled
  IF vc_career_model_enabled = 'Y' THEN

    -- set query statement to fetch term record
    v_forward_gap_exists_stmt := 'SELECT CI2.CAL_TYPE,
                                         CI2.SEQUENCE_NUMBER,
                                         CI.CAL_TYPE,
                                         CI.SEQUENCE_NUMBER
                                  FROM IGS_EN_SPA_TERMS SPT,
                                       IGS_PS_VER CV,
                                       IGS_CA_INST CI,
                                       IGS_CA_INST CI2
                                  WHERE SPT.PERSON_ID = :1
                                  AND   SPT.PROGRAM_CD = CV.COURSE_CD
                                  AND   SPT.PROGRAM_VERSION = CV.VERSION_NUMBER
                                  AND   CV.COURSE_TYPE IN (SELECT CV2.COURSE_TYPE
                                                           FROM IGS_PS_VER CV2
                                                           WHERE CV2.COURSE_CD = :2
                                                           AND CV2.VERSION_NUMBER = :3)
                                  AND   CI2.CAL_TYPE = SPT.TERM_CAL_TYPE
                                  AND   CI2.SEQUENCE_NUMBER = SPT.TERM_SEQUENCE_NUMBER
                                  AND   CI.CAL_TYPE = :4
                                  AND   CI.SEQUENCE_NUMBER = :5
                                  AND   SPT.ACAD_CAL_TYPE = :6
                                  AND   CI2.START_DT >= CI.START_DT
                                  AND   CI2.SEQUENCE_NUMBER <> CI.SEQUENCE_NUMBER
                                  ORDER BY CI2.START_DT ASC';

  -- if Career Model is not enabled
  ELSE
    -- set query statement to fetch term record
    v_forward_gap_exists_stmt := 'SELECT CI2.CAL_TYPE,
                                         CI2.SEQUENCE_NUMBER,
                                         CI.CAL_TYPE,
                                         CI.SEQUENCE_NUMBER
                                  FROM IGS_EN_SPA_TERMS SPT,
                                       IGS_CA_INST CI,
                                       IGS_CA_INST CI2
                                  WHERE SPT.PERSON_ID = :1
                                  AND   SPT.PROGRAM_CD = :2
                                  AND   CI2.CAL_TYPE = SPT.TERM_CAL_TYPE
                                  AND   CI2.SEQUENCE_NUMBER = SPT.TERM_SEQUENCE_NUMBER
                                  AND   CI.CAL_TYPE = :3
                                  AND   CI.SEQUENCE_NUMBER = :4
                                  AND   SPT.ACAD_CAL_TYPE = :5
                                  AND   CI2.START_DT >= CI.START_DT
                                  AND   CI2.SEQUENCE_NUMBER <> CI.SEQUENCE_NUMBER
                                  ORDER BY CI2.START_DT ASC';
   END IF;

   IF vc_career_model_enabled = 'Y' THEN
   -- fetch term record details
    OPEN c_forward_gap_exists FOR v_forward_gap_exists_stmt
     USING  p_term_rec.person_id,
            p_term_rec.program_cd,
            p_term_rec.program_version,
            p_term_rec.term_cal_type,
            p_term_rec.term_sequence_number,
            p_term_rec.acad_cal_type;
    ELSE
        OPEN c_forward_gap_exists FOR v_forward_gap_exists_stmt
         USING  p_term_rec.person_id,
                p_term_rec.program_cd,
                p_term_rec.term_cal_type,
                p_term_rec.term_sequence_number,
                p_term_rec.acad_cal_type;
   END IF;
   FETCH c_forward_gap_exists INTO vc_next_cal_type,
                                   vn_next_sequence_number,
                                   vc_curr_cal_type,
                                   vn_curr_sequence_number;

  -- if term record was not found
  IF c_forward_gap_exists%NOTFOUND THEN
    CLOSE c_forward_gap_exists;
    RETURN;

  -- if term record was found
  ELSE
    CLOSE c_forward_gap_exists;
  END IF;

    v_term_rec := p_term_rec;
    -- fetch forward calendars
    FOR vr_forward_gap_rec IN c_forward_gap(vc_next_cal_type,
                                            vn_next_sequence_number,
                                            vc_curr_cal_type,
                                            vn_curr_sequence_number) LOOP
    v_term_rec.term_cal_type :=vr_forward_gap_rec.cal_type;
    v_term_rec.term_sequence_number :=vr_forward_gap_rec.sequence_number;
    v_term_rec.plan_sht_status := 'NONE';

        IF (v_term_rec.program_cd = find_key_effective_for(v_term_rec.person_id,
                                                       vc_curr_cal_type,
                                                       vn_curr_sequence_number)) THEN
                v_term_rec.key_program_flag := 'Y';
    ELSE
        v_term_rec.key_program_flag := 'N';
    END IF;

    -- create term record for future term
    check_and_create(
          p_term_rec     => v_term_rec,
          p_update_rec   => TRUE);

  END LOOP;

END forward_gap_fill;





PROCEDURE create_update_term_rec(
p_person_id IN NUMBER ,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER,
p_ripple_frwrd IN boolean,
p_update_rec IN BOOLEAN,
p_message_name OUT NOCOPY VARCHAR2,
p_coo_id IN NUMBER DEFAULT -1,
p_key_program_flag IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_fee_cat IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_class_standing_id IN NUMBER DEFAULT -1,
p_plan_sht_status IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
p_program_changed IN BOOLEAN DEFAULT FALSE
)
AS
cursor c_valid_term IS
SELECT 'x' FROM IGS_CA_INST ca, IGS_CA_TYPE ct
WHERE ca.cal_type = p_term_cal_type
AND   ca.sequence_number = p_term_sequence_number
AND ca.cal_type = ct.cal_type
and ct.s_cal_cat = 'LOAD';


l_dummy VARCHAR2(1);
l_term_id IGS_EN_SPA_TERMS.term_record_id%TYPE;
l_insert_rec BOOLEAN;
new_term_rec EN_SPAT_REC_TYPE%TYPE;
old_term_rec EN_SPAT_REC_TYPE%TYPE;
l_username VARCHAR2(20);


BEGIN

    -- ## Checking whether term instance is a valid value.
        IF (p_term_cal_type IS NULL OR p_term_sequence_number IS NULL) THEN

          p_message_name := 'IGS_EN_INVALID_LOAD_CAL' ;
          FND_MESSAGE.SET_NAME('IGS',p_message_name);
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

    ELSE
      OPEN c_valid_term;
            FETCH c_valid_term INTO l_dummy;
        IF (c_valid_term%NOTFOUND) THEN
            p_message_name := 'IGS_EN_INVALID_LOAD_CAL' ;
            FND_MESSAGE.SET_NAME('IGS',p_message_name);
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
    END IF;


        -- Get the attribute values which are effective in the passed in term.
        -- It returns a record variable as out paramter which contains are effective attribute values.
        get_effective_attribute_values(p_person_id => p_person_id,
                                        p_program_cd => p_program_cd,
                                        p_term_cal_type => p_term_cal_type,
                                        p_term_sequence_number => p_term_sequence_number,
                                        p_term_rec => old_term_rec);


        set_param_attributes(
                             p_person_id  => p_person_id,
                             p_program_cd => p_program_cd,
                             p_term_cal_type => p_term_cal_type,
                             p_term_sequence_number => p_term_sequence_number,
                             p_coo_id => p_coo_id,
                             p_key_program_flag => p_key_program_flag,
                             p_fee_cat => p_fee_cat,
                             p_class_standing_id => p_class_standing_id,
                             p_plan_sht_status => p_plan_sht_status,
                             p_old_term_rec => old_term_rec,
                             p_new_term_rec => new_term_rec,
                             p_program_changed => p_program_changed);

        validate_term_rec(p_term_rec => new_term_rec);
        IF (p_ripple_frwrd) THEN
                ripple_frwd(
                p_person_id => p_person_id,
                p_program_cd => p_program_cd,
                p_coo_id =>p_coo_id ,
                p_term_cal_type => p_term_cal_type,
                p_term_sequence_number => p_term_sequence_number,
                p_fee_cat => p_fee_cat,
                p_class_standing_id => p_class_standing_id,
                p_term_rec => old_term_rec,
                p_program_changed => p_program_changed);
        END IF;

        OPEN c_term_exists (old_term_rec.person_id,old_term_rec.program_cd,
           old_term_rec.program_version,old_term_rec.term_cal_type,
           old_term_rec.term_sequence_number);
        FETCH c_term_exists INTO l_term_id;
        IF (c_term_exists%NOTFOUND) THEN
               l_insert_rec := TRUE;
        ELSE
               l_insert_rec := FALSE;
        END IF;
        CLOSE c_term_exists;
        -- All attributes whose values have been passed in for the call have changed.
        -- Hence set those attributes which have a value passed to create_update_term_Rec .


        IF l_insert_rec THEN

                backward_gap_fill(new_term_rec);

                check_and_create(p_term_rec => new_term_rec,
                                 p_update_rec  => TRUE,
                                 p_program_changed => p_program_changed);

                forward_gap_fill(new_term_rec);
        ELSE
                -- If the record already exists then no gaps need not be filled.
                -- Only update the term record with the changed values

                        check_and_create(p_term_rec => new_term_rec,
                                         p_update_rec  => TRUE,
                                 p_program_changed => p_program_changed);
        END IF;
        IF (p_key_program_flag = 'Y') THEN

                change_key_program_to(p_person_id,
                                        p_program_cd,
                                        p_term_cal_type,
                                        p_term_sequence_number, new_term_rec);
        END IF;



END create_update_term_rec;


PROCEDURE change_key_program_to(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER,
p_term_rec IN EN_SPAT_REC_TYPE%TYPE) AS

CURSOR c_future_key_terms IS
SELECT spat.rowid, spat.*
FROM igs_en_spa_terms spat, igs_ca_inst ca1, igs_ca_inst ca2
WHERE ca1.cal_type = spat.term_cal_type
AND   ca1.sequence_number = spat.term_sequence_number
AND       ca2.cal_type = p_term_cal_type
AND   ca2.sequence_number = p_term_sequence_number
AND   ca1.start_dt >= ca2.start_dt
and   spat.person_id = p_person_id
AND   spat.key_program_flag = 'Y';

CURSOR c_latest_term_in_acad IS  -- check if the latest term in acad is for this program
SELECT spat.rowid, spat.program_cd, term_cal_type, term_sequence_number
FROM   igs_en_spa_terms spat, igs_ca_inst ca, igs_ca_inst_rel cir
WHERE  spat.person_id = p_person_id
AND    ca.cal_type = spat.term_cal_type
AND    ca.sequence_number = spat.term_sequence_number
AND    cir.sub_cal_type = p_term_cal_type
AND    cir.sub_ci_sequence_number = p_term_sequence_number
AND    cir.sup_cal_type = spat.acad_cal_type
ORDER BY ca.start_dt DESC;

CURSOR c_dest_term IS
SELECT spat.rowid, spat.term_record_id
FROM   igs_en_spa_terms spat
WHERE person_id = p_person_id
AND   program_cd = p_program_cd
AND   term_cal_type = p_term_cal_type
AND   term_sequence_number = p_term_sequence_number;

CURSOR c_dest_fut_terms IS
SELECT spat.rowid,spat.*
    FROM IGS_EN_SPA_TERMS spat,
         IGS_CA_INST_REL cr,
         IGS_CA_INST_REL cr2,
         IGS_CA_INST ci,
         IGS_PS_VER cv
    WHERE cr.sub_cal_type            = p_term_cal_type
    AND   cr.sub_ci_sequence_number  = p_term_sequence_number
    AND   cr.sup_cal_type            = cr2.sup_cal_type
    AND   cr2.sub_cal_type           = spat.term_cal_type
    AND   cr2.sub_ci_sequence_number = spat.term_sequence_number
    AND   spat.person_id             = p_person_id
    AND   ci.cal_type                = cr2.sub_cal_type
    AND   ci.sequence_number         = cr2.sub_ci_sequence_number
    AND   ci.start_dt                >=
                 (SELECT start_dt
                  FROM   IGS_CA_INST
                  WHERE  cal_type = cr.sub_cal_type
                  AND    sequence_number = cr.sub_ci_sequence_number)
    AND   ci.sequence_number         <> p_term_sequence_number
    AND   cv.course_cd               = spat.program_cd
    AND   cv.version_number          = spat.program_version
    AND   spat.program_cd = p_program_cd;

l_term_cal IGS_CA_INST.CAL_TYPE%TYPE;
l_term_seq IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
l_message_name VARCHAR2(2000);
l_term_rec EN_SPAT_REC_TYPE%TYPE;
l_rowid ROWID;
l_term_id IGS_EN_SPA_TERMS.term_record_id%TYPE;
l_program_cd IGS_PS_VER.COURSE_CD%TYPE;

BEGIN
    l_term_rec := p_term_rec;
        -- Reset all future key term records as Non-Key
        FOR rec_future_key_terms IN c_future_key_terms LOOP

                IGS_EN_SPA_TERMS_PKG.update_row(
                        x_rowid                => rec_future_key_terms.rowid,
                        x_term_record_id       => rec_future_key_terms.term_record_id,
                        x_person_id            => rec_future_key_terms.person_id,
                        x_program_cd           => rec_future_key_terms.program_cd,
                        x_program_version      => rec_future_key_terms.program_version,
                        x_acad_cal_type        => rec_future_key_terms.acad_cal_type,
                        x_term_cal_type        => rec_future_key_terms.term_cal_type,
                        x_term_sequence_number => rec_future_key_terms.term_sequence_number,
                        x_key_program_flag     => 'N',
                        x_location_cd          => rec_future_key_terms.location_cd,
                        x_attendance_mode      => rec_future_key_terms.attendance_mode,
                        x_attendance_type      => rec_future_key_terms.attendance_type,
                        x_fee_cat              => rec_future_key_terms.fee_cat,
                        x_coo_id               => rec_future_key_terms.coo_id,
                        x_class_standing_id    => rec_future_key_terms.class_standing_id,
                        x_attribute_category   => rec_future_key_terms.attribute_category,
                        x_attribute1           => rec_future_key_terms.attribute1,
                        x_attribute2           => rec_future_key_terms.attribute2,
                        x_attribute3           => rec_future_key_terms.attribute3,
                        x_attribute4           => rec_future_key_terms.attribute4,
                        x_attribute5           => rec_future_key_terms.attribute5,
                        x_attribute6           => rec_future_key_terms.attribute6,
                        x_attribute7           => rec_future_key_terms.attribute7,
                        x_attribute8           => rec_future_key_terms.attribute8,
                        x_attribute9           => rec_future_key_terms.attribute9,
                        x_attribute10          => rec_future_key_terms.attribute10,
                        x_attribute11          => rec_future_key_terms.attribute11,
                        x_attribute12          => rec_future_key_terms.attribute12,
                        x_attribute13          => rec_future_key_terms.attribute13,
                        x_attribute14          => rec_future_key_terms.attribute14,
                        x_attribute15          => rec_future_key_terms.attribute15,
                        x_attribute16          => rec_future_key_terms.attribute16,
                        x_attribute17          => rec_future_key_terms.attribute17,
                        x_attribute18          => rec_future_key_terms.attribute18,
                        x_attribute19          => rec_future_key_terms.attribute19,
                        x_attribute20          => rec_future_key_terms.attribute20,
                        x_mode                 => 'R',
                        x_plan_sht_status      => rec_future_key_terms.plan_sht_status
                  );
        END LOOP;
        OPEN c_dest_term;
        FETCH c_dest_term INTO l_rowid, l_term_id;
        CLOSE c_dest_term;
        -- Update the destination term record as Key
        IGS_EN_SPA_TERMS_PKG.update_row(
                        x_rowid                => l_rowid,
                        x_term_record_id       => l_term_id,
                        x_person_id            => l_term_rec.person_id,
                        x_program_cd           => l_term_rec.program_cd,
                        x_program_version      => l_term_rec.program_version,
                        x_acad_cal_type        => l_term_rec.acad_cal_type,
                        x_term_cal_type        => l_term_rec.term_cal_type,
                        x_term_sequence_number => l_term_rec.term_sequence_number,
                        x_key_program_flag     => 'Y',
                        x_location_cd          => l_term_rec.location_cd,
                        x_attendance_mode      => l_term_rec.attendance_mode,
                        x_attendance_type      => l_term_rec.attendance_type,
                        x_fee_cat              => l_term_rec.fee_cat,
                        x_coo_id               => l_term_rec.coo_id,
                        x_class_standing_id    => l_term_rec.class_standing_id,
                        x_attribute_category   => l_term_rec.attribute_category,
                        x_attribute1           => l_term_rec.attribute1,
                        x_attribute2           => l_term_rec.attribute2,
                        x_attribute3           => l_term_rec.attribute3,
                        x_attribute4           => l_term_rec.attribute4,
                        x_attribute5           => l_term_rec.attribute5,
                        x_attribute6           => l_term_rec.attribute6,
                        x_attribute7           => l_term_rec.attribute7,
                        x_attribute8           => l_term_rec.attribute8,
                        x_attribute9           => l_term_rec.attribute9,
                        x_attribute10          => l_term_rec.attribute10,
                        x_attribute11          => l_term_rec.attribute11,
                        x_attribute12          => l_term_rec.attribute12,
                        x_attribute13          => l_term_rec.attribute13,
                        x_attribute14          => l_term_rec.attribute14,
                        x_attribute15          => l_term_rec.attribute15,
                        x_attribute16          => l_term_rec.attribute16,
                        x_attribute17          => l_term_rec.attribute17,
                        x_attribute18          => l_term_rec.attribute18,
                        x_attribute19          => l_term_rec.attribute19,
                        x_attribute20          => l_term_rec.attribute20,
                        x_mode                 => 'R',
                        x_plan_sht_status      => NVL(l_term_rec.plan_sht_status,'NONE')
                  );
    FOR rec_dest_fut_terms IN c_dest_fut_terms LOOP

        -- Set all destination future terms as Key terms.

        IGS_EN_SPA_TERMS_PKG.update_row(
                        x_rowid                => rec_dest_fut_terms.rowid,
                        x_term_record_id       => rec_dest_fut_terms.term_record_id,
                        x_person_id            => rec_dest_fut_terms.person_id,
                        x_program_cd           => rec_dest_fut_terms.program_cd,
                        x_program_version      => rec_dest_fut_terms.program_version,
                        x_acad_cal_type        => rec_dest_fut_terms.acad_cal_type,
                        x_term_cal_type        => rec_dest_fut_terms.term_cal_type,
                        x_term_sequence_number => rec_dest_fut_terms.term_sequence_number,
                        x_key_program_flag     => 'Y',
                        x_location_cd          => rec_dest_fut_terms.location_cd,
                        x_attendance_mode      => rec_dest_fut_terms.attendance_mode,
                        x_attendance_type      => rec_dest_fut_terms.attendance_type,
                        x_fee_cat              => rec_dest_fut_terms.fee_cat,
                        x_coo_id               => rec_dest_fut_terms.coo_id,
                        x_class_standing_id    => rec_dest_fut_terms.class_standing_id,
                        x_attribute_category   => rec_dest_fut_terms.attribute_category,
                        x_attribute1           => rec_dest_fut_terms.attribute1,
                        x_attribute2           => rec_dest_fut_terms.attribute2,
                        x_attribute3           => rec_dest_fut_terms.attribute3,
                        x_attribute4           => rec_dest_fut_terms.attribute4,
                        x_attribute5           => rec_dest_fut_terms.attribute5,
                        x_attribute6           => rec_dest_fut_terms.attribute6,
                        x_attribute7           => rec_dest_fut_terms.attribute7,
                        x_attribute8           => rec_dest_fut_terms.attribute8,
                        x_attribute9           => rec_dest_fut_terms.attribute9,
                        x_attribute10          => rec_dest_fut_terms.attribute10,
                        x_attribute11          => rec_dest_fut_terms.attribute11,
                        x_attribute12          => rec_dest_fut_terms.attribute12,
                        x_attribute13          => rec_dest_fut_terms.attribute13,
                        x_attribute14          => rec_dest_fut_terms.attribute14,
                        x_attribute15          => rec_dest_fut_terms.attribute15,
                        x_attribute16          => rec_dest_fut_terms.attribute16,
                        x_attribute17          => rec_dest_fut_terms.attribute17,
                        x_attribute18          => rec_dest_fut_terms.attribute18,
                        x_attribute19          => rec_dest_fut_terms.attribute19,
                        x_attribute20          => rec_dest_fut_terms.attribute20,
                        x_mode                 => 'R',
                        x_plan_sht_status      => rec_dest_fut_terms.plan_sht_status
                  );
        END LOOP;



END change_key_program_to;

FUNCTION get_spat_fee_cat(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2
AS
  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT fee_cat from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.fee_cat
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT fee_cat
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_fee_cat igs_en_spa_terms.fee_cat%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_fee_cat;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_fee_cat;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_fee_cat;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_fee_cat;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_fee_cat;
     END IF;
     return l_fee_cat;
END get_spat_fee_cat;

FUNCTION get_spat_class_standing(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT class_standing_id from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.class_standing_id
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT IGS_PR_CLASS_STD_ID
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_class_standing igs_en_spa_terms.class_standing_id%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_class_standing;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_class_standing;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_class_standing;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_class_standing;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_class_standing;
     END IF;
     return l_class_standing;
END get_spat_class_standing;

FUNCTION get_spat_coo_id(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT coo_id from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.coo_id
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT coo_id
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_coo_id igs_en_spa_terms.coo_id%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_coo_id;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_coo_id;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_coo_id;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_coo_id;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_coo_id;
     END IF;
     return l_coo_id;
END get_spat_coo_id;

FUNCTION get_spat_att_type (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2,
            p_term_cal_type IN VARCHAR2,
            p_term_sequence_NUMBER IN NUMBER
            ) RETURN VARCHAR2
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT attendance_type from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.attendance_type
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT attendance_type
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_attendance_type igs_en_spa_terms.attendance_type%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_attendance_type;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_attendance_type;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_attendance_type;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_attendance_type;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_attendance_type;
     END IF;
     return l_attendance_type;
END get_spat_att_type;

FUNCTION get_spat_att_mode(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT attendance_mode from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.attendance_mode
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT attendance_mode
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_attendance_mode igs_en_spa_terms.attendance_mode%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_attendance_mode;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_attendance_mode;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_attendance_mode;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_attendance_mode;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_attendance_mode;
     END IF;
     return l_attendance_mode;
END get_spat_att_mode;

FUNCTION get_spat_location(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT location_cd from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.location_cd
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT location_cd
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_location_cd igs_en_spa_terms.location_cd%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_location_cd;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_location_cd;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_location_cd;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_location_cd;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_location_cd;
     END IF;
     return l_location_cd;
END get_spat_location;

FUNCTION get_spat_program_version(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN NUMBER
AS

  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT program_version from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.program_version
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT version_number
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_program_version igs_en_spa_terms.program_version%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_program_version;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_program_version;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_program_version;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_program_version;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_program_version;
     END IF;
     return l_program_version;
END get_spat_program_version;

PROCEDURE delete_terms_for_program(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2) AS
l_term_cal_type IGS_CA_INST.cal_type%TYPE;
l_term_sequence_number IGS_CA_INST.sequence_number%TYPE;
l_acad_cal_type IGS_CA_INST.cal_type%TYPE;
l_acad_ci_seq_num IGS_CA_INST.sequence_number%TYPE;
l_load_ci_alt_code IGS_CA_INST.alternate_code%TYPE;
l_load_ci_start_dt  DATE;
l_load_ci_end_dt DATE;
l_message_name  VARCHAR2(200);
CURSOR c_future_terms(cp_term_cal_type IGS_CA_INST.cal_type%TYPE, cp_term_seq_num IGS_CA_INST.sequence_number%TYPE) IS
select spat.rowid, spat.person_id, spat.program_cd, spat.term_cal_type,spat.term_sequence_number, spat.fee_cat
from igs_en_spa_terms spat, igs_ca_inst c1, igs_ca_inst c2
where person_id = p_person_id
and   program_cd = p_program_cd
and   term_cal_type = c1.cal_type
and   term_sequence_number = c1.sequence_number
and   cp_term_cal_type = c2.cal_type
and   cp_term_seq_num = c2.sequence_number
and   c1.start_dt >= c2.start_dt
for update nowait;
l_fee_assessed VARCHAR2(1);
l_message VARCHAR2(2000);
BEGIN
    igs_en_gen_015.enrp_get_eff_load_ci(p_person_id, p_program_cd, SYSDATE,
                        l_acad_cal_type,
                        l_acad_ci_seq_num,
                        l_term_cal_type,
                        l_term_sequence_number,
                        l_load_ci_alt_code,
                        l_load_ci_start_dt,
                        l_load_ci_end_dt,
                        l_message_name);

    for rec_future_terms IN c_future_terms(l_term_cal_type, l_term_sequence_number)
    LOOP

            -- key/pirmary will never be unconfirmed if there is an alternate program that can
            -- be made key/primary.
            -- If this is the only primary key program then its unconfirmed and SPA key program is set as 'N'
            -- Hence there is no need to find an alternate key primary delete_row(rowid);
            -- If fee is assessed for a term, then donot delete such term record.
            igs_fi_gen_008.chk_spa_rec_exists(
                             p_n_person_id    => rec_future_terms.person_id,
                             p_v_course_cd    => rec_future_terms.program_cd,
                             p_v_load_cal_type=> rec_future_terms.term_cal_type,
                             p_n_load_ci_seq  => rec_future_terms.term_sequence_number,
                             p_v_fee_cat      => rec_future_terms.fee_cat,
                             p_v_status       => l_fee_assessed,
                             p_v_message      => l_message);
            IF  l_fee_assessed = 'N' THEN
              --
                  igs_en_spa_terms_pkg.delete_row(rec_future_terms.rowid);
            END IF;


    END LOOP;

END;
FUNCTION get_spat_key_prog_flag(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2 AS
l_key_program IGS_PS_VER.COURSE_CD%TYPE;
BEGIN
        l_key_program := find_key_effective_for(p_person_id,p_term_cal_type, p_term_sequence_NUMBER);
        if (p_program_cd  = l_key_program) THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
END get_spat_key_prog_flag;


FUNCTION get_miss_char RETURN VARCHAR2 AS
BEGIN
   RETURN FND_API.G_MISS_CHAR;
END;
FUNCTION get_spat_att_type_desc (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2,
            p_term_cal_type IN VARCHAR2,
            p_term_sequence_NUMBER IN NUMBER
            ) RETURN VARCHAR2 AS
l_att_type igs_en_atd_type.attendance_type%TYPE;
l_att_desc igs_en_atd_type.description%TYPE;
CURSOR c_att_desc (cp_att_type igs_en_atd_type.attendance_type%TYPE) IS
SELECT description
FROM igs_en_atd_type
WHERE attendance_type = cp_att_type;

BEGIN
    l_att_type := get_spat_att_type(
                            p_person_id,
                            p_program_cd,
                            p_term_cal_type,
                            p_term_sequence_NUMBER);
    OPEN c_att_desc(l_att_type);
    FETCH c_att_desc INTO l_att_desc;
    CLOSE c_att_desc;
    RETURN l_att_desc;
END;

FUNCTION get_spat_att_mode_desc (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2,
            p_term_cal_type IN VARCHAR2,
            p_term_sequence_NUMBER IN NUMBER
            ) RETURN VARCHAR2 AS
l_att_mode igs_en_atd_mode.attendance_mode%TYPE;
l_att_desc igs_en_atd_mode.description%TYPE;
CURSOR c_att_desc (cp_att_mode igs_en_atd_mode.attendance_mode%TYPE) IS
SELECT description
FROM igs_en_atd_mode
WHERE attendance_mode = cp_att_mode;

BEGIN
    l_att_mode := get_spat_att_mode(
                            p_person_id,
                            p_program_cd,
                            p_term_cal_type,
                            p_term_sequence_NUMBER);
    OPEN c_att_desc(l_att_mode);
    FETCH c_att_desc INTO l_att_desc;
    CLOSE c_att_desc;
    RETURN l_att_desc;
END;

FUNCTION get_spat_location_desc (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2,
            p_term_cal_type IN VARCHAR2,
            p_term_sequence_NUMBER IN NUMBER
            ) RETURN VARCHAR2 AS
l_loc igs_ad_location.location_cd%TYPE;
l_loc_desc igs_ad_location.description%TYPE;
CURSOR c_loc_desc (cp_loc igs_ad_location.location_cd%TYPE) IS
SELECT description
FROM igs_ad_location
WHERE location_cd = cp_loc;

BEGIN
    l_loc := get_spat_location(
                            p_person_id,
                            p_program_cd,
                            p_term_cal_type,
                            p_term_sequence_NUMBER);
    OPEN c_loc_desc(l_loc);
    FETCH c_loc_desc INTO l_loc_desc;
    CLOSE c_loc_desc;
    RETURN l_loc_desc;
END;


FUNCTION get_spat_primary_prg(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2
AS
/* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Check whether the given program is a primary or
                       secondary program in the given term.
                       Returns PRIMARY, SECONDARY OR NULL

   Change History
   Who         When        What
  stutta    31-Dec-2004  Added cursor cur_c3prev to pick up previous term
                         records for the career, if no record is found for
                         the term passed in as parameter.
  ----------------------------------------------------------------------*/

    -- cursor to check whether program is a term record
    CURSOR cur_c1 IS
        SELECT 'x'
        FROM igs_en_spa_terms spat
        WHERE
        spat.person_id            = p_person_id AND
        spat.program_cd           = p_program_cd AND
        spat.term_cal_type        = p_term_cal_type AND
        spat.term_sequence_number = p_term_sequence_number;

    -- cursor to retrieve course_type for given program and person
    CURSOR cur_c2 IS
        SELECT ps.course_type
        FROM igs_ps_ver ps,
             igs_en_stdnt_ps_att spa
        WHERE
        spa.course_cd      = p_program_cd AND
        spa.person_id      = p_person_id AND
        spa.course_cd      = ps.course_cd AND
        spa.version_number = ps.version_number;

    -- cursor to check whether term record exists for some other program
    -- for the student in same career
    CURSOR cur_c3(p_program_type IN VARCHAR2) IS
        SELECT 'x'
        FROM igs_en_spa_terms spat
        WHERE spat.person_id      = p_person_id AND
        p_program_type = (SELECT course_type FROM igs_ps_ver
                           WHERE course_cd = spat.program_cd
                           AND version_number = spat.program_version)
        AND spat.term_cal_type        = p_term_cal_type
        AND spat.term_sequence_number = p_term_sequence_number;

      CURSOR ci_start_dt (cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_ci_Sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
      SELECT start_dt
      FROM   IGS_CA_INST
      WHERE cal_type = cp_cal_type
      AND sequence_number = cp_ci_Sequence_number;

      CURSOR cur_c3prev (cp_person_id igs_en_spa_terms.person_id%TYPE,
                         cp_program_type igs_ps_ver.course_type%TYPE,
                         cp_start_dt IGS_CA_INST.START_DT%TYPE) IS
      SELECT
        SPAT.PROGRAM_CD
      FROM
        IGS_EN_SPA_TERMS SPAT,
        IGS_CA_INST CI2
      WHERE
        SPAT.PERSON_ID = cp_person_id AND
        cp_program_type = (SELECT course_type
                           FROM igs_ps_ver cv
                           WHERE spat.program_cd = cv.course_cd
                           AND spat.program_version = cv.version_number) AND
        SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
        SPAT.TERM_SEQUENCE_NUMBER = CI2.SEQUENCE_NUMBER AND
        CI2.START_DT < cp_start_dt
      ORDER BY CI2.START_DT DESC;

    -- cursor to check whether given program for person exists in
    -- program attempt table
    CURSOR cur_c4 IS
        SELECT primary_program_type
        FROM igs_en_stdnt_ps_att
        WHERE
        person_id = p_person_id AND
        course_cd = p_program_cd;


     l_primary_prg IGS_EN_STDNT_PS_ATT.PRIMARY_PROGRAM_TYPE%TYPE;
     l_profile VARCHAR2(1);
     l_program_type IGS_PS_VER.COURSE_TYPE%TYPE;
     l_check VARCHAR2(1);
     l_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE;
     l_start_dt IGS_CA_INST.START_DT%TYPE;

BEGIN

 -- check whether Career profile is set or not
 l_profile :=NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N');

 -- if system is in Career model
 IF l_profile='Y' THEN
   OPEN cur_c1;
   FETCH cur_c1 INTO l_primary_prg;

   -- check term record exists for given program,
   -- if  record exists then it is the Primary program
   IF cur_c1%FOUND THEN
    l_primary_prg:='PRIMARY';

   -- if term record for program does not exist
   ELSE
      -- retrieve course_type for program
      OPEN  cur_c2;
      FETCH cur_c2 INTO l_program_type;
      CLOSE cur_c2;

      -- and check whether term record exists for some other program for
      -- student in same career
      OPEN cur_c3(l_program_type);
      FETCH cur_c3 INTO l_check;

      -- if term record exists for some other program for student in same career
      -- return SECONDARY
      IF cur_c3%FOUND THEN
         l_primary_prg := 'SECONDARY';

      ELSE
        -- check if any previous term record exists for this career.
         OPEN ci_start_dt(p_term_cal_type, p_term_sequence_number);
         FETCH ci_start_dt INTO l_start_dt;
         CLOSE ci_start_dt;
         OPEN cur_c3prev(p_person_id, l_program_type, l_start_dt);
         FETCH cur_c3prev INTO l_program_cd;
         IF cur_c3prev%FOUND THEN -- if a previous term record is found for this career.
             IF l_program_cd = p_program_cd THEN
               -- This program is primary is the previous term
                l_primary_prg := 'PRIMARY';
             ELSE
               -- some other program is primary in previous term for the career
                 l_primary_prg := 'SECONDARY';
             END IF;
         ELSE
             -- check whether given program for person exists in
             -- program attempt table
             OPEN cur_c4;
             FETCH cur_c4 INTO l_primary_prg;

             -- if given program for person exists in program attempt table
             -- return primary_program_type value obtained
             IF cur_c4%FOUND THEN
               l_primary_prg:=l_primary_prg;

             -- if given program for person does not exist in program attempt table
             -- return null
             ELSE
               l_primary_prg :=null;
             END IF;

             CLOSE cur_c4;
           END IF;
           CLOSE cur_c3prev;
      END IF;

      CLOSE cur_c3;

   END IF;

   CLOSE cur_c1;
 END IF;

 RETURN l_primary_prg;
END get_spat_primary_prg;


PROCEDURE validate_terms(
p_person_id IN NUMBER
)
AS
/* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Validates number of terms containing key program
                       for given person id
   Change History
   Who         When        What

  ----------------------------------------------------------------------*/

    -- cursor to fetch distinct term records for given person id
    CURSOR c_distinct_terms IS
      SELECT DISTINCT term_cal_type, term_sequence_number
      FROM            IGS_EN_SPA_TERMS
      WHERE           person_id = p_person_id;

    -- cursor to fetch number of terms containing key program for given
    -- person id, term cal type and sequence number
    CURSOR c_count_key (cp_term_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_term_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE)
      IS
      SELECT COUNT(key_program_flag)
      FROM   IGS_EN_SPA_TERMS
      WHERE  person_id            = p_person_id
      AND    term_cal_type        = cp_term_cal_type
      AND    term_sequence_number = cp_term_sequence_number
      AND    key_program_flag     = 'Y';

    vn_key_count     NUMBER(1);

BEGIN
    -- loop through the distinct term records for given person id
    FOR vr_distinct_terms_rec IN c_distinct_terms LOOP

        vn_key_count := 0;

        -- fetch number of terms containing key program
        OPEN c_count_key(vr_distinct_terms_rec.term_cal_type,
                         vr_distinct_terms_rec.term_sequence_number);
        FETCH c_count_key INTO vn_key_count;
        CLOSE c_count_key;

        -- if number of terms containing key program is greater than 1
        IF vn_key_count > 1 THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_KEY_IN_TERM');
          app_exception.raise_exception;
        END IF;

     END LOOP;

END validate_terms;

FUNCTION get_curr_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2
AS
/* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Returns the sequence number for the current term, for
                       the given academic calendar

   Change History
   rvangala   17-Feb-2004    Added formatting to the return value from the
                             function, Bug #3441941

  ----------------------------------------------------------------------*/

    --local variables
    l_load_cal_type      IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_seq_num    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_load_ci_alt_code   IGS_CA_INST.ALTERNATE_CODE%TYPE;
    l_load_ci_start_dt   DATE;
    l_load_ci_end_dt     DATE;
    l_message_name       VARCHAR2(80);

    l_curr_term          VARCHAR2(100);

BEGIN

    -- call package igs_en_gen_015 to retrieve sequence number for current term
    -- for given academic calendar
    igs_en_gen_015.get_curr_acad_term_cal(
        p_acad_cal_type       => p_cal_type,
        p_effective_dt        => SYSDATE,
        p_load_cal_type       => l_load_cal_type,
        p_load_ci_seq_num     => l_load_ci_seq_num,
        p_load_ci_alt_code    => l_load_ci_alt_code,
        p_load_ci_start_dt    => l_load_ci_start_dt,
        p_load_ci_end_dt      => l_load_ci_end_dt,
        p_message_name        => l_message_name);

     -- concatenate term calendar sequence number and term calendar type
     l_curr_term :=RPAD(l_load_ci_seq_num,6,' ') || l_load_cal_type;

     RETURN l_curr_term;

END get_curr_term;


FUNCTION get_prev_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2
AS
/* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Returns the sequence number for the immediate previous
                       term for the current term, for the given academic
                       calendar

   Change History
   rvangala   17-Feb-2004    Added formatting in select clause to pick
                             results from cur_c1, Bug #3441941

  ----------------------------------------------------------------------*/

    -- cursor to fetch immediate previous term for current term, for the
    -- given academic calendar
    CURSOR cur_c1(p_cur_term_cal IN VARCHAR2,
                  p_cur_term_seq_num IN NUMBER) IS
        SELECT RPAD(ci2.sequence_number,6,' ') || ci2.cal_Type
        FROM igs_ca_inst ci2,
            igs_ca_inst_rel cir,
            igs_ca_type ct,
            igs_ca_inst ci1,
            igs_ca_stat cs
        WHERE
        ci2.cal_type        = cir.sub_cal_type AND
        ci2.sequence_number = cir.sub_ci_sequence_number AND
        cir.sup_cal_type    = p_cal_type AND
        ci2.cal_type        = ct.cal_type AND
        ct.s_cal_cat        = 'LOAD' AND
        cs.cal_status       = ci1.cal_status AND
        cs.s_cal_status     = 'ACTIVE' AND
        ci1.cal_type        = p_cur_term_cal AND
        ci1.sequence_number = p_cur_term_seq_num AND
        ci2.start_dt        < ci1.start_dt
        ORDER BY            ci2.start_dt DESC;

    --local variables
    l_load_cal_type      IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_seq_num    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_load_ci_alt_code   IGS_CA_INST.ALTERNATE_CODE%TYPE;
    l_load_ci_start_dt   DATE;
    l_load_ci_end_dt     DATE;
    l_message_name       VARCHAR2(80);

    l_prev_term          VARCHAR2(100);
BEGIN
    -- call package igs_en_gen_015 to retrieve sequence number for current term
    -- for given academic calendar
    igs_en_gen_015.get_curr_acad_term_cal(
        p_acad_cal_type       => p_cal_type,
        p_effective_dt        => SYSDATE,
        p_load_cal_type       => l_load_cal_type,
        p_load_ci_seq_num     => l_load_ci_seq_num,
        p_load_ci_alt_code    => l_load_ci_alt_code,
        p_load_ci_start_dt    => l_load_ci_start_dt,
        p_load_ci_end_dt      => l_load_ci_end_dt,
        p_message_name        => l_message_name);

   -- fetch immediate previous term for the current term
   OPEN cur_c1(l_load_cal_type,l_load_ci_seq_num);
   FETCH cur_c1 INTO l_prev_term;
   CLOSE cur_c1;

   RETURN l_prev_term;
END get_prev_term;


FUNCTION get_next_term(
p_cal_type IN VARCHAR2
) RETURN VARCHAR2
AS
/* -----------------------------------------------------------------------
   Created By        : rvangala
   Date Created By   : 18-Nov-2003
   Purpose           : Returns the sequence number for the immediate next term
                       for the current term, for the given academic calendar

   Change History
   rvangala   17-Feb-2004    Added formatting in select clause to pick
                             results from cur_c1, Bug #3441941

  ----------------------------------------------------------------------*/

    -- cursor to fetch immediate next term for current term, for the
    -- given academic calendar
    CURSOR cur_c1(p_cur_term_cal IN VARCHAR2,
                   p_cur_term_seq_num IN NUMBER) IS
        SELECT RPAD(ci2.sequence_number,6,' ') || ci2.cal_type
        FROM igs_ca_inst ci2,
            igs_ca_inst_rel cir,
            igs_ca_type ct,
            igs_ca_inst ci1,
            igs_ca_stat cs
        WHERE
        ci2.cal_type        = cir.sub_cal_type AND
        ci2.sequence_number = cir.sub_ci_sequence_number AND
        cir.sup_cal_type    = p_cal_type AND
        ci2.cal_type        = ct.cal_type AND
        ct.s_cal_cat        = 'LOAD' AND
        cs.cal_status       = ci1.cal_status AND
        cs.s_cal_status     = 'ACTIVE' AND
        ci1.cal_type        = p_cur_term_cal AND
        ci1.sequence_number = p_cur_term_seq_num AND
        ci2.start_dt        > ci1.start_dt
        ORDER BY            ci2.start_dt;

    --local variables
    l_load_cal_type      IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_seq_num    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_load_ci_alt_code   IGS_CA_INST.ALTERNATE_CODE%TYPE;
    l_load_ci_start_dt   DATE;
    l_load_ci_end_dt     DATE;
    l_message_name       VARCHAR2(80);

    l_next_term          VARCHAR2(100);
BEGIN
    -- call package igs_en_gen_015 to retrieve sequence number for current term
    -- for given academic calendar
    igs_en_gen_015.get_curr_acad_term_cal(
        p_acad_cal_type       => p_cal_type,
        p_effective_dt        => SYSDATE,
        p_load_cal_type       => l_load_cal_type,
        p_load_ci_seq_num     => l_load_ci_seq_num,
        p_load_ci_alt_code    => l_load_ci_alt_code,
        p_load_ci_start_dt    => l_load_ci_start_dt,
        p_load_ci_end_dt      => l_load_ci_end_dt,
        p_message_name        => l_message_name);

   -- fetch immediate next term for the current term
   OPEN cur_c1(l_load_cal_type,l_load_ci_seq_num);
   FETCH cur_c1 INTO l_next_term;
   CLOSE cur_c1;

   RETURN l_next_term;
END get_next_term;


FUNCTION get_spat_acad_cal_type(
p_person_id IN NUMBER,
p_program_cd IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_NUMBER IN NUMBER
) RETURN VARCHAR2 AS
  -- ## Get the term details information for the effective term
  CURSOR c_term IS
    SELECT acad_cal_type from igs_en_spa_terms
    WHERE person_id = p_person_id
    AND   program_cd = p_program_cd
    AND   term_cal_type = p_term_cal_type
    AND   term_sequence_number = p_term_sequence_number;

  -- ## get the term record values for a term which is previous to the effective term
  CURSOR c_prev_term IS
          SELECT
            SPAT.acad_cal_type
          FROM
            IGS_EN_SPA_TERMS SPAT,
            IGS_CA_INST CI1,
            IGS_CA_INST CI2
          WHERE
            SPAT.PERSON_ID = p_person_id AND
            spat.program_cd = p_program_cd AND
            SPAT.TERM_CAL_TYPE = CI2.CAL_TYPE AND
            SPAT.TERM_SEQUENCE_NUMBER =     CI2.SEQUENCE_NUMBER AND
            CI1.CAL_TYPE = p_term_cal_type AND
            CI1.SEQUENCE_NUMBER = p_term_sequence_number     AND
            CI1.START_DT > CI2.START_DT AND
            SPAT.ACAD_CAL_TYPE IN (SELECT SUP_CAL_TYPE
                                   FROM IGS_CA_INST_REL
                                   WHERE SUB_CAL_TYPE = CI1.CAL_TYPE
                                   AND SUB_CI_SEQUENCE_NUMBER = CI1.SEQUENCE_NUMBER)
          ORDER BY CI2.START_DT DESC;

-- ## get the SPA values for the passed in program attempt
CURSOR c_spa IS
SELECT cal_type
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_acad_cal_type igs_en_spa_terms.acad_cal_type%TYPE;

BEGIN
--## 1. If term record exists for the effective term then get the attribute details
--##    from it, set in EN_SPAT_REC_TYPE and exit
--## 2. Term record not found for effective term, hence move on to a term record
--##    which is immediately in the past and get the attribute information and
--##    set it in EN_SPAT_REC_TYPE and exit
--## 3. If no term record is found for the program attempt then get the attribute
--##    information from the SPA.

    OPEN c_term;
    FETCH c_term INTO l_acad_cal_type;
    IF (c_term%FOUND) THEN
        CLOSE c_term;

        RETURN l_acad_cal_type;
     END IF;
     CLOSE c_term;

     OPEN c_prev_term;
     FETCH c_prev_term INTO l_acad_cal_type;
     IF (c_prev_term%FOUND) THEN
        CLOSE c_prev_term;
        RETURN l_acad_cal_type;
     ELSE
        CLOSE c_prev_term;
        OPEN c_spa;
        FETCH c_spa INTO l_acad_cal_type;
        CLOSE c_spa;
     END IF;
     RETURN l_acad_cal_type;
END get_spat_acad_cal_type;


END IGS_EN_SPA_TERMS_API;

/
