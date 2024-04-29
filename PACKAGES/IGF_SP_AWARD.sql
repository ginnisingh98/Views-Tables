--------------------------------------------------------
--  DDL for Package IGF_SP_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_AWARD" AUTHID CURRENT_USER AS
/* $Header: IGFSP03S.pls 115.1 2002/11/28 14:36:24 nsidana noship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This is a batch process that created both Award and disbursement
  --          for a fund in FA system. Process will also check for the eligibility
  --          and validations before awarding the Sponsor amount to the students.
  --          Awarding money to the students can be done manually apart from awarding
  --          money through a batch process.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------

  PROCEDURE create_award_disb
              (errbuf               OUT NOCOPY VARCHAR2,
               retcode              OUT NOCOPY NUMBER,
	       p_award_year         IN  VARCHAR2,
	       p_term_calendar      IN  VARCHAR2,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_person_group_id    IN  igs_pe_prsid_grp_mem.group_id%TYPE,
	       p_fund_id            IN  igf_sp_stdnt_rel.fund_id%TYPE,
	       p_award_type         IN  igf_aw_awd_disb.trans_type%TYPE,
	       p_test_mode          IN  VARCHAR2,
	       p_org_id             IN  NUMBER DEFAULT NULL);

END IGF_SP_AWARD;

 

/
