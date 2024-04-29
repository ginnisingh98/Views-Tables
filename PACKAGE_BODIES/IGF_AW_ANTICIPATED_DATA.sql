--------------------------------------------------------
--  DDL for Package Body IGF_AW_ANTICIPATED_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_ANTICIPATED_DATA" AS
/* $Header: IGFAW20B.pls 120.4 2006/01/27 00:59:32 ridas noship $ */


  PROCEDURE process_anti_data(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                              p_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                              p_interface           igf_aw_anticpt_ints%ROWTYPE,
                              p_delete_flag         VARCHAR2)
    IS
    ------------------------------------------------------------------
    --Created by  : ridas, Oracle India
    --Date created: 02-NOV-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------


    --Cursor to fetch organizational unit
    CURSOR  c_org_unit(cp_org_unit    igf_ap_fa_ant_data.org_unit_cd%TYPE)
          IS
      SELECT 'x'
        FROM igs_or_inst_org_base_v
       WHERE party_number  = cp_org_unit
         AND inst_org_ind = 'O'
         AND SYSDATE BETWEEN start_dt AND NVL(end_dt,SYSDATE);

    l_org_unit  c_org_unit%ROWTYPE;


    --Cursor to fetch program type
    CURSOR  c_prog_type(cp_prog_type    igf_ap_fa_ant_data.program_type%TYPE)
          IS
      SELECT 'x'
        FROM igs_ps_type_v
       WHERE course_type = cp_prog_type
         AND NVL(closed_ind,'N')<>'Y';

    l_prog_type  c_prog_type%ROWTYPE;


    --Cursor to fetch program location
    CURSOR  c_prog_loc(cp_prog_loc    igf_ap_fa_ant_data.program_location_cd%TYPE)
          IS
      SELECT 'x'
        FROM igs_ad_location
       WHERE location_cd  = cp_prog_loc
         AND NVL(closed_ind,'N')<>'Y';

    l_prog_loc  c_prog_loc%ROWTYPE;


    --Cursor to fetch program code
    CURSOR  c_prog_cd(cp_prog_cd    igf_ap_fa_ant_data.program_cd%TYPE)
          IS
      SELECT 'x'
        FROM igs_ps_ver
       WHERE course_cd  = cp_prog_cd
         AND SYSDATE BETWEEN start_dt AND NVL(end_dt,SYSDATE)
         AND rownum = 1;

    l_prog_cd  c_prog_cd%ROWTYPE;


    --Cursor to fetch class standing
    CURSOR  c_class_stnd(cp_class_stnd    igf_ap_fa_ant_data.class_standing%TYPE)
          IS
      SELECT 'x'
        FROM igs_pr_class_std_v
       WHERE class_standing = cp_class_stnd
         AND NVL(closed_ind,'N')<>'Y';

    l_class_stnd  c_class_stnd%ROWTYPE;


    --Cursor to fetch residency status and house status
    CURSOR  c_res_status(cp_lookup_code    igs_lookups_view.lookup_code%TYPE,
                         cp_lookup_type    igs_lookups_view.lookup_type%TYPE
                         )
          IS
      SELECT 'x'
        FROM igs_lookups_view
       WHERE lookup_type    = cp_lookup_type
         AND lookup_code    = cp_lookup_code
         AND enabled_flag   = 'Y';

    l_res_status  c_res_status%ROWTYPE;

    l_house_status  c_res_status%ROWTYPE;


    --Cursor to fetch attendance type
    CURSOR  c_atten_type(cp_atten_type    igf_ap_fa_ant_data.attendance_type%TYPE)
          IS
      SELECT 'x'
        FROM igs_en_atd_type
       WHERE attendance_type = cp_atten_type
         AND NVL(closed_ind,'N')<>'Y';

    l_atten_type  c_atten_type%ROWTYPE;


    --Cursor to fetch attendance mode
    CURSOR  c_atten_mode(cp_atten_mode    igf_ap_fa_ant_data.attendance_mode%TYPE)
          IS
      SELECT 'x'
        FROM igs_en_atd_mode
       WHERE attendance_mode = cp_atten_mode
         AND NVL(closed_ind,'N')<>'Y';

    l_atten_mode  c_atten_mode%ROWTYPE;


    --Cursor to retrieve Anticipated Data
    CURSOR c_ant_data (cp_base_id             igf_ap_fa_ant_data.base_id%TYPE,
                       cp_ld_cal_type         igf_ap_fa_ant_data.ld_cal_type%TYPE,
                       cp_ld_sequence_number  igf_ap_fa_ant_data.ld_sequence_number%TYPE)
          IS
      SELECT ant.rowid row_id,
             ant.*
        FROM igf_ap_fa_ant_data ant
       WHERE base_id            = cp_base_id
         AND ld_cal_type        = cp_ld_cal_type
         AND ld_sequence_number = cp_ld_sequence_number;

    l_ant_data    c_ant_data%ROWTYPE;

    lv_set_ant_data     VARCHAR2(1);
    lv_rowid            ROWID;
    lv_ret_status       VARCHAR2(1);
    lv_message          VARCHAR2(500);
    lv_msg_text         VARCHAR2(200);
    ln_msg_index        NUMBER;


  BEGIN
    lv_set_ant_data :=  'Y';

    --validate organizational unit
    IF p_interface.org_unit_cd  IS NOT NULL THEN
        OPEN c_org_unit(p_interface.org_unit_cd );
        FETCH c_org_unit INTO l_org_unit;
        IF c_org_unit%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_org_unit%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','ORG_UNIT_CD '||': '||p_interface.org_unit_cd );
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_org_unit;
    END IF;

    --validate program type
    IF p_interface.program_type IS NOT NULL THEN
        OPEN c_prog_type(p_interface.program_type);
        FETCH c_prog_type INTO l_prog_type;
        IF c_prog_type%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_prog_type%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','PROGRAM_TYPE'||': '||p_interface.program_type);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_prog_type;
    END IF;

    --validate program location
    IF p_interface.program_location_cd IS NOT NULL THEN
        OPEN c_prog_loc(p_interface.program_location_cd);
        FETCH c_prog_loc INTO l_prog_loc;
        IF c_prog_loc%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_prog_loc%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','PROGRAM_LOCATION_CD'||': '||p_interface.program_location_cd);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_prog_loc;
    END IF;

    --validate program code
    IF p_interface.program_cd IS NOT NULL THEN
        OPEN c_prog_cd(p_interface.program_cd);
        FETCH c_prog_cd INTO l_prog_cd;
        IF c_prog_cd%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_prog_cd%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','PROGRAM_CD'||': '||p_interface.program_cd);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_prog_cd;
    END IF;

    --validate class standing
    IF p_interface.class_standing IS NOT NULL THEN
        OPEN c_class_stnd(p_interface.class_standing);
        FETCH c_class_stnd INTO l_class_stnd;
        IF c_class_stnd%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_class_stnd%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','CLASS_STANDING'||': '||p_interface.class_standing);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_class_stnd;
    END IF;

    --validate residency status
    IF p_interface.residency_status_code IS NOT NULL THEN
        OPEN c_res_status(p_interface.residency_status_code,'PE_RES_STATUS');
        FETCH c_res_status INTO l_res_status;
        IF c_res_status%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_res_status%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','RESIDENCY_STATUS_CODE'||': '||p_interface.residency_status_code);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_res_status;
    END IF;

    --validate housing status
    IF p_interface.housing_status_code IS NOT NULL THEN
        OPEN c_res_status(p_interface.housing_status_code,'PE_TEA_PER_RES');
        FETCH c_res_status INTO l_house_status;
        IF c_res_status%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_res_status%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','HOUSING_STATUS_CODE'||': '||p_interface.housing_status_code);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_res_status;
    END IF;

    --validate attendance type
    IF p_interface.attendance_type IS NOT NULL THEN
        OPEN c_atten_type(p_interface.attendance_type);
        FETCH c_atten_type INTO l_atten_type;
        IF c_atten_type%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_atten_type%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','ATTENDANCE_TYPE'||': '||p_interface.attendance_type);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_atten_type;
    END IF;

    --validate attendance mode
    IF p_interface.attendance_mode IS NOT NULL THEN
        OPEN c_atten_mode(p_interface.attendance_mode);
        FETCH c_atten_mode INTO l_atten_mode;
        IF c_atten_mode%NOTFOUND THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','c_atten_mode%NOTFOUND');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','ATTENDANCE_MODE'||': '||p_interface.attendance_mode);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
        CLOSE c_atten_mode;
    END IF;

    --validate months enrolled number
    IF p_interface.months_enrolled_num IS NOT NULL THEN
        IF p_interface.months_enrolled_num NOT BETWEEN 1 AND 12 THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','p_interface.months_enrolled_num NOT BETWEEN 1 AND 12');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','MONTHS_ENROLLED_NUM'||': '||p_interface.months_enrolled_num);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
    END IF;

    --validate credit point number
    IF p_interface.credit_points_num IS NOT NULL THEN
        IF p_interface.credit_points_num < 0 THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','p_interface.credit_points_num < 0');
            END IF;

            lv_set_ant_data :=  'N';
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','CREDIT_POINTS_NUM'||': '||p_interface.credit_points_num);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;
    END IF;

    --to check OSS attributes
    igs_ge_msg_stack.initialize;
    --Bug #4164450
    igf_aw_coa_gen.check_oss_attrib (
                                     p_interface.org_unit_cd ,
                                     p_interface.program_cd ,
                                     p_interface.program_type,
                                     p_interface.program_location_cd,
                                     p_interface.attendance_type,
                                     p_interface.attendance_mode,
                                     lv_ret_status
                                     );

    IF lv_ret_status <>'S' THEN
        IF igs_ge_msg_stack.count_msg > 0 THEN

            FOR i IN 1..igs_ge_msg_stack.count_msg
            LOOP
                igs_ge_msg_stack.get(i,'F',lv_msg_text, ln_msg_index);
                IF i = 1 THEN
                    lv_message := RPAD(' ',5)        ||
                                  lv_msg_text;
                ELSE
                    lv_message := lv_message         ||
                                  fnd_global.newline ||
                                  RPAD(' ',5)        ||
                                  lv_msg_text;
                END IF;
            END LOOP;
            fnd_file.put_line(fnd_file.log,lv_message);
        END IF;
    END IF;


    IF lv_set_ant_data = 'Y' THEN
        IF p_interface.import_record_type = 'U' THEN
            OPEN c_ant_data(p_base_id,p_ld_cal_type,p_ld_sequence_number);
            FETCH c_ant_data INTO l_ant_data;
            CLOSE c_ant_data;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','calling igf_ap_fa_ant_data_pkg.update_row');
            END IF;


            igf_ap_fa_ant_data_pkg.update_row (
              x_mode                              => 'R',
              x_rowid                             => l_ant_data.row_id,
              x_base_id                           => p_base_id,
              x_ld_cal_type                       => l_ant_data.ld_cal_type,
              x_ld_sequence_number                => l_ant_data.ld_sequence_number,
              x_org_unit_cd                       => p_interface.org_unit_cd ,
              x_program_type                      => p_interface.program_type,
              x_program_location_cd               => p_interface.program_location_cd,
              x_program_cd                        => p_interface.program_cd,
              x_class_standing                    => p_interface.class_standing,
              x_residency_status_code             => p_interface.residency_status_code,
              x_housing_status_code               => p_interface.housing_status_code,
              x_attendance_type                   => p_interface.attendance_type,
              x_attendance_mode                   => p_interface.attendance_mode,
              x_months_enrolled_num               => p_interface.months_enrolled_num,
              x_credit_points_num                 => p_interface.credit_points_num
            );

            fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_interface.import_record_type = 'I' THEN
            lv_rowid := NULL;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','calling igf_ap_fa_ant_data_pkg.insert_row');
            END IF;

            igf_ap_fa_ant_data_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => lv_rowid,
              x_base_id                           => p_base_id,
              x_ld_cal_type                       => p_ld_cal_type,
              x_ld_sequence_number                => p_ld_sequence_number,
              x_org_unit_cd                       => p_interface.org_unit_cd ,
              x_program_type                      => p_interface.program_type,
              x_program_location_cd               => p_interface.program_location_cd,
              x_program_cd                        => p_interface.program_cd,
              x_class_standing                    => p_interface.class_standing,
              x_residency_status_code             => p_interface.residency_status_code,
              x_housing_status_code               => p_interface.housing_status_code,
              x_attendance_type                   => p_interface.attendance_type,
              x_attendance_mode                   => p_interface.attendance_mode,
              x_months_enrolled_num               => p_interface.months_enrolled_num,
              x_credit_points_num                 => p_interface.credit_points_num
            );


            fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        END IF;

        IF p_delete_flag = 'Y' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','deleting from igf_aw_anticpt_ints');
            END IF;

            DELETE FROM igf_aw_anticpt_ints
             WHERE batch_num         = p_interface.batch_num
               AND ci_alternate_code = p_interface.ci_alternate_code
               AND ld_alternate_code = p_interface.ld_alternate_code
               AND person_number     = p_interface.person_number;

        ELSE
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','updating in igf_aw_anticpt_ints');
            END IF;

            UPDATE igf_aw_anticpt_ints
               SET IMPORT_STATUS_TYPE = 'I'
             WHERE batch_num         = p_interface.batch_num
               AND ci_alternate_code = p_interface.ci_alternate_code
               AND ld_alternate_code = p_interface.ld_alternate_code
               AND person_number     = p_interface.person_number;

        END IF;

    ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','No data Imported');
        END IF;

        fnd_message.set_name('IGS','IGS_EN_NO_DATA_IMP');
        fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.process_anti_data.debug','updating in igf_aw_anticpt_ints');
        END IF;

        UPDATE igf_aw_anticpt_ints
           SET IMPORT_STATUS_TYPE = 'E'
         WHERE batch_num         = p_interface.batch_num
           AND ci_alternate_code = p_interface.ci_alternate_code
           AND ld_alternate_code = p_interface.ld_alternate_code
           AND person_number     = p_interface.person_number;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_ANTICIPATED_DATA.PROCESS_ANTI_DATA :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_anticipated_data.process_anti_data.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END process_anti_data;



  -- This procedure is the callable from concurrent manager
  PROCEDURE main  ( errbuf          OUT NOCOPY VARCHAR2,
                    retcode         OUT NOCOPY NUMBER,
                    p_award_year    IN         VARCHAR2,
                    p_batch_id      IN         igf_ap_li_bat_ints.batch_num%TYPE,
                    p_del_ind       IN         VARCHAR2 )
    IS

    ------------------------------------------------------------------
    --Created by  : ridas, Oracle India
    --Date created: 02-NOV-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
	--tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    -------------------------------------------------------------------

    --Cursor to retrieve Anticipated Data From Interface Table
    CURSOR c_interface(cp_batch_id        igf_aw_anticpt_ints.batch_num%TYPE,
                       cp_alternate_code  igf_aw_anticpt_ints.ci_alternate_code%TYPE)
          IS
      SELECT intf.*
        FROM igf_aw_anticpt_ints intf
       WHERE intf.batch_num           = cp_batch_id
         AND intf.ci_alternate_code   = cp_alternate_code
         AND intf.import_status_type  = 'R'
         AND intf.import_record_type in ('I','U')
    ORDER BY intf.person_number;


    --Cursor to check Anticipated Data From Interface Table with status as 'R'
    CURSOR c_chk_interface(cp_batch_id        igf_aw_anticpt_ints.batch_num%TYPE,
                           cp_alternate_code  igf_aw_anticpt_ints.ci_alternate_code%TYPE)
          IS
      SELECT 'x'  val
        FROM igf_aw_anticpt_ints intf
       WHERE intf.batch_num           = cp_batch_id
         AND intf.ci_alternate_code   = cp_alternate_code
         AND intf.import_status_type  = 'R'
         AND intf.import_record_type in ('I','U')
         AND rownum = 1;

    l_chk_interface c_chk_interface%ROWTYPE;


    --Cursor to retrieve Anticipated Data
    CURSOR c_ant_data (cp_base_id             igf_ap_fa_ant_data.base_id%TYPE,
                       cp_ld_cal_type         igf_ap_fa_ant_data.ld_cal_type%TYPE,
                       cp_ld_sequence_number  igf_ap_fa_ant_data.ld_sequence_number%TYPE)
          IS
      SELECT ant.base_id
        FROM igf_ap_fa_ant_data ant
       WHERE base_id            = cp_base_id
         AND ld_cal_type        = cp_ld_cal_type
         AND ld_sequence_number = cp_ld_sequence_number;

    l_ant_data    c_ant_data%ROWTYPE;


    --Cursor to validate batch no
    CURSOR c_chk_batch(cp_batch_num   igf_ap_li_bat_ints.batch_num%TYPE,
                       cp_batch_type  igf_ap_li_bat_ints.batch_type%TYPE)
          IS
      SELECT batch_num
        FROM igf_ap_li_bat_ints
       WHERE batch_num = cp_batch_num
         AND batch_type= cp_batch_type
         AND rownum    = 1;

    l_chk_batch     c_chk_batch%ROWTYPE;


    CURSOR c_get_cal_typ_seq_num(p_alternate_code   igs_ca_inst_all.alternate_code%TYPE,
                                 p_cal_type         igs_ca_inst_all.cal_type%TYPE,
                                 p_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                                  )
          IS
      SELECT ld_cal_type, ld_sequence_number
        FROM igf_aw_awd_ld_cal_v  cal
       WHERE cal.aw_cal_type        = p_cal_type
         AND cal.aw_sequence_number = p_sequence_number
         AND cal.ld_alternate_code  = p_alternate_code;

    l_get_cal_typ_seq_num     c_get_cal_typ_seq_num%ROWTYPE;


    lv_ci_cal_type          igs_ca_inst_all.cal_type%TYPE;
    ln_ci_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    lv_alternate_code       igs_ca_inst_all.alternate_code%TYPE;
    lv_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    ln_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    ln_person_id            igf_ap_fa_base_rec_all.person_id%TYPE;
    ln_base_id              igf_ap_fa_base_rec_all.base_id%TYPE;
    lv_person_number        igf_aw_anticpt_ints.person_number%TYPE;
    param_exception         EXCEPTION;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode               := 0;
    errbuf                := NULL;
    lv_ci_cal_type        := TRIM(SUBSTR(p_award_year,1,10));
    ln_ci_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));
    lv_alternate_code     := igf_gr_gen.get_alt_code(lv_ci_cal_type,ln_ci_sequence_number);
    lv_person_number      := '0';

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','p_award_year:'||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','p_batch_id:'||p_batch_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','p_del_ind:'||p_del_ind);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),40) ||': '|| lv_alternate_code);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','BATCH_NUMBER'),40) ||': '||p_batch_id);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DELETE_FLAG'),40) ||': '||igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_del_ind) );

    fnd_file.new_line(fnd_file.log,2);

    IF (p_award_year IS NULL) OR (p_batch_id IS NULL) OR (p_del_ind IS NULL) THEN
      RAISE param_exception;

    ELSIF lv_ci_cal_type IS NULL OR ln_ci_sequence_number IS NULL THEN
      RAISE param_exception;
    END IF;

    --Check whether batch number exist or not
    OPEN c_chk_batch(p_batch_id,'ANT');
    FETCH c_chk_batch INTO l_chk_batch;
    CLOSE c_chk_batch;

    IF l_chk_batch.batch_num IS NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','l_chk_batch.batch_num IS NULL');
        END IF;

        fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE param_exception;
    END IF;

    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');

    --check Anticipated Data From Interface Table with status as 'R'
    OPEN c_chk_interface(p_batch_id,lv_alternate_code);
    FETCH c_chk_interface INTO l_chk_interface;
    CLOSE c_chk_interface;

    IF l_chk_interface.val IS NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','l_chk_interface.val IS NULL');
        END IF;

        fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
    END IF;


    --Validate the person and INSERT/UPDATE based on the record type
    FOR l_interface IN c_interface(p_batch_id,lv_alternate_code)
    LOOP
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','validating person number :'||l_interface.person_number);
        END IF;

        fnd_file.new_line(fnd_file.log,1);

        IF lv_person_number <> l_interface.person_number THEN
            fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
            fnd_message.set_token('STDNT',l_interface.person_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            --here call to the generic wrapper is being made to check the validity of the perosn and base record
            igf_ap_gen.check_person(l_interface.person_number,lv_ci_cal_type,ln_ci_sequence_number,ln_person_id,ln_base_id);
        END IF;

        lv_person_number  :=  l_interface.person_number;

        IF ln_person_id IS NULL THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','ln_person_id IS NULL');
            END IF;

            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        ELSE
            IF ln_base_id IS NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','ln_base_id IS NULL');
              END IF;

              fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
              fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
            ELSE
              l_get_cal_typ_seq_num := NULL;

              OPEN c_get_cal_typ_seq_num(l_interface.ld_alternate_code,
                                         lv_ci_cal_type,
                                         ln_ci_sequence_number
                                         );

              FETCH c_get_cal_typ_seq_num INTO l_get_cal_typ_seq_num;
              CLOSE c_get_cal_typ_seq_num;

              fnd_message.set_name('IGF','IGF_AW_PROC_TERM');
              fnd_message.set_token('TERM',l_interface.ld_alternate_code);
              fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);


              IF l_get_cal_typ_seq_num.ld_cal_type IS NULL OR l_get_cal_typ_seq_num.ld_sequence_number IS NULL THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','l_get_cal_typ_seq_num IS NULL');
                END IF;

                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','LD_ALTERNATE_CODE'||': '||l_interface.ld_alternate_code);
                fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','updating in igf_aw_anticpt_ints');
                END IF;

                UPDATE igf_aw_anticpt_ints
                   SET IMPORT_STATUS_TYPE = 'E'
                 WHERE batch_num         = l_interface.batch_num
                   AND ci_alternate_code = l_interface.ci_alternate_code
                   AND ld_alternate_code = l_interface.ld_alternate_code
                   AND person_number     = l_interface.person_number;


              ELSE
                lv_ld_cal_type        := l_get_cal_typ_seq_num.ld_cal_type;
                ln_ld_sequence_number := l_get_cal_typ_seq_num.ld_sequence_number;


                l_ant_data := NULL;

                OPEN c_ant_data(ln_base_id,lv_ld_cal_type,ln_ld_sequence_number);
                FETCH c_ant_data INTO l_ant_data;
                CLOSE c_ant_data;

                IF l_interface.import_record_type = 'U' THEN
                    IF l_ant_data.base_id IS NULL THEN
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','No anticipated data for record type=U');
                        END IF;

                        fnd_message.set_name('IGF','IGF_AW_IMP_ANT_AVAL');
                        fnd_message.set_token('REC_TYPE',l_interface.import_record_type);
                        fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','updating in igf_aw_anticpt_ints');
                        END IF;

                        UPDATE igf_aw_anticpt_ints
                           SET IMPORT_STATUS_TYPE = 'E'
                         WHERE batch_num         = l_interface.batch_num
                           AND ci_alternate_code = l_interface.ci_alternate_code
                           AND ld_alternate_code = l_interface.ld_alternate_code
                           AND person_number     = l_interface.person_number;

                    ELSE
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','calling process_anti_data');
                        END IF;

                        process_anti_data(ln_base_id,lv_ld_cal_type,ln_ld_sequence_number,l_interface,p_del_ind);
                    END IF;

                ELSIF l_interface.import_record_type = 'I' THEN
                    IF l_ant_data.base_id IS NOT NULL THEN
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','anticipated data available for record type=I');
                        END IF;

                        fnd_message.set_name('IGF','IGF_AW_IMP_ANT_NOT_AVAL');
                        fnd_message.set_token('REC_TYPE',l_interface.import_record_type);
                        fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','updating in igf_aw_anticpt_ints');
                        END IF;

                        UPDATE igf_aw_anticpt_ints
                           SET IMPORT_STATUS_TYPE = 'E'
                         WHERE batch_num         = l_interface.batch_num
                           AND ci_alternate_code = l_interface.ci_alternate_code
                           AND ld_alternate_code = l_interface.ld_alternate_code
                           AND person_number     = l_interface.person_number;

                    ELSE
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_anticipated_data.main.debug','calling process_anti_data');
                        END IF;

                        process_anti_data(ln_base_id,lv_ld_cal_type,ln_ld_sequence_number,l_interface,p_del_ind);
                    END IF;

                END IF;
              END IF;
            END IF;
        END IF;
    COMMIT;

    END LOOP;


    EXCEPTION
      WHEN param_exception THEN
        retcode:=2;
        fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN app_exception.record_lock_exception THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN OTHERS THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get || SQLERRM;

  END main;


END igf_aw_anticipated_data;

/
