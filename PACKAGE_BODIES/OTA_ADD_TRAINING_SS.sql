--------------------------------------------------------
--  DDL for Package Body OTA_ADD_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ADD_TRAINING_SS" AS
/* $Header: otaddwrs.pkb 120.2 2007/01/04 17:34:45 sschauha noship $ */

 g_package  varchar2(33)	:= ' ota_add_training_ss';  -- Global package name
 g_called_from  varchar2(1)	:= 'S' ;  -- Global variable to differentiate whether calling from review or submit


  /*
  ||===========================================================================
  || PROCEDURE: save_add_training
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will save additional training details in Transaction table
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
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE save_add_training(
      p_login_person_id               IN     NUMBER
    , p_item_type                     IN     VARCHAR2
    , p_item_key                      IN     VARCHAR2
    , p_activity_id                   IN     NUMBER
    , p_save_mode                     IN     VARCHAR2
    , p_error_message                 OUT NOCOPY    VARCHAR2
    , p_title                         IN     VARCHAR2
    , p_supplier                      IN     VARCHAR2
    , p_eq_ota_activity               IN     VARCHAR2
    , p_location                      IN     VARCHAR2
    , p_trntype                       IN     VARCHAR2
    , p_duration                      IN     VARCHAR2
    , p_duration_unit                 IN     VARCHAR2
    , p_status                        IN     VARCHAR2
    , p_completion_date               IN     DATE
    , p_award                         IN     VARCHAR2
    , p_score                         IN     VARCHAR2
    , p_internal_contact_person       IN     VARCHAR2  --This contains contact id
    , p_historyId                     IN     VARCHAR2
    , p_nth_information_category      IN     VARCHAR2
    , p_nth_information1              IN     VARCHAR2
    , p_nth_information2              IN     VARCHAR2
    , p_nth_information3              IN     VARCHAR2
    , p_nth_information4              IN     VARCHAR2
    , p_nth_information5              IN     VARCHAR2
    , p_nth_information6              IN     VARCHAR2
    , p_nth_information7              IN     VARCHAR2
    , p_nth_information8              IN     VARCHAR2
    , p_nth_information9              IN     VARCHAR2
    , p_nth_information10             IN     VARCHAR2
    , p_nth_information11             IN     VARCHAR2
    , p_nth_information12             IN     VARCHAR2
    , p_nth_information13             IN     VARCHAR2
    , p_nth_information14             IN     VARCHAR2
    , p_nth_information15             IN     VARCHAR2
    , p_nth_information16             IN     VARCHAR2
    , p_nth_information17             IN     VARCHAR2
    , p_nth_information18             IN     VARCHAR2
    , p_nth_information19             IN     VARCHAR2
    , p_nth_information20             IN     VARCHAR2
    , p_contact_name                  IN     VARCHAR2
    , p_activity_name                 IN     VARCHAR2
    , p_obj_ver_no                    IN     VARCHAR2
    , p_business_grp_id               IN     VARCHAR2
    , p_person_id                     IN     NUMBER
    , p_from                          IN     VARCHAR2
    , p_oafunc                        IN     VARCHAR2
    , p_processname                   IN     VARCHAR2
    , p_calledfrom                    IN     VARCHAR2
    , p_frommenu                      IN     VARCHAR2
    , p_org_id                        IN     VARCHAR2
    , p_transaction_mode              IN     VARCHAR2
    , p_check_changes_result          OUT NOCOPY    VARCHAR2
    , p_Status_Meaning                IN     VARCHAR2
    , p_Type_Meaning                  IN     VARCHAR2
  )  AS

  l_transaction_id                    NUMBER ;
  l_transaction_step_id               NUMBER ;
  l_trans_obj_vers_num                NUMBER ;
  l_count                             INTEGER ;
  l_transaction_table 	              hr_transaction_ss.transaction_table;
  l_review_item_name                  VARCHAR2(50);
  l_message_number                    VARCHAR2(10);
  l_result                            VARCHAR2(100) ;
  l_old_transaction_step_id           NUMBER;
  l_old_object_version_number         NUMBER;

  l_check_changes_result              NUMBER := 100;
  --
  BEGIN
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
  IF ( hr_transaction_api.transaction_step_exist
         (p_item_type => p_item_type
	     ,p_item_key => p_item_key
		 ,p_activity_id => p_activity_id) )  THEN

      hr_transaction_api.get_transaction_step_info
         (p_item_type             => p_item_type
		 ,p_item_key              => p_item_key
 		 ,p_activity_id           => p_activity_id
 		 ,p_transaction_step_id   => l_old_transaction_step_id
         ,p_object_version_number => l_old_object_version_number);

      hr_transaction_api.delete_transaction_step
         (p_validate                    => FALSE
         ,p_transaction_step_id         => l_old_transaction_step_id
         ,p_person_id                   => p_login_person_id
       	 ,p_object_version_number       => l_old_object_version_number);
  END IF;

  --If transaction mode is 'UPDATE' then check if any changes are made or not
  If (p_transaction_mode = 'UPDATE') Then
    check_changes
       (p_historyId
       ,to_number(p_internal_contact_person)
       ,p_title
       ,p_supplier
       ,p_trntype
       ,p_location
       ,p_completion_date
       ,p_award
       ,p_score
       ,to_number(p_duration)
       ,p_duration_unit
       ,to_number(p_eq_ota_activity)
       ,p_status
       ,p_nth_information_category
       ,p_nth_information1
       ,p_nth_information2
       ,p_nth_information3
       ,p_nth_information4
       ,p_nth_information5
       ,p_nth_information6
       ,p_nth_information7
       ,p_nth_information8
       ,p_nth_information9
       ,p_nth_information10
       ,p_nth_information11
       ,p_nth_information12
       ,p_nth_information13
       ,p_nth_information14
       ,p_nth_information15
       ,p_nth_information16
       ,p_nth_information17
       ,p_nth_information18
       ,p_nth_information19
       ,p_nth_information20
       ,l_check_changes_result);

    p_check_changes_result := l_check_changes_result;
    If (l_check_changes_result = 0) Then --Return if no changes are made
       Return;
    End If;
  End If;

  p_check_changes_result := l_check_changes_result;

  --
  -- Create a transaction step
  --
  hr_transaction_api.create_transaction_step
     (p_validate              => FALSE
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
  l_transaction_table(l_count).param_name := 'P_TITLE';
  l_transaction_table(l_count).param_value := p_title;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SUPPLIER';
  l_transaction_table(l_count).param_value := p_supplier;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EQ_OTA_ACTIVITY';
  l_transaction_table(l_count).param_value := p_eq_ota_activity;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LOCATION';
  l_transaction_table(l_count).param_value := p_location;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRNTYPE';
  l_transaction_table(l_count).param_value := p_trntype;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DURATION';
  l_transaction_table(l_count).param_value := p_duration;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DURATION_UNIT';
  l_transaction_table(l_count).param_value := p_duration_unit;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STATUS';
  l_transaction_table(l_count).param_value := p_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMPLETION_DATE';
  l_transaction_table(l_count).param_value := to_char(p_completion_date, hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_AWARD';
  l_transaction_table(l_count).param_value := p_award;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SCORE';
  l_transaction_table(l_count).param_value := p_score;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INTERNAL_CONTACT_PERSON';
  l_transaction_table(l_count).param_value := p_internal_contact_person;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HISTORYID';
  l_transaction_table(l_count).param_value := p_historyId;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION_CATEGORY';
  l_transaction_table(l_count).param_value := p_nth_information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION1';
  l_transaction_table(l_count).param_value := p_nth_information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION2';
  l_transaction_table(l_count).param_value := p_nth_information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION3';
  l_transaction_table(l_count).param_value := p_nth_information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION4';
  l_transaction_table(l_count).param_value := p_nth_information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION5';
  l_transaction_table(l_count).param_value := p_nth_information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION6';
  l_transaction_table(l_count).param_value := p_nth_information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION7';
  l_transaction_table(l_count).param_value := p_nth_information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION8';
  l_transaction_table(l_count).param_value := p_nth_information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION9';
  l_transaction_table(l_count).param_value := p_nth_information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION10';
  l_transaction_table(l_count).param_value := p_nth_information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION11';
  l_transaction_table(l_count).param_value := p_nth_information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION12';
  l_transaction_table(l_count).param_value := p_nth_information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION13';
  l_transaction_table(l_count).param_value := p_nth_information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION14';
  l_transaction_table(l_count).param_value := p_nth_information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION15';
  l_transaction_table(l_count).param_value := p_nth_information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION16';
  l_transaction_table(l_count).param_value := p_nth_information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION17';
  l_transaction_table(l_count).param_value := p_nth_information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION18';
  l_transaction_table(l_count).param_value := p_nth_information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION19';
  l_transaction_table(l_count).param_value := p_nth_information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NTH_INFORMATION20';
  l_transaction_table(l_count).param_value := p_nth_information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_NAME';
  l_transaction_table(l_count).param_value := p_contact_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTIVITY_NAME';
  l_transaction_table(l_count).param_value := p_activity_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJ_VER_NO';
  l_transaction_table(l_count).param_value := p_obj_ver_no;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GRP_ID';
  l_transaction_table(l_count).param_value := p_business_grp_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DELEGATE_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ORG_ID';
  l_transaction_table(l_count).param_value := p_org_id;
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
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FROM';
  l_transaction_table(l_count).param_value := p_from;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TRANSACTION_MODE';
  l_transaction_table(l_count).param_value := p_transaction_mode;
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

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STATUS_MEANING';
  l_transaction_table(l_count).param_value := p_Status_Meaning;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TYPE_MEANING';
  l_transaction_table(l_count).param_value := p_Type_Meaning;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => p_item_type
      ,p_item_key   => p_item_key
      ,p_name   => 'OTA_TRANSACTION_STEP_ID');

  WF_ENGINE.setitemattrnumber(p_item_type,
                              p_item_key,
                              'OTA_TRANSACTION_STEP_ID',
                              l_transaction_step_id);
-- bug 4146681
If p_from='REVIEW' Then
WF_ENGINE.setitemattrtext(p_item_type,
                              p_item_key,
                              'HR_RESTRICT_EDIT_ATTR',
                              'Y');
end if;
--bug 4146681

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
   --populate the p_error_message OUT variable
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
    p_error_message := 'save add trng'||hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

 END save_add_training;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_add_trg_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          IN the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes or vice-versa.  Hence, we need to use
--          the item_type item_key passed IN to retrieve the transaction record.
-- ---------------------------------------------------------------------------
PROCEDURE get_add_trg_data_from_tt (p_item_type                       IN  VARCHAR2
                                   ,p_item_key                        IN  VARCHAR2
                                   ,p_activity_id                     IN  VARCHAR2
                                   ,p_trans_rec_count                 OUT NOCOPY NUMBER
                                   ,p_person_id                       OUT NOCOPY NUMBER
                                   ,p_add_trg_data                    OUT NOCOPY VARCHAR2)
                                   IS
   l_trans_rec_count                  INTEGER DEFAULT 0;
   l_trans_step_ids                   hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums              hr_util_web.g_varchar2_tab_type;
   ln_index                           NUMBER  DEFAULT 0;
   l_trans_step_rows                  NUMBER  ;
   l_add_trg_data                     VARCHAR2(4000);

 BEGIN
         hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);

         get_add_trg_data_from_tt
                (p_transaction_step_id         => l_trans_step_ids(ln_index)
                ,p_add_trg_data                => l_add_trg_data);

              p_add_trg_data := l_add_trg_data;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END get_add_trg_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_add_trg_data_from_tt> ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------
PROCEDURE get_add_trg_data_from_tt (p_transaction_step_id             IN  NUMBER
                                   ,p_add_trg_data                    OUT NOCOPY VARCHAR2
)IS
 l_object_version_number        per_phones.object_version_number%type;
 l_title			            ota_notrng_histories.trng_title%TYPE;
 l_supplier		            	ota_notrng_histories.provider%TYPE;
 l_eq_ota_activity		        VARCHAR2(80);
 l_location			            ota_notrng_histories.centre%TYPE;
 l_trntype			            ota_notrng_histories.type%TYPE;
 l_duration			            VARCHAR2(50);
 l_duration_unit		        ota_notrng_histories.duration_units%TYPE;
 l_status			            ota_notrng_histories.status%TYPE;
 l_completion_date		        DATE;
 l_award			            ota_notrng_histories.award%TYPE;
 l_score			            ota_notrng_histories.rating%TYPE;
 l_internal_contact_person	    VARCHAR2(150);
 l_historyid                    VARCHAR2(50);
 l_nth_information_category     ota_notrng_histories.NTH_INFORMATION_CATEGORY%TYPE;
 l_nth_information1             ota_notrng_histories.NTH_INFORMATION1%TYPE;
 l_nth_information2             ota_notrng_histories.NTH_INFORMATION2%TYPE;
 l_nth_information3             ota_notrng_histories.NTH_INFORMATION3%TYPE;
 l_nth_information4             ota_notrng_histories.NTH_INFORMATION4%TYPE;
 l_nth_information5             ota_notrng_histories.NTH_INFORMATION5%TYPE;
 l_nth_information6             ota_notrng_histories.NTH_INFORMATION6%TYPE;
 l_nth_information7             ota_notrng_histories.NTH_INFORMATION7%TYPE;
 l_nth_information8             ota_notrng_histories.NTH_INFORMATION8%TYPE;
 l_nth_information9             ota_notrng_histories.NTH_INFORMATION9%TYPE;
 l_nth_information10            ota_notrng_histories.NTH_INFORMATION10%TYPE;
 l_nth_information11            ota_notrng_histories.NTH_INFORMATION11%TYPE;
 l_nth_information12            ota_notrng_histories.NTH_INFORMATION12%TYPE;
 l_nth_information13            ota_notrng_histories.NTH_INFORMATION13%TYPE;
 l_nth_information14            ota_notrng_histories.NTH_INFORMATION14%TYPE;
 l_nth_information15            ota_notrng_histories.NTH_INFORMATION15%TYPE;
 l_nth_information16            ota_notrng_histories.NTH_INFORMATION16%TYPE;
 l_nth_information17            ota_notrng_histories.NTH_INFORMATION17%TYPE;
 l_nth_information18            ota_notrng_histories.NTH_INFORMATION18%TYPE;
 l_nth_information19            ota_notrng_histories.NTH_INFORMATION19%TYPE;
 l_nth_information20            ota_notrng_histories.NTH_INFORMATION20%TYPE;
 l_contact_name	  	            VARCHAR2(80);
 l_activity_name                ota_activity_versions.version_name%TYPE;
 l_obj_ver_no                   VARCHAR2(80);
 l_business_grp_id              VARCHAR2(80);
 l_person_id                    per_all_people_f.person_id%TYPE;
 l_var_person_id                VARCHAR2(80);
 l_from                         VARCHAR2(100);
 l_org_id                       VARCHAR2(800);
 l_org_name                     hr_all_organization_units.name%TYPE;
 l_oafunc                       VARCHAR2(1000);
 l_processname                  VARCHAR2(1000);
 l_calledfrom                   VARCHAR2(1000);
 l_frommenu                     VARCHAR2(1000);
 l_transaction_mode             VARCHAR2(10);
 l_str_completion_date          varchar2(20);
 l_status_Meaning               Varchar2(80);
 l_Type_Meaning                 Varchar2(80);

 l_temp varchar2(150);
BEGIN

  l_historyid := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_HISTORYID');

  l_title := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TITLE');

  l_supplier := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUPPLIER');

  l_eq_ota_activity := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EQ_OTA_ACTIVITY');

  l_location := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOCATION');

  l_trntype := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRNTYPE');

  l_duration := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DURATION');

  l_duration_unit := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DURATION_UNIT');

  l_status := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_STATUS');

  l_completion_date := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COMPLETION_DATE');

  l_award := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_AWARD');

  l_score := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCORE');

  l_internal_contact_person := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INTERNAL_CONTACT_PERSON');

  l_nth_information_category := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION_CATEGORY');

  l_nth_information1  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION1');

  l_nth_information2  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION2');

  l_nth_information3  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION3');

  l_nth_information4  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION4');

  l_nth_information5  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION5');

  l_nth_information6  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION6');

  l_nth_information7  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION7');

  l_nth_information8  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION8');

  l_nth_information9  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION9');

  l_nth_information10  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION10');

  l_nth_information11  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION11');

  l_nth_information12  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION12');

  l_nth_information13  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION13');

  l_nth_information14  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION14');

  l_nth_information15  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION15');

  l_nth_information16  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION16');

  l_nth_information17  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION17');

  l_nth_information18  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION18');

  l_nth_information19  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION19');

  l_nth_information20  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTH_INFORMATION20');

  l_contact_name  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CONTACT_NAME');

  l_activity_name  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVITY_NAME');

  l_obj_ver_no  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OBJ_VER_NO');

  l_business_grp_id  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GRP_ID');

  l_person_id  := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DELEGATE_PERSON_ID');

  l_from  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FROM');

  l_transaction_mode    := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TRANSACTION_MODE');

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

  l_status_Meaning  := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_STATUS_MEANING');

  l_Type_Meaning    := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TYPE_MEANING');

  l_str_completion_date := to_char(l_completion_date, fnd_profile.value('ICX_DATE_FORMAT_MASK'));


-- Now string all the retreived items into p_add_trg_data
--
p_add_trg_data := nvl(l_historyid,'null')
		          ||'^'||nvl(l_title,'null')
              ||'^'||nvl(l_supplier,'null')
              ||'^'||nvl(l_eq_ota_activity,'null')
              ||'^'||nvl(l_location,'null')
              ||'^'||nvl(l_trntype,'null')
		          ||'^'||nvl(l_duration,'null')
              ||'^'||nvl(l_duration_unit,'null')
		          ||'^'||nvl(l_status,'null')
		          ||'^'||nvl(l_str_completion_date,'null')
              ||'^'||nvl(l_award,'null')
		          ||'^'||nvl(l_score,'null')
		          ||'^'||nvl(l_internal_contact_person,'null')
		          ||'^'||nvl(l_nth_information_category,'null')
		          ||'^'||nvl(l_nth_information1,'null')
		          ||'^'||nvl(l_nth_information2,'null')
	        	  ||'^'||nvl(l_nth_information3,'null')
		          ||'^'||nvl(l_nth_information4,'null')
       	      ||'^'||nvl(l_nth_information5,'null')
	        	  ||'^'||nvl(l_nth_information6,'null')
		          ||'^'||nvl(l_nth_information7,'null')
		          ||'^'||nvl(l_nth_information8,'null')
	        	  ||'^'||nvl(l_nth_information9,'null')
	        	  ||'^'||nvl(l_nth_information10,'null')
	        	  ||'^'||nvl(l_nth_information11,'null')
	        	  ||'^'||nvl(l_nth_information12,'null')
	        	  ||'^'||nvl(l_nth_information13,'null')
        		  ||'^'||nvl(l_nth_information14,'null')
	        	  ||'^'||nvl(l_nth_information15,'null')
        		  ||'^'||nvl(l_nth_information16,'null')
	        	  ||'^'||nvl(l_nth_information17,'null')
	        	  ||'^'||nvl(l_nth_information18,'null')
	        	  ||'^'||nvl(l_nth_information19,'null')
	        	  ||'^'||nvl(l_nth_information20,'null')
	        	  ||'^'||nvl(l_contact_name,'null')
	        	  ||'^'||nvl(l_activity_name,'null')
	        	  ||'^'||nvl(l_obj_ver_no,'null')
	        	  ||'^'||nvl(l_business_grp_id,'null')
	        	  ||'^'||nvl(l_person_id,0)
	        	  ||'^'||nvl(l_from,'null')
              ||'^'||nvl(l_oafunc,'null')
              ||'^'||nvl(l_processname,'null')
              ||'^'||nvl(l_calledfrom,'null')
              ||'^'||nvl(l_frommenu,'null')
	        	  ||'^'||nvl(l_transaction_mode,'null')
              ||'^'||nvl(l_status_Meaning,'null')
	        	  ||'^'||nvl(l_Type_Meaning,'null');

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END get_add_trg_data_from_tt;

PROCEDURE get_pending_transaction_data
         (p_processname                   IN     VARCHAR2,
          p_item_type                     IN     VARCHAR2,
          p_person_id                     IN     NUMBER,
          p_exclude_historyid             OUT NOCOPY    VARCHAR2,
          p_transaction_step_ids          OUT NOCOPY    VARCHAR2)    IS

 l_token                        varchar2(3) := null;
 l_token2                       varchar2(3) := null;
 l_exclude_historyid            VARCHAR2(2000):= null;
 l_temp_historyid               VARCHAR2(2000):= null;
 l_transaction_step_ids		    VARCHAR2(2000):= null;


Cursor cur_get_pending_trn_step_id     IS
Select
       hrtrns.transaction_step_id
From
       wf_item_activity_statuses    process
      ,wf_item_attribute_values     attribute2
      ,wf_process_activities        activity
      ,hr_api_transaction_steps     hrtrns
Where
       activity.activity_name      = p_processname
and    activity.process_item_type  = p_item_type
and    activity.activity_item_type = p_item_type
and    activity.instance_id        = process.process_activity
and    process.activity_status     = 'ACTIVE'
and    process.item_type           = p_item_type
and    hrtrns.update_person_id     = p_person_id
and    process.item_key            = attribute2.item_key
and    attribute2.item_type        = process.item_type
and    attribute2.name             = 'TRAN_SUBMIT'
and    attribute2.text_value       = 'Y'
and    process.item_key            = hrtrns.item_key
and    trim(upper(hrtrns.api_name)) = trim(upper(g_package ||'.PROCESS_API'))
and    hrtrns.item_type            = p_item_type;






BEGIN

      FOR c in cur_get_pending_trn_step_id --Bug 3590613
      LOOP

       l_temp_historyid :=
            hr_transaction_api.get_varchar2_value
            (p_transaction_step_id => c.transaction_step_id
            ,p_name                => 'P_HISTORYID');

       IF l_temp_historyid is not null then
          l_exclude_historyid :=  l_exclude_historyid || l_token ||  l_temp_historyid;
          l_token:= ',';
       END IF;

       l_transaction_step_ids := l_transaction_step_ids || l_token2 ||c.transaction_step_id;
       l_token2 := ',';
      END LOOP;

          p_transaction_step_ids  := l_transaction_step_ids;
          p_exclude_historyid     := l_exclude_historyid;


  EXCEPTION
		WHEN OTHERS THEN

        RAISE;
END;





/*PROCEDURE process_api
        (p_validate IN BOOLEAN ,p_transaction_step_id IN NUMBER) IS */
PROCEDURE process_api
        (p_validate IN BOOLEAN ,p_transaction_step_id IN NUMBER
        ,p_effective_date in varchar2) IS
 l_transaction_mode            VARCHAR2(10);
 l_from                        VARCHAR2(20);
 l_tran_submitted              VARCHAR2(1);

 l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;



BEGIN
  l_transaction_mode  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_TRANSACTION_MODE');
  l_from  := hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_FROM');

      hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);


       l_tran_submitted := wf_engine.GetItemAttrtext(itemtype => l_item_type
			                                ,itemkey  => l_item_key
                                            ,aname    => 'TRAN_SUBMIT');

       If (l_from = 'REVIEW') Then
          g_called_from := 'R' ;
       End if;

If (l_tran_submitted <> 'Y') then
savepoint validate_add_training;
    If (l_transaction_mode = 'INSERT') Then
        create_add_training_tt(p_validate => true, p_transaction_step_id => p_transaction_step_id);
    ElsIf (l_transaction_mode = 'UPDATE') Then
         update_add_training_tt(p_validate => true, p_transaction_step_id => p_transaction_step_id);
    End If;
rollback to validate_add_training;
Else
    If (l_transaction_mode = 'INSERT') Then
        create_add_training_tt(p_validate => p_validate, p_transaction_step_id => p_transaction_step_id);
    ElsIf (l_transaction_mode = 'UPDATE') Then
         update_add_training_tt(p_validate => p_validate, p_transaction_step_id => p_transaction_step_id);
    End If;
End If;


  EXCEPTION
		WHEN OTHERS THEN

        RAISE;
END process_api;


-- ---------------------------------------------------------------------------
-- ---------------------- < create_add_training_tt > ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id and creates
--          a additional training record.
-- ---------------------------------------------------------------------------

procedure create_add_training_tt
        (p_validate IN BOOLEAN, p_transaction_step_id IN NUMBER)
  is
 l_title		        	ota_notrng_histories.trng_title%TYPE;
 l_supplier		        	ota_notrng_histories.provider%TYPE;
 l_eq_ota_activity		    VARCHAR2(800);
 l_location		        	ota_notrng_histories.centre%TYPE;
 l_trntype		        	ota_notrng_histories.type%TYPE;
 l_duration		        	VARCHAR2(500);
 l_duration_unit	    	ota_notrng_histories.duration_units%TYPE;
 l_status			        ota_notrng_histories.status%TYPE;
 l_completion_date		    DATE;
 l_award			        ota_notrng_histories.award%TYPE;
 l_score			        ota_notrng_histories.rating%TYPE;
 l_internal_contact_person	VARCHAR2(500);
 l_historyid                VARCHAR2(500);
 l_nth_information_category ota_notrng_histories.NTH_INFORMATION_CATEGORY%TYPE;
 l_nth_information1         ota_notrng_histories.NTH_INFORMATION1%TYPE;
 l_nth_information2         ota_notrng_histories.NTH_INFORMATION2%TYPE;
 l_nth_information3         ota_notrng_histories.NTH_INFORMATION3%TYPE;
 l_nth_information4         ota_notrng_histories.NTH_INFORMATION4%TYPE;
 l_nth_information5         ota_notrng_histories.NTH_INFORMATION5%TYPE;
 l_nth_information6         ota_notrng_histories.NTH_INFORMATION6%TYPE;
 l_nth_information7         ota_notrng_histories.NTH_INFORMATION7%TYPE;
 l_nth_information8         ota_notrng_histories.NTH_INFORMATION8%TYPE;
 l_nth_information9         ota_notrng_histories.NTH_INFORMATION9%TYPE;
 l_nth_information10        ota_notrng_histories.NTH_INFORMATION10%TYPE;
 l_nth_information11        ota_notrng_histories.NTH_INFORMATION11%TYPE;
 l_nth_information12        ota_notrng_histories.NTH_INFORMATION12%TYPE;
 l_nth_information13        ota_notrng_histories.NTH_INFORMATION13%TYPE;
 l_nth_information14        ota_notrng_histories.NTH_INFORMATION14%TYPE;
 l_nth_information15        ota_notrng_histories.NTH_INFORMATION15%TYPE;
 l_nth_information16        ota_notrng_histories.NTH_INFORMATION16%TYPE;
 l_nth_information17        ota_notrng_histories.NTH_INFORMATION17%TYPE;
 l_nth_information18        ota_notrng_histories.NTH_INFORMATION18%TYPE;
 l_nth_information19        ota_notrng_histories.NTH_INFORMATION19%TYPE;
 l_nth_information20        ota_notrng_histories.NTH_INFORMATION20%TYPE;
 l_contact_name		        VARCHAR2(800);
 l_activity_name            ota_activity_versions.version_name%TYPE;
 l_obj_ver_no               VARCHAR2(800);
 l_business_grp_id          VARCHAR2(800);
 l_person_id                per_all_people_f.person_id%TYPE;
 l_org_id                   VARCHAR2(800);
 l_transaction_mode         VARCHAR2(10);
 l_some_warning             NUMBER := 0;
 l_from                     VARCHAR2(100);
 l_message                  VARCHAR2(1000) := NULL;

 l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;
BEGIN


      hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);

      SAVEPOINT create_tt;
      l_historyid := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_HISTORYID');
      l_title := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_TITLE');
      l_supplier := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SUPPLIER');
      l_eq_ota_activity := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EQ_OTA_ACTIVITY');
      l_location := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_LOCATION');
      l_trntype := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_TRNTYPE');
      l_duration := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DURATION');
      l_duration_unit := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DURATION_UNIT');
      l_status := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_STATUS');
      l_completion_date := hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_COMPLETION_DATE');
      l_award := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_AWARD');
      l_score := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SCORE');
      l_internal_contact_person := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_INTERNAL_CONTACT_PERSON');
      l_nth_information_category := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION_CATEGORY');
      l_nth_information1  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION1');
      l_nth_information2  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION2');
      l_nth_information3  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION3');
      l_nth_information4  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION4');
      l_nth_information5  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION5');
      l_nth_information6  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION6');
      l_nth_information7  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION7');
      l_nth_information8  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION8');
      l_nth_information9  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION9');
      l_nth_information10  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION10');
      l_nth_information11  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION11');
      l_nth_information12  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION12');
      l_nth_information13  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION13');
      l_nth_information14  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION14');
      l_nth_information15  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION15');
      l_nth_information16  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION16');
      l_nth_information17  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION17');
      l_nth_information18  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION18');
      l_nth_information19  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION19');
      l_nth_information20  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION20');
      l_contact_name  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONTACT_NAME');
      l_activity_name  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ACTIVITY_NAME');
      l_obj_ver_no  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_OBJ_VER_NO');
      l_business_grp_id  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BUSINESS_GRP_ID');
      l_person_id  := hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DELEGATE_PERSON_ID');

      l_org_id  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ORG_ID');

        create_add_training
          (p_effective_date		      => SYSDATE
          ,p_nota_history_id		  => l_historyid
          ,p_person_id			      => l_person_id
          ,p_contact_id         	  => l_internal_contact_person
          ,p_trng_title 			  => l_title
          ,p_provider                 => l_supplier
          ,p_type           		  => l_trntype
          ,p_centre          		  => l_location
          ,p_completion_date 		  => to_date(l_completion_date,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
          ,p_award            		  => l_award
          ,p_rating          		  => l_score
          ,p_duration       		  => l_duration
          ,p_duration_units           => l_duration_unit
          ,p_activity_version_id      => l_eq_ota_activity
          ,p_status                   => l_status
          ,p_verified_by_id           => NULL
          ,p_nth_information_category => l_nth_information_category
          ,p_nth_information1         => l_nth_information1
          ,p_nth_information2         => l_nth_information2
          ,p_nth_information3         => l_nth_information3
          ,p_nth_information4         => l_nth_information4
          ,p_nth_information5         => l_nth_information5
          ,p_nth_information6         => l_nth_information6
          ,p_nth_information7         => l_nth_information7
          ,p_nth_information8         => l_nth_information8
          ,p_nth_information9         => l_nth_information9
          ,p_nth_information10        => l_nth_information10
          ,p_nth_information11        => l_nth_information11
          ,p_nth_information12        => l_nth_information12
          ,p_nth_information13        => l_nth_information13
          ,p_nth_information15        => l_nth_information15
          ,p_nth_information16        => l_nth_information16
          ,p_nth_information17        => l_nth_information17
          ,p_nth_information18        => l_nth_information18
          ,p_nth_information19        => l_nth_information19
          ,p_nth_information20        => l_nth_information20
          ,p_org_id                   => NULL
          ,p_object_version_number    => l_obj_ver_no
          ,p_business_group_id        => l_business_grp_id
          ,p_nth_information14        => l_nth_information14
          ,p_customer_id		      => NULL
          ,p_organization_id		  => l_org_id
          ,p_some_warning		      => l_some_warning
          ,p_message                  => l_message
          ,p_item_type 			      => l_item_type
          ,p_item_key 			      => l_item_key
          );
 EXCEPTION
		WHEN OTHERS THEN
      rollback to create_tt;
      RAISE;
END create_add_training_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < update_add_training_tt > ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id and updates
--          corresponding additional training record.
-- ---------------------------------------------------------------------------
procedure update_add_training_tt
        (p_validate IN BOOLEAN, p_transaction_step_id IN NUMBER)
IS
 l_title		        	ota_notrng_histories.trng_title%TYPE;
 l_supplier		        	ota_notrng_histories.provider%TYPE;
 l_eq_ota_activity		    VARCHAR2(800);
 l_location		        	ota_notrng_histories.centre%TYPE;
 l_trntype		        	ota_notrng_histories.type%TYPE;
 l_duration		        	VARCHAR2(500);
 l_duration_unit	    	ota_notrng_histories.duration_units%TYPE;
 l_status			        ota_notrng_histories.status%TYPE;
 l_completion_date		    DATE;
 l_award			        ota_notrng_histories.award%TYPE;
 l_score			        ota_notrng_histories.rating%TYPE;
 l_internal_contact_person	VARCHAR2(500);
 l_historyid                VARCHAR2(500);
 l_nth_information_category ota_notrng_histories.NTH_INFORMATION_CATEGORY%TYPE;
 l_nth_information1         ota_notrng_histories.NTH_INFORMATION1%TYPE;
 l_nth_information2         ota_notrng_histories.NTH_INFORMATION2%TYPE;
 l_nth_information3         ota_notrng_histories.NTH_INFORMATION3%TYPE;
 l_nth_information4         ota_notrng_histories.NTH_INFORMATION4%TYPE;
 l_nth_information5         ota_notrng_histories.NTH_INFORMATION5%TYPE;
 l_nth_information6         ota_notrng_histories.NTH_INFORMATION6%TYPE;
 l_nth_information7         ota_notrng_histories.NTH_INFORMATION7%TYPE;
 l_nth_information8         ota_notrng_histories.NTH_INFORMATION8%TYPE;
 l_nth_information9         ota_notrng_histories.NTH_INFORMATION9%TYPE;
 l_nth_information10        ota_notrng_histories.NTH_INFORMATION10%TYPE;
 l_nth_information11        ota_notrng_histories.NTH_INFORMATION11%TYPE;
 l_nth_information12        ota_notrng_histories.NTH_INFORMATION12%TYPE;
 l_nth_information13        ota_notrng_histories.NTH_INFORMATION13%TYPE;
 l_nth_information14        ota_notrng_histories.NTH_INFORMATION14%TYPE;
 l_nth_information15        ota_notrng_histories.NTH_INFORMATION15%TYPE;
 l_nth_information16        ota_notrng_histories.NTH_INFORMATION16%TYPE;
 l_nth_information17        ota_notrng_histories.NTH_INFORMATION17%TYPE;
 l_nth_information18        ota_notrng_histories.NTH_INFORMATION18%TYPE;
 l_nth_information19        ota_notrng_histories.NTH_INFORMATION19%TYPE;
 l_nth_information20        ota_notrng_histories.NTH_INFORMATION20%TYPE;
 l_contact_name  		        VARCHAR2(800);
 l_activity_name            ota_activity_versions.version_name%TYPE;
 l_old_obj_ver_no           VARCHAR2(800);
 l_new_obj_ver_no           VARCHAR2(800) := NULL;
 l_business_grp_id          VARCHAR2(800);
 l_person_id                per_all_people_f.person_id%TYPE;
 l_org_id                   VARCHAR2(800);
 l_transaction_mode         VARCHAR2(10);
 l_some_warning             NUMBER := 0;
 l_from                     VARCHAR2(100);
 l_message                  VARCHAR2(1000) := NULL;

 l_item_type                HR_API_TRANSACTION_STEPS.ITEM_TYPE%TYPE;
 l_item_key                 HR_API_TRANSACTION_STEPS.ITEM_KEY%TYPE;
 l_activity_id              HR_API_TRANSACTION_STEPS.ACTIVITY_ID%TYPE;
 l_approval_reg_flag        wf_lookups.lookup_code%type;

BEGIN


      hr_transaction_api.get_transaction_step_info
         (p_transaction_step_id  => p_transaction_step_id
         ,p_item_type            => l_item_type
         ,p_item_key             => l_item_key
         ,p_activity_id          => l_activity_id);

      SAVEPOINT update_tt;
      l_historyid := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_HISTORYID');
      l_title := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_TITLE');
      l_supplier := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SUPPLIER');
      l_eq_ota_activity := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_EQ_OTA_ACTIVITY');
      l_location := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_LOCATION');
      l_trntype := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_TRNTYPE');
      l_duration := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DURATION');
      l_duration_unit := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DURATION_UNIT');
      l_status := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_STATUS');
      l_completion_date := hr_transaction_api.get_Date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_COMPLETION_DATE');
      l_award := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_AWARD');
      l_score := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SCORE');
      l_internal_contact_person := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_INTERNAL_CONTACT_PERSON');
      l_nth_information_category := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION_CATEGORY');
      l_nth_information1  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION1');
      l_nth_information2  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION2');
      l_nth_information3  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION3');
      l_nth_information4  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION4');
      l_nth_information5  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION5');
      l_nth_information6  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION6');
      l_nth_information7  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION7');
      l_nth_information8  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION8');
      l_nth_information9  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION9');
      l_nth_information10  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION10');
      l_nth_information11  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION11');
      l_nth_information12  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION12');
      l_nth_information13  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION13');
      l_nth_information14  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION14');
      l_nth_information15  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION15');
      l_nth_information16  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION16');
      l_nth_information17  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION17');
      l_nth_information18  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION18');
      l_nth_information19  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION19');
      l_nth_information20  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_NTH_INFORMATION20');
      l_contact_name  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONTACT_NAME');
      l_activity_name  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ACTIVITY_NAME');
      l_old_obj_ver_no  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_OBJ_VER_NO');
      l_business_grp_id  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BUSINESS_GRP_ID');
      l_person_id  := hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DELEGATE_PERSON_ID');

      l_org_id  := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_ORG_ID');


       l_approval_reg_flag := wf_engine.GetActivityAttrText(itemtype => l_item_type
			                                ,itemkey  => l_item_key
                                                        ,actid    => l_activity_id
                                                        ,aname    => 'HR_APPROVAL_REQ_FLAG');

--Bug#2508100  hdshah Below if condition corrected.
--        if l_approval_reg_flag <> 'NO' then
        if (l_approval_reg_flag <> 'NO' and p_validate) then
            chk_pending_approval
                               (p_nota_history_id => l_historyid
                               ,p_person_id => l_person_id) ;
        end if;


        update_add_training
          (p_effective_date		       => SYSDATE
          ,p_nota_history_id		   => l_historyid
          ,p_person_id			       => l_person_id
          ,p_contact_id         	   => l_internal_contact_person
          ,p_trng_title 			   => l_title
          ,p_provider                  => l_supplier
          ,p_type           		   => l_trntype
          ,p_centre          		   => l_location
          ,p_completion_date 		   => to_date(l_completion_date,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
          ,p_award            		   => l_award
          ,p_rating          		   => l_score
          ,p_duration       	  	   => l_duration
          ,p_duration_units            => l_duration_unit
          ,p_activity_version_id       => l_eq_ota_activity
          ,p_status                    => l_status
          ,p_verified_by_id            => NULL
          ,p_nth_information_category  => l_nth_information_category
          ,p_nth_information1          => l_nth_information1
          ,p_nth_information2          => l_nth_information2
          ,p_nth_information3          => l_nth_information3
          ,p_nth_information4          => l_nth_information4
          ,p_nth_information5          => l_nth_information5
          ,p_nth_information6          => l_nth_information6
          ,p_nth_information7          => l_nth_information7
          ,p_nth_information8          => l_nth_information8
          ,p_nth_information9          => l_nth_information9
          ,p_nth_information10         => l_nth_information10
          ,p_nth_information11         => l_nth_information11
          ,p_nth_information12         => l_nth_information12
          ,p_nth_information13         => l_nth_information13
          ,p_nth_information15         => l_nth_information15
          ,p_nth_information16         => l_nth_information16
          ,p_nth_information17         => l_nth_information17
          ,p_nth_information18         => l_nth_information18
          ,p_nth_information19         => l_nth_information19
          ,p_nth_information20         => l_nth_information20
          ,p_org_id                    => NULL
          ,p_old_object_version_number => l_old_obj_ver_no
          ,p_new_object_version_number => l_new_obj_ver_no
          ,p_business_group_id         => l_business_grp_id
          ,p_nth_information14         => l_nth_information14
          ,p_customer_id			   => NULL
          ,p_organization_id	  	   => l_org_id
          ,p_some_warning		       => l_some_warning
          ,p_message                   => l_message
          ,p_item_type 			       => l_item_type
          ,p_item_key 			       => l_item_key
          );
 EXCEPTION
		WHEN OTHERS THEN
      rollback to update_tt;
      RAISE;
END update_add_training_tt;


-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to delete additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be deleted.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_add_training
                  ( p_nota_history_id IN  OTA_NOTRNG_HISTORIES.NOTA_HISTORY_ID%TYPE
                  , p_trng_title 			IN 	VARCHAR2
                  , p_item_type       IN   WF_ITEMS.ITEM_TYPE%TYPE
                  , p_item_key        IN   WF_ITEMS.ITEM_TYPE%TYPE
                  , p_message         OUT NOCOPY VARCHAR2
                  ) IS

  CURSOR c_get_obj_ver_no  IS
  SELECT OBJECT_VERSION_NUMBER
  FROM OTA_NOTRNG_HISTORIES
  WHERE NOTA_HISTORY_ID = p_nota_history_id;

  l_obj_ver_no      OTA_NOTRNG_HISTORIES.OBJECT_VERSION_NUMBER%TYPE;
  l_proc            VARCHAR2(72) := 'Delete_Add_Training';

BEGIN

   OPEN  c_get_obj_ver_no;
   FETCH c_get_obj_ver_no INTO l_obj_ver_no;
   CLOSE c_get_obj_ver_no;

   ota_nhs_del.del( p_nota_history_id, l_obj_ver_no );

   p_message := 'S';

--set workflow attributes for notification
  /*WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'PROCESS_DISPLAY_NAME',
                            'External Training '); */

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_EVENT_TITLE',
                            p_trng_title);

EXCEPTION
--
   WHEN OTHERS THEN
--
--      p_message := SQLCODE||': '||SUBSTR(SQLERRM, 1, 950);
      p_message := fnd_message.get();
      hr_utility.set_location('Leaving:'||g_package||l_proc, 40);
 --
END delete_add_training;

-- ----------------------------------------------------------------------------
-- |-----------------------------< create_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to create additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE create_add_training
  (p_effective_date                IN   DATE
  ,p_nota_history_id               OUT NOCOPY NUMBER
  ,p_person_id		               IN 	NUMBER
  ,p_contact_id		               IN 	NUMBER
  ,p_trng_title 			       IN 	VARCHAR2
  ,p_provider                      IN 	VARCHAR2
  ,p_type           		       IN 	VARCHAR2
  ,p_centre          		       IN 	VARCHAR2
  ,p_completion_date 		       IN 	DATE
  ,p_award            		       IN 	VARCHAR2
  ,p_rating          		       IN 	VARCHAR2
  ,p_duration       		       IN 	NUMBER
  ,p_duration_units                IN 	VARCHAR2
  ,p_activity_version_id           IN 	NUMBER
  ,p_status                        IN 	VARCHAR2
  ,p_verified_by_id                IN 	NUMBER
  ,p_nth_information_category      IN 	VARCHAR2
  ,p_nth_information1              IN 	VARCHAR2
  ,p_nth_information2              IN 	VARCHAR2
  ,p_nth_information3              IN 	VARCHAR2
  ,p_nth_information4              IN 	VARCHAR2
  ,p_nth_information5              IN 	VARCHAR2
  ,p_nth_information6              IN 	VARCHAR2
  ,p_nth_information7              IN	VARCHAR2
  ,p_nth_information8              IN 	VARCHAR2
  ,p_nth_information9              IN 	VARCHAR2
  ,p_nth_information10             IN 	VARCHAR2
  ,p_nth_information11             IN 	VARCHAR2
  ,p_nth_information12             IN 	VARCHAR2
  ,p_nth_information13             IN 	VARCHAR2
  ,p_nth_information15             IN 	VARCHAR2
  ,p_nth_information16             IN 	VARCHAR2
  ,p_nth_information17             IN 	VARCHAR2
  ,p_nth_information18             IN 	VARCHAR2
  ,p_nth_information19             IN 	VARCHAR2
  ,p_nth_information20             IN 	VARCHAR2
  ,p_org_id                        IN 	NUMBER
  ,p_object_version_number         OUT NOCOPY 	NUMBER
  ,p_business_group_id             IN 	NUMBER
  ,p_nth_information14             IN 	VARCHAR2
  ,p_customer_id			       IN 	NUMBER
  ,p_organization_id		       IN 	NUMBER
  ,p_some_warning                  OUT NOCOPY 	NUMBER
  ,p_message                       OUT NOCOPY  VARCHAR2
  ,p_item_type 			           IN   WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key 			           IN   WF_ITEMS.ITEM_TYPE%TYPE

  ) IS
  --
  -- Declare cursors and local variables
  --
   l_some_warning               BOOLEAN;
   l_proc                       VARCHAR2(72) := 'Create_Add_Training';
   l_learner_name               per_all_people_f.full_name%TYPE;

BEGIN


  OTA_NHS_API.create_non_ota_histories
                (p_validate 		        => false
                ,p_effective_date		    => p_effective_date
                ,p_nota_history_id	    	=> p_nota_history_id
                ,p_person_id			    => p_person_id
                ,p_contact_id         	    => p_contact_id
                ,p_trng_title 			    => p_trng_title
                ,p_provider                 => p_provider
                ,p_type           		    => p_type
                ,p_centre          		    => p_centre
                ,p_completion_date 		    => p_completion_date
                ,p_award            		=> p_award
                ,p_rating          		    => p_rating
                ,p_duration       		    => p_duration
                ,p_duration_units           => p_duration_units
                ,p_activity_version_id      => p_activity_version_id
                ,p_status                   => p_status
                ,p_verified_by_id           => p_verified_by_id
                ,p_nth_information_category => p_nth_information_category
                ,p_nth_information1         => p_nth_information1
                ,p_nth_information2         => p_nth_information2
                ,p_nth_information3         => p_nth_information3
                ,p_nth_information4         => p_nth_information4
                ,p_nth_information5         => p_nth_information5
                ,p_nth_information6         => p_nth_information6
                ,p_nth_information7         => p_nth_information7
                ,p_nth_information8         => p_nth_information8
                ,p_nth_information9         => p_nth_information9
                ,p_nth_information10        => p_nth_information10
                ,p_nth_information11        => p_nth_information11
                ,p_nth_information12        => p_nth_information12
                ,p_nth_information13        => p_nth_information13
                ,p_nth_information15        => p_nth_information15
                ,p_nth_information16        => p_nth_information16
                ,p_nth_information17        => p_nth_information17
                ,p_nth_information18        => p_nth_information18
                ,p_nth_information19        => p_nth_information19
                ,p_nth_information20        => p_nth_information20
                ,p_org_id                   => p_org_id
                ,p_object_version_number    => p_object_version_number
                ,p_business_group_id        => p_business_group_id
                ,p_nth_information14        => p_nth_information14
                ,p_customer_id			    => p_customer_id
                ,p_organization_id		    => p_organization_id
                ,p_some_warning		        => l_some_warning
  );

  IF ( l_some_warning ) THEN
     p_some_warning  := 1;
  ELSE
     p_some_warning  := 0;
  END IF;
  p_message := 'S';
  l_learner_name := get_internal_contact_name(p_person_id);
 --set workflow attributes for notification

  hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'OTA_TRANSACTION_MODE');

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_TRANSACTION_MODE',
                            'INSERT');

 /* WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'PROCESS_DISPLAY_NAME',
                            'External Training '); */

--bug 3593080
  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'CURRENT_PERSON_DISPLAY_NAME',
                            l_learner_name);
--bug 3593080

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_EVENT_TITLE',
                            p_trng_title);

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_COURSE_END_DATE',
                            p_completion_date);

EXCEPTION
--
   WHEN OTHERS THEN
--
      p_some_warning  := -1;
      hr_utility.set_location('Leaving:'||g_package||l_proc, 40);
--      p_message := SQLCODE||': '||SUBSTR(SQLERRM, 1, 950);


      If g_called_from = 'R' Then
         g_called_From := 'S' ;
         RAISE  ;
      Else
         p_message := fnd_message.get();

      End if;

      If p_message is NULL then

            p_message := substr(SQLERRM,11,(length(SQLERRM)-10));

      End If;
--
END create_add_training;

-- ----------------------------------------------------------------------------
-- |-----------------------------< update_add_training >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used by self service application to update additional training records.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Additional Training data will be updated.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure update_add_training
  (p_effective_date                IN   DATE
  ,p_nota_history_id               IN	NUMBER
  ,p_person_id		               IN 	NUMBER
  ,p_contact_id		               IN 	NUMBER
  ,p_trng_title 		           IN 	VARCHAR2
  ,p_provider                      IN 	VARCHAR2
  ,p_type           		       IN 	VARCHAR2
  ,p_centre          		       IN 	VARCHAR2
  ,p_completion_date 		       IN 	DATE
  ,p_award            		       IN 	VARCHAR2
  ,p_rating          		       IN 	VARCHAR2
  ,p_duration       		       IN 	NUMBER
  ,p_duration_units                IN 	VARCHAR2
  ,p_activity_version_id           IN 	NUMBER
  ,p_status                        IN 	VARCHAR2
  ,p_verified_by_id                IN 	NUMBER
  ,p_nth_information_category      IN 	VARCHAR2
  ,p_nth_information1              IN 	VARCHAR2
  ,p_nth_information2              IN 	VARCHAR2
  ,p_nth_information3              IN 	VARCHAR2
  ,p_nth_information4              IN 	VARCHAR2
  ,p_nth_information5              IN 	VARCHAR2
  ,p_nth_information6              IN 	VARCHAR2
  ,p_nth_information7              IN	VARCHAR2
  ,p_nth_information8              IN 	VARCHAR2
  ,p_nth_information9              IN 	VARCHAR2
  ,p_nth_information10             IN 	VARCHAR2
  ,p_nth_information11             IN 	VARCHAR2
  ,p_nth_information12             IN 	VARCHAR2
  ,p_nth_information13             IN 	VARCHAR2
  ,p_nth_information14             IN 	VARCHAR2
  ,p_nth_information15             IN 	VARCHAR2
  ,p_nth_information16             IN 	VARCHAR2
  ,p_nth_information17             IN 	VARCHAR2
  ,p_nth_information18             IN 	VARCHAR2
  ,p_nth_information19             IN 	VARCHAR2
  ,p_nth_information20             IN 	VARCHAR2
  ,p_org_id                        IN 	NUMBER
  ,p_old_object_version_number     IN   NUMBER
  ,p_business_group_id             IN 	NUMBER
  ,p_customer_id                   IN 	NUMBER
  ,p_organization_id		       IN 	NUMBER
  ,p_some_warning                  OUT NOCOPY 	NUMBER
  ,p_message                       OUT NOCOPY  VARCHAR2
  ,p_new_object_version_number     OUT NOCOPY  NUMBER
  ,p_item_type 			           IN   WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key 			           IN   WF_ITEMS.ITEM_TYPE%TYPE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_some_warning               BOOLEAN;
  l_new_object_version_number  NUMBER;
  l_proc                       VARCHAR2(72) := 'Update_Add_Training';
  l_learner_name               per_all_people_f.full_name%TYPE;
  BEGIN
      hr_utility.set_location('Entering:'||g_package||l_proc, 40);

     l_new_object_version_number := p_old_object_version_number;

     OTA_NHS_API.update_non_ota_histories
                (p_validate 		        => false
                ,p_effective_date		    => p_effective_date
                ,p_nota_history_id		    => p_nota_history_id
                ,p_person_id			    => p_person_id
                ,p_contact_id         	    => p_contact_id
                ,p_trng_title 			    => p_trng_title
                ,p_provider                 => p_provider
                ,p_type           		    => p_type
                ,p_centre          		    => p_centre
                ,p_completion_date 		    => to_date(p_completion_date,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
                ,p_award            		=> p_award
                ,p_rating          	    	=> p_rating
                ,p_duration       		    => p_duration
                ,p_duration_units           => p_duration_units
                ,p_activity_version_id      => p_activity_version_id
                ,p_status                   => p_status
                ,p_verified_by_id           => p_verified_by_id
                ,p_nth_information_category => p_nth_information_category
                ,p_nth_information1         => p_nth_information1
                ,p_nth_information2         => p_nth_information2
                ,p_nth_information3         => p_nth_information3
                ,p_nth_information4         => p_nth_information4
                ,p_nth_information5         => p_nth_information5
                ,p_nth_information6         => p_nth_information6
                ,p_nth_information7         => p_nth_information7
                ,p_nth_information8         => p_nth_information8
                ,p_nth_information9         => p_nth_information9
                ,p_nth_information10        => p_nth_information10
                ,p_nth_information11        => p_nth_information11
                ,p_nth_information12        => p_nth_information12
                ,p_nth_information13        => p_nth_information13
                ,p_nth_information14        => p_nth_information14
                ,p_nth_information15        => p_nth_information15
                ,p_nth_information16        => p_nth_information16
                ,p_nth_information17        => p_nth_information17
                ,p_nth_information18        => p_nth_information18
                ,p_nth_information19        => p_nth_information19
                ,p_nth_information20        => p_nth_information20
                ,p_org_id                   => p_org_id
                ,p_object_version_number    => l_new_object_version_number
                ,p_business_group_id        => p_business_group_id
                ,p_customer_id			    => p_customer_id
--                ,p_organization_id		    => p_organization_id
                ,p_some_warning		        => l_some_warning
  );

  IF ( l_some_warning ) THEN
     p_some_warning  := 1;
  ELSE
     p_some_warning  := 0;
  END IF;

  p_message := 'S';
  l_learner_name := get_internal_contact_name(p_person_id);

 --set workflow attributes for notification

  hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'OTA_TRANSACTION_MODE');

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_TRANSACTION_MODE',
                            'UPDATE');

  /*WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'PROCESS_DISPLAY_NAME',
                            'External Training '); */

--bug 3593080
  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'CURRENT_PERSON_DISPLAY_NAME',
                            l_learner_name);
--bug 3593080
  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_EVENT_TITLE',
                            p_trng_title);

  WF_ENGINE.setitemattrtext(p_item_type,
                            p_item_key,
                           'OTA_COURSE_END_DATE',
                            p_completion_date);

  p_new_object_version_number := l_new_object_version_number;
  hr_utility.set_location('Leaving:'||g_package||l_proc, 40);
EXCEPTION
--
   WHEN OTHERS THEN
--
      p_some_warning  := -1;
      hr_utility.set_location('WHEN OTHERS Exception in :'||g_package||l_proc, 50);
--      p_message := SQLERRM;


      If g_called_from = 'R' Then
         g_called_From := 'S' ;
         RAISE  ;
      Else
          p_message := fnd_message.get();

      End If;

      If p_message is NULL then
                     p_message := substr(SQLERRM,11,(length(SQLERRM)-10));

      End If;
--
END update_add_training;

-- ----------------------------------------------------------------------------
-- |-----------------------------<additional_training_notify>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used by self service application to identify which notification (insert or update)
--   to send on commiting a transaction IN the table.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE additional_training_notify (itemtype	IN  WF_ITEMS.ITEM_TYPE%TYPE,
					                  itemkey	IN  WF_ITEMS.ITEM_KEY%TYPE,
                                      actid		IN  NUMBER,
					                  funcmode	IN  VARCHAR2,
					                  resultout OUT NOCOPY VARCHAR2)
IS

l_transaction_mode    VARCHAR2(10);

BEGIN

l_transaction_mode := wf_engine.GetItemAttrText(itemtype => itemtype
	    				                     ,itemkey  => itemkey
			    		                     ,aname    => 'OTA_TRANSACTION_MODE');

	IF (funcmode='RUN') THEN
       IF l_transaction_mode='INSERT' THEN
			resultout:='COMPLETE:INSERT';
	   ELSE
			resultout:='COMPLETE:UPDATE';
       END IF;
	END IF;

	RETURN;
END additional_training_notify;

procedure validate_add_training
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2) is

l_transaction_step_id 	number;

Begin

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


End validate_add_training;

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_internal_contact_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  is used by self service application to get the contact person name.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  Function  get_internal_contact_name
          ( Person_id     IN   per_all_people_f.person_id%TYPE) RETURN per_all_people_f.full_name%TYPE
  IS

    CURSOR c_get_person_name(p_person_id per_all_people_f.person_id%TYPE) IS
      SELECT full_name
      FROM per_all_people_f
      WHERE person_id = p_person_id
      AND sysdate BETWEEN effective_start_date and effective_end_date;  --Bug 5464327: date tracking of per_all_people_f is considered.

   l_person_full_name per_all_people_f.full_name%TYPE;
   l_proc             VARCHAR2(72) := 'get_internal_contact_name';
 BEGIN

   hr_utility.set_location('Entering:'||g_package||l_proc, 10);
   OPEN  c_get_person_name(person_id);
   FETCH c_get_person_name INTO l_person_full_name;
   CLOSE c_get_person_name;
      hr_utility.set_location('Leaving:'||g_package||l_proc, 20);
   RETURN l_person_full_name;

 EXCEPTION
 WHEN others THEN
      hr_utility.set_location('Leaving:'||g_package||l_proc, 30);
 RETURN null;

 END get_internal_contact_name;


-- ----------------------------------------------------------------------------
-- |-----------------------------< get_learner_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--   This function is used by self service application to get the contact person name.
--   The above implementation assumes that the contact would be found in the
--   per_all_poople_f table. It is ignoring the possiblity of the contact being
--   that of a customer. This function considers that.
-- In Parameters:
--    Contact_Id - person_id/contact id of employee/customer
--    Organization_Id - this parameter is used to decide if the per_all_people_f
--    or the ra_contacts needs to be queried. If this is null, then the incoming
--    person_id belongs to a Customers' contact and ra_contacts is queried.
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  Function  get_learner_name
          ( Person_id IN   ota_notrng_histories.contact_id%TYPE
           ,Organization_id IN ota_notrng_histories.organization_id%TYPE ) RETURN VARCHAR2
  IS

  CURSOR c_get_person_name(p_person_id per_all_people_f.person_id%TYPE) IS
      SELECT full_name
      FROM per_all_people_f
      WHERE person_id = p_person_id
      AND sysdate BETWEEN effective_start_date and effective_end_date;

  CURSOR c_get_contact_name(p_person_id hz_cust_account_roles.cust_account_role_id%TYPE) IS
      SELECT
         substrb( PARTY.person_last_name,1,50) || ',' ||
         substrb( PARTY.person_first_name,1,40) || ' ' ||
         party.person_pre_name_adjunct
      from HZ_CUST_ACCOUNT_ROLES acct_role,
           HZ_PARTIES party,
           HZ_RELATIONSHIPS rel,
           HZ_ORG_CONTACTS org_cont,
           HZ_PARTIES rel_party,
           HZ_CUST_ACCOUNTS role_acct
      where  acct_role.party_id = rel.party_id
         and acct_role.role_type = 'CONTACT'
         and org_cont.party_relationship_id = rel.relationship_id
         and rel.subject_id = party.party_id
         and rel.party_id = rel_party.party_id
         and rel.subject_table_name = 'HZ_PARTIES'
         and rel.object_table_name = 'HZ_PARTIES'
         and acct_role.cust_account_id = role_acct.cust_account_id
         and  role_acct.party_id = rel.object_id
         and acct_role.cust_account_role_id = p_person_id;

   l_person_full_name VARCHAR2(500);
   l_proc             VARCHAR2(72) := 'get_learner_name';
 BEGIN

   hr_utility.set_location('Entering:'||g_package||l_proc, 10);

   IF organization_id IS NULL THEN
     -- ra_contacts needs to be queried since org id is null
     OPEN c_get_contact_name(person_id);
     FETCH c_get_contact_name INTO l_person_full_name;
     CLOSE c_get_contact_name;
   ELSE
     OPEN  c_get_person_name(person_id);
     FETCH c_get_person_name INTO l_person_full_name;
     CLOSE c_get_person_name;
   END IF;
   hr_utility.set_location('Leaving:'||g_package||l_proc, 20);
   RETURN l_person_full_name;

 EXCEPTION
 WHEN others THEN
      hr_utility.set_location('Leaving:'||g_package||l_proc, 30);
 RETURN null;
 END get_learner_name;

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_custorg_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--   This function is used by self service application to get the name of the
--   customer or the organization depending on the not null id.
-- In Parameters:
--    Customer_Id - customer_id of the Customer
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION get_custorg_name(p_customer_id OTA_NOTRNG_HISTORIES.CUSTOMER_ID%TYPE,
                   p_organization_id OTA_NOTRNG_HISTORIES.ORGANIZATION_ID%TYPE)
  RETURN VARCHAR2 IS

    CURSOR c_get_customer_name IS
      SELECT
            substrb(PARTY.party_name,1,50)
      FROM
            HZ_PARTIES party,
            HZ_CUST_ACCOUNTS cust_acct
      WHERE
            CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
        AND CUST_ACCT.CUST_ACCOUNT_ID = p_customer_id;

    l_value VARCHAR2(500);
    l_proc VARCHAR2(50) := 'get_customer_name';

  BEGIN
    HR_UTILITY.SET_LOCATION('Entering:'||g_package||l_proc, 10);

    IF p_organization_id IS NOT NULL THEN
       SELECT OTA_GENERAL.get_org_name(p_organization_id) INTO l_value FROM DUAL;
    ELSE
       OPEN c_get_customer_name;
       FETCH c_get_customer_name INTO l_value;
       CLOSE c_get_customer_name;
    END IF;

    HR_UTILITY.SET_LOCATION('Leaving'||g_package||l_proc, 30);
    RETURN l_value;
 EXCEPTION
    WHEN others THEN
      HR_UTILITY.SET_LOCATION('Leaving:'||g_package||l_proc, 30);
      RETURN null;
  END get_custorg_name;

-- ----------------------------------------------------------------------------
-- |-----------------------------< check_changes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used by self service application to find out whether in 'update'
--   mode any changes are made or not by comparing it with data from database.
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_changes
  (p_nota_history_id               in	  NUMBER
  ,p_contact_id		                 in 	NUMBER
  ,p_trng_title 			             in 	VARCHAR2
  ,p_provider                      in 	VARCHAR2
  ,p_type           		           in 	VARCHAR2
  ,p_centre          		           in 	VARCHAR2
  ,p_completion_date 		           in 	date
  ,p_award            		         in 	VARCHAR2
  ,p_rating          		           in 	VARCHAR2
  ,p_duration       		           in 	NUMBER
  ,p_duration_units                in 	VARCHAR2
  ,p_activity_version_id           in 	NUMBER
  ,p_status                        in 	VARCHAR2
  ,p_nth_information_category      in 	VARCHAR2
  ,p_nth_information1              in 	VARCHAR2
  ,p_nth_information2              in 	VARCHAR2
  ,p_nth_information3              in 	VARCHAR2
  ,p_nth_information4              in 	VARCHAR2
  ,p_nth_information5              in 	VARCHAR2
  ,p_nth_information6              in 	VARCHAR2
  ,p_nth_information7              in	  VARCHAR2
  ,p_nth_information8              in 	VARCHAR2
  ,p_nth_information9              in 	VARCHAR2
  ,p_nth_information10             in 	VARCHAR2
  ,p_nth_information11             in 	VARCHAR2
  ,p_nth_information12             in 	VARCHAR2
  ,p_nth_information13             in 	VARCHAR2
  ,p_nth_information14             in 	VARCHAR2
  ,p_nth_information15             in 	VARCHAR2
  ,p_nth_information16             in 	VARCHAR2
  ,p_nth_information17             in 	VARCHAR2
  ,p_nth_information18             in 	VARCHAR2
  ,p_nth_information19             in 	VARCHAR2
  ,p_nth_information20             in 	VARCHAR2
  ,p_result 				               out nocopy  NUMBER
  ) Is

CURSOR c_get_training_data(p_history_id ota_notrng_histories.nota_history_id%TYPE) IS
Select
      ONH.Trng_Title,
      ONH.Provider,
      ONH.activity_version_id,
      ONH.centre,
      ONH.type,
      ONH.duration,
      ONH.duration_units,
      ONH.status,
      ONH.completion_date,
      ONH.award,
      ONH.rating,
      ONH.contact_id,
      ONH.nth_information_category,
      ONH.nth_information1,
      ONH.nth_information2,
      ONH.nth_information3,
      ONH.nth_information4,
      ONH.nth_information5,
      ONH.nth_information6,
      ONH.nth_information7,
      ONH.nth_information8,
      ONH.nth_information9,
      ONH.nth_information10,
      ONH.nth_information11,
      ONH.nth_information12,
      ONH.nth_information13,
      ONH.nth_information14,
      ONH.nth_information15,
      ONH.nth_information16,
      ONH.nth_information17,
      ONH.nth_information18,
      ONH.nth_information19,
      ONH.nth_information20
From
     OTA_NOTRNG_HISTORIES ONH
where
     ONH.nota_history_id = p_history_id;

l_proc             VARCHAR2(72) := 'check_changes';
l_changed_flag     BOOLEAN := false;
l_null_value       VARCHAR2(5) := '^%&*!';
l_null_value_number   NUMBER := -1000;
l_null_value_date  Date := sysdate - 1000;
BEGIN

   hr_utility.set_location('Entering:'||g_package||l_proc, 10);

   FOR trg_rec IN c_get_training_data(p_nota_history_id) LOOP

      If (Nvl(trim(trg_rec.Trng_Title),l_null_value) = Nvl(trim(p_trng_title),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.Provider),l_null_value) = Nvl(trim(p_provider),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trg_rec.activity_version_id,l_null_value_number) = Nvl(p_activity_version_id,l_null_value_number)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.centre),l_null_value) = Nvl(trim(p_centre),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.type),l_null_value) = Nvl(trim(p_type),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trg_rec.duration,l_null_value_number) = Nvl(p_duration,l_null_value_number)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.duration_units),l_null_value) = Nvl(trim(p_duration_units),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.status),l_null_value) = Nvl(trim(p_status),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trg_rec.completion_date,l_null_value_date) = Nvl(p_completion_date,l_null_value_date)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.award),l_null_value) = Nvl(trim(p_award),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.rating),l_null_value) = Nvl(trim(p_rating),l_null_value)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trg_rec.contact_id,l_null_value_number) = Nvl(p_contact_id,l_null_value_number)) Then
         Null;
      Else
         l_changed_flag := true;
         exit;
      End If;

      If (Nvl(trim(trg_rec.nth_information_category),l_null_value) = Nvl(trim(p_nth_information_category),l_null_value)) Then
            If (Nvl(trim(trg_rec.nth_information1),l_null_value) = Nvl(trim(p_nth_information1),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information2),l_null_value) = Nvl(trim(p_nth_information2),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information3),l_null_value) = Nvl(trim(p_nth_information3),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information4),l_null_value) = Nvl(trim(p_nth_information4),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information5),l_null_value) = Nvl(trim(p_nth_information5),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information6),l_null_value) = Nvl(trim(p_nth_information6),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information7),l_null_value) = Nvl(trim(p_nth_information7),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information8),l_null_value) = Nvl(trim(p_nth_information8),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information9),l_null_value) = Nvl(trim(p_nth_information9),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information10),l_null_value) = Nvl(trim(p_nth_information10),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information11),l_null_value) = Nvl(trim(p_nth_information11),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information12),l_null_value) = Nvl(trim(p_nth_information12),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information13),l_null_value) = Nvl(trim(p_nth_information13),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information14),l_null_value) = Nvl(trim(p_nth_information14),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information15),l_null_value) = Nvl(trim(p_nth_information15),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information16),l_null_value) = Nvl(trim(p_nth_information16),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information17),l_null_value) = Nvl(trim(p_nth_information17),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information18),l_null_value) = Nvl(trim(p_nth_information18),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information19),l_null_value) = Nvl(trim(p_nth_information19),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

            If (Nvl(trim(trg_rec.nth_information20),l_null_value) = Nvl(trim(p_nth_information20),l_null_value)) Then
               Null;
            Else
               l_changed_flag := true;
               exit;
            End If;

      Else
            l_changed_flag := true;
            exit;
      End If;
   END LOOP;

   If (l_changed_flag) Then
      p_result := 1;
   Else
      p_result := 0;
   End If;

   hr_utility.set_location('Leaving:'||g_package||l_proc, 20);
END check_changes;




Procedure chk_pending_approval
  (p_nota_history_id      in VARCHAR2
   ,p_person_id 			in number ) is

--
  l_proc  varchar2(72) := g_package||'chk_pending_approval';
  l_temp_historyid	varchar2(100) := null;



Cursor cur_get_pending_trn_step_id     IS
  Select
       hrtrns.transaction_step_id
From
       wf_item_activity_statuses    process
      ,wf_item_attribute_values     attribute2
      ,wf_process_activities        activity
      ,hr_api_transaction_steps     hrtrns
Where
       activity.activity_name      = 'OTA_ADDTRNG_JSP_PRC'
and    activity.process_item_type  = 'HRSSA'
and    activity.activity_item_type = 'HRSSA'
and    activity.instance_id        = process.process_activity
and    process.activity_status     = 'ACTIVE'
and    process.item_type           = 'HRSSA'
and    hrtrns.update_person_id     = p_person_id
and    process.item_key            = attribute2.item_key
and    attribute2.item_type        = process.item_type
and    attribute2.name             = 'TRAN_SUBMIT'
and    attribute2.text_value       = 'Y'
and    process.item_key            = hrtrns.item_key
and    trim(upper(hrtrns.api_name)) = trim(upper(g_package||'.PROCESS_API'))
and    hrtrns.item_type            = 'HRSSA';



BEGIN

      hr_utility.set_location('Entering:'||l_proc, 5);

      FOR c in cur_get_pending_trn_step_id --bug 3590613
      LOOP

       l_temp_historyid :=
            hr_transaction_api.get_varchar2_value
            (p_transaction_step_id => c.transaction_step_id
            ,p_name                => 'P_HISTORYID');

       if (l_temp_historyid is not null and l_temp_historyid = p_nota_history_id) then

        exit;

        null;

       end if;


      End LOOP;

      if (l_temp_historyid is not null and l_temp_historyid = p_nota_history_id) then


            fnd_message.set_name('OTA','OTA_13967_ADD_TRNG_PA_SS');
            fnd_message.raise_error;

      end if;

hr_utility.set_location('Entering:'||l_proc, 30);


end chk_pending_approval;








END ota_add_training_ss;

/
