--------------------------------------------------------
--  DDL for Package IGF_SL_REL_DISB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_REL_DISB" AUTHID CURRENT_USER AS
/* $Header: IGFSL27S.pls 120.1 2006/04/05 00:22:45 veramach noship $ */

-----------------------------------------------------------------------------------
--
--   Created By   : pssahni
--   Date Created By  : 2004/09/24
--   Purpose    :
-----------------------------------------------------------------------------------

-- This is the callable from Concurrent Manager

 PROCEDURE rel_disb_process_dl(errbuf           OUT NOCOPY   VARCHAR2,
                           retcode          OUT NOCOPY   NUMBER,
                           p_award_year     IN           VARCHAR2,
                           p_pell_dummy     IN           VARCHAR2,
                           p_dl_dummy       IN           VARCHAR2,
                           p_fund_id        IN           igf_aw_fund_mast_all.fund_id%TYPE,
                           p_base_id        IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_per_dummy      IN           NUMBER,
                           p_loan_id        IN           NUMBER,
                           p_loan_dummy     IN           NUMBER,
                           p_per_grp_id     IN           NUMBER,
                           p_trans_type     IN           igf_aw_awd_disb_all.trans_type%TYPE
                           );


 PROCEDURE rel_disb_process_fed(errbuf           OUT NOCOPY   VARCHAR2,
                           retcode          OUT NOCOPY   NUMBER,
                           p_award_year     IN           VARCHAR2,
                           p_fund_id        IN           igf_aw_fund_mast_all.fund_id%TYPE,
                           p_base_id        IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_per_dummy      IN           NUMBER,
                           p_loan_id        IN           NUMBER,
                           p_loan_dummy     IN           NUMBER,
                           p_trans_type     IN           VARCHAR2,
                           p_per_grp_id     IN           NUMBER

                           );

-- Parameters
--
-- p_award_year         Award Year
-- p_fund_id            Fund ID
-- p_base_id            Base ID
-- p_loan_id            Loan ID
-- p_per_grp_id         Person Group ID

PROCEDURE rel_disb_process(p_errbuf           OUT NOCOPY   VARCHAR2,
                           p_retcode          OUT NOCOPY   NUMBER,
                           p_award_year     IN           VARCHAR2,
                           p_fund_id        IN           igf_aw_fund_mast_all.fund_id%TYPE,
                           p_base_id        IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_loan_id        IN           NUMBER,
                           p_trans_type     IN           VARCHAR2,
                           p_per_grp_id     IN           NUMBER
                           );


PROCEDURE process_student( p_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_result     IN OUT NOCOPY VARCHAR2,
                           p_fund_id    igf_aw_fund_mast_all.fund_id%TYPE,
                           p_award_id   igf_aw_award_all.award_id%TYPE,
                           p_loan_id    igf_sl_loans_all.loan_id%TYPE,
                           p_disb_num   igf_aw_awd_disb_all.disb_num%TYPE,
                           p_trans_type VARCHAR2
                          );

END igf_sl_rel_disb;

 

/
