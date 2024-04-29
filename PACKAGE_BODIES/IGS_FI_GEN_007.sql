--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_007" AS
/* $Header: IGSFI62B.pls 120.5 2006/06/27 14:13:57 skharida ship $ */

  CURSOR cur_credit(cp_credit_id igs_fi_credits.credit_id%TYPE) IS
  SELECT *
  FROM   igs_fi_credits
  WHERE  credit_id = cp_credit_id
  AND    status = 'CLEARED'
  AND    unapplied_amount >0;

  CURSOR cur_invoice(cp_invoice_id  igs_fi_inv_int.invoice_id%TYPE)  IS
  SELECT inv.*
  FROM   igs_fi_inv_int inv
  WHERE  inv.invoice_id = cp_invoice_id
  AND    inv.invoice_amount_due >0;

  CURSOR cur_credit_unapp(cp_credit_id igs_fi_credits.credit_id%TYPE) IS
  SELECT *
  FROM   igs_fi_credits
  WHERE  credit_id = cp_credit_id
  AND    status = 'CLEARED'
  AND    unapplied_amount >=0;

  CURSOR cur_invoice_unapp(cp_invoice_id  igs_fi_inv_int.invoice_id%TYPE)  IS
  SELECT inv.*
  FROM   igs_fi_inv_int inv
  WHERE  inv.invoice_id = cp_invoice_id
  AND    inv.invoice_amount_due >=0;

  g_chg_adj  CONSTANT  VARCHAR2(10) :='CHGADJ';
  g_app      CONSTANT  VARCHAR2(10) :='APP';
  g_unapp    CONSTANT  VARCHAR2(10) :='UNAPP';
  g_yes      CONSTANT  VARCHAR2(1)  :='Y';


FUNCTION get_sob_id RETURN NUMBER IS

/*
  ||  Created By : Sridhar Koppula
  ||  Created On : 26-JUL-2001
  ||  Purpose : To return Set of Books ID
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  l_sob       igs_fi_control.set_of_books_id%TYPE;

  CURSOR cur_sob IS SELECT set_of_books_id FROM igs_fi_control;

BEGIN
    OPEN cur_sob;
    FETCH cur_sob INTO l_sob;
    CLOSE cur_sob;
    RETURN l_sob;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END get_sob_id;


FUNCTION get_coa_id RETURN NUMBER IS

/*
  ||  Created By : Sridhar Koppula
  ||  Created On : 26-JUL-2001
  ||  Purpose : To return Chart of Accounts ID
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  l_coa       gl_sets_of_books.chart_of_accounts_id%TYPE;

  CURSOR cur_coa IS SELECT chart_of_accounts_id FROM gl_sets_of_books
                    WHERE set_of_books_id = get_sob_id;

BEGIN
    OPEN cur_coa;
    FETCH cur_coa INTO l_coa;
    CLOSE cur_coa;
    RETURN l_coa;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END get_coa_id;


FUNCTION get_gl_shortname RETURN VARCHAR2 IS

/*
  ||  Created By : Sridhar Koppula
  ||  Created On : 26-JUL-2001
  ||  Purpose : To return Gl short name
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  l_sname       gl_sets_of_books.short_name%TYPE;

  CURSOR cur_sname IS SELECT short_name FROM gl_sets_of_books
                    WHERE set_of_books_id = get_sob_id;

BEGIN
    OPEN cur_sname;
    FETCH cur_sname INTO l_sname;
    CLOSE cur_sname;
    RETURN l_sname;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END get_gl_shortname;

FUNCTION get_segval_desc(p_value_set_id NUMBER,p_value VARCHAR2) RETURN VARCHAR2 IS
/*
  ||  Created By : Sridhar Koppula
  ||  Created On : 26-JUL-2001
  ||  Purpose : To return Gl short name
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   l_segdesc   VARCHAR2(240);

  CURSOR cur_vdesc IS SELECT description FROM fnd_flex_values_vl
                    WHERE flex_value_Set_id = p_value_set_id AND
                    flex_value=p_value;
BEGIN
     OPEN cur_vdesc;
     FETCH cur_vdesc INTO l_segdesc;
     CLOSE cur_vdesc;
     RETURN l_segdesc;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END get_segval_desc;


PROCEDURE validate_parameters(p_credit_id         IN  igs_fi_credits.credit_id%TYPE,
                              p_invoice_id        IN  igs_fi_inv_int.invoice_id%TYPE,
                              p_amount_apply      IN  igs_fi_applications.amount_applied%TYPE,
                              p_appl_type         IN  igs_fi_applications.application_type%TYPE,
                              p_application_id    IN  igs_fi_applications.application_id%TYPE,
                              p_appl_hierarchy_id IN  igs_fi_applications.appl_hierarchy_id%TYPE,
                              p_err_msg           OUT NOCOPY fnd_new_messages.message_name%TYPE,
                              p_status            OUT NOCOPY BOOLEAN,
                              p_d_gl_date         IN  DATE
                              ) AS

/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For validating parameters.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smadathi      20-NOV-2002   Enh. Bug 2584986. Added new parameter GL Date
  ||                             to procedure.
  ||  vvutukur     27-Sep-2002   Enh#2564643.Modified the message name IGS_AD_INVALID_PARAM_COMB to
  ||                             the new message IGS_FI_INVAMT_ZERO.This change is wrt bug#2463855,
  ||                             which is being released as part of Enh#2564643.
  ||  vvutukur     22-Jul-2002   Thrown two separate messages while validating p_amount_apply, as
  ||                             part of bugfix#2463855,instead of throwing IGS_AD_INVALID_PARAM_COMB.
*/

  CURSOR cur_appl_hier IS
  SELECT 'X'
  FROM   igs_fi_a_hierarchies
  WHERE  appl_hierarchy_id = p_appl_hierarchy_id;


  CURSOR cur_chk_crd_inv(cp_credit_id  igs_fi_credits.credit_id%TYPE,
                         cp_invoice_id igs_fi_inv_int.invoice_id%TYPE) IS
  SELECT 'X'
  FROM   igs_fi_applications
  WHERE  application_id=p_application_id
  AND    credit_id=cp_credit_id
  AND    invoice_id=cp_invoice_id;

  CURSOR cur_app_rec IS
  SELECT 'X'
  FROM    igs_fi_applications a1,
          igs_fi_applications a2
  WHERE   a1.application_id=p_application_id
  AND     a1.application_id=a2.link_application_id
  AND     a1.amount_applied= - a2.amount_applied;

  CURSOR cur_chk_app IS
  SELECT credit_id,invoice_id
  FROM   igs_fi_applications
  WHERE  application_id=p_application_id
  AND    application_type='APP';

  CURSOR c_igs_fi_cr_types(cp_n_credit_id igs_fi_credits.credit_id%TYPE) IS
  SELECT credit_class
  FROM   igs_fi_cr_types crtyp
  WHERE  EXISTS (SELECT '1'
                 FROM   igs_fi_credits crd
                 WHERE  crd.credit_type_id = crtyp.credit_type_id
                 AND    crd.credit_id      = cp_n_credit_id
                );

  rec_c_igs_fi_cr_types c_igs_fi_cr_types%ROWTYPE;

  l_cur_chk_app       cur_chk_app%ROWTYPE;
  l_check             VARCHAR2(1);
  l_cur_credit        cur_credit%ROWTYPE;
  l_cur_invoice       cur_invoice%ROWTYPE;
  l_cur_credit_unapp  cur_credit_unapp%ROWTYPE;
  l_cur_invoice_unapp cur_invoice_unapp%ROWTYPE;
  l_status            BOOLEAN := FALSE;

BEGIN
  p_status:=TRUE;
  p_err_msg:=NULL;

  --Check all the mandatory parameter are supplied or not
  IF p_appl_type IS NULL THEN
    p_status:=FALSE;
    p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
  ELSIF p_appl_type NOT IN (g_app,g_unapp) THEN
    --Checking application Type in APP/UNAPP
    p_status:=FALSE;
    p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
  ELSIF (((p_credit_id IS NULL) OR (p_invoice_id IS NULL)) AND (p_appl_type = g_app)) THEN
    p_status:=FALSE;
    p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
  ELSIF ((p_appl_type=g_app) AND (p_application_id IS NOT NULL)) THEN
    --Validating the application Id
    p_status:=FALSE;
    p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
  ELSIF ((p_appl_type=g_unapp) AND (p_application_id IS NULL)) THEN
    p_status:=FALSE;
    p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
  END IF;
  IF  p_d_gl_date IS NULL THEN
    p_status  := FALSE;
    p_err_msg := 'IGS_GE_INSUFFICIENT_PARAMETER';
  END IF;

 -- Return Back to the calling porcedure/finction if validate_parameters procedure is invoked
 -- if either of the mnadatory parameters are not supplied or incorrect values are specified
 -- for the parameters.
  IF NOT (p_status) THEN
    RETURN;
  END IF;

  OPEN   c_igs_fi_cr_types(p_credit_id);
  FETCH  c_igs_fi_cr_types INTO rec_c_igs_fi_cr_types;
  CLOSE  c_igs_fi_cr_types;
  IF rec_c_igs_fi_cr_types.credit_class <> 'ONLINE PAYMENT' THEN
    l_status := igs_fi_gen_gl.check_gl_dt_appl_not_valid ( p_d_gl_date     =>  p_d_gl_date,
                                                           p_n_invoice_id  =>  p_invoice_id,
                                                           p_n_credit_id   =>  p_credit_id
                                                         );
    -- IF the passed GL Date value is before the GL Date of the charge or credit being applied to,
    -- validate_parameters procedure returns the warning message IGS_FI_CHG_CRD_GL_DATE
    -- and status as true to p_status out NOCOPY parameter and message to out NOCOPY p_err_msg
    IF (l_status ) THEN
      p_status  := TRUE;
      p_err_msg := 'IGS_FI_CHG_CRD_GL_DATE';
      RETURN;
    END IF;
  END IF;


  --validating application hierarchy Id
  IF ((p_status = TRUE) AND ((p_appl_type = g_app) AND (p_appl_hierarchy_id IS NOT NULL))) THEN
    OPEN cur_appl_hier;
    FETCH cur_appl_hier INTO l_check;
    IF cur_appl_hier%NOTFOUND THEN
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    END IF;
    CLOSE cur_appl_hier;
  END IF;

  --Validating Credit Id and invoice Id for application type of APP
  IF ((p_status = TRUE) AND (p_appl_type = g_app))THEN
    OPEN cur_credit(p_credit_id);
    FETCH cur_credit INTO l_cur_credit;
    IF cur_credit%NOTFOUND THEN
      CLOSE cur_credit;
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    ELSE
      CLOSE cur_credit;
      OPEN cur_invoice(p_invoice_id);
      FETCH cur_invoice INTO l_cur_invoice;
      IF cur_invoice%NOTFOUND THEN
        p_status:=FALSE;
        p_err_msg:='IGS_FI_INVAMT_ZERO';
      END IF;
      CLOSE cur_invoice;
    END IF;
  END IF;

  --Validating amount applied
  IF ((p_status = TRUE) AND ( p_amount_apply IS NOT NULL)) THEN
    IF p_amount_apply < 0 THEN
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    --Validating if amount applied parameter is greater than unapplied amount of the credit id
    --when application type is APP
    ELSIF (( p_appl_type = g_app ) AND (p_amount_apply > l_cur_credit.unapplied_amount)) THEN
      p_status  := FALSE;
      p_err_msg := 'IGS_FI_HIGH_APPL_AMT';
    --Validating if amount applied parameter is greater than invoice_amount_due
    --when application type is APP
    ELSIF ((p_appl_type = g_app) AND (p_amount_apply > l_cur_invoice.invoice_amount_due)) THEN
      p_status:=FALSE;
      p_err_msg:='IGS_FI_AMT_MOR_BUD';
    END IF;
  END IF;


  --To validate if the application Id passed is a valid one
  IF ((p_status) AND (p_appl_type=g_unapp)) THEN
    OPEN cur_app_rec;
    FETCH cur_app_rec INTO l_check;
    IF cur_app_rec%FOUND THEN
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    ELSE
      OPEN cur_chk_app;
      FETCH cur_chk_app INTO l_cur_chk_app;
      IF cur_chk_app%NOTFOUND THEN
        p_status:=FALSE;
        p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
      END IF;
      CLOSE cur_chk_app;
    END IF;
    CLOSE cur_app_rec;
  END IF;

  --Validating credit Id, invoice Id(if passed) for the given application Id for UNAPP processing
  IF ( p_status = TRUE) THEN
    IF ((p_appl_type=g_unapp) AND ((p_credit_id IS NOT NULL) OR (p_invoice_id IS NOT NULL))) THEN
      OPEN cur_chk_crd_inv(NVL(p_credit_id,l_cur_chk_app.credit_id),NVL(p_invoice_id,l_cur_chk_app.invoice_id));
      FETCH cur_chk_crd_inv INTO l_check;
      IF cur_chk_crd_inv%NOTFOUND THEN
        p_status:=FALSE;
        p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
      END IF;
      CLOSE cur_chk_crd_inv;
    END IF;
  END IF;

  --Validating Credit Record for Unapplication
  IF ((p_status = TRUE) AND (p_appl_type = g_unapp))THEN
    OPEN cur_credit_unapp(l_cur_chk_app.credit_id);
    FETCH cur_credit_unapp INTO l_cur_credit_unapp;
    IF cur_credit_unapp%NOTFOUND THEN
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    END IF;
    CLOSE cur_credit_unapp;
  END IF;

  --Validating Charges Record for Unapplication
  IF ((p_status = TRUE) AND (p_appl_type = g_unapp))THEN
    OPEN cur_invoice_unapp(l_cur_chk_app.invoice_id);
    FETCH cur_invoice_unapp INTO l_cur_invoice_unapp;
    IF cur_invoice_unapp%NOTFOUND THEN
      p_status:=FALSE;
      p_err_msg:='IGS_AD_INVALID_PARAM_COMB';
    END IF;
    CLOSE cur_invoice_unapp;
  END IF;


END validate_parameters;

PROCEDURE call_update_charges(p_invoice_amount_due IN  igs_fi_inv_int_all.invoice_amount_due%TYPE,
                              p_cur_invoice        IN  cur_invoice%ROWTYPE,
                              p_v_opt_fee_flag     IN  igs_fi_inv_int_all.optional_fee_flag%TYPE,
                              p_flag               OUT NOCOPY BOOLEAN  ) AS
/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For updating charges record once a application/unapplication has happened.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  skharida     26-Jun-2006   Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_INV_INT_ALL
  ||  gurprsin     16-Aug-2005   Enh 3392095 - Tution Waiver build - Added new column waiver_name in the TBH call igs_fi_inv_int_pkg.update_row
  ||  pmarada    26-May-2005 Enh#3020586- added tax year code column as per 1098-t reporting build
  ||  pathipat     07-Jun-2003   Enh 2831584 - SS Enhancements build
  ||                             Added parameter p_v_opt_fee_flag
  || smadathi      20-NOV-2002   Enh. Bug 2584986. Modified igs_fi_inv_int_pkg.update_row
  ||                             to add new parameter reversal GL Date
  || jbegum         20 feb 02       Enh bug # 2228910
  ||                                Removed the source_transaction_id column from igs_fi_inv_int_pkg.update_row
  ||  (reverse chronological order - newest change first) */

l_v_opt_fee_flag      igs_fi_inv_int_all.optional_fee_flag%TYPE := NULL;

BEGIN

  p_flag := TRUE;

  IF (p_v_opt_fee_flag IS NULL) THEN
     l_v_opt_fee_flag := p_cur_invoice.optional_fee_flag;
  ELSE
     l_v_opt_fee_flag := p_v_opt_fee_flag;
  END IF;

  BEGIN
    igs_fi_inv_int_pkg.update_row(x_rowid                       => p_cur_invoice.row_id,
                                  x_invoice_id                  => p_cur_invoice.invoice_id,
                                  x_person_id                   => p_cur_invoice.person_id,
                                  x_fee_type                    => p_cur_invoice.fee_type,
                                  x_fee_cat                     => p_cur_invoice.fee_cat,
                                  x_fee_cal_type                => p_cur_invoice.fee_cal_type,
                                  x_fee_ci_sequence_number      => p_cur_invoice.fee_ci_sequence_number,
                                  x_course_cd                   => p_cur_invoice.course_cd,
                                  x_attendance_mode             => p_cur_invoice.attendance_mode,
                                  x_attendance_type             => p_cur_invoice.attendance_type,
                                  x_invoice_amount_due          => p_invoice_amount_due,
                                  x_invoice_creation_date       => p_cur_invoice.invoice_creation_date,
                                  x_invoice_desc                => p_cur_invoice.invoice_desc,
                                  x_transaction_type            => p_cur_invoice.transaction_type,
                                  x_currency_cd                 => p_cur_invoice.currency_cd,
                                  x_status                      => p_cur_invoice.status,
                                  x_attribute_category          => p_cur_invoice.attribute_category,
                                  x_attribute1                  => p_cur_invoice.attribute1,
                                  x_attribute2                  => p_cur_invoice.attribute2,
                                  x_attribute3                  => p_cur_invoice.attribute3,
                                  x_attribute4                  => p_cur_invoice.attribute4,
                                  x_attribute5                  => p_cur_invoice.attribute5,
                                  x_attribute6                  => p_cur_invoice.attribute6,
                                  x_attribute7                  => p_cur_invoice.attribute7,
                                  x_attribute8                  => p_cur_invoice.attribute8,
                                  x_attribute9                  => p_cur_invoice.attribute9,
                                  x_attribute10                 => p_cur_invoice.attribute10,
                                  x_invoice_amount              => p_cur_invoice.invoice_amount,
                                  x_bill_id                     => p_cur_invoice.bill_id,
                                  x_bill_number                 => p_cur_invoice.bill_number,
                                  x_bill_date                   => p_cur_invoice.bill_date,
                                  x_waiver_flag                 => p_cur_invoice.waiver_flag,
                                  x_waiver_reason               => p_cur_invoice.waiver_reason,
                                  x_effective_date              => p_cur_invoice.effective_date,
                                  x_invoice_number              => p_cur_invoice.invoice_number,
                                  x_exchange_rate               => p_cur_invoice.exchange_rate,
                                  x_bill_payment_due_date       => p_cur_invoice.bill_payment_due_date,
                                  x_optional_fee_flag           => l_v_opt_fee_flag,
                                  x_mode                        => 'R',
                                  x_reversal_gl_date            => p_cur_invoice.reversal_gl_date,
                                  x_tax_year_code               => p_cur_invoice.tax_year_code,
                                  x_waiver_name                 => p_cur_invoice.waiver_name
                               );
  EXCEPTION
    WHEN OTHERS THEN
      p_flag :=FALSE;
  END;

END call_update_charges;

PROCEDURE call_update_credits(p_unapplied_amount  IN  igs_fi_credits_all.unapplied_amount%TYPE,
                              p_cur_credit        IN  cur_credit%ROWTYPE,
                              p_flag              OUT NOCOPY BOOLEAN)
AS
/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For updating a credit record once a application/unappliaction has happened.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     16-Aug-2005   Enh 3392095 - Tution Waiver build - Added new column waiver_name in the TBH call igs_fi_credits_pkg.update_row
  ||  pathipat     21-Apr-2004   Enh 3558549 - Commercial Receivables Enhancements
  ||                             Added parameter x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  || vvutukur      16-Jun-2003   Enh#2831582.Lockbox Build. Added 3 new parameters(lockbox_interface_id,batch_name,deposit_date) to the update_row
  ||                             call of credits table.
  || schodava      16-Jun-2003   Enh # 2831587 - Credit Card Fund Transfer Build - Modified call to update row.
  || pathipat      16-Dec-2002   Enh bug 2584741 - Deposits build - Modified call to update_row
  ||                             Added columns check_number, source_transaction_type and source_transaction_ref
  || smadathi      20-NOV-2002   Enh. Bug 2584986. Modified igs_fi_credits_pkg.update_row
  ||                             to add new parameter GL Date
  || sykrishn        14feb2002        SFCR020 build 2191470- Added 4 new params to update_row call for credits
  ||  (reverse chronological order - newest change first) */

BEGIN
  p_flag:=TRUE;
  BEGIN
    igs_fi_credits_pkg.update_row( X_ROWID                        => p_cur_credit.row_id,
                                   X_CREDIT_ID                    => p_cur_credit.credit_id,
                                   X_CREDIT_NUMBER                => p_cur_credit.credit_number,
                                   X_STATUS                       => p_cur_credit.status,
                                   X_CREDIT_SOURCE                => p_cur_credit.credit_source,
                                   X_PARTY_ID                     => p_cur_credit.party_id,
                                   X_CREDIT_TYPE_ID               => p_cur_credit.credit_type_id,
                                   X_CREDIT_INSTRUMENT            => p_cur_credit.credit_instrument,
                                   X_DESCRIPTION                  => p_cur_credit.description,
                                   X_AMOUNT                       => p_cur_credit.amount,
                                   X_CURRENCY_CD                  => p_cur_credit.currency_cd,
                                   X_EXCHANGE_RATE                => p_cur_credit.exchange_rate,
                                   X_TRANSACTION_DATE             => p_cur_credit.transaction_date,
                                   X_EFFECTIVE_DATE               => p_cur_credit.effective_date,
                                   X_REVERSAL_DATE                => p_cur_credit.reversal_date,
                                   X_REVERSAL_REASON_CODE         => p_cur_credit.reversal_reason_code,
                                   X_REVERSAL_COMMENTS            => p_cur_credit.reversal_comments,
                                   X_UNAPPLIED_AMOUNT             => p_unapplied_amount,
                                   X_SOURCE_TRANSACTION_ID        => p_cur_credit.source_transaction_id,
                                   X_RECEIPT_LOCKBOX_NUMBER       => p_cur_credit.receipt_lockbox_number,
                                   X_MERCHANT_ID                  => p_cur_credit.merchant_id,
                                   X_CREDIT_CARD_CODE             => p_cur_credit.credit_card_code,
                                   X_CREDIT_CARD_HOLDER_NAME      => p_cur_credit.credit_card_holder_name,
                                   X_CREDIT_CARD_NUMBER           => p_cur_credit.credit_card_number,
                                   X_CREDIT_CARD_EXPIRATION_DATE  => p_cur_credit.credit_card_expiration_date,
                                   X_CREDIT_CARD_APPROVAL_CODE    => p_cur_credit.credit_card_approval_code,
                                   X_AWD_YR_CAL_TYPE              => p_cur_credit.awd_yr_cal_type,
                                   X_AWD_YR_CI_SEQUENCE_NUMBER    => p_cur_credit.awd_yr_ci_sequence_number,
                                   X_FEE_CAL_TYPE                 => p_cur_credit.fee_cal_type ,
                                   X_FEE_CI_SEQUENCE_NUMBER       => p_cur_credit.fee_ci_sequence_number,
                                   X_ATTRIBUTE_CATEGORY           => p_cur_credit.attribute_category,
                                   X_ATTRIBUTE1                   => p_cur_credit.attribute1,
                                   X_ATTRIBUTE2                   => p_cur_credit.attribute2,
                                   X_ATTRIBUTE3                   => p_cur_credit.attribute3,
                                   X_ATTRIBUTE4                   => p_cur_credit.attribute4,
                                   X_ATTRIBUTE5                   => p_cur_credit.attribute5,
                                   X_ATTRIBUTE6                   => p_cur_credit.attribute6,
                                   X_ATTRIBUTE7                   => p_cur_credit.attribute7,
                                   X_ATTRIBUTE8                   => p_cur_credit.attribute8,
                                   X_ATTRIBUTE9                   => p_cur_credit.attribute9,
                                   X_ATTRIBUTE10                  => p_cur_credit.attribute10,
                                   X_ATTRIBUTE11                  => p_cur_credit.attribute11,
                                   X_ATTRIBUTE12                  => p_cur_credit.attribute12,
                                   X_ATTRIBUTE13                  => p_cur_credit.attribute13,
                                   X_ATTRIBUTE14                  => p_cur_credit.attribute14,
                                   X_ATTRIBUTE15                  => p_cur_credit.attribute15,
                                   X_ATTRIBUTE16                  => p_cur_credit.attribute16,
                                   X_ATTRIBUTE17                  => p_cur_credit.attribute17,
                                   X_ATTRIBUTE18                  => p_cur_credit.attribute18,
                                   X_ATTRIBUTE19                  => p_cur_credit.attribute19,
                                   X_ATTRIBUTE20                  => p_cur_credit.attribute20,
                                   X_MODE                         => 'R',
                                   X_GL_DATE                      => p_cur_credit.gl_date,
                                   X_CHECK_NUMBER                 => p_cur_credit.check_number,
                                   X_SOURCE_TRANSACTION_TYPE      => p_cur_credit.source_transaction_type,
                                   X_SOURCE_TRANSACTION_REF       => p_cur_credit.source_transaction_ref,
                                   x_credit_card_status_code      => p_cur_credit.credit_card_status_code,
                                   x_credit_card_payee_cd         => p_cur_credit.credit_card_payee_cd,
                                   x_credit_card_tangible_cd      => p_cur_credit.credit_card_tangible_cd,
                                   x_lockbox_interface_id         => p_cur_credit.lockbox_interface_id,
                                   x_batch_name                   => p_cur_credit.batch_name,
                                   x_deposit_date                 => p_cur_credit.deposit_date,
                                   x_source_invoice_id            => p_cur_credit.source_invoice_id,
                                   x_tax_year_code                => p_cur_credit.tax_year_code,
                                   x_waiver_name                  => p_cur_credit.waiver_name
                                );
  EXCEPTION
    WHEN OTHERS THEN
      p_flag :=FALSE;
  END;
END call_update_credits;


PROCEDURE application(p_credit_id         IN  igs_fi_credits.credit_id%TYPE,
                      p_invoice_id        IN  igs_fi_inv_int.invoice_id%TYPE,
                      p_amount_apply      IN  igs_fi_applications.amount_applied%TYPE,
                      p_cur_credit        IN  cur_credit%ROWTYPE,
                      p_cur_invoice       IN  cur_invoice%ROWTYPE,
                      p_dr_gl_ccid        OUT NOCOPY igs_fi_cr_activities.dr_gl_ccid%TYPE,
                      p_cr_gl_ccid        OUT NOCOPY igs_fi_cr_activities.cr_gl_ccid%TYPE,
                      p_dr_account_cd     OUT NOCOPY igs_fi_cr_activities.dr_account_cd%TYPE,
                      p_cr_account_cd     OUT NOCOPY igs_fi_cr_activities.cr_account_cd%TYPE,
                      p_application_id    OUT NOCOPY igs_fi_applications.application_id%TYPE,
                      p_appl_hierarchy_id IN  igs_fi_applications.appl_hierarchy_id%TYPE,
                      p_unapp_amount      OUT NOCOPY igs_fi_credits_all.unapplied_amount%TYPE,
                      p_inv_amt_due       OUT NOCOPY igs_fi_inv_int_all.invoice_amount_due%TYPE,
                      p_err_msg           OUT NOCOPY fnd_new_messages.message_name%TYPE,
                      p_status            OUT NOCOPY BOOLEAN,
                      p_d_gl_date         IN  DATE
                      )
 AS
/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For creating application .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  vvutukur     20-Nov-2003   Bug#3249288.Modified the existing conditional check for a charge to be
  ||                             optional or not is modified to look at the OPTIONAL_FEE_FLAG column of
  ||                             charges table instead of the optional_payment_ind column of fee type table.
  ||  pathipat     07-Jun-2003   Enh 2831584 - SS Enhancements build
  ||                             Modified call to call_update_charges() - Added check for optional_payment_ind
  ||                             and waiver flag
  || smadathi      20-NOV-2002   Enh. Bug 2584986. Modified igs_fi_applications_pkg.insert_row
  ||                             to add new parameters GL Date , GL_POSTED_DATE, POSTING_CONTROL_ID
  ||  (reverse chronological order - newest change first) */

  CURSOR cur_cr_act IS
  SELECT credit_activity_id
  FROM   igs_fi_cr_activities
  WHERE  credit_id = p_credit_id;
  l_cur_cr_act cur_cr_act%ROWTYPE;

  CURSOR cur_invln IS
  SELECT invoice_lines_id
  FROM   igs_fi_invln_int
  WHERE  invoice_id = p_invoice_id;
  l_cur_invln cur_invln%ROWTYPE;

  l_rowid              VARCHAR2(25):=NULL;
  l_amount             igs_fi_applications.amount_applied%TYPE;
  l_status             BOOLEAN :=TRUE;
  l_appl_success       BOOLEAN :=TRUE;
  l_crd_upd_success    BOOLEAN :=TRUE;
  l_chg_upd_success    BOOLEAN :=TRUE;

  l_v_optional_fee_flag  igs_fi_inv_int_all.optional_fee_flag%TYPE := NULL;

BEGIN
  SAVEPOINT S1;
  p_application_id:=NULL;
  p_unapp_amount:=NULL;
  p_inv_amt_due:=NULL;
  p_status:=TRUE;
  p_err_msg:=NULL;

  --Fetch the credit activity id
  OPEN cur_cr_act;
  FETCH cur_cr_act INTO l_cur_cr_act;
  CLOSE cur_cr_act;

  --Fetch the invoice lines Id
  OPEN cur_invln;
  FETCH cur_invln INTO l_cur_invln;
  CLOSE cur_invln;

  -- Fetch the accounting Codes
  get_appl_acc(p_cr_activity_id   =>l_cur_cr_act.credit_activity_id,
               p_invoice_lines_id =>l_cur_invln.invoice_lines_id,
               p_dr_gl_ccid       =>p_dr_gl_ccid,
               p_cr_gl_ccid       =>p_cr_gl_ccid,
               p_dr_account_cd    =>p_dr_account_cd,
               p_cr_account_cd    =>p_cr_account_cd,
               p_status           =>l_status);

  IF l_status=FALSE THEN
    p_status:=FALSE;
    p_err_msg:='IGS_FI_APPL_ACC_ERR';
  ELSE
    --setting the amount applied in applications table
    IF p_amount_apply IS NOT NULL THEN
      l_amount:=p_amount_apply;
    ELSE
      IF p_cur_credit.unapplied_amount > p_cur_invoice.invoice_amount_due THEN
        l_amount:=p_cur_invoice.invoice_amount_due;
      ELSE
        l_amount := p_cur_credit.unapplied_amount;
      END IF;
    END IF;

    --Insert record into application table
     -- Modified apply_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
    BEGIN
      p_application_id:=NULL;
      igs_fi_applications_pkg.insert_row( X_ROWID                     => l_rowid,
                                          X_APPLICATION_ID            => p_application_id,
                                          X_APPLICATION_TYPE          => g_app,
                                          X_INVOICE_ID                => p_invoice_id,
                                          X_CREDIT_ID                 => p_credit_id,
                                          X_CREDIT_ACTIVITY_ID        => l_cur_cr_act.credit_activity_id,
                                          X_AMOUNT_APPLIED            => l_amount,
                                          X_APPLY_DATE                => TRUNC(SYSDATE),
                                          X_LINK_APPLICATION_ID       => NULL,
                                          X_DR_ACCOUNT_CD             => p_dr_account_cd,
                                          X_CR_ACCOUNT_CD             => p_cr_account_cd,
                                          X_DR_GL_CODE_CCID           => p_dr_gl_ccid,
                                          X_CR_GL_CODE_CCID           => p_cr_gl_ccid,
                                          X_APPLIED_INVOICE_LINES_ID  => l_cur_invln.invoice_lines_id,
                                          X_APPL_HIERARCHY_ID         => p_appl_hierarchy_id,
                                          X_POSTING_ID                => NULL,
                                          X_MODE                      => 'R' ,
                                          X_GL_DATE                   => TRUNC(p_d_gl_date),
                                          X_GL_POSTED_DATE            => NULL,
                                          X_POSTING_CONTROL_ID        => NULL
                                       );
    EXCEPTION
      WHEN OTHERS THEN
        l_appl_success:=FALSE;
    END;

    IF l_appl_success THEN
      --update the record in the credits table, the unapplied amount
      p_unapp_amount:=p_cur_credit.unapplied_amount - l_amount;
      call_update_credits(p_unapp_amount,p_cur_credit,l_crd_upd_success);
    END IF;


    IF ((l_appl_success= TRUE) AND (l_crd_upd_success= TRUE)) THEN
      --Update the charges table , invoice amount due column
      p_inv_amt_due:= p_cur_invoice.invoice_amount_due - l_amount;

      -- The existing conditional check is modified to look at the
      -- OPTIONAL_FEE_FLAG column of charges table instead of the
      -- optional_payment_ind column of fee type table.

      IF (p_cur_invoice.optional_fee_flag = 'O') THEN
        IF (p_cur_invoice.waiver_flag = 'Y') THEN
           -- Pass 'D' - Declined - as value for parameter p_v_opt_flag
           l_v_optional_fee_flag := 'D';
        ELSIF (p_cur_invoice.waiver_flag = 'N') THEN
           -- Pass 'A' - Accepted - as value for parameter p_v_opt_flag
           l_v_optional_fee_flag := 'A';
        END IF;
      ELSIF (p_cur_invoice.optional_fee_flag = 'N') THEN
        -- Pass null to p_v_opt_fee_flag since optional_fee_flag = 'N'
           l_v_optional_fee_flag := NULL;
      END IF;

      call_update_charges( p_invoice_amount_due => p_inv_amt_due,
                           p_cur_invoice        => p_cur_invoice,
                           p_v_opt_fee_flag     => l_v_optional_fee_flag,
                           p_flag               => l_chg_upd_success);
    END IF;

    IF ((l_appl_success=FALSE) OR (l_crd_upd_success=FALSE) OR (l_chg_upd_success=FALSE)) THEN
       p_application_id:=NULL;
       p_unapp_amount:=NULL;
       p_inv_amt_due:=NULL;
       p_status:=FALSE;
       p_err_msg:='IGS_GE_UNHANDLED_EXCEPTION'; -- fnd_message.get was replaced by message name IGS_GE_UNHANDLED_EXCEPTION
       ROLLBACK TO S1;
    END IF;
  END IF;

END application;

PROCEDURE unapplication(p_credit_id      IN     igs_fi_credits.credit_id%TYPE,
                        p_invoice_id     IN     igs_fi_inv_int.invoice_id%TYPE,
                        p_amount_apply   IN     igs_fi_applications.amount_applied%TYPE,
                        p_cur_credit     IN     cur_credit%ROWTYPE,
                        p_cur_invoice    IN     cur_invoice%ROWTYPE,
                        p_application_id IN OUT NOCOPY igs_fi_applications.application_id%TYPE,
                        p_unapp_amount   OUT NOCOPY    igs_fi_credits_all.unapplied_amount%TYPE,
                        p_inv_amt_due    OUT NOCOPY    igs_fi_inv_int_all.invoice_amount_due%TYPE,
                        p_err_msg        OUT NOCOPY    fnd_new_messages.message_name%TYPE,
                        p_status         OUT NOCOPY    BOOLEAN,
                        p_d_gl_date      IN     DATE
                        ) AS

/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For creating unapplication .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat     07-Jun-2003   Enh 2831584 - SS Enhancements build
  ||                             Modified call to call_update_charges()
  || smadathi      20-NOV-2002   Enh. Bug 2584986. Modified igs_fi_applications_pkg.insert_row
  ||                             to add new parameters GL Date , GL_POSTED_DATE, POSTING_CONTROL_ID
  ||  (reverse chronological order - newest change first) */


  CURSOR  cur_unapp IS
  SELECT  *
  FROM    igs_fi_applications
  WHERE   application_id = p_application_id;
  l_cur_unapp  cur_unapp%ROWTYPE;

  l_unapp_amnt    igs_fi_applications.amount_applied%TYPE;

  l_rowid               VARCHAR2(25);
  l_application_id      igs_fi_applications.application_id%TYPE ;
  l_amount              igs_fi_applications.amount_applied%TYPE;
  l_appl_success        BOOLEAN :=TRUE;
  l_crd_upd_success     BOOLEAN :=TRUE;
  l_chg_upd_success     BOOLEAN :=TRUE;
BEGIN
  SAVEPOINT S2;
  p_status:=TRUE;
  p_err_msg:=NULL;
  p_unapp_amount:=NULL;
  p_inv_amt_due:=NULL;

  OPEN cur_unapp;
  FETCH cur_unapp INTO l_cur_unapp;
  CLOSE cur_unapp;

  l_unapp_amnt:=get_sum_appl_amnt(p_application_id);

  IF l_unapp_amnt > 0 THEN
    --Calculate the amount to be unapplied
    IF p_amount_apply IS NULL THEN
      l_amount := - l_unapp_amnt;
    ELSE
      IF p_amount_apply > l_unapp_amnt THEN
        l_amount := - l_unapp_amnt;
      ELSE
        l_amount := - p_amount_apply;
      END IF;
    END IF;

    --Insert the unapplication record
    -- Modified apply_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
    BEGIN
      l_rowid:=NULL;
      l_application_id:=NULL;
      igs_fi_applications_pkg.insert_row( X_ROWID                     => l_rowid,
                                          X_APPLICATION_ID            => l_application_id,
                                          X_APPLICATION_TYPE          => g_unapp,
                                          X_INVOICE_ID                => p_invoice_id,
                                          X_CREDIT_ID                 => p_credit_id,
                                          X_CREDIT_ACTIVITY_ID        => l_cur_unapp.credit_activity_id,
                                          X_AMOUNT_APPLIED            => l_amount,
                                          X_APPLY_DATE                => TRUNC(SYSDATE),
                                          X_LINK_APPLICATION_ID       => l_cur_unapp.application_id,
                                          X_DR_ACCOUNT_CD             => l_cur_unapp.dr_account_cd,
                                          X_CR_ACCOUNT_CD             => l_cur_unapp.cr_account_cd,
                                          X_DR_GL_CODE_CCID           => l_cur_unapp.dr_gl_code_ccid,
                                          X_CR_GL_CODE_CCID           => l_cur_unapp.cr_gl_code_ccid,
                                          X_APPLIED_INVOICE_LINES_ID  => l_cur_unapp.applied_invoice_lines_id,
                                          X_APPL_HIERARCHY_ID         => l_cur_unapp.appl_hierarchy_id,
                                          X_POSTING_ID                => NULL,
                                          X_MODE                      => 'R' ,
                                          X_GL_DATE                   => TRUNC(p_d_gl_date),
                                          X_GL_POSTED_DATE            => NULL,
                                          X_POSTING_CONTROL_ID        => NULL
                                         );
    EXCEPTION
      WHEN OTHERS THEN
        l_appl_success:=FALSE;
    END;

    IF l_appl_success THEN
      --Update the credits table with the unapplied amount
      p_unapp_amount:=p_cur_credit.unapplied_amount - l_amount;
      call_update_credits(p_unapp_amount,p_cur_credit,l_crd_upd_success);
      IF l_crd_upd_success THEN
        --Update the charges table with invoice amount due
        p_inv_amt_due:=p_cur_invoice.invoice_amount_due - l_amount;
        -- Pass NULL as value to parameter p_v_opt_fee_flag
           call_update_charges( p_invoice_amount_due => p_inv_amt_due,
                                p_cur_invoice        => p_cur_invoice,
                                p_v_opt_fee_flag     => NULL,
                                p_flag               => l_chg_upd_success);
      END IF;
    END IF;

    p_application_id :=l_application_id;

    IF ((l_appl_success=FALSE) OR (l_crd_upd_success=FALSE) OR (l_chg_upd_success=FALSE)) THEN
      p_application_id:=NULL;
      p_unapp_amount:=NULL;
      p_inv_amt_due:=NULL;
      p_status:=FALSE;
      p_err_msg:='IGS_GE_UNHANDLED_EXCEPTION'; -- fnd_message.get was replaced by message name IGS_GE_UNHANDLED_EXCEPTION

      ROLLBACK TO S2;
    END IF;
  ELSE
    p_status:=FALSE;
    p_err_msg:='IGS_FI_NO_APP_REC';
  END IF;

END unapplication;


PROCEDURE get_appl_acc(p_cr_activity_id   IN  igs_fi_cr_activities.credit_activity_id%TYPE,
                       p_invoice_lines_id IN  igs_fi_invln_int.invoice_lines_id%TYPE,
                       p_dr_gl_ccid       OUT NOCOPY igs_fi_cr_activities.dr_gl_ccid%TYPE,
                       p_cr_gl_ccid       OUT NOCOPY igs_fi_cr_activities.cr_gl_ccid%TYPE,
                       p_dr_account_cd    OUT NOCOPY igs_fi_cr_activities.dr_account_cd%TYPE,
                       p_cr_account_cd    OUT NOCOPY igs_fi_cr_activities.cr_account_cd%TYPE,
                       p_status           OUT NOCOPY BOOLEAN) AS
/*||  Created By :Sarakshi
  ||  Created On :23-Jan-2002
  ||  Purpose :To derive the Accounting Information for the Application Record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first) */

  CURSOR cur_cr_act  IS
  SELECT dr_gl_ccid,cr_gl_ccid,dr_account_cd,cr_account_cd
  FROM   igs_fi_cr_activities
  WHERE  credit_activity_id = p_cr_activity_id;
  l_cur_cr_act cur_cr_act%ROWTYPE;

  CURSOR cur_inv IS
  SELECT rec_gl_ccid,rev_gl_ccid,rec_account_cd,rev_account_cd
  FROM   igs_fi_invln_int
  WHERE  invoice_lines_id = p_invoice_lines_id
  AND    NVL(error_account,'N') <> 'Y';
  l_cur_inv cur_inv%ROWTYPE;

  CURSOR cur_class IS
  SELECT ct.credit_class
  FROM   igs_fi_cr_types ct,
         igs_fi_credits  c,
         igs_fi_cr_activities ca
  WHERE  ct.credit_type_id=c.credit_type_id
  AND    c.credit_id=ca.credit_id
  AND    ca.credit_activity_id=p_cr_activity_id;
  l_cur_class cur_class%ROWTYPE;

  l_rec_installed     igs_fi_control.rec_installed%TYPE;
  l_accounting_method igs_fi_control.accounting_method%TYPE;
BEGIN
  p_dr_gl_ccid := NULL;
  p_cr_gl_ccid := NULL;
  p_dr_account_cd :=NULL;
  p_cr_account_cd :=NULL;
  p_status := TRUE;

  IF ((p_cr_activity_id IS NULL) OR (p_invoice_lines_id IS NULL)) THEN
    p_status:= FALSE;
  END IF;

  IF p_status THEN
      --Fetching the accounting method
      l_accounting_method := igs_fi_gen_005.finp_get_acct_meth;
    IF l_accounting_method IS NULL THEN
      p_status:= FALSE;
    END IF;
  END IF;

  IF p_status THEN
    --Fetch the accounting information from Credits Activities Table
    OPEN cur_cr_act;
    FETCH cur_cr_act INTO l_cur_cr_act;
    IF cur_cr_act%NOTFOUND THEN
      p_status:=FALSE;
    END IF;
    CLOSE cur_cr_act;
  END IF;

  IF p_status THEN
    --Fetch the accounting information from Invoice Lines Table
    OPEN cur_inv;
    FETCH cur_inv INTO l_cur_inv;
    IF cur_inv%NOTFOUND THEN
      p_status := FALSE;
    END IF;
    CLOSE cur_inv;
  END IF;

  IF p_status THEN
    --Fetching the Receivables installed
    l_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;
    IF l_accounting_method = 'CASH' THEN
      --Fetch the credit class information
      OPEN cur_class;
      FETCH cur_class INTO l_cur_class;
      CLOSE cur_class;
      IF l_rec_installed = g_yes THEN
        p_dr_gl_ccid := l_cur_cr_act.cr_gl_ccid;
        IF l_cur_class.credit_class = g_chg_adj THEN
          p_cr_gl_ccid := l_cur_cr_act.dr_gl_ccid;
        ELSE
          p_cr_gl_ccid :=l_cur_inv.rev_gl_ccid;
        END IF;
      ELSIF l_rec_installed <> g_yes THEN
        p_dr_account_cd := l_cur_cr_act.cr_account_cd;
        IF l_cur_class.credit_class = g_chg_adj THEN
          p_cr_account_cd := l_cur_cr_act.dr_account_cd;
        ELSE
          p_cr_account_cd := l_cur_inv.rev_account_cd;
        END IF;
      END IF;
    ELSIF l_accounting_method = 'ACCRUAL' THEN
      IF l_rec_installed = g_yes THEN
        p_dr_gl_ccid :=  l_cur_cr_act.cr_gl_ccid;
        p_cr_gl_ccid :=  l_cur_inv.rec_gl_ccid;
      ELSIF l_rec_installed <> g_yes THEN
        p_dr_account_cd :=l_cur_cr_act.cr_account_cd;
        p_cr_account_cd := l_cur_inv.rec_account_cd;
      END IF;
    END IF;--End of accounting method CASH
  END IF;--End of p_status

END get_appl_acc;

FUNCTION get_sum_appl_amnt(p_application_id IN  igs_fi_applications.application_id%TYPE)
RETURN NUMBER AS
/*
  ||  Created By :Sarakshi
  ||  Created On :31-Jan-2002
  ||  Purpose :To return the sum of amount applied for an application Id and its corresponding unapplication
  ||          records ,if no record is found or parameter passed is null then return null
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When            What
  ||  (reverse chronological order - newest change first)
  || pmarada   14-Mar-2005    Bug 4224386, Instead of sum builtin, repeating in a loop to sum the unapply amount.
  */

  CURSOR cur_unapp_amnt IS
  SELECT amount_applied FROM  igs_fi_applications
  WHERE  (application_id = p_application_id AND application_type='APP')
  OR     link_application_id=p_application_id;

   l_cur_unapp_amnt   igs_fi_applications.amount_applied%TYPE;

BEGIN
  --To return the sum of amount applied for an application Id and its corresponding unapplication
  --records ,if no record is found or parameter passed is null then return null
  IF p_application_id IS NULL THEN
     RETURN NULL;
  ELSE
    l_cur_unapp_amnt := 0;
    FOR cur_unapp_amnt_rec IN cur_unapp_amnt LOOP
      l_cur_unapp_amnt := l_cur_unapp_amnt + cur_unapp_amnt_rec.amount_applied;
    END LOOP;
    RETURN l_cur_unapp_amnt;
  END IF;

END get_sum_appl_amnt;


PROCEDURE create_application (p_application_id    IN OUT NOCOPY igs_fi_applications.application_id%TYPE,
                              p_credit_id         IN     igs_fi_applications.credit_id%TYPE,
                              p_invoice_id        IN     igs_fi_applications.invoice_id%TYPE,
                              p_amount_apply      IN     igs_fi_applications.amount_applied%TYPE,
                              p_appl_type         IN     igs_fi_applications.application_type%TYPE,
                              p_appl_hierarchy_id IN     igs_fi_applications.appl_hierarchy_Id%TYPE,
                              p_validation        IN     VARCHAR2 ,
                              p_dr_gl_ccid        OUT NOCOPY    igs_fi_cr_activities.dr_gl_ccid%TYPE,
                              p_cr_gl_ccid        OUT NOCOPY    igs_fi_cr_activities.cr_gl_ccid%TYPE,
                              p_dr_account_cd     OUT NOCOPY    igs_fi_cr_activities.dr_account_cd%TYPE,
                              p_cr_account_cd     OUT NOCOPY    igs_fi_cr_activities.cr_account_cd%TYPE,
                              p_unapp_amount      OUT NOCOPY    igs_fi_credits_all.unapplied_amount%TYPE,
                              p_inv_amt_due       OUT NOCOPY    igs_fi_inv_int_all.invoice_amount_due%TYPE,
                              p_err_msg           OUT NOCOPY    fnd_new_messages.message_name%TYPE,
                              p_status            OUT NOCOPY    BOOLEAN,
                              p_d_gl_date         IN     DATE
                              ) AS
/*||  Created By :Sarakshi
  ||  Created On :24-Jan-2002
  ||  Purpose : For creating application of credit against a charge.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi         20-NOV-2002     Enh. Bug 2584986. Added new parameter GL Date
  ||                                  to procedure create_application.  Added new parameter GL Date
  ||                                  to calls to application and unapplication procedures.
  ||  (reverse chronological order - newest change first) */

  CURSOR cur_app IS
  SELECT credit_id,invoice_id
  FROM   igs_fi_applications
  WHERE  application_id=p_application_id;

  l_cur_app           cur_app%ROWTYPE;
  l_cur_credit        cur_credit%ROWTYPE;
  l_cur_invoice       cur_invoice%ROWTYPE;
  l_cur_credit_unapp  cur_credit_unapp%ROWTYPE;
  l_cur_invoice_unapp cur_invoice_unapp%ROWTYPE;

  l_b_flag  BOOLEAN := FALSE;
BEGIN
  p_status:=TRUE;
  p_err_msg:=NULL;
  p_dr_gl_ccid:=NULL;
  p_cr_gl_ccid:=NULL;
  p_dr_account_cd:=NULL;
  p_cr_account_cd:=NULL;
  p_unapp_amount:=NULL;
  p_inv_amt_due:=NULL;

  --Validate the parameters. PROCEDURE validate_parameters will only be invoked
  --if p_validation parameter value is Y
  IF p_validation = 'Y' THEN
    validate_parameters(p_credit_id , p_invoice_id , p_amount_apply  , p_appl_type ,
                        p_application_id ,p_appl_hierarchy_id , p_err_msg , p_status,
                        p_d_gl_date
                        );
  END IF;

  --If parameter validation is successful then only proceed
  IF p_status THEN
    IF p_appl_type = g_app THEN
          -- if the  validate_parameters procedure  returns the message IGS_FI_CHG_CRD_GL_DATE
          -- return status as true to p_status parameter and message to p_err_msg
          IF p_err_msg = 'IGS_FI_CHG_CRD_GL_DATE' THEN
            l_b_flag   := TRUE;
          END IF;

      --Get the credit record
      OPEN cur_credit(p_credit_id);
      FETCH cur_credit INTO l_cur_credit;
      CLOSE cur_credit;
      --Get the charge record
      OPEN cur_invoice(p_invoice_id);
      FETCH cur_invoice INTO l_cur_invoice;
      CLOSE cur_invoice;

      application(  p_credit_id         => p_credit_id ,
                    p_invoice_id        => p_invoice_id ,
                    p_amount_apply      => p_amount_apply ,
                    p_cur_credit        => l_cur_credit ,
                    p_cur_invoice       => l_cur_invoice ,
                    p_dr_gl_ccid        => p_dr_gl_ccid,
                    p_cr_gl_ccid        => p_cr_gl_ccid,
                    p_dr_account_cd     => p_dr_account_cd,
                    p_cr_account_cd     => p_cr_account_cd,
                    p_application_id    => p_application_id,
                    p_appl_hierarchy_id => p_appl_hierarchy_id,
                    p_unapp_amount      => p_unapp_amount,
                    p_inv_amt_due       => p_inv_amt_due,
                    p_err_msg           => p_err_msg ,
                    p_status            => p_status,
                    p_d_gl_date         => TRUNC(p_d_gl_date)
                    );
          -- if the  validate_parameters procedure  returns the message IGS_FI_CHG_CRD_GL_DATE
          -- return status as true to p_status parameter and message to p_err_msg
       IF  p_status AND (l_b_flag) THEN
         l_b_flag   := FALSE;
         p_status   := TRUE;
         p_err_msg  := 'IGS_FI_CHG_CRD_GL_DATE';
       END IF;

    ELSIF p_appl_type = g_unapp THEN

      --Get the credit_id and invoice_id if not supplied that is possible for UNAPP only
      OPEN cur_app;
      FETCH cur_app INTO l_cur_app;
      CLOSE cur_app;

      --Get the credit record
      OPEN cur_credit_unapp(l_cur_app.credit_id);
      FETCH cur_credit_unapp INTO l_cur_credit_unapp;
      CLOSE cur_credit_unapp;
      --Get the charge record
      OPEN cur_invoice_unapp(l_cur_app.invoice_id);
      FETCH cur_invoice_unapp INTO l_cur_invoice_unapp;
      CLOSE cur_invoice_unapp;

      unapplication(p_credit_id      => l_cur_app.credit_id ,
                    p_invoice_id     => l_cur_app.invoice_id ,
                    p_amount_apply   => p_amount_apply ,
                    p_cur_credit     => l_cur_credit_unapp ,
                    p_cur_invoice    => l_cur_invoice_unapp ,
                    p_application_id => p_application_id,
                    p_unapp_amount   => p_unapp_amount,
                    p_inv_amt_due    => p_inv_amt_due,
                    p_err_msg        => p_err_msg ,
                    p_status         => p_status,
                    p_d_gl_date      => TRUNC(p_d_gl_date)
                    );
    END IF;
  END IF;

  IF p_status =FALSE THEN
    p_application_id:=NULL;
  END IF;

END create_application;

FUNCTION validate_person(p_person_id igs_pe_person.person_id%TYPE) RETURN VARCHAR2 IS
/*||  Created By :Sarakshi
  ||  Created On :27-Feb-2002
  ||  Purpose : For validating the input person_id, for the person_type of PERSON,ORGANIZATION.
  ||            If record is found in igs_fi_parties_v then it returns 'Y'else 'N'.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sapanigr       09-Feb-2006     Bug 5018036: Cursor cur_person now uses hz_parties instead of igs_fi_parties_v
  ||  (reverse chronological order - newest change first)
  */
  CURSOR cur_person IS
  SELECT 'X'
  FROM    hz_parties
  WHERE   party_id=p_person_id;
  l_var   VARCHAR2(1);
BEGIN
  IF p_person_id IS NULL THEN
    RETURN 'N';
  END IF;
  OPEN cur_person;
  FETCH cur_person INTO l_var;
  IF cur_person%FOUND THEN
   CLOSE cur_person;
   RETURN 'Y';
  ELSE
   CLOSE cur_person;
   RETURN 'N';
  END IF;
END validate_person;

FUNCTION get_ccid_concat(p_ccid     IN   NUMBER) RETURN VARCHAR2 AS
/*||  Created By : agairola
  ||  Created On :10-Apr-2002
  ||  Purpose : For fetching the Concatenated Segments for the Code Combination Id passed as
  ||            input to the function
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first) */

-- Cursor for fetching the Concatenated Segments for the CCID passed as input to the function
  CURSOR cur_gl_ccid(cp_ccid    NUMBER) IS
    SELECT concatenated_segments
    FROM gl_code_combinations_kfv
    WHERE code_combination_id = cp_ccid;

  l_ccid_concat  gl_code_combinations_kfv.concatenated_segments%TYPE;
BEGIN

-- If the p_ccid is passed as NULL, then return NULL
  IF p_ccid IS NULL THEN
    l_ccid_concat := NULL;

-- Else
  ELSE

-- Fetch the Concatenated Segments from the GL_CODE_COMBINATIONS_KFV view
    OPEN cur_gl_ccid(p_ccid);
    FETCH cur_gl_ccid INTO l_ccid_concat;
    IF cur_gl_ccid%NOTFOUND THEN
      l_ccid_concat := NULL;
    END IF;
    CLOSE cur_gl_ccid;
  END IF;

-- Return the value set for the l_ccid_concat
  RETURN l_ccid_concat;
END get_ccid_concat;

FUNCTION get_person_id_type
RETURN VARCHAR2 IS
/*||  Created By :Sarakshi
  ||  Created On :13-JUN-2002
  ||  Purpose : For getting the person id type which is preffered .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi       01-jan-2003       Bug 2713272. Modified the cursor cur_pref_person to select
  ||                                 from igs_pe_person_id_typ instead of the igs_pe_person_id_typ_v.
  ||                                 This is done due to Non-Meargabile view and higher value of shared memory
  ||                                 beyong the acceptable limit
  ||  (reverse chronological order - newest change first) */
  CURSOR cur_pref_person IS
  SELECT person_id_type
  FROM   igs_pe_person_id_typ
  WHERE  preferred_ind='Y';
  l_person_id_type  igs_pe_person_id_typ.person_id_type%TYPE;
BEGIN
  OPEN cur_pref_person;
  FETCH cur_pref_person INTO l_person_id_type;
  CLOSE cur_pref_person;
  RETURN l_person_id_type;
END get_person_id_type;


PROCEDURE finp_get_conv_prc_run_ind(p_n_conv_process_run_ind   OUT NOCOPY  igs_fi_control.conv_process_run_ind%TYPE,
                                    p_v_message_name           OUT NOCOPY  fnd_new_messages.message_name%TYPE) AS

/*||  Created By : PATHIPAT
  ||  Created On : 02-OCT-2002
  ||  Purpose : For getting the value of the conv_process_run_ind which indicates
  ||            whether the holds conversion process is running or not
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat        23-Dec-02       Bug: 2723531 - Returned 0 if the value of the
  ||                                  column conv_process_run_ind is NULL in the table
  ||  (reverse chronological order - newest change first) */

 CURSOR cur_prc_run_ind IS
   SELECT conv_process_run_ind
   FROM igs_fi_control_all ;

 l_prc_run_ind   igs_fi_control_all.conv_process_run_ind%TYPE;

 BEGIN

   OPEN cur_prc_run_ind;
   FETCH cur_prc_run_ind INTO l_prc_run_ind;
   IF cur_prc_run_ind%NOTFOUND THEN
      p_n_conv_process_run_ind :=  NULL;
      p_v_message_name := 'IGS_FI_SYSTEM_OPT_SETUP';
      CLOSE cur_prc_run_ind;
      RETURN;
   END IF;

   CLOSE cur_prc_run_ind;

   IF l_prc_run_ind IS NULL THEN
      l_prc_run_ind := 0;
   END IF;

   p_n_conv_process_run_ind := l_prc_run_ind;
   p_v_message_name := NULL;
   RETURN;

 END finp_get_conv_prc_run_ind;


PROCEDURE finp_get_balance_rule (p_v_balance_type          IN  igs_fi_balance_rules.balance_name%TYPE,
                                 p_v_action                IN  VARCHAR2,
                                 p_n_balance_rule_id       OUT NOCOPY igs_fi_balance_rules.balance_rule_id%TYPE,
                                 p_d_last_conversion_date  OUT NOCOPY igs_fi_balance_rules.last_conversion_date%TYPE,
                                 p_n_version_number        OUT NOCOPY igs_fi_balance_rules.version_number%TYPE ) AS
/*||  Created By : PATHIPAT
  ||  Created On : 02-OCT-2002
  ||  Purpose : For getting the balance rule defined in the system for an input balance type
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first) */

  -- Cursor to get the balance rule details when the p_v_action is 'ACTIVE'
  CURSOR cur_get_active(cp_balance_type igs_fi_balance_rules.balance_name%TYPE) IS
   SELECT balance_rule_id,
          version_number,
          last_conversion_date
   FROM   IGS_FI_BALANCE_RULES
   WHERE  balance_name = cp_balance_type
   AND    last_conversion_date IS NOT NULL
   ORDER BY version_number DESC;

  -- Cursor to get the balance rule details when the p_v_action is 'MAX'
  CURSOR cur_get_max(cp_balance_type igs_fi_balance_rules.balance_name%TYPE) IS
    SELECT balance_rule_id,
           version_number,
           last_conversion_date
    FROM   IGS_FI_BALANCE_RULES
    WHERE  balance_name = cp_balance_type
    ORDER BY version_number DESC;

  -- Cursor to check if the input balance type is a valid lookup code or not
  CURSOR cur_balance_type(cp_balance_type igs_fi_balance_rules.balance_name%TYPE) IS
    SELECT *
    FROM  igs_lookup_values
    WHERE lookup_type = 'IGS_FI_BALANCE_TYPE'
    AND   lookup_code = cp_balance_type
    AND   lookup_code IN ('HOLDS','FEE')
    AND   enabled_flag = 'Y'
    AND   ( (start_date_active < TRUNC(SYSDATE))
            AND
            (end_date_active IS NULL OR end_date_active > TRUNC(SYSDATE))
          );

   l_cur_get_active  cur_get_active%ROWTYPE;
   l_cur_get_max     cur_get_max%ROWTYPE;
   l_cur_get_bal     cur_balance_type%ROWTYPE;

  BEGIN

    OPEN cur_balance_type(p_v_balance_type);
    FETCH cur_balance_type INTO l_cur_get_bal;
    -- 1
    IF cur_balance_type%FOUND THEN
         IF p_v_action = 'ACTIVE' THEN   --  (2)
              IF p_v_balance_type = 'FEE' THEN
                   fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
                   app_exception.raise_exception;  -- raise exception and return
              END IF;
              OPEN cur_get_active(p_v_balance_type);
              FETCH cur_get_active INTO l_cur_get_active;
              IF (cur_get_active%FOUND) THEN      -- IF (3)
                   p_n_balance_rule_id := l_cur_get_active.balance_rule_id;
                   p_d_last_conversion_date := l_cur_get_active.last_conversion_date;
                   p_n_version_number := l_cur_get_active.version_number;
                   CLOSE cur_get_active;
                   RETURN;
              END IF;              --  (3)
              CLOSE cur_get_active;

         ELSIF p_v_action = 'MAX' THEN  -- (2)

              OPEN cur_get_max(p_v_balance_type);
              FETCH cur_get_max INTO l_cur_get_max;
              IF (cur_get_max%FOUND) THEN   --  (4)
                   p_n_balance_rule_id := l_cur_get_max.balance_rule_id;
                   p_d_last_conversion_date := l_cur_get_max.last_conversion_date;
                   p_n_version_number := l_cur_get_max.version_number;
                   CLOSE cur_get_max;
                   RETURN;
              END IF;              --  (4)
              CLOSE cur_get_max;
         ELSE   -- if the parameter is not 'ACTIVE' or 'MAX', then raise exception
             fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
             app_exception.raise_exception;
         END IF;             ---  (2)

         CLOSE cur_balance_type;
    ELSE
         -- No data found in the cursor
         CLOSE cur_balance_type;
         fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
         app_exception.raise_exception;
    END IF; -- 1

         p_n_balance_rule_id := NULL;
         p_d_last_conversion_date := NULL;
         p_n_version_number := 0;
         RETURN;

   END finp_get_balance_rule;

  END igs_fi_gen_007;

/
