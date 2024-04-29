--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_014" AUTHID CURRENT_USER AS
/* $Header: IGSADB9S.pls 120.3 2005/09/26 02:49:57 appldev ship $ */
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
rrengara   8-JUL-2002    Added UK Parameters choic number and routre pref to the procedure insert_adm_appl 2448262
pbondugu  28-Mar-2003    Added funding_source parameter in spec and body of insert_adm_appl_prog_inst procedure.
******************************************************************/
FUNCTION insert_adm_appl(
  p_person_id IN NUMBER ,
  p_appl_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN OUT NOCOPY VARCHAR2 ,
  p_tac_appl_ind IN VARCHAR2 DEFAULT 'N',
  p_adm_appl_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_spcl_grp_1   IN NUMBER DEFAULT NULL,
  p_spcl_grp_2   IN NUMBER DEFAULT NULL,
  p_common_app   IN VARCHAR2 DEFAULT NULL,
  p_application_type IN VARCHAR2 DEFAULT NULL,
  p_choice_number IN NUMBER DEFAULT NULL,
  p_routeb_pref  IN VARCHAR2 DEFAULT NULL,
  p_alt_appl_id  IN VARCHAR2 DEFAULT NULL,
  p_appl_fee_Amt  IN NUMBER  DEFAULT NULL,
  p_log IN VARCHAR2 DEFAULT 'Y')
   RETURN BOOLEAN;

FUNCTION insert_adm_appl_prog(
			  p_person_id                   IN igs_pe_person.person_id%type ,
			  p_adm_appl_number             IN NUMBER ,
			  p_nominated_course_cd         IN VARCHAR2 ,
			  p_transfer_course_cd          IN VARCHAR2,
			  p_basis_for_admission_type    IN VARCHAR2 ,
			  p_admission_cd                IN VARCHAR2 ,
			  p_req_for_reconsideration_ind IN VARCHAR2 DEFAULT 'N',
			  p_req_for_adv_standing_ind    IN VARCHAR2 DEFAULT 'N',
			  p_message_name                OUT NOCOPY VARCHAR2,
			  p_log IN VARCHAR2 DEFAULT 'Y' )  RETURN BOOLEAN;

FUNCTION insert_adm_appl_prog_inst(
			  p_person_id                   IN igs_pe_person.person_id%type ,
			  p_admission_appl_number       IN NUMBER ,
			  p_acad_cal_type               IN VARCHAR2 ,
			  p_acad_ci_sequence_number     IN NUMBER ,
			  p_adm_cal_type                IN VARCHAR2 ,
			  p_adm_ci_sequence_number      IN NUMBER ,
			  p_admission_cat               IN VARCHAR2 ,
			  p_s_admission_process_type    IN VARCHAR2,
			  p_appl_dt                     IN DATE ,
			  p_adm_fee_status              IN VARCHAR2 ,
			  p_preference_number           IN NUMBER ,
			  p_offer_dt                    IN DATE ,
			  p_offer_response_dt           IN DATE ,
			  p_course_cd                   IN VARCHAR2 ,
			  p_crv_version_number          IN NUMBER ,
			  p_location_cd                 IN VARCHAR2 ,
			  p_attendance_mode             IN VARCHAR2 ,
			  p_attendance_type             IN VARCHAR2 ,
			  p_unit_set_cd                 IN VARCHAR2 ,
			  p_us_version_number           IN NUMBER ,
			  p_fee_cat                     IN VARCHAR2 ,
			  p_correspondence_cat          IN VARCHAR2 ,
			  p_enrolment_cat               IN VARCHAR2 ,
			  p_funding_source             IN VARCHAR2 DEFAULT NULL,
			  p_edu_goal_prior_enroll       IN NUMBER,
			  p_app_source_id               IN NUMBER,
			  p_apply_for_finaid            IN VARCHAR2,
			  p_finaid_apply_date           IN DATE,
			  p_attribute_category	        IN VARCHAR2,
			  p_attribute1	                IN VARCHAR2,
			  p_attribute2	                IN VARCHAR2,
			  p_attribute3	                IN VARCHAR2,
			  p_attribute4	                IN VARCHAR2,
			  p_attribute5	                IN VARCHAR2,
			  p_attribute6	                IN VARCHAR2,
			  p_attribute7	                IN VARCHAR2,
			  p_attribute8	                IN VARCHAR2,
			  p_attribute9	                IN VARCHAR2,
			  p_attribute10	                IN VARCHAR2,
			  p_attribute11	                IN VARCHAR2,
			  p_attribute12	                IN VARCHAR2,
			  p_attribute13	                IN VARCHAR2,
			  p_attribute14	                IN VARCHAR2,
			  p_attribute15	                IN VARCHAR2,
			  p_attribute16	                IN VARCHAR2,
			  p_attribute17	                IN VARCHAR2,
			  p_attribute18	                IN VARCHAR2,
			  p_attribute19	                IN VARCHAR2,
			  p_attribute20	                IN VARCHAR2,
 		          p_attribute21	                IN VARCHAR2,
			  p_attribute22			IN VARCHAR2,
			  p_attribute23			IN VARCHAR2,
			  p_attribute24			IN VARCHAR2,
			  p_attribute25			IN VARCHAR2,
			  p_attribute26			IN VARCHAR2,
			  p_attribute27			IN VARCHAR2,
			  p_attribute28			IN VARCHAR2,
			  p_attribute29			IN VARCHAR2,
			  p_attribute30			IN VARCHAR2,
			  p_attribute31			IN VARCHAR2,
			  p_attribute32			IN VARCHAR2,
			  p_attribute33			IN VARCHAR2,
			  p_attribute34			IN VARCHAR2,
			  p_attribute35			IN VARCHAR2,
			  p_attribute36			IN VARCHAR2,
			  p_attribute37			IN VARCHAR2,
			  p_attribute38			IN VARCHAR2,
			  p_attribute39			IN VARCHAR2,
			  p_attribute40			IN VARCHAR2,
	         	  p_ss_application_id           IN VARCHAR2,
			  p_sequence_number             OUT NOCOPY NUMBER,
			  p_return_type                 OUT NOCOPY VARCHAR2,
			  p_error_code                  OUT NOCOPY VARCHAR2,
			  p_message_name                OUT NOCOPY VARCHAR2,
			  p_entry_status                IN NUMBER DEFAULT NULL,
			  p_entry_level                 IN NUMBER DEFAULT NULL,
			  p_sch_apl_to_id               IN NUMBER DEFAULT NULL,
                          p_hecs_payment_option  IN VARCHAR2 DEFAULT NULL,
			  p_log IN VARCHAR2 DEFAULT 'Y' )  RETURN BOOLEAN;
 PROCEDURE auto_assign_requirement(
           p_person_id              IN                        NUMBER,
           p_admission_appl_number  IN                        NUMBER,
	   p_course_cd              IN                        VARCHAR2,
	   p_sequence_number        IN                        NUMBER,
	   p_called_from            IN                        VARCHAR2,
	   p_error_text             OUT NOCOPY                VARCHAR2,
	   p_error_code             OUT NOCOPY                NUMBER
 );

 PROCEDURE assign_qual_type (
 p_person_id              IN                        NUMBER,
 p_admission_appl_number  IN                        NUMBER,
 p_course_cd              IN                        VARCHAR2,
 p_sequence_number        IN                        NUMBER
 );

END IGS_AD_GEN_014;

 

/
