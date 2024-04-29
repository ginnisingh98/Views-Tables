--------------------------------------------------------
--  DDL for Package Body PQP_EXR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_SWI" As
/* $Header: pqexrswi.pkb 120.2.12010000.3 2010/03/26 08:54:49 mdubasi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_exr_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_name        in     varchar2
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_balance_type_id              in     number    default null
  ,p_balance_dimension_id         in     number    default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_comparison_type              in     varchar2  default null
  ,p_comparison_value             in     number    default null
  ,p_language_code                in     varchar2  default null
  ,p_exception_report_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_output_format_type           in     varchar2
  ,p_variance_operator            in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_exception_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_exception_report_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_exr_api.create_exception_report
    (p_validate                     => l_validate
    ,p_exception_report_name        => p_exception_report_name
    ,p_legislation_code             => p_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_currency_code                => p_currency_code
    ,p_balance_type_id              => p_balance_type_id
    ,p_balance_dimension_id         => p_balance_dimension_id
    ,p_variance_type                => p_variance_type
    ,p_variance_value               => p_variance_value
    ,p_comparison_type              => p_comparison_type
    ,p_comparison_value             => p_comparison_value
    ,p_language_code                => p_language_code
    ,p_exception_report_id          => p_exception_report_id
    ,p_object_version_number        => p_object_version_number
    ,p_output_format_type           => p_output_format_type
    ,p_variance_operator            => p_variance_operator
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_exception_report_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_exception_report_id          := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_exception_report_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_exception_report_id          := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_exception_report;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_exception_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_exception_report_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_exr_api.delete_exception_report
    (p_validate                     => l_validate
    ,p_exception_report_id          => p_exception_report_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_exception_report_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_exception_report_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_exception_report;
-- ----------------------------------------------------------------------------
-- |------------------------< update_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_name        in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_balance_type_id              in     number    default hr_api.g_number
  ,p_balance_dimension_id         in     number    default hr_api.g_number
  ,p_variance_type                in     varchar2  default hr_api.g_varchar2
  ,p_variance_value               in     number    default hr_api.g_number
  ,p_comparison_type              in     varchar2  default hr_api.g_varchar2
  ,p_comparison_value             in     number    default hr_api.g_number
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_output_format_type           in     varchar2  default hr_api.g_varchar2
  ,p_variance_operator            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_exception_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_exception_report_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_exr_api.update_exception_report
    (p_validate                     => l_validate
    ,p_exception_report_name        => p_exception_report_name
    ,p_legislation_code             => p_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_currency_code                => p_currency_code
    ,p_balance_type_id              => p_balance_type_id
    ,p_balance_dimension_id         => p_balance_dimension_id
    ,p_variance_type                => p_variance_type
    ,p_variance_value               => p_variance_value
    ,p_comparison_type              => p_comparison_type
    ,p_comparison_value             => p_comparison_value
    ,p_exception_report_id          => p_exception_report_id
    --,p_language_code                => p_language_code
    ,p_object_version_number        => p_object_version_number
    ,p_output_format_type           => p_output_format_type
    ,p_variance_operator            => p_variance_operator
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_exception_report_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_exception_report_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_exception_report;


-- ----------------------------------------------------------------------------
-- |------------------------< submit_request_set >-----------------------|
-- ----------------------------------------------------------------------------
procedure submit_request_set(
   p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_id          in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_request_type                 in     varchar2  default null
  ,p_gre_id                       in     number    default null
  ,p_state_code                   in     number    default null
  ,p_exception_grp_name           in     varchar2  default null
  ,p_exception_rep_name           in     varchar2  default null
  ,p_exception_group_id           in     number
  ,p_effective_date               in     date
  ,p_output_format                in     varchar2  default null
  ,p_template_name                in     varchar2  default null
  ,p_component_id                 in     number    default null
  ,p_request_id                   out nocopy number
  ,p_return_status                out nocopy varchar2
)
is
  success                 boolean:= true;
  request_id              NUMBER:= 0;
  submit_failed           EXCEPTION;
  req_id                  number;
  l_request_name          varchar2(35);
  l_grp_request_code      varchar(20);
  l_rep_request_code      varchar(20);
  l_rep_dmy_place_holder1 varchar(20);
  l_grp_dmy_place_holder1 varchar(20);
  l_ppa_finder            varchar2(20);
  l_trnsfer_rep_arg17     varchar(50);
  l_trnsfer_grp_arg14     varchar2(50);
  l_payroll_dummy         varchar2(50);
  l_variance_type_dummy	  varchar2(50);
  l_variance_value_dummy  varchar2(50);
  l_gre_id_dummy	  varchar2(50);
  l_state_code_dummy	  varchar2(50);
  l_component_id_dummy    varchar2(50);
  l_product_release       VARCHAR2(50);
  l_proc                  varchar2(72) := g_package||'submit_request_set';

begin
    hr_utility.set_location('Entering:'|| l_proc, 1);

    --PPA finder value
    SELECT TO_CHAR(sysdate,'HHSSSSS') INTO l_ppa_finder
    FROM DUAL;
    --Starting the request set
    success := fnd_submit.set_request_set('PAY', 'PAYEXREP');
    --Hard coded the values based on report or group
    IF p_request_type = 'ER' then
        l_request_name     := 'Exception Report';
        l_grp_request_code :=NULL;
        l_rep_request_code :='ER';
        l_rep_dmy_place_holder1 :=p_exception_report_id||'A';
        l_grp_dmy_place_holder1 :='A';
        l_trnsfer_rep_arg17  := 'TRANSFER_REPORT='||p_exception_report_id;
        l_trnsfer_grp_arg14  := NULL;
    ELSE
        l_request_name := 'Exception Group';
        l_rep_request_code :=NULL;
        l_grp_request_code :='EG';
        l_rep_dmy_place_holder1 :='A';
        l_grp_dmy_place_holder1 :=p_exception_group_id||'A';
        l_trnsfer_rep_arg17 := NULL;
        l_trnsfer_grp_arg14 := 'TRANSFER_GROUP='||p_exception_group_id;
     END IF;

     --Checking the payroll value
     IF  p_payroll_id IS NULL THEN
       	 l_payroll_dummy := NULL;
     ELSE
         l_payroll_dummy := 'TRANSFER_PAYROLL='||p_payroll_id;
     END IF;

     --Checking the p_variance_type
     IF  p_variance_type IS NULL THEN
       	 l_variance_type_dummy := NULL;
     ELSE
         l_variance_type_dummy := 'TRANSFER_VARTYPE='||p_variance_type;
     END IF;

     --Checking the p_variance_value
     IF  p_variance_value IS NULL THEN
       	 l_variance_value_dummy := NULL;
     ELSE
         l_variance_value_dummy := 'TRANSFER_VARVALUE='||p_variance_value;
     END IF;

     --Checking the p_variance_value
     IF  p_gre_id IS NULL THEN
       	 l_gre_id_dummy := NULL;
     ELSE
         l_gre_id_dummy := 'TRANSFER_GRE='||p_gre_id;
     END IF;

     --Checking the p_variance_value
     IF  p_state_code IS NULL THEN
       	 l_state_code_dummy := NULL;
     ELSE
         l_state_code_dummy := 'TRANSFER_JD='||p_state_code;
     END IF;

     --Checking the p_component_id
     IF  p_component_id IS NULL THEN
       	 l_component_id_dummy := NULL;
     ELSE
         l_component_id_dummy := 'TRANSFER_COMP='||p_component_id;
     END IF;

      SELECT substr(p.product_version,1,2) into l_product_release
        FROM fnd_application a, fnd_application_tl t, fnd_product_installations p
       WHERE a.application_id = p.application_id
         AND a.application_id = t.application_id
         AND t.language = Userenv ('LANG')
         AND Substr (a.application_short_name, 1, 5) = 'PAY';

    	--Starting point to stage starts
        -- 'Exception Report Preprocessor'
        if ( success ) then
           /* submit program PQPEXREP which is in stage STAGE1 */
	   IF TO_NUMBER(l_product_release) = 11 THEN
           success := fnd_submit.submit_program('PQP','PQPEXREP','Exception Report Preprocessor'
           ,argument1=>'ARCHIVE'
           ,argument2=>'EXPREP'
           ,argument3=>'DEFAULT'
           ,argument4=> fnd_date.date_to_canonical(p_effective_date)
           ,argument5=> fnd_date.date_to_canonical(p_effective_date)
           ,argument6=> 'REPORT'
           ,argument7=>  p_business_group_id
           ,argument8=>  NULL
           ,argument9=>  NULL
           ,argument10=> p_legislation_code
           ,argument11=> l_request_name     --'Exception Report'/'Exception Group'
           ,argument12=> l_grp_request_code --'EG' if exception group else NULL
           ,argument13=> p_exception_group_id -- Exception Group Name
           ,argument14=> l_trnsfer_grp_arg14  --Exception Group Name Dummy
           ,argument15=> l_rep_request_code--'ER' if 'report' else NULL
           ,argument16=> p_exception_report_id
           ,argument17=> l_trnsfer_rep_arg17--'TRANSFER_REPORT='||p_exception_report_id
           ,argument18=> l_rep_dmy_place_holder1--'A' or Null based on report id
           ,argument19=> l_grp_dmy_place_holder1--l_grp_dmy_place_holder1--'A' or null based on group name
           ,argument20=> p_variance_type
           ,argument21=> l_variance_type_dummy --Over Ride Variance Type Dummy
           ,argument22=> p_variance_value
           ,argument23=> l_variance_value_dummy	--Over ride Variance Value Dummy
           ,argument24=> p_payroll_id
           ,argument25=> l_payroll_dummy --Payroll Dummy
           ,argument26=> p_consolidation_set_id
           ,argument27=>'TRANSFER_CONC_SET='||p_consolidation_set_id
           ,argument28=>p_gre_id
           ,argument29=>l_gre_id_dummy
           ,argument30=>p_state_code
           ,argument31=>l_state_code_dummy
           ,argument37=>p_component_id
           ,argument38=>l_component_id_dummy
           ,argument32=>l_ppa_finder
           ,argument33=>'TRANSFER_PPA_FINDER='||l_ppa_finder
           ,argument34=>'TRANSFER_DATE='||fnd_date.date_to_canonical(p_effective_date)
	   ,argument35=>p_template_name
	   ,argument36=>p_output_format
	   );
	   ELSE
	              success := fnd_submit.submit_program('PQP','PQPEXREP','Exception Report Preprocessor'
           ,argument1=>'ARCHIVE'
           ,argument2=>'EXPREP'
           ,argument3=>'DEFAULT'
           ,argument4=> fnd_date.date_to_canonical(p_effective_date)
           ,argument5=> fnd_date.date_to_canonical(p_effective_date)
           ,argument6=> 'REPORT'
           ,argument7=>  p_business_group_id
           ,argument8=>  NULL
           ,argument9=>  NULL
           ,argument10=> p_legislation_code
           ,argument11=> l_request_name     --'Exception Report'/'Exception Group'
           ,argument12=> l_grp_request_code --'EG' if exception group else NULL
           ,argument13=> p_exception_group_id -- Exception Group Name
           ,argument14=> l_trnsfer_grp_arg14  --Exception Group Name Dummy
           ,argument15=> l_rep_request_code--'ER' if 'report' else NULL
           ,argument16=> p_exception_report_id
           ,argument17=> l_trnsfer_rep_arg17--'TRANSFER_REPORT='||p_exception_report_id
           ,argument18=> l_rep_dmy_place_holder1--'A' or Null based on report id
           ,argument19=> l_grp_dmy_place_holder1--l_grp_dmy_place_holder1--'A' or null based on group name
           ,argument20=> p_variance_type
           ,argument21=> l_variance_type_dummy --Over Ride Variance Type Dummy
           ,argument22=> p_variance_value
           ,argument23=> l_variance_value_dummy	--Over ride Variance Value Dummy
	   ,argument39=> NULL	--OverRide Variance Type Dummy2
           ,argument24=> p_payroll_id
           ,argument25=> l_payroll_dummy --Payroll Dummy
           ,argument26=> p_consolidation_set_id
           ,argument27=>'TRANSFER_CONC_SET='||p_consolidation_set_id
           ,argument28=>p_gre_id
           ,argument29=>l_gre_id_dummy
           ,argument30=>p_state_code
           ,argument31=>l_state_code_dummy
           ,argument37=>p_component_id
           ,argument38=>l_component_id_dummy
           ,argument32=>l_ppa_finder
           ,argument33=>'TRANSFER_PPA_FINDER='||l_ppa_finder
           ,argument34=>'TRANSFER_DATE='||fnd_date.date_to_canonical(p_effective_date)
	   ,argument35=>p_template_name
	   ,argument36=>p_output_format
	   );
	   END IF;

           if ( not success ) then
             hr_utility.set_location('Exception Report Preprocessor Fail',50);
             raise submit_failed;
           ELSE
              hr_utility.set_location('Exception Report Preprocessor Sucess',50);
           end if;

	   -- 'Exception Report'
          /* submit program PQPRPEXR which is in stage STAGE2  */
          success := fnd_submit.submit_program('PQP','PQPXMLLAY', 'Payroll Exception Report'
           ,argument1=>l_ppa_finder
           ,argument2=>NULL
           ,argument3=>p_business_group_id
           ,argument4=>l_request_name    --Select Report or Group
           ,argument5=>l_grp_request_code--'EG' if exception group else NULL
           ,argument6=>p_exception_grp_name
           ,argument7=>l_rep_request_code--'ER' if exception group else NULL
           ,argument8=>p_exception_report_id
           ,argument9=>p_variance_type
           ,argument10=>p_variance_value
           ,argument11=>p_payroll_id
           ,argument12=>p_consolidation_set_id
           ,argument13=>fnd_date.date_to_canonical(p_effective_date)
	   ,argument14=>p_template_name
	   ,argument15=>p_output_format
           );
          if ( not success ) then
             hr_utility.set_location('Stage2 first submit fail' ,50);
             raise submit_failed;
          ELSE
             hr_utility.set_location('Stage2 first submit success' ,50);
          end if;
          /*  Submit the Request set  */
          req_id := fnd_submit.submit_set(null,FALSE);
          hr_utility.set_location('Request ID:'||req_id ,50);
   end if;
  p_request_id := req_id;
  p_return_status := 'S';
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
   when submit_failed THEN
     hr_utility.set_location('error Leaving:'||l_proc, 80);
     p_return_status := 'E';
     raise;
   when others then
     hr_utility.set_location(' error Leaving:'||l_proc, 80);
     p_return_status := 'E';
     raise;
end submit_request_set;

-- ----------------------------------------------------------------------------
-- |------------------------< exception_report_xml_process >-----------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_legislation_code (p_business_group_id IN NUMBER)
 RETURN VARCHAR2
 IS
 l_legislation_code_l  per_business_groups.legislation_code%TYPE;
 BEGIN
 hr_utility.trace('Enter Legislation code');
  SELECT legislation_code
    INTO l_legislation_code_l
   FROM per_business_groups
   WHERE business_group_id      =p_business_group_id;

   RETURN (l_legislation_code_l);
   hr_utility.trace('Leaving Legislation code' );
 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);

 END;

-- ----------------------------------------------------------------------------
-- |------------------------< exception_report_xml_process >-----------------------|
-- ----------------------------------------------------------------------------
procedure exception_report_xml_process(
   errbuf                        OUT NOCOPY  VARCHAR2
  ,retcode                       OUT NOCOPY  VARCHAR2
  ,p_ppa_finder                   in     varchar2  default null
  ,p_DES_TYPE                     in     varchar2 default null
  ,p_business_group_id            in     varchar2 default null
  ,p_request_name                 in     varchar2  default null
  ,p_grp_request_code             in     varchar2  default null
  ,p_exception_grp_name           in     varchar2  default null
  ,p_rep_request_code             in     varchar2  default null
  ,p_exception_report_id          in     varchar2  default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_effective_date               in     varchar2  default null
  ,p_template_name                in     varchar2  default null
  ,p_output_format		  in     varchar2  default null
)
is
  success                 boolean:= true;
  request_id              NUMBER:= 0;
  submit_failed           EXCEPTION;
  req_id                  number;
  l_request_name          varchar2(35);
  l_grp_request_code      varchar(20);
  l_rep_request_code      varchar(20);
  l_rep_dmy_place_holder1 varchar(20);
  l_grp_dmy_place_holder1 varchar(20);
  l_ppa_finder            varchar2(20);
  l_trnsfer_rep_arg17     varchar(50);
  l_trnsfer_grp_arg14     varchar2(50);
  l_payroll_dummy         varchar2(50);
  l_variance_type         varchar2(50);
  l_variance_value_dummy  varchar2(50);
  l_gre_id_dummy	  varchar2(50);
  l_state_code_dummy	  varchar2(50);
  l_proc                  varchar2(72) := g_package||'exception_report_xml_process';
  l_request_id            number;
  l_app_short_name        varchar2(10);
  l_template_code         varchar2(40);
  l_default_lang          varchar2(10);
  l_default_territory     varchar2(10);
  l_temp                  varchar2(500);
  l_exception_report_id	  varchar2(40);
  l_legislation_code per_business_groups.legislation_code%TYPE                    ;


  cursor c_rtf_data(c_template_name in varchar2) is
       Select application_short_name,template_code,default_language,default_territory
         from  xdo_templates_vl
        where template_name =c_template_name
	  and application_id=8303;

 CURSOR c_rep_id (c_exception_report_id IN VARCHAR2
                   ,c_business_group_id   IN  VARCHAR2
		   ,c_legislation_code    IN VARCHAR2)
 IS
 SELECT exception_report_id
  FROM pqp_exception_reports
  WHERE exception_report_name=c_exception_report_id
    AND (business_group_id =c_business_group_id
     OR business_group_id IS NULL)
    AND (legislation_code=c_legislation_code
     OR legislation_code IS NULL);

begin
    IF p_request_name = 'Exception Report' THEN
        l_rep_request_code :='ER';
    ELSE
        l_grp_request_code :='EG';
    END IF;
    --Varience value check
    IF p_variance_type = 'Amount' THEN
       l_variance_type :='A' ;
    ELSIF p_variance_type = 'Amount' THEN
       l_variance_type :='P' ;
    ELSE
       l_variance_type :=p_variance_type ;
    END IF;
    --Gettign the report ID
    IF 	p_exception_report_id IS NOT NULL THEN
        l_legislation_code:=get_legislation_code(p_business_group_id);
        open c_rep_id(c_exception_report_id      => p_exception_report_id
	                    ,c_business_group_id => p_business_group_id
			    ,c_legislation_code  => l_legislation_code);
        fetch c_rep_id into l_exception_report_id;
        close c_rep_id;

	IF l_exception_report_id IS NULL THEN
	   l_exception_report_id :=p_exception_report_id;
	END IF;

    END IF;

    hr_utility.set_location('Entering:'|| l_proc, 1);

    open c_rtf_data(c_template_name => p_template_name);
    fetch c_rtf_data into l_app_short_name,l_template_code,l_default_lang,l_default_territory;
    close c_rtf_data;


    IF p_output_format = 'HTML' THEN
       success := FND_REQUEST.add_layout(l_app_short_name,l_template_code,l_default_lang,l_default_territory,'HTML');
    ELSIF p_output_format = 'PDF' or p_output_format ='TXT'THEN
       success := FND_REQUEST.add_layout(l_app_short_name,l_template_code,l_default_lang,l_default_territory,'PDF');
    ELSIF p_output_format = 'EXCEL' or p_output_format ='CSV' THEN
       success := FND_REQUEST.add_layout(l_app_short_name,l_template_code,l_default_lang,l_default_territory,'EXCEL');
    ELSIF p_output_format = 'RTF' THEN
       success := FND_REQUEST.add_layout(l_app_short_name,l_template_code,l_default_lang,l_default_territory,'RTF');
    END IF;

    if ( not success ) then
       hr_utility.set_location('XML submit fail' ,50);
       raise submit_failed;
    ELSE
       hr_utility.set_location('XML submit success' ,50);
    end if;

     l_request_id := FND_REQUEST.submit_request(
	  'PQP'
	  ,'PQPRPEXR'
	  ,NULL
	  ,NULL
          ,NULL
	  ,p_ppa_finder
          ,NULL
          ,p_business_group_id
          ,p_request_name    --Select Report or Group
          ,l_grp_request_code--'EG' if exception group else NULL
          ,p_exception_grp_name
          ,l_rep_request_code --p_rep_request_code--'ER' if exception group else NULL
          ,l_exception_report_id
          ,l_variance_type
          ,p_variance_value
          ,p_payroll_id
          ,p_consolidation_set_id
          ,p_effective_date--fnd_date.date_to_canonical(p_effective_date)
          );

  hr_utility.set_location('Current  l_request_id:'||l_request_id, 80);
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
   when submit_failed THEN
     hr_utility.set_location('error Leaving:'||l_proc, 80);
     raise;
   when others then
     hr_utility.set_location(' error Leaving:'||l_proc, 80);
     raise;
end exception_report_xml_process;


end pqp_exr_swi;

/
