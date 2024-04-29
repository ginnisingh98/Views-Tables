--------------------------------------------------------
--  DDL for Package Body BEN_PRE_DATAPUMP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRE_DATAPUMP_PROCESS" as
/* $Header: benripmp.pkb 120.7 2006/05/03 09:40:12 nkkrishn noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Enrollment Process
Purpose
        This is a wrapper procedure for Benefits enrollments,
        dependents and beneficiaries designation for Enrollments conversion,
        ongoing mass updates and IVR Process.
History
	Date		Who         Version	What?
	----		---	    -------	-----
	01 Nov 05	ikasire     115.0       Created
        24 Jan 06       ikasired    115.2       Added update for
                                                ATOMIC_LINKED_CALLS
        08 Feb 06       ikasired    115.3       Added code for full_name and
                                                DOB Validation
        01 Mar 06       ikasired    115.4       Exclude C records
        02 Mar 06       ikasired    115.5       get_pl_id error fix
        23 Mar 06       ikasire     115.6       Added stub for Beneficiaries
                                                future validations if required
                                                for multirows edits
        24 Mar 06       ikasired    115.7       Deleting the POST records to
                                                avoid accidental deletion of the
                                                records.
        13 Apr 06       nkkrishn    115.8       Summary row elimination changes
        19 Apr 06       ikasired    115.9       removed the DELETE for POST rows
                                                as we are not creating any new
                                                rows
        02 May 06       nkkrishn        115.11  Fixed Beneficiary upload
*/
--
--Globals
--
g_debug boolean := hr_utility.debug_enabled;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< INSERT_CREATE_ENROLLMENT >-------------------------|
-- -------------------------------------------------------------------------------+
--
procedure insert_create_enrollment
         (
          BATCH_ID                         NUMBER
         ,API_MODULE_ID                    NUMBER
         ,USER_SEQUENCE                    NUMBER
         ,LINK_VALUE                       NUMBER
         ,BUSINESS_GROUP_NAME              VARCHAR2
         ,P_LIFE_EVENT_DATE                VARCHAR2
         ,P_EFFECTIVE_DATE                 VARCHAR2
         ,P_PROC_CD                        VARCHAR2
         ,P_PROGRAM                        VARCHAR2
         ,P_PROGRAM_NUM                    VARCHAR2
         ,P_PLAN                           VARCHAR2
         ,P_PLAN_NUM                       VARCHAR2
         ,P_LIFE_EVENT_REASON              VARCHAR2
         ,P_EMPLOYEE_NUMBER                VARCHAR2
         ,P_NATIONAL_IDENTIFIER            VARCHAR2
         ,P_FULL_NAME                      VARCHAR2
         ,P_DATE_OF_BIRTH                  VARCHAR2
         ,P_PERSON_NUM                     VARCHAR2
         ) is
  begin
   INSERT INTO hrdpv_create_enrollment (
     BATCH_ID
     ,BATCH_LINE_ID
     ,API_MODULE_ID
     ,LINE_STATUS
     ,USER_SEQUENCE
     ,LINK_VALUE
     ,BUSINESS_GROUP_NAME
     ,P_LIFE_EVENT_DATE
     ,P_EFFECTIVE_DATE
     ,P_PROC_CD
     ,P_RECORD_TYP_CD
     ,P_PROGRAM
     ,P_PROGRAM_NUM
     ,P_PLAN
     ,P_PLAN_NUM
     ,P_LIFE_EVENT_REASON
     ,P_EMPLOYEE_NUMBER
     ,P_NATIONAL_IDENTIFIER
     ,P_FULL_NAME
     ,P_DATE_OF_BIRTH
     ,P_PERSON_NUM  )
   VALUES
     (BATCH_ID
     ,hr_pump_batch_lines_s.NEXTVAL
     ,API_MODULE_ID
     ,'U'
     ,USER_SEQUENCE
     ,LINK_VALUE
     ,BUSINESS_GROUP_NAME
     ,P_LIFE_EVENT_DATE
     ,P_EFFECTIVE_DATE
     ,P_PROC_CD
     ,'POST'
     ,P_PROGRAM
     ,P_PROGRAM_NUM
     ,P_PLAN
     ,P_PLAN_NUM
     ,P_LIFE_EVENT_REASON
     ,P_EMPLOYEE_NUMBER
     ,P_NATIONAL_IDENTIFIER
     ,P_FULL_NAME
     ,P_DATE_OF_BIRTH
     ,P_PERSON_NUM
     ) ;
  end insert_create_enrollment ;
--
procedure insert_process_dependent
         (
          BATCH_ID                         NUMBER
         ,API_MODULE_ID                    NUMBER
         ,USER_SEQUENCE                    NUMBER
         ,LINK_VALUE                       NUMBER
         ,BUSINESS_GROUP_NAME              VARCHAR2
         ,P_LIFE_EVENT_DATE                VARCHAR2
         ,P_EFFECTIVE_DATE                 VARCHAR2
         ,P_PROGRAM                        VARCHAR2
         ,P_PROGRAM_NUM                    VARCHAR2
         ,P_PLAN                           VARCHAR2
         ,P_PLAN_NUM                       VARCHAR2
         ,P_OPTION                         VARCHAR2
         ,P_OPTION_NUM                     VARCHAR2
         ,P_LIFE_EVENT_REASON              VARCHAR2
         ,P_EMPLOYEE_NUMBER                VARCHAR2
         ,P_NATIONAL_IDENTIFIER            VARCHAR2
         ,P_FULL_NAME                      VARCHAR2
         ,P_DATE_OF_BIRTH                  VARCHAR2
         ,P_PERSON_NUM                     VARCHAR2
         ) is
  begin
   INSERT INTO hrdpv_process_dependent (
      BATCH_ID
     ,BATCH_LINE_ID
     ,API_MODULE_ID
     ,LINE_STATUS
     ,USER_SEQUENCE
     ,LINK_VALUE
     ,BUSINESS_GROUP_NAME
     ,P_LIFE_EVENT_DATE
     ,P_EFFECTIVE_DATE
     ,P_RECORD_TYP_CD
     ,P_PROGRAM
     ,P_PROGRAM_NUM
     ,P_PLAN
     ,P_PLAN_NUM
     ,P_OPTION
     ,P_OPTION_NUM
     ,P_LIFE_EVENT_REASON
     ,P_EMPLOYEE_NUMBER
     ,P_NATIONAL_IDENTIFIER
     ,P_FULL_NAME
     ,P_DATE_OF_BIRTH
     ,P_PERSON_NUM  )
   VALUES
     (BATCH_ID
     ,hr_pump_batch_lines_s.NEXTVAL
     ,API_MODULE_ID
     ,'U'
     ,USER_SEQUENCE
     ,LINK_VALUE
     ,BUSINESS_GROUP_NAME
     ,P_LIFE_EVENT_DATE
     ,P_EFFECTIVE_DATE
     ,'POST'
     ,P_PROGRAM
     ,P_PROGRAM_NUM
     ,P_PLAN
     ,P_PLAN_NUM
     ,P_OPTION
     ,P_OPTION_NUM
     ,P_LIFE_EVENT_REASON
     ,P_EMPLOYEE_NUMBER
     ,P_NATIONAL_IDENTIFIER
     ,P_FULL_NAME
     ,P_DATE_OF_BIRTH
     ,P_PERSON_NUM
     ) ;
  end insert_process_dependent ;
--
procedure pre_create_enrollment
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) is
    --
    cursor c_choices is
    select ch.*
      from hrdpv_create_enrollment ch
     where ch.batch_id = p_batch_id
       and ch.line_status <> 'C'
     order by p_person_num,
              p_employee_number,
              p_national_identifier,
              p_full_name,
              p_date_of_birth,
              p_program,
              p_program_num,
              p_plan,
              p_plan_num,
              p_record_typ_cd
     for update;
    --
    l_link_value  hrdpv_create_enrollment.link_value%TYPE := 0 ;
    l_sequence    hrdpv_create_enrollment.user_sequence%TYPE := 1 ;
    l_person_num  hrdpv_create_enrollment.p_person_num%TYPE;
    l_emp_num     hrdpv_create_enrollment.p_employee_number%TYPE;
    l_ssn         hrdpv_create_enrollment.p_national_identifier%TYPE;
    l_full_name   hrdpv_create_enrollment.p_full_name%TYPE;
    l_dob         hrdpv_create_enrollment.p_date_of_birth%TYPE;
    l_program     hrdpv_create_enrollment.p_program%TYPE;
    l_program_num hrdpv_create_enrollment.p_program_num%TYPE;
    l_plan        hrdpv_create_enrollment.p_plan%TYPE;
    l_plan_num    hrdpv_create_enrollment.p_plan_num%TYPE;
    l_record_typ  hrdpv_create_enrollment.p_record_typ_cd%TYPE ;

    l_person_change boolean := true;
    --
    l_prev_rec    c_choices%ROWTYPE;
    l_curr_rec    c_choices%ROWTYPE;
    l_prev_link   hrdpv_create_enrollment.link_value%TYPE ;
    --
  begin
    --
    /*  IMPORTANT to enforce the following assumptions. Otherwise we need to enhance our
        code to handle those cases.
     --In a batch data needs to be consistent which means
     --Person Data - Use either employee_number or SSN or Fullname plus DOB or Person num
     --Plan design - Use either comp object name or num but can't use num for some plans
                     and name for some other plans.
    */
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - module_name :pre_create_enrollment' );
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Batch ID: '||p_batch_id );
    --
    --Update Header for ATOMIC_LINKED_CALLS
    --we need patch 4665288 applied for this.
    UPDATE hr_pump_batch_headers bh
       SET bh.ATOMIC_LINKED_CALLS = 'Y'
     WHERE bh.batch_id = p_batch_id ;
    --
    --
    UPDATE hrdpv_create_enrollment
       SET P_RECORD_TYP_CD = 'ENROLL'
    WHERE batch_id = p_batch_id;
    --
    --
    fnd_file.put_line
        (which => fnd_file.log,
         buff  => 'Updated Header for ATOMIC_LINKED_CALLS');
    --
    for i in c_choices loop
      --
      l_curr_rec := i;
      --
      l_person_change := true;
      --
      IF i.p_person_num IS NOT NULL THEN
        --
        IF i.p_person_num = l_person_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_employee_number IS NOT NULL THEN
        --
        IF i.p_employee_number = l_emp_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_national_identifier IS NOT NULL THEN
        --
        IF i.p_national_identifier = l_ssn THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_full_name IS NOT NULL AND i.p_date_of_birth IS NOT NULL THEN
        --
        IF i.p_full_name = l_prev_rec.p_full_name AND
           i.p_date_of_birth = l_prev_rec.p_date_of_birth THEN
          --
          l_person_change := false;
          --
        END IF;
        --
      END IF;
      --
      IF l_person_change THEN
        --
        --Now check if the last person record exists and if the record type is not
        --POST then create on record for post with the previous record information.
        --
        l_link_value := l_link_value + 1;
        --
      ELSIF i.p_program is NOT NULL OR i.p_program_num IS NOT NULL THEN
        --
        IF i.p_program IS NOT NULL THEN
          --
          IF i.p_program <> l_program THEN
            --If Program is changing and the last record type is not POST
            --then create a record for POST
            --
            l_link_value := l_link_value + 1;
            --
          END IF;
          --
        ELSE
          --
          IF i.p_program_num <> l_program_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          END IF;
          --
        END IF;
        --
      ELSE
        --
        IF i.p_plan IS NOT NULL THEN
          --
          IF i.p_plan <> l_plan THEN
            --
            l_link_value := l_link_value + 1;
            --
          END IF;
          --
        ELSE
          --
          IF i.p_plan_num <> l_plan_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      IF l_prev_link <> l_link_value AND l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
         --
         IF l_prev_rec.P_PROGRAM IS NOT NULL OR
            l_prev_rec.P_PROGRAM_NUM IS NOT NULL THEN
           --
           l_prev_rec.P_PLAN := null;
           l_prev_rec.P_PLAN_NUM := null;
           --
         END IF ;
--NK
--Changes to eliminate summary row in Enrollment Upload Spreadsheet.
--Instead of inserting summary row, change the record type of the
--last record of the group from 'ENROLL' to 'POST'.
/*
         --
         INSERT_CREATE_ENROLLMENT
                (BATCH_ID                 => p_batch_id
                ,API_MODULE_ID            => l_prev_rec.api_module_id
                ,USER_SEQUENCE            => l_sequence
                ,LINK_VALUE               => l_prev_link
                ,BUSINESS_GROUP_NAME      => l_prev_rec.BUSINESS_GROUP_NAME
                ,P_LIFE_EVENT_DATE        => l_prev_rec.P_LIFE_EVENT_DATE
                ,P_EFFECTIVE_DATE         => l_prev_rec.P_EFFECTIVE_DATE
                ,P_PROC_CD                => l_prev_rec.P_PROC_CD
                ,P_PROGRAM                => l_prev_rec.P_PROGRAM
                ,P_PROGRAM_NUM            => l_prev_rec.P_PROGRAM_NUM
                ,P_PLAN                   => l_prev_rec.P_PLAN
                ,P_PLAN_NUM               => l_prev_rec.P_PLAN_NUM
                ,P_LIFE_EVENT_REASON      => l_prev_rec.P_LIFE_EVENT_REASON
                ,P_EMPLOYEE_NUMBER        => l_prev_rec.P_EMPLOYEE_NUMBER
                ,P_NATIONAL_IDENTIFIER    => l_prev_rec.P_NATIONAL_IDENTIFIER
                ,P_FULL_NAME              => l_prev_rec.P_FULL_NAME
                ,P_DATE_OF_BIRTH          => l_prev_rec.P_DATE_OF_BIRTH
                ,P_PERSON_NUM             => l_prev_rec.P_PERSON_NUM
                );
         --
         l_sequence   := l_sequence + 1;
         --
*/
         update hrdpv_create_enrollment
            set p_record_typ_cd = 'POST'
          where batch_id = p_batch_id
            and batch_line_id = l_prev_rec.batch_line_id;
         --
      END IF;
      --UPDATE STATEMENT
      --
      update hrdpv_create_enrollment
         set user_sequence = l_sequence ,
                link_value = l_link_value
       where batch_id = p_batch_id
         and batch_line_id = i.batch_line_id ;
      --
      --
      l_sequence := l_sequence + 1 ;
      --
      l_prev_link   := l_link_value ;
      l_person_num  := i.p_person_num;
      l_emp_num     := i.p_employee_number;
      l_ssn         := i.p_national_identifier;
      l_full_name   := i.p_full_name;
      l_dob         := i.p_date_of_birth;
      l_program     := i.p_program;
      l_program_num := i.p_program_num;
      l_plan        := i.p_plan;
      l_plan_num    := i.p_plan_num;
      l_record_typ  := i.p_record_typ_cd;
      --
      l_prev_rec := l_curr_rec ;
      --
    end loop;
    --
    IF l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
       --
       IF l_prev_rec.P_PROGRAM IS NOT NULL OR
          l_prev_rec.P_PROGRAM_NUM IS NOT NULL THEN
          --
          l_prev_rec.P_PLAN := null;
          l_prev_rec.P_PLAN_NUM := null;
          --
       END IF ;
       --
--NK
--Changes to eliminate summary row in Enrollment Upload Spreadsheet.
--Instead of inserting summary row, change the record type of the
--last record of the group from 'ENROLL' to 'POST'.
/*
       INSERT_CREATE_ENROLLMENT
                (BATCH_ID                 => p_batch_id
                ,API_MODULE_ID            => l_prev_rec.api_module_id
                ,USER_SEQUENCE            => l_sequence
                ,LINK_VALUE               => l_prev_link
                ,BUSINESS_GROUP_NAME      => l_prev_rec.BUSINESS_GROUP_NAME
                ,P_LIFE_EVENT_DATE        => l_prev_rec.P_LIFE_EVENT_DATE
                ,P_EFFECTIVE_DATE         => l_prev_rec.P_EFFECTIVE_DATE
                ,P_PROC_CD                => l_prev_rec.P_PROC_CD
                ,P_PROGRAM                => l_prev_rec.P_PROGRAM
                ,P_PROGRAM_NUM            => l_prev_rec.P_PROGRAM_NUM
                ,P_PLAN                   => l_prev_rec.P_PLAN
                ,P_PLAN_NUM               => l_prev_rec.P_PLAN_NUM
                ,P_LIFE_EVENT_REASON      => l_prev_rec.P_LIFE_EVENT_REASON
                ,P_EMPLOYEE_NUMBER        => l_prev_rec.P_EMPLOYEE_NUMBER
                ,P_NATIONAL_IDENTIFIER    => l_prev_rec.P_NATIONAL_IDENTIFIER
                ,P_FULL_NAME              => l_prev_rec.P_FULL_NAME
                ,P_DATE_OF_BIRTH          => l_prev_rec.P_DATE_OF_BIRTH
                ,P_PERSON_NUM             => l_prev_rec.P_PERSON_NUM
                );
*/
       update hrdpv_create_enrollment
          set p_record_typ_cd = 'POST'
        where batch_id = p_batch_id
          and batch_line_id = l_prev_rec.batch_line_id;
       --
    END IF;
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Leaving - module_name :pre_create_enrollment' );
    --
  end pre_create_enrollment ;
--
procedure pre_process_dependent
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) is
    --
    cursor c_choices is
    select ch.*
      from hrdpv_process_dependent ch
     where ch.batch_id = p_batch_id
       and ch.line_status <> 'C'
     order by p_person_num,
              p_employee_number,
              p_national_identifier,
              p_full_name,
              p_date_of_birth,
              p_program,
              p_program_num,
              p_plan,
              p_plan_num,
              p_option,
              p_option_num,
              p_record_typ_cd
     for update;
    --
    l_link_value  hrdpv_process_dependent.link_value%TYPE := 0 ;
    l_sequence    hrdpv_process_dependent.user_sequence%TYPE := 1 ;
    l_person_num  hrdpv_process_dependent.p_person_num%TYPE;
    l_emp_num     hrdpv_process_dependent.p_employee_number%TYPE;
    l_ssn         hrdpv_process_dependent.p_national_identifier%TYPE;
    l_full_name   hrdpv_process_dependent.p_full_name%TYPE;
    l_dob         hrdpv_process_dependent.p_date_of_birth%TYPE;
    l_program     hrdpv_process_dependent.p_program%TYPE;
    l_program_num hrdpv_process_dependent.p_program_num%TYPE;
    l_plan        hrdpv_process_dependent.p_plan%TYPE;
    l_plan_num    hrdpv_process_dependent.p_plan_num%TYPE;
    l_record_typ  hrdpv_process_dependent.p_record_typ_cd%TYPE ;
    --
    l_person_change boolean := true;
    --
    l_prev_rec    c_choices%ROWTYPE;
    l_curr_rec    c_choices%ROWTYPE;
    l_prev_link   hrdpv_process_dependent.link_value%TYPE ;
    --
  begin
    --
    /*  IMPORTANT to enforce the following assumptions. Otherwise we need to enhance our
        code to handle those cases.
     --In a batch data needs to be consistent which means
     --Person Data - Use either employee_number or SSN or Fullname plus DOB or Person num
     --Plan design - Use either comp object name or num but can't use num for some plans
                     and name for some other plans.
    */
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - module_name :pre_process_dependent' );
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Batch ID: '||p_batch_id );
    --
    --Update Header for ATOMIC_LINKED_CALLS
    --we need patch 4665288 applied for this.
    UPDATE hr_pump_batch_headers bh
       SET bh.ATOMIC_LINKED_CALLS = 'Y'
     WHERE bh.batch_id = p_batch_id ;
    --
    fnd_file.put_line
        (which => fnd_file.log,
         buff  => 'Updated Header for ATOMIC_LINKED_CALLS');
    --
    --
    UPDATE hrdpv_process_dependent
       SET P_RECORD_TYP_CD = 'ENROLL'
    WHERE batch_id = p_batch_id;
    --
    --

    for i in c_choices loop
      --
      l_curr_rec := i;
      --
      l_person_change := true;
      --
      IF i.p_person_num IS NOT NULL THEN
        --
        IF i.p_person_num = l_person_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_employee_number IS NOT NULL THEN
        --
        IF i.p_employee_number = l_emp_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_national_identifier IS NOT NULL THEN
        --
        IF i.p_national_identifier = l_ssn THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_full_name IS NOT NULL AND i.p_date_of_birth IS NOT NULL THEN
        --
        IF i.p_full_name = l_prev_rec.p_full_name AND
           i.p_date_of_birth = l_prev_rec.p_date_of_birth THEN
          --
          l_person_change := false;
          --
        END IF;
        --
      END IF;
      --
      IF l_person_change THEN
        --
        --Now check if the last person record exists and if the record type is not
        --POST then create on record for post with the previous record information.
        --
        l_link_value := l_link_value + 1;
        --
      ELSIF i.p_program is NOT NULL OR i.p_program_num IS NOT NULL THEN
        --
        IF i.p_program IS NOT NULL THEN
          --
          IF i.p_program <> l_program THEN
            --If Program is changing and the last record type is not POST
            --then create a record for POST
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            --
            IF i.p_plan <> l_prev_rec.p_plan THEN
              l_link_value := l_link_value + 1;
            ELSE
               IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
                 IF i.p_option IS NOT NULL THEN
                   IF i.p_option <> l_prev_rec.p_option THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 ELSE
                   IF i.p_option_num <> l_prev_rec.p_option_num THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 END IF;
               END IF;
            END IF;
            --
          END IF;
          --
        ELSE
          --
          IF i.p_program_num <> l_program_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            --
            IF i.p_plan <> l_plan THEN
              l_link_value := l_link_value + 1;
            ELSE
               IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
                 IF i.p_option IS NOT NULL THEN
                   IF i.p_option <> l_prev_rec.p_option THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 ELSE
                   IF i.p_option_num <> l_prev_rec.p_option_num THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 END IF;
               END IF;
            END IF;
            --
          END IF;
          --
        END IF;
        --
      ELSE
        --
        IF i.p_plan IS NOT NULL THEN
          --
          IF i.p_plan <> l_plan THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
              IF i.p_option IS NOT NULL THEN
                IF i.p_option <> l_prev_rec.p_option THEN
                  l_link_value := l_link_value + 1;
                END IF;
              ELSE
                IF i.p_option_num <> l_prev_rec.p_option_num THEN
                  l_link_value := l_link_value + 1;
                END IF;
              END IF;
            END IF;
          END IF;
          --
        ELSE
          --
          IF i.p_plan_num <> l_plan_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
              IF i.p_option IS NOT NULL THEN
                IF i.p_option <> l_prev_rec.p_option THEN
                  l_link_value := l_link_value + 1;
                END IF;
              ELSE
                IF i.p_option_num <> l_prev_rec.p_option_num THEN
                  l_link_value := l_link_value + 1;
                END IF;
              END IF;
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      IF l_prev_link <> l_link_value AND l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
         --
         --
--NK
--Changes to eliminate summary row in Dependent Upload Spreadsheet.
--Instead of inserting summary row, change the record type of the
--last record of the group from 'ENROLL' to 'POST'.
/*
	 INSERT_PROCESS_DEPENDENT
                (BATCH_ID                 => p_batch_id
                ,API_MODULE_ID            => l_prev_rec.api_module_id
                ,USER_SEQUENCE            => l_sequence
                ,LINK_VALUE               => l_prev_link
                ,BUSINESS_GROUP_NAME      => l_prev_rec.BUSINESS_GROUP_NAME
                ,P_LIFE_EVENT_DATE        => l_prev_rec.P_LIFE_EVENT_DATE
                ,P_EFFECTIVE_DATE         => l_prev_rec.P_EFFECTIVE_DATE
                ,P_PROGRAM                => l_prev_rec.P_PROGRAM
                ,P_PROGRAM_NUM            => l_prev_rec.P_PROGRAM_NUM
                ,P_PLAN                   => l_prev_rec.P_PLAN
                ,P_PLAN_NUM               => l_prev_rec.P_PLAN_NUM
                ,P_OPTION                 => l_prev_rec.P_OPTION
                ,P_OPTION_NUM             => l_prev_rec.P_OPTION_NUM
                ,P_LIFE_EVENT_REASON      => l_prev_rec.P_LIFE_EVENT_REASON
                ,P_EMPLOYEE_NUMBER        => l_prev_rec.P_EMPLOYEE_NUMBER
                ,P_NATIONAL_IDENTIFIER    => l_prev_rec.P_NATIONAL_IDENTIFIER
                ,P_FULL_NAME              => l_prev_rec.P_FULL_NAME
                ,P_DATE_OF_BIRTH          => l_prev_rec.P_DATE_OF_BIRTH
                ,P_PERSON_NUM             => l_prev_rec.P_PERSON_NUM
                );
         --
         l_sequence   := l_sequence + 1;
         --
*/
         update hrdpv_process_dependent
            set p_record_typ_cd = 'POST'
          where batch_id = p_batch_id
            and batch_line_id = l_prev_rec.batch_line_id;
	 --
      END IF;
      --UPDATE STATEMENT
      --
      update hrdpv_process_dependent
         set user_sequence = l_sequence ,
                link_value = l_link_value
       where batch_id = p_batch_id
         and batch_line_id = i.batch_line_id ;
      --
      --
      l_sequence := l_sequence + 1 ;
      --
      l_prev_link   := l_link_value ;
      l_person_num  := i.p_person_num;
      l_emp_num     := i.p_employee_number;
      l_ssn         := i.p_national_identifier;
      l_full_name   := i.p_full_name;
      l_dob         := i.p_date_of_birth;
      l_program     := i.p_program;
      l_program_num := i.p_program_num;
      l_plan        := i.p_plan;
      l_plan_num    := i.p_plan_num;
      l_record_typ  := i.p_record_typ_cd;
      --
      l_prev_rec := l_curr_rec ;
      --
    end loop;
    --
--NK
--Changes to eliminate summary row in Dependent Upload Spreadsheet.
--Instead of inserting summary row, change the record type of the
--last record of the group from 'ENROLL' to 'POST'.

    IF l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
/*
       --
--
--       IF l_prev_rec.P_PROGRAM IS NOT NULL OR
--          l_prev_rec.P_PROGRAM_NUM IS NOT NULL THEN
--          --
--          l_prev_rec.P_PLAN := null;
--          l_prev_rec.P_PLAN_NUM := null;
--          --
--       END IF ;
--
       --
       INSERT_PROCESS_DEPENDENT
                (BATCH_ID                 => p_batch_id
                ,API_MODULE_ID            => l_prev_rec.api_module_id
                ,USER_SEQUENCE            => l_sequence
                ,LINK_VALUE               => l_prev_link
                ,BUSINESS_GROUP_NAME      => l_prev_rec.BUSINESS_GROUP_NAME
                ,P_LIFE_EVENT_DATE        => l_prev_rec.P_LIFE_EVENT_DATE
                ,P_EFFECTIVE_DATE         => l_prev_rec.P_EFFECTIVE_DATE
                ,P_PROGRAM                => l_prev_rec.P_PROGRAM
                ,P_PROGRAM_NUM            => l_prev_rec.P_PROGRAM_NUM
                ,P_PLAN                   => l_prev_rec.P_PLAN
                ,P_PLAN_NUM               => l_prev_rec.P_PLAN_NUM
                ,P_OPTION                 => l_prev_rec.P_OPTION
                ,P_OPTION_NUM             => l_prev_rec.P_OPTION_NUM
                ,P_LIFE_EVENT_REASON      => l_prev_rec.P_LIFE_EVENT_REASON
                ,P_EMPLOYEE_NUMBER        => l_prev_rec.P_EMPLOYEE_NUMBER
                ,P_NATIONAL_IDENTIFIER    => l_prev_rec.P_NATIONAL_IDENTIFIER
                ,P_FULL_NAME              => l_prev_rec.P_FULL_NAME
                ,P_DATE_OF_BIRTH          => l_prev_rec.P_DATE_OF_BIRTH
                ,P_PERSON_NUM             => l_prev_rec.P_PERSON_NUM
                );
*/
       update hrdpv_process_dependent
          set p_record_typ_cd = 'POST'
        where batch_id = p_batch_id
          and batch_line_id = l_prev_rec.batch_line_id;
       --
    END IF;
    --

    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Leaving - module_name :pre_process_dependent' );
    --
  end pre_process_dependent ;
  --
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_BENEFICIARY >-------------------------|
-- -------------------------------------------------------------------------------+
procedure pre_process_beneficiary
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) is
    --
    cursor c_choices is
    select ch.*
      from hrdpv_process_beneficiary ch
     where ch.batch_id = p_batch_id
       and ch.line_status <> 'C'
     order by p_person_num,
              p_employee_number,
              p_national_identifier,
              p_full_name,
              p_date_of_birth,
              p_program,
              p_program_num,
              p_plan,
              p_plan_num,
              p_option,
              p_option_num,
              p_record_typ_cd
     for update;
    --
    l_link_value  hrdpv_process_dependent.link_value%TYPE := 0 ;
    l_sequence    hrdpv_process_dependent.user_sequence%TYPE := 1 ;
    l_person_num  hrdpv_process_dependent.p_person_num%TYPE;
    l_emp_num     hrdpv_process_dependent.p_employee_number%TYPE;
    l_ssn         hrdpv_process_dependent.p_national_identifier%TYPE;
    l_full_name   hrdpv_process_dependent.p_full_name%TYPE;
    l_dob         hrdpv_process_dependent.p_date_of_birth%TYPE;
    l_program     hrdpv_process_dependent.p_program%TYPE;
    l_program_num hrdpv_process_dependent.p_program_num%TYPE;
    l_plan        hrdpv_process_dependent.p_plan%TYPE;
    l_plan_num    hrdpv_process_dependent.p_plan_num%TYPE;
    l_record_typ  hrdpv_process_dependent.p_record_typ_cd%TYPE ;
    --
    l_person_change boolean := true;
    --
    l_prev_rec    c_choices%ROWTYPE;
    l_curr_rec    c_choices%ROWTYPE;
    l_prev_link   hrdpv_process_dependent.link_value%TYPE ;
    --
  begin
    --
    /*  IMPORTANT to enforce the following assumptions. Otherwise we need to enhance our
        code to handle those cases.
     --In a batch data needs to be consistent which means
     --Person Data - Use either employee_number or SSN or Fullname plus DOB or Person num
     --Plan design - Use either comp object name or num but can't use num for some plans
                     and name for some other plans.
    */
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - module_name :pre_process_beneficiary' );
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Batch ID: '||p_batch_id );
    --
    --Update Header for ATOMIC_LINKED_CALLS
    --we need patch 4665288 applied for this.
    UPDATE hr_pump_batch_headers bh
       SET bh.ATOMIC_LINKED_CALLS = 'Y'
     WHERE bh.batch_id = p_batch_id ;
    --
    fnd_file.put_line
        (which => fnd_file.log,
         buff  => 'Updated Header for ATOMIC_LINKED_CALLS');
    --
    --
    UPDATE hrdpv_process_beneficiary
       SET P_RECORD_TYP_CD = 'ENROLL'
    WHERE batch_id = p_batch_id;
    --
    --

    for i in c_choices loop
      --
      l_curr_rec := i;
      --
      l_person_change := true;
      --
      IF i.p_person_num IS NOT NULL THEN
        --
        IF i.p_person_num = l_person_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_employee_number IS NOT NULL THEN
        --
        IF i.p_employee_number = l_emp_num THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_national_identifier IS NOT NULL THEN
        --
        IF i.p_national_identifier = l_ssn THEN
          l_person_change := false;
        END IF;
        --
      ELSIF i.p_full_name IS NOT NULL AND i.p_date_of_birth IS NOT NULL THEN
        --
        IF i.p_full_name = l_prev_rec.p_full_name AND
           i.p_date_of_birth = l_prev_rec.p_date_of_birth THEN
          --
          l_person_change := false;
          --
        END IF;
        --
      END IF;
      --
      IF l_person_change THEN
        --
        --Now check if the last person record exists and if the record type is not
        --POST then create on record for post with the previous record information.
        --
        l_link_value := l_link_value + 1;
        --
      ELSIF i.p_program is NOT NULL OR i.p_program_num IS NOT NULL THEN
        --
        IF i.p_program IS NOT NULL THEN
          --
          IF i.p_program <> l_program THEN
            --If Program is changing and the last record type is not POST
            --then create a record for POST
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            --
            IF i.p_plan <> l_prev_rec.p_plan THEN
              l_link_value := l_link_value + 1;
            ELSE
               IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
                 IF i.p_option IS NOT NULL THEN
                   IF i.p_option <> l_prev_rec.p_option THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 ELSE
                   IF i.p_option_num <> l_prev_rec.p_option_num THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 END IF;
               END IF;
            END IF;
            --
          END IF;
          --
        ELSE
          --
          IF i.p_program_num <> l_program_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            --
            IF i.p_plan <> l_plan THEN
              l_link_value := l_link_value + 1;
            ELSE
               IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
                 IF i.p_option IS NOT NULL THEN
                   IF i.p_option <> l_prev_rec.p_option THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 ELSE
                   IF i.p_option_num <> l_prev_rec.p_option_num THEN
                     l_link_value := l_link_value + 1;
                   END IF;
                 END IF;
               END IF;
            END IF;
            --
          END IF;
          --
        END IF;
        --
      ELSE
        --
        IF i.p_plan IS NOT NULL THEN
          --
          IF i.p_plan <> l_plan THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
              IF i.p_option IS NOT NULL THEN
                IF i.p_option <> l_prev_rec.p_option THEN
                  l_link_value := l_link_value + 1;
                END IF;
              ELSE
                IF i.p_option_num <> l_prev_rec.p_option_num THEN
                  l_link_value := l_link_value + 1;
                END IF;
              END IF;
            END IF;
          END IF;
          --
        ELSE
          --
          IF i.p_plan_num <> l_plan_num THEN
            --
            l_link_value := l_link_value + 1;
            --
          ELSE
            IF i.p_option IS NOT NULL OR i.p_option_num IS NOT NULL THEN
              IF i.p_option IS NOT NULL THEN
                IF i.p_option <> l_prev_rec.p_option THEN
                  l_link_value := l_link_value + 1;
                END IF;
              ELSE
                IF i.p_option_num <> l_prev_rec.p_option_num THEN
                  l_link_value := l_link_value + 1;
                END IF;
              END IF;
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      IF l_prev_link <> l_link_value AND l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
         --
         update hrdpv_process_beneficiary
            set p_record_typ_cd = 'POST'
          where batch_id = p_batch_id
            and batch_line_id = l_prev_rec.batch_line_id;
	 --
      END IF;
      --UPDATE STATEMENT
      --
      update hrdpv_process_beneficiary
         set user_sequence = l_sequence ,
                link_value = l_link_value
       where batch_id = p_batch_id
         and batch_line_id = i.batch_line_id ;
      --
      --
      l_sequence := l_sequence + 1 ;
      --
      l_prev_link   := l_link_value ;
      l_person_num  := i.p_person_num;
      l_emp_num     := i.p_employee_number;
      l_ssn         := i.p_national_identifier;
      l_full_name   := i.p_full_name;
      l_dob         := i.p_date_of_birth;
      l_program     := i.p_program;
      l_program_num := i.p_program_num;
      l_plan        := i.p_plan;
      l_plan_num    := i.p_plan_num;
      l_record_typ  := i.p_record_typ_cd;
      --
      l_prev_rec := l_curr_rec ;
      --
    end loop;
    --
    IF l_prev_rec.P_RECORD_TYP_CD <> 'POST' THEN
       --
       update hrdpv_process_beneficiary
          set p_record_typ_cd = 'POST'
        where batch_id = p_batch_id
          and batch_line_id = l_prev_rec.batch_line_id;
       --
    END IF;
    --

    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Leaving - module_name :pre_process_beneficiary' );
    --
  end pre_process_beneficiary;
  --
end ben_pre_datapump_process;

/
