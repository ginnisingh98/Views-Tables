--------------------------------------------------------
--  DDL for Package Body IGS_AS_TRNCMT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_TRNCMT_LGCY_PUB" AS
/* $Header: IGSAS56B.pls 120.0 2005/07/05 12:56:21 appldev noship $ */
/******************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2002
  ||  Purpose : This is an API to move  legacy teranscript comments to OSS
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
******************************************************************************/
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_AS_TRNCMT_LGCY_PUB';

  -- This procedure puts NULL to all the non-required fields for a particular comment type
  PROCEDURE nullify_inappropriate_fields(
                       p_lgcy_trncmt_rec IN OUT NOCOPY lgcy_trncmt_rec_type) IS
  BEGIN
      IF p_lgcy_trncmt_rec.comment_type_code = 'UNIT_ATTEMPT' THEN
               p_lgcy_trncmt_rec.program_cd              := NULL;
               p_lgcy_trncmt_rec.program_type            := NULL;
               p_lgcy_trncmt_rec.award_cd                := NULL;
               p_lgcy_trncmt_rec.load_cal_alternate_cd   := NULL;
               p_lgcy_trncmt_rec.unit_set_cd             := NULL;
               p_lgcy_trncmt_rec.us_version_number       := NULL;
	       return;
      END IF;
      p_lgcy_trncmt_rec.unit_cd                 := NULL;
      p_lgcy_trncmt_rec.version_number          := NULL;
      p_lgcy_trncmt_rec.teach_cal_alternate_cd  := NULL;
      p_lgcy_trncmt_rec.location_cd             := NULL;
      p_lgcy_trncmt_rec.unit_class              := NULL;

      IF    p_lgcy_trncmt_rec.comment_type_code = 'CAREER_HEADER' OR
            p_lgcy_trncmt_rec.comment_type_code = 'CAREER_FOOTER' OR
            p_lgcy_trncmt_rec.comment_type_code = 'CAREER_BASIS'  THEN
               p_lgcy_trncmt_rec.program_cd              := NULL;
               p_lgcy_trncmt_rec.award_cd                := NULL;
               p_lgcy_trncmt_rec.load_cal_alternate_cd   := NULL;
               p_lgcy_trncmt_rec.unit_set_cd             := NULL;
               p_lgcy_trncmt_rec.us_version_number       := NULL;
      ELSIF p_lgcy_trncmt_rec.comment_type_code = 'CAREER_TERM'   THEN
               p_lgcy_trncmt_rec.program_cd              := NULL;
               p_lgcy_trncmt_rec.award_cd                := NULL;
               p_lgcy_trncmt_rec.unit_set_cd             := NULL;
               p_lgcy_trncmt_rec.us_version_number       := NULL;
      ELSIF p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_HEADER' OR
            p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_FOOTER' OR
            p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_BASIS'  THEN
               p_lgcy_trncmt_rec.program_type            := NULL;
               p_lgcy_trncmt_rec.award_cd                := NULL;
               p_lgcy_trncmt_rec.load_cal_alternate_cd   := NULL;
               p_lgcy_trncmt_rec.unit_set_cd             := NULL;
               p_lgcy_trncmt_rec.us_version_number       := NULL;
      ELSIF p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_YEAR'   THEN
               p_lgcy_trncmt_rec.program_type            := NULL;
               p_lgcy_trncmt_rec.award_cd                := NULL;
               p_lgcy_trncmt_rec.load_cal_alternate_cd   := NULL;
      ELSIF p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_AWARD'  THEN
           --    p_lgcy_trncmt_rec.program_type            := NULL;
               p_lgcy_trncmt_rec.load_cal_alternate_cd   := NULL;
               p_lgcy_trncmt_rec.unit_set_cd             := NULL;
               p_lgcy_trncmt_rec.us_version_number       := NULL;
      END IF;
  END nullify_inappropriate_fields;

  FUNCTION validate_parameters (
               p_lgcy_trncmt_rec IN OUT NOCOPY lgcy_trncmt_rec_type
           ) RETURN  BOOLEAN
  /******************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2002
  ||  Purpose    : Valdiates if all the mandatory for this API has been passed
  ||               If not, add the msgs to the stack and return false
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************************/
  IS

    l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);
    l_dummy VARCHAR2(30);

    CURSOR cur_lookup_code(p_lookup_code igs_lookup_values.lookup_code%TYPE) IS
           SELECT 'x'
           FROM   igs_lookup_values
           WHERE  lookup_type = 'IGS_AS_STDNT_TRNS_CMNT_TYPE'
           AND    lookup_code = p_lookup_code
           AND    NVL(enabled_flag, 'N') = 'Y';

  BEGIN
    --Convert all the values that must be uppercase into uppercase forcibly
    p_lgcy_trncmt_rec.comment_type_code   :=  UPPER(p_lgcy_trncmt_rec.comment_type_code);
    p_lgcy_trncmt_rec.program_cd          :=  UPPER(p_lgcy_trncmt_rec.program_cd);
    p_lgcy_trncmt_rec.program_type        :=  UPPER(p_lgcy_trncmt_rec.program_type);
    p_lgcy_trncmt_rec.award_cd            :=  UPPER(p_lgcy_trncmt_rec.award_cd);
    p_lgcy_trncmt_rec.unit_set_cd         :=  UPPER(p_lgcy_trncmt_rec.unit_set_cd);

    -- nullify the values inappropriate for the current comment_type_code
    nullify_inappropriate_fields(p_lgcy_trncmt_rec);

    IF p_lgcy_trncmt_rec.comment_type_code IS NULL THEN
      l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_CMNT_TYP_NULL');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_lgcy_trncmt_rec.comment_txt    IS  NULL THEN
      l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_CMNT_NULL');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_lgcy_trncmt_rec.person_number IS  NULL THEN
      l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PER_NUM_NULL');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_lgcy_trncmt_rec.comment_type_code IS NOT NULL  THEN
      OPEN  cur_lookup_code(p_lgcy_trncmt_rec.comment_type_code);
      FETCH cur_lookup_code INTO l_dummy;
      IF cur_lookup_code%NOTFOUND THEN
          l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_CMNT_TYP_INVALID');
          FND_MSG_PUB.ADD;
          RETURN l_return_value ;
      END IF;
      CLOSE cur_lookup_code;

      IF (p_lgcy_trncmt_rec.comment_type_code = 'CAREER_HEADER'  OR
          p_lgcy_trncmt_rec.comment_type_code = 'CAREER_FOOTER'  OR
          p_lgcy_trncmt_rec.comment_type_code = 'CAREER_BASIS'   OR
          p_lgcy_trncmt_rec.comment_type_code = 'CAREER_TERM'  ) AND
          p_lgcy_trncmt_rec.program_type IS NULL
      THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'program_type');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
      END IF;

      IF (p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_HEADER'  OR
          p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_FOOTER'  OR
          p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_BASIS'   OR
          p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_YEAR'   OR
          p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_AWARD'  ) AND
          p_lgcy_trncmt_rec.program_cd IS NULL
      THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'program_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
      END IF;

      IF  p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_AWARD' AND
          p_lgcy_trncmt_rec.award_cd IS NULL
      THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'award_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
      END IF;

      IF  p_lgcy_trncmt_rec.comment_type_code = 'CAREER_TERM' AND
          p_lgcy_trncmt_rec.load_cal_alternate_cd IS NULL
      THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'load_cal_alternate_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
      END IF;

      IF  p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_YEAR' THEN
          IF p_lgcy_trncmt_rec.unit_set_cd IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'unit_set_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
          IF p_lgcy_trncmt_rec.us_version_number IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'us_version_number');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
      END IF;

      IF  p_lgcy_trncmt_rec.comment_type_code = 'UNIT_ATTEMPT' THEN
          IF p_lgcy_trncmt_rec.unit_cd IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'unit_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
          IF p_lgcy_trncmt_rec.version_number IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'version_number');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
          IF p_lgcy_trncmt_rec.teach_cal_alternate_cd IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'teach_cal_alternate_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
          IF p_lgcy_trncmt_rec.location_cd IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'location_cd');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
          IF p_lgcy_trncmt_rec.unit_class IS NULL THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'unit_class');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
          END IF;
      END IF;

    END IF;

    RETURN l_return_value ;

  END validate_parameters;

-------------------------------------------------------------------------------
  FUNCTION derive_trncmt_data(
           p_lgcy_trncmt_rec       IN OUT NOCOPY lgcy_trncmt_rec_type,
           p_person_id             OUT    NOCOPY igs_pe_person.person_id%TYPE,
           p_load_cal_type         OUT    NOCOPY igs_ca_inst.cal_type%TYPE,
           p_load_sequence_number  OUT    NOCOPY igs_ca_inst.sequence_number%TYPE,
           p_uoo_id                OUT    NOCOPY igs_ps_unit_ofr_opt_all.uoo_id%TYPE
  )RETURN  BOOLEAN
  /****************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2003
  ||  Purpose    : Derives transcript comment data
  ||               If error occurs, add the msgs to the stack and return false
  ||               Called by create_trncmt
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ****************************************************************************/
  IS

    l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);
    l_message VARCHAR2(2000);
    l_start_dt DATE ;
    l_end_dt DATE ;
    l_teach_cal_type         igs_ca_inst.cal_type%TYPE;
    l_teach_sequence_number  igs_ca_inst.sequence_number%TYPE;

    CURSOR cur_uoo_id(
           p_unit_cd                 igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
           p_version_number          igs_ps_unit_ofr_opt_all.version_number%TYPE,
           p_cal_type                igs_ps_unit_ofr_opt_all.cal_type%TYPE,
           p_ci_sequence_number      igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
           p_location_cd             igs_ps_unit_ofr_opt_all.location_cd%TYPE,
           p_unit_class              igs_ps_unit_ofr_opt_all.unit_class%TYPE
    ) IS
        SELECT uoo_id
        FROM   igs_ps_unit_ofr_opt_all
        WHERE  unit_cd            = p_unit_cd
           AND version_number     = p_version_number
           AND cal_type           = p_cal_type
           AND ci_sequence_number = p_ci_sequence_number
           AND location_cd        = p_location_cd
           AND unit_class         = p_unit_class;

  BEGIN

    --Get person id
    p_person_id := igs_ge_gen_003.get_person_id(p_lgcy_trncmt_rec.person_number);
    IF p_person_id IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
      FND_MSG_PUB.ADD;
      l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
      RETURN l_return_value;
    END IF;

    --Get load calendar info
    IF p_lgcy_trncmt_rec.comment_type_code = 'CAREER_TERM' THEN
        igs_ge_gen_003.get_calendar_instance(p_lgcy_trncmt_rec.load_cal_alternate_cd,
                                             '''LOAD''',
                                             p_load_cal_type,
                                             p_load_sequence_number,
                                             l_start_dt,
                                             l_end_dt,
                                             l_message) ;
        IF p_load_cal_type IS NULL OR p_load_sequence_number IS NULL THEN
             FND_MESSAGE.SET_NAME ('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
             FND_MSG_PUB.ADD;
             l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
             RETURN l_return_value;
        END IF;
    END IF;

    --Get teaching calendar info
    IF p_lgcy_trncmt_rec.comment_type_code = 'UNIT_ATTEMPT' THEN
        igs_ge_gen_003.get_calendar_instance(p_lgcy_trncmt_rec.teach_cal_alternate_cd,
                                             '''TEACHING''',
                                             l_teach_cal_type,
                                             l_teach_sequence_number,
                                             l_start_dt,
                                             l_end_dt,
                                             l_message) ;
        IF l_teach_cal_type IS NULL OR l_teach_sequence_number IS NULL THEN
             FND_MESSAGE.SET_NAME ('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
             FND_MSG_PUB.ADD;
             l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
             RETURN l_return_value;
        END IF;
    END IF;

    --Derive uoo_id if it is UNIT_ATTEMPT
    IF p_lgcy_trncmt_rec.comment_type_code = 'UNIT_ATTEMPT' THEN
         OPEN  cur_uoo_id(
                  p_lgcy_trncmt_rec.unit_cd,
                  p_lgcy_trncmt_rec.version_number,
                  l_teach_cal_type,
                  l_teach_sequence_number,
                  p_lgcy_trncmt_rec.location_cd,
                  p_lgcy_trncmt_rec.unit_class);
         FETCH cur_uoo_id INTO p_uoo_id;
         IF cur_uoo_id%NOTFOUND THEN
              l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_NULL_CHK');
              FND_MESSAGE.SET_TOKEN('INT_FIELD', 'uoo_id');
              FND_MESSAGE.SET_TOKEN('CMNT_TYPE', p_lgcy_trncmt_rec.comment_type_code);
              FND_MSG_PUB.ADD;
         END IF;
         CLOSE cur_uoo_id;
    END IF;

    RETURN l_return_value;

  END derive_trncmt_data;

-------------------------------------------------------------------------------
  FUNCTION validate_trncmt_db_cons(
                p_person_id             IN  igs_pe_person.person_id%TYPE,
                p_load_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                p_load_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
                p_uoo_id                IN  igs_en_su_attempt.uoo_id%TYPE,
                p_lgcy_trncmt_rec       IN  lgcy_trncmt_rec_type
           )  RETURN VARCHAR2
  /****************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2003
  ||  Purpose    : Validate db constraints
  ||               If error occurs, add the msgs to the stack and return false
  ||               Called by create_graduand
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ****************************************************************************/
  IS
    CURSOR cur_check_course_type(
                cp_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_type   IGS_PS_VER_ALL.course_type%TYPE
    )IS
        SELECT 'X'
        FROM IGS_EN_STDNT_PS_ATT spa, IGS_PS_VER_ALL pva
       WHERE spa.course_cd      = pva.course_cd
         AND spa.version_number = pva.version_number
         AND spa.person_id      = cp_person_id
         AND pva.course_type    = cp_course_type;

    CURSOR cur_check_career_term(
                cp_person_id               igs_pe_person.person_id%TYPE,
                cp_course_type             igs_ps_ver_all.course_type%TYPE,
                cp_load_cal_type           igs_ca_inst.cal_type%TYPE,
                cp_load_ci_sequence_number igs_ca_inst.sequence_number%TYPE
    ) IS
        SELECT 'X'
          FROM igs_pr_acad_load_v
         WHERE person_id = cp_person_id
           AND course_type = cp_course_type
           AND load_cal_type = cp_load_cal_type
           AND load_ci_sequence_number = cp_load_ci_sequence_number;

    CURSOR cur_igs_as_su_setatmpt(
                cp_person_id               igs_pe_person.person_id%TYPE,
                cp_course_cd               igs_as_su_setatmpt.course_cd%TYPE,
                cp_unit_set_cd             igs_as_su_setatmpt.unit_set_cd%TYPE
    ) IS
      SELECT   'X'
      FROM     IGS_AS_SU_SETATMPT
      WHERE    person_id   = cp_person_id
      AND      course_cd   = cp_course_cd
      AND      unit_set_cd = cp_unit_set_cd;

    CURSOR cur_igs_he_en_susa(
                cp_person_id               igs_pe_person.person_id%TYPE,
                cp_course_cd               igs_as_su_setatmpt.course_cd%TYPE,
                cp_unit_set_cd             igs_as_su_setatmpt.unit_set_cd%TYPE
    ) IS
      SELECT   'X'
      FROM     igs_he_en_susa
      WHERE    person_id   = cp_person_id
      AND      course_cd   = cp_course_cd
      AND      unit_set_cd = cp_unit_set_cd;

    l_dummy VARCHAR2(30);
    l_return_value VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    -- Unique key validation
    IF igs_as_stu_trn_cmts_pkg.get_uk_for_validation(
                 x_person_id                    => p_person_id,
                 x_comment_type_code            => p_lgcy_trncmt_rec.comment_type_code,
                 x_course_cd                    => p_lgcy_trncmt_rec.program_cd,
                 x_course_type                  => p_lgcy_trncmt_rec.program_type,
                 x_award_cd                     => p_lgcy_trncmt_rec.award_cd,
                 x_load_cal_type                => p_load_cal_type,
                 x_load_ci_sequence_number      => p_load_sequence_number,
                 x_unit_set_cd                  => p_lgcy_trncmt_rec.unit_set_cd,
                 x_us_version_number            => p_lgcy_trncmt_rec.us_version_number,
                 x_uoo_id                       => p_uoo_id
                )
    THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_EXISTS');
        FND_MSG_PUB.ADD;
        l_return_value := 'E';  -- Error out
        RETURN l_return_value;
    END IF;

    -- Foreign key validation with IGS_EN_STDNT_PS_ATT
    IF p_lgcy_trncmt_rec.program_cd IS NOT NULL AND
       NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation(
               x_person_id => p_person_id ,
               x_course_cd => p_lgcy_trncmt_rec.program_cd)
    THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_STPRATPT_FK_NOT_EXISTS');
        FND_MSG_PUB.ADD;
        l_return_value := 'E';
    END IF;

    -- Foreign key validation with IGS_HE_EN_SUSA
    IF p_lgcy_trncmt_rec.unit_set_cd  IS NOT NULL THEN
        OPEN cur_igs_he_en_susa(p_person_id,
                                p_lgcy_trncmt_rec.program_cd,
                                p_lgcy_trncmt_rec.unit_set_cd);
        FETCH cur_igs_he_en_susa into l_dummy;
        IF cur_igs_he_en_susa%NOTFOUND THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_STD_ENRL_NOT_EXISTS');
          FND_MSG_PUB.ADD;
          l_return_value := 'E';
	END IF;
    END IF;

    --Foreign key validation with IGS_EN_SPA_AWD_AIM
    IF p_lgcy_trncmt_rec.award_cd IS NOT NULL AND
       NOT igs_en_spa_awd_aim_pkg.get_pk_for_validation(
               x_person_id       => p_person_id,
               x_course_cd       => p_lgcy_trncmt_rec.program_cd,
               x_award_cd        => p_lgcy_trncmt_rec.award_cd)
    THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_AWD_AWARD_FK');
        FND_MSG_PUB.ADD;
        l_return_value := 'E';
    END IF;

    -- unit_set_cd should be in range (0, 999)
    IF p_lgcy_trncmt_rec.unit_set_cd IS NOT NULL THEN
       BEGIN
           igs_en_unit_set_pkg.check_constraints(
                   column_name       => 'UNIT_SET_CD',
                   column_value      => p_lgcy_trncmt_rec.unit_set_cd);
       EXCEPTION
           WHEN OTHERS THEN
               FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.COUNT_MSG);
               FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_UNTST_VERSION_BET_0_999');
               FND_MSG_PUB.ADD;
               l_return_value := 'E';
       END;
    END IF;

    --Foreign key validation with IGS_PS_TYPE
    IF p_lgcy_trncmt_rec.program_type IS NOT NULL AND
       NOT igs_ps_type_pkg.get_pk_for_validation(x_course_type => p_lgcy_trncmt_rec.program_type)
    THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AV_BAS_CRS_TYP_FK_EXISTS');
        FND_MSG_PUB.ADD;
        l_return_value := 'E';
    END IF;

    --Foreign key validation with IGS_AS_SU_SETATMPT
    IF p_lgcy_trncmt_rec.comment_type_code = 'PROGRAM_YEAR' THEN
        OPEN cur_igs_as_su_setatmpt(p_person_id,
                                    p_lgcy_trncmt_rec.program_cd,
                                    p_lgcy_trncmt_rec.unit_set_cd);
        FETCH cur_igs_as_su_setatmpt into l_dummy;
        IF cur_igs_as_su_setatmpt%NOTFOUND THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_TRNS_CMTS_US_CHK');
          FND_MSG_PUB.ADD;
          l_return_value := 'E';
	END IF;
    END IF;

    --Foreign key validation with IGS_EN_SU_ATTEMPT
    IF p_lgcy_trncmt_rec.comment_type_code = 'CAREER_TERM' THEN
        OPEN cur_check_career_term(
                  p_person_id,
                  p_lgcy_trncmt_rec.program_type,
                  p_load_cal_type,
                  p_load_sequence_number);
        FETCH cur_check_career_term into l_dummy;
        IF cur_check_career_term%NOTFOUND THEN
            FND_MESSAGE.SET_NAME ('IGS', 'IGS_AS_STD_ENRL_NOT_EXISTS');
            FND_MSG_PUB.ADD;
            l_return_value := 'E';
        END IF;
        CLOSE cur_check_career_term;
    END IF;

    -- Validation for COURSE_TYPE
    IF substr(p_lgcy_trncmt_rec.comment_type_code, 0, 7) = 'CAREER_' THEN
        OPEN cur_check_course_type(p_person_id, p_lgcy_trncmt_rec.program_type);
        FETCH cur_check_course_type into l_dummy;
        IF cur_check_course_type%NOTFOUND THEN
            FND_MESSAGE.SET_NAME ('IGS', 'IGS_AV_BAS_CRS_TYP_FK_EXISTS');
            FND_MSG_PUB.ADD;
            l_return_value := 'E';
        END IF;
        CLOSE cur_check_course_type;
    END IF;

    RETURN l_return_value;

  END validate_trncmt_db_cons;

-------------------------------------------------------------------------------
  PROCEDURE create_trncmt(
                         p_api_version         IN  NUMBER,
                         p_init_msg_list       IN  VARCHAR2 ,
                         p_commit              IN  VARCHAR2 ,
                         p_validation_level    IN  NUMBER   ,
                         p_lgcy_trncmt_rec     IN  OUT NOCOPY LGCY_TRNCMT_REC_TYPE,
                         x_return_status       OUT NOCOPY VARCHAR2,
                         x_msg_count           OUT NOCOPY NUMBER,
                         x_msg_data            OUT NOCOPY VARCHAR2
  ) IS
  /****************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2003
  ||  Purpose    : For legacy transcript comments API
  ||
  ||  This is called for importing transcript comments data into OSS tables
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ****************************************************************************/
    l_api_name          CONSTANT VARCHAR2(30) := 'create_trncmt';
    l_api_version       CONSTANT  NUMBER      := 1.0;

    --Local params
    l_comment_id             igs_as_stu_trn_cmts.comment_id%TYPE;
    l_load_cal_type          igs_ca_inst.cal_type%TYPE;
    l_load_sequence_number   igs_ca_inst.sequence_number%TYPE;
    l_person_id              igs_pe_person.person_id%TYPE;
    l_uoo_id                 igs_ps_unit_ofr_opt_all.uoo_id%TYPE;

    l_return_value VARCHAR2(1);
    WARN_TYPE_ERR EXCEPTION;

  BEGIN
    --Standard start of API savepoint
    SAVEPOINT create_trncmt;

    --Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(
               l_api_version,
               p_api_version,
               l_api_name,
               G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Validate the params passed to this API
    IF NOT validate_parameters(p_lgcy_trncmt_rec) THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Derive trancript comment data
    IF NOT derive_trncmt_data(
           p_lgcy_trncmt_rec       => p_lgcy_trncmt_rec,
           p_person_id             => l_person_id,
           p_load_cal_type         => l_load_cal_type,
           p_load_sequence_number  => l_load_sequence_number,
           p_uoo_id                => l_uoo_id
          ) THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Validate trancript comments for db constraints
    l_return_value := validate_trncmt_db_cons (
                                p_person_id            => l_person_id,
                                p_load_cal_type        => l_load_cal_type,
                                p_load_sequence_number => l_load_sequence_number,
                                p_uoo_id               => l_uoo_id,
                                p_lgcy_trncmt_rec      => p_lgcy_trncmt_rec
                                );
    IF l_return_value  = 'E' THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_value = 'W' THEN
        RAISE WARN_TYPE_ERR; --Error handling Goes here
    END IF;

    --Generate the sequence number for comment_id and do RAW insert into the table
    SELECT   igs_as_stu_trns_cmts_s.NEXTVAL
    INTO     l_comment_id
    FROM     dual
    WHERE    ROWNUM = 1;

    INSERT INTO IGS_AS_STU_TRN_CMTS
                                 (
                                    COMMENT_ID               ,
                                    COMMENT_TYPE_CODE        ,
                                    COMMENT_TXT              ,
                                    PERSON_ID                ,
                                    COURSE_CD                ,
                                    COURSE_TYPE              ,
                                    AWARD_CD                 ,
                                    LOAD_CAL_TYPE            ,
                                    LOAD_CI_SEQUENCE_NUMBER  ,
                                    UNIT_SET_CD              ,
                                    US_VERSION_NUMBER        ,
                                    UOO_ID                   ,
                                    CREATED_BY               ,
                                    CREATION_DATE            ,
                                    LAST_UPDATED_BY          ,
                                    LAST_UPDATE_DATE         ,
                                    LAST_UPDATE_LOGIN
                                  )
                                  VALUES (
                                         l_comment_id                          ,
                                   UPPER(p_lgcy_trncmt_rec.comment_type_code)  ,
                                         p_lgcy_trncmt_rec.comment_txt         ,
                                         l_person_id                           ,
                                   UPPER(p_lgcy_trncmt_rec.program_cd)         ,
                                   UPPER(p_lgcy_trncmt_rec.program_type)       ,
                                   UPPER(p_lgcy_trncmt_rec.award_cd)           ,
                                   UPPER(l_load_cal_type)                      ,
                                         l_load_sequence_number                ,
                                   UPPER(p_lgcy_trncmt_rec.unit_set_cd)        ,
                                         p_lgcy_trncmt_rec.us_version_number   ,
                                         l_uoo_id                              ,
                                     NVL(FND_GLOBAL.USER_ID, -1)               ,
                                         SYSDATE                               ,
                                     NVL(FND_GLOBAL.USER_ID,-1)                ,
                                         SYSDATE                               ,
                                     NVL(FND_GLOBAL.LOGIN_ID,-1)
                                 );


    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
        commit;
    END IF;

    FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,  p_data  => x_msg_data);


    EXCEPTION
          WHEN WARN_TYPE_ERR THEN
                  ROLLBACK TO create_trncmt;
                  x_return_status := 'W';
                  FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);
          WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO create_trncmt;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO create_trncmt;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);
          WHEN OTHERS THEN
                  ROLLBACK TO create_trncmt;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                  FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
                  FND_MSG_PUB.ADD;
                  FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data  => x_msg_data);

  END create_trncmt ;


END igs_as_trncmt_lgcy_pub;

/
