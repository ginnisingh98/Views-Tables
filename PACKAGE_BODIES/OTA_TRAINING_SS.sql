--------------------------------------------------------
--  DDL for Package Body OTA_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRAINING_SS" AS
 /* $Header: otenrwrs.pkb 120.3 2008/01/08 14:02:26 aabalakr noship $*/

   g_package      varchar2(30)   := 'OTA_TRAINING_SS';


  /*
  ||===========================================================================
  || PROCEDURE: save_adv_search
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure save_adv_search(
     p_login_person_id     NUMBER default null
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_keyword                       in     VARCHAR2
    , p_category                      in     VARCHAR2
    , p_dmethod                       in     VARCHAR2
    , p_language                      in     VARCHAR2
    , p_trndates                      in     VARCHAR2
    , p_trnorgids                     in     VARCHAR2
    , p_trnorgnames                   in     VARCHAR2
    , p_trncompids                    in     VARCHAR2
    , p_trncompnames                  in     VARCHAR2
    , p_trncompminlvl                 in     VARCHAR2  --Bug 2509979
    , p_trncompmaxlvl                 in     VARCHAR2  --Bug 2509979
    , p_criteria                      in     VARCHAR2
    , p_oafunc                        in     VARCHAR2
    , p_processname                   in     VARCHAR2
    , p_calledfrom                    in     VARCHAR2
    , p_frommenu                      in     VARCHAR2
  )

  as

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
  --
  begin

  --
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
     ,p_api_name              => g_package || '.PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
  --
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_KEYWORD';
  l_transaction_table(l_count).param_value := p_keyword;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CATEGORY';
  l_transaction_table(l_count).param_value := p_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DMETHOD';
  l_transaction_table(l_count).param_value := p_dmethod;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LANGUAGE';
  l_transaction_table(l_count).param_value := p_language;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNDATES';
  l_transaction_table(l_count).param_value := p_trndates;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_review_item_name := wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                                  itemkey   => p_item_key,
                                                  actid     => p_activity_id,
                                                  aname     => gv_wf_review_region_item);

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';



  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNORGIDS';
  l_transaction_table(l_count).param_value := p_trnorgids;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNORGNAMES';
  l_transaction_table(l_count).param_value := p_trnorgnames;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNCOMPIDS';
  l_transaction_table(l_count).param_value := p_trncompids;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNCOMPNAMES';
  l_transaction_table(l_count).param_value := p_trncompnames;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  --Bug 2509979
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNCOMPMINLVL';
  l_transaction_table(l_count).param_value := p_trncompminlvl;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNCOMPMAXLVL';
  l_transaction_table(l_count).param_value := p_trncompmaxlvl;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
   --Bug 2509979


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CRITERIA';
  l_transaction_table(l_count).param_value := p_criteria;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OAFUNC';
  l_transaction_table(l_count).param_value := p_oafunc;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESSNAME';
  l_transaction_table(l_count).param_value := p_processname;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CALLEDFROM';
  l_transaction_table(l_count).param_value := p_calledfrom;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROMMENU';
  l_transaction_table(l_count).param_value := p_frommenu;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
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

 end save_adv_search;


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
    , p_delegate_person_id                  in NUMBER default null
    , p_ccselectiontext                     in varchar2     default null
    , p_oafunc                              in varchar2     default null
    , p_processname                         in varchar2     default null
    , p_calledfrom                          in varchar2     default null
    , p_frommenu                            in varchar2     default null
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


  l_review_item_name := wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                                  itemkey   => p_item_key,
                                                  actid     => p_activity_id,
                                                  aname     => gv_wf_review_region_item);

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
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
  l_transaction_table(l_count).param_name := 'P_OAFUNC';
  l_transaction_table(l_count).param_value := p_oafunc;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESSNAME';
  l_transaction_table(l_count).param_value := p_processname;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CALLEDFROM';
  l_transaction_table(l_count).param_value := p_calledfrom;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROMMENU';
  l_transaction_table(l_count).param_value := p_frommenu;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';





    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => p_item_type
      ,p_item_key   => p_item_key
      ,p_name   => 'OTA_TRANSACTION_STEP_ID');

  WF_ENGINE.setitemattrnumber(p_item_type,
                              p_item_key,
                              'OTA_TRANSACTION_STEP_ID',
                              l_transaction_step_id);


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



-- ---------------------------------------------------------------------------
-- ---------------------- < get_adv_search_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes or vice-versa.  Hence, we need to use
--          the item_type item_key passed in to retrieve the transaction record.
-- ---------------------------------------------------------------------------
PROCEDURE get_adv_search_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_adv_search_data                 out nocopy varchar2
) is


   l_trans_rec_count                  integer default 0;
   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   ln_index                           number  default 0;
   l_trans_step_rows                  NUMBER  ;
   l_adv_search_data                       varchar2(4000);


 BEGIN

         hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);


              get_adv_search_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
                ,p_adv_search_data                => l_adv_search_data);


              p_adv_search_data := l_adv_search_data;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_adv_search_data_from_tt;




-- ---------------------------------------------------------------------------
-- ---------------------- < get_adv_search_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------
procedure get_adv_search_data_from_tt
   (p_transaction_step_id             in  number
   ,p_adv_search_data                 out nocopy varchar2
)is

 l_object_version_number per_phones.object_version_number%type;
 l_keyword               varchar2(50);
 l_category              varchar2(50);
 l_dmethod               varchar2(50);
 l_language              varchar2(50);
 l_trndates              varchar2(50);
 l_trnorgids             varchar2(2000);
 l_trnorgnames           varchar2(2000);
 l_trncompids            varchar2(2000);
 l_trncompnames          varchar2(2000);
 l_trncompminlvl         varchar2(2000);  --Bug 2509979
 l_trncompmaxlvl         varchar2(2000);  --Bug 2509979
 l_criteria              varchar2(10);
 l_oafunc                varchar2(100);
 l_processname           varchar2(100);
 l_calledfrom            varchar2(100);
 l_frommenu              varchar2(100);
begin


  l_keyword := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_KEYWORD');

  l_category := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CATEGORY');

  l_dmethod := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DMETHOD');

  l_language := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LANGUAGE');

  l_trndates := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNDATES');


  l_trnorgids := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNORGIDS');

  l_trnorgnames := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNORGNAMES');

  l_trncompids := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNCOMPIDS');

  l_trncompnames := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNCOMPNAMES');

  --Bug 2509979
  l_trncompminlvl := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNCOMPMINLVL');

  l_trncompmaxlvl := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNCOMPMAXLVL');
  --Bug 2509979

  l_criteria := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CRITERIA');

  l_oafunc  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OAFUNC');

  l_processname  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROCESSNAME');

  l_calledfrom  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CALLEDFROM');

  l_frommenu  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FROMMENU');
--
-- Now string all the retreived items into p_adv_search_data

--

p_adv_search_data := nvl(l_keyword,'null')||'^'||nvl(l_category,'null')||'^'||nvl(l_dmethod,'null')||
                     '^'||nvl(l_language,'null')||'^'||nvl(l_trndates,'null')||'^'||nvl(l_trnorgids,'null')
                    ||'^'||nvl(l_trnorgnames,'null')||'^'||nvl(l_trncompids,'null')||'^'||nvl(l_trncompnames,'null')
                    ||'^'||nvl(l_criteria,'null')
                    ||'^'||nvl(l_trncompminlvl,'null')||'^'||nvl(l_trncompmaxlvl,'null')--Bug 2509979
                    ||'^'||nvl(l_oafunc,'null')
                    ||'^'||nvl(l_processname,'null')
                    ||'^'||nvl(l_calledfrom,'null')
                    ||'^'||nvl(l_frommenu,'null');


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_adv_search_data_from_tt;




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
 l_oafunc                  varchar2(100);
 l_processname             varchar2(100);
 l_calledfrom              varchar2(100);
 l_frommenu                varchar2(100);

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

  l_oafunc  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OAFUNC');

  l_processname  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROCESSNAME');

  l_calledfrom  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CALLEDFROM');

  l_frommenu  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FROMMENU');

--
-- Now string all the retreived items into p_adv_search_data

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
                           ||'^'||nvl(l_oafunc,'null')
                           ||'^'||nvl(l_processname,'null')
                           ||'^'||nvl(l_calledfrom,'null')
                           ||'^'||nvl(l_frommenu,'null');


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

         hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);


              get_review_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
                ,p_review_data                    => l_review_data);


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
 l_ccselectiontext          varchar2(200);
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
 l_trnorgnames           varchar2(2000);

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

--
-- Now string all the retreived items into p_review_data

--

--p_review_data := nvl(l_eventid,0)||'^'||nvl(l_specialInstruction,'null')||'^'||nvl(l_keyflexid,0);
--Bug#2381073   hdshah initialize with space instead of 0 if l_ccselectiontext is null
--p_review_data := nvl(l_eventid,0)||'^'||nvl(l_specialInstruction,'null')||'^'||nvl(l_ccselectiontext,0);
p_review_data := nvl(l_eventid,0)||'^'||nvl(l_specialInstruction,'null')||'^'||nvl(l_ccselectiontext,' ')||'^'||nvl(l_tdb_information_category,'null')
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
                           ||'^'||nvl(l_trnorgnames,'null');



EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_review_data_from_tt;




PROCEDURE process_api
        (p_validate IN BOOLEAN,p_transaction_step_id IN NUMBER, p_effective_date in varchar2 ) IS
BEGIN

-- validation for search page.
null;


END process_api;




PROCEDURE process_api2
        (p_validate IN BOOLEAN,p_transaction_step_id IN NUMBER, p_effective_date in varchar2 ) IS

  l_booking_id			OTA_DELEGATE_BOOKINGS.booking_id%type := null;
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_delegate_id		        PER_PEOPLE_F.person_id%TYPE;
  l_eventid                     ota_events.event_id%TYPE;
  l_object_version_number	number;
  l_person_details		OTA_ENROLL_IN_TRAINING_SS.csr_person_to_enroll_details%ROWTYPE;
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
  l_course_end_date 		ota_events.course_end_date%type;
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

 status_not_seeded          exception;


CURSOR bg_to (l_event_id	ota_events.event_id%TYPE) IS
SELECT hao.business_group_id,
       evt.organization_id,
       evt.currency_code,
       evt.offering_id,
       evt.owner_id,
       evt.activity_version_id,
       evt.Title,
       evt.course_start_date,
       evt.course_end_date,
       evt.business_group_id bg_id   -- Bug#2215026 evt.business_group_id included.
FROM   OTA_EVENTS_VL 		 evt,
       HR_ALL_ORGANIZATION_UNITS hao
WHERE  evt.event_id = l_eventid
AND    evt.organization_id = hao.organization_id (+); --Bug#2215026 (+) included.



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
Employee_id = p_owner_id ;

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



        l_person_details := ota_enroll_in_training_ss.Get_Person_To_Enroll_Details(p_person_id => l_delegate_id);

           IF l_person_details.full_name is not null then
                   WF_ENGINE.setitemattrtext(l_item_type,
                             		     l_item_key,
                                             'CURRENT_PERSON_DISPLAY_NAME',
                                             l_person_details.full_name);
           END IF;

        l_restricted_assignment_id := ota_enroll_in_training_ss.CHK_DELEGATE_OK_FOR_EVENT(p_delegate_id => l_delegate_id
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
				l_business_group_id;
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
                             l_event_title);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_course_start_date);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_END_DATE',
                            l_course_end_date);

           WF_ENGINE.setitemattrnumber(l_item_type,
                            l_item_key,
                            'TRANSACTION_ID',
-- Bug#4617150
--                            hr_transaction_web.get_transaction_id
                            hr_transaction_ss.get_transaction_id
                                   (p_item_type => l_item_type
                                   ,p_item_key  => l_item_key));


           WF_ENGINE.setitemattrnumber(l_item_type,
                            l_item_key,
                            'FORWARD_FROM_PERSON_ID',
                            l_delegate_id);



        l_cancel_boolean := ota_enroll_in_training_ss.Chk_Event_Cancelled_for_Person(p_event_id           => l_eventid
       							  ,p_delegate_person_id => l_delegate_id
       							  ,p_booking_id         => l_booking_id);

        IF (l_cancel_boolean) THEN
         -- Call Cancel procedure to cancel the Finance if person Re-enroll
          ota_enroll_in_training_ss.cancel_finance(l_booking_id);
        END IF;


      l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web(
	 p_web_booking_status_type => 'REQUESTED'
  -- Bug#2215026 ota_general call replaced by l_business_group_id.
  --      ,p_business_group_id 	   => ota_general.get_business_group_id);
        ,p_business_group_id 	   => l_business_group_id);

           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
-- Bug#2227738 hdshah change the exception
--              RAISE OTA_ENROLL_IN_TRAINING_SS.g_mesg_on_stack_exception ;
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
--Bug#2215026 ota_general call replaced by l_business_group_id
--					,p_business_group_id        	=>	ota_general.get_business_group_id
					,p_business_group_id        	=>	l_business_group_id
      					,p_event_id                 	=>	l_eventid
--Bug#2364192 hdshah missing trunc included
--     					,p_date_booking_placed     	=>	l_current_date
      					,p_date_booking_placed     	=>	trunc(l_current_date)
      					,p_corespondent        		=> 	'S' --l_corespondent
      					,p_internal_booking_flag    	=> 	'Y'
					,p_person_address_type => 'I'
      					,p_number_of_places         	=> 	1
      					,p_object_version_number    	=> 	l_object_version_number
      					,p_delegate_contact_phone	=> 	l_person_details.work_telephone
     					,p_source_of_booking        	=> 	'E'
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
                                        ,p_tdb_information20            =>	l_tdb_information20);


          if (p_validate = true) then
                 rollback to validate_enrollment;
          else

               l_auto_create_finance   := FND_PROFILE.value('OTA_AUTO_CREATE_FINANCE');
               l_automatic_transfer_gl := FND_PROFILE.value('OTA_SSHR_AUTO_GL_TRANSFER');
               l_user 		       := FND_PROFILE.value('USER_ID');

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

              -- Bug#2215051 do not need commit
              --     commit;

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
               /*  End Set wf item attribute for rejecttion */

          end if;

     ELSIF l_from = 'APPROVE' then  -- update enrollment and create finance line if profile is set to YES

        l_eventid := TO_NUMBER(hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_EVENTID'));


-- hdshah Bug#2213380 read delegate_person_id from p_delegate_person_id instead of p_person_id
        l_delegate_id := TO_NUMBER(hr_transaction_api.get_number_Value
                (p_transaction_step_id => p_transaction_step_id
--                ,p_name                => 'P_PERSON_ID'));
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
				l_business_group_id;
          CLOSE bg_to;

--Bug#2221320 hdshah l_standard_price included.
            OPEN  get_event_status;
            FETCH get_event_status into l_event_status, l_maximum_internal_attendees,l_price_basis,l_standard_price;
            CLOSE get_event_status;

            OPEN  get_existing_internal;
            FETCH get_existing_internal into l_existing_internal;
            CLOSE get_existing_internal;

            l_maximum_internal_allowed := nvl(l_maximum_internal_attendees,0) - l_existing_internal;

         IF l_event_status in ('F') THEN

            l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => l_business_group_id);
          ELSIF l_event_status in ('P') THEN

            l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => l_business_group_id);

          ELSIF l_event_status = 'N' THEN

            IF l_maximum_internal_attendees  is null then
               l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => l_business_group_id);

            ELSE

              IF l_maximum_internal_allowed > 0 THEN
                 l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => l_business_group_id);

              ELSIF l_maximum_internal_allowed <= 0  THEN
                    l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
       			(p_web_booking_status_type => 'WAITLISTED'
      			 ,p_business_group_id       => l_business_group_id);

              END IF;
            END IF;
         END IF;

           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
-- Bug#2227738 hdshah change the exception
--              RAISE OTA_ENROLL_IN_TRAINING_SS.g_mesg_on_stack_exception ;
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

-- --------------------------------------------
--   Dynamic Notification Text for Workflow
-- --------------------------------------------
--                 l_notification_text     := 'The Cross Charge details have been successfully obtained for the Enrollment record. ';

		   l_notification_text     := '  The appropriate cost center has been charged.';



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
-- Bug#2227738 hdshah change the exception
--              WHEN OTA_ENROLL_IN_TRAINING_SS.g_mesg_on_stack_exception THEN
--                    NULL;
		WHEN status_not_seeded THEN
                      RAISE;
		WHEN OTHERS THEN
--              raise_application_error(20001,SQLERRM);
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
	if csr_chk_event%notfound then
            CLOSE csr_chk_event;
                 result := 'COMPLETE:SUCCESS';
             return;
           end if;
           CLOSE csr_chk_event;

           select sysdate into l_current_date from dual;

            l_booking_status_row := ota_enroll_in_training_ss.Get_Booking_Status_for_web
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
                                              p_date_booking_placed       => l_date_booking_placed);


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
  l_eventid			ota_events.event_id%type;

  l_approval_mode        wf_activity_attr_values.text_value%type;
  l_dummy_item_type      HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
  l_dummy_item_key       HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
  l_activity_id          HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;

begin

    l_transaction_step_id  :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type
			                                 ,itemkey  => p_item_key
			                                 ,aname    => 'OTA_TRANSACTION_STEP_ID');

-- Code added for Bug#2782175
    hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => l_transaction_step_id
         ,p_item_type            => l_dummy_item_type
         ,p_item_key             => l_dummy_item_key
         ,p_activity_id          => l_activity_id);

   l_approval_mode := wf_engine.GetActivityAttrText
          (itemtype => p_item_type,
           itemkey  => p_item_key,
           actid    => l_activity_id,
           aname    => 'HR_APPROVAL_REQ_FLAG');

   if l_approval_mode = 'YES_DYNAMIC' then

       l_eventid := TO_NUMBER(hr_transaction_api.get_varchar2_value
		            (p_transaction_step_id => l_transaction_step_id
 	 	            ,p_name                => 'P_EVENTID'));

       hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => p_item_type
		      ,p_item_key   => p_item_key
		      ,p_name       => 'OTA_EVENT_ID');

      WF_ENGINE.setitemattrnumber(p_item_type,
  			          p_item_key,
			          'OTA_EVENT_ID',
				  l_eventid);
   end if;

-- Code added for Bug#2782175


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

TYPE from_rec_type IS RECORD
   (colname    varchar2(30),
    destcolname  varchar2(30),
    colvalue   varchar2(25));

TYPE from_arr_type IS TABLE OF from_rec_type INDEX BY BINARY_INTEGER;


TYPE to_rec_type IS RECORD
   (colname    varchar2(30),
    destcolname  varchar2(30),
    colvalue   varchar2(25));

TYPE to_arr_type IS TABLE OF to_rec_type INDEX BY BINARY_INTEGER;


l_organization_id  number(15);
l_cost_allocation_keyflex_id number(9);
l_user_id        number ;


source_cursor           INTEGER;
ret                     INTEGER;
l_segment               varchar2(25);
l_paying_cost_center    varchar2(800);
l_receiving_cost_center varchar2(800);
l_chart_of_accounts_id  number(15);
l_set_of_books_id       number(15);
l_from_set_of_books_id  number(15);
l_to_set_of_books_id    number(15);
l_receivable_type       ota_finance_headers.receivable_type%type;
l_sequence 			number(3);
l_delimiter   		varchar2(1);
l_length      		number(3);
l_dynamicSqlString  	varchar2(2000);
i          			number;
--cc_arr     		cc_arr_type;
j          			number;
k          			number;
g_from_arr   		from_arr_type;
g_to_arr   			to_arr_type;
l_from_cc_id  		number;
l_to_cc_id  		number;
l_map                   varchar2(1);
l_error                 varchar(2000);
l_authorizer_person_id  ota_finance_headers.authorizer_person_id%type;
--l_auto_transfer         varchar2(1) := FND_PROFILE.VALUE('OTA_SSHR_AUTO_GL_TRANSFER');
l_auto_transfer         varchar2(1) := p_auto_transfer;
l_transfer_status       ota_finance_headers.transfer_status%type;
l_administrator         ota_finance_headers.administrator%type;
l_date_format varchar2(200);

l_offering_id   		ota_events.offering_id%type;

CURSOR THG_FROM(p_business_group_id in number)
IS
Select
      tcc.gl_set_of_books_id,
	thg.SEGMENT
	,thg.SEGMENT_NUM
	,thg.HR_DATA_SOURCE
	,thg.CONSTANT
	,thg.HR_COST_SEGMENT
FROM  OTA_HR_GL_FLEX_MAPS THG
      ,OTA_CROSS_CHARGES TCC
WHERE THG.Cross_charge_id = TCC.Cross_charge_id and
      TCC.Business_group_id = p_business_group_id and
      TCC.Type = 'E' and
      TCC.FROM_TO = 'F' and
      Trunc(sysdate) between tcc.start_date_active and nvl(tcc.end_date_active,sysdate)
ORDER BY thg.segment_num;


CURSOR THG_TO(p_business_group_id in number)
IS
Select
      tcc.gl_set_of_books_id,
	thg.SEGMENT
	,thg.SEGMENT_NUM
	,thg.HR_DATA_SOURCE
	,thg.CONSTANT
	,thg.HR_COST_SEGMENT
FROM  OTA_HR_GL_FLEX_MAPS THG
      ,OTA_CROSS_CHARGES TCC
WHERE THG.Cross_charge_id = TCC.Cross_charge_id and
      TCC.Business_group_id = p_business_group_id_to and
      TCC.Type = 'E' and
      TCC.FROM_TO = 'T' and
      Trunc(sysdate) between tcc.start_date_active and nvl(tcc.end_date_active,sysdate)
ORDER BY thg.segment_num;



CURSOR ORG
IS
SELECT
  COST_ALLOCATION_KEYFLEX_ID
FROM HR_ALL_ORGANIZATION_UNITS
WHERE ORGANIZATION_ID = l_organization_id;

CURSOR SOB(p_set_of_books_id in number)
 IS
SELECT CHART_OF_ACCOUNTS_ID
FROM GL_SETS_OF_BOOKS
WHERE SET_OF_BOOKS_ID = p_set_of_books_id;

CURSOR OFA IS
SELECT hr.COST_ALLOCATION_KEYFLEX_ID
FROM   HR_ALL_ORGANIZATION_UNITS hr ,
       PER_ALL_ASSIGNMENTS_F asg
WHERE hr.organization_id = asg.organization_id and
      asg.organization_id = p_organization_id and
      asg.assignment_id = p_assignment_id and
      trunc(sysdate) between asg.effective_start_date and
                             asg.effective_end_date;

CURSOR SPO IS
SELECT hr.COST_ALLOCATION_KEYFLEX_ID
FROM   HR_ALL_ORGANIZATION_UNITS hr ,
       OTA_EVENTS EVT
WHERE  hr.organization_id = evt.organization_id and
       evt.event_id = p_event_id;

/* For Ilearning */
CURSOR csr_event
IS
SELECT offering_id
FROM ota_events
where event_id= p_event_id;

Begin
  p_result := 'S';
  l_sequence := 1;
  j := 1;



  /*-----------------------------------------------------------
  | For Transfer from logic                                    |
  |                                                           |
  ------------------------------------------------------------*/
  for from_rec  in thg_from(p_business_group_id_from)
  LOOP
     if l_sequence = 1 then

         OPEN sob(from_rec.gl_set_of_books_id);
           FETCH sob into l_chart_of_accounts_id;

         CLOSE sob;
           l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', l_chart_of_accounts_id);

           l_from_set_of_books_id := from_rec.gl_set_of_books_id;

     for  i in 1..30
     loop
		 g_from_arr(i).colname := 'SEGMENT'||to_char(i);
 	  	 g_from_arr(i).destcolname := 'FROM_SEGMENT'||to_char(i);
		 g_from_arr(i).colvalue := null;
     end loop;

     end if;

     l_sequence := 2;

     l_segment := null;
     l_cost_allocation_keyflex_id := null;

     IF from_rec.hr_data_source = 'BGP' THEN
        IF from_rec.HR_COST_SEGMENT is not null THEN
           BEGIN

             SELECT COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
             FROM   HR_ALL_ORGANIZATION_UNITS WHERE organization_id = p_business_group_id_from;


            l_dynamicSqlString := 'SELECT ' ||from_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
             BEGIN
  	   		 execute immediate l_dynamicSqlString
          		 into l_segment
         		 using l_cost_allocation_keyflex_id;
          		 EXCEPTION WHEN NO_DATA_FOUND Then
                   null;
       	 END;

             EXCEPTION WHEN NO_DATA_FOUND Then
              null;
           END;

         ELSE
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            else
               p_result := 'E';
               p_from_result  := 'B';
            end if;
         END IF;

         IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'B';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  from_rec.hr_data_source = 'ASG' THEN

      IF from_rec.HR_COST_SEGMENT is not null THEN
         l_dynamicSqlString := 'SELECT ' || from_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	     execute immediate l_dynamicSqlString
           into l_segment
           using p_cost_allocation_keyflex_id;
           EXCEPTION WHEN NO_DATA_FOUND Then
              null;
         END;
      ELSE
        IF from_rec.constant is not null then
            l_segment := from_rec.constant;
        ELSE
           p_from_result  := 'A';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'A';
               p_result := 'E';
            END IF;
         END IF;
     ELSIF from_rec.hr_data_source = 'OFA' THEN
      IF from_rec.HR_COST_SEGMENT is not null THEN
         BEGIN
          OPEN OFA;
          FETCH OFA INTO l_cost_allocation_keyflex_id ;
          CLOSE OFA;
       /*   SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 PER_ALL_ASSIGNMENTS_F asg
          WHERE hr.organization_id = asg.organization_id and
                asg.organization_id = p_organization_id and
                asg.assignment_id = p_assignment_id ; */

 	    l_dynamicSqlString := 'SELECT ' ||from_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using l_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
        IF from_rec.constant is not null then
            l_segment := from_rec.constant;
        ELSE
           p_from_result  := 'O';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'O';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  from_rec.hr_data_source = 'SPO' THEN
      IF from_rec.HR_COST_SEGMENT is not null THEN
        BEGIN
          OPEN SPO;
          FETCH SPO INTO l_cost_allocation_keyflex_id ;
          CLOSE SPO;

         /* SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 OTA_EVENTS EVT
          WHERE hr.organization_id = evt.organization_id and
                evt.event_id = p_event_id; */
          l_dynamicSqlString := 'SELECT ' ||from_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;

 	    BEGIN
  	       execute immediate l_dynamicSqlString
             into l_segment
             using l_cost_allocation_keyflex_id;
             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
          END;
         EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
         IF from_rec.constant is not null then
            l_segment := from_rec.constant;
         ELSE
           p_from_result  := 'S';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'S';
               p_result := 'E';
            END IF;
         END IF;

     --  END;
     ELSE
       IF from_rec.constant is null then
          p_from_result  := 'S';
          p_result := 'E';
       ELSE
          l_segment := from_rec.constant;
       END IF;
     END IF;

     /*if l_segment is null then
        l_segment := from_rec.constant;
     end if;*/

     if l_paying_cost_center is null then
        l_paying_cost_center := l_segment;
     else
        l_paying_cost_center := l_paying_cost_center ||l_delimiter||l_segment;
     end if;

      j := to_number(substr(from_rec.SEGMENT,8,2));
      if ( g_from_arr(j).colname = from_rec.SEGMENT  ) THEN
    	    g_from_arr(j).colvalue := l_segment;

         -- j:= j +1 ;
      end if;


  /* IF p_result = 'E' then
      RETURN;
   END IF; */

  END LOOP;
  if p_result = 'S' then
     if l_paying_cost_center is not null then
      l_length := length (l_paying_cost_center);
      l_from_cc_id :=FND_FLEX_EXT.GET_CCID('SQLGL', 'GL#', l_chart_of_accounts_id, fnd_date.date_to_displaydate(sysdate),
                             l_paying_cost_center);

      if l_from_cc_id =0 then
         p_from_result  := 'C';
         p_result := 'E';
      end if;
     else
         p_from_result  := 'N';
         p_result := 'E';
    end if;
  end if;



if p_result = 'S' then

  l_sequence := 1;
  k := 1;
  /*-----------------------------------------------------------
  | For Transfer to logic                                     |
  |                                                           |
  ------------------------------------------------------------*/
  for to_rec  in thg_to(p_business_group_id_to)
  LOOP
     if l_sequence = 1 then

        OPEN sob(to_rec.gl_set_of_books_id);
         FETCH sob into l_chart_of_accounts_id;
        CLOSE sob;
        l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', l_chart_of_accounts_id);

        l_to_set_of_books_id := to_rec.gl_set_of_books_id;
     for  l in 1..30
     loop
		 g_to_arr(l).colname := 'SEGMENT'||to_char(l);
 	  	 g_to_arr(l).destcolname := 'TO_SEGMENT'||to_char(l);
		 g_to_arr(l).colvalue := null;
     end loop;


     end if;

     l_sequence := 2;

     l_segment := null;
     l_cost_allocation_keyflex_id := null;

     IF to_rec.hr_data_source = 'BGP' THEN
        IF to_rec.HR_COST_SEGMENT is not null THEN
           BEGIN
             SELECT COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
             FROM   HR_ALL_ORGANIZATION_UNITS WHERE organization_id = p_business_group_id_to;


            l_dynamicSqlString := 'SELECT ' ||to_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
             BEGIN
  	   		 execute immediate l_dynamicSqlString
          		 into l_segment
         		 using l_cost_allocation_keyflex_id;
          		 EXCEPTION WHEN NO_DATA_FOUND Then
                   null;
         	 END;

             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
           END;
        ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'B';
            end if;
         END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'B';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  to_rec.hr_data_source = 'ASG' THEN
      IF to_rec.HR_COST_SEGMENT is not null THEN
         l_dynamicSqlString := 'SELECT ' || to_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using p_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;


      ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'A';
            end if;
      END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'A';
               p_result := 'E';
            END IF;
         END IF;


     ELSIF to_rec.hr_data_source = 'OFA' THEN
      IF to_rec.HR_COST_SEGMENT is not null THEN
         BEGIN
          OPEN OFA;
          FETCH OFA INTO l_cost_allocation_keyflex_id ;
          CLOSE OFA;
         /* SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 PER_ALL_ASSIGNMENTS_F asg
          WHERE hr.organization_id = asg.organization_id and
                asg.organization_id = p_organization_id and
                asg.assignment_id = p_assignment_id  ; */

 	    l_dynamicSqlString := 'SELECT ' ||to_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using l_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;

        END;
       ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'O';
            end if;
      END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'O';
               p_result := 'E';
            END IF;
         END IF;
     ELSIF  to_rec.hr_data_source = 'SPO' THEN
       IF to_rec.HR_COST_SEGMENT is not null THEN
        BEGIN
           OPEN SPO;
          FETCH SPO INTO l_cost_allocation_keyflex_id ;
          CLOSE SPO;

        /*  SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 OTA_EVENTS EVT
          WHERE hr.organization_id = evt.organization_id and
                evt.event_id = p_event_id; */
        l_dynamicSqlString := 'SELECT ' ||to_rec.HR_COST_SEGMENT ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;

 	    BEGIN
  	       execute immediate l_dynamicSqlString
             into l_segment
             using l_cost_allocation_keyflex_id;
             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
          END;
         EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
         IF to_rec.constant is not null then
            l_segment := to_rec.constant;
        ELSE
           p_from_result  := 'S';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'S';
               p_result := 'E';
            END IF;
         END IF;

     --  END;
     ELSE

      IF to_rec.constant is null then
          p_to_result  := 'S';
          p_result := 'E';
       ELSE
          l_segment := to_rec.constant;
       END IF;


     END IF;

    /* if l_segment is null then
        l_segment := to_rec.constant;
     end if; */

     if l_receiving_cost_center is null then
        l_receiving_cost_center := l_segment;
     else
        l_receiving_cost_center := l_receiving_cost_center ||l_delimiter||l_segment;
     end if;

     k := to_number(substr(to_rec.SEGMENT,8,2));

     if ( to_rec.SEGMENT = g_to_arr(k).colname) THEN
        g_to_arr(k).colvalue := l_segment;
        --k:= k +1 ;
     end if;

 --  IF p_result = 'E' then
 --     RETURN;
  -- END IF;

  END LOOP;
   if p_result = 'S' then
       if l_receiving_cost_center is not null then
         l_length := length (l_receiving_cost_center);
          l_to_cc_id :=FND_FLEX_EXT.GET_CCID('SQLGL', 'GL#', l_chart_of_accounts_id, fnd_date.date_to_displaydate(sysdate),
                             l_receiving_cost_center);

         if l_to_cc_id = 0 then
            p_result := 'E';
            p_to_result  := 'C';
         end if;
    else
         p_to_result  := 'N';
         p_result := 'E';
    end if;
  end if;
end if;

IF p_result = 'S' THEN
   /* For Ilearning */
   OPEN csr_event;
   FETCH csr_event into l_offering_id;
   CLOSE csr_event;

   l_administrator  :=p_user_id;
   if l_auto_transfer = 'Y' then
      if l_offering_id is null then
         l_authorizer_person_id := p_user_id;
         l_transfer_status := 'AT';
      else
         l_authorizer_person_id := null;
         l_transfer_status := 'NT';
      end if;
   else
      l_authorizer_person_id := null;
      l_transfer_status := 'NT';
   end if;

      ota_tfh_api_ins.ins
       (
        P_finance_header_id         =>  P_finance_header_id
       ,P_object_version_number     =>  P_object_version_number
       ,P_organization_id           =>  P_organization_id
       ,P_administrator             =>  l_administrator
       ,P_cancelled_flag            =>  'N'
       ,P_currency_code             =>  P_currency_code
       ,P_date_raised               =>  sysdate
       ,P_payment_status_flag       =>  'N'
       ,P_transfer_status           =>  l_transfer_status
       ,P_type                      =>  'CT'
       ,p_authorizer_person_id      =>  l_authorizer_person_id
       ,p_receivable_type	      =>  l_receivable_type
       ,P_paying_cost_center        =>  l_paying_cost_center
       ,P_receiving_cost_center     =>  l_receiving_cost_center
       ,p_transfer_from_set_of_book_id => l_from_set_of_books_id
       ,p_transfer_to_set_of_book_id => l_to_set_of_books_id
       ,p_from_segment1             =>  g_from_arr(1).colvalue
       ,p_from_segment2             =>  g_from_arr(2).colvalue
       ,p_from_segment3             =>  g_from_arr(3).colvalue
       ,p_from_segment4             =>  g_from_arr(4).colvalue
       ,p_from_segment5             =>  g_from_arr(5).colvalue
       ,p_from_segment6             =>  g_from_arr(6).colvalue
       ,p_from_segment7             =>  g_from_arr(7).colvalue
       ,p_from_segment8             =>  g_from_arr(8).colvalue
       ,p_from_segment9             =>  g_from_arr(9).colvalue
       ,p_from_segment10            =>  g_from_arr(10).colvalue
       ,p_from_segment11            =>  g_from_arr(11).colvalue
       ,p_from_segment12            =>  g_from_arr(12).colvalue
       ,p_from_segment13            =>  g_from_arr(13).colvalue
       ,p_from_segment14            =>  g_from_arr(14).colvalue
       ,p_from_segment15            =>  g_from_arr(15).colvalue
       ,p_from_segment16            =>  g_from_arr(16).colvalue
       ,p_from_segment17            =>  g_from_arr(17).colvalue
       ,p_from_segment18            =>  g_from_arr(18).colvalue
       ,p_from_segment19            =>  g_from_arr(19).colvalue
       ,p_from_segment20            =>  g_from_arr(20).colvalue
       ,p_from_segment21            =>  g_from_arr(21).colvalue
       ,p_from_segment22            =>  g_from_arr(22).colvalue
       ,p_from_segment23            =>  g_from_arr(23).colvalue
       ,p_from_segment24            =>  g_from_arr(24).colvalue
       ,p_from_segment25            =>  g_from_arr(25).colvalue
       ,p_from_segment26            =>  g_from_arr(26).colvalue
       ,p_from_segment27            =>  g_from_arr(27).colvalue
       ,p_from_segment28            =>  g_from_arr(28).colvalue
       ,p_from_segment29            =>  g_from_arr(29).colvalue
       ,p_from_segment30            =>  g_from_arr(30).colvalue
       ,p_to_segment1               =>  g_to_arr(1).colvalue
       ,p_to_segment2               =>  g_to_arr(2).colvalue
       ,p_to_segment3               =>  g_to_arr(3).colvalue
       ,p_to_segment4               =>  g_to_arr(4).colvalue
       ,p_to_segment5               =>  g_to_arr(5).colvalue
       ,p_to_segment6               =>  g_to_arr(6).colvalue
       ,p_to_segment7               =>  g_to_arr(7).colvalue
       ,p_to_segment8               =>  g_to_arr(8).colvalue
       ,p_to_segment9               =>  g_to_arr(9).colvalue
       ,p_to_segment10              =>  g_to_arr(10).colvalue
       ,p_to_segment11              =>  g_to_arr(11).colvalue
       ,p_to_segment12              =>  g_to_arr(12).colvalue
       ,p_to_segment13              =>  g_to_arr(13).colvalue
       ,p_to_segment14              =>  g_to_arr(14).colvalue
       ,p_to_segment15              =>  g_to_arr(15).colvalue
       ,p_to_segment16              =>  g_to_arr(16).colvalue
       ,p_to_segment17              =>  g_to_arr(17).colvalue
       ,p_to_segment18              =>  g_to_arr(18).colvalue
       ,p_to_segment19              =>  g_to_arr(19).colvalue
       ,p_to_segment20              =>  g_to_arr(20).colvalue
       ,p_to_segment21              =>  g_to_arr(21).colvalue
       ,p_to_segment22              =>  g_to_arr(22).colvalue
       ,p_to_segment23              =>  g_to_arr(23).colvalue
       ,p_to_segment24              =>  g_to_arr(24).colvalue
       ,p_to_segment25              =>  g_to_arr(25).colvalue
       ,p_to_segment26              =>  g_to_arr(26).colvalue
       ,p_to_segment27              =>  g_to_arr(27).colvalue
       ,p_to_segment28              =>  g_to_arr(28).colvalue
       ,p_to_segment29              =>  g_to_arr(29).colvalue
       ,p_to_segment30              =>  g_to_arr(30).colvalue
       ,p_transfer_from_cc_id       =>  l_from_cc_id
       ,p_transfer_to_cc_id         =>  l_to_cc_id
       ,P_validate                  =>  false
       ,P_transaction_type          =>  'INSERT');
END IF;

end create_segment;


procedure get_min_competence
 (p_comp_id          in  varchar2,
  p_step_value       out nocopy varchar2) is


CURSOR get_min_step_value   IS
select
      min(rl.step_value)
from
      per_competences ce,
      per_rating_levels rl
where
      ce.competence_id = to_number(p_comp_id)    and
      rl.rating_scale_id = ce.rating_scale_id;


begin

    open  get_min_step_value;
    fetch get_min_step_value into p_step_value;
    close get_min_step_value;


end get_min_competence;

procedure get_max_competence
 (p_comp_id          in  varchar2,
  p_step_value       out nocopy varchar2) is


CURSOR get_max_step_value   IS
select
      max(rl.step_value)
from
      per_competences ce,
      per_rating_levels rl
where
      ce.competence_id = to_number(p_comp_id)    and
      rl.rating_scale_id = ce.rating_scale_id;


begin

    open  get_max_step_value;
    fetch get_max_step_value into p_step_value;
    close get_max_step_value;


end get_max_competence;



end ota_training_ss;

/
