--------------------------------------------------------
--  DDL for Package Body IGS_FI_REFUNDS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_REFUNDS_PROCESS" AS
/* $Header: IGSFI66B.pls 120.4 2006/06/27 14:21:13 skharida noship $ */

/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2002
  Purpose        :  This package is used for transfering data to and fro interface
                    refunds tables.
  Known limitations,enhancements,remarks:
  Change History
  Who        When         What
  skharida   26-Jun-2006  Bug# 5208136 - Modified update_refunds proc, removed the obsoleted columns from IGS_FI_REFUNDS_PKG
  sapanigr   03-May-2006  Enh#3924836 Precision Issue. Modified update_refunds and insert_interface.
  sapanigr   14-Feb-2006  Bug#5018036 - R12 Repository tuning. Cursors changed in procedures log_person and transfer_to_int.
  pathipat   23-Apr-2003  Enh 2831569 - Commercial Receivables build
                          Modified transfer_to_int() - added call to chk_manage_account()
                          Added flag g_b_data_found in transfer_int_rec()
  pathipat   18-Feb-2003  Enh 2747329 - Payables Intg build - Modified transfer_int_rec and transfer_to_int
                          Added global variable g_v_offset
  vvutukur   03-Jan-2003  Bug#2727216.Modifications done in function lookup_desc and procedure transfer_to_int.
  vvutukur   19-Nov-2002  Enh#2584986.Modifications done in insert_interface,update_refunds.
  vchappid   03-Jul-2002  Bug#2442030, Refunds Inbound payment information is obsoleted,
                          reference to payment_date, payment_number, payment_mode is removed from the
                          table IGS_FI_REFUND_INT_ALL
                          Refund Record Status 'COMPLETED' has been removed.

  vchappid   13-Jun-2002  Bug#2411529, Incorrectly used message name has been modified
  agairola   16-May-2002  For bug fix 2374103, modified log person, transfer_int_rec and update_pay_info
  vchappid   06-Mar-2002  Enh#2144600, new concurrent manager program update_pay_info
********************************************************************************************** */

  g_five_space     CONSTANT VARCHAR2(10) :='     ';
  g_ten_space      CONSTANT VARCHAR2(12) :='          ';
  g_transferred    CONSTANT VARCHAR2(15) :='TRANSFERRED';
  g_todo           CONSTANT VARCHAR2(10) :='TODO';
  g_v_offset       CONSTANT VARCHAR2(15) := 'OFFSET';

  g_b_data_found  BOOLEAN := FALSE;

  g_last_person_id igs_pe_person.person_id%TYPE :=NULL;
  g_update_last_person igs_fi_parties_v.person_id%TYPE :=NULL;

  e_resource_busy      EXCEPTION;
  PRAGMA               EXCEPTION_INIT(e_resource_busy,-0054);

  CURSOR  cur_ref(cp_person_id  igs_pe_person.person_id%TYPE,
                  cp_start_date igs_fi_refunds.voucher_date%TYPE,
                  cp_end_date   igs_fi_refunds.voucher_date%TYPE) IS
  SELECT  rfnd.*,rfnd.rowid
  FROM    igs_fi_refunds rfnd
  WHERE   (rfnd.person_id=cp_person_id OR (cp_person_id IS NULL))
  AND     rfnd.transfer_status='TODO'
  AND     rfnd.source_refund_id IS NOT NULL
  AND     (TRUNC(rfnd.voucher_date) >= TRUNC(cp_start_date) OR (cp_start_date IS NULL))
  AND     (TRUNC(rfnd.voucher_date) <= TRUNC(cp_end_date) OR (cp_end_date IS NULL))
  ORDER BY rfnd.person_id,rfnd.refund_id;

  CURSOR  cur_refund(cp_person_id  igs_pe_person.person_id%TYPE,
                     cp_start_date igs_fi_refunds.voucher_date%TYPE,
                     cp_end_date   igs_fi_refunds.voucher_date%TYPE) IS
  SELECT  rfnd.*,rfnd.rowid
  FROM    igs_fi_refunds rfnd
  WHERE   (rfnd.person_id=cp_person_id OR (cp_person_id IS NULL))
  AND     rfnd.transfer_status='TODO'
  AND     rfnd.source_refund_id IS  NULL
  AND     NVL(rfnd.reversal_ind,'N') <> 'Y'
  AND     (TRUNC(rfnd.voucher_date) >= TRUNC(cp_start_date) OR (cp_start_date IS NULL))
  AND     (TRUNC(rfnd.voucher_date) <= TRUNC(cp_end_date) OR (cp_end_date IS NULL))
  ORDER BY rfnd.person_id,rfnd.refund_id;

FUNCTION lookup_desc( p_type IN igs_lookups_view.lookup_type%TYPE,
                      p_code IN igs_lookups_view.lookup_code%TYPE)
RETURN VARCHAR2 IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2002
  Purpose        :  To fetch the meaning of a corresponding lookup code of a lookup type

  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
vvutukur  03-Jan-2003.  Bug#2727216. Removed the logic of deriving lookup meaning and placed the
                        call to generic function igs_fi_gen_gl.get_lkp_meaning,for doing same.
********************************************************************************************** */

l_cur_desc igs_lookup_values.meaning%TYPE ;

BEGIN
  l_cur_desc := igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type => p_type,
                                              p_v_lookup_code => p_code
                                              );
  RETURN l_cur_desc;
END lookup_desc;

PROCEDURE log_person(p_person_id              igs_pe_person_v.person_id%TYPE,
                     p_invoice_id             igs_fi_refunds.invoice_id%TYPE,
                     p_refund_id              igs_fi_refunds.refund_id%TYPE,
                     p_pay_person_id          igs_fi_refunds.pay_person_id%TYPE,
                     p_fee_type               igs_fi_refunds.fee_type%TYPE,
                     p_fee_cal_type           igs_fi_refunds.fee_cal_type%TYPE,
                     p_sequence_number        igs_fi_refunds.fee_ci_sequence_number%TYPE,
                     p_reversal_ind           igs_fi_refunds.reversal_ind%TYPE,
                     p_rec_status             VARCHAR2,
                     p_err_msg                fnd_new_messages.message_text%TYPE,
                     p_status                 BOOLEAN ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  4-Mar-2002
  Purpose        :  Logging information related to each refunds record being processed.

  Known limitations,enhancements,remarks:
  Change History
  Who       When        What
  sapanigr  14-Feb-2006 Bug#5018036 - 1. Cursor cur_date modified to use igs_fi_f_typ_ca_inst_all and igs_ca_inst
                        instead of igs_fi_f_typ_ca_inst_lkp_v
                        2. Cursor cur_pers changed to query hz_parties instead of igs_fi_parties_v

********************************************************************************************** */

  CURSOR cur_pers(cp_person_id hz_parties.party_id%TYPE) IS
  SELECT party_number
  FROM   hz_parties
  WHERE  party_id= cp_person_id;
  l_cur_pers cur_pers%ROWTYPE;

  CURSOR cur_inv IS
  SELECT invoice_number
  FROM   igs_fi_inv_int
  WHERE  invoice_id=p_invoice_id;
  l_cur_inv  cur_inv%ROWTYPE;

  CURSOR cur_date IS
  SELECT ci.start_dt start_dt,ci.end_dt end_dt
  FROM   igs_fi_f_typ_ca_inst_all ftci, igs_ca_inst ci
  WHERE  ftci.fee_type=p_fee_type
  AND    ftci.fee_cal_type=p_fee_cal_type
  AND    ftci.fee_ci_sequence_number=p_sequence_number
  AND    ci.cal_type = ftci.fee_cal_type
  AND    ci.sequence_number = ftci.fee_ci_sequence_number;
  l_cur_date   cur_date%ROWTYPE;

BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG,'   ');
  IF g_last_person_id = p_person_id THEN
    NULL;
  ELSE
    OPEN  cur_pers(p_person_id);
    FETCH cur_pers INTO l_cur_pers;
    CLOSE cur_pers;
    FND_FILE.PUT_LINE(FND_FILE.LOG,lookup_desc('IGS_FI_LOCKBOX','PERSON')||':'||l_cur_pers.party_number);
  END IF;
  g_last_person_id:=p_person_id;

  FND_FILE.PUT_LINE(FND_FILE.LOG,g_five_space||lookup_desc('IGS_FI_LOCKBOX','REFUND_ID')||':'||TO_CHAR(p_refund_id));


  OPEN  cur_inv;
  FETCH cur_inv INTO l_cur_inv;
  CLOSE cur_inv;
  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','INVOICE_NUMBER')||':'||l_cur_inv.invoice_number);

  OPEN cur_pers(p_pay_person_id);
  FETCH cur_pers INTO l_cur_pers;
  CLOSE cur_pers;
  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','PAYEE')||':'||l_cur_pers.party_number);

  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE')||':'||p_fee_type);

  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','FEE_CAL_TYPE')||':'||p_fee_cal_type);

  OPEN cur_date;
  FETCH cur_date INTO l_cur_date;
  CLOSE cur_date;
  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','START_DT')||':'||TO_CHAR(l_cur_date.start_dt,'DD-MON-YYYY'));

  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','END_DT')||':'||TO_CHAR(l_cur_date.end_dt,'DD-MON-YYYY'));

  FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','REVERSED')||':'||lookup_desc('VS_AS_YN',p_reversal_ind));

  IF p_status THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','STATUS')||':'||
                                                lookup_desc('REFUND_TRANSFER_STATUS',p_rec_status));
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','STATUS')||':'||lookup_desc('IGS_FI_LOCKBOX','ERROR'));
  END IF;

  IF p_status=FALSE THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,g_ten_space||lookup_desc('IGS_FI_LOCKBOX','REASON')||':'||p_err_msg);
  END IF;
END log_person;

PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                         p_msg_val   VARCHAR2
                       ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2001
  Purpose        :  To log the parameters

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
BEGIN
  FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
  FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
  FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
END log_messages ;

PROCEDURE update_refunds(p_status      IN  igs_fi_refunds.transfer_status%TYPE,
                         p_cur_ref_upd IN  cur_refund%ROWTYPE ,
                         p_dml_status  OUT NOCOPY BOOLEAN,
                         p_err_msg     OUT NOCOPY fnd_new_messages.message_text%TYPE) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2001
  Purpose        :  To update records in refunds table

  Known limitations,enhancements,remarks:
  Change History
  Who     When         What
skharida  26-Jun-2006  Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_REFUNDS
sapanigr  03-May-2006  Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_refunds
                       is now rounded off to currency precision
vvutukur  19-Nov-2002 Modified the call to igs_fi_refunds_pkg.update_row to add new parameters gl_date,
                      reversal_gl_date.
********************************************************************************************** */

BEGIN
  p_dml_status:=TRUE;
  p_err_msg:=NULL;

  -- Call to igs_fi_gen_gl.get_formatted_amount formats refund_amount by rounding off to currency precision
  igs_fi_refunds_pkg.update_row(X_ROWID                   => p_cur_ref_upd.rowid,
                                X_REFUND_ID               => p_cur_ref_upd.refund_id,
                                X_VOUCHER_DATE            => p_cur_ref_upd.voucher_date,
                                X_PERSON_ID               => p_cur_ref_upd.person_id,
                                X_PAY_PERSON_ID           => p_cur_ref_upd.pay_person_id,
                                X_DR_GL_CCID              => p_cur_ref_upd.dr_gl_ccid,
                                X_CR_GL_CCID              => p_cur_ref_upd.cr_gl_ccid,
                                X_DR_ACCOUNT_CD           => p_cur_ref_upd.dr_account_cd,
                                X_CR_ACCOUNT_CD           => p_cur_ref_upd.cr_account_cd,
                                X_REFUND_AMOUNT           => igs_fi_gen_gl.get_formatted_amount(p_cur_ref_upd.refund_amount),
                                X_FEE_TYPE                => p_cur_ref_upd.fee_type,
                                X_FEE_CAL_TYPE            => p_cur_ref_upd.fee_cal_type,
                                X_FEE_CI_SEQUENCE_NUMBER  => p_cur_ref_upd.fee_ci_sequence_number,
                                X_SOURCE_REFUND_ID        => p_cur_ref_upd.source_refund_id,
                                X_INVOICE_ID              => p_cur_ref_upd.invoice_id,
                                X_TRANSFER_STATUS         => p_status,
                                X_REVERSAL_IND            => p_cur_ref_upd.reversal_ind,
                                X_REASON                  => p_cur_ref_upd.reason,
                                X_ATTRIBUTE_CATEGORY      => p_cur_ref_upd.attribute_category,
                                X_ATTRIBUTE1              => p_cur_ref_upd.attribute1,
                                X_ATTRIBUTE2              => p_cur_ref_upd.attribute2,
                                X_ATTRIBUTE3              => p_cur_ref_upd.attribute3,
                                X_ATTRIBUTE4              => p_cur_ref_upd.attribute4,
                                X_ATTRIBUTE5              => p_cur_ref_upd.attribute5,
                                X_ATTRIBUTE6              => p_cur_ref_upd.attribute6,
                                X_ATTRIBUTE7              => p_cur_ref_upd.attribute7,
                                X_ATTRIBUTE8              => p_cur_ref_upd.attribute8,
                                X_ATTRIBUTE9              => p_cur_ref_upd.attribute9,
                                X_ATTRIBUTE10             => p_cur_ref_upd.attribute10,
                                X_ATTRIBUTE11             => p_cur_ref_upd.attribute11,
                                X_ATTRIBUTE12             => p_cur_ref_upd.attribute12,
                                X_ATTRIBUTE13             => p_cur_ref_upd.attribute13,
                                X_ATTRIBUTE14             => p_cur_ref_upd.attribute14,
                                X_ATTRIBUTE15             => p_cur_ref_upd.attribute15,
                                X_ATTRIBUTE16             => p_cur_ref_upd.attribute16,
                                X_ATTRIBUTE17             => p_cur_ref_upd.attribute17,
                                X_ATTRIBUTE18             => p_cur_ref_upd.attribute18,
                                X_ATTRIBUTE19             => p_cur_ref_upd.attribute19,
                                X_ATTRIBUTE20             => p_cur_ref_upd.attribute20,
                                X_MODE                    => 'R',
				X_GL_DATE                 => p_cur_ref_upd.gl_date,
				X_REVERSAL_GL_DATE        => p_cur_ref_upd.reversal_gl_date
                                );
EXCEPTION
  WHEN OTHERS THEN
    p_dml_status:=FALSE;
    p_err_msg:=FND_MESSAGE.GET;
    --If any unexpected event occured , other than what is expected from TBH, say ORA errors , then
    -- return that
    IF p_err_msg IS NULL THEN
      p_err_msg:=sqlerrm;
    END IF;
END update_refunds;

PROCEDURE insert_interface(p_cur_ref_ins  IN  cur_ref%ROWTYPE ,
                           p_dml_status   OUT NOCOPY BOOLEAN,
                           p_err_msg      OUT NOCOPY fnd_new_messages.message_text%TYPE) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2001
  Purpose        :  To insert records in the refunds interface table

  Known limitations,enhancements,remarks:
  Change History
  Who     When        What
sapanigr 03-May-2006 Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_refund_int
                     is now rounded off to currency precision
vvutukur 19-Nov-2002 Enh#2584986.Modified the call to igs_fi_refund_int_pkg.insert_row to include the new parameter
                     x_gl_date.
********************************************************************************************** */

  l_rowid      VARCHAR2(25) ;
BEGIN
   p_dml_status:=TRUE;
   p_err_msg:=NULL;

   -- Call to igs_fi_gen_gl.get_formatted_amount formats refund_amount by rounding off to currency precision
   igs_fi_refund_int_pkg.insert_row( X_ROWID                  => l_rowid,
                                     X_REFUND_ID              => p_cur_ref_ins.refund_id,
                                     X_VOUCHER_DATE           => p_cur_ref_ins.voucher_date,
                                     X_PERSON_ID              => p_cur_ref_ins.person_id,
                                     X_PAY_PERSON_ID          => p_cur_ref_ins.pay_person_id,
                                     X_DR_GL_CCID             => p_cur_ref_ins.dr_gl_ccid,
                                     X_CR_GL_CCID             => p_cur_ref_ins.cr_gl_ccid,
                                     X_DR_ACCOUNT_CD          => p_cur_ref_ins.dr_account_cd,
                                     X_CR_ACCOUNT_CD          => p_cur_ref_ins.cr_account_cd,
                                     X_REFUND_AMOUNT          => igs_fi_gen_gl.get_formatted_amount(p_cur_ref_ins.refund_amount),
                                     X_FEE_TYPE               => p_cur_ref_ins.fee_type,
                                     X_FEE_CAL_TYPE           => p_cur_ref_ins.fee_cal_type,
                                     X_FEE_CI_SEQUENCE_NUMBER => p_cur_ref_ins.fee_ci_sequence_number,
                                     X_SOURCE_REFUND_ID       => p_cur_ref_ins.source_refund_id,
                                     X_INVOICE_ID             => p_cur_ref_ins.invoice_id,
                                     X_REASON                 => p_cur_ref_ins.reason,
                                     X_ATTRIBUTE_CATEGORY     => p_cur_ref_ins.attribute_category,
                                     X_ATTRIBUTE1             => p_cur_ref_ins.attribute1,
                                     X_ATTRIBUTE2             => p_cur_ref_ins.attribute2,
                                     X_ATTRIBUTE3             => p_cur_ref_ins.attribute3,
                                     X_ATTRIBUTE4             => p_cur_ref_ins.attribute4,
                                     X_ATTRIBUTE5             => p_cur_ref_ins.attribute5,
                                     X_ATTRIBUTE6             => p_cur_ref_ins.attribute6,
                                     X_ATTRIBUTE7             => p_cur_ref_ins.attribute7,
                                     X_ATTRIBUTE8             => p_cur_ref_ins.attribute8,
                                     X_ATTRIBUTE9             => p_cur_ref_ins.attribute9,
                                     X_ATTRIBUTE10            => p_cur_ref_ins.attribute10,
                                     X_ATTRIBUTE11            => p_cur_ref_ins.attribute11,
                                     X_ATTRIBUTE12            => p_cur_ref_ins.attribute12,
                                     X_ATTRIBUTE13            => p_cur_ref_ins.attribute13,
                                     X_ATTRIBUTE14            => p_cur_ref_ins.attribute14,
                                     X_ATTRIBUTE15            => p_cur_ref_ins.attribute15,
                                     X_ATTRIBUTE16            => p_cur_ref_ins.attribute16,
                                     X_ATTRIBUTE17            => p_cur_ref_ins.attribute17,
                                     X_ATTRIBUTE18            => p_cur_ref_ins.attribute18,
                                     X_ATTRIBUTE19            => p_cur_ref_ins.attribute19,
                                     X_ATTRIBUTE20            => p_cur_ref_ins.attribute20,
                                     X_MODE                   => 'R',
				     X_GL_DATE                => p_cur_ref_ins.gl_date
                                   );

EXCEPTION
  WHEN OTHERS THEN
    p_dml_status:=FALSE;
    p_err_msg:=FND_MESSAGE.GET;
    --If any unexpected event occured , other than what is expected from TBH, say ORA errors , then
    -- return that
    IF p_err_msg IS NULL THEN
      p_err_msg:=sqlerrm;
    END IF;
END insert_interface;

PROCEDURE transfer_int_rec(p_person_id  igs_pe_person.person_id%TYPE,
                           p_test_run   igs_lookups_view.lookup_code%TYPE,
                           p_start_date igs_fi_refunds.voucher_date%TYPE,
                           p_end_date   igs_fi_refunds.voucher_date%TYPE) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2001
  Purpose        :  To Transfer refunds records to interface table and to update the status
                    of the refund record accordingly.
  Known limitations,enhancements,remarks:
  Change History
  Who         When           What
  pathipat    12-May-2003    Enh 2831569 - Commercial Receivables build
                             Added flag (g_b_data_found) to keep track of no-data-found conditions
  pathipat    18-Feb-2003    Enh 2747329 - Payables Intg build
                             The status for Reversed Refund record and its Source is set to Offset
                             instead of Transferred
  agairola    16-May-2002    Modified the cursor cur_check and cur_ref removing FOR UPDATE clause
                             Also made individual calls to Log_Person in case the Refunds table
                             is updated for bug 2374103
********************************************************************************************** */

  CURSOR  cur_check(cp_refund_id  igs_fi_refunds.refund_id%TYPE) IS
  SELECT  r.*,r.rowid
  FROM    igs_fi_refunds r
  WHERE   refund_id = cp_refund_id
  AND     NVL(reversal_ind,'N') = 'Y';
  l_cur_check    cur_check%ROWTYPE;

  l_status      BOOLEAN;
  l_err_msg     fnd_new_messages.message_text%TYPE;

BEGIN

  --The below loop is for all those records which has been reversed.
  FOR l_cur_ref IN cur_ref(p_person_id,p_start_date,p_end_date) LOOP

    g_b_data_found := TRUE;

    OPEN cur_check(l_cur_ref.source_refund_id);
    FETCH cur_check INTO l_cur_check;
    CLOSE cur_check;
    l_status:=TRUE;
    l_err_msg:=NULL;

    IF l_cur_check.transfer_status = g_todo THEN

      -- Update the refunds record
      -- If the record is a Reversed Refund record, then set status to Offset for that record and for the
      -- Source Refund record. These 2 records will not be transferred to the Interface table, hence the status of Offset.
      update_refunds(g_v_offset, l_cur_ref,l_status,l_err_msg);

      log_person(p_person_id       => l_cur_ref.person_id,
                 p_invoice_id      => l_cur_ref.invoice_id,
                 p_refund_id       => l_cur_ref.refund_id,
                 p_pay_person_id   => l_cur_ref.pay_person_id,
                 p_fee_type        => l_cur_ref.fee_type,
                 p_fee_cal_type    => l_cur_ref.fee_cal_type,
                 p_sequence_number => l_cur_ref.fee_ci_sequence_number,
                 p_reversal_ind    => l_cur_ref.reversal_ind,
                 p_rec_status      => g_v_offset,
                 p_err_msg         => l_err_msg,
                 p_status          => l_status );

      IF l_status THEN
        -- Update the parent refund record (Source refund record)
        -- Set status to Offset, instead of Transferred
        update_refunds(g_v_offset, l_cur_check,l_status,l_err_msg);

        log_person(p_person_id       => l_cur_check.person_id,
                   p_invoice_id      => l_cur_check.invoice_id,
                   p_refund_id       => l_cur_check.refund_id,
                   p_pay_person_id   => l_cur_check.pay_person_id,
                   p_fee_type        => l_cur_check.fee_type,
                   p_fee_cal_type    => l_cur_check.fee_cal_type,
                   p_sequence_number => l_cur_check.fee_ci_sequence_number,
                   p_reversal_ind    => l_cur_check.reversal_ind,
                   p_rec_status      => g_v_offset,
                   p_err_msg         => l_err_msg,
                   p_status          => l_status );
      END IF;
    ELSIF l_cur_check.transfer_status = g_transferred THEN
      --Insert in the interface table
      insert_interface(l_cur_ref,l_status,l_err_msg);
      IF l_status THEN
        --Update the refunds record
        update_refunds(g_transferred, l_cur_ref,l_status,l_err_msg);
      END IF;
      log_person(p_person_id       => l_cur_ref.person_id,
                 p_invoice_id      => l_cur_ref.invoice_id,
                 p_refund_id       => l_cur_ref.refund_id,
                 p_pay_person_id   => l_cur_ref.pay_person_id,
                 p_fee_type        => l_cur_ref.fee_type,
                 p_fee_cal_type    => l_cur_ref.fee_cal_type,
                 p_sequence_number => l_cur_ref.fee_ci_sequence_number,
                 p_reversal_ind    => l_cur_ref.reversal_ind,
                 p_rec_status      => g_transferred,
                 p_err_msg         => l_err_msg,
                 p_status          => l_status );
    END IF;


    --Commit the transaction if test run is set to false and above operations
    --are succcessful else rollback the transaction
    IF ((p_test_run='N') AND (l_status=TRUE)) THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;

  END LOOP;

  --The below loop is for all those records which has not been reversed.
  FOR l_cur_refund IN cur_refund(p_person_id,p_start_date,p_end_date) LOOP

    g_b_data_found := TRUE;

    l_status:=TRUE;
    l_err_msg:=NULL;
    --Insert in the interface table
    insert_interface(l_cur_refund,l_status,l_err_msg);
    IF l_status THEN
      --Update the refunds record
      update_refunds(g_transferred, l_cur_refund,l_status,l_err_msg);
    END IF;

    --Logging the record information
    log_person(p_person_id       => l_cur_refund.person_id,
               p_invoice_id      => l_cur_refund.invoice_id,
               p_refund_id       => l_cur_refund.refund_id,
               p_pay_person_id   => l_cur_refund.pay_person_id,
               p_fee_type        => l_cur_refund.fee_type,
               p_fee_cal_type    => l_cur_refund.fee_cal_type,
               p_sequence_number => l_cur_refund.fee_ci_sequence_number,
               p_reversal_ind    => l_cur_refund.reversal_ind,
               p_rec_status      => g_transferred,
               p_err_msg         => l_err_msg,
               p_status          => l_status );


    --Commit the transaction if test run is set to false and above operations
    --are succcessful else rollback the transaction
    IF ((p_test_run='N') AND (l_status=TRUE)) THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  END LOOP;


END transfer_int_rec;

PROCEDURE    transfer_to_int( errbuf             OUT NOCOPY   VARCHAR2,
                              retcode            OUT NOCOPY   NUMBER,
                              p_person_id        IN    igs_pe_person.person_id%TYPE,
                              p_person_id_grp    IN    igs_pe_persid_group.group_id%TYPE,
                              p_start_date       IN    VARCHAR2,
                              p_end_date         IN    VARCHAR2,
                              p_test_run         IN    igs_lookups_view.lookup_code%TYPE) AS
/***********************************************************************************************
  Created By     :  Sarakshi
  Date Created By:  1-Mar-2001
  Purpose        :  To Transfer refunds records to interface table and to update the status
                    of the refund record accordingly.
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  sapanigr  14-Feb-2006  Bug #5018036. Cursor cur_pers modified to query hz_parties instead of igs_fi_parties_v
  ridas     13-Feb-2006  Bug #5021084. Added new parameter lv_group_type in call to igf_ap_ss_pkg.get_pid
  pathipat  23-Apr-2003  Enh 2831569 - Commercial Receivables build
                         Added validation for manage_account - call to chk_manage_account()
                         Added code to log messages for test run = Y and for no-data-found cases
                         Increased width of l_v_sql_query from 1000 to 32767
  pathipat  18-Feb-2003  Enh 2747329 - Payables Intg build
                         1. Modified cursor cur_pers_grp - used igs_pe_all_persid_group_v instead of igs_pe_persid_group
                            Changed declaration of l_group_code accordingly.
                         2. Added validation to check for Refunds Destination before allowing the process to be run
                         3. Modified approach to identify persons in a person id group
  vvutukur  03-Jan-2003  Bug#2727216.Modified the logic for logging the parameters, by removing the
                         redundant code.
  vchappid  13-Jun-2002  Bug#2411529, Incorrectly used message name has been modified
 ********************************************************************************************** */
  CURSOR cur_pers(cp_person_id hz_parties.party_id%TYPE) IS
  SELECT party_number
  FROM   hz_parties
  WHERE  party_id=cp_person_id;
  l_cur_pers   cur_pers%ROWTYPE;

  -- Cursor for validating Person Id Group
  CURSOR cur_pers_grp IS
  SELECT group_cd
  FROM   igs_pe_all_persid_group_v
  WHERE  group_id = p_person_id_grp
  AND    closed_ind = 'N';

  l_group_code   igs_pe_all_persid_group_v.group_cd%TYPE;

  -- Ref cursor used to execute the dynamic sql query for
  -- identifying persons in a Person Id Group
  TYPE  person_group_ref IS REF CURSOR;
  cur_person_grp_ref    person_group_ref;

  -- The variable l_cur_person_grp_rec is used to hold the values
  -- fetched by the ref cursor
  TYPE person_group_rec IS RECORD ( p_n_person_id  igs_pe_prsid_grp_mem.person_id%TYPE);
  l_cur_person_grp_rec  person_group_rec;

  -- Variable to hold the dynamic sql query to identify persons
  -- in a Person Id Group
  l_v_sql_query           VARCHAR2(32767) := NULL;

  -- Out variable to be passed to function returning sql query
  l_v_status              VARCHAR2(30) := NULL;

  -- Variable to hold value of rfnd_destination in igs_fi_control
  l_v_rfnd_destination    igs_fi_control_all.rfnd_destination%TYPE;

  l_start_date   DATE :=NULL;
  l_end_date     DATE :=NULL;

  l_pers_valid   BOOLEAN := TRUE;
  l_pers_id_grp  BOOLEAN := TRUE;
  l_valid_param  BOOLEAN := TRUE;

  l_v_manage_acc     igs_fi_control_all.manage_accounts%TYPE := NULL;
  l_v_message_name   fnd_new_messages.message_name%TYPE      := NULL;
  lv_group_type      igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  -- initialises the out parameter to 0
  retcode := 0;
  --  sets the orgid
  IGS_GE_GEN_003.set_org_id(NULL);

  --Get the party number for the input party id, if passed and check if it is valid.
  IF p_person_id IS NOT NULL THEN
    OPEN cur_pers(p_person_id);
    FETCH cur_pers INTO l_cur_pers;
    IF cur_pers%NOTFOUND THEN
      l_pers_valid := FALSE;
    END IF;
    CLOSE cur_pers;
  END IF;

  -- Get the group code for input person id group, if passed and check if it is valid.
  IF p_person_id_grp IS NOT NULL THEN
    OPEN cur_pers_grp;
    FETCH cur_pers_grp INTO l_group_code;
    IF cur_pers_grp%NOTFOUND THEN
      l_pers_id_grp := FALSE;
    END IF;
    CLOSE cur_pers_grp;
  END IF;

  --converting the Start Date and End Date to Date format from Canonical Format.
  IF p_start_date IS NOT NULL THEN
    l_start_date:=igs_ge_date.igsdate(p_start_date);
  END IF;
  IF p_end_date IS NOT NULL THEN
    l_end_date:=igs_ge_date.igsdate(p_end_date);
  END IF;

  --Logging all the parameters passed to the concurrent program.
  log_messages(lookup_desc('IGS_FI_LOCKBOX','PERSON'),NVL(l_cur_pers.party_number,p_person_id));
  IF ( p_person_id_grp IS NOT NULL ) THEN
    log_messages(lookup_desc('IGS_FI_LOCKBOX','PERSON_GROUP'),l_group_code||'('||TO_CHAR(p_person_id_grp)||')');
  ELSE
    log_messages(lookup_desc('IGS_FI_LOCKBOX','PERSON_GROUP'),TO_CHAR(p_person_id_grp));
  END IF;
  log_messages(lookup_desc('IGS_FI_LOCKBOX','START_DT'),l_start_date);
  log_messages(lookup_desc('IGS_FI_LOCKBOX','END_DT'),l_end_date);
  log_messages(lookup_desc('IGS_FI_LOCKBOX','TEST_MODE'),lookup_desc('VS_AS_YN',p_test_run));


  -- Obtain the value of manage_accounts in the System Options form
  -- If it is null or 'OTHER', then this process is not available, so error out.
  igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                               p_v_message_name => l_v_message_name
                                             );
  IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
    fnd_message.set_name('IGS',l_v_message_name);
    igs_ge_msg_stack.add;
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(fnd_file.log,' ');
    retcode := 2;
    RETURN;
  END IF;

  -- If Refund destination is 'Payables' or Null, then this process is not available.
  -- The Refund destination set in igs_fi_control has to be 'Other' for this process to be run.
  l_v_rfnd_destination := igs_fi_gen_apint.get_rfnd_destination;

  IF (l_v_rfnd_destination = 'PAYABLES') OR (l_v_rfnd_destination IS NULL) THEN
     fnd_message.set_name('IGS','IGS_FI_RFND_DST_OTH');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     retcode := 2;
     RETURN;
  END IF;

  --Validates if both person_id and person id group is passed
  IF ((p_person_id IS NOT NULL) AND (p_person_id_grp IS NOT NULL)) THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
    IGS_GE_MSG_STACK.ADD;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    l_valid_param := FALSE;
  END IF;

  IF NOT l_pers_valid THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PERSON');
    FND_MESSAGE.SET_TOKEN('PERSON_ID',TO_CHAR(p_person_id));
    IGS_GE_MSG_STACK.ADD;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    l_valid_param := FALSE;
  END IF;

  IF NOT l_pers_id_grp THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVPERS_ID_GRP');
    IGS_GE_MSG_STACK.ADD;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    l_valid_param := FALSE;
  END IF;

  --Validates if start date is less than end date
  IF ((p_start_date IS NOT NULL) AND (p_end_date IS NOT NULL)) THEN
    IF l_start_date > l_end_date THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
      IGS_GE_MSG_STACK.ADD;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      l_valid_param := FALSE;
    END IF;
  END IF;

  IF NOT l_valid_param THEN
    retcode := 2;
    RETURN;
  END IF;

 IF p_person_id_grp IS NOT NULL THEN

      -- The persons belonging to the person_id group are obtained dynamically
      -- The following function returns the sql query which would identify the persons
      --Bug #5021084
      l_v_sql_query := igf_ap_ss_pkg.get_pid( p_person_id_grp,
                                              l_v_status,
                                              lv_group_type
                                            );

      -- Using ref cursor, the sql above is executed and the persons identified
      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN cur_person_grp_ref FOR l_v_sql_query USING p_person_id_grp;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN cur_person_grp_ref FOR l_v_sql_query;
      END IF;

      LOOP
         FETCH cur_person_grp_ref INTO l_cur_person_grp_rec;
         EXIT WHEN cur_person_grp_ref%NOTFOUND;
         -- Invoking the below procedure for transfering records in refunds interface table
         -- when either person_id or person_id_group is provided
         transfer_int_rec( p_person_id      => l_cur_person_grp_rec.p_n_person_id,
                           p_test_run       => p_test_run,
                           p_start_date     => l_start_date,
                           p_end_date       => l_end_date);
      END LOOP;
      CLOSE cur_person_grp_ref;

  -- If a particular person has been specified, or Person ID/Person ID group are both null
  ELSE
       transfer_int_rec(p_person_id      => p_person_id,
                        p_test_run       => p_test_run,
                        p_start_date     => l_start_date,
                        p_end_date       => l_end_date);

  END IF;

  -- Log message if no data found for processing
  IF (NOT g_b_data_found) THEN
     fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     fnd_file.new_line(fnd_file.log);
  END IF;

  -- If run in test mode = Y and records have been processed,
  -- log message saying transactions have been rolled back
  IF (p_test_run = 'Y') AND (g_b_data_found = TRUE) THEN
     fnd_message.set_name('IGS','IGS_FI_PRC_TEST_RUN');
     igs_ge_msg_stack.add;
     fnd_file.new_line(fnd_file.log);
     fnd_file.put_line(fnd_file.log,fnd_message.get);
  END IF;

EXCEPTION
  WHEN e_resource_busy THEN
    retcode := 2;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_FI_RFND_REC_LOCK'));
  WHEN OTHERS THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')||':'||sqlerrm;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
END transfer_to_int;



PROCEDURE update_pay_info   ( errbuf               OUT NOCOPY   VARCHAR2,
                              retcode              OUT NOCOPY   NUMBER,
                              p_person_id          IN    igs_fi_parties_v.person_id%TYPE,
                              p_person_id_group    IN    igs_pe_persid_group.group_id%TYPE,
                              p_start_date         IN    VARCHAR2,
                              p_end_date           IN    VARCHAR2,
                              p_test_run           IN    igs_lookups_view.lookup_code%TYPE)
AS
/***********************************************************************************************
  Created By     :  vchappid
  Date Created By:  04-MAR-2001
  Purpose        :  Concurrent Manager Procedure for updating the payment information for the
                    Refunds transactions
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  vchappid   03-Jul-2002   Bug# 2442030, Concurrent Process is obsoleted, and hence nullified the code
  vchappid   13-Jun-2002   Bug#2411529, Incorrectly used message name has been modified
  agairola   16-May-2002   Moidified the cursor cur_refunds to remove FOR UPDATE clause

********************************************************************************************** */

BEGIN
  --Bug# 2442030, Concurrent Process is obsoleted, and hence nullified the code
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;
EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    FND_MESSAGE.Set_Name('IGS',
                         'IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.Add;
    APP_EXCEPTION.Raise_Exception;
END update_pay_info;

END igs_fi_refunds_process;

/
