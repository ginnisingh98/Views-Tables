--------------------------------------------------------
--  DDL for Package Body IGF_GR_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_GEN" AS
/* $Header: IGFGR08B.pls 120.3 2006/04/06 06:11:10 veramach ship $ */

-----------------------------------------------------------------------------------
-- Who        When           What
------------------------------------------------------------------------
--  cdcruz      28-Oct-2004   FA152 Auto Re-pkg Build
--                            Modified the call to igf_aw_packng_subfns.get_fed_efc()
--			      as part of dependency.
------------------------------------------------------------------------
--ayedubat    13-OCT-04       FA 149 COD-XML Standards build bug # 3416863
--                            Changed the TBH calls of the packages: igf_gr_rfms_pkg
-- veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
-----------------------------------------------------------------------------------
-- veramach   10-Dec-2003    FA 131 COD Updates
--                           Removed function get_rep_pell_id
-----------------------------------------------------------------------------------
-- ugummall   03-NOV-2003    Bug 3102439. FA 126 - Multiple FA Offices.
--                           1. Added two extra parameters p_ci_cal_type and p_ci_sequence_number
--                              to get_pell_header
--                           2. Removed cursor c_ope_id and added cur_get_ope_id to get ope id
--                              from igf_gr_report_pell table rather igf_ap_fa_setup table.
-----------------------------------------------------------------------------------
-- sjadhav    26-Jun-2003    Bug 2938258
--                           Pell and Disb records batch id (rfmb_id) set to NULL
--                           when record moved to ready to send status
-----------------------------------------------------------------------------------
--bkkumar     24-jun-2003    Bug #2974248 Added the code for proceeding in case of
--                           warning codes.
-----------------------------------------------------------------------------------
--rasahoo     13-May-2003    Bug #2938258 Added code for Resetting Origination Status
--                           to "Ready to Send" for the rejected Pell Disbursement Records.
------------------------------------------------------------------------------------
-- gmuralid   10-Apr-2003    Bug 2744419
--                           Modified function get_calendar_desc to
--                           return alternate code if description
--                           is null.
-----------------------------------------------------------------------------------
-- gmuralid   10-Apr-2003    Bug 2744419
--                           Added Function get_calendar_desc to get
--                           the calendar description.
-----------------------------------------------------------------------------------
-- sjadhav    01-Apr-2003    Bug 2875503
--                           Changed in parameter for get_ssn_digits
-----------------------------------------------------------------------------------
-- gmuralid   27-03-2003     BUG 2863929 - OPE ID poulated in pell header record
-----------------------------------------------------------------------------------
-- sjadhav    03-Mar-2003    Bug 2781382
--                           Return NULL if efc is null in get_pell_efc
-----------------------------------------------------------------------------------
-- sjadhav    05-Feb-2003    FA116 Build - Bug 2758812 - 2/4/03
--                           Added update_current_ssn,update_pell_status,
--                           match_file_version,get_min_disb_number
-----------------------------------------------------------------------------------
-- sjadhav    Nov,18,2002.   Bug 2590991
--                           Routine to fetch base id
-----------------------------------------------------------------------------------
-- sjadhav    Oct.25.2002    Bug 2613546,2606001
--                           get_tufees_code,get_def_awd_year,ovrd_coa_exist,
--                           delete_coa,update_item_dist,insert_coa_items,
--                           insert_coa_terms,get_pell_code,insert_stu_coa_terms,
--                           delete_stu_coa_terms,delete_stu_coa_items,
--                           update_stu_coa_items routines added
-----------------------------------------------------------------------------------
-- sjadhav    Oct.10.2002    Bug 2383690
--                           1. Added send_orig_disb
--                           2. Added get_min_pell_disb
--                           3. Added get_min_awd_disb
--
-- nsidana    10/31/2003     Multiple FA offices.
--                           Added 3 new functions to derive the reporting pell ID
--                           for a student.
-----------------------------------------------------------------------------------
--
-- sjadhav
-- This is a generic Utility Package aimed at centralization of
-- common functions/procedures
--
-- This package contains
-- 1. get_rep_pell_id
-- 2. get_pell_header
-- 3. get_pell_trailer
-- 4. process_pell_ack
-- routines which are very specific to Pell Subsytem
--
-- Other routines are general
--
-----------------------------------------------------------------------------------




g_batch_dt     VARCHAR2(20);

FUNCTION chk_orig_isir_exists( p_base_id           IN igf_ap_fa_base_rec.base_id%TYPE,
                               p_transaction_num   IN igf_ap_ISIR_matched.transaction_num%TYPE)
RETURN BOOLEAN
AS
--------------------------------------------------------------------------------------------------------
--   Created By         :       rasahoo
--   Date Created By    :       Sep 26, 2003
--   Purpose            :       check if an RFMS origination record exists for the context Base ID
--                              that does not use  Passed ISIR transaction number as the Payment ISIR
--Change History:
--Who                When                  What
--
----------------------------------------------------------------------------------------------------------
  -- retrieves  records for which RFMS Originations exists in status Accepted or Sent, with a different Transaction Number
  CURSOR chk_ex_orig_rec (cp_base_id           igf_ap_fa_base_rec.base_id%TYPE,
                          cp_transaction_num   igf_ap_ISIR_matched.transaction_num%TYPE)
  IS
    SELECT 'X'
      FROM  igf_gr_rfms rfms
     WHERE  rfms.base_id = cp_base_id
       AND  rfms.orig_action_code in ('A','S')
       AND  rfms.transaction_num <> cp_transaction_num ;

      l_chk_ex_orig_rec  chk_ex_orig_rec%ROWTYPE;

BEGIN

     OPEN chk_ex_orig_rec(p_base_id,p_transaction_num);
    FETCH chk_ex_orig_rec INTO l_chk_ex_orig_rec;
    IF chk_ex_orig_rec%FOUND THEN
       CLOSE chk_ex_orig_rec;
       RETURN TRUE;
    ELSE
       CLOSE chk_ex_orig_rec;
       RETURN FALSE;
    END IF;
END chk_orig_isir_exists;

FUNCTION get_cycle_year (p_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE,
                         p_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--Change History:
--Bug No:-2460904 Desc :- Pell Formatting Issues
--Who                When                  What
--mesriniv           22-jul-2002           Cycle Year should be 4 chars starting from 6th char in File Version.
--                                         Eg If File Version is 2002-2003 then cycle year is 2003
--                                         Cursor used to pick the year part of end date from Cal Instance for award year
--                                         may not always return the ending year.
--                                         Removed cursor which picks the year part of end date from IGS_CA_INST for the calendar instance.

l_ver_num      VARCHAR2(30);  -- Flat File Version Number
l_cycle_year   VARCHAR2(4);

BEGIN

-- Get the Flat File Version and then Proceed
--
        l_ver_num  := igf_aw_gen.get_ver_num(p_ci_cal_type,p_ci_sequence_number,'P');
        IF  l_ver_num IS NOT NULL THEN
            l_cycle_year:=SUBSTR(l_ver_num,6,4);
        END IF;


        RETURN l_cycle_year;

END get_cycle_year;


FUNCTION disb_has_adj ( p_award_id  igf_aw_award_all.award_id%TYPE,
                        p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
RETURN BOOLEAN
IS

--------------------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------------------

        CURSOR cur_get_adj ( p_award_id  igf_aw_award_all.award_id%TYPE,
                             p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
        IS
        SELECT
        COUNT (disb_num)
        FROM
        igf_db_awd_disb_dtl
        WHERE
        p_award_id = award_id AND
        p_disb_num = disb_num;

        ln_rec_count NUMBER;

BEGIN

       OPEN   cur_get_adj(p_award_id,p_disb_num);
       FETCH  cur_get_adj INTO ln_rec_count;
       CLOSE  cur_get_adj;

       IF ln_rec_count > 0 THEN
           RETURN TRUE;
       ELSE
           RETURN FALSE;
       END IF;


END disb_has_adj;


FUNCTION get_alt_code ( p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                        p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns alternate code of calendar
--
--------------------------------------------------------------------------------------------

        CURSOR cur_alt_code ( p_ci_cal_type          igs_ca_inst_all.cal_type%TYPE,
                              p_ci_sequence_number   igs_ca_inst_all.sequence_number%TYPE)

        IS
        SELECT
        alternate_code
        FROM
        igs_ca_inst
        WHERE
        cal_type        = p_ci_cal_type AND
        sequence_number = p_ci_sequence_number;

        alt_code_rec    cur_alt_code%ROWTYPE;

BEGIN

        OPEN  cur_alt_code(p_ci_cal_type,p_ci_sequence_number);
        FETCH cur_alt_code INTO alt_code_rec;

        IF    cur_alt_code%NOTFOUND THEN
              CLOSE cur_alt_code;
              RETURN NULL;
        ELSE
              CLOSE cur_alt_code;
              RETURN alt_code_rec.alternate_code;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_ALT_CODE'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


END get_alt_code;

FUNCTION get_calendar_desc ( p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                             p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       gmuralid
--   Date Created By    :       Apr 10, 2003
--   Purpose            :       Returns calendar description.
--
--------------------------------------------------------------------------------------------

        CURSOR cur_cal_desc ( p_ci_cal_type          igs_ca_inst_all.cal_type%TYPE,
                              p_ci_sequence_number   igs_ca_inst_all.sequence_number%TYPE)

        IS
        SELECT
        description,
        alternate_code
        FROM
        igs_ca_inst
        WHERE
        cal_type        = p_ci_cal_type AND
        sequence_number = p_ci_sequence_number;

        cal_rec    cur_cal_desc%ROWTYPE;

BEGIN

        OPEN  cur_cal_desc(p_ci_cal_type,p_ci_sequence_number);
        FETCH cur_cal_desc INTO cal_rec;

        IF    cur_cal_desc%NOTFOUND THEN
              CLOSE cur_cal_desc;
              RETURN NULL;
        ELSE
              CLOSE cur_cal_desc;
              RETURN NVL(cal_rec.description,cal_rec.alternate_code);
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_CALENDAR_DESC'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


END get_calendar_desc;

FUNCTION get_per_num ( p_base_id   IN  igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns person number for the Base id passed
--
--------------------------------------------------------------------------------------------

        CURSOR cur_fa_pers (  p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE)
        IS
        SELECT person_number
        FROM   igs_pe_person_base_v
        WHERE  person_id =
               (
                 SELECT person_id
                 FROM
                 igf_ap_fa_base_rec
                 WHERE
                 base_id  = p_base_id
               );

        fa_pers_rec   cur_fa_pers%ROWTYPE;

BEGIN

        OPEN  cur_fa_pers(p_base_id);
        FETCH cur_fa_pers  INTO fa_pers_rec;

        IF    cur_fa_pers%NOTFOUND THEN
              CLOSE cur_fa_pers;
              RETURN NULL;
        ELSE
              CLOSE cur_fa_pers;
              RETURN fa_pers_rec.person_number;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_PER_NUM'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_per_num;



FUNCTION get_per_num ( p_person_id       IN   igf_ap_fa_base_rec_all.person_id%TYPE,
                       p_person_number   OUT NOCOPY  igf_ap_person_v.person_number%TYPE )
RETURN BOOLEAN
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns person number for the person id passed in
--                              financial aid
--
--------------------------------------------------------------------------------------------

        CURSOR cur_fa_pers ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT person_number
        FROM   igf_ap_person_v
        WHERE
        person_id  = p_person_id;

        fa_pers_rec   cur_fa_pers%ROWTYPE;

BEGIN

        OPEN  cur_fa_pers(p_person_id);
        FETCH cur_fa_pers  INTO fa_pers_rec;

        IF    cur_fa_pers%NOTFOUND THEN
              CLOSE cur_fa_pers;
              RETURN FALSE;
        ELSE
              CLOSE cur_fa_pers;
              p_person_number := fa_pers_rec.person_number;
              RETURN TRUE;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_PER_NUM'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_per_num;


FUNCTION get_person_id ( p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns Person ID for the Base id passed
--
--------------------------------------------------------------------------------------------

        CURSOR cur_fa_pers (  p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE)
        IS
        SELECT person_id
        FROM   igf_ap_fa_base_rec
        WHERE
        base_id  = p_base_id;

        fa_pers_rec   cur_fa_pers%ROWTYPE;

BEGIN

        OPEN  cur_fa_pers(p_base_id);
        FETCH cur_fa_pers  INTO fa_pers_rec;

        IF    cur_fa_pers%NOTFOUND THEN
              CLOSE cur_fa_pers;
              RETURN NULL;
        ELSE
              CLOSE cur_fa_pers;
              RETURN fa_pers_rec.person_id;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_PER_ID'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_person_id;


FUNCTION get_per_num_oss ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns person number for the Base id passed
--
--------------------------------------------------------------------------------------------

        CURSOR cur_fa_pers (  p_person_id igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT person_number
        FROM   igs_pe_person_base_v
        WHERE
        person_id = p_person_id;

        fa_pers_rec   cur_fa_pers%ROWTYPE;

BEGIN

        OPEN  cur_fa_pers(p_person_id);
        FETCH cur_fa_pers  INTO fa_pers_rec;

        IF    cur_fa_pers%NOTFOUND THEN
              CLOSE cur_fa_pers;
              RETURN NULL;
        ELSE
              CLOSE cur_fa_pers;
              RETURN fa_pers_rec.person_number;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_GEN.GET_PER_NUM_OSS'|| ' ' || SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_per_num_oss;


PROCEDURE insert_sys_holds ( p_award_id  igf_aw_award_all.award_id%TYPE,
                             p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE,
                             p_hold      igf_db_disb_holds_all.hold%TYPE)
IS
--------------------------------------------------------------------------------------------
--
-- sjadhav, 15Feb2002
--
-- This procedure puts hold on Planned Disbursements
-- This process can be modified to insert holds on Actual Disbursements as well
--
--------------------------------------------------------------------------------------------

        CURSOR cur_get_adisb (  p_award_id  igf_aw_award_all.award_id%TYPE,
                                p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
        IS
        SELECT
        awd.award_id,awd.disb_num
        FROM
        igf_aw_awd_disb awd
        WHERE
        awd.award_id   = p_award_id                   AND
        awd.disb_num   = NVL(p_disb_num,awd.disb_num) AND
        awd.trans_type = 'P';

        awd_rec     cur_get_adisb%ROWTYPE;
        holds_rec   igf_db_disb_holds_all%ROWTYPE;

        lv_rowid    ROWID;

        CURSOR cur_chk_holds (  p_award_id  igf_aw_awd_disb_all.award_id%TYPE,
                                p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE,
                                p_hold      igf_db_disb_holds_all.hold%TYPE)
        IS
        SELECT COUNT(hold_id) cnt
        FROM
        igf_db_disb_holds
        WHERE
        award_id  = p_award_id      AND
        disb_num  = p_disb_num      AND
        NVL(release_flag,'N') = 'N' AND
        hold      = p_hold;

        chk_holds_rec   cur_chk_holds%ROWTYPE;

        l_app  VARCHAR2(50);
        l_name VARCHAR2(30);

BEGIN

   lv_rowid   := NULL;

   FOR awd_rec IN cur_get_adisb (p_award_id,p_disb_num)

   LOOP
        OPEN  cur_chk_holds(awd_rec.award_id,awd_rec.disb_num,p_hold);
        FETCH cur_chk_holds INTO chk_holds_rec;
        CLOSE cur_chk_holds;

        IF  NVL(chk_holds_rec.cnt,0) = 0 THEN
                igf_db_disb_holds_pkg.insert_row(x_rowid            =>  lv_rowid,
                                                 x_hold_id          =>  holds_rec.hold_id,
                                                 x_award_id         =>  awd_rec.award_id,
                                                 x_disb_num         =>  awd_rec.disb_num,
                                                 x_hold             =>  p_hold,
                                                 x_hold_date        =>  TRUNC(SYSDATE),
                                                 x_hold_type        =>  'SYSTEM',
                                                 x_release_date     =>  NULL,
                                                 x_release_flag     =>  'N',
                                                 x_release_reason   =>  NULL,
                                                 x_mode             =>  'R');

        END IF;

   END LOOP;

   EXCEPTION

   WHEN OTHERS THEN
   --
   -- This will ensure exception raised from the isnert hold tbh
   -- are is not thrown
   --
   fnd_message.parse_encoded(fnd_message.get_encoded, l_app, l_name);
   IF l_name = 'IGF_DB_HOLD_EXISTS' THEN
      NULL;
   ELSE
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_GEN.INSERT_SYS_HOLDS'|| ' ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

END insert_sys_holds;


----------------------------------------------------------------------------------------
-- Pell Routines
----------------------------------------------------------------------------------------

FUNCTION get_pell_efc ( p_base_id   IN   igf_aw_award_all.base_id%TYPE)
RETURN NUMBER
IS

  ln_pell_efc NUMBER;
  ln_efc      NUMBER;

BEGIN


      igf_aw_packng_subfns.get_fed_efc(
                                       l_base_id      => p_base_id,
                                       l_awd_prd_code => NULL,
                                       l_efc_f        => ln_efc,
                                       l_pell_efc     => ln_pell_efc,
                                       l_efc_ay       => ln_efc
                                       );


   RETURN ln_pell_efc;

END get_pell_efc;

FUNCTION get_pell_header (p_ver_num        IN   VARCHAR2,
                          p_cycle_year     IN   VARCHAR2,
                          p_rep_pell_id    IN   igf_gr_pell_setup_all.rep_pell_id%TYPE,
                          p_batch_type     IN   VARCHAR2,
                          p_rfmb_id        OUT NOCOPY  igf_gr_rfms_batch.rfmb_id%TYPE,
                          p_batch_id       OUT NOCOPY  VARCHAR2,
                          p_ci_cal_type    IN VARCHAR2,
                          p_ci_sequence_number IN NUMBER)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------------------

   l_header        VARCHAR2(1000);
   l_rowid         VARCHAR2(30);
   ln_data_rec_len NUMBER;

   -- Modified this cursor c_ope_id to get ope id from igf_gr_report_pell
   -- table instead of igf_ap_fa_setup w.r.t FA 126
   CURSOR cur_get_ope_id( cp_ci_cal_type    igf_gr_report_pell.ci_cal_type%TYPE,
                    cp_ci_seq_num     igf_gr_report_pell.ci_sequence_number%TYPE,
                    cp_rep_pell_id    igf_gr_report_pell.reporting_pell_cd%TYPE
                   )
   IS
   SELECT ope_cd
     FROM igf_gr_report_pell rpell
    WHERE rpell.ci_cal_type         = cp_ci_cal_type
      AND rpell.ci_sequence_number  = cp_ci_seq_num
      AND rpell.reporting_pell_cd   = cp_rep_pell_id;

    get_ope_id_rec    cur_get_ope_id%ROWTYPE;

BEGIN


        IF p_ver_num IN ('2002-2003','2003-2004','2004-2005','2005-2006') THEN

            g_batch_dt := TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');
            p_batch_id :=  p_batch_type                     ||  -- This indicates Origination
                           p_cycle_year                     ||            -- This is cycle Year ..
                           RPAD(NVL(p_rep_pell_id,' '),6)   ||
                           g_batch_dt;
            IF    p_batch_type = '#O' THEN
                  ln_data_rec_len := 300;
            ELSIF p_batch_type = '#D' THEN
                  ln_data_rec_len := 100;
            END IF;

            -- Get OPE ID.
            OPEN cur_get_ope_id(p_ci_cal_type, p_ci_sequence_number,  p_rep_pell_id);
            FETCH cur_get_ope_id INTO get_ope_id_rec;
            CLOSE cur_get_ope_id;

            l_header   :=  NULL;
            l_header   :=  RPAD('GRANT HDR',10)        ||
                           LPAD(ln_data_rec_len,4,'0') ||
                           RPAD(NVL(p_batch_id,' '),26)||
                           RPAD(NVL(get_ope_id_rec.ope_cd,' '),8)                 ||          -- OPE ID
                           RPAD('IGS1157',10)          ||                -- Software Provider
                           RPAD(' ',5)                 ||                -- Unused
                           RPAD(' ',5)                 ||                -- ED Use Only
                           RPAD(' ',8)                 ||                -- Process Date by Put in by RFMS
                           RPAD(' ',24);                                 -- Batch Reject Reasons

            --
            -- Header Record Length=100, this is same length as that of data record
            --

            --
            -- Insert Batch ID of this batch into igf_gr_Rfms_batch table
            --


            l_rowid := NULL;

            igf_gr_rfms_batch_pkg.insert_row (
              x_rowid                             => l_rowid,
              x_rfmb_id                           => p_rfmb_id,
              x_batch_id                          => p_batch_id,
              x_data_rec_length                   => ln_data_rec_len,
              x_ope_id                            => NULL,
              x_software_providor                 => NULL,
              x_rfms_process_dt                   => TRUNC(SYSDATE),
              x_rfms_ack_dt                       => NULL,
              x_rfms_ack_batch_id                 => NULL,
              x_reject_reason                     => NULL,
              x_mode                              => 'R');

              RETURN l_header;

        ELSE
            RAISE no_file_version;
        END IF;


        EXCEPTION

          WHEN no_file_version THEN
               RAISE;

          WHEN OTHERS THEN
          fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGF_GR_GEN.PREPARE_HEADER'|| ' ' || SQLERRM);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;


END get_pell_header;


FUNCTION get_pell_trailer (p_ver_num        IN  VARCHAR2,
                           p_cycle_year     IN  VARCHAR2,
                           p_rep_pell_id    IN  igf_gr_pell_setup_all.rep_pell_id%TYPE,
                           p_batch_type     IN  VARCHAR2,
                           p_num_of_rec     IN  NUMBER,
                           p_amount_total   IN  NUMBER,
                           p_batch_id       OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--------------------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------------------

   l_trailer        VARCHAR2(1000);
   l_sign_ind       VARCHAR2(10);
   ln_data_rec_len  NUMBER;

BEGIN

        IF p_ver_num IN ('2002-2003','2003-2004','2004-2005','2005-2006') THEN

           p_batch_id :=   p_batch_type                     ||  -- This indicates Origination
                           RPAD(NVL(p_cycle_year,' '),4)    ||  -- This is cycle Year ..
                           RPAD(NVL(p_rep_pell_id,' '),6)   ||
                           g_batch_dt;

            IF NVL(p_amount_total,0) >= 0 THEN
               l_sign_ind := 'P';
            ELSE
               l_sign_ind := 'N';
            END IF;

            l_trailer  :=  NULL;

            IF    p_batch_type = '#O' THEN
                  ln_data_rec_len := 300;
            ELSIF p_batch_type = '#D' THEN
                  ln_data_rec_len := 100;
            END IF;

            l_trailer  :=  RPAD('GRANT TLR',10)              ||
                           LPAD(ln_data_rec_len,4,'0')       ||
                           RPAD(NVL(p_batch_id,' '),26)      ||
                           LPAD(NVL(p_num_of_rec,0),6,'0')   ||
                           LPAD(TO_CHAR(ABS(NVL(100*p_amount_total,0))),11,'0') ||
                           RPAD(NVL(l_sign_ind,' '),1)       ||
                           RPAD(' ',6)                       ||       --  updated by RFMS
                           RPAD(' ',11)                      ||       --  updated by RFMS
                           RPAD(' ',1)                       ||       --  Accepted and corrected sign indicator
                           RPAD(' ',6)                       ||       --  Number of Duplicate Records, updated by RFMS
                           RPAD(' ',18);                              -- updated by RFMS

            RETURN l_trailer;

        ELSE
            RAISE no_file_version;
        END IF;


        EXCEPTION

         WHEN no_file_version THEN
               RAISE;

        WHEN OTHERS THEN
          fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGF_GR_GEN.PREPARE_TRAILER'|| ' ' || SQLERRM);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;

END get_pell_trailer;


PROCEDURE process_pell_ack ( p_ver_num              IN   VARCHAR2,
                             p_file_type            IN   VARCHAR2,
                             p_number_rec           OUT NOCOPY  NUMBER,
                             p_last_gldr_id         OUT NOCOPY  NUMBER,
                             p_batch_id             OUT NOCOPY  VARCHAR2)
IS

----------------------------------------------------------------------------------------------
--
--Change History:
--Bug No:-2460904 Desc :- Pell Formatting Issues
--Who                When                  What
--rasahoo           13-May-2003            Bug #2938258 Added code for Resetting Origination Status
--                                         to "Ready to Send" for the rejected Pell Disbursement Records.
--bkkumar           24-jun-2003            Bug #2974248 Added the code for proceeding in case of
--                                         warning codes.
--------------------------------------------------------------------------------------------



        CURSOR cur_header (p_file_type VARCHAR2)
        IS
        SELECT
        record_data
        FROM
        igf_gr_load_file_t
        WHERE   gldr_id    = 1
        AND     record_data LIKE 'GRANT HDR%'
        AND     file_type   =  p_file_type;

        header_rec     cur_header%ROWTYPE;

        CURSOR cur_trailer (p_file_type VARCHAR2)
        IS
        SELECT
        gldr_id last_gldr_id,
        record_data
        FROM
        igf_gr_load_file_t
        WHERE
        gldr_id       = (SELECT MAX(gldr_id) FROM igf_gr_load_file_t) AND
        record_data LIKE 'GRANT TLR%' AND
        file_type     = p_file_type;

        trailer_rec    cur_trailer%ROWTYPE;

        CURSOR cur_rfms_batch  ( p_batch_id   igf_gr_rfms_batch_all.batch_id%TYPE)
        IS
        SELECT *
        FROM
        igf_gr_rfms_batch
        WHERE
        batch_id = p_batch_id
        FOR UPDATE OF rfms_ack_dt NOWAIT;

        rfms_batch_rec cur_rfms_batch%ROWTYPE;




        CURSOR cur_gr_rfms(p_rfmb_id  igf_gr_rfms.rfmb_id%TYPE)
        IS
        SELECT
        *
        FROM
        igf_gr_rfms
        WHERE
        rfmb_id = p_rfmb_id AND
        orig_action_code = 'S';

        cur_get_rfms   cur_gr_rfms%ROWTYPE;

        CURSOR cur_gr_rfms_disb(p_rfmb_id   igf_gr_rfms_disb.rfmb_id%TYPE)
        IS
        SELECT
        *
        FROM
        igf_gr_rfms_disb
        WHERE
        rfmb_id = p_rfmb_id AND
        disb_ack_act_status = 'S';

         cur_get_rfms_disb cur_gr_rfms_disb%ROWTYPE;
         l_file_name           VARCHAR2(100);
         l_rfms_process_dt     VARCHAR2(200);
         l_batch_rej_reason    VARCHAR2(300);
         l_rowid               VARCHAR2(25);
         l_count               NUMBER;
         l_error_code          igf_gr_rfms_error.edit_code%TYPE;
         lb_error_cd           BOOLEAN := FALSE;
         l_rfmb_id         igf_gr_rfms.rfmb_id%TYPE;
         l_disb_rfmb_id    igf_gr_rfms_disb.rfmb_id%TYPE;

BEGIN

   l_count               := 1;

   IF  p_ver_num IN ('2002-2003','2003-2004','2004-2005','2005-2006','2006-2007') THEN

       OPEN  cur_header (p_file_type);
       FETCH cur_header INTO header_rec;

       IF cur_header%NOTFOUND THEN
           CLOSE cur_header;
           fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
           -- File uploaded is incomplete.
           igs_ge_msg_stack.add;
           RAISE file_not_loaded;
       END IF;
       CLOSE cur_header;

       BEGIN
               l_file_name          := LTRIM(RTRIM(SUBSTR(header_rec.record_data,1,10)));
               p_batch_id           := LTRIM(RTRIM(SUBSTR(header_rec.record_data,15,26)));
               l_rfms_process_dt    := LTRIM(RTRIM(SUBSTR(header_rec.record_data,69,8)));
               l_batch_rej_reason   := NVL(LTRIM(RTRIM(SUBSTR(header_rec.record_data,77,24))),0);
        --
        -- This will make sure process does not bomb if the data is corrupt
        --
               EXCEPTION
               WHEN OTHERS THEN
               RAISE corrupt_data_file;
        END;

       IF LTRIM(RTRIM(l_file_name)) = 'GRANT HDR' THEN -- Remove LIKE, put =

        --
        -- Update the igf_gr_rfms_batch table to reflect new values
        -- This is done only for #O and #D Files
        --
           IF p_file_type IN ('GR_RFMS_ORIG','GR_RFMS_DISB_ORIG') THEN
                   OPEN  cur_rfms_batch(p_batch_id);
                   FETCH cur_rfms_batch  INTO rfms_batch_rec;
                   IF cur_rfms_batch%NOTFOUND THEN
                           CLOSE cur_rfms_batch;
                           RAISE batch_not_in_system;
                   END IF;

                   igf_gr_rfms_batch_pkg.update_row (
                              x_rowid                             => rfms_batch_rec.row_id,
                              x_rfmb_id                           => rfms_batch_rec.rfmb_id,
                              x_batch_id                          => rfms_batch_rec.batch_id,
                              x_data_rec_length                   => rfms_batch_rec.data_rec_length,
                              x_ope_id                            => rfms_batch_rec.ope_id,
                              x_software_providor                 => rfms_batch_rec.software_providor,
                              x_rfms_process_dt                   => fnd_date.string_to_date(l_rfms_process_dt,'YYYYMMDD'),
                              x_rfms_ack_dt                       => TRUNC(SYSDATE),
                              x_rfms_ack_batch_id                 => p_batch_id,
                              x_reject_reason                     => l_batch_rej_reason,
                              x_mode                              => 'R' );



                   CLOSE cur_rfms_batch;
           END IF;

           IF TO_NUMBER(l_batch_rej_reason) > 0 THEN

                p_number_rec := 0;
                fnd_file.new_line(fnd_file.log,1);
                fnd_message.set_name('IGF','IGF_GR_BATCH_REJ');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                fnd_file.new_line(fnd_file.log,1);

                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BATCH_ID') ||'  ' || p_batch_id);
                fnd_file.put_line(fnd_file.log,RPAD('-',35,'-'));
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','EDIT_CODE') || '          ' || igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','TYPE'));
                fnd_file.put_line(fnd_file.log,RPAD('-',35,'-'));

                BEGIN
                        FOR l_cn IN 1 .. 8
                        LOOP

                           l_error_code :=  NVL(SUBSTR(l_batch_rej_reason,l_count,3),'000');

                           IF NVL(l_error_code,'*') <> '000' THEN
                              IF l_error_code NOT IN ('216','218','219','220','222','235','239','240') THEN
                                 fnd_file.put_line(fnd_file.log,RPAD(l_error_code,10) || '          ' || igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ERROR'));
                                 IF NOT lb_error_cd THEN
                                    lb_error_cd := TRUE;
                                 END IF;
                              ELSE
                                fnd_file.put_line(fnd_file.log,RPAD(l_error_code,10) || '          ' || igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','WARN'));
                              END IF;
                           END IF;
                           l_count      :=  l_count + 3;
                        END LOOP;

                        EXCEPTION
                        WHEN OTHERS THEN
                        NULL;

                END;
                fnd_file.new_line(fnd_file.log,1);

      ----Bug #2974248
              IF lb_error_cd THEN
       ----Bug #2938258
                  IF p_file_type = 'GR_RFMS_ORIG'  THEN

                    fnd_message.set_name('IGF','IGF_GR_RESET_REJ_ORIG_BTCH_REC');
                    fnd_message.set_token('BATCH_ID',p_batch_id);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_file.new_line(fnd_file.log,1);

                    l_rfmb_id:=rfms_batch_rec.rfmb_id;


                   FOR cur_get_rfms IN  cur_gr_rfms(l_rfmb_id)
                   LOOP
                       fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID') ||' : ' || cur_get_rfms.origination_id);

                       igf_gr_rfms_pkg.update_row(
                                 x_rowid                             => cur_get_rfms.row_id,
                                 x_origination_id                    => cur_get_rfms.origination_id,
                                 x_ci_cal_type                       => cur_get_rfms.ci_cal_type,
                                 x_ci_sequence_number                => cur_get_rfms.ci_sequence_number,
                                 x_base_id                           => cur_get_rfms.base_id,
                                 x_award_id                          => cur_get_rfms.award_id,
                                 x_rfmb_id                           => NULL,
                                 x_sys_orig_ssn                      => cur_get_rfms.sys_orig_ssn,
                                 x_sys_orig_name_cd                  => cur_get_rfms.sys_orig_name_cd,
                                 x_transaction_num                   => cur_get_rfms.transaction_num,
                                 x_efc                               => igf_gr_gen.get_pell_efc(cur_get_rfms.base_id),
                                 x_ver_status_code                   => cur_get_rfms.ver_status_code,
                                 x_secondary_efc                     => cur_get_rfms.secondary_efc,
                                 x_secondary_efc_cd                  => igf_gr_gen.get_pell_efc_code(cur_get_rfms.base_id),
                                 x_pell_amount                       => cur_get_rfms.pell_amount,
                                 x_pell_profile                      => cur_get_rfms.pell_profile,
                                 x_enrollment_status                 => cur_get_rfms.enrollment_status,
                                 x_enrollment_dt                     => cur_get_rfms.enrollment_dt,
                                 x_coa_amount                        => cur_get_rfms.coa_amount,
                                 x_academic_calendar                 => cur_get_rfms.academic_calendar,
                                 x_payment_method                    => cur_get_rfms.payment_method,
                                 x_total_pymt_prds                   => cur_get_rfms.total_pymt_prds,
                                 x_incrcd_fed_pell_rcp_cd            => cur_get_rfms.incrcd_fed_pell_rcp_cd,
                                 x_attending_campus_id               => cur_get_rfms.attending_campus_id,
                                 x_est_disb_dt1                      => cur_get_rfms.est_disb_dt1,
                                 x_orig_action_code                  => 'R',
                                 x_orig_status_dt                    => cur_get_rfms.orig_status_dt,
                                 x_orig_ed_use_flags                 => cur_get_rfms.orig_ed_use_flags,
                                 x_ft_pell_amount                    => cur_get_rfms.ft_pell_amount,
                                 x_prev_accpt_efc                    => cur_get_rfms.prev_accpt_efc,
                                 x_prev_accpt_tran_no                => cur_get_rfms.prev_accpt_tran_no,
                                 x_prev_accpt_sec_efc_cd             => cur_get_rfms.prev_accpt_sec_efc_cd,
                                 x_prev_accpt_coa                    => cur_get_rfms.prev_accpt_coa,
                                 x_orig_reject_code                  => cur_get_rfms.orig_reject_code,
                                 x_wk_inst_time_calc_pymt            => cur_get_rfms.wk_inst_time_calc_pymt,
                                 x_wk_int_time_prg_def_yr            => cur_get_rfms.wk_int_time_prg_def_yr,
                                 x_cr_clk_hrs_prds_sch_yr            => cur_get_rfms.cr_clk_hrs_prds_sch_yr,
                                 x_cr_clk_hrs_acad_yr                => cur_get_rfms.cr_clk_hrs_acad_yr,
                                 x_inst_cross_ref_cd                 => cur_get_rfms.inst_cross_ref_cd,
                                 x_low_tution_fee                    => cur_get_rfms.low_tution_fee,
                                 x_rec_source                        => cur_get_rfms.rec_source,
                                 x_pending_amount                    => cur_get_rfms.pending_amount,
                                 x_mode                              => 'R',
                                 x_birth_dt                          => cur_get_rfms.birth_dt,
                                 x_last_name                         => cur_get_rfms.last_name,
                                 x_first_name                        => cur_get_rfms.first_name,
                                 x_middle_name                       => cur_get_rfms.middle_name,
                                 x_current_ssn                       => cur_get_rfms.current_ssn,
                                 x_legacy_record_flag                => NULL,
                                 x_reporting_pell_cd                 => cur_get_rfms.rep_pell_id,
                                 x_rep_entity_id_txt                 => cur_get_rfms.rep_entity_id_txt,
                                 x_atd_entity_id_txt                 => cur_get_rfms.atd_entity_id_txt,
                                 x_note_message                      => cur_get_rfms.note_message,
                                 x_full_resp_code                    => cur_get_rfms.full_resp_code,
                                 x_document_id_txt                   => cur_get_rfms.document_id_txt
                                 );

                   END LOOP;
                      ELSIF p_file_type = 'GR_RFMS_DISB_ORIG'  THEN

                    fnd_message.set_name('IGF','IGF_GR_RESET_REJ_DISB_BTCH_REC');
                    fnd_message.set_token('BATCH_ID',p_batch_id);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_file.new_line(fnd_file.log,1);
                    l_disb_rfmb_id:=rfms_batch_rec.rfmb_id;
                   FOR cur_get_rfms_disb IN cur_gr_rfms_disb ( l_disb_rfmb_id )
                   LOOP
                      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID') ||' : ' || cur_get_rfms_disb.origination_id
                                                                          ||' , '
                                                                         ||igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_REF_NUM') ||'   : ' || cur_get_rfms_disb.disb_ref_num);

                   igf_gr_rfms_disb_pkg.update_row (
                         x_rowid                                    => cur_get_rfms_disb.row_id,
                         x_rfmd_id                                  => cur_get_rfms_disb.rfmd_id ,
                         x_origination_id                           => cur_get_rfms_disb.origination_id,
                         x_disb_ref_num                             => cur_get_rfms_disb.disb_ref_num,
                         x_disb_dt                                  => cur_get_rfms_disb.disb_dt,
                         x_disb_amt                                 => cur_get_rfms_disb.disb_amt,
                         x_db_cr_flag                               => cur_get_rfms_disb.db_cr_flag,
                         x_disb_ack_act_status                      => 'R',                -- record processed
                         x_disb_status_dt                           => cur_get_rfms_disb.disb_status_dt,
                         x_accpt_disb_dt                            => cur_get_rfms_disb.accpt_disb_dt ,
                         x_disb_accpt_amt                           => cur_get_rfms_disb.disb_accpt_amt,
                         x_accpt_db_cr_flag                         => cur_get_rfms_disb.accpt_db_cr_flag,
                         x_disb_ytd_amt                             => cur_get_rfms_disb.disb_ytd_amt,
                         x_pymt_prd_start_dt                        => cur_get_rfms_disb.pymt_prd_start_dt,
                         x_accpt_pymt_prd_start_dt                  => cur_get_rfms_disb.accpt_pymt_prd_start_dt,
                         x_edit_code                                => cur_get_rfms_disb.edit_code ,
                         x_rfmb_id                                  => NULL,
                         x_mode                                     => 'R',
                         x_ed_use_flags                             => cur_get_rfms_disb.ed_use_flags);

                   END LOOP;
                 END IF;
              END IF;
  ---end Bug #2938258

           END IF;

        ELSE
                fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
                igs_ge_msg_stack.add;
                RAISE file_not_loaded;
        END IF;

        IF NOT lb_error_cd  THEN

                OPEN  cur_trailer (p_file_type);
                FETCH cur_trailer INTO trailer_rec;
                -- check for a proper trailer record

                IF  cur_trailer%NOTFOUND THEN
                        CLOSE cur_trailer;
                        fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
                        --File uploaded is incomplete.
                        igs_ge_msg_stack.add;
                        RAISE file_not_loaded;
                END IF;
                CLOSE cur_trailer;

                BEGIN
                        --
                        -- This will make sure process does not bomb if the data is corrupt
                        --

                        p_number_rec  := TO_NUMBER(SUBSTR(trailer_rec.record_data,41,6));

                        EXCEPTION
                        WHEN OTHERS THEN
                        RAISE corrupt_data_file;
                END;

                p_last_gldr_id := trailer_rec.last_gldr_id;


        END IF;


  ELSE
            RAISE no_file_version;
  END IF;


EXCEPTION

WHEN no_file_version THEN
     RAISE;

WHEN corrupt_data_file THEN
     RAISE;

WHEN batch_not_in_system  THEN
     RAISE;

WHEN file_not_loaded THEN
     RAISE;

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.PROCESS_PELL_ACK'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END process_pell_ack;


FUNCTION  send_orig_disb  ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN BOOLEAN
IS

--
-- This routine is called from pell origination processes
-- before updating rfms table with the batch id seq no
--
-- Function to determine if an Origination / Disbursement Record
-- can be reported or not
--

     CURSOR cur_rfms_dat ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
     IS
     SELECT
     ver_status_code
     FROM
     igf_gr_rfms
     WHERE
     origination_id = p_orig_id;

     rfms_dat_rec  cur_rfms_dat%ROWTYPE;

     lb_send       BOOLEAN;

BEGIN

     lb_send := TRUE;

     OPEN  cur_rfms_dat ( p_orig_id );
     FETCH cur_rfms_dat INTO rfms_dat_rec;
     CLOSE cur_rfms_dat;

     IF  NOT fresh_origintn(p_orig_id)  AND
         NVL(rfms_dat_rec.ver_status_code,'X') = 'W'THEN
             lb_send := FALSE;
     END IF;

  RETURN lb_send;

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.SEND_ORIG_DISB'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END send_orig_disb;



FUNCTION get_min_pell_disb ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN NUMBER
IS

--
--
--
     CURSOR cur_pell_disb ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
     IS
     SELECT
     MIN(disb_ref_num)
     FROM
     igf_gr_rfms_disb
     WHERE
     origination_id = p_orig_id;

     ln_min_num  NUMBER(10);

BEGIN

     OPEN  cur_pell_disb ( p_orig_id );
     FETCH cur_pell_disb INTO ln_min_num;
     CLOSE cur_pell_disb ;

     RETURN ln_min_num;

EXCEPTION
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_MIN_PELL_DISB'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;


END get_min_pell_disb;

FUNCTION get_min_awd_disb  ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN NUMBER
IS
--
--
--
     CURSOR cur_awd_disb ( p_award_id igf_aw_award_all.award_id%TYPE)
     IS
     SELECT
     MIN(disb_num)
     FROM
     igf_aw_awd_disb
     WHERE
     award_id = p_award_id;

     ln_min_num  NUMBER(10);

BEGIN

     OPEN  cur_awd_disb ( p_award_id );
     FETCH cur_awd_disb INTO ln_min_num;
     CLOSE cur_awd_disb ;

     RETURN ln_min_num;

EXCEPTION
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_MIN_AWD_DISB'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_min_awd_disb;



FUNCTION get_pell_efc_code ( p_base_id IN igf_aw_award_all.base_id%TYPE)
RETURN VARCHAR2
IS
--rasahoo        27-Nov-2003    FA128 Isir Update
--                              removed cursor 'cur_sec_efc_type' and added cursor 'get_awd_fmly_contrib_type'
-- sjadhav
-- Bug 2460904
-- Fuction to determine the efc type of Pell Record.
-- ISIR paid efc can be either Primary or Secondary.
-- Based on ISIR efc, we will map Pell Sec EFC Code.
--

     CURSOR get_awd_fmly_contrib_type ( p_base_id igf_aw_award_all.base_id%TYPE)
     IS
     SELECT award_fmly_contribution_type
       FROM igf_ap_fa_base_rec
      WHERE base_id = p_base_id;


     c_awd_fmly_contrib_type  get_awd_fmly_contrib_type%ROWTYPE;

--
-- Cursor to get Origination ID
--
     CURSOR cur_get_orgn ( p_base_id igf_aw_award_all.base_id%TYPE)
     IS
     SELECT
     origination_id,
     secondary_efc_cd
     FROM
     igf_gr_rfms
     WHERE
     base_id = p_base_id;

     get_orgn_rec cur_get_orgn%ROWTYPE;

     l_sec_efc_type  igf_gr_rfms_all.secondary_efc_cd%TYPE;

BEGIN

     OPEN  cur_get_orgn(p_base_id);
     FETCH cur_get_orgn INTO get_orgn_rec;
     CLOSE cur_get_orgn;


     l_sec_efc_type := NULL;

     OPEN  get_awd_fmly_contrib_type(p_base_id);
     FETCH get_awd_fmly_contrib_type INTO c_awd_fmly_contrib_type;
     CLOSE get_awd_fmly_contrib_type;

     IF  c_awd_fmly_contrib_type.award_fmly_contribution_type IS NOT NULL THEN
        --
        -- Fresh Orign
        --
        IF  fresh_origintn(get_orgn_rec.origination_id) THEN

           IF c_awd_fmly_contrib_type.award_fmly_contribution_type = '2' THEN
              l_sec_efc_type := 'S';
           END IF;
        --
        -- Subs Orign
        --
        ELSE

           IF  c_awd_fmly_contrib_type.award_fmly_contribution_type  = '2' THEN
              l_sec_efc_type := 'S';
           ELSIF c_awd_fmly_contrib_type.award_fmly_contribution_type = '1'  AND
              get_orgn_rec.secondary_efc_cd = 'S' THEN
              l_sec_efc_type := 'O';
           END IF;

        END IF;

     END IF;

  RETURN  l_sec_efc_type;

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_PELL_EFC_CODE'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_pell_efc_code;


FUNCTION fresh_origintn ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
RETURN BOOLEAN
IS

--
-- Function to determine if an Origination Record is being
-- sent for first time or not
--

     CURSOR cur_rfms_dat ( p_orig_id igf_gr_rfms_all.origination_id%TYPE)
     IS
     SELECT
     batch.rfms_ack_batch_id
     FROM
     igf_gr_rfms        pell,
     igf_gr_rfms_batch  batch
     WHERE
     origination_id = p_orig_id       AND
     pell.rfmb_id   = batch.rfmb_id   AND
     batch.rfms_ack_batch_id IS NOT NULL;

     rfms_dat_rec  cur_rfms_dat%ROWTYPE;

     lb_send       BOOLEAN;

BEGIN

     lb_send := FALSE;

--
-- Check if Origination is being reported for first time
-- if rfms_ack_batch_id is not null it means, origination is being sent
-- again
--
     OPEN  cur_rfms_dat ( p_orig_id );
     FETCH cur_rfms_dat INTO rfms_dat_rec;
     CLOSE cur_rfms_dat;

     IF NVL(rfms_dat_rec.rfms_ack_batch_id,'X') = 'X' THEN
        lb_send := TRUE;
     END IF;

  RETURN lb_send;

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.FRESH_ORIGINTN'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END fresh_origintn;


FUNCTION get_fund_id  ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN NUMBER
IS

--
-- Function to retreive Fund ID from Award ID
--


     CURSOR cur_get_fund ( p_award_id igf_aw_award_all.award_id%TYPE)
     IS
     SELECT fund_id
     FROM
     igf_aw_award
     WHERE
     award_id = p_award_id;

     get_fund_rec cur_get_fund%ROWTYPE;

BEGIN

     OPEN  cur_get_fund ( p_award_id);
     FETCH cur_get_fund INTO get_fund_rec;
     CLOSE cur_get_fund;

     RETURN NVL(get_fund_rec.fund_id,-1);

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_FUND_ID'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;


END get_fund_id;


FUNCTION get_ssn_digits(p_ssn  igs_pe_alt_pers_id.api_person_id_uf%TYPE)
RETURN VARCHAR2 IS
--
-- sjadhav
-- This functions strips formatted ssn od special chars and
-- returns sanitisd ssn
--

lv_ssn igs_pe_alt_pers_id.api_person_id_uf%TYPE;
lv_compare_str VARCHAR2(80);

BEGIN

   lv_compare_str := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"[]{}`~!@#$%^&*_+=-,./?><():; ' ||'''';
   lv_ssn         := TRANSLATE (UPPER(LTRIM(RTRIM(p_ssn))),lv_compare_str,'1234567890');

  RETURN SUBSTR(RTRIM(LTRIM(lv_ssn)),1,9);

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_SSN_DIGITS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_ssn_digits;


PROCEDURE delete_coa( p_record           IN   VARCHAR2,
                      p_coa_code         IN   igf_aw_coa_group_all.coa_code%TYPE,
                      p_cal_type         IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                      p_sequence_number  IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                      p_item_code        IN   igf_aw_coa_grp_item_all.item_code%TYPE
                     )
IS

--
-- Bug 2613546
-- sjadhav,
-- routine to delete cost of attendance group/item childs
--

--
-- Cursor to fetch the COA Items
--

     CURSOR cur_coa_items ( p_coa_code         igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type         igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number  igf_aw_coa_group_all.ci_sequence_number%TYPE
                          )


     IS
     SELECT
     *
     FROM
     igf_aw_coa_grp_item
     WHERE
     coa_code           =  p_coa_code     AND
     ci_cal_type        =  p_cal_type     AND
     ci_sequence_number =  p_sequence_number;


--
-- Cursor to fetch COA Terms
--

     CURSOR cur_coa_terms ( p_coa_code         igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type         igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number  igf_aw_coa_group_all.ci_sequence_number%TYPE
                          )
     IS
     SELECT
     row_id
     FROM
     igf_aw_coa_ld
     WHERE
     coa_code           =  p_coa_code     AND
     ci_cal_type        =  p_cal_type     AND
     ci_sequence_number =  p_sequence_number;

--
-- Cursor to fetch Overridden COA Items
--

     CURSOR cur_coa_ovrd_items( p_coa_code         igf_aw_coa_group_all.coa_code%TYPE,
                                p_cal_type         igf_aw_coa_group_all.ci_cal_type%TYPE,
                                p_sequence_number  igf_aw_coa_group_all.ci_sequence_number%TYPE,
                                p_item_code        igf_aw_coa_grp_item_all.item_code%TYPE)
     IS
     SELECT
     row_id
     FROM
     igf_aw_cit_ld_overide
     WHERE
     coa_code           =  p_coa_code        AND
     ci_cal_type        =  p_cal_type        AND
     ci_sequence_number =  p_sequence_number AND
     item_code          =  p_item_code;


BEGIN


--
-- If p_record = COA_GROUP it means we have to delete all child records
-- for COA Grooup
-- 1. First Delete Overridden Term Distribution for Items
-- 2. Next Delete COA Items
-- 3. Then delete COA Terms
--

--
-- If p_record = COA_TERM it means we have to delete
-- ONLY Overridden Term Distribution for all Items
--

  IF  p_record IN ('COA_GROUP','COA_TERM') THEN
     FOR  coa_items_rec IN  cur_coa_items(p_coa_code,
                                   p_cal_type,
                                   p_sequence_number)
     LOOP
          --
          -- Loop thru the term overide recs and delete
          --
          FOR l_term IN cur_coa_ovrd_items(p_coa_code,
                                           p_cal_type,
                                           p_sequence_number,
                                           coa_items_rec.item_code)
          LOOP
            igf_aw_cit_ld_ovrd_pkg.delete_row(l_term.row_id);
          END LOOP;

     --
     -- Delete Items only if p_record = COA_GROUP
     --

         IF p_record = 'COA_GROUP' THEN
              igf_aw_coa_grp_item_pkg.delete_row(coa_items_rec.row_id);
         END IF;

     --
     -- Update Items with item_dist = 'N' only if p_record = COA_TERM
     --

         IF p_record = 'COA_TERM' THEN
                    igf_aw_coa_grp_item_pkg.update_row (
                                x_mode                              => 'R',
                                x_rowid                             => coa_items_rec.row_id,
                                x_coa_code                          => coa_items_rec.coa_code,
                                x_ci_cal_type                       => coa_items_rec.ci_cal_type,
                                x_ci_sequence_number                => coa_items_rec.ci_sequence_number,
                                x_item_code                         => coa_items_rec.item_code,
                                x_default_value                     => coa_items_rec.default_value,
                                x_fixed_cost                        => coa_items_rec.fixed_cost,
                                x_pell_coa                          => NULL,
                                x_active                            => coa_items_rec.active,
                                x_pell_amount                       => coa_items_rec.pell_amount,
                                x_pell_alternate_amt                => coa_items_rec.pell_alternate_amt,
                                x_item_dist                         => 'N',
                                x_lock_flag                         => coa_items_rec.lock_flag);
         END IF;

     END LOOP;

     IF  p_record = 'COA_GROUP' THEN
          --
          -- Loop thru the recs and delete
          --

          FOR l_term IN cur_coa_terms(p_coa_code,
                                      p_cal_type,
                                      p_sequence_number)
          LOOP
            igf_aw_coa_ld_pkg.delete_row(l_term.row_id);
          END LOOP;

     END IF;

  ELSIF  p_record = 'COA_ITEM' THEN
     --
     -- Loop thru the recs and delete
     --
     FOR l_term IN cur_coa_ovrd_items(p_coa_code,
                                      p_cal_type,
                                      p_sequence_number,
                                      p_item_code)
     LOOP
       igf_aw_cit_ld_ovrd_pkg.delete_row(l_term.row_id);
     END LOOP;

  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN NULL;
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.DELETE_COA'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END delete_coa;


PROCEDURE update_item_dist( p_coa_code            IN   igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type            IN   igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number     IN   igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE,
                            p_item_code           IN   igf_aw_cit_ld_ovrd_all.item_code%TYPE,
                            p_upd_result          OUT NOCOPY  VARCHAR2)

IS

--
-- Bug 2613546
-- sjadhav,
-- routine to update cost of attendance item distribution
--

--
-- Cursor to fetch the COA Items
--

     CURSOR cur_coa_items ( p_coa_code         igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type         igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number  igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE,
                            p_item_code        igf_aw_cit_ld_ovrd_all.item_code%TYPE
                          )
     IS
     SELECT
     *
     FROM
     igf_aw_coa_grp_item
     WHERE
     item_code          =  p_item_code    AND
     coa_code           =  p_coa_code     AND
     ci_cal_type        =  p_cal_type     AND
     ci_sequence_number =  p_sequence_number;

     coa_items_rec  cur_coa_items%ROWTYPE;

--
-- Cursor to fetch the Default COA Distribtuon
--
     CURSOR cur_default_ld( p_coa_code         igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type         igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number  igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE
                          )
     IS
     SELECT
     ld_perct
     FROM
     igf_aw_coa_ld
     WHERE
     coa_code           = p_coa_code        AND
     ci_cal_type        = p_cal_type        AND
     ci_sequence_number = p_sequence_number
     ORDER BY
     ld_sequence_number;

     default_ld_rec cur_default_ld%ROWTYPE;

--
-- Cursor to fetch the Overidden COA Distribtuon
--
     CURSOR cur_overide_ld( p_coa_code           igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type           igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number    igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE,
                            p_item_code          igf_aw_cit_ld_ovrd_all.item_code%TYPE
                          )
     IS
     SELECT
     ld_perct
     FROM
     igf_aw_cit_ld_overide
     WHERE
     coa_code           = p_coa_code           AND
     ci_cal_type        = p_cal_type           AND
     ci_sequence_number = p_sequence_number    AND
     item_code          = p_item_code
     ORDER BY
     ld_sequence_number;

     overide_ld_rec cur_overide_ld%ROWTYPE;

     lv_item_dist  igf_aw_coa_grp_item_all.item_dist%TYPE;

     CURSOR cur_pct_total( p_coa_code           igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                           p_cal_type           igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                           p_sequence_number    igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE,
                           p_item_code          igf_aw_cit_ld_ovrd_all.item_code%TYPE
                          )
     IS
     SELECT
     SUM(ld_perct)
     FROM
     igf_aw_cit_ld_overide
     WHERE
     coa_code           = p_coa_code           AND
     ci_cal_type        = p_cal_type           AND
     ci_sequence_number = p_sequence_number    AND
     item_code          = p_item_code;

     ln_total NUMBER;

--
-- PL/SQL table to store default load %
--

     TYPE def_list IS TABLE OF igf_aw_coa_ld.ld_perct%TYPE
                INDEX BY BINARY_INTEGER;
     def_ele  def_list;

--
-- PL/SQL table to store Overidden load %
--

     TYPE ovd_list IS TABLE OF igf_aw_cit_ld_overide.ld_perct%TYPE
                INDEX BY BINARY_INTEGER;
     ovd_ele  ovd_list;

     ln_count_i BINARY_INTEGER;
     ln_count_j BINARY_INTEGER;

BEGIN


     lv_item_dist := 'N';
     p_upd_result := 'FALSE';

     OPEN  cur_pct_total ( p_coa_code,
                           p_cal_type,
                           p_sequence_number,
                           p_item_code);
     FETCH cur_pct_total INTO ln_total;
     CLOSE cur_pct_total;

     IF ln_total <> 100 THEN
        p_upd_result := 'PERCT_ERROR';
     ELSE

        ln_count_i   := 1;

        FOR   default_ld_rec IN  cur_default_ld ( p_coa_code,
                                                  p_cal_type,
                                                  p_sequence_number)
        LOOP
               def_ele(ln_count_i)  := default_ld_rec.ld_perct;
               ln_count_i           := ln_count_i + 1;
        END LOOP;

        ln_count_j   := ln_count_i;
        ln_count_i   := 1;

        FOR   overide_ld_rec IN  cur_overide_ld ( p_coa_code,
                                                  p_cal_type,
                                                  p_sequence_number,
                                                  p_item_code)
        LOOP
               ovd_ele(ln_count_i)  := overide_ld_rec.ld_perct;
               ln_count_i           := ln_count_i + 1;
        END LOOP;


        --
        -- compare default and ovrd load %
        --

        ln_count_i   := 1;

        LOOP
             EXIT WHEN ln_count_i >=  ln_count_j;
             IF  ovd_ele(ln_count_i) <> def_ele(ln_count_i) THEN
                 lv_item_dist := 'Y';
                 EXIT;
             END IF;
             ln_count_i := ln_count_i + 1;

        END LOOP;


        OPEN   cur_coa_items(p_coa_code,
                             p_cal_type,
                             p_sequence_number,
                             p_item_code);
        FETCH cur_coa_items INTO coa_items_rec;
        CLOSE cur_coa_items;
--Bug ID 2689362
        IF lv_item_dist='N' THEN

                      delete_coa( 'COA_ITEM' ,
                                   coa_items_rec.coa_code,
                                   coa_items_rec.ci_cal_type,
                                   coa_items_rec.ci_sequence_number,
                                   coa_items_rec.item_code
                                 );

        END IF;

        IF NVL(coa_items_rec.item_dist,'N') <> lv_item_dist THEN

             igf_aw_coa_grp_item_pkg.update_row (
                                x_mode                              => 'R',
                                x_rowid                             => coa_items_rec.row_id,
                                x_coa_code                          => coa_items_rec.coa_code,
                                x_ci_cal_type                       => coa_items_rec.ci_cal_type,
                                x_ci_sequence_number                => coa_items_rec.ci_sequence_number,
                                x_item_code                         => coa_items_rec.item_code,
                                x_default_value                     => coa_items_rec.default_value,
                                x_fixed_cost                        => coa_items_rec.fixed_cost,
                                x_pell_coa                          => NULL,
                                x_active                            => coa_items_rec.active,
                                x_pell_amount                       => coa_items_rec.pell_amount,
                                x_pell_alternate_amt                => coa_items_rec.pell_alternate_amt,
                                x_item_dist                         => lv_item_dist,
                                x_lock_flag                         => coa_items_rec.lock_flag);

             p_upd_result := 'TRUE';
             COMMIT;

        END IF;

     END IF;

EXCEPTION
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.UPDATE_ITEM_DIST'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END update_item_dist;


PROCEDURE get_def_awd_year(p_alternate_code  OUT NOCOPY   igs_ca_inst_all.alternate_code%TYPE,
                           p_cal_type        OUT NOCOPY   igs_ca_inst_all.cal_type%TYPE,
                           p_sequence_number OUT NOCOPY   igs_ca_inst_all.sequence_number%TYPE,
                           p_start_date      OUT NOCOPY   igs_ca_inst_all.start_dt%TYPE,
                           p_end_date        OUT NOCOPY   igs_ca_inst_all.end_dt%TYPE,
                           p_err_msg         OUT NOCOPY   VARCHAR2
                           )

IS
--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- the first record fetched from this cursor
-- will be the default award year
--

     CURSOR cur_get_awd_yr
     IS
     SELECT
     alternate_code,
     cal_type,
     sequence_number,
     start_dt,
     end_dt
     FROM
     igf_ap_award_year_v
     ORDER BY
     ABS(TRUNC(SYSDATE) - TRUNC(start_dt));


BEGIN

     p_err_msg := 'NULL';

     OPEN  cur_get_awd_yr;
     FETCH cur_get_awd_yr
     INTO
     p_alternate_code,
     p_cal_type,
     p_sequence_number,
     p_start_date,
     p_end_date;

     IF cur_get_awd_yr%NOTFOUND THEN
          p_err_msg := 'IGF_AW_AWDYR_NOT_FOUND';
     END IF;

     CLOSE cur_get_awd_yr;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   IF cur_get_awd_yr%ISOPEN THEN
        CLOSE cur_get_awd_yr;
   END IF;

WHEN OTHERS THEN

   IF cur_get_awd_yr%ISOPEN THEN
        CLOSE cur_get_awd_yr;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_DEF_AWD_YEAR'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_def_awd_year;

--
-- Bug 2613546,2606001
-- sjadhav
-- Oct,22,2002.
--
-- ovrd_coa_exist will check if there are any overridden coa items
-- for a coa group
--

PROCEDURE ovrd_coa_exist( p_coa_code         IN   igf_aw_coa_group_all.coa_code%TYPE,
                          p_cal_type         IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                          p_sequence_number  IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                          p_exist            OUT NOCOPY  VARCHAR2
                        )
IS


--
-- Cursor to fetch the Overidden COA Items
--
     CURSOR cur_overide_ld( p_coa_code           igf_aw_cit_ld_ovrd_all.coa_code%TYPE,
                            p_cal_type           igf_aw_cit_ld_ovrd_all.ci_cal_type%TYPE,
                            p_sequence_number    igf_aw_cit_ld_ovrd_all.ci_sequence_number%TYPE
                          )
     IS
     SELECT
     ld_perct
     FROM
     igf_aw_cit_ld_overide
     WHERE
     coa_code           = p_coa_code           AND
     ci_cal_type        = p_cal_type           AND
     ci_sequence_number = p_sequence_number;

     ln_perct            igf_aw_cit_ld_ovrd_all.ld_perct%TYPE;

BEGIN


     OPEN cur_overide_ld ( p_coa_code,
                           p_cal_type,
                           p_sequence_number );
     FETCH cur_overide_ld INTO ln_perct;

     IF  cur_overide_ld%NOTFOUND THEN
         p_exist := 'N';
     ELSIF cur_overide_ld%FOUND THEN
         p_exist := 'Y';
     END IF;

     CLOSE cur_overide_ld;

EXCEPTION
WHEN OTHERS THEN

   IF cur_overide_ld%ISOPEN THEN
        CLOSE cur_overide_ld;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.OVRD_COA_EXIST'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;


END ovrd_coa_exist;


FUNCTION get_tufees_code(p_base_id             IN   igf_gr_rfms_all.base_id%TYPE,
                         p_cal_type            IN   igf_gr_rfms_all.ci_cal_type%TYPE,
                         p_sequence_number     IN   igf_gr_rfms_all.ci_sequence_number%TYPE)
RETURN VARCHAR2
IS

--
-- First check if the award is a regular or alternate pell
-- award
--

    CURSOR cur_get_award(
                         p_base_id igf_gr_rfms_all.base_id%TYPE
                        ) IS
      SELECT alt_pell_schedule
        FROM igf_aw_award_all awd,
             igf_aw_fund_mast_all fmast,
             igf_aw_fund_cat_all fcat
       WHERE awd.base_id = p_base_id
         AND awd.fund_id = fmast.fund_id
         AND awd.award_status IN ('ACCEPTED','OFFERED')
         AND fmast.fund_code = fcat.fund_code
         AND fcat.fed_fund_code = 'PELL';


--
-- Function to return loa tuition fees code
--
     CURSOR cur_get_alt (p_base_id   igf_gr_rfms_all.base_id%TYPE)
     IS
     SELECT
     pell_alt_expense
     FROM
     igf_ap_fa_base_rec
     WHERE
     base_id = p_base_id;

     get_alt_rec    cur_get_alt%ROWTYPE;

     CURSOR cur_tufees_code (p_exp                 igf_ap_fa_base_rec_all.pell_alt_expense%TYPE,
                             p_cal_type            igf_gr_rfms_all.ci_cal_type%TYPE,
                             p_sequence_number     igf_gr_rfms_all.ci_sequence_number%TYPE)
     IS
     SELECT ltfees.lt_fees_code
       FROM igf_gr_tuition_fee_codes ltfees,
            igf_ap_batch_aw_map_all batch
      WHERE p_exp BETWEEN ltfees.min_range_amt AND ltfees.max_range_amt
        AND batch.ci_cal_type = p_cal_type
        AND batch.ci_sequence_number = p_sequence_number
        AND batch.sys_award_year = ltfees.sys_awd_yr;

     tufees_code_rec  cur_tufees_code%ROWTYPE;

     lv_fees_code     igf_gr_tuition_fee_codes.lt_fees_code%TYPE;

BEGIN

     OPEN  cur_get_award (p_base_id);
     FETCH cur_get_award INTO lv_fees_code;
     CLOSE cur_get_award;

     IF NVL(lv_fees_code,'N') = 'A' THEN

          OPEN  cur_get_alt(p_base_id);
          FETCH cur_get_alt INTO get_alt_rec;
          CLOSE cur_get_alt;

          OPEN cur_tufees_code(get_alt_rec.pell_alt_expense,
                               p_cal_type,
                               p_sequence_number);
          FETCH cur_tufees_code INTO tufees_code_rec;
          CLOSE cur_tufees_code;

          lv_fees_code := tufees_code_rec.lt_fees_code;

     END IF;

     RETURN lv_fees_code;

EXCEPTION
WHEN OTHERS THEN

   IF cur_get_alt%ISOPEN THEN
        CLOSE cur_get_alt;
   END IF;
   IF cur_tufees_code%ISOPEN THEN
        CLOSE cur_tufees_code;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_TUFEES_CODE'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_tufees_code;

PROCEDURE insert_coa_items( p_coa_code           IN   igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type           IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number    IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                            p_item_code          IN   igf_aw_coa_grp_item_all.item_code%TYPE,
                            p_count              OUT NOCOPY  NUMBER
                        )

IS
--
-- Cursor to get default load periods
--

 CURSOR cur_default_ld(p_coa_code        IN VARCHAR2,
                       p_cal_type        IN VARCHAR2,
                       p_sequence_number IN NUMBER
                      )
        IS
        SELECT
        ld_cal_type,
        ld_sequence_number,
        ld_perct,
        ci_cal_type,
        ci_sequence_number
        FROM
        igf_aw_coa_ld
        WHERE
        coa_code           = p_coa_code        AND
        ci_cal_type        = p_cal_type        AND
        ci_sequence_number = p_sequence_number;

--
-- Cursor to get default load periods
--

 CURSOR cur_overide (p_coa_code           VARCHAR2,
                     p_item_code          VARCHAR2,
                     p_cal_type           VARCHAR2,
                     p_sequence_number    NUMBER,
                     p_ld_cal_type        VARCHAR2,
                     p_ld_sequence_number NUMBER
                    )
        IS
        SELECT
        cldo_id
        FROM
        igf_aw_cit_ld_overide
        WHERE
        coa_code           = p_coa_code           AND
        ci_cal_type        = p_cal_type           AND
        ci_sequence_number = p_sequence_number    AND
        item_code          = p_item_code          AND
        ld_cal_type        = p_ld_cal_type        AND
        ld_sequence_number = p_ld_sequence_number;

  overide_rec         cur_overide%ROWTYPE;
  default_ld_rec      cur_default_ld%ROWTYPE;
  l_cldo_id           igf_aw_cit_ld_ovrd_all.cldo_id%TYPE;
  lv_ld_rowid         ROWID;
  ln_count            NUMBER(10);

BEGIN

   FOR default_ld_rec IN cur_default_ld (p_coa_code,
                                         p_cal_type,
                                         p_sequence_number)
   LOOP

     ln_count     := ln_count + 1;
     lv_ld_rowid  := NULL;
     l_cldo_id    := NULL;

      OPEN  cur_overide(p_coa_code,
                        p_item_code,
                        default_ld_rec.ci_cal_type,
                        default_ld_rec.ci_sequence_number,
                        default_ld_rec.ld_cal_type,
                        default_ld_rec.ld_sequence_number
                        );

      FETCH cur_overide INTO overide_rec;

      IF cur_overide%NOTFOUND THEN

            igf_aw_cit_ld_ovrd_pkg.insert_row (
               x_mode                              => 'R',
               x_rowid                             => lv_ld_rowid,
               x_cldo_id                           => l_cldo_id,
               x_coa_code                          => p_coa_code,
               x_ci_cal_type                       => p_cal_type,
               x_ci_sequence_number                => p_sequence_number,
               x_item_code                         => p_item_code,
               x_ld_cal_type                       => default_ld_rec.ld_cal_type,
               x_ld_sequence_number                => default_ld_rec.ld_sequence_number,
               x_ld_perct                          => default_ld_rec.ld_perct
        );
      END IF;
      CLOSE cur_overide;

   END LOOP;

   p_count := ln_count;

EXCEPTION
WHEN OTHERS THEN

   IF cur_default_ld%ISOPEN THEN
        CLOSE cur_default_ld;
   END IF;

   IF cur_overide%ISOPEN THEN
        CLOSE cur_overide;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.INSERT_COA_ITEMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END insert_coa_items;

PROCEDURE insert_coa_terms( p_coa_code           IN   igf_aw_coa_group_all.coa_code%TYPE,
                            p_cal_type           IN   igf_aw_coa_group_all.ci_cal_type%TYPE,
                            p_sequence_number    IN   igf_aw_coa_group_all.ci_sequence_number%TYPE,
                            p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                            p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE
                        )

IS

CURSOR cur_get_items (p_coa_code           igf_aw_coa_group_all.coa_code%TYPE,
                      p_cal_type           igf_aw_coa_group_all.ci_cal_type%TYPE,
                      p_sequence_number    igf_aw_coa_group_all.ci_sequence_number%TYPE)
IS
SELECT
DISTINCT item_code
FROM
igf_aw_cit_ld_overide
WHERE
coa_code           = p_coa_code AND
ci_cal_type        = p_cal_type AND
ci_sequence_number = p_sequence_number;

get_items_rec  cur_get_items%ROWTYPE;


  l_cldo_id           igf_aw_cit_ld_ovrd_all.cldo_id%TYPE;
  lv_ld_rowid         ROWID;

BEGIN

     FOR get_items_rec IN cur_get_items(p_coa_code,
                                        p_cal_type,
                                        p_sequence_number)
     LOOP

     lv_ld_rowid  := NULL;
     l_cldo_id    := NULL;

            igf_aw_cit_ld_ovrd_pkg.insert_row (
               x_mode                              => 'R',
               x_rowid                             => lv_ld_rowid,
               x_cldo_id                           => l_cldo_id,
               x_coa_code                          => p_coa_code,
               x_ci_cal_type                       => p_cal_type,
               x_ci_sequence_number                => p_sequence_number,
               x_item_code                         => get_items_rec.item_code,
               x_ld_cal_type                       => p_ld_cal_type,
               x_ld_sequence_number                => p_ld_sequence_number,
               x_ld_perct                          => 0
        );

     END LOOP;


EXCEPTION
WHEN OTHERS THEN

   IF cur_get_items%ISOPEN THEN
        CLOSE cur_get_items;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.INSERT_COA_TERMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END insert_coa_terms;


PROCEDURE insert_stu_coa_terms( p_base_id            IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                                p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE,
                                p_result             OUT NOCOPY  VARCHAR2
                              )
IS

CURSOR cur_get_terms (p_base_id igf_aw_coa_itm_terms.base_id%TYPE)
IS
SELECT item_code
  FROM igf_aw_coa_items
 WHERE base_id = p_base_id;

lv_rowid   ROWID;

BEGIN

p_result := 'S';

     FOR get_terms_rec IN cur_get_terms (p_base_id) LOOP

          lv_rowid   := NULL;


          igf_aw_coa_itm_terms_pkg.insert_row( x_rowid                => lv_rowid,
                                               x_base_id              => p_base_id,
                                               x_item_code            => get_terms_rec.item_code,
                                               x_amount               => 0,
                                               x_ld_cal_type          => p_ld_cal_type,
                                               x_ld_sequence_number   => p_ld_sequence_number,
                                               x_mode                 => 'R',
                                               x_lock_flag            => 'N'
                                               );
     END LOOP;

EXCEPTION

WHEN OTHERS THEN
   p_result := 'F';
   IF cur_get_terms%ISOPEN THEN
        CLOSE cur_get_terms;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.INSERT_STU_COA_TERMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END insert_stu_coa_terms;

--CODE ADDED BY GAUTAM

PROCEDURE insert_existing_terms( p_base_id            IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                 p_item_code          IN   igf_aw_coa_itm_terms.item_code%TYPE,
                                 p_result             OUT NOCOPY  VARCHAR2
                                 )
IS

CURSOR cur_get_existing_terms(c_base_id   igf_aw_coa_itm_terms.base_id%TYPE)
IS
SELECT DISTINCT ld_cal_type,ld_sequence_number
FROM   igf_aw_coa_itm_terms
WHERE  base_id = c_base_id;

get_exisiting_terms_rec   cur_get_existing_terms%ROWTYPE;
lv_rowid  ROWID;

BEGIN

p_result := 'S';

FOR get_existing_terms_rec IN cur_get_existing_terms(p_base_id) LOOP

          lv_rowid   := NULL;

          igf_aw_coa_itm_terms_pkg.insert_row( x_rowid                => lv_rowid,
                                               x_base_id              => p_base_id,
                                               x_item_code            => p_item_code,
                                               x_amount               => 0,
                                               x_ld_cal_type          => get_existing_terms_rec.ld_cal_type,
                                               x_ld_sequence_number   => get_existing_terms_rec.ld_sequence_number,
                                               x_mode                 => 'R',
                                               x_lock_flag            => 'N'
                                               );
END LOOP;

EXCEPTION

WHEN OTHERS THEN
   p_result := 'F';
   IF cur_get_existing_terms%ISOPEN THEN
        CLOSE cur_get_existing_terms;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.INSERT_EXISTING_TERMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END  insert_existing_terms;

PROCEDURE delete_stu_coa_terms( p_base_id            IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_ld_cal_type        IN   igf_aw_coa_ld_all.ld_cal_type%TYPE,
                                p_ld_sequence_number IN   igf_aw_coa_ld_all.ld_sequence_number%TYPE,
                                p_result             OUT NOCOPY  VARCHAR2
                              )

IS


CURSOR cur_get_terms (p_base_id             igf_aw_coa_itm_terms.base_id%TYPE,
                      p_ld_cal_type         igf_aw_coa_ld_all.ld_cal_type%TYPE,
                      p_ld_sequence_number  igf_aw_coa_ld_all.ld_sequence_number%TYPE
)
IS
SELECT rowid
 FROM  igf_aw_coa_itm_terms
WHERE  base_id            = p_base_id
  AND  ld_cal_type        = p_ld_cal_type
  AND  ld_sequence_number = p_ld_sequence_number;


BEGIN

p_result := 'S';

     FOR get_terms_rec IN cur_get_terms (p_base_id,
                                         p_ld_cal_type,
                                         p_ld_sequence_number)
     LOOP
          igf_aw_coa_itm_terms_pkg.delete_row( x_rowid => get_terms_rec.rowid);
     END LOOP;

EXCEPTION

WHEN OTHERS THEN
   p_result := 'F';
   IF cur_get_terms%ISOPEN THEN
        CLOSE cur_get_terms;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.DELETE_STU_COA_TERMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END delete_stu_coa_terms;


PROCEDURE delete_stu_coa_items( p_base_id    IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_result     OUT NOCOPY  VARCHAR2,
                                p_item_code  IN   igf_aw_coa_items.item_code%TYPE
                              )
IS

CURSOR cur_get_coa_itms (p_base_id     igf_aw_coa_itm_terms.base_id%TYPE,
                         p_item_code   igf_aw_coa_items.item_code%TYPE)
    IS
SELECT item_code,rowid
  FROM igf_aw_coa_items
 WHERE base_id   = p_base_id
   AND item_code = NVL(p_item_code,item_code);


CURSOR cur_get_coa_terms (p_base_id           igf_aw_coa_itm_terms.base_id%TYPE,
                          p_item_code         igf_aw_coa_itm_terms.item_code%TYPE)

    IS
SELECT rowid
  FROM igf_aw_coa_itm_terms
 WHERE base_id    = p_base_id
   AND item_code  = p_item_code;

BEGIN

  p_result := 'S';

  FOR get_coa_itms_rec IN cur_get_coa_itms (p_base_id,
                                            p_item_code)
  LOOP
     FOR get_coa_terms_rec IN  cur_get_coa_terms (p_base_id,
                                                  get_coa_itms_rec.item_code)
     LOOP
          igf_aw_coa_itm_terms_pkg.delete_row(x_rowid => get_coa_terms_rec.rowid);
     END LOOP;
   --  igf_aw_coa_items_pkg.delete_row(x_rowid => get_coa_itms_rec.rowid);
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
   p_result := 'F';
   IF cur_get_coa_itms%ISOPEN THEN
        CLOSE cur_get_coa_itms;
   END IF;
   IF cur_get_coa_terms%ISOPEN THEN
        CLOSE cur_get_coa_terms;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.DELETE_STU_COA_ITEMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END delete_stu_coa_items;

PROCEDURE update_stu_coa_items( p_base_id       IN   igf_aw_coa_itm_terms.base_id%TYPE,
                                p_item_code     IN   igf_aw_coa_itm_terms.item_code%TYPE,
                                p_result        OUT NOCOPY  VARCHAR2)
IS

CURSOR cur_get_items (p_base_id   igf_aw_coa_itm_terms.base_id%TYPE,
                      p_item_code igf_aw_coa_itm_terms.item_code%TYPE)
    IS
SELECT items.rowid,items.*
FROM
igf_aw_coa_items items
WHERE base_id   = p_base_id
  AND item_code = NVL(p_item_code,item_code);

CURSOR cur_get_terms (p_base_id            igf_aw_coa_itm_terms.base_id%TYPE,
                      p_item_code          igf_aw_coa_items.item_code%TYPE)
    IS
SELECT
   SUM (amount) item_amount
  FROM igf_aw_coa_itm_terms
WHERE  base_id   = p_base_id
  AND  item_code = p_item_code
GROUP BY item_code;

BEGIN

  p_result := 'S';

  FOR get_items_rec IN cur_get_items ( p_base_id,
                                       p_item_code)
  LOOP
     FOR get_terms_rec IN cur_get_terms ( p_base_id,
                                          get_items_rec.item_code)
     LOOP
          igf_aw_coa_items_pkg.update_row (x_rowid                => get_items_rec.rowid,
                                           x_base_id              => p_base_id,
                                           x_item_code            => get_items_rec.item_code,
                                           x_amount               => get_terms_rec.item_amount,
                                           x_pell_coa_amount      => get_items_rec.pell_coa_amount,
                                           x_alt_pell_amount      => get_items_rec.alt_pell_amount,
                                           x_fixed_cost           => get_items_rec.fixed_cost,
                                           x_mode                 => 'R',
                                           x_lock_flag            => get_items_rec.lock_flag
                                          );


     END LOOP;

  END LOOP;


EXCEPTION

WHEN OTHERS THEN
   p_result := 'F';

   IF cur_get_items%ISOPEN THEN
        CLOSE cur_get_items;
   END IF;
   IF cur_get_terms%ISOPEN THEN
        CLOSE cur_get_terms;
   END IF;

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.UPDATE_STU_COA_ITEMS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END update_stu_coa_items;



FUNCTION get_pell_code(p_att_code            IN   igs_en_stdnt_ps_att_all.derived_att_type%TYPE,
                       p_cal_type            IN   igf_ap_fa_base_rec.ci_cal_type%TYPE,
                       p_sequence_number     IN   igf_ap_fa_base_rec.ci_sequence_number%TYPE)
RETURN VARCHAR2
/*
  ||  Created By :
  ||  Created On :
  ||  Purpose    :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rasahoo         01-Sep-2003     Replaced igf_ap_fa_base_h_all.derived_attend_type%TYPE
  ||                                  with igs_en_stdnt_ps_att_all.derived_att_type%TYPE
  ||                                  as part of the build FA-114 (Obsoletion of FA base record History)
  ||  (reverse chronological order - newest change first)
  */
IS

CURSOR cur_get_pell (p_att_code            igs_en_stdnt_ps_att_all.derived_att_type%TYPE,
                     p_cal_type            igf_ap_fa_base_rec.ci_cal_type%TYPE,
                     p_sequence_number     igf_ap_fa_base_rec.ci_sequence_number%TYPE
                    )
IS
SELECT pell_att_code
  FROM igf_ap_attend_map
 WHERE attendance_type  = p_att_code
   AND cal_type         = p_cal_type
   AND sequence_number  = p_sequence_number;

get_pell_rec cur_get_pell%ROWTYPE;

BEGIN
    IF p_att_code IS NULL THEN
      RETURN '5';
    ELSE
     OPEN  cur_get_pell(p_att_code,
                       p_cal_type,
                       p_sequence_number);
     FETCH cur_get_pell INTO get_pell_rec;
     CLOSE cur_get_pell;

     RETURN get_pell_rec.pell_att_code;
   END IF;
END get_pell_code;


--
-- Bug 2590991
-- sjadhav
-- Nov,18,2002.
--
-- Routine to fetch base id
--

PROCEDURE get_base_id(p_cal_type        IN          igs_ca_inst_all.cal_type%TYPE,
                      p_sequence_number IN          igs_ca_inst_all.sequence_number%TYPE,
                      p_person_id       IN          igf_ap_fa_base_rec_all.person_id%TYPE,
                      p_base_id         OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_err_msg         OUT NOCOPY  VARCHAR2
                      )
IS


--
-- Cursor to get base id
--

 CURSOR cur_get_base (p_cal_type        igs_ca_inst_all.cal_type%TYPE,
                      p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                      p_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)
  IS
  SELECT
  base_id
  FROM
  igf_ap_fa_base_rec
  WHERE
  person_id = p_person_id AND
  ci_cal_type = p_cal_type AND
  ci_sequence_number = p_sequence_number;


BEGIN

  p_err_msg := 'NULL';
  OPEN cur_get_base( p_cal_type,
                     p_sequence_number,
                     p_person_id);
  FETCH cur_get_base INTO p_base_id;

  IF  cur_get_base%NOTFOUND THEN
     p_err_msg := 'IGF_AP_NO_FA_APPL_MSG';
  END IF;

  CLOSE cur_get_base;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   IF cur_get_base%ISOPEN THEN
        CLOSE cur_get_base;
   END IF;

WHEN OTHERS THEN

   IF cur_get_base%ISOPEN THEN
        CLOSE cur_get_base;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_BASE_ID'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_base_id;

PROCEDURE update_current_ssn (p_base_id  IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_cur_ssn  IN          igf_ap_isir_matched_all.current_ssn%TYPE,
                              p_message  OUT NOCOPY  fnd_new_messages.message_name%TYPE)
IS
--
-- sjadhav,2/4/03
-- FA116 Build - Bug 2758812 - 2/4/03
-- update_current_ssn
-- updates current ssn with the new value from active isir
--

CURSOR cur_get_pell (p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE)
IS
SELECT pell.*
FROM
igf_gr_rfms pell
WHERE
base_id = p_base_id
FOR UPDATE OF current_ssn;

get_pell_rec cur_get_pell%ROWTYPE;

BEGIN

     p_message := 'NULL';
     OPEN  cur_get_pell(p_base_id);
     FETCH cur_get_pell INTO get_pell_rec;

     IF    cur_get_pell%FOUND THEN
--          IF get_pell_rec.current_ssn <> p_cur_ssn THEN
          IF NVL(get_pell_rec.current_ssn, -1) <> NVL(p_cur_ssn, -1) THEN

               IF get_pell_rec.orig_action_code <>'S' THEN

                    get_pell_rec.current_ssn      := get_ssn_digits(p_cur_ssn);
                    get_pell_rec.rfmb_id          := NULL;
                    get_pell_rec.orig_action_code := 'R';

                    igf_gr_rfms_pkg.update_row(
                                        x_rowid                      =>   get_pell_rec.row_id,
                                        x_origination_id             =>   get_pell_rec.origination_id,
                                        x_ci_cal_type                =>   get_pell_rec.ci_cal_type,
                                        x_ci_sequence_number         =>   get_pell_rec.ci_sequence_number,
                                        x_base_id                    =>   get_pell_rec.base_id,
                                        x_award_id                   =>   get_pell_rec.award_id,
                                        x_rfmb_id                    =>   get_pell_rec.rfmb_id,
                                        x_sys_orig_ssn               =>   get_pell_rec.sys_orig_ssn,
                                        x_sys_orig_name_cd           =>   get_pell_rec.sys_orig_name_cd,
                                        x_transaction_num            =>   get_pell_rec.transaction_num,
                                        x_efc                        =>   get_pell_rec.efc,
                                        x_ver_status_code            =>   get_pell_rec.ver_status_code,
                                        x_secondary_efc              =>   get_pell_rec.secondary_efc,
                                        x_secondary_efc_cd           =>   get_pell_rec.secondary_efc_cd,
                                        x_pell_amount                =>   get_pell_rec.pell_amount,
                                        x_pell_profile               =>   get_pell_rec.pell_profile,
                                        x_enrollment_status          =>   get_pell_rec.enrollment_status,
                                        x_enrollment_dt              =>   get_pell_rec.enrollment_dt,
                                        x_coa_amount                 =>   get_pell_rec.coa_amount,
                                        x_academic_calendar          =>   get_pell_rec.academic_calendar,
                                        x_payment_method             =>   get_pell_rec.payment_method,
                                        x_total_pymt_prds            =>   get_pell_rec.total_pymt_prds,
                                        x_incrcd_fed_pell_rcp_cd     =>   get_pell_rec.incrcd_fed_pell_rcp_cd,
                                        x_attending_campus_id        =>   get_pell_rec.attending_campus_id,
                                        x_est_disb_dt1               =>   get_pell_rec.est_disb_dt1,
                                        x_orig_action_code           =>   get_pell_rec.orig_action_code,
                                        x_orig_status_dt             =>   get_pell_rec.orig_status_dt,
                                        x_orig_ed_use_flags          =>   get_pell_rec.orig_ed_use_flags,
                                        x_ft_pell_amount             =>   get_pell_rec.ft_pell_amount,
                                        x_prev_accpt_efc             =>   get_pell_rec.prev_accpt_efc,
                                        x_prev_accpt_tran_no         =>   get_pell_rec.prev_accpt_tran_no,
                                        x_prev_accpt_sec_efc_cd      =>   get_pell_rec.prev_accpt_sec_efc_cd,
                                        x_prev_accpt_coa             =>   get_pell_rec.prev_accpt_coa,
                                        x_orig_reject_code           =>   get_pell_rec.orig_reject_code,
                                        x_wk_inst_time_calc_pymt     =>   get_pell_rec.wk_inst_time_calc_pymt,
                                        x_wk_int_time_prg_def_yr     =>   get_pell_rec.wk_int_time_prg_def_yr,
                                        x_cr_clk_hrs_prds_sch_yr     =>   get_pell_rec.cr_clk_hrs_prds_sch_yr,
                                        x_cr_clk_hrs_acad_yr         =>   get_pell_rec.cr_clk_hrs_acad_yr,
                                        x_inst_cross_ref_cd          =>   get_pell_rec.inst_cross_ref_cd,
                                        x_low_tution_fee             =>   get_pell_rec.low_tution_fee,
                                        x_rec_source                 =>   get_pell_rec.rec_source,
                                        x_pending_amount             =>   get_pell_rec.pending_amount,
                                        x_mode                       =>   'R',
                                        x_birth_dt                   =>   get_pell_rec.birth_dt,
                                        x_last_name                  =>   get_pell_rec.last_name,
                                        x_first_name                 =>   get_pell_rec.first_name,
                                        x_middle_name                =>   get_pell_rec.middle_name,
                                        x_current_ssn                =>   get_pell_rec.current_ssn,
                                        x_legacy_record_flag         =>   NULL,
                                        x_reporting_pell_cd          =>   get_pell_rec.rep_pell_id,
                                        x_rep_entity_id_txt          =>   get_pell_rec.rep_entity_id_txt,
                                        x_atd_entity_id_txt          =>   get_pell_rec.atd_entity_id_txt,
                                        x_note_message               =>   get_pell_rec.note_message,
                                        x_full_resp_code             =>   get_pell_rec.full_resp_code,
                                        x_document_id_txt            =>   get_pell_rec.document_id_txt

                                        );

               ELSE
                    p_message := 'IGF_GR_UPDT_SSN_FAIL';
               END IF;
          END IF;
     END IF;

     CLOSE cur_get_pell;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   IF cur_get_pell%ISOPEN THEN
        CLOSE cur_get_pell;
   END IF;

WHEN app_exception.record_lock_exception THEN
   IF cur_get_pell%ISOPEN THEN
        CLOSE cur_get_pell;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
   fnd_message.set_token('NAME','IGF_GR_GEN.UPDATE_CURRENT_SSN');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

WHEN OTHERS THEN
   IF cur_get_pell%ISOPEN THEN
        CLOSE cur_get_pell;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.UPDATE_CURRENT_SSN'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END update_current_ssn;

PROCEDURE update_pell_status (p_award_id      IN          igf_aw_award_all.award_id%TYPE,
                              p_fed_fund_code IN          igf_aw_fund_cat_all.fed_fund_code%TYPE,
                              p_message       OUT NOCOPY  fnd_new_messages.message_name%TYPE,
                              p_status_desc   OUT NOCOPY  igf_lookups_view.meaning%TYPE)
IS

--
-- sjadhav,2/4/03
-- FA116 Build - Bug 2758812 - 2/4/03
-- update_pell_status
-- sets pell origination status desc
--

CURSOR cur_get_pell (p_award_id  igf_gr_rfms_all.award_id%TYPE)
IS
SELECT pell.orig_action_code
FROM
igf_gr_rfms pell
WHERE
award_id = p_award_id;


get_pell_rec cur_get_pell%ROWTYPE;

BEGIN

     p_message      := 'NULL';
     p_status_desc  := 'NULL';

     IF p_fed_fund_code = 'PELL' THEN

          OPEN  cur_get_pell(p_award_id);
          FETCH cur_get_pell INTO get_pell_rec;

          IF    cur_get_pell%FOUND THEN
               IF get_pell_rec.orig_action_code IN ('A','C','D','E') THEN
                    p_message     := 'IGF_GR_ORIG_STAT_CHG';
                    p_status_desc := igf_aw_gen.lookup_desc('IGF_GR_ORIG_STATUS',
                                                            get_pell_rec.orig_action_code);
               END IF;
          END IF;
          CLOSE cur_get_pell;

     END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   IF cur_get_pell%ISOPEN THEN
        CLOSE cur_get_pell;
   END IF;

WHEN OTHERS THEN
   IF cur_get_pell%ISOPEN THEN
        CLOSE cur_get_pell;
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.UPDATE_PELL_STATUS'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END update_pell_status;

PROCEDURE match_file_version (p_version       IN          igf_lookups_view.lookup_code%TYPE,
                              p_batch_id      IN          igf_gr_rfms_batch_all.batch_id%TYPE,
                              p_message       OUT NOCOPY  fnd_new_messages.message_name%TYPE)
IS

--
-- sjadhav,2/4/03
-- FA116 Build - Bug 2758812 - 2/4/03
-- match_file_version
-- compares cycle year from pell version and
-- batch id
--

BEGIN

     p_message     := 'NULL';
     IF SUBSTR(p_version,-4,4) <> SUBSTR(p_batch_id,3,4) THEN
         p_message := 'IGF_GR_VRSN_MISMTCH';
     END IF;

END match_file_version;



FUNCTION get_min_disb_number (p_award_id igf_aw_award_all.award_id%TYPE)
RETURN NUMBER
IS
--
--
--
     CURSOR cur_min_disb (p_award_id igf_aw_award_all.award_id%TYPE)
     IS
     SELECT
     MIN(disb_num)
     FROM
     igf_aw_awd_disb
     WHERE
     award_id = p_award_id;

     ln_min_num  igf_aw_awd_disb_all.disb_num%TYPE;

BEGIN

     OPEN  cur_min_disb ( p_award_id );
     FETCH cur_min_disb INTO ln_min_num;
     CLOSE cur_min_disb ;

     RETURN ln_min_num;

EXCEPTION

WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_GEN.GET_MIN_DISB_NUMBER'|| ' ' || SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END get_min_disb_number;


FUNCTION get_rep_pell_from_ope(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                               p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                               p_ope_cd     igf_gr_report_pell.ope_cd%TYPE)
RETURN VARCHAR2
AS

CURSOR c_get_rep_pell_from_ope(cp_cal_type VARCHAR2,cp_seq_num NUMBER,cp_ope_cd VARCHAR2)
IS
  SELECT grp.reporting_pell_cd
    FROM
         igf_gr_report_pell grp
   WHERE
         grp.ci_cal_type        = cp_cal_type   AND
         grp.ci_sequence_number = cp_seq_num   AND
         grp.ope_cd             = cp_ope_cd;

l_rep_pell VARCHAR2(30):=NULL;

BEGIN

    OPEN c_get_rep_pell_from_ope(p_cal_type,p_seq_num,p_ope_cd);
    FETCH c_get_rep_pell_from_ope INTO l_rep_pell;
    IF (c_get_rep_pell_from_ope%NOTFOUND)
    THEN
        CLOSE c_get_rep_pell_from_ope;
        RETURN null;
    ELSE
        CLOSE c_get_rep_pell_from_ope;
        RETURN l_rep_pell;
    END IF;

END get_rep_pell_from_ope;

FUNCTION get_rep_pell_from_att(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                               p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                               p_att_pell   igf_gr_attend_pell.attending_pell_cd%TYPE)
RETURN VARCHAR2
AS

CURSOR c_get_rep_pell_from_att(cp_cal_type VARCHAR2,cp_seq_num NUMBER,cp_att_pell VARCHAR2)
IS
  SELECT grp.reporting_pell_cd
    FROM
         igf_gr_attend_pell gap,
         igf_gr_report_pell grp
   WHERE
         gap.ci_cal_type        = cp_cal_type AND
         gap.ci_sequence_number = cp_seq_num AND
         gap.attending_pell_cd  = cp_att_pell AND
         gap.rcampus_id         = grp.rcampus_id;

l_rep_pell VARCHAR2(30);

BEGIN

    OPEN c_get_rep_pell_from_att(p_cal_type,p_seq_num,p_att_pell);
    FETCH c_get_rep_pell_from_att INTO l_rep_pell;
    IF (c_get_rep_pell_from_att%NOTFOUND)
    THEN
        CLOSE c_get_rep_pell_from_att;
        RETURN null;
    ELSE
        CLOSE c_get_rep_pell_from_att;
        RETURN l_rep_pell;
    END IF;

END get_rep_pell_from_att;

FUNCTION get_rep_pell_from_base(p_cal_type   igs_ca_inst_all.cal_type%TYPE,
                                p_seq_num    igs_ca_inst_all.sequence_number%TYPE,
                                p_base_id NUMBER)
RETURN VARCHAR2
AS

l_office_cd     VARCHAR2(30);
l_return_status VARCHAR2(1);
l_msg_data      VARCHAR2(30);
l_rep_pell      VARCHAR2(30);

BEGIN

    igf_sl_gen.get_stu_fao_code(p_base_id,'PELL_ID',l_office_cd,l_return_status,l_msg_data);
    IF (l_return_status='E')
    THEN
        RETURN null;
    END IF;
    IF ((l_return_status ='S') AND (l_office_cd IS NOT NULL))
    THEN
        l_rep_pell := get_rep_pell_from_att(p_cal_type,p_seq_num,l_office_cd);
        RETURN l_rep_pell;
    END IF;

END get_rep_pell_from_base;

END igf_gr_gen;

/
