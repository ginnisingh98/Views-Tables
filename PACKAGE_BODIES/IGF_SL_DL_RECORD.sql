--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_RECORD" AS
/* $Header: IGFSL11B.pls 120.1 2006/04/21 05:01:20 bvisvana noship $ */

/*
--------------------------------------------------------------------
-- who             when               what
----------------------------------------------------------------------------------
-- upinjark       16-Feb-2005    Bug #4187798. Modified line no 181,227,422
                                               replacing FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
					       with FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
----------------------------------------------------------------------------------

  brajendr    12-Oct-2004     FA138 ISIR Enhacements
                              Modified the reference of payment_isir_id

--------------------------------------------------------------------
-- veramach        29-Jan-2004     bug 3408092 added 2004-2005 in p_dl_version checks
-----------------------------------------------------------------------------------
-- ugummall       17-OCT-2003         Bug 3102439. FA 126. Multiple FA Offices.
--                                    New parameter p_school_code is added to procedures
--                                    DLHeader_cur and DLOrig_cur.
--------------------------------------------------------------------
-- sjadhav        7-Oct-2003          Bug 3104228 FA 122 Build
--                                    added join condition in cursor
--                                    c_lor_details for fund code
--                                    Removed ref to obsolete columns
--------------------------------------------------------------------
--
-- sjadhav,
-- Bug 2436484
-- removed references to igf_ap_batch_aw_map table
-- in get_acad_begin_date and _get_acad_end_date functions
-- Use igs_ad_gen_008.get_acadcal function to get acad dates
-- for the functions get_acad_begin_date and get_acad_end_date
-- the passed in parameters are not used
--
*/

p_rec_length   igf_sl_dl_file_type.rec_length%TYPE;

PROCEDURE DLHeader_cur(p_dl_version        igf_lookups_view.lookup_code%TYPE,
                       p_dl_loan_catg      igf_lookups_view.lookup_code%TYPE,
                       p_cal_type          igs_ca_inst.cal_type%TYPE,
                       p_cal_seq_num       igs_ca_inst.sequence_number%TYPE,
                       p_file_type         igf_sl_dl_file_type.dl_file_type%TYPE,
                       p_school_code IN  VARCHAR2,
                       p_dbth_id    IN OUT NOCOPY igf_sl_dl_batch.dbth_id%TYPE,
                       p_batch_id   IN OUT NOCOPY igf_sl_dl_batch.batch_id%TYPE,
                       p_mesg_class IN OUT NOCOPY igf_sl_dl_batch.message_class%TYPE,
                       Header_Rec   IN OUT NOCOPY igf_sl_dl_record.DLHeaderType)
AS

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History:
  Who             When            What
  ugummall        17-OCT-2003     Bug 3102439. FA 126. Multiple FA Offices.
                                  As school_id is obsoleted from igf_sl_dl_setup table,
                                  its reference is replaced with supplied parameter p_school_code
  smvk            18-Feb-2003     Bug # 2758823. Modified the p_dl_version checking from '2001-2002','2002-2003' to '2002-2003','2003-2004'.
  mesriniv        8-jul-2002      Changed LPAD(TO_CHAR(p_rec_length),4) to LPAD(TO_CHAR(p_rec_length),4,0)
  Who             When            What
  mesriniv        14-MAR-2002     Added when no data found Exception as part of the Bug :- 2255281.
                                  DL Version Change
  adhawan         19-02-2002      changed the references of 2001-2002 to 2002-2003
                                  changed the header and the orig record as per 2002-2003 file format changes
  (reverse chronological order - newest change first)
  ***************************************************************/

  lv_message_class igf_sl_dl_file_type.message_class%TYPE;
  lv_batch_type    igf_sl_dl_file_type.batch_type%TYPE;
  lv_cycle_year    igf_sl_dl_file_type.cycle_year%TYPE;

BEGIN

  -- Message Class, Batch Type and Cycle Year have been predefined for each Version+Filetype
  -- in igf_sl_dl_file_type seed data table.
  p_mesg_class     := igf_sl_gen.get_dl_file_type(p_dl_version, p_file_type,
                           p_dl_loan_catg, 'MESSAGE-CLASS');
  lv_batch_type    := igf_sl_gen.get_dl_file_type(p_dl_version, p_file_type,
                           p_dl_loan_catg, 'BATCH-TYPE');
  lv_cycle_year    := igf_sl_gen.get_dl_file_type(p_dl_version, p_file_type,
                           p_dl_loan_catg, 'CYCLE-YEAR');
  p_rec_length     := igf_sl_gen.get_dl_file_type(p_dl_version, p_file_type,
                           p_dl_loan_catg, 'REC-LENGTH');

  IF p_dl_version IN ('2002-2003','2003-2004','2004-2005') THEN

     DECLARE

        lv_file_datetime  DATE;
        lv_rowid          VARCHAR2(25);

--Bug 2490289  Batch ID's Time Component and the seperate field Time Component
--should be same.The time component should HH24MISS and not HH24MMSS.
        CURSOR cur_dl_setup IS
        SELECT lv_batch_type||
               substr(lv_cycle_year,-1,1)||
               RPAD(p_school_code,6,' ') ||
               TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')        batch_id,
               SYSDATE                                    file_datetime
        FROM igf_sl_dl_setup_v
        WHERE ci_cal_type        = p_cal_type
        AND   ci_sequence_number = p_cal_seq_num;

     BEGIN

        /************* Get Batch-ID details ****************/
        OPEN cur_dl_setup;
        FETCH cur_dl_setup into p_batch_id, lv_file_datetime;
        IF cur_dl_setup%NOTFOUND THEN
            CLOSE cur_dl_setup;
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE cur_dl_setup;

        OPEN Header_Rec FOR
        SELECT    RPAD('DL HEADER',10)
                ||LPAD(TO_CHAR(p_rec_length),4,0)
                ||LPAD(p_mesg_class,8)
                ||RPAD(p_batch_id,23)
                ||RPAD(TO_CHAR(lv_file_datetime,'YYYYMMDD'),8)
                ||LPAD(TO_CHAR(lv_file_datetime,'HH24MISS'),6)
                ||RPAD(' ', 2)
                ||RPAD(' ', 8)
                ||RPAD(' ',2)
                ||RPAD('IGS1157',9)
                ||RPAD(' ',(p_rec_length-80))  h_record  FROM DUAL;

        igf_sl_dl_batch_pkg.insert_row (
          x_mode                              => 'R',
          x_rowid                             => lv_rowid,
          X_dbth_id                           => p_dbth_id,
          X_batch_id                          => p_batch_id,
          X_message_class                     => p_mesg_class,
          X_bth_creation_date                 => lv_file_datetime,
          X_batch_rej_code                    => NULL,
          X_end_date                          => NULL,
          X_batch_type                        => lv_batch_type,
          X_send_resp                         => 'S',            -- Send File
          X_status                            => 'Y'             -- Status = Processed
        );

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
         IF cur_dl_setup%ISOPEN THEN
            CLOSE cur_dl_setup;
         END IF;
         fnd_message.set_name('IGF','IGF_GE_NO_DATA_FOUND');
         fnd_message.set_token('NAME','igf_sl_dl_orig.set_batch_details');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
     END;

    END IF;

EXCEPTION
--Added this Exception as part of the Bug :- 2255281.
--DL Version Change
--This is to ensure that even if the DL Setup has the particular version specified,
--it is better we check if the IGF_SL_DL_FILE_TYPE (Seeded Table-Latest File Versions to
--shipped every time new Version Comes in) has the File Type Details.
--DL Setup picks up the Version from Lookups for LOOKUP_TYPE='IGF_SL_DL_VERSION'
WHEN NO_DATA_FOUND THEN
   fnd_message.set_name('IGF','IGF_SL_DL_NO_VERSION');
   fnd_message.set_token('P_DL_VERSION',p_dl_version);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_dl_record.DLHeader_cur.exception',SQLERRM);
    END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_record.DLHeader_cur');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END DLHeader_cur;


PROCEDURE DLTrailer_cur(p_dl_version         igf_lookups_view.lookup_code%TYPE,
                        p_num_of_rec         NUMBER,
                        Trailer_Rec   IN OUT NOCOPY igf_sl_dl_record.DLTrailerType)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Bug No:2438434
  Desc :DL Orig Process.Incorrect Format in Output File
  Who             When            What
  smvk            18-Feb-2003     Bug # 2758823. Modified the p_dl_version checking from '2001-2002','2002-2003' to '2002-2003','2003-2004'.
  mesriniv        1-jul-2002      Changed LPAD(TO_CHAR(p_rec_length),4) to LPAD(TO_CHAR(p_rec_length),4,0)
                                  Changed LPAD(TO_CHAR(p_num_of_rec),7) to LPAD(TO_CHAR(p_num_of_rec),7,0)
                                  RPAD(' ',(p_rec_length-80)) was added make trailer rec length same as Header Record Length
  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN

    IF p_dl_version IN ('2002-2003','2003-2004','2004-2005') THEN
      OPEN Trailer_Rec FOR
      SELECT  RPAD('DL TRAILER',10)||
              LPAD(TO_CHAR(p_rec_length),4,0)||
              LPAD(TO_CHAR(p_num_of_rec),7,0)||
              RPAD(' ', 5)||
              RPAD(' ', 5)||
              RPAD(' ', 5)||
              RPAD(' ',44)||
              RPAD(' ',(p_rec_length-80)) t_record  FROM DUAL;
    END IF;

EXCEPTION
WHEN OTHERS THEN
   IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_dl_record.DLTrailer_cur.exception',SQLERRM);
    END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_record.DLTrailer_cur');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END DLTrailer_cur;


FUNCTION  DLDisbDetails(p_dl_version    igf_lookups_view.lookup_code%TYPE,
                        p_award_id      igf_aw_award.award_id%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Bug 2438434.Incorrect Format in Output File.
  Who             When            What
  smvk            18-Feb-2003     Bug # 2758823. Modified the p_dl_version checking from '2001-2002','2002-2003' to '2002-2003','2003-2004'.
  mesriniv        1-jul-2002      Made LPAD of 0 for Amount Fields
  (reverse chronological order - newest change first)
  ***************************************************************/

   lv_disb_details  VARCHAR2(4000) := '';
   --Int_rebate_amt is being picked from the Disbursement Table directly instead of the
   --calculation
   --Bug 2438434.
   CURSOR cur_disb IS
   SELECT adisb.disb_date, NVL(adisb.disb_accepted_amt,adisb.disb_gross_amt) disb_gross_amt, adisb.fee_1,
          adisb.int_rebate_amt interest_rebate,
         adisb.disb_net_amt
   FROM igf_aw_award       awd,
        igf_aw_awd_disb    adisb,
        igf_aw_fund_mast   fmast,
        igf_aw_fund_cat    fcat,
        igf_ap_fa_base_rec fabase

   WHERE awd.award_id    = p_award_id
   AND   adisb.award_id  = awd.award_id
   AND   awd.fund_id     = fmast.fund_id
   AND   fmast.fund_code = fcat.fund_code
   AND   awd.base_id     = fabase.base_id
   ORDER BY adisb.disb_num;
BEGIN

  IF p_dl_version IN ('2002-2003','2003-2004','2004-2005') THEN

    FOR orec IN cur_disb LOOP
       lv_disb_details :=   lv_disb_details
                          ||LPAD(NVL(TO_CHAR(orec.disb_date,'YYYYMMDD'),' '),8)
                          ||LPAD(NVL(TO_CHAR(orec.disb_gross_amt)      ,'0'),5,0)
                          ||LPAD(NVL(TO_CHAR(orec.fee_1)               ,'0'),5,0)
                          ||LPAD(NVL(TO_CHAR(orec.interest_rebate)     ,'0'),5,0)
                          ||LPAD(NVL(TO_CHAR(orec.disb_net_amt)        ,'0'),5,0);
    END LOOP;

    RETURN lv_disb_details;

  END IF;

  RETURN NULL;

END DLDisbDetails;


-- masehgal   # 2593215   new  procedure to return   acad begin and end dates ...
-- this will replace get_Acad_begin_date   and get_acad_end_date Functions ...

PROCEDURE get_acad_cal_dtls( p_loan_number                 igf_sl_loans_all.loan_number%TYPE,
                             p_acad_cal_type    OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                             p_acad_seq_num     OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                             p_acad_begin_date  IN OUT NOCOPY igs_ps_ofr_inst.ci_start_dt%TYPE,
                             p_acad_end_date    IN OUT NOCOPY igs_ps_ofr_inst.ci_end_dt%TYPE ,
                             p_message          OUT NOCOPY VARCHAR2 )
AS
  /*************************************************************
  Created By : masehgal
  Date Created On : 08-Jan-2003
  Purpose :  To Get Acad Cal related details
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  bkkumar         30-sep-2003     Removed the c_get_base_id cursor as that was taking wrong
                                  imput paramters and is not required since same information is
                                  obtained from  c_get_person_id cursor.
                                  Added debug log messages
  rasahoo         01-Sep-2003     Removed the Cursor c_get_enr_prog and all its references
                                  as part of the build FA-114 (Obsoletion of FA base record History)
  bkkumar         27-Aug-2003     Bug# 3071157 Removed the unnecessary to_date()
  (reverse chronological order - newest change first)
  ***************************************************************/

  -- cursor to get person_id from loan_number
  -- We need person id to get primary enrol prog from FA Base History
  CURSOR  c_get_person_id ( cp_loan_number  igf_sl_loans.loan_number%TYPE) IS
     SELECT fa.person_id,
            fa.base_id
       FROM igf_ap_fa_base_rec fa, igf_sl_loans loan , igf_aw_award awd
      WHERE fa.base_id      = awd.base_id
        AND awd.award_id    = loan.award_id
        AND loan.loan_number = cp_loan_number ;

  -- cursor to get loan_dates for that loan_number
  -- We need loan_dates to determine proper acad cal
  CURSOR  c_get_loan_dates ( cp_loan_number  igf_sl_loans.loan_number%TYPE) IS
     SELECT loan_per_begin_date , loan_per_end_date
       FROM igf_sl_loans
      WHERE loan_number = cp_loan_number ;

  -- cursor to get acad_cal for that loan_number
  CURSOR  get_acad_cal ( cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE ,
                         cp_ver_num      igs_ps_ofr_inst.version_number%TYPE ,
                         cp_start_dt     igf_sl_loans_v.loan_per_begin_date%TYPE ,
                         cp_end_dt       igf_sl_loans_v.loan_per_end_date%TYPE ) IS
     SELECT  cal_type, ci_sequence_number, ci_start_dt, ci_end_dt
       FROM  igs_ps_ofr_inst
      WHERE  course_cd      =  cp_course_cd
        AND  version_number =  cp_ver_num
        AND  ci_start_dt    <= cp_start_dt
        AND  ci_end_dt      >= cp_end_dt ;

  l_person_id           igf_ap_fa_base_rec.person_id%TYPE ;
  l_base_id             igf_ap_fa_base_rec.base_id%TYPE;
  l_get_loan_dates_rec  c_get_loan_dates%ROWTYPE ;
  l_get_acad_cal_rec    get_acad_cal%ROWTYPE ;

  l_course_cd           igs_ps_ofr_inst.course_cd%TYPE ;
  l_ver_num             igs_ps_ofr_inst.version_number%TYPE ;
  l_begin_dt            igf_sl_loans.loan_per_begin_date%TYPE ;
  l_end_dt              igf_sl_loans.loan_per_end_date%TYPE ;

BEGIN

   -- check if loan number is null ...
   -- if so then return
   IF p_loan_number IS NULL THEN
      RETURN ;
   END IF ;

   --First get the person_id
   OPEN  c_get_person_id (p_loan_number) ;
   FETCH c_get_person_id  INTO l_person_id,l_base_id  ;
   CLOSE c_get_person_id ;
   -- if a laon exists then a person has to exist .. therefore not checking for notfound condition

  -- PUT DEBUG MESSAGES HERE
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.get_acad_cal_dtls.debug','l_base_id passed to get_key_program:'|| l_base_id);
    END IF;
   -- Call generic API get_key_program to get course code and version number
   igf_ap_gen_001.get_key_program(l_base_id,l_course_cd,l_ver_num);

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.get_acad_cal_dtls.debug','l_course_cd got from get_key_program:'|| l_course_cd);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.get_acad_cal_dtls.debug','l_ver_num got from get_key_program:'|| l_ver_num);
    END IF;

   IF p_acad_begin_date IS NOT NULL AND p_acad_end_date IS NOT NULL THEN

      l_begin_dt := p_acad_begin_date;
      l_end_dt   := p_acad_end_date;

   ELSE
   --get loan_dates
      OPEN  c_get_loan_dates (p_loan_number) ;
      FETCH c_get_loan_dates  INTO  l_get_loan_dates_rec  ;
      CLOSE c_get_loan_dates ;
   -- if a loan exists then dates have to exist .. therefore not checking for notfound condition
   -- assign to variables
      l_begin_dt    := l_get_loan_dates_rec.loan_per_begin_date ;
      l_end_dt      := l_get_loan_dates_rec.loan_per_end_date ;

   END IF;

   -- Get the acad cal for these dates
   -- bvisvana - Bug 5078761
   IF l_course_cd IS NOT NULL AND l_ver_num IS NOT NULL THEN
   OPEN  get_acad_cal (l_course_cd, l_ver_num, l_begin_dt, l_end_dt ) ;
   FETCH get_acad_cal  INTO  l_get_acad_cal_rec  ;
   IF get_acad_cal%NOTFOUND THEN
      p_message := 'IGF_SL_NO_ACAD_DATES' ;
   ELSE
      -- assign to variables
      p_acad_cal_type    := l_get_acad_cal_rec.cal_type ;
      p_acad_seq_num     := l_get_acad_cal_rec.ci_sequence_number ;
      p_acad_begin_date  := l_get_acad_cal_rec.ci_start_dt ;
      p_acad_end_date    := l_get_acad_cal_rec.ci_end_dt ;
      p_message          := NULL ;
   END IF;
   CLOSE get_acad_cal ;
   ELSE
      p_message := 'IGF_SL_NO_KEYPRG_ACAD_CAL';
   END IF; -- Bug 5078761

EXCEPTION
   WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_dl_record.get_acad_cal_dtls.exception',SQLERRM);
    END IF;
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_SL_DL_RECORD.GET_ACAD_CAL_DTLS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
END get_acad_cal_dtls ;



PROCEDURE DLOrig_cur(p_dl_version        igf_lookups_view.lookup_code%TYPE,
                     p_dl_loan_catg      igf_lookups_view.lookup_code%TYPE,
                     p_ci_cal_type       igs_ca_inst.cal_type%TYPE,
                     p_ci_seq_num        igs_ca_inst.sequence_number%TYPE,
                     p_dl_loan_number    igf_sl_loans.loan_number%TYPE,
                     p_dl_batch_id       igf_sl_dl_batch.batch_id%TYPE,
                     p_school_code  IN     VARCHAR2,
                     Orig_Rec     IN OUT NOCOPY igf_sl_dl_record.DLOrigType)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History:
  Bug 2438434.Incorrect Format in Output File.
  Who             When            What
  ugummall       17-OCT-2003    Bug 3102439. FA 126. Multiple FA Offices.
                                As school_id is obsoleted from igf_sl_dl_setup table, its reference
                                is removed and supplied parameter p_school_code is used.


  bkkumar    30-sep-2003        Bug 3104228 FA 122 Loans Enhancements
                                Added the cursor c_lor_details  and
                                instead of using igf_sl_lor_dtls_v used simple
                                joins and got the details of student and parent
                                from igf_sl_gen.get_person_details.
                                Added the debugging log messages.
  smvk            17-Feb-2003     Bug # 2758823. Added filler space from 132 to 153 for dl_version 2003-2004 for ED to use.
  mesriniv        1-jul-2002      Made UPPERCASE for Name,Address Fields,Code added for Student/Parent Phone
  Bug :- 2426609 SSN Format Incorrect in Output File
  Who             When            What
  mesriniv        21-jun-2002     Wherever Student SSN/Parent SSN is output
                                  formatting is done before the output.

  (reverse chronological order - newest change first)
  ***************************************************************/


   lv_acad_begin_dt     igs_ca_inst.start_dt%TYPE;
   lv_acad_end_dt       igs_ca_inst.end_dt%TYPE;
   l_p_phone            VARCHAR2(80);
   l_s_phone            VARCHAR2(80);
   lv_acad_cal_type     igs_ca_inst.cal_type%TYPE := NULL;
   lv_acad_seq_number   igs_ca_inst.sequence_number%TYPE := NULL ;
   lv_message           VARCHAR2(100) ;

   l_fed_fund_1 igf_aw_fund_cat.fed_fund_code%TYPE;
   l_fed_fund_2 igf_aw_fund_cat.fed_fund_code%TYPE;
   student_dtl_cur igf_sl_gen.person_dtl_cur;
   parent_dtl_cur  igf_sl_gen.person_dtl_cur;
   student_dtl_rec  igf_sl_gen.person_dtl_rec;
   parent_dtl_rec   igf_sl_gen.person_dtl_rec;

   -- cursor to replace the columns selected from the igf_sl_lor_dtls_v FA 122 Enhancements

   CURSOR c_lor_details (
                cp_cal_type         igs_ca_inst.cal_type%TYPE,
                cp_seq_number       igs_ca_inst.sequence_number%TYPE,
                cp_fed_fund_1       igf_aw_fund_cat.fed_fund_code%TYPE,
                cp_fed_fund_2       igf_aw_fund_cat.fed_fund_code%TYPE,
                cp_loan_status      igf_sl_loans.loan_status%TYPE,
                cp_active           igf_sl_loans.active%TYPE,
                cp_dl_loan_number   igf_sl_loans.loan_number%TYPE
                ) IS
   SELECT
    loans.row_id,
    loans.loan_id,
    loans.loan_number,
    loans.award_id,
    awd.accepted_amt loan_amt_accepted,
    loans.loan_per_begin_date,
    loans.loan_per_end_date,
    lor.orig_fee_perct,
    lor.pnote_print_ind,
    lor.s_default_status,
    lor.p_default_status,
    lor.p_person_id,
    lor.grade_level_code,
    lor.unsub_elig_for_heal,
    lor.disclosure_print_ind,
    lor.unsub_elig_for_depnt,
    lor.pnote_batch_id,
    lor.pnote_ack_date,
    lor.pnote_mpn_ind,
    lor.sch_cert_date,
    fabase.base_id,
    fabase.person_id student_id,
    awd.accepted_amt,
    isr.alien_reg_number,
    isr.citizenship_status,
    isr.dependency_status
   FROM
    igf_sl_loans       loans,
    igf_sl_lor         lor,
    igf_aw_award       awd,
    igf_aw_fund_mast   fmast,
    igf_aw_fund_cat    fcat,
    igf_ap_fa_base_rec fabase,
    igf_ap_isir_matched isr
   WHERE
    fabase.ci_cal_type        = cp_cal_type     AND
    fabase.ci_sequence_number = cp_seq_number   AND
    fabase.base_id            = awd.base_id     AND
    awd.fund_id               = fmast.fund_id   AND
    fabase.base_id            = isr.base_id     AND
    isr.payment_isir          = 'Y'             AND
    isr.system_record_type    = 'ORIGINAL'      AND
    fcat.fund_code            = fmast.fund_code AND
    (fcat.fed_fund_code       = cp_fed_fund_1   OR    fcat.fed_fund_code =  cp_fed_fund_2) AND
    loans.award_id            = awd.award_id    AND
    loans.loan_number         LIKE NVL(cp_dl_loan_number,loans.loan_number) AND
    loans.loan_id             = lor.loan_id     AND
    loans.loan_status         = cp_loan_status  AND
    loans.active              = cp_active;

    l_lor_details c_lor_details%ROWTYPE;


   --Cursor cur_dl_setup is deleted here as school_id is obsoleted from table igf_sl_dl_setup. FA 126

   --Cursor to select the Person ID for the loan ID

BEGIN


  -- masehgal   # 2593215   removing begin/end date calls ....
  -- instead use get_acad_cal_dtls ....

  get_acad_cal_dtls( p_dl_loan_number,
                     lv_acad_cal_type,
                     lv_acad_seq_number,
                     lv_acad_begin_dt,
                     lv_acad_end_dt,
                     lv_message ) ;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.DLOrig_cur.debug','lv_message got from get_acad_cal_dtls:'|| lv_message);
    END IF;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.DLOrig_cur.debug','lv_acad_begin_date got from get_acad_cal_dtls:'|| lv_acad_begin_dt);
    END IF;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_record.DLOrig_cur.debug','lv_acad_end_date got from get_acad_cal_dtls:'|| lv_acad_end_dt);
    END IF;
  -- FA 122 Loan Enhancements derive the paramters to be passed to the c_lor cursor
  IF p_dl_loan_catg = 'DL_STAFFORD' THEN
    l_fed_fund_1 := 'DLS';
    l_fed_fund_2 := 'DLU';
  ELSIF p_dl_loan_catg = 'DL_PLUS' THEN
    l_fed_fund_1 := 'DLP';
    l_fed_fund_2 := 'DLP';
  END IF;

  l_lor_details := NULL;
  OPEN c_lor_details(p_ci_cal_type,p_ci_seq_num,l_fed_fund_1,l_fed_fund_2,'V','Y',p_dl_loan_number);
  FETCH c_lor_details INTO l_lor_details;
  CLOSE c_lor_details;

   -- FA 122 Loan Enhancements Use the igf_sl_gen.get_person_details for getting the student as
   -- well as parent details.

   -- get the student details
   igf_sl_gen.get_person_details(l_lor_details.student_id,student_dtl_cur);
   FETCH student_dtl_cur INTO student_dtl_rec;

   -- get the parene details
   igf_sl_gen.get_person_details(l_lor_details.p_person_id,parent_dtl_cur);
   FETCH parent_dtl_cur INTO parent_dtl_rec;

   CLOSE student_dtl_cur;
   CLOSE parent_dtl_cur;

  -- all the cursors are now using the values selected from the l_lor_details cursor and the person related info
  -- from the student_dtl_cur , parent_dtl_cur.

  IF p_dl_version = '2002-2003' THEN

    IF p_dl_loan_catg = 'DL_STAFFORD' THEN

      OPEN Orig_Rec FOR
      SELECT  l_lor_details.award_id       award_id,
              l_lor_details.loan_id        loan_id,
              l_lor_details.loan_number    loan_number,
                RPAD(l_lor_details.loan_number,21)                                      -- #1
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn),9)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_first_name)       ,' '),12)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_last_name)        ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_middle_name)      ,' '), 1)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_addr1)||' '||UPPER(student_dtl_rec.p_permt_addr2),' ') ,35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_city)       ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_state)      ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_permt_zip        ,' '), 9)
              ||DECODE(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(l_lor_details.base_id)),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(l_lor_details.base_id)),10,0))
              ||RPAD(' ',22)
              ||RPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||LPAD(' ', 1)
              ||LPAD(NVL(l_lor_details.alien_reg_number     ,' '), 9)
              ||RPAD(NVL(l_lor_details.s_default_status   ,' '), 1)
              ||LPAD(NVL(l_lor_details.grade_level_code   ,' '), 1)
              ||LPAD(TO_CHAR(l_lor_details.loan_amt_accepted), 5,0)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_begin_date,'YYYYMMDD'),8)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_end_date  ,'YYYYMMDD'),8)           -- #20
              ||RPAD(NVL(DLDisbDetails(p_dl_version, l_lor_details.award_id),' '), 560) -- #21 to #100
              ||RPAD(p_dl_batch_id,23)                                          -- #101
              ||RPAD(NVL(l_lor_details.pnote_print_ind     ,' '),1)
              ||RPAD(NVL(decode(l_lor_details.unsub_elig_for_depnt,
                                'Y',l_lor_details.unsub_elig_for_depnt,
                                ' '),' '),1)
              ||LPAD(NVL(LTRIM(TO_CHAR(l_lor_details.orig_fee_perct*1000,'00000')),'0'),5)   -- Ltrim() done to remove sign char space
              ||LPAD(' ', 9)
              ||RPAD(' ',12)
              ||RPAD(' ',16)
              ||RPAD(' ', 1)
              ||RPAD(' ', 1)
              ||LPAD(' ', 9)                                                    -- #110
              ||RPAD(' ', 8)
              ||RPAD(' ', 1)
              ||RPAD(NVL(p_school_code,' '),6)
              ||RPAD(' ', 5)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_addr1)||' '||UPPER(student_dtl_rec.p_local_addr2) ,' '),35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_city)   ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_state)  ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_local_zip    ,' '), 9)
              ||RPAD(' ', 32)
              ||RPAD(NVL(l_lor_details.dependency_status ,' '), 1)
              ||RPAD(' ',41)                                                    -- #124 to #143
              ||RPAD(TO_CHAR(l_lor_details.sch_cert_date,'YYYYMMDD'),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_begin_dt,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_end_dt  ,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(decode(l_lor_details.unsub_elig_for_heal,
                                'Y',l_lor_details.unsub_elig_for_heal,
                                ' '),' '),1)
              ||RPAD(NVL(decode(l_lor_details.disclosure_print_ind,
                                'N',' ',
                                l_lor_details.disclosure_print_ind)     ,' '),1)
              ||RPAD(NVL(student_dtl_rec.p_email_addr,' '),50)                            -- #149
              transaction_rec
     FROM    dual;

    ELSIF p_dl_loan_catg = 'DL_PLUS' THEN

      OPEN Orig_Rec FOR
      SELECT  l_lor_details.award_id       award_id,
              l_lor_details.loan_id        loan_id,
              l_lor_details.loan_number    loan_number,
                RPAD(l_lor_details.loan_number,21)                                      -- #1
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(parent_dtl_rec.p_ssn),9)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_first_name),' ')     ,12)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_last_name),' ')      ,16)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_middle_name)   ,' ') ,1)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_addr1)||' '||UPPER(parent_dtl_rec.p_permt_addr2),' ') ,35)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_city),' ')     ,16)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_state),' ')    ,2)                        -- Should be valid 2 digit code
              ||RPAD(NVL(parent_dtl_rec.p_permt_zip,' ')      ,9)
              ||DECODE(igf_sl_gen.get_person_phone(l_lor_details.p_person_id),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(l_lor_details.p_person_id),10,0))                       -- #10 ######## p_phone
              ||RPAD(' ',22)
              ||RPAD(NVL(TO_CHAR(parent_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||LPAD(NVL(parent_dtl_rec.p_citizenship_status,' ')   , 1)
              ||LPAD(NVL(parent_dtl_rec.p_alien_reg_num,' ')  ,9)
              ||RPAD(NVL(l_lor_details.p_default_status,' ') ,1)
              ||LPAD(NVL(l_lor_details.grade_level_code,' ') ,1)
              ||LPAD(TO_CHAR(l_lor_details.loan_amt_accepted), 5,0)                      --Should >0 for anytype of LOAN
              ||RPAD(TO_CHAR(l_lor_details.loan_per_begin_date,'YYYYMMDD')  ,8)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_end_date  ,'YYYYMMDD')  ,8)         -- #20
              ||RPAD(NVL(DLDisbDetails(p_dl_version, l_lor_details.award_id),' '), 560) -- #21 to #100
              ||RPAD(p_dl_batch_id,23)                                          -- #101
              ||RPAD(NVL(l_lor_details.pnote_print_ind                 ,' '), 1)
              ||RPAD(' ', 1)                                                    --unsub_elig_for_depnt is N/A for PLUS
              ||LPAD(NVL(LTRIM(TO_CHAR(l_lor_details.orig_fee_perct*1000,'00000')),'0'),5)   -- Ltrim() done to remove sign char space
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn), 9)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_first_name)                    ,' '),12)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_last_name)                     ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_middle_name)                   ,' '), 1)
              ||RPAD(NVL(l_lor_details.citizenship_status                ,' '), 1)
              ||LPAD(NVL(l_lor_details.alien_reg_number                  ,' '), 9)        -- #110
              ||RPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||RPAD(NVL(l_lor_details.s_default_status                ,' '), 1)
              ||RPAD(NVL(p_school_code                       ,' '), 6)
              ||LPAD(' ', 5)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_addr1)||' '|| UPPER(student_dtl_rec.p_local_addr2),' '),35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_city)                    ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_state)                   ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_local_zip                     ,' '), 9)
              ||RPAD(' ', 32)
              ||RPAD(NVL(l_lor_details.dependency_status ,' '), 1)
              ||RPAD(' ',41)                                                    -- #124 to #143
              ||RPAD(NVL(TO_CHAR(l_lor_details.sch_cert_date,'YYYYMMDD'),' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_begin_dt,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_end_dt  ,'YYYYMMDD')  ,' '),8)
              ||RPAD(' ',1)                                                     -- for plus loans Additional Unsubsidized Health .. is N/A
              ||RPAD(NVL(decode(l_lor_details.disclosure_print_ind,
                                'N',' ',
                                l_lor_details.disclosure_print_ind)     ,' '),1)
              ||RPAD(NVL(student_dtl_rec.p_email_addr,' '),50)                            -- #149
              transaction_rec
      FROM    dual;

    END IF;

  ELSIF p_dl_version IN ('2003-2004','2004-2005') THEN
    IF p_dl_loan_catg = 'DL_STAFFORD' THEN

      OPEN Orig_Rec FOR
      SELECT  l_lor_details.award_id       award_id,
              l_lor_details.loan_id        loan_id,
              l_lor_details.loan_number    loan_number,
                RPAD(l_lor_details.loan_number,21)                                      -- #1
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn),9)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_first_name)       ,' '),12)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_last_name)        ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_middle_name)      ,' '), 1)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_addr1)||' '||UPPER(student_dtl_rec.p_permt_addr2),' ') ,35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_city)       ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_permt_state)      ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_permt_zip        ,' '), 9)
              ||DECODE(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(l_lor_details.base_id)),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(l_lor_details.base_id)),10,0))
              ||RPAD(' ', 22)-- Filler for ED use. Bug # 2758823
              ||RPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||LPAD(' ', 1)
              ||LPAD(NVL(l_lor_details.alien_reg_number     ,' '), 9)
              ||RPAD(NVL(l_lor_details.s_default_status   ,' '), 1)
              ||LPAD(NVL(l_lor_details.grade_level_code   ,' '), 1)
              ||LPAD(TO_CHAR(l_lor_details.loan_amt_accepted), 5,0)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_begin_date,'YYYYMMDD'),8)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_end_date  ,'YYYYMMDD'),8)           -- #20
              ||RPAD(NVL(DLDisbDetails(p_dl_version, l_lor_details.award_id),' '), 560) -- #21 to #100
              ||RPAD(p_dl_batch_id,23)                                          -- #101
              ||RPAD(NVL(l_lor_details.pnote_print_ind,' '),1)
              ||RPAD(NVL(decode(l_lor_details.unsub_elig_for_depnt,
                                'Y',l_lor_details.unsub_elig_for_depnt,
                                ' '),' '),1)
              ||LPAD(NVL(LTRIM(TO_CHAR(l_lor_details.orig_fee_perct*1000,'00000')),'0'),5)   -- Ltrim() done to remove sign char space
              ||LPAD(' ', 9)
              ||RPAD(' ',12)
              ||RPAD(' ',16)
              ||RPAD(' ', 1)
              ||RPAD(' ', 1)
              ||LPAD(' ', 9)                                                    -- #110
              ||RPAD(' ', 8)
              ||RPAD(' ', 1)
              ||RPAD(NVL(p_school_code,' '),6)
              ||RPAD(' ', 5) -- Filler for ED use.
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_addr1)||' '||UPPER(student_dtl_rec.p_local_addr2) ,' '),35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_city)   ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_state)  ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_local_zip    ,' '), 9)
              ||RPAD(' ', 32)
              ||RPAD(NVL(l_lor_details.dependency_status ,' '), 1)
              ||RPAD(' ',41)                                                    -- #124 to #143
              ||RPAD(TO_CHAR(l_lor_details.sch_cert_date,'YYYYMMDD'),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_begin_dt,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_end_dt  ,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(decode(l_lor_details.unsub_elig_for_heal,
                                'Y',l_lor_details.unsub_elig_for_heal,
                                ' '),' '),1)
              ||RPAD(NVL(decode(l_lor_details.disclosure_print_ind,
                                'N',' ',
                                l_lor_details.disclosure_print_ind)     ,' '),1)
              ||RPAD(NVL(student_dtl_rec.p_email_addr,' '),50)                            -- #149
              transaction_rec
      FROM   dual;

    ELSIF p_dl_loan_catg = 'DL_PLUS' THEN

      OPEN Orig_Rec FOR
      SELECT  l_lor_details.award_id       award_id,
              l_lor_details.loan_id        loan_id,
              l_lor_details.loan_number    loan_number,
                RPAD(l_lor_details.loan_number,21)                                      -- #1
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(parent_dtl_rec.p_ssn),9)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_first_name),' ')     ,12)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_last_name),' ')      ,16)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_middle_name)   ,' ') ,1)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_addr1)||' '||UPPER(parent_dtl_rec.p_permt_addr2),' ') ,35)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_city),' ')     ,16)
              ||RPAD(NVL(UPPER(parent_dtl_rec.p_permt_state),' ')    ,2)                        -- Should be valid 2 digit code
              ||RPAD(NVL(parent_dtl_rec.p_permt_zip,' ')      ,9)
              ||DECODE(igf_sl_gen.get_person_phone(l_lor_details.p_person_id),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(l_lor_details.p_person_id),10,0))
              ||RPAD(' ', 22)-- Filler for ED use. Bug # 2758823
              ||RPAD(NVL(TO_CHAR(parent_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||LPAD(NVL(parent_dtl_rec.p_citizenship_status,' ')   , 1)
              ||LPAD(NVL(parent_dtl_rec.p_alien_reg_num,' ')  ,9)
              ||RPAD(NVL(l_lor_details.p_default_status,' ') ,1)
              ||LPAD(NVL(l_lor_details.grade_level_code,' ') ,1)
              ||LPAD(TO_CHAR(l_lor_details.loan_amt_accepted), 5,0)                      --Should >0 for anytype of LOAN
              ||RPAD(TO_CHAR(l_lor_details.loan_per_begin_date,'YYYYMMDD')  ,8)
              ||RPAD(TO_CHAR(l_lor_details.loan_per_end_date  ,'YYYYMMDD')  ,8)         -- #20
              ||RPAD(NVL(DLDisbDetails(p_dl_version, l_lor_details.award_id),' '), 560) -- #21 to #100
              ||RPAD(p_dl_batch_id,23)                                          -- #101
              ||RPAD(NVL(l_lor_details.pnote_print_ind                 ,' '), 1)
              ||RPAD(' ', 1)                                                    --unsub_elig_for_depnt is N/A for PLUS
              ||LPAD(NVL(LTRIM(TO_CHAR(l_lor_details.orig_fee_perct*1000,'00000')),'0'),5)   -- Ltrim() done to remove sign char space
              ||LPAD(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn), 9)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_first_name)                    ,' '),12)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_last_name)                     ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_middle_name)                   ,' '), 1)
              ||RPAD(NVL(l_lor_details.citizenship_status                ,' '), 1)
              ||LPAD(NVL(l_lor_details.alien_reg_number                  ,' '), 9)        -- #110
              ||RPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),' '),8)
              ||RPAD(NVL(l_lor_details.s_default_status                ,' '), 1)
              ||RPAD(NVL(p_school_code                       ,' '), 6)
              ||RPAD(' ', 5) -- Filler for ED use
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_addr1)||' '|| UPPER(student_dtl_rec.p_local_addr2),' '),35)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_city)                    ,' '),16)
              ||RPAD(NVL(UPPER(student_dtl_rec.p_local_state)                   ,' '), 2)
              ||RPAD(NVL(student_dtl_rec.p_local_zip                     ,' '), 9)
              ||RPAD(' ', 32)
              ||RPAD(NVL(l_lor_details.dependency_status ,' '), 1)
              ||RPAD(' ',41)                                                    -- #124 to #143
              ||RPAD(NVL(TO_CHAR(l_lor_details.sch_cert_date,'YYYYMMDD'),' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_begin_dt,'YYYYMMDD')  ,' '),8)
              ||RPAD(NVL(TO_CHAR(lv_acad_end_dt  ,'YYYYMMDD')  ,' '),8)
              ||RPAD(' ',1)                                                     -- for plus loans Additional Unsubsidized Health .. is N/A
              ||RPAD(NVL(decode(l_lor_details.disclosure_print_ind,
                                'N',' ',
                                l_lor_details.disclosure_print_ind)     ,' '),1)
              ||RPAD(NVL(student_dtl_rec.p_email_addr,' '),50)                            -- #149
              transaction_rec
      FROM   dual;
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_dl_record.DLOrig_cur.exception',SQLERRM);
    END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_record.DLOrig_cur');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END DLOrig_cur;


END igf_sl_dl_record;

/
