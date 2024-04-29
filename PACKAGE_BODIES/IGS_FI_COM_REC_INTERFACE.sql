--------------------------------------------------------
--  DDL for Package Body IGS_FI_COM_REC_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_COM_REC_INTERFACE" AS
/* $Header: IGSFI81B.pls 120.2 2006/05/04 07:45:15 abshriva noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_COM_REC_INTERFACE                |
 |                                                                       |
 | NOTES                                                                 |
 | New Package created for procedures and functions as per               |
 | Commercial Receivables TD.  (Enh 2831569)                             |
 | HISTORY                                                               |
 | Who             When            What                                  |
 |abshriva   4-May-2006 Bug 5178077: Modification in procedure Transfer  |
 | svuppala      30-MAY-2005       Enh 3442712 - Done the TBH            |
 |                                 modifications by adding new columns   |
 |                                 Unit_Type_Id, Unit_Level in           |
 |                                 igs_fi_invln_int_all                  |
 | pathipat        22-Apr-2004     Enh 3558549 - Comm Rec Enh build      |
 |                                 Added 2 new cols to igs_fi_com_recs_int
 |                                 Modified transfer() for the above     |
 |uudayapr     16-oct-2003   Enh #3117341 Modified the  cur_charges in   |
 |                             Transfer procedure as a part of AUDIT and |
 |                           SPECIAL FEES BUILD.                         |
 *=======================================================================*/


g_b_data_found            BOOLEAN      := FALSE;

g_v_space       CONSTANT  VARCHAR2(10) := '       ';   -- Constant 7 char space used in logging messages in log file.
g_v_tutnfee     CONSTANT  VARCHAR2(20) := 'TUTNFEE';
g_v_other       CONSTANT  VARCHAR2(20) := 'OTHER';
g_v_external    CONSTANT  VARCHAR2(20) := 'EXTERNAL';
g_v_ancillary   CONSTANT  VARCHAR2(20) := 'ANCILLARY';
g_v_sponsor     CONSTANT  VARCHAR2(20) := 'SPONSOR';
g_v_aid_adj     CONSTANT  VARCHAR2(20) := 'AID_ADJ';
g_v_document    CONSTANT  VARCHAR2(20) := 'DOCUMENT';

-- Constant variables for Credit Classes SPNSP and CHGADJ
g_v_spnsp       CONSTANT  VARCHAR2(7) := 'SPNSP';
g_v_chgadj      CONSTANT  VARCHAR2(7) := 'CHGADJ';

--Added the constant variable for AUDIT and SPECIAL FEE TYPE CATEGORY.
g_v_audit       CONSTANT  VARCHAR2(20) := 'AUDIT';
g_v_special     CONSTANT  VARCHAR2(20) := 'SPECIAL';


PROCEDURE chk_manage_account( p_v_manage_acc       OUT NOCOPY VARCHAR2,
                              p_v_message_name     OUT NOCOPY VARCHAR2
                             )  AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 10-APR-2003
  --
  --Purpose: Procedure returns value of MANAGE_ACCOUNTS column in
  --         IGS_FI_CONTROL_ALL
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------

  CURSOR cur_manage_acct IS
    SELECT manage_accounts
    FROM igs_fi_control_all;

  BEGIN

     OPEN cur_manage_acct;
     FETCH cur_manage_acct INTO p_v_manage_acc;
     IF cur_manage_acct%NOTFOUND THEN
        p_v_manage_acc := NULL;
        p_v_message_name := 'IGS_FI_SYSTEM_OPT_SETUP';
        RETURN;
     END IF;
     CLOSE cur_manage_acct;

     -- If manage_accounts is NULL
     IF (p_v_manage_acc IS NULL) THEN
        p_v_message_name := 'IGS_FI_MANAGE_ACC_NULL';
        RETURN;
     -- If manage_accounts is OTHER
     ELSIF (p_v_manage_acc = 'OTHER') THEN
        p_v_message_name := 'IGS_FI_MANAGE_ACC_OTH';
        RETURN;
     -- If manage_Accounts is STUDENT_FINANCE
     ELSIF (p_v_manage_acc = 'STUDENT_FINANCE') THEN
        p_v_message_name := NULL;
        RETURN;
     END IF;

  END chk_manage_account;


FUNCTION get_party_number(p_party_id   IN  hz_parties.party_id%TYPE) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 21-APR-2003
  --
  --Purpose: Function returning party_number for the passed party_id
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_get_party(cp_party_id  hz_parties.party_id%TYPE) IS
    SELECT party_number
    FROM   hz_parties
    WHERE  party_id = cp_party_id;

  l_v_party_number      hz_parties.party_number%TYPE := NULL;

BEGIN

  -- Obtain the party_number corresponding to the party_id passed
  OPEN cur_get_party(p_party_id);
  FETCH cur_get_party INTO l_v_party_number;
  CLOSE cur_get_party;

  RETURN l_v_party_number;

END get_party_number;


PROCEDURE transfer(errbuf                OUT NOCOPY VARCHAR2,
                   retcode               OUT NOCOPY NUMBER
                  ) AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 21-APR-2003
  --
  --Purpose: Concurrent program to Transfer data to Commercial Receivables
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva   4-May-2006       Bug 5178077: Introduced igs_ge_gen_003.set_org_id
  --svuppala   30-MAY-2005      Enh 3442712 - Done the TBH modifications by adding
  --                            new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all
  --pathipat    22-Apr-2004     Enh 3558549 - Comm Rec Enh build
  --                            Added code w.r.t new columns student_party_id and
  --                            source_invoice_id in igs_fi_com_recs_int
  --uudayapr   16-oct-2003    Enh#3117341 Modified cur_charges cursor as a part
  --                          of audit and special fees built.
  -------------------------------------------------------------------

  CURSOR cur_charges IS
    SELECT inv.person_id,
           inv.fee_type,
           inv.course_cd,
           inv.invoice_creation_date,
           inv.fee_cat,
           inv.fee_ci_sequence_number,
           inv.fee_cal_type,
           inv.effective_date,
           inv.waiver_flag,
           inv.waiver_reason,
           inv.attendance_type,
           inv.attendance_mode,
           inv.currency_cd,
           inv.invoice_amount   charge_amount,
           inv.invoice_number   charge_number,
           ft.s_fee_type,
           invln.row_id invln_rowid,
           invln.*
    FROM   igs_fi_inv_int inv,
           igs_fi_invln_int invln,
           igs_fi_fee_type ft
    WHERE inv.invoice_id = invln.invoice_id
    AND   inv.fee_type = ft.fee_type
    AND   ft.s_fee_type IN (g_v_tutnfee,g_v_other,g_v_external,
                            g_v_ancillary,g_v_sponsor,g_v_aid_adj,g_v_document,
                            g_v_audit,g_v_special) -- Added audit and special fees.
    AND   invln.gl_posted_date IS NULL
    ORDER BY inv.person_id, ft.s_fee_type, inv.invoice_number
    FOR UPDATE OF invln.gl_posted_date NOWAIT;

  CURSOR cur_credits IS
    SELECT crd.credit_id cr_id,
           crd.credit_number,
           crd.party_id,
           crd.transaction_date trans_date,
           crd.effective_date,
           crd.fee_cal_type,
           crd.fee_ci_sequence_number,
           crd.currency_cd,
           crd.description,
           crd.credit_type_id,
           crd.source_invoice_id,
           cra.*,
           cra.rowid  cra_rowid,
           crt.credit_class
    FROM   igs_fi_credits crd,
           igs_fi_cr_activities cra,
           igs_fi_cr_types crt
    WHERE  crd.credit_id = cra.credit_id
    AND    crd.credit_type_id = crt.credit_type_id
    AND    crt.credit_class IN (g_v_chgadj, g_v_spnsp)
    AND    cra.gl_posted_date IS NULL
    FOR UPDATE OF cra.gl_posted_date NOWAIT;

  CURSOR cur_course_desc(cp_course_cd  igs_ps_ver.course_cd%TYPE) IS
    SELECT title
    FROM igs_ps_ver
    WHERE course_cd = cp_course_cd;

  -- Returns the party_id from Credits table corresponding to the charge denoted by
  -- the SOURCE_INVOICE_ID column.
  CURSOR cur_chg_stdnt_party(cp_invoice_id    igs_fi_inv_int_all.invoice_id%TYPE) IS
    SELECT party_id
    FROM igs_fi_credits
    WHERE source_invoice_id = cp_invoice_id;

  -- Returns the party_id from Charges Table correponding to the value in  Source_invoice_id
  -- column of the Credits Table of type Aid Adjustment
  CURSOR cur_credit_stdnt_party(cp_source_invoice_id    igs_fi_credits_all.source_invoice_id%TYPE) IS
    SELECT person_id
    FROM igs_fi_inv_int
    WHERE invoice_id =  cp_source_invoice_id
    AND transaction_type = g_v_aid_adj;

  l_v_title             igs_ps_ver.title%TYPE := NULL;

  l_v_manage_acc        igs_fi_control_all.manage_accounts%TYPE := NULL;
  l_v_message_name      fnd_new_messages.message_name%TYPE  := NULL;

  l_v_party             igs_lookup_values.meaning%TYPE := NULL;
  l_v_charge_number     igs_lookup_values.meaning%TYPE := NULL;
  l_v_s_fee_type        igs_lookup_values.meaning%TYPE := NULL;
  l_v_fee_type          igs_lookup_values.meaning%TYPE := NULL;
  l_v_charge_amt        igs_lookup_values.meaning%TYPE := NULL;
  l_v_credit_number     igs_lookup_values.meaning%TYPE := NULL;

  l_n_last_person_id    hz_parties.party_id%TYPE := NULL;
  l_org_id              VARCHAR2(15);
  l_rowid               ROWID  := NULL;

  skip_record           EXCEPTION;
  e_resource_busy       EXCEPTION;

  PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

  l_n_chg_stdnt_party       igs_fi_credits_all.party_id%TYPE;
  l_n_credit_stdnt_party    igs_fi_inv_int_all.person_id%TYPE;

BEGIN
  BEGIN
     l_org_id := NULL;
     igs_ge_gen_003.set_org_id(l_org_id);
  EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line (fnd_file.log, fnd_message.get);
       retcode:=2;
       RETURN;
  END;
   retcode := 0;
   errbuf  := NULL;

   -- Step 1:
   -- Call the generic proc to obtain the Manage Accounts set up
   -- in the System Options form.
   chk_manage_account(l_v_manage_acc,
                      l_v_message_name);

   -- If Manage Accounts <> 'Other' then this process is not available.
   IF (l_v_manage_acc <> 'OTHER') OR (l_v_manage_acc IS NULL) THEN
      fnd_message.set_name('IGS','IGS_FI_MANAGE_ACC_PRC_OTH');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.new_line(fnd_file.log);
      retcode := 2;
      RETURN;
   END IF;

   -- This message is always logged irrespective of error records being found or not
   fnd_message.set_name('IGS','IGS_FI_LOG_ERR_TRX');
   fnd_file.put_line(fnd_file.log,fnd_message.get());
   fnd_file.put_line(FND_FILE.LOG,' ');

   -- Obtain the meaning of the lookup codes to log the details.
   l_v_party         := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PARTY');
   l_v_charge_number := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CHARGE_NUMBER');
   l_v_s_fee_type    := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','SYSTEM_FEE_TYPE');
   l_v_fee_type      := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE');
   l_v_charge_amt    := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CHG_AMOUNT');
   l_v_credit_number := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_NUMBER');

   -- Step 2: Loop across all the transactions in the Charges table (cur_charges)
   FOR l_rec_charges IN cur_charges
      LOOP
        BEGIN

         SAVEPOINT sp_charges;

         -- Step 3: If Error Account of record is 'Y' then log the person details
         --         and skip the record. Move to the next record fetched.
         IF l_rec_charges.error_account = 'Y' THEN
            g_b_data_found := TRUE;
            -- Log Person Number only once for a given person
            IF l_n_last_person_id = l_rec_charges.person_id THEN
               NULL;
            ELSE
               -- Log the details of the party with error_account = 'Y'
               fnd_file.put_line(fnd_file.log,l_v_party||': '||get_party_number(l_rec_charges.person_id));
               l_n_last_person_id := l_rec_charges.person_id;
            END IF;

            fnd_file.put_line(fnd_file.log,g_v_space ||l_v_charge_number||': '||l_rec_charges.charge_number);
            fnd_file.put_line(fnd_file.log,g_v_space ||l_v_s_fee_type   ||': '||l_rec_charges.s_fee_type);
            fnd_file.put_line(fnd_file.log,g_v_space ||l_v_fee_type     ||': '||l_rec_charges.fee_type);
            fnd_file.put_line(fnd_file.log,g_v_space ||l_v_charge_amt   ||': '||l_rec_charges.charge_amount);
            fnd_file.new_line(fnd_file.log);

            -- Skip the record and move to the next record from Step 2
            RAISE skip_record;

         END IF;   -- End IF for error_account = 'Y'

         -- Processing for Error Account = 'N'
         l_rowid := NULL;
         -- Obtain the Description corresponding to the Course_Cd
         OPEN cur_course_desc(l_rec_charges.course_cd);
         FETCH cur_course_desc INTO l_v_title;
         CLOSE cur_course_desc;

         -- Obtain value to be inserted into Student Party ID column
         IF l_rec_charges.s_fee_type = g_v_sponsor THEN
            OPEN cur_chg_stdnt_party(l_rec_charges.invoice_id);
            FETCH cur_chg_stdnt_party INTO l_n_chg_stdnt_party;
            CLOSE cur_chg_stdnt_party;
         ELSE
            l_n_chg_stdnt_party := NULL;
         END IF;

         -- Step 4: If Error Account = N, then insert the record into IGS_FI_COM_RECS_INT table
         igs_fi_com_recs_int_pkg.insert_row ( x_rowid                                   => l_rowid ,
                                              x_transaction_category                    => 'CHARGE' ,
                                              x_transaction_header_id                   => l_rec_charges.invoice_id ,
                                              x_transaction_number                      => l_rec_charges.charge_number ,
                                              x_party_id                                => l_rec_charges.person_id ,
                                              x_transaction_date                        => l_rec_charges.invoice_creation_date ,
                                              x_effective_date                          => l_rec_charges.effective_date ,
                                              x_fee_type                                => l_rec_charges.fee_type ,
                                              x_s_fee_type                              => l_rec_charges.s_fee_type ,
                                              x_fee_cal_type                            => l_rec_charges.fee_cal_type ,
                                              x_fee_ci_sequence_number                  => l_rec_charges.fee_ci_sequence_number ,
                                              x_fee_category                            => l_rec_charges.fee_cat ,
                                              x_course_cd                               => l_rec_charges.course_cd ,
                                              x_attendance_mode                         => l_rec_charges.attendance_mode ,
                                              x_attendance_type                         => l_rec_charges.attendance_type ,
                                              x_course_description                      => l_v_title ,
                                              x_reversal_flag                           => l_rec_charges.waiver_flag,
                                              x_reversal_reason                         => l_rec_charges.waiver_reason,
                                              x_line_number                             => l_rec_charges.line_number,
                                              x_transaction_line_id                     => l_rec_charges.invoice_lines_id,
                                              x_charge_method_type                      => l_rec_charges.s_chg_method_type,
                                              x_description                             => l_rec_charges.description,
                                              x_charge_elements                         => l_rec_charges.chg_elements,
                                              x_amount                                  => l_rec_charges.amount,
                                              x_credit_points                           => l_rec_charges.credit_points,
                                              x_unit_offering_option_id                 => l_rec_charges.uoo_id,
                                              x_cr_gl_code_combination_id               => l_rec_charges.rev_gl_ccid,
                                              x_dr_gl_code_combination_id               => l_rec_charges.rec_gl_ccid,
                                              x_credit_account_code                     => l_rec_charges.rev_account_cd,
                                              x_debit_account_code                      => l_rec_charges.rec_account_cd,
                                              x_org_unit_cd                             => l_rec_charges.org_unit_cd,
                                              x_location_cd                             => l_rec_charges.location_cd,
                                              x_gl_date                                 => l_rec_charges.gl_date,
                                              x_credit_type_id                          => NULL,
                                              x_credit_class                            => NULL,
                                              x_currency_cd                             => l_rec_charges.currency_cd,
                                              x_extract_flag                            => NULL,
                                              x_mode                                    => 'R',
                                              x_student_party_id                        => l_n_chg_stdnt_party,
                                              x_source_invoice_id                       => NULL
                                              );

         -- Step 5: For every record inserted into the Receivables interface table,
         --         update the record in IGS_FI_INVLN_INT - set gl_posted_date to sysdate
         igs_fi_invln_int_pkg.update_row( x_rowid                        => l_rec_charges.invln_rowid,
                                          x_invoice_id                   => l_rec_charges.invoice_id,
                                          x_line_number                  => l_rec_charges.line_number,
                                          x_invoice_lines_id             => l_rec_charges.invoice_lines_id,
                                          x_attribute2                   => l_rec_charges.attribute2,
                                          x_chg_elements                 => l_rec_charges.chg_elements,
                                          x_amount                       => l_rec_charges.amount,
                                          x_unit_attempt_status          => l_rec_charges.unit_attempt_status,
                                          x_eftsu                        => l_rec_charges.eftsu,
                                          x_credit_points                => l_rec_charges.credit_points,
                                          x_attribute_category           => l_rec_charges.attribute_category,
                                          x_attribute1                   => l_rec_charges.attribute1,
                                          x_s_chg_method_type            => l_rec_charges.s_chg_method_type,
                                          x_description                  => l_rec_charges.description,
                                          x_attribute3                   => l_rec_charges.attribute3,
                                          x_attribute4                   => l_rec_charges.attribute4,
                                          x_attribute5                   => l_rec_charges.attribute5,
                                          x_attribute6                   => l_rec_charges.attribute6,
                                          x_attribute7                   => l_rec_charges.attribute7,
                                          x_attribute8                   => l_rec_charges.attribute8,
                                          x_attribute9                   => l_rec_charges.attribute9,
                                          x_attribute10                  => l_rec_charges.attribute10,
                                          x_rec_account_cd               => l_rec_charges.rec_account_cd,
                                          x_rev_account_cd               => l_rec_charges.rev_account_cd,
                                          x_rec_gl_ccid                  => l_rec_charges.rec_gl_ccid,
                                          x_rev_gl_ccid                  => l_rec_charges.rev_gl_ccid,
                                          x_org_unit_cd                  => l_rec_charges.org_unit_cd,
                                          x_posting_id                   => l_rec_charges.posting_id,
                                          x_attribute11                  => l_rec_charges.attribute11,
                                          x_attribute12                  => l_rec_charges.attribute12,
                                          x_attribute13                  => l_rec_charges.attribute13,
                                          x_attribute14                  => l_rec_charges.attribute14,
                                          x_attribute15                  => l_rec_charges.attribute15,
                                          x_attribute16                  => l_rec_charges.attribute16,
                                          x_attribute17                  => l_rec_charges.attribute17,
                                          x_attribute18                  => l_rec_charges.attribute18,
                                          x_attribute19                  => l_rec_charges.attribute19,
                                          x_attribute20                  => l_rec_charges.attribute20,
                                          x_error_string                 => l_rec_charges.error_string,
                                          x_error_account                => l_rec_charges.error_account,
                                          x_location_cd                  => l_rec_charges.location_cd,
                                          x_uoo_id                       => l_rec_charges.uoo_id,
                                          x_gl_date                      => l_rec_charges.gl_date,
                                          x_gl_posted_date               => TRUNC(SYSDATE),
                                          x_posting_control_id           => l_rec_charges.posting_control_id,
                                          x_mode                         => 'R' ,
                                          x_unit_type_id                 => l_rec_charges.unit_type_id,
                                          x_unit_level                   => l_rec_charges.unit_level
                                          );

        EXCEPTION
          WHEN skip_record THEN
             -- Process ends with a warning status
             retcode := 1;
             NULL;
          WHEN OTHERS THEN
             -- Record with some error encountered, so set flag to TRUE
             g_b_data_found := TRUE;
             -- Process ends with a warning status
             retcode := 1;
             ROLLBACK TO sp_charges;
             fnd_file.put_line(fnd_file.log,l_v_charge_number||' - '||l_rec_charges.invoice_id || ': '||SQLERRM);
             fnd_file.new_line(fnd_file.log);
        END;
      END LOOP;  -- End of Step 2 - Loop across all Charges

      -- Commit transactions after charges are processed
      COMMIT;

   -- Step 6: Loop across all the Credits, i.e., cur_credits
   FOR l_rec_credits IN cur_credits
      LOOP
        BEGIN
           SAVEPOINT sp_credits;
           l_rowid := NULL;

           IF (l_rec_credits.credit_class = g_v_spnsp) THEN
               OPEN cur_credit_stdnt_party(l_rec_credits.source_invoice_id);
               FETCH cur_credit_stdnt_party INTO l_n_credit_stdnt_party;
               CLOSE cur_credit_stdnt_party;
           ELSE
               l_n_credit_stdnt_party := NULL;
           END IF;

           -- Step 7: Insert the credit record into the interface table.
           igs_fi_com_recs_int_pkg.insert_row( x_rowid                                 => l_rowid ,
                                               x_transaction_category                    => 'CREDIT' ,
                                               x_transaction_header_id                   => l_rec_credits.cr_id ,
                                               x_transaction_number                      => l_rec_credits.credit_number ,
                                               x_party_id                                => l_rec_credits.party_id ,
                                               x_transaction_date                        => l_rec_credits.trans_date ,
                                               x_effective_date                          => l_rec_credits.effective_date ,
                                               x_fee_type                                => NULL,
                                               x_s_fee_type                              => NULL,
                                               x_fee_cal_type                            => l_rec_credits.fee_cal_type ,
                                               x_fee_ci_sequence_number                  => l_rec_credits.fee_ci_sequence_number ,
                                               x_fee_category                            => NULL,
                                               x_course_cd                               => NULL,
                                               x_attendance_mode                         => NULL,
                                               x_attendance_type                         => NULL,
                                               x_course_description                      => NULL,
                                               x_reversal_flag                           => NULL,
                                               x_reversal_reason                         => NULL,
                                               x_line_number                             => NULL,
                                               x_transaction_line_id                     => l_rec_credits.credit_activity_id,
                                               x_charge_method_type                      => NULL,
                                               x_description                             => l_rec_credits.description,
                                               x_charge_elements                         => NULL,
                                               x_amount                                  => l_rec_credits.amount,
                                               x_credit_points                           => NULL,
                                               x_unit_offering_option_id                 => NULL,
                                               x_cr_gl_code_combination_id               => l_rec_credits.cr_gl_ccid,
                                               x_dr_gl_code_combination_id               => l_rec_credits.dr_gl_ccid,
                                               x_credit_account_code                     => l_rec_credits.cr_account_cd,
                                               x_debit_account_code                      => l_rec_credits.dr_account_cd,
                                               x_org_unit_cd                             => NULL,
                                               x_location_cd                             => NULL,
                                               x_gl_date                                 => l_rec_credits.gl_date,
                                               x_credit_type_id                          => l_rec_credits.credit_type_id,
                                               x_credit_class                            => l_rec_credits.credit_class,
                                               x_currency_cd                             => l_rec_credits.currency_cd,
                                               x_extract_flag                            => NULL,
                                               x_mode                                    => 'R',
                                               x_student_party_id                        => l_n_credit_stdnt_party,
                                               x_source_invoice_id                       => l_rec_credits.source_invoice_id
                                               );

           -- Step 8: For each record inserted, update gl_posted_Date to sysdate in the Activities table
           igs_fi_cr_activities_pkg.update_row( x_rowid                        => l_rec_credits.cra_rowid,
                                                x_credit_activity_id           => l_rec_credits.credit_activity_id,
                                                x_credit_id                    => l_rec_credits.credit_id,
                                                x_status                       => l_rec_credits.status,
                                                x_transaction_date             => l_rec_credits.transaction_date,
                                                x_amount                       => l_rec_credits.amount,
                                                x_dr_account_cd                => l_rec_credits.dr_account_cd,
                                                x_cr_account_cd                => l_rec_credits.cr_account_cd,
                                                x_dr_gl_ccid                   => l_rec_credits.dr_gl_ccid,
                                                x_cr_gl_ccid                   => l_rec_credits.cr_gl_ccid,
                                                x_bill_id                      => l_rec_credits.bill_id,
                                                x_bill_number                  => l_rec_credits.bill_number,
                                                x_bill_date                    => l_rec_credits.bill_date,
                                                x_posting_id                   => l_rec_credits.posting_id,
                                                x_gl_date                      => l_rec_credits.gl_date,
                                                x_gl_posted_date               => TRUNC(SYSDATE),
                                                x_posting_control_id           => l_rec_credits.posting_control_id,
                                                x_mode                         => 'R'
                                                );

        EXCEPTION
           WHEN OTHERS THEN
              -- Record with some error encountered, so set flag to TRUE
              g_b_data_found := TRUE;
              -- Process ends with a warning status
              retcode := 1;
              fnd_file.put_line(fnd_file.log,l_v_credit_number||' - '||l_rec_credits.credit_id || ': '||SQLERRM);
              fnd_file.new_line(fnd_file.log);
              ROLLBACK TO sp_credits;
        END;

      END LOOP;  -- End of looping across Credits in IGS_FI_CREDITS table (Step 6)

      -- Step 9: If there are no records, log 'No Data Found' in the log file.
      -- This message is logged in 2 cases: (a) No data found for transferring to interface table
      --                                    (b) All the data transferred successfully without any error records

      IF (NOT g_b_data_found) THEN
        fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.put_line(fnd_file.log,' ');
        RETURN;
      END IF;

      -- Step 10: Commit the transactions
      COMMIT;

EXCEPTION
  WHEN e_resource_busy THEN
     fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.new_line(fnd_file.log);
     retcode := 2;

  WHEN OTHERS THEN
     ROLLBACK;
     retcode := 2;
     errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION'||' - '||SQLERRM);
     igs_ge_msg_stack.add;
     igs_ge_msg_stack.conc_exception_hndl;

END transfer;

END igs_fi_com_rec_interface;

/
