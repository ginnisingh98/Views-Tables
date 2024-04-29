--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_SIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_SIT_SS" as
/* $Header: hrsitwrs.pkb 120.0 2005/05/31 02:46:37 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_PROCESS_SIT_SS';
-- ----------------------------------------------------------------------------
-- |-----------------------< save_transaction_data >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE save_transaction_data
    (p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_person_analysis_id        in   number
    ,p_pea_object_version_number in   number
    ,p_effective_date            in   date   default null
    ,p_date_from                 in   date   default null
    ,p_date_to                   in   date   default null
    ,p_analysis_criteria_id      in   number
    ,p_old_analysis_criteria_id  in   number
    ,p_business_group_id         in   number
    ,p_id_flex_num               in   number
    ,p_structure_code            in   varchar2
    ,p_structure_name            in   varchar2
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_action                    in   varchar2
    ,p_flow_mode                 in   varchar2 default null
    ,p_transaction_step_id       out nocopy number
    ,p_error_message             out nocopy long
    ,p_attribute_category        in   varchar2
    ,p_attribute1                in   varchar2
    ,p_attribute2                in   varchar2
    ,p_attribute3                in   varchar2
    ,p_attribute4                in   varchar2
    ,p_attribute5                in   varchar2
    ,p_attribute6                in   varchar2
    ,p_attribute7                in   varchar2
    ,p_attribute8                in   varchar2
    ,p_attribute9                in   varchar2
    ,p_attribute10               in   varchar2
    ,p_attribute11               in   varchar2
    ,p_attribute12               in   varchar2
    ,p_attribute13               in   varchar2
    ,p_attribute14               in   varchar2
    ,p_attribute15               in   varchar2
    ,p_attribute16               in   varchar2
    ,p_attribute17               in   varchar2
    ,p_attribute18               in   varchar2
    ,p_attribute19               in   varchar2
    ,p_attribute20               in   varchar2
  ) is
  l_transaction_id             number default null;
  l_trans_obj_vers_num         number default null;
  l_result                     varchar2(100) default null;
  l_count                      number default 0;
  l_transaction_table          hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_new_hire              boolean default false;
  l_proc   varchar2(72)  := g_package||'save_transaction_data';


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  then
    hr_utility.set_location('flow mode!=NULL AND is NewHire Registration:'||l_proc,10);
    l_new_hire := TRUE;
  end if;

  if l_new_hire then
    hr_utility.set_location('if l_new_hire then:'||l_proc,15);
    rollback;
  end if;
  --
  -- First, check if transaction id exists or not
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_utility.set_location('l_transaction_id is null THEN:'||l_proc,15);
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
     ,p_transaction_step_id   => p_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
  --
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ANALYSIS_ID';
  l_transaction_table(l_count).param_value := p_person_analysis_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PEA_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_pea_object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_FROM';
  l_transaction_table(l_count).param_value := to_char(p_date_from,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_TO';
  l_transaction_table(l_count).param_value := to_char(p_date_to,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ANALYSIS_CRITERIA_ID';
  l_transaction_table(l_count).param_value := p_analysis_criteria_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OLD_ANALYSIS_CRITERIA_ID';
  l_transaction_table(l_count).param_value := p_old_analysis_criteria_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ID_FLEX_NUM';
  l_transaction_table(l_count).param_value := p_id_flex_num;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STRUCTURE_CODE';
  l_transaction_table(l_count).param_value := p_structure_code;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STRUCTURE_NAME';
  l_transaction_table(l_count).param_value := p_structure_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTION';
  l_transaction_table(l_count).param_value := p_action;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';


  l_review_item_name :=
        wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                      itemkey   => p_item_key,
                                      actid     => p_activity_id,
                                      aname     => gv_wf_review_region_item);

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  -- Now save the transaction step
  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => p_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);

hr_utility.set_location('Exiting:'||l_proc, 25);
EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
END save_transaction_data;

/*
This procedure will get the transaction data for the given transaction step id
*/
-- ----------------------------------------------------------------------------
-- |-----------------------< get_transaction_data >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_transaction_data
    (p_transaction_step_id       in    number
    ,p_person_id                 out nocopy  number
    ,p_login_person_id           out nocopy  number
    ,p_person_analysis_id        out nocopy  number
    ,p_pea_object_version_number out nocopy  number
    ,p_effective_date            out nocopy  date
    ,p_date_from                 out nocopy  date
    ,p_date_to                   out nocopy  date
    ,p_analysis_criteria_id      out nocopy  number
    ,p_old_analysis_criteria_id  out nocopy  number
    ,p_business_group_id         out nocopy  number
    ,p_id_flex_num               out nocopy  number
    ,p_structure_code            out nocopy  varchar2
    ,p_structure_name            out nocopy  varchar2
    ,p_action                    out nocopy  varchar2
    ,p_error_message             out nocopy  long
    ,p_attribute_category        out nocopy varchar2
    ,p_attribute1                out nocopy varchar2
    ,p_attribute2                out nocopy varchar2
    ,p_attribute3                out nocopy varchar2
    ,p_attribute4                out nocopy varchar2
    ,p_attribute5                out nocopy varchar2
    ,p_attribute6                out nocopy varchar2
    ,p_attribute7                out nocopy varchar2
    ,p_attribute8                out nocopy varchar2
    ,p_attribute9                out nocopy varchar2
    ,p_attribute10               out nocopy varchar2
    ,p_attribute11               out nocopy varchar2
    ,p_attribute12               out nocopy varchar2
    ,p_attribute13               out nocopy varchar2
    ,p_attribute14               out nocopy varchar2
    ,p_attribute15               out nocopy varchar2
    ,p_attribute16               out nocopy varchar2
    ,p_attribute17               out nocopy varchar2
    ,p_attribute18               out nocopy varchar2
    ,p_attribute19               out nocopy varchar2
    ,p_attribute20               out nocopy varchar2
  ) is

   l_trans_step_id                    number default null;
   l_trans_obj_vers_num               number default null;
   l_trans_rec_count                  integer default 0;
   l_proc   varchar2(72)  := g_package||'get_transaction_data';

BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');

-- start registration
-- If its a new user registration flow then the personId which is coming
-- from transaction table will not be valid because the person has just been
-- created by the process_api of the hr_process_person_ss.process_api.
-- We can get that person Id and assignment id by making a call
-- to the global parameters but we need to branch out the code.
-- We also need the latest Object version Number not the one on transaction tbl

-- adding the session id check to avoid connection pooling problems.
  if (( hr_process_person_ss.g_person_id is not null) and
                (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
  then
    hr_utility.set_location('If it is ICX_SEC.G_SESSION_ID:'||l_proc,10);
    p_person_id := hr_process_person_ss.g_person_id;
  end if;

-- end registration
--

--
  p_login_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOGIN_PERSON_ID');
--
  p_person_analysis_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ANALYSIS_ID');
--
  p_pea_object_version_number := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PEA_OBJECT_VERSION_NUMBER');
--
  p_effective_date:= hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');
--
  p_date_from:= hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_FROM');
--
  p_date_to:= hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_TO');
--
  p_analysis_criteria_id:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ANALYSIS_CRITERIA_ID');
--
  p_old_analysis_criteria_id:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OLD_ANALYSIS_CRITERIA_ID');
--
  p_business_group_id:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
  p_id_flex_num:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ID_FLEX_NUM');
--
  p_structure_code:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_STRUCTURE_CODE');
--
  p_structure_name:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_STRUCTURE_NAME');
--
  p_action:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTION');

--
  p_attribute_category:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_CATEGORY');

--
  p_attribute1:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE1');

--
  p_attribute2:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE2');

--
  p_attribute3:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE3');

--
  p_attribute4:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE4');

--
  p_attribute5:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE5');

--
  p_attribute6:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE6');

--
  p_attribute7:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE7');

--
  p_attribute8:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE8');

--
  p_attribute9:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE9');

--
  p_attribute10:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE10');

--
  p_attribute11:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE11');

--
  p_attribute12:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE12');

--
  p_attribute13:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE13');

--
  p_attribute14:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE14');

--
  p_attribute15:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE15');

--
  p_attribute16:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE16');

--
  p_attribute17:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE17');

--
  p_attribute18:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE18');

--
  p_attribute19:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE19');

--
  p_attribute20:= hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE20');


hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
END get_transaction_data;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_sit >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_sit
  (p_validate                  in    number default 1
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_id_flex_num               in    number
  ,p_effective_date            in    date
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_analysis_criteria_id      in    number
  ,p_person_analysis_id        out nocopy  number
  ,p_pea_object_version_number out nocopy  number
  ,p_login_person_id           in    number
  ,p_item_type                 in    varchar2
  ,p_item_key                  in    varchar2
  ,p_activity_id               in    number
  ,p_action                    in    varchar2
  ,p_save_mode                 in    varchar2 default null
  ,p_error_message             out nocopy  long
    ,p_attribute_category        in   varchar2
    ,p_attribute1                in   varchar2
    ,p_attribute2                in   varchar2
    ,p_attribute3                in   varchar2
    ,p_attribute4                in   varchar2
    ,p_attribute5                in   varchar2
    ,p_attribute6                in   varchar2
    ,p_attribute7                in   varchar2
    ,p_attribute8                in   varchar2
    ,p_attribute9                in   varchar2
    ,p_attribute10               in   varchar2
    ,p_attribute11               in   varchar2
    ,p_attribute12               in   varchar2
    ,p_attribute13               in   varchar2
    ,p_attribute14               in   varchar2
    ,p_attribute15               in   varchar2
    ,p_attribute16               in   varchar2
    ,p_attribute17               in   varchar2
    ,p_attribute18               in   varchar2
    ,p_attribute19               in   varchar2
    ,p_attribute20               in   varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'insert_sit';
  l_analysis_criteria_id       number;
  l_analysis_criteria_rec      hr_process_sit_ss.per_analysis_criteria_rec;
  l_error_message              long default null;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);


  -- Get the segments from the ccid
     l_analysis_criteria_rec := get_segments_from_ccid(p_analysis_criteria_id);

  --
  -- Call API Create SIT
  --
  hr_sit_api.create_sit(
     p_validate                  => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
    ,p_person_id                 => p_person_id
    ,p_business_group_id         => p_business_group_id
    ,p_id_flex_num               => p_id_flex_num
    ,p_effective_date            => p_effective_date
    ,p_date_from                 => p_date_from
    ,p_date_to                   => p_date_to
    ,p_segment1                  => l_analysis_criteria_rec.segment1
    ,p_segment2                  => l_analysis_criteria_rec.segment2
    ,p_segment3                  => l_analysis_criteria_rec.segment3
    ,p_segment4                  => l_analysis_criteria_rec.segment4
    ,p_segment5                  => l_analysis_criteria_rec.segment5
    ,p_segment6                  => l_analysis_criteria_rec.segment6
    ,p_segment7                  => l_analysis_criteria_rec.segment7
    ,p_segment8                  => l_analysis_criteria_rec.segment8
    ,p_segment9                  => l_analysis_criteria_rec.segment9
    ,p_segment10                 => l_analysis_criteria_rec.segment10
    ,p_segment11                 => l_analysis_criteria_rec.segment11
    ,p_segment12                 => l_analysis_criteria_rec.segment12
    ,p_segment13                 => l_analysis_criteria_rec.segment13
    ,p_segment14                 => l_analysis_criteria_rec.segment14
    ,p_segment15                 => l_analysis_criteria_rec.segment15
    ,p_segment16                 => l_analysis_criteria_rec.segment16
    ,p_segment17                 => l_analysis_criteria_rec.segment17
    ,p_segment18                 => l_analysis_criteria_rec.segment18
    ,p_segment19                 => l_analysis_criteria_rec.segment19
    ,p_segment20                 => l_analysis_criteria_rec.segment20
    ,p_segment21                 => l_analysis_criteria_rec.segment21
    ,p_segment22                 => l_analysis_criteria_rec.segment22
    ,p_segment23                 => l_analysis_criteria_rec.segment23
    ,p_segment24                 => l_analysis_criteria_rec.segment24
    ,p_segment25                 => l_analysis_criteria_rec.segment25
    ,p_segment26                 => l_analysis_criteria_rec.segment26
    ,p_segment27                 => l_analysis_criteria_rec.segment27
    ,p_segment28                 => l_analysis_criteria_rec.segment28
    ,p_segment29                 => l_analysis_criteria_rec.segment29
    ,p_segment30                 => l_analysis_criteria_rec.segment30
    ,p_analysis_criteria_id      => l_analysis_criteria_id
    ,p_attribute_category        => p_attribute_category
    ,p_attribute1                => p_attribute1
    ,p_attribute2                => p_attribute2
    ,p_attribute3                => p_attribute3
    ,p_attribute4                => p_attribute4
    ,p_attribute5                => p_attribute5
    ,p_attribute6                => p_attribute6
    ,p_attribute7                => p_attribute7
    ,p_attribute8                => p_attribute8
    ,p_attribute9                => p_attribute9
    ,p_attribute10               => p_attribute10
    ,p_attribute11               => p_attribute11
    ,p_attribute12               => p_attribute12
    ,p_attribute13               => p_attribute13
    ,p_attribute14               => p_attribute14
    ,p_attribute15               => p_attribute15
    ,p_attribute16               => p_attribute16
    ,p_attribute17               => p_attribute17
    ,p_attribute18               => p_attribute18
    ,p_attribute19               => p_attribute19
    ,p_attribute20               => p_attribute20
    ,p_person_analysis_id        => p_person_analysis_id
    ,p_pea_object_version_number => p_pea_object_version_number
     );

  --

  hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
   WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    --
    -- A validation or unexpected error has occurred
    --
  --
end insert_sit;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_sit >-------------------------------|
-- ----------------------------------------------------------------------------
procedure update_sit
  (p_validate                  in     number default 1
  ,p_person_id                 in     number
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
  ,p_date_from                 in     date     default hr_api.g_date
  ,p_date_to                   in     date     default hr_api.g_date
  ,p_analysis_criteria_id      in     number
  ,p_login_person_id           in     number
  ,p_business_group_id         in     number
  ,p_id_flex_num               in     number
  ,p_item_type                 in     varchar2
  ,p_item_key                  in     varchar2
  ,p_activity_id               in     number
  ,p_action                    in    varchar2
  ,p_save_mode                 in     varchar2 default null
  ,p_error_message             out nocopy   long
  ,p_attribute_category        in   varchar2
  ,p_attribute1                in   varchar2
  ,p_attribute2                in   varchar2
  ,p_attribute3                in   varchar2
  ,p_attribute4                in   varchar2
  ,p_attribute5                in   varchar2
  ,p_attribute6                in   varchar2
  ,p_attribute7                in   varchar2
  ,p_attribute8                in   varchar2
  ,p_attribute9                in   varchar2
  ,p_attribute10               in   varchar2
  ,p_attribute11               in   varchar2
  ,p_attribute12               in   varchar2
  ,p_attribute13               in   varchar2
  ,p_attribute14               in   varchar2
  ,p_attribute15               in   varchar2
  ,p_attribute16               in   varchar2
  ,p_attribute17               in   varchar2
  ,p_attribute18               in   varchar2
  ,p_attribute19               in   varchar2
  ,p_attribute20               in   varchar2
  ) is
  --
  --
  l_proc                       varchar2(72) := g_package||'update_sit';
  l_analysis_criteria_id       number;
  l_analysis_criteria_rec      hr_process_sit_ss.per_analysis_criteria_rec;
  l_error_message              long default null;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);


  -- Get the segments from the ccid
     l_analysis_criteria_rec := get_segments_from_ccid(p_analysis_criteria_id);

  -- Call API Update SIT
  --
  hr_sit_api.update_sit(
     p_validate                  => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
    ,p_person_analysis_id        => p_person_analysis_id
    ,p_pea_object_version_number => p_pea_object_version_number
    ,p_date_from                 => p_date_from
    ,p_date_to                   => p_date_to
    ,p_segment1                  => l_analysis_criteria_rec.segment1
    ,p_segment2                  => l_analysis_criteria_rec.segment2
    ,p_segment3                  => l_analysis_criteria_rec.segment3
    ,p_segment4                  => l_analysis_criteria_rec.segment4
    ,p_segment5                  => l_analysis_criteria_rec.segment5
    ,p_segment6                  => l_analysis_criteria_rec.segment6
    ,p_segment7                  => l_analysis_criteria_rec.segment7
    ,p_segment8                  => l_analysis_criteria_rec.segment8
    ,p_segment9                  => l_analysis_criteria_rec.segment9
    ,p_segment10                 => l_analysis_criteria_rec.segment10
    ,p_segment11                 => l_analysis_criteria_rec.segment11
    ,p_segment12                 => l_analysis_criteria_rec.segment12
    ,p_segment13                 => l_analysis_criteria_rec.segment13
    ,p_segment14                 => l_analysis_criteria_rec.segment14
    ,p_segment15                 => l_analysis_criteria_rec.segment15
    ,p_segment16                 => l_analysis_criteria_rec.segment16
    ,p_segment17                 => l_analysis_criteria_rec.segment17
    ,p_segment18                 => l_analysis_criteria_rec.segment18
    ,p_segment19                 => l_analysis_criteria_rec.segment19
    ,p_segment20                 => l_analysis_criteria_rec.segment20
    ,p_segment21                 => l_analysis_criteria_rec.segment21
    ,p_segment22                 => l_analysis_criteria_rec.segment22
    ,p_segment23                 => l_analysis_criteria_rec.segment23
    ,p_segment24                 => l_analysis_criteria_rec.segment24
    ,p_segment25                 => l_analysis_criteria_rec.segment25
    ,p_segment26                 => l_analysis_criteria_rec.segment26
    ,p_segment27                 => l_analysis_criteria_rec.segment27
    ,p_segment28                 => l_analysis_criteria_rec.segment28
    ,p_segment29                 => l_analysis_criteria_rec.segment29
    ,p_segment30                 => l_analysis_criteria_rec.segment30
    ,p_attribute_category        => p_attribute_category
    ,p_attribute1                => p_attribute1
    ,p_attribute2                => p_attribute2
    ,p_attribute3                => p_attribute3
    ,p_attribute4                => p_attribute4
    ,p_attribute5                => p_attribute5
    ,p_attribute6                => p_attribute6
    ,p_attribute7                => p_attribute7
    ,p_attribute8                => p_attribute8
    ,p_attribute9                => p_attribute9
    ,p_attribute10               => p_attribute10
    ,p_attribute11               => p_attribute11
    ,p_attribute12               => p_attribute12
    ,p_attribute13               => p_attribute13
    ,p_attribute14               => p_attribute14
    ,p_attribute15               => p_attribute15
    ,p_attribute16               => p_attribute16
    ,p_attribute17               => p_attribute17
    ,p_attribute18               => p_attribute18
    ,p_attribute19               => p_attribute19
    ,p_attribute20               => p_attribute20
    ,p_analysis_criteria_id      => l_analysis_criteria_id
   );
  --

  hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    --
    -- A validation or unexpected error has occurred
    --
  --
end update_sit;
--
-- ----------------------------------------------------------------------------
-- |----------------------------<  delete_sit  >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_sit
  (p_validate                       in     number default 1
  ,p_person_id                      in     number
  ,p_person_analysis_id             in     number
  ,p_pea_object_version_number      in     number
  ,p_analysis_criteria_id           in     number
  ,p_login_person_id                in     number
  ,p_business_group_id              in     number
  ,p_id_flex_num                    in     number
  ,p_item_type                      in     varchar2
  ,p_item_key                       in     varchar2
  ,p_activity_id                    in     number
  ,p_action                    in    varchar2
  ,p_save_mode                      in     varchar2 default null
  ,p_error_message                  out nocopy   long
  ) IS
--
  l_error_message                 long default null;
l_proc                  varchar2(72) := g_package||'delete_sit';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Call API Update SIT
  --
  hr_sit_api.delete_sit(
     p_validate                       => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
    ,p_person_analysis_id             => p_person_analysis_id
    ,p_pea_object_version_number      => p_pea_object_version_number
  );

  --

  hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    --
    -- A validation or unexpected error has occurred
    --
  --
END delete_sit;

-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 default null
)is
  l_person_id                  number;
  l_login_person_id            number;
  l_person_analysis_id         number;
  l_pea_object_version_number  number;
  l_effective_date             date;
  l_date_from                  date;
  l_date_to                    date;
  l_analysis_criteria_id       number;
  l_old_analysis_criteria_id   number;
  l_business_group_id          number;
  l_id_flex_num                number;
  l_structure_code             varchar2(30);
  l_structure_name             varchar2(30);
  l_action                     varchar2(100);
  l_analysis_criteria_rec      hr_process_sit_ss.per_analysis_criteria_rec;
  l_error_message              long default null;
  l_attribute_category         PER_PERSON_ANALYSES.attribute_category%type;
  l_attribute1                 PER_PERSON_ANALYSES.attribute1%type;
  l_attribute2                 PER_PERSON_ANALYSES.attribute2%type;
  l_attribute3                 PER_PERSON_ANALYSES.attribute3%type;
  l_attribute4                 PER_PERSON_ANALYSES.attribute4%type;
  l_attribute5                 PER_PERSON_ANALYSES.attribute5%type;
  l_attribute6                 PER_PERSON_ANALYSES.attribute6%type;
  l_attribute7                 PER_PERSON_ANALYSES.attribute7%type;
  l_attribute8                 PER_PERSON_ANALYSES.attribute8%type;
  l_attribute9                 PER_PERSON_ANALYSES.attribute9%type;
  l_attribute10                PER_PERSON_ANALYSES.attribute10%type;
  l_attribute11                PER_PERSON_ANALYSES.attribute11%type;
  l_attribute12                PER_PERSON_ANALYSES.attribute12%type;
  l_attribute13                PER_PERSON_ANALYSES.attribute13%type;
  l_attribute14                PER_PERSON_ANALYSES.attribute14%type;
  l_attribute15                PER_PERSON_ANALYSES.attribute15%type;
  l_attribute16                PER_PERSON_ANALYSES.attribute16%type;
  l_attribute17                PER_PERSON_ANALYSES.attribute17%type;
  l_attribute18                PER_PERSON_ANALYSES.attribute18%type;
  l_attribute19                PER_PERSON_ANALYSES.attribute19%type;
  l_attribute20                PER_PERSON_ANALYSES.attribute20%type;
  l_proc   varchar2(72)  := g_package||'process_api';

  --2287707
  cursor csr_get_steps is
  select t1.transaction_step_id
    from HR_API_TRANSACTION_STEPS t1
   where t1.api_name = 'HR_PROCESS_SIT_SS.PROCESS_API'
     and  t1.transaction_id = (select t2.transaction_id
       from HR_API_TRANSACTION_STEPS t2
       where t2.transaction_step_id = p_transaction_step_id)
   order by transaction_step_id;

  l_transaction_step_id  HR_API_TRANSACTION_STEPS.transaction_step_id%TYPE;
  --2287707

BEGIN

  --2287707
  --process all the steps at once.
  --get all the steps in order
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN csr_get_steps;
  FETCH csr_get_steps INTO l_transaction_step_id;
  CLOSE csr_get_steps;

  --return if the p_transaction_step_id <> the first one
  IF l_transaction_step_id <> p_transaction_step_id THEN
    hr_utility.set_location('Exiting bcos:l_transaction_step_id!=p_transaction_step_id'||l_proc, 15);
    return;
  END IF;

  -- Do 3 times. The first time, we only process the deleted records.
  -- The second time, we process the updated records.
  -- The third time, we process the inserted records.
  hr_utility.set_location('Entering For Loop:i IN 1..3'||l_proc,20);
  FOR i IN 1..3 LOOP
  FOR v_steps IN csr_get_steps LOOP

    l_transaction_step_id := v_steps.transaction_step_id;

  -- Now get the transaction data for the given step
  get_transaction_data
    (p_transaction_step_id       => l_transaction_step_id
    ,p_person_id                 => l_person_id
    ,p_login_person_id           => l_login_person_id
    ,p_person_analysis_id        => l_person_analysis_id
    ,p_pea_object_version_number => l_pea_object_version_number
    ,p_effective_date            => l_effective_date
    ,p_date_from                 => l_date_from
    ,p_date_to                   => l_date_to
    ,p_analysis_criteria_id      => l_analysis_criteria_id
    ,p_old_analysis_criteria_id  => l_old_analysis_criteria_id
    ,p_business_group_id         => l_business_group_id
    ,p_id_flex_num               => l_id_flex_num
    ,p_structure_code            => l_structure_code
    ,p_structure_name            => l_structure_name
    ,p_action                    => l_action
    ,p_error_message             => l_error_message
    ,p_attribute_category        => l_attribute_category
    ,p_attribute1                => l_attribute1
    ,p_attribute2                => l_attribute2
    ,p_attribute3                => l_attribute3
    ,p_attribute4                => l_attribute4
    ,p_attribute5                => l_attribute5
    ,p_attribute6                => l_attribute6
    ,p_attribute7                => l_attribute7
    ,p_attribute8                => l_attribute8
    ,p_attribute9                => l_attribute9
    ,p_attribute10               => l_attribute10
    ,p_attribute11               => l_attribute11
    ,p_attribute12               => l_attribute12
    ,p_attribute13               => l_attribute13
    ,p_attribute14               => l_attribute14
    ,p_attribute15               => l_attribute15
    ,p_attribute16               => l_attribute16
    ,p_attribute17               => l_attribute17
    ,p_attribute18               => l_attribute18
    ,p_attribute19               => l_attribute19
    ,p_attribute20               => l_attribute20
   );


  IF i = 1 AND l_action = 'DELETE' OR
     i = 2 AND l_action = 'UPDATE' OR
     i = 2 AND l_action = 'INSERT' THEN

  -- Get the segments from the ccid
     l_analysis_criteria_rec := get_segments_from_ccid(l_analysis_criteria_id);

  -- Call the api depending on the action
  IF (l_action = 'INSERT') THEN
      hr_sit_api.create_sit(
         p_validate                  => false
        ,p_person_id                 => l_person_id
        ,p_business_group_id         => l_business_group_id
        ,p_id_flex_num               => l_id_flex_num
        ,p_effective_date            => l_effective_date
        ,p_date_from                 => l_date_from
        ,p_date_to                   => l_date_to
        ,p_segment1                  => l_analysis_criteria_rec.segment1
        ,p_segment2                  => l_analysis_criteria_rec.segment2
        ,p_segment3                  => l_analysis_criteria_rec.segment3
        ,p_segment4                  => l_analysis_criteria_rec.segment4
        ,p_segment5                  => l_analysis_criteria_rec.segment5
        ,p_segment6                  => l_analysis_criteria_rec.segment6
        ,p_segment7                  => l_analysis_criteria_rec.segment7
        ,p_segment8                  => l_analysis_criteria_rec.segment8
        ,p_segment9                  => l_analysis_criteria_rec.segment9
        ,p_segment10                 => l_analysis_criteria_rec.segment10
        ,p_segment11                 => l_analysis_criteria_rec.segment11
        ,p_segment12                 => l_analysis_criteria_rec.segment12
        ,p_segment13                 => l_analysis_criteria_rec.segment13
        ,p_segment14                 => l_analysis_criteria_rec.segment14
        ,p_segment15                 => l_analysis_criteria_rec.segment15
        ,p_segment16                 => l_analysis_criteria_rec.segment16
        ,p_segment17                 => l_analysis_criteria_rec.segment17
        ,p_segment18                 => l_analysis_criteria_rec.segment18
        ,p_segment19                 => l_analysis_criteria_rec.segment19
        ,p_segment20                 => l_analysis_criteria_rec.segment20
        ,p_segment21                 => l_analysis_criteria_rec.segment21
        ,p_segment22                 => l_analysis_criteria_rec.segment22
        ,p_segment23                 => l_analysis_criteria_rec.segment23
        ,p_segment24                 => l_analysis_criteria_rec.segment24
        ,p_segment25                 => l_analysis_criteria_rec.segment25
        ,p_segment26                 => l_analysis_criteria_rec.segment26
        ,p_segment27                 => l_analysis_criteria_rec.segment27
        ,p_segment28                 => l_analysis_criteria_rec.segment28
        ,p_segment29                 => l_analysis_criteria_rec.segment29
        ,p_segment30                 => l_analysis_criteria_rec.segment30
        ,p_attribute_category        => l_attribute_category
        ,p_attribute1                => l_attribute1
        ,p_attribute2                => l_attribute2
        ,p_attribute3                => l_attribute3
        ,p_attribute4                => l_attribute4
        ,p_attribute5                => l_attribute5
        ,p_attribute6                => l_attribute6
        ,p_attribute7                => l_attribute7
        ,p_attribute8                => l_attribute8
        ,p_attribute9                => l_attribute9
        ,p_attribute10               => l_attribute10
        ,p_attribute11               => l_attribute11
        ,p_attribute12               => l_attribute12
        ,p_attribute13               => l_attribute13
        ,p_attribute14               => l_attribute14
        ,p_attribute15               => l_attribute15
        ,p_attribute16               => l_attribute16
        ,p_attribute17               => l_attribute17
        ,p_attribute18               => l_attribute18
        ,p_attribute19               => l_attribute19
        ,p_attribute20               => l_attribute20
        ,p_analysis_criteria_id      => l_analysis_criteria_id
        ,p_person_analysis_id        => l_person_analysis_id
        ,p_pea_object_version_number => l_pea_object_version_number
       );
  ELSIF (l_action = 'UPDATE') THEN
      hr_sit_api.update_sit(
         p_validate                  => false
        ,p_person_analysis_id        => l_person_analysis_id
        ,p_pea_object_version_number => l_pea_object_version_number
        ,p_date_from                 => l_date_from
        ,p_date_to                   => l_date_to
        ,p_segment1                  => l_analysis_criteria_rec.segment1
        ,p_segment2                  => l_analysis_criteria_rec.segment2
        ,p_segment3                  => l_analysis_criteria_rec.segment3
        ,p_segment4                  => l_analysis_criteria_rec.segment4
        ,p_segment5                  => l_analysis_criteria_rec.segment5
        ,p_segment6                  => l_analysis_criteria_rec.segment6
        ,p_segment7                  => l_analysis_criteria_rec.segment7
        ,p_segment8                  => l_analysis_criteria_rec.segment8
        ,p_segment9                  => l_analysis_criteria_rec.segment9
        ,p_segment10                 => l_analysis_criteria_rec.segment10
        ,p_segment11                 => l_analysis_criteria_rec.segment11
        ,p_segment12                 => l_analysis_criteria_rec.segment12
        ,p_segment13                 => l_analysis_criteria_rec.segment13
        ,p_segment14                 => l_analysis_criteria_rec.segment14
        ,p_segment15                 => l_analysis_criteria_rec.segment15
        ,p_segment16                 => l_analysis_criteria_rec.segment16
        ,p_segment17                 => l_analysis_criteria_rec.segment17
        ,p_segment18                 => l_analysis_criteria_rec.segment18
        ,p_segment19                 => l_analysis_criteria_rec.segment19
        ,p_segment20                 => l_analysis_criteria_rec.segment20
        ,p_segment21                 => l_analysis_criteria_rec.segment21
        ,p_segment22                 => l_analysis_criteria_rec.segment22
        ,p_segment23                 => l_analysis_criteria_rec.segment23
        ,p_segment24                 => l_analysis_criteria_rec.segment24
        ,p_segment25                 => l_analysis_criteria_rec.segment25
        ,p_segment26                 => l_analysis_criteria_rec.segment26
        ,p_segment27                 => l_analysis_criteria_rec.segment27
        ,p_segment28                 => l_analysis_criteria_rec.segment28
        ,p_segment29                 => l_analysis_criteria_rec.segment29
        ,p_segment30                 => l_analysis_criteria_rec.segment30
        ,p_analysis_criteria_id      => l_analysis_criteria_id
        ,p_attribute_category        => l_attribute_category
        ,p_attribute1                => l_attribute1
        ,p_attribute2                => l_attribute2
        ,p_attribute3                => l_attribute3
        ,p_attribute4                => l_attribute4
        ,p_attribute5                => l_attribute5
        ,p_attribute6                => l_attribute6
        ,p_attribute7                => l_attribute7
        ,p_attribute8                => l_attribute8
        ,p_attribute9                => l_attribute9
        ,p_attribute10               => l_attribute10
        ,p_attribute11               => l_attribute11
        ,p_attribute12               => l_attribute12
        ,p_attribute13               => l_attribute13
        ,p_attribute14               => l_attribute14
        ,p_attribute15               => l_attribute15
        ,p_attribute16               => l_attribute16
        ,p_attribute17               => l_attribute17
        ,p_attribute18               => l_attribute18
        ,p_attribute19               => l_attribute19
        ,p_attribute20               => l_attribute20
       );
  ELSIF (l_action = 'DELETE') THEN
      hr_sit_api.delete_sit(
         p_validate                  => false
        ,p_person_analysis_id        => l_person_analysis_id
        ,p_pea_object_version_number => l_pea_object_version_number
       );

  END IF; --end of l_action if
  END IF; --end of i if
  END LOOP; --end of v_steps loop
  END LOOP; --end of i loop
  hr_utility.set_location('Exiting For Loop:'||l_proc,20);

  if l_error_message is not null then
    hr_utility.set_location('l_error_message is not null:'||l_proc,25);
    hr_utility.raise_error;
  end if;


hr_utility.set_location('Exiting:'||l_proc, 30);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    raise;

END process_api;



--
-- ----------------------------------------------------------------------------
-- |----------------------< get_segments_from_ccid >--------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_segments_from_ccid(p_analysis_criteria_id IN NUMBER)
         RETURN per_analysis_criteria_rec  IS

  cursor csr_criteria_segments is
  select *
  from per_analysis_criteria
  where analysis_criteria_id = p_analysis_criteria_id;


  l_criteria_segments csr_criteria_segments%ROWTYPE;
  l_analysis_criteria_rec hr_process_sit_ss.per_analysis_criteria_rec;
  l_proc   varchar2(72)  := g_package||'get_segments_from_ccid';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_criteria_segments;
  fetch csr_criteria_segments into l_criteria_segments;
  close csr_criteria_segments;

  -- populate the rec segments to be returned.
  l_analysis_criteria_rec.segment1 := l_criteria_segments.segment1;
  l_analysis_criteria_rec.segment2 := l_criteria_segments.segment2;
  l_analysis_criteria_rec.segment3 := l_criteria_segments.segment3;
  l_analysis_criteria_rec.segment4 := l_criteria_segments.segment4;
  l_analysis_criteria_rec.segment5 := l_criteria_segments.segment5;
  l_analysis_criteria_rec.segment6 := l_criteria_segments.segment6;
  l_analysis_criteria_rec.segment7 := l_criteria_segments.segment7;
  l_analysis_criteria_rec.segment8 := l_criteria_segments.segment8;
  l_analysis_criteria_rec.segment9 := l_criteria_segments.segment9;
  l_analysis_criteria_rec.segment10 := l_criteria_segments.segment10;
  l_analysis_criteria_rec.segment11 := l_criteria_segments.segment11;
  l_analysis_criteria_rec.segment12 := l_criteria_segments.segment12;
  l_analysis_criteria_rec.segment13 := l_criteria_segments.segment13;
  l_analysis_criteria_rec.segment14 := l_criteria_segments.segment14;
  l_analysis_criteria_rec.segment15 := l_criteria_segments.segment15;
  l_analysis_criteria_rec.segment16 := l_criteria_segments.segment16;
  l_analysis_criteria_rec.segment17 := l_criteria_segments.segment17;
  l_analysis_criteria_rec.segment18 := l_criteria_segments.segment18;
  l_analysis_criteria_rec.segment19 := l_criteria_segments.segment19;
  l_analysis_criteria_rec.segment20 := l_criteria_segments.segment20;
  l_analysis_criteria_rec.segment21 := l_criteria_segments.segment21;
  l_analysis_criteria_rec.segment22 := l_criteria_segments.segment22;
  l_analysis_criteria_rec.segment23 := l_criteria_segments.segment23;
  l_analysis_criteria_rec.segment24 := l_criteria_segments.segment24;
  l_analysis_criteria_rec.segment25 := l_criteria_segments.segment25;
  l_analysis_criteria_rec.segment26 := l_criteria_segments.segment26;
  l_analysis_criteria_rec.segment27 := l_criteria_segments.segment27;
  l_analysis_criteria_rec.segment28 := l_criteria_segments.segment28;
  l_analysis_criteria_rec.segment29 := l_criteria_segments.segment29;
  l_analysis_criteria_rec.segment30 := l_criteria_segments.segment30;


  hr_utility.set_location('Exiting:'||l_proc, 10);
  RETURN l_analysis_criteria_rec;

END get_segments_from_ccid;

-- ----------------------------------------------------------------------------
-- |-----------------------< del_transaction_data >---------------------------|
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function dels the transaction data for the given item type, item key
--  and activity id.
-- ----------------------------------------------------------------------------

PROCEDURE del_transaction_data
    (p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   varchar2
    ,p_login_person_id           in   varchar2
    ,p_flow_mode                 in   varchar2 default null
) IS
    l_proc   varchar2(72)  := g_package||'del_transaction_data';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
    hr_utility.set_location('Flow mode is NewHire Reg:'||l_proc,10);
    rollback;
  end if;
  hr_transaction_ss.delete_transaction_steps(
    p_item_type           => p_item_type
    ,p_item_key           => p_item_key
    ,p_actid              => p_activity_id
    ,p_login_person_id    => p_login_person_id
  );

hr_utility.set_location('Exiting:'||l_proc, 15);
END del_transaction_data;

end hr_process_sit_ss;

/
