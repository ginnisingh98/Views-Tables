--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_REFUNDS" AS
/* $Header: IGSFI68B.pls 120.1 2006/02/13 04:16:14 sapanigr noship $ */

/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Refunds General Package, Functions and Procedures used in the Refunds Build
 Change History
 Who             When       What
 sapanigr    13-Feb-2006 Bug# 5018036. Modified cur_fund_auth in check_fund_auth for R12 SQL repository perf tuning.
 shtatiko	 24-Sep-2002 Bug# 2564643, Removed Sub Account References
 agairola        30-Apr-2002 Modified the get_fee_prd for the bug 2348883
 (reverse chronological order - newest change first)
***************************************************************/

g_active      CONSTANT VARCHAR2(10) := 'ACTIVE';
g_refund      CONSTANT VARCHAR2(10) := 'REFUND';
g_stoprefund  CONSTANT VARCHAR2(15) := 'STOPREFUND';
g_borrower    CONSTANT VARCHAR2(10) := 'BORROWER';

FUNCTION check_fund_auth(p_person_id igs_fi_parties_v.person_id%TYPE) RETURN BOOLEAN AS

/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Identifies whether the Fund Autorization is set for the person
 Know limitations, enhancements or remarks
 Change History
 Who           When         What
 sapanigr   13-Feb-2006     Bug 5018036. Modified cur_fund_auth to query from igs_pe_hz_parties instead of igs_fi_parties_v
 (reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_fund_auth (cp_person_id igs_pe_hz_parties.party_id%TYPE) IS
  SELECT NVL(fund_authorization,'N') fund_authorization
  FROM   igs_pe_hz_parties
  WHERE  party_id = cp_person_id;
  l_fund_auth igs_fi_parties_v.fund_authorization%TYPE;
BEGIN
  -- For the person in context get the fund authorization is enabled or not
  -- if no record is found then the function returns FALSE else returns TRUE
  OPEN cur_fund_auth(p_person_id);
  FETCH cur_fund_auth INTO l_fund_auth;
  IF cur_fund_auth%NOTFOUND THEN
    RETURN FALSE;
  ELSE
    IF l_fund_auth = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;
END check_fund_auth;


PROCEDURE get_fee_prd( p_fee_type               OUT NOCOPY       igs_fi_fee_type.fee_type%TYPE,
                       p_fee_cal_type           IN OUT NOCOPY    igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       p_fee_ci_sequence_number IN OUT NOCOPY    igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                       p_status                 OUT NOCOPY       BOOLEAN) AS
/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Gets the Fee Type for the given Sub Account and Fee Period
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
shtatiko	 24-Sep-2002 Bug# 3564643, Removed Subaccount_id from the parameter list and modified the code accordingly.
agairola         30-Apr-2002 Added the Fee Structure Status check in cur_fee_type and cur_ftyp_no_ftci for 2348883
 (reverse chronological order - newest change first)
***************************************************************/


  CURSOR cur_fee_type ( cp_fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE)
  IS
  SELECT ft.fee_type
  FROM   igs_fi_f_typ_ca_inst ftci,
         igs_fi_fee_type ft,
         igs_fi_fee_str_stat fsst
  WHERE  ft.fee_type = ftci.fee_type
  AND    ftci.fee_cal_type = p_fee_cal_type
  AND    ftci.fee_ci_sequence_number = p_fee_ci_sequence_number
  AND    ftci.fee_type_ci_status = fsst.fee_structure_status
  AND    fsst.s_fee_structure_status = g_active
  AND    ft.s_fee_type = g_refund
  AND    NVL(ft.closed_ind,'N') = 'N';

  l_cur_fee_type igs_fi_fee_type.fee_type%TYPE;

  CURSOR cur_ftyp_no_ftci
  IS
  SELECT ftci.fee_type,
         ci.cal_type,
         ci.sequence_number
  FROM   igs_fi_fee_type ft,
         igs_fi_f_typ_ca_inst ftci,
         igs_ca_inst ci,
         igs_fi_fee_str_stat fsst
  WHERE  ft.fee_type = ftci.fee_type
  AND    ft.s_fee_type = g_refund
  AND    ci.cal_type = ftci.fee_cal_type
  AND    ci.sequence_number = ftci.fee_ci_sequence_number
  AND    ftci.fee_type_ci_status = fsst.fee_structure_status
  AND    fsst.s_fee_structure_status = g_active
  AND    (TRUNC(SYSDATE) BETWEEN TRUNC(ci.start_dt) AND TRUNC(NVL(ci.end_dt,SYSDATE)))
  AND    NVL(ft.closed_ind,'N') = 'N'
  ORDER BY ci.start_dt, ci.sequence_number ASC;
  l_cur_ftyp_no_ftci cur_ftyp_no_ftci%ROWTYPE;

BEGIN
  -- If the Fee Period is passed then for Fee Period Fee Type is identified
  IF ( p_fee_cal_type IS NOT NULL AND p_fee_ci_sequence_number IS NOT NULL) THEN
    OPEN cur_fee_type( p_fee_cal_type, p_fee_ci_sequence_number);
    FETCH cur_fee_type INTO l_cur_fee_type;
    IF cur_fee_type%NOTFOUND THEN
      p_status := FALSE;
      p_fee_type := NULL;
      CLOSE cur_fee_type;
      RETURN;
    END IF;
    p_status :=TRUE;
    p_fee_type := l_cur_fee_type;
    CLOSE cur_fee_type;
  ELSE
  -- If the Fee Period is not passed then for the latest Fee Calendar Instance, Fee Type is identified
    OPEN cur_ftyp_no_ftci;
    FETCH cur_ftyp_no_ftci INTO l_cur_ftyp_no_ftci;
    IF cur_ftyp_no_ftci%NOTFOUND THEN
      p_status := FALSE;
      p_fee_type := NULL;
      p_fee_cal_type := NULL;
      p_fee_ci_sequence_number := NULL;
      CLOSE cur_ftyp_no_ftci;
      RETURN;
    END IF;
    p_status :=TRUE;
    p_fee_type := l_cur_ftyp_no_ftci.fee_type;
    p_fee_cal_type := l_cur_ftyp_no_ftci.cal_type;
    p_fee_ci_sequence_number := l_cur_ftyp_no_ftci.sequence_number;
    CLOSE cur_ftyp_no_ftci;
  END IF;
END get_fee_prd;

FUNCTION get_rfnd_hold (p_person_id igs_pe_person.person_id%TYPE) RETURN BOOLEAN IS
/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Function to determine whether a person is having active STOPREFUND hold effects hold
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 (reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_hold_check (cp_person_id igs_pe_person.person_id%TYPE)
  IS
  SELECT 'X'
  FROM   igs_pe_persenc_effct
  WHERE  person_id = cp_person_id
  AND    s_encmb_effect_type = g_stoprefund
  AND    TRUNC(NVL(expiry_dt,SYSDATE)) >= TRUNC(SYSDATE);

  l_temp VARCHAR2(1);
BEGIN
  -- Returns FALSE when the Person Id is not input
  IF ( p_person_id IS NULL) THEN
    RETURN FALSE;
  END IF;

  -- Returns FALSE when there is no hold effect of STOPREFUND else returns TRUE
  OPEN cur_hold_check(p_person_id);
  FETCH cur_hold_check INTO l_temp;
  IF cur_hold_check%NOTFOUND THEN
    CLOSE cur_hold_check;
    RETURN FALSE;
  ELSE
    CLOSE cur_hold_check;
    RETURN TRUE;
  END IF;
END get_rfnd_hold;

FUNCTION val_add_drop (p_fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       p_fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) RETURN BOOLEAN AS
/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Function to determine the Refund Date Alias is less than the Sysdate
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 (reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_control
  IS
  SELECT refund_dt_alias
  FROM   igs_fi_control;
  l_refund_dt_alias igs_ca_da_inst.dt_alias%TYPE;

  CURSOR cur_alias_val (cp_fee_cal_type            igs_ca_inst.cal_type%TYPE,
                        cp_fee_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                        cp_date_alias              igs_ca_da_inst.dt_alias%TYPE)
  IS
  SELECT alias_val
  FROM   igs_ca_da_inst_v
  WHERE  cal_type = cp_fee_cal_type
  AND    ci_sequence_number = cp_fee_ci_sequence_number
  AND    dt_alias = cp_date_alias
  ORDER BY alias_val DESC;
  l_refund_dt_val igs_ca_da_inst_v.alias_val%TYPE;

BEGIN
  -- If the mandatory parameters are not passed then the function returnd FALSE
  IF (p_fee_cal_type IS NULL OR p_fee_ci_sequence_number IS NULL) THEN
    RETURN FALSE;
  END IF;

  -- Identify the refund date alias value in the System Setup form
  -- when no data is setup then the function returns FALSE
  OPEN cur_control;
  FETCH cur_control INTO l_refund_dt_alias;
  IF cur_control%NOTFOUND THEN
    CLOSE cur_control;
    RETURN FALSE;
  END IF;
  CLOSE cur_control;

  -- If the Identified refund date alias value in the System Setup form
  -- is null then the function returns FALSE
  IF (l_refund_dt_alias IS NULL) THEN
    RETURN FALSE;
  END IF;

  -- Get the Alias Value from the igs_ca_da_inst_v view, returns FALSE when no data found
  OPEN cur_alias_val(p_fee_cal_type, p_fee_ci_sequence_number, l_refund_dt_alias);
  FETCH cur_alias_val INTO l_refund_dt_val;
  IF cur_alias_val%NOTFOUND THEN
    CLOSE cur_alias_val;
    RETURN FALSE;
  END IF;
  CLOSE cur_alias_val;

  -- If the Alias Value is Less Than the current Date then the function will return FALSE
  -- else TRUE is returned
  IF (l_refund_dt_val <  SYSDATE) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END val_add_drop;

PROCEDURE get_borw_det (p_credit_id          igs_fi_credits.credit_id%TYPE,
                        p_determination  OUT NOCOPY igs_lookups_view.lookup_code%TYPE,
                        p_err_message    OUT NOCOPY fnd_new_messages.message_name%TYPE,
                        p_status         OUT NOCOPY BOOLEAN) AS
/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Procedure will determine the Borrower for the input Credit Id
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 (reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_award( cp_credit_id igs_fi_credits.credit_id%TYPE)
  IS
  SELECT award_id
  FROM   igf_db_awd_disb_dtl
  WHERE  sf_credit_id = cp_credit_id;
  l_cur_award cur_award%ROWTYPE;

  CURSOR cur_borrower (cp_award_id igf_aw_award.award_id%TYPE)
  IS
  SELECT NVL(borw_detrm_code,g_borrower) borw_detrm_code
  FROM   igf_sl_loans
  WHERE  award_id = cp_award_id;
  l_cur_borrower cur_borrower%ROWTYPE;

BEGIN
  -- If the mandatory parameter credit id is not passed then return setting
  -- NULL to the OUT NOCOPY variables
  IF (p_credit_id IS NULL ) THEN
    p_determination := NULL;
    p_err_message := NULL;
    p_status := FALSE;
    RETURN;
  END IF;

  -- For the input credit id, get the award id from the Disbursment Details Table, return message if no
  -- data is found
  OPEN cur_award( p_credit_id);
  FETCH cur_award INTO l_cur_award;
  IF cur_award%NOTFOUND THEN
    p_determination := NULL;
    p_err_message := 'IGS_FI_RFND_INVDATA';
    p_status := FALSE;
    CLOSE cur_award;
    RETURN;
  END IF;
  CLOSE cur_award;

  -- for the award id get the borrower from the loans table
  -- when the column value is NULL the default BORROWER is
  -- returned as the Borrower code
  OPEN cur_borrower( l_cur_award.award_id);
  FETCH cur_borrower INTO l_cur_borrower;
  IF cur_borrower%NOTFOUND THEN
    p_determination := NULL;
    p_err_message := NULL;
    p_status := FALSE;
    CLOSE cur_borrower;
    RETURN;
  END IF;
  p_determination := l_cur_borrower.borw_detrm_code;
  p_err_message := NULL;
  p_status := TRUE;
  CLOSE cur_borrower;

END get_borw_det;

PROCEDURE get_refund_acc ( p_dr_gl_ccid     OUT NOCOPY igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE,
                           p_dr_account_cd  OUT NOCOPY igs_fi_f_typ_ca_inst.rec_account_cd%TYPE,
                           p_cr_gl_ccid     OUT NOCOPY igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE,
                           p_cr_account_cd  OUT NOCOPY igs_fi_f_typ_ca_inst.rec_account_cd%TYPE,
                           p_err_message    OUT NOCOPY fnd_new_messages.message_name%TYPE,
                           p_status         OUT NOCOPY BOOLEAN) AS
/*************************************************************
 Created By : vchappid
 Date Created By : 01-Mar-2002
 Purpose : Get the Refunds Account Codes setup at the System Options Form
           depending whether AR is installed or not
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 (reverse chronological order - newest change first)
***************************************************************/


  CURSOR cur_refund
  IS
  SELECT refund_dr_gl_ccid,
         refund_cr_gl_ccid,
         refund_dr_account_cd,
         refund_cr_account_cd,
         NVL(rec_installed,'N') rec_installed
  FROM   igs_fi_control;

  l_cur_refund cur_refund%ROWTYPE;

BEGIN

  -- If there is no record in the igs_fi_control table then the procedure will return
  -- an error and assigns NULL to the OUT NOCOPY parameters
  OPEN cur_refund;
  FETCH cur_refund INTO l_cur_refund;
  IF cur_refund%NOTFOUND THEN
      p_dr_gl_ccid := NULL;
      p_dr_account_cd := NULL;
      p_cr_gl_ccid := NULL;
      p_cr_account_cd := NULL;
      p_err_message := 'IGS_FI_REFUND_ACC_ERR';
      p_status:= FALSE;
      RETURN;
  END IF;
  CLOSE cur_refund;

  -- If AR is installed then the CCID columns will be assigned to the Out NOCOPY Parameters
  -- else Account codes are assigned to the OUT NOCOPY parameters
  IF (l_cur_refund.rec_installed ='Y') THEN
    IF (l_cur_refund.refund_dr_gl_ccid IS NULL OR l_cur_refund.refund_cr_gl_ccid IS NULL) THEN
      p_dr_gl_ccid := NULL;
      p_dr_account_cd := NULL;
      p_cr_gl_ccid := NULL;
      p_cr_account_cd := NULL;
      p_err_message := 'IGS_FI_REFUND_ACC_ERR';
      p_status:= FALSE;
      RETURN;
    ELSE
      p_dr_gl_ccid := l_cur_refund.refund_dr_gl_ccid;
      p_dr_account_cd := NULL;
      p_cr_gl_ccid := l_cur_refund.refund_cr_gl_ccid;
      p_cr_account_cd := NULL;
      p_err_message := NULL;
      p_status:= TRUE;
      RETURN;
    END IF;
  ELSE
    IF (l_cur_refund.refund_dr_account_cd IS NULL OR l_cur_refund.refund_cr_account_cd IS NULL) THEN
      p_dr_gl_ccid := NULL;
      p_dr_account_cd := NULL;
      p_cr_gl_ccid := NULL;
      p_cr_account_cd := NULL;
      p_err_message := 'IGS_FI_REFUND_ACC_ERR';
      p_status:= FALSE;
      RETURN;
    ELSE
      p_dr_gl_ccid := NULL;
      p_dr_account_cd := l_cur_refund.refund_dr_account_cd;
      p_cr_gl_ccid := NULL;
      p_cr_account_cd := l_cur_refund.refund_cr_account_cd;
      p_err_message := NULL;
      p_status:= TRUE;
      RETURN;
    END IF;
  END IF;
END get_refund_acc;
END igs_fi_gen_refunds;

/
