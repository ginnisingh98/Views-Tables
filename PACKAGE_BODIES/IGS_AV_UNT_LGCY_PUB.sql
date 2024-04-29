--------------------------------------------------------
--  DDL for Package Body IGS_AV_UNT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_UNT_LGCY_PUB" AS
/* $Header: IGSPAV2B.pls 120.7 2006/05/31 06:43:04 sepalani ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_AV_UNT_LGCY_PUB';

    PROCEDURE mydebug (p_msg IN VARCHAR2)
      -- this procedure will be used to debug
    IS
    BEGIN
      null;
    END mydebug;


FUNCTION validate_ref_code (
   p_av_stnd_unit_id     IN   igs_av_stnd_unit_all.av_stnd_unit_id%TYPE,
   p_reference_code_id   IN   igs_ge_ref_cd.reference_code_id%TYPE
)
   RETURN BOOLEAN
IS
   CURSOR c_untref_cd
   IS
      SELECT 1
        FROM igs_av_unt_ref_cds
       WHERE av_stnd_unit_id = p_av_stnd_unit_id
         AND reference_code_id = p_reference_code_id;

   x_return_status   BOOLEAN := TRUE;
BEGIN

--    Primary key validation
   OPEN c_untref_cd;

   IF c_untref_cd%FOUND
   THEN
      fnd_message.set_name ('IGS', 'IGS_AV_UNT_REF_PK_EXISTS ');
      fnd_msg_pub.ADD;
      x_return_status := FALSE;
      mydebug ('validate_unt_bss_db_cons IGS_AV_UNT_REF_PK_EXISTS ');
   END IF;
   CLOSE c_untref_cd;
   RETURN x_return_status;
END validate_ref_code;


    PROCEDURE initialise ( p_lgcy_adstunt_rec IN OUT NOCOPY lgcy_adstunt_rec_type )
    IS
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              initialise                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Initialise the advanced standing lgcy_adstunt_rec_type record|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |          IN/ OUT:   p_lgcy_adstunt_rec                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | jhanda   11-Nov-2002 Created                                              |
 | kdande   03-Jan-2002 Changed "IGS_AV_STUNT_INST_UID_NOT_NULL" to          |
 |                      IGS_AV_STUT_INST_UID_NOT_NULL                        |
 |                      Changed "IGS_AV_LYENR_NOTGT_CURYR " to               |
 |                      "IGS_AV_LYENR_NOTGT_CURYR"                           |
 |                                                                           |
 | nalkumar 10-Dec-2003 Bug# 3270446 RECR50 Build; Obsoleted the	     |
 |			IGS_AV_STND_UNIT.CREDIT_PERCENTAGE column.           |
 | sepalani 31-May-2006 Bug #5254238 IGSQUSRM:LEGACY LOAD AV STDNG IMPORTS   |
 |			INVALID REFERENCE CODE/TYPE WITHOUT ERROR	     |
 |                                                                           |
 +===========================================================================*/
    BEGIN
      p_lgcy_adstunt_rec.person_number                  :=    null;
      p_lgcy_adstunt_rec.program_cd                     :=    null;
      p_lgcy_adstunt_rec.total_exmptn_approved          :=    null;
      p_lgcy_adstunt_rec.total_exmptn_granted           :=    null;
      p_lgcy_adstunt_rec.total_exmptn_perc_grntd        :=    null;
      p_lgcy_adstunt_rec.exemption_institution_cd       :=    null;
      p_lgcy_adstunt_rec.unit_cd                        :=    null;
      p_lgcy_adstunt_rec.version_number                 :=    null;
      p_lgcy_adstunt_rec.approved_dt                    :=    null;
      p_lgcy_adstunt_rec.authorising_person_number      :=    null;
      p_lgcy_adstunt_rec.prog_group_ind                 :=    null;
      p_lgcy_adstunt_rec.granted_dt                     :=    null;
      p_lgcy_adstunt_rec.expiry_dt                      :=    null;
      p_lgcy_adstunt_rec.cancelled_dt                   :=    null;
      p_lgcy_adstunt_rec.revoked_dt                     :=    null;
      p_lgcy_adstunt_rec.comments                       :=    null;
      p_lgcy_adstunt_rec.credit_percentage              :=    null;
      p_lgcy_adstunt_rec.s_adv_stnd_granting_status     :=    null;
      p_lgcy_adstunt_rec.s_adv_stnd_recognition_type    :=    null;
      p_lgcy_adstunt_rec.load_cal_alt_code              :=    null;
      p_lgcy_adstunt_rec.grading_schema_cd              :=    null;
      p_lgcy_adstunt_rec.grd_sch_version_number         :=    null;
      p_lgcy_adstunt_rec.grade                          :=    null;
      p_lgcy_adstunt_rec.achievable_credit_points       :=    null;
      p_lgcy_adstunt_rec.prev_unit_cd                   :=    null;
      p_lgcy_adstunt_rec.prev_term                      :=    null;
      p_lgcy_adstunt_rec.tst_admission_test_type        :=    null;
      p_lgcy_adstunt_rec.tst_test_date                  :=    null;
      p_lgcy_adstunt_rec.test_segment_name              :=    null;
      p_lgcy_adstunt_rec.alt_unit_cd                    :=    null;
      p_lgcy_adstunt_rec.alt_version_number             :=    null;
      p_lgcy_adstunt_rec.optional_ind                   :=    null;
      p_lgcy_adstunt_rec.basis_program_type             :=    null;
      p_lgcy_adstunt_rec.basis_year                     :=    null;
      p_lgcy_adstunt_rec.basis_completion_ind           :=    null;
      p_lgcy_adstunt_rec.reference_cd_type		:=    null;
      p_lgcy_adstunt_rec.reference_cd			:=    null;
      p_lgcy_adstunt_rec.applied_program_cd		:=    null;
    END initialise;


  FUNCTION validate_parameters(
                               p_lgcy_adstunt_rec IN LGCY_ADSTUNT_REC_TYPE
                               )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_parameters                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function checks all the mandatory parameters for the    |
 |                passed record type are not null ,and adds error messages to|
 |                the stack for all the parameters.                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                            |
 |                      p_lgcy_adstunt_rec                                   |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created 					     |
 +===========================================================================*/
    l_b_return_val BOOLEAN DEFAULT TRUE;
    l_s_message_name VARCHAR2(30);
  BEGIN

    mydebug('Inside validate_parameters');

    IF    p_lgcy_adstunt_rec.person_number    IS NULL THEN
        l_s_message_name := 'IGS_EN_PER_NUM_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.program_cd    IS NULL THEN
        l_s_message_name := 'IGS_EN_PRGM_CD_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.total_exmptn_approved    IS NULL THEN
        l_s_message_name := 'IGS_AV_TOT_EXMPT_APPR_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.total_exmptn_granted    IS NULL THEN
        l_s_message_name := 'IGS_AV_TOT_EXMPT_GRNT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.total_exmptn_perc_grntd    IS NULL THEN
        l_s_message_name := 'IGS_AV_TOT_EXT_PER_GRNT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.exemption_institution_cd    IS NULL THEN
        l_s_message_name := 'IGS_AV_ADLVL_EX_INS_CD_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.unit_cd    IS NULL THEN
        l_s_message_name := 'IGS_AV_UNIT_CD_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.version_number     IS NULL THEN
        l_s_message_name := 'IGS_AV_UNIT_VER_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.s_adv_stnd_granting_status     IS NULL THEN
        l_s_message_name := 'IGS_AV_ADLVL_GRNT_STAT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.approved_dt    IS NULL THEN
        l_s_message_name := 'IGS_AV_ADLVL_APPR_DT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.authorising_person_number    IS NULL THEN
        l_s_message_name := 'IGS_AV_ADLV_AUTH_PERNUM_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;
    IF    p_lgcy_adstunt_rec.s_adv_stnd_recognition_type    IS NULL THEN
        l_s_message_name := 'IGS_AV_STUNT_RG_TYP_NOT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;

    IF p_lgcy_adstunt_rec.prev_unit_cd IS NOT NULL AND
       (p_lgcy_adstunt_rec.prev_term IS NULL OR
	    p_lgcy_adstunt_rec.start_date  IS NULL OR
		p_lgcy_adstunt_rec.end_date  IS NULL OR
		    p_lgcy_adstunt_rec.institution_cd  IS NULL
	   )THEN
        l_s_message_name := 'IGS_AV_PREV_UNT_DET_NOT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;

    IF p_lgcy_adstunt_rec.tst_admission_test_type  IS NOT NULL AND
               ( p_lgcy_adstunt_rec.tst_test_date IS NULL OR p_lgcy_adstunt_rec.test_segment_name IS NULL) THEN
        l_s_message_name := 'IGS_AV_TST_ADM_DET_NOT_NULL';
        l_b_return_val :=FALSE;
           FND_MESSAGE.SET_NAME('IGS', l_s_message_name);
           FND_MSG_PUB.ADD;
    END IF;

   IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type <> 'PRECLUSION' AND
      (
       p_lgcy_adstunt_rec.alt_unit_cd        IS NOT NULL OR
       p_lgcy_adstunt_rec.alt_version_number IS NOT NULL
      )
    THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_CRD_ALT_BOTH_EXISTS');
       FND_MSG_PUB.ADD;
       l_b_return_val := FALSE;
    END IF;

    /*
        validate that when advanced standing granting status if granted -> revoked and cancelled  dates are null
        when advanced standing granting status if revoked then granted and cancelled  dates are null
        when advanced standing granting status if cancelled then revoked and granted  dates are null
     */
    IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'GRANTED' AND
          (p_lgcy_adstunt_rec.revoked_dt    IS NOT NULL OR
	     p_lgcy_adstunt_rec.cancelled_dt    IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        l_b_return_val := FALSE;
    END IF;

    IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'CANCELLED' AND
          (p_lgcy_adstunt_rec.revoked_dt    IS NOT NULL OR
	     p_lgcy_adstunt_rec.granted_dt    IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        l_b_return_val := FALSE;
    END IF;

    IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'REVOKED' AND
          (p_lgcy_adstunt_rec.granted_dt    IS NOT NULL OR
	     p_lgcy_adstunt_rec.cancelled_dt    IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        l_b_return_val := FALSE;
    END IF;
    mydebug('Comming Out Of validate_parameters' || l_s_message_name );
    RETURN l_b_return_val;
  END validate_parameters;


 FUNCTION derive_unit_data(
        p_lgcy_adstunt_rec              IN OUT NOCOPY          lgcy_adstunt_rec_type,
        p_person_id                     OUT    NOCOPY          igs_pe_person.person_id%TYPE,
        p_s_adv_stnd_type               OUT    NOCOPY          igs_av_stnd_unit_all. s_adv_stnd_type%TYPE,
        p_cal_type                      OUT    NOCOPY          igs_ca_inst.cal_type%TYPE,
        p_seq_number                    OUT    NOCOPY          igs_ca_inst. sequence_number%TYPE,
        p_auth_pers_id                  OUT    NOCOPY          igs_pe_person.person_id%TYPE,
        p_unit_details_id               OUT    NOCOPY          igs_ad_term_unitdtls.unit_details_id%TYPE,
        p_tst_rslt_dtls_id              OUT    NOCOPY          igs_ad_tst_rslt_dtls .tst_rslt_dtls_id%TYPE,
        p_as_version_number             OUT    NOCOPY          igs_en_stdnt_ps_att.version_number%TYPE,
        p_reference_code_id		OUT    NOCOPY          igs_ge_ref_cd.reference_code_id%TYPE
       )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              derive_unit_data                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function derives advanced standing unit level data      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_lgcy_adstunt_rec                                     |
 |                OUT:                                                       |
 |                p_lgcy_adstunt_rec                                         |
 |                p_person_id                                                |
 |                p_s_adv_stnd_type                                          |
 |                p_cal_type                                                 |
 |                p_seq_number                                               |
 |                p_auth_pers_id                                             |
 |                p_unit_details_id                                          |
 |                p_tst_rslt_dtls_id                                         |
 |                p_as_version_number                                        |
 |                                                                           |
 |                                                                           |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
  l_n_rec_count NUMBER :=0 ;

  CURSOR c_unit_details_id (  cp_unit             igs_ad_term_unitdtls.unit%TYPE,
                              cp_prev_term        igs_av_lgcy_lvl_int.prev_term%TYPE,
                              cp_start_date       igs_av_lgcy_lvl_int.start_date%TYPE,
                              cp_end_date         igs_av_lgcy_lvl_int.end_date%TYPE,
                              cp_person_id        igs_pe_person.person_id%TYPE,
                              cp_institution_code igs_av_acad_history_v.institution_code%TYPE
                             ) IS
        SELECT  ahv.unit_details_id
        FROM    igs_av_acad_history_v ahv,
                igs_ad_term_details   td
        WHERE   ahv.term_details_id = td.term_details_id
             AND     ahv.term=td.term
             AND     td.term = cp_prev_term
             AND     trunc(td.start_date) = cp_start_date
             AND     trunc(td.end_date) = cp_end_date
             AND     ahv.unit = cp_unit
             AND     ahv.person_id = cp_person_id
             AND     ahv.institution_code = cp_institution_code ;


  CURSOR c_tst_rslt_dtls_id (cp_admission_test_type
         igs_ad_test_results.admission_test_type%TYPE,
       cp_test_date            igs_ad_test_results.test_date%TYPE,
       cp_test_segment_name
       igs_ad_test_segments.test_segment_name%TYPE,
       cp_person_id            igs_ad_test_results.person_id%TYPE) IS
        SELECT  b.tst_rslt_dtls_id
        FROM    igs_ad_test_results a,
                igs_ad_tst_rslt_dtls b,
         igs_ad_test_segments c
        WHERE   a.test_results_id = b.test_results_id
		AND     c.admission_test_type  = cp_admission_test_type
        AND     b.test_segment_id = c.test_segment_id
        AND     a.admission_test_type = cp_admission_test_type
        AND     a.test_date           = cp_test_date
        AND     c.test_segment_name   = cp_test_segment_name
        AND     a.person_id           = cp_person_id;
  CURSOR c_credit_points ( cp_unit_cd p_lgcy_adstunt_rec.UNIT_CD%TYPE , cp_version_number igs_en_stdnt_ps_att.version_number%TYPE) IS
      SELECT nvl(achievable_credit_points ,enrolled_credit_points) credit_points
      FROM igs_ps_unit_ver
      WHERE unit_cd=cp_unit_cd and version_number = cp_version_number ;

  CURSOR c_ref_id (p_reference_cd_type igs_ge_ref_cd.reference_cd_type%TYPE , p_reference_cd igs_ge_ref_cd.reference_cd%TYPE) IS
  SELECT reference_code_id
    FROM igs_ge_ref_cd
  WHERE reference_cd_type = p_reference_cd_type
    AND reference_cd = p_reference_cd;

  l_reference_code_id  igs_ge_ref_cd.reference_code_id%TYPE :=null;

  l_count  NUMBER := 0;
  l_start_dt igs_ad_term_details.start_date%TYPE;
  l_end_dt igs_ad_term_details.end_date%TYPE;
  l_return_status VARCHAR2(1000);

  BEGIN
  p_s_adv_stnd_type := 'UNIT'; -- initialise
  p_person_id := IGS_GE_GEN_003.get_person_id(p_lgcy_adstunt_rec.person_number );
  mydebug('Got person ID as ' || p_person_id);
  IF p_person_id IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
       FND_MSG_PUB.ADD;
    RETURN FALSE;
  END IF;

  IF p_lgcy_adstunt_rec.load_cal_alt_code IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
       FND_MSG_PUB.ADD;
    RETURN FALSE;
  END IF;

   mydebug('Calling  IGS_GE_GEN_003.get_calendar_instance ' || p_cal_type || p_lgcy_adstunt_rec.load_cal_alt_code);
  igs_ge_gen_003.get_calendar_instance(p_alternate_cd => p_lgcy_adstunt_rec.load_cal_alt_code ,
                                       p_s_cal_category=>'''LOAD''',
                                       p_cal_type => p_cal_type,
                                       p_ci_sequence_number => p_seq_number ,
                                       p_start_dt => l_start_dt ,
                                       p_end_dt => l_end_dt ,
                                       p_return_status => l_return_status );
  mydebug('Got p_cal_type as ' || p_cal_type || ' and p_seq_number as' || p_seq_number);
  -- IF 0 or more load calendars are found
  IF p_seq_number IS NULL OR p_cal_type IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
       FND_MSG_PUB.ADD;
    RETURN FALSE;
  END IF;

  p_auth_pers_id := igs_ge_gen_003.get_person_id(p_lgcy_adstunt_rec.authorising_person_number );

  mydebug('Got p_auth_pers_id as ' || p_auth_pers_id);
  OPEN c_unit_details_id(p_lgcy_adstunt_rec.PREV_UNIT_CD ,p_lgcy_adstunt_rec.prev_term ,
                         p_lgcy_adstunt_rec.start_date , p_lgcy_adstunt_rec.end_date ,
                         p_person_id , p_lgcy_adstunt_rec.institution_cd );
  LOOP
      FETCH c_unit_details_id INTO p_unit_details_id;
      EXIT WHEN c_unit_details_id%NOTFOUND;
      l_n_rec_count := c_unit_details_id%ROWCOUNT;
  END LOOP;
  CLOSE c_unit_details_id;
  mydebug('******Got p_unit_details_id as ' || p_unit_details_id);

  IF l_n_rec_count = 0 OR l_count >=2 THEN
     p_unit_details_id := NULL;
  END IF;
  mydebug('Got p_unit_details_id as ' || p_unit_details_id);

  OPEN  c_tst_rslt_dtls_id(p_lgcy_adstunt_rec.tst_admission_test_type,
                           p_lgcy_adstunt_rec.tst_test_date,
                           p_lgcy_adstunt_rec.test_segment_name,
                           p_person_id);
  LOOP
      FETCH c_tst_rslt_dtls_id INTO p_tst_rslt_dtls_id;
      EXIT WHEN c_tst_rslt_dtls_id%NOTFOUND;
      l_n_rec_count := c_tst_rslt_dtls_id%ROWCOUNT;
  END LOOP;
  CLOSE c_tst_rslt_dtls_id;
  mydebug('Got p_tst_rslt_dtls_id as ' || p_tst_rslt_dtls_id);

 -- set p_unit_details_id in case no data or too many rows
    IF l_n_rec_count = 0 OR l_count >=2 THEN
        p_tst_rslt_dtls_id := NULL;
    END IF;
 -- Get the program version number
    p_as_version_number := igs_ge_gen_003.get_program_version(  p_person_id => p_person_id ,  p_program_cd => p_lgcy_adstunt_rec.program_cd );
    mydebug('Got p_as_version_number as ' || p_as_version_number);

  -- Default p_lgcy_adstunt_rec.achievable_credit_points
  IF p_lgcy_adstunt_rec.achievable_credit_points IS NULL THEN
      OPEN c_credit_points(p_lgcy_adstunt_rec.unit_cd , p_lgcy_adstunt_rec.version_number);
      FETCH c_credit_points INTO p_lgcy_adstunt_rec.achievable_credit_points;
      CLOSE c_credit_points;
  END IF;
  mydebug('Got p_achievable_credit_points as ' || p_lgcy_adstunt_rec.achievable_credit_points);

  -- calculate the value for  p_ reference_code_id  as

    OPEN  c_ref_id(p_lgcy_adstunt_rec.reference_cd_type,
			   p_lgcy_adstunt_rec.reference_cd);
    LOOP
      FETCH c_ref_id INTO l_reference_code_id  ;
      EXIT WHEN c_ref_id%NOTFOUND;
      l_n_rec_count := c_ref_id%ROWCOUNT;
    END LOOP;
    CLOSE c_ref_id;

    IF p_lgcy_adstunt_rec.reference_cd_type IS NOT NULL AND l_reference_code_id IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_PS_NO_OPEN_REFCDTYPE_EXIS');
       FND_MSG_PUB.ADD;
       RETURN FALSE;
  END IF;
  p_reference_code_id :=l_reference_code_id;
  mydebug('Got p_reference_code_id as ' || l_reference_code_id);

  RETURN TRUE;
  END derive_unit_data;


  FUNCTION validate_unit_basis(
        p_person_id             IN    igs_pe_person.person_id%TYPE,
        p_version_number        IN    igs_ps_ver_all.version_number%TYPE,
        p_lgcy_adstunt_rec      IN    lgcy_adstunt_rec_type
        )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_unit_basis                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                            |
 |                      p_version_number                                     |
 |                      p_lgcy_adstunt_rec                                   |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
    l_b_return_val BOOLEAN:=TRUE;
    l_message_name VARCHAR2(30);
    l_return_type VARCHAR2(100);
  BEGIN
--    Validate that the value in the BASIS_YEAR is not more than the current year
  IF NOT igs_av_val_asuleb.advp_val_basis_year(
                                          p_basis_year     => p_lgcy_adstunt_rec.basis_year,
                                          p_course_cd      => p_lgcy_adstunt_rec.program_cd,
                                          p_version_number => p_version_number,
                                          p_message_name   => l_message_name,
                                          p_return_type    => l_return_type
                                          ) THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_LYENR_NOTGT_CURYR');
       FND_MSG_PUB.ADD;
    l_b_return_val:=FALSE;
  END IF;

    RETURN l_b_return_val;
  END validate_unit_basis;

  FUNCTION validate_adv_std_db_cons(
        p_version_number       IN    igs_ps_ver_all.version_number%TYPE,
        p_lgcy_adstunt_rec     IN    lgcy_adstunt_rec_type
        )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_adv_std_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                            |
 |                      p_version_number                                     |
 |                      p_lgcy_adstunt_rec                                   |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
  x_return_status  BOOLEAN :=TRUE;
  BEGIN
     x_return_status := TRUE;
	 mydebug('Before igs_ps_ver_pkg.get_pk_for_validation ' );
     IF NOT igs_ps_ver_pkg.get_pk_for_validation
               (
                         x_course_cd      => p_lgcy_adstunt_rec.program_cd,
                         x_version_number => p_version_number
               ) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_PRG_CD_NOT_EXISTS');
      FND_MSG_PUB.ADD;
          x_return_status := FALSE;
     END IF;
     mydebug('Inside validate_adv_std_db_cons Got x_return_status as ' );
     return x_return_status;
  END validate_adv_std_db_cons;

  FUNCTION validate_adv_stnd(
        p_person_id            IN    igs_pe_person.person_id%TYPE,
        p_version_number       IN    igs_ps_ver_all.version_number%TYPE,
        p_lgcy_adstunt_rec     IN    lgcy_adstunt_rec_type
       )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_adv_stnd                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                            |
 |                      p_version_number                                     |
 |                      p_lgcy_adstunt_rec                                   |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;
     /*
        check whether person is deceased or not
     */
     DECLARE
        CURSOR c_ind (cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
           SELECT deceased_ind
           FROM   igs_pe_hz_parties
           WHERE  party_id = cp_party_id;
    l_ind  igs_pe_hz_parties.deceased_ind%TYPE;
     BEGIN
        OPEN  c_ind (p_person_id);
    FETCH c_ind INTO l_ind;
    CLOSE c_ind;
    IF upper(l_ind) = 'Y' THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_PERSON_DECEASED');
         FND_MSG_PUB.ADD;
         x_return_status := FALSE;
        END IF;
    mydebug ('l_ind :'||l_ind);
     END;
     /*
        check whether exemtion_inst_cd is valid or not
     */
     DECLARE
        CURSOR c_validate_inst(cp_exemption_institution_cd p_lgcy_adstunt_rec.exemption_institution_cd%TYPE) IS
		  SELECT 'x'
		  FROM hz_parties hp, igs_pe_hz_parties ihp
		 WHERE hp.party_id = ihp.party_id
		   AND ihp.inst_org_ind = 'I'
		   AND ihp.oi_govt_institution_cd IS NOT NULL
		   AND ihp.oi_institution_status = 'ACTIVE'
		   AND ihp.oss_org_unit_cd = cp_exemption_institution_cd;
     BEGIN
         OPEN c_validate_inst(p_lgcy_adstunt_rec.exemption_institution_cd);
	    IF c_validate_inst%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_STND_EXMPT_INVALID');
              FND_MSG_PUB.ADD;
              x_return_status := FALSE;
	    END IF;
	 CLOSE c_validate_inst;
	 mydebug (' exemption_inst_cd');
     END;
     /*
        check whether program_cd is valid or not
     */
     DECLARE
        l_message_name VARCHAR2(2000);
     BEGIN
        IF NOT igs_av_val_as.advp_val_as_crs
            (
               p_person_id      => p_person_id,
               p_course_cd      => p_lgcy_adstunt_rec.program_cd,
               p_version_number => p_version_number,
               p_message_name   => l_message_name
             ) THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_HE_EXT_SPA_DTL_NOT_FOUND');
         FND_MSG_PUB.ADD;
           x_return_status := FALSE;
     END IF;
     END;
     /*
        validation for exemption credit points
     */
     DECLARE
       CURSOR c_local_inst_ind (cp_ins_cd igs_or_institution.institution_cd%type) IS
               SELECT  ins.local_institution_ind
               FROM    igs_or_institution ins
               WHERE   ins.institution_cd = cp_ins_cd;
       CURSOR cur_program_exempt_totals (
                   cp_course_cd      igs_ps_ver.course_cd%type,
                   cp_version_number igs_ps_ver.version_number%type,
           cp_local_ind      VARCHAR2) IS
         SELECT  DECODE (cp_local_ind, 'N', NVL (cv.external_adv_stnd_limit, -1),
                        NVL (cv.internal_adv_stnd_limit, -1)) adv_stnd_limit
         FROM    igs_ps_ver cv
         WHERE   cv.course_cd    = cp_course_cd
         AND     cv.version_number   = cp_version_number;
        rec_cur_program_exempt_totals cur_program_exempt_totals%ROWTYPE;
        rec_local_inst_ind c_local_inst_ind%ROWTYPE;
        l_message_name fnd_new_messages.message_name%TYPE;
     BEGIN
     OPEN c_local_inst_ind (p_lgcy_adstunt_rec.exemption_institution_cd);
     FETCH c_local_inst_ind INTO rec_local_inst_ind;
         IF (c_local_inst_ind%NOTFOUND) THEN
           rec_local_inst_ind.local_institution_ind := 'N';
         END IF;
     CLOSE c_local_inst_ind;
     IF (rec_local_inst_ind.local_institution_ind = 'N') THEN
       l_message_name := 'IGS_AV_EXCEEDS_PRGVER_EXT_LMT';
     ELSE
       l_message_name := 'IGS_AV_EXCEEDS_PRGVER_INT_LMT';
     END IF;
     OPEN cur_program_exempt_totals (
        p_lgcy_adstunt_rec.program_cd,
        p_version_number,
        rec_local_inst_ind.local_institution_ind);
     FETCH cur_program_exempt_totals INTO rec_cur_program_exempt_totals;
     CLOSE cur_program_exempt_totals;
     IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
          IF p_lgcy_adstunt_rec.total_exmptn_approved < 0 OR
         p_lgcy_adstunt_rec.total_exmptn_approved > rec_cur_program_exempt_totals.adv_stnd_limit THEN
                 FND_MESSAGE.SET_NAME('IGS',l_message_name);
               FND_MSG_PUB.ADD;
                 x_return_status := FALSE;
          END IF;
     END IF;
         IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
           IF p_lgcy_adstunt_rec.total_exmptn_granted < 0 OR
         p_lgcy_adstunt_rec.total_exmptn_granted > rec_cur_program_exempt_totals.adv_stnd_limit THEN
                 FND_MESSAGE.SET_NAME('IGS',l_message_name);
               FND_MSG_PUB.ADD;
                 x_return_status := FALSE;
           END IF;
         END IF;
     END;
     /*
        check the course_attempt_status
     */
     DECLARE
        CURSOR c_exists (cp_person_id    igs_en_stdnt_ps_att.person_id%TYPE,
                     cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE ) IS
           SELECT 'x'
           FROM   igs_en_stdnt_ps_att
           WHERE  person_id = cp_person_id
           AND    course_cd = cp_course_cd
           AND    course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT','UNCONFIRM','DISCONTIN','COMPLETED');
     l_exists VARCHAR2(1);
     BEGIN
         OPEN c_exists (p_person_id,
                    p_lgcy_adstunt_rec.program_cd);
         FETCH c_exists INTO l_exists;
     IF c_exists%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_PRG_ATTMPT_INVALID');
            FND_MSG_PUB.ADD;
            x_return_status := FALSE;
     END IF;
     CLOSE c_exists;
     END;
     return x_return_status;

  END validate_adv_stnd;

  FUNCTION validate_std_unt_db_cons(
        p_lgcy_adstunt_rec                IN  lgcy_adstunt_rec_type,
        p_person_id                       IN igs_pe_person.person_id%TYPE,
        p_s_adv_stnd_type                 IN igs_av_stnd_unit_all. s_adv_stnd_type %TYPE,
        p_cal_type                        IN igs_ca_inst.cal_type%TYPE,
        p_seq_number                      IN igs_ca_inst. sequence_number%TYPE,
        p_auth_pers_id                    IN igs_pe_person.person_id%TYPE,
        p_unit_details_id                 IN igs_ad_term_unitdtls. unit_details_id%TYPE,
        p_tst_rslt_dtls_id                IN igs_ad_tst_rslt_dtls .tst_rslt_dtls_id%TYPE,
        p_as_version_number               IN igs_en_stdnt_ps_att.version_number%TYPE,
        p_av_stnd_unit_lvl_id             OUT NOCOPY igs_av_stnd_unit_all.av_stnd_unit_id%TYPE
          )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_std_unt_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                 This function performs all the data integrity validation  |
 |                before entering into the table  IGS_AV_STND_UNIT_ ALL and  |
 |                keeps adding error message to stack as an when it encounters.|                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_lgcy_adstunt_rec                                      |
 |                OUT: p_person_id                                           |
 |                     p_s_adv_stnd_type                                     |
 |                     p_cal_type                                            |
 |                     p_seq_number                                          |
 |                     p_auth_pers_number                                    |
 |                     p_unit_details_id                                     |
 |                     p_tst_rslt_dtls_id                                    |
 |                     p_as_version_number                                   |
 |                     p_av_stnd_unit_lvl_id                                 |
 |                                                                           |
 |                                                                           |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
  x_return_status BOOLEAN := TRUE;
  l_c_tmp_msg VARCHAR2(30);
  l_av_stnd_unit_lvl_id igs_av_stnd_unit_all.av_stnd_unit_id%TYPE;
  CURSOR c_igs_av_stnd_unit_seq IS
  		 select igs_av_stnd_unit_s.nextval from dual ;

  BEGIN

  OPEN c_igs_av_stnd_unit_seq ;
  FETCH c_igs_av_stnd_unit_seq INTO l_av_stnd_unit_lvl_id;
  CLOSE c_igs_av_stnd_unit_seq;

  mydebug('***** Got l_av_stnd_unit_lvl_id=' ||l_av_stnd_unit_lvl_id);
--    Primary key validation
  IF igs_av_stnd_unit_pkg.get_pk_for_validation(x_av_stnd_unit_id => l_av_stnd_unit_lvl_id) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STDUNT_ALREADY_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_AV_STND_UNIT_PKG.GET_PK_FOR_VALIDATION ');
     RETURN x_return_status;
  ELSE
       p_av_stnd_unit_lvl_id :=l_av_stnd_unit_lvl_id;
  END IF;
  mydebug('**p_av_stnd_unit_lvl_id=' || p_av_stnd_unit_lvl_id || 'l_av_stnd_unit_lvl_id=' ||l_av_stnd_unit_lvl_id);
 --    Foreign Key with Table IGS_AD_TERM_UNITDTLS

  IF p_unit_details_id IS NULL AND
           p_lgcy_adstunt_rec.prev_unit_cd IS NOT NULL AND
         p_lgcy_adstunt_rec.prev_term IS NOT NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_TERM_UNTDTLS_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons p_unit_details_id ');
  END IF;
-- Foreign Key with Table IGS_AD_TST_RSLT_DTLS
  IF p_tst_rslt_dtls_id IS NULL AND p_lgcy_adstunt_rec.tst_admission_test_type  IS NOT NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADM_TST_RSLT_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons p_tst_rslt_dtls_id ');
  END IF;
--    Foreign Key with Table IGS_AV_ADV_STANDING_PKG
  IF NOT igs_av_adv_standing_pkg.get_pk_for_validation(
                                                x_person_id                => p_person_id ,
                                                x_course_cd                => p_lgcy_adstunt_rec.program_cd,
                                                x_version_number           => p_as_version_number ,
                                                x_exemption_institution_cd => p_lgcy_adstunt_rec.exemption_institution_cd
                                               ) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_NO_ADV_STND_DET_EXIST');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION ');
  END IF;
  --    Foreign Key with AUTHORIZING_PERSON_ID exists in table IGS_PE_PERSON
  IF p_auth_pers_id  IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_INVALID_PERS_AUTH_NUM');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons p_auth_pers_id ');
  END IF;
  --     Valid s_adv_granting_status exists
  IF NOT igs_lookups_view_pkg.get_pk_for_validation(
                                                    x_lookup_type => 'ADV_STND_GRANTING_STATUS',
                                                    x_lookup_code => p_lgcy_adstunt_rec.s_adv_stnd_granting_status)  THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_CANNOT_DTR_GRNT_STAT');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_LOOKUPS_VIEW_PKG.GET_PK_FOR_VALIDATION ');
  END IF;

 --   Foreign Key with Table IGS_PS_UNIT_VER
 IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
                                                      x_unit_cd        => p_lgcy_adstunt_rec.unit_cd,
                                                      x_version_number =>  p_lgcy_adstunt_rec.version_number
                                                   )  THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADV_STUNT_UNIT_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_PS_UNIT_VER_PKG.GET_PK_FOR_VALIDATION ');
  END IF;

  --     Foreign Key with Table IGS_AS_GRD_SCH_GRADE

  IF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (    x_grading_schema_cd => p_lgcy_adstunt_rec.grading_schema_cd,
                                                             x_version_number    => p_lgcy_adstunt_rec.grd_sch_version_number,
                                                             x_grade             => p_lgcy_adstunt_rec.grade
                                                        )  THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADV_STUNT_GRD_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_AS_GRD_SCH_GRADE_PKG.GET_PK_FOR_VALIDATION ');
  END IF;

 --    Validate that the record parameter S_Adv_Stnd_Recognition_Type cannot have any other values other than 'CREDIT','EXEMPTION' or 'PRECLUSION'

  IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type NOT IN ('CREDIT' , 'EXEMPTION' , 'PRECLUSION') THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_RECOG_VALUE');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons P_LGCY_ADSTUNT_REC.S_ADV_STND_RECOGNITION_TYPE ');
  END IF;
  --    Check constraint on PROG_GROUP_IND
  IF p_lgcy_adstunt_rec.prog_group_ind <> upper(p_lgcy_adstunt_rec.prog_group_ind ) AND
       p_lgcy_adstunt_rec.prog_group_ind NOT IN ('Y' , 'N') THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_CRS_GRP_IN_Y_N');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons P_LGCY_ADSTUNT_REC.PROG_GROUP_IND ');
  END IF;
  --    Check that if institution_cd is NOT NULL and unit_details_id is NULL
  IF p_lgcy_adstunt_rec.institution_cd IS NOT NULL AND
       p_unit_details_id IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUT_INST_UID_NOT_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons P_LGCY_ADSTUNT_REC.EXEMPTION_INSTITUTION_CD ');
  END IF;

  -- Validate that both institution_cd and tst_rslt_dtls_id are not nulls
  IF p_lgcy_adstunt_rec.institution_cd IS NOT NULL AND
       p_tst_rslt_dtls_id IS NOT NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_INST_RLID_BOTH_NOT_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons P_LGCY_ADSTUNT_REC.EXEMPTION_INSTITUTION_CD ');
  END IF;
  -- One and only one of unit details or test result details must be entered (both cannot be Not Nulls simultaneously
  IF p_unit_details_id     IS NULL AND
       p_tst_rslt_dtls_id IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_UID_RSID_ATLEAST_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_std_unt_db_cons IGS_AV_UID_RSID_ATLEAST_NULL ');
  END IF;

  RETURN x_return_status;
  END validate_std_unt_db_cons;

  FUNCTION validate_unit(
        p_lgcy_adstunt_rec            IN lgcy_adstunt_rec_type,
        p_person_id                   IN igs_pe_person.person_id%TYPE,
        p_s_adv_stnd_type             IN igs_av_stnd_unit_all. s_adv_stnd_type %TYPE,
        p_cal_type                    IN igs_ca_inst.cal_type%TYPE,
        p_seq_number                  IN igs_ca_inst. sequence_number%TYPE,
        p_auth_pers_id                IN igs_pe_person.person_id%TYPE,
        p_unit_details_id             IN igs_ad_term_unitdtls. unit_details_id%TYPE,
        p_tst_rslt_dtls_id            IN igs_ad_tst_rslt_dtls .tst_rslt_dtls_id%TYPE,
        p_as_version_number           IN igs_en_stdnt_ps_att.version_number%TYPE
          )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_unit                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function performs all the business validations before   |
 |                inserting a record into the table  IGS_AV_STND_UNIT_ALL and|
 |                keeps adding error message to stack as an when it encounters.|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_lgcy_adstunt_rec                                   |
 |                      p_person_id                                          |
 |                      p_s_adv_stnd_type                                    |
 |                      p_cal_type                                           |
 |                      p_seq_number                                         |
 |                      p_auth_pers_number                                   |
 |                      p_unit_details_id                                    |
 |                      p_tst_rslt_dtls_id                                   |
 |                      p_as_version_number                                  |
 |                                                                           |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
      x_return_status BOOLEAN := TRUE;
      l_total_exmptn_approved p_lgcy_adstunt_rec.total_exmptn_approved%TYPE ;
      l_total_exmptn_granted p_lgcy_adstunt_rec.total_exmptn_granted%TYPE ;
      l_total_exmptn_perc_grntd p_lgcy_adstunt_rec.total_exmptn_perc_grntd%TYPE ;
      l_message_name VARCHAR2(30);
  BEGIN
 /*
      Validate that the approved date is greater than current date
 */
  IF p_lgcy_adstunt_rec.approved_dt >= SYSDATE THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_APRVDT_LE_CURDT');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
  END IF;

  IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type = 'PRECLUSION' AND
     p_lgcy_adstunt_rec.achievable_credit_points <> 0.00 THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_CREDIT_PRECL_IS_ZERO');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_CREDIT_PRECL_IS_ZERO   ');
  END IF;
  IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type = 'PRECLUSION' AND
     p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'GRANTED' THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_NOT_GRT_PRE');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_NOT_GRT_PRE   ');
  END IF;

 IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'EXPIRED' AND
     p_lgcy_adstunt_rec.expiry_dt IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_EXPDT_TOBE_SET');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_STUNT_EXPDT_TOBE_SET');
  END IF;


  IF NOT igs_av_val_asu.advp_val_as_totals(
                                      p_person_id                   => p_person_id,
                                      p_course_cd                   => p_lgcy_adstunt_rec.program_cd ,
                                      p_version_number              => p_as_version_number  ,
                                      p_include_approved            => TRUE ,
                                      p_asu_unit_cd                 => p_lgcy_adstunt_rec.unit_cd ,
                                      p_asu_version_number          => p_lgcy_adstunt_rec.version_number ,
                                      p_asu_advstnd_granting_status => p_lgcy_adstunt_rec.s_adv_stnd_granting_status ,
                                      p_asul_unit_level             => NULL ,
                                      p_asul_exmptn_institution_cd  => p_lgcy_adstunt_rec.exemption_institution_cd ,
                                      p_asul_advstnd_granting_status=> p_lgcy_adstunt_rec.s_adv_stnd_granting_status ,
                                      p_total_exmptn_approved       => l_total_exmptn_approved ,
                                      p_total_exmptn_granted        => l_total_exmptn_granted ,
                                      p_total_exmptn_perc_grntd     => l_total_exmptn_perc_grntd ,
                                      p_message_name                => l_message_name,
                                      p_unit_details_id             => p_unit_details_id ,
                                      p_tst_rslt_dtls_id            => p_tst_rslt_dtls_id
                                        ) THEN
     FND_MESSAGE.SET_NAME('IGS',l_message_name);
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_VAL_ASU.ADVP_VAL_AS_TOTALS ');
  END IF;

--    Check for person hold
  IF NOT igs_en_val_encmb.enrp_val_excld_prsn(
                                              p_person_id    => p_person_id ,
                                              p_course_cd    => p_lgcy_adstunt_rec.program_cd,
                                              p_effective_dt => p_lgcy_adstunt_rec.granted_dt,
                                              p_message_name => l_message_name
                                         ) THEN
     FND_MESSAGE.SET_NAME('IGS',l_message_name);
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_EN_VAL_ENCMB.ENRP_VAL_EXCLD_PRSN ');
  END IF;


  IF p_as_version_number    IS NULL AND
     p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'GRANTED' THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_GRANTED_STUDPRG_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_GRANTED_STUDPRG_EXISTS   ');
  END IF;

  IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'GRANTED' AND
       p_lgcy_adstunt_rec.granted_dt    IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_GRANTDT_NOT_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_STUNT_GRANTDT_NOT_NULL');
  END IF;

  IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'CANCELLED' AND
       p_lgcy_adstunt_rec.cancelled_dt    IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_CANCDT_NOT_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_STUNT_CANCDT_NOT_NULL');
  END IF;

  IF p_lgcy_adstunt_rec.s_adv_stnd_granting_status = 'REVOKED' AND
       p_lgcy_adstunt_rec.revoked_dt    IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_REVDT_NOT_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_STUNT_REVDT_NOT_NULL');
  END IF;

  IF NOT igs_av_val_asu.advp_val_approved_dt(
                                                p_approved_dt => p_lgcy_adstunt_rec.approved_dt ,
                                                p_expiry_dt => p_lgcy_adstunt_rec.expiry_dt ,
                                                p_message_name => l_message_name
                                                 ) THEN
     FND_MESSAGE.SET_NAME('IGS',l_message_name);
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_VAL_ASU.ADVP_VAL_APPROVED_DT ');
  END IF;
  --    Validate whether the Granted Date, Cancelled Date Or Revoked Dates are greater than or equal to the Approved date
  IF NOT  (
             igs_av_val_asu.advp_val_as_aprvd_dt(
                                                  p_approved_dt => p_lgcy_adstunt_rec.approved_dt ,
                                                  p_related_dt => p_lgcy_adstunt_rec.granted_dt ,
                                                  p_message_name => l_message_name
                                                 ) AND
             igs_av_val_asu.advp_val_as_aprvd_dt(
                                                 p_approved_dt => p_lgcy_adstunt_rec.approved_dt ,
                                                 p_related_dt => p_lgcy_adstunt_rec.cancelled_dt ,
                                                 p_message_name => l_message_name
                                                ) AND
             igs_av_val_asu.advp_val_as_aprvd_dt(
                                                 p_approved_dt => p_lgcy_adstunt_rec.approved_dt ,
                                                 p_related_dt => p_lgcy_adstunt_rec.revoked_dt ,
                                                 p_message_name => l_message_name
                                                )
         )THEN

     FND_MESSAGE.SET_NAME('IGS','IGS_AV_DTASSO_LE_APPRVDT' );
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_VAL_ASU.ADVP_VAL_APRVD_DT ');
  END IF;

 IF NOT igs_ad_val_acai.genp_val_staff_prsn(
                                              p_person_id =>  p_auth_pers_id ,
                                              p_message_name => l_message_name
                                           ) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_GE_NOT_STAFF_MEMBER');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_GE_NOT_STAFF_MEMBER ');
  END IF;

 IF  p_lgcy_adstunt_rec.achievable_credit_points IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_CRD_PER_CANNOT_BE_NULL');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_CRD_PER_CANNOT_BE_NULL  ');
  END IF;

     /*
        check the course_attempt_status
     */
     DECLARE
        CURSOR c_exists (cp_person_id    igs_en_stdnt_ps_att.person_id%TYPE,
                     cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE ) IS
           SELECT 'x'
           FROM   igs_en_stdnt_ps_att
           WHERE  person_id = cp_person_id
           AND    course_cd = cp_course_cd
           AND    course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT','UNCONFIRM','DISCONTIN','COMPLETED');
     l_exists VARCHAR2(1);
     BEGIN
         OPEN c_exists (p_person_id,
                    p_lgcy_adstunt_rec.program_cd);
         FETCH c_exists INTO l_exists;
     IF c_exists%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_PRG_ATTMPT_INVALID');
            FND_MSG_PUB.ADD;
            mydebug('validate_unit IGS_AV_PRG_ATTMPT_INVALID  ');
            x_return_status := FALSE;
     END IF;
     CLOSE c_exists;
     END;
  RETURN x_return_status;
  END validate_unit;


  FUNCTION create_post_unit(
             p_person_id              IN  igs_pe_person.person_id%type,
                p_course_version      IN  igs_ps_ver.version_number%type,
             p_unit_details_id        IN  igs_ad_term_unitdtls. unit_details_id%type,
             p_tst_rslt_dtls_id       IN  igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
             p_lgcy_adstunt_rec       IN  lgcy_adstunt_rec_type
       )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              create_post_unit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                            |
 |                      p_lgcy_adstunt_rec                                   |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
     x_return_status  BOOLEAN :=TRUE;
     l_message VARCHAR2(2000);
     l_total_exmptn_approved        igs_av_adv_standing_all.total_exmptn_approved%TYPE ;
     l_total_exmptn_granted         igs_av_adv_standing_all.total_exmptn_granted%TYPE ;
     l_total_exmptn_perc_grntd      igs_av_adv_standing_all.total_exmptn_perc_grntd%TYPE ;
  BEGIN
     x_return_status := TRUE;
     mydebug ('in create_post_unit');
     /*
         Validate whether the advanced standing approved / granted has not
     exceeded the advanced standing internal or external limits of
     the Program version
     */
     IF NOT igs_av_val_asu.advp_val_as_totals(
                        p_person_id                    => p_person_id,
                        p_course_cd                    => p_lgcy_adstunt_rec.program_cd,
                        p_version_number               => p_course_version,
                        p_include_approved             => TRUE,
                        p_asu_unit_cd                  => p_lgcy_adstunt_rec.unit_cd,
                        p_asu_version_number           => p_lgcy_adstunt_rec.version_number,
                        p_asu_advstnd_granting_status  => p_lgcy_adstunt_rec.s_adv_stnd_granting_status,
                        p_asul_unit_level              => NULL ,
                        p_asul_exmptn_institution_cd   => p_lgcy_adstunt_rec.exemption_institution_cd,
                        p_asul_advstnd_granting_status => p_lgcy_adstunt_rec.s_adv_stnd_granting_status,
                        p_total_exmptn_approved        => l_total_exmptn_approved,
                        p_total_exmptn_granted         => l_total_exmptn_granted,
                        p_total_exmptn_perc_grntd      => l_total_exmptn_perc_grntd,
                        p_message_name                 => l_message,
                        p_unit_details_id              => p_unit_details_id,
                        p_tst_rslt_dtls_id             => p_tst_rslt_dtls_id,
			p_asu_exmptn_institution_cd    => p_lgcy_adstunt_rec.exemption_institution_cd
                       ) THEN
          FND_MESSAGE.SET_NAME('IGS',l_message);
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
     ELSE  -- function returns TRUE
       /*
        update IGS_AV_ADV_STANDING_ALL  with above obtained values for
        total_exmptn_approved, total_exmptn_granted   and total_exmptn_perc_grntd
       */
       UPDATE igs_av_adv_standing_all
       SET    total_exmptn_approved        = l_total_exmptn_approved,
              total_exmptn_granted         = l_total_exmptn_granted,
              total_exmptn_perc_grntd      = l_total_exmptn_perc_grntd
       WHERE  person_id                    = p_person_id
       AND    course_cd                    = p_lgcy_adstunt_rec.program_cd
       AND    version_number               = p_course_version
       AND    exemption_institution_cd     = p_lgcy_adstunt_rec.exemption_institution_cd;
     END IF;
     mydebug ('out create_post_lvl');
     return x_return_status;
  END create_post_unit;


  FUNCTION validate_alt_unt_db_cons(
                                  p_lgcy_adstunt_rec      IN     LGCY_ADSTUNT_REC_TYPE,
                                  p_av_stnd_unit_id       IN     IGS_AV_STND_UNIT_ALL.AV_STND_UNIT_ID%TYPE   ,
                                  p_s_adv_stnd_type       IN     IGS_AV_STND_UNIT_ALL.S_ADV_STND_TYPE%TYPE   ,
	                          p_person_id             IN     IGS_PE_PERSON.PERSON_ID%TYPE                ,
	                          p_unit_details_id       IN     IGS_AD_TERM_UNITDTLS.UNIT_DETAILS_ID%TYPE   ,
	                          p_tst_rslt_dtls_id      IN     IGS_AD_TST_RSLT_DTLS.TST_RSLT_DTLS_ID%TYPE  ,
                                  p_as_version_number     IN     IGS_AV_STND_UNIT_ALL.AS_VERSION_NUMBER%TYPE ,
				  p_av_stnd_unit_lvl_id   OUT  NOCOPY  IGS_AV_STND_ALT_UNIT.AV_STND_UNIT_ID%TYPE    ,
	                          x_return_status         OUT  NOCOPY   VARCHAR2
                                  )
   RETURN BOOLEAN
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_alt_unt_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This function performs all the data integrity validation     |
 |                before entering into the table  IGS_AV_STND_UNIT_ ALL and  |
 |                keeps adding error message to stack as an when it encounters.|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_lgcy_adstunt_rec                                   |
 |                      p_av_stnd_unit_id                                    |
 |                      p_s_adv_stnd_type                                    |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/

IS

    CURSOR cur_get_adv_stnd_id (    cp_person_id           NUMBER,
                                    cp_institution_cd      VARCHAR2,
                                    cp_unit_details_id     NUMBER,
                                    cp_tst_rslt_dtls_id    NUMBER,
                                    cp_unit_cd             VARCHAR2,
                                    cp_as_course_cd        VARCHAR2,
                                    cp_as_version_number   NUMBER
       )IS
        SELECT
	          av_stnd_unit_id
        FROM
		  igs_av_stnd_unit_all
        WHERE
		  person_id                 = cp_person_id                  AND
		  NVL(institution_cd,0)     = NVL(cp_institution_cd,0) 	   	AND
          NVL(tst_rslt_dtls_id,0)   = NVL(cp_tst_rslt_dtls_id,0)   	AND
		  NVL(unit_details_id,0)    = NVL(cp_unit_details_id,0)     AND
		  unit_cd                   = cp_unit_cd 		            AND
		  as_course_cd              = cp_as_course_cd 		        AND
		  as_version_number         = cp_as_version_number ;

    l_av_stnd_unit_lvl_id      IGS_AV_STND_UNIT_ALL.AV_STND_UNIT_ID%TYPE;
    l_return_status BOOLEAN DEFAULT TRUE;
  BEGIN
    -- Initialise x_return_status to 'S'
    x_return_status  := 'S';

    -- Foreign key and Primary key validation
    OPEN cur_get_adv_stnd_id (
                cp_person_id           =>   p_person_id                        ,
				cp_institution_cd      =>   p_lgcy_adstunt_rec.institution_cd  ,
			    cp_unit_details_id     =>   p_unit_details_id                  ,
				cp_tst_rslt_dtls_id    =>   p_tst_rslt_dtls_id                 ,
				cp_unit_cd             =>   p_lgcy_adstunt_rec.unit_cd         ,
				cp_as_course_cd        =>   p_lgcy_adstunt_rec.program_cd      ,
				cp_as_version_number   =>   p_as_version_number
			     );
    FETCH cur_get_adv_stnd_id INTO l_av_stnd_unit_lvl_id;
    IF cur_get_adv_stnd_id%NOTFOUND THEN
      -- foreign key with table igs_av_stnd_unit_all does not exist.
      FND_MESSAGE.SET_NAME('IGS','IGS_AV_UNT_ALT_ID_FK_EXISTS');
      FND_MSG_PUB.ADD;
      x_return_status := 'E';
      l_return_status := FALSE;
    ELSE
      -- av_stnd_unit_lvl_id found in table igs_av_stnd_unit_all
      -- check primary in table igs_av_std_alt_unit
      IF igs_av_stnd_alt_unit_pkg.get_pk_for_validation(
                                                         x_av_stnd_unit_id    => l_av_stnd_unit_lvl_id,
                                                         x_alt_unit_cd        => p_lgcy_adstunt_rec.alt_unit_cd,
                                                         x_alt_version_number => p_lgcy_adstunt_rec.alt_version_number
                                                        )THEN
        CLOSE cur_get_adv_stnd_id;
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_STDUNT_ALREADY_EXISTS');
        FND_MSG_PUB.ADD;
        x_return_status := 'W';
        l_return_status := FALSE;
        RETURN (l_return_status) ;
      END IF;
      p_av_stnd_unit_lvl_id := l_av_stnd_unit_lvl_id;
    END IF;
    CLOSE cur_get_adv_stnd_id;

  IF NOT IGS_PS_UNIT_VER_PKG.GET_PK_FOR_VALIDATION(
                                                   x_unit_cd =>p_lgcy_adstunt_rec.unit_cd ,
                                                   x_version_number => p_lgcy_adstunt_rec.version_number
                                                   )THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_UNT_ALT_UID_FK_EXISTS');
     FND_MSG_PUB.ADD;
      x_return_status := 'E';
      l_return_status := FALSE;
     mydebug('validate_unit IGS_AV_UNT_ALT_UID_FK_EXISTS ');
  END IF;

  IF p_lgcy_adstunt_rec.OPTIONAL_IND NOT IN ('Y' , 'N') THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_ALT_OPT_IND_IN_Y_N');
     FND_MSG_PUB.ADD;
      x_return_status := 'E';
      l_return_status := FALSE;
     mydebug('validate_unit IGS_AV_ALT_OPT_IND_IN_Y_N ');
  END IF;

  RETURN ( l_return_status );

  END validate_alt_unt_db_cons;


  FUNCTION validate_alt_unit(
        p_lgcy_adstunt_rec   IN     lgcy_adstunt_rec_type,
        p_av_stnd_unit_id    IN     igs_av_stnd_unit_all.av_stnd_unit_id%TYPE,
        p_s_adv_stnd_type    IN     igs_av_stnd_unit_all.s_adv_stnd_type %TYPE
          )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_alt_unit                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Validate that the advanced standing unit code is not         |
 |                same as the Alternate Unit Code                            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_lgcy_adstunt_rec                                   |
 |                      p_av_stnd_unit_id                                    |
 |                      p_s_adv_stnd_type                                    |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
     x_return_status  BOOLEAN :=TRUE;
     l_message_name VARCHAR2(30);
  BEGIN
--    Validate that the advanced standing unit code is not same as the Alternate Unit Code
  IF NOT igs_av_val_asau.advp_val_prclde_unit(
                                              p_precluded_unit_cd => p_lgcy_adstunt_rec.unit_cd ,
                                              p_alternate_unit_cd => p_lgcy_adstunt_rec.alt_unit_cd ,
                                              p_message_name      => l_message_name
                                              ) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_ALTUNIT_DIFF_UNITASSOC');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unit IGS_AV_ALTUNIT_DIFF_UNITASSOC ');
  END IF;
  RETURN x_return_status;
  END validate_alt_unit;


  FUNCTION validate_unt_bss_db_cons(
        p_lgcy_adstunt_rec   IN     lgcy_adstunt_rec_type,
        p_av_stnd_unit_id    IN     igs_av_stnd_unit_all.av_stnd_unit_id%TYPE,
        p_s_adv_stnd_type    IN     igs_av_stnd_unit_all.s_adv_stnd_type %TYPE
      )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_unt_bss_db_cons                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                 This function performs all the data integrity validation  |
 |                before entering into the table  IGS_AV_STD_UNT_BASIS_ALL and |
 |                keeps adding error message to stack as an when it encounters.|                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_lgcy_adstunt_rec                                   |
 |                      p_av_stnd_unit_id                                    |
 |                      p_s_adv_stnd_type                                    |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 |    jhanda    01-07-2003  Changed for Bug 2743009                          |
 |    swaghmar  19-10-2005  Changed for Bug 4676359
 +===========================================================================*/
     x_return_status  BOOLEAN := TRUE;
  BEGIN
--    Primary key validation
  IF igs_av_std_unt_basis_pkg.get_pk_for_validation(
                                                      x_av_stnd_unit_id =>p_av_stnd_unit_id
                                                   ) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_UNT_BAS_PK_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_UNT_BAS_PK_EXISTS ');
  END IF;

--    Check Foreign key Validation with the table IGS_AV_STND_UNIT_ALL
  IF NOT IGS_AV_STND_UNIT_PKG.GET_PK_FOR_VALIDATION( x_av_stnd_unit_id => p_av_stnd_unit_id) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_UNT_ALT_ID_FK_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_UNT_ALT_ID_FK_EXISTS ');
  END IF;

 -- Check passed  BASIS_PROGRAM_TYPE for x_course_type
 IF ((p_lgcy_adstunt_rec.basis_program_type IS NOT NULL) AND NOT igs_ps_type_pkg.get_pk_for_validation(
								      x_course_type =>p_lgcy_adstunt_rec.basis_program_type
								      )) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_BAS_CRS_TYP_FK_EXISTS');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_BAS_CRS_TYP_FK_EXISTS  ');
  END IF;
  --    Validate that the record parameter basis_year has a value greater than 1900 and less than 2100
  IF ((p_lgcy_adstunt_rec.basis_year IS NOT NULL) AND (p_lgcy_adstunt_rec.basis_year < 1900 OR
					             p_lgcy_adstunt_rec.basis_year > 2100))    THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_BAS_YEAR_1900_2100');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_BAS_YEAR_1900_2100 ');
  END IF;
  --    Validate that the value for the record parameter Basis_completion_Ind field cannot be anything other than 'Y' or 'N'
  IF ((p_lgcy_adstunt_rec.basis_completion_ind IS NOT NULL) AND (NOT  p_lgcy_adstunt_rec.basis_completion_ind IN ('Y','N'))) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_BAS_COMP_IND_IN_Y_N');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_BAS_COMP_IND_IN_Y_N  ');
  END IF;
  RETURN x_return_status;
  END validate_unt_bss_db_cons;


  FUNCTION validate_un1t_basis(
        p_lgcy_adstunt_rec    IN     lgcy_adstunt_rec_type,
        p_av_stnd_unit_id     IN     igs_av_stnd_unit_all.av_stnd_unit_id%TYPE,
        p_s_adv_stnd_type     IN     igs_av_stnd_unit_all.s_adv_stnd_type %TYPE
       )RETURN BOOLEAN IS
/*===========================================================================+
 | FUNCTION                                                                  |
 |              validate_un1t_basis                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                 This function performs all the data integrity validation  |
 |                before entering into the table  IGS_AV_STD_UNT_BASIS_ALL and |
 |                keeps adding error message to stack as an when it encounters.|                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_lgcy_adstunt_rec                                   |
 |                      p_av_stnd_unit_id                                    |
 |                      p_s_adv_stnd_type                                    |
 | RETURNS    :       x_return_value                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
     x_return_status  BOOLEAN :=TRUE;
     l_message_name VARCHAR2(30);
     l_return_type VARCHAR2(300);
  BEGIN
  --    Validate that the value in the BASIS_YEAR is not more than the current year
  IF igs_av_val_asuleb.advp_val_basis_year(
                          p_basis_year     => p_lgcy_adstunt_rec.basis_year ,
                          p_course_cd      => p_lgcy_adstunt_rec.program_cd ,
                          p_version_number => p_lgcy_adstunt_rec.version_number ,
                          p_message_name   => l_message_name,
                          p_return_type    => l_return_type )  THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_AV_LYENR_NOTGT_CURYR');
     FND_MSG_PUB.ADD;
     x_return_status := FALSE;
     mydebug('validate_unt_bss_db_cons IGS_AV_LYENR_NOTGT_CURYR');
  END IF;
  RETURN x_return_status;
  END validate_un1t_basis;


  PROCEDURE create_adv_stnd_unit
        (p_api_version                 IN NUMBER,
         p_init_msg_list               IN VARCHAR2 ,
         p_commit                      IN VARCHAR2 ,
         p_validation_level            IN VARCHAR2 ,
         p_lgcy_adstunt_rec            IN OUT NOCOPY lgcy_adstunt_rec_type,
         x_return_status               OUT    NOCOPY VARCHAR2,
         x_msg_count                   OUT    NOCOPY NUMBER,
         x_msg_data                    OUT    NOCOPY VARCHAR2
        )
  IS
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_adv_stnd_unit                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates advanced standing unit                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_lgcy_adstunt_rec                                     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   jhanda    11-11-2002  Created                                           |
 |   shimitta  9-11-2005   Modified BUG#472377: optional_ind set to N if null|
 |   swaghmar  14-11-2005  Bug# 4723760 -Added check IF l_reference_code_id  |
 |					IS NOT NULL			     |
 +===========================================================================*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'create_adv_stnd_unit';
    l_api_version                   CONSTANT  NUMBER  := 1.0;
    l_ret_status                    BOOLEAN;
    l_b_av_stnd_alt_unit_pk_exist   BOOLEAN := TRUE;
    l_person_id               igs_pe_person.person_id%TYPE;
    l_s_adv_stnd_type         igs_av_stnd_unit_all. s_adv_stnd_type%TYPE;
    l_cal_type                igs_ca_inst.cal_type%TYPE;
    l_seq_number              igs_ca_inst. sequence_number%TYPE;
    l_auth_pers_id            igs_pe_person.person_id%TYPE;
    l_unit_details_id         igs_ad_term_unitdtls.unit_details_id%TYPE;
    l_tst_rslt_dtls_id        igs_ad_tst_rslt_dtls .tst_rslt_dtls_id%TYPE;
    l_as_version_number       igs_en_stdnt_ps_att.version_number%TYPE;
    l_av_stnd_unit_lvl_id     igs_av_stnd_unit_all.av_stnd_unit_id%TYPE;
    L_REQUEST_ID              igs_av_stnd_unit_all.request_id%TYPE ;
    L_PROGRAM_ID              igs_av_stnd_unit_all.program_id%TYPE ;
    L_PROGRAM_APPLICATION_ID  igs_av_stnd_unit_all.program_application_id%TYPE;
    L_PROGRAM_UPDATE_DATE     igs_av_stnd_unit_all.program_update_date%TYPE;
    duplicate_record_exists   EXCEPTION;
    l_reference_code_id       igs_ge_ref_cd.reference_code_id%TYPE;
    l_AVU_REFERENCE_CD_ID     IGS_AV_UNT_REF_CDS.AVU_REFERENCE_CD_ID%TYPE;

    CURSOR c_unit_ref_id is
      select IGS_AV_UNT_REF_CDS_S.nextval from dual;

  BEGIN
     mydebug('ENTERED create_adv_stnd_unit ');
  --Standard start of API savepoint
        SAVEPOINT create_adv_stnd_unit;

  --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                    l_api_version,
                    p_api_version,
                    l_api_name,
                    G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

  --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/*==================== Start Your coding here==========*/

/*					  Initialise  	 				   */
	p_lgcy_adstunt_rec.prog_group_ind              := upper(p_lgcy_adstunt_rec.prog_group_ind);
	p_lgcy_adstunt_rec.program_cd                  := upper(p_lgcy_adstunt_rec.program_cd);
	p_lgcy_adstunt_rec.unit_cd                     := upper(p_lgcy_adstunt_rec.unit_cd)	;
	p_lgcy_adstunt_rec.s_adv_stnd_granting_status  := upper(p_lgcy_adstunt_rec.s_adv_stnd_granting_status);
	p_lgcy_adstunt_rec.exemption_institution_cd    := upper(p_lgcy_adstunt_rec.exemption_institution_cd);
	p_lgcy_adstunt_rec.s_adv_stnd_recognition_type := upper(p_lgcy_adstunt_rec.s_adv_stnd_recognition_type);
	p_lgcy_adstunt_rec.optional_ind	               := upper(nvl(p_lgcy_adstunt_rec.optional_ind,'N')); --shimitta
 	p_lgcy_adstunt_rec.alt_unit_cd                 := upper(p_lgcy_adstunt_rec.alt_unit_cd);


    IF validate_parameters(
                           p_lgcy_adstunt_rec =>p_lgcy_adstunt_rec
                           )THEN
            mydebug('Before derive_unit_data');
        IF     derive_unit_data(
                                p_lgcy_adstunt_rec             => p_lgcy_adstunt_rec ,
                                p_person_id                    => l_person_id    ,
                                p_s_adv_stnd_type              => l_s_adv_stnd_type ,
                                p_cal_type                     => l_cal_type,
                                p_seq_number                   => l_seq_number,
                                p_auth_pers_id                 => l_auth_pers_id,
                                p_unit_details_id              => l_unit_details_id ,
                                p_tst_rslt_dtls_id             => l_tst_rslt_dtls_id,
                                p_as_version_number            => l_as_version_number,
         			p_reference_code_id           => l_reference_code_id
                            ) THEN
            mydebug('*****l_unit_details_id='||l_unit_details_id);
            mydebug('Before validate_adv_std_db_cons');
            IF     validate_adv_std_db_cons(
                                        p_version_number     =>    l_as_version_number,
                                        p_lgcy_adstunt_rec   =>    p_lgcy_adstunt_rec
                                        ) THEN
                mydebug('Before validate_adv_stnd');
                IF     validate_adv_stnd(
                                        p_person_id          =>    l_person_id    ,
                                        p_version_number     =>    l_as_version_number,
                                        p_lgcy_adstunt_rec   =>    p_lgcy_adstunt_rec
                                      ) THEN
                    mydebug('Before IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION');
                    --    Validate that  the current record is already present in the tables IGS_AV_ADV_STANDING_ALL and IGS_AV_STND_UNIT_ALL
                    IF  NOT igs_av_adv_standing_pkg.get_pk_for_validation(
                                                                          x_person_id                => l_person_id,
                                                                          x_course_cd                => p_lgcy_adstunt_rec.program_cd ,
                                                                          x_version_number           => l_as_version_number,
                                                                          x_exemption_institution_cd => p_lgcy_adstunt_rec.exemption_institution_cd
                                                                      ) THEN
                                mydebug('***** INSERT INTO IGS_AV_ADV_STANDING_ALL *****');
                                INSERT INTO igs_av_adv_standing_all(person_id,
                                                                    created_by,
                                                                    creation_date,
                                                                    last_updated_by,
                                                                    last_update_date,
                                                                    last_update_login,
                                                                    course_cd,
                                                                    version_number,
                                                                    total_exmptn_approved,
                                                                    total_exmptn_granted,
                                                                    total_exmptn_perc_grntd,
                                                                    exemption_institution_cd ,
                                                                    org_id
                                                                    ) VALUES (
                                                                                l_person_id,
                                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                                SYSDATE         ,
                                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                                SYSDATE         ,
                                                                                NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                                upper(p_lgcy_adstunt_rec.program_cd)    ,
                                                                                l_as_version_number,
                                                                                p_lgcy_adstunt_rec.total_exmptn_approved ,
                                                                                p_lgcy_adstunt_rec.total_exmptn_granted,
                                                                                p_lgcy_adstunt_rec.total_exmptn_perc_grntd,
                                                                                p_lgcy_adstunt_rec.exemption_institution_cd ,
                                                                                igs_ge_gen_003.get_org_id()
                                                                    );
                    END IF;    --IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION
                        mydebug('Before IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION');
                        IF     NOT IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION(
                                                                           x_person_id          => l_person_id,
                                                                           x_exemption_institution_cd     => p_lgcy_adstunt_rec.exemption_institution_cd,
                                                                           x_unit_details_id    => l_unit_details_id,
                                                                           x_tst_rslt_dtls_id   => l_tst_rslt_dtls_id,
                                                                           x_unit_cd            => p_lgcy_adstunt_rec.unit_cd,
                                                                           x_as_course_cd       => p_lgcy_adstunt_rec.program_cd,
                                                                           x_as_version_number  => l_as_version_number,
									   x_version_number     => p_lgcy_adstunt_rec.version_number,
									   x_s_adv_stnd_type    => l_s_adv_stnd_type
                                                                         ) THEN
                            mydebug('Before validate_std_unt_db_cons');
                            mydebug('**** l_unit_details_id='||l_unit_details_id);
                            IF validate_std_unt_db_cons(
                                                        p_lgcy_adstunt_rec    => p_lgcy_adstunt_rec,
                                                        p_person_id           => l_person_id,
                                                        p_s_adv_stnd_type     => l_s_adv_stnd_type,
                                                        p_cal_type            => l_cal_type,
                                                        p_seq_number          => l_seq_number,
                                                        p_auth_pers_id        => l_auth_pers_id,
                                                        p_unit_details_id     => l_unit_details_id,
                                                        p_tst_rslt_dtls_id    => l_tst_rslt_dtls_id,
                                                        p_as_version_number   => l_as_version_number,
                                                        p_av_stnd_unit_lvl_id =>  l_av_stnd_unit_lvl_id
                                                       ) THEN
                                mydebug('Before validate_unit');
                               IF validate_unit(
                                                p_lgcy_adstunt_rec       => p_lgcy_adstunt_rec,
                                                p_person_id              => l_person_id,
                                                p_s_adv_stnd_type        => l_s_adv_stnd_type,
                                                p_cal_type               => l_cal_type,
                                                p_seq_number             => l_seq_number,
                                                p_auth_pers_id           => l_auth_pers_id,
                                                p_unit_details_id        => l_unit_details_id,
                                                p_tst_rslt_dtls_id       => l_tst_rslt_dtls_id,
                                                p_as_version_number      => l_as_version_number
                                                ) THEN
                                     IF p_lgcy_adstunt_rec.prog_group_ind is null THEN
                                        mydebug(' INSERT INTO IGS_AV_STND_UNIT_ALL N');
                                        p_lgcy_adstunt_rec.prog_group_ind :='N';
                                     END IF;

                                  mydebug(' INSERT INTO IGS_AV_STND_UNIT_ALL lgcy_adstunt_rec.prog_group_ind ');

                                L_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID ;
                                L_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID ;
                                L_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID ;

                                if (L_REQUEST_ID = -1) then
                                   L_REQUEST_ID := NULL ;
                                   L_PROGRAM_ID := NULL ;
                                   L_PROGRAM_APPLICATION_ID := NULL ;
                                   L_PROGRAM_UPDATE_DATE := NULL ;
                                else
                                   L_PROGRAM_UPDATE_DATE := SYSDATE ;
                                end if ;
                                   mydebug('***** l_av_stnd_unit_lvl_id=' || l_av_stnd_unit_lvl_id);
                                  INSERT INTO igs_av_stnd_unit_all(
                                                                    person_id,
                                                                    as_course_cd,
                                                                    as_version_number,
                                                                    s_adv_stnd_type,
                                                                    unit_cd,
                                                                    version_number,
                                                                    s_adv_stnd_granting_status,
                                                                    approved_dt,
                                                                    authorising_person_id,
                                                                    crs_group_ind,
                                                                    exemption_institution_cd,
                                                                    granted_dt,
                                                                    expiry_dt,
                                                                    cancelled_dt,
                                                                    revoked_dt,
                                                                    comments,
                                                                    /* credit_percentage, */
                                                                    s_adv_stnd_recognition_type,
                                                                    org_id,
                                                                    request_id,
                                                                    program_application_id,
                                                                    program_id,
                                                                    program_update_date,
                                                                    created_by,
                                                                    creation_date,
                                                                    last_updated_by,
                                                                    last_update_date,
                                                                    last_update_login,
                                                                    av_stnd_unit_id,
                                                                    cal_type,
                                                                    ci_sequence_number,
                                                                    institution_cd,
                                                                    grading_schema_cd,
                                                                    grd_sch_version_number,
                                                                    grade,
                                                                    achievable_credit_points,
                                                                    deg_aud_detail_id,
                                                                    unit_details_id,
                                                                    tst_rslt_dtls_id
                                                                   ) VALUES (
                                                                    l_person_id,
                                                                    upper(p_lgcy_adstunt_rec.program_cd),
                                                                    l_as_version_number,
                                                                    upper(l_s_adv_stnd_type),
                                                                    upper(p_lgcy_adstunt_rec.unit_cd),
                                                                    p_lgcy_adstunt_rec.version_number,
                                                                    upper(p_lgcy_adstunt_rec.s_adv_stnd_granting_status),
                                                                    p_lgcy_adstunt_rec.approved_dt,
                                                                    l_auth_pers_id,
                                                                    upper(p_lgcy_adstunt_rec.prog_group_ind),
                                                                    upper(p_lgcy_adstunt_rec.exemption_institution_cd),
                                                                    p_lgcy_adstunt_rec.granted_dt,
                                                                    p_lgcy_adstunt_rec.expiry_dt,
                                                                    p_lgcy_adstunt_rec.cancelled_dt,
                                                                    p_lgcy_adstunt_rec.revoked_dt,
                                                                    p_lgcy_adstunt_rec.comments,
                                                                    /* p_lgcy_adstunt_rec.credit_percentage, */
                                                                    upper(p_lgcy_adstunt_rec.s_adv_stnd_recognition_type),
                                                                    igs_ge_gen_003.get_org_id(),
                                                                    l_request_id,
                                                                    l_program_application_id,
                                                                    l_program_id,
                                                                    l_program_update_date,
                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                    SYSDATE,
                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                    SYSDATE,
                                                                    NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                    l_av_stnd_unit_lvl_id,
                                                                    l_cal_type,
                                                                    l_seq_number,
                                                                    upper(p_lgcy_adstunt_rec.institution_cd),
                                                                    p_lgcy_adstunt_rec.grading_schema_cd,
                                                                    p_lgcy_adstunt_rec.grd_sch_version_number,
                                                                    p_lgcy_adstunt_rec.grade,
                                                                    p_lgcy_adstunt_rec.achievable_credit_points,
                                                                    NULL ,
                                                                    l_unit_details_id,
                                                                    l_tst_rslt_dtls_id
                                                                   );
                                    mydebug(' Inserted into IGS_AV_STND_UNIT_ALL val AV_STND_UNIT_ID =' ||l_av_stnd_unit_lvl_id);
                                   IF NOT create_post_unit(
                                                   p_person_id           => l_person_id,
                                                   p_course_version      => l_as_version_number,
                                                   p_unit_details_id     => l_unit_details_id,
                                                   p_tst_rslt_dtls_id    => l_tst_rslt_dtls_id,
                                                   p_lgcy_adstunt_rec    => p_lgcy_adstunt_rec
                                                   ) THEN
                                            mydebug('Error 2');
                                           x_return_status := FND_API.G_RET_STS_ERROR;
                                   ELSE  -- create_post_unit
				     IF l_reference_code_id IS NOT NULL THEN
					IF validate_ref_code(
                                                                  p_av_stnd_unit_id     => l_av_stnd_unit_lvl_id,
                                                                  p_reference_code_id	=>  l_reference_code_id
                                                             ) THEN
					   mydebug('INSERT INTO IGS_AV_STD_UNT_BASIS_ALL AV_STND_UNIT_ID= '|| l_av_stnd_unit_lvl_id);
					    OPEN c_unit_ref_id;
						FETCH c_unit_ref_id INTO l_AVU_REFERENCE_CD_ID;
					    CLOSE c_unit_ref_id;
					    INSERT INTO IGS_AV_UNT_REF_CDS(
									last_update_login,
									created_by,
									creation_date,
									last_updated_by,
									last_update_date,
									AVU_REFERENCE_CD_ID,
									PERSON_ID,
									AV_STND_UNIT_ID,
									REFERENCE_CODE_ID,
									APPLIED_COURSE_CD,
									DELETED_DATE
									)
								  VALUES (
									NVL(FND_GLOBAL.LOGIN_ID,-1),
									NVL(FND_GLOBAL.USER_ID,-1),
									SYSDATE,
									NVL(FND_GLOBAL.USER_ID,-1),
									SYSDATE,
									l_AVU_REFERENCE_CD_ID ,
									l_person_id,
									l_av_stnd_unit_lvl_id,
									l_REFERENCE_CODE_ID,
									p_lgcy_adstunt_rec.APPLIED_PROGRAM_CD,
									null
									);
                                           ELSE  -- validate_reference codes
                                                  x_return_status := FND_API.G_RET_STS_ERROR;
                                                  mydebug('Error 6');
                                           END IF; -- validate_ref_code
					 END IF;
                                           mydebug('Before validate_alt_unt_db_cons');
                                          IF validate_unt_bss_db_cons(
                                                                    p_lgcy_adstunt_rec    => p_lgcy_adstunt_rec,
                                                                    p_av_stnd_unit_id     => l_av_stnd_unit_lvl_id,
                                                                    p_s_adv_stnd_type     => l_s_adv_stnd_type
                                                                   ) THEN
                                            mydebug('Before validate_unit_basis');
                                           IF validate_unit_basis(
                                                                  p_person_id            => l_person_id,
                                                                  p_version_number       => l_as_version_number,
                                                                  p_lgcy_adstunt_rec     => p_lgcy_adstunt_rec
                                                                  ) THEN
                                                          mydebug('INSERT INTO IGS_AV_STD_UNT_BASIS_ALL AV_STND_UNIT_ID= '|| l_av_stnd_unit_lvl_id);
                                                             INSERT INTO igs_av_std_unt_basis_all(
							                                        last_update_login,
                                                                                                created_by,
                                                                                                creation_date,
                                                                                                last_updated_by,
                                                                                                last_update_date,
                                                                                                basis_course_type,
                                                                                                basis_year,
                                                                                                basis_completion_ind,
                                                                                                org_id,
                                                                                                av_stnd_unit_id
                                                                                                ) VALUES (
                                                                                                NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                                                SYSDATE,
                                                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                                                SYSDATE,
                                                                                                p_lgcy_adstunt_rec.basis_program_type ,
                                                                                                p_lgcy_adstunt_rec.basis_year,
                                                                                                p_lgcy_adstunt_rec.basis_completion_ind,
                                                                                                igs_ge_gen_003.get_org_id(),
                                                                                                l_av_stnd_unit_lvl_id
                                                                                                );
                                           ELSE  -- validate_unit_basis
                                                  x_return_status := FND_API.G_RET_STS_ERROR;
                                                  mydebug('Error 6');
                                           END IF; -- validate_unit_basis
                                         ELSE  -- validate_unt_bss_db_cons
                                              x_return_status := FND_API.G_RET_STS_ERROR;
                                              mydebug('Error 7');
                                        END IF; --validate_unt_bss_db_cons
                                   END IF; --create_post_unit
                                ELSE  -- validate_unit
                                  mydebug('Error 3');
                                  x_return_status := FND_API.G_RET_STS_ERROR;
                               END IF; --validate_unit
                             ELSE  -- validate_std_unt_db_cons
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              mydebug('Error 4');
                            END IF;    --validate_std_unt_db_cons
                        ELSE
			   IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type <> 'PRECLUSION' THEN
			      mydebug('****IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION and  s_adv_stnd_recognition_type <> PRECLUSION ');
                              FND_MESSAGE.SET_NAME('IGS','IGS_AV_STDUNT_ALREADY_EXISTS');
                              FND_MSG_PUB.ADD;
			      RAISE duplicate_record_exists;
			   END IF;
                        END IF;    --IGS_AV_STND_UNIT_PKG.GET_UK_FOR_VALIDATION
			mydebug('*****  Preclusion *****');
                        IF p_lgcy_adstunt_rec.s_adv_stnd_recognition_type = 'PRECLUSION' AND
                           p_lgcy_adstunt_rec.alt_unit_cd IS NOT NULL                    AND
			   p_lgcy_adstunt_rec.alt_version_number IS NOT NULL
			THEN
                           IF validate_alt_unt_db_cons(
                             p_lgcy_adstunt_rec   => p_lgcy_adstunt_rec    ,
							 p_av_stnd_unit_id    => l_av_stnd_unit_lvl_id ,
							 p_s_adv_stnd_type    => l_s_adv_stnd_type     ,
							 p_person_id          => l_person_id           ,
							 p_unit_details_id    => l_unit_details_id     ,
							 p_tst_rslt_dtls_id   => l_tst_rslt_dtls_id    ,
							 p_as_version_number  => l_as_version_number   ,
                             p_av_stnd_unit_lvl_id=> l_av_stnd_unit_lvl_id ,
							 x_return_status      => x_return_status
                                                       ) THEN

                              mydebug('Before validate_alt_unit');
                              IF validate_alt_unit(
                                                    p_lgcy_adstunt_rec   => p_lgcy_adstunt_rec,
                                                    p_av_stnd_unit_id    => l_av_stnd_unit_lvl_id,
                                                    p_s_adv_stnd_type    => l_s_adv_stnd_type
                                                   ) THEN
                                    mydebug('****  INSERT INTO IGS_AV_STND_ALT_UNIT ');
                                    INSERT INTO igs_av_stnd_alt_unit(
                                                                       last_update_login,
                                                                       created_by,
                                                                       creation_date,
                                                                       last_updated_by,
                                                                       last_update_date,
                                                                       alt_unit_cd,
                                                                       alt_version_number,
                                                                       optional_ind,
                                                                       av_stnd_unit_id
                                                                     )
                                                                      VALUES
							             (
                                                                        NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                        NVL(FND_GLOBAL.USER_ID,-1),
                                                                        SYSDATE,
                                                                        NVL(FND_GLOBAL.USER_ID,-1),
                                                                        SYSDATE,
                                                                        p_lgcy_adstunt_rec.alt_unit_cd,
                                                                        p_lgcy_adstunt_rec.alt_version_number,
                                                                        upper(p_lgcy_adstunt_rec.optional_ind),
                                                                        l_av_stnd_unit_lvl_id
                                                                     );
                              END IF; --validate_alt_unit
                           ELSE  -- validate_alt_unt_db_cons
                             mydebug('Error 5');
			     IF x_return_status = 'W' THEN
			       RAISE duplicate_record_exists;
			     ElSE
			        RAISE FND_API.G_EXC_ERROR;
			     END IF;
                           END IF; -- validate_alt_unt_db_cons
                        END IF; --l_b_av_stnd_alt_unit_pk_exist
                      ELSE  -- validate_adv_stnd
                         x_return_status := FND_API.G_RET_STS_ERROR;
              mydebug('Error 8');
            END IF;--validate_adv_stnd
        ELSE  -- validate_adv_std_db_cons
              x_return_status := FND_API.G_RET_STS_ERROR;
              mydebug('Error 9');
        END IF;    --validate_adv_std_db_cons
    ELSE  -- derive_unit_data
          x_return_status := FND_API.G_RET_STS_ERROR;
          mydebug('Error 10');
    END IF;--    derive_unit_data
  ELSE  -- validate_parameters
        x_return_status := FND_API.G_RET_STS_ERROR;
        mydebug('Error 11');
  END IF;--validate_parameters

       IF x_return_status IN (FND_API.G_RET_STS_ERROR,'E','W') THEN
            mydebug('************************  Roll Back ********************');
            ROLLBACK TO create_adv_stnd_unit;
        END IF;
/*==================== End Your coding here==========*/


  --Standard check of p_commit.

	mydebug('************************ Before  Doing a COMMIT ********************');
        IF FND_API.to_Boolean(p_commit) AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            mydebug('************************  Doing a COMMIT ********************');
            commit;
        END IF;
  --Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data);
  EXCEPTION
       WHEN DUPLICATE_RECORD_EXISTS THEN
        ROLLBACK TO create_adv_stnd_unit;
        x_return_status := 'W';
        FND_MSG_PUB.Count_And_Get(
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data
				 );
        WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK TO create_adv_stnd_unit;
            x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_adv_stnd_unit;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
        ROLLBACK TO create_adv_stnd_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_adv_stnd_unit;


END igs_av_unt_lgcy_pub;



/
