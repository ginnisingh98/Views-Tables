--------------------------------------------------------
--  DDL for Package Body IGF_AW_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_GEN" AS
/* $Header: IGFAW02B.pls 120.14 2006/06/06 07:31:50 akomurav ship $ */

--------------------------------------------------------------------------------------
-- Who           When              What
--------------------------------------------------------------------------------------
-- museshad     06-Apr-2006        Bug 5140851. For FWS awards, award-level paid_amt
--                                 must not be reset with the sum of disbursement-level
--                                 paid_amts. Fixed this in update_award().
--------------------------------------------------------------------------------------
-- museshad     24-Oct-2005        In update_fmast(), cancelled_amt was getting updated
--                                 incorrectly. Fixed this.
--------------------------------------------------------------------------------------
-- museshad     08-Aug-2005        Bug 3954451. Cancel award, if all disbursements are
--                                 cancelled.
--------------------------------------------------------------------------------------
-- museshad     14-Jul-2005        Build FA 140.
--                                 Modified TBH call due to the addition of new
--                                 columns to igf_aw_fund_mast_all.
--------------------------------------------------------------------------------------
-- mnade        6/6/2005           FA 157 - 4382371 - Added
--                                 get_notification_status update_notification_status
--                                 update_awd_notification_status get_concurrent_prog_name
--                                 is_fund_locked_for_awd_period.
--                                 TBH impact fornotification_status_code, Disb Rounding.
--------------------------------------------------------------------------------------
-- mnade       1-Feb-2005          Bug - 4089662 - Added IGF_AW_LOAN_LMT_NOT_FND in others for avoiding
--                                 exception messages being appended
--------------------------------------------------------------------------------------
-- cdcruz      05-Dec-04           FA 152/FA 137 - Adjustment entries were not getting created in
--                                 Proc update_disb. Cursor cur_get_fed, moved to the right position
---------------------------------------------------------------------------------------
-- veramach    Oct 2004            FA 152/FA 137 - Obsoleted efc_coa,efc_resource,rem_need_fm,rem_need_im
--------------------------------------------------------------------------------------
-- sjadhav     21-Oct-2004    Bug # 3416936 FA 134, update sl loans chg status
--------------------------------------------------------------------------------------
-- brajendr    13-Oct-2004    FA152 COA and FA137 Repackaging design changes
--                            Added the new column to the form and the TBH calls
--------------------------------------------------------------------------------------
-- svuppala    14-Oct-04      Bug # 3416936 Modified TBH call to addeded field
--                            Eligible for Additional Unsubsidized Loans
--------------------------------------------------------------------------------------
-- ayedubat      12-OCT-2004       Changed the update_disb procedure for FA 149 build bug # 3416863
-- veramach      July 2004         FA 151 HR Integration (bug # 3709292)
--                                 Impact of obsoleting columns from igf_aw_fund_mast_all table
--------------------------------------------------------------------------------------
-- sjadhav       10-Dec-2003       FA 131 Changes
--                                 De-link auto update of Pell Disbursement and Pell
--                                 origination amounts
--------------------------------------------------------------------------------------
-- sjadhav       3-Dec-2003        FA 131 Build changes
--                                 Modified  award and disb table handlers
--------------------------------------------------------------------------------------
-- rasahoo       2-Dec-2003        FA 128 ISIR update 2004-05 New parameters added
--------------------------------------------------------------------------------------
-- veramach      11-NOV-2003       Changed the signature of check_ld_cal_tps -
--                                 adplans_id is passed instead of fund_id and out
--                                 variable is VARCHAR2 instead of BOOLEAN
--------------------------------------------------------------------------------------
-- veramach      1-NOV-2003        FA 125(#3160568) Added apdlans_id in the calls to
--                                 igf_aw_award_pkg.update_row
--------------------------------------------------------------------------------------
-- ugummall      25-SEP-2003       FA 126 - Multiple FA Offices
--                                 added new parameter assoc_org_num to
--                                 igf_ap_fa_base_rec_pkg.update_row call.
--------------------------------------------------------------------------------------
-- bkkumar       04-jun-2003       Bug 2858504 Added legacy_record_flag
--                                 and award_number_txt in the table
--                                 handler calls for igf_aw_award_pkg.update_row
--------------------------------------------------------------------------------------
-- sjadhav       26-Mar-2003       Bug 2863960
--                                 Modified routine update_disb to populate disb gross
--                                 amount in the adjustment table with disb accepted
--                                 amount
-----------------------------------------------------------------------------------
-- sjadhav       18-Feb-2003       Bug 2758823
--                                 Modified update_disb routine to create adjustment
--                                 for disbursement date change for direct loan award
--                                 Modified cursor cur_fund_dtls,c_fm_need,c_awd_tot
--                                 c_im_need for sql tuning
--------------------------------------------------------------------------------------
-- cdcruz        18-Feb-2003       Bug 2758804
--                                 Reference To Efc Setup Tables Removed
--------------------------------------------------------------------------------------
-- sjadhav       05-Feb-2003       FA116 Build - Bug 2758812
--                                 Modified update_award to set pell origination
--                                 status to 'R' and batch id to null(i.e.rfmb_id)
--------------------------------------------------------------------------------------
-- brajendr      19-Dec-2002       Bug # 2708599
--                                 Modifed the procedure update_fmast for deletion
--                                 of Simulated awards
--------------------------------------------------------------------------------------
-- cdcruz        07-Nov-02         Modified the update_row call of
--                                 IGF_AW_FUND_MAST_PKG
--                                 Sap type is obsoleted in the SAP build fa101
--------------------------------------------------------------------------------------
-- adhawan       25-oct-2002       ALT_PELL_SCHEDULE added for FA108 Awarding
--                                 Enhancements efc_coa --Modified the coa_total_cur
--                                 to select from directly for term load calendar
--                                 efc_coa --Obsoleted the usage of p_flag ,
--                                 it is kept only for backward compatibility
--                                 efc_resource Modified the award_total_cur to select
--                                 from igf_aw_adisb_coa_match_v instead of
--                                 igf_aw_coa_citsn efc_resource Obsoleted the usage
--                                 of p_flag , it is kept only for backward
--                                 compatibility
--------------------------------------------------------------------------------------
-- masehgal      25-Sep-2002       FA 104 - To Do Enhancements
--                                 Added manual_disb_hold in FA Base update
--------------------------------------------------------------------------------------
-- brajendr      14-Jun-2002       Modified the update_row call of
--                                 igf_aw_award_pkg.update_row
--                                 to calculate the sum of the paid amount of all
--                                 the disbursements
--------------------------------------------------------------------------------------
-- brajendr      12-Jun-2002       Modified the update_row call of
--                                 IGF_AW_FUND_MAST_PKG as
--                                 Student Employment related columns
--                                 are missing in the call
--------------------------------------------------------------------------------------
-- sjadhav       24-apr-2002       Bug # 2340471.Restored changes done for Bug
--                                 2144600,2222272
--------------------------------------------------------------------------------------
-- agairola      15-Mar-2002       Modified the call for the
--                                 IGF_SL_LOANS_PKG.UPDATE_ROW
--                                 for Borrower Determination - 2144600
--------------------------------------------------------------------------------------
-- jbegum        15-Feb-02         As part of Enh bug #2222272 modified FUNCTION
--                                 get_org_id
--                                 Explicitly the org id is being returned as null
--                                 to remove multi org functionality from OSS
--------------------------------------------------------------------------------------
-- cdcruz        06-May-2002       Modified the procedure update_fmast
--                                 All summary tab updations in Fund Manager
--                                 are now revised - Bug 2310222
--------------------------------------------------------------------------------------
-- sjadhav      Feb 13, 2002       Bug 2216956
--                                 This function would return Version Number from
--                                 batch year mappings table
--------------------------------------------------------------------------------------


FUNCTION get_ver_num ( p_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                       p_seq_num  IN igs_ca_inst_all.sequence_number%TYPE,
                       p_process  IN VARCHAR2)
RETURN VARCHAR2
IS

        CURSOR cur_ver_num ( p_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num  IN igs_ca_inst_all.sequence_number%TYPE)
        IS
        SELECT dl_code,
               pell_code,
               ffel_code,
               isir_code,
               profile_code
        FROM
               igf_ap_batch_aw_map
        WHERE
               ci_cal_type = p_cal_type AND
               ci_sequence_number = p_seq_num;

        ver_num_rec  cur_ver_num%ROWTYPE;


BEGIN

        OPEN  cur_ver_num (p_cal_type,p_seq_num);
        FETCH cur_ver_num INTO ver_num_rec;

        IF    cur_ver_num%NOTFOUND THEN
              CLOSE cur_ver_num;
              RETURN 'NULL';
        ELSIF cur_ver_num%FOUND THEN
              CLOSE cur_ver_num;

                IF    p_process ='D' THEN
                        RETURN ver_num_rec.dl_code;
                ELSIF p_process ='F' THEN
                        RETURN ver_num_rec.ffel_code;
                ELSIF p_process ='P' THEN
                        RETURN ver_num_rec.pell_code;
                ELSIF p_process ='I' THEN
                        RETURN ver_num_rec.isir_code;
                ELSIF p_process ='R' THEN
                        RETURN ver_num_rec.profile_code;
                ELSE
                        RETURN 'NULL';
                END IF;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.GET_VER_NUM' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_ver_num;



 FUNCTION lookup_desc( l_type in VARCHAR2 , l_code in VARCHAR2 )RETURN VARCHAR2
 IS

 CURSOR c_desc( x_type  igf_lookups_view.lookup_type%TYPE,
                x_code  igf_lookups_view.lookup_code%TYPE)
 IS
 SELECT meaning
 FROM
 igf_lookups_view
 WHERE
  lookup_code = UPPER(TRIM(x_code))  AND
  lookup_type = UPPER(TRIM(x_type)) ;

 --
 -- For OSS Lookups
 --

 CURSOR cur_oss_desc( x_type  igf_lookups_view.lookup_type%TYPE,
                      x_code  igf_lookups_view.lookup_code%TYPE)
 IS
 SELECT meaning
 FROM
 igs_lookups_view
 WHERE
  lookup_code = UPPER(TRIM(x_code))  AND
  lookup_type = UPPER(TRIM(x_type)) ;

 l_desc VARCHAR2(80) DEFAULT NULL;

 BEGIN

   IF l_code IS NULL THEN
     RETURN NULL ;
   ELSE

      OPEN  c_desc(l_type,l_code);
      FETCH c_desc INTO l_desc;

      IF c_desc%NOTFOUND THEN
              CLOSE c_desc;
--
-- If not found in IGF, then look in OSS
--
              OPEN  cur_oss_desc(l_type,l_code);
              FETCH cur_oss_desc INTO l_desc;
              CLOSE cur_oss_desc;
      ELSE
              CLOSE c_desc ;
      END IF;

   END IF ;

   RETURN l_desc;

END lookup_desc;

FUNCTION chk_disb_status(p_award_id igf_aw_award_all.award_id%TYPE)
RETURN BOOLEAN
IS
  ------------------------------------------------------------------
  --Created by  : museshad
  --Date created: 22-Sep-2005
  --
  --Purpose: Returns TRUE if all the disbursements in the award are
  --         cancelled, else returns FALSE
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR cur_get_cancl_disb(cp_award_id igf_aw_award_all.award_id%TYPE)
  IS
    SELECT  'X'
    FROM    igf_aw_awd_disb_all
    WHERE   award_id = cp_award_id AND
            trans_type <> 'C';

  l_cur_get_cancl_disb_rec cur_get_cancl_disb%ROWTYPE;

BEGIN

  OPEN cur_get_cancl_disb(cp_award_id => p_award_id);
  FETCH cur_get_cancl_disb INTO l_cur_get_cancl_disb_rec;

  IF (cur_get_cancl_disb%FOUND) THEN
    CLOSE cur_get_cancl_disb;
    RETURN FALSE;
  ELSE
    CLOSE cur_get_cancl_disb;
    RETURN TRUE;
  END IF;

END chk_disb_status;

PROCEDURE update_disb(p_disb_old_rec  igf_aw_awd_disb_all%ROWTYPE,
                      p_disb_new_rec  igf_aw_awd_disb_all%ROWTYPE)
IS

--------------------------------------------------------------------------------------
-- sjadhav       05-Nov-2004     FA 134 Build. Update loans table if disb data changes
--------------------------------------------------------------------------------------
-- ayedubat      11-OCT-2004       Changed the calling of procedure, igf_db_awd_disb_dtl_pkg.insert_row
--                                 to pass NULL values for the columns, DISB_STATUS, DISB_STATUS_DATE,
--                                 DISB_BATCH_ID, DISB_ACK_DATE, BOOKING_BATCH_ID and BOOKED_DATE for Bug, 3416863
-- sjadhav       18-Feb-2003       Bug 2758823
--                                 Modified update_disb routine to create adjustment
--                                 for disbursement date change for direct loan award
--------------------------------------------------------------------------------------
-- sjadhav, Feb 08th 2002
--
-- This procedure creates adjustments for actual disbursement
--
-- If the Direct Loan is Accepted and if any amounts change then
-- update Loan Change Status to 'Ready to Send'
--------------------------------------------------------------------------------------
--
-- Cursor to get loan details
--
   CURSOR cur_loans(
      p_award_id                          igf_db_awd_disb_dtl.award_id%TYPE
   )
   IS
      SELECT        loan.*
               FROM igf_sl_loans loan
              WHERE loan.award_id = p_award_id
      FOR UPDATE OF loan_chg_status;

   loans_rec                     cur_loans%ROWTYPE;


--
--  Cursor to get Fed Fund Code
--
   CURSOR cur_get_fed(
      p_award_id                          igf_db_awd_disb_dtl.award_id%TYPE
   )
   IS
      SELECT cat.fed_fund_code, awd.award_status award_status
        FROM igf_aw_award awd, igf_aw_fund_mast fmast, igf_aw_fund_cat cat
       WHERE awd.award_id = p_award_id
         AND awd.fund_id = fmast.fund_id
         AND fmast.fund_code = cat.fund_code;

   get_fed_rec                   cur_get_fed%ROWTYPE;

   CURSOR c_max_seq_num(
      p_award_id                          igf_db_awd_disb_dtl.award_id%TYPE,
      p_disb_num                          igf_aw_awd_disb_all.disb_num%TYPE
   )
   IS
      SELECT MAX(disb_seq_num) max_num
        FROM igf_db_awd_disb_dtl
       WHERE award_id = p_award_id AND disb_num = p_disb_num;


   CURSOR c_get_net_total(
      p_award_id                          igf_db_awd_disb_dtl.award_id%TYPE,
      p_disb_num                          igf_aw_awd_disb_all.disb_num%TYPE
   )
   IS
      SELECT
	SUM(DECODE(DISB_ACTIVITY,'D',DISB_NET_AMT,'A',DISB_ADJ_AMT,'Q',0)) net_total
	FROM igf_db_awd_disb_dtl_all
	WHERE award_id =p_award_id  AND disb_num = p_disb_num AND sf_status in('R','P','E');

   r_get_net_total              c_get_net_total%ROWTYPE;


   lv_max_seq_num                c_max_seq_num%ROWTYPE;
   lv_rowid                      VARCHAR2(25);
   dbdtlrec                      igf_db_awd_disb_dtl%ROWTYPE;
BEGIN

--
-- check if any of the following fields are changed
--
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
   THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
         'p_disb_old_rec.disb_net_amt:' || p_disb_old_rec.disb_net_amt);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
         'p_disb_new_rec.disb_net_amt:' || p_disb_new_rec.disb_net_amt);
   END IF;

   OPEN cur_get_fed(p_disb_old_rec.award_id);
   FETCH cur_get_fed INTO get_fed_rec;
   CLOSE cur_get_fed;

   --akomurav
   IF p_disb_old_rec.disb_net_amt <> p_disb_new_rec.disb_net_amt AND (p_disb_old_rec.ld_cal_type = p_disb_new_rec.ld_cal_type AND p_disb_old_rec.ld_sequence_number = p_disb_new_rec.ld_sequence_number)
   THEN

--
-- if there is change in the above amounts, decide if we should create
-- an adjustment or not
--
      IF p_disb_old_rec.trans_type = 'A' OR p_disb_new_rec.trans_type = 'A'
      THEN
         OPEN c_max_seq_num(p_disb_new_rec.award_id, p_disb_new_rec.disb_num);
         FETCH c_max_seq_num INTO lv_max_seq_num;
         CLOSE c_max_seq_num;

         IF lv_max_seq_num.max_num > 0
         THEN
            dbdtlrec.award_id := p_disb_new_rec.award_id;
            dbdtlrec.disb_num := p_disb_new_rec.disb_num;
            dbdtlrec.disb_seq_num := TO_NUMBER(lv_max_seq_num.max_num) + 1;
            dbdtlrec.disb_gross_amt := p_disb_new_rec.disb_accepted_amt;
            dbdtlrec.fee_1 := p_disb_new_rec.fee_1;
            dbdtlrec.fee_2 := p_disb_new_rec.fee_2;
            dbdtlrec.disb_net_amt := p_disb_new_rec.disb_net_amt;
            dbdtlrec.disb_adj_amt :=   p_disb_new_rec.disb_net_amt
                                     - p_disb_old_rec.disb_net_amt;
            dbdtlrec.disb_date := p_disb_new_rec.disb_date;
            dbdtlrec.fee_paid_1 := p_disb_new_rec.fee_paid_1;
            dbdtlrec.fee_paid_2 := p_disb_new_rec.fee_paid_2;
            dbdtlrec.disb_activity := 'A';
            dbdtlrec.disb_batch_id := NULL;
            dbdtlrec.disb_ack_date := NULL;
            dbdtlrec.booking_batch_id := NULL;
            dbdtlrec.booked_date := NULL;
            dbdtlrec.disb_status := NULL;
            dbdtlrec.disb_status_date := NULL;
            dbdtlrec.sf_status := 'R';
            dbdtlrec.sf_status_date := TRUNC(SYSDATE);
            dbdtlrec.sf_invoice_num := NULL;
            dbdtlrec.spnsr_credit_id := NULL;
            dbdtlrec.spnsr_charge_id := NULL;
            dbdtlrec.sf_credit_id := NULL;
            dbdtlrec.error_desc := NULL;
	    dbdtlrec.ld_cal_type := p_disb_new_rec.ld_cal_type;
    	    dbdtlrec.ld_sequence_number := p_disb_new_rec.ld_sequence_number;


--Only if the Award Status is Accepted  will the adjustment details would be created .
            IF get_fed_rec.award_status IN ('ACCEPTED', 'CANCELLED')
            THEN
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
                        'Inserting igf_db_awd_disb_dtl award_id '|| dbdtlrec.award_id);
               END IF;

               igf_db_awd_disb_dtl_pkg.insert_row(
                  x_rowid                       => lv_rowid,
                  x_award_id                    => dbdtlrec.award_id,
                  x_disb_num                    => dbdtlrec.disb_num,
                  x_disb_seq_num                => dbdtlrec.disb_seq_num,
                  x_disb_gross_amt              => dbdtlrec.disb_gross_amt,
                  x_fee_1                       => dbdtlrec.fee_1,
                  x_fee_2                       => dbdtlrec.fee_2,
                  x_disb_net_amt                => dbdtlrec.disb_net_amt,
                  x_disb_adj_amt                => dbdtlrec.disb_adj_amt,
                  x_disb_date                   => dbdtlrec.disb_date,
                  x_fee_paid_1                  => dbdtlrec.fee_paid_1,
                  x_fee_paid_2                  => dbdtlrec.fee_paid_2,
                  x_disb_activity               => dbdtlrec.disb_activity,
                  x_disb_batch_id               => NULL,
                  x_disb_ack_date               => NULL,
                  x_booking_batch_id            => NULL,
                  x_booked_date                 => NULL,
                  x_disb_status                 => NULL,
                  x_disb_status_date            => NULL,
                  x_sf_status                   => dbdtlrec.sf_status,
                  x_sf_status_date              => dbdtlrec.sf_status_date,
                  x_sf_invoice_num              => dbdtlrec.sf_invoice_num,
                  x_spnsr_credit_id             => dbdtlrec.spnsr_credit_id,
                  x_spnsr_charge_id             => dbdtlrec.spnsr_charge_id,
                  x_sf_credit_id                => dbdtlrec.sf_credit_id,
                  x_error_desc                  => dbdtlrec.error_desc,
                  x_mode                        => 'R',
                  x_notification_date           => NULL,
                  x_interest_rebate_amt         => NULL,
		  x_ld_cal_type                 => dbdtlrec.ld_cal_type,
		  x_ld_sequence_number          => dbdtlrec.ld_sequence_number
               );
            END IF; -- award rec status is accepted/cancelled
         END IF; -- max number > 0
      END IF; -- trans type check
   END IF; -- net amount check


   --akomurav #5145680 if the ld cal type is changed due to repackage then a invoice rec with old amount and credit with new amt is created in the
		--disb_dtl table in ready staus. These will be then picked by the "Transfer to student Account" process.
IF p_disb_old_rec.ld_cal_type <> p_disb_new_rec.ld_cal_type OR p_disb_old_rec.ld_sequence_number <> p_disb_new_rec.ld_sequence_number
   THEN

--
-- if there is change in the cal_type of sequence_number, decide if we should create
-- an adjustment or not
--
      IF p_disb_old_rec.trans_type = 'A' OR p_disb_new_rec.trans_type = 'A'
      THEN
         OPEN c_max_seq_num(p_disb_new_rec.award_id, p_disb_new_rec.disb_num);
         FETCH c_max_seq_num INTO lv_max_seq_num;
         CLOSE c_max_seq_num;

	 OPEN c_get_net_total(p_disb_new_rec.award_id, p_disb_new_rec.disb_num);
         FETCH c_get_net_total INTO r_get_net_total;
	 CLOSE c_get_net_total;

         IF lv_max_seq_num.max_num > 0
         THEN
            dbdtlrec.award_id := p_disb_new_rec.award_id;
            dbdtlrec.disb_num := p_disb_new_rec.disb_num;
            dbdtlrec.disb_seq_num := TO_NUMBER(lv_max_seq_num.max_num) + 1;
            dbdtlrec.disb_gross_amt := 0;
            dbdtlrec.fee_1 := p_disb_old_rec.fee_1;
            dbdtlrec.fee_2 := p_disb_old_rec.fee_2;
            dbdtlrec.disb_net_amt := 0;
            dbdtlrec.disb_adj_amt := -r_get_net_total.net_total;
            dbdtlrec.disb_date := p_disb_old_rec.disb_date;
            dbdtlrec.fee_paid_1 := p_disb_old_rec.fee_paid_1;
            dbdtlrec.fee_paid_2 := p_disb_old_rec.fee_paid_1;
            dbdtlrec.disb_activity := 'A';
            dbdtlrec.disb_batch_id := NULL;
            dbdtlrec.disb_ack_date := NULL;
            dbdtlrec.booking_batch_id := NULL;
            dbdtlrec.booked_date := NULL;
            dbdtlrec.disb_status := NULL;
            dbdtlrec.disb_status_date := NULL;
            dbdtlrec.sf_status := 'R';
            dbdtlrec.sf_status_date := TRUNC(SYSDATE);
            dbdtlrec.sf_invoice_num := NULL;
            dbdtlrec.spnsr_credit_id := NULL;
            dbdtlrec.spnsr_charge_id := NULL;
            dbdtlrec.sf_credit_id := NULL;
            dbdtlrec.error_desc := NULL;
	    dbdtlrec.ld_cal_type:= p_disb_old_rec.ld_cal_type;
	    dbdtlrec.ld_sequence_number := p_disb_old_rec.ld_sequence_number;



--Only if the Award Status is Accepted  will the adjustment details would be created .
            IF get_fed_rec.award_status IN ('ACCEPTED', 'CANCELLED')
            THEN
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
                        'Inserting igf_db_awd_disb_dtl award_id '|| dbdtlrec.award_id);
               END IF;
		--creating an invoice record in disb_dtl table
               igf_db_awd_disb_dtl_pkg.insert_row(
                  x_rowid                       => lv_rowid,
                  x_award_id                    => dbdtlrec.award_id,
                  x_disb_num                    => dbdtlrec.disb_num,
                  x_disb_seq_num                => dbdtlrec.disb_seq_num,
                  x_disb_gross_amt              => dbdtlrec.disb_gross_amt,
                  x_fee_1                       => dbdtlrec.fee_1,
                  x_fee_2                       => dbdtlrec.fee_2,
                  x_disb_net_amt                => dbdtlrec.disb_net_amt,
                  x_disb_adj_amt                => dbdtlrec.disb_adj_amt,
                  x_disb_date                   => dbdtlrec.disb_date,
                  x_fee_paid_1                  => dbdtlrec.fee_paid_1,
                  x_fee_paid_2                  => dbdtlrec.fee_paid_2,
                  x_disb_activity               => dbdtlrec.disb_activity,
                  x_disb_batch_id               => NULL,
                  x_disb_ack_date               => NULL,
                  x_booking_batch_id            => NULL,
                  x_booked_date                 => NULL,
                  x_disb_status                 => NULL,
                  x_disb_status_date            => NULL,
                  x_sf_status                   => dbdtlrec.sf_status,
                  x_sf_status_date              => dbdtlrec.sf_status_date,
                  x_sf_invoice_num              => dbdtlrec.sf_invoice_num,
                  x_spnsr_credit_id             => dbdtlrec.spnsr_credit_id,
                  x_spnsr_charge_id             => dbdtlrec.spnsr_charge_id,
                  x_sf_credit_id                => dbdtlrec.sf_credit_id,
                  x_error_desc                  => dbdtlrec.error_desc,
                  x_mode                        => 'R',
                  x_notification_date           => NULL,
                  x_interest_rebate_amt         => NULL,
		  x_ld_cal_type                 => dbdtlrec.ld_cal_type,
		  x_ld_sequence_number          => dbdtlrec.ld_sequence_number
               );

		dbdtlrec.fee_1 := p_disb_new_rec.fee_1;
		dbdtlrec.fee_2 := p_disb_new_rec.fee_2;
		dbdtlrec.fee_paid_1 := p_disb_new_rec.fee_paid_1;
		dbdtlrec.fee_paid_2 := p_disb_new_rec.fee_paid_1;
		dbdtlrec.disb_net_amt := p_disb_new_rec.disb_net_amt;
		dbdtlrec.disb_gross_amt := p_disb_new_rec.disb_gross_amt;
		dbdtlrec.disb_adj_amt := p_disb_new_rec.disb_net_amt;
		dbdtlrec.ld_cal_type := p_disb_new_rec.ld_cal_type;
		dbdtlrec.ld_sequence_number  := p_disb_new_rec.ld_sequence_number;
		dbdtlrec.disb_date := p_disb_old_rec.disb_date;--this should be old disb date only

		--creating an credit record in disb_dtl table

		igf_db_awd_disb_dtl_pkg.insert_row(
                  x_rowid                       => lv_rowid,
                  x_award_id                    => dbdtlrec.award_id,
                  x_disb_num                    => dbdtlrec.disb_num,
                  x_disb_seq_num                => dbdtlrec.disb_seq_num+1,
                  x_disb_gross_amt              => dbdtlrec.disb_gross_amt,
                  x_fee_1                       => dbdtlrec.fee_1,
                  x_fee_2                       => dbdtlrec.fee_2,
                  x_disb_net_amt                => dbdtlrec.disb_net_amt,
                  x_disb_adj_amt                => dbdtlrec.disb_adj_amt,
                  x_disb_date                   => dbdtlrec.disb_date,
                  x_fee_paid_1                  => dbdtlrec.fee_paid_1,
                  x_fee_paid_2                  => dbdtlrec.fee_paid_2,
                  x_disb_activity               => dbdtlrec.disb_activity,
                  x_disb_batch_id               => NULL,
                  x_disb_ack_date               => NULL,
                  x_booking_batch_id            => NULL,
                  x_booked_date                 => NULL,
                  x_disb_status                 => NULL,
                  x_disb_status_date            => NULL,
                  x_sf_status                   => dbdtlrec.sf_status,
                  x_sf_status_date              => dbdtlrec.sf_status_date,
                  x_sf_invoice_num              => dbdtlrec.sf_invoice_num,
                  x_spnsr_credit_id             => dbdtlrec.spnsr_credit_id,
                  x_spnsr_charge_id             => dbdtlrec.spnsr_charge_id,
                  x_sf_credit_id                => dbdtlrec.sf_credit_id,
                  x_error_desc                  => dbdtlrec.error_desc,
                  x_mode                        => 'R',
                  x_notification_date           => NULL,
                  x_interest_rebate_amt         => NULL,
		  x_ld_cal_type                 => dbdtlrec.ld_cal_type,
		  x_ld_sequence_number          => dbdtlrec.ld_sequence_number
               );

            END IF; -- award rec status is accepted/cancelled
         END IF; -- max number > 0
      END IF; -- trans type check
   END IF; -- ld_cal_type or ld_sequence_number change



--
-- check if any of the disb dates are changed
--
   IF TRUNC(p_disb_old_rec.disb_date) <> TRUNC(p_disb_new_rec.disb_date)
   THEN
      IF p_disb_old_rec.trans_type = 'A' OR p_disb_new_rec.trans_type = 'A'
      THEN
         OPEN c_max_seq_num(p_disb_new_rec.award_id, p_disb_new_rec.disb_num);
         FETCH c_max_seq_num INTO lv_max_seq_num;
         CLOSE c_max_seq_num;

         IF lv_max_seq_num.max_num > 0
         THEN
            dbdtlrec.award_id := p_disb_new_rec.award_id;
            dbdtlrec.disb_num := p_disb_new_rec.disb_num;
            dbdtlrec.disb_seq_num := lv_max_seq_num.max_num + 1;
            dbdtlrec.disb_gross_amt := p_disb_new_rec.disb_accepted_amt;
            dbdtlrec.fee_1 := p_disb_new_rec.fee_1;
            dbdtlrec.fee_2 := p_disb_new_rec.fee_2;
            dbdtlrec.disb_net_amt := p_disb_new_rec.disb_net_amt;
            dbdtlrec.disb_adj_amt := 0;
            dbdtlrec.disb_date := p_disb_new_rec.disb_date;
            dbdtlrec.fee_paid_1 := p_disb_new_rec.fee_paid_1;
            dbdtlrec.fee_paid_2 := p_disb_new_rec.fee_paid_2;
            dbdtlrec.disb_activity := 'Q';
            dbdtlrec.disb_batch_id := NULL;
            dbdtlrec.disb_ack_date := NULL;
            dbdtlrec.booking_batch_id := NULL;
            dbdtlrec.booked_date := NULL;
            dbdtlrec.disb_status := NULL;
            dbdtlrec.disb_status_date := NULL;
            dbdtlrec.sf_status := 'N';
            dbdtlrec.sf_status_date := TRUNC(SYSDATE);
            dbdtlrec.sf_invoice_num := NULL;
            dbdtlrec.spnsr_credit_id := NULL;
            dbdtlrec.spnsr_charge_id := NULL;
            dbdtlrec.sf_credit_id := NULL;
            dbdtlrec.error_desc := NULL;
	    dbdtlrec.ld_cal_type := p_disb_new_rec.ld_cal_type;
    	    dbdtlrec.ld_sequence_number := p_disb_new_rec.ld_sequence_number;



--Only if the Award Status is Accepted  will the adjustment details would be created .
            IF get_fed_rec.award_status = 'ACCEPTED'
            THEN
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
                        'Inserting to igf_db_awd_disb_dtl award_id:'|| dbdtlrec.award_id);
               END IF;

               igf_db_awd_disb_dtl_pkg.insert_row(
                  x_rowid                       => lv_rowid,
                  x_award_id                    => dbdtlrec.award_id,
                  x_disb_num                    => dbdtlrec.disb_num,
                  x_disb_seq_num                => dbdtlrec.disb_seq_num,
                  x_disb_gross_amt              => dbdtlrec.disb_gross_amt,
                  x_fee_1                       => dbdtlrec.fee_1,
                  x_fee_2                       => dbdtlrec.fee_2,
                  x_disb_net_amt                => dbdtlrec.disb_net_amt,
                  x_disb_adj_amt                => dbdtlrec.disb_adj_amt,
                  x_disb_date                   => dbdtlrec.disb_date,
                  x_fee_paid_1                  => dbdtlrec.fee_paid_1,
                  x_fee_paid_2                  => dbdtlrec.fee_paid_2,
                  x_disb_activity               => dbdtlrec.disb_activity,
                  x_disb_batch_id               => NULL,
                  x_disb_ack_date               => NULL,
                  x_booking_batch_id            => NULL,
                  x_booked_date                 => NULL,
                  x_disb_status                 => NULL,
                  x_disb_status_date            => NULL,
                  x_sf_status                   => dbdtlrec.sf_status,
                  x_sf_status_date              => dbdtlrec.sf_status_date,
                  x_sf_invoice_num              => dbdtlrec.sf_invoice_num,
                  x_spnsr_credit_id             => dbdtlrec.spnsr_credit_id,
                  x_spnsr_charge_id             => dbdtlrec.spnsr_charge_id,
                  x_sf_credit_id                => dbdtlrec.sf_credit_id,
                  x_error_desc                  => dbdtlrec.error_desc,
                  x_mode                        => 'R',
                  x_notification_date           => NULL,
                  x_interest_rebate_amt         => NULL,
		  x_ld_cal_type                 => dbdtlrec.ld_cal_type,
		  x_ld_sequence_number          => dbdtlrec.ld_sequence_number

               );
            END IF; -- award rec status is accepted
         END IF; -- max number > 0
      END IF; -- trans type check
   END IF; -- date check

--
-- Check if the DL Loan Status is 'Accepted', If yes then change the
-- Loan Change Status to 'Ready to Send'
--

   FOR loans_rec IN cur_loans(p_disb_old_rec.award_id)
   LOOP
     IF   igf_sl_gen.chk_cl_fed_fund_code(get_fed_rec.fed_fund_code) = 'TRUE'
       AND loans_rec.loan_status = 'A' AND NVL(loans_rec.loan_chg_status,'*') <> 'S'
     THEN
       IF igf_sl_award.get_loan_cl_version(loans_rec.award_id) = 'RELEASE-4'
       THEN
         IF  TRUNC(p_disb_old_rec.disb_date) <> TRUNC(p_disb_new_rec.disb_date)
            OR p_disb_old_rec.disb_net_amt <> p_disb_new_rec.disb_net_amt
            OR p_disb_old_rec.hold_rel_ind <> p_disb_old_rec.hold_rel_ind
         THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
                                 'Updating loan ' || loans_rec.loan_id || ' as ready to send');
            END IF;
               igf_sl_loans_pkg.update_row(
                  x_rowid                       => loans_rec.row_id,
                  x_loan_id                     => loans_rec.loan_id,
                  x_award_id                    => loans_rec.award_id,
                  x_seq_num                     => loans_rec.seq_num,
                  x_loan_number                 => loans_rec.loan_number,
                  x_loan_per_begin_date         => loans_rec.loan_per_begin_date,
                  x_loan_per_end_date           => loans_rec.loan_per_end_date,
                  x_loan_status                 => loans_rec.loan_status,
                  x_loan_status_date            => loans_rec.loan_status_date,
                  x_loan_chg_status             => 'G',
                  x_loan_chg_status_date        => TRUNC(SYSDATE),
                  x_active                      => loans_rec.active,
                  x_active_date                 => loans_rec.active_date,
                  x_borw_detrm_code             => loans_rec.borw_detrm_code,
                  x_external_loan_id_txt        => loans_rec.external_loan_id_txt,
                  x_mode                        => 'R'
               );
         END IF;
       END IF;
     END IF;
   END LOOP;

   FOR loans_rec IN cur_loans(p_disb_old_rec.award_id)
   LOOP
       IF  igf_sl_gen.chk_dl_fed_fund_code(get_fed_rec.fed_fund_code) = 'TRUE'
           AND loans_rec.loan_status = 'A'  AND NVL(loans_rec.loan_chg_status,'*') <> 'S'
       THEN
          IF    TRUNC(p_disb_old_rec.disb_date) <> TRUNC(p_disb_new_rec.disb_date)
             OR p_disb_old_rec.disb_net_amt <> p_disb_new_rec.disb_net_amt
          THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
             THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_disb.debug',
                   'Updating loan ' || loans_rec.loan_id || ' as ready to send');
             END IF;

            igf_sl_loans_pkg.update_row(
               x_rowid                       => loans_rec.row_id,
               x_loan_id                     => loans_rec.loan_id,
               x_award_id                    => loans_rec.award_id,
               x_seq_num                     => loans_rec.seq_num,
               x_loan_number                 => loans_rec.loan_number,
               x_loan_per_begin_date         => loans_rec.loan_per_begin_date,
               x_loan_per_end_date           => loans_rec.loan_per_end_date,
               x_loan_status                 => loans_rec.loan_status,
               x_loan_status_date            => loans_rec.loan_status_date,
               x_loan_chg_status             => 'G',
               x_loan_chg_status_date        => TRUNC(SYSDATE),
               x_active                      => loans_rec.active,
               x_active_date                 => loans_rec.active_date,
               x_borw_detrm_code             => loans_rec.borw_detrm_code,
               x_external_loan_id_txt        => loans_rec.external_loan_id_txt,
               x_mode                        => 'R'
            );

          END IF;
       END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS
   THEN
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME', 'IGF_AW_GEN.UPDATE_DISB' || ' ' || SQLERRM);
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
END update_disb;


PROCEDURE update_fabase_awds(
                             p_base_id in  igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_pack_status igf_ap_fa_base_rec.packaging_status%TYPE
                            ) IS
  /*
  ||  Created By : cdcruz
  ||  Created On : 29-JAN-2001
  ||  Purpose : Update FA Base record with the latest Packaging deails
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || rasahoo         27-NOV-2003    FA 128 - ISIR update 2004-05
  ||                                added new parameter award_fmly_contribution_type to
  ||                                igf_ap_fa_base_rec_pkg.update_row
  ||
  ||  ugummall        25-SEP-2003     FA 126 - Multiple FA Offices
  ||                                  added new parameter assoc_org_num to
  ||                                  igf_ap_fa_base_rec_pkg.update_row call.
  ||
  ||  brajendr        18-Dec-2002     Bug # 2691832
  ||                                  Modified the logic for updating the Packaging Status.
  ||
  ||  masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
  ||                                  removed packaging hold
  ||
  ||  masehgal        25-Sep-2002     FA 104 - To Do Enhancements
  ||                                  Added manual_disb_hold in FA Base update
  ||
  ||  avenkatr        27-JUN-2001     1. Added p_pack_status parameter.
  */

  -- Sums up studentwise packaged totals
  CURSOR c_pkg_tot ( x_base_id    igf_aw_award_t.base_id%TYPE) IS
  SELECT SUM(NVL(awd.offered_amt,0)) offered_amt,
         SUM(NVL(awd.accepted_amt,0)) accepted_amt
    FROM igf_aw_award awd
   WHERE awd.base_id    = x_base_id
     AND award_status NOT IN( 'CANCELLED', 'DECLINED','SIMULATED' ) ;

  l_pkg_tot c_pkg_tot%rowtype ;

  CURSOR c_stud_det ( x_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
  SELECT fabase.*
    FROM igf_ap_fa_base_rec fabase
   WHERE fabase.base_id = x_base_id ;

  l_stud_det c_stud_det%rowtype ;

BEGIN

  --- Get packaged Totals
  igf_aw_gen.set_org_id(NULL);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fabase_awds.debug','p_base_id:'||p_base_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fabase_awds.debug','p_pack_status:'||p_pack_status);
  END IF;

  OPEN c_pkg_tot ( p_base_id ) ;
  FETCH c_pkg_tot INTO l_pkg_tot ;
  CLOSE c_pkg_tot ;

  -- Update the Students FA Base Record
  OPEN c_stud_det ( p_base_id ) ;
  FETCH c_stud_det INTO l_stud_det ;
    CLOSE c_stud_det ;

    /*  Bug # 2691832
    -- Packing Status should be modified as
    -----------------------------------------------------------------------
    Calling From      Parameter Val      Initial Status     Final Status
    -----------------------------------------------------------------------
    Auto Pkg      --> AUTO_PACKAGED -->  NULL/SIMULATED --> AUTO_PACKAGED
    Simulated Pkg --> SIMULATED     -->  NULL/SIMULATED --> SIMULATED
    Single Fund   --> SINGLE        -->  AUTO_PACKAGED  --> REVISED ( Other Statuses --> No Change)
    Cancelled     --> CANCELLED     -->  AUTO_PACKAGED  --> REVISED ( Other Statuses --> No Change)
    Forms         --> REVISED       -->  AUTO_PACKAGED  --> REVISED ( Other Statuses --> No Change)
    -----------------------------------------------------------------------
    */

    IF p_pack_status = 'AUTO_PACKAGED' THEN
      l_stud_det.packaging_status  := 'AUTO_PACKAGED';

    ELSIF p_pack_status = 'SIMULATED' THEN
      l_stud_det.packaging_status  := 'SIMULATED';

    ELSIF p_pack_status IN ('CANCELLED', 'REVISED', 'SINGLE') THEN

      IF l_stud_det.packaging_status = 'AUTO_PACKAGED' THEN
        l_stud_det.packaging_status  := 'REVISED';
      END IF;

    END IF;

    l_stud_det.packaging_status_date  := Trunc(Sysdate) ;
    l_stud_det.total_package_accepted := l_pkg_tot.accepted_amt ;
    l_stud_det.total_package_offered  := l_pkg_tot.offered_amt ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fabase_awds.debug','Updating igf_ap_fa_base_rec');
    END IF;
    igf_ap_fa_base_rec_pkg.update_row(
                                      x_rowid                      =>  l_stud_det.row_id,
                                      x_base_id                    =>  l_stud_det.base_id,
                                      x_ci_cal_type                =>  l_stud_det.ci_cal_type,
                                      x_person_id                  =>  l_stud_det.person_id,
                                      x_ci_sequence_number         =>  l_stud_det.ci_sequence_number,
                                      x_org_id                     =>  l_stud_det.org_id,
                                      x_coa_pending                =>  l_stud_det.coa_pending,
                                      x_verification_process_run   =>  l_stud_det.verification_process_run,
                                      x_inst_verif_status_date     =>  l_stud_det.inst_verif_status_date,
                                      x_manual_verif_flag          =>  l_stud_det.manual_verif_flag,
                                      x_fed_verif_status           =>  l_stud_det.fed_verif_status,
                                      x_fed_verif_status_date      =>  l_stud_det.fed_verif_status_date,
                                      x_inst_verif_status          =>  l_stud_det.inst_verif_status,
                                      x_nslds_eligible             =>  l_stud_det.nslds_eligible,
                                      x_ede_correction_batch_id    =>  l_stud_det.ede_correction_batch_id,
                                      x_fa_process_status_date     =>  l_stud_det.fa_process_status_date,
                                      x_isir_corr_status           =>  l_stud_det.isir_corr_status,
                                      x_isir_corr_status_date      =>  l_stud_det.isir_corr_status_date,
                                      x_isir_status                =>  l_stud_det.isir_status,
                                      x_isir_status_date           =>  l_stud_det.isir_status_date,
                                      x_coa_code_f                 =>  l_stud_det.coa_code_f,
                                      x_coa_code_i                 =>  l_stud_det.coa_code_i,
                                      x_coa_f                      =>  l_stud_det.coa_f,
                                      x_coa_i                      =>  l_stud_det.coa_i,
                                      x_disbursement_hold          =>  l_stud_det.disbursement_hold,
                                      x_fa_process_status          =>  l_stud_det.fa_process_status,
                                      x_notification_status        =>  l_stud_det.notification_status,
                                      x_notification_status_date   =>  l_stud_det.notification_status_date,
                                      x_packaging_status           =>  l_stud_det.packaging_status,
                                      x_packaging_status_date      =>  l_stud_det.packaging_status_date,
                                      x_total_package_accepted     =>  l_stud_det.total_package_accepted,
                                      x_total_package_offered      =>  l_stud_det.total_package_offered,
                                      x_admstruct_id               =>  l_stud_det.admstruct_id,
                                      x_admsegment_1               =>  l_stud_det.admsegment_1,
                                      x_admsegment_2               =>  l_stud_det.admsegment_2,
                                      x_admsegment_3               =>  l_stud_det.admsegment_3,
                                      x_admsegment_4               =>  l_stud_det.admsegment_4,
                                      x_admsegment_5               =>  l_stud_det.admsegment_5,
                                      x_admsegment_6               =>  l_stud_det.admsegment_6,
                                      x_admsegment_7               =>  l_stud_det.admsegment_7,
                                      x_admsegment_8               =>  l_stud_det.admsegment_8,
                                      x_admsegment_9               =>  l_stud_det.admsegment_9,
                                      x_admsegment_10              =>  l_stud_det.admsegment_10,
                                      x_admsegment_11              =>  l_stud_det.admsegment_11,
                                      x_admsegment_12              =>  l_stud_det.admsegment_12,
                                      x_admsegment_13              =>  l_stud_det.admsegment_13,
                                      x_admsegment_14              =>  l_stud_det.admsegment_14,
                                      x_admsegment_15              =>  l_stud_det.admsegment_15,
                                      x_admsegment_16              =>  l_stud_det.admsegment_16,
                                      x_admsegment_17              =>  l_stud_det.admsegment_17,
                                      x_admsegment_18              =>  l_stud_det.admsegment_18,
                                      x_admsegment_19              =>  l_stud_det.admsegment_19,
                                      x_admsegment_20              =>  l_stud_det.admsegment_20,
                                      x_packstruct_id              =>  l_stud_det.packstruct_id,
                                      x_packsegment_1              =>  l_stud_det.packsegment_1,
                                      x_packsegment_2              =>  l_stud_det.packsegment_2,
                                      x_packsegment_3              =>  l_stud_det.packsegment_3,
                                      x_packsegment_4              =>  l_stud_det.packsegment_4,
                                      x_packsegment_5              =>  l_stud_det.packsegment_5,
                                      x_packsegment_6              =>  l_stud_det.packsegment_6,
                                      x_packsegment_7              =>  l_stud_det.packsegment_7,
                                      x_packsegment_8              =>  l_stud_det.packsegment_8,
                                      x_packsegment_9              =>  l_stud_det.packsegment_9,
                                      x_packsegment_10             =>  l_stud_det.packsegment_10,
                                      x_packsegment_11             =>  l_stud_det.packsegment_11,
                                      x_packsegment_12             =>  l_stud_det.packsegment_12,
                                      x_packsegment_13             =>  l_stud_det.packsegment_13,
                                      x_packsegment_14             =>  l_stud_det.packsegment_14,
                                      x_packsegment_15             =>  l_stud_det.packsegment_15,
                                      x_packsegment_16             =>  l_stud_det.packsegment_16,
                                      x_packsegment_17             =>  l_stud_det.packsegment_17,
                                      x_packsegment_18             =>  l_stud_det.packsegment_18,
                                      x_packsegment_19             =>  l_stud_det.packsegment_19,
                                      x_packsegment_20             =>  l_stud_det.packsegment_20,
                                      x_miscstruct_id              =>  l_stud_det.miscstruct_id,
                                      x_miscsegment_1              =>  l_stud_det.miscsegment_1,
                                      x_miscsegment_2              =>  l_stud_det.miscsegment_2,
                                      x_miscsegment_3              =>  l_stud_det.miscsegment_3,
                                      x_miscsegment_4              =>  l_stud_det.miscsegment_4,
                                      x_miscsegment_5              =>  l_stud_det.miscsegment_5,
                                      x_miscsegment_6              =>  l_stud_det.miscsegment_6,
                                      x_miscsegment_7              =>  l_stud_det.miscsegment_7,
                                      x_miscsegment_8              =>  l_stud_det.miscsegment_8,
                                      x_miscsegment_9              =>  l_stud_det.miscsegment_9,
                                      x_miscsegment_10             =>  l_stud_det.miscsegment_10,
                                      x_miscsegment_11             =>  l_stud_det.miscsegment_11,
                                      x_miscsegment_12             =>  l_stud_det.miscsegment_12,
                                      x_miscsegment_13             =>  l_stud_det.miscsegment_13,
                                      x_miscsegment_14             =>  l_stud_det.miscsegment_14,
                                      x_miscsegment_15             =>  l_stud_det.miscsegment_15,
                                      x_miscsegment_16             =>  l_stud_det.miscsegment_16,
                                      x_miscsegment_17             =>  l_stud_det.miscsegment_17,
                                      x_miscsegment_18             =>  l_stud_det.miscsegment_18,
                                      x_miscsegment_19             =>  l_stud_det.miscsegment_19,
                                      x_miscsegment_20             =>  l_stud_det.miscsegment_20,
                                      x_prof_judgement_flg         =>  l_stud_det.prof_judgement_flg,
                                      x_nslds_data_override_flg    =>  l_stud_det.nslds_data_override_flg ,
                                      x_target_group               =>  l_stud_det.target_group,
                                      x_coa_fixed                  =>  l_stud_det.coa_fixed,
                                      x_coa_pell                   =>  l_stud_det.coa_pell,
                                      x_profile_status             =>  l_stud_det.profile_status,
                                      x_profile_status_date        =>  l_stud_det.profile_status_date,
                                      x_profile_fc                 =>  l_stud_det.profile_fc,
                                      x_tolerance_amount           =>  l_stud_det.tolerance_amount,
                                      x_manual_disb_hold           =>  l_stud_det.manual_disb_hold,
                                      x_mode                       =>   'R',
                                      x_pell_alt_expense           =>   l_stud_det.pell_alt_expense,
                                      x_assoc_org_num              =>  l_stud_det.assoc_org_num,
                                      x_award_fmly_contribution_type => l_stud_det.award_fmly_contribution_type,
                                      x_isir_locked_by             =>  l_stud_det.isir_locked_by,
                                      x_adnl_unsub_loan_elig_flag  =>   l_stud_det.adnl_unsub_loan_elig_flag,
                                      x_lock_awd_flag              => l_stud_det.lock_awd_flag,
                                      x_lock_coa_flag              => l_stud_det.lock_coa_flag
                                     );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN.UPDATE_FA_BASE_AWD' ||' ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception ;
END update_fabase_awds;


FUNCTION get_org_id RETURN NUMBER AS
    l_org_id NUMBER(15);
   CURSOR get_orgid IS
      SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),NULL)
      FROM dual;
BEGIN
   -- Commented out NOCOPY by jbegum as part of Enh bug #2222272
   -- This code has been commented out NOCOPY to remove multi org functionality from OSS
   /* OPEN get_orgid;
    FETCH get_orgid INTO l_org_id;
    CLOSE get_orgid;*/

    -- Added by jbegum as part of Enh bug #2222272
    -- The org_id is being passed as null to remove multi org functionality from OSS
    l_org_id := NULL;

   RETURN l_org_id;

EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.GET_ORG_ID' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_org_id;

/*
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  tsailaja		  17-Jan-2006    removed Exception handling as it would be handled by the calling routine
  ||								  changes made against bug No: 4947880
*/
PROCEDURE set_org_id(p_context IN VARCHAR2) AS
  p_org_id Varchar2(10);
BEGIN
	igs_ge_gen_003.set_org_id(p_context);
END set_org_id;


PROCEDURE update_fmast( x_old_ref in igf_aw_award_all%ROWTYPE,
                        x_new_ref in igf_aw_award_all%ROWTYPE,
                        flag in Varchar )
IS
  /*
  ||  Created By : pkpatel
  ||  Created On : 11-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad       24-Oct-2005      cancelled_amt was getting updated incorrectly.
  ||                                  Fixed this. Note that, when a Offered/Accepted award (with
  ||                                  award amount say X) is Cancelled, then the cancelled_amt
  ||                                  of the fund is 0 and not X. The cancelled_amt for a fund
  ||                                  always remains at 0 and it is not used anywhere.
  ||
  ||  museshad       14-Jul-2005      Build FA 140.
  ||                                  Modified TBH call due to the addition of new
  ||                                  columns to igf_aw_fund_mast_all table.
  ||
  ||  smvk           10_feb_2003      Bug # 2758812. Added send_without_doc column in the igf_aw_fund_mast_pkg.update_row call.
  ||
  ||  brajendr       19-Dec-2002      Bug # 2708599
  ||                                  Modifed the procedure update_fmast for deletion of Simulated awards,
  ||                                  earlier it was looking at new refferences, modified to old refferences
  ||
  ||  pkpatel        11-DEC-2001      Bug NO:2154941 Disbursement DLD
  ||                                  Removed the reference to dropped columns from, IGF_AW_FUND_MAST
  ||
  ||  cdcruz         06-MAY-2002      Bug NO: 2310222 Summary Tab updation
  ||                                  All summary column counts and totals modified
 */


  CURSOR c_fmast( x_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT fmast.*
    FROM igf_aw_fund_mast fmast
    WHERE fund_id = x_fund_id ;

  l_fmast  c_fmast%ROWTYPE;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','flag:'||flag);
  END IF;
  IF ( flag = 'DELETE' ) THEN
    OPEN  c_fmast( x_old_ref.fund_id );
  ELSE
    OPEN  c_fmast( x_new_ref.fund_id );
  END IF;

  FETCH c_fmast INTO l_fmast;
  IF ( c_fmast%NOTFOUND ) THEN
    CLOSE c_fmast;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_fmast;

  -- For simulation no updation to fund manager
  -- Simulated award cannot be change to any other status

  IF ( x_old_ref.award_status = 'SIMULATED' )  THEN
    RETURN;
  END IF;

  IF ( flag =  'INSERT' ) THEN


      IF ( x_new_ref.award_status = 'OFFERED'  ) THEN
        l_fmast.offered_amt   := NVL(l_fmast.offered_amt,0)   + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_offered := NVL(l_fmast.total_offered,0) + 1 ;

      ELSIF ( x_new_ref.award_status = 'ACCEPTED' ) THEN
        l_fmast.offered_amt    := NVL(l_fmast.offered_amt,0)    + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_offered  := NVL(l_fmast.total_offered,0)  + 1 ;
        l_fmast.accepted_amt   := NVL(l_fmast.accepted_amt,0)   + NVL(x_new_ref.accepted_amt,0) ;
        l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) + 1 ;

      END IF;


  ELSIF ( flag = 'UPDATE' ) THEN

    -- First update the amounts which is independent of Status

     l_fmast.accepted_amt   := NVL(l_fmast.accepted_amt,0) - NVL(x_old_ref.accepted_amt,0)  + NVL(x_new_ref.accepted_amt,0) ;
     l_fmast.offered_amt    := NVL(l_fmast.offered_amt,0) - NVL(x_old_ref.offered_amt,0)  + NVL(x_new_ref.offered_amt,0) ;
     l_fmast.disbursed_amt  := NVL(l_fmast.disbursed_amt ,0) - NVL(x_old_ref.paid_amt ,0)  + NVL(x_new_ref.paid_amt,0) ;

     -- Update the Disbursed Count ( If the paid amt has just incremented then +1

     IF NVL(x_new_ref.paid_amt,0) > 0 and NVL(x_old_ref.paid_amt,0) = 0 THEN

       l_fmast.total_disbursed := NVL(l_fmast.total_disbursed,0) + 1 ;

     ELSIF NVL(x_new_ref.paid_amt,0) = 0 and NVL(x_old_ref.paid_amt,0) > 0  THEN

       l_fmast.total_disbursed := NVL(l_fmast.total_disbursed,0) - 1 ;

     END IF;

    -- Status updation determines the change in counts

    IF ( x_old_ref.award_status = 'OFFERED' ) THEN

      IF ( x_new_ref.award_status = 'ACCEPTED'  ) THEN
        l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) + 1 ;

      ELSIF ( x_new_ref.award_status = 'CANCELLED' ) THEN
        l_fmast.cancelled_amt   := NVL(l_fmast.cancelled_amt,0)   + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) + 1 ;

      ELSIF ( x_new_ref.award_status = 'DECLINED' ) THEN
        l_fmast.declined_amt   := NVL(l_fmast.declined_amt,0)   + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined := NVL(l_fmast.total_declined,0) + 1 ;

      END IF;

    ELSIF ( x_old_ref.award_status = 'ACCEPTED'  ) THEN

      IF ( x_new_ref.award_status =  'OFFERED'  ) THEN
        l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) - 1 ;

      ELSIF ( x_new_ref.award_status = 'CANCELLED' ) THEN
        l_fmast.total_accepted  := NVL(l_fmast.total_accepted,0)  - 1 ;
        l_fmast.cancelled_amt   := NVL(l_fmast.cancelled_amt,0)   + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) + 1 ;

      ELSIF ( x_new_ref.award_status = 'DECLINED' ) THEN
        l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) - 1 ;
        l_fmast.declined_amt   := NVL(l_fmast.declined_amt,0)   + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined := NVL(l_fmast.total_declined,0) + 1 ;

      END IF;

    ELSIF ( x_old_ref.award_status = 'CANCELLED' ) THEN

      IF ( x_new_ref.award_status = 'ACCEPTED'  ) THEN
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) - 1 ;
        l_fmast.total_accepted  := NVL(l_fmast.total_accepted,0)  + 1 ;

      ELSIF ( x_new_ref.award_status = 'OFFERED' ) THEN
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) - 1 ;

      ELSIF ( x_new_ref.award_status = 'DECLINED' ) THEN
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) - 1 ;
        l_fmast.declined_amt    := NVL(l_fmast.declined_amt,0)    + NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined  := NVL(l_fmast.total_declined,0)  + 1 ;

      END IF;

    ELSIF ( x_old_ref.award_status = 'DECLINED' ) THEN

      IF ( x_new_ref.award_status = 'ACCEPTED'  ) THEN
        l_fmast.declined_amt   := NVL(l_fmast.declined_amt,0)   - NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined := NVL(l_fmast.total_declined,0) - 1 ;
        l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) + 1 ;

      ELSIF ( x_new_ref.award_status =  'OFFERED'  ) THEN
        l_fmast.declined_amt   := NVL(l_fmast.declined_amt,0) - NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined := NVL(l_fmast.total_declined,0) - 1 ;

      ELSIF ( x_new_ref.award_status = 'CANCELLED' ) THEN
        l_fmast.declined_amt    := NVL(l_fmast.declined_amt,0)    - NVL(x_new_ref.offered_amt,0) ;
        l_fmast.total_declined  := NVL(l_fmast.total_declined,0)  - 1 ;
        l_fmast.cancelled_amt   := NVL(l_fmast.cancelled_amt,0)   + x_new_ref.offered_amt ;
        l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) + 1 ;

     END IF;
   END IF;

  ELSIF ( flag = 'DELETE' ) THEN


      l_fmast.offered_amt    := NVL(l_fmast.offered_amt,0)    - NVL(x_old_ref.offered_amt,0) ;
      l_fmast.accepted_amt   := NVL(l_fmast.accepted_amt,0)   - NVL(x_old_ref.accepted_amt,0) ;

      l_fmast.total_offered  := NVL(l_fmast.total_offered,0)  - 1 ;


    IF ( x_old_ref.award_status = 'ACCEPTED'  ) THEN

      l_fmast.total_accepted := NVL(l_fmast.total_accepted,0) - 1 ;

    ELSIF ( x_old_ref.award_status = 'CANCELLED' ) THEN
      l_fmast.cancelled_amt   := NVL(l_fmast.cancelled_amt,0)   - NVL(x_old_ref.offered_amt,0) ;
      l_fmast.total_cancelled := NVL(l_fmast.total_cancelled,0) - 1 ;

    ELSIF ( x_old_ref.award_status = 'DECLINED' ) THEN
      l_fmast.declined_amt   := NVL(l_fmast.declined_amt,0)   - NVL(x_old_ref.offered_amt,0) ;
      l_fmast.total_declined := NVL(l_fmast.total_declined,0) - 1 ;

    END IF;


  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.offered_amt:'||l_fmast.offered_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.accepted_amt:'||l_fmast.accepted_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.total_offered:'||l_fmast.total_offered);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.cancelled_amt:'||l_fmast.cancelled_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.total_cancelled:'||l_fmast.total_cancelled);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.declined_amt:'||l_fmast.declined_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_fmast.debug','l_fmast.total_declined:'||l_fmast.total_declined);
  END IF;
  igf_aw_fund_mast_pkg.update_row (
          x_rowid                => l_fmast.row_id,
          x_fund_id              => l_fmast.fund_id,
          x_fund_code            => l_fmast.fund_code,
          x_ci_cal_type          => l_fmast.ci_cal_type,
          x_ci_sequence_number   => l_fmast.ci_sequence_number,
          x_description          => l_fmast.description,
          x_discontinue_fund     => l_fmast.discontinue_fund,
          x_entitlement          => l_fmast.entitlement,
          x_auto_pkg             => l_fmast.auto_pkg,
          x_self_help            => l_fmast.self_help,
          x_allow_man_pkg        => l_fmast.allow_man_pkg,
          x_update_need          => l_fmast.update_need,
          x_disburse_fund        => l_fmast.disburse_fund,
          x_available_amt        => l_fmast.available_amt,
          x_offered_amt          => l_fmast.offered_amt,
          x_pending_amt          => l_fmast.pending_amt,
          x_accepted_amt         => l_fmast.accepted_amt,
          x_declined_amt         => l_fmast.declined_amt,
          x_cancelled_amt        => l_fmast.cancelled_amt,
          x_remaining_amt        => l_fmast.remaining_amt,
          x_enrollment_status    => l_fmast.enrollment_status,
          x_prn_award_letter     => l_fmast.prn_award_letter,
          x_over_award_amt       => l_fmast.over_award_amt,
          x_over_award_perct     => l_fmast.over_award_perct,
          x_min_award_amt        => l_fmast.min_award_amt,
          x_max_award_amt        => l_fmast.max_award_amt,
          x_max_yearly_amt       => l_fmast.max_yearly_amt,
          x_max_life_amt         => l_fmast.max_life_amt,
          x_max_life_term        => l_fmast.max_life_term,
          x_fm_fc_methd          => l_fmast.fm_fc_methd,
          x_roundoff_fact        => l_fmast.roundoff_fact,
          x_replace_fc           => l_fmast.replace_fc,
          x_allow_overaward      => l_fmast.allow_overaward,
          x_pckg_awd_stat        => l_fmast.pckg_awd_stat,
          x_org_record_req       => l_fmast.org_record_req,
          x_disb_record_req      => l_fmast.disb_record_req,
          x_prom_note_req        => l_fmast.prom_note_req,
          x_min_num_disb         => l_fmast.min_num_disb,
          x_max_num_disb         => l_fmast.max_num_disb,
          X_FEE_TYPE             => l_fmast.FEE_TYPE ,
          x_total_offered        => l_fmast.total_offered,
          x_total_accepted       => l_fmast.total_accepted,
          x_total_declined       => l_fmast.total_declined,
          x_total_revoked        => l_fmast.total_revoked,
          x_total_cancelled      => l_fmast.total_cancelled,
          x_total_disbursed      => l_fmast.total_disbursed,
          x_total_committed      => l_fmast.total_committed,
          x_committed_amt        => l_fmast.committed_amt,
          x_disbursed_amt        => l_fmast.disbursed_amt,
          x_awd_notice_txt       => l_fmast.awd_notice_txt,
          x_attribute_category   => l_fmast.attribute_category,
          x_attribute1           => l_fmast.attribute1,
          x_attribute2           => l_fmast.attribute2,
          x_attribute3           => l_fmast.attribute3,
          x_attribute4           => l_fmast.attribute4,
          x_attribute5           => l_fmast.attribute5,
          x_attribute6           => l_fmast.attribute6,
          x_attribute7           => l_fmast.attribute7,
          x_attribute8           => l_fmast.attribute8,
          x_attribute9           => l_fmast.attribute9,
          x_attribute10          => l_fmast.attribute10,
          x_attribute11          => l_fmast.attribute11,
          x_attribute12          => l_fmast.attribute12,
          x_attribute13          => l_fmast.attribute13,
          x_attribute14          => l_fmast.attribute14,
          x_attribute15          => l_fmast.attribute15,
          x_attribute16          => l_fmast.attribute16,
          x_attribute17          => l_fmast.attribute17,
          x_attribute18          => l_fmast.attribute18,
          x_attribute19          => l_fmast.attribute19,
          x_attribute20          => l_fmast.attribute20,
          x_disb_verf_da         => l_fmast.disb_verf_da,
          x_fund_exp_da          => l_fmast.fund_exp_da,
          x_nslds_disb_da        => l_fmast.nslds_disb_da,
          x_disb_exp_da          => l_fmast.disb_exp_da,
          x_fund_recv_reqd       => l_fmast.fund_recv_reqd,
          x_show_on_bill         => l_fmast.show_on_bill,
          x_bill_desc            => l_fmast.bill_desc,
          x_credit_type_id       => l_fmast.credit_type_id,
          x_spnsr_ref_num        => l_fmast.spnsr_ref_num,
          x_party_id             => l_fmast.party_id,
          x_spnsr_fee_type       => l_fmast.spnsr_fee_type,
          x_min_credit_points    => l_fmast.min_credit_points,
          x_group_id             => l_fmast.group_id,
          x_threshold_perct      => l_fmast.threshold_perct,
          x_threshold_value      => l_fmast.threshold_value,
          x_spnsr_attribute_category => l_fmast.spnsr_attribute_category,
          x_spnsr_attribute1     => l_fmast.spnsr_attribute1,
          x_spnsr_attribute2     => l_fmast.spnsr_attribute2,
          x_spnsr_attribute3     => l_fmast.spnsr_attribute3,
          x_spnsr_attribute4     => l_fmast.spnsr_attribute4,
          x_spnsr_attribute5     => l_fmast.spnsr_attribute5,
          x_spnsr_attribute6     => l_fmast.spnsr_attribute6,
          x_spnsr_attribute7     => l_fmast.spnsr_attribute7,
          x_spnsr_attribute8     => l_fmast.spnsr_attribute8,
          x_spnsr_attribute9     => l_fmast.spnsr_attribute9,
          x_spnsr_attribute10    => l_fmast.spnsr_attribute10,
          x_spnsr_attribute11    => l_fmast.spnsr_attribute11,
          x_spnsr_attribute12    => l_fmast.spnsr_attribute12,
          x_spnsr_attribute13    => l_fmast.spnsr_attribute13,
          x_spnsr_attribute14    => l_fmast.spnsr_attribute14,
          x_spnsr_attribute15    => l_fmast.spnsr_attribute15,
          x_spnsr_attribute16    => l_fmast.spnsr_attribute16,
          x_spnsr_attribute17    => l_fmast.spnsr_attribute17,
          x_spnsr_attribute18    => l_fmast.spnsr_attribute18,
          x_spnsr_attribute19    => l_fmast.spnsr_attribute19,
          x_spnsr_attribute20    => l_fmast.spnsr_attribute20,
          x_ver_app_stat_override => l_fmast.ver_app_stat_override,
          x_gift_aid             => l_fmast.gift_aid,
          x_send_without_doc     => l_fmast.send_without_doc,  --  Bug # 2758812. Added send_without_doc column.
          x_re_pkg_verif_flag    => l_fmast.re_pkg_verif_flag,
          x_donot_repkg_if_code  => l_fmast.donot_repkg_if_code,
          x_lock_award_flag      => l_fmast.lock_award_flag,
          x_disb_rounding_code   => l_fmast.disb_rounding_code,
          x_view_only_flag                => l_fmast.view_only_flag,
          x_accept_less_amt_flag          => l_fmast.accept_less_amt_flag,
          x_allow_inc_post_accept_flag    => l_fmast.allow_inc_post_accept_flag,
          x_min_increase_amt              => l_fmast.min_increase_amt,
          x_allow_dec_post_accept_flag    => l_fmast.allow_dec_post_accept_flag,
          x_min_decrease_amt              => l_fmast.min_decrease_amt,
          x_allow_decln_post_accept_flag  => l_fmast.allow_decln_post_accept_flag,
          x_status_after_decline          => l_fmast.status_after_decline,
          x_fund_information_txt          => l_fmast.fund_information_txt,
          x_mode                          => 'R'
      );

EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.UPDATE_FMAST' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END update_fmast;

PROCEDURE update_award( p_award_id    IN igf_aw_award_all.award_id%TYPE,
                        p_disb_num    IN igf_aw_awd_disb_all.disb_num%TYPE,
                        p_disb_amt    IN igf_aw_awd_disb_all.disb_net_amt%TYPE,
                        p_disb_dt     IN igf_aw_awd_disb_all.disb_date%TYPE,
                        p_action      IN VARCHAR2,
                        x_called_from IN VARCHAR2
                        )
IS
--------------------------------------------------------------------------------------
-- museshad      05-Apr-2006       Bug 5140851. Do not reset paid amount for FWS awards
--                                 bcoz paid amount for FWS is maintained only at award
--                                 level. Retain award paid amout for FWS awards.
--------------------------------------------------------------------------------------
-- museshad      08-Aug-2005       Bug 3954451. Cancel award(and make offered amount
--                                 and accepted amount as 0), if all disbursements
--                                 in the award are cancelled.
--------------------------------------------------------------------------------------
-- veramach      05-Jul-2004       bug 3682032 Modified logic so that if error 'fund locked'
--                                 error is thrown by the awards table handler, it is passed
--                                 correctly to the caller
--------------------------------------------------------------------------------------
-- sjadhav       10-Dec-2003       FA 131 Changes
--                                 De-link auto update of Pell Disbursement and Pell
--                                 origination amounts
--------------------------------------------------------------------------------------
-- veramach      1-NOV-2003        FA 125(#3160568) Added apdlans_id in the calls
--                                 to igf_aw_award_pkg.update_row
--------------------------------------------------------------------------------------
-- rasahoo       09-Sep-2003       Bug 33094878  Added the call to update_fabase_awds
--                                 as the FA base rec was not getting updated when any
--                                 DML Operations performed from Disbursement form.
--------------------------------------------------------------------------------------
-- sjadhav       05-Feb-2003       FA116 Build - Bug 2758812
--                                 Modified update_award to set pell origination
--                                 status to 'R'.
--------------------------------------------------------------------------------------
-- sjadhav       Jan 25,2002       Bug ID : 2154941
--                                 This routine is called throgh table handler of
--                                 igf_aw_awd_Disb table. This routine updates
--                                 igf_aw_Award,igf_gr_rfms,igf_gr_rfms_disb
--                                 tables to reflect the changes made in
--                                 igf_aw_Awd_disb table
--------------------------------------------------------------------------------------

--
-- Cursor to Get The Award Record which will be updated
--
    CURSOR cur_award (p_award_id   igf_aw_award_all.award_id%TYPE)
    IS
    SELECT
    awd.rowid row_id,awd.*
    FROM
    igf_aw_award_all   awd
    WHERE
    award_id = p_award_id
    FOR UPDATE OF offered_amt;

    award_rec  cur_award%ROWTYPE;

--
-- Cursor to get Total Amounts from Disbursement Table
-- The paid amount should be updated by the Student Finance process,
-- that is why we are not taking the Paid amount in this cursor
--
    CURSOR cur_disb (p_award_id    igf_aw_award_all.award_id%TYPE)
    IS
    SELECT
    SUM(NVL(disb_gross_amt,0))     offered_amt,
    SUM(NVL(disb_accepted_amt,0))  accepted_amt,
    SUM(NVL(disb_paid_amt,0))      paid_amt
    FROM
    igf_aw_awd_disb_all
    WHERE
    award_id = p_award_id;

    disb_rec  cur_disb%ROWTYPE;

     -- Get the fund code of the fund.
    CURSOR cur_fund_dtls ( c_fund_id igf_aw_fund_mast.fund_id%TYPE)
    IS
    SELECT
    cat.fed_fund_code
    FROM
    igf_aw_fund_mast_all fmast,
    igf_aw_fund_cat_all  cat
    WHERE
    fmast.fund_id   = c_fund_id AND
    fmast.fund_code = cat.fund_code;

    cur_fund_dtls_rec cur_fund_dtls%ROWTYPE;

    -- museshad (Bug 3954451)
    -- Returns 'X' for all the non-cancelled disbursements in the award
    CURSOR cur_get_cancl_disb(cp_award_id igf_aw_award_all.award_id%TYPE)
    IS
      SELECT  'X'
      FROM    igf_aw_awd_disb_all
      WHERE   award_id = cp_award_id AND
              trans_type <> 'C';

    l_cur_get_cancl_disb_rec cur_get_cancl_disb%ROWTYPE;
    -- museshad (Bug 3954451)

    -- Get accepted amt
    CURSOR c_get_accept_amt(
                            cp_award_id igf_aw_award_all.award_id%TYPE
                           ) IS
      SELECT SUM(disb_accepted_amt) accepted_amt
        FROM igf_aw_awd_disb_all
       WHERE award_id = cp_award_id
         AND trans_type <> 'C';
    l_get_accept_amt c_get_accept_amt%ROWTYPE;

    l_app  VARCHAR2(80);
    l_name VARCHAR2(80);
    l_v_called_from  VARCHAR2(30);

    -- museshad (Bug 3954451)
    l_awd_status            igf_aw_award_all.award_status%TYPE;
    l_awd_off_amt           igf_aw_award_all.offered_amt%TYPE;
    l_awd_acc_amt           igf_aw_award_all.accepted_amt%TYPE;
    l_awd_proc_status_code  igf_aw_award_all.awd_proc_status_code%TYPE;
    -- museshad (Bug 3954451)

BEGIN
  l_v_called_from := x_called_from;
--
-- Get Number of Disbursements
--
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','p_award_id: '||p_award_id);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','p_disb_num: '||p_disb_num);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','p_disb_amt: '||p_disb_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','p_disb_dt:  '||p_disb_dt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','p_action:   '||p_action);
   END IF;


   OPEN   cur_award(p_award_id);
   FETCH  cur_award INTO award_rec;

   IF cur_award%NOTFOUND THEN
      CLOSE cur_award;
      NULL;

   ELSIF  cur_award%FOUND THEN
      CLOSE  cur_award;

      OPEN   cur_disb(p_award_id);
      FETCH  cur_disb INTO  disb_rec;
      CLOSE  cur_disb;

      OPEN cur_fund_dtls( award_rec.fund_id);
      FETCH cur_fund_dtls INTO cur_fund_dtls_rec;
      CLOSE cur_fund_dtls;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','disb_rec.paid_amt: '||disb_rec.paid_amt);
      END IF;

      /*
        If the user updates the disb_accepted_amt of an award while the award is still in
        OFFERED state, silently update the status to ACCEPTED
      */
      IF award_rec.award_status = 'OFFERED' THEN
        l_get_accept_amt := NULL;
        OPEN c_get_accept_amt(p_award_id);
        FETCH c_get_accept_amt INTO l_get_accept_amt;
        CLOSE c_get_accept_amt;

        IF NVL(l_get_accept_amt.accepted_amt,-1) > 0 THEN
          l_awd_status := 'ACCEPTED';
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_award.debug','setting the award status to accepted');
          END IF;
        END IF;
      END IF;

      -- museshad (Bug 3954451)
      IF chk_disb_status(p_award_id => p_award_id) THEN
        -- All disbursements in the award are cancelled.
        -- Mark Award  has cancelled
        IF award_rec.award_status <> 'DECLINED' THEN
        l_awd_status            :=  'CANCELLED';
        l_awd_off_amt           :=  0;
        l_awd_acc_amt           :=  0;
        l_awd_proc_status_code  :=  'AWARDED';
        ELSE
          l_awd_status            :=  'DECLINED';
          l_awd_off_amt           :=  disb_rec.offered_amt;
          l_awd_acc_amt           :=  0;
          l_awd_proc_status_code  :=  'AWARDED';
        END IF;
        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                         'igf.plsql.igf_aw_gen.update_award.debug',
                         'All the disbursements in award ' ||award_rec.award_id|| ' are cancelled. Cancelling the award.');
        END IF;
      ELSE
        -- There is atleast one uncancelled disbursement in the award.
        -- Retain existing values
        l_awd_status            :=  award_rec.award_status;
        l_awd_off_amt           :=  disb_rec.offered_amt;
        l_awd_acc_amt           :=  disb_rec.accepted_amt;
        l_awd_proc_status_code  :=  award_rec.awd_proc_status_code;
      END IF;
      -- museshad (Bug 3954451)

      /* Bug 5140851: Do not reset paid amount for FWS awards bcoz paid amount for FWS is maintained
                      only at award level. Retain award paid amout for FWS awards.
      */
      IF cur_fund_dtls_rec.fed_fund_code = 'FWS' THEN
        disb_rec.paid_amt := award_rec.paid_amt;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_gen.update_award.debug',
                         'Not updtaing award paid_amt with sum of disb paid_amt bcoz this is an FWS award. Retaining existing award paid amt. Award Id= '
                         ||award_rec.award_id);
        END IF;
      END IF;

      igf_aw_award_pkg.update_row ( x_mode               => 'R',
                                    x_rowid              => award_rec.row_id,
                                    x_award_id           => award_rec.award_id,
                                    x_fund_id            => award_rec.fund_id,
                                    x_base_id            => award_rec.base_id,
                                    x_offered_amt        => l_awd_off_amt,
                                    x_accepted_amt       => l_awd_acc_amt,
                                    x_paid_amt           => disb_rec.paid_amt,
                                    x_packaging_type     => award_rec.packaging_type,
                                    x_batch_id           => award_rec.batch_id,
                                    x_manual_update      => award_rec.manual_update,
                                    x_rules_override     => award_rec.rules_override,
                                    x_award_date         => award_rec.award_date,
                                    x_award_status       => l_awd_status,
                                    x_attribute_category => award_rec.attribute_category,
                                    x_attribute1         => award_rec.attribute1,
                                    x_attribute2         => award_rec.attribute2,
                                    x_attribute3         => award_rec.attribute3,
                                    x_attribute4         => award_rec.attribute4,
                                    x_attribute5         => award_rec.attribute5,
                                    x_attribute6         => award_rec.attribute6,
                                    x_attribute7         => award_rec.attribute7,
                                    x_attribute8         => award_rec.attribute8,
                                    x_attribute9         => award_rec.attribute9,
                                    x_attribute10        => award_rec.attribute10,
                                    x_attribute11        => award_rec.attribute11,
                                    x_attribute12        => award_rec.attribute12,
                                    x_attribute13        => award_rec.attribute13,
                                    x_attribute14        => award_rec.attribute14,
                                    x_attribute15        => award_rec.attribute15,
                                    x_attribute16        => award_rec.attribute16,
                                    x_attribute17        => award_rec.attribute17,
                                    x_attribute18        => award_rec.attribute18,
                                    x_attribute19        => award_rec.attribute19,
                                    x_attribute20        => award_rec.attribute20,
                                    x_rvsn_id            => award_rec.rvsn_id,
                                    x_alt_pell_schedule  => award_rec.alt_pell_schedule,
                                    x_award_number_txt   => award_rec.award_number_txt,
                                    x_legacy_record_flag => NULL,
                                    x_adplans_id         => award_rec.adplans_id,
                                    x_lock_award_flag    => award_rec.lock_award_flag,
                                    x_app_trans_num_txt  => award_rec.app_trans_num_txt,
                                    x_awd_proc_status_code => award_rec.awd_proc_status_code,
                                    x_notification_status_code  => award_rec.notification_status_code,
                                    x_notification_status_date  => award_rec.notification_status_date,
                                    x_called_from          => l_v_called_from,
                                    x_publish_in_ss_flag        => award_rec.publish_in_ss_flag
                                    );

   END IF;

   --
   -- Update FA Base record
   --
   update_fabase_awds(award_rec.base_id, 'REVISED');

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.parse_encoded(fnd_message.get_encoded,l_app,l_name);
    IF l_name IN (
                  'IGF_SL_CL_CHG_BSSN_REQD',
                  'IGF_SL_CL_CHG_GID_REQD',
                  'IGF_SL_CL_CHG_GSEQ_REQD',
                  'IGF_SL_CL_CHG_LID_REQD',
                  'IGF_SL_CL_CHG_LNUMB_REQD',
                  'IGF_SL_CL_CHG_LOANT_REQD',
                  'IGF_SL_CL_CHG_SCHID_REQD',
                  'IGF_SL_CL_CHG_SCHID_REQD',
                  'IGF_SL_CL_CHG_SSSN_REQD',
                  'IGF_SL_CL_GRD_AMT_VAL',
                  'IGS_GE_INVALID_VALUE',
                  'IGF_AW_FUND_LOCK_ERR',
                  'IGF_AW_LOAN_LMT_NOT_FND',      -- mnade 1-Feb-2005 - 4089662
                  'IGF_AW_LOAN_LMT_NOT_FND_WNG'
                ) THEN
      fnd_message.set_name(SUBSTR(l_name,1,3),l_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception ;
    ELSE
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN.UPDATE_AWARD' || ' ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception ;
    END IF;
END update_award;


PROCEDURE check_ld_cal_tps( p_adplans_id       igf_aw_awd_dist_plans.adplans_id%TYPE,
                            p_found OUT NOCOPY VARCHAR2 ) IS
------------------------------------------------------------------
--Created by  :
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--veramach    11-NOV-2003     FA 125 multiple distr methods
--                            removed fund_id as parameter and added adplans_id
--                            changed p_found datatype from boolean to varchar2
-------------------------------------------------------------------

    --Get all terms using linked to the distribution plan
    CURSOR cur_check_terms(
                           p_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                          ) IS
    SELECT terms.adterms_id
      FROM igf_aw_dp_terms terms
     WHERE terms.adplans_id = p_adplans_id;
    l_check_terms cur_check_terms%ROWTYPE;
    --Get incomplete terms
    CURSOR cur_check_teach(
                           p_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                          ) IS
    SELECT terms.adterms_id
      FROM igf_aw_dp_terms terms
     WHERE terms.adplans_id = p_adplans_id
       AND NOT EXISTS (
                       SELECT 'x'
                         FROM igf_aw_dp_teach_prds tech
                        WHERE tech.adterms_id = terms.adterms_id
                      );
    l_check_teach cur_check_teach%ROWTYPE;
BEGIN
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.check_ld_cal_tps.debug','p_adplans_id:'||p_adplans_id);
  END IF;
  OPEN cur_check_terms(p_adplans_id);
  FETCH cur_check_terms INTO l_check_terms;
  IF cur_check_terms%FOUND THEN
    OPEN cur_check_teach(p_adplans_id);
    FETCH cur_check_teach INTO l_check_teach;
    IF cur_check_teach%NOTFOUND THEN
      p_found := 'TRUE';
    ELSE
      p_found := 'IGF_AW_DIST_TERMS_TEACH_FAIL';
    END IF;
  ELSE
    p_found := 'IGF_AW_DIST_PLAN_TERMS_FAIL';
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.CHECK_LD_CAL_TPS' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END check_ld_cal_tps;

PROCEDURE check_number_format(str varchar2,ret out NOCOPY number) IS

invalid_number       EXCEPTION;
PRAGMA               EXCEPTION_INIT(invalid_number,-01722);
l_cur_check_number   NUMBER ;

--Cursor that will convert the String into a Number
CURSOR cur_check_number IS
  SELECT TO_NUMBER(LTRIM(RTRIM(str)))
  FROM DUAL;

BEGIN

  ret:=0;

  OPEN cur_check_number;
  FETCH cur_check_number INTO l_cur_check_number;
  CLOSE cur_check_number;

EXCEPTION

    WHEN invalid_number THEN
    CLOSE cur_check_number;
    ret:=1;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.CHECK_NUMBER_FORMAT' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END check_number_format;

PROCEDURE depend_stat_2001
  (   p_base_id           IN   igf_ap_fa_base_rec.base_id%TYPE,
      p_isir_id           IN   igf_ap_isir_matched_all.isir_id%TYPE,
      p_method_code       IN   VARCHAR2,
      p_category          OUT NOCOPY  NUMBER,
      p_dependency_status OUT NOCOPY  VARCHAR2)
  AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 11-DEC-2001
  ||  Purpose :Bug No - 2142666 EFC DLD
  ||           It finds the Dependency Status and eligibility of student for processing Simplified and Auto Zero EFC.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  CDCRUZ          14-FEB-03       Obsoleted by the FACR105 Bug# 2758804
 */


BEGIN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.depend_stat_2001.debug','p_base_id:'||p_base_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.depend_stat_2001.debug','p_isir_id:'||p_isir_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.depend_stat_2001.debug','p_method_code:'||p_method_code);
     END IF;
     p_category := 0 ;
     p_dependency_status := '' ;

  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.DEPEND_STAT_2001' ||' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END depend_stat_2001;

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Searches for the award notification status for given person for given awarding period the terms for which
  ||  fall under the given awarding period. If all awards carry same notification status in that case carry the same with
  || latest date. In case there are multiple, return the least significant one , with latest date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE get_notification_status (
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_notification_status_code  OUT NOCOPY igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  OUT NOCOPY igf_aw_award_all.notification_status_date%TYPE
                        ) AS
    -- mnade 5/24/2005 using the base query from IGFAW016.pld for the same C_PROCESS_STATUS
    CURSOR c_process_status (cp_ci_cal_type             igs_ca_inst_all.cal_type%TYPE,
                             cp_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE,
                             cp_award_prd_code          igf_aw_awd_prd_term.award_prd_cd%TYPE,
                             cp_base_id                 igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
    SELECT TO_CHAR(MIN(status_order)) min_award_status, MAX(notification_status_date) notification_status_date
    FROM
    (SELECT
        awd.award_id,
        notification_status_code,
        notification_status_date,
        DECODE(AWD.notification_status_code,
          NULL, 99,
          'R', 1,
          'D', 2,
          'S', 3,
          'F', 3
          ) STATUS_ORDER
      FROM
        IGF_AW_AWARD_all AWD,
        IGF_AW_FUND_MAST FMAST
      WHERE
        FMAST.CI_CAL_TYPE = cp_ci_cal_type AND
        FMAST.CI_SEQUENCE_NUMBER = cp_ci_sequence_number AND
        AWD.FUND_ID = FMAST.FUND_ID AND
        AWD.BASE_ID = cp_base_id AND
        NOT EXISTS
          (SELECT DISB.LD_CAL_TYPE, DISB.LD_SEQUENCE_NUMBER
          FROM IGF_AW_AWD_DISB DISB
          WHERE
            DISB.AWARD_ID = AWD.AWARD_ID
          MINUS
          SELECT LD_CAL_TYPE, LD_SEQUENCE_NUMBER
          FROM IGF_AW_AWD_PRD_TERM APT
          WHERE APT.CI_CAL_TYPE = cp_ci_cal_type AND
            APT.CI_SEQUENCE_NUMBER = cp_ci_sequence_number AND
            APT.award_prd_cd = NVL(cp_award_prd_code, award_prd_cd))) temp;
    l_process_status                                    c_process_status%ROWTYPE;
    CURSOR  c_rev_mapping (cp_mapped_value              NUMBER)
    IS
    SELECT val_data FROM
    (
      SELECT 1 key_data, 'R' val_data from dual union all
      SELECT 2 key_data, 'D' val_data from dual union all
      SELECT 3 key_data, 'S' val_data from dual union all
      SELECT 4 key_data, 'F' val_data from dual
    ) MAPPING
    WHERE key_data = cp_mapped_value;
  BEGIN
    OPEN c_process_status (
            cp_ci_cal_type            => p_cal_type,
            cp_ci_sequence_number     => p_seq_num,
            cp_award_prd_code         => p_awarding_period,
            cp_base_id                => p_base_id);
    FETCH c_process_status INTO l_process_status;
    IF c_process_status%FOUND THEN                -- award rank found?
      OPEN c_rev_mapping (cp_mapped_value => l_process_status.min_award_status);
      FETCH c_rev_mapping INTO p_notification_status_code;
      p_notification_status_date := l_process_status.notification_status_date;
      CLOSE c_rev_mapping;
    END IF;                                       -- END award rank found?
    CLOSE c_process_status;
  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.GET_NOTIFICATION_STATUS ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END get_notification_status;

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Searches for awards for given person for given awarding period the terms for which
  ||  fall under the given awarding period. All awards will be updated to carry supplied
  ||  Notification Status and Notification Status Date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE update_notification_status (
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_notification_status_code  IN igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  IN igf_aw_award_all.notification_status_date%TYPE,
                        p_called_from               IN VARCHAR2
                        ) AS
    -- mnade 5/24/2005 using the base query from IGFAW016.pld for the same C_PROCESS_STATUS
    CURSOR c_awards    (cp_ci_cal_type             igs_ca_inst_all.cal_type%TYPE,
                        cp_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE,
                        cp_award_prd_code          igf_aw_awd_prd_term.award_prd_cd%TYPE,
                        cp_base_id                 igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
    SELECT
        awd.award_id
      FROM
        IGF_AW_AWARD_all AWD,
        IGF_AW_FUND_MAST FMAST
      WHERE
        FMAST.CI_CAL_TYPE             = cp_ci_cal_type AND
        FMAST.CI_SEQUENCE_NUMBER      = cp_ci_sequence_number AND
        AWD.FUND_ID                   = FMAST.FUND_ID AND
        AWD.BASE_ID                   = cp_base_id AND
        NOT EXISTS
          (SELECT DISB.LD_CAL_TYPE, DISB.LD_SEQUENCE_NUMBER
          FROM IGF_AW_AWD_DISB DISB
          WHERE
            DISB.AWARD_ID = AWD.AWARD_ID
          MINUS
          SELECT LD_CAL_TYPE, LD_SEQUENCE_NUMBER
          FROM IGF_AW_AWD_PRD_TERM APT
          WHERE APT.CI_CAL_TYPE       = cp_ci_cal_type AND
            APT.CI_SEQUENCE_NUMBER    = cp_ci_sequence_number AND
            APT.award_prd_cd          = NVL(cp_award_prd_code, award_prd_cd));
    award_rec                                       c_awards%ROWTYPE;
  BEGIN
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_cal_type                    - ' || p_cal_type);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_seq_num                     - ' || p_seq_num);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_awarding_period             - ' || p_awarding_period);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_base_id                     - ' || p_base_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_notification_status_code    - ' || p_notification_status_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_notification_status_date    - ' || p_notification_status_date);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_awarding_period             - ' || p_awarding_period);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_called_from                 - ' || p_called_from);
     END IF;
    OPEN  c_awards ( cp_ci_cal_type            => p_cal_type,
                     cp_ci_sequence_number     => p_seq_num,
                     cp_award_prd_code         => p_awarding_period,
                     cp_base_id                => p_base_id);
    LOOP                                          -- Award Noification Status Update
      FETCH c_awards INTO award_rec;
      EXIT WHEN c_awards%NOTFOUND;
      update_awd_notification_status  (
                              p_award_id                  => award_rec.award_id,
                              p_notification_status_code  => p_notification_status_code,
                              p_notification_status_date  => p_notification_status_date,
                              p_called_from               => p_called_from
                              );
    END LOOP;                                     -- END Award Noification Status Update
  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.UPDATE_NOTIFICATION_STATUS ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END update_notification_status;

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Updates the Notification Status and Notification Status Date for given award.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE update_awd_notification_status  (
                        p_award_id                  IN igf_aw_award_all.award_id%TYPE,
                        p_notification_status_code  IN igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  IN igf_aw_award_all.notification_status_date%TYPE,
                        p_called_from               IN VARCHAR2
                        ) AS
    -- mnade 5/24/2005 using the base query from IGFAW016.pld for the same C_PROCESS_STATUS
    CURSOR c_award     (cp_award_id                 igf_aw_award_all.award_id%TYPE)
    IS
    SELECT
        awd.rowid row_id, awd.*
      FROM
        IGF_AW_AWARD_all awd
      WHERE
        awd.award_id = cp_award_id;
--    award_rec                                       c_award%ROWTYPE;
  BEGIN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_award_id                    - ' || p_award_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_notification_status_code    - ' || p_notification_status_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_notification_status_date    - ' || p_notification_status_date);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen.update_notification_status.debug', 'p_called_from                 - ' || p_called_from);
     END IF;

--    OPEN c_award (cp_award_id => p_award_id);
    FOR award_rec IN c_award (cp_award_id => p_award_id) LOOP
--    FETCH c_award INTO award_rec;
    igf_aw_award_pkg.update_row ( x_mode                      => 'R',
                                  x_rowid                     => award_rec.row_id,
                                  x_award_id                  => award_rec.award_id,
                                  x_fund_id                   => award_rec.fund_id,
                                  x_base_id                   => award_rec.base_id,
                                  x_offered_amt               => award_rec.offered_amt,
                                  x_accepted_amt              => award_rec.accepted_amt,
                                  x_paid_amt                  => award_rec.paid_amt,
                                  x_packaging_type            => award_rec.packaging_type,
                                  x_batch_id                  => award_rec.batch_id,
                                  x_manual_update             => award_rec.manual_update,
                                  x_rules_override            => award_rec.rules_override,
                                  x_award_date                => award_rec.award_date,
                                  x_award_status              => award_rec.award_status,
                                  x_attribute_category        => award_rec.attribute_category,
                                  x_attribute1                => award_rec.attribute1,
                                  x_attribute2                => award_rec.attribute2,
                                  x_attribute3                => award_rec.attribute3,
                                  x_attribute4                => award_rec.attribute4,
                                  x_attribute5                => award_rec.attribute5,
                                  x_attribute6                => award_rec.attribute6,
                                  x_attribute7                => award_rec.attribute7,
                                  x_attribute8                => award_rec.attribute8,
                                  x_attribute9                => award_rec.attribute9,
                                  x_attribute10               => award_rec.attribute10,
                                  x_attribute11               => award_rec.attribute11,
                                  x_attribute12               => award_rec.attribute12,
                                  x_attribute13               => award_rec.attribute13,
                                  x_attribute14               => award_rec.attribute14,
                                  x_attribute15               => award_rec.attribute15,
                                  x_attribute16               => award_rec.attribute16,
                                  x_attribute17               => award_rec.attribute17,
                                  x_attribute18               => award_rec.attribute18,
                                  x_attribute19               => award_rec.attribute19,
                                  x_attribute20               => award_rec.attribute20,
                                  x_rvsn_id                   => award_rec.rvsn_id,
                                  x_alt_pell_schedule         => award_rec.alt_pell_schedule,
                                  x_award_number_txt          => award_rec.award_number_txt,
                                  x_legacy_record_flag        => NULL,
                                  x_adplans_id                => award_rec.adplans_id,
                                  x_lock_award_flag           => award_rec.lock_award_flag,
                                  x_app_trans_num_txt         => award_rec.app_trans_num_txt,
                                  x_awd_proc_status_code      => award_rec.awd_proc_status_code,
                                  x_notification_status_code  => p_notification_status_code,
                                  x_notification_status_date  => p_notification_status_date,
                                  x_called_from               => p_called_from,
                                  x_publish_in_ss_flag        => award_rec.publish_in_ss_flag
                                  );
--    CLOSE c_award;
END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_GEN.UPDATE_AWD_NOTIFICATION_STATUS ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END update_awd_notification_status;


  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Gets the concurrent program name for the cp id being passed.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  FUNCTION get_concurrent_prog_name (p_program_id   IN fnd_concurrent_programs_tl.concurrent_program_id%TYPE) RETURN VARCHAR2 IS
    CURSOR c_cp_name IS
      SELECT
        user_concurrent_program_name
      FROM
        FND_CONCURRENT_PROGRAMS_TL
      WHERE
        APPLICATION_ID = 8406 AND
        CONCURRENT_PROGRAM_ID = p_program_id AND
        LANGUAGE = userenv('LANG');
    l_user_concurrent_program_name      fnd_concurrent_programs_tl.user_concurrent_program_name%TYPE;
  BEGIN
    OPEN c_cp_name;
    FETCH c_cp_name INTO l_user_concurrent_program_name;
    CLOSE c_cp_name;
    RETURN l_user_concurrent_program_name;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;
  END get_concurrent_prog_name;


  /*
  ||  Created By : mnade
  ||  Created On : 6/6/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Checks if there is any award locked under given awarding period for the student
  ||  and returns true of there is any award locked for the student.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  FUNCTION is_fund_locked_for_awd_period (
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_fund_id                   IN igf_aw_award_all.fund_id%TYPE
    ) RETURN BOOLEAN AS
  CURSOR locked_award_count_cur (
                        cp_base_id                  IN igf_ap_fa_base_rec_all.base_id%type,
                        cp_cal_type                 IN igs_ca_inst_all.cal_type%TYPE,
                        cp_seq_num                  IN igs_ca_inst_all.sequence_number%TYPE,
                        cp_awarding_period          IN igf_aw_award_prd.award_prd_cd%TYPE,
                        cp_fund_id                  IN igf_aw_award_all.fund_id%TYPE
  )
  IS
    SELECT
        COUNT(awd.award_id) lock_count
    FROM
        igf_aw_award_all awd,
        igf_aw_awd_disb_all disb,
        igf_aw_awd_prd_term apt
    WHERE
        disb.award_id = awd.award_id
        AND disb.ld_cal_type = apt.ld_cal_type
        AND disb.ld_sequence_number = apt.ld_sequence_number
        AND NVL(awd.lock_award_flag, 'N') = 'Y'
        AND awd.fund_id = cp_fund_id
        AND apt.ci_cal_type               = cp_cal_type
        AND apt.ci_sequence_number        = cp_seq_num
        AND apt.award_prd_cd              = NVL(cp_awarding_period, award_prd_cd)
        AND awd.base_id = cp_base_id;

    l_locked_award_count        NUMBER := 0;
    l_flag                      BOOLEAN   := FALSE;

  BEGIN
    OPEN locked_award_count_cur (
                        cp_base_id                  => p_base_id,
                        cp_cal_type                 => p_cal_type,
                        cp_seq_num                  => p_seq_num,
                        cp_awarding_period          => p_awarding_period,
                        cp_fund_id                  => p_fund_id
                    );
    FETCH locked_award_count_cur INTO l_locked_award_count;
    CLOSE locked_award_count_cur;
    IF l_locked_award_count > 0 THEN
      l_flag := TRUE;
    END IF;
    RETURN l_flag;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;



END igf_aw_gen;

/
