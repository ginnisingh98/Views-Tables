--------------------------------------------------------
--  DDL for Package Body JTF_RS_RES_SSWA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RES_SSWA_PUB" AS
  /* $Header: jtfrssrb.pls 120.1 2005/06/07 23:06:15 baianand ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RES_SSWA_PUB';

PROCEDURE create_emp_resource
 (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SOURCE_FIRST_NAME    IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_LAST_NAME     IN   VARCHAR2,
   P_SOURCE_MIDDLE_NAME   IN   VARCHAR2   DEFAULT NULL,
   P_EMPLOYEE_NUMBER      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_SEX           IN   VARCHAR2,
   P_SOURCE_TITLE         IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_JOB_ID        IN   NUMBER  DEFAULT NULL,
   P_SOURCE_EMAIL         IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_START_DATE    IN   DATE,
   P_SOURCE_END_DATE      IN   DATE   DEFAULT NULL,
   P_USER_NAME            IN   VARCHAR2,
   P_SOURCE_ADDRESS_ID    IN   NUMBER   DEFAULT NULL,
   P_SOURCE_OFFICE        IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_MAILSTOP      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_LOCATION      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_PHONE         IN   VARCHAR2   DEFAULT NULL,
   P_SALESREP_NUMBER      IN   VARCHAR2,
   P_SALES_CREDIT_TYPE_ID IN   NUMBER,
   P_SOURCE_MGR_ID        IN   NUMBER   DEFAULT NULL,   /* This is the Resource_id of the manager */
   X_RESOURCE_ID          OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   P_CALLED_FROM          IN   VARCHAR2   DEFAULT NULL,
   P_USER_PASSWORD        IN OUT NOCOPY VARCHAR2
  ) IS

    l_api_version         constant number := 1.0;
    l_api_name            constant varchar2(30) := 'CREATE_EMP_RESOURCE';
    l_return_status       varchar2(100) := fnd_api.g_ret_sts_success;
    l_address_id          number := to_number(p_source_address_id);
    l_job_id              number := p_source_job_id;
    l_source_mailstop     jtf_rs_resource_extns.source_mailstop%type := p_source_mailstop;
    l_source_office       jtf_rs_resource_extns.source_office%type := p_source_office;
    l_source_location     jtf_rs_resource_extns.source_location%type := p_source_location;
    l_source_email        jtf_rs_resource_extns.source_email%type := p_source_email;
    l_source_phone        jtf_rs_resource_extns.source_phone%type := p_source_phone;
    l_business_group_id   per_all_people_f.business_group_id%type;
    l_user_name           fnd_user.user_name%type := upper(p_user_name);
    l_user_password       fnd_user.encrypted_user_password%type := p_user_password;
    l_salesrep_number     jtf_rs_salesreps.salesrep_number%type := p_salesrep_number;
    /* Out Parameters  for Create Employee*/

    l_person_id                      number;
    l_assignment_id                  number;
    l_per_object_version_number      number;
    l_asg_object_version_number      number;
    l_per_effective_start_date       date;
    l_per_effective_end_date         date;
    l_full_name                      varchar2(2000) ;
    l_employee_number                varchar2(2000);
    l_per_comment_id                 number;
    l_assignment_sequence            number;
    l_assignment_number              varchar2(250);
    l_name_combination_warning       boolean;
    l_assign_payroll_warning         boolean;
    l_orig_hire_warning              boolean;

    /* Out Parameters  for Create Phone*/

    l_object_version_number_phone    number;
    l_phone_id                       number;

    /* Out Parameters  for Create Resource*/

    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_resource_id         number;
    l_resource_number     varchar2(2000);

    /* Out Parameters  for Create Resource*/

    l_salesrep_id         number;

    /* Cursor  Variables to get Addres Deatils */

    cursor address_cur(l_address_id number)
    is
    select  address_line_1,
            address_line_2,
            address_line_3 ,
            town_or_city ,
            country,
            postal_code
    from    hr_locations
    where   location_id = l_address_id;

    l_address_line_1      hr_locations.address_line_1%type;
    l_address_line_2      hr_locations.address_line_2%type;
    l_address_line_3      hr_locations.address_line_3%type;
    l_town_or_city        hr_locations.town_or_city%type;
    l_country             hr_locations.country%type;
    l_postal_code         hr_locations.postal_code%type;
--    address_rec address_cur%rowtype;

    /* Cursor  Variables to get Org Deatils */

    cursor org_details(l_business_group_id number)
    is
    select   name
    from     hr_all_organization_units
    where    l_business_group_id = organization_id;

    l_org_name            varchar2(2000);

    /* Cursor  Variables to get Manager Deatils */

/*    cursor mgr_details(p_source_mgr_id number)
    is
    select  full_name, person_id
    from    per_all_people_f
    where   trunc(sysdate ) between effective_start_date and effective_end_date
    and     person_id = (select source_id from   jtf_rs_resource_extns
                         and    resource_id = p_source_mgr_id);
*/
    cursor mgr_details(p_source_mgr_id number)
    is
    select  source_name, source_id
    from    jtf_rs_resource_extns
    where   resource_id = p_source_mgr_id;

    l_source_mgr_name     varchar2(2000);
    l_mgr_source_id       number;

    /* Cursor  Variables to get Fnd User Deatils */

    cursor fnd_user_details(l_user_name varchar2)
    is
    select   user_id
    from     fnd_user
    where    user_name = l_user_name;

    l_user_id             number;

    /* Cursor Variables to insert Job and Manager Deatils */

    cursor job_cur(l_person_id number)
    is
    select  object_version_number,
            assignment_id,
       	    effective_start_date,
	    effective_end_date,
	    business_group_id,
	    location_id,
	    special_ceiling_step_id,
            last_update_date,
            job_id
    from    per_all_assignments_f
    where   person_id = l_person_id
    and     effective_start_date = (select max(effective_start_date)
                              from per_all_assignments_f
                              where person_id = l_person_id
                              and   assignment_type = 'E'
                              and   primary_flag = 'Y')
    and     effective_end_date = (select max(effective_end_date)
                              from per_all_assignments_f
                              where person_id = l_person_id
                              and   assignment_type = 'E'
                              and   primary_flag = 'Y')
    and   assignment_type = 'E'
    and   primary_flag = 'Y';

    job_rec job_cur%rowtype;

     l_object_version_number_assg    number;
     l_special_ceiling_step_id       number;
     l_group_name                    varchar2(2000);
     l_datetrack_update_mode         varchar2(2000) := 'UPDATE';
     l_effective_start_date          date;
     l_effective_end_date            date;
     l_people_group_id               number;
     l_org_now_no_manager_warning    boolean;
     l_other_manager_warning         boolean;
     l_spp_delete_warning            boolean;
     l_entries_changed_earning       varchar2(2000);
     l_tax_district_changed_earning  boolean ;
     l_soft_coding_keyflex_id        number;
     l_concatenated_segments         varchar2(2000);
     l_comment_id                    number;
     l_no_managers_warning           boolean;

    /* Cursor Variables to Job Name */

    cursor Job_dtls(l_job_id number)
    is
    select name
    from   per_jobs
    where  job_id = l_job_id;

    l_job_name     varchar2(240) := null;

  hr_api_error exception;
  PRAGMA EXCEPTION_INIT(hr_api_error, -20001);

BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    savepoint cr_emp_save;

 --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    if fnd_api.tO_BOOLEAN(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    l_employee_number := p_employee_number;

    /* Get Business group Id */

     fnd_profile.get('PER_BUSINESS_GROUP_ID',l_business_group_id);


    /* Calling the hr api's to create an Employee in HR database. */

    hr_employee_api.create_employee
                    (p_hire_date                        => p_source_start_date
                    ,p_business_group_id                => l_business_group_id
                    ,p_last_name                        => p_source_last_name
                    ,p_sex                              => p_source_sex
                    ,p_email_address                    => p_source_email
                    ,p_employee_number                  => l_employee_number
                    ,p_first_name                       => p_source_first_name
                    ,p_middle_names                     => p_source_middle_name
                    ,p_title                            => p_source_title
                    ,p_work_telephone                   => p_source_phone
                    ,p_internal_location                => p_source_location
                    ,p_mailstop                         => p_source_mailstop
                    ,p_office_number                    => p_source_office
                    ,p_person_id                        => l_person_id
                    ,p_assignment_id                    => l_assignment_id
                    ,p_per_object_version_number        => l_per_object_version_number
                    ,p_asg_object_version_number        => l_asg_object_version_number
                    ,p_per_effective_start_date         => l_per_effective_start_date
                    ,p_per_effective_end_date           => l_per_effective_end_date
                    ,p_full_name                        => l_full_name
                    ,p_per_comment_id                   => l_per_comment_id
                    ,p_assignment_sequence              => l_assignment_sequence
                    ,p_assignment_number                => l_assignment_number
                    ,p_name_combination_warning         => l_name_combination_warning
                    ,p_assign_payroll_warning           => l_assign_payroll_warning
                    ,p_orig_hire_warning                => l_orig_hire_warning
                    );

    /*  Fetching Manager datails */
    open mgr_details(p_source_mgr_id);
    fetch mgr_details into l_source_mgr_name,l_mgr_source_id;
    close mgr_details;

     if l_mgr_source_id is not null then
       --update supervisor id
       open job_cur(l_person_id);
       fetch job_cur into job_rec;
       if(job_cur%found) then
         l_object_version_number_assg := job_rec.object_version_number;
         l_special_ceiling_step_id := job_rec.special_ceiling_step_id;
         if(trunc(job_rec.last_update_date)= trunc(sysdate)) then
           l_datetrack_update_mode := 'CORRECTION';
         else
           l_datetrack_update_mode := 'UPDATE';
         end if;

         hr_assignment_api.update_emp_asg
         (p_effective_date               => trunc(sysdate)
         ,p_datetrack_update_mode        => l_datetrack_update_mode
         ,p_assignment_id                => job_rec.assignment_id
         ,p_object_version_number        => l_object_version_number_assg
         ,p_supervisor_id                => l_mgr_source_id
         ,p_concatenated_segments        => l_concatenated_segments
         ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
         ,p_comment_id                   => l_comment_id
         ,p_effective_start_date         => l_effective_start_date
         ,p_effective_end_date           => l_effective_start_date
         ,p_no_managers_warning          => l_no_managers_warning
         ,p_other_manager_warning        => l_other_manager_warning );
       end if;
       close job_cur;
     end if;

     if l_job_id is not null then
       --update job id
       open job_cur(l_person_id);
       fetch job_cur into job_rec;
       if(job_cur%found) then
         l_object_version_number_assg := job_rec.object_version_number;
         l_special_ceiling_step_id := job_rec.special_ceiling_step_id;
         if(trunc(job_rec.last_update_date)= trunc(sysdate)) then
           l_datetrack_update_mode := 'CORRECTION';
         else
           l_datetrack_update_mode := 'UPDATE';
         end if;

         hr_assignment_api.update_emp_asg_criteria
         (p_effective_date               => trunc(sysdate)
         ,p_datetrack_update_mode        => l_datetrack_update_mode
         ,p_assignment_id                => job_rec.assignment_id
         ,p_object_version_number        => l_object_version_number_assg
         ,p_job_id                       => l_job_id
         ,p_special_ceiling_step_id      => l_special_ceiling_step_id
         ,p_group_name                   => l_group_name
         ,p_effective_start_date         => l_effective_start_date
         ,p_effective_end_date           => l_effective_start_date
         ,p_people_group_id              => l_people_group_id
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         ,p_other_manager_warning        => l_other_manager_warning
         ,p_spp_delete_warning           => l_spp_delete_warning
         ,p_entries_changed_warning      => l_entries_changed_earning
         ,p_tax_district_changed_warning => l_tax_district_changed_earning
         );
       end if;
       close job_cur;
     end if;

     open Job_dtls(l_job_id);
     fetch Job_dtls into l_job_name;
     close Job_dtls;

--   end if;

    -- generate fnd user password

    jtf_um_password_pvt.generate_password (
                 p_api_version_number        => 1.0,
                 x_password                  => l_user_password,
                 x_return_status             => l_return_status,
                 x_msg_count                 => x_msg_count,
                 x_msg_data                  => x_msg_data
                 );
    if not (l_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_unexpected_error;
    end if;

    p_user_password := l_user_password;

    fnd_user_pkg.CreateUser (
          x_user_name             => l_user_name
         ,x_owner                 => null
         ,x_unencrypted_password  => l_user_password
         ,x_start_date            => p_source_start_date
         ,x_end_date              => p_source_end_date
         ,x_employee_id           => l_person_id
         ,x_email_address         => p_source_email
         );

    /*  Fetching User Id datails */
    if(l_user_name is NOT NULL )
    then
        open fnd_user_details(l_user_name);
        fetch fnd_user_details into l_user_id;
        close fnd_user_details;

/*        if l_user_id is NOT NULL
        then
            raise
        end if;
*/

    end if;

        /*  Fetching Location datails */
    if(l_address_id <> fnd_api.g_miss_num)
    then
        open address_cur(l_address_id);
        fetch address_cur
        into  l_address_line_1,
              l_address_line_2,
              l_address_line_3,
              l_town_or_city,
              l_country,
              l_postal_code;
        close address_cur;
    else
        l_address_line_1 := NULL;
        l_address_line_2 := NULL;
        l_address_line_3 := NULL;
        l_town_or_city := NULL;
        l_country := NULL;
        l_postal_code := NULL;
    end if;

    /*  Fetching Org datails */
    open org_details(l_business_group_id);
    fetch org_details into l_org_name;
    close org_details;

   -- Calling Create Resource API

    jtf_rs_resource_pub.create_resource
            ( p_api_version               => 1.0
             ,p_init_msg_list             => fnd_api.g_false
             ,p_commit                    => fnd_api.g_false
             ,p_category                  => 'EMPLOYEE'
             ,p_source_id                 => l_person_id
             ,p_address_id                => p_source_address_id
             ,p_contact_id                => null
             ,p_managing_emp_id           => null
             ,p_start_date_active         => p_source_start_date
             ,p_end_date_active           => p_source_end_date
             ,p_time_zone                 => null
             ,p_cost_per_hr               => null
             ,p_primary_language          => null
             ,p_secondary_language        => null
             ,p_support_site_id           => null
             ,p_ies_agent_login           => null
             ,p_server_group_id           => null
             ,p_assigned_to_group_id      => null
             ,p_cost_center               => null
             ,p_charge_to_cost_center     => null
             ,p_comp_currency_code        => null
             ,p_commissionable_flag       => null
             ,p_hold_reason_code          => null
             ,p_hold_payment              => null
             ,p_comp_service_team_id      => null
             ,p_user_id                   => l_user_id
             ,p_transaction_number        => null
             ,x_return_status             => l_return_status
             ,x_msg_count                 => l_msg_count
             ,x_msg_data                  => l_msg_data
             ,x_resource_id               => l_resource_id
             ,x_resource_number           => l_resource_number
             ,p_resource_name             => l_full_name
             ,p_source_name               => l_full_name
             ,p_source_number             => l_employee_number
             ,p_source_job_title          => l_job_name
             ,p_source_email              => p_source_email
             ,p_source_phone              => p_source_phone
             ,p_source_org_id             => null
             ,p_source_org_name           => null
             ,p_source_address1           => l_address_line_1
             ,p_source_address2           => l_address_line_2
             ,p_source_address3           => l_address_line_3
             ,p_source_city               => l_town_or_city
             ,p_source_country            => l_country
             ,p_source_postal_code        => l_postal_code
             ,p_source_address4           => null
             ,p_source_state              => null
             ,p_source_province           => null
             ,p_source_county             => null
             ,p_source_mgr_id             => l_mgr_source_id
             ,p_source_mgr_name           => l_source_mgr_name
             ,p_source_business_grp_id    => l_business_group_id
             ,p_source_business_grp_name  => l_org_name
             ,p_source_first_name         => p_source_first_name
             ,p_source_last_name          => p_source_last_name
             ,p_source_middle_name        => p_source_middle_name
             ,p_source_category           => null
             ,p_source_status             => null
             ,p_source_office             => p_source_office
             ,p_source_location           => p_source_location
             ,p_source_mailstop           => p_source_mailstop
             ,p_user_name                 => l_user_name
             );

    if not (l_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_unexpected_error;
    end if;

    x_resource_id := l_resource_id;

    if (p_called_from = 'CRT_BULK_IMPORT') then
       l_salesrep_number := l_employee_number;
    end if;

    -- below call to MO_GLOBAL init is added for MOAC changes.
    -- If we didn't pass a value for org id in create_salesrep API,
    -- it will call the get_valid_org procedure and get the default operating unit.
    MO_GLOBAL.init('JTF');
    jtf_rs_salesreps_pub.create_salesrep (
             p_api_version           => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,p_commit               => p_commit
             ,p_resource_id          => l_resource_id
             ,p_sales_credit_type_id => p_sales_credit_type_id
             ,p_name                 => l_full_name
             ,p_status               => 'A'
             ,p_start_date_active    => p_source_start_date
             ,p_end_date_active      => p_source_end_date
             ,p_gl_id_rev            => null
             ,p_gl_id_freight        => null
             ,p_gl_id_rec            => null
             ,p_set_of_books_id      => null
             ,p_salesrep_number      => l_salesrep_number
             ,p_email_address        => null
             ,p_wh_update_date       => null
             ,p_sales_tax_geocode    => null
             ,p_sales_tax_inside_city_limits => '1'
             ,x_return_status        => l_return_status
             ,x_msg_count            => l_msg_count
             ,x_msg_data             => l_msg_data
             ,x_salesrep_id          => l_salesrep_id
             );

    if not (l_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_unexpected_error;
    end if;

    if (p_called_from <> 'CRT_BULK_IMPORT') then

       -- initiate the workflow to send the password
       jtf_um_password_pvt.send_password(
                     p_api_version_number       => 1.0,
                     p_requester_user_name      => l_user_name,
                     p_requester_password       => l_user_password,
                     p_first_time_user          => 'Y',
                     p_user_verified            => 'Y',
                     x_return_status            => l_return_status,
                     x_msg_count                => x_msg_count,
                     x_msg_data                 => x_msg_data
                     );

 --      if not (l_return_status = fnd_api.g_ret_sts_success) THEN
 --         raise fnd_api.g_exc_unexpected_error;
 --      end if;

    end if;

    if fnd_api.to_boolean(p_commit)
    then
       commit work;
    end if;

 exception
    WHEN hr_api_error
    THEN
      ROLLBACK TO cr_emp_save;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('JTF','JTF_RS_HR_API_ERROR');
      fnd_message.set_token('P_SQLERRM',substr(SQLERRM,11));
      FND_MSG_PUB.add;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    when fnd_api.g_exc_unexpected_error
    then
      rollback to cr_emp_save;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    when others
    then
      rollback to cr_emp_save;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

END create_emp_resource;

  PROCEDURE update_resource
 (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NUMBER      IN   VARCHAR2,
   P_RESOURCE_NAME        IN   VARCHAR2  ,
   P_SOURCE_NAME          IN   VARCHAR2  ,
   P_ADDRESS_ID           IN   VARCHAR2  ,
   P_SOURCE_OFFICE        IN   VARCHAR2  ,
   P_SOURCE_MAILSTOP      IN   VARCHAR2  ,
   P_SOURCE_LOCATION      IN   VARCHAR2  ,
   P_SOURCE_PHONE         IN   VARCHAR2  ,
   P_SOURCE_EMAIL         IN   VARCHAR2  ,
   P_OBJECT_VERSION_NUMBER IN  NUMBER,
   P_APPROVED             IN   VARCHAR2 DEFAULT 'N',
   P_SOURCE_JOB_ID        IN   NUMBER  DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_JOB_TITLE     IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_SALESREP_NUMBER      IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_SALES_CREDIT_TYPE_ID IN   NUMBER  DEFAULT FND_API.G_MISS_NUM,
   P_END_DATE_ACTIVE      IN   DATE    DEFAULT FND_API.G_MISS_DATE,
   P_USER_ID              IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   P_USER_NAME            IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
   P_MGR_RESOURCE_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   P_ORG_ID               IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   P_TIME_ZONE            IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_COST_PER_HR          IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE     IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE   IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID      IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_MOBILE_PHONE  IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PAGER         IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
    l_return_status       VARCHAR2(100) := FND_API.G_RET_STS_SUCCESS;
    l_job_id            number := p_source_job_id;
    l_job_title            varchar2(2000) := p_source_job_title;
    l_supervisor_id            number  ;

cursor old_cur
   is
select  RESOURCE_NAME
        , SOURCE_NAME
        , SOURCE_NUMBER
        , SOURCE_MGR_NAME
        , SOURCE_JOB_TITLE
        , SOURCE_ADDRESS1
        , SOURCE_ADDRESS2
        , SOURCE_ADDRESS3
        , SOURCE_ADDRESS4
        , SOURCE_CITY
        , SOURCE_STATE
        , SOURCE_PROVINCE
        , SOURCE_POSTAL_CODE
        , SOURCE_COUNTY
        , SOURCE_COUNTRY
        , SOURCE_PHONE
        , SOURCE_EMAIL
        , ADDRESS_ID
        , SOURCE_OFFICE
        , SOURCE_MAILSTOP
        , SOURCE_LOCATION
        , SOURCE_ID
        , SOURCE_MGR_ID
        , START_DATE_ACTIVE
        , END_DATE_ACTIVE
        , TIME_ZONE
        , COST_PER_HR
        , PRIMARY_LANGUAGE
        , SECONDARY_LANGUAGE
        , SUPPORT_SITE_ID
        , SOURCE_MOBILE_PHONE
        , SOURCE_PAGER
        , USER_ID
 from  jtf_rs_resource_extns_vl
where  resource_id = p_resource_id;

old_rec    old_cur%rowtype;

cursor salesrep_cur(l_resource_id number,
                    l_org_id      number)
    is
select salesrep_id,
       object_version_number,
       sales_credit_type_id,
       salesrep_number
 from  jtf_rs_salesreps
where  resource_id = l_resource_id
  and  org_id      = l_org_id;

 salesrep_rec salesrep_cur%rowtype;

 l_srp_object_version_number number;
 l_salesrep_id  number;

cursor mgr_user(l_mgr_id number)
   is
select user_id
 from  fnd_user
where  employee_id = l_mgr_id;

 l_mgr_user_id number;

cursor user_cur(l_user_id number)
    is
select user_name
 from  fnd_user
 where user_id = l_user_id;

l_user_name fnd_user.user_name%type;

l_u    number  := 0;
l_uwn  number := 0;
l_uwa   number := 0;
l_direct_call varchar2(1) := 'Y';

cursor attr_cur
   is
select attribute_name
      , attribute_access_level
from  jtf_rs_table_attributes_b;


attr_rec attr_cur%rowtype;


TYPE ATTR_TYPE is Record
  (attribute_name varchar2(30),
   attribute_access_level varchar2(30));
type attr_tab_type is table of attr_type index by BINARY_INTEGER;

l_attr_rec attr_tab_type;
i BINARY_INTEGER := 0;
l_found BOOLEAN := FALSE;
l_object_version_number number := p_object_version_number;

cursor assg_cur(l_person_id number)
    is
select  object_version_number,
        assignment_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	location_id,
	special_ceiling_step_id,
       last_update_date,
       job_id
from per_all_assignments_f
where person_id = l_person_id
and   effective_start_date = (select max(effective_start_date)
                              from per_all_assignments_f
                              where person_id = l_person_id
                              and   assignment_type = 'E'
                              and   primary_flag = 'Y')
and   effective_end_date = (select max(effective_end_date)
                              from per_all_assignments_f
                              where person_id = l_person_id
                              and   assignment_type = 'E'
                              and   primary_flag = 'Y')
and   assignment_type = 'E'
and   primary_flag = 'Y';

assg_rec assg_cur%rowtype;

cursor per_cur(l_person_id number)
    is
select person_id,
       employee_number,
       last_update_date,
       object_version_number
from   per_all_people_f
where person_id = l_person_id
and   effective_start_date = (select max(effective_start_date)
                              from per_all_people_f
                              where person_id = l_person_id
                              and   employee_number is not null )
and   effective_end_date = (select max(effective_end_date)
                              from per_all_people_f
                              where person_id = l_person_id
                              and   employee_number is not null )
and  employee_number is not null;

per_rec per_cur%rowtype;

  -- Bug # 2186026
  -- OK_... fields are set for changes for which no approval needed or just the
  -- noficiations are required. Whereas APPRV_.. fields are set when
  -- changes requires approval
  aprvl_resource_name jtf_rs_resource_extns_vl.resource_name%type := fnd_api.g_miss_char;
  aprvl_source_name jtf_rs_resource_extns_vl.source_name%type := fnd_api.g_miss_char;
  aprvl_address_id jtf_rs_resource_extns_vl.address_id%type := fnd_api.g_miss_num;
  aprvl_source_office jtf_rs_resource_extns_vl.source_office%type := fnd_api.g_miss_char;
  aprvl_source_mailstop jtf_rs_resource_extns_vl.source_mailstop%type := fnd_api.g_miss_char;
  aprvl_source_location jtf_rs_resource_extns_vl.source_location%type := fnd_api.g_miss_char;
  aprvl_source_phone jtf_rs_resource_extns_vl.source_phone%type := fnd_api.g_miss_char;
  aprvl_source_mobile_phone jtf_rs_resource_extns_vl.source_mobile_phone%type := fnd_api.g_miss_char;
  aprvl_source_pager jtf_rs_resource_extns_vl.source_pager%type := fnd_api.g_miss_char;
  aprvl_source_email jtf_rs_resource_extns_vl.source_email%type := fnd_api.g_miss_char;
  aprvl_time_zone jtf_rs_resource_extns_vl.time_zone%type := fnd_api.g_miss_num;
  aprvl_support_site_id jtf_rs_resource_extns_vl.support_site_id%type := fnd_api.g_miss_num;
  aprvl_primary_language jtf_rs_resource_extns_vl.primary_language%type := fnd_api.g_miss_char;
  aprvl_secondary_language jtf_rs_resource_extns_vl.secondary_language%type := fnd_api.g_miss_char;
  aprvl_cost_per_hr jtf_rs_resource_extns_vl.cost_per_hr%type := fnd_api.g_miss_num;

  ok_resource_name jtf_rs_resource_extns_vl.resource_name%type := p_resource_name;
  ok_source_name jtf_rs_resource_extns_vl.source_name%type := p_source_name;
  ok_address_id jtf_rs_resource_extns_vl.address_id%type := to_number(p_address_id);
  ok_source_office jtf_rs_resource_extns_vl.source_office%type := p_source_office;
  ok_source_mailstop jtf_rs_resource_extns_vl.source_mailstop%type := p_source_mailstop;
  ok_source_location jtf_rs_resource_extns_vl.source_location%type := p_source_location;
  ok_source_phone jtf_rs_resource_extns_vl.source_phone%type := p_source_phone;
  ok_source_mobile_phone jtf_rs_resource_extns_vl.source_mobile_phone%type := p_source_mobile_phone;
  ok_source_pager jtf_rs_resource_extns_vl.source_pager%type := p_source_pager;
  ok_source_email jtf_rs_resource_extns_vl.source_email%type := p_source_email;
  ok_time_zone jtf_rs_resource_extns_vl.time_zone%type := p_time_zone;
  ok_support_site_id jtf_rs_resource_extns_vl.support_site_id%type := p_support_site_id;
  ok_primary_language jtf_rs_resource_extns_vl.primary_language%type := p_primary_language;
  ok_secondary_language jtf_rs_resource_extns_vl.secondary_language%type := p_secondary_language;
  ok_cost_per_hr jtf_rs_resource_extns_vl.cost_per_hr%type := p_cost_per_hr;

--variables for assg update call
      l_object_version_number_assg  number;
      l_special_ceiling_step_id number;
      l_group_name             varchar2(2000);
      l_datetrack_update_mode  varchar2(2000) := 'UPDATE';
      l_effective_start_date   date;
      l_effective_end_date   date;
      l_people_group_id     number;
      l_org_now_no_manager_warning    boolean;
      l_other_manager_warning     boolean;
      l_spp_delete_warning     boolean;
      l_entries_changed_earning      varchar2(2000);
      l_tax_district_changed_earning    boolean ;
      l_cagr_grade_def_id               number;
      l_cagr_concatenated_segments      varchar2(2000);
      l_soft_coding_keyflex_id          number;
      l_concatenated_segments         varchar2(2000);

      l_no_managers_warning   boolean;
--variables for person update
 l_object_version_number_per     number;
 l_employee_number               varchar2(2000);
 l_full_name                     varchar2(2000);
 l_comment_id                    number;
 l_name_combination_warning      boolean;
 l_assign_payroll_warning        boolean;
 l_orig_hire_warning             boolean;



 cursor address_cur(l_address_id number)
    is
 select  ADDRESS_LINE_1,
         ADDRESS_LINE_2,
         ADDRESS_LINE_3 ,
         TOWN_OR_CITY ,
         COUNTRY,
         POSTAL_CODE
   from  hr_locations
 where  location_id = l_address_id;

 address_rec address_cur%rowtype;


 cursor phone_cur(l_person_id number)
     is
  select phone_id,
         object_version_number
   from  per_phones p1
  where  parent_table = 'PER_ALL_PEOPLE_F'
    and  parent_id    = l_person_id
    and  phone_type   = 'W1'
    and  date_from  = (select max(date_from)
                         from per_phones p2
                        where  parent_table = 'PER_ALL_PEOPLE_F'
                          and  parent_id    = l_person_id
                          and  phone_type   = 'W1' );

  phone_rec phone_cur%rowtype;
  l_object_version_number_phone number;
  l_phone_id     number;


 cursor mobile_phone_cur(l_person_id number)
     is
  select phone_id,
         object_version_number
   from  per_phones p1
  where  parent_table = 'PER_ALL_PEOPLE_F'
    and  parent_id    = l_person_id
    and  phone_type   = 'M'
    and  date_from  = (select max(date_from)
                         from per_phones p2
                        where  parent_table = 'PER_ALL_PEOPLE_F'
                          and  parent_id    = l_person_id
                          and  phone_type   = 'M' );

  mobile_phone_rec mobile_phone_cur%rowtype;
  l_object_ver_num_mobile_ph number;
  l_mobile_phone_id     number;


 cursor pager_cur(l_person_id number)
     is
  select phone_id,
         object_version_number
   from  per_phones p1
  where  parent_table = 'PER_ALL_PEOPLE_F'
    and  parent_id    = l_person_id
    and  phone_type   = 'P'
    and  date_from  = (select max(date_from)
                         from per_phones p2
                        where  parent_table = 'PER_ALL_PEOPLE_F'
                          and  parent_id    = l_person_id
                          and  phone_type   = 'P' );

  pager_rec pager_cur%rowtype;
  l_object_version_number_pager number;
  l_pager_id     number;


  cursor mgr_res_cur(l_resource_id number)
      is
  select source_id,
         source_name
  from   jtf_rs_resource_extns
 where   resource_id = l_resource_id;

 l_mgr_source_name jtf_rs_resource_extns.source_name%type := fnd_api.g_miss_char;
 l_mgr_source_id   jtf_rs_resource_extns.source_id%type := fnd_api.g_miss_num;
 l_mgr_name        jtf_rs_resource_extns_vl.resource_name%type;
 mgr_res_rec mgr_res_cur%rowtype;

  l_fnd_date date := to_date(to_char(fnd_api.g_miss_date, 'DD-MM-RRRR'), 'DD-MM-RRRR');

  hr_api_error exception;
  PRAGMA EXCEPTION_INIT(hr_api_error, -20001);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
 --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;
   SAVEPOINT sp_save;
 IF(P_APPROVED='NR')
 THEN
    -- if called from the all update screen then work like l_u = 1
    l_u := 1;
 END IF;
 IF(P_APPROVED='N')
 THEN
  x_return_status := fnd_api.g_ret_sts_success;
  --fetch the attributes
  open attr_cur;
  fetch attr_cur into attr_rec;
  while(attr_cur%found)
  loop
      i := i + 1;
      l_attr_rec(i).attribute_name := attr_rec.attribute_name;
      l_attr_rec(i).attribute_access_level := attr_rec.attribute_access_level;
      fetch attr_cur into attr_rec;
  end loop;
  close attr_cur;



  open old_cur;
  fetch old_cur into old_rec;
  if (old_cur%found)
  then
    --resource name
    if(nvl(ok_resource_name, fnd_api.g_miss_char) <>
                    nvl(old_rec.resource_name, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'RESOURCE_NAME')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_resource_name := ok_resource_name;
	      ok_resource_name := fnd_api.g_miss_char;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    end if;

  --source name
  if(nvl(ok_source_name, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_name, fnd_api.g_miss_char))
  then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'RESOURCE_NAME')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_name := ok_source_name;
	      ok_source_name := fnd_api.g_miss_char;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
  end if;


 --address

  if(nvl(ok_address_id, fnd_api.g_miss_num) <>
                    nvl(old_rec.address_id, fnd_api.g_miss_num))
  then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_ADDRESS')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_address_id := ok_address_id;
	      ok_address_id := fnd_api.g_miss_num;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    else
      ok_address_id := fnd_api.g_miss_num;
    end if;


 --office

  if(nvl(ok_source_office, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_office, fnd_api.g_miss_char))
  then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_OFFICE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
      	      aprvl_source_office := ok_source_office;
	      -- not setting ok_source_office as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_office := old_rec.source_office;

           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
  end if;

 --mailstop

  if(nvl(ok_source_mailstop, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_mailstop, fnd_api.g_miss_char))
  then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_MAILSTOP')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_mailstop := ok_source_mailstop;
	      -- not setting ok_source_mailstop as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_mailstop := old_rec.source_mailstop;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
  end if;

 --location

  if(nvl(ok_source_location, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_location, fnd_api.g_miss_char))
  then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_LOCATION')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_location := ok_source_location;
	      -- not setting ok_source_location as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_location := old_rec.source_location;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
  end if;


--phone
  if(nvl(ok_source_phone, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_phone, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_PHONE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_phone := ok_source_phone;
	      -- not setting ok_source_phone as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_phone := old_rec.source_phone;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    end if;

--mobile phone
  if(nvl(ok_source_mobile_phone, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_mobile_phone, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_MOBILE_PHONE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_mobile_phone := ok_source_mobile_phone;
	      -- not setting ok_source_mobile_phone as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_mobile_phone := old_rec.source_mobile_phone;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    end if;

--pager
  if(nvl(ok_source_pager, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_pager, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_PAGER')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_pager := ok_source_pager;
	      -- not setting ok_source_pager as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_pager := old_rec.source_pager;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    end if;

--email
  if(nvl(ok_source_email, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_email, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SOURCE_EMAIL')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_source_email := ok_source_email;
	      -- not setting ok_source_email as G_MISS as HR API
	      -- does not understand G_MISS and inserts G_MISS into
	      -- the database which causes form crash/junk value
	      -- bug # 3114608
	      ok_source_email := old_rec.source_email;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
    end if;

--time zone
  if(nvl(ok_time_zone, fnd_api.g_miss_num) <>
                    nvl(old_rec.time_zone, fnd_api.g_miss_num))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'TIME_ZONE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_time_zone := ok_time_zone;
	      ok_time_zone := fnd_api.g_miss_num;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
     else
      ok_time_zone := fnd_api.g_miss_num;
    end if;

--Support site
  if(nvl(ok_support_site_id, fnd_api.g_miss_num) <>
                    nvl(old_rec.support_site_id, fnd_api.g_miss_num))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SUPPORT_SITE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_support_site_id := ok_support_site_id;
	      ok_support_site_id := fnd_api.g_miss_num;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
     else
      ok_support_site_id := fnd_api.g_miss_num;
    end if;

--primary language
  if(nvl(ok_primary_language, fnd_api.g_miss_char) <>
                    nvl(old_rec.primary_language, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'PRIMARY_LANGUAGE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_primary_language := ok_primary_language;
	      ok_primary_language := fnd_api.g_miss_char;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
     else
      ok_primary_language := fnd_api.g_miss_char;
    end if;

--secondary language
  if(nvl(ok_secondary_language, fnd_api.g_miss_char) <>
                    nvl(old_rec.secondary_language, fnd_api.g_miss_char))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'SECONDARY_LANGUAGE')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_secondary_language := ok_secondary_language;
	      ok_secondary_language := fnd_api.g_miss_char;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
     else
      ok_secondary_language := fnd_api.g_miss_char;
    end if;

--Rate
  if(nvl(ok_cost_per_hr, fnd_api.g_miss_num) <>
                    nvl(old_rec.cost_per_hr, fnd_api.g_miss_num))
    then
      i:= 0;
      l_found := FALSE;
      for i in 1..l_attr_rec.COUNT
      loop
         if(l_attr_rec(i).attribute_name = 'COST_PER_HR')
         then
           l_found := TRUE;
           if(l_attr_rec(i).attribute_access_level = 'U')
           then
               l_u := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWN')
           then
               l_uwn := 1;
           elsif(l_attr_rec(i).attribute_access_level = 'UWA')
           then
              l_uwa := 1;
	      aprvl_cost_per_hr := ok_cost_per_hr;
	      ok_cost_per_hr := fnd_api.g_miss_num;
           end if;

         end if;
         if(l_found) then exit; end if;
      end loop;
     else
      ok_cost_per_hr := fnd_api.g_miss_num;
    end if;


  end if; -- end of old cou
  close old_cur;
 END IF; -- end of p_approved check
  if(p_approved <> 'Y')
  then
     open old_cur;
     fetch old_cur into old_rec;
     if (old_cur%found)
     then
        if p_user_id =  fnd_api.g_miss_num
        then
            --fetch user name (use the user_id of resource_id from table)
            open user_cur(old_rec.user_id);
            fetch user_cur into l_user_name;
            close user_cur;
        else
          if p_user_id is not null then
            --fetch user name (use the user_id from API input parameter)
            open user_cur(p_user_id);
            fetch user_cur into l_user_name;
            close user_cur;
          end if;
        end if;
     end if;--end of old_cur check
     close old_cur;
  end if; --end of p_approved second check

  --if called with P_APPROVED = NR then fetch all relevant details
  if(p_approved = 'NR')
  then

        open mgr_res_cur(p_mgr_resource_id);
        fetch mgr_res_cur into mgr_res_rec;
        l_mgr_source_id := mgr_res_rec.source_id;
        l_mgr_source_name := mgr_res_rec.source_name;
        if(nvl(l_mgr_source_id, fnd_api.g_miss_num) = nvl(old_rec.source_mgr_id, fnd_api.g_miss_num))
        then
            l_supervisor_id := fnd_api.g_miss_num;
        else
            l_supervisor_id := l_mgr_source_id;
        end if;

        close mgr_res_cur;

     if(nvl(l_job_title, fnd_api.g_miss_char) = nvl(old_rec.source_job_title, fnd_api.g_miss_char))
     then
           l_job_id := fnd_api.g_miss_num;
           l_job_title := fnd_api.g_miss_char;
     -- added these checks for invalid job title validation
     elsif((l_job_id is null) and (l_job_title is not null))
     then
           l_job_id := fnd_api.g_miss_num;
           l_job_title := fnd_api.g_miss_char;
     elsif((l_job_id is not null) and (l_job_title is null))
     then
           l_job_id := null;
     end if;

      if(nvl(ok_address_id, fnd_api.g_miss_num) =
                    nvl(old_rec.address_id, fnd_api.g_miss_num))
      then
            ok_address_id := fnd_api.g_miss_num;
      end if;
  else
     l_job_id := fnd_api.g_miss_num;
     l_supervisor_id := fnd_api.g_miss_num;
     l_job_title := fnd_api.g_miss_char;

     if(nvl(ok_address_id, fnd_api.g_miss_num) =
                    nvl(old_rec.address_id, fnd_api.g_miss_num))
      then
            ok_address_id := fnd_api.g_miss_num;
      end if;
  end if;

  if(l_uwn=1)
  then

      jtf_rs_resource_wf_pub.start_update_resource_wf
       (P_API_VERSION              => 1.0,
        P_COMMIT                   => p_commit,
        P_RESOURCE_ID              => p_resource_id,
        P_CATEGORY                 => 'EMPLOYEE',
        P_RESOURCE_NUMBER          => null,
        P_RESOURCE_NAME            => ok_resource_name,
        P_ADDRESS_ID               => ok_address_id,
        P_SOURCE_EMAIL             =>  ok_source_email,
        P_SOURCE_PHONE             =>  ok_source_phone,
        P_SOURCE_OFFICE            => ok_source_office,
        P_SOURCE_LOCATION          => ok_source_location,
        P_SOURCE_MAILSTOP          => ok_source_mailstop,
        P_TIME_ZONE                => ok_time_zone,
        P_SUPPORT_SITE_ID          => ok_support_site_id,
        P_PRIMARY_LANGUAGE         => ok_primary_language,
        P_SECONDARY_LANGUAGE       => ok_secondary_language,
        P_COST_PER_HR              => ok_cost_per_hr,
        P_SOURCE_MOBILE_PHONE      => ok_source_mobile_phone,
        P_SOURCE_PAGER             => ok_source_pager,
        P_ATTRIBUTE_ACCESS_LEVEL   => 'UWN',
        P_OBJECT_VERSION_NUMBER    => p_object_version_number,
        X_RETURN_STATUS            => x_return_status,
        X_MSG_COUNT                => x_msg_count,
        X_MSG_DATA                 => x_msg_data
       );

  elsif((l_u = 1) OR (p_approved IN ('A', 'T', 'AE', 'TE') ))
  then

    --call the hr api's
    If (l_supervisor_id <> fnd_api.g_miss_num)
   then
    -- call the api for per_assigments_f update
     open assg_cur(old_rec.source_id);
     fetch assg_cur into assg_rec;
     if(assg_cur%found)
     then
         l_object_version_number_assg := assg_rec.object_version_number;
         l_special_ceiling_step_id := assg_rec.special_ceiling_step_id;
         if(trunc(assg_rec.last_update_date)= trunc(sysdate))
         then
            l_datetrack_update_mode := 'CORRECTION';
         else
           l_datetrack_update_mode := 'UPDATE';
         end if;
         hr_assignment_api.update_emp_asg
         (p_effective_date              => trunc(sysdate)
         ,p_datetrack_update_mode       => l_datetrack_update_mode --in ??
         ,p_assignment_id             => assg_rec.assignment_id
         ,p_object_version_number     => l_object_version_number_assg
         ,p_supervisor_id             => l_mgr_source_id
         ,p_concatenated_segments        => l_concatenated_segments
         ,p_soft_coding_keyflex_id          => l_soft_coding_keyflex_id
         ,p_comment_id                      => l_comment_id
         ,p_effective_start_date      => l_effective_start_date
         ,p_effective_end_date        => l_effective_start_date
         ,p_no_managers_warning      => l_no_managers_warning
         ,p_other_manager_warning    => l_other_manager_warning );

     end if; --end of assg cur check
     close assg_cur;
  end if;

  if((ok_address_id <> fnd_api.g_miss_num)
     OR (ok_address_id is null)
     OR (l_job_id <> fnd_api.g_miss_num)
     OR (l_job_id is null))
   then
     --update location and job
      open assg_cur(old_rec.source_id);
     fetch assg_cur into assg_rec;
     if(assg_cur%found)
     then
         if(l_job_id = fnd_api.g_miss_num)
         then
            l_job_id := assg_rec.job_id;
         end if;
         if(ok_address_id = fnd_api.g_miss_num)
         then
            ok_address_id := assg_rec.location_id;
         end if;
         l_object_version_number_assg := assg_rec.object_version_number;
         l_special_ceiling_step_id := assg_rec.special_ceiling_step_id;
         if(trunc(assg_rec.last_update_date)= trunc(sysdate))
         then
            l_datetrack_update_mode := 'CORRECTION';
         else
           l_datetrack_update_mode := 'UPDATE';
         end if;
          hr_assignment_api.update_emp_asg_criteria
         (p_effective_date              => trunc(sysdate)
         ,p_datetrack_update_mode       => l_datetrack_update_mode --in ??
         ,p_assignment_id             => assg_rec.assignment_id
         ,p_object_version_number     => l_object_version_number_assg
         ,p_location_id               => ok_address_id
         ,p_job_id                    => l_job_id
         ,p_special_ceiling_step_id   => l_special_ceiling_step_id
         ,p_group_name                => l_group_name
         ,p_effective_start_date      => l_effective_start_date
         ,p_effective_end_date        => l_effective_start_date
         ,p_people_group_id           => l_people_group_id
         ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
         ,p_other_manager_warning      => l_other_manager_warning
         ,p_spp_delete_warning         => l_spp_delete_warning
         ,p_entries_changed_warning    => l_entries_changed_earning
         ,p_tax_district_changed_warning => l_tax_district_changed_earning
         );

     end if;
     close assg_cur;
   end if;

  if((nvl(ok_source_mailstop, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_mailstop, fnd_api.g_miss_char) )
     OR (nvl(ok_source_location, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_location, fnd_api.g_miss_char) )
     OR (nvl(ok_source_email, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_email, fnd_api.g_miss_char) )
     OR (nvl(ok_source_office, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_office, fnd_api.g_miss_char)))
  then
   --update per_all_people_f
     open per_cur(old_rec.source_id);
     fetch per_cur into per_rec;
     if(per_cur%found)
     then
         l_object_version_number_per := per_rec.object_version_number;
         l_employee_number := per_rec.employee_number;
          if(trunc(per_rec.last_update_date)= trunc(sysdate))
         then
            l_datetrack_update_mode := 'CORRECTION';
         else
           l_datetrack_update_mode := 'UPDATE';
         end if;

        hr_person_api.update_person
        (p_effective_date              => trunc(sysdate)
         ,p_datetrack_update_mode        =>  l_datetrack_update_mode
         ,p_person_id                    => per_rec.person_id
         ,p_object_version_number       => l_object_version_number_per
         ,p_employee_number             => l_employee_number
         ,p_internal_location            => ok_source_location
         ,p_mailstop                    => ok_source_mailstop
         ,p_office_number                => ok_source_office
         ,p_email_address                => ok_source_email
         ,p_effective_start_date            => l_effective_start_date
         ,p_effective_end_date              => l_effective_end_date
         ,p_full_name                       => l_full_name
         ,p_comment_id                      => l_comment_id
         ,p_name_combination_warning        =>  l_name_combination_warning
         ,p_assign_payroll_warning         => l_assign_payroll_warning
         ,p_orig_hire_warning               => l_orig_hire_warning);

    end if; -- end of per cursor
    close per_cur;

    end if; -- end of source col change check


   --call phone api
   if(nvl(ok_source_phone, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_phone, fnd_api.g_miss_char))
   then
      --update per_phones
     open phone_cur(old_rec.source_id);
     fetch phone_cur into phone_rec;
     if(phone_cur%found)
     then
       l_object_version_number_phone := phone_rec.object_version_number;
       if(ok_source_phone is not null)
       then
         hr_phone_api.update_phone(p_phone_id              => phone_rec.phone_id,
                                   p_object_version_number => l_object_version_number_phone,
                                   p_effective_date        => sysdate,
                                   p_phone_number          => ok_source_phone);
       else
          hr_phone_api.delete_phone
                    (p_phone_id                      => phone_rec.phone_id,
                    p_object_version_number       => l_object_version_number_phone
                    );


       end if;
      else
           hr_phone_api.create_phone
                  (p_date_from              => sysdate,
                   p_phone_type             => 'W1',
                   p_phone_number           => ok_source_phone,
                   p_parent_id              => old_rec.source_id,
                   p_parent_table           => 'PER_ALL_PEOPLE_F',
                   p_effective_date         => sysdate,
                   p_object_version_number  => l_object_version_number_phone,
                   p_phone_id               => l_phone_id);

     end if;
     close phone_cur;
   end if; -- end of source_phone change check


   --call mobile phone api
   if(nvl(ok_source_mobile_phone, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_mobile_phone, fnd_api.g_miss_char))
   then
      --update per_phones
     open mobile_phone_cur(old_rec.source_id);
     fetch mobile_phone_cur into mobile_phone_rec;
     if(mobile_phone_cur%found)
     then
       l_object_ver_num_mobile_ph := mobile_phone_rec.object_version_number;
       if(ok_source_mobile_phone is not null)
       then
         hr_phone_api.update_phone(p_phone_id              => mobile_phone_rec.phone_id,
                                   p_object_version_number => l_object_ver_num_mobile_ph,
                                   p_effective_date        => sysdate,
                                   p_phone_number          => ok_source_mobile_phone);
       else
          hr_phone_api.delete_phone
                    (p_phone_id                      => mobile_phone_rec.phone_id,
                    p_object_version_number       => l_object_ver_num_mobile_ph
                    );


       end if;
      else
           hr_phone_api.create_phone
                  (p_date_from              => sysdate,
                   p_phone_type             => 'M',
                   p_phone_number           => ok_source_mobile_phone,
                   p_parent_id              => old_rec.source_id,
                   p_parent_table           => 'PER_ALL_PEOPLE_F',
                   p_effective_date         => sysdate,
                   p_object_version_number  => l_object_ver_num_mobile_ph,
                   p_phone_id               => l_mobile_phone_id);

     end if;
     close mobile_phone_cur;
   end if; -- end of source_mobile_phone change check

   --call pager api
   if(nvl(ok_source_pager, fnd_api.g_miss_char) <>
                    nvl(old_rec.source_pager, fnd_api.g_miss_char))
   then
      --update per_phones
     open pager_cur(old_rec.source_id);
     fetch pager_cur into pager_rec;
     if(pager_cur%found)
     then
       l_object_version_number_pager := pager_rec.object_version_number;
       if(ok_source_pager is not null)
       then
         hr_phone_api.update_phone(p_phone_id              => pager_rec.phone_id,
                                   p_object_version_number => l_object_version_number_pager,
                                   p_effective_date        => sysdate,
                                   p_phone_number          => ok_source_pager);
       else
          hr_phone_api.delete_phone
                    (p_phone_id                      => pager_rec.phone_id,
                    p_object_version_number       => l_object_version_number_pager
                    );


       end if;
      else
           hr_phone_api.create_phone
                  (p_date_from              => sysdate,
                   p_phone_type             => 'P',
                   p_phone_number           => ok_source_pager,
                   p_parent_id              => old_rec.source_id,
                   p_parent_table           => 'PER_ALL_PEOPLE_F',
                   p_effective_date         => sysdate,
                   p_object_version_number  => l_object_version_number_pager,
                   p_phone_id               => l_pager_id);

     end if;
     close pager_cur;
   end if; -- end of source_pager change check


   --end of hr api calls

   --call update resource  api

     if((ok_address_id <> fnd_api.g_miss_num) OR (ok_address_id is NULL))
     then
        if (ok_address_id is NULL) then
           address_rec := NULL;
        else
           open address_cur(ok_address_id);
           fetch address_cur into address_rec;
           close address_cur;
        end if;
     else
        open address_cur(old_rec.address_id);
        fetch address_cur into address_rec;
        close address_cur;
        ok_address_id := old_rec.address_id;
     end if;


         --call the cascade update api if p_end_date_active < existing end date
         IF(nvl(to_date(to_char(p_end_date_active ,'DD-MM-RRRR'), 'DD-MM-RRRR'), l_fnd_date)
                < nvl(to_date(to_char(old_rec.end_date_active, 'DD-MM-RRRR'), 'DD-MM-RRRR'), l_fnd_date))
         THEN
           jtf_rs_resource_utl_pub.end_date_employee
            (p_api_version => 1.0
             , p_resource_id => p_resource_id
             , p_end_date_active => p_end_date_active
             , x_object_ver_number => l_object_version_number
             , x_return_status => x_return_status
             , x_msg_count    => x_msg_count
             , x_msg_data     => x_msg_data);


            if(x_return_status <> fnd_api.g_ret_sts_success)
            then
               raise fnd_api.g_exc_error;
            end if;

         END IF; -- edn of date check

         jtf_rs_resource_pub.update_resource
          (p_api_version => 1.0
          , p_init_msg_list => fnd_api.g_false
          , p_commit        => p_commit
          , p_resource_id => p_resource_id
          , p_resource_number => null
          , p_resource_name => ok_resource_name
          , p_SOURCE_NAME   => ok_source_name
          , p_SOURCE_EMAIL   => ok_source_email
          , p_SOURCE_PHONE    => ok_source_phone
          , p_address_id      => ok_address_id
          , p_source_mailstop  => ok_source_mailstop
          , p_source_office     => ok_source_office
          , p_source_location   => ok_source_location
          , p_source_address1   => address_rec.address_line_1
          , p_source_address2   => address_rec.address_line_2
          , p_source_address3   => address_rec.address_line_3
          , p_source_city   => address_rec.town_or_city
          , p_source_country   => address_rec.country
          , p_source_postal_code   => address_rec.postal_code
          , p_object_version_num => l_object_version_number
          , p_source_job_title   => l_job_title --p_source_job_title
          , p_end_date_active   => p_end_date_active
          , p_source_mgr_id    => l_mgr_source_id
          , p_source_mgr_name  => l_mgr_source_name
          , p_user_id          => p_user_id
          , p_user_name        => l_user_name
          , p_time_zone    => ok_time_zone
          , p_cost_per_hr   => ok_cost_per_hr
          , p_primary_language   => ok_primary_language
          , p_secondary_language  => ok_secondary_language
          , p_support_site_id    => ok_support_site_id
          , p_source_mobile_phone  => ok_source_mobile_phone
          , p_source_pager    => ok_source_pager
          , x_return_status  => x_return_status
          , x_msg_count    => x_msg_count
          , x_msg_data     => x_msg_data);


          if(x_return_status = fnd_api.g_ret_sts_success)
          then
             if((p_org_id is not null)
                OR (p_org_id <> fnd_api.g_miss_num))
             then
                --update srp
                 open salesrep_cur(p_resource_id, p_org_id);
                 fetch salesrep_cur into salesrep_rec;
                 if(salesrep_cur%found)
                 then
                      l_srp_object_version_number := salesrep_rec.object_version_number;
                      jtf_rs_salesreps_pub.update_salesrep
                          (P_API_VERSION          =>  1.0,
                           P_SALESREP_ID          => salesrep_rec.salesrep_id,
                           P_SALES_CREDIT_TYPE_ID => p_sales_credit_type_id,
                           P_NAME                 => ok_resource_name,
                           P_ORG_ID               => p_org_id,
                           p_salesrep_number      => p_salesrep_number,
                           P_OBJECT_VERSION_NUMBER => l_srp_object_version_number,
                           X_RETURN_STATUS        => x_return_status,
                           X_MSG_COUNT            => x_msg_count,
                           X_MSG_DATA             => x_msg_data);
                 end if;
                 close salesrep_cur;

             elsif(( p_sales_credit_type_id is not null)
                   AND (p_sales_credit_type_id <> fnd_api.g_miss_num))
             then
                --create srp
                  -- below call to MO_GLOBAL init is added for MOAC changes.
                  -- If we didn't pass a value for org id in create_salesrep API,
                  -- it will call the get_valid_org procedure and get the default operating unit.
                  MO_GLOBAL.init('JTF');
                  jtf_rs_salesreps_pub.create_salesrep
                          (P_API_VERSION          =>  1.0,
                           P_RESOURCE_ID          => p_resource_id,
                           P_SALES_CREDIT_TYPE_ID => p_sales_credit_type_id,
                           p_salesrep_number      => p_salesrep_number,
                           P_NAME                 => ok_resource_name,
                           P_START_DATE_ACTIVE    => trunc(old_rec.start_date_active),
                           P_END_DATE_ACTIVE    =>   trunc(p_end_date_active),
                           X_RETURN_STATUS        => x_return_status,
                           X_MSG_COUNT            => x_msg_count,
                           X_MSG_DATA             => x_msg_data,
                           X_SALESREP_ID          => l_salesrep_id
                         );

             end if;
          end if;


    end if;


   if(l_uwa=1)
   then

      --call approval api
       jtf_rs_resource_wf_pub.start_update_resource_wf
	(P_API_VERSION              => 1.0,
	 P_COMMIT                   => p_commit,
	 P_RESOURCE_ID              => p_resource_id,
	 P_CATEGORY                 => 'EMPLOYEE',
	 P_RESOURCE_NUMBER          => null,
	 P_RESOURCE_NAME            => aprvl_resource_name,
	 P_ADDRESS_ID               => aprvl_address_id,
	 P_SOURCE_EMAIL             =>  aprvl_source_email,
	 P_SOURCE_PHONE             =>  aprvl_source_phone,
	 P_SOURCE_OFFICE            => aprvl_source_office,
	 P_SOURCE_LOCATION          => aprvl_source_location,
	 P_SOURCE_MAILSTOP          => aprvl_source_mailstop,
	 P_TIME_ZONE                => aprvl_time_zone,
	 P_SUPPORT_SITE_ID          => aprvl_support_site_id,
	 P_PRIMARY_LANGUAGE         => aprvl_primary_language,
	 P_SECONDARY_LANGUAGE       => aprvl_secondary_language,
	 P_COST_PER_HR              => aprvl_cost_per_hr,
	 P_SOURCE_MOBILE_PHONE      => aprvl_source_mobile_phone,
	 P_SOURCE_PAGER             => aprvl_source_pager,
	 P_ATTRIBUTE_ACCESS_LEVEL   => 'UWA',
	 P_OBJECT_VERSION_NUMBER    => p_object_version_number,
	 X_RETURN_STATUS            => l_return_status,
	 X_MSG_COUNT                => x_msg_count,
	 X_MSG_DATA                 => x_msg_data
	);

   end if;

   l_mgr_name := old_rec.source_mgr_name;
   if(x_return_status=fnd_api.g_ret_sts_success)
   then
     -- bug # 2185983 success message was showed
     -- two times if atleast one field requires
     -- notification/apporval and atleast one field has
     -- full update
     if(l_u=1 and l_uwa=0 and l_uwn=0)
     then
        fnd_message.set_name ('JTF', 'JTF_RS_UPDATED');
        FND_MSG_PUB.add;
     else
       if(p_approved = 'A')
       then
           fnd_message.set_name ('JTF', 'JTF_RS_WF_APPROVAL');
           fnd_message.set_token('P_MGR',l_mgr_name);
           FND_MSG_PUB.add;
       elsif(p_approved= 'T')
       then
           fnd_message.set_name ('JTF', 'JTF_RS_WF_NOTIF');
           fnd_message.set_token('P_MGR',l_mgr_name);
           FND_MSG_PUB.add;
           fnd_message.set_name ('JTF', 'JTF_RS_UPDATED');
           FND_MSG_PUB.add;
       elsif((p_approved='TE') OR (p_approved = 'AE') OR
	     (l_u=1 AND l_uwa=1 AND l_uwn=0))
       then
           fnd_message.set_name ('JTF', 'JTF_RS_UPDATED');
           FND_MSG_PUB.add;
       end if;
     end if;

     if((l_u = 0) AND (l_uwn = 0) AND (l_uwa = 0) AND (p_approved = 'N'))
     then
       fnd_message.set_name ('JTF', 'JTF_RS_NO_CHANGES');
       FND_MSG_PUB.add;
     elsif((l_uwa= 1) AND (old_rec.source_mgr_id is not null))
     then
	open mgr_user(old_rec.source_mgr_id);
	fetch mgr_user into l_mgr_user_id ;
	if(mgr_user%found)
	then
	   fnd_message.set_name ('JTF', 'JTF_RS_WF_APPROVAL');
	    fnd_message.set_token('P_MGR',l_mgr_name);
	    FND_MSG_PUB.add;
	end if;
	close mgr_user;
     end if;

     FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   else
     ROLLBACK TO sp_save;
  end if;

 EXCEPTION
    WHEN hr_api_error
    THEN
      ROLLBACK TO sp_save;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('JTF','JTF_RS_HR_API_ERROR');
      fnd_message.set_token('P_SQLERRM',substr(SQLERRM,11));
      FND_MSG_PUB.add;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO sp_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO sp_save;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO sp_save;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END update_resource;




END jtf_rs_res_sswa_pub;

/
