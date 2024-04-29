--------------------------------------------------------
--  DDL for Package IGF_AP_MATCHING_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_MATCHING_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP04S.pls 120.0 2005/06/01 13:44:19 appldev noship $ */


PROCEDURE main ( errbuf            OUT NOCOPY VARCHAR2,
                 retcode           OUT NOCOPY NUMBER,
                 p_force_add       IN VARCHAR2,
                 p_create_inquiry  IN VARCHAR2,
                 p_adm_source_type IN VARCHAR2,
                 p_batch_year      IN VARCHAR2,
                 p_match_code      IN VARCHAR2,
                 p_del_int         IN VARCHAR2,
                 p_parent_req_id   IN VARCHAR2,             -- when called as sub request
                 p_sub_req_num     IN VARCHAR2,             -- when called as sub request
                 p_si_id           IN VARCHAR2,
                 p_upd_ant_val     IN VARCHAR2   DEFAULT 'Y'
                 );


-- # 2376750  Added match_records procedure.

FUNCTION format_SSN (l_ssn  VARCHAR2 )
RETURN VARCHAR2 ;

FUNCTION convert_to_date(pv_org_date  VARCHAR2)
RETURN DATE;

FUNCTION convert_to_number(pv_org_number VARCHAR2)
RETURN NUMBER;

FUNCTION is_fa_base_record_present(pn_person_id   NUMBER,
                                  pn_batch_year  NUMBER,
                                  pn_base_id     OUT  NOCOPY  NUMBER)
RETURN BOOLEAN;

FUNCTION convert_negative_char(pv_charnum   VARCHAR2)
RETURN NUMBER;

PROCEDURE load_matched_isir(pv_ssn                 VARCHAR2,
                            pv_last_name           VARCHAR2,
                            pd_date_of_birth       DATE,
                            pn_ci_sequence_number  NUMBER,
                            pv_ci_cal_type         VARCHAR2,
                            pn_base_id             igf_ap_isir_matched.base_id%TYPE);

PROCEDURE create_isir_matched(pn_si_id           NUMBER,
                              pn_isir_id   OUT NOCOPY  NUMBER,
                              pn_base_id   IN    NUMBER );


PROCEDURE update_isir_intrface(pn_si_id           NUMBER,
                               pv_record_status   VARCHAR2 );


PROCEDURE create_nslds_data(pn_si_id     NUMBER,
                            pn_isir_id   NUMBER,
                            pn_base_id   NUMBER
                          );

FUNCTION check_ptyp_code(p_person_id   igf_ap_person_v.person_id%TYPE)
RETURN BOOLEAN;

FUNCTION remove_spl_chr(pv_ssn  igf_ap_isir_ints_all.current_ssn_txt%TYPE )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(remove_spl_chr, WNDS, WNPS, RNPS);


FUNCTION get_msg_class_from_filename(p_filename VARCHAR2)
RETURN VARCHAR2 ;

-- Added p_award_yr as a part of Bug Fix 4241350
PROCEDURE wrpr_auto_fa_rec(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                           p_person_id      IN igf_ap_match_details.person_id%TYPE,
			   p_batch_year       IN igf_ap_isir_matched.batch_year%TYPE,
                           p_return_status OUT NOCOPY VARCHAR2,
                           p_message_out   OUT NOCOPY VARCHAR2);


PROCEDURE wrpr_unmatched_rec(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                             p_return_status OUT NOCOPY VARCHAR2,
                             p_message_out   OUT NOCOPY VARCHAR2);

PROCEDURE wrpr_refresh_matches(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                               p_match_code     IN igf_ap_record_match_all.match_code%TYPE,
                               p_return_status OUT NOCOPY VARCHAR2,
                               p_message_out   OUT NOCOPY VARCHAR2);

END igf_ap_matching_process_pkg;

 

/
