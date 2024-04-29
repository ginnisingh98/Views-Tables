--------------------------------------------------------
--  DDL for Package Body IGF_GR_PELL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_PELL" AS
/* $Header: IGFGR01B.pls 120.0 2005/06/02 15:55:36 appldev noship $ */

--
------------------------------------------------------------------------
-- Who       When           What
------------------------------------------------------------------------
--  sjadhav   25-Oct-2004       FA 149 build bug # 3416863 - added full resp code
------------------------------------------------------------------------
--  sjadhav   25-Oct-2004       FA 149 build bug # 3416863 - Person
--                              information picked from SWS, so rfms columns
--                              are not used, do not insert rfms_disb for cod
------------------------------------------------------------------------
--  ayedubat   13-OCT-2004      Changed  the logic as part of FA 149 build bug # 3416863
--  bkkumar    23-July-04       Bug 3773300 Added the function to get the enrollment dateas min start date
--                              of term for the pell award disbursements.
--  sjalasut    10 Dec, 2003    removed get_current_term_enr_dtl and added igf_ap_gen_001.get_key_program
--  ugummall      09-DEC-2003.  Bug 3252832. FA 131 - COD Updates.
--                              Removed the procedure pell_calc.
--  ugummall      20-NOV-2003   Bug 3252832. FA 131 - COD Updates.
--                              1. Added two cursors cur_get_attendance_type_code and cur_get_pell_att_code
--                                 in rfms_load_rec procedure.
--                              2. Modified code in preparing enrollment_status field of the origination record.
--                                 in rfms_load_rec procedure.
------------------------------------------------------------------------
--  sjalasut      7 Nov 2003    FA126. Modified the code to have attending pell
--                              in the generate_origination_id procedure.
--                              Pell Origination Records will have Attending Pell
--                              in the Origination Id field.
--   veramach     11-OCT-2003   FA 124
--                              1.COA is required for awarding PELL Grants
--                              2.Pell Award Amount must be less than or equal to amount calculated from PELL matrix
------------------------------------------------------------------------
-- rasahoo   01-Sep-2003   In the cursor C_FA_BASE, removed the join with igf_ap_fa_base_h
--                         as part of the build FA-114 (obsoletion of base rec history)
------------------------------------------------------------------------
-- sjadhav   01-Aug-2003    Bug 3062062
--                          Removed variable lv_enrollment_status from
--                          pell_calc routine
--                          Removed igf_gr_gen.get_pell_efc call from
--                          pell_calc routine
--                          Modified pell_calc routine to default
--                          Enrollment Status to Full time when called
--                          from IGFGR02B - Pell Origination process
------------------------------------------------------------------------
-- sjadhav   08-Apr-2003    Bug 2890177
--                          Removed NVL from comparisons to decide
--                          Regular or Alternate Pell Matrix
--                          in pell_calc routine
--                          When pell_calc invoked from IGFGR005
--                          messages are added to stack
------------------------------------------------------------------------
-- gmuralid  04-04-2003     BUG 2863895,2863910
--                          Made the following changes in
--                          rfms_load_rec_procedure:
--                          1.Modified Exception Handling where in
--                          included the message to skip a student if
--                          there is no set up or active and payment
--                          isir are different or there is a duplicate
--                          ssn.
--                          In rfms_load procedure the following chnages
--                          were made:
--                          1.Included commit just before exception
--                          handling to ensure proper write into log
--                          file.
------------------------------------------------------------------------
-- gmuralid  28-Mar-2003    BUG 2863895 - The process used to error
--                          out when active and payment isirs were
--                          not the same.Modified code logic such that
--                          the process continues skipping only that
--                          particular student.Formatted log file
--                          by including new messages.
------------------------------------------------------------------------
-- gmuralid  28-Mar-2003    BUG 2863910 - Included duplicate SSN cursor
--                          to check for exisiting origination id.
------------------------------------------------------------------------
-- vvutukur  17-Feb-2003    Enh#2758804.FACR105 Build. Modified procedures
--                          rfms_load_rec and rfms_load.
------------------------------------------------------------------------
-- sjadhav   10-Feb-2003    Bug 2758812 - FA116 Pell Build
--                          Modified generate_origination_id to read
--                          pell cycle year using function
--                          igf_gr_gen.get_cycle_year
------------------------------------------------------------------------
-- sjadhav   FA105 108      Bug 2613546,2606001
--                          modified pell_calc routine
--                          modified c_fa_base cursor to read
--                          pell_alt_expense .added award year to
--                          get_gr_ver_code fuction call
------------------------------------------------------------------------
-- sjadhav   Feb 07, 2002   Bug : 2216956
--                          1.Changes in the tbh calls
--                          2.Pick Current SSN, Last Name,First Name,
--                            Middle Name from igf_gr_person_v
--                          3.Db/Cr Flag set to 'P' in case of positive
--                            disbursement,else set to 'N'
--                          4.Added Exception Handlers in All procedures
--                          5.Modified generate_origination_id proc to
--                            pick up the Cycle Year from the End Date
------------------------------------------------------------------------
-- sjadhav   Jan 30,2002    Bug : 2154941
--                          Common cursor c_fa_base to pick up all
--                          relevent information added
------------------------------------------------------------------------
-- sjadhav   24-jul-2001    Bug ID  : 1818617 added parameter
--                          p_get_recent_info
------------------------------------------------------------------------
-- avenkatr  06-SEP-2001    Bug Id : 1967738. Added the procedure
--                          Generate _Origination_Id to take care of
--                          conditions when ISIR record is not found and
--                          when any of SSN, Start date of Award Year or
--                          Reporting Pell Id is NULL when generating
--                          the Origination ID
------------------------------------------------------------------------
--


-- The calculation of Pell amount is done in this package
--
-- Pre-requisites
-- The following tables have to be populated before calling this process
-- igf_fa_base_rec
-- igf_aw_fund_mast
-- igf_gr_pell_setup
--
-- The pell calculation routine is called from packaging,igfgr004,igfgr005,igfaw016
--

NO_SETUP             EXCEPTION;
MY_EXP               EXCEPTION;

--
-- Cursor to Pick up Person Details
--

CURSOR c_fa_base ( x_base_id igf_ap_fa_base_rec.base_id%TYPE)
IS
SELECT
        faconv.base_id,
        faconv.person_id,
        faconv.ci_cal_type,
        faconv.ci_sequence_number,
        faconv.coa_code_f,
        fed_verif_status,
        coa_pell,
        pell_alt_expense,
        isir.transaction_num,
        isir.original_ssn,
        isir.orig_name_id,
        isir.secondary_efc,
        isir.sec_efc_type,
        isir.isir_id
FROM
        igf_ap_fa_base_rec      faconv,
        igf_ap_isir_matched     isir
WHERE
        x_base_id       = faconv.base_id         AND
        faconv.base_id  = isir.base_id           AND
        isir.active_isir = 'Y'
ORDER BY 1;

l_fa_base            c_fa_base%ROWTYPE;

lv_invoke            VARCHAR2(30);
ln_cnt               NUMBER;




PROCEDURE rfms_load_rec ( p_ci_cal_type      IN  igs_ca_inst_all.cal_type%TYPE,
                          p_ci_seq_num       IN  igs_ca_inst_all.sequence_number%TYPE,
                          l_base_id          IN  igf_ap_fa_base_rec_all.base_id%TYPE)
IS

--
------------------------------------------------------------------------------
--
--   Created By : cdcruz
--   Created On : 14-NOV-2000
--   Purpose :
--   Known limitations, enhancements or remarks :
--   Change History :
------------------------------------------------------------------------------
--   Who          When         What
------------------------------------------------------------------------------
--   rasahoo      13-Feb-2004   Bug # 3441605 Changed The cursor "cur_get_attendance_type_code" to
--                              "cur_base_attendance_type_code". Now it will select
--                              "base_attendance_type_code" instead of "attendance_type_code".
--                              Removed cursor "cur_get_pell_att_code" as it is no longer used.
--   ugummall     15-DEC-2003   Bug 3316665. Changed the cursor c_fa_base and added
--                              new message when the cusor cur_chk_orig is found.
--   ugummall     12-DEC-2003   Bug 3252832. FA 131 - COD Updates.
--                              1. Changed cursor name c_coa_f to c_coa_pell and picked up coa_pell item
--                                 instead of coa_f.
--                              2. cusor cur_payment_isir is changed.
--   ugummall     10-DEC-2003   Bug 3252832. FA 131 - COD Updates.
--                              Removed cursor c_pell_setup.
--                              Getting Pell Setup record logic is changed.
--   ugummall     04-DEC-2003   Bug 3252832. FA 131 - COD Updates.
--                              Added group by clause in cursor cur_get_attendance_type_code.
--   ugummall     20-NOV-2003   Bug 3252832. FA 131 - COD Updates.
--                              1. Added two cursors cur_get_attendance_type_code and cur_get_pell_att_code
--                              2. Modified code in preparing enrollment_status field of the origination record.
------------------------------------------------------------------------------
--   veramach     11-OCT-2003   FA 124
--                              1.COA is required for awarding PELL Grants
--                              2.Pell Award Amount must be less than or equal to amount calculated from PELL matrix
------------------------------------------------------------------------------
--   rasahoo      27-Aug-2003   Removed the call to IGF_AP_OSS_PROCESS.GET_OSS_DETAILS
--                              as part of obsoletion of FA base record history
--   gmuralid     06-JAN-2003  Bug 2728405 Changed Cursor for picking award
--                             details
------------------------------------------------------------------------------
--   vvutukur     17-Feb-2003  Enh#2758804.FACR105 Build.Raised an exception
--                             to show proper error message when the active
--                             isir is not same as the payment isir.
------------------------------------------------------------------------------
--

 CURSOR c_award ( x_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_ci_cal_type      igs_ca_inst_all.cal_type%TYPE,
                  p_ci_seq_num       igs_ca_inst_all.sequence_number%TYPE)
 IS
 SELECT awd.base_id,
        awd.award_id,
        awd.offered_amt,
        awd.accepted_amt,
        awd.fund_id,
        awd.alt_pell_schedule,
        fmast.ci_cal_type,
        fmast.ci_sequence_number
 FROM   igf_aw_award awd,
        igf_aw_fund_mast fmast,
        igf_aw_fund_cat fcat
 WHERE  fmast.ci_cal_type = p_ci_cal_type
 AND    fmast.ci_sequence_number  = p_ci_seq_num
 AND    awd.base_id = NVL(x_base_id,awd.base_id)
 AND    fcat.fed_fund_code = 'PELL'
 AND    awd.award_status  IN ('ACCEPTED','OFFERED')
 AND    awd.fund_id = fmast.fund_id
 AND    fmast.fund_code = fcat.fund_code
 ORDER BY
 awd.base_id,
 awd.award_id;

 l_award c_award%ROWTYPE;

 CURSOR c_awd_disb ( x_award_id igf_aw_award.award_id%type )
 IS
 SELECT
   awd.*
 FROM
   igf_aw_awd_disb awd
 WHERE
   awd.award_id = x_award_id
 ORDER BY awd.disb_num ;

 l_awd_disb c_awd_disb%rowtype ;

--
-- Cursor to Check if Pell Origination Record is Present
--

 CURSOR cur_chk_orig ( x_award_id igf_aw_award.award_id%TYPE)
 IS
 SELECT
   rfms.origination_id
 FROM
   igf_gr_rfms      rfms
 WHERE
   rfms.award_id       = x_award_id ;

 chk_orig_rec cur_chk_orig%ROWTYPE;


 CURSOR c_rfms ( x_award_id igf_aw_award.award_id%TYPE,
                 x_disb_num igf_aw_awd_disb_all.disb_num%TYPE)
 IS
 SELECT
   rfmd.origination_id
 FROM
   igf_gr_rfms      rfms,
   igf_gr_rfms_disb rfmd
 WHERE
   rfms.origination_id = rfmd.origination_id AND
   rfmd.disb_ref_num   = x_disb_num          AND
   rfms.award_id       = x_award_id ;

 l_rfms c_rfms%ROWTYPE;


--
-- Cursor to Pick Award Details
--

CURSOR cur_get_awd ( p_award_id igf_aw_award_all.award_id%TYPE)
IS
SELECT
        adisb1.disb_num,
        adisb2.disb_date
FROM
        igf_aw_awd_disb adisb1,
        igf_aw_awd_disb adisb2
WHERE
        p_award_id = adisb1.award_id
        AND
        adisb1.disb_num
                IN(SELECT MAX(adisb11.disb_num) FROM igf_aw_awd_disb adisb11
                        WHERE adisb11.award_id = adisb1.award_id)
        AND
        adisb1.award_id  = adisb2.award_id
        AND
        adisb2.disb_num
                IN( SELECT MIN(adisb11.disb_num) FROM igf_aw_awd_disb adisb11
                        WHERE adisb11.award_id = adisb2.award_id);


get_awd_rec   cur_get_awd%ROWTYPE;

   l_pell_setup  igf_gr_pell_setup_all%ROWTYPE;
   l_rfms_rec    igf_gr_rfms%ROWTYPE ;
   l_rfmsd_rec   igf_gr_rfms_disb%ROWTYPE ;

   lv_row_id          VARCHAR2(25);
   lv_rfmd_id         NUMBER(15);


   l_origination_id   VARCHAR2(30);
   l_error            VARCHAR2(30);
   l_pell_mat         VARCHAR2(10);
--
-- One Student will have only one Pell Award in a given Award Year
--
-- Cursor to select active isir.

-- Cursor to select payment isir.
CURSOR cur_payment_isir(c_base_id NUMBER) IS
  SELECT isir_id
  FROM   igf_ap_isir_matched
  WHERE  base_id = c_base_id
  AND    payment_isir = 'Y';


CURSOR cur_chk_duplicate_ssn(c_orig_id igf_gr_rfms.origination_id%TYPE) IS
  SELECT 'Y'
  FROM igf_gr_rfms
  WHERE origination_id = c_orig_id;

chk_ssn          VARCHAR2(1);

l_payment_isir   igf_ap_fa_base_rec.payment_isir_id%TYPE;

-- Get coa
CURSOR c_coa_pell(
                cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
              ) IS
  SELECT coa_pell
    FROM igf_ap_fa_base_rec_all
   WHERE base_id = cp_base_id;

CURSOR c_get_rep_pell_id(cp_cal_type VARCHAR2,cp_seq_num NUMBER,cp_att_pell_id VARCHAR2)
IS
SELECT rep.reporting_pell_cd
FROM
      igf_gr_attend_pell gap,
      igf_gr_report_pell rep
WHERE
     gap.ci_cal_type        =  cp_cal_type AND
     gap.ci_sequence_number =  cp_seq_num AND
     gap.attending_pell_cd  =  cp_att_pell_id AND
     gap.rcampus_id         =  rep.rcampus_id;

l_coa_pell  igf_ap_fa_base_rec_all.coa_pell%TYPE;

CURSOR c_get_rep_entity_id(cp_cal_type igs_ca_inst_all.cal_type%TYPE,
                           cp_seq_num  igs_ca_inst_all.sequence_number%TYPE,
                           cp_atd_entity_id igf_gr_rfms_all.atd_entity_id_txt%TYPE) IS
  SELECT rep.rep_entity_id_txt
  FROM igf_gr_attend_pell att,
       igf_gr_report_pell rep
  WHERE att.rcampus_id  = rep.rcampus_id
  AND   att.ci_cal_type = cp_cal_type
  AND   att.ci_sequence_number = cp_seq_num
  AND   att.atd_entity_id_txt  = cp_atd_entity_id;

-- Local variables (Multiple FA offices build -- 10/29/2003 nsidana.)

l_attend_pell_id   VARCHAR2(30);
l_rep_pell_id      VARCHAR2(30);
l_ret_status       VARCHAR2(1);
l_msg_data         VARCHAR2(30);
l_stu_num          VARCHAR2(30);
l_cod_year_flag    BOOLEAN;
l_attend_entity_id igf_gr_rfms_all.atd_entity_id_txt%TYPE ;
l_rep_entity_id    igf_gr_rfms_all.rep_entity_id_txt%TYPE ;



-- FA 131 - COD Updates Build cursors. 20-NOV-2003 ugummall.
  CURSOR cur_base_attendance_type_code(cp_award_id igf_aw_awd_disb_all.award_id%TYPE) IS
  SELECT    base_attendance_type_code
    FROM    igf_aw_awd_disb_all
   WHERE    award_id = cp_award_id
GROUP BY    base_attendance_type_code;
rec_base_attendance_type_code  cur_base_attendance_type_code%ROWTYPE;
-- End FA 131.

  l_return_status     VARCHAR2(1);
  l_return_mesg_text  VARCHAR2(2000);
  l_ft_pell_amt       igf_gr_rfms_all.ft_pell_amount%TYPE;
  l_pell_amt          igf_gr_rfms.pell_amount%TYPE;
  l_program_cd        igf_gr_pell_setup_all.course_cd%TYPE;
  l_program_version   igf_gr_pell_setup_all.version_number%TYPE;
  l_attendance_type   igs_en_stdnt_ps_att.attendance_type%TYPE;

BEGIN

  -- Get the award details
  OPEN  c_award (l_base_id,p_ci_cal_type,p_ci_seq_num);
  ln_cnt := 0;

  LOOP
    FETCH c_award INTO l_award;
    EXIT WHEN c_award%NOTFOUND;

    BEGIN

      OPEN  c_fa_base(l_award.base_id) ;
      FETCH c_fa_base INTO l_fa_base ;

      IF c_fa_base%NOTFOUND THEN
        CLOSE c_fa_base ;

      ELSIF c_fa_base%FOUND THEN
        CLOSE c_fa_base ;

        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_AW_PROCESS_STUD');
        fnd_message.set_token('STUD',igf_gr_gen.get_per_num(l_award.base_id));
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

        OPEN cur_payment_isir(l_award.base_id);
        FETCH cur_payment_isir INTO l_payment_isir;
        CLOSE cur_payment_isir;

        --If active isir is not same as the payment isir, then
        IF ((l_fa_base.isir_id IS NULL OR l_payment_isir IS NULL)
           OR (l_fa_base.isir_id <> l_payment_isir))
        THEN
          fnd_message.set_name('IGF','IGF_AP_PELL_ISIR_CHK');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE MY_EXP;
        END IF;

        OPEN c_coa_pell(l_award.base_id);
        FETCH c_coa_pell INTO l_coa_pell;
        IF l_coa_pell IS NULL THEN
          fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          CLOSE c_coa_pell;
          RAISE MY_EXP;
        END IF;

        IF c_coa_pell%ISOPEN THEN
          CLOSE c_coa_pell;
        END IF;

        OPEN  cur_chk_orig(l_award.award_id);
        FETCH cur_chk_orig INTO chk_orig_rec;
        --
        -- Create RFMS Record only if there is no existing Record
        --
        IF cur_chk_orig%FOUND THEN
          fnd_message.set_name('IGF','IGF_GR_PELL_ALREADY_EXISTS');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          CLOSE cur_chk_orig;
          RAISE MY_EXP;
        ELSE
          CLOSE  cur_chk_orig;

          -- get student's key program details. added the get_key_program api as part of fa132 term based integration
          igf_ap_gen_001.get_key_program(cp_base_id        => l_award.base_id,
                                         cp_course_cd      => l_program_cd,
                                         cp_version_number => l_program_version
                                        );
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell.rfms_load_rec.debug','Key Program > Course cd>' || l_program_cd || ' Version >' || TO_CHAR(l_program_version) );
          END IF;

          -- Get Pell Setup Details
          igf_gr_pell_calc.get_pell_setup(cp_base_id         => l_award.base_id,
                                          cp_course_cd       => l_program_cd,
                                          cp_version_number  => l_program_version,
                                          cp_cal_type        => l_fa_base.ci_cal_type,
                                          cp_sequence_number => l_fa_base.ci_sequence_number ,
                                          cp_pell_setup_rec  => l_pell_setup ,
                                          cp_message         => l_return_mesg_text,
                                          cp_return_status   => l_return_status
                                          );

          IF (l_return_status = 'E') THEN
            fnd_file.put_line(fnd_file.log, l_return_mesg_text);
            EXIT;
          END IF;
          -- End of Get Pell Setup Details.

          -- Load the rfms record

          -- 10/29/2003 nsidana : Multiple FA offices build.

          -- Derive the attending pell ID/attending entity ID for the base ID.

          l_attend_pell_id   := NULL;
          l_attend_entity_id := NULL;
          l_rep_pell_id      := NULL;
          l_rep_entity_id    := NULL;
          l_cod_year_flag    := NULL;

          -- Check wether the awarding year is for COD-XML processing or flat-file processing.
          -- If it is for COD-XML processing, then derive attending entity id otherwise derive atteinding pell id
          l_cod_year_flag := igf_sl_dl_validation.check_full_participant (p_ci_cal_type, p_ci_seq_num,'PELL');

          -- If l_cod_year_flag is true
          IF (l_cod_year_flag) THEN
            -- Derive attending entity id
            igf_sl_gen.get_stu_fao_code(l_award.base_id,'ENTITY_ID',l_attend_entity_id,l_ret_status,l_msg_data);

          ELSE
            -- Derive attending pell id
            igf_sl_gen.get_stu_fao_code(l_award.base_id,'PELL_ID',l_attend_pell_id,l_ret_status,l_msg_data);

          END IF;

          IF (l_ret_status='E') THEN
            IF (l_cod_year_flag) THEN
              fnd_message.set_name('IGF','IGF_GR_NO_ATTEND_ENTITY_ID');
            ELSE
              fnd_message.set_name('IGF','IGF_GR_NO_ATTEND_PELL');
            END IF;
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            RAISE MY_EXP;

          ELSIF ((l_ret_status='S') AND (l_attend_pell_id IS NOT NULL OR l_attend_entity_id IS NOT NULL)) THEN

            -- Derive the report pell ID/reporting entity ID

            -- If l_cod_year_flag is true
            IF (l_cod_year_flag) THEN -- full participation

              -- Derive reporting entity id
              OPEN c_get_rep_entity_id( p_ci_cal_type,p_ci_seq_num,l_attend_entity_id);
              FETCH c_get_rep_entity_id INTO l_rep_entity_id;
              CLOSE c_get_rep_entity_id;

              IF (l_rep_entity_id IS NULL) THEN
                l_stu_num:=igf_gr_gen.get_per_num(l_award.base_id);
                fnd_message.set_name( 'IGF', 'IGF_GR_NOREP_ENTITY');
                fnd_message.set_token('STU_NUMBER',l_stu_num);
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                RAISE MY_EXP;
              END IF;

            ELSE  -- phase-in participation

              OPEN c_get_rep_pell_id(p_ci_cal_type,p_ci_seq_num,l_attend_pell_id);
              FETCH c_get_rep_pell_id INTO l_rep_pell_id;
              CLOSE c_get_rep_pell_id;

              IF (l_rep_pell_id IS NULL) THEN
                l_stu_num:=igf_gr_gen.get_per_num(l_award.base_id);
                fnd_message.set_name( 'IGF', 'IGF_GR_NOREP_PELL');
                fnd_message.set_token('STU_NUMBER',l_stu_num);
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                RAISE MY_EXP;
              END IF;

            END IF;

            IF (l_rep_entity_id IS NOT NULL OR l_rep_pell_id IS NOT NULL) THEN

              -- both reporing and attending pell IDs derived successfully...do the normal processing...
              -- passed l_attend_pell_id instead of l_reporting_pell. This is because Origination Id
              -- expects attending pell

              IF (l_cod_year_flag) THEN -- Full Student

                -- Pass Attending Entity ID COD-XML processing year
                igf_gr_pell.generate_origination_id( l_fa_base.base_id,
                                                     l_attend_entity_id,
                                                     l_origination_id,
                                                     l_error );
              ELSE -- phase-in award year
                -- Pass Attending Pell ID
                igf_gr_pell.generate_origination_id( l_fa_base.base_id,
                                                     l_attend_pell_id,
                                                     l_origination_id,
                                                     l_error );
              END IF;

              OPEN cur_chk_duplicate_ssn(l_origination_id);
              FETCH cur_chk_duplicate_ssn INTO chk_ssn;
              IF (cur_chk_duplicate_ssn%FOUND) THEN
                CLOSE cur_chk_duplicate_ssn;
                fnd_message.set_name( 'IGF', 'IGF_SL_SSN_IN_USE');
                fnd_message.set_token('VALUE',SUBSTR(l_origination_id,1,9));
                fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(l_fa_base.base_id));
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                RAISE MY_EXP;
              END IF;
              CLOSE cur_chk_duplicate_ssn;

              IF ( l_error = 'ISIR' ) THEN
                fnd_message.set_name( 'IGF', 'IGF_GR_ISIR_NOT_FOUND');
                fnd_message.set_token('STUD', igf_gr_gen.get_per_num(l_fa_base.base_id));
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                RAISE NO_SETUP;

              ELSIF  ( l_error = 'CAL' ) THEN

                fnd_message.set_name( 'IGF', 'IGF_GR_CAL_NOT_FOUND');
                fnd_message.set_token('STUD', igf_gr_gen.get_per_num(l_fa_base.base_id));
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                RAISE NO_SETUP;

              ELSIF ( l_error  = 'VAL_NULL' ) then

                fnd_message.set_name( 'IGF', 'IGF_GR_VALS_NULL');
                fnd_message.set_token('STUD',igf_gr_gen.get_per_num(l_fa_base.base_id));
                fnd_file.put_line(fnd_file.log,fnd_message.get());

                RAISE NO_SETUP;

              END IF;

              l_rfms_rec.origination_id            := l_origination_id ;
              l_rfms_rec.ci_cal_type               := l_fa_base.ci_cal_type;
              l_rfms_rec.ci_sequence_number        := l_fa_base.ci_sequence_number;
              l_rfms_rec.base_id                   := l_fa_base.base_id;
              l_rfms_rec.award_id                  := l_award.award_id;
              l_rfms_rec.sys_orig_ssn              := LTRIM(RTRIM(l_fa_base.original_ssn));
              l_rfms_rec.sys_orig_name_cd          := LTRIM(RTRIM(l_fa_base.orig_name_id));
              l_rfms_rec.transaction_num           := l_fa_base.transaction_num;
              l_rfms_rec.efc                       := igf_gr_gen.get_pell_efc(l_fa_base.base_id);

              --
              -- Federal Verification Status Mapping with Grants Verification Status Code is impletemented
              -- in igf_ap_batch_ver_prc_pkg packages The call has been added here
              --

              l_rfms_rec.ver_status_code           := igf_ap_batch_ver_prc_pkg.get_gr_ver_code(l_fa_base.fed_verif_status,
                                                                                               l_fa_base.ci_cal_type,
                                                                                               l_fa_base.ci_sequence_number);
              l_rfms_rec.secondary_efc_cd          := igf_gr_gen.get_pell_efc_code(l_fa_base.base_id);

              ---
              -- Bug ID : 1774268
              --
              IF NVL(l_award.accepted_amt,0) = 0 THEN
                 l_rfms_rec.pell_amount                       := NVL(l_award.offered_amt,0);
              ELSE
                 l_rfms_rec.pell_amount                       := NVL(l_award.accepted_amt,0);
              END IF;

             igf_gr_pell_calc.calc_ft_max_pell(cp_base_id          =>  l_rfms_rec.base_id,
                                               cp_cal_type         =>  l_rfms_rec.ci_cal_type,
                                               cp_sequence_number  =>  l_rfms_rec.ci_sequence_number,
                                               cp_flag             =>  'FULL_TIME',
                                               cp_aid              =>  l_pell_amt,
                                               cp_ft_aid           =>  l_ft_pell_amt,
                                               cp_return_status    =>  l_return_status,
                                               cp_message          =>  l_return_mesg_text
                                              );

          IF (l_return_status = 'E') THEN
            fnd_file.put_line(fnd_file.log,l_return_mesg_text);
          ELSE
              IF l_rfms_rec.pell_amount > l_ft_pell_amt THEN
                fnd_message.set_name('IGF','IGF_GR_LI_PELL_AWD_SCH_MISMTH');
                fnd_message.set_token('AWD_AMT',l_rfms_rec.pell_amount);
                fnd_message.set_token('SCHDL_AMT',l_ft_pell_amt);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                RAISE my_exp;
              ELSE
                l_rfms_rec.ft_pell_amount  := l_ft_pell_amt;
              END IF;
          END IF;




              -- Get the Full Time Pell Amount,First Disbursement Date and Number of Disbursements.

              OPEN  cur_get_awd(l_award.award_id);
              FETCH cur_get_awd INTO get_awd_rec;
              CLOSE cur_get_awd;


              l_rfms_rec.pell_profile              := l_pell_setup.pell_profile;

              -- FA 131 Build. 20-NOV-2003. Preparing enrollment_status field.
              OPEN cur_base_attendance_type_code(l_award.award_id);
              FETCH cur_base_attendance_type_code INTO rec_base_attendance_type_code;

              -- It returns one or more records. Never returns zero records.
              IF (cur_base_attendance_type_code%ROWCOUNT > 1) THEN
                l_rfms_rec.enrollment_status := '5';    -- 5 for Pell Attendance "Others"
              ELSIF (rec_base_attendance_type_code.base_attendance_type_code IS NULL) THEN
                -- cursor returned 1 row. And attendance_type_code is null
                l_rfms_rec.enrollment_status := '5';    -- 5 for Pell Attendance "Others"
              ELSE
                l_rfms_rec.enrollment_status := rec_base_attendance_type_code.base_attendance_type_code;
              END IF;
              CLOSE cur_base_attendance_type_code;
              -- End FA 131 Build.

              l_rfms_rec.enrollment_dt             := get_enrollment_date(l_award.award_id);
              l_rfms_rec.coa_amount                := l_fa_base.coa_pell;
              l_rfms_rec.academic_calendar         := l_pell_setup.academic_cal;
              l_rfms_rec.payment_method            := l_pell_setup.payment_method;
              l_rfms_rec.total_pymt_prds           := l_pell_setup.payment_periods_num;
              l_rfms_rec.incrcd_fed_pell_rcp_cd    := NULL;
              l_rfms_rec.attending_campus_id       := l_attend_pell_id;
              l_rfms_rec.est_disb_dt1              := get_awd_rec.disb_date;
              l_rfms_rec.orig_action_code          := 'R';
              l_rfms_rec.orig_status_dt            := TRUNC(SYSDATE);
              l_rfms_rec.orig_ed_use_flags         := NULL;

              l_rfms_rec.prev_accpt_efc            := NULL;
              l_rfms_rec.prev_accpt_tran_no        := NULL;
              l_rfms_rec.prev_accpt_sec_efc_cd     := NULL;
              l_rfms_rec.prev_accpt_coa            := NULL;
              l_rfms_rec.orig_reject_code          := NULL;
              l_rfms_rec.wk_inst_time_calc_pymt    := l_pell_setup.wk_inst_time_calc_pymt ;
              l_rfms_rec.wk_int_time_prg_def_yr    := l_pell_setup.wk_int_time_prg_def_yr ;
              l_rfms_rec.cr_clk_hrs_prds_sch_yr    := l_pell_setup.cr_clk_hrs_prds_sch_yr ;
              l_rfms_rec.cr_clk_hrs_acad_yr        := l_pell_setup.cr_clk_hrs_acad_yr ;
              l_rfms_rec.inst_cross_ref_cd         := l_pell_setup.inst_cross_ref_code;
              l_rfms_rec.full_resp_code            := l_pell_setup.response_option_code;

              --
              -- Only for Alternate Pell Awards, Low Tution and Fees Code will
              -- be populated
              --

              l_pell_mat := l_award.alt_pell_schedule;
              IF l_pell_mat = 'A' THEN
                   l_rfms_rec.low_tution_fee        := igf_gr_gen.get_tufees_code(l_fa_base.base_id,
                                                                                  l_fa_base.ci_cal_type,
                                                                                  l_fa_base.ci_sequence_number);
              ELSE
                   l_rfms_rec.low_tution_fee       := NULL;
              END IF;

              l_rfms_rec.rec_source                := 'B';
              l_rfms_rec.rfmb_id                   := NULL;
              l_rfms_rec.pending_amount            := NULL;

              lv_row_id := NULL;

              igf_gr_rfms_pkg.insert_row ( x_rowid                             => lv_row_id,
                                           x_origination_id                    => l_rfms_rec.origination_id,
                                           x_ci_cal_type                       => l_rfms_rec.ci_cal_type,
                                           x_ci_sequence_number                => l_rfms_rec.ci_sequence_number,
                                           x_base_id                           => l_rfms_rec.base_id,
                                           x_award_id                          => l_rfms_rec.award_id,
                                           x_rfmb_id                           => l_rfms_rec.rfmb_id,
                                           x_sys_orig_ssn                      => l_rfms_rec.sys_orig_ssn,
                                           x_sys_orig_name_cd                  => l_rfms_rec.sys_orig_name_cd,
                                           x_transaction_num                   => l_rfms_rec.transaction_num,
                                           x_efc                               => l_rfms_rec.efc,
                                           x_ver_status_code                   => l_rfms_rec.ver_status_code,
                                           x_secondary_efc                     => l_rfms_rec.secondary_efc,
                                           x_secondary_efc_cd                  => l_rfms_rec.secondary_efc_cd,
                                           x_pell_amount                       => l_rfms_rec.pell_amount,
                                           x_pell_profile                      => l_rfms_rec.pell_profile,
                                           x_enrollment_status                 => l_rfms_rec.enrollment_status,
                                           x_enrollment_dt                     => l_rfms_rec.enrollment_dt,
                                           x_coa_amount                        => l_rfms_rec.coa_amount,
                                           x_academic_calendar                 => l_rfms_rec.academic_calendar,
                                           x_payment_method                    => l_rfms_rec.payment_method,
                                           x_total_pymt_prds                   => l_rfms_rec.total_pymt_prds,
                                           x_incrcd_fed_pell_rcp_cd            => l_rfms_rec.incrcd_fed_pell_rcp_cd,
                                           x_attending_campus_id               => l_rfms_rec.attending_campus_id,
                                           x_est_disb_dt1                      => l_rfms_rec.est_disb_dt1,
                                           x_orig_action_code                  => l_rfms_rec.orig_action_code,
                                           x_orig_status_dt                    => l_rfms_rec.orig_status_dt,
                                           x_orig_ed_use_flags                 => l_rfms_rec.orig_ed_use_flags,
                                           x_ft_pell_amount                    => l_rfms_rec.ft_pell_amount,
                                           x_prev_accpt_efc                    => l_rfms_rec.prev_accpt_efc,
                                           x_prev_accpt_tran_no                => l_rfms_rec.prev_accpt_tran_no,
                                           x_prev_accpt_sec_efc_cd             => l_rfms_rec.prev_accpt_sec_efc_cd,
                                           x_prev_accpt_coa                    => l_rfms_rec.prev_accpt_coa,
                                           x_orig_reject_code                  => l_rfms_rec.orig_reject_code,
                                           x_wk_inst_time_calc_pymt            => l_rfms_rec.wk_inst_time_calc_pymt,
                                           x_wk_int_time_prg_def_yr            => l_rfms_rec.wk_int_time_prg_def_yr,
                                           x_cr_clk_hrs_prds_sch_yr            => l_rfms_rec.cr_clk_hrs_prds_sch_yr,
                                           x_cr_clk_hrs_acad_yr                => l_rfms_rec.cr_clk_hrs_acad_yr,
                                           x_inst_cross_ref_cd                 => l_rfms_rec.inst_cross_ref_cd,
                                           x_low_tution_fee                    => l_rfms_rec.low_tution_fee,
                                           x_rec_source                        => l_rfms_rec.rec_source,
                                           x_pending_amount                    => l_rfms_rec.pending_amount,
                                           x_mode                              => 'R',
                                           x_birth_dt                          => NULL,
                                           x_last_name                         => NULL,
                                           x_first_name                        => NULL,
                                           x_middle_name                       => NULL,
                                           x_current_ssn                       => NULL,
                                           x_legacy_record_flag                => NULL,
                                           x_reporting_pell_cd                 => l_rep_pell_id,
                                           x_rep_entity_id_txt                 => l_rep_entity_id,
                                           x_atd_entity_id_txt                 => l_attend_entity_id,
                                           x_note_message                      => NULL,
                                           x_full_resp_code                    => l_rfms_rec.full_resp_code,
                                           x_document_id_txt                   => NULL );

              fnd_file.put_line(fnd_file.log,'');
              fnd_message.set_name('IGF','IGF_GR_CREATE_RFMS');
              fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(l_fa_base.base_id));
              fnd_message.set_token('ORIG_ID',l_rfms_rec.origination_id);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              fnd_file.put_line(fnd_file.log,'');

              ln_cnt := ln_cnt + 1;

              --
              -- Insert the RFMS Disbursement Details only for Phase-In
              --
              IF NOT l_cod_year_flag THEN
                OPEN c_awd_disb (l_award.award_id) ;

                LOOP
                  FETCH c_awd_disb into l_awd_disb ;
                  EXIT WHEN c_awd_disb%NOTFOUND;
                  --
                  -- Check if RFMS record is already created
                  --
                  OPEN c_rfms ( l_award.award_id,l_awd_disb.disb_num ) ;
                  FETCH c_rfms INTO l_rfms;
                  --
                  -- This will make sure that only new disbursements from award will go into rfms_disb table
                  --
                  IF c_rfms%NOTFOUND THEN
                    CLOSE c_rfms;
                    IF l_rfms_rec.origination_id IS NOT NULL THEN
                      l_rfmsd_rec.origination_id          := l_rfms_rec.origination_id;
                    ELSE
                      l_rfmsd_rec.origination_id          := chk_orig_rec.origination_id;
                    END IF;

                    l_rfmsd_rec.disb_ref_num            := l_awd_disb.disb_num ;
                    l_rfmsd_rec.disb_dt                 := l_awd_disb.disb_date ;
                    l_rfmsd_rec.disb_amt                := l_awd_disb.disb_net_amt ;

                    IF  l_rfmsd_rec.disb_amt >= 0 THEN
                      l_rfmsd_rec.db_cr_flag       := 'P' ;
                    ELSE
                      l_rfmsd_rec.db_cr_flag       := 'N' ;
                    END IF;

                    l_rfmsd_rec.disb_ack_act_status     := 'R' ;
                    l_rfmsd_rec.disb_status_dt          := TRUNC(SYSDATE);
                    l_rfmsd_rec.disb_accpt_amt          := NULL ;
                    l_rfmsd_rec.accpt_db_cr_flag        := NULL ;
                    l_rfmsd_rec.disb_ytd_amt            := NULL ;
                    l_rfmsd_rec.pymt_prd_start_dt       := NULL ;
                    l_rfmsd_rec.accpt_pymt_prd_start_dt := NULL ;
                    l_rfmsd_rec.edit_code               := NULL ;
                    l_rfmsd_rec.rfmb_id                 := NULL ;


                    -- Insert RFMS Disb Record

                    lv_row_id := NULL;

                    igf_gr_rfms_disb_pkg.insert_row (x_mode                              => 'R',
                                                     x_rowid                             => lv_row_id,
                                                     x_rfmd_id                           => lv_rfmd_id,
                                                     x_origination_id                    => l_rfmsd_rec.origination_id,
                                                     x_disb_ref_num                      => l_rfmsd_rec.disb_ref_num,
                                                     x_disb_dt                           => l_rfmsd_rec.disb_dt,
                                                     x_disb_amt                          => l_rfmsd_rec.disb_amt,
                                                     x_db_cr_flag                        => l_rfmsd_rec.db_cr_flag,
                                                     x_disb_ack_act_status               => l_rfmsd_rec.disb_ack_act_status ,
                                                     x_disb_status_dt                    => l_rfmsd_rec.disb_status_dt ,
                                                     x_accpt_disb_dt                     => l_rfmsd_rec.accpt_disb_dt ,
                                                     x_disb_accpt_amt                    => l_rfmsd_rec.disb_accpt_amt ,
                                                     x_accpt_db_cr_flag                  => l_rfmsd_rec.accpt_db_cr_flag ,
                                                     x_disb_ytd_amt                      => l_rfmsd_rec.disb_ytd_amt ,
                                                     x_pymt_prd_start_dt                 => l_rfmsd_rec.pymt_prd_start_dt ,
                                                     x_accpt_pymt_prd_start_dt           => l_rfmsd_rec.accpt_pymt_prd_start_dt ,
                                                     x_edit_code                         => l_rfmsd_rec.edit_code ,
                                                     x_rfmb_id                           => l_rfmsd_rec.rfmb_id,
                                                     x_ed_use_flags                      => l_rfmsd_rec.ed_use_flags);

                    fnd_message.set_name('IGF','IGF_GR_CREATE_RFMS_DISB');
                    fnd_message.set_token('ORIG_ID',l_rfmsd_rec.origination_id);
                    fnd_message.set_token('DISB_NUM',l_rfmsd_rec.disb_ref_num);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                  ELSIF c_rfms%FOUND THEN
                    CLOSE c_rfms;
                  END IF;
                END LOOP;
                CLOSE c_awd_disb;
              END IF; -- phase-in, insert gr disbursement
            END IF;        -- for successful derivation of the Report Pell.
          END IF; -- for l_ret_status='E'
        END IF; -- cur_chk_orig IF ..
      END IF;     -- cur c_fa_base IF

      IF cur_chk_orig%ISOPEN THEN
        CLOSE  cur_chk_orig;
      END IF;

    EXCEPTION

      WHEN  NO_SETUP THEN
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

      WHEN MY_EXP THEN
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);
        ln_cnt := ln_cnt +1;
    END;          -- Block

  END LOOP;             -- c_award LOOP
  CLOSE c_award;

  IF ln_cnt > 0 THEN
    NULL;
  ELSE
    fnd_message.set_name('IGF','IGF_AP_NO_DATA_FOUND');   -- Origination Record already exist
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_PELL.RFMS_LOAD_REC');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END rfms_load_rec ;


PROCEDURE rfms_load( errbuf               OUT NOCOPY    VARCHAR,
                     retcode              OUT NOCOPY    NUMBER,
                     l_award_year         IN     VARCHAR2,
                     l_base_id            IN     igf_ap_fa_base_rec_all.base_id%TYPE,
                     p_org_id             IN     NUMBER )
IS

--
------------------------------------------------------------------------------
--
--   Created By : cdcruz
--   Created On : 14-NOV-2000
--   Purpose :
--   Known limitations, enhancements or remarks :
--   Change History :
------------------------------------------------------------------------------
--   Who          When         What
------------------------------------------------------------------------------
--   rasahoo      27-Aug-2003  Removed the parameter P_GET_RECENT_INFO
--                             as part of obsoletion of FA base record history
--   gmuralid     06-JAN-2003  Bug 2728405 Changed Cursor for picking award
--                             details
------------------------------------------------------------------------------
--   vvutukur     17-Feb-2003  Enh#2758804.FACR105 Build.Raised an exception
--                             to show proper error message when the active
--                             isir is not same as the payment isir.
------------------------------------------------------------------------------
--

  l_ci_cal_type        igs_ca_inst_all.cal_type%TYPE;
  l_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE;


BEGIN

     retcode := 0 ;
     lv_invoke := 'JOB';

     igf_aw_gen.set_org_id(p_org_id);

     l_ci_cal_type        := LTRIM(RTRIM(SUBSTR(l_award_year,1,10)));
     l_ci_sequence_number := TO_NUMBER(SUBSTR(l_award_year,11));

     IF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN
            retcode := 2 ;
            errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
            igs_ge_msg_stack.conc_exception_hndl;
     ELSE
            rfms_load_rec(l_ci_cal_type,l_ci_sequence_number,l_base_id);

     END IF;

     COMMIT;

EXCEPTION

      WHEN app_exception.record_lock_exception THEN
                ROLLBACK;
                retcode:=2;
                fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
                igs_ge_msg_stack.add;
                errbuf := fnd_message.get;

       WHEN OTHERS THEN
                ROLLBACK;
                retcode:=2;
                errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                fnd_file.put_line(fnd_file.log,SQLERRM);
                igs_ge_msg_stack.conc_exception_hndl;

END rfms_load ;

PROCEDURE generate_origination_id( l_base_id        IN   NUMBER,
                                   l_attend_pell_id    IN   VARCHAR2,
                                   l_origination_id OUT NOCOPY  VARCHAR2,
                                   l_error          OUT NOCOPY  VARCHAR2  )
IS

------------------------------------------------------------------------
-- sjadhav  10-Feb-2003     Bug 2758812 - FA116 Pell Build
--                          Modified generate_origination_id to read
--                          pell cycle year using function
--                          igf_gr_gen.get_cycle_year
------------------------------------------------------------------------

  CURSOR c_isir ( x_base_id   igf_ap_fa_base_rec.base_id%TYPE)
  IS
  SELECT
    isir.original_ssn,
    isir.orig_name_id
  FROM
    igf_ap_isir_matched isir
  WHERE isir.base_id = x_base_id
    AND isir.active_isir = 'Y' ;

  l_isir c_isir%rowtype;


  CURSOR c_cal ( x_base_id    igf_ap_fa_base_rec.base_id%TYPE)
  IS
  SELECT
    ci_cal_type,ci_sequence_number
  FROM
    igf_ap_fa_base_rec  fabase
  WHERE
    fabase.base_id = x_base_id;

  l_cal c_cal%rowtype;

BEGIN

  l_error := NULL;

  -- Get ISIR details
  OPEN c_isir( l_base_id ) ;
  FETCH c_isir into l_isir ;
  IF c_isir%NOTFOUND THEN
    l_error := 'ISIR';
    CLOSE c_isir ;
    RETURN;
  END IF;
  CLOSE c_isir ;

  -- Get calendar dates
  OPEN c_cal( l_base_id );
  FETCH c_cal into l_cal ;
  IF ( c_cal%NOTFOUND ) THEN
    l_error := 'CAL';
    CLOSE c_cal;
    RETURN;
  END IF;
  CLOSE c_cal;

  IF ( (l_isir.original_ssn IS NOT NULL) AND
       (l_isir.orig_name_id IS NOT NULL) AND
       (l_cal.ci_cal_type   IS NOT NULL) AND
       (l_attend_pell_id IS NOT NULL)) THEN
    l_origination_id  := l_isir.original_ssn          ||
                         RPAD(l_isir.orig_name_id,2,' ')  ||
                         igf_gr_gen.get_cycle_year
                         (l_cal.ci_cal_type,
                          l_cal.ci_sequence_number)   ||
                         RTRIM(LTRIM(l_attend_pell_id))  ||
                         '00';
  ELSE
    l_error := 'VAL_NULL';
  END IF;

EXCEPTION

        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_PELL.GENERATE_ORIGINATION_ID' ||' '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END generate_origination_id;

FUNCTION get_enrollment_date(p_award_id igf_aw_award_all.award_id%TYPE)
RETURN DATE
AS

CURSOR cur_enrollment_date(cp_award_id igf_aw_award_all.award_id%TYPE) IS
  SELECT ld_cal_type,ld_sequence_number
    FROM igf_aw_awd_disb_all
   WHERE award_id = cp_award_id
     AND trans_type <> 'C';

CURSOR c_base_id(cp_award_id igf_aw_award_all.award_id%TYPE) IS
  SELECT base_id
    FROM igf_aw_award_all
   WHERE award_id = cp_award_id;
l_base_id igf_ap_fa_base_rec_all.base_id%TYPE;

p_start_dt DATE;
l_start_dt DATE;
l_end_dt   DATE;
l_first_cycle VARCHAR2(1);

BEGIN
  p_start_dt := NULL;
  l_base_id := NULL;

  OPEN c_base_id(p_award_id);
  FETCH c_base_id INTO l_base_id;
  CLOSE c_base_id;

  l_first_cycle := 'Y';

  FOR rec IN cur_enrollment_date(p_award_id) LOOP
    igf_ap_gen_001.get_term_dates(
                                  p_base_id            => l_base_id,
                                  p_ld_cal_type        => rec.ld_cal_type,
                                  p_ld_sequence_number => rec.ld_sequence_number,
                                  p_ld_start_date      => l_start_dt,
                                  p_ld_end_date        => l_end_dt
                                 );
    IF l_first_cycle = 'Y' THEN
      p_start_dt := l_start_dt;
      l_first_cycle := 'N';
    ELSE
      p_start_dt := LEAST(p_start_dt,l_start_dt);
    END IF;
  END LOOP;

  RETURN p_start_dt;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END get_enrollment_date;

END igf_gr_pell;

/
