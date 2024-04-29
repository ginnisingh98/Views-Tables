--------------------------------------------------------
--  DDL for Package Body OTA_COMPETENCE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_COMPETENCE_SS" as
/* $Header: otcmpupd.pkb 120.3.12010000.8 2010/04/15 08:36:48 pekasi ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= '  ota_Competence_ss';  -- Global package name




procedure get_review_data_from_tt
   (p_transaction_step_id             in  number
   ,p_review_data                     out nocopy Long
   ,p_from out nocopy varchar2
)
is

 l_competence_id varchar2(4000);
 l_level_id varchar2(4000);
 l_level_override varchar2(4000);
 l_date_from varchar2(4000);
 l_date_to varchar2(4000);
 l_source varchar2(4000);
 l_certification_date varchar2(4000);
  l_certification_method varchar2(4000);
   l_certification_next varchar2(4000);
   l_comments varchar2(4000);

 l_from varchar2(100);

begin


  l_competence_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COMPETENCE');


  l_level_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LEVEL');

  l_level_override := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LEVELOVERRIDE');


  l_date_from := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATEFROM');

 l_date_to := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATETO');


  l_source := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SOURCE');

  l_certification_date := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CERTDATE');


  l_certification_method := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CERTMETHOD');

  l_certification_next := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CERTNEXT');

 -- l_certification_next := to_char(to_date(l_certification_next),fnd_profile.value('ICX_DATE_FORMAT_MASK'));

  l_comments := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COMMENTS');

    l_from := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FROM');

    p_from := l_from;

--
-- Now string all the retreived items into p_review_data

if l_from is not null then

p_review_data := nvl(l_competence_id,0)
                 ||'#'||nvl(l_level_id,'null')
                 ||'#'||nvl(l_level_override,'null')
                 ||'#'||nvl(l_date_from,'null')
                 ||'#'||nvl(l_date_to,'null')
                 ||'#'||nvl(l_source,'null')
                 ||'#'||nvl(l_certification_date,'null')
                 ||'#'||nvl(l_certification_method,'null')
                 ||'#'||nvl(l_certification_next,'null')
                 ||'#'||nvl(l_comments,'null');

else
p_review_data := nvl(l_competence_id,0)||'#'||nvl(l_level_id,'null')
                    ||'#'||nvl(l_date_from,'null');
end if;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data_from_tt;


--  ---------------------------------------------------------------------------
--  |----------------------< get_review_data_from_tt >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_review_data
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_review_data                     out nocopy long
   ,p_from                            out nocopy varchar2
) is


  /* l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   ln_index                           number  default 0;
   l_trans_step_rows                  NUMBER  ; */
   l_review_data                      long(32000);
   l_from varchar2(100);
   l_trans_step_id number;


 BEGIN

 /*        hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);
*/
--added new
l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');
    get_review_data_from_tt(
                 p_transaction_step_id            => l_trans_step_id
                ,p_review_data                    => l_review_data
                ,p_from                           => l_from  );
/*
              get_review_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
                ,p_review_data                    => l_review_data);
*/

              p_review_data := l_review_data;
p_from := l_from;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data;




--  ---------------------------------------------------------------------------
--  |----------------------< get_Comptence_eff_date >--------------------------|
--  ---------------------------------------------------------------------------
--
Function get_Competence_eff_date(
            p_comp_id in per_competence_elements.competence_id%type,
            p_id 		in ota_events.event_id%type,
            p_obj_type in varchar2
           ) return date
 is


l_proc 	varchar2(72) := g_package||'get_Competence_eff_date';

l_eff_date date;

Cursor course_eff_date is
select oev.course_end_date
from ota_events oev,
ota_offerings off, ota_category_usages ocu
where oev.event_id=p_id
and (oev.parent_offering_id = off.offering_id or oev.offering_id = off.offering_id)
and off.delivery_mode_id = ocu.category_usage_id
and ocu.synchronous_flag = 'Y';
/*select pce.effective_date_from
	from per_competence_elements pce , ota_offerings off,ota_events oev
	where oev.parent_offering_id=off.offering_id
	and off.activity_version_id=pce.activity_version_id
	and oev.event_id= p_id
	and pce.competence_id =p_comp_id
	and type='DELIVERY'; */



/*Cursor lp_eff_date is
select pce.effective_date_from
	from per_competence_elements pce
	where pce.object_id= p_id
	and pce.competence_id =p_comp_id
	and type='OTA_LEARNING_PATH';*/

  begin

hr_utility.set_location('Entering:'||l_proc, 5);
if p_obj_type='COURSE' then
	OPEN course_eff_date;
    FETCH course_eff_date INTO l_eff_date;
    if course_eff_date%notfound then
        select trunc(sysdate) into l_eff_date from dual;
    end if;
    CLOSE course_eff_date;
 else
   select trunc(sysdate) into l_eff_date from dual;
 end if;
hr_utility.set_location('Leaving:'||l_proc, 5);
	return l_eff_date;

Exception

	when others then

	raise;



 end get_Competence_eff_date;



--  ---------------------------------------------------------------------------
--  |----------------------< save_Comptence_info >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure save_Comptence_info(
            p_person_id 	in number ,
            p_item_type 		in wf_items.item_type%type,
            p_item_key       in wf_items.item_key%type,
            p_Competence_id  in varchar2,
            p_level_id      in varchar2,
            p_level_override in varchar2,
            p_date_from     in varchar2,
            p_date_to       in varchar2,
            p_source        in varchar2,
            p_certification_date in varchar2,
            p_certification_method in varchar2,
            p_certification_next in varchar2,
            p_comments in varchar2,
            p_from in varchar2)

is

l_proc 	varchar2(72) := g_package||'save_Comptence_info';
  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table 	       hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_message_number             VARCHAR2(10);
  l_result                     varchar2(100) default null;
  l_old_transaction_step_id    number;
  l_old_object_version_number  number;
  l_activity_id number :=0;
  l_business_group_id per_all_people_f.business_group_id%type;

  cursor get_person_business_grp  is  ----Bug#6869342
  select business_group_id from per_all_people_f
  where person_id= p_person_id
  and trunc(sysdate) between trunc(effective_start_date) and trunc(nvl(effective_end_date,sysdate+1));

begin

        -- First, check if transaction id exists or not
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => l_activity_id --not used
           ,funmode    => 'RUN'
           ,p_login_person_id => p_person_id
           ,p_function_id => 0--not available in api
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);

  END IF;

  hr_utility.set_location('Before chk transaction step'||l_proc, 5);

  if (hr_transaction_api.transaction_step_exist  (p_item_type => p_item_type
			     			 ,p_item_key => p_item_key
			     			 ,p_activity_id => l_activity_id) and p_from is null )  then

      hr_transaction_api.get_transaction_step_info(p_item_type             => p_item_type
						  ,p_item_key              => p_item_key
 						  ,p_activity_id           => l_activity_id
 						  ,p_transaction_step_id   => l_old_transaction_step_id
 						  ,p_object_version_number => l_old_object_version_number);




--  if l_old_transaction_step_id is not null   then
      hr_transaction_api.delete_transaction_step(p_validate                    => false
        					,p_transaction_step_id         => l_old_transaction_step_id
        					,p_person_id                   => p_person_id
       						,p_object_version_number       => l_old_object_version_number);

  end if;

  --
  -- Create a transaction step
  --
hr_utility.set_location('Me Entering Create transaction step'||l_proc, 5);

if p_from ='SS' then
l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');

  l_business_group_id := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => l_transaction_step_id
              ,p_name                => 'P_BUSINESS_GROUP_ID');

else

  hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || '.PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => l_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);

     OPEN get_person_business_grp; ----Bug#6869342
     FETCH get_person_business_grp INTO l_business_group_id;
     CLOSE get_person_business_grp;
     --l_business_group_id := ota_general.get_business_group_id;


end if;
  --
  hr_utility.set_location('out of Create transaction step'||l_proc, 5);
  HR_UTILITY.TRACE ('tranasction step id: ' || to_char (l_transaction_step_id));
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_COMPETENCE';
  l_transaction_table(l_count).param_value := p_competence_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LEVEL';
  l_transaction_table(l_count).param_value := p_level_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LEVELOVERRIDE';
  l_transaction_table(l_count).param_value := p_level_override;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATEFROM';
  l_transaction_table(l_count).param_value := p_date_from;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATETO';
  l_transaction_table(l_count).param_value := p_date_to;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SOURCE';
  l_transaction_table(l_count).param_value := p_source;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CERTDATE';
  l_transaction_table(l_count).param_value := p_certification_date;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CERTMETHOD';
  l_transaction_table(l_count).param_value := p_certification_method;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CERTNEXT';
  l_transaction_table(l_count).param_value := p_certification_next;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMMENTS';
  l_transaction_table(l_count).param_value := p_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROM';
  l_transaction_table(l_count).param_value := p_from;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := l_business_group_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';




   hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => p_item_type
      ,p_item_key   => p_item_key
      ,p_name   => 'OTA_TRANSACTION_STEP_ID');

  WF_ENGINE.setitemattrnumber(p_item_type,
                              p_item_key,
                              'OTA_TRANSACTION_STEP_ID',
                              l_transaction_step_id);

hr_utility.set_location('Before save transaction step'||l_proc, 5);
  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => l_activity_id
                ,p_login_person_id => p_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_function_id => 0 ---not used
                ,p_transaction_data => l_transaction_table);

hr_utility.set_location('After save transaction step'||l_proc, 50);

if p_from ='SS' then
hr_transaction_api.update_transaction
            (p_transaction_id             => l_transaction_id
          --  ,p_status                     => lv_status
            ,p_transaction_state          => null
           -- ,p_transaction_effective_date => ld_trans_effec_date
            );
end if;

 EXCEPTION
 /* WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
   --populate the p_error_message out variable
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'Page',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_UPDATE_NOT_ALLOWED');
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF; */
  WHEN OTHERS THEN
   /* p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
*/
raise;

end save_Comptence_info;


--  ---------------------------------------------------------------------------
--  |----------------------< Update_competence >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE Update_competence  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )
is

      l_transaction_step_id 	number(15);

        l_error_text    varchar2(2000);
        l_result    varchar2(25);

begin
hr_utility.set_location('ENTERING Update Competence', 10);

hr_multi_message.disable_message_list;

    IF (funcmode='RUN') THEN
    savepoint commit_transaction;

        l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');



        process_api(false,l_transaction_step_id);
        l_result := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'HR_FLOW_NAME_ATTR');
        if l_result = 'PROCEED' then
            resultout := 'COMPLETE:Y' ;
        else
            resultout := 'COMPLETE:N';
        end if;
        return;

    end if;



    IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

hr_multi_message.enable_message_list;


EXCEPTION

    When others then

        rollback to commit_transaction;
    --
    hr_utility.set_location('ERROR Update Competence', 10);

    l_error_text := hr_utility.get_message;
    if l_error_text is null then
      l_error_text := fnd_message.get;
    end if;
    -- 1903606
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');

    -- set the ERROR_MESSAGE_TEXT
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => nvl(l_error_text, sqlerrm));
hr_utility.trace('l_error_text' || nvl(l_error_text, sqlerrm));
   -- update the transaction table status
    hr_transaction_api.update_transaction(
      p_transaction_id => hr_transaction_ss.get_transaction_id
                          (p_item_type => itemtype
                          ,p_item_key => itemkey),
                          p_status => 'E');

    -- an application error or warning has been set
    resultout := 'COMPLETE:E';

hr_multi_message.enable_message_list;
end Update_competence;

--  ---------------------------------------------------------------------------
--  |----------------------< check_Update_competence >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE check_Update_competence  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )
is

      l_transaction_step_id 	number(15);

        l_error_text    varchar2(2000);
        l_result    varchar2(25);

begin
hr_utility.set_location('ENTERING check Update Competence', 10);
hr_multi_message.disable_message_list;
    IF (funcmode='RUN') THEN
   -- savepoint commit_transaction;

        l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');



        process_api(true,l_transaction_step_id);
        l_result := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'HR_FLOW_NAME_ATTR');
        hr_utility.trace('l_result chk_proceed' || l_result);
        if l_result = 'PROCEED' then
            resultout := 'COMPLETE:Y' ;
        else
            resultout := 'COMPLETE:N';
        end if;
        return;

    end if;



    IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

hr_multi_message.enable_message_list;

EXCEPTION

    When others then

       -- rollback to commit_transaction;
    --
    hr_utility.set_location('ERROR Update Competence', 10);

    l_error_text := hr_utility.get_message;
    if l_error_text is null then
      l_error_text := fnd_message.get;
    end if;
    -- 1903606
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');

    -- set the ERROR_MESSAGE_TEXT
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => nvl(l_error_text, sqlerrm));
hr_utility.trace('l_error_text' || nvl(l_error_text, sqlerrm));
   -- update the transaction table status
    hr_transaction_api.update_transaction(
      p_transaction_id => hr_transaction_ss.get_transaction_id
                          (p_item_type => itemtype
                          ,p_item_key => itemkey),
                          p_status => 'E');

    -- an application error or warning has been set
    resultout := 'COMPLETE:E';

hr_multi_message.enable_message_list;

end check_Update_competence;


--  ---------------------------------------------------------------------------
--  |----------------------< get_approval_req >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_approval_req  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )
IS

l_item_value varchar2(200);
l_ntf_url varchar2(4000);
l_item_value_crs varchar2(200);
l_item_value_off varchar2(200);
l_event_id number(15);
l_LP_id number(15);
l_cert_id number(15);
l_person_id varchar2(30);
l_active_assignment number(15) := -1;



Cursor getActAttrValue is
SELECT WAAV.TEXT_VALUE Value
FROM WF_ACTIVITY_ATTR_VALUES WAAV
WHERE WAAV.PROCESS_ACTIVITY_ID = actid
AND WAAV.NAME = 'HR_APPROVAL_REQ_FLAG';

cursor get_cert_setting(l_id number) is
select competency_update_level
from ota_certifications_b
where certification_id = l_id;

cursor get_LP_setting(l_id number) is
select competency_update_level
from ota_learning_paths
where learning_path_id = l_id;

cursor get_course_off_setting(l_id number) is
select oav.competency_update_level,off.competency_update_level
from ota_activity_versions oav,ota_offerings off,ota_events oev
where oav.activity_version_id = off.activity_version_id
and off.offering_id = oev.parent_offering_id
and
oev.event_id = l_id;

--added for bug 7308160
cursor C_Assignment(p_person_id varchar2) is
SELECT paf.ASSIGNMENT_ID
FROM per_all_assignments_f paf
WHERE  paf.person_id         = p_person_id
AND  TRUNC(SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date
AND paf.primary_flag ='Y'
AND paf.assignment_type in ('E','A', 'C');

BEGIN
hr_utility.set_location('ENTERING get_approval_req', 10);
	IF (funcmode='RUN') THEN

    l_cert_id := wf_engine.getItemAttrNumber(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'RECRUITER_ID');
     l_LP_id := wf_engine.getItemAttrNumber(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'BOOKING_ID');
     l_event_id := wf_engine.getItemAttrNumber(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'EVENT_ID');
     l_person_id := wf_engine.GetItemAttrText(itemtype => itemtype
			     ,itemkey  => itemkey
			     ,aname    => 'CURRENT_PERSON_ID');

--added for bug 7308160
     if l_person_id is not null then
     open  C_Assignment(l_person_id);
     fetch C_Assignment into l_active_assignment;
     close C_Assignment;
     end if;

     if (l_active_assignment = -1 and l_person_id is not null) then
         --learner is ex-employee so automatic update without approval
          l_item_value:='NOTIFYUPDATE';
     else
        if l_cert_id is not null then
          open get_cert_setting(l_cert_id);
          fetch get_cert_setting into l_item_value;
          close get_cert_setting;

        elsif l_LP_id is not null then
           open get_LP_setting(l_LP_id);
           fetch get_LP_setting into l_item_value;
           close get_LP_setting;
        else
           open get_course_off_setting(l_event_id);
           fetch get_course_off_setting into l_item_value_crs,l_item_value_off;
           close get_course_off_setting;

           if l_item_value_off is not null then
              l_item_value := l_item_value_off;
           else
              l_item_value:= l_item_value_crs;
           end if;

       end if;
    end if;

    if l_item_value is null then

    OPEN getActAttrValue;
    FETCH getActAttrValue INTO l_item_value;
    hr_utility.trace('l_item_value' || l_item_value);
    close getActAttrValue;

    end if;
   --     if getActAttrValue%FOUND then

    /*
     l_item_value := wf_engine.getItemAttrText(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'HR_APPROVAL_REQ_FLAG');

                  wf_engine.*/

              if l_item_value = 'NONOTIFY' then

                   resultout:='COMPLETE:NONOTIFY';

              elsif l_item_value = 'NOTIFYUPDATE' then

                   resultout:='COMPLETE:NOTIFYUPDATE';

               elsif l_item_value = 'APPROVAL' then

                   resultout:='COMPLETE:APPROVAL';
               elsif l_item_value = 'NOTIFYONLY' then

                   resultout:='COMPLETE:NOTIFYONLY';
               else

                   resultout:='COMPLETE';


              end if;
        hr_utility.trace('l_resultout' || resultout);
        l_ntf_url := generate_url(l_item_value);
        WF_ENGINE.setitemattrtext(itemtype, itemkey, 'APPROVAL_GENERIC_URL', l_ntf_url);
WF_ENGINE.setitemattrtext(itemtype, itemkey, 'HR_REVIEW_TEMPLATE_RN_ATTR', 'OTA_LIST_COMP_NTF');
      /*  END IF; -- cursor
        CLOSE getActAttrValue;*/
                 RETURN;
	END IF; --RUN

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;
Exception

	when others then
hr_utility.set_location('ENTERING exception get_approval_req', 10);



end get_approval_req;
--  ---------------------------------------------------------------------------
--  |----------------------< get_Value >--------------------------|
--  ---------------------------------------------------------------------------
--

Procedure get_Value( inString varchar2, startPos number, endPos out nocopy number , retValue out nocopy varchar2)
is

l_value varchar2(1000);
l_posFound number(15);

begin

select INSTR(inString,'^',startPos) into l_posFound from dual;

if l_posFound=0 then --implies last string token
    select SUBSTR(inString,startPos,((length(inString)+1)-startPos)) into l_value from dual;
else
	select SUBSTR(inString,startPos,(l_posFound-startPos)) into l_value from dual;
end if;


endPos :=l_posFound ;
retValue := l_value;

Exception
  when others then
  raise;

end get_Value;


PROCEDURE process_api
        (p_validate IN BOOLEAN ,p_transaction_step_id IN NUMBER) IS

 /*l_transaction_mode            VARCHAR2(10);
 l_from                        VARCHAR2(20);
 l_tran_submitted              VARCHAR2(1);*/

 l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;

 l_proc 	varchar2(72) := g_package||'process_api';
 l_from                        VARCHAR2(20);

 l_person_id number(15);

 l_Comp_ids  varchar2(4000);
 l_level_ids varchar2(4000);

 l_comp_startPos number(15):=1;
 l_comp_endPos number(15);
 l_comp_retValue varchar2(100);

 l_level_startPos number(15) :=1;
 l_level_endPos number(15);
 l_level_retValue varchar2(100);

 l_override_ids  varchar2(4000);

 l_override_startPos number(15):=1;
 l_override_endPos number(15);
 l_override_retValue varchar2(100);

 l_dtFrom varchar2(4000);

 l_dtFrom_startPos number(15) :=1;
 l_dtFrom_endPos number(15);
 l_dtFrom_retValue varchar2(100);

 l_dtTo  varchar2(4000);
 l_source varchar2(4000);

 l_dtTo_startPos number(15):=1;
 l_dtTo_endPos number(15);
 l_dtTo_retValue varchar2(100);

 l_source_startPos number(15) :=1;
 l_source_endPos number(15);
 l_source_retValue varchar2(100);

 l_certDate  varchar2(4000);
 l_certMethod varchar2(4000);

 l_certDate_startPos number(15):=1;
 l_certDate_endPos number(15);
 l_certDate_retValue varchar2(100);

 l_certMethod_startPos number(15) :=1;
 l_certMethod_endPos number(15);
 l_certMethod_retValue varchar2(100);

 l_certNext  varchar2(4000);
 l_comments varchar2(4000);

 l_certNext_startPos number(15):=1;
 l_certNext_endPos number(15);
 l_certNext_retValue varchar2(100);

 l_comments_startPos number(15) :=1;
 l_comments_endPos number(15);
 l_comments_retValue varchar2(1000);

 l_competence_created number(10);

 l_level_value_to_use number(10);

 l_business_group_id per_all_people_f.business_group_id%type;

 l_old_level_id number(15);
 l_attr_chk boolean := TRUE;
l_fwd_to_username varchar2(1000);
 l_msg_name varchar2(1000);

 Cursor Comp_level(CompId number,personId number) is
 Select Proficiency_level_id
 from per_competence_elements
 where Competence_id = CompId
 and person_id = personId;


BEGIN

  /*   l_Comp_ids := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_COMPETENCE');*/

      SAVEPOINT validate_competence;

     l_person_id := hr_transaction_api.get_number_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_PERSON');

     l_Comp_ids := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_COMPETENCE');

     l_level_ids := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_LEVEL');

     l_override_ids := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_LEVELOVERRIDE');

     l_dtFrom := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_DATEFROM');

     l_dtTo := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_DATETO');

     l_source := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_SOURCE');

     l_certDate := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_CERTDATE');

     l_certMethod := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_CERTMETHOD');


     l_certNext := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_CERTNEXT');

     l_comments := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_COMMENTS');

     l_business_group_id := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_BUSINESS_GROUP_ID');

--GET item type and key
  hr_transaction_api.get_transaction_step_info
  (p_transaction_step_id => p_transaction_step_id
  ,p_item_type   => l_item_type
  ,p_item_key    => l_item_key
  ,p_activity_id  => l_activity_id);

    -- no need if no competency is attached
    if l_comp_ids is not null then
    Loop

        get_value(inString =>l_comp_ids,
                startPos =>l_comp_startPos,
                endPos => l_comp_endPos,
                retValue => l_comp_retValue);
        hr_utility.trace ('l_comp_retValue ' ||l_comp_retValue);

        l_comp_startPos := l_comp_endPos+1;

        get_value(inString =>l_level_ids,
                startPos =>l_level_startPos,
                endPos => l_level_endPos,
                retValue => l_level_retValue);

        l_level_startPos := l_level_endPos+1;

        if l_level_retValue ='-1' then

            l_level_retValue  := null;

        end if;

        get_value(inString =>l_override_ids,
                startPos =>l_override_startPos,
                endPos => l_override_endPos,
                retValue => l_override_retValue);

        l_override_startPos := l_override_endPos+1;

        if l_override_retValue ='-1' then

            l_override_retValue  := null;

        end if;



        get_value(inString =>l_dtFrom,
                startPos =>l_dtFrom_startPos,
                endPos => l_dtFrom_endPos,
                retValue => l_dtFrom_retValue);
        hr_utility.trace ('l_dtFrom_retValue ' ||l_dtFrom_retValue);
        l_dtFrom_startPos := l_dtFrom_endPos+1;

        if l_dtFrom_retValue ='-1' then

            l_dtFrom_retValue  := null;

        end if;

        if l_dtFrom_retValue is null then

            l_dtFrom_retValue  := trunc(sysdate);
        end if;


        get_value(inString =>l_dtTo,
                startPos =>l_dtTo_startPos,
                endPos => l_dtTo_endPos,
                retValue => l_dtTo_retValue);
        hr_utility.trace ('l_dtTo_retValue ' ||l_dtTo_retValue);
        l_dtTo_startPos := l_dtTo_endPos+1;

        if l_dtTo_retValue ='-1' then

            l_dtTo_retValue  := null;

        end if;

        get_value(inString =>l_source,
                startPos =>l_source_startPos,
                endPos => l_source_endPos,
                retValue => l_source_retValue);

        l_source_startPos := l_source_endPos+1;

        if l_source_retValue ='-1' then

            l_source_retValue  := null;

        end if;

        get_value(inString =>l_certDate,
                startPos =>l_certDate_startPos,
                endPos => l_certDate_endPos,
                retValue => l_certDate_retValue);

        l_certDate_startPos := l_certDate_endPos+1;

        if l_certDate_retValue ='-1' then

            l_certDate_retValue  := null;

        end if;

        get_value(inString =>l_certMethod,
                startPos =>l_certMethod_startPos,
                endPos => l_certMethod_endPos,
                retValue => l_certMethod_retValue);

        l_certMethod_startPos := l_certMethod_endPos+1;

        if l_certMethod_retValue ='-1' then

            l_certMethod_retValue  := null;

        end if;

        get_value(inString =>l_certNext,
                startPos =>l_certNext_startPos,
                endPos => l_certNext_endPos,
                retValue => l_certNext_retValue);

        l_certNext_startPos := l_certNext_endPos+1;

        if l_certNext_retValue ='-1' then

            l_certNext_retValue  := null;

        end if;

        get_value(inString =>l_comments,
                startPos =>l_comments_startPos,
                endPos => l_comments_endPos,
                retValue => l_comments_retValue);

        l_comments_startPos := l_comments_endPos+1;

        if l_comments_retValue ='-1' then

            l_comments_retValue  := null;

        end if;

    if l_override_retValue is not null then
        l_level_value_to_use := l_override_retValue;
    else
        l_level_value_to_use := l_level_retValue;
    end if;
-- bug 3433361
	l_old_level_id := null;
    OPEN Comp_level(l_comp_retValue,l_person_id);
    FETCH Comp_level INTO l_old_level_id;
    CLOSE Comp_level;

--if ((l_level_value_to_use is not null and l_old_level_id <= l_level_value_to_use) or l_old_level_id is null) then

hr_utility.set_location('BEFORE call to competence element api', 100);

    hr_competence_element_api.maintain_student_comp_element
    (p_person_id                     => l_person_id
    ,p_competence_id                 => l_comp_retValue
    ,p_proficiency_level_id          => l_level_value_to_use
    ,p_business_group_id             => l_business_group_id --2798
    ,p_effective_date_from           => to_date(l_dtFrom_retValue,g_date_format)
    ,p_effective_date_to             => to_date(l_dtTo_retValue,g_date_format)
    ,p_certification_date             => to_date(l_certDate_retValue,g_date_format)
    ,p_certification_method           => l_certMethod_retValue
    ,p_next_certification_date        => to_date(l_certNext_retValue,g_date_format)
    ,p_source_of_proficiency_level    => l_source_retValue
    ,p_comments                       => l_comments_retValue
    ,p_effective_date                 => trunc(sysdate)
  --  ,p_validate                     => p_validate
    ,p_competence_created            => l_competence_created);
  hr_utility.set_location('After call to competence element api', 100);
  hr_utility.trace ('l_competence_created ' ||l_competence_created);



  if l_competence_created <> 0 and (l_attr_chk) then
  l_attr_chk := false;
 --   WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_FLOW_NAME_ATTR', 'PROCEED');
 -- elsif (l_attr_chk) then
 --   WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_FLOW_NAME_ATTR', 'STOP');
  end if;
--end if; --level_id

            if l_comp_endPos =0 then --implies end of string has been reached

            Exit ;
        end if;



 end Loop;

 end if;

 if p_validate then
    rollback to validate_competence;
 end if;
 if l_attr_chk then
 WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_FLOW_NAME_ATTR', 'STOP');
 else
 WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_FLOW_NAME_ATTR', 'PROCEED');
 end if;
 hr_utility.set_location('Leaving'||l_proc, 5);

  EXCEPTION
		WHEN OTHERS THEN
        hr_utility.set_location('Leaving with error:'||l_proc, 25);
        rollback to validate_competence;
-- In case of Approvla required Error notification shud go to approving manager
 -- In case of auto competence update error notification shud go to learner
        l_fwd_to_username:= nvl(wf_engine.getitemattrtext
                        (l_item_type,
                            l_item_key,
                            'FORWARD_TO_USERNAME'
                          ),
                          wf_engine.getitemattrtext
                          (l_item_type,
                            l_item_key,
                            'CURRENT_PERSON_USERNAME'
                            )
                            );
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'APPROVAL_CREATOR_USERNAME', l_fwd_to_username);
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_REVIEW_TEMPLATE_RN_ATTR', 'HR_CHKERRORSRN_NTF');
/*wf_engine.SetItemAttrText ( l_item_type, l_item_key,
                         'APPROVAL_CREATOR_DISPLAY_NAME',l_fwd_to_username
                     );
*/
-- change date message to a more meaningful one.
    l_msg_name:= sqlerrm;
    hr_utility.trace('l_msg_name' || sqlerrm);
    if instr(l_msg_name,'_51647_')>0 then
    hr_utility.set_location('MESSAGE CHANGED', 10);
        fnd_message.set_name('OTA', 'OTA_443335_COMP_UPD_FAIL');
    --fnd_message.raise_error;
    end if;
        RAISE;
        --null;
END process_api;

--  ---------------------------------------------------------------------------
--  |----------------------< validate_competence_update >--------------------------|
--  ---------------------------------------------------------------------------
--

procedure validate_competence_update
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2) is

  l_transaction_step_id 	number(15);


begin

    l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');



    process_api(true,l_transaction_step_id);

p_message := 'S' ;

EXCEPTION
    When OTHERS Then
         p_message := fnd_message.get();
         If p_message is NULL then
            p_message := substr(SQLERRM,11,(length(SQLERRM)-10));
         End If;

end validate_competence_update;


--  ---------------------------------------------------------------------------
--  |----------------------< chk_comp_level >--------------------------|
--  ---------------------------------------------------------------------------
--
function chk_comp_level(p_comp_id in varchar2,
                        p_level_id in varchar2,
                        p_person_id in number)
return varchar2 is

Cursor Comp_level(CompId number,personId number) is
 Select Proficiency_level_id
 from per_competence_elements
 where Competence_id = CompId
 and person_id = personId;

 l_person_id number(15):= p_person_id;

 l_Comp_ids  varchar2(4000):=p_comp_id;
 l_level_ids varchar2(4000):= p_level_id;

 l_comp_startPos number(15):=1;
 l_comp_endPos number(15);
 l_comp_retValue varchar2(100);

 l_level_startPos number(15) :=1;
 l_level_endPos number(15);
 l_level_retValue varchar2(100);

 l_old_level_id number(15);
 l_flag Boolean := TRUE;


begin

        Loop

        get_value(inString =>l_comp_ids,
                startPos =>l_comp_startPos,
                endPos => l_comp_endPos,
                retValue => l_comp_retValue);
        hr_utility.trace ('l_comp_retValue ' ||l_comp_retValue);

        l_comp_startPos := l_comp_endPos+1;

        get_value(inString =>l_level_ids,
                startPos =>l_level_startPos,
                endPos => l_level_endPos,
                retValue => l_level_retValue);

        l_level_startPos := l_level_endPos+1;



        l_old_level_id := null;
        OPEN Comp_level(l_comp_retValue,l_person_id);
        FETCH Comp_level INTO l_old_level_id;
       -- CLOSE Comp_level;
	if Comp_level%notfound then --implies competence itself doesn't exist
            CLOSE Comp_level;
            l_flag:=false;
            exit;

        else
            CLOSE Comp_level;
        end if;

if (nvl(l_old_level_id,-1) <= nvl(l_level_retValue,-1)) then

l_flag:= FALSE;
exit;


end if;

    if l_comp_endPos =0 then --implies end of string has been reached

            Exit ;
        end if;



 end Loop;

 if l_flag then
 return 'NOUPDATE';
 else

 return 'UPDATE';
end if;

end chk_comp_level;


--  ---------------------------------------------------------------------------
--  |----------------------< create_wf_process >--------------------------|
--  ---------------------------------------------------------------------------
--

Procedure create_wf_process(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type,
            p_learningpath_ids in varchar2 ,
            p_certification_Id in number default null,
            p_itemkey       out nocopy wf_items.item_key%type)
            is

l_proc 	varchar2(72) := g_package||'create_wf_process';
l_process             	wf_activities.name%type := upper(p_process);
l_item_type    wf_items.item_type%type := upper(p_itemtype);
  l_item_key     wf_items.item_key%type;

l_LP_ids  varchar2(4000) := p_learningpath_ids;

 l_LP_startPos number(15):=1;
 l_LP_endPos number(15);
 l_LP_retValue varchar2(100);

l_user_name  varchar2(80);
l_current_username varchar2(80);
--:= fnd_profile.value('USERNAME');
l_current_user_Id  number ;
--:= fnd_profile.value('USER_ID');

l_creator_username varchar2(80):= fnd_profile.value('USERNAME');
l_creator_user_Id  number := fnd_profile.value('USER_ID');

l_creator_person_id   per_all_people_f.person_id%type;
l_ntf_url varchar2(4000);
l_comp_ids varchar2(4000);
l_level_ids varchar2(4000);
l_eff_date_from varchar2(4000);
l_eff_date_to varchar2(4000);

--l_person_details		ota_learner_enroll_ss.csr_person_to_enroll_details%ROWTYPE;
l_person_full_name  per_all_people_f.full_name%TYPE;
l_role_name wf_roles.name%type;
l_role_display_name wf_roles.display_name%type;

l_assignment varchar2(100);

l_supervisor_id         per_all_people_f.person_id%Type;
l_supervisor_username   fnd_user.user_name%TYPE;
l_supervisor_full_name  per_all_people_f.full_name%TYPE;

l_event_name  ota_events.title%type;

l_course_name  ota_activity_versions.version_name%type;
l_process_display_name varchar2(240);

l_loop_counter number(15) := 0;
l_will_comp_update varchar2(50);
l_LP_lookup_meaning varchar2(100);
l_CRS_lookup_meaning varchar2(100);
l_CERT_lookup_meaning varchar2(100);

Cursor get_display_name is
SELECT wrpv.display_name displayName
FROM   wf_runnable_processes_v wrpv
WHERE wrpv.item_type = p_itemtype
AND wrpv.process_name = p_process;

cursor curr_per_info
is
Select user_id ,user_name
from
fnd_user
where employee_id=p_person_id;

CURSOR C_USER IS
SELECT
 EMPLOYEE_ID
FROM
 FND_USER
WHERE
 user_id = l_creator_user_id ;

Cursor C_Assignment is
SELECT
paf.ASSIGNMENT_ID
FROM    per_all_assignments_f paf
    WHERE  paf.person_id         = p_person_id
       AND  TRUNC(SYSDATE) BETWEEN
     paf.effective_start_date
    AND paf.effective_end_date
    AND paf.primary_flag ='Y'
    AND paf.assignment_type in ('E','A', 'C');

--added for bug 7308160
Cursor C_Ex_Assignment is
    SELECT
    paf.ASSIGNMENT_ID
    FROM    per_all_assignments_f paf
        WHERE  paf.person_id         = p_person_id
        AND paf.primary_flag ='Y'
    AND paf.assignment_type in ('E','A', 'C')
    order by paf.effective_end_date;

 Cursor get_person_full_name is
   Select ppf.full_name
   FROM per_all_people_f ppf
   where ppf.person_id = p_person_id
   AND  TRUNC(SYSDATE) BETWEEN ppf.effective_start_date
    AND ppf.effective_end_date;


 CURSOR csr_supervisor_id IS
  SELECT asg.supervisor_id, per.full_name
    FROM per_all_assignments_f asg,
         per_all_people_f per
   WHERE asg.person_id = p_person_id
     AND per.person_id = asg.supervisor_id
     AND asg.primary_flag = 'Y'
     AND trunc(sysdate)
 BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND trunc(sysdate)
 BETWEEN per.effective_start_date AND per.effective_end_date;

 CURSOR csr_supervisor_user IS
 SELECT user_name
   FROM fnd_user
  WHERE employee_id= l_supervisor_id;

  Cursor csr_name is
  select oev.title,oav.version_name
from ota_Events_vl oev ,ota_activity_versions_tl oav
--,ota_offerings off
where
--oev.parent_offering_id=off.offering_id	and
    oev.activity_version_id= oav.activity_version_id
	and oev.event_id= p_eventid
    and Language= USERENV('LANG');

    cursor LP_name (csr_lp_id varchar2) is
    select name from ota_learning_paths_TL
    where learning_path_id =csr_lp_id
    and Language= USERENV('LANG');

cursor chk_person_business_grp
    is
    Select 1 from
    per_all_people_f
    where person_id= p_person_id
    and (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is not null or --Bug#6869342
        business_group_id = ota_general.get_business_group_id);

-- get certification name
  cursor certification_name
  is select name from ota_certifications_tl
  where certification_id = p_certification_id
  and Language= USERENV('LANG');

cursor getFYINtfParamVal(param varchar2) is
SELECT decode(instr(web_html_call, param), 0, '-1',
substr(substr(web_html_call, instr(web_html_call, param),
    (decode(instr(web_html_call, '&', instr(web_html_call, param), 1), 0, (length(web_html_call)+1),
      instr(web_html_call, '&', instr(web_html_call, param), 1))-instr(web_html_call, param))),
      instr(substr(web_html_call, instr(web_html_call, param),
    (decode(instr(web_html_call, '&', instr(web_html_call, param), 1), 0, (length(web_html_call)+1),
      instr(web_html_call, '&', instr(web_html_call, param), 1))-instr(web_html_call, param))), '=')+1)) "paramvalue"
FROM fnd_form_functions
WHERE function_name = 'OTA_LEARNER_HOME_SS';

    l_business_group_id per_all_people_f.business_group_id%type;
    l_ntfFyiParamVal varchar2(5) := 'N';


BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN chk_person_business_grp;
FETCH chk_person_business_grp INTO l_business_group_id;
if chk_person_business_grp%found then
CLOSE chk_person_business_grp;


--Retrieve comp. info for the course first to be stored in tt table
   COMP_RETREIVE ( p_event_id => p_eventid
			, p_learning_path_ids => p_learningpath_ids
            , p_certification_id => p_certification_id
            , p_person_id => p_person_id
			, p_comp_ids => l_comp_ids
			, p_level_ids =>l_level_ids
            ,p_eff_date_from => l_eff_date_from
            ,p_eff_date_to => l_eff_date_to);

--Retrieve comp. info for each of the LP's to be stored in tt table ,
--create separate worklfow process for each LP.
hr_utility.trace ('l_LP_idsssss ' ||l_LP_ids);

-- code required for object type to be set in notifications
if p_learningpath_ids is not null then
l_LP_lookup_meaning := ota_utility.get_lookup_meaning(p_lookup_type => 'OTA_CATALOG_OBJECT_TYPE',
                                                        p_lookup_code =>'CLP',
	                                                 p_application_id =>810);
elsif p_eventid is not null then
l_CRS_lookup_meaning := ota_utility.get_lookup_meaning(p_lookup_type => 'OTA_CATALOG_OBJECT_TYPE',
                                                        p_lookup_code =>'H',
	                                                 p_application_id =>810);
else ---Batra to revisit**********************
l_CERT_lookup_meaning := ota_utility.get_lookup_meaning(p_lookup_type => 'OTA_CATALOG_OBJECT_TYPE',
                                                        p_lookup_code =>'CER',
	                                                 p_application_id =>810);
end if;
/*Loop

    if l_loop_counter > 0 and (l_LP_ids <>'' or l_LP_ids is not null) then

        get_value(inString =>l_LP_ids,
                startPos =>l_LP_startPos,
                endPos => l_LP_endPos,
                retValue => l_LP_retValue);
        hr_utility.trace ('l_LP_retValue ' ||l_LP_retValue);

        l_LP_startPos := l_LP_endPos+1;

        --Retrieve comp. info for the course first , to be stored in tt table
    COMP_RETREIVE ( p_event_id => p_eventid
			, p_learning_path_ids =>l_LP_retValue
			, p_comp_ids => l_comp_ids
			, p_level_ids =>l_level_ids
            ,p_eff_date_from => l_eff_date_from);

     end if;
hr_utility.trace ('l_comp_idssssssssss ' ||l_comp_ids);
--l_current_user_Id := 12725;
*/
--Start transaction and workflow only when competencies are attached
/*if l_comp_ids is not null then
l_will_comp_update := chk_comp_level(l_comp_ids,l_level_ids,p_person_id);
end if;*/
--if (l_comp_ids is not null and l_will_comp_update='UPDATE')then
if (l_comp_ids is not null) then
--if l_comp_ids is not null then


OPEN get_display_name;
FETCH get_display_name INTO l_process_display_name;
CLOSE get_display_name;


OPEN curr_per_info;
FETCH curr_per_info INTO l_current_user_id, l_current_username;
CLOSE curr_per_info;

OPEN C_USER;
FETCH C_USER INTO l_creator_person_id;
CLOSE C_USER;

open C_Assignment;
Fetch C_Assignment into l_assignment;
close C_Assignment;

--added for bug 7308160
if l_assignment is null then
FOR assg in C_Ex_Assignment LOOP
 l_assignment := assg.assignment_id;
END LOOP;
end if;

open get_person_full_name;
Fetch get_person_full_name into l_person_full_name;
close get_person_full_name;


if p_eventid is not null then
open csr_name;
Fetch csr_name into l_event_name ,l_course_name;
close csr_name;

elsif p_learningpath_ids is not null then
OPEN LP_name(p_learningpath_ids);
FETCH LP_name INTO l_course_name;
CLOSE LP_name;

else
OPEN certification_name;
FETCH certification_name INTO l_course_name;
CLOSE certification_name;
end if;

 hr_utility.set_location('Entering:'||l_proc, 10);
 -- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;


WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

if p_Learningpath_ids is not null then
hr_utility.set_location('before OTA_OBJECT_TYPE'||l_proc, 140);
    WF_ENGINE.setitemattrtext(l_item_type,
  			          l_item_key,
			          'REVIEW_OBJECT',
				  l_LP_lookup_meaning);
hr_utility.set_location('after OTA_OBJECT_TYPE'||l_proc, 240);
elsif p_eventid is not null then
hr_utility.set_location('before OTA_OBJECT_TYPE 2'||l_proc, 340);
      WF_ENGINE.setitemattrtext(l_item_type,
  			          l_item_key,
			          'REVIEW_OBJECT',
				  l_CRS_lookup_meaning);
hr_utility.set_location('after OTA_OBJECT_TYPE 2'||l_proc, 440);
else
WF_ENGINE.setitemattrtext(l_item_type,
  			          l_item_key,
			          'REVIEW_OBJECT',
				  l_CERT_lookup_meaning);
end if;

WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CURRENT_PERSON_ID', p_person_id);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CURRENT_PERSON_USERNAME', l_current_username);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_USERNAME', l_current_username);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_ID', p_person_id);
--WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_USERNAME', l_creator_username);
--WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_ID', l_creator_person_id);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'PROCESS_DISPLAY_NAME', l_process_display_name);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'PROCESS_NAME',p_process );
--hard coded date format required by pqh
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key,'P_EFFECTIVE_DATE',to_char(trunc(sysdate),'RRRR-MM-DD'));
--WF_ENGINE.setitemattrtext(p_itemtype, l_item_key,'P_EFFECTIVE_DATE',trunc(sysdate));
WF_ENGINE.setitemattrDate(p_itemtype, l_item_key,'CURRENT_EFFECTIVE_DATE',trunc(sysdate));

open getFYINtfParamVal('pFyiNtfDetails');
fetch getFYINtfParamVal into l_ntfFyiParamVal;
close getFYINtfParamVal;

if(trim(l_ntfFyiParamVal) = 'Y') then
    WF_ENGINE.setitemattrtext(p_itemtype, l_item_key,'FYI_NTF_DETAILS','Y');
end if;

-- Get and set owner role

hr_utility.set_location('Before Getting Owner'||l_proc, 10);

        WF_DIRECTORY.GetRoleName(p_orig_system =>'PER',
                      p_orig_system_id => l_creator_person_id,
                      p_name  =>l_role_name,
                      p_display_name  =>l_role_display_name);


        WF_ENGINE.SetItemOwner(
                               itemtype => l_item_type,
                               itemkey =>l_item_key,
                               owner =>l_role_name);

    hr_utility.set_location('After Setting Owner'||l_proc, 10);

    --modified for bug 7308160

/*l_person_details := ota_learner_enroll_ss.Get_Person_To_Enroll_Details(p_person_id => p_person_id);

           IF l_person_details.full_name is not null then
                   WF_ENGINE.setitemattrtext(l_item_type,
                             		     l_item_key,
                                             'CURRENT_PERSON_DISPLAY_NAME',
                                             l_person_details.full_name);
                    WF_ENGINE.setitemattrtext(l_item_type,
                             		     l_item_key,
                                             'CREATOR_PERSON_DISPLAY_NAME',
                                             l_person_details.full_name);
           END IF;*/

           IF l_person_full_name is not null then
	                      WF_ENGINE.setitemattrtext(l_item_type,
	                                		     l_item_key,
	                                                'CURRENT_PERSON_DISPLAY_NAME',
	                                                l_person_full_name);
	                       WF_ENGINE.setitemattrtext(l_item_type,
	                                		     l_item_key,
	                                                'CREATOR_PERSON_DISPLAY_NAME',
	                                                l_person_full_name);
           END IF;


  HR_UTILITY.TRACE ('item key: ' || l_item_key);




--start a transaction and save data to transaction tables
save_Comptence_info(
            p_person_id =>p_person_id ,
            p_item_type => l_item_type,
            p_item_key  => l_item_key,
            p_Competence_id => l_comp_ids,
            p_level_id   => l_level_ids,
            p_date_from =>l_eff_date_from,
            p_date_to => l_eff_date_to);


hr_utility.set_location('before supervisor'||l_proc, 30);
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_CUSTOM_RETURN_FOR_CORR','Y');

--always set to Y
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_RUNTIME_APPROVAL_REQ_FLAG', 'YES');
hr_utility.set_location('before supervisor'||l_proc, 40);
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'P_ASSIGNMENT_ID', l_assignment);
hr_utility.set_location('before supervisor'||l_proc, 50);
WF_ENGINE.setitemattrNumber(l_item_type, l_item_key, 'CURRENT_ASSIGNMENT_ID', to_number(l_assignment));

if p_eventId is not null then
WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'OTA_EVENT_TITLE', l_event_name);
end if;

WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'OTA_ACTIVITY_VERSION_NAME', l_course_name);
--WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_AME_TRAN_TYPE_ATTR','SSHRMS');
-- bug 3483960
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_AME_TRAN_TYPE_ATTR','OTA');
WF_ENGINE.setitemattrNumber(l_item_type, l_item_key, 'HR_AME_APP_ID_ATTR', 810);
--WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'TRAN_SUBMIT','Y');
--WF_ENGINE.SetItemattrtext(p_itemtype,p_item_key, 'EVENT_OWNER',l_user_name);
hr_utility.set_location('before supervisor'||l_proc, 20);

     FOR a IN csr_supervisor_id LOOP
          l_supervisor_id := a.supervisor_id;
          l_supervisor_full_name := a.full_name;
      END LOOP;


     FOR b IN csr_supervisor_user LOOP
         l_supervisor_username := b.user_name;
     END LOOP;

 hr_utility.set_location('after supervisor cursor'||l_proc, 20);

wf_engine.setitemattrtext
            (l_item_type,
             l_item_key,
             'SUPERVISOR_USERNAME',
             l_supervisor_username);
hr_utility.set_location('after supervisor username'||l_proc, 20);

        wf_engine.setitemattrtext
            (l_item_type,
             l_item_key,
             'SUPERVISOR_DISPLAY_NAME',
             l_supervisor_full_name);
hr_utility.set_location('after supervisor disp name'||l_proc, 20);
         wf_engine.setitemattrtext
            (l_item_type,
             l_item_key,
             'SUPERVISOR_ID',
             l_supervisor_id);
hr_utility.set_location('before start process'||l_proc, 20);
if p_learningpath_ids is not null then

/*hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => l_item_type
		      ,p_item_key   => l_item_key
		      ,p_name       => 'OTA_LP_ID');*/

      WF_ENGINE.setitemattrnumber(l_item_type,
  			          l_item_key,
			          'BOOKING_ID',
				  p_learningpath_ids);

elsif p_eventId is not null then


      WF_ENGINE.setitemattrnumber(l_item_type,
  			          l_item_key,
			          'EVENT_ID',
				  p_eventid);
else

      WF_ENGINE.setitemattrnumber(l_item_type,
  			          l_item_key,
			          'RECRUITER_ID',
				  p_certification_id);
end if;
WF_ENGINE.STARTPROCESS(p_itemtype,l_item_key);

end if;
else
CLOSE chk_person_business_grp;
end if;--chk_person_business_grp

p_itemkey:=l_item_key;


hr_utility.set_location('leaving:'||l_proc, 20);
EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Raise;



end create_wf_process;

--  ---------------------------------------------------------------------------
--  |----------------------< generate_url >--------------------------|
--  ---------------------------------------------------------------------------
--

Function generate_url(p_func varchar2) return varchar2
is

l_proc 	varchar2(72) := g_package||'generate_url';
l_jsp_apps_agent varchar2(2000);
l_url varchar2(4000);
l_amp varchar2(2) := '&';
l_func varchar2(80);

begin
hr_utility.set_location('Entering'||l_proc, 5);

--l_jsp_apps_agent := fnd_profile.value('APPS_FRAMEWORK_AGENT');
--HR_UTILITY.TRACE ('Agent :: ' || l_jsp_apps_agent);
if p_func='APPROVAL' then
    l_func:='OTA_ADMIN_COMPETENCE_UPDATE';
else
    l_func:='OTA_ADMIN_COMPETENCE_VIEW';

end if;

l_url := 'JSP:' || '/OA_HTML/OA.jsp?OAFunc=' || l_func || l_amp || 'NtfId=-&#NID-' || l_amp || 'retainAM=Y';

HR_UTILITY.TRACE ('URL :: ' || l_url);

return l_url;

hr_utility.set_location('Leaving'||l_proc, 5);
end generate_url;

--  ---------------------------------------------------------------------------
--  |----------------------< COMP_RETREIVE >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE COMP_RETREIVE ( p_event_id IN NUMBER
			, p_learning_path_ids IN VARCHAR2
            , p_certification_id IN Number
            , p_person_id in number
			, p_comp_ids OUT NOCOPY VARCHAR2
			, p_level_ids OUT NOCOPY VARCHAR2
            ,p_eff_date_from out nocopy varchar2
            ,p_eff_date_to out nocopy varchar2) IS


l_learning_path_id NUMBER;
l_leftpos NUMBER := 1;
l_rightpos NUMBER ;
l_count NUMBER := 1;
l_learning_path_ids VARCHAR2(4000);
l_eff_date_from varchar2(4000);
l_expiry_date ota_cert_enrollments.expiration_date%type;
l_eff_date_to varchar2(4000):=NULL;

l_comp_id NUMBER;
l_renewable_period_frequency NUMBER;
l_renewable_period_units VARCHAR2(4000);
p_active_days NUMBER;
l_start_date Date;
l_end_date Date;
allow_comp_renewal_period varchar2(30):= 'N';

l_proc 	varchar2(72) := g_package||'COMP_RETREIVE';

CURSOR csr_get_crs_comps IS
	SELECT pce.competence_id CompetenceId
	               ,nvl(pce.proficiency_level_id,-1) LevelId
	FROM per_competence_elements pce
		   , ota_offerings OFF
		   , ota_events EVT
	WHERE off.activity_version_id = pce.activity_version_id
		AND evt.parent_offering_id = off.offering_id
		AND evt.event_id = p_event_id;

--Added for 8403115 Allow competency update with renewal period for class enrollments

CURSOR csr_get_renewable_period_units(p_competence_id NUMBER) IS
SELECT
pc.competence_id,
pc.renewal_period_frequency,
pc.renewal_period_units
FROM
per_competences pc
where
pc.competence_id = p_competence_id
AND pc.renewal_period_frequency IS NOT NULL
--AND pc.renewal_period_units IS NOT NULL  modified for bug8410902
AND pc.renewal_period_units IN ('Y','D','H','MIN','M','Q','W');

Cursor get_comp_profile is
 Select nvl(fnd_profile.value('OTA_ALLOW_COMPETENCY_UPDATE_WITH_RENEWAL_PERIOD'),'N') from dual;

CURSOR csr_get_lp_comps IS
	SELECT pce.competence_id CompetenceId
	       ,nvl(pce.proficiency_level_id,-1) LevelId
	FROM per_competence_elements pce
	WHERE pce.type = 'OTA_LEARNING_PATH'
		AND pce.object_id = l_learning_path_id;

  CURSOR csr_get_cert_comps IS
	SELECT pce.competence_id CompetenceId
	       ,nvl(pce.proficiency_level_id,-1) LevelId
	FROM per_competence_elements pce
	WHERE pce.type = 'OTA_CERTIFICATION'    ---Batra to revisit*********************
		AND pce.object_id = p_certification_id;

  Cursor get_cert_expiry is
  select cenr.expiration_date
  from ota_cert_enrollments cenr
  where certification_id = p_certification_id
  and person_id = p_person_id;
 -- and certification_status_code ='CERTIFIED';--not ok?//////////////


BEGIN

hr_utility.set_location('Entering:'||l_proc, 5);
IF p_learning_path_ids = '' or p_learning_path_ids is null THEN
        l_learning_path_ids := NULL;
    ELSE
        l_learning_path_ids:= p_learning_path_ids;
    END IF;
 IF p_event_id IS not NULL THEN
 hr_utility.set_location('l_:'||l_proc, 10);
 OPEN get_comp_profile;
 FETCH get_comp_profile into allow_comp_renewal_period;
 CLOSE get_comp_profile;
	FOR crs_comp_rec IN csr_get_crs_comps LOOP
		IF p_comp_ids IS NULL OR p_comp_ids = '' THEN
			p_comp_ids :=  crs_comp_rec.CompetenceId;
			p_level_ids   :=  crs_comp_rec.LevelId;
                 --Modified for 8403115 Allow competency update with renewal period for class enrollments
			-- l_eff_date_from := to_char(get_competence_eff_date(p_comp_id=> crs_comp_rec.CompetenceId,p_id=>p_event_id, p_obj_type=>'COURSE'),g_date_format)	;
			p_active_days := 0;
			l_start_date := get_competence_eff_date(p_comp_id=> crs_comp_rec.CompetenceId,p_id=>p_event_id, p_obj_type=>'COURSE');
            l_eff_date_from := to_char(l_start_date,g_date_format)	;
            l_eff_date_to := NULL;

            if(allow_comp_renewal_period = 'Y') then
             OPEN csr_get_renewable_period_units(crs_comp_rec.CompetenceId);
             FETCH  csr_get_renewable_period_units into l_comp_id,l_renewable_period_frequency,l_renewable_period_units;
             IF csr_get_renewable_period_units % FOUND then

              if(l_renewable_period_units='D') then
              --renewable unit is Day
                 p_active_days := l_renewable_period_frequency;

              elsif(l_renewable_period_units='H') then
              --renewable unit is Hour
                if(l_renewable_period_frequency <= 24 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/24);
                end if;

              elsif(l_renewable_period_units='M') then
              --renewable unit is Month
              p_active_days := l_renewable_period_frequency * 30;

              elsif(l_renewable_period_units='MIN') then
             --renewable unit is Minute
                if(l_renewable_period_frequency <= 1440 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/1440);
                end if;

              elsif(l_renewable_period_units='Q') then
             --renewable unit is Quarter Hour
              if(l_renewable_period_frequency <= 96 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/96);
                end if;

              elsif(l_renewable_period_units='W') then
              --renewable unit is Week
                p_active_days := l_renewable_period_frequency * 7;

              elsif(l_renewable_period_units='Y') then
              --renewable unit is Year
                p_active_days := l_renewable_period_frequency * 365;
              end if;

              l_end_date:= l_start_date+round(p_active_days);--	bug8410988
              l_eff_date_to := to_char(l_end_date,g_date_format);


              CLOSE csr_get_renewable_period_units;
             ELSE
                 CLOSE csr_get_renewable_period_units;
             END IF;


            end if;



		ELSE
			p_comp_ids := p_comp_ids || '^' || crs_comp_rec.CompetenceId;
			p_level_ids := p_level_ids || '^' || crs_comp_rec.LevelId;
			--l_eff_date_from :=l_eff_date_from || '^' ||to_char(get_competence_eff_date(p_comp_id=> crs_comp_rec.CompetenceId,p_id=>p_event_id,p_obj_type=>'COURSE' ),g_date_format)	;
			p_active_days := 0;
			l_start_date := get_competence_eff_date(p_comp_id=> crs_comp_rec.CompetenceId,p_id=>p_event_id, p_obj_type=>'COURSE');
            l_eff_date_from :=l_eff_date_from || '^' ||to_char(l_start_date,g_date_format)	;


            if(allow_comp_renewal_period = 'Y') then
             OPEN csr_get_renewable_period_units(crs_comp_rec.CompetenceId);
             FETCH  csr_get_renewable_period_units into l_comp_id,l_renewable_period_frequency,l_renewable_period_units;
             IF csr_get_renewable_period_units % FOUND then

              if(l_renewable_period_units='D') then
              --renewable unit is Day
                 p_active_days := l_renewable_period_frequency;

              elsif(l_renewable_period_units='H') then
              --renewable unit is Hour
                if(l_renewable_period_frequency <= 24 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/24);
                end if;

              elsif(l_renewable_period_units='M') then
              --renewable unit is Month
              p_active_days := l_renewable_period_frequency * 30;

              elsif(l_renewable_period_units='MIN') then
             --renewable unit is Minute
                if(l_renewable_period_frequency <= 1440 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/1440);
                end if;

              elsif(l_renewable_period_units='Q') then
             --renewable unit is Quarter Hour
              if(l_renewable_period_frequency <= 96 ) then
                p_active_days := 0;
                else
                p_active_days := (l_renewable_period_frequency/96);
                end if;

              elsif(l_renewable_period_units='W') then
              --renewable unit is Week
                p_active_days := l_renewable_period_frequency * 7;

              elsif(l_renewable_period_units='Y') then
              --renewable unit is Year
                p_active_days := l_renewable_period_frequency * 365;
              end if;

              l_end_date:= l_start_date+round(p_active_days);--	bug8410988
              l_eff_date_to :=l_eff_date_to || '^' ||to_char(l_end_date,g_date_format)	;

              CLOSE csr_get_renewable_period_units;
             ELSE
             --no/non-seeded duration units specified for the competence
             l_eff_date_to :=l_eff_date_to || '^' ||NULL;
               CLOSE csr_get_renewable_period_units;
             END IF;

            end if;
		END IF;
	END LOOP;
  END IF;

	IF l_learning_path_ids IS NOT NULL THEN
    hr_utility.set_location('Entering:'||l_proc, 15);
		/* LOOP
		       l_rightpos := INSTR(p_learning_path_ids,'^',1,l_count);
		        IF l_rightpos = 0 THEN
				 l_learning_path_id := to_number(SUBSTR(l_learning_path_ids,l_leftpos,length(p_learning_path_ids) - l_leftpos +1));
			ELSE
				l_learning_path_id := to_number(SUBSTR(l_learning_path_ids,l_leftpos,l_rightpos - l_leftpos));
			END IF;
			l_leftpos := l_rightpos + 1;
			l_count := l_count +1; */

            l_learning_path_id := to_number(l_learning_path_ids);
            hr_utility.trace ('l_learning_path_id ' ||l_learning_path_id);
			FOR lps_comp_rec IN csr_get_lp_comps LOOP
            hr_utility.set_location('Entering:'||l_proc, 20);
				IF p_comp_ids IS NULL OR p_comp_ids = '' THEN
                hr_utility.set_location('Entering:'||l_proc, 25);
					p_comp_ids :=  lps_comp_rec.CompetenceId;
					p_level_ids   :=  lps_comp_rec.LevelId;
                    hr_utility.set_location('Entering:'||l_proc, 35);
                    l_eff_date_from := to_char(get_competence_eff_date(p_comp_id=> lps_comp_rec.CompetenceId,p_id=>l_learning_path_id,p_obj_type=>'LP'),g_date_format)	;
				hr_utility.set_location('Entering:'||l_proc, 45);

                ELSE
					p_comp_ids := p_comp_ids || '^' || lps_comp_rec.CompetenceId;
					p_level_ids := p_level_ids || '^' || lps_comp_rec.LevelId;
                    l_eff_date_from :=l_eff_date_from || '^' ||to_char(get_competence_eff_date(p_comp_id=> lps_comp_rec.CompetenceId,p_id=>l_learning_path_id,p_obj_type=>'LP'),g_date_format)	;

				END IF;
		END LOOP;
			-- dbms_output.put_line('Learning Path Id ' || l_learning_path_id);
        --    EXIT WHEN l_rightpos = 0;
		--END LOOP;
	END IF;

	IF p_certification_id IS not NULL THEN ---Batra to revisst ***************888888

	open get_cert_expiry;
	fetch get_cert_expiry into l_expiry_date;
	close get_cert_expiry;



	FOR crs_cert_rec IN csr_get_cert_comps LOOP
		IF p_comp_ids IS NULL OR p_comp_ids = '' THEN
			p_comp_ids :=  crs_cert_rec.CompetenceId;
			p_level_ids   :=  crs_cert_rec.LevelId;
            l_eff_date_from := to_char(trunc(sysdate),g_date_format);
            if l_expiry_date is not null then
                l_eff_date_to := to_char(l_expiry_date,g_date_format );
            end if;
		ELSE
			p_comp_ids := p_comp_ids || '^' || crs_cert_rec.CompetenceId;
			p_level_ids := p_level_ids || '^' || crs_cert_rec.LevelId;
			-- start date would be the date certification is completed
            l_eff_date_from :=l_eff_date_from || '^' ||to_char(trunc(sysdate),g_date_format);
            if l_expiry_date is not null then
                l_eff_date_to := l_eff_date_to || '^' ||to_char(l_expiry_date,g_date_format );
            end if;
		END IF;
	END LOOP;
  END IF;
    p_eff_date_from :=l_eff_date_from;
    p_eff_date_to := l_eff_date_to;

    hr_utility.set_location('Leaving:'||l_proc, 5);

Exception

    when others then
    raise;

END comp_retreive;


end ota_Competence_ss;



/
