--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_017
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_017" AS
/* $Header: IGSEN96B.pls 120.3 2005/07/12 07:44:57 appldev ship $ */

  /*************************************************************
   Created By :
   Date Created By :
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   vvutukur      05-Aug-2003     Enh#3045069.PSP Enh Build. Modified add_to_cart_waitlist.
   (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE add_to_cart_waitlist (
    p_person_number IN  VARCHAR2,
    p_career        IN  VARCHAR2,
    p_program_code  IN  VARCHAR2,
    p_term_alt_code IN  VARCHAR2,
    p_call_number   IN  NUMBER,
    p_audit_ind     IN  VARCHAR2,
    p_waitlist_ind  IN  OUT NOCOPY VARCHAR2,
    p_action        IN  VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_ret_status    OUT NOCOPY VARCHAR2) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 23JAN2003
  ||  Purpose    : This procedure is called from the add_to_cart API and waitlist API.
  ||               When called from the waitlist API it wailists a student.
  ||               When called from add_to_cart API its checks for seat availability for the student.
  ||               In case the seat is available then it adds the unit section to the student cart.
  ||               In case the seat is not available but student can waitlist then it returns
  ||               this information without adding to cart.
  ||               In case student cannot waitlist then it returns the error message out.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sgurusam        05-Jul-2005    Pass the new parameter p_calling_obj='JOB'  in the calls to igs_ss_en_wrappers.insert_into_enr_worksheet
  ||                                 Pass the new parameter p_calling_obj= 'JOB' in the calls to igs_ss_en_wrappers.drop_selected_units
  ||  sommukhe        27-JUL-2005    Bug#4344483,Modified the call to igs_ps_unit_ofr_opt_pkg.update_row
  ||                                 to include new parameter abort_flag.
  ||  sarakshi        18-Sep-2003    Enh#3052452.Modified the call to igs_ps_unit_ofr_opt_pkg.update_row
  ||                                 to include new parameter sup_uoo_id,relation_type,default_enroll_flag
  || rvivekan           3-Aug-2003	  Added new parameters to ofr_enrollment_or_waitlist    |
			 			  as a part of Bulk Unit Upload Bug#3049009
  || vvutukur         05-aug-2003    Enh#3045069.PSP Enh Build. Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to
  ||                                 include new parameter not_multiple_section_flag.
  || svanukur         16-jun-2003    implemented the check for unit section status of 'NOT_OFFERED'
  ||                                   as part of validation impact CR ENCR034.
  ||  (reverse chronological order - newest change first)
  */
    l_person_id          igs_pe_person_base_v.person_id%TYPE;
    l_person_type        igs_pe_typ_instances.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_ps_ver.course_cd%TYPE;
    l_primary_version    igs_ps_ver.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_us_status          igs_en_su_attempt.unit_attempt_status%TYPE;
    l_ret_status         VARCHAR2(6):='TRUE';
    l_waitlist_ind       VARCHAR2(1);
    l_message_count      NUMBER;
    l_message_data       VARCHAR2(2000) := NULL;
    l_message_data_out   VARCHAR2(2000) := NULL;
    l_next_step          VARCHAR2(1);

    CURSOR c_chk_us_ivr IS
    SELECT ivrs_available_ind, unit_section_status, auditable_ind
    FROM   igs_ps_unit_ofr_opt
    WHERE  uoo_id = l_uoo_id;

    l_ivrs_available_ind  igs_ps_unit_ofr_opt.ivrs_available_ind%TYPE;
    l_unit_section_status igs_ps_unit_ofr_opt.unit_section_status%TYPE;
    l_auditable_ind       igs_ps_unit_ofr_opt.auditable_ind%TYPE;

    CURSOR c_unit_ofr_opt IS
    SELECT uoo.*
    FROM   igs_ps_unit_ofr_opt uoo
    WHERE  uoo_id = l_uoo_id;

    l_unit_ofr_opt  c_unit_ofr_opt%ROWTYPE;

  BEGIN
    p_ret_status := l_ret_status;

    --Validate the input parameters and if valid, also fetch the internal calculated
    --values. Pass the Validation level as With Call Number.
    igs_en_gen_017.enrp_validate_input_parameters(
        p_person_number       => p_person_number,
        p_career              => p_career,
        p_program_code        => p_program_code,
        p_term_alt_code       => p_term_alt_code,
        p_call_number         => p_call_number,
        p_validation_level    => 'WITHCALLNUM',
        p_person_id           => l_person_id,
        p_person_type         => l_person_type,
        p_cal_type            => l_cal_type,
        p_ci_sequence_number  => l_ci_sequence_number,
        p_primary_code        => l_primary_code,
        p_primary_version     => l_primary_version,
        p_uoo_id              => l_uoo_id,
        p_error_message       => l_message_data,
        p_ret_status          => l_ret_status );

    --If there is any invalid parameter then log it and return with error status
    IF l_ret_status = 'FALSE' THEN
         igs_en_gen_017.enrp_msg_string_to_list (
                    p_message_string => l_message_data,
                    p_delimiter      => ';',
                    p_init_msg_list  => FND_API.G_FALSE,
                    x_message_count  => l_message_count,
                    x_message_data   => l_message_data_out);
         p_error_message := l_message_data_out;
         p_ret_status := 'FALSE';
         RETURN;
    END IF;

    --If p_action is "WLIST" and the waitlist indicator parameter is 'N' then update the
    --inquired but not waitlisted counter (INQ_NOT_WLST column) of the unit section
    --with increasing by one.
    IF p_action = 'WLIST' AND p_waitlist_ind = 'N' THEN

         OPEN c_unit_ofr_opt;
         FETCH c_unit_ofr_opt INTO l_unit_ofr_opt;
         CLOSE c_unit_ofr_opt;

         igs_ps_unit_ofr_opt_pkg.update_row (
                  x_rowid                        => l_unit_ofr_opt.row_id,
                  x_unit_cd                      => l_unit_ofr_opt.unit_cd,
                  x_version_number               => l_unit_ofr_opt.version_number,
                  x_cal_type                     => l_unit_ofr_opt.cal_type,
                  x_ci_sequence_number           => l_unit_ofr_opt.ci_sequence_number,
                  x_location_cd                  => l_unit_ofr_opt.location_cd,
                  x_unit_class                   => l_unit_ofr_opt.unit_class,
                  x_uoo_id                       => l_unit_ofr_opt.uoo_id,
                  x_ivrs_available_ind           => l_unit_ofr_opt.ivrs_available_ind,
                  x_call_number                  => l_unit_ofr_opt.call_number,
                  x_unit_section_status          => l_unit_ofr_opt.unit_section_status,
                  x_unit_section_start_date      => l_unit_ofr_opt.unit_section_start_date,
                  x_unit_section_end_date        => l_unit_ofr_opt.unit_section_end_date,
                  x_enrollment_actual            => l_unit_ofr_opt.enrollment_actual,
                  x_waitlist_actual              => l_unit_ofr_opt.waitlist_actual,
                  x_offered_ind                  => l_unit_ofr_opt.offered_ind,
                  x_state_financial_aid          => l_unit_ofr_opt.state_financial_aid,
                  x_grading_schema_prcdnce_ind   => l_unit_ofr_opt.grading_schema_prcdnce_ind,
                  x_federal_financial_aid        => l_unit_ofr_opt.federal_financial_aid,
                  x_unit_quota                   => l_unit_ofr_opt.unit_quota,
                  x_unit_quota_reserved_places   => l_unit_ofr_opt.unit_quota_reserved_places,
                  x_institutional_financial_aid  => l_unit_ofr_opt.institutional_financial_aid,
                  x_unit_contact                 => l_unit_ofr_opt.unit_contact,
                  x_grading_schema_cd            => l_unit_ofr_opt.grading_schema_cd,
                  x_gs_version_number            => l_unit_ofr_opt.gs_version_number,
                  x_owner_org_unit_cd            => l_unit_ofr_opt.owner_org_unit_cd,
                  x_attendance_required_ind      => l_unit_ofr_opt.attendance_required_ind,
                  x_reserved_seating_allowed     => l_unit_ofr_opt.reserved_seating_allowed,
                  x_special_permission_ind       => l_unit_ofr_opt.special_permission_ind,
                  x_ss_display_ind               => l_unit_ofr_opt.ss_display_ind,
                  x_mode                         => 'R',
                  x_ss_enrol_ind                 => l_unit_ofr_opt.ss_enrol_ind,
                  x_dir_enrollment               => l_unit_ofr_opt.dir_enrollment,
                  x_enr_from_wlst                => l_unit_ofr_opt.enr_from_wlst,
                  x_inq_not_wlst                 => NVL(l_unit_ofr_opt.inq_not_wlst,0) + 1, --increased by one
                  x_rev_account_cd               => l_unit_ofr_opt.rev_account_cd,
                  x_anon_unit_grading_ind        => l_unit_ofr_opt.anon_unit_grading_ind,
                  x_anon_assess_grading_ind      => l_unit_ofr_opt.anon_assess_grading_ind,
                  x_non_std_usec_ind             => l_unit_ofr_opt.non_std_usec_ind,
                  x_auditable_ind                => l_unit_ofr_opt.auditable_ind,
                  x_audit_permission_ind         => l_unit_ofr_opt.audit_permission_ind,
		  x_not_multiple_section_flag    => l_unit_ofr_opt.not_multiple_section_flag ,
                  x_sup_uoo_id                   => l_unit_ofr_opt.sup_uoo_id                 ,
                  x_relation_type                => l_unit_ofr_opt.relation_type              ,
                  x_default_enroll_flag          => l_unit_ofr_opt.default_enroll_flag,
                  x_abort_flag                   => l_unit_ofr_opt.abort_flag
		  );
                  RETURN;

    END IF;

    OPEN c_chk_us_ivr;
    FETCH c_chk_us_ivr INTO l_ivrs_available_ind,l_unit_section_status,l_auditable_ind;
    CLOSE c_chk_us_ivr;

    --If the unit Section is not for IVR Response Enrollment then log error message
    IF l_ivrs_available_ind <> 'Y' THEN
         l_message_data := 'IGS_EN_US_NOT_OFR_IVR';
         p_ret_status := 'FALSE';
    END IF;

    --If the unit Section is of PLANNED OR CANCELLED status then log error message
    IF l_unit_section_status IN ('PLANNED','CANCELLED','NOT_OFFERED') THEN
         IF l_message_data IS NULL THEN
              l_message_data := 'IGS_SS_EN_INVLD_UNIT_STATUS';
         ELSE
              l_message_data := l_message_data||';'||'IGS_SS_EN_INVLD_UNIT_STATUS';
         END IF;
         p_ret_status := 'FALSE';
    END IF;

    --If the Auditable parameter passed is yes, But the Auditable indicator of the
    --unit section is no then log Error message
    IF p_audit_ind = 'Y' AND l_auditable_ind <> 'Y' THEN
         IF l_message_data IS NULL THEN
              l_message_data := 'IGS_EN_CANNOT_AUDIT';
         ELSE
              l_message_data := l_message_data||';'||'IGS_EN_CANNOT_AUDIT';
         END IF;
         p_ret_status := 'FALSE';
    END IF;

    --If one or more of the above three validation has been failed then log all the
    --error messages and Return.
    IF p_ret_status = 'FALSE' THEN
         igs_en_gen_017.enrp_msg_string_to_list (
              p_message_string => l_message_data,
              p_delimiter      => ';',
              p_init_msg_list  => FND_API.G_FALSE,
              x_message_count  => l_message_count,
              x_message_data   => l_message_data_out);
         RETURN;
    END IF;

    --Call the below procedure for the Person Step validations
    l_message_data := NULL;
    igs_en_ivr_pub.evaluate_person_steps(
         p_api_version   => 1.0,
         p_init_msg_list => FND_API.G_FALSE,
         p_commit => FND_API.G_FALSE,
         p_person_number => p_person_number,
         p_career        => p_career,
         p_program_code  => p_program_code,
         p_term_alt_code => p_term_alt_code,
         x_return_status => l_ret_status,
         x_msg_count => l_message_count,
         x_msg_data  => l_message_data );

    --If the Person Step Validation has been returned with Error then
    --Log error message and Return.
    IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
         p_ret_status := 'FALSE';
         RETURN;
    END IF;

    --Get the Unit Section Status and Waitlist Allowed indicator of the Unit Section Applied for
    igs_en_gen_015.get_usec_status (
         p_uoo_id                  => l_uoo_id,
         p_person_id               => l_person_id,
         p_unit_section_status     => l_us_status,
         p_waitlist_ind            => l_waitlist_ind,
         p_load_cal_type           => l_cal_type,
         p_load_ci_sequence_number => l_ci_sequence_number,
         p_course_cd               => p_program_code);

    --If the waitlist indicator is 'Y' then Student can waitlist into the unit section
    IF l_waitlist_ind = 'Y' THEN
         --If Action parameter is CART then log an error message saying the unit section is full.
         --You can be waitlisted into it and Return.
         IF p_action = 'CART' THEN
               p_ret_status := 'FALSE';
               p_waitlist_ind := 'Y';
               l_next_step := 'N';
               igs_en_gen_017.enrp_msg_string_to_list (
                    p_message_string => 'IGS_EN_IVR_USEC_WLST_INFO',
                    p_delimiter      => ';',
                    p_init_msg_list  => FND_API.G_FALSE,
                    x_message_count  => l_message_count,
                    x_message_data   => l_message_data_out);
               p_ret_status := 'FALSE';
               p_error_message := l_message_data_out;

         --If Action parameter is WLIST then Proceed to the further validations
         ELSIF p_action = 'WLIST' THEN
               l_next_step := 'Y';
         END IF;

    --If the Waitlist indicator is 'N' then Student can enroll into the unit section.
    --Proceed to the further validations
    ELSIF l_waitlist_ind = 'N' THEN
         l_next_step := 'Y';
    --If the Waitlist indicator is NULL then Student can neither Enroll nor waitlist.
    --Log proper error message and Return.
    ELSIF l_waitlist_ind IS NULL THEN
         p_ret_status := 'FALSE';
         p_waitlist_ind := 'N';
         l_next_step := 'N';
         igs_en_gen_017.enrp_msg_string_to_list (
              p_message_string => 'IGS_EN_SS_CANNOT_WAITLIST',
              p_delimiter      => ';',
              p_init_msg_list  => FND_API.G_FALSE,
              x_message_count  => l_message_count,
              x_message_data   => l_message_data_out);
         p_ret_status := 'FALSE';
         p_error_message := l_message_data_out;
    END IF;

    --In case of any succes case above do the below validation
    IF l_next_step = 'Y' THEN

         --Perform the unit steps validation and add the unit section to the cart in unconfirmed status.
         --In case of action WLIST, Waitlist the student into the unit section.
         igs_ss_en_wrappers.insert_into_enr_worksheet (
              p_person_number       => p_person_number,
              p_course_cd           => l_primary_code,
              p_uoo_id              => l_uoo_id,
              p_waitlist_ind        => l_waitlist_ind,
              p_session_id          => NULL,
              p_return_status       => l_ret_status,
              p_message             => l_message_data,
              p_cal_type            => l_cal_type,
              p_ci_sequence_number  => l_ci_sequence_number,
              p_audit_requested     => p_audit_ind,
              p_enr_method          => NULL,
              p_override_cp         => NULL,
              p_subtitle            => NULL,
              p_gradsch_cd          => NULL,
              p_gs_version_num	    => NULL,
              p_calling_obj         => 'JOB');

         --If the return status is D (means DENY) then Log error message and Return
         IF l_ret_status = 'D' THEN
              igs_en_gen_017.enrp_msg_string_to_list (
                   p_message_string => l_message_data,
                   p_delimiter      => ';',
                   p_init_msg_list  => FND_API.G_FALSE,
                   x_message_count  => l_message_count,
                   x_message_data   => l_message_data_out);
              p_ret_status := 'FALSE';
         END IF;
    END IF;
  END add_to_cart_waitlist;

  PROCEDURE drop_section(
    p_person_number IN         VARCHAR2,
    p_career        IN         VARCHAR2,
    p_program_code  IN         VARCHAR2,
    p_term_alt_code IN         VARCHAR2,
    p_call_number   IN         NUMBER  ,
    p_action        IN         VARCHAR2,
    p_drop_reason   IN         VARCHAR2,
    p_adm_status    IN         VARCHAR2,
    p_error_message OUT NOCOPY VARCHAR2,
    p_return_stat   OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : To drop all the sections of students for the career/program and term.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_program_cd         igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_messaage_count     NUMBER(15);
    l_error_message      VARCHAR2(1000);
    l_return_stat        VARCHAR2(10);
    l_api_name           CONSTANT VARCHAR2(30) := 'drop_section';
    l_api_version        CONSTANT NUMBER       := 1.0;
    l_failed_uoo_ids     VARCHAR2(1000);
    l_failed_unit_cds    VARCHAR2(1000);

    l_return_status      VARCHAR2(10)   := NULL;
    l_message_count      NUMBER         := NULL;
    l_message_data       VARCHAR2(1000);

    CURSOR cur_uoo_id (cp_person_id          igs_pe_person.person_id%TYPE,
                       cp_course_cd          igs_en_su_attempt.course_cd%TYPE,
                       cp_cal_type           igs_ca_inst.cal_type%TYPE,
                       cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE)IS
    SELECT uoo_id
    FROM igs_en_su_attempt
    WHERE person_id = cp_person_id
    AND unit_attempt_status IN ('INVALID','WAITLIST','ENROLLED')
    AND course_cd = cp_course_cd
    AND (cal_type , ci_sequence_number) IN (SELECT teach_cal_type,teach_ci_sequence_number
                                         FROM igs_ca_load_to_teach_v
                                         WHERE load_cal_type     = cp_cal_type AND
                                         load_ci_sequence_number = cp_ci_sequence_number);
    l_rec_uoo_id cur_uoo_id%ROWTYPE;
    l_uoo_ids VARCHAR2(1000);

  BEGIN

    --Initialize the parameters
    p_error_message := NULL;
    p_return_stat   := 'TRUE';

    IF p_action = 'ONE' THEN
      igs_en_gen_017.enrp_validate_input_parameters(
        p_person_number        => p_person_number     ,
        p_career               => p_career            ,
        p_program_code         => p_program_code      ,
        p_term_alt_code        => p_term_alt_code     ,
        p_call_number          => p_call_number       ,
        p_validation_level     => 'WITHCALLNUM'       ,
        p_person_id            => l_person_id         ,
        p_person_type          => l_person_type       ,
        p_cal_type             => l_cal_type          ,
        p_ci_sequence_number   => l_ci_sequence_number,
        p_primary_code         => l_primary_code      ,
        p_primary_version      => l_primary_version   ,
        p_uoo_id               => l_uoo_id            ,
        p_error_message        => l_error_message     ,
        p_ret_status           => l_return_stat
      );
    ELSIF p_action = 'ALL' THEN
      igs_en_gen_017.enrp_validate_input_parameters(
        p_person_number        => p_person_number     ,
        p_career               => p_career            ,
        p_program_code         => p_program_code      ,
        p_term_alt_code        => p_term_alt_code     ,
        p_call_number          => p_call_number       ,
        p_validation_level     => 'NOCALLNUM'         ,
        p_person_id            => l_person_id         ,
        p_person_type          => l_person_type       ,
        p_cal_type             => l_cal_type          ,
        p_ci_sequence_number   => l_ci_sequence_number,
        p_primary_code         => l_primary_code      ,
        p_primary_version      => l_primary_version   ,
        p_uoo_id               => l_uoo_id            ,
        p_error_message        => l_error_message     ,
        p_ret_status           => l_return_stat
      );
    END IF;
    p_return_stat   := l_return_stat;
    p_error_message := l_error_message;
    IF p_return_stat = 'FALSE' THEN
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data
       );
      RETURN;
    END IF;
    --
    --If the control reaches till here then perform the Person Validate Step by calling igs_en_ivr_pub.evaluate_person_steps.
    --
    igs_en_ivr_pub.evaluate_person_steps(
        p_api_version   => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit =>  FND_API.G_FALSE,
        p_person_number => p_person_number,
        p_career        => p_career,
        p_program_code  => p_program_code,
        p_term_alt_code => p_term_alt_code,
        x_return_status => l_return_status,
        x_msg_count => l_message_count,
        x_msg_data  => l_message_data);

    IF l_return_status = FND_API.G_FALSE THEN
      RETURN;
    END IF;

    --
    --If the action is 'ALL' then Fetch the students sections for selected term and career/program.
    --
    IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') = 'Y' THEN
      l_program_cd := l_primary_code;
    ELSE
      l_program_cd := p_program_code;
    END IF;
    l_uoo_ids := NULL;

    IF p_action = 'ONE' THEN
      l_uoo_ids := l_uoo_id;
    ELSIF p_action = 'ALL' THEN
     FOR l_rec_uoo_id IN cur_uoo_id(l_person_id, l_program_cd, l_cal_type, l_ci_sequence_number) LOOP
       IF l_uoo_ids IS NULL THEN
         l_uoo_ids := l_rec_uoo_id.uoo_id;
       ELSE
         l_uoo_ids := l_uoo_ids||','||l_rec_uoo_id.uoo_id;
       END IF;
     END LOOP;
    END IF;

    BEGIN
    --Call the program unit to drop the unit sections
    igs_ss_en_wrappers.drop_selected_units(
      p_uoo_ids              => l_uoo_ids           ,
      p_person_id            => l_person_id         ,
      p_person_type          => l_person_type       ,
      p_load_cal_type        => l_cal_type          ,
      p_load_sequence_number => l_ci_sequence_number,
      p_program_cd           => l_program_cd        ,
      p_program_version      => l_primary_version   ,
      p_dcnt_reason_cd       => p_drop_reason       ,
      p_admin_unit_status    => p_adm_status        ,
      p_effective_date       => SYSDATE             ,
      p_failed_uoo_ids       => l_failed_uoo_ids    ,
      p_failed_unit_cds      => l_failed_unit_cds   ,
      p_return_status        => l_return_status     ,
      p_message              => l_error_message     ,
      p_ovrrd_min_cp_chk     => NULL,
      p_ovrrd_crq_chk        => NULL,
      p_ovrrd_prq_chk        => NULL,
      p_ovrrd_att_typ_chk    => NULL
    );

    EXCEPTION
      -- Added the exception part to handle the excption occured in igs_ss_enr_details.drop_selected_units procedure.
      WHEN OTHERS THEN
        IF l_message_data IS NOT NULL THEN
          IF p_error_message IS NOT NULL THEN
            p_error_message := p_error_message||';'||l_message_data;
          ELSE
            p_error_message := l_message_data;
          END IF;
        END IF;
	p_return_stat := 'FALSE';
	RETURN;
    END;

    l_message_data:= NULL;
    igs_en_gen_017.enrp_msg_string_to_list(
      p_message_string => l_error_message,
      p_init_msg_list  => FND_API.G_FALSE,
      x_message_count  => l_message_count,
      x_message_data   => l_message_data);

    IF l_message_data IS NOT NULL THEN
      IF p_error_message IS NOT NULL THEN
        p_error_message := p_error_message||';'||l_message_data;
      ELSE
        p_error_message := l_message_data;
      END IF;
    END IF;
    p_return_stat   := 'TRUE';
  END drop_section;

PROCEDURE enrp_get_default_term(
              p_term_alt_code OUT NOCOPY VARCHAR2,
              p_error_message OUT NOCOPY VARCHAR2,
              p_ret_status    OUT NOCOPY VARCHAR2 )AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 15JAN2003
  ||  Purpose    : This Procedure gets the default Term.
  ||               If no default term found then it will return error message.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

--Get the 'load effective date alias' in 'Configure Enrollment Calendar' set up form.
--For that alias find the active term calendar instance for which the sysdate is between
--the start date and end date of the instance and the absolute value of the alias is less than
--or equal to sysdate. The instance with most recent absolute value will be considered as defaulted.
CURSOR c_cur_alt_code IS
SELECT currterm.alternate_code
FROM   (SELECT ci.alternate_code
        FROM   igs_ca_inst ci,
               igs_ca_type ct,
               igs_ca_stat cs,
               igs_ca_da_inst dai
        WHERE  ci.cal_type = ct.cal_type
        AND    ct.s_cal_cat = 'LOAD'
        AND    ci.cal_status = cs.cal_status
        AND    cs.s_cal_status = 'ACTIVE'
        AND    SYSDATE BETWEEN ci.start_dt AND ci.end_dt
        AND    dai.cal_type = ci.cal_type
        AND    dai.ci_sequence_number = ci.sequence_number
        AND    dai.dt_alias = (SELECT load_effect_dt_alias
                               FROM igs_en_cal_conf)
        AND    dai.absolute_val <= SYSDATE
        ORDER BY dai.absolute_val DESC) currterm
WHERE ROWNUM < 2;

BEGIN
--Initialize the parameters
p_error_message := NULL;
p_ret_status    := 'TRUE';

OPEN c_cur_alt_code;
FETCH c_cur_alt_code INTO p_term_alt_code;

IF c_cur_alt_code%NOTFOUND THEN
--If the default Term Calendar is not found then set error message.
    p_error_message := 'IGS_EN_NO_DEFAULT_TERM';
    p_ret_status    := 'FALSE';
END IF;
CLOSE c_cur_alt_code;

END enrp_get_default_term;

  PROCEDURE enrp_get_enr_method(
    p_enr_method_type OUT NOCOPY VARCHAR2,
    P_error_message   OUT NOCOPY VARCHAR2,
    p_ret_status      OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : To return the method type based on the enrolling source.
  ||             This procedure would return the Enrollment Method depending on the Passed
  ||             Parameter indicating the enrolling source. This parameter would currently
  ||             have the values SS for Self Service /IVR or the actual enrolment method
  ||             stored with at student attempt level Based on this, the method type setup
  ||             would be fetched and returned or if method is passed then it would be
  ||             validated to be a valid method. The setup is done in IGSEN015 form. If no
  ||             method type is found then error is returned. The procedure can be expanded
  ||             later to other methods of enrollment as and when the requirement arises.
  ||             'SS' and 'IVR' are codes used internally hence not seeded.
  ||             Note: After this modification at no place the IGS_EN_METHOD_TYPE should be
  ||             used directly to get the enrollment method type. This procedure should be invoked.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || rvivekan	      11-7-2003	      changed g_invoke_source NJOB to JOB as a part of bug 3036949
  ||  kkillams        09-06-2003      Modified the validation to return default bulk job enrollment method
  ||                                  if g_invoke_source set to 'JOB' w.r.t bug 3829270
  */
    CURSOR cur_ss IS
    SELECT enr_method_type
    FROM   igs_en_method_type
    WHERE self_service = 'Y'
      AND closed_ind = 'N';
    l_rec_ss cur_ss%ROWTYPE;

    CURSOR cur_ivr IS
    SELECT enr_method_type
    FROM   igs_en_method_type
    WHERE ivr_display_ind = 'Y'
    AND closed_ind = 'N';
    l_rec_ivr cur_ivr%ROWTYPE;

    CURSOR cur_bulkjob IS
    SELECT enr_method_type
    FROM   igs_en_method_type
    WHERE bulk_job_ind = 'Y'
    AND closed_ind = 'N';
    l_rec_bulk cur_bulkjob%ROWTYPE;

  BEGIN
    --
    --Initialize the parameters.
    --
    p_enr_method_type := NULL;
    p_error_message := NULL;
    p_ret_status    := 'TRUE';

    --
    --Get the Enrollment Method.
    --
    IF igs_en_gen_017.g_invoke_source = 'SS' THEN
      OPEN cur_ss;
      FETCH cur_ss INTO l_rec_ss;
        IF cur_ss%FOUND THEN
          p_enr_method_type := l_rec_ss.enr_method_type;
        END IF;
      CLOSE cur_ss;
    ELSIF igs_en_gen_017.g_invoke_source = 'IVR' THEN
      OPEN cur_ivr;
      FETCH cur_ivr INTO l_rec_ivr;
        IF cur_ivr%FOUND THEN
          p_enr_method_type := l_rec_ivr.enr_method_type;
        END IF;
      CLOSE cur_ivr;
    ELSIF igs_en_gen_017.g_invoke_source = 'JOB' THEN
      OPEN cur_bulkjob;
      FETCH cur_bulkjob INTO l_rec_bulk;
        IF cur_bulkjob%FOUND THEN
          p_enr_method_type := l_rec_bulk.enr_method_type;
        END IF;
      CLOSE cur_bulkjob;
    END IF;

    --
    -- If no Enrollment Method found then return 'FALSE' along with the proper error message.
    --
    IF p_enr_method_type IS NULL THEN
      p_error_message := 'IGS_SS_EN_NOENR_METHOD';
      p_ret_status    := 'FALSE';
    END IF;
  END enrp_get_enr_method;

  FUNCTION enrp_get_invoke_source RETURN VARCHAR2 AS
  /******************************************************************************************
  ||  Created By : smanglm
  ||  Created On : 2003/01/22
  ||  Purpose : This funtion will return value of global package variable g_invoke_source
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************************************/
  BEGIN
     RETURN igs_en_gen_017.g_invoke_source;
  END enrp_get_invoke_source;

  PROCEDURE enrp_get_term_ivr_list(
                p_term_tbl        OUT NOCOPY igs_en_ivr_pub.term_tbl_type,
                p_error_message   OUT NOCOPY VARCHAR2     ,
                p_ret_status      OUT NOCOPY VARCHAR2     ) AS
    /*
    ||  Created By : Nishikant
    ||  Created On : 15JAN2003
    ||  Purpose    : This Procedure gets a list of valid term calendars for IVR in PL/SQL Table.
    ||               These calendars should be ACTIVE LOAD calendars in system where the IVR indicator is 'Y'.
    ||
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  CURSOR c_alt_code IS
  SELECT ci.alternate_code
  FROM   igs_ca_inst ci,
         igs_ca_type ca,
         igs_ca_stat cs
  WHERE  ci.cal_type =ca.cal_type
  AND    ci.cal_status = cs.cal_status
  AND    cs.s_cal_status = 'ACTIVE'
  AND    ca.s_cal_cat = 'LOAD'
  AND    ci.ivr_display_ind = 'Y';
  counter  NUMBER := 0;

  BEGIN
  --Initialize the parameters
  p_error_message := NULL;
  p_ret_status    := 'TRUE';

  --Get all the Active term calendars for IVR
  FOR l_alt_code IN c_alt_code LOOP
      counter := counter + 1;
      p_term_tbl(counter).p_term_alt_code := l_alt_code.alternate_code;
  END LOOP;

  --If not a single term has found then set error message
  IF counter = 0 THEN
      p_error_message := 'IGS_EN_NO_TERM_FOR_IVR';
      p_ret_status    := 'FALSE';
  END IF;

  END enrp_get_term_ivr_list;

  PROCEDURE enrp_msg_string_to_list
            (
		p_message_string       IN  VARCHAR2,
		p_delimiter	       IN  VARCHAR2,
		p_init_msg_list        IN  VARCHAR2,
	        x_message_count	       OUT NOCOPY NUMBER,
                x_message_data	       OUT NOCOPY VARCHAR2
	    )
  /******************************************************************************************
  ||  Created By : smanglm
  ||  Created On : 2003/01/15
  ||  Purpose : This procedure will extract the message name and set them in message list
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************************************/

  IS
    -- local variables
    l_start_pos   NUMBER :=0;
    l_end_pos     NUMBER :=0;
    l_message_string VARCHAR2(4000);
    l_msg            VARCHAR2(30);

  BEGIN
    /*
      Initialize message stack
    */
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /*
      If input string is null then do not proceed and return
    */
    IF p_message_string IS NULL THEN
       RETURN;
    END IF;
    l_message_string := p_message_string;
    /*
       remove delimiter from start messaage string
    */
    IF substr(l_message_string,1,1) = p_delimiter THEN
       l_message_string := substr (l_message_string,2);
    END IF;
    /*
       add p_delimiter at the end, if missing
    */
    IF substr(l_message_string,-1) <> p_delimiter THEN
       l_message_string := l_message_string||p_delimiter;
    END IF;
    /*
       loop through the string and keep adding to message stack
    */
    FOR i IN 1..length(l_message_string)
    LOOP
        IF substr(l_message_string,i,1) = p_delimiter THEN
           l_end_pos   := i;
           l_msg := substr(l_message_string,l_start_pos+1,l_end_pos-l_start_pos-1);
         IF INSTR(l_msg, '*') <> 0 THEN
           FND_MESSAGE.SET_NAME('IGS',substr(l_msg,1, (INSTR(l_msg, '*') - 1 )));
           FND_MESSAGE.SET_TOKEN('UNIT_CD', substr(l_msg, (INSTR(l_msg, '*') + 1 )));
           FND_MSG_PUB.ADD;
          ELSE
           FND_MESSAGE.SET_NAME('IGS',l_msg);
           FND_MSG_PUB.ADD;
          END IF;
	ELSE
           l_start_pos:= l_end_pos;
	END IF;
        /*
	  check for exit criteria
	*/
	IF l_end_pos = length(l_message_string) THEN
	   EXIT;
	END IF;
    END LOOP;
    /*
        now get the message data and count
	Please note that if count > 1, data will null
	Calling procedure should loop through the message
	stack to retrieve all messages
    */
    FND_MSG_PUB.Count_And_Get(
                p_count => x_message_count,
                p_data  => x_message_data);

  END enrp_msg_string_to_list;


PROCEDURE enrp_validate_call_number(
              p_term_alt_code      IN VARCHAR2,
              p_call_number        IN NUMBER  ,
              p_uoo_id             OUT NOCOPY NUMBER  ,
              p_cal_type           OUT NOCOPY VARCHAR2,
              p_ci_sequence_number OUT NOCOPY NUMBER  ,
              p_error_message      OUT NOCOPY VARCHAR2,
              p_ret_status         OUT NOCOPY VARCHAR2) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 15JAN2003
  ||  Purpose    : The procedure validates the term is valid and the call number corresponds
  ||               to a valid unit section for that term.
  ||               As call number is unique within the term it takes the term calendar also and
  ||               return the valid section details else return the error message.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

l_cal_type           igs_ca_inst.cal_type%TYPE;
l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;

CURSOR c_uoo_id IS
SELECT 'X'
FROM   igs_ps_unit_ofr_opt
WHERE  call_number = p_call_number;
l_dummy VARCHAR2(1);

CURSOR c_chk_call_num_term (cp_cal_type   igs_ca_inst.cal_type%TYPE,
                            cp_ci_seq_num igs_ca_inst.sequence_number%TYPE) IS
SELECT uoo_id
FROM   igs_ps_unit_ofr_opt
WHERE  call_number = p_call_number
AND    ( cal_type, ci_sequence_number ) IN
       ( SELECT teach_cal_type, teach_ci_sequence_number
         FROM   igs_ca_load_to_teach_v
         WHERE  load_cal_type = cp_cal_type
         AND    load_ci_sequence_number = cp_ci_seq_num );

BEGIN
--Initialize the parameters
p_error_message := NULL;
p_ret_status    := 'TRUE';

--Call the procedure enrp_validate_term_alt_code to validate the paramter p_term_alt_code.
igs_en_gen_017.enrp_validate_term_alt_code(
    p_term_alt_code      => p_term_alt_code,
    p_cal_type           => l_cal_type,
    p_ci_sequence_number => l_ci_sequence_number,
    p_error_message      => p_error_message,
    p_ret_status         => p_ret_status);

IF p_ret_status = 'TRUE' THEN
    --Set the Term Calendar details
    p_cal_type           := l_cal_type;
    p_ci_sequence_number := l_ci_sequence_number;

    --Check whether the provided call number is valid or not
    OPEN c_uoo_id;
    FETCH c_uoo_id INTO l_dummy;
    IF c_uoo_id%FOUND THEN
         --Check if the provided call number falls under term calendar passed
	 --And get the uoo_id for the provided Call Number parameter
         OPEN c_chk_call_num_term( l_cal_type, l_ci_sequence_number);
         FETCH c_chk_call_num_term INTO p_uoo_id;
         IF c_chk_call_num_term%NOTFOUND THEN
              --If the Call number does not fall in the term calendar provided then set the message parameter
              FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_MISMATCH_CALL_TERM');
              FND_MSG_PUB.ADD;
              p_error_message := 'IGS_EN_MISMATCH_CALL_TERM';
         END IF;
         CLOSE c_chk_call_num_term;

    ELSE
       --If uoo_id could not found then set the error message for invalid call number
         FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_INVALID_CALL_NUMBER');
         FND_MESSAGE.SET_TOKEN('CALLNUM',p_call_number);
         FND_MSG_PUB.ADD;
         p_error_message := 'IGS_EN_INVALID_CALL_NUMBER';

    END IF;
    CLOSE c_uoo_id;
END IF;

IF p_error_message IS NOT NULL THEN
    p_ret_status    := 'FALSE';
END IF;

END enrp_validate_call_number;

  PROCEDURE enrp_validate_input_parameters
            (
		p_person_number       IN  VARCHAR2,
		p_career              IN  VARCHAR2,
		p_program_code        IN  VARCHAR2,
		p_term_alt_code       IN  VARCHAR2,
		p_call_number         IN  NUMBER,
		p_validation_level    IN  VARCHAR2,
		p_person_id           OUT NOCOPY NUMBER,
		p_person_type         OUT NOCOPY VARCHAR2,
		p_cal_type            OUT NOCOPY VARCHAR2,
		p_ci_sequence_number  OUT NOCOPY NUMBER,
		p_primary_code        OUT NOCOPY VARCHAR2,
		p_primary_version     OUT NOCOPY NUMBER,
		p_uoo_id              OUT NOCOPY NUMBER,
		p_error_message       OUT NOCOPY VARCHAR2,
		p_ret_status          OUT NOCOPY VARCHAR2
	    )
  /******************************************************************************************
  ||  Created By : smanglm
  ||  Created On : 2003/01/15
  ||  Purpose : This procedure will accept the input parameters and verify that they are
  ||            valid OSS data. If not valid data then it would return the error message.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************************************/

  IS
    -- local variables
    l_person_id                 igs_pe_person.person_id%TYPE;
    l_person_type               igs_pe_typ_instances.person_type_code%TYPE;
    l_error_message             VARCHAR2(2000);
    l_ret_status                VARCHAR2(10);
    l_primary_program_code      igs_ps_ver.course_cd%TYPE;
    l_primary_program_version   igs_ps_ver.version_number%TYPE;
    l_cal_type                  igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
    l_uoo_id                    igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_return_status             VARCHAR2(10);
    l_message_count             NUMBER;
    l_message_data              VARCHAR2(2000);


  BEGIN
    /*
        set the package variable igs_en_gen_017.g_invoke_source to IVR
    */
    igs_en_gen_017.g_invoke_source := 'IVR';
    /*
        Set the out parameter p_error_message as null and p_ret_status as 'TRUE'
    */
    p_error_message := NULL;
    p_ret_status := 'TRUE';
    /*
        Validate the person number parameter
    */
    igs_en_gen_017.enrp_validate_student
            (
	       p_person_number => p_person_number,
	       p_person_id     => l_person_id    ,
	       p_person_type   => l_person_type  ,
	       p_error_message => l_error_message,
	       p_ret_status    => l_ret_status
	    );
    IF l_ret_status = 'FALSE' THEN
       p_ret_status := l_ret_status;
       -- return as no other validation would be successful
       -- messages are not added to the parameter since they are already
       -- added to the stack
       RETURN;
    END IF;
    /*
       assign OUT parameters
    */
    p_person_id := l_person_id;
    p_person_type := l_person_type;
    /*
       got the person number and hence continue with other validation
    */
    /*
       	Validate the career and program
    */
    igs_en_ivr_pub.validate_career_program
            (
		p_api_version	 => 1.0,
		p_init_msg_list	 => FND_API.G_FALSE,
		p_commit         => FND_API.G_FALSE,
		p_person_number	 => p_person_number,
		p_career	 => p_career,
		p_program_code	 => p_program_code,
		x_primary_code	 => l_primary_program_code,
		x_primary_version=> l_primary_program_version,
		x_return_status	 => l_return_status,
		x_msg_count	 => l_message_count,
		x_msg_data	 => l_message_data
	    );
     IF l_message_data IS NOT NULL THEN
        p_ret_status := 'FALSE';
       -- messages are not added to the parameter since they are already
       -- added to the stack
     END IF;
     /*
        continue with other validation so that at one go all
	exceptions are caught.
     */
     DECLARE
        l_error_message_in             VARCHAR2(2000);
        l_ret_status_in                VARCHAR2(10);

     BEGIN
             IF p_validation_level = 'NOCALLNUM' THEN
                igs_en_gen_017.enrp_validate_term_alt_code
                    (
                        p_term_alt_code     => p_term_alt_code,
                        p_cal_type          => l_cal_type,
                        p_ci_sequence_number=> l_ci_sequence_number,
                        p_error_message     => l_error_message_in,
                        p_ret_status        => l_ret_status_in
                    );
                IF l_error_message_in IS NOT NULL OR l_ret_status_in = 'FALSE' THEN
		           p_ret_status := 'FALSE';
                   -- message already in the stack
                END IF;  -- l_error_message_in IS NOT NULL OR l_ret_status_in = 'FALSE'
	     ELSIF p_validation_level = 'WITHCALLNUM' THEN
                igs_en_gen_017.enrp_validate_call_number
		    (
                        p_term_alt_code       => p_term_alt_code,
                        p_call_number         => p_call_number,
                        p_uoo_id              => l_uoo_id,
                        p_cal_type            => l_cal_type ,
                        p_ci_sequence_number  => l_ci_sequence_number  ,
                        p_error_message       => l_error_message_in,
                        p_ret_status          => l_ret_status_in
		    );
		IF l_error_message_in IS NOT NULL OR l_ret_status_in = 'FALSE' THEN
           -- messages already added to the stack
           p_ret_status := 'FALSE';
		END IF;
             END IF;  -- p_validation_level = 'NOCALLNUM'
	     /*
	        assign OUT parameters
	     */
             p_cal_type := l_cal_type;
             p_ci_sequence_number := l_ci_sequence_number;
             p_primary_code := l_primary_program_code;
             p_primary_version := l_primary_program_version;
	     p_uoo_id := l_uoo_id;
     END;
  END enrp_validate_input_parameters;

  PROCEDURE enrp_validate_student
            (
	       p_person_number IN VARCHAR2,
	       p_person_id     OUT NOCOPY NUMBER,
	       p_person_type   OUT NOCOPY VARCHAR2,
	       p_error_message OUT NOCOPY VARCHAR2,
	       p_ret_status    OUT NOCOPY VARCHAR2
	    )
  /******************************************************************************************
  ||  Created By : smanglm
  ||  Created On : 2003/01/15
  ||  Purpose : The procedure is to validate that the student passed by 3rd party s/w is
  ||            valid person in system or not. If valid and has an fnd user then return
  ||            the person id and the user defined person type for system type of 'STUDENT'.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
	|| bdeviset      14-APR-2005      changed cursor c_vld_fnd_user for bug # 4303661
  ******************************************************************************************/

  IS
    /*
       cursor to validate if person number is valid in the system
    */
    CURSOR c_vld_person (cp_person_number  igs_pe_person_base_v.person_number%TYPE) IS
           SELECT person_id
	   FROM   igs_pe_person_base_v
	   WHERE  person_number = cp_person_number;
    l_vld_person_id 	   igs_pe_person_base_v.person_id%TYPE;

    /*
       cursor to validate that person is valid apps user in system
    */
    CURSOR c_vld_fnd_user (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
           SELECT user_id
	   FROM   fnd_user
	   WHERE  person_party_id = cp_person_id;
    l_vld_fnd_user_id  fnd_user.user_id%TYPE;

    /*
       cursor to validate that the person number is a valid 'STUDENT' in the system
    */
    CURSOR c_vld_student (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
           SELECT  person_type_code
           FROM igs_pe_typ_instances
           WHERE person_id = cp_person_id
           AND ( end_date IS NULL  OR end_date > SYSDATE )
	   AND person_type_code IN (
                                       SELECT person_type_code
                                       FROM igs_pe_person_types
                                       WHERE system_type = 'STUDENT'
				       AND closed_ind = 'N'
				    );
    l_person_type igs_pe_typ_instances.person_type_code%TYPE;

    /*
       cursor to fetch the RESP_ID and RESP_APPL_ID against the user_id
    */
    CURSOR c_fnd_user_dtls (cp_user_id fnd_user_resp_groups.user_id%TYPE) IS
           SELECT responsibility_id,
                  responsibility_application_id,
                  security_group_id
           FROM   fnd_user_resp_groups
	   WHERE  user_id = cp_user_id
	   AND    SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);
    rec_fnd_user_dtls  c_fnd_user_dtls%ROWTYPE;

  BEGIN
    /*
        Set the out parameter p_error_message as null and p_ret_status as 'TRUE'
    */
    p_error_message := NULL;
    p_ret_status := 'TRUE';
    /*
        If input parmeter is null return with error message 'IGS_GE_INVALID_PERSON_NUMBER'
    */
    IF p_person_number IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
       FND_MSG_PUB.ADD;
       p_error_message := 'IGS_GE_INVALID_PERSON_NUMBER';
       p_ret_status := 'FALSE';
       RETURN;
    END IF;
    /*
        Validate if person number is valid in the system
    */
    OPEN c_vld_person (p_person_number);
    FETCH c_vld_person INTO l_vld_person_id;
    IF c_vld_person%NOTFOUND THEN
       CLOSE c_vld_person;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
       FND_MSG_PUB.ADD;
       p_error_message := 'IGS_GE_INVALID_PERSON_NUMBER';
       p_ret_status := 'FALSE';
       RETURN;
    END IF;
    CLOSE c_vld_person;
    /*
       validate that person is valid apps user in system
    */
    OPEN c_vld_fnd_user (l_vld_person_id);
    FETCH c_vld_fnd_user INTO l_vld_fnd_user_id;
    IF c_vld_fnd_user%NOTFOUND THEN
       CLOSE c_vld_fnd_user;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PERSON_NOT_FND_USER');
       FND_MSG_PUB.ADD;
       p_error_message := 'IGS_EN_PERSON_NOT_FND_USER';
       p_ret_status := 'FALSE';
       RETURN;
    END IF;
    CLOSE c_vld_fnd_user;
    /*
        Validate that the person number is a valid 'STUDENT' in the system
    */
    OPEN c_vld_student (l_vld_person_id);
    FETCH c_vld_student INTO l_person_type;
    IF c_vld_student%NOTFOUND THEN
       CLOSE c_vld_student;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PERSON_NOT_STUDENT');
       FND_MSG_PUB.ADD;
       p_error_message := 'IGS_EN_PERSON_NOT_STUDENT';
       p_ret_status := 'FALSE';
       RETURN;
    END IF;
    CLOSE c_vld_student;
    /*
       fetch the RESP_ID and RESP_APPL_ID against the user_id
    */
    OPEN c_fnd_user_dtls (l_vld_fnd_user_id);
    FETCH c_fnd_user_dtls INTO rec_fnd_user_dtls;
    IF c_fnd_user_dtls%NOTFOUND THEN
       CLOSE c_fnd_user_dtls;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PERSON_NO_RESP');
       FND_MSG_PUB.ADD;
       p_error_message := 'IGS_EN_PERSON_NO_RESP';
       p_ret_status := 'FALSE';
       RETURN;
    END IF;
    CLOSE c_fnd_user_dtls;

    /*
       set the apps context
    */
    fnd_global.apps_initialize
               (
                 user_id                        => l_vld_fnd_user_id,
                 resp_id                        => rec_fnd_user_dtls.responsibility_id,
                 resp_appl_id                   => rec_fnd_user_dtls.responsibility_application_id,
                 security_group_id              => rec_fnd_user_dtls.security_group_id
	       );

    /*
       assign obtained values to OUT parameters
    */
    p_person_id := l_vld_person_id;
    p_person_type := l_person_type;

  END enrp_validate_student;

PROCEDURE enrp_validate_term_alt_code(
              p_term_alt_code      IN VARCHAR2,
              p_cal_type           OUT NOCOPY VARCHAR2,
              p_ci_sequence_number OUT NOCOPY NUMBER  ,
              p_error_message      OUT NOCOPY VARCHAR2,
              p_ret_status         OUT NOCOPY VARCHAR2) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 15JAN2003
  ||  Purpose    : This procedure validates that the term passed is valid or not.
  ||               If valid then return with null error message and Cal Type and
  ||               Sequence Number required for further processing.
  ||               Else return with error message.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

CURSOR c_alt_code IS
SELECT ci.cal_type,
       ci.sequence_number
FROM   igs_ca_inst ci,
       igs_ca_type ca,
       igs_ca_stat cs
WHERE  ci.alternate_code = p_term_alt_code
AND    ci.cal_type = ca.cal_type
AND    ci.cal_status = cs.cal_status
AND    cs.s_cal_status = 'ACTIVE'
AND    ca.s_cal_cat = 'LOAD'
AND    ci.ivr_display_ind = 'Y';

BEGIN
--Initialize the parameters
p_error_message := NULL;
p_ret_status    := 'TRUE';

--If the parameter Alternate Code is NULL then set the error message.
IF p_term_alt_code IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NO_TERM_DTLS');
    FND_MSG_PUB.ADD;
    p_error_message := 'IGS_EN_NO_TERM_DTLS';
    p_ret_status    := 'FALSE';
END IF;

--If the alternate code parameter is NOT NULL then validate the alternate code
--and get the cal_type and Sequence Number for the Alternate code
IF p_ret_status = 'TRUE' THEN
    OPEN c_alt_code;
    FETCH c_alt_code INTO p_cal_type, p_ci_sequence_number;

    --If the alternate code is not valid , then set the error message.
    IF c_alt_code%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_INVALID_TERM');
        FND_MESSAGE.SET_TOKEN('ALTERNATE_CODE', p_term_alt_code);
        FND_MSG_PUB.ADD;
        p_error_message := 'IGS_EN_INVALID_TERM';
        p_ret_status    := 'FALSE';
    END IF;
    CLOSE c_alt_code;
END IF;

END enrp_validate_term_alt_code;


END igs_en_gen_017;

/
