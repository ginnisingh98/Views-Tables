--------------------------------------------------------
--  DDL for Package Body GHR_PDI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_API" AS
/* $Header: ghpdiapi.pkb 120.1 2006/01/17 06:20:19 sumarimu noship $ */


--Global Variables
g_package varchar2(200) := 'ghr_pdi_api';
PROCEDURE CREATE_PDI(
	p_validate IN BOOLEAN default false,
	p_position_description_id OUT NOCOPY number,
	p_date_from IN date,
	p_routing_grp_id	   IN   number default null,
	p_date_to IN date default null,
	p_opm_cert_num IN ghr_position_descriptions.opm_cert_num%TYPE default null,
	p_flsa	IN	ghr_position_descriptions.flsa%TYPE default null,
	p_financial_statement IN ghr_position_descriptions.financial_statement%TYPE default null,
	p_subject_to_ia_action	IN  ghr_position_descriptions.subject_to_ia_action%TYPE default null,
	p_position_status IN ghr_position_descriptions.position_status%TYPE default null,
	p_position_is	IN ghr_position_descriptions.position_is%TYPE default null,
	p_position_sensitivity IN ghr_position_descriptions.position_sensitivity%TYPE default null,
	p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE default null,
	p_pd_remarks	IN  ghr_position_descriptions.pd_remarks%TYPE default null,
	p_position_class_std IN ghr_position_descriptions.position_class_std%TYPE default null,
	p_category	IN ghr_position_descriptions.category%TYPE default null,
	p_career_ladder	IN ghr_position_descriptions.career_ladder%TYPE default null,
        p_supervisor_name         in varchar2       default hr_api.g_varchar2,
        p_supervisor_title        in varchar2       default hr_api.g_varchar2,
        p_supervisor_date         in date           default hr_api.g_date,
        p_manager_name		  in varchar2       default hr_api.g_varchar2,
        p_manager_title 	  in varchar2       default hr_api.g_varchar2,
        p_manager_date            in date           default hr_api.g_date,
        p_classifier_name	  in varchar2       default hr_api.g_varchar2,
        p_classifier_title 	  in varchar2       default hr_api.g_varchar2,
        p_classifier_date         in date           default hr_api.g_date,
	p_attribute_category              in      varchar2  default null,
	p_attribute1                      in      varchar2  default null,
 	p_attribute2                      in      varchar2  default null,
	p_attribute3                      in      varchar2  default null,
 	p_attribute4                      in      varchar2  default null,
 	p_attribute5                      in      varchar2  default null,
 	p_attribute6                      in      varchar2  default null,
 	p_attribute7                      in      varchar2  default null,
 	p_attribute8                      in      varchar2  default null,
 	p_attribute9                      in      varchar2  default null,
 	p_attribute10                     in      varchar2  default null,
 	p_attribute11                     in      varchar2  default null,
 	p_attribute12                     in      varchar2  default null,
 	p_attribute13                     in      varchar2  default null,
 	p_attribute14                     in      varchar2  default null,
 	p_attribute15                     in      varchar2  default null,
 	p_attribute16                     in      varchar2  default null,
 	p_attribute17                     in      varchar2  default null,
 	p_attribute18                     in      varchar2  default null,
 	p_attribute19                     in      varchar2  default null,
 	p_attribute20                     in      varchar2  default null,
        p_business_group_id               in      number    default null,
        p_1_approved_flag		  in      varchar2  default null,
        p_1_user_name_acted_on	          in      varchar2  default null,
        p_1_action_taken                  in      varchar2  default null,
        p_2_user_name_routed_to           in      varchar2  default null,
        p_2_groupbox_id                   in      number    default null,
        p_2_routing_list_id               in      number    default null,
        p_2_routing_seq_number            in      number    default null,
        p_1_pd_routing_history_id         out nocopy     number,
        p_1_pdh_object_version_number     out nocopy     number,
        p_2_pdh_object_version_number     out nocopy     number,
        p_2_pd_routing_history_id         out nocopy     number,
	p_pdi_object_version_number out nocopy number)
IS
  l_proc varchar2(72) := g_package||'create_pdi';
  l_position_description_id   ghr_position_descriptions.position_description_id%TYPE;
  l_pdi_object_version_number number := 1;
/* Added by Dinkar. Karumuri to support workflow and routing of Position description*/
  l_initiator_flag              ghr_pd_routing_history.initiator_flag%TYPE;
  l_reviewer_flag               ghr_pd_routing_history.reviewer_flag%TYPE;
  l_requester_flag              ghr_pd_routing_history.requester_flag%TYPE;
  l_authorizer_flag             ghr_pd_routing_history.authorizer_flag%TYPE;
  l_approver_flag               ghr_pd_routing_history.approver_flag%TYPE;
  l_approved_flag               ghr_pd_routing_history.approved_flag%TYPE;
  l_personnelist_flag           ghr_pd_routing_history.personnelist_flag%TYPE;
  l_user_name_employee_id       per_people_f.person_id%TYPE;
  l_user_name_emp_first_name    per_people_f.first_name%TYPE;
  l_user_name_emp_last_name     per_people_f.last_name%TYPE;
  l_user_name_emp_middle_names  per_people_f.middle_names%TYPE;
  l_2_routing_seq_number        ghr_pd_routing_history.routing_seq_number%TYPE;
  l_forward_to_name             ghr_groupboxes.name%TYPE;
  l_2_groupbox_id               ghr_pd_routing_history.groupbox_id%TYPE;
  l_2_user_name                 ghr_pd_routing_history.user_name%TYPE;
  l_action_taken                ghr_pd_routing_history.action_taken%TYPE;
  l_item_key                    ghr_pd_routing_history.item_key%TYPE;
  l_pd_routing_history_id       ghr_pd_routing_history.pd_routing_history_id%TYPE;
-- Need to Make sure that we need this Cursor.
-- Open Issue is what do we use instead of effective_date.
/*  Cursor    C_user_emp_names is
    select  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    from    per_people_f per,
            fnd_user     usr
    where   upper(usr.user_name)  =  upper(p_1_user_name_acted_on)
    and     per.person_id         =  usr.employee_id
    and     p_date_from
    between per.effective_start_date
    and     per.effective_end_date;
*/
	-- Bug 4863608 Performance repository Changes for R12
	CURSOR    C_user_emp_names is
    SELECT  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    FROM    per_people_f per,
            fnd_user     usr
    WHERE   usr.user_name  =  UPPER(p_1_user_name_acted_on)
    AND     per.person_id         =  usr.employee_id
    AND     p_date_from
    BETWEEN per.effective_start_date
    AND     per.effective_end_date;

  Cursor     C_seq_number is
     select   rlm.seq_number,
              rlm.groupbox_id,
              rlm.user_name
     from     ghr_routing_list_members rlm
     where    rlm.routing_list_id = p_2_routing_list_id
     order by rlm.seq_number asc;
  Cursor c_history_exists is
     select 1
     from   ghr_pd_routing_history pdh
     where  pdh.position_description_id = l_position_description_id;
  Cursor  c_groupbox_name is
    select gbx.name
    from   ghr_groupboxes gbx
    where  gbx.groupbox_id = l_2_groupbox_id;
  Cursor  c_item_key_seq is
     select  ghr_pd_wf_item_key_s.nextval
     from    dual;

BEGIN
hr_utility.set_location('Now Entering:'||l_proc, 5);
-- Issue a savepoint if operating in validation only mode.
--IF p_validate THEN
	SAVEPOINT create_pdi;
--END IF;
-- Call Before Process User Hook
--
  begin
	ghr_pdi_bk1.create_pdi_b (
          p_date_from                   => p_date_from,
          p_routing_grp_id              => p_routing_grp_id,
          p_date_to                    	=> p_date_to,
          p_opm_cert_num       		=> p_opm_cert_num,
          p_flsa                       	=> p_flsa,
          p_financial_statement  	=> p_financial_statement,
          p_subject_to_ia_action        => p_subject_to_ia_action,
          p_position_status            	=> p_position_status,
          p_position_is                	=> p_position_is,
          p_position_sensitivity       	=> p_position_sensitivity,
          p_competitive_level       	=> p_competitive_level,
          p_pd_remarks                 	=> p_pd_remarks,
          p_position_class_std         	=> p_position_class_std,
          p_category                   	=> p_category,
          p_career_ladder              	=> p_career_ladder,
          p_supervisor_name             => p_supervisor_name,
          p_supervisor_title            => p_supervisor_title,
          p_supervisor_date             => p_supervisor_date,
          p_manager_name                => p_manager_name,
          p_manager_title               => p_manager_title,
          p_manager_date                => p_manager_date,
          p_classifier_name	        => p_classifier_name,
          p_classifier_title 	        => p_classifier_title,
          p_classifier_date             => p_classifier_date,
          p_attribute_category         	=> p_attribute_category,
          p_attribute1                 	=> p_attribute1,
          p_attribute2                 	=> p_attribute2,
          p_attribute3                 	=> p_attribute3,
          p_attribute4                 	=> p_attribute4,
          p_attribute5                 	=> p_attribute5,
          p_attribute6                 	=> p_attribute6,
          p_attribute7                 	=> p_attribute7,
          p_attribute8                 	=> p_attribute8,
          p_attribute9                 	=> p_attribute9,
          p_attribute10                	=> p_attribute10,
          p_attribute11                	=> p_attribute11,
          p_attribute12                	=> p_attribute12,
          p_attribute13                	=> p_attribute13,
          p_attribute14                	=> p_attribute14,
          p_attribute15                	=> p_attribute15,
          p_attribute16                	=> p_attribute16,
          p_attribute17                	=> p_attribute17,
          p_attribute18                	=> p_attribute18,
          p_attribute19                	=> p_attribute19,
          p_attribute20                	=> p_attribute20,
          p_business_group_id                	=> p_business_group_id,
          p_1_approved_flag               => p_1_approved_flag,
          p_1_user_name_acted_on          => p_1_user_name_acted_on,
          p_1_action_taken                => p_1_action_taken,
          p_2_user_name_routed_to         => p_2_user_name_routed_to,
          p_2_groupbox_id                 => p_2_groupbox_id,
          p_2_routing_list_id             => p_2_routing_list_id,
          p_2_routing_seq_number          => p_2_routing_seq_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pdi',
				 p_hook_type	=> 'BP'
				);
  end;
--
-- End of Before Process User Hook call
--
--
hr_utility.set_location(l_proc,6);
-- Validation in Addition to Row Handlers: There is no additional validation
-- Process Logic:  The process logic is to call the row handlers to insert the information into
-- GHR_POSITION_DESCRIPTIONS and GHR_PD_CLASSIFICATIONS.
-- 1)First insert a row into GHR_POSITION_DESCRIPTIONS table.
ghr_pdi_ins.ins
(
  p_position_description_id		=> l_position_description_id,
  p_routing_group_id             	=> p_routing_grp_id,
  p_date_from                    	=> p_date_from,
  p_date_to                    		=> p_date_to,
  p_opm_cert_num       			=> p_opm_cert_num,
  p_flsa                         	=> p_flsa,
  p_financial_statement   		=> p_financial_statement,
  p_subject_to_ia_action                => p_subject_to_ia_action,
  p_position_status              	=> p_position_status,
  p_position_is                  	=> p_position_is,
  p_position_sensitivity        	=> p_position_sensitivity,
  p_competitive_level       		=> p_competitive_level,
  p_pd_remarks                   	=> p_pd_remarks,
  p_position_class_std         		=> p_position_class_std,
  p_category                     	=> p_category,
  p_career_ladder                	=> p_career_ladder,
  p_supervisor_name                     => p_supervisor_name,
  p_supervisor_title                    => p_supervisor_title,
  p_supervisor_date                     => p_supervisor_date,
  p_manager_name		        => p_manager_name,
  p_manager_title 	                => p_manager_title,
  p_manager_date                        => p_manager_date,
  p_classifier_name	                => p_classifier_name,
  p_classifier_title 	                => p_classifier_title,
  p_classifier_date                     => p_classifier_date,
  p_attribute_category          	=> p_attribute_category,
  p_attribute1                   	=> p_attribute1,
  p_attribute2                   	=> p_attribute2,
  p_attribute3                  	=> p_attribute3,
  p_attribute4                   	=> p_attribute4,
  p_attribute5                   	=> p_attribute5,
  p_attribute6                 		=> p_attribute6,
  p_attribute7                 		=> p_attribute7,
  p_attribute8                  	=> p_attribute8 ,
  p_attribute9                  	=> p_attribute9,
  p_attribute10                 	=> p_attribute10 ,
  p_attribute11                 	=> p_attribute11,
  p_attribute12                 	=> p_attribute12 ,
  p_attribute13                 	=> p_attribute13 ,
  p_attribute14                 	=> p_attribute14 ,
  p_attribute15                  	=> p_attribute15,
  p_attribute16                		=> p_attribute16 ,
  p_attribute17                 	=> p_attribute17,
  p_attribute18                 	=> p_attribute18 ,
  p_attribute19                  	=> p_attribute19,
  p_attribute20                 	=> p_attribute20 ,
  p_business_group_id                 	=> p_business_group_id ,
  p_object_version_number        	=> l_pdi_object_version_number
  );
p_pdi_object_version_number := l_pdi_object_version_number;
p_position_description_id := l_position_description_id;
hr_utility.set_location('after pdi_ins.ins' ,6);
--insert_messages(2,l_position_description_id,l_proc);
--
--------------------------------------------------------------------------------------
-- Inserted by Dinkar. Karumuri for routing and Workflow on 05-AUG-1997
--
-- 3)Derive all parameters required to insert routing_history records.
--   Roles , Action_taken  (and sequence Number if necessary)
    l_action_taken := p_1_action_taken;
    if p_1_user_name_acted_on is not null then
      ghr_pdi_pkg.get_roles
     (l_position_description_id,
      p_routing_grp_id,
      p_1_user_name_acted_on,
      l_initiator_flag,
      l_requester_flag,
      l_authorizer_flag,
      l_personnelist_flag,
      l_approver_flag,
      l_reviewer_flag
      );
     for user_emp_names in C_user_emp_names loop
       l_user_name_employee_id      := user_emp_names.employee_id;
       l_user_name_emp_first_name   := user_emp_names.first_name;
       l_user_name_emp_last_name    := user_emp_names.last_name;
       l_user_name_emp_middle_names := user_emp_names.middle_names;
       exit;
     end loop;
    else
      hr_utility.set_message(8301,'GHR_38111_USER_NAME_REQD');
      hr_utility.raise_error;

    end if; -- End if for User Acted On condn.
   l_action_taken    := p_1_action_taken;
    if l_action_taken is null then
          l_action_taken := 'NO_ACTION';
    end if;
hr_utility.set_location('before invalid condition',10);

    if l_action_taken not in ('NOT_ROUTED','INITIATED','AUTHORIZED',
                              'NO_ACTION','REVIEWED','CANCELED','CLASSIFIED',
				'REQUESTED')
    then

       hr_utility.set_message(8301,'GHR_38110_INVALID_ACTION_TAKEN');
       hr_utility.raise_error;
    end if;
-- to check if there is any routing information, if required.
    if l_action_taken not in ('CANCELED','CLASSIFIED','NOT_ROUTED') then
       if p_2_user_name_routed_to is null and
          p_2_groupbox_id        is null and
          p_2_routing_list_id     is null then
          hr_utility.set_message(8301,'GHR_38280_NO_ROUTING_INFO');
          hr_utility.raise_error;
       end if;
    end if;
hr_utility.set_location('before getting item key'||l_action_taken,10);
    if nvl(l_action_taken,hr_api.g_varchar2)  in
                 ('NOT_ROUTED','INITIATED','CLASSIFIED','AUTHORIZED','REQUESTED')
           then

    OPEN c_item_key_seq;
    FETCH c_item_key_seq INTO l_item_key;
      IF c_item_key_seq%NOTFOUND THEN

    hr_utility.set_message(8301,'GHR_38625_NO_WF_ITEM_KEY_SEQ');
    hr_utility.raise_error;
      END IF;
    CLOSE c_item_key_seq;
    end if;

--insert_messages(5,l_position_description_id,'after item_key_seq');
-- write the first record into the routing history (actions done by the user)
    if nvl(l_action_taken,hr_api.g_varchar2) not in
    ('CANCELED') then
hr_utility.set_location('after not in cancled',10);
       ghr_pdh_ins.ins
       (
        p_pd_routing_history_id     => p_1_pd_routing_history_id,
        p_position_description_id   => l_position_description_id,
        p_initiator_flag            => nvl(l_initiator_flag,'N'),
        p_requester_flag            => nvl(l_requester_flag,'N'),
        p_approver_flag             => nvl(l_approver_flag,'N'),
        p_reviewer_flag             => nvl(l_reviewer_flag,'N') ,
        p_authorizer_flag           => nvl(l_authorizer_flag,'N'),
        p_personnelist_flag         => nvl(l_personnelist_flag,'N'),
        p_approved_flag             => nvl(p_1_approved_flag,'N'),
        p_user_name                 => p_1_user_name_acted_on,
        p_user_name_employee_id     => l_user_name_employee_id,
        p_user_name_emp_first_name  => l_user_name_emp_first_name,
        p_user_name_emp_last_name   => l_user_name_emp_last_name ,
        p_user_name_emp_middle_names =>l_user_name_emp_middle_names,
       p_date_notification_sent       => sysdate,
        p_action_taken              => l_action_taken,
        p_object_version_number     => p_1_pdh_object_version_number,
	p_item_key                  => l_item_key,
        p_validate                  => false
       );
-- Insert 2nd record into routing_history for routing details
--  (exception when routing_status = 'NOT_ROUTED' )
     if nvl(l_action_taken,hr_api.g_varchar2) not in  ('CLASSIFIED','NOT_ROUTED') then
hr_utility.set_location('in the 2nd row',10);
       l_2_routing_seq_number := p_2_routing_seq_number;
       l_2_groupbox_id        := p_2_groupbox_id;
       l_2_user_name          := p_2_user_name_routed_to;
--  derive the next sequence number for the speicific routing list if seq. number is not passed in
       if p_2_routing_list_id is not null and p_2_routing_seq_number is null then
         for rout_seq_numb in C_seq_number  loop
           l_2_routing_seq_number  := rout_seq_numb.seq_number;
           l_2_groupbox_id         := rout_seq_numb.groupbox_id;
           l_2_user_name           := rout_seq_numb.user_name;
           exit;
         end loop;
         if l_2_routing_seq_number is null then
           hr_utility.set_message(8301,'GHR_38114_NO_MORE_SEQ_NUMBER' );
           hr_utility.raise_error;
         end if;
       end if;

--    vravikan - Getting the next sequence number for workflow routing


       ghr_pdh_ins.ins
      (p_pd_routing_history_id        => p_2_pd_routing_history_id,
       p_position_description_id      => l_position_description_id,
       p_initiator_flag               => 'N',
       p_requester_flag               => 'N',
       p_approver_flag                => 'N',
       p_reviewer_flag                => 'N',
       p_authorizer_flag              => 'N',
       p_approved_flag                => 'N',
       p_personnelist_flag            => 'N',
       p_user_name                    => l_2_user_name,
       p_groupbox_id                  => l_2_groupbox_id,
       p_routing_list_id              => p_2_routing_list_id,
       p_routing_seq_number           => l_2_routing_seq_number,
       p_date_notification_sent       => sysdate,

       p_object_version_number        => p_2_pdh_object_version_number,
       p_item_key                     => l_item_key,

       p_validate                     => false
      );
 end if;
  else
    hr_utility.set_message(8301,'GHR_38112_INVALID_API');
    hr_utility.raise_error;
  end if;
-----------------------------------------------------------------------------------
--- When in validation only mode raise the Validate_Enabled_Exception

--
-- Call After Process User Hook
--
  begin
	ghr_pdi_bk1.create_pdi_a (
          p_position_description_id       => l_position_description_id,
          p_date_from                  	=> p_date_from,
          p_routing_grp_id                => p_routing_grp_id,
          p_date_to                    	=> p_date_to,
          p_opm_cert_num                => p_opm_cert_num,
          p_flsa                       	=> p_flsa,
          p_financial_statement   	=> p_financial_statement,
          p_subject_to_ia_action        => p_subject_to_ia_action,
          p_position_status            	=> p_position_status,
          p_position_is                	=> p_position_is,
          p_position_sensitivity        => p_position_sensitivity,
          p_competitive_level       	=> p_competitive_level,
          p_pd_remarks                 	=> p_pd_remarks,
          p_position_class_std         	=> p_position_class_std,
          p_category                   	=> p_category,
          p_career_ladder              	=> p_career_ladder,
          p_supervisor_name              => p_supervisor_name,
          p_supervisor_title             => p_supervisor_title,
          p_supervisor_date              => p_supervisor_date,
          p_manager_name	      => p_manager_name,
          p_manager_title 	         => p_manager_title,
          p_manager_date                 => p_manager_date,
          p_classifier_name	         => p_classifier_name,
          p_classifier_title 	         => p_classifier_title,
          p_classifier_date              => p_classifier_date,
          p_attribute_category          => p_attribute_category,
          p_attribute1                  => p_attribute1,
          p_attribute2                   => p_attribute2,
          p_attribute3                  => p_attribute3,
          p_attribute4                  => p_attribute4,
          p_attribute5                  => p_attribute5,
          p_attribute6                 	=> p_attribute6,
          p_attribute7                 	=> p_attribute7,
          p_attribute8                  => p_attribute8,
          p_attribute9                  => p_attribute9,
          p_attribute10                 => p_attribute10,
          p_attribute11                 => p_attribute11,
          p_attribute12                 => p_attribute12,
          p_attribute13                 => p_attribute13,
          p_attribute14                 => p_attribute14,
          p_attribute15                 => p_attribute15,
          p_attribute16                	=> p_attribute16,
          p_attribute17                 => p_attribute17,
          p_attribute18                 => p_attribute18,
          p_attribute19                 => p_attribute19,
          p_attribute20                 => p_attribute20,
  p_business_group_id                 	=> p_business_group_id ,
          p_1_approved_flag               => p_1_approved_flag,
          p_1_user_name_acted_on          => p_1_user_name_acted_on,
          p_1_action_taken                => p_1_action_taken,
          p_2_user_name_routed_to         => p_2_user_name_routed_to,
          p_2_groupbox_id                 => p_2_groupbox_id,
          p_2_routing_list_id             => p_2_routing_list_id,
          p_2_routing_seq_number          => p_2_routing_seq_number,
          p_1_pd_routing_history_id       => p_1_pd_routing_history_id,
          p_1_pdh_object_version_number   => p_1_pdh_object_version_number,
          p_2_pdh_object_version_number   => p_2_pdh_object_version_number,
          p_2_pd_routing_history_id       => p_2_pd_routing_history_id,
          p_pdi_object_version_number     => l_pdi_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pdi',
				 p_hook_type	=> 'AP'
				);
  end;
--
-- End of After Process User Hook call
--
IF p_validate THEN
	RAISE hr_api.validate_enabled;
END IF;
--
-- Set All output Arguments
--
p_position_description_id := l_position_description_id;
p_pdi_object_version_number := l_pdi_object_version_number;
hr_utility.set_location ('Leaving:'|| l_proc,11);
EXCEPTION

	WHEN hr_api.validate_enabled THEN
	-- As the validation exception has been raised
	-- We must rollback to the Savepoint set.
	ROLLBACK TO create_pdi;
--
--	Only Set Output warning arguments.
--  	(Any key or derived arguments must be set to NULL
--	When validation only mode is being used.)
--
	p_position_description_id := NULL;
        p_1_pd_routing_history_id := NULL;
        p_1_pdh_object_version_number := NULL;
        p_2_pdh_object_version_number := NULL;
        p_2_pd_routing_history_id     := NULL;
	p_pdi_object_version_number := NULL;
	when others then
           rollback to create_pdi;
           --
           -- Reset IN OUT parameters and set OUT parameters
           --
        p_position_description_id := NULL;
        p_1_pd_routing_history_id := NULL;
        p_1_pdh_object_version_number := NULL;
        p_2_pdh_object_version_number := NULL;
        p_2_pd_routing_history_id     := NULL;
        p_pdi_object_version_number := NULL;

           raise;
--
	hr_utility.set_location('Leaving:' || l_proc,12);
END create_pdi;
----------------------------|------------< Update_pdi >------------|--------------------------------

PROCEDURE  update_pdi
(
	p_validate IN BOOLEAN default false,
	p_position_description_id IN number,
	p_routing_grp_id	   IN   number default hr_api.g_number,
	p_date_from IN date,
	p_date_to IN date default hr_api.g_date,
	p_opm_cert_num IN ghr_position_descriptions.opm_cert_num%TYPE default hr_api.g_varchar2,
	p_flsa	IN	ghr_position_descriptions.flsa%TYPE default hr_api.g_varchar2,
	p_financial_statement IN ghr_position_descriptions.financial_statement%TYPE default hr_api.g_varchar2,
	p_subject_to_ia_action	IN  ghr_position_descriptions.subject_to_ia_action%TYPE default hr_api.g_varchar2,
	p_position_status IN ghr_position_descriptions.position_status%TYPE default hr_api.g_number,
	p_position_is	IN ghr_position_descriptions.position_is%TYPE default hr_api.g_varchar2,
	p_position_sensitivity IN ghr_position_descriptions.position_sensitivity%TYPE default hr_api.g_varchar2,
	p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE default hr_api.g_varchar2,
	p_pd_remarks	IN  ghr_position_descriptions.pd_remarks%TYPE default hr_api.g_varchar2,
	p_position_class_std IN ghr_position_descriptions.position_class_std%TYPE default hr_api.g_varchar2,
	p_category	IN ghr_position_descriptions.category%TYPE default hr_api.g_varchar2,
	p_career_ladder	IN ghr_position_descriptions.career_ladder%TYPE default hr_api.g_varchar2,
        p_supervisor_name         	in 	varchar2  default hr_api.g_varchar2,
        p_supervisor_title        	in 	varchar2  default hr_api.g_varchar2,
        p_supervisor_date         	in 	date      default hr_api.g_date,
        p_manager_name		  	in 	varchar2  default hr_api.g_varchar2,
        p_manager_title 	  	in 	varchar2  default hr_api.g_varchar2,
        p_manager_date            	in 	date      default hr_api.g_date,
        p_classifier_name	  	in 	varchar2  default hr_api.g_varchar2,
        p_classifier_title 	  	in 	varchar2  default hr_api.g_varchar2,
        p_classifier_date         	in 	date      default hr_api.g_date,
	p_attribute_category            in      varchar2  default hr_api.g_varchar2,
	p_attribute1                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute2                    in      varchar2  default hr_api.g_varchar2,
	p_attribute3                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute4                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute5                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute6                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute7                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute8                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute9                    in      varchar2  default hr_api.g_varchar2,
 	p_attribute10                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute11                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute12                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute13                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute14                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute15                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute16                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute17                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute18                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute19                   in      varchar2  default hr_api.g_varchar2,
 	p_attribute20                   in      varchar2  default hr_api.g_varchar2,
        p_business_group_id             in      number    default hr_api.g_number,
        p_u_approved_flag               in      varchar2  default hr_api.g_varchar2,
 	p_u_user_name_acted_on          in      varchar2  default hr_api.g_varchar2,
  	p_u_action_taken                in      varchar2  default null,
  	p_i_user_name_routed_to         in      varchar2  default null,
  	p_i_groupbox_id                 in      number    default null,
  	p_i_routing_list_id             in      number    default null,
  	p_i_routing_seq_number          in      number    default null,

  	p_u_pdh_object_version_number   in out nocopy  number,
  	p_i_pd_routing_history_id       out nocopy     number,
  	p_i_pdh_object_version_number   out nocopy     number,
	p_o_pd_routing_history_id       out nocopy     number,


        p_o_pdh_object_version_number   out nocopy     number,

	p_pdi_object_version_number     in out nocopy number)
IS
   l_pdi_object_version_number	number;
   l_proc 	varchar2(72) := g_package||'Update_pdi';
   l_routing_grp_id            ghr_position_descriptions.routing_group_id%TYPE;
   l_u_pd_routing_history_id     ghr_pd_routing_history.pd_routing_history_id%TYPE;
   l_i_pd_routing_history_id     ghr_pd_routing_history.pd_routing_history_id%TYPE;
   l_u_pdh_object_version_number ghr_pd_routing_history.object_version_number%TYPE;
   l_initial_u_pdh_ovn           ghr_pd_routing_history.object_version_number%TYPE;
   l_i_pdh_object_version_number ghr_pd_routing_history.object_version_number%TYPE;
   l_initial_pdi_ovn             ghr_pd_routing_history.object_version_number%TYPE;
   l_initiator_flag              ghr_pd_routing_history.initiator_flag%TYPE;
   l_reviewer_flag               ghr_pd_routing_history.reviewer_flag%TYPE;
   l_authorizer_flag             ghr_pd_routing_history.authorizer_flag%TYPE;
   l_requester_flag              ghr_pd_routing_history.requester_flag%TYPE;
   l_approver_flag               ghr_pd_routing_history.approver_flag%TYPE;
   l_personnelist_flag           ghr_pd_routing_history.personnelist_flag%TYPE;
   l_user_name_employee_id       per_people_f.person_id%TYPE;
   l_user_name_emp_first_name    per_people_f.first_name%TYPE;
   l_user_name_emp_last_name     per_people_f.last_name%TYPE;
   l_user_name_emp_middle_names  per_people_f.middle_names%TYPE;
   l_seq_numb                    ghr_pd_routing_history.routing_seq_number%TYPE;
   l_cur_seq_numb                ghr_pd_routing_history.routing_seq_number%TYPE;
   l_next_seq_numb               ghr_pd_routing_history.routing_seq_number%TYPE;
   l_next_groupbox_name          ghr_groupboxes.name%TYPE;
   l_next_groupbox_id            ghr_pd_routing_history.groupbox_id%TYPE;
   l_next_user_name              ghr_pd_routing_history.user_name%TYPE := p_i_user_name_routed_to;
   l_action_taken                ghr_pd_routing_history.action_taken%TYPE;
   l_old_action_taken            ghr_pd_routing_history.action_taken%TYPE;
   l_forward_to_name             ghr_pd_routing_history.user_name%type;
   l_cnt_history                 number;
   l_dummy                       ghr_pd_routing_history.action_taken%TYPE;
   l_pd_initiated                boolean;
   l_exists                      boolean;
   l_item_key                    ghr_pd_routing_history.item_key%TYPE;
   l_reclass_direct_flag         varchar2(1) := 'N';
   l_reclass_action_taken        ghr_pd_routing_history.action_taken%TYPE;
   l_last_item_key               ghr_pd_routing_history.item_key%TYPE;

 CURSOR     c_cnt_history is
     SELECT   count(*) cnt
     FROM     ghr_pd_routing_history pdh
     WHERE    pdh.position_description_id = p_position_description_id;

  CURSOR   c_routing_history_id is
    SELECT   pdh.pd_routing_history_id,
             pdh.object_version_number,
             pdh.action_taken,
             pdh.item_key
    FROM     ghr_pd_routing_history pdh
    WHERE    pdh.position_description_id = p_position_description_id
    ORDER BY pdh.pd_routing_history_id desc;

  CURSOR   c_routing_grp_id is
    SELECT  pdi.routing_group_id
    FROM    ghr_position_descriptions pdi
    WHERE   pdi.position_description_id = p_position_description_id;

/*   CURSOR     c_names is
     SELECT   usr.employee_id,
              per.first_name,
              per.last_name,
              per.middle_names
     FROM     fnd_user      usr,
              per_people_f  per
     WHERE    upper(p_u_user_name_acted_on)  = upper(usr.user_name)
     AND      per.person_id           = usr.employee_id
     AND      p_date_from
     BETWEEN  per.effective_start_date
     AND      per.effective_end_date;      */
	-- Bug 4863608 Perf. Repository Changes

	CURSOR     c_names IS
     SELECT   usr.employee_id,
              per.first_name,
              per.last_name,
              per.middle_names
     FROM     fnd_user      usr,
              per_people_f  per
     WHERE    usr.user_name = UPPER(p_u_user_name_acted_on)
     AND      per.person_id           = usr.employee_id
     AND      p_date_from
     BETWEEN  per.effective_start_date
     AND      per.effective_end_date;

   cursor      cur_rout_list_used is
     select    pdh.routing_seq_number
     from      ghr_pd_routing_history  pdh
     where     pdh.position_description_id      = p_position_description_id
     and       pdh.routing_list_id    = p_i_routing_list_id
     order  by pdh.pd_routing_history_id desc;
   cursor     cur_next_rout_seq is
     select   rlm.seq_number,
              rlm.groupbox_id,
              rlm.user_name
     from     ghr_routing_list_members  rlm
     where    rlm.routing_list_id = p_i_routing_list_id
     and      rlm.seq_number      > l_cur_seq_numb
     order by rlm.seq_number asc;
   cursor c_history_exists is
   select action_taken
   from   ghr_pd_routing_history pdh
   where  pdh.position_description_id = p_position_description_id
   order by pd_routing_history_id;

   cursor c_pd_initiated is

   select action_taken
   from   ghr_pd_routing_history pdh
   where  pdh.position_description_id = p_position_description_id
   and    action_taken = 'INITIATED';

   cursor  c_groupbox_name is
   select gbx.name
   from   ghr_groupboxes gbx
   where  gbx.groupbox_id = l_next_groupbox_id;
  Cursor  c_item_key_seq is
     select  ghr_pd_wf_item_key_s.nextval
     from    dual;
BEGIN
hr_utility.set_location('Entering'||l_proc,5);
--
-- Issue a savepoint if operating in validation mode.
--
--IF p_validate THEN
    SAVEPOINT update_pdi;
--END IF;
-- Call Before Process User Hook
--
  --
  -- Remember IN OUT parameter IN values
  l_initial_u_pdh_ovn   := p_u_pdh_object_version_number;
  l_initial_pdi_ovn     := p_pdi_object_version_number;

  begin
	ghr_pdi_bk2.update_pdi_b (
          p_position_description_id       => p_position_description_id,
          p_routing_grp_id                => p_routing_grp_id,
          p_date_from                   => p_date_from,
          p_date_to                    	=> p_date_to,
          p_opm_cert_num       		=> p_opm_cert_num,
          p_flsa                        => p_flsa,
          p_financial_statement   	=> p_financial_statement,
          p_subject_to_ia_action        => p_subject_to_ia_action,
          p_position_status             => p_position_status,
          p_position_is                 => p_position_is,
          p_position_sensitivity        => p_position_sensitivity,
          p_competitive_level       	=> p_competitive_level,
          p_pd_remarks                  => p_pd_remarks,
          p_position_class_std         	=> p_position_class_std,
          p_category                    => p_category,
          p_career_ladder               => p_career_ladder,
          p_supervisor_name             => p_supervisor_name,
          p_supervisor_title            => p_supervisor_title,
          p_supervisor_date             => p_supervisor_date,
          p_manager_name		=> p_manager_name,
          p_manager_title 	        => p_manager_title,
          p_manager_date                => p_manager_date,
          p_classifier_name	        => p_classifier_name,
          p_classifier_title 	        => p_classifier_title,
          p_classifier_date             => p_classifier_date,
          p_attribute_category         	=> p_attribute_category,
          p_attribute1                 	=> p_attribute1,
          p_attribute2                 	=> p_attribute2,
          p_attribute3                  => p_attribute3,
          p_attribute4                 	=> p_attribute4,
          p_attribute5                 	=> p_attribute5,
          p_attribute6                 	=> p_attribute6,
          p_attribute7                 	=> p_attribute7,
          p_attribute8                  => p_attribute8,
          p_attribute9                 	=> p_attribute9,
          p_attribute10                	=> p_attribute10,
          p_attribute11                	=> p_attribute11,
          p_attribute12                	=> p_attribute12,
          p_attribute13                	=> p_attribute13,
          p_attribute14                	=> p_attribute14,
          p_attribute15                	=> p_attribute15,
          p_attribute16                	=> p_attribute16,
          p_attribute17                	=> p_attribute17,
          p_attribute18                	=> p_attribute18,
          p_attribute19                	=> p_attribute19,
          p_attribute20                	=> p_attribute20,
          p_business_group_id                	=> p_business_group_id,
          p_u_approved_flag               => p_u_approved_flag,
          p_u_user_name_acted_on          => p_u_user_name_acted_on,
          p_u_action_taken                => p_u_action_taken,
          p_i_user_name_routed_to         => p_i_user_name_routed_to,
          p_i_groupbox_id                 => p_i_groupbox_id,
          p_i_routing_list_id             => p_i_routing_list_id,
          p_i_routing_seq_number          => p_i_routing_seq_number,
          p_u_pdh_object_version_number   => p_u_pdh_object_version_number,
          p_i_pd_routing_history_id       => p_i_pd_routing_history_id,
          p_i_pdh_object_version_number   => p_i_pdh_object_version_number,
          p_pdi_object_version_number     => p_pdi_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pdi',
				 p_hook_type	=> 'BP'
				);
  end;
--
-- End of Before Process User Hook call
--
hr_utility.set_location(l_proc,6);
--
--   Validation in addition to row handlers.
--
-- To Update the ghr_position_descriptions table. we need the primary key.
IF p_position_description_id is null  then
	hr_utility.set_message(8301, 'GHR_PD_ID_PRIMARY_KEY_INVALID');
	hr_utility.raise_error;
end if;
-- Process Logic
-- Update the row in ghr_position_description by calling the update row handler.
  -- Routing Group _Id can be changed  only in a case where the request has been initiated
  -- but not yet routed , for instance when the user uses the task flow button to
  -- naviage to another form  and when he comes back he can change the routing_grouip_id

  if p_routing_grp_id  is not null and p_routing_grp_id <> hr_api.g_number then
     for rout_group_id in c_routing_grp_id  loop
       l_routing_grp_id := rout_group_id.routing_group_id;
     end loop;
       if nvl(l_routing_grp_id,hr_api.g_number) <> p_routing_grp_id then
         for cnt_of_history in c_cnt_history  loop
           l_cnt_history     := cnt_of_history.cnt;
           exit;
         end loop;
         if nvl(l_cnt_history,0) > 1 then
           hr_utility.set_message(8301,'GHR_38638_PD_ROUT_GRP_NON_UPD');
           hr_utility.raise_error;
         end if;
       end if;
  end if;
l_pdi_object_version_number := p_pdi_object_version_number;
ghr_pdi_upd.upd
(
  p_position_description_id		=>   p_position_description_id,
  p_routing_group_id             	=>  p_routing_grp_id,
  p_date_from                    	=> p_date_from,
  p_date_to                    		=>  p_date_to,
  p_opm_cert_num       			=>  p_opm_cert_num,
  p_flsa                         	=>  p_flsa,
  p_financial_statement   		=> p_financial_statement,
  p_subject_to_ia_action                => p_subject_to_ia_action,
  p_position_status              	=> p_position_status,
  p_position_is                  	=> p_position_is,
  p_position_sensitivity        	=> p_position_sensitivity,
  p_competitive_level       		=> p_competitive_level,
  p_pd_remarks                   	=> p_pd_remarks,
  p_position_class_std         		=> p_position_class_std,
  p_category                     	=> p_category,
  p_career_ladder                	=> p_career_ladder,
  p_supervisor_name                     => p_supervisor_name,
  p_supervisor_title                    => p_supervisor_title,
  p_supervisor_date                     => p_supervisor_date,
  p_manager_name		        => p_manager_name,
  p_manager_title 	                => p_manager_title,
  p_manager_date                        => p_manager_date,
  p_classifier_name	                => p_classifier_name,
  p_classifier_title 	                => p_classifier_title,
  p_classifier_date                     => p_classifier_date,
  p_attribute_category          	=> p_attribute_category,
  p_attribute1                   	=> p_attribute1,
  p_attribute2                   	=> p_attribute2,
  p_attribute3                  	=> p_attribute3,
  p_attribute4                   	=> p_attribute4,
  p_attribute5                   	=> p_attribute5,
  p_attribute6                 		=> p_attribute6,
  p_attribute7                 		=> p_attribute7,
  p_attribute8                  	=> p_attribute8 ,
  p_attribute9                  	=> p_attribute9,
  p_attribute10                 	=> p_attribute10 ,
  p_attribute11                 	=> p_attribute11,
  p_attribute12                 	=> p_attribute12 ,
  p_attribute13                 	=> p_attribute13 ,
  p_attribute14                 	=> p_attribute14 ,
  p_attribute15                  	=> p_attribute15,
  p_attribute16                		=> p_attribute16 ,
  p_attribute17                 	=> p_attribute17,
  p_attribute18                 	=> p_attribute18 ,
  p_attribute19                  	=> p_attribute19,
  p_attribute20                 	=> p_attribute20 ,
  p_business_group_id                 	=> p_business_group_id ,
  p_object_version_number        	=> l_pdi_object_version_number
  );
--When in validation only mode raise the Validate_Enabled exception.
------------------------------------------------------------------
-- Added by Dinkar. Karumuri for Routing and Workflow.
-----------------------------------------------------
 --
 --2)Derive all parameters required to insert routing_history records.
   l_action_taken    := p_u_action_taken;
    if l_action_taken is null then
	l_action_taken := 'NO_ACTION';
    end if;
-- To check if PD has already been initiated

hr_utility.set_location('before open init',10);
    OPEN c_pd_initiated;
    FETCH c_pd_initiated INTO l_dummy;
    IF c_pd_initiated%FOUND THEN
       l_pd_initiated := TRUE;
    ELSE
       l_pd_initiated := FALSE;
    END IF;
    CLOSE c_pd_initiated;


    OPEN c_history_exists;
    FETCH c_history_exists INTO l_old_action_taken;

    l_exists := true;

    IF  c_history_exists%NOTFOUND THEN
        l_exists := false;
    END IF;

    CLOSE c_history_exists;



--Check for Invalid action taken

    if l_action_taken not in('NOT_ROUTED','INITIATED','AUTHORIZED',
                              'NO_ACTION','REVIEWED','CANCELED','REOPENED',
                             'REQUESTED', 'RECLASSIFIED','CLASSIFIED')
    then
       hr_utility.set_message(8301,'GHR_38110_INVALID_ACTION_TAKEN');
       hr_utility.raise_error;
    end if;

hr_utility.set_location('after invalid action',10);
    if l_action_taken not in ('CANCELED','CLASSIFIED','RECLASSIFIED','NOT_ROUTED') then
       if p_i_user_name_routed_to is null and
          p_i_groupbox_id        is null and
          p_i_routing_list_id     is null then
         hr_utility.set_message(8301,'GHR_38280_NO_ROUTING_INFO');
         hr_utility.raise_error;
       end if;
    end if;

-- For Direct Reclassification  and getting the last_item_key in case NOT_ROUTED to INITIATED

     for cur_routing_history_id in C_routing_history_id loop
       l_u_pd_routing_history_id     :=  cur_routing_history_id.pd_routing_history_id;
       l_u_pdh_object_version_number :=  cur_routing_history_id.object_version_number;
       l_reclass_action_taken        :=  cur_routing_history_id.action_taken;
       l_last_item_key               :=  cur_routing_history_id.item_key;
       exit;
     end loop;

   if  nvl(l_reclass_action_taken,hr_api.g_varchar2)  in ('RECLASSIFIED','CLASSIFIED') then
       if nvl(l_action_taken,hr_api.g_varchar2)  in ('RECLASSIFIED','NOT_ROUTED') then
         l_reclass_direct_flag := 'Y';
       end if;
   end if;

hr_utility.set_location('action taken is'||l_action_taken,10);

if l_action_taken in ('REOPENED') or l_reclass_direct_flag = 'Y' then
    OPEN c_item_key_seq;
    FETCH c_item_key_seq INTO l_item_key;
      IF c_item_key_seq%NOTFOUND THEN

    hr_utility.set_message(8301,'GHR_38625_NO_WF_ITEM_KEY_SEQ');
    hr_utility.raise_error;
      END IF;
    CLOSE c_item_key_seq;
end if;


     for cur_routing_history_id in C_routing_history_id loop
       l_u_pd_routing_history_id     :=  cur_routing_history_id.pd_routing_history_id;
       l_u_pdh_object_version_number :=  cur_routing_history_id.object_version_number;
       exit;
     end loop;
     if p_u_user_name_acted_on is not null then
      ghr_pdi_pkg.get_roles
     (p_position_description_id,
      p_routing_grp_id,
      p_u_user_name_acted_on,
      l_initiator_flag,
      l_requester_flag,
      l_authorizer_flag,
      l_personnelist_flag,
      l_approver_flag,
      l_reviewer_flag
      );
       for name_rec in C_names loop
         l_user_name_employee_id      := name_rec.employee_id ;
         l_user_name_emp_first_name   := name_rec.first_name;
         l_user_name_emp_last_name    := name_rec.last_name;
         l_user_name_emp_middle_names := name_rec.middle_names;
         exit;
       end loop;
     else
       hr_utility.set_message(8301,'GHR_38111_USER_NAME_REQD');
       hr_utility.raise_error;
    end if;


-- Update the latest record in the routing history for the specific pd id
-- Or  ( Modified by vravikan )
-- Insert a new record in the routing history if l_action_taken = 'REOPENED'
-- For reclassifaction of existing classfied PD we need two records  one is for 'REOPENED' status
-- another is for routing purposes


if not (nvl(l_action_taken,hr_api.g_varchar2) in ('NOT_ROUTED') and l_reclass_direct_flag = 'Y' )
then
if  nvl(l_action_taken,hr_api.g_varchar2) not in ('CANCELED','RECLASSIFIED','CLASSIFIED')
then

hr_utility.set_location('l_action taken is ' || l_action_taken,10);
hr_utility.set_location('l_reclass_direct is ' || l_reclass_direct_flag,10);
if l_action_taken <> 'REOPENED' or
((l_action_taken = 'REOPENED') and (l_reclass_action_taken = 'NOT_ROUTED')) then

     ghr_pdh_upd.upd
     (
     p_pd_routing_history_id      => l_u_pd_routing_history_id,
     p_initiator_flag             => nvl(l_initiator_flag,'N'),
     p_requester_flag             => nvl(l_requester_flag,'N'),
     p_approver_flag              => nvl(l_approver_flag,'N'),
     p_reviewer_flag              => nvl(l_reviewer_flag,'N'),
     p_authorizer_flag            => nvl(l_authorizer_flag,'N'),
     p_personnelist_flag          => nvl(l_personnelist_flag,'N'),
     p_approved_flag              => nvl(p_u_approved_flag,'N'),
     p_user_name                  => p_u_user_name_acted_on,
     p_user_name_employee_id      => l_user_name_employee_id,
     p_user_name_emp_first_name   => l_user_name_emp_first_name,
     p_user_name_emp_last_name    => l_user_name_emp_last_name,
     p_user_name_emp_middle_names => l_user_name_emp_middle_names,
       p_date_notification_sent       => sysdate,
     p_action_taken               => l_action_taken,
     p_object_version_number      => l_u_pdh_object_version_number,
     p_validate                   => p_validate
     );
elsif
(l_action_taken = 'REOPENED') and (l_reclass_action_taken <> 'NOT_ROUTED')
then
       ghr_pdh_ins.ins
       (
        p_pd_routing_history_id     => p_o_pd_routing_history_id,
        p_position_description_id   => p_position_description_id,
        p_initiator_flag            => nvl(l_initiator_flag,'N'),
        p_requester_flag            => nvl(l_requester_flag,'N'),
        p_approver_flag             => nvl(l_approver_flag,'N'),
        p_reviewer_flag             => nvl(l_reviewer_flag,'N') ,
        p_authorizer_flag           => nvl(l_authorizer_flag,'N'),
        p_personnelist_flag         => nvl(l_personnelist_flag,'N'),
        p_approved_flag              => nvl(p_u_approved_flag,'N'),
        p_user_name                  => p_u_user_name_acted_on,
        p_user_name_employee_id      => l_user_name_employee_id,
        p_user_name_emp_first_name   => l_user_name_emp_first_name,
        p_user_name_emp_last_name    => l_user_name_emp_last_name,
        p_user_name_emp_middle_names => l_user_name_emp_middle_names,
        p_action_taken               => l_action_taken,
       p_date_notification_sent       => sysdate,
        p_object_version_number      => p_o_pdh_object_version_number,
        p_validate                   => p_validate,
        p_item_key                   => l_item_key
          );
l_last_item_key := l_item_key;
end if;
  -- if the specific routing_list has already been used,get the next seq. no.from routing_list_members
  -- else sequence_number = 1
  -- if there are no more sequences, raise an error
  -- Insert 2nd record into routing_history for routing details (exception when action_taken = 'NOT_ROUTED')

    if nvl(l_action_taken,hr_api.g_varchar2) not in  ('NOT_ROUTED') then
      l_next_seq_numb    :=   p_i_routing_seq_number;
      l_next_groupbox_id :=   p_i_groupbox_id;
      l_next_user_name   :=   p_i_user_name_routed_to;
-- fetch the next sequence number for the specific routing list, when it is not passed
      if p_i_routing_list_id is not null and p_i_routing_seq_number is null then
        for rout_list_used in cur_rout_list_used loop
          l_cur_seq_numb := rout_list_used.routing_seq_number;
          exit;
        end loop;
        if l_cur_seq_numb is null then
          l_cur_seq_numb := 0;
        end if;
        for next_rout_seq_numb in cur_next_rout_seq loop
          l_next_seq_numb      := next_rout_seq_numb.seq_number;
          l_next_groupbox_id   := next_rout_seq_numb.groupbox_id;
          l_next_user_name     := next_rout_seq_numb.user_name;
          exit;
         end loop;
         if l_next_user_name is null then
           l_next_user_name := p_i_user_name_routed_to;
         end if;
         if l_next_groupbox_id is null then
            l_next_groupbox_id := p_i_groupbox_id;
         end if;
         if l_next_seq_numb is null then
           hr_utility.set_message(8301, 'GHR_38114_NO_MORE_SEQ_NUMBER');
           hr_utility.raise_error;
         end if;
      end if;



      ghr_pdh_ins.ins
      (p_pd_routing_history_id        => p_i_pd_routing_history_id,
       p_position_description_id      => p_position_description_id,
       p_initiator_flag               => 'N',
       p_requester_flag               => 'N',
       p_approver_flag                => 'N',
       p_reviewer_flag                => 'N',
       p_authorizer_flag              => 'N',
       p_approved_flag                => 'N',
       p_personnelist_flag            => 'N',
       p_user_name                    => l_next_user_name,
       p_groupbox_id                  => l_next_groupbox_id,
       p_routing_list_id              => p_i_routing_list_id,
       p_routing_seq_number           => l_next_seq_numb,
       p_date_notification_sent       => sysdate,
       p_object_version_number        => p_i_pdh_object_version_number,
       p_item_key                     => l_last_item_key,
       p_validate                     => p_validate
       );
    end if;
  end if;

end if;



 IF l_action_taken IN ('CANCELED','RECLASSIFIED','CLASSIFIED')
or  (nvl(l_action_taken,hr_api.g_varchar2) in ('NOT_ROUTED') and l_reclass_direct_flag = 'Y' )
then
hr_utility.set_location('l_action taken is ' || l_action_taken,10);
hr_utility.set_location('l_reclass_direct is ' || l_reclass_direct_flag,10);
     for cur_routing_history_id in C_routing_history_id loop
       l_u_pd_routing_history_id     :=  cur_routing_history_id.pd_routing_history_id;
       l_u_pdh_object_version_number :=  cur_routing_history_id.object_version_number;
       exit;
     end loop;

 if l_reclass_direct_flag = 'Y' then

       ghr_pdh_ins.ins
       (
        p_pd_routing_history_id     => p_o_pd_routing_history_id,
        p_position_description_id   => p_position_description_id,
        p_initiator_flag            => nvl(l_initiator_flag,'N'),
        p_requester_flag            => nvl(l_requester_flag,'N'),
        p_approver_flag             => nvl(l_approver_flag,'N'),
        p_reviewer_flag             => nvl(l_reviewer_flag,'N') ,
        p_authorizer_flag           => nvl(l_authorizer_flag,'N'),
        p_personnelist_flag         => nvl(l_personnelist_flag,'N'),
        p_approved_flag             => nvl(p_u_approved_flag,'N'),
        p_user_name                 => p_u_user_name_acted_on,
        p_user_name_employee_id     => l_user_name_employee_id,
        p_user_name_emp_first_name  => l_user_name_emp_first_name,
        p_user_name_emp_last_name   => l_user_name_emp_last_name ,
        p_user_name_emp_middle_names =>l_user_name_emp_middle_names,
        p_action_taken              => l_action_taken,
       p_date_notification_sent       => sysdate,
        p_object_version_number     => p_o_pdh_object_version_number,
	p_item_key                  => l_item_key,

        p_validate                  => false
       );
else
     ghr_pdh_upd.upd
     (
     p_pd_routing_history_id      => l_u_pd_routing_history_id,
     p_initiator_flag             => nvl(l_initiator_flag,'N'),
     p_requester_flag             => nvl(l_requester_flag,'N'),
     p_approver_flag              => nvl(l_approver_flag,'N'),
     p_reviewer_flag              => nvl(l_reviewer_flag,'N'),
     p_authorizer_flag            => nvl(l_authorizer_flag,'N'),
     p_personnelist_flag          => nvl(l_personnelist_flag,'N'),
     p_approved_flag              => nvl(p_u_approved_flag,'N'),
     p_user_name                  => p_u_user_name_acted_on,
     p_user_name_employee_id      => l_user_name_employee_id,
     p_user_name_emp_first_name   => l_user_name_emp_first_name,
     p_user_name_emp_last_name    => l_user_name_emp_last_name,
     p_user_name_emp_middle_names => l_user_name_emp_middle_names,
       p_date_notification_sent       => sysdate,
     p_action_taken               => l_action_taken,
     p_object_version_number      => l_u_pdh_object_version_number,
     p_validate                   => p_validate
     );

end if;

end if;
--
-- Call After Process User Hook
--
  begin
	ghr_pdi_bk2.update_pdi_a (
          p_position_description_id       => p_position_description_id,
          p_routing_grp_id                => p_routing_grp_id,
          p_date_from                  	=> p_date_from,
          p_date_to                    	=> p_date_to,
          p_opm_cert_num       		=> p_opm_cert_num,
          p_flsa                       	=> p_flsa,
          p_financial_statement   	=> p_financial_statement,
          p_subject_to_ia_action        => p_subject_to_ia_action,
          p_position_status            	=> p_position_status,
          p_position_is                	=> p_position_is,
          p_position_sensitivity        => p_position_sensitivity,
          p_competitive_level       	=> p_competitive_level,
          p_pd_remarks                 	=> p_pd_remarks,
          p_position_class_std         	=> p_position_class_std,
          p_category                   	=> p_category,
          p_career_ladder              	=> p_career_ladder,
          p_supervisor_name             => p_supervisor_name,
          p_supervisor_title            => p_supervisor_title,
          p_supervisor_date             => p_supervisor_date,
          p_manager_name	        => p_manager_name,
          p_manager_title 	        => p_manager_title,
          p_manager_date                => p_manager_date,
          p_classifier_name	        => p_classifier_name,
          p_classifier_title 	        => p_classifier_title,
          p_classifier_date             => p_classifier_date,
          p_attribute_category         	=> p_attribute_category,
          p_attribute1                 	=> p_attribute1,
          p_attribute2                 	=> p_attribute2,
          p_attribute3                 	=> p_attribute3,
          p_attribute4                 	=> p_attribute4,
          p_attribute5                 	=> p_attribute5,
          p_attribute6                 	=> p_attribute6,
          p_attribute7                 	=> p_attribute7,
          p_attribute8                 	=> p_attribute8,
          p_attribute9                 	=> p_attribute9,
          p_attribute10                	=> p_attribute10,
          p_attribute11                	=> p_attribute11,
          p_attribute12                	=> p_attribute12,
          p_attribute13                	=> p_attribute13,
          p_attribute14                	=> p_attribute14,
          p_attribute15                	=> p_attribute15,
          p_attribute16                	=> p_attribute16,
          p_attribute17                	=> p_attribute17,
          p_attribute18                	=> p_attribute18,
          p_attribute19                	=> p_attribute19,
          p_attribute20                	=> p_attribute20,
          p_business_group_id                	=> p_business_group_id,
          p_u_approved_flag               => p_u_approved_flag,
          p_u_user_name_acted_on          => p_u_user_name_acted_on,
          p_u_action_taken                => p_u_action_taken,
          p_i_user_name_routed_to         => p_i_user_name_routed_to,
          p_i_groupbox_id                 => p_i_groupbox_id,
          p_i_routing_list_id             => p_i_routing_list_id,
          p_i_routing_seq_number          => p_i_routing_seq_number,
          p_u_pdh_object_version_number   => p_u_pdh_object_version_number,
          p_i_pd_routing_history_id       => p_i_pd_routing_history_id,
          p_i_pdh_object_version_number   => p_i_pdh_object_version_number,
          p_pdi_object_version_number     => l_pdi_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pdi',
				 p_hook_type	=> 'AP'
				);
  end;
--
-- End of After Process User Hook call
--
IF p_validate THEN
	RAISE hr_api.validate_enabled;
END IF;
p_pdi_object_version_number := l_pdi_object_version_number;
hr_utility.set_location('Leaving:'|| l_proc,11);
EXCEPTION
	WHEN hr_api.validate_enabled THEN
	--
	-- As the Validate_Enabled exception has been raised
	-- We must rollback to the savepoint
	--
	ROLLBACK to update_pdi;
        --
        -- Reset IN OUT parameters and set OUT parameters
        --
        p_u_pdh_object_version_number  := l_initial_u_pdh_ovn;
        p_i_pd_routing_history_id      := null;
        p_i_pdh_object_version_number  := null;
        p_o_pd_routing_history_id      := null;
        p_o_pdh_object_version_number  := null;
        p_pdi_object_version_number    := l_initial_pdi_ovn;

	when others then
           rollback to update_pdi;
        --
        -- Reset IN OUT parameters and set OUT parameters
        --
        p_u_pdh_object_version_number  := l_initial_u_pdh_ovn;
        p_i_pd_routing_history_id      := null;
        p_i_pdh_object_version_number  := null;
        p_o_pd_routing_history_id      := null;
        p_o_pdh_object_version_number  := null;
        p_pdi_object_version_number    := l_initial_pdi_ovn;

           raise;
hr_utility.set_location('Leaving:'||l_proc,12);
END update_pdi;

procedure call_workflow
(
p_position_description_id IN ghr_position_descriptions.position_description_id%TYPE,
p_action_taken            IN ghr_pd_routing_history.action_taken%TYPE
)
is
  l_position_description_id   ghr_position_descriptions.position_description_id%TYPE;
  l_pdi_object_version_number number := 1;
  l_initiator_flag              ghr_pd_routing_history.initiator_flag%TYPE;
  l_reviewer_flag               ghr_pd_routing_history.reviewer_flag%TYPE;
  l_requester_flag              ghr_pd_routing_history.requester_flag%TYPE;
  l_authorizer_flag             ghr_pd_routing_history.authorizer_flag%TYPE;
  l_approver_flag               ghr_pd_routing_history.approver_flag%TYPE;
  l_approved_flag               ghr_pd_routing_history.approved_flag%TYPE;
  l_personnelist_flag           ghr_pd_routing_history.personnelist_flag%TYPE;
  l_user_name_employee_id       per_people_f.person_id%TYPE;
  l_user_name_emp_first_name    per_people_f.first_name%TYPE;
  l_user_name_emp_last_name     per_people_f.last_name%TYPE;
  l_user_name_emp_middle_names  per_people_f.middle_names%TYPE;
  l_2_routing_seq_number        ghr_pd_routing_history.routing_seq_number%TYPE;
  l_forward_to_name             ghr_groupboxes.name%TYPE;
  l_2_groupbox_id               ghr_pd_routing_history.groupbox_id%TYPE;
  l_user_name_1                 ghr_pd_routing_history.user_name%TYPE;
  l_user_name_2                 ghr_pd_routing_history.user_name%TYPE;
  l_last_action_taken_1         ghr_pd_routing_history.action_taken%TYPE;
  l_last_action_taken_2         ghr_pd_routing_history.action_taken%TYPE;
  l_item_key_1                    ghr_pd_routing_history.item_key%TYPE;
  l_item_key_2                    ghr_pd_routing_history.item_key%TYPE;
  l_pd_routing_history_id_1       ghr_pd_routing_history.pd_routing_history_id%TYPE;
  l_pd_routing_history_id_2       ghr_pd_routing_history.pd_routing_history_id%TYPE;
  l_cnt_history                 number;
  l_reclass_direct_flag         varchar2(1) := 'N';
  l_groupbox_id_1               ghr_pd_routing_history.groupbox_id%TYPE;
  l_groupbox_id_2               ghr_pd_routing_history.groupbox_id%TYPE;
  l_proc varchar2(72) := g_package||'call_work_flow';
  l_pd_initiated        BOOLEAN;
  l_dummy               varchar2(1);
  Cursor c_history_exists is
     select 1
     from   ghr_pd_routing_history pdh
     where  pdh.position_description_id = p_position_description_id;
  Cursor  c_groupbox_name is
    select gbx.name
    from   ghr_groupboxes gbx
    where  gbx.groupbox_id = l_groupbox_id_1;
  Cursor  c_item_key_seq is
     select  ghr_pd_wf_item_key_s.nextval
     from    dual;
 cursor     c_cnt_history is
     select   count(*) cnt
     from     ghr_pd_routing_history pdh
     where    pdh.position_description_id = p_position_description_id;
  Cursor   C_routing_history_id is
    select   pdh.pd_routing_history_id,
             pdh.action_taken,
             pdh.item_key,
             pdh.groupbox_id,
             pdh.user_name
    from     ghr_pd_routing_history pdh
    where    pdh.position_description_id = p_position_description_id
    order by pdh.pd_routing_history_id desc;
    cursor   c_routing_grp_id is
    select  pdi.routing_group_id
    from    ghr_position_descriptions pdi
    where   pdi.position_description_id = p_position_description_id;
   cursor c_pd_initiated is
   select 'X'
   from   ghr_pd_routing_history pdh
   where  pdh.position_description_id = p_position_description_id
   and    action_taken in ( 'INITIATED','AUTHORIZED','REQUESTED','CLASSIFIED');

begin

hr_utility.set_location('Now Entering:'||l_proc, 5);
-- Get the Routing history Count
     FOR cnt_history in c_cnt_history LOOP
            l_cnt_history    := cnt_history.cnt;
     END LOOP;
hr_utility.set_location('after count history: #'||to_char(l_cnt_history), 5);
hr_utility.set_location('action taken is '||p_action_taken, 5);
-- Get the last two action takens
      if l_cnt_history > 0 then
       open  c_routing_history_id;
       fetch c_routing_history_id into
                 l_pd_routing_history_id_1,
                 l_last_action_taken_1,
                 l_item_key_1,
                 l_groupbox_id_1,
                 l_user_name_1;
      if l_cnt_history > 1 then
       fetch c_routing_history_id into
                 l_pd_routing_history_id_2,
                 l_last_action_taken_2,
                 l_item_key_2,
                 l_groupbox_id_2,
                 l_user_name_2;
      end if;
    end if;
       close c_routing_history_id;
hr_utility.set_location('action 1 is '||l_last_action_taken_1, 5);
hr_utility.set_location('action 2 is '||l_last_action_taken_2, 5);
hr_utility.set_location('item key1 is '||l_item_key_1, 5);
hr_utility.set_location('item key2 is '||l_item_key_2, 5);
open c_pd_initiated;
fetch c_pd_initiated into l_dummy;
if c_pd_initiated%FOUND then
  l_pd_initiated := TRUE;
else
  l_pd_initiated := FALSE;
end if;
-- Setting the reclass_direct_flag
   if l_cnt_history > 1 then
     if  nvl(l_last_action_taken_2,hr_api.g_varchar2)
                  in ('RECLASSIFIED','CLASSIFIED') then
       if nvl(l_last_action_taken_1,hr_api.g_varchar2)  = 'RECLASSIFIED' then
         l_reclass_direct_flag := 'Y';
       end if;
     end if;
   end if;

 -- Deriving the groupbox name to be passed to workflow call
    if l_groupbox_id_1 is not null then
      for groupbox_name in c_groupbox_name loop
        l_forward_to_name := groupbox_name.name;
      end loop;
    else
      l_forward_to_name := l_user_name_1;
    end if;
hr_utility.set_location('l_forward_to_name is '||l_forward_to_name, 5);
if p_action_taken in ('REOPENED','INITIATED')  or (l_reclass_direct_flag = 'Y' and p_action_taken = 'RECLASSIFIED' ) then
        ghr_wf_pd_pkg.StartPDprocess
       (p_position_description_id  => p_position_description_id,
        p_item_key                 => l_item_key_1,
        p_forward_to_name          => l_forward_to_name
        );
elsif p_action_taken in ('CLASSIFIED') and l_cnt_history = 1 then
        ghr_wf_pd_pkg.StartPDprocess
       (p_position_description_id  => p_position_description_id,
        p_item_key                 => l_item_key_1,
        p_forward_to_name          => l_forward_to_name
        );
elsif p_action_taken in ('REQUESTED','AUTHORIZED') and l_cnt_history = 2 then
        ghr_wf_pd_pkg.StartPDprocess
       (p_position_description_id  => p_position_description_id,
        p_item_key                 => l_item_key_1,
        p_forward_to_name          => l_forward_to_name
        );
else
          ghr_wf_pd_pkg.CompleteBlockingOfPD(
               p_position_description_id => p_position_description_id  );
end if;
end call_workflow;
end ghr_pdi_api;

/
