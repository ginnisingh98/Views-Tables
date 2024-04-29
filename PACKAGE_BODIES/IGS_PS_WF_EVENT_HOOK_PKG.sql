--------------------------------------------------------
--  DDL for Package Body IGS_PS_WF_EVENT_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_WF_EVENT_HOOK_PKG" AS
/* $Header: IGSPS79B.pls 120.2 2006/01/31 01:52:02 sommukhe noship $ */
procedure wf_get_shadow_values( p_uoo_id IN NUMBER,
                           p_unit_section_occurrence_id IN NUMBER,
                           p_type IN VARCHAR2,
                           p_old_values IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.OCCUROLD,
                           p_new_values IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.OCCURNEW,
			   p_unit_dtls  IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.UNITDTLS)
IS
	/**********************************************************
	  Created By :

	  Date Created By :

	  Purpose :

	  Know limitations, enhancements or remarks

	  Change History

	  Who           When            What
          sommukhe      24-Jan-2006     Bug #4926548,replaced igs_pe_person with hz_parties and hz_person_profiles for inline cursors p_students and p_instructors
	  sarakshi      12-Jan-2005     Bug#4926548, modified the select for the ref cursor p_unit_dtls such ath tit uses the base tables rather than the view IGS_PS_UNIT_OFR_OPT_V
	***************************************************************/

BEGIN
	IF p_type = 'CNCL' THEN
	  RETURN;
	END IF;
  IF p_unit_dtls%ISOPEN THEN
	CLOSE p_unit_dtls;
  END IF;
  IF p_new_values%ISOPEN THEN
	CLOSE p_new_values;
  END IF;
  IF p_old_values%ISOPEN THEN
	CLOSE p_old_values;
  END IF;
  OPEN p_unit_dtls FOR SELECT us.unit_cd,
	   uv.title,
	   ca.start_dt cal_start_dt,
	   ca.end_dt cal_end_dt,
	   us.location_cd,
	   loc.description location_description,
	   uc.unit_mode unit_mode
	  FROM igs_ps_unit_ofr_opt_all us, igs_ca_inst_all ca, igs_ps_unit_ver_all uv, igs_as_unit_class_all uc, igs_ad_location_all loc
	  WHERE us.unit_cd=uv.unit_cd
	  AND   us.version_number=uv.version_number
	  AND   us.cal_type=ca.cal_type
	  AND   us.ci_sequence_number=ca.sequence_number
	  AND   us.unit_class=uc.unit_class
	  AND   us.location_cd=loc.location_cd
	  AND   us.uoo_id = p_uoo_id;
  OPEN p_new_values FOR SELECT Monday,
	   Tuesday,
	   wednesday,
	   thursday,
	   friday,
	   Saturday,
	   sunday,
	   start_time,
	   end_time,
	   building_code,
	   room_code
	  FROM  IGS_PS_USEC_OCCURS
	  WHERE notify_status='TRIGGER'
	  AND unit_section_occurrence_id = p_unit_section_occurrence_id;
  OPEN p_old_values FOR SELECT unit_section_occurrence_id,
	   Monday,
	   Tuesday,
	   wednesday,
	   thursday,
	   friday,
	   Saturday,
	   sunday,
	   start_time,
	   end_time,
	   building_code,
	   room_code
	  FROM  IGS_PS_SH_USEC_OCCURS
	  WHERE unit_section_occurrence_id = p_unit_section_occurrence_id;
END wf_get_shadow_values;

procedure wf_event_audience (p_uoo_id IN NUMBER,
                           p_unit_section_occurrence_id IN NUMBER,
                           p_type IN VARCHAR2,
                           p_students IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.StudentDetails,
                           p_instructors IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.InstructorDetails)
IS
CURSOR c_notify IS SELECT a.inst_notify_ind,
	b.instructor_id
 FROM IGS_PS_USEC_OCCURS a,
      IGS_PS_USO_INSTRCTRS_V b
 WHERE a.unit_section_occurrence_id = p_unit_section_occurrence_id
 AND a.unit_section_occurrence_id=b.unit_section_occurrence_id;

l_inst_notify_ind IGS_PS_USEC_OCCURS.inst_notify_ind%TYPE;
l_instructor_id IGS_PS_USO_INSTRCTRS_V.instructor_id%TYPE;
BEGIN

IF p_type='MOD' THEN
  IF p_students%ISOPEN THEN
    CLOSE p_students;
  ELSE
  OPEN p_students FOR SELECT a.person_id,
	   a.unit_attempt_status,
	   p.party_number person_number,
	   p.email_address email_addr,
	   pp.person_name full_name
	   FROM  igs_en_su_attempt a,hz_parties p,hz_person_profiles pp
	   WHERE a.UOO_ID=p_uoo_id
	  AND a.UNIT_ATTEMPT_STATUS IN ('ENROLLED','WAITLISTED')
	  AND a.person_id=p.party_id
  	  AND p.party_id = pp.party_id AND
          SYSDATE BETWEEN PP.EFFECTIVE_START_DATE AND
          NVL(PP.EFFECTIVE_END_DATE,SYSDATE);
  END IF;
END IF;

IF p_type='CNCL' THEN
  IF p_students%ISOPEN THEN
    CLOSE p_students;
  ELSE
  OPEN p_students FOR SELECT a.person_id,
  	   a.unit_attempt_status,
  	   p.party_number person_number,
  	   p.email_address email_addr,
  	   pp.person_name full_name
  	  FROM  igs_en_su_attempt a,hz_parties p,hz_person_profiles pp
  	  WHERE a.uoo_id=p_uoo_id
  	  AND a.unit_attempt_status IN ('DROPPED','DISCONTIN')
  	  AND a.person_id=p.party_id
  	  AND p.party_id = pp.party_id AND
          SYSDATE BETWEEN PP.EFFECTIVE_START_DATE AND
          NVL(PP.EFFECTIVE_END_DATE,SYSDATE);
  END IF;
END IF;
OPEN c_notify;
FETCH c_notify INTO l_inst_notify_ind, l_instructor_id;
IF l_inst_notify_ind='Y' THEN
LOOP
  IF p_instructors%ISOPEN THEN
  close p_instructors;
  ELSE
  OPEN p_instructors FOR SELECT P.PARTY_NUMBER PERSON_NUMBER,P.EMAIL_ADDRESS EMAIL_ADDR,PP.PERSON_NAME FULL_NAME
                         FROM HZ_PARTIES P,HZ_PERSON_PROFILES PP
                         WHERE P.PARTY_ID = l_instructor_id
                         AND  P.PARTY_ID = PP.PARTY_ID AND
                          SYSDATE BETWEEN PP.EFFECTIVE_START_DATE AND
                          NVL(PP.EFFECTIVE_END_DATE,SYSDATE);
  END IF;
END LOOP;
END IF;
CLOSE c_notify;
END wf_event_audience;
END IGS_PS_WF_EVENT_HOOK_PKG;

/
