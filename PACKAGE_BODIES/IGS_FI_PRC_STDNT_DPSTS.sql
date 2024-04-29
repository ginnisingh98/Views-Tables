--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_STDNT_DPSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_STDNT_DPSTS" AS
/* $Header: IGSFI77B.pls 120.1 2006/02/10 01:29:05 sapanigr noship $ */

/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 05-DEC-2002
Purpose           : This package contains the specification for the
                    Process Deposits concurrent request. This process
                    has an out come of either Transferring the Deposit
                    to the Student Account as a Payment or Forfeit the
                    Deposit or take no action on the Deposit transaction.
Known limitations,
enhancements,
remarks            :
Change History
Who      When          What
sapanigr 12-Feb-2006   Bug#5018036 - Modified  cursor c_person in validate_person procedure. (for R12 SQL Repository tuning)
pathipat 24-Apr-2003   Enh 2831569 - Commercial Receivables build
                       Modified prc_stdnt_deposit() - added call to chk_manage_account()
vvutukur 10-Apr-2003   Enh#2831554.Internal Credits API Build. Modified procedures generate_log,prc_stdnt_deposit.
vchappid 29-Jan-2003   Bug# 2729927,In procedure generate_log,log file should log Deposit Number, Amount details
                       only when they have a value
vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                       input parameter is an invalid value
                       Bug# 2729984, Incase when the program attempt status is in other than enrolled status
                       incorrect token is being logged. Corrected the token
                       While Selecting Person Group member, start date and end date are checked.
                       Additional issue: Local variables l_c_message_name, l_c_outcome have to be re-initialized
                       before start of each Enrollment Credit
vchappid 09-Jan-2003   Bug# 2730010, when a student has program attempt as Enrolled and no action is being
                       taken on the Deposit then different message is logged in the log file.
vchappid 06-Jan-2003   Bug# 2729948, message name changed from IGS_FI_PRS_OR_PRSIDGRP to IGS_FI_PRS_PRSIDGRP_NULL
                       whenever user don't provide either person id or person id group as parameter to the request
                       Additionally, Person Group Id parameter is being validated twice.
                       Removed duplicate Person Group ID validation.
******************************************************************/

  g_c_yes                CONSTANT VARCHAR2(1)  := 'Y';
  g_c_no                 CONSTANT VARCHAR2(1)  := 'N';
  g_c_hold               CONSTANT VARCHAR2(4) := 'HOLD';
  g_c_transfer           CONSTANT igs_lookup_values.lookup_code%TYPE := 'TRANSFER';
  g_c_forfeit            CONSTANT igs_lookup_values.lookup_code%TYPE := 'FORFEIT';
  g_c_enrdeposit         CONSTANT igs_lookup_values.lookup_code%TYPE := 'ENRDEPOSIT';
  g_c_othdeposit         CONSTANT igs_lookup_values.lookup_code%TYPE := 'OTHDEPOSIT';
  g_c_sca_enrolled       CONSTANT igs_en_stdnt_ps_att.course_attempt_status%TYPE := 'ENROLLED';
  g_c_sca_other          CONSTANT igs_en_stdnt_ps_att.course_attempt_status%TYPE := 'OTHER';
  g_c_appl_dep_lvl       CONSTANT igs_lookup_values.lookup_code%TYPE := 'APPL';
  g_c_all_dep_lvl        CONSTANT igs_lookup_values.lookup_code%TYPE := 'ALL';
  g_c_prg_dep_lvl        CONSTANT igs_lookup_values.lookup_code%TYPE := 'PROGRAM';
  g_c_prgty_dep_lvl      CONSTANT igs_lookup_values.lookup_code%TYPE := 'PROGRAM_TYPE';
  g_null                 CONSTANT VARCHAR2(1):= NULL;
  g_credit_type_id       igs_fi_cr_types_all.credit_type_id%TYPE;

  do_nothing  EXCEPTION;

  -- Pl/SQL table for storing all Student Program Attempts
  TYPE stdnt_sca_tab IS TABLE OF igs_ps_ver.course_cd%TYPE
    INDEX BY BINARY_INTEGER;

  -- Pl/SQL table for storing all Student Program Attempts Version Numbers
  TYPE stdnt_sca_ver_num_tab IS TABLE OF igs_ps_ver.version_number%TYPE
    INDEX BY BINARY_INTEGER;

  -- Pl/SQL table for storing all Student Program Attempts Program Types
  TYPE stdnt_sca_typ_tab IS TABLE OF igs_ps_ver.course_type%TYPE
    INDEX BY BINARY_INTEGER;

  -- Pl/SQL table for storing all Student Program Attempts Statuses
  TYPE stdnt_sca_status_tab IS TABLE OF igs_en_stdnt_ps_att.course_attempt_status%TYPE
    INDEX BY BINARY_INTEGER;


  TYPE rec_input_param IS RECORD ( credit_class          igs_fi_cr_types.credit_class%TYPE,
                                   credit_type_id        igs_fi_cr_types.credit_type_id%TYPE,
                                   load_cal_type         igs_ca_inst.cal_type%TYPE,
                                   load_cal_seq_num      igs_ca_inst.sequence_number%TYPE,
                                   fee_cal_type          igs_ca_inst.cal_type%TYPE,
                                   fee_cal_seq_num       igs_ca_inst.sequence_number%TYPE,
                                   gl_date               DATE,
                                   test_mode             VARCHAR2(1));

  FUNCTION check_acad_load_adm_rel(p_c_load_cal_type         VARCHAR2,
                                   p_n_load_ci_seq_num       NUMBER,
                                   p_c_acad_cal_type         VARCHAR2,
                                   p_n_acad_ci_seq_num       NUMBER,
                                   p_c_adm_cal_type          VARCHAR2,
                                   p_n_adm_ci_seq_num        NUMBER)
  RETURN VARCHAR2 AS
/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 05-DEC-2002
Purpose           : Checks if the relation Exists between Acad, Load and Admission
Known limitations,
enhancements,
remarks            :
Change History
Who      When          What
******************************************************************/


    CURSOR c_check_rel(cp_c_load_cal_type igs_ca_inst.cal_type%TYPE,cp_n_load_ci_seq_num igs_ca_inst.sequence_number%TYPE,
                       cp_c_acad_cal_type igs_ca_inst.cal_type%TYPE,cp_n_acad_ci_seq_num igs_ca_inst.sequence_number%TYPE,
                       cp_c_adm_cal_type  igs_ca_inst.cal_type%TYPE,cp_n_adm_ci_seq_num igs_ca_inst.sequence_number%TYPE)
    IS
    SELECT 'X'
    FROM igs_ca_inst_rel r1
    WHERE r1.sub_cal_type = cp_c_load_cal_type AND
          r1.sub_ci_sequence_number = cp_n_load_ci_seq_num AND
          r1.sup_cal_type = cp_c_acad_cal_type AND
          r1.sup_ci_sequence_number = cp_n_acad_ci_seq_num AND
    EXISTS (SELECT 'X'
            FROM igs_ca_inst_rel r2
            WHERE r2.sup_cal_type = r1.sup_cal_type AND
            r2.sup_ci_sequence_number = r1.sup_ci_sequence_number  AND
            r2.sub_cal_type = cp_c_adm_cal_type AND
            r2.sub_ci_sequence_number = cp_n_adm_ci_seq_num);
    l_c_temp VARCHAR2(1);

  BEGIN

    OPEN c_check_rel(p_c_load_cal_type,
                     p_n_load_ci_seq_num,
                     p_c_acad_cal_type,
                     p_n_acad_ci_seq_num,
                     p_c_adm_cal_type,
                     p_n_adm_ci_seq_num);
    FETCH c_check_rel INTO l_c_temp;
    CLOSE c_check_rel;

    IF l_c_temp IS NOT NULL THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  END check_acad_load_adm_rel;


  PROCEDURE check_enrollment(p_n_person_id igs_fi_parties_v.person_id%TYPE,
                             p_tab_course_cd stdnt_sca_tab,
                             p_tab_ver_num stdnt_sca_ver_num_tab,
                             p_tab_sca_typ stdnt_sca_typ_tab,
                             p_rec_input_param rec_input_param,
                             p_c_sca_status igs_en_stdnt_ps_att.course_attempt_status%TYPE,
                             p_c_dep_lvl VARCHAR2,
                             p_c_action OUT NOCOPY igs_lookup_values.lookup_code%TYPE,
                             p_c_sca_att_status OUT NOCOPY igs_lookup_values.lookup_code%TYPE)
  AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Checks if student has Enrollment in a set of programs
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  ******************************************************************/


    CURSOR c_sca_status (cp_n_person_id igs_fi_parties_v.person_id%TYPE,
                         cp_c_load_cal_type igs_ca_inst.cal_type%TYPE,
                         cp_n_load_cal_seq_num igs_ca_inst.sequence_number%TYPE,
                         cp_c_sca_status VARCHAR2)
    IS
    SELECT spa.course_cd course_cd,
           spa.version_number version_number,
           ps.course_type course_type,
           spa.course_attempt_status course_attempt_status
    FROM   igs_en_stdnt_ps_att  spa,
           igs_ps_ver ps
    WHERE  spa.course_cd = ps.course_cd AND
           spa.version_number = ps.version_number AND
           spa.person_id = cp_n_person_id AND
           (
            (cp_c_sca_status= g_c_sca_enrolled AND spa.course_attempt_status = 'ENROLLED')
             OR
            (
             cp_c_sca_status = g_c_sca_other
             AND
             spa.course_attempt_status IN ('COMPLETED','INTERMIT','INACTIVE','UNCONFIRM','ENROLLED')
            )
           )
            AND
           (
             (spa.course_attempt_status ='ENROLLED' AND
              EXISTS
              (
               SELECT 'X'
               FROM igs_en_su_attempt  sua,
               igs_ca_load_to_teach_v  lci
               WHERE sua.person_id = spa.person_id AND
               sua.course_cd = spa.course_cd AND
               sua.cal_type = lci.teach_cal_type AND
               sua.ci_sequence_number = lci.teach_ci_sequence_number AND
               (lci.load_cal_type = cp_c_load_cal_type  AND
                lci.load_ci_sequence_number = cp_n_load_cal_seq_num) AND
               (
                (cp_c_sca_status= g_c_sca_enrolled AND sua.unit_attempt_status = 'ENROLLED')
                 OR
                (cp_c_sca_status = g_c_sca_other
                 AND
                 sua.unit_attempt_status IN ('UNCONFIRM','WAITLISTED','COMPLETED')
                )
               )
              )
            OR
             (spa.course_attempt_status IN ('COMPLETED','INTERMIT','INACTIVE','UNCONFIRM') AND cp_c_sca_status = g_c_sca_other)
            )
          );

    -- pl/sql table structure for storing course codes in which the student has program attempts
    l_tab_std_sca_attmpts stdnt_sca_tab;

    -- pl/sql table structure for storing version number of the corresponding course code
    -- in which the student has program attempts
    l_tab_std_sca_ver_num stdnt_sca_ver_num_tab;

    -- pl/sql table structure for storing program types of the courses in which the student has program attempts
    l_tab_std_sca_typ stdnt_sca_typ_tab;

    -- pl/sql table structure for storing program status of the courses in which the student has program attempts
    l_tab_std_sca_stat_typ stdnt_sca_status_tab;

    -- this flag is used if the program attempt match with the one that is found from the above cursor
    l_b_found BOOLEAN := FALSE;
    l_c_course_attempt_status igs_lookup_values.lookup_code%TYPE;

  BEGIN
    -- For the person incontext and for the load calendar instance as selected by the user
    -- select all program attempts the student has attempted and with the course attempt status decided
    -- cursor parameter cp_c_sca_status
    OPEN c_sca_status (p_n_person_id,
                       p_rec_input_param.load_cal_type,
                       p_rec_input_param.load_cal_seq_num,
                       p_c_sca_status);
    FETCH c_sca_status BULK COLLECT INTO l_tab_std_sca_attmpts,l_tab_std_sca_ver_num,l_tab_std_sca_typ,l_tab_std_sca_stat_typ;
    CLOSE c_sca_status;

    -- If the deposit level is passed APPL, PROGRAM, ALL then the course codes have to be matched
    -- else i.e. incase of Deposit Level is Program Type then the course types should be matched
    -- When matching course codes both course code and version number should be matched
    -- When a matching record is found, flag l_b_found will be set to TRUE
    IF p_c_dep_lvl IN (g_c_appl_dep_lvl,g_c_all_dep_lvl,g_c_prg_dep_lvl) THEN

      IF (l_tab_std_sca_attmpts.COUNT <> 0 AND p_tab_course_cd.COUNT <>0) THEN

        FOR i IN l_tab_std_sca_attmpts.FIRST .. l_tab_std_sca_attmpts.LAST
        LOOP
        EXIT WHEN l_b_found;
          FOR j IN p_tab_course_cd.FIRST .. p_tab_course_cd.LAST
          LOOP
          EXIT WHEN l_b_found;
            IF ((p_tab_course_cd(j) = l_tab_std_sca_attmpts(i)) AND (p_tab_ver_num(j) = l_tab_std_sca_ver_num(i) )) THEN
              l_b_found := TRUE;
              l_c_course_attempt_status := l_tab_std_sca_stat_typ(i);
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    ELSIF p_c_dep_lvl = g_c_prgty_dep_lvl THEN
      IF (l_tab_std_sca_typ.COUNT <> 0 AND p_tab_sca_typ.COUNT<> 0 ) THEN
        FOR i IN l_tab_std_sca_typ.FIRST .. l_tab_std_sca_typ.LAST
        LOOP
        EXIT WHEN l_b_found;
          FOR j IN p_tab_sca_typ.FIRST .. p_tab_sca_typ.LAST
          LOOP
          EXIT WHEN l_b_found;
            IF (p_tab_sca_typ(j) = l_tab_std_sca_typ(i)) THEN
              l_b_found := TRUE;
              l_c_course_attempt_status := l_tab_std_sca_stat_typ(i);
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;

    -- When the student is found to have Enrolled program attempts then the action indicator is set to 'Transfer'
    -- and no further processing should be done
    -- Incase where the student has program attempts in any other status then no action should be taken
    -- Set the flag to 'Hold'
    IF l_b_found THEN
      IF p_c_sca_status = g_c_sca_enrolled THEN
        p_c_action := g_c_transfer;
        p_c_sca_att_status := NULL;
      ELSE
        p_c_action := g_c_hold;
        p_c_sca_att_status := l_c_course_attempt_status;
      END IF;
    ELSE
      p_c_action := NULL;
      p_c_sca_att_status := NULL;
    END IF;
  END check_enrollment;

  PROCEDURE generate_log(p_n_person_id igs_fi_parties_v.person_id%TYPE,
                         p_c_credit_number igs_fi_credits.credit_number%TYPE,
                         p_n_amount igs_fi_credits.amount%TYPE,
                         p_c_action VARCHAR2,
                         p_c_payment_cr_num igs_fi_credits.credit_number%TYPE,
                         p_c_message_name fnd_new_messages.message_name%TYPE,
                         p_c_sca_att_status igs_lookup_values.lookup_code%TYPE) AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Log Messages
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vvutukur 10-Apr-2003   Enh#2831554.Internal Credits API Build. Added code to set the tokens when payment credit type is invalid.
  vchappid 29-Jan-2003   Bug# 2729927, log file should log Deposit Number, Amount details only when they have a value
  vchappid 09-Jan-2003   Bug# 2729984, Incase when the program attempt status is in other than enrolled status
                         incorrect token is being logged. Corrected the token
  ******************************************************************/


    CURSOR c_person(cp_n_person_id igs_fi_parties_v.person_id%TYPE)
    IS
    SELECT person_number, full_name
    FROM igs_fi_parties_v
    WHERE person_id = cp_n_person_id;

    CURSOR cur_cr_type_names(cp_credit_type_id igs_fi_cr_types_all.credit_type_id%TYPE) IS
      SELECT credit_type_name,payment_credit_type_name
      FROM   igs_fi_cr_types_v
      WHERE  credit_type_id = cp_credit_type_id;

    rec_cur_cr_type_names  cur_cr_type_names%ROWTYPE;

    l_c_person c_person%ROWTYPE;
    l_c_message_text fnd_new_messages.message_text%TYPE;

  BEGIN

    OPEN c_person(p_n_person_id);
    FETCH c_person INTO l_c_person;
    CLOSE c_person;

    IF p_c_message_name IS NOT NULL THEN
      IF p_c_message_name = 'IGS_FI_DP_SPA_NO_ACTION' THEN
        fnd_message.set_name('IGS',p_c_message_name);
        fnd_message.set_token('SPA_STAT',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',p_c_sca_att_status));

      ELSIF p_c_message_name = 'IGS_FI_PCT_DCT_INVALID' THEN
          OPEN cur_cr_type_names(g_credit_type_id);
          FETCH cur_cr_type_names INTO rec_cur_cr_type_names;
          CLOSE cur_cr_type_names;
          fnd_message.set_name('IGS',p_c_message_name);
          fnd_message.set_token('PAY_CR_TYPE',rec_cur_cr_type_names.payment_credit_type_name);
          fnd_message.set_token('DEP_CR_TYPE',rec_cur_cr_type_names.credit_type_name);
      ELSE
        fnd_message.set_name('IGS',p_c_message_name);
      END IF;
      l_c_message_text:= fnd_message.get;
    END IF;

    -- Person Number and Deposit Action should be logged each and everytime.
    -- Deposit Number, Amount and Payment Receipt Number should be printed only when they have a value
    fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
    fnd_message.set_token('PERSON_NUM',l_c_person.person_number||' '||l_c_person.full_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF p_c_credit_number IS NOT NULL THEN
      fnd_message.set_name('IGS','IGS_FI_DEP_REC_NUM');
      fnd_message.set_token('DEP_REC_NUM',p_c_credit_number);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    IF p_n_amount IS NOT NULL THEN
      fnd_message.set_name('IGS','IGS_FI_DEP_AMOUNT');
      fnd_message.set_token('DEP_AMNT',p_n_amount);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    fnd_message.set_name('IGS','IGS_FI_DEP_ACTION');
    fnd_message.set_token('DEP_ACTION',l_c_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF p_c_payment_cr_num IS NOT NULL THEN
      fnd_message.set_name('IGS','IGS_FI_PAYMENT_REC_NUM');
      fnd_message.set_token('PAYMNT_NUM',p_c_payment_cr_num);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    -- Put a line to seperate from the previous log details
    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
    fnd_file.new_line(fnd_file.log);

  END generate_log;

  FUNCTION validate_credit_type(p_c_credit_type_id igs_fi_cr_types.credit_type_id%TYPE,
                                p_c_credit_class igs_fi_cr_types.credit_class%TYPE) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Validates Credit Type
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/
    CURSOR c_credit_type(cp_credit_type_id IN igs_fi_cr_types.credit_type_id%TYPE)
    IS
    SELECT credit_type_name
    FROM igs_fi_cr_types
    WHERE credit_type_id = cp_credit_type_id AND
          credit_class = p_c_credit_class;

    l_b_return_val BOOLEAN := FALSE;
    l_c_credit_type c_credit_type%ROWTYPE;
    l_v_message_text fnd_new_messages.message_text%TYPE;
  BEGIN
    OPEN c_credit_type(p_c_credit_type_id);
    FETCH c_credit_type INTO l_c_credit_type;
    IF c_credit_type%NOTFOUND THEN
      l_b_return_val := FALSE;
    ELSE
      l_v_message_text := l_c_credit_type.credit_type_name;
      l_b_return_val := TRUE;
    END IF;
    CLOSE c_credit_type;

    fnd_message.set_name('IGS','IGS_FI_CREDIT_TYPE');
    fnd_message.set_token('CREDIT_TYPE',l_v_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF NOT l_b_return_val THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_N_CREDIT_TYPE_ID');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    RETURN l_b_return_val;
  END validate_credit_type;

  FUNCTION validate_credit_class(p_c_credit_class IN VARCHAR2) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates Credit Class
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    l_v_message_text fnd_new_messages.message_text%TYPE;
    l_b_return_val BOOLEAN;
  BEGIN
    IF p_c_credit_class NOT IN (g_c_enrdeposit, g_c_othdeposit) THEN
      l_b_return_val := FALSE;
    ELSE
      l_b_return_val := TRUE;
    END IF;

    fnd_message.set_name('IGS','IGS_FI_CREDIT_CLASS');
    fnd_message.set_token('CREDIT_CLASS',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CLASS',p_c_credit_class));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF NOT l_b_return_val THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_C_CREDIT_CLASS');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    RETURN l_b_return_val;
  END validate_credit_class;


  FUNCTION validate_person(p_n_person_id igs_pe_person.person_id%TYPE) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates Person
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  sapanigr 12-Feb-2006   Bug#5018036 - Cursor c_person now queries hz_parties instead of
                         igs_fi_parties_v. (R12 SQL Repository tuning)
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    CURSOR c_person (cp_n_person_id hz_parties.party_id%TYPE)
    IS
    SELECT party_number
    FROM hz_parties
    WHERE party_id = cp_n_person_id;

    l_c_person_number hz_parties.party_number%TYPE;
    l_v_message_text fnd_new_messages.message_text%TYPE;
    l_b_return_val BOOLEAN;

  BEGIN
    OPEN c_person(p_n_person_id);
    FETCH c_person INTO l_c_person_number;
    IF c_person%NOTFOUND THEN
      l_b_return_val := FALSE;
    ELSE
      l_v_message_text := l_c_person_number;
      l_b_return_val := TRUE;
    END IF;
    CLOSE c_person;

    fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
    fnd_message.set_token('PERSON_NUM',l_v_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF NOT l_b_return_val THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_N_PERSON_ID');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    RETURN l_b_return_val;
  END validate_person;

  FUNCTION validate_person_grp(p_n_person_id_grp igs_pe_persid_group.group_id%TYPE) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates Person Id Group
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    CURSOR c_check_prsn_grp
    IS
    SELECT group_cd
    FROM igs_pe_persid_group
    WHERE group_id= p_n_person_id_grp AND
          TRUNC(create_dt)<= TRUNC(SYSDATE) AND
          closed_ind = 'N';
    l_c_group_cd igs_pe_persid_group.group_cd%TYPE;

    l_b_return_val BOOLEAN;
    l_v_message_text fnd_new_messages.message_text%TYPE;

  BEGIN
    OPEN c_check_prsn_grp;
    FETCH c_check_prsn_grp INTO l_c_group_cd;
    IF c_check_prsn_grp%NOTFOUND THEN
      l_b_return_val := FALSE;
    ELSE
      l_v_message_text := l_c_group_cd;
      l_b_return_val := TRUE;
    END IF;
    CLOSE c_check_prsn_grp;

    fnd_message.set_name('IGS','IGS_FI_PERSON_GROUP');
    fnd_message.set_token('PERSON_GRP',l_v_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF NOT l_b_return_val THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_N_PERSON_ID_GRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;
    RETURN l_b_return_val;
  END validate_person_grp;

  FUNCTION validate_term_cal_inst(p_c_load_cal_type IN igs_ca_inst.cal_type%TYPE,
                                  p_n_load_seq_number igs_ca_inst.sequence_number%TYPE) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates term calendar
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    CURSOR c_cal_inst (cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                       cp_n_seq_num igs_ca_inst.sequence_number%TYPE)
    IS
    SELECT t.cal_type, t.start_dt, t.end_dt
    FROM igs_ca_inst t, igs_ca_type ty
    WHERE t.cal_type = ty.cal_type
    AND   ty.s_cal_cat='LOAD'
    AND   t.cal_type = cp_c_cal_type
    AND   t.sequence_number =  cp_n_seq_num;

    l_rec_c_cal_inst c_cal_inst%ROWTYPE;

    l_b_ret_status BOOLEAN;
    l_c_message_text fnd_new_messages.message_text%TYPE;

  BEGIN

    IF (p_c_load_cal_type IS NULL OR p_n_load_seq_number IS NULL ) THEN
        l_b_ret_status := FALSE;
    ELSE
      OPEN c_cal_inst(p_c_load_cal_type, p_n_load_seq_number);
      FETCH c_cal_inst INTO l_rec_c_cal_inst;
      IF c_cal_inst%NOTFOUND THEN
        l_b_ret_status := FALSE;
      ELSE
        l_c_message_text := l_rec_c_cal_inst.cal_type||' - '||l_rec_c_cal_inst.start_dt||' - '|| l_rec_c_cal_inst.end_dt;
        l_b_ret_status := TRUE;
      END IF;
      CLOSE c_cal_inst;
    END IF;

    fnd_message.set_name('IGS','IGS_FI_TERM');
    fnd_message.set_token('TERM',l_c_message_text);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    IF NOT l_b_ret_status THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_C_TERM_CAL_INST');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    RETURN l_b_ret_status;
  END validate_term_cal_inst;


  PROCEDURE validate_gl_date(p_d_gl_date IN DATE,
                             p_b_ret_status OUT NOCOPY BOOLEAN,
                             p_c_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE) AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates GL Date
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    l_v_closing_status igs_fi_gl_periods_v.closing_status%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;
    l_v_message_text fnd_new_messages.message_text%TYPE;
    l_b_ret_status BOOLEAN := TRUE;
  BEGIN
    --Validate the GL Date.
    igs_fi_gen_gl.get_period_status_for_date(p_d_date            => p_d_gl_date,
                                             p_v_closing_status  => l_v_closing_status,
                                             p_v_message_name    => l_v_message_name
                                             );
    IF l_v_message_name IS NOT NULL THEN
      l_v_message_text := p_d_gl_date;
      p_c_message_name:= l_v_message_name;
      p_b_ret_status := FALSE;
    ELSE
      IF l_v_closing_status NOT IN ('O','F') THEN
        l_v_message_text := p_d_gl_date;
        p_c_message_name := 'IGS_FI_INVALID_GL_DATE';
        p_b_ret_status := FALSE;
      ELSE
        l_v_message_text := p_d_gl_date;
        p_c_message_name := NULL;
        p_b_ret_status := TRUE;
      END IF;
    END IF;
    -- when no errors are encountered then return TRUE
    fnd_message.set_name('IGS','IGS_FI_GL_DATE');
    fnd_message.set_token('GL_DATE',l_v_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  END validate_gl_date;

  FUNCTION validate_test_mode(p_c_test_mode VARCHAR2) RETURN BOOLEAN AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates test mode
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 09-Jan-2003   Bug# 2729935, Invalid Value token is removed from all parameters when the
                         input parameter is an invalid value
  ******************************************************************/

    l_b_return_val BOOLEAN;
    l_v_message_text fnd_new_messages.message_text%TYPE;
  BEGIN
    IF p_c_test_mode NOT IN (g_c_yes,g_c_no) THEN
      l_b_return_val := FALSE;
    ELSE
      l_v_message_text := igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_c_test_mode);
      l_b_return_val := TRUE;
    END IF;

    fnd_message.set_name('IGS','IGS_FI_TEST_MODE');
    fnd_message.set_token('TEST_MODE',l_v_message_text);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF NOT l_b_return_val THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER','P_C_TEST_MODE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;
    RETURN l_b_return_val;
  END validate_test_mode;


  PROCEDURE validate_log_parameters(p_rec_input_param  rec_input_param,
                                    p_n_person_id      igs_fi_parties_v.person_id%TYPE,
                                    p_n_person_id_grp  NUMBER,
                                    p_b_ret_status OUT NOCOPY BOOLEAN) AS

  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : validates Input Parameters and Logs in the Log file
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vchappid 06-Jan-03     Bug# 2729948, message name changed from IGS_FI_PRS_OR_PRSIDGRP to IGS_FI_PRS_PRSIDGRP_NULL
                         whenever user don't provide either person id or person id group as parameter to the request
                         Additionally, Person Group Id parameter is being validated twice.
                         Removed duplicate Person Group ID validation.
  ******************************************************************/

    l_b_ret_status BOOLEAN := TRUE;
    l_b_temp BOOLEAN := TRUE;
    l_c_message_name fnd_new_messages.message_name%TYPE;

  BEGIN

    fnd_message.set_name('IGS','IGS_FI_PROCESS_PARAM');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
    fnd_file.new_line(fnd_file.log);

    -- Check if the Credit Class that is provided is a valid Credit Class
    IF NOT validate_credit_class(p_rec_input_param.credit_class) THEN
      l_b_temp := FALSE;
    END IF;

    -- Check if the Person Id Group provided is a valid value
    IF (p_n_person_id_grp IS NOT NULL) THEN
      IF NOT validate_person_grp(p_n_person_id_grp) THEN
        l_b_temp := FALSE;
      END IF;
    END IF;

    -- Check if the Person Id provided is a valid value
    IF (p_n_person_id IS NOT NULL) THEN
      IF NOT validate_person(p_n_person_id) THEN
        l_b_temp := FALSE;
      END IF;
    END IF;

    -- Check if the Credit Class that is provided is a valid Credit Class
    IF p_rec_input_param.credit_type_id IS NOT NULL THEN
      IF NOT validate_credit_type(p_rec_input_param.credit_type_id, p_rec_input_param.credit_class) THEN
        l_b_temp := FALSE;
      END IF;
    END IF;

    -- Check if the Term Calendar is a valid value
    IF (p_rec_input_param.load_cal_type IS NOT NULL AND p_rec_input_param.load_cal_seq_num IS NOT NULL) THEN
      IF NOT validate_term_cal_inst( p_c_load_cal_type => p_rec_input_param.load_cal_type,
                                     p_n_load_seq_number => p_rec_input_param.load_cal_seq_num) THEN
        l_b_temp := FALSE;
      END IF;
    END IF;

    -- Check if the GL Date passed is a valid date in the Open or Future periods
    -- Rec Installed will be checked in the generic procedure so need to check here
    validate_gl_date(p_d_gl_date => p_rec_input_param.gl_date,
                     p_b_ret_status => l_b_ret_status,
                     p_c_message_name => l_c_message_name
                    );

    -- Should handle the message
    IF NOT l_b_ret_status THEN
      l_b_temp := FALSE;
    END IF;

    -- Check if the Test Mode parameter passed is a valid value
    IF NOT validate_test_mode(p_rec_input_param.test_mode) THEN
        l_b_temp := FALSE;
    END IF;

    IF NOT l_b_temp THEN
      p_b_ret_status := FALSE;
      IF l_c_message_name IS NOT NULL THEN
        IF l_c_message_name = 'IGS_FI_INVALID_GL_DATE' THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
          fnd_message.set_token('GL_DATE',p_rec_input_param.gl_date);
        ELSE
          fnd_message.set_name('IGS',l_c_message_name);
        END IF;
      END IF;
    END IF;

    fnd_file.new_line(fnd_file.log);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
    fnd_file.new_line(fnd_file.log);

    -- Check if the mandatory parameters are provided abort the process they are not provided
    IF (p_rec_input_param.credit_class IS NULL OR p_rec_input_param.test_mode IS NULL OR p_rec_input_param.gl_date IS NULL) THEN
      fnd_message.set_name('IGS','IGS_UC_NO_MANDATORY_PARAMS');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_ret_status := FALSE;
    END IF;

    -- Either Person Id or Person Id Group has to be provided both cannot be provided
    IF (p_n_person_id IS NOT NULL AND p_n_person_id_grp IS NOT NULL) THEN
      fnd_message.set_name('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_ret_status := FALSE;
    END IF;

    -- Either Person Id or Person Id Group has to be provided both cannot be null
    IF (p_n_person_id IS NULL AND p_n_person_id_grp IS NULL) THEN
      fnd_message.set_name('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_ret_status := FALSE;
    END IF;

    -- If the Credit Class provided is ENRDEPOSIT then the term calendar should be mandatory.
    IF (p_rec_input_param.credit_class = g_c_enrdeposit AND
        (
         (p_rec_input_param.load_cal_type IS NULL
          OR
          p_rec_input_param.load_cal_seq_num IS NULL
         )
        )) THEN
      fnd_message.set_name('IGS','IGS_FI_DP_TERM_REQD');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_ret_status := FALSE;
    END IF;
  END validate_log_parameters;

  PROCEDURE take_action(p_n_credit_id igs_fi_credits_all.credit_id%TYPE,
                        p_d_gl_date DATE,
                        p_c_action igs_lookup_values.lookup_code%TYPE,
                        p_c_credit_number OUT NOCOPY igs_fi_credits.credit_number%TYPE,
                        p_c_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE)
  AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Procedure to transfer or forfeit a deposit
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  ******************************************************************/

    l_b_ret_status BOOLEAN;
    l_c_message_name fnd_new_messages.message_name%TYPE;
    l_c_receipt_number igs_fi_credits.credit_number%TYPE;
  BEGIN
    IF p_c_action = g_c_transfer THEN
      BEGIN
        SAVEPOINT s_before_action;
        igs_fi_deposits_prcss.transfer_deposit(p_n_credit_id=> p_n_credit_id,
                                               p_d_gl_date => TRUNC(p_d_gl_date),
                                               p_b_return_status => l_b_ret_status,
                                               p_c_message_name => l_c_message_name,
                                               p_c_receipt_number => l_c_receipt_number
                                               );
        IF NOT l_b_ret_status THEN
          p_c_credit_number := NULL;
          p_c_message_name := l_c_message_name;
        ELSE
          p_c_credit_number :=l_c_receipt_number;
          p_c_message_name := NULL;
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO s_before_action;
      END;

    ELSIF p_c_action = g_c_forfeit THEN
      BEGIN
        SAVEPOINT s_before_action;
        igs_fi_deposits_prcss.forfeit_deposit( p_n_credit_id=> p_n_credit_id,
                                               p_d_gl_date => TRUNC(p_d_gl_date),
                                               p_b_return_status => l_b_ret_status,
                                               p_c_message_name => l_c_message_name);
        IF NOT l_b_ret_status THEN
          p_c_message_name := l_c_message_name;
        ELSE
          p_c_message_name := NULL;
        END IF;
        p_c_credit_number := NULL;
      EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO s_before_action;
      END;
    END IF;
    RETURN;
  END take_action;

  PROCEDURE prcss_oth_dpsts(p_n_person_id IN igs_fi_parties_v.person_id%TYPE, l_rec_input_param rec_input_param) AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Processess other deposits
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vvutukur 10-Apr-2003   Enh#2831554.Internal Credits API Build. Assigned credit type id to a global variable as this global variable
                         value is used to fetch the credit type name and payment credit type name in the local procedure generate_log.
  ******************************************************************/

    CURSOR c_oth_dpsts(cp_n_person_id igs_fi_parties_v.person_id%TYPE,
                       cp_c_cr_type_id   igs_fi_cr_types.credit_type_id%TYPE,
                       cp_c_fee_cal_type igs_ca_inst.cal_type%TYPE,
                       cp_n_fee_seq_num igs_ca_inst.sequence_number%TYPE)
    IS
    SELECT crd.*
    FROM   igs_fi_credits_all crd,
           igs_fi_cr_types crt
    WHERE crd.party_id = cp_n_person_id AND
          crd.credit_type_id = crt.credit_type_id AND
          crt.credit_class = g_c_othdeposit AND
          (
           (crt.credit_type_id = cp_c_cr_type_id AND cp_c_cr_type_id IS NOT NULL)
            OR
            cp_c_cr_type_id IS NULL
          ) AND
          (
           (crd.fee_cal_type = cp_c_fee_cal_type
            AND
            crd.fee_ci_sequence_number = cp_n_fee_seq_num
           )
           OR
           (
            (crd.fee_cal_type IS NULL AND cp_c_fee_cal_type IS NULL)
             AND
            (crd.fee_ci_sequence_number IS NULL AND cp_n_fee_seq_num IS NULL)
           )
          ) AND
          crd.status = 'CLEARED';

    l_c_message_name fnd_new_messages.message_name%TYPE;
    l_c_credit_number igs_fi_credits.credit_number%TYPE;
    l_b_othdep_exists BOOLEAN := FALSE;
  BEGIN
    FOR l_rec_c_oth_dpsts IN c_oth_dpsts(p_n_person_id,l_rec_input_param.credit_type_id,l_rec_input_param.fee_cal_type, l_rec_input_param.fee_cal_seq_num)
    LOOP
      IF NOT l_b_othdep_exists THEN
        l_b_othdep_exists := TRUE;
      END IF;


      g_credit_type_id := l_rec_c_oth_dpsts.credit_type_id;

      IF (l_rec_input_param.test_mode <> 'Y') THEN
        take_action(l_rec_c_oth_dpsts.credit_id,
                    l_rec_input_param.gl_date,
                    g_c_transfer,
                    l_c_credit_number,
                    l_c_message_name);
      END IF;
      IF l_c_message_name IS NOT NULL THEN
        generate_log(p_n_person_id,
                     l_rec_c_oth_dpsts.credit_number,
                     l_rec_c_oth_dpsts.amount,
                     g_c_hold,
                     g_null,
                     l_c_message_name,
                     g_null);
      ELSE
        generate_log(p_n_person_id,
                     l_rec_c_oth_dpsts.credit_number,
                     l_rec_c_oth_dpsts.amount,
                     g_c_transfer,
                     l_c_credit_number,
                     'IGS_FI_DP_TRANSFERRED',
                     g_null);
      END IF;
    END LOOP;

    IF NOT l_b_othdep_exists THEN
      generate_log(p_n_person_id,
                   g_null,
                   g_null,
                   g_c_hold,
                   g_null,
                   'IGS_FI_DP_NO_RECORDS',
                   g_null);

    END IF;
  END prcss_oth_dpsts;

  PROCEDURE prcss_enr_dpsts(p_n_person_id IN igs_fi_parties_v.person_id%TYPE, l_rec_input_param rec_input_param) AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Processess enrollment deposits
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When          What
  vvutukur 10-Apr-2003   Enh#2831554.Internal Credits API Build. Assigned credit type id to a global variable as this global variable
                         value is used to fetch the credit type name and payment credit type name in the local procedure generate_log.
                         Modified cursor c_enr_dpsts to select credit type id also.
  vchappid 09-Jan-2003   Bug# 2730010, when a student has program attempt as Enrolled and no action is being
                         taken on the Deposit then different message is logged in the log file.
                         Additional issue: Local variables l_c_message_name, l_c_outcome have to be re-initialized
                         before start of each Enrollment Credit

  ******************************************************************/

    -- Cursor for fetching all Deposit Transactions of Enrolment Deposit Credit Class
    -- with 'Cleared' status and matching credit type if provided
    CURSOR c_enr_dpsts(cp_n_person_id   igs_fi_parties_v.person_id%TYPE,
                       cp_n_cr_type_id  igs_fi_cr_types.credit_type_id%TYPE)
    IS
    SELECT crd.credit_id,crd.credit_type_id,
           TO_NUMBER(crd.source_transaction_ref) source_transaction_ref,
           crd.credit_number,
           crd.amount
    FROM  igs_fi_credits crd,
          igs_fi_cr_types crt
    WHERE crd.party_id = cp_n_person_id AND
          crd.credit_type_id = crt.credit_type_id AND
          (
           (crt.credit_type_id = cp_n_cr_type_id AND cp_n_cr_type_id IS NOT NULL)
            OR
            cp_n_cr_type_id IS NULL
          ) AND
          crt.credit_class = g_c_enrdeposit AND
          crd.status = 'CLEARED'
    ORDER BY crd.credit_number;

    -- For each Enrollment Deposit Transaction there wiil be an Admission Application Id Attached
    -- Get the Admission Application Number for the Admission Application Id
    -- With an Admission Application Id, a unique Admission Application Number can be identified for a
    -- person incontext
    CURSOR c_adm_appl_number(cp_n_person_id igs_fi_parties_v.person_id%TYPE,
                             cp_n_appl_id igs_ad_appl.application_id%TYPE)
    IS
    SELECT admission_appl_number, application_type
    FROM  igs_ad_appl
    WHERE person_id = cp_n_person_id AND
          (application_id IS NOT NULL AND application_id = cp_n_appl_id);
    l_rec_adm_appl_number c_adm_appl_number%ROWTYPE;

    -- Cursor for fetching the deposit level for an Admission Application Type
    CURSOR c_deposit_level( cp_c_application_type IN igs_ad_appl.application_type%TYPE)
    IS
    SELECT NVL(enroll_deposit_level, g_c_appl_dep_lvl) enroll_deposit_level
    FROM igs_ad_ss_appl_typ
    WHERE admission_application_type = cp_c_application_type AND
          closed_ind <> 'Y';
    l_rec_deposit_level c_deposit_level%ROWTYPE;


    -- Cursor for fetching matching Admission Application Instances for a Admission Application Number
    -- for the person incontext, load/term calendar as passed in to this request.
    -- If cp_c_criteria parameter value is 'APPL' then all matching instances for a Admission Application Number,
    -- the matching load calendar will be selected.
    -- If cp_c_criteria parameter value is 'ALL' then all matching instances excluding for a Admission Application Number,
    -- the matching load calendar will be selected.
    CURSOR c_appl_number (cp_n_person_id igs_fi_parties_v.person_id%TYPE,
                          cp_c_adm_application_number NUMBER,
                          cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                          cp_load_ci_seq_number igs_ca_inst.cal_type%TYPE,
                          cp_c_criteria igs_lookup_values.lookup_code%TYPE)
    IS
    SELECT inst.course_cd course_cd,
           inst.crv_version_number version_number,
           ps.course_type course_type
    FROM   igs_ad_ps_appl_inst inst,
           igs_ad_appl aa,
           igs_ps_ver ps,
           igs_ad_ofrdfrmt_stat df,
           igs_ad_ofr_resp_stat off
    WHERE  inst.person_id = cp_n_person_id AND
           aa.person_id = inst.person_id AND
           aa.admission_appl_number = inst.admission_appl_number AND
           (
            (inst.admission_appl_number = cp_c_adm_application_number AND cp_c_criteria = 'APPL')
            OR
            (inst.admission_appl_number <> cp_c_adm_application_number AND cp_c_criteria = 'ALL')
           ) AND
           (inst.course_cd = ps.course_cd AND inst.crv_version_number = ps.version_number) AND
           inst.adm_offer_resp_status = off.adm_offer_resp_status AND
           inst.adm_offer_dfrmnt_status = df.adm_offer_dfrmnt_status AND
           (
            (off.s_adm_offer_resp_status = 'DEFERRAL' AND df.s_adm_offer_dfrmnt_status = 'CONFIRM' AND
             check_acad_load_adm_rel(cp_load_cal_type,
                                     cp_load_ci_seq_number,
                                     inst.def_acad_cal_type,
                                     inst.def_acad_ci_sequence_num,
                                     inst.deferred_adm_cal_type,
                                     inst.deferred_adm_ci_sequence_num) = 'Y'
            )
            OR
            (off.s_adm_offer_resp_status = 'ACCEPTED'
             AND
             check_acad_load_adm_rel(cp_load_cal_type,
                                     cp_load_ci_seq_number,
                                     aa.acad_cal_type,
                                     aa.acad_ci_sequence_number,
                                     inst.adm_cal_type,
                                     inst.adm_ci_sequence_number) = 'Y'
            )
           );

      -- Cursor for fetching positive enrollment criteria when defined at program level
      CURSOR c_pec_program(cp_c_adm_appl_type igs_ad_deplvl_prg.admission_application_type%TYPE)
      IS
      SELECT  program_code,
              version_number,
              NULL course_type
      FROM igs_ad_deplvl_prg
      WHERE admission_application_type = cp_c_adm_appl_type AND
            closed_ind='N';

      -- Cursor for fetching positive enrollment criteria when defined at program type level
      CURSOR c_pec_program_type(cp_c_adm_appl_type igs_ad_deplvl_prgty.admission_application_type%TYPE)
      IS
      SELECT NULL program_code,
             NULL version_number,
             program_type
      FROM   igs_ad_deplvl_prgty
      WHERE  admission_application_type = cp_c_adm_appl_type AND
             closed_ind = 'N';

      -- table for holding all initial program attempts details,
      l_tab_stdnt_sca_appl stdnt_sca_tab;
      l_tab_stdnt_sca_num_appl stdnt_sca_ver_num_tab;
      l_tab_std_sca_typ_appl stdnt_sca_typ_tab;

      -- table for holding all Positive Enrollment program attempts
      l_tab_stdnt_sca_oth stdnt_sca_tab;
      l_tab_stdnt_sca_num_oth stdnt_sca_ver_num_tab;
      l_tab_std_sca_typ_oth stdnt_sca_typ_tab;

      -- Deposits will be forfeited depending on this status if it is FALSE
      l_b_dpsts_exist BOOLEAN := FALSE;

      -- local boolean variable
      l_b_status  BOOLEAN;

      l_c_action  igs_lookup_values.lookup_code%TYPE;
      l_c_outcome igs_lookup_values.lookup_code%TYPE := g_c_forfeit;
      l_c_criteria igs_lookup_values.lookup_code%TYPE;
      l_c_sca_att_status igs_lookup_values.lookup_code%TYPE;

      l_c_message_name fnd_new_messages.message_name%TYPE;
      l_c_credit_number igs_fi_credits.credit_number%TYPE;

  BEGIN

    -- Select all records in the Credits Table with a Credit Class of EnrDeposit and with status as Cleared
    -- When there are no receipt transactions for the person incontext then message will be logged in the Log
    -- file.
    FOR l_rec_enr_dpsts IN c_enr_dpsts(p_n_person_id,l_rec_input_param.credit_type_id)
    LOOP

    -- Re-initialize local variables to the default values as these variables are used in a loop
    l_c_message_name := NULL;
    l_c_outcome := g_c_forfeit;

    g_credit_type_id := l_rec_enr_dpsts.credit_type_id;


      IF NOT l_b_dpsts_exist THEN
        l_b_dpsts_exist := TRUE;
      END IF;

      OPEN c_adm_appl_number(p_n_person_id, l_rec_enr_dpsts.source_transaction_ref);
      FETCH c_adm_appl_number INTO l_rec_adm_appl_number;
      CLOSE c_adm_appl_number;

      -- Get the Enrolment Deposit Level for the Admission
      OPEN c_deposit_level(l_rec_adm_appl_number.application_type);
      FETCH c_deposit_level INTO l_rec_deposit_level;
      CLOSE c_deposit_level;

      -- Get All the Course Codes for matching Admission Calendar Type and Admission Application Number
      -- Default Processing Criteria
      -- get all matching application instances load calendar to admission calendar via academic instances
      OPEN c_appl_number(p_n_person_id,
                         l_rec_adm_appl_number.admission_appl_number,
                         l_rec_input_param.load_cal_type,
                         l_rec_input_param.load_cal_seq_num,
                         'APPL');
      FETCH c_appl_number BULK COLLECT INTO l_tab_stdnt_sca_appl, l_tab_stdnt_sca_num_appl, l_tab_std_sca_typ_appl;
      CLOSE c_appl_number;

      -- When there are no matching Admission Instance Records then show the message and process next deposit
      -- Else Continue with the Processing
      IF l_tab_stdnt_sca_appl.COUNT = 0 THEN
        generate_log(p_n_person_id,
                     l_rec_enr_dpsts.credit_number,
                     l_rec_enr_dpsts.amount,
                     g_c_hold,
                     g_null,
                     'IGS_FI_DP_TERM_MISMATCH',
                     g_null);
      ELSE

        -- Verify if the student is enrolled in any of the above programs. If Enrolled then the action on the deposit
        -- will be to transfer the Deposit
        -- If the action is not to Transfer then the processing has to be carried forward depending on the Deposit level
        check_enrollment(p_n_person_id => p_n_person_id,
                         p_tab_course_cd => l_tab_stdnt_sca_appl,
                         p_tab_ver_num => l_tab_stdnt_sca_num_appl,
                         p_tab_sca_typ => l_tab_std_sca_typ_appl,
                         p_rec_input_param => l_rec_input_param,
                         p_c_sca_status => g_c_sca_enrolled,
                         p_c_dep_lvl => g_c_appl_dep_lvl,
                         p_c_action => l_c_action,
                         p_c_sca_att_status => l_c_sca_att_status);

        -- Initially Out Come variable is initialized to Forfeit the Deposit Transaction.
        -- If the outcome is different from the initial value then that value will be assigned to this local variable
        -- If the out come is to Transfer the Deposit then the same is set to this variable and no other procesing
        -- will be done
        IF l_c_action IS NOT NULL THEN
          IF l_c_outcome <> l_c_action THEN
            l_c_outcome := l_c_action;
          END IF;
        END IF;

        -- If out come variable is not set to Transfer then only proceed with the processing
        -- Positive Enrollment Criteria should be considered only when the Deposit Level defined for the
        -- Admission Application Type is other than Application 'APPL'
        -- For an Admission Application Type if the deposit level is not set then processing will be
        -- carried assuming deposit level as Application 'APPL'
        IF l_c_outcome <> g_c_transfer THEN
          IF (l_rec_deposit_level.enroll_deposit_level=g_c_prg_dep_lvl) THEN

            -- If the Deposit is found to be associated at the Program Level then for the
            -- admission application type get all active programs
            OPEN c_pec_program(l_rec_adm_appl_number.application_type);
            FETCH c_pec_program BULK COLLECT INTO l_tab_stdnt_sca_oth, l_tab_stdnt_sca_num_oth, l_tab_std_sca_typ_oth;
            CLOSE c_pec_program;

            -- For the above programs check if the student is Enrolled in any of these programs
            -- If Enrolled then out come is to transfer the deposit transaction
            check_enrollment(p_n_person_id => p_n_person_id,
                             p_tab_course_cd => l_tab_stdnt_sca_oth,
                             p_tab_ver_num => l_tab_stdnt_sca_num_oth,
                             p_tab_sca_typ => l_tab_std_sca_typ_oth,
                             p_rec_input_param => l_rec_input_param,
                             p_c_sca_status => g_c_sca_enrolled,
                             p_c_dep_lvl => g_c_prg_dep_lvl,
                             p_c_action =>l_c_action,
                             p_c_sca_att_status => l_c_sca_att_status);

          ELSIF (l_rec_deposit_level.enroll_deposit_level=g_c_prgty_dep_lvl) THEN

            -- If the Deposit is found to be associated at the Program Type Level then for the
            -- admission application type get all active programs types
            OPEN c_pec_program_type(l_rec_adm_appl_number.application_type);
            FETCH c_pec_program_type BULK COLLECT INTO l_tab_stdnt_sca_oth, l_tab_stdnt_sca_num_oth, l_tab_std_sca_typ_oth;
            CLOSE c_pec_program_type;

            -- For the above program types check if the student is Enrolled in any of these programs types
            -- If Enrolled then out come is to transfer the deposit transaction
            check_enrollment(p_n_person_id => p_n_person_id,
                             p_tab_course_cd => l_tab_stdnt_sca_oth,
                             p_tab_ver_num => l_tab_stdnt_sca_num_oth,
                             p_tab_sca_typ => l_tab_std_sca_typ_oth,
                             p_rec_input_param => l_rec_input_param,
                             p_c_sca_status => g_c_sca_enrolled,
                             p_c_dep_lvl => g_c_prgty_dep_lvl,
                             p_c_action =>l_c_action,
                             p_c_sca_att_status => l_c_sca_att_status);

          ELSIF (l_rec_deposit_level.enroll_deposit_level=g_c_all_dep_lvl) THEN
            -- If the Deposit is found to be associated at the ALL Level executing the admission application
            -- number derived from the admission application id attached to the deposit transaction,
            -- find all other matching program attempts and proceed with this processing
            OPEN c_appl_number(p_n_person_id,
                               l_rec_adm_appl_number.admission_appl_number,
                               l_rec_input_param.load_cal_type,
                               l_rec_input_param.load_cal_seq_num,
                               'ALL');
            FETCH c_appl_number BULK COLLECT INTO l_tab_stdnt_sca_oth, l_tab_stdnt_sca_num_oth,l_tab_std_sca_typ_oth;
            CLOSE c_appl_number;

            -- For the above program attempts check if the student is Enrolled in any of these programs
            -- If Enrolled then out come is to transfer the deposit transaction
            check_enrollment(p_n_person_id => p_n_person_id,
                             p_tab_course_cd => l_tab_stdnt_sca_oth,
                             p_tab_ver_num => l_tab_stdnt_sca_num_oth,
                             p_tab_sca_typ => l_tab_std_sca_typ_oth,
                             p_rec_input_param => l_rec_input_param,
                             p_c_sca_status => g_c_sca_enrolled,
                             p_c_dep_lvl => g_c_all_dep_lvl,
                             p_c_action =>l_c_action,
                             p_c_sca_att_status => l_c_sca_att_status);

          END IF;

          IF l_c_action IS NOT NULL THEN
            IF l_c_outcome <> l_c_action THEN
              l_c_outcome := l_c_action;
            END IF;
          END IF;
        END IF;

        -- If the out come of the deposit till this point is not to Transfer the Deposit then
        -- Proceed further to check if the student has program attempts in any other statuses
        IF l_c_outcome <> g_c_transfer THEN

          -- For the program attempts attached for the application number derived form the application id
          -- attached to a deposit check the student program attempt status is in other than Enrolled Status
          -- If the student attempt is in other status then out come is to hold the deposit transaction
          check_enrollment(p_n_person_id => p_n_person_id,
                           p_tab_course_cd => l_tab_stdnt_sca_appl,
                           p_tab_ver_num => l_tab_stdnt_sca_num_appl,
                           p_tab_sca_typ => l_tab_std_sca_typ_appl,
                           p_rec_input_param => l_rec_input_param,
                           p_c_sca_status => g_c_sca_other,
                           p_c_dep_lvl => g_c_appl_dep_lvl,
                           p_c_action =>l_c_action,
                           p_c_sca_att_status => l_c_sca_att_status);

          IF l_c_action IS NOT NULL THEN
            IF l_c_outcome <> l_c_action THEN
              l_c_outcome := l_c_action;
            END IF;
          END IF;
        END IF;

        -- Process should be continued only when the outcome till this point is not set to either Hold or Transfer and
        -- the deposit level for the admission application type is other than 'Application'
        IF (l_c_outcome NOT IN (g_c_transfer, g_c_hold) AND l_rec_deposit_level.enroll_deposit_level <> g_c_appl_dep_lvl) THEN

          -- In this case since we need to compare course codes and version numbers
          -- for all deposit levels ALL, APPL and PROGRAM, to the generic procedure
          -- pass p_c_dep_lvl as 'APPL' else pass as 'PROGRAM TYPE'
          IF l_rec_deposit_level.enroll_deposit_level <> g_c_prgty_dep_lvl THEN
            l_c_criteria := g_c_appl_dep_lvl;
          ELSE
            l_c_criteria := g_c_prgty_dep_lvl;
          END IF;

          -- For the program attempts as derived from Positive Enrollment Criteria
          -- attached to a deposit check the student program attempt status is in other than Enrolled Status
          -- If the student attempt is in other status then out come is to hold the deposit transaction
          check_enrollment(p_n_person_id => p_n_person_id,
                           p_tab_course_cd => l_tab_stdnt_sca_oth,
                           p_tab_ver_num => l_tab_stdnt_sca_num_oth,
                           p_tab_sca_typ => l_tab_std_sca_typ_oth,
                           p_rec_input_param => l_rec_input_param,
                           p_c_sca_status => g_c_sca_other,
                           p_c_dep_lvl => l_c_criteria,
                           p_c_action =>l_c_action,
                           p_c_sca_att_status => l_c_sca_att_status);

          IF l_c_action IS NOT NULL THEN
            IF l_c_outcome <> l_c_action THEN
              l_c_outcome := l_c_action;
            END IF;
          END IF;
        END IF;


        IF l_rec_input_param.test_mode <> 'Y' THEN
          IF l_c_outcome = g_c_transfer THEN
            l_c_action :=  g_c_transfer;
          ELSIF l_c_outcome = g_c_hold THEN
            l_c_action :=  g_c_hold;
          ELSIF l_c_outcome = g_c_forfeit THEN
            l_c_action :=  g_c_forfeit;
          END IF;
          take_action(l_rec_enr_dpsts.credit_id,
                        l_rec_input_param.gl_date,
                        l_c_action,
                        l_c_credit_number,
                        l_c_message_name);
        END IF;

        IF l_c_outcome = g_c_transfer THEN
          l_c_message_name := NVL(l_c_message_name,'IGS_FI_DP_TRANSFERRED');
        ELSIF l_c_outcome = g_c_hold THEN
          IF l_c_sca_att_status = 'ENROLLED' THEN
            l_c_message_name := NVL(l_c_message_name,'IGS_FI_DP_SPA_SUA_NO_ACTION');
          ELSE
            l_c_message_name := NVL(l_c_message_name,'IGS_FI_DP_SPA_NO_ACTION');
          END IF;
        ELSIF l_c_outcome = g_c_forfeit THEN
          l_c_message_name := NVL(l_c_message_name,'IGS_FI_DP_FORFEITED');
        END IF;

        generate_log(p_n_person_id,
                     l_rec_enr_dpsts.credit_number,
                     l_rec_enr_dpsts.amount,
                     l_c_outcome,
                     l_c_credit_number,
                     l_c_message_name,
                     l_c_sca_att_status);
      END IF;
    END LOOP; -- igs_fi_credits table End Loop
    -- If there are no deposits in Cleared Status then log a message
    -- Depending on the test mode parameter call to the generic procedure will be made
    -- Irrespective of the test mode parameter, messages have to be logged
  IF NOT l_b_dpsts_exist THEN
    generate_log(p_n_person_id,
                 g_null,
                 g_null,
                 g_null,
                 g_null,
                 'IGS_FI_DP_NO_RECORDS',
                 g_null);
  END IF;

  RETURN;
  END prcss_enr_dpsts;


  PROCEDURE prc_stdnt_deposit (errbuf           OUT NOCOPY  VARCHAR2,
                               retcode          OUT NOCOPY  NUMBER,
                               p_c_credit_class             VARCHAR2,
                               p_n_person_id_grp            NUMBER,
                               p_n_person_id                NUMBER,
                               p_n_credit_type_id           NUMBER,
                               p_c_term_cal_inst            VARCHAR2,
                               p_d_gl_date                  VARCHAR2,
                               p_c_test_mode                VARCHAR2
                             ) AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 05-DEC-2002
  Purpose           : Main procedure called from Concurrent Manager
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who        When           What
  pathipat   24-Apr-2003    Enh 2831569 - Commercial Receivables build
                            Added check for manage_accounts - call to chk_manage_account()
  vchappid   09-Jan-2003    Bug# 2729935, While Selecting Person Group member, start date and end date is checked.
  ******************************************************************/

    CURSOR c_person(cp_n_person_id     igs_pe_person.person_id%TYPE,
                    cp_n_person_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE)
    IS
    SELECT person_id
    FROM  igs_pe_prsid_grp_mem
    WHERE group_id = cp_n_person_grp_id AND
          TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date,SYSDATE)) AND TRUNC(NVL(end_date,SYSDATE)) AND
          cp_n_person_id IS NULL AND
          cp_n_person_grp_id IS NOT NULL
    UNION
    SELECT cp_n_person_id
    FROM   DUAL
    WHERE cp_n_person_id IS NOT NULL AND
          cp_n_person_grp_id IS NULL;

    l_rec_input_param rec_input_param;

    l_c_load_cal_type      igs_ca_inst.cal_type%TYPE;
    l_n_load_ci_seq_num    igs_ca_inst.sequence_number%TYPE;
    l_c_fee_cal_type       igs_ca_inst.cal_type%TYPE;
    l_n_fee_ci_seq_num igs_ca_inst.sequence_number%TYPE;

    l_b_ret_status BOOLEAN;

    l_c_message_name   fnd_new_messages.message_name%TYPE := NULL;

    l_v_manage_acc     igs_fi_control_all.manage_accounts%TYPE  := NULL;

  BEGIN
    -- Initialize retcode to 0 and errbuf to NULL
    retcode :=0;
    errbuf := NULL;

    -- Should Set the org_id
    igs_ge_gen_003.set_org_id(NULL);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_c_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_c_message_name);
       fnd_file.put_line(fnd_file.log,fnd_message.get());
       fnd_file.new_line(fnd_file.log);
       RAISE do_nothing;
    END IF;

    IF (p_c_term_cal_inst IS NOT NULL) THEN
      l_c_load_cal_type := RTRIM(SUBSTR(p_c_term_cal_inst, 102, 10));
      l_n_load_ci_seq_num := TO_NUMBER(LTRIM(SUBSTR(p_c_term_cal_inst, 113,8)));
    END IF;

    -- Initialize the record type variable with the values that are passed to this request
    l_rec_input_param.credit_class := p_c_credit_class;
    l_rec_input_param.credit_type_id := p_n_credit_type_id;
    l_rec_input_param.load_cal_type := l_c_load_cal_type ;
    l_rec_input_param.load_cal_seq_num := l_n_load_ci_seq_num ;
    l_rec_input_param.fee_cal_type := NULL ;
    l_rec_input_param.fee_cal_seq_num := NULL ;
    l_rec_input_param.gl_date := igs_ge_date.igsdate(p_canonical_date => p_d_gl_date);
    l_rec_input_param.test_mode := p_c_test_mode;

    -- Validate and log input process parameters
    validate_log_parameters(p_rec_input_param => l_rec_input_param,
                            p_n_person_id => p_n_person_id,
                            p_n_person_id_grp => p_n_person_id_grp,
                            p_b_ret_status => l_b_ret_status);

    -- When the above procedure returns FALSE then raise Exception
    IF NOT l_b_ret_status THEN
      RAISE do_nothing;
    END IF;

    BEGIN
    -- Initialize the record type input variables with the Fee Calendar Instance only when then term calendar is provided
    IF l_rec_input_param.load_cal_type IS NOT NULL AND l_rec_input_param.load_cal_seq_num IS NOT NULL THEN
      IF NOT (igs_fi_gen_001.finp_get_lfci_reln(p_cal_type => l_rec_input_param.load_cal_type,
                                                p_ci_sequence_number => l_rec_input_param.load_cal_seq_num,
                                                p_cal_category => 'LOAD',
                                                p_ret_cal_type => l_c_fee_cal_type,
                                                p_ret_ci_sequence_number => l_n_fee_ci_seq_num,
                                                p_message_name => l_c_message_name)) THEN
          fnd_message.set_name('IGS',l_c_message_name);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE do_nothing;
      END IF;
    END IF;
    EXCEPTION
    WHEN do_nothing THEN
      RAISE;
    END;

    -- Initialize the input record variable with the fee calendar instance
    l_rec_input_param.fee_cal_type := l_c_fee_cal_type;
    l_rec_input_param.fee_cal_seq_num := l_n_fee_ci_seq_num;

    -- Start the processing for the Person or Person Id Group depending on the input parameters
    FOR l_person_rec IN c_person(p_n_person_id,p_n_person_id_grp)
    LOOP
      IF p_c_credit_class = g_c_othdeposit THEN
        prcss_oth_dpsts(l_person_rec.person_id, l_rec_input_param);
      ELSIF p_c_credit_class = g_c_enrdeposit THEN
        prcss_enr_dpsts(l_person_rec.person_id, l_rec_input_param);
      END IF;
    END LOOP;

    IF (l_rec_input_param.test_mode='N') THEN
      COMMIT;
    ELSE
      ROLLBACK;
      fnd_message.set_name('IGF', 'IGF_SP_TEST_MODE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;


  EXCEPTION
    WHEN do_nothing THEN
      retcode :=2;

    WHEN OTHERS THEN
     retcode := 2;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
     errbuf := fnd_message.get;
     fnd_file.put_line(fnd_file.log,sqlerrm);
     igs_ge_msg_stack.conc_exception_hndl;
  END prc_stdnt_deposit;

END igs_fi_prc_stdnt_dpsts;

/
