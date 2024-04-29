--------------------------------------------------------
--  DDL for Package Body OTA_LP_NOTIFY_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_NOTIFY_SS" as
/* $Header: otlpsnot.pkb 120.5.12010000.3 2009/05/13 06:10:15 pekasi ship $ */

g_package  varchar2(33)	:= ' ota_lp_notify_ss.';  -- Global package name


-- --------------------------------------------------------------------
-- |--------------------< create_item_attrib_if_notexist >---------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure checks to see if an item attribute exists. If it does
--  not the one is created
--
procedure create_item_attrib_if_notexist
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_name      in     varchar2) is
--
    l_dummy  number(1);
  -- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;
  --
begin
  -- open the cursor to determine if the a
  open csr_wiav;
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    --
    -- item attribute does not exist so create it
      wf_engine.additemattr
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => p_name);
  end if;
  close csr_wiav;
  --
end create_item_attrib_if_notexist;
--

PROCEDURE create_wf_process( p_lp_notification_type in varchar2,
            p_lp_enrollment_id in number default null,
            p_lp_member_enrollment_id in number default null
        )
IS
    l_proc 	varchar2(72) := g_package||'create_wf_process';
    l_process             	wf_activities.name%type :='OTA_LRNG_PATH_NOTIFY_PRC';
    l_item_type    wf_items.item_type%type := 'OTWF';
    l_item_key     wf_items.item_key%type;


    l_user_name  varchar2(80);
    l_creator_person_name PER_ALL_PEOPLE_F.full_name%TYPE;

    l_creator_person_id   per_all_people_f.person_id%type;
    l_person_id   per_all_people_f.person_id%type;
    l_contact_id  number;
    l_contact_name HZ_PARTIES.party_name%TYPE;

    l_person_details		OTA_LEARNER_ENROLL_SS.csr_person_to_enroll_details%ROWTYPE;
    l_role_name wf_roles.name%type;
    l_role_display_name wf_roles.display_name%type;

    l_process_display_name varchar2(240);


Cursor get_display_name is
SELECT wrpv.display_name displayName
FROM   wf_runnable_processes_v wrpv
WHERE wrpv.item_type = l_item_type
AND wrpv.process_name = l_process;


CURSOR csr_get_user_name(p_person_id IN VARCHAR2) IS
  SELECT user_name
  FROM fnd_user
  WHERE employee_id=p_person_id;

    CURSOR csr_get_lp_details is
     SELECT lpt.name path_name,
            lpe.person_id person_id,
            lpe.contact_id contact_id,
            lpe.completion_target_date completion_target,
            lpe.completion_date,
            lps.notify_days_before_target,
            lpe.creator_person_id
     FROM ota_learning_paths lps,
          ota_learning_paths_tl lpt,
          ota_lp_enrollments lpe
     WHERE lpt.language = USERENV('LANG')
        AND lps.learning_path_id = lpt.learning_path_id
        AND lpe.lp_enrollment_id = p_lp_enrollment_id
        AND lpt.learning_path_id = lpe.learning_path_id;


     CURSOR csr_get_lpm_details IS
     SELECT avt.version_name course_name,
            lpe.person_id person_id,
            lpe.contact_id contact_id,
            lpme.completion_target_date completion_target,
            lpt.name path_name,
            lpe.creator_person_id,
            lpm.notify_days_before_target
     FROM ota_lp_member_enrollments lpme,
          ota_learning_path_members lpm,
          ota_activity_versions_tl avt,
          ota_lp_enrollments lpe,
          ota_learning_paths lps,
          ota_learning_paths_tl lpt
      WHERE lpme.lp_member_enrollment_id = p_lp_member_enrollment_id
         AND lps.learning_path_id = lpt.learning_path_id
         AND avt.language = USERENV('LANG')
         AND avt.activity_version_id = lpm.activity_version_id
         AND lpm.learning_path_member_id = lpme.learning_path_member_id
         AND lpe.lp_enrollment_id = lpme.lp_enrollment_id
         AND lpt.learning_path_id = lpm.learning_path_id
         AND lpt.language = USERENV('LANG');

     CURSOR csr_get_contact_name IS
     SELECT PARTY.party_name contact_name
     FROM HZ_CUST_ACCOUNT_ROLES acct_role,
          HZ_PARTIES party,
          HZ_RELATIONSHIPS rel,
          HZ_ORG_CONTACTS org_cont,
          HZ_CUST_ACCOUNTS role_acct
    WHERE acct_role.party_id = rel.party_id
     and acct_role.role_type = 'CONTACT'
     and org_cont.party_relationship_id = rel.relationship_id
     and rel.subject_id = party.party_id
     and rel.subject_table_name = 'HZ_PARTIES'
     and rel.object_table_name = 'HZ_PARTIES'
     and acct_role.cust_account_id = role_acct.cust_account_id
     and role_acct.party_id	= rel.object_id
     AND acct_role.cust_account_role_id = l_contact_id;


     CURSOR csr_get_person_name(p_person_id IN number) IS
     SELECT ppf.full_name
     FROM per_all_people_f ppf
     WHERE person_id = p_person_id;

    l_lp_details  csr_get_lp_details%ROWTYPE;
    l_lpm_details csr_get_lpm_details%ROWTYPE;
    l_section_name OTA_LP_SECTIONS_TL.NAME%TYPE;

    CURSOR csr_get_section_name IS
    SELECT lpst.name
    FROM ota_lp_sections_tl lpst,
         ota_lp_member_enrollments lpme,
         ota_learning_path_members lpm
    WHERE lpme.learning_path_member_id = lpm.learning_path_member_id
        AND lpst.learning_path_section_id = lpm.learning_path_section_id
        AND lpst.language = USERENV('LANG')
        AND lpme.lp_member_enrollment_id = p_lp_member_enrollment_id;

    CURSOR csr_get_person_user_name(p_person_id IN NUMBER) IS
    SELECT user_name
    FROM fnd_user
    WHERE employee_id=p_person_id;

    CURSOR csr_get_contact_user_name(p_contact_id IN NUMBER) IS
    SELECT usr.user_name
    FROM
        hz_parties party,
        fnd_user usr,
        hz_cust_account_roles rol
    WHERE
      rol.party_id = party.party_id
    AND rol.party_id = usr.customer_id
    AND rol.cust_account_role_id = p_contact_id;


BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);


OPEN get_display_name;
FETCH get_display_name INTO l_process_display_name;
CLOSE get_display_name;



IF p_lp_notification_type ='LP_COMPLETE'
   OR p_lp_notification_type = 'LRN_LP_REMINDER'
      OR p_lp_notification_type = 'MGR_LP_REMINDER'  THEN

    OPEN csr_get_lp_details;
    FETCH csr_get_lp_details INTO l_lp_details;
    CLOSE csr_get_lp_details;

  IF p_lp_notification_type ='LP_COMPLETE' THEN
     -- Get the next item key from the sequence
      select hr_workflow_item_key_s.nextval
      into   l_item_key
      from   sys.dual;
   ELSE
    l_item_key := 'LP^' ||p_lp_enrollment_id || '^' || l_lp_details.notify_days_before_target||'^' ||to_char(sysdate,'DDMMRRRR');
   END IF;

    WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);
    --Enh 5606090: Language support for LrngPath.
    WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'LP_NAME', p_lp_enrollment_id);
    WF_ENGINE.setitemattrdate(l_item_type, l_item_key, 'TARGET_DATE', l_lp_details.completion_target);
    WF_ENGINE.setitemattrdate(l_item_type, l_item_key, 'COMPLETION_DATE', l_lp_details.completion_date);
    WF_ENGINE.setitemattrnumber(l_item_type, l_item_key, 'NOTIFY_DAYS_BEFORE_TARGET', l_lp_details.notify_days_before_target);

    create_item_attrib_if_notexist(p_item_type => l_item_type
                                   ,p_item_key => l_item_key
                                   ,p_name     => 'LP_ENROLLMENT_ID');
    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'LP_ENROLLMENT_ID',p_lp_enrollment_id);
    l_person_id := l_lp_details.person_id;
    l_contact_id := l_lp_details.contact_id;

    IF l_lp_details.creator_person_id <> l_person_id THEN
         OPEN csr_get_person_name(l_lp_details.creator_person_id);
         FETCH csr_get_person_name INTO l_creator_person_name;
         CLOSE csr_get_person_name;
         fnd_file.put_line(FND_FILE.LOG,'creator_person_id ' || l_creator_person_name);
         WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'LP_CREATOR_NAME',l_creator_person_name);
    END IF;

ELSIF p_lp_notification_type IS NOT NULL THEN
    OPEN csr_get_lpm_details;
    FETCH csr_get_lpm_details INTO l_lpm_details;
    CLOSE csr_get_lpm_details;

    l_item_key := 'LPM^' ||p_lp_member_enrollment_id || '^' || l_lpm_details.notify_days_before_target||'^' ||to_char(sysdate,'DDMMRRRR');

    WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);


    WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'COURSE_NAME', l_lpm_details.course_name);
    --Enh 5606090: Language support for LrngPath.
    WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'LP_NAME', p_lp_member_enrollment_id);
    WF_ENGINE.setitemattrdate(l_item_type, l_item_key, 'TARGET_DATE', l_lpm_details.completion_target);
    create_item_attrib_if_notexist(p_item_type => l_item_type
                                   ,p_item_key => l_item_key
                                   ,p_name     => 'LPM_ENROLLMENT_ID');
    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'LPM_ENROLLMENT_ID',p_lp_member_enrollment_id);
    WF_ENGINE.setitemattrnumber(l_item_type, l_item_key, 'NOTIFY_DAYS_BEFORE_TARGET', l_lpm_details.notify_days_before_target);
    l_person_id := l_lpm_details.person_id;
    l_contact_id := l_lpm_details.contact_id;


    IF l_lpm_details.creator_person_id <> l_person_id THEN
         OPEN csr_get_person_name(l_lpm_details.creator_person_id);
         FETCH csr_get_person_name INTO l_creator_person_name;
         CLOSE csr_get_person_name;
         fnd_file.put_line(FND_FILE.LOG,'creator_person_id ' || l_creator_person_name);
         WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'LP_CREATOR_NAME',l_creator_person_name);
    END IF;

    IF p_lp_notification_type = 'LNR_CTG_LPM_REMINDER' OR p_lp_notification_type = 'MGR_CTG_LPM_REMINDER' THEN
        OPEN csr_get_section_name;
        FETCH csr_get_section_name INTO l_section_name;
        CLOSE csr_get_section_name;
        WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'SECTION_NAME',l_section_name);
    END IF;

END IF;

create_item_attrib_if_notexist(p_item_type => l_item_type
                               ,p_item_key => l_item_key
                               ,p_name     => 'LP_NOTIFICATION_TYPE');
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'LP_NOTIFICATION_TYPE', p_lp_notification_type);


IF l_person_id IS NOT NULL THEN
    l_person_details := ota_learner_enroll_ss.Get_Person_To_Enroll_Details(p_person_id => l_person_id);

  --Modified for bug#4644019
  /*SELECT user_name INTO l_user_name
    FROM fnd_user
    WHERE employee_id=l_person_id
    AND ROWNUM =1 ;  */

    OPEN csr_get_person_user_name(l_person_id);
    FETCH csr_get_person_user_name INTO l_user_name;
    IF csr_get_person_user_name%NOTFOUND THEN
        CLOSE csr_get_person_user_name;
        RETURN;
    ELSE
       CLOSE csr_get_person_user_name;
    END IF;


    IF l_person_details.full_name IS NOT NULL then
       WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'EVENT_OWNER',l_user_name);
       WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'LP_ENROLLEE',l_person_details.full_name);
    END IF;
ELSIF l_contact_id IS NOT NULL THEN
    OPEN csr_get_contact_name;
    FETCH csr_get_contact_name INTO l_contact_name;
    CLOSE csr_get_contact_name;

  --Modified for bug#4644019
    /*SELECT usr.user_name INTO l_user_name
    FROM
        hz_parties party,
        fnd_user usr,
        hz_cust_account_roles rol
    WHERE
        rol.party_id = party.party_id
    AND rol.party_id = usr.customer_id
    AND rol.cust_account_role_id = l_contact_id;*/

    OPEN csr_get_contact_user_name(l_contact_id);
    FETCH csr_get_contact_user_name INTO l_user_name;
    IF csr_get_contact_user_name%NOTFOUND THEN
      CLOSE csr_get_contact_user_name;
      RETURN;
    ELSE
      CLOSE csr_get_contact_user_name;
    END IF;

    WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'LP_ENROLLEE',l_contact_name);
    WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'EVENT_OWNER',l_user_name);
END IF;



-- Get and set owner role

hr_utility.set_location('Before Getting Owner'||l_proc, 10);

WF_DIRECTORY.GetRoleName(p_orig_system =>'PER',
                      p_orig_system_id => l_creator_person_id,
                      p_name  =>l_role_name,
                      p_display_name  =>l_role_display_name);


WF_ENGINE.SetItemOwner(itemtype => l_item_type,
                       itemkey =>l_item_key,
                       owner =>l_role_name);

hr_utility.set_location('After Setting Owner'||l_proc, 10);


WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

hr_utility.set_location('leaving:'||l_proc, 20);

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end create_wf_process;

PROCEDURE get_notification_type
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
  		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
	    ,resultout	OUT nocopy VARCHAR2 ) AS

     l_notification_type varchar2(30);
BEGIN
  IF (funcmode='RUN') THEN
    l_notification_type := WF_ENGINE.getitemattrtext(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname     =>'LP_NOTIFICATION_TYPE',
                                      ignore_notfound => true);
    resultout := 'COMPLETE:'||l_notification_type;
  ELSE IF (funcmode='CANCEL')  THEN
    resultout := 'COMPLETE';
  END IF;
 END IF;
END get_notification_type;

PROCEDURE is_Manager_enrolled_path
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
   		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
	    ,resultout	OUT nocopy VARCHAR2 ) AS

  l_lp_enrollment_id OTA_LP_ENROLLMENTS.lp_enrollment_id%TYPE;
  l_manager_user_name fnd_user.user_name%TYPE;

  CURSOR csr_get_manager_name IS
     SELECT ppf.full_name, ppf.person_id
     FROM ota_lp_enrollments lpe,
          ota_learning_paths lps,
          per_all_people_f ppf,
          per_all_assignments_f paf
     WHERE trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
         AND trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
         AND paf.person_id = lpe.person_id
         AND paf.supervisor_id = ppf.person_id
         AND paf.primary_flag = 'Y'
         AND lps.learning_path_id = lpe.learning_path_id
         AND lpe.person_id <> lpe.creator_person_id
         AND lpe.lp_enrollment_id = l_lp_enrollment_id;

     l_manager_details csr_get_manager_name%ROWTYPE;

  CURSOR csr_get_user_name(l_person_id IN VARCHAR2) IS
  SELECT user_name
  FROM fnd_user
  WHERE employee_id=l_person_id
  and trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));          --Bug 5676892

BEGIN
  --
  IF (funcmode = 'RUN') THEN
      l_lp_enrollment_id := wf_engine.getItemAttrNumber
                        	(itemtype  => itemtype
                        	,itemkey   => itemkey
                        	,aname	   => 'LP_ENROLLMENT_ID');

    OPEN csr_get_manager_name;
      FETCH csr_get_manager_name INTO l_manager_details;
      IF csr_get_manager_name%FOUND THEN
        WF_ENGINE.setitemattrtext(itemtype,itemkey,'SUPERVISOR_USERNAME',l_manager_details.full_name);
        create_item_attrib_if_notexist(p_item_type => itemtype
                               ,p_item_key => itemkey
                               ,p_name     => 'MANAGER_ID');
        WF_ENGINE.setitemattrNumber(itemtype,itemkey,'MANAGER_ID',l_manager_details.person_id);
        CLOSE csr_get_manager_name;
        OPEN csr_get_user_name(l_manager_details.person_id);
        FETCH csr_get_user_name INTO l_manager_user_name;
        IF csr_get_user_name%FOUND THEN
            WF_ENGINE.setitemattrText(itemtype,itemkey,'EVENT_OWNER',l_manager_user_name);
        END IF;
        CLOSE csr_get_user_name;
        resultout := 'COMPLETE:T';
      ELSE
        CLOSE csr_get_manager_name;
         resultout := 'COMPLETE:F';
      END IF;
   ELSE IF (funcmode = 'CANCEL')  THEN
       resultout := 'COMPLETE';
  END IF;
 END IF;
  --
END is_Manager_enrolled_path;

PROCEDURE is_Manager_same_as_creator
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
   		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
	    ,resultout	OUT nocopy VARCHAR2 ) AS
  l_lp_enrollment_id OTA_LP_ENROLLMENTS.lp_enrollment_id%TYPE;
  l_manager_id OTA_LP_ENROLLMENTS.creator_person_id%TYPE;
  l_manager_user_name fnd_user.user_name%TYPE;

 CURSOR csr_get_creator_name IS
     SELECT ppf.full_name, ppf.person_id
     FROM ota_lp_enrollments lpe,
          ota_learning_paths lps,
          per_all_people_f ppf
     WHERE trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
         AND ppf.person_id = lpe.creator_person_id
         AND lpe.lp_enrollment_id = l_lp_enrollment_id
         AND lpe.learning_path_id = lps.learning_path_id;

  l_creator_details csr_get_creator_name%ROWTYPE;

  CURSOR csr_get_user_name(l_person_id IN VARCHAR2) IS
  SELECT user_name
  FROM fnd_user
  WHERE employee_id=l_person_id
  and trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));   --Bug 5676892

BEGIN
  --
  IF (funcmode = 'RUN') THEN
    l_manager_id := wf_engine.getItemAttrNumber
                    	(itemtype  => itemtype
                    	,itemkey   => itemkey
                    	,aname	   => 'MANAGER_ID');

    l_lp_enrollment_id := wf_engine.getItemAttrNumber
                    	(itemtype  => itemtype
                    	,itemkey   => itemkey
                    	,aname	   => 'LP_ENROLLMENT_ID');
      OPEN csr_get_creator_name;
      FETCH csr_get_creator_name INTO l_creator_details;
      IF l_creator_details.person_id = l_manager_id THEN
          CLOSE csr_get_creator_name;
          resultout := 'COMPLETE:T';
      ELSE
        WF_ENGINE.setitemattrtext(itemtype,itemkey,'LP_CREATOR_NAME',l_creator_details.full_name);
        create_item_attrib_if_notexist(p_item_type => itemtype
                                 ,p_item_key => itemkey
                                ,p_name     => 'CREATOR_ID');
        WF_ENGINE.setitemattrNumber(itemtype,itemkey,'CREATOR_ID',l_creator_details.person_id);
        CLOSE csr_get_creator_name;
        OPEN csr_get_user_name(l_creator_details.person_id);
        FETCH csr_get_user_name INTO l_manager_user_name;
        IF csr_get_user_name%FOUND THEN
            WF_ENGINE.setitemattrText(itemtype,itemkey,'EVENT_OWNER',l_manager_user_name);
        END IF;
        CLOSE csr_get_user_name;
        resultout := 'COMPLETE:F';
      END IF;
    ELSE IF (funcmode = 'CANCEL')  THEN
       resultout := 'COMPLETE';
    END IF;
  END IF;
  --

END is_Manager_same_as_creator;


FUNCTION is_notification_sent(p_itemkey in varchar2)
RETURN BOOLEAN
IS
  CURSOR csr_notification_sent IS
  SELECT 1
  FROM wf_items
  WHERE item_type = 'OTWF'
  AND item_key = p_itemkey;

   l_sent number;
BEGIN
  OPEN csr_notification_sent;
  FETCH csr_notification_sent INTO l_sent;
  IF csr_notification_sent%NOTFOUND THEN
    RETURN false;
  ELSE
    RETURN true;
  END IF;
END is_notification_sent;
PROCEDURE send_lp_ct_notifications
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2) as

  CURSOR csr_get_learning_paths IS
    SELECT lpe.lp_enrollment_id
           ,lpe.person_id
           ,lpe.contact_id
           ,lpe.creator_person_id
           ,lps.notify_days_before_target
    FROM ota_learning_paths lps,
     ota_lp_enrollments lpe
    WHERE lps.learning_path_id = lpe.learning_path_id
   AND lpe.path_status_code = 'ACTIVE'
   AND trunc(sysdate) + lps.notify_days_before_target = trunc(lpe.completion_target_date)
   AND lps.business_group_id = ota_general.get_business_group_id;

   l_lp_enrollment_id number;
   failure		exception;
   l_proc 		varchar2(72) := g_package||' send_lp_ct_notifications';
   l_lp_notification_type VARCHAR2(30);
   l_key VARCHAR2(50);
BEGIN

   FOR lp_rec IN csr_get_learning_paths
   LOOP
    l_lp_enrollment_id := lp_rec.lp_enrollment_id;
    l_key := 'LP^' ||l_lp_enrollment_id || '^' || lp_rec.notify_days_before_target||'^' ||to_char(sysdate,'DDMMRRRR');
    IF NOT is_notification_sent( p_itemkey => l_key) THEN
        IF lp_rec.person_id <> lp_rec.creator_person_id THEN
            l_lp_notification_type := 'MGR_LP_REMINDER';
        ELSE
            l_lp_notification_type := 'LRN_LP_REMINDER';
        END IF;

         create_wf_process(
          p_lp_notification_type     => l_lp_notification_type
          ,p_lp_enrollment_id        => l_lp_enrollment_id);
     END IF;
    END LOOP;

   EXCEPTION
	  when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
END send_lp_ct_notifications;


PROCEDURE send_lpm_ct_notifications
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2) as
  CURSOR csr_get_lp_comps IS

  SELECT lpme.lp_member_enrollment_id
         ,lpe.person_id
         ,lpe.creator_person_id
         ,lps.path_source_code
         ,lpm.notify_days_before_target
  FROM ota_learning_path_members lpm,
     ota_lp_member_enrollments lpme,
     ota_learning_paths lps,
     ota_lp_enrollments lpe,
     ota_lp_sections lpc
  WHERE lpe.learning_path_id = lps.learning_path_id
   AND lpc.learning_path_id = lps.learning_path_id
   AND lpc.learning_path_section_id = lpm.learning_path_section_id
   AND lpme.learning_path_member_id = lpm.learning_path_member_id
   AND lpme.lp_enrollment_id = lpe.lp_enrollment_id
   AND lpe.path_status_code NOT IN ('CANCELLED', 'COMPLETED')
   AND lpme.member_status_code NOT IN ('CANCELLED','COMPLETED')
   AND trunc(sysdate) + lpm.notify_days_before_target = trunc(lpme.completion_target_date)
   AND (lpc.completion_type_code = 'M'
          OR (lpc.completion_type_code = 'S'
                AND lpc.no_of_mandatory_courses < (SELECT count(lp_member_enrollment_id)
                                                  FROM ota_lp_member_enrollments
                                                  WHERE learning_path_section_id = lpc.learning_path_section_id
                                                    AND lp_enrollment_id = lpe.lp_enrollment_id
                                                    AND member_status_code = 'COMPLETED')))

   AND lps.business_group_id = ota_general.get_business_group_id;

   l_lpm_enrollment_id number;
   failure		exception;
   l_proc 		varchar2(72) := g_package|| ' send_lpm_ct_notifications';
   l_lpm_notification_type VARCHAR2(30);
   l_person_id    OTA_LEARNING_PATHS.PERSON_ID%TYPE;
   l_contact_id   OTA_LEARNING_PATHS.CONTACT_ID%TYPE;
   l_creator_person_id  OTA_LP_ENROLLMENTS.CREATOR_PERSON_ID%TYPE;
   l_path_source_code    OTA_LEARNING_PATHS.PATH_SOURCE_CODE%TYPE;
   l_key varchar2(80);
BEGIN

   FOR lpm_rec IN csr_get_lp_comps
   LOOP
   l_lpm_enrollment_id := lpm_rec.lp_member_enrollment_id;
   l_key := 'LPM^' ||l_lpm_enrollment_id || '^' ||lpm_rec.notify_days_before_target||'^' || to_char(sysdate,'DDMMRRRR');
     IF NOT is_notification_sent( p_itemkey => l_key) THEN
         l_person_id := lpm_rec.person_id;
         l_path_source_code := lpm_rec.path_source_code;
         l_creator_person_id := lpm_rec.creator_person_id;

         IF l_path_source_code = 'CATALOG' THEN
            IF l_person_id <> l_creator_person_id THEN
                l_lpm_notification_type := 'MGR_CTG_LPM_REMINDER';
            ELSE
                l_lpm_notification_type := 'LRN_CTG_LPM_REMINDER';
            END IF;
         ELSIF l_path_source_code = 'EMPLOYEE' THEN
            l_lpm_notification_type := 'LRN_LPM_REMINDER';
         ELSIF l_path_source_code = 'MANAGER' OR l_path_source_code = 'TALENT_MGMT' THEN
            l_lpm_notification_type := 'MGR_LPM_REMINDER';
         END IF;
         create_wf_process(
           p_lp_notification_type     => l_lpm_notification_type
          ,p_lp_member_enrollment_id => l_lpm_enrollment_id);
      END IF;
   END LOOP;

   EXCEPTION
	  when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
END send_lpm_ct_notifications;



end ota_lp_notify_ss;

/
