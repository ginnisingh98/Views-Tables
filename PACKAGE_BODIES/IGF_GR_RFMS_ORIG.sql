--------------------------------------------------------
--  DDL for Package Body IGF_GR_RFMS_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_RFMS_ORIG" AS
/* $Header: IGFGR02B.pls 120.4 2006/02/08 23:45:48 ridas ship $ */
------------------------------------------------------------------------
-- bvisvana   07-July-2005   Bug # 4008991 - IGF_GR_BATCH_DOES_NOT_EXIST replaced by IGF_SL_GR_BATCH_DOES_NO_EXIST
------------------------------------------------------------------------
--  ayedubat  20-OCT-2004   FA 149 COD-XML Standards build bug # 3416863
--                          Changed the logic as per the TD, FA149_TD_COD_XML_i1a.doc
------------------------------------------------------------------------
-- veramach   12-Mar-2004    bug 3490915
--                           Aded validation to check if award amounts in pell origination
--                           and student award level are equal or not
------------------------------------------------------------------------
-- veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
------------------------------------------------------------------------
-- ugummall   08-Jan-2003    Bug 3318202. Changed the order of parameters and removed
--                           the parameter p_org_id in main.
------------------------------------------------------------------------
-- ugummall   05-NOV-2003    Bug 3102439. FA 126 Multiple FA Offices.
--                           1. Added two extra parameters to main and rfms_orig procedures.
--                           2. Modified cursor cur_rfms to include reporting and attending pell ids.
--                           3. Removed l_rep_pell_id and its references. Used p_reporting_pell, newly
--                              passed parameter, in igf_gr_gen.{get_pell_trailer, get_pell_header} procedures.
--                           4. New cursor cur_attending_pell to check attending pell is a child of reporting pell or not.
--                           5. In rfms_orig prcodure processed only those records for which attending pell is
--                              a child of reporting pell id.
------------------------------------------------------------------------
-- ugummall   03-NOV-2003    Bug 3102439. FA 126 Multiple FA Offices.
--                           Added two extra parameters to igf_gr_gen.get_pell_header call.
------------------------------------------------------------------------
-- cdcruz     15-Aug-2003    Bug BUG FA121-3085558
--                           Check added to check for Transaction Number
--                           Match against Payment ISIR.
------------------------------------------------------------------------
-- sjadhav    01-Aug-2003    Bug BUG 3062062
--                           Removed code to re-calcuate efc/efc code
--                           after Origination is Sent
--------------------------------------------------------------------------
-- rasahoo    13-May-2003    Bug #2938258 If Origination Record is not
--                           part of this batch in the System then raise
--                           error.Cannot process Origination
--                           Record which status for acknowledgement
--                           processing is not "Sent".
---------------------------------------------------------------------------
-- sjadhav    06-Feb-2003    FA116 Build Bug - 2758812
--                           added invalid_version expcetion
--                           modified for 03-04 compliance
--                           output file in UPPERCASE
--------------------------------------------------------------------------
-- sjadhav    Bug 2460904    Before sending origination check for the
--                           ft pell amount and pell award amount.
--                           if pell award amount is more than ft pell
--                           amount do not send this origination record,
--                           log a message and skip
--                           use igf_gr_gen.get_pell_efc_code to get
--                           value for sec efc code
--
--------------------------------------------------------------------------
-- sjadhav    Bug 2383690    added igf_gr_gen.send_orig_disb call
--------------------------------------------------------------------------
-- sjadhav    Bug 2216956 -  FACR007 Removed flag parameter
--                           Added Award Year parameter to
--                           main_ack
--------------------------------------------------------------------------
-- sjadhav    18-jun-2001    Bug ID : 1823995 base_id is made null
--                           if the process is run for an award year
--------------------------------------------------------------------------
--
--------------------------------------------------------------------------
--  Created By : sjadhav
--  Date Created On : 2001/01/03
--------------------------------------------------------------------------
--

   no_data_in_table      EXCEPTION;
   param_error           EXCEPTION;
   batch_not_created     EXCEPTION;
   invalid_version       EXCEPTION;
   persid_grp_sql_stmt_error  EXCEPTION;

   l_cy_yr               VARCHAR2(10)      DEFAULT NULL; -- to hold cycle year
   l_msg_prn_1           BOOLEAN           DEFAULT TRUE;
   g_ver_num             VARCHAR2(30)      DEFAULT NULL; -- Flat File Version Number
   g_print_header        VARCHAR2(1)       DEFAULT 'N';
   l_header              VARCHAR2(1000);
   g_alt_code            VARCHAR2(80);

--
-- Main Cursor to pick up RFMS Records
-- for preparing Origination File
--

-- FA 126. This cursor cur_rfms is modified to include reporting and attending pell ids.

        CURSOR cur_rfms(l_base_id              igf_gr_rfms.base_id%TYPE,
                        l_ci_cal_type          igf_gr_rfms.ci_cal_type%TYPE,
                        l_ci_sequence_number   igf_gr_rfms.ci_sequence_number%TYPE,
                        cp_reporting_pell      igf_gr_rfms.rep_pell_id%TYPE,
                        cp_attending_pell      igf_gr_rfms.attending_campus_id%TYPE
                        )
        IS
        SELECT
                rfms.*
        FROM
                igf_gr_rfms rfms
        WHERE
        rfms.orig_action_code      = 'R'            AND
        rfms.base_id               = NVL(l_base_id,rfms.base_id)             AND
        rfms.ci_cal_type           = l_ci_cal_type  AND
        rfms.ci_sequence_number    = l_ci_sequence_number         AND
        rfms.rep_pell_id           = cp_reporting_pell            AND
        rfms.attending_campus_id   = NVL(cp_attending_pell, rfms.attending_campus_id)
        FOR UPDATE OF orig_action_code NOWAIT;

        rfms_rec        cur_rfms%ROWTYPE;



PROCEDURE update_orig_rec(p_rfms_rec cur_rfms%ROWTYPE,
                          p_rfmb_id  igf_gr_rfms_batch.rfmb_id%TYPE) IS
--
-- This procedure updates the rfms origination records
-- which are being sent to the external processor
-- orig_action_code is updated to 'S' to indicate that
-- the record has been processed and sent
-- Update the RFMB_ID  field in IGFGR004
--
BEGIN

     igf_gr_rfms_pkg.update_row(
                                 x_rowid                             => p_rfms_rec.row_id,
                                 x_origination_id                    => p_rfms_rec.origination_id,
                                 x_ci_cal_type                       => p_rfms_rec.ci_cal_type,
                                 x_ci_sequence_number                => p_rfms_rec.ci_sequence_number,
                                 x_base_id                           => p_rfms_rec.base_id,
                                 x_award_id                          => p_rfms_rec.award_id,
                                 x_rfmb_id                           => p_rfmb_id,
                                 x_sys_orig_ssn                      => p_rfms_rec.sys_orig_ssn,
                                 x_sys_orig_name_cd                  => p_rfms_rec.sys_orig_name_cd,
                                 x_transaction_num                   => p_rfms_rec.transaction_num,
                                 x_efc                               => p_rfms_rec.efc,
                                 x_ver_status_code                   => p_rfms_rec.ver_status_code,
                                 x_secondary_efc                     => p_rfms_rec.secondary_efc,
                                 x_secondary_efc_cd                  => p_rfms_rec.secondary_efc_cd,
                                 x_pell_amount                       => p_rfms_rec.pell_amount,
                                 x_pell_profile                      => p_rfms_rec.pell_profile,
                                 x_enrollment_status                 => p_rfms_rec.enrollment_status,
                                 x_enrollment_dt                     => p_rfms_rec.enrollment_dt,
                                 x_coa_amount                        => p_rfms_rec.coa_amount,
                                 x_academic_calendar                 => p_rfms_rec.academic_calendar,
                                 x_payment_method                    => p_rfms_rec.payment_method,
                                 x_total_pymt_prds                   => p_rfms_rec.total_pymt_prds,
                                 x_incrcd_fed_pell_rcp_cd            => p_rfms_rec.incrcd_fed_pell_rcp_cd,
                                 x_attending_campus_id               => p_rfms_rec.attending_campus_id,
                                 x_est_disb_dt1                      => p_rfms_rec.est_disb_dt1,
                                 x_orig_action_code                  => 'S',
                                 x_orig_status_dt                    => p_rfms_rec.orig_status_dt,
                                 x_orig_ed_use_flags                 => p_rfms_rec.orig_ed_use_flags,
                                 x_ft_pell_amount                    => p_rfms_rec.ft_pell_amount,
                                 x_prev_accpt_efc                    => p_rfms_rec.prev_accpt_efc,
                                 x_prev_accpt_tran_no                => p_rfms_rec.prev_accpt_tran_no,
                                 x_prev_accpt_sec_efc_cd             => p_rfms_rec.prev_accpt_sec_efc_cd,
                                 x_prev_accpt_coa                    => p_rfms_rec.prev_accpt_coa,
                                 x_orig_reject_code                  => p_rfms_rec.orig_reject_code,
                                 x_wk_inst_time_calc_pymt            => p_rfms_rec.wk_inst_time_calc_pymt,
                                 x_wk_int_time_prg_def_yr            => p_rfms_rec.wk_int_time_prg_def_yr,
                                 x_cr_clk_hrs_prds_sch_yr            => p_rfms_rec.cr_clk_hrs_prds_sch_yr,
                                 x_cr_clk_hrs_acad_yr                => p_rfms_rec.cr_clk_hrs_acad_yr,
                                 x_inst_cross_ref_cd                 => p_rfms_rec.inst_cross_ref_cd,
                                 x_low_tution_fee                    => p_rfms_rec.low_tution_fee,
                                 x_rec_source                        => p_rfms_rec.rec_source,
                                 x_pending_amount                    => p_rfms_rec.pending_amount,
                                 x_mode                              => 'R',
                                 x_birth_dt                          => p_rfms_rec.birth_dt,
                                 x_last_name                         => p_rfms_rec.last_name,
                                 x_first_name                        => p_rfms_rec.first_name,
                                 x_middle_name                       => p_rfms_rec.middle_name,
                                 x_current_ssn                       => p_rfms_rec.current_ssn,
                                 x_legacy_record_flag                => NULL,
                                 x_reporting_pell_cd                 => p_rfms_rec.rep_pell_id,
                                 x_rep_entity_id_txt                 => p_rfms_rec.rep_entity_id_txt,
                                 x_atd_entity_id_txt                 => p_rfms_rec.atd_entity_id_txt,
                                 x_note_message                      => p_rfms_rec.note_message,
                                 x_full_resp_code                    => p_rfms_rec.full_resp_code,
                                 x_document_id_txt                   => p_rfms_rec.document_id_txt );
EXCEPTION
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.UPDATE_ORIG_REC');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END update_orig_rec;

PROCEDURE  prepare_data
          ( p_rfms_rec cur_rfms%ROWTYPE,
            p_num_of_records IN OUT NOCOPY NUMBER,
            p_rfmb_id   IN  igf_gr_rfms_batch.rfmb_id%TYPE,
            p_originated IN OUT NOCOPY VARCHAR2,
            p_enrl_status_mesgnum IN NUMBER ) IS
------------------------------------------------------------------------
--
--    Created By : sjadhav
--
--    Date Created On : 2001/01/03
--    Purpose :This procedure loads the record data into datafile
--    Know limitations, enhancements or remarks
--    Change History:
--    Bug 2460904 Desc:Pell Formatting Issues
--    Who             When            What
--    ugummall        04-DEC-2003     Bug 3252832. FA 131 - COD Updates.
--                                    1. Added one parameter p_enrl_status_mesgnum to avoid bug(which may arise
--                                       in future.
--                                    2. Moved code up and down to improve performance and clarity.
--    mesriniv        22-jul-2002     Added IF Condition for Payment Method and Calendar.
--    (reverse chronological order - newest change first)
--
-----------------------------------------------------------------------

  l_data                   VARCHAR2(1000);
  l_wk_inst_time_calc_pymt VARCHAR2(5);
  l_wk_int_time_prg_def_yr VARCHAR2(5);
  l_cr_clk_hrs_acad_yr     VARCHAR2(5);
  l_cr_clk_hrs_prds_sch_yr VARCHAR2(5);
  l_enroll_stat            VARCHAR2(1);

  l_person_id  hz_parties.party_id%TYPE;
  student_dtl_cur igf_sl_gen.person_dtl_cur;
  student_dtl_rec igf_sl_gen.person_dtl_rec;

  -- This cursor gets disb_dates from igf_gr_rfms_disb
  -- for a particualr origination
  CURSOR cur_disb(l_orig_id igf_gr_rfms_disb.origination_id%TYPE) IS
   SELECT    disb_dt
     FROM    igf_gr_rfms_disb
    WHERE    origination_id = l_orig_id
    ORDER BY disb_ref_num;
  l_disbursement_dates       VARCHAR2(400);

BEGIN

  --
  -- Bug No : 1747297
  --
  -- Do not create origination record if any of the following field is null
  -- efc, pell award, total payment periods, academic
  -- calendar, payment mehtod, scheduled award, enrollment status, enrollment
  -- date, first disb date and transaction number.
  -- write into log file which origiantion id were not put into file
  --

  IF p_rfms_rec.efc               IS NULL OR
    p_rfms_rec.pell_amount       IS NULL OR
    p_rfms_rec.ft_pell_amount    IS NULL OR
    p_rfms_rec.transaction_num   IS NULL OR
    p_rfms_rec.academic_calendar IS NULL OR
    p_rfms_rec.payment_method    IS NULL OR
    p_rfms_rec.est_disb_dt1      IS NULL OR
    p_rfms_rec.total_pymt_prds   IS NULL OR
    p_rfms_rec.enrollment_status IS NULL OR
    p_rfms_rec.enrollment_dt     IS NULL
  THEN
    fnd_file.new_line(fnd_file.log,1);
    fnd_message.set_name('IGF','IGF_GR_ORIG_DATA_REQD');
    fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_rfms_rec.base_id));
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','EFC'),50) || ' : ' ||p_rfms_rec.efc);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','PELL_AMOUNT'),50) || ' : ' ||p_rfms_rec.pell_amount);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','FT_PELL_AMOUNT'),50) || ' : ' ||p_rfms_rec.ft_pell_amount);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','TRANSACTION_NUM'),50) || ' : ' ||p_rfms_rec.transaction_num);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ACADEMIC_CALENDAR'),50) || ' : ' ||p_rfms_rec.academic_calendar);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','PAYMENT_METHOD'),50) || ' : ' ||p_rfms_rec.payment_method);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','EST_DISB_DT1'),50) || ' : ' ||p_rfms_rec.est_disb_dt1);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','TOTAL_PYMT_PRDS'),50) || ' : ' ||p_rfms_rec.total_pymt_prds);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ENROLLMENT_STATUS'),50) || ' : ' ||p_rfms_rec.enrollment_status);
    fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ENROLLMENT_DT'),50) || ' : ' ||p_rfms_rec.enrollment_dt);
    -- 'Data not sufficient to create Origination Record for Person '
    fnd_file.new_line(fnd_file.log,1);
  ELSE

    --Set the value for Printing Header Record as 'Y' only if its 'N'
    --Bug 2460904
    IF g_print_header  ='N' THEN
      g_print_header :='Y';
    END IF;

    --Following IF conditions have been added as per bug 2460904
    --It is done with respect to the Pell Tech Document for 2002-2003
    --For Name Fields made as UPPER

    IF p_rfms_rec.payment_method = '1' THEN
      l_wk_inst_time_calc_pymt := LPAD(' ',2,' ');
      l_wk_int_time_prg_def_yr := LPAD(' ',2,' ');
    ELSE
      l_wk_inst_time_calc_pymt := LPAD(p_rfms_rec.wk_inst_time_calc_pymt,2,'0');
      l_wk_int_time_prg_def_yr := LPAD(p_rfms_rec.wk_int_time_prg_def_yr,2,'0');
    END IF;

    IF p_rfms_rec.payment_method ='4' THEN
      l_enroll_stat :=' ';
    ELSE
      l_enroll_stat := p_rfms_rec.enrollment_status;
    END IF;

    IF p_rfms_rec.academic_calendar IN ('1','2','3','4') THEN
      l_cr_clk_hrs_acad_yr     := LPAD(' ',4,' ');
      l_cr_clk_hrs_prds_sch_yr := LPAD(' ',4,' ');
    ELSE
      l_cr_clk_hrs_acad_yr     := LPAD(p_rfms_rec.cr_clk_hrs_acad_yr,4,'0');
      l_cr_clk_hrs_prds_sch_yr := LPAD(NVL(p_rfms_rec.cr_clk_hrs_prds_sch_yr,'0'),4,'0');
    END IF;

    -- Prepare disbursement dates.
    l_disbursement_dates := NULL;
    FOR  rec_disb IN cur_disb(p_rfms_rec.origination_id) LOOP
      l_disbursement_dates := l_disbursement_dates || RPAD(NVL(TO_CHAR(rec_disb.disb_dt,'YYYYMMDD'),' '),8);
    END LOOP;

    -- Get the person details by calling the procedure
    l_person_id := igf_gr_gen.get_person_id( P_BASE_ID => p_rfms_rec.base_id);

    student_dtl_rec := NULL;
    igf_sl_gen.get_person_details(l_person_id, student_dtl_cur);
    FETCH student_dtl_cur INTO student_dtl_rec;
    CLOSE student_dtl_cur;

    l_data        :=   NULL;
    l_data        :=   RPAD(NVL(p_rfms_rec.origination_id,' '),23,' ')                      ||
                            RPAD(NVL(p_rfms_rec.sys_orig_ssn,' '),9,' ')                         ||  -- Original SSN from FAFSA
                            RPAD(NVL(p_rfms_rec.sys_orig_name_cd,' '),2,' ')                     ||
                            RPAD(NVL(p_rfms_rec.attending_campus_id,' '),6,' ')                  ||
                            RPAD(' ',5,' ')                                                      ||  -- ED Use only
                            RPAD(NVL(p_rfms_rec.inst_cross_ref_cd,' '),13,' ')                   ||
                            RPAD(' ',1,' ')                                                      ||  -- Action Code
                            RPAD(' ',1,' ')                                                      ||  -- Unused
                            LPAD(TO_CHAR(ABS(100*NVL(p_rfms_rec.pell_amount,0))),7,'0')          ||  -- Amount Awarded to the Student
                            RPAD(NVL(l_disbursement_dates,' '),120,' ')                          ||
                            RPAD(NVL(TO_CHAR(p_rfms_rec.enrollment_dt,'YYYYMMDD'),' '),8,' ')    ||
                            RPAD(NVL(p_rfms_rec.low_tution_fee,' '),1,' ')                       ||
                            RPAD(NVL(p_rfms_rec.ver_status_code,' '),1,' ')                      ||
                            RPAD(NVL(p_rfms_rec.incrcd_fed_pell_rcp_cd,' '),1,' ')               ||
                            RPAD(NVL(p_rfms_rec.transaction_num,' '),2,' ')                      ||
                            LPAD(TO_CHAR(ROUND(ABS(NVL(p_rfms_rec.efc,0)))),5,'0')               ||
                            RPAD(NVL(p_rfms_rec.secondary_efc_cd,' '),1,' ')                     ||
                            RPAD(NVL(p_rfms_rec.academic_calendar,' '),1,' ')                    ||
                            RPAD(NVL(p_rfms_rec.payment_method,' '),1,' ')                       ||
                            LPAD(TO_CHAR(100*ABS(NVL(p_rfms_rec.coa_amount,0))),7,'0')           ||
                            l_enroll_stat                                                        ||
                            l_wk_inst_time_calc_pymt                                             ||
                            l_wk_int_time_prg_def_yr                                             ||
                            l_cr_clk_hrs_acad_yr                                                 ||
                            l_cr_clk_hrs_prds_sch_yr                                             ||
                            RPAD(' ',3,' ')                                                      ||  -- Inst. Internal sequence no.
                            RPAD(NVL(student_dtl_rec.p_ssn,' '),9,' ')                           ||  -- Current SSN of the Student
                            RPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8,' ')    ||
                            RPAD(NVL(UPPER(student_dtl_rec.p_last_name),' '),16,' ')                    ||
                            RPAD(NVL(UPPER(student_dtl_rec.p_first_name),' '),12,' ')                   ||
                            RPAD(NVL(UPPER(student_dtl_rec.p_middle_name),' '),1,' ')                   ||
                            RPAD(' ',23,' ');                                                        -- Unused

    -- The length of this record is 300

    --
    -- Bug 2383690
    -- If NOT Originating for First Time
    -- If fed verf stat is W, do not send
    -- log message
    --

    IF   igf_gr_gen.send_orig_disb( p_rfms_rec.origination_id) THEN
      --Print Header for the first time and reset value so that it does not get printed further
      --Bug 2460904
      IF g_print_header='Y' THEN
        fnd_file.put_line(fnd_file.output,UPPER(l_header)||RPAD(' ',200));
        g_print_header:='Z';
      END IF;

      -- Since we are going to write the record to file, print log message if we had been set enrollment_status.
      IF p_enrl_status_mesgnum = 1 THEN
        -- default to 'Others'
        fnd_message.set_name('IGF','IGF_GR_DEFAULT_ENRL_STAT');
        fnd_message.set_token('EN_STAT',igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT', p_rfms_rec.enrollment_status));
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      ELSIF p_enrl_status_mesgnum = 2 THEN
        -- set to pell attendance code.
        fnd_message.set_name('IGF','IGF_GR_SET_ENRL_STAT');
        fnd_message.set_token('EN_STAT',igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT', p_rfms_rec.enrollment_status));
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;

      fnd_file.put_line(fnd_file.output,UPPER(l_data));
      p_num_of_records := p_num_of_records + 1;
      p_originated :='Y';
      update_orig_rec(p_rfms_rec,p_rfmb_id);
    ELSE
      fnd_message.set_name('IGF','IGF_GR_VERF_STAT_W');
      fnd_message.set_token('ORIG_ID',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID') ||
                                                             ' : ' || p_rfms_rec.origination_id );
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      p_originated :='N';
    END IF;
  END IF;

EXCEPTION

    WHEN igf_gr_gen.no_file_version THEN
         RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.PREPARE_DATA');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END prepare_data;


PROCEDURE   log_message
       (p_batch_id                 VARCHAR2,
        p_origination_id           igf_gr_rfms.origination_id%TYPE )  IS

---------------------------------------------------------------------
--
--    Created By : sjadhav
--
--    Date Created On : 2001/01/03
--    Purpose :This procedure formats the messages to be put into
--    log file.
--    Know limitations, enhancements or remarks
--    Change History
--    Who             When            What
--
--    (reverse chronological order - newest change first)
--
-----------------------------------------------------------------------

          l_msg_str_0                 VARCHAR2(1000);
          l_msg_str_1                 VARCHAR2(1000);

BEGIN

          l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BATCH_ID'),50) ||
                           RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50);
          l_msg_str_1  :=  RPAD(p_batch_id,50) ||
                           RPAD(p_origination_id,50);

          fnd_file.put_line(fnd_file.log,'         ');
          fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.put_line(fnd_file.log,'         ');
          fnd_file.put_line(fnd_file.log,l_msg_str_0);
          fnd_file.put_line(fnd_file.log,RPAD('-',100,'-'));
          fnd_file.put_line(fnd_file.log,l_msg_str_1);


EXCEPTION
   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END log_message;


PROCEDURE out_message(p_origination_id     igf_gr_rfms.origination_id%TYPE) IS

---------------------------------------------------------------------
--
--    Created By : sjadhav
--
--    Date Created On : 2001/01/03
--    Purpose :This procedure formats the messages to be put into
--    log file.
--    Know limitations, enhancements or remarks
--    Change History
--    Who             When            What
--
--    (reverse chronological order - newest change first)
--
-----------------------------------------------------------------------

          l_msg_str_0                 VARCHAR2(1000);
          l_msg_str_1                 VARCHAR2(1000);

BEGIN



          l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50);
          l_msg_str_1  :=  RPAD(p_origination_id,50);

          IF l_msg_prn_1 = TRUE THEN
             fnd_message.set_name('IGF','IGF_GR_RECORDS_UPDATED');
             fnd_file.put_line(fnd_file.output,fnd_message.get);
             fnd_file.put_line(fnd_file.output,'');
             fnd_file.put_line(fnd_file.output,l_msg_str_0);
             fnd_file.put_line(fnd_file.output,RPAD('-',50,'-'));
             l_msg_prn_1 :=  FALSE;
          END IF;
          fnd_file.put_line(fnd_file.output,l_msg_str_1);


   EXCEPTION
   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


END out_message;



PROCEDURE log_rej_message(p_origination_id     igf_gr_rfms.origination_id%TYPE,
                          p_orig_reject_code   igf_gr_rfms.orig_reject_code%TYPE) IS

---------------------------------------------------------------------
--
--    Created By : sjadhav
--
--    Date Created On : 2001/01/03
--    Purpose :This procedure formats the messages to be put into
--    log file.
--    Know limitations, enhancements or remarks
--    Change History
--    Who             When            What
--
--    (reverse chronological order - newest change first)
--
-----------------------------------------------------------------------

          l_msg_str_0                 VARCHAR2(1000)  DEFAULT NULL;
          l_msg_str_1                 VARCHAR2(1000)  DEFAULT NULL;
          l_msg_str_2                 VARCHAR2(1000)  DEFAULT NULL;
          l_msg_str_3                 VARCHAR2(1000)  DEFAULT NULL;


          l_count          NUMBER          DEFAULT  1;
          l_error_code     igf_gr_rfms_error.edit_code%TYPE;
          l_msg_desc       VARCHAR2(4000)  DEFAULT NULL;

BEGIN

          fnd_file.put_line(fnd_file.log,'');
         IF NVL(TO_NUMBER(RTRIM(LTRIM(p_orig_reject_code))),0) > 0 THEN
          fnd_message.set_name('IGF','IGF_GR_REC_CONTAIN_EDIT_CODES');
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50);
          l_msg_str_1  :=  RPAD(p_origination_id,50);
          l_msg_str_2  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIG_REJECT_CODE'),50);

          fnd_file.put_line(fnd_file.log,' ');
          fnd_file.put_line(fnd_file.log,l_msg_str_0);
          fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));
          fnd_file.put_line(fnd_file.log,l_msg_str_1);
          fnd_file.put_line(fnd_file.log,l_msg_str_2);
          fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));

          FOR l_cn IN 1 .. 25 LOOP

              l_error_code :=  NVL(SUBSTR(p_orig_reject_code,l_count,3),'000');
              IF l_error_code <> '000' THEN
                   l_msg_str_3 :=    RPAD(l_error_code,5);
                   fnd_file.put_line(fnd_file.log,l_msg_str_3);
               END IF;
               l_count      :=  l_count + 3;
          END LOOP;
         END IF;


   EXCEPTION
   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


END log_rej_message;


PROCEDURE rfms_orig(
                    p_ci_cal_type         IN  VARCHAR2,
                    p_ci_sequence_number  IN  NUMBER,
                    p_base_id             IN  VARCHAR2,
                    p_reporting_pell      IN  VARCHAR2,
                    p_attending_pell      IN  VARCHAR2,
                    p_persid_grp          IN  VARCHAR2,
                    p_orig_run_mode       IN  VARCHAR2
                   ) IS
--------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--  Purpose : This procedure reads the data from igf_gr_rfms table
--  for the paricular award year and base id and loads the data
--  into a datafile after formatting
--
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  ridas           08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
--  bkkumar         23-Mar-2004     Bug# 3512319 If run_mode = 'MAX_PELL' then rfms_rec.coa_amount is made 99999.
--  rasahoo         13-Feb-2004     Bug # 3441605 Changed The cursor "cur_get_attendance_type_code" to
--                                  "cur_base_attendance_type_code". Now it will select
--                                  "base_attendance_type_code" instead of "attendance_type_code".
--                                  Removed cursor "cur_get_pell_att_code" as it is no longer used.
--  ugummall        12-DEC-2003     Bug 3252832. FA 131 - COD Updates.
--                                  enrollment_status is derived only if run mode is ACTUAL_PELL. Otherwise
--                                  it is defaulted to '1' ie full-time.
--  ugummall        10-DEC-2003     Bug 3252832. FA 131 - COD Updates.
--                                  Added validation - Amount should not be less than sum of disbursement
--                                  amounts. Added cursor cur_disb_amt_tot.
--  ugummall        04-DEC-2003     Bug 3252832. FA 131 - COD Updates.
--                                  1. Added two extra parameters namely p_persid_grp
--                                     and p_orig_run_mode to this procedure.
--                                  2. Enrollment status derived instead of dafaulting to '1'. Added two cursors
--                                     for this. cur_get_attendance_type_code and cur_get_pell_att_code.
--                                  3. Earlier enrollment status defaulting to '1' may print message though context
--                                     record may not be written to output file. Avoided that bug.
--                                  4. Pell calculation logic moved little down to improve the performance.
--                                  5. Used a different wrapper to calculate pell w.r.t. FA 131.
--                                  6. Used ref cursor reference cursor refcur_persid_check for person-id-group logic.
--  ugummall        04-NOV-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                                  1. Added two extra parameters namely p_reporting_pell
--                                     and p_attending_pell to this procedure.
--                                  2. Added cursor cur_attending_pell. Added check for attending pell
--                                     is a child of reporting pell. If not skipped the record.
--                                  3. Parameters are shown in log file irrespective of wether cur_rfms
--                                     fetches the records or not. This is done for clarity.
--  ugummall        03-NOV-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                                  Added two extra parameters to igf_gr_gen.get_pell_header call.
--  rasahoo         16-Oct-2003     FA121-Bug# 3085558 cur_pymnt_isir_rec is initialised to null
--                                  Changed the logic to check the presence of payment ISIR
--                                  and log message if payment isir not present
--  cdcruz          15-Sep-03       FA121-Bug# 3085558 New Cursor added cur_pymnt_isir
--                                  That checks for the Transaction Number
--                                  On the Payment ISIR
--  (reverse chronological order - newest change first)
--
-------------------------------------------------------------------------------

  CURSOR cur_pymnt_isir( cp_base_id  igf_gr_rfms.base_id%TYPE ) IS
    SELECT isir.transaction_num
      FROM igf_ap_isir_matched isir
     WHERE isir.base_id = cp_base_id
       AND isir.payment_isir = 'Y' ;

  cur_pymnt_isir_rec cur_pymnt_isir%rowtype;

  -- Cursor to check attending pell id is a child of reporting pell id
  CURSOR cur_attending_pell(cp_ci_cal_type          igf_gr_report_pell.ci_cal_type%TYPE,
                            cp_ci_sequence_number   igf_gr_report_pell.ci_sequence_number%TYPE,
                            cp_reporting_pell       igf_gr_report_pell.reporting_pell_cd%TYPE,
                            cp_attending_pell       igf_gr_attend_pell.attending_pell_cd%TYPE)
  IS
  SELECT  'Y'
    FROM  igf_gr_report_pell rep,
          igf_gr_attend_pell att
   WHERE  rep.rcampus_id            =   att.rcampus_id
     AND  rep.ci_cal_type           =   cp_ci_cal_type
     AND  rep.ci_sequence_number    =   cp_ci_sequence_number
     AND  rep.reporting_pell_cd     =   cp_reporting_pell
     AND  att.attending_pell_cd     =   cp_attending_pell;

  l_attending_pell_exists      cur_attending_pell%ROWTYPE;

  l_record           VARCHAR2(4000);
  l_trailer          VARCHAR2(1000);
  l_num_of_rec       NUMBER DEFAULT 0;
  l_amount_total     NUMBER DEFAULT 0;
  l_batch_id         VARCHAR2(60);
  l_originated       VARCHAR2(1);

  p_rfmb_id          igf_gr_rfms_batch_all.rfmb_id%TYPE;
  l_ft_pell_amt      igf_gr_rfms_all.ft_pell_amount%TYPE;
  l_pell_mat         VARCHAR2(10);
  l_isir_present     BOOLEAN := FALSE;

  -- FA 131 - COD Updates Build cursors and variables. 03-DEC-2003 ugummall.
  CURSOR cur_base_attendance_type_code(cp_award_id igf_aw_awd_disb_all.award_id%TYPE) IS
  SELECT    base_attendance_type_code
    FROM    igf_aw_awd_disb_all
   WHERE    award_id = cp_award_id
GROUP BY    base_attendance_type_code;
rec_base_attendance_type_code  cur_base_attendance_type_code%ROWTYPE;

  CURSOR cur_disb_amt_tot(cp_origination_id igf_gr_rfms_disb.origination_id%TYPE) IS
    SELECT    sum(disb_amt) disb_amt_tot
      FROM    igf_gr_rfms_disb
     WHERE    origination_id = cp_origination_id;
  rec_disb_amt_tot  cur_disb_amt_tot%ROWTYPE;

  TYPE PersonIdGroupType IS REF CURSOR ;
  refcur_persid_check PersonIdGroupType;
  lv_persid NUMBER(1);

  l_pell_amt          igf_gr_rfms.pell_amount%TYPE;
  l_return_status     VARCHAR2(1);
  l_return_mesg_text  VARCHAR2(2000);

  -- Variables for the dynamic person id group
  lv_status     VARCHAR2(1);
  lv_sql_stmt   VARCHAR(32767) ;

  lv_persid_flag BOOLEAN;
  l_enrl_status_mesgnum NUMBER(1) DEFAULT 0;
  -- End FA 131.

  --Added for bug 3490915
  -- Get sum of pell award amount
  CURSOR c_awd_disb_tot(
                        cp_award_id igf_aw_award_all.award_id%TYPE
                       ) IS
    SELECT DECODE( accepted_amt,0,offered_amt,NULL,offered_amt,accepted_amt) pell_award
      FROM igf_aw_award awd
     WHERE awd.award_id = cp_award_id
       AND awd.award_status IN ('OFFERED','ACCEPTED');
  l_awd_disb_tot  c_awd_disb_tot%ROWTYPE;

  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  lv_status  := 'S';  -- Defaulted to 'S' and the function will return 'F' in case of failure
  l_originated := 'N';
  -- FA 126. Passed extra parameters p_reporting_pell and p_attending_pell to this cursor.
  OPEN cur_rfms(p_base_id,p_ci_cal_type,p_ci_sequence_number, p_reporting_pell, p_attending_pell);
  FETCH cur_rfms      INTO rfms_rec;

        -- If the table does not contain any data for this base_id or award_year
        -- message is logged into log file and relevent details are also shown
        IF cur_rfms%NOTFOUND  THEN
                CLOSE cur_rfms;
    fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
                igs_ge_msg_stack.add;

    RAISE no_data_in_table;
  END IF;

  -- since the table has data, prepare a header record
  -- igf_gr_gen.get_pell_header will insert a header record which needs to be deleted(rolledback)
  -- if no records have been written to output file. This is handled in batch_not_created exception handling

  l_header := igf_gr_gen.get_pell_header(
                                               g_ver_num,
                                         l_cy_yr,
                                                                                                                                                                 p_reporting_pell,
                                                                                                                                                                 '#O',
                                                                                                                                                                 p_rfmb_id,
                                                                                                                                                                 l_batch_id,
                                         p_ci_cal_type,
                                         p_ci_sequence_number
                                                                                                                                                                );

        fnd_file.new_line(fnd_file.log,1);
        fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BATCH_ID'),10)||' :'
                                                                ||'  '|| l_batch_id);

        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_GR_ORIG_RECORDS');
        fnd_file.put_line(fnd_file.log,fnd_message.get);

  l_amount_total := 0;
  l_num_of_rec   := 0;

  -- get the sql stantement which returns list of person-ids for a given person-id-group.
  -- Bug #5021084
  lv_sql_stmt := igf_ap_ss_pkg.get_pid(p_persid_grp, lv_status, lv_group_type);

  IF (lv_status <> 'S') THEN
    -- Stop processing.
    RAISE persid_grp_sql_stmt_error;
  END IF;

  LOOP
    -- FA 131. Check wether to consider the context record or not based on person-id-group.
    -- lv_persid_flag = TRUE means consider the record and process it.
    -- lv_persid_flag = FALSE means not the intended record. skip the record.
    lv_persid_flag := TRUE;
    IF (p_persid_grp IS NOT NULL) THEN
      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN refcur_persid_check FOR 'SELECT 1
                                        FROM igf_ap_fa_base_rec fabase
                                       WHERE fabase.base_id   = :base_id
                                         AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  rfms_rec.base_id,p_persid_grp;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN refcur_persid_check FOR 'SELECT 1
                                        FROM igf_ap_fa_base_rec fabase
                                       WHERE fabase.base_id   = :base_id
                                         AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  rfms_rec.base_id;
      END IF;

      FETCH refcur_persid_check INTO lv_persid;
      IF refcur_persid_check%NOTFOUND THEN
        lv_persid_flag := FALSE;
      END IF;
    END IF;

    IF (lv_persid_flag) THEN    -- Is person-id in person-group or not ?
      fnd_file.new_line(fnd_file.log,1);
      fnd_message.set_name('IGF','IGF_GR_PROCESS_STUD');
      fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(rfms_rec.base_id));
      fnd_message.set_token('ORIG_ID',rfms_rec.origination_id);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      -- check if attending pell is a child of reporting pell id.
      l_attending_pell_exists := NULL;
      OPEN cur_attending_pell(rfms_rec.ci_cal_type,
                              rfms_rec.ci_sequence_number,
                              rfms_rec.rep_pell_id,
                              rfms_rec.attending_campus_id);
      FETCH cur_attending_pell INTO l_attending_pell_exists;
      IF (cur_attending_pell%NOTFOUND) THEN               -- Attending pell child records exists?

        -- No attending pell child record exists. Skip this record
        CLOSE cur_attending_pell;
        FND_MESSAGE.SET_NAME('IGF','IGF_GR_ATTEND_PELL_NOT_SETUP');
	FND_MESSAGE.SET_TOKEN('ATT_PELL','');
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
      ELSE
        -- attending pell child record exists. Proceed further...
        CLOSE cur_attending_pell;

        --
        -- sjadhav
        -- Bug 2460904
        -- Before sending origination check for the ft pell amount and
        -- pell award amount. if pell award amount is more than ft pell amount
        -- do not send this origination record, log a message and skip
        --

        -- 12-DEC-2003. FA 131. ugummall
        -- If the run mode FULL_TIME or MAX_PELL enrollment_status will be full time ie '1'
        -- irrespective of its old value. Derive enrollment_status only if the run mode is ACTUAL_PELL.
        -- Prepare Enrollment Status field if it is NULL.
        l_enrl_status_mesgnum := 0;
        IF (p_orig_run_mode = 'FULL_TIME' OR p_orig_run_mode = 'MAX_PELL') THEN
          rfms_rec.enrollment_status := '1';    -- 1 stands for Pell Attendance full time
        ELSE
          -- p_orig_run_mode is 'ACTUAL_PELL'

          IF rfms_rec.enrollment_status IS NULL THEN
            -- FA 131 Build. 03-DEC-2003. Preparing enrollment_status field.
            -- Earlier Enrollment status is defaulted to '1' when it is null.
            -- w.r.t. FA 131, it is derived in the following way.
            OPEN cur_base_attendance_type_code(rfms_rec.award_id);
            FETCH cur_base_attendance_type_code INTO rec_base_attendance_type_code;

            -- It returns one or more records. Never returns zero records.
            IF (cur_base_attendance_type_code%ROWCOUNT > 1) THEN
              rfms_rec.enrollment_status := '5';    -- 5 for Pell Attendance "Others"
              l_enrl_status_mesgnum := 1;
            ELSIF (rec_base_attendance_type_code.base_attendance_type_code IS NULL) THEN
              -- cursor returned 1 row. And attendance_type_code is null
              rfms_rec.enrollment_status := '5';    -- 5 for Pell Attendance "Others"
              l_enrl_status_mesgnum := 1;
            ELSE
              -- cursor returned 1 row. And attendance_type_code is not null
               rfms_rec.enrollment_status := rec_base_attendance_type_code.base_attendance_type_code;
               l_enrl_status_mesgnum := 2;
            END IF;
            CLOSE cur_base_attendance_type_code;

            -- NOTE: enrl_status_errnum value either 1 or 2 means some value is assigned to enrollment_status.
            -- Need to convey that mesg in log file, saying enrollment_status set to so and so, only if
            -- that record is going to write into the output file.
          END IF;       -- End of Preparing enrollment status field
        END IF;

        -- Get The Payment ISIR Transaction Number
        cur_pymnt_isir_rec := NULL;
        l_isir_present     := TRUE;
        OPEN cur_pymnt_isir(rfms_rec.base_id);
        FETCH cur_pymnt_isir INTO cur_pymnt_isir_rec;
        IF cur_pymnt_isir%NOTFOUND THEN
          l_isir_present  := FALSE;
        END IF;
        CLOSE cur_pymnt_isir;

        IF NOT l_isir_present THEN
          fnd_message.set_name('IGF','IGF_AP_NO_PAYMENT_ISIR');
          fnd_file.put_line(fnd_file.log,fnd_message.get);

        -- If the Transaction Number being reported does not match do not Originate
        ELSIF rfms_rec.transaction_num <> NVL(cur_pymnt_isir_rec.transaction_num,-1) THEN
           fnd_message.set_name('IGF','IGF_GR_PYMNT_ISIR_MISMATCH');
           fnd_file.put_line(fnd_file.log,fnd_message.get);

        ELSE

          -- Get disbursements amounts total
          rec_disb_amt_tot := NULL;
          OPEN cur_disb_amt_tot(rfms_rec.origination_id);
          FETCH cur_disb_amt_tot INTO rec_disb_amt_tot;
          CLOSE cur_disb_amt_tot;

          -- If origination record's amount is less than sum of disbursement amounts, then do not originate.
          IF (rfms_rec.pell_amount < rec_disb_amt_tot.disb_amt_tot) THEN
            fnd_message.set_name('IGF','IGF_GR_PELL_DIFF_AMTS');
            FND_MESSAGE.SET_TOKEN('DISB_AMT', TO_CHAR(rec_disb_amt_tot.disb_amt_tot));
            FND_MESSAGE.SET_TOKEN('PELL_TOT', TO_CHAR(rfms_rec.pell_amount));

            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE

            l_awd_disb_tot := NULL;
            OPEN c_awd_disb_tot(rfms_rec.award_id);
            FETCH c_awd_disb_tot INTO l_awd_disb_tot;
            CLOSE c_awd_disb_tot;

            IF NVL(l_awd_disb_tot.pell_award,-1) <> rec_disb_amt_tot.disb_amt_tot AND p_orig_run_mode = 'ACTUAL_PELL' THEN
              --put messages here
              fnd_message.set_name('IGF','IGF_GR_PELL_AWD_DIFF_AMT');
              fnd_message.set_token('RFMS_DISB_TOT',TO_CHAR(rec_disb_amt_tot.disb_amt_tot));
              fnd_message.set_token('AWD_DISB_TOT',TO_CHAR(NVL(l_awd_disb_tot.pell_award,0)));
              fnd_file.put_line(fnd_file.log,fnd_message.get);

            ELSE

              -- Calculate Pell amount and Full time Pell amount
              igf_gr_pell_calc.calc_ft_max_pell(cp_base_id          =>  rfms_rec.base_id,
                                                cp_cal_type         =>  rfms_rec.ci_cal_type,
                                                cp_sequence_number  =>  rfms_rec.ci_sequence_number,
                                                cp_flag             =>  p_orig_run_mode,
                                                cp_aid              =>  l_pell_amt,
                                                cp_ft_aid           =>  l_ft_pell_amt,
                                                cp_return_status    =>  l_return_status,
                                                cp_message          =>  l_return_mesg_text
                                               );
              IF (l_return_status = 'E') THEN
                fnd_file.put_line(fnd_file.log,l_return_mesg_text);
              ELSE
                IF l_pell_amt > l_ft_pell_amt THEN
                  fnd_message.set_name('IGF','IGF_GR_LIMIT_EXC');
                  fnd_message.set_token('PEL_AMT',l_ft_pell_amt);
                  fnd_message.set_token('AWD_AMT',rfms_rec.pell_amount);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                ELSE
                  rfms_rec.pell_amount    := l_pell_amt;
                  rfms_rec.ft_pell_amount := l_ft_pell_amt;
                  IF (p_orig_run_mode = 'MAX_PELL') THEN
                    rfms_rec.efc := 0;
                    rfms_rec.coa_amount := 99999;  --Bug 3512319
                  ELSE
                    rfms_rec.efc := igf_gr_gen.get_pell_efc(rfms_rec.base_id);
                  END IF;
                  prepare_data(rfms_rec,l_num_of_rec,p_rfmb_id,l_originated, l_enrl_status_mesgnum);

                  --Bug 2460904
                  --Trailer printed l_amount_total wrongly as it calculated
                  --even for records rejected by the prepare data procedure.
                  --Modified code based on whether a record is rejected or sent by prepare_data procedure.
                  --Added parameter l_originated

                  IF l_originated ='Y' THEN
                    l_amount_total := l_amount_total + NVL(rfms_rec.pell_amount,0);
                    l_originated :='N';
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;     -- Attending pell child records exists?
    END IF;     -- Is person-id in person-group or not ?

    FETCH cur_rfms INTO rfms_rec;
    EXIT WHEN cur_rfms%NOTFOUND;
  END LOOP;
  CLOSE cur_rfms;

  -- since the table has data, prepare a trailer record
  l_trailer := igf_gr_gen.get_pell_trailer(g_ver_num,
                                           l_cy_yr,
                                           p_reporting_pell,
                                           '#O',
                                           l_num_of_rec,
                                           l_amount_total,
                                           l_batch_id);
  fnd_file.new_line(fnd_file.log,1);
  fnd_message.set_name('IGF','IGF_GR_ORIG_REC_NUM');
  fnd_message.set_token('TOT_NUM',TO_CHAR(l_num_of_rec));
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  -- p_num_of_rec || ' records written into data file
  fnd_file.new_line(fnd_file.log,1);

  IF  l_num_of_rec > 0 THEN
    fnd_file.put_line(fnd_file.output,UPPER(l_trailer)||RPAD(' ',200));
  ELSE
    RAISE batch_not_created;
  END IF;

EXCEPTION
  WHEN igf_gr_gen.no_file_version THEN
    RAISE;
  WHEN batch_not_created THEN
    RAISE;
  WHEN no_data_in_table THEN
    RAISE;
  WHEN persid_grp_sql_stmt_error THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.RFMS_ORIG');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END rfms_orig;


PROCEDURE rfms_ack  IS
-------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--  Purpose : This procedure reads the data from datafile(RFMS Ack File )
--            and loads data into origination table after formatting
--  Know limitations, enhancements or remarks
--  Change History
--
--  Who             When            What
-- rasahoo         13-May-2003      Bug #2938258 If ROrigination ecord is not part of this batch
--                                 in the System then raise error.Cannot process Origination
--                                 Record which status for acknowledgement processing is not "Sent".
--
--  (reverse chronological order - newest change first)
--
-------------------------------------------------------------------------

       l_last_gldr_id        NUMBER;
       l_number_rec          NUMBER;
       l_count               NUMBER          DEFAULT  1;
       l_batch_id            VARCHAR2(100);
       l_rfms_process_dt     VARCHAR2(200);
       lp_count              NUMBER          DEFAULT  0;
       lf_count              NUMBER          DEFAULT  0;
       lv_message            fnd_new_messages.message_name%TYPE;
       SYSTEM_STATUS         VARCHAR2(20);

     ----Bug #2938258
       CURSOR cur_gr_rfmb ( p_batch_id  igf_gr_rfms_batch.batch_id%TYPE)
       IS
       SELECT
       rfmb_id
       FROM
       igf_gr_rfms_batch
       WHERE batch_id = p_batch_id;

       cur_get_rfmb  cur_gr_rfmb%ROWTYPE;
       l_rfmb_id     igf_gr_rfms_batch.rfmb_id%TYPE;
     -----

BEGIN

   igf_gr_gen.process_pell_ack ( g_ver_num,
                                 'GR_RFMS_ORIG',
                                 l_number_rec,
                                 l_last_gldr_id,
                                 l_batch_id);

----Bug #2938258

  OPEN cur_gr_rfmb(l_batch_id);
  FETCH cur_gr_rfmb INTO cur_get_rfmb;
  CLOSE cur_gr_rfmb;

  l_rfmb_id := cur_get_rfmb.rfmb_id;
 --
   --
   --  Check the award year matches with the award year in PELL setup.
   --
   igf_gr_gen.match_file_version (g_ver_num, l_batch_id, lv_message);

   IF lv_message = 'IGF_GR_VRSN_MISMTCH' THEN
      fnd_message.set_name('IGF','IGF_GR_VRSN_MISMTCH');
      fnd_message.set_token('CYCL',SUBSTR(l_batch_id,3,4));
      fnd_message.set_token('BATCH',l_batch_id);
      fnd_message.set_token('VRSN',g_ver_num);
      fnd_message.set_token('AWD_YR',g_alt_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE invalid_version;
   END IF;

   IF l_number_rec > 0 THEN

      DECLARE
        l_actual_rec               NUMBER DEFAULT 0;
        l_origination_id           igf_gr_rfms.origination_id%TYPE;
        l_ci_cal_type              igf_gr_rfms.ci_cal_type%TYPE;
        l_ci_sequence_number       igf_gr_rfms.ci_sequence_number%TYPE;


        l_chk_flag                 BOOLEAN DEFAULT FALSE;


        CURSOR cur_get_pell(l_origination_id   igf_gr_rfms.origination_id%TYPE) IS
        SELECT  rfms.*
        FROM
        igf_gr_rfms rfms
        WHERE
        rfms.origination_id = l_origination_id
        FOR UPDATE OF origination_id NOWAIT;

        get_pell_rec  cur_get_pell%ROWTYPE;


        CURSOR c_rfms_data IS
        SELECT
        record_data
        FROM
        igf_gr_load_file_t
        WHERE
        gldr_id BETWEEN 2 AND (l_last_gldr_id - 1) AND
        file_type = 'GR_RFMS_ORIG';

        l_rfms    igf_gr_rfms%ROWTYPE ;
        rec_data  c_rfms_data%ROWTYPE;

        ln_pell_awd  NUMBER;

        BEGIN

          OPEN c_rfms_data;
           LOOP

                FETCH c_rfms_data INTO rec_data;
                EXIT WHEN c_rfms_data%NOTFOUND;

             BEGIN
                    l_actual_rec    :=  l_actual_rec + 1;
                    OPEN cur_get_pell(LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23))));
                    FETCH cur_get_pell INTO get_pell_rec;

                    IF cur_get_pell%NOTFOUND THEN
                      CLOSE cur_get_pell;
                      log_message(l_batch_id,LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23))));
                      RAISE igf_gr_gen.skip_this_record;
                    END IF;
----Bug #2938258
                   IF  l_rfmb_id<> get_pell_rec.rfmb_id THEN

                      fnd_message.set_name('IGF','IGF_GR_ORIG_BATCH_MISMATCH');
                      fnd_message.set_token('BATCH_ID',l_batch_id);
                      fnd_message.set_token('ORIG_ID',LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23))));
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                      fnd_file.new_line(fnd_file.log,1);

                      RAISE igf_gr_gen.skip_this_record;
                   END IF;
                     --Record should be in "Sent" status for acknowledgment processing"
                     IF get_pell_rec.orig_action_code <> 'S' THEN

                       fnd_message.set_name('IGF','IGF_GR_ORIG_NOT_IN_SENT');
                       fnd_message.set_token('ORIG_ID',LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23))));
                       SYSTEM_STATUS := igf_aw_gen.lookup_desc('IGF_GR_ORIG_STATUS',get_pell_rec.orig_action_code);
                       fnd_message.set_token('SYS_STATUS',SYSTEM_STATUS);
                       fnd_file.put_line(fnd_file.log,fnd_message.get);
                       fnd_file.new_line(fnd_file.log,1);
                       RAISE igf_gr_gen.skip_this_record;
                      END IF;

----end Bug #2938258

-- Do not make any updates for amounts
-- Updates for Amounts have to happen throgh Disbursement Routine
--
-- Also do not update all the Fields
-- See which fields are updated by RFMS.
-- Only those fields should be updated
--
                                 l_rfms.origination_id            := get_pell_rec.origination_id;
                                 l_rfms.ci_cal_type               := get_pell_rec.ci_cal_type;
                                 l_rfms.ci_sequence_number        := get_pell_rec.ci_sequence_number;
                                 l_rfms.base_id                   := get_pell_rec.base_id;
                                 l_rfms.award_id                  := get_pell_rec.award_id;
                                 l_rfms.rfmb_id                   := get_pell_rec.rfmb_id;
                                 l_rfms.inst_cross_ref_cd         := get_pell_rec.inst_cross_ref_cd;
                                 l_rfms.rep_pell_id               := get_pell_rec.rep_pell_id;
                      BEGIN
                      IF g_ver_num IN ('2002-2003','2003-2004','2004-2005') THEN
                                 l_rfms.sys_orig_ssn              := LTRIM(RTRIM(SUBSTR(rec_data.record_data,24,9)));
                                 l_rfms.sys_orig_name_cd          := LTRIM(RTRIM(SUBSTR(rec_data.record_data,33,2)));
                                 l_rfms.attending_campus_id       := LTRIM(RTRIM(SUBSTR(rec_data.record_data,35,6)));
                                 l_rfms.orig_action_code          := LTRIM(RTRIM(SUBSTR(rec_data.record_data,59,1)));
                                 ln_pell_awd                      := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,61,7)))),0)/100;
                                 l_rfms.est_disb_dt1              := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(rec_data.record_data,68,8))),'YYYYMMDD');
                                 l_rfms.enrollment_dt             := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(rec_data.record_data,188,8))),'YYYYMMDD');
                                 l_rfms.low_tution_fee            := LTRIM(RTRIM(SUBSTR(rec_data.record_data,196,1)));
                                 l_rfms.ver_status_code           := LTRIM(RTRIM(SUBSTR(rec_data.record_data,197,1)));
                                 l_rfms.incrcd_fed_pell_rcp_cd    := LTRIM(RTRIM(SUBSTR(rec_data.record_data,198,1)));
                                 l_rfms.transaction_num           := LTRIM(RTRIM(SUBSTR(rec_data.record_data,199,2)));
                                 l_rfms.efc                       := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,201,5)))),0);
                                 l_rfms.secondary_efc_cd          := LTRIM(RTRIM(SUBSTR(rec_data.record_data,206,1)));
                                 l_rfms.academic_calendar         := LTRIM(RTRIM(SUBSTR(rec_data.record_data,207,1)));
                                 l_rfms.payment_method            := LTRIM(RTRIM(SUBSTR(rec_data.record_data,208,1)));
                                 l_rfms.coa_amount                := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,209,7)))),0)/100;
                                 l_rfms.enrollment_status         := LTRIM(RTRIM(SUBSTR(rec_data.record_data,216,1)));
                                 l_rfms.wk_inst_time_calc_pymt    := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,217,2)))),0);
                                 l_rfms.wk_int_time_prg_def_yr    := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,219,2)))),0);
                                 l_rfms.cr_clk_hrs_acad_yr        := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,221,4)))),0);
                                 l_rfms.cr_clk_hrs_prds_sch_yr    := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,225,4)))),0);
                                 l_rfms.ft_pell_amount            := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,251,5)))),0);
                                 l_rfms.prev_accpt_tran_no        := LTRIM(RTRIM(SUBSTR(rec_data.record_data,256,2)));
                                 l_rfms.prev_accpt_efc            := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,258,5)))),0);
                                 l_rfms.prev_accpt_sec_efc_cd     := LTRIM(RTRIM(SUBSTR(rec_data.record_data,263,1)));
                                 l_rfms.prev_accpt_coa            := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,264,7)))),0)/100;
                                 l_rfms.orig_reject_code          := LTRIM(RTRIM(SUBSTR(rec_data.record_data,271,75)));
                                 l_rfms.orig_ed_use_flags         := LTRIM(RTRIM(SUBSTR(rec_data.record_data,346,10)));
                                 l_rfms.pending_amount            := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,356,7)))),0)/100;
                                 l_rfms.secondary_efc             := NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,363,5)))),0)/100;
                                 l_rfms.current_ssn               := LTRIM(RTRIM(SUBSTR(rec_data.record_data,368,9)));
                                 l_rfms.birth_dt                  := fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(rec_data.record_data,377,8))),'YYYYMMDD');
                                 l_rfms.last_name                 := LTRIM(RTRIM(SUBSTR(rec_data.record_data,385,16)));
                                 l_rfms.first_name                := LTRIM(RTRIM(SUBSTR(rec_data.record_data,401,12)));
                                 l_rfms.middle_name               := LTRIM(RTRIM(SUBSTR(rec_data.record_data,413,1)));
                        ELSE
                          RAISE  igf_gr_gen.no_file_version;
                        END IF;

                        EXCEPTION
                        -- The exception caught here will be the data format exceptions
                        WHEN OTHERS THEN
                        lf_count := lf_count + 1;
                        fnd_message.set_name('IGF','IGF_GR_INVALID_RECORD');
                        fnd_message.set_token('ORIG_ID',l_rfms.origination_id);
                        fnd_file.put_line(fnd_file.log,fnd_message.get);

                        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                        fnd_file.put_line(fnd_file.log,fnd_message.get);
                        -- Cannot Process Record for Origination ORIG_ID as it contains corrupt data
                        fnd_file.put_line(fnd_file.log, ' ' );

                        RAISE igf_gr_gen.skip_this_record;

                     END;
                           l_rfms.rec_source                 := get_pell_rec.rec_source;
                           l_rfms.pell_amount                := get_pell_rec.pell_amount;  -- compare this amount
                           l_rfms.pell_profile               := get_pell_rec.pell_profile;
                           l_rfms.total_pymt_prds            := get_pell_rec.total_pymt_prds;
                           l_rfms.orig_status_dt             := TRUNC(SYSDATE);

                       IF  ln_pell_awd <> get_pell_rec.pell_amount THEN
                            igf_gr_gen.insert_sys_holds(get_pell_rec.award_id,NULL,'PELL');
                            fnd_message.set_name('IGF','IGF_GR_DIFF_PELL_AMT');
                            fnd_message.set_token('ORIG_ID',l_rfms.origination_id);
                            -- The Reported and Received Pell Award Amount for this Origination Record are different
                            fnd_file.put_line(fnd_file.log,fnd_message.get);

                            fnd_message.set_name('IGF','IGF_GR_REPORTED_AMT');
                            fnd_message.set_token('AMT', TO_CHAR(get_pell_rec.pell_amount));
                            fnd_file.put_line(fnd_file.log,fnd_message.get);

                            fnd_message.set_name('IGF','IGF_GR_RECEIVED_AMT');
                            fnd_message.set_token('AMT', TO_CHAR(ln_pell_awd));
                            fnd_file.put_line(fnd_file.log,fnd_message.get);
                            fnd_file.new_line(fnd_file.log,1);

                            --
                            -- print both amounts fnd_message.set_name('IGF','IGF_
                            --

                       END IF;
                       lp_count := lp_count + 1;
                       igf_gr_rfms_pkg.update_row (
                                 x_rowid                             => get_pell_rec.row_id,
                                 x_origination_id                    => l_rfms.origination_id,
                                 x_ci_cal_type                       => l_rfms.ci_cal_type,
                                 x_ci_sequence_number                => l_rfms.ci_sequence_number,
                                 x_base_id                           => l_rfms.base_id,
                                 x_award_id                          => l_rfms.award_id,
                                 x_rfmb_id                           => l_rfms.rfmb_id,
                                 x_sys_orig_ssn                      => l_rfms.sys_orig_ssn,
                                 x_sys_orig_name_cd                  => l_rfms.sys_orig_name_cd,
                                 x_transaction_num                   => l_rfms.transaction_num,
                                 x_efc                               => l_rfms.efc,
                                 x_ver_status_code                   => l_rfms.ver_status_code,
                                 x_secondary_efc                     => l_rfms.secondary_efc,
                                 x_secondary_efc_cd                  => l_rfms.secondary_efc_cd,
                                 x_pell_amount                       => l_rfms.pell_amount,
                                 x_pell_profile                      => l_rfms.pell_profile,
                                 x_enrollment_status                 => l_rfms.enrollment_status,
                                 x_enrollment_dt                     => l_rfms.enrollment_dt,
                                 x_coa_amount                        => l_rfms.coa_amount,
                                 x_academic_calendar                 => l_rfms.academic_calendar,
                                 x_payment_method                    => l_rfms.payment_method,
                                 x_total_pymt_prds                   => l_rfms.total_pymt_prds,
                                 x_incrcd_fed_pell_rcp_cd            => l_rfms.incrcd_fed_pell_rcp_cd,
                                 x_attending_campus_id               => l_rfms.attending_campus_id,
                                 x_est_disb_dt1                      => l_rfms.est_disb_dt1,
                                 x_orig_action_code                  => l_rfms.orig_action_code,
                                 x_orig_status_dt                    => l_rfms.orig_status_dt,
                                 x_orig_ed_use_flags                 => l_rfms.orig_ed_use_flags,
                                 x_ft_pell_amount                    => l_rfms.ft_pell_amount,
                                 x_prev_accpt_efc                    => l_rfms.prev_accpt_efc,
                                 x_prev_accpt_tran_no                => l_rfms.prev_accpt_tran_no,
                                 x_prev_accpt_sec_efc_cd             => l_rfms.prev_accpt_sec_efc_cd,
                                 x_prev_accpt_coa                    => l_rfms.prev_accpt_coa,
                                 x_orig_reject_code                  => l_rfms.orig_reject_code,
                                 x_wk_inst_time_calc_pymt            => l_rfms.wk_inst_time_calc_pymt,
                                 x_wk_int_time_prg_def_yr            => l_rfms.wk_int_time_prg_def_yr,
                                 x_cr_clk_hrs_prds_sch_yr            => l_rfms.cr_clk_hrs_prds_sch_yr,
                                 x_cr_clk_hrs_acad_yr                => l_rfms.cr_clk_hrs_acad_yr,
                                 x_inst_cross_ref_cd                 => l_rfms.inst_cross_ref_cd,
                                 x_low_tution_fee                    => l_rfms.low_tution_fee,
                                 x_rec_source                        => l_rfms.rec_source,
                                 x_pending_amount                    => l_rfms.pending_amount,
                                 x_mode                              => 'R',
                                 x_birth_dt                          => l_rfms.birth_dt,
                                 x_last_name                         => l_rfms.last_name,
                                 x_first_name                        => l_rfms.first_name,
                                 x_middle_name                       => l_rfms.middle_name,
                                 x_current_ssn                       => l_rfms.current_ssn,
                                 x_legacy_record_flag                => NULL,
                                 x_reporting_pell_cd                 => l_rfms.rep_pell_id,
                                 x_rep_entity_id_txt                 => get_pell_rec.rep_entity_id_txt,
                                 x_atd_entity_id_txt                 => get_pell_rec.atd_entity_id_txt,
                                 x_note_message                      => get_pell_rec.note_message,
                                 x_full_resp_code                    => get_pell_rec.full_resp_code,
                                 x_document_id_txt                   => get_pell_rec.document_id_txt );

                --write to log file
                log_rej_message(l_rfms.origination_id,
                                l_rfms.orig_reject_code);

                --write to output file
                out_message(l_rfms.origination_id);

                IF cur_get_pell%ISOPEN THEN
                   CLOSE cur_get_pell;
                END IF;

           EXCEPTION
           WHEN   igf_gr_gen.skip_this_record THEN
               IF cur_get_pell%ISOPEN THEN
                   CLOSE cur_get_pell;
               END IF;
         END;
       END LOOP;

       CLOSE  c_rfms_data;

       IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              igs_ge_msg_stack.add;
              RAISE igf_gr_gen.file_not_loaded;
           END IF;
       END;                 -- Inner Begin

       fnd_file.new_line(fnd_file.log,2);
       fnd_message.set_name('IGF','IGF_GR_FILE_REC_CNT');
       fnd_message.set_token('CNT',l_number_rec);
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       fnd_message.set_name('IGF','IGF_GR_FILE_REC_PAS');
       fnd_message.set_token('CNT',lp_count);
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       fnd_message.set_name('IGF','IGF_GR_FILE_REC_FAL');
       fnd_message.set_token('CNT',lf_count);
       fnd_file.put_line(fnd_file.log,fnd_message.get);

END IF;             -- if l_num_rec

EXCEPTION

WHEN invalid_version THEN
     RAISE;
WHEN igf_gr_gen.no_file_version THEN
     RAISE;
WHEN igf_gr_gen.corrupt_data_file THEN
     RAISE;
WHEN no_data_in_table THEN
     RAISE;
WHEN igf_gr_gen.batch_not_in_system THEN
      -- Bug # 4008991
     fnd_message.set_name('IGF','IGF_SL_GR_BATCH_DOES_NO_EXIST');
     fnd_message.set_token('BATCH_ID',l_batch_id);
     RAISE;
WHEN igf_gr_gen.file_not_loaded THEN
     RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.RFMS_ACK');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END rfms_ack;

PROCEDURE main(errbuf       OUT NOCOPY  VARCHAR2,
               retcode      OUT NOCOPY  NUMBER,
               award_year   IN          VARCHAR2,
               p_reporting_pell   IN    VARCHAR2,
               p_attending_pell   IN    VARCHAR2,
               base_id      IN          igf_gr_rfms_all.base_id%TYPE,
               p_persid_grp       IN    VARCHAR2,
               p_orig_run_mode    IN    VARCHAR2 )
AS

--------------------------------------------------------------------------
--
--  Created By : sjadhav
--  Date Created On : 2001/01/03
--
--  Purpose :This is the main procedure which will be called by
--  concurrent manager.It will call either rfms orination or
--  rfms ack depending on the l_mode parameter
--
--  Know limitations, enhancements or remarks
--  Change History
--  Who         When            What
--  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
--  ugummall    08-Jan-2003     Bug 3318202. Changed the order of parameters and removed
--                              the parameter p_org_id.
--  ugummall    03-DEC-2003     Bug 3252832. FA 131 - COD Updates
--                              1. Added two parameters to this procedure namely
--                                 p_persid_grp and p_orig_run_mode.
--                              2. base_id and p_persid_grp are mutually exclusive. Added this check.
--                              3. Flat file version number is checked here itself to improve performance.
--
--  ugummall    05-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                              1. Added two parameters to this procedure namely
--                                 p_reporting_pell and p_attending_pell
--                              2. base_id and p_attending_pell are mutually exclusive. Added this check.
--
--  (reverse chronological order - newest change first)
--
--  sjadhav, Feb 06th 2002
--  Disabled Run For Parameter
--  If Award Year and Base ID Both are present,
--  then run the process for Student, else run for Award Year
--
--------------------------------------------------------------------------

  -- To get group description for group_id
  CURSOR cur_person_group(cp_persid_grp igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT group_cd group_name
      FROM igs_pe_persid_group_all
     WHERE group_id = cp_persid_grp;
  rec_person_group cur_person_group%ROWTYPE;

  l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
  l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;
  ln_base_id            NUMBER;
  l_msg_str_1        VARCHAR2(1000);
  l_msg_str_2        VARCHAR2(1000);
  l_msg_str_3        VARCHAR2(1000);
  l_msg_str_4        VARCHAR2(1000);
  l_msg_str_5        VARCHAR2(1000);
  l_msg_str_6        VARCHAR2(1000);
  mutually_exclusive  BOOLEAN DEFAULT TRUE;
  l_cod_year_flag    BOOLEAN;

BEGIN
  igf_aw_gen.set_org_id(NULL);
  retcode := 0;
  ln_base_id               :=   base_id;
  l_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(award_year,1,10)));
  l_ci_sequence_number     :=   NVL(TO_NUMBER(SUBSTR(award_year,11)),0);

  -- Check wether the awarding year is COD-XML processing Year or not
  l_cod_year_flag  := NULL;
  l_cod_year_flag := igf_sl_dl_validation.check_full_participant (l_ci_cal_type,l_ci_sequence_number,'PELL');

  -- This process is allowed to run only for PHASE_IN_PARTICIPANT
  -- If the award year is FULL_PARTICIPANT then raise the error message
  --  and stop processing else continue the process
  IF l_cod_year_flag THEN

   fnd_message.set_name('IGF','IGF_GR_COD_NO_ORIG');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   RETURN;

  END IF;

  -- show parameter 1 - award year
        l_msg_str_1        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','AWARD_YEAR'),30) ||
                          RPAD(igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number),20);
  fnd_file.put_line(fnd_file.log,l_msg_str_1);

  -- show parameter 2 - report pell id
  l_msg_str_3        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'REPORT_PELL'),30) || p_reporting_pell;
  fnd_file.put_line(fnd_file.log,l_msg_str_3);

  -- show parameter 3 - attend pell id
  IF (p_attending_pell IS NOT NULL) THEN
    l_msg_str_4      :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'ATTEND_PELL'),30) || p_attending_pell;
        fnd_file.put_line(fnd_file.log,l_msg_str_4);
  END IF;

  -- show parameter 4 - base id
  IF (base_id IS NOT NULL) THEN
    l_msg_str_2        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BASE_ID'),30) ||
                            RPAD(igf_gr_gen.get_per_num(ln_base_id),20);
    fnd_file.put_line(fnd_file.log,l_msg_str_2);
  END IF;

  -- show parameter 5 - Person Id Group
  IF (p_persid_grp IS NOT NULL) THEN
    OPEN cur_person_group(p_persid_grp);
    FETCH cur_person_group INTO rec_person_group;
    CLOSE cur_person_group;
    l_msg_str_5      :=   RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS', 'PERSON_ID_GROUP'),30) || rec_person_group.group_name;
        fnd_file.put_line(fnd_file.log,l_msg_str_5);
  END IF;

  -- show parameter 6 - Orgination Run Mode
  l_msg_str_6      :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'PELL_ORIG_RUN_MODE'),30) || p_orig_run_mode;
  fnd_file.put_line(fnd_file.log,l_msg_str_6);

  -- FA 126. base_id and attending pell are mutually exclusive.
  IF (base_id IS NOT NULL AND p_attending_pell IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('IGF', 'IGF_GR_PORIG_INCOMPAT');
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
    mutually_exclusive := FALSE;
  END IF;

  -- FA 131. Person Number(base_id) and Person Group are mutually exclusive.
  IF (base_id IS NOT NULL AND p_persid_grp IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('IGF', 'IGF_GR_PERSID_GRP_INCOMPAT');
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
    mutually_exclusive := FALSE;
  END IF;

  IF NOT mutually_exclusive THEN
    RETURN;
  END IF;

  IF l_ci_cal_type IS NULL OR
     l_ci_sequence_number IS NULL THEN
     RAISE param_error;
  END IF;

  -- Get the Flat File Version and then Proceed
  g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');

  -- Get the Cycle Year
  l_cy_yr    :=  igf_gr_gen.get_cycle_year(l_ci_cal_type,l_ci_sequence_number);

  IF (g_ver_num ='NULL') OR (g_ver_num  NOT IN ('2002-2003','2003-2004','2004-2005')) THEN
    RAISE igf_gr_gen.no_file_version;
  ELSE
    rfms_orig(l_ci_cal_type,l_ci_sequence_number,
              ln_base_id, p_reporting_pell, p_attending_pell,
              p_persid_grp, p_orig_run_mode
             );
  END IF;

  COMMIT;

EXCEPTION
  WHEN igf_gr_gen.no_file_version THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGF','IGF_GR_VERSION_NOTFOUND');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN batch_not_created THEN
    ROLLBACK;
  WHEN param_error THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN no_data_in_table THEN
    ROLLBACK;
    errbuf := fnd_message.get_string('IGF','IGF_AP_NO_DATA_FOUND');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN app_exception.record_lock_exception THEN
    ROLLBACK;
    retcode:=2;
    errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN persid_grp_sql_stmt_error THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGF','IGF_AP_INVALID_QUERY');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || SQLERRM;
    igs_ge_msg_stack.conc_exception_hndl;
END main;

PROCEDURE main_ack( errbuf      OUT NOCOPY   VARCHAR2,
                    retcode     OUT NOCOPY   NUMBER,
                    p_awd_yr    IN           VARCHAR2,
                    p_org_id    IN           NUMBER)
AS
----------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 19-apr-2001
--
--  Purpose :This is the main procedure which will be called by
--  concurrent manager.It calls rfms ack
--
--
--  sjadhav
--  add Award Year parameter to all Acknowledgement Processing
--
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--
--  (reverse chronological order - newest change first)
--tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
----------------------------------------------------------------------

    l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
    l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;

BEGIN
	 igf_aw_gen.set_org_id(NULL);
     retcode := 0;
     l_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
     l_ci_sequence_number     :=   NVL(TO_NUMBER(SUBSTR(p_awd_yr,11)),0);

     IF l_ci_cal_type IS NULL OR
        l_ci_sequence_number IS NULL THEN
        RAISE param_error;
     END IF;

     -- Check wether the awarding year is COD-XML processing Year or not
     -- This process is allowed to run only for PHASE_IN_PARTICIPANT
     -- If the award year is FULL_PARTICIPANT then raise the error message
     --  and stop processing else continue the process
     IF igf_sl_dl_validation.check_full_participant (l_ci_cal_type,l_ci_sequence_number,'PELL') THEN

       fnd_message.set_name('IGF','IGF_GR_COD_NO_ORIG_ACK');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       RETURN;

     END IF;

--
-- Get the Flat File Version and then Proceed
--
   g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');
   g_alt_code := igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);
--
-- Get the Cycle Year
--
   l_cy_yr    :=  igf_gr_gen.get_cycle_year(l_ci_cal_type,l_ci_sequence_number);

   IF g_ver_num ='NULL' THEN
      RAISE igf_gr_gen.no_file_version;
   ELSE
      rfms_ack;
   END IF;

  COMMIT;

EXCEPTION

     WHEN invalid_version THEN
       ROLLBACK;
       retcode := 2;

     WHEN igf_gr_gen.no_file_version THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_VERSION_NOTFOUND');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN param_error THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.file_not_loaded THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN no_data_in_table THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_AP_NO_DATA_FOUND');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.batch_not_in_system THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get; -- Bug # 4008991
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.corrupt_data_file THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_CORRUPT_DATA_FILE');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || SQLERRM;
       igs_ge_msg_stack.conc_exception_hndl;

    END main_ack;

END igf_gr_rfms_orig;

/
