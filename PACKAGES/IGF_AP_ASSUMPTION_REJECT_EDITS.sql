--------------------------------------------------------
--  DDL for Package IGF_AP_ASSUMPTION_REJECT_EDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ASSUMPTION_REJECT_EDITS" AUTHID CURRENT_USER AS
/* $Header: IGFAP33S.pls 115.3 2003/02/20 10:03:46 masehgal noship $ */
/*
  ||  Created By : masehgal
  ||  Created On : 03-FEB-2003
  ||  Purpose : Ti make the assumption edits, model determination, assign reject reasons.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

PROCEDURE assume_values  (  p_isir_rec       IN  OUT NOCOPY   igf_ap_isir_matched%ROWTYPE ,
	                         l_sys_batch_yr   IN               VARCHAR2   ) ;
/***************************************************************
Created By		:	masehgal
Date Created By	:	03-Feb-2003
Purpose		:	To make assumption values
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/



PROCEDURE reject_edits   (  p_isir_rec       IN  OUT NOCOPY   igf_ap_isir_matched%ROWTYPE ,
	                         p_sys_batch_yr   IN               VARCHAR2 ,
                            p_reject_codes       OUT NOCOPY   VARCHAR2 ) ;
/***************************************************************
Created By		:	masehgal
Date Created By	:	03-Feb-2003
Purpose		:	To display reject reasons for Student
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/


END igf_ap_assumption_reject_edits ;


 

/
