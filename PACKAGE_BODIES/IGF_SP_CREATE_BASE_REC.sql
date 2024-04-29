--------------------------------------------------------
--  DDL for Package Body IGF_SP_CREATE_BASE_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_CREATE_BASE_REC" AS
/* $Header: IGFSP01B.pls 120.8 2006/02/14 23:07:02 ridas ship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm (Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This package deals with the creation of equivalent records of OSS in
  --          Financial Aid system. The system is a pre-requisite for Assigning students
  --          sponsor and also for sponsor award process.
  --          It has the following procedure/function:
  --             i)  procedure create_base_record  - this is the main procedure called
  --                 from the concurrent manager
  --            ii)  function create_fa_base_record - this is a function called from
  --                 create_base_records for actual creation of the base records
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --svuppala    06-Dec-2005     Bug#4767660 Not able to assign a student to sponsorship
  --                            Modified Function: create_fa_base_record.
  -- svuppala    14-Oct-04      Bug # 3416936 Modified TBH call to addeded field
  --                            Eligible for Additional Unsubsidized Loans
  -- vvutukur    18-Jul-2003     Enh#3038511.FICR106 Build. Modified procedure create_base_record.
  -- shtatiko    15-MAR-2003     Bug# 2772277, Modified create_base_record and added log_parameter
  -- vchappid    26-Feb-2003     Bug#2747335, In function igf_sp_assign_pub, Base ID will be returned
  --                            when there exists Base ID for the Award Calendar Instance
  -- shtaiko     24-JAN-2003     Bug# 2684853, Modified create_fa_base_record
  -- smadathi    03-jun-2003     Bug 2620288. Modified procedures create_base_record,
  --                            write_log_file
  -- masehgal   03-Nov-2002     # 2613546  FA 105_108 Multi Award Years
  --                            Added pell alt expense in fa base call
  -- masehgal   25-Sep-2002     FA 104 - To Do Enhancements
  --                            Added manual_disb_hold in FA Base update
  -- smadathi   14-Jun-2002     Bug 2413695. write_log_file_head modified.
  -- | gvarapra   14-sep-2004         FA138 - ISIR Enhancements                    |
  -- |                                Changed arguments in call to                 |
  -- |                                IGF_AP_FA_BASE_RECORD_PKG.                   |
  -------------------------------------------------------------------------------------

PROCEDURE log_parameter (
            p_c_param_name IN VARCHAR2,
            p_c_param_value IN VARCHAR2 ) AS
------------------------------------------------------------------------------------
--Created by  : shtatiko ( Oracle IDC)
--Date created: 24-MAR-2003
--
--Purpose:  This procedure will log the passed parameter and its value to the log file.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------------------------
BEGIN
  fnd_message.set_name('IGS','IGS_FI_CRD_INT_ALL_PARAMETER');
  fnd_message.set_token('PARM_TYPE', p_c_param_name);
  fnd_message.set_token('PARM_CODE', p_c_param_value);
  fnd_file.put_line(fnd_file.LOG, fnd_message.get );
END log_parameter;


PROCEDURE create_base_record
              (errbuf               OUT NOCOPY VARCHAR2,
               retcode              OUT NOCOPY NUMBER,
               p_award_year         IN  VARCHAR2,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_person_group_id    IN  igs_pe_prsid_grp_mem.group_id%TYPE,
               p_org_id             IN  NUMBER )
AS
 ------------------------------------------------------------------------------------
 --Created by  : smanglm ( Oracle IDC)
 --Date created: 2002/01/11
 --
 --Purpose:  Created as part of the build for DLD Sponsorship
 --          this is the main procedure called from the concurrent manager
 --
 --          parameter description:
 --          errbuf                   - standard conc. req. paramater
 --          retcode                  - standard conc. req. paramater
 --          p_award_year             - award year calendar for which base id
 --                                     needs to be created
 --          p_person_id              - Person ID for whom base id should be
 --                                     created in the FA system
 --          p_person_group_id        - Indicates Person Group Id for which base
 --                                     ids should be created in the FA system
 --
 --Known limitations/enhancements and/or remarks:
 --
 --Change History:
 --Who         When            What
 --ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call
 --                            to igf_ap_ss_pkg.get_pid
 --bvisvana    31-Aug-2005     FA 157 - Bug # 4382371 - Dynamic person Id Inclusion.
 --                            Removed the normal cursor c_person_id and made it as REF CURSOR
 --rasahoo     17-NOV-2003     FA 128 - ISIR update 2004-05
 --                            added new parameter award_fmly_contribution_type to
 --                            igf_ap_fa_base_rec_pkg.update_row
 --vvutukur    18-Jul-2003     Enh#3038511.FICR106 Build. Added call to generic procedure
 --                            igs_fi_crdapi_util.get_award_year_status to validate Award Year Status.
 --shtatiko    25-MAR-2003     Bug# 2772277, Added parameter logging for PERSON, NAME, STATUS and REASON
 --                            Removed write_log_file and write_log_file_head.
 --                            Added log_person_details and log_status procedures
 --smadathi    03-jun-2003     Bug 2620288. Modified cursor c_person_id to fetch
 --                            the records from view igs_pe_prsid_grp_mem
 --                            instead of igs_pe_prsid_grp_mem_v. This fix is done to remove
 --                            Non-mergable view exists in the select and to reduce shared memory
 --                            within the acceptable limit
 -------------------------------------------------------------------------------------
  l_cal_type             igs_ca_inst.cal_type%TYPE;
  l_sequence_number      igs_ca_inst.sequence_number%TYPE;
  l_message              VARCHAR2(4000);
  l_status               BOOLEAN;
  l_base_id              igf_ap_fa_base_rec.base_id%TYPE;
  l_count                NUMBER(1) := 0;
  l_v_awd_yr_status_cd   igf_ap_batch_aw_map.award_year_status_code%TYPE;
  l_v_message_name       fnd_new_messages.message_name%TYPE;

  TYPE RefCur IS REF CURSOR;
  c_person_id RefCur;
  l_person_id       hz_parties.party_id%TYPE;
  lv_status         VARCHAR2(1);
 	l_list            VARCHAR2(32767);
  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  /*
    cursor to fetch person_id based on the person_group_id
  */
  /*CURSOR c_person_id (cp_group_id igs_pe_prsid_grp_mem_v.group_id%TYPE) IS
  SELECT person_id
  FROM   igs_pe_prsid_grp_mem
  WHERE  group_id = cp_group_id
  AND    (TRUNC(start_date) <= TRUNC(SYSDATE) OR (start_date IS NULL))
  AND    (TRUNC(end_date)  >= TRUNC(SYSDATE) OR (end_date IS NULL));*/

   PROCEDURE log_person_details ( p_n_person_id  igs_pe_person.person_id%TYPE )
   AS
   ------------------------------------------------------------------------------------
   --Created by  : shtatiko ( Oracle IDC)
   --Date created: 25-MAR-2003
   --
   --Purpose:  To log person details.
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
  -------------------------------------------------------------------------------------

  CURSOR c_person_detail (cp_person_id igs_pe_person.person_id%TYPE) IS
  SELECT person_number,
         full_name
  FROM   igs_pe_person_base_v
  WHERE  person_id = cp_person_id;
  rec_person_detail c_person_detail%ROWTYPE;

  BEGIN
      OPEN c_person_detail(p_n_person_id);
      FETCH c_person_detail INTO rec_person_detail;
      log_parameter (
        p_c_param_name  => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_LOCKBOX', 'PERSON' ),
        p_c_param_value => rec_person_detail.person_number
      );
      log_parameter (
        p_c_param_name  => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_HOLDS', 'PERSON_NAME' ),
        p_c_param_value => rec_person_detail.full_name
      );
      CLOSE c_person_detail;
  END log_person_details;

   PROCEDURE log_status ( p_b_status IN BOOLEAN, p_c_message IN VARCHAR2 )
   AS
   ------------------------------------------------------------------------------------
   --Created by  : shtatiko ( Oracle IDC)
   --Date created: 25-MAR-2003
   --
   --Purpose:  To log status of creation of FA Base Record.
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
  -------------------------------------------------------------------------------------

  BEGIN
    IF p_b_status THEN
      log_parameter (
        p_c_param_name  => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_LOCKBOX', 'STATUS' ),
        p_c_param_value => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_LOCKBOX', 'SUCCESS' )
      );
      fnd_file.put_line ( fnd_file.LOG, '  ' || fnd_message.get_string('IGF', 'IGF_SP_SUCCESS') );
      fnd_file.put_line ( fnd_file.LOG, ' ');
    ELSE
      log_parameter (
        p_c_param_name  => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_LOCKBOX', 'STATUS' ),
        p_c_param_value => igs_fi_gen_gl.get_lkp_meaning ( 'IGS_FI_LOCKBOX', 'ERROR' )
      );
      fnd_file.put_line ( fnd_file.LOG, '  ' || p_c_message );
      fnd_file.put_line ( fnd_file.LOG, ' ');
    END IF;
  END log_status;

BEGIN
  /*
    set the org id
  */
  igf_aw_gen.set_org_id(p_org_id);
  /*
    either person id or person group id should be passed,
    both should not be passed.
    checking when none of them have been passed
  */
  IF p_person_id IS NULL AND p_person_group_id IS NULL THEN
      retcode := 2 ;
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      /*
        write to the log file
      */
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      RETURN;
  END IF;
  /*
    checking when both of p_person_id and p_person_group_id are passed
  */
  IF p_person_id IS NOT NULL AND p_person_group_id IS NOT NULL THEN
      retcode := 2 ;
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      /*
        write to the log file
      */
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_OR_PRSIDGRP');
      FND_FILE.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      RETURN;
  END IF;
  /*
    validation of parameters done
  */

  /*
    get the cal type and seq number based on alternate code (p_award_year passed)
  */
  l_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10))) ;
  l_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11)) ;

  l_v_message_name := NULL;
  --Validate the Award Year Status. If the status is not open, log the message in log file and
  --complete the process with error.
  igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  l_cal_type,
                                            p_n_awd_seq_number   =>  l_sequence_number,
                                            p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                            p_v_message_name     =>  l_v_message_name
                                           );
  IF l_v_message_name IS NOT NULL THEN
    retcode := 2;
    IF l_v_message_name = 'IGF_SP_INVALID_AWD_YR_STATUS' THEN
      fnd_message.set_name('IGF',l_v_message_name);
    ELSE
      fnd_message.set_name('IGS',l_v_message_name);
    END IF;
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,' ');
    RETURN;
  END IF;

  /*
    if person id is passed, call the function create_fa_base_record for that person id
    else fetch all the relevant person_id for the passed person group id
  */
  IF p_person_id IS NOT NULL THEN
     /*
       call the  function create_fa_base_record for this person id
     */
     l_status:= create_fa_base_record ( p_cal_type => l_cal_type,
                                        p_sequence_number => l_sequence_number,
                                        p_person_id => p_person_id,
                                        p_base_id   => l_base_id,
                                        p_message => l_message);
     l_count := 1;
     /*
       write the result to log file
     */
      -- Logging of parameters(PERSON, NAME, STATUS and REASON) has been added as part of
      -- Bug 2772277.
      log_person_details ( p_person_id );
      log_status ( l_status, l_message );

  ELSIF p_person_group_id IS NOT NULL THEN -- person_group_id is passed
     /*
       loop through all the person id present for the group id
     */
     -- FOR rec_person_id IN c_person_id (p_person_group_id)
     --FA 157 - Bug # 4382371 - Dynamic person Id Inclusion
     --Bug #5021084
     l_list := igf_ap_ss_pkg.get_pid(p_person_group_id,lv_status,lv_group_type);

     --Bug #5021084. Passing Group ID if the group type is STATIC.
     IF lv_group_type = 'STATIC' THEN
        OPEN c_person_id FOR 'SELECT party_id person_id FROM hz_parties WHERE party_id IN (' || l_list  || ') ' USING p_person_group_id;
     ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN c_person_id FOR 'SELECT party_id person_id FROM hz_parties WHERE party_id IN (' || l_list  || ') ';
     END IF;

     LOOP

             FETCH c_person_id INTO l_person_id;
             EXIT WHEN c_person_id%NOTFOUND;
             -- Logging of parameters(PERSON, NAME, STATUS and REASON) has been added as part of
             -- Bug 2772277.
             log_person_details (l_person_id);
             /*
               call the  function create_fa_base_record for all the person id
             */
             l_status:= create_fa_base_record ( p_cal_type => l_cal_type,
                                                p_sequence_number => l_sequence_number,
                                                p_person_id => l_person_id,
                                                p_base_id => l_base_id,
                                                p_message => l_message);
             /*
               write the result to log file
             */
              l_count := 1;
              log_status ( l_status, l_message );
     END LOOP;
  END IF;
  IF l_count = 0 THEN
    FND_MESSAGE.SET_NAME('IGF','IGF_SP_NO_PERSON');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2 ;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','create_base_records');
    errbuf := FND_MESSAGE.GET ;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
END create_base_record;

FUNCTION create_fa_base_record
              (p_cal_type           IN  igs_ca_inst.cal_type%TYPE,
               p_sequence_number    IN  igs_ca_inst.sequence_number%TYPE,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_base_id            OUT NOCOPY igf_ap_fa_base_rec.base_id%TYPE,
               p_message            OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
AS
 ------------------------------------------------------------------------------------
 --Created by  : smanglm ( Oracle IDC)
 --Date created: 2002/01/11
 --
 --Purpose:  Created as part of the build for DLD Sponsorship
 --          this is the private function to create the FA records
 --
 --          parameter description:
 --          p_cal_type               - calendar type for the award year
 --          p_sequence_number        - sequence_numver for teh award year
 --          p_person_id              - Person ID for whom base id should be
 --                                     created in the FA system
 --          p_message                - error messages generated to be passed back
 --
 --          ALERT                    - if this function is made public, validation
 --                                     for the parameters need to be added
 --
 --Known limitations/enhancements and/or remarks:
 --
 --Change History:
 --Who         When            What
 -- ridas      15-Feb-2006     Bug #5021084. Removed trunc function from cursor SSN_CUR
 --svuppala    06-Dec-2005     Bug#4767660 Not able to assign a student to sponsorship
 --                            While returning the error message the function fnd_message.get
 --                            was used 2 times. So, assigned p_message with IGF_AP_SSN_REQD
 --                            prior to logging the message. Used fnd_message.get to log the message.
 --rajagupt    06-Oct-2005     Bug#4068548 - added a new cursor ssn_cur
 --vchappid    26-Feb-2003     Bug#2747335, Base ID will be returned when there exists Base ID for
 --                            the Award Calendar Instance
 -- shtatiko   24-JAN-2003     Bug# 2584853, Added message IGF_AP_FA_BASE_REC_ALL
 -- masehgal   25-Sep-2002     FA 104 - To Do Enhancements
 --                            Added manual_disb_hold in FA Base update
 -------------------------------------------------------------------------------------
   l_rowid    igf_ap_fa_base_rec.ROW_ID%TYPE;
   l_base_id  igf_ap_fa_base_rec.BASE_ID%TYPE;
   /*
     cursor to see whether the FA records for the passsed in person id exists or not
   */
   CURSOR c_exists (cp_person_id igs_pe_person.person_id%TYPE,
                    cp_cal_type igs_ca_inst.cal_type%TYPE,
                    cp_sequence_number igs_ca_inst.sequence_number%TYPE) IS
          SELECT base_id
          FROM   igf_ap_fa_base_rec
          WHERE  person_id = cp_person_id
          AND    ci_cal_type = cp_cal_type
          AND    ci_sequence_number = cp_sequence_number;

   l_exists   c_exists%ROWTYPE;

-- cursor to get the ssn no of a person
   CURSOR ssn_cur(cp_person_id number) IS
          SELECT api_person_id,api_person_id_uf, end_dt
          FROM   igs_pe_alt_pers_id
          WHERE  pe_person_id=cp_person_id
          AND    person_id_type like 'SSN'
          AND    SYSDATE < = NVL(end_dt,SYSDATE);

	        rec_ssn_cur ssn_cur%ROWTYPE;
          lv_profile_value VARCHAR2(20);
 BEGIN

   /*
     create the FA records only when it does not exist
   */
   OPEN c_exists (p_person_id,
                  p_cal_type,
                  p_sequence_number);
   FETCH c_exists INTO l_exists;
   IF c_exists%NOTFOUND THEN
      /*
        create the FA base record
      */

     --check if the ssn no is available or not

     fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);


          IF (lv_profile_value = 'Y') THEN
            OPEN ssn_cur(p_person_id) ;
            FETCH ssn_cur INTO rec_ssn_cur;
            IF ssn_cur%NOTFOUND THEN
              fnd_message.set_name('IGF','IGF_AP_SSN_REQD');
              p_message := 'IGF_AP_SSN_REQD';
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RETURN FALSE;
            ELSE
              CLOSE ssn_cur;
            END IF;

          END IF;

          igf_ap_fa_base_rec_pkg.insert_row (
                            X_ROWID                          =>     l_rowid         ,
                            X_BASE_ID                        =>     l_base_id       ,
                            X_CI_CAL_TYPE                    =>     p_cal_type      ,
                            X_PERSON_ID                      =>     p_person_id     ,
                            X_CI_SEQUENCE_NUMBER             =>     p_sequence_number,
                            X_ORG_ID                         =>     NULL    ,
                            X_COA_PENDING                    =>     NULL    ,
                            X_VERIFICATION_PROCESS_RUN       =>     NULL    ,
                            X_INST_VERIF_STATUS_DATE         =>     NULL    ,
                            X_MANUAL_VERIF_FLAG              =>     NULL    ,
                            X_FED_VERIF_STATUS               =>     NULL    ,
                            X_FED_VERIF_STATUS_DATE          =>     NULL    ,
                            X_INST_VERIF_STATUS              =>     NULL    ,
                            X_NSLDS_ELIGIBLE                 =>     NULL    ,
                            X_EDE_CORRECTION_BATCH_ID        =>     NULL    ,
                            X_FA_PROCESS_STATUS_DATE         =>     NULL    ,
                            X_ISIR_CORR_STATUS               =>     NULL    ,
                            X_ISIR_CORR_STATUS_DATE          =>     NULL    ,
                            X_ISIR_STATUS                    =>     NULL    ,
                            X_ISIR_STATUS_DATE               =>     NULL    ,
                            X_COA_CODE_F                     =>     NULL    ,
                            X_COA_CODE_I                     =>     NULL    ,
                            X_COA_F                          =>     NULL    ,
                            X_COA_I                          =>     NULL    ,
                            X_DISBURSEMENT_HOLD              =>     NULL    ,
                            X_FA_PROCESS_STATUS              =>     NULL    ,
                            X_NOTIFICATION_STATUS            =>     NULL    ,
                            X_NOTIFICATION_STATUS_DATE       =>     NULL    ,
                            X_PACKAGING_STATUS               =>     NULL    ,
                            X_PACKAGING_STATUS_DATE          =>     NULL    ,
                            X_TOTAL_PACKAGE_ACCEPTED         =>     NULL    ,
                            X_TOTAL_PACKAGE_OFFERED          =>     NULL    ,
                            X_ADMSTRUCT_ID                   =>     NULL    ,
                            X_ADMSEGMENT_1                   =>     NULL    ,
                            X_ADMSEGMENT_2                   =>     NULL    ,
                            X_ADMSEGMENT_3                   =>     NULL    ,
                            X_ADMSEGMENT_4                   =>     NULL    ,
                            X_ADMSEGMENT_5                   =>     NULL    ,
                            X_ADMSEGMENT_6                   =>     NULL    ,
                            X_ADMSEGMENT_7                   =>     NULL    ,
                            X_ADMSEGMENT_8                   =>     NULL    ,
                            X_ADMSEGMENT_9                   =>     NULL    ,
                            X_ADMSEGMENT_10                  =>     NULL    ,
                            X_ADMSEGMENT_11                  =>     NULL    ,
                            X_ADMSEGMENT_12                  =>     NULL    ,
                            X_ADMSEGMENT_13                  =>     NULL    ,
                            X_ADMSEGMENT_14                  =>     NULL    ,
                            X_ADMSEGMENT_15                  =>     NULL    ,
                            X_ADMSEGMENT_16                  =>     NULL    ,
                            X_ADMSEGMENT_17                  =>     NULL    ,
                            X_ADMSEGMENT_18                  =>     NULL    ,
                            X_ADMSEGMENT_19                  =>     NULL    ,
                            X_ADMSEGMENT_20                  =>     NULL    ,
                            X_PACKSTRUCT_ID                  =>     NULL    ,
                            X_PACKSEGMENT_1                  =>     NULL    ,
                            X_PACKSEGMENT_2                  =>     NULL    ,
                            X_PACKSEGMENT_3                  =>     NULL    ,
                            X_PACKSEGMENT_4                  =>     NULL    ,
                            X_PACKSEGMENT_5                  =>     NULL    ,
                            X_PACKSEGMENT_6                  =>     NULL    ,
                            X_PACKSEGMENT_7                  =>     NULL    ,
                            X_PACKSEGMENT_8                  =>     NULL    ,
                            X_PACKSEGMENT_9                  =>     NULL    ,
                            X_PACKSEGMENT_10                 =>     NULL    ,
                            X_PACKSEGMENT_11                 =>     NULL    ,
                            X_PACKSEGMENT_12                 =>     NULL    ,
                            X_PACKSEGMENT_13                 =>     NULL    ,
                            X_PACKSEGMENT_14                 =>     NULL    ,
                            X_PACKSEGMENT_15                 =>     NULL    ,
                            X_PACKSEGMENT_16                 =>     NULL    ,
                            X_PACKSEGMENT_17                 =>     NULL    ,
                            X_PACKSEGMENT_18                 =>     NULL    ,
                            X_PACKSEGMENT_19                 =>     NULL    ,
                            X_PACKSEGMENT_20                 =>     NULL    ,
                            X_MISCSTRUCT_ID                  =>     NULL    ,
                            X_MISCSEGMENT_1                  =>     NULL    ,
                            X_MISCSEGMENT_2                  =>     NULL    ,
                            X_MISCSEGMENT_3                  =>     NULL    ,
                            X_MISCSEGMENT_4                  =>     NULL    ,
                            X_MISCSEGMENT_5                  =>     NULL    ,
                            X_MISCSEGMENT_6                  =>     NULL    ,
                            X_MISCSEGMENT_7                  =>     NULL    ,
                            X_MISCSEGMENT_8                  =>     NULL    ,
                            X_MISCSEGMENT_9                  =>     NULL    ,
                            X_MISCSEGMENT_10                 =>     NULL    ,
                            X_MISCSEGMENT_11                 =>     NULL    ,
                            X_MISCSEGMENT_12                 =>     NULL    ,
                            X_MISCSEGMENT_13                 =>     NULL    ,
                            X_MISCSEGMENT_14                 =>     NULL    ,
                            X_MISCSEGMENT_15                 =>     NULL    ,
                            X_MISCSEGMENT_16                 =>     NULL    ,
                            X_MISCSEGMENT_17                 =>     NULL    ,
                            X_MISCSEGMENT_18                 =>     NULL    ,
                            X_MISCSEGMENT_19                 =>     NULL    ,
                            X_MISCSEGMENT_20                 =>     NULL    ,
                            X_PROF_JUDGEMENT_FLG             =>     NULL    ,
                            X_NSLDS_DATA_OVERRIDE_FLG        =>     NULL    ,
                            X_TARGET_GROUP                   =>     NULL    ,
                            X_COA_FIXED                      =>     NULL    ,
                            X_COA_PELL                       =>     NULL    ,
                            X_MODE                           =>     'R'     ,
                            X_PROFILE_STATUS                 =>     NULL    ,
                            X_PROFILE_STATUS_DATE            =>     NULL    ,
                            X_PROFILE_FC                     =>     NULL    ,
                            X_TOLERANCE_AMOUNT               =>     NULL    ,
                            x_manual_disb_hold               =>     NULL    ,
                            x_pell_alt_expense               =>     NULL    ,
                            x_assoc_org_num                  =>     NULL    ,
                            x_award_fmly_contribution_type   =>     '1',
                            x_isir_locked_by                 =>     NULL,
                            x_adnl_unsub_loan_elig_flag      => 'N',
                            x_lock_awd_flag                  => 'N',
                            x_lock_coa_flag                  => 'N'
                            );


      CLOSE c_exists;
      p_base_id := l_base_id;
      p_message := NULL;
      RETURN TRUE;
   ELSE
      /*
        return FALSE with error message
      */
      -- when the BaseID is already existing for the Person, Award Calendar Instance then this function will assign
      -- the existing base_id to the OUT varaible. This function is being called in igf_sp_assign_pub (IGFSP05B.pls)
      -- when there already exists a Base ID then even though the return status is FALSE, Base ID will be used for
      -- further processing in igf_sp_assign_pub
      p_base_id := l_exists.base_id;
      CLOSE c_exists;
      -- Changed this message to include token, person name as per Bug# 2684853
      fnd_message.set_name('IGS', 'IGS_FI_FA_BASE_REC_ALL');
      fnd_message.set_token ('PERSON_NAME', igs_ge_gen_001.adm_get_name(p_person_id) );
      p_message := fnd_message.get ;
      RETURN FALSE;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
      IF c_exists%ISOPEN THEN
         CLOSE c_exists;
      END IF;
      p_base_id := NULL;
      p_message := FND_MESSAGE.GET;
      RETURN FALSE;
 END create_fa_base_record;

END igf_sp_create_base_rec;

/
