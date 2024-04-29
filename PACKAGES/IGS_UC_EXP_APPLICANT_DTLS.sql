--------------------------------------------------------
--  DDL for Package IGS_UC_EXP_APPLICANT_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXP_APPLICANT_DTLS" AUTHID CURRENT_USER AS
/* $Header: IGSUC44S.pls 120.1 2006/08/21 06:16:25 jbaber noship $  */

  PROCEDURE export_process ( errbuf OUT NOCOPY VARCHAR2,
                             retcode OUT NOCOPY NUMBER,
                             p_app_no IN NUMBER,
                             p_addr_usage_home IN VARCHAR2 DEFAULT NULL,
                             p_addr_usage_corr IN VARCHAR2 DEFAULT NULL) ;

  PROCEDURE pop_api_int ( p_ni_number IN VARCHAR2,
                          p_ninumber_alt_type IN VARCHAR2,
                          p_scn  IN VARCHAR2,
                          p_person_id IN NUMBER,
                          p_interface_id IN NUMBER,
                          p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  PROCEDURE pop_res_dtls_int( p_rescat IN VARCHAR2,
                              p_application_date IN DATE,
                              p_system_code IN VARCHAR2,
                              p_interface_id IN NUMBER,
                              p_cal_type IN VARCHAR2, -- anwest UCFD040 Bug# 4015492 Added new parameter
                              p_sequence_number IN NUMBER, -- anwest UCFD040 Bug# 4015492 Added new parameter
                              p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  PROCEDURE pop_citizen_int ( p_nationality IN NUMBER,
                              p_dual_nationality IN NUMBER,
                              p_person_id IN NUMBER,
                              p_application_date IN DATE,
                              p_interface_id IN NUMBER,
                              p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  PROCEDURE pop_acad_hist_int ( p_person_id IN NUMBER,
                                p_person_number IN VARCHAR2,
                                p_school IN NUMBER,
                                p_interface_id IN NUMBER,
                                p_app_valid_status IN OUT NOCOPY BOOLEAN);

  PROCEDURE pop_disability_int(p_special_needs IN VARCHAR2,
                               p_person_id IN NUMBER,
                               p_application_date IN DATE,
                               p_interface_id IN NUMBER,
                               p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  PROCEDURE pop_contact_int ( p_telephone IN VARCHAR2,
                              p_email IN VARCHAR2,
                              p_home_phone IN VARCHAR2,
                              p_mobile IN VARCHAR2,
                              p_interface_id IN NUMBER,
                              p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  PROCEDURE pop_address_int ( p_app_address_dtls_rec IN IGS_UC_APP_ADDRESES%ROWTYPE,
                              p_domocile_apr IN VARCHAR2,
                              p_interface_id IN NUMBER,
                              p_addr_usage_home IN VARCHAR2,
                              p_addr_usage_corr IN VARCHAR2,
                              p_app_valid_status IN OUT NOCOPY BOOLEAN) ;

  FUNCTION  chk_src_cat( p_source_type_id IN NUMBER,
                         p_category IN VARCHAR2)
  RETURN BOOLEAN;

  PROCEDURE adm_import_process( p_ad_batch_id IN NUMBER,
                                p_source_type_id IN NUMBER,
                                p_status IN OUT NOCOPY BOOLEAN);

END igs_uc_exp_applicant_dtls;

 

/
