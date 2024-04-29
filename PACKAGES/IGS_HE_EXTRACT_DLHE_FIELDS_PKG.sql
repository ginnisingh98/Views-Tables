--------------------------------------------------------
--  DDL for Package IGS_HE_EXTRACT_DLHE_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXTRACT_DLHE_FIELDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE9DS.pls 120.1 2006/02/13 17:25:31 jbaber noship $ */

  -- Method of data collection
  PROCEDURE get_survey_method
          (p_dlhe_method          IN igs_he_stdnt_dlhe.survey_method%TYPE,
           p_hesa_method          OUT NOCOPY VARCHAR2);

  -- Employment circumstances
  PROCEDURE get_empcir
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_employment      IN  igs_he_stdnt_dlhe.Employment%TYPE,
           p_hesa_empcir        OUT NOCOPY VARCHAR2);

  -- Mode of Study
  PROCEDURE get_mode_study
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_further_study   IN  igs_he_stdnt_dlhe.Further_study%TYPE,
           p_hesa_modstudy        OUT NOCOPY VARCHAR2);

  -- Nature of employers business
  PROCEDURE get_makedo
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_business   IN  igs_he_stdnt_dlhe.Employer_business%TYPE,
           p_hesa_makedo        OUT NOCOPY VARCHAR2);

   -- Standard Industrial Classification
   PROCEDURE get_sic
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_class       IN  igs_he_stdnt_dlhe.Employer_classification%TYPE,
           p_hesa_sic        OUT NOCOPY VARCHAR2);

   -- Location of employment
   PROCEDURE get_emp_loc
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_postcode    IN  igs_he_stdnt_dlhe.Employer_postcode%TYPE,
	   p_dlhe_emp_country     IN  igs_he_stdnt_dlhe.Employer_country%TYPE,
           p_hesa_locemp        OUT NOCOPY VARCHAR2);

   -- Job title
   PROCEDURE get_job_title
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_jobtitle   IN  igs_he_stdnt_dlhe.Job_title%TYPE,
           p_hesa_jobtitle       OUT NOCOPY VARCHAR2);

    -- Standard Occupational Classification
   PROCEDURE get_occ_class
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_job_class       IN  igs_he_stdnt_dlhe.Job_classification%TYPE,
           p_hesa_soc             OUT NOCOPY VARCHAR2);

    -- Employer size
   PROCEDURE get_emp_size
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_size        IN  igs_he_stdnt_dlhe.Employer_size%TYPE,
           p_hesa_empsize       OUT NOCOPY VARCHAR2);

    -- Duration of employment
   PROCEDURE get_emp_duration
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_duration    IN  igs_he_stdnt_dlhe.Job_duration%TYPE,
           p_hesa_duration       OUT NOCOPY VARCHAR2);

     -- Salary
   PROCEDURE get_salary
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Job_salary       IN  igs_he_stdnt_dlhe.Job_salary%TYPE,
           p_hesa_salary             OUT NOCOPY VARCHAR2);

    -- Qualification required for job
   PROCEDURE get_qual_req
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_qual_req    IN  igs_he_stdnt_dlhe.Qualification_requirement%TYPE,
           p_hesa_qualreq       OUT NOCOPY VARCHAR2);

     -- Importance to employer
   PROCEDURE get_emp_imp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_imp    IN  igs_he_stdnt_dlhe.Qualification_importance%TYPE,
           p_hesa_empimp       OUT NOCOPY VARCHAR2);

   -- Career related code 1 to 8
   PROCEDURE get_career
          (p_hesa_reason    IN  igs_he_stdnt_dlhe.Job_reason1%TYPE,
           p_hesa_career       OUT NOCOPY VARCHAR2);

    -- How found job
   PROCEDURE get_job_find
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_job_source    IN  igs_he_stdnt_dlhe.Job_source%TYPE,
           p_hesa_jobfnd       OUT NOCOPY VARCHAR2);

      -- Previously employed
   PROCEDURE get_prev_emp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_previous_job    IN  igs_he_stdnt_dlhe.Previous_job%TYPE,
           p_hesa_prevemp       OUT NOCOPY VARCHAR2);

     -- Category of previous employment 1 to 6
   PROCEDURE get_prev_emp_cat
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_prevemp         IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_previous_jobtype    IN  igs_he_stdnt_dlhe.Previous_jobtype1%TYPE,
           p_hesa_prevcat       OUT NOCOPY VARCHAR2);

      -- Nature of study/training
   PROCEDURE get_nat_study
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_type    IN  igs_he_stdnt_dlhe.Further_study_type%TYPE,
           p_hesa_natstudy       OUT NOCOPY VARCHAR2);

       -- Professional subject of training
   PROCEDURE get_train_subj
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_natstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_crse_train_subj    IN  igs_he_stdnt_dlhe.Course_training_subject%TYPE,
	   p_dlhe_res_train_subj     IN  igs_he_stdnt_dlhe.Research_training_subject%TYPE,
           p_hesa_profsoct        OUT NOCOPY VARCHAR2);

      -- Institution providing study
   PROCEDURE get_inst_prov
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_natstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_prov     IN  igs_he_stdnt_dlhe.Further_study_provider%TYPE,
           p_hesa_instprov        OUT NOCOPY VARCHAR2);

    -- Type of qualification
    -- smaddali removed parameter p_hesa_natstudy from the procedure for build HECR011 ,bug#3051597
   PROCEDURE get_type_qual
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_qualaim     IN  igs_he_stdnt_dlhe.Further_study_qualaim%TYPE,
           p_hesa_typequal        OUT NOCOPY VARCHAR2);

   -- Reason for taking another course 1 to 7
   --smaddali   Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
   PROCEDURE get_study_reason2
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_reason    IN  igs_he_stdnt_dlhe.Study_reason2%TYPE,
           p_hesa_secint        OUT NOCOPY VARCHAR2);

   -- Reason for taking another course 8
   --smaddali   Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
   PROCEDURE get_study_reason8
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_other_study_reason IN igs_he_stdnt_dlhe.Other_study_reason%TYPE,
	   p_dlhe_no_study_reason    IN  igs_he_stdnt_dlhe.No_other_study_reason%TYPE,
           p_hesa_secint8        OUT NOCOPY VARCHAR2);

   -- How funding further study
   --smaddali   Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
   PROCEDURE get_funding_source
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_funding_source    IN  igs_he_stdnt_dlhe.Funding_source%TYPE,
           p_hesa_fundstudy        OUT NOCOPY VARCHAR2);

    -- Teaching employment marker
   PROCEDURE get_teaching_emp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_qualified       IN  igs_he_stdnt_dlhe.Qualified_teacher%TYPE,
           p_dlhe_teaching        IN  igs_he_stdnt_dlhe.Teacher_teaching%TYPE ,
           p_dlhe_seeking        IN  igs_he_stdnt_dlhe.Teacher_seeking%TYPE ,
           p_hesa_tchemp        OUT NOCOPY VARCHAR2);

    -- Teaching sector
   PROCEDURE get_teaching_sector
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_tchemp        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_teach_sector    IN  igs_he_stdnt_dlhe.Teaching_sector%TYPE,
           p_hesa_teachsct        OUT NOCOPY VARCHAR2);

    -- Teaching phase
   PROCEDURE get_teaching_phase
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_tchemp        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_teach_level    IN  igs_he_stdnt_dlhe.Teaching_level%TYPE,
           p_hesa_teachphs        OUT NOCOPY VARCHAR2);

    -- Reason for taking original course
   PROCEDURE get_intent
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study        IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_reason_ptcrse    IN  igs_he_stdnt_dlhe.Reason_for_PTcourse%TYPE,
           p_hesa_intent        OUT NOCOPY VARCHAR2);

   -- Employed during course
   PROCEDURE get_job_while_study
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study        IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_job_while_study    IN  igs_he_stdnt_dlhe.Job_while_studying%TYPE,
           p_hesa_empcrse        OUT NOCOPY VARCHAR2);

    -- Employer sponsorship 1 to 5
   PROCEDURE get_emp_sponsorship
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcrse         IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study        IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_emp_support    IN  igs_he_stdnt_dlhe.Employer_support1%TYPE,
           p_hesa_empspns        OUT NOCOPY VARCHAR2);

END IGS_HE_EXTRACT_DLHE_FIELDS_PKG;

 

/
