--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_EIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_EIT_SS" as
/* $Header: hreitwrs.pkb 120.0 2005/05/31 00:05:15 appldev noship $ */
--
-- Package Variables
--
-- Package scope global variables.
 l_transaction_table hr_transaction_ss.transaction_table;
 l_count INTEGER := 0;
 l_praddr_ovrlap VARCHAR2(2);
 l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
 l_trs_object_version_number  hr_api_transaction_steps.object_version_number%type;
 g_package      varchar2(31)   := 'HR_PROCESS_EIT_SS';
 g_data_error            exception;
 l_message_number VARCHAR2(10);
 p_trans_rec_count integer;


 -- ----------------------------------------------------------------------------
-- |-----------------------< save_transaction_data >--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE save_transaction_data
    (p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_eit_type			 in   varchar2
    ,p_eit_type_id		 in   number
    ,p_eit_number		 in   number
    ,p_eit_table		 in   HR_EIT_STRUCTURE_TABLE
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_transaction_step_id       out nocopy  number
    ,p_error_message             out nocopy  varchar2
    ,p_active_view               in   varchar2
    ,p_active_row_id		 in   number
    ,p_flow_mode                 in   varchar2 default null
  ) is
  l_transaction_id             number default null;
  l_trans_obj_vers_num         number default null;
  l_trans_step_rows	       number default null;
  l_result                     varchar2(100) default null;
  l_count                      number default 0;
  l_transaction_table          hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_eit_number                 number := 0;
  l_proc   varchar2(72)  := g_package||'save_transaction_data';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  then
    hr_utility.trace('Calling RollBack:'||l_proc);
    rollback;
  end if;
  --
  -- First, check if transaction id exists or not
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);

  hr_utility.trace( 'hr_process_eit_ss.save_transaction_data' ||
           	    ' l_transaction_id: '|| l_transaction_id);

  --
  IF l_transaction_id is null THEN

     -- Start a Transaction
        hr_utility.trace('IF l_transaction_id is null THEN:'||l_proc);
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
  hr_utility.trace('hr_process_eit_ss.save_transaction_data' ||
           	   ' l_transaction_id: '||l_transaction_id);


  hr_transaction_api.get_transaction_step_info
        (p_Item_Type     => p_item_type
        ,p_Item_Key      => p_item_key
        ,p_activity_id   => p_activity_id
        ,p_transaction_step_id   => l_transaction_step_id
        ,p_object_version_number => l_trs_object_version_number);

  if(hr_utility.debug_enabled) then

    hr_utility.trace('hr_process_eit_ss.save_transaction_data' ||
              	     ' l_transaction_id: '||l_transaction_id||
            	     ' p_Item_Type: '||p_Item_Type||
            	     ' p_Item_Key: '||p_Item_Key||
            	     ' p_activity_id: '||p_activity_id||
            	     ' l_transaction_step_id: '||l_transaction_step_id||
                     ' l_trs_object_version_number: '||l_trs_object_version_number
                   );
  end if;

  IF l_transaction_step_id < 1 THEN
  hr_utility.trace('l_transaction_step_id < 1:'||l_proc);

       --There is no transaction step for this transaction.
       --Create a step within this new transaction
       hr_transaction_api.create_transaction_step
     		(p_validate              => false
     		,p_creator_person_id     => p_login_person_id
     		,p_transaction_id        => l_transaction_id
     		,p_api_name              => g_package || '.PROCESS_API'
     		,p_item_type             => p_item_type
     		,p_item_key              => p_item_key
     		,p_activity_id           => p_activity_id
     		,p_transaction_step_id   => l_transaction_step_id
     		,p_object_version_number => l_trs_object_version_number);
  END IF;

  hr_utility.trace('hr_process_eit_ss.save_transaction_data' ||
  	           ' l_transaction_step_id: '||l_transaction_step_id
  	         );


	l_count := 1;
 	l_transaction_table(l_count).param_name := 'P_PERSON_ID';
 	l_transaction_table(l_count).param_value := p_person_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
 	l_transaction_table(l_count).param_value := p_login_person_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EIT_TYPE';
 	l_transaction_table(l_count).param_value := p_eit_type;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EIT_TYPE_ID';
 	l_transaction_table(l_count).param_value := p_eit_type_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EIT_NUMBER';
 	l_transaction_table(l_count).param_value := p_eit_number;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

        l_review_item_name :=
                    wf_engine.GetActivityAttrText(itemtype  => p_item_type,
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

	-- for the update page when we rebuild the page after a
	-- save for later
 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ACTIVE_VIEW';
 	l_transaction_table(l_count).param_value := p_active_view;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ACTIVE_ROW_ID';
 	l_transaction_table(l_count).param_value := p_active_row_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

     if(hr_utility.debug_enabled) then

     	hr_utility.trace('hr_process_eit_ss.save_transaction_data' ||
       	      	      ' p_person_id: '||p_person_id||
           	      ' p_login_person_id: '||p_login_person_id||
           	      ' p_eit_type: '||p_eit_type||
           	      ' p_eit_number: '||p_eit_number);
    end if;

     l_eit_number := p_eit_number;

     hr_utility.trace('Entering For 1..l_eit_number:'||l_proc);
     FOR i in 1..l_eit_number LOOP



	l_count := l_count + 1;
  	l_transaction_table(l_count).param_name := 'P_ACTION_'||i;
  	l_transaction_table(l_count).param_value := p_eit_table(i).action;
  	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EXTRA_INFO_ID_'||i;
 	l_transaction_table(l_count).param_value := p_eit_table(i).extra_info_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER_'||i;
 	l_transaction_table(l_count).param_value := p_eit_table(i).object_version_number;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_INFORMATION_TYPE_'||i;
 	l_transaction_table(l_count).param_value := p_eit_table(i).information_type;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- Now add all the Descriptive flex fields into transactions tables

        l_count := l_count + 1; -- CONTEXT
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute_category;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute4;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute5;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute6;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute7;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute8;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute9;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute10;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute11;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute12;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).attribute20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION_CATEGORY_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information_category;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION1_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION2_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION3_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION4_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information4;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION5_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information5;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION6_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information6;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION7_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information7;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION8_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information8;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION9_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information9;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION10_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information10;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION11_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information11;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION12_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information12;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION13_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION14_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION15_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION16_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION17_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION18_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION19_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION20_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION21_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information21;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION22_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information22;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION23_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information23;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION24_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information24;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION25_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information25;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION26_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information26;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION27_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information27;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION28_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information28;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION29_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information29;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_INFORMATION30_'||i;
        l_transaction_table(l_count).param_value := p_eit_table(i).information30;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        -- EndRegistration
        --
        --  This is a marker for the contact person to be used to identify the Address
        --  to be retrieved for the contact person in context in review page.
       END LOOP;
       hr_utility.trace('Exiting For Loop:'||l_proc);

       dump_eit_table(p_eit_table);

       hr_transaction_ss.save_transaction_step
       		(p_item_type => p_item_type
       		,p_item_key  => p_item_key
       		,p_actid     => p_activity_id
--       	        ,p_login_person_id     => nvl(p_login_person_id, p_person_id) -- PB Modification
       	        ,p_login_person_id     => p_login_person_id -- PB Modification
                ,p_transaction_step_id => l_transaction_step_id
       		,p_api_name            => g_package || '.PROCESS_API'
       		,p_transaction_data    => l_transaction_table);

         hr_utility.set_location('Exiting:'||l_proc, 35);




EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
  hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

    hr_utility.trace('hr_process_eit_ss.get_eit_data_from_tt' ||
           	     ' p_error_message: '||p_error_message);



END save_transaction_data;

-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_eit_data_from_tt
  (p_item_type                       in     varchar2
  ,p_item_key                        in     varchar2
  ,p_activity_id                     in     number
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id	             out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_eit_table	            	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
)
IS

  l_transaction_id             number;
  l_trans_step_id              number;
  l_trans_obj_vers_num         number;
  l_count                      integer default 0;
  l_trans_rec_count      number;
  l_proc   varchar2(72)  := g_package||'get_eit_data_from_tt';


begin

  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace(
            'hr_process_eit_ss.get_eit_data_from_tt' ||
            ' p_item_type: '||p_item_type||
            ' p_item_key:  '||p_item_key||
            ' p_activity_id: '||p_activity_id);

  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_trans_step_id
     ,p_object_version_number  => l_trans_obj_vers_num);

  hr_utility.trace(
              'hr_process_eit_ss.get_eit_data_from_tt' ||
              ' l_trans_step_id: '||l_trans_step_id||
              ' l_trans_obj_vers_num: '||l_trans_obj_vers_num);


  IF l_trans_step_id IS NOT NULL OR
     l_trans_step_id > 0
  THEN
     hr_utility.trace('l_trans_step_id IS NOT NULL stepid>0:'||l_proc);
     l_trans_rec_count := 1;
  ELSE
     hr_utility.trace('l_trans_step_id IS NULL & l_trans_step_id <= 0'||l_proc);
     l_trans_rec_count := 0;
     hr_utility.trace('Exiting:From Else part'||l_proc);
     return;
  END IF;

  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------

  -- Now get the transaction data for the given step
  get_eit_data_from_tt
  (p_transaction_step_id       => l_trans_step_id
  ,p_person_id                 => p_person_id
  ,p_login_person_id           => p_login_person_id
  ,p_eit_type		       => p_eit_type
  ,p_eit_type_id	       => p_eit_type_id
  ,p_eit_number		       => p_eit_number
  ,p_eit_table	       	       => p_eit_table
  ,p_error_message             => p_error_message
  ,p_active_view               => p_active_view
  ,p_active_row_id	       => p_active_row_id
);

  hr_utility.trace(
            'hr_process_eit_ss.get_eit_data_from_tt' ||
            ' p_error_message: '||p_error_message);

  p_trans_rec_count := l_trans_rec_count;
  hr_utility.set_location('Exiting:Funtion'||l_proc, 25);

EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    hr_utility.trace(
            'hr_process_eit_ss.get_eit_data_from_tt' ||
            ' p_error_message: '||p_error_message);


END get_eit_data_from_tt;

-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------
procedure get_eit_data_from_tt
  (p_transaction_step_id             in     number
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id		     out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_eit_table	             	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
)IS

l_number_eit 	number := 0;
l_eit_table 	HR_EIT_STRUCTURE_TABLE;
l_proc   varchar2(72)  := g_package||'get_eit_data_from_tt';

begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace(
            'hr_process_eit_ss.get_eit_data_from_tt' ||
            ' p_transaction_step_id: '||p_transaction_step_id);


  p_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');

  p_login_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOGIN_PERSON_ID');

  p_eit_type := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_TYPE');

  p_eit_type_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_TYPE_ID');

-- start registration
-- If its a new user registration flow then the assignmentId which is coming
-- from transaction table will not be valid because the person has just been
-- created by the process_api of the hr_process_person_ss.process_api.
-- We can get that person Id and assignment id by making a call
-- to the global parameters but we need to branch out the code.
-- We also need the latest Object version Number not the one on transaction tbl

-- adding the session id check to avoid connection pooling problems.
  if (( hr_process_person_ss.g_assignment_id is not null
       or hr_process_person_ss.g_person_id is not null) and
                (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
  then
    hr_utility.trace('AsgId<>NULL or PID<>NULL AND SESSIONID=ICX_SEC.G_SESSION_ID:'||l_proc);
    if p_eit_type = 'PERSON' then
      p_eit_type_id := hr_process_person_ss.g_person_id;
    else
      p_eit_type_id := hr_process_person_ss.g_assignment_id;
    end if;
    p_person_id := hr_process_person_ss.g_person_id;
  end if;

-- end registration
--

  p_eit_number := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_NUMBER');

  p_active_view := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVE_VIEW');

  p_active_row_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVE_ROW_ID');

  if(hr_utility.debug_enabled) then

  	hr_utility.trace(
  	          'hr_process_eit_ss.get_eit_data_from_tt' ||
  	          ' p_person_id: '||p_person_id||
  	          ' p_login_person_id: '||p_login_person_id||
  	          ' p_eit_type: '||p_eit_type||
  	          ' p_eit_type_id: '||p_eit_type_id||
  	          ' p_eit_number: '||p_eit_number||
  	          ' p_active_view: '||p_active_view||
  	          ' p_active_row_id: '||p_active_row_id);
  end if;

  l_number_eit := p_eit_number;

  l_eit_table := HR_EIT_STRUCTURE_TABLE();


  hr_utility.trace('For :1 ..l_number_eit'||l_proc);
  FOR i in 1 ..l_number_eit LOOP
--
  l_eit_table.extend;

--  hr_utility.trace(
--            'hr_process_eit_ss.get_eit_data_from_tt' ||
--            ' i : '||i);
  --
  l_eit_table(i) := HR_EIT_STRUCTURE_TYPE
  (
-- action
   hr_transaction_api.get_varchar2_value
    	(p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTION_'||i)

-- extra info id
   ,hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EXTRA_INFO_ID_'||i)

--object_version_number
   ,hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER_'||i)

--information_type
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION_TYPE_'||i)

--attribute_category
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_CATEGORY_'||i)

--attribute1
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE1_'||i)

--attribute2
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE2_'||i)

--attribute3
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE3_'||i)

--attribute4
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE4_'||i)

--attribute5
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE5_'||i)

--attribute6
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE6_'||i)

--attribute7
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE7_'||i)

--attribute8
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE8_'||i)

--attribute9
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE9_'||i)

--attribute10
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE10_'||i)

--attribute11
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE11_'||i)

--attribute12
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE12_'||i)

--attribute13
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE13_'||i)

--attribute14
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE14_'||i)

--attribute15
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE15_'||i)

--attribute16
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE16_'||i)

--attribute17
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE17_'||i)

--attribute18
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE18_'||i)

--attribute19
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE19_'||i)

--attribute20
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE20_'||i)

--information_category
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION_CATEGORY_'||i)

--information1
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION1_'||i)

--information2
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION2_'||i)

--information3
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION3_'||i)

--information4
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION4_'||i)

--information5
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION5_'||i)

--information6
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION6_'||i)

--information7
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION7_'||i)

--information8
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION8_'||i)

--information9
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION9_'||i)

--information10
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION10_'||i)

--information11
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION11_'||i)

--information12
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION12_'||i)

--information13
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION13_'||i)

--information14
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION14_'||i)

--information15
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION15_'||i)

--information16
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION16_'||i)

--information17
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION17_'||i)

--information18
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION18_'||i)

--information19
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION19_'||i)

--information20
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION20_'||i)

--information21
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION21_'||i)

--information22
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION22_'||i)

--information23
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION23_'||i)

--information24
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION24_'||i)

--information25
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION25_'||i)

--information26
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION26_'||i)

--information27
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION27_'||i)

--information28
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION28_'||i)

--information29
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION29_'||i)

--information30
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION30_'||i));

 END LOOP;
 hr_utility.trace('End of FOR:'||l_proc);
 p_eit_table := l_eit_table;
 dump_eit_table(p_eit_table);
 hr_utility.set_location('Exiting:'||l_proc, 30);

EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
  hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

END get_eit_data_from_tt;

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
--
l_proc   varchar2(72)  := g_package||'del_transaction_data';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration

  then
    hr_utility.trace('p_flow_mode is not null but is NewHireReg:'||l_proc);
    hr_utility.trace('Rolling back:'||l_proc);
    rollback;
  end if;
 if(hr_utility.debug_enabled) then

 	hr_utility.trace(
 	           'hr_process_eit_ss.del_transaction_data' ||
 	           ' p_item_type: '||p_item_type||
 	           ' p_item_key: '||p_item_key||
 	           ' p_activity_id: '||p_activity_id||
 	           ' p_login_person_id: '||p_login_person_id);
  end if;

  hr_transaction_ss.delete_transaction_steps(
    p_item_type           => p_item_type
    ,p_item_key           => p_item_key
    ,p_actid              => p_activity_id
    ,p_login_person_id    => p_login_person_id
  );

hr_utility.set_location('Exiting:'||l_proc, 20);
END del_transaction_data;

-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE PROCESS_API
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 default null
)is

l_person_id 		number;
l_login_person_id 	number;
l_eit_type 		varchar2(80);
l_eit_type_id 		number;
l_eit_number 		number;
l_eit_table		HR_EIT_STRUCTURE_TABLE;
l_extra_info_id         number;
l_object_version_number number;
l_error_message		long;
l_active_view           varchar2(200);
l_active_row_id         number;
l_index NUMBER;
l_proc   varchar2(72)  := g_package||'PROCESS_API';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace(
            'hr_process_eit_ss.process_api' ||
            ' p_transaction_step_id: ');--||p_transaction_step_id);

  --insert session because some flex uses the session effective date.
  if p_effective_date is not null then
    hr_utility.trace('EffDate!=Null:'||l_proc);
    hr_util_misc_web.insert_session_row(to_date(p_effective_date, 'RRRR-MM-DD'));
  else
    hr_utility.trace('EffDate==Null:'||l_proc);
    hr_util_misc_web.insert_session_row(SYSDATE);
  end if;

   get_eit_data_from_tt
   (p_transaction_step_id       => p_transaction_step_id
   ,p_person_id                 => l_person_id
   ,p_login_person_id           => l_login_person_id
   ,p_eit_type		        => l_eit_type
   ,p_eit_type_id	        => l_eit_type_id
   ,p_eit_number		=> l_eit_number
   ,p_eit_table		        => l_eit_table
   ,p_error_message             => l_error_message
   ,p_active_view               => l_active_view
   ,p_active_row_id	        => l_active_row_id
);

   --debug
   if(hr_utility.debug_enabled)then

   	hr_utility.trace(
   	         'hr_process_eit_ss.process_api' ||
   	         ' p_person_id: '||l_person_id||
   	         ' p_login_person_id: '||l_login_person_id||
   	         ' p_eit_type: '||l_eit_type||
   	         ' p_eit_type_id: '||l_eit_type_id||
   	         ' p_eit_number: '||l_eit_number);
    end if;


   hr_utility.trace('Before DumpingEIT table:'||l_proc);
   dump_eit_table(l_eit_table);

   hr_utility.trace('FOR j IN 1..2'||l_proc);
   FOR j IN 1..2 LOOP
   l_index := l_eit_table.first;
   LOOP
   EXIT WHEN
     (NOT l_eit_table.exists(l_index));

  hr_utility.trace('End of FOR '||l_proc);

      hr_utility.trace(
            'hr_process_eit_ss.process_api' ||
           ' l_index: '||l_index);

    IF j = 1 AND l_eit_table(l_index).action = 'DELETE_ROW'
      OR j = 2 and l_eit_table(l_index).action <> 'DELETE_ROW' THEN


     IF l_eit_table(l_index).action = 'NEW_ROW' THEN
--     hr_utility.trace('l_eit_table(l_index).action=NEW ROW'||l_proc);

--        hr_utility.trace(
--           'hr_process_eit_ss.process_api' ||
--           ' create a row: ');

  	create_eit
  	(p_validate                  => 0
  	,p_login_person_id           => l_login_person_id
  	,p_eit_type	  	     => l_eit_type
  	,p_eit_type_id	  	     => l_eit_type_id
  	,p_person_id                 => l_person_id
  	,p_information_type          => l_eit_table(l_index).information_type
  	,p_attribute_category        => l_eit_table(l_index).attribute_category
  	,p_attribute1                => l_eit_table(l_index).attribute1
  	,p_attribute2                => l_eit_table(l_index).attribute2
  	,p_attribute3                => l_eit_table(l_index).attribute3
  	,p_attribute4                => l_eit_table(l_index).attribute4
  	,p_attribute5                => l_eit_table(l_index).attribute5
  	,p_attribute6                => l_eit_table(l_index).attribute6
  	,p_attribute7                => l_eit_table(l_index).attribute7
  	,p_attribute8                => l_eit_table(l_index).attribute8
  	,p_attribute9                => l_eit_table(l_index).attribute9
  	,p_attribute10               => l_eit_table(l_index).attribute10
  	,p_attribute11               => l_eit_table(l_index).attribute11
  	,p_attribute12               => l_eit_table(l_index).attribute12
  	,p_attribute13               => l_eit_table(l_index).attribute13
  	,p_attribute14               => l_eit_table(l_index).attribute14
  	,p_attribute15               => l_eit_table(l_index).attribute15
  	,p_attribute16               => l_eit_table(l_index).attribute16
  	,p_attribute17               => l_eit_table(l_index).attribute17
  	,p_attribute18               => l_eit_table(l_index).attribute18
  	,p_attribute19               => l_eit_table(l_index).attribute19
  	,p_attribute20               => l_eit_table(l_index).attribute20
  	,p_information_category      => l_eit_table(l_index).information_category
  	,p_information1              => l_eit_table(l_index).information1
  	,p_information2              => l_eit_table(l_index).information2
  	,p_information3              => l_eit_table(l_index).information3
  	,p_information4              => l_eit_table(l_index).information4
  	,p_information5              => l_eit_table(l_index).information5
  	,p_information6              => l_eit_table(l_index).information6
  	,p_information7              => l_eit_table(l_index).information7
  	,p_information8              => l_eit_table(l_index).information8
  	,p_information9              => l_eit_table(l_index).information9
  	,p_information10             => l_eit_table(l_index).information10
  	,p_information11             => l_eit_table(l_index).information11
  	,p_information12             => l_eit_table(l_index).information12
  	,p_information13             => l_eit_table(l_index).information13
  	,p_information14             => l_eit_table(l_index).information14
  	,p_information15             => l_eit_table(l_index).information15
  	,p_information16             => l_eit_table(l_index).information16
  	,p_information17             => l_eit_table(l_index).information17
  	,p_information18             => l_eit_table(l_index).information18
  	,p_information19             => l_eit_table(l_index).information19
  	,p_information20             => l_eit_table(l_index).information20
  	,p_information21             => l_eit_table(l_index).information21
  	,p_information22             => l_eit_table(l_index).information22
  	,p_information23             => l_eit_table(l_index).information23
  	,p_information24             => l_eit_table(l_index).information24
  	,p_information25             => l_eit_table(l_index).information25
  	,p_information26             => l_eit_table(l_index).information26
  	,p_information27             => l_eit_table(l_index).information27
  	,p_information28             => l_eit_table(l_index).information28
  	,p_information29             => l_eit_table(l_index).information29
  	,p_information30             => l_eit_table(l_index).information30
  	,p_extra_info_id             => l_extra_info_id
  	,p_object_version_number     => l_object_version_number
  	-- EndRegistration
  	,p_item_type                => null
  	,p_item_key                 => null
  	,p_activity_id              => null
  	,p_action                   => null
  	,p_old_extra_info_id        => null
  	,p_old_object_version_number  => null
  	,p_save_mode                => null
  	,p_error_message            => l_error_message
  	);

--        hr_utility.trace(
--           'hr_process_eit_ss.process_api' ||
--           ' create a row with extra info type id'||l_extra_info_id);


      ELSIF l_eit_table(l_index).action = 'UPDATE_ROW' THEN
--      hr_utility.trace('l_eit_table(l_index).action=UPDATE_ROW'||l_proc);

--        hr_utility.trace(
--            'hr_process_eit_ss.process_api' ||
--           ' update a row with extra info type id'||l_eit_table(l_index).extra_info_id);

  	update_eit
  	(p_validate                  => 0
  	,p_login_person_id           => l_login_person_id
  	,p_eit_type	  	     => l_eit_type
  	,p_eit_type_id	  	     => l_eit_type_id
  	,p_person_id                 => l_person_id
  	,p_information_type          => l_eit_table(l_index).information_type
  	,p_attribute_category        => l_eit_table(l_index).attribute_category
  	,p_attribute1                => l_eit_table(l_index).attribute1
  	,p_attribute2                => l_eit_table(l_index).attribute2
  	,p_attribute3                => l_eit_table(l_index).attribute3
  	,p_attribute4                => l_eit_table(l_index).attribute4
  	,p_attribute5                => l_eit_table(l_index).attribute5
  	,p_attribute6                => l_eit_table(l_index).attribute6
  	,p_attribute7                => l_eit_table(l_index).attribute7
  	,p_attribute8                => l_eit_table(l_index).attribute8
  	,p_attribute9                => l_eit_table(l_index).attribute9
  	,p_attribute10               => l_eit_table(l_index).attribute10
  	,p_attribute11               => l_eit_table(l_index).attribute11
  	,p_attribute12               => l_eit_table(l_index).attribute12
  	,p_attribute13               => l_eit_table(l_index).attribute13
  	,p_attribute14               => l_eit_table(l_index).attribute14
  	,p_attribute15               => l_eit_table(l_index).attribute15
  	,p_attribute16               => l_eit_table(l_index).attribute16
  	,p_attribute17               => l_eit_table(l_index).attribute17
  	,p_attribute18               => l_eit_table(l_index).attribute18
  	,p_attribute19               => l_eit_table(l_index).attribute19
  	,p_attribute20               => l_eit_table(l_index).attribute20
  	,p_information_category      => l_eit_table(l_index).information_category
  	,p_information1              => l_eit_table(l_index).information1
  	,p_information2              => l_eit_table(l_index).information2
  	,p_information3              => l_eit_table(l_index).information3
  	,p_information4              => l_eit_table(l_index).information4
  	,p_information5              => l_eit_table(l_index).information5
  	,p_information6              => l_eit_table(l_index).information6
  	,p_information7              => l_eit_table(l_index).information7
  	,p_information8              => l_eit_table(l_index).information8
  	,p_information9              => l_eit_table(l_index).information9
  	,p_information10             => l_eit_table(l_index).information10
  	,p_information11             => l_eit_table(l_index).information11
  	,p_information12             => l_eit_table(l_index).information12
  	,p_information13             => l_eit_table(l_index).information13
  	,p_information14             => l_eit_table(l_index).information14
  	,p_information15             => l_eit_table(l_index).information15
  	,p_information16             => l_eit_table(l_index).information16
  	,p_information17             => l_eit_table(l_index).information17
  	,p_information18             => l_eit_table(l_index).information18
  	,p_information19             => l_eit_table(l_index).information19
  	,p_information20             => l_eit_table(l_index).information20
  	,p_information21             => l_eit_table(l_index).information21
  	,p_information22             => l_eit_table(l_index).information22
  	,p_information23             => l_eit_table(l_index).information23
  	,p_information24             => l_eit_table(l_index).information24
  	,p_information25             => l_eit_table(l_index).information25
  	,p_information26             => l_eit_table(l_index).information26
  	,p_information27             => l_eit_table(l_index).information27
  	,p_information28             => l_eit_table(l_index).information28
  	,p_information29             => l_eit_table(l_index).information29
  	,p_information30             => l_eit_table(l_index).information30
  	,p_extra_info_id             => l_eit_table(l_index).extra_info_id
  	,p_object_version_number     => l_eit_table(l_index).object_version_number
  	-- EndRegistration
  	,p_item_type                => null
  	,p_item_key                 => null
  	,p_activity_id              => null
  	,p_action                   => null
  	,p_old_extra_info_id        => null
  	,p_old_object_version_number  => null
  	,p_save_mode                => null
  	,p_error_message            => l_error_message
  	);

      ELSIF l_eit_table(l_index).action = 'DELETE_ROW' THEN

--        hr_utility.trace('l_eit_table(l_index).action=DELETE_ROW:'||l_proc);
--        hr_utility.trace(
--            'hr_process_eit_ss.process_api' ||
--           ' delete a row with extra info type id'||l_eit_table(l_index).extra_info_id);

  	delete_eit
  	(p_validate                  => 0
  	,p_login_person_id           => l_login_person_id
  	,p_eit_type	  	     => l_eit_type
  	,p_eit_type_id	  	     => l_eit_type_id
  	,p_person_id                 => l_person_id
  	,p_information_type          => l_eit_table(l_index).information_type
  	,p_extra_info_id             => l_eit_table(l_index).extra_info_id
  	,p_object_version_number     => l_eit_table(l_index).object_version_number
  	-- EndRegistration
  	,p_item_type                => null
  	,p_item_key                 => null
  	,p_activity_id              => null
  	,p_action                   => null
  	,p_old_extra_info_id        => null
  	,p_old_object_version_number  => null
  	,p_save_mode                => null
  	,p_error_message            => l_error_message
  	);

      END IF;
     END IF;

--     hr_utility.trace(
--           'hr_process_eit_ss.process_api' ||
--           ' l_error_message: '||l_error_message);

     l_index := l_eit_table.next(l_index);

    END LOOP;
    END LOOP;

  --remove session
  hr_util_misc_web.remove_session_row();

  if l_error_message is not null then
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('Exiting:'||l_proc, 40);

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('Exception:Others'||l_proc,555);
    raise;

END process_api;


  /*
  ||===========================================================================
  || PROCEDURE: create_eit
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE create_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type	  	       in     varchar2
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_information_category      in     varchar2 default null
  ,p_information1              in     varchar2 default null
  ,p_information2              in     varchar2 default null
  ,p_information3              in     varchar2 default null
  ,p_information4              in     varchar2 default null
  ,p_information5              in     varchar2 default null
  ,p_information6              in     varchar2 default null
  ,p_information7              in     varchar2 default null
  ,p_information8              in     varchar2 default null
  ,p_information9              in     varchar2 default null
  ,p_information10             in     varchar2 default null
  ,p_information11             in     varchar2 default null
  ,p_information12             in     varchar2 default null
  ,p_information13             in     varchar2 default null
  ,p_information14             in     varchar2 default null
  ,p_information15             in     varchar2 default null
  ,p_information16             in     varchar2 default null
  ,p_information17             in     varchar2 default null
  ,p_information18             in     varchar2 default null
  ,p_information19             in     varchar2 default null
  ,p_information20             in     varchar2 default null
  ,p_information21             in     varchar2 default null
  ,p_information22             in     varchar2 default null
  ,p_information23             in     varchar2 default null
  ,p_information24             in     varchar2 default null
  ,p_information25             in     varchar2 default null
  ,p_information26             in     varchar2 default null
  ,p_information27             in     varchar2 default null
  ,p_information28             in     varchar2 default null
  ,p_information29             in     varchar2 default null
  ,p_information30             in     varchar2 default null
  ,p_extra_info_id             out nocopy number
  ,p_object_version_number     out nocopy number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ,p_eit_type_id  	       	   in     number
  ,p_flow_mode                     in     varchar2 default null
  )
  IS
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_eit';
  l_dummy_num  number;
  l_extra_info_id         per_people_extra_info.person_extra_info_id%type;
  l_object_version_number per_people_extra_info.object_version_number%type;
  l_transaction_id             number default null;
  l_result                     varchar2(100) default null;
  l_new_hire              boolean default false;
  l_person_id             number;
  l_assignment_id         number;
  l_eit_type_id           number;

  BEGIN
    --
    -- Call the actual API.
    --

    --
    -- if the extra info type is a PERSON
    --
    hr_utility.set_location('Entering:'||l_proc, 5);
    if(hr_utility.debug_enabled) then

    	hr_utility.trace(
		   'hr_process_eit_ss.create_eit' ||
		   ' arrive '||
		    'p_validate '||p_validate||
		    ' p_login_person_id '||p_login_person_id||
		    ' p_eit_type '||p_eit_type||
		    ' p_eit_type_id '||p_eit_type_id||
		    ' p_person_id '||p_person_id||
		    ' p_information_type '||p_information_type||
		    ' p_attribute_category '||p_attribute_category||
		    ' p_attribute1 '||p_attribute1||
		    ' p_attribute2 '||p_attribute2||
		    ' p_attribute3 '||p_attribute3||
		    ' p_attribute4 '||p_attribute4||
		    ' p_attribute5 '||p_attribute5||
		    ' p_attribute6 '||p_attribute6||
		    ' p_attribute7 '||p_attribute7||
		    ' p_attribute8 '||p_attribute8||
		    ' p_attribute9 '||p_attribute9||
		    ' p_attribute10 '||p_attribute10||
		    ' p_attribute11 '||p_attribute11||
		    ' p_attribute12 '||p_attribute12||
		    ' p_attribute13 '||p_attribute13||
		    ' p_attribute14 '||p_attribute14||
		    ' p_attribute15 '||p_attribute15||
		    ' p_attribute16 '||p_attribute16||
		    ' p_attribute17 '||p_attribute17||
		    ' p_attribute18 '||p_attribute18||
		    ' p_attribute19 '||p_attribute19||
		    ' p_attribute20 '||p_attribute20||
		    ' p_information_category '||p_information_category||
		    ' p_information1 '||p_information1||
		    ' p_information2 '||p_information2||
		    ' p_information3 '||p_information3||
		    ' p_information4 '||p_information4||
		    ' p_information5 '||p_information5||
		    ' p_information6 '||p_information6||
		    ' p_information7 '||p_information7||
		    ' p_information8 '||p_information8||
		    ' p_information9 '||p_information9||
		    ' p_information10 '||p_information10||
		    ' p_information11 '||p_information11||
		    ' p_information12 '||p_information12||
		    ' p_information13 '||p_information13||
		    ' p_information14 '||p_information14||
		    ' p_information15 '||p_information15||
		    ' p_information16 '||p_information16||
		    ' p_information17 '||p_information17||
		    ' p_information18 '||p_information18||
		    ' p_information19 '||p_information19||
		    ' p_information20 '||p_information20||
		    ' p_information21 '||p_information21||
		    ' p_information22 '||p_information22||
		    ' p_information23 '||p_information23||
		    ' p_information24 '||p_information24||
		    ' p_information25 '||p_information25||
		    ' p_information26 '||p_information26||
		    ' p_information27 '||p_information27||
		    ' p_information28 '||p_information28||
		    ' p_information29 '||p_information29||
		    ' p_information30 '||p_information30||
		    ' p_item_type '||p_item_type||
		    ' p_item_key  '||p_item_key ||
		    ' p_activity_id '||p_activity_id||
		    ' p_action      '||p_action||
		    ' p_old_extra_info_id '||p_old_extra_info_id||
		    ' p_old_object_version_number '||p_old_object_version_number||
		    ' p_save_mode '||p_save_mode);
       end if;
  --l_eit_type_id := p_eit_type_id;

  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  then
    hr_utility.trace('p_flow_mode!=null but NewHireReg:'||l_proc);
    l_new_hire := TRUE;
  end if;

  l_eit_type_id := p_eit_type_id;

  if l_new_hire then
    hr_utility.trace('if l_new_hire:'||l_proc);
    hr_new_user_reg_ss.processNewUserTransaction
      (WfItemType => p_item_type
      ,WfItemKey => p_item_key
      ,PersonId => l_person_id
      ,AssignmentId => l_assignment_id);
    if p_eit_type = 'PERSON' then
      l_eit_type_id := l_person_id;
    else
        l_eit_type_id := l_assignment_id;
    end if;
  end if;


  if p_eit_type = 'PERSON' then
  hr_utility.trace('if p_eit_type=PERSON:'||l_proc);
    hr_utility.trace(
           'hr_process_eit_ss.create_eit' ||
           ' p_eit_type '||p_eit_type);

	hr_person_extra_info_api.create_person_extra_info
	(p_validate			=> hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_person_id			=> l_eit_type_id
	,p_information_type		=> p_information_type
  	,p_pei_attribute_category	=> p_attribute_category
  	,p_pei_attribute1		=> p_attribute1
  	,p_pei_attribute2		=> p_attribute2
  	,p_pei_attribute3		=> p_attribute3
  	,p_pei_attribute4		=> p_attribute4
  	,p_pei_attribute5		=> p_attribute5
  	,p_pei_attribute6		=> p_attribute6
  	,p_pei_attribute7		=> p_attribute7
  	,p_pei_attribute8		=> p_attribute8
  	,p_pei_attribute9		=> p_attribute9
  	,p_pei_attribute10		=> p_attribute10
  	,p_pei_attribute11		=> p_attribute11
  	,p_pei_attribute12		=> p_attribute12
  	,p_pei_attribute13		=> p_attribute13
  	,p_pei_attribute14		=> p_attribute14
  	,p_pei_attribute15		=> p_attribute15
  	,p_pei_attribute16		=> p_attribute16
  	,p_pei_attribute17		=> p_attribute17
  	,p_pei_attribute18		=> p_attribute18
  	,p_pei_attribute19		=> p_attribute19
  	,p_pei_attribute20		=> p_attribute20
  	,p_pei_information_category	=> p_information_category
  	,p_pei_information1		=> p_information1
  	,p_pei_information2		=> p_information2
  	,p_pei_information3		=> p_information3
  	,p_pei_information4		=> p_information4
  	,p_pei_information5		=> p_information5
  	,p_pei_information6		=> p_information6
  	,p_pei_information7		=> p_information7
  	,p_pei_information8		=> p_information8
  	,p_pei_information9		=> p_information9
  	,p_pei_information10		=> p_information10
  	,p_pei_information11		=> p_information11
  	,p_pei_information12		=> p_information12
  	,p_pei_information13		=> p_information13
  	,p_pei_information14		=> p_information14
  	,p_pei_information15		=> p_information15
  	,p_pei_information16		=> p_information16
  	,p_pei_information17		=> p_information17
  	,p_pei_information18		=> p_information18
  	,p_pei_information19		=> p_information19
  	,p_pei_information20		=> p_information20
  	,p_pei_information21		=> p_information21
  	,p_pei_information22		=> p_information22
  	,p_pei_information23		=> p_information23
  	,p_pei_information24		=> p_information24
  	,p_pei_information25		=> p_information25
  	,p_pei_information26		=> p_information26
  	,p_pei_information27		=> p_information27
  	,p_pei_information28		=> p_information28
  	,p_pei_information29		=> p_information29
  	,p_pei_information30		=> p_information30
  	,p_person_extra_info_id		=> l_extra_info_id
  	,p_object_version_number	=> l_object_version_number
	);


	p_object_version_number	:= l_object_version_number;
        p_extra_info_id  	:= l_extra_info_id;

	hr_utility.trace(
            'hr_process_eit_ss.create_eit' ||
            ' out nocopy create params '||
  	    ' p_person_extra_info_id '||l_extra_info_id||
  	    ' p_object_version_number '||l_object_version_number);

    elsif p_eit_type = 'ASSIGNMENT' then
    hr_utility.trace('p_eit_type=ASSIGNMENT:'||l_proc);
    hr_utility.trace(
            'hr_process_eit_ss.create_eit' ||
            ' p_eit_type '||p_eit_type);

	hr_assignment_extra_info_api.create_assignment_extra_info
	(p_validate			=> hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_assignment_id		=> l_eit_type_id
	,p_information_type		=> p_information_type
  	,p_aei_attribute_category	=> p_attribute_category
  	,p_aei_attribute1		=> p_attribute1
  	,p_aei_attribute2		=> p_attribute2
  	,p_aei_attribute3		=> p_attribute3
  	,p_aei_attribute4		=> p_attribute4
  	,p_aei_attribute5		=> p_attribute5
  	,p_aei_attribute6		=> p_attribute6
  	,p_aei_attribute7		=> p_attribute7
  	,p_aei_attribute8		=> p_attribute8
  	,p_aei_attribute9		=> p_attribute9
  	,p_aei_attribute10		=> p_attribute10
  	,p_aei_attribute11		=> p_attribute11
  	,p_aei_attribute12		=> p_attribute12
  	,p_aei_attribute13		=> p_attribute13
  	,p_aei_attribute14		=> p_attribute14
  	,p_aei_attribute15		=> p_attribute15
  	,p_aei_attribute16		=> p_attribute16
  	,p_aei_attribute17		=> p_attribute17
  	,p_aei_attribute18		=> p_attribute18
  	,p_aei_attribute19		=> p_attribute19
  	,p_aei_attribute20		=> p_attribute20
  	,p_aei_information_category	=> p_information_category
  	,p_aei_information1		=> p_information1
  	,p_aei_information2		=> p_information2
  	,p_aei_information3		=> p_information3
  	,p_aei_information4		=> p_information4
  	,p_aei_information5		=> p_information5
  	,p_aei_information6		=> p_information6
  	,p_aei_information7		=> p_information7
  	,p_aei_information8		=> p_information8
  	,p_aei_information9		=> p_information9
  	,p_aei_information10		=> p_information10
  	,p_aei_information11		=> p_information11
  	,p_aei_information12		=> p_information12
  	,p_aei_information13		=> p_information13
  	,p_aei_information14		=> p_information14
  	,p_aei_information15		=> p_information15
  	,p_aei_information16		=> p_information16
  	,p_aei_information17		=> p_information17
  	,p_aei_information18		=> p_information18
  	,p_aei_information19		=> p_information19
  	,p_aei_information20		=> p_information20
  	,p_aei_information21		=> p_information21
  	,p_aei_information22		=> p_information22
  	,p_aei_information23		=> p_information23
  	,p_aei_information24		=> p_information24
  	,p_aei_information25		=> p_information25
  	,p_aei_information26		=> p_information26
  	,p_aei_information27		=> p_information27
  	,p_aei_information28		=> p_information28
  	,p_aei_information29		=> p_information29
  	,p_aei_information30		=> p_information30
  	,p_assignment_extra_info_id	=> l_extra_info_id
  	,p_object_version_number	=> l_object_version_number
	);


	p_object_version_number	:= l_object_version_number;
        p_extra_info_id  	:= l_extra_info_id;

     if(hr_utility.debug_enabled) then
	hr_utility.trace(
            'hr_process_eit_ss.create_eit' ||
            ' out nocopy create params '||
  	    ' p_person_extra_info_id '||l_extra_info_id||
  	    ' p_object_version_number '||l_object_version_number);
    	end if;
    end if;

 --
 -- PB : Now rollback all the changes which are performed.
 --
   hr_utility.trace(l_proc);

-- first check if this is being called for registration.
  if l_new_hire then
    hr_utility.trace('if l_new_hire: then rollback'||l_proc);
    rollback;
  end if;

hr_utility.set_location('Exiting:'||l_proc, 35);

EXCEPTION

   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    hr_utility.trace(
           'hr_process_eit_ss.create_eit' ||
           ' l_error_message: '||p_error_message ||' '|| sqlerrm );
    --
    -- A validation or unexpected error has occurred
    --
    --
    if l_new_hire then
      rollback;
    end if;
END create_eit;

  /*
  ||===========================================================================
  || PROCEDURE: update_eit
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
PROCEDURE update_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type                  in     varchar2
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_information_category      in     varchar2 default null
  ,p_information1              in     varchar2 default null
  ,p_information2              in     varchar2 default null
  ,p_information3              in     varchar2 default null
  ,p_information4              in     varchar2 default null
  ,p_information5              in     varchar2 default null
  ,p_information6              in     varchar2 default null
  ,p_information7              in     varchar2 default null
  ,p_information8              in     varchar2 default null
  ,p_information9              in     varchar2 default null
  ,p_information10             in     varchar2 default null
  ,p_information11             in     varchar2 default null
  ,p_information12             in     varchar2 default null
  ,p_information13             in     varchar2 default null
  ,p_information14             in     varchar2 default null
  ,p_information15             in     varchar2 default null
  ,p_information16             in     varchar2 default null
  ,p_information17             in     varchar2 default null
  ,p_information18             in     varchar2 default null
  ,p_information19             in     varchar2 default null
  ,p_information20             in     varchar2 default null
  ,p_information21             in     varchar2 default null
  ,p_information22             in     varchar2 default null
  ,p_information23             in     varchar2 default null
  ,p_information24             in     varchar2 default null
  ,p_information25             in     varchar2 default null
  ,p_information26             in     varchar2 default null
  ,p_information27             in     varchar2 default null
  ,p_information28             in     varchar2 default null
  ,p_information29             in     varchar2 default null
  ,p_information30             in     varchar2 default null
  ,p_extra_info_id             in     number
  ,p_object_version_number     in out nocopy number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ,p_eit_type_id                   in     number
  )
  IS
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_eit';
  l_dummy_num  number;
  l_transaction_id             number default null;
  l_result                     varchar2(100) default null;

  BEGIN
    --
    -- Call the actual API.
    --

        hr_utility.set_location('Entering:'||l_proc, 5);

    if(hr_utility.debug_enabled) then

        hr_utility.trace(
            'hr_process_eit_ss.create_eit' ||
            ' arrive '||
  	    'p_validate '||p_validate||
	    ' p_login_person_id '||p_login_person_id||
	    ' p_eit_type '||p_eit_type||
	    ' p_eit_type_id '||p_eit_type_id||
	    ' p_person_id '||p_person_id||
	    ' p_information_type '||p_information_type||
	    ' p_attribute_category '||p_attribute_category||
	    ' p_attribute1 '||p_attribute1||
	    ' p_attribute2 '||p_attribute2||
	    ' p_attribute3 '||p_attribute3||
	    ' p_attribute4 '||p_attribute4||
	    ' p_attribute5 '||p_attribute5||
	    ' p_attribute6 '||p_attribute6||
	    ' p_attribute7 '||p_attribute7||
	    ' p_attribute8 '||p_attribute8||
	    ' p_attribute9 '||p_attribute9||
	    ' p_attribute10 '||p_attribute10||
	    ' p_attribute11 '||p_attribute11||
	    ' p_attribute12 '||p_attribute12||
	    ' p_attribute13 '||p_attribute13||
	    ' p_attribute14 '||p_attribute14||
	    ' p_attribute15 '||p_attribute15||
	    ' p_attribute16 '||p_attribute16||
	    ' p_attribute17 '||p_attribute17||
	    ' p_attribute18 '||p_attribute18||
	    ' p_attribute19 '||p_attribute19||
	    ' p_attribute20 '||p_attribute20||
	    ' p_information_category '||p_information_category||
	    ' p_information1 '||p_information1||
	    ' p_information2 '||p_information2||
	    ' p_information3 '||p_information3||
	    ' p_information4 '||p_information4||
	    ' p_information5 '||p_information5||
	    ' p_information6 '||p_information6||
	    ' p_information7 '||p_information7||
	    ' p_information8 '||p_information8||
	    ' p_information9 '||p_information9||
	    ' p_information10 '||p_information10||
	    ' p_information11 '||p_information11||
	    ' p_information12 '||p_information12||
	    ' p_information13 '||p_information13||
	    ' p_information14 '||p_information14||
	    ' p_information15 '||p_information15||
	    ' p_information16 '||p_information16||
	    ' p_information17 '||p_information17||
	    ' p_information18 '||p_information18||
	    ' p_information19 '||p_information19||
	    ' p_information20 '||p_information20||
	    ' p_information21 '||p_information21||
	    ' p_information22 '||p_information22||
	    ' p_information23 '||p_information23||
	    ' p_information24 '||p_information24||
	    ' p_information25 '||p_information25||
	    ' p_information26 '||p_information26||
	    ' p_information27 '||p_information27||
	    ' p_information28 '||p_information28||
	    ' p_information29 '||p_information29||
	    ' p_information30 '||p_information30||
	    ' p_item_type '||p_item_type||
	    ' p_item_key  '||p_item_key ||
	    ' p_activity_id '||p_activity_id||
	    ' p_action      '||p_action||
	    ' p_old_extra_info_id '||p_old_extra_info_id||
	    ' p_old_object_version_number '||p_old_object_version_number||
	    ' p_save_mode '||p_save_mode);

      end if;
    --
    -- if the extra info type is a PERSON
    --
    if p_eit_type = 'PERSON' then

	hr_utility.trace('p_eit_type = PERSON:'||l_proc);

	hr_person_extra_info_api.update_person_extra_info
	(p_validate			=> hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_person_extra_info_id		=> p_extra_info_id
  	,p_object_version_number	=> p_object_version_number
  	,p_pei_attribute_category	=> p_attribute_category
  	,p_pei_attribute1		=> p_attribute1
  	,p_pei_attribute2		=> p_attribute2
  	,p_pei_attribute3		=> p_attribute3
  	,p_pei_attribute4		=> p_attribute4
  	,p_pei_attribute5		=> p_attribute5
  	,p_pei_attribute6		=> p_attribute6
  	,p_pei_attribute7		=> p_attribute7
  	,p_pei_attribute8		=> p_attribute8
  	,p_pei_attribute9		=> p_attribute9
  	,p_pei_attribute10		=> p_attribute10
  	,p_pei_attribute11		=> p_attribute11
  	,p_pei_attribute12		=> p_attribute12
  	,p_pei_attribute13		=> p_attribute13
  	,p_pei_attribute14		=> p_attribute14
  	,p_pei_attribute15		=> p_attribute15
  	,p_pei_attribute16		=> p_attribute16
  	,p_pei_attribute17		=> p_attribute17
  	,p_pei_attribute18		=> p_attribute18
  	,p_pei_attribute19		=> p_attribute19
  	,p_pei_attribute20		=> p_attribute20
  	,p_pei_information_category	=> p_information_category
  	,p_pei_information1		=> p_information1
  	,p_pei_information2		=> p_information2
  	,p_pei_information3		=> p_information3
  	,p_pei_information4		=> p_information4
  	,p_pei_information5		=> p_information5
  	,p_pei_information6		=> p_information6
  	,p_pei_information7		=> p_information7
  	,p_pei_information8		=> p_information8
  	,p_pei_information9		=> p_information9
  	,p_pei_information10		=> p_information10
  	,p_pei_information11		=> p_information11
  	,p_pei_information12		=> p_information12
  	,p_pei_information13		=> p_information13
  	,p_pei_information14		=> p_information14
  	,p_pei_information15		=> p_information15
  	,p_pei_information16		=> p_information16
  	,p_pei_information17		=> p_information17
  	,p_pei_information18		=> p_information18
  	,p_pei_information19		=> p_information19
  	,p_pei_information20		=> p_information20
  	,p_pei_information21		=> p_information21
  	,p_pei_information22		=> p_information22
  	,p_pei_information23		=> p_information23
  	,p_pei_information24		=> p_information24
  	,p_pei_information25		=> p_information25
  	,p_pei_information26		=> p_information26
  	,p_pei_information27		=> p_information27
  	,p_pei_information28		=> p_information28
  	,p_pei_information29		=> p_information29
  	,p_pei_information30		=> p_information30
	);

    --
    -- if the extra info type is a PERSON
    --
    elsif p_eit_type = 'ASSIGNMENT' then
    hr_utility.trace('p_eit_type=ASSIGNMENT:'||l_proc);

	hr_assignment_extra_info_api.update_assignment_extra_info
	(p_validate			=> hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_assignment_extra_info_id		=> p_extra_info_id
  	,p_object_version_number	=> p_object_version_number
  	,p_aei_attribute_category	=> p_attribute_category
  	,p_aei_attribute1		=> p_attribute1
  	,p_aei_attribute2		=> p_attribute2
  	,p_aei_attribute3		=> p_attribute3
  	,p_aei_attribute4		=> p_attribute4
  	,p_aei_attribute5		=> p_attribute5
  	,p_aei_attribute6		=> p_attribute6
  	,p_aei_attribute7		=> p_attribute7
  	,p_aei_attribute8		=> p_attribute8
  	,p_aei_attribute9		=> p_attribute9
  	,p_aei_attribute10		=> p_attribute10
  	,p_aei_attribute11		=> p_attribute11
  	,p_aei_attribute12		=> p_attribute12
  	,p_aei_attribute13		=> p_attribute13
  	,p_aei_attribute14		=> p_attribute14
  	,p_aei_attribute15		=> p_attribute15
  	,p_aei_attribute16		=> p_attribute16
  	,p_aei_attribute17		=> p_attribute17
  	,p_aei_attribute18		=> p_attribute18
  	,p_aei_attribute19		=> p_attribute19
  	,p_aei_attribute20		=> p_attribute20
  	,p_aei_information_category	=> p_information_category
  	,p_aei_information1		=> p_information1
  	,p_aei_information2		=> p_information2
  	,p_aei_information3		=> p_information3
  	,p_aei_information4		=> p_information4
  	,p_aei_information5		=> p_information5
  	,p_aei_information6		=> p_information6
  	,p_aei_information7		=> p_information7
  	,p_aei_information8		=> p_information8
  	,p_aei_information9		=> p_information9
  	,p_aei_information10		=> p_information10
  	,p_aei_information11		=> p_information11
  	,p_aei_information12		=> p_information12
  	,p_aei_information13		=> p_information13
  	,p_aei_information14		=> p_information14
  	,p_aei_information15		=> p_information15
  	,p_aei_information16		=> p_information16
  	,p_aei_information17		=> p_information17
  	,p_aei_information18		=> p_information18
  	,p_aei_information19		=> p_information19
  	,p_aei_information20		=> p_information20
  	,p_aei_information21		=> p_information21
  	,p_aei_information22		=> p_information22
  	,p_aei_information23		=> p_information23
  	,p_aei_information24		=> p_information24
  	,p_aei_information25		=> p_information25
  	,p_aei_information26		=> p_information26
  	,p_aei_information27		=> p_information27
  	,p_aei_information28		=> p_information28
  	,p_aei_information29		=> p_information29
  	,p_aei_information30		=> p_information30
	);

    end if;
 --
 -- PB : Now rollback all the changes which are performed.
 --
 hr_utility.set_location('Exiting:'||l_proc, 30);

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

    hr_utility.trace(
           'hr_process_eit_ss.create_eit' ||
           ' l_error_message: '||p_error_message ||' '|| sqlerrm );

    --
    -- A validation or unexpected error has occurred
    --
    --
END update_eit;


-- ----------------------------------------------------------------------------
-- |----------------------------<  delete_eit  >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_eit
  (p_validate                  in     number   default 0
  ,p_login_person_id           in     number default null
  ,p_eit_type                  in     varchar2
  ,p_eit_type_id               in     number
  ,p_person_id                 in     number
  ,p_information_type          in     varchar2
  ,p_extra_info_id             in     number
  ,p_object_version_number     in      number
  -- EndRegistration
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_action                        in     varchar2
  ,p_old_extra_info_id             in     number   default null
  ,p_old_object_version_number     in     number   default null
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  ) IS
--
  l_error_message                 long default null;
l_proc                  varchar2(72) := g_package||'delete_sit';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
    --
    -- Call the actual API.
    --
    --
    -- if the extra info type is a PERSON
    --
  IF p_eit_type = 'PERSON' THEN
     hr_utility.trace('p_eit_type = PERSON'||l_proc);
     hr_person_extra_info_api.delete_person_extra_info
  	(p_validate                      => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_person_extra_info_id          => p_extra_info_id
  	,p_object_version_number         => p_object_version_number
  	);
  ELSIF p_eit_type = 'ASSIGNMENT' THEN

     hr_utility.trace('p_eit_type=ASSIGNMENT:'||l_proc);
     hr_assignment_extra_info_api.DELETE_ASSIGNMENT_EXTRA_INFO
  	(p_validate                      => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate)
  	,p_assignment_extra_info_id      => p_extra_info_id
  	,p_object_version_number         => p_object_version_number
  	);

  END IF;

  hr_utility.set_location('Exiting:'||l_proc, 25);

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    --
    -- A validation or unexpected error has occurred
    --
  --
END delete_eit;



/******************************************************************************/
/* this procedure dump the eit table information                              */
/******************************************************************************/

PROCEDURE dump_eit_table (p_eit_table  in   HR_EIT_STRUCTURE_TABLE ) IS

l_index NUMBER;
l_proc   varchar2(72)  := g_package||'dump_eit_table';

BEGIN


   hr_utility.set_location('Entering:'||l_proc, 5);
   l_index := p_eit_table.first;
   hr_utility.trace('Entering LOOP:'||l_proc);
   LOOP
   EXIT WHEN
     (NOT p_eit_table.exists(l_index));

   if(hr_utility.debug_enabled) then

    hr_utility.trace(
           'hr_process_eit_ss.dump_eit_table' ||
           ' l_index :'||l_index||
           ' Action :'||p_eit_table(l_index).action||
           ' extra_info_id: '||p_eit_table(l_index).extra_info_id||
           ' object_version_number :'||p_eit_table(l_index).object_version_number||
	   ' information_type :'||p_eit_table(l_index).information_type||
           ' attribute_category :'||p_eit_table(l_index).attribute_category||
           ' ATT1:'||p_eit_table(l_index).attribute1||
      	   ' ATT2:'||p_eit_table(l_index).attribute2||
	   ' ATT3:'||p_eit_table(l_index).attribute3||
	   ' ATT4:'||p_eit_table(l_index).attribute4||
	   ' ATT5:'||p_eit_table(l_index).attribute5||
	   ' ATT6:'||p_eit_table(l_index).attribute6||
	   ' ATT7:'||p_eit_table(l_index).attribute7||
	   ' ATT8:'||p_eit_table(l_index).attribute8||
	   ' ATT9:'||p_eit_table(l_index).attribute9||
	   ' ATT10:'||p_eit_table(l_index).attribute10||
	   ' ATT11:'||p_eit_table(l_index).attribute11||
	   ' ATT12:'||p_eit_table(l_index).attribute12||
	   ' ATT13:'||p_eit_table(l_index).attribute13||
	   ' ATT14:'||p_eit_table(l_index).attribute14||
	   ' ATT15:'||p_eit_table(l_index).attribute15||
	   ' ATT16:'||p_eit_table(l_index).attribute16||
	   ' ATT17:'||p_eit_table(l_index).attribute17||
	   ' ATT18:'||p_eit_table(l_index).attribute18||
	   ' ATT19:'||p_eit_table(l_index).attribute19||
	   ' ATT20:'||p_eit_table(l_index).attribute20||
	   ' information_category :'||p_eit_table(l_index).information_category||
	   ' information1 :'||p_eit_table(l_index).information1||
	   ' information2 :'||p_eit_table(l_index).information2||
	   ' information3 :'||p_eit_table(l_index).information3||
	   ' information4 :'||p_eit_table(l_index).information4||
	   ' information5 :'||p_eit_table(l_index).information5||
	   ' information6 :'||p_eit_table(l_index).information6||
	   ' information7 :'||p_eit_table(l_index).information7||
	   ' information8 :'||p_eit_table(l_index).information8||
	   ' information9 :'||p_eit_table(l_index).information9||
	   ' information10:'||p_eit_table(l_index).information10||
	   ' information11:'||p_eit_table(l_index).information11||
	   ' information12:'||p_eit_table(l_index).information12||
	   ' information13:'||p_eit_table(l_index).information13||
	   ' information14:'||p_eit_table(l_index).information14||
	   ' information15:'||p_eit_table(l_index).information15||
	   ' information16:'||p_eit_table(l_index).information16||
	   ' information17:'||p_eit_table(l_index).information17||
	   ' information18:'||p_eit_table(l_index).information18||
	   ' information19:'||p_eit_table(l_index).information19||
	   ' information20:'||p_eit_table(l_index).information20||
	   ' information21:'||p_eit_table(l_index).information21||
	   ' information22:'||p_eit_table(l_index).information22||
	   ' information23:'||p_eit_table(l_index).information23||
	   ' information24:'||p_eit_table(l_index).information24||
	   ' information25:'||p_eit_table(l_index).information25||
	   ' information26:'||p_eit_table(l_index).information26||
	   ' information27:'||p_eit_table(l_index).information27||
	   ' information28:'||p_eit_table(l_index).information28||
	   ' information29:'||p_eit_table(l_index).information29||
	   ' information30:'||p_eit_table(l_index).information30);

     end if;

     l_index := p_eit_table.next(l_index);
   END LOOP;
   hr_utility.trace('End of LOOP:'||l_proc );
   hr_utility.set_location('Exiting:'||l_proc, 20);

END dump_eit_table;


end hr_process_eit_ss;

/
