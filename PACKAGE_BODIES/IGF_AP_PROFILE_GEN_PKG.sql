--------------------------------------------------------
--  DDL for Package Body IGF_AP_PROFILE_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_PROFILE_GEN_PKG" AS
/* $Header: IGFAP48B.pls 120.4 2006/02/14 23:05:30 ridas noship $ */
------------------------------------------------------------------
--Created by  : ugummall, Oracle India
--Date created: 04-AUG-2004
--
--Purpose:  Generic routines used in self-service pages and PROFILE Import Process.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

FUNCTION convert_int(col_value VARCHAR2)
RETURN VARCHAR2 IS
 /*
  ||  Created By : ugummall
  ||  Created On : 11-Aug-2004
  ||  Purpose : This function will return the  numberic value  of the given column value  , i.e taken through the parameter
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

BEGIN
  RETURN TO_NUMBER(col_value);
EXCEPTION WHEN others THEN
  RETURN col_value;
END convert_int ;

PROCEDURE create_base_record  (
                                p_css_id        IN          NUMBER,
                                p_person_id     IN          NUMBER,
                                p_batch_year    IN          NUMBER,
                                x_msg_data      OUT NOCOPY  VARCHAR2,
                                x_return_status OUT NOCOPY  VARCHAR2
                              )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Insert a New FA BASE Record if it doesn't exist.
  ||          2. Create a record in PROFILE matched table.
  ||          3. Create a record in FNAR table.
  ||          4. Update PROFILE interface record status to "MATCHED".
  ||          5. Deletes corresponding records in match details and person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who           When            What
  ||  ridas         14-Feb-2006     Bug #5021084. Removed trunc function from cursor C_SSN.
  */

  -- Cursor to get cal_type and sequence_number from batch_year
  CURSOR cur_get_cal_sequence (cp_batch_year igf_ap_batch_aw_map.batch_year%TYPE) IS
    SELECT ibm.ci_cal_type, ibm.ci_sequence_number
      FROM IGF_AP_BATCH_AW_MAP ibm
     WHERE ibm.batch_year = cp_batch_year;

  rec_get_cal_sequence  cur_get_cal_sequence%ROWTYPE;

  lv_cal_type         igf_ap_batch_aw_map.ci_cal_type%TYPE;
  lv_sequence_number  igf_ap_batch_aw_map.ci_sequence_number%TYPE;
  lv_base_id          igf_ap_fa_base_rec_all.base_id%TYPE;
  lv_cssp_id          igf_ap_css_profile.cssp_id%TYPE;

  lv_profile_value   VARCHAR2(10);
  CURSOR c_ssn(
               cp_person_id NUMBER
              ) IS
    SELECT api_person_id,
           api_person_id_uf,
           end_dt
      FROM igs_pe_alt_pers_id
     WHERE pe_person_id = cp_person_id
       AND person_id_type LIKE 'SSN'
       AND SYSDATE BETWEEN start_dt AND NVL(end_dt,SYSDATE);
  l_ssn c_ssn%ROWTYPE;

BEGIN

  fnd_msg_pub.initialize;
  x_return_status := fnd_api.g_ret_sts_success;
  SAVEPOINT SP_PROFILE;
  x_msg_data := '';

  fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','lv_profile_value:'||NVL(lv_profile_value,'N'));
  END IF;
  IF NVL(lv_profile_value,'N') = 'Y' THEN
    OPEN c_ssn(p_person_id);
    FETCH c_ssn INTO l_ssn;
    IF c_ssn%NOTFOUND THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','c_ssn%NOTFOUND. raising error');
      END IF;
      CLOSE c_ssn;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('IGF','IGF_AP_SSN_FOR_BASEREC');
      x_msg_data := x_msg_data || ' ' || fnd_message.get;
      RETURN;
    ELSE
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','c_ssn%FOUND.');
      END IF;
      CLOSE c_ssn;
    END IF;
  END IF;

  IGF_AP_PROFILE_MATCHING_PKG.ss_wrap_create_base_record(p_css_id,p_person_id,p_batch_year);
  -- Fa Base Record got created successfully. Store success message.
  fnd_message.set_name('IGF', 'IGF_AP_SUCCESS_FA_BASE');
  x_msg_data := x_msg_data || ' ' || fnd_message.get;
  x_return_status := 'S';

EXCEPTION WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.create_base_record.exception','The exception is : ' || SQLERRM );
    END IF;
    ROLLBACK TO SP_PROFILE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.create_base_record');
    fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
    igs_ge_msg_stack.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

   fnd_message.set_name('IGF','IGF_AP_FAIL_FA_BASE');
   x_msg_data := fnd_message.get;
   x_return_status := FND_API.G_RET_STS_ERROR;

END create_base_record;

PROCEDURE create_person_record  (
                                  p_css_id        IN          NUMBER,
                                  p_person_id     OUT NOCOPY  NUMBER,
                                  p_batch_year    IN          NUMBER,
                                  x_msg_data      OUT NOCOPY  VARCHAR2,
                                  x_return_status OUT NOCOPY  VARCHAR2
                              )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Creates a person record.
  ||          2. Creates a person address record.
  ||          3. Creates a FA Base Record.
  ||          4. Creates a record in PROFILE matched table.
  ||          5. Creates a record in FNAR table.
  ||          6. Updates PROFILE interface record status to "MATCHED".
  ||          7. Deletes corresponding records in match details and person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */

  lv_message2   VARCHAR2(4000);

BEGIN

  fnd_msg_pub.initialize;
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := '';

  SAVEPOINT SP_CREATE_PERSON;

    IGF_AP_PROFILE_MATCHING_PKG.ss_wrap_create_person_record (p_css_id);
    fnd_message.set_name('IGF', 'IGF_AP_SUCCESS_CREATE_PERSON');
    x_msg_data := x_msg_data || ' ' ||fnd_message.get;
    x_return_status := 'S';


EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.create_person_record.exception','The exception is : ' || SQLERRM );
    END IF;
    ROLLBACK TO SP_CREATE_PERSON;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.create_person_record');
    fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
    igs_ge_msg_stack.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

END create_person_record;

PROCEDURE delete_person_match ( p_css_id   IN    NUMBER)
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Deletes records in match details table (child records)
  ||          2. Deletes the person match record (parent record)
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */

  -- Cursor to fetch apm_id from person match table of an profile interface record.
  CURSOR cur_get_person_match ( cp_css_id  igf_ap_person_match_all.css_id%TYPE) IS
    SELECT ROWID row_id, apm_id
      FROM IGF_AP_PERSON_MATCH_ALL permatch
     WHERE permatch.css_id = cp_css_id;

  -- Cursor to fetch rowids of child records (match detail records) of person match record.
  CURSOR cur_get_match_detail ( cp_apm_id  igf_ap_person_match_all.apm_id%TYPE) IS
    SELECT ROWID row_id
      FROM IGF_AP_MATCH_DETAILS matchdtls
     WHERE matchdtls.apm_id = cp_apm_id;

  rec_get_person_match  cur_get_person_match%ROWTYPE;
  rec_get_match_detail cur_get_match_detail%ROWTYPE;

BEGIN

  -- Get APM_ID from CSS_ID
  rec_get_person_match := null;
  OPEN cur_get_person_match(p_css_id);
  FETCH cur_get_person_match INTO rec_get_person_match;
  IF cur_get_person_match%FOUND THEN
    CLOSE cur_get_person_match;

     -- Delete match detail records (child records)
     FOR rec_get_match_detail IN cur_get_match_detail(rec_get_person_match.apm_id) LOOP
       igf_ap_match_details_pkg.delete_row(rec_get_match_detail.row_id);
     END LOOP;
    -- Delete person match record (parent record)
    igf_ap_person_match_pkg.delete_row(rec_get_person_match.row_id);
   ELSE
      CLOSE cur_get_person_match;
   END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.delete_person_match.exception','The exception is : ' || SQLERRM );
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.delete_person_match');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    igs_ge_msg_stack.add;
END delete_person_match;

PROCEDURE delete_interface_record ( p_css_id       IN          NUMBER,
                                    x_return_status     OUT NOCOPY  VARCHAR2
                                  )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Deletes the record in PROFILE interface table.
  ||          2. Deletes the corresponding match detail records.
  ||          3. Deletes the corresponding record in person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */

  -- Cursor to get rowid of the PROFILE interface record.
  CURSOR cur_get_rowid_interface ( cp_css_id igf_ap_css_interface_all.css_id%TYPE) IS
    SELECT ROWID row_id
      FROM IGF_AP_CSS_INTERFACE_ALL intface
     WHERE intface.css_id = cp_css_id;

  rec_get_rowid_interface cur_get_rowid_interface%ROWTYPE;

BEGIN

  -- get row id of the PROFILE interface record to be deleted.
  OPEN cur_get_rowid_interface(p_css_id);
  FETCH cur_get_rowid_interface INTO rec_get_rowid_interface;
  IF (cur_get_rowid_interface%NOTFOUND) THEN
    CLOSE cur_get_rowid_interface;
    x_return_status := 'E';
    RETURN;
  END IF;
  CLOSE cur_get_rowid_interface;

  -- delete the interface record.
  igf_ap_css_interface_pkg.delete_row(rec_get_rowid_interface.row_id);

  -- delete person match record and match details records
  delete_person_match(p_css_id => p_css_id);

  x_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.delete_interface_record.exception','The exception is : ' || SQLERRM );
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.delete_interface_record');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    igs_ge_msg_stack.add;
    x_return_status := 'E';
END delete_interface_record;

PROCEDURE delete_int_records  ( p_css_ids IN  VARCHAR2 )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Deletes the record in PROFILE interface table.
  ||          2. Deletes the corresponding match detail records.
  ||          3. Deletes the corresponding record in person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */

  l_del_css_id  VARCHAR2(10);
  l_css_id      VARCHAR2(10);
  l_css_ids     VARCHAR2(1000);
  x_return_status     VARCHAR2(2);

BEGIN

  l_css_ids := p_css_ids;
  LOOP
    l_css_ids := TRIM(SUBSTR(l_css_ids, INSTR(l_css_ids, '*') + 1, LENGTH(l_css_ids)));
    l_css_id  := TRIM(SUBSTR(l_css_ids, 1, INSTR(l_css_ids, '*') - 1));
    l_css_ids := TRIM(SUBSTR(l_css_ids, INSTR(l_css_ids, ',') + 1, LENGTH(l_css_ids)));

    IF (l_css_id IS NULL) THEN
      l_del_css_id := l_css_ids;
    ELSE
      l_del_css_id := l_css_id;
    END IF;

    delete_interface_record( p_css_id => l_del_css_id, x_return_status => x_return_status);

    IF (l_css_id IS NULL) THEN
      EXIT; -- exit from loop.
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.delete_int_records.exception','The exception is : ' || SQLERRM );
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.delete_int_records');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    igs_ge_msg_stack.add;
END delete_int_records;

PROCEDURE ss_upload_profile ( p_css_id        IN          NUMBER,
                              x_msg_data      OUT NOCOPY  VARCHAR2,
                              x_return_status OUT NOCOPY  VARCHAR2
                            )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Upload the PROFILE record from interface table to profile table.
  ||          2. Update PROFILE interface record status to "MATCHED".
  ||          3. Deletes corresponding records in match details and person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */


BEGIN

  fnd_msg_pub.initialize;
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := '';

  igf_ap_profile_matching_pkg.ss_wrap_upload_Profile ( p_css_id        => p_css_id,
                                                       x_msg_data      => x_msg_data,
                                                       x_return_status => x_return_status
                                                      );
EXCEPTION WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.ss_upload_profile.exception','The exception is : ' || SQLERRM );
  END IF;
  fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.ss_upload_profile');
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  igs_ge_msg_stack.add;
  x_return_status := 'E';
END ss_upload_profile;

END igf_ap_profile_gen_pkg;

/
