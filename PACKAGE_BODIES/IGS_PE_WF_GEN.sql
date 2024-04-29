--------------------------------------------------------
--  DDL for Package Body IGS_PE_WF_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_WF_GEN" AS
/* $Header: IGSPE07B.pls 120.9 2006/05/26 05:39:45 vskumar ship $ */

/******************************************************************
 Created By         : Vinay Chappidi
 Date Created By    : 20-Sep-2001
 Purpose            : Workflow General package for Person Module
 remarks            :
 Change History
 Who      When        What
 sarakshi 23-Jan-2006 Bug#4938278, created TYPE t_addr_chg_persons and three procedures process_addr_sync,write_addr_sync_message and addr_bulk_synchronization
 nsidana  9/9/2003    New functions added as part of SWSCR01-02-04
                      address_create,address_update,primary_address_ind_update
                      old function change_address stubbed.
 asbala   01-09-2003  Reference: Build SWCR01,02,04
                      Business Event triggered
 gmaheswa 3-Nov-2004  Created a procedure change_housing_status for raising an event in case of insert/update of housing status
 pkpatel  9-Nov-2004  Bug 3993967 (Modified signature of procedure CHANGE_RESIDENCE. Modified process_residency as per new
                      Notification message. Stubbed the procedure get_res_details.)
 pkpatel  19=Sep-2005 Bug 4618459 (Removed the reference of HZ_PARAM_TAB. Commented the procedure get_address_dtls.
                      stubbed the procedures address_update and primary_address_ind_update)
 pkpatel  21-Feb-2006 Bug 4938278 (Added the cursor in the create_address to retrieve the Dates from igs_pe_hz_pty_sites)
  vskumar   24-May-2006 Bug 5211157 Added two procdeures specs raise_acad_intent_event and process_acad_intent
******************************************************************/


  PROCEDURE change_residence( p_resident_details_id IN NUMBER,
							  p_old_res_status IN VARCHAR2,
							  p_old_evaluator IN VARCHAR2,
							  p_old_evaluation_date IN VARCHAR2,
   							  p_old_comment IN VARCHAR2,
							  p_action IN VARCHAR2) AS
  /******************************************************************
   Created By         : Vinay Chappidi
   Date Created By    : 20-Sep-2001
   Purpose            : Procedure for sending workflow mail notification when the
                        residency status or class is changed, to inform Fee Asess user(STUDENT_FIN User)
   remarks            :
   Change History
   Who      When        What
   asbala   01-09-2003  Reference: Build SWCR01,02,04
  ******************************************************************/


    CURSOR c_seq_num IS
    SELECT IGS_PE_PE003_WF_S.nextval
    FROM DUAL;
    ln_seq_val            NUMBER;
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
  BEGIN

   -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

   -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'RES_DTLS_ID', p_value => p_resident_details_id, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'OLD_RES_STATUS', p_value => p_old_res_status, p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'OLD_EVALUATOR', p_Value => p_old_evaluator, p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'OLD_EVAL_DATE', p_Value => p_old_evaluation_date, p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'OLD_COMMENTS', p_Value => p_old_comment, p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'ACTION', p_Value => p_action, p_ParameterList  => l_parameter_list_t);
   -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;

     -- raise event
     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pe.residency_change',
	  p_event_key  => 'IGSPE001'||ln_seq_val,
	  p_parameters => l_parameter_list_t
     );
  END change_residence;


  PROCEDURE change_address( p_person_number IN VARCHAR2, p_full_name IN VARCHAR2) AS
   /******************************************************************
    Created By         : Vinay Chappidi
    Date Created By    : 20-Sep-2001
    Purpose            : Procedure for sending workflow mail notification when the
                         address is changed, to inform Responsible Person(RES_PERSON user)
    Remarks            :
    Change History
    Who      When        What
    nsidana  9/9/2003    Stubbing the procedure as new procedures are in place below.
   ******************************************************************/
  BEGIN
      NULL;
  END change_address;


PROCEDURE process_residency(itemtype       IN              VARCHAR2,
          itemkey        IN              VARCHAR2,
          actid          IN              NUMBER,
          funcmode       IN              VARCHAR2,
          resultout      OUT NOCOPY      VARCHAR2) IS
   /******************************************************************
    Created By         : Ashwini Bala
    Date Created By    : 01-Sep-2003
    Purpose            : To trigger the Business Event
    Remarks            :
    Change History
    Who      When        What
   ******************************************************************/

   CURSOR c_get_person_name(cp_person_id NUMBER) IS
     SELECT full_name person_name,person_number
     FROM igs_pe_person_base_v
     WHERE person_id = cp_person_id;

   CURSOR res_dtl_cur(cp_resident_details_id NUMBER) IS
   SELECT person_id, cal_type, sequence_number, residency_class, residency_class_desc, residency_status_desc,
          calendar_desc, evaluation_date, evaluator, comments, last_updated_by
   FROM igs_pe_res_dtls_v
   WHERE resident_details_id = cp_resident_details_id;

   CURSOR res_status_cur (cp_lookup_type VARCHAR2, cp_lookup_code VARCHAR2) IS
   SELECT meaning
   FROM igs_lookup_values
   WHERE lookup_type = cp_lookup_type AND
         lookup_code = cp_lookup_code;

   CURSOR updated_by_cur(cp_user_id NUMBER) IS
   SELECT user_name
   FROM   fnd_user
   WHERE user_id = cp_user_id;

   l_res_dtls_id       igs_pe_res_dtls_all.resident_details_id%TYPE;
   l_old_res_status    igs_pe_res_dtls_all.residency_status_cd%TYPE;
   l_old_eval_date     DATE;
   l_old_evaluator     igs_pe_res_dtls_all.evaluator%TYPE;
   l_old_comments      igs_pe_res_dtls_all.comments%TYPE;
   l_res_status_desc   igs_lookup_values.meaning%TYPE;
   l_user_name         fnd_user.user_name%TYPE;
   l_date              DATE;
   l_action            VARCHAR2(30);
   l_name              hz_person_profiles.person_name%TYPE;
   l_person_number     hz_parties.party_number%TYPE;
   l_message  VARCHAR2(2000);
   res_dtl_rec         res_dtl_cur%ROWTYPE;
BEGIN

 fnd_message.set_name('IGS','IGS_PE_RES_CHG_MES_SUBJ');
 l_message := fnd_message.get;

 -- Getting the paremeter values from the workflow

 l_res_dtls_id := Wf_Engine.GetItemAttrText(itemtype,itemkey,'RES_DTLS_ID');
 l_action    := Wf_Engine.GetItemAttrText(itemtype,itemkey,'ACTION');
 l_date      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'OLD_EVAL_DATE');

 OPEN res_dtl_cur(l_res_dtls_id);
 FETCH res_dtl_cur INTO res_dtl_rec;
 CLOSE res_dtl_cur;

 -- getting the person_number and name for the required person
 OPEN c_get_person_name(res_dtl_rec.person_id);
 FETCH c_get_person_name INTO l_name,l_person_number;
 CLOSE c_get_person_name;

Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'PERSON_ID',
		       avalue    =>  res_dtl_rec.person_id
		    );

Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'RES_CLASS',
		       avalue    =>  res_dtl_rec.residency_class
		    );

 Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_RES_STATUS',
		       avalue    =>  res_dtl_rec.residency_status_desc
		    );

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_EVAL_DATE',
		       avalue    =>  res_dtl_rec.evaluation_date
		    );

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'CALENDAR_DESC',
		       avalue    =>  res_dtl_rec.calendar_desc
		    );

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_EVALUATOR',
		       avalue    =>  res_dtl_rec.evaluator
		    );
   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'PERSON_NUMBER',
		       avalue    =>  l_person_number
		    );
   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NAME',
		       avalue    =>  l_name
		    );

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'RES_CLASS_DESC',
		       avalue    =>  res_dtl_rec.residency_class_desc
		    );

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_COMMENTS',
		       avalue    =>  res_dtl_rec.comments
		    );
   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'SUBJECT',
		       avalue    =>  l_message
		    );

   OPEN updated_by_cur(res_dtl_rec.last_updated_by);
   FETCH updated_by_cur INTO l_user_name;
   CLOSE updated_by_cur;

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'UPDATED_BY',
		       avalue    =>  l_user_name
		    );

 IF l_action='U' THEN

   l_old_res_status := Wf_Engine.GetItemAttrText(itemtype,itemkey,'OLD_RES_STATUS');

   OPEN res_status_cur('PE_RES_STATUS', l_old_res_status);
   FETCH res_status_cur INTO l_res_status_desc;
   CLOSE res_status_cur;

   Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'OLD_RES_STATUS',
		       avalue    =>  l_res_status_desc
		    );

   resultout := 'COMPLETE:U';
 ELSIF l_action='I' THEN
   resultout := 'COMPLETE:I';
 END IF;

END process_residency;


PROCEDURE get_res_details(
          p_person_id       IN              NUMBER,
          p_res_class       IN              VARCHAR2,
          p_res_dtls_rec    OUT NOCOPY      igs_pe_res_dtls_v%ROWTYPE,
          p_ind             IN              VARCHAR2 DEFAULT 'NEW' ) IS

   /******************************************************************
    Created By         : Ashwini Bala
    Date Created By    : 1-Sep-2003
    Purpose            : To get the details from the database
    Remarks            :
    Change History
    Who      When        What
   ******************************************************************/
BEGIN
   NULL;
END get_res_details;

PROCEDURE address_create(itemtype IN VARCHAR2,
                         itemkey IN VARCHAR2,
                         actid IN NUMBER,
                         funcmode IN VARCHAR2,
                         resultout OUT NOCOPY VARCHAR2)

/******************************************************************
 Created By         : Navin Sidana.
 Date Created By    : 9/9/2003
 Purpose            : Function to process party site create event
                      raised from HZ.
 remarks            :
 Change History
 Who      When        What
******************************************************************/
IS

CURSOR cur_get_party_id(cp_party_site_id NUMBER) IS
SELECT party_number, party_name, location_id,hp.party_type,hp.party_id
FROM    hz_parties hp, hz_party_sites hps
WHERE hp.party_id = hps.party_id AND
                (hp.party_type = 'PERSON' OR hp.party_type = 'ORGANIZATION') AND
                hp.status = 'A'  AND
                hps.party_site_id = cp_party_site_id;

CURSOR get_location_dets(cp_party_site_id NUMBER) IS
SELECT hzl.address1, hzl.address2, hzl.address3, hzl.address4, hzl.city, hzl.province, hzl.state ,
       hzl.county, hzl.postal_code, hzl.country, hzl.delivery_point_code ,hzp.party_number,
       hzp.party_name,hps.identifying_address_flag
FROM
hz_party_sites hps,
hz_locations hzl,
hz_parties hzp
WHERE
hps.party_site_id=cp_party_site_id AND
hps.location_id=hzl.location_id AND
hzp.party_id=hps.party_id;


CURSOR chk_oss_party(cp_party_id NUMBER) IS
SELECT inst_org_ind
FROM
       igs_pe_hz_parties
WHERE
       party_id = cp_party_id;


CURSOR get_country(cp_country VARCHAR2) IS
SELECT territory_short_name
FROM fnd_territories_vl
WHERE territory_code = cp_country;

CURSOR get_lkup_meaning(cp_lk_code VARCHAR2) IS
SELECT meaning
FROM igs_lookup_values
WHERE
lookup_type='YES_NO' AND
lookup_code=cp_lk_code;

CURSOR get_effective_dates_cur (cp_party_site_id NUMBER) IS
SELECT start_date, end_date
FROM igs_pe_hz_pty_sites
WHERE party_site_id = cp_party_site_id;

cur_get_party_id_rec   cur_get_party_id%ROWTYPE;
get_location_dets_rec  get_location_dets%ROWTYPE;
chk_oss_party_rec      chk_oss_party%ROWTYPE;
get_country_rec        get_country%ROWTYPE;
l_lkup_meaning         VARCHAR2(100);
l_party_site_id        VARCHAR2(100);
l_message              VARCHAR2(200);
l_country_desc         VARCHAR2(100);
get_effective_dates_rec get_effective_dates_cur%ROWTYPE;

BEGIN
      -- get the party side ID from the business event generated.
      l_party_site_id := wf_engine.getitemattrtext(itemtype,itemkey,'PARTY_SITE_ID');
      -- check if this ID is for any PERSON. If not set the outcome status to FAIL otherwise process.
      OPEN cur_get_party_id(l_party_site_id);
      FETCH cur_get_party_id INTO cur_get_party_id_rec;
      IF (cur_get_party_id%FOUND) THEN
            -- ID is for a PERSON, so proceed further.
            CLOSE cur_get_party_id;

            -- check if its an OSS party.
            OPEN chk_oss_party(cur_get_party_id_rec.party_id);
            FETCH chk_oss_party INTO chk_oss_party_rec;
            IF (chk_oss_party%FOUND)
            THEN
            CLOSE chk_oss_party;

            -- OSS party, proceed further.
            OPEN get_location_dets(l_party_site_id);
            FETCH get_location_dets INTO get_location_dets_rec;
            IF (get_location_dets%FOUND) THEN

            -- set the workflow parameters.

           fnd_message.set_name('IGS','IGS_PE_ADDR_CHG_MES_SUBJ');
           l_message := fnd_message.get;

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'PERSON_NUMBER',
		       avalue    =>  get_location_dets_rec.party_number
      	   );

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NAME',
		       avalue    =>  get_location_dets_rec.party_name
      	   );

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_ADDRESS1',
		       avalue    =>  get_location_dets_rec.address1
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_ADDRESS2',
		       avalue    =>  get_location_dets_rec.address2
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_ADDRESS3',
		       avalue    =>  get_location_dets_rec.address3
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_ADDRESS4',
		       avalue    =>  get_location_dets_rec.address4
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_CITY',
		       avalue    =>  get_location_dets_rec.city
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_STATE',
		       avalue    =>  get_location_dets_rec.state
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_COUNTY',
		       avalue    =>  get_location_dets_rec.county
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_POSTAL_CODE',
		       avalue    =>  get_location_dets_rec.postal_code
      	   );

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_PROVINCE',
		       avalue    =>  get_location_dets_rec.province
      	   );

           OPEN get_country(get_location_dets_rec.country);
           FETCH get_country INTO l_country_desc;
           CLOSE get_country;

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_COUNTRY',
		       avalue    =>  l_country_desc
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_DEL_POINT',
		       avalue    =>  get_location_dets_rec.delivery_point_code
      	   );

	   OPEN get_effective_dates_cur(l_party_site_id);
	   FETCH get_effective_dates_cur INTO get_effective_dates_rec;
	   CLOSE get_effective_dates_cur;

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_FROM_DATE',
		       avalue    =>  get_effective_dates_rec.start_date
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_TO_DATE',
		       avalue    =>  get_effective_dates_rec.end_date
      	   );

           OPEN get_lkup_meaning(get_location_dets_rec.identifying_address_flag);
           FETCH get_lkup_meaning INTO l_lkup_meaning;
           CLOSE get_lkup_meaning;

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NEW_PRIMARY_ADDRESS',
		       avalue    =>  l_lkup_meaning
      	   );
           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'SUBJECT',
		       avalue    =>  l_message
      	   );
           IF (cur_get_party_id_rec.party_type='PERSON') THEN
                l_message:=null;
                fnd_message.set_name('IGS','IGS_PR_PERSON_ID');
                l_message := fnd_message.get;

           ELSE
                IF ((cur_get_party_id_rec.party_type='ORGANIZATION') AND (chk_oss_party_rec.inst_org_ind='I'))THEN
                  l_message:=null;
                  fnd_message.set_name('IGS','IGS_OR_INSTITUTION_CODE');
                  l_message := fnd_message.get;

                ELSE
                    IF ((cur_get_party_id_rec.party_type='ORGANIZATION') AND (chk_oss_party_rec.inst_org_ind='O')) THEN
                      l_message:=null;
                      fnd_message.set_name('IGS','IGS_RE_ORG_UNIT_CD');
                      l_message := fnd_message.get;

                    END IF;
                  END IF;
             END IF;

             Wf_Engine.SetItemAttrText(
             ItemType  =>  itemtype,
             ItemKey   =>  itemkey,
             aname     =>  'PARTY_TYPE',
             avalue    =>  l_message
             );

            resultout := 'SUCCESS';
            END IF;
            CLOSE get_location_dets;
      ELSE
          -- not an OSS party, set the status to FAIL.
           resultout := 'FAIL';
           CLOSE chk_oss_party;
      END IF;
      ELSE
           -- ID is not for a PERSON.
           resultout := 'FAIL';
           CLOSE cur_get_party_id;
      END IF;

END address_create;

PROCEDURE address_update(itemtype IN VARCHAR2,
                         itemkey IN VARCHAR2,
                         actid IN NUMBER,
                         funcmode IN VARCHAR2,
                         resultout OUT NOCOPY VARCHAR2)
/******************************************************************
 Created By         : Navin Sidana.
 Date Created By    : 9/9/2003
 Purpose            : Function to process location update event
                      raised from HZ.
 remarks            :
 Change History
 Who      When        What
 gmaheswa 17-Jan-1006 4938278: Modified complete logic as per R12 Business Events Mandate Build.
******************************************************************/
IS

CURSOR chk_oss_party(cp_party_site_id NUMBER) IS
SELECT hp.party_number, hp.party_name, hps.location_id,
       php.inst_org_ind, hps.identifying_address_flag, php.oss_org_unit_cd
FROM    hz_parties hp, hz_party_sites hps, igs_pe_hz_parties php
WHERE hp.party_id = hps.party_id
AND hp.party_id = php.party_id
AND hp.status = 'A'
AND hps.status = 'A'
AND hps.party_site_id = cp_party_site_id;

CURSOR get_location_dtls(cp_location_id NUMBER) IS
SELECT address1, address2, address3, address4, city, province, state ,
       county, postal_code, country, delivery_point_code
FROM hz_locations
WHERE location_id = cp_location_id;

CURSOR get_effective_dates (cp_party_site_id NUMBER) IS
SELECT start_date, end_date
FROM igs_pe_hz_pty_sites
WHERE party_site_id = cp_party_site_id;

CURSOR get_old_addr_dtls(cp_location_id NUMBER) IS
SELECT address1, address2, address3, address4, city,
       prov_state_admin_code, county, postal_code, country
FROM hz_location_profiles
WHERE location_id = cp_location_id
AND SYSDATE NOT BETWEEN effective_start_date AND NVL(effective_end_date,SYSDATE)
ORDER BY location_profile_id DESC;

CURSOR  get_country(cp_country VARCHAR2) IS
SELECT territory_short_name
FROM fnd_territories_vl
WHERE territory_code = cp_country;

rec_chk_oss_party chk_oss_party%ROWTYPE;
rec_location_dtls get_location_dtls%ROWTYPE;
rec_effective_dates get_effective_dates%ROWTYPE;
rec_old_addr_dtls get_old_addr_dtls%ROWTYPE;

l_party_site_id NUMBER;
l_country_desc VARCHAR2(360);
l_new_country_desc VARCHAR2(360);
l_message VARCHAR2(2000);
BEGIN

--get Party Site ID from the business event that was raised.

l_party_site_id := wf_engine.getitemattrtext(itemtype,itemkey,'PARTY_SITE_ID');

--Check whether the party site is of an OSS party. If not then set the result to FAIL and stop processing.
OPEN chk_oss_party(l_party_site_id);
FETCH chk_oss_party INTO rec_chk_oss_party;

IF (chk_oss_party%NOTFOUND) THEN
    CLOSE chk_oss_party;
    resultout :='FAIL';
    RETURN;
ELSE

    CLOSE chk_oss_party;
    --If the identifying_address_flag = 'Y' then it's a primary address. Set the parameter P_PRIM_ADDR_MSG with the message IGS_PE_PRIM_ADDR_MSG
    IF rec_chk_oss_party.identifying_address_flag = 'Y' THEN
        fnd_message.set_name('IGS','IGS_PE_PRIM_ADDR_MSG');
        l_message := fnd_message.get;

	    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'P_PRIM_ADDR_MSG',
                         avalue    =>  l_message
                         );
    END IF;

           Wf_Engine.SetItemAttrText(
		       ItemType  =>  itemtype,
		       ItemKey   =>  itemkey,
		       aname     =>  'NAME',
		       avalue    =>  rec_chk_oss_party.party_name
      	   );

    --Get the current details of the Address record from HZ_LOCATIONS table and set the respective workflow NEW_ parameters.
    OPEN get_location_dtls(rec_chk_oss_party.location_id);
    FETCH get_location_dtls INTO rec_location_dtls;
    CLOSE get_location_dtls;

    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_ADDRESS1',
                         avalue    =>  rec_location_dtls.ADDRESS1
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_ADDRESS2',
                         avalue    =>  rec_location_dtls.ADDRESS2
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_ADDRESS3',
                         avalue    =>  rec_location_dtls.ADDRESS3
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_ADDRESS4',
                         avalue    =>  rec_location_dtls.ADDRESS4
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_CITY',
                         avalue    =>  rec_location_dtls.CITY
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_STATE',
                         avalue    =>  rec_location_dtls.STATE
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_COUNTY',
                         avalue    =>  rec_location_dtls.COUNTY
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_POSTAL_CODE',
                         avalue    =>  rec_location_dtls.POSTAL_CODE
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_PROVINCE',
                         avalue    =>  rec_location_dtls.PROVINCE
                         );
    --For Country show the Description and set in the item attribute.
    OPEN get_country(rec_location_dtls.country);
    FETCH get_country INTO l_new_country_desc;
    CLOSE get_country;

    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_COUNTRY',
                         avalue    =>  l_new_country_desc
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_DEL_POINT',
                         avalue    =>  rec_location_dtls.DELIVERY_POINT_CODE
                         );

    --Get the start and end date of the Address from the IGS_PE_HZ_PTY_SITES table and set the M_NEW_ start and end date parameters.
    OPEN get_effective_dates(l_party_site_id);
    FETCH get_effective_dates INTO rec_effective_dates;
    CLOSE get_effective_dates;

    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_FROM_DATE',
                         avalue    =>  rec_effective_dates.start_date
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'NEW_TO_DATE',
                         avalue    =>  rec_effective_dates.end_date
                         );

    --Get the previous details of the Address record from the HZ_LOCATION_PROFILES table. And set the respective OLD_ workflow parameters.
    OPEN get_old_addr_dtls(rec_chk_oss_party.location_id);
    FETCH get_old_addr_dtls INTO rec_old_addr_dtls;
    CLOSE get_old_addr_dtls;

    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_ADDRESS1',
                         avalue    =>  rec_old_addr_dtls.ADDRESS1
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_ADDRESS2',
                         avalue    =>  rec_old_addr_dtls.ADDRESS2
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_ADDRESS3',
                         avalue    =>  rec_old_addr_dtls.ADDRESS3
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_ADDRESS4',
                         avalue    =>  rec_old_addr_dtls.ADDRESS4
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_CITY',
                         avalue    =>  rec_old_addr_dtls.CITY
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_STATE',
                         avalue    =>  rec_old_addr_dtls.PROV_STATE_ADMIN_CODE
                         );
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_COUNTY',
                         avalue    =>  rec_old_addr_dtls.COUNTY
                         );

    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'OLD_POSTAL_CODE',
                         avalue    =>  rec_old_addr_dtls.POSTAL_CODE
                         );
    -- Set the SUBJECT with message IGS_PE_ADDR_CHG_MES_SUBJ -Address Change Notification
    fnd_message.set_name('IGS','IGS_PE_ADDR_CHG_MES_SUBJ');
    l_message := fnd_message.get;
    Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'SUBJECT',
                         avalue    =>  l_message
                         );

    --For Country show the Description and set in the item attribute.
    OPEN get_country(rec_old_addr_dtls.country);
    FETCH get_country INTO l_country_desc;
    CLOSE get_country;

    Wf_Engine.SetItemAttrText(
			ItemType  =>  itemtype,
			ItemKey   =>  itemkey,
			aname     =>  'OLD_COUNTRY',
			avalue    =>   l_country_desc
			);

    --Set PARTY_TYPE and PERSON_NUMBER as per the INST_ORG_IND. INST_ORG_IND is null for PERSON. INST_ORG_IND is 'I' for INSTITUTION. INST_ORG_IND is 'O' for ORGANIZATION.
    IF rec_chk_oss_party.inst_org_ind IS NULL THEN

    fnd_message.set_name('IGS','IGS_PR_PERSON_ID');
    l_message := fnd_message.get;
	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PARTY_TYPE',
                         avalue    =>  l_message
                         );
	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PERSON_NUMBER',
                         avalue    =>  rec_chk_oss_party.PARTY_NUMBER
                         );
    ELSIF rec_chk_oss_party.inst_org_ind = 'I' THEN
    fnd_message.set_name('IGS','IGS_OR_INSTITUTION_CODE');
    l_message := fnd_message.get;

	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PARTY_TYPE',
                         avalue    =>  l_message
                         );
	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PERSON_NUMBER',
                         avalue    =>  rec_chk_oss_party.OSS_ORG_UNIT_CD
                         );
    ELSIF rec_chk_oss_party.inst_org_ind = 'O' THEN
    fnd_message.set_name('IGS','IGS_RE_ORG_UNIT_CD');
    l_message := fnd_message.get;

	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PARTY_TYPE',
                         avalue    =>  l_message
                         );
	  Wf_Engine.SetItemAttrText(
                         ItemType  =>  itemtype,
                         ItemKey   =>  itemkey,
                         aname     =>  'PERSON_NUMBER',
                         avalue    =>  rec_chk_oss_party.OSS_ORG_UNIT_CD
                         );
    END IF;

    resultout := 'SUCCESS';

END IF;

END address_update;


PROCEDURE primary_address_ind_update(itemtype IN VARCHAR2,
                                     itemkey IN VARCHAR2,
                                     actid IN NUMBER,
                                     funcmode IN VARCHAR2,
                                     resultout OUT NOCOPY VARCHAR2)
/******************************************************************
 Created By         : Navin Sidana.
 Date Created By    : 9/9/2003
 Purpose            : Function to process party site update event
                      raised from HZ.
 remarks            :
 Change History
 Who      When        What
 gmaheswa 17-Jan-06   4938278: Stubbed.
******************************************************************/
IS

BEGIN
NULL;
END primary_address_ind_update;

PROCEDURE change_housing_status(p_person_id IN NUMBER,
                                p_housing_status IN VARCHAR2,
                				P_CALENDER_TYPE  IN VARCHAR2,
                				P_CAL_SEQ_NUM    IN NUMBER,
            			        P_TEACHING_PERIOD_ID IN NUMBER,
                			    P_ACTION         IN VARCHAR2 ) IS
/******************************************************************
   Created By         : Uma Maheswari
   Date Created By    : 3-Nov-2004
   Purpose            : Procedure for raising an event when the
                        Housing status is changed.
   remarks            :
   Change History
   Who      When        What
  ******************************************************************/


    CURSOR c_seq_num IS
    SELECT IGS_PE_CHG_HOUSING_STAT_S.nextval
    FROM DUAL;
    ln_seq_val            NUMBER;
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
  BEGIN

   -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

   -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'PERSON_ID'     , p_value => p_person_id     , p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'HOUSING_STATUS'     , p_value => p_housing_status     , p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'CALENDER_TYPE'     , p_Value => P_CALENDER_TYPE     , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'CAL_SEQUENCE_NUMBER'     , p_Value => P_CAL_SEQ_NUM     , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'TEACHING_PERIOD_ID'     , p_Value => P_TEACHING_PERIOD_ID     , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'ACTION'        , p_Value => p_action        , p_ParameterList  => l_parameter_list_t);

   -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;
     -- raise event
     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pe.housing_status.change',
	  p_event_key  => 'HOUSING_STATUS'||ln_seq_val,
	  p_parameters => l_parameter_list_t
     );
  END change_housing_status;



  PROCEDURE process_addr_sync(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2
                                )
    ------------------------------------------------------------------------------------
          --Created by  : sarakshi ( Oracle IDC)
          --Date created: 20-Jan-2006
          --
          --Purpose:  Generate the body of the message .
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
   AS
     CURSOR cur_party_type (cp_lookup_type  igs_lookup_values.lookup_type%TYPE,
			    cp_lookup_code  igs_lookup_values.lookup_code%TYPE) IS
     SELECT meaning
     FROM   igs_lookup_values
     WHERE  lookup_type=cp_lookup_type
     AND    lookup_code=cp_lookup_code;
     l_party_type  igs_lookup_values.meaning%TYPE;

     CURSOR cur_message_text (cp_message_name  fnd_new_messages.message_name%TYPE) IS
     SELECT message_text
     FROM   fnd_new_messages
     WHERE  message_name=cp_message_name
     AND    application_id = 8405
     AND    LANGUAGE_CODE = USERENV('LANG');
     l_message_text   fnd_new_messages.message_text%TYPE;

     l_c_per_org  VARCHAR2(1);

   BEGIN

     IF (funcmode  = 'RUN') THEN

       l_c_per_org :=   wf_engine.GetItemAttrText (
 					           itemtype => itemtype,
						   itemkey => itemkey,
						   aname => 'P_BULK_PROC_CONTEXT');


       IF l_c_per_org IS NULL THEN
	 OPEN cur_party_type('IGS_PE_HOLDS','PERSON');
	 FETCH cur_party_type INTO l_party_type;
	 CLOSE cur_party_type;

	 OPEN cur_message_text('IGS_PR_PERSON_ID');
	 FETCH cur_message_text INTO l_message_text;
	 CLOSE cur_message_text;
       ELSE
	 OPEN cur_party_type('ORG_STRUCTURE_TYPE','INSTITUTE');
	 FETCH cur_party_type INTO l_party_type;
	 CLOSE cur_party_type;

	 OPEN cur_message_text('IGS_OR_INSTITUTION_CODE');
	 FETCH cur_message_text INTO l_message_text;
	 CLOSE cur_message_text;
       END IF;

       wf_engine.SetItemAttrText (itemtype => itemtype,
				 itemkey => itemkey,
				 aname => 'P_PARTY_TYPE_TITLE',
				 avalue => l_party_type);



       wf_engine.SetItemAttrText (itemtype => itemtype,
				 itemkey => itemkey,
				 aname => 'PARTY_TYPE',
				 avalue => l_message_text);

       wf_engine.SetItemAttrText(itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'P_ADDR_SYNC_MSG_TEXT',
                                 avalue          => 'PLSQLCLOB:igs_pe_wf_gen.write_addr_sync_message/'|| itemtype || ':' || itemkey);


     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

   END process_addr_sync;

  PROCEDURE write_addr_sync_message(document_id    IN VARCHAR2,
                                    display_type   IN VARCHAR2,
                                    document       IN OUT NOCOPY CLOB,
                                    document_type  IN OUT NOCOPY  VARCHAR2
                                     )
    ------------------------------------------------------------------------------------
          --Created by  : sarakshi ( Oracle IDC)
          --Date created: 20-Jan-2006
          --
          --Purpose:  Generate the body of the message .
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
   AS

    l_c_document      VARCHAR2(32000);
    l_c_itemtype      VARCHAR2(100);
    l_c_itemkey       WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE;

    CURSOR c_person(cp_person_id hz_parties.party_id%TYPE) IS
    SELECT '<tr><td>'||party_number||'<br></td><td>'|| person_last_name||', '||person_first_name|| '<br></td></tr>' person_record
    FROM hz_parties
    WHERE party_id = cp_person_id;
    l_person_record VARCHAR2(2000);

    CURSOR c_inst(cp_party_id igs_or_inst_org_base_v.party_id%TYPE) IS
    SELECT '<tr><td>'||party_number||'<br></td><td>'|| party_name|| '<br></td></tr>' person_record
    FROM  igs_or_inst_org_base_v
    WHERE party_id = cp_party_id
    AND   inst_org_ind='I';

    TYPE person_id IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    person_id_tbl person_id;
    l_n_cntr  NUMBER;

    i_event	 wf_event_t;
    l_clob_data  CLOB;
    l_c_per_org  VARCHAR2(1);

    PROCEDURE  populate_table (p_c_person_str VARCHAR2) IS
      l_c_length         NUMBER;
      l_c_start_position NUMBER;
      l_c_end_position   NUMBER;
      l_c_value          VARCHAR2(15);

    BEGIN
      --Create the pl-sql table, containing all the persons

      l_c_length := NVL(LENGTH(LTRIM(RTRIM(p_c_person_str))),0);
      l_c_start_position:=1;
      WHILE (l_c_length >= l_c_start_position) LOOP

	 l_c_end_position:=INSTR(p_c_person_str,',',l_c_start_position);

	 IF l_c_end_position =0 THEN
	   l_c_value:=SUBSTR(p_c_person_str,l_c_start_position,l_c_length - l_c_start_position + 1);
	 ELSE
	   l_c_value:=SUBSTR(p_c_person_str,l_c_start_position,l_c_end_position - l_c_start_position);
	   l_c_start_position:=l_c_end_position + 1;
	 END IF;

	 l_n_cntr := l_n_cntr+1;
	 person_id_tbl(l_n_cntr):= TO_NUMBER(l_c_value);
	 IF l_c_end_position = 0 THEN
	   EXIT;
	 END IF;
      END LOOP;

    END populate_table;

    PROCEDURE prepare_plsql_table(p_clob_object IN OUT NOCOPY CLOB) IS
      l_rawBuffer	 VARCHAR2(32767);
      l_amount	        BINARY_INTEGER;
      l_totalLen	INTEGER;
      l_offset	        INTEGER ;
      l_c_data          VARCHAR2(32767);

    BEGIN
      -- Get the data from the clob into a variable in the chunk of 32767 characters.
      -- Note same chunk size was used to create the clob.
      l_amount	:= 32767;
      l_offset	:= 1;

      l_totalLen := DBMS_LOB.GETLENGTH(p_clob_object);
      l_n_cntr :=0;
      WHILE l_totalLen >= l_amount LOOP
	   DBMS_LOB.READ(p_clob_object, l_amount, l_offset, l_rawBuffer);
           l_c_data := l_rawBuffer;
	   populate_table(RTRIM(l_c_data));
	   l_totalLen := l_totalLen - l_amount;
	   l_offset := l_offset + l_amount;
      END LOOP;

      IF l_totalLen > 0 THEN
	   DBMS_LOB.READ(p_clob_object, l_totalLen, l_offset, l_rawBuffer);
           l_c_data := l_rawBuffer;
	   populate_table(RTRIM(l_c_data));
      END IF;

    END prepare_plsql_table;

   BEGIN
     /* Get item type and item key */

     l_c_itemtype := SUBSTR(document_id, 1, instr(document_id, ':') - 1);
     l_c_itemkey := SUBSTR(document_id, instr(document_id, ':') + 1, length(document_id));


     -- get the handle of the event instance, and get the value of the event data.
     i_event  := Wf_Engine.GetItemAttrEvent(l_c_itemtype, l_c_itemkey, 'P_EVENT_DATA');
     l_clob_data := i_event.event_data;
     --Prepare the pl-sql table from the clob object
     prepare_plsql_table(l_clob_data);



     l_c_per_org :=   wf_engine.GetItemAttrText (
 					           itemtype => l_c_itemtype,
						   itemkey => l_c_itemkey,
						   aname => 'P_BULK_PROC_CONTEXT');

     -- write to the CLOB object from the above pl-sql table
     IF person_id_tbl.EXISTS(1) THEN

        l_n_cntr :=0;
        FOR i IN 1..person_id_tbl.last LOOP

           IF l_c_per_org IS NULL THEN
	     OPEN c_person(person_id_tbl(i));
	     FETCH c_person INTO l_person_record;
	     CLOSE c_person;
	   ELSE
	     OPEN c_inst(person_id_tbl(i));
	     FETCH c_inst INTO l_person_record;
	     CLOSE c_inst;
	   END IF;


	   l_c_document := l_c_document||l_person_record;
           l_n_cntr := l_n_cntr+1;
           IF l_n_cntr = 90 THEN
 	     /* Write the header doc into CLOB variable */
	     WF_NOTIFICATION.WriteToClob(document, l_c_document);
             l_c_document := NULL;
             l_n_cntr := 0;
           END IF;

	END LOOP;
	IF l_n_cntr <>0 THEN
	     WF_NOTIFICATION.WriteToClob(document, l_c_document);
	END IF;
     END IF;

     person_id_tbl.DELETE;

   END write_addr_sync_message;

   PROCEDURE addr_bulk_synchronization (p_persons_processes IN OUT NOCOPY t_addr_chg_persons) IS


      /* Cursor for Sequence */
      CURSOR c_seq IS
      SELECT IGS_PE_PE002_WF_S.NEXTVAL
      FROM DUAL;
      l_n_key                   NUMBER;

      l_wf_event_t              WF_EVENT_T;
      l_wf_parameter_list_t     WF_PARAMETER_LIST_T;
      l_eventdata               CLOB;
      l_str                     VARCHAR2(32767);

     CURSOR cur_inst_per (cp_party_id  igs_pe_hz_parties.party_id%TYPE) IS
     SELECT inst_org_ind
     FROM   igs_pe_hz_parties
     WHERE  party_id=cp_party_id;
     l_c_per_org  VARCHAR2(1);

    BEGIN

      IF p_persons_processes.EXISTS(1) THEN

	 WF_EVENT_T.Initialize(l_wf_event_t);
	 --
	 -- set the event name
	 --
	 l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.pe.addr_bulk_sync');
	 --
	 -- event key to identify uniquely
	 --
	 OPEN c_seq;
	 FETCH c_seq INTO l_n_key;
	 CLOSE c_seq;
	 --
	 --
	 -- set the parameter list
	 --
	 l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
	 --
         OPEN cur_inst_per(p_persons_processes(1));
         FETCH cur_inst_per INTO l_c_per_org;
         CLOSE cur_inst_per;

	 wf_event.AddParameterToList ( p_name => 'P_BULK_PROC_CONTEXT', p_value => l_c_per_org,p_parameterlist => l_wf_parameter_list_t);
	 -- Write the clob
         dbms_lob.createtemporary(l_eventdata, FALSE,DBMS_LOB.CALL);


	 FOR i IN 1..p_persons_processes.last LOOP

	    IF l_str IS NULL THEN
	      l_str:=TO_CHAR(p_persons_processes(i));
	    ELSE
	      l_str:=l_str||','||TO_CHAR(p_persons_processes(i));
	    END IF;

            IF LENGTH(l_str) >= (32767-15) THEN
              --Make a string of length 32767 , after the last person it is space.
              l_str:=RPAD(l_str,32767);
              dbms_lob.writeappend(l_eventdata, length(l_str),l_str);
	      l_str:=NULL;
	    END IF;
	 END LOOP;

         IF LENGTH(l_str)> 0 THEN
           --Make a string of length 32767 , after the last person it is space.
	   l_str:=RPAD(l_str,32767);
           dbms_lob.writeappend(l_eventdata, length(l_str),l_str);
	   l_str:=NULL;
         END IF;

	 --
	 -- raise the event
         wf_event.raise (
			 p_event_name => 'oracle.apps.igs.pe.addr_bulk_sync',
			 p_event_key  =>  'IGSPE002ADDRBULK'||l_n_key,
			 p_parameters => l_wf_parameter_list_t,
			 p_event_data => l_eventdata
		      );

      END IF;
      p_persons_processes.DELETE;

    END addr_bulk_synchronization;
PROCEDURE raise_acad_intent_event(P_ACAD_INTENT_ID IN NUMBER,
                                       P_PERSON_ID IN NUMBER,
                                       P_CAL_TYPE  IN VARCHAR2,
                                       P_CAL_SEQ_NUMBER  IN NUMBER,
                                       P_ACAD_INTENT_CODE IN VARCHAR2,
                                       P_OLD_ACAD_INTENT_CODE IN VARCHAR2 )
     IS
     /******************************************************************
      Created By         : Uma Maheswari
      Date Created By    : 3-Nov-2004
      Purpose            : Procedure for raising an event when the
                           Housing status is changed.
      remarks            :
      Change History
      Who      When        What
      vskumar	23-May-2006	bug 5211157 forward port the procedure from bug 2882588.
     ******************************************************************/

       l_event_t             wf_event_t;
       l_parameter_list_t    wf_parameter_list_t;
     BEGIN

      -- initialize the parameter list.
        wf_event_t.Initialize(l_event_t);

      -- set the parameters.
        wf_event.AddParameterToList ( p_name => 'P_PERSON_ID', p_value => p_person_id, p_parameterlist  => l_parameter_list_t);
        wf_event.AddParameterToList ( p_Name => 'P_CAL_TYPE', p_Value => P_CAL_TYPE, p_ParameterList  => l_parameter_list_t);
        wf_event.AddParameterToList ( p_Name => 'P_CAL_SEQ_NUMBER', p_Value => P_CAL_SEQ_NUMBER, p_ParameterList  => l_parameter_list_t);
        wf_event.AddParameterToList ( p_Name => 'P_ACAD_INTENT_CODE'     , p_Value => P_ACAD_INTENT_CODE, p_ParameterList  => l_parameter_list_t);
        wf_event.AddParameterToList ( p_Name => 'P_OLD_ACAD_INTENT_CODE', p_Value => P_OLD_ACAD_INTENT_CODE, p_ParameterList  => l_parameter_list_t);

        -- raise event
        WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pe.acad_intent.change',
             p_event_key  => 'ACAD_INTENT'||P_ACAD_INTENT_ID,
             p_parameters => l_parameter_list_t
        );

        l_parameter_list_t.DELETE;
     END raise_acad_intent_event;

     PROCEDURE process_acad_intent(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                                 funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2)
     IS
     /******************************************************************
      Created By         : Uma Maheswari
      Date Created By    : 3-Nov-2004
      Purpose            : Procedure for raising an event when the
                           Housing status is changed.
      remarks            :
      Change History
      Who      When        What
      vskumar	23-May-2006	bug 5211157 forward port the procedure from bug 2882588.
     ******************************************************************/
       CURSOR person_dtl_cur(cp_person_id NUMBER) IS
       SELECT person_number, full_name
       FROM igs_pe_person_base_v
       WHERE person_id = cp_person_id;

       CURSOR acad_intent_dtl_cur (cp_lookup_code VARCHAR2, cp_lookup_type VARCHAR2) IS
       SELECT meaning
       FROM igs_lookup_values
       WHERE lookup_type = cp_lookup_type
       AND lookup_code = cp_lookup_code;

       CURSOR term_desc_cur (cp_cal_type VARCHAR2, cp_sequence_number NUMBER) IS
       SELECT description
       FROM igs_ca_inst_all
       WHERE cal_type = cp_cal_type
       AND sequence_number = cp_sequence_number;

       l_person_id  NUMBER;

       l_acad_intent_code VARCHAR2(30);
       l_old_acad_intent_code VARCHAR2(30);
       l_acad_intent_desc VARCHAR2(80);
       l_old_acad_intent_desc VARCHAR2(80);

       l_term_desc igs_ca_inst_all.description%TYPE;
       l_cal_type igs_ca_inst_all.cal_type%TYPE;
       l_cal_seq_num igs_ca_inst_all.sequence_number%TYPE;

       person_dtl_rec person_dtl_cur%ROWTYPE;

     BEGIN

       l_person_id  := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');
       l_acad_intent_code := wf_engine.getitemattrtext(itemtype,itemkey,'P_ACAD_INTENT_CODE');
       l_old_acad_intent_code := wf_engine.getitemattrtext(itemtype,itemkey,'P_OLD_ACAD_INTENT_CODE');
       l_cal_type := wf_engine.getitemattrtext(itemtype,itemkey,'P_CAL_TYPE');
       l_cal_seq_num := wf_engine.getitemattrnumber(itemtype,itemkey,'P_CAL_SEQ_NUMBER');

       OPEN person_dtl_cur(l_person_id);
       FETCH person_dtl_cur INTO person_dtl_rec;
       CLOSE person_dtl_cur;

            Wf_Engine.SetItemAttrText(
            ItemType  =>  itemtype,
            ItemKey   =>  itemkey,
            aname     =>  'P_PERSON_NUMBER',
            avalue    =>  person_dtl_rec.person_number
            );

            Wf_Engine.SetItemAttrText(
            ItemType  =>  itemtype,
            ItemKey   =>  itemkey,
            aname     =>  'P_PERSON_NAME',
            avalue    =>  person_dtl_rec.full_name
            );

       OPEN acad_intent_dtl_cur(l_acad_intent_code,'PE_ACAD_INTENTS');
       FETCH acad_intent_dtl_cur INTO l_acad_intent_desc;
       CLOSE acad_intent_dtl_cur;

            Wf_Engine.SetItemAttrText(
            ItemType  =>  itemtype,
            ItemKey   =>  itemkey,
            aname     =>  'P_ACAD_INTENT_DESC',
            avalue    =>  l_acad_intent_desc
            );

       IF l_old_acad_intent_code IS NOT NULL THEN
         OPEN acad_intent_dtl_cur(l_old_acad_intent_code, 'PE_ACAD_INTENTS');
         FETCH acad_intent_dtl_cur INTO l_old_acad_intent_desc;
         CLOSE acad_intent_dtl_cur;

            Wf_Engine.SetItemAttrText(
            ItemType  =>  itemtype,
            ItemKey   =>  itemkey,
            aname     =>  'P_OLD_ACAD_INTENT_DESC',
            avalue    =>  l_old_acad_intent_desc
            );
       END IF;

       OPEN term_desc_cur(l_cal_type, l_cal_seq_num);
       FETCH term_desc_cur INTO l_term_desc;
       CLOSE term_desc_cur;

            Wf_Engine.SetItemAttrText(
            ItemType  =>  itemtype,
            ItemKey   =>  itemkey,
            aname     =>  'P_CAL_DESC',
            avalue    =>  l_term_desc
            );

     END process_acad_intent;
END igs_pe_wf_gen;

/
