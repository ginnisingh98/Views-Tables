--------------------------------------------------------
--  DDL for Package Body IGF_SP_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_ROLLOVER" AS
/* $Header: IGFSP02B.pls 120.8 2006/06/12 08:10:48 skharida ship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2002
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --skharida    12-Jun-2006     Bug#5093981 Modified the procedure sponsor_student_rollover
  --gurprsin    31-May-2006     Bug 5213852,Modification done to sponsor_student_rollover,
  --                            sponsor_fund_roll_over procedure to Log the new messages
  --                            'IGF_SP_NO_STDREL_TERM_MAP', 'IGF_SP_NO_FUND_TERM_MAP' respectively
  --                            and removed the code logic to log 'IGF_AW_FND_RLOVR_LD_NTFND'
  --                            as the later message is obsoleted.
  --sapanigr    03-May-2006     Enh#3924836 Precision Issue. Modified sponsor_fund_rollover and sponsor_student_rollover
  --akandreg    29-Mar-2006     Bug 4765537. Passed appropriate values to parameters x_lock_award_flag,
  --                            x_donot_repkg_if_code ,x_re_pkg_verif_flag of igf_aw_fund_mast_pkg.insert_row
  --museshad    14-Jul-2005     Build FA 140.
  --                            Modified TBH call due to the addition of new
  --                            columns to igf_aw_fund_mast_all table.
  --museshad    25-May-2005     Build FA 157.
  --                            New column 'DISB_ROUNDING_CODE' has been added
  --                            to the table 'IGF_AW_FUND_MAST_ALL'.
  --                            Modified calls to TBH.
  --brajendr    13-Oct-2004     FA152 COA and FA137 Repackaging design changes
  --                            Added the new column to the form and the TBH calls
  --veramach    July 2004       FA 151 HR Integration(bug #3709292)
  --                            Impact of obsoleting columns from fund manager
  --vvutukur    18-Jul-2003     Enh#3038511.FICR106 Build. Modified procedure sponsor_rollover.
  --pathipat   28-Apr-2003      Enh 2831569 - Commercial Receivables build
  --                            Modified sponsor_rollover() - Added call to chk_manage_account()
  --vvutukur   25-Mar-2003      Bug#2822725.Modified procedures sponsor_fund_rollover,sponsor_student_rollover to remove parameters
  --                            p_cal_type,p_sequence_number and from cursor c_igf_aw_fund_mast and its usage.Modified function lookup_desc.
  --vchappid   18-Feb-2003      Bug 2785649, Sponsor Code is made mandatory. Modified cursor c_igf_aw_fund_mast
  --                            for removing handling NULL value of Fund ID input parameter
  --                            Fund Id is made mandatory. When this parameter is null, process will error out
  --adhawan    06-nov-2002      Obsoletion of sap_type from the tbh of igf_aw_fund_mast_pkg
  --2613536
  -- adhawan   31-oct-2002      Added gift_aid to insert row of Fund Manager
  --2613546
  -------------------------------------------------------------------

   g_c_fund_type CONSTANT VARCHAR2(10) := 'SPONSOR';
   g_c_yes CONSTANT VARCHAR2(1) := 'Y';
   g_c_no  CONSTANT VARCHAR2(1) := 'N';


   -- Declare an User-Defined exception for handling known error conditions
   do_nothing  EXCEPTION;

  -- Forward declaration of the functions, procedures used in the package body
  -- The functions/procedures referred are private to the package body

  -- function to return meaning for the lookup code and lookup type passed
  -- as parameter.
  FUNCTION    lookup_desc( p_type IN VARCHAR2 ,
                           p_code IN VARCHAR2
                         ) RETURN VARCHAR2;

  -- procedure to log the messages
  PROCEDURE   log_messages ( p_msg_name  IN VARCHAR2 ,
                             p_msg_val   IN VARCHAR2
                           ) ;

  -- function to validate the fund
  FUNCTION   validate_fund(p_fund             IN  igf_aw_fund_mast.fund_id%TYPE ,
                           p_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                           p_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
                           p_err_message      OUT NOCOPY VARCHAR2
                          ) RETURN BOOLEAN;

  -- function to validate award year
  FUNCTION   validate_award_year(p_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                                 p_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
                                 p_err_message      OUT NOCOPY VARCHAR2
                                ) RETURN BOOLEAN;

  -- procedure which rollover over the sponsor fund details
  PROCEDURE   sponsor_fund_rollover ( p_sc_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                      p_sc_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                      p_fund         IN  igf_aw_fund_mast_all.fund_id%TYPE
                                     ) ;

  -- procedure which rollover over the sponsor student relation
  PROCEDURE   sponsor_student_rollover ( p_sc_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                         p_sc_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                         p_fund         IN  igf_aw_fund_mast_all.fund_id%TYPE
                                        );

  -- Forward declaration of functions/procedures ends here

  -- cursor to select fund code from igf_aw_fund_mast to get fund code for fund id parameter
  -- This cursor definition is public to this package body;
  CURSOR   c_igf_aw_fund_mast(cp_fund_id          igf_aw_fund_mast.fund_id%TYPE)  IS
  SELECT   fmast.*
  FROM     igf_aw_fund_mast fmast ,
           igf_aw_fund_cat fcat
  WHERE    fmast.fund_code   = fcat.fund_code
  AND      fmast.fund_id   = cp_fund_id
  AND      fcat.sys_fund_type = g_c_fund_type
  AND      fmast.discontinue_fund = g_c_no;


    -- cursor to retrieve the succeeding year for the current award year passed as
    -- parameter to it.
    CURSOR   c_igf_aw_cal_rel(cp_cal_type  igs_ca_inst.cal_type%TYPE,
                              cp_seq_num   igs_ca_inst.sequence_number%TYPE
                             ) IS
    SELECT   sc_cal_type       , sc_sequence_number,
             sc_alternate_code , sc_start_dt,
             sc_end_dt
    FROM     igf_aw_cal_rel_v
    WHERE    cr_cal_type         = cp_cal_type
    AND      cr_sequence_number  = cp_seq_num
    AND      active              = 'Y';


  -- This procedure is being invoked directly from the concurrent manager
  PROCEDURE sponsor_rollover ( errbuf           OUT NOCOPY VARCHAR2                  ,
                               retcode          OUT NOCOPY NUMBER                    ,
                               p_award_year     IN  VARCHAR2                         ,
                               p_rollover       IN  VARCHAR2                         ,
                               p_fund_id        IN  igf_aw_fund_mast_all.fund_id%TYPE,
                               p_run_mode       IN  VARCHAR2
                           ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2002
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vvutukur   20-Jul-2003      Enh#3038511.FICR106 Build. Added call to generic procedure
  --                            igs_fi_crdapi_util.get_award_year_status to validate the Status of the
  --                            Award Year passed as parameter to this proces and also the status of its Succeeding Award Year.
  --pathipat   28-Apr-2003      Enh 2831569 - Commercial Receivables build
  --                            Added check for manage_accounts - call to chk_manage_account()
  --vvutukur   25-Mar-2003      Bug#2822725.Modified the calls to sponsor_fund_rollover to remove parameters p_cal_type,p_sequence_number.Also
  --                            modified the cursor c_igs_lookups to check for sysdate falling between lookup start and end dates and enabled_flag.
  --                            Added tokens to the message IGF_AW_AWD_MAP_NOT_FND.
  --vchappid   18-Feb-2003      Bug 2785649, Fund Id is made mandatory. When this parameter is null then
  --                            the process will error out
  ------------------------------------------------------------------
    -- Cursor to select meaning associated with the run mode passed as parameter
    -- to the process
    CURSOR  c_igs_lookups(cp_run_flag VARCHAR2) IS
    SELECT  meaning
    FROM    igs_lookup_values
    WHERE   lookup_type= 'YES_NO'
    AND     lookup_code= cp_run_flag
    AND     NVL(enabled_flag,'N') = 'Y'
    AND     TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
                               AND TRUNC(NVL(end_date_active,SYSDATE));

    -- cursor variable for c_igs_lookups
    l_c_igs_lookups  c_igs_lookups%ROWTYPE;

    l_ans                  BOOLEAN      := FALSE ;
    l_appl_name            VARCHAR2(30) := NULL;
    l_cal_type             igs_ca_inst_all.cal_type%TYPE;
    l_sequence_number      igs_ca_inst_all.sequence_number%TYPE;
    l_sc_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_sc_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_err_message          VARCHAR2(30);
    -- cursor variable for c_igf_aw_cal_rel
    l_c_igf_aw_cal_rel  c_igf_aw_cal_rel%ROWTYPE;
    -- cursor variable for c_igf_aw_fund_mast
    l_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;

    l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
    l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;

    l_v_awd_yr_status_cd   igf_ap_batch_aw_map.award_year_status_code%TYPE;

  BEGIN
    -- sets the orgid
    igf_aw_gen.set_org_id(p_context  => NULL) ;
    -- initialises the retcode parameter to 0
    retcode := 0 ;

    -- Extract calendar type and Sequence number from award year parameter passed to the process
    l_cal_type        := RTRIM(SUBSTR(p_award_year ,1,10));
    l_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

    -- get the meaning of the run mode parameter passed to the process
    OPEN   c_igs_lookups(cp_run_flag => p_run_mode);
    FETCH  c_igs_lookups INTO l_c_igs_lookups;
    CLOSE  c_igs_lookups;

    -- get sponsor fund code from igf_aw_fund_mast to get fund code for fund id parameter
    OPEN   c_igf_aw_fund_mast(cp_fund_id => p_fund_id);
    FETCH  c_igf_aw_fund_mast INTO l_c_igf_aw_fund_mast;
    CLOSE  c_igf_aw_fund_mast;

    -- log all the parameters passed to the process
    log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR'),p_award_year);
    log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','FUND_CODE'),l_c_igf_aw_fund_mast.fund_code||' '||l_c_igf_aw_fund_mast.description);
    log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','TEST_MODE'),l_c_igs_lookups.meaning);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_v_message_name);
       fnd_file.put_line(fnd_file.log,fnd_message.get());
       fnd_file.new_line(fnd_file.log);
       RAISE do_nothing;
    END IF;

    -- This Section confirms that all the mandatory parameters are passed to the process
    IF ((p_award_year IS NULL) OR (p_rollover IS NULL) OR (p_run_mode IS NULL) OR (p_fund_id IS NULL)) THEN
      fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RAISE do_nothing;
    END IF;
    --Validation of all mandatory parameter ends here

    -- This Section confirms that all parameters passed to the process are valid
    -- This procedure validates the award year.
    IF p_award_year IS NOT NULL THEN
      l_ans := validate_award_year(p_cal_type        => l_cal_type,
                                   p_sequence_number => l_sequence_number,
                                   p_err_message     => l_err_message
                                  );
      IF NOT(l_ans) and l_err_message IS NOT NULL THEN
        fnd_message.set_name('IGS',l_err_message);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RAISE do_nothing;
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
        RAISE do_nothing;
      END IF;
    END IF;

    --Validate the fund id.
    l_ans := validate_fund(p_fund             =>  p_fund_id,
                           p_cal_type         =>  l_cal_type,
                           p_sequence_number  =>  l_sequence_number,
                           p_err_message      =>  l_err_message);
    IF NOT(l_ans) and l_err_message IS NOT NULL THEN
      fnd_message.set_name('IGS',l_err_message);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RAISE do_nothing;
    END IF;

    -- Check if succeeding awards are present for the current award year passed as
    -- parameter to the process
    OPEN c_igf_aw_cal_rel(cp_cal_type  => l_cal_type,
                          cp_seq_num   => l_sequence_number
                         );
    FETCH  c_igf_aw_cal_rel INTO l_c_igf_aw_cal_rel;
    IF c_igf_aw_cal_rel%NOTFOUND THEN
      CLOSE c_igf_aw_cal_rel;
      fnd_message.set_name('IGF','IGF_AW_AWD_MAP_NOT_FND');
      fnd_message.set_token('FNDID',p_fund_id);
      fnd_message.set_token('ALTCD',p_award_year);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RAISE do_nothing;
    END IF;
    l_sc_cal_type        := l_c_igf_aw_cal_rel.sc_cal_type;
    l_sc_sequence_number := l_c_igf_aw_cal_rel.sc_sequence_number;
    CLOSE c_igf_aw_cal_rel;

    --Validate the Succeeding Award Year Status. If the status is not open, log the message in log file and
    --complete the process with error.
    l_v_message_name := NULL;
    l_v_awd_yr_status_cd := NULL;

    igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  l_sc_cal_type,
                                              p_n_awd_seq_number   =>  l_sc_sequence_number,
                                              p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                              p_v_message_name     =>  l_v_message_name
                                             );
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name('IGF','IGF_SP_NXT_AWD_YR_STAT_INVALID');
      fnd_message.set_token('ALT_CODE',l_c_igf_aw_cal_rel.sc_alternate_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE do_nothing;
    END IF;

    SAVEPOINT sp_main;
    --Validation of all the parameters ends here
    -- if user has given only rollover of fund alone
    IF p_rollover = 'S' THEN
    -- procedure which rollover the sponsor fund details
      sponsor_fund_rollover ( p_sc_cal_type      => l_sc_cal_type,
                              p_sc_seq_num       => l_sc_sequence_number,
                              p_fund             => p_fund_id
                             ) ;

    -- if user has given only rollover of student sponsor fund alone
    ELSIF p_rollover = 'R' THEN
    -- procedure which rollover the sponsor student details
          sponsor_student_rollover ( p_sc_cal_type      => l_sc_cal_type,
                                     p_sc_seq_num       => l_sc_sequence_number,
                                     p_fund             => p_fund_id
                                   ) ;

    -- if user has given  rollover of fund and student sponsor fund
    ELSIF p_rollover = 'B' THEN
    -- procedure which rollover the sponsor fund details
      sponsor_fund_rollover ( p_sc_cal_type      => l_sc_cal_type,
                              p_sc_seq_num       => l_sc_sequence_number,
                              p_fund             => p_fund_id
                             ) ;
      fnd_file.put_line(fnd_file.log,' ');
      sponsor_student_rollover ( p_sc_cal_type      => l_sc_cal_type,
                                 p_sc_seq_num       => l_sc_sequence_number,
                                 p_fund             => p_fund_id
                               ) ;
    END IF;
    -- if test mode = yes then rollback all the transactions
    IF p_run_mode = 'Y' THEN
      ROLLBACK TO sp_main;
    END IF;

  EXCEPTION
    WHEN do_nothing THEN
      retcode :=2;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      igs_ge_msg_stack.conc_exception_hndl ;
  END sponsor_rollover;

  FUNCTION lookup_desc( p_type IN VARCHAR2 ,
                        p_code IN VARCHAR2 )
                        RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2002
  --
  --Purpose: This function is private to this package body .
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vvutukur  07-Mar-2003     Bug#2822725.Removed cursor to fetch the meaning of lookup,instead used generic function.
  -------------------------------------------------------------------

 l_desc igf_lookups_view.meaning%TYPE ;

 BEGIN
   IF p_code IS NULL THEN
     RETURN NULL;
   ELSE
     RETURN igf_aw_gen.lookup_desc( l_type => p_type,
                                    l_code => p_code);
   END IF ;
 END lookup_desc;  /** Function Ends Here   **/


  PROCEDURE log_messages ( p_msg_name  IN VARCHAR2 ,
                           p_msg_val   IN VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         table values
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
    fnd_message.set_token('PARAMETER_NAME',p_msg_name);
    fnd_message.set_token('PARAMETER_VAL' ,p_msg_val) ;
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  END log_messages;


  FUNCTION   validate_fund(p_fund             IN  igf_aw_fund_mast.fund_id%TYPE ,
                           p_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                           p_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
                           p_err_message      OUT NOCOPY VARCHAR2
                          ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         table values
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vvutukur  07-Mar-2003     Bug#2822725. Removed parameters cal_type,sequence_number to open the cursor c_igf_aw_fund_mast.
  ------------------------------------------------------------------
      -- cursor variable for c_igf_aw_fund_mast
    l_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;
  BEGIN
    OPEN  c_igf_aw_fund_mast(cp_fund_id    => p_fund);
    FETCH c_igf_aw_fund_mast INTO l_c_igf_aw_fund_mast;
    IF c_igf_aw_fund_mast%NOTFOUND THEN
      CLOSE c_igf_aw_fund_mast;
      p_err_message := 'IGS_GE_INVALID_VALUE';
      RETURN (FALSE);
    END IF;
    CLOSE c_igf_aw_fund_mast;
    p_err_message := NULL;
    RETURN (TRUE);
  END validate_fund;


  FUNCTION   validate_award_year(p_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                                 p_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
                                 p_err_message      OUT NOCOPY VARCHAR2
                                ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         table values
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

    -- cursor which validates whether the term calendar type and
    -- sequence number is present in igs_ca_inst table
    CURSOR  c_igs_ca_inst(cp_cal_type         igs_ca_inst.cal_type%TYPE,
                          cp_sequence_number  igs_ca_inst.sequence_number%TYPE
                         ) IS
    SELECT  '1'
    FROM    igs_ca_inst
    WHERE   cal_type        = cp_cal_type
    AND     sequence_number = cp_sequence_number;

    l_c_igs_ca_inst  c_igs_ca_inst%ROWTYPE;
  BEGIN
    OPEN c_igs_ca_inst(cp_cal_type         =>  p_cal_type,
                       cp_sequence_number  =>  p_sequence_number
                      ) ;
    FETCH c_igs_ca_inst  into l_c_igs_ca_inst ;
    -- if records are not found for the passed calendar type and sequence number
    -- assign error message to out NOCOPY parameter and function returns false
    IF c_igs_ca_inst%NOTFOUND THEN
      CLOSE c_igs_ca_inst;
      p_err_message := 'IGS_GE_INVALID_VALUE';
      RETURN (FALSE);
    END IF;
    CLOSE c_igs_ca_inst;
    p_err_message := NULL;
    RETURN (TRUE);
  END validate_award_year;

  -- procedure which rollover over the sponsor fund details
  PROCEDURE   sponsor_fund_rollover ( p_sc_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                      p_sc_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                      p_fund         IN  igf_aw_fund_mast_all.fund_id%TYPE
                                    ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure is being called from the sponsor_rollover procedure
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --gurprsin  31-May-2006       Bug 5213852, Logged the new message 'IGF_SP_NO_FUND_TERM_MAP' and removed the code logic to
  --                            log 'IGF_AW_FND_RLOVR_LD_NTFND' as the later message is obsoleted. This new message
  --                            will be logged when user tries to rollover Sponsor setup and the associated term
  --                            calendar mapping does not exist for the destination award year.
  --sapanigr    03-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igf_aw_fund_mast, igf_sp_fc,
  --                            igf_sp_prg, igf_sp_unit are now rounded off to currency precision
  --akandreg    29-Mar-2006     Bug 4765537. Passed appropriate values to parameters x_lock_award_flag,
  --                            x_donot_repkg_if_code ,x_re_pkg_verif_flag of igf_aw_fund_mast_pkg.insert_row
  --museshad    14-Jul-2005     Build FA 140.
  --                            Modified TBH call due to the addition of new
  --                            columns to igf_aw_fund_mast_all table.
  --museshad    25-May-2005     Build# FA157 - Bug# 4382371.
  --                            New column 'DISB_ROUNDING_CODE' has been added
  --                            to the table 'IGF_AW_FUND_MAST_ALL'.
  --                            Modified calls to TBH.
  --vvutukur  07-Mar-2003     Bug#2822725. Removed parameters p_cal_type,p_sequence_number of this procedure as they are not required.
  --                          Also same have been removed from cursor c_igf_aw_fund_mast and its usage.
  --smvk        09-Feb-2003     Bug # 2758812. Added send_without_doc column.
  ------------------------------------------------------------------

    l_msg_str_0        VARCHAR2(32767) := NULL;
    l_msg_str_1        VARCHAR2(32767) := NULL;
    l_message_name     VARCHAR2(30)    := NULL;
    l_err_exception    EXCEPTION;
    l_rowid            VARCHAR2(25);
    l_fund_id          igf_aw_fund_mast_all.fund_id%TYPE;
    l_fee_cls_id       igf_sp_fc_all.fee_cls_id%TYPE;
    l_fee_cls_prg_id   igf_sp_prg_all.fee_cls_prg_id%TYPE;
    l_fee_cls_unit_id  igf_sp_unit_all.fee_cls_unit_id%TYPE;

    CURSOR           c_igf_aw_fund_tp( cp_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT           *
    FROM             igf_aw_fund_tp_v ftp
    WHERE            ftp.fund_id = cp_fund_id
    ORDER BY         tp_cal_type,tp_sequence_number;

    l_c_igf_aw_fund_tp   c_igf_aw_fund_tp%ROWTYPE;

    CURSOR           c_igf_sp_fc(cp_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_fc_v
    WHERE            fund_id = cp_fund_id
    ORDER BY         fee_cls_id;

    l_c_igf_sp_fc    c_igf_sp_fc%ROWTYPE;

    CURSOR           c_igf_sp_prg(cp_fee_cls_id igf_sp_fc.fee_cls_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_prg
    WHERE            fee_cls_id = cp_fee_cls_id
    ORDER BY         fee_cls_prg_id;

    l_c_igf_sp_prg  c_igf_sp_prg%ROWTYPE;

    CURSOR           c_igf_sp_unit(cp_fee_cls_prg_id igf_sp_prg.fee_cls_prg_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_unit
    WHERE            fee_cls_prg_id = cp_fee_cls_prg_id
    ORDER BY         fee_cls_unit_id;

    l_c_igf_sp_unit  c_igf_sp_unit%ROWTYPE;
    -- cursor variable for c_igf_aw_cal_rel
    l_c_igf_aw_cal_rel  c_igf_aw_cal_rel%ROWTYPE;
    -- cursor variable for c_igf_aw_fund_mast
    l_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;
  BEGIN

    OPEN c_igf_aw_fund_mast(cp_fund_id  => p_fund);
    FETCH c_igf_aw_fund_mast INTO l_c_igf_aw_fund_mast;
    CLOSE c_igf_aw_fund_mast;

    -- log the relavant details
    l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','FUND_CODE'),32) ||
                     RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR'),19) ||
                     RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','MIN_CRD_POINTS'),19) ||
                     RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','MIN_ATD_TYPE'),32) ||
                          lookup_desc('IGF_AW_LOOKUPS_MSG','TOT_SPNSR_AMT');

        fnd_file.put_line(fnd_file.log,l_msg_str_0);
        fnd_file.put_line(fnd_file.log,' ');
        l_msg_str_1  :=  RPAD(l_c_igf_aw_fund_mast.fund_code,32)||
                         RPAD((p_sc_cal_type||' '||p_sc_seq_num),19) ||
                         NVL(RPAD(TO_CHAR(l_c_igf_aw_fund_mast.min_credit_points),19),'                   ') ||
                         NVL(RPAD(l_c_igf_aw_fund_mast.enrollment_status,32),'                                ' )||
                         TO_CHAR(l_c_igf_aw_fund_mast.max_yearly_amt);

        fnd_file.put_line(fnd_file.log,l_msg_str_1);
        fnd_file.put_line(fnd_file.log,' ');

      BEGIN
        -- declare a save point
        SAVEPOINT sp_fund;
        l_rowid   := NULL;
        l_fund_id := NULL;
        BEGIN
          -- rollover the fund to new award year
          -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
          igf_aw_fund_mast_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => l_rowid,
            x_fund_id                           => l_fund_id,
            x_fund_code                         => l_c_igf_aw_fund_mast.fund_code,
            x_ci_cal_type                       => p_sc_cal_type,
            x_ci_sequence_number                => p_sc_seq_num,
            x_description                       => l_c_igf_aw_fund_mast.description,
            x_discontinue_fund                  => l_c_igf_aw_fund_mast.discontinue_fund,
            x_entitlement                       => l_c_igf_aw_fund_mast.entitlement,
            x_auto_pkg                          => l_c_igf_aw_fund_mast.auto_pkg,
            x_self_help                         => l_c_igf_aw_fund_mast.self_help,
            x_allow_man_pkg                     => l_c_igf_aw_fund_mast.allow_man_pkg,
            x_update_need                       => l_c_igf_aw_fund_mast.update_need,
            x_disburse_fund                     => l_c_igf_aw_fund_mast.disburse_fund,
            x_available_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.available_amt),
            x_offered_amt                       => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.offered_amt),
            x_pending_amt                       => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.pending_amt),
            x_accepted_amt                      => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.accepted_amt),
            x_declined_amt                      => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.declined_amt),
            x_cancelled_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.cancelled_amt),
            x_remaining_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.remaining_amt),
            x_enrollment_status                 => l_c_igf_aw_fund_mast.enrollment_status,
            x_prn_award_letter                  => l_c_igf_aw_fund_mast.prn_award_letter,
            x_over_award_amt                    => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.over_award_amt),
            x_over_award_perct                  => l_c_igf_aw_fund_mast.over_award_perct,
            x_min_award_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.min_award_amt),
            x_max_award_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.max_award_amt),
            x_max_yearly_amt                    => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.max_yearly_amt),
            x_max_life_amt                      => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.max_life_amt),
            x_max_life_term                     => l_c_igf_aw_fund_mast.max_life_term,
            x_fm_fc_methd                       => l_c_igf_aw_fund_mast.fm_fc_methd,
            x_roundoff_fact                     => l_c_igf_aw_fund_mast.roundoff_fact,
            x_replace_fc                        => l_c_igf_aw_fund_mast.replace_fc,
            x_allow_overaward                   => l_c_igf_aw_fund_mast.allow_overaward,
            x_pckg_awd_stat                     => l_c_igf_aw_fund_mast.pckg_awd_stat,
            x_org_record_req                    => l_c_igf_aw_fund_mast.org_record_req,
            x_disb_record_req                   => l_c_igf_aw_fund_mast.disb_record_req,
            x_prom_note_req                     => l_c_igf_aw_fund_mast.prom_note_req,
            x_min_num_disb                      => l_c_igf_aw_fund_mast.min_num_disb,
            x_max_num_disb                      => l_c_igf_aw_fund_mast.max_num_disb,
            x_fee_type                          => l_c_igf_aw_fund_mast.fee_type,
            x_total_offered                     => l_c_igf_aw_fund_mast.total_offered,
            x_total_accepted                    => l_c_igf_aw_fund_mast.total_accepted,
            x_total_declined                    => l_c_igf_aw_fund_mast.total_declined,
            x_total_revoked                     => l_c_igf_aw_fund_mast.total_revoked,
            x_total_cancelled                   => l_c_igf_aw_fund_mast.total_cancelled,
            x_total_disbursed                   => l_c_igf_aw_fund_mast.total_disbursed,
            x_total_committed                   => l_c_igf_aw_fund_mast.total_committed,
            x_committed_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.committed_amt),
            x_disbursed_amt                     => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.disbursed_amt),
            x_awd_notice_txt                    => l_c_igf_aw_fund_mast.awd_notice_txt,
            x_attribute_category                => l_c_igf_aw_fund_mast.attribute_category,
            x_attribute1                        => l_c_igf_aw_fund_mast.attribute1,
            x_attribute2                        => l_c_igf_aw_fund_mast.attribute2,
            x_attribute3                        => l_c_igf_aw_fund_mast.attribute3,
            x_attribute4                        => l_c_igf_aw_fund_mast.attribute4,
            x_attribute5                        => l_c_igf_aw_fund_mast.attribute5,
            x_attribute6                        => l_c_igf_aw_fund_mast.attribute6,
            x_attribute7                        => l_c_igf_aw_fund_mast.attribute7,
            x_attribute8                        => l_c_igf_aw_fund_mast.attribute8,
            x_attribute9                        => l_c_igf_aw_fund_mast.attribute9,
            x_attribute10                       => l_c_igf_aw_fund_mast.attribute10,
            x_attribute11                       => l_c_igf_aw_fund_mast.attribute11,
            x_attribute12                       => l_c_igf_aw_fund_mast.attribute12,
            x_attribute13                       => l_c_igf_aw_fund_mast.attribute13,
            x_attribute14                       => l_c_igf_aw_fund_mast.attribute14,
            x_attribute15                       => l_c_igf_aw_fund_mast.attribute15,
            x_attribute16                       => l_c_igf_aw_fund_mast.attribute16,
            x_attribute17                       => l_c_igf_aw_fund_mast.attribute17,
            x_attribute18                       => l_c_igf_aw_fund_mast.attribute18,
            x_attribute19                       => l_c_igf_aw_fund_mast.attribute19,
            x_attribute20                       => l_c_igf_aw_fund_mast.attribute20,
            x_disb_verf_da                      => l_c_igf_aw_fund_mast.disb_verf_da,
            x_fund_exp_da                       => l_c_igf_aw_fund_mast.fund_exp_da,
            x_nslds_disb_da                     => l_c_igf_aw_fund_mast.nslds_disb_da,
            x_disb_exp_da                       => l_c_igf_aw_fund_mast.disb_exp_da,
            x_fund_recv_reqd                    => l_c_igf_aw_fund_mast.fund_recv_reqd,
            x_show_on_bill                      => l_c_igf_aw_fund_mast.show_on_bill,
            x_bill_desc                         => l_c_igf_aw_fund_mast.bill_desc,
            x_credit_type_id                    => l_c_igf_aw_fund_mast.credit_type_id,
            x_spnsr_ref_num                     => l_c_igf_aw_fund_mast.spnsr_ref_num,
            x_threshold_perct                   => l_c_igf_aw_fund_mast.threshold_perct,
            x_threshold_value                   => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.threshold_value),
            x_party_id                          => l_c_igf_aw_fund_mast.party_id,
            x_spnsr_fee_type                    => l_c_igf_aw_fund_mast.spnsr_fee_type,
            x_min_credit_points                 => l_c_igf_aw_fund_mast.min_credit_points,
            x_group_id                          => l_c_igf_aw_fund_mast.group_id,
            x_spnsr_attribute_category          => l_c_igf_aw_fund_mast.spnsr_attribute_category,
            x_spnsr_attribute1                  => l_c_igf_aw_fund_mast.spnsr_attribute1,
            x_spnsr_attribute2                  => l_c_igf_aw_fund_mast.spnsr_attribute2,
            x_spnsr_attribute3                  => l_c_igf_aw_fund_mast.spnsr_attribute3,
            x_spnsr_attribute4                  => l_c_igf_aw_fund_mast.spnsr_attribute4,
            x_spnsr_attribute5                  => l_c_igf_aw_fund_mast.spnsr_attribute5,
            x_spnsr_attribute6                  => l_c_igf_aw_fund_mast.spnsr_attribute6,
            x_spnsr_attribute7                  => l_c_igf_aw_fund_mast.spnsr_attribute7,
            x_spnsr_attribute8                  => l_c_igf_aw_fund_mast.spnsr_attribute8,
            x_spnsr_attribute9                  => l_c_igf_aw_fund_mast.spnsr_attribute9,
            x_spnsr_attribute10                 => l_c_igf_aw_fund_mast.spnsr_attribute10,
            x_spnsr_attribute11                 => l_c_igf_aw_fund_mast.spnsr_attribute11,
            x_spnsr_attribute12                 => l_c_igf_aw_fund_mast.spnsr_attribute12,
            x_spnsr_attribute13                 => l_c_igf_aw_fund_mast.spnsr_attribute13,
            x_spnsr_attribute14                 => l_c_igf_aw_fund_mast.spnsr_attribute14,
            x_spnsr_attribute15                 => l_c_igf_aw_fund_mast.spnsr_attribute15,
            x_spnsr_attribute16                 => l_c_igf_aw_fund_mast.spnsr_attribute16,
            x_spnsr_attribute17                 => l_c_igf_aw_fund_mast.spnsr_attribute17,
            x_spnsr_attribute18                 => l_c_igf_aw_fund_mast.spnsr_attribute18,
            x_spnsr_attribute19                 => l_c_igf_aw_fund_mast.spnsr_attribute19,
            x_spnsr_attribute20                 => l_c_igf_aw_fund_mast.spnsr_attribute20,
            x_ver_app_stat_override             => l_c_igf_aw_fund_mast.ver_app_stat_override ,
            x_gift_aid                          => l_c_igf_aw_fund_mast.gift_aid,
            x_send_without_doc                  => l_c_igf_aw_fund_mast.send_without_doc,  --  Bug # 2758812. Added send_without_doc column.
            x_re_pkg_verif_flag                 => l_c_igf_aw_fund_mast.re_pkg_verif_flag,
            x_donot_repkg_if_code               => l_c_igf_aw_fund_mast.donot_repkg_if_code,
            x_lock_award_flag                   => l_c_igf_aw_fund_mast.lock_award_flag,
            x_disb_rounding_code                => l_c_igf_aw_fund_mast.disb_rounding_code,
            x_view_only_flag                    => l_c_igf_aw_fund_mast.view_only_flag,
            x_accept_less_amt_flag              => l_c_igf_aw_fund_mast.accept_less_amt_flag,
            x_allow_inc_post_accept_flag        => l_c_igf_aw_fund_mast.allow_inc_post_accept_flag,
            x_min_increase_amt                  => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.min_increase_amt),
            x_allow_dec_post_accept_flag        => l_c_igf_aw_fund_mast.allow_dec_post_accept_flag,
            x_min_decrease_amt                  => igs_fi_gen_gl.get_formatted_amount(l_c_igf_aw_fund_mast.min_decrease_amt),
            x_allow_decln_post_accept_flag      => l_c_igf_aw_fund_mast.allow_decln_post_accept_flag,
            x_status_after_decline              => l_c_igf_aw_fund_mast.status_after_decline,
            x_fund_information_txt              => l_c_igf_aw_fund_mast.fund_information_txt
          );

        EXCEPTION
          WHEN OTHERS THEN
            -- rollsback to the save point
            ROLLBACK TO sp_fund;
            -- log the error message returned by the tbh
            fnd_file.put_line(fnd_file.log,' ');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- raises user defined exception so as to skip the record
            -- the record will not be processed further
            RAISE l_err_exception;
        END;

        -- rolling over fund term details
        -- log the relavant details
        l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','TERM'),12) ||
                         RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','START_DT'),22) ||
                         lookup_desc('IGF_AW_LOOKUPS_MSG','END_DT');
        fnd_file.put_line(fnd_file.log,l_msg_str_0);
        fnd_file.put_line(fnd_file.log,' ');
        FOR l_c_igf_aw_fund_tp  IN c_igf_aw_fund_tp(cp_fund_id  => l_c_igf_aw_fund_mast.fund_id)
        LOOP
            -- Check if succeeding terms are present for the current term passed as
            -- parameter to the process
            OPEN c_igf_aw_cal_rel(cp_cal_type  => l_c_igf_aw_fund_tp.tp_cal_type,
                                  cp_seq_num   => l_c_igf_aw_fund_tp.tp_sequence_number
                                 );
            FETCH  c_igf_aw_cal_rel INTO l_c_igf_aw_cal_rel;
            IF c_igf_aw_cal_rel%NOTFOUND THEN
              -- rolls back to the save point
              ROLLBACK TO sp_fund;
              CLOSE c_igf_aw_cal_rel;

              --Bug 5213852, Logged the new message 'IGF_SP_NO_FUND_TERM_MAP' and removed the code logic to
              --log 'IGF_AW_FND_RLOVR_LD_NTFND' as the later message is obsoleted.
              fnd_message.set_name('IGF','IGF_SP_NO_FUND_TERM_MAP');
              fnd_message.set_token('TERM_ALT_CD ',l_c_igf_aw_fund_tp.tp_alternate_code);
              fnd_message.set_token('AWD_ALT_CD',l_c_igf_aw_fund_tp.awd_alternate_code);
              fnd_message.set_token('FUND_CODE',l_c_igf_aw_fund_tp.fund_code);

              igs_ge_msg_stack.add;
              -- log the error message
              fnd_file.put_line(fnd_file.log,' ');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              -- raises user defined exception so as to skip the record
              RAISE l_err_exception;
            END IF;
            CLOSE c_igf_aw_cal_rel;
          -- log relevant details
          l_msg_str_1  :=  RPAD(l_c_igf_aw_cal_rel.sc_alternate_code,12) ||
                           RPAD(igs_ge_date.igschardt(l_c_igf_aw_cal_rel.sc_start_dt),22) ||
                           igs_ge_date.igschardt(l_c_igf_aw_cal_rel.sc_end_dt);
          fnd_file.put_line(fnd_file.log,l_msg_str_1);
          l_rowid := NULL;
          BEGIN
            igf_aw_fund_tp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              x_fund_id                           => l_fund_id,
              x_tp_cal_type                       => l_c_igf_aw_cal_rel.sc_cal_type,
              x_tp_sequence_number                => l_c_igf_aw_cal_rel.sc_sequence_number,
              x_tp_perct                          => l_c_igf_aw_fund_tp.tp_perct
            );
          EXCEPTION
           WHEN OTHERS THEN
            -- rolls back to the save point
            ROLLBACK TO sp_fund;
            -- log the error message returned by the tbh
            fnd_message.set_name('IGF',fnd_message.get);
            igs_ge_msg_stack.add;
            fnd_file.put_line(fnd_file.log,' ');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- raises user defined exception so as to skip the record
            RAISE l_err_exception;
          END;
        END LOOP;
        fnd_file.put_line(fnd_file.log,' ');
        l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','FEE_CLASS'),32) ||
                         RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','PERCENT'),10) ||
                         lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
        fnd_file.put_line(fnd_file.log,l_msg_str_0);
        fnd_file.put_line(fnd_file.log,' ');
        -- rolling over pays only fee class details
        FOR l_c_igf_sp_fc IN c_igf_sp_fc(cp_fund_id  => l_c_igf_aw_fund_mast.fund_id)
        LOOP
          -- log relevant details
          l_msg_str_1  :=  RPAD(l_c_igf_sp_fc.fee_class,32) ||
                           NVL(RPAD(TO_CHAR(l_c_igf_sp_fc.fee_percent),10),'          ' )||
                           TO_CHAR(l_c_igf_sp_fc.max_amount);
          fnd_file.put_line(fnd_file.log,l_msg_str_1);
          l_rowid      := NULL;
          l_fee_cls_id := NULL;
          BEGIN
          -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
            igf_sp_fc_pkg.insert_row (
                x_mode                              => 'R',
                x_rowid                             => l_rowid,
                x_fee_cls_id                        => l_fee_cls_id,
                x_fund_id                           => l_fund_id,
                x_fee_class                         => l_c_igf_sp_fc.fee_class,
                x_fee_percent                       => l_c_igf_sp_fc.fee_percent,
                x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_fc.max_amount)
             );
          EXCEPTION
           WHEN OTHERS THEN
            -- rolls back to the save point
            ROLLBACK TO sp_fund;
            -- log the error message returned by the tbh
            fnd_file.put_line(fnd_file.log,' ');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- raises user defined exception so as to skip the record
            RAISE l_err_exception;
          END;
          IF l_c_igf_sp_fc.fee_class = 'TUITION' THEN
            -- rolling over pays program details
            fnd_file.put_line(fnd_file.log,' ');
            l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','COURSE_CD'),12) ||
                             RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','VERSION_NUMBER'),16) ||
                             RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','PERCENT'),10) ||
                             lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
            fnd_file.put_line(fnd_file.log,l_msg_str_0);
            fnd_file.put_line(fnd_file.log,' ');

            FOR l_c_igf_sp_prg IN c_igf_sp_prg(cp_fee_cls_id => l_c_igf_sp_fc.fee_cls_id)
            LOOP
              -- log relevant details
              l_msg_str_1  :=  RPAD(l_c_igf_sp_prg.course_cd,12) ||
                               RPAD(l_c_igf_sp_prg.version_number,16) ||
                               NVL(RPAD(TO_CHAR(l_c_igf_sp_prg.fee_percent),10),'          ') ||
                               TO_CHAR(l_c_igf_sp_prg.max_amount);
              fnd_file.put_line(fnd_file.log,l_msg_str_1);
              l_rowid          := NULL;
              l_fee_cls_prg_id := NULL;
              BEGIN
              -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                igf_sp_prg_pkg.insert_row (
                   x_mode                              => 'R',
                   x_rowid                             => l_rowid,
                   x_fee_cls_prg_id                    => l_fee_cls_prg_id,
                   x_fee_cls_id                        => l_fee_cls_id,
                   x_course_cd                         => l_c_igf_sp_prg.course_cd,
                   x_version_number                    => l_c_igf_sp_prg.version_number,
                   x_fee_percent                       => l_c_igf_sp_prg.fee_percent,
                   x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_prg.max_amount)
                );
              EXCEPTION
                WHEN OTHERS THEN
                  -- rolls back to the save point
                  ROLLBACK TO sp_fund;
                  -- log the error message returned by the tbh
                  fnd_file.put_line(fnd_file.log,' ');
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  -- raises user defined exception so as to skip the record
                  RAISE l_err_exception;
              END ;
              -- rollover pays only unit details.
              fnd_file.put_line(fnd_file.log,' ');
              l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','UNIT_CD'),12) ||
                               RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','VERSION_NUMBER'),16) ||
                               lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
              fnd_file.put_line(fnd_file.log,l_msg_str_0);
              fnd_file.put_line(fnd_file.log,' ');
              FOR l_c_igf_sp_unit IN c_igf_sp_unit(cp_fee_cls_prg_id => l_c_igf_sp_prg.fee_cls_prg_id)
              LOOP
                -- log relevant details
                l_msg_str_1  :=  RPAD(l_c_igf_sp_unit.unit_cd,12) ||
                                 RPAD(l_c_igf_sp_unit.version_number,16) ||
                                 TO_CHAR(l_c_igf_sp_unit.max_amount);
                fnd_file.put_line(fnd_file.log,l_msg_str_1);
                l_rowid           := NULL;
                l_fee_cls_unit_id := NULL;
                BEGIN
                -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                 igf_sp_unit_pkg.insert_row (
                  x_mode                              => 'R',
                  x_rowid                             => l_rowid,
                  x_fee_cls_unit_id                   => l_fee_cls_unit_id,
                  x_fee_cls_prg_id                    => l_fee_cls_prg_id,
                  x_unit_cd                           => l_c_igf_sp_unit.unit_cd,
                  x_version_number                    => l_c_igf_sp_unit.version_number,
                  x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_unit.max_amount)
                 );
                EXCEPTION
                  WHEN OTHERS THEN
                    -- rolls back to the save point
                    ROLLBACK TO sp_fund;
                    -- log the error message returned by the tbh
                    fnd_file.put_line(fnd_file.log,' ');
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    -- raises user defined exception so as to skip the record
                    RAISE l_err_exception;
                END;
              END LOOP;
              fnd_file.put_line(fnd_file.log,' ');
            END LOOP;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN l_err_exception THEN
          NULL;
      END;

  END sponsor_fund_rollover;

  -- procedure which rollover over the sponsor student relation
  PROCEDURE   sponsor_student_rollover ( p_sc_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                         p_sc_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                         p_fund         IN  igf_aw_fund_mast_all.fund_id%TYPE
                                       ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure is being called from the sponsor_rollover procedure
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --skharida  12-Jun-2006     Bug#5093981 Appended the Person Number to the log when no FA base is found for the
  --                          person for Awards Sponsorship Rollover process
  --gurprsin  31-May-2006     Bug 5213852, Logged the new message 'IGF_SP_NO_STDREL_TERM_MAP' and removed the code logic to
  --                          log 'IGF_AW_FND_RLOVR_LD_NTFND' as the later message is obsoleted. This new message
  --                          will be logged when user tries to rollover Sponsor-student relation and the
  --                          associated term calendar mapping does not exist for the destination award year.
  --sapanigr  03-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igf_sp_stdnt_rel, igf_sp_std_fc,
  --                          igf_sp_std_prg, igf_sp_std_unit are now rounded off to currency precision
  --vvutukur  07-Mar-2003     Bug#2822725. Removed parameters p_cal_type,p_sequence_number and from the cursor c_igf_aw_fund_mast usage also.
  ------------------------------------------------------------------
     -- cursor to select fund code from igf_aw_fund_mast to get fund code for fund id parameter
     CURSOR   c_fund_mast(cp_fund_code          igf_aw_fund_mast.fund_code%TYPE,
                          cp_cal_type         igs_ca_inst.cal_type%TYPE,
                          cp_sequence_number  igs_ca_inst.sequence_number%TYPE
                          )  IS
     SELECT   fmast.*
     FROM     igf_aw_fund_mast fmast ,
              igf_aw_fund_cat fcat
     WHERE    fmast.fund_code          = fcat.fund_code
     AND      fmast.fund_code          = cp_fund_code
     AND      fmast.ci_cal_type        = cp_cal_type
     AND      fmast.ci_sequence_number = cp_sequence_number
     AND      fcat.sys_fund_type       = g_c_fund_type
     AND      fmast.discontinue_fund = g_c_no;

     --  cursor variable for c_fund_mast
    l_c_fund_mast  c_fund_mast%ROWTYPE;

    CURSOR           c_igf_aw_fund_tp( cp_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT           *
    FROM             igf_aw_fund_tp_v ftp
    WHERE            ftp.fund_id = cp_fund_id;

    l_c_igf_aw_fund_tp   c_igf_aw_fund_tp%ROWTYPE;

    CURSOR    c_igf_sp_stdnt_rel(cp_fund_id          igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT    *
    FROM      igf_sp_stdnt_rel_v
    WHERE     fund_id             = cp_fund_id ;

    l_c_igf_sp_stdnt_rel c_igf_sp_stdnt_rel%ROWTYPE;


    CURSOR  c_igf_ap_fa_base_rec(cp_person_id  igs_pe_person.person_id%TYPE,
                                 cp_cal_type   igs_ca_inst.cal_type%TYPE,
                                 cp_seq_num    igs_ca_inst.sequence_number%TYPE
                                ) IS
    SELECT  base_id
    FROM    igf_ap_fa_base_rec
    WHERE   person_id           =  cp_person_id
    AND     ci_cal_type         =  cp_cal_type
    AND     ci_sequence_number  =  cp_seq_num;

    l_c_igf_ap_fa_base_rec  c_igf_ap_fa_base_rec%ROWTYPE;

    CURSOR           c_igf_sp_std_fc(cp_spnsr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_std_fc_v
    WHERE            spnsr_stdnt_id = cp_spnsr_stdnt_id;

    l_c_igf_sp_std_fc    c_igf_sp_std_fc%ROWTYPE;

    CURSOR           c_igf_sp_std_prg(cp_fee_cls_id igf_sp_fc.fee_cls_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_std_prg
    WHERE            fee_cls_id = cp_fee_cls_id;

    l_c_igf_sp_std_prg  c_igf_sp_std_prg%ROWTYPE;

    CURSOR           c_igf_sp_std_unit(cp_fee_cls_prg_id igf_sp_prg.fee_cls_prg_id%TYPE) IS
    SELECT           *
    FROM             igf_sp_std_unit
    WHERE            fee_cls_prg_id = cp_fee_cls_prg_id;

    l_c_igf_sp_std_unit  c_igf_sp_std_unit%ROWTYPE;

    l_msg_str_0        VARCHAR2(32767) := NULL;
    l_msg_str_1        VARCHAR2(32767) := NULL;
    l_message_name     VARCHAR2(30)    := NULL;
    l_err_exception    EXCEPTION;
    l_stud_exception   EXCEPTION;
    l_rowid            VARCHAR2(25);
    l_fund_id          igf_aw_fund_mast.fund_id%TYPE;
    l_spnsr_stdnt_id   igf_sp_stdnt_rel_all.spnsr_stdnt_id%TYPE;
    l_fee_cls_id       igf_sp_fc_all.fee_cls_id%TYPE;
    l_fee_cls_prg_id   igf_sp_prg_all.fee_cls_prg_id%TYPE;
    l_fee_cls_unit_id  igf_sp_unit_all.fee_cls_unit_id%TYPE;
    l_message          VARCHAR2(2000) := NULL;
    l_base_id          igf_ap_fa_base_rec.base_id%TYPE;
    l_ans              BOOLEAN := TRUE;
      -- cursor variable for c_igf_aw_cal_rel
    l_c_igf_aw_cal_rel  c_igf_aw_cal_rel%ROWTYPE;
    -- cursor variable for c_igf_aw_fund_mast
    l_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;
  BEGIN

    OPEN c_igf_aw_fund_mast(cp_fund_id  => p_fund);
    FETCH c_igf_aw_fund_mast INTO l_c_igf_aw_fund_mast;
    CLOSE c_igf_aw_fund_mast;
    BEGIN
      -- declare a save point
      SAVEPOINT sp_student;

      -- get the fund id of the succeeding award year for the fund passed to the process
      OPEN  c_fund_mast (cp_fund_code       => l_c_igf_aw_fund_mast.fund_code,
                         cp_cal_type        => p_sc_cal_type,
                         cp_sequence_number => p_sc_seq_num);
      FETCH c_fund_mast INTO l_c_fund_mast;
      IF c_fund_mast%NOTFOUND THEN
        -- rolls back to the save point
        ROLLBACK TO sp_student;
        CLOSE c_fund_mast;
        fnd_message.set_name('IGF','IGF_SP_NO_FUND_ROLL');
        igs_ge_msg_stack.add;
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE l_err_exception;
      END IF;
      CLOSE c_fund_mast;

      -- log the relavant details
      l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','FUND_CODE'),32) ||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR'),19) ;
      fnd_file.put_line(fnd_file.log,l_msg_str_0);
      fnd_file.put_line(fnd_file.log,' ');
      l_msg_str_1  :=  RPAD(l_c_igf_aw_fund_mast.fund_code,32)||
                       RPAD((p_sc_cal_type||' '||p_sc_seq_num),19);
      fnd_file.put_line(fnd_file.log,l_msg_str_1);
      fnd_file.put_line(fnd_file.log,' ');
      OPEN  c_igf_aw_fund_tp(l_c_fund_mast.fund_id);
      FETCH c_igf_aw_fund_tp INTO l_c_igf_aw_fund_tp;
      IF c_igf_aw_fund_tp%NOTFOUND THEN
        -- rolls back to the save point
        ROLLBACK TO sp_student;
        CLOSE c_igf_aw_fund_tp;
        fnd_message.set_name('IGF','IGF_SP_NO_TERM');
        igs_ge_msg_stack.add;

        -- log the error message
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE l_err_exception;
      END IF;
      CLOSE c_igf_aw_fund_tp;

      -- log the relavant details
      l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER'),32) ||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','TERM'),12) ||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','START_DT'),22) ||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','END_DT'),22)||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','MIN_CRD_POINTS'),19) ||
                       RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','MIN_ATD_TYPE'),32) ||
                       lookup_desc('IGF_AW_LOOKUPS_MSG','TOT_SPNSR_AMT');
      fnd_file.put_line(fnd_file.log,l_msg_str_0);
      fnd_file.put_line(fnd_file.log,' ');

      -- rolling over sponsor student relation for fund and term calendar for the succeeding award year
      FOR l_c_igf_sp_stdnt_rel IN c_igf_sp_stdnt_rel(cp_fund_id => l_c_igf_aw_fund_mast.fund_id)
      LOOP
        BEGIN
        -- declare a save point
        SAVEPOINT sp_spnsr_student;

        -- checks if record exists in fa base record table for the student and award year
        OPEN c_igf_ap_fa_base_rec(cp_person_id => l_c_igf_sp_stdnt_rel.person_id,
                                  cp_cal_type  => p_sc_cal_type,
                                  cp_seq_num   => p_sc_seq_num);
        FETCH c_igf_ap_fa_base_rec  INTO l_c_igf_ap_fa_base_rec;

        -- error out if no fa base record exists for the student award year
        IF c_igf_ap_fa_base_rec%NOTFOUND THEN
          CLOSE c_igf_ap_fa_base_rec;

          -- rolls back to the save point
          ROLLBACK TO sp_spnsr_student;
          fnd_message.set_name('IGF','IGF_SP_NO_FA_BASE_REC');
          igs_ge_msg_stack.add;

          -- log the error message
          fnd_file.put_line(fnd_file.log,' ');
          fnd_file.put_line(fnd_file.log,l_c_igf_sp_stdnt_rel.person_number||'  '||fnd_message.get);

          -- skips the current student
          RAISE l_stud_exception;
        END IF;

        l_base_id := l_c_igf_ap_fa_base_rec.base_id ;
          CLOSE c_igf_ap_fa_base_rec;
          -- Check if succeeding terms are present for the current term passed as
          -- parameter to the process
          OPEN c_igf_aw_cal_rel(cp_cal_type  => l_c_igf_sp_stdnt_rel.ld_cal_type,
                                cp_seq_num   => l_c_igf_sp_stdnt_rel.ld_sequence_number);
          FETCH  c_igf_aw_cal_rel INTO l_c_igf_aw_cal_rel;
          IF c_igf_aw_cal_rel%NOTFOUND THEN

            -- rolls back to the save point
            ROLLBACK TO sp_spnsr_student;
            CLOSE c_igf_aw_cal_rel;

            --Bug 5213852, Logged the new message 'IGF_SP_NO_STDREL_TERM_MAP' and removed the code logic to
            --log 'IGF_AW_FND_RLOVR_LD_NTFND' as the later message is obsoleted.
            fnd_message.set_name('IGF','IGF_SP_NO_STDREL_TERM_MAP');
            fnd_message.set_token('TERM_ALT_CD',l_c_igf_aw_fund_tp.tp_alternate_code);
            fnd_message.set_token('AWD_ALT_CD',l_c_igf_aw_fund_tp.awd_alternate_code);
            fnd_message.set_token('STUDENT_NUM',l_c_igf_sp_stdnt_rel.person_number);
            fnd_message.set_token('SPONSOR_CD',l_c_igf_aw_fund_tp.fund_code);

            igs_ge_msg_stack.add;

            -- log the error message
            fnd_file.put_line(fnd_file.log,' ');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- raises user defined exception so as to skip the student record
            RAISE l_stud_exception;
          END IF;
          CLOSE c_igf_aw_cal_rel;

          -- log the relavant details
          l_msg_str_1  :=  RPAD(l_c_igf_sp_stdnt_rel.person_number,32)||
                           RPAD(l_c_igf_aw_cal_rel.sc_alternate_code,12) ||
                           RPAD(IGS_GE_DATE.IGSCHARDT(l_c_igf_aw_cal_rel.sc_start_dt),22) ||
                           RPAD(IGS_GE_DATE.IGSCHARDT(l_c_igf_aw_cal_rel.sc_end_dt),22) ||
                           NVL(RPAD(TO_CHAR(l_c_igf_sp_stdnt_rel.min_credit_points),19),'                   ') ||
                           NVL(RPAD(l_c_igf_sp_stdnt_rel.min_attendance_type,32),'                                ' )||
                           TO_CHAR(l_c_igf_sp_stdnt_rel.tot_spnsr_amount);

          fnd_file.put_line(fnd_file.log,l_msg_str_1);
          l_spnsr_stdnt_id := NULL;
          l_rowid          := NULL;
          BEGIN
            -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
            igf_sp_stdnt_rel_pkg.insert_row (
                   x_mode                              => 'R',
                   x_rowid                             => l_rowid,
                   x_spnsr_stdnt_id                    => l_spnsr_stdnt_id,
                   x_fund_id                           => l_c_fund_mast.fund_id,
                   x_base_id                           => l_base_id,
                   x_person_id                         => l_c_igf_sp_stdnt_rel.person_id,
                   x_ld_cal_type                       => l_c_igf_aw_cal_rel.sc_cal_type,
                   x_ld_sequence_number                => l_c_igf_aw_cal_rel.sc_sequence_number,
                   x_tot_spnsr_amount                  => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_stdnt_rel.tot_spnsr_amount),
                   x_min_credit_points                 => l_c_igf_sp_stdnt_rel.min_credit_points,
                   x_min_attendance_type               => l_c_igf_sp_stdnt_rel.min_attendance_type
                );
            EXCEPTION
              WHEN OTHERS THEN
                -- rolls back to the save point
                ROLLBACK TO sp_spnsr_student;
                -- log the error message returned by the tbh
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                -- raises user defined exception so as to skip the record
                RAISE l_stud_exception;
            END ;

            -- log relevant details
            fnd_file.put_line(fnd_file.log,' ');
            l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','FEE_CLASS'),32) ||
                             RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','PERCENT'),10) ||
                             lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
            fnd_file.put_line(fnd_file.log,l_msg_str_0);
            fnd_file.put_line(fnd_file.log,' ');
            -- rolling over fee class details
            FOR l_c_igf_sp_std_fc IN c_igf_sp_std_fc(cp_spnsr_stdnt_id => l_c_igf_sp_stdnt_rel.spnsr_stdnt_id)
            LOOP
              -- log relevant details
              l_msg_str_1  :=  RPAD(l_c_igf_sp_std_fc.fee_class,32) ||
                               NVL(RPAD(TO_CHAR(l_c_igf_sp_std_fc.fee_percent),10),'          ' )||
                               TO_CHAR(l_c_igf_sp_std_fc.max_amount);
              fnd_file.put_line(fnd_file.log,l_msg_str_1);
              l_rowid  := NULL;
              l_fee_cls_id := NULL;
              BEGIN
                -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                igf_sp_std_fc_pkg.insert_row (
                         x_mode                              => 'R',
                         x_rowid                             => l_rowid,
                         x_fee_cls_id                        => l_fee_cls_id,
                         x_spnsr_stdnt_id                    => l_spnsr_stdnt_id,
                         x_fee_class                         => l_c_igf_sp_std_fc.fee_class,
                         x_fee_percent                       => l_c_igf_sp_std_fc.fee_percent,
                         x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_std_fc.max_amount)
                  );
              EXCEPTION
                WHEN OTHERS THEN
                  -- rolls back to the save point
                  ROLLBACK TO sp_student;
                  -- log the error message returned by the tbh
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  -- raises user defined exception so as to skip the record
                  RAISE l_err_exception;
              END;
              IF l_c_igf_sp_std_fc.fee_class = 'TUITION' THEN
                -- log relevant details
                fnd_file.put_line(fnd_file.log,' ');
                l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','COURSE_CD'),12) ||
                                 RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','VERSION_NUMBER'),16) ||
                                 RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','PERCENT'),10) ||
                                 lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
                fnd_file.put_line(fnd_file.log,l_msg_str_0);
                fnd_file.put_line(fnd_file.log,' ');
                -- rolling over program details
                FOR l_c_igf_sp_std_prg IN c_igf_sp_std_prg(cp_fee_cls_id => l_c_igf_sp_std_fc.fee_cls_id)
                LOOP
                  -- log relevant details
                  l_msg_str_1  :=  RPAD(l_c_igf_sp_std_prg.course_cd,12) ||
                                   RPAD(l_c_igf_sp_std_prg.version_number,16) ||
                                   NVL(RPAD(TO_CHAR(l_c_igf_sp_std_prg.fee_percent),10),'          ') ||
                                   TO_CHAR(l_c_igf_sp_std_prg.max_amount);
                  fnd_file.put_line(fnd_file.log,l_msg_str_1);
                  l_fee_cls_prg_id := NULL;
                  l_rowid          := NULL;
                  BEGIN
                  -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                    igf_sp_std_prg_pkg.insert_row (
                       x_mode                              => 'R',
                       x_rowid                             => l_rowid,
                       x_fee_cls_prg_id                    => l_fee_cls_prg_id,
                       x_fee_cls_id                        => l_fee_cls_id,
                       x_course_cd                         => l_c_igf_sp_std_prg.course_cd,
                       x_version_number                    => l_c_igf_sp_std_prg.version_number,
                       x_fee_percent                       => l_c_igf_sp_std_prg.fee_percent,
                       x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_std_prg.max_amount)
                    );
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- rolls back to the save point
                      ROLLBACK TO sp_student;
                      -- log the error message returned by the tbh
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                      -- raises user defined exception so as to skip the record
                      RAISE l_err_exception;
                  END;
                  fnd_file.put_line(fnd_file.log,' ');
                  l_msg_str_0  :=  RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','UNIT_CD'),12) ||
                                   RPAD(lookup_desc('IGF_AW_LOOKUPS_MSG','VERSION_NUMBER'),16) ||
                                   lookup_desc('IGF_AW_LOOKUPS_MSG','MAX_AMOUNT');
                  fnd_file.put_line(fnd_file.log,l_msg_str_0);
                  fnd_file.put_line(fnd_file.log,' ');
                  -- rolling over unit details
                  FOR l_c_igf_sp_std_unit IN c_igf_sp_std_unit(cp_fee_cls_prg_id => l_c_igf_sp_std_prg.fee_cls_prg_id)
                  LOOP
                    -- log relevant details
                    l_msg_str_1  :=  RPAD(l_c_igf_sp_std_unit.unit_cd,12) ||
                                     RPAD(l_c_igf_sp_std_unit.version_number,16) ||
                                     TO_CHAR(l_c_igf_sp_std_unit.max_amount);
                    fnd_file.put_line(fnd_file.log,l_msg_str_1);
                    l_fee_cls_unit_id := NULL;
                    l_rowid := NULL;
                    BEGIN
                    -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                      igf_sp_std_unit_pkg.insert_row (
                        x_mode                              => 'R',
                        x_rowid                             => l_rowid,
                        x_fee_cls_unit_id                   => l_fee_cls_unit_id,
                        x_fee_cls_prg_id                    => l_fee_cls_prg_id,
                        x_unit_cd                           => l_c_igf_sp_std_unit.unit_cd,
                        x_version_number                    => l_c_igf_sp_std_unit.version_number,
                        x_max_amount                        => igs_fi_gen_gl.get_formatted_amount(l_c_igf_sp_std_unit.max_amount)
                     );
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- rolls back to the save point
                        ROLLBACK TO sp_student;
                        -- log the error message returned by the tbh
                        fnd_file.put_line(fnd_file.log,fnd_message.get);
                        -- raises user defined exception so as to skip the record
                        RAISE l_err_exception;
                    END;
                  END LOOP;
                  fnd_file.put_line(fnd_file.log,' ');
                END LOOP;
              END IF;
            END LOOP;
          EXCEPTION
            WHEN l_stud_exception THEN
              NULL;
          END;
        END LOOP;

      EXCEPTION
        WHEN l_err_exception THEN
          NULL;
      END;
  END sponsor_student_rollover;


END igf_sp_rollover ;

/
