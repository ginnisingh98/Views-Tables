--------------------------------------------------------
--  DDL for Package IGF_AP_LG_COA_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LG_COA_IMP" AUTHID CURRENT_USER AS
/* $Header: IGFAP40S.pls 115.0 2003/06/08 08:49:59 masehgal noship $ */
/*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose : to import Legacy Data for Student Cost of Attendance items
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  PROCEDURE main ( errbuf          OUT NOCOPY VARCHAR2,
                 retcode           OUT NOCOPY NUMBER,
                 p_award_year      IN         VARCHAR2,
                 p_batch_num       IN         VARCHAR2,
                 p_delete_flag     IN         VARCHAR2 ) ;
/***************************************************************
Created By	:	masehgal
Date Created By	:	28-May-2003
Purpose		:	To import COA Items for Student
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/

    g_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE ;
    g_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;

END igf_ap_lg_coa_imp ;


 

/
