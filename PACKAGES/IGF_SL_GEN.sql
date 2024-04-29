--------------------------------------------------------
--  DDL for Package IGF_SL_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_GEN" AUTHID CURRENT_USER AS
/* $Header: IGFSL12S.pls 120.1 2006/08/07 13:21:34 azmohamm noship $ */

  /****************************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  azmohamm       03-Aug-2006      FA-163 : Added chk_cl_gplus function
  museshad       06-May-2005      Bug# 4346258 - Added extra parameter 'p_base_id'
                                  to the function 'get_cl_version()'. This is
                                  needed to arrive at the correct CL version# by
                                  taking into account any CL version# override
                                  for any particular Organization Unit.
  sjadhav        09-Nov-2004      Bug #3416936.added rel code to cl version
  svuppala       20-Oct-2004      Bug #3416936.Added new update change status.

  smadathi        14-oct-2004     Bug 3416936.Added new generic functions as
                                  given in the TD.
  ugummall      14-OCT-2003       Bug# 3102439. FA 126 Multiple FA Offices.
                                  Added new routines get_associated_org and
                                  get_stu_fao_code.

  bkkumar       15-Sep-2003       Bug# 3104228. FA 122 Loans Enhancements
                                  Added new routine check_rel,get_person_details
                                  and check_lend_relation

  (reverse chronological order - newest change first)
  ***********************************************************************************/

  TYPE person_dtl_rec IS  RECORD
    (
    p_alien_reg_num          VARCHAR2(150),
    p_citizenship_status     VARCHAR2(30),
    p_date_of_birth          DATE,
    p_email_addr             VARCHAR2(2000),
    p_first_name             VARCHAR2(150),
    p_full_name              VARCHAR2(450),
    p_last_name              VARCHAR2(150),
    p_legal_res_date         DATE,
    p_license_num            VARCHAR2(20),
    p_license_state          VARCHAR2(30),
    p_middle_name            VARCHAR2(60),
    p_permt_addr1            VARCHAR2(240),
    p_permt_addr2            VARCHAR2(240),
    p_permt_city             VARCHAR2(60),
    p_permt_state            VARCHAR2(150),
    p_permt_zip              VARCHAR2(60),
    p_ssn                    VARCHAR2(20),
    p_state_of_legal_res     VARCHAR2(60),
    p_province               VARCHAR2(60),
    p_county                 VARCHAR2(60),
    p_country                VARCHAR2(60),
    p_local_addr1            VARCHAR2(240),
    p_local_addr2            VARCHAR2(240),
    p_local_city             VARCHAR2(60),
    p_local_state            VARCHAR2(150),
    p_local_zip              VARCHAR2(60)
    );

  TYPE person_dtl_cur IS REF CURSOR RETURN person_dtl_rec;


 PROCEDURE get_person_details    ( p_person_id        IN  igf_sl_cl_pref_lenders.person_id%TYPE,
                                   p_person_dtl_rec   IN OUT NOCOPY person_dtl_cur);
 PROCEDURE check_rel (
                      p_rel_code  IN  igf_sl_cl_setup_all.relationship_cd%TYPE,
                      p_flag      OUT NOCOPY VARCHAR2
                     );

FUNCTION  chk_dl_fed_fund_code(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;

FUNCTION  chk_dl_stafford(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;


FUNCTION  chk_dl_plus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;

FUNCTION  chk_cl_fed_fund_code(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;

FUNCTION  chk_cl_gplus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;

FUNCTION  chk_cl_stafford(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;

FUNCTION  chk_cl_plus(p_fed_fund_code   igf_aw_fund_cat_all.fed_fund_code%TYPE)
          RETURN VARCHAR2;
/* Function to check for Alternative Loan */
FUNCTION  chk_cl_alt(p_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE)
    RETURN VARCHAR2;

FUNCTION base10_to_base36(p_base_10   NUMBER)
          RETURN VARCHAR;

FUNCTION get_grade_level_desc(p_fed_fund_code    igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_grade_level_code igf_sl_lor_all.grade_level_code%TYPE)
          RETURN VARCHAR2;

FUNCTION get_enrollment_desc(p_fed_fund_code     igf_aw_fund_cat_all.fed_fund_code%TYPE,
                             p_enrollment_code   igf_sl_lor_all.enrollment_code%TYPE)
          RETURN VARCHAR2;

FUNCTION get_dl_version(p_ci_cal_type  igf_sl_dl_setup_all.ci_cal_type%TYPE,
                        p_ci_seq_num   igf_sl_dl_setup_all.ci_sequence_number%TYPE)
         RETURN VARCHAR2;

-- museshad. Bug# 4346258 - Added extra parameter p_base_id. This is needed to
-- arrive at the correct CL version# by taking into account any CL version#
-- override for any particular Organization Unit.
FUNCTION get_cl_version(p_ci_cal_type     igf_sl_cl_setup_all.ci_cal_type%TYPE,
                        p_ci_seq_num      igf_sl_cl_setup_all.ci_sequence_number%TYPE,
                        p_relationship_cd igf_sl_cl_setup_all.relationship_cd%TYPE,
                        p_base_id         igf_ap_fa_base_rec_all.base_id%TYPE)
         RETURN VARCHAR2;

FUNCTION get_dl_file_type(p_dl_version    igf_sl_dl_file_type.dl_version%TYPE,
                          p_dl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE,
                          p_dl_loan_catg  igf_sl_dl_file_type.dl_loan_catg%TYPE,
                          p_return_type   VARCHAR2)
         RETURN VARCHAR2;

PROCEDURE get_dl_batch_details(p_message_class IN  igf_sl_dl_file_type.message_class%TYPE,
                               p_batch_type    IN  igf_sl_dl_file_type.batch_type%TYPE,
                               p_dl_version    OUT NOCOPY igf_sl_dl_file_type.dl_version%TYPE,
                               p_dl_file_type  OUT NOCOPY igf_sl_dl_file_type.dl_file_type%TYPE,
                               p_dl_loan_catg  OUT NOCOPY igf_sl_dl_file_type.dl_loan_catg%TYPE);

FUNCTION get_cl_file_type(p_cl_version    igf_sl_dl_file_type.dl_version%TYPE,
                          p_cl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE,
                          p_return_type   VARCHAR2)
         RETURN VARCHAR2;

PROCEDURE get_cl_batch_details(p_file_ident_code IN  igf_sl_cl_file_type.file_ident_code%TYPE,
                               p_file_ident_name IN  igf_sl_cl_file_type.file_ident_name%TYPE,
                               p_cl_version      OUT NOCOPY igf_sl_cl_file_type.cl_version%TYPE,
                               p_cl_file_type    OUT NOCOPY igf_sl_cl_file_type.cl_file_type%TYPE);
/* Function to get the Disbursement Date */
FUNCTION get_disb_date(p_loan_id IN igf_sl_loans.loan_id%TYPE,
                       p_disb_num IN igf_aw_awd_disb.disb_num%TYPE)
   RETURN  DATE;
/* Function to get the Phone Number */
FUNCTION get_person_phone(p_person_id IN igs_pe_contacts_v.owner_table_id%TYPE)
         RETURN  VARCHAR2;

PROCEDURE check_lend_relation( p_person_id   IN  igf_sl_cl_pref_lenders.person_id%TYPE,
                                 p_start_date  IN  DATE,
                                 p_end_date    IN  DATE,
                                 p_message     OUT NOCOPY VARCHAR2);

/*  Procedure for obtaining responsible org unit code associated with the student */
PROCEDURE get_associated_org( p_base_id       IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                              x_org_unit_cd   OUT   NOCOPY hz_parties.party_number%TYPE,
                              x_org_party_id  OUT   NOCOPY hz_parties.party_id%TYPE,
                              x_module        OUT   NOCOPY VARCHAR2,
                              x_return_status OUT   NOCOPY VARCHAR2,
                              x_msg_data      OUT   NOCOPY VARCHAR2);

/* Procedure for obtaining school code configured at Org Unit of the Student's key program */
PROCEDURE get_stu_fao_code( p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_office_type     IN    igs_lookups_view.lookup_code%TYPE,
                            x_office_cd       OUT   NOCOPY igs_or_org_alt_ids.org_alternate_id_type%TYPE,
                            x_return_status   OUT   NOCOPY VARCHAR2,
                            x_msg_data        OUT   NOCOPY VARCHAR2);

FUNCTION get_fed_fund_code (p_n_award_id      IN igf_aw_award_all.award_id%TYPE,
                            p_v_message_name  OUT NOCOPY VARCHAR2)
RETURN igf_aw_fund_cat_all.fed_fund_code%TYPE;

FUNCTION check_prc_chg (p_v_relationship_cd IN igf_sl_cl_setup_all.relationship_cd%TYPE,
                        p_v_cal_type        IN igf_aw_fund_mast_all.ci_cal_type%TYPE ,
                        p_n_sequence_number IN igf_aw_fund_mast_all.ci_sequence_number%TYPE
                        )
RETURN BOOLEAN;

FUNCTION check_prc_chgm (p_v_relationship_cd IN igf_sl_cl_setup_all.relationship_cd%TYPE,
                         p_v_cal_type        IN igf_aw_fund_mast_all.ci_cal_type%TYPE ,
                         p_n_sequence_number IN igf_aw_fund_mast_all.ci_sequence_number%TYPE
                        )
RETURN BOOLEAN;

PROCEDURE update_cl_chg_status(p_v_loan_number IN igf_sl_loans_all.loan_number%TYPE);

PROCEDURE get_stu_ant_fao_code
                             (p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
			      p_office_type     IN    igs_lookups_view.lookup_code%TYPE,
			      x_office_cd       OUT   NOCOPY igs_or_org_alt_ids.org_alternate_id_type%TYPE,
			      x_return_status   OUT   NOCOPY VARCHAR2,
                              x_msg_data        OUT   NOCOPY VARCHAR2);


END igf_sl_gen;

 

/
