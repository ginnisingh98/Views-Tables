--------------------------------------------------------
--  DDL for Package Body OTA_LEARNER_ENROLL_REVIEW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LEARNER_ENROLL_REVIEW_SS" AS
 /* $Header: otlnrrev.pkb 120.12.12010000.5 2009/10/30 06:23:07 pekasi ship $*/

   g_package      varchar2(30)   := 'OTA_LEARNER_ENROLL_REVIEW_SS';

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



BEGIN
hr_utility.set_location('ENTERING get_approval_req', 10);
	IF (funcmode='RUN') THEN




     l_item_value := wf_engine.getItemAttrText(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'HR_RUNTIME_APPROVAL_REQ_FLAG');



              if l_item_value = 'NO' then

                   resultout:='COMPLETE:N';


               else

                   resultout:='COMPLETE:Y';


              end if;
        hr_utility.trace('l_resultout' || resultout);

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


  procedure save_add_enroll_detail(
      p_login_person_id     NUMBER default null
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_eventid                       in     VARCHAR2
    , p_activityversionid             in     VARCHAR2
    , p_specialInstruction            in     VARCHAR2
    , p_keyflexId                     in     VARCHAR2
    , p_businessGroupId               in     VARCHAR2
    , p_assignmentId                  in     VARCHAR2
    , p_organizationId                in     VARCHAR2
    , p_from                          in     VARCHAR2
    , p_tdb_information_category            in varchar2     default null
    , p_tdb_information1                    in varchar2     default null
    , p_tdb_information2                    in varchar2     default null
    , p_tdb_information3                    in varchar2     default null
    , p_tdb_information4                    in varchar2     default null
    , p_tdb_information5                    in varchar2     default null
    , p_tdb_information6                    in varchar2     default null
    , p_tdb_information7                    in varchar2     default null
    , p_tdb_information8                    in varchar2     default null
    , p_tdb_information9                    in varchar2     default null
    , p_tdb_information10                   in varchar2     default null
    , p_tdb_information11                   in varchar2     default null
    , p_tdb_information12                   in varchar2     default null
    , p_tdb_information13                   in varchar2     default null
    , p_tdb_information14                   in varchar2     default null
    , p_tdb_information15                   in varchar2     default null
    , p_tdb_information16                   in varchar2     default null
    , p_tdb_information17                   in varchar2     default null
    , p_tdb_information18                   in varchar2     default null
    , p_tdb_information19                   in varchar2     default null
    , p_tdb_information20                   in varchar2     default null
    , p_delegate_person_id                  in NUMBER       default null
    , p_ccselectiontext                     in varchar2     default null
    , p_offering_id                         in VARCHAR2
    ,p_booking_justification_id IN VARCHAR2 default null
)
  as

  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table          hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_message_number             VARCHAR2(10);
  l_result                     varchar2(100) default null;
  l_old_transaction_step_id    number;
  l_old_object_version_number  number;

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
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  END IF;

  --
  -- Delete transaction step if exist
  --

  if (hr_transaction_api.transaction_step_exist  (p_item_type => p_item_type
			     			 ,p_item_key => p_item_key
			     			 ,p_activity_id => p_activity_id) )  then

      hr_transaction_api.get_transaction_step_info(p_item_type             => p_item_type
						  ,p_item_key              => p_item_key
 						  ,p_activity_id           => p_activity_id
 						  ,p_transaction_step_id   => l_old_transaction_step_id
 						  ,p_object_version_number => l_old_object_version_number);


      hr_transaction_api.delete_transaction_step(p_validate                    => false
        					,p_transaction_step_id         => l_old_transaction_step_id
        					,p_person_id                   => p_login_person_id
       						,p_object_version_number       => l_old_object_version_number);

  end if;

  --
  -- Create a transaction step
  --
  hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || '.PROCESS_API2'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);


  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_EVENTID';
  l_transaction_table(l_count).param_value := p_eventid;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTIVITYVERSIONID';
  l_transaction_table(l_count).param_value := p_activityversionid;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SPECIALINSTRUCTION';
  l_transaction_table(l_count).param_value := p_specialInstruction;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_KEYFLEXID';
  l_transaction_table(l_count).param_value := p_keyflexId;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESSGROUPID';
  l_transaction_table(l_count).param_value := p_businessGroupId;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASSIGNMENTID';
  l_transaction_table(l_count).param_value := p_assignmentId;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ORGANIZATIONID';
  l_transaction_table(l_count).param_value := p_organizationId;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROM';
  l_transaction_table(l_count).param_value := p_from;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION_CATEGORY';
  l_transaction_table(l_count).param_value := p_tdb_information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION1';
  l_transaction_table(l_count).param_value := p_tdb_information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION2';
  l_transaction_table(l_count).param_value := p_tdb_information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION3';
  l_transaction_table(l_count).param_value := p_tdb_information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION4';
  l_transaction_table(l_count).param_value := p_tdb_information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION5';
  l_transaction_table(l_count).param_value := p_tdb_information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION6';
  l_transaction_table(l_count).param_value := p_tdb_information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION7';
  l_transaction_table(l_count).param_value := p_tdb_information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION8';
  l_transaction_table(l_count).param_value := p_tdb_information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION9';
  l_transaction_table(l_count).param_value := p_tdb_information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION10';
  l_transaction_table(l_count).param_value := p_tdb_information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION11';
  l_transaction_table(l_count).param_value := p_tdb_information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION12';
  l_transaction_table(l_count).param_value := p_tdb_information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION13';
  l_transaction_table(l_count).param_value := p_tdb_information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION14';
  l_transaction_table(l_count).param_value := p_tdb_information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION15';
  l_transaction_table(l_count).param_value := p_tdb_information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION16';
  l_transaction_table(l_count).param_value := p_tdb_information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION17';
  l_transaction_table(l_count).param_value := p_tdb_information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION18';
  l_transaction_table(l_count).param_value := p_tdb_information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION19';
  l_transaction_table(l_count).param_value := p_tdb_information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TDB_INFORMATION20';
  l_transaction_table(l_count).param_value := p_tdb_information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DELEGATE_PERSON_ID';
  l_transaction_table(l_count).param_value := p_delegate_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CCSELECTIONTEXT';
  l_transaction_table(l_count).param_value := p_ccselectiontext;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OFFERING_ID';
  l_transaction_table(l_count).param_value := p_offering_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BKNG_JUSTIFICATION_ID';
  l_transaction_table(l_count).param_value := p_booking_justification_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => p_item_type
      ,p_item_key   => p_item_key
      ,p_name   => 'OTA_TRANSACTION_STEP_ID');

  WF_ENGINE.setitemattrnumber(p_item_type,
                              p_item_key,
                              'OTA_TRANSACTION_STEP_ID',
                              l_transaction_step_id);


  If p_from='REVIEW' Then
      hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => p_item_type
		      ,p_item_key   => p_item_key
		      ,p_name       => 'OTA_EVENT_ID');

      WF_ENGINE.setitemattrnumber(p_item_type,
  			          p_item_key,
			          'OTA_EVENT_ID',
				  p_eventid);

-- bug 4146681
WF_ENGINE.setitemattrtext(p_item_type,
                              p_item_key,
                              'HR_RESTRICT_EDIT_ATTR',
                              'Y');
--bug 4146681

  End If;

  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API2'
                ,p_transaction_data => l_transaction_table);


  EXCEPTION
  WHEN hr_utility.hr_error THEN
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
         END IF;
  WHEN OTHERS THEN
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

 end save_add_enroll_detail;




PROCEDURE get_add_enr_dtl_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_add_enroll_detail_data          out nocopy varchar2
) is


   l_trans_rec_count                  integer default 0;
   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   ln_index                           number  default 0;
   l_trans_step_rows                  NUMBER  ;
   l_add_enroll_detail_data           varchar2(4000);
l_trans_step_id number;


 BEGIN

         hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);


              get_add_enr_dtl_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
--                 p_transaction_step_id            => l_trans_step_id
                ,p_add_enroll_detail_data         => l_add_enroll_detail_data);


              p_add_enroll_detail_data := l_add_enroll_detail_data;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_add_enr_dtl_data_from_tt;


procedure get_add_enr_dtl_data_from_tt
   (p_transaction_step_id             in  number
   ,p_add_enroll_detail_data          out nocopy varchar2
)
is

 l_eventid                  ota_events.event_id%TYPE;
 l_activityversionid        ota_events.ACTIVITY_VERSION_ID%TYPE;
-- l_costAlocationKeyflexId   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_specialInstruction       ota_delegate_bookings.SPECIAL_BOOKING_INSTRUCTIONS%TYPE;
 l_keyflexid                pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_businessgroupid          ota_delegate_bookings.BUSINESS_GROUP_ID%TYPE;
 l_assignmentid             per_all_assignments.ASSIGNMENT_ID%TYPE;
 l_organizationid           ota_delegate_bookings.ORGANIZATION_ID%TYPE;
 l_tdb_information_category ota_delegate_bookings.TDB_INFORMATION_CATEGORY%TYPE;
 l_tdb_information1         ota_delegate_bookings.TDB_INFORMATION1%TYPE;
 l_tdb_information2         ota_delegate_bookings.TDB_INFORMATION2%TYPE;
 l_tdb_information3         ota_delegate_bookings.TDB_INFORMATION3%TYPE;
 l_tdb_information4         ota_delegate_bookings.TDB_INFORMATION4%TYPE;
 l_tdb_information5         ota_delegate_bookings.TDB_INFORMATION5%TYPE;
 l_tdb_information6         ota_delegate_bookings.TDB_INFORMATION6%TYPE;
 l_tdb_information7         ota_delegate_bookings.TDB_INFORMATION7%TYPE;
 l_tdb_information8         ota_delegate_bookings.TDB_INFORMATION8%TYPE;
 l_tdb_information9         ota_delegate_bookings.TDB_INFORMATION9%TYPE;
 l_tdb_information10        ota_delegate_bookings.TDB_INFORMATION10%TYPE;
 l_tdb_information11        ota_delegate_bookings.TDB_INFORMATION11%TYPE;
 l_tdb_information12        ota_delegate_bookings.TDB_INFORMATION12%TYPE;
 l_tdb_information13        ota_delegate_bookings.TDB_INFORMATION13%TYPE;
 l_tdb_information14        ota_delegate_bookings.TDB_INFORMATION14%TYPE;
 l_tdb_information15        ota_delegate_bookings.TDB_INFORMATION15%TYPE;
 l_tdb_information16        ota_delegate_bookings.TDB_INFORMATION16%TYPE;
 l_tdb_information17        ota_delegate_bookings.TDB_INFORMATION17%TYPE;
 l_tdb_information18        ota_delegate_bookings.TDB_INFORMATION18%TYPE;
 l_tdb_information19        ota_delegate_bookings.TDB_INFORMATION19%TYPE;
 l_tdb_information20        ota_delegate_bookings.TDB_INFORMATION20%TYPE;
 l_offering_id              ota_offerings.offering_id%TYPE;
 l_booking_justification_id ota_bkng_justifications_b.booking_justification_id%TYPE;
 l_booking_justification ota_bkng_justifications_tl.justification_text%TYPE;
begin


  l_eventid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EVENTID');

  l_activityversionid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVITYVERSIONID');

  l_specialInstruction := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SPECIALINSTRUCTION');

  l_keyflexid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_KEYFLEXID');

  l_businessgroupid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESSGROUPID');

  l_assignmentid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENTID');

  l_organizationid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ORGANIZATIONID');

  l_tdb_information_category := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION_CATEGORY');

  l_tdb_information1  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION1');

  l_tdb_information2  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION2');

  l_tdb_information3  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION3');

  l_tdb_information4  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION4');

  l_tdb_information5  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION5');

  l_tdb_information6  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION6');

  l_tdb_information7  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION7');

  l_tdb_information8  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION8');

  l_tdb_information9  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION9');

  l_tdb_information10  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION10');

  l_tdb_information11  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION11');

  l_tdb_information12  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION12');

  l_tdb_information13  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION13');

  l_tdb_information14  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION14');

  l_tdb_information15  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION15');

  l_tdb_information16  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION16');

  l_tdb_information17  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION17');

  l_tdb_information18  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION18');

  l_tdb_information19  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION19');

  l_tdb_information20  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION20');

  l_offering_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OFFERING_ID');

    l_booking_justification_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BKNG_JUSTIFICATION_ID');

    IF l_booking_justification_id IS NOT NULL THEN
	OPEN csr_get_booking_justification(l_booking_justification_id);
	FETCH csr_get_booking_justification INTO l_booking_justification;
	CLOSE csr_get_booking_justification;
   END IF;


--
-- Now string all the retreived items into p_add_enroll_detail_data

--

p_add_enroll_detail_data := nvl(l_eventid,0)
                           ||'^'||nvl(l_activityversionid,0)
                           ||'^'||nvl(l_specialInstruction,'null')
                           ||'^'||nvl(l_keyflexid,0)
                           ||'^'||nvl(l_businessgroupid,0)
                           ||'^'||nvl(l_assignmentid,0)
                           ||'^'||nvl(l_organizationid,0)
                           ||'^'||nvl(l_tdb_information_category,'null')
                           ||'^'||nvl(l_tdb_information1,'null')
                           ||'^'||nvl(l_tdb_information2,'null')
                           ||'^'||nvl(l_tdb_information3,'null')
                           ||'^'||nvl(l_tdb_information4,'null')
                           ||'^'||nvl(l_tdb_information5,'null')
                           ||'^'||nvl(l_tdb_information6,'null')
                           ||'^'||nvl(l_tdb_information7,'null')
                           ||'^'||nvl(l_tdb_information8,'null')
                           ||'^'||nvl(l_tdb_information9,'null')
                           ||'^'||nvl(l_tdb_information10,'null')
                           ||'^'||nvl(l_tdb_information11,'null')
                           ||'^'||nvl(l_tdb_information12,'null')
                           ||'^'||nvl(l_tdb_information13,'null')
                           ||'^'||nvl(l_tdb_information14,'null')
                           ||'^'||nvl(l_tdb_information15,'null')
                           ||'^'||nvl(l_tdb_information16,'null')
                           ||'^'||nvl(l_tdb_information17,'null')
                           ||'^'||nvl(l_tdb_information18,'null')
                           ||'^'||nvl(l_tdb_information19,'null')
                           ||'^'||nvl(l_tdb_information20,'null')
                           ||'^'||nvl(l_offering_id,0)
			   ||'^'||nvl(l_booking_justification,'null');


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_add_enr_dtl_data_from_tt;





PROCEDURE get_review_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_person_id                       out nocopy number
   ,p_review_data                     out nocopy varchar2
) is


   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   ln_index                           number  default 0;
   l_trans_step_rows                  NUMBER  ;
   l_review_data                      varchar2(4000);
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
                ,p_review_data                    => l_review_data);
/*
              get_review_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
                ,p_review_data                    => l_review_data);
*/

              p_review_data := l_review_data;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data_from_tt;



procedure get_review_data_from_tt
   (p_transaction_step_id             in  number
   ,p_review_data                     out nocopy varchar2
)
is

 l_eventid                  ota_events.event_id%TYPE;
 l_specialInstruction       ota_delegate_bookings.SPECIAL_BOOKING_INSTRUCTIONS%TYPE;
 l_keyflexid                pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_ccselectiontext          varchar2(2000);
 l_tdb_information_category ota_delegate_bookings.TDB_INFORMATION_CATEGORY%TYPE;
 l_tdb_information1         ota_delegate_bookings.TDB_INFORMATION1%TYPE;
 l_tdb_information2         ota_delegate_bookings.TDB_INFORMATION2%TYPE;
 l_tdb_information3         ota_delegate_bookings.TDB_INFORMATION3%TYPE;
 l_tdb_information4         ota_delegate_bookings.TDB_INFORMATION4%TYPE;
 l_tdb_information5         ota_delegate_bookings.TDB_INFORMATION5%TYPE;
 l_tdb_information6         ota_delegate_bookings.TDB_INFORMATION6%TYPE;
 l_tdb_information7         ota_delegate_bookings.TDB_INFORMATION7%TYPE;
 l_tdb_information8         ota_delegate_bookings.TDB_INFORMATION8%TYPE;
 l_tdb_information9         ota_delegate_bookings.TDB_INFORMATION9%TYPE;
 l_tdb_information10        ota_delegate_bookings.TDB_INFORMATION10%TYPE;
 l_tdb_information11        ota_delegate_bookings.TDB_INFORMATION11%TYPE;
 l_tdb_information12        ota_delegate_bookings.TDB_INFORMATION12%TYPE;
 l_tdb_information13        ota_delegate_bookings.TDB_INFORMATION13%TYPE;
 l_tdb_information14        ota_delegate_bookings.TDB_INFORMATION14%TYPE;
 l_tdb_information15        ota_delegate_bookings.TDB_INFORMATION15%TYPE;
 l_tdb_information16        ota_delegate_bookings.TDB_INFORMATION16%TYPE;
 l_tdb_information17        ota_delegate_bookings.TDB_INFORMATION17%TYPE;
 l_tdb_information18        ota_delegate_bookings.TDB_INFORMATION18%TYPE;
 l_tdb_information19        ota_delegate_bookings.TDB_INFORMATION19%TYPE;
 l_tdb_information20        ota_delegate_bookings.TDB_INFORMATION20%TYPE;
 l_trnorgnames              varchar2(2000);
 l_offering_id              ota_offerings.offering_id%TYPE;
 l_booking_justification_id ota_bkng_justifications_b.booking_justification_id%TYPE;
 l_booking_justification ota_bkng_justifications_tl.justification_text%TYPE;

begin


  l_eventid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EVENTID');


  l_specialInstruction := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SPECIALINSTRUCTION');

/*  l_keyflexid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_KEYFLEXID');    */

  l_ccselectiontext := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CCSELECTIONTEXT');

   l_tdb_information_category := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION_CATEGORY');

  l_tdb_information1  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION1');

  l_tdb_information2  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION2');

  l_tdb_information3  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION3');

  l_tdb_information4  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION4');

  l_tdb_information5  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION5');

  l_tdb_information6  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION6');

  l_tdb_information7  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION7');

  l_tdb_information8  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION8');

  l_tdb_information9  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION9');

  l_tdb_information10  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION10');

  l_tdb_information11  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION11');

  l_tdb_information12  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION12');

  l_tdb_information13  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION13');

  l_tdb_information14  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION14');

  l_tdb_information15  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION15');

  l_tdb_information16  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION16');

  l_tdb_information17  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION17');

  l_tdb_information18  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION18');

  l_tdb_information19  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION19');

  l_tdb_information20  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TDB_INFORMATION20');

  l_trnorgnames := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNORGNAMES');

  l_offering_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OFFERING_ID');

  l_booking_justification_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BKNG_JUSTIFICATION_ID');

        IF l_booking_justification_id IS NOT NULL THEN
	OPEN csr_get_booking_justification(l_booking_justification_id);
	FETCH csr_get_booking_justification INTO l_booking_justification;
	CLOSE csr_get_booking_justification;
   END IF;

--
-- Now string all the retreived items into p_review_data

--

--p_review_data := nvl(l_eventid,0)||'^'||nvl(l_specialInstruction,'null')||'^'||nvl(l_keyflexid,0);
--Bug#2381073   hdshah initialize with space instead of 0 if l_ccselectiontext is null
--p_review_data := nvl(l_eventid,0)||'^'||nvl(l_specialInstruction,'null')||'^'||nvl(l_ccselectiontext,0);
p_review_data := nvl(l_eventid,0)
                           ||'^'||nvl(l_specialInstruction,'null')
                           ||'^'||nvl(l_ccselectiontext,' ')
                           ||'^'||nvl(l_tdb_information_category,'null')
                           ||'^'||nvl(l_tdb_information1,'null')
                           ||'^'||nvl(l_tdb_information2,'null')
                           ||'^'||nvl(l_tdb_information3,'null')
                           ||'^'||nvl(l_tdb_information4,'null')
                           ||'^'||nvl(l_tdb_information5,'null')
                           ||'^'||nvl(l_tdb_information6,'null')
                           ||'^'||nvl(l_tdb_information7,'null')
                           ||'^'||nvl(l_tdb_information8,'null')
                           ||'^'||nvl(l_tdb_information9,'null')
                           ||'^'||nvl(l_tdb_information10,'null')
                           ||'^'||nvl(l_tdb_information11,'null')
                           ||'^'||nvl(l_tdb_information12,'null')
                           ||'^'||nvl(l_tdb_information13,'null')
                           ||'^'||nvl(l_tdb_information14,'null')
                           ||'^'||nvl(l_tdb_information15,'null')
                           ||'^'||nvl(l_tdb_information16,'null')
                           ||'^'||nvl(l_tdb_information17,'null')
                           ||'^'||nvl(l_tdb_information18,'null')
                           ||'^'||nvl(l_tdb_information19,'null')
                           ||'^'||nvl(l_tdb_information20,'null')
                           ||'^'||nvl(l_trnorgnames,'null')
                           ||'^'||nvl(l_offering_id,0)
			   ||'^'||nvl(l_booking_justification, 'null');


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data_from_tt;




PROCEDURE process_api
        (p_validate IN BOOLEAN,p_transaction_step_id IN NUMBER) IS
BEGIN

-- validation for search page.
null;


END process_api;




PROCEDURE process_api2
        (p_validate IN BOOLEAN,p_transaction_step_id IN NUMBER
,p_effective_date in varchar2) IS

  l_booking_id			OTA_DELEGATE_BOOKINGS.booking_id%type := null;
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_delegate_id		        PER_PEOPLE_F.person_id%TYPE;
  l_eventid                     ota_events.event_id%TYPE;
  l_object_version_number	number;
  l_person_details		OTA_LEARNER_ENROLL_SS.csr_person_to_enroll_details%ROWTYPE;
  l_specialInstruction          ota_delegate_bookings.SPECIAL_BOOKING_INSTRUCTIONS%TYPE;
  l_finance_line_id		OTA_FINANCE_LINES.finance_line_id%type:= null;
  l_item_type                   HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
  l_item_key                    HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
  l_activity_id                 HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;
  l_transaction_step_id         HR_API_TRANSACTION_STEPS.TRANSACTION_STEP_ID%TYPE;
  l_transaction_table           hr_transaction_ss.transaction_table;
  l_from                        varchar2(15);
  l_cancel_boolean              BOOLEAN;
  l_auto_create_finance		VARCHAR2(40);
  l_price_basis                 OTA_EVENTS.price_basis%TYPE;
  l_business_group_id_from      PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE;
  l_business_group_id_to        hr_all_organization_units.organization_id%type;
  l_assignment_id               PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE;
  l_organization_id             PER_ALL_ASSIGNMENTS_F.organization_id%TYPE;
  l_user			NUMBER;
  fapi_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  fapi_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;
  fapi_result			VARCHAR2(40);
  fapi_from			VARCHAR2(5);
  fapi_to			VARCHAR2(5);
  l_sponsor_organization_id     hr_all_organization_units.organization_id%type;
  l_event_currency_code         ota_events.currency_code%type;
  l_event_status                ota_events.event_status%type;
  l_cost_allocation_keyflex_id  VARCHAR2(1000);
  l_maximum_internal_attendees  NUMBER;
  l_existing_internal           NUMBER;
  l_maximum_internal_allowed    NUMBER;
  l_automatic_transfer_gl	VARCHAR2(40);
  result_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  result_create_finance_line 	VARCHAR2(5) := 'Y';
  result_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;
  l_offering_id                 ota_events.offering_id%type;
  l_date_booking_placed         date;
  l_current_date                date;
  l_restricted_assignment_id    PER_ASSIGNMENTS_F.assignment_id%type;
  l_version_name 		ota_activity_versions.version_name%type;
  l_owner_username 		fnd_user.user_name%type;
  l_owner_id  			ota_events.owner_id%type;
  l_activity_version_id 	ota_activity_versions.activity_version_id%type;
  l_event_title   		ota_events.title%type;
  l_course_start_date 		ota_events.course_start_date%type;
  l_course_start_time 		ota_events.course_start_time%type;
  l_course_end_date 		ota_events.course_end_date%type;
  l_delivery_mode 		    ota_category_usages_tl.category%type;
  l_event_location          hr_locations_all.location_code%TYPE;

  l_notification_text		VARCHAR2(1000);
  l_business_group_name		PER_BUSINESS_GROUPS.name%TYPE := null;

  l_business_group_id           ota_events.business_group_id%type;
  l_standard_price              ota_events.standard_price%type;

 l_tdb_information_category ota_delegate_bookings.TDB_INFORMATION_CATEGORY%TYPE;
 l_tdb_information1         ota_delegate_bookings.TDB_INFORMATION1%TYPE;
 l_tdb_information2         ota_delegate_bookings.TDB_INFORMATION2%TYPE;
 l_tdb_information3         ota_delegate_bookings.TDB_INFORMATION3%TYPE;
 l_tdb_information4         ota_delegate_bookings.TDB_INFORMATION4%TYPE;
 l_tdb_information5         ota_delegate_bookings.TDB_INFORMATION5%TYPE;
 l_tdb_information6         ota_delegate_bookings.TDB_INFORMATION6%TYPE;
 l_tdb_information7         ota_delegate_bookings.TDB_INFORMATION7%TYPE;
 l_tdb_information8         ota_delegate_bookings.TDB_INFORMATION8%TYPE;
 l_tdb_information9         ota_delegate_bookings.TDB_INFORMATION9%TYPE;
 l_tdb_information10        ota_delegate_bookings.TDB_INFORMATION10%TYPE;
 l_tdb_information11        ota_delegate_bookings.TDB_INFORMATION11%TYPE;
 l_tdb_information12        ota_delegate_bookings.TDB_INFORMATION12%TYPE;
 l_tdb_information13        ota_delegate_bookings.TDB_INFORMATION13%TYPE;
 l_tdb_information14        ota_delegate_bookings.TDB_INFORMATION14%TYPE;
 l_tdb_information15        ota_delegate_bookings.TDB_INFORMATION15%TYPE;
 l_tdb_information16        ota_delegate_bookings.TDB_INFORMATION16%TYPE;
 l_tdb_information17        ota_delegate_bookings.TDB_INFORMATION17%TYPE;
 l_tdb_information18        ota_delegate_bookings.TDB_INFORMATION18%TYPE;
 l_tdb_information19        ota_delegate_bookings.TDB_INFORMATION19%TYPE;
 l_tdb_information20        ota_delegate_bookings.TDB_INFORMATION20%TYPE;

 l_booking_justification_id ota_bkng_justifications_b.booking_justification_id%TYPE;
 l_priority_level ota_delegate_bookings.booking_priority%TYPE;

 l_timezone  fnd_timezones_tl.name%TYPE;
 l_course_end_time 		ota_events.course_start_time%type;
 status_not_seeded          exception;


CURSOR bg_to (l_event_id	ota_events.event_id%TYPE) IS
SELECT hao.business_group_id,
       evt.organization_id,
       evt.currency_code,
       evt.offering_id,
       evt.owner_id,
       ofr.activity_version_id,
       evt.Title,
       evt.course_start_date,
       evt.course_end_date,
       evt.business_group_id bg_id,
       evt.course_start_time,
       Ctl.Category,
-- Modified for bug 3389890 as usage of inline query in CURSOR is not supported in 8.1.7
--       (Select Category from ota_category_usages_tl where Category_Usage_Id = ofr.Delivery_Mode_Id
--        and Language = userenv('LANG')) Delivery_Mode,
        ota_general.get_location_code(ota_utility.get_event_location(evt.event_id)) Location_Name,
	ota_timezone_util.get_timezone_name(evt.timezone) timezone,
	evt.course_end_time
FROM   OTA_EVENTS_VL    evt,
       OTA_OFFERINGS    ofr,
       OTA_CATEGORY_USAGES_TL ctl,
       HR_ALL_ORGANIZATION_UNITS hao
WHERE  evt.event_id = l_eventid
AND    evt.parent_offering_id = ofr.offering_id
AND    evt.organization_id = hao.organization_id (+)
AND    ctl.Category_usage_id = ofr.delivery_mode_id
AND    ctl.language = userenv('LANG') ;


--Bug#2221320 hdshah standard price included.
Cursor Get_Event_status is
Select event_status, maximum_internal_attendees,nvl(price_basis,NULL),standard_price
from   OTA_EVENTS
WHERE  EVENT_ID = l_eventid;

CURSOR get_existing_internal IS
SELECT count(*)
FROM   OTA_DELEGATE_BOOKINGS dbt,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  dbt.event_id = l_eventid
AND    dbt.internal_booking_flag = 'Y'
AND    dbt.booking_status_type_id = bst.booking_status_type_id
AND    bst.type in ('P','A','E');


CURSOR csr_chk_event
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER) IS
SELECT ov.booking_id,
       ov.date_booking_placed,
       ov.object_version_number
FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
WHERE  ov.event_id = p_event_id
AND    ov.delegate_person_id = p_person_id
AND    os.booking_status_type_id = ov.booking_status_type_id
AND    os.type = 'R';

CURSOR csr_activity(p_activity_version_id number )
IS
SELECT version_name
FROM OTA_ACTIVITY_VERSIONS_TL
WHERE activity_version_id = p_activity_version_id
AND language=userenv('LANG');



CURSOR csr_user(p_owner_id in number) IS
SELECT
 USER_NAME
FROM
 FND_USER
WHERE
Employee_id = p_owner_id
AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892


CURSOR csr_get_priority_level(p_booking_justification_id IN VARCHAR2) IS
   select priority_level
   from ota_bkng_justifications_b
   where booking_justification_id = p_booking_justification_id;

BEGIN

        l_from := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_FROM');

         hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);

    if l_from = 'REVIEW' then  -- Create enrollment

      -- establish Savepoint
         SAVEPOINT validate_enrollment;

        l_eventid := TO_NUMBER(hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_EVENTID'));


-- hdshah Bug#2213380 read delegate_person_id from p_delegate_person_id instead of p_person_id
        l_delegate_id := TO_NUMBER(hr_transaction_api.get_number_Value
                (p_transaction_step_id => p_transaction_step_id
--                ,p_name                => 'P_PERSON_ID'));
                ,p_name                => 'P_DELEGATE_PERSON_ID'));


        l_specialInstruction := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_SPECIALINSTRUCTION');

        l_tdb_information_category := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION_CATEGORY');

        l_tdb_information1  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION1');

        l_tdb_information2  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION2');

        l_tdb_information3  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION3');

        l_tdb_information4  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION4');

        l_tdb_information5  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION5');

        l_tdb_information6  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION6');

        l_tdb_information7  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION7');

        l_tdb_information8  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION8');

        l_tdb_information9  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION9');

        l_tdb_information10  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION10');

        l_tdb_information11  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION11');

        l_tdb_information12  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION12');

        l_tdb_information13  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION13');

        l_tdb_information14  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION14');

        l_tdb_information15  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION15');

        l_tdb_information16  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION16');

        l_tdb_information17  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION17');

        l_tdb_information18  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION18');

        l_tdb_information19  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION19');

        l_tdb_information20  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TDB_INFORMATION20');

	l_booking_justification_id  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_BKNG_JUSTIFICATION_ID');

	 IF l_booking_justification_id IS NOT NULL THEN
	     OPEN csr_get_priority_level(l_booking_justification_id);
	     FETCH csr_get_priority_level INTO l_priority_level;
	     CLOSE csr_get_priority_level;
	  END IF;




        l_person_details := OTA_LEARNER_ENROLL_SS.Get_Person_To_Enroll_Details(p_person_id => l_delegate_id);

           IF l_person_details.full_name is not null then
                   WF_ENGINE.setitemattrtext(l_item_type,
                             		     l_item_key,
                                             'CURRENT_PERSON_DISPLAY_NAME',
                                             l_person_details.full_name);
           END IF;

        l_restricted_assignment_id := OTA_LEARNER_ENROLL_SS.CHK_DELEGATE_OK_FOR_EVENT(p_delegate_id => l_delegate_id
      	   			      			   				 ,p_event_id    => l_eventid);

           IF l_restricted_assignment_id IS NULL OR
               l_restricted_assignment_id = '-1' THEN
               NULL;
           ELSE
               l_person_details.assignment_id := l_restricted_assignment_id;
           END IF;



           OPEN  bg_to(l_eventid);
           FETCH bg_to INTO 	l_business_group_id_to,
                   		l_sponsor_organization_id,
                   		l_event_currency_code,
                                l_offering_id,
                                l_owner_id,
                                l_activity_version_id,
                                l_event_title,
				l_course_start_date,
				l_course_end_date,
				l_business_group_id,
                l_course_start_time,
                l_delivery_mode,
                l_event_location,l_timezone,l_course_end_time;

           CLOSE bg_to;

            For act in csr_activity(l_activity_version_id)
              Loop
                l_version_name := act.version_name;
              End Loop;


          if l_owner_id is not null then
             For owner in csr_user(l_owner_id)
             Loop
                l_owner_username := owner.user_name;
             End Loop;
          end if;


           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_ACTIVITY_VERSION_NAME',
                             l_version_name);


           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'EVENT_OWNER_EMAIL',
                             l_owner_username);


           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_EVENT_TITLE',
                             l_eventid);                 --Enh 5606090: Language support for Event Details.

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_course_start_date);


           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_END_DATE',
                            l_course_end_date);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_CLASS_START_TIME',
                            nvl(l_course_start_time,'00:00'));

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_DELIVERY_MODE_NAME',
                            l_delivery_mode);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_LOCATION_ADDRESS',
                            l_event_location);

     wf_engine.setItemAttrText(l_item_type,l_item_key,'STATE_LIST',l_timezone);

   /*  hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => l_item_type
		      ,p_item_key   => l_item_key
		      ,p_name       => 'OTA_CLASS_END_TIME');*/
     wf_engine.setItemAttrText(l_item_type,l_item_key,'PQH_EVENT_NAME',nvl(l_course_end_time,'23:59'));

           WF_ENGINE.setitemattrnumber(l_item_type,
                            l_item_key,
                            'TRANSACTION_ID',
--Bug#4617150
--                            hr_transaction_web.get_transaction_id
                            hr_transaction_ss.get_transaction_id
                                   (p_item_type => l_item_type
                                   ,p_item_key  => l_item_key));


           WF_ENGINE.setitemattrnumber(l_item_type,
                            l_item_key,
                            'FORWARD_FROM_PERSON_ID',
                            l_delegate_id);



        l_cancel_boolean := OTA_LEARNER_ENROLL_SS.Chk_Event_Cancelled_for_Person(p_event_id           => l_eventid
       							  ,p_delegate_person_id => l_delegate_id
                                  ,p_delegate_contact_id => null
       							  ,p_booking_id         => l_booking_id);

        IF (l_cancel_boolean) THEN
         -- Call Cancel procedure to cancel the Finance if person Re-enroll
          OTA_LEARNER_ENROLL_SS.cancel_finance(l_booking_id);
        END IF;


      l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web(
	 p_web_booking_status_type => 'REQUESTED'
        ,p_business_group_id 	   => l_business_group_id);

           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
                RAISE status_not_seeded;
           ELSE
               WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);
           END IF ;

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);



      select sysdate into l_current_date from dual;

     ota_tdb_api_ins2.Create_Enrollment( p_booking_id    		=>	l_booking_id
					,p_booking_status_type_id   	=>	l_booking_status_row.booking_status_type_id
      					,p_delegate_person_id       	=>	l_delegate_id
      					,p_contact_id               	=>	null
					,p_business_group_id        	=>	l_business_group_id
      					,p_event_id                 	=>	l_eventid
      					--,p_date_booking_placed     	=>	trunc(l_current_date)
					,p_date_booking_placed     	=>	l_current_date
      					,p_corespondent        		=> 	'S' --l_corespondent
      					,p_internal_booking_flag    	=> 	'Y'
					,p_person_address_type          =>      'I'
      					,p_number_of_places         	=> 	1
      					,p_object_version_number    	=> 	l_object_version_number
      					,p_delegate_contact_phone	=> 	l_person_details.work_telephone
     					,p_source_of_booking        	=> 	fnd_profile.value('OTA_DEFAULT_ENROLLMENT_SOURCE')   --Bug 5580960: removed hardcoding. Now Source of Booking will be decided by profile value OTA_DEFAULT_ENROLLMENT_SOURCE
      					,p_special_booking_instructions => 	l_specialInstruction
      					,p_successful_attendance_flag   => 	'N'
      					,p_finance_line_id          	=> 	l_finance_line_id
      					,p_enrollment_type          	=> 	'S'
					,p_validate               	=> 	FALSE
                                	,p_organization_id          	=> 	l_person_details.organization_id
      					,p_delegate_assignment_id   	=> 	l_person_details.assignment_id
 					,p_delegate_contact_email 	=> 	l_person_details.email_address
                                        ,p_tdb_information_category     =>	l_tdb_information_category
                                        ,p_tdb_information1             =>	l_tdb_information1
                                        ,p_tdb_information2             =>	l_tdb_information2
                                        ,p_tdb_information3             =>	l_tdb_information3
                                        ,p_tdb_information4             =>	l_tdb_information4
                                        ,p_tdb_information5             =>	l_tdb_information5
                                        ,p_tdb_information6             =>	l_tdb_information6
                                        ,p_tdb_information7             =>	l_tdb_information7
                                        ,p_tdb_information8             =>	l_tdb_information8
                                        ,p_tdb_information9             =>	l_tdb_information9
                                        ,p_tdb_information10            =>	l_tdb_information10
                                        ,p_tdb_information11            =>	l_tdb_information11
                                        ,p_tdb_information12            =>	l_tdb_information12
                                        ,p_tdb_information13            =>	l_tdb_information13
                                        ,p_tdb_information14            =>	l_tdb_information14
                                        ,p_tdb_information15            =>	l_tdb_information15
                                        ,p_tdb_information16            =>	l_tdb_information16
                                        ,p_tdb_information17            =>	l_tdb_information17
                                        ,p_tdb_information18            =>	l_tdb_information18
                                        ,p_tdb_information19            =>	l_tdb_information19
                                        ,p_tdb_information20            =>	l_tdb_information20
					,p_booking_justification_id => l_booking_justification_id
					,p_booking_priority               => l_priority_level
					,p_book_from => 'AME');


          if (p_validate = true) then
                 rollback to validate_enrollment;
          else

               l_auto_create_finance   := FND_PROFILE.value('OTA_AUTO_CREATE_FINANCE');
               l_automatic_transfer_gl := FND_PROFILE.value('OTA_SSHR_AUTO_GL_TRANSFER');
--               l_user 		       := FND_PROFILE.value('USER_ID');
               l_user 		       := fnd_global.user_id; -- Bug 3513140

               hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => l_item_type
                               ,p_item_key   => l_item_key
                               ,p_name   => 'OTA_AUTO_CREATE_FINANCE');

               WF_ENGINE.setitemattrtext(l_item_type,
                                           l_item_key,
                                           'OTA_AUTO_CREATE_FINANCE',
                                           l_auto_create_finance);

               hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => l_item_type
                               ,p_item_key   => l_item_key
                               ,p_name   => 'OTA_SSHR_AUTO_GL_TRANSFER');

               WF_ENGINE.setitemattrtext(l_item_type,
                                           l_item_key,
                                           'OTA_SSHR_AUTO_GL_TRANSFER',
                                           l_automatic_transfer_gl);

               hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => l_item_type
                               ,p_item_key   => l_item_key
                               ,p_name   => 'OTA_USER_ID');

               WF_ENGINE.setitemattrnumber(l_item_type,
                                           l_item_key,
                                           'OTA_USER_ID',
                                           l_user);


              WF_ENGINE.setitemattrtext(l_item_type,
                                        l_item_key,
                                        'BOOKING_ID',
                                        l_booking_id);

              -- update p_from in transaction table
                    update hr_api_transaction_values
                    set varchar2_value = 'APPROVE'
                    where transaction_step_id = p_transaction_step_id
                    and name = 'P_FROM';

              /*Bug#2258423 hdshah  Set wf item attribute for rejection */

              hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => l_item_type
                               ,p_item_key   => l_item_key
                               ,p_name   => 'OTA_EVENT_ID');

               WF_ENGINE.setitemattrnumber(l_item_type,
                                           l_item_key,
                                           'OTA_EVENT_ID',
                                           l_eventid);

               hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => l_item_type
                               ,p_item_key   => l_item_key
                               ,p_name   => 'OTA_DELEGATE_PERSON_ID');


               WF_ENGINE.setitemattrnumber(l_item_type,
                                           l_item_key,
                                           'OTA_DELEGATE_PERSON_ID',
                                           l_delegate_id);
               /*  End Set wf item attribute for rejection */

          end if;

     ELSIF l_from = 'APPROVE' then  -- update enrollment and create finance line if profile is set to YES

        l_eventid := TO_NUMBER(hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_EVENTID'));


        l_delegate_id := TO_NUMBER(hr_transaction_api.get_number_Value
                (p_transaction_step_id => p_transaction_step_id
                ,p_name                => 'P_DELEGATE_PERSON_ID'));



           l_auto_create_finance  :=  wf_engine.GetItemAttrtext(itemtype => l_item_type
			                                 ,itemkey  => l_item_key
			                                 ,aname    => 'OTA_AUTO_CREATE_FINANCE');


           l_automatic_transfer_gl  :=  wf_engine.GetItemAttrtext(itemtype => l_item_type
			                                 ,itemkey  => l_item_key
			                                 ,aname    => 'OTA_SSHR_AUTO_GL_TRANSFER');

           l_user  :=  wf_engine.GetItemAttrNumber(itemtype => l_item_type
			                                 ,itemkey  => l_item_key
			                                 ,aname    => 'OTA_USER_ID');

           OPEN  bg_to(l_eventid);
           FETCH bg_to INTO 	l_business_group_id_to,
                   		l_sponsor_organization_id,
                   		l_event_currency_code,
                                l_offering_id,
                                l_owner_id,
                                l_activity_version_id,
                                l_event_title,
				l_course_start_date,
				l_course_end_date,
				l_business_group_id,
                l_course_start_time,
                l_delivery_mode,
                l_event_location,l_timezone,l_course_end_time;

          CLOSE bg_to;

--Bug#2221320 hdshah l_standard_price included.
            OPEN  get_event_status;
            FETCH get_event_status into l_event_status, l_maximum_internal_attendees,l_price_basis,l_standard_price;
            CLOSE get_event_status;

            OPEN  get_existing_internal;
            FETCH get_existing_internal into l_existing_internal;
            CLOSE get_existing_internal;

            l_maximum_internal_allowed := nvl(l_maximum_internal_attendees,0) - l_existing_internal;


--Update enrollments to Waitlisted status for planned class
         IF l_event_status in ('F','P') THEN

            l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => l_business_group_id);
          /*ELSIF l_event_status in ('P') THEN

            l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => l_business_group_id);*/

          ELSIF l_event_status = 'N' THEN

            IF l_maximum_internal_attendees  is null then
               l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => l_business_group_id);

            ELSE

              IF l_maximum_internal_allowed > 0 THEN
                 l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => l_business_group_id);

              ELSIF l_maximum_internal_allowed <= 0  THEN
                    l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
       			(p_web_booking_status_type => 'WAITLISTED'
      			 ,p_business_group_id       => l_business_group_id);

              END IF;
            END IF;
         END IF;

           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
                RAISE status_not_seeded;
           ELSE
               WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);
           END IF ;

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);

           OPEN  csr_chk_event(l_eventid, l_delegate_id);
           FETCH csr_chk_event INTO l_booking_id,l_date_booking_placed,l_object_version_number;
           CLOSE csr_chk_event;

           select sysdate into l_current_date from dual;

	IF l_auto_create_finance = 'Y' and
           l_price_basis <> 'N' and
           l_event_currency_code is not null THEN

               l_cost_allocation_keyflex_id := TO_NUMBER(hr_transaction_api.get_varchar2_value
                                               (p_transaction_step_id => p_transaction_step_id
                                               ,p_name                => 'P_KEYFLEXID'));


               l_business_group_id_from := TO_NUMBER(hr_transaction_api.get_varchar2_value
                                               (p_transaction_step_id => p_transaction_step_id
                                               ,p_name                => 'P_BUSINESSGROUPID'));

               l_assignment_id := TO_NUMBER(hr_transaction_api.get_varchar2_value
                                               (p_transaction_step_id => p_transaction_step_id
                                               ,p_name                => 'P_ASSIGNMENTID'));

               l_organization_id := TO_NUMBER(hr_transaction_api.get_varchar2_value
                                               (p_transaction_step_id => p_transaction_step_id
                                               ,p_name                => 'P_ORGANIZATIONID'));

          fnd_message.set_name('OTA', 'OTA_443505_COST_CENTER_CHARGED');
		   l_notification_text     := fnd_message.get();

                 		Create_Segment(  	p_assignment_id		     	=>	l_assignment_id,
							p_business_group_id_from        =>	l_business_group_id_from,
							p_business_group_id_to	        =>	l_business_group_id_to,
							p_organization_id	     	=>	l_organization_id,
							p_sponsor_organization_id       =>	l_sponsor_organization_id,
							p_event_id		     	=>	l_eventid,
							p_person_id		     	=> 	l_delegate_id,
							p_currency_code		     	=>	l_event_currency_code,
							p_cost_allocation_keyflex_id    => 	l_cost_allocation_keyflex_id,
							p_user_id			=> 	l_user,
 							p_finance_header_id	     	=> 	fapi_finance_header_id,
							p_object_version_number	        => 	fapi_object_version_number,
							p_result		     	=> 	fapi_result,
							p_from_result		     	=> 	fapi_from,
							p_to_result		     	=> 	fapi_to,
                                                        p_auto_transfer                 =>      l_automatic_transfer_gl);

			IF fapi_result = 'S' THEN

				wf_engine.setItemAttrText (itemtype => l_item_type
						 	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_RESULT'
						  	  ,avalue   => fapi_result);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_FROM'
						  	  ,avalue   => fapi_from);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_TO'
						  	  ,avalue   => fapi_to);

				wf_engine.setItemAttrNumber(itemtype => l_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'EVENT_ID'
						  	   ,avalue   => l_eventid);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'BUSINESS_GROUP_NAME'
						  	   ,avalue   => l_business_group_name);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'NOTIFICATION_TEXT'
						  	  ,avalue   => l_notification_text);

				result_object_version_number := fapi_object_version_number;
				result_finance_header_id     := fapi_finance_header_id;
--Bug#2221320 hdshah p_currency_code, p_standard_amount, p_money_amount, p_unitary_amount, p_booking_deal_id,
-- p_booking_deal_type included and p_update_finance_line parameter changed from 'N' to 'Y'.
--Bug#2215026 separate update_enrollment procedure call included for successful finance creation.
                                ota_tdb_api_upd2.update_enrollment(
                                              p_booking_id 		  => l_booking_id,
                                              p_event_id                  => l_eventid,
                                              p_object_version_number 	  => l_object_version_number,
                                              p_booking_status_type_id 	  => l_booking_status_row.booking_status_type_id,
                                              p_tfl_object_version_number => result_object_version_number,
					  --    p_update_finance_line       => 'N',
					      p_update_finance_line       => 'Y',
                                              p_currency_code             => l_event_currency_code,
                                              p_standard_amount           => l_standard_price,
                                              p_money_amount              => l_standard_price,
                                              p_unitary_amount            => null,
                                              p_booking_deal_id           => null,
                                              p_booking_deal_type         => 'N',
					      p_finance_header_id	  => result_finance_header_id,
					      p_finance_line_id 	  => l_finance_line_id,
                                              p_date_status_changed       => l_current_date,
                                              p_date_booking_placed       => l_date_booking_placed);


                                IF l_automatic_transfer_gl = 'Y' AND l_finance_line_id IS NOT NULL AND l_offering_id is null THEN
                                                UPDATE ota_finance_lines SET transfer_status = 'AT'
						WHERE finance_line_id = l_finance_line_id;
	 			END IF;


       			ELSIF fapi_result = 'E' THEN

				l_notification_text := NULL;

				wf_engine.setItemAttrText (itemtype => l_item_type
						 	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_RESULT'
						  	  ,avalue   => fapi_result);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_FROM'
						  	  ,avalue   => fapi_from);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_TO'
						  	  ,avalue   => fapi_to);

				wf_engine.setItemAttrNumber(itemtype => l_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'EVENT_ID'
						  	   ,avalue   => l_eventid);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'BUSINESS_GROUP_NAME'
						  	   ,avalue   => l_business_group_name);

				wf_engine.setItemAttrText (itemtype => l_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'NOTIFICATION_TEXT'
						  	  ,avalue   => l_notification_text);

				result_object_version_number := l_object_version_number;
				result_finance_header_id     := NULL;
				result_create_finance_line   := NULL;

--Bug#2215026 separate update_enrollment procedure call included for unsuccessful finance creation.
                                ota_tdb_api_upd2.update_enrollment(
                                              p_booking_id 		  => l_booking_id,
                                              p_event_id                  => l_eventid,
                                              p_object_version_number 	  => l_object_version_number,
                                              p_booking_status_type_id 	  => l_booking_status_row.booking_status_type_id,
                                              p_tfl_object_version_number => result_object_version_number,
					      p_finance_line_id 	  => l_finance_line_id,
                                              p_date_status_changed       => l_current_date,
                                              p_date_booking_placed       => l_date_booking_placed);

			END IF;
/*Bug#2215026 Two separate update_enrollment procedure calls included for successful and unsuccessful finance creation.
--Bug#2221320 hdshah p_currency_code, p_standard_amount, p_money_amount, p_unitary_amount, p_booking_deal_id, p_booking_deal_type included.
--            p_update_finance_line parameter changed from 'N' to 'Y'.
  */
		wf_engine.setItemAttrText (itemtype => l_item_type
					 	  ,itemkey  => l_item_key
		  			 	  ,aname    => 'BOOKING_STATUS_TYPE_ID'
	  			  	  	  ,avalue   => l_booking_status_row.booking_status_type_id);

                 WF_ENGINE.setitemattrtext(l_item_type,
                              l_item_key,
                              'BOOKING_ID',
                              l_booking_id);

       ELSE

               ota_tdb_api_upd2.update_enrollment(
                                              p_booking_id 		  => l_booking_id,
                                              p_event_id                  => l_eventid,
                                              p_object_version_number 	  => l_object_version_number,
                                              p_booking_status_type_id 	  => l_booking_status_row.booking_status_type_id,
                                              p_tfl_object_version_number => result_object_version_number,
					      p_finance_line_id 	  => l_finance_line_id,
                                              p_date_status_changed       => l_current_date,
                                              p_date_booking_placed       => l_date_booking_placed);

		wf_engine.setItemAttrText (itemtype => l_item_type
					 	  ,itemkey  => l_item_key
		  			 	  ,aname    => 'BOOKING_STATUS_TYPE_ID'
		  			  	  ,avalue   => l_booking_status_row.booking_status_type_id);

                WF_ENGINE.setitemattrtext(l_item_type,
                              l_item_key,
                              'BOOKING_ID',
                              l_booking_id);


       END IF;


     ELSIF l_from = 'SAVEFORLATER' then

      -- from save for later validation
      null;

     END IF;


        EXCEPTION
		WHEN status_not_seeded THEN
                      RAISE;
		WHEN OTHERS THEN
                      RAISE;

END process_api2;




procedure create_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is

   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   l_trans_step_rows                  NUMBER  ;
   l_trans_step_id number;

begin

    l_trans_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');

  if ( funmode = 'RUN' ) then

       process_api2 (false,l_trans_step_id);
       result := 'COMPLETE:SUCCESS';

  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;

end create_enrollment;


procedure cancel_enrollment
 (itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is

  l_transaction_step_id 	number;
  l_eventid                     ota_events.event_id%TYPE;
  l_booking_id			OTA_DELEGATE_BOOKINGS.booking_id%type := null;
  l_business_group_id		OTA_DELEGATE_BOOKINGS.business_group_id%type;
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_delegate_id		        PER_PEOPLE_F.person_id%TYPE;
  l_object_version_number	number;
  l_date_booking_placed         date;
  l_current_date                date;
  result_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;
  l_finance_line_id		OTA_FINANCE_LINES.finance_line_id%type:= null;



CURSOR csr_chk_event
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER) IS
SELECT ov.booking_id,
       ov.date_booking_placed,
       ov.object_version_number,
       ov.business_group_id
FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
WHERE  ov.event_id = p_event_id
AND    ov.delegate_person_id = p_person_id
AND    os.booking_status_type_id = ov.booking_status_type_id
AND    os.type = 'R';


begin

/*    l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');
*/


  if ( funmode = 'RUN' ) then

/* Bug#2258423 hdshah read event id from workflow instead of transaction table
         l_eventid := TO_NUMBER(hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => l_transaction_step_id
               ,p_name                => 'P_EVENTID'));
*/

       l_eventid := wf_engine.GetItemAttrNumber(itemtype => itemtype
                                    ,itemkey  => itemkey
                                    ,aname    => 'OTA_EVENT_ID');

/* Bug#2258423 hdshah read delegate person id from workflow instead of transaction table
-- hdshah Bug#2213380 read delegate_person_id from p_delegate_person_id instead of p_person_id
        l_delegate_id := TO_NUMBER(hr_transaction_api.get_number_Value
                (p_transaction_step_id => l_transaction_step_id
--                ,p_name                => 'P_PERSON_ID'));
                ,p_name                => 'P_DELEGATE_PERSON_ID'));
*/

        l_delegate_id := wf_engine.GetItemAttrNumber(itemtype => itemtype
                                    ,itemkey  => itemkey
                                    ,aname    => 'OTA_DELEGATE_PERSON_ID');


           OPEN  csr_chk_event(l_eventid, l_delegate_id);
           FETCH csr_chk_event INTO l_booking_id,l_date_booking_placed,l_object_version_number,l_business_group_id;
           CLOSE csr_chk_event;

           select sysdate into l_current_date from dual;

            l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'CANCELLED'
			,p_business_group_id       => l_business_group_id);

               ota_tdb_api_upd2.update_enrollment(
                                              p_booking_id 		  => l_booking_id,
                                              p_event_id                  => l_eventid,
                                              p_object_version_number 	  => l_object_version_number,
                                              p_booking_status_type_id 	  => l_booking_status_row.booking_status_type_id,
                                              p_tfl_object_version_number => result_object_version_number,
					      p_finance_line_id 	  => l_finance_line_id,
                                              p_status_change_comments    => null, --Bug 2359495
                                              p_date_status_changed       => l_current_date,
                                               p_date_booking_placed       => l_date_booking_placed,
                                              p_source_cancel => 'AME');



       result := 'COMPLETE:SUCCESS';

  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;

end cancel_enrollment;


procedure validate_enrollment
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2) is

  l_transaction_step_id 	number;
begin

   l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');
   process_api2(true,l_transaction_step_id);
   p_message := 'S' ;
EXCEPTION
    When OTHERS Then
         p_message := fnd_message.get();
         If p_message is NULL then
            p_message := substr(SQLERRM,11,(length(SQLERRM)-10));
         End If;

end validate_enrollment;




Procedure create_segment
  (p_assignment_id                        in     number
  ,p_business_group_id_from               in     number
  ,p_business_group_id_to                 in     number
  ,p_organization_id				in     number
  ,p_sponsor_organization_id              in     number
  ,p_event_id 					in 	 number
  ,p_person_id					in     number
  ,p_currency_code				in     varchar2
  ,p_cost_allocation_keyflex_id           in     number
  ,p_user_id                              in     number
  ,p_finance_header_id			 out nocopy    number
  ,p_object_version_number		 out nocopy    number
  ,p_result                     	 out nocopy    varchar2
  ,p_from_result                          out nocopy    varchar2
  ,p_to_result                            out nocopy    varchar2
  ,p_auto_transfer                        in     varchar2
  ) IS

Begin

ota_crt_finance_segment.Create_Segment(p_assignment_id	 =>	p_assignment_id,
					p_business_group_id_from     =>	p_business_group_id_from,
					p_business_group_id_to	     =>	p_business_group_id_to,
					p_organization_id	     	 =>	p_organization_id,
					p_sponsor_organization_id    =>	p_sponsor_organization_id,
					p_event_id		     	     =>	p_event_id,
					p_person_id		     	     => p_person_id,
					p_currency_code		     	 =>	p_currency_code,
					p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
					p_user_id			         => p_user_id,
					p_finance_header_id	     	 => p_finance_header_id,
					p_object_version_number	     =>	p_object_version_number,
					p_result		     	     => p_result,
					p_from_result		     	 => p_from_result,
					p_to_result		     	     => p_to_result);

end create_segment;

--
-- -----------------------------------------------------------
--   Cross Charges Notifications (Workflow Notifications)
-- -----------------------------------------------------------
--
Procedure Cross_Charges_Notifications ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT nocopy VARCHAR2 )
IS

CURSOR user_name(p_event_id	OTA_EVENTS.event_id%TYPE) IS
SELECT usr.user_name
FROM   OTA_EVENTS 	evt,
       FND_USER        USR
WHERE  evt.event_id = p_event_id and
       usr.employee_id = evt.owner_id
       and trunc(sysdate) between usr.start_date and nvl(usr.end_date,to_date('4712/12/31', 'YYYY/MM/DD')) ;  --Bug 5676892

l_api_result	VARCHAR2(4000);
l_api_from		VARCHAR2(4000);
l_api_to		VARCHAR2(4000);
l_event_id		NUMBER;
l_user_name		FND_USER.USER_NAME%TYPE;
BEGIN

    l_event_id   := wf_engine.GetItemAttrNumber(itemtype => itemtype
					   ,itemkey  => itemkey
					   ,aname    => 'OTA_EVENT_ID');


    OPEN  user_name(l_event_id);
    FETCH user_name INTO l_user_name;
    CLOSE user_name;


    wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'EVENT_OWNER_EMAIL'
			  	  ,avalue   => l_user_name);

    l_api_result := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_RESULT');

	l_api_from   := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_FROM');

	l_api_to     := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_TO');

	IF (funcmode='RUN') THEN
		IF l_api_result = 'S' THEN
			resultout := 'COMPLETE:SUCCESS';
			RETURN;
		ELSE
		  IF l_api_from IS NOT NULL THEN
   			resultout := 'COMPLETE:FROM_ERROR';
     		  ELSIF l_api_to IS NOT NULL THEN
    			resultout := 'COMPLETE:ERROR_TO';
                  ELSE
   		        resultout := 'COMPLETE:SUCCESS';
    			RETURN;
      		  END IF;
       	        END IF;
	END IF;

	IF (funcmode='CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
	END IF;

END Cross_Charges_Notifications;

Procedure set_addnl_attributes(p_item_type 	in wf_items.item_type%type,
                                p_item_key in wf_items.item_key%type,
                                p_eventid in ota_events.event_id %type
                                 )

is

l_proc 	varchar2(72) := g_package||'set_addnl_attributes';

l_actual_cost ota_events.actual_cost%type;
l_budget_currency_code ota_events.budget_currency_code%type;
l_act_ver_id ota_events.activity_version_id%type;
l_off_id ota_events.parent_offering_id%type;
l_event_id ota_events.event_id%type;
l_event_type ota_events.event_type%type;
l_object_type varchar2(240);
l_timezone ota_events.timezone%type;



cursor get_addnl_event_info
is
select
--added after show n tell
oev.actual_cost, oev.budget_currency_code,
oev.parent_offering_id,oev.timezone
from  ota_events oev
where
 oev.event_id = l_event_id;


cursor get_lang_det is
select ofe.language_id, ocu.category
from ota_offerings ofe, ota_category_usages_tl ocu
where ofe.delivery_mode_id = ocu.category_usage_id
and ocu.language=USERENV('LANG')
and ofe.offering_id = l_off_id;


l_lang_description fnd_languages_vl.description%TYPE;
l_curr_name fnd_currencies_vl.name%TYPE;
l_lang_id ota_offerings.language_id%type;
l_delivery_method ota_category_usages.category%type;

begin


open get_addnl_event_info;
fetch get_addnl_event_info into l_actual_cost,
l_budget_currency_code,l_off_id,l_timezone;
close get_addnl_event_info;

open get_lang_det;
fetch get_lang_det into l_lang_id,l_delivery_method;
close get_lang_det;

--l_course_name := ota_general.get_course_name(l_act_ver_id);
l_curr_name := ota_general.fnd_currency_name(l_budget_currency_code);
l_curr_name := l_actual_cost || ' ' || l_curr_name;

l_lang_description := ota_general.fnd_lang_desc(l_lang_id);

--set wf item attributes

--wf_engine.setItemAttrText(p_item_type,p_item_key,'COST',l_curr_name );
wf_engine.setItemAttrText(p_item_type,p_item_key,'STATE_LIST',l_timezone);
--wf_engine.setItemAttrText(p_item_type,p_item_key,'LANGUAGE',l_lang_description );





end set_addnl_attributes;

Procedure Delivery_Mode_Notifications ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT nocopy VARCHAR2 )
IS

CURSOR user_name(p_event_id	OTA_EVENTS.event_id%TYPE) IS
SELECT usr.user_name
FROM   OTA_EVENTS 	evt,
       FND_USER        USR
WHERE  evt.event_id = p_event_id and
       usr.employee_id = evt.owner_id
       and trunc(sysdate) between usr.start_date and nvl(usr.end_date,to_date('4712/12/31', 'YYYY/MM/DD'));   --Bug 5676892


CURSOR csr_booking_status(p_booking_id ota_delegate_bookings.booking_id%type) IS
SELECT bst.Type
FROM   OTA_DELEGATE_BOOKINGS tdb,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  tdb.booking_id = p_booking_id
AND    bst.booking_status_type_id = tdb.booking_status_type_id;

CURSOR delivery_mode(p_event_id	OTA_EVENTS.event_id%TYPE) IS
Select OCU.synchronous_flag, OCU.online_flag
From ota_events OEV,
     ota_offerings OFR,
     ota_category_usages OCU
Where OFR.offering_id = OEV.parent_offering_id
  And OCU.category_usage_id = OFR.delivery_mode_id
  And OEV.event_id = p_event_id;

l_event_id		NUMBER;
l_user_name		FND_USER.USER_NAME%TYPE;
l_booking_id    ota_delegate_bookings.booking_id%type;
l_notification_text  varchar2(2000);
l_status_type   ota_booking_status_types.type%type;

l_synchronous_flag   ota_category_usages.synchronous_flag%type;
l_online_flag   ota_category_usages.online_flag%type;
l_dm_status varchar2(20);
l_approval_req_flag varchar2(100);
l_forward_to_person_id  per_people_f.person_id%type;

BEGIN

    l_event_id   := wf_engine.GetItemAttrNumber(itemtype => itemtype
					   ,itemkey  => itemkey
					   ,aname    => 'OTA_EVENT_ID');

/*	set_addnl_attributes(p_item_type => itemtype,
                                p_item_key => itemkey,
                                p_eventid => l_event_id
                                 );*/


    OPEN  user_name(l_event_id);
    FETCH user_name INTO l_user_name;
    CLOSE user_name;

    l_approval_req_flag := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'HR_RUNTIME_APPROVAL_REQ_FLAG');

    l_booking_id := wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'BOOKING_ID');

    l_notification_text := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'NOTIFICATION_TEXT');

    IF l_booking_id is not null then
       For sts in csr_booking_status(l_booking_id)
       LOOP
          l_status_type := sts.type;
       END LOOP;

       If  l_status_type = 'W' then
          fnd_message.set_name('OTA', 'OTA_443496_WAITLIST_NTF_TEXT');

          l_notification_text := l_notification_text || fnd_message.get();

		  wf_engine.setItemAttrText (itemtype => itemtype
					       ,itemkey  => itemkey
					       ,aname    => 'NOTIFICATION_TEXT'
					       ,avalue   => l_notification_text);
       End If;

    END IF;

    wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'EVENT_OWNER_EMAIL'
			  	  ,avalue   => l_user_name);

/*bug# 7346984 starts*/
    l_forward_to_person_id := wf_engine.GetItemAttrNumber
                    (itemtype       => itemtype
                        ,itemkey        => itemkey
                        ,aname          =>'FORWARD_TO_PERSON_ID');

    if(l_forward_to_person_id is null) then
        wf_engine.SetItemAttrNumber(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'FORWARD_TO_PERSON_ID'
                                   ,avalue   => wf_engine.GetItemAttrNumber(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_ID'));

        wf_engine.SetItemAttrText(itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'FORWARD_TO_USERNAME'
                                  ,avalue   => wf_engine.GetItemAttrText(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_USERNAME'));

        wf_engine.SetItemAttrText(itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'FORWARD_TO_DISPLAY_NAME'
                                  ,avalue   => wf_engine.GetItemAttrText(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_DISPLAY_NAME'));
    end if;
/*bug# 7346984 ends*/

    OPEN  delivery_mode(l_event_id);
    FETCH delivery_mode INTO l_synchronous_flag, l_online_flag;
    CLOSE delivery_mode;

    If upper(l_online_flag) = 'Y' Then
        If upper(l_synchronous_flag) = 'Y' Then
          if l_approval_req_flag = 'NO' then
            l_dm_status := 'COMPLETE:ONSYNN';
          else
            l_dm_status := 'COMPLETE:ONSYN';
          end if;
        Else
            if l_approval_req_flag = 'NO' then
                l_dm_status := 'COMPLETE:ONASYNN';
            else
            l_dm_status := 'COMPLETE:ONASYN';
            end if;
        End If;
    Else
        if l_approval_req_flag = 'NO' then
            l_dm_status := 'COMPLETE:OFFLINEN';
          else
        l_dm_status := 'COMPLETE:OFFLINE';
        end if;
    End If;

    IF (funcmode='RUN') THEN
           resultout := l_dm_status;
	       RETURN;
    END IF;

    IF (funcmode='CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
    END IF;

END Delivery_Mode_Notifications;



--
-- ------------------------------------------------------------------
--  PROCEDURE Approved
-- ------------------------------------------------------------------
--
Procedure Approved  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )  IS

l_forward_to_person_id  per_people_f.person_id%type;
BEGIN

	IF (funcmode='RUN') THEN
		wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'APPROVAL_RESULT'
			  	  ,avalue   => 'ACCEPTED');
                   resultout:='COMPLETE';
/*bug# 3445970 starts*/
    l_forward_to_person_id := wf_engine.GetItemAttrNumber
                    (itemtype       => itemtype
                        ,itemkey        => itemkey
                        ,aname          =>'FORWARD_TO_PERSON_ID');

    if(l_forward_to_person_id is null) then
        wf_engine.SetItemAttrNumber(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'FORWARD_TO_PERSON_ID'
                                   ,avalue   => wf_engine.GetItemAttrNumber(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_ID'));

        wf_engine.SetItemAttrText(itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'FORWARD_TO_USERNAME'
                                  ,avalue   => wf_engine.GetItemAttrText(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_USERNAME'));

        wf_engine.SetItemAttrText(itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'FORWARD_TO_DISPLAY_NAME'
                                  ,avalue   => wf_engine.GetItemAttrText(itemtype   => itemtype
                                                                         ,itemkey    => itemkey
                                                                         ,aname      => 'CREATOR_PERSON_DISPLAY_NAME'));
    end if;
/*bug# 3445970 ends*/
                 RETURN;
	END IF;

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

END Approved;

Function is_class_pending_for_approval
  (p_event_id      in varchar2,
   p_person_id 	   in number,
   p_process_name in varchar2)
RETURN VARCHAR2 IS
--
Cursor cur_get_pending_trn_step_id     IS
Select
       hrtrns.transaction_step_id
From
       wf_item_activity_statuses    process
      ,wf_item_attribute_values     attribute2
      ,wf_process_activities        activity
      ,hr_api_transaction_steps     hrtrns
Where
       activity.activity_name      = p_process_name
and    activity.process_item_type  = 'HRSSA'
and    activity.activity_item_type = 'HRSSA'
and    activity.instance_id        = process.process_activity
and    process.activity_status     = 'ACTIVE'
and    process.item_type           = 'HRSSA'
and    process.item_key            = attribute2.item_key
and    attribute2.item_type        = process.item_type
and    attribute2.name             = 'TRAN_SUBMIT'
and    attribute2.text_value       = 'Y'
and    process.item_key            = hrtrns.item_key
and    trim(upper(hrtrns.api_name)) = trim(upper(g_package||'.PROCESS_API2'))
and    hrtrns.item_type            = 'HRSSA'
and    nvl(hrtrns.update_person_id, hrtrns.creator_person_id) = p_person_id;

l_proc  varchar2(72) := g_package || '.is_class_pending_for_approval';
l_temp_event_id	varchar2(100) := null;
l_return_value varchar2(1) := 'N';
BEGIN

      hr_utility.set_location('Entering:'||l_proc, 5);

      FOR c in cur_get_pending_trn_step_id
      LOOP
          l_temp_event_id :=
                hr_transaction_api.get_varchar2_value
                (p_transaction_step_id => c.transaction_step_id
                ,p_name                => 'P_EVENTID');

           If (l_temp_event_id is not null and l_temp_event_id = p_event_id) Then
                exit;
                null;
           End If;
      End LOOP;

      If (l_temp_event_id is not null and l_temp_event_id = p_event_id) Then
        l_return_value := 'Y';
      End If;

      RETURN l_return_value;
      hr_utility.set_location('Entering:'||l_proc, 30);
END is_class_pending_for_approval;


end ota_learner_enroll_review_ss;

/
