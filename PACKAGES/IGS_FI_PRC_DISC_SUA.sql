--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_DISC_SUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_DISC_SUA" AUTHID CURRENT_USER AS
/* $Header: IGSFI64S.pls 120.0 2005/06/01 21:44:22 appldev noship $ */

  PROCEDURE drop_disc_sua_non_payment
  (
                                      ERRBUF                    OUT NOCOPY  VARCHAR2,
                                      RETCODE                   OUT NOCOPY  NUMBER,
                                      p_person_id               IN  igs_pe_person.person_id%type,
                                      p_person_id_grp           IN  igs_pe_prsid_grp_mem_v.group_id%type,
                                      p_fee_period              IN  VARCHAR2,
                                      p_balance_type            IN  igs_fi_balance_rules.balance_name%type,
                                      p_dcnt_reason_cd          IN  igs_en_dcnt_reasoncd_v.discontinuation_reason_cd%type,
                                      p_test_run                IN  VARCHAR2 DEFAULT 'Y'
  );

END igs_fi_prc_disc_sua;

 

/
