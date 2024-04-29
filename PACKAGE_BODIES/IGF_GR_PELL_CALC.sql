--------------------------------------------------------
--  DDL for Package Body IGF_GR_PELL_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_PELL_CALC" AS
/* $Header: IGFGR11B.pls 120.25 2006/08/25 05:56:02 veramach ship $ */

/*===================================================================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +===================================================================================================================+
 |                                                                                                                   |
 | DESCRIPTION                                                                                                       |
 |      PL/SQL spec for package: IGF_GR_PELL_CALC                                                                    |
 |                                                                                                                   |
 | NOTES                                                                                                             |
 |   New process that recomputes pell based on the Student Term Enrl                                                 |
 |   details.                                                                                                        |
 |   Package includes wrappers that calculate pell and will be called                                                |
 |   From the following places                                                                                       |
 | Student Awards Form / Student Disb Form / Packaging Process                                                       |
 | Single Fund Process / RFMS Originations.                                                                          |
 |                                                                                                                   |
 | HISTORY                                                                                                           |
 | museshad      31-May-2006  Bug 5254735. Following changes made in calc_pell and get_pell_attendance_type() -      |
 |                            1. If the no. of terms in COA + DP combination is more than the no. of Payment Periods |
 |                               setup in Pell Setup form, then an Err used to be thrown before, now it is a Warning |
 |                               message.                                                                            |
 |                            2. If the Pell award amount (cp_aid) is more than the Full time Pell amount, before an |
 |                               error message used to be thrown. This scenario cannot occur now. Term level         |
 |                               amt is reduced to be within the Full time Pell amount.                              |
 |                            3. If get_pell_attendance_type() fails to derive the ACTUAL attendance type for any of |
 |                               the terms in COA + DP combination, then calc_pell() would error out before.This has |
 |                                been changed to skip that term and award Pell by processing the remaining terms.   |
 | museshad      06-Mar-2006  Bug 5006587. Build FA 162. Adjust (+ or -) Term Start Date with Term Offset.           |
 |                            Changes made to get_pell_setup() and get_pell_attendance_type().                       |
 | museshad      08-Nov-2005  Bug 4624366. Added exception handler in get_pell_attendance_type, for the              |
 |                            Enrollment wrapper call igs_en_prc_load.enrp_get_inst_latt.                            |
 | museshad      12-Sep-2005  Build FA 157. Added the procedure round_term_disbursements to implement Pell           |
 |                            disbursement rounding.                                                                 |
 | museshad      13-Jul-2005  Build FA 157. Added the proocedure 'get_key_prog_ver' and other related changes        |
 |                            relating to deriving anticipated data.                                                 |
 | rasahoo       28-May-2004  Bug# 4396459 Repalced the table refference igf_gr_pell_rng_amt with igf_gr_reg_amts and|
 |               Repalced the table refference igf_gr_alt_coa with igf_gr_alt_amts.                                  |
 | cdcruz        28-Oct-2004  FA152 BUILD Modified  igf_aw_packng_subfns.get_fed_efc() as part of dependency         |
 | sjadhav       15-Oct-2004  Modified get_pell_setup for COD Entity ID                                              |
 | veramach      12-Dec-2003  Fixed issues with NVL                                                                  |
 | sjalasut      10 Dec, 2003 FA132 Changes.Removed get_current_enrl_term                                            |
 |               and replaced with igf_ap_gen_001.get_key_program                                                    |
 | cdcruz        06-Dec-2003  Creation of file                                                                       |
 |                                                                                                                   |
 *===================================================================================================================*/

NO_SETUP             EXCEPTION;

PROCEDURE get_pm_3_acad_term_wks(p_cal_type       igs_ca_inst_all.cal_type%TYPE,
                                 p_seq_number     igs_ca_inst_all.sequence_number%TYPE,
                                 p_course_cd      igs_en_psv_term_it.course_cd%TYPE,
                                 p_version_number igs_en_psv_term_it.version_number%TYPE,
                                 p_term_weeks     OUT NOCOPY NUMBER,
                                 p_acad_weeks     OUT NOCOPY NUMBER,
                                 p_result         OUT NOCOPY VARCHAR2,
                                 p_message        OUT NOCOPY VARCHAR2)
IS


CURSOR cur_get_anl_instr_time
IS
SELECT annual_instruction_time
FROM   igs_ps_ver_all
WHERE  course_cd      = p_course_cd
AND    version_number = p_version_number;

get_anl_instr_time_rec cur_get_anl_instr_time%ROWTYPE;

CURSOR cur_get_term_instr_time
IS
SELECT term_instruction_time
FROM   igs_en_psv_term_it
WHERE  cal_type        = p_cal_type
AND    sequence_number = p_seq_number
AND    course_cd       = p_course_cd
AND    version_number  = p_version_number;

get_term_instr_time_rec cur_get_term_instr_time%ROWTYPE;

CURSOR cur_get_term_time
IS
SELECT
term_instruction_time
FROM
igs_ca_inst_all
WHERE
cal_type        = p_cal_type AND
sequence_number = p_seq_number;

get_term_time_rec cur_get_term_time%ROWTYPE;

BEGIN

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pm_3_acad_term_wks.debug',
                                           'In Params  - > p_cal_type -> p_seq_number -> p_course_cd -> p_course_cd '
                                         || ' -> ' || p_cal_type
                                         || ' -> ' || p_seq_number
                                         || ' -> ' || p_course_cd
                                         || ' -> ' || p_course_cd);
 END IF;

 p_acad_weeks := NULL;
 p_term_weeks := NULL;

 OPEN  cur_get_anl_instr_time;
 FETCH cur_get_anl_instr_time INTO get_anl_instr_time_rec;
 CLOSE cur_get_anl_instr_time;

 p_acad_weeks := get_anl_instr_time_rec.annual_instruction_time;

 --
 -- If acad weeks is NULL or ZERO then return with error
 --
 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pm_3_acad_term_wks.debug',
                                           'Prog Level Weeks - > p_acad_weeks '
                                        || ' -> ' || p_acad_weeks);
 END IF;

 IF p_acad_weeks IS NULL THEN
   fnd_message.set_name( 'IGF','IGF_AW_NO_ANNL_INST_TIME');
   fnd_message.set_token('PROGRAM_CODE',p_course_cd);
   fnd_message.set_token('VERSION_NUM',p_version_number);
   p_message := fnd_message.get ;
   p_result  := 'E' ;
   RETURN;
 ELSIF p_acad_weeks = 0 THEN
   fnd_message.set_name( 'IGF','IGF_AW_ZERO_ANNL_TIME');
   fnd_message.set_token('PROGRAM_CODE',p_course_cd);
   fnd_message.set_token('VERSION_NUM',p_version_number);
   p_message := fnd_message.get ;
   p_result  := 'E' ;
   RETURN;
 END IF;

 --
 -- Open the Program Level Override
 --
 OPEN  cur_get_term_instr_time;
 FETCH cur_get_term_instr_time INTO get_term_instr_time_rec;
 CLOSE cur_get_term_instr_time;

 p_term_weeks := get_term_instr_time_rec.term_instruction_time;

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pm_3_acad_term_wks.debug',
                                           'Term Level Prog Overd Weeks - > p_term_weeks '
                                        || ' -> ' || p_term_weeks);
 END IF;

 IF p_term_weeks = 0 THEN
   fnd_message.set_name('IGF','IGF_AW_ZERO_TERM_ACAD_TIME');
   fnd_message.set_token('PROGRAM_CODE',p_course_cd);
   fnd_message.set_token('VERSION_NUM',p_version_number);
   fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_cal_type,p_seq_number));
   p_message := fnd_message.get;
   p_result  := 'E';
   RETURN;
 END IF;

 IF p_term_weeks IS NULL THEN
 --
 -- Open term level cursor
 --
  OPEN cur_get_term_time;
  FETCH cur_get_term_time INTO get_term_time_rec;
  CLOSE cur_get_term_time;

  p_term_weeks :=  get_term_time_rec.term_instruction_time;

  IF p_term_weeks IS NULL THEN
    fnd_message.set_name('IGF','IGF_AW_NO_TERM_INST_TIME');
    fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_cal_type,p_seq_number));
    p_message := fnd_message.get;
    p_result  := 'E';
  ELSIF p_term_weeks = 0 THEN
    fnd_message.set_name('IGF','IGF_AW_ZERO_TERM_TIME');
    fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_cal_type,p_seq_number));
    p_message := fnd_message.get;
    p_result  := 'E';
  END IF;
 END IF;

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pm_3_acad_term_wks.debug',
                                           'Term Level Weeks - > p_term_weeks '
                                        || ' -> ' || p_term_weeks);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_GR_PELL_CALC.GET_PM_3_ACAD_TERM_WKS '||SQLERRM);
     igs_ge_msg_stack.add;
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.get_pm_3_acad_term_wks.exception',
                                               'sql error message: '||SQLERRM);
     END IF;
     app_exception.raise_exception;

END get_pm_3_acad_term_wks;

PROCEDURE get_key_prog_ver_frm_adm(
                                    p_base_id      IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_key_prog_cd  OUT NOCOPY   igs_ps_ver.course_cd%TYPE,
                                    p_key_prog_ver OUT NOCOPY   igs_ps_ver.version_number%TYPE
                                  )
IS
  /*
  ||  Created By :  museshad
  ||  Created On :  13-Jul-2005
  ||  Purpose    :  This procedure is called, when actual (Enrollment) key program data
  ||                is not available. Key program is got by looking in this order -
  ||                1)  Enrollment data (Actual)
  ||                2)  Admissions data
  ||                3)  FA Anticipated data
  ||                This procedure implements 2
  ||                For Admissions, the Key program data is considered only if the
  ||                Student has just one Admission application.
  */
  CURSOR c_get_prog_frm_adm
  IS
      SELECT
            adm.course_cd key_prog,
            adm.crv_version_number key_prog_ver
      FROM
            igs_ad_ps_appl_inst_all adm,
            igs_ad_ou_stat s_adm_st,
            igf_ap_fa_base_rec_all fabase
      WHERE
            adm.person_id = fabase.person_id AND
            fabase.base_id = p_base_id AND
            adm.adm_outcome_status = s_adm_st.adm_outcome_status  AND
            s_adm_st.s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
            adm.course_cd IS NOT NULL AND
            1 = (SELECT COUNT(person_id)
                 FROM igs_ad_ps_appl_inst_all adm1, igs_ad_ou_stat s_adm_st1
                 WHERE
                      adm1.person_id = adm.person_id AND
                      adm1.adm_outcome_status = s_adm_st1.adm_outcome_status AND
                      s_adm_st1.s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
                      adm1.course_cd IS NOT NULL);

  l_adm_rec c_get_prog_frm_adm%ROWTYPE;
BEGIN

  p_key_prog_cd   :=  NULL;
  p_key_prog_ver  :=  NULL;

  OPEN c_get_prog_frm_adm;
  FETCH c_get_prog_frm_adm INTO l_adm_rec;

  IF (c_get_prog_frm_adm%FOUND) THEN
    p_key_prog_cd   :=  l_adm_rec.key_prog;
    p_key_prog_ver  :=  l_adm_rec.key_prog_ver;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.get_key_prog_ver_frm_adm.debug', 'Getting key program details from Admissions. Key program: ' ||p_key_prog_cd|| ', Version: ' ||p_key_prog_ver);
    END IF;
  END IF;

  CLOSE c_get_prog_frm_adm;
END get_key_prog_ver_frm_adm;

PROCEDURE get_pell_setup ( cp_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                           cp_course_cd       IN igf_gr_pell_setup_all.course_cd%TYPE,
                           cp_version_number  IN igf_gr_pell_setup_all.version_number%TYPE,
                           cp_cal_type        IN igs_ca_inst.cal_type%TYPE,
                           cp_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                           cp_pell_setup_rec  IN OUT NOCOPY igf_gr_pell_setup_all%ROWTYPE ,
                           cp_message         OUT NOCOPY VARCHAR2,
                           cp_return_status   OUT NOCOPY VARCHAR2
                           )
 IS
  /*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to get Pell Setup Details
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id / primary program and calendar
  ||  and returns the Pell Setup record.
  ||
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        05-Apr-2006     While deriving Pell default setup course_cd
  ||                                  and version_number should be checked for NULL.
  ||                                  Fixed this.
  ||  museshad        06-Mar-2006     Bug 5006587. Build FA 162 - COD Reg Updates.
  ||                                  Added override for the newly introduced column
  ||                                  term_start_offset_num
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
  */

   CURSOR c_get_rep_pell_id(
      l_cal_type                          igs_ca_inst.cal_type%TYPE,
      l_seq_num                           igs_ca_inst.sequence_number%TYPE,
      l_att_pell_id                       igf_gr_pell_setup_all.rep_pell_id%TYPE
   )
   IS
      SELECT rep.reporting_pell_cd
        FROM igf_gr_attend_pell gap, igf_gr_report_pell rep
       WHERE gap.ci_cal_type = l_cal_type
         AND gap.ci_sequence_number = l_seq_num
         AND gap.attending_pell_cd = l_att_pell_id
         AND gap.rcampus_id = rep.rcampus_id;

   CURSOR c_pell_setup(
      l_ci_cal_type                       igf_aw_fund_mast.ci_cal_type%TYPE,
      l_ci_sequence_number                igf_aw_fund_mast.ci_sequence_number%TYPE,
      l_reporting_pell_id                 igf_gr_pell_setup.rep_pell_id%TYPE,
      l_course_cd                         igf_gr_pell_setup.course_cd%TYPE,
      l_version_number                    igf_gr_pell_setup.version_number%TYPE
   )
   IS
      SELECT pell.*
        FROM igf_gr_pell_setup_all pell
       WHERE pell.ci_cal_type = l_ci_cal_type
         AND pell.ci_sequence_number = l_ci_sequence_number
         AND pell.rep_pell_id = l_reporting_pell_id
         AND pell.course_cd = l_course_cd
         AND pell.version_number = l_version_number;

   CURSOR c_pell_def_setup(
      l_ci_cal_type                       igf_aw_fund_mast.ci_cal_type%TYPE,
      l_ci_sequence_number                igf_aw_fund_mast.ci_sequence_number%TYPE,
      l_reporting_pell_id                 igf_gr_pell_setup.rep_pell_id%TYPE
   )
   IS
      SELECT pell.*
        FROM igf_gr_pell_setup_all pell
       WHERE pell.ci_cal_type = l_ci_cal_type
         AND pell.ci_sequence_number = l_ci_sequence_number
         AND pell.rep_pell_id = l_reporting_pell_id
         AND pell.course_cd IS NULL
         AND pell.version_number IS NULL;

   l_attend_pell_id              igf_gr_report_pell.reporting_pell_cd%TYPE;
   l_rep_pell_id                 igf_gr_attend_pell.attending_pell_cd%TYPE;
   l_ret_status                  VARCHAR2(30);
   l_msg_data                    VARCHAR2(30);
   l_stu_num                     VARCHAR2(30);
   l_ovrd_setup_rec              igf_gr_pell_setup_all%ROWTYPE;


-- Entity ID declarations
   CURSOR c_get_rep_entity_id_txt(
      l_cal_type                          igs_ca_inst.cal_type%TYPE,
      l_seq_num                           igs_ca_inst.sequence_number%TYPE,
      l_atd_entity_id                     igf_gr_attend_pell.atd_entity_id_txt%TYPE
   )
   IS
      SELECT rep.rep_entity_id_txt
        FROM igf_gr_attend_pell gap, igf_gr_report_pell rep
       WHERE gap.ci_cal_type = l_cal_type
         AND gap.ci_sequence_number = l_seq_num
         AND gap.atd_entity_id_txt = l_atd_entity_id
         AND gap.rcampus_id = rep.rcampus_id;

   CURSOR c_pell_def_setup_cod(
      l_ci_cal_type                       igf_aw_fund_mast_all.ci_cal_type%TYPE,
      l_ci_sequence_number                igf_aw_fund_mast_all.ci_sequence_number%TYPE,
      l_rep_entity_id                     igf_gr_pell_setup_all.rep_entity_id_txt%TYPE
   )
   IS
      SELECT pell.*
        FROM igf_gr_pell_setup_all pell
       WHERE pell.ci_cal_type = l_ci_cal_type
         AND pell.ci_sequence_number = l_ci_sequence_number
         AND pell.rep_entity_id_txt = l_rep_entity_id
         AND pell.course_cd IS NULL
         AND pell.version_number IS NULL;

   CURSOR c_pell_ovrd_setup_cod(
      l_ci_cal_type                       igf_aw_fund_mast_all.ci_cal_type%TYPE,
      l_ci_sequence_number                igf_aw_fund_mast_all.ci_sequence_number%TYPE,
      l_rep_entity_id                     igf_gr_pell_setup_all.rep_entity_id_txt%TYPE,
      l_course_cd                         igf_gr_pell_setup_all.course_cd%TYPE,
      l_version_number                    igf_gr_pell_setup_all.version_number%TYPE
   )
   IS
      SELECT pell.*
        FROM igf_gr_pell_setup_all pell
       WHERE pell.ci_cal_type = l_ci_cal_type
         AND pell.ci_sequence_number = l_ci_sequence_number
         AND pell.rep_entity_id_txt = l_rep_entity_id
         AND pell.course_cd = l_course_cd
         AND pell.version_number = l_version_number;

   l_atd_entity_id_txt           igf_gr_report_pell.rep_entity_id_txt%TYPE;
   l_rep_entity_id_txt           igf_gr_attend_pell.atd_entity_id_txt%TYPE;
   lb_cod_year                   BOOLEAN;

BEGIN

   lb_cod_year := igf_sl_dl_validation.check_full_participant(
                     cp_cal_type,
                     cp_sequence_number,
                     'PELL'
                  );

   IF lb_cod_year
   THEN -- cod year
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',' COD Year');
     END IF;

      l_atd_entity_id_txt := NULL;
      l_rep_entity_id_txt := NULL;

-- Get attending Pell Id from Org Setup.
      igf_sl_gen.get_stu_fao_code(
         p_base_id                     => cp_base_id,
         p_office_type                 => 'ENTITY_ID',
         x_office_cd                   => l_atd_entity_id_txt,
         x_return_status               => l_ret_status,
         x_msg_data                    => l_msg_data
      );

      IF (l_ret_status = 'E')
      THEN
        --get attending pell id from anticipated data
        igf_sl_gen.get_stu_ant_fao_code(
           p_base_id                     => cp_base_id,
           p_office_type                 => 'ENTITY_ID',
           x_office_cd                   => l_atd_entity_id_txt,
           x_return_status               => l_ret_status,
           x_msg_data                    => l_msg_data
        );
        IF l_ret_status = 'E' THEN
          cp_return_status := l_ret_status;
          fnd_message.set_name('IGF', 'IGF_GR_NO_ATTEND_ENTITY_ID');
          cp_message := fnd_message.get;
          RETURN;
        END IF;
      END IF;

      IF ((l_ret_status = 'S') AND (l_atd_entity_id_txt IS NOT NULL))
      THEN

-- Derive the report pell ID.
         OPEN c_get_rep_entity_id_txt(
            cp_cal_type,
            cp_sequence_number,
            l_atd_entity_id_txt
         );
         FETCH c_get_rep_entity_id_txt INTO l_rep_entity_id_txt;
         CLOSE c_get_rep_entity_id_txt;
      END IF;

      IF (l_rep_entity_id_txt IS NULL)
      THEN
         l_stu_num := igf_gr_gen.get_per_num(cp_base_id);
         fnd_message.set_name('IGF', 'IGF_GR_NOREP_ENTITY');
         fnd_message.set_token('STU_NUMBER', l_stu_num);
         cp_message := fnd_message.get;
         cp_return_status := 'E';
         RETURN;
      END IF;

      cp_pell_setup_rec := NULL;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',' COD Year l_rep_entity_id_txt ' || l_rep_entity_id_txt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',' COD Year l_atd_entity_id_txt ' || l_atd_entity_id_txt);
     END IF;

-- Retrieve the Default Pell Setup values
      OPEN c_pell_def_setup_cod(
         cp_cal_type,
         cp_sequence_number,
         l_rep_entity_id_txt
      );
      FETCH c_pell_def_setup_cod INTO cp_pell_setup_rec;

      IF c_pell_def_setup_cod%NOTFOUND
      THEN
         CLOSE c_pell_def_setup_cod;
         cp_return_status := 'E';
         fnd_message.set_name('IGF', 'IGF_GR_NO_PELL_SETUP_COD');
         fnd_message.set_token('REP_ENTITY_ID_TXT', l_rep_entity_id_txt);
         cp_message := fnd_message.get;
         RETURN;
      END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',' COD Year cp_pell_setup_rec.pell_seq_id ' || cp_pell_setup_rec.pell_seq_id);
     END IF;

      CLOSE c_pell_def_setup_cod;

-- Retrieve Program Level Setup if Any
      OPEN c_pell_ovrd_setup_cod(
         cp_cal_type,
         cp_sequence_number,
         l_rep_entity_id_txt,
         cp_course_cd,
         cp_version_number
      );
      FETCH c_pell_ovrd_setup_cod INTO l_ovrd_setup_rec;
      CLOSE c_pell_ovrd_setup_cod;

      IF l_ovrd_setup_rec.rep_pell_id IS NOT NULL
      THEN
         -- Overridden setup exist hence use the Overidden fields
         -- Populate the Non Default Values.
         -- Not not all fields can be overridden , hence individually the columns are replaced
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',' COD Year l_ovrd_setup_rec.rep_pell_id ' || l_ovrd_setup_rec.rep_pell_id);
         END IF;

         cp_pell_setup_rec.academic_cal := l_ovrd_setup_rec.academic_cal;
         cp_pell_setup_rec.payment_method := l_ovrd_setup_rec.payment_method;
         cp_pell_setup_rec.wk_inst_time_calc_pymt := l_ovrd_setup_rec.wk_inst_time_calc_pymt;
         cp_pell_setup_rec.wk_int_time_prg_def_yr := l_ovrd_setup_rec.wk_int_time_prg_def_yr;
         cp_pell_setup_rec.cr_clk_hrs_prds_sch_yr := l_ovrd_setup_rec.cr_clk_hrs_prds_sch_yr;
         cp_pell_setup_rec.cr_clk_hrs_acad_yr := l_ovrd_setup_rec.cr_clk_hrs_acad_yr;
         cp_pell_setup_rec.payment_periods_num := l_ovrd_setup_rec.payment_periods_num;
         cp_pell_setup_rec.enr_before_ts_code := l_ovrd_setup_rec.enr_before_ts_code;
         cp_pell_setup_rec.enr_in_mt_code := l_ovrd_setup_rec.enr_in_mt_code;
         cp_pell_setup_rec.enr_after_tc_code := l_ovrd_setup_rec.enr_after_tc_code;
         cp_pell_setup_rec.pell_seq_id := l_ovrd_setup_rec.pell_seq_id;
         cp_pell_setup_rec.term_start_offset_num := l_ovrd_setup_rec.term_start_offset_num; -- museshad (Bug 5006587 - FA 162)
      END IF;
   ELSE -- phase-in award year

      l_attend_pell_id := NULL;
      l_rep_pell_id := NULL;
      -- Get attending Pell Id from Org Setup.
      igf_sl_gen.get_stu_fao_code(
         p_base_id                     => cp_base_id,
         p_office_type                 => 'PELL_ID',
         x_office_cd                   => l_attend_pell_id,
         x_return_status               => l_ret_status,
         x_msg_data                    => l_msg_data
      );

      IF (l_ret_status = 'E')
      THEN
        --try to get anticipated pell id
        igf_sl_gen.get_stu_ant_fao_code(
           p_base_id                     => cp_base_id,
           p_office_type                 => 'PELL_ID',
           x_office_cd                   => l_attend_pell_id,
           x_return_status               => l_ret_status,
           x_msg_data                    => l_msg_data
        );
        IF l_ret_status = 'E' THEN
          cp_return_status := l_ret_status;
          fnd_message.set_name('IGF', 'IGF_GR_NO_ATTEND_PELL');
          cp_message := fnd_message.get;
          RETURN;
        END IF;
      END IF;

      IF ((l_ret_status = 'S') AND (l_attend_pell_id IS NOT NULL))
      THEN
         -- Derive the report pell ID.
         OPEN c_get_rep_pell_id(
            cp_cal_type,
            cp_sequence_number,
            l_attend_pell_id
         );
         FETCH c_get_rep_pell_id INTO l_rep_pell_id;
         CLOSE c_get_rep_pell_id;
      END IF;

      IF (l_rep_pell_id IS NULL)
      THEN
         l_stu_num := igf_gr_gen.get_per_num(cp_base_id);
         fnd_message.set_name('IGF', 'IGF_GR_NOREP_PELL');
         fnd_message.set_token('STU_NUMBER', l_stu_num);
         cp_message := fnd_message.get;
         cp_return_status := 'E';
         RETURN;
      END IF;

      cp_pell_setup_rec := NULL;
      -- Retrieve the Default Pell Setup values
      OPEN c_pell_def_setup(cp_cal_type, cp_sequence_number, l_rep_pell_id);
      FETCH c_pell_def_setup INTO cp_pell_setup_rec;

      IF c_pell_def_setup%NOTFOUND
      THEN
         CLOSE c_pell_def_setup;
         cp_return_status := 'E';
         fnd_message.set_name('IGF', 'IGF_GR_NO_PELL_SETUP');
         fnd_message.set_token('REP_PELL_ID', l_rep_pell_id);
         cp_message := fnd_message.get;
         RETURN;
      END IF;

      CLOSE c_pell_def_setup;
      -- Retrieve Program Level Setup if Any
      OPEN c_pell_setup(
         cp_cal_type,
         cp_sequence_number,
         l_rep_pell_id,
         cp_course_cd,
         cp_version_number
      );
      FETCH c_pell_setup INTO l_ovrd_setup_rec;
      CLOSE c_pell_setup;

      IF l_ovrd_setup_rec.rep_pell_id IS NOT NULL
      THEN
         -- Overridden setup exist hence use the Overidden fields
         -- Populate the Non Default Values.
         -- Not not all fields can be overridden , hence individually the columns are replaced

         cp_pell_setup_rec.academic_cal := l_ovrd_setup_rec.academic_cal;
         cp_pell_setup_rec.payment_method := l_ovrd_setup_rec.payment_method;
         cp_pell_setup_rec.wk_inst_time_calc_pymt := l_ovrd_setup_rec.wk_inst_time_calc_pymt;
         cp_pell_setup_rec.wk_int_time_prg_def_yr := l_ovrd_setup_rec.wk_int_time_prg_def_yr;
         cp_pell_setup_rec.cr_clk_hrs_prds_sch_yr := l_ovrd_setup_rec.cr_clk_hrs_prds_sch_yr;
         cp_pell_setup_rec.cr_clk_hrs_acad_yr := l_ovrd_setup_rec.cr_clk_hrs_acad_yr;
         cp_pell_setup_rec.payment_periods_num := l_ovrd_setup_rec.payment_periods_num;
         cp_pell_setup_rec.enr_before_ts_code := l_ovrd_setup_rec.enr_before_ts_code;
         cp_pell_setup_rec.enr_in_mt_code := l_ovrd_setup_rec.enr_in_mt_code;
         cp_pell_setup_rec.enr_after_tc_code := l_ovrd_setup_rec.enr_after_tc_code;
         cp_pell_setup_rec.pell_seq_id := l_ovrd_setup_rec.pell_seq_id;
         cp_pell_setup_rec.term_start_offset_num := l_ovrd_setup_rec.term_start_offset_num; -- museshad (Bug 5006587 - FA 162)
      END IF;
   END IF; -- cod year

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
   THEN
      fnd_log.STRING(
         fnd_log.level_statement,
         'igf.plsql.igf_gr_pell_calc.get_pell_setup.debug',
            'Pell Setup -> Rep_pell_id->'
         || cp_pell_setup_rec.rep_pell_id
         || ' Base_id->'
         || TO_CHAR(cp_base_id)
         || ' ProgCode/Ver ->'
         || cp_pell_setup_rec.course_cd
         || '/'
         || TO_CHAR(cp_pell_setup_rec.version_number)
      );
   END IF;

   IF      cp_pell_setup_rec.payment_method IN ('1', '2')
       AND NVL(cp_pell_setup_rec.payment_periods_num, 0) = 0
   THEN
      cp_return_status := 'E';
      fnd_message.set_name('IGF', 'IGF_GR_INVALID_PYMNT_PRD');
      cp_message := fnd_message.get;
      RETURN;
   END IF;

   cp_return_status := 'S';
   cp_message := NULL;
   RETURN;

EXCEPTION
   WHEN OTHERS
   THEN
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token(
         'NAME',
         'igf_gr_pell_calc.get_pell_setup ' || SQLERRM
      );
      igs_ge_msg_stack.ADD;

      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING(
            fnd_log.level_exception,
            'igf.plsql.igf_gr_pell_calc.get_pell_setup.exception',
            'sql error message: ' || SQLERRM
         );
      END IF;
      app_exception.raise_exception;
 END get_pell_setup;


  PROCEDURE get_pell_coa_efc (cp_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE,
                               cp_attendance_type    IN  igf_ap_attend_map.attendance_type%TYPE,
                               cp_pell_setup_rec     IN  igf_gr_pell_setup_all%ROWTYPE ,
                               cp_coa                OUT NOCOPY NUMBER,
                               cp_efc                OUT NOCOPY NUMBER,
                               cp_pell_schedule_code OUT NOCOPY VARCHAR2,
                               cp_message            OUT NOCOPY VARCHAR2,
                               cp_return_status      OUT NOCOPY VARCHAR2
                             )
  IS
  /*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to get the pell Cost of Attendance and EFC
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id / Attendance type / Pell Setup Record
  ||  and returns the Pell COA / EFC / Pell Schedule used.
  ||
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
  */

  CURSOR c_lt_ht_coa (l_base_id NUMBER)
  IS
  SELECT
    NVL(SUM(aci.pell_coa_amount),0) reg_pell_coa,
    NVL(SUM(aci.alt_pell_amount),0) alt_pell_coa
  FROM   igf_aw_coa_items aci,
         igf_aw_item  ai
  WHERE  aci.base_id   = l_base_id
  AND    aci.item_code = ai.item_code
  AND    ai.item_category_code IN ('TUITION','BOOKS','FEES','TRANSPORTATION','SUPPLIES','DEPENDENT_CARE');

  c_lt_ht_coa_rec c_lt_ht_coa%ROWTYPE;


  CURSOR c_pell_coa (l_base_id NUMBER)
  IS
  SELECT
    NVL(SUM(aci.pell_coa_amount),0) reg_pell_coa,
    NVL(SUM(aci.alt_pell_amount),0) alt_pell_coa
  FROM   igf_aw_coa_items aci
  WHERE  aci.base_id = l_base_id;


   c_pell_coa_rec c_pell_coa%ROWTYPE;

   ln_reg_coa   NUMBER;
   ln_alt_coa   NUMBER;
   ln_efc       NUMBER;
   ln_pell_efc  NUMBER;

  BEGIN

    -- Retrieve his COA.
    IF cp_attendance_type = '4' THEN
      --Less Than Half Time

      OPEN c_lt_ht_coa(cp_base_id) ;
      FETCH c_lt_ht_coa INTO c_lt_ht_coa_rec;
      CLOSE c_lt_ht_coa;

      ln_reg_coa := c_lt_ht_coa_rec.REG_PELL_COA ;
      ln_alt_coa := c_lt_ht_coa_rec.ALT_PELL_COA ;

    ELSE
      -- Not less than half time

      OPEN c_pell_coa(cp_base_id) ;
      FETCH c_pell_coa INTO c_pell_coa_rec ;
      CLOSE c_pell_coa ;

      ln_reg_coa := c_pell_coa_rec.REG_PELL_COA ;
      ln_alt_coa := c_pell_coa_rec.ALT_PELL_COA ;

    END IF;

    --- Get Pell EFC
      igf_aw_packng_subfns.get_fed_efc(
                                       l_base_id      => cp_base_id,
                                       l_awd_prd_code => NULL,
                                       l_efc_f        => ln_efc,
                                       l_pell_efc     => ln_pell_efc,
                                       l_efc_ay       => ln_efc
                                       );

       IF  ln_alt_coa   <= cp_pell_setup_rec.pell_alt_exp_max  AND
           ln_pell_efc  <= cp_pell_setup_rec.efc_max          AND
           ln_reg_coa   >= cp_pell_setup_rec.alt_coa_limit     THEN
           cp_pell_schedule_code := 'A';
           cp_coa := ln_reg_coa ;
       ELSE
           cp_pell_schedule_code := 'R';
           cp_coa := ln_reg_coa ;
       END IF;

       cp_efc := ln_pell_efc ;
       cp_return_status := 'S' ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_coa_efc.debug',
                                              'Pell EFC  -> Pell Reg COA -> Pell Alt COA -> Pell Matrix -> '
                                              || cp_efc ||' -> '||ln_reg_coa||' -> '||ln_alt_coa||' -> '||cp_pell_schedule_code);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.get_pell_coa_efc '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.get_pell_coa_efc.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

  END get_pell_coa_efc;

  PROCEDURE get_pell_attendance_type (
                                cp_base_id             IN igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_ld_cal_type         IN igs_ca_inst.cal_type%TYPE,
                                cp_ld_sequence_number  IN igs_ca_inst.sequence_number%TYPE,
                                cp_pell_setup_rec      IN  igf_gr_pell_setup_all%ROWTYPE ,
                                cp_attendance_type     IN OUT NOCOPY igf_ap_attend_map.attendance_type%TYPE,
                                cp_message             OUT NOCOPY VARCHAR2,
                                cp_return_status       OUT NOCOPY VARCHAR2
                             )
  IS
  /*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to get Pell attendance type
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id / load calendar in context
  ||  and returns the Pell attendance type based on the setup
  ||
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        06-Mar-2006     Bug 5006587. Build FA 162.
  ||                                  Adjust (+ or -) Term Start Date with Term Offset
  ||  museshad        08-Nov-2005     Bug 4624366
  ||                                  The Enrollment wrapper igs_en_prc_load.enrp_get_inst_latt
  ||                                  throws an App exception when there is no Key program.
  ||                                  Handled this.
  ||  bkkumar         23-Mar-2004     Bug 3512319 Removed the hard coded base_id in the c_nominated cursor.
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
  */

   p_ld_start_dt DATE;
   p_ld_end_dt   DATE;
   p_ld_start_dt_offset DATE;

   CURSOR c_isir ( l_base_id NUMBER )
   IS
   SELECT
     summ_enrl_status
   FROM igf_ap_isir_matched isir
   WHERE
    isir.base_id = l_base_id AND
    isir.active_isir = 'Y' ;

  CURSOR c_nominated ( l_base_id NUMBER )
  IS
  SELECT
   pell.pell_att_code attendance_type
  FROM
   igs_en_stdnt_ps_att en,
   igf_ap_fa_base_rec fa,
   igf_ap_attend_map pell
  WHERE
   fa.base_id = l_base_id AND
   fa.person_id = en.person_id AND
   en.key_program = 'Y'    AND
   pell.cal_type = fa.ci_cal_type AND
   pell.sequence_number = fa.ci_sequence_number AND
   en.attendance_type = pell.attendance_type ;

   CURSOR c_fabase ( l_base_id NUMBER)
   IS
     SELECT
      person_id ,
      ci_cal_type,
      ci_sequence_number
   FROM
     igf_ap_fa_base_rec_all  fa
   WHERE
     fa.base_id = l_base_id;

   l_fabase_rec c_fabase%ROWTYPE;

  l_program_cd      igs_en_stdnt_ps_att.course_cd%TYPE;
  l_program_version igs_en_stdnt_ps_att.version_number%TYPE;
  l_attendance_type igs_en_atd_type_load.attendance_type%TYPE ;
  l_credit_pts igs_en_su_attempt.override_achievable_cp%TYPE ;
  l_fte igs_en_su_attempt.override_achievable_cp%TYPE ;

  l_effctive_cens_dt DATE;
  l_enrl_mode igf_gr_pell_setup.enr_in_mt_code%TYPE;


   CURSOR c_get_pell_att(
                       l_att_type igf_ap_attend_map_all.attendance_type%TYPE,
                       l_cal_type igf_ap_attend_map_all.cal_type%TYPE,
                       l_sequence_number igf_ap_attend_map_all.sequence_number%TYPE)
    IS
    SELECT
      pell.pell_att_code attendance_type
    FROM
      igf_ap_attend_map pell
    WHERE
      pell.cal_type        = l_cal_type AND
      pell.sequence_number = l_sequence_number AND
      pell.attendance_type = l_att_type;

  CURSOR c_chk_enr(cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE)
  IS
    SELECT  'X'
    FROM    igs_en_stdnt_ps_att
    WHERE   person_id = cp_person_id;
  l_chk_enr_rec c_chk_enr%ROWTYPE;

  CURSOR c_get_ant_atype(
                         cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                         cp_ld_cal_type        igs_ca_inst_all.cal_type%TYPE,
                         cp_ld_sequence_number igs_ca_inst_all.sequence_number%TYPE
                        ) IS
    SELECT pell.pell_att_code attendance_type
      FROM igf_ap_fa_ant_data ant,
           igf_ap_attend_map pell,
           igf_ap_fa_base_rec_all fa
     WHERE fa.base_id             = cp_base_id
       AND ant.ld_cal_type        = cp_ld_cal_type
       AND ant.ld_sequence_number = cp_ld_sequence_number
       AND pell.attendance_type   = ant.attendance_type
       AND pell.cal_type          = fa.ci_cal_type
       AND pell.sequence_number   = fa.ci_sequence_number
       AND fa.base_id             = ant.base_id;

  l_app  VARCHAR2(50);
  l_name VARCHAR2(30);
  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Before call to IGS_EN_GEN_015.GET_EFFECTIVE_CENSUS_DATE');
    END IF;

  -- Get the Effective census date
  l_effctive_cens_dt := IGS_EN_GEN_015.GET_EFFECTIVE_CENSUS_DATE (
                          P_LOAD_CAL_TYPE           => cp_ld_cal_type,
                          P_LOAD_CAL_SEQ_NUMBER     => cp_ld_sequence_number,
                          P_TEACH_CAL_TYPE          => NULL,
                          P_TEACH_CAL_SEQ_NUMBER    => NULL
                          );

  IF l_effctive_cens_dt IS NULL THEN
    cp_return_status := 'E';
    fnd_message.set_name('IGF','IGF_AW_EN_LD_STDA');
    fnd_message.set_token('LD_CI_ALT_CODE',igf_gr_gen.get_alt_code(cp_ld_cal_type,cp_ld_sequence_number));
    cp_message := fnd_message.get ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Error deriving Effective Census Date');
    END IF;

    RETURN;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Effective Census Date:' ||l_effctive_cens_dt);
  END IF;

  p_ld_start_dt := NULL;
  p_ld_end_dt   := NULL;
  p_ld_start_dt_offset := NULL;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','deriving start/end dates for '||
                                           'base_id:'||cp_base_id||
                                           'ld_cal_type:'||cp_ld_cal_type||
                                           'ld_sequence_number:'||cp_ld_sequence_number);
  END IF;
  igf_ap_gen_001.get_term_dates(
                                p_base_id            => cp_base_id,
                                p_ld_cal_type        => cp_ld_cal_type,
                                p_ld_sequence_number => cp_ld_sequence_number,
                                p_ld_start_date      => p_ld_start_dt,
                                p_ld_end_date        => p_ld_end_dt
                               );

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','p_ld_start_dt:'||p_ld_start_dt);
  END IF;

  IF p_ld_start_dt IS NULL THEN
    cp_return_status := 'E';
    fnd_message.set_name('IGF','IGF_AW_INV_START_DT');
    fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(cp_ld_cal_type,cp_ld_sequence_number));
    cp_message := fnd_message.get ;
    RETURN;
  END IF;

  -- museshad (Bug 5006587 - Build FA 162). Adjust (+ or -) term start date with term offset. Use the new term start date to determine l_enrl_mode.
  p_ld_start_dt_offset := p_ld_start_dt + NVL(cp_pell_setup_rec.term_start_offset_num, 0);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Term Offset: ' ||NVL(cp_pell_setup_rec.term_start_offset_num, 0));
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Term Start date with term offset: ' ||p_ld_start_dt_offset);
  END IF;
  -- museshad (Bug 5006587 - Build FA 162)

  IF SYSDATE < p_ld_start_dt_offset THEN
     -- Use Before Term Start Attendance Type
     l_enrl_mode := cp_pell_setup_rec.enr_before_ts_code ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Enrl Term Rule Used >Before Term Start'
                                             ||' for '||cp_ld_cal_type||'/'||cp_ld_sequence_number);
    END IF;

  ELSIF SYSDATE BETWEEN p_ld_start_dt_offset AND l_effctive_cens_dt THEN
     -- Use Mid Term Attendance Type
     l_enrl_mode := cp_pell_setup_rec.enr_in_mt_code ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Enrl Term Rule Used >Term In Progress'
                                             ||' for '||cp_ld_cal_type||'/'||cp_ld_sequence_number);
    END IF;

  ELSE
     -- Use After Census Attendance Type
     l_enrl_mode := cp_pell_setup_rec.enr_after_tc_code ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Enrl Term Rule Used >After Term Census'
                                             ||' for '||cp_ld_cal_type||'/'||cp_ld_sequence_number);
    END IF;

  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','value of l_enrl_mode >'|| l_enrl_mode
                                           ||' for '||cp_ld_cal_type||'/'||cp_ld_sequence_number);
  END IF;

-- Derive the Literal Value of the attendance Type

IF l_enrl_mode = 'FT' THEN
    cp_attendance_type := '1';

ELSIF l_enrl_mode = 'HT' THEN
    cp_attendance_type := '3';

ELSIF l_enrl_mode = 'TQT' THEN
    cp_attendance_type := '2';

ELSIF l_enrl_mode = 'LTHT' THEN
    cp_attendance_type := '4';

ELSIF l_enrl_mode = 'ANTICIPATED' THEN
   -- get the value from the Payment ISIR
   OPEN c_isir(cp_base_id);
   FETCH c_isir INTO cp_attendance_type ;
   IF c_isir%NOTFOUND THEN
          cp_return_status := 'E';
          fnd_message.set_name('IGF','IGF_SL_LI_NO_ACTIVE_ISIR');
          cp_message := fnd_message.get ;
          CLOSE c_isir;
          RETURN;
   ELSE
      CLOSE c_isir;
   END IF;

   IF (cp_attendance_type IS NULL) THEN
      cp_return_status := 'E';
      fnd_message.set_name('IGF','IGF_GR_ANTICIP_ATT_NOT_AVAIL');
      cp_message := fnd_message.get ;
      RETURN;
   END IF;

ELSIF  l_enrl_mode = 'PRG_NOMINATED' THEN
   -- get the primary programs Nominated Attendance Type
   cp_attendance_type := NULL;
   OPEN c_nominated ( cp_base_id);
   FETCH c_nominated INTO cp_attendance_type;
   CLOSE c_nominated;

   IF cp_attendance_type IS NULL THEN
      IF igf_aw_coa_gen.canUseAnticipVal THEN
        -- Get attendance type from FA anticipated data
        cp_attendance_type := NULL;
        OPEN c_get_ant_atype(
                              cp_base_id => cp_base_id,
                              cp_ld_cal_type => cp_ld_cal_type,
                              cp_ld_sequence_number => cp_ld_sequence_number
                            );
        FETCH c_get_ant_atype INTO cp_attendance_type;
        CLOSE c_get_ant_atype;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string( fnd_log.level_statement,
                            'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug',
                            'Attendance Type from FA anticipated data is '|| NVL(l_attendance_type, ''));
        END IF;
        IF cp_attendance_type IS NULL THEN
          cp_return_status := 'E';
          fnd_message.set_name('IGF','IGF_GR_NOM_ATT_NOT_EXIST');
          cp_message := fnd_message.get ;
          RETURN;
        END IF;
      ELSE
        cp_return_status := 'E';
        fnd_message.set_name('IGF','IGF_GR_NOM_ATT_NOT_EXIST');
        cp_message := fnd_message.get ;
        RETURN;
      END IF;
   END IF;

ELSIF   l_enrl_mode = 'ACTUAL' THEN
   -- get the Derived Attendance Type

  OPEN c_fabase ( cp_base_id);
  FETCH c_fabase INTO l_fabase_rec;
  CLOSE c_fabase;

  l_attendance_type := NULL;
  l_credit_pts      := NULL;
  l_fte             := NULL;

  OPEN c_chk_enr(cp_person_id => l_fabase_rec.person_id);
  FETCH c_chk_enr INTO l_chk_enr_rec;

  IF (c_chk_enr%FOUND) THEN
    BEGIN
      -- Get the derived attendnce type for the Context Term
      igs_en_prc_load.enrp_get_inst_latt(  p_person_id       => l_fabase_rec.person_id,
                                           p_load_cal_type   => cp_ld_cal_type,
                                           p_load_seq_number => cp_ld_sequence_number,
                                           p_attendance      => l_attendance_type,
                                           p_credit_points   => l_credit_pts,
                                           p_fte             => l_fte);
    EXCEPTION
      /*The above Enrollment wrapper can return an App exception (or)
      any unhandled exception.*/
      WHEN OTHERS THEN
        cp_message := fnd_message.get;
        IF cp_message IS NOT NULL THEN
          -- App Exception from Enrollment wrapper.
          -- We know how this needs to be handled.
          cp_return_status  :=  'E';
          RETURN;
        ELSE
          -- Unhandled Exception from Enrollment wrapper.
          -- We do not know how this needs to be handles, so raise it again.
          RAISE;
        END IF;
    END;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug','Attendance Type from the igs_en_prc_load.enrp_get_inst_latt api is '||NVL(l_attendance_type, ''));
    END IF;

  END IF;
  CLOSE c_chk_enr;

   IF l_attendance_type IS NULL THEN
     fnd_message.set_name('IGF','IGF_GR_NO_OSS_ATTEND');
     fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(cp_ld_cal_type,cp_ld_sequence_number));
     cp_message := fnd_message.get;
     cp_return_status := 'E';
     cp_attendance_type := 'XX';
     RETURN;
   END IF;

   -- Get the Pell Attendance Type
   OPEN c_get_pell_att(l_attendance_type,
                       l_fabase_rec.ci_cal_type,
                       l_fabase_rec.ci_sequence_number);

   FETCH c_get_pell_att INTO cp_attendance_type;
   IF c_get_pell_att%NOTFOUND THEN
    fnd_message.set_name('IGF','IGF_GR_PELL_ATT_NOT_EXIST');
    fnd_message.set_token('ATTEND_TYPE',NVL(l_attendance_type,'Null'));
    cp_message := fnd_message.get;
    cp_return_status := 'E' ;
    CLOSE c_get_pell_att;

    RETURN;
   END IF;
   CLOSE c_get_pell_att;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.debug',
                                              'cp_attendance_type  -> l_enrl_mode -> l_effctive_cens_dt -> '
                                              || cp_attendance_type ||' -> '||l_enrl_mode||' -> '||l_effctive_cens_dt);
    END IF;

END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.get_pell_attendance_type '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.get_pell_attendance_type.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

END get_pell_attendance_type;

PROCEDURE get_pell_matrix_amt(
                     cp_cal_type      IN igs_ca_inst.cal_type%TYPE,
                     cp_sequence_num  IN igs_ca_inst.sequence_number%TYPE,
                     cp_efc           IN NUMBER,
                     cp_pell_schd     IN VARCHAR2,
                     cp_enrl_stat     IN VARCHAR2,
                     cp_pell_coa      IN NUMBER,
                     cp_pell_alt_exp  IN NUMBER,
                     cp_called_from   IN VARCHAR2,
                     cp_return_status IN OUT NOCOPY VARCHAR2,
                     cp_message       IN OUT NOCOPY VARCHAR2,
                     cp_aid           IN OUT NOCOPY NUMBER
                   )
IS

--
-- Schdl Pell Award from Regular Pell Matrix
--

  CURSOR c_pell_rng(
                    l_ci_cal_type        igf_aw_fund_mast.ci_cal_type%TYPE,
                    l_ci_sequence_number igf_aw_fund_mast.ci_sequence_number%TYPE,
                    l_coa                igf_gr_reg_amts.coa_range_start%TYPE,
                    l_efc                igf_gr_reg_amts.efc_range_start%TYPE,
                    l_enrl_stat          igf_gr_reg_amts.enrollment_stat_code%TYPE
                   ) IS
    SELECT crngd.pell_amount amount
      FROM igf_gr_reg_amts crngd,
           igf_ap_batch_aw_map_all batch
     WHERE crngd.enrollment_stat_code = l_enrl_stat
       AND batch.ci_cal_type = l_ci_cal_type
       AND batch.ci_sequence_number = l_ci_sequence_number
       AND batch.sys_award_year = crngd.sys_awd_yr
       AND (l_coa BETWEEN crngd.coa_range_start AND crngd.coa_range_end)
       AND (l_efc BETWEEN crngd.efc_range_start AND crngd.efc_range_end);

  l_pell_rng c_pell_rng%rowtype ;


--
-- Schdl Pell Award from Alternate Pell Matrix
--

  CURSOR c_alt_pell(
                    l_ci_cal_type        igf_aw_fund_mast.ci_cal_type%TYPE,
                    l_ci_sequence_number igf_aw_fund_mast.ci_sequence_number%TYPE,
                    l_coa                igf_gr_alt_amts.coa_range_start%TYPE,
                    l_altexp             igf_gr_alt_amts.exp_range_start%TYPE,
                    l_efc                igf_gr_reg_amts.efc_range_start%TYPE,
                    l_enrl_stat          igf_gr_reg_amts.enrollment_stat_code%TYPE
                   ) IS
    SELECT alt.pell_amount amount
      FROM igf_gr_alt_amts alt,
           igf_ap_batch_aw_map_all batch
     WHERE alt.enrollment_stat_code =  l_enrl_stat
       AND alt.sys_awd_yr = batch.sys_award_year
       AND batch.ci_cal_type = l_ci_cal_type
       AND batch.ci_sequence_number = l_ci_sequence_number
       AND (l_coa BETWEEN alt.coa_range_start AND alt.coa_range_end)
       AND (l_altexp BETWEEN alt.exp_range_start AND alt.exp_range_end)
       AND (l_efc BETWEEN alt.efc_range_start AND alt.efc_range_end);

  l_alt_pell               c_alt_pell%ROWTYPE;
  l_aid_passed             NUMBER;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_matrix_amt.debug',
    'Parameters in get_pell_matrix -> caltype/seq/efc/attend/coa/cp_pell_schd ->' || cp_cal_type || '/' ||
    TO_CHAR(cp_sequence_num) || '/' || TO_CHAR(cp_efc) || '/' || cp_enrl_stat || '/' || TO_CHAR(cp_pell_coa) ||'/'||cp_pell_schd );
  END IF;

  IF  cp_pell_schd = 'R' THEN

  -- Use Regular Pell Matrix

      OPEN c_pell_rng (cp_cal_type,
                       cp_sequence_num,
                       cp_pell_coa,
                       cp_efc,
                       cp_enrl_stat);
      FETCH c_pell_rng into l_pell_rng ;

      IF c_pell_rng%FOUND THEN
            CLOSE c_pell_rng;
            cp_aid := l_pell_rng.amount ;
      ELSE
            fnd_message.set_name('IGF','IGF_GR_PELL_RNG_ERR_FRM');
            IF cp_pell_coa IS NULL THEN
                 fnd_message.set_token('COA','NULL');
            ELSE
                 fnd_message.set_token('COA',TO_CHAR(cp_pell_coa));
            END IF;
            IF cp_efc IS NULL THEN
               fnd_message.set_token('EFC','NULL');
            ELSE
               fnd_message.set_token('EFC',TO_CHAR(cp_efc));
            END IF;
            fnd_message.set_token('ATT',NVL(igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',cp_enrl_stat),'NULL'));
            CLOSE c_pell_rng;
              cp_return_status := 'E';
              cp_message := fnd_message.get ;
            RETURN;
      END IF;

  ELSE

      OPEN c_alt_pell ( cp_cal_type ,
                        cp_sequence_num  ,
                        cp_pell_coa,
                        cp_pell_alt_exp ,
                        cp_efc  ,
                        cp_enrl_stat);

      FETCH c_alt_pell INTO l_alt_pell;

      IF c_alt_pell%FOUND THEN
         CLOSE c_alt_pell;
         cp_aid := l_alt_pell.amount ;

      ELSE
         fnd_message.set_name('IGF','IGF_GR_PELL_RNG_ERR_FRM_ALT');
         IF cp_pell_coa IS NULL THEN
             fnd_message.set_token('COA','NULL');
         ELSE
             fnd_message.set_token('COA',TO_CHAR(cp_pell_coa));
         END IF;
         IF cp_efc IS NULL THEN
             fnd_message.set_token('EFC','NULL');
         ELSE
             fnd_message.set_token('EFC',TO_CHAR(cp_efc));
         END IF;
         fnd_message.set_token('ATT',NVL(igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',cp_enrl_stat),'NULL'));
         IF cp_pell_alt_exp IS NULL THEN
             fnd_message.set_token('ALT_EXP','NULL');
         ELSE
             fnd_message.set_token('ALT_EXP',TO_CHAR(cp_pell_alt_exp));
         END IF;

         cp_aid := 0 ;
         CLOSE c_alt_pell;
         cp_return_status := 'E';
         cp_message := fnd_message.get ;
         RETURN;

      END IF;

  END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.get_pell_matrix_amt.debug',
                                              'cp_aid  -> '|| cp_aid);
    END IF;

RETURN;

EXCEPTION
    WHEN NO_SETUP THEN
     RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.get_pell_matrix_amt '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.get_pell_matrix_amt.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

END get_pell_matrix_amt ;

FUNCTION num_disb(
                  p_adplans_id          igf_aw_awd_dist_plans.adplans_id%TYPE,
                  p_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                  p_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                 ) RETURN NUMBER AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 24/August/2005
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

  -- Get number of disbursements
  CURSOR c_num_disb(
                    cp_adplans_id          igf_aw_awd_dist_plans.adplans_id%TYPE,
                    cp_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                    cp_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                   ) IS
    SELECT COUNT (*) num_disb
       FROM igf_aw_dp_terms terms,
            igf_aw_dp_teach_prds teach_periods
      WHERE terms.adplans_id = cp_adplans_id
        AND terms.adterms_id = teach_periods.adterms_id
        AND terms.ld_cal_type = NVL(cp_ld_cal_type,terms.ld_cal_type)
        AND terms.ld_sequence_number = NVL(cp_ld_sequence_number,terms.ld_sequence_number);
  l_num_disb NUMBER;

BEGIN
  OPEN c_num_disb(p_adplans_id,p_ld_cal_type,p_ld_sequence_number);
  FETCH c_num_disb INTO l_num_disb;
  CLOSE c_num_disb;

  RETURN l_num_disb;
END num_disb;

PROCEDURE round_term_disbursements (
                                    p_pell_tab              IN OUT NOCOPY   pell_tab,
                                    p_fund_id               IN              igf_aw_fund_mast_all.fund_id%TYPE,
                                    p_dist_plan_code        IN              igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                                    p_ld_cal_type           IN              igs_ca_inst_all.cal_type%TYPE,
                                    p_ld_seq_num            IN              igs_ca_inst_all.sequence_number%TYPE,
                                    p_term_amt              IN              NUMBER,
                                    p_tp_count              IN              NUMBER,
                                    p_pkg_awd_status        IN              igf_aw_fund_mast_all.pckg_awd_stat%TYPE,
                                    p_return_status         OUT NOCOPY      VARCHAR2
                                   )
IS
  /*
  ||  Created By : museshad
  ||  Created On : 12-Sep-2005
  ||  Purpose    : Round Pell disbursements based on the distribution method and rounding factor
  ||  Known limitations, enhancements or remarks :
  ||  Refer igf_aw_packaging.round_off_disbursements() for the explanation of the logic
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_disb_round_factor   igf_aw_fund_mast.disb_rounding_code%TYPE := NULL;
  l_trunc_factor        NUMBER        := 0;
  l_extra_factor        NUMBER        := 0;
  l_disb_no             NUMBER        := 0;
  l_special_disb_no     NUMBER        := 0;
  l_step                NUMBER        := 0;
  l_disb_amt            NUMBER        := 0;
  l_disb_prelim_amt     NUMBER        := 0;
  l_disb_amt_extra      NUMBER        := 0;
  l_disb_inter_sum_amt  NUMBER        := 0;
  l_disb_diff           NUMBER        := 0;
  l_term_disb_cnt       NUMBER        := 0;
  l_term_found          BOOLEAN       := FALSE;

BEGIN
  -- Get the disbursement rounding factor
  l_disb_round_factor := igf_aw_packaging.get_disb_round_factor(p_fund_id => p_fund_id);
  l_term_found := FALSE;

  IF l_disb_round_factor NOT IN ('ONE_FIRST', 'DEC_FIRST', 'ONE_LAST', 'DEC_LAST') THEN
    -- Invalid disbursement round factor. Return with Err status
    p_return_status := 'E';
    RETURN;
  END IF;

  -- Log useful values
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Into round_term_disbursements. Parameters received ...');
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Rounding disbursements for the term: '||p_ld_cal_type||', '||p_ld_seq_num);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Term level amount: '||p_term_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Teaching Period count: '||p_tp_count);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Disbursement rounding factor: '||l_disb_round_factor);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'Distribution plan code: ' || p_dist_plan_code);
  END IF;

  -- Set the attributes common to ONEs rounding factor
  IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'ONE_LAST' THEN
    l_trunc_factor      :=    0;
    l_extra_factor      :=    1;
  -- Set the attributes common to DECIMALs rounding factor
  ELSIF l_disb_round_factor = 'DEC_FIRST' OR l_disb_round_factor = 'DEC_LAST' THEN
    l_trunc_factor      :=    2;
    l_extra_factor      :=    0.01;
  END IF;

  -- Set the attributes common to FIRST rounding factor
  IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'DEC_FIRST' THEN
    l_disb_no         :=    1;
    l_step            :=    1;

    IF p_dist_plan_code IN ('C', 'M') THEN
      l_special_disb_no :=    1; -- First disbursement in the term
    END IF;

  -- Set the attributes common to LAST rounding factor
  ELSIF l_disb_round_factor = 'ONE_LAST' OR l_disb_round_factor = 'DEC_LAST' THEN
    l_disb_no         :=    p_pell_tab.COUNT;
    l_step            :=    -1;

    IF p_dist_plan_code IN ('C', 'M') THEN
      l_special_disb_no :=    p_tp_count; -- Last disbursement in the term
    END IF;
  END IF;

  -- Log values
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_trunc_factor: ' ||l_trunc_factor);
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_extra_factor: ' ||l_extra_factor);
  END IF;

  ------------------------------------
  -- EVEN Distribution
  ------------------------------------
  IF p_dist_plan_code = 'E' THEN

    -- Normal disbursement amount
    l_disb_amt := TRUNC(NVL((p_term_amt/p_tp_count), 0), l_trunc_factor);

    -- Preliminary disbursement amount
    l_disb_prelim_amt := TRUNC(NVL((p_term_amt - (l_disb_amt * (p_tp_count-1))), 0), l_trunc_factor);

    -- Difference in disbursement amount
    l_disb_diff := TRUNC(NVL((l_disb_prelim_amt - l_disb_amt), 0), l_trunc_factor);

    -- Extra disbursement amount
    IF l_disb_diff > 0 THEN
        l_disb_amt_extra := TRUNC(NVL((l_disb_amt + l_extra_factor), 0), l_trunc_factor);
    ELSIF l_disb_diff < 0 THEN
        l_disb_amt_extra := TRUNC(NVL((l_disb_amt - l_extra_factor), 0), l_trunc_factor);
    ELSE
        l_disb_amt_extra := TRUNC(NVL(l_disb_amt, 0), l_trunc_factor);
    END IF;

    -- Get the absolute difference value between preliminary and normal disbursement amount
    l_disb_diff := ABS(l_disb_diff);

    -- Log values
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_disb_diff: ' ||l_disb_diff);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_disb_prelim_amt: ' ||l_disb_prelim_amt);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_disb_amt_extra: ' ||l_disb_amt_extra);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_disb_amt: ' ||l_disb_amt);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug', 'l_step: ' ||l_step);
    END IF;

    WHILE l_disb_no BETWEEN 1 AND p_pell_tab.COUNT
    LOOP
      -- Check if it is the current term's disbursement
      IF (p_pell_tab.EXISTS(l_disb_no)) AND
          (p_pell_tab(l_disb_no).ld_cal_type = p_ld_cal_type AND p_pell_tab(l_disb_no).ld_sequence_number = p_ld_seq_num) THEN

        l_term_found := TRUE;

        -- Give the extra amount to each disbursement
        IF l_disb_diff >= l_extra_factor THEN
            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug',
                            'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt||' New rounded disb Amt= '||l_disb_amt_extra);
            END IF;

            p_pell_tab(l_disb_no).offered_amt := l_disb_amt_extra;
            l_disb_diff := NVL((l_disb_diff - l_extra_factor), 0);
        ELSE
            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug',
                            'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt||' New rounded disb Amt= '||l_disb_amt);
            END IF;

            p_pell_tab(l_disb_no).offered_amt := l_disb_amt;
        END IF;
      END IF;

      /* Update the Accepted amount */
      IF p_pkg_awd_status = 'ACCEPTED' THEN
          p_pell_tab(l_disb_no).accepted_amt  :=  p_pell_tab(l_disb_no).offered_amt;
      ELSE
          p_pell_tab(l_disb_no).accepted_amt  :=  NULL;
      END IF;

      l_disb_no := NVL(l_disb_no, 0) + l_step;
    END LOOP;

  ------------------------------------
  -- MATCH COA/MANUAL Distribution
  ------------------------------------
  ELSIF p_dist_plan_code IN ('C', 'M') THEN
    l_term_disb_cnt := 0;

    WHILE l_disb_no BETWEEN 1 AND p_pell_tab.COUNT
    LOOP
      IF (p_pell_tab.EXISTS(l_disb_no)) AND
          (p_pell_tab(l_disb_no).ld_cal_type = p_ld_cal_type AND p_pell_tab(l_disb_no).ld_sequence_number = p_ld_seq_num) THEN

        l_term_found := TRUE;

        l_term_disb_cnt := l_term_disb_cnt + 1;

        IF l_term_disb_cnt <> l_special_disb_no THEN
          -- Other disbursements
          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug',
                          'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt
                          ||' New rounded disb Amt= '||(TRUNC(NVL(p_pell_tab(l_disb_no).offered_amt, 0), l_trunc_factor)));
          END IF;

          p_pell_tab(l_disb_no).offered_amt := TRUNC(NVL(p_pell_tab(l_disb_no).offered_amt, 0), l_trunc_factor);

          -- Calculate running total of other disbursements
          l_disb_inter_sum_amt := NVL((l_disb_inter_sum_amt + p_pell_tab(l_disb_no).offered_amt), 0);
        ELSE
          -- Special (First/Last) disbursement
          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_gr_pell_calc.round_term_disbursements.debug',
                          'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt
                          ||' New rounded disb Amt= '||(TRUNC(NVL((p_term_amt - l_disb_inter_sum_amt), 0), l_trunc_factor)));
          END IF;
          p_pell_tab(l_disb_no).offered_amt := TRUNC(NVL((p_term_amt - l_disb_inter_sum_amt), 0), l_trunc_factor);
        END IF;
      END IF;

      /* Update the Accepted amount */
      IF p_pkg_awd_status = 'ACCEPTED' THEN
          p_pell_tab(l_disb_no).accepted_amt  :=  p_pell_tab(l_disb_no).offered_amt;
      ELSE
          p_pell_tab(l_disb_no).accepted_amt  :=  NULL;
      END IF;

      l_disb_no := NVL(l_disb_no, 0) + l_step;
    END LOOP;
  END IF;

  -- Check if the term passed was found in PL/SQL table.
  -- if no, then it is an error.
  IF NOT l_term_found THEN
    p_return_status := 'E';
    RETURN;
  END IF;

  p_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.round_term_disbursements '||SQLERRM);
      igs_ge_msg_stack.add;

      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.round_term_disbursements.exception','sql error message: '||SQLERRM);
      END IF;

      app_exception.raise_exception;
END round_term_disbursements;


PROCEDURE round_all_disbursements(
                                  p_pell_tab       IN OUT NOCOPY    pell_tab,
                                  p_fund_id        IN               igf_aw_fund_mast_all.fund_id%TYPE,
                                  p_dist_plan_code IN               igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                                  p_aid            IN               NUMBER,
                                  p_disb_count     IN               NUMBER,
                                  p_pkg_awd_status IN               igf_aw_fund_mast_all.pckg_awd_stat%TYPE,
                                  p_return_status  OUT NOCOPY       VARCHAR2
                                 ) AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------
l_disb_round_factor   igf_aw_fund_mast.disb_rounding_code%TYPE := NULL;
l_trunc_factor        NUMBER        := 0;
l_extra_factor        NUMBER        := 0;
l_disb_no             NUMBER        := 0;
l_special_disb_no     NUMBER        := 0;
l_step                NUMBER        := 0;
l_disb_amt            NUMBER        := 0;
l_disb_prelim_amt     NUMBER        := 0;
l_disb_amt_extra      NUMBER        := 0;
l_disb_inter_sum_amt  NUMBER        := 0;
l_disb_diff           NUMBER        := 0;

BEGIN
  l_disb_round_factor := igf_aw_packaging.get_disb_round_factor(p_fund_id => p_fund_id);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'Into round_all_disbursements. Parameters received ...');
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'p_aid: '||p_aid);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'disb count: '||p_disb_count);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'Disbursement rounding factor: '||l_disb_round_factor);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'Distribution plan code: ' || p_dist_plan_code);
  END IF;

  -- Set the attributes common to ONEs rounding factor
  IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'ONE_LAST' THEN
    l_trunc_factor      :=    0;
    l_extra_factor      :=    1;
  -- Set the attributes common to DECIMALs rounding factor
  ELSIF l_disb_round_factor = 'DEC_FIRST' OR l_disb_round_factor = 'DEC_LAST' THEN
    l_trunc_factor      :=    2;
    l_extra_factor      :=    0.01;
  END IF;

  -- Set the attributes common to FIRST rounding factor
  IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'DEC_FIRST' THEN
    l_disb_no         :=    1;
    l_step            :=    1;

    IF p_dist_plan_code IN ('C', 'M') THEN
      l_special_disb_no :=    1; -- First disbursement
    END IF;

  -- Set the attributes common to LAST rounding factor
  ELSIF l_disb_round_factor = 'ONE_LAST' OR l_disb_round_factor = 'DEC_LAST' THEN
    l_disb_no         :=    p_pell_tab.COUNT;
    l_step            :=    -1;

    IF p_dist_plan_code IN ('C', 'M') THEN
      l_special_disb_no :=    p_disb_count; -- Last disbursement
    END IF;
  END IF;

  -- Log values
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_trunc_factor: ' ||l_trunc_factor);
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_extra_factor: ' ||l_extra_factor);
  END IF;

  IF p_dist_plan_code = 'E' THEN

    -- Normal disbursement amount
    l_disb_amt := TRUNC(NVL((p_aid/p_disb_count), 0), l_trunc_factor);

    -- Preliminary disbursement amount
    l_disb_prelim_amt := TRUNC(NVL((p_aid - (l_disb_amt * (p_disb_count-1))), 0), l_trunc_factor);

    -- Difference in disbursement amount
    l_disb_diff := TRUNC(NVL((l_disb_prelim_amt - l_disb_amt), 0), l_trunc_factor);

    -- Extra disbursement amount
    IF l_disb_diff > 0 THEN
        l_disb_amt_extra := TRUNC(NVL((l_disb_amt + l_extra_factor), 0), l_trunc_factor);
    ELSIF l_disb_diff < 0 THEN
        l_disb_amt_extra := TRUNC(NVL((l_disb_amt - l_extra_factor), 0), l_trunc_factor);
    ELSE
        l_disb_amt_extra := TRUNC(NVL(l_disb_amt, 0), l_trunc_factor);
    END IF;

    -- Get the absolute difference value between preliminary and normal disbursement amount
    l_disb_diff := ABS(l_disb_diff);

    -- Log values
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_disb_diff: ' ||l_disb_diff);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_disb_prelim_amt: ' ||l_disb_prelim_amt);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_disb_amt_extra: ' ||l_disb_amt_extra);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_disb_amt: ' ||l_disb_amt);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug', 'l_step: ' ||l_step);
    END IF;

    WHILE l_disb_no BETWEEN 1 AND p_pell_tab.COUNT
    LOOP
      -- Check if it is the current term's disbursement
      IF (p_pell_tab.EXISTS(l_disb_no)) THEN

        -- Give the extra amount to each disbursement
        IF l_disb_diff >= l_extra_factor THEN
            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug',
                            'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt||' New rounded disb Amt= '||l_disb_amt_extra);
            END IF;

            p_pell_tab(l_disb_no).offered_amt := l_disb_amt_extra;
            l_disb_diff := NVL((l_disb_diff - l_extra_factor), 0);
        ELSE
            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug',
                            'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt||' New rounded disb Amt= '||l_disb_amt);
            END IF;

            p_pell_tab(l_disb_no).offered_amt := l_disb_amt;
        END IF;
      END IF;

      /* Update the Accepted amount */
      IF p_pkg_awd_status = 'ACCEPTED' THEN
          p_pell_tab(l_disb_no).accepted_amt  :=  p_pell_tab(l_disb_no).offered_amt;
      ELSE
          p_pell_tab(l_disb_no).accepted_amt  :=  NULL;
      END IF;

      l_disb_no := NVL(l_disb_no, 0) + l_step;
    END LOOP;

  ------------------------------------
  -- MATCH COA/MANUAL Distribution
  ------------------------------------
  ELSIF p_dist_plan_code IN ('C', 'M') THEN

    WHILE l_disb_no BETWEEN 1 AND p_pell_tab.COUNT
    LOOP
      IF (p_pell_tab.EXISTS(l_disb_no)) THEN

        IF l_disb_no <> l_special_disb_no THEN
          -- Other disbursements
          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug',
                          'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt
                          ||' New rounded disb Amt= '||(TRUNC(NVL(p_pell_tab(l_disb_no).offered_amt, 0), l_trunc_factor)));
          END IF;

          p_pell_tab(l_disb_no).offered_amt := TRUNC(NVL(p_pell_tab(l_disb_no).offered_amt, 0), l_trunc_factor);

          -- Calculate running total of other disbursements
          l_disb_inter_sum_amt := NVL((l_disb_inter_sum_amt + p_pell_tab(l_disb_no).offered_amt), 0);
        ELSE
          -- Special (First/Last) disbursement
          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug',
                          'Disb No= '||l_disb_no||' Old Disb Amt= '||p_pell_tab(l_disb_no).offered_amt
                          ||' New rounded disb Amt= '||(TRUNC(NVL((p_aid - l_disb_inter_sum_amt), 0), l_trunc_factor)));
          END IF;
          p_pell_tab(l_disb_no).offered_amt := TRUNC(NVL((p_aid - l_disb_inter_sum_amt), 0), l_trunc_factor);
        END IF;
      END IF;

      /* Update the Accepted amount */
      IF p_pkg_awd_status = 'ACCEPTED' THEN
          p_pell_tab(l_disb_no).accepted_amt  :=  p_pell_tab(l_disb_no).offered_amt;
      ELSE
          p_pell_tab(l_disb_no).accepted_amt  :=  NULL;
      END IF;

      l_disb_no := NVL(l_disb_no, 0) + l_step;
    END LOOP;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                    'igf.plsql.igf_gr_pell_calc.round_all_disbursements.debug',
                    'Disb No= '||l_special_disb_no||' Old Disb Amt= '||p_pell_tab(l_special_disb_no).offered_amt
                    ||' New rounded disb Amt= '|| (TRUNC(NVL((p_aid - l_disb_inter_sum_amt), 0), l_trunc_factor)));
    END IF;
    p_pell_tab(l_special_disb_no).offered_amt := TRUNC(NVL((p_aid - l_disb_inter_sum_amt), 0), l_trunc_factor);
    IF p_pkg_awd_status = 'ACCEPTED' THEN
        p_pell_tab(l_special_disb_no).accepted_amt  :=  p_pell_tab(l_special_disb_no).offered_amt;
    ELSE
        p_pell_tab(l_special_disb_no).accepted_amt  :=  NULL;
    END IF;
  END IF;
  p_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_gr_pell_calc.round_all_disbursements '||SQLERRM);
    igs_ge_msg_stack.add;
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.round_all_disbursements.exception','sql error message: '||SQLERRM);
    END IF;
    app_exception.raise_exception;
END round_all_disbursements;

PROCEDURE calc_pell(
                    cp_fund_id       IN igf_aw_fund_mast_all.fund_id%TYPE,
                    cp_plan_id       IN igf_aw_awd_dist_plans.adplans_id%TYPE,
                    cp_base_id       IN igf_ap_fa_base_rec.base_id%TYPE,
                    cp_aid           IN OUT NOCOPY NUMBER,
                    cp_pell_tab      IN OUT NOCOPY pell_tab,
                    cp_return_status IN OUT NOCOPY VARCHAR2,
                    cp_message       IN OUT NOCOPY VARCHAR2,
                    cp_called_from   IN VARCHAR2,
                    cp_pell_seq_id   OUT NOCOPY igf_gr_pell_setup_all.pell_seq_id%TYPE,
                    cp_pell_schedule_code OUT NOCOPY VARCHAR2
          ) IS
  /*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to calculate the Pell Award
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id / fund id/ plan id
  ||  and returns the Pell award / A Pl/Sql table with the disbursements
  ||  and a return status of S/E  => Success/Error
  ||  Also returns the Pk to the Pell Setup record used for processing
  ||
  ||  Variable description:
  ||  l_aid                   Annual Pell amount
  ||  cp_aid                  Pell Award amount
  ||  l_term_amt              Pell term-level award amount
  ||  l_tp_amt                Teaching-period level award amount
  ||  cp_pell_tab             PL/SQL table containing a record for each Teaching Period
  ||  c_terms_det             Cursor to loop thru each disb in (COA + DP) terms
  ||
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        12-Sep-2005     Build FA 157.
  ||                                  Implemented Pell disbursement rounding
  ||  museshad        20-Jun-2005     Build# FA157 - Bug# 4382371.
  ||                                  1)  Added another check to determine Pell eligibility.
  ||                                      Check the completed programs in the Student's
  ||                                      Program Attempts history and check if there are
  ||                                      any non 'PRE-BACHELORS' programs. If so,
  ||                                      the Student is not eligible for Pell.
  ||                                      Modified the cursor 'c_acad_hist' to avoid unnecessary
  ||                                      looping.
  ||                                  2)  Get key program data from Admissions/FA Anticipated data
  ||                                      when actual key program data is not available
  ||  bkkumar         21-July-2004    Bug# 3778277 This total amount check validation should happen
  ||                                  only if the attendance type is same for all terms.
  ||                                  Also added the validation to validate the amount to be awarded
  ||                                  against the full time pell amount.
  ||  veramach        01-Jul-2004     bug # 3729182 Added logic to check whether cp_pell_tab is null
  ||  bkkumar         01-Apr-04       Bug# 3409969 Added the logic to calculate the pell
  ||                                  award amount when the pell_formula = 3 , to derive the
  ||                                  term_instruction_time and annual instruction time
  ||                                  from the OSS.
  ||                                  Also the rounding off logic is implemented that in case the
  ||                                  attendance type is same for all the terms for the student and
  ||                                  if the number of terms enrolled is same as the payment periods
  ||                                  then add the balance pell amount if any to the last pell term amount.
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
  */

  -- Get the Academic History of the Student to check if He is
  -- Eligible for Pell.
  CURSOR c_acad_hist(
                     l_base_id NUMBER
                    ) IS
    SELECT acad.degree_earned,
           ptype.fin_aid_program_type
      FROM igs_ad_acad_history_v acad,
           igs_ps_type_all ptype,
           igf_ap_fa_base_rec fa,
           igs_ps_degrees dc
     WHERE fa.base_id = l_base_id
       AND acad.person_id = fa.person_id
       AND acad.degree_earned = dc.degree_cd
       AND dc.program_type = ptype.course_type
       AND UPPER(ptype.fin_aid_program_type) IN ('BACHELORS','PROFESSIONAL');
  l_acad_hist c_acad_hist%ROWTYPE;

  -- check whether the student is eligibile for PELL Grant per the context
  -- Payment ISIR.

  CURSOR c_pell_elig ( l_base_id NUMBER ) IS
  SELECT NVL(pell_grant_elig_flag, 'N') pell_grant_elig_flag,
         transaction_num
    FROM igf_ap_isir_matched ism
   WHERE ism.base_id  = l_base_id
     AND ism.active_isir = 'Y';

   l_pell_elig c_pell_elig%ROWTYPE;


    -- Get the Count of the Common Terms for the Student
    CURSOR c_terms(
                      l_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                      l_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                     ) IS
    SELECT COUNT(*) Total_terms FROM (
    SELECT
      terms.ld_cal_type,
      terms.ld_sequence_number
    FROM
      igf_aw_dp_terms terms,
      igf_aw_coa_itm_terms coa
    WHERE
         coa.base_id = l_base_id
    AND  terms.adplans_id = l_adplans_id
    AND  terms.ld_cal_type = coa.ld_cal_type
    AND  terms.ld_sequence_number = coa.ld_sequence_number
    GROUP by terms.ld_cal_type,terms.ld_sequence_number
    );

    l_terms_rec c_terms%ROWTYPE;

    -- Get the Count of the Common Terms for the Student
    CURSOR c_dp_terms(
                      l_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                      l_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                     ) IS

    SELECT COUNT(*) Total_terms FROM (
    SELECT
      terms.ld_cal_type,
      terms.ld_sequence_number
    FROM
      igf_aw_dp_terms terms
    WHERE
         terms.adplans_id = l_adplans_id
    GROUP by terms.ld_cal_type,terms.ld_sequence_number
    );

    -- Get the Terms for the Student, Common between COA / DPlan
    CURSOR c_terms_det(
                      l_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                      l_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                     ) IS
      SELECT   NVL (igf_aw_packaging.get_date_instance (
                     l_base_id,
                     teach.date_offset_cd,
                     terms.ld_cal_type,
                     terms.ld_sequence_number
                  ),
                  teach.start_date) disb_dt,
               terms.ld_cal_type,
               terms.ld_sequence_number,
               teach.tp_cal_type,
               teach.tp_sequence_number,
               teach.tp_perct_num,
               teach.attendance_type_code,
               teach.credit_points_num,
               teach.date_offset_cd
          FROM igf_aw_dp_terms terms,
               igf_aw_dp_teach_prds_v teach
         WHERE terms.adplans_id = l_adplans_id
           AND teach.adterms_id = terms.adterms_id
           AND (terms.ld_cal_type, terms.ld_sequence_number) IN (
                                      SELECT coa.ld_cal_type,
                                             coa.ld_sequence_number
                                        FROM igf_aw_coa_itm_terms coa
                                       WHERE coa.base_id = l_base_id)
      ORDER BY 1;

    l_terms_det_rec c_terms_det%ROWTYPE;

CURSOR c_base( l_base_id igf_ap_fa_base_rec.base_id%TYPE
          ) IS
SELECT
    fa.person_id,
    fa.ci_cal_type,
    fa.ci_sequence_number,
    fa.pell_alt_expense
FROM igf_ap_fa_base_rec fa
WHERE fa.base_id = l_base_id ;

l_base_rec c_base%ROWTYPE;

-- Get The Fund Details
CURSOR c_fund ( l_fund_id igf_aw_fund_mast_all.fund_id%TYPE
          ) IS
  SELECT
     fm.disb_exp_da,
     fm.disb_verf_da,
     fm.show_on_bill,
     fm.pckg_awd_stat
  FROM igf_aw_fund_mast fm
  WHERE
    fm.fund_id = l_fund_id ;

l_fund_rec c_fund%ROWTYPE;

    CURSOR c_get_ofst( cp_ofst_da       igs_ca_da.dt_alias%TYPE,
                       cp_tp_Cal_type   igs_ca_inst.cal_type%TYPE,
                       cp_ci_sequence   igs_ca_inst.sequence_number%TYPE,
                       cp_cur_da        igs_ca_da.dt_alias%TYPE) IS
       SELECT dai.absolute_val ofst_absolute_val,
              dai.derived_val ofst_derived_val
         FROM igs_ca_da_inst_ofst ofst,
              igs_ca_da_inst_v dai,
              igs_ca_da_inst rel
        WHERE rel.dt_alias                    = cp_ofst_da
          AND rel.cal_type                    = cp_tp_cal_type
          AND rel.ci_sequence_number          = cp_ci_Sequence
          AND ofst.dt_alias                   = cp_cur_da
          AND ofst.offset_dt_alias            = cp_ofst_da
          AND ofst.offset_dai_sequence_number = rel.sequence_number
          AND dai.dt_alias                    = ofst.dt_alias
          AND dai.sequence_number             = ofst.dai_sequence_number;

l_ofst_rec c_get_ofst%ROWTYPE;

-- Get CP Plan details
CURSOR c_dp_details(
          l_plan_id igf_aw_awd_dist_plans.adplans_id%TYPE) IS
  SELECT
   dp.adplans_id,
   dp.awd_dist_plan_cd,
   dp.awd_dist_plan_cd_desc,
   dp.dist_plan_method_code
    FROM
   igf_aw_awd_dist_plans dp
   WHERE
   dp.adplans_id = l_plan_id;

l_dp_details_rec c_dp_details%ROWTYPE;

l_pell_setup_rec igf_gr_pell_setup_all%ROWTYPE;
l_pell_schedule    VARCHAR2(30);
l_pell_attend_type VARCHAR2(30);
l_message fnd_new_messages.message_text%TYPE;
l_return_status    VARCHAR2(30);
l_coa              NUMBER;
l_efc              NUMBER;
l_aid              NUMBER;
l_term_amt         NUMBER;
l_running_term     NUMBER;
l_cnt              NUMBER;
l_disb_num         NUMBER;
l_tp_amt           NUMBER;
l_actual_weeks     NUMBER;
l_disb_exp_dt      DATE;
l_verif_enfr_dt    DATE;
l_program_cd       igs_en_stdnt_ps_att.course_cd%TYPE;
l_program_version  igs_en_stdnt_ps_att.version_number%TYPE;
l_attendance_type  igs_en_stdnt_ps_att.attendance_type%TYPE;
pell_att_flag      BOOLEAN := TRUE;
l_term_cnt         NUMBER;
old_pell_att_type  igf_ap_attend_map.attendance_type%TYPE;
l_term_weeks       NUMBER;
l_total_term_weeks NUMBER;
l_pell_amt         NUMBER;
l_ft_pell_amt      NUMBER;
l_return_mesg_text VARCHAR2(1000);
next_disbursement  EXCEPTION;
l_term_exists      BOOLEAN         :=  FALSE;
l_full_time_amount NUMBER          :=  0;
l_ft_running_amount   NUMBER       :=  0;
l_pell_schedule_code  VARCHAR2(1)  :=  'X';


-- PL/SQL Table that returns the records
l_pell_tab pell_tab := pell_tab();

-- Gets all Programs (non pre-bachelor type) completed by the student from
-- the Enrollment Program attempts table. If there is any record of this
-- type, then the student is not eligible for Pell
CURSOR c_get_prog_type (l_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT ptype.fin_aid_program_type prog_type
  FROM
      igs_en_stdnt_ps_att en,
      igf_ap_fa_base_rec fa,
      igs_ps_ver pver,
      igs_ps_type_v ptype
  WHERE
      fa.base_id        = l_base_id                 AND
      en.person_id      = fa.person_id              AND
      en.course_cd      = pver.course_cd            AND
      en.version_number = pver.version_number       AND
      pver.course_type  = ptype.course_type         AND
      UPPER(en.course_attempt_status) = 'COMPLETED' AND
      UPPER(ptype.fin_aid_program_type) <> 'PRE-BACHELORS';

l_get_prog_type c_get_prog_type%ROWTYPE;

-- Gets anticipated Key Program details
CURSOR cur_get_ant_key_prog_ver(
                                cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_plan_id      igf_aw_awd_dist_plans.adplans_id%TYPE
                               )
IS
  SELECT
          ant_data.program_cd key_prog,
          prog.version_number key_prog_ver
  FROM
          igf_aw_dp_terms terms,
          igf_aw_dp_teach_prds_v teach,
          igf_ap_fa_ant_data ant_data,
          igs_ps_ver prog
  WHERE
          terms.adplans_id = cp_plan_id AND
          teach.adterms_id = terms.adterms_id AND
          ant_data.ld_cal_type = terms.ld_cal_type AND
          ant_data.ld_sequence_number = terms.ld_sequence_number AND
          ant_data.base_id = cp_base_id AND
          ant_data.program_cd = prog.course_cd AND
          prog.course_status = 'ACTIVE' AND
          ant_data.program_cd IS NOT NULL AND
          (terms.ld_cal_type,terms.ld_sequence_number) IN
              (SELECT coa.ld_cal_type, coa.ld_sequence_number
               FROM igf_aw_coa_itm_terms coa
               WHERE coa.base_id = cp_base_id)
  ORDER BY
          igf_aw_packaging.get_term_start_date(cp_base_id, terms.ld_cal_type, terms.ld_sequence_number) ASC,
          prog.version_number DESC;

l_get_ant_key_prog_ver_rec cur_get_ant_key_prog_ver%ROWTYPE;

-- museshad (Build# FA 157 Pell disbursement rounding)
TYPE pell_term_rec IS RECORD(
                              term_ld_cal_type  igs_ca_inst.cal_type%TYPE,
                              term_ld_seq_num   igs_ca_inst.sequence_number%TYPE,
                              term_amt          NUMBER,
                              tp_count          NUMBER
                            );
TYPE pell_term_tab IS TABLE OF pell_term_rec;
l_pell_term_tab_rec pell_term_tab;

-- Returns the terms in the (distribution plan + COA) and the number of teaching periods
-- in each term
CURSOR cur_get_term_info (
                          cp_plan_id    igf_aw_awd_dist_plans.adplans_id%TYPE,
                          cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                         )
IS
  SELECT
        terms.ld_cal_type,
        terms.ld_sequence_number,
        COUNT(terms.ld_cal_type) tp_count
  FROM
        igf_aw_dp_terms terms,
        igf_aw_dp_teach_prds teach_periods
  WHERE
        teach_periods.adterms_id = terms.adterms_id AND
        terms.adplans_id = cp_plan_id   AND
        (terms.ld_cal_type,
        terms.ld_sequence_number) IN (
                                      SELECT  coa.ld_cal_type,
                                              coa.ld_sequence_number
                                      FROM    igf_aw_coa_itm_terms coa
                                      WHERE   coa.base_id = cp_base_id
                                     )
  GROUP BY terms.ld_cal_type, terms.ld_sequence_number;
-- museshad (Build# FA 157 Pell disbursement rounding)

-- Get roundoff_fact
CURSOR c_roundoff_fact(
                       cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE
                      ) IS
  SELECT roundoff_fact
    FROM igf_aw_fund_mast_all
   WHERE fund_id = cp_fund_id;
l_roundoff_fact igf_aw_fund_mast_all.roundoff_fact%TYPE;

BEGIN
l_pell_amt    := 0;
l_ft_pell_amt := 0;
l_return_mesg_text := NULL;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                              'cp_plan_id  -> '|| cp_plan_id);
END IF;
l_total_term_weeks := 0;
-- If no plan ID is passed , Not possible to calculate Pell hence return
IF cp_plan_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_DIST_CODE_FAIL');
      cp_message       := fnd_message.get ;
      cp_return_status := 'E' ;
      return;
ELSE
-- Get the CP_Plan code to be displayed in the Log
   OPEN c_dp_details(cp_plan_id);
   FETCH c_dp_details INTO l_dp_details_rec;
   IF  c_dp_details%NOTFOUND THEN
      CLOSE c_dp_details;
      fnd_message.set_name('IGF','IGF_AW_DIST_CODE_FAIL');
      cp_message       := fnd_message.get ;
      cp_return_status := 'E' ;
      return;
   END IF;
   CLOSE c_dp_details;

END IF;

OPEN c_base(cp_base_id);
FETCH c_base INTO l_base_rec;
CLOSE c_base;

  -- Check if student is a Graduate/Professional
  OPEN  c_acad_hist(cp_base_id);
  FETCH c_acad_hist INTO l_acad_hist;

  IF (c_acad_hist%FOUND) THEN
    l_aid := 0;
    fnd_message.set_name('IGF','IGF_AW_NO_PELL_HIGH_DEG');
    fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
    cp_message       := fnd_message.get ;

    cp_return_status := 'E' ;
    CLOSE c_acad_hist;
    RETURN;
  END IF;
  CLOSE c_acad_hist;

  -- Check if the student is eligible per the ISIR record.

  IF cp_called_from NOT IN ('IGFAW016','IGFGR005') THEN
    OPEN c_pell_elig(cp_base_id);
    FETCH c_pell_elig INTO l_pell_elig;
    IF l_pell_elig.pell_grant_elig_flag = 'N' THEN
      l_aid := 0;

      fnd_message.set_name('IGF','IGF_AP_NO_PELL_AWARD');
      fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
      cp_message       := fnd_message.get ;
      cp_return_status := 'E' ;
      CLOSE c_pell_elig;
      RETURN;
    END IF;
    CLOSE c_pell_elig;
  END IF;

  IF cp_called_from NOT IN ('IGFAW016','IGFGR005') THEN
    -- Get all the non PRE-BACHELOR program types already completed by the Student from
    -- Enrollment's Program attempts table. If the student has already completed
    -- any non PRE-BACHELOR program type, then he is not eligible for Pell
    OPEN  c_get_prog_type(cp_base_id);
    FETCH c_get_prog_type INTO l_get_prog_type;

    IF (c_get_prog_type%FOUND) THEN
      -- Display error message
      fnd_message.set_name('IGF','IGF_AW_NO_PELL_HIGH_DEG');
      fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
      cp_message := fnd_message.get ;

      -- Log error
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                       'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                       'Person Number ' ||igf_gr_gen.get_per_num(cp_base_id)|| ' not eligible for Pell because this person has already completed a Bacheolor/Professional program'
                       );
      END IF;
      -- Mark return status as Error
      cp_return_status := 'E' ;

      CLOSE c_get_prog_type;
      RETURN;
    END IF;
    CLOSE c_get_prog_type;
  END IF;

-- Start processing Pell award based on the Common Terms.
OPEN c_terms(cp_base_id,
             cp_plan_id );
FETCH c_terms INTO l_terms_rec;
CLOSE c_terms;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','No terms found for base_id >' || TO_CHAR(cp_base_id) || ' plan_id >' || TO_CHAR(cp_plan_id) || ' = ' || TO_CHAR(NVL(l_terms_rec.total_terms,0)));
END IF;

IF NVL(l_terms_rec.total_terms,0) = 0 THEN

     cp_return_status := 'E';
     fnd_message.set_name('IGF','IGF_AW_COA_COMMON_TERMS_FAIL');
     fnd_message.set_token('PLAN_CD',l_dp_details_rec.awd_dist_plan_cd);
     cp_message := fnd_message.get ;
     RETURN;
END IF;

 -- Get the students key program details
 -- Based on these details the Pell Setup record is arrived at
 igf_ap_gen_001.get_key_program(cp_base_id        => cp_base_id,
                                cp_course_cd      => l_program_cd,
                                cp_version_number => l_program_version
                               );

    IF l_program_cd IS NULL THEN
      -- Actual (Enrollment) key program details not available.
      -- Get it from Admissions
      get_key_prog_ver_frm_adm(
                                p_base_id       =>  cp_base_id,
                                p_key_prog_cd   =>  l_program_cd,
                                p_key_prog_ver  =>  l_program_version
                              );

      IF l_program_cd IS NULL AND igf_aw_coa_gen.canUseAnticipVal THEN
        -- Admissions does not have key program details
        -- Get it from FA Anticipated data.
        OPEN cur_get_ant_key_prog_ver(cp_base_id, cp_plan_id);
        FETCH cur_get_ant_key_prog_ver INTO l_get_ant_key_prog_ver_rec;
        CLOSE cur_get_ant_key_prog_ver;

        l_program_cd      :=  l_get_ant_key_prog_ver_rec.key_prog;
        l_program_version :=  l_get_ant_key_prog_ver_rec.key_prog_ver;

        IF l_program_cd IS NULL THEN
          -- FA Anticipated data does not have key program details. Error out
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Cannot compute key program details.');
          END IF;

          cp_return_status := 'E';
          fnd_message.set_name('IGS', 'IGS_EN_NO_KEY_PRG');
          fnd_message.set_token('PERSON', igf_gr_gen.get_per_num(cp_base_id));
          cp_message := fnd_message.get;
          RETURN;
        END IF;
      END IF;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Key Program > Course cd>' || l_program_cd || ' Version >' || TO_CHAR(l_program_version) );
    END IF;

  l_message := NULL;

 -- Get the Pell Setup
  get_pell_setup( cp_base_id         => cp_base_id,
                  cp_course_cd       => l_program_cd,
                  cp_version_number  => l_program_version,
                  cp_cal_type        => l_base_rec.ci_cal_type,
                  cp_sequence_number => l_base_rec.ci_sequence_number ,
                  cp_pell_setup_rec  => l_pell_setup_rec ,
                  cp_message         => l_message  ,
                  cp_return_status   => l_return_status );

  IF l_return_status = 'E' THEN
    cp_message       := l_message;
    cp_return_status := 'E' ;
    RETURN;
  END IF;

    cp_pell_seq_id := l_pell_setup_rec.pell_seq_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Pell Setup Retrival Succesful for Primary key PELL_SEQ_ID- > ' ||  TO_CHAR(l_pell_setup_rec.PELL_SEQ_ID));
    END IF;

 -- Check if the Pell Setup Payment periods are greater than the total number of payment periods
 IF l_terms_rec.total_terms > l_pell_setup_rec.payment_periods_num  THEN
    fnd_message.set_name('IGF','IGF_GR_INVALID_PAY_PERIODS');
    fnd_message.set_token('REPORT_PELL_ID', l_pell_setup_rec.rep_pell_id);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Pell Setup pymnt prds - > ' ||  TO_CHAR(l_pell_setup_rec.payment_periods_num) || ' Actual periods ->' || TO_CHAR(l_terms_rec.total_terms));
    END IF;
 END IF;

 -- Get fund attributes to set at Disbursement Level.
 OPEN c_fund(cp_fund_id);
 FETCH c_fund into l_fund_rec;
 IF c_fund%NOTFOUND THEN
         fnd_message.set_name('IGF','IGF_AW_NO_SUCH_FUND');
         fnd_message.set_token('FUND_ID',TO_CHAR(cp_fund_id));
         cp_message := fnd_message.get ;
         cp_return_status := 'E' ;
         CLOSE c_fund;
         RETURN;
 END IF;
 CLOSE c_fund;


 -- Initialize the running Term flag
 l_running_term := -1 ;
 l_term_cnt     := 0;
 l_term_amt     := 0;
 l_disb_num     := 0;
 cp_aid         := NULL;
 old_pell_att_type := NULL;
 l_ft_running_amount := 0;

 /*
   Before starting pell calculation, find out what is the Full time pell amount
   that the student can get, using his own COA and EFC
 */
 get_pell_coa_efc(
                   cp_base_id              =>   cp_base_id,
                   cp_attendance_type      =>   '1',
                   cp_pell_setup_rec       =>   l_pell_setup_rec,
                   cp_coa                  =>   l_coa,
                   cp_efc                  =>   l_efc,
                   cp_pell_schedule_code   =>   l_pell_schedule_code,
                   cp_message              =>   l_message,
                   cp_return_status        =>   l_return_status
                 );

 -- Assumed that get_pell_coa_efc() will not return any error.
 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Done with get_pell_coa_efc: l_coa= '||l_coa||
                                          ' l_efc: '||l_efc||' l_pell_schedule_code: '||l_pell_schedule_code);
 END IF;

 get_pell_matrix_amt(
                       cp_cal_type      =>  l_base_rec.ci_cal_type,
                       cp_sequence_num  =>  l_base_rec.ci_sequence_number,
                       cp_efc           =>  l_efc,
                       cp_pell_schd     =>  l_pell_schedule_code,
                       cp_enrl_stat     =>  '1',
                       cp_pell_coa      =>  l_coa,
                       cp_pell_alt_exp  =>  l_base_rec.pell_alt_expense,
                       cp_called_from   =>  'PELLORIG',
                       cp_return_status =>  l_return_status,
                       cp_message       =>  l_message,
                       cp_aid           =>  l_full_time_amount
                    );

 -- Assumed that get_pell_matrix_amt() will not return any error.
 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Done with get_pell_matrix_amt: l_full_time_amount= '|| l_full_time_amount);
 END IF;

 -- Check the if running in DP only Mode or COA/DP common Terms Mode
 OPEN c_terms_det (
                   cp_plan_id,
                   cp_base_id
                  );

   LOOP       -- << c_terms_det Start loop >>
    BEGIN     -- << Start Block >>
      FETCH c_terms_det INTO l_terms_det_rec;
      EXIT WHEN c_terms_det%NOTFOUND;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Processing Term->' ||
        l_terms_det_rec.ld_cal_type || '/' || TO_CHAR(l_terms_det_rec.ld_sequence_number)  || ' Teach->' ||
        l_terms_det_rec.tp_cal_type || '/' || TO_CHAR(l_terms_det_rec.tp_sequence_number) );
      END IF;

      IF l_dp_details_rec.dist_plan_method_code = 'E' THEN
        l_terms_det_rec.tp_perct_num := 100 / num_disb(cp_plan_id,l_terms_det_rec.ld_cal_type,l_terms_det_rec.ld_sequence_number);
      END IF;

      IF l_running_term <> l_terms_det_rec.ld_sequence_number THEN
       -- Term has changed so Do a Term Level Pell computation .

        -- Reset the Term variables
        l_running_term := l_terms_det_rec.ld_sequence_number ;
        l_term_amt     := 0 ;
        l_term_cnt     := l_term_cnt + 1;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Term level call to get_pell_attendance_type ' );
        END IF;

        -- Get the Attndance Type for the Person
        get_pell_attendance_type (
                                   cp_base_id            => cp_base_id,
                                   cp_ld_cal_type        => l_terms_det_rec.ld_cal_type ,
                                   cp_ld_sequence_number => l_terms_det_rec.ld_sequence_number  ,
                                   cp_pell_setup_rec     => l_pell_setup_rec  ,
                                   cp_attendance_type    => l_pell_attend_type ,
                                   cp_message            => l_message  ,
                                   cp_return_status      => l_return_status );

        IF (l_return_status='E') AND (l_pell_attend_type <> 'XX' OR l_pell_attend_type IS NULL) THEN
           -- IGF_GR_PELL_ATT_NOT_EXIST scenario - FA Attendance type mapping does not exist. Error out and return.
           cp_message       := l_message ;
           cp_return_status := 'E' ;
           CLOSE c_terms_det ;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','returning back - current term '||l_terms_det_rec.ld_cal_type||'/'||l_terms_det_rec.ld_sequence_number);
           END IF;

           RETURN;
        ELSIF (l_return_status='E') AND l_pell_attend_type = 'XX' THEN
          -- IGF_GR_NO_OSS_ATTEND scenario- Not able to derive ACTUAL attendance type for the term.
          -- We can still continue by Skipping this disb and moving to next disb in the loop c_terms_det
          l_term_cnt := l_term_cnt - 1;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug', 'Not able to derive ACTUAL attendance type for the term '
                          ||l_terms_det_rec.ld_cal_type ||'/'|| l_terms_det_rec.ld_sequence_number ||'. Raising next_disbursement to process next disbursement.');
          END IF;

          RAISE next_disbursement;
        END IF;

        -- FACR116
        -- here set the flag indicating that if the attendance type is different for the terms
        -- If pell_att_flag is FALSE then the pell attendance type is not the same for all the terms.
        IF pell_att_flag AND NVL(old_pell_att_type,'*') = l_pell_attend_type THEN
           pell_att_flag := TRUE;
        ELSE
           IF old_pell_att_type IS NOT NULL THEN
             pell_att_flag := FALSE;
           END IF;
        END IF;
        old_pell_att_type := l_pell_attend_type;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Term level call to get_pell_coa_efc ' );
        END IF;

        -- Get Pell COA and EFC
        get_pell_coa_efc (
                        cp_base_id            => cp_base_id,
                        cp_attendance_type    => l_pell_attend_type  ,
                        cp_pell_setup_rec     => l_pell_setup_rec  ,
                        cp_coa                => l_coa   ,
                        cp_efc                => l_efc  ,
                        cp_pell_schedule_code => l_pell_schedule  ,
                        cp_message            => l_message  ,
                        cp_return_status      => l_return_status );

        IF (l_return_status='E') THEN
           cp_message       := l_message ;
           cp_return_status := 'E' ;
           CLOSE c_terms_det ;
           RETURN;
        ELSE
           cp_pell_schedule_code := l_pell_schedule ;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','**** values passed to matrix efc>'|| l_efc || '/schedule>' || l_pell_schedule || '/coa>'  || l_coa || '/alt_exp>'
                       || l_base_rec.pell_alt_expense || '/attend_type>' || l_pell_attend_type);
        END IF;

        -- Compute the Annual Pell Amount for the context attendance type
        get_pell_matrix_amt(
               cp_cal_type     => l_base_rec.ci_cal_type,
               cp_sequence_num => l_base_rec.ci_sequence_number,
               cp_efc          => l_efc,
               cp_pell_schd    => l_pell_schedule,
               cp_enrl_stat    => l_pell_attend_type,
               cp_pell_coa     => l_coa,
               cp_pell_alt_exp => l_base_rec.pell_alt_expense,
               cp_called_from  => cp_called_from,
               cp_message      => l_message,
               cp_return_status => l_return_status,
               cp_aid           => l_aid
             ) ;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','Term level return amount from get_pell_matrix_amt **************->' || TO_CHAR(l_aid) );
        END IF;

        IF l_return_status IS NOT NULL AND l_return_status <> 'E' AND l_aid = 0 THEN
          l_term_cnt     := l_term_cnt - 1;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','reduced l_term_cnt:'||l_term_cnt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','raising next_disbursement for '||l_terms_det_rec.ld_cal_type||'/'||l_terms_det_rec.ld_sequence_number ||' as matrix amt is zero');
          END IF;
          RAISE next_disbursement;
        END IF;

        IF (l_return_status='E') THEN
           cp_message       := l_message ;
           cp_return_status := 'E' ;
           CLOSE c_terms_det ;
           RETURN;
        END IF;
        IF l_aid = 0 THEN
           fnd_message.set_name('IGF','IGF_AW_ZERO_PELL_AMT');
           cp_message       := fnd_message.get;
           cp_return_status := 'E' ;
           RETURN;
        END IF;
        -- Get the Term Level Amount
        IF l_pell_setup_rec.payment_method = 3 THEN

           l_term_weeks     := NULL;
           l_actual_weeks   := NULL;
           cp_return_status := NULL;
           cp_message       := NULL;

           get_pm_3_acad_term_wks(l_terms_det_rec.ld_cal_type,
                                  l_terms_det_rec.ld_sequence_number,
                                  l_program_cd,
                                  l_program_version,
                                  l_term_weeks,
                                  l_actual_weeks,
                                  cp_return_status,
                                  cp_message
                                 );

           IF cp_return_status = 'E' THEN
              RETURN;
           END IF;

           -- museshad Build# FA 157
           -- Changed ROUNDing to two decimal places
           l_term_amt         := ROUND(((l_aid * l_term_weeks) / l_actual_weeks), 2);
           l_total_term_weeks := l_total_term_weeks + l_term_weeks;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                                   'Payment Method = 3 - > l_actual_weeks - > l_term_weeks - > l_aid -> l_term_amt -> '
                                                   || l_actual_weeks || ' -> ' || l_term_weeks
                                                   || ' -> ' || l_aid
                                                   || ' -> ' || l_term_amt);
           END IF;

        ELSE  -- the payment method is not equal to '3'
           l_term_amt := ROUND((l_aid/l_pell_setup_rec.payment_periods_num),2) ;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug', 'l_aid***payment periods -> ' ||l_aid|| '***' ||l_pell_setup_rec.payment_periods_num);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                                   'Payment Method is NOT  3 - > l_aid -> l_term_amt -> '
                                                   || ' -> ' || l_aid
                                                   || ' -> ' || l_term_amt);
           END IF;
        END IF;

        /*
          For each term, add the aid amount to running total
        */
        IF l_ft_running_amount + l_term_amt > l_full_time_amount THEN
          l_term_amt := l_full_time_amount - l_ft_running_amount ;
          l_ft_running_amount := l_full_time_amount;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug', 'Reduced l_term_amt to ' ||l_term_amt|| ' so that it is within the full time Pell amt');
          END IF;
        ELSE
          l_ft_running_amount  := l_ft_running_amount + l_term_amt ;
        END IF;

      END IF; -- Term Calendar Instance has Changed

      IF NVL(l_term_amt, 0) > 0 THEN
         -- Retrieve the Verification Enforcement Date
        l_ofst_rec := NULL;
        OPEN c_get_ofst(
                        l_terms_det_rec.date_offset_cd,
                        l_terms_det_rec.ld_cal_type,
                        l_terms_det_rec.ld_sequence_number,
                        l_fund_rec.disb_verf_da
                       );
        FETCH c_get_ofst INTO l_ofst_rec;
        CLOSE c_get_ofst;

        IF l_ofst_rec.ofst_derived_val IS NOT NULL THEN
          l_verif_enfr_dt := l_ofst_rec.ofst_derived_val;
        ELSE
          l_verif_enfr_dt := l_ofst_rec.ofst_absolute_val;
        END IF;

         -- Retrieve the Disbursement Expiration Date
        l_ofst_rec := NULL;
        OPEN c_get_ofst(
                        l_terms_det_rec.date_offset_cd,
                        l_terms_det_rec.ld_cal_type,
                        l_terms_det_rec.ld_sequence_number,
                        l_fund_rec.disb_exp_da
                       );
        FETCH c_get_ofst INTO l_ofst_rec;
        CLOSE c_get_ofst;

        IF l_ofst_rec.ofst_derived_val IS NOT NULL THEN
          l_disb_exp_dt := l_ofst_rec.ofst_derived_val;
        ELSE
          l_disb_exp_dt := l_ofst_rec.ofst_absolute_val;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',' /PL SQL Table count Before ' ||l_cnt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',' Teaching Period Percent: ' ||l_terms_det_rec.tp_perct_num);
        END IF;

         -- Populate the PL/SQL Table with the Disbursement Details
        l_tp_amt := ROUND((l_term_amt * l_terms_det_rec.tp_perct_num/100),2) ;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',' l_tp_amt: ' ||l_tp_amt);
        END IF;

        IF cp_pell_tab IS NULL THEN
          cp_pell_tab := pell_tab();
        END IF;
        l_cnt := cp_pell_tab.COUNT;
        l_cnt := NVL(l_cnt,0) + 1 ;
        l_disb_num := l_disb_num + 1;


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','###  term_ld>' || l_terms_det_rec.ld_cal_type || '/tp_cal>' ||
           l_terms_det_rec.tp_cal_type || '/tp_seq>' || l_terms_det_rec.tp_sequence_number || '/term_amt>' || l_term_amt || '/tp_%>' || l_terms_det_rec.tp_perct_num
           || '/tp_amt>' || l_tp_amt ||' /PL SQL Table count After ' ||l_cnt);
        END IF;

        cp_pell_tab.EXTEND(1);

        cp_pell_tab(l_cnt).process_id         := NULL;
        cp_pell_tab(l_cnt).sl_number          := l_disb_num ;
        cp_pell_tab(l_cnt).disb_dt            := l_terms_det_rec.disb_dt ;
        cp_pell_tab(l_cnt).fund_id            := cp_fund_id ;
        cp_pell_tab(l_cnt).base_id            := cp_base_id ;
        cp_pell_tab(l_cnt).offered_amt        := l_tp_amt ;
        cp_pell_tab(l_cnt).term_amt           := l_term_amt ; -- museshad (Build FA 157)

        IF l_fund_rec.pckg_awd_stat = 'ACCEPTED' THEN
            cp_pell_tab(l_cnt).accepted_amt       := l_tp_amt ;
        ELSE
            cp_pell_tab(l_cnt).accepted_amt       := NULL ;
        END IF;

        cp_pell_tab(l_cnt).paid_amt                  := null;
        cp_pell_tab(l_cnt).ld_cal_type               := l_terms_det_rec.ld_cal_type ;
        cp_pell_tab(l_cnt).ld_sequence_number        := l_terms_det_rec.ld_sequence_number;
        cp_pell_tab(l_cnt).tp_cal_type               := l_terms_det_rec.tp_cal_type;
        cp_pell_tab(l_cnt).tp_sequence_number        := l_terms_det_rec.tp_sequence_number;
        cp_pell_tab(l_cnt).app_trans_num_txt         := l_pell_elig.transaction_num;
        cp_pell_tab(l_cnt).adplans_id                := cp_plan_id;
        cp_pell_tab(l_cnt).attendance_type_code      := l_terms_det_rec.attendance_type_code;
        cp_pell_tab(l_cnt).min_credit_pts            := l_terms_det_rec.credit_points_num;
        cp_pell_tab(l_cnt).disb_exp_dt               := l_disb_exp_dt;
        cp_pell_tab(l_cnt).verf_enfr_dt              := l_verif_enfr_dt;
        cp_pell_tab(l_cnt).show_on_bill              := l_fund_rec.show_on_bill;
        cp_pell_tab(l_cnt).base_attendance_type_code := l_pell_attend_type ;

        cp_aid := NVL(cp_aid,0) + NVL(l_tp_amt,0) ;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                                 'l_tp_amt , cp_aid - LOOP ' || l_tp_amt || ' , ' || cp_aid);
        END IF;
      ELSE
        -- l_term_amt is NULL or 0
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug', 'Ignoring term bcoz l_term_amt is 0');
        END IF;
      END IF;     -- << NVL(l_term_amt, 0) > 0 >>

    EXCEPTION
      WHEN next_disbursement THEN
        l_term_amt := NULL;
        l_pell_attend_type := NULL;
      WHEN OTHERS THEN
        RAISE;
    END;      -- << End Block >>
   END LOOP;  -- << c_terms_det End loop >>

   CLOSE c_terms_det;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                             'l_aid , cp_aid , l_acad_wks , l_term_total_weeks '
                                             || l_aid || ' , '|| cp_aid || ' , '
                                             || l_actual_weeks || ' , '|| l_total_term_weeks);
   END IF;

   -- Check if cp_pell_tab is NOT filled for some reason. If so, error out and return
   IF (cp_pell_tab IS NULL) OR (cp_pell_tab IS NOT NULL AND cp_pell_tab.COUNT = 0) THEN
      -- cp_pell_tab is not filled, so the Pell awd amount will be 0
       fnd_message.set_name('IGF','IGF_AW_ZERO_PELL_AMT');
       cp_message       :=  fnd_message.get;
       cp_return_status :=  'E';
       cp_aid           :=  0;

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug', 'cp_pell_tab is NOT filled. Cannot proceed further.');
       END IF;

       RETURN;
   END IF;

    OPEN c_roundoff_fact(cp_fund_id);
    FETCH c_roundoff_fact INTO l_roundoff_fact;
    CLOSE c_roundoff_fact;

    -- museshad (Round Pell disbursements)
    -- Loop for each distinct term
    FOR l_term_rec IN cur_get_term_info(
                                        cp_plan_id  =>  cp_plan_id,
                                        cp_base_id  =>  cp_base_id
                                       )
    LOOP
      l_term_amt := 0;
      l_term_exists := FALSE;

      -- Loop thru the main PL/SQL table and find the term amount
      FOR i in 1..cp_pell_tab.COUNT
      LOOP
        IF (cp_pell_tab.EXISTS(i) AND
              (
               ((l_term_rec.ld_cal_type IS NOT NULL) AND (cp_pell_tab(i).ld_cal_type = l_term_rec.ld_cal_type)) AND
               ((l_term_rec.ld_sequence_number IS NOT NULL) AND (cp_pell_tab(i).ld_sequence_number = l_term_rec.ld_sequence_number))
              )
           ) THEN
            l_term_amt := cp_pell_tab(i).term_amt;
            l_term_exists := TRUE;
           /*
             Apply fund master round-off factor to term level amount
           */
            IF l_roundoff_fact = '0.5' THEN
              l_term_amt := ROUND(l_term_amt, 2);
            ELSIF l_roundoff_fact = '1' THEN
              l_term_amt := ROUND(l_term_amt);
           END IF;
          EXIT;
        END IF;
      END LOOP;

      -- Round all disbursements in the term
      l_return_status := 'S';
      -- Log
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                      'igf.plsql.igf_gr_pell_calc.calc_pell.debug Full Time Amount Validation',
                      'Calling round_term_disbursements for the term '||l_term_rec.ld_cal_type||', '||l_term_rec.ld_sequence_number);
      END IF;
      IF NOT pell_att_flag AND l_term_exists THEN
        --round off term amount
        round_term_disbursements (
                                  p_pell_tab              =>    cp_pell_tab,
                                  p_fund_id               =>    cp_fund_id,
                                  p_dist_plan_code        =>    l_dp_details_rec.dist_plan_method_code,
                                  p_ld_cal_type           =>    l_term_rec.ld_cal_type,
                                  p_ld_seq_num            =>    l_term_rec.ld_sequence_number,
                                  p_term_amt              =>    l_term_amt,
                                  p_tp_count              =>    l_term_rec.tp_count,
                                  p_pkg_awd_status        =>    l_fund_rec.pckg_awd_stat,
                                  p_return_status         =>    l_return_status
                                );

        -- Check for err in Pell disbursement rounding for the term
        IF l_return_status = 'E' THEN
          cp_message       := NULL;
          cp_return_status := 'E';
          RETURN;
        END IF;
      ELSE
        --round of entire award amount
        /*
          Apply fund master round-off factor to award amount
        */
         IF l_roundoff_fact = '0.5' THEN
           cp_aid := ROUND(cp_aid, 2);
         ELSIF l_roundoff_fact = '1' THEN
           cp_aid := ROUND(cp_aid);
        END IF;
        round_all_disbursements(
                                p_pell_tab         => cp_pell_tab,
                                p_fund_id          => cp_fund_id,
                                p_dist_plan_code   => l_dp_details_rec.dist_plan_method_code,
                                p_aid              => cp_aid,
                                p_disb_count       => cp_pell_tab.COUNT,
                                p_pkg_awd_status   => l_fund_rec.pckg_awd_stat,
                                p_return_status    => l_return_status
                               );
      END IF;
    END LOOP;
    -- museshad (Round Pell disbursements)

   --
   -- FACR116
   --
   IF (l_pell_setup_rec.payment_method <> 3)
   OR (l_pell_setup_rec.payment_method = 3 AND l_total_term_weeks = l_actual_weeks) THEN
      -- If the payment periods is equal to the terms enrolled for the student
      IF l_pell_setup_rec.payment_periods_num = l_term_cnt THEN
          -- if the attendance type is same in all the terms
          IF pell_att_flag THEN
            IF l_aid <> cp_aid THEN
                 cp_pell_tab(l_cnt).offered_amt := l_tp_amt + l_aid - cp_aid ;
                 IF l_fund_rec.pckg_awd_stat = 'ACCEPTED' THEN
                  cp_pell_tab(l_cnt).accepted_amt       := l_tp_amt + l_aid - cp_aid ;
                 ELSE
                  cp_pell_tab(l_cnt).accepted_amt       := NULL ;
                 END IF;
                 cp_aid := l_aid;
            END IF;
          END IF;
     END IF;
   END IF;
   --
   -- Bug 3778277 This validation should happen only if the attendance type is same for all terms
   /*IF pell_att_flag AND cp_aid > l_aid THEN
      -- Total awarded amount is greater than the limit
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug','raising IGF_AW_PELL_LMT_EXCEED with cp_aid/l_aid->'||cp_aid||'/'||l_aid);
      END IF;
      fnd_message.set_name('IGF','IGF_AW_PELL_LMT_EXCEED');
      cp_message       := fnd_message.get;
      cp_return_status := 'E' ;
      RETURN;
   END IF;*/
    -- Check to compare the award amount with the full time pell amount that a student can get.
    l_return_status := NULL;
    calc_ft_max_pell(cp_base_id          =>  cp_base_id,
                     cp_cal_type         =>  l_base_rec.ci_cal_type,
                     cp_sequence_number  =>  l_base_rec.ci_sequence_number,
                     cp_flag             =>  'FULL_TIME',
                     cp_aid              =>  l_pell_amt,
                     cp_ft_aid           =>  l_ft_pell_amt,
                     cp_return_status    =>  l_return_status,
                     cp_message          =>  l_return_mesg_text
                    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug Full Time Amount Validation',
                                             'l_ft_pell_amt , cp_aid , l_return_status , l_return_mesg_text '
                                             || l_ft_pell_amt || ' , '|| cp_aid || ' , '
                                             || l_return_status || ' , '|| l_return_mesg_text);
    END IF;
    IF (NVL(l_return_status,'*') = 'E') THEN
      cp_message       := l_return_mesg_text;
      cp_return_status := 'E' ;
      RETURN;
    ELSE
       IF cp_aid > l_ft_pell_amt THEN
          fnd_message.set_name('IGF','IGF_AW_PELL_LMT_EXCEED');
          cp_message       := fnd_message.get;
          cp_return_status := 'E' ;
          RETURN;
       END IF;
    END IF;

    /* museshad (Build FA 157)
      Recalculate cp_aid after rounding */
    cp_aid := 0;
    FOR i in 1..cp_pell_tab.COUNT
    LOOP
      IF (cp_pell_tab.EXISTS(i)) THEN
        cp_aid := cp_aid + NVL(cp_pell_tab(i).offered_amt, 0);
      END IF;
    END LOOP;

   cp_return_status := 'S';


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_pell.debug',
                                              'Aid Amount ' || cp_aid);
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.calc_pell '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.calc_pell.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

END calc_pell;

PROCEDURE pell_elig( cp_base_id  IN igf_ap_fa_base_rec.base_id%TYPE,
                     cp_return_status IN OUT NOCOPY VARCHAR2
                    )
IS
/*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to calculate the Eligibilty Status of the Student
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id
  ||  and a return status of S/E  => Success/Error
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        01-Jun-2005     Build# FA157 - Bug# 4382371.
  ||                                  Added another check to determine Pell eligibility.
  ||                                  Check the completed programs in the Student's
  ||                                  Program Attempts history (apart from Admission Academic
  ||                                  History which is already there) and see if there are
  ||                                  any non 'PRE-BACHELORS' programs. If so,
  ||                                  mark as ineligible.
  ||                                  Modified the cursor 'c_acad_hist' to avoid unnecessary
  ||                                  looping
  ||  ugummall        17-DEC-2003     BUG# 3252832 FA-131 Cod updates
  ||                                  when c_pell_elig cursor not found used a message.
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
*/
  CURSOR c_acad_hist(
                     l_base_id NUMBER
                    ) IS
    SELECT acad.degree_earned,
           ptype.fin_aid_program_type
      FROM igs_ad_acad_history_v acad,
           igs_ps_type_all ptype,
           igf_ap_fa_base_rec fa,
           igs_ps_degrees dc
     WHERE fa.base_id = l_base_id
       AND acad.person_id = fa.person_id
       AND acad.degree_earned = dc.degree_cd
       AND dc.program_type = ptype.course_type
       AND UPPER(ptype.fin_aid_program_type) IN ('BACHELORS','PROFESSIONAL');

  l_acad_hist c_acad_hist%ROWTYPE;

  -- check whether the student is eligibile for PELL Grant per the context
  -- Payment ISIR.

  CURSOR c_pell_elig ( l_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
  SELECT NVL(ism.pell_grant_elig_flag, 'N') pell_grant_elig_flag
    FROM igf_ap_isir_matched ism
   WHERE ism.base_id     = l_base_id
     AND ism.active_isir = 'Y' ;

   l_pell_elig c_pell_elig%ROWTYPE;

  -- Get non Pre-Bachelor program types completed by the student
  -- from the Enrollment's table
  CURSOR c_get_prog_type (l_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  IS
    SELECT ptype.FIN_AID_PROGRAM_TYPE prog_type
    FROM
        igs_en_stdnt_ps_att en,
        igf_ap_fa_base_rec fa,
        igs_ps_ver pver,
        igs_ps_type_v ptype
    WHERE
        fa.base_id        = l_base_id                 AND
        en.person_id      = fa.person_id              AND
        en.course_cd      = pver.course_cd            AND
        en.version_number = pver.version_number       AND
        pver.course_type  = ptype.course_type         AND
        UPPER(en.course_attempt_status) = 'COMPLETED' AND
        UPPER(ptype.fin_aid_program_type) <> 'PRE-BACHELORS';

  l_get_prog_type c_get_prog_type%ROWTYPE;

BEGIN

  cp_return_status := 'S' ;

  OPEN  c_acad_hist(cp_base_id);
  FETCH c_acad_hist INTO l_acad_hist;

  IF (c_acad_hist%FOUND) THEN
    -- Not eligible for Pell
    fnd_message.set_name('IGF','IGF_AW_NO_PELL_HIGH_DEG');
    fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
    igs_ge_msg_stack.add;

    cp_return_status := 'E';
    CLOSE c_acad_hist;
    RETURN;
  END IF;
  CLOSE c_acad_hist;

  OPEN c_pell_elig(cp_base_id);
  FETCH c_pell_elig INTO l_pell_elig;
  IF (c_pell_elig%NOTFOUND) THEN
    fnd_message.set_name('IGF','IGF_AP_ACT_ISIR_NOT_FOUND');
    igs_ge_msg_stack.add;
    cp_return_status := 'E' ;
  ELSE
    IF NVL(l_pell_elig.pell_grant_elig_flag,'N') = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_NO_PELL_AWARD');
      fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
      igs_ge_msg_stack.add;
      cp_return_status := 'E' ;
      CLOSE c_pell_elig;
      RETURN;
    END IF;
  END IF;
  CLOSE c_pell_elig;

  -- museshad Build# FA157 - Bug# 4382371
  -- Get all non PRE-BACHELOR Program types completed by the Student
  -- If the student has already completed any non PRE-BACHELOR program
  -- then he is not eligible for Pell
  OPEN  c_get_prog_type(cp_base_id);
  FETCH c_get_prog_type INTO l_get_prog_type;

  IF (c_get_prog_type%FOUND) THEN
    -- Not eligible for Pell
    fnd_message.set_name('IGF','IGF_AW_NO_PELL_HIGH_DEG');
    fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(cp_base_id));
    igs_ge_msg_stack.add;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                     'igf.plsql.igf_gr_pell_calc.pell_elig.debug',
                     'Person Number ' ||igf_gr_gen.get_per_num(cp_base_id)|| ' not eligible for Pell because this person has already completed a Bacheolor/Professional program'
                     );
    END IF;

    cp_return_status := 'E' ;
    CLOSE c_get_prog_type;
    RETURN;
  END IF;
  CLOSE c_get_prog_type;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.pell_elig '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.pell_elig.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

END pell_elig;

PROCEDURE calc_term_pell(
                    cp_base_id            IN  igf_ap_fa_base_rec.base_id%TYPE,
                    cp_attendance_type    IN  igf_ap_attend_map.attendance_type%TYPE,
                    cp_ld_cal_type        IN  igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
                    cp_term_aid           IN  OUT NOCOPY NUMBER,
                    cp_return_status      IN  OUT NOCOPY VARCHAR2,
                    cp_message            IN  OUT NOCOPY VARCHAR2,
                    cp_called_from        IN  VARCHAR2,
                    cp_pell_schedule_code OUT NOCOPY VARCHAR2
          ) IS
/*
  ||  Created By : CDCRUZ
  ||  Created On : 19-NOV-2003
  ||  Purpose    : Procedure to calculate Pell amount for a given term
  ||  Known limitations, enhancements or remarks :
  ||  This wrapper takes in parameters
  ||  of Base id / Attendance Type/ Term Details
  ||  returns the Term Amount
  ||  and a return status of S/E  => Success/Error
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        14-Sep-2005     Build FA 157. Implemented term amount rounding.
  ||  bkkumar         01-Apr-04       Bug# 3409969 Added the logic to calculate the pell
  ||                                  award amount when the pell_formula = 3 , to derive the
  ||                                  term_instruction_time and annual instruction time
  ||                                  from the OSS.
  ||  CDCRUZ          19-NOV-2003     BUG# 3252832 FA-131 Cod updates
*/
CURSOR c_base( l_base_id igf_ap_fa_base_rec.base_id%TYPE
          ) IS
SELECT
    fa.person_id,
    fa.ci_cal_type,
    fa.ci_sequence_number,
    fa.pell_alt_expense
FROM igf_ap_fa_base_rec fa
WHERE fa.base_id = l_base_id ;

l_base_rec c_base%ROWTYPE;

-- Gets FA Anticipated key program details
CURSOR cur_get_ant_key_prog_ver(
                                cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                                cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                               )
IS
  SELECT
          ant_data.program_cd key_prog,
          prog.version_number key_prog_ver
  FROM
          igf_ap_fa_ant_data ant_data,
          igs_ps_ver prog
  WHERE
          ant_data.ld_cal_type = cp_ld_cal_type AND
          ant_data.ld_sequence_number = cp_ld_sequence_number AND
          ant_data.base_id = cp_base_id AND
          ant_data.program_cd = prog.course_cd AND
          prog.course_status = 'ACTIVE' AND
          ant_data.program_cd IS NOT NULL AND
          ROWNUM = 1
  ORDER BY prog.version_number DESC;

l_get_ant_key_prog_ver_rec cur_get_ant_key_prog_ver%ROWTYPE;

-- museshad (Build FA 157)
-- Returns the award rounding factor setup for the fund in Fund Manager
CURSOR cur_get_awd_round_fact(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT  LTRIM(RTRIM(roundoff_fact)) roundoff_fact
  FROM
          igf_aw_fund_mast_all fmast,
          igf_ap_fa_base_rec_all fabase
  WHERE
          fabase.base_id            =   cp_base_id                AND
          fabase.ci_cal_type        =   fmast.ci_cal_type         AND
          fabase.ci_sequence_number =   fmast.ci_sequence_number  AND
          UPPER(fmast.fund_code)    =   'PELL';

l_awd_round_fact_rec cur_get_awd_round_fact%ROWTYPE;

l_pell_setup_rec igf_gr_pell_setup_all%ROWTYPE;
l_pell_schedule VARCHAR2(30);
l_message fnd_new_messages.message_text%TYPE;
l_return_status VARCHAR2(30);

l_coa           NUMBER;
l_efc           NUMBER;
l_aid           NUMBER;
l_term_amt      NUMBER;
l_tp_amt        NUMBER;
l_actual_weeks  NUMBER;
l_program_cd      igs_en_stdnt_ps_att.course_cd%TYPE;
l_program_version igs_en_stdnt_ps_att.version_number%TYPE;
l_attendance_type igs_en_stdnt_ps_att.attendance_type%TYPE;
l_term_weeks   NUMBER;


BEGIN

OPEN c_base(cp_base_id);
FETCH c_base INTO l_base_rec;
CLOSE c_base;

   -- Get the students OSS Details
   -- get the key program from the term or spa table of enrollments.
   igf_ap_gen_001.get_key_program(cp_base_id        => cp_base_id,
                                  cp_course_cd      => l_program_cd,
                                  cp_version_number => l_program_version
                                  );

    IF l_program_cd IS NULL THEN
      -- Actual (Enrollment) key program details not available.
      -- Get it from Admissions
      get_key_prog_ver_frm_adm(
                                p_base_id       =>  cp_base_id,
                                p_key_prog_cd   =>  l_program_cd,
                                p_key_prog_ver  =>  l_program_version
                              );

      IF l_program_cd IS NULL AND igf_aw_coa_gen.canUseAnticipVal THEN
        -- Admissions does not have key program details
        -- Get it from FA Anticipated data.
        OPEN cur_get_ant_key_prog_ver(cp_base_id, cp_ld_cal_type, cp_ld_sequence_number);
        FETCH cur_get_ant_key_prog_ver INTO l_get_ant_key_prog_ver_rec;
        CLOSE cur_get_ant_key_prog_ver;

        l_program_cd      :=  l_get_ant_key_prog_ver_rec.key_prog;
        l_program_version :=  l_get_ant_key_prog_ver_rec.key_prog_ver;

        IF l_program_cd IS NULL THEN
          -- FA Anticipated data does not have key program details. Error out
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_term_pell.debug','Cannot compute key program details.');
          END IF;

          cp_return_status := 'E' ;
          fnd_message.set_name('IGS', 'IGS_EN_NO_KEY_PRG');
          fnd_message.set_token('PERSON', igf_gr_gen.get_per_num(cp_base_id));
          cp_message := fnd_message.get;
          RETURN;
        END IF;
      END IF;
    END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_term_pell.debug','Key Program > Course cd>' || l_program_cd || ' Version >' || TO_CHAR(l_program_version) );
   END IF;

  l_message := NULL;

 -- Get the Pell Setup
  get_pell_setup( cp_base_id         => cp_base_id,
                  cp_course_cd       => l_program_cd,
                  cp_version_number  => l_program_version,
                  cp_cal_type        => l_base_rec.ci_cal_type,
                  cp_sequence_number => l_base_rec.ci_sequence_number ,
                  cp_pell_setup_rec  => l_pell_setup_rec ,
                  cp_message         => l_message  ,
                  cp_return_status   => l_return_status );

IF  l_return_status = 'E' THEN
      cp_message       := l_message;
      cp_return_status := 'E' ;
      RETURN;
END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_term_pell.debug','Pell Setup Retrival Succesful for Primary key PELL_SEQ_ID- > ' ||  TO_CHAR(l_pell_setup_rec.PELL_SEQ_ID));
    END IF;


    -- Get Pell COA and EFC
    get_pell_coa_efc (
                      cp_base_id            => cp_base_id,
                      cp_attendance_type    => cp_attendance_type,
                      cp_pell_setup_rec     => l_pell_setup_rec  ,
                      cp_coa                => l_coa   ,
                      cp_efc                => l_efc  ,
                      cp_pell_schedule_code => l_pell_schedule  ,
                      cp_message            => l_message  ,
                      cp_return_status      => l_return_status );


     IF (l_return_status='E') THEN
         cp_message       := l_message ;
         cp_return_status := 'E' ;
         RETURN;
     END IF;
     l_coa := NVL(l_coa,0);

     cp_pell_schedule_code := l_pell_schedule ;

     -- Compute the Annual Pell Amount for the context attendance type
        get_pell_matrix_amt(
              cp_cal_type     => l_base_rec.ci_cal_type,
              cp_sequence_num => l_base_rec.ci_sequence_number,
              cp_efc          => l_efc,
              cp_pell_schd    => l_pell_schedule,
              cp_enrl_stat    => cp_attendance_type,
              cp_pell_coa     => l_coa,
              cp_pell_alt_exp => l_base_rec.pell_alt_expense,
              cp_called_from  => cp_called_from,
              cp_message      => l_message,
              cp_return_status => l_return_status,
              cp_aid           => l_aid
            ) ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_term_pell.debug','Term level return amount from get_pell_matrix_amt **************->' || TO_CHAR(l_aid) );
    END IF;

     IF (l_return_status='E') THEN
         cp_message       := l_message ;
         cp_return_status := 'E' ;
         RETURN;
     END IF;
     IF l_aid = 0 THEN
         fnd_message.set_name('IGF','IGF_AW_ZERO_TERM_PELL_AMT');
         fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(cp_ld_cal_type,cp_ld_sequence_number));
         cp_message       := fnd_message.get;
         cp_return_status := 'E' ;
         RETURN;
      END IF;
      -- Get the Term Level Amount
      IF l_pell_setup_rec.payment_method = 3 THEN

         l_term_weeks     := NULL;
         l_actual_weeks   := NULL;
         cp_return_status := NULL;
         cp_message       := NULL;
         get_pm_3_acad_term_wks(cp_ld_cal_type,
                                cp_ld_sequence_number,
                                l_program_cd,
                                l_program_version,
                                l_term_weeks,
                                l_actual_weeks,
                                cp_return_status,
                                cp_message
                               );

         IF cp_return_status = 'E' THEN
            RETURN;
         END IF;

         l_term_amt := ROUND((l_aid * l_term_weeks) / l_actual_weeks);

      ELSE -- if the payment method is not '3'
         l_term_amt := ROUND((l_aid/l_pell_setup_rec.payment_periods_num),2) ;
      END IF;

      IF UPPER(cp_called_from) = 'IGFGR005' THEN
        /* Round the term amount based on the award rounding factor setup in Fund Manager */
        OPEN cur_get_awd_round_fact(cp_base_id => cp_base_id);
        FETCH cur_get_awd_round_fact INTO l_awd_round_fact_rec;

        IF (cur_get_awd_round_fact%FOUND) AND (l_awd_round_fact_rec.roundoff_fact IS NOT NULL) THEN

          IF l_awd_round_fact_rec.roundoff_fact = '0.5' THEN
            l_term_amt := ROUND(l_term_amt, 2);

          ELSIF l_awd_round_fact_rec.roundoff_fact = '1' THEN
            l_term_amt := ROUND(l_term_amt);
         END IF;

        END IF;
        CLOSE cur_get_awd_round_fact;
      END IF;
      cp_term_aid      := l_term_amt;
      cp_return_status := 'S';

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_term_pell.debug','cp_term_aid ' || cp_term_aid );
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.calc_term_pell '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.calc_term_pell.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

END calc_term_pell;

PROCEDURE calc_ft_max_pell(
                    cp_base_id          IN igf_ap_fa_base_rec.base_id%TYPE,
                    cp_cal_type         IN igf_ap_fa_base_rec.ci_cal_type%TYPE,
                    cp_sequence_number  IN igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                    cp_flag             IN VARCHAR2,
                    cp_aid              IN OUT NOCOPY NUMBER,
                    cp_ft_aid           IN OUT NOCOPY NUMBER,
                    cp_return_status    IN OUT NOCOPY VARCHAR2,
                    cp_message          IN OUT NOCOPY VARCHAR2
                    )
IS
------------------------------------------------------------------
--Created by  : cdcruz, Oracle India
--Date created: 01-Dec-2003
--
--Purpose:
-- Note : value of the parameter cp_flag can have 2 values
-- FULL_TIME -> Full Time - Calculate using  Full-Time Attendance Type / Payment ISIR's EFC / 99999 COA
-- MAX_PELL -> Max Pell  - Calculate using  Full-Time Attendance Type / 0 EFC / 99999 COA
-- ACTUAL_PELL -> Actual amount
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- rasahoo    10-Mar-2004   Bug # 3491025 While Run mode (cp_flag) is Full time, the Pell COA will be calculated
--                          instead of taking it as 99999 which is the max value.
-------------------------------------------------------------------

-- Get RFMS Pell Details
CURSOR c_rfms( l_base_id igf_ap_fa_base_rec.base_id%TYPE
          ) IS
  SELECT
     RFMS.PELL_AMOUNT
    FROM
     igf_gr_rfms rfms
   WHERE
     rfms.base_id = l_base_id;

l_rfms_rec c_rfms%ROWTYPE;

-- Get
CURSOR c_coa( l_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
  SELECT
    fa.coa_pell pell_coa
  FROM
    igf_ap_fa_base_rec fa
  WHERE
     fa.base_id = l_base_id;

-- Get FA Anticipated Key Prog details
CURSOR cur_get_ant_key_prog_ver(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
IS
  SELECT
            ant_data.program_cd key_prog,
            prog.version_number key_prog_ver
  FROM
            igf_aw_awd_ld_cal_v     awd_year_terms,
            igf_ap_fa_ant_data      ant_data,
            igs_ps_ver              prog
  WHERE
            ant_data.ld_cal_type = awd_year_terms.ld_cal_type AND
            ant_data.ld_sequence_number = awd_year_terms.ld_sequence_number AND
            ant_data.base_id = cp_base_id and
            ant_data.program_cd = prog.course_cd AND
            prog.course_status = 'ACTIVE' AND
            ant_data.program_cd IS NOT NULL
  ORDER BY
            igf_aw_packaging.get_term_start_date(cp_base_id, awd_year_terms.ld_cal_type, awd_year_terms.ld_sequence_number) ASC,
            prog.version_number DESC;

l_get_ant_key_prog_ver_rec cur_get_ant_key_prog_ver%ROWTYPE;

l_coa_rec               c_coa%ROWTYPE;
l_reg_efc               NUMBER;
l_att_type              igs_en_stdnt_ps_att.attendance_type%TYPE;
l_efc                   NUMBER;
l_coa                   NUMBER;
l_ft_coa                NUMBER;
l_ft_aid                NUMBER;
l_program_cd            igs_en_stdnt_ps_att.course_cd%TYPE;
l_program_version       igs_en_stdnt_ps_att.version_number%TYPE;
l_pell_setup_rec        igf_gr_pell_setup_all%ROWTYPE;
l_ft_efc                NUMBER;
l_pell_schedule_code    VARCHAR2(30);


BEGIN

l_att_type := '1' ;
l_coa      := 99999 ;

IF cp_flag IN ('FULL_TIME','ACTUAL_PELL') THEN

    --- Get Pell EFC
      igf_aw_packng_subfns.get_fed_efc(
                                       l_base_id      => cp_base_id,
                                       l_awd_prd_code => NULL,
                                       l_efc_f        => l_reg_efc,
                                       l_pell_efc     => l_efc,
                                       l_efc_ay       => l_reg_efc
                                       );


ELSIF cp_flag = 'MAX_PELL' THEN
     -- Originate with Max Pell Award
     l_efc := 0 ;
END IF;

IF  cp_flag = 'MAX_PELL' THEN

                 get_pell_matrix_amt(
                     cp_cal_type     => cp_cal_type,
                     cp_sequence_num => cp_sequence_number,
                     cp_efc          => l_efc,
                     cp_pell_schd    => 'R',
                     cp_enrl_stat    => l_att_type,
                     cp_pell_coa     => l_coa,
                     cp_pell_alt_exp => 0,
                     cp_called_from  => 'PELLORIG',
                     cp_message      =>  cp_message,
                     cp_return_status => cp_return_status,
                     cp_aid           => cp_aid
                   ) ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_ft_max_pell.debug','Term level return amount from get_pell_matrix_amt **************->' || TO_CHAR(cp_aid) );
    END IF;
    IF (cp_return_status='E') THEN
        RETURN;
    END IF;

ELSIF  cp_flag = 'FULL_TIME' THEN  -- Get the Full time Pell.
      -- Get the students key program details
      -- Based on these details the Pell Setup record is arrived at
      igf_ap_gen_001.get_key_program(cp_base_id        => cp_base_id,
                                     cp_course_cd      => l_program_cd,
                                     cp_version_number => l_program_version
                                     );

    IF l_program_cd IS NULL THEN
      -- Actual (Enrollment) key program details not available.
      -- Get it from Admissions
      get_key_prog_ver_frm_adm(
                                p_base_id       =>  cp_base_id,
                                p_key_prog_cd   =>  l_program_cd,
                                p_key_prog_ver  =>  l_program_version
                              );

      IF l_program_cd IS NULL AND igf_aw_coa_gen.canUseAnticipVal THEN
        -- Admissions does not have key program details
        -- Get it from FA Anticipated data.
        OPEN cur_get_ant_key_prog_ver(cp_base_id);
        FETCH cur_get_ant_key_prog_ver INTO l_get_ant_key_prog_ver_rec;
        CLOSE cur_get_ant_key_prog_ver;

        l_program_cd      :=  l_get_ant_key_prog_ver_rec.key_prog;
        l_program_version :=  l_get_ant_key_prog_ver_rec.key_prog_ver;

        IF l_program_cd IS NULL THEN
          -- FA Anticipated data does not have key program details. Error out
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_ft_max_pell.debug','Cannot compute key program details');
          END IF;

          cp_return_status := 'E' ;
          fnd_message.set_name('IGS', 'IGS_EN_NO_KEY_PRG');
          fnd_message.set_token('PERSON', igf_gr_gen.get_per_num(cp_base_id));
          cp_message := fnd_message.get;
          RETURN;
        END IF;
      END IF;
    END IF;

      -- Get the Pell Setup
      get_pell_setup( cp_base_id         => cp_base_id,
                      cp_course_cd       => l_program_cd,
                      cp_version_number  => l_program_version,
                      cp_cal_type        => cp_cal_type,
                      cp_sequence_number => cp_sequence_number,
                      cp_pell_setup_rec  => l_pell_setup_rec ,
                      cp_message         => cp_message ,
                      cp_return_status   => cp_return_status );
      -- Get Pell COA
      get_pell_coa_efc( cp_base_id            =>  cp_base_id,
                        cp_attendance_type    =>  '1',
                        cp_pell_setup_rec     =>  l_pell_setup_rec,
                        cp_coa                =>  l_ft_coa ,
                        cp_efc                =>  l_ft_efc,
                        cp_pell_schedule_code =>  l_pell_schedule_code,
                        cp_message            =>  cp_message,
                        cp_return_status      =>  cp_return_status
                      ) ;
      -- Get pell amount from  Pell matrix
      get_pell_matrix_amt(
                           cp_cal_type     => cp_cal_type,
                           cp_sequence_num => cp_sequence_number,
                           cp_efc          => l_ft_efc,
                           cp_pell_schd    => l_pell_schedule_code , --'R',
                           cp_enrl_stat    => l_att_type,
                           cp_pell_coa     => l_ft_coa,
                           cp_pell_alt_exp => 0,
                           cp_called_from  => 'PELLORIG',
                           cp_message      =>  cp_message,
                           cp_return_status => cp_return_status,
                           cp_aid           => cp_aid
                         ) ;

ELSE
  -- Actual Attendance Type
  -- This will be called only from Pell Originations process
  -- Hence RFMS record has to exist

   OPEN c_rfms(cp_base_id);
   FETCH c_rfms INTO l_rfms_rec;
   IF c_rfms%NOTFOUND THEN
      CLOSE c_rfms;
      fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
      cp_message := fnd_message.get;
      cp_return_status := 'E' ;
      RETURN;
   END IF;

  cp_aid := ROUND(l_rfms_rec.pell_amount,2) ;

END IF;

IF cp_flag in ('FULL_TIME','MAX_PELL')  THEN

   cp_ft_aid := ROUND(cp_aid,2) ;

ELSE
   -- Compute the Full Time Amount for Actual EFC/COA

   -- Fetch the Full time COA for the student
   OPEN c_coa(cp_base_id);
   FETCH c_coa INTO l_coa_rec;
   CLOSE c_coa;

   -- No check for COA%notfound because per new rule
   -- You can create pell even if he has zero COA.

                 get_pell_matrix_amt(
                     cp_cal_type      => cp_cal_type,
                     cp_sequence_num  => cp_sequence_number,
                     cp_efc           => l_efc,
                     cp_pell_schd     => 'R',
                     cp_enrl_stat     => '1',
                     cp_pell_coa      => NVL(l_coa_rec.pell_coa,0),
                     cp_pell_alt_exp  => 0,
                     cp_called_from   => 'PELLORIG',
                     cp_message       =>  cp_message,
                     cp_return_status => cp_return_status,
                     cp_aid           => l_ft_aid
                   ) ;

     cp_ft_aid := ROUND(l_ft_aid,2) ;

END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_pell_calc.calc_ft_max_pell.debug','cp_ft_aid ' || cp_ft_aid );
END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_pell_calc.calc_ft_max_pell '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_pell_calc.calc_ft_max_pell.exception','sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;


END calc_ft_max_pell;

END igf_gr_pell_calc;

/
