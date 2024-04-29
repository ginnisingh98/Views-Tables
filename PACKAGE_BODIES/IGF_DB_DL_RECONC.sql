--------------------------------------------------------
--  DDL for Package Body IGF_DB_DL_RECONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DL_RECONC" AS
/* $Header: IGFDB07B.pls 120.3 2006/04/06 06:08:00 veramach noship $ */
/***************************************************************
   Created By           :       adhawan
   Date Created By      :       22-jan-2002
   Purpose                  :   To load the
   Known Limitations,Enhancements or Remarks:
   Change History       :2154941
   Who          When            What
     veramach        29-Jan-2004     bug 3408092 added 2004-2005 in dl_version checks
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               added two new parameters school_type and p_school_code to
                               main_smr and main_dtl and removed school_id references
   adhawan      22-jan-2002     Disbursements build
   smvk         24-Feb-2003     Bug # 2758823. DL 03-04 Updates.
 ***************************************************************/
  INV_HDR_OR_TLR       EXCEPTION;
  INVALID_FILE         EXCEPTION;
  INV_TRL_NUM          EXCEPTION;

  FUNCTION valid_header ( p_c_file_type IN igf_sl_load_file_t.file_type%TYPE, p_c_batch_id OUT NOCOPY igf_sl_dl_batch.batch_id%TYPE,
                          p_c_message_class OUT NOCOPY igf_sl_dl_batch.message_class%TYPE, p_d_bth_creation_date OUT NOCOPY igf_sl_dl_batch.bth_creation_date%TYPE,
                          p_c_rej_code OUT NOCOPY igf_sl_dl_batch.batch_rej_code%TYPE, p_c_batch_type OUT NOCOPY igf_sl_dl_batch.batch_type%TYPE) RETURN BOOLEAN;

  FUNCTION valid_trailer ( p_c_file_type IN igf_sl_load_file_t.file_type%TYPE, p_n_last_lort_id OUT NOCOPY NUMBER ,
                           p_n_rec_num OUT NOCOPY NUMBER, p_n_rec_accept OUT NOCOPY NUMBER,
                           p_n_rec_reject OUT NOCOPY NUMBER, p_n_rec_pending OUT NOCOPY NUMBER) RETURN BOOLEAN ;

  FUNCTION valid_header ( p_c_file_type IN igf_sl_load_file_t.file_type%TYPE, p_c_batch_id OUT NOCOPY igf_sl_dl_batch.batch_id%TYPE,
                          p_c_message_class OUT NOCOPY igf_sl_dl_batch.message_class%TYPE, p_d_bth_creation_date OUT NOCOPY igf_sl_dl_batch.bth_creation_date%TYPE,
                          p_c_rej_code OUT NOCOPY igf_sl_dl_batch.batch_rej_code%TYPE, p_c_batch_type OUT NOCOPY igf_sl_dl_batch.batch_type%TYPE) RETURN BOOLEAN  AS
   /***************************************************************
     Created By         :       smvk
     Date Created By    :       18-Feb-2003
     Purpose                :   Returns TRUE if there exist a valid header for given file type. otherwise returns FALSE
     Known Limitations,Enhancements or Remarks:
     Change History     :2154941
     Who                        When            What

   ***************************************************************/
     CURSOR c_header (cp_c_file_type IN igf_sl_load_file_t.file_type%TYPE) IS
        SELECT RTRIM(LTRIM(SUBSTR(record_data, 15,  8)))                     message_class,
               RTRIM(LTRIM(SUBSTR(record_data, 23,  2)))                     batch_type,
               RTRIM(LTRIM(SUBSTR(record_data, 23, 23)))                     batch_id,
               to_date(SUBSTR(record_data, 46, 16),'YYYYMMDDHH24MISS')       bth_creation_date,
               RTRIM(LTRIM(SUBSTR(record_data, 60,  2)))                     batch_rej_code

        FROM   igf_sl_load_file_t
        WHERE  lort_id = 1
        AND    record_data LIKE 'DL HEADER%'
        AND    file_type = cp_c_file_type;

     rec_header c_header%ROWTYPE;

  BEGIN
     OPEN c_header (p_c_file_type);
     FETCH c_header INTO rec_header;
     IF c_header%FOUND THEN
        p_c_batch_id := rec_header.batch_id;
        p_c_message_class := rec_header.message_class;
        p_d_bth_creation_date := rec_header.bth_creation_date;
        p_c_rej_code := rec_header.batch_rej_code;
        p_c_batch_type := rec_header.batch_type;
        CLOSE c_header;
        RETURN TRUE;
     ELSE
        CLOSE c_header;
        RETURN FALSE;
     END IF;
  END valid_header;

  FUNCTION valid_trailer ( p_c_file_type IN igf_sl_load_file_t.file_type%TYPE, p_n_last_lort_id OUT NOCOPY NUMBER ,
                           p_n_rec_num OUT NOCOPY NUMBER, p_n_rec_accept OUT NOCOPY NUMBER,
                           p_n_rec_reject OUT NOCOPY NUMBER, p_n_rec_pending OUT NOCOPY NUMBER) RETURN BOOLEAN AS

   /***************************************************************
     Created By         :       smvk
     Date Created By    :       18-Feb-2003
     Purpose                :   Returns TRUE if there exist a valid trailer for given file type. otherwise returns FALSE
     Known Limitations,Enhancements or Remarks:
     Change History     :2154941
     Who                        When            What

   ***************************************************************/

     CURSOR   c_trailer (cp_c_file_type IN igf_sl_load_file_t.file_type%TYPE) IS
       SELECT lort_id                  last_lort_id,
              RTRIM(SUBSTR(record_data,15,7)) number_rec,
              RTRIM(SUBSTR(record_data,22,5)) accept_rec,
              RTRIM(SUBSTR(record_data,27,5)) reject_rec,
              RTRIM(SUBSTR(record_data,32,5)) pending_rec
       FROM   igf_sl_load_file_t
       WHERE  lort_id = (SELECT MAX(lort_id) FROM igf_sl_load_file_t)
       AND    record_data LIKE 'DL TRAILER%'
       AND    file_type = cp_c_file_type;

     rec_trailer c_trailer%ROWTYPE;

  BEGIN
    OPEN c_trailer (p_c_file_type);
    FETCH c_trailer INTO rec_trailer;
    IF c_trailer%FOUND THEN
       p_n_last_lort_id := rec_trailer.last_lort_id;
       p_n_rec_num      := rec_trailer.number_rec;
       p_n_rec_accept   := rec_trailer.accept_rec;
       p_n_rec_reject   := rec_trailer.reject_rec;
       p_n_rec_pending  := rec_trailer.pending_rec;
       CLOSE c_trailer;
       RETURN TRUE;
    ELSE
       CLOSE c_trailer;
       RETURN FALSE;
    END IF;

  END valid_trailer ;

 PROCEDURE load_ytd_summary(p_school_code VARCHAR2, p_award_year igf_sl_dl_setup_v.ci_alternate_code%TYPE) AS
 /***************************************************************
   Created By           :       adhawan
   Date Created By      :       22-jan-2002
   Purpose                  :   To load the table igf_db_ytd_sum from igf_sl_load_file_t table
   Known Limitations,Enhancements or Remarks:
   Change History       :2154941
   Who          When            What
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               changed first parameter to this procedure as passed to main_smr process
                               and replaced references of school_id of igf_sl_dl_setup table with newly
                               changed p_school_code w.r.t. FA 126
   smvk         25-Feb-2003     Bug # 2758823. Validating Header and trailer. Done changes for 2003-2004 awary year.
   adhawan      22-jan-2002 Disbursements build
 ***************************************************************/

 CURSOR c_batch  IS
   SELECT record_data FROM igf_sl_load_file_t ,igf_db_ytd_smr ln
   WHERE file_type ='DL_YTDS'  AND
   SUBSTR(record_data,1,1)='Y' AND
   SUBSTR(record_data,2,23) =ln.batch_id;
 c_batch_rec c_batch%ROWTYPE;

 CURSOR c_ytd_summary(cp_c_last_lort_id igf_sl_load_file_t.lort_id%TYPE) IS
 SELECT  record_data  FROM
      igf_sl_load_file_t
      WHERE lort_id BETWEEN 2 AND (cp_c_last_lort_id-1)
      AND file_type ='DL_YTDS'
      AND SUBSTR(record_data,1,1)='Y'
      AND SUBSTR(record_data,25,6)=p_school_code
      ORDER BY lort_id ;
 l_dl_ytds_rec igf_db_ytd_smr%ROWTYPE;

 l_rowid VARCHAR2(30);
 l_ytds_id igf_db_ytd_smr.ytds_id%TYPE;
 l_counter NUMBER(20) := 0;

 --Variables used to give the end result of the processing of the records

 l_fetch_count NUMBER(20) := 0;
 l_processed_count NUMBER(20) :=0;

 -- Variables to hold the value derive from header
 l_c_batch_id igf_sl_dl_batch.batch_id%TYPE;
 l_c_message_class igf_sl_dl_batch.message_class%TYPE;
 l_d_bth_creation_date igf_sl_dl_batch.bth_creation_date%TYPE;
 l_c_rej_code igf_sl_dl_batch.batch_rej_code%TYPE;
 l_c_batch_type igf_sl_dl_batch.batch_type%TYPE;

 -- Variables to hold the value derive from trailer
 l_n_last_lort_id NUMBER ;
 l_n_rec_num NUMBER;
 l_n_rec_accept NUMBER;
 l_n_rec_reject NUMBER;
 l_n_rec_pending NUMBER;

 l_c_dl_version    igf_sl_dl_file_type.dl_version%TYPE;
 l_c_dl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE;
 l_c_dl_loan_catg  igf_sl_dl_file_type.dl_loan_catg%TYPE;

BEGIN

   -- checking the header
  IF NOT valid_header ( 'DL_YTDS', l_c_batch_id, l_c_message_class,
                   l_d_bth_creation_date, l_c_rej_code, l_c_batch_type) THEN
     RAISE INV_HDR_OR_TLR;
  END IF;

   -- checking the trailer
  IF NOT valid_trailer ( 'DL_YTDS', l_n_last_lort_id, l_n_rec_num,
                    l_n_rec_accept, l_n_rec_reject, l_n_rec_pending) THEN
     RAISE INV_HDR_OR_TLR;
  END IF;

  -- get the DL version, DL loan catg and file_type
  igf_sl_gen.get_dl_batch_details(l_c_message_class,l_c_batch_type,l_c_dl_version,l_c_dl_file_type,l_c_dl_loan_catg);
  IF l_c_dl_file_type <> 'DL_YTDS' OR l_c_dl_loan_catg <> 'DL' THEN
     RAISE INVALID_FILE;
  END IF;


   --To check whether the batch has been already loaded or not
   OPEN c_batch ;
   FETCH c_batch INTO c_batch_rec;
     IF c_batch%FOUND THEN
       CLOSE c_batch;
       FND_MESSAGE.SET_NAME('IGF','IGF_GE_BATCH_ALREADY_LOADED');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       RETURN;
     END IF;
   CLOSE c_batch;

  -- Bug # 2758823. Removed the ref cursor c_count_ytd_rec1

    /* Get the records from the temporary table. Split each column and
        insert into the igf_db_ytd_smr_all table */

  IF (l_n_last_lort_id-2) <>  l_n_rec_num THEN
     RAISE INV_TRL_NUM;
  END IF;

 FOR loadrec IN c_ytd_summary(l_n_last_lort_id) LOOP
   BEGIN
     IF l_c_dl_version IN ('2002-2003','2003-2004','2004-2005','2005-2006','2006-2007') THEN
        l_dl_ytds_rec.dl_version           :=l_c_dl_version ;
        l_dl_ytds_rec.record_type          :=SUBSTR(loadrec.record_data,1 ,1);
        l_dl_ytds_rec.batch_id             :=SUBSTR(loadrec.record_data, 2,23);
        l_dl_ytds_rec.school_code          :=SUBSTR(loadrec.record_data, 25,6);
        l_dl_ytds_rec.region_code          :=SUBSTR(loadrec.record_data,31,2);
        l_dl_ytds_rec.state_code           :=SUBSTR(loadrec.record_data,33,2);
        l_dl_ytds_rec.stat_end_dt          :=FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,35,8),'YYYYMMDD');
        l_dl_ytds_rec.process_dt           :=FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,43,8),'YYYYMMDD');
        l_dl_ytds_rec.disb_smr_type        :=SUBSTR(loadrec.record_data,51,2);
        l_dl_ytds_rec.bkd_gross            :=SUBSTR(loadrec.record_data,53,11);
        l_dl_ytds_rec.bkd_fee              :=SUBSTR(loadrec.record_data,64,11);
        l_dl_ytds_rec.bkd_int_rebate       :=SUBSTR(loadrec.record_data,75,11);
        l_dl_ytds_rec.bkd_net              :=SUBSTR(loadrec.record_data,86,11);
        l_dl_ytds_rec.unbkd_gross          :=SUBSTR(loadrec.record_data,97,11);
        l_dl_ytds_rec.unbkd_fee            :=SUBSTR(loadrec.record_data,108,11);
        l_dl_ytds_rec.unbkd_int_rebate     :=SUBSTR(loadrec.record_data,119,11);
        l_dl_ytds_rec.unbkd_net            :=SUBSTR(loadrec.record_data,130,11);
        l_dl_ytds_rec.rec_count            :=SUBSTR(loadrec.record_data,215,6);

        l_rowid := NULL;
           igf_db_ytd_smr_pkg.insert_row(
             x_mode                  => 'R',
             x_rowid                 => l_rowid,
             x_ytds_id               =>l_ytds_id,
             x_dl_version            =>l_dl_ytds_rec.dl_version         ,
             x_record_type           =>l_dl_ytds_rec.record_type        ,
             x_batch_id              =>l_dl_ytds_rec.batch_id           ,
             x_school_code           =>l_dl_ytds_rec.school_code        ,
             x_stat_end_dt           =>l_dl_ytds_rec.stat_end_dt        ,
             x_process_dt            =>l_dl_ytds_rec.process_dt         ,
             x_disb_smr_type         =>l_dl_ytds_rec.disb_smr_type      ,
             x_bkd_gross             =>l_dl_ytds_rec.bkd_gross          ,
             x_bkd_fee               =>l_dl_ytds_rec.bkd_fee            ,
             x_bkd_int_rebate        =>l_dl_ytds_rec.bkd_int_rebate     ,
             x_bkd_net               =>l_dl_ytds_rec.bkd_net            ,
             x_unbkd_gross           =>l_dl_ytds_rec.unbkd_gross        ,
             x_unbkd_fee             =>l_dl_ytds_rec.unbkd_fee          ,
             x_unbkd_int_rebate      =>l_dl_ytds_rec.unbkd_int_rebate   ,
             x_unbkd_net             =>l_dl_ytds_rec.unbkd_net          ,
             x_region_code           =>l_dl_ytds_rec.region_code        ,
             x_state_code            =>l_dl_ytds_rec.state_code         ,
             x_rec_count             =>l_dl_ytds_rec.rec_count
             );

          l_processed_count := l_processed_count +1 ;
     ELSE
          fnd_message.set_name('IGF','IGF_SL_INVALID_RECORD');
          fnd_message.set_token('BATCH_ID',SUBSTR(loadrec.record_data, 2,23));
          fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
          fnd_message.set_name('IGF','IGF_SL_INVALID_RECORD');
          fnd_message.set_token('BATCH_ID',SUBSTR(loadrec.record_data, 2,23));
          fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
   END ;

  END LOOP;

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_SUM_FET');
  FND_MESSAGE.SET_TOKEN('VALUE',(l_n_last_lort_id-2));
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_SCHOOL_AWARD');
  FND_MESSAGE.SET_TOKEN('VALUE',p_school_code);
  FND_MESSAGE.SET_TOKEN('AWD_YR',p_award_year);
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_SUM_PRO');
  FND_MESSAGE.SET_TOKEN('VALUE',l_processed_count);
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_SUM_REJ');
  FND_MESSAGE.SET_TOKEN('VALUE',((l_n_last_lort_id-2) - l_processed_count));
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

EXCEPTION
WHEN INV_TRL_NUM THEN
    RAISE;

WHEN INV_HDR_OR_TLR THEN
    RAISE;

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
   FND_MESSAGE.SET_TOKEN('NAME','igf_db_dl_reconc.ytd_load_summary');
   IGS_GE_MSG_STACK.ADD;
   APP_EXCEPTION.RAISE_EXCEPTION;

END load_ytd_summary;

 PROCEDURE load_ytd_detail(p_school_code VARCHAR2, p_award_year igf_sl_dl_setup_v.ci_alternate_code%TYPE, p_c_dl_version igf_sl_dl_setup_v.DL_VERSION%TYPE) AS
 /***************************************************************
   Created By           :       adhawan
   Date Created By      :       22-jan-2002
   Purpose                  :   To load igf_db_ytd_dtl from igf_sl_load_file_t
   Known Limitations,Enhancements or Remarks:
   Change History       :2154941
   Who          When            What
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               changed first parameter to this procedure as passed to main_smr process
                               and replaced references of school_id of igf_sl_dl_setup table with newly
                               changed p_school_code w.r.t. FA 126
   smvk         25-Feb-2003     Bug # 2758823. Validating Header and trailer. Done changes for 2003-2004 awary year.
   adhawan      22-jan-2002     Disbursements build
 ***************************************************************/

 l_loaded_batch_id igf_db_ytd_dtl.batch_id%TYPE;
-- To ensure whether the batch is loaded , if yes then the records should not be loaded again
 CURSOR c_batch  IS
   SELECT record_data FROM igf_sl_load_file_t ,igf_db_ytd_dtl ln
     WHERE file_type ='DL_YTDD'  AND
     SUBSTR(record_data,1,1)='D' AND
     SUBSTR(record_data,2,23) =ln.batch_id ;
 c_batch_rec c_batch%ROWTYPE;


 CURSOR c_ytd_detail (cp_c_last_lort_id igf_sl_load_file_t.lort_id%TYPE) IS
 SELECT  record_data  FROM
      igf_sl_load_file_t , igf_sl_loans_v sl
      WHERE lort_id BETWEEN 2 AND (cp_c_last_lort_id-1)
      AND file_type ='DL_YTDD'
      AND SUBSTR(record_data,1,1)='D'
      AND SUBSTR(record_data,25,6)=p_school_code    -- To select only those records who have a school code passed as parameter
      AND SUBSTR(record_data,51,21)=sl.loan_number--who have a valid loan number in the system(igf_sl_loans_v)
      ORDER BY lort_id ;

 l_dl_ytds_rec_det igf_db_ytd_dtl%ROWTYPE;
 l_rowid VARCHAR2(30);
 l_ytdd_id igf_db_ytd_dtl.ytdd_id%TYPE;
 l_counter NUMBER(20) := 0;

 --Variables used to give the end result of the processing of the records

 l_fetch_count     NUMBER(20) := 0;
 l_processed_count NUMBER(20) :=0;

  -- Variables to hold the value derive from header
  l_c_batch_id igf_sl_dl_batch.batch_id%TYPE;
  l_c_message_class igf_sl_dl_batch.message_class%TYPE;
  l_d_bth_creation_date igf_sl_dl_batch.bth_creation_date%TYPE;
  l_c_rej_code igf_sl_dl_batch.batch_rej_code%TYPE;
  l_c_batch_type igf_sl_dl_batch.batch_type%TYPE;

  -- Variables to hold the value derive from trailer
  l_n_last_lort_id NUMBER ;
  l_n_rec_num NUMBER;
  l_n_rec_accept NUMBER;
  l_n_rec_reject NUMBER;
  l_n_rec_pending NUMBER;

  l_c_dl_version    igf_sl_dl_file_type.dl_version%TYPE;
  l_c_dl_file_type  igf_sl_dl_file_type.dl_file_type%TYPE;
  l_c_dl_loan_catg  igf_sl_dl_file_type.dl_loan_catg%TYPE;

BEGIN

   -- checking the header
  IF NOT valid_header ( 'DL_YTDD', l_c_batch_id, l_c_message_class,
                   l_d_bth_creation_date, l_c_rej_code, l_c_batch_type) THEN
     RAISE INV_HDR_OR_TLR;
  END IF;
   -- checking the trailer
  IF NOT valid_trailer ( 'DL_YTDD', l_n_last_lort_id, l_n_rec_num,
                    l_n_rec_accept, l_n_rec_reject, l_n_rec_pending) THEN
     RAISE INV_HDR_OR_TLR;
  END IF;

  -- get the DL version, DL loan catg and file_type
  igf_sl_gen.get_dl_batch_details(l_c_message_class,l_c_batch_type,l_c_dl_version,l_c_dl_file_type,l_c_dl_loan_catg);
  IF l_c_dl_file_type <> 'DL_YTDD' OR l_c_dl_loan_catg <> 'DL' THEN
     RAISE INVALID_FILE;
  END IF;

    /* Get the total no of records that would be processed */
   --To check whether the batch has been already loaded or not
   OPEN c_batch ;
   FETCH c_batch INTO c_batch_rec;
     IF c_batch%FOUND THEN
       CLOSE c_batch;
       FND_MESSAGE.SET_NAME('IGF','IGF_GE_BATCH_ALREADY_LOADED');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       RETURN;
     END IF;
   CLOSE c_batch;

  -- Bug # 2758823. Removed the ref cursor c_count_ytd_rec1

    /* Get the records from the temporary table. Split each column and
        insert into the igf_db_ytd_dtl table */

  IF (l_n_last_lort_id-2) <>  l_n_rec_num THEN
     RAISE INV_TRL_NUM;
  END IF;

 FOR loadrec IN c_ytd_detail (l_n_last_lort_id) LOOP
   BEGIN
     IF l_c_dl_version IN ('2002-2003','2003-2004','2004-2005','2005-2006','2006-2007') THEN
        l_dl_ytds_rec_det.dl_version                  :=    l_c_dl_version;
        l_dl_ytds_rec_det.record_type                 :=    SUBSTR(loadrec.record_data,1,1);
        l_dl_ytds_rec_det.batch_id                    :=    SUBSTR(loadrec.record_data,2,23);
        l_dl_ytds_rec_det.school_code                 :=    SUBSTR(loadrec.record_data,25,6);
        l_dl_ytds_rec_det.region_code                 :=    SUBSTR(loadrec.record_data,31,2);
        l_dl_ytds_rec_det.state_code                  :=    SUBSTR(loadrec.record_data,33,2);
        l_dl_ytds_rec_det.stat_end_dt                 :=    FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,35,8),'YYYYMMDD');
        l_dl_ytds_rec_det.process_dt                  :=    FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,43,8),'YYYYMMDD');
        l_dl_ytds_rec_det.loan_number                 :=    SUBSTR(loadrec.record_data,51,21);
        l_dl_ytds_rec_det.loan_bkd_dt                 :=    FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,72,8),'YYYYMMDD');
        l_dl_ytds_rec_det.disb_bkd_dt                 :=    FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,80,8),'YYYYMMDD');
        l_dl_ytds_rec_det.disb_gross                  :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,88,5)));
        l_dl_ytds_rec_det.disb_fee                    :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,93,5)));
        l_dl_ytds_rec_det.disb_int_rebate             :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,98,5)));
        l_dl_ytds_rec_det.disb_net                    :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,103,5)));
        l_dl_ytds_rec_det.disb_net_adj                :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,108,6)));
        l_dl_ytds_rec_det.disb_num                    :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,114,2)));
        l_dl_ytds_rec_det.disb_seq_num                :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,116,2)));
        l_dl_ytds_rec_det.trans_type                  :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,118,1)));
        l_dl_ytds_rec_det.trans_dt                    :=    FND_DATE.STRING_TO_DATE(SUBSTR(loadrec.record_data,119,8),'YYYYMMDD');
        l_dl_ytds_rec_det.total_gross                 :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,127,5)));
        l_dl_ytds_rec_det.total_fee                   :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,132,5)));
        l_dl_ytds_rec_det.total_int_rebate            :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,137,5)));
        l_dl_ytds_rec_det.total_net                   :=    LTRIM(RTRIM(SUBSTR(loadrec.record_data,142,5)));
        l_dl_ytds_rec_det.rec_count                  :=     LTRIM(RTRIM(SUBSTR(loadrec.record_data,215,11)));

        l_rowid := NULL;

           igf_db_ytd_dtl_pkg.insert_row(
             x_mode                      =>    'R',
             x_rowid                     =>    l_rowid,
             x_ytdd_id                   =>    l_ytdd_id,
             x_dl_version                =>    l_dl_ytds_rec_det.dl_version                     ,
             x_record_type               =>    l_dl_ytds_rec_det.record_type                    ,
             x_batch_id                  =>    l_dl_ytds_rec_det.batch_id                       ,
             x_school_code               =>    l_dl_ytds_rec_det.school_code                    ,
             x_stat_end_dt               =>    l_dl_ytds_rec_det.stat_end_dt                    ,
             x_process_dt                =>    l_dl_ytds_rec_det.process_dt                     ,
             x_loan_number               =>    l_dl_ytds_rec_det.loan_number                    ,
             x_loan_bkd_dt               =>    l_dl_ytds_rec_det.loan_bkd_dt                    ,
             x_disb_bkd_dt               =>    l_dl_ytds_rec_det.disb_bkd_dt                    ,
             x_disb_gross                =>    l_dl_ytds_rec_det.disb_gross                     ,
             x_disb_fee                  =>    l_dl_ytds_rec_det.disb_fee                       ,
             x_disb_int_rebate           =>    l_dl_ytds_rec_det.disb_int_rebate                ,
             x_disb_net                  =>    l_dl_ytds_rec_det.disb_net                       ,
             x_disb_net_adj              =>    l_dl_ytds_rec_det.disb_net_adj                   ,
             x_disb_num                  =>    l_dl_ytds_rec_det.disb_num                       ,
             x_disb_seq_num              =>    l_dl_ytds_rec_det.disb_seq_num                   ,
             x_trans_type                =>    l_dl_ytds_rec_det.trans_type                     ,
             x_trans_dt                  =>    l_dl_ytds_rec_det.trans_dt                       ,
             x_total_gross               =>    l_dl_ytds_rec_det.total_gross                    ,
             x_total_fee                 =>    l_dl_ytds_rec_det.total_fee                      ,
             x_total_int_rebate          =>    l_dl_ytds_rec_det.total_int_rebate               ,
             x_total_net                 =>    l_dl_ytds_rec_det.total_net                      ,
             x_region_code               =>    l_dl_ytds_rec_det.region_code                        ,
             x_state_code                =>    l_dl_ytds_rec_det.state_code                         ,
             x_rec_count                 =>    l_dl_ytds_rec_det.rec_count
                );

       l_processed_count := l_processed_count +1;
     ELSE
          fnd_message.set_name('IGF','IGF_SL_INVALID_RECORD');
          fnd_message.set_token('BATCH_ID',SUBSTR(loadrec.record_data, 2,23));
          fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     END IF;

   EXCEPTION
     WHEN INV_TRL_NUM THEN
         RAISE;
     WHEN OTHERS THEN
          fnd_message.set_name('IGF','IGF_SL_INVALID_RECORD');
          fnd_message.set_token('BATCH_ID',SUBSTR(loadrec.record_data, 2,23));
          fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
   END ;

  END LOOP;

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_DET_FET');
  FND_MESSAGE.SET_TOKEN('VALUE',(l_n_last_lort_id-2));
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_SCHOOL_AWD_DTL');
  FND_MESSAGE.SET_TOKEN('VALUE',p_school_code);
  FND_MESSAGE.SET_TOKEN('AWD_YR',p_award_year);
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_DET_PRO');
  FND_MESSAGE.SET_TOKEN('VALUE',l_processed_count);
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGF','IGF_DB_YTD_DET_REJ');
  FND_MESSAGE.SET_TOKEN('VALUE',((l_n_last_lort_id-2) - l_processed_count));
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

EXCEPTION

WHEN INV_TRL_NUM THEN
     RAISE;
WHEN INVALID_FILE THEN
     RAISE;
WHEN INV_HDR_OR_TLR THEN
     RAISE;
WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
   FND_MESSAGE.SET_TOKEN('NAME','igf_db_dl_reconc.ytd_load_detail');
   IGS_GE_MSG_STACK.ADD;
   APP_EXCEPTION.RAISE_EXCEPTION;

END load_ytd_detail;


PROCEDURE main_smr      (ERRBUF                 OUT NOCOPY          VARCHAR2,
                         RETCODE            OUT NOCOPY         NUMBER,
                         p_award_year    IN         VARCHAR2,
                         SCHOOL_TYPE    IN      VARCHAR2,
                         P_SCHOOL_CODE  IN      VARCHAR2
                         ) IS
 /***************************************************************
   Created By           :       adhawan
   Date Created By      :       22-jan-2002
   Purpose                  :   To load the
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who          When            What
   tsailaja		13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               added two new parameters school_type and p_school_code and
                               removed school_id as it is being obsoleted from igf_sl_dl_setup_all table.
   smvk         25-Feb-2003    Bug # 2758823. Removed the award year checking 2002-2003 and displaying the error message "IGF_DB_DL_VERSION_FALSE"
 ***************************************************************/
 l_ci_cal_type        igf_sl_dl_setup.ci_cal_type%TYPE;
 l_ci_sequence_number igf_sl_dl_setup.ci_sequence_number%TYPE;


  CURSOR c_get_ver IS
    SELECT dl_version , ci_alternate_code FROM
    igf_sl_dl_setup_v
    WHERE
    ci_cal_type        =l_ci_cal_type AND
    ci_sequence_number =l_ci_sequence_number ;
    c_get_ver_rec c_get_ver%ROWTYPE ;

  l_award_year igf_sl_dl_setup_v.ci_alternate_code%TYPE;

 BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode :=0;
    l_ci_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10))) ;
    l_ci_sequence_number  := TO_NUMBER(SUBSTR(p_award_year,11)) ;


    OPEN c_get_ver ;
    FETCH c_get_ver INTO c_get_ver_rec;
--Checking if the data setup for    the version is there or not
      IF c_get_ver%NOTFOUND THEN
        CLOSE c_get_ver;
        FND_MESSAGE.SET_NAME('IGF','IGF_DB_DL_VERSION_FALSE');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        RETURN;
      ELSE
        l_award_year:=c_get_ver_rec.ci_alternate_code;

      END IF;
    CLOSE c_get_ver;

-- Calling the procedure to load the data from igf_sl_load_file_t to igf_db_ytd_smr table
  load_ytd_summary(P_SCHOOL_CODE, l_award_year);

  EXCEPTION
      WHEN INV_TRL_NUM THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');

      WHEN INVALID_FILE THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_INVALID_FILE');

      WHEN INV_HDR_OR_TLR THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_COMPLETE');

      WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf := FND_MESSAGE.GET_STRING('IGF','IGF_GE_LOCK_ERROR');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END main_smr;

  PROCEDURE main_dtl     (ERRBUF                OUT NOCOPY          VARCHAR2,
                          RETCODE               OUT NOCOPY          NUMBER,
                          p_award_year          IN         VARCHAR2,
                          SCHOOL_TYPE    IN      VARCHAR2,
                          P_SCHOOL_CODE  IN      VARCHAR2
                         ) IS
 /***************************************************************
   Created By           :       adhawan
   Date Created By      :       22-jan-2002
   Purpose                  :   To load the
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who          When            What
   tsailaja		13/Jan/2006    Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               added two new parameters school_type and p_school_code and
                               removed school_id as it is being obsoleted from igf_sl_dl_setup_all table.
   smvk         25-Feb-2003    Bug # 2758823. Removed the award year checking 2002-2003 and displaying the error message "IGF_DB_DL_VERSION_FALSE"
 ***************************************************************/
 l_ci_cal_type        igf_sl_dl_setup.ci_cal_type%TYPE;
 l_ci_sequence_number igf_sl_dl_setup.ci_sequence_number%TYPE;



  CURSOR c_get_ver IS
    SELECT dl_version , ci_alternate_code FROM
    igf_sl_dl_setup_v
    WHERE
    ci_cal_type        =l_ci_cal_type AND
    ci_sequence_number =l_ci_sequence_number ;

    c_get_ver_rec c_get_ver%ROWTYPE ;


  l_award_year igf_sl_dl_setup_v.ci_alternate_code%TYPE;

 BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode :=0;
    l_ci_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10))) ;
    l_ci_sequence_number  := TO_NUMBER(SUBSTR(p_award_year,11)) ;



    OPEN c_get_ver ;
    FETCH c_get_ver INTO c_get_ver_rec;
--Checking if the data setup for the version is there or not
      IF c_get_ver%NOTFOUND THEN
        CLOSE c_get_ver;
        FND_MESSAGE.SET_NAME('IGF','IGF_DB_DL_VERSION_FALSE');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        RETURN;
      ELSE
        l_award_year :=c_get_ver_rec.ci_alternate_code;

      END IF;

    CLOSE c_get_ver;

-- Calling the procedure to load the data from igf_sl_load_file_t to igf_db_ytd_dtl table
  load_ytd_detail(P_SCHOOL_CODE, l_award_year, c_get_ver_rec.dl_version);

  EXCEPTION
      WHEN INV_TRL_NUM THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');

      WHEN INVALID_FILE THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_INVALID_FILE');

      WHEN INV_HDR_OR_TLR THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_COMPLETE');

      WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf := FND_MESSAGE.GET_STRING('IGF','IGF_GE_LOCK_ERROR');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END main_dtl;

END igf_db_dl_reconc;

/
