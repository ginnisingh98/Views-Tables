--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGBL_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGBL_OVERRIDE" AS
/* $Header: IGSEN77B.pls 120.5 2006/08/18 12:14:21 amuthu noship $ */

/*-----------------------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When               What
  --amuthu      29-JAN-2003        As part of bug 2744715 change the message logging format for the
  --                               this job and also truncated the date being passed to the insert row
  --                               of IGS_EN_ELGB_OVR_STEP_PKG.
  --svanukur    16-jun-2003       modified the UI and Validations associated with this job as part of
  --                               Validations ImpactCR , ENCR34, bug #2881385
  --ptandon	02-Jul-2003	   Modified the function enrp_chk_unit_over to allow unit level override
				   for multiple units/unit sections to a student in case of same unit
				   step type. Bug# 3033214
  --rvangala    11-NOV-2003        Changed query of Cursor cur_criteria_satisfied to include call to
  --                               igs_en_gen_011.match_term_sca_params and included parameters
  --                               p_load_cal_type and p_load_cal_seq

  --ckasu       18-FEB-2004        Modified enrp_elgbl_override procedure inorder to log message
                                   IGS_EN_NO_STDNT_FOUND when no data is found.Bug No 3442015

  --ckasu       11-APR-2006        Modified as a part of Sevis Build bug# 5140084.

  --ckasu       13-JUN-2006        modified as a part of bug 5299024 inorder show proper error message
  --amuthu      15-jun-2006        Modified enrp_chk_prg_over as part of bug 5335207/5330361.
  --amuthu      18-Aug-2006        Modified enrp_chk_prg_over as part of bug 5435397
  ------------------------------------------------------------------------------------------------------*/


PROCEDURE enrp_elgbl_override(
errbuf                     OUT NOCOPY VARCHAR2,
retcode                    OUT NOCOPY NUMBER,
p_trm_teach_cal_type_comb  IN  VARCHAR2,
p_program_cd_comb          IN  VARCHAR2,
p_location_cd              IN  VARCHAR2,
p_attendance_mode          IN  VARCHAR2,
p_attendance_type          IN  VARCHAR2,
p_unit_cd_comb             IN  VARCHAR2,
p_unit_set_comb            IN  VARCHAR2,
p_class_standing           IN  VARCHAR2,
p_org_unit_cd              IN  VARCHAR2,
p_person_id_group          IN  VARCHAR2,
p_person_id                IN  NUMBER,
p_program_attempt_status   IN  VARCHAR2,
p_person_step_1            IN  VARCHAR2,
p_program_step_1           IN  VARCHAR2,
p_over_credit_point_1      IN  NUMBER,
p_unit_step_1              IN  VARCHAR2,
p_unit_cd_1                IN  VARCHAR2,
p_unit_section_1           IN  NUMBER,
p_person_step_2            IN  VARCHAR2,
p_program_step_2           IN  VARCHAR2,
p_over_credit_point_2      IN  NUMBER,
p_unit_step_2              IN  VARCHAR2,
p_unit_cd_2                IN  VARCHAR2,
p_unit_section_2           IN  NUMBER,
p_person_step_3            IN  VARCHAR2,
p_program_step_3           IN  VARCHAR2,
p_unit_step_3              IN  VARCHAR2,
p_unit_cd_3                IN  VARCHAR2,
p_unit_section_3           IN  NUMBER,
p_person_step_4            IN  VARCHAR2,
p_program_step_4           IN  VARCHAR2,
p_unit_step_4              IN  VARCHAR2,
p_unit_cd_4                IN  VARCHAR2,
p_unit_section_4           IN  NUMBER,
p_person_ovr_step_1        IN  VARCHAR2,
p_unit_ovr_step_1          IN  VARCHAR2,
p_over_credit_point_3      IN  NUMBER,
p_unit_cd_ovr_1            IN  VARCHAR2,
p_unit_section_ovr_1       IN  NUMBER,
p_person_ovr_step_2        IN  VARCHAR2,
p_unit_ovr_step_2          IN  VARCHAR2,
p_over_credit_point_4      IN  NUMBER,
p_unit_cd_ovr_2            IN  VARCHAR2,
p_unit_section_ovr_2       IN  NUMBER,
p_person_ovr_step_3        IN  VARCHAR2,
p_unit_ovr_step_3          IN  VARCHAR2,
p_unit_cd_ovr_3            IN  VARCHAR2,
p_unit_section_ovr_3       IN  NUMBER,
p_person_ovr_step_4        IN  VARCHAR2,
p_unit_ovr_step_4          IN  VARCHAR2,
p_unit_cd_ovr_4            IN  VARCHAR2,
p_unit_section_ovr_4       IN  NUMBER,
p_org_id                   IN  NUMBER,
p_sevis_auth_cd            IN  VARCHAR2,
p_comments                 IN  VARCHAR2
) AS
--------------------------------------------------------------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:  This procedure will create override records to the students who satisfied the given criteria,
  --          corresponding to the all steps passed as parameters.
  --
  --   Flow of the process
  --------------------------------------
  --
  --    ENRP_ELGBL_OVERRIDE ( ** Main Function )
  --     |
  --     | Function ENRP_LOG_PARA ( ** log parameters )
  --     | Function ENRP_VAL_PARA ( ** Validate parameters )
  --     |   LOOP for all students
  --     |     Igs_En_Elgb_Ovr_Pkg.insert_row (** If not exists )
  --     |     Procedure ENRP_INS_STEP_OVER ( ** create override records for all steps passed )
  --              | Procedure enrp_chk_pers_over/enrp_chk_prg_over/enrp_chk_unit_over ( ** based on the step type different call)
  --                      | Igs_En_Gen_015.validation_step_is_overridden ( ** whether step is overriden )
  --                      | Igs_En_Elgb_Ovr_Step_Pkg.insert_row ( ** create override record for the step )
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When               What
  --kkillams    05-11-2002         As part of sevis build two new parameters p_sevis_auth_cd and p_comments are added.
  --                               bug no # 2641905
  --svanukur    17-APR-2003        As part of bug #2744699, modified the parameters entered in the log file. Also used messages for prompts in the
  --                               log file instead of hard coded values for NLS compliance.
  --                               created cursors cur_person_id_grp, cur_person_id, cur_step and variable l_step to populate
  --                               the log file.
  --rvangala    11-NOV-2003        Changed query of Cursor cur_criteria_satisfied to include call to
  --                               igs_en_gen_011.match_term_sca_params
  --ckasu       18-FEB-2004        Variable l_not_found was initialised to FALSE and code was changed inorder to log a Message
  --                               'No Student was selected for given Criteria' when no data was found for Override record Processing
  --                               as a part of bug 3442015
  ---------------------------------------------------------------------------------------------------------------------------------------

 CURSOR cur_elgb_over(p_person_id NUMBER,p_cal_type VARCHAR2,p_ci_seq_number NUMBER)IS
 SELECT elgb_override_id
 FROM igs_en_elgb_ovr
 WHERE person_id = p_person_id AND
       cal_type = p_cal_type AND
           ci_sequence_number = p_ci_seq_number;

 CURSOR cur_criteria_satisfied(p_course_cd VARCHAR2,p_course_version NUMBER,p_unit_cd VARCHAR2, p_unit_version NUMBER,
                               p_unit_set_cd VARCHAR2,p_unit_set_version NUMBER, p_org_unit_start_dt DATE,
                               p_load_cal_type VARCHAR2, p_load_cal_seq NUMBER) IS
 SELECT DISTINCT(sca.person_id) person_id
 FROM igs_en_stdnt_ps_att sca
 WHERE (p_person_id IS NULL OR
        sca.person_id = p_person_id) AND
           (p_person_id_group IS NULL OR
            EXISTS ( SELECT 'x'
                         FROM igs_pe_prsid_grp_mem pig
                                 WHERE pig.group_id = p_person_id_group AND
                                       pig.person_id = sca.person_id)) AND
       sca.course_cd LIKE NVL(p_course_cd,'%')  AND
       igs_en_gen_011.match_term_sca_params (
			sca.person_id,
			sca.course_cd,
			sca.version_number,
			sca.attendance_type,
			sca.attendance_mode,
			sca.location_cd,
			p_course_cd,
			p_course_version,
			p_attendance_type,
			p_attendance_mode,
			p_location_cd,
			p_load_cal_type,
			p_load_cal_seq) = 'Y'
	  AND
           sca.course_attempt_status LIKE NVL(p_program_attempt_status,'%') AND
           (p_unit_cd_comb IS NULL OR
            EXISTS (SELECT 'X'
                        FROM igs_en_su_attempt sua
                                WHERE sua.person_id = sca.person_id AND
                                      sua.course_cd = sca.course_cd AND
                                      sua.unit_cd = p_unit_cd AND
                                          sua.version_number = p_unit_version)) AND
       (p_unit_set_comb IS NULL OR
            EXISTS (SELECT 'X'
                        FROM igs_as_su_setatmpt
                                WHERE unit_set_cd = p_unit_set_cd AND
                                      us_version_number = p_unit_set_version AND
                                          person_id = sca.person_id AND
                                      course_cd = sca.course_cd )) AND
/*         (p_class_stand IS NULL OR
            NVL(sca.class_standing_override,get_class_standing(sca.person_id,sca.course_cd,'N'))
                   = p_class_stand ) AND*/
           (p_org_unit_cd IS NULL OR
            EXISTS (SELECT 'X'
                        FROM igs_ps_ver ps
                                WHERE ps.course_cd = sca.course_cd AND
                                      ps.version_number = sca.version_number AND
                                          ((ps.responsible_org_unit_cd = p_org_unit_cd AND
                                        ps.responsible_ou_start_dt = p_org_unit_start_dt) OR
                                                igs_or_gen_001.orgp_get_within_ou(ps.responsible_org_unit_cd,
                                                                                  ps.responsible_ou_start_dt,
                                                                                                                  p_org_unit_cd,
                                                                                                                  p_org_unit_start_dt,
                                                                                                                  'N') = 'Y')));


 CURSOR cur_org_unit_st_dt(p_org_unit_cd VARCHAR2) IS
 SELECT start_dt
 FROM igs_or_unit
 WHERE org_unit_cd = p_org_unit_cd;

 CURSOR cur_person_id_grp(p_person_id_group  NUMBER) IS
 SELECT PG.GROUP_CD||'-'||PG.GROUP_ID
 FROM IGS_PE_PERSID_GROUP PG
 WHERE PG.group_id = p_person_id_group;

 CURSOR cur_person_id(p_person_id NUMBER) IS
 SELECT PE.party_number person_number
 FROM hz_parties  PE
 WHERE PE.party_id  = p_person_id;

 CURSOR cur_step(p_lookup_type VARCHAR2, p_step VARCHAR2) IS
 SELECT LKV.meaning
 FROM IGS_Lookup_values LKV
 WHERE  lkv.lookup_type = p_lookup_type AND
  LKV.lookup_code = p_step;


 CURSOR cur_get_cal_cat (cp_cal_type IGS_CA_TYPE.CAL_TYPE%TYPE) IS
 SELECT s_cal_cat
 FROM igs_ca_type
 WHERE cal_type = cp_cal_type;

 CURSOR cur_load_cal (cp_teach_cal_type VARCHAR2, cp_teach_ci_sequence_number NUMBER) IS
 SELECT load_cal_type,load_ci_sequence_number
 FROM igs_ca_teach_to_load_v
 WHERE teach_cal_type= cp_teach_cal_type
 AND teach_ci_sequence_number= cp_teach_ci_sequence_number;


 l_cal_type igs_ca_inst.cal_type%TYPE;
 l_ci_seq_number igs_ca_inst.sequence_number%TYPE;
 l_course_cd igs_ps_ver.course_cd%TYPE;
 l_course_version  igs_ps_ver.version_number%TYPE;
 l_unit_cd igs_ps_unit_ver.unit_cd%TYPE;
 l_unit_version  igs_ps_unit_ver.version_number%TYPE;
 l_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE;
 l_unit_set_version igs_en_unit_set.version_number%TYPE;
 l_message_name VARCHAR2(30) := NULL;
 l_elgb_override_id igs_en_elgb_ovr.elgb_override_id%TYPE;
 l_rowid VARCHAR2(30);
 l_record_found BOOLEAN :=FALSE;
 l_org_unit_start_dt igs_or_unit.start_dt%TYPE;
 l_person_id_grp VARCHAR2(20);
 l_person_id VARCHAR2(20);
 l_step  IGS_Lookups_view.meaning%TYPE;
 l_load_cal_type igs_ca_teach_to_load_v.load_cal_type%TYPE;
 l_load_cal_seq_num igs_ca_teach_to_load_v.load_ci_sequence_number%TYPE;
 l_cal_cat IGS_CA_TYPE.S_CAL_CAT%TYPE;

 l_is_teach_cal BOOLEAN;

 --
 -- procedure to log all the parameters passed
 -- if no steps provided to override then log error message and stop the process
 --
  FUNCTION enrp_log_para(p_message_name OUT NOCOPY VARCHAR2
           ) RETURN BOOLEAN AS

  BEGIN
    IF (p_person_step_1 IS NULL  AND p_program_step_1 IS NULL AND p_unit_step_1 IS NULL
       AND p_person_step_2 IS NULL  AND p_program_step_2 IS NULL  AND p_unit_step_2 IS NULL
       AND p_person_step_3 IS NULL  AND p_program_step_3 IS NULL  AND p_unit_step_3 IS NULL
       AND p_person_step_4 IS NULL  AND p_program_step_4 IS NULL  AND p_unit_step_4 IS NULL
       AND p_person_ovr_step_1 IS NULL   AND p_unit_ovr_step_1 IS NULL
       AND p_person_ovr_step_2 IS NULL   AND p_unit_ovr_step_2 IS NULL
       AND p_person_ovr_step_3 IS NULL   AND p_unit_ovr_step_3 IS NULL
       AND p_person_ovr_step_4 IS NULL   AND p_unit_ovr_step_4 IS NULL ) THEN

           p_message_name := 'IGS_EN_NO_STEP_PASSED';
           RETURN FALSE;
    END IF;
        Fnd_Message.SET_NAME ('IGS','IGS_CA_CAL_TYPE');
        Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': ' ||p_trm_teach_cal_type_comb);

        IF p_program_cd_comb IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_AD_CRS_CD');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||': '||p_program_cd_comb);
        END IF;
        IF p_location_cd IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_AD_LG_INAP_LOC');
           Fnd_Message.Set_Token('LOC',p_location_cd);
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET);
        END IF;
        IF p_attendance_mode IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_AD_LG_INAP_ATT_MODE');
           Fnd_Message.Set_Token('ATTMODE',p_attendance_mode);
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET);
        END IF;
        IF p_attendance_type IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_AD_LG_INAP_ATT_TYPE');
           Fnd_Message.Set_Token('ATTTYPE',p_attendance_type);
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET);
        END IF;
        IF p_unit_cd_comb IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': ' ||p_unit_cd_comb);
        END IF;
        IF p_unit_set_comb IS NOT NULL THEN
            Fnd_Message.SET_NAME ('IGS','IGS_AD_UNIT_SET');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': ' ||p_unit_set_comb);
        END IF;
        IF p_class_standing IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_EN_CLASS_STAND');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': ' ||p_class_standing);

        END IF;
        IF p_org_unit_cd IS NOT NULL THEN
           Fnd_Message.SET_NAME ('IGS','IGS_PR_ORG_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': '||p_org_unit_cd);
        END IF;
        IF p_person_id_group IS NOT NULL THEN
           OPEN cur_person_id_grp(p_person_id_group);
           FETCH cur_person_id_grp INTO l_person_id_grp;
           CLOSE cur_person_id_grp;
           Fnd_Message.SET_NAME ('IGS','IGS_AD_ADM_ENQ_ID_GRP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||': '||l_person_id_grp);

        END IF;
        IF p_person_id IS NOT NULL THEN
           OPEN cur_person_id(p_person_id);
           FETCH cur_person_id INTO l_person_id;
           CLOSE cur_person_id;
           Fnd_Message.SET_NAME ('IGS','IGS_AD_PERSON_ID');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET|| ': '||l_person_id);

        END IF;
        IF p_program_attempt_status IS NOT NULL THEN
          -- program attempt status
           OPEN cur_step('CRS_ATTEMPT_STATUS',p_program_attempt_status);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME ('IGS','IGS_RE_ATTMPT_STATUS');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||': '||l_step);

        END IF;
        IF p_person_step_1 IS NOT NULL THEN
        -- person step
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_person_step_1);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||l_step);

        END IF;
        IF p_program_step_1 IS NOT NULL THEN
        -- program step
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_program_step_1);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PGM_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||l_step);

        END IF;

        IF p_over_credit_point_1 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_DESIRED_LIM');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||p_over_credit_point_1);

        END IF;

	IF p_unit_step_1 IS NOT NULL THEN
    -- unit step
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_unit_step_1);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||l_step);

        END IF;

	IF p_unit_cd_1 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||p_unit_cd_1);

        END IF;

	IF p_unit_section_1 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||p_unit_section_1);

        END IF;

	IF p_person_step_2 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_person_step_2);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||l_step);

        END IF;
        IF p_program_step_2 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_program_step_2);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PGM_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||l_step);
        END IF;
         IF p_over_credit_point_2 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_DESIRED_LIM');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_over_credit_point_2 );
        END IF;

	IF p_unit_step_2 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_unit_step_2);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||l_step);

        END IF;

       IF p_unit_cd_2 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_unit_cd_2);

        END IF;

	IF p_unit_section_2 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_unit_section_2);

        END IF;


	IF p_person_step_3 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_person_step_3);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||l_step);

        END IF;
        IF p_program_step_3 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_program_step_3);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PGM_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||l_step);
        END IF;
        IF p_unit_step_3 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_unit_step_3);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||l_step);

        END IF;
        IF p_unit_cd_3 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||p_unit_cd_3);

        END IF;

	IF p_unit_section_3 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||p_unit_section_3);

        END IF;

	IF p_person_step_4 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_person_step_4);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||l_step);

        END IF;
        IF p_program_step_4 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_program_step_4);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PGM_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||l_step);

        END IF;
        IF p_unit_step_4 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_STEP_TYPE_EXT',p_unit_step_4);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||l_step);
--
        END IF;

	IF p_unit_cd_4 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||p_unit_cd_4);

        END IF;

	IF p_unit_section_4 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||p_unit_section_4);

        END IF;

        IF p_person_ovr_step_1 IS NOT NULL THEN
        --Person Override Step
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_person_ovr_step_1);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||l_step);

        END IF;

        IF p_unit_ovr_step_1 IS NOT NULL THEN
        --unit Override Step
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_unit_ovr_step_1);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||l_step);

        END IF;
        IF p_over_credit_point_3 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_EN_CRDT_LIM');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '|| p_over_credit_point_3);

        END IF;

	IF p_unit_cd_ovr_1 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||p_unit_cd_ovr_1);

        END IF;

	IF p_unit_section_ovr_1 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 1: '||p_unit_section_ovr_1);

        END IF;
	IF p_person_ovr_step_2 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_person_ovr_step_2);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||l_step);

        END IF;

        IF p_unit_ovr_step_2 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_unit_ovr_step_2);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||l_step);

        END IF;


	IF p_over_credit_point_4 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_CRDT_LIM');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_over_credit_point_4);

        END IF;
        IF p_unit_cd_ovr_2 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_unit_cd_ovr_2 );

        END IF;

	IF p_unit_section_ovr_2 IS NOT NULL THEN

           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 2: '||p_unit_section_ovr_2 );
         END IF;

	IF p_person_ovr_step_3 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_person_ovr_step_3);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||l_step);
        END IF;

	IF p_unit_ovr_step_3 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_unit_ovr_step_3);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||l_step);
        END IF;

	IF p_unit_cd_ovr_3 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||p_unit_cd_ovr_3);

        END IF;

	IF p_unit_section_ovr_3 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 3: '||p_unit_section_ovr_3);
         END IF;
	IF p_person_ovr_step_4 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_person_ovr_step_4);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_PER_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||l_step);
        END IF;

        IF p_unit_ovr_step_4 IS NOT NULL THEN
           OPEN cur_step('ENROLMENT_OVR_STEP_TYPE',p_unit_ovr_step_4);
           FETCH cur_step INTO l_step;
           CLOSE cur_step;
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_OVR_STEP');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||l_step);
        END IF;
        IF p_unit_cd_ovr_4 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_AD_UNIT');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||p_unit_cd_ovr_4);

        END IF;

	IF p_unit_section_ovr_4 IS NOT NULL THEN
           Fnd_Message.SET_NAME('IGS', 'IGS_EN_UNIT_SEC');
           Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||' 4: '||p_unit_section_ovr_4);
         END IF;
        Fnd_File.PUT_LINE(Fnd_File.LOG,'--------------------------------------------------------------------');
        RETURN TRUE;

  END enrp_log_para;

 --
 -- Function which validates the parameters
 -- Steps (FMIN_CRDT,FMAX_CRDT,VAR_CREDIT_APPROVAL) should have value in
 -- credit_point_limit parameter if no value specified log error message and stop the process
 -- if any other steps has value for then log a warning message and continue the process.
 --
 FUNCTION enrp_val_para(p_message_name OUT NOCOPY VARCHAR2
  )RETURN BOOLEAN AS
 BEGIN

   IF (p_program_step_1 IS NULL OR p_program_step_1 NOT IN ('FMIN_CRDT','FMAX_CRDT'))
                   AND (p_over_credit_point_1 IS NOT NULL ) THEN

                    p_message_name := 'IGS_EN_DESIRED_LMT_IGN';

  ELSIF (p_program_step_2 IS NULL OR p_program_step_2 NOT IN ('FMIN_CRDT','FMAX_CRDT'))
                   AND (p_over_credit_point_2 IS NOT NULL ) THEN

                   p_message_name := 'IGS_EN_DESIRED_LMT_IGN';
  END IF;

  IF  (p_unit_ovr_step_1 IS  NULL OR p_unit_ovr_step_1 NOT IN('VAR_CREDIT_APPROVAL'))
                  AND (p_over_credit_point_3 IS NOT NULL)THEN
    --
                    p_message_name :='IGS_EN_CRDT_LMT_IGN';

  ELSIF (p_unit_ovr_step_2 IS  NULL OR p_unit_ovr_step_2 NOT IN ('VAR_CREDIT_APPROVAL'))
                  AND (p_over_credit_point_4 IS NOT NULL) THEN
    --
                    p_message_name :='IGS_EN_CRDT_LMT_IGN';

  END IF;

   IF  p_unit_ovr_step_1 = 'VAR_CREDIT_APPROVAL' AND p_over_credit_point_3 IS  NULL THEN
         p_message_name :='IGS_EN_CRDT_LMT_REQ';
	 RETURN FALSE;
   ELSIF p_unit_ovr_step_2 = 'VAR_CREDIT_APPROVAL' AND p_over_credit_point_4 IS  NULL THEN
         p_message_name :='IGS_EN_CRDT_LMT_REQ';
	 RETURN FALSE;
   END IF;

   IF  p_unit_step_1 IS NOT NULL AND p_unit_cd_1 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;

   IF  p_unit_step_2 IS NOT NULL AND p_unit_cd_2 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_step_3 IS NOT NULL AND p_unit_cd_3 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_step_4 IS NOT NULL AND p_unit_cd_4 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_ovr_step_1 IS NOT NULL AND p_unit_cd_ovr_1 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_ovr_step_2 IS NOT NULL AND p_unit_cd_ovr_2 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_ovr_step_3 IS NOT NULL AND p_unit_cd_ovr_3 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;
   IF  p_unit_ovr_step_4 IS NOT NULL AND p_unit_cd_ovr_4 IS NULL THEN
        p_message_name := 'IGS_EN_UNIT_EXISTS';
	RETURN FALSE;
   END IF;

   IF  p_unit_step_1 IS  NULL AND (p_unit_cd_1 IS NOT NULL
   OR p_unit_section_1 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;
   IF  p_unit_step_2 IS  NULL AND (p_unit_cd_2 IS NOT NULL
   OR p_unit_section_2 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;
   IF  p_unit_step_3 IS  NULL AND (p_unit_cd_3 IS NOT NULL
   OR p_unit_section_3 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;
   IF  p_unit_step_4 IS  NULL AND (p_unit_cd_4 IS NOT NULL
   OR p_unit_section_4 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;
   IF  p_unit_ovr_step_1 IS  NULL AND (p_unit_cd_ovr_1 IS NOT NULL
   OR p_unit_section_ovr_1 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;
   IF  p_unit_ovr_step_2 IS  NULL AND (p_unit_cd_ovr_2 IS NOT NULL
   OR p_unit_section_ovr_2 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;

   IF  p_unit_ovr_step_3 IS  NULL AND (p_unit_cd_ovr_3 IS NOT NULL
   OR p_unit_section_ovr_3 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;

   IF  p_unit_ovr_step_4 IS  NULL AND (p_unit_cd_ovr_4 IS NOT NULL
   OR p_unit_section_ovr_4 IS NOT NULL) THEN
        p_message_name := 'IGS_EN_UNIT_NT_REQD';

   END IF;

   RETURN TRUE;


 END enrp_val_para;

 --
 -- This Procedure will create(if not exists) the override records for the steps passed as parameters
 -- corresponding to the person override record created in igs_en_elgb_ovr table
 --
 PROCEDURE enrp_ins_step_over(p_person_id NUMBER, p_cal_type VARCHAR2, p_ci_seq_number NUMBER,
                              p_elgb_override_id IN NUMBER, p_unit_cd VARCHAR2, p_unit_version NUMBER,
                              p_is_teach_cal BOOLEAN
  )AS

    CURSOR cur_check_override (
                                cp_elgb_override_id      IGS_EN_ELGB_OVR_STEP.ELGB_OVERRIDE_ID%TYPE,
                                cp_eligibility_step_type IGS_EN_ELGB_OVR_STEP.STEP_OVERRIDE_TYPE%TYPE )IS
    SELECT   step_override_limit,
             step_override_type
    FROM     igs_en_elgb_ovr_step eos
    WHERE    eos.elgb_override_id   = cp_elgb_override_id
    AND      eos.step_override_type = cp_eligibility_step_type;

    lr_cur_check_override  cur_check_override%ROWTYPE;

     CURSOR cur_pers_number(p_party_id NUMBER)IS
     SELECT party_number
     FROM hz_parties
     WHERE party_id = p_party_id;

     l_person_number hz_parties.party_number%TYPE;

     CURSOR cur_step_meaning (cp_step_Type IGS_LOOKUP_VALUES.LOOKUP_CODE%TYPE) IS
     SELECT meaning
     FROM   igs_lookup_values
     WHERE  lookup_code = cp_step_Type
     AND (LOOKUP_TYPE = 'ENROLMENT_STEP_TYPE_EXT'
          OR LOOKUP_TYPE = 'ENROLMENT_OVR_STEP_TYPE');

	l_message VARCHAR2(5000);

  --
  -- procedure to check whether record exist, otherwise create new override record for Person Steps
  PROCEDURE enrp_chk_pers_over(p_elgb_step IN VARCHAR2, p_is_teach_cal IN BOOLEAN
  )AS

  l_step_meaning IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_step_override_limit igs_en_elgb_ovr_step.STEP_OVERRIDE_LIMIT%TYPE;
  l_rowid VARCHAR2(30);
  l_elgb_ovr_step_id igs_en_elgb_ovr_step.elgb_ovr_step_id%TYPE;

  BEGIN

    l_step_meaning := NULL;
    OPEN cur_step_meaning(p_elgb_step);
    FETCH cur_step_meaning INTO l_step_meaning;
    CLOSE cur_step_meaning;
    IF p_is_teach_cal THEN
      Fnd_Message.SET_NAME ('IGS','IGS_EN_CANNOT_CREATE_STEP');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' ||l_step_meaning || ' - ' || Fnd_Message.GET);
      RETURN;
    END IF;-- end of IF p_is_teach_cal THEN


    OPEN cur_check_override(p_elgb_override_id,p_elgb_step);
    FETCH cur_check_override INTO lr_cur_check_override;
   BEGIN
    IF cur_check_override%NOTFOUND THEN

      Igs_En_Elgb_Ovr_Step_Pkg.insert_row(x_rowid => l_rowid,
                                        x_elgb_ovr_step_id => l_elgb_ovr_step_id,
                                        x_elgb_override_id => p_elgb_override_id, -- from parameter of container procedure

                                        x_step_override_type => p_elgb_step,
                                        x_step_override_dt => TRUNC(SYSDATE),
                                        x_step_override_limit => NULL,
                                        x_mode => 'R');


      Fnd_Message.SET_NAME ('IGS','IGS_EN_CR_SUCCESS');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' ||l_step_meaning || ' - ' || Fnd_Message.GET);
    ELSE
      Fnd_Message.SET_NAME ('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' || Fnd_Message.GET);
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
           l_message := Fnd_Message.GET;
   	   IF l_message IS NOT NULL THEN
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||l_message );
	   ELSE
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||SQLERRM );
	   END IF;
    END;
    CLOSE cur_check_override;

  END enrp_chk_pers_over;


  PROCEDURE enrp_chk_prg_over(
            p_elgb_step           IN VARCHAR2,
            p_step_override_limit IN NUMBER,
            p_is_teach_cal IN BOOLEAN
  )AS
  /*------------------------------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created:
  --
  --Purpose:
  -- procedure to check whether record exist, otherwise create new override record for Person Steps
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When              What
  --kkillams    05-10-2002        New validation checks whether authorization code is defined or not
  --                              for the MIN credit/Force attendance program steps. If not new logic
  --                              tries to insert the authorization code, where authorization code
  --                              passed as a parameter.
  --svanukur    16-jun-2003       as part of validation consolidtion CR bug #2881385,
  --                                inserting the unit details into igs_en_elgb_ovr_uoo table which was
  --				  created as part of build#2829272.
  --ckasu       13-JUN-2006       modified as a part of bug 5299024.
  --amuthu      15-jun-2006       Added logic to show a note to the user if an authorization already
  --                              exists and a new one is not being created.
  --amuthu      18-Aug-2006       The message IGS_EN_SV_AUTH_ALREADY_EXISTS would be displayed only
  --                              for non-imig student alone. Bug 5435397
  -------------------------------------------------------------------------------------------- */
  --Cursor to get the calendar end date,person id for a given eligibility override.
  CURSOR cur_elgb_end_dt IS SELECT end_dt,person_id, ci.cal_type, ci.sequence_number FROM  igs_en_elgb_ovr elgb,
                                                igs_ca_inst ci
					  WHERE elgb.elgb_override_id   = p_elgb_override_id
                                          AND   elgb.cal_type           = ci.cal_type
                                          AND   elgb.ci_sequence_number    = ci.sequence_number;
  l_step_meaning IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_rowid               VARCHAR2(30);
  l_elgb_ovr_step_id    NUMBER;
  l_step_override_limit NUMBER := NULL;
  l_ci_end_dt           igs_ca_inst.end_dt%TYPE;
  l_cal_type            igs_ca_inst.cal_type%TYPE;
  l_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
  l_person_id           igs_en_elgb_ovr.person_id%TYPE;
  l_message VARCHAR2(5000);
  l_auth_start_Dt igs_en_svs_auth.START_DT%TYPE;
  l_auth_end_dt igs_en_svs_auth.END_DT%TYPE;
  l_sevis_auth_id igs_en_svs_auth.SEVIS_AUTH_ID%TYPE;
  l_sevis_authorization_no igs_en_svs_auth.sevis_authorization_no%TYPE;

     -- Cursor to check whether active sevis person type exists for that person
     -- modified by ckasu as a part of bug 5300119
     CURSOR c_sevis_person_type IS
       SELECT 'X'
       FROM igs_pe_typ_instances_all pti,
            igs_pe_person_types pt
       WHERE pt.person_type_code = pti.person_type_code
       AND system_type IN ('NONIMG_STUDENT')
       AND person_id = p_person_id
       AND NVL(end_date, SYSDATE) >= SYSDATE;

    l_sevis_person_type  c_sevis_person_type%ROWTYPE;


  BEGIN
    -- if the unit step is 'FMIN_CRDT','FMAX_CRDT' then only create override record with step_override_limit
    -- otherwise that column will be NULL

    SAVEPOINT creating_auth_rec;

    IF p_elgb_step IN ('FMIN_CRDT','FMAX_CRDT') THEN
          l_step_override_limit := p_step_override_limit;
    END IF;

    l_step_meaning := NULL;
    OPEN cur_step_meaning(p_elgb_step);
    FETCH cur_step_meaning INTO l_step_meaning;
    CLOSE cur_step_meaning;

    IF p_is_teach_cal THEN

      Fnd_Message.SET_NAME ('IGS','IGS_EN_CANNOT_CREATE_STEP');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' ||l_step_meaning || ' - ' || Fnd_Message.GET);
      RETURN;
    END IF;-- end of IF p_is_teach_cal THEN


    OPEN cur_check_override(p_elgb_override_id,p_elgb_step);
    FETCH cur_check_override INTO lr_cur_check_override;
    BEGIN
    IF cur_check_override%NOTFOUND THEN
        --Cursor to get the calendar end date for a given eligibility override.
        OPEN cur_elgb_end_dt;
        FETCH cur_elgb_end_dt INTO l_ci_end_dt,l_person_id, l_cal_type,l_ci_sequence_number ;
        CLOSE cur_elgb_end_dt;

        -- modified by ckasu  as part of bug 5299024 inorder to create the eligible override step
        -- in upfront.

        l_rowid:=NULL;

        Igs_En_Elgb_Ovr_Step_Pkg.insert_row(x_rowid               => l_rowid,
                                            x_elgb_ovr_step_id    => l_elgb_ovr_step_id,
                                            x_elgb_override_id    => p_elgb_override_id, -- from parameter of container procedure
                                            x_step_override_type  => p_elgb_step,
                                            x_step_override_dt    => TRUNC(SYSDATE),
                                            x_step_override_limit => l_step_override_limit,
                                            x_mode                => 'R');


        --If step is 'FMIN_CRDT' or 'FATD_TYPE', then call the igs_en_sevis.enrf_chk_sevis_auth_req function, which validates the sevis pre-requisites.
        --And check whether authorization code is required for this step override or not.
        IF  p_elgb_step IN ('FMIN_CRDT','FATD_TYPE') THEN

            IF igs_en_sevis.enrf_chk_sevis_auth_req(p_person_id => l_person_id ,
                                                    p_cal_type => l_cal_type,
                                                    p_ci_sequence_number => l_ci_sequence_number,
                                                    p_elgb_step => p_elgb_step
                                                    ) THEN
               IF p_sevis_auth_cd IS NOT NULL THEN
                  l_rowid := NULL;
                  l_sevis_auth_id := NULL;
                  l_auth_start_dt := NULL;
                  l_auth_end_dt := NULL;

                  igs_en_sevis.enrp_sevis_auth_dflt_dt(
                                  p_person_id          => l_person_id,
                                  p_cal_type           => l_cal_type,
                                  p_ci_sequence_number => l_ci_sequence_number,
                                  p_dflt_auth_start_dt => l_auth_start_dt,
                                  p_dflt_auth_end_dt   => l_auth_end_dt);

                  IF l_auth_end_dt IS NULL OR   l_auth_start_dt IS NULL THEN
                    --Log a warn  message.
                    --modfied message name as a part of bug 5299024
                    ROLLBACK to creating_auth_rec;
                    Fnd_Message.SET_NAME ('IGS','IGS_EN_AUTH_REC_NO_DATES');
                    Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || Fnd_Message.GET );
                    RETURN;
                  ELSE

                     SAVEPOINT creating_auth_rec;
                   --Creating the authorization code for the given person.
                   --p_comments,p_elgb_override_id,p_sevis_auth_cd these are parameter of container procedure.
                     igs_en_sevis.create_auth_cal_row (
                       p_sevis_authorization_code          => p_sevis_auth_cd,
                       p_start_dt                          => l_auth_start_dt,
                       p_end_dt                            => l_auth_end_dt,
                       p_comments                          => p_comments,
                       p_sevis_auth_id                     => l_sevis_auth_id,
                       p_sevis_authorization_no            => l_sevis_authorization_no,
                       p_person_id                         => l_person_id,
                       p_cal_type                          => l_cal_type,
                       p_ci_sequence_number                => l_ci_sequence_number,
                       p_cancel_flag                        => 'N');


                    IF igs_en_sevis.is_auth_records_overlap(l_person_id) THEN
                      ROLLBACK to creating_auth_rec;
                      FND_MESSAGE.SET_NAME('IGS','IGS_GE_DATES_OVERLAP');
                      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || Fnd_Message.GET );
                      RETURN;
                    END IF;

                  END IF;
               ELSE

                  --Log a warn  message.
                  ROLLBACK to creating_auth_rec;
                  Fnd_Message.SET_NAME ('IGS','IGS_EN_SEVIS_AUTH_REQUIRED');
                  Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' ||Fnd_Message.GET );
                  RETURN;
               END IF;
            ELSE
             IF FND_PROFILE.VALUE('IGS_SV_ENABLED') = 'Y' THEN
               OPEN c_sevis_person_type;
               FETCH c_sevis_person_type INTO l_sevis_person_type;
               IF c_sevis_person_type%FOUND THEN
                 Fnd_Message.SET_NAME ('IGS','IGS_EN_SV_AUTH_ALREADY_EXISTS');
                 Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || Fnd_Message.GET );
               END IF;
               CLOSE c_sevis_person_type;
             END IF;
            END IF;
        END IF;


      Fnd_Message.SET_NAME ('IGS','IGS_EN_CR_SUCCESS');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' ||l_step_meaning || ' - ' || Fnd_Message.GET);
    ELSE
      Fnd_Message.SET_NAME ('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' || Fnd_Message.GET);
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK to creating_auth_rec;
           l_message := Fnd_Message.GET;
   	   IF l_message IS NOT NULL THEN
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||l_message );
	   ELSE
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||SQLERRM );
	   END IF;
    END;
    CLOSE cur_check_override;


  END enrp_chk_prg_over;

  --
  -- procedure to check whether record exist, otherwise create new override record for Person Steps
  PROCEDURE enrp_chk_unit_over(p_elgb_step IN VARCHAR2,p_step_override_limit IN NUMBER,p_unit_cd IN VARCHAR2,
  p_version_number IN NUMBER, p_uoo_id IN NUMBER
  )AS
  /*------------------------------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created:
  --
  --Purpose:
  -- procedure to check whether record exist, otherwise create new override record for Person Steps
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When               What
  --ptandon	02-Jul-2003	   Modified to allow unit level override for multiple units/unit sections
				   to a student in case of same unit step type if the override is for a
				   different unit section. Bug# 3033214
------------------------------------------------------------------------------------------------------*/
  l_step_meaning IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_rowid VARCHAR2(30);
  l_elgb_ovr_step_id NUMBER(15);
  l_elgb_ovr_step_uoo_id NUMBER(15);
  l_step_override_limit NUMBER(6,3) := NULL;

  l_step_override_type  igs_en_elgb_ovr_step.step_override_type%TYPE;
  l_message VARCHAR2(5000);

  CURSOR cur_get_elgb_ovr_step_id IS
    SELECT   elgb_ovr_step_id
    FROM     igs_en_elgb_ovr_step eos
    WHERE    eos.elgb_override_id   = p_elgb_override_id
    AND      eos.step_override_type = p_elgb_step;

  lr_cur_get_elgb_ovr_step_id  IGS_EN_ELGB_OVR_UOO.ELGB_OVR_STEP_ID%TYPE;

  CURSOR cur_check_override_uooid (
                                cp_elgb_ovr_step_id      IGS_EN_ELGB_OVR_UOO.ELGB_OVR_STEP_ID%TYPE)IS
    SELECT   elgb_ovr_step_uoo_id
    FROM     igs_en_elgb_ovr_uoo eou
    WHERE    eou.elgb_ovr_step_id   = cp_elgb_ovr_step_id
    AND      ((eou.uoo_id = NVL(p_uoo_id,-1) AND NVL(p_uoo_id,-1) <> -1)
    OR (eou.uoo_id = NVL(p_uoo_id,-1) AND NVL(p_uoo_id,-1) = -1 AND eou.unit_cd = p_unit_cd AND eou.version_number = p_version_number));

  lr_cur_check_override_uooid  cur_check_override_uooid%ROWTYPE;

  BEGIN

        -- if the unit step is 'VAR_CREDIT_APPROVAL' then only create override record with step_override_limit
        -- otherwise that column will be NULLp_person_id,

    IF p_elgb_step = 'VAR_CREDIT_APPROVAL' THEN
       l_step_override_limit := p_step_override_limit;
    END IF;

    l_step_meaning := NULL;
    OPEN cur_step_meaning(p_elgb_step);
    FETCH cur_step_meaning INTO l_step_meaning;
    CLOSE cur_step_meaning;

        --
        -- check whether override record exists for the given Unit step, given student and in the given calendar.
        --
    OPEN cur_check_override(p_elgb_override_id,p_elgb_step);
    FETCH cur_check_override INTO lr_cur_check_override;
    BEGIN
    IF cur_check_override%NOTFOUND THEN

            Igs_En_Elgb_Ovr_Step_Pkg.insert_row(x_rowid               => l_rowid,
                                                x_elgb_ovr_step_id    => l_elgb_ovr_step_id,
                                                x_elgb_override_id    => p_elgb_override_id, -- from parameter of container procedure

                                                x_step_override_type  => p_elgb_step,
                                                x_step_override_dt    => TRUNC(SYSDATE),
                                                x_step_override_limit => l_step_override_limit,
                                                x_mode                => 'R');

     l_rowid :=NULL;

     Igs_En_Elgb_Ovr_Uoo_Pkg.insert_row(x_rowid               => l_rowid,
                                                x_elgb_ovr_step_uoo_id    => l_elgb_ovr_step_uoo_id,
                                                x_elgb_ovr_step_id    => l_elgb_ovr_step_id,
                                                x_unit_cd             => p_unit_cd,
                                                x_version_number      => p_version_number,
                                                x_uoo_id              => p_uoo_id,
                                                x_step_override_limit => l_step_override_limit,
                                                x_mode                => 'R');

    Fnd_Message.SET_NAME ('IGS','IGS_EN_CR_SUCCESS');
    Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' || Fnd_Message.GET);
    ELSE
    	OPEN cur_get_elgb_ovr_step_id;
	FETCH cur_get_elgb_ovr_step_id INTO lr_cur_get_elgb_ovr_step_id;
	CLOSE cur_get_elgb_ovr_step_id;

	OPEN cur_check_override_uooid(lr_cur_get_elgb_ovr_step_id);
	FETCH cur_check_override_uooid INTO lr_cur_check_override_uooid;

	IF cur_check_override_uooid%NOTFOUND THEN
		Igs_En_Elgb_Ovr_Uoo_Pkg.insert_row(x_rowid               => l_rowid,
						x_elgb_ovr_step_uoo_id    => l_elgb_ovr_step_uoo_id,
                                                x_elgb_ovr_step_id    => lr_cur_get_elgb_ovr_step_id,
                                                x_unit_cd             => p_unit_cd,
                                                x_version_number      => p_version_number,
                                                x_uoo_id              => p_uoo_id,
                                                x_step_override_limit => l_step_override_limit,
                                                x_mode                => 'R');
		Fnd_Message.SET_NAME ('IGS','IGS_EN_CR_SUCCESS');
		Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' || Fnd_Message.GET);
	ELSE
		Fnd_Message.SET_NAME ('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' || Fnd_Message.GET);
	END IF;
	CLOSE cur_check_override_uooid;
    END IF;
    EXCEPTION
         WHEN OTHERS THEN

           l_message := Fnd_Message.GET;
   	   IF l_message IS NOT NULL THEN
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||l_message );
	   ELSE
              Fnd_File.PUT_LINE(Fnd_File.LOG,'        ' || l_step_meaning || ' - ' ||SQLERRM );
	   END IF;
    END;
    CLOSE cur_check_override;

  END enrp_chk_unit_over;

  --
  -- begin of PROCEDURE enrp_ins_step_over
  --
 BEGIN

   -- fetch the person number

   OPEN cur_pers_number(p_person_id);
   FETCH cur_pers_number INTO l_person_number;
   CLOSE cur_pers_number;

    Fnd_Message.SET_NAME ('IGS','IGS_PR_PERSON_ID');
   -- log the person number into log file for whom override records are going create
   Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET || ': ' || l_person_number );

--
-- for parameter set 1
  IF p_person_step_1 IS NOT NULL THEN
      enrp_chk_pers_over(p_person_step_1,p_is_teach_cal);
  END IF;
  IF p_program_step_1 IS NOT NULL THEN
         enrp_chk_prg_over(p_program_step_1,p_over_credit_point_1, p_is_teach_cal);
  END IF;
  IF p_unit_step_1 IS NOT NULL THEN
       enrp_chk_unit_over(p_unit_step_1,p_over_credit_point_1,RTRIM(SUBSTR(p_unit_cd_1,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_1,12,3))),p_unit_section_1);
  END IF;

--
-- for parameter set 2
  IF p_person_step_2 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_step_2,p_is_teach_cal);
  END IF;
  IF p_program_step_2 IS NOT NULL THEN
     enrp_chk_prg_over(p_program_step_2,p_over_credit_point_2, p_is_teach_cal);
  END IF;
  IF p_unit_step_2 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_step_2,p_over_credit_point_2,RTRIM(SUBSTR(p_unit_cd_2,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_2,12,3))),p_unit_section_2);
  END IF;

--
-- for parameter set 3
  IF p_person_step_3 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_step_3,p_is_teach_cal);
  END IF;
  IF p_program_step_3 IS NOT NULL THEN
     enrp_chk_prg_over(p_program_step_3,NULL,p_is_teach_cal);
  END IF;
  IF p_unit_step_3 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_step_3,NULL,RTRIM(SUBSTR(p_unit_cd_3,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_3,12,3))),p_unit_section_3);
  END IF;

--
-- for parameter set 4
  IF p_person_step_4 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_step_4,p_is_teach_cal);
  END IF;
  IF p_program_step_4 IS NOT NULL THEN
     enrp_chk_prg_over(p_program_step_4,NULL,p_is_teach_cal);
  END IF;
  IF p_unit_step_4 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_step_4,NULL,RTRIM(SUBSTR(p_unit_cd_4,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_4,12,3))),p_unit_section_4);
  END IF;

--
-- for parameter set 5
  IF p_person_ovr_step_1 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_ovr_step_1,FALSE);
  END IF;
  IF p_unit_ovr_step_1 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_ovr_step_1,p_over_credit_point_3,RTRIM(SUBSTR(p_unit_cd_ovr_1,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_ovr_1,12,3))),p_unit_section_ovr_1);
  END IF;

--
-- for parameter set 6
  IF p_person_ovr_step_2 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_ovr_step_2,FALSE);
  END IF;

  IF p_unit_ovr_step_2 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_ovr_step_2,p_over_credit_point_4,RTRIM(SUBSTR(p_unit_cd_ovr_2,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_ovr_2,12,3))), p_unit_section_ovr_2);
  END IF;

--
-- for parameter set 7
  IF p_person_ovr_step_3 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_ovr_step_3,FALSE);
  END IF;

  IF p_unit_ovr_step_3 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_ovr_step_3,NULL,RTRIM(SUBSTR(p_unit_cd_ovr_3,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_ovr_3,12,3))),p_unit_section_ovr_3);
  END IF;

--
-- for parameter set 8
  IF p_person_ovr_step_4 IS NOT NULL THEN
     enrp_chk_pers_over(p_person_ovr_step_4,FALSE);
  END IF;

  IF p_unit_ovr_step_4 IS NOT NULL THEN
     enrp_chk_unit_over(p_unit_ovr_step_4,NULL,RTRIM(SUBSTR(p_unit_cd_ovr_4,1,10)),
     TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_ovr_4,12,3))),p_unit_section_ovr_4);
  END IF;

 END enrp_ins_step_over;

 --
 -- Begin of the procedure enrp_elgbl_override
 --
BEGIN

RETCODE :=0;
igs_ge_gen_003.set_org_id(p_org_id);

--
-- get the details of calendar,program, Unit code and unit set code from the parameters
--
 l_cal_type := RTRIM(SUBSTR(p_trm_teach_cal_type_comb,101,10));
 l_ci_seq_number := TO_NUMBER(RTRIM(SUBSTR(p_trm_teach_cal_type_comb,112,6)));

 IF p_program_cd_comb IS NOT NULL THEN
   l_course_cd := RTRIM(SUBSTR(p_program_cd_comb,1,6));
   l_course_version := TO_NUMBER(RTRIM(SUBSTR(p_program_cd_comb,8)));
 END IF;

 IF p_unit_cd_comb IS NOT NULL THEN
   l_unit_cd := RTRIM(SUBSTR(p_unit_cd_comb,1,10));
   l_unit_version :=TO_NUMBER(RTRIM(SUBSTR(p_unit_cd_comb,12)));
 END IF;

 IF p_unit_set_comb IS NOT NULL THEN
   l_unit_set_cd :=RTRIM(SUBSTR(p_unit_set_comb,1,10));
   l_unit_set_version :=TO_NUMBER(RTRIM(SUBSTR(p_unit_set_comb,12)));
 END IF;
 IF p_org_unit_cd IS NOT NULL THEN
   OPEN cur_org_unit_st_dt(p_org_unit_cd);
   FETCH cur_org_unit_st_dt INTO l_org_unit_start_dt ;
   CLOSE cur_org_unit_st_dt;
 END IF;
--
-- call the procedure below to log all the parameters passed to this function
 IF NOT enrp_log_para(l_message_name) THEN
    -- no steps passed in parameter to override
    Fnd_Message.SET_NAME ('IGS',l_message_name);
    Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET );

    retcode :=2;
    RETURN;
 END IF;

--
-- Validate parameters.
-- all the parameters for the container procedure will be available to the inner function
--
 IF NOT enrp_val_para(l_message_name) THEN
   -- validation failed log error message
    Fnd_Message.SET_NAME ('IGS',l_message_name);
    Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET );

        retcode :=2;
    RETURN;
 END IF;
 IF l_message_name IS NOT NULL THEN
    Fnd_Message.SET_NAME ('IGS',l_message_name);
    Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET );

 END IF;
--
-- loop through all the students who satisfied the cursor criteria
-- and create the override records for the steps passed in parameters
--
 OPEN cur_get_cal_cat(l_cal_type);
 FETCH cur_get_cal_cat INTO l_cal_cat;
 CLOSE cur_get_cal_cat;

 l_is_teach_cal := FALSE;

 IF l_cal_cat = 'LOAD' THEN
  l_load_cal_type := l_cal_type;
  l_load_cal_seq_num := l_ci_seq_number;
 ELSIF l_cal_cat = 'TEACHING' THEN
   l_is_teach_cal := TRUE;
   OPEN cur_load_cal(l_cal_type,l_ci_seq_number);
   FETCH cur_load_cal INTO l_load_cal_type,l_load_cal_seq_num;
   CLOSE cur_load_cal;
 ELSE
  l_load_cal_type := NULL;
  l_load_cal_seq_num := NULL;
 END IF;

FOR cur_criteria_satisfied_rec IN cur_criteria_satisfied(l_course_cd ,l_course_version,l_unit_cd, l_unit_version,
                                                         l_unit_set_cd,l_unit_set_version, l_org_unit_start_dt,
                                                         l_load_cal_type,l_load_cal_seq_num ) LOOP
   --
   -- log the message that for the following persons override records have been created

   IF NOT l_record_found THEN
      l_record_found := TRUE;
      Fnd_Message.SET_NAME('IGS','IGS_EN_PERSONS_OVERRIDE');
      Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET );

   END IF;

  OPEN cur_elgb_over(cur_criteria_satisfied_rec.person_id,l_cal_type,l_ci_seq_number);
  FETCH cur_elgb_over INTO l_elgb_override_id;

  --
  -- if override record is not exists for the given student in given calendar(Load/Teach)
  IF cur_elgb_over%NOTFOUND THEN
    -- create override record for the given student in given calendar(Load/Teach)
    l_rowid :=NULL;
       Igs_En_Elgb_Ovr_Pkg.insert_row(x_rowid              => l_rowid,
                                   x_elgb_override_id   => l_elgb_override_id,
                                   x_person_id          => cur_criteria_satisfied_rec.person_id,
                                   x_cal_type           => l_cal_type,
                                   x_ci_sequence_number => l_ci_seq_number,
                                   x_mode               => 'R');
  END IF;
  CLOSE cur_elgb_over;
  --
  -- call the procedure to create override records correponding to the steps paased as parameters
  --
    enrp_ins_step_over(cur_criteria_satisfied_rec.person_id,l_cal_type,l_ci_seq_number,l_elgb_override_id,l_unit_cd,l_unit_version,l_is_teach_cal );

END LOOP; -- cur_criteria_satisfied_rec

--  l_record_found is initialised with False at declaration.When an override record doesn't exists then
--  it retains same value and the below If condition evaluates to True and logs Message 'No Student was
--  selected for the given criteria' in log file.

IF NOT l_record_found THEN
  Fnd_Message.SET_NAME('IGS','IGS_EN_NO_STDNT_FOUND');
  Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET );
END IF;

EXCEPTION
        WHEN OTHERS THEN

          retcode:=2;
          Fnd_File.PUT_LINE(Fnd_File.LOG,SQLERRM);

	  ERRBUF := Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END enrp_elgbl_override;

END igs_en_elgbl_override;

/
