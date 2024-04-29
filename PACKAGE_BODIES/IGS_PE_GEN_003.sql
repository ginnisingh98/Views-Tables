--------------------------------------------------------
--  DDL for Package Body IGS_PE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_GEN_003" AS
/* $Header: IGSPE18B.pls 120.9 2006/01/23 06:33:29 gmaheswa noship $ */
/*
  ||  Created By : gmaheswa
  ||  Created On : 2-NOV-2004
  ||  Purpose : Created to process FA todo items in case of insert/update of housing status/residency status
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
  ||  skpandey        18-AUG-2005     Bug#: 4378028
  ||                                  Added procedure raise_person_type_event and resp_assignment to handle person type responsibility enhancements
*/
PROCEDURE process_res_dtls(
                           p_action        IN  VARCHAR2 , -- I/U I-INSERT U-UPDATE,
                           p_old_record    IN  igs_pe_res_dtls_all%ROWTYPE,
                           p_new_record    IN  igs_pe_res_dtls_all%ROWTYPE
                          ) AS
l_label             VARCHAR2(100);
l_debug_str         VARCHAR2(2000);
l_residency_class   igs_pe_res_dtls.residency_class_cd%TYPE;
BEGIN
  fnd_profile.get('IGS_FI_RES_CLASS_ID',l_residency_class);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igs.plsql.igs_pe_gen_003.process_res_dtls.debug','l_residency_class:'||l_residency_class);
  END IF;
  IF (p_action = 'I' AND NVL(l_residency_class,'*') = p_new_record.residency_class_cd)
  OR (p_action = 'U' AND NVL(l_residency_class,'*') = p_new_record.residency_class_cd AND NVL(p_old_record.residency_status_cd,'*') <> NVL(p_new_record.residency_status_cd,'*')) THEN
    igf_aw_coa_gen.ins_coa_todo(
                                p_new_record.person_id,
                                'IGSPE18B'
                               );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      l_label := 'igs.plsql.igs_pe_gen_003.process_res_dtls.exception';
    IF fnd_log.test(fnd_log.level_exception,l_label) THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      l_debug_str :=  fnd_message.get || '. Residency Details Id : '||P_NEW_RECORD.RESIDENT_DETAILS_ID ||' '|| SQLERRM;
      fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
END process_res_dtls;

PROCEDURE process_housing_dtls(
                               p_action      IN  VARCHAR2 , -- I/U I-INSERT U-UPDATE,
                               p_old_record  IN  igs_pe_teach_periods_all%ROWTYPE,
                               p_new_record  IN  igs_pe_teach_periods_all%ROWTYPE
                              ) AS
l_label             VARCHAR2(100);
l_debug_str         VARCHAR2(2000);

BEGIN
  IF p_action = 'I' OR (p_action = 'U' AND NVL(p_old_record.teach_period_resid_stat_cd,'*') <> NVL(p_new_record.teach_period_resid_stat_cd,'*')) THEN
    igf_aw_coa_gen.ins_coa_todo(
                                p_new_record.person_id,
                                'IGSPE18B'
                               );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_label := 'igs.plsql.igs_pe_gen_003.process_housing_dtls.exception';
    IF fnd_log.test(fnd_log.level_exception,l_label) THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      l_debug_str :=  fnd_message.get || '. Teaching Period Id : '||P_NEW_RECORD.TEACHING_PERIOD_ID ||' '|| SQLERRM;
      fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
END process_housing_dtls;


PROCEDURE RAISE_PERSON_TYPE_EVENT(
                                  p_person_id          IN    NUMBER,
                                  p_person_type_code   IN    VARCHAR2,
                                  p_action             IN    VARCHAR2,
				  p_end_date           IN    DATE
                                  ) AS

/*
  ||  Created By : skpandey
  ||  Created On : 2-aug-2005
  ||  Purpose : 4378028
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
  ||  ssawhney        18-AUG-2005     Bug#: 4378028 added end date.
*/
---- Cursor to get system_type_person
CURSOR get_sys_person_id(cp_person_type_code igs_pe_typ_instances_all.person_type_code%TYPE) IS
    SELECT ppt.system_type
    FROM igs_pe_person_types ppt
    WHERE ppt.person_type_code = cp_person_type_code;

---- Cursor to get next sequence number
CURSOR c_seq_num IS
    SELECT IGS_PE_PER_TYP_WF_S.nextval
    FROM DUAL;

    l_system_type         IGS_PE_PERSON_TYPES.system_type%TYPE;
    ln_seq_val            NUMBER;
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t := wf_parameter_list_t();
    l_prog_label          CONSTANT VARCHAR2(100) := 'igs.plsql.igs_pe_gen_003.raise_person_type_event';
    l_label               VARCHAR2(500);
    l_debug_str           VARCHAR2(3200);

BEGIN
   --Get system type
     OPEN  get_sys_person_id(p_person_type_code);
     FETCH get_sys_person_id INTO l_system_type ;
     CLOSE get_sys_person_id ;

  -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

  -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'PERSON_ID', p_value => p_person_id, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'S_PERSON_TYPE', p_value => l_system_type, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'ACTION', p_value => p_action, p_parameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'END_DATE', p_value => p_end_date, p_parameterList  => l_parameter_list_t);


  -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;

  -- fnd_logging before raising business event
     IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
        l_label := 'igs.plsql.igs_pe_gen_003.raise_person_type_event.raise_event';
        l_debug_str :=  fnd_message.get || ' Action : ' || p_action ||'/' ||' Person : ' ||p_person_id ||'/'||' S person type : '||l_system_type ||'/' || ' Sequence is : '||ln_seq_val ;
        fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

  -- raise event
     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pe.person_type_change',
                     p_event_key  => 'RESP_ASSIGNMENT'||ln_seq_val,
                     p_parameters => l_parameter_list_t
                     );

   -- Delete parameter_list
     l_parameter_list_t.DELETE;

     --COMMIT; should not be doing commit inside BE flow, AD has further processsing.

  -- Exception Handling
EXCEPTION
  WHEN OTHERS THEN

     IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
        l_label := 'igs.plsql.igs_pe_gen_003.raise_person_type_event.execption';
        l_debug_str :=  fnd_message.get || 'Person : ' ||p_person_id ||'/'||' S person type : '||l_system_type ||'/' || ' sequence is : '||ln_seq_val ||'/'|| SQLERRM ;
        fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

END RAISE_PERSON_TYPE_EVENT;



FUNCTION RESP_ASSIGNMENT(
                         p_subscription_guid in raw,
                         p_event in out NOCOPY wf_event_t
                         ) RETURN VARCHAR2 AS
/*
  ||  Created By : skpandey
  ||  Created On : 2-aug-2005
  ||  Purpose : 4378028
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
  ||  ssawhney        18-AUG-2005     Bug#: 4378028 added end date logic in insert/update.
*/

l_default_date             DATE := TO_DATE('4712/12/31','YYYY/MM/DD');
---- Get the FND User Information for the Person ID passed.
CURSOR get_user_id_cur(cp_person_id fnd_user.person_party_id%type) IS
SELECT user_id
FROM fnd_user
WHERE person_party_id = cp_person_id;

-- Exclusively for Insert.
---- Get the responsibilities associated with the System Person Type, which are not associated with the person already. INSERT CASE
CURSOR get_resp_info_cur(cp_system_person_typ igs_pe_typ_rsp_dflt.s_person_type%type, cp_user_id fnd_user.user_id%type) IS
SELECT default_resp.responsibility_key, oss.application_short_name, default_resp.responsibility_id, default_resp.application_id, default_resp.description
FROM igs_pe_typ_rsp_dflt oss , fnd_responsibility_vl default_resp
WHERE oss.s_person_type= cp_system_person_typ
AND oss.responsibility_key = default_resp.responsibility_key
AND NOT EXISTS
(SELECT 1
FROM fnd_user_resp_groups_direct resp_group
WHERE user_id = cp_user_id AND
resp_group.responsibility_id = default_resp.responsibility_id AND
resp_group.responsibility_application_id = default_resp.application_id
);


-- Get the Default responsibilities mapping with the System Person Type ,
-- that are present with the user. Update the end date. Both INSERT/UPDATE case
CURSOR get_inactive_resp_cur(cp_user_id fnd_user.user_id%type, cp_system_person_type igs_pe_typ_rsp_dflt.s_person_type%type) IS
SELECT  resp.responsibility_key, resp.responsibility_id, resp.application_id, resp_group.start_date, Resp_group.end_date, fnd.application_short_name
FROM fnd_user_resp_groups_direct resp_group, fnd_responsibility resp , igs_pe_typ_rsp_dflt oss, fnd_application fnd
WHERE user_id = cp_user_id AND
Resp.responsibility_id = resp_group.Responsibility_id AND
Resp.application_id = resp_group.responsibility_application_id AND
oss.s_person_type = cp_system_person_type AND
oss.responsibility_key =  resp.responsibility_key AND
resp.application_id = fnd.application_id;


-- if a resp is through 2 pti. then since the event is fired after_dml, then max of null and static would return static
-- hence need to use l_default.
CURSOR get_max_date (cp_person_id NUMBER, cp_resp_key VARCHAR2,cp_app_short_name VARCHAR2) IS
SELECT max(NVL(pti.end_date , l_default_date))
FROM   igs_pe_typ_instances_all pti , igs_pe_person_types typ , igs_pe_typ_rsp_dflt dflt
WHERE  pti.person_id = cp_person_id AND
       pti.person_type_code = typ.person_type_code AND
       typ.system_type = dflt.s_person_type AND
       dflt.responsibility_key = cp_resp_key AND
       dflt.application_short_name = cp_app_short_name;




---- Get all those responsibilities associated with the System Person Type of OTHER. DELETE CASE
CURSOR get_resp_sys_cur(cp_user_id fnd_user.user_id%type, cp_system_person_type igs_pe_typ_rsp_dflt.s_person_type%type) IS
SELECT  resp.application_id, resp.responsibility_id , resp.responsibility_key, resp_group.start_date, Resp_group.end_date
FROM fnd_user_resp_groups_direct resp_group, fnd_responsibility resp
WHERE user_id = cp_user_id AND
Resp.responsibility_id = resp_group.Responsibility_id AND
Resp.application_id = resp_group.responsibility_application_id
--AND Resp_group.end_date IS NOT NULL
AND EXISTS
   (SELECT 1
    FROM igs_pe_typ_rsp_dflt oss
    WHERE oss.s_person_type= cp_system_person_type
    AND oss.responsibility_key = resp.responsibility_key);


l_parameter_list_t         wf_parameter_list_t := wf_parameter_list_t();
l_person_id                NUMBER(15);
l_system_person_type       VARCHAR2(30);
l_action                   VARCHAR2(10);
l_user_id                  fnd_user.user_id%type;
l_result                   VARCHAR2(100);
l_prog_label               CONSTANT VARCHAR2(100) := 'igs.plsql.igs_pe_gen_003.resp_assignment';
l_label                    VARCHAR2(500);
l_debug_str                VARCHAR2(3200);
l_end_date                 DATE;

l_update_resp              BOOLEAN := FALSE;
l_max_end_date             DATE;
---------Main Start-------------------------------------------------
BEGIN

l_parameter_list_t := p_event.getparameterlist;
l_person_id := TO_NUMBER(wf_event.getvalueforparameter('PERSON_ID',l_parameter_list_t));
l_system_person_type := wf_event.getvalueforparameter('S_PERSON_TYPE',l_parameter_list_t);
l_action := wf_event.getvalueforparameter('ACTION',l_parameter_list_t);
l_end_date :=   igs_ge_date.igsdate(igs_ge_date.igschar(wf_event.getvalueforparameter('END_DATE',l_parameter_list_t))) ;


  --Get User id
    OPEN get_user_id_cur(l_person_id);
    FETCH get_user_id_cur INTO l_user_id;
    CLOSE get_user_id_cur;

---- l_action is INSERT
  IF l_action IN ('INSERT', 'UPDATE')  THEN

    FOR inactive_resp_rec IN get_inactive_resp_cur(l_user_id, l_system_person_type) LOOP

             --fnd_logging
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_pe_gen_003.resp_assignment.'||l_action;
                 l_debug_str := fnd_message.get || 'System Person Type : '||l_system_person_type ||'/'|| ' User id : ' ||l_user_id || ' End Date ' ||'/' ||l_end_date;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

        IF l_action = 'INSERT' THEN
        -- if any existing resp exists, then update them with the MAX end date between PTI end date and existing resp end date.
             IF  ( NVL(inactive_resp_rec.end_date, l_default_date) < NVL(TRUNC(l_end_date), l_default_date)   )  THEN
		   l_update_resp := TRUE;
             END IF;
        ELSE
	   --l_action is update.
	     OPEN get_max_date (l_person_id,inactive_resp_rec.responsibility_key, inactive_resp_rec.application_short_name);
	     FETCH get_max_date INTO l_max_end_date;
	     CLOSE get_max_date;

             IF (l_max_end_date IS NULL AND inactive_resp_rec.end_date IS NULL) OR
	        (l_max_end_date = inactive_resp_rec.end_date ) THEN
	         l_update_resp := FALSE;
             ELSE
	         l_update_resp := TRUE;

                 IF l_end_date > l_max_end_date THEN
                   -- This is the exceptional scnerio when record from import process is updated with end date < current date
                   -- And Current date is passed in place of that from the TBH
                   l_end_date := l_end_date ;
                 ELSE
                   -- This is the usual scenerio
            	   l_end_date := l_max_end_date ;
                 END IF;

		 --after assignment, if end_date = default then set end date to null.
		 IF l_end_date = l_default_date THEN
		    l_end_date := null;
		 END IF;
	     END IF;

	END IF;

	       --Call update
	       IF l_update_resp THEN
                  fnd_user_resp_groups_api.update_assignment (
                                                   user_id                         => l_user_id,
                                                   responsibility_id               => inactive_resp_rec.responsibility_id,
                                                   responsibility_application_id   => inactive_resp_rec.application_id,
                                                   security_group_id               => 0,
                                                   start_date                      => inactive_resp_rec.start_date,
                                                   end_date                        => TRUNC(l_end_date),
                                                   description                     => NULL);
	       END IF;
    END LOOP;

    FOR resp_info_rec IN get_resp_info_cur(l_system_person_type, l_user_id) LOOP
         --fnd_logging
             IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_pe_gen_003.resp_assignment.'||l_action;
                 l_debug_str := fnd_message.get || 'System Person Type : '||l_system_person_type ||'/'|| ' User id : ' ||l_user_id ||  ' End Date ' ||'/' ||l_end_date;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
             END IF;
       Fnd_User_Resp_Groups_api.insert_assignment (
                                                   user_id                         => l_user_id,
                                                   responsibility_id               => resp_info_rec.responsibility_id,
                                                   responsibility_application_id   => resp_info_rec.application_id,
                                                   security_group_id               => 0,
                                                   start_date                      => SYSDATE,
                                                   end_date                        => TRUNC(l_end_date),
                                                   description                     => resp_info_rec.description);
    END LOOP;

---- l_action is DELETE
ELSIF l_action = 'DELETE' THEN

   FOR resp_sys_rec IN get_resp_sys_cur(l_user_id, l_system_person_type) LOOP
      --fnd_logging
             IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_pe_gen_003.resp_assignment.delete';
                 l_debug_str := fnd_message.get || 'System Person Type : '||l_system_person_type ||'/'|| ' User id : ' ||l_user_id || ' Resp ' ||resp_sys_rec.responsibility_id ;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
             END IF;

      -- Delete event will only be called for Others person type. And will always be for sysdate.
      -- if the resp is already end date with a past end date. Then dont touch it.
        IF  ( NVL(resp_sys_rec.end_date, sysdate) >= sysdate) THEN
            fnd_user_resp_groups_api.update_assignment (
                                                   user_id                         => l_user_id,
                                                   responsibility_id               => resp_sys_rec.responsibility_id,
                                                   responsibility_application_id   => resp_sys_rec.application_id,
                                                   security_group_id               => 0,
                                                   start_date                      => resp_sys_rec.start_date,
                                                   end_date                        => TRUNC(SYSDATE),
                                                   description                     => NULL);
	END IF;
    END LOOP;
 END IF;

l_result := wf_rule.default_rule(p_subscription_guid, p_event);

RETURN(l_result);

EXCEPTION
  WHEN OTHERS THEN

	--fnd_logging
             IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_pe_gen_003.resp_assignment.exception';
                 l_debug_str := fnd_message.get || 'System Person Type : '||l_system_person_type ||'/'|| ' User id : ' ||l_user_id || SQLERRM;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
             END IF;

  WF_CORE.CONTEXT('IGS_PE_ELEARNING_PKG','RESP_ASSIGNMENT',1, p_subscription_guid);
  wf_event.setErrorInfo(p_event,'ERROR');

END RESP_ASSIGNMENT;

PROCEDURE TURNOFF_TCA_BE(
	p_turnoff VARCHAR2
) AS
/*
  ||  Created By : gmaheswa
  ||  Created On : 17-Jan-2006
  ||  Purpose : 4938278
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
*/
i BOOLEAN;
BEGIN

   IF p_turnoff = 'Y' THEN
      g_hz_api_callouts_profl := FND_PROFILE.VALUE('HZ_EXECUTE_API_CALLOUTS');
      IF g_hz_api_callouts_profl <> 'N' THEN
           FND_PROFILE.PUT('HZ_EXECUTE_API_CALLOUTS','N');
      END IF;
   ELSIF  p_turnoff = 'N' THEN
      IF g_hz_api_callouts_profl <> 'N' THEN
           FND_PROFILE.PUT('HZ_EXECUTE_API_CALLOUTS',g_hz_api_callouts_profl);
      END IF;
   END IF;
END TURNOFF_TCA_BE;


END igs_pe_gen_003;

/
