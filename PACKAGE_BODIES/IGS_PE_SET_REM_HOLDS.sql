--------------------------------------------------------
--  DDL for Package Body IGS_PE_SET_REM_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_SET_REM_HOLDS" AS
/* $Header: IGSPE08B.pls 120.2 2006/02/02 06:57:24 skpandey noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 25-SEP-2001
  --
  --Purpose: Package Body contains code for procedures/Functions defined in
  --         package specification . Also body includes Functions/Procedures
  --         private to it .
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --npalanis    30-apr-2002     The display of person id during setting or releasing
  --                            holds is changed to person number.
  --                            The full name is nullable so nvl of space is given for
  --                            full name.
  --ssawhney    17-feb-2003     Bug 2758856  external holds design change, ENCUMB TBH parameter added.
  --pkpatel     8-APR-2003      Bug 2804863. Modified set_prsid_grp_holds and rel_prsid_grp_holds procedures.
  --gmaheswa    29-OCT-2003     Bug 3198795  Modified set_prsid_grp_holds and rel_prsid_grp_holds procedures for
  --                                         Introducing dynamic person id groups.
  --asbala      26-DEC-2003     3338759, Modified the substr() call to retrieve l_seq_num in set_prsid_grp_holds.
  --                In rel_prsid_grp_holds, when the hold doesnot exist, the process will not
  --                error out. Added ROLLBACK stmts in set_prsid_grp_holds and rel_prsid_grp_holds.
  --pkpatel     6-JAn-2004     3338759, Used TRIM for Cal type in Rel, Moved the Savepoint before Begin in Set Hold
  -------------------------------------------------------------------

  FUNCTION lookup_desc( l_type IN VARCHAR2 ,
                        l_code IN VARCHAR2 )
                        RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 25-SEP-2001
  --
  --Purpose: This function is private to this package body . This Procedure returns the
  --         meaning from look up table
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR c_desc( x_type igs_lookups_view.lookup_type%TYPE , x_code  igs_lookups_view.lookup_code%TYPE ) IS
    SELECT meaning
    FROM   igs_lookups_view
    WHERE  lookup_code = x_code
    AND    lookup_type = x_type ;

    l_desc igs_lookups_view.meaning%TYPE ;

 BEGIN

   IF l_code IS NULL THEN
     RETURN NULL ;
   ELSE
      OPEN c_desc(l_type,l_code);
      FETCH c_desc INTO l_desc ;
      CLOSE c_desc ;
   END IF ;

   RETURN l_desc ;

 END lookup_desc;  /** Function Ends Here   **/


  PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                           p_msg_val   VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 25-SEP-2001
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

  PROCEDURE set_prsid_grp_holds ( errbuf           OUT NOCOPY VARCHAR2                                         ,
                                  retcode          OUT NOCOPY NUMBER                                           ,
                                  p_hold_type      IN  igs_pe_pers_encumb_v.encumbrance_type%TYPE       ,
                                  p_pid_group      IN  igs_pe_persid_group_v.group_id%TYPE              ,
                                  p_start_dt       IN  VARCHAR2                                         ,
                                  p_term           IN  VARCHAR2                                         ,
                                  p_org_id         IN  NUMBER
                                 ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 25-SEP-2001
  --
  --Purpose: The concurrent manager initiates this procedure. This concurrent process set
  --         new holds for all members in a person ID group , using the specified parameters.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel     30-SEP-2002     Bug NO: 2600842
  --                            Added the validation for implementing security feature with respect to Authorising Person.
  --                            Removed the parameter p_authorizing_id
  --                            Added the check to consider only the active members of the person ID group
  --                            Call the user defined exception instead of app_exception.raise_exception, so that
  --                            the message Unhandled Exception does not come for business validations failed
  --ssawhney    17-feb-2003     Bug 2758856  external holds design change, ENCUMB TBH parameter added.
  --pkpatel     8-APR-2003      Bug 2804863 igs_pe_gen_001.g_hold_validation variable was set to 'N' at the beginning and 'Y' at the end.
  --gmaheswa    29-OCT-2003     Bug 3198795 Introducing DYNAMIC PERSON ID group functionality
  --asbala      5-JAN-2003      3338759, Changes mentioned along with bug no. in corresponding places
  --skpandey    02-FEB-2006     Bug#4937960: Changed call to igs_get_dynamic_sql to get_dynamic_sql as a part of literal fix
  -------------------------------------------------------------------
    l_cal_type       igs_ca_inst.cal_type%TYPE        ;
    l_seq_num        igs_ca_inst.sequence_number%TYPE ;
    l_start_date     igs_ca_inst.start_dt%TYPE        ;
    l_rowid          igs_pe_prsid_grp_mem.row_id%TYPE;
    l_message_name   VARCHAR2(30)   ;
    l_message_string VARCHAR2(900)  ;
    l_msg_str_0      VARCHAR2(1000) ;
    l_msg_str_1      VARCHAR2(1000) ;
    l_err_raised     BOOLEAN := FALSE;
    l_resp_id      fnd_responsibility.responsibility_id%TYPE := FND_GLOBAL.RESP_ID;

    l_error_exception  EXCEPTION ;  /* user defined exception */
    l_person_id    hz_parties.party_id%TYPE;
    l_person_number hz_parties.party_number%TYPE;
    l_person_name   hz_person_profiles.person_name%TYPE;

    L_select VARCHAR2(32767) := 'SELECT p.person_id,p.person_number,p.full_name FROM igs_pe_person_base_v p WHERE p.person_id IN ';
    TYPE cur_query IS REF CURSOR;
    c_cur_query cur_query;

    TYPE rec_query IS RECORD (
          person_id     NUMBER(30),
          person_number VARCHAR2(100),
          full_name  VARCHAR2(240)
      );
    r_rec_query rec_query;

    L_str VARCHAR2(32000);
    l_status VARCHAR2(1);

    l_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

  BEGIN

    IGS_GE_GEN_003.set_org_id(p_org_id) ;                /**  sets the orgid                      **/
    retcode := 0 ;                                       /**  initialises the out NOCOPY parameter to 0  **/

     -- Set the variable to 'N' to prevent the security level validation to happen for each record.
    igs_pe_gen_001.g_hold_validation := 'N';

    IF p_term IS NOT NULL THEN
      l_cal_type   := TRIM(SUBSTR(p_term,1,10)) ;
      l_seq_num    := FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(p_term,-6)) ; --3338759: To get the 6-digit sequence number
      l_start_date := IGS_GE_DATE.IGSDATE(SUBSTR(p_term,12,10));
    ELSE
      l_start_date  :=  IGS_GE_DATE.IGSDATE(p_start_dt) ;  /**  Character to date conversion        **/
    END IF;

    -- logs all the parameters
    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','PERS_ID_GROUP'),20)||':',p_pid_group);
    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','HOLD_TYPE'),20)||':',p_hold_type);

    -- if p_term parameter is entered by the user only then this parameter is logged in log file
    IF p_term IS NOT NULL THEN
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','TERM'),20)||':',p_term);
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','CAL_TYPE'),20)||':',l_cal_type);
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','SEQ_NUM'),20)||':',l_seq_num);
    END IF;

    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','START_DT'),20)||':',IGS_GE_DATE.IGSCHARDT(l_start_date));

    FND_FILE.NEW_LINE(FND_FILE.LOG,2);                    /** writes 2 new line characters **/

    -- if both start date and term parameters are passed as null , error out NOCOPY of the process
    IF p_start_dt IS NULL AND p_term IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_TERM_OR_START_DT') ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
    END IF;

    -- if both start date and term parameters are passed as not null's , error out NOCOPY of the process
    IF p_start_dt IS NOT NULL AND p_term IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_TERM_OR_START_DT') ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
    END IF;

     -- Validate that the person who has logged in has a party account and
     -- is a STAFF. If he fails any of the above then is not authorized to release the hold.
       igs_pe_gen_001.get_hold_auth(FND_GLOBAL.USER_ID,
                                  l_person_id,
                                  l_person_number,
                                  l_person_name,
                                  l_message_name);

      IF l_message_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS',l_message_name) ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
     END IF;

     -- ssawhney commented the above call as its already happening in the TBH

    l_msg_str_0  :=   RPAD(lookup_desc('IGS_PE_HOLDS','PERSON'),30) ||
                      RPAD(lookup_desc('IGS_PE_HOLDS','NAME'),452)||
                      RPAD(lookup_desc('IGS_PE_HOLDS','HOLD_TYPE'),12)||
                      RPAD(lookup_desc('IGS_PE_HOLDS','CAL_TYPE'),15)||
                      RPAD(lookup_desc('IGS_PE_HOLDS','SEQ_NUM'),17)||
                      RPAD(lookup_desc('IGS_PE_HOLDS','START_DT'),11);

    FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str_0);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

   --get the query for the members in the group passed
   L_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_pid_group,l_status, l_group_type);
   IF l_status <> 'S' THEN
      RAISE NO_DATA_FOUND;
   END IF;
   L_select := L_select||'('||L_str||')';
   --skpandey, Bug#4937960: Added logic as a part of literal fix
   IF l_group_type = 'STATIC' THEN
    OPEN c_cur_query FOR L_select USING p_pid_group ;
   ELSIF l_group_type = 'DYNAMIC' THEN
    OPEN c_cur_query FOR L_select;
   END IF;
    LOOP
      FETCH c_cur_query INTO r_rec_query; ----l_per_id,l_per_number,l_full_name;
      EXIT WHEN c_cur_query%NOTFOUND;
      SAVEPOINT sp_person;
      l_err_raised := FALSE ;
      BEGIN
        l_msg_str_1    :=  RPAD(r_rec_query.person_number,30) ||
                           RPAD(NVL(r_rec_query.full_name,' '),452)         ||
                           RPAD(p_hold_type,12)                   ||
                           NVL(RPAD(l_cal_type,15),'               ')||
                           NVL(RPAD(TO_CHAR(l_seq_num),17),'                 ')||
                           RPAD(IGS_GE_DATE.IGSCHARDT(l_start_date),11) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str_1);

		igs_pe_pers_encumb_pkg.insert_row
        (
              x_mode                     =>   'R'                     ,
              x_rowid                    =>   l_rowid                 ,
              x_person_id                =>   r_rec_query.person_id    ,
              x_encumbrance_type         =>   p_hold_type             ,
              x_start_dt                 =>   l_start_date            ,
              x_expiry_dt                =>   NULL                    ,
              x_authorising_person_id    =>   l_person_id,
              x_comments                 =>   NULL                    ,
              x_spo_course_cd            =>   NULL                    ,
              x_spo_sequence_number      =>   NULL                    ,
              x_cal_type                 =>   l_cal_type              ,
              x_sequence_number          =>   l_seq_num ,
              x_auth_resp_id             =>   l_resp_id ,
              x_external_reference       =>   NULL   -- this should be explicitly NULL while coming from Internal system
        ) ;

      EXCEPTION
        WHEN OTHERS THEN
          l_err_raised := TRUE ;
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          ROLLBACK TO sp_person; -- 3338759: Rollback to SAVEPOINT sp_person in case of exception
      END ;

      IF NOT (l_err_raised) THEN
    BEGIN
          --check if the encumbrance has effects which require that the active
          -- enrolments be dicontinued , validate that SCA'S are inactive
          IF igs_en_val_pen.finp_val_encmb_eff ( r_rec_query.person_id ,
                                                 p_hold_type          ,
                                                 l_start_date         ,
                                                 NULL                 ,
                                                 l_message_name
                                                ) = FALSE
          THEN
            ROLLBACK TO sp_person;
            FND_MESSAGE.SET_NAME('IGS',l_message_name) ;
            IGS_GE_MSG_STACK.ADD;
            RAISE l_error_exception ;
          END IF;

          -- call the procedure which creates the default effects for the encumbrance type .
          igs_en_gen_009.enrp_ins_dflt_effect ( r_rec_query.person_id ,
                                                p_hold_type          ,
                                                l_start_date         ,
                                                NULL                 ,
                                                NULL                 ,
                                                l_message_name       ,
                                                l_message_string
                                               ) ;
          IF l_message_name IS NOT NULL THEN
            ROLLBACK TO sp_person;
            FND_MESSAGE.SET_NAME('IGS',l_message_name) ;
            IGS_GE_MSG_STACK.ADD;
            RAISE l_error_exception ;
          END IF;

    EXCEPTION
      WHEN OTHERS THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END ;
    END IF;
    END LOOP ;
    CLOSE c_cur_query;
    igs_pe_gen_001.g_hold_validation := 'Y';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      retcode := 2;
      igs_pe_gen_001.g_hold_validation := 'Y';
      FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERSID_GROUP_EXP') ;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    WHEN l_error_exception THEN
     retcode := 2;
     igs_pe_gen_001.g_hold_validation := 'Y';
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    WHEN OTHERS THEN
      retcode := 2;
      igs_pe_gen_001.g_hold_validation := 'Y';
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

  END set_prsid_grp_holds ;                      /** procedure ends here **/


  PROCEDURE rel_prsid_grp_holds ( errbuf           OUT NOCOPY VARCHAR2                                         ,
                                  retcode          OUT NOCOPY NUMBER                                           ,
                                  p_hold_type      IN  igs_pe_pers_encumb_v.encumbrance_type%TYPE       ,
                                  p_pid_group      IN  igs_pe_persid_group_v.group_id%TYPE              ,
                                  p_start_dt       IN  VARCHAR2                                         ,
                                  p_expiry_dt      IN  VARCHAR2                                         ,
                                  p_term           IN  VARCHAR2                                         ,
                                  p_org_id         IN  NUMBER
                                 ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 25-SEP-2001
  --
  --Purpose: The concurrent manager initiates this procedure. This concurrent process release
  --         holds for all memebers in a person ID group, using the specified parameters and
  --         logic.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel     30-SEP-2002     Bug NO: 2600842
  --                            Added the validation for implementing security feature with respect to Authorising Person.
  --                            Removed the parameter p_authorizing_id
  --                            Added the check to consider only the active members of the person ID group
  --                            Call the user defined exception instead of app_exception.raise_exception, so that
  --                            the message Unhandled Exception does not come for business validations failed
  --pkpatel     8-APR-2003      Bug 2804863 igs_pe_gen_001.g_hold_validation variable was set to 'N' at the beginning and 'Y' at the end.
  --                            Added the call of igs_pe_gen_001.get_hold_auth
  --gmaheswa    29-OCT-2003     Bug 3198795 Introducing DYNAMIC PERSON ID group functionality
  --skpandey    12-JAN-2006     Bug#4937960
  --                            Changed c_igs_pe_pers_encumb Cursor definition to optimize query
  --skpandey    02-FEB-2006     Bug#4937960: Changed call to igs_get_dynamic_sql to get_dynamic_sql as a part of literal fix
  -------------------------------------------------------------------
    l_cal_type       igs_ca_inst.cal_type%TYPE         ;
    l_seq_num        igs_ca_inst.sequence_number%TYPE  ;
    l_start_date     igs_ca_inst.start_dt%TYPE ;
    l_expiry_date    igs_ca_inst.start_dt%TYPE ;
    l_rowid          igs_pe_prsid_grp_mem.row_id%TYPE;
    l_message_name   VARCHAR2(30);
    l_message_string VARCHAR2(900);
    l_msg_str_0      VARCHAR2(1000);
    l_msg_str_1      VARCHAR2(1000);
    l_err_raised     BOOLEAN := FALSE;

    l_resp_id      fnd_responsibility.responsibility_id%TYPE := FND_GLOBAL.RESP_ID;
    l_fnd_user_id  fnd_user.user_id%TYPE := FND_GLOBAL.USER_ID;
    l_person_id    hz_parties.party_id%TYPE;
    l_person_number hz_parties.party_number%TYPE;
    l_person_name   hz_person_profiles.person_name%TYPE;


    -- cursor selects row_id from igs_pe_pers_encumb table based on person id and hold type
    CURSOR c_igs_pe_pers_encumb(cp_person_id  igs_pe_pers_encumb_v.person_id%TYPE               ,
                                          cp_hold_type  igs_pe_pers_encumb_v.encumbrance_type%TYPE ,
                                          cp_start_dt   igs_pe_pers_encumb_v.start_dt%TYPE) IS
    SELECT           *
    FROM             IGS_PE_PERS_ENCUMB
    WHERE            person_id         = cp_person_id
    AND              encumbrance_type  = cp_hold_type
    AND              start_dt          = cp_start_dt
    AND              (expiry_dt IS NULL OR SYSDATE < expiry_dt);

    l_c_igs_pe_pers_encumb   c_igs_pe_pers_encumb%ROWTYPE ;  -- cursor variable for the above cursor
    l_error_exception  EXCEPTION ;  /* user defined exception */
    l_ignore_exception  EXCEPTION ;  /* user defined exception */ -- for logging the error and stopping of further processing.
                                  -- concurrent pgm will not error out.
    L_select VARCHAR2(32767) := 'SELECT p.person_id,p.person_number,p.full_name FROM igs_pe_person_base_v p WHERE p.person_id IN ';
    TYPE cur_query IS REF CURSOR;
    c_cur_query cur_query;

    TYPE rec_query IS RECORD (
          person_id     NUMBER(30),
          person_number VARCHAR2(100),
          full_name  VARCHAR2(240)
      );
    r_rec_query rec_query;

    L_str VARCHAR2(32000);
    l_status VARCHAR2(1);

    l_group_type IGS_PE_PERSID_GROUP_V.group_type%type;

  BEGIN
    IGS_GE_GEN_003.set_org_id(p_org_id) ;                /**  sets the orgid                      **/
    retcode := 0 ;                                       /**  initialises the out NOCOPY parameter to 0  **/

    -- Set the variable to 'N' to prevent the security level validation to happen for each record.
    igs_pe_gen_001.g_hold_validation := 'N';

    IF p_term IS NOT NULL THEN
      l_cal_type    := TRIM(SUBSTR(p_term,1,10)) ;
      l_seq_num     := FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(p_term,-6)); --3338759: To get the 6-digit sequence number
      l_start_date  := IGS_GE_DATE.IGSDATE(SUBSTR(p_term,12,10));
      l_expiry_date := IGS_GE_DATE.IGSDATE(SUBSTR(p_term,23,10));
    ELSE
      l_start_date   :=  IGS_GE_DATE.IGSDATE(p_start_dt) ;   /**  Character to date conversion        **/
      l_expiry_date  :=  IGS_GE_DATE.IGSDATE(p_expiry_dt) ;  /**  Character to date conversion        **/
    END IF;

    -- logs all the parameters
    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','PERS_ID_GROUP'),20)||':',p_pid_group);
    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','HOLD_TYPE'),20)||':',p_hold_type);

    -- if p_term parameter is entered by the user only then this parameter is logged in log file
    IF p_term IS NOT NULL THEN
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','TERM'),20)||':',p_term);
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','CAL_TYPE'),20)||':',l_cal_type);
      log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','SEQ_NUM'),20)||':',l_seq_num);
    END IF;

    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','START_DT'),20)||':',IGS_GE_DATE.IGSCHARDT(l_start_date));
    log_messages(RPAD(lookup_desc('IGS_PE_HOLDS','EXPIRY_DT'),20)||':',IGS_GE_DATE.IGSCHARDT(l_expiry_date));
    FND_FILE.NEW_LINE(FND_FILE.LOG,2);                    /** writes 2 new line characters **/

    -- if both start date and term parameters are passed as null , error out of the process
    IF ((p_start_dt IS NULL OR p_expiry_dt IS NULL) AND p_term IS NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_TERM_OR_START_EXP_DT') ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
    END IF;

    -- if both start date and term parameters are passed as not null's , error out of the process
    IF ((p_start_dt IS NOT NULL OR p_expiry_dt IS NOT NULL) AND p_term IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_TERM_OR_START_EXP_DT') ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
    END IF;

    -- check if expirt date is less than start date
      IF l_expiry_date < l_start_date THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_EXPDT_GE_STDT') ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
      END IF;

     -- Validate that the person who has logged in has a party account and
     -- is a STAFF. If he fails any of the above then is not authorized to release the hold.
       igs_pe_gen_001.get_hold_auth(FND_GLOBAL.USER_ID,
                                    l_person_id,
                                    l_person_number,
                                    l_person_name,
                                    l_message_name);

      IF l_message_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS',l_message_name) ;
        IGS_GE_MSG_STACK.ADD;
        RAISE l_error_exception;
      END IF;

    l_msg_str_0  :=   RPAD(lookup_desc('IGS_PE_HOLDS','PERSON'),30) ||
                      RPAD(lookup_desc('IGS_PE_HOLDS','NAME'),452);

    FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str_0);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

    --get the query for the members in the group passed
    L_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_pid_group,l_status, l_group_type); -- skpandey
    IF l_status <> 'S' THEN
      RAISE NO_DATA_FOUND;
    END IF;
    L_select := L_select||'('||L_str||')';

   --skpandey, Bug#4937960: Added logic as a part of literal fix
   IF l_group_type = 'STATIC' THEN
    OPEN c_cur_query FOR L_select USING p_pid_group ;
   ELSIF l_group_type = 'DYNAMIC' THEN
    OPEN c_cur_query FOR L_select;
   END IF;
    LOOP
      FETCH c_cur_query INTO r_rec_query ; --l_per_id,l_per_number,l_full_name;
      EXIT WHEN c_cur_query%NOTFOUND;
      BEGIN
        l_msg_str_1    :=  RPAD(r_rec_query.person_number,30) ||
                           RPAD(nvl(r_rec_query.full_name,' '),452);

        FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_str_1);

        OPEN   c_igs_pe_pers_encumb( cp_person_id    =>  r_rec_query.person_id ,
                                     cp_hold_type    =>  p_hold_type          ,
                                     cp_start_dt     =>  l_start_date
                                    );
        FETCH  c_igs_pe_pers_encumb INTO l_c_igs_pe_pers_encumb ;
        IF c_igs_pe_pers_encumb%NOTFOUND THEN
          CLOSE  c_igs_pe_pers_encumb ;
          FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERS_ENCUMB_NOTEXIST') ;
          IGS_GE_MSG_STACK.ADD;
      RAISE l_ignore_exception; -- 3338759: To stop further processing and log the message
        END IF;
        CLOSE  c_igs_pe_pers_encumb ;

        BEGIN

        -- Person Encumbrance Security.
        -- To release Hold the user must have a party account
        -- must be a Staff
        -- must have logged in with the same responsibility as the Authorizer has logged in to create the Hold.
        SAVEPOINT sp_release;

            igs_pe_gen_001.release_hold
            (p_resp_id     => l_resp_id,
             p_fnd_user_id => l_fnd_user_id,
             p_person_id   => r_rec_query.person_id,
             p_encumbrance_type => p_hold_type,
             p_start_dt    => l_start_date,
             p_expiry_dt   => l_expiry_date,
             p_override_resp => 'N',
             p_message_name  => l_message_name);

        EXCEPTION
          WHEN OTHERS THEN
            -- 3338759: Rollback to SAVEPOINT sp_release in case of exception
        ROLLBACK TO sp_release;
        retcode := 2;
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        END ;
     EXCEPTION
       WHEN l_error_exception THEN
       retcode := 2;
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

       WHEN l_ignore_exception THEN -- 3338759: when this exception is thrown, only the error is to be logged
                                    -- the concurrent program should not error out
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
     END ;
    END LOOP ;
    CLOSE c_cur_query;
    igs_pe_gen_001.g_hold_validation := 'Y';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      retcode := 2;
      igs_pe_gen_001.g_hold_validation := 'Y';
      FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERSID_GROUP_EXP') ;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    WHEN l_error_exception THEN
     retcode := 2;
     igs_pe_gen_001.g_hold_validation := 'Y';
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    WHEN OTHERS THEN
      retcode := 2;
      igs_pe_gen_001.g_hold_validation := 'Y';
      errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
  END rel_prsid_grp_holds ;                      /** procedure ends here **/
END igs_pe_set_rem_holds;

/
