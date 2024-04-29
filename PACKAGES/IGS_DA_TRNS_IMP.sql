--------------------------------------------------------
--  DDL for Package IGS_DA_TRNS_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_TRNS_IMP" AUTHID CURRENT_USER AS
/* $Header: IGSDA12S.pls 120.0 2005/10/14 10:33:37 appldev noship $ */
   TYPE trans_cur_rec IS RECORD (

      transcript_id                 igs_ad_transcript.transcript_id%TYPE,
      education_id                  igs_ad_transcript.education_id%TYPE,
      term_details_id               igs_ad_term_details.term_details_id%TYPE,
      unit_details_id               igs_ad_term_unitdtls.unit_details_id%TYPE,

      term_type                     igs_ad_transcript.term_type%TYPE,
      term                          igs_ad_term_details.term%TYPE,
      start_date                    igs_ad_term_details.start_date%TYPE,
      end_date                      igs_ad_term_details.end_date%TYPE,
      unit                          igs_ad_term_unitdtls.unit%TYPE,
      person_id                     hz_education.party_id%TYPE,
      unit_name                     igs_ad_term_unitdtls.unit_name%TYPE,
      cp_attempted                     igs_ad_term_unitdtls.cp_attempted%TYPE,
      cp_earned                     igs_ad_term_unitdtls.cp_earned%TYPE,
      grade                         igs_ad_term_unitdtls.grade%TYPE,
      unit_grade_points             igs_ad_term_unitdtls.unit_grade_points%TYPE,
      prev_institution_code         igs_ad_acad_history_v.institution_code%TYPE
      );

-- This function is called to create a new / update an existing academic history record and
-- term / unit details corresponding to a source unit.

   PROCEDURE create_acad_hist_rec (
      p_batch_id                IN              igs_da_req_stdnts.batch_id%TYPE,
      p_program_cd              IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      p_person_id_code          IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type     IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_term_type               IN              VARCHAR2,
      p_term                    IN              igs_ad_term_details.term%TYPE,
      p_start_date              IN              VARCHAR2,
      p_end_date                IN              VARCHAR2,
      p_source_course_subject   IN              VARCHAR2,
      p_source_course_num       IN              VARCHAR2,
      p_unit_name               IN              igs_ad_term_unitdtls.unit_name%TYPE,
      p_inst_id_code            IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_inst_id_code_type       IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_cp_attempted            IN              igs_ad_term_unitdtls.cp_attempted%TYPE,
      p_cp_earned               IN              igs_ad_term_unitdtls.cp_earned%TYPE,
      p_grade                   IN              igs_ad_term_unitdtls.grade%TYPE,
      p_unit_grade_points       IN              igs_ad_term_unitdtls.unit_grade_points%TYPE,
      p_unit_details_id         OUT NOCOPY      igs_ad_term_unitdtls.unit_details_id%TYPE
   );

-- This function is called to create a new / update an existing advanced standing record

   PROCEDURE create_adv_stnd_unit (
      p_batch_id                   IN   igs_da_rqst.batch_id%TYPE,
      p_unit_details_id            IN   igs_ad_term_unitdtls.unit_details_id%TYPE,
      p_person_id_code             IN   igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type        IN   igs_pe_alt_pers_id.person_id_type%TYPE,
      p_program_cd                 IN   igs_av_lgcy_unt_int.program_cd%TYPE,
      p_load_cal_alt_code          IN   igs_av_lgcy_unt_int.load_cal_alt_code%TYPE,
      p_avstnd_grade               IN   igs_av_lgcy_unt_int.grade%TYPE,
      p_achievable_credit_points   IN   igs_av_lgcy_unt_int.achievable_credit_points%TYPE,
      p_target_course_subject      IN   VARCHAR2,
      p_target_course_num          IN   VARCHAR2,
      p_inst_id_code               IN   igs_pe_alt_pers_id.api_person_id%TYPE,
      p_inst_id_code_type          IN   igs_pe_alt_pers_id.api_person_id%TYPE
   );

-- This procedure is called to validate a batch ID or to create a new batch id if
-- the incomming transfer evaluation reply is without a request.This procedure also deletes the
-- academic history and advanced standing details for the the student.

   PROCEDURE create_or_get_batch_id (
      p_batch_id              IN              igs_da_rqst.batch_id%TYPE,
      p_person_id_code        IN              igs_pe_alt_pers_id.api_person_id%TYPE,
      p_person_id_code_type   IN              igs_pe_alt_pers_id.person_id_type%TYPE,
      p_program_code          IN              igs_av_lgcy_unt_int.program_cd%TYPE,
      transaction_sub_type    IN              VARCHAR2,
      p_out_batch_id          OUT NOCOPY      igs_da_rqst.batch_id%TYPE
   );

   PROCEDURE delete_adv_stnd_records (p_person_id IN hz_parties.party_id%TYPE);
   PROCEDURE complete_import_process (p_batch_id IN igs_da_rqst.batch_id%TYPE);

END igs_da_trns_imp;

 

/
