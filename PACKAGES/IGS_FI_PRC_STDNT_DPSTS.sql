--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_STDNT_DPSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_STDNT_DPSTS" AUTHID CURRENT_USER AS
/* $Header: IGSFI77S.pls 115.1 2002/12/16 14:49:32 vchappid noship $ */

/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 05-DEC-2002
Purpose           : This package contains the specification for the
                    Process Deposits concurrent request. This process
                    has an out come of either Transferring the Deposit
                    to the Student Account as a Payment or Forfeit the
                    Deposit or take no action on the Deposit transaction.

                    Function check_acad_load_adm_rel is defined in the
                    specification as it has been used in a select statement

Known limitations,
enhancements,
remarks            :
Change History
Who      When          What
******************************************************************/
  PROCEDURE prc_stdnt_deposit ( errbuf           OUT NOCOPY  VARCHAR2,
                               retcode           OUT NOCOPY  NUMBER,
                               p_c_credit_class              VARCHAR2,
                               p_n_person_id_grp             NUMBER,
                               p_n_person_id                 NUMBER,
                               p_n_credit_type_id            NUMBER,
                               p_c_term_cal_inst             VARCHAR2,
                               p_d_gl_date                   VARCHAR2,
                               p_c_test_mode                 VARCHAR2
                               ) ;

  FUNCTION check_acad_load_adm_rel(p_c_load_cal_type         VARCHAR2,
                                   p_n_load_ci_seq_num       NUMBER,
                                   p_c_acad_cal_type         VARCHAR2,
                                   p_n_acad_ci_seq_num       NUMBER,
                                   p_c_adm_cal_type          VARCHAR2,
                                   p_n_adm_ci_seq_num        NUMBER) RETURN VARCHAR2;

END igs_fi_prc_stdnt_dpsts;

 

/
