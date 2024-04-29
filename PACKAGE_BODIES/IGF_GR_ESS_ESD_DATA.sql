--------------------------------------------------------
--  DDL for Package Body IGF_GR_ESS_ESD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_ESS_ESD_DATA" AS
/* $Header: IGFGR06B.pls 120.3 2006/04/06 06:10:40 veramach ship $ */

/***************************************************************
    Created By		:	adhawan
    Date Created By	:	2000/12/20
    Purpose		:	To Load the data into IGF_GR_ELEC_STAT_SUM and IGF_GR_ELEC_STAT_DET tables

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
--  veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
-- Bug ID :  1731177
-- Who       When            What
-- masehgal  17-Feb-2002     # 2216956    FACR007
--                           Removed "Last Payment Number" from Summary
-- sjadhav   16-apr-2001     Added P_ESD_IND parameter to the main procedure
--                           If P_ESD_IND is 'S' ; we should run summary Process
--                           else if its 'D' then we should run Detail Process.
  ***************************************************************/


  param_error             EXCEPTION;
  invalid_version         EXCEPTION;     -- Thrown if the award year doesn't matches with that on the flat file.

  g_ver_num               VARCHAR2(30)    DEFAULT NULL; -- Flat File Version Number
  g_c_alt_code            VARCHAR2(80)    DEFAULT NULL; -- To hold alternate code.


PROCEDURE split_ess_fields ( p_record_data    IN  igf_gr_load_file_t.record_data%TYPE,
                             p_ess_rec        OUT NOCOPY igf_gr_elec_stat_sum%ROWTYPE  )
AS
  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/20
    Purpose		:	To split data in the single record_data column of igf_gr_load_file_t
                                into the different columns of igf_gr_elec_stat_sum table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    smvk               11-Feb-2003      Bug # 2758812. Added '2003-2004' in g_ver_num checking.
  ***************************************************************/


BEGIN

    IF g_ver_num IN ('2002-2003', '2003-2004','2004-2005') THEN

         BEGIN
		 p_ess_rec.rep_pell_id                 := SUBSTR(p_record_data,2,6);
		 p_ess_rec.duns_id                     := SUBSTR(p_record_data,8,11);
		 p_ess_rec.gaps_award_num              := SUBSTR(p_record_data,30,16);
		 p_ess_rec.acct_schedule_number        := SUBSTR(p_record_data,46,5);
		 p_ess_rec.acct_schedule_date          := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,51,8),'YYYYMMDD');
		 p_ess_rec.prev_obligation_amt         := TO_NUMBER(SUBSTR(p_record_data,59,11))/100;
		 p_ess_rec.obligation_adj_amt          := TO_NUMBER(SUBSTR(p_record_data,70,11))/100;
		 p_ess_rec.curr_obligation_amt         := TO_NUMBER(SUBSTR(p_record_data,81,11))/100;
		 p_ess_rec.prev_obligation_pymt_amt    := TO_NUMBER(SUBSTR(p_record_data,92,11))/100;
		 p_ess_rec.obligation_pymt_adj_amt     := TO_NUMBER(SUBSTR(p_record_data,103,11))/100;
		 p_ess_rec.curr_obligation_pymt_amt    := TO_NUMBER(SUBSTR(p_record_data,114,11))/100;
		 p_ess_rec.ytd_total_recp              := TO_NUMBER(SUBSTR(p_record_data,125,7));
		 p_ess_rec.ytd_accepted_disb_amt       := TO_NUMBER(SUBSTR(p_record_data,132,11))/100;
		 p_ess_rec.ytd_posted_disb_amt         := TO_NUMBER(SUBSTR(p_record_data,143,11))/100;
		 p_ess_rec.ytd_admin_cost_allowance    := TO_NUMBER(SUBSTR(p_record_data,154,11))/100;
		 p_ess_rec.caps_drwn_dn_pymts          := TO_NUMBER(SUBSTR(p_record_data,165,13))/100;
		 p_ess_rec.gaps_last_date              := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,178,8),'YYYYMMDD');


            EXCEPTION
            WHEN OTHERS THEN     -- Number / Date format exception
                 RAISE igf_gr_gen.skip_this_record;

         END;

      ELSIF g_ver_num IN ('2005-2006','2006-2007') THEN

         BEGIN
		 p_ess_rec.rep_pell_id                 := SUBSTR(p_record_data,2,6);
		 p_ess_rec.duns_id                     := SUBSTR(p_record_data,8,11);
		 p_ess_rec.gaps_award_num              := SUBSTR(p_record_data,30,16);
		 p_ess_rec.acct_schedule_number        := NULL;
		 p_ess_rec.acct_schedule_date          := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,51,8),'YYYYMMDD');
		 p_ess_rec.prev_obligation_amt         := TO_NUMBER(SUBSTR(p_record_data,59,11))/100;
		 p_ess_rec.obligation_adj_amt          := TO_NUMBER(SUBSTR(p_record_data,70,11))/100;
		 p_ess_rec.curr_obligation_amt         := TO_NUMBER(SUBSTR(p_record_data,81,11))/100;
		 p_ess_rec.prev_obligation_pymt_amt    := TO_NUMBER(SUBSTR(p_record_data,92,11))/100;
		 p_ess_rec.obligation_pymt_adj_amt     := TO_NUMBER(SUBSTR(p_record_data,103,11))/100;
		 p_ess_rec.curr_obligation_pymt_amt    := TO_NUMBER(SUBSTR(p_record_data,114,11))/100;
		 p_ess_rec.ytd_total_recp              := TO_NUMBER(SUBSTR(p_record_data,125,7));
		 p_ess_rec.ytd_accepted_disb_amt       := TO_NUMBER(SUBSTR(p_record_data,132,11))/100;
		 p_ess_rec.ytd_posted_disb_amt         := NULL;
		 p_ess_rec.ytd_admin_cost_allowance    := TO_NUMBER(SUBSTR(p_record_data,154,11))/100;
		 p_ess_rec.caps_drwn_dn_pymts          := TO_NUMBER(SUBSTR(p_record_data,165,13))/100;
		 p_ess_rec.gaps_last_date              := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,178,8),'YYYYMMDD');


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
      fnd_message.set_token('NAME','igf_gr_ess_esd_data.split_ess_fields');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END split_ess_fields;


PROCEDURE split_esd_fields ( p_record_data    IN  igf_gr_load_file_t.record_data%TYPE,
                             p_esd_rec        OUT NOCOPY igf_gr_elec_stat_det%ROWTYPE  )
AS
  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/20
    Purpose		:	To split data in the single record_data column of igf_gr_load_file_t
                                into the different columns of igf_gr_elec_stat_sum table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    smvk               11-Feb-2003      Bug # 2758812. Added '2003-2004' in g_ver_num checking.
  ***************************************************************/

BEGIN

    IF g_ver_num IN ('2002-2003', '2003-2004','2004-2005') THEN

         BEGIN
                  p_esd_rec.rep_pell_id            := SUBSTR(p_record_data,2,6);
                  p_esd_rec.duns_id                := SUBSTR(p_record_data,8,11);
                  p_esd_rec.gaps_award_num         := SUBSTR(p_record_data,30,16);
                  p_esd_rec.transaction_date       := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,46,8),'YYYYMMDD');
                  p_esd_rec.db_cr_flag             := SUBSTR(p_record_data,54,1);
                  p_esd_rec.adj_amt                := TO_NUMBER(SUBSTR(p_record_data,55,11))/100;
                  p_esd_rec.gaps_process_date      := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,66,8),'YYYYMMDD');
                  p_esd_rec.adj_batch_id           := SUBSTR(p_record_data,74,26);

            EXCEPTION
            WHEN OTHERS THEN     -- Number / Date format exception
                 RAISE igf_gr_gen.skip_this_record;
         END;

     ELSIF g_ver_num IN ('2005-2006','2006-2007') THEN

         BEGIN
                  p_esd_rec.rep_pell_id            := SUBSTR(p_record_data,2,6);
                  p_esd_rec.duns_id                := SUBSTR(p_record_data,8,11);
                  p_esd_rec.gaps_award_num         := SUBSTR(p_record_data,30,16);
                  p_esd_rec.transaction_date       := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,46,8),'YYYYMMDD');
                  p_esd_rec.db_cr_flag             := SUBSTR(p_record_data,54,1);
                  p_esd_rec.adj_amt                := TO_NUMBER(SUBSTR(p_record_data,55,11))/100;
                  p_esd_rec.gaps_process_date      := fnd_date.STRING_TO_DATE(SUBSTR(p_record_data,66,8),'YYYYMMDD');
                  p_esd_rec.adj_batch_id           := SUBSTR(p_record_data,74,30);

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
      fnd_message.set_token('NAME','igf_gr_ess_esd_data.split_esd_fields');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END split_esd_fields;


PROCEDURE insert_in_ess_table ( p_ess_rec  IN  igf_gr_elec_stat_sum%ROWTYPE )
AS
  /***************************************************************
  Created By		:	avenkatr
  Date Created By	:	2000/12/19
  Purpose		:	To Load data into igf_gr_elec_stat_sum table

  Known Limitations,Enhancements or Remarks
  Change History	:
  Who			When		What
  ***************************************************************/

  lv_rowid VARCHAR2(25);
  lv_ess_id NUMBER;

BEGIN
    /* Call the table handler of the table igf_gr_elec_stat_sum to insert data */
  	     igf_gr_elec_stat_sum_pkg.insert_row (
         		 x_mode                         => 'R',
	        	 x_rowid                        => lv_rowid,
		         x_acct_schedule_number         => p_ess_rec.acct_schedule_number,
         		 x_acct_schedule_date           => p_ess_rec.acct_schedule_date,
        		 x_prev_obligation_amt          => p_ess_rec.prev_obligation_amt,
        		 x_obligation_adj_amt           => p_ess_rec.obligation_adj_amt,
        		 x_curr_obligation_amt          => p_ess_rec.curr_obligation_amt,
        		 x_prev_obligation_pymt_amt     => p_ess_rec.prev_obligation_pymt_amt,
        		 x_obligation_pymt_adj_amt      => p_ess_rec.obligation_pymt_adj_amt,
        		 x_curr_obligation_pymt_amt     => p_ess_rec.curr_obligation_pymt_amt,
        		 x_ytd_total_recp               => p_ess_rec.ytd_total_recp,
        		 x_ytd_accepted_disb_amt        => p_ess_rec.ytd_accepted_disb_amt ,
        		 x_ytd_posted_disb_amt          => p_ess_rec.ytd_posted_disb_amt ,
        		 x_ytd_admin_cost_allowance     => p_ess_rec.ytd_admin_cost_allowance ,
        		 x_caps_drwn_dn_pymts           => p_ess_rec.caps_drwn_dn_pymts,
        		 x_gaps_last_date               => p_ess_rec.gaps_last_date,
        		 x_last_pymt_number             => p_ess_rec.last_pymt_number,
        		 x_ess_id                       => lv_ess_id,
        		 x_rep_pell_id                  => p_ess_rec.rep_pell_id,
        		 x_duns_id                      => p_ess_rec.duns_id,
         		 x_gaps_award_num               => p_ess_rec.gaps_award_num  );

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_ess_esd_data.insert_in_ess_table');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END insert_in_ess_table;


PROCEDURE insert_in_esd_table ( p_esd_rec  IN  igf_gr_elec_stat_det%ROWTYPE )
AS
  /***************************************************************
  Created By		:	avenkatr
  Date Created By	:	2000/12/19
  Purpose		:	To Load data into igf_gr_elec_stat_sum table

  Known Limitations,Enhancements or Remarks
  Change History	:
  Who			When		What
  ***************************************************************/

  lv_rowid VARCHAR2(25);
  lv_esd_id NUMBER;

BEGIN

     igf_gr_elec_stat_det_pkg.insert_row (
            x_mode                       => 'R',
            x_rowid                      => lv_rowid,
            x_esd_id                     => lv_esd_id,
            x_rep_pell_id                => p_esd_rec.rep_pell_id,
            x_duns_id                    => p_esd_rec.duns_id ,
            x_gaps_award_num             => p_esd_rec.gaps_award_num,
            x_transaction_date           => p_esd_rec.transaction_date,
            x_db_cr_flag                 => p_esd_rec.db_cr_flag ,
            x_adj_amt                    => p_esd_rec.adj_amt ,
            x_gaps_process_date          => p_esd_rec.gaps_process_date,
            x_adj_batch_id               => p_esd_rec.adj_batch_id);

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_ess_esd_data.insert_in_esd_table');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END insert_in_esd_table;


PROCEDURE ess_load IS
/***************************************************************
    Created By		:	adhawan
    Date Created By	:	2000/12/20
    Purpose		:	To Load the data into IGF_GR_ELEC_STAT_SUM table

    Known Limitations,Enhancements or Remarks
    Change History	:
--  Who       When           What
-- smvk       11-Feb-2003    Bug # 2758812. Added the code to check version mismatch and
--                           validate the number of records mentioned in the trailer record.
-- masehgal  17-Feb-2002     # 2216956    FACR007
--                           Removed "Last Payment Number" from Summary
  ***************************************************************/

    l_last_gldr_id        NUMBER;
    l_number_rec          NUMBER;
    l_batch_id            VARCHAR2(100);
    lp_count              NUMBER          DEFAULT  0;
    lf_count              NUMBER          DEFAULT  0;

    l_c_message           VARCHAR2(30);  -- Local variable to hold message

BEGIN

   igf_gr_gen.process_pell_ack ( g_ver_num,
                                 'ESS',
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

       CURSOR c_ess_data
       IS
       SELECT
       record_data
       FROM
       igf_gr_load_file_t
       WHERE
       gldr_id BETWEEN 2 AND (l_last_gldr_id - 1)
       AND
       file_type = 'ESS'
       ORDER BY
       gldr_id;

       ess_rec_data  c_ess_data%ROWTYPE;
       lv_ess_row    igf_gr_elec_stat_sum%ROWTYPE;

   BEGIN
    --
    -- Check for the type of data in the Flat File
    --
     FOR ess_rec_data IN c_ess_data LOOP

         IF SUBSTR(ess_rec_data.record_data,1,1) ='S' THEN

             BEGIN
                 --
                 -- split
                 --
                 split_ess_fields(ess_rec_data.record_data,
                                  lv_ess_row);
                 --
                 -- Insert
                 --

                 insert_in_ess_table(lv_ess_row);


                 fnd_message.set_name('IGF','IGF_GR_ESS_LOAD_PASS');
                 fnd_message.set_token('VALUE',' ');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);

                 lp_count := lp_count + 1;

             EXCEPTION
                 WHEN igf_gr_gen.skip_this_record THEN
                 fnd_message.set_name('IGF','IGF_GR_ESS_LOAD_FAIL');
                 fnd_message.set_token('VALUE',' ');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);

                 lf_count := lf_count + 1;
                 fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);

                 WHEN igf_gr_gen.no_file_version THEN
                 RAISE;

             END;
         ELSE
          lf_count := lf_count + 1;
         END IF;
     END LOOP;

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
  WHEN igf_gr_gen.file_not_loaded THEN
       RAISE;

  WHEN OTHERS THEN
       fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','igf_gr_ess_esd_data.ess_load ');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;

END ess_load;

PROCEDURE esd_load IS
/***************************************************************
    Created By		:	adhawan
    Date Created By	:	2000/12/20
    Purpose		:	To Load the data into IGF_GR_ELEC_STAT_SUM table

    Known Limitations,Enhancements or Remarks
    Change History	:
--  Who       When           What
-- masehgal  17-Feb-2002     # 2216956    FACR007
--                           Removed "Last Payment Number" from Summary
  ***************************************************************/

    l_last_gldr_id        NUMBER;
    l_number_rec          NUMBER;
    lp_count              NUMBER          DEFAULT  0;
    lf_count              NUMBER          DEFAULT  0;
    l_batch_id            VARCHAR2(100);

    l_c_message           VARCHAR2(30);  -- Local variable to hold message

BEGIN

   igf_gr_gen.process_pell_ack ( g_ver_num,
                                 'ESD',
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

       CURSOR c_esd_data
       IS
       SELECT
       record_data
       FROM
       igf_gr_load_file_t
       WHERE
       gldr_id BETWEEN 2 AND (l_last_gldr_id - 1)
       AND
       file_type = 'ESD'
       ORDER BY
       gldr_id;

       esd_rec_data  c_esd_data%ROWTYPE;
       lv_esd_row    igf_gr_elec_stat_det%ROWTYPE;

    BEGIN
    --
    -- Check for the type of data in the Flat File
    --
     FOR esd_rec_data IN c_esd_data LOOP

         IF SUBSTR(esd_rec_data.record_data,1,1) ='D' THEN
             BEGIN
                 --
                 -- split
                 --
                 split_esd_fields(esd_rec_data.record_data,
                                  lv_esd_row);
                 --
                 -- Insert
                 --

                 insert_in_esd_table(lv_esd_row);


                 fnd_message.set_name('IGF','IGF_GR_ESD_LOAD_PASS');
                 fnd_message.set_token('VALUE',' ');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 lp_count := lp_count + 1;

             EXCEPTION
                 WHEN igf_gr_gen.skip_this_record THEN
                 fnd_message.set_name('IGF','IGF_GR_ESD_LOAD_FAIL');
                 fnd_message.set_token('VALUE',' ' );
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 lf_count := lf_count + 1;
                 fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);

                 WHEN igf_gr_gen.no_file_version THEN
                 RAISE;
             END;
         ELSE
            lf_count := lf_count + 1;
         END IF;
     END LOOP;

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
  WHEN igf_gr_gen.file_not_loaded THEN
      RAISE;

  WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_ess_esd_data.esd_load ');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END esd_load;


 PROCEDURE main(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id		 IN	   	NUMBER
   )
AS
  /***************************************************************
    Created By		:	adhawan
    Date Created By	:	2000/12/20
    Purpose		:	To Load the IGF_GR_ELEC_STAT_SUM and IGF_GR_ELEC_STAT_DET table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    --
    -- Bug ID :  1731177
    -- who       when            what
    -- sjadhav   16-apr-2001     Call to summary procedure
    --
    --
  ***************************************************************/
    l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
    l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;


 BEGIN

    retcode:= 0;
    igf_aw_gen.set_org_id(p_org_id);
    retcode := 0;
    igf_aw_gen.set_org_id(p_org_id);

    l_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
    l_ci_sequence_number     :=   TO_NUMBER(SUBSTR(p_awd_yr,11));


    IF l_ci_cal_type IS  NULL OR l_ci_sequence_number IS NULL  THEN
              RAISE param_error;
    END IF;

-- Get the Flat File Version and then Proceed
--
    g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');
    g_c_alt_code := igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);

   IF g_ver_num ='NULL' THEN
      RAISE igf_gr_gen.no_file_version;
   ELSE
        esd_load;
   END IF;

   COMMIT;

EXCEPTION

    WHEN invalid_version THEN
       ROLLBACK;
       retcode := 2;

    WHEN no_data_found THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_NO_PELL_SETUP');
       fnd_file.put_line(fnd_file.log,errbuf);

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

END main;


 PROCEDURE main_s(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id		 IN	   	NUMBER
)
AS
  /***************************************************************
    Created By		:	adhawan
    Date Created By	:	2000/12/20
    Purpose		:	To Load the IGF_GR_ELEC_STAT_SUM and IGF_GR_ELEC_STAT_DET table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    --
    -- Bug ID :  1731177
    -- who       when            what
    -- sjadhav   16-apr-2001     Call to summary procedure
    --
    --
  ***************************************************************/
    l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
    l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;

 BEGIN

    retcode:= 0;
    igf_aw_gen.set_org_id(p_org_id);
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
        ess_load;
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

END main_s;

END igf_gr_ess_esd_data;

/
