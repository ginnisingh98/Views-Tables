--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_CHG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_CHG_FILE" AS
/* $Header: IGFSL24B.pls 120.7 2006/08/03 11:55:35 tsailaja noship $ */
/*
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
--Purpose:
-- Invoked     : From concurrent manager
-- Function    : FFELP Change Send File Creation
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who           When                What
--tsailaja      25-Jul-2006         Bug #5337555 FA 163 Included 'GPLUSFL'
--                                  Loan type validation
--bvisvana      24-Nov-2005         Bug # 4256897 - Added anticip_compl_date to the
                                    TYPE lorlar_recTyp. Also added anticip_compl_date to CURSOR c_lor_lar
--bvisvana      18-Jul-2005         4132989 - Added sch_cert_date,loan_per_end_date,loan_per_begin_date to the
--                                  TYPE lorlar_recTyp. Also added sch_cert_date to CURSOR c_lor_lar
--mnade         27-Jan-2005         Bug - 4146934
--                                  Added 'G' Filter on the c_lor_lar cursor to avoid picking up
--                                  all loans.
-------------------------------------------------------------------
*/

  TYPE lorlar_recTyp IS RECORD (
    cal_type            igs_ca_inst_all.cal_type%TYPE,
    sequence_number     igs_ca_inst_all.sequence_number%TYPE,
    fund_id             igf_aw_fund_mast_all.fund_id%TYPE,
    discontinue_fund    igf_aw_fund_mast_all.discontinue_fund%TYPE,
    fed_fund_code       igf_aw_fund_cat_all.fed_fund_code%TYPE,
    base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
    award_id            igf_aw_award_all.award_id%TYPE,
    loan_id             igf_sl_loans_all.loan_id%TYPE,
    loan_number         igf_sl_loans_all.loan_number%TYPE,
    loan_status         igf_sl_loans_all.loan_status%TYPE,
    loan_chg_status     igf_sl_loans_all.loan_chg_status%TYPE,
    loan_active         igf_sl_loans_all.active%TYPE,
    anticip_compl_date  igf_sl_lor_all.anticip_compl_date%TYPE,
    sch_cert_date       igf_sl_lor_all.sch_cert_date%TYPE,
    loan_per_begin_date igf_sl_loans_all.loan_per_begin_date%TYPE,
    loan_per_end_date   igf_sl_loans_all.loan_per_end_date%TYPE,
    cl_rec_status       igf_sl_lor_all.cl_rec_status%TYPE,
    prc_type_code       igf_sl_lor_all.prc_type_code%TYPE,
    cl_version          igf_sl_cl_setup_all.cl_version%TYPE
  );

  -- procedure for enabling statement level logging
  PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                         p_v_string IN VARCHAR2
                       );

  PROCEDURE log_parameters ( p_v_param_typ IN VARCHAR2,
                             p_v_param_val IN VARCHAR2
                           ) ;

  PROCEDURE identify_clchsn_dtls
           (
              p_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
              p_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
              p_n_fund_id         IN  igf_aw_fund_mast_all.fund_id%TYPE,
              p_n_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
              p_n_loan_id         IN  igf_sl_loans_all.loan_id%TYPE
           );
  FUNCTION get_base_id
           (
             p_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
             p_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
             p_n_person_id       IN  igf_ap_fa_base_rec_all.person_id%TYPE
           )
  RETURN igf_ap_fa_base_rec_all.base_id%TYPE;

  FUNCTION get_person_number (p_n_person_id  IN  igf_ap_fa_base_rec_all.person_id%TYPE)
  RETURN hz_parties.party_number%TYPE;

  FUNCTION  validate_cl_lar (p_rec_lorlar lorlar_recTyp) RETURN BOOLEAN;

  PROCEDURE proc_update_loan_rec(p_loan_rec igf_sl_loans%ROWTYPE);

  PROCEDURE proc_update_clchsn_dtls_rec(p_v_loan_number        IN  igf_sl_loans.loan_number%TYPE                  ,
                                        p_v_change_record_typ  IN  igf_sl_clchsn_dtls.change_record_type_txt%TYPE ,
                                        p_n_disb_num           IN  igf_aw_awd_disb_all.disb_num%TYPE              ,
                                        p_v_send_record_txt    IN  igf_sl_clchsn_dtls.send_record_txt%TYPE
                                        );

  PROCEDURE create_file   (
                           errbuf                OUT  NOCOPY   VARCHAR2,
                           retcode               OUT  NOCOPY   NUMBER,
                           p_v_award_year        IN   VARCHAR2,
                           p_n_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
                           p_n_dummy_1           IN   NUMBER,
                           p_n_base_id           IN   igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_n_dummy_2           IN   NUMBER,
                           p_n_loan_id           IN   igf_sl_loans_all.loan_id%TYPE,
                           p_n_dummy_3           IN   NUMBER,
                           p_n_person_id_grp     IN   igs_pe_persid_group_all.group_id%TYPE,
                           p_v_media_type        IN   igf_lookups_view.lookup_code%TYPE,
                           p_v_school_id         IN   igf_sl_school_codes_v.alternate_identifier%TYPE,
                           p_v_non_ed_branch     IN   igf_sl_school_codes_v.system_id_type%TYPE,
                           p_v_sch_non_ed_branch IN   igf_sl_school_codes_v.alternate_identifier%TYPE
                           ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from concurrent manager (Job IGFSLJ20)
-- Function    :
--
-- Parameters  : p_v_award_year        : IN parameter. Required.
--               p_n_fund_id           : IN parameter
--               p_n_dummy_1           : IN parameter
--               p_n_base_id           : IN parameter
--               p_n_dummy_2           : IN parameter
--               p_n_loan_id           : IN parameter
--               p_n_dummy_3           : IN parameter
--               p_n_person_id_grp     : IN parameter
--               p_v_media_type        : IN parameter. Required.
--               p_v_school_id         : IN parameter. Required.
--               p_v_non_ed_branch     : IN parameter.
--               p_v_sch_non_ed_branch : IN parameter.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--ridas       07-Feb-2006     Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
------------------------------------------------------------------
  CURSOR  c_igf_aw_fund_mast(cp_n_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
  SELECT  fmast.description fund_desc
         ,fmast.ci_cal_type
         ,fmast.ci_sequence_number
  FROM    igf_aw_fund_mast_all fmast
  WHERE   fmast.fund_id = cp_n_fund_id;

  rec_c_igf_aw_fund_mast c_igf_aw_fund_mast%ROWTYPE;

  CURSOR  c_igf_sl_loans(cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
  SELECT  lar.loan_number
         ,lar.award_id
  FROM    igf_sl_loans_all lar
  WHERE   lar.loan_id = cp_n_loan_id;

  rec_c_igf_sl_loans c_igf_sl_loans%ROWTYPE;

  CURSOR c_person_grp (cp_n_person_id_grp igs_pe_persid_group_all.group_id%TYPE) IS
  SELECT pig.group_cd
  FROM   igs_pe_persid_group_all pig
  WHERE  pig.group_id = cp_n_person_id_grp;

  CURSOR c_aw_lookups_view (cp_v_lookup_type     igf_lookups_view.lookup_type%TYPE,
                            cp_v_lookup_code     igf_lookups_view.lookup_code%TYPE,
                            cp_v_cal_type        igs_ca_inst_all.cal_type%TYPE,
                            cp_n_sequence_number igs_ca_inst_all.sequence_number%TYPE
                           ) IS
  SELECT lkups.meaning
  FROM   igf_aw_lookups_view  lkups
  WHERE  lkups.lookup_type     = cp_v_lookup_type
  AND    lkups.lookup_code     = cp_v_lookup_code
  AND    lkups.cal_type        = cp_v_cal_type
  AND    lkups.sequence_number = cp_n_sequence_number
  AND    lkups.enabled_flag    = 'Y'
  ORDER BY lookup_code;

  CURSOR c_school_codes(cp_v_school_id igf_sl_school_codes_v.alternate_identifier%TYPE) IS
  SELECT alternate_identifier
        ,system_id_type
  FROM   igf_sl_school_codes_v
  WHERE  alternate_identifier = cp_v_school_id
  ORDER BY alternate_identifier;

  rec_c_school_codes  c_school_codes%ROWTYPE;

  CURSOR  c_school_opeid(cp_v_school_id igf_sl_school_codes_v.alternate_identifier%TYPE) IS
  SELECT  meaning
  FROM    igf_ap_school_opeid_v
  WHERE   alternate_identifier = cp_v_school_id;

  CURSOR c_sch_non_ed_branch (cp_v_non_ed_branch  igf_sl_school_codes_v.system_id_type%TYPE,
                              cp_v_alt_identifier igf_sl_school_codes_v.alternate_identifier%TYPE
                             ) IS
  SELECT 'x'
  FROM   igf_sl_school_codes_v
  WHERE  system_id_type       = cp_v_non_ed_branch
  AND    alternate_identifier = cp_v_alt_identifier
  ORDER BY alternate_identifier;


  CURSOR  c_recip_dtls( cp_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
                        cp_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
                        cp_c_loan_chg_status IN  igf_sl_loans_all.loan_chg_status%TYPE,
                        cp_v_school_id       IN  igf_sl_school_codes_v.alternate_identifier%TYPE
                      ) IS
  SELECT  DISTINCT lor.relationship_cd
  FROM    igf_sl_lor_all       lor
         ,igf_sl_loans_all     loans
         ,igf_aw_award_all     awd
         ,igf_aw_fund_mast_all fmast
         ,igf_sl_cl_recipient  recip
  WHERE   loans.loan_id                  = lor.loan_id
  AND     loans.loan_chg_status          = cp_c_loan_chg_status
  AND     awd.award_id                   = loans.award_id
  AND     fmast.fund_id                  = awd.fund_id
  AND     fmast.ci_cal_type              = cp_v_cal_type
  AND     fmast.ci_sequence_number       = cp_n_sequence_number
  AND     SUBSTR(loans.loan_number,1, 6) = SUBSTR(cp_v_school_id,1,6)
  AND     recip.relationship_cd          = lor.relationship_cd;


  TYPE ref_CurpersongrpTyp IS REF CURSOR;
  c_dyn_person_grp ref_CurpersongrpTyp;

  l_v_cal_type           igs_ca_inst_all.cal_type%TYPE;
  l_n_sequence_number    igs_ca_inst_all.sequence_number%TYPE;
  l_n_loan_id            igf_sl_loans_all.loan_id%TYPE;
  l_n_base_id            igf_ap_fa_base_rec_all.base_id%TYPE;
  l_n_fund_id            igf_aw_fund_mast_all.fund_id%TYPE;
  l_n_person_id          igf_ap_fa_base_rec_all.person_id%TYPE;
  l_n_person_id_grp      igs_pe_persid_group_all.group_id%TYPE;
  l_v_school_id          igf_sl_school_codes_v.alternate_identifier%TYPE;
  l_v_media_type         igf_lookups_view.lookup_code%TYPE;
  l_v_sch_non_ed_branch  igf_sl_school_codes_v.alternate_identifier%TYPE;
  l_v_non_ed_branch      igf_lookups_view.lookup_code%TYPE;

  l_v_awd_yr_status_cd   igf_ap_batch_aw_map.award_year_status_code%TYPE;
  l_v_alt_code           igs_ca_inst_all.alternate_code%TYPE;
  l_v_fund_desc          igf_aw_fund_mast_all.description%TYPE;
  l_v_group_cd           igs_pe_persid_group_all.group_cd%TYPE;
  l_v_loan_number        igf_sl_loans_all.loan_number%TYPE;
  l_c_flag               VARCHAR2(1);
  l_v_sql                VARCHAR2(32767);
  l_v_status             VARCHAR2(1);
  l_v_meaning            igf_lookups_view.meaning%TYPE;
  l_v_message_name       fnd_new_messages.message_name%TYPE;
  l_n_request_id         NUMBER;
  l_n_ctr_recip          NUMBER;
  lv_group_type          igs_pe_persid_group_v.group_type%TYPE;

  e_skip            EXCEPTION;

BEGIN
  igf_aw_gen.set_org_id(NULL);
  retcode := 0 ;

  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' Entered Procedure create_file: The input parameters are '||
                           ' p_v_award_year        : '  ||p_v_award_year         ||
                           ' p_n_fund_id           : '  ||p_n_fund_id            ||
                           ' p_n_base_id           : '  ||p_n_base_id            ||
                           ' p_n_loan_id           : '  ||p_n_loan_id            ||
                           ' p_n_person_id_grp     : '  ||p_n_person_id_grp      ||
                           ' p_v_media_type        : '  ||p_v_media_type         ||
                           ' p_v_school_id         : '  ||p_v_school_id          ||
                           ' p_v_non_ed_branch     : '  ||p_v_non_ed_branch      ||
                           ' p_v_sch_non_ed_branch : '  ||p_v_sch_non_ed_branch
            );
  -- derive the cal type and sequence number for the input award year
  l_v_cal_type           := LTRIM(RTRIM(SUBSTR(p_v_award_year,1,10)));
  l_n_sequence_number    := TO_NUMBER(SUBSTR(p_v_award_year,11));
  -- assigning the passed input parameters to local variables
  l_n_fund_id            := p_n_fund_id;
  l_n_base_id            := p_n_base_id;
  l_n_loan_id            := p_n_loan_id;
  l_n_person_id_grp      := p_n_person_id_grp;
  l_v_alt_code           := igf_gr_gen.get_alt_code(l_v_cal_type,l_n_sequence_number);
  l_v_media_type         := p_v_media_type ;
  l_v_school_id          := p_v_school_id  ;
  l_v_non_ed_branch      := p_v_non_ed_branch;
  l_v_sch_non_ed_branch  := p_v_sch_non_ed_branch;

  ----------------------- parameter logging logic starts here---------------------------
  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' Start of Parameter logging'
            );

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
  fnd_file.new_line(fnd_file.log,1);

  OPEN  c_igf_aw_fund_mast (cp_n_fund_id => l_n_fund_id);
  FETCH c_igf_aw_fund_mast INTO rec_c_igf_aw_fund_mast;
  CLOSE c_igf_aw_fund_mast;

  l_v_fund_desc     := rec_c_igf_aw_fund_mast.fund_desc;

  OPEN   c_igf_sl_loans (cp_n_loan_id => l_n_loan_id);
  FETCH  c_igf_sl_loans INTO rec_c_igf_sl_loans;
  CLOSE  c_igf_sl_loans;

  l_v_loan_number     := rec_c_igf_sl_loans.loan_number;

  OPEN  c_person_grp (cp_n_person_id_grp => l_n_person_id_grp);
  FETCH c_person_grp INTO l_v_group_cd;
  CLOSE c_person_grp;

  OPEN  c_school_opeid (cp_v_school_id => l_v_school_id);
  FETCH c_school_opeid INTO l_v_meaning;
  CLOSE c_school_opeid ;

  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),40),
                   p_v_param_val => l_v_alt_code
                 );
  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_TYPE'),40),
                   p_v_param_val => l_v_fund_desc
                 );
  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),40),
                   p_v_param_val => igf_gr_gen.get_per_num(l_n_base_id)
                 );
  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'),40),
                   p_v_param_val => l_v_loan_number
                 );
  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),40),
                   p_v_param_val => l_v_group_cd
                 );

  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','MEDIA_TYPE'),40),
                   p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_MEDIA_TYPE',l_v_media_type)
                 );

  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SCHOOL_ID'),40),
                   p_v_param_val => l_v_meaning
                 );

  log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SCH_NON_ED_BRANCH'),40),
                   p_v_param_val => l_v_sch_non_ed_branch
                 );

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
  fnd_file.new_line(fnd_file.log,1);
  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' End of Parameter logging'
            );
  -- parameter logging logic ends here -------------------------------------------------

  -- Validation of Required parameters---------------------------------------------------
  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' Validation of Required parameters'
            );
  IF p_v_award_year IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_REQ_PARAM');
    fnd_message.set_token('PARAM',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;

  IF l_v_media_type IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_REQ_PARAM');
    fnd_message.set_token('PARAM',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','MEDIA_TYPE'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;

  IF l_v_school_id IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_REQ_PARAM');
    fnd_message.set_token('PARAM',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SCHOOL_ID'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;

  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' End of Validation of Required parameters'
            );
  ----------------------------- Validation of Required parameters ends here-------------

  ---------------------------- Validation of parameters----------------------------------
  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' Start of Validation of input parameters'
            );
  -- Validate if the passed award year is valid or not
  IF l_v_alt_code IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;
  --Validate the Award Year Status. If the status is not open, log the message in log file and
  --complete the process with error.
  l_v_message_name := NULL;
  igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  l_v_cal_type,
                                            p_n_awd_seq_number   =>  l_n_sequence_number,
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

  -- person id and person group id are mutually exclusive. Hence if both are
  -- provided error out of the process
  IF l_n_person_id_grp IS NOT NULL AND l_n_base_id IS NOT NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
    fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
    fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;

  -- loan id and person group id are mutually exclusive. Hence if both are
  -- provided error out of the process
  IF l_n_person_id_grp IS NOT NULL AND l_n_loan_id IS NOT NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
    fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
    fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    retcode := 2;
    RETURN;
  END IF;

  -- validate if the person group if passed is a valid person group
  IF l_n_person_id_grp IS NOT NULL THEN
    IF l_v_group_cd IS NULL THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;
  END IF;

  -- validate the media type passed as input parameter to th process
  OPEN c_aw_lookups_view (cp_v_lookup_type     => 'IGF_SL_MEDIA_TYPE',
                          cp_v_lookup_code     => l_v_media_type,
                          cp_v_cal_type        => l_v_cal_type,
                          cp_n_sequence_number => l_n_sequence_number
                         );

  FETCH c_aw_lookups_view INTO l_v_meaning;
  IF c_aw_lookups_view%NOTFOUND THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','MEDIA_TYPE'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    retcode := 2;
    RETURN;
  END IF;
  CLOSE c_aw_lookups_view;

  -- validate the school id parameter passed as input to the process
  OPEN  c_school_codes (cp_v_school_id => l_v_school_id);
  FETCH c_school_codes INTO rec_c_school_codes;
  IF c_school_codes%NOTFOUND THEN
    CLOSE c_school_codes;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SCHOOL_ID'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    retcode := 2;
    RETURN;
  END IF;
  CLOSE c_school_codes;

  -- if user has provided the value for p_v_sch_non_ed_branch parameter
  -- validate the parameter  passed as input to the process
  IF l_v_sch_non_ed_branch IS NOT NULL THEN
    OPEN  c_sch_non_ed_branch (cp_v_non_ed_branch  => l_v_non_ed_branch,
                               cp_v_alt_identifier => l_v_sch_non_ed_branch
                              );
    FETCH c_sch_non_ed_branch INTO l_c_flag;
    IF c_sch_non_ed_branch%NOTFOUND THEN
      CLOSE c_sch_non_ed_branch;
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SCH_NON_ED_BRANCH'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;
    CLOSE c_sch_non_ed_branch;

  END IF;

  log_to_fnd(p_v_module => 'create_file',
             p_v_string => ' End of Validation of input parameters'
            );
  -----------------------end of validation of input parameters -------------------------
  IF l_n_person_id_grp IS NOT NULL THEN

    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' Person Group is provided as input parameter'
              );

    --Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
    l_v_sql := igs_pe_dynamic_persid_group.get_dynamic_sql(p_groupid => l_n_person_id_grp,
                                                           p_status  => l_v_status,
                                                           p_group_type => lv_group_type
                                                           );

    --If the sql returned is invalid.. then,
    IF l_v_status <> 'S' THEN
      --Log the error message and stop processing.
      fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,l_v_sql);
      log_to_fnd(p_v_module => ' Procedure create_file',
                 p_v_string => ' igs_pe_dynamic_persid_group.get_dynamic_sql call out returned an error status'
                );
      retcode := 2;
      RETURN;
    END IF;

    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' igs_pe_dynamic_persid_group.get_dynamic_sql call out returned a status of Succes'
              );

    --Execute the sql statement using ref cursor.
    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN c_dyn_person_grp FOR l_v_sql USING l_n_person_id_grp;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN c_dyn_person_grp FOR l_v_sql;
    END IF;

    LOOP
      BEGIN
        --Capture the person id into a local variable l_n_person_id.
        FETCH c_dyn_person_grp INTO l_n_person_id;
        EXIT WHEN c_dyn_person_grp%NOTFOUND;
        log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),40),
                         p_v_param_val => get_person_number (p_n_person_id => l_n_person_id)
                       );
        log_to_fnd(p_v_module => 'create_file',
                   p_v_string => ' processing for Person number '||get_person_number (p_n_person_id => l_n_person_id)
                   );
        -- validate if the person has been associated with the input award year
        l_n_base_id := get_base_id (
                         p_v_cal_type        => l_v_cal_type,
                         p_n_sequence_number => l_n_sequence_number,
                         p_n_person_id       => l_n_person_id
                        ) ;
        IF l_n_base_id IS NULL THEN
          RAISE e_skip;
        END IF;
        log_to_fnd(p_v_module => 'create_file',
                   p_v_string => ' Invoking procedure identify_clchsn_dtls for base id '||l_n_base_id
                   );
        identify_clchsn_dtls
        (
          p_v_cal_type        => l_v_cal_type,
          p_n_sequence_number => l_n_sequence_number,
          p_n_fund_id         => l_n_fund_id,
          p_n_base_id         => l_n_base_id,
          p_n_loan_id         => l_n_loan_id
        );
      EXCEPTION
        WHEN e_skip THEN
          fnd_message.set_name('IGF','IGF_SP_NO_FA_BASE_REC');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
          log_to_fnd(p_v_module => ' Procedure create_file',
                     p_v_string => ' No Base id found for person id '||l_n_person_id
                     );
      END;
    END LOOP;
  END IF;
  -- if base id is provided as input to the process
  IF p_n_base_id IS NOT NULL THEN
    l_n_base_id := p_n_base_id;
    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' Base id: '|| l_n_base_id|| ' provides as input to the process '
               );
    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' Invoking procedure identify_clchsn_dtls for base id '||l_n_base_id
              );
    identify_clchsn_dtls
    (
      p_v_cal_type        => l_v_cal_type,
      p_n_sequence_number => l_n_sequence_number,
      p_n_fund_id         => l_n_fund_id,
      p_n_base_id         => l_n_base_id,
      p_n_loan_id         => l_n_loan_id
    );
  END IF;
  -- if both person group and base id parameters are not provided as input to the process
  IF l_n_person_id_grp IS NULL AND p_n_base_id IS NULL THEN
    l_n_base_id := p_n_base_id;
    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' Both person group and base id are not provided as input to the process '
               );
    identify_clchsn_dtls
    (
      p_v_cal_type        => l_v_cal_type,
      p_n_sequence_number => l_n_sequence_number,
      p_n_fund_id         => l_n_fund_id,
      p_n_base_id         => NULL,
      p_n_loan_id         => l_n_loan_id
    );
  END IF;

  -- Loop through the distinct recipient
  l_n_ctr_recip := 0;
  FOR rec_c_recip_dtls IN c_recip_dtls (cp_v_cal_type        =>  l_v_cal_type       ,
                                        cp_n_sequence_number =>  l_n_sequence_number,
                                        cp_c_loan_chg_status =>  'V',
                                        cp_v_school_id       =>  l_v_school_id
                                        )
  LOOP
    -- this would invoke igf_sl_cl_chg_file.sub_create_file procedure
    log_to_fnd(p_v_module => 'create_file',
               p_v_string => 'Submitting the Concurrent request for relationship code '||rec_c_recip_dtls.relationship_cd
              );
    l_n_request_id := fnd_request.submit_request('IGF',
                                                 'IGFSLJ21',
                                                 '',
                                                 '',
                                                 FALSE,
                                                 l_v_cal_type,
                                                 TO_CHAR(l_n_sequence_number),
                                                 TO_CHAR(l_n_fund_id),
                                                 TO_CHAR(l_n_base_id),
                                                 TO_CHAR(l_n_loan_id),
                                                 rec_c_recip_dtls.relationship_cd,
                                                 l_v_media_type,
                                                 l_v_school_id,
                                                 l_v_sch_non_ed_branch,
                                                 CHR(0),
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '',
                                                 '', '', '', '', '', '', '', '', '', '');
    l_n_ctr_recip := NVL(l_n_ctr_recip,0) + 1;
    IF l_n_request_id = 0 THEN
      -- On Failure of Concurrent Request
      fnd_message.set_name('IGF','IGF_SL_CL_ORIG_REQ_FAIL');
      igs_ge_msg_stack.add;
      log_to_fnd(p_v_module => 'create_file',
                 p_v_string => 'Concurrent request failed for relationship code '||rec_c_recip_dtls.relationship_cd
                );
      app_exception.raise_exception;
    END IF;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.log, fnd_message.get || l_n_ctr_recip );

    log_to_fnd(p_v_module => 'create_file',
               p_v_string => 'Concurrent request successfully executed for relationship code '||rec_c_recip_dtls.relationship_cd
              );
  END LOOP;

EXCEPTION

  WHEN OTHERS THEN
    log_to_fnd(p_v_module => 'create_file',
               p_v_string => ' when others exception handler '||SQLERRM
              );
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
    igs_ge_msg_stack.conc_exception_hndl;
END create_file;

PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2
                     ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sl_cl_chg_file'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;

PROCEDURE log_parameters ( p_v_param_typ IN VARCHAR2,
                           p_v_param_val IN VARCHAR2
                         ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 21 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private procedure for logging
--
-- Parameters  : p_v_param_typ   : IN parameter. Required.
--               p_v_param_val   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  BEGIN
    fnd_file.put_line(fnd_file.log, p_v_param_typ || ' : ' || p_v_param_val );
  END log_parameters;

FUNCTION get_base_id
         (
           p_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
           p_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
           p_n_person_id       IN  igf_ap_fa_base_rec_all.person_id%TYPE
         ) RETURN igf_ap_fa_base_rec_all.base_id%TYPE AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 25 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private function to return the base id for input person id and
--               award year cal type and sequence number
--
-- Parameters  : p_v_cal_type          : IN parameter. Required.
--               p_n_sequence_number   : IN parameter. Required.
--               p_n_person_id         : IN parameter.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR c_ap_fa_base_rec (cp_n_person_id       igf_ap_fa_base_rec_all.person_id%TYPE,
                           cp_v_cal_type        igs_ca_inst_all.cal_type%TYPE,
                           cp_n_sequence_number igs_ca_inst_all.sequence_number%TYPE
                          ) IS
  SELECT base_id
  FROM   igf_ap_fa_base_rec_all fabase
  WHERE  fabase.person_id   = cp_n_person_id
  AND    fabase.ci_cal_type = cp_v_cal_type
  AND    fabase.ci_sequence_number = cp_n_sequence_number;

  l_n_base_id          igf_ap_fa_base_rec_all.base_id%TYPE;
BEGIN
  log_to_fnd(p_v_module => 'get_base_id',
             p_v_string => ' Entered Procedure get_base_id: The input parameters are '||
                           ' p_v_cal_type          : '  ||p_v_cal_type           ||
                           ' p_n_sequence_number   : '  ||p_n_sequence_number    ||
                           ' p_n_person_id         : '  ||p_n_person_id
            );
  OPEN c_ap_fa_base_rec ( cp_n_person_id       => p_n_person_id,
                          cp_v_cal_type        => p_v_cal_type,
                          cp_n_sequence_number => p_n_sequence_number
                        );
  FETCH c_ap_fa_base_rec INTO l_n_base_id;
  CLOSE c_ap_fa_base_rec;
  log_to_fnd(p_v_module => 'get_base_id',
             p_v_string => ' Return value of base id : '||l_n_base_id
            );
  RETURN l_n_base_id;
END get_base_id;

FUNCTION get_person_number (p_n_person_id  IN  igf_ap_fa_base_rec_all.person_id%TYPE)
RETURN hz_parties.party_number%TYPE AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 25 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private function to return the person number for input person id
--
-- Parameters  : p_n_person_id         : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  -- cursor to get person number
  CURSOR c_person_number (cp_n_person_id igf_ap_fa_base_rec_all.person_id%TYPE) IS
  SELECT person_number
  FROM   igs_pe_person_base_v
  WHERE  person_id = cp_n_person_id;

  l_v_person_number  hz_parties.party_number%TYPE;
BEGIN
  log_to_fnd(p_v_module => 'get_person_number',
             p_v_string =>' Entered Procedure get_person_number: The input parameters are ' ||
                          ' p_n_person_id         : '  ||p_n_person_id
            );
  OPEN  c_person_number (cp_n_person_id => p_n_person_id);
  FETCH c_person_number INTO l_v_person_number;
  CLOSE c_person_number;
  log_to_fnd(p_v_module => ' get_base_id',
             p_v_string => ' Return value of person number : '||l_v_person_number
            );
  RETURN l_v_person_number;
END get_person_number;

FUNCTION  validate_cl_lar (p_rec_lorlar lorlar_recTyp) RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 09 November 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private function to return the person number for input person id
--
-- Parameters  : p_rec_lorlar        : IN parameter.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR c_nof_awd_disb (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
  SELECT COUNT(awd.disb_num) tot_disb
  FROM   igf_aw_awd_disb_all awd
  WHERE  awd.award_id = cp_n_award_id
  GROUP BY awd.award_id
  HAVING COUNT(awd.disb_num) > 4;

  l_n_disb_cnt  NUMBER;

  l_rec_lorlar lorlar_recTyp;

BEGIN
  log_to_fnd(p_v_module => 'validate_cl_lar',
             p_v_string => ' Entered function validate_cl_lar: The input parameters are ' ||
                           ' p_n_base_id           : '  ||p_rec_lorlar.base_id            ||
                           ' p_n_loan_id           : '  ||p_rec_lorlar.loan_id
            );

  l_rec_lorlar := p_rec_lorlar;

  -- Verify if the fund is dicontinued or not
  IF l_rec_lorlar.discontinue_fund = 'Y' THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_TYPE'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN FALSE;
  END IF;

  -- Loan Type is required for Change Loan Processing. Following are valid Loan Types -
  -- AL=Alternative loan
  -- PL=Federal PLUS loan
  -- SF=Subsidized Federal Stafford loan
  -- SU=Unsubsidized Federal Stafford loan
  -- tsailaja -FA 163  -Bug 5337555
  IF l_rec_lorlar.fed_fund_code NOT IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
    fnd_message.set_name('IGF','IGF_SL_CL_CHG_LOANT_REQD');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  --  Validate whether loan is active
  IF l_rec_lorlar.loan_active  <> 'Y' THEN
    fnd_message.set_name('IGS','IGF_SL_CL_LOAN_INACTIVE');
    fnd_message.set_token('LOAN_NUMBER',l_rec_lorlar.loan_number);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN FALSE;
  END IF;

  -- validate the loan status
  IF l_rec_lorlar.loan_status <> 'A' THEN
    fnd_message.set_name('IGF','IGF_SL_CL_INV_LOAN_STAT');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- Validate the loan change status
  -- loan change status should be ready to send
  IF (l_rec_lorlar.loan_chg_status <> 'G') THEN
    fnd_message.set_name('IGF','IGF_SL_INV_LOAN_CHG_STATUS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- Change Record would be created only if
  -- The version = CommonLine Release 4 Version Loan,
  -- Loan Status = Accepted
  -- Loan Record Status is Guaranteed or Accepted
  -- Processing Type Code is GP or GO

  -- vaildate the cl version code
  IF (l_rec_lorlar.cl_version <> 'RELEASE-4') THEN
    fnd_message.set_name('IGF','IGF_SL_CL_INV_CL_VER');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- validate the loan processing type code
  IF (l_rec_lorlar.prc_type_code NOT IN ('GO','GP')) THEN
    fnd_message.set_name('IGF','IGF_SL_CL_RESP_INVLID_PRC');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- validate the Loan Record Status
  IF l_rec_lorlar.cl_rec_status NOT IN ('B','G') THEN
    fnd_message.set_name('IGF','IGF_SL_CL_INV_LAR_REC_STAT');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- For Release 4 processing, only 4 disbursements are allowed.
  OPEN  c_nof_awd_disb ( cp_n_award_id => l_rec_lorlar.award_id);
  FETCH c_nof_awd_disb INTO l_n_disb_cnt;
  IF  c_nof_awd_disb%FOUND THEN
    CLOSE c_nof_awd_disb;
    fnd_message.set_name('IGF','IGF_SL_CL4_DISB_EXCEED');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;
  CLOSE c_nof_awd_disb;

  --bvisvana - Validate the School certification date > loan end period
  IF l_rec_lorlar.sch_cert_date > l_rec_lorlar.loan_per_end_date THEN
    fnd_message.set_name('IGF','IGF_SL_CL_CERT_AFTER_END');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  --bvisvana - Bug # 4256897 - Validate the anticip_compl_date < loan end period
  IF l_rec_lorlar.anticip_compl_date < l_rec_lorlar.loan_per_end_date THEN
    fnd_message.set_name('IGF','IGF_SL_CHECK_COMPLDATE');
    fnd_message.set_token('VALUE', ' ' || l_rec_lorlar.loan_per_end_date);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RETURN FALSE;
  END IF;

  -- returning true as all the validations are successful
  log_to_fnd(p_v_module => 'validate_cl_lar',
             p_v_string => ' Returning true as all the validations are successful'
            );
  RETURN TRUE;

END validate_cl_lar;

PROCEDURE identify_clchsn_dtls
          (
            p_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
            p_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
            p_n_fund_id         IN  igf_aw_fund_mast_all.fund_id%TYPE,
            p_n_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
            p_n_loan_id         IN  igf_sl_loans_all.loan_id%TYPE
          ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 25 October 2004
--
-- Purpose:
-- Invoked     : from within create_file procedure
-- Function    : Private procedure to identify the clchsn_dtls records
--               for change send file creation
-- Parameters  : p_v_cal_type          : IN parameter. Required.
--               p_n_sequence_number   : IN parameter. Required.
--               p_n_fund_id           : IN parameter.
--               p_n_base_id           : IN parameter.
--               p_n_loan_id           : IN parameter.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who           When                What
--bvisvana      18-Jul-2005         4132989 - Added sch_cert_date to the Cursor.
--                                  For validation of Sch cert date > loan end period
--mnade         27-Jan-2005         Added 'G' Filter on the c_lor_lar cursor to avoid picking up
--                                  all loans.
------------------------------------------------------------------
  CURSOR  c_sl_clchsn_dtls (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
  SELECT  chdt.ROWID row_id
         ,chdt.*
  FROM    igf_sl_clchsn_dtls chdt
  WHERE   chdt.loan_number_txt = cp_v_loan_number
  AND     chdt.status_code ='R';

  CURSOR  c_lor_lar (cp_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
                     cp_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
                     cp_n_fund_id         IN  igf_aw_fund_mast_all.fund_id%TYPE,
                     cp_n_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_n_loan_id         IN  igf_sl_loans_all.loan_id%TYPE
                    ) IS
  SELECT  loans.row_id
         ,loans.loan_id
         ,loans.award_id
         ,loans.seq_num
         ,loans.loan_number
         ,loans.loan_per_begin_date
         ,loans.loan_per_end_date
         ,loans.loan_status
         ,loans.loan_status_date
         ,loans.loan_chg_status
         ,loans.loan_chg_status_date
         ,loans.active
         ,loans.active_date
         ,loans.borw_detrm_code
         ,loans.legacy_record_flag
         ,loans.external_loan_id_txt
         ,lor.anticip_compl_date
         ,lor.sch_cert_date
         ,lor.prc_type_code
         ,lor.cl_rec_status
         ,lor.relationship_cd
         ,awd.base_id
         ,fmast.ci_cal_type
         ,fmast.ci_sequence_number
         ,fmast.fund_id
         ,fmast.fund_code
         ,fmast.discontinue_fund
         ,fcat.fed_fund_code
         ,clset.cl_version
  FROM    igf_sl_lor_all lor
         ,igf_sl_loans loans
         ,igf_aw_award_all awd
         ,igf_aw_fund_mast_all fmast
         ,igf_aw_fund_cat_all  fcat
         ,igf_sl_cl_setup_all  clset
  WHERE   ((lor.loan_id   = cp_n_loan_id) OR cp_n_loan_id IS NULL)
  AND     loans.loan_id   = lor.loan_id
  AND     awd.award_id    = loans.award_id
  AND     ((awd.base_id   = cp_n_base_id) OR cp_n_base_id IS NULL)
  AND     ((awd.fund_id   = cp_n_fund_id) OR cp_n_fund_id IS NULL)
  AND     fmast.fund_id   = awd.fund_id
  AND     fmast.ci_cal_type        = cp_v_cal_type
  AND     fmast.ci_sequence_number = cp_n_sequence_number
  AND     fcat.fund_code           = fmast.fund_code
  AND     clset.ci_cal_type        = fmast.ci_cal_type
  AND     clset.ci_sequence_number = fmast.ci_sequence_number
  AND     clset.relationship_cd    = lor.relationship_cd
  AND     loans.loan_chg_status = 'G'
  AND     EXISTS (SELECT '1'
                  FROM   igf_ap_fa_base_rec_all fabase
                  WHERE  fabase.base_id     = awd.base_id
                  AND    fabase.ci_cal_type = fmast.ci_cal_type
                  AND    fabase.ci_sequence_number = fmast.ci_sequence_number
                 );

  rec_c_lor_lar         c_lor_lar%ROWTYPE;
  rec_sl_loans          igf_sl_loans%ROWTYPE;
  l_rec_lorlar          lorlar_recTyp;

  l_b_return_status     BOOLEAN;
  l_v_message_name      fnd_new_messages.message_name%TYPE;
  l_v_message_text      fnd_new_messages.message_text%TYPE;
  l_t_message_tokens    igf_sl_cl_chg_prc.token_tab%TYPE;
  e_loan_skip           EXCEPTION;
BEGIN
  log_to_fnd(p_v_module => 'identify_clchsn_dtls',
             p_v_string => ' Entered Procedure identify_clchsn_dtls: The input parameters are '||
                           ' p_v_cal_type          : '  ||p_v_cal_type           ||
                           ' p_n_sequence_number   : '  ||p_n_sequence_number    ||
                           ' p_n_fund_id           : '  ||p_n_fund_id            ||
                           ' p_n_base_id           : '  ||p_n_base_id            ||
                           ' p_n_loan_id           : '  ||p_n_loan_id
            );
  FOR rec_c_lor_lar IN c_lor_lar(cp_v_cal_type        =>  p_v_cal_type       ,
                                 cp_n_sequence_number =>  p_n_sequence_number,
                                 cp_n_fund_id         =>  p_n_fund_id        ,
                                 cp_n_base_id         =>  p_n_base_id        ,
                                 cp_n_loan_id         =>  p_n_loan_id
                                )
  LOOP
    BEGIN
      fnd_file.new_line(fnd_file.log,1);
      fnd_file.put(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING'),40));
      fnd_file.new_line(fnd_file.log,1);

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'),40),
                       p_v_param_val => rec_c_lor_lar.loan_number
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_TYPE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_AW_FED_FUND',rec_c_lor_lar.fed_fund_code)
                     );

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_STATUS'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_LOAN_STATUS',rec_c_lor_lar.loan_status)
                     );

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),40),
                       p_v_param_val => igf_gr_gen.get_per_num(rec_c_lor_lar.base_id)
                     );
      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND_CODE'),40),
                       p_v_param_val => rec_c_lor_lar.fund_code
                     );

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING_TYPE'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_PRC_TYPE_CODE',rec_c_lor_lar.prc_type_code)
                     );

      log_parameters ( p_v_param_typ => RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','CL_VERSION'),40),
                       p_v_param_val => igf_aw_gen.lookup_desc('IGF_SL_CL_VERSION',rec_c_lor_lar.cl_version)
                     );
      fnd_file.new_line(fnd_file.log,1);

      -- Assigning to record type variable
      l_rec_lorlar.cal_type             :=  rec_c_lor_lar.ci_cal_type           ;
      l_rec_lorlar.sequence_number      :=  rec_c_lor_lar.ci_sequence_number    ;
      l_rec_lorlar.fund_id              :=  rec_c_lor_lar.fund_id               ;
      l_rec_lorlar.discontinue_fund     :=  rec_c_lor_lar.discontinue_fund      ;
      l_rec_lorlar.fed_fund_code        :=  rec_c_lor_lar.fed_fund_code         ;
      l_rec_lorlar.base_id              :=  rec_c_lor_lar.base_id               ;
      l_rec_lorlar.award_id             :=  rec_c_lor_lar.award_id              ;
      l_rec_lorlar.loan_id              :=  rec_c_lor_lar.loan_id               ;
      l_rec_lorlar.loan_number          :=  rec_c_lor_lar.loan_number           ;
      l_rec_lorlar.loan_status          :=  rec_c_lor_lar.loan_status           ;
      l_rec_lorlar.loan_chg_status      :=  rec_c_lor_lar.loan_chg_status       ;
      l_rec_lorlar.loan_active          :=  rec_c_lor_lar.active                ;
      l_rec_lorlar.sch_cert_date        :=  rec_c_lor_lar.sch_cert_date         ;
      l_rec_lorlar.anticip_compl_date   :=  rec_c_lor_lar.anticip_compl_date    ;
      l_rec_lorlar.loan_per_begin_date  :=  rec_c_lor_lar.loan_per_begin_date   ;
      l_rec_lorlar.loan_per_end_date    :=  rec_c_lor_lar.loan_per_end_date     ;

      l_rec_lorlar.cl_rec_status      :=  rec_c_lor_lar.cl_rec_status      ;
      l_rec_lorlar.prc_type_code      :=  rec_c_lor_lar.prc_type_code      ;
      l_rec_lorlar.cl_version         :=  rec_c_lor_lar.cl_version         ;

      -- assigning to loan record type variable
       rec_sl_loans.row_id                         :=   rec_c_lor_lar.row_id                   ;
       rec_sl_loans.loan_id                        :=   rec_c_lor_lar.loan_id                  ;
       rec_sl_loans.award_id                       :=   rec_c_lor_lar.award_id                 ;
       rec_sl_loans.seq_num                        :=   rec_c_lor_lar.seq_num                  ;
       rec_sl_loans.loan_number                    :=   rec_c_lor_lar.loan_number              ;
       rec_sl_loans.loan_per_begin_date            :=   rec_c_lor_lar.loan_per_begin_date      ;
       rec_sl_loans.loan_per_end_date              :=   rec_c_lor_lar.loan_per_end_date        ;
       rec_sl_loans.loan_status                    :=   rec_c_lor_lar.loan_status              ;
       rec_sl_loans.loan_status_date               :=   rec_c_lor_lar.loan_status_date         ;
       rec_sl_loans.loan_chg_status_date           :=   rec_c_lor_lar.loan_chg_status_date     ;
       rec_sl_loans.active                         :=   rec_c_lor_lar.active                   ;
       rec_sl_loans.active_date                    :=   rec_c_lor_lar.active_date              ;
       rec_sl_loans.borw_detrm_code                :=   rec_c_lor_lar.borw_detrm_code          ;
       rec_sl_loans.legacy_record_flag             :=   rec_c_lor_lar.legacy_record_flag       ;
       rec_sl_loans.external_loan_id_txt           :=   rec_c_lor_lar.external_loan_id_txt     ;


      -- invoke the validate routine to validate the loan
      l_b_return_status := validate_cl_lar (p_rec_lorlar => l_rec_lorlar) ;
      IF NOT (l_b_return_status) THEN
        log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                   p_v_string => ' validation of the Loan record failed for Loan number: '  ||rec_c_lor_lar.loan_number
                  );
         rec_sl_loans.loan_chg_status  :=   'N'  ;
        RAISE e_loan_skip;
      END IF;
      log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                 p_v_string => ' validation of the Loan record successful for Loan number: '  ||rec_c_lor_lar.loan_number
                );
      -- for each loan number loop thru the change send details table
      FOR rec_c_sl_clchsn_dtls IN c_sl_clchsn_dtls (cp_v_loan_number => rec_c_lor_lar.loan_number)
      LOOP
        l_b_return_status := TRUE;
        l_v_message_name  := NULL;
        log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                   p_v_string => 'Validating the Change record for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id
                  );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        igf_sl_cl_chg_prc.validate_chg (
          p_n_clchgsnd_id    => rec_c_sl_clchsn_dtls.clchgsnd_id,
          p_b_return_status  => l_b_return_status,
          p_v_message_name   => l_v_message_name,
	  p_t_message_tokens => l_t_message_tokens
        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id
                    );
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igf_sl_cl_chg_prc.parse_tokens(
            p_t_message_tokens => l_t_message_tokens);
/*
    FOR token_counter IN l_t_message_tokens.FIRST..l_t_message_tokens.LAST LOOP
       fnd_message.set_token(l_t_message_tokens(token_counter).token_name, l_t_message_tokens(token_counter).token_value);
    END LOOP;
*/
          l_v_message_text := fnd_message.get;
          fnd_file.put_line(fnd_file.log, l_v_message_text);
          log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                     p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                     );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => rec_c_sl_clchsn_dtls.row_id                     ,
            x_clchgsnd_id                => rec_c_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                             ,
            x_status_date                => rec_c_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => l_v_message_text                                ,
            x_send_record_txt            => rec_c_sl_clchsn_dtls.send_record_txt
          );
          log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                     p_v_string => ' Updated the status of change send record to Not Ready to Send'
                     );
          rec_sl_loans.loan_chg_status  :=   'N'  ;
          RAISE e_loan_skip;
        END IF;
        log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                   p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id
                  );
      END LOOP;

      -- Call to update row of loans table to update the status to intermediate status 'V'
      rec_sl_loans.loan_chg_status  :=   'V'  ;
      log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                 p_v_string => ' Updating the loan_chg_status of : '  ||rec_c_lor_lar.loan_number|| 'to V'
                );
      proc_update_loan_rec(p_loan_rec => rec_sl_loans);
    EXCEPTION
      WHEN e_loan_skip THEN
        -- Call to update row of loans table to update the status to 'Not ready to Sent'
        log_to_fnd(p_v_module => 'identify_clchsn_dtls',
                   p_v_string => ' update row of loans table to update the status to Not ready to Sent for : '  ||rec_c_lor_lar.loan_number
                  );
        proc_update_loan_rec(p_loan_rec => rec_sl_loans);
    END;
  END LOOP;
END identify_clchsn_dtls;


PROCEDURE proc_update_loan_rec(p_loan_rec igf_sl_loans%ROWTYPE) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 25 October 2004
--
-- Purpose:
-- Invoked     : from within identify_clchsn_dtls procedure
-- Function    : Private procedure to update the loans table
--               to 'V' or 'N'
-- Parameters  : p_loan_rec          : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_loan_rec  igf_sl_loans%ROWTYPE;
BEGIN
  log_to_fnd(p_v_module => 'proc_update_loan_rec',
             p_v_string => ' Entered Procedure proc_update_loan_rec: The input parameters are '||
                           ' p_loan_rec.loan_id           : '  ||p_loan_rec.loan_id            ||
                           ' p_loan_rec.loan_chg_status   : '  ||p_loan_rec.loan_chg_status
            );
  l_loan_rec  := p_loan_rec;

  -- parameter x_called_from would not be passed as no change record processing is
  -- required while updating the loans table through this process
  igf_sl_loans_pkg.update_row (
    x_rowid                          =>       l_loan_rec.row_id                   ,
    x_loan_id                        =>       l_loan_rec.loan_id                  ,
    x_award_id                       =>       l_loan_rec.award_id                 ,
    x_seq_num                        =>       l_loan_rec.seq_num                  ,
    x_loan_number                    =>       l_loan_rec.loan_number              ,
    x_loan_per_begin_date            =>       l_loan_rec.loan_per_begin_date      ,
    x_loan_per_end_date              =>       l_loan_rec.loan_per_end_date        ,
    x_loan_status                    =>       l_loan_rec.loan_status              ,
    x_loan_status_date               =>       l_loan_rec.loan_status_date         ,
    x_loan_chg_status                =>       l_loan_rec.loan_chg_status          ,
    x_loan_chg_status_date           =>       l_loan_rec.loan_chg_status_date     ,
    x_active                         =>       l_loan_rec.active                   ,
    x_active_date                    =>       l_loan_rec.active_date              ,
    x_borw_detrm_code                =>       l_loan_rec.borw_detrm_code          ,
    x_mode                           =>       'R'                                 ,
    x_legacy_record_flag             =>       l_loan_rec.legacy_record_flag       ,
    x_external_loan_id_txt           =>       l_loan_rec.external_loan_id_txt
  );
  log_to_fnd(p_v_module => 'proc_update_loan_rec',
             p_v_string => ' Updated the loan record successfully '                           ||
                           ' l_loan_rec.loan_id           : '  ||l_loan_rec.loan_id           ||
                           ' l_loan_rec.loan_chg_status   : '  ||l_loan_rec.loan_chg_status
            );
END proc_update_loan_rec;

PROCEDURE sub_create_file(
  errbuf                OUT  NOCOPY   VARCHAR2,
  retcode               OUT  NOCOPY   NUMBER,
  p_v_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
  p_n_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE,
  p_n_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
  p_n_base_id           IN   igf_ap_fa_base_rec_all.base_id%TYPE,
  p_n_loan_id           IN   igf_sl_loans_all.loan_id%TYPE,
  p_v_relationship_cd   IN   igf_sl_cl_recipient.relationship_cd%TYPE,
  p_v_media_type        IN   igf_lookups_view.lookup_code%TYPE,
  p_v_school_id         IN   igf_sl_school_codes_v.alternate_identifier%TYPE,
  p_v_sch_non_ed_branch IN   igf_sl_school_codes_v.alternate_identifier%TYPE
  ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 25 October 2004
--
-- Purpose:
-- Invoked     : from within identify_clchsn_dtls procedure
-- Function    : public procedure to create the change send file
-- Parameters  : p_v_cal_type          : IN parameter. Required.
--               p_n_sequence_number   : IN parameter. Required.
--               p_n_fund_id           : IN parameter.
--               p_n_base_id           : IN parameter.
--               p_n_loan_id           : IN parameter.
--               p_v_relationship_cd   : IN parameter. Required
--               p_v_media_type        : IN parameter. Required.
--               p_v_school_id         : IN parameter. Required.
--               p_v_sch_non_ed_branch : IN parameter.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--bvisvana    10-Apr-2006      Build FA 161.
--                            TBH Impact change done in igf_sl_lor_loc_pkg.update_row()
--museshad    05-May-2005      Bug# 4346258
--                             Added the parameter 'base_id' in the call to the
--                             function get_cl_version(). The signature of
--                             this function has been changed so that it takes
--                             into account any overriding CL version for a
--                             specific Organization Unit in FFELP Setup override.--
------------------------------------------------------------------
  CURSOR  c_recip_dtls( cp_v_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
                        cp_n_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
                        cp_n_fund_id         IN  igf_aw_fund_mast_all.fund_id%TYPE,
                        cp_n_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_n_loan_id         IN  igf_sl_loans_all.loan_id%TYPE,
                        cp_v_relationship_cd IN  igf_sl_cl_recipient.relationship_cd%TYPE,
                        cp_c_loan_chg_status IN  igf_sl_loans_all.loan_chg_status%TYPE,
                        cp_v_school_id       IN  igf_sl_school_codes_v.alternate_identifier%TYPE
                      ) IS
  SELECT   recip.rcpt_id
          ,recip.lender_id
          ,recip.lend_non_ed_brc_id
          ,recip.guarantor_id
          ,recip.recipient_id
          ,recip.recipient_type
          ,recip.recip_non_ed_brc_id
          ,loans.loan_id
          ,loans.award_id
          ,loans.seq_num
          ,loans.loan_number
          ,loans.loan_per_begin_date
          ,loans.loan_per_end_date
          ,loans.loan_status
          ,loans.loan_status_date
          ,loans.loan_chg_status
          ,loans.loan_chg_status_date
          ,loans.active
          ,loans.active_date
          ,loans.borw_detrm_code
          ,loans.legacy_record_flag
          ,loans.external_loan_id_txt
          ,lor.origination_id
          ,lor.sch_cert_date
          ,lor.orig_status_flag
          ,lor.orig_batch_id
          ,lor.orig_batch_date
          ,lor.chg_batch_id
          ,lor.orig_ack_date
          ,lor.credit_override
          ,lor.credit_decision_date
          ,lor.req_serial_loan_code
          ,lor.act_serial_loan_code
          ,lor.pnote_delivery_code
          ,lor.pnote_status
          ,lor.pnote_status_date
          ,lor.pnote_id
          ,lor.pnote_print_ind
          ,lor.pnote_accept_amt
          ,lor.pnote_accept_date
          ,lor.unsub_elig_for_heal
          ,lor.disclosure_print_ind
          ,lor.orig_fee_perct
          ,lor.borw_confirm_ind
          ,lor.borw_interest_ind
          ,lor.borw_outstd_loan_code
          ,lor.unsub_elig_for_depnt
          ,lor.guarantee_amt
          ,lor.guarantee_date
          ,lor.guarnt_amt_redn_code
          ,lor.guarnt_status_code
          ,lor.guarnt_status_date
          ,lor.lend_apprv_denied_code
          ,lor.lend_apprv_denied_date
          ,lor.lend_status_code
          ,lor.lend_status_date
          ,lor.guarnt_adj_ind
          ,lor.grade_level_code
          ,lor.enrollment_code
          ,lor.anticip_compl_date
          ,lor.borw_lender_id
          ,lor.duns_borw_lender_id
          ,lor.duns_guarnt_id
          ,lor.prc_type_code
          ,lor.cl_seq_number
          ,lor.last_resort_lender
          ,lor.duns_lender_id
          ,lor.duns_recip_id
          ,lor.rec_type_ind
          ,lor.cl_loan_type
          ,lor.cl_rec_status
          ,lor.cl_rec_status_last_update
          ,lor.alt_prog_type_code
          ,lor.alt_appl_ver_code
          ,lor.mpn_confirm_code
          ,lor.resp_to_orig_code
          ,lor.appl_loan_phase_code
          ,lor.appl_loan_phase_code_chg
          ,lor.appl_send_error_codes
          ,lor.tot_outstd_stafford
          ,lor.tot_outstd_plus
          ,lor.alt_borw_tot_debt
          ,lor.act_interest_rate
          ,lor.service_type_code
          ,lor.rev_notice_of_guarnt
          ,lor.sch_refund_amt
          ,lor.sch_refund_date
          ,lor.uniq_layout_vend_code
          ,lor.uniq_layout_ident_code
          ,DECODE(fcat.fed_fund_code,'FLP',lor.p_person_id,
                                     'FLS',fabase.person_id,
                                     'FLU',fabase.person_id,
									 'GPLUSFL',fabase.person_id,
                                     'ALT',DECODE(SIGN(lor.p_person_id-fabase.person_id),0, fabase.person_id,lor.p_person_id)) borrower_id
          ,lor.p_ssn_chg_date
          ,lor.p_dob_chg_date
          ,lor.p_permt_addr_chg_date
          ,lor.p_default_status
          ,lor.p_signature_code
          ,lor.p_signature_date
          ,lor.s_ssn_chg_date
          ,lor.s_dob_chg_date
          ,lor.s_permt_addr_chg_date
          ,lor.s_local_addr_chg_date
          ,lor.s_default_status
          ,lor.s_signature_code
          ,lor.pnote_batch_id
          ,lor.pnote_ack_date
          ,lor.pnote_mpn_ind
          ,lor.elec_mpn_ind
          ,lor.borr_sign_ind
          ,lor.stud_sign_ind
          ,lor.borr_credit_auth_code
          ,lor.relationship_cd
          ,lor.cps_trans_num
          ,lor.crdt_decision_status
          ,lor.note_message
          ,lor.book_loan_amt
          ,lor.book_loan_amt_date
          ,lor.pymt_servicer_amt
          ,lor.pymt_servicer_date
          ,lor.deferment_request_code
          ,lor.eft_authorization_code
          ,lor.requested_loan_amt
          ,lor.actual_record_type_code
          ,lor.reinstatement_amt
          ,lor.school_use_txt
          ,lor.lender_use_txt
          ,lor.guarantor_use_txt
          ,lor.fls_approved_amt
          ,lor.flu_approved_amt
          ,lor.flp_approved_amt
          ,lor.alt_approved_amt
          ,lor.loan_app_form_code
          ,lor.override_grade_level_code
          ,awd.base_id
          ,awd.accepted_amt                loan_amt_accepted
          ,awd.award_date
          ,fmast.fund_code
          ,fcat.fed_fund_code
          ,fabase.person_id                 student_id
          ,TRUNC(fabase.coa_f) coa_f
  FROM    igf_sl_lor_all       lor
         ,igf_sl_loans_all     loans
         ,igf_aw_award_all     awd
         ,igf_aw_fund_mast_all fmast
         ,igf_aw_fund_cat_all  fcat
         ,igf_sl_cl_recipient  recip
         ,igf_ap_fa_base_rec_all fabase
  WHERE   lor.relationship_cd            = cp_v_relationship_cd
  AND     ((lor.loan_id = cp_n_loan_id) OR cp_n_loan_id IS NULL)
  AND     loans.loan_id                  = lor.loan_id
  AND     loans.loan_chg_status          = cp_c_loan_chg_status
  AND     SUBSTR(loans.loan_number,1, 6) = SUBSTR(cp_v_school_id,1,6)
  AND     awd.award_id                   = loans.award_id
  AND     ((awd.base_id   = cp_n_base_id) OR cp_n_base_id IS NULL)
  AND     ((awd.fund_id   = cp_n_fund_id) OR cp_n_fund_id IS NULL)
  AND     fmast.fund_id                  = awd.fund_id
  AND     fmast.ci_cal_type              = cp_v_cal_type
  AND     fmast.ci_sequence_number       = cp_n_sequence_number
  AND     fcat.fund_code                 = fmast.fund_code
  AND     recip.relationship_cd          = lor.relationship_cd
  AND     fabase.base_id                 = awd.base_id
  AND     fabase.ci_cal_type             = fmast.ci_cal_type
  AND     fabase.ci_sequence_number      = fmast.ci_sequence_number
  ORDER BY borrower_id;


  CURSOR  c_school_opeid(cp_v_school_id IN igf_sl_school_codes_v.alternate_identifier%TYPE) IS
  SELECT  meaning
  FROM    igf_lookups_view
  WHERE   lookup_type = 'IGF_AP_SCHOOL_OPEID'
  AND     lookup_code = cp_v_school_id;

  CURSOR  c_cl_recipient_dtls (cp_v_relationship_cd IN  igf_sl_cl_recipient.relationship_cd%TYPE)IS
  SELECT  recipient_id
         ,recipient_type
         ,recip_non_ed_brc_id
  FROM    igf_sl_cl_recipient
  WHERE   relationship_cd  = cp_v_relationship_cd;

  CURSOR  c_sl_lender (cp_n_recipient_id IN igf_sl_cl_recipient.recipient_id%TYPE) IS
  SELECT  lender_id
         ,description
  FROM    igf_sl_lender
  WHERE   lender_id = cp_n_recipient_id
  AND     enabled      = 'Y';

  CURSOR  c_sl_guarantor (cp_n_recipient_id IN igf_sl_cl_recipient.recipient_id%TYPE) IS
  SELECT  guarantor_id
         ,description
  FROM    igf_sl_guarantor
  WHERE   guarantor_id = cp_n_recipient_id
  AND     enabled      = 'Y';


  CURSOR  c_sl_servicer (cp_n_recipient_id IN igf_sl_cl_recipient.recipient_id%TYPE) IS
  SELECT  servicer_id
         ,description
  FROM    igf_sl_servicer
  WHERE   servicer_id  = cp_n_recipient_id
  AND     enabled      = 'Y';

  CURSOR  c_sl_clchsn_dtls (cp_v_loan_number IN igf_sl_loans_all.loan_number%TYPE) IS
  SELECT  chdt.ROWID row_id
         ,chdt.*
  FROM    igf_sl_clchsn_dtls chdt
  WHERE   chdt.loan_number_txt = cp_v_loan_number
  AND     chdt.status_code ='R'
  ORDER BY change_record_type_txt,disbursement_number;

  CURSOR    c_aw_awd_disb (cp_n_award_id IN igf_aw_award_all.award_id%TYPE) IS
  SELECT    adisb.disb_date
           ,NVL(adisb.disb_accepted_amt,0)  disb_accepted_amt
           ,adisb.hold_rel_ind
           ,adisb.disb_num
  FROM      igf_aw_awd_disb_all adisb
  WHERE     adisb.award_id = cp_n_award_id
  ORDER BY  adisb.disb_num;

  CURSOR    c_aw_awd_disb2 (cp_n_award_id IN igf_aw_award_all.award_id%TYPE,
                            cp_n_disb_num IN igf_aw_awd_disb_all.disb_num%TYPE
                           ) IS
  SELECT    adisb.disb_date
           ,NVL(adisb.disb_accepted_amt,0)  disb_accepted_amt
           ,adisb.hold_rel_ind
           ,adisb.disb_num
           ,adisb.fee_1
           ,adisb.fee_2
           ,adisb.fee_paid_1
           ,adisb.fee_paid_2
  FROM      igf_aw_awd_disb_all adisb
  WHERE     adisb.award_id = cp_n_award_id
  AND       adisb.disb_num = cp_n_disb_num
  ORDER BY  adisb.disb_num;

  rec_c_aw_awd_disb2 c_aw_awd_disb2%ROWTYPE;

  CURSOR cur_get_fin_aid(cp_n_award_id   IN  igf_aw_award_all.award_id%TYPE  ,
                         cp_n_base_id    IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                         cp_awd_status_1 IN  igf_aw_award.award_status%TYPE,
                         cp_awd_status_2 IN  igf_aw_award.award_status%TYPE
                        ) IS
  SELECT TRUNC(SUM(NVL(NVL(awd.accepted_amt,awd.offered_amt),0))) etsimated_fin
  FROM   igf_aw_award_all awd
  WHERE  awd.base_id  =  cp_n_base_id
  AND    awd.award_id <> cp_n_award_id
  AND    (awd.award_status IN (cp_awd_status_1,cp_awd_status_2));

  CURSOR c_sl_lor_loc (cp_n_loan_id         igf_sl_loans_all.loan_id%TYPE ,
                       cp_n_origination_id  igf_sl_lor_all.origination_id%TYPE
                      ) IS
  SELECT lorloc.*, lorloc.ROWID row_id
  FROM   igf_sl_lor_loc_all lorloc
  WHERE  loan_id        = cp_n_loan_id
  AND    origination_id = cp_n_origination_id;

  rec_c_sl_lor_loc  c_sl_lor_loc%ROWTYPE;

  -- input variables for this procedure
  l_v_cal_type           igs_ca_inst_all.cal_type%TYPE;
  l_n_sequence_number    igs_ca_inst_all.sequence_number%TYPE;
  l_n_loan_id            igf_sl_loans_all.loan_id%TYPE;
  l_n_base_id            igf_ap_fa_base_rec_all.base_id%TYPE;
  l_n_fund_id            igf_aw_fund_mast_all.fund_id%TYPE;
  l_v_school_id          igf_sl_school_codes_v.alternate_identifier%TYPE;
  l_v_media_type         igf_lookups_view.lookup_code%TYPE;
  l_v_sch_non_ed_branch  igf_sl_school_codes_v.alternate_identifier%TYPE;
  l_v_relationship_cd    igf_sl_cl_recipient.relationship_cd%TYPE;

  l_v_alt_code           igs_ca_inst_all.alternate_code%TYPE;

  -- variables for change send header record
  l_v_chg_header_rec     VARCHAR2(1000);
  l_v_file_ident_code    igf_sl_cl_file_type.file_ident_code%TYPE;
  l_v_file_ident_name    igf_sl_cl_file_type.file_ident_name%TYPE;
  l_v_file_crea_date     VARCHAR2(8);
  l_v_file_crea_time     VARCHAR2(6);
  l_v_cl_version         igf_sl_cl_setup_all.cl_version%TYPE;
  l_v_source_name        igf_ap_school_opeid_v.meaning%TYPE;
  l_n_recipient_id       igf_sl_cl_recipient.recipient_id%TYPE;
  l_v_recipient_name     igf_sl_servicer.description%TYPE;
  l_v_recipient_type     igf_sl_cl_recipient.recipient_type%TYPE;
  l_v_recip_non_edbrc_id igf_sl_cl_recipient.recip_non_ed_brc_id%TYPE;
  l_n_lender_id          igf_sl_lender.lender_id%TYPE;
  l_n_guarantor_id       igf_sl_guarantor.guarantor_id%TYPE;
  l_n_servicer_id        igf_sl_servicer.servicer_id%TYPE;
  l_v_filler_2_char      VARCHAR2(2);
  l_v_batch_id           igf_sl_cl_batch.batch_id%TYPE;
  l_v_rowid              ROWID;
  l_n_cbth_id            igf_sl_cl_batch.cbth_id%TYPE;

  -- variables for trailer
  l_v_chg_trailer_rec     VARCHAR2(1000);
  l_n_1cntr               NUMBER;
  l_n_2cntr               NUMBER;

  -- variables for (@1-02)
  l_n_borrower_id         igf_ap_fa_base_rec_all.person_id%TYPE;
  l_v_chg_01_2_rec        VARCHAR2(2000);
  c_borrower_dtls         igf_sl_gen.person_dtl_cur;
  rec_borrower_dtls       igf_sl_gen.person_dtl_rec;
  l_v_filler_3_char       VARCHAR2(3);

  -- variables for (@1-07)
  l_v_chg_01_7_rec         VARCHAR2(4000);
  l_c_01_07_flg            VARCHAR2(1);
  l_v_loan_type            igf_aw_fund_cat_all.fed_fund_code%TYPE;
  l_v_alt_prog_type_code   igf_sl_lor_all.alt_prog_type_code%TYPE;
  c_student_dtls           igf_sl_gen.person_dtl_cur;
  rec_student_dtls         igf_sl_gen.person_dtl_rec;
  l_d_revised_per_begin_dt igf_sl_loans_all.loan_per_begin_date%TYPE;
  l_d_revised_per_end_dt   igf_sl_loans_all.loan_per_end_date%TYPE;
  l_d_old_per_begin_dt     igf_sl_loans_all.loan_per_begin_date%TYPE;
  l_d_old_per_end_dt       igf_sl_loans_all.loan_per_end_date%TYPE;
  l_v_ssn                  igf_ap_isir_ints_all.current_ssn_txt%TYPE;

  -- variables for (@1-08)
  l_v_chg_01_8_rec         VARCHAR2(4000);
  l_c_01_08_flg            VARCHAR2(1);
  l_n_reinstated_loan_amt  NUMBER;
  l_d_cancellation_date    DATE;

  -- variables for (@1-09)
  l_v_chg_01_9_rec         VARCHAR2(4000);
  l_c_01_09_flg            VARCHAR2(1);
  l_n_disb_number          igf_aw_awd_disb_all.disb_num%TYPE;

  TYPE chsn_09dtl_rectyp IS RECORD (
    disb_number          igf_aw_awd_disb_all.disb_num%TYPE                ,
    disb_date            igf_aw_awd_disb_all.disb_date%TYPE               ,
    disb_cancel_date     igf_sl_clchsn_dtls.disbursement_cancel_date%TYPE ,
    disb_cancel_amt      igf_sl_clchsn_dtls.disbursement_cancel_amt%TYPE  ,
    disb_hold_rel_ind    igf_aw_awd_disb_all.hold_rel_ind%TYPE            ,
    revised_disb_date    igf_sl_clchsn_dtls.disbursement_revised_date%TYPE,
    revised_disb_amt     igf_sl_clchsn_dtls.disbursement_revised_amt%TYPE ,
    reinstate_ind        igf_sl_clchsn_dtls.disbursement_reinst_code%TYPE
  );
  l_rec_chsn_09dtl  chsn_09dtl_rectyp;

  TYPE tab_rec_09_dtl IS TABLE OF l_rec_chsn_09dtl%TYPE INDEX BY BINARY_INTEGER;
  v_tab_rec_09_dtl       tab_rec_09_dtl;
  l_n_ctr_09             NUMBER;

  -- variables for (@1-10)
  l_v_chg_01_10_rec         VARCHAR2(4000);
  l_c_01_10_flg             VARCHAR2(1);
  l_n_post_disb_number      igf_aw_awd_disb_all.disb_num%TYPE;

  TYPE chsn_10dtl_rectyp IS RECORD (
    disb_number           igf_aw_awd_disb_all.disb_num%TYPE                ,
    disb_date             igf_aw_awd_disb_all.disb_date%TYPE               ,
    disb_cancel_date      igf_sl_clchsn_dtls.disbursement_cancel_date%TYPE ,
    disb_cancel_amt       igf_sl_clchsn_dtls.disbursement_cancel_amt%TYPE  ,
    disb_consummation_ind VARCHAR2(30)                                     ,
    actual_return_amt     igf_aw_awd_disb_all.disb_accepted_amt%TYPE       ,
    fund_return_mthd_code igf_aw_awd_disb_all.fund_return_mthd_code%TYPE   ,
    fund_reissue_code     igf_sl_clchsn_dtls.disbursement_reissue_code%TYPE,
    revised_disb_date     igf_sl_clchsn_dtls.disbursement_revised_date%TYPE,
    revised_disb_amt      igf_sl_clchsn_dtls.disbursement_revised_amt%TYPE ,
    reinstate_ind         igf_sl_clchsn_dtls.disbursement_reinst_code%TYPE
  );
  l_rec_chsn_10dtl  chsn_10dtl_rectyp;

  TYPE tab_rec_10_dtl IS TABLE OF l_rec_chsn_10dtl%TYPE INDEX BY BINARY_INTEGER;
  v_tab_rec_10_dtl       tab_rec_10_dtl;
  l_n_ctr_10             NUMBER;
  l_n_actual_return_amt  NUMBER;

  -- variables for (@1-24)
  l_v_chg_01_24_rec         VARCHAR2(4000);
  l_v_disb_rec              VARCHAR2(1000);
  l_c_01_24_flg             VARCHAR2(1);
  l_n_loan_amt_increase     igf_aw_awd_disb_all.disb_accepted_amt%TYPE;
  l_n_coa                   igf_ap_fa_base_rec_all.coa_f%TYPE;
  l_n_efc                   igf_ap_fa_base_rec_all.efc_f%TYPE;
  l_n_est_fin               igf_aw_award_all.accepted_amt%TYPE;
  l_n_pell_efc              NUMBER;
  l_n_efc_f                 NUMBER;
  l_n_ctr_disb              NUMBER;
BEGIN

  igf_aw_gen.set_org_id(NULL);
  retcode := 0 ;
  SAVEPOINT sub_create_file;
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' Entered Procedure sub_create_file: The input parameters are '||
                           ' p_v_cal_type          : '  ||p_v_cal_type           ||
                           ' p_n_sequence_number   : '  ||p_n_sequence_number    ||
                           ' p_n_fund_id           : '  ||p_n_fund_id            ||
                           ' p_n_base_id           : '  ||p_n_base_id            ||
                           ' p_n_loan_id           : '  ||p_n_loan_id            ||
                           ' p_v_relationship_cd   : '  ||p_v_relationship_cd    ||
                           ' p_v_media_type        : '  ||p_v_media_type         ||
                           ' p_v_school_id         : '  ||p_v_school_id          ||
                           ' p_v_sch_non_ed_branch : '  ||p_v_sch_non_ed_branch
            );

  -- assigning the passed input parameters to local variables
  l_v_cal_type           := p_v_cal_type;
  l_n_sequence_number    := p_n_sequence_number;
  l_n_fund_id            := p_n_fund_id;
  l_n_base_id            := p_n_base_id;
  l_n_loan_id            := p_n_loan_id;
  l_v_relationship_cd    := p_v_relationship_cd;
  l_v_alt_code           := igf_gr_gen.get_alt_code(l_v_cal_type,l_n_sequence_number);
  l_v_media_type         := p_v_media_type ;
  l_v_school_id          := p_v_school_id  ;
  l_v_sch_non_ed_branch  := p_v_sch_non_ed_branch;


  l_v_file_crea_date     := TO_CHAR(SYSDATE,'YYYYMMDD');
  l_v_file_crea_time     := TO_CHAR(SYSDATE,'HH24MISS');
  -- obtain the common line release version based on the award year and relationship code passed as parameter
  -- museshad(Bug# 4346258) -  Added the parameter p_base_id due to change in the
  --                           signature of the function 'get_cl_version()'
  l_v_cl_version         := igf_sl_gen.get_cl_version(
                              p_ci_cal_type          =>  l_v_cal_type        ,
                              p_ci_seq_num           =>  l_n_sequence_number ,
                              p_relationship_cd      =>  l_v_relationship_cd ,
                              p_base_id              =>  l_n_base_id
                            );
  l_v_file_ident_code    := igf_sl_gen.get_cl_file_type(l_v_cl_version, 'CL_CHANGE_TRANS', 'FILE-IDENT-CODE');
  l_v_file_ident_name    := igf_sl_gen.get_cl_file_type(l_v_cl_version, 'CL_CHANGE_TRANS', 'FILE-IDENT-NAME');
  -- get the source name
  OPEN  c_school_opeid(cp_v_school_id => l_v_school_id);
  FETCH c_school_opeid INTO l_v_source_name;
  CLOSE c_school_opeid ;

  -- get the recepient name

  OPEN  c_cl_recipient_dtls (cp_v_relationship_cd => l_v_relationship_cd);
  FETCH c_cl_recipient_dtls INTO  l_n_recipient_id
                                 ,l_v_recipient_type
                                 ,l_v_recip_non_edbrc_id;
  CLOSE c_cl_recipient_dtls ;

  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' Recipient id           : '  ||l_n_recipient_id           ||
                           ' Recipient type         : '  ||l_v_recipient_type         ||
                           ' Recipient Non EdBrc Id : '  ||l_v_recip_non_edbrc_id
            );

  -- if recepient is guarantor
  IF l_v_recipient_type  = 'GUARN' THEN

    OPEN  c_sl_guarantor (cp_n_recipient_id => l_n_recipient_id);
    FETCH c_sl_guarantor INTO l_n_guarantor_id,l_v_recipient_name;
    CLOSE c_sl_guarantor ;

  -- if recepient is lender
  ELSIF l_v_recipient_type = 'LND' THEN

    OPEN  c_sl_lender (cp_n_recipient_id => l_n_recipient_id);
    FETCH c_sl_lender INTO l_n_lender_id,l_v_recipient_name;
    CLOSE c_sl_lender ;

    -- if recepient is servicer
  ELSIF l_v_recipient_type = 'SRVC' THEN

    OPEN  c_sl_servicer (cp_n_recipient_id => l_n_recipient_id);
    FETCH c_sl_servicer INTO l_n_servicer_id,l_v_recipient_name;
    CLOSE c_sl_servicer ;

  END IF;

  -- deriving the unique batch id

  l_v_batch_id := NULL;
  l_v_batch_id :=   '@A'
                   ||RPAD(NVL(l_n_recipient_id,' '),6)
                   ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),2)
                   ||TO_CHAR(SYSDATE,'YY')
                   ||RPAD(l_v_school_id,8)
                   ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4)
                   ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' Derived Unique Batchid           : '  ||l_v_batch_id
            );
  -- insert into cl batch table
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' Inserting into  igf_sl_cl_batch table '
            );
  l_v_rowid   :=  NULL;
  igf_sl_cl_batch_pkg.insert_row (
     x_mode                              => 'R'                            ,
     x_rowid                             => l_v_rowid                      ,
     x_cbth_id                           => l_n_cbth_id                    ,
     x_batch_id                          => l_v_batch_id                   ,
     x_file_creation_date                => TRUNC(SYSDATE)                 ,
     x_file_trans_date                   => TRUNC(SYSDATE)                 ,
     x_file_ident_code                   => RPAD(l_v_file_ident_code,5,' '),
     x_recipient_id                      => l_n_recipient_id               ,
     x_recip_non_ed_brc_id               => l_v_recip_non_edbrc_id         ,
     x_source_id                         => l_v_school_id                  ,
     x_source_non_ed_brc_id              => l_v_sch_non_ed_branch          ,
     x_send_resp                         =>  'S'                           ,
     x_record_count_num                  =>  NULL                          ,
     x_total_net_disb_amt                =>  NULL                          ,
     x_total_net_eft_amt                 =>  NULL                          ,
     x_total_net_non_eft_amt             =>  NULL                          ,
     x_total_reissue_amt                 =>  NULL                          ,
     x_total_cancel_amt                  =>  NULL                          ,
     x_total_deficit_amt                 =>  NULL                          ,
     x_total_net_cancel_amt              =>  NULL                          ,
     x_total_net_out_cancel_amt          =>  NULL
  );
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' Inserted successfully into  igf_sl_cl_batch table '
            );

  -- defining values for filler characters variables
  l_v_filler_2_char  := RPAD(' ',2,' ');
  l_v_filler_3_char  := RPAD(' ',3,' ');

  -- constructing change send header record
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' constructing change send header record '
            );
  l_v_chg_header_rec   :=   '@H'
                          ||RPAD('IGS',4,' ')
                          ||'1157'
                          ||RPAD(' ',12,' ')
                          ||l_v_file_crea_date
                          ||l_v_file_crea_time
                          ||l_v_file_crea_date
                          ||l_v_file_crea_time
                          ||RPAD(l_v_file_ident_name,19,' ')
                          ||RPAD(l_v_file_ident_code,5,' ')
                          ||RPAD(NVL(l_v_source_name,' '),32,' ')
                          ||RPAD(l_v_school_id,8,' ')
                          ||l_v_filler_2_char
                          ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                          ||'S'
                          ||RPAD(NVL(l_v_recipient_name,' '),32,' ')
                          ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                          ||l_v_filler_2_char
                          ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                          ||l_v_media_type
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',293,' ')
                          ||'*';
  l_v_chg_header_rec := UPPER(l_v_chg_header_rec);
  -- writing the change send header record on to output file
  fnd_file.put_line(fnd_file.output,l_v_chg_header_rec);
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' change send header record '||l_v_chg_header_rec
            );
  -- initializing the record counters for both @1 and @2 change send reccords for RELEASE-4
  l_n_1cntr   := 0;
  l_n_2cntr   := 0;

  -- initializing the borrower id to a dummy value
  l_n_borrower_id := -999;

  FOR  rec_c_recip_dtls IN  c_recip_dtls(
    cp_v_cal_type        =>  l_v_cal_type        ,
    cp_n_sequence_number =>  l_n_sequence_number ,
    cp_n_fund_id         =>  l_n_fund_id         ,
    cp_n_base_id         =>  l_n_base_id         ,
    cp_n_loan_id         =>  l_n_loan_id         ,
    cp_v_relationship_cd =>  l_v_relationship_cd ,
    cp_c_loan_chg_status =>  'V'                 ,
    cp_v_school_id       =>  l_v_school_id
  )
  LOOP
    -- derived SSN value is set to NULL initially
    l_v_ssn  := NULL;
    --One Borrower (@1-02) Detail Record in the file for each borrower
    IF (l_n_borrower_id <> rec_c_recip_dtls.borrower_id) THEN
      l_v_chg_01_2_rec     := NULL;
      l_n_borrower_id      := rec_c_recip_dtls.borrower_id;
      -- get the borrower details
      igf_sl_gen.get_person_details(rec_c_recip_dtls.borrower_id,c_borrower_dtls);
      FETCH c_borrower_dtls INTO rec_borrower_dtls;
      CLOSE c_borrower_dtls;
      -- constructing change send @1-02 record
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' constructing change send @1-02 record '
                );
      l_v_chg_01_2_rec     :=    '@1'
                               ||'02'
                               ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                               ||RPAD(l_v_school_id,8,' ')
                               ||l_v_filler_3_char
                               ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                               ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                               ||l_v_filler_3_char
                               ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                               ||RPAD(' ',12,' ')
                               ||RPAD(NVL(rec_borrower_dtls.p_last_name,' '),35,' ')
                               ||RPAD(NVL(rec_borrower_dtls.p_first_name,' '),12,' ')
                               ||RPAD(NVL(rec_borrower_dtls.p_middle_name,' '),1,' ')
                               ||LPAD(NVL(TO_CHAR(rec_borrower_dtls.p_date_of_birth,'YYYYMMDD'),'0'),8,'0')
                               ||' '
                               ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                               ||RPAD(' ',9,' ')
                               ||RPAD(' ',9,' ')
                               ||RPAD(' ',183,' ')
                               ||RPAD(' ',23,' ')
                               ||RPAD(' ',20,' ')
                               ||RPAD(' ',23,' ')
                               ||RPAD(' ',80,' ')
                               ||'*';
      l_v_chg_01_2_rec := UPPER(l_v_chg_01_2_rec);
      -- writing the change send @1-02 record on to output file
      fnd_file.put_line(fnd_file.output,l_v_chg_01_2_rec);
      l_n_1cntr   := l_n_1cntr + 1;
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' change send @1-02 record '||l_v_chg_01_2_rec
                );
    END IF;

    -- get the student details
    igf_sl_gen.get_person_details(rec_c_recip_dtls.student_id,c_student_dtls);
    FETCH c_student_dtls INTO rec_student_dtls;
    CLOSE c_student_dtls;

    -- derivation of loan type code
    IF rec_c_recip_dtls.fed_fund_code = 'ALT' THEN
      l_v_loan_type          := 'AL';
      l_v_alt_prog_type_code := rec_c_recip_dtls.alt_prog_type_code;
      IF (rec_c_recip_dtls.student_id <> rec_c_recip_dtls.borrower_id) THEN
        l_v_ssn              := rec_borrower_dtls.p_ssn;
      ELSIF (rec_c_recip_dtls.student_id = rec_c_recip_dtls.borrower_id) THEN
        l_v_ssn              := rec_student_dtls.p_ssn;
      END IF;
    ELSIF rec_c_recip_dtls.fed_fund_code = 'FLP' THEN
      l_v_loan_type          := 'PL';
      l_v_alt_prog_type_code := ' ';
      l_v_ssn                := rec_student_dtls.p_ssn;
    ELSIF rec_c_recip_dtls.fed_fund_code = 'FLS' THEN
      l_v_loan_type          := 'SF';
      l_v_alt_prog_type_code := ' ';
    ELSIF rec_c_recip_dtls.fed_fund_code = 'FLU' THEN
      l_v_loan_type          := 'SU';
      l_v_alt_prog_type_code := ' ';
	ELSIF rec_c_recip_dtls.fed_fund_code = 'GPLUSFL' THEN
	  l_v_loan_type     := 'GB';
	  l_v_ssn           := rec_student_dtls.p_ssn;
    END IF;
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' derived loan type code. loan type code : '||l_v_loan_type
              );
    -- obtain the efc
    igf_aw_packng_subfns.get_fed_efc(
      l_base_id         => rec_c_recip_dtls.base_id,
      l_awd_prd_code    => NULL,
      l_efc_f           => l_n_efc_f,
      l_pell_efc        => l_n_pell_efc,
      l_efc_ay          => l_n_efc
    );
    l_n_efc  := TRUNC(l_n_efc);
    l_n_coa  := rec_c_recip_dtls.coa_f;
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' Obtained efc and coa '||
                             ' l_n_efc  : '||l_n_efc ||
                             ' l_n_coa  : '||l_n_coa
              );
    -- obtaining the estimated financial aid for the base id
    OPEN cur_get_fin_aid (
      cp_n_award_id    => rec_c_recip_dtls.award_id,
      cp_n_base_id     => rec_c_recip_dtls.base_id ,
      cp_awd_status_1  => 'OFFERED'                ,
      cp_awd_status_2  => 'ACCEPTED'
    );
    FETCH cur_get_fin_aid INTO l_n_est_fin;
    CLOSE cur_get_fin_aid ;
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' Estimated  financial aid for the base id : '||l_n_est_fin
              );

    -- assigning the default loan periods from loan record
    l_d_old_per_begin_dt      :=  rec_c_recip_dtls.loan_per_begin_date ;
    l_d_revised_per_begin_dt  :=  rec_c_recip_dtls.loan_per_begin_date ;
    l_d_old_per_end_dt        :=  rec_c_recip_dtls.loan_per_end_date   ;
    l_d_revised_per_end_dt    :=  rec_c_recip_dtls.loan_per_end_date   ;
    l_n_reinstated_loan_amt   :=  0   ;
    l_d_cancellation_date     :=  NULL;
    l_c_01_07_flg             :=  'N' ;
    l_c_01_08_flg             :=  'N' ;
    l_c_01_09_flg             :=  'N' ;
    l_c_01_10_flg             :=  'N' ;
    l_c_01_24_flg             :=  'N' ;
    l_v_chg_01_7_rec          :=  NULL;
    l_v_chg_01_8_rec          :=  NULL;
    l_v_chg_01_9_rec          :=  NULL;
    l_v_chg_01_10_rec         :=  NULL;
    l_v_chg_01_24_rec         :=  NULL;
    l_n_disb_number           :=  -1  ;
    l_n_ctr_09                :=  0   ;
    l_n_ctr_10                :=  0   ;
    l_n_ctr_disb              :=  0   ;
    l_n_post_disb_number      :=  -1  ;
    l_n_loan_amt_increase     :=  NULL;

    FOR rec_c_sl_clchsn_dtls IN c_sl_clchsn_dtls (cp_v_loan_number => rec_c_recip_dtls.loan_number)
    LOOP
      --There must be one Loan Period Change (@1-07) Detail Record in the file for each loan
      --if revising loan period begin and end dates, student's grade level, and/or student's
      --anticipated completion dates. The @1-07 Detail Record can be submitted pre- or postdisbursement.
      IF rec_c_sl_clchsn_dtls.change_record_type_txt = '07' THEN
        l_c_01_07_flg    := 'Y';
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' (@1-07) Detail Record found '
                  );
        IF rec_c_sl_clchsn_dtls.change_field_code = 'LOAN_PER_BEGIN_DT'  AND
          rec_c_sl_clchsn_dtls.change_code_txt = 'A' THEN
          l_d_old_per_begin_dt      :=  rec_c_sl_clchsn_dtls.old_date;
          l_d_revised_per_begin_dt  :=  rec_c_sl_clchsn_dtls.new_date;
        ELSIF rec_c_sl_clchsn_dtls.change_field_code = 'LOAN_PER_END_DT'  AND
          rec_c_sl_clchsn_dtls.change_code_txt = 'A' THEN
          l_d_old_per_end_dt        :=  rec_c_sl_clchsn_dtls.old_date;
          l_d_revised_per_end_dt    :=  rec_c_sl_clchsn_dtls.new_date;
        END IF;
      END IF;

      -- There must be one Loan Cancellation/Reinstatement (@1-08) Detail Record in the file
      -- for each loan to be fully cancelled or fully/partially reinstated (pre-disbursement).
      IF rec_c_sl_clchsn_dtls.change_record_type_txt = '08'  THEN
        l_c_01_08_flg    := 'Y';
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' (@1-08) Detail Record found '
                  );
        -- Full Loan Cancellation
        IF rec_c_sl_clchsn_dtls.change_code_txt = 'A' THEN
          l_d_cancellation_date    :=  TRUNC(SYSDATE);
        -- Full/Partial Loan Reinstatement
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt = 'B' THEN
          l_n_reinstated_loan_amt  :=  rec_c_sl_clchsn_dtls.new_amt;
        END IF;
      END IF;

      -- There must be one Disbursement Cancellation/Change (@1-09) Detail Record in the
      -- file for each loan disbursement to be cancelled, reinstated, and/or rescheduled (predisbursement).
      -- One Disbursement Cancellation/Change (@1-09) Detail Record in the file for
      -- each disbursement (if applicable)
      IF rec_c_sl_clchsn_dtls.change_record_type_txt = '09' THEN
        l_c_01_09_flg          := 'Y';
         log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' (@1-09) Detail Record found '
                  );
        IF l_n_disb_number <> rec_c_sl_clchsn_dtls.disbursement_number THEN
          l_n_disb_number        := rec_c_sl_clchsn_dtls.disbursement_number;
          l_n_ctr_09             := l_n_ctr_09 + 1;
          OPEN c_aw_awd_disb2(
            cp_n_award_id    =>  rec_c_recip_dtls.award_id,
            cp_n_disb_num    =>  l_n_disb_number
          );
          FETCH c_aw_awd_disb2 INTO rec_c_aw_awd_disb2;
          CLOSE c_aw_awd_disb2 ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_number       := rec_c_aw_awd_disb2.disb_num          ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_date         := rec_c_aw_awd_disb2.disb_date         ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_date  := NULL ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_amt   := NULL ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_hold_rel_ind := NULL ;
          v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_date := rec_c_aw_awd_disb2.disb_date         ;
          v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt  := rec_c_aw_awd_disb2.disb_accepted_amt ;
          v_tab_rec_09_dtl(l_n_ctr_09).reinstate_ind     := 'N'  ;
        END IF;

        -- Disbursement Hold Release Change
        IF rec_c_sl_clchsn_dtls.change_code_txt    = 'E' THEN
          v_tab_rec_09_dtl(l_n_ctr_09).disb_hold_rel_ind := rec_c_sl_clchsn_dtls.new_value_txt ;
        -- Disbursement Reinstatement
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt = 'C' THEN
          v_tab_rec_09_dtl(l_n_ctr_09).reinstate_ind     := 'Y'  ;
        -- Disbursement Date Change
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt = 'B' THEN
          v_tab_rec_09_dtl(l_n_ctr_09).disb_date         :=  rec_c_sl_clchsn_dtls.old_date;
          v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_date :=  rec_c_sl_clchsn_dtls.new_date;
        -- New Disbursement Addition
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt = 'D' THEN
          v_tab_rec_09_dtl(l_n_ctr_09).disb_date         := NULL  ;
        -- Full cancellation
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt = 'ADI' THEN
          v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_date  :=  rec_c_sl_clchsn_dtls.disbursement_cancel_date ;
          v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_amt   :=  rec_c_sl_clchsn_dtls.disbursement_cancel_amt  ;
--MN 5-Jan-2005 Updated to send the revised amount and make the date NULL only if revised_disb_amt is 0
--          v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt  :=  NULL ;
          IF v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt = 0 THEN
            v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_date :=  NULL ;
          END IF;
        -- Disbursement amount change other than cancellation
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt IN ('A','AI','AD') THEN
          v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt :=  rec_c_sl_clchsn_dtls.new_amt ;
        END IF;
      END IF;

      -- There must be one Disbursement Notification/Change (@1-10) Detail Record in the
      -- file for each loan disbursement to be cancelled, reissued, reinstated, and/or rescheduled
      -- (post-disbursement).
      -- This detail record is submitted for each disbursement to be cancelled, rescheduled,
      -- reissued, and/or reinstated after the release of funds for the disbursement.
      IF rec_c_sl_clchsn_dtls.change_record_type_txt = '10' THEN
        l_c_01_10_flg    := 'Y';
         log_to_fnd(p_v_module => 'sub_create_file',
                    p_v_string => ' (@1-10) Detail Record found '
                  );
        IF l_n_post_disb_number <> rec_c_sl_clchsn_dtls.disbursement_number THEN
          l_n_post_disb_number   := rec_c_sl_clchsn_dtls.disbursement_number;
          l_n_ctr_10             := l_n_ctr_10 + 1;
          OPEN c_aw_awd_disb2(
            cp_n_award_id    =>  rec_c_recip_dtls.award_id,
            cp_n_disb_num    =>  l_n_post_disb_number
          );
          FETCH c_aw_awd_disb2 INTO rec_c_aw_awd_disb2;
          CLOSE c_aw_awd_disb2 ;
          v_tab_rec_10_dtl(l_n_ctr_10).disb_number             := rec_c_aw_awd_disb2.disb_num          ;
          v_tab_rec_10_dtl(l_n_ctr_10).disb_date               := rec_c_aw_awd_disb2.disb_date         ;
          v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_date        := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_amt         := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).disb_consummation_ind   := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).actual_return_amt       := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).fund_return_mthd_code   := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).fund_reissue_code       := NULL ;
          v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_date       := rec_c_aw_awd_disb2.disb_date         ;
          v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_amt        := rec_c_aw_awd_disb2.disb_accepted_amt ;
          v_tab_rec_10_dtl(l_n_ctr_10).reinstate_ind           := 'N'  ;
        END IF;
        -- Full or Partial Cancellation
        IF rec_c_sl_clchsn_dtls.change_code_txt    = 'A' THEN
          v_tab_rec_10_dtl(l_n_ctr_10).disb_consummation_ind   :=  'N';
          v_tab_rec_10_dtl(l_n_ctr_10).fund_return_mthd_code   :=  rec_c_sl_clchsn_dtls.disbursement_return_code ;
          v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_date       :=  NULL;
          v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_amt        :=  NULL;
          IF rec_c_sl_clchsn_dtls.change_field_code = 'DISB_AMOUNT' THEN
            v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_amt         :=  rec_c_sl_clchsn_dtls.disbursement_cancel_amt  ;
            l_n_actual_return_amt := NVL(rec_c_sl_clchsn_dtls.disbursement_cancel_amt,0) - (NVL(rec_c_aw_awd_disb2.fee_1,0) + NVL(rec_c_aw_awd_disb2.fee_2,0));
            v_tab_rec_10_dtl(l_n_ctr_10).actual_return_amt       :=  l_n_actual_return_amt;
          ELSIF rec_c_sl_clchsn_dtls.change_field_code = 'DISB_DATE' THEN
            v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_date        :=  rec_c_sl_clchsn_dtls.disbursement_cancel_date ;
          END IF;
        -- Full or Partial Reissue
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt    = 'B' THEN
          v_tab_rec_10_dtl(l_n_ctr_10).fund_return_mthd_code := rec_c_sl_clchsn_dtls.disbursement_return_code  ;
          v_tab_rec_10_dtl(l_n_ctr_10).fund_reissue_code     := rec_c_sl_clchsn_dtls.disbursement_reissue_code ;
          IF rec_c_sl_clchsn_dtls.change_field_code = 'DISB_DATE' THEN
            v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_date :=  rec_c_sl_clchsn_dtls.new_date;
          ELSIF rec_c_sl_clchsn_dtls.change_field_code = 'DISB_AMOUNT' THEN
            v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_date  :=  rec_c_sl_clchsn_dtls.disbursement_cancel_date ;
            v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_amt   :=  rec_c_sl_clchsn_dtls.disbursement_cancel_amt  ;
            l_n_actual_return_amt := NVL(rec_c_sl_clchsn_dtls.disbursement_cancel_amt,0) - (NVL(rec_c_aw_awd_disb2.fee_1,0) + NVL(rec_c_aw_awd_disb2.fee_2,0));
            v_tab_rec_10_dtl(l_n_ctr_10).actual_return_amt :=  l_n_actual_return_amt;
          END IF;
        -- Full or Partial Reinstatement
        ELSIF rec_c_sl_clchsn_dtls.change_code_txt    = 'C' THEN
          v_tab_rec_10_dtl(l_n_ctr_10).reinstate_ind       := 'Y'  ;
          IF rec_c_sl_clchsn_dtls.change_field_code = 'DISB_DATE' THEN
            v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_date :=  rec_c_sl_clchsn_dtls.new_date;
          END IF;
        END IF;
      END IF;
      -- There must be one Loan Increase (@1-24) Detail Record in the file for each loan
      -- increase request (pre- or post-disbursement).
      IF rec_c_sl_clchsn_dtls.change_record_type_txt = '24' THEN
         l_c_01_24_flg          :=  'Y';
         log_to_fnd(p_v_module => 'sub_create_file',
                    p_v_string => ' (@1-24) Detail Record found '
                  );
         l_n_loan_amt_increase  :=  rec_c_sl_clchsn_dtls.new_amt;
      END IF;

    END LOOP;

    IF l_c_01_07_flg = 'Y' THEN
      -- constructing change send (@1-07) record
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' constructing change send (@1-07) record '
                );
      l_v_chg_01_7_rec :=    '@1'
                           ||'07'
                           ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                           ||RPAD(l_v_school_id,8,' ')
                           ||l_v_filler_3_char
                           ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                           ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                           ||l_v_filler_3_char
                           ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                           ||RPAD(' ',16,' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.guarantee_date,'YYYYMMDD'),'0'),8,'0')
                           ||l_v_loan_type
                           ||RPAD(l_v_alt_prog_type_code,3,' ')
                           ||RPAD('0',8,'0')
                           ||RPAD(NVL(rec_c_recip_dtls.lender_id,' '),6,' ')
                           ||RPAD(' ',6,' ')
                           ||LPAD(NVL(TO_CHAR(l_d_old_per_begin_dt,'YYYYMMDD'),'0'),8,'0')
                           ||LPAD(NVL(TO_CHAR(l_d_old_per_end_dt,'YYYYMMDD'),'0'),8,'0')
                           ||l_v_filler_2_char
                           ||LPAD(NVL(l_v_ssn,' '),9,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.external_loan_id_txt,rec_c_recip_dtls.loan_number),17,' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.cl_seq_number),'0'),2,'0')
                           ||LPAD(NVL(TO_CHAR(l_d_revised_per_begin_dt,'YYYYMMDD'),'0'),8,'0')
                           ||LPAD(NVL(TO_CHAR(l_d_revised_per_end_dt,'YYYYMMDD'),'0'),8,'0')
                           ||NVL(NVL(rec_c_recip_dtls.override_grade_level_code,rec_c_recip_dtls.grade_level_code),' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.sch_cert_date,'YYYYMMDD'),'0'),8,'0')
                           ||' '
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.anticip_compl_date,'YYYYMMDD'),'0'),8,'0')
                           ||' '
                           ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                           ||RPAD(' ',9,' ')
                           ||RPAD(' ',9,' ')
                           ||RPAD(' ',9,' ')
                           ||RPAD(' ',9,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.lend_non_ed_brc_id,' '),4,' ')
                           ||RPAD(' ',100,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.school_use_txt,' '),23,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.lender_use_txt,' '),20,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.guarantor_use_txt,' '),23,' ')
                           ||RPAD(' ',80,' ')
                           ||'*';

      l_v_chg_01_7_rec := UPPER(l_v_chg_01_7_rec);
      -- writing the change send @1-07 record on to output file
      fnd_file.put_line(fnd_file.output,l_v_chg_01_7_rec);
      l_n_1cntr   := l_n_1cntr + 1;
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' change send @1-07 record '||l_v_chg_01_7_rec
                );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Invoking proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' with the send record text and to move status code to Sent for change send @1-07 record'
                );
      proc_update_clchsn_dtls_rec(
        p_v_loan_number        =>  rec_c_recip_dtls.loan_number ,
        p_v_change_record_typ  =>  '07'                         ,
        p_n_disb_num           =>  NULL                         ,
        p_v_send_record_txt    =>  SUBSTR(l_v_chg_01_7_rec,3,(INSTR(l_v_chg_01_7_rec,'*')-3))
      );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Successfully Invoked proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' for change send @1-07 record '
                );
    END IF;

    IF l_c_01_08_flg = 'Y' THEN
      -- constructing change send (@1-08) record
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' constructing change send (@1-08) record '
                );
      l_v_chg_01_8_rec :=   '@1'
                          ||'08'
                          ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                          ||RPAD(l_v_school_id,8,' ')
                          ||l_v_filler_3_char
                          ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                          ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                          ||l_v_filler_3_char
                          ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                          ||RPAD(' ',16,' ')
                          ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.guarantee_date,'YYYYMMDD'),'0'),8,'0')
                          ||l_v_loan_type
                          ||RPAD(l_v_alt_prog_type_code,3,' ')
                          ||RPAD('0',8,'0')
                          ||RPAD(NVL(rec_c_recip_dtls.lender_id,' '),6,' ')
                          ||RPAD(' ',6,' ')
                          ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')
                          ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')
                          ||l_v_filler_2_char
                          ||LPAD(NVL(l_v_ssn,' '),9,' ')
                          ||RPAD(NVL(rec_c_recip_dtls.external_loan_id_txt,rec_c_recip_dtls.loan_number),17,' ')
                          ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.cl_seq_number),'0'),2,'0')
                          ||LPAD(NVL(TO_CHAR(l_d_cancellation_date,'YYYYMMDD'),'0'),8,'0')
                          ||LPAD(TO_CHAR(NVL(l_n_reinstated_loan_amt * 100, '0')),8,'0')
                          ||' '
                          ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',202,' ')
                          ||RPAD(NVL(rec_c_recip_dtls.school_use_txt,' '),23,' ')
                          ||RPAD(NVL(rec_c_recip_dtls.lender_use_txt,' '),20,' ')
                          ||RPAD(NVL(rec_c_recip_dtls.guarantor_use_txt,' '),23,' ')
                          ||'*';

      l_v_chg_01_8_rec := UPPER(l_v_chg_01_8_rec);
      -- writing the change send @1-08 record on to output file
      fnd_file.put_line(fnd_file.output,l_v_chg_01_8_rec);
      l_n_1cntr   := l_n_1cntr + 1;
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' change send @1-08 record '||l_v_chg_01_8_rec
                );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Invoking proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' with the send record text and to move status code to Sent for change send @1-08 record'
                );
      proc_update_clchsn_dtls_rec(
        p_v_loan_number        =>  rec_c_recip_dtls.loan_number ,
        p_v_change_record_typ  =>  '08'                         ,
        p_n_disb_num           =>  NULL                         ,
        p_v_send_record_txt    =>  SUBSTR(l_v_chg_01_8_rec,3,(INSTR(l_v_chg_01_8_rec,'*')-3))
      );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Successfully Invoked proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' for change send @1-08 record '
                );
    END IF;

    IF l_c_01_09_flg = 'Y' THEN
      -- constructing change send (@1-09) record
      l_n_ctr_09 := 0;
      FOR l_n_ctr_09 IN v_tab_rec_09_dtl.FIRST..v_tab_rec_09_dtl.LAST
      LOOP
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' constructing change send (@1-09) record  for '                      ||
                                 ' disb number      : '||v_tab_rec_09_dtl(l_n_ctr_09).disb_number      ||
                                 ' l_n_ctr_09 value : '||l_n_ctr_09                                    ||
                                 ' disb_cancel_date : '||v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_date ||
                                 ' disb_cancel_amt  : '||v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_amt  ||
                                 ' disb_hold_rel_ind: '||v_tab_rec_09_dtl(l_n_ctr_09).disb_hold_rel_ind||
                                 ' revised_disb_date: '||v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_date||
                                 ' revised_disb_amt : '||v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt
                  );

        l_v_chg_01_9_rec :=    '@1'
                             ||'09'
                             ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                             ||RPAD(l_v_school_id,8,' ')
                             ||l_v_filler_3_char
                             ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                             ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                             ||l_v_filler_3_char
                             ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                             ||RPAD(' ',16,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.guarantee_date,'YYYYMMDD'),'0'),8,'0')
                             ||l_v_loan_type
                             ||RPAD(l_v_alt_prog_type_code,3,' ')
                             ||RPAD('0',8,'0')
                             ||RPAD(NVL(rec_c_recip_dtls.lender_id,' '),6,' ')
                             ||RPAD(' ',6,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')
                             ||l_v_filler_2_char
                             ||LPAD(NVL(l_v_ssn,' '),9,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.external_loan_id_txt,rec_c_recip_dtls.loan_number),17,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.cl_seq_number),'0'),2,'0')
                             ||' '
                             ||NVL(TO_CHAR(v_tab_rec_09_dtl(l_n_ctr_09).disb_number),' ')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_09_dtl(l_n_ctr_09).disb_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(TO_CHAR(NVL(v_tab_rec_09_dtl(l_n_ctr_09).disb_cancel_amt * 100, '0')),8,'0')
                             ||NVL(v_tab_rec_09_dtl(l_n_ctr_09).disb_hold_rel_ind,' ')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(TO_CHAR(NVL(v_tab_rec_09_dtl(l_n_ctr_09).revised_disb_amt * 100, '0')),8,'0')
                             ||NVL(v_tab_rec_09_dtl(l_n_ctr_09).reinstate_ind,' ')
                             ||' '
                             ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.lend_non_ed_brc_id,' '),4,' ')
                             ||RPAD('0',8,'0')
                             ||RPAD(' ',82,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.school_use_txt,' '),23,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.lender_use_txt,' '),20,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.guarantor_use_txt,' '),23,' ')
                             ||RPAD(' ',80,' ')
                             ||'*';

        l_v_chg_01_9_rec := UPPER(l_v_chg_01_9_rec);
        -- writing the change send @1-09 record on to output file
        fnd_file.put_line(fnd_file.output,l_v_chg_01_9_rec);
        l_n_1cntr   := l_n_1cntr + 1;
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' change send @1-09 record '||l_v_chg_01_9_rec
                  );
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' Invoking proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                                 ' with the send record text and to move status code to Sent for change send @1-09 record'
                  );
        proc_update_clchsn_dtls_rec(
          p_v_loan_number        =>  rec_c_recip_dtls.loan_number               ,
          p_v_change_record_typ  =>  '09'                                       ,
          p_n_disb_num           =>  v_tab_rec_09_dtl(l_n_ctr_09).disb_number   ,
          p_v_send_record_txt    =>  SUBSTR(l_v_chg_01_9_rec,3,(INSTR(l_v_chg_01_9_rec,'*')-3))
        );
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' Successfully Invoked proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                                 ' for change send @1-09 record '
                  );
      END LOOP;
      v_tab_rec_09_dtl.DELETE;
    END IF;

    IF l_c_01_10_flg = 'Y' THEN
      l_n_ctr_10  := 0;
      FOR l_n_ctr_10 IN v_tab_rec_10_dtl.FIRST..v_tab_rec_10_dtl.LAST
      LOOP
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' constructing change send (@1-10) record '
                  );
        l_v_chg_01_10_rec :=   '@1'
                             ||'10'
                             ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                             ||RPAD(l_v_school_id,8,' ')
                             ||l_v_filler_3_char
                             ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                             ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                             ||l_v_filler_3_char
                             ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                             ||RPAD(' ',16,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.guarantee_date,'YYYYMMDD'),'0'),8,'0')
                             ||l_v_loan_type
                             ||RPAD(l_v_alt_prog_type_code,3,' ')
                             ||RPAD('0',8,'0')
                             ||RPAD(NVL(rec_c_recip_dtls.lender_id,' '),6,' ')
                             ||RPAD(' ',6,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')
                             ||l_v_filler_2_char
                             ||LPAD(NVL(l_v_ssn,' '),9,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.external_loan_id_txt,rec_c_recip_dtls.loan_number),17,' ')
                             ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.cl_seq_number),'0'),2,'0')
                             ||' '
                             ||NVL(TO_CHAR(v_tab_rec_10_dtl(l_n_ctr_10).disb_number),' ')
                             ||RPAD('0',8,'0')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_10_dtl(l_n_ctr_10).disb_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD('0',8,'0')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(TO_CHAR(NVL(v_tab_rec_10_dtl(l_n_ctr_10).disb_cancel_amt * 100, '0')),8,'0')
                             ||NVL(v_tab_rec_10_dtl(l_n_ctr_10).disb_consummation_ind,' ')
                             ||LPAD(TO_CHAR(NVL(v_tab_rec_10_dtl(l_n_ctr_10).actual_return_amt * 100, '0')),8,'0')
                             ||NVL(v_tab_rec_10_dtl(l_n_ctr_10).fund_return_mthd_code,' ')
                             ||NVL(v_tab_rec_10_dtl(l_n_ctr_10).fund_reissue_code,' ')
                             ||LPAD(NVL(TO_CHAR(v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_date,'YYYYMMDD'),'0'),8,'0')
                             ||LPAD(TO_CHAR(NVL(v_tab_rec_10_dtl(l_n_ctr_10).revised_disb_amt * 100, '0')),8,'0')
                             ||NVL(v_tab_rec_10_dtl(l_n_ctr_10).reinstate_ind,' ')
                             ||' '
                             ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.lend_non_ed_brc_id,' '),4,' ')
                             ||RPAD('0',8,'0')
                             ||RPAD(' ',56,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.school_use_txt,' '),23,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.lender_use_txt,' '),20,' ')
                             ||RPAD(NVL(rec_c_recip_dtls.guarantor_use_txt,' '),23,' ')
                             ||RPAD(' ',80,' ')
                             ||'*';

        l_v_chg_01_10_rec := UPPER(l_v_chg_01_10_rec);
        -- writing the change send @1-10 record on to output file
        fnd_file.put_line(fnd_file.output,l_v_chg_01_10_rec);
        l_n_1cntr   := l_n_1cntr + 1;
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' change send @1-10 record '||l_v_chg_01_10_rec
                  );
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' Invoking proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                                 ' with the send record text and to move status code to Sent for change send @1-10 record'
                  );
        proc_update_clchsn_dtls_rec(
          p_v_loan_number        =>  rec_c_recip_dtls.loan_number               ,
          p_v_change_record_typ  =>  '10'                                       ,
          p_n_disb_num           =>  v_tab_rec_10_dtl(l_n_ctr_10).disb_number   ,
          p_v_send_record_txt    =>  SUBSTR(l_v_chg_01_10_rec,3,(INSTR(l_v_chg_01_10_rec,'*')-3))
        );
        log_to_fnd(p_v_module => 'sub_create_file',
                   p_v_string => ' Successfully Invoked proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                                 ' for change send @1-10 record '
                  );
      END LOOP;
      v_tab_rec_10_dtl.DELETE;
    END IF;

    IF l_c_01_24_flg = 'Y' THEN
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' constructing change send (@1-24) record '
                );
      -- bvisvana - Bug # 4575843 - Truncated the increase loan amount to avoid decimals.
      l_v_chg_01_24_rec :=   '@1'
                           ||'24'
                           ||RPAD(NVL(rec_borrower_dtls.p_ssn,' '),9,' ')
                           ||RPAD(l_v_school_id,8,' ')
                           ||l_v_filler_3_char
                           ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                           ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                           ||l_v_filler_3_char
                           ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                           ||RPAD(' ',16,' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.guarantee_date,'YYYYMMDD'),'0'),8,'0')
                           ||l_v_loan_type
                           ||RPAD(l_v_alt_prog_type_code,3,' ')
                           ||RPAD('0',8,'0')
                           ||RPAD(NVL(rec_c_recip_dtls.lender_id,' '),6,' ')
                           ||RPAD(' ',6,' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')
                           ||l_v_filler_2_char
                           ||LPAD(NVL(l_v_ssn,' '),9,' ')
                           ||RPAD(NVL(rec_c_recip_dtls.external_loan_id_txt,rec_c_recip_dtls.loan_number),17,' ')
                           ||LPAD(NVL(TO_CHAR(rec_c_recip_dtls.cl_seq_number),'0'),2,'0')
                           ||LPAD(TO_CHAR(NVL(TRUNC(l_n_loan_amt_increase),0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(TRUNC(l_n_loan_amt_increase),0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_coa,0)),5,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_efc,0)),5,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_est_fin,0)),5,'0');
      l_v_disb_rec := NULL;
      l_n_ctr_disb              :=  0   ;
      FOR  rec_c_aw_awd_disb IN c_aw_awd_disb ( cp_n_award_id => rec_c_recip_dtls.award_id)
      LOOP
        l_n_ctr_disb :=  NVL(l_n_ctr_disb,0) + 1;
        l_v_disb_rec :=   l_v_disb_rec
                        ||LPAD(NVL(TO_CHAR(rec_c_aw_awd_disb.disb_date,'YYYYMMDD'),'0'),8,'0')
                        ||LPAD(TO_CHAR(NVL(rec_c_aw_awd_disb.disb_accepted_amt * 100, '0')),8,'0');
      END LOOP;
      IF l_n_ctr_disb = 1 THEN
        l_v_chg_01_24_rec :=  l_v_chg_01_24_rec
                            ||l_v_disb_rec
                            ||RPAD('0',48,'0');
      ELSIF l_n_ctr_disb = 2 THEN
        l_v_chg_01_24_rec :=  l_v_chg_01_24_rec
                            ||l_v_disb_rec
                            ||RPAD('0',32,'0');
      ELSIF l_n_ctr_disb = 3 THEN
        l_v_chg_01_24_rec :=  l_v_chg_01_24_rec
                            ||l_v_disb_rec
                            ||RPAD('0',16,'0');
      ELSIF l_n_ctr_disb = 4 THEN
        l_v_chg_01_24_rec :=  l_v_chg_01_24_rec
                            ||l_v_disb_rec ;
      END IF;
      l_v_chg_01_24_rec  :=   l_v_chg_01_24_rec
                            ||' '
                            ||RPAD('0',8,'0')
                            ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS')||RPAD('0',6,'0')
                            ||RPAD(' ',9,' ')
                            ||RPAD(' ',9,' ')
                            ||RPAD(' ',9,' ')
                            ||RPAD(' ',9,' ')
                            ||RPAD(NVL(rec_c_recip_dtls.lend_non_ed_brc_id,' '),4,' ')
                            ||RPAD('0',8,'0')
                            ||l_v_filler_2_char
                            ||l_v_filler_2_char
                            ||l_v_filler_2_char
                            ||l_v_filler_2_char
                            ||RPAD(' ',19,' ')
                            ||RPAD(NVL(rec_c_recip_dtls.school_use_txt,' '),23,' ')
                            ||RPAD(NVL(rec_c_recip_dtls.lender_use_txt,' '),20,' ')
                            ||RPAD(NVL(rec_c_recip_dtls.guarantor_use_txt,' '),23,' ')
                            ||RPAD(' ',80,' ')
                            ||'*';

      l_v_chg_01_24_rec := UPPER(l_v_chg_01_24_rec);
      -- writing the change send @1-24 record on to output file
      fnd_file.put_line(fnd_file.output,l_v_chg_01_24_rec);
      l_n_1cntr   := l_n_1cntr + 1;
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' change send @1-24 record '||l_v_chg_01_24_rec
                );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Invoking proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' with the send record text and to move status code to Sent for change send @1-24 record'
                );
      proc_update_clchsn_dtls_rec(
        p_v_loan_number        =>  rec_c_recip_dtls.loan_number  ,
        p_v_change_record_typ  =>  '24'                          ,
        p_n_disb_num           =>  NULL                          ,
        p_v_send_record_txt    =>  SUBSTR(l_v_chg_01_24_rec,3,(INSTR(l_v_chg_01_24_rec,'*')-3))
      );
      log_to_fnd(p_v_module => 'sub_create_file',
                 p_v_string => ' Successfully Invoked proc_update_clchsn_dtls_rec to update the igf_sl_clchsn_dtls table ' ||
                               ' for change send @1-24 record '
                );
    END IF;

    -- invoke the igf_sl_gen.update_cl_chg_status to update the change status of loan table
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => 'invoking igf_sl_gen.update_cl_chg_status for loan number ='||rec_c_recip_dtls.loan_number
              );
    igf_sl_gen.update_cl_chg_status(p_v_loan_number => rec_c_recip_dtls.loan_number);
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' Call out to igf_sl_gen.update_cl_chg_status successful for loan number ='||rec_c_recip_dtls.loan_number
              );
    OPEN c_sl_lor_loc (
      cp_n_loan_id         => rec_c_recip_dtls.loan_id,
      cp_n_origination_id  => rec_c_recip_dtls.origination_id
    );
    FETCH c_sl_lor_loc INTO rec_c_sl_lor_loc;
    CLOSE c_sl_lor_loc ;

    rec_c_sl_lor_loc.loan_per_end_date   :=  l_d_revised_per_begin_dt;
    rec_c_sl_lor_loc.loan_per_end_date   :=  l_d_revised_per_end_dt  ;
    rec_c_sl_lor_loc.anticip_compl_date  :=  rec_c_recip_dtls.anticip_compl_date ;
    rec_c_sl_lor_loc.grade_level_code    :=  NVL(rec_c_recip_dtls.override_grade_level_code,rec_c_recip_dtls.grade_level_code);
    -- if no loan increase (@1-24), pass the same value originally present in the
    -- lor table for the input loan and origination id
    rec_c_sl_lor_loc.requested_loan_amt  :=  NVL(l_n_loan_amt_increase,rec_c_sl_lor_loc.requested_loan_amt);
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' invoking igf_sl_lor_loc_pkg.update_row for '  ||
                             ' loan id        = ' ||rec_c_recip_dtls.loan_id ||
                             ' Origination id = ' ||rec_c_sl_lor_loc.origination_id
              );
    igf_sl_lor_loc_pkg.update_row (
      x_rowid                             =>   rec_c_sl_lor_loc.row_id                        ,
      x_loan_id                           =>   rec_c_sl_lor_loc.loan_id                       ,
      x_origination_id                    =>   rec_c_sl_lor_loc.origination_id                ,
      x_loan_number                       =>   rec_c_sl_lor_loc.loan_number                   ,
      x_loan_type                         =>   rec_c_sl_lor_loc.loan_type                     ,
      x_loan_amt_offered                  =>   rec_c_sl_lor_loc.loan_amt_offered              ,
      x_loan_amt_accepted                 =>   rec_c_sl_lor_loc.loan_amt_accepted             ,
      x_loan_per_begin_date               =>   rec_c_sl_lor_loc.loan_per_begin_date           ,
      x_loan_per_end_date                 =>   rec_c_sl_lor_loc.loan_per_end_date             ,
      x_acad_yr_begin_date                =>   rec_c_sl_lor_loc.acad_yr_begin_date            ,
      x_acad_yr_end_date                  =>   rec_c_sl_lor_loc.acad_yr_end_date              ,
      x_loan_status                       =>   rec_c_sl_lor_loc.loan_status                   ,
      x_loan_status_date                  =>   rec_c_sl_lor_loc.loan_status_date              ,
      x_loan_chg_status                   =>   'S'                                            ,
      x_loan_chg_status_date              =>   TRUNC(SYSDATE)                                 ,
      x_req_serial_loan_code              =>   rec_c_sl_lor_loc.req_serial_loan_code          ,
      x_act_serial_loan_code              =>   rec_c_sl_lor_loc.act_serial_loan_code          ,
      x_active                            =>   rec_c_sl_lor_loc.active                        ,
      x_active_date                       =>   rec_c_sl_lor_loc.active_date                   ,
      x_sch_cert_date                     =>   rec_c_sl_lor_loc.sch_cert_date                 ,
      x_orig_status_flag                  =>   rec_c_sl_lor_loc.orig_status_flag              ,
      x_orig_batch_id                     =>   rec_c_sl_lor_loc.orig_batch_id                 ,
      x_orig_batch_date                   =>   rec_c_sl_lor_loc.orig_batch_date               ,
      x_chg_batch_id                      =>   rec_c_sl_lor_loc.chg_batch_id                  ,
      x_orig_ack_date                     =>   rec_c_sl_lor_loc.orig_ack_date                 ,
      x_credit_override                   =>   rec_c_sl_lor_loc.credit_override               ,
      x_credit_decision_date              =>   rec_c_sl_lor_loc.credit_decision_date          ,
      x_pnote_delivery_code               =>   rec_c_sl_lor_loc.pnote_delivery_code           ,
      x_pnote_status                      =>   rec_c_sl_lor_loc.pnote_status                  ,
      x_pnote_status_date                 =>   rec_c_sl_lor_loc.pnote_status_date             ,
      x_pnote_id                          =>   rec_c_sl_lor_loc.pnote_id                      ,
      x_pnote_print_ind                   =>   rec_c_sl_lor_loc.pnote_print_ind               ,
      x_pnote_accept_amt                  =>   rec_c_sl_lor_loc.pnote_accept_amt              ,
      x_pnote_accept_date                 =>   rec_c_sl_lor_loc.pnote_accept_date             ,
      x_p_signature_code                  =>   rec_c_sl_lor_loc.p_signature_code              ,
      x_p_signature_date                  =>   rec_c_sl_lor_loc.p_signature_date              ,
      x_s_signature_code                  =>   rec_c_sl_lor_loc.s_signature_code              ,
      x_unsub_elig_for_heal               =>   rec_c_sl_lor_loc.unsub_elig_for_heal           ,
      x_disclosure_print_ind              =>   rec_c_sl_lor_loc.disclosure_print_ind          ,
      x_orig_fee_perct                    =>   rec_c_sl_lor_loc.orig_fee_perct                ,
      x_borw_confirm_ind                  =>   rec_c_sl_lor_loc.borw_confirm_ind              ,
      x_borw_interest_ind                 =>   rec_c_sl_lor_loc.borw_interest_ind             ,
      x_unsub_elig_for_depnt              =>   rec_c_sl_lor_loc.unsub_elig_for_depnt          ,
      x_guarantee_amt                     =>   rec_c_sl_lor_loc.guarantee_amt                 ,
      x_guarantee_date                    =>   rec_c_sl_lor_loc.guarantee_date                ,
      x_guarnt_adj_ind                    =>   rec_c_sl_lor_loc.guarnt_adj_ind                ,
      x_guarnt_amt_redn_code              =>   rec_c_sl_lor_loc.guarnt_amt_redn_code          ,
      x_guarnt_status_code                =>   rec_c_sl_lor_loc.guarnt_status_code            ,
      x_guarnt_status_date                =>   rec_c_sl_lor_loc.guarnt_status_date            ,
      x_lend_apprv_denied_code            =>   rec_c_sl_lor_loc.lend_apprv_denied_code        ,
      x_lend_apprv_denied_date            =>   rec_c_sl_lor_loc.lend_apprv_denied_date        ,
      x_lend_status_code                  =>   rec_c_sl_lor_loc.lend_status_code              ,
      x_lend_status_date                  =>   rec_c_sl_lor_loc.lend_status_date              ,
      x_grade_level_code                  =>   rec_c_sl_lor_loc.grade_level_code              ,
      x_enrollment_code                   =>   rec_c_sl_lor_loc.enrollment_code               ,
      x_anticip_compl_date                =>   rec_c_sl_lor_loc.anticip_compl_date            ,
      x_borw_lender_id                    =>   rec_c_sl_lor_loc.borw_lender_id                ,
      x_duns_borw_lender_id               =>   rec_c_sl_lor_loc.duns_borw_lender_id           ,
      x_guarantor_id                      =>   rec_c_sl_lor_loc.guarantor_id                  ,
      x_duns_guarnt_id                    =>   rec_c_sl_lor_loc.duns_guarnt_id                ,
      x_prc_type_code                     =>   rec_c_sl_lor_loc.prc_type_code                 ,
      x_rec_type_ind                      =>   rec_c_sl_lor_loc.rec_type_ind                  ,
      x_cl_loan_type                      =>   rec_c_sl_lor_loc.cl_loan_type                  ,
      x_cl_seq_number                     =>   rec_c_sl_lor_loc.cl_seq_number                 ,
      x_last_resort_lender                =>   rec_c_sl_lor_loc.last_resort_lender            ,
      x_lender_id                         =>   rec_c_sl_lor_loc.lender_id                     ,
      x_duns_lender_id                    =>   rec_c_sl_lor_loc.duns_lender_id                ,
      x_lend_non_ed_brc_id                =>   rec_c_sl_lor_loc.lend_non_ed_brc_id            ,
      x_recipient_id                      =>   rec_c_sl_lor_loc.recipient_id                  ,
      x_recipient_type                    =>   rec_c_sl_lor_loc.recipient_type                ,
      x_duns_recip_id                     =>   rec_c_sl_lor_loc.duns_recip_id                 ,
      x_recip_non_ed_brc_id               =>   rec_c_sl_lor_loc.recip_non_ed_brc_id           ,
      x_cl_rec_status                     =>   rec_c_sl_lor_loc.cl_rec_status                 ,
      x_cl_rec_status_last_update         =>   rec_c_sl_lor_loc.cl_rec_status_last_update     ,
      x_alt_prog_type_code                =>   rec_c_sl_lor_loc.alt_prog_type_code            ,
      x_alt_appl_ver_code                 =>   rec_c_sl_lor_loc.alt_appl_ver_code             ,
      x_borw_outstd_loan_code             =>   rec_c_sl_lor_loc.borw_outstd_loan_code         ,
      x_mpn_confirm_code                  =>   rec_c_sl_lor_loc.mpn_confirm_code              ,
      x_resp_to_orig_code                 =>   rec_c_sl_lor_loc.resp_to_orig_code             ,
      x_appl_loan_phase_code              =>   rec_c_sl_lor_loc.appl_loan_phase_code          ,
      x_appl_loan_phase_code_chg          =>   rec_c_sl_lor_loc.appl_loan_phase_code_chg      ,
      x_tot_outstd_stafford               =>   rec_c_sl_lor_loc.tot_outstd_stafford           ,
      x_tot_outstd_plus                   =>   rec_c_sl_lor_loc.tot_outstd_plus               ,
      x_alt_borw_tot_debt                 =>   rec_c_sl_lor_loc.alt_borw_tot_debt             ,
      x_act_interest_rate                 =>   rec_c_sl_lor_loc.act_interest_rate             ,
      x_service_type_code                 =>   rec_c_sl_lor_loc.service_type_code             ,
      x_rev_notice_of_guarnt              =>   rec_c_sl_lor_loc.rev_notice_of_guarnt          ,
      x_sch_refund_amt                    =>   rec_c_sl_lor_loc.sch_refund_amt                ,
      x_sch_refund_date                   =>   rec_c_sl_lor_loc.sch_refund_date               ,
      x_uniq_layout_vend_code             =>   rec_c_sl_lor_loc.uniq_layout_vend_code         ,
      x_uniq_layout_ident_code            =>   rec_c_sl_lor_loc.uniq_layout_ident_code        ,
      x_p_person_id                       =>   rec_c_sl_lor_loc.p_person_id                   ,
      x_p_ssn                             =>   rec_c_sl_lor_loc.p_ssn                         ,
      x_p_ssn_chg_date                    =>   rec_c_sl_lor_loc.p_ssn_chg_date                ,
      x_p_last_name                       =>   rec_c_sl_lor_loc.p_last_name                   ,
      x_p_first_name                      =>   rec_c_sl_lor_loc.p_first_name                  ,
      x_p_middle_name                     =>   rec_c_sl_lor_loc.p_middle_name                 ,
      x_p_permt_addr1                     =>   rec_c_sl_lor_loc.p_permt_addr1                 ,
      x_p_permt_addr2                     =>   rec_c_sl_lor_loc.p_permt_addr2                 ,
      x_p_permt_city                      =>   rec_c_sl_lor_loc.p_permt_city                  ,
      x_p_permt_state                     =>   rec_c_sl_lor_loc.p_permt_state                 ,
      x_p_permt_zip                       =>   rec_c_sl_lor_loc.p_permt_zip                   ,
      x_p_permt_addr_chg_date             =>   rec_c_sl_lor_loc.p_permt_addr_chg_date         ,
      x_p_permt_phone                     =>   rec_c_sl_lor_loc.p_permt_phone                 ,
      x_p_email_addr                      =>   rec_c_sl_lor_loc.p_email_addr                  ,
      x_p_date_of_birth                   =>   rec_c_sl_lor_loc.p_date_of_birth               ,
      x_p_dob_chg_date                    =>   rec_c_sl_lor_loc.p_dob_chg_date                ,
      x_p_license_num                     =>   rec_c_sl_lor_loc.p_license_num                 ,
      x_p_license_state                   =>   rec_c_sl_lor_loc.p_license_state               ,
      x_p_citizenship_status              =>   rec_c_sl_lor_loc.p_citizenship_status          ,
      x_p_alien_reg_num                   =>   rec_c_sl_lor_loc.p_alien_reg_num               ,
      x_p_default_status                  =>   rec_c_sl_lor_loc.p_default_status              ,
      x_p_foreign_postal_code             =>   rec_c_sl_lor_loc.p_foreign_postal_code         ,
      x_p_state_of_legal_res              =>   rec_c_sl_lor_loc.p_state_of_legal_res          ,
      x_p_legal_res_date                  =>   rec_c_sl_lor_loc.p_legal_res_date              ,
      x_s_ssn                             =>   rec_c_sl_lor_loc.s_ssn                         ,
      x_s_ssn_chg_date                    =>   rec_c_sl_lor_loc.s_ssn_chg_date                ,
      x_s_last_name                       =>   rec_c_sl_lor_loc.s_last_name                   ,
      x_s_first_name                      =>   rec_c_sl_lor_loc.s_first_name                  ,
      x_s_middle_name                     =>   rec_c_sl_lor_loc.s_middle_name                 ,
      x_s_permt_addr1                     =>   rec_c_sl_lor_loc.s_permt_addr1                 ,
      x_s_permt_addr2                     =>   rec_c_sl_lor_loc.s_permt_addr2                 ,
      x_s_permt_city                      =>   rec_c_sl_lor_loc.s_permt_city                  ,
      x_s_permt_state                     =>   rec_c_sl_lor_loc.s_permt_state                 ,
      x_s_permt_zip                       =>   rec_c_sl_lor_loc.s_permt_zip                   ,
      x_s_permt_addr_chg_date             =>   rec_c_sl_lor_loc.s_permt_addr_chg_date         ,
      x_s_permt_phone                     =>   rec_c_sl_lor_loc.s_permt_phone                 ,
      x_s_local_addr1                     =>   rec_c_sl_lor_loc.s_local_addr1                 ,
      x_s_local_addr2                     =>   rec_c_sl_lor_loc.s_local_addr2                 ,
      x_s_local_city                      =>   rec_c_sl_lor_loc.s_local_city                  ,
      x_s_local_state                     =>   rec_c_sl_lor_loc.s_local_state                 ,
      x_s_local_zip                       =>   rec_c_sl_lor_loc.s_local_zip                   ,
      x_s_local_addr_chg_date             =>   rec_c_sl_lor_loc.s_local_addr_chg_date         ,
      x_s_email_addr                      =>   rec_c_sl_lor_loc.s_email_addr                  ,
      x_s_date_of_birth                   =>   rec_c_sl_lor_loc.s_date_of_birth               ,
      x_s_dob_chg_date                    =>   rec_c_sl_lor_loc.s_dob_chg_date                ,
      x_s_license_num                     =>   rec_c_sl_lor_loc.s_license_num                 ,
      x_s_license_state                   =>   rec_c_sl_lor_loc.s_license_state               ,
      x_s_depncy_status                   =>   rec_c_sl_lor_loc.s_depncy_status               ,
      x_s_default_status                  =>   rec_c_sl_lor_loc.s_default_status              ,
      x_s_citizenship_status              =>   rec_c_sl_lor_loc.s_citizenship_status          ,
      x_s_alien_reg_num                   =>   rec_c_sl_lor_loc.s_alien_reg_num               ,
      x_s_foreign_postal_code             =>   rec_c_sl_lor_loc.s_foreign_postal_code         ,
      x_mode                              =>   'R'                                            ,
      x_pnote_batch_id                    =>   rec_c_sl_lor_loc.pnote_batch_id                ,
      x_pnote_ack_date                    =>   rec_c_sl_lor_loc.pnote_ack_date                ,
      x_pnote_mpn_ind                     =>   rec_c_sl_lor_loc.pnote_mpn_ind                 ,
      x_award_id                          =>   rec_c_sl_lor_loc.award_id                      ,
      x_base_id                           =>   rec_c_sl_lor_loc.base_id                       ,
      x_document_id_txt                   =>   rec_c_sl_lor_loc.document_id_txt               ,
      x_loan_key_num                      =>   rec_c_sl_lor_loc.loan_key_num                  ,
      x_interest_rebate_percent_num       =>   rec_c_sl_lor_loc.interest_rebate_percent_num   ,
      x_fin_award_year                    =>   rec_c_sl_lor_loc.fin_award_year                ,
      x_cps_trans_num                     =>   rec_c_sl_lor_loc.cps_trans_num                 ,
      x_atd_entity_id_txt                 =>   rec_c_sl_lor_loc.atd_entity_id_txt             ,
      x_rep_entity_id_txt                 =>   rec_c_sl_lor_loc.rep_entity_id_txt             ,
      x_source_entity_id_txt              =>   rec_c_sl_lor_loc.source_entity_id_txt          ,
      x_pymt_servicer_amt                 =>   rec_c_sl_lor_loc.pymt_servicer_amt             ,
      x_pymt_servicer_date                =>   rec_c_sl_lor_loc.pymt_servicer_date            ,
      x_book_loan_amt                     =>   rec_c_sl_lor_loc.book_loan_amt                 ,
      x_book_loan_amt_date                =>   rec_c_sl_lor_loc.book_loan_amt_date            ,
      x_s_chg_birth_date                  =>   rec_c_sl_lor_loc.s_chg_birth_date              ,
      x_s_chg_ssn                         =>   rec_c_sl_lor_loc.s_chg_ssn                     ,
      x_s_chg_last_name                   =>   rec_c_sl_lor_loc.s_chg_last_name               ,
      x_b_chg_birth_date                  =>   rec_c_sl_lor_loc.b_chg_birth_date              ,
      x_b_chg_ssn                         =>   rec_c_sl_lor_loc.b_chg_ssn                     ,
      x_b_chg_last_name                   =>   rec_c_sl_lor_loc.b_chg_last_name               ,
      x_note_message                      =>   rec_c_sl_lor_loc.note_message                  ,
      x_full_resp_code                    =>   rec_c_sl_lor_loc.full_resp_code                ,
      x_s_permt_county                    =>   rec_c_sl_lor_loc.s_permt_county                ,
      x_b_permt_county                    =>   rec_c_sl_lor_loc.b_permt_county                ,
      x_s_permt_country                   =>   rec_c_sl_lor_loc.s_permt_country               ,
      x_b_permt_country                   =>   rec_c_sl_lor_loc.b_permt_country               ,
      x_crdt_decision_status              =>   rec_c_sl_lor_loc.crdt_decision_status          ,
      x_external_loan_id_txt              =>   rec_c_sl_lor_loc.external_loan_id_txt          ,
      x_deferment_request_code            =>   rec_c_sl_lor_loc.deferment_request_code        ,
      x_eft_authorization_code            =>   rec_c_sl_lor_loc.eft_authorization_code        ,
      x_requested_loan_amt                =>   rec_c_sl_lor_loc.requested_loan_amt            ,
      x_actual_record_type_code           =>   rec_c_sl_lor_loc.actual_record_type_code       ,
      x_reinstatement_amt                 =>   rec_c_sl_lor_loc.reinstatement_amt             ,
      x_lender_use_txt                    =>   rec_c_sl_lor_loc.lender_use_txt                ,
      x_guarantor_use_txt                 =>   rec_c_sl_lor_loc.guarantor_use_txt             ,
      x_fls_approved_amt                  =>   rec_c_sl_lor_loc.fls_approved_amt              ,
      x_flu_approved_amt                  =>   rec_c_sl_lor_loc.flu_approved_amt              ,
      x_flp_approved_amt                  =>   rec_c_sl_lor_loc.flp_approved_amt              ,
      x_alt_approved_amt                  =>   rec_c_sl_lor_loc.alt_approved_amt              ,
      x_loan_app_form_code                =>   rec_c_sl_lor_loc.loan_app_form_code            ,
      x_alt_borrower_ind_flag             =>   rec_c_sl_lor_loc.alt_borrower_ind_flag         ,
      x_school_id_txt                     =>   rec_c_sl_lor_loc.school_id_txt                 ,
      x_cost_of_attendance_amt            =>   rec_c_sl_lor_loc.cost_of_attendance_amt        ,
      x_established_fin_aid_amount        =>   rec_c_sl_lor_loc.established_fin_aid_amount    ,
      x_student_electronic_sign_flag      =>   rec_c_sl_lor_loc.student_electronic_sign_flag  ,
      x_mpn_type_flag                     =>   rec_c_sl_lor_loc.mpn_type_flag                 ,
      x_school_use_txt                    =>   rec_c_sl_lor_loc.school_use_txt                ,
      x_expect_family_contribute_amt      =>   rec_c_sl_lor_loc.expect_family_contribute_amt  ,
      x_borower_electronic_sign_flag      =>   rec_c_sl_lor_loc.borower_electronic_sign_flag  ,
      x_borower_credit_authoriz_flag      =>   rec_c_sl_lor_loc.borower_credit_authoriz_flag  ,
      x_esign_src_typ_cd                  =>   rec_c_sl_lor_loc.esign_src_typ_cd
    );
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' Call out to igf_sl_lor_loc_pkg.update_row for '      ||
                             ' loan id        = ' ||rec_c_sl_lor_loc.loan_id        ||
                             ' Origination id = ' ||rec_c_sl_lor_loc.origination_id ||
                             ' Successful. Updated the change status to Sent '
              );
  END LOOP;

  -- constructing change send trailer record
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' constructing change send trailer record '
            );
  l_v_chg_trailer_rec  :=   '@T'
                          ||LPAD(TO_CHAR(NVL(l_n_1cntr,0)),6,'0')
                          ||LPAD(TO_CHAR(NVL(l_n_2cntr,0)),6,'0')
                          ||l_v_file_crea_date
                          ||l_v_file_crea_time
                          ||RPAD(l_v_file_ident_code,5,' ')
                          ||RPAD(NVL(l_v_source_name,' '),32,' ')
                          ||RPAD(l_v_school_id,8,' ')
                          ||l_v_filler_2_char
                          ||RPAD(NVL(l_v_sch_non_ed_branch,' '),4,' ')
                          ||RPAD(NVL(l_v_recipient_name,' '),32,' ')
                          ||RPAD(NVL(l_n_recipient_id,' '),8,' ')
                          ||l_v_filler_2_char
                          ||RPAD(NVL(l_v_recip_non_edbrc_id,' '),4,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',9,' ')
                          ||RPAD(' ',336,' ')
                          ||'*';
  l_v_chg_trailer_rec := UPPER(l_v_chg_trailer_rec);
  -- writing the change send trailer record on to output file
  fnd_file.put_line(fnd_file.output,l_v_chg_trailer_rec);
  log_to_fnd(p_v_module => 'sub_create_file',
             p_v_string => ' change send trailer record '||l_v_chg_trailer_rec
            );

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK TO sub_create_file;
    log_to_fnd(p_v_module => 'sub_create_file',
               p_v_string => ' when others exception handler ' ||SQLERRM
              );
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
    igs_ge_msg_stack.conc_exception_hndl;
END sub_create_file;

PROCEDURE proc_update_clchsn_dtls_rec(p_v_loan_number        IN  igf_sl_loans.loan_number%TYPE                  ,
                                      p_v_change_record_typ  IN  igf_sl_clchsn_dtls.change_record_type_txt%TYPE ,
                                      p_n_disb_num           IN  igf_aw_awd_disb_all.disb_num%TYPE              ,
                                      p_v_send_record_txt    IN  igf_sl_clchsn_dtls.send_record_txt%TYPE
                                      ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 16 November 2004
--
-- Purpose:
-- Invoked     : from sub_create_file procedure
-- Function    :
--
-- Parameters  : p_v_loan_number       : IN parameter. Required.
--               p_v_change_record_typ : IN parameter. Required.
--               p_n_disb_num          : IN parameter. Required.
--               p_v_send_record_txt   : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR  c_sl_clchsn_dtls (cp_v_loan_number        IN  igf_sl_loans_all.loan_number%TYPE              ,
                            cp_v_change_record_typ  IN  igf_sl_clchsn_dtls.change_record_type_txt%TYPE ,
                            cp_n_disb_num           IN  igf_aw_awd_disb_all.disb_num%TYPE
                            ) IS
  SELECT  chdt.ROWID row_id
         ,chdt.*
  FROM    igf_sl_clchsn_dtls chdt
  WHERE   chdt.loan_number_txt        = cp_v_loan_number
  AND     chdt.change_record_type_txt = cp_v_change_record_typ
  AND     ((chdt.disbursement_number  = cp_n_disb_num) OR (cp_n_disb_num IS NULL))
  AND     chdt.status_code ='R'
  ORDER BY loan_number_txt,change_record_type_txt,disbursement_number;

  rec_c_sl_clchsn_dtls     c_sl_clchsn_dtls%ROWTYPE;

  l_v_loan_number          igf_sl_loans.loan_number%TYPE                  ;
  l_v_change_record_typ    igf_sl_clchsn_dtls.change_record_type_txt%TYPE ;
  l_n_disb_num             igf_aw_awd_disb_all.disb_num%TYPE              ;
  l_v_send_record_txt      igf_sl_clchsn_dtls.send_record_txt%TYPE        ;
BEGIN
  log_to_fnd(p_v_module => 'proc_update_clchsn_dtls_rec',
             p_v_string => ' Entered Procedure proc_update_clchsn_dtls_rec: The input parameters are '||
                           ' p_v_loan_number          : '  ||p_v_loan_number         ||
                           ' p_v_change_record_typ    : '  ||p_v_change_record_typ   ||
                           ' p_n_disb_num             : '  ||p_n_disb_num            ||
                           ' p_v_send_record_txt      : '  ||p_v_send_record_txt
            );

  l_v_loan_number          :=  p_v_loan_number       ;
  l_v_change_record_typ    :=  p_v_change_record_typ ;
  l_n_disb_num             :=  p_n_disb_num          ;
  l_v_send_record_txt      :=  p_v_send_record_txt   ;

  FOR rec_c_sl_clchsn_dtls IN c_sl_clchsn_dtls (
    cp_v_loan_number        =>  l_v_loan_number       ,
    cp_v_change_record_typ  =>  l_v_change_record_typ ,
    cp_n_disb_num           =>  l_n_disb_num
  )
  LOOP
    log_to_fnd(p_v_module => 'proc_update_clchsn_dtls_rec',
               p_v_string => 'invoking igf_sl_clchsn_dtls_pkg.update_row for change send id ='||rec_c_sl_clchsn_dtls.clchgsnd_id
               );

    igf_sl_clchsn_dtls_pkg.update_row (
      x_rowid                             =>    rec_c_sl_clchsn_dtls.row_id                        ,
      x_clchgsnd_id                       =>    rec_c_sl_clchsn_dtls.clchgsnd_id                   ,
      x_award_id                          =>    rec_c_sl_clchsn_dtls.award_id                      ,
      x_loan_number_txt                   =>    rec_c_sl_clchsn_dtls.loan_number_txt               ,
      x_cl_version_code                   =>    rec_c_sl_clchsn_dtls.cl_version_code               ,
      x_change_field_code                 =>    rec_c_sl_clchsn_dtls.change_field_code             ,
      x_change_record_type_txt            =>    rec_c_sl_clchsn_dtls.change_record_type_txt        ,
      x_change_code_txt                   =>    rec_c_sl_clchsn_dtls.change_code_txt               ,
      x_status_code                       =>    'S'                                                ,
      x_status_date                       =>    rec_c_sl_clchsn_dtls.status_date                   ,
      x_response_status_code              =>    rec_c_sl_clchsn_dtls.response_status_code          ,
      x_old_value_txt                     =>    rec_c_sl_clchsn_dtls.old_value_txt                 ,
      x_new_value_txt                     =>    rec_c_sl_clchsn_dtls.new_value_txt                 ,
      x_old_date                          =>    rec_c_sl_clchsn_dtls.old_date                      ,
      x_new_date                          =>    rec_c_sl_clchsn_dtls.new_date                      ,
      x_old_amt                           =>    rec_c_sl_clchsn_dtls.old_amt                       ,
      x_new_amt                           =>    rec_c_sl_clchsn_dtls.new_amt                       ,
      x_disbursement_number               =>    rec_c_sl_clchsn_dtls.disbursement_number           ,
      x_disbursement_date                 =>    rec_c_sl_clchsn_dtls.disbursement_date             ,
      x_change_issue_code                 =>    rec_c_sl_clchsn_dtls.change_issue_code             ,
      x_disbursement_cancel_date          =>    rec_c_sl_clchsn_dtls.disbursement_cancel_date      ,
      x_disbursement_cancel_amt           =>    rec_c_sl_clchsn_dtls.disbursement_cancel_amt       ,
      x_disbursement_revised_amt          =>    rec_c_sl_clchsn_dtls.disbursement_revised_amt      ,
      x_disbursement_revised_date         =>    rec_c_sl_clchsn_dtls.disbursement_revised_date     ,
      x_disbursement_reissue_code         =>    rec_c_sl_clchsn_dtls.disbursement_reissue_code     ,
      x_disbursement_reinst_code          =>    rec_c_sl_clchsn_dtls.disbursement_reinst_code      ,
      x_disbursement_return_amt           =>    rec_c_sl_clchsn_dtls.disbursement_return_amt       ,
      x_disbursement_return_date          =>    rec_c_sl_clchsn_dtls.disbursement_return_date      ,
      x_disbursement_return_code          =>    rec_c_sl_clchsn_dtls.disbursement_return_code      ,
      x_post_with_disb_return_amt         =>    rec_c_sl_clchsn_dtls.post_with_disb_return_amt     ,
      x_post_with_disb_return_date        =>    rec_c_sl_clchsn_dtls.post_with_disb_return_date    ,
      x_post_with_disb_return_code        =>    rec_c_sl_clchsn_dtls.post_with_disb_return_code    ,
      x_prev_with_disb_return_amt         =>    rec_c_sl_clchsn_dtls.prev_with_disb_return_amt     ,
      x_prev_with_disb_return_date        =>    rec_c_sl_clchsn_dtls.prev_with_disb_return_date    ,
      x_school_use_txt                    =>    rec_c_sl_clchsn_dtls.school_use_txt                ,
      x_lender_use_txt                    =>    rec_c_sl_clchsn_dtls.lender_use_txt                ,
      x_guarantor_use_txt                 =>    rec_c_sl_clchsn_dtls.guarantor_use_txt             ,
      x_validation_edit_txt               =>    rec_c_sl_clchsn_dtls.validation_edit_txt           ,
      x_send_record_txt                   =>    l_v_send_record_txt                                ,
      x_mode                              =>    'R'
    );
    log_to_fnd(p_v_module => 'proc_update_clchsn_dtls_rec',
               p_v_string => 'Call out to igf_sl_clchsn_dtls_pkg.update_row successful for change send id ='||rec_c_sl_clchsn_dtls.clchgsnd_id
              );

  END LOOP;

END proc_update_clchsn_dtls_rec;

END igf_sl_cl_chg_file;

/
