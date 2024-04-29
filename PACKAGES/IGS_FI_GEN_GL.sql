--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_GL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_GL" AUTHID CURRENT_USER AS
/* $Header: IGSFI75S.pls 120.1 2006/05/12 02:00:39 abshriva noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGS_FI_GEN_GL				 |
 |                                                                       |
 | NOTES                                                                 |
				  |New Package created for generic       |
 |			    	   procedures and functions              |
 |			 	   as per GL Interfac TD.
 |                                       Bug 2584986)                    |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | abshriva        12-MAY-2006     Added new function get_formatted_amount
 |                                 to return formatted amount            |
 | agairola        26-Nov-2002     Removed the procedures for Journal    |
 |                                 categories derivation                 |
 | SYKRISHN        05-NOV/2002     New Package created for generic       |
 |			    	   procedures and functions              |
 |			 	   as per GL Interface TD.
 | The below procedures/functions have been added new
    PROCEDURE finp_get_cur
    FUNCTION finp_ss_get_cur
    FUNCTION check_unposted_txns_exist
    PROCEDURE get_period_status_for_date
    FUNCTION check_gl_dt_appl_not_valid
    FUNCTION check_neg_chgadj_exists
    FUNCTION get_lkp_meaning
 *=======================================================================*/


  PROCEDURE finp_get_cur (
                          p_v_currency_cd OUT NOCOPY VARCHAR2,
			  p_v_curr_desc OUT NOCOPY VARCHAR2,
			  p_v_message_name OUT NOCOPY VARCHAR2);


  FUNCTION finp_ss_get_cur RETURN VARCHAR2;

  FUNCTION check_unposted_txns_exist(p_d_start_date IN DATE,
                                     p_d_end_date IN DATE,
				     p_v_accounting_mthd IN VARCHAR2) RETURN BOOLEAN;


  PROCEDURE get_period_status_for_date(p_d_date IN DATE,
				      p_v_closing_status OUT NOCOPY VARCHAR2,
                  		      p_v_message_name   OUT NOCOPY VARCHAR2);



  FUNCTION check_gl_dt_appl_not_valid (p_d_gl_date    IN DATE,
				      p_n_invoice_id IN NUMBER,
                  		      p_n_credit_id  IN NUMBER) RETURN BOOLEAN;


  FUNCTION check_neg_chgadj_exists (p_n_invoice_id IN NUMBER) RETURN BOOLEAN;


  FUNCTION get_lkp_meaning (p_v_lookup_type IN igs_lookup_values.lookup_type%TYPE ,
                            p_v_lookup_code IN igs_lookup_values.lookup_code%TYPE ) RETURN VARCHAR2;

/*Public function to return the formatted value of the input
  amount based on the currency precision
 **/
  FUNCTION get_formatted_amount ( p_n_amount IN NUMBER) RETURN NUMBER;

END igs_fi_gen_gl;

 

/
