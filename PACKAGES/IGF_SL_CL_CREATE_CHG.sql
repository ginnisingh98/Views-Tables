--------------------------------------------------------
--  DDL for Package IGF_SL_CL_CREATE_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_CREATE_CHG" AUTHID CURRENT_USER AS
/* $Header: IGFSL22S.pls 120.0 2005/06/01 13:54:38 appldev noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 10 October 2004
  --
  --Purpose:
  -- Invoked     : Through Table Handlers of Disbursement and Loans table
  -- Function    : To create Change Records for CommonLine Release 4 version Loans.
  --               Four routines defined in this package would be invoked for changes
  --               IN award or loan information for CommonLine Release 4 version Loans
  --               that are "Accepted"
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

  PROCEDURE create_loan_chg_rec( p_new_loan_rec    IN  igf_sl_loans_all%ROWTYPE,
                                 p_b_return_status OUT NOCOPY BOOLEAN,
                                 p_v_message_name  OUT NOCOPY VARCHAR2
                                );

  PROCEDURE create_lor_chg_rec ( p_new_lor_rec     IN  igf_sl_lor_all%ROWTYPE,
                                 p_b_return_status OUT NOCOPY BOOLEAN,
                                 p_v_message_name  OUT NOCOPY VARCHAR2
                               );

  PROCEDURE create_awd_chg_rec ( p_n_award_id      IN igf_aw_award_all.award_id%TYPE,
                                 p_n_old_amount    IN NUMBER,
                                 p_n_new_amount    IN NUMBER,
                                 p_v_chg_type      IN VARCHAR2,
                                 p_b_return_status OUT NOCOPY BOOLEAN,
                                 p_v_message_name  OUT NOCOPY VARCHAR2
                               );

  PROCEDURE create_disb_chg_rec ( p_new_disb_rec    IN igf_aw_awd_disb_all%ROWTYPE,
                                  p_old_disb_rec    IN igf_aw_awd_disb_all%ROWTYPE,
                                  p_b_return_status OUT NOCOPY BOOLEAN,
                                  p_v_message_name  OUT NOCOPY VARCHAR2
                               );

END igf_sl_cl_create_chg;

 

/
