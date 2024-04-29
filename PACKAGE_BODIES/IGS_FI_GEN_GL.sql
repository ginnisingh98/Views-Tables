--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_GL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_GL" AS
/* $Header: IGSFI75B.pls 120.1 2006/05/12 01:49:04 abshriva noship $ */

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
 |			 	   as per GL Interface TD.  (Bug 2584986)|
 | HISTORY                                                               |
 | Who             When            What                                  |
 | abshriva        12-MAY-2006     Added new function get_formatted_amount
 |                                 to return formatted amount            |
 | vvutukur        12-Jan-2004     Bug#3348787.Modified finp_get_cur.    |
 | schodava        29-Sep-2003	   Bug # 3112084 - Modified procedure    |
 |                                 finp_get_cur                          |
 | agairola        26-Nov-2002     Removed the procedures for the        |
 |                                 derivation of the Journal Categories  |
 | SYKRISHN        05-NOV/2002     New Package created for generic       |
 |			    	   procedures and functions              |
 |			 	   as per GL Interface TD.               |
 *=======================================================================*/
  g_old_reference         fnd_currencies%ROWTYPE;


 PROCEDURE finp_get_cur ( p_v_currency_cd OUT NOCOPY VARCHAR2,
			  p_v_curr_desc OUT NOCOPY VARCHAR2,
			  p_v_message_name OUT NOCOPY VARCHAR2) AS
  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Procedure to get the local functional currency details
			Returns message name if error occurs
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who		When		What
  vvutukur      12-Jan-2004     Bug#3348787.Modified cursor c_curr_desc to put filter on language
                                while selecting currency from fnd_currencies_tl.
  schodava	29-Sep-2003	Bug # 3112084 - Modified cursor cur_ctrl, to
				fetch the currency name from fnd_currencies_tl
   ******************************************************************/

   -- get the currency code
   CURSOR cur_ctrl IS
   SELECT currency_cd
   FROM   igs_fi_control_all;

   -- Get the name of the currency
   CURSOR c_curr_desc(cp_currency_cd IN igs_fi_control_all.currency_cd%TYPE
             ) IS
     SELECT name
     FROM   fnd_currencies_tl
     WHERE  currency_code = cp_currency_cd
     AND    language = USERENV('LANG');

 BEGIN
        p_v_message_name := NULL;
	OPEN cur_ctrl;
	FETCH cur_ctrl INTO p_v_currency_cd;

        IF cur_ctrl%NOTFOUND THEN
	  CLOSE cur_ctrl;
	  p_v_currency_cd := NULL;
	  p_v_curr_desc := NULL;
	  p_v_message_name := 'IGS_FI_SYSTEM_OPT_SETUP';
	  RETURN;
        END IF;

	OPEN c_curr_desc(p_v_currency_cd);
	FETCH c_curr_desc INTO p_v_curr_desc;
	CLOSE c_curr_desc;

	CLOSE cur_ctrl;
  END finp_get_cur;


 FUNCTION finp_ss_get_cur RETURN VARCHAR2 AS
  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Function to only return currency_cd (to be used in SS)

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

   l_v_currency_cd igs_fi_control_v.currency_cd%TYPE;
   l_v_currency_desc igs_fi_control_v.name%TYPE;
   l_v_message_name fnd_new_messages.message_name%TYPE := NULL;

 BEGIN

       --Invoke procedure to get currency
       igs_fi_gen_gl.finp_get_cur(l_v_currency_cd,
	                          l_v_currency_desc,
				  l_v_message_name);

        -- If error then return null
      IF l_v_message_name IS NOT NULL THEN
	   RETURN NULL;
      ELSE
           RETURN l_v_currency_cd;
      END IF;

 END finp_ss_get_cur;



 FUNCTION check_unposted_txns_exist (p_d_start_date IN DATE,
                                     p_d_end_date IN DATE,
				     p_v_accounting_mthd IN VARCHAR2) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Function to check for any unposted transactions
  		      This function returns Boolean. TRUE if
		      Unposted Transaction exists and FALSE if not.

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/


--Cursor to validate the accounting method param
CURSOR cur_acct_mth(cp_v_accounting_mthd IN igs_fi_control.accounting_method%TYPE) IS
SELECT lookup_code
FROM   igs_lookup_values
WHERE lookup_code = cp_v_accounting_mthd
AND lookup_type = 'IGS_FI_ACCT_METHOD'
AND enabled_flag = 'Y'
AND trunc(sysdate) BETWEEN trunc(NVL(start_date_active, SYSDATE)) AND trunc(NVL(end_date_active, SYSDATE));


--Cursor to check unposted transactions in credit activities table.

 CURSOR cur_credit_activities(cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                              cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS

 SELECT 'Y'
 FROM   igs_fi_cr_activities crac
 WHERE  crac.gl_date IS NOT NULL
 AND    TRUNC(crac.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
 AND    crac.posting_id IS NULL
 AND    crac.posting_control_id IS NULL;



--Cursor to check unposted transactions in applications table.

CURSOR cur_appl(cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS

SELECT 'Y'
FROM   igs_fi_applications appl
WHERE  appl.gl_date IS NOT NULL
AND    TRUNC(appl.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
AND    appl.posting_id IS NULL
AND    appl.posting_control_id IS NULL;



--Cursor to check unposted transactions in adm applications fees table. (only posting control id need to be checked)
CURSOR cur_adm_fee	(cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                         cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS
SELECT 'Y'
FROM   igs_ad_app_req adm
WHERE  adm.gl_date IS NOT NULL
AND    TRUNC(adm.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
AND    adm.posting_control_id IS NULL;


--Cursor to check unposted transactions in charges table.
CURSOR cur_inv	(cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                 cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS
SELECT 'Y'
FROM   igs_fi_invln_int_all invln
WHERE  invln.gl_date IS NOT NULL
AND    TRUNC(invln.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
AND    invln.posting_id IS NULL
AND    invln.posting_control_id IS NULL;


l_v_accounting_method igs_fi_control.accounting_method%TYPE;
l_v_exist VARCHAR2(1);

 BEGIN

 -- Sanity Validation of the input parameters to raise exception
 -- We know that this is a function invoked by igsfi071- hence the validation to raise exception only
    IF (p_d_start_date IS NULL) OR (p_d_end_date IS NULL) THEN
	    app_exception.raise_exception;
    END IF;

    IF TRUNC(p_d_start_date) > TRUNC(p_d_end_date) THEN
	    app_exception.raise_exception;
    END IF;

    OPEN cur_acct_mth(p_v_accounting_mthd);
    FETCH cur_acct_mth INTO l_v_accounting_method;
       IF cur_acct_mth%NOTFOUND THEN
            CLOSE cur_acct_mth;
	    app_exception.raise_exception;
       END IF;
    CLOSE cur_acct_mth;
 -- Sanity Validation of the input parameters to raise exception

 --If the value of the parameter P_V_ACCOUNTING_MTHD is CASH or ACCRUAL then existence of unposted transactions needs to be checked in
 --the credit activities, the applications table and admission application fees table.

--
  OPEN cur_credit_activities(cp_d_gl_date_start  => p_d_start_date,
                             cp_d_gl_date_end    => p_d_end_date);
  FETCH cur_credit_activities INTO l_v_exist;
       IF cur_credit_activities%FOUND THEN
          CLOSE cur_credit_activities;
          RETURN TRUE;
       END IF;
  CLOSE cur_credit_activities;
--

  OPEN cur_appl(cp_d_gl_date_start  => p_d_start_date,
                cp_d_gl_date_end    => p_d_end_date);
  FETCH cur_appl INTO l_v_exist;
       IF cur_appl%FOUND THEN
          CLOSE cur_appl;
          RETURN TRUE;
       END IF;
  CLOSE cur_appl;
--
  OPEN cur_adm_fee(cp_d_gl_date_start  => p_d_start_date,
                   cp_d_gl_date_end    => p_d_end_date);
  FETCH cur_adm_fee INTO l_v_exist;
       IF cur_adm_fee%FOUND THEN
          CLOSE cur_adm_fee;
          RETURN TRUE;
       END IF;
  CLOSE cur_adm_fee;

--This check needs to happen only when accounting method is ACCRUAL

 IF p_v_accounting_mthd = 'ACCRUAL' THEN
  OPEN cur_inv(cp_d_gl_date_start  => p_d_start_date,
               cp_d_gl_date_end    => p_d_end_date);
  FETCH cur_inv INTO l_v_exist;
       IF cur_inv%FOUND THEN
          CLOSE cur_inv;
          RETURN TRUE;
       END IF;
  CLOSE cur_inv;
 END IF;

-- If no unposted transactions exist ina any of the above, then return FALSE to denote than no unposted txns exist at all.

 RETURN FALSE;


 END check_unposted_txns_exist;

 PROCEDURE get_period_status_for_date(p_d_date IN DATE,
				      p_v_closing_status OUT NOCOPY VARCHAR2,
                  		      p_v_message_name   OUT NOCOPY VARCHAR2) AS
  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Procedure to get the period's closing status in which a passed date belong to

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/




--Cursor to Derive the Set Of books defined in the system options form- Use the Set of Books ID derived  (SET_OF_BOOKS_ID) to
--access the view IGS_FI_GL_PERIODS_V to get the CLOSING_STATUS of the period in which the passed P_D_DATE belongs to.
CURSOR cur_closing_status IS
SELECT closing_status
FROM   igs_fi_gl_periods_v
WHERE  TRUNC(p_d_date) BETWEEN TRUNC(start_date) AND TRUNC(end_date)
AND    set_of_books_id = igs_fi_gen_007.get_sob_id;

 BEGIN
    p_v_message_name := NULL;
    p_v_closing_status := NULL;

 -- Validate if p_d_date passed is null
    IF (p_d_date IS NULL) THEN
        p_v_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER' ;
	RETURN;
    END IF;

--If the passed P_D_DATE is Current System Date , then return P_V_CLOSING_STATUS = O and return from procedure. No validation required when the date passed is SYSDATE.
--OR If the Oracle Financials Installed is derived as Y, then proceed with remaining steps . If the value is N, then return P_V_CLOSING_STATUS = O and return from procedure.
--Derive the value of Oracle Financials Installed value defined in the system options

    IF (TRUNC(p_d_date) = TRUNC(SYSDATE)) OR (igs_fi_gen_005.finp_get_receivables_inst  = 'N') THEN
        p_v_closing_status := 'O';
    	RETURN;
    END IF;

--Derive the Set Of books defined in the system options form- Use the Set of Books ID derived  (SET_OF_BOOKS_ID) to
--access the view IGS_FI_GL_PERIODS_V to get the CLOSING_STATUS of the period in which the passed P_D_DATE belongs to.
 OPEN cur_closing_status;
 FETCH cur_closing_status INTO p_v_closing_status;
     IF cur_closing_status%NOTFOUND THEN
         CLOSE cur_closing_status;
         p_v_closing_status := NULL;
	 p_v_message_name := 'IGS_FI_GL_DT_NT_IN_PER';
	 RETURN;
     END IF;
  p_v_message_name := NULL;
  -- Return the appropriate closing status derived.
 CLOSE cur_closing_status;


 END get_period_status_for_date;



 FUNCTION check_gl_dt_appl_not_valid (p_d_gl_date    IN DATE,
				      p_n_invoice_id IN NUMBER,
                  		      p_n_credit_id  IN NUMBER) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Function to check validity of GL date for applications
		     This function returns TRUE if the GL Date passed is NOT Valid. Else FALSE

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/


 CURSOR cur_inv	(cp_n_invoice_id IN igs_fi_inv_int.invoice_id%TYPE) IS
 SELECT gl_date
 FROM   igs_fi_invln_int_all
 WHERE  gl_date IS NOT NULL
 AND    invoice_id = cp_n_invoice_id;


 CURSOR cur_credit (cp_n_credit_id IN igs_fi_credits.credit_id%TYPE) IS
 SELECT gl_date
 FROM   igs_fi_credits_all
 WHERE  gl_date IS NOT NULL
 AND    credit_id = cp_n_credit_id;

 l_d_chg_gl_date igs_fi_invln_int_all.gl_date%TYPE := NULL;
 l_d_crd_gl_date igs_fi_credits_all.gl_date%TYPE := NULL;

 BEGIN

 -- Sanity Validation of the input parameters to raise exception
 -- We know that this is a function invoked by applications form - hence the validation to raise exception only and not give proper error messages.
    IF (p_d_gl_date IS NULL) OR (p_n_invoice_id IS NULL) OR (p_n_credit_id IS NULL) THEN
      app_exception.raise_exception;
    END IF;
 -- Sanity Validation of the input parameters to raise exception

    OPEN cur_inv (p_n_invoice_id);
    FETCH cur_inv INTO l_d_chg_gl_date;
      IF cur_inv%NOTFOUND THEN
         CLOSE cur_inv;
         RETURN FALSE;
      END IF;
    CLOSE cur_inv;


    OPEN cur_credit (p_n_credit_id);
    FETCH cur_credit INTO l_d_crd_gl_date;
      IF cur_credit%NOTFOUND THEN
         CLOSE cur_credit;
         RETURN FALSE;
      END IF;
    CLOSE cur_credit;


--If the passed P_D_GL_DATE is earlier than CHG_GL_DATE or CRD_GL_DATE selected above then return TRUE else FALSE.
   IF (TRUNC(p_d_gl_date) <  TRUNC(l_d_chg_gl_date)) OR (TRUNC(p_d_gl_date) <  TRUNC(l_d_crd_gl_date))  THEN
      RETURN TRUE;
   END IF;

   -- Else return FALSE
   RETURN FALSE;


 END check_gl_dt_appl_not_valid;

 FUNCTION check_neg_chgadj_exists (p_n_invoice_id IN NUMBER) RETURN BOOLEAN AS

  /******************************************************************
  Created By        : SYKRISHN
  Date Created By   : 05/NOV-2002
  Purpose           : Function to check if negative charge adjustment exist for the charge id (invoice_id) passed
		      This function returns BOOLEAN. Returns TRUE if negative charge adjustment exists and FALSE otherwise.

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

-- Below 2 Cursors to check if negative charge adjustment exists in applications table for the invoice_id

 CURSOR cur_app_crd (cp_n_invoice_id IN igs_fi_inv_int.invoice_id%TYPE) IS
 SELECT credit_id
 FROM   igs_fi_applications
 WHERE  invoice_id = cp_n_invoice_id
 AND    application_type  = 'APP';


 CURSOR cur_neg	(cp_n_credit_id IN igs_fi_credits.credit_id%TYPE) IS
 SELECT 'Y'
 FROM igs_fi_credits_all crd,
      igs_fi_cr_types_all crtype
 WHERE crd.credit_id = cp_n_credit_id
 AND   crd.credit_type_id  = crtype.credit_type_id
 AND   crtype.credit_class = 'CHGADJ';

 l_v_neg_exist VARCHAR2(1);

 BEGIN
 -- Sanity Validation of the input parameters to raise exception
 -- We know that this is a function invoked internally - hence the validation to raise exception only and not give proper error messages.
    IF (p_n_invoice_id IS NULL) THEN
      app_exception.raise_exception;
    END IF;
 -- Sanity Validation of the input parameters to raise exception

 -- Loop across the applied credit ids to check if any of them is a neg chag adjustment.
  FOR app_crd_rec IN cur_app_crd (p_n_invoice_id) LOOP
        OPEN cur_neg (app_crd_rec.credit_id);
        FETCH cur_neg INTO l_v_neg_exist;
	 IF cur_neg%FOUND THEN
           CLOSE cur_neg;
           RETURN TRUE;
         END IF;
        CLOSE cur_neg;
  END LOOP;
  -- Return FALSE if no neg charge adj rows found.
  RETURN FALSE;

 END check_neg_chgadj_exists;

FUNCTION get_lkp_meaning (p_v_lookup_type IN igs_lookup_values.lookup_type%TYPE ,
                          p_v_lookup_code IN igs_lookup_values.lookup_code%TYPE ) RETURN VARCHAR2 IS
  /******************************************************************
  Created By        : sykrishn
  Date Created By   : 11-NOV-2002
  Purpose           : Function Returns the meaning for the given lookup code
                      Retuns NULL if not found.

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

 CURSOR cur_lkp_meaning( cp_v_lookup_type IN igs_lookup_values.lookup_type%TYPE ,
                         cp_v_lookup_code IN igs_lookup_values.lookup_code%TYPE )
 IS
 SELECT meaning
 FROM  igs_lookup_values
 WHERE lookup_code = cp_v_lookup_code
 AND   lookup_type = cp_v_lookup_type;

 l_v_meaning igs_lookup_values.meaning%TYPE;

 BEGIN
   IF p_v_lookup_code IS NULL THEN
     RETURN NULL;
   ELSE
      OPEN cur_lkp_meaning(p_v_lookup_type,p_v_lookup_code);
      FETCH cur_lkp_meaning INTO l_v_meaning;
           IF cur_lkp_meaning%NOTFOUND THEN
              CLOSE cur_lkp_meaning;
	      RETURN NULL;
	   END IF;
      CLOSE cur_lkp_meaning;
   END IF ;

   RETURN l_v_meaning;


END get_lkp_meaning;

FUNCTION get_formatted_amount ( p_n_amount IN NUMBER) RETURN NUMBER
AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 28 April 2006
--
-- Purpose:    : Public procedure for amount precision
-- Invoked     :
-- Function    : Public function to return the formatted
--               value of the input amount based on the currency
--               precision
-- Parameters  : p_n_amount   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_n_amount        NUMBER;

BEGIN
  l_n_amount := p_n_amount;

  -- if the global value have not been initialized
  IF g_old_reference.currency_code IS NULL THEN
    -- Get the default functional currency set up in the System Options form
    g_old_reference.currency_code := igs_fi_gen_gl.finp_ss_get_cur;
    -- If no default functional currency set up in the System Options form
    -- return the amount value without any precision formatting
    IF g_old_reference.currency_code IS NULL THEN
      RETURN l_n_amount;
    END IF;

    -- invoke the generic fnd_currency.get_info to get the precision information
    -- for the functional currency. This call out would be made once per session
    fnd_currency.get_info(
      currency_code  => g_old_reference.currency_code      ,
      precision      => g_old_reference.precision          ,
      ext_precision  => g_old_reference.extended_precision ,
      min_acct_unit  => g_old_reference.minimum_accountable_unit
    );
  END IF;

  -- if minimum_accountable_unit holds a value
  IF g_old_reference.minimum_accountable_unit IS NOT NULL
  THEN
    RETURN( ROUND(l_n_amount/g_old_reference.minimum_accountable_unit)* g_old_reference.minimum_accountable_unit);
  END IF;

  RETURN( ROUND( l_n_amount,g_old_reference.precision ));

END get_formatted_amount;


END igs_fi_gen_gl;

/
