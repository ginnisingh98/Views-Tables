--------------------------------------------------------
--  DDL for Package IGF_SE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SE_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGFSE01S.pls 120.1 2005/08/18 03:23:10 appldev ship $ */

  ------------------------------------------------------------------------------------
  -- Created by  :
  -- Date created:
  -- Purpose:
  --
  --
  --
  -- Known limitations/enhancements and/or remarks:
  -- Change History:
  -- Who         When            What
  --ridas        29/Jul/2005     Bug #3536039. New exception (IGFSEGEN001) added.
  --veramach     July 2004       FA 151 HR Integration (Bug# 3709292) Changes
  --                             New parameter(AUTH_DATE) added to send_work_auth
  --                             New parameter(p_dummy) added to send_work_auth_job
  --                             New parameter(AWARD_ID) added to se_notify
  -------------------------------------------------------------------------------------

  IGFSEGEN001     EXCEPTION;

  PROCEDURE send_work_auth(
                           p_base_id      IN  igf_ap_fa_base_rec.base_id%TYPE,
                           p_person_id    IN  hz_parties.party_id%TYPE,
                           p_fund_id      IN  igf_aw_fund_mast.fund_id%TYPE,
                           p_award_id     IN  igf_aw_award.award_id%TYPE,
                           p_ld_cal_type  IN  igs_ca_inst.cal_type%TYPE,
                           p_ld_seq_no    IN  igs_ca_inst.sequence_number%TYPE,
                           p_call         IN  VARCHAR2 DEFAULT 'FORM',
                           p_auth_date    IN DATE DEFAULT SYSDATE
                          );


  PROCEDURE send_work_auth_job(
                               errbuf     OUT NOCOPY VARCHAR2,
                               retcode    OUT NOCOPY NUMBER,
                               p_awd_cal  IN  VARCHAR2,
                               p_fund_id  IN  igf_aw_fund_mast_all.fund_id%TYPE,
                               p_dummy    IN  NUMBER,
                               p_base_id  IN  igf_ap_fa_base_rec_all.base_id%TYPE
                              ) ;

  PROCEDURE payroll_uplaod(
                           errbuf      OUT NOCOPY varchar2,
                           retcode     OUT NOCOPY number,
                           p_batch_id  IN  igf_se_payment_int.batch_id%TYPE,
                           p_auth_id   IN  igf_se_auth.auth_id%TYPE,
                           p_level     IN  VARCHAR2 DEFAULT 'N'
                          ) ;

  PROCEDURE payroll_adjust(
                           p_payment_rec  IN  igf_se_payment%ROWTYPE,
                           p_status       OUT NOCOPY igf_se_payment_int.status%TYPE,
                           p_error_cd     OUT NOCOPY igf_se_payment_int.error_code%TYPE
                          );


  PROCEDURE se_notify(
                      p_person_id    IN  hz_parties.party_id%TYPE,
                      p_fund_id      IN  igf_aw_fund_mast.fund_id%TYPE,
                      p_ld_cal_type  IN  igs_ca_inst.cal_type%TYPE,
                      p_ld_seq_no    IN  igs_ca_inst.sequence_number%TYPE,
                      p_award_id     IN  igf_aw_award_all.award_id%TYPE
                     );


END igf_se_gen_001;

 

/
