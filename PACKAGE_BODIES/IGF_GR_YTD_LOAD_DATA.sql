--------------------------------------------------------
--  DDL for Package Body IGF_GR_YTD_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_YTD_LOAD_DATA" AS
/* $Header: IGFGR04B.pls 120.2 2006/04/06 06:09:41 veramach ship $ */

  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/20
    Purpose		:	To upload data into IGF_GR_YTD_ORIG and IGF_GR_YTD_DISB files

    Known Limitations,Enhancements or Remarks
    Change History	: Big Id : 1706091  Wrong error message and token
    Who			When		What
    veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
    avenkatr            26-MAR-2001     1.  Message token changed
                                        2.  Substr positions corrected in procedure "split_into_disb_fields"
  ***************************************************************/


  param_error             EXCEPTION;
  invalid_version         EXCEPTION;     -- Thrown if the award year doesn't matches with that on the flat file.

  g_ver_num               VARCHAR2(30)    DEFAULT NULL; -- Flat File Version Number
  g_c_alt_code            VARCHAR2(80)    DEFAULT NULL; -- To hold alternate code.
  g_ci_cal_type           igf_gr_rfms.ci_cal_type%TYPE;
  g_ci_sequence_number    igf_gr_rfms.ci_sequence_number%TYPE;


  PROCEDURE split_into_orig_fields ( p_record_data    IN  igf_gr_load_file_t.record_data%TYPE,
                                     p_ytd_orig_row   OUT NOCOPY igf_gr_ytd_orig%ROWTYPE)
  AS
  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/20
    Purpose		:	To split data in the single record_data column of igf_gr_load_file_t
                                into the different columns of igf_gr_ytd_orig table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    smvk               11-Feb-2003      Bug # 2758812. Added '2003-2004' in g_ver_num checking.
  ***************************************************************/

   CURSOR cur_get_orig  ( p_orig_id              igf_gr_rfms_all.origination_id%TYPE,
                          p_ci_cal_type          igf_gr_rfms.ci_cal_type%TYPE,
                          p_ci_sequence_number   igf_gr_rfms.ci_sequence_number%TYPE)
   IS
   SELECT
   COUNT(origination_id) rec_count
   FROM
   igf_gr_rfms
   WHERE
   ci_cal_type        = p_ci_cal_type AND
   ci_sequence_number = p_ci_sequence_number AND
   p_orig_id          = origination_id;

   get_orig_rec  cur_get_orig%ROWTYPE;



  BEGIN


    IF g_ver_num IN ('2002-2003', '2003-2004','2004-2005') THEN

         BEGIN

            p_ytd_orig_row.origination_id      := SUBSTR( p_record_data, 2, 23) ;
            OPEN  cur_get_orig(p_ytd_orig_row.origination_id,
                              g_ci_cal_type,
                              g_ci_sequence_number);
            FETCH cur_get_orig INTO get_orig_rec;
            CLOSE cur_get_orig;

--
-- If origination id does not exist in the System, skip this record
--
            IF get_orig_rec.rec_count = 0 THEN

               fnd_message.set_name('IGF','IGF_GR_REC_NOT_FOUND');
               fnd_message.set_token('ORIG_ID',p_ytd_orig_row.origination_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               RAISE igf_gr_gen.skip_this_record;

            ELSE

               p_ytd_orig_row.original_ssn              := SUBSTR( p_record_data, 25, 9);
               p_ytd_orig_row.original_name_cd          := SUBSTR( p_record_data, 34, 2);
               p_ytd_orig_row.attend_pell_id            := SUBSTR( p_record_data, 36, 6);
               p_ytd_orig_row.ed_use                    := SUBSTR( p_record_data, 42, 5);
               p_ytd_orig_row.inst_cross_ref_code       := SUBSTR( p_record_data, 47, 13);
               p_ytd_orig_row.action_code               := SUBSTR( p_record_data, 60, 1);
               p_ytd_orig_row.accpt_awd_amt             := TO_NUMBER(SUBSTR( p_record_data, 62, 7))/100;
               p_ytd_orig_row.accpt_disb_dt1            := fnd_date.string_to_date(SUBSTR( p_record_data, 69, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt2            := fnd_date.string_to_date(SUBSTR( p_record_data, 77, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt3            := fnd_date.string_to_date(SUBSTR( p_record_data, 85, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt4            := fnd_date.string_to_date(SUBSTR( p_record_data, 93, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt5            := fnd_date.string_to_date(SUBSTR( p_record_data, 101, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt6            := fnd_date.string_to_date(SUBSTR( p_record_data, 109, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt7            := fnd_date.string_to_date(SUBSTR( p_record_data, 117, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt8            := fnd_date.string_to_date(SUBSTR( p_record_data, 125, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt9            := fnd_date.string_to_date(SUBSTR( p_record_data, 133, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt10           := fnd_date.string_to_date(SUBSTR( p_record_data, 141, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt11           := fnd_date.string_to_date(SUBSTR( p_record_data, 149, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt12           := fnd_date.string_to_date(SUBSTR( p_record_data, 157, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt13           := fnd_date.string_to_date(SUBSTR( p_record_data, 165, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt14           := fnd_date.string_to_date(SUBSTR( p_record_data, 173, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt15           := fnd_date.string_to_date(SUBSTR( p_record_data, 181, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_enrl_dt             := fnd_date.string_to_date(SUBSTR( p_record_data, 189, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_low_tut_flg         := SUBSTR( p_record_data, 197, 1);
               p_ytd_orig_row.accpt_ver_stat_flg        := SUBSTR( p_record_data, 198, 1);
               p_ytd_orig_row.accpt_incr_pell_cd        := SUBSTR( p_record_data, 199, 1);
               p_ytd_orig_row.accpt_tran_num            := SUBSTR( p_record_data, 200, 2);
               p_ytd_orig_row.accpt_efc                 := SUBSTR( p_record_data, 202, 5);
               p_ytd_orig_row.accpt_sec_efc             := SUBSTR( p_record_data, 207, 1);
               p_ytd_orig_row.accpt_acad_cal            := SUBSTR( p_record_data, 208, 1);
               p_ytd_orig_row.accpt_pymt_method         := SUBSTR( p_record_data, 209, 1);
               p_ytd_orig_row.accpt_coa                 := TO_NUMBER(SUBSTR( p_record_data, 210, 7))/100;
               p_ytd_orig_row.accpt_enrl_stat           := SUBSTR( p_record_data, 217, 1);
               p_ytd_orig_row.accpt_wks_inst_pymt       := SUBSTR( p_record_data, 218, 2);
               p_ytd_orig_row.wk_inst_time_calc_pymt    := TO_NUMBER(SUBSTR( p_record_data, 220, 2));
               p_ytd_orig_row.accpt_wks_acad            := SUBSTR( p_record_data, 222, 4);
               p_ytd_orig_row.accpt_cr_acad_yr          := SUBSTR( p_record_data, 226, 4);
               p_ytd_orig_row.inst_seq_num              := SUBSTR( p_record_data, 230, 3);
               p_ytd_orig_row.sch_full_time_pell        := TO_NUMBER(SUBSTR( p_record_data, 252, 5));
               p_ytd_orig_row.stud_name                 := SUBSTR( p_record_data, 257, 29);
               p_ytd_orig_row.ssn                       := SUBSTR( p_record_data, 286, 9);
               p_ytd_orig_row.stud_dob                  := fnd_date.string_to_date(SUBSTR( p_record_data, 295, 8), 'YYYYMMDD');
               p_ytd_orig_row.cps_ver_sel_cd            := fnd_date.string_to_date(SUBSTR( p_record_data, 303, 1), 'YYYYMMDD');
               p_ytd_orig_row.ytd_disb_amt              := TO_NUMBER(SUBSTR( p_record_data, 304, 7))/100;
               p_ytd_orig_row.batch_id                  := SUBSTR( p_record_data, 311, 26);
               p_ytd_orig_row.process_date              := fnd_date.string_to_date(SUBSTR( p_record_data, 337, 8), 'YYYYMMDD');

            END IF;

            EXCEPTION
            WHEN OTHERS THEN     -- Number / Date format exception
                 RAISE igf_gr_gen.skip_this_record;

        END;

         ELSIF g_ver_num IN ('2005-2006','2006-2007') THEN

               p_ytd_orig_row.original_ssn              := SUBSTR( p_record_data, 25, 9);
               p_ytd_orig_row.original_name_cd          := SUBSTR( p_record_data, 34, 2);
               p_ytd_orig_row.attend_pell_id            := SUBSTR( p_record_data, 36, 6);
               p_ytd_orig_row.ed_use                    := SUBSTR( p_record_data, 42, 5);
               p_ytd_orig_row.inst_cross_ref_code       := SUBSTR( p_record_data, 47, 13);
               p_ytd_orig_row.action_code               := SUBSTR( p_record_data, 60, 1);
               p_ytd_orig_row.accpt_awd_amt             := TO_NUMBER(SUBSTR( p_record_data, 62, 7))/100;
               p_ytd_orig_row.accpt_disb_dt1            := fnd_date.string_to_date(SUBSTR( p_record_data, 69, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt2            := fnd_date.string_to_date(SUBSTR( p_record_data, 77, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt3            := fnd_date.string_to_date(SUBSTR( p_record_data, 85, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt4            := fnd_date.string_to_date(SUBSTR( p_record_data, 93, 8),  'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt5            := fnd_date.string_to_date(SUBSTR( p_record_data, 101, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt6            := fnd_date.string_to_date(SUBSTR( p_record_data, 109, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt7            := fnd_date.string_to_date(SUBSTR( p_record_data, 117, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt8            := fnd_date.string_to_date(SUBSTR( p_record_data, 125, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt9            := fnd_date.string_to_date(SUBSTR( p_record_data, 133, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt10           := fnd_date.string_to_date(SUBSTR( p_record_data, 141, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt11           := fnd_date.string_to_date(SUBSTR( p_record_data, 149, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt12           := fnd_date.string_to_date(SUBSTR( p_record_data, 157, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt13           := fnd_date.string_to_date(SUBSTR( p_record_data, 165, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt14           := fnd_date.string_to_date(SUBSTR( p_record_data, 173, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_disb_dt15           := fnd_date.string_to_date(SUBSTR( p_record_data, 181, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_enrl_dt             := fnd_date.string_to_date(SUBSTR( p_record_data, 189, 8), 'YYYYMMDD');
               p_ytd_orig_row.accpt_low_tut_flg         := SUBSTR( p_record_data, 197, 1);
               p_ytd_orig_row.accpt_ver_stat_flg        := SUBSTR( p_record_data, 198, 1);
               p_ytd_orig_row.accpt_incr_pell_cd        := SUBSTR( p_record_data, 199, 1);
               p_ytd_orig_row.accpt_tran_num            := SUBSTR( p_record_data, 200, 2);
               p_ytd_orig_row.accpt_efc                 := SUBSTR( p_record_data, 202, 5);
               p_ytd_orig_row.accpt_sec_efc             := NULL;
               p_ytd_orig_row.accpt_acad_cal            := NULL;
               p_ytd_orig_row.accpt_pymt_method         := NULL;
               p_ytd_orig_row.accpt_coa                 := TO_NUMBER(SUBSTR( p_record_data, 210, 7))/100;
               p_ytd_orig_row.accpt_enrl_stat           := SUBSTR( p_record_data, 217, 1);
               p_ytd_orig_row.accpt_wks_inst_pymt       := NULL;
               p_ytd_orig_row.wk_inst_time_calc_pymt    := NULL;
               p_ytd_orig_row.accpt_wks_acad            := NULL;
               p_ytd_orig_row.accpt_cr_acad_yr          := NULL;
               p_ytd_orig_row.inst_seq_num              := SUBSTR( p_record_data, 230, 3);
               p_ytd_orig_row.sch_full_time_pell        := TO_NUMBER(SUBSTR( p_record_data, 252, 5));
               p_ytd_orig_row.stud_name                 := SUBSTR( p_record_data, 257, 29);
               p_ytd_orig_row.ssn                       := SUBSTR( p_record_data, 286, 9);
               p_ytd_orig_row.stud_dob                  := fnd_date.string_to_date(SUBSTR( p_record_data, 295, 8), 'YYYYMMDD');
               p_ytd_orig_row.cps_ver_sel_cd            := SUBSTR( p_record_data, 303, 1);
               p_ytd_orig_row.ytd_disb_amt              := TO_NUMBER(SUBSTR( p_record_data, 304, 7))/100;
               p_ytd_orig_row.batch_id                  := NULL;
               p_ytd_orig_row.process_date              := fnd_date.string_to_date(SUBSTR( p_record_data, 337, 8), 'YYYYMMDD');


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
      fnd_message.set_token('NAME','igf_gr_ytd_load_data.split_into_orig_fields');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END split_into_orig_fields;


PROCEDURE split_into_disb_fields ( p_record_data    IN   igf_gr_load_file_t.record_data%TYPE,
                                   p_ytd_disb_row   OUT NOCOPY  igf_gr_ytd_disb%ROWTYPE)
AS
  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/20
    Purpose		:	To split data in the single record_data column of igf_gr_load_file_t
                                into the different columns of igf_gr_ytd_disb table

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
    smvk               11-Feb-2003      Bug # 2758812. Added '2003-2004' in g_ver_num checking.
  ***************************************************************/

   CURSOR cur_get_orig  ( p_orig_id              igf_gr_rfms_all.origination_id%TYPE,
                          p_ci_cal_type          igf_gr_rfms.ci_cal_type%TYPE,
                          p_ci_sequence_number   igf_gr_rfms.ci_sequence_number%TYPE)
   IS
   SELECT
   COUNT(origination_id) rec_count
   FROM
   igf_gr_rfms
   WHERE
   ci_cal_type        = p_ci_cal_type AND
   ci_sequence_number = p_ci_sequence_number AND
   p_orig_id          = origination_id;

   get_orig_rec  cur_get_orig%ROWTYPE;


BEGIN

    IF g_ver_num IN ('2002-2003', '2003-2004','2004-2005') THEN

         BEGIN
--
-- If origination id does not exist in the System, skip this record
--
            p_ytd_disb_row.origination_id      :=  SUBSTR( p_record_data, 2, 23) ;

            OPEN  cur_get_orig(p_ytd_disb_row.origination_id,
                              g_ci_cal_type,
                              g_ci_sequence_number);
            FETCH cur_get_orig INTO get_orig_rec;
            CLOSE cur_get_orig;

--
-- If origination id does not exist in the System, skip this record
--
            IF get_orig_rec.rec_count = 0 THEN

               fnd_message.set_name('IGF','IGF_GR_REC_NOT_FOUND');
               fnd_message.set_token('ORIG_ID',p_ytd_disb_row.origination_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               RAISE igf_gr_gen.skip_this_record;

            ELSE

               p_ytd_disb_row.inst_cross_ref_code :=  SUBSTR( p_record_data, 25, 13);
               p_ytd_disb_row.action_code         :=  SUBSTR( p_record_data, 38, 1);
               p_ytd_disb_row.disb_ref_num        :=  SUBSTR( p_record_data, 39, 2);
               p_ytd_disb_row.disb_accpt_amt      :=  TO_NUMBER(SUBSTR( p_record_data, 41, 7))/100;
               p_ytd_disb_row.db_cr_flag          :=  SUBSTR( p_record_data, 48, 1);
               p_ytd_disb_row.disb_dt             :=  fnd_date.string_to_date(SUBSTR( p_record_data, 49, 8), 'YYYYMMDD');
               p_ytd_disb_row.pymt_prd_start_dt   :=  fnd_date.string_to_date(SUBSTR( p_record_data, 94, 8), 'YYYYMMDD');
               p_ytd_disb_row.disb_batch_id       :=  SUBSTR( p_record_data, 139, 26);

            END IF;

            EXCEPTION
            WHEN OTHERS THEN     -- Number / Date format exception
                 RAISE igf_gr_gen.skip_this_record;

        END;

         ELSIF g_ver_num IN ('2005-2006','2006-2007') THEN

               p_ytd_disb_row.inst_cross_ref_code :=  SUBSTR( p_record_data, 25, 13);
               p_ytd_disb_row.action_code         :=  SUBSTR( p_record_data, 38, 1);
               p_ytd_disb_row.disb_ref_num        :=  SUBSTR( p_record_data, 39, 2);
               p_ytd_disb_row.disb_accpt_amt      :=  TO_NUMBER(SUBSTR( p_record_data, 41, 7))/100;
               p_ytd_disb_row.db_cr_flag          :=  SUBSTR( p_record_data, 48, 1);
               p_ytd_disb_row.disb_dt             :=  fnd_date.string_to_date(SUBSTR( p_record_data, 49, 8), 'YYYYMMDD');
               p_ytd_disb_row.pymt_prd_start_dt   :=  fnd_date.string_to_date(SUBSTR( p_record_data, 58, 8), 'YYYYMMDD');
               p_ytd_disb_row.disb_batch_id       :=  SUBSTR( p_record_data, 104, 26);
	             p_ytd_disb_row.disb_process_date     :=  fnd_date.string_to_date(SUBSTR(p_record_data, 130, 8), 'YYYYMMDD');
    	         p_ytd_disb_row.routing_id_txt        :=  SUBSTR(p_record_data, 138, 8);
 	             p_ytd_disb_row.fin_award_year_num    :=  TO_NUMBER(SUBSTR(p_record_data, 146, 4));
 	             p_ytd_disb_row.attend_entity_id_txt  :=  SUBSTR(p_record_data, 150, 6);
 	             p_ytd_disb_row.student_name          :=  SUBSTR(p_record_data, 156, 29);
 	             p_ytd_disb_row.current_ssn_txt       :=  SUBSTR(p_record_data, 185, 9);
 	             p_ytd_disb_row.student_birth_date    :=  fnd_date.string_to_date(SUBSTR(p_record_data, 194, 8), 'YYYYMMDD');
 	             p_ytd_disb_row.disb_seq_num          :=  TO_NUMBER(SUBSTR(p_record_data, 202, 2));
 	             p_ytd_disb_row.disb_rel_ind          :=  SUBSTR(p_record_data, 204, 1);
 	             p_ytd_disb_row.prev_disb_seq_num     :=  TO_NUMBER(SUBSTR(p_record_data, 205, 2));

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
      fnd_message.set_token('NAME','igf_gr_ytd_load_data.split_into_disb_fields');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END split_into_disb_fields ;


PROCEDURE insert_in_ytdor_table ( p_orig_rec  IN  igf_gr_ytd_orig%ROWTYPE )
AS
  /***************************************************************
  Created By		:	avenkatr
  Date Created By	:	2000/12/19
  Purpose		:	To Load data into IGF_GR_MRR table

  Known Limitations,Enhancements or Remarks
  Change History	:
  Who			When		What
  ***************************************************************/
  lv_rowid VARCHAR2(25);
  lv_ytdor_id NUMBER;

BEGIN

   igf_gr_ytd_orig_pkg.insert_row (
      x_rowid                     => lv_rowid,
      x_ytdor_id                  => lv_ytdor_id,
      x_origination_id            => p_orig_rec.origination_id,
      x_original_ssn              => p_orig_rec.original_ssn,
      x_original_name_cd          => p_orig_rec.original_name_cd,
      x_attend_pell_id            => p_orig_rec.attend_pell_id,
      x_ed_use                    => P_orig_rec.ed_use,
      x_inst_cross_ref_code       => p_orig_rec.inst_cross_ref_code,
      x_action_code               => p_orig_rec.action_code,
      x_accpt_awd_amt             => p_orig_rec.accpt_awd_amt,
      x_accpt_disb_dt1            => p_orig_rec.accpt_disb_dt1,
      x_accpt_disb_dt2            => p_orig_rec.accpt_disb_dt2,
      x_accpt_disb_dt3            => p_orig_rec.accpt_disb_dt3,
      x_accpt_disb_dt4            => p_orig_rec.accpt_disb_dt4,
      x_accpt_disb_dt5            => p_orig_rec.accpt_disb_dt5,
      x_accpt_disb_dt6            => p_orig_rec.accpt_disb_dt6,
      x_accpt_disb_dt7            => p_orig_rec.accpt_disb_dt7,
      x_accpt_disb_dt8            => p_orig_rec.accpt_disb_dt8,
      x_accpt_disb_dt9            => p_orig_rec.accpt_disb_dt9,
      x_accpt_disb_dt10           => p_orig_rec.accpt_disb_dt10,
      x_accpt_disb_dt11           => p_orig_rec.accpt_disb_dt11,
      x_accpt_disb_dt12           => p_orig_rec.accpt_disb_dt12,
      x_accpt_disb_dt13           => p_orig_rec.accpt_disb_dt13,
      x_accpt_disb_dt14           => p_orig_rec.accpt_disb_dt14,
      x_accpt_disb_dt15           => p_orig_rec.accpt_disb_dt15,
      x_accpt_enrl_dt             => p_orig_rec.accpt_enrl_dt,
      x_accpt_low_tut_flg         => p_orig_rec.accpt_low_tut_flg,
      x_accpt_ver_stat_flg        => p_orig_rec.accpt_ver_stat_flg,
      x_accpt_incr_pell_cd        => p_orig_rec.accpt_incr_pell_cd,
      x_accpt_tran_num            => p_orig_rec.accpt_tran_num,
      x_accpt_efc                 => p_orig_rec.accpt_efc,
      x_accpt_sec_efc             => p_orig_rec.accpt_sec_efc,
      x_accpt_acad_cal            => p_orig_rec.accpt_acad_cal,
      x_accpt_pymt_method         => p_orig_rec.accpt_pymt_method,
      x_accpt_coa                 => p_orig_rec.accpt_coa,
      x_accpt_enrl_stat           => p_orig_rec.accpt_enrl_stat,
      x_accpt_wks_inst_pymt       => p_orig_rec.accpt_wks_inst_pymt,
      x_wk_inst_time_calc_pymt    => p_orig_rec.wk_inst_time_calc_pymt,
      x_accpt_wks_acad            => p_orig_rec.accpt_wks_acad,
      x_accpt_cr_acad_yr          => p_orig_rec.accpt_cr_acad_yr,
      x_inst_seq_num              => p_orig_rec.inst_seq_num,
      x_sch_full_time_pell        => p_orig_rec.sch_full_time_pell,
      x_stud_name                 => p_orig_rec.stud_name,
      x_ssn                       => p_orig_rec.ssn ,
      x_stud_dob                  => p_orig_rec.stud_dob,
      x_cps_ver_sel_cd            => p_orig_rec.cps_ver_sel_cd,
      x_ytd_disb_amt              => p_orig_rec.ytd_disb_amt,
      x_batch_id                  => p_orig_rec.batch_id ,
      x_process_date              => p_orig_rec.process_date,
      x_mode                      => 'R',
      x_ci_cal_type               => g_ci_cal_type,
      x_ci_sequence_number        => g_ci_sequence_number
    );

EXCEPTION

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_ytd_load_data.insert_in_ytdor_table');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END insert_in_ytdor_table;


PROCEDURE insert_in_ytdds_table ( p_orig_rec  IN  igf_gr_ytd_disb%ROWTYPE )
AS
  /***************************************************************
  Created By		:	avenkatr
  Date Created By	:	2000/12/22
  Purpose		:	To Load data into IGF_GR_YTD_DISB table

  Known Limitations,Enhancements or Remarks
  Change History	:
  Who			When		What
  ***************************************************************/
  lv_rowid VARCHAR2(25);
  lv_ytdds_id NUMBER;

BEGIN

    igf_gr_ytd_disb_pkg.insert_row (
       x_rowid                 => lv_rowid,
       x_ytdds_id              => lv_ytdds_id,
       x_origination_id        => p_orig_rec.origination_id,
       x_inst_cross_ref_code   => p_orig_rec.inst_cross_ref_code,
       x_action_code           => p_orig_rec.action_code,
       x_disb_ref_num          => NVL(p_orig_rec.disb_ref_num,0),
       x_disb_accpt_amt        => NVL(p_orig_rec.disb_accpt_amt,0),
       x_db_cr_flag            => p_orig_rec.db_cr_flag,
       x_disb_dt               => p_orig_rec.disb_dt,
       x_pymt_prd_start_dt     => NVL(p_orig_rec.pymt_prd_start_dt,TRUNC(SYSDATE)),
       x_disb_batch_id         => p_orig_rec.disb_batch_id,
       x_mode                  => 'R',
 	     x_ci_cal_type           => g_ci_cal_type,
 	     x_ci_sequence_number    => g_ci_sequence_number,
 	     x_student_name          => p_orig_rec.student_name,
 	     x_current_ssn_txt       => p_orig_rec.current_ssn_txt,
 	     x_student_birth_date    => p_orig_rec.student_birth_date,
 	     x_disb_process_date     => p_orig_rec.disb_process_date,
 	     x_routing_id_txt        => p_orig_rec.routing_id_txt,
 	     x_fin_award_year_num    => p_orig_rec.fin_award_year_num,
 	     x_attend_entity_id_txt  => p_orig_rec.attend_entity_id_txt,
 	     x_disb_seq_num          => p_orig_rec.disb_seq_num,
 	     x_disb_rel_ind          => p_orig_rec.disb_rel_ind,
 	     x_prev_disb_seq_num     => p_orig_rec.prev_disb_seq_num
    ) ;

EXCEPTION

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_gr_ytd_load_data.insert_in_ytdds_table');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END insert_in_ytdds_table;

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
    lp_count              NUMBER          DEFAULT  0;
    lf_count              NUMBER          DEFAULT  0;
    l_batch_id            VARCHAR2(100);

    l_c_message           VARCHAR2(30);  -- Local variable to hold message

BEGIN

   igf_gr_gen.process_pell_ack ( g_ver_num,
                                 'YTD',
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

       CURSOR c_ytd_data
       IS
       SELECT
       record_data
       FROM
       igf_gr_load_file_t
       WHERE
       gldr_id BETWEEN 2 AND (l_last_gldr_id - 1)
       AND
       file_type = 'YTD'
       ORDER BY
       gldr_id;

       ytd_rec_data  c_ytd_data%ROWTYPE;
       lv_ytdor_row  igf_gr_ytd_orig%ROWTYPE;
       lv_ytdds_row  igf_gr_ytd_disb%ROWTYPE;

    BEGIN
    --
    -- Check for the type of data in the Flat File
    --
     FOR ytd_rec_data IN c_ytd_data LOOP

       IF  ( (SUBSTR(ytd_rec_data.record_data, 1, 1)) = 'O' ) THEN
            --
            -- This file has Origination records and has to be uploaded in igf_gr_ytd_orig table
            --
              BEGIN
                --
                --  Split the data in the column of igf_gr_load_file_t into the columns of igf_gr_ytd_orig  file
                --
                split_into_orig_fields (ytd_rec_data.record_data,
                                       lv_ytdor_row);

                --
                -- Insert this new record into the igf_gr_ytd_orig table
                --
                insert_in_ytdor_table (lv_ytdor_row );
                --
                -- Make an entry in the log file indicating Success
                --
                fnd_message.set_name('IGF','IGF_GR_YTDOR_LOAD_PASS');
                fnd_message.set_token('ORIGINATION_ID',lv_ytdor_row.origination_id);
                fnd_file.put_line(fnd_file.log,fnd_message.get());

                lp_count := lp_count + 1;

              EXCEPTION
                WHEN igf_gr_gen.skip_this_record THEN
                fnd_message.set_name('IGF','IGF_GR_YTDOR_LOAD_FAIL');
                fnd_message.set_token('ORIGINATION_ID',SUBSTR( ytd_rec_data.record_data, 2, 23));
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                lf_count := lf_count + 1;

                WHEN igf_gr_gen.no_file_version THEN
                RAISE;

              END;

       ELSIF  ( (SUBSTR(ytd_rec_data.record_data, 1, 1)) = 'D' ) THEN

              --
              -- This file has Disbursement records and has to be updated in the igf_gr_ytd_disb file
              --
               BEGIN
                  --
                  -- Split the data in the column of igf_gr_load_file_t into the columns of igf_gr_ytd_orig  file
                  --
                   split_into_disb_fields (ytd_rec_data.record_data,
                                           lv_ytdds_row) ;

                  --
                  -- Insert this new record into the igf_gr_ytd_orig table
                  --
                  insert_in_ytdds_table (lv_ytdds_row ) ;
                  --
                  -- Make an entry in the log file indicating Success
                  --
                  fnd_message.set_name('IGF','IGF_GR_YTDDS_LOAD_PASS');
                  fnd_message.set_token('ORIGINATION_ID',lv_ytdds_row.origination_id);
                  fnd_file.put_line(fnd_file.log,fnd_message.get());

                  lp_count := lp_count + 1;

               EXCEPTION

                    WHEN igf_gr_gen.skip_this_record THEN
                    --
                    -- Make an entry in the log file indicating Failure
                    --
                    fnd_message.set_name('IGF','IGF_GR_YTDDS_LOAD_FAIL');
                    fnd_message.set_token('ORIGINATION_ID',SUBSTR( ytd_rec_data.record_data, 2, 23));
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
       fnd_message.set_token('NAME','igf_gr_ytd_load_data.load_ack');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;

END load_ack;


--
-- MAIN PROCEDURE
--

PROCEDURE ytd_load_file(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id		 IN	   	NUMBER
  )
AS
  /***************************************************************
    Created By		:	avenkatr
    Date Created By	:	2000/12/19
    Purpose		:	To Load the IGF_GR_YTD_ORIG and IGF_GR_YTD_DISB tables

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
  ***************************************************************/



BEGIN

     retcode := 0;
     igf_aw_gen.set_org_id(p_org_id);

     g_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
     g_ci_sequence_number     :=   TO_NUMBER(SUBSTR(p_awd_yr,11));

     IF g_ci_cal_type IS  NULL OR g_ci_sequence_number IS NULL  THEN
              RAISE param_error;
     END IF;

--
-- Get the Flat File Version and then Proceed
--
    g_ver_num  := igf_aw_gen.get_ver_num(g_ci_cal_type,g_ci_sequence_number,'P');
    g_c_alt_code := igf_gr_gen.get_alt_code(g_ci_cal_type,g_ci_sequence_number);

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

END ytd_load_file;

END igf_gr_ytd_load_data;

/
