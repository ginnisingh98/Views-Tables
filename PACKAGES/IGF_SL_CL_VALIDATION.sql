--------------------------------------------------------
--  DDL for Package IGF_SL_CL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: IGFSL07S.pls 115.9 2003/10/30 07:09:14 ugummall ship $ */

/***************************************************************
   Created By		:	mesriniv
   Date Created By	:	2000/11/17
   Purpose		:	To Validate Common Line Loans and
   				Update the Loan Status accordingly.
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			        When		        What
   ugummall         29-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                    Added two new parameters p_school_id and p_base_id to cl_lar_validate function.

   veramach             19-SEP-2003     FA 122 Loan Enhancements Build
                                        1. Removed references to igf_sl_lor_dtls_v from the functions cl_lar_validate
					2. Changed the overloaded function cl_lar_validate
 ***************************************************************/


FUNCTION cl_lar_validate(
p_ci_cal_type			      IN		igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
p_ci_sequence_number		IN		igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
p_loan_number			      IN		igf_sl_loans_all.loan_number%TYPE,
p_loan_catg			        IN		igf_lookups_view.lookup_code%TYPE,
p_call_mode            	IN		VARCHAR2 DEFAULT 'JOB',
p_school_id             IN    VARCHAR2 DEFAULT NULL,
p_base_id               IN    VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN;

END igf_sl_cl_validation;

 

/
