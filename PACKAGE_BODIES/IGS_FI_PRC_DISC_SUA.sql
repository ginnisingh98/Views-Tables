--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_DISC_SUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_DISC_SUA" AS
/* $Header: IGSFI64B.pls 120.6 2006/06/19 09:36:28 gurprsin noship $ */
/*=======================================================================+
 |                   Oracle India, IDC , Hyderabad.                      |
 |                                                                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_PRC_DISC_SUA
 |                                                                       |
 | NOTES                                                                 |
 |      This package accesses the charges table to get the unit records  |
 |      where the student has a positive balance for i.e., the student   |
 |      has not paid for the units he has enrolled into.Check has been   |
 |      done for waiving also. If balance type parameter is specified in |
 |      the as a parameter, exclusion rules will also be checked         |
 |      whether the charge is excluded for the specified invoice of      |
 |      particular unit. If the parameter test run is passed as NO       |
 |      to this package, then Drop/Discontinue the unit attempts and log |
 |      appropriate messages.If the parameter test run is YES, then does |
 |      not do the actual dropping of unit but gives the log file of all |
 |      units that will qualify for dropping/discontinuation for the     |
 |      students.                                                        |
 |                                                                       |
 | HISTORY                                                               |
 | Who        When        What                                           |
 | gurprsin   14-Jun-2006 Bug 5123583, Added a cursor and code logic to  |
 |                        display calendar instance description in the   |
 |                        log file.                                      |
 |                        Modified the format and associated             |
 |                        the code logic in 'drop_disc_sua_non_payment'  |
 |                        to display the output in the log file.         |
 | sapanigr   01-Jun-2006 Bug#5251760. Review comments addressed         |
 | sapanigr   31-May-2006 Bug#5251760. Modified cursor cur_person_unit_outstdng_chrgs |
 |                        in drop_disc_sua_non_payment as part of R12    |
 |                        Repository Performance tuning for xBuild3.     |
 | sapanigr   13-Feb-2006 Bug#5018036. Modified cursor cur_person in     |
 |                        drop_disc_sua_non_payment and global cursor    |
 |                        cur_dcnt_reason_cd as part of R12              |
 |                        Repository Performance tuning.                 |
 | rmaddipa   22-jul-2004 Bug#3776195. Obsoleted get_lookup_meaning,     |
 |                        modified procedure drop_disc_sua_non_payment.  |
 |                        modified function validate_input_parameters    |
 | vvutukur   19-Sep-2003 Enh#3045007.Payment Plans Build.Modified the   |
 |                        procedure drop_disc_sua_non_payment.           |
 | shtaitko   21-Jul-2003 Bug# 3037137,Modified drop_disc_sua_non_payment|
 | pathipat   23-Jun-2003 Bug: 3018104 - Impact of changes to person id  |
 |                        group views - Modified drop_disc_sua_non_payment|
 | pathipat   24-Apr-2003 Enh 2831569 - Commercial Receivables build     |
 |                        Added check for manage_accounts - call to chk_manage_account()
 | svenkata     27-Dec-2002        Added 4 new parameters with defauly value of 'N' to the call to the routine
                                igs_ss_enr_details.drop_selected_units as a part of technical impact.Bug#2686793
 | shtatiko   03-sep-2002 Enh# 2562745 Modified validate_input_parameters|
 |                        modified drop_disc_sua_non_payment.            |
 | vvutukur   23-Sep-2002 Enh#2564643.Modified drop_disc_sua_non_payment.|
 |                        Removed DEFAULT clause from package body.      |
 | vchappid   13-Jun-2002  Bug#2411529, Incorrectly used message name    |
 |                         has been modified                             |
   SYKRISHN       30_APR-2002     Bug 2348883- Modified cursor cur_fee_ci
                 to compare fee type ci status with the system status
        and not with the user entered status - Using Fee Structure status
                               In function validate_input_parameters
 | vvutukur    23-apr-2002     modified the log file to show meanings &  |
 |                             descriptions for person group,balance type|
 |                             and discontinuation reason code , test run|
 | schodava    30-Jan-2002     Enh # 2187247                             |
 |                             Modified PROCEDURE                        |
 |                             drop_disc_sua_non_payment                 |
 | vvutukur    20-dec-2001     Created the file for Unit Drop for Non    |
 |                             Payment Build:  Bug # 2153205             |
 *=======================================================================*/

  g_fee_type_ci_status   CONSTANT VARCHAR2(10) := 'ACTIVE';
  g_lookup_type          CONSTANT VARCHAR2(30) := 'IGS_FI_BALANCE_TYPE';
  g_lookup_type_tr       CONSTANT VARCHAR2(30) := 'VS_AS_YN';
  g_exclude_type         CONSTANT VARCHAR2(10) := 'CHARGE';
  g_transaction_type     CONSTANT VARCHAR2(30) := 'ASSESSMENT';
  g_yes_ind              CONSTANT VARCHAR2(1)  := 'Y';
  g_no_ind               CONSTANT VARCHAR2(1)  := 'N';


  -- Cursor for validation of the Discontinuation Reason Code
  CURSOR cur_dcnt_reason_cd(cp_dcnt_reason_cd    IN VARCHAR2) IS
    SELECT   description
    -- Bug#5018036: Replaced igs_en_dcnt_reasoncd_v by igs_en_dcnt_reasoncd_all
      FROM   igs_en_dcnt_reasoncd_all
      WHERE  discontinuation_reason_cd = cp_dcnt_reason_cd
      AND    closed_ind = g_no_ind
      AND    dcnt_unit_ind = g_yes_ind;

-- Fuction for validating all the Input Paramters
  FUNCTION validate_input_parameters(
                                     p_person_id               IN  igs_pe_person.person_id%TYPE,
                                     p_person_id_grp           IN  igs_pe_prsid_grp_mem_v.group_id%TYPE,
                                     p_fee_period              IN  VARCHAR2,
                                     p_fee_cal_type            IN  igs_fi_inv_int.fee_cal_type%TYPE,
                                     p_fee_ci_sequence_number  IN  igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                                     p_balance_type            IN  igs_fi_balance_rules.balance_name%TYPE,
                                     p_dcnt_reason_cd          IN  igs_en_dcnt_reasoncd_v.discontinuation_reason_cd%TYPE,
                                     p_test_run                IN  VARCHAR2
                                    ) RETURN BOOLEAN IS
/***************************************************
Created By : Venkata.Vutukuri@oracle.com
Date Created By : 02-Jan-2002
Purpose : Function for validation of the Input parameters
Known Limitations, enhancements or remarks : None
Change History
Who              When                      Why
rmaddipa       22-jul-2004        Bug#3776195 Removed the code for logging of input parameters
shtatiko       03-sep-2002        Enh#2562745 Modified cur_balance_lkup_type to exclude balance types INSTALLMENT and OTHER.
vvutukur       23-Sep-2002        Enh#2564643.Removed DEFAULT clause for parameter p_test_run.
vchappid       13-Jun-2002        Bug#2411529, Incorrectly used message name has been modified
SYKRISHN       30_APR-2002        Bug 2348883- Modified cursor cur_fee_ci to compare fee type ci status with the system status
                                     and not with the user entered status - Using Fee Structure status
agairola         02-Jan-2002               For modification of logic
(reverse chronological order - newest change first)
****************************************************/

  -- Cursor for validating the Person Id
  CURSOR cur_person_id(cp_person_id IN igs_pe_person.person_id%TYPE) IS
  SELECT  party_number
  FROM    hz_parties
  WHERE   party_id = cp_person_id;

-- Cursor for validation of the Person Id Group
  CURSOR cur_person_id_group(cp_person_id_grp       IN NUMBER) IS
    SELECT   group_cd
      FROM   igs_pe_persid_group
      WHERE  group_id = cp_person_id_grp
      AND    closed_ind = g_no_ind;

-- Cursor for validation of the Fee Calendar Instance
  CURSOR cur_fee_ci(cp_fee_cal_type             IN VARCHAR2,
                    cp_fee_ci_sequence_number   IN   NUMBER) IS
    SELECT 'x'
      FROM   igs_fi_f_typ_ca_inst fcc,
             igs_fi_fee_str_stat fss
      WHERE  fcc.fee_type_ci_status = fss.fee_structure_status
      AND   fss.s_fee_structure_status = g_fee_type_ci_status
      AND    fcc.fee_cal_type=cp_fee_cal_type
      AND    fcc.fee_ci_sequence_number = cp_fee_ci_sequence_number;

-- Cursor for validation of the Balance Type
-- This cursor has been changed to exclude INSTALLMENT and OTHER balance types as part of Enh# 2562745.
  CURSOR cur_balance_lkup_type(cp_balance_type    IN VARCHAR2) IS
    SELECT  meaning
      FROM  igs_lookup_values
      WHERE lookup_type = g_lookup_type
      AND   lookup_code = cp_balance_type
      AND   lookup_code NOT IN ('STANDARD', 'INSTALLMENT', 'OTHER')
      AND   sysdate BETWEEN NVL(start_date_active, sysdate) AND
                            NVL(end_date_active, sysdate)
      AND   enabled_flag='Y';

  CURSOR cur_test_run(cp_test_run  IN VARCHAR2) IS
    SELECT meaning
    FROM   igs_lookups_view
    WHERE  lookup_type = g_lookup_type_tr
    AND    lookup_code = cp_test_run;

  l_var                  VARCHAR2(1);
  l_flag                 BOOLEAN;
  rec_cur_person_id      cur_person_id%ROWTYPE;
  l_test_run             igs_lookups_view.meaning%TYPE;
  l_balance_type_meaning igs_lookups_view.meaning%TYPE;
  l_dcnt_reason_cd_desc  igs_en_dcnt_reasoncd_v.description%TYPE;
  l_person_grp_cd        igs_pe_persid_group.group_cd%TYPE;

  BEGIN
    l_flag := TRUE;

-- If the person id is not null, then validate if the person id is a valid
-- person id

    IF(p_person_id IS NOT NULL) THEN
       --  Check if the Person ID is valid.
       OPEN  cur_person_id(p_person_id);
       FETCH cur_person_id INTO rec_cur_person_id;

       IF cur_person_id%NOTFOUND THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PERSON_ID');
         fnd_file.put_line(fnd_file.log, FND_MESSAGE.GET);
         l_flag := FALSE;
       END IF;
       CLOSE cur_person_id;
    ELSE
      fnd_file.new_line(fnd_file.log);
    END IF;
-- If the Person Id Group is not null, then validate if the Person Id Group is invalid

      IF p_person_id_grp IS NOT NULL THEN
      --  Check if the Person ID Group is valid.
        OPEN cur_person_id_group(p_person_id_grp );
        FETCH cur_person_id_group INTO l_person_grp_cd;

        IF cur_person_id_group%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PARAMETER');
          FND_MESSAGE.SET_TOKEN('PARAMETER','P_PERSON_ID_GRP');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          l_flag := FALSE;
        END IF;
        CLOSE cur_person_id_group;
      ELSE
        fnd_file.new_line(fnd_file.log);
      END IF;


-- Validate if the Person Id and the Person ID Group both are not passed
-- simultaneously
    IF ((p_person_id_grp IS NOT NULL) AND (p_person_id IS NOT NULL)) THEN
      --  Return FALSE if both the parameters are NOT NULL.
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_flag := FALSE;
    END IF;


-- Validate if the Fee Calendar Instance is valid
    OPEN  cur_fee_ci(p_fee_cal_type,
                     p_fee_ci_sequence_number);
    FETCH cur_fee_ci INTO l_var;

    IF cur_fee_ci%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_FEE_CAL_TYPE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_flag := FALSE;
    END IF;
    CLOSE cur_fee_ci;


-- Validate if the Balance Type is valid
    OPEN  cur_balance_lkup_type(p_balance_type);
    FETCH cur_balance_lkup_type INTO l_balance_type_meaning;


    IF p_balance_type IS NOT NULL AND cur_balance_lkup_type%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PARAMETER');
      FND_MESSAGE.SET_TOKEN('PARAMETER','P_BALANCE_TYPE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_flag := FALSE;
    END IF;
    CLOSE cur_balance_lkup_type;


-- Validate if the Discontinuation Reason is valid
    OPEN  cur_dcnt_reason_cd(p_dcnt_reason_cd);
    FETCH cur_dcnt_reason_cd INTO l_dcnt_reason_cd_desc;


    IF cur_dcnt_reason_cd%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_EN_DISCONT_REAS_CD_CLOS');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_flag := FALSE;
    END IF;
    CLOSE cur_dcnt_reason_cd;

-- Validate if the Discontinuation Reason is valid
    OPEN cur_test_run(p_test_run);
    FETCH cur_test_run INTO l_test_run;

    IF cur_test_run%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_PARAMETER');
      FND_MESSAGE.SET_TOKEN('PARAMETER','P_TEST_RUN');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_flag := FALSE;
    END IF;
    CLOSE cur_test_run;
    fnd_file.new_line(fnd_file.log);

    RETURN l_flag;
  END validate_input_parameters;

  PROCEDURE drop_disc_sua_non_payment(
                                      ERRBUF                    OUT NOCOPY  VARCHAR2,
                                      RETCODE                   OUT NOCOPY  NUMBER,
                                      p_person_id               IN  igs_pe_person.person_id%type,
                                      p_person_id_grp           IN  igs_pe_prsid_grp_mem_v.group_id%type,
                                      p_FEE_PERIOD              IN  VARCHAR2,
                                      p_balance_type            IN  igs_fi_balance_rules.balance_name%type,
                                      p_dcnt_reason_cd          IN  igs_en_dcnt_reasoncd_v.discontinuation_reason_cd%type,
                                      p_test_run                IN  VARCHAR2
                                     ) AS


/***************************************************
Created By : Venkata.Vutukuri@oracle.com
Date Created By : 02-Jan-2002
Purpose : Function for validation of the Input parameters
Known Limitations, enhancements or remarks : None
Change History
Who              When                      What
gurprsin         14-Jun-2006               Bug 5123583, Added a cursor and code logic to
                                           display calendar instance description in the log file.
                                           Modified the format and associated
                                           the code logic to display the output in the log file.

sapanigr         01-Jun-2006               Bug#5251760. Review comments addressed. Minor modifications.
sapanigr         31-May-2006               Bug#5251760. Removed unions in cur_person_unit_outstdng_chrgs to form
                                           three separate cursors. Modified related code accordingly.
sapanigr         13-Feb-2006               Bug#5018036. Modified cursor cur_person. Query now uses igs_pe_person_base_v
                                           instead of igs_pe_person.
rmaddipa         22-jul-2004               Bug#3776195 Replaced the call APP_EXCEPTION.RAISE_EXCEPTION with a
                                           "retcode := 2;" statement and "RETURN;" to remove the 'Unhandled Exception'
                                           in the log,
                                           Added the code for logging the input parameters
stutta           27-Oct-2003               Build #3052438. Passed additional parameter p_sub_unit to funcion call
                                           igs_en_gen_004.enrp_dropall_unit
vvutukur         19-Sep-2003               Enh#3045007.Payment Plans Build.Added validation to check if the Student on
                                           an Active Payment plan. If the student is on an active payment plan, then
                                           the unit is not considered for dropping/discontinuing.
shtatiko         21-JUL-2003               Bug# 3037137, Replaced call to igs_ss_en_wrappers.drop_selected_units
                                           with igs_en_gen_004.enrp_dropall_unit
pathipat         23-Jun-2003               Bug: 3018104 - Impact of changes to person id group views
                                           Modified cur_unit_outstdng_chrgs - replaced igs_pe_prsid_grp_mem_v
                                           with igs_pe_prsid_grp_mem
pathipat         24-Apr-2003               Enh 2831569 - Commercial Receivables build
                                           Added check for manage_accounts - call to chk_manage_account()
svenkata     27-Dec-2002        Added 4 new parameters with defauly value of 'N' to the call to the routine
                                igs_ss_enr_details.drop_selected_units as a part of technical impact.Bug#2686793
shtatiko         04-Oct-2002               Enh# 2562745, Added calls to FINP_GET_BALANCE_RULE.
                                           Added a parameter in the invocation of check_exclusion_rules.
vvutukur         23-Sep-2002               Enh#2564643.Removed references to subaccount_id from cursor
                                           cur_unit_outstdng_chrgs and its usage and also removed
                                           DEFAULT clause from package body as a gscc fix.
schodava         30-Jan-2002               Enh # 2187247
                                           SFCR021 - FCI-LCI Relation
agairola         02-Jan-2002               For modification of logic
(reverse chronological order - newest change first)
****************************************************/

-- Cursor for getting the details for the charges for the person which have the Amount Due as greater than zero
-- and which have been created due to the Fee Assessment Run and have the Unit Section details
-- and the records do not have waiver details

  CURSOR cur_person_chrgs(cp_n_person_id              IN hz_parties.party_id%type,
                          cp_v_balance_type           IN igs_fi_balance_rules.balance_name%TYPE,
                          cp_v_fee_cal_type           IN igs_fi_inv_int_all.fee_cal_type%TYPE,
                          cp_n_fee_ci_sequence_number IN igs_fi_inv_int_all.fee_ci_sequence_number%TYPE
                          ) IS
    SELECT  hd.person_id person_id,
            ln.uoo_id uoo_id,
            hd.course_cd,
            hd.invoice_creation_date invoice_creation_date,
            hd.fee_type,
            hd.fee_cal_type,
            hd.fee_ci_sequence_number,
            hd.invoice_id,
            hd.invoice_amount_due
      FROM  igs_fi_inv_int_all hd,
            igs_fi_invln_int_v ln
    WHERE hd.invoice_id = ln.invoice_id
    AND  hd.transaction_type = g_transaction_type
    AND  hd.person_id = cp_n_person_id
    AND  hd.invoice_amount_due > 0
    AND  hd.fee_cal_type = cp_v_fee_cal_type
    AND  hd.fee_ci_sequence_number = cp_n_fee_ci_sequence_number
    AND  ln.uoo_id IS NOT NULL
    AND  hd.course_cd IS NOT NULL
    AND  NOT EXISTS (SELECT 'X'
                     FROM igs_fi_inv_wav_det wd
                     WHERE     wd.invoice_id = hd.invoice_id
                     AND       wd.balance_type = cp_v_balance_type
                     AND       (wd.end_dt is not null AND sysdate
                     BETWEEN   wd.start_dt and wd.end_dt))
    ORDER BY person_id,course_cd, uoo_id,invoice_creation_date;

  CURSOR cur_person_group_chrgs(cp_n_person_id_grp          IN igs_pe_prsid_grp_mem_all.group_id%TYPE,
                                cp_v_balance_type           IN igs_fi_balance_rules.balance_name%TYPE,
                                cp_v_fee_cal_type           IN igs_fi_inv_int_all.fee_cal_type%TYPE,
                                cp_n_fee_ci_sequence_number IN igs_fi_inv_int_all.fee_ci_sequence_number%TYPE
                                ) IS
    SELECT  hd.person_id person_id,
            ln.uoo_id uoo_id,
            hd.course_cd,
            hd.invoice_creation_date invoice_creation_date,
            hd.fee_type,
            hd.fee_cal_type,
            hd.fee_ci_sequence_number,
            hd.invoice_id,
            hd.invoice_amount_due
      FROM  igs_fi_inv_int_all hd,
            igs_fi_invln_int_v ln
    WHERE hd.invoice_id = ln.invoice_id
    AND  hd.transaction_type = g_transaction_type
    AND  hd.person_id IN (SELECT person_id
                          FROM igs_pe_prsid_grp_mem
                          WHERE group_id = cp_n_person_id_grp
                          AND  ((end_date IS NULL) OR (TRUNC(end_date) >= TRUNC(SYSDATE))))
    AND  hd.invoice_amount_due > 0
    AND  hd.fee_cal_type = cp_v_fee_cal_type
    AND  hd.fee_ci_sequence_number = cp_n_fee_ci_sequence_number
    AND  ln.uoo_id IS NOT NULL
    AND  hd.course_cd IS NOT NULL
    AND  NOT EXISTS (SELECT 'X'
                     FROM igs_fi_inv_wav_det  wd
                     WHERE     wd.invoice_id = hd.invoice_id
                     AND       wd.balance_type = cp_v_balance_type
                     AND       (wd.end_dt is not null AND sysdate
                     BETWEEN   wd.start_dt and wd.end_dt))
    ORDER BY person_id,course_cd, uoo_id,invoice_creation_date;


  CURSOR cur_all_person_chrgs(cp_v_balance_type           IN igs_fi_balance_rules.balance_name%TYPE,
                              cp_v_fee_cal_type           IN Igs_fi_inv_int_all.fee_cal_type%TYPE,
                              cp_n_fee_ci_sequence_number IN Igs_fi_inv_int_all.fee_ci_sequence_number%TYPE
                             ) IS
    SELECT  hd.person_id person_id,
            ln.uoo_id uoo_id,
            hd.course_cd,
            hd.invoice_creation_date invoice_creation_date,
            hd.fee_type,
            hd.fee_cal_type,
            hd.fee_ci_sequence_number,
            hd.invoice_id,
            hd.invoice_amount_due
      FROM  igs_fi_inv_int_all hd,
            igs_fi_invln_int_v ln
    WHERE hd.invoice_id = ln.invoice_id
    AND  hd.transaction_type = g_transaction_type
    AND  hd.invoice_amount_due > 0
    AND  hd.fee_cal_type = cp_v_fee_cal_type
    AND  hd.fee_ci_sequence_number = cp_n_fee_ci_sequence_number
    AND  ln.uoo_id IS NOT NULL
    AND  hd.course_cd IS NOT NULL
    AND  NOT EXISTS (SELECT 'X'
                     FROM igs_fi_inv_wav_det  wd
                     WHERE     wd.invoice_id = hd.invoice_id
                     AND       wd.balance_type = cp_v_balance_type
                     AND       (wd.end_dt is not null AND sysdate
                     BETWEEN   wd.start_dt and wd.end_dt))
    ORDER BY person_id,course_cd, uoo_id,invoice_creation_date;

--Cursor to fetch the person details
  CURSOR cur_person(cp_person_id   IN igs_pe_person_base_v.person_id%TYPE) IS
    SELECT person_number,
           first_name || ' ' || last_name person_name
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_person_id;

   -- Enh # 2187247
   -- Modified the cursor for fetching the unit attempt status
   -- Cursor for fetching the Enrolment details
  CURSOR cur_enrl_dt(cp_person_id  IN igs_en_su_attempt.person_id%TYPE,
                     cp_course_cd  IN igs_en_su_attempt.course_cd%TYPE,
                     cp_uoo_id     IN igs_en_su_attempt.uoo_id%TYPE) IS
   SELECT  enrolled_dt,
           unit_cd,
           version_number,
           cal_type,
           ci_sequence_number,
           location_cd,
           unit_class,
           uoo_id,
           unit_attempt_status
    FROM   igs_en_su_attempt
    WHERE  person_id = cp_person_id
    AND    course_cd = cp_course_cd
    AND    uoo_id    = cp_uoo_id;

   -- Cursor to fetch the Course details
   -- Enh # 2187247
   -- Modified the cursor
   -- Removed the subquery as it was redundant
   CURSOR cur_course_version(p_person_id        IN igs_pe_person.person_id%TYPE,
                             p_course_cd        IN igs_fi_inv_int.course_cd%TYPE
                             ) IS
    SELECT ps.course_cd, ps.version_number
    FROM   igs_en_stdnt_ps_att ps
    WHERE  ps.person_id = p_person_id
           AND  ps.course_cd = p_course_cd;

   -- Bug 5123583, Created the Cursor to fetch Teaching calendar description
   CURSOR cur_get_cal_inst_desc(p_v_cal_type        IN igs_ca_inst_all.cal_type%TYPE,
                                p_n_sequence_number IN igs_ca_inst_all.sequence_number%TYPE
                               ) IS
    SELECT description
    FROM   igs_ca_inst_all ca
    WHERE  ca.cal_type = p_v_cal_type
           AND  ca.sequence_number = p_n_sequence_number;

  -- Declaration of local variables

  l_uoo_id                 igs_fi_invln_int.uoo_id%TYPE;
  l_person_id              igs_pe_person.person_id%TYPE;
  l_course_cd              igs_fi_inv_int.course_cd%TYPE;
  l_cnt                    NUMBER;
  l_str                    VARCHAR2(4000);
  l_message                VARCHAR2(2000);
  l_fee_cal_type           igs_fi_inv_int.fee_cal_type%TYPE;
  l_fee_ci_sequence_number igs_fi_inv_int.fee_ci_sequence_number%TYPE;
  l_ld_cal_type            igs_ca_inst.cal_type%TYPE;
  l_ld_ci_sequence_number  Igs_ca_inst.sequence_number%TYPE;
  l_person_number          igs_pe_person.person_number%TYPE;
  l_enrolled_dt            igs_en_su_attempt.enrolled_dt%TYPE;
  l_person_name            igs_pe_person.full_name%TYPE;
  l_balance_rule_id        igs_fi_balance_rules.balance_rule_id%TYPE;
  l_last_conversion_date   igs_fi_balance_rules.last_conversion_date%TYPE;
  l_version_number         igs_fi_balance_rules.version_number%TYPE;

  l_flag                   BOOLEAN := TRUE;
  l_enr_dtls               cur_enrl_dt%ROWTYPE;
  l_str_enrl               VARCHAR2(4000);

  l_v_manage_acc           igs_fi_control_all.manage_accounts%TYPE  := NULL;
  l_v_message_name         fnd_new_messages.message_name%TYPE       := NULL;

  l_n_act_plan_id          igs_fi_pp_std_attrs.student_plan_id%TYPE;
  l_v_act_plan_name        igs_fi_pp_std_attrs.payment_plan_name%TYPE;
  l_n_pp_person_id         igs_fi_parties_v.person_id%TYPE;
  e_skip_record            EXCEPTION;
  l_b_proceed              BOOLEAN;

  l_v_dcnt_reason_cd_desc  igs_en_dcnt_reasoncd_v.description%TYPE;

  --Bug 5123583, variable declared to fetch calendar description from cur_get_cal_inst_desc.
  l_v_cal_inst_desc igs_ca_inst_all.description%TYPE := NULL;


  TYPE tab_chrgs_rec IS TABLE OF cur_person_chrgs%ROWTYPE INDEX BY BINARY_INTEGER;
  v_tab_chrgs_rec    tab_chrgs_rec;
  rec_chrgs          cur_person_chrgs%ROWTYPE;

BEGIN

-- Set the Org Id
  igs_ge_gen_003.set_org_id(NULL);

  retcode:= 0;
-- logging input parameters
  fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')|| ': ');
  fnd_file.put_line(fnd_file.log,igs_fi_gen_008.get_party_number(p_person_id));

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP')|| ': ');
  fnd_file.put_line(fnd_file.log,igs_fi_gen_005.finp_get_prsid_grp_code(p_person_id_grp));

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_PERIOD')|| ': ');
  fnd_file.put_line(fnd_file.log,p_fee_period);

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','BALANCE_TYPE')|| ': ');
  fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning(g_lookup_type,p_balance_type));

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','DCNT_REASON_CD')|| ': ');
  OPEN  cur_dcnt_reason_cd(p_dcnt_reason_cd);
  FETCH cur_dcnt_reason_cd INTO l_v_dcnt_reason_cd_desc;
  CLOSE cur_dcnt_reason_cd;
  fnd_file.put_line(fnd_file.log,l_v_dcnt_reason_cd_desc);

  fnd_file.put(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TEST_MODE')|| ': ');
  fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_test_run));
-- end of logging the input parameters


  -- Obtain the value of manage_accounts in the System Options form
  -- If it is null or 'OTHER', then this process is not available, so error out.
  igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                               p_v_message_name => l_v_message_name
                                             );
  IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.new_line(fnd_file.log);
    retcode := 2;
    RETURN;
  END IF;

-- Create the savepoint for rollback
  SAVEPOINT s_disc_drop_units;

-- The person number and person name should be fetched for logging into
-- the log file of the concurrent manager.
  OPEN  cur_person(p_person_id);
  FETCH cur_person INTO l_person_number,l_person_name;
  CLOSE cur_person;

-- The fee period parameter should be split to extract the
-- Fee Calendar Type and Fee Calendar Instance
  IF p_fee_period IS NOT NULL THEN
    l_fee_cal_type           := RTRIM(SUBSTR(p_fee_period, 102, 10));
    l_fee_ci_sequence_number := TO_NUMBER(LTRIM(SUBSTR(p_fee_period, 113,8)));
  END IF;

  -- Enh # 2187247
  -- Invoke the function to derive the Load Calendar Intance
  -- related to the fee calendar instance.
  -- There can be only one such ACTIVE load calendar instance

  IF igs_fi_gen_001.finp_get_lfci_reln(
                                p_cal_type              => l_fee_cal_type,
                                p_ci_sequence_number    => l_fee_ci_sequence_number,
                                p_cal_category          => 'FEE',
                                p_ret_cal_type          => l_ld_cal_type,
                                p_ret_ci_sequence_number=> l_ld_ci_sequence_number,
                                p_message_name          => l_message
                                ) = FALSE THEN
    FND_MESSAGE.SET_NAME('IGS', l_message);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    retcode:=2;
    RETURN;
  END IF;

-- Call the procedure for validation of the input parameters
  IF NOT igs_fi_prc_disc_sua.validate_input_parameters(
                                                       p_person_id               => p_person_id,
                                                       p_person_id_grp           => p_person_id_grp,
                                                       p_fee_period              => p_fee_period,
                                                       p_fee_cal_type            => l_fee_cal_type,
                                                       p_fee_ci_sequence_number  => l_fee_ci_sequence_number,
                                                       p_balance_type            => p_balance_type,
                                                       p_dcnt_reason_cd          => p_dcnt_reason_cd,
                                                       p_test_run                => p_test_run)  THEN

-- If the validation procedure returns false, then raise the exception as some
-- of the validations have failed and have been logged in the log file of the
-- Concurrent Manager
    retcode:=2;
    RETURN;
  END IF;

-- Initialize the local variables
  l_uoo_id :=0;
  l_person_id := 0;
  l_course_cd := NULL;
  l_cnt := 0;
  l_balance_rule_id := 0;
  l_last_conversion_date := null;
  l_version_number := 0;

--Added as part of Enh Bug# 2562745. Get the balance_rule_id by calling finp_get_balance_rule and
--use the value in the call to check_exclusion_rules.

  IF p_balance_type IS NOT NULL THEN
    IF p_balance_type = 'HOLDS' THEN
        IGS_FI_GEN_007.FINP_GET_BALANCE_RULE ( p_v_balance_type => 'HOLDS',
                                               p_v_action => 'ACTIVE',
                                               p_n_balance_rule_id => l_balance_rule_id,
                                               p_d_last_conversion_date => l_last_conversion_date,
                                               p_n_version_number => l_version_number );
        IF l_version_number = 0 THEN
          fnd_file.new_line(fnd_file.log);
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_CANNOT_CRT_TXN');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          retcode:=2;
          RETURN;
        END IF;
    ELSIF p_balance_type = 'FEE' THEN
        IGS_FI_GEN_007.FINP_GET_BALANCE_RULE ( p_v_balance_type => 'FEE',
                                               p_v_action => 'MAX',
                                               p_n_balance_rule_id => l_balance_rule_id,
                                               p_d_last_conversion_date => l_last_conversion_date,
                                               p_n_version_number => l_version_number );
    END IF;
  END IF;

-- Displaying appropriate message in the log file based on the
-- Test Run Parameter
  IF p_test_run = g_yes_ind THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_WILL_DROP_UNITS');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  ELSE
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_HAVE_DROP_UNITS');
    fnd_file.put_line(fnd_file.log,fnd_message.get );
  END IF;

--Bug 5123583, Removed the logic to display header like person number, enrollement date etc. used in the log file.

-- Open person cursors to loop across the persons in context */

  IF p_person_id_grp IS NOT NULL AND p_person_id IS NULL THEN
     OPEN cur_person_group_chrgs(p_person_id_grp, p_balance_type, l_fee_cal_type, l_fee_ci_sequence_number);
     FETCH cur_person_group_chrgs BULK COLLECT INTO v_tab_chrgs_rec;
     CLOSE cur_person_group_chrgs;
  ELSIF p_person_id IS NOT NULL AND p_person_id_grp IS NULL THEN
     OPEN  cur_person_chrgs(p_person_id, p_balance_type, l_fee_cal_type, l_fee_ci_sequence_number);
     FETCH cur_person_chrgs BULK COLLECT INTO v_tab_chrgs_rec;
     CLOSE cur_person_chrgs;
  ELSE
     OPEN  cur_all_person_chrgs(p_balance_type, l_fee_cal_type, l_fee_ci_sequence_number);
     FETCH cur_all_person_chrgs BULK COLLECT INTO v_tab_chrgs_rec;
     CLOSE cur_all_person_chrgs;
  END IF;

  IF v_tab_chrgs_rec.COUNT > 0 THEN
     -- Loop across all charges identified
    FOR l_n_cntr IN v_tab_chrgs_rec.FIRST..v_tab_chrgs_rec.LAST
    LOOP
      IF v_tab_chrgs_rec.EXISTS(l_n_cntr) THEN
        rec_chrgs := v_tab_chrgs_rec(l_n_cntr);

        BEGIN

          --If the person being processed in not checked for active payment plan existence earlier...
          IF l_n_pp_person_id IS NULL OR rec_chrgs.person_id <> l_n_pp_person_id THEN

            l_b_proceed := TRUE;

            --Capture the person id in a local variable.
            l_n_pp_person_id := rec_chrgs.person_id;

            --Get the Student's Active Payment Plan Details.
            igs_fi_gen_008.get_plan_details(p_n_person_id     => rec_chrgs.person_id,
                                            p_n_act_plan_id   => l_n_act_plan_id,
                                            p_v_act_plan_name => l_v_act_plan_name
                                            );
            --If an active payment plan exists for the person being processed, skip the record and process for
            --the next person.
            IF l_n_act_plan_id IS NOT NULL THEN
              l_b_proceed := FALSE;
              OPEN cur_person(rec_chrgs.person_id);
              FETCH cur_person INTO l_person_number,l_person_name;
              CLOSE cur_person;
              --Bug 5123583, Removed the RPAD used earlier to display 6 spaces.
              l_str := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||l_person_number;
              RAISE e_skip_record;
            END IF;
          END IF;

          IF l_b_proceed THEN
            l_flag := TRUE;

      -- If the Person Id in the local variable is different from the Person Id of the
      -- charge record being processed, then reset the Course Code and the Uoo_Id variables
            IF l_person_id <> rec_chrgs.person_id THEN
              l_course_cd := NULL;
              l_uoo_id    := 0;
            END IF;

      -- Reset the Uoo_Id variable if the course code is null or the course code is different
      -- from the local variable value
            IF ((l_course_cd IS NULL) OR (l_course_cd <> rec_chrgs.course_cd)) THEN
              l_uoo_id := 0;
            END IF;

      -- If the Uoo_Id in the local variable is not the same for the Uoo_Id of the record
      -- then the further processing needs to be done
            IF (l_uoo_id <> rec_chrgs.uoo_id) THEN

          -- Enh #2187247
          -- Added a validation to process a UOO ID only if the UOO ID
          -- is of 'ENROLLED' or 'INVALID' status
              OPEN cur_enrl_dt(rec_chrgs.person_id,
                               rec_chrgs.course_cd,
                               rec_chrgs.uoo_id);
              FETCH cur_enrl_dt INTO l_enr_dtls;
              CLOSE cur_enrl_dt;

              IF l_enr_dtls.unit_attempt_status NOT IN ('ENROLLED','INVALID') THEN
                l_flag := FALSE;
              END IF;


      -- If the balance type passed is not null, then

              IF p_balance_type IS NOT NULL THEN
      -- Check if the balance rules for exclusion are applicable
      -- Added balance_rule_id parameter to the call as part of Enh Bug# 2562745
                IF igs_fi_prc_balances.check_exclusion_rules( p_balance_type => p_balance_type,
                                                              p_balance_date => rec_chrgs.invoice_creation_date,
                                                              p_source_type => g_exclude_type,
                                                              p_source_id => rec_chrgs.invoice_id,
                                                              p_message_name => l_message,
                                                              p_balance_rule_id => l_balance_rule_id ) THEN

      -- If the record is excluded, then set the Local flag variable to FALSE
                  l_flag := FALSE;
                END IF;
              END IF;

      -- If the flag is set to TRUE i.e. the record has not been excluded, then
      -- the process for dropping of the unit attempt has to be called.
              IF l_flag THEN
                l_uoo_id := rec_chrgs.uoo_id;


      -- Enh # 2187247 Uncommenting the call to the Enrolments API
      -- as a part of Build of SFCR021.
      -- The following code has been commented because the Load Calendar is not available
      -- After the SFCR021 is built, this code should be uncommented and the functionality for
      -- dropping the units should be tested for the dropping of the units
      -- The API which provides the Load Calendar based on the Fee Calendar is not put in the code
      -- as this will be available only after SFCR021 build

                IF p_test_run <> 'Y' THEN
                  FOR rec_cur_course_version IN cur_course_version(rec_chrgs.person_id,
                                                                   rec_chrgs.course_cd) LOOP

                  -- Enh # 2187247
                  -- Changed this call from positional notation to named notation
                  -- Added a new parameter p_admin_unit_status

                  -- Bug# 3037137, Replaced call to igs_ss_en_wrappers.drop_selected_units with igs_en_gen_004.enrp_dropall_unit
                  -- to avoid unnecessary validations carried out in drop_selected_units.
               -- Build # 3052438, Added parameter p_sub_unit to function call.
                    igs_en_gen_004.enrp_dropall_unit(
                      p_person_id => rec_chrgs.person_id,
                      p_cal_type => l_ld_cal_type,
                      p_ci_sequence_number => l_ld_ci_sequence_number,
                      p_dcnt_reason_cd => p_dcnt_reason_cd,
                      p_admin_unit_sta => NULL,
                      p_effective_date => SYSDATE,
                      p_program_cd => rec_cur_course_version.course_cd,
                      p_uoo_id => TO_CHAR(rec_chrgs.uoo_id),
                      p_sub_unit => 'N'
                );

                  END LOOP;
                END IF;

      -- Log the details of unit drop in the log file of the concurrent manager
              -- Enh # 2187247
              -- Changed the IF condition below from p_failed_uoo_ids to l_return_status
              -- Bug# 3037137. Removed check for l_return_status as it is no longer used.
                OPEN cur_person(rec_chrgs.person_id);
                FETCH cur_person INTO l_person_number,
                                      l_person_name;
                CLOSE cur_person;

      -- Prepare the string for logging of the details in the log file.
          --Bug# 5123583, Changed the separtor used to display unit details from '-' to '/'.
          --Fetching the teaching calendar instance description.
                OPEN cur_get_cal_inst_desc(l_enr_dtls.cal_type, l_enr_dtls.ci_sequence_number);
                FETCH cur_get_cal_inst_desc into l_v_cal_inst_desc;
                CLOSE cur_get_cal_inst_desc;

                l_str_enrl := l_enr_dtls.unit_cd||'/'||To_Char(l_enr_dtls.version_number)||'/'||
                              l_v_cal_inst_desc||'/'||
                              l_enr_dtls.location_cd||'/'||l_enr_dtls.unit_class;

                l_v_cal_inst_desc := NULL;

                l_cnt := l_cnt + 1;
                --Bug 5123583, Removed the code to display all data through l_str local variable.
                --Changed the tabular form of output to show records by person number.

                --Printing output in the log file.
                fnd_file.put_line(fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||l_person_number);

                fnd_message.set_name('IGS', 'IGS_FI_PERSON_NAME');
                fnd_file.put_line(fnd_file.log, fnd_message.get || ': ' || l_person_name);

                fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_TRIGGER_GROUP','COURSE')|| ': ' || rec_chrgs.course_cd);

                fnd_message.set_name('IGS', 'IGS_FI_UNIT_DTLS');
                fnd_file.put_line(fnd_file.log, fnd_message.get || ': ' || l_str_enrl);

                l_str_enrl := NULL;

                fnd_message.set_name('IGS', 'IGS_FI_ENR_DATE');
                fnd_file.put_line(fnd_file.log, fnd_message.get || ': ' || TRUNC(l_enr_dtls.enrolled_dt));

                --for separating one person details with the others
                fnd_file.new_line(fnd_file.log);
              END IF;
            END IF;
            l_person_id := rec_chrgs.person_id;
            l_course_cd := rec_chrgs.course_cd;
          END IF;

        EXCEPTION
        WHEN e_skip_record THEN
          fnd_message.set_name('IGS','IGS_FI_PP_NO_UNIT_DROP');
          fnd_file.new_line(fnd_file.log);
          fnd_file.put_line(fnd_file.log,l_str||' - '||fnd_message.get);
          fnd_file.new_line(fnd_file.log);
        END;
      END IF; -- end of condition v_tab_chrgs_rec.EXISTS(l_n_cntr)
    END LOOP;
  END IF;

-- If there were no units identified for dropping, then log the appropriate message in the
-- log file of the concurrent manager.
  IF l_cnt = 0 THEN
    fnd_file.new_line(fnd_file.log);
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_NO_DROP_UNITS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- If the test run flag is not Y, then the transactions need to be committed else
-- rollback to the savepoint
  IF p_test_run <> g_yes_ind THEN
    COMMIT;
  ELSE
    ROLLBACK TO s_disc_drop_units;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO s_disc_drop_units;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END drop_disc_sua_non_payment;
END igs_fi_prc_disc_sua;

/
