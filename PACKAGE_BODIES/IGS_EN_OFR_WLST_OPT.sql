--------------------------------------------------------
--  DDL for Package Body IGS_EN_OFR_WLST_OPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_OFR_WLST_OPT" as
/* $Header: IGSEN75B.pls 120.2 2006/01/16 22:42:18 smaddali ship $ */


  EN_SUA_REC_TYPE IGS_EN_SU_ATTEMPT_ALL%ROWTYPE;

  FUNCTION  ofr_enrollment_or_waitlist (  p_uoo_id                IN   igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                          p_session_id            IN   igs_en_su_attempt.session_id%TYPE,
                                          p_waitlist_ind          IN   VARCHAR2,
                                          p_person_number         IN   igs_pe_person.person_number%TYPE,
                                          p_course_cd             IN   igs_en_su_attempt.course_cd%TYPE,
                                          p_enr_method_type       IN   igs_en_su_attempt.enr_method_type%TYPE,
                                          p_deny_or_warn          OUT NOCOPY  VARCHAR2,
                                          p_message               OUT NOCOPY  VARCHAR2,
                                          p_cal_type              IN   igs_ca_inst.cal_type%TYPE,
                                          p_ci_sequence_number    IN   igs_ca_inst.sequence_number%TYPE,
                                          p_audit_requested       IN   VARCHAR2,
                                          p_override_cp           IN NUMBER ,
                                          p_subtitle              IN VARCHAR2 ,
                                          p_gradsch_cd            IN VARCHAR2 ,
                                          p_gs_version_num        IN NUMBER,
										                      p_core_indicator_code   IN VARCHAR2,
										                      p_calling_obj				    IN VARCHAR2
                                       ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 15-JUL-2001
  --
  --Purpose: This procedure validates the unit section selected by the student and place them in the
  --         cart or move them into waitlist .
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --myoganat   26-May-2003      Removed the code setting the override achievable CP as zero
  --                            in case of an audit attempt - (Bug# 2855870)
  --rvangala    07-OCT-2003     Value for CORE_INDICATOR_CODE passed to
  --                            IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW and IGS_EN_SU_ATTEMPT_PKG.INSERT_ROW
  --                            added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  -------------------------------------------------------------------

    l_cst_unconfirm      CONSTANT igs_ps_unit_ofr_opt.unit_section_status%TYPE   DEFAULT 'UNCONFIRM';
    l_cst_waitlisted     CONSTANT igs_ps_unit_ofr_opt.unit_section_status%TYPE   DEFAULT 'WAITLISTED';


  -- cursor which fetches unit offering option details based on the id passed as a parameter to it
    CURSOR    c_igs_ps_unit_ofr_opt(cp_uoo_id IN  igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
    SELECT    unit_cd                         ,  version_number                , uoo.cal_type   ,
              uoo.ci_sequence_number          ,  location_cd                   , unit_class     , start_dt      ,
              end_dt                          ,  uoo.row_id                    , uoo.ivrs_available_ind         ,
              uoo.call_number                 ,  uoo.unit_section_status       , uoo.unit_section_start_date    ,
              uoo.unit_section_end_date       ,  uoo.enrollment_actual         , uoo.waitlist_actual            ,
              uoo.offered_ind                 ,  uoo.state_financial_aid       , uoo.grading_schema_prcdnce_ind ,
              uoo.federal_financial_aid       ,  uoo.unit_quota                , uoo.unit_quota_reserved_places ,
              uoo.institutional_financial_aid ,  uoo.unit_contact              , uoo.grading_schema_cd          ,
              uoo.gs_version_number           ,  uoo.owner_org_unit_cd         , uoo.attendance_required_ind    ,
              uoo.reserved_seating_allowed    ,  uoo.special_permission_ind    , uoo.ss_display_ind             ,
              uoo.ss_enrol_ind                ,  uoo.dir_enrollment            , uoo.enr_from_wlst              ,
              uoo.inq_not_wlst                ,  uoo.anon_unit_grading_ind     , uoo.anon_assess_grading_ind    ,
              uoo.rev_account_cd              ,  uoo.non_std_usec_ind          , uoo.auditable_ind              ,
              uoo.audit_permission_ind
    FROM      igs_ps_unit_ofr_opt  uoo,  igs_ca_inst ci
    WHERE     uoo.cal_type            =  ci.cal_type
    AND       uoo.ci_sequence_number  =  ci.sequence_number
    AND       uoo_id                  =  cp_uoo_id ;

    -- local rowtype variable for above cursor
    l_c_igs_ps_unit_ofr_opt   c_igs_ps_unit_ofr_opt%ROWTYPE ;

    -- cursor which picks up person id corresponding to person number passed as parameter
    CURSOR    c_igs_pe_person(cp_person_number   igs_pe_person.person_number%TYPE) IS
    SELECT    party_id
    FROM      hz_parties
    WHERE     party_number    =  cp_person_number ;

    -- local rowtype variable for above cursor
    l_c_igs_pe_person    c_igs_pe_person%ROWTYPE        ;
    -- local variables
    l_rowid              igs_en_su_attempt.row_id%TYPE  ;
    l_person_id          igs_pe_person.person_id%TYPE   ;
    l_result             BOOLEAN DEFAULT FALSE          ;
    l_deny_or_warn_flag  VARCHAR2(1000)                 ;
    l_ret_flag           BOOLEAN DEFAULT FALSE          ;
    l_rsv_seat_ext_id    igs_ps_rsv_ext.rsv_ext_id%TYPE ;
    l_message            VARCHAR2(32767) DEFAULT NULL   ;
    l_message_name       VARCHAR2(32767) DEFAULT NULL   ;
    l_app_short_name     VARCHAR2(1000)  DEFAULT 'IGS'  ;

    -- cursor which picks up all the details from reserved seat utilisation table
    CURSOR    c_igs_ps_rsv_ext(cp_rsv_ext_id  igs_ps_rsv_ext.rsv_ext_id%TYPE) IS
    SELECT    rowid         ,  rsv_ext_id      ,  uoo_id               , priority_id  ,
              preference_id ,  rsv_level       ,  actual_seat_enrolled , created_by   ,
              creation_date ,  last_updated_by ,  last_update_date     , last_update_login
    FROM      igs_ps_rsv_ext
    WHERE     rsv_ext_id  = cp_rsv_ext_id ;

    -- local rowtype variable for above cursor
    l_c_igs_ps_rsv_ext  c_igs_ps_rsv_ext%ROWTYPE ;

    CURSOR   c_igs_en_su_attempt(cp_rowid VARCHAR2) IS
    SELECT   su.*
    FROM     igs_en_su_attempt_all su
    WHERE    su.rowid = cp_rowid ;

    l_c_igs_en_su_attempt       c_igs_en_su_attempt%ROWTYPE ;
    l_override_achievable_cp    igs_en_su_attempt.override_achievable_cp%TYPE;
    old_references    EN_SUA_REC_TYPE%TYPE;
    new_references    EN_SUA_REC_TYPE%TYPE;
		l_ss_src_ind			igs_en_su_attempt.ss_source_ind%TYPE;

		-- cursor to get person type
		CURSOR cur_per_typ IS
		SELECT person_type_code
		FROM igs_pe_person_types
		WHERE system_type = 'OTHER';
		l_cur_per_typ cur_per_typ%ROWTYPE;
		lv_person_type igs_pe_person_types.person_type_code%TYPE;

    -- cursor tp get system person type
		CURSOR cur_sys_pers_type(cp_person_type_code VARCHAR2) IS
		SELECT system_type
		FROM igs_pe_person_types
		WHERE person_type_code = cp_person_type_code;

		l_sys_per_type		igs_pe_person_types.system_type%TYPE;

  BEGIN
    IGS_GE_MSG_STACK.INITIALIZE;
    --fetch the person id corresponding to person number passed as parameter
    OPEN   c_igs_pe_person( cp_person_number => p_person_number) ;
    FETCH  c_igs_pe_person  INTO l_c_igs_pe_person ;
    --person number passed as parameter does not exist
    IF  c_igs_pe_person%NOTFOUND THEN
      CLOSE  c_igs_pe_person ;
      p_message  := 'IGS_PE_PERS_NOT_EXIST' ;
      RETURN (FALSE) ;
    END IF;
    l_person_id  := l_c_igs_pe_person.party_id ;
    CLOSE c_igs_pe_person ;

    -- fetch the uoo id details
    OPEN   c_igs_ps_unit_ofr_opt( p_uoo_id) ;
    FETCH  c_igs_ps_unit_ofr_opt  INTO l_c_igs_ps_unit_ofr_opt ;
    IF     c_igs_ps_unit_ofr_opt%NOTFOUND THEN
      CLOSE c_igs_ps_unit_ofr_opt ;
      p_message  := 'IGS_EN_UOO_NOT_EXIST' ;
      RETURN (FALSE) ;
    END IF;
    CLOSE  c_igs_ps_unit_ofr_opt ;

		OPEN cur_per_typ;
		FETCH cur_per_typ INTO l_cur_per_typ;
		lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_course_cd),l_cur_per_typ.person_type_code);
		CLOSE cur_per_typ;

		OPEN cur_sys_pers_type(lv_person_type);
		FETCH cur_sys_pers_type INTO l_sys_per_type;
		CLOSE cur_sys_pers_type;

    -- set the source indicator flag
		IF p_calling_obj =  'JOB'  THEN

			l_ss_src_ind := 'A';

		ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN

			l_ss_src_ind := 'P';

		ELSIF p_calling_obj IN ('SWAP','SUBMITSWAP') THEN

			l_ss_src_ind := 'S';

    ELSIF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN

			IF l_sys_per_type = 'STUDENT' THEN
				l_ss_src_ind := 'N';
			ELSE
				l_ss_src_ind := 'A';
			END IF;

	  END IF;

    FOR  l_c_igs_ps_unit_ofr_opt  IN c_igs_ps_unit_ofr_opt(cp_uoo_id => p_uoo_id)
    LOOP
      -- creates a record in the table igs_en_su_attempt with unit_attempt_status = unconfirm
      igs_en_su_attempt_pkg.insert_row (
                                     X_ROWID                        =>     l_rowid                                    ,
                                     X_PERSON_ID                    =>     l_person_id                                ,
                                     X_COURSE_CD                    =>     p_course_cd                                ,
                                     X_UNIT_CD                      =>     l_c_igs_ps_unit_ofr_opt.unit_cd            ,
                                     X_CAL_TYPE                     =>     l_c_igs_ps_unit_ofr_opt.cal_type           ,
                                     X_CI_SEQUENCE_NUMBER           =>     l_c_igs_ps_unit_ofr_opt.ci_sequence_number ,
                                     X_VERSION_NUMBER               =>     l_c_igs_ps_unit_ofr_opt.version_number     ,
                                     X_LOCATION_CD                  =>     l_c_igs_ps_unit_ofr_opt.location_cd        ,
                                     X_UNIT_CLASS                   =>     l_c_igs_ps_unit_ofr_opt.unit_class         ,
                                     X_CI_START_DT                  =>     l_c_igs_ps_unit_ofr_opt.start_dt           ,
                                     X_CI_END_DT                    =>     l_c_igs_ps_unit_ofr_opt.end_dt             ,
                                     X_UOO_ID                       =>     p_uoo_id                                   ,
                                     X_ENROLLED_DT                  =>     NULL                                       ,
                                     X_UNIT_ATTEMPT_STATUS          =>     l_cst_unconfirm                            ,
                                     X_ADMINISTRATIVE_UNIT_STATUS   =>     NULL                                       ,
                                     X_DISCONTINUED_DT              =>     NULL                                       ,
                                     X_RULE_WAIVED_DT               =>     NULL                                       ,
                                     X_RULE_WAIVED_PERSON_ID        =>     NULL                                       ,
                                     X_NO_ASSESSMENT_IND            =>     NVL(p_audit_requested,'N')                          , -- value passed to indicate that audit is requeted or not
                                     X_SUP_UNIT_CD                  =>     NULL                                       ,
                                     X_SUP_VERSION_NUMBER           =>     NULL                                       ,
                                     X_EXAM_LOCATION_CD             =>     NULL                                       ,
                                     X_ALTERNATIVE_TITLE            =>     p_subtitle                                 ,
                                     X_OVERRIDE_ENROLLED_CP         =>     p_override_cp                              ,
                                     X_OVERRIDE_EFTSU               =>     NULL                                       ,
                                     X_OVERRIDE_ACHIEVABLE_CP       =>     l_override_achievable_cp                   , -- selective values passed based on whether audit is requeted or not
                                     X_OVERRIDE_OUTCOME_DUE_DT      =>     NULL                                       ,
                                     X_OVERRIDE_CREDIT_REASON       =>     NULL                                       ,
                                     X_ADMINISTRATIVE_PRIORITY      =>     NULL                                       ,
                                     X_WAITLIST_DT                  =>     NULL                                       ,
                                     X_DCNT_REASON_CD               =>     NULL                                       ,
                                     X_MODE                         =>     'R'                                        ,
                                     X_ORG_ID                       =>     TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'))     ,
                                     X_GS_VERSION_NUMBER            =>     p_gs_version_num                          ,
                                     X_ENR_METHOD_TYPE              =>     p_enr_method_type                          ,
                                     X_FAILED_UNIT_RULE             =>     NULL                                       ,
                                     X_CART                         =>     NULL                                       ,
                                     X_RSV_SEAT_EXT_ID              =>     NULL                                       ,
                                     X_ORG_UNIT_CD                  =>     NULL                                       ,
                                     -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                     X_SESSION_ID                   =>     p_session_id,
                                     -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                     X_GRADING_SCHEMA_CODE          =>     p_gradsch_cd                                    ,
                                     --Added the column Deg_Aud_Detail_Id as part of Degree Audit Interface build. (Bug# 2033208) - pradhakr
                                     X_DEG_AUD_DETAIL_ID            =>     NULL,
                                     X_STUDENT_CAREER_TRANSCRIPT    =>  NULL ,
                                     X_STUDENT_CAREER_STATISTICS    =>  NULL,
                                     X_ATTRIBUTE_CATEGORY           => NULL,
                                     X_ATTRIBUTE1                   => NULL,
                                     X_ATTRIBUTE2                   => NULL,
                                     X_ATTRIBUTE3                   => NULL,
                                     X_ATTRIBUTE4                   => NULL,
                                     X_ATTRIBUTE5                   => NULL,
                                     X_ATTRIBUTE6                   => NULL,
                                     X_ATTRIBUTE7                   => NULL,
                                     X_ATTRIBUTE8                   => NULL,
                                     X_ATTRIBUTE9                   => NULL,
                                     X_ATTRIBUTE10                  => NULL,
                                     X_ATTRIBUTE11                  => NULL,
                                     X_ATTRIBUTE12                  => NULL,
                                     X_ATTRIBUTE13                  => NULL,
                                     X_ATTRIBUTE14                  => NULL,
                                     X_ATTRIBUTE15                  => NULL,
                                     X_ATTRIBUTE16                  => NULL,
                                     X_ATTRIBUTE17                  => NULL,
                                     X_ATTRIBUTE18                  => NULL,
                                     X_ATTRIBUTE19                  => NULL,
                                     X_ATTRIBUTE20                  => NULL,
                                     X_WAITLIST_MANUAL_IND          => 'N', --Added by mesriniv for Bug 2554109 Mini Waitlist Build.,
                                     X_WLST_PRIORITY_WEIGHT_NUM     => NULL,
                                     X_WLST_PREFERENCE_WEIGHT_NUM   => NULL,
                                     X_CORE_INDICATOR_CODE          => p_core_indicator_code,
                                     X_UPD_AUDIT_FLAG               => 'N',
                                     X_SS_SOURCE_IND	              => l_ss_src_ind

                                );
        -- validate_combined_unit is called here
        l_result     :=  igs_en_enroll_wlst.validate_combined_unit
                                                     (
                                                         p_person_id           =>  l_person_id                                ,
                                                         p_unit_cd             =>  l_c_igs_ps_unit_ofr_opt.unit_cd            ,
                                                         p_version_number      =>  l_c_igs_ps_unit_ofr_opt.version_number     ,
                                                         p_cal_type            =>  p_cal_type ,     -- load calendar
                                                         p_ci_sequence_number  =>  p_ci_sequence_number ,   -- load calendar
                                                         p_location_cd         =>  l_c_igs_ps_unit_ofr_opt.location_cd        ,
                                                         p_unit_class          =>  l_c_igs_ps_unit_ofr_opt.unit_class         ,
                                                         p_uoo_id              =>  p_uoo_id                                   ,
                                                         p_course_cd           =>  p_course_cd                                ,
                                                         p_enr_method_type     =>  p_enr_method_type                          ,
                                                         p_message_name        =>  p_message                                  ,
                                                         p_deny_warn           =>  l_deny_or_warn_flag,
							                                           p_calling_obj         => p_calling_obj
                                                     ) ;
           p_deny_or_warn  :=  l_deny_or_warn_flag;
        -- If all the validations are successful and waitlist indicator = 'N'
        OPEN   c_igs_en_su_attempt(l_rowid);
        FETCH  c_igs_en_su_attempt INTO l_c_igs_en_su_attempt ;
        CLOSE  c_igs_en_su_attempt ;

        old_references := l_c_igs_en_su_attempt ;

        IF (l_result AND p_waitlist_ind = 'N') THEN

          -- update sua record with cart = 'y'
          igs_en_su_attempt_pkg.update_row (
                                        X_ROWID                        =>     l_rowid                         ,
                                        X_PERSON_ID                    =>     l_c_igs_en_su_attempt.person_id                      ,
                                        X_COURSE_CD                    =>     l_c_igs_en_su_attempt.course_cd                      ,
                                        X_UNIT_CD                      =>     l_c_igs_en_su_attempt.unit_cd                        ,
                                        X_CAL_TYPE                     =>     l_c_igs_en_su_attempt.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     l_c_igs_en_su_attempt.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     l_c_igs_en_su_attempt.version_number                 ,
                                        X_LOCATION_CD                  =>     l_c_igs_en_su_attempt.location_cd                    ,
                                        X_UNIT_CLASS                   =>     l_c_igs_en_su_attempt.unit_class                     ,
                                        X_CI_START_DT                  =>     l_c_igs_en_su_attempt.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     l_c_igs_en_su_attempt.ci_end_dt                      ,
                                        X_UOO_ID                       =>     l_c_igs_en_su_attempt.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     l_c_igs_en_su_attempt.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     l_c_igs_en_su_attempt.unit_attempt_status            ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_c_igs_en_su_attempt.administrative_unit_status     ,
                                        X_DISCONTINUED_DT              =>     l_c_igs_en_su_attempt.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     l_c_igs_en_su_attempt.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     l_c_igs_en_su_attempt.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     l_c_igs_en_su_attempt.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     l_c_igs_en_su_attempt.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     l_c_igs_en_su_attempt.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     l_c_igs_en_su_attempt.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     l_c_igs_en_su_attempt.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     l_c_igs_en_su_attempt.override_enrolled_cp           ,
                                        X_OVERRIDE_EFTSU               =>     l_c_igs_en_su_attempt.override_eftsu                 ,
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_c_igs_en_su_attempt.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_c_igs_en_su_attempt.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     l_c_igs_en_su_attempt.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     l_c_igs_en_su_attempt.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     l_c_igs_en_su_attempt.waitlist_dt                    ,
                                        X_DCNT_REASON_CD               =>     l_c_igs_en_su_attempt.dcnt_reason_cd                 ,
                                        X_MODE                         =>     'R'                                                  ,
                                        X_GS_VERSION_NUMBER            =>     l_c_igs_en_su_attempt.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     l_c_igs_en_su_attempt.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     l_c_igs_en_su_attempt.failed_unit_rule               ,
                                        X_CART                         =>     substr(igs_en_gen_017.enrp_get_invoke_source,1,1),
                                        X_RSV_SEAT_EXT_ID              =>     l_c_igs_en_su_attempt.rsv_seat_ext_id                ,
                                        X_ORG_UNIT_CD                  =>     l_c_igs_en_su_attempt.org_unit_cd                    ,
                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                        X_SESSION_ID                   =>     l_c_igs_en_su_attempt.session_id,
                                        -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                        X_GRADING_SCHEMA_CODE          =>     l_c_igs_en_su_attempt.grading_schema_code            ,
                                        --Added the column Deg_Aud_Detail_Id as part of Degree Audit Interface build. (Bug# 2033208)- pradhakr
                                        X_DEG_AUD_DETAIL_ID            =>     l_c_igs_en_su_attempt.deg_aud_detail_id    ,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_c_igs_en_su_attempt.student_career_transcript,
                                        X_STUDENT_CAREER_STATISTICS    =>      l_c_igs_en_su_attempt.student_career_statistics,
                                        X_ATTRIBUTE_CATEGORY           =>      l_c_igs_en_su_attempt.attribute_category,
                                        X_ATTRIBUTE1                   =>      l_c_igs_en_su_attempt.attribute1,
                                        X_ATTRIBUTE2                   =>      l_c_igs_en_su_attempt.attribute2,
                                        X_ATTRIBUTE3                   =>      l_c_igs_en_su_attempt.attribute3,
                                        X_ATTRIBUTE4                   =>      l_c_igs_en_su_attempt.attribute4,
                                        X_ATTRIBUTE5                   =>      l_c_igs_en_su_attempt.attribute5,
                                        X_ATTRIBUTE6                   =>      l_c_igs_en_su_attempt.attribute6,
                                        X_ATTRIBUTE7                   =>      l_c_igs_en_su_attempt.attribute7,
                                        X_ATTRIBUTE8                   =>      l_c_igs_en_su_attempt.attribute8,
                                        X_ATTRIBUTE9                   =>      l_c_igs_en_su_attempt.attribute9,
                                        X_ATTRIBUTE10                  =>      l_c_igs_en_su_attempt.attribute10,
                                        X_ATTRIBUTE11                  =>      l_c_igs_en_su_attempt.attribute11,
                                        X_ATTRIBUTE12                  =>      l_c_igs_en_su_attempt.attribute12,
                                        X_ATTRIBUTE13                  =>      l_c_igs_en_su_attempt.attribute13,
                                        X_ATTRIBUTE14                  =>      l_c_igs_en_su_attempt.attribute14,
                                        X_ATTRIBUTE15                  =>      l_c_igs_en_su_attempt.attribute15,
                                        X_ATTRIBUTE16                  =>      l_c_igs_en_su_attempt.attribute16,
                                        X_ATTRIBUTE17                  =>      l_c_igs_en_su_attempt.attribute17,
                                        X_ATTRIBUTE18                  =>      l_c_igs_en_su_attempt.attribute18,
                                        X_ATTRIBUTE19                  =>      l_c_igs_en_su_attempt.attribute19,
                                        X_ATTRIBUTE20                  =>      l_c_igs_en_su_attempt.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>      l_c_igs_en_su_attempt.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.,
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>      l_c_igs_en_su_attempt.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>      l_c_igs_en_su_attempt.wlst_preference_weight_num,
                                        X_CORE_INDICATOR_CODE          =>      l_c_igs_en_su_attempt.core_indicator_code,
                                        X_UPD_AUDIT_FLAG               =>      l_c_igs_en_su_attempt.upd_audit_flag,
                                        X_SS_SOURCE_IND				         =>	      l_c_igs_en_su_attempt.ss_source_ind
                                     ) ;
                                   l_ret_flag := TRUE ;

           OPEN   c_igs_en_su_attempt(l_rowid);
           FETCH  c_igs_en_su_attempt INTO new_references;
           CLOSE c_igs_en_su_attempt ;

           igs_en_sua_api.upd_enrollment_counts('UPDATE',
                                                old_references,
                                                new_references);


        -- if validations are successful and waitlist indicator = 'Y' or validations fail and deny_warn_flag = 'warn' and waitlist indicator = 'Y'
        ELSIF ((l_result  AND  p_waitlist_ind = 'Y') OR (NOT l_result AND  l_deny_or_warn_flag = 'WARN' AND  p_waitlist_ind = 'Y' )) THEN
          -- update sua record with cart = 'n' and unit_attempt_status = 'waitlisted'

          igs_en_su_attempt_pkg.update_row (
                                        X_ROWID                        =>     l_rowid                                              ,
                                        X_PERSON_ID                    =>     l_c_igs_en_su_attempt.person_id                      ,
                                        X_COURSE_CD                    =>     l_c_igs_en_su_attempt.course_cd                      ,
                                        X_UNIT_CD                      =>     l_c_igs_en_su_attempt.unit_cd                        ,
                                        X_CAL_TYPE                     =>     l_c_igs_en_su_attempt.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     l_c_igs_en_su_attempt.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     l_c_igs_en_su_attempt.version_number                 ,
                                        X_LOCATION_CD                  =>     l_c_igs_en_su_attempt.location_cd                    ,
                                        X_UNIT_CLASS                   =>     l_c_igs_en_su_attempt.unit_class                     ,
                                        X_CI_START_DT                  =>     l_c_igs_en_su_attempt.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     l_c_igs_en_su_attempt.ci_end_dt                      ,
                                        X_UOO_ID                       =>     l_c_igs_en_su_attempt.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     l_c_igs_en_su_attempt.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     l_cst_waitlisted                                     ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_c_igs_en_su_attempt.administrative_unit_status     ,
                                        X_DISCONTINUED_DT              =>     l_c_igs_en_su_attempt.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     l_c_igs_en_su_attempt.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     l_c_igs_en_su_attempt.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     l_c_igs_en_su_attempt.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     l_c_igs_en_su_attempt.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     l_c_igs_en_su_attempt.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     l_c_igs_en_su_attempt.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     l_c_igs_en_su_attempt.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     l_c_igs_en_su_attempt.override_enrolled_cp           ,
                                        X_OVERRIDE_EFTSU               =>     l_c_igs_en_su_attempt.override_eftsu                 ,
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_c_igs_en_su_attempt.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_c_igs_en_su_attempt.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     l_c_igs_en_su_attempt.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     l_c_igs_en_su_attempt.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     SYSDATE, --l_c_igs_en_su_attempt.waitlist_dt         , -- modification done as per the Bug# 2335455
                                        X_DCNT_REASON_CD               =>     l_c_igs_en_su_attempt.dcnt_reason_cd                 ,
                                        X_MODE                         =>     'R'                                                  ,
                                        X_GS_VERSION_NUMBER            =>     l_c_igs_en_su_attempt.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     l_c_igs_en_su_attempt.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     l_c_igs_en_su_attempt.failed_unit_rule               ,
                                        X_CART                         =>     'N'                                                  ,
                                        X_RSV_SEAT_EXT_ID              =>     l_c_igs_en_su_attempt.rsv_seat_ext_id                ,
                                        X_ORG_UNIT_CD                  =>     l_c_igs_en_su_attempt.org_unit_cd                    ,
                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                        X_SESSION_ID                   =>     l_c_igs_en_su_attempt.session_id,
                                        -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                        X_GRADING_SCHEMA_CODE          =>     l_c_igs_en_su_attempt.grading_schema_code            ,
                                        --Added the column Deg_Aud_Detail_Id as part of Degree Audit Interface build. (Bug# 2033208)- pradhakr
                                        X_DEG_AUD_DETAIL_ID            =>     l_c_igs_en_su_attempt.deg_aud_detail_id,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_c_igs_en_su_attempt.student_career_transcript,
                                        X_STUDENT_CAREER_STATISTICS    =>     l_c_igs_en_su_attempt.student_career_statistics,
                                        X_ATTRIBUTE_CATEGORY           =>     l_c_igs_en_su_attempt.attribute_category,
                                        X_ATTRIBUTE1                   =>     l_c_igs_en_su_attempt.attribute1,
                                        X_ATTRIBUTE2                   =>     l_c_igs_en_su_attempt.attribute2,
                                        X_ATTRIBUTE3                   =>     l_c_igs_en_su_attempt.attribute3,
                                        X_ATTRIBUTE4                   =>     l_c_igs_en_su_attempt.attribute4,
                                        X_ATTRIBUTE5                   =>     l_c_igs_en_su_attempt.attribute5,
                                        X_ATTRIBUTE6                   =>     l_c_igs_en_su_attempt.attribute6,
                                        X_ATTRIBUTE7                   =>     l_c_igs_en_su_attempt.attribute7,
                                        X_ATTRIBUTE8                   =>     l_c_igs_en_su_attempt.attribute8,
                                        X_ATTRIBUTE9                   =>     l_c_igs_en_su_attempt.attribute9,
                                        X_ATTRIBUTE10                  =>     l_c_igs_en_su_attempt.attribute10,
                                        X_ATTRIBUTE11                  =>     l_c_igs_en_su_attempt.attribute11,
                                        X_ATTRIBUTE12                  =>     l_c_igs_en_su_attempt.attribute12,
                                        X_ATTRIBUTE13                  =>     l_c_igs_en_su_attempt.attribute13,
                                        X_ATTRIBUTE14                  =>     l_c_igs_en_su_attempt.attribute14,
                                        X_ATTRIBUTE15                  =>     l_c_igs_en_su_attempt.attribute15,
                                        X_ATTRIBUTE16                  =>     l_c_igs_en_su_attempt.attribute16,
                                        X_ATTRIBUTE17                  =>     l_c_igs_en_su_attempt.attribute17,
                                        X_ATTRIBUTE18                  =>     l_c_igs_en_su_attempt.attribute18,
                                        X_ATTRIBUTE19                  =>     l_c_igs_en_su_attempt.attribute19,
                                        X_ATTRIBUTE20                  =>     l_c_igs_en_su_attempt.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>     l_c_igs_en_su_attempt.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>     l_c_igs_en_su_attempt.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     l_c_igs_en_su_attempt.wlst_preference_weight_num,
										X_CORE_INDICATOR_CODE          =>     l_c_igs_en_su_attempt.core_indicator_code,
										X_UPD_AUDIT_FLAG			   =>     l_c_igs_en_su_attempt.upd_audit_flag,
										X_SS_SOURCE_IND				   =>	  l_c_igs_en_su_attempt.ss_source_ind
                                   ) ;
           --increase the waitlist actual by 1
           /* the waitlist actual will be incremented through the TBH of IGS_EN_SU_ATTEMPT
              this has been done to centralize the updation of all the statistics and status related columns */

           p_deny_or_warn  :=  l_deny_or_warn_flag;
           l_ret_flag :=  TRUE;

          -- since a waitlisetd unit could  contribute to the fee we need
          -- to create a TODO record to recalculate the fee when a waitlisted unit
          -- is added. The unit would contribute towards the CP or fee based on the
          -- profile IGS_EN_INCL_WLST_CP
           IGS_SS_EN_WRAPPERS.call_fee_ass (
             p_person_id => l_person_id,
             p_cal_type => p_cal_type, -- load
             p_sequence_number => p_ci_sequence_number, -- load
             p_course_cd => l_c_igs_en_su_attempt.course_cd,
             p_unit_cd => l_c_igs_en_su_attempt.unit_cd,
             p_uoo_id => l_c_igs_en_su_attempt.uoo_id
           );


           OPEN   c_igs_en_su_attempt(l_rowid);
           FETCH  c_igs_en_su_attempt INTO new_references;
           CLOSE  c_igs_en_su_attempt ;

           igs_en_sua_api.upd_enrollment_counts( 'UPDATE',
                                                 old_references,
                                                 new_references);


        ELSIF ( NOT l_result AND  l_deny_or_warn_flag = 'DENY' ) THEN
          -- update igs_ps_rsv_ext only when l_c_igs_en_su_attempt.rsv_seat_ext_id is not null
          IF l_c_igs_en_su_attempt.rsv_seat_ext_id IS NOT NULL THEN
                  OPEN   c_igs_ps_rsv_ext(cp_rsv_ext_id => l_c_igs_en_su_attempt.rsv_seat_ext_id ) ;
                  FETCH  c_igs_ps_rsv_ext  INTO l_c_igs_ps_rsv_ext ;
                  igs_ps_rsv_ext_pkg.update_row(
                                              x_rowid                        =>   l_c_igs_ps_rsv_ext.rowid                            ,
                                              x_rsv_ext_id                   =>   l_c_igs_ps_rsv_ext.rsv_ext_id                       ,
                                              x_uoo_id                       =>   l_c_igs_ps_rsv_ext.uoo_id                           ,
                                              x_priority_id                  =>   l_c_igs_ps_rsv_ext.priority_id                      ,
                                              x_preference_id                =>   l_c_igs_ps_rsv_ext.preference_id                    ,
                                              x_rsv_level                    =>   l_c_igs_ps_rsv_ext.rsv_level                        ,
                                              x_actual_seat_enrolled         =>   NVL(l_c_igs_ps_rsv_ext.actual_seat_enrolled,0) - 1  ,
                                              x_mode                         =>   'R'
                                             );
                  CLOSE c_igs_ps_rsv_ext ;
          END IF;

           p_deny_or_warn  :=  l_deny_or_warn_flag;
           l_ret_flag :=  FALSE ;
        END IF;

    END LOOP ;
    RETURN (l_ret_flag) ;
  END ofr_enrollment_or_waitlist ;


END igs_en_ofr_wlst_opt ;

/
