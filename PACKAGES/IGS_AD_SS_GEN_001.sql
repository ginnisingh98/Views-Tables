--------------------------------------------------------
--  DDL for Package IGS_AD_SS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_GEN_001" AUTHID CURRENT_USER AS
  /* $Header: IGSADB8S.pls 120.10 2006/06/14 12:08:50 arvsrini ship $ */
  /******************************************************************
  Created By: tapash.ray
  Date Created By: 11-Dec-2001
  Purpose: Transfer API for transfer of data from SS Staging Table to IGS tables
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  apadegal   21-Oct-2005   Added  g_admin_security_on to enable security for submission of application by any Admin
  abhiskum   25-Aug-2005   Added procedures DELETE_PERSTMT_ATTACHMENT_UP, ADD_PERSTMT_ATTACHMENT_UP for
			   Update Submitted Applications Page in SS Admin Flow; and
			   DELETE_PERSTMT_ATTACHMENT, ADD_PERSTMT_ATTACHMENT for Supporting Evidence Page
			   in SS Applicant Floe, for the IGS.M build
  pathipat   17-Jun-2003   Enh 2831587 Credit Card Fund Transfer build
                           Modified procedure update_ad_offer_resp_and_fee - added p_credit_card_tangible_cd
  vvutukur  26-Nov-2002  Enh#2584986.Modified procedure update_ad_offer_resp_and_fee to add 9 new parameters.
  rboddu     17-FEB-2002    insert_ss_appl_stg procedure is modified
                            for new IN paramter p_app_source_id. insert_ss_appl_perstat_stg procedure
                            is modified for the new IN parameter p_date_received.
  kamohan  30-MAY-2002   Bug 2347213 Added the procedure validate_prog_inst
  ******************************************************************/


  g_admin_security_on VARCHAR2(1);

  PROCEDURE set_adm_secur_on;
  PROCEDURE set_adm_secur_off;

  PROCEDURE transfer_data(x_person_id       IN NUMBER,
                          x_application_id  IN NUMBER,
                          x_message_name    OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          p_adm_appl_number OUT NOCOPY NUMBER);

  PROCEDURE insert_ss_appl_stg(x_message_name       OUT NOCOPY VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               p_person_id          IN NUMBER,
                               p_application_type   IN VARCHAR2,
                               p_adm_appl_number    IN NUMBER,
                               p_admission_cat      IN VARCHAR2,
                               p_s_adm_process_type IN VARCHAR2,
                               p_login_id           IN NUMBER,
                               p_app_source_id      IN NUMBER DEFAULT NULL);

  PROCEDURE delete_ss_appl_stg(x_message_name    OUT NOCOPY VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               p_adm_appl_number IN NUMBER,
                               p_person_id       IN NUMBER);

  PROCEDURE insert_ss_appl_perstat_stg(p_return_status              OUT NOCOPY VARCHAR2,
                                       p_message_data               OUT NOCOPY VARCHAR2,
                                       p_person_id                  IN NUMBER,
                                       p_adm_appl_id                IN NUMBER,
                                       p_admission_application_type IN VARCHAR2,
                                       p_user_id                    IN NUMBER,
                                       p_date_received              IN DATE DEFAULT NULL);

  PROCEDURE get_acad_cal(p_adm_cal_type  IN IGS_CA_TYPE.CAL_TYPE%TYPE,
                         p_adm_seq       IN OUT NOCOPY IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                         p_acad_cal_type OUT NOCOPY IGS_CA_TYPE.CAL_TYPE%TYPE,
                         p_acad_seq      OUT NOCOPY IGS_CA_INST.SEQUENCE_NUMBER%TYPE);

  FUNCTION get_dflt_adm_cal RETURN VARCHAR2;

  PROCEDURE Check_FeeExists(p_person_id          IN igs_ad_appl_all.person_id%TYPE,
			    p_adm_appl_num       IN igs_ad_appl_all.admission_appl_number%TYPE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_message_data       OUT NOCOPY VARCHAR2);

  PROCEDURE Check_OneStop(p_person_id              IN NUMBER,
                          p_admission_cat          IN VARCHAR2,
                          p_admission_process_type IN VARCHAR2,
                          x_return_status          OUT NOCOPY VARCHAR2,
                          x_message_data           OUT NOCOPY VARCHAR2);

  PROCEDURE Process_OneStop(p_admission_appl_number  IN NUMBER,
                            p_person_id              IN NUMBER,
                            p_admission_cat          IN VARCHAR2,
                            p_admission_process_type IN VARCHAR2,
			    p_role                   IN VARCHAR2,
                            x_return_status          OUT NOCOPY VARCHAR2,
                            x_message_data           OUT NOCOPY VARCHAR2);

  PROCEDURE update_ad_offer_resp_and_fee(p_person_id                   IN NUMBER,
                                         p_admission_appl_number       IN NUMBER,
                                         p_one_stop_ind                IN VARCHAR2,
                                         p_app_fee_amt                 IN NUMBER,
                                         p_authorization_number        IN VARCHAR2,
                                         x_return_status               OUT NOCOPY VARCHAR2,
                                         x_msg_count                   OUT NOCOPY NUMBER,
                                         x_msg_data                    OUT NOCOPY VARCHAR2,
                                         p_credit_card_code            IN VARCHAR2,
                                         p_credit_card_holder_name     IN VARCHAR2,
                                         p_credit_card_number          IN VARCHAR2,
                                         p_credit_card_expiration_date IN DATE,
                                         p_gl_date                     IN DATE,
                                         p_rev_gl_ccid                 IN NUMBER,
                                         p_cash_gl_ccid                IN NUMBER,
                                         p_rev_account_cd              IN VARCHAR2,
                                         p_cash_account_cd             IN VARCHAR2,
                                         p_credit_card_tangible_cd     IN VARCHAR2);

  PROCEDURE Process_OneStop2(p_admission_appl_number  IN NUMBER,
                             p_person_id              IN NUMBER,
                             p_admission_cat          IN VARCHAR2,
                             p_admission_process_type IN VARCHAR2,
			     p_role                   IN VARCHAR2,
                             x_return_status          OUT NOCOPY VARCHAR2,
                             x_msg_data               OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Appl_Eqdo_Inst(p_person_id             IN NUMBER,
                                  p_admission_appl_number IN NUMBER,
                                  p_nominated_course_cd   IN VARCHAR2,
                                  p_sequence_number       IN NUMBER,
                                  x_return_status         OUT NOCOPY VARCHAR2,
                                  x_message_data          OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Appl_Ofr_Inst(p_person_id             IN NUMBER,
                                 p_admission_appl_number IN NUMBER,
                                 p_nominated_course_cd   IN VARCHAR2,
                                 p_sequence_number       IN NUMBER,
                                 x_return_status         OUT NOCOPY VARCHAR2,
                                 x_message_data          OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Appl_Ofres_Inst(p_person_id             IN NUMBER,
                                   p_admission_appl_number IN NUMBER,
                                   p_nominated_course_cd   IN VARCHAR2,
                                   p_sequence_number       IN NUMBER,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_message_data          OUT NOCOPY VARCHAR2);

  PROCEDURE insert_appl_section_stat(x_message_name    OUT NOCOPY VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2,
                                     p_person_id       IN NUMBER,
                                     p_adm_appl_number IN NUMBER,
                                     p_login_id        IN NUMBER);

  PROCEDURE validate_prog_inst(p_course_cd                IN VARCHAR2,
                               p_crv_version_number       IN NUMBER,
                               p_location_cd              IN VARCHAR2,
                               p_attendance_mode          IN VARCHAR2,
                               p_attendance_type          IN VARCHAR2,
                               p_acad_cal_type            IN VARCHAR2,
                               p_acad_ci_sequence_number  IN NUMBER,
                               p_adm_cal_type             IN VARCHAR2,
                               p_adm_ci_sequence_number   IN NUMBER,
                               p_admission_cat            IN VARCHAR2,
                               p_s_admission_process_type IN VARCHAR2,
                               p_message_name             OUT NOCOPY VARCHAR2,
                               p_return_type              OUT NOCOPY VARCHAR2);

  /*
  --------------------------------------------------------------------------------------------------
  --Function to get the major first choice and second choice to be displayed in the printable page
  -- Sent by Nagaraju from HQ to be added to the API
  --------------------------------------------------------------------------------------------------
  */
  FUNCTION get_major(p_person_id             IN igs_ad_ps_appl_inst.person_id%TYPE,
                     p_admission_appl_number IN igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                     p_nominated_course_cd   IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                     p_sequence_number       IN igs_ad_ps_appl_inst.sequence_number%TYPE,
                     p_rank                  IN igs_ad_unit_sets.rank%TYPE)
    RETURN VARCHAR2;

  FUNCTION DATESTR(P_START_DATE DATE, P_END_DATE DATE, P_COMP_DATE DATE)
    RETURN VARCHAR2;

  -- Procedure specially designed to get the Concatenated list of Alternate Ids in the FindPerson Page
  FUNCTION getAltid(x_party_id number) RETURN VARCHAR2;

  -- Procedure specially designed to get the Concatenated list of Application Ids in the FindPerson Page
  FUNCTION getApplid(x_party_id number) RETURN VARCHAR2;

  /* Added procedure which will update the checklist w.r.t Application type configuration. */
  PROCEDURE update_appl_section_stat(p_person_id       IN NUMBER,
                                     p_adm_appl_number IN NUMBER,
                                     p_page_Name       IN VARCHAR2,
                                     p_Appl_Type       IN VARCHAR2,
                                     x_message_name    OUT NOCOPY VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2,
                                     x_mand_incomplete OUT NOCOPY VARCHAR2);

  /* Procedure which will Sync the checklist w.r.t Application type configuration. */
  PROCEDURE sync_appl_section_stat(p_person_id       IN NUMBER,
                                   p_adm_appl_number IN NUMBER,
                                   p_Appl_Type       IN VARCHAR2,
                                   p_login_id        IN NUMBER,
                                   x_message_name    OUT NOCOPY VARCHAR2,
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_max_Sections    OUT NOCOPY NUMBER);

/*procedure which will create the records in following areas when Application Type is created
            Application Type pages
            Application Type page Components
            Terms and Conditions */
PROCEDURE auto_assign_pgs_comps_terms(
                                    x_message_name       OUT NOCOPY VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    p_appl_type          IN VARCHAR2,
                                    p_admission_cat      IN VARCHAR2 ,
                                    p_s_admission_process_type IN VARCHAR2
                                    );
/*procedure which will update the records in following areas when Application Category
           is Changed for an Application Type:
            Application Type pages
            Application Type page Components
            Terms and Conditions */
PROCEDURE update_assign_pgs_comps( x_message_name             OUT NOCOPY VARCHAR2,
                                   x_return_status            OUT NOCOPY VARCHAR2,
                                   p_appl_type                IN VARCHAR2 DEFAULT NULL,
			           p_admission_cat            IN VARCHAR2,
                                   p_s_admission_process_type IN VARCHAR2
                                   );

PROCEDURE validate_prog_pref  (p_ss_adm_appl_id           IN NUMBER ,
                               p_course_cd                IN VARCHAR2,
			       p_crv_version_number       IN NUMBER,
			       p_location_cd              IN VARCHAR2,
			       p_attendance_mode          IN VARCHAR2,
			       p_attendance_type          IN VARCHAR2,
			       p_final_unit_set_cd        IN VARCHAR2,
                               p_us_version_number       IN NUMBER,
                               p_message_name             OUT NOCOPY VARCHAR2,
                               p_return_type              OUT NOCOPY VARCHAR2);

PROCEDURE validate_unit_Set (p_ss_adm_appl_id           IN NUMBER ,
                               p_course_cd                    VARCHAR2,
			       p_crv_version_number           NUMBER,
			       p_location_cd                  VARCHAR2,
			       p_attendance_mode              VARCHAR2,
			       p_attendance_type              VARCHAR2,
                               p_unit_set_cd                  VARCHAR2,
                               p_us_version_number            NUMBER ,
 			       p_message_name                 OUT NOCOPY VARCHAR2,
			       p_return_type		      OUT NOCOPY VARCHAR2) ;
PROCEDURE DELETE_PERSTMT_ATTACHMENT(p_document_id IN NUMBER,
				    p_ss_perstat_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2
				      );
PROCEDURE ADD_PERSTMT_ATTACHMENT   (p_person_id IN NUMBER,
				    p_ss_perstat_id IN NUMBER,
				    p_file_name IN VARCHAR2,
				    p_file_content_type IN VARCHAR2,
				    p_file_format IN VARCHAR2,
				    p_file_id OUT NOCOPY NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2
				   );
PROCEDURE DELETE_PERSTMT_ATTACHMENT_UP(p_document_id IN NUMBER,
				       x_return_status OUT NOCOPY VARCHAR2
				      );
PROCEDURE ADD_PERSTMT_ATTACHMENT_UP(p_person_id IN NUMBER,
				    p_appl_perstat_id IN NUMBER,
				    p_file_name IN VARCHAR2,
				    p_file_content_type IN VARCHAR2,
				    p_file_format IN VARCHAR2,
				    p_file_id OUT NOCOPY NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2
				   );

/* Get Concatenated Enabled SS Lookup Code Descriptions for a given lookup type with given delimiter */

PROCEDURE get_ss_lookup_desc(p_application_type IN igs_ad_ss_lookups.admission_application_type%type,
                             p_lookup_type   IN igs_ad_ss_lookups.ss_lookup_type%TYPE,
                             p_delimiter     IN VARCHAR2,
                             x_message_name    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2,
                             x_concat_desc     OUT NOCOPY VARCHAR2);

PROCEDURE CHECK_INSTANCE_SECURITY( p_person_id       IN NUMBER,
                                   p_adm_appl_number IN NUMBER,
                                   x_return_status   OUT NOCOPY VARCHAR2,
				   x_error_msg       OUT NOCOPY VARCHAR2);

FUNCTION wf_submit_application_sub(p_subscription_guid IN RAW,
                        p_event IN OUT NOCOPY WF_EVENT_T) return varchar2;

END IGS_AD_SS_GEN_001;

 

/
