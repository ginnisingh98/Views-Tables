--------------------------------------------------------
--  DDL for Package Body BEN_CREATE_PTNL_LER_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CREATE_PTNL_LER_SS" AS
/* $Header: belerwrs.pkb 120.0 2005/05/28 03:22:21 appldev noship $*/

  -- Package scope global variables.

 g_package   varchar2(31)   := 'BEN_CREATE_PTNL_LER_SS';
 g_api_name  varchar2(72):= g_package||'.PROCESS_API';
 g_data_error   exception;




 --This is an overloaded procedure which will call the actual procedure
 PROCEDURE create_ptnl_ler_for_per
    (p_validate                       in  varchar2  default 'N'
    ,p_ptnl_ler_for_per_id            out nocopy varchar2
    ,p_csd_by_ptnl_ler_for_per_id     in  varchar2  default null
    ,p_lf_evt_ocrd_dt                 in out nocopy varchar2
    ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
    ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
    ,p_mnl_dt                         in  varchar2  default null
    ,p_enrt_perd_id                   in  varchar2  default null
    ,p_ler_id                         in  varchar2  default null
    ,p_person_id                      in  varchar2  default null
    ,p_business_group_id              in  varchar2  default null
    ,p_dtctd_dt                       in  varchar2  default null
    ,p_procd_dt                       in  varchar2  default null
    ,p_unprocd_dt                     in  varchar2  default null
    ,p_voidd_dt                       in  varchar2  default null
    ,p_mnlo_dt                        in  varchar2  default null
    ,p_ntfn_dt                        in  varchar2  default null
    ,p_request_id                     in  varchar2  default null
    ,p_program_application_id         in  varchar2  default null
    ,p_program_id                     in  varchar2  default null
    ,p_program_update_date            in  varchar2  default null
    ,p_object_version_number          out nocopy varchar2
    ,p_effective_date                 in  varchar2
    ,p_item_type                      in  varchar2
    ,p_item_key                       in  varchar2
    ,p_activity_id                    in  varchar2
    ,p_login_person_id                in  varchar2  default null
    ,P_flow_mode                      in  varchar2
    ,p_subflow_mode                   in  varchar2
    ,p_life_event_name                in  varchar2
    ,p_transaction_step_id            out nocopy varchar2
    ,p_error_message                  out nocopy long
    ,p_hire_dt                        in  varchar2  default null
) is

    l_ptnl_ler_for_per_id ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type := to_number(p_ptnl_ler_for_per_id);
    l_object_version_number ben_ptnl_ler_for_per.object_version_number%type := to_number(p_object_version_number);
    l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type := to_number(p_transaction_step_id);
    l_lf_evt_ocrd_date date;
    l_ocrd_dt_cd hr_lookups.lookup_code%TYPE; -- UTF8   varchar2(30);

    cursor get_ler is
    select ler.ocrd_dt_det_cd
    from ben_ler_f ler
    where  ler.business_group_id = to_number(p_business_group_id)
    and ler.ler_id = to_number(p_ler_id)
    and to_date(p_effective_date,hr_transaction_ss.g_date_format)
        between ler.effective_start_date
        and     ler.effective_end_date;
BEGIN
-- CALL THE ACTUAL PROCEDURE HERE
  /************cobra change********************/
--
  if p_hire_dt is not null then

     if (to_date(p_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format) <=
     to_date(p_hire_dt,hr_transaction_ss.g_date_format)) then
        p_lf_evt_ocrd_dt := p_hire_dt;
     end if;
  end if;
  open get_ler;
  fetch get_ler into l_ocrd_dt_cd;
  if get_ler%found then
     if l_ocrd_dt_cd is not null then
        ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => to_date(p_effective_date,hr_transaction_ss.g_date_format)
        ,p_lf_evt_ocrd_dt  => to_date(p_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format)
        ,p_returned_date   => l_lf_evt_ocrd_date
        );
      else
        l_lf_evt_ocrd_date := to_date(p_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format);
      end if;
   else
      l_lf_evt_ocrd_date := to_date(p_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format);
   end if;
 /********************************************/
      --l_lf_evt_ocrd_date := to_date(p_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format);
-- Replace the strings by date and number where required
    create_ptnl_ler_for_per
    (p_validate                      => p_validate                                                  -- in  varchar2  default 'N'
    ,p_ptnl_ler_for_per_id           => l_ptnl_ler_for_per_id                                       -- out number
    ,p_csd_by_ptnl_ler_for_per_id    => to_number(p_csd_by_ptnl_ler_for_per_id)                     -- in  number    default null
    ,p_lf_evt_ocrd_dt                => l_lf_evt_ocrd_date                                          -- in  date      default null
    ,p_ptnl_ler_for_per_stat_cd      => p_ptnl_ler_for_per_stat_cd                                  -- in  varchar2  default null
    ,p_ptnl_ler_for_per_src_cd       => p_ptnl_ler_for_per_src_cd                                   -- in  varchar2  default null
    ,p_mnl_dt                        => to_date(p_mnl_dt,hr_transaction_ss.g_date_format)           -- in  date      default null
    ,p_enrt_perd_id                  => to_number(p_enrt_perd_id)                                   -- in  number    default null
    ,p_ler_id                        => to_number(p_ler_id)                                         -- in  number    default null
    ,p_person_id                     => to_number(p_person_id)                                      -- in  number    default null
    ,p_business_group_id             => to_number(p_business_group_id)                              -- in  number
    ,p_dtctd_dt                      => to_date(p_dtctd_dt,hr_transaction_ss.g_date_format)         -- in  date      default null
    ,p_procd_dt                      => to_date(p_procd_dt,hr_transaction_ss.g_date_format)         -- in  date      default null
    ,p_unprocd_dt                    => to_date(p_unprocd_dt,hr_transaction_ss.g_date_format)       -- in  date      default null
    ,p_voidd_dt                      => to_date(p_voidd_dt,hr_transaction_ss.g_date_format)         -- in  date      default null
    ,p_mnlo_dt                       => to_date(p_mnlo_dt,hr_transaction_ss.g_date_format)          -- in  date      default null
    ,p_ntfn_dt                       => to_date(p_ntfn_dt,hr_transaction_ss.g_date_format)          -- in  date      default null
    ,p_request_id                    => to_number(p_request_id)                                     -- in  number      default null
    ,p_program_application_id        => to_number(p_program_application_id)                         -- in  number      default null
    ,p_program_id                    => to_number(p_program_id)                                     -- in  number      default null
    ,p_program_update_date           => to_date(p_program_update_date,hr_transaction_ss.g_date_format) -- in  date      default null
    ,p_object_version_number         => l_object_version_number                                      --out number
    ,p_effective_date                => to_date(p_effective_date,hr_transaction_ss.g_date_format)    -- in  date
    ,p_item_type                     => p_item_type                                                  -- in  varchar2
    ,p_item_key                      => p_item_key                                                   -- in  varchar2
    ,p_activity_id                   => to_number(p_activity_id)                                     -- in  number
    ,p_login_person_id               => to_number(p_login_person_id)                                 -- in     number default null
    ,P_flow_mode                     => P_flow_mode                                                  -- in  varchar2 -- This may have a value of Insert, Update
    ,p_subflow_mode                  => p_subflow_mode                                               -- in  varchar2
    ,p_life_event_name               => p_life_event_name                                            -- in  varchar2
    ,p_transaction_step_id           => l_transaction_step_id                                        -- out number
    ,p_error_message                 => p_error_message                                              -- out long
    );
    -- assign the out parameters
     p_ptnl_ler_for_per_id :=  to_char(l_ptnl_ler_for_per_id);
     p_object_version_number:= to_char(l_object_version_number);
     p_transaction_step_id :=  to_char(l_transaction_step_id);
     p_lf_evt_ocrd_dt := to_char(l_lf_evt_ocrd_date,hr_transaction_ss.g_date_format);
    --
EXCEPTION
 when others then
  raise;
END  create_ptnl_ler_for_per;

  PROCEDURE create_ptnl_ler_for_per
    (p_validate                       in  varchar2  default 'N'
    ,p_ptnl_ler_for_per_id            out nocopy number
    ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
    ,p_lf_evt_ocrd_dt                 in  date      default null
    ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
    ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
    ,p_mnl_dt                         in  date      default null
    ,p_enrt_perd_id                   in  number    default null
    ,p_ler_id                         in  number    default null
    ,p_person_id                      in  number    default null
    ,p_business_group_id              in  number
    ,p_dtctd_dt                       in  date      default null
    ,p_procd_dt                       in  date      default null
    ,p_unprocd_dt                     in  date      default null
    ,p_voidd_dt                       in  date      default null
    ,p_mnlo_dt                        in  date      default null
    ,p_ntfn_dt                        in  date      default null
    ,p_request_id                     in  number    default null
    ,p_program_application_id         in  number    default null
    ,p_program_id                     in  number    default null
    ,p_program_update_date            in  date      default null
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_item_type                      in  varchar2
    ,p_item_key                       in  varchar2
    ,p_activity_id                    in  number
    ,p_login_person_id                in     number default null
    ,P_flow_mode                      in  varchar2 -- This may have a value of Insert, Update
    ,p_subflow_mode                   in  varchar2  -- This may have a value of Insert and Cobra
    ,p_life_event_name                in  varchar2
    ,p_transaction_step_id            out nocopy number
    ,p_error_message                  out nocopy long
    ) IS

    --declare a cursor to check if the person actually exists in the database
    cursor csr_person is select person_id from per_all_people_f where person_id = p_person_id;


    l_transaction_table hr_transaction_ss.transaction_table;
    l_count INTEGER := 0;
    l_transaction_id hr_api_transaction_steps.transaction_id%type default null;
    l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
    l_trans_object_version_number  hr_api_transaction_steps.object_version_number%type;

   -- variable for the create person call
    l_original_person_id per_all_people_f.person_id%type;
    l_review_item_name           varchar2(50);
    l_result                     varchar2(100) default null;
    l_person_id              per_all_people_f.person_id%type := p_person_id;
    l_object_version_number  per_all_people_f.object_version_number%type ;
    l_effective_start_date   date;
    l_effective_end_date     date ;
    l_full_name              per_all_people_f.full_name%type;
    l_comment_id             number;
    l_name_combination_warning  boolean ;
    l_orig_hire_warning boolean ;
    l_proc varchar2(72)  := g_package||'CREATE_PTNL_LER_FOR_PER';
  -- dummy variables
    l_dummy_num  number;
    l_dummy_date date;
    l_dummy_char varchar2(1000);
    l_dummy_bool boolean;

  BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 5);


    -- Call the actual API.
    --
    -- In case the person Id doesn't exists in the database
    -- we need to do the validation there are three cases.
    -- 1) The person actually exists in database( Page invoked from menu)
    -- 2) The page is being used in normal registration flow ( one row in Transaction table)
    -- 3) The page is being used in Cobra registration flow( Two rows in transaction tables)
    --
   savepoint create_life_event;
    open csr_person;
    fetch csr_person into l_original_person_id;
    if csr_person%notfound then
   hr_contact_api.create_person
  (p_validate                      => false
  ,p_start_date                    => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => 'XcXXXXX'-- can hard code it is not going to be committed
  ,p_sex                           => 'M'
  ,p_person_id                     =>  l_person_id
  ,p_object_version_number         =>  l_object_version_number
  ,p_effective_start_date          =>  l_effective_start_date
  ,p_effective_end_date            =>  l_effective_end_date
  ,p_full_name                     =>  l_full_name
  ,p_comment_id                    =>  l_comment_id
  ,p_name_combination_warning      =>  l_name_combination_warning
  ,p_orig_hire_warning             =>  l_orig_hire_warning
  );
    end if;
    close csr_person;

  --  We should have a value for l_person_id by now
  if (l_person_id is not null ) then
       --
       -- call the api to create potential life event

  ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
  (p_validate                     =>  true
  ,p_ptnl_ler_for_per_id          =>  l_dummy_num                    -- out number
  ,p_csd_by_ptnl_ler_for_per_id   =>  p_csd_by_ptnl_ler_for_per_id   -- in  number    default null
  ,p_lf_evt_ocrd_dt               =>  p_lf_evt_ocrd_dt               -- in  date      default null
  ,p_ptnl_ler_for_per_stat_cd     =>  p_ptnl_ler_for_per_stat_cd     -- in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd      =>  p_ptnl_ler_for_per_src_cd      -- in  varchar2  default null
  ,p_mnl_dt                       =>  p_mnl_dt                       -- in  date      default null
  ,p_enrt_perd_id                 =>  p_enrt_perd_id                 -- in  number    default null
  ,p_ler_id                       =>  p_ler_id                       -- in  number    default null
  ,p_person_id                    =>  l_person_id                    -- in  number    default null
  ,p_business_group_id            =>  p_business_group_id            -- in  number    default null
  ,p_dtctd_dt                     =>  p_dtctd_dt                     -- in  date      default null
  ,p_procd_dt                     =>  p_procd_dt                     -- in  date      default null
  ,p_unprocd_dt                   =>  p_unprocd_dt                   -- in  date      default null
  ,p_voidd_dt                     =>  p_voidd_dt                     -- in  date      default null
  ,p_mnlo_dt                      =>  p_mnlo_dt                      -- in  date      default null
  ,p_ntfn_dt                      =>  p_ntfn_dt                      -- in  date      default null
  ,p_request_id                   =>  p_request_id                   -- in  number    default null
  ,p_program_application_id       =>  p_program_application_id       -- in  number    default null
  ,p_program_id                   =>  p_program_id                   -- in  number    default null
  ,p_program_update_date          =>  p_program_update_date          -- in  date      default null
  ,p_object_version_number        =>  p_object_version_number        -- out number
  ,p_effective_date               =>  p_effective_date               --in  date
  );
 end if;


 --  Now rollback all the changes which have been made.
 --
 ROLLBACK to create_life_event;
 --
 -- -----------------------------------------------------------------------------
 -- We will write the data to transaction tables.
 -- Determine if a transaction step exists for this activity
 -- if a transaction step does exist then the transaction_step_id and
 -- object_version_number are set (i.e. not null).
 -- -----------------------------------------------------------------------------
 --
       --
       -- First, check if transaction id exists or not
       --
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
           ,p_login_person_id => nvl(p_login_person_id, p_person_id) -- PB : Modification
           ,result     => l_result);

           -- need to take care of l_result

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
       ELSE
       -- since transaction id is present look for the step if it already exists
         get_step(p_item_type   => p_item_type
                 ,p_item_key    => p_item_key
                 ,p_activity_id => p_activity_id
                 ,p_api_name    => g_api_name
                 ,p_flow_mode   => p_flow_mode
                 ,p_subflow_mode=> p_subflow_mode
                 ,p_transaction_step_id =>  l_transaction_step_id
                 ,p_object_version_number => l_trans_object_version_number);

       END IF;
       -- if l_transaction_step_id is null then create a transaction step Id
       -- otherwise just update the current step
       if(  l_transaction_step_id is null) then
       -- Create a transaction step
       --
       hr_transaction_api.create_transaction_step
           (p_validate              => false
           ,p_creator_person_id     => nvl(p_login_person_id, p_person_id) -- PB : Modification
           ,p_transaction_id        => l_transaction_id
           ,p_api_name              => g_package || '.PROCESS_API'
           ,p_item_type             => p_item_type
           ,p_item_key              => p_item_key
           ,p_activity_id           => p_activity_id
           ,p_transaction_step_id   => l_transaction_step_id
           ,p_object_version_number => l_trans_object_version_number);

        end if;
        --


	l_count := 1;
 	l_transaction_table(l_count).param_name := 'P_CSD_BY_PTNL_LER_FOR_PER_ID';
 	l_transaction_table(l_count).param_value := p_csd_by_ptnl_ler_for_per_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';


	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_LF_EVT_OCRD_DT';
 	l_transaction_table(l_count).param_value := to_char(p_lf_evt_ocrd_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';


 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name	:= 'P_PTNL_LER_FOR_PER_STAT_CD';
 	l_transaction_table(l_count).param_value := p_ptnl_ler_for_per_stat_cd;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PTNL_LER_FOR_PER_SRC_CD';
 	l_transaction_table(l_count).param_value := p_ptnl_ler_for_per_src_cd;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';


 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_MNL_DT';
 	l_transaction_table(l_count).param_value := to_char(p_mnl_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ENRT_PERD_ID';
 	l_transaction_table(l_count).param_value := p_enrt_perd_id;
   	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_LER_ID';
 	l_transaction_table(l_count).param_value := p_ler_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PERSON_ID';
 	l_transaction_table(l_count).param_value := p_person_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
 	l_transaction_table(l_count).param_value := p_business_group_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_DTCTD_DT';
 	l_transaction_table(l_count).param_value := to_char(p_dtctd_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PROCD_DT';
 	l_transaction_table(l_count).param_value := to_char(p_procd_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_UNPROCD_DT';
 	l_transaction_table(l_count).param_value := to_char(p_unprocd_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_VOIDD_DT';
	l_transaction_table(l_count).param_value := to_char(p_voidd_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_MNLO_DT';
 	l_transaction_table(l_count).param_value := to_char(p_mnlo_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_NTFN_DT';
 	l_transaction_table(l_count).param_value := to_char(p_ntfn_dt,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_REQUEST_ID';
 	l_transaction_table(l_count).param_value := p_request_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PROGRAM_APPLICATION_ID';
 	l_transaction_table(l_count).param_value := p_program_application_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';


 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PROGRAM_ID';
 	l_transaction_table(l_count).param_value := p_program_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PROGRAM_UPDATE_DATE';
 	l_transaction_table(l_count).param_value := to_char(p_program_update_date,
                                                    hr_transaction_ss.g_date_format);
    l_transaction_table(l_count).param_data_type := 'DATE';


    l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
 	l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                                    hr_transaction_ss.g_date_format);
 	l_transaction_table(l_count).param_data_type := 'DATE';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
        l_transaction_table(l_count).param_value := p_item_type;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
        l_transaction_table(l_count).param_value := p_item_key;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
        l_transaction_table(l_count).param_value := p_activity_id;
        l_transaction_table(l_count).param_data_type := 'NUMBER';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
        l_transaction_table(l_count).param_value := p_login_person_id;
        l_transaction_table(l_count).param_data_type := 'NUMBER';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_FLOW_MODE';
        l_transaction_table(l_count).param_value := p_flow_mode;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_SUBFLOW_MODE';
        l_transaction_table(l_count).param_value := p_subflow_mode;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_LIFE_EVENT_NAME';
        l_transaction_table(l_count).param_value := p_life_event_name;
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


	 hr_transaction_ss.save_transaction_step
       		(p_item_type => p_item_type
       		,p_item_key => p_item_key
       		,p_actid => p_activity_id
            ,p_login_person_id => nvl(p_login_person_id, p_person_id) -- PB Modification
            ,p_transaction_step_id => l_transaction_step_id
       		,p_api_name => g_api_name
       		,p_transaction_data => l_transaction_table);
    -- put the out parameter for transaction step
    -- This will be null if any error is raised in processing.
    p_transaction_step_id :=  l_transaction_step_id;

    if p_subflow_mode = 'COBRA' then
      wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'LIFE_EVENT_TRANSACTION_STEP',
                           avalue   => to_char(l_transaction_step_id));
   end if;


     hr_utility.set_location('Leaving:'|| l_proc, 10);


   EXCEPTION
    WHEN OTHERS THEN
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
    raise;
  END create_ptnl_ler_for_per;




-- ---------------------------------------------------------------------------
-- ---------------------- < get_ptnl_ler_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
--
PROCEDURE get_ptnl_ler_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_csd_by_ptnl_ler_for_per_id      out nocopy number    -- in  number    default null
   ,p_lf_evt_ocrd_dt                  out nocopy date      -- in  date      default null
   ,p_ptnl_ler_for_per_stat_cd        out nocopy varchar2  -- in  varchar2  default null
   ,p_ptnl_ler_for_per_src_cd         out nocopy varchar2  -- in  varchar2  default null
   ,p_mnl_dt                          out nocopy date      -- in  date      default null
   ,p_enrt_perd_id                    out nocopy number    -- in  number    default null
   ,p_ler_id                          out nocopy number    -- in  number    default null
   ,p_person_id                       out nocopy number    -- in  number    default null
   ,p_business_group_id               out nocopy number    -- in  number    default null
   ,p_dtctd_dt                        out nocopy date      -- in  date      default null
   ,p_procd_dt                        out nocopy date      -- in  date      default null
   ,p_unprocd_dt                      out nocopy date      -- in  date      default null
   ,p_voidd_dt                        out nocopy date      -- in  date      default null
   ,p_mnlo_dt                         out nocopy date      -- in  date      default null
   ,p_ntfn_dt                         out nocopy date      -- in  date      default null
   ,p_request_id                      out nocopy number    -- in  number    default null
   ,p_program_application_id          out nocopy number    -- in  number    default null
   ,p_program_id                      out nocopy number    -- in  number    default null
   ,p_program_update_date             out nocopy date      -- in  date      default null
   ,p_effective_date                  out nocopy date
   ,p_flow_mode                       in varchar2
   ,p_subflow_mode                    in varchar2
   ,p_life_event_name                 out nocopy varchar2
) is
   l_transaction_id hr_api_transaction_steps.transaction_id%type default null;
   l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
   l_trans_object_version_number  hr_api_transaction_steps.object_version_number%type;
   l_proc varchar2(72)  := g_package||'.GET_PTNL_LER_DATA_FROM_TT';


 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 5);

 --
 -- This call will get us the step Id for the Api name passed in
 -- and the subflow mode passed in

  get_step(p_item_type           => p_item_type
      ,p_item_key                => p_item_key
      ,p_activity_id             => p_activity_id
      ,p_api_name                => g_api_name
      ,p_flow_mode               => p_flow_mode
      ,p_subflow_mode            => p_subflow_mode
      ,p_transaction_step_id     => l_transaction_step_id
      ,p_object_version_number   => l_trans_object_version_number);
  --
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
  get_ptnl_ler_data_from_tt
   (p_transaction_step_id             => l_transaction_step_id
   ,p_csd_by_ptnl_ler_for_per_id      => p_csd_by_ptnl_ler_for_per_id
   ,p_lf_evt_ocrd_dt                  => p_lf_evt_ocrd_dt
   ,p_ptnl_ler_for_per_stat_cd        => p_ptnl_ler_for_per_stat_cd
   ,p_ptnl_ler_for_per_src_cd         => p_ptnl_ler_for_per_src_cd
   ,p_mnl_dt                          => p_mnl_dt
   ,p_enrt_perd_id                    => p_enrt_perd_id
   ,p_ler_id                          => p_ler_id
   ,p_person_id                       => p_person_id
   ,p_business_group_id               => p_business_group_id
   ,p_dtctd_dt                        => p_dtctd_dt
   ,p_procd_dt                        => p_procd_dt
   ,p_unprocd_dt                      => p_unprocd_dt
   ,p_voidd_dt                        => p_voidd_dt
   ,p_mnlo_dt                         => p_mnlo_dt
   ,p_ntfn_dt                         => p_ntfn_dt
   ,p_request_id                      => p_request_id
   ,p_program_application_id          => p_program_application_id
   ,p_program_id                      => p_program_id
   ,p_program_update_date             => p_program_update_date
   ,p_effective_date                  => p_effective_date
   ,p_flow_mode                       => p_flow_mode
   ,p_subflow_mode                    => p_subflow_mode
   ,p_life_event_name                 => p_life_event_name
);



 hr_utility.set_location('Leaving:'|| l_proc, 10);

EXCEPTION
   WHEN g_data_error THEN
      RAISE;

END get_ptnl_ler_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_ptnl_ler_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------
--
procedure get_ptnl_ler_data_from_tt
   (p_transaction_step_id             in  number
   ,p_csd_by_ptnl_ler_for_per_id      out nocopy number    -- in  number    default null
   ,p_lf_evt_ocrd_dt                  out nocopy date      -- in  date      default null
   ,p_ptnl_ler_for_per_stat_cd        out nocopy varchar2  -- in  varchar2  default null
   ,p_ptnl_ler_for_per_src_cd         out nocopy varchar2  -- in  varchar2  default null
   ,p_mnl_dt                          out nocopy date      -- in  date      default null
   ,p_enrt_perd_id                    out nocopy number    -- in  number    default null
   ,p_ler_id                          out nocopy number    -- in  number    default null
   ,p_person_id                       out nocopy number    -- in  number    default null
   ,p_business_group_id               out nocopy number    -- in  number    default null
   ,p_dtctd_dt                        out nocopy date      -- in  date      default null
   ,p_procd_dt                        out nocopy date      -- in  date      default null
   ,p_unprocd_dt                      out nocopy date      -- in  date      default null
   ,p_voidd_dt                        out nocopy date      -- in  date      default null
   ,p_mnlo_dt                         out nocopy date      -- in  date      default null
   ,p_ntfn_dt                         out nocopy date      -- in  date      default null
   ,p_request_id                      out nocopy number    -- in  number    default null
   ,p_program_application_id          out nocopy number    -- in  number    default null
   ,p_program_id                      out nocopy number    -- in  number    default null
   ,p_program_update_date             out nocopy date      -- in  date      default null
   ,p_effective_date                  out nocopy date
   ,p_flow_mode                       in varchar2
   ,p_subflow_mode                    in varchar2
   ,p_life_event_name                 out nocopy varchar2
)is
l_proc varchar2(72)  := g_package||'GET_PTNL_LER_DATA_FROM_TT';

begin
hr_utility.set_location('Entering:'|| l_proc, 5);

--
  p_csd_by_ptnl_ler_for_per_id:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CSD_BY_PTNL_LER_FOR_PER_ID');
--
  p_lf_evt_ocrd_dt := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LF_EVT_OCRD_DT');
--
  p_ptnl_ler_for_per_stat_cd := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PTNL_LER_FOR_PER_STAT_CD');
--
  p_ptnl_ler_for_per_src_cd := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_PTNL_LER_FOR_PER_SRC_CD');
--
  p_mnl_dt := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MNL_DT');
--
  p_enrt_perd_id  := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ENRT_PERD_ID');

--
  p_ler_id :=  hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LER_ID');
--
  p_person_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
--
  p_business_group_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
  p_dtctd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DTCTD_DT');


  p_procd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROCD_DT');
--
  p_unprocd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_UNPROCD_DT');
--
  p_voidd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VOIDD_DT');
--
  p_mnlo_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MNLO_DT');
--
  p_ntfn_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTFN_DT');
--
  p_request_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REQUEST_ID');
--
  p_program_application_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_APPLICATION_ID');
--
  p_program_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_ID');
--
  p_program_update_date :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_UPDATE_DATE');
--
  p_effective_date :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');

--
/*
  p_flow_mode :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FLOW_MODE');

--
  p_subflow_mode :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUBFLOW_MODE');

*/
--
  p_life_event_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LIFE_EVENT_NAME');

    hr_utility.set_location('Leaving:'|| l_proc, 10);
--


EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END get_ptnl_ler_data_from_tt;

/*----------------------------------------------------------------------------
|                                                                            |
|       Name           : process_api                                         |
|                                                                            |
|       Purpose        : This will procedure is invoked whenever approver    |
|                        approves the address change.                        |
|                                                                            |
-----------------------------------------------------------------------------*/
--
PROCEDURE process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
)is

l_validate BOOLEAN := false;
l_dummy_num number;
l_effective_date date;
l_ovn NUMBER;
l_ptnl_ler ben_ptnl_ler_for_per%ROWTYPE;
l_proc varchar2(72)  := g_package||'PROCESS_API';

BEGIN

hr_utility.set_location('Entering:'|| l_proc, 5);

--
  if p_validate is not null then
  l_validate :=  p_validate;
  end if;

-- Get the data from the transaction tables.

  -- This may be a New user registration / Cobra Registration and we may not
  -- have a person in the database.
 if (( hr_process_person_ss.g_person_id is not null) and
                              (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
       l_ptnl_ler.person_id := hr_process_person_ss.g_person_id;
 end if;
--
 if l_ptnl_ler.person_id is null then
  l_ptnl_ler.person_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
 end if;

 if l_ptnl_ler.person_id is null then
  null;
 else
--
 l_ptnl_ler.csd_by_ptnl_ler_for_per_id:= hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CSD_BY_PTNL_LER_FOR_PER_ID');
--
  l_ptnl_ler.lf_evt_ocrd_dt := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LF_EVT_OCRD_DT');
--
  l_ptnl_ler.ptnl_ler_for_per_stat_cd := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PTNL_LER_FOR_PER_STAT_CD');
--
  l_ptnl_ler.ptnl_ler_for_per_src_cd := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_PTNL_LER_FOR_PER_SRC_CD');
--
  l_ptnl_ler.mnl_dt := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MNL_DT');
--
  l_ptnl_ler.enrt_perd_id  := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ENRT_PERD_ID');

--
  l_ptnl_ler.ler_id :=  hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LER_ID');
--
  l_ptnl_ler.business_group_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
  l_ptnl_ler.dtctd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DTCTD_DT');


  l_ptnl_ler.procd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROCD_DT');
--
  l_ptnl_ler.unprocd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_UNPROCD_DT');
--
  l_ptnl_ler.voidd_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VOIDD_DT');
--
  l_ptnl_ler.mnlo_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MNLO_DT');
--
  l_ptnl_ler.ntfn_dt :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NTFN_DT');
--
  l_ptnl_ler.request_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REQUEST_ID');
--
  l_ptnl_ler.program_application_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_APPLICATION_ID');
--
  l_ptnl_ler.program_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_ID');
--
  l_ptnl_ler.program_update_date :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROGRAM_UPDATE_DATE');
--
  l_effective_date :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');

--
-- These two can be removed if not used in the future.
/*
  l_ptnl_ler.p_flow_mode :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FLOW_MODE');
--
  l_ptnl_ler.p_life_event_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LIFE_EVENT_NAME');
*/

  -- This may be a New user registration / Cobra Registration and we may not
  -- have a person in the database.
    /*if (( hr_process_person_ss.g_person_id is not null) and
                              (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
       l_ptnl_ler.person_id := hr_process_person_ss.g_person_id;
    end if;*/


   ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
  (p_validate                     =>  l_validate
  ,p_ptnl_ler_for_per_id          =>  l_dummy_num                               -- out number
  ,p_csd_by_ptnl_ler_for_per_id   =>  l_ptnl_ler.csd_by_ptnl_ler_for_per_id   -- in  number    default null
  ,p_lf_evt_ocrd_dt               =>  l_ptnl_ler.lf_evt_ocrd_dt               -- in  date      default null
  ,p_ptnl_ler_for_per_stat_cd     =>  l_ptnl_ler.ptnl_ler_for_per_stat_cd     -- in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd      =>  l_ptnl_ler.ptnl_ler_for_per_src_cd      -- in  varchar2  default null
  ,p_mnl_dt                       =>  l_ptnl_ler.mnl_dt                       -- in  date      default null
  ,p_enrt_perd_id                 =>  l_ptnl_ler.enrt_perd_id                 -- in  number    default null
  ,p_ler_id                       =>  l_ptnl_ler.ler_id                       -- in  number    default null
  ,p_person_id                    =>  l_ptnl_ler.person_id                    -- in  number    default null
  ,p_business_group_id            =>  l_ptnl_ler.business_group_id            -- in  number    default null
  ,p_dtctd_dt                     =>  l_ptnl_ler.dtctd_dt                     -- in  date      default null
  ,p_procd_dt                     =>  l_ptnl_ler.procd_dt                     -- in  date      default null
  ,p_unprocd_dt                   =>  l_ptnl_ler.unprocd_dt                   -- in  date      default null
  ,p_voidd_dt                     =>  l_ptnl_ler.voidd_dt                     -- in  date      default null
  ,p_mnlo_dt                      =>  l_ptnl_ler.mnlo_dt                      -- in  date      default null
  ,p_ntfn_dt                      =>  l_ptnl_ler.ntfn_dt                      -- in  date      default null
  ,p_request_id                   =>  l_ptnl_ler.request_id                   -- in  number    default null
  ,p_program_application_id       =>  l_ptnl_ler.program_application_id       -- in  number    default null
  ,p_program_id                   =>  l_ptnl_ler.program_id                   -- in  number    default null
  ,p_program_update_date          =>  l_ptnl_ler.program_update_date          -- in  date      default null
  ,p_object_version_number        =>  l_ovn                                     -- out number
  ,p_effective_date               =>  l_effective_date               --in  date
  );
 end if;

 hr_utility.set_location('Leaving:'|| l_proc, 10);

END process_api;

procedure get_step(
     p_item_type                in     varchar2
    ,p_item_key                 in     varchar2
    ,p_activity_id              in     varchar2
    ,p_api_name                 in     varchar2
    ,p_flow_mode                in     varchar2
    ,p_subflow_mode             in     varchar2
    ,p_transaction_step_id      out nocopy number
    ,p_object_version_number    out nocopy number
     ) is
/* This procedure gets the transaction_step_id based on a given item_type and
   item_key
*/
--
cursor transaction_step is
select transaction_step_id
,      object_version_number
from hr_api_transaction_steps
where item_type=p_item_type
and   item_key=p_item_key
--and   activity_id = p_activity_id --because when this is called from review page the activity id is different
and   api_name=p_api_name;
--
l_subflow_mode varchar2(31);
begin
   open transaction_step;
   fetch transaction_step into p_transaction_step_id,p_object_version_number;

   -- check if the step exists for the particular subflow
      loop
       l_subflow_mode :=
              hr_transaction_api.get_varchar2_value
              (p_transaction_step_id => p_transaction_step_id
              ,p_name                => 'P_SUBFLOW_MODE');
       exit when l_subflow_mode =  p_subflow_mode ;
       fetch transaction_step into p_transaction_step_id,p_object_version_number;
       if transaction_step%notfound then
         p_transaction_step_id:=null;
         p_object_version_number:=null;
         exit;

       end if;

     end loop;
   --  if no step is present it will return null for the step_id and transaction id otherwise
   --  the step_id and transaction_id will be returned for the subflow_mode

  close transaction_step;
end get_step;


END ben_create_ptnl_ler_ss;

/
