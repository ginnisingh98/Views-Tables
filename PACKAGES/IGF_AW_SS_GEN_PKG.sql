--------------------------------------------------------
--  DDL for Package IGF_AW_SS_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_SS_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAW23S.pls 120.1 2005/10/17 03:18:41 appldev noship $ */
  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE update_awards_from_ss ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                  p_offered_amt   NUMBER,
                                  p_accepted_amt  NUMBER,
                                  p_award_status  VARCHAR2
                                 );

PROCEDURE update_award_status ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                p_award_status  VARCHAR2,
                                p_lock_status   VARCHAR2);

PROCEDURE update_awards_by_term_from_ss ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                          p_ld_cal_type   VARCHAR2,
                                          p_ld_seq_num    NUMBER,
                                          p_offered_amt   NUMBER,
                                          p_accepted_amt  NUMBER,
                                          p_term_awd_status VARCHAR2);

FUNCTION  get_awd_action  ( p_ci_cal_type         VARCHAR2,
                            p_ci_sequence_number  NUMBER,
                            p_award_prd_cd        VARCHAR2,
                            p_base_id             NUMBER)
RETURN VARCHAR2;

FUNCTION  get_accept_amt_display_mode ( p_award_id      NUMBER,
                                        p_accepted_amt  NUMBER,
                                        p_offered_amt   NUMBER)
RETURN VARCHAR2;

FUNCTION  get_accept_display_mode ( p_award_id      NUMBER,
                                    p_accepted_amt  NUMBER,
                                    p_offered_amt   NUMBER)
RETURN VARCHAR2;

FUNCTION  get_decline_display_mode  ( p_award_id      NUMBER,
                                      p_accepted_amt  NUMBER,
                                      p_offered_amt   NUMBER)
RETURN VARCHAR2;

PROCEDURE apply_certf_resp(p_base_id            number,
                           p_ci_cal_type        varchar2,
                           p_ci_sequence_number number,
                           p_award_prd_cd       varchar2,
                           p_cert_code          varchar2,
                           p_response           VARCHAR2);

PROCEDURE submit_business_event (p_description VARCHAR2,
                                 p_award_prd      VARCHAR2,
                                 p_person_number  VARCHAR2,
                                 p_details        VARCHAR2);

FUNCTION get_acc_amt_display_mode_term( p_award_id      NUMBER,
                                        p_accepted_amt  NUMBER,
                                        p_offered_amt   NUMBER,
                                        p_ld_cal_type   VARCHAR2,
                                        p_ld_seq_num    NUMBER)
RETURN VARCHAR2;

FUNCTION  get_acc_display_mode_term(p_award_id      NUMBER,
                                    p_accepted_amt  NUMBER,
                                    p_offered_amt   NUMBER,
                                    p_ld_cal_type   VARCHAR2,
                                    p_ld_seq_num    NUMBER)
RETURN VARCHAR2;

FUNCTION  get_dec_display_mode_term(p_award_id      NUMBER,
                                    p_accepted_amt  NUMBER,
                                    p_offered_amt   NUMBER,
                                    p_ld_cal_type   VARCHAR2,
                                    p_ld_seq_num    NUMBER)
RETURN VARCHAR2;

FUNCTION get_term_award_status (p_award_id      NUMBER,
                                p_ld_cal_type   VARCHAR2,
                                p_ld_seq_num    NUMBER)
RETURN VARCHAR2;

END IGF_AW_SS_GEN_PKG;

 

/
