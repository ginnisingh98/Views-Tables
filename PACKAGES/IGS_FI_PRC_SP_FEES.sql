--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_SP_FEES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_SP_FEES" AUTHID CURRENT_USER AS
/* $Header: IGSFI89S.pls 120.0 2005/06/03 15:47:54 appldev noship $ */
/************************************************************************
  Created By :  Priya Athipatla
  Date Created By :  15-Oct-2003
  Purpose :  Package for Special Fees processing

  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
 vvutukur        05-Jan-2004     Bug#3346618.Removed procedure assess_fees_pvt
                                 from spec as it is private to this package body.
*************************************************************************/
PROCEDURE assess_fees( errbuf              OUT NOCOPY VARCHAR2,
                       retcode             OUT NOCOPY NUMBER,
                       p_n_person_id       IN  NUMBER,
                       p_n_person_grp_id   IN  NUMBER,
                       p_v_fee_period      IN  VARCHAR2,
                       p_v_test_run        IN  VARCHAR2,
                       p_d_gl_date         IN  VARCHAR2 ) ;

PROCEDURE process_special_fees(p_n_person_id  IN PLS_INTEGER,
                               p_v_fee_cal_type  IN VARCHAR2,
                               p_n_fee_ci_seq_number IN PLS_INTEGER,
                               p_v_load_cal_type IN VARCHAR2,
                               p_n_load_ci_seq_number IN PLS_INTEGER,
                               p_d_gl_date  IN DATE,
                               p_v_test_run  IN VARCHAR2,
                               p_b_log_messages  IN BOOLEAN,
                               p_b_recs_found  OUT NOCOPY BOOLEAN,
                               p_v_return_status OUT NOCOPY VARCHAR2);

END igs_fi_prc_sp_fees;

 

/
