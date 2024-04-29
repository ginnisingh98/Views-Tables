--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_002" AS
  /* $Header: IGSPS02B.pls 120.3 2006/06/14 07:03:37 ckasu noship $ */
  /* CAHNGE HISTORY
  WHO        WHEN          WHAT
  ckasu     14-JUN-2006    modified as a part of bug#5299752 inorder to include attendance type
                           as parameter in crsp_get_crv_eftd PROCEDURE
  ckasu     07-MAR-2006    modified as a part of bug#5070746 inorder to include location_cd , attendance mode
                           as parameters in crsp_get_crv_eftd PROCEDURE
  ijeddy      05-nov-2003  Bug# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
  smvk       10-Oct-2003   Enh # 3052445. Added p_n_max_wlst_per_stud to the signature of crsp_ins_cv_hist.
  Nishikant  11DEC2002     ENCR027 Build (Program Length Integration). The function crsp_get_crv_eftd revamped.
  vvutukur   19-Oct-2002   Enh#2608227.Modified crsp_get_crv_eftd,crsp_ins_cv_hist.
  ayedubat   25-MAY-2001   midified the procedure,crsp_ins_cv_hist to add the new columns.
  avenkatr   29-AUG-2001   removed procedure "crsp_val_crv_quality"
  knaraset   8-Jan-2003    Modified the code to fetch alias value instead of absolete value
                           while getting the load effective date bug 2739128
 Rvivekan    26-6-2003     Bug#2931318. The logic of crsp_get_crv_eftd has been completed revamped. The function now calculates
         		attendance type byt chosing the attendance type with the greatest research percentage.

 */

  FUNCTION crsp_get_course_ttl(
  p_course_cd IN igs_ps_course.course_cd%TYPE )
  RETURN VARCHAR2 AS
  BEGIN -- crsp_get_course_ttl
    -- This module returns the IGS_PS_COURSE version IGS_PE_TITLE for a IGS_PS_COURSE code.
    -- If no IGS_PS_COURSE version is found then NULL is returned.
  DECLARE

    cst_active CONSTANT igs_ps_stat.s_course_status%TYPE  := 'ACTIVE';
    cst_planned CONSTANT igs_ps_stat.s_course_status%TYPE := 'PLANNED';

    v_title  igs_ps_ver.title%TYPE;

    CURSOR c_crv_crst IS
    SELECT crv.title
    FROM igs_ps_ver crv,
      igs_ps_stat crst
    WHERE crv.course_cd  = p_course_cd AND
      crst.course_status = crv.course_status
    ORDER BY decode( crst.s_course_status,
      cst_active, 1,
      cst_planned, 2, 3) ASC,
      crv.expiry_dt  DESC,
      crv.version_number DESC;
  BEGIN
    OPEN c_crv_crst;
    FETCH c_crv_crst INTO v_title;
    IF c_crv_crst%NOTFOUND THEN
      CLOSE c_crv_crst;
      RETURN NULL;
    END IF;
    CLOSE c_crv_crst;
    RETURN v_title;
  EXCEPTION
    WHEN OTHERS THEN
      IF (c_crv_crst%isopen) THEN
        CLOSE c_crv_crst;
      END IF;
      app_exception.raise_exception;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME','IGS_PS_GEN_002.crsp_get_course_ttl');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END crsp_get_course_ttl;

FUNCTION crsp_get_crv_eftd( p_person_id    IN  NUMBER ,
                            p_course_cd    IN  VARCHAR2)
RETURN NUMBER AS
 /*----------------------------------------------------------------------------
 || Created By :
 || Created On :
 || Purpose : Get the program length, program length measurement for a course
 ||           offering option. This is derived from program_length,program_length_measurement
 ||           fields.
 || Known limitations, enhancements or remarks :
 || Change History :
 || Who             When            What
 || (reverse chronological order - newest change first)
 || ckasu     07-MAR-2006      modified as a part of bug#5070746 inorder to include location_cd , attendance mode
 ||                            as parameters.
 || Rvivekan	 26-6-2003     Bug#2931318. The logic of this function has bee completed revamped. The function now calculates
 ||				attendance type byt chosing the attendance type with the greatest research percentage.
 || Nishikant    12MAR2003     Bug#2843854. The Cursor c_check_att_type was retrieving the Program Length and Measurement from
 ||                            the Uoo_id passed as a parameter. Now its modified to be based upon the parameters course_cd,
 ||                            version_number, cal_type, attendance_type. So that if a student has been attempted a Half Time
 ||                            Program Offering Option, and if the Program Length and Measurement are specified for a Full time
 ||                            offering option, then these will be considered. And the cursor c_coo_id removed.
 || Nishikant    11DEC2002     ENCR027 Build (Program Length Integration) . The Function revamped fully to calculate Total
 ||                            EFTD for research students based on the FT offering for the Program with the highest FTE value
 ||                            and not based on the offering the student is attempting.
 || vvutukur     19-Oct-2002   Enh#2608227.Modified cursor c_get and its usage in the code
 ||                            to fetch program length and program length measurement by removing
 ||                            references to std_ft_completion_time.
  ----------------------------------------------------------------------------*/

 CURSOR c_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT  sca.cal_type, sca.version_number,sca.location_cd,sca.attendance_mode,sca.attendance_type
      FROM    igs_en_stdnt_ps_att sca
      WHERE   sca.person_id = cp_person_id
      AND     sca.course_cd = cp_course_cd;
    --

 CURSOR c_stu_crs_atmpt_from_appl (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
    SELECT aav.acad_cal_type, acai.crv_version_number , acai.location_cd,acai.attendance_mode,acai.attendance_type
    FROM igs_ad_appl aav,
         igs_ad_ps_appl_inst acai
    WHERE acai.person_id=cp_person_id AND acai.course_cd=cp_course_cd AND
    aav.person_id = acai.person_id AND aav.admission_appl_number = acai.admission_appl_number;


 CURSOR c_check_att_type (cp_course_cd         igs_ps_ofr_opt_all.course_cd%TYPE,
                           cp_version_number    igs_ps_ofr_opt_all.version_number%TYPE,
			   cp_cal_type          igs_ps_ofr_opt_all.cal_type%TYPE,
			   cp_attendance_type   igs_ps_ofr_opt_all.attendance_type%TYPE,
                           cp_location          igs_ps_ofr_opt_all.location_cd%TYPE,
                           cp_attendance_mode   igs_ps_ofr_opt_all.attendance_mode%TYPE) IS
  SELECT program_length, program_length_measurement
  FROM   igs_ps_ofr_opt_all
  WHERE  course_cd = cp_course_cd AND
         version_number = cp_version_number AND
         cal_type = cp_cal_type AND
	 attendance_type = cp_attendance_type AND
         location_cd = cp_location AND
         attendance_mode = cp_attendance_mode AND
         program_length  IS NOT NULL AND
         program_length_measurement  IS NOT NULL;
  l_program_length              igs_ps_ofr_opt_all.program_length%TYPE;
  l_program_length_measurement  igs_ps_ofr_opt_all.program_length_measurement%TYPE;
  l_version_number    igs_en_stdnt_ps_att.version_number%TYPE;
  l_acad_cal_type     igs_ca_inst.cal_type%TYPE;
  l_message_name      fnd_new_messages.message_name%TYPE;
  l_ret_value         NUMBER := 0;
  l_total_eftd        NUMBER := 0;
  l_proglength_found   BOOLEAN :=FALSE;
  l_location_cd       igs_ps_ofr_opt_all.location_cd%TYPE;
  l_attendance_mode   igs_ps_ofr_opt_all.attendance_mode%TYPE;
  l_attendance_type   igs_ps_ofr_opt_all.attendance_type%TYPE;
BEGIN
  l_message_name := NULL;
  l_total_eftd := l_ret_value; --If returns without calculating EFTD, then p_total_eftd will be zero

  OPEN c_stu_crs_atmpt (p_person_id,
                        p_course_cd);
    FETCH c_stu_crs_atmpt INTO l_acad_cal_type, l_version_number,l_location_cd,l_attendance_mode,l_attendance_type;
    IF (c_stu_crs_atmpt%NOTFOUND) THEN
       --
       -- if not data found return from the program unit
       --
    CLOSE c_stu_crs_atmpt;
     OPEN c_stu_crs_atmpt_from_appl (p_person_id,p_course_cd);
       FETCH c_stu_crs_atmpt_from_appl INTO l_acad_cal_type, l_version_number,l_location_cd,l_attendance_mode,l_attendance_type;
       IF (c_stu_crs_atmpt_from_appl%NOTFOUND) THEN
          CLOSE c_stu_crs_atmpt_from_appl;
          l_message_name := 'IGS_EN_NO_CRS_ATMPT';
          l_total_eftd := -2;
	  RETURN l_total_eftd;
       END IF;
       CLOSE c_stu_crs_atmpt_from_appl;
    ELSE
    CLOSE c_stu_crs_atmpt;
    END IF;

	   --Get the Program Length and Program Length Measurement for the Full Time Attendance Type
	   --in the same Program offering, the student is attempting
    OPEN  c_check_att_type ( p_course_cd, l_version_number, l_acad_cal_type,l_attendance_type,l_location_cd,l_attendance_mode);
    FETCH c_check_att_type INTO l_program_length, l_program_length_measurement;

    IF c_check_att_type%FOUND AND  l_program_length IS NOT NULL  AND l_program_length_measurement IS NOT NULL THEN
	l_proglength_found:=TRUE;
	CLOSE c_check_att_type;
    ELSE
        CLOSE c_check_att_type;
    END IF;


  IF l_proglength_found=FALSE THEN
	l_message_name:='IGS_EN_FT_OFR_INCOMPL';
	l_total_eftd := 0;
        RETURN l_total_eftd;
  END IF;


         --If FT Attendance Type has been found at the Program Offering option then
         --calculate the total EFTD according to the value of Program Length and
	 --Program Length Measurement return the calculated EFTD.

         IF l_program_length_measurement = 'YEAR' THEN
             l_ret_value := l_program_length*365;
         ELSIF l_program_length_measurement = 'MONTHS' THEN
             l_ret_value := l_program_length*365/12;
         ELSIF l_program_length_measurement = 'DAYS' THEN
             l_ret_value := l_program_length;
         ELSIF l_program_length_measurement = 'WEEKS' THEN
             l_ret_value := l_program_length*7;
         ELSIF l_program_length_measurement = 'HOURS' THEN
             l_ret_value := l_program_length/24;
         ELSIF l_program_length_measurement = '10TH OF A YEAR' THEN
             l_ret_value := l_program_length*365/10;
         ELSIF l_program_length_measurement = 'MINUTES' THEN
             l_ret_value := l_program_length/(24*60);
         END IF;

         l_total_eftd := l_ret_value;
	 RETURN l_total_eftd;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END crsp_get_crv_eftd;

   FUNCTION crsp_get_un_lvl(
  p_unit_cd IN VARCHAR2 ,
  p_unit_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version_number IN NUMBER )
  RETURN VARCHAR2 AS
  BEGIN
    DECLARE
    v_unit_level igs_ps_unit_lvl.unit_level%TYPE;
    CURSOR c_cul_crv IS
    SELECT cul.unit_level
    FROM igs_ps_unit_lvl cul
    WHERE cul.course_cd = p_course_cd AND
      cul.version_number = p_course_version_number AND
      cul.unit_cd = p_unit_cd AND
      cul.version_number = p_unit_version_number;
    CURSOR c_uv IS
    SELECT uv.unit_level
    FROM igs_ps_unit_ver uv
    WHERE uv.unit_cd = p_unit_cd AND
      uv.version_number = p_unit_version_number;
  BEGIN
    -- Get the IGS_PS_UNIT level of a IGS_PS_UNIT attempt within a nominated IGS_PS_COURSE.
    -- Searches for the existence of a IGS_PS_UNIT_LVL record using the
   -- IGS_PS_UNIT.level
    -- 1. Search for a IGS_PS_UNIT_LVL record matching the IGS_PS_UNIT version and the
    -- IGS_PS_COURSE type of the nominated IGS_PS_COURSE.
   OPEN c_cul_crv;
   FETCH c_cul_crv INTO v_unit_level;
    IF (c_cul_crv%FOUND) THEN
      CLOSE c_cul_crv;
      RETURN v_unit_level;
    END IF;
    CLOSE c_cul_crv;
    OPEN c_uv;
    FETCH c_uv  INTO v_unit_level;
    IF (c_uv%NOTFOUND) THEN
      CLOSE c_uv;
      RETURN NULL;
    END IF;
    CLOSE c_uv;
    RETURN v_unit_level;
  END;
  EXCEPTION
    WHEN OTHERS THEN
    fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('NAME','IGS_PS_GEN_002.crsp_get_un_lvl');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END crsp_get_un_lvl;

  PROCEDURE crsp_ins_cfos_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_field_of_study IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER ,
  p_major_field_ind IN VARCHAR2)
  AS
  v_s_course_status igs_ps_stat.s_course_status%TYPE;
  x_rowid   VARCHAR2(25);
  l_org_id  NUMBER(15);

  CURSOR c_get_course_status IS
    SELECT s_course_status
    FROM  igs_ps_stat, igs_ps_ver
    WHERE igs_ps_ver.course_cd = p_course_cd  AND
      igs_ps_ver.version_number  = p_version_number  AND
      igs_ps_stat.course_status = igs_ps_ver.course_status;
  BEGIN
    OPEN c_get_course_status;
    FETCH c_get_course_status INTO v_s_course_status;
    CLOSE c_get_course_status;
    l_org_id := igs_ge_gen_003.get_org_id;
    IF v_s_course_status = 'ACTIVE' THEN
      igs_ps_fld_std_hist_pkg.insert_row(
      x_rowid  => x_rowid,
      x_course_cd  => p_course_cd,
      x_field_of_study => p_field_of_study,
      x_hist_start_dt => p_last_update_on,
      x_version_number => p_version_number,
      x_hist_end_dt => p_update_on,
      x_hist_who  => p_last_update_who,
      x_percentage => p_percentage,
      x_major_field_ind => p_major_field_ind,
      x_mode  => 'R',
      x_org_id   => l_org_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('NAME','IGS_PS_GEN_002.crsp_ins_cfos_hist');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END crsp_ins_cfos_hist;

  PROCEDURE crsp_ins_cv_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_review_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_end_dt IN DATE ,
  p_course_status IN VARCHAR2 ,
  p_title IN VARCHAR2 ,
  p_short_title IN VARCHAR2 ,
  p_abbreviation IN VARCHAR2 ,
  p_supp_exam_permitted_ind IN VARCHAR2 ,
  p_generic_course_ind IN VARCHAR2 ,
  p_graduate_students_ind IN VARCHAR2 ,
  p_count_intrmsn_in_time_ind IN VARCHAR2 ,
  p_intrmsn_allowed_ind IN VARCHAR2 ,
  p_course_type IN VARCHAR2 ,
  p_responsible_org_unit_cd IN VARCHAR2 ,
  p_responsible_ou_start_dt IN DATE ,
  p_govt_special_course_type IN VARCHAR2 ,
  p_qualification_recency IN NUMBER ,
  p_external_adv_stnd_limit IN NUMBER ,
  p_internal_adv_stnd_limit IN NUMBER ,
  p_contact_hours IN NUMBER ,
  p_credit_points_required IN NUMBER ,
  p_govt_course_load IN NUMBER ,
  p_std_annual_load IN NUMBER ,
  p_course_total_eftsu IN NUMBER ,
  p_max_intrmsn_duration IN NUMBER ,
  p_num_of_units_before_intrmsn IN NUMBER ,
  p_min_sbmsn_percentage IN NUMBER,
  p_min_cp_per_calendar IN NUMBER,
  p_approval_date IN DATE,
  p_external_approval_date IN DATE,
  p_federal_financial_aid IN VARCHAR2,
  p_institutional_financial_aid IN VARCHAR2,
  p_max_cp_per_teaching_period IN NUMBER,
  p_residency_cp_required IN NUMBER,
  p_state_financial_aid IN VARCHAR2,
  p_primary_program_rank IN NUMBER,
  p_n_max_wlst_per_stud IN NUMBER,
  p_n_annual_instruction_time IN NUMBER)
  AS
  v_ct_description igs_ps_type.description%TYPE;
  v_ou_description igs_or_unit.description%TYPE;
  v_gsct_description igs_ps_govt_spl_type.description%TYPE;
  x_rowid   VARCHAR(25);
  l_org_id  NUMBER(15);
  CURSOR c_find_ct_desc IS
    SELECT description
    FROM igs_ps_type
    WHERE course_type = p_course_type;
  CURSOR c_find_ou_desc IS
    SELECT party_name description
    FROM igs_or_inst_org_base_v
    WHERE party_number = p_responsible_org_unit_cd AND
  start_dt    = p_responsible_ou_start_dt;
  CURSOR c_find_gsct_desc IS
    SELECT  description
    FROM    igs_ps_govt_spl_type
    WHERE   govt_special_course_type = p_govt_special_course_type;
   /*************************************************************
   Created By :
   Date Created By :
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who           When            What
   --sommukhe 16-FEB-2006 Bug#3094371, replaced IGS_OR_UNIT by igs_or_inst_org_base_v for cursor c_find_ou_desc
   sarakshi   23-Jan-2004 Enh#3345205, added column annual_instruction_time in the TBH call
   vvutukur   19-Oct-2002 Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time as these
                          columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
   ayedubat   25-MAY-2001 Added the new columns
   (reverse chronological order - newest change first)
   ***************************************************************/
  BEGIN
    IF p_course_type IS NULL THEN
      v_ct_description := NULL;
    ELSE
      OPEN c_find_ct_desc;
      FETCH c_find_ct_desc INTO v_ct_description;
      CLOSE c_find_ct_desc;
    END IF;
    IF p_responsible_org_unit_cd IS NULL THEN
      v_ou_description := NULL;
    ELSE
      OPEN c_find_ou_desc;
    FETCH c_find_ou_desc INTO v_ou_description;
      CLOSE c_find_ou_desc;
    END IF;
    IF p_govt_special_course_type IS NULL THEN
      v_gsct_description := NULL;
    ELSE
      OPEN c_find_gsct_desc;
      FETCH c_find_gsct_desc INTO v_gsct_description;
      CLOSE c_find_gsct_desc;
    END IF;
    l_org_id := igs_ge_gen_003.get_org_id;

    igs_ps_ver_hist_pkg.insert_row(
      x_rowid        => x_rowid,
      x_course_cd                  => p_course_cd,
      x_version_number             => p_version_number,
      x_hist_start_dt              => p_last_update_on,
      x_hist_end_dt                => p_update_on,
      x_hist_who                   => p_last_update_who,
      x_start_dt                   => p_start_dt,
      x_review_dt                  => p_review_dt,
      x_expiry_dt                  => p_expiry_dt,
      x_end_dt                     => p_end_dt,
      x_course_status              => p_course_status,
      x_title                      => p_title,
      x_short_title                => p_short_title,
      x_abbreviation               => p_abbreviation,
      x_supp_exam_permitted_ind    => p_supp_exam_permitted_ind,
      x_generic_course_ind         => p_generic_course_ind,
      x_graduate_students_ind      => p_graduate_students_ind,
      x_count_intrmsn_in_time_ind  => p_count_intrmsn_in_time_ind,
      x_intrmsn_allowed_ind        => p_intrmsn_allowed_ind,
      x_course_type                => p_course_type,
      x_ct_description             => v_ct_description,
      x_responsible_org_unit_cd    => p_responsible_org_unit_cd,
      x_responsible_ou_start_dt    => p_responsible_ou_start_dt,
      x_ou_description             => v_ou_description,
      x_govt_special_course_type   => p_govt_special_course_type,
      x_gsct_description           => v_gsct_description,
      x_qualification_recency      => p_qualification_recency,
      x_external_adv_stnd_limit    => p_external_adv_stnd_limit,
      x_internal_adv_stnd_limit    => p_internal_adv_stnd_limit,
      x_contact_hours              => p_contact_hours,
      x_credit_points_required     => p_credit_points_required,
      x_govt_course_load           => p_govt_course_load,
      x_std_annual_load            => p_std_annual_load,
      x_course_total_eftsu         => p_course_total_eftsu,
      x_max_intrmsn_duration       => p_max_intrmsn_duration,
      x_num_of_units_before_intrmsn=> p_num_of_units_before_intrmsn,
      x_min_sbmsn_percentage       => p_min_sbmsn_percentage,
      x_min_cp_per_calendar        => p_min_cp_per_calendar,
      x_approval_date              => p_approval_date,
      x_external_approval_date     => p_external_approval_date,
      x_federal_financial_aid      => p_federal_financial_aid ,
      x_institutional_financial_aid=> p_institutional_financial_aid ,
      x_max_cp_per_teaching_period => p_max_cp_per_teaching_period ,
      x_residency_cp_required      => p_residency_cp_required,
      x_state_financial_aid        => p_state_financial_aid,
      x_primary_program_rank       => p_primary_program_rank,
      x_max_wlst_per_stud          => p_n_max_wlst_per_stud,
      x_mode                       => 'R',
      x_org_id                     => l_org_id,
      x_annual_instruction_time    => p_n_annual_instruction_time);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME','IGS_PS_GEN_002.crsp_ins_cv_hist');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END crsp_ins_cv_hist;


END igs_ps_gen_002;



/
