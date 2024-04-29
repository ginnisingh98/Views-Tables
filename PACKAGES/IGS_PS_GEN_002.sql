--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_002" AUTHID CURRENT_USER AS
    /* $Header: IGSPS02S.pls 120.0 2005/06/02 04:22:05 appldev noship $ */
   /* CAHNGE HISTORY
      WHO          WHEN           WHAT
      smvk         10-Oct-2003    Enh # 3052445. Added p_n_max_wlst_per_stud to the signature of crsp_ins_cv_hist.
      Nishikant   11DEC2002      ENCR027 Build (Program Length Integration). The signature of the function
                                 crsp_get_crv_eftd got modified. The pragma restriction for the functions
                                 crsp_get_crv_eftd removed since its modifying the variables in package.
				 Pragma restriction WNPS removed from the function crsp_get_crv_eftd.
      vvutukur    19-Oct-2002    Enh#2608227.Modified crsp_get_crv_eftd,crsp_ins_cv_hist.
      ayedubat    25-MAY-2001    procudure,crsp_ins_cv_hist is midified according
                                 to the DLD,PSP001-US   */

   FUNCTION crsp_get_course_ttl(
    p_course_cd IN igs_ps_course.course_cd%TYPE )
   RETURN VARCHAR2;

   FUNCTION crsp_get_crv_eftd( p_person_id    IN  NUMBER ,
                               p_course_cd    IN  VARCHAR2)
   RETURN NUMBER;
   PRAGMA RESTRICT_REFERENCES(crsp_get_crv_eftd,WNDS,WNPS);

   FUNCTION crsp_get_un_lvl(
    p_unit_cd IN VARCHAR2 ,
    p_unit_version_number IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_course_version_number IN NUMBER )
   RETURN VARCHAR2;

   PROCEDURE crsp_ins_cfos_hist(
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_field_of_study IN VARCHAR2 ,
    p_last_update_on IN DATE ,
    p_update_on IN DATE ,
    p_last_update_who IN VARCHAR2 ,
    p_percentage IN NUMBER ,
    p_major_field_ind IN VARCHAR2 DEFAULT 'N');

   PROCEDURE crsp_ins_cv_hist(
   /*************************************************************
   Created By :
   Date Created By :
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   sarakshi      27-Jan-2004    Enh##3345205, added column annual_instruction_time in the parameter list
   vvutukur      19_oct-2002    Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time as these
                                columns are obsoleted.
   ayedubat      25-MAY-2001    Added the new columns
   (reverse chronological order - newest change first)
   ***************************************************************/
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
    p_primary_program_rank IN NUMBER DEFAULT NULL,
    p_n_max_wlst_per_stud  IN NUMBER DEFAULT NULL,
    p_n_annual_instruction_time IN NUMBER DEFAULT NULL
    );

END igs_ps_gen_002;

 

/
