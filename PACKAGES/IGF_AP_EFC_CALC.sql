--------------------------------------------------------
--  DDL for Package IGF_AP_EFC_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_EFC_CALC" AUTHID CURRENT_USER AS
/* $Header: IGFAP25S.pls 115.10 2003/08/05 10:13:28 rasahoo noship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose : Bug No - 2142666 EFC DLD.
  ||            This Package contains procedures for the Concurrent Program EFC Calculation
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal,sgaddama,gmuralid,cdcruz  08-03-2003  BUG# 2833795 - EFC Mismatch Base BUG
  ||  masehgal        15-feb-2003     # 2758804   FACR105  EFC Build - Package Revamped
  ||  cdcruz          18-Oct-2003     Bug# 2613546 FUNCTION get_efc_no_of_months has been modified
  ||                                  P_flag parameter has been dropped
  ||
*/

EXCEPTION_IN_REJECTS  EXCEPTION ;
EXCEPTION_IN_SETUP    EXCEPTION ;

g_efc_a_9             igf_ap_isir_matched_all.paid_efc%TYPE ;
g_efc_a_10            igf_ap_isir_matched_all.paid_efc%TYPE ;
g_efc_a_11            igf_ap_isir_matched_all.paid_efc%TYPE ;
g_efc_a_12            igf_ap_isir_matched_all.paid_efc%TYPE ;

g_s_efc_a_9             igf_ap_isir_matched_all.paid_efc%TYPE ;
g_s_efc_a_10            igf_ap_isir_matched_all.paid_efc%TYPE ;
g_s_efc_a_11            igf_ap_isir_matched_all.paid_efc%TYPE ;
g_s_efc_a_12            igf_ap_isir_matched_all.paid_efc%TYPE ;

isir_rec              igf_ap_isir_matched%ROWTYPE ;
p_sys_award_year      VARCHAR2(30)  ;


FUNCTION get_efc_no_of_months (p_last_end_dt         IN  DATE,                            -- end date of the Last Teaching/Load calendar
	                            p_base_id        IN  igf_ap_fa_base_rec.base_id%TYPE) -- Students Base Id
                               RETURN  NUMBER;
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 11-DEC-2001
  ||  Purpose : Bug No - 2142666 EFC DLD.
  ||            This procedure finds the exact number of months not repeating the overlapped terms
  ||            and neglecting the gap between terms.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


PROCEDURE calculate_efc (p_isir_rec         IN  OUT  NOCOPY    igf_ap_isir_matched%ROWTYPE ,
                         p_ignore_warnings  IN                 VARCHAR2 ,
                         p_sys_batch_yr     IN                 VARCHAR2 ,
                         p_return_status        OUT  NOCOPY    VARCHAR2 ) ;
  /*
  ||  Created By : masehgal
  ||  Created On : 11-Feb-2003
  ||  Purpose : Main EFC Engine
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


END igf_ap_efc_calc;

 

/
