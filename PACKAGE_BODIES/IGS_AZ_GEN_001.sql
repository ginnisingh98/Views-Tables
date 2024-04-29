--------------------------------------------------------
--  DDL for Package Body IGS_AZ_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AZ_GEN_001" AS
/* $Header: IGSAZ01B.pls 120.9 2006/06/06 13:47:55 swaghmar ship $ */

  /***********************************************************************************************
  Created By      : Girish Jha
  Date Created By : 14 May 2003
  Purpose         : This package is the generaic package for advising functionality. This contains the routines
                    for Maintaining the advising group, apply advising holds on the students of the group and
                    sending the notifications to students and advisors.
                    This is modular approach to make the routines which can be called from 1. Concurrent program
                    2. Self service pages 3. Any pl/sql block separately.
  Remarks          : None
  Change History
  Who        When        What
  -----------------------------------------------------------
  Girish Jha 12-May-2003 New Package created.
  anilk      03-Jul-2003 Fixed Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
  smanglm    05-Aug-2003 Bug 3084766: Make use of Dynamic Person ID Group if the igs_pe_persid_group_all.FILE_NAME
                         is not null else make use of static query. Changes made in the
                         following cursors of maintain_groups:
                         cur_std_to_add
                         cur_adv_to_add
                         cur_std_to_del
                         cur_adv_to_del
  kdande     03-Sep-2003 Bug# 3034714
    Changed the log format for the Maintain Advising Group job as per the format
    mentioned in the FD.
     | nmankodi   11-Apr-2005     fnd_user.customer_id column has been changed to
 |                            fnd_user.person_party_id as an ebizsuite wide TCA mandate.
 |swaghmar    16-Jan-2006    Bug# 4951054  Added check for disabling UI's
 | sepalani   27-Mar-2006     added validation check for empty string values on student group and
 |				advisor group person ids .
 | sepalani   20-Apr-2006     Bug # 5188499: ISSUE WITH SUGGESTED MATCHES IN ADVISING GROUPS
  ***********************************************************************************************/

  PROCEDURE maintain_groups (
    errbuf                       OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY VARCHAR2,
    p_group_name                 IN       VARCHAR2 DEFAULT NULL,
    p_apply_hold                 IN       VARCHAR2 DEFAULT 'N',
    p_notify                     IN       VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    -- declare the ref cursor
    --
    TYPE ref_cur IS REF CURSOR;
    --
    -- Now declare the variables for the above ref curosr
    --
    cur_std_to_add         ref_cur;
    cur_adv_to_add         ref_cur;
    cur_std_to_del         ref_cur;
    cur_adv_to_del         ref_cur;
    --
    -- Declare the out param for the funtion IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL
    --
    l_status               VARCHAR2 (2000);
    --
    -- Cursor to check whether dynamic person_id_group has to be used or not based on the value
    -- of igs_pe_persid_group_all.file_name for the given group_id
    --
    CURSOR c_is_filename_null (cp_group_id igs_pe_persid_group_all.GROUP_ID%TYPE) IS
      SELECT 'Y'
        FROM igs_pe_persid_group_all
       WHERE GROUP_ID = cp_group_id AND file_name IS NULL;
    --
    l_adv_is_filename_null VARCHAR2 (1)                            := 'N';
    l_std_is_filename_null VARCHAR2 (1)                            := 'N';
    --
    -- Cursor to select the advising groups to be processed .. If user passes Null as group name then
    -- Select all the groups having AUTO_REFRESH_FLAG = 'Y' Also this should not be run for delivary method = 'Self advised'
    --
    CURSOR cur_grp_to_be_processed IS
      SELECT   azg.ROWID row_id,
               azg.*
      FROM     igs_az_groups azg
      WHERE    (azg.group_name = p_group_name
      AND      azg.delivery_method_code <> 'SELF')
      OR       (p_group_name IS NULL
      AND      azg.auto_refresh_flag = 'Y');

    CURSOR cur_stdt_to_be_updated(cp_group_name VARCHAR2,cp_student_person_id NUMBER) IS
        SELECT azs.ROWID row_id,
               azs.*
        FROM igs_az_students azs
        where GROUP_NAME = cp_group_name
        AND  STUDENT_PERSON_ID = cp_student_person_id;

    CURSOR cur_advr_to_be_updated(cp_group_name VARCHAR2,cp_advisor_person_id NUMBER) IS
        SELECT azs.ROWID row_id,
               azs.*
        FROM igs_az_advisors azs
        where GROUP_NAME = cp_group_name
        AND  ADVISOR_PERSON_ID = cp_advisor_person_id;
    --
    -- Variable to store select the Students in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table
    -- for the group for static group id
    --
    l_stc_std_to_add       VARCHAR2 (2000)
    :=    ' SELECT PERSON_ID FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :1 '
       || ' AND trunc(START_DATE) <= trunc(SYSDATE) AND  NVL(END_DATE, SYSDATE) >= SYSDATE '
       || ' MINUS '
       || ' SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :2 ';
    --
    -- Variable to store select the Students in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table
    -- for the group for dynamic group id
    --
    l_dyn_std_to_add       VARCHAR2 (2000)
    := ' MINUS SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :1 ';
    --
    -- Variable to store to select the ADVISORS in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table
    -- for the group for static group id
    --
    l_stc_adv_to_add       VARCHAR2 (2000)
    :=    ' SELECT PERSON_ID  FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :1 '
       || ' AND trunc(START_DATE) <= trunc(SYSDATE) AND  NVL(END_DATE, SYSDATE) >= SYSDATE '
       || ' MINUS '
       || ' SELECT ADVISOR_PERSON_ID PERSON_ID  FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :2 ';
    --
    -- variable to store to select the ADVISORS in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table
    -- for the group for dynamic group id
    --
    l_dyn_adv_to_add       VARCHAR2 (2000)
    := ' MINUS SELECT ADVISOR_PERSON_ID PERSON_ID  FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :1 ';
    --
    -- Variable to store to select the Students existing inthe IGS_AZ_STUDENTS table MINUS
    -- those in the student person ID group for static group id
    --
    l_stc_std_to_del       VARCHAR2 (2000)
    :=    ' SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :1 '
       || ' AND NVL(ACCEPT_DELETE_FLAG, ''N'') = ''N'' '
       || ' MINUS '
       || ' SELECT PERSON_ID FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :2 '
       || ' AND  NVL(END_DATE, SYSDATE) >= SYSDATE AND trunc(START_DATE) <= trunc(SYSDATE) ';
    --
    -- To do see the effective date in person ID group
    --
    --
    -- Variable to store to select the Students existing inthe IGS_AZ_STUDENTS table MINUS
    -- those in the student person ID group for dynamic group id
    --
    l_dyn_std_to_del       VARCHAR2 (2000)
    :=    ' SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :1 '
       || ' AND NVL(ACCEPT_DELETE_FLAG, ''N'') = ''N'' MINUS ';
    --
    -- Variable to store to select the advisors existing inthe IGS_AZ_STUDENTS table MINUS
    -- those in the advisor person ID group for static group id
    --
    l_stc_adv_to_del       VARCHAR2 (2000)
    :=    ' SELECT ADVISOR_PERSON_ID PERSON_ID FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :1 '
       || ' MINUS '
       || ' SELECT PERSON_ID FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :2 '
       || ' AND  NVL(END_DATE, SYSDATE) >= SYSDATE AND trunc(START_DATE) <= trunc(SYSDATE) ';
    --
    -- Variable to store to select the advisors existing inthe IGS_AZ_STUDENTS table MINUS
    -- those in the advisor person ID group for dynamic group id
    --
    l_dyn_adv_to_del       VARCHAR2 (2000)
    := ' SELECT ADVISOR_PERSON_ID PERSON_ID FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :1 MINUS ';

    -- sepalani For Bug # 5188499
    --
    -- Variable to store select the Students in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table who
    -- has accept flag set to none
    -- for the group for static group id
    --
    l_stc_std_to_upd       VARCHAR2 (2000)
    :=    ' SELECT PERSON_ID FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :1 '
       || ' AND trunc(START_DATE) <= trunc(SYSDATE) AND  NVL(END_DATE, SYSDATE) >= SYSDATE '
       || ' MINUS '
       || ' SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :2 '
       || ' AND ACCEPT_ADD_FLAG IS NOT NULL';
    --
    -- Variable to store select the Students in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table who
    -- has accept flag set to none
    -- for the group for dynamic group id
    --
    l_dyn_std_to_upd       VARCHAR2 (2000)
    := ' MINUS SELECT STUDENT_PERSON_ID PERSON_ID FROM IGS_AZ_STUDENTS WHERE GROUP_NAME = :1 '
      || ' AND ACCEPT_ADD_FLAG IS NOT NULL';
    --
    -- Variable to store to select the ADVISORS in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table who
    -- has accept flag set to none
    -- for the group for static group id
    --
    l_stc_adv_to_upd       VARCHAR2 (2000)
    :=    ' SELECT PERSON_ID  FROM  IGS_PE_PRSID_GRP_MEM_ALL WHERE GROUP_ID = :1 '
       || ' AND trunc(START_DATE) <= trunc(SYSDATE) AND  NVL(END_DATE, SYSDATE) >= SYSDATE '
       || ' MINUS '
       || ' SELECT ADVISOR_PERSON_ID PERSON_ID  FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :2 '
       || ' AND ACCEPT_ADD_FLAG IS NOT NULL';
    --
    -- variable to store to select the ADVISORS in the existing Student PID grop minus that one for the IGS_AZ_STUDENTS table who
    -- has accept flag set to none
    -- for the group for dynamic group id
    --
    l_dyn_adv_to_upd       VARCHAR2 (2000)
    := ' MINUS SELECT ADVISOR_PERSON_ID PERSON_ID  FROM IGS_AZ_ADVISORS WHERE GROUP_NAME = :1 '
        || ' AND ACCEPT_ADD_FLAG IS NOT NULL';

    --
    -- Declare a variable to store the person_id that would be obtained from the above ref cursors
    --
    l_person_id            igs_pe_person.person_id%TYPE;
    --
    -- Declare Local variables
    --
    lvAutoStdAddInd        VARCHAR2 (1)                            := 'N';
    lvAutoStdDelInd        VARCHAR2 (1)                            := 'N';
    lvAutoAdvAddInd        VARCHAR2 (1)                            := 'N';
    lvAutoAdvDelInd        VARCHAR2 (1)                            := 'N';
    lvAutoMatchInd         VARCHAR2 (1)                            := 'N';
    ldAddStdStartDate      DATE                                    := NULL;
    ldDelStdStartDate      DATE                                    := NULL;
    ldAddAdvStartDate      DATE                                    := NULL;
    ldDelAdvStartDate      DATE                                    := NULL;
    lnAddedStudents        NUMBER;
    lnAddedAdvisors        NUMBER;
    lnDelStudents          NUMBER;
    lnDelAdvisors          NUMBER;
    lnGrpCount             NUMBER                                  := 0;
    lnSuggestedMatches     NUMBER                                  := 0;
    lvcNotifErbuf          VARCHAR2 (1000); -- Err buf code for making a call to send notification (its out parameter)
    lvNotifRtCode          VARCHAR2 (100);
    lvcApplHldErbuf        VARCHAR2 (1000); -- Err buf code for making a call to apply hold (its out parameter)
    lvApplHldrtcode        VARCHAR2 (100);
    lvStdRowID             VARCHAR2 (25); -- ROWID to be passed as parameter to IGS_AZ_STUDENTS_PKG.INSERT_ROW(An out parameter)
    lnGrpStdID             igs_az_students.group_student_id%TYPE; -- Group Student ID to be passed as parameter to IGS_AZ_STUDENTS_PKG.INSERT_ROW(An out parameter)
    lvAdvRowID             VARCHAR2 (25); -- ROWID to be passed as parameter to IGS_AZ_ADVISORS_PKG.INSERT_ROW(An out parameter)
    lnGrpadvID             igs_az_students.group_student_id%TYPE; -- Group Student ID to be passed as parameter to IGS_AZ_ADVISORS_PKG.INSERT_ROW(An out parameter)
    lvReturnStatus         VARCHAR2 (1); -- Parameter to be passed to the procedures which have RETURN_STATUS as an out paramere
    lvMsgData              VARCHAR2 (1000); -- Parameter to be passed to the procedures which have MSG_DATA as an out paramere
    lnMsgCount             NUMBER; -- Parameter to be passed to the procedures which have MSG_COUNT as an out paramere
    -- sepalani
    p_student_rec           cur_stdt_to_be_updated%ROWTYPE;
    p_advisor_rec           cur_advr_to_be_updated%ROWTYPE;

    --
  BEGIN
    --
    -- Initialize the OUT params
    --

    retcode := 0;
    errbuf := NULL;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
    SAVEPOINT s_maintain_groups;
    --
    -- Write the passed parameters to the Log File
    --
    fnd_message.set_name ('FND', 'CONC-ARGUMENTS');
    fnd_file.put_line (fnd_file.log, fnd_message.get);
    fnd_file.put_line (fnd_file.log, '+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.log, 'P_GROUP_NAME=''' || p_group_name || '''');
    fnd_file.put_line (fnd_file.log, 'P_APPLY_HOLD=''' || p_apply_hold || '''');
    fnd_file.put_line (fnd_file.log, 'P_NOTIFY=''' || p_notify || '''');
    fnd_file.put_line (fnd_file.log, '+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.log, '');
    --
    FOR grp_rec IN cur_grp_to_be_processed LOOP
      --
      -- check whether the dynamic persid group has to be used or not for advisor
      --
      OPEN c_is_filename_null (grp_rec.advisor_group_id);
      FETCH c_is_filename_null INTO l_adv_is_filename_null;
      CLOSE c_is_filename_null;
      --
      -- check whether the dynamic persid group has to be used or not for student
      --
      OPEN c_is_filename_null (grp_rec.student_group_id);
      FETCH c_is_filename_null INTO l_std_is_filename_null;
      CLOSE c_is_filename_null;
      --
      -- Update the count of the group to be printed in log file
      --
      lnGrpCount := lnGrpCount + 1;
      --
      -- Initialize the counts to be logged in the log file
      --
      lnAddedStudents := 0;
      lnAddedAdvisors := 0;
      lnDelStudents := 0;
      lnDelAdvisors := 0;
      --
      -- See if the value of AUTO_STDNT_ADD_FLAG is 'Y' if yes then START_DATE should be 'Y' else it should be null;
      --
      IF grp_rec.auto_stdnt_add_flag = 'Y' THEN
        ldAddStdStartDate := SYSDATE;
        lvAutoStdAddInd := 'Y';
      ELSE
        ldAddStdStartDate := NULL;
        lvAutoStdAddInd := NULL;
      END IF;
      --
      -- See if the value of AUTO_STDNT_REMOVE_FLAG is 'Y' if yes then START_DATE should be 'Y' else it should be null;
      --
      IF grp_rec.auto_stdnt_add_flag = 'Y' THEN
        ldDelStdStartDate := SYSDATE;
        lvAutoStdDelInd := 'Y';
      ELSE
        ldDelStdStartDate := NULL;
        lvAutoStdDelInd := NULL;
      END IF;
      --
      -- See if the value of AUTO_ADVISOR_ADD_FLAG is 'Y' if yes then START_DATE should be 'Y' else it should be null;
      --
      IF grp_rec.auto_advisor_add_flag = 'Y' THEN
        ldAddAdvStartDate := SYSDATE;
        lvAutoAdvAddInd := 'Y';
      ELSE
        ldAddAdvStartDate := NULL;
        lvAutoAdvAddInd := NULL;
      END IF;
      --
      -- See if the value of AUTO_ADVISOR_REMOVE_FLAG is 'Y' if yes then START_DATE should be 'Y' else it should be null;
      --
      IF grp_rec.auto_advisor_remove_flag = 'Y' THEN
        ldDelAdvStartDate := SYSDATE;
        lvAutoAdvDelInd := 'Y';
      ELSE
        ldDelAdvStartDate := NULL;
        lvAutoAdvDelInd := NULL;
      END IF;
      --
      -- See if the auto match indiactor is Yes
      --
      IF  grp_rec.auto_match_flag = 'Y' AND grp_rec.delivery_method_code = '1_ON_1' THEN
        lvAutoMatchInd := 'Y';
      ELSE
        lvAutoMatchInd := 'N';
      END IF;

      --
      -- Check if the Student group id is null or not
      -- if it is not null the proceed with the adding to the Advising Group
      --
      IF (grp_rec.student_group_id IS NOT NULL) THEN
      --
      -- Loop through all the students who are suggested to be added to the group..
      --
      IF l_std_is_filename_null = 'N' THEN
        l_dyn_std_to_add :=
               igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
                 grp_rec.student_group_id,
                 l_status
               )
            || l_dyn_std_to_add;
        --
        IF l_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
          fnd_msg_pub.ADD;
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          RAISE fnd_api.g_exc_error;
        END IF;
        --
        OPEN cur_std_to_add FOR l_dyn_std_to_add USING grp_rec.group_name;
      ELSE
        OPEN cur_std_to_add FOR l_stc_std_to_add
          USING grp_rec.student_group_id, grp_rec.group_name;
      END IF;
      --
      LOOP
        FETCH cur_std_to_add INTO l_person_id;
        EXIT WHEN cur_std_to_add%NOTFOUND;
        --
        -- Update the count to be printed in log file
        --
        lnAddedStudents := lnAddedStudents + 1;
        --
        -- Make a call to the procedure to add the student with values for
        -- Get the nextvalue from the sequence ..
        --
        -- Now call insert row
        --
        igs_az_students_pkg.insert_row (
          x_rowid                       => lvStdRowID,
          x_group_student_id            => lnGrpStdID,
          x_group_name                  => grp_rec.group_name,
          x_student_person_id           => l_person_id,
          x_start_date                  => ldAddStdStartDate,
          x_end_date                    => NULL,
          x_advising_hold_type          => NULL,
          x_hold_start_date             => NULL,
          x_notified_date               => NULL,
          x_accept_add_flag             => lvAutoStdAddInd,
          x_accept_delete_flag          => NULL,
          x_return_status               => lvReturnStatus,
          x_msg_data                    => lvMsgData,
          x_msg_count                   => lnMsgCount
        );
        --
        -- To do error handling...
        --
        IF (lvReturnStatus <> fnd_api.g_ret_sts_success) THEN
          retcode := 2;
          IF (lnMsgCount = 1) THEN
            errbuf := lvMsgData;
          ELSE
            errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP; -- for cur_std_to_add
      CLOSE cur_std_to_add;

      -- sepalani bug # 5188499

      IF lnAddedStudents = 0 and lvAutoStdAddInd = 'Y' THEN



        IF l_std_is_filename_null = 'N' THEN
        l_dyn_std_to_upd :=
               igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
                 grp_rec.student_group_id,
                 l_status
               )
            || l_dyn_std_to_upd;
        --
        IF l_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
          fnd_msg_pub.ADD;
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          RAISE fnd_api.g_exc_error;
        END IF;
          OPEN cur_std_to_add FOR l_dyn_std_to_upd USING grp_rec.group_name;
        ELSE
        OPEN cur_std_to_add FOR l_stc_std_to_upd
          USING grp_rec.student_group_id, grp_rec.group_name;
        END IF;

        LOOP

            FETCH cur_std_to_add INTO l_person_id;
            EXIT WHEN cur_std_to_add%NOTFOUND;

            OPEN cur_stdt_to_be_updated (p_group_name, l_person_id);
            FETCH cur_stdt_to_be_updated into p_student_rec;

            IF lvAutoStdAddInd IS NULL  THEN
              lvAutoStdAddInd := p_student_rec.accept_add_flag;
            END IF;

            igs_az_students_pkg.update_row (
            x_rowid                        => p_student_rec.row_id,
            x_group_student_id             => p_student_rec.group_student_id,
            x_group_name                   => p_student_rec.group_name,
            x_student_person_id            => p_student_rec.student_person_id,
            x_start_date                   => ldAddStdStartDate,
            x_end_date                     => p_student_rec.end_date,
            x_advising_hold_type           => p_student_rec.advising_hold_type,
            x_hold_start_date              => p_student_rec.hold_start_date,
            x_notified_date                => p_student_rec.notified_date,
            x_accept_add_flag              => lvAutoStdAddInd,
            x_accept_delete_flag           => p_student_rec.accept_delete_flag,
            x_return_status                => lvReturnStatus,
            x_msg_data                     => lvMsgData,
            x_msg_count                    => lnMsgCount
            );
            CLOSE cur_stdt_to_be_updated;
            --
            -- To do error handling...
            --
            IF (lvReturnStatus <> fnd_api.g_ret_sts_success) THEN
              retcode := 2;
              IF (lnMsgCount = 1) THEN
                errbuf := lvMsgData;
              ELSE
                errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

       END LOOP;
       CLOSE cur_std_to_add;
      END IF;

      END IF ; --      IF (grp_rec.student_group_id IS NOT NULL) THEN

      --
      -- Check if the Advisor group id is null or not
      -- if it is not null then proceed with the adding Advisors
      --

      IF (grp_rec.advisor_group_id IS NOT NULL) THEN

      --
      -- Loop through all the Advisors who are suggested to be added
      --
      IF l_adv_is_filename_null = 'N' THEN
        l_dyn_adv_to_add :=
               igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
                 grp_rec.advisor_group_id,
                 l_status
               )
            || l_dyn_adv_to_add;
        IF l_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
          fnd_msg_pub.ADD;
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          RAISE fnd_api.g_exc_error;
        END IF;
        OPEN cur_adv_to_add FOR l_dyn_adv_to_add USING grp_rec.group_name;
      ELSE
        OPEN cur_adv_to_add FOR l_stc_adv_to_add
          USING grp_rec.advisor_group_id, grp_rec.group_name;
      END IF;
      LOOP
        FETCH cur_adv_to_add INTO l_person_id;
        EXIT WHEN cur_adv_to_add%NOTFOUND;
        --
        -- Update the count to be printed in log file
        --
        lnAddedAdvisors := lnAddedAdvisors + 1;
        --
        -- Make a call to the procedure to add the advisors with values for
        -- auto accept and start dates properly
        --
        -- Make a call to insert row for the group advisor
        --
        igs_az_advisors_pkg.insert_row (
          x_rowid                       => lvAdvRowID,
          x_group_advisor_id            => lnGrpadvID,
          x_group_name                  => grp_rec.group_name,
          x_advisor_person_id           => l_person_id,
          x_start_date                  => ldAddAdvStartDate,
          x_end_date                    => NULL,
          x_max_students_num            => grp_rec.default_advisor_load_num, -- The maximum load initialized to the default load of the group
          x_notified_date               => NULL,
          x_accept_add_flag             => lvAutoAdvAddInd,
          x_accept_delete_flag          => NULL, --Todo uncomment following three parameters once the are added to TBH
          x_return_status               => lvReturnStatus,
          x_msg_data                    => lvMsgData,
          x_msg_count                   => lnMsgCount
        );
        --
        -- To do Error handling
        --
        IF lvReturnStatus <> fnd_api.g_ret_sts_success THEN
          retcode := 2;
          IF lnMsgCount = 1 THEN
            errbuf := lvMsgData;
          ELSE
            errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP; --cur_adv_to_add

      CLOSE cur_adv_to_add;

      -- sepalani bug # 5188499

      IF lnAddedAdvisors = 0 and lvAutoAdvAddInd = 'Y' THEN

      IF l_adv_is_filename_null = 'N' THEN
	l_dyn_adv_to_upd :=
	       igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
		 grp_rec.advisor_group_id,
		 l_status
	       )
	    || l_dyn_adv_to_upd;
	IF l_status <> fnd_api.g_ret_sts_success THEN
	  fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
	  fnd_msg_pub.ADD;
	  fnd_file.put_line (fnd_file.LOG, fnd_message.get);
	  RAISE fnd_api.g_exc_error;
	END IF;
	OPEN cur_adv_to_add FOR l_dyn_adv_to_upd USING grp_rec.group_name;
      ELSE
	OPEN cur_adv_to_add FOR l_stc_adv_to_upd
	  USING grp_rec.advisor_group_id, grp_rec.group_name;
      END IF;

        LOOP

            FETCH cur_adv_to_add INTO l_person_id;
            EXIT WHEN cur_adv_to_add%NOTFOUND;

            OPEN cur_advr_to_be_updated (p_group_name, l_person_id);
            FETCH cur_advr_to_be_updated into p_advisor_rec;

            IF lvAutoAdvAddInd IS NULL  THEN
              lvAutoAdvAddInd := p_advisor_rec.accept_add_flag;
            END IF;


      igs_az_advisors_pkg.update_row(
        x_rowid                       => p_advisor_rec.row_id,
        x_group_advisor_id            => p_advisor_rec.group_advisor_id,
        x_group_name                  => p_advisor_rec.group_name,
        x_advisor_person_id           => p_advisor_rec.advisor_person_id,
        x_start_date                  => ldAddAdvStartDate,
        x_end_date                    => p_advisor_rec.end_date,
        x_max_students_num            => p_advisor_rec.max_students_num,
        x_notified_date               => SYSDATE, -- This is the only change
        x_accept_add_flag             => lvAutoAdvAddInd,
        x_accept_delete_flag          => p_advisor_rec.accept_delete_flag, ---To do Follwing three parameters need to be added in the TBH and then uncomment
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );

            CLOSE cur_advr_to_be_updated;
            --
            -- To do error handling...
            --
            IF (lvReturnStatus <> fnd_api.g_ret_sts_success) THEN
              retcode := 2;
              IF (lnMsgCount = 1) THEN
                errbuf := lvMsgData;
              ELSE
                errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

       END LOOP;
       CLOSE cur_adv_to_add;
      END IF;


      END IF; --       IF (grp_rec.advisor_group_id IS NOT NULL) THEN

      --
      -- Check if the Student group id is null or not
      -- if it is not null the proceed with  removing the suggested Students
      --

      IF (grp_rec.student_group_id IS NOT NULL) THEN
      --
      -- Loop through all the students who are suggested to be removed
      --
      IF l_std_is_filename_null = 'N' THEN
        l_dyn_std_to_del :=
               l_dyn_std_to_del
            || igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
                 grp_rec.student_group_id,
                 l_status
               );
        IF l_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
          fnd_msg_pub.ADD;
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          RAISE fnd_api.g_exc_error;
        END IF;
        OPEN cur_std_to_del FOR l_dyn_std_to_del USING grp_rec.group_name;
      ELSE
        OPEN cur_std_to_del FOR l_stc_std_to_del
          USING grp_rec.group_name, grp_rec.student_group_id;
      END IF;
      LOOP
        FETCH cur_std_to_del INTO l_person_id;
        EXIT WHEN cur_std_to_del%NOTFOUND;
        --
        -- Update the count to be printed in log file
        --
        lnDelStudents := lnDelStudents + 1;
        --
        -- Make a call to the procedure to update the students with values for auto accept and end datesproperly
        --
        end_date_student (grp_rec.group_name, l_person_id, SYSDATE, 'C');
      END LOOP; --cur_std_to_del
      CLOSE cur_std_to_del;
      END IF; --     IF (grp_rec.student_group_id IS NOT NULL) THEN

      --
      -- Check if the advisor group id is null or not
      -- if it is not null the proceed with removing the suggested advisors
      --

      IF (grp_rec.advisor_group_id IS NOT NULL) THEN

      --
      -- Loop through all the advisors  who are suggested to be removed
      --
      IF l_adv_is_filename_null = 'N' THEN
        l_dyn_adv_to_del :=
               l_dyn_adv_to_del
            || igs_pe_dynamic_persid_group.igs_get_dynamic_sql (
                 grp_rec.advisor_group_id,
                 l_status
               );
        IF l_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name ('IGS', 'IGS_AZ_DYN_PERS_ID_GRP_ERR');
          fnd_msg_pub.ADD;
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          RAISE fnd_api.g_exc_error;
        END IF;
        OPEN cur_adv_to_del FOR l_dyn_adv_to_del USING grp_rec.group_name;
      ELSE
        OPEN cur_adv_to_del FOR l_stc_adv_to_del
          USING grp_rec.group_name, grp_rec.advisor_group_id;
      END IF;
      LOOP
        FETCH cur_adv_to_del INTO l_person_id;
        EXIT WHEN cur_adv_to_del%NOTFOUND;
        --
        -- Update the count to be printed in log file
        --
        lnDelAdvisors := lnDelAdvisors + 1;
        --
        -- Make a call to the procedure to update the Advisors with values for auto accept and end datesproperly
        --
        end_date_advisor (grp_rec.group_name, l_person_id, SYSDATE, 'C');
      END LOOP; --cur_adv_to_del
      CLOSE cur_adv_to_del;

      END IF ;--     IF (grp_rec.advisor_group_id IS NOT NULL) THEN

      --
      -- See if the match is to be provided for the Students and the advisors.
      --
      IF lvAutoMatchInd = 'Y' THEN
        assign_students_to_advisors (
          grp_rec.group_name,
          lnSuggestedMatches,
          SYSDATE
        );
      END IF;
      --
      -- Print the Statistics in the log file:
      --
      fnd_file.put_line (fnd_file.log, lnGrpCount || '. ' || grp_rec.group_name || ' - ' || grp_rec.group_desc);
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_SUG_STU_ADD');
      fnd_message.set_token ('ADDSTU', lnAddedStudents);
      fnd_message.set_token ('AUTOSTD', lvAutoStdAddInd);
      fnd_file.put_line (fnd_file.log, '  o ' || fnd_message.get);
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_SUG_STU_REM');
      fnd_message.set_token ('DELSTU', lnDelStudents);
      fnd_message.set_token ('AUTOST', lvAutoStdDelInd);
      fnd_file.put_line (fnd_file.log, '  o ' || fnd_message.get);
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_SUG_ADV_ADD');
      fnd_message.set_token ('ADDADV', lnAddedAdvisors);
      fnd_message.set_token ('AUTOADV', lvAutoAdvAddInd);
      fnd_file.put_line (fnd_file.log, '  o ' || fnd_message.get);
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_SUG_ADV_REM');
      fnd_message.set_token ('DELADV', lnDelAdvisors);
      fnd_message.set_token ('AUTOADV', lvAutoAdvDelInd);
      fnd_file.put_line (fnd_file.log, '  o ' || fnd_message.get);
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_SUG_MATCH');
      fnd_message.set_token ('SUGGMAT', lnSuggestedMatches);
      fnd_message.set_token ('AUTOMAT', lvAutoMatchInd);
      fnd_file.put_line (fnd_file.log, '  o ' || fnd_message.get);
      fnd_file.put_line (fnd_file.log, '');
      --
      -- See if the auto notification parameter is passed as Yes
      --
      IF (p_notify = 'Y') THEN
        --
        -- Make a call to send notification as group name as parameter.
        --
        send_notification (
          errbuf                         => lvcNotifErbuf,
          retcode                        => lvNotifrtcode,
          p_group_name                   => grp_rec.group_name
        );
        --
        -- to do error handling and loggin
        --
      END IF; -- End Notify
      --
      -- See if the auto apply hold is passed as Yes
      -- If Y then call the procedure to Apply the hold also see if the
      -- advising group has a default advising hold defined.
      --
      IF ((p_apply_hold = 'Y' OR
           grp_rec.auto_apply_hold_flag = 'Y') AND
           grp_rec.advising_hold_type IS NOT NULL) THEN
        apply_hold (
          errbuf                         => lvcApplHldErbuf,
          retcode                        => lvApplHldrtcode,
          p_group_name                   => grp_rec.group_name,
	  p_notify			 => p_notify
        );
        --
        -- to do error handling and loggin
        --
      END IF; -- End Apply Hold
      --
      -- Now update the IGS_AZ_GROUPS table for last_auto_refres_dt with SYSDATE.
      --
      igs_az_groups_pkg.update_row (
        x_rowid                        => grp_rec.row_id,
        x_group_name                   => grp_rec.group_name,
        x_group_desc                   => grp_rec.group_desc,
        x_advising_code                => grp_rec.advising_code,
        x_resp_org_unit_cd             => grp_rec.resp_org_unit_cd,
        x_resp_person_id               => grp_rec.resp_person_id,
        x_location_cd                  => grp_rec.location_cd,
        x_delivery_method_code         => grp_rec.delivery_method_code,
        x_advisor_group_id             => grp_rec.advisor_group_id,
        x_student_group_id             => grp_rec.student_group_id,
        x_default_advisor_load_num     => grp_rec.default_advisor_load_num,
        x_mandatory_flag               => grp_rec.mandatory_flag,
        x_advising_sessions_num        => grp_rec.advising_sessions_num,
        x_advising_hold_type           => grp_rec.advising_hold_type,
        x_closed_flag                  => grp_rec.closed_flag,
        x_comments_txt                 => grp_rec.comments_txt,
        x_auto_refresh_flag            => grp_rec.auto_refresh_flag,
        x_last_auto_refresh_date       => SYSDATE, -- only change.
        x_auto_stdnt_add_flag          => grp_rec.auto_stdnt_add_flag,
        x_auto_stdnt_remove_flag       => grp_rec.auto_stdnt_remove_flag,
        x_auto_advisor_add_flag        => grp_rec.auto_advisor_add_flag,
        x_auto_advisor_remove_flag     => grp_rec.auto_advisor_remove_flag,
        x_auto_match_flag              => grp_rec.auto_match_flag,
        x_auto_apply_hold_flag         => grp_rec.auto_apply_hold_flag,
        x_attribute_category           => grp_rec.attribute_category,
        x_attribute1                   => grp_rec.attribute1,
        x_attribute2                   => grp_rec.attribute2,
        x_attribute3                   => grp_rec.attribute3,
        x_attribute4                   => grp_rec.attribute4,
        x_attribute5                   => grp_rec.attribute5,
        x_attribute6                   => grp_rec.attribute6,
        x_attribute7                   => grp_rec.attribute7,
        x_attribute8                   => grp_rec.attribute8,
        x_attribute9                   => grp_rec.attribute9,
        x_attribute10                  => grp_rec.attribute10,
        x_attribute11                  => grp_rec.attribute11,
        x_attribute12                  => grp_rec.attribute12,
        x_attribute13                  => grp_rec.attribute13,
        x_attribute14                  => grp_rec.attribute14,
        x_attribute15                  => grp_rec.attribute15,
        x_attribute16                  => grp_rec.attribute16,
        x_attribute17                  => grp_rec.attribute17,
        x_attribute18                  => grp_rec.attribute18,
        x_attribute19                  => grp_rec.attribute19,
        x_attribute20                  => grp_rec.attribute20, --To Do --see if the following three parameters are required.
        x_return_status                => lvReturnStatus,
        x_msg_data                     => lvMsgData,
        x_msg_count                    => lnMsgCount
      );
    END LOOP; -- main
    fnd_message.set_name ('IGS', 'IGS_AD_TOT_REC_PRC');
    fnd_message.set_token ('RCOUNT', lnGrpCount);
    fnd_file.put_line (fnd_file.log, fnd_message.get);
    fnd_file.put_line (fnd_file.log, '');
    --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
      retcode := 2;
      ROLLBACK TO s_maintain_groups;
    --
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'IGS_AZ_GEN_001.Maintain_group : ' || SUBSTR (SQLERRM, 80));
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => lnMsgCount,
        p_data  => lvMsgData
      );
      ROLLBACK TO s_maintain_groups ;
    --
  END maintain_groups;
  --
  --
  --
  PROCEDURE assign_students_to_advisors (
    p_group_name                   IN VARCHAR2,
    p_n_processed                  OUT NOCOPY NUMBER,
    p_start_date                   IN DATE DEFAULT NULL
  ) AS
    --
    lnProcessed NUMBER := 0;
    --
    -- Select all the students who need to be assigned to an advisor
    --
    -- Cursor to detremine whether Match is to start dated automatically:
    --
    CURSOR auto_match_cur IS
      SELECT   auto_match_flag
      FROM     igs_az_groups
      WHERE    group_name = p_group_name;
    --
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_students_to_match IS
      SELECT   stu.group_student_id,
               stu.end_date
      FROM     igs_az_students stu
      WHERE    TRUNC (stu.start_date) <= TRUNC (SYSDATE)
      AND      NVL (stu.end_date, SYSDATE + 1) > SYSDATE
      AND      stu.group_name = p_group_name
      AND NOT EXISTS
              (SELECT   1
               FROM     igs_az_advising_rels rel
               WHERE    rel.group_name = p_group_name
               AND      rel.group_student_id = stu.group_student_id);
    --
    -- Select the advisor details for allocating the student
    --
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_advisors_to_load IS
      SELECT   adv.group_advisor_id,
               adv.end_date,
               adv.max_students_num maximum_load,
               NVL (rel.actual_load, 0) actual_load,
               NVL (rel.actual_load, 0) / NVL (adv.max_students_num, 1) percent_load
      FROM     igs_az_advisors adv, (SELECT   group_advisor_id,
                                              COUNT(*) actual_load
                                     FROM     igs_az_advising_rels
                                     WHERE    group_name = p_group_name
                                     GROUP BY group_advisor_id) rel
      WHERE    adv.start_date IS NOT NULL
      AND      TRUNC (adv.start_date) <= TRUNC (SYSDATE)
      AND      NVL (adv.end_date, SYSDATE + 1) > SYSDATE
      AND      adv.group_name = p_group_name
      AND      rel.group_advisor_id (+) = adv.group_advisor_id
      ORDER BY percent_load;
    --
    -- Cursor to find the count  the number of students
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_find_count IS
      SELECT   COUNT (group_student_id)
      FROM     igs_az_students st
      WHERE    TRUNC (start_date) <= SYSDATE
      AND      NVL (end_date, SYSDATE + 1) > SYSDATE
      AND      group_name = p_group_name
      AND NOT EXISTS
              (SELECT   1
               FROM     igs_az_advising_rels rel
               WHERE    group_name = p_group_name
               AND      rel.group_student_id = st.group_student_id);
    --
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_max_stu_num IS
      SELECT   SUM (max_students_num)
      FROM     igs_az_advisors
      WHERE    TRUNC (start_date) <= TRUNC (SYSDATE)
      AND      NVL (end_date, SYSDATE + 1) > SYSDATE
      AND      group_name = p_group_name;
    --
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_tot_act_load IS
      SELECT   COUNT (*)
      FROM     igs_az_advising_rels rel
      WHERE    group_name = p_group_name
      AND EXISTS
              (SELECT   1
               FROM     igs_az_advisors adv
               WHERE    rel.group_advisor_id = adv.group_advisor_id
               AND      TRUNC (adv.start_date) <= TRUNC (SYSDATE)
               AND      NVL (adv.end_date, SYSDATE + 1) > SYSDATE
               AND      adv.group_name = p_group_name);
    --
    -- Declare local variables
    --
    rec_advisors_to_load cur_advisors_to_load%ROWTYPE;
    numberOfStudentsToProcess NUMBER;
    totalActualLoad NUMBER;
    totalMaximumLoad NUMBER;
    desiredLoadPercentage NUMBER;
    lv_rowid VARCHAR2(25);
    l_group_advising_rel_id igs_az_advising_rels.group_advising_rel_id%TYPE;
    ldRelEndDate  DATE;
    ldRelStartDate DATE;
    lvcReturnStatus VARCHAR2(10);
    lvcMsgData  VARCHAR2(2000);
    lnMsgCount NUMBER;
    lvCAutoMatch Varchar2(1) := 'N';
    --
  BEGIN
    --
    fnd_msg_pub.initialize;
    --
    -- Get Auto match indicator
    --
    OPEN auto_match_cur;
    FETCH auto_match_cur INTO lvCAutoMatch;
    CLOSE auto_match_cur;
    --
    IF (lvCAutoMatch = 'Y' AND
        p_start_date IS NULL)  THEN
      ldRelStartDate := SYSDATE;
    ELSE
      ldRelStartDate := p_start_date;
    END IF;
    --
    -- Get the Total Number of Students who need to be assigned to the Advisor
    --
    OPEN cur_find_count;
    FETCH cur_find_count INTO numberOfStudentsToProcess;
    CLOSE cur_find_count;
    --
    -- Get the Sum of Maximum Load of the Advisors in the group
    --
    OPEN cur_max_stu_num;
    FETCH cur_max_stu_num INTO totalMaximumLoad;
    CLOSE cur_max_stu_num;
    --
    -- Get the Sum of Actual Loads of the Advisors in the group
    --
    OPEN cur_tot_act_load;
    FETCH cur_tot_act_load INTO totalActualLoad;
    CLOSE cur_tot_act_load;
    --
    -- Calculate the Desired Load Percentage
    --
    desiredLoadPercentage := (numberOfStudentsToProcess +
                              NVL (totalActualLoad, 0)) / NVL (totalMaximumLoad, 1);
    --
    -- Assign Advisors to the Students
    --
    lnProcessed := 0;
    FOR rec_students_to_match IN cur_students_to_match LOOP
      --
      OPEN cur_advisors_to_load;
      FETCH cur_advisors_to_load INTO rec_advisors_to_load;
      IF (cur_advisors_to_load%FOUND) THEN
        IF ((NVL (rec_advisors_to_load.actual_load, 0) /
             NVL (rec_advisors_to_load.maximum_load, 1)) < desiredLoadPercentage) AND
             (rec_advisors_to_load.maximum_load > rec_advisors_to_load.actual_load) THEN
          --
          -- Determine the end date of relationship.
          -- If student or advisor is end dated then the end date will be the earilest of the two
          -- else the end date of relationship will be null;
          --
          IF (rec_students_to_match.end_date IS NULL AND
              rec_advisors_to_load.end_date IS NULL) THEN
            ldRelEndDate := NULL;
          ELSE
            IF (rec_students_to_match.end_date >= rec_advisors_to_load.end_date) THEN
              ldRelEndDate := rec_advisors_to_load.end_date;
            ELSE
              ldRelEndDate := rec_students_to_match.end_date;
            END IF;
          END IF;
          --
          -- increment the count of statistics by 1
          --
          lnProcessed := lnProcessed +1;
          --
          -- Add Student to the Relationship table with the current Advisor
          --
          igs_az_advising_rels_pkg.insert_row (
            x_rowid                        => lv_rowid,
            x_group_advising_rel_id        => l_group_advising_rel_id,
            x_group_name                   => p_group_name,
            x_group_advisor_id             => rec_advisors_to_load.group_advisor_id,
            x_group_student_id             => rec_students_to_match.group_student_id,
            x_start_date                   => ldRelStartDate,
            x_end_date                     => ldRelEndDate,
            x_return_status                => lvcReturnStatus,
            x_msg_data                     => lvcMsgData,
            x_msg_count                    => lnMsgCount
          );
          --
          -- To do See if we have to add ret status, msg_count ad msg_data to th eparameter list
          --
        END IF;
      END IF;
      CLOSE cur_advisors_to_load;
    END LOOP;
    --
    p_n_processed := lnProcessed;
    --
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'ASSIGN_STUDENTS_TO_ADVISORS : ' || SUBSTR (SQLERRM, 80));
      fnd_msg_pub.add;
      RETURN;
  END assign_students_to_advisors;
  --
  --
  --  swaghmar 06-Jun-2006 Bug# 5283309, Added new message IGS_AZ_STU_LIST_HOLD_APPLIED
  --				instead of IGS_AZ_STU_LIST_ADD
  --
  PROCEDURE apply_hold (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY VARCHAR2,
    p_group_name                   IN VARCHAR2 DEFAULT NULL,
     p_notify                     IN  VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    -- Cursor to get the hold Type defined for the group
    --
    CURSOR cur_hold_Type IS
      SELECT   advising_hold_type
      FROM     igs_az_groups
      WHERE    group_name = p_group_name;
    --
    -- Cursor to get all the default hold effect associated with the Hold Type
    --
    CURSOR cur_hold_effect (cp_hold_type VARCHAR2) IS
      SELECT   s_encmb_effect_type
      FROM     igs_fi_enc_dflt_eft
      WHERE    encumbrance_type = cp_hold_type;
    --
    -- Cursor to select all the students who are to applyed the hold. This will contain all the students who are in the group and have
    -- not been applied with any hold as part of this group
    --
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_appl_hld_std (cp_group_name VARCHAR2, cp_hold_type VARCHAR2) IS
    SELECT   azs.ROWID row_id,
             azs.*,
             p.party_number,
             p.party_name
    FROM     igs_az_students azs ,
             hz_parties p
    WHERE    azs.group_name = cp_group_name
    AND      azs.advising_hold_type IS NULL
    AND      azs.hold_start_date  IS NULL
    AND      azs.start_date IS NOT NULL
    AND      TRUNC (azs.start_date) <= TRUNC (SYSDATE)
    AND      NVL (azs.end_date, TRUNC (SYSDATE+1)) > TRUNC (SYSDATE)
    AND      p.party_id = azs.student_person_id;
    --
    -- Cursor to generate new sequence number
    --
    CURSOR cur_seq_num IS
    SELECT   igs_pe_persenc_effct_seq_num_s.NEXTVAL
    FROM     dual;
    --
    -- Cursor to check if the Hold already existes for the Student
    --
    CURSOR cur_stu_encumb (
             cp_encumbrance_type igs_pe_pers_encumb.encumbrance_type%TYPE,
             cp_person_id hz_parties.party_id%TYPE) IS
      SELECT   encumbrance_type,
               start_dt
      FROM     igs_pe_pers_encumb
      WHERE    encumbrance_type = cp_encumbrance_type
      AND      person_id = cp_person_id
      AND      TRUNC (start_dt) <= TRUNC (SYSDATE)
      AND      NVL (expiry_dt, SYSDATE) >= SYSDATE;
    --
    --
    --
    CURSOR cur_az_holds_upd (
             cp_student_person_id igs_az_students.student_person_id%TYPE,
             cp_group_name igs_az_students.group_name%TYPE) IS
      SELECT   start_date
      FROM     igs_az_students
      WHERE    student_person_id = cp_student_person_id
      AND      group_name = cp_group_name;
    --
    -- Local Variables here
    --
    lvcHoldType VARCHAR2(30);
    lvHoldRowID VARCHAR2(25);
    lvHoldEfctRowID VARCHAR2(25);
    lvEncefctRowID VARCHAR2(25);
    ldHldStrtDt DATE := TRUNC (SYSDATE);
    ldHldEfctStrtDt DATE := TRUNC (SYSDATE);
    lnpeeseqnum NUMBER;
    lvReturnStatus VARCHAR2(1);
    lvMsgData VARCHAR2(100);
    lnMsgCount NUMBER;
    lvcHoldPersonIds VARCHAR2(32767); -- Variable to hold the comma separated person IDs of the students who are going to be applied advising hold. Will be used in sending the notification.
    lvcHoldMsgSubject fnd_new_messages.message_text%TYPE;
    lvcHoldMsgText fnd_new_messages.message_text%TYPE;
    lvnHoldExixts NUMBER;
    lvEncumbranceType igs_pe_pers_encumb.encumbrance_type%TYPE;
    lvEncmbTypeStartDt igs_pe_pers_encumb.start_dt%TYPE;
    l_cur_az_holds_upd cur_az_holds_upd%ROWTYPE;
    --
  BEGIN
    --
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    fnd_msg_pub.initialize;
    --
    OPEN cur_hold_Type;
    FETCH cur_hold_Type INTO lvcHoldType;
    CLOSE cur_hold_Type;
    --
    -- If Hold Type is not defined do nothing  and return success
    --
    IF (lvcHoldType IS NULL) THEN
      errbuf := NULL;
      retcode := 0;
      RETURN;
    END IF;
    --
    -- If there is some hold type associated with the group then
    --
    -- Loop through all the students who need to be applied Hold
    -- initialize the personIds to null;
    --
    lvcHoldPersonIds := NULL;
    --
    -- Set the token and get the message which will be used as subject for the hold notification.
    --
    fnd_message.set_name ('IGS', 'IGS_AZ_HOLD_NOTIF_SUBJECT'); -- Bug# 5283309
    fnd_message.set_token ('GROUP_NAME', p_group_name);
    lvcHoldMsgSubject := fnd_message.get;
    --
    -- Clear the message buffer now
    --
    fnd_msg_pub.initialize;
    --
    FOR std_rec IN cur_appl_hld_std (p_group_name, lvcHoldType) LOOP
      --
      IF (cur_appl_hld_std%ROWCOUNT = 1) THEN
        -- Put the entry in the log file for the students who are being put on advising hold...
        fnd_message.set_name ('IGS', 'IGS_AZ_STU_LIST_HOLD_APPLIED');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
      --
      -- 1. Create a record in table IGS_PE_PERS_ENCUMB
      --
      -- Concatenate the person Ids for sending the notification:
      --
      lvcHoldPersonIds := lvcHoldPersonIds || ',' || std_rec.student_person_id; -- To do See here I am using student_person_id inplace of group_student_ID(seq gen PK) as mentioned in FD.
      ldHldStrtDt := TRUNC(SYSDATE);
      --
      lvEncumbranceType := NULL;
      lvEncmbTypeStartDt := NULL;
      OPEN cur_stu_encumb (lvcHoldType, std_rec.student_person_id);
      FETCH cur_stu_encumb INTO lvEncumbranceType, lvEncmbTypeStartDt;
      CLOSE cur_stu_encumb;
      --
      IF (lvEncumbranceType IS NULL) THEN
        --
        igs_pe_pers_encumb_pkg.insert_row (
          x_rowid                        => lvHoldRowID,
          x_person_id                    => std_rec.student_person_id,
          x_encumbrance_type             => lvcHoldType,
          x_start_dt                     => ldHldStrtDt,
          x_expiry_dt                    => NULL,
          x_authorising_person_id        => NULL, -- To do .. Look how this can be populated
          x_comments                     => NULL, -- See if we can use some  message here.
          x_spo_course_cd                => NULL,
          x_spo_sequence_number          => NULL,
          x_cal_type                     => NULL,
          x_sequence_number              => NULL,
          x_auth_resp_id                 => NULL,
          x_external_reference           => NULL
        );
        --
        -- 2. Loop through all the Default hold effects for the hold type and Create a record in Table IGS_PE_PERSENC_EFFCT
        --
        FOR HldEfct_rec IN cur_hold_effect (lvcHoldType) LOOP
          --
          -- Get the sequnce number from the sequence
          --
          OPEN cur_seq_num;
          FETCH cur_seq_num INTO lnpeeseqnum;
          CLOSE cur_seq_num;
          --
          igs_pe_persenc_effct_pkg.insert_row (
            x_rowid                        => lvHoldEfctRowID,
            x_person_id                    => std_rec.student_person_id,
            x_encumbrance_type             => lvcHoldType,
            x_pen_start_dt                 => ldHldStrtDt,
            x_s_encmb_effect_type          => HldEfct_rec.s_encmb_effect_type,
            x_pee_start_dt                 => ldHldEfctStrtDt,
            x_sequence_number              => lnpeeseqnum,
            x_expiry_dt                    => NULL,
            x_course_cd                    => NULL,
            x_restricted_enrolment_cp      => NULL,
            x_restricted_attendance_type   => NULL
          );
          --
        END LOOP; --HldEfct_rec
      ELSE
        --
        OPEN cur_az_holds_upd(std_rec.student_person_id,std_rec.group_name);
        FETCH cur_az_holds_upd INTO l_cur_az_holds_upd;
        CLOSE cur_az_holds_upd;
        --
        ldHldStrtDt := lvEncmbTypeStartDt;
        --
      END IF;
      --
      -- Now update the advising student table with the HOLD_APPLIED and start Date.
      --
      igs_az_students_pkg.update_row (
        x_rowid                        => std_rec.row_id,
        x_group_student_id             => std_rec.group_student_id,
        x_group_name                   => std_rec.group_name,
        x_student_person_id            => std_rec.student_person_id,
        x_start_date                   => std_rec.start_date,
        x_end_date                     => std_rec.end_date,
        x_advising_hold_type           => lvcHoldType,
        x_hold_start_date              => ldHldStrtDt,
        x_notified_date                => std_rec.notified_date,
        x_accept_add_flag              => std_rec.accept_add_flag,
        x_accept_delete_flag           => std_rec.accept_delete_flag ,
        x_return_status                => lvReturnStatus,
        x_msg_data                     => lvMsgData,
        x_msg_count                    => lnMsgCount
      );
      --
      -- Put in the log the info about student being put on hold..
      --
      fnd_file.put_line (fnd_file.log, '       ' || std_rec.party_number || ' -  ' || std_rec.party_name) ;
      --
    END LOOP; --std_rec
    --
    -- Get the first comma from the comma separated list of person IDs.
    --
    lvcHoldPersonIds := SUBSTR (lvcHoldPersonIds, INSTR (lvcHoldPersonIds, ',' ) + 1);
    --
    -- Now send the notification to all the students who have been applied with advising hold..
    --
    IF (NVL (LENGTH (lvcHoldPersonIds), 0) > 0) THEN
      --
      -- Get the message text to be sent to the student for being added to the group.
      --
      fnd_message.set_name ('IGS', 'IGS_AZ_HOLD_NOTIF_TEXT');
      fnd_message.set_token ('GROUP_NAME', p_group_name);
      fnd_message.set_token ('START_DATE', TO_CHAR (SYSDATE, 'DD-MON-RRRR'));
      --
      lvcHoldMsgText := fnd_message.get;
      --
      -- Once u get the message text in a local variable initialize the message stack
      --
      fnd_msg_pub.initialize;


    IF (p_notify = 'Y') THEN

      notify_person (
        p_busevent                     => 'oracle.apps.igs.az.ntfyhold', -- to do --Verify this with final case and seed.
        p_param_name1                  => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
        p_param_value1                 => lvcHoldPersonIds,
        p_param_name2                  => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
        p_param_value2                 => lvcHoldMsgSubject,
        p_param_name3                  => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
        p_param_value3                 => lvcHoldMsgText
      );

    END IF;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false);
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'IGS_AZ_GEN_001.Apply_hold : ' || SUBSTR (SQLERRM, 80));
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get (
        p_encoded                      => fnd_api.g_false,
        p_count                        => lnMsgCount,
        p_data                         => lvMsgData
      );
      RETURN;
  END apply_hold;
  --
  --
  --
  PROCEDURE send_notification(
    errbuf       OUT NOCOPY    VARCHAR2,
    retcode      OUT NOCOPY    VARCHAR2,
    p_group_name IN            VARCHAR2 DEFAULT NULL) IS
    --
    -- 1. For students
    --   a. Notify the student who have been added to the group and not yet sent the notification
    --   b. Notify the students who have been removed from the group and not yet sent the notification.
    --  a.-- ---------
    --
    -- Cursor to get all the newly added students.
    --
    CURSOR cur_std_add IS
      SELECT azs.ROWID AS row_id,
             azs.*,
             p.party_number,
             p.party_name
        FROM igs_az_students azs, hz_parties p
       WHERE azs.group_name = p_group_name
         AND azs.accept_add_flag = 'Y'
         AND azs.start_date IS NOT NULL
         AND azs.end_date IS NULL
         AND azs.notified_date IS NULL
         AND p.party_id = azs.student_person_id;
    --
    -- Cursor to get all the students who are removed from the group.
    --
    CURSOR cur_std_del IS
      SELECT azs.ROWID AS row_id,
             azs.*,
             p.party_number,
             p.party_name
        FROM igs_az_students azs, hz_parties p
       WHERE azs.group_name = p_group_name
         AND azs.accept_add_flag = 'Y'
         AND azs.notified_date IS NULL
         AND azs.start_date IS NOT NULL
         AND azs.end_date IS NOT NULL
         AND p.party_id = azs.student_person_id;
    --
    -- Cursor to get all the newly added advisors.
    --
    CURSOR cur_adv_add IS
      SELECT aza.ROWID AS row_id,
             aza.*,
             p.party_number,
             p.party_name
        FROM igs_az_advisors aza, igs_az_groups azg, hz_parties p
       WHERE aza.group_name = p_group_name
         AND aza.accept_add_flag = 'Y'
         AND aza.start_date IS NOT NULL
         AND aza.end_date IS NULL
         AND aza.notified_date IS NULL
         AND azg.group_name = aza.group_name
         AND azg.delivery_method_code <>
                                        'SELF' -- To do look for exact lookup code
         AND p.party_id = aza.advisor_person_id;
    --
    -- Cursor to get all the advisors who are removed from the group.
    --
    CURSOR cur_adv_del IS
      SELECT aza.ROWID AS row_id,
             aza.*,
             p.party_number,
             p.party_name
        FROM igs_az_advisors aza, igs_az_groups azg, hz_parties p
       WHERE aza.group_name = p_group_name
         AND aza.accept_add_flag = 'Y'
         AND aza.start_date IS NOT NULL
         AND aza.notified_date IS NULL
         AND aza.end_date IS NOT NULL
         AND azg.group_name = aza.group_name
         AND azg.delivery_method_code <>
                                        'SELF' -- To do look for exact lookup code
         AND p.party_id = aza.advisor_person_id;
    --
    -- Declare Local varaibles to be used ..
    --
    lvcmsgsubject  VARCHAR2(2000);
    lvcmsgtext     VARCHAR2(20000);
    lvcpersonids   VARCHAR2(32767); -- Variable to store the comma separated Person IDs. Which will be passed for notificataion.
    --
    -- The workflow in turn will call the procedure igs_as_notify_student.wf_set_role to add these students to
    -- the role to which the notification will be sent.
    --
    lvReturnStatus VARCHAR2(10);
    lvMsgData      VARCHAR2(2000);
    lnMsgCount     NUMBER;
    lncount        NUMBER          := 0;
    --
  BEGIN
    --
    -- Get the Default  message subject. This can be got from FND_NEW_MESSAGES table. PLacing here before any loop because subject remains same for
    -- all kinds of advising notification. (Message IGS_AZ_NOTIF_SUBJECT Token Group name ).
    --
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    fnd_message.set_name('IGS', 'IGS_AZ_NOTIF_SUBJECT');
    fnd_message.set_token('GROUP_NAME', p_group_name);
    lvcmsgsubject := fnd_message.get;
    --
    -- Once u get the message text in a local variable initialize the message stack
    --
    fnd_msg_pub.initialize;
    --
    -- Now u start .. 1. For newly added students:
    -- Get the message text to be sent to the student for being added to the group.
    --
    fnd_message.set_name('IGS', 'IGS_AZ_NOTIF_TEXT');
    fnd_message.set_token('GROUP_NAME', p_group_name);
    fnd_message.set_token('ADDED_REMOVED ', ' assigned to');
    fnd_message.set_token('NOTIF_DATE', TO_CHAR(SYSDATE, 'DD-MON-YY'));
    lvcmsgtext := fnd_message.get;
    --
    -- Once u get the message text in a local variable initialize the message stack
    --
    fnd_msg_pub.initialize;
    --
    FOR add_std_rec IN cur_std_add LOOP
      IF (cur_std_add%ROWCOUNT = 1) THEN
        --
        -- Log that u are going to start the notification for the students being added
        --
        fnd_message.set_name('IGS', 'IGS_AZ_STU_LIST_ADD');
        fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      END IF;
      --
      -- Now since the student is slated to be notified, updated the IGS_AZ_STUDENTS table with NOTIFIED_DATE = sysdate.
      --
      igs_az_students_pkg.update_row(
        x_rowid                       => add_std_rec.row_id,
        x_group_student_id            => add_std_rec.group_student_id,
        x_group_name                  => add_std_rec.group_name,
        x_student_person_id           => add_std_rec.student_person_id,
        x_start_date                  => add_std_rec.start_date,
        x_end_date                    => add_std_rec.end_date,
        x_advising_hold_type          => add_std_rec.advising_hold_type,
        x_hold_start_date             => add_std_rec.hold_start_date,
        x_notified_date               => SYSDATE,
        x_accept_add_flag             => add_std_rec.accept_add_flag,
        x_accept_delete_flag          => add_std_rec.accept_delete_flag,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
      --
      -- Log that the selected student is notified.
      --
      fnd_file.put_line(
        fnd_file.LOG,
        ' -      ' || add_std_rec.party_number || ' -  ' || add_std_rec.party_name);
      lvcpersonids := lvcpersonids || ',' || add_std_rec.student_person_id;
      lncount := lncount + 1;
      --
      -- The event  oracle.apps.igs.az.ntfystud would be raised for every hundred students
      -- This is to avoid buffer overflow.
      -- Please don't change the code.
      --
      IF (MOD(lncount, 100) = 0) THEN
        lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
        notify_person(
          p_busevent                    => 'oracle.apps.igs.az.ntfystud', -- to do --Verify this with final case and seed.
          p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
          p_param_value1                => lvcpersonids,
          p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
          p_param_value2                => lvcmsgsubject,
          p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
          p_param_value3                => lvcmsgtext
        );
        lvcpersonids := NULL;
      END IF;
    END LOOP;
    --
    -- Now we have all the student Ids.. concatenated. Lets strip the first comma  and then send the notification.
    --
    lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
    --
    -- The event  oracle.apps.igs.az.ntfystud would be raised for every hundred students
    -- This is to avoid buffer overflow.
    -- In the code given above the event would be raised for every 100 person, if the number of students are like 231, 202
    -- then the notification would not go to 31 , 2 students resp. So the code below is requied to send the notifications all the students.
    --
    IF NVL(LENGTH(lvcpersonids), 0) > 0 THEN
      notify_person(
        p_busevent                    => 'oracle.apps.igs.az.ntfystud', -- to do --Verify this with final case and seed.
        p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
        p_param_value1                => lvcpersonids,
        p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
        p_param_value2                => lvcmsgsubject,
        p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
        p_param_value3                => lvcmsgtext
      );
    END IF; -- Some  student selected for group add notification.
    --
    -- Agian initialize the personIdlist before trying to send next notification.
    --
    lvcpersonids := NULL;
    lncount := 0;
    lvReturnStatus := NULL;
    lvMsgData := NULL;
    lnMsgCount := NULL;
    --
    -- Send notification to the student who are removed from the group.
    -- Log that u are going to start the notification for the students being rmoved from the group
    --
    fnd_message.set_name('IGS', 'IGS_AZ_STU_LIST_DEL');
    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    --
    -- Get the message text to be sent to the student for being added to the group.
    --
    fnd_message.set_name('IGS', 'IGS_AZ_NOTIF_TEXT');
    fnd_message.set_token('GROUP_NAME', p_group_name);
    fnd_message.set_token('ADDED_REMOVED ', ' removed from');
    fnd_message.set_token('NOTIF_DATE', TO_CHAR(SYSDATE, 'DD-MON-YY'));
    lvcmsgtext := fnd_message.get;
    --
    -- Once u get the message text in a local variable initialize the message stack
    --
    fnd_msg_pub.initialize;
    --
    FOR del_std_rec IN cur_std_del LOOP
      --
      -- Now since the student is slated to be notified. updated the IGS_AZ_STUDENTS table with NOTIFIED_DATE = sysdate.
      --
      igs_az_students_pkg.update_row(
        x_rowid                       => del_std_rec.row_id,
        x_group_student_id            => del_std_rec.group_student_id,
        x_group_name                  => del_std_rec.group_name,
        x_student_person_id           => del_std_rec.student_person_id,
        x_start_date                  => del_std_rec.start_date,
        x_end_date                    => del_std_rec.end_date,
        x_advising_hold_type          => del_std_rec.advising_hold_type,
        x_hold_start_date             => del_std_rec.hold_start_date,
        x_notified_date               => SYSDATE,
        x_accept_add_flag             => del_std_rec.accept_add_flag,
        x_accept_delete_flag          => del_std_rec.accept_delete_flag,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
      --
      -- Log that the selected student is removed from the group.
      --
      fnd_file.put_line(
        fnd_file.LOG,
        ' -     ' || del_std_rec.party_number || ' -  ' || del_std_rec.party_name);
      --
      lncount := lncount + 1;
      lvcpersonids := lvcpersonids || ',' || del_std_rec.student_person_id;
      --
      -- The event  oracle.apps.igs.az.ntfystud would be raised for every hundred students
      -- This is to avoid buffer overflow.
      -- Please don't change the code.
      --
      IF (MOD(lncount, 100) = 0) THEN
        lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
        notify_person(
          p_busevent                    => 'oracle.apps.igs.az.ntfystud', -- to do --Verify this with final case and seed.
          p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
          p_param_value1                => lvcpersonids,
          p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
          p_param_value2                => lvcmsgsubject,
          p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
          p_param_value3                => lvcmsgtext
        );
        lvcpersonids := NULL;
      END IF;
    END LOOP;
    --
    -- Now we have all the student Ids.. concatenated. Lets strip the first comma  and then send the notification.
    --
    lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
    --
    -- The event  oracle.apps.igs.az.ntfystud would be raised for every hundred students
    -- This is to avoid buffer overflow.
    -- In the code given above the event would be raised for every 100 person, if the number of students are like 231, 202
    -- then the notification would not go to 31 , 2 students resp. So the code below is requied to send the notifications all the students.
    --
    IF NVL(LENGTH(lvcpersonids), 0) > 0 THEN
      --
      notify_person(
        p_busevent                    => 'oracle.apps.igs.az.ntfystud', -- to do --Verify this with final case and seed.
        p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
        p_param_value1                => lvcpersonids,
        p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
        p_param_value2                => lvcmsgsubject,
        p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
        p_param_value3                => lvcmsgtext
      );
      --
    END IF; -- Some  student selected for group add notification.
    --
    -- Agian initialize the personIdlist before trying to send next notification.
    --
    lvcpersonids := NULL;
    --
    -- Notify the advisors now:
    --
    -- Log that u are going to start the notification for the advisors being assigned the group
    --
    fnd_message.set_name('IGS', 'IGS_AZ_STU_LIST_NOTIFY_ADD');
    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    --
    FOR add_adv_rec IN cur_adv_add LOOP
      --
      lvcpersonids := lvcpersonids || ',' || add_adv_rec.advisor_person_id; -- To do See here I am using student_person_id inplace of Froup_student_ID(seq gen PK) as mentioned in FD.
      --
      -- Now since the advisor is slated to be notified for being added to the group , updated the IGS_AZ_STUDENTS table with NOTIFIED_DATE = sysdate.
      --
      igs_az_advisors_pkg.update_row(
        x_rowid                       => add_adv_rec.row_id,
        x_group_advisor_id            => add_adv_rec.group_advisor_id,
        x_group_name                  => add_adv_rec.group_name,
        x_advisor_person_id           => add_adv_rec.advisor_person_id,
        x_start_date                  => add_adv_rec.start_date,
        x_end_date                    => add_adv_rec.end_date,
        x_max_students_num            => add_adv_rec.max_students_num,
        x_notified_date               => SYSDATE, -- This is the only change
        x_accept_add_flag             => add_adv_rec.accept_add_flag,
        x_accept_delete_flag          => add_adv_rec.accept_delete_flag, ---To do Follwing three parameters need to be added in the TBH and then uncomment
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
      --
      -- Log that the selected advisor is assigned to the group.
      --
      fnd_file.put_line(
        fnd_file.LOG,
        '     ' || add_adv_rec.party_number || ' -  ' || add_adv_rec.party_name);
    END LOOP;
    --
    -- Now we have all the student Ids.. concatenated. Lets strip the first comma  and then send the notification.
    --
    lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
    --
    -- See if there were any advisor selected in this category.
    --
    IF NVL(LENGTH(lvcpersonids), 0) > 0 THEN
      --
      -- Get the message text to be sent to the student for being added to the group.
      --
      fnd_message.set_name('IGS', 'IGS_AZ_NOTIF_TEXT');
      fnd_message.set_token('GROUP_NAME', p_group_name);
      fnd_message.set_token('ADDED_REMOVED ', ' assigned to');
      fnd_message.set_token('NOTIF_DATE', TO_CHAR(SYSDATE, 'DD-MON-YY'));
      lvcmsgtext := fnd_message.get;
      --
      -- Once u get the message text in a local variable initialize the message stack
      --
      fnd_msg_pub.initialize;
      --
      notify_person(
        p_busevent                    => 'oracle.apps.igs.az.ntfyadvr', -- to do --Verify this with final case and seed.
        p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
        p_param_value1                => lvcpersonids,
        p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
        p_param_value2                => lvcmsgsubject,
        p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
        p_param_value3                => lvcmsgtext
      );
    END IF; -- Some  advisor  selected for group add notification.
    --
    -- Agian initialize the personIdlist before trying to send next notification.
    --
    lvcpersonids := NULL;
    --
    -- Send notification to the advisor who are removed from the group.
    -- Log that u are going to start the notification for the advisors being rmoved from the group
    --
    fnd_message.set_name('IGS', 'IGS_AZ_STU_LIST_NOTIFY_AD_REM');
    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    --
    FOR del_adv_rec IN cur_adv_del LOOP
      --
      -- set the staus, message count etc. back to null so that it is used in the next call
      --
      lvReturnStatus := NULL;
      lvMsgData := NULL;
      lnMsgCount := NULL;
      lvcpersonids := lvcpersonids || ',' || del_adv_rec.advisor_person_id; -- To do See here I am using advisor_person_id inplace of Group_advisor_ID(seq gen PK) as mentioned in FD.
      --
      -- Now since the advisor is slated to be notified about removal from group, updated the IGS_AZ_STUDENTS table with NOTIFIED_DATE = sysdate.
      --
      igs_az_advisors_pkg.update_row(
        x_rowid                       => del_adv_rec.row_id,
        x_group_advisor_id            => del_adv_rec.group_advisor_id,
        x_group_name                  => del_adv_rec.group_name,
        x_advisor_person_id           => del_adv_rec.advisor_person_id,
        x_start_date                  => del_adv_rec.start_date,
        x_end_date                    => del_adv_rec.end_date,
        x_max_students_num            => del_adv_rec.max_students_num,
        x_notified_date               => SYSDATE, -- This is the only change
        x_accept_add_flag             => del_adv_rec.accept_add_flag,
        x_accept_delete_flag          => del_adv_rec.accept_delete_flag, ---To do Follwing three parameters need to be added in the TBH and then uncomment
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
      --
      -- Log that the selected advisor is removed from the group.
      --
      fnd_file.put_line(
        fnd_file.LOG,
        '     ' || del_adv_rec.party_number || ' -  ' || del_adv_rec.party_name);
    END LOOP;
    --
    -- Now we have all the student Ids.. concatenated. Lets strip the first comma  and then send the notification.
    --
    lvcpersonids := SUBSTR(lvcpersonids, INSTR(lvcpersonids, ',') + 1);
    --
    -- See if there were any student selected in this category.
    --
    IF NVL(LENGTH(lvcpersonids), 0) > 0 THEN
      --
      -- Get the message text to be sent to the student for being added to the group.
      --
      fnd_message.set_name('IGS', 'IGS_AZ_NOTIF_TEXT');
      fnd_message.set_token('GROUP_NAME', p_group_name);
      fnd_message.set_token('ADDED_REMOVED ', ' removed from');
      fnd_message.set_token('NOTIF_DATE', TO_CHAR(SYSDATE, 'DD-MON-YY'));
      lvcmsgtext := fnd_message.get;
      --
      -- Once u get the message text in a local variable initialize the message stack
      --
      fnd_msg_pub.initialize;
      --
      notify_person(
        p_busevent                    => 'oracle.apps.igs.az.ntfyadvr', -- to do --Verify this with final case and seed.
        p_param_name1                 => 'IA_USERS', ---this must be defined in workflow as the parameter to this event
        p_param_value1                => lvcpersonids,
        p_param_name2                 => 'IA_SUBJECT', ---this must be defined in workflow as the parameter to this event
        p_param_value2                => lvcmsgsubject,
        p_param_name3                 => 'IA_MESSAGE', -- ---this must be defined in workflow as the parameter to this event
        p_param_value3                => lvcmsgtext
      );
    END IF; -- Some  student selected for group add notification.
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false);
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'NAME',
        'IGS_AZ_GEN_001.send_notification : ' || SUBSTR(SQLERRM, 80));
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded                     => fnd_api.g_false,
        p_count                       => lnMsgCount,
        p_data                        => lvMsgData);
      RAISE;
  END send_notification;
  --
  --
  --
  PROCEDURE notify_person(
    p_busevent                   IN       VARCHAR2,
    p_param_name1                IN       VARCHAR2 DEFAULT NULL,
    p_param_value1               IN       VARCHAR2 DEFAULT NULL,
    p_param_name2                IN       VARCHAR2 DEFAULT NULL,
    p_param_value2               IN       VARCHAR2 DEFAULT NULL,
    p_param_name3                IN       VARCHAR2 DEFAULT NULL,
    p_param_value3               IN       VARCHAR2 DEFAULT NULL,
    p_param_name4                IN       VARCHAR2 DEFAULT NULL,
    p_param_value4               IN       VARCHAR2 DEFAULT NULL,
    p_param_name5                IN       VARCHAR2 DEFAULT NULL,
    p_param_value5               IN       VARCHAR2 DEFAULT NULL
  ) AS
    /******************************************************************
    Created By         : Girish Jha
    Date Created By    : 17-May-2003
    Purpose            : This procedure will be used for raising business event.  This procedure is made very generic.
       This will acceept business event name and five pair of name value pair of w/f parameters.
       The name of the parameters must be registered with the w/f.
    Change History
    Who      When        What
   ******************************************************************/
    l_event_t          wf_event_t;
    l_parameter_list_t wf_parameter_list_t;
    l_itemkey          VARCHAR2(100);
    ln_seq_val         NUMBER;
    lvMsgData          VARCHAR2(100);
    lnMsgCount         NUMBER;
    --
    -- Gets a unique sequence number
    --
    CURSOR c_seq_num IS
      SELECT igs_as_wf_beas006_s.NEXTVAL
        FROM DUAL;
    --
  BEGIN
    --
    -- Get the sequence value
    --
    OPEN c_seq_num;
    FETCH c_seq_num INTO ln_seq_val;
    CLOSE c_seq_num;
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);
    --
    -- Adding the parameters to the parameter list, only when param is not null
    --
    IF p_param_name1 IS NOT NULL THEN
      wf_event.addparametertolist(
        p_name                        => p_param_name1,
        p_value                       => p_param_value1,
        p_parameterlist               => l_parameter_list_t
      );
    END IF;
    --
    IF p_param_name2 IS NOT NULL THEN
      wf_event.addparametertolist(
        p_name                        => p_param_name2,
        p_value                       => p_param_value2,
        p_parameterlist               => l_parameter_list_t
      );
    END IF;
    --
    IF p_param_name3 IS NOT NULL THEN
      wf_event.addparametertolist(
        p_name                        => p_param_name3,
        p_value                       => p_param_value3,
        p_parameterlist               => l_parameter_list_t
      );
    END IF;
    --
    IF p_param_name4 IS NOT NULL THEN
      wf_event.addparametertolist(
        p_name                        => p_param_name4,
        p_value                       => p_param_value4,
        p_parameterlist               => l_parameter_list_t
      );
    END IF;
    --
    IF p_param_name5 IS NOT NULL THEN
      wf_event.addparametertolist(
        p_name                        => p_param_name5,
        p_value                       => p_param_value5,
        p_parameterlist               => l_parameter_list_t
      );
    END IF;
    --
    -- Now the parameters are set, Raise the Event
    --
    wf_event.RAISE(
      p_event_name                  => p_busevent,
      p_event_key                   => 'IGSAZ001' || ln_seq_val,
      p_parameters                  => l_parameter_list_t
    );
    --
    -- Delete the Parameter list after the event is raised
    --
    l_parameter_list_t.DELETE;
    --
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'IGS_AZ_GEN_001.notify_person : ' || SUBSTR(SQLERRM, 80));
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (
        p_encoded                     => fnd_api.g_false,
        p_count                       => lnMsgCount,
        p_data                        => lvMsgData
      );
      RAISE;
  END notify_person;
  --
  --
  --
  PROCEDURE end_date_advisor (
    p_group_name                          VARCHAR2,
    p_advisor_person_id                   NUMBER,
    p_end_date                            DATE,
    p_calling_mod                         VARCHAR2,
    p_enforce                             VARCHAR2 DEFAULT NULL
  ) IS
    /******************************************************************
     Created By         : Girish Jha
     Date Created By    : 17-May-2003
     Purpose            : The requirement for ending an advisor is not limited to ending
                          the advisor but also the relationships that advisor has with the students in table IGS_AZ_ADVISING_RELS.
                          Also the end dating an advisor can happen either from SS page fro a concurrent program. Its better to write a
                          separet procedure to handle this.

     Change History
     Who      When        What
    ******************************************************************/
    --
    --
    --
    CURSOR cur_adv_upd IS
      SELECT aza.ROWID row_id,
             aza.*
        FROM igs_az_advisors aza
       WHERE aza.group_name = p_group_name
         AND aza.advisor_person_id = p_advisor_person_id
         AND NVL (aza.accept_add_flag, 'Y') = 'Y';
    --
    -- Business requirement 1.5 of FD. Technical approach section Last but one bullet says  that if the advisor/student
    -- has not bben accepted and no longer is part of the PIG then phycally delete the record.. Get that record corresponding to the
    -- Advisor person_id Passed.. To do .. Can this happen from SS Screen? Can I have a record with ACCEPT_ADD_FLAG = 'Y' and again make that to 'N'?
    --
    CURSOR cur_adv_del IS
      SELECT aza.ROWID row_id
        FROM igs_az_advisors aza
       WHERE aza.group_name = p_group_name
         AND aza.advisor_person_id = p_advisor_person_id
         AND aza.accept_add_flag = 'N';
    --
    -- Cursor to get all the active relationship of the advisor.
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_reln IS
      SELECT azr.ROWID row_id,
             azr.*
        FROM igs_az_advising_rels azr, igs_az_advisors aza
       WHERE azr.group_name = p_group_name
         AND azr.group_name = aza.group_name
         AND azr.group_advisor_id = aza.group_advisor_id
         AND aza.advisor_person_id = p_advisor_person_id
         AND azr.start_date IS NOT NULL
         AND TRUNC (NVL (azr.end_date, SYSDATE + 1)) > TRUNC (SYSDATE);
    --
    --
    --
    CURSOR cur_reln_del IS
      SELECT azr.ROWID row_id
        FROM igs_az_advising_rels azr, igs_az_advisors aza
       WHERE azr.group_name = p_group_name
         AND azr.group_name = aza.group_name
         AND azr.group_advisor_id = aza.group_advisor_id
         AND aza.advisor_person_id = p_advisor_person_id
         AND azr.start_date IS NULL;
    --
    --
    --
    CURSOR cur_grp IS
      SELECT auto_advisor_remove_flag
        FROM igs_az_groups azg
       WHERE azg.group_name = p_group_name;
    --
    -- Local variables:
    --
    lddeladvdate    DATE;
    lvautoadvremind VARCHAR2 (1);
    lvadvdelind     VARCHAR2 (1);
    lvReturnStatus  VARCHAR2 (10); -- To do look for the dat lengths
    lvMsgData       VARCHAR2 (1000);
    lnMsgCount      NUMBER;
    --
  BEGIN
    --
    IF p_calling_mod = 'C' THEN
      OPEN cur_grp;
      FETCH cur_grp INTO lvautoadvremind;
      CLOSE cur_grp;
      --
      IF lvautoadvremind = 'Y' THEN
        lddeladvdate := SYSDATE;
        lvadvdelind := 'Y';
      ELSE
        IF p_enforce = 'Y' THEN
          lddeladvdate := SYSDATE;
          lvadvdelind := 'Y';
        ELSE
          lddeladvdate := NULL;
          lvadvdelind := 'Y';
        END IF;
      END IF;
    ELSE
      lddeladvdate := p_end_date;
      lvadvdelind := 'Y';
    END IF;
    --
    -- End date the relationship..
    --
    FOR reln_rec IN cur_reln LOOP
      igs_az_advising_rels_pkg.update_row (
        x_rowid                       => reln_rec.row_id,
        x_group_advising_rel_id       => reln_rec.group_advising_rel_id,
        x_group_name                  => reln_rec.group_name,
        x_group_advisor_id            => reln_rec.group_advisor_id,
        x_group_student_id            => reln_rec.group_student_id,
        x_start_date                  => reln_rec.start_date,
        x_end_date                    => lddeladvdate,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      ); -- To do see if msg count etc. is require , if yes add and Error Handling
    END LOOP;
    --
    FOR del_reln IN cur_reln_del LOOP
      igs_az_advising_rels_pkg.delete_row (
        x_rowid                       => del_reln.row_id,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
    END LOOP; --   DEL_RELN
    --
    --  Update the advising record
    --
    FOR adv_upd_rec IN cur_adv_upd LOOP
      IF p_calling_mod = 'C' THEN
        igs_az_advisors_pkg.update_row (
          x_rowid                       => adv_upd_rec.row_id,
          x_group_advisor_id            => adv_upd_rec.group_advisor_id,
          x_group_name                  => adv_upd_rec.group_name,
          x_advisor_person_id           => adv_upd_rec.advisor_person_id,
          x_start_date                  => adv_upd_rec.start_date,
          x_end_date                    => lddeladvdate, -- This is only changed..
          x_max_students_num            => adv_upd_rec.max_students_num,
          x_notified_date               => adv_upd_rec.notified_date, -- This is the only change
          x_accept_add_flag             => adv_upd_rec.accept_add_flag,
          x_accept_delete_flag          => lvadvdelind, ---To do Follwing three parameters need to be added in the TBH and then uncomment
          x_return_status               => lvReturnStatus,
          x_msg_data                    => lvMsgData,
          x_msg_count                   => lnMsgCount
        ); -- To Do error handling..
      END IF;
    END LOOP;
    --
    -- See if the record has to be deleted
    --
    FOR adv_del_rec IN cur_adv_del LOOP
      igs_az_advisors_pkg.delete_row (
        adv_del_rec.row_id,
        lvReturnStatus,
        lvMsgData,
        lnMsgCount
      );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'IGS_AZ_GEN_001.Mainatin_group : ' || SUBSTR (SQLERRM, 80));
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (
        p_encoded                     => fnd_api.g_false,
        p_count                       => lnMsgCount,
        p_data                        => lvMsgData
      );
      RETURN;
  END end_date_advisor;
  --
  --
  --
  PROCEDURE end_date_student (
    p_group_name                          VARCHAR2,
    p_student_person_id                   NUMBER,
    p_end_date                            DATE,
    p_calling_mod                         VARCHAR2 DEFAULT 'C',
    p_enforce                             VARCHAR2 DEFAULT NULL
  ) IS
    /******************************************************************
     Created By         : Girish Jha
     Date Created By    : 17-May-2003
     Purpose            : The requirement for ending an student is not limited to end dating
                          the student but also the relationships that student  has in table IGS_AZ_ADVISING_RELS.
                          Also the end dating an student can happen either from SS page fro a concurrent program. Its better to write a
                          separet procedure to handle this.


     Change History
     Who      When        What
    ******************************************************************/
    --
    -- Decalre
    --
    CURSOR cur_std_upd IS
      SELECT azs.ROWID row_id,
             azs.*
        FROM igs_az_students azs
       WHERE azs.group_name = p_group_name
         AND azs.student_person_id = p_student_person_id
         AND NVL (azs.accept_add_flag, 'Y') = 'Y';
    --
    -- Business requirement 1.5 of FD. Technical approach section Last but one bullet says  that if the advisor/student
    -- has not bben accepted and no longer is part of the PIG then phycally delete the record.. Get that record corresponding to the
    -- Advisor person_id Passed.. To do .. Can this happen from SS Screen? Can I have a record with ACCEPT_ADD_FLAG = 'Y' and again make that to 'N'?
    --
    CURSOR cur_std_del IS
      SELECT azs.ROWID row_id
        FROM igs_az_students azs
       WHERE azs.group_name = p_group_name
         AND azs.student_person_id = p_student_person_id
         AND azs.accept_add_flag = 'N';
    --
    -- Cursor to get all the active relationship of the advisor.
    -- anilk, Bug# 3032626, STUDENT/ADVISOR STILL ACTIVE ON THE END DATE
    --
    CURSOR cur_reln IS
      SELECT azr.ROWID row_id,
             azr.*
        FROM igs_az_advising_rels azr, igs_az_students azs
       WHERE azr.group_name = p_group_name
         AND azr.group_name = azs.group_name
         AND azr.group_student_id = azs.group_student_id
         AND azs.student_person_id = p_student_person_id
         AND azr.start_date IS NOT NULL
         AND TRUNC (NVL (azr.end_date, SYSDATE + 1)) > TRUNC (SYSDATE);
    --
    --
    --
    CURSOR cur_grp IS
      SELECT auto_stdnt_remove_flag
        FROM igs_az_groups azg
       WHERE azg.group_name = p_group_name;
    --
    --
    --
    CURSOR cur_reln_del IS
      SELECT azr.ROWID row_id
        FROM igs_az_advising_rels azr, igs_az_students azs
       WHERE azr.group_name = p_group_name
         AND azr.group_name = azs.group_name
         AND azr.group_student_id = azs.group_student_id
         AND azs.student_person_id = p_student_person_id
         AND azr.start_date IS NULL;
    --
    -- Local variables:
    --
    lvReturnStatus  VARCHAR2 (10); -- To do look for the dat lengths
    lvMsgData       VARCHAR2 (1000);
    lnMsgCount      NUMBER;
    lddelstddate    DATE;
    lvautostdremind VARCHAR2 (1);
    lvstddelind     VARCHAR2 (1);
    --
  BEGIN
    --
    IF p_calling_mod = 'C' THEN
      OPEN cur_grp;
      FETCH cur_grp INTO lvautostdremind;
      CLOSE cur_grp;
      --
      IF lvautostdremind = 'Y' THEN
        lddelstddate := SYSDATE;
        lvstddelind := 'Y';
      ELSE
        IF p_enforce = 'Y' THEN
          lddelstddate := SYSDATE;
          lvstddelind := 'Y';
        ELSE
          lddelstddate := NULL;
          lvstddelind := 'Y';
        END IF;
      END IF;
    ELSE --- Because if called from SS pages .. the auto_accept ind will be 'Y' and end will be waht is passed as parameter.
      lddelstddate := p_end_date;
      lvstddelind := 'Y';
    END IF;
    --
    -- End date the relationship..
    --
    FOR reln_rec IN cur_reln LOOP
      igs_az_advising_rels_pkg.update_row (
        x_rowid                       => reln_rec.row_id,
        x_group_advising_rel_id       => reln_rec.group_advising_rel_id,
        x_group_name                  => reln_rec.group_name,
        x_group_advisor_id            => reln_rec.group_advisor_id,
        x_group_student_id            => reln_rec.group_student_id,
        x_start_date                  => reln_rec.start_date,
        x_end_date                    => lddelstddate,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      ); -- To do see if msg count etc. is require , if yes add and Error Handling also to do See how we can verify that the end date is earliest of either the student or the advisor end date if any.
    END LOOP; --reln_rec
    --
    FOR del_reln IN cur_reln_del LOOP
      igs_az_advising_rels_pkg.delete_row (
        x_rowid                       => del_reln.row_id,
        x_return_status               => lvReturnStatus,
        x_msg_data                    => lvMsgData,
        x_msg_count                   => lnMsgCount
      );
    END LOOP; --Del_reln
    --
    --  Update the  advising record
    --
    FOR std_upd_rec IN cur_std_upd LOOP
      IF p_calling_mod = 'C' THEN -- This is because from the ss pages, there will already be call to update row for this table.
        igs_az_students_pkg.update_row (
          x_rowid                       => std_upd_rec.row_id,
          x_group_student_id            => std_upd_rec.group_student_id,
          x_group_name                  => std_upd_rec.group_name,
          x_student_person_id           => std_upd_rec.student_person_id,
          x_start_date                  => std_upd_rec.start_date,
          x_end_date                    => lddelstddate, -- this is the only change..
          x_advising_hold_type          => std_upd_rec.advising_hold_type,
          x_hold_start_date             => std_upd_rec.hold_start_date,
          x_notified_date               => std_upd_rec.notified_date,
          x_accept_add_flag             => std_upd_rec.accept_add_flag,
          x_accept_delete_flag          => lvstddelind,
          x_return_status               => lvReturnStatus,
          x_msg_data                    => lvMsgData,
          x_msg_count                   => lnMsgCount
        ); -- To Do error handling..
      END IF;
      --
      -- End date the holds and hold effects for the student which was created as part of being ion this group.
      --
      end_std_advsng_hold (
        std_upd_rec.group_name,
        std_upd_rec.student_person_id,
        p_end_date
      ); -- Should the hold be end dated with the end date passed as parameter.
    END LOOP;
    --
    -- See if the record has to be deleted
    --
    FOR std_del_rec IN cur_std_del LOOP
      igs_az_students_pkg.delete_row (
        std_del_rec.row_id,
        lvReturnStatus,
        lvMsgData,
        lnMsgCount
      );
    END LOOP;
    --
  END end_date_student;
  --
  --
  --
  PROCEDURE end_std_advsng_hold (
    p_group_name                          VARCHAR2,
    p_person_id                           NUMBER,
    p_hld_end_dt                          DATE DEFAULT SYSDATE
  ) IS
    --
    -- Select  the student record for whom the hold is to be end dated.
    --
    CURSOR cur_std_hold IS
      SELECT azs.ROWID row_id,
             azs.*
        FROM igs_az_students azs
       WHERE azs.group_name = p_group_name AND azs.student_person_id = p_person_id;
    --
    -- Cursor to get all the advising holds of the students that were applied as part of this group and which are not yet end dated.
    --
    CURSOR cur_std_grp_hld (cp_hold_type VARCHAR2, cp_start_date DATE) IS
      SELECT hld.ROWID row_id,
             hld.*
        FROM igs_pe_pers_encumb hld
       WHERE hld.person_id = p_person_id
         AND hld.encumbrance_type = cp_hold_type
         AND hld.start_dt = cp_start_date; --AND hld.EXPIRY_DT IS NULL ;
    --
    -- Cursor to get the hold effects that are to be end dated....
    --
    CURSOR cur_hld_efct (cp_hold_type VARCHAR2, cp_start_date DATE) IS
      SELECT efc.ROWID row_id,
             efc.*
        FROM igs_pe_persenc_effct efc
       WHERE efc.person_id = p_person_id
         AND efc.encumbrance_type = cp_hold_type
         AND efc.pen_start_dt = cp_start_date; --to do see if there needs to be a check on expiry date also..
    --
  BEGIN
    --
    -- Start the loop for Student:
    --
    FOR std_rec IN cur_std_hold LOOP
      --
      -- Start the Loop for the holds
      --
      FOR hold_rec IN cur_std_grp_hld (
                        std_rec.advising_hold_type,
                        std_rec.hold_start_date
                      ) LOOP
        --
        -- Start the loop for hold effect..
        --
        FOR effect_rec IN cur_hld_efct (
                            hold_rec.encumbrance_type,
                            hold_rec.start_dt
                          ) LOOP
          igs_pe_persenc_effct_pkg.update_row (
            x_rowid                       => effect_rec.row_id,
            x_person_id                   => effect_rec.person_id,
            x_encumbrance_type            => effect_rec.encumbrance_type,
            x_pen_start_dt                => effect_rec.pen_start_dt,
            x_s_encmb_effect_type         => effect_rec.s_encmb_effect_type,
            x_pee_start_dt                => effect_rec.pee_start_dt,
            x_sequence_number             => effect_rec.sequence_number,
            x_expiry_dt                   => p_hld_end_dt, -- Only Change
            x_course_cd                   => effect_rec.course_cd,
            x_restricted_enrolment_cp     => effect_rec.restricted_enrolment_cp,
            x_restricted_attendance_type  => effect_rec.restricted_attendance_type
          );
        END LOOP; --effect_rec
        --
        -- Once all the effects are end dated end date the hold itself.
        --
        igs_pe_pers_encumb_pkg.update_row (
          x_rowid                       => hold_rec.row_id,
          x_person_id                   => hold_rec.person_id,
          x_encumbrance_type            => hold_rec.encumbrance_type,
          x_start_dt                    => hold_rec.start_dt,
          x_expiry_dt                   => p_hld_end_dt,
          x_authorising_person_id       => hold_rec.authorising_person_id,
          x_comments                    => hold_rec.comments,
          x_spo_course_cd               => hold_rec.spo_course_cd,
          x_spo_sequence_number         => hold_rec.spo_sequence_number,
          x_cal_type                    => hold_rec.cal_type,
          x_sequence_number             => hold_rec.sequence_number,
          x_auth_resp_id                => hold_rec.auth_resp_id,
          x_external_reference          => hold_rec.external_reference
        );
      END LOOP; --hold_rec
    END LOOP; --std_rec
    --
  END end_std_advsng_hold;
  --
  --
  --
  PROCEDURE submit_maintain_group_job (
    p_group_name                 IN       igs_az_groups.group_name%TYPE,
    p_return_status              OUT NOCOPY VARCHAR2,
    p_message_data               OUT NOCOPY VARCHAR2,
    p_message_count              OUT NOCOPY NUMBER,
    p_request_id                 OUT NOCOPY NUMBER
  ) AS
    --
    l_message VARCHAR2 (2000);
    l_req_id  NUMBER          := 100;
    --
  BEGIN
    --
    -- This report now needs to take the order number as parameter
    --
    l_req_id := fnd_request.submit_request (
                  application                   => 'IGS',
                  program                       => 'IGSAZJ01',
                  description                   => NULL,
                  start_time                    => SYSDATE,
                  sub_request                   => FALSE,
                  argument1                     => p_group_name
                );
    --
    IF l_req_id = 0 THEN
      p_message_data := fnd_message.get;
    END IF;
    --
    p_request_id := l_req_id;
    --
    -- Commit issued as the job will not be saved till commit is done
    --
    COMMIT;
  END submit_maintain_group_job;
  --
  --
  --
  PROCEDURE wf_set_role (
    itemtype                     IN       VARCHAR2,
    itemkey                      IN       VARCHAR2,
    actid                        IN       NUMBER,
    funcmode                     IN       VARCHAR2,
    resultout                    OUT NOCOPY VARCHAR2
  ) AS
    /******************************************************************
      Created By         : anilk
      Date Created By    : 10-Jun-2003
      Purpose            : This procedure is called from workflow IGSAZ001
      Change History
      Who      When        What
     ******************************************************************/
    --
    l_date_prod         VARCHAR2 (30);
    l_doc_type          VARCHAR2 (30);
    l_role_name         VARCHAR2 (320);
    l_role_display_name VARCHAR2 (320)            := 'Adhoc Role for IGSAZ001';
    l_person_id_sep     VARCHAR2 (4000);
    l_person_id         VARCHAR2 (30);
    --
    -- cursor to get the user_name corresponding to the person_id
    --
    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
      SELECT user_name
        FROM fnd_user
       WHERE person_party_id = cp_person_id;
    --
    l_user_name         fnd_user.user_name%TYPE;
    --
    --
    --
    CURSOR c_dup_user (cp_user_name VARCHAR2, cp_role_name VARCHAR2) IS
      SELECT COUNT (1)
        FROM wf_local_user_roles
       WHERE user_name = cp_user_name
         AND role_name = cp_role_name
         AND role_orig_system = 'WF_LOCAL_ROLES'
         AND role_orig_system_id = 0;
    --
    l_dup_user          NUMBER                    := 0;
    --
  BEGIN
    --
    IF (funcmode = 'RUN') THEN
      -- create the adhoc role
      l_role_name := 'IGS' || SUBSTR (itemkey, 6);
      wf_directory.createadhocrole (
        role_name                     => l_role_name,
        role_display_name             => l_role_display_name
      );
      --
      -- fetch student for whom the record has been procesed and add the user name to the
      -- adhoc role
      --
      l_person_id_sep := wf_engine.getitemattrtext (itemtype, itemkey, 'IA_USERS');
      --
      WHILE (LENGTH (l_person_id_sep) > 0) LOOP
        IF (INSTR (l_person_id_sep, ',') > 0) THEN
          l_person_id := SUBSTR (l_person_id_sep, 1, INSTR (l_person_id_sep, ',') - 1);
          l_person_id_sep := SUBSTR (l_person_id_sep, INSTR (l_person_id_sep, ',') + 1);
          OPEN c_user_name (l_person_id);
          FETCH c_user_name INTO l_user_name;
          CLOSE c_user_name;
          --
          -- add this user name to the adhoc role if it is not null and unique
          --
          OPEN c_dup_user (l_user_name, l_role_name);
          FETCH c_dup_user INTO l_dup_user;
          CLOSE c_dup_user;
          --
          IF  l_user_name IS NOT NULL AND l_dup_user = 0 THEN
            wf_directory.adduserstoadhocrole (
              role_name                     => l_role_name,
              role_users                    => l_user_name
            );
          END IF;
        ELSE
          OPEN c_user_name (l_person_id_sep);
          FETCH c_user_name INTO l_user_name;
          CLOSE c_user_name;
          --
          -- add this user name to the adhoc role if it is not null and unique
          --
          OPEN c_dup_user (l_user_name, l_role_name);
          FETCH c_dup_user INTO l_dup_user;
          CLOSE c_dup_user;
          --
          IF  l_user_name IS NOT NULL AND l_dup_user = 0 THEN
            wf_directory.adduserstoadhocrole (
              role_name                     => l_role_name,
              role_users                    => l_user_name
            );
          END IF;
          --
          l_person_id := l_person_id_sep;
          l_person_id_sep := NULL;
          --
        END IF;
      END LOOP;
      --
      -- now set this role to the workflow
      --
      wf_engine.setitemattrtext (
        itemtype                      => itemtype,
        itemkey                       => itemkey,
        aname                         => 'IA_ADHOCROLE',
        avalue                        => l_role_name
      );
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    --
  END wf_set_role;
  --
  --
  --
  PROCEDURE deactivate_group (
    p_group_name                 IN       VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    --
    -- More info of the group
    --
    CURSOR cur_grp IS
      SELECT azg.ROWID row_id,
             azg.*
        FROM igs_az_groups azg
       WHERE azg.group_name = p_group_name;
    --
    -- Advisors in the group
    --
    CURSOR cur_adv IS
      SELECT advisor_person_id
        FROM igs_az_advisors aza
       WHERE aza.group_name = p_group_name;
    --
    -- Students in the group
    --
    CURSOR cur_stud IS
      SELECT student_person_id
        FROM igs_az_students azs
       WHERE azs.group_name = p_group_name;
    --
    grp_rec         cur_grp%ROWTYPE;
    l_return_status VARCHAR2 (1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2 (2000);
    --
  BEGIN
    --
    OPEN cur_grp;
    FETCH cur_grp INTO grp_rec;
    CLOSE cur_grp;
    --
    igs_az_groups_pkg.update_row (
      x_rowid                       => grp_rec.row_id,
      x_group_name                  => grp_rec.group_name,
      x_group_desc                  => grp_rec.group_desc,
      x_advising_code               => grp_rec.advising_code,
      x_resp_org_unit_cd            => grp_rec.resp_org_unit_cd,
      x_resp_person_id              => grp_rec.resp_person_id,
      x_location_cd                 => grp_rec.location_cd,
      x_delivery_method_code        => grp_rec.delivery_method_code,
      x_advisor_group_id            => grp_rec.advisor_group_id,
      x_student_group_id            => grp_rec.student_group_id,
      x_default_advisor_load_num    => grp_rec.default_advisor_load_num,
      x_mandatory_flag              => grp_rec.mandatory_flag,
      x_advising_sessions_num       => grp_rec.advising_sessions_num,
      x_advising_hold_type          => grp_rec.advising_hold_type,
      x_closed_flag                 => 'Y',
      x_comments_txt                => grp_rec.comments_txt,
      x_auto_refresh_flag           => grp_rec.auto_refresh_flag,
      x_last_auto_refresh_date      => grp_rec.last_auto_refresh_date,
      x_auto_stdnt_add_flag         => grp_rec.auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag      => grp_rec.auto_stdnt_remove_flag,
      x_auto_advisor_add_flag       => grp_rec.auto_advisor_add_flag,
      x_auto_advisor_remove_flag    => grp_rec.auto_advisor_remove_flag,
      x_auto_match_flag             => grp_rec.auto_match_flag,
      x_auto_apply_hold_flag        => grp_rec.auto_apply_hold_flag,
      x_attribute_category          => grp_rec.attribute_category,
      x_attribute1                  => grp_rec.attribute1,
      x_attribute2                  => grp_rec.attribute2,
      x_attribute3                  => grp_rec.attribute3,
      x_attribute4                  => grp_rec.attribute4,
      x_attribute5                  => grp_rec.attribute5,
      x_attribute6                  => grp_rec.attribute6,
      x_attribute7                  => grp_rec.attribute7,
      x_attribute8                  => grp_rec.attribute8,
      x_attribute9                  => grp_rec.attribute9,
      x_attribute10                 => grp_rec.attribute10,
      x_attribute11                 => grp_rec.attribute11,
      x_attribute12                 => grp_rec.attribute12,
      x_attribute13                 => grp_rec.attribute13,
      x_attribute14                 => grp_rec.attribute14,
      x_attribute15                 => grp_rec.attribute15,
      x_attribute16                 => grp_rec.attribute16,
      x_attribute17                 => grp_rec.attribute17,
      x_attribute18                 => grp_rec.attribute18,
      x_attribute19                 => grp_rec.attribute19,
      x_attribute20                 => grp_rec.attribute20,
      x_return_status               => l_return_status,
      x_msg_data                    => l_msg_data,
      x_msg_count                   => l_msg_count
    );
    --
    -- End date the advisors, this will end date relations also
    --
    FOR adv_rec IN cur_adv LOOP
      end_date_advisor (
        p_group_name                  => p_group_name,
        p_advisor_person_id           => adv_rec.advisor_person_id,
        p_end_date                    => TRUNC (SYSDATE),
        p_calling_mod                 => 'C',
        p_enforce                     => 'Y'
      );
    END LOOP;
    --
    -- End date the students, this will end date relations also
    --
    FOR stud_rec IN cur_stud LOOP
      end_date_student (
        p_group_name                  => p_group_name,
        p_student_person_id           => stud_rec.student_person_id,
        p_end_date                    => TRUNC (SYSDATE),
        p_calling_mod                 => 'C',
        p_enforce                     => 'Y'
      );
    END LOOP;
    --
    x_return_status := 'S';
    --
  END deactivate_group;
  --
  --
  --
  PROCEDURE reactivate_group (
    p_group_name                          VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    --
    -- More info of the group
    --
    CURSOR cur_grp IS
      SELECT azg.ROWID row_id,
             azg.*
        FROM igs_az_groups azg
       WHERE azg.group_name = p_group_name;
    --
    grp_rec         cur_grp%ROWTYPE;
    l_return_status VARCHAR2 (1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2 (2000);
    --
  BEGIN
    --
    OPEN cur_grp;
    FETCH cur_grp INTO grp_rec;
    CLOSE cur_grp;
    --
    igs_az_groups_pkg.update_row (
      x_rowid                       => grp_rec.row_id,
      x_group_name                  => grp_rec.group_name,
      x_group_desc                  => grp_rec.group_desc,
      x_advising_code               => grp_rec.advising_code,
      x_resp_org_unit_cd            => grp_rec.resp_org_unit_cd,
      x_resp_person_id              => grp_rec.resp_person_id,
      x_location_cd                 => grp_rec.location_cd,
      x_delivery_method_code        => grp_rec.delivery_method_code,
      x_advisor_group_id            => grp_rec.advisor_group_id,
      x_student_group_id            => grp_rec.student_group_id,
      x_default_advisor_load_num    => grp_rec.default_advisor_load_num,
      x_mandatory_flag              => grp_rec.mandatory_flag,
      x_advising_sessions_num       => grp_rec.advising_sessions_num,
      x_advising_hold_type          => grp_rec.advising_hold_type,
      x_closed_flag                 => 'N',
      x_comments_txt                => grp_rec.comments_txt,
      x_auto_refresh_flag           => grp_rec.auto_refresh_flag,
      x_last_auto_refresh_date      => grp_rec.last_auto_refresh_date,
      x_auto_stdnt_add_flag         => grp_rec.auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag      => grp_rec.auto_stdnt_remove_flag,
      x_auto_advisor_add_flag       => grp_rec.auto_advisor_add_flag,
      x_auto_advisor_remove_flag    => grp_rec.auto_advisor_remove_flag,
      x_auto_match_flag             => grp_rec.auto_match_flag,
      x_auto_apply_hold_flag        => grp_rec.auto_apply_hold_flag,
      x_attribute_category          => grp_rec.attribute_category,
      x_attribute1                  => grp_rec.attribute1,
      x_attribute2                  => grp_rec.attribute2,
      x_attribute3                  => grp_rec.attribute3,
      x_attribute4                  => grp_rec.attribute4,
      x_attribute5                  => grp_rec.attribute5,
      x_attribute6                  => grp_rec.attribute6,
      x_attribute7                  => grp_rec.attribute7,
      x_attribute8                  => grp_rec.attribute8,
      x_attribute9                  => grp_rec.attribute9,
      x_attribute10                 => grp_rec.attribute10,
      x_attribute11                 => grp_rec.attribute11,
      x_attribute12                 => grp_rec.attribute12,
      x_attribute13                 => grp_rec.attribute13,
      x_attribute14                 => grp_rec.attribute14,
      x_attribute15                 => grp_rec.attribute15,
      x_attribute16                 => grp_rec.attribute16,
      x_attribute17                 => grp_rec.attribute17,
      x_attribute18                 => grp_rec.attribute18,
      x_attribute19                 => grp_rec.attribute19,
      x_attribute20                 => grp_rec.attribute20,
      x_return_status               => l_return_status,
      x_msg_data                    => l_msg_data,
      x_msg_count                   => l_msg_count
    );
    x_return_status := 'S';
    --
  END reactivate_group;
  --
END igs_az_gen_001;

/
