--------------------------------------------------------
--  DDL for Package IGF_GR_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_GEN" AUTHID CURRENT_USER AS
/* $Header: IGFGR08S.pls 115.18 2003/12/10 09:16:15 veramach noship $ */

-----------------------------------------------------------------------------------
-- Who        When           What
------------------------------------------------------------------------------------
-- veramach   10-Dec-2003    FA 131 COD Updates
--                           Removed function get_rep_pell_id
-----------------------------------------------------------------------------------
--  rasahoo         01-Sep-2003     Replaced igf_ap_fa_base_h_all.derived_attend_type%TYPE
--                                  with igs_en_stdnt_ps_att_all.derived_att_type%TYPE
--                                  as part of the build FA-114 (Obsoletion of FA base record History)
-----------------------------------------------------------------------------------
-- gmuralid   10-Apr-2003    Bug 2744419
--                           Added Function get_calendar_desc to get
--                           the calendar description.
-----------------------------------------------------------------------------------
-- sjadhav    01-Apr-2003    Bug 2875503
--                           Changed in parameter for get_ssn_digits
-----------------------------------------------------------------------------------
-- sjadhav    05-Feb-2003    FA116 Build - Bug 2758812 - 2/4/03
--                           Added update_current_ssn,update_pell_status,
--                           match_file_version,get_min_disb_number
-----------------------------------------------------------------------------------
-- sjadhav    Nov,18,2002.   Bug 2590991
--                           Routine to fetch base id
-----------------------------------------------------------------------------------
-- sjadhav    Oct.25.2002    Bug 2613546,2606001
--                           get_tufees_code,get_def_awd_year,ovrd_coa_exist,
--                           delete_coa,update_item_dist,insert_coa_items,
--                           insert_coa_terms,get_pell_code,insert_stu_coa_terms,
--                           delete_stu_coa_terms,delete_stu_coa_items,
--                           update_stu_coa_items routines added
-----------------------------------------------------------------------------------
-- sjadhav    Oct.10.2002    Bug 2383690
--                           1. Added send_orig_disb
--                           2. Added get_min_pell_disb
--                           3. Added get_min_awd_disb
--
-- nsidana    10/31/2003     Multiple FA offices.
--                           Added 3 new functions to derive the reporting pell ID
--                           for a student.
-----------------------------------------------------------------------------------
--
-- sjadhav
-- This is a generic Utility Package aimed at centralization of
-- common functions/procedures
--
-- This package contains
-- 1. get_rep_pell_id
-- 2. get_pell_header
-- 3. get_pell_trailer
-- 4. process_pell_ack
-- routines which are very specific to Pell Subsytem
--
-- Other routines are general
--
-----------------------------------------------------------------------------------


no_file_version         EXCEPTION;
file_not_loaded         EXCEPTION;
batch_not_in_system     EXCEPTION;
corrupt_data_file       EXCEPTION;
skip_this_record        EXCEPTION;

FUNCTION get_cycle_year (p_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE,
                         p_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE)
RETURN VARCHAR2;

FUNCTION disb_has_adj ( p_award_id  igf_aw_award_all.award_id%TYPE,
                        p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
RETURN BOOLEAN;


FUNCTION get_alt_code ( p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                        p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE)
RETURN VARCHAR2;

FUNCTION get_calendar_desc ( p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                             p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE)
RETURN VARCHAR2;

FUNCTION get_per_num ( p_base_id   IN  igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN VARCHAR2;



FUNCTION get_per_num ( p_person_id       IN   igf_ap_fa_base_rec_all.person_id%TYPE,
                       p_person_number   OUT NOCOPY  igf_ap_person_v.person_number%TYPE )
RETURN BOOLEAN;


FUNCTION get_person_id ( p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN VARCHAR2;


FUNCTION get_per_num_oss ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
RETURN VARCHAR2;


PROCEDURE insert_sys_holds ( p_award_id  igf_aw_award_all.award_id%TYPE,
                             p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE DEFAULT NULL,
                             p_hold      igf_db_disb_holds_all.hold%TYPE);


FUNCTION get_min_awd_disb  ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN NUMBER;


----------------------------------------------------------------------------------------
-- Pell Routines
----------------------------------------------------------------------------------------


-- Bug 3102439 FA126 Multiple FA Offices.
-- Added two extra parameters p_ci_cal_type and p_ci_sequence_number

FUNCTION get_pell_header ( p_ver_num        IN   VARCHAR2,
                           p_cycle_year     IN   VARCHAR2,
                           p_rep_pell_id    IN   igf_gr_pell_setup_all.rep_pell_id%TYPE,
                           p_batch_type     IN   VARCHAR2,
                           p_rfmb_id        OUT NOCOPY  igf_gr_rfms_batch.rfmb_id%TYPE,
                           p_batch_id       OUT NOCOPY  VARCHAR2,
                           p_ci_cal_type    IN VARCHAR2,
                           p_ci_sequence_number IN NUMBER)
RETURN VARCHAR2;



FUNCTION get_pell_trailer ( p_ver_num        IN   VARCHAR2,
                            p_cycle_year     IN  VARCHAR2,
                            p_rep_pell_id    IN  igf_gr_pell_setup_all.rep_pell_id%TYPE,
                            p_batch_type     IN  VARCHAR2,
                            p_num_of_rec     IN  NUMBER,
                            p_amount_total   IN  NUMBER,
                            p_batch_id       OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


PROCEDURE process_pell_ack ( p_ver_num              IN   VARCHAR2,
                             p_file_type            IN   VARCHAR2,
                             p_number_rec           OUT NOCOPY  NUMBER,
                             p_last_gldr_id         OUT NOCOPY  NUMBER,
                             p_batch_id             OUT NOCOPY  VARCHAR2);


FUNCTION get_pell_efc ( p_base_id   IN   igf_aw_award_all.base_id%TYPE)
RETURN NUMBER;


FUNCTION  send_orig_disb  ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN BOOLEAN;


FUNCTION get_min_pell_disb ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN NUMBER;

FUNCTION get_pell_efc_code ( p_base_id IN igf_aw_award_all.base_id%TYPE)
RETURN VARCHAR2;

FUNCTION fresh_origintn ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN BOOLEAN;

FUNCTION get_fund_id  ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN NUMBER;

FUNCTION get_ssn_digits(p_ssn  igs_pe_alt_pers_id.api_person_id_uf%TYPE)
RETURN VARCHAR2;

--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- ovrd_coa_exist will check if there are any overridden coa items
-- for a coa group
--

PROCEDURE ovrd_coa_exist( p_coa_code         IN   igf_aw_coa_group_all.coa_code%TYPE,
                          p_cal_type         IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                          p_sequence_number  IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                          p_exist            OUT NOCOPY  VARCHAR2
                        );
--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- delete coa group childs
--

PROCEDURE delete_coa( p_record           IN   VARCHAR2,
                      p_coa_code         IN   igf_aw_coa_group_all.coa_code%TYPE,
                      p_cal_type         IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                      p_sequence_number  IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                      p_item_code        IN   igf_aw_coa_grp_item_all.item_code%TYPE DEFAULT NULL
                     );
--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- update coa item for item overidden distribution
--

PROCEDURE update_item_dist( p_coa_code            IN   igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type            IN   igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number     IN   igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE,
                            p_item_code           IN   igf_aw_cit_ld_ovrd_all.item_code%TYPE,
                            p_upd_result          OUT NOCOPY  VARCHAR2);

--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- Routine to fetch default award year
--

PROCEDURE get_def_awd_year(p_alternate_code  OUT NOCOPY   igs_ca_inst_all.alternate_code%TYPE,
                           p_cal_type        OUT NOCOPY   igs_ca_inst_all.cal_type%TYPE,
                           p_sequence_number OUT NOCOPY   igs_ca_inst_all.sequence_number%TYPE,
                           p_start_date      OUT NOCOPY   igs_ca_inst_all.start_dt%TYPE,
                           p_end_date        OUT NOCOPY   igs_ca_inst_all.end_dt%TYPE,
                           p_err_msg         OUT NOCOPY   VARCHAR2
                           );


--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- Routine to fetch Low Tution and Fees Code
--

FUNCTION get_tufees_code(p_base_id             IN   igf_gr_rfms_all.base_id%TYPE,
                         p_cal_type            IN   igf_gr_rfms_all.ci_cal_type%TYPE,
                         p_sequence_number     IN   igf_gr_rfms_all.ci_sequence_number%TYPE)
RETURN VARCHAR2;

--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to add coa items in overide table with default
-- term %
--

PROCEDURE insert_coa_items( p_coa_code           IN   igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type           IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number    IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                            p_item_code          IN   igf_aw_coa_grp_item_all.item_code%TYPE,
                            p_count              OUT NOCOPY  NUMBER
                        );


--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to add coa items in overide table with 0
-- term % once a new term is added
--

PROCEDURE insert_coa_terms( p_coa_code           IN   igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type           IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number    IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                            p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                            p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE
                        );



--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to add coa items in students coa table
--

PROCEDURE insert_stu_coa_terms( p_base_id            IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                                p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE,
                                p_result             OUT NOCOPY  VARCHAR2
                              );


--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to delete coa items-terms from students coa table
--

PROCEDURE delete_stu_coa_terms( p_base_id            IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                                p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE,
                                p_result             OUT NOCOPY  VARCHAR2
                              );

--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to delete coa items from students coa table
--

PROCEDURE delete_stu_coa_items( p_base_id    IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_result     OUT NOCOPY  VARCHAR2,
                                p_item_code  IN   igf_aw_coa_items.item_code%TYPE DEFAULT NULL
                              );

--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to update coa items-amount in students coa table
--

PROCEDURE update_stu_coa_items( p_base_id       IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_item_code     IN   igf_aw_coa_itm_terms.item_code%TYPE DEFAULT NULL,
                                p_result        OUT NOCOPY  VARCHAR2
                              );


--
-- Bug 2606001
-- FA105 108 Build
-- sjadhav
-- routine to get pell att code from attend map form
--


PROCEDURE insert_existing_terms( p_base_id            IN          igf_aw_coa_itm_terms.base_id%TYPE,
                                 p_item_code          IN          igf_aw_coa_itm_terms.item_code%TYPE,
                                 p_result             OUT NOCOPY  VARCHAR2
                                 );


FUNCTION get_pell_code(p_att_code            IN   igs_en_stdnt_ps_att_all.derived_att_type%TYPE,
                       p_cal_type            IN   igf_ap_fa_base_rec.ci_cal_type%TYPE,
                       p_sequence_number     IN   igf_ap_fa_base_rec.ci_sequence_number%TYPE)
RETURN VARCHAR2;


--
-- Bug 2590991
-- sjadhav
-- Nov,18,2002.
--
-- Routine to fetch base id
--

PROCEDURE get_base_id(p_cal_type        IN          igs_ca_inst_all.cal_type%TYPE,
                      p_sequence_number IN          igs_ca_inst_all.sequence_number%TYPE,
                      p_person_id       IN          igf_ap_fa_base_rec_all.person_id%TYPE,
                      p_base_id         OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_err_msg         OUT NOCOPY  VARCHAR2
                      );

--
-- sjadhav,2/4/03
-- FA116 Build - Bug 2758812 - 2/4/03
--
PROCEDURE update_current_ssn (p_base_id  IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_cur_ssn  IN          igf_ap_isir_matched_all.current_ssn%TYPE,
                              p_message  OUT NOCOPY  fnd_new_messages.message_name%TYPE);

PROCEDURE update_pell_status (p_award_id      IN          igf_aw_award_all.award_id%TYPE,
                              p_fed_fund_code IN          igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_message       OUT NOCOPY  fnd_new_messages.message_name%TYPE,
                              p_status_desc   OUT NOCOPY  igf_lookups_view.meaning%TYPE);

PROCEDURE match_file_version (p_version       IN          igf_lookups_view.lookup_code%TYPE,
                              p_batch_id      IN          igf_gr_rfms_batch_all.batch_id%TYPE,
                              p_message       OUT NOCOPY  fnd_new_messages.message_name%TYPE);

FUNCTION get_min_disb_number (p_award_id igf_aw_award_all.award_id%TYPE)
RETURN NUMBER;
-- Added As part of FA121 Build (Verification Worksheet Enhancements)
FUNCTION chk_orig_isir_exists( p_base_id           IN igf_ap_fa_base_rec.base_id%TYPE,
                               p_transaction_num   IN igf_ap_ISIR_matched.transaction_num%TYPE)
RETURN BOOLEAN;


FUNCTION get_rep_pell_from_ope(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                               p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                               p_ope_cd     igf_gr_report_pell.ope_cd%TYPE)
RETURN VARCHAR2;

FUNCTION get_rep_pell_from_att(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                               p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                               p_att_pell   igf_gr_attend_pell.attending_pell_cd%TYPE)
RETURN VARCHAR2;

FUNCTION get_rep_pell_from_base(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                                p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                                p_base_id NUMBER)
RETURN VARCHAR2;

END igf_gr_gen;

 

/
