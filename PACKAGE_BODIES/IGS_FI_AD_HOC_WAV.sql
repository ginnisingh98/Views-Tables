--------------------------------------------------------
--  DDL for Package Body IGS_FI_AD_HOC_WAV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_AD_HOC_WAV" AS
/* $Header: IGSFI70B.pls 120.3 2006/06/01 15:26:21 sapanigr noship $ */

  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 5/12/2001
  --Purpose: This package is used for group application of waiver on charges
  --or group release of waiver present on charges
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr   30-May-2006      Bug 5251760 - Modified procedure group_waiver_proc for R12 XBuild3 SQL Repository Perf tuning.
  --sapanigr   17-Feb-2006      Bug 5018046 - Modified procedure group_waiver_proc for R12 SQL Repository Perf tuning.
  --pathipat   26-Apr-2004      Bug 3578249 - Modified function test_mode() and group_waiver_proc()
  --vvutukur   20-Jan-2004      Bug#3348787.Modified function test_mode.
  --uudayapr   26-SEP-2003      Bug:3055356 - Replaced the Default Intiallization of sysdate to l_release_dt
  --                                          when null ,Added code for message log in group_waiver_proc procedure.
  --pathipat   24-Jun-2003      Bug: 3018104 - Impact of changes to person id group views
  --                            Replaced igs_pe_persid_group_v with igs_pe_persid_group in group_waiver_proc()
  --shtatiko   22-APR-2003      Enh# 2831569, Modified group_waiver_proc
  --vvutukur   21-Jan-2003      Bug#2751136.Modifications done in procedure group_waiver_proc and function lookup_desc.
  -- SYKRISHN  03-JAN2003        Bug 2684895 - Logged person group code instead of person group id
  --                            used igs_fi_gen_005.finp_get_prsid_grp_code()
  --                            some lookups were missing - introduced 4 lookup codes to IGS_FI_LOCKBOX
  --smvk        16-Sep-2002     Bug # 2564643. Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2
  --                            from procedure group_waiver_proc. As a part of Subaccount Removal Build.
  --vvutukur    05-Jul-2002     Modified group_waiver_proc procedure to exclude reversed charges
  --                            from being selected through cursor c_per_chg as part of Bug#2405762.
  --jbegum      13-Jun-2002     Bug#2412433 Added a validation checking if the Balance Type passed
  --                            is a STANDARD Balance.If it is then concurrent process errors out.
  --sarakshi    28-Feb-2002     bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v
  --sbaliga        25-feb-2002        Modified procedure group_waiver_proc as part of #2144600
  -------------------------------------------------------------------

  FUNCTION fee_perd (p_cal_type IN igs_ca_inst.cal_type%TYPE ,
                     p_seq_number IN igs_ca_inst.sequence_number%TYPE ) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 20/12/2001
  --
  --
  --Purpose: Returns the fee period for the cal type and sequence number combination.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR cur_perd(cp_cal_type  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                  cp_seq_num   igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
    SELECT cal_type , start_dt , end_dt
    FROM igs_ca_inst
    WHERE cal_type = cp_cal_type
    AND sequence_number = cp_seq_num;

  l_fee_per  cur_perd%ROWTYPE;
  l_string   VARCHAR2(50);

  BEGIN
     OPEN cur_perd(p_cal_type,
                   p_seq_number);
     FETCH cur_perd INTO l_fee_per;
     IF  cur_perd%NOTFOUND THEN
         CLOSE  cur_perd;
         RETURN NULL;
     ELSE
         l_string := l_fee_per.cal_type||'    '||l_fee_per.start_dt||' - '||l_fee_per.end_dt;
         CLOSE  cur_perd;
     END IF;

     RETURN l_string;

  END fee_perd;

  FUNCTION lookup_desc( p_type IN igs_lookup_values.lookup_type%TYPE,
                        p_code IN igs_lookup_values.lookup_code%TYPE ) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 5/12/2001
  --
  --
  --Purpose: Returns the meaning for the given lookup code.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vvutukur   21-Jan-2003 Bug#2751136.Used igs_lookup_values in stead of igs_lookups_view.Removed cursor cur_desc and its implementation,instead,
  --                       made a call to igs_fi_gen_gl.get_lkp_meaning,which returns the meaning of lookup code of a specific lookup type.
  -------------------------------------------------------------------
    l_desc igs_lookup_values.meaning%TYPE;

    BEGIN

      IF p_code IS NULL THEN
         RETURN NULL ;
      ELSE
        l_desc := igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type   => p_type,
                                                p_v_lookup_code   => p_code
                                                );
      END IF ;

      RETURN l_desc;

  END lookup_desc;

  PROCEDURE log_messages ( p_msg_name IN VARCHAR2 ,
                           p_msg_val  IN VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 5/12/2001
  --
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

    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  END log_messages ;

/* Removed the function sub_name as a part of Subaccount removal Build. Bug # 2564643 */

  FUNCTION test_mode (p_code IN fnd_lookup_values.lookup_code%TYPE) RETURN VARCHAR2 IS

  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 20/12/2001
  --
  --
  --Purpose: Returns the meaning of the code passed to the test mode parameter.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat   26-Apr-2004      Bug 3578249 - Modified cur_mode - replaced fnd_lookup_values
  --                            with igs_lookup_values.
  --vvutukur    20-Jan-2004     Bug#3348787.Modified cursor cur_mode.
  -------------------------------------------------------------------

  CURSOR cur_mode(cp_code  fnd_lookup_values.lookup_code%TYPE) IS
    SELECT meaning
    FROM  igs_lookup_values
    WHERE lookup_code = cp_code
    AND   lookup_type = 'YES_NO';

    l_mode fnd_lookup_values.meaning%TYPE ;

  BEGIN

     OPEN cur_mode(p_code);
     FETCH cur_mode INTO l_mode ;
     CLOSE cur_mode ;
     RETURN l_mode ;

  END test_mode;

  PROCEDURE group_waiver_proc( errbuf                   OUT NOCOPY VARCHAR2                                               ,
                               retcode                  OUT NOCOPY NUMBER                                                 ,
                               p_c_action               IN  VARCHAR2                                               ,
                               p_c_bal_type             IN  igs_lookups_view.lookup_code%TYPE                      ,
                               p_d_start_dt             IN  VARCHAR2                                               ,
                               p_d_end_dt               IN  VARCHAR2                                               ,
                               p_d_release_dt                IN  VARCHAR2                                               ,
                               p_n_person_id            IN  igs_pe_person_v.person_id%TYPE                         ,
                               p_n_pers_id_grp_id       IN  igs_pe_persid_group_v.group_id%TYPE                    ,
                               p_c_fee_period           IN  VARCHAR2                                               ,
                              /* Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2, as a part of Bug # 2564643 */
                               p_c_fee_type_1           IN  igs_fi_inv_int.fee_type%TYPE                           ,
                               p_c_fee_type_2           IN  igs_fi_inv_int.fee_type%TYPE                           ,
                               p_c_fee_type_3           IN  igs_fi_inv_int.fee_type%TYPE                           ,
                               p_c_test_flag            IN  fnd_lookup_values.lookup_code%TYPE
                               )  AS
  ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 5/12/2001
  --
  --Purpose: This procedure is the main procedure for applying or releasing waivers on
  --         group of charges having similar attributes, at one go.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr   30-May-2006      Bug 5251760 - Modified cursor c_per_id by replacing igs_fi_parties_v with base tables
  --sapanigr   17-Feb-2006      Bug 5018036 - 1. Added validation to check if both person id and person id group are not null
  --                            so that full table scan on IGS_FI_INV_INT_ALL can be avoided.
  --                            2. Broke up UNION in cursor c_person to make two different cursors c_person and c_pers_group.
  --                            This solves Non mergability issue and has improved performance.
  --pathipat   26-Apr-2004      Bug 3578249 - Modified code w.r.t p_c_test_flag - Checked against Y and N
  --                            instead of against 1 and 2 respectively due to change in lookup_type used.
  --uudayapr   26-sep-2003      Bug:3055356-Added the validation for logging message to log file when release date
  --                                        is provided when the Action is waive.
  --                                        Removed the Default intiallization to Sysdate when release date is not given
  --                                        for release action and placed the code for logging the error message to the
  --                                        log file and error out the process.
  --                                        Added the Code for logging message to log file when start date and end date
  --                                        is provided when the action is release.
  --pathipat   24-Jun-2003      Bug: 3018104 - Impact of changes to person id group views
  --                            Replaced igs_pe_persid_group_v with igs_pe_persid_group in c_grp_id
  --shtatiko   22-APR-2003      Enh# 2831569, Added check for Manage Accounts System Option
  --vvvutukur  21-Jan-2003      Bug#2751136.Removed app_exception.raise_exception whenever a parameter validation fails, instead, used a variable
  --                            l_valid to identify the failure of validation,after logging the error message. After all the parameters are validated,
  --                            set the retcode to 2 and stopped processing further.Also, used message IGS_FI_NO_PERS_PGRP instead of
  --                            IGS_FI_PRS_OR_PRSIDGRP,when both person number and person group parameters have been passed to the process.
  -- SYKRISHN  03-JAN2003        Bug 2684895 - Logged person group code instead of person group id
  --                            used igs_fi_gen_005.finp_get_prsid_grp_code()
  --                            some lookups were missing - introduced 4 lookup codes to IGS_FI_LOCKBOXLOCKBOX
  --smvk        19-Sep-2002     Bug # 2564643. Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2
  --                            from procedure group_waiver_proc. As a part of Subaccount Removal Build.
  --vvutukur    05-Jul-2002     Excluded reversed charges from being selected through
  --                            cursor c_per_chg as part of Bug#2405762.
  --sbaliga     25-feb-2002        Excluded charges of  type 'REFUND' from being selected
  --                                through cursor c_per_chg as part of #2144600.
  -------------------------------------------------------------------


  l_start_dt       igs_fi_inv_wav_det.start_dt%TYPE                  ;
  l_end_dt         igs_fi_inv_wav_det.end_dt%TYPE                    ;
  l_release_dt     igs_fi_inv_wav_det.end_dt%TYPE                    ;
  l_rowid          igs_fi_inv_wav_det_v.row_id%TYPE                  ;
  l_fee_cal_type   igs_fi_f_typ_ca_inst.fee_cal_type%TYPE            ;
  l_fee_ci_seq_num igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE  ;
  l_per_num        igs_pe_person_v.person_number%TYPE                ;
  l_msg_str        VARCHAR2(1000)                                    ;

  TYPE tab_party_rec IS TABLE OF hz_parties.party_id%TYPE INDEX BY BINARY_INTEGER;
  v_tab_party_rec tab_party_rec ;
  l_n_party_id hz_parties.party_id%TYPE;



  CURSOR c_grp_id (cp_group_id  igs_pe_persid_group_v.group_id%TYPE) IS
     SELECT 'X'
     FROM   igs_pe_persid_group
     WHERE  group_id      =  cp_group_id
     AND    closed_ind    = 'N'
     AND    TRUNC(create_dt) <= TRUNC(SYSDATE);

  l_v_grp_id    VARCHAR2(1);

  CURSOR c_per_id (cp_n_person_id  hz_parties.party_id%TYPE) IS
     SELECT hz.party_number person_number,
            nvl(pp.person_name, hz.party_name) full_name
     FROM   hz_parties hz, hz_person_profiles pp
     WHERE  hz.party_id =  cp_n_person_id
     AND    pp.party_id = cp_n_person_id;

  l_v_per_id    c_per_id%ROWTYPE;

  CURSOR c_cal_per  (cp_cal_type        igs_fi_f_typ_ca_inst.fee_cal_type%TYPE                 ,
                     cp_ci_seq_num      igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
     SELECT 'X'
     FROM   igs_ca_type t , igs_ca_inst i , igs_ca_stat s
     WHERE t.closed_ind = 'N'
     AND t.s_cal_cat = 'FEE'
     AND t.cal_type = cp_cal_type
     AND t.cal_type = i.cal_type
     AND i.sequence_number = cp_ci_seq_num
     AND i.cal_status = s.cal_status
     AND s.s_cal_status = 'ACTIVE';

  l_v_cal_per   VARCHAR2(1);

  CURSOR c_pers_group (cp_person_grp     igs_pe_persid_group_v.group_id%TYPE) IS
     SELECT person_id
     FROM igs_pe_prsid_grp_mem
     WHERE group_id = cp_person_grp
     AND (start_date <= TRUNC(SYSDATE) OR start_date IS NULL)
     AND (end_date >= TRUNC(SYSDATE) OR end_date IS NULL)
     ORDER BY 1;

  CURSOR c_person(cp_person_id              hz_parties.party_id%TYPE) IS
     SELECT party_id person_id
     FROM hz_parties
     WHERE party_id = cp_person_id
     AND   party_type IN ('ORGANIZATION','PERSON');

  CURSOR c_per_chg (cp_person_id        igs_pe_person_v.person_id%TYPE                   ,
                    cp_fee_cal_type     igs_fi_f_typ_ca_inst.fee_cal_type%TYPE           ,
                    cp_fee_ci_seq_no    igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE ,
                    /* Removed the cursor parameters cp_sub_acc1 and cp_sub_acc2 as a part of the Bug # 2564643 */
                    cp_fee_type1        igs_fi_inv_int.fee_type%TYPE                     ,
                    cp_fee_type2        igs_fi_inv_int.fee_type%TYPE                     ,
                    cp_fee_type3        igs_fi_inv_int.fee_type%TYPE) IS
     SELECT *
     FROM   igs_fi_inv_int
     WHERE  person_id                =  cp_person_id
     AND    fee_cal_type             =  cp_fee_cal_type
     AND    fee_ci_sequence_number   =  cp_fee_ci_seq_no
     AND    transaction_type         <>'REFUND'
     AND    NVL(waiver_flag,'N') <> 'Y'
     AND    ((cp_fee_type1 IS NULL AND cp_fee_type2 IS NULL  AND cp_fee_type3 IS NULL) OR
             (cp_fee_type1 IS NOT NULL  AND fee_type = cp_fee_type1) OR
             (cp_fee_type2 IS NOT NULL  AND fee_type = cp_fee_type2) OR
             (cp_fee_type3 IS NOT NULL  AND fee_type = cp_fee_type3)
            );

  CURSOR c_chg_wav (cp_inv_id        igs_fi_inv_wav_det.invoice_id%TYPE                   ,
                    cp_bal_type      igs_fi_inv_wav_det.balance_type%TYPE                 ,
                    cp_rel_dt        igs_fi_inv_wav_det.end_dt%TYPE) IS
     SELECT *
     FROM   igs_fi_inv_wav_det_v
     WHERE invoice_id             =  cp_inv_id
     AND balance_type             =  cp_bal_type
     AND ((end_dt IS NOT NULL  AND end_dt > cp_rel_dt) OR (end_dt IS NULL));

  l_chg_wav  c_chg_wav%ROWTYPE;
  l_valid    BOOLEAN := TRUE;
  l_v_message_name     fnd_new_messages.message_name%TYPE;
  l_v_manage_accounts  igs_fi_control.manage_accounts%TYPE;
  l_validation_exp     EXCEPTION;

  BEGIN

    /** sets the orgid  **/
    IGS_GE_GEN_003.set_org_id(NULL) ;

    /**  initialises the out NOCOPY parameter to 0  **/
    retcode := 0 ;

    /** Converting the date parameters passed as datatype VARCHAR2 to datatype DATE **/
    IF p_d_start_dt IS NOT NULL THEN
      l_start_dt        :=  IGS_GE_DATE.igsdate(p_d_start_dt)   ;
    END IF;
    IF p_d_end_dt IS NOT NULL THEN
      l_end_dt          :=  IGS_GE_DATE.igsdate(p_d_end_dt)     ;
    END IF;
    IF p_d_release_dt IS NOT NULL THEN
      l_release_dt      :=  IGS_GE_DATE.igsdate(p_d_release_dt) ;
    END IF;

    /** Extracting the Fee Cal Type and Fee Ci Sequence Number from the Fee Period Parameter **/
    l_fee_cal_type    :=  RTRIM(SUBSTR(p_c_fee_period ,1,10))          ;
    l_fee_ci_seq_num  :=  TO_NUMBER(RTRIM(SUBSTR(p_c_fee_period,12)))  ;

    /** Extracting the person_number if a person id has been passed in parameter p_n_person_id **/
    IF p_n_person_id IS NOT NULL THEN

       OPEN   c_per_id(p_n_person_id);
       FETCH  c_per_id INTO l_v_per_id;
       IF  c_per_id%NOTFOUND THEN
         l_per_num := NULL;
         CLOSE  c_per_id;
       ELSE
         l_per_num := l_v_per_id.person_number;
         CLOSE  c_per_id;
       END IF;

    END IF;

    /** logs all the parameters in the LOG **/
    log_messages(lookup_desc('IGS_FI_LOCKBOX','ACTION'),p_c_action);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','BALANCE_TYPE'),lookup_desc('IGS_FI_BALANCE_TYPE',p_c_bal_type));
    log_messages(lookup_desc('IGS_FI_LOCKBOX','WAIVE_START_DT'),l_start_dt);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','WAIVE_END_DT'),l_end_dt);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','WAIVE_REL_DT'),l_release_dt);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','PARTY'),l_per_num);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','PERSON_GROUP'),igs_fi_gen_005.finp_get_prsid_grp_code(p_n_pers_id_grp_id));
    log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_PERIOD'),fee_perd(l_fee_cal_type,l_fee_ci_seq_num));

/* Removed the code which logs the value of the parameters p_n_sub_acc_1 and p_n_sub_acc_2 */

    log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE1'),p_c_fee_type_1);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE2'),p_c_fee_type_2);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE3'),p_c_fee_type_3);
    log_messages(lookup_desc('IGS_FI_LOCKBOX','TEST_MODE'),test_mode(p_c_test_flag));

    -- Check the value of Manage Accounts System Option value.
    -- If its NULL or OTHER then this process should error out by logging message.
    igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                  p_v_message_name => l_v_message_name );
    IF l_v_manage_accounts IS NULL OR l_v_manage_accounts = 'OTHER' THEN
      fnd_message.set_name ( 'IGS', l_v_message_name );
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
      RAISE l_validation_exp;
    END IF;

    /** Only person id or group id should be passed to the process
        If both are passed as parameter then the process errors out NOCOPY **/

    IF (p_n_person_id IS NOT NULL AND p_n_pers_id_grp_id IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_FI_NO_PERS_PGRP');
        IGS_GE_MSG_STACK.ADD;
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        l_valid := FALSE;
    END IF;

    -- Bug# 5018036, Either of the two parameters must be specified.
    IF (p_n_person_id IS NULL AND p_n_pers_id_grp_id IS NULL) THEN
      fnd_message.set_name ( 'IGS', 'IGS_FI_PRS_PRSIDGRP_NULL') ;
      igs_ge_msg_stack.ADD;
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      l_valid := FALSE;
    END IF;

    /** Validating whether the Person Id Group passed to parameter p_n_pers_id_grp_id
        is a valid Person Id Group **/
    IF p_n_pers_id_grp_id IS NOT NULL THEN

        OPEN   c_grp_id(p_n_pers_id_grp_id);
        FETCH  c_grp_id INTO l_v_grp_id;

        IF  c_grp_id%NOTFOUND THEN
            CLOSE  c_grp_id;
            FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVPERS_ID_GRP');
            IGS_GE_MSG_STACK.ADD;
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            l_valid := FALSE;
        END IF;
        CLOSE  c_grp_id;

    END IF;

    /** Validating whether the Person Id passed to parameter p_n_person_id
        is a valid Person Id  **/

    IF p_n_person_id IS NOT NULL THEN

        OPEN   c_per_id(p_n_person_id);
        FETCH  c_per_id INTO l_v_per_id;

        IF  c_per_id%NOTFOUND THEN
            CLOSE  c_per_id;
            FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PERSON_ID');
            IGS_GE_MSG_STACK.ADD;
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            l_valid := FALSE;
        END IF;
        CLOSE  c_per_id;

    END IF;

    /** Validating whether the value passed to parameter p_c_action
        is either WAIVE OR RELEASE  **/

    IF p_c_action NOT IN ('WAIVE','RELEASE') THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        l_valid := FALSE;
    END IF;

    /** Validating whether the start date has been provided in case the action is 'WAIVE'
        Also if the start date has been provided,it should be greater than or equal sysdate **/

    IF p_c_action = 'WAIVE' THEN
       IF l_start_dt IS NULL THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_WV_STRT_DT');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          l_valid := FALSE;
       ELSIF TRUNC(l_start_dt) < TRUNC(SYSDATE) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_NOT_LT_CURRDT');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          l_valid := FALSE;
       END IF;

       --Added the If Condtion to log a message when Waiver Release date is mentioned
       --and the Action Type is WAIVE.
       IF l_release_dt IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_RL_DT_NR');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       END IF;


    END IF;

    /** Validating whether the end date is greater than or equal to the start date
        in case the action is 'WAIVE' **/

    IF p_c_action = 'WAIVE' THEN
       IF l_end_dt IS NOT NULL AND l_end_dt < l_start_dt THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_END_DT_GE_ST_DATE');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          l_valid := FALSE;
       END IF;
    END IF;

    /** Validating that for action 'RELEASE' if the release date has been provided,it should be greater than
       or equal to sysdate. If it has not been provided then it is set to sysdate**/

    IF p_c_action = 'RELEASE' THEN
       --Added the If condition to check whether l_end_dt or
       --l_start_dt is Null if Not Log the ErrorMessage to the Log File.

       IF l_end_dt IS NOT NULL OR l_start_dt IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_WR_DTS_NR');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       END IF;

       IF l_release_dt IS NULL THEN
       --Removed the Default Intiallization to Sysdate
       --and Logged the Error Message and Errored Out
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_RLS_DT');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          l_valid := FALSE;
       ELSIF TRUNC(l_release_dt) < TRUNC(SYSDATE) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_RLS_CRR_DT');
          IGS_GE_MSG_STACK.ADD;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          l_valid := FALSE;
       END IF;
    END IF;

   /** Validating whether the Calendar Type passed is a FEE calendar and it is not closed
      (ie. closed_ind = 'N')
       Also the Calendar Instance of the Calendar Type passed should have system calendar
       status as ACTIVE **/

   OPEN   c_cal_per(l_fee_cal_type,l_fee_ci_seq_num);
   FETCH  c_cal_per INTO l_v_cal_per;

   IF  c_cal_per%NOTFOUND THEN
       CLOSE  c_cal_per;
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       l_valid := FALSE;
   END IF;
   CLOSE  c_cal_per;

   -- Validation added as part of Bug#2412433
   /** Validating that the Balance Type is not a STANDARD Balance **/

   IF p_c_bal_type = 'STANDARD' THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      l_valid := FALSE;
   END IF;

   --if any of the parameter validation fails,process logs the error messages and error out.
   IF NOT l_valid THEN
     retcode := 2;
     RETURN;
   END IF;

   -- Bug 5018036. If person id group is passed then fetch records using c_pers_group else use cur_person.
   IF p_n_pers_id_grp_id IS NOT NULL THEN
       OPEN c_pers_group(p_n_pers_id_grp_id);
       FETCH c_pers_group BULK COLLECT INTO v_tab_party_rec;
       CLOSE c_pers_group;
   ELSE
       OPEN  c_person(p_n_person_id);
       FETCH c_person BULK COLLECT INTO v_tab_party_rec;
       CLOSE c_person;
   END IF;

   /** Looping thru all identified persons for the Ad Hoc Group Waiver Process **/

   IF v_tab_party_rec.COUNT > 0 THEN
     -- Loop across all the Person ids identified for processing for Refunds
     FOR l_n_cntr IN v_tab_party_rec.FIRST..v_tab_party_rec.LAST
     LOOP
       l_n_party_id := v_tab_party_rec(l_n_cntr);

       OPEN   c_per_id(l_n_party_id);
       FETCH  c_per_id INTO l_v_per_id;


       FND_MESSAGE.SET_NAME('IGS','IGS_FI_PROC_PERSON');
       FND_MESSAGE.SET_TOKEN('NUMBER',l_v_per_id.person_number);
       FND_MESSAGE.SET_TOKEN('NAME',l_v_per_id.full_name);
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

       CLOSE  c_per_id;
       /* Removed the logging of subaccount related information, as a part of Bug # 2564643 */
       l_msg_str   :=   RPAD(lookup_desc('IGS_FI_LOCKBOX','INVOICE_NUMBER'),62)            ||
                        RPAD(lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE'),12)                  ||
                        LPAD(lookup_desc('IGS_FI_LOCKBOX','INVOICE_AMOUNT'),22);

       FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str);


       /** Looping thru all identified charges for a person for the Ad Hoc Group Waiver Process **/

       FOR l_rec_per_chg IN c_per_chg( l_n_party_id           ,
                                       l_fee_cal_type         ,
                                       l_fee_ci_seq_num       ,
                                      /* Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2 as a part of Bug # 2564643 */
                                       p_c_fee_type_1         ,
                                       p_c_fee_type_2         ,
                                       p_c_fee_type_3 )
       LOOP

           IF p_c_action = 'WAIVE' THEN

              BEGIN

                  /** Logging message that for this charge the waiver is being done **/
                  /* Removed the logging of subaccount related information, as a part of Bug # 2564643 */
                  l_msg_str   :=   RPAD(l_rec_per_chg.invoice_number,62)            ||
                                   RPAD(l_rec_per_chg.fee_type,12)                  ||
                                   LPAD(TO_CHAR(l_rec_per_chg.invoice_amount),22);

                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str);

                  /** For every charge found for a person , inserting a waiver record in the table
                      igs_fi_inv_wav_det if Test Mode is NO.
                      This record is created for an identified charge and the balance type passed in
                      the parameter p_c_bal_type **/

                  IF p_c_test_flag = 'Y' THEN

                     igs_fi_inv_wav_det_pkg.before_dml
                     (p_action                            => 'INSERT',
                      x_rowid                             => l_rowid,
                      x_invoice_id                        => l_rec_per_chg.invoice_id,
                      x_balance_type                      => p_c_bal_type,
                      x_start_dt                          => l_start_dt,
                      x_end_dt                            => l_end_dt
                     );

                  ELSIF  p_c_test_flag = 'N' THEN


                     igs_fi_inv_wav_det_pkg.insert_row
                     (x_rowid               => l_rowid,
                      x_invoice_id          => l_rec_per_chg.invoice_id,
                      x_balance_type        => p_c_bal_type,
                      x_start_dt            => l_start_dt,
                      x_end_dt              => l_end_dt,
                      x_mode                => 'R'
                     ) ;

                  END IF;

              EXCEPTION
                  WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END ;

           ELSIF p_c_action = 'RELEASE' THEN

                  /** For every charge found for a person , checking whether waiver exists for this
                      charge and the balance type passed in the parameter p_c_bal_type .
                      If waiver record found in the table igs_fi_inv_wav_det, release the waiver  **/

                  /** Release functionality is as follows :
                      If start date of the waiver record is greater than release date then delete the
                      waiver record.
                      If start date of waiver record is less than or equal to release date then
                      update the end date to release date.
                      Note : For releasing a waiver only those waiver records are considered whose
                             end date is either null or is greater than the release date.
                             This is so because waiver records with end date less than release date will
                             already be used for waiver before the release date **/
                  FOR l_chg_wav IN c_chg_wav(l_rec_per_chg.invoice_id,
                                             p_c_bal_type,
                                             l_release_dt)
                  LOOP

                      /** Logging message that for this charge the release is being done **/
                      /* Removed the logging of subaccount related information, as a part of Bug # 2564643 */
                      l_msg_str   :=   RPAD(l_rec_per_chg.invoice_number,62)            ||
                                       RPAD(l_rec_per_chg.fee_type,12)                  ||
                                       LPAD(TO_CHAR(l_rec_per_chg.invoice_amount),22);

                      FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str);

                      IF p_c_test_flag = 'N' THEN

                        IF l_chg_wav.start_dt > l_release_dt THEN

                           igs_fi_inv_wav_det_pkg.delete_row
                               (x_rowid               => l_chg_wav.row_id
                                );

                        ELSE

                           igs_fi_inv_wav_det_pkg.update_row
                               (x_rowid               => l_chg_wav.row_id,
                                x_invoice_id          => l_chg_wav.invoice_id,
                                x_balance_type        => l_chg_wav.balance_type,
                                x_start_dt            => l_chg_wav.start_dt,
                                x_end_dt              => l_release_dt,
                                x_mode                => 'R'
                               ) ;

                        END IF;/** End if of IF l_chg_wav.start_dt > l_release_dt **/


                      END IF;/** End if of IF p_c_test_flag = 'N' **/

                  END LOOP; /** End of loop for waiver records **/

           END IF; /** End if of IF checking for WAIVE or RELEASE **/

       END LOOP; /** End of charges loop**/

     END LOOP;/** End of person loop**/

   END IF; /** End if of IF checking for v_tab_party_rec.COUNT > 0 **/


  EXCEPTION

    WHEN l_validation_exp THEN
      retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

  END group_waiver_proc ;  /** procedure ends here **/

END igs_fi_ad_hoc_wav;  /** End of package body **/

/
