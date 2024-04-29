--------------------------------------------------------
--  DDL for Package Body HR_DOR_REVIEW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOR_REVIEW_SS" As
/* $Header: hrdorrevss.pkb 120.0.12010000.13 2010/06/07 09:50:20 tkghosh noship $ */
--
-- Package variables
g_package      varchar2(30)   := 'HR_DOR_REVIEW_SS';
g_data_error            exception;
--


--  ---------------------------------------------------------------------------
--  |----------------------< get_approval_req >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_approval_req  (
          itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	    funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )
IS

l_item_value varchar2(200);

BEGIN
	hr_utility.set_location('ENTERING get_approval_req', 10);
	IF (funcmode='RUN') THEN
     l_item_value := wf_engine.getItemAttrText(
										 itemtype => itemtype
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



--------------------------------------------------------------------------
--------------------------Start_transaction-------------------------------
-------This method creates record in tables hr_api_transactions and ------
-------hr_api_transaction_steps.------------------------------------------
--------------------------------------------------------------------------


PROCEDURE start_transaction(
						   p_item_type                    in varchar2
						  ,p_item_key                     in varchar2
						  ,p_act_id                       in number
						  ,p_fun_mode                     in varchar2
						  ,p_login_person_id              in number
						  ,p_product_code                 in varchar2 default 'PER'
						  ,p_url                          in varchar2 default null
						  ,p_status                       in varchar2 default 'W'
						  ,p_section_display_name         in varchar2 default null
						  ,p_function_id                  in number default null
						  ,p_transaction_ref_table        in varchar2 default 'HR_DOCUMENT_EXTRA_INFO'
						  ,p_transaction_ref_id           in number default null
						  ,p_transaction_type             in varchar2 default 'WF'
						  ,p_assignment_id                in number default null
						  ,p_api_addtnl_info              in varchar2 default null
						  ,p_selected_person_id           in number default null
						  ,p_transaction_effective_date   in date default sysdate
						  ,p_process_name                 in varchar2 default null
						  ,p_plan_id                      in number default null
						  ,p_rptg_grp_id                  in number default null
						  ,p_effective_date_option        in varchar2 default 'E'
						  ,p_save_mode                    in varchar2 default null
						  ,p_transaction_step_id          out nocopy  number
						  ,p_transaction_id               out nocopy  number
						  ,p_error_message                out nocopy  varchar2)
IS

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
  p_effective_date             Date;

  Cursor cur_trans(p_selected_person_id IN number) is
    select transaction_id
    from hr_api_transactions
    where transaction_ref_table = 'HR_DOCUMENT_EXTRA_INFO'
    and status ='W'
    and selected_person_id = p_selected_person_id ;

  BEGIN
--  hr_utility.trace_on(null,'ORCL1');
  hr_utility.set_location('Entering '||g_package||'.start_transaction', 10);



  --
  IF l_transaction_id is null THEN

--deleting the transactions that are in status 'W' to avoid inadvertent SFL

      for t_rec in cur_trans(p_selected_person_id)
      loop
          hr_transaction_api.rollback_transaction(
                      p_transaction_id => t_rec.transaction_id);
      end loop;


     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_act_id
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id
           ,p_product_code => p_product_code
           ,p_url => p_url
           ,p_status => p_status
           ,p_section_display_name => p_section_display_name
           ,p_function_id => p_function_id
           ,p_transaction_ref_table => p_transaction_ref_table
           ,p_transaction_ref_id => p_transaction_ref_id
           ,p_transaction_type => p_transaction_type
           ,p_assignment_id => p_assignment_id
           ,p_api_addtnl_info => p_api_addtnl_info
           ,p_selected_person_id => p_selected_person_id
           ,p_transaction_effective_date => p_transaction_effective_date
           ,p_process_name => p_process_name
           ,p_plan_id => p_plan_id
           ,p_rptg_grp_id => p_rptg_grp_id
           ,p_effective_date_option => p_effective_date_option
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);

        wf_engine.SetItemAttrText(
                          itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'TRANSACTION_ID',
                          avalue => l_transaction_id);

       wf_engine.SetItemAttrText(
                          itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'HR_REVIEW_TEMPLATE_RN_ATTR',
                          avalue => 'DOR_REVIEW_NTF');

    wf_engine.SetItemAttrText(
                          itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'HR_RESTRICT_EDIT_ATTR',
                          avalue => 'Y');


  END IF;

  --
  -- Delete transaction step if exist
  --

  IF (hr_transaction_api.transaction_step_exist  (p_item_type => p_item_type
			     			 ,p_item_key => p_item_key
			     			 ,p_activity_id => p_act_id) )  THEN

      hr_transaction_api.get_transaction_step_info(
							 p_item_type             => p_item_type
						  ,p_item_key              => p_item_key
 						  ,p_activity_id           => p_act_id
 						  ,p_transaction_step_id   => l_old_transaction_step_id
 						  ,p_object_version_number => l_old_object_version_number);


      hr_transaction_api.delete_transaction_step(
        					 p_validate                    => false
        					,p_transaction_step_id         => l_old_transaction_step_id
        					,p_person_id                   => p_login_person_id
       						,p_object_version_number       => l_old_object_version_number);

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
     ,p_activity_id           => p_act_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);

----Saving all the mandatory values in the hr_api_transaction_values table----


  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SELECTED_PERSON_ID';
  l_transaction_table(l_count).param_value := p_selected_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
  l_transaction_table(l_count).param_value := p_assignment_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_act_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_act_id
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);

p_transaction_step_id := l_transaction_step_id;
p_transaction_id := l_transaction_id;

if p_error_message = 'E' then
  hr_utility.raise_error;
else
  p_error_message := 'S';
end if;

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

END start_transaction;


--------------------------------------------------------------------------
--------------------------save_transaction_values-------------------------
-----This method stores the document information of a person in the ------
-----hr_api_transaction_values table--------------------------------------
--------------------------------------------------------------------------


PROCEDURE save_transaction_values(
   p_transaction_step_id          in     varchar2
  ,p_login_person_id              in     varchar2
  ,p_person_id                    in     number
  ,p_document_extra_info_id       in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_document_number              in     varchar2
  ,p_issued_by                    in     varchar2  default null
  ,p_issued_at                    in     varchar2  default null
  ,p_issued_date                  in     date      default null
  ,p_issuing_authority            in     varchar2  default null
  ,p_verified_by                  in     number    default null
  ,p_verified_date                in     date      default null
  ,p_related_object_name          in     varchar2  default null
  ,p_related_object_id_col        in     varchar2  default null
  ,p_related_object_id            in     number    default null
  ,p_dei_attribute_category       in     varchar2  default null
  ,p_dei_attribute1               in     varchar2  default null
  ,p_dei_attribute2               in     varchar2  default null
  ,p_dei_attribute3               in     varchar2  default null
  ,p_dei_attribute4               in     varchar2  default null
  ,p_dei_attribute5               in     varchar2  default null
  ,p_dei_attribute6               in     varchar2  default null
  ,p_dei_attribute7               in     varchar2  default null
  ,p_dei_attribute8               in     varchar2  default null
  ,p_dei_attribute9               in     varchar2  default null
  ,p_dei_attribute10              in     varchar2  default null
  ,p_dei_attribute11              in     varchar2  default null
  ,p_dei_attribute12              in     varchar2  default null
  ,p_dei_attribute13              in     varchar2  default null
  ,p_dei_attribute14              in     varchar2  default null
  ,p_dei_attribute15              in     varchar2  default null
  ,p_dei_attribute16              in     varchar2  default null
  ,p_dei_attribute17              in     varchar2  default null
  ,p_dei_attribute18              in     varchar2  default null
  ,p_dei_attribute19              in     varchar2  default null
  ,p_dei_attribute20              in     varchar2  default null
  ,p_dei_attribute21              in     varchar2  default null
  ,p_dei_attribute22              in     varchar2  default null
  ,p_dei_attribute23              in     varchar2  default null
  ,p_dei_attribute24              in     varchar2  default null
  ,p_dei_attribute25              in     varchar2  default null
  ,p_dei_attribute26              in     varchar2  default null
  ,p_dei_attribute27              in     varchar2  default null
  ,p_dei_attribute28              in     varchar2  default null
  ,p_dei_attribute29              in     varchar2  default null
  ,p_dei_attribute30              in     varchar2  default null
  ,p_dei_information_category     in     varchar2  default null
  ,p_dei_information1             in     varchar2  default null
  ,p_dei_information2             in     varchar2  default null
  ,p_dei_information3             in     varchar2  default null
  ,p_dei_information4             in     varchar2  default null
  ,p_dei_information5             in     varchar2  default null
  ,p_dei_information6             in     varchar2  default null
  ,p_dei_information7             in     varchar2  default null
  ,p_dei_information8             in     varchar2  default null
  ,p_dei_information9             in     varchar2  default null
  ,p_dei_information10            in     varchar2  default null
  ,p_dei_information11            in     varchar2  default null
  ,p_dei_information12            in     varchar2  default null
  ,p_dei_information13            in     varchar2  default null
  ,p_dei_information14            in     varchar2  default null
  ,p_dei_information15            in     varchar2  default null
  ,p_dei_information16            in     varchar2  default null
  ,p_dei_information17            in     varchar2  default null
  ,p_dei_information18            in     varchar2  default null
  ,p_dei_information19            in     varchar2  default null
  ,p_dei_information20            in     varchar2  default null
  ,p_dei_information21            in     varchar2  default null
  ,p_dei_information22            in     varchar2  default null
  ,p_dei_information23            in     varchar2  default null
  ,p_dei_information24            in     varchar2  default null
  ,p_dei_information25            in     varchar2  default null
  ,p_dei_information26            in     varchar2  default null
  ,p_dei_information27            in     varchar2  default null
  ,p_dei_information28            in     varchar2  default null
  ,p_dei_information29            in     varchar2  default null
  ,p_dei_information30            in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is

  l_proc varchar2(70) :=   g_package||'.save_transaction_values';
  p_action_mode            varchar2(30);
  p_transaction_id         hr_api_transactions.transaction_id%type;
  p_org_rec                hr_document_extra_info%rowtype;
  msg_name                 varchar2(1000);
  msg_appl                 varchar2(10);

BEGIN
--  hr_utility.trace_on(null,'ORCL1');
  hr_utility.set_location('Entering '||l_proc, 30);
  --

p_transaction_id := get_transaction_id(p_transaction_step_id);
p_action_mode := getActionMode(p_transaction_id);

/*-----------Flipping the old attachments primary key from docextrainfoid
           to transactionstepid ----------------------------------*/

 /*save_attachments(
   p_transaction_id           => p_transaction_step_id
  ,p_document_extra_info_id   => p_document_extra_info_id
  ,p_flip_flag                => 'TXN'
  ,p_return_status            => p_return_status);*/


IF p_transaction_step_id IS NOT NULL AND
   p_login_person_id IS NOT NULL THEN

	hr_transaction_api.set_number_value
	(p_transaction_step_id  => p_transaction_step_id
	,p_person_id      => p_login_person_id
	,p_name                 => 'P_PERSON_ID'
	,p_value                => p_person_id);

	hr_transaction_api.set_number_value
	(p_transaction_step_id  => p_transaction_step_id
	,p_person_id      => p_login_person_id
	,p_name                 => 'P_DOCUMENT_TYPE_ID'
	,p_value                => p_document_type_id);

	hr_transaction_api.set_number_value
	(p_transaction_step_id  => p_transaction_step_id
	,p_person_id      => p_login_person_id
	,p_name                 => 'P_DOCUMENT_EXTRA_INFO_ID'
	,p_value                => p_document_extra_info_id);

	if p_action_mode = 'DOR_INSERT' then

			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_FROM'
			,p_value                => p_date_from);

			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_TO'
			,p_value                => p_date_to);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DOCUMENT_NUMBER'
			,p_value                => p_document_number);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_BY'
			,p_value                => p_issued_by);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_AT'
			,p_value                => p_issued_at);

			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_DATE'
			,p_value                => p_issued_date);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUING_AUTHORITY'
			,p_value                => p_issuing_authority);

			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_BY'
			,p_value                => p_verified_by);

			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_DATE'
			,p_value                => p_verified_date);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_NAME'
			,p_value                => p_related_object_name);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID_COL'
			,p_value                => p_related_object_id_col);

			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID'
			,p_value                => p_related_object_id);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE_CATEGORY'
			,p_value                => p_dei_attribute_category);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE1'
			,p_value                => p_dei_attribute1);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE2'
			,p_value                => p_dei_attribute2);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE3'
			,p_value                => p_dei_attribute3);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE4'
			,p_value                => p_dei_attribute4);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE5'
			,p_value                => p_dei_attribute5);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE6'
			,p_value                => p_dei_attribute6);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE7'
			,p_value                => p_dei_attribute7);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE8'
			,p_value                => p_dei_attribute8);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE9'
			,p_value                => p_dei_attribute9);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE10'
			,p_value                => p_dei_attribute10);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE11'
			,p_value                => p_dei_attribute11);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE12'
			,p_value                => p_dei_attribute12);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE13'
			,p_value                => p_dei_attribute13);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE14'
			,p_value                => p_dei_attribute14);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE15'
			,p_value                => p_dei_attribute15);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE16'
			,p_value                => p_dei_attribute16);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE17'
			,p_value                => p_dei_attribute17);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE18'
			,p_value                => p_dei_attribute18);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE19'
			,p_value                => p_dei_attribute19);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE20'
			,p_value                => p_dei_attribute20);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE21'
			,p_value                => p_dei_attribute21);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE22'
			,p_value                => p_dei_attribute22);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE23'
			,p_value                => p_dei_attribute23);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE24'
			,p_value                => p_dei_attribute24);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE25'
			,p_value                => p_dei_attribute25);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE26'
			,p_value                => p_dei_attribute26);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE27'
			,p_value                => p_dei_attribute27);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE28'
			,p_value                => p_dei_attribute28);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE29'
			,p_value                => p_dei_attribute29);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE30'
			,p_value                => p_dei_attribute30);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION_CATEGORY'
			,p_value                => p_dei_information_category);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION1'
			,p_value                => p_dei_information1);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION2'
			,p_value                => p_dei_information2);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION3'
			,p_value                => p_dei_information3);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION4'
			,p_value                => p_dei_information4);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION5'
			,p_value                => p_dei_information5);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION6'
			,p_value                => p_dei_information6);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION7'
			,p_value                => p_dei_information7);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION8'
			,p_value                => p_dei_information8);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION9'
			,p_value                => p_dei_information9);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION10'
			,p_value                => p_dei_information10);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION11'
			,p_value                => p_dei_information11);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION12'
			,p_value                => p_dei_information12);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION13'
			,p_value                => p_dei_information13);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION14'
			,p_value                => p_dei_information14);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION15'
			,p_value                => p_dei_information15);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION16'
			,p_value                => p_dei_information16);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION17'
			,p_value                => p_dei_information17);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION18'
			,p_value                => p_dei_information18);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION19'
			,p_value                => p_dei_information19);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION20'
			,p_value                => p_dei_information20);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION21'
			,p_value                => p_dei_information21);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION22'
			,p_value                => p_dei_information22);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION23'
			,p_value                => p_dei_information23);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION24'
			,p_value                => p_dei_information24);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION25'
			,p_value                => p_dei_information25);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION26'
			,p_value                => p_dei_information26);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION27'
			,p_value                => p_dei_information27);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION28'
			,p_value                => p_dei_information28);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION29'
			,p_value                => p_dei_information29);

			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION30'
			,p_value                => p_dei_information30);


			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_REQUEST_ID'
			,p_value                => p_request_id);

			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_APPLICATION_ID'
			,p_value                => p_program_application_id);

			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_ID'
			,p_value                => p_program_id);

			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_UPDATE_DATE'
			,p_value                => p_program_update_date);

			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_OBJECT_VERSION_NUMBER'
			,p_value                => p_object_version_number);


	elsif p_action_mode = 'DOR_UPDATE' then

	SELECT *
	INTO p_org_rec
	FROM HR_DOCUMENT_EXTRA_INFO
	WHERE document_extra_info_id = p_document_extra_info_id
	AND   person_id = p_person_id
	AND   document_type_id = p_document_type_id;


	if p_org_rec.date_from = p_date_from then
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_FROM'
			,p_value                => p_date_from);
	else
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_FROM'
			,p_value                => p_date_from
			,p_original_value       => p_org_rec.date_from);
	end if;

	if p_org_rec.date_to = p_date_to then
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_TO'
			,p_value                => p_date_to);
	else
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DATE_TO'
			,p_value                => p_date_to
			,p_original_value       => p_org_rec.date_to);
	end if;

	if p_org_rec.document_number = p_document_number then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DOCUMENT_NUMBER'
			,p_value                => p_document_number);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DOCUMENT_NUMBER'
			,p_value                => p_document_number
			,p_original_value       => p_org_rec.document_number);
	end if;

	if p_org_rec.issued_by = p_issued_by then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_BY'
			,p_value                => p_issued_by);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_BY'
			,p_value                => p_issued_by
			,p_original_value       => p_org_rec.issued_by);
	end if;

	if p_org_rec.issued_at = p_issued_at then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_AT'
			,p_value                => p_issued_at);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_AT'
			,p_value                => p_issued_at
			,p_original_value       => p_org_rec.issued_at);
	end if;

	if p_org_rec.issued_date = p_issued_date then
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_DATE'
			,p_value                => p_issued_date);
	else
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUED_DATE'
			,p_value                => p_issued_date
			,p_original_value       => p_org_rec.issued_date);
	end if;

	if p_org_rec.issuing_authority = p_issuing_authority then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUING_AUTHORITY'
			,p_value                => p_issuing_authority);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_ISSUING_AUTHORITY'
			,p_value                => p_issuing_authority
			,p_original_value       => p_org_rec.issuing_authority);
	end if;

	if p_org_rec.verified_by = p_verified_by then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_BY'
			,p_value                => p_verified_by);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_BY'
			,p_value                => p_verified_by
			,p_original_value       => p_org_rec.verified_by);
	end if;

	if p_org_rec.verified_date = p_verified_date then
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_DATE'
			,p_value                => p_verified_date);
	else
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_VERIFIED_DATE'
			,p_value                => p_verified_date
			,p_original_value       => p_org_rec.verified_date);
	end if;

	if p_org_rec.related_object_name = p_related_object_name then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_NAME'
			,p_value                => p_related_object_name);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_NAME'
			,p_value                => p_related_object_name
			,p_original_value       => p_org_rec.related_object_name);
	end if;

	if p_org_rec.related_object_id_col = p_related_object_id_col then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID_COL'
			,p_value                => p_related_object_id_col);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID_COL'
			,p_value                => p_related_object_id_col
			,p_original_value       => p_org_rec.related_object_id_col);
	end if;

	if p_org_rec.related_object_id = p_related_object_id then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID'
			,p_value                => p_related_object_id);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_RELATED_OBJECT_ID'
			,p_value                => p_related_object_id
			,p_original_value       => p_org_rec.related_object_id);
	end if;

	if p_org_rec.dei_attribute_category = p_dei_attribute_category then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE_CATEGORY'
			,p_value                => p_dei_attribute_category);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE_CATEGORY'
			,p_value                => p_dei_attribute_category
			,p_original_value       => p_org_rec.dei_attribute_category);
	end if;

	if p_org_rec.dei_attribute1 = p_dei_attribute1 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE1'
			,p_value                => p_dei_attribute1);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE1'
			,p_value                => p_dei_attribute1
			,p_original_value       => p_org_rec.dei_attribute1);
	end if;

	if p_org_rec.dei_attribute2 = p_dei_attribute2 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE2'
			,p_value                => p_dei_attribute2);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE2'
			,p_value                => p_dei_attribute2
			,p_original_value       => p_org_rec.dei_attribute2);
	end if;

	if p_org_rec.dei_attribute3 = p_dei_attribute3 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE3'
			,p_value                => p_dei_attribute3);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE3'
			,p_value                => p_dei_attribute3
			,p_original_value       => p_org_rec.dei_attribute3);
	end if;

	if p_org_rec.dei_attribute4 = p_dei_attribute4 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE4'
			,p_value                => p_dei_attribute4);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE4'
			,p_value                => p_dei_attribute4
			,p_original_value       => p_org_rec.dei_attribute4);
	end if;

	if p_org_rec.dei_attribute5 = p_dei_attribute5 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE5'
			,p_value                => p_dei_attribute5);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE5'
			,p_value                => p_dei_attribute5
			,p_original_value       => p_org_rec.dei_attribute5);
	end if;

	if p_org_rec.dei_attribute6 = p_dei_attribute6 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE6'
			,p_value                => p_dei_attribute6);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE6'
			,p_value                => p_dei_attribute6
			,p_original_value       => p_org_rec.dei_attribute6);
end if;

	if p_org_rec.dei_attribute7 = p_dei_attribute7 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE7'
			,p_value                => p_dei_attribute7);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE7'
			,p_value                => p_dei_attribute7
			,p_original_value       => p_org_rec.dei_attribute7);
	end if;

	if p_org_rec.dei_attribute8 = p_dei_attribute8 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE8'
			,p_value                => p_dei_attribute8);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE8'
			,p_value                => p_dei_attribute8
			,p_original_value       => p_org_rec.dei_attribute8);
	end if;

	if p_org_rec.dei_attribute9 = p_dei_attribute9 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE9'
			,p_value                => p_dei_attribute9);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE9'
			,p_value                => p_dei_attribute9
			,p_original_value       => p_org_rec.dei_attribute9);
	end if;

	if p_org_rec.dei_attribute10 = p_dei_attribute10 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE10'
			,p_value                => p_dei_attribute10);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE10'
			,p_value                => p_dei_attribute10
			,p_original_value       => p_org_rec.dei_attribute10);
	end if;

	if p_org_rec.dei_attribute11 = p_dei_attribute11 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE11'
			,p_value                => p_dei_attribute11);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE11'
			,p_value                => p_dei_attribute11
			,p_original_value       => p_org_rec.dei_attribute11);
	end if;

	if p_org_rec.dei_attribute12 = p_dei_attribute12 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE12'
			,p_value                => p_dei_attribute12);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE12'
			,p_value                => p_dei_attribute12
			,p_original_value       => p_org_rec.dei_attribute12);
	end if;

	if p_org_rec.dei_attribute13 = p_dei_attribute13 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE13'
			,p_value                => p_dei_attribute13);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE13'
			,p_value                => p_dei_attribute13
			,p_original_value       => p_org_rec.dei_attribute13);
	end if;

	if p_org_rec.dei_attribute14 = p_dei_attribute14 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE14'
			,p_value                => p_dei_attribute14);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE14'
			,p_value                => p_dei_attribute14
			,p_original_value       => p_org_rec.dei_attribute14);
	end if;

	if p_org_rec.dei_attribute15 = p_dei_attribute15 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE15'
			,p_value                => p_dei_attribute15);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE15'
			,p_value                => p_dei_attribute15
			,p_original_value       => p_org_rec.dei_attribute15);
	end if;

	if p_org_rec.dei_attribute16 = p_dei_attribute16 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE16'
			,p_value                => p_dei_attribute16);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE16'
			,p_value                => p_dei_attribute16
			,p_original_value       => p_org_rec.dei_attribute16);
	end if;

	if p_org_rec.dei_attribute17 = p_dei_attribute17 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE17'
			,p_value                => p_dei_attribute17);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE17'
			,p_value                => p_dei_attribute17
			,p_original_value       => p_org_rec.dei_attribute17);
	end if;

	if p_org_rec.dei_attribute18 = p_dei_attribute18 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE18'
			,p_value                => p_dei_attribute18);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE18'
			,p_value                => p_dei_attribute18
			,p_original_value       => p_org_rec.dei_attribute18);
	end if;

	if p_org_rec.dei_attribute19 = p_dei_attribute19 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE19'
			,p_value                => p_dei_attribute19);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE19'
			,p_value                => p_dei_attribute19
			,p_original_value       => p_org_rec.dei_attribute19);
	end if;

	if p_org_rec.dei_attribute20 = p_dei_attribute20 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE20'
			,p_value                => p_dei_attribute20);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE20'
			,p_value                => p_dei_attribute20
			,p_original_value       => p_org_rec.dei_attribute20);
	end if;

	if p_org_rec.dei_attribute21 = p_dei_attribute21 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE21'
			,p_value                => p_dei_attribute21);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE21'
			,p_value                => p_dei_attribute21
			,p_original_value       => p_org_rec.dei_attribute21);
	end if;

	if p_org_rec.dei_attribute22 = p_dei_attribute22 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE22'
			,p_value                => p_dei_attribute22);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE22'
			,p_value                => p_dei_attribute22
			,p_original_value       => p_org_rec.dei_attribute22);
	end if;

	if p_org_rec.dei_attribute23 = p_dei_attribute23 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE23'
			,p_value                => p_dei_attribute23);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE23'
			,p_value                => p_dei_attribute23
			,p_original_value       => p_org_rec.dei_attribute23);
	end if;

	if p_org_rec.dei_attribute24 = p_dei_attribute24 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE24'
			,p_value                => p_dei_attribute24);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE24'
			,p_value                => p_dei_attribute24
			,p_original_value       => p_org_rec.dei_attribute24);
	end if;

	if p_org_rec.dei_attribute25 = p_dei_attribute25 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE25'
			,p_value                => p_dei_attribute25);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE25'
			,p_value                => p_dei_attribute25
			,p_original_value       => p_org_rec.dei_attribute25);
	end if;

	if p_org_rec.dei_attribute26 = p_dei_attribute26 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE26'
			,p_value                => p_dei_attribute26);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE26'
			,p_value                => p_dei_attribute26
			,p_original_value       => p_org_rec.dei_attribute26);
	end if;

	if p_org_rec.dei_attribute27 = p_dei_attribute27 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE27'
			,p_value                => p_dei_attribute27);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE27'
			,p_value                => p_dei_attribute27
			,p_original_value       => p_org_rec.dei_attribute27);
	end if;

	if p_org_rec.dei_attribute28 = p_dei_attribute28 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE28'
			,p_value                => p_dei_attribute28);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE28'
			,p_value                => p_dei_attribute28
			,p_original_value       => p_org_rec.dei_attribute28);
	end if;

	if p_org_rec.dei_attribute29 = p_dei_attribute29 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE29'
			,p_value                => p_dei_attribute29);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE29'
			,p_value                => p_dei_attribute29
			,p_original_value       => p_org_rec.dei_attribute29);
	end if;

	if p_org_rec.dei_attribute30 = p_dei_attribute30 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE30'
			,p_value                => p_dei_attribute30);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_ATTRIBUTE30'
			,p_value                => p_dei_attribute30
			,p_original_value       => p_org_rec.dei_attribute30);
	end if;

	if p_org_rec.dei_information_category = p_dei_information_category then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION_CATEGORY'
			,p_value                => p_dei_information_category);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION_CATEGORY'
			,p_value                => p_dei_information_category
			,p_original_value       => p_org_rec.dei_information_category);
	end if;

	if p_org_rec.dei_information1 = p_dei_information1 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION1'
			,p_value                => p_dei_information1);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION1'
			,p_value                => p_dei_information1
			,p_original_value       => p_org_rec.dei_information1);
	end if;

	if p_org_rec.dei_information2 = p_dei_information2 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION2'
			,p_value                => p_dei_information2);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION2'
			,p_value                => p_dei_information2
			,p_original_value       => p_org_rec.dei_information2);
	end if;

	if p_org_rec.dei_information3 = p_dei_information3 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION3'
			,p_value                => p_dei_information3);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION3'
			,p_value                => p_dei_information3
			,p_original_value       => p_org_rec.dei_information3);
	end if;

	if p_org_rec.dei_information4 = p_dei_information4 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION4'
			,p_value                => p_dei_information4);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION4'
			,p_value                => p_dei_information4
			,p_original_value       => p_org_rec.dei_information4);
	end if;

	if p_org_rec.dei_information5 = p_dei_information5 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION5'
			,p_value                => p_dei_information5);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION5'
			,p_value                => p_dei_information5
			,p_original_value       => p_org_rec.dei_information5);
	end if;

	if p_org_rec.dei_information6 = p_dei_information6 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION6'
			,p_value                => p_dei_information6);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION6'
			,p_value                => p_dei_information6
			,p_original_value       => p_org_rec.dei_information6);
	end if;

	if p_org_rec.dei_information7 = p_dei_information7 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION7'
			,p_value                => p_dei_information7);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION7'
			,p_value                => p_dei_information7
			,p_original_value       => p_org_rec.dei_information7);
	end if;

	if p_org_rec.dei_information8 = p_dei_information8 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION8'
			,p_value                => p_dei_information8);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION8'
			,p_value                => p_dei_information8
			,p_original_value       => p_org_rec.dei_information8);
	end if;

	if p_org_rec.dei_information9 = p_dei_information9 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION9'
			,p_value                => p_dei_information9);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION9'
			,p_value                => p_dei_information9
			,p_original_value       => p_org_rec.dei_information9);
	end if;

	if p_org_rec.dei_information10 = p_dei_information10 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION10'
			,p_value                => p_dei_information10);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION10'
			,p_value                => p_dei_information10
			,p_original_value       => p_org_rec.dei_information10);
	end if;
	if p_org_rec.dei_information11 = p_dei_information11 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION11'
			,p_value                => p_dei_information11);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION11'
			,p_value                => p_dei_information11
			,p_original_value       => p_org_rec.dei_information11);
	end if;

	if p_org_rec.dei_information12 = p_dei_information12 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION12'
			,p_value                => p_dei_information12);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION12'
			,p_value                => p_dei_information12
			,p_original_value       => p_org_rec.dei_information12);
	end if;

	if p_org_rec.dei_information13 = p_dei_information13 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION13'
			,p_value                => p_dei_information13);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION13'
			,p_value                => p_dei_information13
			,p_original_value       => p_org_rec.dei_information13);
	end if;

	if p_org_rec.dei_information14 = p_dei_information14 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION14'
			,p_value                => p_dei_information14);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION14'
			,p_value                => p_dei_information14
			,p_original_value       => p_org_rec.dei_information14);
	end if;

	if p_org_rec.dei_information15 = p_dei_information15 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION15'
			,p_value                => p_dei_information15);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION15'
			,p_value                => p_dei_information15
			,p_original_value       => p_org_rec.dei_information15);
	end if;

	if p_org_rec.dei_information16 = p_dei_information16 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION16'
			,p_value                => p_dei_information16);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION16'
			,p_value                => p_dei_information16
			,p_original_value       => p_org_rec.dei_information16);
	end if;

	if p_org_rec.dei_information17 = p_dei_information17 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION17'
			,p_value                => p_dei_information17);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION17'
			,p_value                => p_dei_information17
			,p_original_value       => p_org_rec.dei_information17);
	end if;

	if p_org_rec.dei_information18 = p_dei_information18 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION18'
			,p_value                => p_dei_information18);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION18'
			,p_value                => p_dei_information18
			,p_original_value       => p_org_rec.dei_information18);
	end if;

	if p_org_rec.dei_information19 = p_dei_information19 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION19'
			,p_value                => p_dei_information19);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION19'
			,p_value                => p_dei_information19
			,p_original_value       => p_org_rec.dei_information19);
	end if;

	if p_org_rec.dei_information20 = p_dei_information20 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION20'
			,p_value                => p_dei_information20);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION20'
			,p_value                => p_dei_information20
			,p_original_value       => p_org_rec.dei_information20);
	end if;

	if p_org_rec.dei_information21 = p_dei_information21 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION21'
			,p_value                => p_dei_information21);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION21'
			,p_value                => p_dei_information21
			,p_original_value       => p_org_rec.dei_information21);
	end if;

	if p_org_rec.dei_information22 = p_dei_information22 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION22'
			,p_value                => p_dei_information22);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION22'
			,p_value                => p_dei_information22
			,p_original_value       => p_org_rec.dei_information22);
	end if;

	if p_org_rec.dei_information23 = p_dei_information23 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION23'
			,p_value                => p_dei_information23);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION23'
			,p_value                => p_dei_information23
			,p_original_value       => p_org_rec.dei_information23);
	end if;

	if p_org_rec.dei_information24 = p_dei_information24 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION24'
			,p_value                => p_dei_information24);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION24'
			,p_value                => p_dei_information24
			,p_original_value       => p_org_rec.dei_information24);
	end if;

	if p_org_rec.dei_information25 = p_dei_information25 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION25'
			,p_value                => p_dei_information25);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION25'
			,p_value                => p_dei_information25
			,p_original_value       => p_org_rec.dei_information25);
	end if;

	if p_org_rec.dei_information26 = p_dei_information26 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION26'
			,p_value                => p_dei_information26);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION26'
			,p_value                => p_dei_information26
			,p_original_value       => p_org_rec.dei_information26);
	end if;

	if p_org_rec.dei_information27 = p_dei_information27 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION27'
			,p_value                => p_dei_information27);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION27'
			,p_value                => p_dei_information27
			,p_original_value       => p_org_rec.dei_information27);
	end if;

	if p_org_rec.dei_information28 = p_dei_information28 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION28'
			,p_value                => p_dei_information28);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION28'
			,p_value                => p_dei_information28
			,p_original_value       => p_org_rec.dei_information28);
	end if;

	if p_org_rec.dei_information29 = p_dei_information29 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION29'
			,p_value                => p_dei_information29);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION29'
			,p_value                => p_dei_information29
			,p_original_value       => p_org_rec.dei_information29);
	end if;

	if p_org_rec.dei_information30 = p_dei_information30 then
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION30'
			,p_value                => p_dei_information30);
	else
			hr_transaction_api.set_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_DEI_INFORMATION30'
			,p_value                => p_dei_information30
			,p_original_value       => p_org_rec.dei_information30);
	end if;

	if p_org_rec.request_id = p_request_id then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_REQUEST_ID'
			,p_value                => p_request_id);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_REQUEST_ID'
			,p_value                => p_request_id
			,p_original_value       => p_org_rec.request_id);
	end if;

	if p_org_rec.program_application_id = p_program_application_id then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_APPLICATION_ID'
			,p_value                => p_program_application_id
			,p_original_value       => p_org_rec.program_application_id);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_APPLICATION_ID'
			,p_value                => p_program_application_id);
	end if;

	if p_org_rec.program_id = p_program_id then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_ID'
			,p_value                => p_program_id
			,p_original_value       => p_org_rec.program_id);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_ID'
			,p_value                => p_program_id);
	end if;

	if p_org_rec.program_update_date = p_program_update_date then
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_UPDATE_DATE'
			,p_value                => p_program_update_date);
	else
			hr_transaction_api.set_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_PROGRAM_UPDATE_DATE'
			,p_value                => p_program_update_date
			,p_original_value       => p_org_rec.program_update_date);
	end if;

	if p_org_rec.object_version_number = p_object_version_number then
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_OBJECT_VERSION_NUMBER'
			,p_value                => p_object_version_number);
	else
			hr_transaction_api.set_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_person_id      => p_login_person_id
			,p_name                 => 'P_OBJECT_VERSION_NUMBER'
			,p_value                => p_object_version_number
			,p_original_value       => p_org_rec.object_version_number);
	end if;

	end if;

END IF;

if p_return_status = 'E' then
  hr_utility.raise_error;
else
  p_return_status := 'S';
end if;

EXCEPTION

    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in '||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,666);
      p_return_status := SQLERRM;

		 WHEN hr_utility.hr_error THEN
     hr_utility.get_message_details(msg_name,msg_appl);
     fnd_message.set_name(msg_appl,msg_name);
     p_return_status := hr_utility.get_message;

    WHEN OTHERS THEN
      hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,660);
      p_return_status := SQLERRM;


END save_transaction_values;
--------------------------------------------------------------------------
--------------------------Process_api-------------------------------------
------This method is called from commit_transaction ----------------------
--------------------------------------------------------------------------

  procedure process_api
   (p_validate                 in     boolean default false
   ,p_transaction_step_id      in     number
   ,p_effective_date           in     varchar2 default null
   )
IS

  l_proc    varchar2(72) := g_package ||'.process_api';
  p_dor_rec                HR_DOCUMENT_EXTRA_INFO%rowtype;
  p_return_status          varchar2(100);
  l_object_version_number  number;
  l_effective_date         date;
  l_validate               number;
  p_item_type              wf_items.item_type%type;
  p_item_key               wf_items.item_key%type;
  p_action_mode            varchar2(30);
  p_transaction_id         hr_api_transactions.transaction_id%type;
  l_user_name              varchar2(30);
  l_verified_by            number;
  l_verified_date          date;
  msg_name                 varchar2(1000);
  msg_appl                 varchar2(10);

BEGIN

--  hr_utility.trace_on(null,'ORCL1');
  hr_utility.set_location(' Entering:' || l_proc,40);


  If p_validate then
			l_validate := hr_api.g_true_num;
  else
			l_validate := hr_api.g_false_num;
  end if;

p_transaction_id := get_transaction_id(p_transaction_step_id);
p_action_mode := getActionMode(p_transaction_id);


get_review_data_from_tt(
				p_transaction_step_id => p_transaction_step_id
				,p_dor_rec => p_dor_rec);

p_item_type :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ITEM_TYPE');

p_item_key :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ITEM_KEY');

if p_dor_rec.verified_by is null then

   l_user_name := wf_engine.GetItemAttrText(
	itemtype => p_item_type,
                         itemkey  => p_item_key,
                         aname    => 'FORWARD_TO_USERNAME');

   if l_user_name is not null then
   	select user_id into l_verified_by
   	from fnd_user where user_name =  l_user_name;
   end if;
   l_verified_date := sysdate;

end if;

if p_action_mode = 'DOR_INSERT' then
  hr_document_extra_info_swi.create_doc_extra_info
    (p_validate                     => l_validate
    ,p_person_id                    => p_dor_rec.person_id
    ,p_document_type_id             => p_dor_rec.document_type_id
    ,p_date_from                    => p_dor_rec.date_from
    ,p_date_to                      => p_dor_rec.date_to
    ,p_document_number              => p_dor_rec.document_number
    ,p_issued_by                    => p_dor_rec.issued_by
    ,p_issued_at                    => p_dor_rec.issued_at
    ,p_issued_date                  => p_dor_rec.issued_date
    ,p_issuing_authority            => p_dor_rec.issuing_authority
    ,p_verified_by                  => l_verified_by
    ,p_verified_date                => l_verified_date
    ,p_related_object_name          => p_dor_rec.related_object_name
    ,p_related_object_id_col        => p_dor_rec.related_object_id_col
    ,p_related_object_id            => p_dor_rec.related_object_id
    ,p_dei_attribute_category       => p_dor_rec.dei_attribute_category
    ,p_dei_attribute1               => p_dor_rec.dei_attribute1
    ,p_dei_attribute2               => p_dor_rec.dei_attribute2
    ,p_dei_attribute3               => p_dor_rec.dei_attribute3
    ,p_dei_attribute4               => p_dor_rec.dei_attribute4
    ,p_dei_attribute5               => p_dor_rec.dei_attribute5
    ,p_dei_attribute6               => p_dor_rec.dei_attribute6
    ,p_dei_attribute7               => p_dor_rec.dei_attribute7
    ,p_dei_attribute8               => p_dor_rec.dei_attribute8
    ,p_dei_attribute9               => p_dor_rec.dei_attribute9
    ,p_dei_attribute10              => p_dor_rec.dei_attribute10
    ,p_dei_attribute11              => p_dor_rec.dei_attribute11
    ,p_dei_attribute12              => p_dor_rec.dei_attribute12
    ,p_dei_attribute13              => p_dor_rec.dei_attribute13
    ,p_dei_attribute14              => p_dor_rec.dei_attribute14
    ,p_dei_attribute15              => p_dor_rec.dei_attribute15
    ,p_dei_attribute16              => p_dor_rec.dei_attribute16
    ,p_dei_attribute17              => p_dor_rec.dei_attribute17
    ,p_dei_attribute18              => p_dor_rec.dei_attribute18
    ,p_dei_attribute19              => p_dor_rec.dei_attribute19
    ,p_dei_attribute20              => p_dor_rec.dei_attribute20
    ,p_dei_attribute21              => p_dor_rec.dei_attribute21
    ,p_dei_attribute22              => p_dor_rec.dei_attribute22
    ,p_dei_attribute23              => p_dor_rec.dei_attribute23
    ,p_dei_attribute24              => p_dor_rec.dei_attribute24
    ,p_dei_attribute25              => p_dor_rec.dei_attribute25
    ,p_dei_attribute26              => p_dor_rec.dei_attribute26
    ,p_dei_attribute27              => p_dor_rec.dei_attribute27
    ,p_dei_attribute28              => p_dor_rec.dei_attribute28
    ,p_dei_attribute29              => p_dor_rec.dei_attribute29
    ,p_dei_attribute30              => p_dor_rec.dei_attribute30
    ,p_dei_information_category     => p_dor_rec.dei_information_category
    ,p_dei_information1             => p_dor_rec.dei_information1
    ,p_dei_information2             => p_dor_rec.dei_information2
    ,p_dei_information3             => p_dor_rec.dei_information3
    ,p_dei_information4             => p_dor_rec.dei_information4
    ,p_dei_information5             => p_dor_rec.dei_information5
    ,p_dei_information6             => p_dor_rec.dei_information6
    ,p_dei_information7             => p_dor_rec.dei_information7
    ,p_dei_information8             => p_dor_rec.dei_information8
    ,p_dei_information9             => p_dor_rec.dei_information9
    ,p_dei_information10            => p_dor_rec.dei_information10
    ,p_dei_information11            => p_dor_rec.dei_information11
    ,p_dei_information12            => p_dor_rec.dei_information12
    ,p_dei_information13            => p_dor_rec.dei_information13
    ,p_dei_information14            => p_dor_rec.dei_information14
    ,p_dei_information15            => p_dor_rec.dei_information15
    ,p_dei_information16            => p_dor_rec.dei_information16
    ,p_dei_information17            => p_dor_rec.dei_information17
    ,p_dei_information18            => p_dor_rec.dei_information18
    ,p_dei_information19            => p_dor_rec.dei_information19
    ,p_dei_information20            => p_dor_rec.dei_information20
    ,p_dei_information21            => p_dor_rec.dei_information21
    ,p_dei_information22            => p_dor_rec.dei_information22
    ,p_dei_information23            => p_dor_rec.dei_information23
    ,p_dei_information24            => p_dor_rec.dei_information24
    ,p_dei_information25            => p_dor_rec.dei_information25
    ,p_dei_information26            => p_dor_rec.dei_information26
    ,p_dei_information27            => p_dor_rec.dei_information27
    ,p_dei_information28            => p_dor_rec.dei_information28
    ,p_dei_information29            => p_dor_rec.dei_information29
    ,p_dei_information30            => p_dor_rec.dei_information30
    ,p_request_id                   => p_dor_rec.request_id
    ,p_program_application_id       => p_dor_rec.program_application_id
    ,p_program_id                   => p_dor_rec.program_id
    ,p_program_update_date          => p_dor_rec.program_update_date
    ,p_document_extra_info_id       => p_dor_rec.document_extra_info_id
    ,p_object_version_number        => l_object_version_number
    ,p_return_status                => p_return_status
    );

elsif p_action_mode ='DOR_UPDATE' then


  hr_document_extra_info_swi.update_doc_extra_info
    (p_validate                     => l_validate
    ,p_person_id                    => p_dor_rec.person_id
    ,p_document_type_id             => p_dor_rec.document_type_id
    ,p_date_from                    => p_dor_rec.date_from
    ,p_date_to                      => p_dor_rec.date_to
    ,p_document_number              => p_dor_rec.document_number
    ,p_issued_by                    => p_dor_rec.issued_by
    ,p_issued_at                    => p_dor_rec.issued_at
    ,p_issued_date                  => p_dor_rec.issued_date
    ,p_issuing_authority            => p_dor_rec.issuing_authority
    ,p_verified_by                  => l_verified_by
    ,p_verified_date                => p_dor_rec.verified_date
    ,p_related_object_name          => p_dor_rec.related_object_name
    ,p_related_object_id_col        => p_dor_rec.related_object_id_col
    ,p_related_object_id            => p_dor_rec.related_object_id
    ,p_dei_attribute_category       => p_dor_rec.dei_attribute_category
    ,p_dei_attribute1               => p_dor_rec.dei_attribute1
    ,p_dei_attribute2               => p_dor_rec.dei_attribute2
    ,p_dei_attribute3               => p_dor_rec.dei_attribute3
    ,p_dei_attribute4               => p_dor_rec.dei_attribute4
    ,p_dei_attribute5               => p_dor_rec.dei_attribute5
    ,p_dei_attribute6               => p_dor_rec.dei_attribute6
    ,p_dei_attribute7               => p_dor_rec.dei_attribute7
    ,p_dei_attribute8               => p_dor_rec.dei_attribute8
    ,p_dei_attribute9               => p_dor_rec.dei_attribute9
    ,p_dei_attribute10              => p_dor_rec.dei_attribute10
    ,p_dei_attribute11              => p_dor_rec.dei_attribute11
    ,p_dei_attribute12              => p_dor_rec.dei_attribute12
    ,p_dei_attribute13              => p_dor_rec.dei_attribute13
    ,p_dei_attribute14              => p_dor_rec.dei_attribute14
    ,p_dei_attribute15              => p_dor_rec.dei_attribute15
    ,p_dei_attribute16              => p_dor_rec.dei_attribute16
    ,p_dei_attribute17              => p_dor_rec.dei_attribute17
    ,p_dei_attribute18              => p_dor_rec.dei_attribute18
    ,p_dei_attribute19              => p_dor_rec.dei_attribute19
    ,p_dei_attribute20              => p_dor_rec.dei_attribute20
    ,p_dei_attribute21              => p_dor_rec.dei_attribute21
    ,p_dei_attribute22              => p_dor_rec.dei_attribute22
    ,p_dei_attribute23              => p_dor_rec.dei_attribute23
    ,p_dei_attribute24              => p_dor_rec.dei_attribute24
    ,p_dei_attribute25              => p_dor_rec.dei_attribute25
    ,p_dei_attribute26              => p_dor_rec.dei_attribute26
    ,p_dei_attribute27              => p_dor_rec.dei_attribute27
    ,p_dei_attribute28              => p_dor_rec.dei_attribute28
    ,p_dei_attribute29              => p_dor_rec.dei_attribute29
    ,p_dei_attribute30              => p_dor_rec.dei_attribute30
    ,p_dei_information_category     => p_dor_rec.dei_information_category
    ,p_dei_information1             => p_dor_rec.dei_information1
    ,p_dei_information2             => p_dor_rec.dei_information2
    ,p_dei_information3             => p_dor_rec.dei_information3
    ,p_dei_information4             => p_dor_rec.dei_information4
    ,p_dei_information5             => p_dor_rec.dei_information5
    ,p_dei_information6             => p_dor_rec.dei_information6
    ,p_dei_information7             => p_dor_rec.dei_information7
    ,p_dei_information8             => p_dor_rec.dei_information8
    ,p_dei_information9             => p_dor_rec.dei_information9
    ,p_dei_information10            => p_dor_rec.dei_information10
    ,p_dei_information11            => p_dor_rec.dei_information11
    ,p_dei_information12            => p_dor_rec.dei_information12
    ,p_dei_information13            => p_dor_rec.dei_information13
    ,p_dei_information14            => p_dor_rec.dei_information14
    ,p_dei_information15            => p_dor_rec.dei_information15
    ,p_dei_information16            => p_dor_rec.dei_information16
    ,p_dei_information17            => p_dor_rec.dei_information17
    ,p_dei_information18            => p_dor_rec.dei_information18
    ,p_dei_information19            => p_dor_rec.dei_information19
    ,p_dei_information20            => p_dor_rec.dei_information20
    ,p_dei_information21            => p_dor_rec.dei_information21
    ,p_dei_information22            => p_dor_rec.dei_information22
    ,p_dei_information23            => p_dor_rec.dei_information23
    ,p_dei_information24            => p_dor_rec.dei_information24
    ,p_dei_information25            => p_dor_rec.dei_information25
    ,p_dei_information26            => p_dor_rec.dei_information26
    ,p_dei_information27            => p_dor_rec.dei_information27
    ,p_dei_information28            => p_dor_rec.dei_information28
    ,p_dei_information29            => p_dor_rec.dei_information29
    ,p_dei_information30            => p_dor_rec.dei_information30
    ,p_request_id                   => p_dor_rec.request_id
    ,p_program_application_id       => p_dor_rec.program_application_id
    ,p_program_id                   => p_dor_rec.program_id
    ,p_program_update_date          => p_dor_rec.program_update_date
    ,p_document_extra_info_id       => p_dor_rec.document_extra_info_id
    ,p_object_version_number        => p_dor_rec.object_version_number
    ,p_return_status                => p_return_status
    );

end if;



/*-----------Flipping the attachments primary key from transactionid
             to docextrainfoid-------------------------------------------*/

	save_attachments(
   p_transaction_id           => p_transaction_id
  ,p_document_extra_info_id   => p_dor_rec.document_extra_info_id
  ,p_flip_flag                => 'NTXN'
  ,p_return_status            => p_return_status);


if p_return_status = 'E' then
  hr_utility.raise_error;
else
  p_return_status := 'S';
end if;


EXCEPTION

    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in '||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,666);
      raise;

		 WHEN hr_utility.hr_error THEN
     hr_utility.get_message_details(msg_name,msg_appl);
     fnd_message.set_name(msg_appl,msg_name);
     p_return_status := hr_utility.get_message;

    WHEN OTHERS THEN
      hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,660);
      raise ;


END process_api;


--------------------------------------------------------------------------
--------------------------validate_dor------------------------------------
------This method validate the api of documents of records----------------
--------------------------------------------------------------------------



PROCEDURE validate_dor(
   p_validate                     in     number    default hr_api.g_true_num
  ,p_person_id                    in     number
  ,p_document_extra_info_id       in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_document_number              in     varchar2
  ,p_issued_by                    in     varchar2  default null
  ,p_issued_at                    in     varchar2  default null
  ,p_issued_date                  in     date      default null
  ,p_issuing_authority            in     varchar2  default null
  ,p_verified_by                  in     number    default null
  ,p_verified_date                in     date      default null
  ,p_related_object_name          in     varchar2  default null
  ,p_related_object_id_col        in     varchar2  default null
  ,p_related_object_id            in     number    default null
  ,p_dei_attribute_category       in     varchar2  default null
  ,p_dei_attribute1               in     varchar2  default null
  ,p_dei_attribute2               in     varchar2  default null
  ,p_dei_attribute3               in     varchar2  default null
  ,p_dei_attribute4               in     varchar2  default null
  ,p_dei_attribute5               in     varchar2  default null
  ,p_dei_attribute6               in     varchar2  default null
  ,p_dei_attribute7               in     varchar2  default null
  ,p_dei_attribute8               in     varchar2  default null
  ,p_dei_attribute9               in     varchar2  default null
  ,p_dei_attribute10              in     varchar2  default null
  ,p_dei_attribute11              in     varchar2  default null
  ,p_dei_attribute12              in     varchar2  default null
  ,p_dei_attribute13              in     varchar2  default null
  ,p_dei_attribute14              in     varchar2  default null
  ,p_dei_attribute15              in     varchar2  default null
  ,p_dei_attribute16              in     varchar2  default null
  ,p_dei_attribute17              in     varchar2  default null
  ,p_dei_attribute18              in     varchar2  default null
  ,p_dei_attribute19              in     varchar2  default null
  ,p_dei_attribute20              in     varchar2  default null
  ,p_dei_attribute21              in     varchar2  default null
  ,p_dei_attribute22              in     varchar2  default null
  ,p_dei_attribute23              in     varchar2  default null
  ,p_dei_attribute24              in     varchar2  default null
  ,p_dei_attribute25              in     varchar2  default null
  ,p_dei_attribute26              in     varchar2  default null
  ,p_dei_attribute27              in     varchar2  default null
  ,p_dei_attribute28              in     varchar2  default null
  ,p_dei_attribute29              in     varchar2  default null
  ,p_dei_attribute30              in     varchar2  default null
  ,p_dei_information_category     in     varchar2  default null
  ,p_dei_information1             in     varchar2  default null
  ,p_dei_information2             in     varchar2  default null
  ,p_dei_information3             in     varchar2  default null
  ,p_dei_information4             in     varchar2  default null
  ,p_dei_information5             in     varchar2  default null
  ,p_dei_information6             in     varchar2  default null
  ,p_dei_information7             in     varchar2  default null
  ,p_dei_information8             in     varchar2  default null
  ,p_dei_information9             in     varchar2  default null
  ,p_dei_information10            in     varchar2  default null
  ,p_dei_information11            in     varchar2  default null
  ,p_dei_information12            in     varchar2  default null
  ,p_dei_information13            in     varchar2  default null
  ,p_dei_information14            in     varchar2  default null
  ,p_dei_information15            in     varchar2  default null
  ,p_dei_information16            in     varchar2  default null
  ,p_dei_information17            in     varchar2  default null
  ,p_dei_information18            in     varchar2  default null
  ,p_dei_information19            in     varchar2  default null
  ,p_dei_information20            in     varchar2  default null
  ,p_dei_information21            in     varchar2  default null
  ,p_dei_information22            in     varchar2  default null
  ,p_dei_information23            in     varchar2  default null
  ,p_dei_information24            in     varchar2  default null
  ,p_dei_information25            in     varchar2  default null
  ,p_dei_information26            in     varchar2  default null
  ,p_dei_information27            in     varchar2  default null
  ,p_dei_information28            in     varchar2  default null
  ,p_dei_information29            in     varchar2  default null
  ,p_dei_information30            in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_action_mode                  in     varchar2  default null
  ,p_object_version_number        in out    nocopy number
  ,p_return_status                   out    nocopy varchar2
)
IS

l_proc                 varchar2(72) := g_package ||'validate_dor';
l_document_type        hr_document_types_v.document_type%type;
l_num                  number;
msg_name               varchar2(1000);
msg_appl               varchar2(10);
cursor csr_chk_duplicate_txn(p_document_type_id number,
                           p_person_id number,
                           p_date_from DATE,
                           p_date_to DATE) is
       select count(*)
       from hr_api_transaction_values hatv1,
            hr_api_transaction_values hatv2,
            hr_api_transaction_values hatv3,
            hr_api_transaction_steps hats,
            hr_api_transactions hat
       WHERE hat.selected_person_id = p_person_id
         and hatv1.number_value = p_document_type_id
         and hatv2.date_value = p_date_from
         and hatv3.date_value = p_date_to
         and hatv1.name = 'P_DOCUMENT_TYPE_ID'
         and hatv2.name = 'P_DATE_FROM'
         and hatv3.name = 'P_DATE_TO'
         and hatv1.transaction_step_id = hats.transaction_step_id
         and hatv2.transaction_step_id = hats.transaction_step_id
         and hatv3.transaction_step_id = hats.transaction_step_id
         and hats.transaction_id = hat.transaction_id
         and hat.transaction_ref_table = 'HR_DOCUMENT_EXTRA_INFO'
         and hat.status not in ('D','E','W');


BEGIN

 --hr_utility.trace_on(null,'ORCL1');
  hr_utility.set_location(' Entering:' || l_proc,50);


--- Validating the document information thru api------------------
if p_action_mode = 'DOR_INSERT' then
hr_document_extra_info_swi.create_doc_extra_info
    (p_validate                     => p_validate
    ,p_person_id                    => p_person_id
    ,p_document_type_id             => p_document_type_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_document_number              => p_document_number
    ,p_issued_by                    => p_issued_by
    ,p_issued_at                    => p_issued_at
    ,p_issued_date                  => p_issued_date
    ,p_issuing_authority            => p_issuing_authority
    ,p_verified_by                  => p_verified_by
    ,p_verified_date                => p_verified_date
    ,p_related_object_name          => p_related_object_name
    ,p_related_object_id_col        => p_related_object_id_col
    ,p_related_object_id            => p_related_object_id
    ,p_dei_attribute_category       => p_dei_attribute_category
    ,p_dei_attribute1               => p_dei_attribute1
    ,p_dei_attribute2               => p_dei_attribute2
    ,p_dei_attribute3               => p_dei_attribute3
    ,p_dei_attribute4               => p_dei_attribute4
    ,p_dei_attribute5               => p_dei_attribute5
    ,p_dei_attribute6               => p_dei_attribute6
    ,p_dei_attribute7               => p_dei_attribute7
    ,p_dei_attribute8               => p_dei_attribute8
    ,p_dei_attribute9               => p_dei_attribute9
    ,p_dei_attribute10              => p_dei_attribute10
    ,p_dei_attribute11              => p_dei_attribute11
    ,p_dei_attribute12              => p_dei_attribute12
    ,p_dei_attribute13              => p_dei_attribute13
    ,p_dei_attribute14              => p_dei_attribute14
    ,p_dei_attribute15              => p_dei_attribute15
    ,p_dei_attribute16              => p_dei_attribute16
    ,p_dei_attribute17              => p_dei_attribute17
    ,p_dei_attribute18              => p_dei_attribute18
    ,p_dei_attribute19              => p_dei_attribute19
    ,p_dei_attribute20              => p_dei_attribute20
    ,p_dei_attribute21              => p_dei_attribute21
    ,p_dei_attribute22              => p_dei_attribute22
    ,p_dei_attribute23              => p_dei_attribute23
    ,p_dei_attribute24              => p_dei_attribute24
    ,p_dei_attribute25              => p_dei_attribute25
    ,p_dei_attribute26              => p_dei_attribute26
    ,p_dei_attribute27              => p_dei_attribute27
    ,p_dei_attribute28              => p_dei_attribute28
    ,p_dei_attribute29              => p_dei_attribute29
    ,p_dei_attribute30              => p_dei_attribute30
    ,p_dei_information_category     => p_dei_information_category
    ,p_dei_information1             => p_dei_information1
    ,p_dei_information2             => p_dei_information2
    ,p_dei_information3             => p_dei_information3
    ,p_dei_information4             => p_dei_information4
    ,p_dei_information5             => p_dei_information5
    ,p_dei_information6             => p_dei_information6
    ,p_dei_information7             => p_dei_information7
    ,p_dei_information8             => p_dei_information8
    ,p_dei_information9             => p_dei_information9
    ,p_dei_information10            => p_dei_information10
    ,p_dei_information11            => p_dei_information11
    ,p_dei_information12            => p_dei_information12
    ,p_dei_information13            => p_dei_information13
    ,p_dei_information14            => p_dei_information14
    ,p_dei_information15            => p_dei_information15
    ,p_dei_information16            => p_dei_information16
    ,p_dei_information17            => p_dei_information17
    ,p_dei_information18            => p_dei_information18
    ,p_dei_information19            => p_dei_information19
    ,p_dei_information20            => p_dei_information20
    ,p_dei_information21            => p_dei_information21
    ,p_dei_information22            => p_dei_information22
    ,p_dei_information23            => p_dei_information23
    ,p_dei_information24            => p_dei_information24
    ,p_dei_information25            => p_dei_information25
    ,p_dei_information26            => p_dei_information26
    ,p_dei_information27            => p_dei_information27
    ,p_dei_information28            => p_dei_information28
    ,p_dei_information29            => p_dei_information29
    ,p_dei_information30            => p_dei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_document_extra_info_id       => p_document_extra_info_id
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => p_return_status
    );

elsif p_action_mode ='DOR_UPDATE' then

  hr_document_extra_info_swi.update_doc_extra_info
    (p_validate                     => p_validate
    ,p_person_id                    => p_person_id
    ,p_document_type_id             => p_document_type_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_document_number              => p_document_number
    ,p_issued_by                    => p_issued_by
    ,p_issued_at                    => p_issued_at
    ,p_issued_date                  => p_issued_date
    ,p_issuing_authority            => p_issuing_authority
    ,p_verified_by                  => p_verified_by
    ,p_verified_date                => p_verified_date
    ,p_related_object_name          => p_related_object_name
    ,p_related_object_id_col        => p_related_object_id_col
    ,p_related_object_id            => p_related_object_id
    ,p_dei_attribute_category       => p_dei_attribute_category
    ,p_dei_attribute1               => p_dei_attribute1
    ,p_dei_attribute2               => p_dei_attribute2
    ,p_dei_attribute3               => p_dei_attribute3
    ,p_dei_attribute4               => p_dei_attribute4
    ,p_dei_attribute5               => p_dei_attribute5
    ,p_dei_attribute6               => p_dei_attribute6
    ,p_dei_attribute7               => p_dei_attribute7
    ,p_dei_attribute8               => p_dei_attribute8
    ,p_dei_attribute9               => p_dei_attribute9
    ,p_dei_attribute10              => p_dei_attribute10
    ,p_dei_attribute11              => p_dei_attribute11
    ,p_dei_attribute12              => p_dei_attribute12
    ,p_dei_attribute13              => p_dei_attribute13
    ,p_dei_attribute14              => p_dei_attribute14
    ,p_dei_attribute15              => p_dei_attribute15
    ,p_dei_attribute16              => p_dei_attribute16
    ,p_dei_attribute17              => p_dei_attribute17
    ,p_dei_attribute18              => p_dei_attribute18
    ,p_dei_attribute19              => p_dei_attribute19
    ,p_dei_attribute20              => p_dei_attribute20
    ,p_dei_attribute21              => p_dei_attribute21
    ,p_dei_attribute22              => p_dei_attribute22
    ,p_dei_attribute23              => p_dei_attribute23
    ,p_dei_attribute24              => p_dei_attribute24
    ,p_dei_attribute25              => p_dei_attribute25
    ,p_dei_attribute26              => p_dei_attribute26
    ,p_dei_attribute27              => p_dei_attribute27
    ,p_dei_attribute28              => p_dei_attribute28
    ,p_dei_attribute29              => p_dei_attribute29
    ,p_dei_attribute30              => p_dei_attribute30
    ,p_dei_information_category     => p_dei_information_category
    ,p_dei_information1             => p_dei_information1
    ,p_dei_information2             => p_dei_information2
    ,p_dei_information3             => p_dei_information3
    ,p_dei_information4             => p_dei_information4
    ,p_dei_information5             => p_dei_information5
    ,p_dei_information6             => p_dei_information6
    ,p_dei_information7             => p_dei_information7
    ,p_dei_information8             => p_dei_information8
    ,p_dei_information9             => p_dei_information9
    ,p_dei_information10            => p_dei_information10
    ,p_dei_information11            => p_dei_information11
    ,p_dei_information12            => p_dei_information12
    ,p_dei_information13            => p_dei_information13
    ,p_dei_information14            => p_dei_information14
    ,p_dei_information15            => p_dei_information15
    ,p_dei_information16            => p_dei_information16
    ,p_dei_information17            => p_dei_information17
    ,p_dei_information18            => p_dei_information18
    ,p_dei_information19            => p_dei_information19
    ,p_dei_information20            => p_dei_information20
    ,p_dei_information21            => p_dei_information21
    ,p_dei_information22            => p_dei_information22
    ,p_dei_information23            => p_dei_information23
    ,p_dei_information24            => p_dei_information24
    ,p_dei_information25            => p_dei_information25
    ,p_dei_information26            => p_dei_information26
    ,p_dei_information27            => p_dei_information27
    ,p_dei_information28            => p_dei_information28
    ,p_dei_information29            => p_dei_information29
    ,p_dei_information30            => p_dei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_document_extra_info_id       => p_document_extra_info_id
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => p_return_status
    );

end if;


----Validating the document information in transaction table--------

  open csr_chk_duplicate_txn(
              p_document_type_id => p_document_type_id,
              p_person_id=> p_person_id ,
              p_date_from => p_date_from,
              p_date_to=> p_date_to);

  fetch csr_chk_duplicate_txn into l_num;
  if l_num > 0 then
    close csr_chk_duplicate_txn;

    select document_type into l_document_type
    from hr_document_types_v
    where document_type_id = p_document_type_id;

    hr_utility.set_message(800, 'HR_449708_DOR_UNQ_PER_DOC');
    hr_utility.set_message_token('TYPE', l_document_type);
    hr_utility.set_message_token('DATE_FROM', p_date_from);
    hr_utility.set_message_token('DATE_TO', p_date_to);
    p_return_status := hr_utility.hr_error_number||hr_utility.get_message;

  else
    close csr_chk_duplicate_txn;

  end if;

if p_return_status = 'E' then
  hr_utility.raise_error;
end if;


EXCEPTION

    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in  hr_dor_review_ss.validate_dor ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,555);
      p_return_status := SQLERRM;
      raise;

   WHEN hr_utility.hr_error THEN
     hr_utility.get_message_details(msg_name,msg_appl);
     fnd_message.set_name(msg_appl,msg_name);
     p_return_status := hr_utility.get_message;
     hr_utility.set_location(p_return_status,566);

    WHEN OTHERS THEN
      hr_utility.trace('When others exception in  hr_dor_review_ss.validate_dor ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,560);
      p_return_status := SQLERRM;
      raise;





END validate_dor ;

--------------------------------------------------------------------------
--------------------------get_review_data_from_tt-------------------------
------This method retrieve the documents of records data from the --------
------transaction table---------------------------------------------------
--------------------------------------------------------------------------


PROCEDURE get_review_data_from_tt(
          p_transaction_step_id in number
         ,p_dor_rec out nocopy HR_DOCUMENT_EXTRA_INFO%rowtype)
IS

l_proc    varchar2(72) := g_package ||'get_review_data_from_tt';

BEGIN

 hr_utility.set_location(' Entering:' || l_proc,60);

			p_dor_rec.person_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_PERSON_ID');

			p_dor_rec.document_type_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DOCUMENT_TYPE_ID');

			p_dor_rec.date_from :=
			hr_transaction_api.get_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DATE_FROM');

			p_dor_rec.date_to :=
			hr_transaction_api.get_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DATE_TO');

			p_dor_rec.document_number :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DOCUMENT_NUMBER');

			p_dor_rec.issued_by :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ISSUED_BY');

			p_dor_rec.issued_at :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ISSUED_AT');

			p_dor_rec.issued_date :=
			hr_transaction_api.get_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ISSUED_DATE');

			p_dor_rec.issuing_authority :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_ISSUING_AUTHORITY');

			p_dor_rec.verified_by :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_VERIFIED_BY');

			p_dor_rec.verified_date :=
			hr_transaction_api.get_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_VERIFIED_DATE');

			p_dor_rec.related_object_name :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_RELATED_OBJECT_NAME');

			p_dor_rec.related_object_id_col :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_RELATED_OBJECT_ID_COL');

			p_dor_rec.related_object_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_RELATED_OBJECT_ID');

			p_dor_rec.dei_attribute_category :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE_CATEGORY');

			p_dor_rec.dei_attribute1 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE1');

			p_dor_rec.dei_attribute2 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE2');

			p_dor_rec.dei_attribute3 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE3');

			p_dor_rec.dei_attribute4 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE4');

			p_dor_rec.dei_attribute4 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE5');

			p_dor_rec.dei_attribute6 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE6');

			p_dor_rec.dei_attribute7 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE7');

			p_dor_rec.dei_attribute8 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE8');

			p_dor_rec.dei_attribute9 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE9');

			p_dor_rec.dei_attribute10 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE10');

			p_dor_rec.dei_attribute11 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE11');

			p_dor_rec.dei_attribute12 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE12');

			p_dor_rec.dei_attribute13 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE13');

			p_dor_rec.dei_attribute14 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE14');

			p_dor_rec.dei_attribute15 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE15');

			p_dor_rec.dei_attribute16 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE16');

			p_dor_rec.dei_attribute17 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE17');

			p_dor_rec.dei_attribute18 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE18');

			p_dor_rec.dei_attribute19 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE19');

			p_dor_rec.dei_attribute20 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE20');

			p_dor_rec.dei_attribute21 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE21');

			p_dor_rec.dei_attribute22 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE22');

			p_dor_rec.dei_attribute23 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE23');

			p_dor_rec.dei_attribute24 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE24');

			p_dor_rec.dei_attribute25 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE25');

			p_dor_rec.dei_attribute26 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE26');

			p_dor_rec.dei_attribute27 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE27');

			p_dor_rec.dei_attribute28 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE28');

			p_dor_rec.dei_attribute29 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE29');

			p_dor_rec.dei_attribute30 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_ATTRIBUTE30');

			p_dor_rec.dei_information_category :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION_CATEGORY');

			p_dor_rec.dei_information1 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION1');

			p_dor_rec.dei_information2 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION2');

			p_dor_rec.dei_information3 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION3');

			p_dor_rec.dei_information4 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION4');

			p_dor_rec.dei_information5 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION5');

			p_dor_rec.dei_information6 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION6');

			p_dor_rec.dei_information7 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION7');

			p_dor_rec.dei_information8 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION8');

			p_dor_rec.dei_information9 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION9');

			p_dor_rec.dei_information10 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION10');

			p_dor_rec.dei_information11 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION11');

			p_dor_rec.dei_information12 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION12');

			p_dor_rec.dei_information13 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION13');

			p_dor_rec.dei_information14 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION14');

			p_dor_rec.dei_information15 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION15');

			p_dor_rec.dei_information16 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION16');

			p_dor_rec.dei_information17 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION17');

			p_dor_rec.dei_information18 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION18');

			p_dor_rec.dei_information19 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION19');

			p_dor_rec.dei_information20 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION20');

			p_dor_rec.dei_information21 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION21');

			p_dor_rec.dei_information22 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION22');

			p_dor_rec.dei_information23 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION23');

			p_dor_rec.dei_information24 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION24');

			p_dor_rec.dei_information25 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION25');

			p_dor_rec.dei_information26 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION26');

			p_dor_rec.dei_information27 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION27');

			p_dor_rec.dei_information28 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION28');

			p_dor_rec.dei_information29 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION29');

			p_dor_rec.dei_information30 :=
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DEI_INFORMATION30');

			p_dor_rec.request_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_REQUEST_ID');

			p_dor_rec.program_application_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_PROGRAM_APPLICATION_ID');

			p_dor_rec.program_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_PROGRAM_ID');

			p_dor_rec.program_update_date :=
			hr_transaction_api.get_date_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_PROGRAM_UPDATE_DATE');

			p_dor_rec.document_extra_info_id :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_DOCUMENT_EXTRA_INFO_ID');

			p_dor_rec.object_version_number :=
			hr_transaction_api.get_number_value
			(p_transaction_step_id  => p_transaction_step_id
			,p_name                 => 'P_OBJECT_VERSION_NUMBER');

EXCEPTION

    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in '||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,666);
      raise;

    WHEN OTHERS THEN
      hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,660);
      raise ;


END get_review_data_from_tt;


--------------------------------------------------------------------------
--------------------------get_transaction_values--------------------------
------This method retrieve the documents of records data from the --------
------transaction table and return back the values.-----------------------
--------------------------------------------------------------------------

PROCEDURE get_transaction_values(
   p_transaction_step_id          in              varchar2
  ,p_person_id                    out  nocopy     varchar2
  ,p_document_extra_info_id       out  nocopy     varchar2
  ,p_document_type_id             out  nocopy     varchar2
  ,p_date_from                    out  nocopy     varchar2
  ,p_date_to                      out  nocopy     varchar2
  ,p_document_number              out  nocopy     varchar2
  ,p_issued_by                    out  nocopy     varchar2
  ,p_issued_at                    out  nocopy     varchar2
  ,p_issued_date                  out  nocopy     varchar2
  ,p_issuing_authority            out  nocopy     varchar2
  ,p_verified_by                  out  nocopy     varchar2
  ,p_verified_date                out  nocopy     varchar2
  ,p_related_object_name          out  nocopy     varchar2
  ,p_related_object_id_col        out  nocopy     varchar2
  ,p_related_object_id            out  nocopy     varchar2
  ,p_dei_attribute_category       out  nocopy     varchar2
  ,p_dei_attribute1               out  nocopy     varchar2
  ,p_dei_attribute2               out  nocopy     varchar2
  ,p_dei_attribute3               out  nocopy     varchar2
  ,p_dei_attribute4               out  nocopy     varchar2
  ,p_dei_attribute5               out  nocopy     varchar2
  ,p_dei_attribute6               out  nocopy     varchar2
  ,p_dei_attribute7               out  nocopy     varchar2
  ,p_dei_attribute8               out  nocopy     varchar2
  ,p_dei_attribute9               out  nocopy     varchar2
  ,p_dei_attribute10              out  nocopy     varchar2
  ,p_dei_attribute11              out  nocopy     varchar2
  ,p_dei_attribute12              out  nocopy     varchar2
  ,p_dei_attribute13              out  nocopy     varchar2
  ,p_dei_attribute14              out  nocopy     varchar2
  ,p_dei_attribute15              out  nocopy     varchar2
  ,p_dei_attribute16              out  nocopy     varchar2
  ,p_dei_attribute17              out  nocopy     varchar2
  ,p_dei_attribute18              out  nocopy     varchar2
  ,p_dei_attribute19              out  nocopy     varchar2
  ,p_dei_attribute20              out  nocopy     varchar2
  ,p_dei_attribute21              out  nocopy     varchar2
  ,p_dei_attribute22              out  nocopy     varchar2
  ,p_dei_attribute23              out  nocopy     varchar2
  ,p_dei_attribute24              out  nocopy     varchar2
  ,p_dei_attribute25              out  nocopy     varchar2
  ,p_dei_attribute26              out  nocopy     varchar2
  ,p_dei_attribute27              out  nocopy     varchar2
  ,p_dei_attribute28              out  nocopy     varchar2
  ,p_dei_attribute29              out  nocopy     varchar2
  ,p_dei_attribute30              out  nocopy     varchar2
  ,p_dei_information_category     out  nocopy     varchar2
  ,p_dei_information1             out  nocopy     varchar2
  ,p_dei_information2             out  nocopy     varchar2
  ,p_dei_information3             out  nocopy     varchar2
  ,p_dei_information4             out  nocopy     varchar2
  ,p_dei_information5             out  nocopy     varchar2
  ,p_dei_information6             out  nocopy     varchar2
  ,p_dei_information7             out  nocopy     varchar2
  ,p_dei_information8             out  nocopy     varchar2
  ,p_dei_information9             out  nocopy     varchar2
  ,p_dei_information10            out  nocopy     varchar2
  ,p_dei_information11            out  nocopy     varchar2
  ,p_dei_information12            out  nocopy     varchar2
  ,p_dei_information13            out  nocopy     varchar2
  ,p_dei_information14            out  nocopy     varchar2
  ,p_dei_information15            out  nocopy     varchar2
  ,p_dei_information16            out  nocopy     varchar2
  ,p_dei_information17            out  nocopy     varchar2
  ,p_dei_information18            out  nocopy     varchar2
  ,p_dei_information19            out  nocopy     varchar2
  ,p_dei_information20            out  nocopy     varchar2
  ,p_dei_information21            out  nocopy     varchar2
  ,p_dei_information22            out  nocopy     varchar2
  ,p_dei_information23            out  nocopy     varchar2
  ,p_dei_information24            out  nocopy     varchar2
  ,p_dei_information25            out  nocopy     varchar2
  ,p_dei_information26            out  nocopy     varchar2
  ,p_dei_information27            out  nocopy     varchar2
  ,p_dei_information28            out  nocopy     varchar2
  ,p_dei_information29            out  nocopy     varchar2
  ,p_dei_information30            out  nocopy     varchar2
  ,p_request_id                   out  nocopy     varchar2
  ,p_program_application_id       out  nocopy     varchar2
  ,p_program_id                   out  nocopy     varchar2
  ,p_program_update_date          out  nocopy     varchar2
  ,p_object_version_number        out  nocopy     varchar2
  ,p_return_status                out  nocopy     varchar2
  ,p_document_type                out  nocopy     varchar2
  ,p_category_name                out  nocopy     varchar2
  ,p_sub_category_name            out  nocopy     varchar2
  ,p_country_name                 out  nocopy     varchar2
  ,p_system_doc_type              out  nocopy     varchar2
  ) IS

l_proc                    varchar2(72) := g_package ||'.get_transaction_values';
p_dor_rec                 hr_document_extra_info%rowtype;
l_country_name            varchar2(150);
l_document_type           varchar2(150);
l_category_name           varchar2(150);
l_sub_category_name       varchar2(150);
l_system_doc_type         varchar2(150);
l_legislation_code        varchar2(10);
p_transaction_id          number;
msg_name                  varchar2(1000);
msg_appl                  varchar2(10);

BEGIN

--hr_utility.trace_on(null,'ORCL1');
 hr_utility.set_location(' Entering:' || l_proc,70);


--Retrieving the data---------

	hr_dor_review_ss.get_review_data_from_tt(
			p_transaction_step_id => p_transaction_step_id,
			p_dor_rec => p_dor_rec);


---Assigning values to all parameters

    p_person_id                    := TO_CHAR(p_dor_rec.person_id);
    p_document_extra_info_id       := TO_CHAR(p_dor_rec.document_extra_info_id);
    p_document_type_id             := TO_CHAR(p_dor_rec.document_type_id);
    p_date_from                    := TO_CHAR(p_dor_rec.date_from,'dd-mm-rrrr');
    p_date_to                      := TO_CHAR(p_dor_rec.date_to,'dd-mm-rrrr');
    p_document_number              := p_dor_rec.document_number;
    p_issued_by                    := p_dor_rec.issued_by;
    p_issued_at                    := p_dor_rec.issued_at;
    p_issued_date                  := TO_CHAR(p_dor_rec.issued_date,'dd-mm-rrrr');
    p_issuing_authority            := p_dor_rec.issuing_authority;
    p_verified_by                  := TO_CHAR(p_dor_rec.verified_by);
    p_verified_date                := TO_CHAR(p_dor_rec.verified_date,'dd-mm-rrrr');
    p_related_object_name          := p_dor_rec.related_object_name;
    p_related_object_id_col        := p_dor_rec.related_object_id_col;
    p_related_object_id            := TO_CHAR(p_dor_rec.related_object_id);
    p_dei_attribute_category       := p_dor_rec.dei_attribute_category;
    p_dei_attribute1               := p_dor_rec.dei_attribute1;
    p_dei_attribute2               := p_dor_rec.dei_attribute2;
    p_dei_attribute3               := p_dor_rec.dei_attribute3;
    p_dei_attribute4               := p_dor_rec.dei_attribute4;
    p_dei_attribute5               := p_dor_rec.dei_attribute5;
    p_dei_attribute6               := p_dor_rec.dei_attribute6;
    p_dei_attribute7               := p_dor_rec.dei_attribute7;
    p_dei_attribute8               := p_dor_rec.dei_attribute8;
    p_dei_attribute9               := p_dor_rec.dei_attribute9;
    p_dei_attribute10              := p_dor_rec.dei_attribute10;
    p_dei_attribute11              := p_dor_rec.dei_attribute11;
    p_dei_attribute12              := p_dor_rec.dei_attribute12;
    p_dei_attribute13              := p_dor_rec.dei_attribute13;
    p_dei_attribute14              := p_dor_rec.dei_attribute14;
    p_dei_attribute15              := p_dor_rec.dei_attribute15;
    p_dei_attribute16              := p_dor_rec.dei_attribute16;
    p_dei_attribute17              := p_dor_rec.dei_attribute17;
    p_dei_attribute18              := p_dor_rec.dei_attribute18;
    p_dei_attribute19              := p_dor_rec.dei_attribute19;
    p_dei_attribute20              := p_dor_rec.dei_attribute20;
    p_dei_attribute21              := p_dor_rec.dei_attribute21;
    p_dei_attribute22              := p_dor_rec.dei_attribute22;
    p_dei_attribute23              := p_dor_rec.dei_attribute23;
    p_dei_attribute24              := p_dor_rec.dei_attribute24;
    p_dei_attribute25              := p_dor_rec.dei_attribute25;
    p_dei_attribute26              := p_dor_rec.dei_attribute26;
    p_dei_attribute27              := p_dor_rec.dei_attribute27;
    p_dei_attribute28              := p_dor_rec.dei_attribute28;
    p_dei_attribute29              := p_dor_rec.dei_attribute29;
    p_dei_attribute30              := p_dor_rec.dei_attribute30;
    p_dei_information_category     := p_dor_rec.dei_information_category;
    p_dei_information1             := p_dor_rec.dei_information1;
    p_dei_information2             := p_dor_rec.dei_information2;
    p_dei_information3             := p_dor_rec.dei_information3;
    p_dei_information4             := p_dor_rec.dei_information4;
    p_dei_information5             := p_dor_rec.dei_information5;
    p_dei_information6             := p_dor_rec.dei_information6;
    p_dei_information7             := p_dor_rec.dei_information7;
    p_dei_information8             := p_dor_rec.dei_information8;
    p_dei_information9             := p_dor_rec.dei_information9;
    p_dei_information10            := p_dor_rec.dei_information10;
    p_dei_information11            := p_dor_rec.dei_information11;
    p_dei_information12            := p_dor_rec.dei_information12;
    p_dei_information13            := p_dor_rec.dei_information13;
    p_dei_information14            := p_dor_rec.dei_information14;
    p_dei_information15            := p_dor_rec.dei_information15;
    p_dei_information16            := p_dor_rec.dei_information16;
    p_dei_information17            := p_dor_rec.dei_information17;
    p_dei_information18            := p_dor_rec.dei_information18;
    p_dei_information19            := p_dor_rec.dei_information19;
    p_dei_information20            := p_dor_rec.dei_information20;
    p_dei_information21            := p_dor_rec.dei_information21;
    p_dei_information22            := p_dor_rec.dei_information22;
    p_dei_information23            := p_dor_rec.dei_information23;
    p_dei_information24            := p_dor_rec.dei_information24;
    p_dei_information25            := p_dor_rec.dei_information25;
    p_dei_information26            := p_dor_rec.dei_information26;
    p_dei_information27            := p_dor_rec.dei_information27;
    p_dei_information28            := p_dor_rec.dei_information28;
    p_dei_information29            := p_dor_rec.dei_information29;
    p_dei_information30            := p_dor_rec.dei_information30;
    p_request_id                   := TO_CHAR(p_dor_rec.request_id);
    p_program_application_id       := TO_CHAR(p_dor_rec.program_application_id);
    p_program_id                   := TO_CHAR(p_dor_rec.program_id);
    p_program_update_date          := TO_CHAR(p_dor_rec.program_update_date,'dd-mm-rrrr');
    p_object_version_number        := TO_CHAR(p_dor_rec.object_version_number);



SELECT DOCUMENT_TYPE
      ,CATEGORY_NAME
      ,SUB_CATEGORY_NAME
      ,LEGISLATION_CODE
      ,SYSTEM_DOCUMENT_TYPE
INTO   l_document_type
      ,l_category_name
      ,l_sub_category_name
      ,l_legislation_code
      ,l_system_doc_type
FROM HR_DOCUMENT_TYPES_V
WHERE DOCUMENT_TYPE_ID=p_dor_rec.document_type_id;

if l_legislation_code is not null then
	SELECT TERRITORY_SHORT_NAME
	INTO l_country_name
	FROM FND_TERRITORIES_VL
	WHERE TERRITORY_CODE = l_legislation_code;
else
 l_country_name := null;
end if;

hr_utility.set_location(' Entering:' || l_proc,72);

    p_document_type := l_document_type;
    p_category_name := l_category_name;
    p_sub_category_name := l_sub_category_name;
    p_country_name := l_country_name;
    p_system_doc_type := l_system_doc_type;

/*-----------Flipping the attachments primary key from docextrainfoid
           to transactionid------------------------------------------ */

  p_transaction_id := get_transaction_id(p_transaction_step_id);
	save_attachments(
   p_transaction_id           => p_transaction_id
  ,p_document_extra_info_id   => p_dor_rec.document_extra_info_id
  ,p_flip_flag                => 'TXN'
  ,p_return_status            => p_return_status);


  commit;

if p_return_status = 'E' then
  hr_utility.raise_error;
else
  p_return_status := 'S';
end if;


EXCEPTION

    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in '||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,777);
      p_return_status := SQLERRM;

    WHEN hr_utility.hr_error THEN
     	hr_utility.get_message_details(msg_name,msg_appl);
     	fnd_message.set_name(msg_appl,msg_name);
     	p_return_status := hr_utility.get_message;

		WHEN OTHERS THEN
      hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,770);
      p_return_status := SQLERRM;

END get_transaction_values;


/*=============================================================================

This procedure will flip the attachemnets' primary key from
transaction id to doc_extra_info_id and vice versa.
The flip flag denotes the flag to change the primary key.

If "TXN" then the priamry key will be change to transaction id.
If "NTXN" then the priamry key will be change to doc_extra_info_id

=============================================================================*/

PROCEDURE save_attachments(
   p_transaction_id              in               number
  ,p_document_extra_info_id      in               number
  ,p_flip_flag                   in               varchar2
  ,p_return_status               out nocopy       varchar2)
IS
p_entity_name          varchar2(100);
l_proc varchar2(50) := 'save_attachments';
msg_name               varchar2(1000);
msg_appl               varchar2(10);

Cursor get_attached_docs(p_value in number) is
  select rowid
  from   fnd_attached_documents
  where  entity_name = 'R_DOCUMENT_EXTRA_INFO'
  and   pk1_value = p_value;


BEGIN

hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 1);

p_entity_name := 'R_DOCUMENT_EXTRA_INFO' ;


if p_flip_flag = 'TXN' then

	for crec in get_attached_docs(p_document_extra_info_id) Loop
     update_attachment
          (p_entity_name=> p_entity_name
          ,p_pk1_value=> p_transaction_id
          ,p_rowid=> crec.rowid);
  end loop;

elsif p_flip_flag = 'NTXN' then

	for crec in get_attached_docs(p_transaction_id) Loop
    update_attachment
          (p_entity_name=> p_entity_name
          ,p_pk1_value=> p_document_extra_info_id
          ,p_rowid=> crec.rowid);
  end loop;

end if;
commit;
if p_return_status = 'E' then
  hr_utility.raise_error;
else
  p_return_status := 'S';
end if;

hr_utility.set_location('Leaving:'|| g_package||'.'||l_proc, 2);

EXCEPTION

  WHEN hr_utility.hr_error THEN
     hr_utility.get_message_details(msg_name,msg_appl);
     fnd_message.set_name(msg_appl,msg_name);
     p_return_status := hr_utility.get_message;
 when others then
		 hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
     hr_utility.set_location(' Leaving:' || l_proc,770);
     p_return_status := SQLERRM;


END save_attachments;


/*===========================================================================
This procedure calls the fnd api to update the attachments
===========================================================================*/


procedure update_attachment
          (p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2 ) is



  l_proc    varchar2(72) := g_package ||'update_attachment';
  l_rowid                  varchar2(50);
  l_language               varchar2(30) ;
  data_error               exception;
  msg_name                 varchar2(1000);
  msg_appl                 varchar2(10);
  cursor csr_get_attached_doc  is
    select *
    from   fnd_attached_documents
    where  rowid = p_rowid;
  cursor csr_get_doc(csr_p_document_id in number)  is
    select *
    from   fnd_documents
    where  document_id = csr_p_document_id;
  cursor csr_get_doc_tl  (csr_p_lang in varchar2
                         ,csr_p_document_id in number) is
    select *
    from   fnd_documents_tl
    where  document_id = csr_p_document_id
    and    language = csr_p_lang;
  l_attached_doc_pre_upd   csr_get_attached_doc%rowtype;
  l_doc_pre_upd            csr_get_doc%rowtype;
  l_doc_tl_pre_upd         csr_get_doc_tl%rowtype;
  Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    select userenv('LANG') into l_language from dual;
     Open csr_get_attached_doc;
     fetch csr_get_attached_doc into l_attached_doc_pre_upd;
     IF csr_get_attached_doc%NOTFOUND THEN
        close csr_get_attached_doc;
        raise data_error;
     END IF;

     Open csr_get_doc(l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc into l_doc_pre_upd;
     IF csr_get_doc%NOTFOUND then
        close csr_get_doc;
        raise data_error;
     END IF;

     Open csr_get_doc_tl (csr_p_lang => l_language
                      ,csr_p_document_id => l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc_tl into l_doc_tl_pre_upd;
     IF csr_get_doc_tl%NOTFOUND then
        close csr_get_doc_tl;
        raise data_error;
     END IF;

     hr_utility.set_location(' before  fnd_attached_documents_pkg.lock_row :' || l_proc,20);
     fnd_attached_documents_pkg.lock_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                      l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => l_attached_doc_pre_upd.entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => l_attached_doc_pre_upd.pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                    l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                    l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => l_doc_pre_upd.start_date_active
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_doc_tl_pre_upd.language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                          l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );


        hr_utility.set_location(' before fnd_attached_documents_pkg.update_row :' || l_proc,30);


            fnd_attached_documents_pkg.update_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                        l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => l_attached_doc_pre_upd.last_updated_by
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                      l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                      l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15

            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
           ,x_start_date_active          => trunc(sysdate)
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                      l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );

  hr_utility.set_location(' after fnd_attached_documents_pkg.update_row :' || l_proc,40);
  hr_utility.set_location(' Leaving:' || l_proc,50);

  EXCEPTION
    when others then
      hr_utility.set_location(' Error in :' || l_proc,60);
         raise;
  End update_attachment;
/*==========================================================================
This procedure will abort the workflow process and update the
transaction status to E.
============================================================================*/
procedure delete_transaction(p_transaction_id in number)
IS
p_item_type  WF_ITEMS.ITEM_TYPE%TYPE;
p_item_key   WF_ITEMS.ITEM_KEY%TYPE;
l_proc varchar2(50) := 'delete_transaction';

BEGIN

hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 1);

select item_type,item_key into
p_item_type,p_item_key
from hr_api_transactions
where transaction_id = p_transaction_id;

wf_engine.abortprocess(itemtype => p_item_type
                      ,itemkey  => p_item_key);

hr_transaction_api.rollback_transaction
                   (p_transaction_id => p_transaction_id);

hr_utility.set_location('Leaving:'|| g_package||'.'||l_proc, 2);

EXCEPTION
	when others then
   hr_utility.trace('When others exception in  ' ||l_proc||','|| SQLERRM );
   hr_utility.set_location(' Leaving:' || l_proc,770);
   raise;

END delete_transaction;



function isUpdateAllowed(p_transaction_id         in number   default null,
                         p_transaction_status     in varchar2 default null,
                         p_document_extra_info_id in number   default null)
return varchar2

IS
c_proc  constant varchar2(30) := 'isUpdateAllowed';
dor_UpdateAllowed varchar2(30);
p_count      number := 0;
begin

    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);

if p_document_extra_info_id is null then
    -- for now this will only allow for transaction owner to update

  if(p_transaction_id is not null) then
    if(istxnowner(p_transaction_id,fnd_global.employee_id)
       and p_transaction_status in ('W','S','RI','RIS')) then
      dor_UpdateAllowed := 'HrUpdateEnabled';
    else
      dor_UpdateAllowed := 'HrUpdateDisabled';
    end if;
 end if;
elsif p_transaction_id is null then
 select count(*) into p_count
 from hr_api_transactions
 where transaction_id = (
    select transaction_id from hr_api_transaction_steps
    where transaction_step_id = (
      select transaction_step_id from hr_api_transaction_values
      where NAME = 'P_DOCUMENT_EXTRA_INFO_ID'
      and NUMBER_VALUE = p_document_extra_info_id )) ;

  if p_count > 0 then
    dor_UpdateAllowed := 'HrUpdateDisabled';
  else
    dor_UpdateAllowed := 'HrUpdateEnabled';
  end if;
end if;

  return dor_UpdateAllowed;

    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);


exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end isUpdateAllowed;


function isDeleteAllowed(p_transaction_id in number,
                         p_transaction_status in varchar2) return varchar2

IS
c_proc  constant varchar2(30) := 'isDeleteAllowed';
dor_DeleteAllowed varchar2(30);
pvalue varchar2(30);

begin

    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);


    -- for now this will only allow for transaction owner to update

  if(p_transaction_id is not null) then
    if(istxnowner(p_transaction_id,fnd_global.employee_id)
       and p_transaction_status in ('W','S','RI','RIS')) then
      dor_DeleteAllowed := 'HrDeleteEnabled';
    else
			pvalue := fnd_profile.value('HR_APRVL_TXN_INITIATOR_DEL_ENABLED');
      if pvalue = 'Y' then
				dor_DeleteAllowed := 'HrDeleteEnabled';
			else
      	dor_DeleteAllowed := 'HrDeleteDisabled';
      end if;
    end if;
  end if;

  return dor_DeleteAllowed;

    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);


exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;

end isDeleteAllowed;


function isAttachAllowed(p_transaction_id in number,
                         p_transaction_status in varchar2) return varchar2

IS
c_proc  constant varchar2(30) := 'isAttachAllowed';
dor_AttachAllowed varchar2(30);
begin

    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);


    -- for now this will only allow for transaction owner to update

     if(p_transaction_id is not null) then
    if(istxnowner(p_transaction_id,fnd_global.employee_id)
       and p_transaction_status in ('W','S','RI','RIS')) then
      dor_AttachAllowed := 'HrDocsEnabled';
    else
      dor_AttachAllowed := 'HrDocsDisabled';
    end if;
  end if;

  return dor_AttachAllowed;

    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);


exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;

end isAttachAllowed;

function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean
is
-- local variables
x_returnStatus boolean;
ln_hr_api_transaction_rec hr_api_transactions%rowtype;
ln_person_id number;

begin

 -- set the default value
 x_returnStatus := false;
 ln_person_id := p_person_id;

  if(p_transaction_id is not null) then
    -- ignore passed personid
    -- derive from the transaction details
     select hr_api_transactions.creator_person_id
     into ln_person_id
     from hr_api_transactions
     where transaction_id=p_transaction_id;
  end if;

  --
     if(ln_person_id= fnd_global.employee_id) then
       x_returnStatus := true;
     else
       x_returnStatus :=false;
     end if;
  return x_returnStatus;
exception
when others then
  raise;
end isTxnOwner;

function getActionMode(p_transaction_id in number)
return varchar2
is

p_api_addtnl_info hr_api_transactions.api_addtnl_info%type;

begin

SELECT api_addtnl_info
INTO p_api_addtnl_info
FROM hr_api_transactions
WHERE transaction_id = p_transaction_id;

return p_api_addtnl_info;

EXCEPTION
 WHEN no_data_found THEN
     raise;

 WHEN others THEN
    raise;
end getActionMode;


-- ----------------------------------------------------------------------------
-- |------------------------< get_transaction_id >----------------------------|
-- ----------------------------------------------------------------------------
function get_transaction_id
  (p_transaction_step_id in number) return number is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_transaction_id';
  l_transaction_id    hr_api_transactions.transaction_id%type;
  -- cursor to select the transaction_id of the step
  cursor csr_hats is
    select hats.transaction_id
    from   hr_api_transaction_steps  hats
    where  hats.transaction_step_id = p_transaction_step_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 5);

  open csr_hats;
  hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
  fetch csr_hats into l_transaction_id;
  if csr_hats%notfound then
    -- the transaction step doesn't exist
    close csr_hats;
    hr_utility.set_message(801, 'HR_51751_WEB_TRA_STEP_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_hats;
   hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_transaction_id);

  hr_utility.set_location(' Leaving:'||l_proc, 20);

end get_transaction_id;

END HR_DOR_REVIEW_SS;


/
