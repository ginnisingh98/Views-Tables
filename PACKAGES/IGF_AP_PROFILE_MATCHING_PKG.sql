--------------------------------------------------------
--  DDL for Package IGF_AP_PROFILE_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_PROFILE_MATCHING_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP16S.pls 120.0 2005/06/01 15:01:20 appldev noship $ */

       PROCEDURE create_fa_base_record(pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                                       pn_person_id       igf_ap_fa_base_rec_all.person_id%TYPE,
                                       pn_base_id    OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE
                                       ) ;

        PROCEDURE create_fnar_data(pn_css_id           igf_ap_css_interface_all.css_id%TYPE,
                                   pn_cssp_id          igf_ap_css_profile.cssp_id%TYPE
                                   ) ;

        PROCEDURE create_person_record(pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                                       pn_person_id  OUT NOCOPY  igf_ap_fa_base_rec_all.person_id%TYPE,
				                           pv_mesg_data  OUT NOCOPY  VARCHAR2,
                                       p_called_from             VARCHAR2
                                       ) ;

        PROCEDURE create_person_addr_record(pn_css_id        igf_ap_css_interface_all.css_id%TYPE,
                                            pn_person_id     igf_ap_fa_base_rec_all.person_id%TYPE
                                            ) ;

	     PROCEDURE create_profile_matched(pn_css_id                igf_ap_css_interface_all.css_id%TYPE,
	                                 pn_cssp_id      OUT NOCOPY      igf_ap_css_profile.cssp_id%TYPE,
	                                 pn_base_id               igf_ap_css_profile.base_id%TYPE,
	                                 pn_system_record_type    igf_ap_css_profile.system_record_type%TYPE
	                                 ) ;


        FUNCTION  is_fa_base_record_present(pn_person_id            igf_ap_match_details.person_id%TYPE,
                                            pn_cal_type             igf_ap_person_match_all.ci_cal_type%TYPE,
                                            pn_sequence_number      igf_ap_person_match_all.ci_sequence_number%TYPE,
                                            pn_base_id         OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE
                                            )  RETURN BOOLEAN ;

        PROCEDURE update_css_interface(pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                                       pv_record_status   igf_ap_css_interface_all.record_status%TYPE,
                                       pv_match_code      VARCHAR2
                                       ) ;

        FUNCTION convert_int(col_value VARCHAR2)  RETURN VARCHAR2 ;

        PROCEDURE main( errbuf            OUT NOCOPY  VARCHAR2,
                        retcode           OUT NOCOPY  NUMBER,
                        p_org_id          IN  NUMBER,
                        p_award_year      IN  VARCHAR2,
                        p_force_add       IN  VARCHAR2,
                        p_create_inquiry  IN  VARCHAR2,
                        p_adm_source_type IN  VARCHAR2,
                        p_match_code      IN  VARCHAR2,
                        p_school_code     IN  VARCHAR2
		                );

        PROCEDURE auto_fa_rec(p_person_id  igf_ap_match_details.person_id%TYPE ,
                              p_apm_id     igf_ap_person_match_all.apm_id%TYPE,
                              p_cal_type   igf_ap_person_match_all.ci_cal_type%TYPE,
                              p_seq_num    igf_ap_person_match_all.ci_sequence_number%TYPE
                              );

        PROCEDURE rvw_fa_rec(p_apm_id    igf_ap_person_match_all.apm_id%TYPE );

        PROCEDURE  unmatched_rec (p_apm_id  igf_ap_person_match_all.apm_id%TYPE);

        PROCEDURE create_admission_rec(p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE,
                                       p_batch_year igf_ap_css_interface_all.academic_year%TYPE);


	     PROCEDURE update_person_match(pn_apm_id          igf_ap_person_match.apm_id%TYPE,
                                      pv_record_status   igf_ap_person_match.record_status%TYPE
                                      ) ;

        PROCEDURE  update_fa_base_rec(p_base_id   igf_ap_fa_base_rec.base_id%TYPE);


        FUNCTION remove_spl_chr(pv_ssn        igf_ap_isir_ints_all.current_ssn_txt%TYPE)
        RETURN VARCHAR2;

        PROCEDURE ss_wrap_create_person_record (p_css_id  IN NUMBER);

	     PROCEDURE ss_wrap_refresh_matches(p_css_id     IN NUMBER,
	                                       p_match_code IN VARCHAR2,
					                           p_batch_year IN NUMBER);

        PROCEDURE ss_wrap_create_base_record ( p_css_id        IN          NUMBER,
                                               p_person_id     IN          NUMBER,
                                               p_batch_year    IN          NUMBER);

        PROCEDURE ss_wrap_upload_Profile ( p_css_id        IN          NUMBER,
                                   x_msg_data      OUT NOCOPY  VARCHAR2,
                                   x_return_status OUT NOCOPY  VARCHAR2
                            );

END igf_ap_profile_matching_pkg;

 

/
