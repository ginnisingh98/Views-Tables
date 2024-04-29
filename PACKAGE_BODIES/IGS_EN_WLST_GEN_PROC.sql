--------------------------------------------------------
--  DDL for Package Body IGS_EN_WLST_GEN_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_WLST_GEN_PROC" as
/* $Header: IGSEN76B.pls 120.2 2005/10/10 04:58:33 appldev ship $ */
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 18-JUL-2001
  --
  --Purpose: Package  specification contains definition of procedures
  --         getPersonDetail and getUooDetail
  --         and procedure to raise event for sending mail to student
  --         and administrator
  --         and function to get message text
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- rnirwani   01-Dec-2003     Bug# 2829263. Term records build
  --                            Parameters to procedure wf_inform_stud have been modified.
  --                            The parameters passed to the business events too have changed.
  --kkillams    11-03-2003      Initialized the workflow parameter list variable
  --                            while declaring wiht wf_parameter_list_t();
  --                            w.r.t. but no:2840162
  --rvangala    07-OCT-2003     Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                            added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  -------------------------------------------------------------------

  FUNCTION  getmessagetext (p_message_name     IN   VARCHAR2
                            )RETURN VARCHAR2
  ------------------------------------------------------------------
  --Created by  : smanglm, Oracle IDC
  --Date created: 24-JUL-2001
  --
  --Purpose: This function returns the message text
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  IS
    l_message_text  VARCHAR2(2000);
  BEGIN
    --
    -- set the message name passed in
    --
    FND_MESSAGE.SET_NAME('IGS',p_message_name);
    --
    -- get the message string
    --
    l_message_text := FND_MESSAGE.GET;
    RETURN l_message_text;

  END getmessagetext;

  PROCEDURE  getpersondetail ( p_person_id      IN   igs_pe_person.person_id%TYPE        ,
                               p_person_number  OUT NOCOPY  igs_pe_person.person_number%TYPE    ,
                               p_full_name      OUT NOCOPY  igs_pe_person.full_name%TYPE        ,
                               p_email_addr     OUT NOCOPY  igs_pe_person.email_addr%TYPE       ,
                               p_message        OUT NOCOPY  VARCHAR2
                             ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 18-JUL-2001
  --
  --Purpose: This procedure return all the details of person id when person id
  --         is passed as parameter .
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    CURSOR  c_igs_pe_person(cp_person_id  igs_pe_person.person_id%TYPE) IS
    SELECT  person_number  ,  full_name  ,  email_addr
    FROM    igs_pe_person
    WHERE   person_id   =  cp_person_id  ;

    l_c_igs_pe_person   c_igs_pe_person%ROWTYPE ;
    l_message           VARCHAR2(1000) DEFAULT NULL ;
  BEGIN
    OPEN  c_igs_pe_person(cp_person_id => p_person_id );
    FETCH c_igs_pe_person INTO l_c_igs_pe_person ;
    IF c_igs_pe_person%NOTFOUND THEN
      CLOSE  c_igs_pe_person ;
      l_message        := 'IGS_PE_PERS_NOT_EXIST' ;
      p_person_number  := NULL ;
      p_full_name      := NULL ;
      p_email_addr     := NULL ;
      p_message        := l_message ;
      RETURN ;
    END IF;
    p_person_number := l_c_igs_pe_person.person_number ;
    p_full_name     := l_c_igs_pe_person.full_name     ;
    p_email_addr    := l_c_igs_pe_person.email_addr    ;
    p_message       := NULL ;
    CLOSE c_igs_pe_person ;

  END getpersondetail ;

  PROCEDURE  getuoodetail ( p_uoo_id           IN     igs_ps_unit_ofr_opt.uoo_id%TYPE      ,
                            p_unit_cd          OUT NOCOPY    igs_ps_unit_ver.unit_cd%TYPE         ,
                            p_unit_title       OUT NOCOPY    igs_ps_unit_ver.title%TYPE           ,
                            p_cal_type         OUT NOCOPY    igs_ps_unit_ofr_opt.cal_type%TYPE    ,
                            p_alternate_code   OUT NOCOPY    igs_ca_inst.alternate_code%TYPE      ,
                            p_location_desc    OUT NOCOPY    igs_ad_location.description%TYPE     ,
                            p_unit_class       OUT NOCOPY    igs_ps_unit_ofr_opt.unit_class%TYPE  ,
                            p_message          OUT NOCOPY    VARCHAR2
                          )  IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 18-JUL-2001
  --
  --Purpose: This procedure return all the details of unit offer option when uoo Id
  --         is passed as parameter .
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR  c_uoo_details(cp_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
    SELECT  uoo.unit_cd       , uv.title  , uoo.cal_type      ,
            ci.alternate_code , al.description location_desc  ,
            uoo.unit_class
     FROM   igs_ps_unit_ofr_opt uoo ,
            igs_ad_location     al  ,
            igs_ps_unit_ver     uv  ,
            igs_ca_inst         ci
     WHERE  uoo.unit_cd         = uv.unit_cd
     AND    uoo.version_number     = uv.version_number
     AND    uoo.cal_type           = ci.cal_type
     AND    uoo.ci_sequence_number = ci.sequence_number
     AND    uoo.location_cd        = al.location_cd
     AND    uoo.uoo_id             = cp_uoo_id  ;

     l_c_uoo_details      c_uoo_details%ROWTYPE ;
     l_message            VARCHAR2(1000) DEFAULT NULL ;
  BEGIN
    OPEN  c_uoo_details(cp_uoo_id => p_uoo_id);
    FETCH c_uoo_details INTO l_c_uoo_details ;
    IF c_uoo_details%NOTFOUND THEN
      CLOSE  c_uoo_details ;
      l_message         :=  'IGS_EN_UOO_NOT_EXIST' ;
      p_unit_cd         :=  NULL ;
      p_unit_title      :=  NULL ;
      p_cal_type        :=  NULL ;
      p_alternate_code  :=  NULL ;
      p_location_desc   :=  NULL ;
      p_unit_class      :=  NULL ;
      p_message         :=  l_message ;
      RETURN ;
    END IF;
    p_unit_cd         :=   l_c_uoo_details.unit_cd        ;
    p_unit_title      :=   l_c_uoo_details.title          ;
    p_cal_type        :=   l_c_uoo_details.cal_type       ;
    p_alternate_code  :=   l_c_uoo_details.alternate_code ;
    p_location_desc   :=   l_c_uoo_details.location_desc  ;
    p_unit_class      :=   l_c_uoo_details.unit_class     ;
    p_message         :=   NULL  ;
    CLOSE c_uoo_details ;

  END getuoodetail ;

  PROCEDURE   wf_inform_stud    (  p_person_id                IN igs_en_stdnt_ps_att.person_id%TYPE     ,
                                   p_program_cd               IN igs_en_stdnt_ps_att.course_cd%TYPE,
                                   P_version_number           IN igs_en_stdnt_ps_att.version_number%TYPE,
                                   P_program_attempt_status   IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
                                   p_org_id                   IN NUMBER,
                                   p_old_key_program          IN igs_en_stdnt_ps_att.course_cd%TYPE,
                                   p_old_prim_program         IN igs_en_stdnt_ps_att.course_cd%TYPE,
                                   p_load_cal_type            IN igs_ca_inst.cal_type%TYPE,
                                   p_load_ci_seq_num          IN igs_ca_inst.sequence_number%TYPE
                                )
  ------------------------------------------------------------------
  --Created by  : svenkata, Oracle IDC
  --Date created: 17-Jan-2002
  --
  --Purpose: This procedure raises the business event for informing
  --         to student.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  IS
        l_wf_parameter_list_t   WF_PARAMETER_LIST_T :=wf_parameter_list_t();
        l_key                   NUMBER;
        l_wf_installed          fnd_lookups.lookup_code%TYPE;
  BEGIN
        -- get the profile value that is set for checking if workflow is installed
        fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

        -- if workflow is installed then carry on with the raising an event
        IF (RTRIM(l_wf_installed) ='Y') THEN
                 --
                 -- set the event key but before the select a number from sequenec
                 --
                 SELECT igs_en_inform_stud_s.NEXTVAL INTO l_key FROM dual;
                 --
                 -- now add the parameters to the parameter list
                 --
                 wf_event.AddParameterToList( p_Name => 'P_ORG_ID',                 p_Value => p_org_id,                  p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_PERSON_ID',              p_Value => p_person_id,               p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_KEY_PROGRAM',             p_Value => p_program_cd,              p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_VERSION_NUMBER',         p_Value => p_version_number,          p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_PROGRAM_ATTEMPT_STATUS', p_Value => p_program_attempt_status,  p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_OLD_KEY_PROGRAM',        p_Value => p_old_key_program,         p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_OLD_PRIM_PROGRAM',       p_Value => p_old_prim_program,        p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_LOAD_CAL_TYPE',          p_Value => p_load_cal_type,           p_parameterlist =>l_wf_parameter_list_t);
                 wf_event.AddParameterToList( p_Name => 'P_LOAD_CA_SEQ_NUM',        p_Value => p_load_ci_seq_num,         p_parameterlist =>l_wf_parameter_list_t);
                 --
                 -- raise the event
                 --
                 WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.prog.keyprim',
                                 p_event_key  => 'keyprim'||l_key,
                                 p_event_data => NULL,
                                 p_parameters => l_wf_parameter_list_t);
        END IF;
  END wf_inform_stud ;



  PROCEDURE  wf_send_mail_stud  (  p_person_id    IN    igs_pe_person.person_id%TYPE     ,
                                   p_uoo_id       IN    igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                                   p_org_id       IN    NUMBER
                                )
  ------------------------------------------------------------------
  --Created by  : smanglm, Oracle IDC
  --Date created: 24-JUL-2001
  --
  --Purpose: This procedure raises the business event for sending mail
  --         to student.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
 IS
        l_key                   NUMBER;
        l_param_list            wf_parameter_list_t:=wf_parameter_list_t();
        l_wf_installed          fnd_lookups.lookup_code%TYPE;
  BEGIN
        -- get the profile value that is set for checking if workflow is installed
        fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

        -- if workflow is installed then carry on with the raising an event
        IF (RTRIM(l_wf_installed) ='Y') THEN
                 SELECT IGS_EN_WF_MAILSTUD_S.NEXTVAL INTO l_key FROM dual;
                 --
                 -- now add the parameters to the parameter list
                 --
                         wf_event.AddParameterToList(p_name => 'ORG_ID',      p_value => p_org_id,                         p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'USER_ID',     p_value => FND_PROFILE.VALUE('USER_ID'),     p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'RESP_ID',     p_value => FND_PROFILE.VALUE('RESP_ID'),     p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',p_value => FND_PROFILE.VALUE('RESP_APPL_ID'),p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'UOO_ID',      p_value => p_uoo_id,                         p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'PERSON_ID',   p_value => p_person_id,                      p_parameterlist => l_param_list);
                 --
                 -- raise the event
                 --
                 WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.wlst.mailstud',
                                 p_event_key  => 'mailstud'||l_key,
                                 p_parameters => l_param_list);
       END IF;

  END wf_send_mail_stud;

  PROCEDURE  wf_send_mail_adm   (  p_person_id_list    IN    VARCHAR2                         ,
                                   p_uoo_id            IN    igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                                   p_org_id            IN    NUMBER
                                )
  ------------------------------------------------------------------
  --Created by  : smanglm, Oracle IDC
  --Date created: 24-JUL-2001
  --
  --Purpose: This procedure raises the business event for sending mail
  --         to administrator.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --  ctyagi      07-OCT-2005   Modified for bug #4314601: tosend workflow notification
  --                            to lead instructor
  -------------------------------------------------------------------
  IS

  CURSOR c_userid  IS
         SELECT fnd.USER_ID from fnd_user fnd ,
         igs_ps_usec_tch_resp ustr
         WHERE
         ustr.uoo_id = p_uoo_id   AND
         ustr.LEAD_INSTRUCTOR_FLAG='Y' AND
         ustr.instructor_id =  fnd.person_party_id ;


 CURSOR c_resp (cp_user_id fnd_user.user_id%type) IS
         SELECT rg.responsibility_id,
         rg.responsibility_application_id
         FROM fnd_user_resp_groups rg, fnd_responsibility r
         WHERE rg.user_id =  cp_user_id
         AND SYSDATE BETWEEN rg.start_date AND NVL(rg.end_date,(SYSDATE+1))
         AND r.responsibility_id = rg.responsibility_id
         AND r.responsibility_key = 'IGS_SS_FACULTY';


        l_key                   NUMBER;
        l_param_list            wf_parameter_list_t:=wf_parameter_list_t();
        l_wf_installed          fnd_lookups.lookup_code%TYPE;
        v_USER_ID   c_userid%ROWTYPE ;
        l_USER_ID   fnd_user.USER_ID%TYPE ;
        l_RESP_ID   fnd_user_resp_groups.responsibility_id%TYPE ;
        l_RESP_APPL_ID fnd_user_resp_groups.responsibility_application_id%TYPE ;

  BEGIN
        -- get the profile value that is set for checking if workflow is installed
        fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

        -- if workflow is installed then carry on with the raising an event
        IF (RTRIM(l_wf_installed) ='Y') THEN

            FOR  v_USER_ID IN   c_userid LOOP
               l_USER_ID := v_USER_ID.USER_ID;
               IF  l_USER_ID IS NOT NULL THEN
                   OPEN     c_resp(l_USER_ID);
                   FETCH    c_resp  INTO    l_RESP_ID,l_RESP_APPL_ID;
                   CLOSE    c_resp;
               END IF;
               IF  l_USER_ID IS NOT NULL AND  l_RESP_ID IS NOT NULL AND  l_RESP_APPL_ID IS NOT NULL THEN
                   EXIT ;
               END IF;
            END LOOP ;


            IF l_USER_ID IS NULL OR l_RESP_ID IS  NULL OR l_RESP_APPL_ID IS  NULL  THEN
               l_USER_ID := FND_PROFILE.VALUE('USER_ID');
               l_RESP_ID := FND_PROFILE.VALUE('RESP_ID');
               l_RESP_APPL_ID :=  FND_PROFILE.VALUE('RESP_APPL_ID');
            END IF;


                 --
                 -- now add the parameters to the parameter list
                 --
                         wf_event.AddParameterToList(p_name => 'ORG_ID',         p_value => p_org_id,                         p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'USER_ID',        p_value => l_USER_ID,                        p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'RESP_ID',        p_value => l_RESP_ID,                        p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',   p_value => l_RESP_APPL_ID,                   p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'UOO_ID',         p_value => p_uoo_id,                         p_parameterlist => l_param_list);
                         wf_event.AddParameterToList(p_name => 'PERSON_ID_LIST', p_value => p_person_id_list,                 p_parameterlist => l_param_list);
                 --
                 -- raise the event
                 --
                 WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.wlst.mailadm',
                                 p_event_key  => 'mailadm'||l_key,
                                 p_parameters => l_param_list);
        END IF;
  END wf_send_mail_adm;

  FUNCTION Enrp_Resequence_Wlst ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE ,
                                  p_modified_pos_tab    IN   t_modified_pos_tab
                                 ) RETURN BOOLEAN

  ------------------------------------------------------------------
  --Created by  : prraj, Oracle IDC
  --Date created: 9-SEP-2002
  --
  --Purpose: This procedure resequences the waitlist and raises the
  -- business event for sending mail to the students whose
  -- wailist positions have been affected.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When           What
  --pradhakr    15-Dec-2002    Changed the call to the update_row of igs_en_su_attempt
  --                           table to igs_en_sua_api.update_unit_attempt.
  --                           Changes wrt ENCR031 build. Bug# 2643207
  --ptandon     25-Aug-2003    Modified the signature to add a new parameter of
  --                           type t_modified_pos_tab and added logic to retain the
  --                           same priority/preference weight for a given position
  --                           as part of Waitlist Enhancements Build (Bug# 3052426)
  --rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                           added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  -------------------------------------------------------------------

  IS

        -- Cursor to select all the students for the unit section whose
        -- waitlist postion has been currently modified by the Admin.
        CURSOR  c_unit_sec_stud_mod(cp_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
        SELECT
                person_id,
                course_cd,
                administrative_priority,
                waitlist_manual_ind,
                wlst_priority_weight_num,
                wlst_preference_weight_num
        FROM
                igs_en_su_attempt_all sua
        WHERE
                sua.uoo_id = cp_uoo_id
        AND     sua.waitlist_manual_ind = 'M'
        AND     sua.unit_attempt_status = 'WAITLISTED'
        FOR UPDATE NOWAIT;
        unit_sec_stud_mod_rec   c_unit_sec_stud_mod%ROWTYPE;


        -- Cursor to select all the students for the unit section whose
        -- waitlist postion has NOT been currently modified by the Admin.
        CURSOR  c_unit_sec_stud(cp_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
        SELECT
                person_id,
                course_cd,
                administrative_priority,
                waitlist_manual_ind,
                wlst_priority_weight_num,
                wlst_preference_weight_num
        FROM
                igs_en_su_attempt_all sua
        WHERE
                sua.uoo_id = cp_uoo_id
        AND     sua.waitlist_manual_ind <> 'M'
        AND     sua.unit_attempt_status = 'WAITLISTED'
        ORDER BY sua.administrative_priority
        FOR UPDATE NOWAIT;
        unit_sec_stud_rec       c_unit_sec_stud%ROWTYPE;


        -- Cursor to select a unit section for a particular student
        CURSOR  c_stud_unit_attempt(cp_uoo_id       igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                    cp_person_id    igs_en_su_attempt_all.person_id%TYPE,
                                    cp_course_cd    igs_en_su_attempt_all.course_cd%TYPE
                                   ) IS
        SELECT * FROM
                igs_en_su_attempt sua
        WHERE
                sua.uoo_id    = cp_uoo_id
        AND     sua.person_id = cp_person_id
        AND     sua.course_cd = cp_course_cd
        FOR UPDATE NOWAIT;
        cur_sua_rec            c_stud_unit_attempt%ROWTYPE;


        -- Cursor to select person number based on the person_id
        CURSOR c_person(cp_person_id    hz_parties.party_id%TYPE) IS
        SELECT party_number
        FROM hz_parties
        WHERE party_id = cp_person_id;

        -- Cursor to select user name of the student based on the person_id
        CURSOR c_student(cp_person_id   hz_parties.party_id%TYPE) IS
        SELECT user_name
        FROM fnd_user
        WHERE person_party_id = cp_person_id;

        -- Record type for PL/SQL table
        TYPE t_stud_wait_rec IS RECORD
        (
             person_id            igs_en_su_attempt_all.person_id%TYPE,
             course_cd            igs_en_su_attempt_all.course_cd%TYPE,
             admin_priority       igs_en_su_attempt_all.administrative_priority%TYPE,
             wlst_manual_ind      igs_en_su_attempt_all.waitlist_manual_ind%TYPE,
             wlst_priority_weight_num   igs_en_su_attempt_all.wlst_priority_weight_num%TYPE,
             wlst_preference_weight_num igs_en_su_attempt_all.wlst_preference_weight_num%TYPE
        );

        TYPE t_stud_waitlist IS TABLE OF t_stud_wait_rec INDEX BY BINARY_INTEGER;

        stud_waitlist_table     t_stud_waitlist;

        l_person_number_wlst    hz_parties.party_number%TYPE;
        l_person_number_sua     hz_parties.party_number%TYPE;
        l_student_user_name     fnd_user.user_name%TYPE;

        waitlist_pos            NUMBER;
        counter                 NUMBER;

        -- Workflow variables
        l_wf_event_t            WF_EVENT_T;
        l_wf_parameter_list_t   WF_PARAMETER_LIST_T;
        l_key                   NUMBER;
        l_tot_stud              NUMBER;
        l_param_list            wf_parameter_list_t:=wf_parameter_list_t();
        l_param_value           VARCHAR2(200);
        l_param_name            VARCHAR2(50);
        l_pri_pref_def          BOOLEAN;

  BEGIN

        l_pri_pref_def := FALSE;
        IF p_modified_pos_tab.COUNT <> 0 THEN
          l_pri_pref_def := TRUE;
        END IF;
        FOR unit_sec_stud_mod_rec IN c_unit_sec_stud_mod (cp_uoo_id => p_uoo_id)
        LOOP
                waitlist_pos := unit_sec_stud_mod_rec.administrative_priority;

                IF stud_waitlist_table.EXISTS(waitlist_pos) AND stud_waitlist_table(waitlist_pos).person_id IS NOT NULL THEN
                      -- Duplicate value exists at the same position
                      -- Select the person numbers involved

                      OPEN c_person(stud_waitlist_table(waitlist_pos).person_id);
                        FETCH c_person INTO l_person_number_wlst;
                      CLOSE c_person;

                      OPEN c_person(unit_sec_stud_mod_rec.person_id);
                        FETCH c_person INTO l_person_number_sua;
                      CLOSE c_person;

                      -- concatenate both person numbers and raise exception
                      FND_MESSAGE.SET_NAME('IGS','IGS_EN_DUP_WLST_POSITION');
                      FND_MESSAGE.SET_TOKEN('STUDENTS',l_person_number_wlst || ', ' || l_person_number_sua);
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
                ELSE
                      IF l_pri_pref_def THEN
                         -- assign the priority/preference weights of the student at correct position
                         FOR pos_tab_cnt IN 1 .. p_modified_pos_tab.COUNT LOOP

                           IF p_modified_pos_tab(pos_tab_cnt).current_position = waitlist_pos THEN
                             stud_waitlist_table(p_modified_pos_tab(pos_tab_cnt).previous_position).wlst_priority_weight_num :=
                                                                                 unit_sec_stud_mod_rec.wlst_priority_weight_num;
                             stud_waitlist_table(p_modified_pos_tab(pos_tab_cnt).previous_position).wlst_preference_weight_num :=
                                                                                 unit_sec_stud_mod_rec.wlst_preference_weight_num;
                             EXIT;
                           END IF;
                         END LOOP;
                      END IF;

                  -- record does not exist
                  -- Assigning the record
                  stud_waitlist_table(waitlist_pos).person_id           := unit_sec_stud_mod_rec.person_id;
                  stud_waitlist_table(waitlist_pos).course_cd           := unit_sec_stud_mod_rec.course_cd;
                  stud_waitlist_table(waitlist_pos).admin_priority      := unit_sec_stud_mod_rec.administrative_priority;
                  stud_waitlist_table(waitlist_pos).wlst_manual_ind     := unit_sec_stud_mod_rec.waitlist_manual_ind;
                END IF;
        END LOOP;


        -- Assign the unmodified records at the vacant positions in the PL/SQL table
        counter := 1;
        FOR unit_sec_stud_rec IN c_unit_sec_stud (cp_uoo_id => p_uoo_id)
        LOOP

                IF stud_waitlist_table.EXISTS(counter) AND stud_waitlist_table(counter).person_id IS NOT NULL THEN

                   IF l_pri_pref_def THEN
                      -- assign the priority/preference weights of the student at correct position
                             stud_waitlist_table(unit_sec_stud_rec.administrative_priority).wlst_priority_weight_num :=
                                                                                 unit_sec_stud_rec.wlst_priority_weight_num;
                             stud_waitlist_table(unit_sec_stud_rec.administrative_priority).wlst_preference_weight_num :=
                                                                                 unit_sec_stud_rec.wlst_preference_weight_num;
                   END IF;

                   -- loop until a vacant place is found in the pl/sql table
                   -- and set the record there
                   counter := counter + 1;
                   LOOP
                     IF (NOT stud_waitlist_table.EXISTS(counter)) OR
                        (stud_waitlist_table.EXISTS(counter) AND stud_waitlist_table(counter).person_id IS NULL)
                     THEN
                        stud_waitlist_table(counter).person_id                := unit_sec_stud_rec.person_id;
                        stud_waitlist_table(counter).course_cd                := unit_sec_stud_rec.course_cd;
                        stud_waitlist_table(counter).admin_priority           := unit_sec_stud_rec.administrative_priority;
                        stud_waitlist_table(counter).wlst_manual_ind          := unit_sec_stud_rec.waitlist_manual_ind;
                       EXIT;
                     END IF;
                     counter := counter + 1;
                   END LOOP;
                ELSE

                   IF l_pri_pref_def THEN
                      -- assign the priority/preference weights of the student at correct position
                             stud_waitlist_table(unit_sec_stud_rec.administrative_priority).wlst_priority_weight_num :=
                                                                                 unit_sec_stud_rec.wlst_priority_weight_num;
                             stud_waitlist_table(unit_sec_stud_rec.administrative_priority).wlst_preference_weight_num :=
                                                                                 unit_sec_stud_rec.wlst_preference_weight_num;
                   END IF;

                   -- No records exist at this index
                   -- so directly assign the record
                   stud_waitlist_table(counter).person_id               := unit_sec_stud_rec.person_id;
                   stud_waitlist_table(counter).course_cd               := unit_sec_stud_rec.course_cd;
                   stud_waitlist_table(counter).admin_priority          := unit_sec_stud_rec.administrative_priority;
                   stud_waitlist_table(counter).wlst_manual_ind         := unit_sec_stud_rec.waitlist_manual_ind;
                END IF;
           counter := counter + 1;
        END LOOP;

        counter := 1;
        l_tot_stud := 0;
        WHILE counter <=  stud_waitlist_table.COUNT
        LOOP
           IF ( (counter <> stud_waitlist_table(counter).admin_priority) OR (stud_waitlist_table(counter).wlst_manual_ind IN ('M','Y')) ) THEN
              OPEN c_stud_unit_attempt(p_uoo_id,
                                       stud_waitlist_table(counter).person_id,
                                       stud_waitlist_table(counter).course_cd
                                      );
               FETCH c_stud_unit_attempt INTO cur_sua_rec;

               IF(stud_waitlist_table(counter).wlst_manual_ind = 'M') THEN
                  cur_sua_rec.WAITLIST_MANUAL_IND := 'Y';
               ELSE
                  cur_sua_rec.WAITLIST_MANUAL_IND := 'N';
               END IF;

               -- assign the table index value as waitlist position
               cur_sua_rec.ADMINISTRATIVE_PRIORITY := counter;
               cur_sua_rec.WLST_PRIORITY_WEIGHT_NUM := stud_waitlist_table(counter).wlst_priority_weight_num;
               cur_sua_rec.WLST_PREFERENCE_WEIGHT_NUM := stud_waitlist_table(counter).wlst_preference_weight_num;

                      -- Call the API to update the student unit attempt. This API is a
                      -- wrapper to the update row of the TBH.

                      -- Added two more parameters to the call X_WLST_PRIORITY_WEIGHT_NUM and X_WLST_PREFERENCE_WEIGHT_NUM
                      -- as part of Waitlist Enhancements Build - Bug# 3052426 (ptandon)
                      igs_en_sua_api.update_unit_attempt (
                                  X_ROWID                      => cur_sua_rec.ROW_ID,
                                  X_PERSON_ID                  => cur_sua_rec.PERSON_ID,
                                  X_COURSE_CD                  => cur_sua_rec.COURSE_CD,
                                  X_UNIT_CD                    => cur_sua_rec.UNIT_CD,
                                  X_CAL_TYPE                   => cur_sua_rec.CAL_TYPE,
                                  X_CI_SEQUENCE_NUMBER         => cur_sua_rec.CI_SEQUENCE_NUMBER,
                                  X_VERSION_NUMBER             => cur_sua_rec.VERSION_NUMBER,
                                  X_LOCATION_CD                => cur_sua_rec.LOCATION_CD,
                                  X_UNIT_CLASS                 => cur_sua_rec.UNIT_CLASS,
                                  X_CI_START_DT                => cur_sua_rec.CI_START_DT,
                                  X_CI_END_DT                  => cur_sua_rec.CI_END_DT,
                                  X_UOO_ID                     => cur_sua_rec.UOO_ID,
                                  X_ENROLLED_DT                => cur_sua_rec.ENROLLED_DT,
                                  X_UNIT_ATTEMPT_STATUS        => cur_sua_rec.UNIT_ATTEMPT_STATUS,
                                  X_ADMINISTRATIVE_UNIT_STATUS => cur_sua_rec.ADMINISTRATIVE_UNIT_STATUS,
                                  X_DISCONTINUED_DT            => cur_sua_rec.DISCONTINUED_DT,
                                  X_RULE_WAIVED_DT             => cur_sua_rec.RULE_WAIVED_DT,
                                  X_RULE_WAIVED_PERSON_ID      => cur_sua_rec.RULE_WAIVED_PERSON_ID,
                                  X_NO_ASSESSMENT_IND          => cur_sua_rec.NO_ASSESSMENT_IND,
                                  X_SUP_UNIT_CD                => cur_sua_rec.SUP_UNIT_CD,
                                  X_SUP_VERSION_NUMBER         => cur_sua_rec.SUP_VERSION_NUMBER,
                                  X_EXAM_LOCATION_CD           => cur_sua_rec.EXAM_LOCATION_CD,
                                  X_ALTERNATIVE_TITLE          => cur_sua_rec.ALTERNATIVE_TITLE,
                                  X_OVERRIDE_ENROLLED_CP       => cur_sua_rec.OVERRIDE_ENROLLED_CP,
                                  X_OVERRIDE_EFTSU             => cur_sua_rec.OVERRIDE_EFTSU,
                                  X_OVERRIDE_ACHIEVABLE_CP     => cur_sua_rec.OVERRIDE_ACHIEVABLE_CP,
                                  X_OVERRIDE_OUTCOME_DUE_DT    => cur_sua_rec.OVERRIDE_OUTCOME_DUE_DT,
                                  X_OVERRIDE_CREDIT_REASON     => cur_sua_rec.OVERRIDE_CREDIT_REASON,
                                  X_ADMINISTRATIVE_PRIORITY    => cur_sua_rec.ADMINISTRATIVE_PRIORITY,
                                  X_WAITLIST_DT                => cur_sua_rec.WAITLIST_DT,
                                  X_DCNT_REASON_CD             => cur_sua_rec.DCNT_REASON_CD,
                                  X_MODE                       => 'R',
                                  X_GS_VERSION_NUMBER          => cur_sua_rec.GS_VERSION_NUMBER,
                                  X_ENR_METHOD_TYPE            => cur_sua_rec.ENR_METHOD_TYPE,
                                  X_FAILED_UNIT_RULE           => cur_sua_rec.FAILED_UNIT_RULE,
                                  X_CART                       => cur_sua_rec.CART,
                                  X_RSV_SEAT_EXT_ID            => cur_sua_rec.RSV_SEAT_EXT_ID,
                                  X_ORG_UNIT_CD                => cur_sua_rec.ORG_UNIT_CD,
                                  X_GRADING_SCHEMA_CODE        => cur_sua_rec.GRADING_SCHEMA_CODE,
                                  X_SUBTITLE                   => cur_sua_rec.SUBTITLE,
                                  X_SESSION_ID                 => cur_sua_rec.SESSION_ID,
                                  X_DEG_AUD_DETAIL_ID          => cur_sua_rec.DEG_AUD_DETAIL_ID,
                                  X_STUDENT_CAREER_TRANSCRIPT  => cur_sua_rec.STUDENT_CAREER_TRANSCRIPT,
                                  X_STUDENT_CAREER_STATISTICS  => cur_sua_rec.STUDENT_CAREER_STATISTICS,
                                  X_ATTRIBUTE_CATEGORY         => cur_sua_rec.ATTRIBUTE_CATEGORY,
                                  X_ATTRIBUTE1                 => cur_sua_rec.ATTRIBUTE1,
                                  X_ATTRIBUTE2                 => cur_sua_rec.ATTRIBUTE2,
                                  X_ATTRIBUTE3                 => cur_sua_rec.ATTRIBUTE3,
                                  X_ATTRIBUTE4                 => cur_sua_rec.ATTRIBUTE4,
                                  X_ATTRIBUTE5                 => cur_sua_rec.ATTRIBUTE5,
                                  X_ATTRIBUTE6                 => cur_sua_rec.ATTRIBUTE6,
                                  X_ATTRIBUTE7                 => cur_sua_rec.ATTRIBUTE7,
                                  X_ATTRIBUTE8                 => cur_sua_rec.ATTRIBUTE8,
                                  X_ATTRIBUTE9                 => cur_sua_rec.ATTRIBUTE9,
                                  X_ATTRIBUTE10                => cur_sua_rec.ATTRIBUTE10,
                                  X_ATTRIBUTE11                => cur_sua_rec.ATTRIBUTE11,
                                  X_ATTRIBUTE12                => cur_sua_rec.ATTRIBUTE12,
                                  X_ATTRIBUTE13                => cur_sua_rec.ATTRIBUTE13,
                                  X_ATTRIBUTE14                => cur_sua_rec.ATTRIBUTE14,
                                  X_ATTRIBUTE15                => cur_sua_rec.ATTRIBUTE15,
                                  X_ATTRIBUTE16                => cur_sua_rec.ATTRIBUTE16,
                                  X_ATTRIBUTE17                => cur_sua_rec.ATTRIBUTE17,
                                  X_ATTRIBUTE18                => cur_sua_rec.ATTRIBUTE18,
                                  X_ATTRIBUTE19                => cur_sua_rec.ATTRIBUTE19,
                                  X_ATTRIBUTE20                => cur_sua_rec.ATTRIBUTE20,
                                  X_WAITLIST_MANUAL_IND        => cur_sua_rec.WAITLIST_MANUAL_IND,
                                  X_WLST_PRIORITY_WEIGHT_NUM   => cur_sua_rec.WLST_PRIORITY_WEIGHT_NUM,
                                  X_WLST_PREFERENCE_WEIGHT_NUM => cur_sua_rec.WLST_PREFERENCE_WEIGHT_NUM,
				  -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
				  X_CORE_INDICATOR_CODE        => cur_sua_rec.CORE_INDICATOR_CODE
                                  );

                 -- Set Workflow parameters, setting the student details for whom the notification has to be sent
                 IF ( (stud_waitlist_table(counter).admin_priority <> cur_sua_rec.ADMINISTRATIVE_PRIORITY) OR
                      (stud_waitlist_table(counter).wlst_manual_ind = 'M') ) THEN

                     OPEN c_student(stud_waitlist_table(counter).person_id);
                     FETCH c_student INTO l_student_user_name;
                     CLOSE c_student;
                     l_tot_stud := l_tot_stud + 1;
                     l_param_name  := 'PARAM_'||l_tot_stud;

                     IF l_student_user_name IS NULL THEN
                         l_student_user_name := ' ';
                     END IF;

                     l_param_value := RPAD(l_student_user_name,100,' ')||cur_sua_rec.WAITLIST_MANUAL_IND||LPAD(cur_sua_rec.ADMINISTRATIVE_PRIORITY,4,'0');

                     wf_event.AddParameterToList(p_name => l_param_name, p_value => l_param_value,p_parameterlist => l_param_list);

                 END IF;  -- end of Workflow notification

              CLOSE c_stud_unit_attempt;
           END IF;
          counter := counter + 1;
        END LOOP;


        --  Workflow notification ------------------------------

        SELECT igs_en_wf_be_en001_s.NEXTVAL INTO l_key FROM dual;

        WF_EVENT.AddParameterToList(p_name => 'TOTAL_STDNT_COUNT',p_value =>l_tot_stud,p_parameterlist => l_param_list);
        WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.be_en001',
                                         p_event_key  => 'wlst_pos_change'|| l_key,
                                         p_parameters =>  l_param_list);


        -- end of Workflow notification

        RETURN TRUE;

  END Enrp_Resequence_Wlst;


  PROCEDURE check_stud_count( itemtype  IN  VARCHAR2,
                              itemkey   IN  VARCHAR2,
                  actid     IN  NUMBER,
                  funcmode  IN  VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2)

  ------------------------------------------------------------------
  --Created by  : prraj, Oracle IDC
  --Date created: 12-SEP-2002
  --
  --Purpose: This procedure checks the number of students for whom the
  -- notification has to be raised
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  IS

    l_total_std         NUMBER;
    l_event_message     WF_EVENT_T;
    l_par_st_count      NUMBER;
    l_curr_student      NUMBER;
    l_user              VARCHAR2(30);
    l_param_name        VARCHAR2(50);
    l_param_value       VARCHAR2(1500);
    l_chk_Val           NUMBER;

 BEGIN

    IF funcmode='RUN' THEN

        IF wf_engine.getitemattrnumber(itemtype,itemkey,'IA_STD_COUNT') IS NULL THEN

            l_event_message := wf_engine.getitemattrevent(itemtype,itemkey,'IA_EVE_MSG');
            l_par_st_count  := wf_event.getvalueforparameter('TOTAL_STDNT_COUNT',l_event_message.parameter_list);

            wf_engine.setitemattrnumber(itemtype,itemkey,'IA_STD_COUNT',l_par_st_count);
            l_chk_val := wf_engine.getitemattrnumber(itemtype,itemkey,'IA_STD_COUNT');

            wf_engine.setitemattrnumber(itemtype,itemkey,'IA_CURR_STD',0);
        END IF;

        l_curr_student := wf_engine.getitemattrnumber(itemtype,itemkey,'IA_CURR_STD');
        l_total_std    := wf_engine.getitemattrnumber(itemtype,itemkey,'IA_STD_COUNT');

        IF (l_total_std  - l_curr_student) > 0 THEN
            resultout := 'COMPLETE:Y';
        ELSE
            resultout := 'COMPLETE:N';
        END IF;

    END IF;

 END check_stud_count;


PROCEDURE check_manual_ind(itemtype     IN  VARCHAR2,
                           itemkey      IN  VARCHAR2,
                           actid        IN  NUMBER,
                           funcmode     IN  VARCHAR2,
                           resultout    OUT NOCOPY VARCHAR2)

------------------------------------------------------------------
  --Created by  : prraj, Oracle IDC
  --Date created: 12-SEP-2002
  --
  --Purpose: This procedure checks the manual indicator status
  --of students for whom the notification has to be raised
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

IS

    l_event_name        VARCHAR2(200);
    l_event_key         VARCHAR2(200);
    l_event_message     WF_EVENT_T;
    l_curr_student      NUMBER;
    l_param_name        VARCHAR2(100);
    l_param_Value       VARCHAR2(2000);
    l_std_name          VARCHAR2(30);
    l_std_pos           NUMBER;
    l_send_wf           VARCHAR2(1);

BEGIN

 IF funcmode='RUN' THEN

   l_event_name := wf_engine.getitemattrtext(itemtype,itemkey,'IA_EVENT');
   l_event_key  := wf_engine.getitemattrtext(itemtype,itemkey,'IA_EVE_KEY');
   l_event_message := wf_engine.getitemattrevent(itemtype,itemkey,'IA_EVE_MSG');
   l_curr_student := wf_engine.getitemattrnumber(itemtype,itemkey,'IA_CURR_STD');
   l_curr_student := l_curr_student + 1;

   l_param_name := 'PARAM_'||l_Curr_student;
   l_param_value := wf_event.getvalueforparameter(l_param_name,l_event_message.parameter_list);
   l_send_wf := SUBSTR(l_param_Value,101,1);

   IF l_send_wf = 'Y' THEN
     l_std_name := LTRIM(RTRIM(SUBSTR(l_param_Value,1,100)));
     l_std_pos  := TO_NUMBER(SUBSTR(l_param_value,102));

     wf_engine.setitemattrtext(itemtype,itemkey,'IA_UNAME',l_std_name);
     wf_engine.setitemattrtext(itemtype,itemkey,'IA_WLPOS',l_std_pos);
     wf_engine.setitemattrnumber(itemtype,itemkey,'IA_CURR_STD',l_curr_student);
     resultout := 'COMPLETE:Y';
   ELSE
     wf_engine.setitemattrtext(itemtype,itemkey,'IA_UNAME',l_std_name);
     wf_engine.setitemattrtext(itemtype,itemkey,'IA_WLPOS',l_std_pos);
     wf_engine.setitemattrnumber(itemtype,itemkey,'IA_CURR_STD',l_curr_student);
     resultout := 'COMPLETE:N';
   END IF;
 END IF;

END check_manual_ind;

PROCEDURE enrp_wlst_assign_pos (  p_person_id           IN  NUMBER ,
                                  p_program_cd          IN  VARCHAR2 ,
                                  p_uoo_id              IN  NUMBER
                               )
  ------------------------------------------------------------------
  --Created by  : ptandon, Oracle IDC
  --Date created: 25-AUG-2003
  --
  --Purpose: This procedure re-sequences the students after calculating
  --         the priority/preference weights for the student in context.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

IS
        -- Cursor to lock parent unit section record.
        CURSOR  c_unit_sec_lock IS
        SELECT  uoo_id
        FROM    igs_ps_unit_ofr_opt
        WHERE   uoo_id = p_uoo_id
        FOR UPDATE;

        -- Cursor to get all the waitlisted students in the given unit section.
        CURSOR   c_sua_pri_pref (cp_uoo_id      igs_en_su_attempt.uoo_id%TYPE) IS
        SELECT   *
        FROM     igs_en_su_attempt
        WHERE    uoo_id = cp_uoo_id AND unit_attempt_status = 'WAITLISTED'
        ORDER BY wlst_priority_weight_num DESC, wlst_preference_weight_num DESC, administrative_priority
        FOR UPDATE;

        l_cnt   NUMBER;
BEGIN

     -- Lock the parent unit section record
     OPEN c_unit_sec_lock;
     l_cnt := 1;
     FOR l_sua_details IN c_sua_pri_pref(p_uoo_id) LOOP
            IF l_cnt <> NVL(l_sua_details.administrative_priority,0) THEN
                 UPDATE igs_en_su_attempt
                 SET administrative_priority = l_cnt ,
                     waitlist_manual_ind = 'N'
                 WHERE CURRENT OF c_sua_pri_pref;
            END IF;
            l_cnt := l_cnt + 1;
     END LOOP;
     CLOSE c_unit_sec_lock;

END enrp_wlst_assign_pos;

PROCEDURE enrp_wlst_dt_reseq   (  p_person_id           IN  NUMBER ,
                                  p_program_cd          IN  VARCHAR2 ,
                                  p_uoo_id              IN  NUMBER ,
                                  p_cur_position        IN  NUMBER
                               )
  ------------------------------------------------------------------
  --Created by  : ptandon, Oracle IDC
  --Date created: 25-AUG-2003
  --
  --Purpose: This procedure re-sequences the remaining students after
  --         placing the student in context at appropriate position.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

IS
        -- Cursor to lock parent unit section record.
        CURSOR  c_unit_sec_lock IS
        SELECT  uoo_id
        FROM    igs_ps_unit_ofr_opt
        WHERE   uoo_id = p_uoo_id
        FOR UPDATE;

        -- Cursor to get all the waitlisted students in the given unit section
        -- whose waitlist date is later than the student in context.
        CURSOR   c_sua_wl_dt (cp_uoo_id         igs_en_su_attempt.uoo_id%TYPE ,
                              cp_person_id      igs_en_su_attempt.person_id%TYPE ,
                              cp_program_cd     igs_en_su_attempt.course_cd%TYPE ,
                              cp_cur_position   NUMBER)
        IS
        SELECT   *
        FROM     igs_en_su_attempt
        WHERE    uoo_id = cp_uoo_id AND
                 (person_id <> cp_person_id OR
                  course_cd <> cp_program_cd) AND
                 unit_attempt_status = 'WAITLISTED' AND
                 administrative_priority >= cp_cur_position
        ORDER BY administrative_priority
        FOR UPDATE;

        l_cnt   NUMBER;
BEGIN

     -- Lock the parent unit section record
     OPEN c_unit_sec_lock;
     l_cnt := p_cur_position + 1;
     FOR l_sua_details IN c_sua_wl_dt(p_uoo_id,p_person_id,p_program_cd,p_cur_position) LOOP
            IF l_cnt <> NVL(l_sua_details.administrative_priority,0) THEN
                 UPDATE igs_en_su_attempt
                 SET administrative_priority = l_cnt ,
                     waitlist_manual_ind = 'N'
                 WHERE CURRENT OF c_sua_wl_dt;
            END IF;
            l_cnt := l_cnt + 1;
      END LOOP;
      CLOSE c_unit_sec_lock;

END enrp_wlst_dt_reseq;

PROCEDURE enrp_wlst_pri_pref_calc  (  p_person_id               IN  NUMBER ,
                                      p_program_cd              IN  VARCHAR2 ,
                                      p_uoo_id                  IN  NUMBER ,
                                      p_priority_weight         OUT NOCOPY NUMBER ,
                                      p_preference_weight       OUT NOCOPY NUMBER
                                     )
  ------------------------------------------------------------------
  --Created by  : ptandon, Oracle IDC
  --Date created: 26-AUG-2003
  --
  --Purpose: This procedure calculates the waitlist priority / preference
  --         weights for the given student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
IS
        -- Cursor to select priorities at unit section level
        CURSOR  cur_wlst_uoo_pri   (   cp_uoo_id       igs_ps_usec_wlst_pri.uoo_id%TYPE)
        IS
        SELECT  unit_sec_waitlist_priority_id, priority_value, priority_number
        FROM    igs_ps_usec_wlst_pri
        WHERE   uoo_id = cp_uoo_id
        ORDER BY priority_number;

        -- Cursor to select preferences for a given priority Id at unit section level
        CURSOR   cur_wlst_uoo_prf   (   cp_priority_id       igs_ps_usec_wlst_prf.unit_sec_waitlist_priority_id%TYPE)
        IS
        SELECT   preference_code,preference_version
        FROM     igs_ps_usec_wlst_prf
        WHERE    unit_sec_waitlist_priority_id = cp_priority_id
        ORDER BY preference_order;

        -- Cursor to select maximum number of priorities at unit section level
        CURSOR  cur_max_uoo_pri   (    cp_uoo_id       igs_ps_usec_wlst_pri.uoo_id%TYPE)
        IS
        SELECT  count(unit_sec_waitlist_priority_id)
        FROM    igs_ps_usec_wlst_pri
        WHERE   uoo_id = cp_uoo_id;
        l_max_uoo_pri            NUMBER;

        -- Cursor to select maximum number of preferences among all the priorities at unit section level
        CURSOR  cur_max_uoo_prf   (    cp_uoo_id       igs_ps_usec_wlst_pri.uoo_id%TYPE)
        IS
        SELECT  count(unit_sec_waitlist_pref_id)
        FROM    igs_ps_usec_wlst_prf
        WHERE   unit_sec_waitlist_priority_id IN(SELECT  unit_sec_waitlist_priority_id
                                                 FROM    igs_ps_usec_wlst_pri
                                                 WHERE   uoo_id = cp_uoo_id);
        l_max_uoo_pref            NUMBER;

        -- Cursor to get the unit code, version number and teaching calender associated with the unit section
        CURSOR  cur_get_teach_inst  (   cp_uoo_id       igs_ps_unit_ofr_opt.uoo_id%TYPE)
        IS
        SELECT  unit_cd, version_number, cal_type , ci_sequence_number
        FROM    igs_ps_unit_ofr_opt
        WHERE   uoo_id = cp_uoo_id;
        cur_get_teach_inst_rec  cur_get_teach_inst%ROWTYPE;

        -- Cursor to select priorities at unit offering pattern level
        CURSOR  cur_wlst_uop_pri   (    cp_unit_cd              igs_ps_uofr_wlst_pri.unit_cd%TYPE ,
                                        cp_version_number       igs_ps_uofr_wlst_pri.version_number%TYPE ,
                                        cp_cal_type             igs_ps_uofr_wlst_pri.calender_type%TYPE ,
                                        cp_seq_no               igs_ps_uofr_wlst_pri.ci_sequence_number%TYPE)
        IS
        SELECT  unit_ofr_waitlist_priority_id, priority_value, priority_number
        FROM    igs_ps_uofr_wlst_pri
        WHERE   unit_cd    = cp_unit_cd
        AND     version_number = cp_version_number
        AND     calender_type = cp_cal_type
        AND     ci_sequence_number = cp_seq_no
        ORDER BY priority_number;

        -- Cursor to select preferences for a given priority Id at unit offering pattern level
        CURSOR   cur_wlst_uop_prf   (    cp_priority_id       igs_ps_uofr_wlst_prf.unit_ofr_waitlist_priority_id%TYPE)
        IS
        SELECT   preference_code,preference_version
        FROM     igs_ps_uofr_wlst_prf
        WHERE    unit_ofr_waitlist_priority_id = cp_priority_id
        ORDER BY preference_order;

        -- Cursor to select maximum number of priorities at unit offering pattern level
        CURSOR  cur_max_uop_pri   (     cp_unit_cd              igs_ps_uofr_wlst_pri.unit_cd%TYPE ,
                                        cp_version_number       igs_ps_uofr_wlst_pri.version_number%TYPE ,
                                        cp_cal_type             igs_ps_uofr_wlst_pri.calender_type%TYPE ,
                                        cp_seq_no               igs_ps_uofr_wlst_pri.ci_sequence_number%TYPE)
        IS
        SELECT  count(unit_ofr_waitlist_priority_id)
        FROM    igs_ps_uofr_wlst_pri
        WHERE   unit_cd    = cp_unit_cd
        AND     version_number = cp_version_number
        AND     calender_type = cp_cal_type
        AND     ci_sequence_number = cp_seq_no;
        l_max_uop_pri             NUMBER;

        -- Cursor to select maximum number of preferences among all the priorities at unit offering pattern level
        CURSOR  cur_max_uop_prf   (     cp_unit_cd              igs_ps_uofr_wlst_pri.unit_cd%TYPE ,
                                        cp_version_number       igs_ps_uofr_wlst_pri.version_number%TYPE ,
                                        cp_cal_type             igs_ps_uofr_wlst_pri.calender_type%TYPE ,
                                        cp_seq_no               igs_ps_uofr_wlst_pri.ci_sequence_number%TYPE)
        IS
        SELECT  count(unit_ofr_waitlist_pref_id)
        FROM    igs_ps_uofr_wlst_prf
        WHERE   unit_ofr_waitlist_priority_id IN(SELECT  unit_ofr_waitlist_priority_id
                                                 FROM    igs_ps_uofr_wlst_pri
                                                 WHERE   unit_cd    = cp_unit_cd
                                                 AND     version_number = cp_version_number
                                                 AND     calender_type = cp_cal_type
                                                 AND     ci_sequence_number = cp_seq_no);
        l_max_uop_pref            NUMBER;

        -- Cursor to select organization unit code for a given unit section
        CURSOR  cur_org_unit_cd    (    cp_uoo_id       igs_ps_unit_ofr_opt.uoo_id%TYPE)
        IS
        SELECT  NVL(uoo.owner_org_unit_cd,uv.owner_org_unit_cd)
        FROM    igs_ps_unit_ofr_opt uoo,
                igs_ps_unit_ver uv
        WHERE   uoo.uoo_id = cp_uoo_id
        AND     uv.unit_cd= uoo.unit_cd
        AND     uv.version_number= uoo.version_number;

        l_org_unit_cd           igs_ps_unit_ofr_opt.owner_org_unit_cd%TYPE;

        -- Cursor to get the load calender type associated with a teaching calender instance
        CURSOR  cur_teach_to_load  (    cp_teach_cal_type       igs_ca_inst.cal_type%TYPE ,
                                        cp_teach_seq_no         igs_ca_inst.sequence_number%TYPE)
        IS
        SELECT   load_cal_type
        FROM     igs_ca_teach_to_load_v
        WHERE    teach_cal_type = cp_teach_cal_type
        AND      teach_ci_sequence_number = cp_teach_seq_no
        ORDER BY load_start_dt;

        l_load_cal_type         igs_ca_inst.cal_type%TYPE;

        -- Cursor to select priorities at organizational unit level
        CURSOR  cur_wlst_org_pri   (    cp_org_unit_cd          igs_en_or_unit_wlst.org_unit_cd%TYPE ,
                                        cp_cal_type             igs_en_or_unit_wlst.cal_type%TYPE )
        IS
        SELECT  owp.org_unit_wlst_pri_id, owp.priority_value, owp.priority_number
        FROM    igs_en_orun_wlst_pri owp, igs_en_or_unit_wlst ouw
        WHERE   ouw.org_unit_cd = cp_org_unit_cd
        AND     ouw.cal_type = cp_cal_type
        AND     owp.org_unit_wlst_id = ouw.org_unit_wlst_id
        AND     ouw.closed_flag = 'N'
        ORDER BY owp.priority_number;

        -- Cursor to select preferences for a given priority Id at organizational unit level
        CURSOR   cur_wlst_org_prf   (    cp_priority_id       igs_en_orun_wlst_pri.org_unit_wlst_pri_id%TYPE)
        IS
        SELECT   preference_code,preference_version
        FROM     igs_en_orun_wlst_prf
        WHERE    org_unit_wlst_pri_id = cp_priority_id
        ORDER BY preference_order;

        -- Cursor to select maximum number of priorities at organizational unit level
        CURSOR  cur_max_org_pri   (     cp_org_unit_cd          igs_en_or_unit_wlst.org_unit_cd%TYPE ,
                                        cp_cal_type             igs_en_or_unit_wlst.cal_type%TYPE )
        IS
        SELECT  count(org_unit_wlst_pri_id)
        FROM    igs_en_orun_wlst_pri owp, igs_en_or_unit_wlst ouw
        WHERE   ouw.org_unit_cd = cp_org_unit_cd
        AND     ouw.cal_type = cp_cal_type
        AND     owp.org_unit_wlst_id = ouw.org_unit_wlst_id
        AND     ouw.closed_flag = 'N';
        l_max_org_pri             NUMBER;

        -- Cursor to select maximum number of preferences among all the priorities at organizational unit level
        CURSOR  cur_max_org_prf   (     cp_org_unit_cd          igs_en_or_unit_wlst.org_unit_cd%TYPE ,
                                        cp_cal_type             igs_en_or_unit_wlst.cal_type%TYPE )
        IS
        SELECT  count(org_unit_wlst_prf_id)
        FROM    igs_en_orun_wlst_prf
        WHERE   org_unit_wlst_pri_id IN(SELECT  owp.org_unit_wlst_pri_id
                                        FROM    igs_en_orun_wlst_pri owp, igs_en_or_unit_wlst ouw
                                        WHERE   ouw.org_unit_cd = cp_org_unit_cd
                                        AND     ouw.cal_type = cp_cal_type
                                        AND     owp.org_unit_wlst_id = ouw.org_unit_wlst_id
                                        AND     ouw.closed_flag = 'N');
        l_max_org_pref            NUMBER;

        -- Cursor to get program version for a student program attempt
        CURSOR  cur_get_prog_ver      (cp_person_id NUMBER ,
                                       cp_course_cd VARCHAR2)
        IS
        SELECT version_number
        FROM   igs_en_stdnt_ps_att
        WHERE  person_id = cp_person_id
        AND    course_cd = cp_course_cd;

        -- Cursors to check whether given student is satisfying waitlist priority / preferences
        CURSOR  cur_program      (     cp_person_id NUMBER ,
                                       cp_course_cd VARCHAR2 ,
                                       cp_version_number NUMBER)
        IS
        SELECT 'X'
        FROM   igs_en_stdnt_ps_att
        WHERE  person_id = cp_person_id
        AND    course_cd = cp_course_cd
        AND    version_number = cp_version_number;

        CURSOR  cur_org          (     cp_person_id NUMBER ,
                                       cp_org_unit_cd VARCHAR2)
        IS
        SELECT  'X'
        FROM   igs_en_stdnt_ps_att sca,
               igs_ps_ver pv
        WHERE  sca.person_id = cp_person_id
        AND    sca.course_cd = pv.course_cd
        AND    sca.version_number = pv.version_number
        AND    pv.responsible_org_unit_cd = cp_org_unit_cd;

        CURSOR  cur_unit_set     (     cp_person_id NUMBER ,
                                       cp_unit_set_cd VARCHAR2 ,
                                       cp_us_version_number NUMBER)
        IS
        SELECT  'X'
        FROM    igs_en_stdnt_ps_att spa,
                igs_as_su_setatmpt sus
        WHERE   spa.person_id = cp_person_id
        AND     sus.person_id = spa.person_id
        AND     spa.course_cd = sus.course_cd
        AND     sus.unit_set_cd = cp_unit_set_cd
        AND     sus.us_version_number = cp_us_version_number;

        l_pref_order            NUMBER;
        l_pri_weight            NUMBER;
        l_pref_weight           NUMBER;
        l_wlst_level            VARCHAR2(10);
        l_pref_satisfied        BOOLEAN;
        l_pri_satisfied         VARCHAR2(1);
        l_teach_cal_type        igs_ca_inst.cal_type%TYPE;
        l_teach_seq_no          igs_ca_inst.sequence_number%TYPE;
        l_program_version       igs_en_stdnt_ps_att.version_number%TYPE;

BEGIN
        l_pref_order  := 0;
        l_pri_weight  := 0;
        l_pref_weight := 0;
        l_wlst_level  := NULL;

        OPEN cur_get_prog_ver(p_person_id,p_program_cd);
        FETCH cur_get_prog_ver INTO l_program_version;
        CLOSE cur_get_prog_ver;

        -- Get the maximum number of priorities at unit section level
        OPEN cur_max_uoo_pri(p_uoo_id);
        FETCH cur_max_uoo_pri INTO l_max_uoo_pri;
        CLOSE cur_max_uoo_pri;

        -- Get the maximum number of preferences among all the priorities at unit section level
        OPEN cur_max_uoo_prf(p_uoo_id);
        FETCH cur_max_uoo_prf INTO l_max_uoo_pref;
        CLOSE cur_max_uoo_prf;

        -- Loop for all priorities at unit section level
        FOR cur_wlst_uoo_pri_rec IN cur_wlst_uoo_pri(p_uoo_id)
        LOOP
          l_wlst_level := 'UNIT_SEC';
          IF cur_wlst_uoo_pri_rec.priority_value = 'PROGRAM' THEN
             l_pref_satisfied := FALSE;
             FOR cur_wlst_uoo_prf_rec IN cur_wlst_uoo_prf(cur_wlst_uoo_pri_rec.unit_sec_waitlist_priority_id)
             LOOP
               l_pref_order := l_pref_order + 1;
               OPEN cur_program (p_person_id ,
                                 cur_wlst_uoo_prf_rec.preference_code ,
                                 cur_wlst_uoo_prf_rec.preference_version);
               FETCH cur_program INTO l_pri_satisfied;
               IF cur_program%FOUND THEN
                  l_pref_satisfied := TRUE;
                  l_pref_weight := l_pref_weight + power(2,(l_max_uoo_pref-l_pref_order));
               END IF;
               CLOSE cur_program;
             END LOOP; -- End of cur_wlst_uoo_prf
             IF l_pref_satisfied THEN
                l_pri_weight := l_pri_weight + power(2,(l_max_uoo_pri-cur_wlst_uoo_pri_rec.priority_number));
             END IF;

          ELSIF cur_wlst_uoo_pri_rec.priority_value = 'ORG_UNIT' THEN
             l_pref_satisfied := FALSE;
             FOR cur_wlst_uoo_prf_rec IN cur_wlst_uoo_prf(cur_wlst_uoo_pri_rec.unit_sec_waitlist_priority_id)
             LOOP
               l_pref_order := l_pref_order + 1;
               OPEN cur_org (p_person_id ,
                             cur_wlst_uoo_prf_rec.preference_code);
               FETCH cur_org INTO l_pri_satisfied;
               IF cur_org%FOUND THEN
                  l_pref_satisfied := TRUE;
                  l_pref_weight := l_pref_weight + power(2,(l_max_uoo_pref-l_pref_order));
               END IF;
               CLOSE cur_org;
             END LOOP; -- End of cur_wlst_uoo_prf
             IF l_pref_satisfied THEN
                l_pri_weight := l_pri_weight + power(2,(l_max_uoo_pri-cur_wlst_uoo_pri_rec.priority_number));
             END IF;

          ELSIF cur_wlst_uoo_pri_rec.priority_value = 'UNIT_SET' THEN
             l_pref_satisfied := FALSE;
             FOR cur_wlst_uoo_prf_rec IN cur_wlst_uoo_prf(cur_wlst_uoo_pri_rec.unit_sec_waitlist_priority_id)
             LOOP
               l_pref_order := l_pref_order + 1;
               OPEN cur_unit_set (p_person_id ,
                                  cur_wlst_uoo_prf_rec.preference_code ,
                                  cur_wlst_uoo_prf_rec.preference_version);
               FETCH cur_unit_set INTO l_pri_satisfied;
               IF cur_unit_set%FOUND THEN
                  l_pref_satisfied := TRUE;
                  l_pref_weight := l_pref_weight + power(2,(l_max_uoo_pref-l_pref_order));
               END IF;
               CLOSE cur_unit_set;
             END LOOP; -- End of cur_wlst_uoo_prf
             IF l_pref_satisfied THEN
                l_pri_weight := l_pri_weight + power(2,(l_max_uoo_pri-cur_wlst_uoo_pri_rec.priority_number));
             END IF;

          ELSIF cur_wlst_uoo_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
             l_pref_satisfied := FALSE;
             FOR cur_wlst_uoo_prf_rec IN cur_wlst_uoo_prf(cur_wlst_uoo_pri_rec.unit_sec_waitlist_priority_id)
             LOOP
               l_pref_order := l_pref_order + 1;

               -- Call the function to determine whether the student completed the given program stage
               IF igs_en_gen_015.enrp_val_ps_stage(p_person_id, p_program_cd, l_program_version,
                                                   cur_wlst_uoo_prf_rec.preference_code)
               THEN
                  l_pref_satisfied := TRUE;
                  l_pref_weight := l_pref_weight + power(2,(l_max_uoo_pref-l_pref_order));
               END IF;
             END LOOP; -- End of cur_wlst_uoo_prf
             IF l_pref_satisfied THEN
                l_pri_weight := l_pri_weight + power(2,(l_max_uoo_pri-cur_wlst_uoo_pri_rec.priority_number));
             END IF;

          ELSIF cur_wlst_uoo_pri_rec.priority_value = 'CLASS_STD' THEN
             l_pref_satisfied := FALSE;
             FOR cur_wlst_uoo_prf_rec IN cur_wlst_uoo_prf(cur_wlst_uoo_pri_rec.unit_sec_waitlist_priority_id)
             LOOP
               l_pref_order := l_pref_order + 1;

               -- Call the function to determine the class standing of the given student
               IF igs_pr_get_class_std.get_class_standing(p_person_id, p_program_cd, 'Y', SYSDATE, NULL, NULL)
                                                          = cur_wlst_uoo_prf_rec.preference_code
               THEN
                  l_pref_satisfied := TRUE;
                  l_pref_weight := l_pref_weight + power(2,(l_max_uoo_pref-l_pref_order));
               END IF;
             END LOOP; -- End of cur_wlst_uoo_prf
             IF l_pref_satisfied THEN
                l_pri_weight := l_pri_weight + power(2,(l_max_uoo_pri-cur_wlst_uoo_pri_rec.priority_number));
             END IF;
          END IF; -- End of cur_wlst_uoo_pri_rec.priority_value
        END LOOP; -- End of cur_wlst_uoo_pri

        IF l_wlst_level IS NULL THEN

                -- Waitlist setup is not defined at unit section level,
                -- Check whether the setup is defined at unit offering level.

                -- Get the teach calender associated with the unit section
                OPEN cur_get_teach_inst(p_uoo_id);
                FETCH cur_get_teach_inst INTO cur_get_teach_inst_rec;
                CLOSE cur_get_teach_inst;

                l_teach_cal_type := cur_get_teach_inst_rec.cal_type;
                l_teach_seq_no := cur_get_teach_inst_rec.ci_sequence_number;

                -- Get the maximum number of priorities at unit offering pattern level
                OPEN cur_max_uop_pri(cur_get_teach_inst_rec.unit_cd ,
                                     cur_get_teach_inst_rec.version_number ,
                                     cur_get_teach_inst_rec.cal_type ,
                                     cur_get_teach_inst_rec.ci_sequence_number);
                FETCH cur_max_uop_pri INTO l_max_uop_pri;
                CLOSE cur_max_uop_pri;

                -- Get the maximum number of preferences among all the priorities at unit offering pattern level
                OPEN cur_max_uop_prf(cur_get_teach_inst_rec.unit_cd ,
                                     cur_get_teach_inst_rec.version_number ,
                                     cur_get_teach_inst_rec.cal_type ,
                                     cur_get_teach_inst_rec.ci_sequence_number);
                FETCH cur_max_uop_prf INTO l_max_uop_pref;
                CLOSE cur_max_uop_prf;

                -- Loop for all priorities at unit offering pattern level
                FOR cur_wlst_uop_pri_rec IN cur_wlst_uop_pri(cur_get_teach_inst_rec.unit_cd ,
                                                             cur_get_teach_inst_rec.version_number ,
                                                             cur_get_teach_inst_rec.cal_type ,
                                                             cur_get_teach_inst_rec.ci_sequence_number)
                LOOP
                  l_wlst_level := 'UNIT_PAT';
                  IF cur_wlst_uop_pri_rec.priority_value = 'PROGRAM' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_uop_prf_rec IN cur_wlst_uop_prf(cur_wlst_uop_pri_rec.unit_ofr_waitlist_priority_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_program (p_person_id ,
                                         cur_wlst_uop_prf_rec.preference_code ,
                                         cur_wlst_uop_prf_rec.preference_version);
                       FETCH cur_program INTO l_pri_satisfied;
                       IF cur_program%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_uop_pref-l_pref_order));
                       END IF;
                       CLOSE cur_program;
                     END LOOP; -- End of cur_wlst_uop_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_uop_pri-cur_wlst_uop_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_uop_pri_rec.priority_value = 'ORG_UNIT' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_uop_prf_rec IN cur_wlst_uop_prf(cur_wlst_uop_pri_rec.unit_ofr_waitlist_priority_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_org (p_person_id ,
                                     cur_wlst_uop_prf_rec.preference_code);
                       FETCH cur_org INTO l_pri_satisfied;
                       IF cur_org%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_uop_pref-l_pref_order));
                       END IF;
                       CLOSE cur_org;
                     END LOOP; -- End of cur_wlst_uop_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_uop_pri-cur_wlst_uop_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_uop_pri_rec.priority_value = 'UNIT_SET' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_uop_prf_rec IN cur_wlst_uop_prf(cur_wlst_uop_pri_rec.unit_ofr_waitlist_priority_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_unit_set (p_person_id ,
                                          cur_wlst_uop_prf_rec.preference_code ,
                                          cur_wlst_uop_prf_rec.preference_version);
                       FETCH cur_unit_set INTO l_pri_satisfied;
                       IF cur_unit_set%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_uop_pref-l_pref_order));
                       END IF;
                       CLOSE cur_unit_set;
                     END LOOP; -- End of cur_wlst_uop_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_uop_pri-cur_wlst_uop_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_uop_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_uop_prf_rec IN cur_wlst_uop_prf(cur_wlst_uop_pri_rec.unit_ofr_waitlist_priority_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;

                       -- Call the function to determine whether the student completed the given program stage
                       IF igs_en_gen_015.enrp_val_ps_stage(p_person_id, p_program_cd, l_program_version,
                                                           cur_wlst_uop_prf_rec.preference_code)
                       THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_uop_pref-l_pref_order));
                       END IF;
                     END LOOP; -- End of cur_wlst_uop_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_uop_pri-cur_wlst_uop_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_uop_pri_rec.priority_value = 'CLASS_STD' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_uop_prf_rec IN cur_wlst_uop_prf(cur_wlst_uop_pri_rec.unit_ofr_waitlist_priority_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;

                       -- Call the function to determine the class standing of the given student
                       IF igs_pr_get_class_std.get_class_standing(p_person_id, p_program_cd, 'Y', SYSDATE, NULL, NULL)
                                                                  = cur_wlst_uop_prf_rec.preference_code
                       THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_uop_pref-l_pref_order));
                       END IF;
                     END LOOP; -- End of cur_wlst_uop_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_uop_pri-cur_wlst_uop_pri_rec.priority_number));
                     END IF;
                  END IF; -- End of cur_wlst_uop_pri_rec.priority_value
                END LOOP; -- End of cur_wlst_uop_pri
        END IF;

        IF l_wlst_level IS NULL THEN

                -- Waitlist setup is not defined at unit section / unit offering level,
                -- Check whether the setup is defined at organization unit level.

                -- Get the organizational unit code associated with the unit section
                OPEN cur_org_unit_cd(p_uoo_id);
                FETCH cur_org_unit_cd INTO l_org_unit_cd;
                CLOSE cur_org_unit_cd;

                -- Get the Load Calender type associated with the teach calender
                OPEN cur_teach_to_load(l_teach_cal_type,l_teach_seq_no);
                FETCH cur_teach_to_load INTO l_load_cal_type;
                CLOSE cur_teach_to_load;

                -- Get the maximum number of priorities at organizational unit level
                OPEN cur_max_org_pri(l_org_unit_cd, l_load_cal_type);
                FETCH cur_max_org_pri INTO l_max_org_pri;
                CLOSE cur_max_org_pri;

                -- Get the maximum number of preferences among all the priorities at organizational unit level
                OPEN cur_max_org_prf(l_org_unit_cd, l_load_cal_type);
                FETCH cur_max_org_prf INTO l_max_org_pref;
                CLOSE cur_max_org_prf;

                -- Loop for all priorities at organizational unit level
                FOR cur_wlst_org_pri_rec IN cur_wlst_org_pri(l_org_unit_cd, l_load_cal_type)
                LOOP
                  l_wlst_level := 'ORG_UNIT';
                  IF cur_wlst_org_pri_rec.priority_value = 'PROGRAM' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_org_prf_rec IN cur_wlst_org_prf(cur_wlst_org_pri_rec.org_unit_wlst_pri_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_program (p_person_id ,
                                         cur_wlst_org_prf_rec.preference_code ,
                                         cur_wlst_org_prf_rec.preference_version);
                       FETCH cur_program INTO l_pri_satisfied;
                       IF cur_program%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_org_pref-l_pref_order));
                       END IF;
                       CLOSE cur_program;
                     END LOOP; -- End of cur_wlst_org_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_org_pri-cur_wlst_org_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_org_pri_rec.priority_value = 'ORG_UNIT' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_org_prf_rec IN cur_wlst_org_prf(cur_wlst_org_pri_rec.org_unit_wlst_pri_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_org (p_person_id ,
                                     cur_wlst_org_prf_rec.preference_code);
                       FETCH cur_org INTO l_pri_satisfied;
                       IF cur_org%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_org_pref-l_pref_order));
                       END IF;
                       CLOSE cur_org;
                     END LOOP; -- End of cur_wlst_org_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_org_pri-cur_wlst_org_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_org_pri_rec.priority_value = 'UNIT_SET' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_org_prf_rec IN cur_wlst_org_prf(cur_wlst_org_pri_rec.org_unit_wlst_pri_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;
                       OPEN cur_unit_set (p_person_id ,
                                          cur_wlst_org_prf_rec.preference_code ,
                                          cur_wlst_org_prf_rec.preference_version);
                       FETCH cur_unit_set INTO l_pri_satisfied;
                       IF cur_unit_set%FOUND THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_org_pref-l_pref_order));
                       END IF;
                       CLOSE cur_unit_set;
                     END LOOP; -- End of cur_wlst_org_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_org_pri-cur_wlst_org_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_org_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_org_prf_rec IN cur_wlst_org_prf(cur_wlst_org_pri_rec.org_unit_wlst_pri_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;

                       -- Call the function to determine whether the student completed the given program stage
                       IF igs_en_gen_015.enrp_val_ps_stage(p_person_id, p_program_cd, l_program_version,
                                                           cur_wlst_org_prf_rec.preference_code)
                       THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_org_pref-l_pref_order));
                       END IF;
                     END LOOP; -- End of cur_wlst_org_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_org_pri-cur_wlst_org_pri_rec.priority_number));
                     END IF;

                  ELSIF cur_wlst_org_pri_rec.priority_value = 'CLASS_STD' THEN
                     l_pref_satisfied := FALSE;
                     FOR cur_wlst_org_prf_rec IN cur_wlst_org_prf(cur_wlst_org_pri_rec.org_unit_wlst_pri_id)
                     LOOP
                       l_pref_order := l_pref_order + 1;

                       -- Call the function to determine the class standing of the given student
                       IF igs_pr_get_class_std.get_class_standing(p_person_id, p_program_cd, 'Y', SYSDATE, NULL, NULL)
                                                                  = cur_wlst_org_prf_rec.preference_code
                       THEN
                          l_pref_satisfied := TRUE;
                          l_pref_weight := l_pref_weight + power(2,(l_max_org_pref-l_pref_order));
                       END IF;
                     END LOOP; -- End of cur_wlst_org_prf
                     IF l_pref_satisfied THEN
                        l_pri_weight := l_pri_weight + power(2,(l_max_org_pri-cur_wlst_org_pri_rec.priority_number));
                     END IF;
                  END IF; -- End of cur_wlst_org_pri_rec.priority_value
                END LOOP; -- End of cur_wlst_org_pri
        END IF;

        IF l_wlst_level IS NULL THEN
           p_priority_weight := NULL;
           p_preference_weight := NULL;
        ELSE
           p_priority_weight := l_pri_weight;
           p_preference_weight := l_pref_weight;
        END IF;

END enrp_wlst_pri_pref_calc;

PROCEDURE inform_stud_not(itemtype     IN  VARCHAR2,
                           itemkey      IN  VARCHAR2,
                           actid        IN  NUMBER,
                           funcmode     IN  VARCHAR2,
                           resultout    OUT NOCOPY VARCHAR2)

------------------------------------------------------------------
  --Created by  : rnirwani, Oracle IDC
  --Date created: 12-DEC-2003
  --
  --Purpose: This procedure sets the values for person number
  -- and calendar description.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

IS


    -- cursor to get the Person Number corresponding to the person_id
    CURSOR c_person_num (cp_person_id hz_parties.party_id%TYPE) IS
           SELECT party_number
           FROM   hz_parties
           WHERE  party_id = cp_person_id;

    -- cursor to get the calendar description
    CURSOR c_cal_desc (pc_cal_type igs_ca_inst.cal_type%TYPE, pc_seq_num igs_ca_inst.sequence_number%TYPE) IS
           SELECT description
           FROM   igs_ca_inst
           WHERE  cal_type=pc_cal_type
           AND sequence_number=pc_seq_num;

  l_party_id  hz_parties.party_id%TYPE;
  l_cal_type igs_ca_inst.cal_type%TYPE;
  l_seq_num igs_ca_inst.sequence_number%TYPE;
  l_party_number hz_parties.party_number%TYPE;
  l_description igs_ca_inst.description%TYPE;

 BEGIN



   IF (funcmode  = 'RUN') THEN

     --
     -- fetch student for whom the record has been procesed and add the user name to the
     -- adhoc role
     --
     --
          l_party_id  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSON_ID');
          l_cal_type  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_LOAD_CAL_TYPE');
          l_seq_num  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_LOAD_CA_SEQ_NUM');


     -- Getting the Person Number
           OPEN c_person_num(l_party_id);
           FETCH c_person_num INTO l_party_number;
           CLOSE c_person_num;


     -- Setting the Load calendar description
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'P_PERSON_NUM',
                                 avalue    =>  l_party_number
                                );



     -- Getting the Load Calendar Description
           OPEN c_cal_desc(l_cal_type,l_seq_num);
           FETCH c_cal_desc INTO l_description;
           CLOSE c_cal_desc;


     -- Setting the Load calendar description
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'P_LOAD_CAL_DESC',
                                 avalue    =>  l_description
                                );

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

END inform_stud_not;



END igs_en_wlst_gen_proc ;---------

/
