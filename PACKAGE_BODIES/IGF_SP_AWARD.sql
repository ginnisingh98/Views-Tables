--------------------------------------------------------
--  DDL for Package Body IGF_SP_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_AWARD" AS
/* $Header: IGFSP03B.pls 120.9 2006/08/11 05:39:56 rajagupt ship $ */

  ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This is a batch process that created both Award and disbursement
  --          for a fund in FA system. Process will also check for the eligibility
  --          and validations before awarding the Sponsor amount to the students.
  --          Awarding money to the students can be done manually apart from awarding
  --          money through a batch process.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr    26-Jun-2006     Bug 5083572 Awards - Assign Sponsorship Awards (Wrong Msg. Logged)
  --                            In create_aw_award procedure, Logging the message 'New Award is created for the
  --                            person with the following details.' only once before actual creation of Disbursement.
  --                            in the loop of fetched FC records.
  --akomurav    06-jun-2006     Bug 5276122 - Made the changes required(TBH Impact) for adding 2 new columns in IGF_DB_AWD_DISB_DTL_ALL table
  --pathipat    18-May-2006     Bug 5194095 - Modified create_award_disb, loop_thru_spnsr_dtl_pvt and recal_dis_gross_amt
  --sapanigr    03-May-2006     Enh#3924836 Precision Issue. Modified create_disb_dtl, create_aw_award, loop_thru_spnsr_dtl_pvt
  --ayedubat    13-OCT-04       FA 149 COD-XML Standards build bug # 3416863
  --                            Changed the TBH calls of the packages: igf_aw_awd_disb_pkg and igf_db_awd_disb_dtl_pkg
  --veramach    July 2004       FA 151 HR Integration(bug #3709292)
  --                            Impact of obsoleting columns from fund manager
  -- bkkumar    04-DEC-2003     Bug 3252382  FA 131 . TBH impact for the igf_aw_awd_disb_all
  --                            Added two columns ATTENDANCE_TYPE_CODE,BASE_ATTENDANCE_TYPE_CODE
  --                            TBH impact of the igf_aw_award Added columns LOCK_AWARD_FLAG,
  --                            APP_TRANS_NUM_TXT
  --vvutukur    20-Jul-2003     Enh#3038511.FICR106 Build. Modified procedure create_award_disb.
  --vchappid    22-Jun-2003     Bug 2881654, Log file format is revamped, Dynamic Person Group feature is introduced,
  --                            Sponsor Code parameter is made optional
  --bkkumar  #2858504  04-jun-2003          Added legacy_record_flag and award_number_txt in the table handler calls for igf_aw_award_pkg.insert_row
  --pathipat    25-Apr-2003     Enh 2831569 - Commercial Receivables build
  --                            Modified create_award_disb() - added call to chk_manage_account()
  --vvutukur    26-feb-2003     Enh#2758823.FA117 Build. Modified the procedure create_disb_dtl.
  --smadathi    30-Jan-2002     Bug 2620302. Function et_person_number ,procedure create_award_disb modified.
  --adhawan  #2613546  28-oct-2002          Added alt_pell_schedule in the table handler calls for igf_aw_award_pkg.insert_row

  -- adhawan #2613546  27-oct-2002          gscc fix for Default
  --smadathi    02-jul-2002                 Bug 2427996. Modified create_award_disb procedure.
  --smadathi    31-Jun-2002                 Bug 2387604. Modified create_aw_award procedure, loop_thru_spnsr_dtl Procedure.
  --smadathi    11-Jun-2002                 Bug 2387572. procedure create_aw_award,loop_thru_spnsr_dtl_pvt modified.
  --smadathi    31-May-2002                 Bug 2387344. procedure create_award_disb,Procedure loop_thru_spnsr_dtl_pvt
  --                                        modified. Function lookup_desc, log_messages added newly.
  --smadathi    17-May-2002                 Bug 2369173. Function recal_dis_gross_amt ,procedure create_aw_award,
  --                                        procedure create_award_disb, Procedure loop_thru_spnsr_dtl_pvt
  --                                        modified.

  --vvutukur   15-apr-2002    Modifications done in create_aw_award procedure for bug#2293676.
  -------------------------------------------------------------------------------------

  -- Global Variable defined for holding the lookup meaning for generating the log file details
  g_v_award_yr         igf_lookups_view.meaning%TYPE;
  g_v_term             igf_lookups_view.meaning%TYPE;
  g_v_person_num_pmt   igf_lookups_view.meaning%TYPE;
  g_v_person_group     igf_lookups_view.meaning%TYPE;
  g_v_spnr_cd          igf_lookups_view.meaning%TYPE;
  g_v_spnr_desc        igf_lookups_view.meaning%TYPE;
  g_v_award_type       igf_lookups_view.meaning%TYPE;
  g_v_test_mode        igf_lookups_view.meaning%TYPE;
  g_v_award_id         igf_lookups_view.meaning%TYPE;
  g_v_disb_fee_class   igf_lookups_view.meaning%TYPE;
  g_v_disb_amount      igf_lookups_view.meaning%TYPE;
  g_v_award_amount     igf_lookups_view.meaning%TYPE;
  g_v_ext_disb_amount  igf_lookups_view.meaning%TYPE;
  g_v_upd_disb_amount  igf_lookups_view.meaning%TYPE;
  g_v_ext_award_amount igf_lookups_view.meaning%TYPE;
  g_v_upd_award_amount igf_lookups_view.meaning%TYPE;
  g_v_person_number    hz_parties.party_number%TYPE;
  g_b_records_found    BOOLEAN := FALSE;
  g_b_award_updated    BOOLEAN := FALSE;
  g_b_msg_logged       BOOLEAN := FALSE;
  g_v_log_text VARCHAR2(32000);
  g_rowid VARCHAR2(25);


  -- function to return meaning for the lookup code and lookup type passed
  -- as parameter.
  FUNCTION lookup_desc( p_type IN VARCHAR2 ,
                        p_code IN VARCHAR2 )
                        RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 31 May 2002
  --
  --Purpose: This function is private to this package body .
  --
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR c_desc( cp_type igs_lookups_view.lookup_type%TYPE ,
                   cp_code igs_lookups_view.lookup_code%TYPE ) IS
    SELECT meaning
    FROM   igf_lookups_view
    WHERE  lookup_type = cp_type
    AND    lookup_code = cp_code;

    l_desc igf_lookups_view.meaning%TYPE ;

  BEGIN
    IF p_code IS NULL THEN
      RETURN NULL;
    ELSE
      OPEN c_desc(cp_type => p_type,
                  cp_code => p_code
                 );
      FETCH c_desc INTO l_desc ;
      CLOSE c_desc ;
    END IF ;
    RETURN l_desc ;
  END lookup_desc;


  FUNCTION get_show_on_bill(p_n_fund_id NUMBER) RETURN VARCHAR2
  IS
  /*----------------------------------------------------------------------------
    Created By : Vinay Chappidi
    Created On : 18-Jun-2003
    Purpose : Generic Function returning the show-on-bill indicator for a Fund ID
    Known limitations, enhancements or remarks :
    Change History :
    Who             When            What
    (reverse chronological order - newest change first)
  ----------------------------------------------------------------------------*/
    CURSOR cur_include_as_plncrd(cp_fund_id igf_aw_fund_mast.fund_id%TYPE)
    IS
    SELECT show_on_bill
    FROM   igf_aw_fund_mast
    WHERE  fund_id = cp_fund_id;
    l_v_show_on_bill igf_aw_fund_mast.show_on_bill%TYPE;
  BEGIN
    OPEN cur_include_as_plncrd(p_n_fund_id);
    FETCH cur_include_as_plncrd INTO l_v_show_on_bill ;
    CLOSE cur_include_as_plncrd;
    RETURN l_v_show_on_bill;
  END get_show_on_bill;



  FUNCTION get_cal_inst_dtls (p_c_cal_type VARCHAR2, p_n_seq_number NUMBER) RETURN VARCHAR2
  IS
  /*----------------------------------------------------------------------------
    Created By : Vinay Chappidi
    Created On : 18-Jun-2003
    Purpose : Generic Function returning the concatenated Calendar Instance details
    Known limitations, enhancements or remarks :
    Change History :
    Who             When            What
    (reverse chronological order - newest change first)
  ----------------------------------------------------------------------------*/

    -- Cursor to select the details for the award year or term calendar passed to the process
    CURSOR c_ca_inst( cp_c_cal_type         igs_ca_inst.cal_type%TYPE,
                      cp_n_sequence_number  igs_ca_inst.sequence_number%TYPE)
    IS
    SELECT alternate_code,
           start_dt,
           end_dt
    FROM   igs_ca_inst
    WHERE  cal_type        = cp_c_cal_type
    AND    sequence_number = cp_n_sequence_number;
    -- cursor variable for c_igs_ca_inst
    l_v_ca_inst  c_ca_inst%ROWTYPE;
  BEGIN
    OPEN c_ca_inst(p_c_cal_type, p_n_seq_number);
    FETCH c_ca_inst INTO l_v_ca_inst;
    IF c_ca_inst%NOTFOUND THEN
      RETURN NULL;
    ELSE
      RETURN (l_v_ca_inst.alternate_code||' '||l_v_ca_inst.start_dt||' - '|| l_v_ca_inst.end_dt);
    END IF;
    CLOSE c_ca_inst;
  END get_cal_inst_dtls;


  FUNCTION get_award_amount(p_n_award_id NUMBER) RETURN NUMBER
  IS
  /*----------------------------------------------------------------------------
    Created By : Vinay Chappidi
    Created On : 18-Jun-2003
    Purpose : Generic function returning the Award Amount
    Known limitations, enhancements or remarks :
    Change History :
    Who             When            What
    (reverse chronological order - newest change first)
    ----------------------------------------------------------------------------*/
    CURSOR c_award_amount(cp_n_award_id igf_aw_award.award_id%TYPE)
    IS
    SELECT accepted_amt
    FROM igf_aw_award
    WHERE award_id = cp_n_award_id;
    l_n_award_amount igf_aw_award.accepted_amt%TYPE;
  BEGIN
    OPEN c_award_amount(p_n_award_id);
    FETCH c_award_amount INTO l_n_award_amount;
    CLOSE c_award_amount;
    RETURN l_n_award_amount;
  END get_award_amount;


  PROCEDURE initialize IS
    /******************************************************************
     Created By : Vinay Chappidi
     Created On : 18-Jun-2003
     Purpose : Procedure for initializing the global variables
     Known limitations, enhancements or remarks :
     Change History :
     Who             When            What
    ******************************************************************/
  BEGIN

    -- Initialize all the constant lables/translatable text for the process
    g_v_award_yr := lookup_desc('IGF_AW_LOOKUPS_MSG', 'AWARD_YEAR');
    g_v_term := lookup_desc('IGF_AW_LOOKUPS_MSG', 'TERM');
    g_v_person_num_pmt := lookup_desc('IGF_AW_LOOKUPS_MSG', 'PERSON_NUMBER');
    g_v_person_group := lookup_desc('IGF_AW_LOOKUPS_MSG', 'PERSON_GROUP');
    g_v_spnr_cd := lookup_desc('IGF_AW_LOOKUPS_MSG', 'SPONSOR_CD');
    g_v_spnr_desc := lookup_desc('IGF_AW_LOOKUPS_MSG', 'SPONSOR_DESC');
    g_v_award_type := lookup_desc('IGF_AW_LOOKUPS_MSG', 'AWARD_TYPE');
    g_v_test_mode := lookup_desc('IGF_AW_LOOKUPS_MSG', 'TEST_MODE');
    g_v_award_id := lookup_desc('IGF_AW_LOOKUPS_MSG', 'AWARD_ID');
    g_v_disb_fee_class := lookup_desc('IGF_AW_LOOKUPS_MSG', 'DISB_FEE_CLASS');
    g_v_disb_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'DISB_AMOUNT');
    g_v_award_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'AWARD_AMT');
    g_v_ext_disb_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'EXT_DISB_AMT');
    g_v_upd_disb_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'UPD_DISB_AMT');
    g_v_ext_award_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'EXT_AWARD_AMT');
    g_v_upd_award_amount := lookup_desc('IGF_AW_LOOKUPS_MSG', 'UPD_AWARD_AMT');
  END initialize;


  -- Routine to log parameters.
  PROCEDURE log_parameters ( p_v_parm_type IN VARCHAR2, p_v_parm_code IN VARCHAR2 )
  AS
  /*----------------------------------------------------------------------------
    Created By : Vinay Chappidi
    Created On : 18-Jun-2003
    Purpose : To log input parameters to the process
    Known limitations, enhancements or remarks :
    Change History :
    Who             When            What
    (reverse chronological order - newest change first)
  ----------------------------------------------------------------------------*/
  BEGIN
    fnd_file.put_line(fnd_file.log, p_v_parm_type || ' : ' || p_v_parm_code );
  END log_parameters;


  FUNCTION get_person_number (p_person_id igs_pe_person.person_id%TYPE)
  RETURN VARCHAR2
  AS
   ------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this function return person number
   --
   --          parameter description:
   --          p_person_id       - Person ID
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   --smadathi    30-Jan-2002     Bug 2620302. Cursor c_person_number select modified
   --                            to fetch the records from view igs_pe_person_base_v
   --                            instead of igs_pe_person. This fix is done to remove
   --                            Non-mergablity due to igs_pe_person view
  -------------------------------------------------------------------------------------
    -- cursor to get person number
    CURSOR c_person_number (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
    SELECT person_number
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_person_id;

    l_person_number  igs_pe_person.person_number%TYPE;
  BEGIN
    -- get the person number
    OPEN c_person_number (p_person_id);
    FETCH c_person_number INTO l_person_number;
    CLOSE c_person_number;
    RETURN l_person_number;
  END get_person_number;

  FUNCTION check_eligibility ( p_person_id          igf_sp_stdnt_rel.person_id%TYPE,
                               p_min_att_type       igf_sp_stdnt_rel.min_attendance_type%TYPE,
                               p_min_credit_points  igf_sp_stdnt_rel.min_credit_points%TYPE,
                               p_ld_cal_type        igf_sp_stdnt_rel.ld_cal_type%TYPE,
                               p_ld_sequence_number igf_sp_stdnt_rel.ld_sequence_number%TYPE)
  RETURN BOOLEAN
  AS
   ------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this procedure checks the eligibility of the student
   --
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
  --smadathi    17-May-2002     Bug 2369173. Incorpoarted condition to return true when
  --                            min. credit points and min. attd. tpe has not been provided
  --                            in the sponsor student relation. Moreover, the existing
  --                            comparison operators used for min.credit points and
  --                            Min. attendance type is changed.
  -------------------------------------------------------------------------------------
    l_min_credit_points    igf_sp_stdnt_rel.min_credit_points%TYPE;
    l_min_attendance_type  igf_sp_stdnt_rel.min_attendance_type%TYPE;
    l_fte                  VARCHAR2 (10); --to be verified

  BEGIN

    -- IF Min attendance type and min. credit points are not provided ,
    -- eligibility check should be skipped.
    IF p_min_att_type IS NULL AND p_min_credit_points IS NULL THEN
      RETURN TRUE;
    END IF;

    igs_en_prc_load.enrp_get_inst_latt (p_person_id,
                                        p_ld_cal_type,
                                        p_ld_sequence_number,
                                        l_min_attendance_type,
                                        l_min_credit_points,
                                        l_fte);

    IF (l_min_attendance_type <> p_min_att_type) OR
       (l_min_credit_points < p_min_credit_points) THEN
       RETURN FALSE;
    END IF;
    RETURN TRUE;
  END check_eligibility;

  PROCEDURE create_disb_dtl(p_award_id   igf_aw_award_all.award_id%TYPE,
                            p_disb_num   igf_aw_awd_disb_all.disb_num%TYPE)
  AS
  -------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this procedure checks the eligibility of the student
   --
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
  -- sapanigr   03-May-2006    Enh#3924836 Precision Issue. Amount values being inserted into igf_db_awd_disb_dtl
  --                           are now rounded off to currency precision
   --vvutukur   26-Feb-2003    Enh#2758823.FA117 Build. Assigned value 'D' to disb_dtl_rec.disb_activity, instead of NULL.
  -------------------------------------------------------------------------------------

    CURSOR cur_chk_adj( cp_award_id   igf_aw_award_all.award_id%TYPE,
                        cp_disb_num   igf_aw_awd_disb_all.disb_num%TYPE)
    IS
    SELECT NVL(disb_seq_num,0) disb_seq_num
    FROM igf_db_awd_disb_dtl
    WHERE award_id = cp_award_id AND
          disb_num = cp_disb_num;
    chk_adj_rec cur_chk_adj%ROWTYPE;

    CURSOR cur_get_adisb( cp_award_id   igf_aw_award_all.award_id%TYPE,
                          cp_disb_num   igf_aw_awd_disb_all.disb_num%TYPE)
    IS
    SELECT *
    FROM igf_aw_awd_disb
    WHERE award_id = cp_award_id AND
          disb_num = cp_disb_num;
    get_adisb_rec   cur_get_adisb%ROWTYPE;

    disb_dtl_rec    igf_db_awd_disb_dtl%ROWTYPE;
  BEGIN
    -- Check if any adjustment record is present for this award
    OPEN cur_chk_adj (p_award_id, p_disb_num);
    FETCH cur_chk_adj INTO chk_adj_rec;
    IF cur_chk_adj%FOUND THEN
      -- No need to create adjustement, as it is already present
      CLOSE cur_chk_adj;
    ELSIF cur_chk_adj%NOTFOUND THEN
      CLOSE cur_chk_adj;

      OPEN cur_get_adisb(p_award_id, p_disb_num);
      FETCH cur_get_adisb INTO get_adisb_rec;
      CLOSE cur_get_adisb;

      -- Create transaction record in disbursement detail table
      disb_dtl_rec.award_id           :=  p_award_id;
      disb_dtl_rec.disb_num           :=  p_disb_num;
      disb_dtl_rec.disb_seq_num       :=  1;
      disb_dtl_rec.disb_gross_amt     :=  get_adisb_rec.disb_gross_amt;
      disb_dtl_rec.fee_1              :=  get_adisb_rec.fee_1;
      disb_dtl_rec.fee_2              :=  get_adisb_rec.fee_1;
      disb_dtl_rec.disb_net_amt       :=  get_adisb_rec.disb_net_amt;
      disb_dtl_rec.disb_adj_amt       :=  0;
      disb_dtl_rec.disb_date          :=  get_adisb_rec.disb_date;
      disb_dtl_rec.fee_paid_1         :=  get_adisb_rec.fee_paid_1;
      disb_dtl_rec.fee_paid_2         :=  get_adisb_rec.fee_paid_1;
      disb_dtl_rec.sf_status          :=  'R';  -- Ready to Send
      disb_dtl_rec.sf_status_date     :=  TRUNC(SYSDATE);
      disb_dtl_rec.disb_activity      :=  'D';
      disb_dtl_rec.disb_status        :=  NULL;
      disb_dtl_rec.disb_status_date   :=  NULL;
      g_rowid := NULL;

      -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
      igf_db_awd_disb_dtl_pkg.insert_row( x_rowid              =>   g_rowid,
                                          x_award_id           =>   disb_dtl_rec.award_id        ,
                                          x_disb_num           =>   disb_dtl_rec.disb_num        ,
                                          x_disb_seq_num       =>   disb_dtl_rec.disb_seq_num    ,
                                          x_disb_gross_amt     =>   igs_fi_gen_gl.get_formatted_amount(disb_dtl_rec.disb_gross_amt)  ,
                                          x_fee_1              =>   disb_dtl_rec.fee_1           ,
                                          x_fee_2              =>   disb_dtl_rec.fee_2           ,
                                          x_disb_net_amt       =>   igs_fi_gen_gl.get_formatted_amount(disb_dtl_rec.disb_net_amt)    ,
                                          x_disb_adj_amt       =>   igs_fi_gen_gl.get_formatted_amount(disb_dtl_rec.disb_adj_amt)    ,
                                          x_disb_date          =>   disb_dtl_rec.disb_date       ,
                                          x_fee_paid_1         =>   disb_dtl_rec.fee_paid_1      ,
                                          x_fee_paid_2         =>   disb_dtl_rec.fee_paid_2      ,
                                          x_disb_activity      =>   disb_dtl_rec.disb_activity   ,
                                          x_disb_batch_id      =>   NULL,
                                          x_disb_ack_date      =>   NULL,
                                          x_booking_batch_id   =>   NULL,
                                          x_booked_date        =>   NULL,
                                          x_disb_status        =>   NULL,
                                          x_disb_status_date   =>   NULL,
                                          x_sf_status          =>   disb_dtl_rec.sf_status       ,
                                          x_sf_status_date     =>   disb_dtl_rec.sf_status_date  ,
                                          x_sf_invoice_num     =>   disb_dtl_rec.sf_invoice_num  ,
                                          x_spnsr_credit_id    =>   disb_dtl_rec.spnsr_credit_id ,
                                          x_spnsr_charge_id    =>   disb_dtl_rec.spnsr_charge_id ,
                                          x_sf_credit_id       =>   disb_dtl_rec.sf_credit_id    ,
                                          x_error_desc         =>   disb_dtl_rec.error_desc      ,
                                          x_mode               =>   'R',
                                          x_notification_date  =>   disb_dtl_rec.notification_date,
                                          x_interest_rebate_amt =>  NULL,
					  x_ld_cal_type         =>  get_adisb_rec.ld_cal_type,
 	                                  x_ld_sequence_number   => get_adisb_rec.ld_sequence_number
                                         );
    END IF;
  END create_disb_dtl;

  FUNCTION recal_dis_gross_amt (p_spnsr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE,
                                p_chk_elig VARCHAR2,
                                p_fee_cls_id     igf_sp_std_fc.fee_cls_id%TYPE
                                )
  RETURN NUMBER
  AS
  ------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this procedure is to write into log file
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   --pathipat    18-May-2006     Bug 5194095 - Added code related to calculations of
   --                            Eligible/New Sponsor amounts.
   --vchappid    22-Jun-2003     Bug 2881654, Log file format is revamped
   --smadathi    17-May-2002     Bug 2369173. Division by 100 was incorporated where
   --                            pays only percent was involved in calculation.
  -------------------------------------------------------------------------------------
    --  cursor to find the tot_spnsr_amt
    CURSOR c_stdnt_rel (cp_spnsr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE)
    IS
    SELECT spstd.*, fmast.fund_code
    FROM   igf_sp_stdnt_rel_all spstd,
           igf_aw_fund_mast_all fmast
    WHERE  spstd.spnsr_stdnt_id = cp_spnsr_stdnt_id
    AND    fmast.fund_id = spstd.fund_id;
    rec_stdnt_rel c_stdnt_rel%ROWTYPE;

    --  cursor to get the charge at fee class
    CURSOR c_std_fc (cp_spnsr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE,
                     cp_fee_cls_id     igf_sp_std_fc.fee_cls_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_std_fc
    WHERE  spnsr_stdnt_id = cp_spnsr_stdnt_id
    AND    fee_cls_id = NVL(cp_fee_cls_id,fee_cls_id);

    --  cursor to get the charge at program level
    CURSOR c_std_prg (cp_fee_cls_id igf_sp_std_prg.fee_cls_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_std_prg
    WHERE  fee_cls_id = cp_fee_cls_id;

    -- cursor to get the charge at unit level
    CURSOR c_std_unit (cp_fee_cls_prg_id igf_sp_std_unit.fee_cls_prg_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_std_unit
    WHERE  fee_cls_prg_id = cp_fee_cls_prg_id;
    rec_std_unit c_std_unit%ROWTYPE;

    --  cursor to check forprg attempt
    CURSOR c_prg_attempt (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                           cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                           cp_course_version_number igs_en_stdnt_ps_att.version_number%TYPE,
                           cp_v_load_cal_type   igs_ca_inst_all.cal_type%TYPE,
                           cp_n_load_seq_num    igs_ca_inst_all.sequence_number%TYPE) IS
    SELECT 'x'
    FROM   igs_en_stdnt_ps_att psatt
    WHERE  person_id = cp_person_id
    AND    course_cd = cp_course_cd
    AND    version_number = cp_course_version_number
    AND    course_attempt_status IN ('ENROLLED','INACTIVE','DISCONTIN')
    AND    EXISTS ( SELECT 1
                    FROM igs_en_su_attempt_all sua
                    WHERE sua.person_id = psatt.person_id
                    AND  sua.course_cd = psatt.course_cd
                    AND  sua.unit_attempt_status IN ('ENROLLED','COMPLETED')
                    AND  (cal_type, ci_sequence_number) IN ( SELECT teach_cal_type, teach_ci_sequence_number
                                                             FROM  igs_ca_load_to_teach_v
                                                             WHERE load_cal_type = cp_v_load_cal_type
                                                             AND load_ci_sequence_number = cp_n_load_seq_num)
                  );

    l_prg_attempt VARCHAR2(1);

    l_tot_spnsr_amount igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;

    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_status           BOOLEAN;

    l_v_fee_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_n_fee_ci_seq_num        igs_ca_inst_all.sequence_number%TYPE;
    l_v_message_name          fnd_new_messages.message_name%TYPE;
    l_n_eligible_spns_amount  igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;
    l_n_computed_spns_amount  igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;
    l_n_new_spns_amount       igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;
    l_n_spns_amount           igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;
    l_n_final_spns_amount     igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;

  BEGIN
    -- get the tot_spsnr_amt
    OPEN c_stdnt_rel (p_spnsr_stdnt_id);
    FETCH c_stdnt_rel INTO rec_stdnt_rel;
    CLOSE c_stdnt_rel;

    -- Fetch the Fee Calendar mapped to the Load Calendar
    IF NOT(igs_fi_gen_001.finp_get_lfci_reln(p_cal_type        => rec_stdnt_rel.ld_cal_type,
                                      p_ci_sequence_number     => rec_stdnt_rel.ld_sequence_number,
                                      p_cal_category           => 'LOAD',
                                      p_ret_cal_type           => l_v_fee_cal_type,
                                      p_ret_ci_sequence_number => l_n_fee_ci_seq_num,
                                      p_message_name           => l_v_message_name)) THEN
        -- If there was any error in retrieving the calendar info, return 0
        IF l_v_message_name IS NOT NULL THEN
            fnd_message.set_name('IGS',l_v_message_name);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            RETURN 0;
        END IF;
    END IF;

    IF rec_stdnt_rel.tot_spnsr_amount IS NOT NULL THEN
        -- If param p_chk_elig holds N (Planned), then return the Total Sponsor Amount
        IF (p_chk_elig = 'N') THEN
           RETURN rec_stdnt_rel.tot_spnsr_amount;
        ELSE
           -- If p_chk_elig is 'Y' (Actual), then the New Sponsor amount will be the lesser of
           -- Eligible Sponsor Amount and the Total Sponsor Amount.

           -- Fetch the sponsor amounts
           igf_sp_gen_001.get_sponsor_amts(p_n_person_id          => rec_stdnt_rel.person_id,
                                           p_v_fee_cal_type       => l_v_fee_cal_type,
                                           p_n_fee_seq_number     => l_n_fee_ci_seq_num,
                                           p_v_fund_code          => rec_stdnt_rel.fund_code,
                                           p_v_ld_cal_type        => rec_stdnt_rel.ld_cal_type,
                                           p_n_ld_seq_number      => rec_stdnt_rel.ld_sequence_number,
                                           p_v_fee_class          => NULL,
                                           p_v_course_cd          => NULL,
                                           p_v_unit_cd            => NULL,
                                           p_n_unit_ver_num       => NULL,
                                           x_eligible_amount      => l_n_eligible_spns_amount,
                                           x_new_spnsp_amount     => l_n_computed_spns_amount);
            -- Determine New Sponsor amount as lesser of Eligible and Computed sponsor amount
            IF (l_n_eligible_spns_amount = l_n_computed_spns_amount) THEN
               l_n_new_spns_amount := l_n_computed_spns_amount;
            ELSIF (l_n_eligible_spns_amount < l_n_computed_spns_amount) THEN
               l_n_new_spns_amount := l_n_eligible_spns_amount;
            ELSE
               l_n_new_spns_amount := l_n_computed_spns_amount;
            END IF;

            -- Return the lesser of New Sponsor Amount and Total Sponsor Amount
            IF (rec_stdnt_rel.tot_spnsr_amount = l_n_new_spns_amount) THEN
               RETURN l_n_new_spns_amount;
            ELSIF (rec_stdnt_rel.tot_spnsr_amount < l_n_new_spns_amount) THEN
               RETURN rec_stdnt_rel.tot_spnsr_amount;
            ELSE
               RETURN l_n_new_spns_amount;
            END IF;
        END IF;
    END IF;

    -- sum up the amount at the fee class
   FOR rec_std_fc IN c_std_fc (p_spnsr_stdnt_id, p_fee_cls_id)
   LOOP
     -- check for the presence of fee percent and max amount else look at the program level
     IF rec_std_fc.fee_percent IS NULL AND rec_std_fc.max_amount IS NULL THEN
       --  look at prg level
       FOR rec_std_prg IN c_std_prg (rec_std_fc.fee_cls_id)
       LOOP
         -- check for program status
         IF p_chk_elig = 'Y' THEN
           OPEN c_prg_attempt (rec_stdnt_rel.person_id, rec_std_prg.course_cd,rec_std_prg.version_number,
                               rec_stdnt_rel.ld_cal_type,rec_stdnt_rel.ld_sequence_number);
           FETCH c_prg_attempt INTO l_prg_attempt;
             IF c_prg_attempt%NOTFOUND THEN
               EXIT;
             END IF;
             CLOSE c_prg_attempt;
         END IF;

         IF rec_std_prg.fee_percent IS NULL AND rec_std_prg.max_amount IS NULL THEN
           -- get it from unit level
           OPEN c_std_unit (rec_std_prg.fee_cls_prg_id);
           LOOP
           FETCH c_std_unit INTO rec_std_unit;
           EXIT WHEN c_std_unit%NOTFOUND ;
             IF p_chk_elig = 'Y' THEN
               IF igf_sp_gen_001.check_unit_attempt(p_person_id                => rec_stdnt_rel.person_id,
                                                    p_ld_cal_type              => rec_stdnt_rel.ld_cal_type,
                                                    p_ld_ci_sequence_number    => rec_stdnt_rel.ld_sequence_number,
                                                    p_course_cd                => rec_std_prg.course_cd,
                                                    p_course_version_number    => rec_std_prg.version_number,
                                                    p_unit_cd                  => rec_std_unit.unit_cd,
                                                    p_unit_version_number      => rec_std_unit.version_number,
                                                    p_msg_count                => l_msg_count,
                                                    p_msg_data                 => l_msg_data) THEN
                  -- If p_chk_elig is Y (Actual), then the Eligible Amount needs to be taken into account
                  -- before awarding.
                  -- Fetch the sponsor amounts
                  igf_sp_gen_001.get_sponsor_amts(p_n_person_id   => rec_stdnt_rel.person_id,
                                           p_v_fee_cal_type       => l_v_fee_cal_type,
                                           p_n_fee_seq_number     => l_n_fee_ci_seq_num,
                                           p_v_fund_code          => rec_stdnt_rel.fund_code,
                                           p_v_ld_cal_type        => rec_stdnt_rel.ld_cal_type,
                                           p_n_ld_seq_number      => rec_stdnt_rel.ld_sequence_number,
                                           p_v_fee_class          => rec_std_fc.fee_class,
                                           p_v_course_cd          => NULL,
                                           p_v_unit_cd            => rec_std_unit.unit_cd,
                                           p_n_unit_ver_num       => rec_std_unit.version_number,
                                           x_eligible_amount      => l_n_eligible_spns_amount,
                                           x_new_spnsp_amount     => l_n_computed_spns_amount);
                   -- Determine New Sponsor amount as lesser of Eligible and Computed sponsor amount
                   IF (l_n_eligible_spns_amount = l_n_computed_spns_amount) THEN
                       l_n_new_spns_amount := l_n_computed_spns_amount;
                   ELSIF (l_n_eligible_spns_amount < l_n_computed_spns_amount) THEN
                       l_n_new_spns_amount := l_n_eligible_spns_amount;
                   ELSE
                       l_n_new_spns_amount := l_n_computed_spns_amount;
                   END IF;

                   -- Determine the lesser of New Sponsor Amount and Max Amount
                   -- The lesser of the two will be added to the Total Sponsor Amount
                   IF (rec_std_unit.max_amount = l_n_new_spns_amount) THEN
                      l_n_spns_amount := l_n_new_spns_amount;
                   ELSIF (rec_std_unit.max_amount < l_n_new_spns_amount) THEN
                      l_n_spns_amount := rec_std_unit.max_amount;
                   ELSE
                      l_n_spns_amount := l_n_new_spns_amount;
                   END IF;
                   -- Add the calculated Sponsor Amount to the Total Sponsor Amount
                   l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_spns_amount,0);
               END IF;
             ELSE
               -- Since p_chk_elig is N (Planned) - there is no need to consider Eligible Amounts.
               -- The Max Amount can directly be used.
               l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(rec_std_unit.max_amount,0);
             END IF;
           END LOOP;
           CLOSE c_std_unit;

         ELSIF  rec_std_prg.fee_percent IS NULL AND rec_std_prg.max_amount IS NOT NULL THEN
             IF (p_chk_elig = 'N') THEN
                 l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + rec_std_prg.max_amount;
             ELSE
                 -- Fetch the Sponsor Amounts
                 igf_sp_gen_001.get_sponsor_amts(p_n_person_id      => rec_stdnt_rel.person_id,
                                               p_v_fee_cal_type     => l_v_fee_cal_type,
                                               p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                               p_v_fund_code        => rec_stdnt_rel.fund_code,
                                               p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                               p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                               p_v_fee_class        => rec_std_fc.fee_class,
                                               p_v_course_cd        => rec_std_prg.course_cd,
                                               p_v_unit_cd          => NULL,
                                               p_n_unit_ver_num     => NULL,
                                               x_eligible_amount    => l_n_eligible_spns_amount,
                                               x_new_spnsp_amount   => l_n_computed_spns_amount);
                   -- Determine New Sponsor amount as lesser of Eligible and Computed sponsor amount
                   IF (l_n_eligible_spns_amount = l_n_computed_spns_amount) THEN
                       l_n_new_spns_amount := l_n_computed_spns_amount;
                   ELSIF (l_n_eligible_spns_amount < l_n_computed_spns_amount) THEN
                       l_n_new_spns_amount := l_n_eligible_spns_amount;
                   ELSE
                       l_n_new_spns_amount := l_n_computed_spns_amount;
                   END IF;

                   -- Determine the lesser of New Sponsor Amount and Max Amount
                   -- The lesser of the two will be added to the Total Sponsor Amount
                   IF (rec_std_prg.max_amount = l_n_new_spns_amount) THEN
                      l_n_spns_amount := l_n_new_spns_amount;
                   ELSIF (rec_std_prg.max_amount < l_n_new_spns_amount) THEN
                      l_n_spns_amount := rec_std_prg.max_amount;
                   ELSE
                      l_n_spns_amount := l_n_new_spns_amount;
                   END IF;

                   -- Add the calculated Sponsor Amount to the Total Sponsor Amount
                   l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_spns_amount,0);
             END IF;
         ELSIF  rec_std_prg.fee_percent IS NOT NULL AND rec_std_prg.max_amount IS NULL THEN
               -- Fetch the Sponsor Amounts
               igf_sp_gen_001.get_sponsor_amts(p_n_person_id        => rec_stdnt_rel.person_id,
                                               p_v_fee_cal_type     => l_v_fee_cal_type,
                                               p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                               p_v_fund_code        => rec_stdnt_rel.fund_code,
                                               p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                               p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                               p_v_fee_class        => rec_std_fc.fee_class,
                                               p_v_course_cd        => rec_std_prg.course_cd,
                                               p_v_unit_cd          => NULL,
                                               p_n_unit_ver_num     => NULL,
                                               x_eligible_amount    => l_n_eligible_spns_amount,
                                               x_new_spnsp_amount   => l_n_computed_spns_amount);

               l_n_new_spns_amount := (rec_std_prg.fee_percent/100) * l_n_computed_spns_amount;

               -- Consider the lower of Eligible Amount and % of New Amount to add
               -- to the Total Sponsor Amount.
               IF (l_n_new_spns_amount = l_n_eligible_spns_amount) THEN
                   l_n_spns_amount := l_n_eligible_spns_amount;
               ELSIF (l_n_new_spns_amount < l_n_eligible_spns_amount) THEN
                   l_n_spns_amount := l_n_new_spns_amount;
               ELSE
                   l_n_spns_amount := l_n_eligible_spns_amount;
               END IF;

               -- Add the calculated Sponsor Amount to the Total Sponsor Amount
               l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_spns_amount,0);

         ELSIF  rec_std_prg.fee_percent IS NOT NULL AND rec_std_prg.max_amount IS NOT NULL THEN
               -- Fetch the Sponsor Amounts
               igf_sp_gen_001.get_sponsor_amts(p_n_person_id        => rec_stdnt_rel.person_id,
                                               p_v_fee_cal_type     => l_v_fee_cal_type,
                                               p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                               p_v_fund_code        => rec_stdnt_rel.fund_code,
                                               p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                               p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                               p_v_fee_class        => rec_std_fc.fee_class,
                                               p_v_course_cd        => rec_std_prg.course_cd,
                                               p_v_unit_cd          => NULL,
                                               p_n_unit_ver_num     => NULL,
                                               x_eligible_amount    => l_n_eligible_spns_amount,
                                               x_new_spnsp_amount   => l_n_computed_spns_amount);

               l_n_new_spns_amount := (rec_std_prg.fee_percent/100) * l_n_computed_spns_amount;

               -- Determine the lesser of New Sponsor Amount and Max Amount
               -- The lesser of the two will be added to the Total Sponsor Amount
               IF (rec_std_prg.max_amount = l_n_new_spns_amount) THEN
                  l_n_spns_amount := l_n_new_spns_amount;
               ELSIF (rec_std_prg.max_amount < l_n_new_spns_amount) THEN
                  l_n_spns_amount := rec_std_unit.max_amount;
               ELSE
                  l_n_spns_amount := l_n_new_spns_amount;
               END IF;

               -- Consider the lower of Eligible Amount and % of Computed Amount to add
               -- to the Total Sponsor Amount.
               IF (l_n_spns_amount = l_n_eligible_spns_amount) THEN
                   l_n_final_spns_amount := l_n_eligible_spns_amount;
               ELSIF (l_n_spns_amount < l_n_eligible_spns_amount) THEN
                   l_n_final_spns_amount := l_n_spns_amount;
               ELSE
                   l_n_final_spns_amount := l_n_eligible_spns_amount;
               END IF;

               -- Add the calculated Sponsor Amount to the Total Sponsor Amount
               l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_final_spns_amount,0);

         END IF;

       END LOOP; -- for the prg level
     ELSIF  rec_std_fc.fee_percent IS NULL AND rec_std_fc.max_amount IS NOT NULL THEN
        IF (p_chk_elig = 'N') THEN
           l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + rec_std_fc.max_amount;
        ELSE
           -- Fetch the Sponsor Amounts
           igf_sp_gen_001.get_sponsor_amts(p_n_person_id      => rec_stdnt_rel.person_id,
                                         p_v_fee_cal_type     => l_v_fee_cal_type,
                                         p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                         p_v_fund_code        => rec_stdnt_rel.fund_code,
                                         p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                         p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                         p_v_fee_class        => rec_std_fc.fee_class,
                                         p_v_course_cd        => NULL,
                                         p_v_unit_cd          => NULL,
                                         p_n_unit_ver_num     => NULL,
                                         x_eligible_amount    => l_n_eligible_spns_amount,
                                         x_new_spnsp_amount   => l_n_computed_spns_amount);
             -- Determine New Sponsor amount as lesser of Eligible and Computed sponsor amount
             IF (l_n_eligible_spns_amount = l_n_computed_spns_amount) THEN
                 l_n_new_spns_amount := l_n_computed_spns_amount;
             ELSIF (l_n_eligible_spns_amount < l_n_computed_spns_amount) THEN
                 l_n_new_spns_amount := l_n_eligible_spns_amount;
             ELSE
                 l_n_new_spns_amount := l_n_computed_spns_amount;
             END IF;

             -- Determine the lesser of New Sponsor Amount and Max Amount
             -- The lesser of the two will be added to the Total Sponsor Amount
             IF (rec_std_fc.max_amount = l_n_new_spns_amount) THEN
                l_n_spns_amount := l_n_new_spns_amount;
             ELSIF (rec_std_fc.max_amount < l_n_new_spns_amount) THEN
                l_n_spns_amount := rec_std_fc.max_amount;
             ELSE
                l_n_spns_amount := l_n_new_spns_amount;
             END IF;

             -- Add the calculated Sponsor Amount to the Total Sponsor Amount
             l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_spns_amount,0);

        END IF;
     ELSIF  rec_std_fc.fee_percent IS NOT NULL AND rec_std_fc.max_amount IS NULL THEN
           -- Fetch the Sponsor Amounts
           igf_sp_gen_001.get_sponsor_amts(p_n_person_id      => rec_stdnt_rel.person_id,
                                         p_v_fee_cal_type     => l_v_fee_cal_type,
                                         p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                         p_v_fund_code        => rec_stdnt_rel.fund_code,
                                         p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                         p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                         p_v_fee_class        => rec_std_fc.fee_class,
                                         p_v_course_cd        => NULL,
                                         p_v_unit_cd          => NULL,
                                         p_n_unit_ver_num     => NULL,
                                         x_eligible_amount    => l_n_eligible_spns_amount,
                                         x_new_spnsp_amount   => l_n_computed_spns_amount);

               l_n_new_spns_amount := (rec_std_fc.fee_percent/100) * l_n_computed_spns_amount;

               -- Consider the lower of Eligible Amount and % of New Amount to add
               -- to the Total Sponsor Amount.
               IF (l_n_new_spns_amount = l_n_eligible_spns_amount) THEN
                   l_n_spns_amount := l_n_eligible_spns_amount;
               ELSIF (l_n_new_spns_amount < l_n_eligible_spns_amount) THEN
                   l_n_spns_amount := l_n_new_spns_amount;
               ELSE
                   l_n_spns_amount := l_n_eligible_spns_amount;
               END IF;

               -- Add the calculated Sponsor Amount to the Total Sponsor Amount
               l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_spns_amount,0);

     ELSIF  rec_std_fc.fee_percent IS NOT NULL AND rec_std_fc.max_amount IS NOT NULL THEN
           -- Fetch the Sponsor Amounts
           igf_sp_gen_001.get_sponsor_amts(p_n_person_id      => rec_stdnt_rel.person_id,
                                         p_v_fee_cal_type     => l_v_fee_cal_type,
                                         p_n_fee_seq_number   => l_n_fee_ci_seq_num,
                                         p_v_fund_code        => rec_stdnt_rel.fund_code,
                                         p_v_ld_cal_type      => rec_stdnt_rel.ld_cal_type,
                                         p_n_ld_seq_number    => rec_stdnt_rel.ld_sequence_number,
                                         p_v_fee_class        => rec_std_fc.fee_class,
                                         p_v_course_cd        => NULL,
                                         p_v_unit_cd          => NULL,
                                         p_n_unit_ver_num     => NULL,
                                         x_eligible_amount    => l_n_eligible_spns_amount,
                                         x_new_spnsp_amount   => l_n_computed_spns_amount);

               l_n_new_spns_amount := (rec_std_fc.fee_percent/100) * l_n_computed_spns_amount;

               -- Determine the lesser of New Sponsor Amount and Max Amount
               -- The lesser of the two will be added to the Total Sponsor Amount
               IF (rec_std_fc.max_amount = l_n_new_spns_amount) THEN
                  l_n_spns_amount := l_n_new_spns_amount;
               ELSIF (rec_std_fc.max_amount < l_n_new_spns_amount) THEN
                  l_n_spns_amount := rec_std_fc.max_amount;
               ELSE
                  l_n_spns_amount := l_n_new_spns_amount;
               END IF;

               -- Consider the lower of Eligible Amount and Calculated Amount to add
               -- to the Total Sponsor Amount.
               IF (l_n_spns_amount = l_n_eligible_spns_amount) THEN
                   l_n_final_spns_amount := l_n_eligible_spns_amount;
               ELSIF (l_n_spns_amount < l_n_eligible_spns_amount) THEN
                   l_n_final_spns_amount := l_n_spns_amount;
               ELSE
                   l_n_final_spns_amount := l_n_eligible_spns_amount;
               END IF;

               -- Add the calculated Sponsor Amount to the Total Sponsor Amount
               l_tot_spnsr_amount := NVL(l_tot_spnsr_amount,0) + NVL(l_n_final_spns_amount,0);
     END IF;
   END LOOP;
   RETURN NVL(l_tot_spnsr_amount,0);

  EXCEPTION
    WHEN OTHERS THEN
      --  close all opened cursor
      IF c_stdnt_rel%ISOPEN THEN
         CLOSE c_stdnt_rel;
      END IF;
      IF c_std_unit%ISOPEN THEN
         CLOSE c_std_unit;
      END IF;
      RAISE;
  END recal_dis_gross_amt;

  FUNCTION get_disb_num (p_award_id  igf_aw_award.award_id%TYPE)
  RETURN NUMBER
  AS
  ------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this procedure is returns the disb num
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
  -------------------------------------------------------------------------------------
  -- cursor to get max of disb num
  CURSOR c_disb_num (cp_award_id igf_aw_award.award_id%TYPE)
  IS
  SELECT NVL(max(disb_num),0) + 1
  FROM   igf_aw_awd_disb
  WHERE  award_id = cp_award_id;
  l_disb_num igf_aw_awd_disb.disb_num%TYPE;
  BEGIN
    OPEN c_disb_num (p_award_id);
    FETCH c_disb_num INTO l_disb_num;
    CLOSE c_disb_num;
    RETURN l_disb_num;
  END get_disb_num;

  PROCEDURE create_aw_award (p_fund_id             igf_sp_stdnt_rel.fund_id%TYPE,
                             p_base_id             igf_sp_stdnt_rel.base_id%TYPE,
                             p_ld_cal_type         igf_sp_stdnt_rel.ld_cal_type%TYPE,
                             p_ld_sequence_number  igf_sp_stdnt_rel.ld_sequence_number%TYPE,
                             p_fee_type            igf_aw_fund_mast.fee_type%TYPE,
                             p_spnsr_stdnt_id      igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE,
                             p_award_type          igf_aw_awd_disb.trans_type%TYPE,
                             p_person_id           igs_pe_person.person_id%TYPE,
                             p_chk_elig            VARCHAR2)
  AS
  ------------------------------------------------------------------------------------
   --Created by  : smanglm ( Oracle IDC)
   --Date created: 2002/01/11
   --
   --Purpose:  Created as part of the build for DLD Sponsorship
   --          this procedure is to create award and details record
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   --sapanigr    26-Jun-2006     Bug 5083572 Awards - Assign Sponsorship Awards (Wrong Msg. Logged)
   --                            Logging the message 'New Award is created for the person with the following details.'
   --                            only once before actual creation of Disbursement in the loop of fetched FC records.
   --pathipat    18-May-2006     Bug 5194095 - Added call to recal_dis_gross_amt when Total Sponsor Amount has been
   --                            specified at Student Relation level.
   --sapanigr    03-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igf_aw_awd_disb, igf_aw_award
   --                            are now rounded off to currency precision
   --vchappid    22-Jun-2003    Bug 2881654, Log file format is revamped
   --smadathi    31-Jun-2002    Bug 2387604. New Message IGF_SP_NO_DISB_DTL  has been registered
   --                           for logging. This message is logged for informing the user
   --                           that no adjustment detail records are created for planned awards.
   --smadathi    11-Jun-2002    Bug 2387572. Logging of IGF_SP_NO_AWARD added. Moreover,the code
   --                           logic has been handled to log the message IGF_SP_FUND_AWARD only
   --                           once when disbursements are created successfully. The amount token
   --                           was removed off from the message IGF_SP_CREATE_AWARD.
   --vvutukur    15-apr-2002    Added cursor cur_include_as_plncrd to pass the show_on_bill selected from igs_fi_fund_mast
   --                           of particular fund_id. Done for bug#2293676.
  -------------------------------------------------------------------------------------
    -- cursor to see that tot_spnsr_amount is present in the igf_sp_stdnt_rel table
    CURSOR c_stdnt_rel (cp_spnsr_stdnt_id      igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_stdnt_rel
    WHERE  spnsr_stdnt_id = cp_spnsr_stdnt_id;

    rec_stdnt_rel c_stdnt_rel%ROWTYPE;

    -- cursor to fetch the FC record
    CURSOR c_std_fc (cp_spnsr_stdnt_id      igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_std_fc
    WHERE  spnsr_stdnt_id = cp_spnsr_stdnt_id;

    l_include_as_plncrd igf_aw_fund_mast.show_on_bill%TYPE;

    l_disb_gross_amt igf_aw_awd_disb.disb_gross_amt%TYPE;
    l_chk_elig VARCHAR2(1);
    l_award_id igf_aw_award.award_id%TYPE;
    l_disb_num igf_aw_awd_disb.disb_num%TYPE;
    l_n_cnt NUMBER := 0;

    l_n_tot_spns_amt   igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;

  BEGIN
    SAVEPOINT sp_award;
    --Get the show-on-bill value from igs_fi_fund_mast for passed fund_id.
    l_include_as_plncrd := get_show_on_bill(p_fund_id);
    -- check if tot_spnsr_amount is present in the igf_sp_stdnt_rel table
    OPEN c_stdnt_rel(p_spnsr_stdnt_id);
    FETCH c_stdnt_rel INTO rec_stdnt_rel;
    CLOSE c_stdnt_rel;

    IF rec_stdnt_rel.tot_spnsr_amount IS NULL THEN
      -- look at FC level
      g_rowid := NULL;
      l_award_id := NULL;
      igf_aw_award_pkg.insert_row(x_rowid              => g_rowid ,
                        x_award_id                     => l_award_id  ,
                        x_fund_id                      => rec_stdnt_rel.fund_id,
                        x_base_id                      => rec_stdnt_rel.base_id,
                        x_offered_amt                  => 0 ,
                        x_accepted_amt                 => 0 ,
                        x_paid_amt                     => NULL,
                        x_packaging_type               => NULL,
                        x_batch_id                     => NULL,
                        x_manual_update                => 'N' ,
                        x_rules_override               => NULL,
                        x_award_date                   => TRUNC(SYSDATE),
                        x_award_status                 => 'ACCEPTED' ,
                        x_attribute_category           => NULL,
                        x_attribute1                   => NULL,
                        x_attribute2                   => NULL,
                        x_attribute3                   => NULL,
                        x_attribute4                   => NULL,
                        x_attribute5                   => NULL,
                        x_attribute6                   => NULL,
                        x_attribute7                   => NULL,
                        x_attribute8                   => NULL,
                        x_attribute9                   => NULL,
                        x_attribute10                  => NULL,
                        x_attribute11                  => NULL,
                        x_attribute12                  => NULL,
                        x_attribute13                  => NULL,
                        x_attribute14                  => NULL,
                        x_attribute15                  => NULL,
                        x_attribute16                  => NULL,
                        x_attribute17                  => NULL,
                        x_attribute18                  => NULL,
                        x_attribute19                  => NULL,
                        x_attribute20                  => NULL,
                        x_rvsn_id                      => NULL,
                        x_alt_pell_schedule            =>NULL,
                        x_mode                         => 'R',
                        x_award_number_txt             => NULL,
                        x_legacy_record_flag           => NULL,
                        x_lock_award_flag              => 'N',
                        x_app_trans_num_txt            => NULL,
                        x_awd_proc_status_code         => NULL,
                        x_notification_status_code	   => NULL,
                        x_notification_status_date	   => NULL,
                        x_publish_in_ss_flag           => 'N'
                        );

      -- get the disb num
      l_disb_num := get_disb_num(l_award_id);
      l_n_cnt := 0;

      g_b_msg_logged := FALSE;
      FOR rec_std_fc IN c_std_fc (rec_stdnt_rel.spnsr_stdnt_id)
      LOOP

        BEGIN
          l_disb_gross_amt := recal_dis_gross_amt (p_spnsr_stdnt_id => rec_stdnt_rel.spnsr_stdnt_id,
                                                   p_fee_cls_id     => rec_std_fc.fee_cls_id,
                                                   p_chk_elig       => p_chk_elig);

          -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
          l_disb_gross_amt := igs_fi_gen_gl.get_formatted_amount(l_disb_gross_amt);

          -- Log the fee class details
          IF NVL(l_disb_gross_amt ,0) = 0 THEN
            -- No disb gross amount
            -- log the message only once
            log_parameters(g_v_disb_fee_class,igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_std_fc.fee_class));
            fnd_message.set_name('IGF','IGF_SP_ELGB_FAIL');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE
            g_b_msg_logged := TRUE;
            l_n_cnt := NVL(l_n_cnt,0) + 1;
            g_rowid := NULL;
            igf_aw_awd_disb_pkg.insert_row(
                        x_rowid                          => g_rowid   ,
                        x_award_id                       => l_award_id    ,
                        x_disb_num                       => l_disb_num    ,
                        x_tp_cal_type                    => NULL    ,
                        x_tp_sequence_number             => NULL    ,
                        x_disb_gross_amt                 => l_disb_gross_amt    ,
                        x_fee_1                          => NULL    ,
                        x_fee_2                          => NULL    ,
                        x_disb_net_amt                   => l_disb_gross_amt    ,
                        x_disb_date                      => TRUNC(SYSDATE)    ,
                        x_trans_type                     => p_award_type    ,
                        x_elig_status                    => NULL    ,
                        x_elig_status_date               => NULL    ,
                        x_affirm_flag                    => NULL    ,
                        x_hold_rel_ind                   => NULL    ,
                        x_manual_hold_ind                => NULL    ,
                        x_disb_status                    => NULL    ,
                        x_disb_status_date               => NULL    ,
                        x_late_disb_ind                  => NULL    ,
                        x_fund_dist_mthd                 => NULL    ,
                        x_prev_reported_ind              => NULL    ,
                        x_fund_release_date              => NULL    ,
                        x_fund_status                    => NULL    ,
                        x_fund_status_date               => NULL    ,
                        x_fee_paid_1                     => NULL  ,
                        x_fee_paid_2                     => NULL    ,
                        x_cheque_number                  => NULL    ,
                        x_ld_cal_type                    => p_ld_cal_type   ,
                        x_ld_sequence_number             => p_ld_sequence_number  ,
                        x_disb_accepted_amt              => l_disb_gross_amt    ,
                        x_disb_paid_amt                  => NULL    ,
                        x_rvsn_id                        => NULL    ,
                        x_int_rebate_amt                 => NULL    ,
                        x_force_disb                     => NULL    ,
                        x_min_credit_pts                 => NULL    ,
                        x_disb_exp_dt                    => NULL    ,
                        x_verf_enfr_dt                   => NULL    ,
                        x_fee_class                      => rec_std_fc.fee_class  ,
                        x_show_on_bill                   => l_include_as_plncrd    ,  --for bug#2293676.
                        x_mode                           => 'R'     ,
                        x_attendance_type_code           => NULL    ,
                        x_base_attendance_type_code      => NULL,
                        x_payment_prd_st_date            => NULL,
                        x_change_type_code               => NULL,
                        x_fund_return_mthd_code          => NULL,
                        x_direct_to_borr_flag            => 'N'

                        );

            -- Log Message only once and when the Fee Class Details are defined
            IF l_n_cnt = 1 THEN
              fnd_message.set_name('IGF','IGF_SP_CREATE_AWARD');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              log_parameters(g_v_award_id,l_award_id);
            END IF;

            fnd_message.set_name('IGF','IGF_SP_CREATE_DISB');
            fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',p_award_type));
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            log_parameters(g_v_disb_fee_class,igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_std_fc.fee_class));
            log_parameters(g_v_disb_amount,l_disb_gross_amt);

            IF p_award_type = 'A' THEN
              create_disb_dtl (l_award_id, l_disb_num);
            END IF;
            l_disb_num := l_disb_num + 1;
          END IF;
        END ;
      END LOOP;

      -- log the award amount only a new award id created
      -- creation of a new award is identified when the g_b_msg_logged is set to TRUE
      IF g_b_msg_logged THEN
        -- log award amount only when an award is created.
        log_parameters(g_v_award_amount,get_award_amount(l_award_id));
      END IF;
      -- re-initialize to FALSE
      g_b_msg_logged := FALSE;

      IF NVL(l_n_cnt,0) = 0 THEN
        ROLLBACK TO sp_award;
      END IF;
    ELSIF NVL(rec_stdnt_rel.tot_spnsr_amount,0) > 0  THEN

      l_n_tot_spns_amt := recal_dis_gross_amt(p_spnsr_stdnt_id  => rec_stdnt_rel.spnsr_stdnt_id,
                                              p_fee_cls_id      => NULL,
                                              p_chk_elig        => p_chk_elig);

      --  create record in igf_aw_award and igf_aw_awd_disb with the same amount
      g_rowid := NULL;
      l_award_id := NULL;

      -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
      l_n_tot_spns_amt := igs_fi_gen_gl.get_formatted_amount(l_n_tot_spns_amt);

      igf_aw_award_pkg.insert_row(
                        x_rowid                        => g_rowid ,
                        x_award_id                     => l_award_id  ,
                        x_fund_id                      => rec_stdnt_rel.fund_id,
                        x_base_id                      => rec_stdnt_rel.base_id,
                        x_offered_amt                  => l_n_tot_spns_amt ,
                        x_accepted_amt                 => l_n_tot_spns_amt ,
                        x_paid_amt                     => NULL,
                        x_packaging_type               => NULL,
                        x_batch_id                     => NULL,
                        x_manual_update                => 'N' ,
                        x_rules_override               => NULL,
                        x_award_date                   => TRUNC(SYSDATE),
                        x_award_status                 => 'ACCEPTED' ,
                        x_attribute_category           => NULL,
                        x_attribute1                   => NULL,
                        x_attribute2                   => NULL,
                        x_attribute3                   => NULL,
                        x_attribute4                   => NULL,
                        x_attribute5                   => NULL,
                        x_attribute6                   => NULL,
                        x_attribute7                   => NULL,
                        x_attribute8                   => NULL,
                        x_attribute9                   => NULL,
                        x_attribute10                  => NULL,
                        x_attribute11                  => NULL,
                        x_attribute12                  => NULL,
                        x_attribute13                  => NULL,
                        x_attribute14                  => NULL,
                        x_attribute15                  => NULL,
                        x_attribute16                  => NULL,
                        x_attribute17                  => NULL,
                        x_attribute18                  => NULL,
                        x_attribute19                  => NULL,
                        x_attribute20                  => NULL,
                        x_rvsn_id                      => NULL,
                        x_alt_pell_schedule            =>NULL,
                        x_mode                         => 'R',
                        x_award_number_txt             => NULL,
                        x_legacy_record_flag           => NULL,
                        x_lock_award_flag              => 'N',
                        x_app_trans_num_txt            => NULL,
                        x_awd_proc_status_code         => NULL,
                        x_notification_status_code	=> NULL,
                        x_notification_status_date	=> NULL,
                        x_publish_in_ss_flag        => 'N'
                        );

       fnd_message.set_name('IGF','IGF_SP_CREATE_AWARD');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       log_parameters(g_v_award_id,l_award_id);

       l_disb_num := get_disb_num (l_award_id);
       g_rowid := NULL;
                       igf_aw_awd_disb_pkg.insert_row(
                        x_rowid                          => g_rowid   ,
                        x_award_id                       => l_award_id    ,
                        x_disb_num                       => l_disb_num    ,
                        x_tp_cal_type                    => NULL    ,
                        x_tp_sequence_number             => NULL    ,
                        x_disb_gross_amt                 => l_n_tot_spns_amt    ,
                        x_fee_1                          => NULL    ,
                        x_fee_2                          => NULL    ,
                        x_disb_net_amt                   => l_n_tot_spns_amt    ,
                        x_disb_date                      => TRUNC(SYSDATE)    ,
                        x_trans_type                     => p_award_type    ,
                        x_elig_status                    => NULL    ,
                        x_elig_status_date               => NULL    ,
                        x_affirm_flag                    => NULL    ,
                        x_hold_rel_ind                   => NULL    ,
                        x_manual_hold_ind                => NULL    ,
                        x_disb_status                    => NULL    ,
                        x_disb_status_date               => NULL    ,
                        x_late_disb_ind                  => NULL    ,
                        x_fund_dist_mthd                 => NULL    ,
                        x_prev_reported_ind              => NULL    ,
                        x_fund_release_date              => NULL    ,
                        x_fund_status                    => NULL    ,
                        x_fund_status_date               => NULL    ,
                        x_fee_paid_1                     => NULL  ,
                        x_fee_paid_2                     => NULL    ,
                        x_cheque_number                  => NULL    ,
                        x_ld_cal_type                    => p_ld_cal_type   ,
                        x_ld_sequence_number             => p_ld_sequence_number  ,
                        x_disb_accepted_amt              => l_n_tot_spns_amt    ,
                        x_disb_paid_amt                  => NULL    ,
                        x_rvsn_id                        => NULL    ,
                        x_int_rebate_amt                 => NULL    ,
                        x_force_disb                     => NULL    ,
                        x_min_credit_pts                 => NULL    ,
                        x_disb_exp_dt                    => NULL    ,
                        x_verf_enfr_dt                   => NULL    ,
                        x_fee_class                      => NULL    ,
                        x_show_on_bill                   => l_include_as_plncrd ,  --for bug#2293676.
                        x_mode                           => 'R'     ,
                        x_attendance_type_code           => NULL    ,
                        x_base_attendance_type_code      => NULL,
                        x_payment_prd_st_date            => NULL,
                        x_change_type_code               => NULL,
                        x_fund_return_mthd_code          => NULL,
                        x_direct_to_borr_flag            => 'N'
                        );

         fnd_message.set_name('IGF','IGF_SP_CREATE_DISB');
         fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',p_award_type));
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         log_parameters(g_v_disb_fee_class,NULL);
         log_parameters(g_v_disb_amount,l_n_tot_spns_amt);
         log_parameters(g_v_award_amount,l_n_tot_spns_amt);
         --  create disb detail adjustment
         IF p_award_type = 'A' THEN
             create_disb_dtl (l_award_id, l_disb_num);
         END IF;
    END IF;
  END create_aw_award;

  PROCEDURE loop_thru_spnsr_dtl_pvt (p_person_id           igs_pe_person.person_id%TYPE,
                                     p_award_type          VARCHAR2,
                                     p_base_id             igf_sp_stdnt_rel.base_id%TYPE,
                                     p_fund_id             igf_sp_stdnt_rel.base_id%TYPE,
                                     p_min_attendance_type igf_sp_stdnt_rel.min_attendance_type%TYPE,
                                     p_min_credit_points   igf_sp_stdnt_rel.min_credit_points%TYPE,
                                     p_ld_cal_type         igf_sp_stdnt_rel.ld_cal_type%TYPE,
                                     p_ld_sequence_number  igf_sp_stdnt_rel.ld_sequence_number%TYPE,
                                     p_spnsr_stdnt_id      igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE,
                                     p_fee_type            igf_aw_fund_mast.fee_type%TYPE,
                                     p_n_total_spnsr_amt   igf_sp_stdnt_rel.tot_spnsr_amount%TYPE
                                     )
  AS
  ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          this is the local procedure to loop_thru_spnsr_dtl
        --          created as the similar code is to be called from if else condt
  --
  --          parameter description:
  --          p_person_id              - Person ID
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat    18-May-2006     Bug 5194095 - Added calls to recal_dis_gross_amt to fetch the
  --                            total sponsor amount.
  --sapanigr    03-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igf_aw_awd_disb
  --                            are now rounded off to currency precision
  --vchappid    22-Jun-2003     Bug 2881654, Log file format is revamped
  --smadathi    17-Jun-2002     Bug 2387572. Logging of IGF_SP_NO_AWARD added. The token
  --                            amount for message IGF_SP_UPDATE_AWARD modified to handle the
  --                            case when null values are passed.
  --smadathi    17-May-2002     Bug 2369173. Modified currsor c_manual_update , c_aw_awd_disb
  --                            select statement. Added load cal type and load sequence number
  --                            parameters to cursor c_manual_update. A new cursor c_igf_sp_std_fc
  --                            added to fetch details from sponsor student relation table.
  -------------------------------------------------------------------------------------
    l_chk_elig  VARCHAR2(1);

    -- cursor to see the value for the manual update
    CURSOR c_manual_update (cp_base_id            igf_sp_stdnt_rel.base_id%TYPE,
                            cp_fund_id            igf_sp_stdnt_rel.fund_id%TYPE,
                            cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                            cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                           )
    IS
    SELECT NVL(manual_update,'N'), award_id
    FROM   igf_aw_award awd
    WHERE  base_id = cp_base_id
    AND    fund_id = cp_fund_id
    AND    EXISTS (SELECT '1'
                   FROM   igf_aw_awd_disb  disb
                   WHERE  disb.award_id            = awd.award_id
                   AND    disb.ld_cal_type         = cp_ld_cal_type
                   AND    disb.ld_sequence_number  = cp_ld_sequence_number);

    l_manual_update  igf_aw_award.manual_update%TYPE;
    l_award_id       igf_aw_award.award_id%TYPE;
    l_rec_count      NUMBER :=0;
    l_disb_gross_amt igf_aw_awd_disb.disb_gross_amt%TYPE;

    -- cursor to fetch records from igf_aw_awd_disb which have trans_type as P
    CURSOR c_aw_awd_disb(cp_award_id    igf_aw_award.award_id%TYPE,
                         cp_v_fee_class igf_aw_awd_disb.fee_class%TYPE,
                         cp_trans_type  igf_aw_awd_disb.trans_type%TYPE
                        )
    IS
    SELECT *
    FROM   igf_aw_awd_disb
    WHERE  award_id = cp_award_id
    AND    (
            (fee_class = cp_v_fee_class AND cp_v_fee_class IS NOT NULL AND fee_class IS NOT NULL)
             OR
            (cp_v_fee_class IS NULL)
           )
    AND    (
            (cp_trans_type IS NOT NULL AND trans_type = cp_trans_type)
             OR
             (cp_trans_type IS NULL AND trans_type IN ('A','P'))
           );

    rec_aw_awd_disb c_aw_awd_disb%ROWTYPE;

    CURSOR c_igf_sp_std_fc (cp_spnsr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE)
    IS
    SELECT *
    FROM   igf_sp_std_fc
    WHERE  spnsr_stdnt_id = cp_spnsr_stdnt_id;
    rec_c_igf_sp_std_fc  c_igf_sp_std_fc%ROWTYPE;
    l_n_before_awd_amt igf_aw_award.accepted_amt%TYPE :=0;

    l_include_as_plncrd igf_aw_fund_mast.show_on_bill%TYPE;
    l_v_award_type igf_aw_awd_disb.trans_type%TYPE;
    l_n_disb_num igf_aw_awd_disb.disb_num%TYPE;

    l_v_upd_msg_text fnd_new_messages.message_text%TYPE;

    TYPE l_msg_tab IS TABLE OF fnd_new_messages.message_text%TYPE INDEX BY BINARY_INTEGER;
    l_v_msg l_msg_tab;
    l_v_msg_null l_msg_tab;

    i BINARY_INTEGER;

    l_n_tot_spns_amt   igf_sp_stdnt_rel.tot_spnsr_amount%TYPE;

  BEGIN -- begin for loop_thru_spnsr_dtl_pvt

    l_include_as_plncrd := get_show_on_bill(p_fund_id);

    -- decide if eligibility check has to be made or not
    IF p_award_type = 'A' THEN
      l_chk_elig := 'Y';
    ELSE
      l_chk_elig := 'N';
    END IF;

    -- Loop across all Fee Class Details
    OPEN c_manual_update (p_base_id,
                          p_fund_id,
                          p_ld_cal_type,
                          p_ld_sequence_number
                         );
    LOOP
    FETCH c_manual_update INTO l_manual_update,l_award_id;
    EXIT WHEN c_manual_update%NOTFOUND;
      l_rec_count := c_manual_update%ROWCOUNT;
      IF l_manual_update = 'Y' AND p_award_type = 'A' THEN
        -- fetch record from igf_aw_awd_disb based on award id obtained and update only if
        -- the award type is A
        g_b_msg_logged := FALSE;
        FOR rec_aw_awd_disb IN c_aw_awd_disb (l_award_id,NULL,'P')
        LOOP
          IF NOT g_b_msg_logged THEN
            log_parameters(g_v_award_id,l_award_id);
            g_b_msg_logged := TRUE;
          END IF;

          fnd_message.set_name('IGF','IGF_SP_PLN_AWD_CNV_ACT_AWD');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          -- make trans type P to A
          igf_aw_awd_disb_pkg.update_row (x_rowid                          => rec_aw_awd_disb.row_id                          ,
                                          x_award_id                       => rec_aw_awd_disb.award_id                        ,
                                          x_disb_num                       => rec_aw_awd_disb.disb_num                        ,
                                          x_tp_cal_type                    => rec_aw_awd_disb.tp_cal_type                     ,
                                          x_tp_sequence_number             => rec_aw_awd_disb.tp_sequence_number              ,
                                          x_disb_gross_amt                 => rec_aw_awd_disb.disb_gross_amt                  ,
                                          x_fee_1                          => rec_aw_awd_disb.fee_1                           ,
                                          x_fee_2                          => rec_aw_awd_disb.fee_2                           ,
                                          x_disb_net_amt                   => rec_aw_awd_disb.disb_net_amt                    ,
                                          x_disb_date                      => rec_aw_awd_disb.disb_date                       ,
                                          x_trans_type                     => 'A'                           ,
                                          x_elig_status                    => rec_aw_awd_disb.elig_status                     ,
                                          x_elig_status_date               => rec_aw_awd_disb.elig_status_date                ,
                                          x_affirm_flag                    => rec_aw_awd_disb.affirm_flag                     ,
                                          x_hold_rel_ind                   => rec_aw_awd_disb.hold_rel_ind                    ,
                                          x_manual_hold_ind                => rec_aw_awd_disb.manual_hold_ind                 ,
                                          x_disb_status                    => rec_aw_awd_disb.disb_status                     ,
                                          x_disb_status_date               => rec_aw_awd_disb.disb_status_date                ,
                                          x_late_disb_ind                  => rec_aw_awd_disb.late_disb_ind                   ,
                                          x_fund_dist_mthd                 => rec_aw_awd_disb.fund_dist_mthd                  ,
                                          x_prev_reported_ind              => rec_aw_awd_disb.prev_reported_ind               ,
                                          x_fund_release_date              => rec_aw_awd_disb.fund_release_date               ,
                                          x_fund_status                    => rec_aw_awd_disb.fund_status                     ,
                                          x_fund_status_date               => rec_aw_awd_disb.fund_status_date                ,
                                          x_fee_paid_1                     => rec_aw_awd_disb.fee_paid_1                      ,
                                          x_fee_paid_2                     => rec_aw_awd_disb.fee_paid_2                      ,
                                          x_cheque_number                  => rec_aw_awd_disb.cheque_number                   ,
                                          x_ld_cal_type                    => rec_aw_awd_disb.ld_cal_type                     ,
                                          x_ld_sequence_number             => rec_aw_awd_disb.ld_sequence_number              ,
                                          x_disb_accepted_amt              => rec_aw_awd_disb.disb_accepted_amt               ,
                                          x_disb_paid_amt                  => rec_aw_awd_disb.disb_paid_amt                   ,
                                          x_rvsn_id                        => rec_aw_awd_disb.rvsn_id                         ,
                                          x_int_rebate_amt                 => rec_aw_awd_disb.int_rebate_amt                  ,
                                          x_force_disb                     => rec_aw_awd_disb.force_disb                      ,
                                          x_min_credit_pts                 => rec_aw_awd_disb.min_credit_pts                  ,
                                          x_disb_exp_dt                    => rec_aw_awd_disb.disb_exp_dt                     ,
                                          x_verf_enfr_dt                   => rec_aw_awd_disb.verf_enfr_dt                    ,
                                          x_fee_class                      => rec_aw_awd_disb.fee_class                       ,
                                          x_show_on_bill                   => rec_aw_awd_disb.show_on_bill                    ,
                                          x_mode                           => 'R'                                             ,
                                          x_attendance_type_code           => rec_aw_awd_disb.attendance_type_code            ,
                                          x_base_attendance_type_code      => rec_aw_awd_disb.base_attendance_type_code       ,
                                          x_payment_prd_st_date            => rec_aw_awd_disb.payment_prd_st_date             ,
                                          x_change_type_code               => rec_aw_awd_disb.change_type_code                ,
                                          x_fund_return_mthd_code          => rec_aw_awd_disb.fund_return_mthd_code           ,
                                          x_direct_to_borr_flag            => rec_aw_awd_disb.direct_to_borr_flag

                                         );

          log_parameters(g_v_disb_fee_class,igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class));
          log_parameters(g_v_disb_amount,rec_aw_awd_disb.disb_net_amt);
          create_disb_dtl (rec_aw_awd_disb.award_id, rec_aw_awd_disb.disb_num);
        END LOOP;
        IF g_b_msg_logged THEN
          log_parameters(g_v_award_amount,get_award_amount(l_award_id));
        ELSE
          fnd_message.set_name('IGF','IGF_SP_AWD_NOT_UPDATED');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          log_parameters(g_v_award_id,l_award_id);
        END IF;
      ELSIF l_manual_update = 'N' AND p_n_total_spnsr_amt IS NOT NULL AND p_award_type = 'A' THEN
      -- When invoked in the Actual Mode then get all the Planned Disbursement Records and check if the
      -- eligibility satisfies. If satisfies then update the status to Actual.

        IF NOT check_eligibility(p_person_id => p_person_id,
                                 p_min_att_type => p_min_attendance_type,
                                 p_min_credit_points => p_min_credit_points ,
                                 p_ld_cal_type => p_ld_cal_type,
                                 p_ld_sequence_number => p_ld_sequence_number ) THEN
          log_parameters(g_v_disb_fee_class,NULL);
          fnd_message.set_name('IGF','IGF_SP_ELGB_FAIL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
          log_parameters(g_v_award_id,l_award_id);

          -- Fetch the Disbursement Amount using the following function.
          l_n_tot_spns_amt := recal_dis_gross_amt(p_spnsr_stdnt_id  => p_spnsr_stdnt_id,
                                                  p_fee_cls_id      => NULL,
                                                  p_chk_elig        => l_chk_elig);

          -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
          l_n_tot_spns_amt := igs_fi_gen_gl.get_formatted_amount(l_n_tot_spns_amt);

          -- fetch record from igf_aw_awd_disb based on award id obtained and update only if
          -- the award type is A
          FOR rec_aw_awd_disb IN c_aw_awd_disb (l_award_id,NULL,'P')
          LOOP
              fnd_message.set_name('IGF','IGF_SP_PLN_AWD_CNV_ACT_AWD');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- make trans type P to A
            igf_aw_awd_disb_pkg.update_row (x_rowid                          => rec_aw_awd_disb.row_id                          ,
                                            x_award_id                       => rec_aw_awd_disb.award_id                        ,
                                            x_disb_num                       => rec_aw_awd_disb.disb_num                        ,
                                            x_tp_cal_type                    => rec_aw_awd_disb.tp_cal_type                     ,
                                            x_tp_sequence_number             => rec_aw_awd_disb.tp_sequence_number              ,
                                            x_disb_gross_amt                 => l_n_tot_spns_amt                  ,
                                            x_fee_1                          => rec_aw_awd_disb.fee_1                           ,
                                            x_fee_2                          => rec_aw_awd_disb.fee_2                           ,
                                            x_disb_net_amt                   => l_n_tot_spns_amt                    ,
                                            x_disb_date                      => rec_aw_awd_disb.disb_date                       ,
                                            x_trans_type                     => 'A'                           ,
                                            x_elig_status                    => rec_aw_awd_disb.elig_status                     ,
                                            x_elig_status_date               => rec_aw_awd_disb.elig_status_date                ,
                                            x_affirm_flag                    => rec_aw_awd_disb.affirm_flag                     ,
                                            x_hold_rel_ind                   => rec_aw_awd_disb.hold_rel_ind                    ,
                                            x_manual_hold_ind                => rec_aw_awd_disb.manual_hold_ind                 ,
                                            x_disb_status                    => rec_aw_awd_disb.disb_status                     ,
                                            x_disb_status_date               => rec_aw_awd_disb.disb_status_date                ,
                                            x_late_disb_ind                  => rec_aw_awd_disb.late_disb_ind                   ,
                                            x_fund_dist_mthd                 => rec_aw_awd_disb.fund_dist_mthd                  ,
                                            x_prev_reported_ind              => rec_aw_awd_disb.prev_reported_ind               ,
                                            x_fund_release_date              => rec_aw_awd_disb.fund_release_date               ,
                                            x_fund_status                    => rec_aw_awd_disb.fund_status                     ,
                                            x_fund_status_date               => rec_aw_awd_disb.fund_status_date                ,
                                            x_fee_paid_1                     => rec_aw_awd_disb.fee_paid_1                      ,
                                            x_fee_paid_2                     => rec_aw_awd_disb.fee_paid_2                      ,
                                            x_cheque_number                  => rec_aw_awd_disb.cheque_number                   ,
                                            x_ld_cal_type                    => rec_aw_awd_disb.ld_cal_type                     ,
                                            x_ld_sequence_number             => rec_aw_awd_disb.ld_sequence_number              ,
                                            x_disb_accepted_amt              => l_n_tot_spns_amt               ,
                                            x_disb_paid_amt                  => rec_aw_awd_disb.disb_paid_amt                   ,
                                            x_rvsn_id                        => rec_aw_awd_disb.rvsn_id                         ,
                                            x_int_rebate_amt                 => rec_aw_awd_disb.int_rebate_amt                  ,
                                            x_force_disb                     => rec_aw_awd_disb.force_disb                      ,
                                            x_min_credit_pts                 => rec_aw_awd_disb.min_credit_pts                  ,
                                            x_disb_exp_dt                    => rec_aw_awd_disb.disb_exp_dt                     ,
                                            x_verf_enfr_dt                   => rec_aw_awd_disb.verf_enfr_dt                    ,
                                            x_fee_class                      => rec_aw_awd_disb.fee_class                       ,
                                            x_show_on_bill                   => rec_aw_awd_disb.show_on_bill                    ,
                                            x_mode                           => 'R'                                             ,
                                            x_attendance_type_code           => rec_aw_awd_disb.attendance_type_code            ,
                                            x_base_attendance_type_code      => rec_aw_awd_disb.base_attendance_type_code       ,
                                            x_payment_prd_st_date            => rec_aw_awd_disb.payment_prd_st_date             ,
                                            x_change_type_code               => rec_aw_awd_disb.change_type_code                ,
                                            x_fund_return_mthd_code          => rec_aw_awd_disb.fund_return_mthd_code           ,
                                            x_direct_to_borr_flag            => rec_aw_awd_disb.direct_to_borr_flag

                                           );

            log_parameters(g_v_disb_fee_class,igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class));
            log_parameters(g_v_disb_amount,l_n_tot_spns_amt);
            create_disb_dtl(rec_aw_awd_disb.award_id, rec_aw_awd_disb.disb_num);
          END LOOP;
          log_parameters(g_v_award_amount,get_award_amount(l_award_id));
        END IF;
      ELSIF l_manual_update = 'N' AND p_n_total_spnsr_amt IS NULL THEN


        -- When the Award Type is provided as "A" then get all the disbursement records
        -- that are even in the Planned State.
        -- Otherwise get only the Planned Records.
        IF p_award_type = 'A' THEN
          l_v_award_type := NULL;
        ELSE
          l_v_award_type := 'P';
        END IF;

        -- get the Existing award amount
        l_n_before_awd_amt := get_award_amount(l_award_id);

        -- initalize the Binary Integer
        i := 0;
        g_b_award_updated := FALSE;
        g_b_msg_logged := FALSE;
        OPEN c_igf_sp_std_fc(p_spnsr_stdnt_id);
        LOOP
        FETCH c_igf_sp_std_fc INTO rec_c_igf_sp_std_fc;
        EXIT WHEN c_igf_sp_std_fc%NOTFOUND;
          -- fetch record from igf_aw_awd_disb based on award id obtained
          OPEN c_aw_awd_disb(l_award_id,rec_c_igf_sp_std_fc.fee_class,NULL);
          FETCH c_aw_awd_disb INTO rec_aw_awd_disb;
          IF c_aw_awd_disb%FOUND THEN
            IF NOT (rec_aw_awd_disb.trans_type = 'A' AND p_award_type = 'P') THEN
              -- recalculate the disbursement amount when a disbursement record already exists
              l_disb_gross_amt:= recal_dis_gross_amt(p_spnsr_stdnt_id => p_spnsr_stdnt_id,
                                                     p_fee_cls_id     => rec_c_igf_sp_std_fc.fee_cls_id,
                                                     p_chk_elig       => l_chk_elig);

              -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
              l_disb_gross_amt := igs_fi_gen_gl.get_formatted_amount(l_disb_gross_amt);

              IF NVL(l_disb_gross_amt,0) = 0 THEN
                -- No disb gross amount
                -- log the message only once
                i := i+1;
                l_v_msg(i) := g_v_disb_fee_class ||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class);

                i := i+1;
                fnd_message.set_name('IGF','IGF_SP_NO_UPDATE_DISB');
                fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',rec_aw_awd_disb.trans_type));
                l_v_msg(i) := fnd_message.get;
              ELSE
                IF NVL(l_disb_gross_amt,0) <> rec_aw_awd_disb.disb_net_amt THEN
                  fnd_message.set_name('IGF','IGF_SP_UPDATE_AWARD');
                  l_v_upd_msg_text := fnd_message.get;
                  IF rec_aw_awd_disb.trans_type = 'P' AND p_award_type = 'A' THEN
                    i := i+1;
                    fnd_message.set_name('IGF','IGF_SP_PLN_AWD_CNV_ACT_AWD');
                    l_v_msg(i) := fnd_message.get;
                  ELSE
                    i := i+1;
                    fnd_message.set_name('IGF','IGF_SP_UPDATE_DISB');
                    fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',rec_aw_awd_disb.trans_type));
                    l_v_msg(i) := fnd_message.get;
                  END IF;

                  i := i+1;
                  l_v_msg(i) := g_v_disb_fee_class||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class);
                  i := i+1;
                  l_v_msg(i) := g_v_ext_disb_amount||' : '|| rec_aw_awd_disb.disb_net_amt;
                  i := i+1;
                  l_v_msg(i) := g_v_upd_disb_amount||' : '|| l_disb_gross_amt;

                  igf_aw_awd_disb_pkg.update_row (x_rowid => rec_aw_awd_disb.row_id,
                                 x_award_id                       => rec_aw_awd_disb.award_id                        ,
                                 x_disb_num                       => rec_aw_awd_disb.disb_num                        ,
                                 x_tp_cal_type                    => rec_aw_awd_disb.tp_cal_type                     ,
                                 x_tp_sequence_number             => rec_aw_awd_disb.tp_sequence_number              ,
                                 x_disb_gross_amt                 => l_disb_gross_amt                    ,
                                 x_fee_1                          => rec_aw_awd_disb.fee_1                           ,
                                 x_fee_2                          => rec_aw_awd_disb.fee_2                           ,
                                 x_disb_net_amt                   => l_disb_gross_amt                    ,
                                 x_disb_date                      => rec_aw_awd_disb.disb_date,
                                 x_trans_type                     => NVL(l_v_award_type,'A'),
                                 x_elig_status                    => rec_aw_awd_disb.elig_status                     ,
                                 x_elig_status_date               => rec_aw_awd_disb.elig_status_date                ,
                                 x_affirm_flag                    => rec_aw_awd_disb.affirm_flag                     ,
                                 x_hold_rel_ind                   => rec_aw_awd_disb.hold_rel_ind                    ,
                                 x_manual_hold_ind                => rec_aw_awd_disb.manual_hold_ind                 ,
                                 x_disb_status                    => rec_aw_awd_disb.disb_status                     ,
                                 x_disb_status_date               => rec_aw_awd_disb.disb_status_date                ,
                                 x_late_disb_ind                  => rec_aw_awd_disb.late_disb_ind                   ,
                                 x_fund_dist_mthd                 => rec_aw_awd_disb.fund_dist_mthd                  ,
                                 x_prev_reported_ind              => rec_aw_awd_disb.prev_reported_ind               ,
                                 x_fund_release_date              => rec_aw_awd_disb.fund_release_date               ,
                                 x_fund_status                    => rec_aw_awd_disb.fund_status                     ,
                                 x_fund_status_date               => rec_aw_awd_disb.fund_status_date                ,
                                 x_fee_paid_1                     => rec_aw_awd_disb.fee_paid_1                      ,
                                 x_fee_paid_2                     => rec_aw_awd_disb.fee_paid_2                      ,
                                 x_cheque_number                  => rec_aw_awd_disb.cheque_number                   ,
                                 x_ld_cal_type                    => rec_aw_awd_disb.ld_cal_type                     ,
                                 x_ld_sequence_number             => rec_aw_awd_disb.ld_sequence_number              ,
                                 x_disb_accepted_amt              => l_disb_gross_amt                ,
                                 x_disb_paid_amt                  => rec_aw_awd_disb.disb_paid_amt                   ,
                                 x_rvsn_id                        => rec_aw_awd_disb.rvsn_id                         ,
                                 x_int_rebate_amt                 => rec_aw_awd_disb.int_rebate_amt                  ,
                                 x_force_disb                     => rec_aw_awd_disb.force_disb                      ,
                                 x_min_credit_pts                 => rec_aw_awd_disb.min_credit_pts                  ,
                                 x_disb_exp_dt                    => rec_aw_awd_disb.disb_exp_dt                     ,
                                 x_verf_enfr_dt                   => rec_aw_awd_disb.verf_enfr_dt                    ,
                                 x_fee_class                      => rec_aw_awd_disb.fee_class                       ,
                                 x_show_on_bill                   => rec_aw_awd_disb.show_on_bill                    ,
                                 x_mode                           => 'R'                                             ,
                                 x_attendance_type_code           => rec_aw_awd_disb.attendance_type_code            ,
                                 x_base_attendance_type_code      => rec_aw_awd_disb.base_attendance_type_code       ,
                                 x_payment_prd_st_date            => rec_aw_awd_disb.payment_prd_st_date             ,
                                 x_change_type_code               => rec_aw_awd_disb.change_type_code                ,
                                 x_fund_return_mthd_code          => rec_aw_awd_disb.fund_return_mthd_code           ,
                                 x_direct_to_borr_flag            => rec_aw_awd_disb.direct_to_borr_flag
                                 );

                  IF (p_award_type = 'A') THEN
                    -- create disb detail adjustment
                    create_disb_dtl (rec_aw_awd_disb.award_id, rec_aw_awd_disb.disb_num);
                  END IF;
                ELSE
                  IF p_award_type ='A' AND rec_aw_awd_disb.trans_type = 'P' THEN
                    fnd_message.set_name('IGF','IGF_SP_PLN_AWD_CNV_ACT_AWD');
                    i := i+1;
                    l_v_msg(i) := fnd_message.get;

                    i := i+1;
                    l_v_msg(i) := g_v_disb_fee_class||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class);

                    i := i+1;
                    l_v_msg(i) := g_v_disb_amount||' : '|| rec_aw_awd_disb.disb_net_amt;

                    -- when the process is invoked in the Actual Mode then when there is no change in the disbursement amount
                    -- then the Planned Disbursement records needs to be updated to Actual
                    igf_aw_awd_disb_pkg.update_row (x_rowid => rec_aw_awd_disb.row_id,
                                 x_award_id                       => rec_aw_awd_disb.award_id                        ,
                                 x_disb_num                       => rec_aw_awd_disb.disb_num                        ,
                                 x_tp_cal_type                    => rec_aw_awd_disb.tp_cal_type                     ,
                                 x_tp_sequence_number             => rec_aw_awd_disb.tp_sequence_number              ,
                                 x_disb_gross_amt                 => rec_aw_awd_disb.disb_gross_amt                  ,
                                 x_fee_1                          => rec_aw_awd_disb.fee_1                           ,
                                 x_fee_2                          => rec_aw_awd_disb.fee_2                           ,
                                 x_disb_net_amt                   => rec_aw_awd_disb.disb_net_amt                    ,
                                 x_disb_date                      => rec_aw_awd_disb.disb_date,
                                 x_trans_type                     => 'A',
                                 x_elig_status                    => rec_aw_awd_disb.elig_status                     ,
                                 x_elig_status_date               => rec_aw_awd_disb.elig_status_date                ,
                                 x_affirm_flag                    => rec_aw_awd_disb.affirm_flag                     ,
                                 x_hold_rel_ind                   => rec_aw_awd_disb.hold_rel_ind                    ,
                                 x_manual_hold_ind                => rec_aw_awd_disb.manual_hold_ind                 ,
                                 x_disb_status                    => rec_aw_awd_disb.disb_status                     ,
                                 x_disb_status_date               => rec_aw_awd_disb.disb_status_date                ,
                                 x_late_disb_ind                  => rec_aw_awd_disb.late_disb_ind                   ,
                                 x_fund_dist_mthd                 => rec_aw_awd_disb.fund_dist_mthd                  ,
                                 x_prev_reported_ind              => rec_aw_awd_disb.prev_reported_ind               ,
                                 x_fund_release_date              => rec_aw_awd_disb.fund_release_date               ,
                                 x_fund_status                    => rec_aw_awd_disb.fund_status                     ,
                                 x_fund_status_date               => rec_aw_awd_disb.fund_status_date                ,
                                 x_fee_paid_1                     => rec_aw_awd_disb.fee_paid_1                      ,
                                 x_fee_paid_2                     => rec_aw_awd_disb.fee_paid_2                      ,
                                 x_cheque_number                  => rec_aw_awd_disb.cheque_number                   ,
                                 x_ld_cal_type                    => rec_aw_awd_disb.ld_cal_type                     ,
                                 x_ld_sequence_number             => rec_aw_awd_disb.ld_sequence_number              ,
                                 x_disb_accepted_amt              => rec_aw_awd_disb.disb_accepted_amt               ,
                                 x_disb_paid_amt                  => rec_aw_awd_disb.disb_paid_amt                   ,
                                 x_rvsn_id                        => rec_aw_awd_disb.rvsn_id                         ,
                                 x_int_rebate_amt                 => rec_aw_awd_disb.int_rebate_amt                  ,
                                 x_force_disb                     => rec_aw_awd_disb.force_disb                      ,
                                 x_min_credit_pts                 => rec_aw_awd_disb.min_credit_pts                  ,
                                 x_disb_exp_dt                    => rec_aw_awd_disb.disb_exp_dt                     ,
                                 x_verf_enfr_dt                   => rec_aw_awd_disb.verf_enfr_dt                    ,
                                 x_fee_class                      => rec_aw_awd_disb.fee_class                       ,
                                 x_show_on_bill                   => rec_aw_awd_disb.show_on_bill                    ,
                                 x_mode                           => 'R'                                             ,
                                 x_attendance_type_code           => rec_aw_awd_disb.attendance_type_code            ,
                                 x_base_attendance_type_code      => rec_aw_awd_disb.base_attendance_type_code       ,
                                 x_payment_prd_st_date            => rec_aw_awd_disb.payment_prd_st_date             ,
                                 x_change_type_code               => rec_aw_awd_disb.change_type_code                ,
                                 x_fund_return_mthd_code          => rec_aw_awd_disb.fund_return_mthd_code           ,
                                 x_direct_to_borr_flag            => rec_aw_awd_disb.direct_to_borr_flag
                                 );

                    IF (p_award_type = 'A') THEN
                      -- create disb detail adjustment
                      create_disb_dtl (rec_aw_awd_disb.award_id, rec_aw_awd_disb.disb_num);
                    END IF;
                  ELSE
                    i := i+1;
                    l_v_msg(i) := g_v_disb_fee_class||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class);

                    fnd_message.set_name('IGF','IGF_SP_NO_UPDATE_DISB');
                    fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',rec_aw_awd_disb.trans_type));
                    i := i+1;
                    l_v_msg(i) := fnd_message.get;
                  END IF;
                END IF;
              END IF;
            ELSE
              i := i+1;
              l_v_msg(i) := g_v_disb_fee_class||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_aw_awd_disb.fee_class);
              fnd_message.set_name('IGF','IGF_SP_NO_UPDATE_DISB');
              fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',rec_aw_awd_disb.trans_type));
              i := i+1;
              l_v_msg(i) := fnd_message.get;
            END IF;
          ELSE
            -- a new record needs to be created.
            l_disb_gross_amt := recal_dis_gross_amt (p_spnsr_stdnt_id => p_spnsr_stdnt_id,
                                                     p_fee_cls_id     => rec_c_igf_sp_std_fc.fee_cls_id,
                                                     p_chk_elig       => l_chk_elig);

            -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
            l_disb_gross_amt := igs_fi_gen_gl.get_formatted_amount(l_disb_gross_amt);

            -- Log the fee class details
            IF NVL(l_disb_gross_amt ,0) = 0 THEN
              -- No disb gross amount
              i := i+1;
              l_v_msg(i) := g_v_disb_fee_class||' : '||igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_c_igf_sp_std_fc.fee_class);

              i := i+1;
              fnd_message.set_name('IGF','IGF_SP_ELGB_FAIL');
              l_v_msg(i) := fnd_message.get;
            ELSE
              g_rowid := NULL;
              l_n_disb_num := get_disb_num(l_award_id);
              g_b_award_updated := TRUE;

              fnd_message.set_name('IGF','IGF_SP_UPDATE_AWARD');
              l_v_upd_msg_text := fnd_message.get;


              igf_aw_awd_disb_pkg.insert_row(x_rowid                          => g_rowid,
                                             x_award_id                       => l_award_id,
                                             x_disb_num                       => l_n_disb_num,
                                             x_tp_cal_type                    => NULL,
                                             x_tp_sequence_number             => NULL,
                                             x_disb_gross_amt                 => l_disb_gross_amt,
                                             x_fee_1                          => NULL,
                                             x_fee_2                          => NULL,
                                             x_disb_net_amt                   => l_disb_gross_amt,
                                             x_disb_date                      => TRUNC(SYSDATE),
                                             x_trans_type                     => p_award_type,
                                             x_elig_status                    => NULL,
                                             x_elig_status_date               => NULL,
                                             x_affirm_flag                    => NULL,
                                             x_hold_rel_ind                   => NULL,
                                             x_manual_hold_ind                => NULL,
                                             x_disb_status                    => NULL,
                                             x_disb_status_date               => NULL,
                                             x_late_disb_ind                  => NULL,
                                             x_fund_dist_mthd                 => NULL,
                                             x_prev_reported_ind              => NULL,
                                             x_fund_release_date              => NULL,
                                             x_fund_status                    => NULL,
                                             x_fund_status_date               => NULL,
                                             x_fee_paid_1                     => NULL,
                                             x_fee_paid_2                     => NULL,
                                             x_cheque_number                  => NULL,
                                             x_ld_cal_type                    => p_ld_cal_type,
                                             x_ld_sequence_number             => p_ld_sequence_number,
                                             x_disb_accepted_amt              => l_disb_gross_amt,
                                             x_disb_paid_amt                  => NULL,
                                             x_rvsn_id                        => NULL,
                                             x_int_rebate_amt                 => NULL,
                                             x_force_disb                     => NULL,
                                             x_min_credit_pts                 => NULL,
                                             x_disb_exp_dt                    => NULL,
                                             x_verf_enfr_dt                   => NULL,
                                             x_fee_class                      => rec_c_igf_sp_std_fc.fee_class,
                                             x_show_on_bill                   => l_include_as_plncrd,
                                             x_mode                           => 'R',
                                             x_attendance_type_code           => NULL,
                                             x_base_attendance_type_code      => NULL,
                                             x_payment_prd_st_date            => NULL,
                                             x_change_type_code               => NULL,
                                             x_fund_return_mthd_code          => NULL,
                                             x_direct_to_borr_flag            => 'N'
                                          );

              fnd_message.set_name('IGF','IGF_SP_CREATE_DISB');
              fnd_message.set_token('DISB_TYPE',lookup_desc('IGF_DB_TRANS_TYPE',p_award_type));
              i := i+1;
              l_v_msg(i) := fnd_message.get;
              i := i+1;
              l_v_msg(i) := g_v_disb_fee_class||' : '|| igs_fi_gen_gl.get_lkp_meaning('FEE_CLASS',rec_c_igf_sp_std_fc.fee_class);
              i := i+1;
              l_v_msg(i) := g_v_disb_amount||' : '|| l_disb_gross_amt;
              IF p_award_type = 'A' THEN
                create_disb_dtl (l_award_id, l_n_disb_num);
              END IF;
            END IF;
          END IF;
          CLOSE c_aw_awd_disb;
        END LOOP;
        CLOSE c_igf_sp_std_fc;


        -- if the existing awards are updated then the boolean variable is set to TRUE
        -- log the existing award amount and the newly created award amount
        -- If the award is updated then the message needs to be logged in the log file first
        -- then the Award ID needs to be logged
        -- Once the Award ID is logged, then the messages from the table needs to be logged in the log file
        IF l_v_upd_msg_text IS NOT NULL THEN
          fnd_file.put_line(fnd_file.log,l_v_upd_msg_text);
          i := i+1;
          l_v_msg(i) := g_v_ext_award_amount||' : '|| l_n_before_awd_amt;
          i := i+1;
          l_v_msg(i) := g_v_upd_award_amount||' : '|| get_award_amount(l_award_id);
        ELSE
          -- When a
          IF (g_b_award_updated) THEN
            i := i+1;
            l_v_msg(i) := g_v_ext_award_amount||' : '|| l_n_before_awd_amt;
            i := i+1;
            l_v_msg(i) := g_v_upd_award_amount||' : '|| get_award_amount(l_award_id);
            g_b_award_updated := FALSE;
          ELSE
            i := i+1;
            l_v_msg(i) := g_v_award_amount||' : '|| get_award_amount(l_award_id);
          END IF;
        END IF;
        log_parameters(g_v_award_id,l_award_id);
        l_v_upd_msg_text := NULL;


        IF l_v_msg.COUNT > 0 THEN
          FOR i IN l_v_msg.FIRST .. l_v_msg.LAST LOOP
            IF l_v_msg.EXISTS(i) THEN
              IF l_v_msg(i) IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log,l_v_msg(i));
              END IF;
            END IF;
          END LOOP;
          -- Once the messages are logged clear the table contents
          l_v_msg := l_v_msg_null;
        ELSE
          fnd_message.set_name('IGF','IGF_SP_AWD_NOT_UPDATED');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          log_parameters(g_v_award_id,l_award_id);
        END IF;
      ELSE
        fnd_message.set_name('IGF','IGF_SP_AWD_NOT_UPDATED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        log_parameters(g_v_award_id,l_award_id);
      END IF;-- check for manual update
    END LOOP;
    CLOSE c_manual_update;

    -- if no record exist in igf_aw_award for rec_sp_std_dtls.base_id, rec_sp_std_dtls.fund_id
    -- create the record in igf_aw_award
    IF l_rec_count = 0 and p_award_type = 'A' THEN
      IF NOT check_eligibility (p_person_id,
                                p_min_attendance_type,
                                p_min_credit_points,
                                p_ld_cal_type,
                                p_ld_sequence_number) THEN
        log_parameters(g_v_disb_fee_class,NULL);
        fnd_message.set_name('IGF','IGF_SP_ELGB_FAIL');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      ELSE
        create_aw_award (p_fund_id => p_fund_id,
                         p_base_id => p_base_id,
                         p_ld_cal_type => p_ld_cal_type,
                         p_ld_sequence_number => p_ld_sequence_number,
                         p_fee_type => p_fee_type,
                         p_spnsr_stdnt_id => p_spnsr_stdnt_id,
                         p_award_type => p_award_type,
                         p_person_id => p_person_id,
                         p_chk_elig => 'Y');
      END IF;
   ELSIF l_rec_count = 0 and p_award_type = 'P' THEN
     create_aw_award (p_fund_id => p_fund_id,
                      p_base_id => p_base_id,
                      p_ld_cal_type => p_ld_cal_type,
                      p_ld_sequence_number => p_ld_sequence_number,
                      p_fee_type => p_fee_type,
                      p_spnsr_stdnt_id => p_spnsr_stdnt_id,
                      p_award_type => p_award_type,
                      p_person_id => p_person_id,
                      p_chk_elig => 'N');
   END IF;

  EXCEPTION
    --  close open cursor
    WHEN OTHERS THEN
      IF c_manual_update%ISOPEN THEN
        CLOSE c_manual_update;
      END IF;
      RAISE;
  END loop_thru_spnsr_dtl_pvt;

  PROCEDURE loop_thru_spnsr_dtl (p_person_id           IN igs_pe_person.person_id%TYPE,
                                 p_cal_type           IN igs_ca_inst.cal_type%TYPE,
                                 p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                                 p_award_type         IN VARCHAR2,
                                 p_fund_id            IN igf_aw_fund_mast.fund_id%TYPE,
                                 p_ld_cal_type        IN igs_ca_inst.cal_type%TYPE,
                                 p_ld_sequence_number IN igs_ca_inst.sequence_number%TYPE)
  AS
    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 2002/01/11
    --
    --Purpose:  Created as part of the build for DLD Sponsorship
    --          this is the local procedure to create_award_disb to loop thru the sponsor
    --          detail for the passed person id
    --
    --          parameter description:
    --          p_person_id              - Person ID
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --vchappid    22-Jun-2003     Bug 2881654, Log file format is revamped
    --smadathi    31-Jun-2002     Bug 2387604. Modified the logging of messages. Logging
    --                            associated with a person , a term grouped together.
    --smadathi    31-May-2002     Bug 2387344. Cursor c_sp_std_dtls modified to consider all
    --                            term calendars and person id's if both are not provided.
    --smadathi    17-May-2002     Bug 2369173.  Added ld_cal_type and ld_sequence_number as
    --                            parameters to the procedure.
    -------------------------------------------------------------------------------------
      -- cursor to get all the sponsor detail for the person id
      CURSOR c_sp_std_dtls (cp_person_id igs_pe_person.person_id%TYPE,
                            cp_awd_cal_type igs_ca_inst.cal_type%TYPE,
                            cp_awd_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                            cp_fund_id igf_aw_fund_mast.fund_id%TYPE,
                            cp_v_disc_fund igf_aw_fund_mast.discontinue_fund%TYPE) IS
       SELECT rel.*,
              fund.fund_code,
              fund.description fund_desc,
              fund.fee_type
       FROM   igf_sp_stdnt_rel rel,
              igf_aw_fund_mast fund
       WHERE  rel.fund_id = fund.fund_id
       AND    rel.fund_id = cp_fund_id
       AND    fund.discontinue_fund <> cp_v_disc_fund
       AND    (
               (p_ld_cal_type IS NOT NULL AND rel.ld_cal_type  = p_ld_cal_type)
                OR
               (p_ld_cal_type IS NULL)
              )
       AND    (
               (p_ld_sequence_number IS NOT NULL AND rel.ld_sequence_number = p_ld_sequence_number)
                OR
               (p_ld_sequence_number IS NULL)
              )
       AND    (
               (cp_person_id IS NOT NULL AND person_id = cp_person_id)
                OR
                (cp_person_id IS NULL)
              )
       AND    EXISTS ( SELECT '1'
                       FROM   igf_ap_fa_base_rec
                       WHERE  base_id = rel.base_id
                       AND    person_id = rel.person_id
                       AND    ci_cal_type = cp_awd_cal_type
                       AND    ci_sequence_number = cp_awd_ci_sequence_number
                     )
       ORDER BY fund.fund_code;

      rec_sp_std_dtls c_sp_std_dtls%ROWTYPE;
  BEGIN
     -- get the stud sponsor detail
     OPEN c_sp_std_dtls (p_person_id, p_cal_type, p_ci_sequence_number, p_fund_id,'Y');
     LOOP
     FETCH c_sp_std_dtls INTO rec_sp_std_dtls;
     EXIT WHEN c_sp_std_dtls%NOTFOUND;
       -- initialize the Record found parameter when there are records matching to the input criteria
       g_b_records_found := TRUE;

       -- When the user has not passed either the Person ID or Person Group then get the Person Number for the records
       -- found matching to the input criteria
       IF p_person_id IS NULL THEN
         g_v_person_number := get_person_number(rec_sp_std_dtls.person_id);
       END IF;

       --Log sponsor details and the disbursment amount
       log_parameters(g_v_spnr_cd,rec_sp_std_dtls.fund_code);
       log_parameters(g_v_spnr_desc,rec_sp_std_dtls.fund_desc);
       log_parameters(g_v_person_num_pmt,g_v_person_number);
       log_parameters(g_v_term,get_cal_inst_dtls(rec_sp_std_dtls.ld_cal_type, rec_sp_std_dtls.ld_sequence_number));

       -- check for the award type whether it is A or P, if A, check for eligibility
       IF  p_award_type = 'A' THEN
         -- check for eligibility
         IF NOT check_eligibility (rec_sp_std_dtls.person_id,
                                   rec_sp_std_dtls.min_attendance_type,
                                   rec_sp_std_dtls.min_credit_points,
                                   rec_sp_std_dtls.ld_cal_type,
                                   rec_sp_std_dtls.ld_sequence_number) THEN
           log_parameters(g_v_disb_fee_class,NULL);
           fnd_message.set_name('IGF','IGF_SP_ELGB_FAIL');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.put_line(fnd_file.log, RPAD('-',77,'-'));
           EXIT;
         ELSE
           loop_thru_spnsr_dtl_pvt(p_person_id  => rec_sp_std_dtls.person_id,
                                   p_award_type => p_award_type,
                                   p_base_id    => rec_sp_std_dtls.base_id,
                                   p_fund_id    => rec_sp_std_dtls.fund_id,
                                   p_min_attendance_type => rec_sp_std_dtls.min_attendance_type,
                                   p_min_credit_points   => rec_sp_std_dtls.min_credit_points,
                                   p_ld_cal_type         => rec_sp_std_dtls.ld_cal_type,
                                   p_ld_sequence_number  => rec_sp_std_dtls.ld_sequence_number,
                                   p_fee_type            => rec_sp_std_dtls.fee_type,
                                   p_spnsr_stdnt_id      => rec_sp_std_dtls.spnsr_stdnt_id,
                                   p_n_total_spnsr_amt   => rec_sp_std_dtls.tot_spnsr_amount);
         END IF;
       ELSIF p_award_type = 'P' THEN
         loop_thru_spnsr_dtl_pvt(p_person_id  => rec_sp_std_dtls.person_id,
                                 p_award_type => p_award_type,
                                 p_base_id    => rec_sp_std_dtls.base_id,
                                 p_fund_id    => rec_sp_std_dtls.fund_id,
                                 p_min_attendance_type => rec_sp_std_dtls.min_attendance_type,
                                 p_min_credit_points   => rec_sp_std_dtls.min_credit_points,
                                 p_ld_cal_type         => rec_sp_std_dtls.ld_cal_type,
                                 p_ld_sequence_number  => rec_sp_std_dtls.ld_sequence_number,
                                 p_fee_type            => rec_sp_std_dtls.fee_type,
                                 p_spnsr_stdnt_id      => rec_sp_std_dtls.spnsr_stdnt_id,
                                 p_n_total_spnsr_amt   => rec_sp_std_dtls.tot_spnsr_amount);
       END IF;
       fnd_file.put_line(fnd_file.log, RPAD('-',77,'-'));
     END LOOP;
     CLOSE c_sp_std_dtls;
  EXCEPTION
    --  close open cursor
    WHEN OTHERS THEN
      IF c_sp_std_dtls%ISOPEN THEN
        CLOSE c_sp_std_dtls;
      END IF;
      RAISE;
  END loop_thru_spnsr_dtl;

  --  main procedure which is called from the concurrent manager
  PROCEDURE create_award_disb
              (errbuf               OUT NOCOPY VARCHAR2,
               retcode              OUT NOCOPY NUMBER,
               p_award_year         IN  VARCHAR2,
               p_term_calendar      IN  VARCHAR2,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_person_group_id    IN  igs_pe_prsid_grp_mem.group_id%TYPE,
               p_fund_id            IN  igf_sp_stdnt_rel.fund_id%TYPE,
               p_award_type         IN  igf_aw_awd_disb.trans_type%TYPE,
               p_test_mode          IN  VARCHAR2,
               p_org_id             IN  NUMBER)
  AS
  ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This is the main procedure called from the concurrent job.
  --          This procedure will creat both Award and disbursement
  --          for a fund in FA system. Process will also check for the eligibility
  --          and validations before awarding the Sponsor amount to the students.
  --          Awarding money to the students can be done manually apart from awarding
  --          money through a batch process.
  --
  --          parameter description:
  --
  --          errbuf                   - standard conc. req. paramater
  --          retcode                  - standard conc. req. paramater
  --          p_award_year             - mandatory paramater
  --                                     award year instnace for which sponsor and
  --                                     student relation info. should be rolled over
  --          p_term_calendar          - indicates the time period (term calendar) in
  --                                     which all students should awarded
  --          p_person_id              - Person ID for whom financial aid should be
  --                                     created in the FA system
  --          p_person_group_id        - Indicates Person Group Id for which financial
  --                                     aids should be created in the FA system
  --          p_fund_id                - Optional parameter
  --                                     indicates the sponsor id for whom all the award
  --                                     should be initiated
  --          p_award_type             - indicates the award_type, whether the financial
  --                                     aid should be awarded to the students in Planned
  --                                     or Actual mode. P- Planned A- Actual
  --          p_test_mode              - mandatory parameter
  --                                   - indicates whether the process is executed in
  --                                     Actual or Test mode
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
  --vvutukur    20-Jul-2003     Enh#3038511.FICR106 Build. Added call to generic procedure
  --                            igs_fi_crdapi_util.get_award_year_status to validate Award Year Status.
  --vchappid    22-Jun-2003     Bug 2881654, Log file format is revamped, Dynamic Person Group feature is introduced,
  --                            Sponsor Code parameter is made optional
  --pathipat    25-Apr-2003     Enh 2831569 - Commercial Receivables build
  --                            Added check for manage_accounts - call to chk_manage_account()
   --smadathi    30-Jan-2002     Bug 2620302. Cursor c_person_id_grp select modified
   --                            to fetch the records from view igs_pe_prsid_grp_mem
   --                            instead of igs_pe_prsid_grp_mem_v. This fix is done to remove
   --                            Non-mergablity and to reduce shared memory. Also modified the
   --                            cursor c_igs_lookups modified to fetch only active look up codes
  --smadathi    02-jul-2002     Bug 2427996. Cursor c_person_id_grp modified to select only active person id
  --                            belonging to the group.  The logic for logging  the message IGF_SP_NO_PERSON
  --                            has been removed.
  --smadathi    31-May-2002     Bug 2387344. Cursor c_igs_lookups , c_igs_pe_persid_group , c_igf_aw_fund_mast
  --                            added. Also logic of logging of all parameters added.
  --smadathi    17-May-2002     Bug 2369173.  Modified to hadnle the cases when
  --                            term calendar was provided as parameter to the process
  -------------------------------------------------------------------------------------

    --  variables to store cal type and seq num passed by award year
    l_cal_type igs_ca_inst.cal_type%TYPE;
    l_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_ld_cal_type igs_ca_inst.cal_type%TYPE;
    l_ld_sequence_number igs_ca_inst.sequence_number%TYPE;

    l_v_awd_yr_status_cd   igf_ap_batch_aw_map.award_year_status_code%TYPE;

  -- cursor to select fund code from igf_aw_fund_mast to get fund code for fund id parameter
  -- This cursor definition is public to this package body;
  CURSOR   c_igf_aw_fund_mast(cp_fund_id          igf_aw_fund_mast.fund_id%TYPE,
                              cp_cal_type         igs_ca_inst.cal_type%TYPE,
                              cp_sequence_number  igs_ca_inst.sequence_number%TYPE,
                              cp_v_sys_fund_type   igf_aw_fund_cat.sys_fund_type%TYPE,
                              cp_v_disc_fund      igf_aw_fund_mast.discontinue_fund%TYPE)
  IS
  SELECT   fmast.*
  FROM     igf_aw_fund_mast fmast ,
           igf_aw_fund_cat fcat
  WHERE    fmast.fund_code   = fcat.fund_code
  AND      (fmast.fund_id   = cp_fund_id OR cp_fund_id IS NULL)
  AND      fmast.ci_cal_type        = cp_cal_type
  AND      fmast.ci_sequence_number = cp_sequence_number
  AND      fcat.sys_fund_type = cp_v_sys_fund_type
  AND      fmast.discontinue_fund <> cp_v_disc_fund
  ORDER BY fund_id;

    -- cursor variable for c_igf_aw_fund_mast
    l_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;

    -- Cursor for validating the Person Id Group
    CURSOR c_pers_id_grp(cp_n_pers_grp_id   igs_pe_all_persid_group_v.group_id%TYPE)
    IS
    SELECT group_cd, closed_ind
    FROM igs_pe_all_persid_group_v
    WHERE group_id = cp_n_pers_grp_id;
    l_c_pers_id_grp   c_pers_id_grp%ROWTYPE;

    CURSOR c_validate_fund_id(cp_n_fund_id igf_aw_fund_mast.fund_id%TYPE)
    IS
    SELECT fund_code, discontinue_fund
    FROM igf_aw_fund_mast
    WHERE fund_id = cp_n_fund_id;
    l_rec_c_validate_fund_id c_validate_fund_id%ROWTYPE;

    l_v_fund_code igf_aw_fund_mast.fund_code%TYPE;


    l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
    l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;

    -- REF CURSOR for dynamic person group.
    TYPE person_grp_ref_cur_type IS REF CURSOR;
    c_ref_person_grp person_grp_ref_cur_type;
    l_dynamic_sql VARCHAR2(2000);
    l_v_status    VARCHAR2(10);

    -- Record of person_id to get the values of
    TYPE person_grp_rec_type IS RECORD (l_n_person_id igs_pe_prsid_grp_mem.person_id%TYPE );
    rec_person_grp person_grp_rec_type;

    l_b_award_year    BOOLEAN;
    l_b_term          BOOLEAN;
    l_b_person_number BOOLEAN;
    l_b_person_group  BOOLEAN;
    l_b_sponsor_code  BOOLEAN;
    l_b_award_type    BOOLEAN;
    l_b_test_mode     BOOLEAN;
    l_b_param_valid   BOOLEAN := TRUE;
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN

  --  set the org id
  igf_aw_gen.set_org_id(p_org_id);
  retcode := 0 ;
  initialize;

  IF (p_award_year IS NOT NULL) THEN
    l_cal_type := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));
    g_v_log_text := get_cal_inst_dtls(l_cal_type,l_sequence_number);
    IF g_v_log_text IS NOT NULL THEN
      l_b_award_year := TRUE;
    ELSE
      l_b_award_year := FALSE;
    END IF;
  ELSE
    l_b_award_year := FALSE;
  END IF;
  log_parameters(g_v_award_yr,g_v_log_text);

  IF p_term_calendar IS NOT NULL THEN
    l_ld_cal_type := LTRIM(RTRIM(SUBSTR(p_term_calendar,1,10))) ;
    l_ld_sequence_number := TO_NUMBER(SUBSTR(p_term_calendar,12)) ;
    -- get the alternate code , start date and end date for the term calendar type and sequence no passed to the process
    g_v_log_text := get_cal_inst_dtls(l_ld_cal_type,l_ld_sequence_number);
    IF g_v_log_text IS NOT NULL THEN
      l_b_term := TRUE;
    ELSE
      l_b_term := FALSE;
    END IF;
  ELSE
    g_v_log_text := NULL;
  END IF;
  log_parameters(g_v_term,g_v_log_text);

  IF p_person_id IS NOT NULL THEN
    g_v_person_number := get_person_number(p_person_id);
    IF g_v_person_number IS NULL THEN
      l_b_person_number := FALSE;
    ELSE
      l_b_person_number := TRUE;
    END IF;
  END IF;
  log_parameters(g_v_person_num_pmt,g_v_person_number);

  -- validate if the person group if passed is a valid person group
  IF p_person_group_id IS NOT NULL THEN
    OPEN c_pers_id_grp(p_person_group_id);
    FETCH c_pers_id_grp INTO l_c_pers_id_grp;
    IF c_pers_id_grp%NOTFOUND THEN
      l_b_person_group := FALSE;
      g_v_log_text := NULL;
    ELSE
      l_b_person_group := TRUE;
      g_v_log_text := l_c_pers_id_grp.group_cd;
    END IF;
    CLOSE c_pers_id_grp;
  ELSE
    g_v_log_text := NULL;
  END IF;
  log_parameters(g_v_person_group,g_v_log_text);

  -- validate if the fund id if passed is existing in the Fund Master table
  IF p_fund_id IS NOT NULL THEN
    OPEN c_validate_fund_id(p_fund_id);
    FETCH c_validate_fund_id INTO l_rec_c_validate_fund_id;
    IF c_validate_fund_id%NOTFOUND THEN
      l_b_sponsor_code := FALSE;
      g_v_log_text := NULL;
    ELSE
      IF l_rec_c_validate_fund_id.discontinue_fund = 'Y' THEN
        l_b_sponsor_code := FALSE;
        g_v_log_text := NULL;
      ELSE
        l_b_sponsor_code := TRUE;
        g_v_log_text := l_rec_c_validate_fund_id.fund_code;
      END IF;
    END IF;
  ELSE
    g_v_log_text := NULL;
  END IF;
  log_parameters(g_v_spnr_cd,g_v_log_text);

  IF p_award_type IS NOT NULL THEN
    IF (p_award_type NOT IN ('A','P')) THEN
      l_b_award_type := FALSE;
      g_v_log_text := NULL;
    ELSE
      l_b_award_type := TRUE;
      g_v_log_text := lookup_desc('IGF_DB_TRANS_TYPE',p_award_type);
    END IF;
  ELSE
    l_b_award_type := FALSE;
    g_v_log_text := NULL;
  END IF;
  log_parameters(g_v_award_type,g_v_log_text);

  IF p_test_mode IS NOT NULL THEN
    IF (p_test_mode NOT IN ('Y','N')) THEN
      l_b_test_mode := FALSE;
      g_v_log_text := NULL;
    ELSE
      l_b_test_mode := TRUE;
      g_v_log_text := igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_test_mode);
    END IF;
  ELSE
    l_b_test_mode := FALSE;
    g_v_log_text := NULL;
  END IF;
  log_parameters(g_v_test_mode,g_v_log_text);
  fnd_file.put_line(fnd_file.log, RPAD('-',77,'-'));

  -- check if the input parameters are not valid
  -- when not valid then return from the process after logging which all parameters are not valid
  IF NOT l_b_award_year THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_award_yr);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_term THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_term);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_person_number THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_person_num_pmt);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- If the person group validation has failed earlier or the person group
  -- is closed, then error message is logged
  IF NOT l_b_person_group OR NVL(l_c_pers_id_grp.closed_ind,'N') = 'Y' THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_person_group);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_sponsor_code THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_spnr_cd);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_award_type THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_award_type);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_test_mode THEN
    l_b_param_valid := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_test_mode);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF NOT l_b_param_valid THEN
    RETURN;
  END IF;

  -- validate the person_id and person_group_id parameters
  -- both p_person_id and person_group_id cannot be passed at a time
  IF p_person_id IS NOT NULL AND p_person_group_id IS NOT NULL THEN
    retcode := 2;
    -- Removed assignment of error message to errbuf to prevent dual messages appearing in the log
    fnd_message.set_name('IGS','IGS_FI_PRS_OR_PRSIDGRP');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN;
  END IF;

  --Validate the Award Year Status. If the status is not open, log the message in log file and
  --complete the process with error.
  l_v_message_name := NULL;
  igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  l_cal_type,
                                            p_n_awd_seq_number   =>  l_sequence_number,
                                            p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                            p_v_message_name     =>  l_v_message_name
                                           );
  IF l_v_message_name IS NOT NULL THEN
    IF l_v_message_name = 'IGF_SP_INVALID_AWD_YR_STATUS' THEN
      fnd_message.set_name('IGF',l_v_message_name);
    ELSE
      fnd_message.set_name('IGS',l_v_message_name);
    END IF;
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    retcode := 2;
    RETURN;
  END IF;

  -- Obtain the value of manage_accounts in the System Options form
  -- If it is null, then this process is not available, so error out.
  igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                               p_v_message_name => l_v_message_name);
  IF (l_v_manage_acc IS NULL) THEN
    retcode := 2;
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  END IF;

  -- Get the select statement when the person id Group is provided
  IF p_person_group_id IS NOT NULL THEN
    --Bug #5021084
    l_dynamic_sql := igf_ap_ss_pkg.get_pid(p_person_group_id, l_v_status,lv_group_type);

    IF l_v_status <> 'S' THEN
      fnd_file.put_line(fnd_file.log, l_dynamic_sql);
      retcode := 2;
      RETURN;
    END IF;
  END IF;

  FOR l_c_igf_aw_fund_mast IN c_igf_aw_fund_mast (p_fund_id,l_cal_type,l_sequence_number,'SPONSOR','Y')
  LOOP

    IF p_person_group_id IS NOT NULL THEN
      -- Open the REF CURSOR for above derived SQL statement ( l_dynamic_sql )
      -- looping across all the valid person ids in the group.

      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN c_ref_person_grp FOR l_dynamic_sql USING p_person_group_id;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN c_ref_person_grp FOR l_dynamic_sql;
      END IF;

      LOOP
      FETCH c_ref_person_grp INTO rec_person_grp;
      EXIT WHEN c_ref_person_grp%NOTFOUND;
        -- While processing for a group get the person number for the current person and stroe it in the
        -- package variable.
        -- When the person id is passed as input parameter then while logging the process parameters, this global
        -- variable is initialized and has a value.
        g_v_person_number := get_person_number(rec_person_grp.l_n_person_id);
        loop_thru_spnsr_dtl (rec_person_grp.l_n_person_id, l_cal_type, l_sequence_number, p_award_type, l_c_igf_aw_fund_mast.fund_id,l_ld_cal_type,l_ld_sequence_number);
      END LOOP;
      CLOSE c_ref_person_grp;
    ELSE
      -- When the user has not provided either Person Id od Person Group then the process should assign awards for
      -- all eligible persons. This is handled in the local procedure loop_thru_spnsr_dtl main cursor.
      loop_thru_spnsr_dtl(p_person_id, l_cal_type, l_sequence_number, p_award_type,l_c_igf_aw_fund_mast.fund_id,l_ld_cal_type,l_ld_sequence_number);
    END IF;

    -- Commit the transactions for each Sponsor and when test_run mode is 'N'
    -- Should Rollback the transactions to avoid redo log error
    IF p_test_mode = 'N' THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  END LOOP;

  -- if the job is run with test_mode set to Y, rollback the transaction
  IF g_b_records_found THEN
    IF p_test_mode = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'');
      fnd_message.set_name('IGF','IGF_SP_TEST_MODE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;
  ELSE
    fnd_file.put_line(fnd_file.log,'');
    fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    fnd_file.put_line(fnd_file.log,SQLERRM);
    retcode := 2 ;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','CREATE_AWARD_DISB');
    errbuf := fnd_message.get||' - '||SQLERRM;
    igs_ge_msg_stack.conc_exception_hndl ;
  END create_award_disb;
END igf_sp_award;

/
