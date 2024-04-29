--------------------------------------------------------
--  DDL for Package Body IGF_GR_MRR_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_MRR_LOAD_DATA" AS
/* $Header: IGFGR05B.pls 120.2 2006/04/06 06:10:12 veramach ship $ */

  /***************************************************************
    Created By          :       avenkatr
    Date Created By     :       2000/12/20
    Purpose             :       To upload data into the IGF_GR_MRR table

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
    veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
    smvk               11-Feb-2003      Modified the procedure load_ack and split_into_fields.
    2216956     13-02-2002  Added the field current_ssn in the tbh call and in the split_into_fields procedure
  ***************************************************************/


  param_error             EXCEPTION;
  invalid_version         EXCEPTION;     -- Thrown if the award year doesn't matches with that on the flat file.

  g_ver_num               VARCHAR2(30)    DEFAULT NULL; -- Flat File Version Number
  g_c_alt_code            VARCHAR2(80)    DEFAULT NULL; -- To hold alternate code.

PROCEDURE split_into_fields ( p_record_data    IN  igf_gr_load_file_t.record_data%TYPE,
                              p_igf_gr_mrr_row OUT NOCOPY igf_gr_mrr%ROWTYPE  )
AS
  /***************************************************************
    Created By          :       avenkatr
    Date Created By     :       2000/12/20
    Purpose             :       To split data in the single record_data column of igf_gr_load_file_t
                                into the different columns of igf_gr_mrr table

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
    smvk               11-Feb-2003      Bug # 2758812. Added '2003-2004' in g_ver_num checking.
  ***************************************************************/

BEGIN

    IF g_ver_num IN ('2002-2003', '2003-2004','2004-2005','2005-2006','2006-2007') THEN

         BEGIN
                    p_igf_gr_mrr_row.record_type       := SUBSTR( p_record_data, 1, 2);
                    p_igf_gr_mrr_row.req_inst_pell_id  := SUBSTR( p_record_data, 3, 6);
                    p_igf_gr_mrr_row.mrr_code1         := SUBSTR( p_record_data, 9, 1);
                    p_igf_gr_mrr_row.mrr_code2         := SUBSTR( p_record_data, 10, 1);
                    p_igf_gr_mrr_row.mr_stud_id        := SUBSTR( p_record_data, 11, 11);
                    p_igf_gr_mrr_row.mr_inst_pell_id   := SUBSTR( p_record_data, 22, 6);
                    p_igf_gr_mrr_row.stud_orig_ssn     := SUBSTR( p_record_data, 28, 9);
                    p_igf_gr_mrr_row.orig_name_cd      := SUBSTR( p_record_data, 37, 2);
                    p_igf_gr_mrr_row.inst_pell_id      := SUBSTR( p_record_data, 39, 6);
                    p_igf_gr_mrr_row.inst_name         := SUBSTR( p_record_data, 45, 70);
                    p_igf_gr_mrr_row.inst_addr1        := SUBSTR( p_record_data, 115, 35);
                    p_igf_gr_mrr_row.inst_addr2        := SUBSTR( p_record_data, 150, 35);
                    p_igf_gr_mrr_row.inst_city         := SUBSTR( p_record_data, 185, 25);
                    p_igf_gr_mrr_row.inst_state        := SUBSTR( p_record_data, 210, 2);
                    p_igf_gr_mrr_row.zip_code          := SUBSTR( p_record_data, 212, 9);
                    p_igf_gr_mrr_row.faa_name          := SUBSTR( p_record_data, 221, 30);
                    p_igf_gr_mrr_row.faa_tel           := SUBSTR( p_record_data, 251, 10);
                    p_igf_gr_mrr_row.faa_fax           := SUBSTR( p_record_data, 261, 10);
                    p_igf_gr_mrr_row.faa_internet_addr := SUBSTR( p_record_data, 271, 50);
                    p_igf_gr_mrr_row.schd_pell_grant   := TO_NUMBER(SUBSTR( p_record_data, 321, 7))/100;
                    p_igf_gr_mrr_row.orig_awd_amt      := TO_NUMBER(SUBSTR( p_record_data, 328, 7))/100;
                    p_igf_gr_mrr_row.tran_num          := SUBSTR( p_record_data, 335, 2);
                    p_igf_gr_mrr_row.efc               := TO_NUMBER(SUBSTR( p_record_data, 337, 5));
                    p_igf_gr_mrr_row.enrl_dt           := FND_DATE.STRING_TO_DATE(SUBSTR( p_record_data, 342, 8), 'YYYYMMDD');
                    p_igf_gr_mrr_row.orig_creation_dt  := FND_DATE.STRING_TO_DATE(SUBSTR( p_record_data, 350, 8), 'YYYYMMDD');
                    p_igf_gr_mrr_row.disb_accepted_amt := TO_NUMBER(SUBSTR( p_record_data, 358, 7))/100;
                    p_igf_gr_mrr_row.last_active_dt    := FND_DATE.STRING_TO_DATE(SUBSTR( p_record_data, 365, 8), 'YYYYMMDD');
                    p_igf_gr_mrr_row.next_est_disb_dt  := FND_DATE.STRING_TO_DATE(SUBSTR( p_record_data, 373, 8), 'YYYYMMDD');
                    p_igf_gr_mrr_row.eligibility_used  := TO_NUMBER(SUBSTR( p_record_data, 381, 5));
                    p_igf_gr_mrr_row.ed_use_flags      := SUBSTR( p_record_data, 386, 10);
                    p_igf_gr_mrr_row.stud_last_name    := SUBSTR( p_record_data, 396, 16);
                    p_igf_gr_mrr_row.stud_first_name   := SUBSTR( p_record_data, 412, 12);
                    p_igf_gr_mrr_row.stud_middle_name  := SUBSTR( p_record_data, 424, 1);
                    p_igf_gr_mrr_row.stud_dob          := FND_DATE.STRING_TO_DATE(SUBSTR( p_record_data, 425, 8), 'YYYYMMDD');
                    p_igf_gr_mrr_row.current_ssn       := SUBSTR(p_record_data,433,9);

            EXCEPTION
            WHEN OTHERS THEN     -- Number / Date format exception
                 RAISE igf_gr_gen.skip_this_record;

    END;

    ELSE
      RAISE igf_gr_gen.no_file_version;
   END IF;

EXCEPTION

   WHEN igf_gr_gen.skip_this_record THEN
        RAISE;

   WHEN igf_gr_gen.no_file_version  THEN
        RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_mrr_load_data.split_into_fields');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END split_into_fields;


PROCEDURE insert_in_mrr_table ( p_mrr_rec  IN  igf_gr_mrr%ROWTYPE )
AS
  /***************************************************************
  Created By            :       avenkatr
  Date Created By       :       2000/12/19
  Purpose               :       To Load data into IGF_GR_MRR table

  Known Limitations,Enhancements or Remarks
  Change History        :
  Who                   When            What
  ***************************************************************/
  lv_rowid VARCHAR2(25);
  lv_mrr_id NUMBER;

BEGIN
    /* Call the table handler of the table igf_gr_mrr to insert data */
    igf_gr_mrr_pkg.insert_row (
        x_rowid             => lv_rowid,
        x_mrr_id            => lv_mrr_id,
        x_record_type       => p_mrr_rec.record_type,
        x_req_inst_pell_id  => p_mrr_rec.req_inst_pell_id,
        x_mrr_code1         => p_mrr_rec.mrr_code1,
        x_mrr_code2         => p_mrr_rec.mrr_code2,
        x_mr_stud_id        => p_mrr_rec.mr_stud_id,
        x_mr_inst_pell_id   => p_mrr_rec.mr_inst_pell_id,
        x_stud_orig_ssn     => p_mrr_rec.stud_orig_ssn,
        x_orig_name_cd      => p_mrr_rec.orig_name_cd,
        x_inst_pell_id      => p_mrr_rec.inst_pell_id,
        x_inst_name         => p_mrr_rec.inst_name,
        x_inst_addr1        => p_mrr_rec.inst_addr1,
        x_inst_addr2        => p_mrr_rec.inst_addr2,
        x_inst_city         => p_mrr_rec.inst_city,
        x_inst_state        => p_mrr_rec.inst_state,
        x_zip_code          => p_mrr_rec.zip_code,
        x_faa_name          => p_mrr_rec.faa_name,
        x_faa_tel           => p_mrr_rec.faa_tel,
        x_faa_fax           => p_mrr_rec.faa_fax,
        x_faa_internet_addr => p_mrr_rec.faa_internet_addr,
        x_schd_pell_grant   => p_mrr_rec.schd_pell_grant,
        x_orig_awd_amt      => p_mrr_rec.orig_awd_amt,
        x_tran_num          => p_mrr_rec.tran_num,
        x_efc               => p_mrr_rec.efc ,
        x_enrl_dt           => p_mrr_rec.enrl_dt,
        x_orig_creation_dt  => p_mrr_rec.orig_creation_dt,
        x_disb_accepted_amt => p_mrr_rec.disb_accepted_amt,
        x_last_active_dt    => p_mrr_rec.last_active_dt,
        x_next_est_disb_dt  => p_mrr_rec.next_est_disb_dt,
        x_eligibility_used  => p_mrr_rec.eligibility_used,
        x_ed_use_flags      => p_mrr_rec.ed_use_flags,
        x_stud_last_name    => p_mrr_rec.stud_last_name,
        x_stud_first_name   => p_mrr_rec.stud_first_name,
        x_stud_middle_name  => p_mrr_rec.stud_middle_name,
        x_stud_dob          => p_mrr_rec.stud_dob,
        x_current_ssn       => p_mrr_rec.current_ssn,
        x_mode              => 'R'
      ) ;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_mrr_load_data.insert_in_mrr_table');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END insert_in_mrr_table;


PROCEDURE load_ack
IS
  /***************************************************************
    Created By          :
    Date Created By     :
    Purpose             :

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
    smvk              11-Feb-2003       Bug # 2758812. Added the code to check version mismatch and
                                        validate the number of records mentioned in the trailer record.
  ***************************************************************/

    l_last_gldr_id        NUMBER;
    l_number_rec          NUMBER;
    l_batch_id            VARCHAR2(100);
    lp_count              NUMBER          DEFAULT  0;
    lf_count              NUMBER          DEFAULT  0;

    l_c_message           VARCHAR2(30);  -- Local variable to hold message

BEGIN


   igf_gr_gen.process_pell_ack ( g_ver_num,
                                 'MRR',
                                 l_number_rec,
                                 l_last_gldr_id,
                                 l_batch_id);

    --  Check the award year matches with the award year in PELL setup.
   igf_gr_gen.match_file_version (g_ver_num, l_batch_id, l_c_message);
   IF l_c_message = 'IGF_GR_VRSN_MISMTCH' THEN
      fnd_message.set_name ('IGF',l_c_message);
      fnd_message.set_token('CYCL',substr(l_batch_id,3,4));
      fnd_message.set_token('BATCH',l_batch_id);
      fnd_message.set_token('AWD_YR',g_c_alt_code);
      fnd_message.set_token('VRSN',g_ver_num);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE invalid_version;
   END IF;

   IF l_number_rec > 0 THEN

   DECLARE

       CURSOR c_mrr_data
       IS
       SELECT
       record_data
       FROM
       igf_gr_load_file_t
       WHERE
       gldr_id BETWEEN 2 AND (l_last_gldr_id - 1)
       AND
       file_type = 'MRR'
       ORDER BY
       gldr_id;

       mrr_rec_data  c_mrr_data%ROWTYPE;
       lv_mrr_row    igf_gr_mrr%ROWTYPE;

    BEGIN
    --
    -- Check for the type of data in the Flat File
    --
    FOR  mrr_rec_data  IN  c_mrr_data  LOOP

       IF  ( (SUBSTR(mrr_rec_data.record_data, 1, 1)) = 'O' ) THEN
            --
            -- This file has Origination records and has to be uploaded in igf_gr_ytd_orig table
            --
              BEGIN
                --
                --  Split the data in the column of igf_gr_load_file_t into the columns of igf_gr_ytd_orig  file
                --
                split_into_fields (mrr_rec_data.record_data,
                                   lv_mrr_row);

               --
               -- Insert this new record into the igf_gr_ytd_orig table
               --
               insert_in_mrr_table (lv_mrr_row );
               --
               -- Make an entry in the log file indicating Success
               --
                fnd_message.set_name('IGF','IGF_GR_MRR_LOAD_PASS');
                fnd_message.set_token('STUD_ORIG_SSN',lv_mrr_row.stud_orig_ssn);
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                lp_count := lp_count + 1;

               EXCEPTION

                  WHEN igf_gr_gen.skip_this_record THEN
                  fnd_message.set_name('IGF','IGF_GR_MRR_LOAD_FAIL');
                  fnd_message.set_token('STUD_ORIG_SSN',SUBSTR( mrr_rec_data.record_data, 28, 9));
                  fnd_file.put_line(fnd_file.log,fnd_message.get());
                  lf_count := lf_count + 1;
                  fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                  fnd_file.put_line(fnd_file.log,fnd_message.get);

                  WHEN igf_gr_gen.no_file_version THEN
                  RAISE;

               END ;

       ELSE
          lf_count := lf_count + 1;
       END IF;

     END LOOP;

     EXCEPTION

         WHEN igf_gr_gen.no_file_version THEN
         RAISE;

    END;

  END IF;

  IF l_number_rec <> (lp_count + lf_count) THEN
     fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     RAISE igf_gr_gen.file_not_loaded;
  END IF;

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_CNT');
  fnd_message.set_token('CNT',l_number_rec);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_PAS');
  fnd_message.set_token('CNT',lp_count);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_FAL');
  fnd_message.set_token('CNT',lf_count);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

EXCEPTION
  WHEN invalid_version THEN
       RAISE;
  WHEN igf_gr_gen.no_file_version THEN
       RAISE;
  WHEN igf_gr_gen.corrupt_data_file THEN
       RAISE;
  WHEN igf_gr_gen.file_not_loaded   THEN
      RAISE;

  WHEN OTHERS THEN
       fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','igf_gr_mrr_load_data.load_ack');
       igs_ge_msg_stack.add;
      app_exception.raise_exception;

END load_ack;


--
-- MAIN PROCEDURE
--

PROCEDURE mrr_load_file(
    errbuf               OUT NOCOPY             VARCHAR2,
    retcode              OUT NOCOPY             NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id             IN             NUMBER
  )
  AS
  /***************************************************************
    Created By          :       avenkatr
    Date Created By     :       2000/12/19
    Purpose             :       To Load data into IGF_GR_MRR table

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
  ***************************************************************/

    l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
    l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;

BEGIN

     retcode := 0;
     igf_aw_gen.set_org_id(p_org_id);

     l_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
     l_ci_sequence_number     :=   TO_NUMBER(SUBSTR(p_awd_yr,11));

     IF l_ci_cal_type IS  NULL OR l_ci_sequence_number IS NULL  THEN
              RAISE param_error;
     END IF;

--
-- Get the Flat File Version and then Proceed
--
    g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');
    g_c_alt_code := igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);

   IF g_ver_num ='NULL' THEN
      RAISE igf_gr_gen.no_file_version;
   ELSE
      load_ack;
   END IF;

   COMMIT;

EXCEPTION
    WHEN invalid_version THEN
       ROLLBACK;
       retcode := 2;

    WHEN param_error THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.corrupt_data_file THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_CORRUPT_DATA_FILE');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.file_not_loaded THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.no_file_version THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_VERSION_NOTFOUND');
       igs_ge_msg_stack.conc_exception_hndl;

    WHEN others THEN

       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       igs_ge_msg_stack.conc_exception_hndl;


END mrr_load_file;


END igf_gr_mrr_load_data;

/
